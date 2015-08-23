require "go.ui.control.StaticImage"
require "uppuRacingObject"

class 'uppuRacingLowBlockObject' (uppuRacingObject)

function uppuRacingLowBlockObject:__init(world, pos, angle, isCircle, image) super(0, CLASS_SLAVE)
	self.oid = -1	-- no owner
	self.world = world
	self.image = image
	self.isCircle = isCircle
	self.body = self:CreateBody(pos, angle)
end

function uppuRacingLowBlockObject:Destroy()
	self.world:DestroyBody(self.body)
	self.body = nil

	Scene.latestScene:RemoveChild(self.image)

	self.prevBodyPos = nil
	self.prevBodyAngle = 0
	self.world = nil
	self.image = nil
end

function uppuRacingLowBlockObject:CreateBody(pos, angle)
	local object = self.image

	Scene.latestScene:AddChild(object)

	local objectWidth = object:GetWidth()
	local objectHeight = object:GetHeight()

	object:SetXPos(pos.x)
	object:SetYPos(pos.y)
	object:SetXPivot(objectWidth/2)
	object:SetYPivot(objectHeight/2)
	object:Show(true)

	-- low wall 물리 객체 생성
	local groundBodyDef = b2BodyDef()
	groundBodyDef.position:Set(pos.x + objectWidth/2, pos.y + objectHeight/2)

	local groundShapeDef = nil
	if self.isCircle then
		groundShapeDef = b2CircleDef()
		groundShapeDef.radius = objectWidth/2
	else
		groundShapeDef = b2PolygonDef()
		groundShapeDef:SetAsBox(objectWidth/2, objectHeight/2)
	end

	local groundBody1 = self.world:CreateBody(groundBodyDef)
	groundBody1:CreateShape(groundShapeDef)

	self:SetLowWall(groundBody1)
	return groundBody1
end
