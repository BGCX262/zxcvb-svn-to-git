require "go.ui.Scene"

-- load iDoLobby setting
require "iDoLobby_Settings"

class 'iDoLobby_LobbyMainScene' (Scene)

function iDoLobby_LobbyMainScene:__init() super()
	self:SetupUIObjects()

	self.txtGameTitle:SetText(App.GetTitle())

	self.imgSep:SetXPos(self.txtGameTitle:GetXPos() + self.txtGameTitle:GetWidth() + 7)
	self.txtRoomCount:SetText("")		-- show blank for uncertain information
	self.txtRoomCount:SetXPos(self.imgSep:GetXPos() + self.imgSep:GetWidth() + 7)

	-- chatting window
	self.chatWindow:SetComboHotColor(iDoLobby_Settings.colorSelectedText, iDoLobby_Settings.colorSelectedBG)
	self.chatWindow:SetOutputLineGap(4)

	--self:SetMsgHandler(Evt_KeyboardDown, self.OnKeyDown)
	self:SetMsgHandler(iDoLobby_Settings.Evt_LoadLobbyList, self.OnLoadLobbyList)

	self.btnDirectStart.MouseLClick:AddHandler(self, self.OnbtnDirectStartMouseLClick)
	self.btnCreateRoom.MouseLClick:AddHandler(self, self.OnroomListWndRoomCreateClicked)
	self.btnSingleGame.MouseLClick:AddHandler(self, self.OnbtnSingleGameMouseLClick)
	self.btnRanking.MouseLClick:AddHandler(self, self.OnbtnRankingMouseLClick)
	self.btnChannelExit.MouseLClick:AddHandler(self, self.OnbtnChannelExitMouseLClick)
	self.chkSortRoom.MouseLClick:AddHandler(self, self.OnchkSortRoomMouseLClick)
	self.chkShowAvailRoom.MouseLClick:AddHandler(self, self.OnchkShowAvailRoomMouseLClick)
	self.playerListWnd.ScrollFinished:AddHandler(self, self.OnplayerListWndScrollFinished)
	self.playerListWnd.ScrollBarChanged:AddHandler(self, self.OnplayerListWndScrollBarChanged)
	self.roomListWnd.RoomCreateClicked:AddHandler(self, self.OnroomListWndRoomCreateClicked)
	self.roomListWnd.RoomEnterClicked:AddHandler(self, self.OnroomListWndRoomEnterClicked)
	self.roomListWnd.ScrollFinished:AddHandler(self, self.OnroomListWndScrollFinished)
	self.chkChattingTitle.MouseLClick:AddHandler(self, self.OnchkChattingTitleMouseLClick)
	self.chatWindow.CopyUrlButtonClicked:AddHandler(self, self.OnbtnUrlCopyMouseLClick)
	self.chatWindow.ReportButtonClicked:AddHandler(self, self.OnbtnAccuseMouseLClick)
	self.chatWindow.ChannelClicked:AddHandler(self, self.OnChattingChannelMouseLClick)
	self.chatWindow.ChannelChanged:AddHandler(self, self.OnChattingChannelChanged)
	self.chatWindow.KeyboardDown:AddHandler(self, self.OnchatWindowKeyboardDown)

	-----------------------
	--  사용자목록 헤더  --
	-----------------------
	local headerColor   = MakeColorKey(255, 161, 161, 161)
	local headerFont	= FontInfo("돋움", 11, false)
	self.playerListWnd:SetHeaderFont(headerFont)
	self.playerListWnd:SetColumnLabelColor(headerColor)
	self.playerListWnd:SetColumnBorderColor(headerColor)
	self.playerListWnd:SetColumnBorderWidth(1)
	self.playerListWnd:SetColumnLabel("별명", 0)
	self.playerListWnd:SetColumnLabel("위치", 1)
	self.playerListWnd:AlignColumn(1, UIConst.PlayerListCenter)

	-----------------------
	-- SingleGame Button --
	-----------------------
	if iDoLobby_Settings.supportSingleGame then
		self.btnSingleGame:Show(true)
	else
		self.btnSingleGame:Show(false)

		-- align btnCreateRoom/DirectStart to right (btnRanking)
		self.btnCreateRoom:SetXPos(self.btnRanking:GetXPos() - (self.btnCreateRoom:GetWidth() + 4))
		self.btnDirectStart:SetXPos(self.btnCreateRoom:GetXPos() - (self.btnDirectStart:GetWidth() + 4))
	end

	-----------------------
	-- LobbyList ComboBox
	-----------------------
	-- it will be enabled later after lobby-list is loaded properly
	self.cmbLobbyList:Enable(false)		
	-- position
	self.cmbLobbyList:SetXPos(self.txtRoomCount:GetXPos() + 45 + 6)		-- reserve space for 3-digit number of rooms
	self.txtLobbyName:SetXPos(self.cmbLobbyList:GetXPos() + 5)
	-- font and colors
	self.cmbLobbyList:SetFont(iDoLobby_Settings.fontNormalText)
	self.cmbLobbyList:SetTextColor(iDoLobby_Settings.colorNormalText)
	self.cmbLobbyList:SetHotColor(iDoLobby_Settings.colorSelectedText, iDoLobby_Settings.colorSelectedBG)
	self.cmbLobbyList:SetDisabledColor(iDoLobby_Settings.colorDisabledText)
	-- event handlers
	self.cmbLobbyList.MouseLClick:AddHandler(self, self.OncmbLobbyListMouseLClick)
	self.cmbLobbyList.ListViewSelChanged:AddHandler(self, self.OncmbLobbyListSelChanged)
	-- set current lobby name
	self.currentLobbyNo   = lobbyapp:GetLobbyInfo():GetLobbyNo()
	self.currentLobbyName = lobbyapp:GetLobbyInfo():GetName()
	self.txtLobbyName:SetFont(iDoLobby_Settings.fontNormalText)
	self.txtLobbyName:SetTextColor(iDoLobby_Settings.colorNormalText)
	self.txtLobbyName:SetText(self.currentLobbyName)

end

-- @param msg class Message.
function iDoLobby_LobbyMainScene:OnKeyDown(msg)
	--local keyValue = msg:GetValue(Evt_KeyboardDown.key.Value)
	--print(keyValue)
end

function iDoLobby_LobbyMainScene:OnChatKeyDown(sender, msg)
	local keyValue = msg:GetValue(Evt_KeyboardDown.key.Value)	
	if keyValue == 13 and self.editChat:GetTextLength() > 0 then
		lobbyapp:SendChat(self.editChat:GetText())

		self.editChat:ClearEdit()
	end
end

function iDoLobby_LobbyMainScene:OnchkSortRoomMouseLClick(sender, msg)
	-- Add event hanlder code here
	if sender:IsChecked() then
		-- 번호순보기
		local count = self.roomListWnd:GetRoomCountPerPage()
		lobbyapp.roomListQuery.sort.roomNo = ListQuery.ORDER_ASC
		lobbyapp.roomListQuery.sort.creationTime = nil
		lobbyapp.roomListQuery:Request(true, 0, count)
	else
		-- 최근순보기
		local count = self.roomListWnd:GetRoomCountPerPage()
		lobbyapp.roomListQuery.sort.roomNo = nil
		lobbyapp.roomListQuery.sort.creationTime = ListQuery.ORDER_DESC
		lobbyapp.roomListQuery:Request(true, 0, count)
	end
end

function iDoLobby_LobbyMainScene:OnchkShowAvailRoomMouseLClick(sender, msg)
	-- Add event hanlder code here
	if sender:IsChecked() then
		-- 대기방보기
		local count = self.roomListWnd:GetRoomCountPerPage()
		lobbyapp.roomListQuery.filter.isAdmittable = true
		lobbyapp.roomListQuery:Request(true, 0, count)
	else
		-- 전체방보기
		local count = self.roomListWnd:GetRoomCountPerPage()
		lobbyapp.roomListQuery.filter.isAdmittable = nil
		lobbyapp.roomListQuery:Request(true, 0, count)
	end
end

function iDoLobby_LobbyMainScene:OnbtnDirectStartMouseLClick(sender, msg)
	self.btnDirectStart:Enable(false)
	self.btnCreateRoom:Enable(false)
	self.roomListWnd:Enable(false)

	local result, gameClient = lobbyapp:EnterRoomRandom(iDoLobby_Settings.classGameClient, iDoLobby_Settings.timeoutEnterRoom)
	if result then
		lobbyapp:ClearQueries()
		gameapp = gameClient
	else
		local idxRoomTitle = math.random(#iDoLobby_Settings.defaultRoomTitles)
		result, gameClient = lobbyapp:CreateRoom(iDoLobby_Settings.classGameClient, 
												iDoLobby_Settings.defaultRoomTitles[idxRoomTitle], 
												iDoLobby_Settings.timeoutCreateRoom)
		if result then
			lobbyapp:ClearQueries()
			gameapp = gameClient
		else
			lobbyapp.popup.dlgMessageBox:SetMessage("바로 입장에 실패하였습니다.", "다시 시도하여 주시기 바랍니다.")
			lobbyapp.popup.dlgMessageBox:SetXYPos(220, 230)
			lobbyapp.popup.dlgMessageBox:Show(true)
		end
	end

	self.btnDirectStart:Enable(true)
	self.btnCreateRoom:Enable(true)
	self.roomListWnd:Enable(true)
end

function iDoLobby_LobbyMainScene:OnroomListWndRoomCreateClicked(sender, msg)
	if not lobbyapp.popup.dlgCreateRoom:IsShown() then
		lobbyapp.popup.dlgCreateRoom:SetXYPos(225, 100)
		lobbyapp.popup.dlgCreateRoom:Show(true)
	end
end

function iDoLobby_LobbyMainScene:OnroomListWndRoomEnterClicked(sender, msg)
	self.btnDirectStart:Enable(false)
	self.btnCreateRoom:Enable(false)
	self.roomListWnd:Enable(false)

	local roomNo = msg:GetValue(Evt_RoomEnterClicked.key.RoomNo)
	if self.roomListWnd:IsRoomLocked(roomNo) then
		if not lobbyapp.popup.dlgPassword:IsShown() then
			lobbyapp.popup.dlgPassword:SetXYPos(220, 230)
			lobbyapp.popup.dlgPassword:Show(true)

			lobbyapp.popup.dlgPassword.roomNo = roomNo
		end
	else
		local result, gameClient = lobbyapp:EnterRoom(iDoLobby_Settings.classGameClient, roomNo, iDoLobby_Settings.timeoutEnterRoom)
		if result then
			lobbyapp:ClearQueries()
			gameapp = gameClient
		else
			local msgText
			if gameClient == ServiceError.EXCEED_CAPACITY then
				msgText = iDoLobby_Settings.errorExceedRoomCapacity
			else
				msgText = iDoLobby_Settings.errorUnknownFailure
			end

			lobbyapp.popup.dlgMessageBox:SetMessage(msgText[1], msgText[2])
			lobbyapp.popup.dlgMessageBox:SetXYPos(220, 230)
			lobbyapp.popup.dlgMessageBox.btnMessageBoxExit:Show(true)
			lobbyapp.popup.dlgMessageBox:Show(true, true)	
		end
	end

	self.btnDirectStart:Enable(true)
	self.btnCreateRoom:Enable(true)
	self.roomListWnd:Enable(true)
end
	
-----------------------
--  사용자목록 헤더  --
-----------------------
local viewTop		-- 보여지는 부분의 top row index (0부터 시작)
local viewSize		-- 보여지는 부분의 row수
local listMargin	-- 보여지는 부분 위 아래로 여유분 row수
local listTop		-- 목록을 요청하는 top row index (0부터 시작)

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

function iDoLobby_LobbyMainScene:OnplayerListWndScrollFinished(sender, msg)
	-- not used
end

function iDoLobby_LobbyMainScene:OnplayerListWndScrollBarChanged(sender, msg)
	local topIndex = self.playerListWnd:GetTopIndex()
	self:RequestPlayerList(topIndex)
end

function iDoLobby_LobbyMainScene:RequestPlayerList(topIndex, mustUpdate)
	if not viewSize or mustUpdate then 
		viewSize    = self.playerListWnd:GetVisibleRow()
		listMargin = math.floor(viewSize / 2)
	end

	-- 스크롤되어 top index가 list margin 만큼 이동하지 않았을 경우
	if not mustUpdate and viewTop and math.abs(viewTop - topIndex) < listMargin then return end

	-- 처음으로 list를 얻었거나, 최상단으로 스크롤이 이동했을 때 리셋
	if topIndex == 0 then 
		self.playerListWnd:RemoveAllRow()
		self.playerListWnd:SetScrollPos(0)

		-- self info will be located on top
		local pi = PlayerInfo.GetSelf()
		self.playerListWnd:SetItem(pi.nickname, 0, 0)
		self.playerListWnd:SetItem(getLocation(pi), 1, 0)
	end

	-- 새로운 query 생성
	viewTop = topIndex
	listTop = topIndex - listMargin

	listSize = viewSize + listMargin
	if listTop < 0 then 
		listTop  = 0 
		listSize = listSize + viewTop
	else
		listSize = listSize + listMargin
	end

	lobbyapp.playerListQuery:Request(true, listTop, listSize)
end

function iDoLobby_LobbyMainScene:OnroomListWndScrollFinished(sender, msg)
	local topIndex = msg:GetValue(Evt_ScrollFinished.key.TopIndex)
	local length = msg:GetValue(Evt_ScrollFinished.key.Length)

	-- topIndex부터 length만큼 request를 보낸다.
	lobbyapp.roomListQuery:Request(true, topIndex, length)
end

function iDoLobby_LobbyMainScene:OnbtnUrlCopyMouseLClick(sender, msg)
	local propertyList = { forwarding={} }
	local lobbyNo = lobbyapp:GetLobbyInfo():GetLobbyNo() 
	propertyList.forwarding.lobbyNo = lobbyNo

	local url = App.MakeURL(propertyList)
	if url and __main:SetClipBoardString(url) then
		lobbyapp.popup.dlgMessageBox:SetMessage(iDoLobby_Settings.noticeGameURLCopied)
	else
		lobbyapp.popup.dlgMessageBox:SetMessage(iDoLobby_Settings.noticeGameURLError)
	end
	lobbyapp.popup.dlgMessageBox:SetXYPos(220, 230)
	lobbyapp.popup.dlgMessageBox:Show(true)
end

function iDoLobby_LobbyMainScene:OnbtnSingleGameMouseLClick(sender, msg)
	lobbyapp.popup.dlgMessageBox:SetMessage("아직 적용되지 않은 기능입니다.")
	lobbyapp.popup.dlgMessageBox:SetXYPos(220, 230)
	lobbyapp.popup.dlgMessageBox:Show(true)
end

function iDoLobby_LobbyMainScene:OnbtnRankingMouseLClick(sender, msg)
	lobbyapp.popup.dlgRanking:SetXYPos(220, 80)
	lobbyapp.popup.dlgRanking:Show(true)
end

function iDoLobby_LobbyMainScene:OnbtnAccuseMouseLClick(sender, msg)
	local existChatter = false
	for userKey, ci in pairs(lobbyapp.chatterList) do
		if userKey ~= PlayerInfo.GetSelf().userkey then
			existChatter = true
			break
		end
	end
	 
	if existChatter then
		lobbyapp.popup.dlgAccuse:Reset()
		lobbyapp.popup.dlgAccuse:SetAccuserNick(PlayerInfo.GetSelf().nickname)
		lobbyapp.popup.dlgAccuse:SetXYPos(225, 35)
		lobbyapp.popup.dlgAccuse:Show(true)
	else
		lobbyapp.popup.dlgMessageBox:SetMessage("신고하실 대화 내용이 없습니다.")
		lobbyapp.popup.dlgMessageBox:SetXYPos(220, 230)
		lobbyapp.popup.dlgMessageBox:Show(true)	
	end
end

function iDoLobby_LobbyMainScene:OnbtnChannelExitMouseLClick(sender, msg)
	lobbyapp:Exit()
end

function iDoLobby_LobbyMainScene:OnchatWindowKeyboardDown(sender, msg)
	local keyValue = msg:GetValue(Evt_KeyboardDown.key.Value)
	if keyValue == UIConst.KeyEnter and self.chatWindow:GetInputTextLength() > 0 then
		lobbyapp:SendChat(self.chatWindow:GetInputText())
		self.chatWindow:ClearInputText()

		if self.chkChattingTitle:IsChecked() then
			self:HideChattingWindow(false)
			self.chkChattingTitle:SetChecked(false)
		end
	end
end

function iDoLobby_LobbyMainScene:HideChattingWindow(hide)
	if hide then
		-- Hide
		self.chatWindow:EnableClip(true)
		self.chkChattingTitle:SetYPos(421)
		self.txtChattingChannel:SetYPos(430)
		self.playerListWnd:SetHeight(343)
	else 
		-- Show
		self.chatWindow:EnableClip(false)
		self.chkChattingTitle:SetYPos(251)
		self.txtChattingChannel:SetYPos(260)
		self.playerListWnd:SetHeight(173)
	end

	-- player List Query
	self:RequestPlayerList(0, true)
end

function iDoLobby_LobbyMainScene:OnchkChattingTitleMouseLClick(sender, msg)
	self:HideChattingWindow(sender:IsChecked())
end

function iDoLobby_LobbyMainScene:SetCurChattingChannel(chattingChannel)
	self.txtChattingChannel:SetText(chattingChannel)
	self.chatWindow:SetSelectedComboString(chattingChannel)
	self.chatWindow.currentChattingChannelString = chattingChannel
end

function iDoLobby_LobbyMainScene:OnChattingChannelChanged(sender, msg)
	local selIndex = self.chatWindow:GetSelectedComboItem()
	local selChannelNo = lobbyapp.chattingChannelListQuery:GetItem(selIndex):GetChattingChannelNo()
	if lobbyapp:ChangeChattingChannel(selChannelNo) then
		self.chatWindow:RemoveAllComboItems()

		self:SetCurChattingChannel("채팅" .. selChannelNo)

		local noticeMessage = "채팅" .. selChannelNo .. "로 변경되었습니다."
		self.chatWindow:AddOutputText(noticeMessage, iDoLobby_Settings.colorNoticeText)

		local pi = PlayerInfo.GetSelf()
		local playerList = self.playerListWnd
		if playerList:GetScrollPos() == 0 then
			location = "대기(채팅" .. selChannelNo .. ")"
			playerList:SetItem(location, 1, 0)	
		end
	end
end

function iDoLobby_LobbyMainScene:OnChattingChannelMouseLClick(sender, msg)
	if self.chatWindow:GetComboItemCount() == 0 then
		lobbyapp:RequestChattingChannel()
	end
end

function iDoLobby_LobbyMainScene:Update(elapsed)
	self:LoadLobbyList()
end


-----------------------
-- LobbyList ComboBox
-----------------------
function iDoLobby_LobbyMainScene:OncmbLobbyListMouseLClick(sender, msg)
	self.cmbLobbyList:Enable(false)	
	self:UpdateLobbyList()
	self.cmbLobbyList:Enable(true)	
end

function iDoLobby_LobbyMainScene:LoadLobbyList()
	if self.cmbLobbyList.listIndexes then return end

	local msg = Message(iDoLobby_Settings.Evt_LoadLobbyList)		-- Update의 busy현상을 줄이기 위해, 새로운 msg를 생성하여 처리
	lobbyapp:SendToScene(msg)
end

function iDoLobby_LobbyMainScene:OnLoadLobbyList(msg)
	self.cmbLobbyList:RemoveAllItems()
	self.cmbLobbyList.listIndexes = {}			-- lobbyNo => listIndex

	local index = 0
	for li in LobbyList.LobbyInfos() do
		local lobbyNo = li:GetLobbyNo()
		if self.currentLobbyNo ~= lobbyNo then						-- if not current lobby
			self.cmbLobbyList:InsertLineAt(index, li:GetName())		-- add to combo list
			self.cmbLobbyList.listIndexes[lobbyNo] = index
			index = index + 1
		end
	end	
	self.cmbLobbyList:Enable(true)	
end

local LOBBYLIST_UPDATE_TOLERANCE = 2			-- 로비목록에 대한 실시간 데이터를 요청하는 최소 간격
function iDoLobby_LobbyMainScene:UpdateLobbyList()
	if self.cmbLobbyList.lastUpdate and (App.GetCurrentSeconds() - self.cmbLobbyList.lastUpdate < LOBBYLIST_UPDATE_TOLERANCE) then 
		return 
	end
	self.cmbLobbyList.lastUpdate = App.GetCurrentSeconds()

	for li in LobbyList.LobbyInfos() do
		local index = self.cmbLobbyList.listIndexes[li:GetLobbyNo()]
		if index then	
			-- check whether lobby is full or not
			local cur, max = li:GetPlayerCount()
			self.cmbLobbyList:SetDisabledItem(index, (cur >= max))
		end
	end	
end

function iDoLobby_LobbyMainScene:OncmbLobbyListSelChanged(sender, msg)
	self.cmbLobbyList:Enable(false)		-- at first, disable button
	self.txtLobbyName:SetText("")		-- erase lobbyName immediately

	local target
	for lobbyNo, index in pairs(self.cmbLobbyList.listIndexes) do
		if index == self.cmbLobbyList:GetSelectedItem() then
			target = lobbyNo
		end
	end

	if target then
		self.cmbLobbyList:RemoveAllItems()
		lobbyapp:Exit(target)
	end
end

require "iDoLobby_LobbyMainSceneUIObject"