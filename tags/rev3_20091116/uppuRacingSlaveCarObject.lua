require "uppuRacingObject"

class 'uppuRacingSlaveCarObject' (uppuRacingObject)

function uppuRacingSlaveCarObject:__init(name, owner, oid, pos, angle, vel, cartype) super(owner, CLASS_SLAVE)
	self.oid = oid

	-- for slave
	self.imagePos = pos
	self.imageAngle = angle
	self.imageVel = vel

	self.name = name
	self.cartype = cartype
	self.image = self:LoadImage()
end

function uppuRacingSlaveCarObject:LoadImage()
	local frame = Image()

	frame:LoadControlImage(CAR_IMAGE[self.cartype][self.owner], 4, 5, nil, UIConst.Blue)	-- 70x70 이미지
	Scene.latestScene:AddChild(frame)

	frame:AnimateImage(0, 3, 1, -1)

	local imageWidth = frame:GetWidth()
	local imageHeight = frame:GetHeight()

	--frame:SetStaticImageIndex(0)
	frame:SetXPivot(imageWidth/2)
	frame:SetYPivot(imageHeight/2)
	frame:SetXPos(self.imagePos.x)
	frame:SetYPos(self.imagePos.y)

	frame:Show(true)

	return frame
end

function uppuRacingSlaveCarObject:Sync(owner, oid, pos0, r0, v0, vr)
	self.imagePos.x = pos0.x - 35
	self.imagePos.y = pos0.y - 35
	self.imageAngle = r0
end

function uppuRacingSlaveCarObject:Update(elapsed)
	assert(self.image)

	self.image:SetXPos(self.imagePos.x)
	self.image:SetYPos(self.imagePos.y)
	self.image:SetRotate(math.deg(self.imageAngle))
end

function uppuRacingSlaveCarObject:Destroy()
	self.image:Show(false)
	self.image:Enable(false)
end
