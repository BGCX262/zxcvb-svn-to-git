require "go.app.App"
require "uppuRacingSoundObject"	-- should be required before the definition of inherited class from Client
require "go.service.idogame.LobbyClient"
require "go.service.idogame.ServiceError"
require "iDoLobby_LobbyMainScene"
require "iDoLobby_PopupScene"
require "iDoLobby_GameGuideScene01"
require "iDoLobby_Settings"

require "go.service.idogame.RoomListQuery"
require "go.service.idogame.PlayerListQuery"
require "go.service.idogame.ChattingChannelListQuery"
require "go.service.idogame.RankingListQuery"

class 'iDoLobby_LobbyClient' (LobbyClient)

local forwarding = App.GetProperty("forwarding")

function iDoLobby_LobbyClient:__init(parent, lobby, lobbyInfo) super(parent, lobby, lobbyInfo)
	-- to use all the sound objects defined in XML directly as a member of this client 
	self:SetupSoundObjects()

	-- record current time
	self.lastsec = App.GetCurrentSeconds()

	self.chatterList = {}
end

function iDoLobby_LobbyClient:OnReturn(exitArg)
	gameapp = nil

	self.popup:HideAllDialogs()

	self.lobbyScene.chatWindow:RemoveAllOutputTexts()
	self.lobbyScene.chatWindow:ClearInputText()	

	self:ActivateScene(self.lobbyScene)

	if self.lobby then
		-- room list query
		local roomCount = self.lobbyScene.roomListWnd:GetRoomCountPerPage()
		self.roomListQuery:Request(true, 0, roomCount)
	 
		-- player list query
		self.lobbyScene:RequestPlayerList(0)
	end
end

function iDoLobby_LobbyClient:OnFullScreen(fullScreen)
end

function iDoLobby_LobbyClient:OnEnter()
	self:SetWindowSize(760, 586)
	self:SetScreenPivot(760/2, 586/2)

	-- scene
	self.gameGuideScene = iDoLobby_GameGuideScene01()
	self.lobbyScene = iDoLobby_LobbyMainScene()

	-- 씬 상태 초기화
	self.lobbyScene.chatWindow:RemoveAllComboItems()
	self.lobbyScene.chatWindow:RemoveAllOutputTexts()
	self.lobbyScene.chatWindow:ClearInputText()
	self.lobbyScene.chkShowAvailRoom:SetChecked(false)
	self.lobbyScene.chkSortRoom:SetChecked(false)

	if not iDoLobby_Settings.skipGameGuide then
		local gameData = PlayerInfo.GetSelf():GetGameData()
		gameData:Load()
		if gameData.matchCount == 0 then
			-- 전적이 없을 경우, 게임가이드를 보여준다.
			self:ActivateScene(self.gameGuideScene)
		else
			-- 전적이 있을 경우, 바로 대기실 씬을 보여준다.
			self:ActivateScene(self.lobbyScene)
		end
		-- 게임가이드는 한번만 노출되면 충분하다. 
		iDoLobby_Settings.skipGameGuide = true
	else
		self:ActivateScene(self.lobbyScene)
	end

	self:InitializePopup()
 
	-- room list query start
	local roomCount = self.lobbyScene.roomListWnd:GetRoomCountPerPage()
	self.roomListQuery = RoomListQuery(lobbyapp)
	self.roomListQuery:AddListener(self, self.OnUpdateRoomList)
	self.roomListQuery.sort.roomNo = nil
	self.roomListQuery.sort.creationTime = ListQuery.ORDER_DESC
	self.roomListQuery.filter.gameState = nil
	self.roomListQuery:Request(true, 0, roomCount)

	-- player list query start
	self.playerListQuery = PlayerListQuery(lobbyapp)
	self.playerListQuery:AddListener(self, self.OnUpdatePlayerList)
	self.playerListQuery.sort.joinTime =  ListQuery.ORDER_DESC
	self.playerListQuery.filter.exclusiveUser = PlayerInfo.GetSelf().userkey

	self.lobbyScene:RequestPlayerList(0)

	-- set current chatting channel number
	local chattingChannelNo = PlayerInfo.GetSelf():GetChattingChannelNo()
	if chattingChannelNo then
		self.lobbyScene:SetCurChattingChannel("채팅" .. chattingChannelNo)
	end

	-- move to game automatically
	-- self.lobbyScene:OnbtnDirectStartMouseLClick()

	---------------------------------------------------------------------------
	-- forwarding에 의해 지정된 게임방 입장 시도
	---------------------------------------------------------------------------
	local roomNo = (forwarding and type(forwarding) == "table" and forwarding.roomNo)
	if roomNo then
		local password = forwarding.password
		local creationTime = forwarding.creationTime
		self:EnterRoomInvited(roomNo, password, creationTime)
		forwarding = nil	-- forwarding은 최초 한번만 실행
	end
end

function iDoLobby_LobbyClient:RequestChattingChannel()
	-- chattingchannel list query start
	self.chattingChannelListQuery = ChattingChannelListQuery(lobbyapp)
	self.chattingChannelListQuery:AddListener(self, self.OnUpdateChattingChannelList)
	self.chattingChannelListQuery:Request()
end

function iDoLobby_LobbyClient:OnExit(exitArg)
	lobbyapp = nil
end

function iDoLobby_LobbyClient:OnUpdateChattingChannelList(query, evtType, chattingChannelInfo)
	if evtType == ListQuery.EVENT_LIST then
		local ChannelList = {}
		local i = -1
		for ccInfo in query:Items() do
			i = i + 1

			local curUsers, maxUsers = ccInfo:GetPlayerCount()
			local chattingChannelString = "채팅" .. ccInfo:GetChattingChannelNo()
			self.lobbyScene.chatWindow:InsertComboItem(i , chattingChannelString .. " (" .. curUsers .. ")")
			if curUsers == maxUsers or chattingChannelString == self.lobbyScene.chatWindow.currentChattingChannelString then
				self.lobbyScene.chatWindow:SetDisabledComboItem(i, true)
			end
		end
	end
end

local function getLocation(pi)
	local roomNo = pi:GetLocation()
	local chnNo  = pi:GetChattingChannelNo()

	if roomNo == 0 then
		if chnNo then
			return "대기(채팅" .. chnNo .. ")"
		else
			return "대기"
		end
	else
		return string.format("%03d", roomNo)
	end
end


local maxIndex 
function iDoLobby_LobbyClient:OnUpdatePlayerList(query, evtType, playerInfo)
	local listWnd = self.lobbyScene.playerListWnd

	if evtType == ListQuery.EVENT_LIST then
		local start, count, total = query:GetRange()
		if not maxIndex then maxIndex = total end

		-- 방금 얻은 list 영역을 업데이트
		for i = start, start + count - 1 do
			local pi = query:GetItem(i)

			listWnd:SetItem(pi.nickname, 0, i+1)
			listWnd:SetItem(getLocation(pi), 1, i+1)
		end		

		-- 전체 목록 바깥 쪽에 남아있는 데이터 삭제
		for i = total, maxIndex - 1 do
			listWnd:RemoveRow(i+1)
		end
		if total > maxIndex then maxIndex = total end

	elseif evtType == ListQuery.EVENT_ADDED or evtType == ListQuery.EVENT_CHANGED or evtType == ListQuery.EVENT_REMOVED then
		local start, count, total = query:GetRange()

		-- 방금 얻은 list 영역을 업데이트
		for i = start, start + count - 1 do
			local pi = query:GetItem(i)

			listWnd:SetItem(pi.nickname, 0, i+1)
			listWnd:SetItem(getLocation(pi), 1, i+1)
		end		

		if evtType == ListQuery.EVENT_ADDED then
			maxIndex = maxIndex + 1
		end

		if evtType == ListQuery.EVENT_REMOVED then
			listWnd:RemoveRow(maxIndex)
			maxIndex = maxIndex - 1

			if start == 1 and count <= listWnd:GetVisibleRow() then
				listWnd:SetScrollPos(0)
			end
		end
	end
end

function iDoLobby_LobbyClient:OnUpdateRoomList(query, evtType, roomInfo)
	local roomList = self.lobbyScene.roomListWnd

	if evtType == ListQuery.EVENT_CHANGED then
		local roomNo = roomInfo:GetRoomNo()
		local curUsers, maxUsers = roomInfo:GetPlayerCount()

		roomList:SetRoomLocked(roomNo, roomInfo:HasPassword())
		roomList:SetRoomMaxPlayerCount(roomNo, maxUsers)
		roomList:SetRoomCurrentPlayerCount(roomNo, curUsers)

		if roomInfo:GetRoomState() == RoomClose or maxUsers == curUsers then
			roomList:SetRoomEnterable(roomNo, false)
		else
			roomList:SetRoomEnterable(roomNo, true)
		end

		roomList:SetStringProperty(UIConst.RoomNo, roomNo, string.format("%03d", roomNo))
		if roomInfo:HasPassword() then
			roomList:SetRoomTitle(roomNo, "    " .. roomInfo:GetName())
		else
			roomList:SetRoomTitle(roomNo, roomInfo:GetName())
		end
	else
		roomList:SetTotalRoomCount(self.roomListQuery.totalCount)
		roomList:RemoveAllRooms()
		for ri in query:Items() do
			local roomNo = ri:GetRoomNo()
			local curUsers, maxUsers = ri:GetPlayerCount()

			roomList:CreateRoom(roomNo)
			roomList:SetRoomLocked(roomNo, ri:HasPassword())
			roomList:SetRoomMaxPlayerCount(roomNo, maxUsers)
			roomList:SetRoomCurrentPlayerCount(roomNo, curUsers)

			if ri:GetRoomState() == RoomClose or maxUsers == curUsers then
				roomList:SetRoomEnterable(roomNo, false)
			else
				roomList:SetRoomEnterable(roomNo, true)
			end

			roomList:SetStringProperty(UIConst.RoomNo, roomNo, string.format("%03d", roomNo))
			if ri:HasPassword() then
				roomList:SetRoomTitle(roomNo, "    " .. ri:GetName())
			else
				roomList:SetRoomTitle(roomNo, ri:GetName())
			end
		end
	end
end

function iDoLobby_LobbyClient:OnReceiveChat(userkey, userid, nick, text)
	-- used for accuse
	self.chatterList[userkey] = {}
	self.chatterList[userkey].UserId = userid
	self.chatterList[userkey].NickName = nick

	local outputLine = nick .. ":" .. text
 	self.lobbyScene.chatWindow:AddOutputText(outputLine)
end

function iDoLobby_LobbyClient:OnDisconnected()
	local msgText = iDoLobby_Settings.errorNetworkUnreachable
	self.popup.dlgMessageBox.OkClick:AddHandler(self, self._OnConfirmExit)
	self.popup.dlgMessageBox:SetMessage(msgText[1], msgText[2])
	self.popup.dlgMessageBox:SetXYPos(220, 230)
	self.popup.dlgMessageBox:Show(true, true)		
end

function iDoLobby_LobbyClient:OnKicked(errCode)
	local msgText
	if errCode == ServiceError.SERVER_SHUTDOWN then
		msgText = iDoLobby_Settings.noticeShutdown
	elseif errCode == ServiceError.DUPLICATE_LOGIN then
		msgText = iDoLobby_Settings.noticeDuplicateLogin
	elseif errCode == ServiceError.BAD_USER then
		msgText = iDoLobby_Settings.noticeBadUser
	else
		msgText = iDoLobby_Settings.noticeKickedFromLobby
	end
	self.popup.dlgMessageBox.OkClick:AddHandler(self, self._OnConfirmExit)
	self.popup.dlgMessageBox:SetMessage(msgText[1], msgText[2])
	self.popup.dlgMessageBox:SetXYPos(220, 230)
	self.popup.dlgMessageBox:Show(true, true)		
end

function iDoLobby_LobbyClient:OnNetworkError(errCode)
	local msgText = iDoLobby_Settings.errorNetworkUnreachable
	self.popup.dlgMessageBox.OkClick:AddHandler(self, self._OnConfirmExit)
	self.popup.dlgMessageBox:SetMessage(msgText[1], msgText[2])
	self.popup.dlgMessageBox:SetXYPos(220, 230)
	self.popup.dlgMessageBox:Show(true, true)		
end

function iDoLobby_LobbyClient:_OnConfirmExit(sender, msg)
	self.popup.dlgMessageBox.OkClick:RemoveHandler(self, self._OnConfirmExit)
	self:Exit()
end

-- @param timerid number.
function iDoLobby_LobbyClient:OnTimer(timerid)
end

-- @param seconds number.
function iDoLobby_LobbyClient:Update(seconds)
	if self.currentScene then self.currentScene:Update(seconds - self.lastsec) end
	self.lastsec = seconds

	-- Update Room Count
	local roomCount = self:GetLobbyInfo():GetRoomCount()
	if roomCount and roomCount ~= self.roomCount then
		self.lobbyScene.txtRoomCount:SetText(roomCount.."개방")
		self.roomCount = roomCount
	end

	for i = 1, iDoLobby_Settings.maxInviteAcceptDialogCount do
		if self.popup.dlgInviteAcceptList[i]:IsShown() then
			self.popup.dlgInviteAcceptList[i]:Update()
		end
	end
end

function iDoLobby_LobbyClient:InitializePopup()
	self.popup = iDoLobby_PopupScene()

	-- CreateRoom Dialog
	self.lobbyScene.grpPopup:AddChild(self.popup.dlgCreateRoom)
	self.popup.dlgCreateRoom.OkClick:AddHandler(self, self.OnCreateOKClick)
	self.popup.dlgCreateRoom.InviteeSelectClick:AddHandler(self, function() self.popup.dlgInvite:Open(true) end)
	self.popup.dlgCreateRoom.ModifyClick:AddHandler(self, function() self.popup.dlgInvite:Open() end)
	self.popup.dlgCreateRoom:SetRoomTitleList(iDoLobby_Settings.defaultRoomTitles, iDoLobby_Settings.fontNormalText, iDoLobby_Settings.colorNormalText)

	-- Password Dialog
	self.lobbyScene.grpPopup:AddChild(self.popup.dlgPassword)
	self.popup.dlgPassword.OkClick:AddHandler(self, self.OnPasswordOKClick)

	-- Accuse Dialog
	self.popup.dlgAccuse.OkClick:AddHandler(self, self.OnAccuseOKClick)
	self.lobbyScene.grpPopup:AddChild(self.popup.dlgAccuse)

	-- AccuseResult Dialog
	self.lobbyScene.grpPopup:AddChild(self.popup.dlgAccuseResult)

	-- Invite Dialog
	self.lobbyScene.grpPopup:AddChild(self.popup.dlgInvite)
	self.popup.dlgInvite.OkClick:AddHandler    (self, self.OnUpdateInviteInfo)
	self.popup.dlgInvite.CancelClick:AddHandler(self, self.OnUpdateInviteInfo)
	self.popup.dlgInvite.CloseClick:AddHandler (self, self.OnUpdateInviteInfo)

	-- InviteAccept Dialog
	for i = 1, iDoLobby_Settings.maxInviteAcceptDialogCount do
		self.lobbyScene.grpPopup:AddChild(self.popup.dlgInviteAcceptList[i])
		self.popup.dlgInviteAcceptList[i].OkClick:AddHandler(self, self.OnInviteAcceptOKClick)
	end

	-- MessageBox Dialog
	self.lobbyScene.grpPopup:AddChild(self.popup.dlgMessageBox)
	self.popup.dlgMessageBox.OkClick:AddHandler(self, self.OnMessageBoxOKClick)

	-- Ranking Dialog
	self.lobbyScene.grpPopup:AddChild(self.popup.dlgRanking)
end

function iDoLobby_LobbyClient:ClearQueries()
	self.roomListQuery:Clear()
	self.playerListQuery:Clear()
end

function iDoLobby_LobbyClient:OnCreateOKClick(sender, msg)
	self.lobbyScene.btnDirectStart:Enable(false)
	self.lobbyScene.btnCreateRoom:Enable(false)
	self.lobbyScene.roomListWnd:Enable(false)

	local roomTitle = sender:GetRoomTitle()
	local password = sender:GetPassword()

	if sender:GetPasswordOption() == CreateRoomDialog.ROOM_WITH_NO_PASSWORD then
		password = nil
	end

	local result, gameClient = self:CreateRoom(iDoLobby_Settings.classGameClient, roomTitle, iDoLobby_Settings.timeoutCreateRoom, password)
	if result then
		self:ClearQueries()
		gameapp = gameClient

		-- random invite
		if sender.radInviteOption2:IsSelected() then 
			self:InviteRandom(gameapp:GetRoomInfo():GetRoomNo())
		elseif sender.radInviteOption3:IsSelected() then
			self:InviteSelectedPlayer(gameapp:GetRoomInfo():GetRoomNo())
		end
	else
		self.popup.dlgMessageBox:SetMessage("방 생성에 실패하였습니다.")
		self.popup.dlgMessageBox:SetXYPos(220, 230)
		self.popup.dlgMessageBox:Show(true)		
	end

	self.lobbyScene.btnDirectStart:Enable(true)
	self.lobbyScene.btnCreateRoom:Enable(true)
	self.lobbyScene.roomListWnd:Enable(true)
end

function iDoLobby_LobbyClient:OnInviteeSelectClick(sender, msg)
	self.popup.dlgInvite:OnOpen()
end

function iDoLobby_LobbyClient:OnInviteeModifyClick(sender, msg)
	self.popup.dlgInvite:OnOpen()
end

function iDoLobby_LobbyClient:OnPasswordOKClick(sender, msg)
	local roomNo = sender.roomNo
	local password = sender:GetPassword()

	local result, gameClient = self:EnterRoom(iDoLobby_Settings.classGameClient, roomNo, iDoLobby_Settings.timeoutEnterRoom, password)
	if result then
		self:ClearQueries()
		gameapp = gameClient
	else
		self.popup.dlgMessageBox:SetMessage("비밀번호가 정확하지 않습니다.", "방 입장에 실패하였습니다.")
		self.popup.dlgMessageBox:SetXYPos(220, 230)
		self.popup.dlgMessageBox:Show(true)
	end
end

function iDoLobby_LobbyClient:OnAccuseOKClick(sender, msg)
	if sender:GetSelectedUserKey() then
		if self:AccuseChatLog(sender:GetSelectedUserKey(), sender:GetCauseString(), sender.complain) then
			-- show result dlg
			self.popup.dlgAccuseResult:SetXYPos(225, 110)
			self.popup.dlgAccuseResult:Show(true)
		else
			self.popup.dlgMessageBox:SetMessage("신고 접수에 실패하였습니다.")
			self.popup.dlgMessageBox:SetXYPos(220, 230)
			self.popup.dlgMessageBox:Show(true)			
		end
	else
		self.popup.dlgMessageBox:SetMessage("신고할 대상을 정하지 않았습니다.")
		self.popup.dlgMessageBox:SetXYPos(220, 230)
		self.popup.dlgMessageBox:Show(true)	
	end
end

function iDoLobby_LobbyClient:OnUpdateInviteInfo(sender, msg)
	if self.popup.dlgCreateRoom:IsShown() then
		self.popup.dlgCreateRoom:SetSelectCount(#self.popup.dlgInvite:GetChosenList())
	end
end

function iDoLobby_LobbyClient:OnInvite(nick, roomNo, roomCreationTime, roomPassword)
	for i = 1, iDoLobby_Settings.maxInviteAcceptDialogCount do
		if not self.popup.dlgInviteAcceptList[i]:IsShown() then
			self.popup.dlgInviteAcceptList[i]:SetInviteInfo(nick, roomNo, roomCreationTime, roomPassword, App.GetCurrentSeconds())
			self.popup.dlgInviteAcceptList[i]:SetXYPos(220 + (i - 1) * 20, 230 + (i - 1) * 20)
			self.popup.dlgInviteAcceptList[i]:Show(true)
			return
		end
	end
end

function iDoLobby_LobbyClient:OnInviteAcceptOKClick(sender, msg)
	local roomNo = sender.roomNo 
	local roomCreationTime = sender.roomCreationTime
	local roomPassword = sender.roomPassword

	self:EnterRoomInvited(roomNo, roomPassword, roomCreationTime)
end

function iDoLobby_LobbyClient:OnMessageBoxOKClick(sender, msg)
end

function iDoLobby_LobbyClient:EnterRoomInvited(roomNo, password, roomCreationTime)
	local result, gameClient = self:EnterRoom(iDoLobby_Settings.classGameClient, roomNo, iDoLobby_Settings.timeoutEnterRoom, password)
	if result then
		self:ClearQueries()
		gameapp = gameClient
	else
		self.popup.dlgMessageBox:SetMessage(iDoLobby_Settings.noticeFailEnterInvited)
		self.popup.dlgMessageBox:SetXYPos(220, 230)
		self.popup.dlgMessageBox:Show(true)
	end
end

function iDoLobby_LobbyClient:InviteRandom(roomNo)
	self.invitePlayerListQuery = PlayerListQuery(lobbyapp)
	self.invitePlayerListQuery:AddListener(self, self.OnUpdateInvitePlayerList)
	self.invitePlayerListQuery.sort.joinTime =  ListQuery.ORDER_DESC
	self.invitePlayerListQuery.filter.isInRoom = false
	self.invitePlayerListQuery:Request(false, 0, 1)
	self.invitePlayerListQuery.roomNo = roomNo
end

function iDoLobby_LobbyClient:InviteSelectedPlayer(roomNo)
	for _, userkey in ipairs(self.popup.dlgInvite:GetChosenList()) do
		self:Invite(roomNo, userkey)
	end
end

function iDoLobby_LobbyClient:OnUpdateInvitePlayerList(query, evtType, playerInfo)
	if evtType == ListQuery.EVENT_LIST then
		for pi in query:Items() do
			if pi:GetLocation() == 0 then
				self:Invite(query.roomNo, pi.userkey)
				return
			end
		end
	end

	query:Clear()
end
