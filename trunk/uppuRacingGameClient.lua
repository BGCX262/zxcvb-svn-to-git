require "uppuRacingSoundObject"  -- should be required before the definition of inherited class from Client
require "go.app.GameClient"
require "go.service.idogame.PlayerInfo"

require "uppuRacingScene"
require "Scene_WaitingRoom"

require "uppuRacingProtocol"
require "uppuRacingGameData"


class 'uppuRacingGameClient' (GameClient)

function uppuRacingGameClient:__init(...) super(...)
	math.randomseed(os.time())

	self.rtt = {}		-- players' rtt
	self.hostno = nil	-- player no of host
	self.players = {}
	self.playerInfos = {}

--		self:LoadXML("Scene.xml", true)

	print("adfadf")

	self.scene = uppuRacingScene(1)
	self.waitScene = Scene_WaitingRoom(5)
	self:ActivateScene(self.waitScene)
	
	self:SetupSoundObjects()

	-- record current time
	self.lastsec = App.GetCurrentSeconds()

	self:SetClearColor(UIConst.Black)	
	self:SetScreenPivot(self.scene.pivot.x,self.scene.pivot.y)

	-- set network event handler
	self:SetMsgHandler(Noti_EnterPlayer, self.OnNotiEnterPlayer)
	self:SetMsgHandler(Noti_LeavePlayer, self.OnNotiLeavePlayer)
	self:SetMsgHandler(Object_Create, self.OnObjectCreate)
	self:SetMsgHandler(Object_Lock, self.OnObjectLock)
	self:SetMsgHandler(Object_Sync, self.OnObjectSync)
	self:SetMsgHandler(Object_Delete, self.OnObjectDelete)
	self:SetMsgHandler(Object_Force, self.OnObjectForce)
	self:SetMsgHandler(Effect_Sync, self.OnEffectSync)
	self:SetMsgHandler(RTT_Check, self.OnRTTCheck)
	self:SetMsgHandler(RTT_Broadcast, self.OnRTTBroadcast)

	self:SetMsgHandler(Noti_PlayerReady, self.OnNotiPlayerReady )
	self:SetMsgHandler(Noti_ChangeCarType, self.OnChangeCarType )
	self:SetMsgHandler(Noti_GameStart, self.OnNotiGameStart )
	self:SetMsgHandler(Noti_GoCountDown, self.OnGoCountDown)
	self:SetMsgHandler(Noti_ReadyGo, self.OnReadyGo)
	self:SetMsgHandler(Game_Result, self.OnGameResult)
	self:SetMsgHandler(Game_CutFinishResult, self.OnGameCutFinishResult)
	self:SetMsgHandler(Game_MapRecord, self.OnGameMapRecord)
	self:SetMsgHandler(Noti_Chat, self.OnNotiChat)
	self:SetMsgHandler(Noti_ChangeHost, self.OnNotiChangeHost)
	self:SetMsgHandler(Noti_GameReady, self.OnNotiGameReady)
	self:SetMsgHandler(Noti_ChangeMap, self.OnChangeMap)

	self:SetMsgHandler(Noti_ChangeRoomState, self.OnNotiChangeRoomState)
	self:SetMsgHandler(Noti_ChangeGameState, self.OnNotiChangeGameState)
	self:SetMsgHandler(Noti_ChangeUserState, self.OnNotiChangeUserState)

	-- FSM
	self.roomState = RoomState( self )
	self.gameState = GameState( self )
	self.listUserState = { }

	self.recvGameStarted = false
end

function uppuRacingGameClient:SendUnreliableToServer(msg)
	if self.proxy == nil then
		print("Error! Server has not connected.")
		return
	end
	self.proxy:SendUnreliable(self.serverProxy, msg)
end

---------------------------------------------------------
-- Game Handler
---------------------------------------------------------
function uppuRacingGameClient:OnEnter()
	local player = self:GetSelfPlayer()
	self.playerNo = player.no
	self.sndEnterRoom:PlaySound(false)

	self.players[player.no] = player
	self.playerInfos[player.no] = nil
end

function uppuRacingGameClient:OnExit()
	local player = self:GetSelfPlayer()
	self.players[player.no] = nil
	self.playerInfos[player.no] = nil
end

function uppuRacingGameClient:OnDisconnected()

end

function uppuRacingGameClient:OnJoinPlayer(player)
	self.sndEnterPlayer:PlaySound(false)

	self.players[player.no] = player
	self.playerInfos[player.no] = nil
end

function uppuRacingGameClient:OnLeavePlayer(player)
	if self.scene.map then
		local oid = GetCarOID(player.no)
		self.scene.map:DeleteObject(oid, self.playerNo)
	end
	self.sndLeavePlayer:PlaySound(false)

	self.players[player.no] = nil
	self.playerInfos[player.no] = nil
end

function uppuRacingGameClient:OnTimer(timerid)
	if timerid == TIMER_GAMERESULT then
		self.scene:ShowGameResult(self.ranks, self.retireRank)

		self:KillTimer(TIMER_GAMERESULT)
		self:SetTimer(TIMER_GAMERESULT2, 4)

	elseif timerid == TIMER_GAMERESULT2 then
		self.roomState:ChangeState(self.roomState.Open)
		self.gameState:ChangeState(self.gameState.Wait)
		self.listUserState[self.playerNo]:ChangeState(self.listUserState[self.playerNo].Wait)

		local n = 0
		for userNo, userState in pairs(self.listUserState) do
			if userState then
				userState:OnUserUnready()
			end
			n = n + 1
		end
		if n == 1 then
			self.waitScene.btnReady:Enable(true)
			self.waitScene.btnPrevMap:Enable(true)
			self.waitScene.btnNextMap:Enable(true)
		end

		self.scene:DeleteMap()
		self.scene:EndRacing()
		self.scene:HideGameResult()

		gameapp:SetScreenPivot(SCREEN_SIZE_X/2, SCREEN_SIZE_Y/2)
		self:ActivateScene(self.waitScene)
		Scene.latestScene = self.waitScene

		self:KillTimer(TIMER_GAMERESULT2)
		self:ResetRetireTimer()
	elseif timerid == TIMER_RETIRECOUNT then
		if self.retireCount == 0 then
			-- retire!!
			local msg = Message(Game_CutFinish)
			msg:SetValue(Game_CutFinish.key.retire, true)
			self:SendToServer(msg)

			self.scene:PlayRetire()
			self:ResetRetireTimer()
	else
			self.scene:PlayCount(self.retireCount)
			self.retireCount = self.retireCount - 1
		end
	end
end

function uppuRacingGameClient:ResetRetireTimer()
	if self.scene.imageCountDown then
		self.scene.imageCountDown:Show(false)
	end
	self.retireCount = 10	
	self:KillTimer(TIMER_RETIRECOUNT)
end

function uppuRacingGameClient:Update(seconds)
	if self.currentScene then
		self.currentScene:Update(seconds - self.lastsec)
		self.lastsec = seconds
	end
end

---------------------------------------------------------
-- Network Handler
---------------------------------------------------------
function uppuRacingGameClient:OnNotiEnterPlayer(server, msg)
	local playerNo = msg:GetValue(Noti_EnterPlayer.key.no)
	local playerNick = msg:GetValue(Noti_EnterPlayer.key.nick)
	local playerAge = msg:GetValue(Noti_EnterPlayer.key.age)
	local playerGender = msg:GetValue(Noti_EnterPlayer.key.gender)
	local mapNo = msg:GetValue(Noti_EnterPlayer.key.mapNo)
	self.hostno = msg:GetValue(Noti_EnterPlayer.key.hostno)

	-- set player info
	local info = PlayerInfo(self.players[playerNo])
	info.nickname = playerNick
	info.age = playerAge
	info.gender = playerGender
	self.playerInfos[playerNo] = info

	if self.listUserState[playerNo] == nil then
		self.listUserState[playerNo] = UserState( self, playerNo, isPlayer )
		self.listUserState[playerNo]:ChangeState( self.listUserState[playerNo].Join )
	end
	self.listUserState[playerNo].nickname = playerNick
	self.gameState.mapNo = mapNo

	print(string.format("[GameClient:OnNotiEnterPlayer] User = no[%d] nick[%s] age[%d] gender[%s]", playerNo, playerNick, playerAge, playerGender))
end

function uppuRacingGameClient:OnNotiLeavePlayer(server, msg)
	
end

function uppuRacingGameClient:OnNotiPlayerReady(server, msg)
	local userNo = msg:GetValue( Noti_PlayerReady.key.no )
	self.listUserState[userNo]:OnUserReady(msg)
end

function uppuRacingGameClient:OnChangeCarType(server, msg)
	local userNo = msg:GetValue( Noti_ChangeCarType.key.no )
	self.listUserState[userNo]:OnChangeCarType(msg)
end

function uppuRacingGameClient:OnNotiGameStart( sender, msg )
	print("game start!")

	-- set racing scene
	self:ActivateScene(self.scene)
	Scene.latestScene = self.scene

	-- todo: create selected map
	self.scene:CreateMap(self.playerNo)

	for playerNo, playerState in pairs( self.listUserState ) do
		if self.playerNo == playerNo then
			-- my info
			self.scene:CreateMasterCar( playerState.nickname, playerNo, Vector2(300 + 100*playerNo, 150) )
		else
			-- their info
			self.scene:CreateSlaveCar( playerState.nickname, playerNo, Vector2(300 + 100*playerNo, 150) )
		end
	end

	-- noti to server that map-loading is completed
	-- force update scene to load all resources
	--self.scene:Update(0)	
	local msg = Message(Noti_LoadingCompleted)
	self:SendToServer(msg)
end

function uppuRacingGameClient:OnGoCountDown(server, msg)
	local count = msg:GetValue(Noti_GoCountDown.key.count)
	self.scene:PlayCount(count)
end

function uppuRacingGameClient:OnReadyGo(server, msg)
	self.scene:StartRacing()
end

function uppuRacingGameClient:OnGameResult(server, msg)
	self.ranks = {}

	self.ranks[1] = msg:GetValue(Game_Result.key.no1)
	self.ranks[2] = msg:GetValue(Game_Result.key.no2)
	self.ranks[3] = msg:GetValue(Game_Result.key.no3)
	self.ranks[4] = msg:GetValue(Game_Result.key.no4)
	self.retireRank = msg:GetValue(Game_Result.key.retireRank)

	self:SetTimer(TIMER_GAMERESULT, 3)
end

function uppuRacingGameClient:OnGameCutFinishResult(server, msg)
	local no = msg:GetValue(Game_CutFinishResult.key.no)
	local rank = msg:GetValue(Game_CutFinishResult.key.rank)
	local retire = msg:GetValue(Game_CutFinishResult.key.retire)

	-- show rank for me
	if no == self.playerNo then
		self.scene:PlayRank(rank)
	elseif retire == true then
		-- retire
	elseif rank == 1 then
		self.retireCount = 10
		self:SetTimer(TIMER_RETIRECOUNT, 1)
	end
end

function uppuRacingGameClient:OnGameMapRecord(server, msg)
	-- set best record
	local recordString = msg:GetValue(Game_MapRecord.key.record)
	if recordString then
		local record = uppuRacingMapRecord()
		record:SetString(recordString)

		-- todo: 맵으로 옮기자
		self.bestRecord = record
	end
end

function uppuRacingGameClient:OnNotiChangeRoomState(server, msg)
	local stateFlag = msg:GetValue( Noti_ChangeRoomState.key.stateFlag )
	if stateFlag == RoomState.Open then
		self.roomState:ChangeState( self.roomState.Open )
	--elseif stateFlag == RoomState.PlayerOpen then
	--	self.roomState:ChangeState( self.roomState.PlayerOpen )
	--elseif stateFlag == RoomState.ObserverOpen then
	--	self.roomState:ChangeState( self.roomState.ObserverOpen )
	elseif stateFlag == RoomState.Close then
		self.roomState:ChangeState( self.roomState.Close )
	end
end

function uppuRacingGameClient:OnNotiChangeGameState(server, msg)
	local stateFlag = msg:GetValue( Noti_ChangeGameState.key.stateFlag )
	if stateFlag == GameState.Wait then
		self.gameState:ChangeState( self.gameState.Wait )
	elseif stateFlag == GameState.Play then
		self.gameState:ChangeState( self.gameState.Play )
	end
end

function uppuRacingGameClient:OnNotiChangeUserState(server, msg)
	local stateFlag = msg:GetValue( Noti_ChangeUserState.key.stateFlag )
	local userNo = msg:GetValue( Noti_ChangeUserState.key.userNo )
	local isPlayer = msg:GetValue( Noti_ChangeUserState.key.isPlayer )

	if stateFlag == UserState.Join then
		self.listUserState[userNo]:ChangeState( self.listUserState[userNo].Join )
	elseif stateFlag == UserState.Wait then
		self.listUserState[userNo]:ChangeState( self.listUserState[userNo].Wait )
	elseif stateFlag == UserState.Play then
		self.listUserState[userNo]:ChangeState( self.listUserState[userNo].Play )
	elseif stateFlag == UserState.View then
		self.listUserState[userNo]:ChangeState( self.listUserState[userNo].View )
	elseif stateFlag == UserState.Leave then
		self.listUserState[userNo]:ChangeState( self.listUserState[userNo].Leave )
		self.listUserState[userNo] = nil
	end
end

function uppuRacingGameClient:OnObjectCreate(server, msg)
	local owner = msg:GetValue(Object_Sync.key.n)
	local x0 = msg:GetValue(Object_Sync.key.x)	-- body position x
	local y0 = msg:GetValue(Object_Sync.key.y)	-- body position y
	local r0 = msg:GetValue(Object_Sync.key.r)	-- body angle (rad)
	local oid = msg:GetValue(Object_Sync.key.o)
	local vx = msg:GetValue(Object_Sync.key.X)
	local vy = msg:GetValue(Object_Sync.key.Y)
	local vr = msg:GetValue(Object_Sync.key.R)
	local classtype = msg:GetValue(Object_Sync.key.c)
	if vy == nil then vy = 0 end
	if vx == nil then vx = 0 end
	if vr == nil then vr = 0 end

	local pos0 = b2Vec2(x0, y0)
	local v0 = b2Vec2(vx, vy)
	
	self.scene:ObjectCreate(owner, oid, pos0, r0, v0, vr)
end

function uppuRacingGameClient:OnObjectLock(server, msg)
	local owner = msg:GetValue(Object_Lock.key.no)
	local oid = msg:GetValue(Object_Lock.key.oid)

	self.scene:ObjectLock(owner, oid)	
end

function uppuRacingGameClient:OnObjectSync(server, msg)
	local owner = msg:GetValue(Object_Sync.key.n)
	local x0 = msg:GetValue(Object_Sync.key.x)	-- body position x
	local y0 = msg:GetValue(Object_Sync.key.y)	-- body position y
	local r0 = msg:GetValue(Object_Sync.key.r)	-- body angle (rad)
	local oid = msg:GetValue(Object_Sync.key.o)
	local vx = msg:GetValue(Object_Sync.key.X)
	local vy = msg:GetValue(Object_Sync.key.Y)
	local vr = msg:GetValue(Object_Sync.key.R)
	local classtype = msg:GetValue(Object_Sync.key.c)
	if vy == nil then vy = 0 end
	if vx == nil then vx = 0 end
	if vr == nil then vr = 0 end

	local pos0 = b2Vec2(x0, y0)
	local v0 = b2Vec2(vx, vy)
	
	self.scene:ObjectSync(owner, oid, pos0, r0, v0, vr)
end

function uppuRacingGameClient:OnObjectDelete(server, msg)
	local owner = msg:GetValue(Object_Sync.key.n)
	local x0 = msg:GetValue(Object_Sync.key.x)	-- body position x
	local y0 = msg:GetValue(Object_Sync.key.y)	-- body position y
	local r0 = msg:GetValue(Object_Sync.key.r)	-- body angle (rad)
	local oid = msg:GetValue(Object_Sync.key.o)
	local vx = msg:GetValue(Object_Sync.key.X)
	local vy = msg:GetValue(Object_Sync.key.Y)
	local vr = msg:GetValue(Object_Sync.key.R)
	local classtype = msg:GetValue(Object_Sync.key.c)
	if vy == nil then vy = 0 end
	if vx == nil then vx = 0 end
	if vr == nil then vr = 0 end

	local pos0 = b2Vec2(x0, y0)
	local v0 = b2Vec2(vx, vy)

	self.scene:ObjectDelete(owner, oid, pos0, r0, v0, vr)
end

function uppuRacingGameClient:OnObjectForce(server, msg)
	local srcoid = msg:GetValue(Object_Force.key.srcoid)
	local tgtoid = msg:GetValue(Object_Force.key.tgtoid)
	local fx = msg:GetValue(Object_Force.key.fx)
	local fy = msg:GetValue(Object_Force.key.fy)
	local x = msg:GetValue(Object_Force.key.x)
	local y = msg:GetValue(Object_Force.key.y)

	local force = b2Vec2(fx, fy)
	local pos0 = b2Vec2(x, y)

	self.scene:ObjectForce(srcoid, tgtoid, pos0, force)	
end

function uppuRacingGameClient:OnEffectSync(server, msg)
	local owner = msg:GetNValue(Effect_Sync.key.no)
	local oid = msg:GetNValue(Effect_Sync.key.oid)
	local effect = msg:GetValue(Effect_Sync.key.effect)

	self.scene:EffectSync(owner, oid, effect)
end

function uppuRacingGameClient:OnRTTCheck(server, msg)
	-- echo back
	self:SendUnreliableToServer(msg)
end

function uppuRacingGameClient:OnRTTBroadcast(server, msg)
	local rtt1 = msg:GetValue(RTT_Broadcast.key.rtt1)
	local rtt2 = msg:GetValue(RTT_Broadcast.key.rtt2)
	local rtt3 = msg:GetValue(RTT_Broadcast.key.rtt3)
	local rtt4 = msg:GetValue(RTT_Broadcast.key.rtt4)

	self.rtt[1] = rtt1
	self.rtt[2] = rtt2	
	self.rtt[3] = rtt3	
	self.rtt[4] = rtt4	
end

function uppuRacingGameClient:OnNotiChat(server, msg)
	if msg:GetValue( Noti_Chat.key.no ) == __main.selfplayer.no then
		self.waitScene.textlistChat:AddLine( msg:GetValue( Noti_Chat.key.chatText ), 0xffffffff )
	else
		self.waitScene.textlistChat:AddLine( msg:GetValue( Noti_Chat.key.chatText ), 0xffbbbbbb )
	end
	self.waitScene.textlistChat:SetDisplayLine(UIConst.VertAlignBottom, self.waitScene.textlistChat:GetLineCount()-1)
end

function uppuRacingGameClient:OnNotiChangeHost(server, msg)
	self.gameState.hostNo = msg:GetValue( Noti_ChangeHost.key.hostno )
	if __main.selfplayer.no == self.gameState.hostNo then
		self.waitScene.btnReady:LoadButtonImage( "images\\btnStart.bmp", 1, 4 )
		self.waitScene.btnReady:Enable(false)
		self.waitScene.btnPrevMap:Enable(true)
		self.waitScene.btnNextMap:Enable(true)
	end
	self.waitScene.imageHost:SetXYPos( PLAYER_SLOT_LOC[self.gameState.hostNo][1], PLAYER_SLOT_LOC[self.gameState.hostNo][2] )
end

function uppuRacingGameClient:OnNotiGameReady(server, msg)
	self.waitScene.btnReady:Enable(true)

	local n = 0
	for i, v in pairs (self.listUserState) do
		n = n + 1
	end
	if n > 1 then
		self.waitScene.btnPrevMap:Enable(false)
		self.waitScene.btnNextMap:Enable(false)
	end
end

function uppuRacingGameClient:OnChangeMap(server, msg)
	self.gameState:OnChangeMap(msg)
end

