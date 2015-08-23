require 'uppuRacingConsts'
require 'uppuRacingContactFilter'

class 'uppuRacingMap' (b2ContactListener)

function uppuRacingMap:__init(name, scene, tilex, tiley, owner) super()
	self.name = name
	self.scene = scene

	self.mapSize = Vector2(tilex, tiley)	-- x축 타일 개수, y축 타일 개수 (타일 60x60)
	self.startPoint = {}
	self.objects = {}
	self.elapsedTime = 0
	self.owner = owner
	self.passRects = {}
	
	-- create box2d world
	self:CreateWorld()

	self.animBoom = Image()
	self.animBoom:LoadControlImage("images/ido_up_ef_012.bmp", 5, 2, nil, UIConst.Blue)	-- 70x70 이미지
end

-- world를 만든다.
function uppuRacingMap:CreateWorld()
	worldAABB = b2AABB()
	worldAABB.lowerBound:Set( 0, 0 )
	worldAABB.upperBound:Set( self.mapSize.x*TILE_SIZE_X, self.mapSize.y*TILE_SIZE_Y )

	gravity = b2Vec2( 0, 0 )
	doSleep = true

	self.world = b2World( worldAABB, gravity, doSleep )
	self.world:SetContactListener( self )

	local contactFilter = uppuRacingContactFilter()
	self.world:SetContactFilter( contactFilter )
end

function uppuRacingMap:SetUserCar(car)
	self.car = car
end

function uppuRacingMap:GetUserCar()
	return self.car
end

function uppuRacingMap:Update(elapsed)
	-- delete missile image
	if self.animBoom:GetImageIndex() >= self.animBoom:GetImageCount()-1 then
		self.animBoom:StopAnimation()
		self.animBoom:Show(false)
	end

	self.elapsedTime = self.elapsedTime + elapsed

	local simulated = self:SimulateWorld()
	if simulated then
		self:UpdateObjects(elapsed)
	end

	if self.car then
		self:Scroll()
	end

	return simulated
end

function uppuRacingMap:SimulateWorld()
	local timeStep = 1.0 / 20.0
	local iterations = 10

	-- 시뮬레이션을 빨리 하기 위해서 실제 시뮬레이션 속도보다 2배 빠르게 했음
	local simulated = false
	while self.elapsedTime >= timeStep/2 do
		self.world:Step( timeStep, iterations )
		self.elapsedTime = self.elapsedTime - timeStep/2

		simulated = true
	end

	return simulated
end

function uppuRacingMap:Scroll()
	-- scroll
	local pivotx = self.car:GetXPos()
	if pivotx < SCREEN_SIZE_X/2 then
		pivotx = SCREEN_SIZE_X/2
	elseif pivotx > self.mapSize.x*TILE_SIZE_X - SCREEN_SIZE_X/2 then
		pivotx = self.mapSize.x*TILE_SIZE_X - SCREEN_SIZE_X/2
	end
	local pivoty = self.car:GetYPos()
	if pivoty < SCREEN_SIZE_Y/2 then
		pivoty = SCREEN_SIZE_Y/2
	elseif pivoty > self.mapSize.y*TILE_SIZE_Y - SCREEN_SIZE_Y/2 then
		pivoty = self.mapSize.y*TILE_SIZE_Y - SCREEN_SIZE_Y/2
	end
	gameapp:SetScreenPivot(pivotx, pivoty)
end

function uppuRacingMap:FindObject(oid)
	return self.objects[oid]
end

function uppuRacingMap:DeleteObject(oid)
	local object = self.objects[oid]
	if object then
		object:Destroy()
		self.objects[oid] = nil
	end
end

function uppuRacingMap:UpdateObjects(elapsed)
	for oid, object in pairs(self.objects) do
		assert(object)
		assert(object.classtype)

		if object.classtype	== CLASS_MASTER or object.classtype == CLASS_NPO then
			local x = object.body:GetPosition().x
			local y = object.body:GetPosition().y

			if object:IsDirty() then
				local event = object:MakeMessageObject_Sync()
				gameapp:SendUnreliableToServer(event)
	
				-- set prev pos&angle
				object.prevBodyPos = b2Vec2(x, y)
				object.prevBodyAngle = object.body:GetAngle()
			end

			-- 지정한 구역을 순서대로 도는 지 확인
			if object:GetClassName() == "uppuRacingCarObject" and self.passRects[object.pass+1]:PtInRect(x, y) then
				object.pass = object.pass + 1
				if object.pass == #self.passRects then
					object.pass = 0
					object.lap = object.lap + 1
				end

				-- 정해진 바퀴 수를 다 돌았나 확인
				if object.lap == self.finalLap then
					local msg = Message(Game_CutFinish)
					gameapp:SendToServer(msg)
				end
			end

		elseif object.classtype	== CLASS_SLAVE then
		--elseif object.classtype	== CLASS_NPO then
		else
			assert(0)
		end

		object:Update(elapsed)
	end
end

--
-- box2d contact listner
--
function uppuRacingMap:Add( contactPoint )

end

function uppuRacingMap:Persist( contactPoint )

end

function uppuRacingMap:Remove( contactPoint )
	--local filter1 = contactPoint.shape1:GetFilterData()
	--local filter2 = contactPoint.shape2:GetFilterData()
 --
	--if filter1.categoryBits == COLLISION_FILTER_CATEGORY_MISSILE or filter2.categoryBits == COLLISION_FILTER_CATEGORY_MISSILE then
	--	--self.map:GetUserCar():OnAnimateEnd(0, ANITYPE_MISSILE)
	--	self.animBoom:StopAnimation()
	--	self.animBoom:Show(false)
	--end
end

function uppuRacingMap:Result( contactPoint )
	local filter1 = contactPoint.shape1:GetFilterData()
	local filter2 = contactPoint.shape2:GetFilterData()
	local body1 = contactPoint.shape1:GetBody()
	local body2 = contactPoint.shape2:GetBody()
	local object1 = body1:GetUserData()
	local object2 = body2:GetUserData()

	-- 둘 중 하나가 미사일이면
	if filter1.categoryBits == COLLISION_FILTER_CATEGORY_MISSILE then
		contactPoint.shape1:GetBody():PutToSleep()
 
 		self:AnimateMissileBoom( contactPoint.position )
		--self:DeleteObject(object1.oid)
		return
	elseif filter2.categoryBits == COLLISION_FILTER_CATEGORY_MISSILE then
		contactPoint.shape2:GetBody():PutToSleep()
 
		self:AnimateMissileBoom( contactPoint.position )
		--self:DeleteObject(object2.oid)
		return
	end

	-- 둘 중 하나가 NPO이면

	if object1 and object2 then
		local msg = Message(Object_Lock)
		if object1.classtype == CLASS_NPO and object2.classtype == CLASS_MASTER then
			object1.owner = object2.owner
			object1:SetDirty()
			msg:SetValue(Object_Lock.key.no, object2.owner)
			msg:SetValue(Object_Lock.key.oid, object1.oid)	
			gameapp:SendToServer(msg)
		elseif object2.classtype == CLASS_NPO and object1.classtype == CLASS_MASTER then
			object2.owner = object1.owner
			object2:SetDirty()
			msg:SetValue(Object_Lock.key.no, object1.owner)
			msg:SetValue(Object_Lock.key.oid, object2.oid)	
			gameapp:SendToServer(msg)
		else
			-- NPO끼리 충돌하면??
			if object1.owner == self.owner then
				object2.owner = object1.owner

				object1:SetDirty()
				object2:SetDirty()
	
				msg:SetValue(Object_Lock.key.no, self.owner)
				msg:SetValue(Object_Lock.key.oid, object1.oid)	
				gameapp:SendToServer(msg)
	
				msg:SetValue(Object_Lock.key.no, self.owner)
				msg:SetValue(Object_Lock.key.oid, object2.oid)	
				gameapp:SendToServer(msg)
			end
		end
	end
end

function uppuRacingMap:AnimateMissileBoom(pos)
	local x = pos.x - self.animBoom:GetWidth()/2
	local y = pos.y - self.animBoom:GetHeight()/2

	if self.animBoom:IsAnimating() == false then
		self.animBoom:Show(true)
		self.scene:AddChild( self.animBoom )
		self.animBoom:SetXYPos( x, y )
		self.animBoom:AnimateImage(4, 9, 0.5, 1)
	end
end

function uppuRacingMap:AddObject(object)
	assert(object)
	assert(object.oid)

	self.objects[object.oid] = object

	if object:GetClassName() == "uppuRacingCarObject" then
		local x, y = self:GetXYPos(self.startPoint[object.owner])
		object:SetPosition(x, y, math.pi*3/2)
		object.lap = 0
		object.pass = 0
	end
end

function uppuRacingMap:GetXYPos(tileIndex)
	local x = ((tileIndex-1) % self.mapSize.x)*TILE_SIZE_X
	local y = ((tileIndex-1 - ((tileIndex-1) % self.mapSize.x)) / self.mapSize.x)*TILE_SIZE_Y

	return x, y
end
