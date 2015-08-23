require "uppuRacingObject"

class 'uppuRacingMissileObject' (uppuRacingObject)

function uppuRacingMissileObject:__init(world, car) super(car.owner, CLASS_MASTER, world)
	self.oid = car.oid+1
	self.world = world

	self.car = car			-- set owner car
	self.delete = false

	-- for master
	self.body = self:CreateBody(car.body:GetPosition(), car.body:GetAngle())
	self.body:SetUserData(self)
	self.prevBodyPos = b2Vec2(car.body:GetPosition().x, car.body:GetPosition().y)
	self.prevBodyAngle = car.body:GetAngle()

	self.animBoom = Image()
	self.animBoom:LoadControlImage("images/ido_up_ef_012.bmp", 5, 2, nil, UIConst.Blue)	-- 70x70 이미지
	self.animBoom:Show(false)
	self.car.scene:AddChild(self.animBoom)
end

function uppuRacingMissileObject:Destroy()
	self.delete = true
end

function uppuRacingMissileObject:InternalDestroy()
	self.world:DestroyBody(self.body)
	self.body = nil

	self.car.scene:RemoveChild(self.image)
	self.car:DestroyMissile()

	self.car.scene:RemoveChild(self.animBoom)
	self.animBoom = nil

	self.prevBodyPos = nil
	self.prevBodyAngle = 0
	self.car = nil
	self.world = nil
	self.image = nil
end

function uppuRacingMissileObject:CreateBody(pos, angle)
	local object = StaticImage()
	self.image = object

	object:LoadStaticImage("images/ido_up_ob_001.bmp", 4, 6, nil, UIConst.Blue)

	self.car.scene:AddChild(object)

	local objectWidth = object:GetWidth()
	local objectHeight = object:GetHeight()

	object:SetXPos(pos.x - objectWidth/2)
	object:SetYPos(pos.y - objectHeight/2)
	object:SetXPivot(objectWidth/2)
	object:SetYPivot(objectHeight/2)
	object:AnimateStaticImage(0, 3, 0.6, -1)
	object:Show(true)

	-- missile 물리 객체 생성
	local missileDef = b2BodyDef()
	missileDef.position:Set(pos.x, pos.y)
	missileDef.isBullet = true
	missileDef.linearDamping = 0
	missileDef.angularDamping = 0
	local objectBody = self.world:CreateBody(missileDef)

	local missileShapeDef = b2PolygonDef()
	missileShapeDef:SetAsBox(7, 15)			-- 14 x 30
	missileShapeDef.density = 1

	objectBody:CreateShape(missileShapeDef)
	objectBody:SetMassFromShapes()
	objectBody:SetUserData(self)

	-- set angle and velocity
	objectBody:SetXForm(pos, angle)

	local vel = b2Vec2( math.cos( math.pi/2 - angle ), -math.sin( math.pi/2 - angle ) )
	self:Multiply( vel, MISSILE_INITIAL_VELOCITY )
	objectBody:SetLinearVelocity( vel )	

	self:SetMissile(objectBody)
	return objectBody
end

function uppuRacingMissileObject:Sync(owner, oid, pos0, r0, v0, vr)
	self.body:SetXForm(pos0, r0)
	self.body:SetLinearVelocity(v0)
	-- set vel, vr
end

function uppuRacingMissileObject:Update(elapsed)
	if self.delete and self.animBoom:IsAnimating() == false then
		self:InternalDestroy()
		self.delete = false
		return
	end

	-- delete missile image
	if self.animBoom:GetImageIndex() >= self.animBoom:GetImageCount()-1 then
		self.animBoom:StopAnimation()
		self.animBoom:Show(false)
	end

	if self.image and self.body then
		local x = self.body:GetPosition().x - self.image:GetWidth()/2
		local y = self.body:GetPosition().y - self.image:GetHeight()/2
		local angle = math.deg(self.body:GetAngle())
	
		self.image:SetXYPos(x, y)
		self.image:SetRotate(angle)
	end
end

function uppuRacingMissileObject:AnimateMissileBoom(pos)
	local x = pos.x - self.animBoom:GetWidth()/2
	local y = pos.y - self.animBoom:GetHeight()/2

	if self.animBoom:IsAnimating() == false then
		-- hide missile image
		self.image:Show(false)

		-- boom animation
		self.animBoom:SetXYPos( x, y )
		self.animBoom:AnimateImage(4, 9, 0.5, 1)
		self.animBoom:Show(true)
	end
end
