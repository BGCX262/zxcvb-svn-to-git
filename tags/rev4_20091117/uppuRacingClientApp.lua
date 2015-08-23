require "go.app.ClientApp"

require "uppuRacingScene"
require "Scene_WaitingRoom"

require "uppuRacingProtocol"

class 'uppuRacingClientApp' (ClientApp)

function uppuRacingClientApp:__init() super()
	math.randomseed(os.time())

	self.rtt = {}		-- players' rtt
	self.hostno = nil	-- player no of host

	self:LoadXML("Scene.xml", true)

	self.scene = uppuRacingScene(1)
	self.waitScene = Scene_WaitingRoom(5)
	self:ActivateScene(self.waitScene)
	
	self:SetupSoundObjects()

	-- record current time
	self.lastsec = self:GetCurrentSeconds()

	self:SetClearColor(UIConst.Black)	
	self:SetScreenPivot(self.scene.pivot.x,self.scene.pivot.y)

	-- set network event handler
	self:SetMsgHandler(Noti_EnterPlayer, self.OnNotiEnterPlayer)
	self:SetMsgHandler(Noti_LeavePlayer, self.OnNotiLeavePlayer)
	self:SetMsgHandler(Object_Create, self.OnObjectCreate)
	self:SetMsgHandler(Object_Lock, self.OnObjectLock)
	self:SetMsgHandler(Object_Sync, self.OnObjectSync)
	self:SetMsgHandler(Object_Delete, self.OnObjectDelete)
	self:SetMsgHandler(RTT_Check, self.OnRTTCheck)
	self:SetMsgHandler(RTT_Broadcast, self.OnRTTBroadcast)

	self:SetMsgHandler(Noti_PlayerReady, self.OnNotiPlayerReady )
	self:SetMsgHandler(Noti_ChangeCarType, self.OnChangeCarType )
	self:SetMsgHandler(Noti_GameStart, self.OnNotiGameStart )
	self:SetMsgHandler(Noti_ReadyGo, self.OnReadyGo)
	self:SetMsgHandler(Game_Result, self.OnGameResult)
	self:SetMsgHandler(Game_CutFinishResult, self.OnGameCutFinishResult)

	self:SetMsgHandler(Noti_ChangeRoomState, self.OnNotiChangeRoomState)
	self:SetMsgHandler(Noti_ChangeGameState, self.OnNotiChangeGameState)
	self:SetMsgHandler(Noti_ChangeUserState, self.OnNotiChangeUserState)

	-- FSM
	self.roomState = RoomState( self )
	self.gameState = GameState( self )
	self.listUserState = { }
end

function uppuRacingClientApp:SendUnreliableToServer(msg)
	if self.proxy == nil then
		print("Error! Server has not connected.")
		return
	end
	self.proxy:SendUnreliable(self.serverProxy, msg)
end

---------------------------------------------------------
-- Game Handler
---------------------------------------------------------
function uppuRacingClientApp:OnEnterGame(player)
	self.playerNo = player.no
	self.sndEnterRoom:PlaySound(false)
end

function uppuRacingClientApp:OnLeaveGame(player)

end

function uppuRacingClientApp:OnDisconnected()

end

function uppuRacingClientApp:OnEnterPlayer(player)
	self.sndEnterPlayer:PlaySound(false)
end

function uppuRacingClientApp:OnLeavePlayer(player)
	--self.scene:DeleteCar(player.no)
	self.sndLeavePlayer:PlaySound(false)
end

function uppuRacingClientApp:OnTimer(timerid)
	if timerid == TIMER_GAMERESULT then
		self.roomState:ChangeState(self.roomState.Open)
		self.gameState:ChangeState(self.gameState.Wait)
		self.listUserState[self.playerNo]:ChangeState(self.listUserState[self.playerNo].Wait)

		for userNo, userState in pairs(self.listUserState) do
			if userState then
				userState:OnUserUnready()
			end
		end

		self.scene:DeleteMap()

		self:ActivateScene(self.waitScene)
		Scene.latestScene = self.waitScene

		self:KillTimer(TIMER_GAMERESULT)
	end
end

function uppuRacingClientApp:Update(seconds)
	if self.currentScene then
		self.currentScene:Update(seconds - self.lastsec)
		self.lastsec = seconds
	end
end

---------------------------------------------------------
-- Network Handler
---------------------------------------------------------
function uppuRacingClientApp:OnNotiEnterPlayer(server, msg)
	local playerNo = msg:GetValue(Noti_EnterPlayer.key.no)
	local playerNick = msg:GetValue(Noti_EnterPlayer.key.nick)
	local playerAge = msg:GetValue(Noti_EnterPlayer.key.age)
	local playerGender = msg:GetValue(Noti_EnterPlayer.key.gender)
	self.hostno = msg:GetValue(Noti_EnterPlayer.key.hostno)

	if self.listUserState[playerNo] == nil then
		self.listUserState[playerNo] = UserState( self, playerNo, isPlayer )
		self.listUserState[playerNo]:ChangeState( self.listUserState[playerNo].Join )
	end
	self.listUserState[playerNo].nickname = playerNick

	print(string.format("[ClientApp:OnNotiEnterPlayer] User = no[%d] nick[%s] age[%d] gender[%s]", playerNo, playerNick, playerAge, playerGender))
end

function uppuRacingClientApp:OnNotiLeavePlayer(server, msg)
	
end

function uppuRacingClientApp:OnNotiPlayerReady(server, msg)
	local userNo = msg:GetValue( Noti_PlayerReady.key.no )
	self.listUserState[userNo]:OnUserReady(msg)
end

function uppuRacingClientApp:OnChangeCarType(server, msg)
	local userNo = msg:GetValue( Noti_ChangeCarType.key.no )
	self.listUserState[userNo]:OnChangeCarType(msg)
end

function uppuRacingClientApp:OnNotiGameStart( sender, msg )
	print("game start!")

	-- set racing scene
	self:ActivateScene( self.scene )
	Scene.latestScene = self.scene

	-- todo: create selected map
	self.scene:CreateMap(self.playerNo)

	-- noti to server that map-loading is completed
	local msg = Message(Noti_LoadingCompleted)
	self:SendToServer(msg)

	for playerNo, playerState in pairs( self.listUserState ) do
		if self.playerNo == playerNo then
			-- my info
			self.scene:CreateMasterCar( playerState.nickname, playerNo, CONTROL_USER, Vector2(300 + 100*playerNo, 150) )
		else
			-- their info
			self.scene:CreateSlaveCar( playerState.nickname, playerNo, CONTROL_NETWORK, Vector2(300 + 100*playerNo, 150) )
		end
	end
end

function uppuRacingClientApp:OnReadyGo(server, msg)
	self.scene:StartRacing()
end

function uppuRacingClientApp:OnGameResult(server, msg)
	self:SetTimer(TIMER_GAMERESULT, 3)
end

function uppuRacingClientApp:OnGameCutFinishResult(server, msg)
	local no = msg:GetValue(Game_CutFinishResult.key.no)
	local rank = msg:GetValue(Game_CutFinishResult.key.rank)

	-- show rank for me
	if no == self.playerNo then
		self.scene:PlayRank(rank)
	end
end

function uppuRacingClientApp:OnNotiChangeRoomState(server, msg)
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

function uppuRacingClientApp:OnNotiChangeGameState(server, msg)
	local stateFlag = msg:GetValue( Noti_ChangeGameState.key.stateFlag )
	if stateFlag == GameState.Wait then
		self.gameState:ChangeState( self.gameState.Wait )
	elseif stateFlag == GameState.Play then
		self.gameState:ChangeState( self.gameState.Play )
	end
end

function uppuRacingClientApp:OnNotiChangeUserState(server, msg)
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

function uppuRacingClientApp:OnObjectCreate(server, msg)
	--self.scene:CreateCar(
end

function uppuRacingClientApp:OnObjectLock(server, msg)
	local owner = msg:GetValue(Object_Lock.key.no)
	local oid = msg:GetValue(Object_Lock.key.oid)

	self.scene:ObjectLock(owner, oid)	
end

function uppuRacingClientApp:OnObjectSync(server, msg)
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

function uppuRacingClientApp:OnRTTCheck(server, msg)
	-- echo back
	self:SendUnreliableToServer(msg)
end

function uppuRacingClientApp:OnRTTBroadcast(server, msg)
	local rtt1 = msg:GetValue(RTT_Broadcast.key.rtt1)
	local rtt2 = msg:GetValue(RTT_Broadcast.key.rtt2)
	local rtt3 = msg:GetValue(RTT_Broadcast.key.rtt3)
	local rtt4 = msg:GetValue(RTT_Broadcast.key.rtt4)

	self.rtt[1] = rtt1
	self.rtt[2] = rtt2	
	self.rtt[3] = rtt3	
	self.rtt[4] = rtt4	
end

require "uppuRacingSoundObject"