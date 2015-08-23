require "uppuRacingObject"

class 'uppuRacingBombBoxObject' (uppuRacingObject)

function uppuRacingBombBoxObject:__init(world, oid, pos, angle) super(0, CLASS_NPO)
	self.oid = oid
	self.world = world
	self.classname = "uppuRacingBombBoxObject"
	self.deleteAnimation = true

	-- for master
	self.body = self:CreateBody(pos, angle)
	self.body:SetUserData(self)
	self.prevBodyPos = b2Vec2(pos.x + TILE_SIZE_X/2, pos.y + TILE_SIZE_Y/2)
	self.prevBodyAngle = angle

	-- for slave
	self.imagePos = pos
	self.imageAngle = angle
	self.imageVel = b2Vec2(0, 0)

	-- for delayed delete
	self.delayedDelete = true
	self.canDelete = false

	self.boom = false
end

function uppuRacingBombBoxObject:Destroy()
	-- already destroyed
	if self.world == nil then
		return
	end

	self.world:DestroyBody(self.body)
	self.body = nil

	Scene.latestScene:RemoveChild(self.image)

	self.prevBodyPos = nil
	self.prevBodyAngle = 0
	self.car = nil
	self.world = nil
	self.image = nil
end

function uppuRacingBombBoxObject:CreateBody(pos, angle)
	local object = Scene.latestScene["imageBombBox"]:Clone()
	Scene.latestScene:AddChild(object)
	self.image = object

	local objectWidth = object:GetWidth()
	local objectHeight = object:GetHeight()

	object:SetXPos(pos.x)
	object:SetYPos(pos.y)
	object:SetXPivot(objectWidth/2)
	object:SetYPivot(objectHeight/2)
	object:SetImageIndex(0)
	object:Show(true)

	-- 물리 객체 생성
	local objectDef = b2BodyDef()
	objectDef.position:Set(pos.x + TILE_SIZE_X/2, pos.y + TILE_SIZE_Y/2)
					
	local objectShapeDef = b2PolygonDef()
	objectShapeDef:SetAsBox(TILE_SIZE_X/2, TILE_SIZE_Y/2)	-- 60x60
	
	local objectBody = self.world:CreateBody(objectDef)
	objectBody:CreateShape(objectShapeDef)

	self:SetLowWall(objectBody)
	return objectBody
end

function uppuRacingBombBoxObject:Sync(owner, oid, pos0, r0, v0, vr)
	--self.body:SetXForm(pos0, r0)
	--self.body:SetLinearVelocity(v0)
	-- set vel, vr
end

function uppuRacingBombBoxObject:Update(elapsed)
	assert(self.image)
	assert(self.body)

	local x = self.body:GetPosition().x - self.image:GetWidth()/2
	local y = self.body:GetPosition().y - self.image:GetHeight()/2
	local angle = math.deg( self.body:GetAngle() )

	self.image:SetXYPos(x, y)
	self.image:SetRotate(angle)
	if self.boom == false and self.image:IsAnimating() == false then
		self.image:AnimateImage(0, 2, 1, -1)
	elseif self.boom == true and self.image:IsAnimating() == false then
		-- destroyed on next frame
		self.canDelete = true
	end
end

function uppuRacingBombBoxObject:AnimateBoom()
	self:SetNoCollision(self.body)

	self.boom = true

	--self.image:StopAnimation()
	self.image:SetImageIndex(0)
	self.image:AnimateImage(0, 9, 1, 1)
end

function uppuRacingBombBoxObject:AnimateDeletingObject(pos)
	self:AnimateBoom()
end
