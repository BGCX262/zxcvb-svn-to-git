require "go.ui.control.Group"
require "iDoLobby_PopupMultiEventHandler"

class 'PasswordDialog' (Group)

-- Constructor
function PasswordDialog:__init(popupScene, id) super(id)
	self:CloneControls(popupScene)

	-- Variables
	self.dragInfo = {btnDown = false, diffX = 0, diffY = 0}

	self.editPassword:SetMaxLength(iDoLobby_Settings.maxPasswordLength)

	-- Event Handlers
	self.OkClick = iDoLobby_PopupMultiEventHandler(self.btnPasswordOK, Evt_MouseLClick)
	self.CancelClick = iDoLobby_PopupMultiEventHandler(self.btnPasswordCancel, Evt_MouseLClick)

	-- Add internal event handlers
	self.passwordBg.MouseDown:AddHandler(self, self.OnBgMouseDown)
	self.passwordBg.MouseMove:AddHandler(self, self.OnBgMouseMove)
	self.passwordBg.MouseUp:AddHandler(self, self.OnBgMouseUp)

	self.OkClick:AddHandler(self, self.OnOKClick)
	self.CancelClick:AddHandler(self, self.OnCancelClick)
end

-- Methods
function PasswordDialog:GetPassword()
	return self.editPassword:GetText()
end

-- Override
function PasswordDialog:Show(show)
	if show then
		-- Initialize dialog
		self.editPassword:ClearEdit()
		self.editPassword:Enable(true)
	end

	Graphic.Show(self, show)
	self:BringToTop()
end

-- Internal handlers
function PasswordDialog:OnBgMouseDown(sender, msg)
	self.dragInfo.btnDown = true
	self.dragInfo.diffX = msg:GetValue(Evt_MouseDown.key.X)
	self.dragInfo.diffY = msg:GetValue(Evt_MouseDown.key.Y)
	self:BringToTop()
end

function PasswordDialog:OnBgMouseMove(sender, msg)
	if self.dragInfo.btnDown == false then return end

	local x = self:GetAbsXPos() + msg:GetValue(Evt_MouseMove.key.X)
	local y = self:GetAbsYPos() + msg:GetValue(Evt_MouseMove.key.Y)
	self:SetAbsXYPos(x - self.dragInfo.diffX, y - self.dragInfo.diffY)
end

function PasswordDialog:OnBgMouseUp(sender, msg)
	self.dragInfo.btnDown = false

	local x, y = self:GetAbsXYPos()
	local windowSize = lobbyapp:GetWindowSize()

	if x < 0 then
		self:SetAbsXPos(0)
	elseif x + self.passwordBg:GetWidth() > windowSize.x then
		self:SetAbsXPos(windowSize.x - self.passwordBg:GetWidth())
	end

	if y < 0 then
		self:SetAbsYPos(0)
	elseif y + self.passwordBg:GetHeight() > windowSize.y then
		self:SetAbsYPos(windowSize.y - self.passwordBg:GetHeight())
	end
end

function PasswordDialog:OnOKClick(sender, msg)
	self:Show(false)
end

function PasswordDialog:OnCancelClick(sender, msg)
	self:Show(false)
end

function PasswordDialog:CloneControls(scene)
	self.passwordBg = scene.passwordBg:Clone()
	self.editPassword = scene.editPassword:Clone()
	self.btnPasswordOK = scene.btnPasswordOK:Clone()
	self.btnPasswordCancel = scene.btnPasswordCancel:Clone()

	self:AddChild(self.passwordBg)
	self:AddChild(self.editPassword)
	self:AddChild(self.btnPasswordOK)
	self:AddChild(self.btnPasswordCancel)

	self:Show(false)
end
