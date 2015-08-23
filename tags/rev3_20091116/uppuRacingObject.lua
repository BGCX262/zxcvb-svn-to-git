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

	-- for master
	self.body = nil
	self.prevBodyPos = nil		-- position of prev frame (vec2)
	self.prevBodyAngle = nil	-- angle of prev frame (radian)

	-- for slave
	self.imagePos = nil			-- position of slave object (vec2)
	self.imageAngle = nil		-- angle of slave object (radian)
	self.imageVel = nil			-- velocity of slave object (vec2)
end

-- for master
function uppuRacingObject:VectorDistance(vec1, vec2)
	local dist = math.sqrt( math.pow(vec2.x-vec1.x, 2) + math.pow(vec2.y-vec1.y, 2) )
	return dist
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

	if self:VectorDistance(self.body:GetPosition(), self.prevBodyPos) >= 10 then
		return true
	else
		return false
	end
end

function uppuRacingObject:MakeMessageObject_Sync(owner)
	local event = Message(Object_Sync)
	if owner == nil then
		event:SetNValue(Object_Sync.key.n, self.owner)
	else
		event:SetNValue(Object_Sync.key.n, owner)
	end

	event:SetNValue(Object_Sync.key.x, self.body:GetPosition().x)
	event:SetNValue(Object_Sync.key.y, self.body:GetPosition().y)
	event:SetValue(Object_Sync.key.r, self.body:GetAngle())
	event:SetNValue(Object_Sync.key.X, self.body:GetLinearVelocity().x)
	event:SetNValue(Object_Sync.key.Y, self.body:GetLinearVelocity().y)
	--event:SetNValue(Object_Sync.key.R, self.body:GetAngularVelocity())
	event:SetNValue(Object_Sync.key.o, self.oid)
	event:SetNValue(Object_Sync.key.c, self.classtype)

	return event
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

	local debugFilterData = shape:GetFilterData()
	assert( debugFilterData.maskBits == COLLISION_FILTER_MASK_LOWWALL )
	assert( debugFilterData.categoryBits == COLLISION_FILTER_CATEGORY_LOWWALL )
end

function uppuRacingObject:SetHighWall(body)
	local filterData = b2FilterData()
	filterData.groupIndex = 0

	filterData.maskBits = COLLISION_FILTER_MASK_HIGHWALL
	filterData.categoryBits = COLLISION_FILTER_CATEGORY_HIGHWALL

	local shape = body:GetShapeList()
	shape:SetFilterData(filterData)

	local debugFilterData = shape:GetFilterData()
	assert( debugFilterData.maskBits == COLLISION_FILTER_MASK_HIGHWALL )
	assert( debugFilterData.categoryBits == COLLISION_FILTER_CATEGORY_HIGHWALL )
end

function uppuRacingObject:SetMissile()
	local filterData = b2FilterData()
	filterData.groupIndex = 0

	filterData.maskBits = COLLISION_FILTER_MASK_MISSILE
	filterData.categoryBits = COLLISION_FILTER_CATEGORY_MISSILE

	local shape = self.missile:GetShapeList()
	shape:SetFilterData( filterData )

	self.world:Refilter( shape )

	local debugFilterData = shape:GetFilterData()
	assert( debugFilterData.maskBits == COLLISION_FILTER_MASK_MISSILE )
	assert( debugFilterData.categoryBits == COLLISION_FILTER_CATEGORY_MISSILE )
end

-- b2Vec2 . b2Vec2
function uppuRacingObject:VectorDot(avec, bvec)
	return avec.x * bvec.x + avec.y * bvec.y;
end

-- mul * b2Vec2
function uppuRacingObject:Multiply(vec, mul)
	vec.x = vec.x * mul
	vec.y = vec.y * mul
	return vec
end