require "uppuRacingObject"
require "uppuRacingAnimationBooster"
require "uppuRacingAnimationCarJump"

class 'uppuRacingSlaveCarObject' (uppuRacingObject)

function uppuRacingSlaveCarObject:__init(name, owner, oid, pos, angle, vel, cartype, world) super(owner, CLASS_SLAVE)
	self.oid = oid
	self.classname = "uppuRacingSlaveCarObject"

	-- for slave
	self.imagePos = pos
	self.imageAngle = angle
	self.imageVel = vel

	self.name = name
	self.cartype = cartype
	self.image = self:LoadImage()

	self.world = world
	self.body = self:CreateBody(pos.x, pos.y)
	self.body:SetUserData(self)

	self.textName = self:LoadTextName()

	self.effectAnim = {}
	self.effectAnimName = "none"
	self:CreateAnimations()
end

function uppuRacingSlaveCarObject:GetXPos()
	return self.body:GetPosition().x
end

function uppuRacingSlaveCarObject:GetYPos()
	return self.body:GetPosition().y
end

function uppuRacingSlaveCarObject:GetAngle()
	return self.body:GetAngle()
end

function uppuRacingSlaveCarObject:CreateBody(x, y)
	-- 물리 객체 생성
	local objectDef = b2BodyDef()
	objectDef.position:Set(x + self.image:GetWidth()/2, y + self.image:GetHeight()/2)
	objectDef.linearDamping = 1
	objectDef.angularDamping = 1 --0.1

	local objectShapeDef = b2PolygonDef()
	objectShapeDef:SetAsBox(CAR_WIDTH/2, CAR_HEIGHT/2)
	objectShapeDef.isSensor = true
	objectShapeDef.density = CAR_DENSITY
	objectShapeDef.restitution = 0.1
	
	local objectBody = self.world:CreateBody(objectDef)
	objectBody:CreateShape(objectShapeDef)
	objectBody:SetMassFromShapes()

	self:SetLowWall(objectBody)
	return objectBody
end

function uppuRacingSlaveCarObject:LoadImage()
	local frame = gameapp.listUserState[self.owner].carImage:Clone()--Image()

--	frame:LoadControlImage(CAR_IMAGE[self.cartype][self.owner], 4, 5, nil, UIConst.Blue)	-- 70x70 이미지
	Scene.latestScene:AddChild(frame)

	--frame:EnableCollision(true)
	frame:AnimateStaticImage(0, 3, 1, -1)

	local imageWidth = frame:GetWidth()
	local imageHeight = frame:GetHeight()

	--frame:SetStaticImageIndex(0)
	frame:SetXPivot(imageWidth/2)
	frame:SetYPivot(imageHeight/2)
	frame:SetXPos(self.imagePos.x)
	frame:SetYPos(self.imagePos.y)

	frame:Show(true)

	return frame
end

function uppuRacingSlaveCarObject:LoadTextName()
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

function uppuRacingSlaveCarObject:Sync(owner, oid, pos0, r0, v0, vr)
	--self.imagePos.x = pos0.x
	--self.imagePos.y = pos0.y
	--self.imageAngle = r0
	self.body:SetXForm(pos0, r0)
	self.body:SetLinearVelocity(v0)
	-- set vel, vr
end

function uppuRacingSlaveCarObject:Update(elapsed)
	assert(self.image)
	assert(self.body)

	local x = self.body:GetPosition().x - self.image:GetWidth()/2
	local y = self.body:GetPosition().y - self.image:GetHeight()/2
	local angle = math.deg(self.body:GetAngle())

	self.image:SetXYPos(x, y)
	self.image:SetRotate(angle)

	self.textName:SetXPos(self.image:GetXPos())
	self.textName:SetYPos(self.image:GetYPos() - 5)

	if self.effectAnim[self.effectAnimName] then
		self.effectAnim[self.effectAnimName]:Update(elapsed)

		-- aninmate가 끝나면, 다시 none 상태로 변경
		if self.effectAnim[self.effectAnimName]:IsAnimating() == false then
			-- jump animation이 끝나면 다시 기본 차 animation이 보이도록 한다.
			if self.effectAnimName == "jump" then
				self.image:Show(true)
			end

			self.effectAnimName = "none"
		end
	end
end

function uppuRacingSlaveCarObject:Destroy()
	self.image:Show(false)
	self.textName:Show(false)
	self.world:DestroyBody(self.body)
end

function uppuRacingSlaveCarObject:CreateAnimations()
	local anim = nil
	
	-- jump 쓸 때
	anim = uppuRacingAnimationCarJump(self, CAR_IMAGE[self.cartype][self.owner])
	self.effectAnim["jump"] = anim

	-- booster 썼을 때
	anim = uppuRacingAnimationBooster(self)
	self.effectAnim["booster"] = anim
end

function uppuRacingSlaveCarObject:AnimateEffect(effect)
	if self.effectAnim[effect] then
		-- 기존 animation은 cancel한다.
		if self.effectAnim[self.effectAnimName] then
			self.effectAnim[self.effectAnimName]:Reset()
		end
		-- 기존 animation이 jump였다면, image를 다시 show상태로 변경한다.
		if self.effectAnimName == "jump" then
			self.image:Show(true)
		end

		-- 새로운 animation을 play한다.
		self.effectAnim[effect]:Play()
		self.effectAnimName = effect

		if effect == "jump" then
			self.image:Show(false)
		end
	end
end
