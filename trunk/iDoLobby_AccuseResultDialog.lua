require "go.ui.control.Group"
require "iDoLobby_PopupMultiEventHandler"

class 'AccuseResultDialog' (Group)

-- Constructor
function AccuseResultDialog:__init(popupScene, id) super(id)
	self:CloneControls(popupScene)

	-- Variables
	self.dragInfo = {btnDown = false, diffX = 0, diffY = 0}

	-- Add internal event handlers
	self.accuseResultBg.MouseDown:AddHandler(self, self.OnBgMouseDown)
	self.accuseResultBg.MouseMove:AddHandler(self, self.OnBgMouseMove)
	self.accuseResultBg.MouseUp:AddHandler(self, self.OnBgMouseUp)
	self.btnAccuseResultExit.MouseLClick:AddHandler(self, self.OnExit)
	self.btnAccuseResultOK.MouseLClick:AddHandler(self, self.OnExit)
	self.imgAccuseUrlLink.MouseLClick:AddHandler(self, self.OnResultUrlLink)
	self.imgAccuseUrlLink2.MouseLClick:AddHandler(self, self.OnResultUrlLink)
end

-- Internal handlers
function AccuseResultDialog:OnBgMouseDown(sender, msg)
	self.dragInfo.btnDown = true
	self.dragInfo.diffX = msg:GetValue(Evt_MouseDown.key.X)
	self.dragInfo.diffY = msg:GetValue(Evt_MouseDown.key.Y)
	self:BringToTop()
end

function AccuseResultDialog:OnBgMouseMove(sender, msg)
	if self.dragInfo.btnDown == false then return end

	local x = self:GetAbsXPos() + msg:GetValue(Evt_MouseMove.key.X)
	local y = self:GetAbsYPos() + msg:GetValue(Evt_MouseMove.key.Y)
	self:SetAbsXYPos(x - self.dragInfo.diffX, y - self.dragInfo.diffY)
end

function AccuseResultDialog:OnBgMouseUp(sender, msg)
	self.dragInfo.btnDown = false

	local x, y = self:GetAbsXYPos()
	local windowSize = lobbyapp:GetWindowSize()

	if x < 0 then
		self:SetAbsXPos(0)
	elseif x + self.accuseResultBg:GetWidth() > windowSize.x then
		self:SetAbsXPos(windowSize.x - self.accuseResultBg:GetWidth())
	end

	if y < 0 then
		self:SetAbsYPos(0)
	elseif y + self.accuseResultBg:GetHeight() > windowSize.y then
		self:SetAbsYPos(windowSize.y - self.accuseResultBg:GetHeight())
	end
end

function AccuseResultDialog:OnExit(sender, msg)
	self:Show(false)
end

function AccuseResultDialog:OnResultUrlLink(sender, msg)
	__main:OpenWebPage("http://cs.hangame.com/content/clean/badness.do?pageId=20")
end

function AccuseResultDialog:CloneControls(scene)
	self.accuseResultBg = scene.accuseResultBg:Clone()
	self.btnAccuseResultExit = scene.btnAccuseResultExit:Clone()
	self.btnAccuseResultOK = scene.btnAccuseResultOK:Clone()
	self.imgAccuseUrlLink = scene.imgAccuseUrlLink:Clone()
	self.imgAccuseUrlLink2 = scene.imgAccuseUrlLink2:Clone()

	self:AddChild(self.accuseResultBg)
	self:AddChild(self.btnAccuseResultExit)
	self:AddChild(self.btnAccuseResultOK)
	self:AddChild(self.imgAccuseUrlLink)
	self:AddChild(self.imgAccuseUrlLink2)

	self:Show(false)
end
  