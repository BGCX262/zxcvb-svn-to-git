require "go.app.GameServer"
require "uppuRacingProtocol"
require "uppuRacingConsts"
require "go.service.idogame.playerinfo"
require 'uppuRacingGameData'

class 'uppuRacingGameServer' (GameServer)

function uppuRacingGameServer:__init(...) super(...)
	math.randomseed(os.time())

	-- host
	self.host = nil
	self.owners = {}
	self.rank = {}
	self.retireRank = 0
	self.startCountDown	= -1
	self.playerInfos = {}

	-- FSM
	self.roomState = RoomState( self )
	self.roomState:ChangeState( self.roomState.Open )
	self.gameState = GameState( self )
	self.gameState:ChangeState( self.gameState.Wait )
	self.listUserState = { }
	self.numberOfUser = 0
	self.numberOfReadyUser = 0

	-- set network event handler
	self:SetMsgHandler(Object_NPO_List, self.OnObjectNPOList)
	self:SetMsgHandler(Object_Create, self.OnObjectCreate)
	self:SetMsgHandler(Object_Sync, self.OnObjectSync)
	self:SetMsgHandler(Object_Delete, self.OnObjectDelete)
	self:SetMsgHandler(Object_Lock, self.OnObjectLock)
	self:SetMsgHandler(Object_Force, self.OnObjectForce)
	self:SetMsgHandler(Effect_Sync, self.OnEffectSync)
	self:SetMsgHandler(RTT_Check, self.OnRecvRTTCheck)
	self:SetMsgHandler(Noti_PlayerReady, self.OnNotiPlayerReady)
	self:SetMsgHandler(Noti_ChangeCarType, self.OnChangeCarType)
	self:SetMsgHandler(Noti_LoadingCompleted, self.OnLoadingCompleted)
	self:SetMsgHandler(Game_CutFinish, self.OnGameCutFinish)
	self:SetMsgHandler(Noti_Chat, self.OnNotiChat)
	self:SetMsgHandler(Noti_ChangeMap, self.OnChangeMap)

	-- rtt check timer (1sec)
	self:SetTimer(1, 1)
end

function uppuRacingGameServer:SendUnreliableToAll(msg, except)
	for i = 1, #__player do
		if (not except) or (except ~= __player[i]) then
			if __player[i]:IsConnected() then
				self.proxy:SendUnreliable(__player[i], msg)
			end
		end
	end
end

function uppuRacingGameServer:MakeMessageNoti_EnterPlayer(player, playerInfo, hostno)
	local event = Message(Noti_EnterPlayer)
	event:SetValue(Noti_EnterPlayer.key.no, player.no)
	event:SetValue(Noti_EnterPlayer.key.nick, playerInfo.nickname)
	event:SetValue(Noti_EnterPlayer.key.gender, playerInfo.gender)
	event:SetValue(Noti_EnterPlayer.key.age, playerInfo.age)
	event:SetValue(Noti_EnterPlayer.key.hostno, hostno)
	event:SetValue(Noti_EnterPlayer.key.mapNo, self.gameState.mapNo)

	return event
end

function uppuRacingGameServer:SetHost()
	if self.host == nil then
		self.host = __player[1]
		return true
	end

	-- find low rtt
	local minrtt = 9999
	local minplayer = nil
	for i = 1, #__player do
		if __player[i]:IsConnected() then
			if __player[i].RTT and __player[i].RTT < minrtt then
				minrtt = __player[i].RTT
				minplayer = __player[i]
			end
		end
	end

	if minplayer == nil then
		self.host = nil
		return false
	end

	self.host = minplayer
	return true
end

---------------------------------------------------------
-- Game Handler
---------------------------------------------------------
function uppuRacingGameServer:OnJoinPlayer(player)
	self.listUserState[player.no] = UserState( self, player.no, true )
	self.listUserState[player.no]:ChangeState( self.listUserState[player.no].Join )

	player.RTT = 0

	-- set host
	self:SetHost()

	-- load player info
	local playerInfo = PlayerInfo(player)
	playerInfo:Load()	

	local newbieString = string.format("[GameServer:OnEnterPlayer] User = %s", playerInfo:__tostring())
	print(newbieString)
	--print(playerInfo)

	-- send player info to all (include yourself)
	local event = self:MakeMessageNoti_EnterPlayer(player, playerInfo, self.host.no)
	self:SendToAll(event)

	-- send oldbie-players info to newbie (not include yourself)
	for i = 1, #__player do
		if player ~= __player[i] then
			if __player[i]:IsConnected() then

				-- load player info
				playerInfo = PlayerInfo(__player[i])
				playerInfo:Load()

				print(string.format("[GameServer:OnEnterPlayer] Send UserInfo[%s] to User = %s", playerInfo:__tostring(), newbieString))

				-- send all player info to newbie
				event = self:MakeMessageNoti_EnterPlayer(__player[i], playerInfo)
				self.proxy:Send(player, event)

			end
		end

		-- add playerinfo
		self.playerInfos[i] = playerInfo
	end

	local msg = Message( Noti_ChangeHost )
	if self.gameState.hostNo == 0 then
		self.gameState.hostNo = player.no
		msg:SetValue( Noti_ChangeHost.key.hostno, player.no )
		self:SendToAll( msg )

		msg = Message( Noti_GameReady )
		self:SendToAll( msg )
	else
		msg:SetValue( Noti_ChangeHost.key.hostno, self.gameState.hostNo )
		self:SendToAll( msg )
	end

	self.listUserState[player.no]:ChangeState( self.listUserState[player.no].Wait )
	self:SendStateChange()

	for i = 1, #__player do
		if player ~= __player[i] then
			if __player[i]:IsConnected() then
				-- send player ready state to newbie
				if self.listUserState[i].isReady == true then
					local msg = Message( Noti_PlayerReady )
					msg:SetValue( Noti_PlayerReady.key.no, i )
					self.proxy:Send( player, msg )
				end
				if self.listUserState[i].carType ~= 1 then
					local msg = Message( Noti_ChangeCarType )
					msg:SetValue( Noti_ChangeCarType.key.no, i )
					msg:SetValue( Noti_ChangeCarType.key.carType, self.listUserState[i].carType )
					self.proxy:Send( player, msg )
				end				
			end
		end
	end


	self.numberOfUser = self.numberOfUser + 1
end

function uppuRacingGameServer:OnLeavePlayer(player)
	if player == self.host then
		self:SetHost()
	end	

	if self.gameState.hostNo == player.no then
		local msg = Message( Noti_ChangeHost )
		for i, v in pairs (self.listUserState) do
			if i ~= player.no then
				self.gameState.hostNo = i
				msg:SetValue( Noti_ChangeHost.key.hostno, i )
				self:SendToAll( msg )
				if self.listUserState[i].isReady == true then
					self.listUserState[i].isReady = false
					self.numberOfReadyUser = self.numberOfReadyUser - 1
					msg = Message( Noti_PlayerReady )
					msg:SetValue( Noti_PlayerReady.key.no, i )
					self:SendToAll( msg )
				end
				break
			end
		end
	end

	self.listUserState[player.no]:ChangeState( self.listUserState[player.no].Leave )
	self:SendUserStateChange( self.listUserState[player.no] )

	self.numberOfUser = self.numberOfUser - 1
	if self.listUserState[player.no].isReady == true then
		self.numberOfReadyUser = self.numberOfReadyUser - 1
	else
		if self.gameState:GetFSM():GetCurrentState() == self.gameState.Wait and self.numberOfUser == self.numberOfReadyUser + 1 then
			local msg = Message( Noti_GameReady )
			self:SendToAll( msg )
		elseif self.gameState:GetFSM():GetCurrentState() == self.gameState.Wait and self.numberOfUser == self.numberOfReadyUser then
			self:StartGame()
		end
	end

	self.listUserState[player.no] = nil
end

function uppuRacingGameServer:StartGame()
	self.roomState:ChangeState( self.roomState.Close )
	self.gameState:ChangeState( self.gameState.Play )
	for i, v in pairs ( self.listUserState ) do
		v:ChangeState( v.Play )
	end
	self:SendStateChange()

	-- load gamedata
	self.bestRecord = self:LoadGameData()

	-- send map record message
	local mapRecord = Message(Game_MapRecord)
	if self.bestRecord then
		mapRecord:SetValue(Game_MapRecord.key.record, self.bestRecord:GetString())
	end
	self:SendToAll(mapRecord)

	-- send start message
	local startMsg = Message( Noti_GameStart )
	self:SendToAll( startMsg )
end

function uppuRacingGameServer:LoadGameData()
	local uppudata = LoadGameData()
	assert(uppudata)

	for mapname, record in pairs(uppudata.bestRecords) do
		if mapname == MAP_INFO[self.gameState.mapNo][2] then
			print (string.format("%s map's best record: nickname[%s] id[%s] bestrecord[%s]", MAP_INFO[self.gameState.mapNo][2], record.nickname, record.id, TimeToString(record.besttime)))
			return record
		end
	end

	print (string.format("%s map's best record not found", MAP_INFO[self.gameState.mapNo][2]))
	return nil
end

function uppuRacingGameServer:SaveGameData()
	local uppudata = LoadGameData()
	assert(uppudata)

	print (string.format("save best time id[%s] time[%s]", self.bestRecord.nickname, TimeToString(self.bestRecord.besttime)))

	uppudata.bestRecords[ MAP_INFO[self.gameState.mapNo][2] ] = self.bestRecord

	SaveGameData(uppudata)
end

function uppuRacingGameServer:OnTimer(timerid)
	local msg = Message(RTT_Check)
	for i = 1, #__player do
		if __player[i]:IsConnected() then
			msg:SetValue(RTT_Check.key.servertime, App.GetCurrentSeconds())
			--self:SendTo(__player[i], msg)
			self.proxy:SendUnreliable(__player[i], msg)

			-- print RTT
			print (string.format("player%d's RTT = %fms", i, __player[i].RTT*1000))
		end
	end

	-- RTT broadcast
	msg = Message(RTT_Broadcast)

	local rtt1 = 0
	if __player[1].RTT then rtt1 = __player[1].RTT*1000 end
	local rtt2 = 0
	if __player[2].RTT then rtt2 = __player[2].RTT*1000 end
	local rtt3 = 0
	if __player[3].RTT then rtt3 = __player[3].RTT*1000 end
	local rtt4 = 0
	if __player[4].RTT then rtt4 = __player[4].RTT*1000 end

	msg:SetValue(RTT_Broadcast.key.rtt1, rtt1 )
	msg:SetValue(RTT_Broadcast.key.rtt2, rtt2 )
	msg:SetValue(RTT_Broadcast.key.rtt3, rtt3 )
	msg:SetValue(RTT_Broadcast.key.rtt4, rtt4 )
	self:SendUnreliableToAll(msg)

	-- start count donw
	if self.startCountDown > 0 then
		msg = Message(Noti_GoCountDown)
		msg:SetValue(Noti_GoCountDown.key.count, self.startCountDown)
		self:SendToAll(msg)

		self.startCountDown	= self.startCountDown - 1
	elseif self.startCountDown == 0 then
		local readygo = Message(Noti_ReadyGo)
		self:SendToAll(readygo)

		-- reset game
		self.startCountDown = -1
		self.retireRank = 0
	end

	-- check game end
	self:CheckGameEnd()
end

---------------------------------------------------------
-- Network Handler
---------------------------------------------------------
function uppuRacingGameServer:OnObjectNPOList(player, msg)
	local npolist = List()
	local npostring = msg:GetValue(Object_NPO_List.key.list)
	npolist:SetString(npostring)

	print (string.format("npo list len = %d", string.len(npostring)))

	for i, oid in pairs(npolist.list) do
		if oid ~= nil then
			self.owners[oid] = 0	-- no owner
		end
	end
end

function uppuRacingGameServer:OnObjectCreate(player, msg)
	self:SendUnreliableToAll(msg, player)
end

function uppuRacingGameServer:OnObjectSync(player, msg)
	local classtype = msg:GetValue(Object_Sync.key.c)

	-- npo의 경우, 다른 사람에게 own되어 있는 객체를 움직일 수 없다.
	if classtype == CLASS_NPO then
		local owner = msg:GetValue(Object_Sync.key.n)
		local oid = msg:GetValue(Object_Sync.key.o)

		print (string.format("OnObjectSync: owner=%d, oid=%d, self.owner[oid]=%d", owner, oid, self.owners[oid]))
		assert(self.owners[oid])
		if self.owners[oid] ~= owner then
			return
		end
	end
	self:SendUnreliableToAll(msg, player)
end

function uppuRacingGameServer:OnObjectDelete(player, msg)
	self:SendUnreliableToAll(msg, player)
end

function uppuRacingGameServer:OnObjectLock(player, msg)
	local owner = msg:GetValue(Object_Lock.key.no)
	local oid = msg:GetValue(Object_Lock.key.oid)

	-- set new owner
	assert(self.owners[oid])
	assert(owner)
	self.owners[oid] = owner

	self:SendUnreliableToAll(msg, player)
end

function uppuRacingGameServer:OnObjectForce(player, msg)
	self:SendUnreliableToAll(msg, player)
end

function uppuRacingGameServer:OnEffectSync(player, msg)
	self:SendUnreliableToAll(msg, player)
end

function uppuRacingGameServer:OnRecvRTTCheck(player, msg)
	local sendtime = msg:GetValue(RTT_Check.key.servertime)
	local rtt = App.GetCurrentSeconds() - sendtime

	-- set RTT
	player.RTT = rtt	
end

function uppuRacingGameServer:OnNotiPlayerReady(player, msg)
	if self.listUserState[msg:GetValue(Noti_PlayerReady.key.no)].isReady == true then
		self.listUserState[msg:GetValue(Noti_PlayerReady.key.no)].isReady = false
		self.numberOfReadyUser = self.numberOfReadyUser - 1
	else
		self.listUserState[msg:GetValue(Noti_PlayerReady.key.no)].isReady = true
		self.numberOfReadyUser = self.numberOfReadyUser + 1
	end
	self:SendToAll( msg )

	if self.gameState:GetFSM():GetCurrentState() == self.gameState.Wait and self.numberOfUser == self.numberOfReadyUser + 1 then
		local msg = Message( Noti_GameReady )
		self:SendToAll( msg )
	elseif self.gameState:GetFSM():GetCurrentState() == self.gameState.Wait and self.numberOfUser == self.numberOfReadyUser then
		self:StartGame()
	end
end

function uppuRacingGameServer:OnChangeCarType(player, msg)
	self.listUserState[msg:GetValue(Noti_ChangeCarType.key.no)].carType = msg:GetValue(Noti_ChangeCarType.key.carType)
	self:SendToAll( msg )
end

function uppuRacingGameServer:OnLoadingCompleted(player, msg)
	self.listUserState[player.no].loading = true

	-- check all completed
	for i = 1, #__player do
		if __player[i]:IsConnected() then
			if self.listUserState[i].loading ~= true then
				return
			end			
		end
	end

	-- clear all flags for next game
	for i = 1, #__player do
		if __player[i]:IsConnected() then
			self.listUserState[i].loading = false
		end			
	end

	-- send to all readygo
	self.startCountDown = 3
	--local readygo = Message(Noti_ReadyGo)
	--self:SendToAll(readygo)
end

function uppuRacingGameServer:GetCurrentPlayerCount()
	local count = 0
	for i = 1, #__player do
		if __player[i]:IsConnected() then
			count = count + 1
		end			
	end
	return count
end

function uppuRacingGameServer:CheckGameEnd()
	if #self.rank > 0 and #self.rank == self:GetCurrentPlayerCount() then
		local endmsg = Message(Game_Result)
		endmsg:SetValue(Game_Result.key.no1, self.rank[1])
		endmsg:SetValue(Game_Result.key.no2, self.rank[2])
		endmsg:SetValue(Game_Result.key.no3, self.rank[3])
		endmsg:SetValue(Game_Result.key.no4, self.rank[4])
		endmsg:SetValue(Game_Result.key.retireRank, self.retireRank) 

		self:SendToAll(endmsg)

		-- save game data
		self:SaveGameData()

		self.rank = {}

		-- set all user not ready
		for userNo, userState in pairs(self.listUserState) do
			if userState then
				userState.isReady = false
			end
		end
		self.numberOfReadyUser = 0

		self.roomState:ChangeState( self.roomState.Open )
		self.gameState:ChangeState( self.gameState.Wait )
		for i, v in pairs ( self.listUserState ) do
			v:ChangeState( v.Wait )
		end
		--self:SendStateChange()
	end
end

function uppuRacingGameServer:OnGameCutFinish(player, msg)
	local retire = msg:GetValue(Game_CutFinish.key.retire)
	local time = msg:GetValue(Game_CutFinish.key.time)

	self.rank[#self.rank+1] = player.no
	
	print (string.format("#self.rank = %d, playerno = %d cut time %s", #self.rank, player.no, TimeToString(time)))

	-- 1등 time을 best로 남길지 체크
	if #self.rank == 1 then
		-- find player
		local info = self.playerInfos[player.no]

		if self.bestRecord == nil then
			self.bestRecord = uppuRacingMapRecord()
			self.bestRecord.mapname = MAP_INFO[self.gameState.mapNo][2]
			self.bestRecord.nickname = info.nickname
			self.bestRecord.id = info.playerId
			self.bestRecord.besttime = time
		elseif self.bestRecord.besttime == 0 or self.bestRecord.besttime > time then
			self.bestRecord.mapname = MAP_INFO[self.gameState.mapNo][2]
			self.bestRecord.nickname = info.nickname
			self.bestRecord.id = info.playerId
			self.bestRecord.besttime = time
		end
	end

	-- self.retireRank 등수부터는 retire
	if self.retireRank == 0 then
		if retire then
			self.retireRank = #self.rank
		end
	end

	print(string.format("#### OnGameCutFinish: player%d = rank %d", player.no, #self.rank))

	local resmsg = Message(Game_CutFinishResult)
	resmsg:SetValue(Game_CutFinishResult.key.no, player.no)
	resmsg:SetValue(Game_CutFinishResult.key.rank, #self.rank)
	resmsg:SetValue(Game_CutFinishResult.key.retire, retire)
	self:SendToAll(resmsg)
end

function uppuRacingGameServer:OnNotiChat(player, msg)
	self:SendToAll(msg)
end

function uppuRacingGameServer:OnChangeMap(player, msg)
	self.gameState.mapNo = msg:GetValue( Noti_ChangeMap.key.no )
	self:SendToAll(msg)
end

-- Send Room, Game, User State Change to All Clients
function uppuRacingGameServer:SendStateChange()
	self:SendRoomStateChange()
	self:SendGameStateChange()
	
	for i, v in pairs ( self.listUserState ) do
		self:SendUserStateChange( v )
	end
end

-- Send Room State Change to All Clients
function uppuRacingGameServer:SendRoomStateChange()
	local msg = Message( Noti_ChangeRoomState )

	if self.roomState:GetFSM():GetCurrentState() == self.roomState.Open then
		msg:SetValue( Noti_ChangeRoomState.key.stateFlag, RoomState.Open )
	elseif self.roomState:GetFSM():GetCurrentState() == self.roomState.PlayerOpen then
		msg:SetValue( Noti_ChangeRoomState.key.stateFlag, RoomState.PlayerOpen )
	elseif self.roomState:GetFSM():GetCurrentState() == self.roomState.ObserverOpen then
		msg:SetValue( Noti_ChangeRoomState.key.stateFlag, RoomState.ObserverOpen )
	elseif self.roomState:GetFSM():GetCurrentState() == self.roomState.Close then
		msg:SetValue( Noti_ChangeRoomState.key.stateFlag, RoomState.Close )
	end

	self:SendToAll( msg )
end

-- Send Game State Change to All Clients
function uppuRacingGameServer:SendGameStateChange()
	local msg = Message( Noti_ChangeGameState )

	if self.gameState:GetFSM():GetCurrentState() == self.gameState.Wait then
		msg:SetValue( Noti_ChangeGameState.key.stateFlag, GameState.Wait )
	elseif self.gameState:GetFSM():GetCurrentState() == self.gameState.Play then
		msg:SetValue( Noti_ChangeGameState.key.stateFlag, GameState.Play )
	end

	self:SendToAll( msg )
end

-- Send User State Change to All Clients
function uppuRacingGameServer:SendUserStateChange( userState )
	local msg = Message( Noti_ChangeUserState )
	msg:SetValue( Noti_ChangeUserState.key.userNo, userState.userNo )
	msg:SetValue( Noti_ChangeUserState.key.isPlayer, userState.isPlayer )

	if userState:GetFSM():GetCurrentState() == userState.Join then
		msg:SetValue( Noti_ChangeUserState.key.stateFlag, UserState.Join )
	elseif userState:GetFSM():GetCurrentState() == userState.Wait then
		msg:SetValue( Noti_ChangeUserState.key.stateFlag, UserState.Wait )
	elseif userState:GetFSM():GetCurrentState() == userState.Play then
		msg:SetValue( Noti_ChangeUserState.key.stateFlag, UserState.Play )
	elseif userState:GetFSM():GetCurrentState() == userState.View then
		msg:SetValue( Noti_ChangeUserState.key.stateFlag, UserState.View )
	elseif userState:GetFSM():GetCurrentState() == userState.Leave then
		msg:SetValue( Noti_ChangeUserState.key.stateFlag, UserState.Leave )
	end

	self:SendToAll( msg )
end