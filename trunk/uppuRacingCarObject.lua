require "go.ui.control.StaticImage"
require "uppuRacingConsts"
require "uppuRacingAnimationBooster"
require "uppuRacingAnimationCarJump"
require "uppuRacingKeyInput"
require "uppuRacingObject"
require "uppuRacingMissileObject"

class 'uppuRacingCarObject' (uppuRacingObject)

function uppuRacingCarObject:__init(name, owner, scene, map, pos, cartype) super(owner, CLASS_MASTER, map.world)
	self.name = name
	self.scene = scene
	self.map = map
	self.cartype = cartype
	self.CreateBody_BasicType = self.CreateBody_Haan

	self.oid = GetCarOID(owner)	
	self.imagePos = pos
	self.classname = "uppuRacingCarObject"
	self.ownObjectId = 0

	self:CreateBody(pos.x, pos.y)
	self.body:SetUserData(self)

	self:SetHandleAngle(0)		-- 핸들을 얼마나 꺾었는 지 (degree)

	self.image = self:LoadImage()
	self.effectAnim = {}
	self.effectAnimName = "none"
	self:CreateAnimations()

	self.textName = self:LoadTextName()

	self.input = uppuRacingKeyInput(self.scene)

	self.lap = 0
	self.pass = 0
	self.retire = false
	self.groggytime = 0		-- 조종이 안되는 시간
end

function uppuRacingCarObject:SetGroggy(groggytime)
	-- todo: 차에따라 groggytime이 다 적용되지 않을 수 있다.
	if groggytime > self.groggytime then
		self.groggytime = groggytime
	end
	self.image:AnimateStaticImage(10, 11, self.groggytime, 1)
end

function uppuRacingCarObject:GetNewOID()
	self.ownObjectId = self.ownObjectId	+ 1
	if self.ownObjectId	>= 9000 then
		self.ownObjectId = 1
	end
	return self.oid + self.ownObjectId
end

function uppuRacingCarObject:GetSpeed()
	local vel = self.body:GetLinearVelocity()
	return math.sqrt(vel.x*vel.x + vel.y*vel.y)
end

function uppuRacingCarObject:GetMass()
	return self.body:GetMass()
end

function uppuRacingCarObject:LoadImage()
	local frame = gameapp.listUserState[self.owner].carImage:Clone()
	Scene.latestScene:AddChild(frame)

	frame:AnimateStaticImage(0, 3, 1, -1)

	local imageWidth = frame:GetWidth()
	local imageHeight = frame:GetHeight()

	--frame:SetStaticImageIndex(0)
	frame:SetXPivot(imageWidth/2)
	frame:SetYPivot(imageHeight/2)
	frame:SetXPos(self:GetXPos())
	frame:SetYPos(self:GetYPos())
	frame:SetRotate(math.deg(self:GetAngle()))

	frame:Show(true)

	return frame
end

function uppuRacingCarObject:LoadTextName()
	local text = Text()
	Scene.latestScene:AddChild(text)

	--text:SetTextAlign(UIConst.HorzAlignRight)
	text:SetXPos(self:GetXPos())
	text:SetYPos(self:GetYPos() - 5)
	text:SetText(self.name)
	text:SetTextColor(UIConst.White)
	text:Show(true)

	return text
end

function uppuRacingCarObject:Destroy()
	self.map.world:DestroyBody( self.body )
	self.map.world:DestroyBody( self.wheel )
	self.map.world:DestroyBody( self.rearWheel )

	if self.effectAnim[self.effectAnimName] then
		self.effectAnim[self.effectAnimName]:Reset()
	end
	if self.wheelImage then
		self.wheelImage:Show(false)
	end
	if self.rearWheelImage then
		self.rearWheelImage:Show(false)
	end
	if self.textName then
		self.textName:Show(false)
	end
end

function uppuRacingCarObject:SetPosition(x, y, angle)
	local pos = b2Vec2(x+35, y+35)
	self.body:SetXForm(pos, angle)

	self:AlignWheelPosition(x+35, y+35, angle)
end

function uppuRacingCarObject:AlignWheelPosition(x, y, angle)
	local wheelOffset = b2Vec2(0, CAR_WHEEL_OFFSET)
	local rearWheelOffset = b2Vec2(0, CAR_REAR_WHEEL_OFFSET)

	VectorRotate(wheelOffset, angle)
	VectorRotate(rearWheelOffset, angle)

	local pos = b2Vec2(x + wheelOffset.x, y + wheelOffset.y)
	self.wheel:SetXForm(pos, self.wheel:GetAngle())
	pos = b2Vec2(x + rearWheelOffset.x, y + rearWheelOffset.y)
	self.rearWheel:SetXForm(pos, self.rearWheel:GetAngle())
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

	-- 바퀴는 충돌 안하도록 설정
	filterData.maskBits = COLLISION_FILTER_MASK_NOCOLLISION
	filterData.categoryBits = 0

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
end

function uppuRacingCarObject:GetXPos()
	return self.body:GetPosition().x
end

function uppuRacingCarObject:GetYPos()
	return self.body:GetPosition().y
end

function uppuRacingCarObject:GetAngle()
	return self.body:GetAngle()
end

function uppuRacingCarObject:CreateBody(startx, starty)
	if self.cartype == CAR_TYPE_HAAN then
		self:CreateBody_Haan(startx, starty)
	elseif self.cartype == CAR_TYPE_POONG then
		self:CreateBody_Poong(startx, starty)
	elseif self.cartype == CAR_TYPE_PYAGI then
		self:CreateBody_Pyagi(startx, starty)
	elseif self.cartype == CAR_TYPE_TOTO then
		self:CreateBody_Toto(startx, starty)
	elseif self.cartype == CAR_TYPE_HOOCHI then
		self:CreateBody_Hoochi(startx, starty)
	else
		self:CreateBody_BasicType(startx, starty)
	end
end

function uppuRacingCarObject:CreateMissile()
	self.missile = uppuRacingMissileObject(self.map.world, self, self:GetNewOID())
	self.map:AddObject(self.missile)
end

function uppuRacingCarObject:DestroyMissile()
	if self.missile then
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
	Multiply( sidewaysAxis, self:VectorDot(velocity,sidewaysAxis) )
 
	targetBody:SetLinearVelocity( sidewaysAxis ) --targetBody:GetWorldPoint(localPoint));
end

function uppuRacingCarObject:CreateAnimations()
	local anim = nil
	
	-- jump 쓸 때
	anim = uppuRacingAnimationCarJump(self, CAR_IMAGE[self.cartype][self.owner])
	self.effectAnim["jump"] = anim

	-- booster 썼을 때
	anim = uppuRacingAnimationBooster(self)
	self.effectAnim["booster"] = anim
end

function uppuRacingCarObject:ChangeEffectState(animName)
	-- 이미 다른 effect가 실행중이면 return false
	if self.effectAnim[self.effectAnimName] and self.effectAnim[self.effectAnimName]:IsAnimating() then
		return false
	end

	if self.effectAnim[animName] then
		self.effectAnim[animName]:Play()
		self.effectAnimName = animName

		-- effect sync
		local msg = Message(Effect_Sync)
		msg:SetNValue(Effect_Sync.key.no, self.owner)
		msg:SetNValue(Effect_Sync.key.oid, self.oid)
		msg:SetValue(Effect_Sync.key.effect, animName)

		gameapp:SendUnreliableToServer(msg)		
	end
	return true
end

function uppuRacingCarObject:GetEffectState()
	return self.effectAnimName
end

function uppuRacingCarObject:DivideForceXY(force)
	local carAngleRad = self.body:GetAngle()
	local forcey = -math.cos( carAngleRad ) * force		-- 위쪽이 -이므로 -를 붙여줌
	local forcex = math.sin( carAngleRad ) * force
 
	return b2Vec2(forcex, forcey)
end

function uppuRacingCarObject:Update(elapsed)
	local groggytime = self.groggytime

	-- 마지막 바퀴를 돌면 키 입력 안 받는다.
	if self.lap == self.map.finalLap or self.retire or self.groggytime > elapsed then
		if self.groggytime > elapsed then
			self.groggytime = self.groggytime - elapsed
		end
		self.input:Clear()
	else
		self.input:Read()
		self.groggytime = 0
	end

	-- 그로기 상태에서 벗어나면 animation을 디폴트 상태로 되돌림
	if groggytime > 0 and self.groggytime == 0 then
		self.image:AnimateStaticImage(0, 3, 1, -1)
	end

	--self:Wheel(elapsed)
	--self:ApplyForce(elapsed)
	self:EasyWheel(elapsed)
	self:UpdateImage(elapsed)
end

function uppuRacingCarObject:EasyWheelHandle(secondkeyPressed)
	local bodyAngle = self.body:GetAngle()
	bodyAngle = bodyAngle % (math.pi*2)
	if bodyAngle < 0 then
		bodyAngle = bodyAngle + math.pi*2
	end
	assert(bodyAngle >= 0 and bodyAngle < math.pi*2)

	local steeredHandleAngle = 0
	local backward = false

	if secondkeyPressed == nil then
		secondkeyPressed = false
	end

	-- 90 (pi/2)
	if self.input.R and (secondkeyPressed == false or (secondkeyPressed and self.input.secondkey == 2)) then
		if math.abs(bodyAngle - math.pi/2) <= math.pi/2 then
			steeredHandleAngle = -math.deg(bodyAngle - math.pi/2)
		else
			steeredHandleAngle = -math.deg(bodyAngle - math.pi*3/2)
			backward = true		
		end

	-- 270 (pi*3/2)
	elseif self.input.L and (secondkeyPressed == false or (secondkeyPressed and self.input.secondkey == 1)) then
		if math.abs(bodyAngle - math.pi*3/2) <= math.pi/2 then
			steeredHandleAngle = -math.deg(bodyAngle - math.pi*3/2)
		else
			steeredHandleAngle = -math.deg(bodyAngle - math.pi/2)
			backward = true		
		end

	-- 0 (0)
	elseif self.input.U and (secondkeyPressed == false or (secondkeyPressed and self.input.secondkey == 3)) then
		if bodyAngle >= math.pi*3/2 then
			steeredHandleAngle = math.deg(math.pi*2 - bodyAngle)
		elseif bodyAngle <= math.pi/2 then
			steeredHandleAngle = -math.deg(bodyAngle)
		else
			steeredHandleAngle = -math.deg(bodyAngle - math.pi)
			backward = true
		end

	-- 180 (pi)
	elseif self.input.D and (secondkeyPressed == false or (secondkeyPressed and self.input.secondkey == 4)) then
		if math.abs(bodyAngle - math.pi) <= math.pi/2 then
			steeredHandleAngle = -math.deg(bodyAngle - math.pi)
		else
			if bodyAngle <= math.pi/2 then
				steeredHandleAngle = -math.deg(bodyAngle)
			else
				steeredHandleAngle = math.deg(math.pi*2 - bodyAngle)
			end
			backward = true		
		end
	end

	self:SetHandleAngle( steeredHandleAngle )
	return backward
end

-- 좀 더 쉬운 조작법
function uppuRacingCarObject:EasyWheel(elapsed)
	self:AlignWheelPosition(self.body:GetPosition().x, self.body:GetPosition().y, self.body:GetAngle())

	local backward = self:EasyWheelHandle(self.input.keydowns[self.input.secondkey])

	-- todo: bombbox가 터질 때, 미사일이 위를 지나가면 미사일이 box2d world 밖으로 나가는 버그 있음
	local r = self.wheel:SetXForm( self.wheel:GetPosition(), (self:GetHandleAngle()+math.deg(self.body:GetAngle()))*math.pi/180 )
	if false == r then
		print (string.format("SetXFrom failed: car(%f, %f), pos(%f, %f), handle(%d)", self.body:GetPosition().x, self.body:GetPosition().y, self.wheel:GetPosition().x, self.wheel:GetPosition().y, self:GetHandleAngle()))
		assert(r)
	end

	if self.nofriction == false then
		self:KillOrthogonalVelocity( self.wheel )
		self:KillOrthogonalVelocity( self.rearWheel )
	end

	-- booster
	if self.input.Z then
		self:ChangeEffectState("booster")
	end

	-- jump
	if self.input.X then
		if self:ChangeEffectState("jump", true) then
			self:SetJumpCar()
			self.image:Show(false)
		end
	end

	-- missile
	if self.input.C and self.missile == nil then
		self:CreateMissile()
	end

	if self.input.D or self.input.U or self.input.L or self.input.R then
		local lcol2x=-math.cos(math.pi/2-self.wheel:GetAngle())
		local lcol2y=math.sin(math.pi/2-self.wheel:GetAngle())
		local ldirection = b2Vec2(lcol2x, lcol2y)

		if backward then
			Multiply( ldirection, CAR_HORSEPOWERS )
		else
			Multiply( ldirection, -CAR_HORSEPOWERS )
		end
	
		self.wheel:ApplyForce(ldirection, self.wheel:GetPosition())
		--self.wheel:SetLinearVelocity(ldirection)
		if self:GetEffectState() == "booster" then
			local vforce = self:DivideForceXY(CAR_BOOSTER_VELOCITY)
			self.body:SetLinearVelocity(vforce)
		end
	end
end

--function uppuRacingCarObject:Wheel(elapsed)
--	self:AlignWheelPosition(self.body:GetPosition().x, self.body:GetPosition().y, self.body:GetAngle())
--
--	-- 핸들 각도를 조절 (1초에 최대 핸들 각도로 돌아가도록...)
--	local steeredHandleAngle = self:GetHandleAngle()
--	if self.input.L and self.effectAnim["jump"]:IsAnimating() == false then
--		if steeredHandleAngle > 0 then
--			steeredHandleAngle = 0 --steeredHandleAngle - elapsed*CAR_MAX_STEER_ANGLE*2
--		else
--			--steeredHandleAngle = steeredHandleAngle - elapsed*CAR_MAX_STEER_ANGLE/2
--			steeredHandleAngle = -15
--		end
--		--print ("left")
--	elseif self.input.R and self.effectAnim["jump"]:IsAnimating() == false then
--		if steeredHandleAngle < 0 then
--			steeredHandleAngle = 0 --steeredHandleAngle + elapsed*CAR_MAX_STEER_ANGLE*2
--		else
--			--steeredHandleAngle = steeredHandleAngle + elapsed*CAR_MAX_STEER_ANGLE/2
--			steeredHandleAngle = 15
--		end
--		--print ("right")
--	else
--		steeredHandleAngle = 0
--	end
--
--	self:SetHandleAngle( steeredHandleAngle )
--
--	-- todo: bombbox가 터질 때, 미사일이 위를 지나가면 미사일이 box2d world 밖으로 나가는 버그 있음
--	local r = self.wheel:SetXForm( self.wheel:GetPosition(), (self:GetHandleAngle()+math.deg(self.body:GetAngle()))*math.pi/180 )
--	if false == r then
--		print (string.format("SetXFrom failed: car(%f, %f), pos(%f, %f), handle(%d)", self.body:GetPosition().x, self.body:GetPosition().y, self.wheel:GetPosition().x, self.wheel:GetPosition().y, self:GetHandleAngle()))
--		assert(r)
--	end
--end
--
--function uppuRacingCarObject:ApplyForce(elapsed)
--	if self.nofriction == false then
--		self:KillOrthogonalVelocity( self.wheel )
--		self:KillOrthogonalVelocity( self.rearWheel )
--	end
--
--	local engineSpeed = 0
-- 
--	if self.input.U then
--		self.body:WakeUp()
--		engineSpeed = -CAR_HORSEPOWERS
--	elseif self.input.D then
--		engineSpeed = CAR_HORSEPOWERS/4
--	else
--		engineSpeed = 0
--	end
-- 
--	-- booster
--	if self.input.Z then
--		self:ChangeEffectState("booster")
--	end
--
--	-- jump
--	if self.input.X then
--		if self:ChangeEffectState("jump", true) then
--			self:SetJumpCar()
--			self.image:Show(false)
--			boosterSpeed = 0
--		end
--	end
--
--	-- missile
--	if self.input.C and self.missile == nil then
--		self:CreateMissile()
--	end
--
--
--	local lcol2x=-math.cos(math.pi/2-self.wheel:GetAngle())
--	local lcol2y=math.sin(math.pi/2-self.wheel:GetAngle())
--	local ldirection = b2Vec2(lcol2x, lcol2y)
--	Multiply( ldirection, engineSpeed )
--
--	--self.wheel:ApplyForce( ldirection, self.wheel:GetPosition() )
--	self.wheel:SetLinearVelocity(ldirection)
--	if self:GetEffectState() == "booster" then
--		local vforce = self:DivideForceXY(CAR_BOOSTER_VELOCITY)
--		self.body:SetLinearVelocity(vforce)
--	end
--end

function uppuRacingCarObject:UpdateImage(elapsed)
	self:UpdateCar(elapsed)
	self:UpdateMissile(elapsed)

	-- debug: wheel image
	self:UpdateDebugWheel()
end

function uppuRacingCarObject:UpdateCar(elapsed)
	-- 기본 차 그림
	self.image:SetXPos(self:GetXPos() - self.image:GetWidth()/2)
	self.image:SetYPos(self:GetYPos() - self.image:GetHeight()/2)
	self.image:SetRotate(math.deg(self:GetAngle()))

	self.textName:SetXPos(self.image:GetXPos())
	self.textName:SetYPos(self.image:GetYPos() - 5)

	-- effect animation
	if self.effectAnim[self.effectAnimName] then
		self.effectAnim[self.effectAnimName]:Update(elapsed)

		-- aninmate가 끝나면, 다시 none 상태로 변경
		if self.effectAnim[self.effectAnimName]:IsAnimating() == false then
			-- jump animation이 끝나면 다시 충돌가능한 차로 만들어 준다.
			if self.effectAnimName == "jump" then
				self:SetGroundCar()
				self.image:Show(true)
			end

			self.effectAnimName = "none"
		end
	end
end

function uppuRacingCarObject:UpdateMissile(elapsed)
	if self.missile then
		self.missile:Update(elapsed)
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

function uppuRacingCarObject:CreateBody_Haan( startx, starty )
	-- create car body
	local carDef = b2BodyDef()
	carDef.position:Set( startx+35, starty+35 )
	carDef.linearDamping = CAR_LINEAR_DAMPING
	carDef.angularDamping = CAR_ANGULAR_DAMPING
	self.body = self.map.world:CreateBody( carDef )	-- 공을 생성
	
	local carShapeDef = b2PolygonDef()
	carShapeDef:SetAsBox(CAR_HAAN_WIDTH/2, CAR_HAAN_HEIGHT/2)	-- 44x58 (70x70)
	carShapeDef.density = CAR_DENSITY
	carShapeDef.restitution = CAR_RESTITUTION
	
	self.body:CreateShape( carShapeDef )
	self.body:SetMassFromShapes()

	-- car wheel
	local wheelDef = b2BodyDef()
	wheelDef.position:Set( startx+35, starty+35 + CAR_WHEEL_OFFSET )
	wheelDef.linearDamping = CAR_LINEAR_DAMPING
	wheelDef.angularDamping = CAR_ANGULAR_DAMPING
	wheelDef.isBullet = true
	self.wheel = self.map.world:CreateBody( wheelDef )

	local wheelShapeDef = b2PolygonDef()
	wheelShapeDef:SetAsBox( CAR_WHEEL_SIZE_X/2, CAR_WHEEL_SIZE_Y/2 )
	wheelShapeDef.density = CAR_WHEEL_DENSITY

	self.wheel:CreateShape( wheelShapeDef )
	self.wheel:SetMassFromShapes()

	-- car rear wheel
	local rearWheelDef = b2BodyDef()
	rearWheelDef.position:Set( startx+35, starty+35 + CAR_REAR_WHEEL_OFFSET )
	rearWheelDef.linearDamping = CAR_LINEAR_DAMPING
	rearWheelDef.angularDamping = CAR_ANGULAR_DAMPING
	rearWheelDef.isBullet = true
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

function uppuRacingCarObject:CreateBody_Poong( startx, starty )
	-- create car body
	local carDef = b2BodyDef()
	carDef.position:Set( startx+35, starty+35 )
	carDef.linearDamping = CAR_LINEAR_DAMPING
	carDef.angularDamping = CAR_ANGULAR_DAMPING
	self.body = self.map.world:CreateBody( carDef )	-- 공을 생성
	
	local carShapeDef = b2PolygonDef()
	carShapeDef:SetAsBox(CAR_POONG_WIDTH/2, CAR_POONG_HEIGHT/2)
	carShapeDef.density = CAR_DENSITY
	carShapeDef.restitution = CAR_RESTITUTION
	
	self.body:CreateShape( carShapeDef )
	self.body:SetMassFromShapes()

	-- car wheel
	local wheelDef = b2BodyDef()
	wheelDef.position:Set( startx+35, starty+35 + CAR_WHEEL_OFFSET )
	wheelDef.linearDamping = CAR_LINEAR_DAMPING
	wheelDef.angularDamping = CAR_ANGULAR_DAMPING
	self.wheel = self.map.world:CreateBody( wheelDef )

	local wheelShapeDef = b2PolygonDef()
	wheelShapeDef:SetAsBox( CAR_WHEEL_SIZE_X/2, CAR_WHEEL_SIZE_Y/2 )
	wheelShapeDef.density = CAR_WHEEL_DENSITY

	self.wheel:CreateShape( wheelShapeDef )
	self.wheel:SetMassFromShapes()

	-- car rear wheel
	local rearWheelDef = b2BodyDef()
	rearWheelDef.position:Set( startx+35, starty+35 + CAR_REAR_WHEEL_OFFSET )
	rearWheelDef.linearDamping = CAR_LINEAR_DAMPING
	rearWheelDef.angularDamping = CAR_ANGULAR_DAMPING
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

function uppuRacingCarObject:CreateBody_Pyagi( startx, starty )
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

function uppuRacingCarObject:CreateBody_Toto( startx, starty )
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

function uppuRacingCarObject:CreateBody_Hoochi( startx, starty )
	-- create car body
	local carDef = b2BodyDef()
	carDef.position:Set( startx+40, starty+40 )
	carDef.linearDamping = 1
	carDef.angularDamping = 1 --0.1
	self.body = self.map.world:CreateBody( carDef )	-- 공을 생성
	
	local carShapeDef = b2CircleDef()
	carShapeDef.radius = 30 --37
	carShapeDef.density = CAR_DENSITY*2
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