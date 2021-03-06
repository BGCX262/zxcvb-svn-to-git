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

	self.keydowns[1] = self.L
	self.keydowns[2] = self.R 
	self.keydowns[3] = self.U
	self.keydowns[4] = self.D

	-- select new base key
	if self.keydowns[self.basekey] ~= true and self.keydowns[self.secondkey] == true then
		self.basekey = self.secondkey
		self.secondkey = 98
		print (string.format("base key = %d (second key -> base key)", self.basekey	))
	end

	if self.keydowns[self.basekey] ~= true or self.keydowns[self.secondkey] ~= true then
		for i, down in pairs(self.keydowns) do
			if down then
				if self.keydowns[self.basekey] ~= true then
					print (string.format("base key = %d", i))
					self.basekey = i
				elseif i ~= self.basekey then
					print (string.format("second key = %d", i))
					self.secondkey = i
					break
				end
			end
		end

		-- no base key
		if self.keydowns[self.basekey] ~= true then
			self.basekey = 99
		end
		if self.keydowns[self.secondkey] ~= true then
			self.secondkey = 98
		end
	end
			
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

	self.keydowns = {}
	self.keydowns[1] = self.L
	self.keydowns[2] = self.R 
	self.keydowns[3] = self.U
	self.keydowns[4] = self.D

	self.basekey = 99
	self.secondkey = 99
end
