require "uppuRacingObject"

class 'uppuRacingMissileObject' (uppuRacingObject)

function uppuRacingMissileObject:__init(world, car, oid) super(car.owner, CLASS_MASTER, world)
	self.oid = oid
	self.world = world
	self.classname = "uppuRacingMissileObject"
	self.deleteAnimation = true

	self.car = car			-- set owner car

	-- for master
	self.body = self:CreateBody(car.body:GetPosition(), car.body:GetAngle())
	self.body:SetUserData(self)
	self.prevBodyPos = b2Vec2(car.body:GetPosition().x, car.body:GetPosition().y)
	self.prevBodyAngle = car.body:GetAngle()

	-- for delayed delete
	self.delayedDelete = true
	self.canDelete = false

	self.animBoom = Scene.latestScene["imageBombBox"]:Clone()
	self.animBoom:Show(false)
	--self.car.scene:AddChild(self.animBoom)
end

function uppuRacingMissileObject:Destroy()
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
	local object = Scene.latestScene["imageMissile"]:Clone()
	self.image = object
	--self.image:EnableCollision(true)

	local objectWidth = object:GetWidth()
	local objectHeight = object:GetHeight()

	object:SetXPos(pos.x - objectWidth/2)
	object:SetYPos(pos.y - objectHeight/2)
	object:SetXPivot(objectWidth/2)
	object:SetYPivot(objectHeight/2)
	object:AnimateImage(0, 3, 0.6, -1)
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
	missileShapeDef.density = MISSILE_DENSITY

	objectBody:CreateShape(missileShapeDef)
	objectBody:SetMassFromShapes()
	objectBody:SetUserData(self)

	-- set angle and velocity
	objectBody:SetXForm(pos, angle)

	local vel = b2Vec2( math.cos( math.pi/2 - angle ), -math.sin( math.pi/2 - angle ) )
	Multiply( vel, MISSILE_INITIAL_VELOCITY )
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
	-- delete missile boom image
	if self.animBoom:GetImageIndex() >= self.animBoom:GetImageCount()-1 then
		self.animBoom:StopAnimation()
		self.animBoom:Show(false)
		self.canDelete = true
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

		return true
	end

	return false
end

function uppuRacingMissileObject:AnimateDeletingObject(pos)
	self:AnimateMissileBoom(pos)
end
