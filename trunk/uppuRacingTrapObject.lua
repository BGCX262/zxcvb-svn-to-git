require "uppuRacingObject"

class 'uppuRacingTrapObject' (uppuRacingObject)

function uppuRacingTrapObject:__init(world, pos, angle, image) super(0, CLASS_SLAVE)
	self.owner = -1
	self.world = world
	self.trap = true

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

function uppuRacingTrapObject:Destroy()
	self.world:DestroyBody(self.body)
	self.body = nil

	Scene.latestScene:RemoveChild(self.image)

	self.prevBodyPos = nil
	self.prevBodyAngle = 0
	self.car = nil
	self.world = nil
	self.image = nil
end

function uppuRacingTrapObject:CreateBody(pos, angle, image)
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
					
	local objectShapeDef = b2CircleDef()
	objectShapeDef.radius = TILE_SIZE_X/4
	objectShapeDef.isSensor = true
	
	local objectBody = self.world:CreateBody(objectDef)
	objectBody:CreateShape(objectShapeDef)

	--self:SetLowWall(objectBody)
	return objectBody
end

function uppuRacingTrapObject:Update(elapsed)
	--assert(self.image)
	--assert(self.body)
 --
	--local x = self.body:GetPosition().x - self.image:GetWidth()/2
	--local y = self.body:GetPosition().y - self.image:GetHeight()/2
	--local angle = math.deg( self.body:GetAngle() )
 --
	--self.image:SetXYPos(x, y)
	--self.image:SetRotate(angle)
end
