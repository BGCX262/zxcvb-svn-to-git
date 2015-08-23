class 'uppuRacingAnimationBooster'

function uppuRacingAnimationBooster:__init(car)
	self.car = car
	self.image = self:LoadImage()
	self.animating = false
end

function uppuRacingAnimationBooster:LoadImage()
	local frame = Scene.latestScene["imageBooster"]:Clone()
	frame:Show(false)

	Scene.latestScene:AddChild(frame)

	self.driftImageLeft = Scene.latestScene["imageDrift"]:Clone()
	self.driftImageRight = Scene.latestScene["imageDrift"]:Clone()

	Scene.latestScene:AddChild(self.driftImageLeft)
	Scene.latestScene:AddChild(self.driftImageRight)

	return frame
end

function uppuRacingAnimationBooster:Play()
	if self.animating == false then
		self.animating = true
	
		self.image:SetXPivot(self.image:GetWidth()/2)
		self.image:SetYPivot(self.image:GetHeight()/2)
		self.image:SetXYPos(self.car:GetXPos() - self.image:GetWidth()/2, self.car:GetYPos() - self.image:GetHeight()/2)	-- -32, -35
		self.image:SetRotate(math.deg(self.car:GetAngle()))
		self.image:Show(true)
		self.image:AnimateImage(0, 7, 0.3, 2)

		-- car image
		self.car.image:AnimateStaticImage(8, 9, 0.6, 2)

		local leftDriftOffset = b2Vec2(0, 70)
		local rightDriftOffset = b2Vec2(58, 70)

		---- drift image
		--self.driftImageLeft:SetXYPos(self.image:GetXPos(), self.image:GetYPos() + 70)
		--self.driftImageLeft:SetRotate(math.deg(self.car:GetAngle()))
		--self.driftImageLeft:AnimateStaticImage(0, 4, 0.3, 2)
		--self.driftImageLeft:Show(true)
  --
		--self.driftImageRight:SetXYPos(self.image:GetXPos() + 58, self.image:GetYPos() + 70)
		--self.driftImageRight:SetFlip(true, false)
		--self.driftImageRight:SetRotate(math.deg(self.car:GetAngle()))
		--self.driftImageRight:AnimateStaticImage(0, 4, 0.3, 2)
		--self.driftImageRight:Show(true)
	end
end

function uppuRacingAnimationBooster:Update(elapsed)
	if self.image:GetImageIndex() >= self.image:GetImageCount()-1 then
		self:Reset()
	end

	self.image:SetXYPos(self.car:GetXPos() - self.image:GetWidth()/2, self.car:GetYPos() - self.image:GetHeight()/2)
	self.image:SetRotate(math.deg(self.car:GetAngle()))

	--local leftDriftOffset = b2Vec2(0, 70)
	--local rightDriftOffset = b2Vec2(58, 70)
	--local angle = VectorRotate(leftDriftOffset, self.car:GetAngle())
 --
	--self.driftImageLeft:SetXYPos(self.image:GetXPos() + leftDriftOffset.x, self.image:GetYPos() + leftDriftOffset.y)
	--self.driftImageLeft:SetRotate(math.deg(self.car:GetAngle()))
 --
	--self.driftImageRight:SetXYPos(self.image:GetXPos() + 58, self.image:GetYPos() + 70)
	--self.driftImageRight:SetRotate(math.deg(self.car:GetAngle()))
end

function uppuRacingAnimationBooster:Reset()
	self.image:SetImageIndex(0)
	self.image:StopAnimation()
	self.image:Show(false)
	self.animating = false

	-- reset car image
	self.car.image:AnimateStaticImage(0, 3, 1, -1)

	-- reset drift image
	self.driftImageLeft:Show(false)
	self.driftImageRight:Show(false)
end

function uppuRacingAnimationBooster:IsAnimating()
	return self.animating
end
