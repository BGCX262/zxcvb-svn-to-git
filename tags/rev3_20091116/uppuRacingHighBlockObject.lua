require "go.ui.control.StaticImage"
require "uppuRacingObject"

class 'uppuRacingHighBlockObject' (uppuRacingObject)

function uppuRacingHighBlockObject:__init(world, pos, angle, image) super(0, CLASS_NPO)
	self.oid = -1	-- no owner
	self.world = world
	self.image = image

	-- for master
	self.body = self:CreateBody(pos, angle)
	--self.prevBodyPos = pos
	--self.prevBodyAngle = angle

	-- for slave
	--self.pos = pos
	--self.angle = angle
	--self.vel = b2Vec2(0, 0)
end

function uppuRacingHighBlockObject:CreateBody(pos, angle)
	local object = self.image

	Scene.latestScene:AddChild(object)

	local objectWidth = object:GetWidth()
	local objectHeight = object:GetHeight()

	object:SetXPos(pos.x)
	object:SetYPos(pos.y)
	object:SetXPivot(objectWidth/2)
	object:SetYPivot(objectHeight/2)
	object:Show(true)

	-- high wall 물리 객체 생성
	local groundBodyDef = b2BodyDef()
	groundBodyDef.position:Set(pos.x + objectWidth/2, pos.y + objectHeight/2)

	local groundShapeDef = b2PolygonDef()
	groundShapeDef:SetAsBox(objectWidth/2, objectHeight/2)

	local groundBody1 = self.world:CreateBody(groundBodyDef)
	groundBody1:CreateShape(groundShapeDef)

	self:SetHighWall(groundBody1)
	return groundBody1
end
