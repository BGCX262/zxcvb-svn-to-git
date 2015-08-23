class 'uppuRacingKeyInput'

function uppuRacingKeyInput:__init(scene)
	self.scene = scene

	self:Clear()
end

function uppuRacingKeyInput:Read()
	if self.scene:IsStarted() == false then
		return
	end

	-- check keyboard state
	self.L = self.scene:GetKeyPressed(UIConst.KeyLeft)
	self.R = self.scene:GetKeyPressed(UIConst.KeyRight)
	self.U = self.scene:GetKeyPressed(UIConst.KeyUp)
	self.D = self.scene:GetKeyPressed(UIConst.KeyDown)
	self.Z = self.scene:GetKeyPressed(UIConst.KeyZ)
	self.X = self.scene:GetKeyPressed(UIConst.KeyX)
	self.C = self.scene:GetKeyPressed(UIConst.KeyC)
	
	-- check debug turn on/off
	local debug = self.scene:GetKeyPressed(UIConst.KeyF5)
	if debug then
		self.scene:ToggleDebug()
	end
end

function uppuRacingKeyInput:Clear()
	self.L = false
	self.R = false
	self.U = false
	self.D = false
	self.Z = false
	self.X = false
	self.C = false
end
