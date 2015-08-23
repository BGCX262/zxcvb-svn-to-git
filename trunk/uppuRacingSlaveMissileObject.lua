require "uppuRacingObject"

class 'uppuRacingSlaveMissileObject' (uppuRacingObject)

function uppuRacingSlaveMissileObject:__init(owner, oid, pos, angle, vel) super(owner, CLASS_SLAVE)
	self.oid = oid
	self.classname = "uppuRacingSlaveMissileObject"
	self.deleteAnimation = true

	-- for slave
	self.imagePos = pos
	self.imageAngle = angle
	self.imageVel = vel
	self.image = self:LoadImage()

	-- for missile boom
	self.animBoom = Scene.latestScene["imageBombBox"]:Clone()
	self.animBoom:Show(false)

	-- for delayed delete
	self.delayedDelete = true
	self.canDelete = false
end

function uppuRacingSlaveMissileObject:LoadImage()
	local object = Scene.latestScene["imageMissile"]:Clone()
	local objectWidth = object:GetWidth()
	local objectHeight = object:GetHeight()

	object:SetXPivot(objectWidth/2)
	object:SetYPivot(objectHeight/2)
	object:SetXPos(self.imagePos.x - objectWidth/2)
	object:SetYPos(self.imagePos.y - objectHeight/2)
	object:AnimateImage(0, 3, 0.6, -1)
	object:Show(true)

	return object
end

function uppuRacingSlaveMissileObject:Sync(owner, oid, pos0, r0, v0, vr)
	self.imagePos.x = pos0.x
	self.imagePos.y = pos0.y
	self.imageAngle = r0
end

function uppuRacingSlaveMissileObject:Update(elapsed)
	-- delete missile boom image
	if self.animBoom:GetImageIndex() >= self.animBoom:GetImageCount()-1 then
		self.animBoom:StopAnimation()
		self.animBoom:Show(false)
		self.canDelete = true
	end

	assert(self.image)

	local objectWidth = self.image:GetWidth()
	local objectHeight = self.image:GetHeight()

	self.image:SetXPos(self.imagePos.x - objectWidth/2)
	self.image:SetYPos(self.imagePos.y - objectHeight/2)
	self.image:SetRotate(math.deg(self.imageAngle))
end

function uppuRacingSlaveMissileObject:Destroy()
	self.image:Show(false)
	self.animBoom:Show(false)

	Scene.latestScene:RemoveChild(self.image)
	Scene.latestScene:RemoveChild(self.animBoom)

	self.image = nil
	self.animBoom = nil
end

function uppuRacingSlaveMissileObject:AnimateMissileBoom(pos)
	local x = pos.x - self.animBoom:GetWidth()/2
	local y = pos.y - self.animBoom:GetHeight()/2

	if self.animBoom:IsAnimating() == false then
		-- hide missile image
		self.image:Show(false)

		-- boom animation
		self.animBoom:SetXYPos(x, y)
		self.animBoom:AnimateImage(4, 9, 0.5, 1)
		self.animBoom:Show(true)
	end
end

function uppuRacingSlaveMissileObject:AnimateDeletingObject(pos)
	self:AnimateMissileBoom(pos)
end
