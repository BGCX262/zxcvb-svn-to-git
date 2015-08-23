require "go.ui.control.Group"
require "iDoLobby_PopupMultiEventHandler"

class 'CreateRoomDialog' (Group)

-- Password Option Constants
CreateRoomDialog.ROOM_WITH_NO_PASSWORD = 1
CreateRoomDialog.ROOM_WITH_PASSWORD = 2
-- Invite Option Constants
CreateRoomDialog.ROOM_NO_INVITEE = 1
CreateRoomDialog.ROOM_RANDOM_INVITEE = 2
CreateRoomDialog.ROOM_SELECTED_INVITEE = 3

-- Constructor
function CreateRoomDialog:__init(popupScene, id) super(id)
	self:CloneControls(popupScene)

	-- Variables
	self.dragInfo = {btnDown = false, diffX = 0, diffY = 0}
	self.fontHeight = 0

	-- limit length
	self.edtRoomTitle:SetMaxLength(iDoLobby_Settings.maxRoomTitleLength )
	self.edtPassword:SetMaxLength(iDoLobby_Settings.maxPasswordLength)

	-- Event Handlers
	self.OkClick = iDoLobby_PopupMultiEventHandler(self.btnOK, Evt_MouseLClick)
	self.InviteeSelectClick = iDoLobby_PopupMultiEventHandler(self.radInviteOption3, Evt_MouseLClick)
	self.ModifyClick = iDoLobby_PopupMultiEventHandler(self.btnModify, Evt_MouseLClick)

	-- Add internal event handlers
	self.imgBg.MouseDown:AddHandler(self, self.OnBgMouseDown)
	self.imgBg.MouseDown:AddHandler(self, self.OnHideRoomTitleCombo)
	self.imgBg.MouseMove:AddHandler(self, self.OnBgMouseMove)
	self.imgBg.MouseUp:AddHandler(self, self.OnBgMouseUp)
	self.imgRoomTitleComboBg.MouseDown:AddHandler(self, self.OnComboBgMouseDown)
	self.chkRoomTitleCombo.MouseDown:AddHandler(self, self.OnComboMouseDown)
	self.radPasswordOption1.MouseLClick:AddHandler(self, self.OnPasswordOptionClick)
	self.radPasswordOption1.MouseLClick:AddHandler(self, self.OnHideRoomTitleCombo)
	self.radPasswordOption2.MouseLClick:AddHandler(self, self.OnPasswordOptionClick)
	self.radPasswordOption2.MouseLClick:AddHandler(self, self.OnHideRoomTitleCombo)
	self.radInviteOption1.MouseLClick:AddHandler(self, self.OnInviteOptionClick)
	self.radInviteOption1.MouseLClick:AddHandler(self, self.OnHideRoomTitleCombo)
	self.radInviteOption2.MouseLClick:AddHandler(self, self.OnInviteOptionClick)
	self.radInviteOption2.MouseLClick:AddHandler(self, self.OnHideRoomTitleCombo)
	--self.radInviteOption3.MouseLClick:AddHandler(self, self.OnInviteOptionClick)
	--self.radInviteOption3.MouseLClick:AddHandler(self, self.OnHideRoomTitleCombo)
	self.edtRoomTitle.FocusGain:AddHandler(self, self.OnHideRoomTitleCombo)
	self.edtRoomTitle.KeyboardDown:AddHandler(self, self.OnRoomTitleChanged)
	self.btnCancel.MouseLClick:AddHandler(self, self.OnExit)
	self.btnClose.MouseLClick:AddHandler(self, self.OnExit)
	self.OkClick:AddHandler(self, self.OnOKClick)
	self.InviteeSelectClick:AddHandler(self, self.OnInviteOptionClick)
	self.InviteeSelectClick:AddHandler(self, self.OnHideRoomTitleCombo)
end

-- Methods
function CreateRoomDialog:GetPasswordOption()
	if self.radPasswordOption2:IsSelected() then
		return CreateRoomDialog.ROOM_WITH_PASSWORD
	end
	return CreateRoomDialog.ROOM_WITH_NO_PASSWORD
end

function CreateRoomDialog:GetInviteOption()
	if self.radInviteOption2:IsSelected() then
		return CreateRoomDialog.ROOM_RANDOM_INVITEE
	elseif self.radInviteOption3:IsSelected() then
		return CreateRoomDialog.ROOM_SELECTED_INVITEE
	end
	return CreateRoomDialog.ROOM_NO_INVITEE
end

function CreateRoomDialog:GetRoomTitle()
	return self.edtRoomTitle:GetText()
end

function CreateRoomDialog:GetPassword()
	return self.edtPassword:GetText()
end

function CreateRoomDialog:SetRoomTitleList(roomTitles, fontInfo, color)
	assert(#roomTitles > 0)
	assert(fontInfo)
	assert(color)
	assert("number" == type(color))

	self.fontHeight = fontInfo.height + 3
	-- Remove room title list
	for i=1, self.grpRoomTitleCombo:GetChildCount() do
		local child = self.grpRoomTitleCombo:GetChildAt(i)
		child:RemoveObject()
	end
	self.grpRoomTitleCombo:RemoveAllChildren()

	-- Create title list
	local y = 0
	for i, title in ipairs(roomTitles) do
		local text = Text()
		text:SetFont(fontInfo)
		text:SetTextColor(color)
		text:SetText(title)
		text:SetXYPos(7, y + 4)
		self.grpRoomTitleCombo:AddChild(text)
		y = y + self.fontHeight
	end

	-- ComboList Frame
	self.imgRoomTitleComboBg:SetXPos(self.imgRoomTitleComboBgTop:GetXPos())
	self.imgRoomTitleComboBg:SetYPos(self.imgRoomTitleComboBgTop:GetYPos() + self.imgRoomTitleComboBgTop:GetHeight())
	self.imgRoomTitleComboBg:SetHeight(y)
	self.imgRoomTitleComboBgBottom:SetXPos(self.imgRoomTitleComboBg:GetXPos())
	self.imgRoomTitleComboBgBottom:SetYPos(self.imgRoomTitleComboBg:GetYPos() + y)
	self.chkRoomTitleCombo:Enable(true)
end

-- Override
function CreateRoomDialog:Show(show)
	if show then
		-- Initialize dialog
		self.edtRoomTitle:ClearEdit()
		self.edtRoomTitle:SetFocus()
		self.edtPassword:ClearEdit()
		self.edtPassword:Enable(false)
		self.radPasswordOption1:SetSelected(true)
		self.radInviteOption1:SetSelected(true)
		self.txtSelectCount:Show(false)
		self.txtSelectString:Show(false)
		self.btnModify:Show(false)
		if self.grpRoomTitleCombo:GetChildCount() > 0 then
			self.edtRoomTitle:InsertText(self.grpRoomTitleCombo:GetChildAt(1):GetText())
			self.btnOK:Enable(true)
		end
	end
	Graphic.Show(self, show)
	self:BringToTop()
end

-- Internal handlers
function CreateRoomDialog:OnBgMouseDown(sender, msg)
	self.dragInfo.btnDown = true
	self.dragInfo.diffX = msg:GetValue(Evt_MouseDown.key.X)
	self.dragInfo.diffY = msg:GetValue(Evt_MouseDown.key.Y)
	self:BringToTop()
end

function CreateRoomDialog:OnBgMouseMove(sender, msg)
	if self.dragInfo.btnDown == false then return end

	local x = self:GetAbsXPos() + msg:GetValue(Evt_MouseMove.key.X)
	local y = self:GetAbsYPos() + msg:GetValue(Evt_MouseMove.key.Y)
	self:SetAbsXYPos(x - self.dragInfo.diffX, y - self.dragInfo.diffY)
end

function CreateRoomDialog:OnBgMouseUp(sender, msg)
	self.dragInfo.btnDown = false

	local x, y = self:GetAbsXYPos()
	local windowSize = lobbyapp:GetWindowSize()

	if x < 0 then
		self:SetAbsXPos(0)
	elseif x + self.imgBg:GetWidth() > windowSize.x then
		self:SetAbsXPos(windowSize.x - self.imgBg:GetWidth())
	end

	if y < 0 then
		self:SetAbsYPos(0)
	elseif y + self.imgBg:GetHeight() > windowSize.y then
		self:SetAbsYPos(windowSize.y - self.imgBg:GetHeight())
	end
end

function CreateRoomDialog:OnComboBgMouseDown(sender, msg)
	local y = msg:GetValue(Evt_MouseDown.key.Y)
	local index = math.floor(y / self.fontHeight + 1)
	if index < 1 or index > self.grpRoomTitleCombo:GetChildCount() then return end

	local title = self.grpRoomTitleCombo:GetChildAt(index)
	self.edtRoomTitle:ClearEdit()
	self.edtRoomTitle:InsertText(title:GetText())
	self:ShowRoomTitleComboList(false)

	-- [IDOGAMECOMMON-136] invoke event on room title changed by combo selection
	self:OnRoomTitleChanged(sender, msg)
end

function CreateRoomDialog:OnComboMouseDown(sender, msg)
	self:ShowRoomTitleComboList(sender:IsChecked())
end

function CreateRoomDialog:OnOKClick(sender, msg)
	self:Show(false)
end

function CreateRoomDialog:OnExit(sender, msg)
	self:Show(false)
end

function CreateRoomDialog:SetSelectCount(count)
	self.txtSelectCount:SetText(tostring(count))
	self.txtSelectCount:Show(true)
	self.txtSelectString:Show(true)
	self.btnModify:Show(true)
end

function CreateRoomDialog:OnPasswordOptionClick(sender, msg)
	if sender == self.radPasswordOption2 and sender:IsSelected() then
		self.edtPassword:Enable(true)
		self.edtPassword:SetFocus()
	else
		self.edtPassword:Enable(false)
	end
end

function CreateRoomDialog:OnInviteOptionClick(sender, msg)
	if sender == self.radInviteOption1 then
		self.txtSelectCount:SetText("0")
		self.txtSelectCount:Show(false)
		self.txtSelectString:Show(false)
		self.btnModify:Show(false)
		self.radInviteOption1:SetSelected(true)
	elseif sender == self.radInviteOption2 then
		self.txtSelectCount:SetText("0")
		self.txtSelectCount:Show(false)
		self.txtSelectString:Show(false)
		self.btnModify:Show(false)
		self.radInviteOption2:SetSelected(true)
	else
		self.radInviteOption3:SetSelected(true)
	end
end

function CreateRoomDialog:OnHideRoomTitleCombo(sender, msg)
	self:ShowRoomTitleComboList(false)
end

function CreateRoomDialog:OnRoomTitleChanged(sender, msg)
	local length = self.edtRoomTitle:GetTextLength()
	self.btnOK:Enable(length > 0)	-- make btnOK disabled when room title is empty
end

function CreateRoomDialog:CloneControls(scene)
	self.imgBg = scene.imgBg:Clone()
	self.edtRoomTitle = scene.edtRoomTitle:Clone()
	self.chkRoomTitleCombo = scene.chkRoomTitleCombo:Clone()
	self.radPasswordOption1 = scene.radPasswordOption1:Clone()
	self.radPasswordOption2 = scene.radPasswordOption2:Clone()
	self.edtPassword = scene.edtPassword:Clone()
	self.radInviteOption1 = scene.radInviteOption1:Clone()
	self.radInviteOption2 = scene.radInviteOption2:Clone()
	self.radInviteOption3 = scene.radInviteOption3:Clone()
	self.btnOK = scene.btnOK:Clone()
	self.btnCancel = scene.btnCancel:Clone()
	self.btnClose = scene.btnClose:Clone()
	self.imgRoomTitleComboBg = scene.imgRoomTitleComboBg:Clone()
	self.imgRoomTitleComboBgTop = scene.imgRoomTitleComboBgTop:Clone()
	self.imgRoomTitleComboBgBottom = scene.imgRoomTitleComboBgBottom:Clone()
	self.txtSelectCount = scene.txtSelectCount:Clone()
	self.txtSelectString = scene.txtSelectString:Clone()
	self.btnModify = scene.btnModify:Clone()
	self.grpPasswordOption = Group()
	self.grpInviteOption = Group()
	self.grpRoomTitleCombo = Group()

	self:AddChild(self.imgBg)
	self:AddChild(self.edtRoomTitle)
	self:AddChild(self.chkRoomTitleCombo)
	self:AddChild(self.grpPasswordOption)
	self:AddChild(self.edtPassword)
	self:AddChild(self.grpInviteOption)
	self:AddChild(self.btnOK)
	self:AddChild(self.btnCancel)
	self:AddChild(self.btnClose)
	self:AddChild(self.txtSelectCount)
	self:AddChild(self.txtSelectString)
	self:AddChild(self.btnModify)
	self:AddChild(self.imgRoomTitleComboBg)
	self:AddChild(self.imgRoomTitleComboBgTop)
	self:AddChild(self.imgRoomTitleComboBgBottom)
	self:AddChild(self.grpRoomTitleCombo)

	self.grpPasswordOption:AddChild(self.radPasswordOption1)
	self.grpPasswordOption:AddChild(self.radPasswordOption2)
	self.grpInviteOption:AddChild(self.radInviteOption1)
	self.grpInviteOption:AddChild(self.radInviteOption2)
	self.grpInviteOption:AddChild(self.radInviteOption3)

	self.grpRoomTitleCombo:SetXYPos(self.imgRoomTitleComboBg:GetXYPos())
	self.grpRoomTitleCombo:Show(false)
	self.chkRoomTitleCombo:Enable(false)
	self:Show(false)
end

function CreateRoomDialog:ShowRoomTitleComboList(show)
	self.grpRoomTitleCombo:Show(show)
	self.imgRoomTitleComboBg:Show(show)
	self.imgRoomTitleComboBgTop:Show(show)
	self.imgRoomTitleComboBgBottom:Show(show)
	self.chkRoomTitleCombo:SetChecked(show)
end