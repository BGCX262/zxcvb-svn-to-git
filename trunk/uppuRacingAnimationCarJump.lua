class 'uppuRacingAnimationCarJump'

function uppuRacingAnimationCarJump:__init(car, filename)
	self.car = car
	self.image = self:LoadImage(filename)
	self.animating = false
	self.phase = 0
end

function uppuRacingAnimationCarJump:LoadImage(filename)
	local frame = Image()
	frame:LoadControlImage(filename, 4, 5, nil, UIConst.Blue)
	frame:SetImageIndex(3)
	frame:Show(false)

	Scene.latestScene:AddChild(frame)

	return frame
end

function uppuRacingAnimationCarJump:Play()
	if self.animating == false then
		self.animating = true
	
		self.image:SetXPivot(self.image:GetWidth()/2)
		self.image:SetYPivot(self.image:GetHeight()/2)
		self.image:SetXYPos(self.car:GetXPos() - self.image:GetWidth()/2, self.car:GetYPos() - self.image:GetHeight()/2)	-- -32, -35
		self.image:SetRotate(math.deg(self.car:GetAngle()))
		self.image:Show(true)
		self.image:ScaleTo(CAR_JUMP_SCALE, CAR_JUMP_SCALE, CAR_JUMP_DURATION/2)

		self.phase = 1
	end
end

function uppuRacingAnimationCarJump:Update(elapsed)
	if self.phase == 1 and self.image:GetXScale() >= CAR_JUMP_SCALE then
		self.image:ScaleTo(1, 1, CAR_JUMP_DURATION/2)

		self.phase = 2
	elseif self.phase == 2 and self.image:GetXScale() == 1 then
		self:Reset()

		self.phase = 0
	end

	self.image:SetXYPos(self.car:GetXPos() - self.image:GetWidth()/2, self.car:GetYPos() - self.image:GetHeight()/2)
	self.image:SetRotate(math.deg(self.car:GetAngle()))
end

function uppuRacingAnimationCarJump:Reset()
	self.image:SetImageIndex(0)
	self.image:StopAnimation()
	self.image:Show(false)
	self.animating = false

	self.image:SetXScale(1)
	self.image:SetYScale(1)
	self.phase = 0
end

function uppuRacingAnimationCarJump:IsAnimating()
	return self.animating
end
