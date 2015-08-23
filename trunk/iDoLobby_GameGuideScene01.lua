require "go.ui.Scene"

class 'iDoLobby_GameGuideScene01' (Scene)

function iDoLobby_GameGuideScene01:__init() super()
	self:SetupUIObjects()

	self.txtGameTitle:SetText(App.GetTitle())

	--self:SetMsgHandler(Evt_KeyboardDown, self.OnKeyDown)
	self.btnGameStart.MouseLClick:AddHandler(self, self.OnbtnGameStartMouseLClick)
	self.btnTutorial.MouseLClick:AddHandler(self, self.OnbtnTutorialMouseLClick)
end

-- @param msg class Message.
function iDoLobby_GameGuideScene01:OnKeyDown(msg)
	--local keyValue = msg:GetValue(Evt_KeyboardDown.key.Value)
	--print(keyValue)
end

-- @param elapsed number.
function iDoLobby_GameGuideScene01:Update(elapsed)
	
end


function iDoLobby_GameGuideScene01:OnbtnGameStartMouseLClick(sender, msg)
	lobbyapp:ActivateScene(lobbyapp.lobbyScene)
end

function iDoLobby_GameGuideScene01:OnbtnTutorialMouseLClick(sender, msg)
	-- 튜토리얼 생성시 이 부분에 코드 작성
end

require "iDoLobby_GameGuideScene01UIObject"