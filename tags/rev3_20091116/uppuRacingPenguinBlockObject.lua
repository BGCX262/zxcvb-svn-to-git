require "uppuRacingObject"

class 'uppuRacingPenguinBlockObject' (uppuRacingObject)

function uppuRacingPenguinBlockObject:__init(world, oid, pos, angle) super(0, CLASS_NPO)
	self.oid = oid
	self.world = world

	-- for master
	self.body = self:CreateBody(pos, angle)
	self.body:SetUserData(self)
	self.prevBodyPos = b2Vec2(pos.x + TILE_SIZE_X/2, pos.y + TILE_SIZE_Y/2)
	self.prevBodyAngle = angle

	-- for slave
	self.imagePos = pos
	self.imageAngle = angle
	self.imageVel = b2Vec2(0, 0)
end

function uppuRacingPenguinBlockObject:CreateBody(pos, angle)
	-- 펭귄 스프라이트 로딩
	local object = Hsv()
	self.image = object

	object:LoadHsv("images/ice_penguin.hsv")
	-- BUG: width랑 height가 10으로 나오네? 강제로 60으로 셋팅
	object:SetHeight(TILE_SIZE_X)
	object:SetWidth(TILE_SIZE_Y)

	Scene.latestScene:AddChild(object)

	local objectWidth = object:GetWidth()
	local objectHeight = object:GetHeight()

	object:SetXPos(pos.x)
	object:SetYPos(pos.y)
	object:SetXPivot( objectWidth/2 )
	object:SetYPivot( objectHeight/2 )
	object:Play(-1)
	object:Show(true)

	-- 펭귄 물리 객체 생성
	local objectDef = b2BodyDef()
	objectDef.position:Set(pos.x + TILE_SIZE_X/2, pos.y + TILE_SIZE_Y/2)
	objectDef.linearDamping = 0.8
	objectDef.angularDamping = 0.8
					
	local objectShapeDef = b2PolygonDef()
	objectShapeDef:SetAsBox(TILE_SIZE_X/2, TILE_SIZE_Y/2)	-- 60x60
	objectShapeDef.density = 0.2
	objectShapeDef.restitution = 0.3
	
	local objectBody = self.world:CreateBody(objectDef)
	objectBody:CreateShape(objectShapeDef)
	objectBody:SetMassFromShapes()

	self:SetLowWall(objectBody)
	return objectBody
end

function uppuRacingPenguinBlockObject:Sync(owner, oid, pos0, r0, v0, vr)
	self.body:SetXForm(pos0, r0)
	self.body:SetLinearVelocity(v0)
	-- set vel, vr
end

function uppuRacingPenguinBlockObject:Update(elapsed)
	assert(self.image)
	assert(self.body)

	local x = self.body:GetPosition().x - self.image:GetWidth()/2
	local y = self.body:GetPosition().y - self.image:GetHeight()/2
	local angle = math.deg( self.body:GetAngle() )

	self.image:SetXYPos(x, y)
	self.image:SetRotate(angle)
end
