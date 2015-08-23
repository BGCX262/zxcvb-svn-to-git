require "go.ui.control.Group"
require "iDoLobby_PopupMultiEventHandler"

class 'InviteAcceptDialog' (Group)

-- Constructor
function InviteAcceptDialog:__init(popupScene, id) super(id)
	self:CloneControls(popupScene)

	-- Variables
	self.dragInfo = {btnDown = false, diffX = 0, diffY = 0}

	-- Event Handlers
	self.OkClick = iDoLobby_PopupMultiEventHandler(self.btnInviteAccept, Evt_MouseLClick)

	-- Add internal event handlers
	self.inviteAcceptBg.MouseDown:AddHandler(self, self.OnBgMouseDown)
	self.inviteAcceptBg.MouseMove:AddHandler(self, self.OnBgMouseMove)
	self.inviteAcceptBg.MouseUp:AddHandler(self, self.OnBgMouseUp)
	self.btnInviteReject.MouseLClick:AddHandler(self, self.OnExit)
	self.OkClick:AddHandler(self, self.OnOKClick)
end

-- Internal handlers
function InviteAcceptDialog:OnBgMouseDown(sender, msg)
	self.dragInfo.btnDown = true
	self.dragInfo.diffX = msg:GetValue(Evt_MouseDown.key.X)
	self.dragInfo.diffY = msg:GetValue(Evt_MouseDown.key.Y)
	self:BringToTop()
end

function InviteAcceptDialog:OnBgMouseMove(sender, msg)
	if self.dragInfo.btnDown == false then return end

	local x = self:GetAbsXPos() + msg:GetValue(Evt_MouseMove.key.X)
	local y = self:GetAbsYPos() + msg:GetValue(Evt_MouseMove.key.Y)
	self:SetAbsXYPos(x - self.dragInfo.diffX, y - self.dragInfo.diffY)
end

function InviteAcceptDialog:OnBgMouseUp(sender, msg)
	self.dragInfo.btnDown = false

	local x, y = self:GetAbsXYPos()
	local windowSize = lobbyapp:GetWindowSize()

	if x < 0 then
		self:SetAbsXPos(0)
	elseif x + self.inviteAcceptBg:GetWidth() > windowSize.x then
		self:SetAbsXPos(windowSize.x - self.inviteAcceptBg:GetWidth())
	end

	if y < 0 then
		self:SetAbsYPos(0)
	elseif y + self.inviteAcceptBg:GetHeight() > windowSize.y then
		self:SetAbsYPos(windowSize.y - self.inviteAcceptBg:GetHeight())
	end
end

function InviteAcceptDialog:SetInviteInfo(nickName, roomNo, roomCreationTime, roomPassword, startsec)
	self.txtInviter:SetText(nickName .. "님이 게임초대를 신청했습니다.")
	self.roomNo = roomNo
	self.roomCreationTime = roomCreationTime
	self.roomPassword = roomPassword
	self.startsec = startsec
end

function InviteAcceptDialog:Update()
	local cursec = App.GetCurrentSeconds()
	
	local remainTime = 15 - (cursec - self.startsec)
	if remainTime < 0 then
		self:Show(false)
	end

	self.txtRemainTime:SetText(tostring(math.floor(remainTime)))
	self.imgLoadingBar:SetWidth(308 * remainTime / 15)
end

function InviteAcceptDialog:OnOKClick(sender, msg)
	self:Show(false)
end

function InviteAcceptDialog:OnExit(sender, msg)
	self:Show(false)
end

function InviteAcceptDialog:Show(show)
	Graphic.Show(self, show)
	self:BringToTop()
end

function InviteAcceptDialog:CloneControls(scene)
	self.inviteAcceptBg = scene.inviteAcceptBg:Clone()
	self.btnInviteAccept = scene.btnInviteAccept:Clone()
	self.btnInviteReject = scene.btnInviteReject:Clone()
	self.txtInviter = scene.txtInviter:Clone()
	self.txtRemainTime = scene.txtRemainTime:Clone()
	self.imgLoadingBar = scene.imgLoadingBar:Clone()

	self:AddChild(self.inviteAcceptBg)
	self:AddChild(self.btnInviteAccept)
	self:AddChild(self.btnInviteReject)
	self:AddChild(self.txtInviter)
	self:AddChild(self.txtRemainTime)
	self:AddChild(self.imgLoadingBar)

	self:Show(false)
end
