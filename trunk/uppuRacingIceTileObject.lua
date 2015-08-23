require "uppuRacingObject"

class 'uppuRacingIceTileObject' (uppuRacingObject)

function uppuRacingIceTileObject:__init(world, pos, angle, image) super(0, CLASS_SLAVE)
	self.owner = -1
	self.world = world
	self.icetile = true

	-- for master
	self.body = self:CreateBody(pos, angle, image)
	self.body:SetUserData(self)
	self.prevBodyPos = b2Vec2(pos.x + TILE_SIZE_X/2, pos.y + TILE_SIZE_Y/2)
	self.prevBodyAngle = angle

	-- for slave
	self.image = image
	self.imagePos = pos
	self.imageAngle = angle
--	self.imageVel = b2Vec2(0, 0)
end

function uppuRacingIceTileObject:Destroy()
	self.world:DestroyBody(self.body)
	self.body = nil

	Scene.latestScene:RemoveChild(self.image)

	self.prevBodyPos = nil
	self.prevBodyAngle = 0
	self.world = nil
	self.image = nil
end

function uppuRacingIceTileObject:CreateBody(pos, angle, image)
	local object = image

	Scene.latestScene:AddChild(object)

	local objectWidth = object:GetWidth()
	local objectHeight = object:GetHeight()

	object:SetXPos(pos.x)
	object:SetYPos(pos.y)
	object:SetXPivot( objectWidth/2 )
	object:SetYPivot( objectHeight/2 )
	object:Show(true)

	-- 물리 객체 생성
	local objectDef = b2BodyDef()
	objectDef.position:Set(pos.x + TILE_SIZE_X/2, pos.y + TILE_SIZE_Y/2)
					
	local objectShapeDef = b2PolygonDef()
	objectShapeDef:SetAsBox(TILE_SIZE_X/2, TILE_SIZE_Y/2)
	objectShapeDef.isSensor = true
	
	local objectBody = self.world:CreateBody(objectDef)
	objectBody:CreateShape(objectShapeDef)

	return objectBody
end

function uppuRacingIceTileObject:Update(elapsed)
end
