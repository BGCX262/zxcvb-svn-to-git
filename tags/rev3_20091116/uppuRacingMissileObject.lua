require "uppuRacingObject"

class 'uppuRacingMissileObject' (uppuRacingObject)

function uppuRacingMissileObject:__init(world, car) super(car.owner, CLASS_MASTER)
	self.oid = car.oid+1
	self.world = world

	self.car = car			-- set owner car

	-- for master
	self.body = self:CreateBody(car.body:GetPosition(), car.body:GetAngle())
	self.body:SetUserData(self)
	self.prevBodyPos = b2Vec2(car.body:GetPosition().x, car.body:GetPosition().y)
	self.prevBodyAngle = car.body:GetAngle()
end

function uppuRacingMissileObject:CreateBody(pos, angle)
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

	-- missile 물리 객체 생성
	local missileDef = b2BodyDef()
	missileDef.position:Set(pos.x, pos.y)
	missileDef.isBullet = true
	missileDef.linearDamping = 0
	missileDef.angularDamping = 0
	local objectBody = self.world:CreateBody( missileDef )

	local missileShapeDef = b2PolygonDef()
	missileShapeDef:SetAsBox( 7, 15 )			-- 14 x 30
	missileShapeDef.density = 1

	objectBody:CreateShape( missileShapeDef )
	objectBody:SetMassFromShapes()

	-- set angle and velocity
	objectBody:SetXForm(pos, angle)

	local vel = b2Vec2( math.cos( math.pi/2 - angle ), -math.sin( math.pi/2 - angle ) )
	self:Multiply( vel, MISSILE_INITIAL_VELOCITY )
	objectBody:SetLinearVelocity( vel )	

	self:SetMissile()
	return objectBody
end

function uppuRacingMissileObject:Sync(owner, oid, pos0, r0, v0, vr)
	self.body:SetXForm(pos0, r0)
	self.body:SetLinearVelocity(v0)
	-- set vel, vr
end

function uppuRacingMissileObject:Update(elapsed)
	assert(self.image)
	assert(self.body)

	local x = self.body:GetPosition().x - self.image:GetWidth()/2
	local y = self.body:GetPosition().y - self.image:GetHeight()/2
	local angle = math.deg( self.body:GetAngle() )

	self.image:SetXYPos(x, y)
	self.image:SetRotate(angle)
end
