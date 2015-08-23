require "go.ui.Scene"

class 'iDoLobby_GameIntroScene' (Scene)

function iDoLobby_GameIntroScene:__init() super()
	self:SetupUIObjects()

	--self:SetMsgHandler(Evt_KeyboardDown, self.OnKeyDown)
end

-- @param msg class Message.
function iDoLobby_GameIntroScene:OnKeyDown(msg)
	--local keyValue = msg:GetValue(Evt_KeyboardDown.key.Value)
	--print(keyValue)
end

-- @param elapsed number.
function iDoLobby_GameIntroScene:Update(elapsed)

end

require "iDoLobby_GameIntroSceneUIObject"