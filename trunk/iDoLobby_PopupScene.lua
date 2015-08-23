require "go.ui.Scene"
require "iDoLobby_CreateRoomDialog"
require "iDoLobby_PasswordDialog"
require "iDoLobby_MessageBoxDialog"
require "iDoLobby_AccuseDialog"
require "iDoLobby_AccuseResultDialog"
require "iDoLobby_InviteDialog"
require "iDoLobby_InviteAcceptDialog"
require "iDoLobby_RankingDialog"

class 'iDoLobby_PopupScene' (Scene)

function iDoLobby_PopupScene:__init() super()
	self:SetupUIObjects()

	self.dlgCreateRoom = CreateRoomDialog(self)
	self.dlgPassword = PasswordDialog(self)
	self.dlgMessageBox = MessageBoxDialog(self)
	self.dlgAccuse = AccuseDialog(self)
	self.dlgAccuseResult = AccuseResultDialog(self)
	self.dlgInvite = InviteDialog(self)
	self.dlgInviteAcceptList = {}
	for i = 1, iDoLobby_Settings.maxInviteAcceptDialogCount do
		self.dlgInviteAcceptList[i] = InviteAcceptDialog(self)
	end
	self.dlgRanking = RankingDialog(self)

	--self:SetMsgHandler(Evt_KeyboardDown, self.OnKeyDown)
end

-- @param msg class Message.
function iDoLobby_PopupScene:OnKeyDown(msg)
	--local keyValue = msg:GetValue(Evt_KeyboardDown.key.Value)
	--print(keyValue)
end

-- @param elapsed number.
function iDoLobby_PopupScene:Update(elapsed)
end

function iDoLobby_PopupScene:HideAllDialogs()
	self.dlgCreateRoom:Show(false)
	self.dlgPassword:Show(false)
	--self.dlgMessageBox:Show(false)
	self.dlgAccuse:Show(false)
	self.dlgAccuseResult:Show(false)
	self.dlgInvite:Show(false)
	for i = 1, iDoLobby_Settings.maxInviteAcceptDialogCount do
		self.dlgInviteAcceptList[i]:Show(false)
	end
	self.dlgRanking:Show(false)
end

require "iDoLobby_PopupSceneUIObject"