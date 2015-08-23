require "go.ui.control.Group"
require "iDoLobby_PopupMultiEventHandler"

class 'AccuseDialog' (Group)

-- Constructor
function AccuseDialog:__init(popupScene, id) super(id)
	self:CloneControls(popupScene)

	-- Variables
	self.dragInfo = {btnDown = false, diffX = 0, diffY = 0}

	-- Event Handlers
	self.OkClick = iDoLobby_PopupMultiEventHandler(self.btnAccuseOK	, Evt_MouseLClick)

	-- Add internal event handlers
	self.accuseBg.MouseDown:AddHandler(self, self.OnBgMouseDown)
	self.accuseBg.MouseMove:AddHandler(self, self.OnBgMouseMove)
	self.accuseBg.MouseUp:AddHandler(self, self.OnBgMouseUp)

	self.radioAccuse1.MouseLClick:AddHandler(self, self.OnradioAccuseClick)
	self.radioAccuse2.MouseLClick:AddHandler(self, self.OnradioAccuseClick)
	self.radioAccuse3.MouseLClick:AddHandler(self, self.OnradioAccuseClick)
	self.radioAccuse4.MouseLClick:AddHandler(self, self.OnradioAccuseClick)
	self.radioAccuse5.MouseLClick:AddHandler(self, self.OnradioAccuseClick)
	self.radioAccuse6.MouseLClick:AddHandler(self, self.OnradioAccuseClick)
	self.radioAccuse7.MouseLClick:AddHandler(self, self.OnradioAccuseClick)

	self.btnAccuseExit.MouseLClick:AddHandler(self, self.OnExit)
	self.btnAccuseCancel.MouseLClick:AddHandler(self, self.OnExit)
	self.OkClick:AddHandler(self, self.OnOKClick)

	self.scrChatter.ScrollBarChanged:AddHandler(self, self.OnScrollChatter)
end

function AccuseDialog:Reset()
	self.uiList = {}
	self.selectedUserKey = nil
	self.complain = AccuseType.BADWORDS
	self.radioAccuse1:SetSelected(true)
	self.editAccuseReport:ClearEdit()
	self.editAccuseReport:Enable(false)
end

function AccuseDialog:GetSelectedUserKey()
	return self.selectedUserKey
end

function AccuseDialog:GetCauseString()
	return self.editAccuseReport:GetText()
end

-- Internal handlers
function AccuseDialog:OnBgMouseDown(sender, msg)
	self.dragInfo.btnDown = true
	self.dragInfo.diffX = msg:GetValue(Evt_MouseDown.key.X)
	self.dragInfo.diffY = msg:GetValue(Evt_MouseDown.key.Y)
	self:BringToTop()
end

function AccuseDialog:OnBgMouseMove(sender, msg)
	if self.dragInfo.btnDown == false then return end

	local x = self:GetAbsXPos() + msg:GetValue(Evt_MouseMove.key.X)
	local y = self:GetAbsYPos() + msg:GetValue(Evt_MouseMove.key.Y)
	self:SetAbsXYPos(x - self.dragInfo.diffX, y - self.dragInfo.diffY)
end

function AccuseDialog:OnBgMouseUp(sender, msg)
	self.dragInfo.btnDown = false

	local x, y = self:GetAbsXYPos()
	local windowSize = lobbyapp:GetWindowSize()

	if x < 0 then
		self:SetAbsXPos(0)
	elseif x + self.accuseBg:GetWidth() > windowSize.x then
		self:SetAbsXPos(windowSize.x - self.accuseBg:GetWidth())
	end

	if y < 0 then
		self:SetAbsYPos(0)
	elseif y + self.accuseBg:GetHeight() > windowSize.y then
		self:SetAbsYPos(windowSize.y - self.accuseBg:GetHeight())
	end
end

function AccuseDialog:OnScrollChatter(sender, msg)
	local diff = sender:GetScrollValue()
	--print(diff)

	for i = 0, self.userCount - 1 do
		self.uiList[i]["imgSelection"]:SetYPos(i * 20 - 1 - diff)
		self.uiList[i]["textNick"]:SetYPos(i * 20 + 2 - diff)
	end
end

function AccuseDialog:SetAccuserNick(userNick)
	self.txtAccuseNick:SetText(userNick)
end

function AccuseDialog:OnOKClick(sender, msg)
	self:Show(false)
end

function AccuseDialog:OnExit(sender, msg)
	self:Show(false)
end

function AccuseDialog:OnSelectPlayer(sender, msg)
	if sender:GetImageIndex() == 0 then
		for i = 0, self.userCount - 1 do
			if self.uiList[i]["imgSelection"] == sender then
				self.uiList[i]["imgSelection"]:SetImageIndex(1)
				self.selectedUserKey = sender.userKey
			else
				self.uiList[i]["imgSelection"]:SetImageIndex(0)
			end
		end
	else
		sender:SetImageIndex(0)
		self.selectedUserKey = nil
	end
end

function AccuseDialog:Show(show)
	for i=1, self.grpPlayerList:GetChildCount() do
		self.grpPlayerList:GetChildAt(i):RemoveObject()
	end
	self.grpPlayerList:RemoveAllChildren()

	if show then
		self.userCount = 0

		for userKey, ci in pairs(lobbyapp.chatterList) do
			if userKey ~= PlayerInfo.GetSelf().userkey then
				self:AddPlayer(ci.NickName, userKey)
			end
		end

		self.grpPlayerList:EnableClip(true)
		self.grpPlayerList:SetClipRect(Rect(-1, -1, 290, 79))
	
		if self.userCount >= 4 then
			self.scrChatter:Enable(true)
			self.scrChatter:SetMinValue(0)
			self.scrChatter:SetMaxValue((self.userCount - 4) * 20)
		else
			self.scrChatter:Enable(false)
		end
	end

	Graphic.Show(self, show)
	self:BringToTop()
end

function AccuseDialog:AddPlayer(userNick, userKey)
	self.userCount = self.userCount + 1

	self.uiList[self.userCount - 1] = {}

	-- image
	local imgSelection = Image()
	imgSelection:LoadControlImage("images\\iDoLobby\\selection.bmp", 2, 1)
	imgSelection:SetImageIndex(0)
	imgSelection:SetXYPos(-1, self.userCount * 20 - 21)
	self.grpPlayerList:AddChild(imgSelection)
	imgSelection.MouseLClick:AddHandler(self, self.OnSelectPlayer)
	imgSelection.userKey = userKey
	self.uiList[self.userCount - 1]["imgSelection"] = imgSelection

	-- nick
	local textNick = Text()
	textNick:SetFont(iDoLobby_Settings.fontNormalText)
	textNick:SetTextColor(iDoLobby_Settings.colorNormalText)
	textNick:SetText(userNick)
	textNick:SetXYPos(7, self.userCount * 20 - 18)
	self.grpPlayerList:AddChild(textNick)
	self.uiList[self.userCount - 1]["textNick"] = textNick
end

function AccuseDialog:OnradioAccuseClick(sender, msg)
	if sender == self.radioAccuse1 then
		self.complain = AccuseType.BADWORDS
	elseif sender == self.radioAccuse2 then
		self.complain = AccuseType.MONEYTRADE
	elseif sender == self.radioAccuse3 then
		self.complain = AccuseType.ADS
	elseif sender == self.radioAccuse4 then
		self.complain = AccuseType.DIRTYCHAT
	elseif sender == self.radioAccuse5 then
		self.complain = AccuseType.FALSEGM 
	elseif sender == self.radioAccuse6 then
		self.complain = AccuseType.CHATABUSE
	elseif sender == self.radioAccuse7 then
		self.complain = AccuseType.ETC
		self.editAccuseReport:SetFocus()
	end

	self.editAccuseReport:Enable(sender == self.radioAccuse7)
	self.editAccuseReport:ClearEdit()
end

function AccuseDialog:CloneControls(scene)
	self.accuseBg = scene.accuseBg:Clone()
	self.btnAccuseExit = scene.btnAccuseExit:Clone()
	self.txtAccuseNick = scene.txtAccuseNick:Clone()
	self.radioAccuse1 = scene.radioAccuse1:Clone()
	self.radioAccuse2 = scene.radioAccuse2:Clone()
	self.radioAccuse3 = scene.radioAccuse3:Clone()
	self.radioAccuse4 = scene.radioAccuse4:Clone()
	self.radioAccuse5 = scene.radioAccuse5:Clone()
	self.radioAccuse6 = scene.radioAccuse6:Clone()
	self.radioAccuse7 = scene.radioAccuse7:Clone()
	self.editAccuseReport = scene.editAccuseReport:Clone()
	self.btnAccuseOK = scene.btnAccuseOK:Clone()
	self.btnAccuseCancel = scene.btnAccuseCancel:Clone()
	self.grpPlayerList = scene.grpPlayerList:Clone()
	self.grpAccuseOption = Group()
	self.scrChatter = scene.scrChatter:Clone()

	self:AddChild(self.accuseBg)
	self:AddChild(self.btnAccuseExit)
	self:AddChild(self.txtAccuseNick)
	self:AddChild(self.grpAccuseOption)
	self:AddChild(self.editAccuseReport)
	self:AddChild(self.btnAccuseOK)
	self:AddChild(self.btnAccuseCancel)
	self:AddChild(self.grpPlayerList)
	self:AddChild(self.scrChatter)

	self.grpAccuseOption:AddChild(self.radioAccuse1)
	self.grpAccuseOption:AddChild(self.radioAccuse2)
	self.grpAccuseOption:AddChild(self.radioAccuse3)
	self.grpAccuseOption:AddChild(self.radioAccuse4)
	self.grpAccuseOption:AddChild(self.radioAccuse5)
	self.grpAccuseOption:AddChild(self.radioAccuse6)
	self.grpAccuseOption:AddChild(self.radioAccuse7)

	self:Show(false)
end
 