require "go.ui.control.Group"
require "iDoLobby_PopupMultiEventHandler"

class 'RankingDialog' (Group)

-- Constructor
function RankingDialog:__init(popupScene, id) super(id)
	self:CloneControls(popupScene)

	self.userCount = 0
	self.userList = {}

	-- Variables
	self.dragInfo = {btnDown = false, diffX = 0, diffY = 0}

	-- Add internal event handlers
	self.rankingBg.MouseDown:AddHandler(self, self.OnBgMouseDown)
	self.rankingBg.MouseMove:AddHandler(self, self.OnBgMouseMove)
	self.rankingBg.MouseUp:AddHandler(self, self.OnBgMouseUp)
	self.btnRankingExit.MouseLClick:AddHandler(self, self.OnExit)
	self.btnRankingClose.MouseLClick:AddHandler(self, self.OnExit)

	self.imgDayRanking.MouseLClick:AddHandler(self, self.OnImgDownDayRanking)
	self.imgTotalRanking.MouseLClick:AddHandler(self, self.OnImgDownTotalRanking)
	self.btnMyRanking.MouseLClick:AddHandler(self, self.OnBtnDownMyRanking)
	self.btnNextPage.MouseLClick:AddHandler(self, self.OnBtnDownNextPage)
	self.btnPrevPage.MouseLClick:AddHandler(self, self.OnBtnDownPrevPage)

	self.cbRankingList:SetFont(iDoLobby_Settings.fontNormalText)
	self.cbRankingList:SetTextColor(iDoLobby_Settings.colorNormalText)
	self.cbRankingList:SetHotColor(iDoLobby_Settings.colorNormalText, iDoLobby_Settings.colorSelectedBG)
	self.cbRankingList:SetDisabledColor(iDoLobby_Settings.colorNormalText)
	self.cbRankingList:AddLine("승점 랭킹", iDoLobby_Settings.colorNormalText, iDoLobby_Settings.fontNormalText)
	self.cbRankingList:SetSelectedItem(0)
end

-- Internal handlers
function RankingDialog:OnBgMouseDown(sender, msg)
	self.dragInfo.btnDown = true
	self.dragInfo.diffX = msg:GetValue(Evt_MouseDown.key.X)
	self.dragInfo.diffY = msg:GetValue(Evt_MouseDown.key.Y)
	self:BringToTop()
end

function RankingDialog:OnBgMouseMove(sender, msg)
	if self.dragInfo.btnDown == false then return end

	local x = self:GetAbsXPos() + msg:GetValue(Evt_MouseMove.key.X)
	local y = self:GetAbsYPos() + msg:GetValue(Evt_MouseMove.key.Y)
	self:SetAbsXYPos(x - self.dragInfo.diffX, y - self.dragInfo.diffY)
end

function RankingDialog:OnBgMouseUp(sender, msg)
	self.dragInfo.btnDown = false

	local x, y = self:GetAbsXYPos()
	local windowSize = lobbyapp:GetWindowSize()

	if x < 0 then
		self:SetAbsXPos(0)
	elseif x + self.rankingBg:GetWidth() > windowSize.x then
		self:SetAbsXPos(windowSize.x - self.rankingBg:GetWidth())
	end

	if y < 0 then
		self:SetAbsYPos(0)
	elseif y + self.rankingBg:GetHeight() > windowSize.y then
		self:SetAbsYPos(windowSize.y - self.rankingBg:GetHeight())
	end
end

function RankingDialog:OnExit(sender, msg)
	self:Show(false)
end

function RankingDialog:OnImgDownDayRanking(sender, msg)
	if self.imgDayRanking:GetImageIndex() == 0 then
		return
	end

	self.imgDayRanking:SetImageIndex(0)
	self.imgTotalRanking:SetImageIndex(3)

	self.rankingListQuery.filter.period = RankingListQuery.PERIOD_DAILY
	if self.btnPrevPage:IsEnabled() and self.btnNextPage:IsEnabled() then
		self.rankingListQuery:Request(true, 5, 10)
	elseif self.btnPrevPage:IsEnabled() then
		self.rankingListQuery:Request(true, 11, 10)
	else
		self.rankingListQuery:Request(true, 1, 10)
	end
end

function RankingDialog:OnImgDownTotalRanking(sender, msg)
	if self.imgTotalRanking:GetImageIndex() == 0 then
		return
	end

	self.imgDayRanking:SetImageIndex(3)
	self.imgTotalRanking:SetImageIndex(0)

	self.rankingListQuery.filter.period = RankingListQuery.PERIOD_TOTALLY
	if self.btnPrevPage:IsEnabled() and self.btnNextPage:IsEnabled() then
		self.rankingListQuery:Request(true, 5, 10)
	elseif self.btnPrevPage:IsEnabled() then
		self.rankingListQuery:Request(true, 11, 10)
	else
		self.rankingListQuery:Request(true, 1, 10)
	end
end

function RankingDialog:OnBtnDownMyRanking(sender, msg)
	self.btnPrevPage:Enable(true)
	self.btnNextPage:Enable(true)

	-- request ranking
	self.rankingListQuery.filter.rankingId = 1
	self.rankingListQuery.filter.userKey = PlayerInfo.GetSelf().userkey
	if self.imgDayRanking:GetImageIndex() == 0 then
		self.rankingListQuery.filter.period = RankingListQuery.PERIOD_DAILY
	else
		self.rankingListQuery.filter.period = RankingListQuery.PERIOD_TOTALLY
	end
	self.rankingListQuery:Request(true, 5, 10)	
end

function RankingDialog:OnBtnDownNextPage(sender, msg)
	self.txtRankingRange:SetText("11위~20위")
	self.btnPrevPage:Enable(true)
	self.btnNextPage:Enable(false)

	-- request ranking
	self.rankingListQuery.filter.rankingId = 1
	self.rankingListQuery.filter.userKey = nil
	if self.imgDayRanking:GetImageIndex() == 0 then
		self.rankingListQuery.filter.period = RankingListQuery.PERIOD_DAILY
	else
		self.rankingListQuery.filter.period = RankingListQuery.PERIOD_TOTALLY
	end
	self.rankingListQuery:Request(true, 11, 10)
end

function RankingDialog:OnBtnDownPrevPage(sender, msg)
	self.txtRankingRange:SetText("1위~10위")
	self.btnPrevPage:Enable(false)
	self.btnNextPage:Enable(true)

	-- request ranking
	self.rankingListQuery.filter.rankingId = 1
	self.rankingListQuery.filter.userKey = nil
	if self.imgDayRanking:GetImageIndex() == 0 then
		self.rankingListQuery.filter.period = RankingListQuery.PERIOD_DAILY
	else
		self.rankingListQuery.filter.period = RankingListQuery.PERIOD_TOTALLY
	end
	self.rankingListQuery:Request(true, 1, 10)
end

function RankingDialog:AddPlayerRanking(rankNo, changeValue, userNick, score)
	self.txtRankingMessage:Show(false)

	self.userCount = self.userCount + 1

	-- rank
	if (rankNo >= 1 and rankNo <= 20) then
		local imgRank = StaticImage()
		imgRank:LoadStaticImage("images\\iDoLobby\\pop_ranking_" .. tostring(rankNo) .. ".png")
		imgRank:SetXYPos(17, self.userCount * 20 - 9)
		self.grpRankingList:AddChild(imgRank)
	end

	-- up/down image
	if changeValue ~= 0  then
		local imgChange = StaticImage()
		if changeValue > 0 then
			imgChange:LoadStaticImage("images\\iDoLobby\\pop_ranking_up.png")
		elseif changeValue < 0 then
			imgChange:LoadStaticImage("images\\iDoLobby\\pop_ranking_down.png")
		end
		imgChange:SetXYPos(39, self.userCount * 20 - 4)
		self.grpRankingList:AddChild(imgChange)
	end

	-- change Value
	local textChange = Text()
	textChange:SetFont(iDoLobby_Settings.fontNormalNum)
	if changeValue == 0 then
		textChange:SetTextColor(iDoLobby_Settings.colorNormalText)
		textChange:SetText("-")
	elseif changeValue > 0 then
		textChange:SetTextColor(iDoLobby_Settings.colorRankUp)
		textChange:SetText(tostring(changeValue))
	else
		textChange:SetTextColor(iDoLobby_Settings.colorRankDown)
		textChange:SetText(tostring(-changeValue))
	end
	textChange:SetXYPos(47, self.userCount * 20 - 10)
	self.grpRankingList:AddChild(textChange)

	-- nick
	local textNick = Text()
	textNick:SetFont( iDoLobby_Settings.fontNormalText)
	textNick:SetTextColor(iDoLobby_Settings.colorNormalText)
	textNick:SetText(userNick)
	textNick:SetXYPos(87, self.userCount * 20 - 10)
	self.grpRankingList:AddChild(textNick)

	-- score
	local textScore = Text()
	textScore:SetFont(iDoLobby_Settings.fontNormalNum)
	textScore:SetTextColor(iDoLobby_Settings.colorNormalText)
	textScore:SetText(tostring(score))
	textScore:SetXYPos(258, self.userCount * 20 - 10)
	textScore:SetTextAlign(UIConst.HorzAlignCenter)
	self.grpRankingList:AddChild(textScore)
end

-- Override
function RankingDialog:Show(show)
	if show then
		-- Initialize dialog

		for i=1, self.grpRankingList:GetChildCount() do
			self.grpRankingList:GetChildAt(i):RemoveObject()
		end
		self.grpRankingList:RemoveAllChildren()

		self.txtRankingRange:SetText("1위~10위")
		self.btnPrevPage:Enable(false)
		self.btnNextPage:Enable(true)
		self.txtRankingMessage:Show(true)

		self.userCount = 0
		self.userList = {}

		self.grpRankingList:SetXYPos(23, 132)

		-- 랭크 요청
		self.rankingListQuery = RankingListQuery(lobbyapp)
		self.rankingListQuery:AddListener(self, self.OnUpdateRankingList)
		self.rankingListQuery.filter.rankingId = 1
		self.rankingListQuery.filter.userKey = nil
		if self.imgDayRanking:GetImageIndex() == 0 then
			self.rankingListQuery.filter.period = RankingListQuery.PERIOD_DAILY
		else
			self.rankingListQuery.filter.period = RankingListQuery.PERIOD_TOTALLY
		end
		self.rankingListQuery:Request(true, 1, 10)
	end  
	Graphic.Show(self, show)
	self:BringToTop()
end

function RankingDialog:OnUpdateRankingList(query, evtType, rankingData)
	self.userCount	= 0
	self.userList = {}

	for i=1, self.grpRankingList:GetChildCount() do
		self.grpRankingList:GetChildAt(i):RemoveObject()
	end
	self.grpRankingList:RemoveAllChildren()

	for rd in query:Items() do
		self:AddPlayerRanking(rd:GetRank(), rd:GetRankChange(), rd:GetUserNick(), rd:GetScore())
	end
end

function RankingDialog:CloneControls(scene)
	self.rankingBg = scene.rankingBg:Clone()
	self.imgDayRanking = scene.imgDayRanking:Clone()
	self.imgTotalRanking = scene.imgTotalRanking:Clone()
	self.btnMyRanking = scene.btnMyRanking:Clone()
	self.btnPrevPage = scene.btnPrevPage:Clone()
	self.btnNextPage = scene.btnNextPage:Clone()
	self.txtRankingRange = scene.txtRankingRange:Clone()
	self.cbRankingList = scene.cbRankingList:Clone()
	self.btnRankingExit = scene.btnRankingExit:Clone()
	self.btnRankingClose = scene.btnRankingClose:Clone()
	self.grpRankingList = scene.grpRankingList:Clone()
	self.txtRankingMessage = scene.txtRankingMessage:Clone()

	self:AddChild(self.rankingBg)
	self:AddChild(self.imgDayRanking)
	self:AddChild(self.imgTotalRanking)
	self:AddChild(self.btnMyRanking)
	self:AddChild(self.btnPrevPage)
	self:AddChild(self.btnNextPage)
	self:AddChild(self.txtRankingRange)
	self:AddChild(self.cbRankingList)
	self:AddChild(self.btnRankingExit)
	self:AddChild(self.btnRankingClose)
	self:AddChild(self.grpRankingList)
	self:AddChild(self.txtRankingMessage)

	self:Show(false)
end
  