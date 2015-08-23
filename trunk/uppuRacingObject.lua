require "uppuRacingConsts"

class 'uppuRacingObject'

function uppuRacingObject:__init(owner, classtype, world)
	assert(owner ~= nil)

	self.owner = owner
	self.classtype = classtype
	self.oid = nil				-- object id
	self.world = world			-- box2d world
	self.image = nil			-- image object (static image, image, Hsv, sprite, ...)
	self.forceDirty = false		-- force dirty
	self.classname = nil
	self.deleteAnimation = false
	self.nofriction = false		-- friction = true

	-- for master
	self.body = nil
	self.prevBodyPos = nil		-- position of prev frame (vec2)
	self.prevBodyAngle = nil	-- angle of prev frame (radian)

	-- for slave
	self.imagePos = nil			-- position of slave object (vec2)
	self.imageAngle = nil		-- angle of slave object (radian)
	self.imageVel = nil			-- velocity of slave object (vec2)

	-- for delayed delete
	self.delayedDelete = false
	self.canDelete = false
end

function uppuRacingObject:DelayedDelete()
	return self.delayedDelete
end

function uppuRacingObject:CanDelete()
	return self.canDelete
end

-- for master
function uppuRacingObject:DeltaDistance()
	local vec1 = self.body:GetPosition()
	local vec2 = self.prevBodyPos
	local dist = math.sqrt( math.pow(vec2.x-vec1.x, 2) + math.pow(vec2.y-vec1.y, 2) )
	return dist
end

function uppuRacingObject:DeltaAngle()
	return math.abs(self.body:GetAngle() - self.prevBodyAngle)
end

function uppuRacingObject:GetClassName()
	return self.classname
end

function uppuRacingObject:SetDirty()
	self.forceDirty	= true
end

function uppuRacingObject:IsDirty()
	-- forceDirty가 true이면 강제로 dirty true 리턴하고 forceDirty를 다시 false로 셋팅
	if self.forceDirty then
		self.forceDirty	= false
		return true
	end

	if self.body == nil then
		return false
	end

	if self.prevBodyPos == nil and self.body then
		return true
	end

	if self:DeltaDistance() >= DISTANCE_THRESHOLD or self:DeltaAngle() >= ANGLE_THRESHOLD then
		return true
	else
		return false
	end
end

function uppuRacingObject:SetSyncMessage(owner, event, msg)
	if owner == nil then
		event:SetNValue(msg.key.n, self.owner)
	else
		event:SetNValue(msg.key.n, owner)
	end

	event:SetNValue(msg.key.x, self.body:GetPosition().x)
	event:SetNValue(msg.key.y, self.body:GetPosition().y)
	event:SetValue(msg.key.r, self.body:GetAngle())
	event:SetNValue(msg.key.X, self.body:GetLinearVelocity().x)
	event:SetNValue(msg.key.Y, self.body:GetLinearVelocity().y)
	--event:SetNValue(msg.key.R, self.body:GetAngularVelocity())
	event:SetNValue(msg.key.o, self.oid)
	event:SetNValue(msg.key.c, self.classtype)

	return event
end

function uppuRacingObject:MakeMessageObject_Create(owner)
	print ("create")

	local event = Message(Object_Create)
	return self:SetSyncMessage(owner, event, Object_Create)
end

function uppuRacingObject:MakeMessageObject_Sync(owner)
	local event = Message(Object_Sync)
	return self:SetSyncMessage(owner, event, Object_Sync)
end

function uppuRacingObject:MakeMessageObject_Delete()
	print ("delete")

	local event = Message(Object_Delete)
	return self:SetSyncMessage(owner, event, Object_Delete)
end

----------------------------------
-- set box2d collision property
----------------------------------
function uppuRacingObject:SetLowWall(body)
	local filterData = b2FilterData()
	filterData.groupIndex = 0

	filterData.maskBits = COLLISION_FILTER_MASK_LOWWALL
	filterData.categoryBits = COLLISION_FILTER_CATEGORY_LOWWALL

	local shape = body:GetShapeList()
	shape:SetFilterData(filterData)
end

function uppuRacingObject:SetHighWall(body)
	local filterData = b2FilterData()
	filterData.groupIndex = 0

	filterData.maskBits = COLLISION_FILTER_MASK_HIGHWALL
	filterData.categoryBits = COLLISION_FILTER_CATEGORY_HIGHWALL

	local shape = body:GetShapeList()
	shape:SetFilterData(filterData)
end

function uppuRacingObject:SetMissile(body)
	local filterData = b2FilterData()
	filterData.groupIndex = 0

	filterData.maskBits = COLLISION_FILTER_MASK_MISSILE
	filterData.categoryBits = COLLISION_FILTER_CATEGORY_MISSILE

	local shape = body:GetShapeList()
	shape:SetFilterData(filterData)

	self.world:Refilter(shape)
end

function uppuRacingObject:SetNoCollision(body)
	local filterData = b2FilterData()
	filterData.groupIndex = 0

	filterData.maskBits = COLLISION_FILTER_MASK_NOCOLLISION
	filterData.categoryBits = COLLISION_FILTER_CATEGORY_PLANE

	local shape = body:GetShapeList()
	shape:SetFilterData(filterData)

	self.world:Refilter(shape)
end

function uppuRacingObject:Force(pos, force)
	if self.body ~= nil then
		self.body:ApplyForce(force, pos)
	end
end

-- b2Vec2 . b2Vec2
function uppuRacingObject:VectorDot(avec, bvec)
	return avec.x * bvec.x + avec.y * bvec.y;
end
