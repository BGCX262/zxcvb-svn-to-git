require "go.ui.control.StaticImage"
require "uppuRacingConsts"
require "uppuRacingAnimationBooster"
require "uppuRacingCarAnimationRun"
require "uppuRacingCarAnimationJump"
require "uppuRacingAnimationMissileBoom"
require "uppuRacingAnimationMissile"
require "uppuRacingKeyInput"
require "uppuRacingObject"

class 'uppuRacingCarObject' (uppuRacingObject)

function uppuRacingCarObject:__init(name, owner, scene, map, controlType, pos, cartype) super(owner, CLASS_MASTER, map.world)
	self.name = name
	self.scene = scene
	self.map = map
	self.controlType = controlType
	self.cartype = cartype
	self.CreateBody_BasicType = self.CreateBody_Type1

	self.oid = owner*100+1	
	self.imagePos = pos
	self.classname = "uppuRacingCarObject"

	self:CreateBody(pos.x, pos.y)
	self.body:SetUserData(self)

	self:SetHandleAngle(0)		-- 핸들을 얼마나 꺾었는 지 (degree)

	self.anim = {}
	self.effectAnim = {}
	self.missileAnim = {}
	self:CreateAnimations()

	self.animName = "run"
	self.effectAnimName = "none"
	self.missileAnimName = "none"

	self.input = uppuRacingKeyInput(self.scene)

	self.lap = 0
	self.pass = 0

	-- 미사일 터지는 애니메이션
	--self.animBoom = Image()
	--self.animBoom:LoadControlImage("images/ido_up_ef_012.bmp", 5, 2, nil, UIConst.Blue)	-- 70x70 이미지
	--self.animBoom:Show(false)
	--self.scene:AddChild(self.animBoom)

	--self.lastsec = 0
end

function uppuRacingCarObject:Destroy()
	self.map.world:DestroyBody( self.body )
	self.map.world:DestroyBody( self.wheel )
	self.map.world:DestroyBody( self.rearWheel )

	if self.anim[self.animName] then
		self.anim[self.animName]:Reset()
	end
	if self.effectAnim[self.effectAnimName] then
		self.effectAnim[self.effectAnimName]:Reset()
	end
	if self.missileAnim[self.missileAnimName] then
		self.missileAnim[self.missileAnimName]:Reset()
	end
	if self.wheelImage then
		self.wheelImage:Show(false)
	end
	if self.rearWheelImage then
		self.rearWheelImage:Show(false)
	end
end

function uppuRacingCarObject:SetPosition(x, y, angle)
	local pos = b2Vec2(x+35, y+35)
	self.body:SetXForm(pos, angle)
	pos = b2Vec2(x+35, y+35-23)
	self.wheel:SetXForm(pos, angle)
	pos = b2Vec2(x+35, y+35+22)
	self.rearWheel:SetXForm(pos, angle)
end

function uppuRacingCarObject:SetHandleAngle(degree)
	-- 핸들은 최대 -CAR_MAX_STEER_ANGLE~CAR_MAX_STEER_ANGLE도까지 꺾을 수 있다.
	if degree > CAR_MAX_STEER_ANGLE then
		degree = CAR_MAX_STEER_ANGLE
	elseif degree < -CAR_MAX_STEER_ANGLE then
		degree = -CAR_MAX_STEER_ANGLE
	end
	self.handleAngle = degree
end

function uppuRacingCarObject:GetHandleAngle()
	return self.handleAngle
end

function uppuRacingCarObject:SetGroundCar()
	local filterData = b2FilterData()
	filterData.groupIndex = 0

	filterData.maskBits = COLLISION_FILTER_MASK_CAR
	filterData.categoryBits = COLLISION_FILTER_CATEGORY_CAR

	local shape = self.body:GetShapeList()
	while( shape ) do
		shape:SetFilterData( filterData )
		self.map.world:Refilter( shape )
		shape = shape:GetNext()
	end

--	local debugFilterData = shape:GetFilterData()
--	assert( debugFilterData.maskBits == COLLISION_FILTER_MASK_CAR )
--	assert( debugFilterData.categoryBits == COLLISION_FILTER_CATEGORY_CAR )

	-- 바퀴는 충돌 안하도록 설정
	filterData.maskBits = COLLISION_FILTER_MASK_CAR
	filterData.categoryBits = COLLISION_FILTER_MASK_NOCOLLISION

	shape = self.wheel:GetShapeList()
	shape:SetFilterData( filterData )

	shape = self.rearWheel:GetShapeList()
	shape:SetFilterData( filterData )
end

function uppuRacingCarObject:SetJumpCar()
	local filterData = b2FilterData()
	filterData.groupIndex = 0

	filterData.maskBits = COLLISION_FILTER_MASK_PLANE
	filterData.categoryBits = COLLISION_FILTER_CATEGORY_PLANE

	local shape = self.body:GetShapeList()
	shape:SetFilterData( filterData )

	self.map.world:Refilter( shape )

	local debugFilterData = shape:GetFilterData()
	assert( debugFilterData.maskBits == COLLISION_FILTER_MASK_PLANE )
	assert( debugFilterData.categoryBits == COLLISION_FILTER_CATEGORY_PLANE )
end

function uppuRacingCarObject:GetXPos()
	return self.body:GetPosition().x
end

function uppuRacingCarObject:GetYPos()
	return self.body:GetPosition().y
end

function uppuRacingCarObject:CreateBody(startx, starty)
	if self.cartype == 1 then
		self:CreateBody_Type1(startx, starty)
	elseif self.cartype == 2 then
		self:CreateBody_Type2(startx, starty)
	elseif self.cartype == 3 then
		self:CreateBody_Type3(startx, starty)
	elseif self.cartype == 4 then
		self:CreateBody_Type4(startx, starty)
	elseif self.cartype == 5 then
		self:CreateBody_Type5(startx, starty)
	else
		self:CreateBody_BasicType(startx, starty)
	end
end

function uppuRacingCarObject:CreateMissile()
	local missileDef = b2BodyDef()
	missileDef.position:Set( self.body:GetPosition().x, self.body:GetPosition().y )
	missileDef.isBullet = true
	missileDef.linearDamping = 0
	missileDef.angularDamping = 0
	self.missile = self.map.world:CreateBody( missileDef )

	local missileShapeDef = b2PolygonDef()
	missileShapeDef:SetAsBox( 7, 15 )			-- 14 x 30
	missileShapeDef.density = 1

	self.missile:CreateShape( missileShapeDef )
	self.missile:SetMassFromShapes()
	self.missile:SetUserData( self )

	-- set angle and velocity
	self.missile:SetXForm( self.missile:GetPosition(), self.body:GetAngle() )

	local vel = b2Vec2( math.cos( math.pi/2 - self.body:GetAngle() ), -math.sin( math.pi/2 - self.body:GetAngle() ) )
	self:Multiply( vel, MISSILE_INITIAL_VELOCITY )
	self.missile:SetLinearVelocity( vel )	

	self:SetMissile()
end

function uppuRacingCarObject:DestroyMissile()
	if self.missile then
		self.map.world:DestroyBody( self.missile )
		self.missile = nil
	end
end

function uppuRacingCarObject:KillOrthogonalVelocity(targetBody)
	local localPoint = b2Vec2(0,0)
	local velocity = targetBody:GetLinearVelocityFromLocalPoint( localPoint )
 
	--local sidewaysAxis = targetBody:GetXForm().R.col2
	local lcol2x=-math.sin(targetBody:GetAngle())
	local lcol2y=math.cos(targetBody:GetAngle())
	local sidewaysAxis = b2Vec2(lcol2x, lcol2y)
	self:Multiply( sidewaysAxis, self:VectorDot(velocity,sidewaysAxis) )
 
	targetBody:SetLinearVelocity( sidewaysAxis ) --targetBody:GetWorldPoint(localPoint));
end

function uppuRacingCarObject:CreateAnimations()
	local anim = nil
	
	-- run 달릴 때
	anim = uppuRacingCarAnimationRun(self, ANITYPE_CAR, CAR_IMAGE[self.cartype][self.owner])
	self.anim["run"] = anim

	-- jump 쓸 때
	anim = uppuRacingCarAnimationJump(self, ANITYPE_CAR, CAR_IMAGE[self.cartype][self.owner])
	self.anim["jump"] = anim

	-- booster 썼을 때
	anim = uppuRacingAnimationBooster(self, ANITYPE_EFFECT)
	self.effectAnim["booster"] = anim

	-- 미사일 맞았을 때
	anim = uppuRacingAnimationMissileBoom(self, ANITYPE_EFFECT)
	self.effectAnim["missileboom"] = anim

	-- 미사일 쐈을 때
	anim = uppuRacingAnimationMissile(self, ANITYPE_MISSILE)
	self.missileAnim["missile"] = anim

	---- create car image
	--self.myCar = Image()
	--self.myCar:LoadControlImage("images/ido_up_ch001_010.bmp", 4, 5, nil, UIConst.Blue)	-- 70x70 이미지
	--self.myCar:SetImageIndex(0)
	--self.myCar:SetXYPos(100, 100)
 --
	--local car = uppuRacingCarObject(charname)
	--car:SetImage( self.myCar )
	--car:SetBody( self.world )
	--car:Update()

	--local anim = car:CreateAnimation("idle")
	--anim:SetLoop(true)
	--anim:SetDelay(0.10)
	--anim:SetOffset(0, 0)
 --
	--anim:AddMoveFrame()
 --
	--anim = car:CreateAnimation("walk")
	--anim:SetLoop(true)
	--anim:SetDelay(0.08)
	--anim:SetOffset(0, 0)
 --
	--anim:AddMoveFrame()
 --
	--anim = car:CreateAnimation("rotate")
	--anim:SetLoop(true)
	--anim:SetDelay(0.10)
	--anim:SetOffset(0, 0)
 --
	--anim:AddMoveFrame()

	--return car
end

--function uppuRacingCarObject:Show(show)
--	--self.show = show ~= false
--	self.image:Show(show)
--end
--
--function uppuRacingCarObject:Enable(enable)
--	self.image:Enable(enable)
--end
--
--function uppuRacingCarObject:SetXYPos(x, y)
--	self.pos = Vector2(x, y)
--end
--
--function uppuRacingCarObject:GetXYPos()
--	return self.pos.x, self.pos.y
--end

function uppuRacingCarObject:OnAnimationEnd(elapsed, aniType)
	if aniType == ANITYPE_CAR then
		self:ChangeState("run", true)
	elseif aniType == ANITYPE_EFFECT then
		self:ChangeEffectState("none", true)
	elseif aniType == ANITYPE_MISSILE then
		self:ChangeMissileState("none", true)
	end
	--self:Update(elapsed)
end

function uppuRacingCarObject:ChangeState(animName, force)
	--현재와 같은 상태로의 변화이면 무시
	if self.animName == animName then 
		return false
	end
	
	if not force then
		if not self.anim[self.animName].loop then
			return false
		end
	end

	-- jump state로 변화인 경우
	if animName == "jump" then
		self:SetJumpCar()
	else
		self:SetGroundCar()
	end

	-- 현재 애니메이션 중단
	if self.anim[self.animName] then
		self.anim[self.animName]:Reset()
	end

	-- 새 애니메이션 셋팅	 
	self.animName = animName
	return true
end

function uppuRacingCarObject:ChangeEffectState(animName, force)
	--현재와 같은 상태로의 변화이면 무시
	if self.effectAnimName == animName then 
		return false
	end
	
	if not force then
		if not self.effectAnim[self.effectAnimName].loop then
			return false
		end
	end

	-- 현재 애니메이션 중단
	if self.effectAnim[self.effectAnimName] then
		self.effectAnim[self.effectAnimName]:Reset()
	end

	-- 새 애니메이션 셋팅	 
	self.effectAnimName = animName
	return true
end

function uppuRacingCarObject:ChangeMissileState(animName, force)
	--현재와 같은 상태로의 변화이면 무시
	if self.missileAnimName == animName then 
		return false
	end

	if animName == "none" then
		self:DestroyMissile()
		self.missileAnimName = animName
		return false
	end
	
	if not force then
		if not self.missileAnim[self.missileAnimName].loop then
			return false
		end
	end

	-- missile state로 변화인 경우
	if animName == "missile" then
		self:CreateMissile()
	else
		self:DestroyMissile()
	end

	-- 현재 애니메이션 중단
	if self.missileAnim[self.missileAnimName] then
		self.missileAnim[self.missileAnimName]:Reset()
	end

	-- 새 애니메이션 셋팅	 
	self.missileAnimName = animName
	return true
end

function uppuRacingCarObject:DivideForceXY(force)
	local carAngleRad = self.body:GetAngle()
	local forcey = -math.cos( carAngleRad ) * force		-- 위쪽이 -이므로 -를 붙여줌
	local forcex = math.sin( carAngleRad ) * force
 
	return b2Vec2(forcex, forcey)
end

function uppuRacingCarObject:Update(elapsed)
	if self.lap ~= self.map.finalLap then
		self.input:Read()
	else
		self.input:Clear()
	end
	self:Wheel(elapsed)
	self:ApplyForce(elapsed)
	self:UpdateImage(elapsed)
end

function uppuRacingCarObject:Wheel(elapsed)
	-- 핸들 각도를 조절 (1초에 최대 핸들 각도로 돌아가도록...)
	local steeredHandleAngle = self:GetHandleAngle()
	if self.input.L then
		if steeredHandleAngle > 0 then
			steeredHandleAngle = 0 --steeredHandleAngle - elapsed*CAR_MAX_STEER_ANGLE*2
		else
			steeredHandleAngle = steeredHandleAngle - elapsed*CAR_MAX_STEER_ANGLE
		end
	elseif self.input.R then
		if steeredHandleAngle < 0 then
			steeredHandleAngle = 0 --steeredHandleAngle + elapsed*CAR_MAX_STEER_ANGLE*2
		else
			steeredHandleAngle = steeredHandleAngle + elapsed*CAR_MAX_STEER_ANGLE
		end
	else
		steeredHandleAngle = 0
	end

	self:SetHandleAngle( steeredHandleAngle )
	self.wheel:SetXForm( self.wheel:GetPosition(), (self:GetHandleAngle()+math.deg(self.body:GetAngle()))*math.pi/180 )
end

function uppuRacingCarObject:ApplyForce(elapsed)
	self:KillOrthogonalVelocity( self.wheel )
	self:KillOrthogonalVelocity( self.rearWheel )

	local engineSpeed = 0
	local boosterSpeed = 0
 
	if self.input.U then
		self.body:WakeUp()
		engineSpeed = -CAR_HORSEPOWERS
	elseif self.input.D then
		engineSpeed = CAR_HORSEPOWERS/4
	else
		engineSpeed = 0
	end
 
	-- booster
	if self.input.Z then
		if self:ChangeEffectState("booster", true) then
			boosterSpeed = 5000000
		end
	end

	-- jump
	if self.input.X then
		if self:ChangeState("jump", true) then
			boosterSpeed = 1000000
		end
	end

	-- missile boom
	if self.input.C then
		--if self:ChangeEffectState("missileboom", true) then
		--	boosterSpeed = 0
		--end

		-- debug
		self:ChangeMissileState("none", true)

		if self:ChangeMissileState("missile", true) then
		end
	end

	local vforce = self:DivideForceXY(boosterSpeed)

	local lcol2x=-math.cos(math.pi/2-self.wheel:GetAngle())
	local lcol2y=math.sin(math.pi/2-self.wheel:GetAngle())
	local ldirection = b2Vec2(lcol2x, lcol2y)
	self:Multiply( ldirection, engineSpeed )

	self.wheel:ApplyForce( ldirection, self.wheel:GetPosition() )
	self.body:ApplyForce( vforce, self.body:GetPosition() )
end

function uppuRacingCarObject:UpdateImage(elapsed)
	self:UpdateCar(elapsed)
	self:UpdateMissile(elapsed)

	-- debug: wheel image
	self:UpdateDebugWheel()
end

function uppuRacingCarObject:UpdateCar(elapsed)
	local body = self.body

	-- 강체 중심(bodyx)에서 이미지 좌표로 변환하기 위해서 -35
	-- 차 그림 각도 보정위해서 +90
	local x = body:GetPosition().x - 32
	local y = body:GetPosition().y - 35
	local angle = math.deg( body:GetAngle() )

	self.anim[self.animName]:Update(elapsed, x, y, angle)
	if self.effectAnim[self.effectAnimName] then
		self.effectAnim[self.effectAnimName]:Update(elapsed, x, y, angle)
	end
end

function uppuRacingCarObject:UpdateMissile(elapsed)
	if self.missile and self.missileAnim[self.missileAnimName] then
		self.missileAnim[self.missileAnimName]:Update(elapsed, self.missile:GetPosition().x, self.missile:GetPosition().y,
			math.deg( self.missile:GetAngle() ) )
	end
end

function uppuRacingCarObject:UpdateDebugWheel()
	if self.scene:IsDebug() == false then
		if self.wheelImage then self.wheelImage:Show(false) end
		if self.rearWheelImage then self.rearWheelImage:Show(false) end
		return
	end

	if self.wheelImage == nil then
		self.wheelImage = StaticImage()
		Scene.latestScene:AddChild(self.wheelImage)
		self.wheelImage:LoadStaticImage("images/wheel.bmp", 1, 1, nil, UIConst.Blue)
	end

	self.wheelImage:SetXPos( self.wheel:GetPosition().x - CAR_WHEEL_SIZE_X/2 )
	self.wheelImage:SetYPos( self.wheel:GetPosition().y - CAR_WHEEL_SIZE_Y/2 )
	self.wheelImage:SetXPivot( self.wheelImage:GetWidth()/2 )
	self.wheelImage:SetYPivot( self.wheelImage:GetHeight()/2 )
	self.wheelImage:SetRotate( math.deg( self.wheel:GetAngle() ) )
	self.wheelImage:Show(true)

	if self.rearWheelImage == nil then
		self.rearWheelImage = StaticImage()
		Scene.latestScene:AddChild(self.rearWheelImage)
		self.rearWheelImage:LoadStaticImage("images/wheel.bmp", 1, 1, nil, UIConst.Blue)
	end

	self.rearWheelImage:SetXPos( self.rearWheel:GetPosition().x - CAR_WHEEL_SIZE_X/2 )
	self.rearWheelImage:SetYPos( self.rearWheel:GetPosition().y - CAR_WHEEL_SIZE_Y/2 )
	self.rearWheelImage:SetXPivot( self.rearWheelImage:GetWidth()/2 )
	self.rearWheelImage:SetYPivot( self.rearWheelImage:GetHeight()/2 )
	self.rearWheelImage:SetRotate( math.deg( self.rearWheel:GetAngle() ) )
	self.rearWheelImage:Show(true)
end

function uppuRacingCarObject:CreateBody_Type1( startx, starty )
	-- create car body
	local carDef = b2BodyDef()
	carDef.position:Set( startx+35, starty+35 )
	carDef.linearDamping = 1
	carDef.angularDamping = 1 --0.1
	self.body = self.map.world:CreateBody( carDef )	-- 공을 생성
	
	local carShapeDef = b2PolygonDef()
	carShapeDef:SetAsBox( 22.0, 29.0 )	-- 44x58 (70x70)
	--carShapeDef:SetAsBox( 1.5, 2.5 )
	carShapeDef.density = CAR_DENSITY
	carShapeDef.restitution = 0.7
	
	self.body:CreateShape( carShapeDef )
	self.body:SetMassFromShapes()

	-- car wheel
	local wheelDef = b2BodyDef()
	wheelDef.position:Set( startx+35, starty+35 -23 )
	wheelDef.linearDamping = 1
	wheelDef.angularDamping = 1 --0.1
	self.wheel = self.map.world:CreateBody( wheelDef )

	local wheelShapeDef = b2PolygonDef()
	wheelShapeDef:SetAsBox( CAR_WHEEL_SIZE_X/2, CAR_WHEEL_SIZE_Y/2 )
	wheelShapeDef.density = CAR_WHEEL_DENSITY

	self.wheel:CreateShape( wheelShapeDef )
	self.wheel:SetMassFromShapes()

	-- car rear wheel
	local rearWheelDef = b2BodyDef()
	rearWheelDef.position:Set( startx+35, starty+35 +22 )
	rearWheelDef.linearDamping = 1
	rearWheelDef.angularDamping = 1 --0.1
	self.rearWheel = self.map.world:CreateBody( rearWheelDef )

	local rearWheelShapeDef = b2PolygonDef()
	rearWheelShapeDef:SetAsBox( CAR_WHEEL_SIZE_X/2, CAR_WHEEL_SIZE_Y/2 )
	rearWheelShapeDef.density = CAR_WHEEL_DENSITY

	self.rearWheel:CreateShape( rearWheelShapeDef )
	self.rearWheel:SetMassFromShapes()

	-- create joint
	local wheelJointDef = b2PrismaticJointDef()
	wheelJointDef:Initialize( self.body, self.wheel, self.wheel:GetWorldCenter(), b2Vec2(1,0) )
	wheelJointDef.enableLimit = true
	wheelJointDef.lowerTranslation = 0
	wheelJointDef.upperTranslation = 0
	 
	self.map.world:CreateJoint( wheelJointDef )

	local rearWheelJointDef = b2PrismaticJointDef()
	rearWheelJointDef:Initialize( self.body, self.rearWheel, self.rearWheel:GetWorldCenter(), b2Vec2(1,0) )
	rearWheelJointDef.enableLimit = true
	rearWheelJointDef.lowerTranslation = 0
	rearWheelJointDef.upperTranslation = 0
	 
	self.map.world:CreateJoint( rearWheelJointDef )

	self:SetGroundCar()
end

function uppuRacingCarObject:CreateBody_Type2( startx, starty )
	-- create car body
	local carDef = b2BodyDef()
	carDef.position:Set( startx+35, starty+35 )
	carDef.linearDamping = 1
	carDef.angularDamping = 1 --0.1
	self.body = self.map.world:CreateBody( carDef )	-- 공을 생성
	
	local carShapeDef = b2PolygonDef()
	carShapeDef:SetAsBox( 18.0, 29.0 )	-- 44x58 (70x70)
	--carShapeDef:SetAsBox( 1.5, 2.5 )
	carShapeDef.density = CAR_DENSITY
	carShapeDef.restitution = 0.7
	
	self.body:CreateShape( carShapeDef )
	self.body:SetMassFromShapes()

	-- car wheel
	local wheelDef = b2BodyDef()
	wheelDef.position:Set( startx+35, starty+35 -23 )
	wheelDef.linearDamping = 1
	wheelDef.angularDamping = 1 --0.1
	self.wheel = self.map.world:CreateBody( wheelDef )

	local wheelShapeDef = b2PolygonDef()
	wheelShapeDef:SetAsBox( CAR_WHEEL_SIZE_X/2, CAR_WHEEL_SIZE_Y/2 )
	wheelShapeDef.density = CAR_WHEEL_DENSITY

	self.wheel:CreateShape( wheelShapeDef )
	self.wheel:SetMassFromShapes()

	-- car rear wheel
	local rearWheelDef = b2BodyDef()
	rearWheelDef.position:Set( startx+35, starty+35 +22 )
	rearWheelDef.linearDamping = 1
	rearWheelDef.angularDamping = 1 --0.1
	self.rearWheel = self.map.world:CreateBody( rearWheelDef )

	local rearWheelShapeDef = b2PolygonDef()
	rearWheelShapeDef:SetAsBox( CAR_WHEEL_SIZE_X/2, CAR_WHEEL_SIZE_Y/2 )
	rearWheelShapeDef.density = CAR_WHEEL_DENSITY

	self.rearWheel:CreateShape( rearWheelShapeDef )
	self.rearWheel:SetMassFromShapes()

	-- create joint
	local wheelJointDef = b2PrismaticJointDef()
	wheelJointDef:Initialize( self.body, self.wheel, self.wheel:GetWorldCenter(), b2Vec2(1,0) )
	wheelJointDef.enableLimit = true
	wheelJointDef.lowerTranslation = 0
	wheelJointDef.upperTranslation = 0
	 
	self.map.world:CreateJoint( wheelJointDef )

	local rearWheelJointDef = b2PrismaticJointDef()
	rearWheelJointDef:Initialize( self.body, self.rearWheel, self.rearWheel:GetWorldCenter(), b2Vec2(1,0) )
	rearWheelJointDef.enableLimit = true
	rearWheelJointDef.lowerTranslation = 0
	rearWheelJointDef.upperTranslation = 0
	 
	self.map.world:CreateJoint( rearWheelJointDef )

	self:SetGroundCar()
end

function uppuRacingCarObject:CreateBody_Type3( startx, starty )
	-- create car body
	local carDef = b2BodyDef()
	carDef.position:Set( startx+30, starty+30 )
	carDef.linearDamping = 1
	carDef.angularDamping = 1 --0.1
	self.body = self.map.world:CreateBody( carDef )	-- 공을 생성
	
	local carShapeDef = b2PolygonDef()
	carShapeDef:SetAsBox( 20.0, 20.0 )	-- 44x58 (70x70)
	--carShapeDef:SetAsBox( 1.5, 2.5 )
	carShapeDef.density = CAR_DENSITY
	carShapeDef.restitution = 0.7
	
	self.body:CreateShape( carShapeDef )
	self.body:SetMassFromShapes()

	-- car wheel
	local wheelDef = b2BodyDef()
	wheelDef.position:Set( startx+30, starty+30 -23 )
	wheelDef.linearDamping = 1
	wheelDef.angularDamping = 1 --0.1
	self.wheel = self.map.world:CreateBody( wheelDef )

	local wheelShapeDef = b2PolygonDef()
	wheelShapeDef:SetAsBox( CAR_WHEEL_SIZE_X/2, CAR_WHEEL_SIZE_Y/2 )
	wheelShapeDef.density = CAR_WHEEL_DENSITY

	self.wheel:CreateShape( wheelShapeDef )
	self.wheel:SetMassFromShapes()

	-- car rear wheel
	local rearWheelDef = b2BodyDef()
	rearWheelDef.position:Set( startx+30, starty+30 +22 )
	rearWheelDef.linearDamping = 1
	rearWheelDef.angularDamping = 1 --0.1
	self.rearWheel = self.map.world:CreateBody( rearWheelDef )

	local rearWheelShapeDef = b2PolygonDef()
	rearWheelShapeDef:SetAsBox( CAR_WHEEL_SIZE_X/2, CAR_WHEEL_SIZE_Y/2 )
	rearWheelShapeDef.density = CAR_WHEEL_DENSITY

	self.rearWheel:CreateShape( rearWheelShapeDef )
	self.rearWheel:SetMassFromShapes()

	-- create joint
	local wheelJointDef = b2PrismaticJointDef()
	wheelJointDef:Initialize( self.body, self.wheel, self.wheel:GetWorldCenter(), b2Vec2(1,0) )
	wheelJointDef.enableLimit = true
	wheelJointDef.lowerTranslation = 0
	wheelJointDef.upperTranslation = 0
	 
	self.map.world:CreateJoint( wheelJointDef )

	local rearWheelJointDef = b2PrismaticJointDef()
	rearWheelJointDef:Initialize( self.body, self.rearWheel, self.rearWheel:GetWorldCenter(), b2Vec2(1,0) )
	rearWheelJointDef.enableLimit = true
	rearWheelJointDef.lowerTranslation = 0
	rearWheelJointDef.upperTranslation = 0
	 
	self.map.world:CreateJoint( rearWheelJointDef )

	self:SetGroundCar()
end

function uppuRacingCarObject:CreateBody_Type4( startx, starty )
	-- create car body
	local carDef = b2BodyDef()
	carDef.position:Set( startx+35, starty+35 )
	carDef.linearDamping = 1
	carDef.angularDamping = 1 --0.1
	self.body = self.map.world:CreateBody( carDef )	-- 공을 생성
	
	local carShapeDef = b2PolygonDef()
	carShapeDef:SetAsBox( 22.0, 29.0 )	-- 44x58 (70x70)
	--carShapeDef:SetAsBox( 1.5, 2.5 )
	carShapeDef.density = CAR_DENSITY
	carShapeDef.restitution = 0.7
	
	self.body:CreateShape( carShapeDef )
	self.body:SetMassFromShapes()

	-- car wheel
	local wheelDef = b2BodyDef()
	wheelDef.position:Set( startx+35, starty+35 -23 )
	wheelDef.linearDamping = 1
	wheelDef.angularDamping = 1 --0.1
	self.wheel = self.map.world:CreateBody( wheelDef )

	local wheelShapeDef = b2PolygonDef()
	wheelShapeDef:SetAsBox( CAR_WHEEL_SIZE_X/2, CAR_WHEEL_SIZE_Y/2 )
	wheelShapeDef.density = CAR_WHEEL_DENSITY

	self.wheel:CreateShape( wheelShapeDef )
	self.wheel:SetMassFromShapes()

	-- car rear wheel
	local rearWheelDef = b2BodyDef()
	rearWheelDef.position:Set( startx+35, starty+35 +22 )
	rearWheelDef.linearDamping = 1
	rearWheelDef.angularDamping = 1 --0.1
	self.rearWheel = self.map.world:CreateBody( rearWheelDef )

	local rearWheelShapeDef = b2PolygonDef()
	rearWheelShapeDef:SetAsBox( CAR_WHEEL_SIZE_X/2, CAR_WHEEL_SIZE_Y/2 )
	rearWheelShapeDef.density = CAR_WHEEL_DENSITY

	self.rearWheel:CreateShape( rearWheelShapeDef )
	self.rearWheel:SetMassFromShapes()

	-- create joint
	local wheelJointDef = b2PrismaticJointDef()
	wheelJointDef:Initialize( self.body, self.wheel, self.wheel:GetWorldCenter(), b2Vec2(1,0) )
	wheelJointDef.enableLimit = true
	wheelJointDef.lowerTranslation = 0
	wheelJointDef.upperTranslation = 0
	 
	self.map.world:CreateJoint( wheelJointDef )

	local rearWheelJointDef = b2PrismaticJointDef()
	rearWheelJointDef:Initialize( self.body, self.rearWheel, self.rearWheel:GetWorldCenter(), b2Vec2(1,0) )
	rearWheelJointDef.enableLimit = true
	rearWheelJointDef.lowerTranslation = 0
	rearWheelJointDef.upperTranslation = 0
	 
	self.map.world:CreateJoint( rearWheelJointDef )

	self:SetGroundCar()
end

function uppuRacingCarObject:CreateBody_Type5( startx, starty )
	-- create car body
	local carDef = b2BodyDef()
	carDef.position:Set( startx+40, starty+40 )
	carDef.linearDamping = 1
	carDef.angularDamping = 1 --0.1
	self.body = self.map.world:CreateBody( carDef )	-- 공을 생성
	
	local carShapeDef = b2CircleDef()
	carShapeDef.radius = 37
	carShapeDef.density = CAR_DENSITY
	carShapeDef.restitution = 0.7
	
	self.body:CreateShape( carShapeDef )
	self.body:SetMassFromShapes()

	-- car wheel
	local wheelDef = b2BodyDef()
	wheelDef.position:Set( startx+40, starty+40 -23 )
	wheelDef.linearDamping = 1
	wheelDef.angularDamping = 1 --0.1
	self.wheel = self.map.world:CreateBody( wheelDef )

	local wheelShapeDef = b2PolygonDef()
	wheelShapeDef:SetAsBox( CAR_WHEEL_SIZE_X/2, CAR_WHEEL_SIZE_Y/2 )
	wheelShapeDef.density = CAR_WHEEL_DENSITY

	self.wheel:CreateShape( wheelShapeDef )
	self.wheel:SetMassFromShapes()

	-- car rear wheel
	local rearWheelDef = b2BodyDef()
	rearWheelDef.position:Set( startx+40, starty+40 +22 )
	rearWheelDef.linearDamping = 1
	rearWheelDef.angularDamping = 1 --0.1
	self.rearWheel = self.map.world:CreateBody( rearWheelDef )

	local rearWheelShapeDef = b2PolygonDef()
	rearWheelShapeDef:SetAsBox( CAR_WHEEL_SIZE_X/2, CAR_WHEEL_SIZE_Y/2 )
	rearWheelShapeDef.density = CAR_WHEEL_DENSITY

	self.rearWheel:CreateShape( rearWheelShapeDef )
	self.rearWheel:SetMassFromShapes()

	-- create joint
	local wheelJointDef = b2PrismaticJointDef()
	wheelJointDef:Initialize( self.body, self.wheel, self.wheel:GetWorldCenter(), b2Vec2(1,0) )
	wheelJointDef.enableLimit = true
	wheelJointDef.lowerTranslation = 0
	wheelJointDef.upperTranslation = 0
	 
	self.map.world:CreateJoint( wheelJointDef )

	local rearWheelJointDef = b2PrismaticJointDef()
	rearWheelJointDef:Initialize( self.body, self.rearWheel, self.rearWheel:GetWorldCenter(), b2Vec2(1,0) )
	rearWheelJointDef.enableLimit = true
	rearWheelJointDef.lowerTranslation = 0
	rearWheelJointDef.upperTranslation = 0
	 
	self.map.world:CreateJoint( rearWheelJointDef )

	self:SetGroundCar()
end