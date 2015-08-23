require "go.ui.Scene"
require "uppuRacingProtocol"
require "uppuRacingConsts"

class 'Scene_WaitingRoom' (Scene)

function Scene_WaitingRoom:__init(id)	super(id)
	self:SetupUIObjects()

	--self:SetMsgHandler(Evt_KeyboardDown, self.OnKeyDown)
	self.btnExit.MouseLClick:AddHandler( self, self.OnExit )
end

function Scene_WaitingRoom:OnKeyDown(msg)
	--local keyValue = msg:GetValue(Evt_KeyboardDown.key.Value)
	--print(keyValue)
end

function Scene_WaitingRoom:Update(elapsed)

end

function Scene_WaitingRoom:OnExit( sender, msg )
	gameapp:ExitGame()
end

require "Scene_WaitingRoomUIObject"