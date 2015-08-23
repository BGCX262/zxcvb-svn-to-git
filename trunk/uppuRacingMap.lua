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
	self.finalLap = 3
	self.raceTime = 0

	self.itemImages = {}
	self.ownObjectId = 0
	
	-- create box2d world
	self:CreateWorld()
end

function uppuRacingMap:GetNewOID()
	self.ownObjectId = self.ownObjectId + 1
	if self.ownObjectId >= 9999 then
		self.ownObjectId = 1
	end

	return self.ownObjectId
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
	self.elapsedTime = self.elapsedTime + elapsed

	local simulated = self:SimulateWorld()
	if simulated then
		self:UpdateObjects(elapsed)
	end

	if self.car then
		self:Scroll()
		--self:CheckCollision()
	end

	-- LAPS, TIME, BEST
	self:ShowRaceBoard()
	self:ShowItemBox()

	return simulated
end

--function uppuRacingMap:CheckCollision()
--	-- missile and slave car (image collision)
--	for oid, object in pairs(self.objects) do
--		if object:GetClassName() == "uppuRacingSlaveCarObject" then
--			if self.car.missile then
--				-- missile and slave car collision!!!
--				if self.car.missile.image:IntersectCollBox(object.image) then
--					self.car.missile.body:PutToSleep()
--
--			 		self.car.missile:AnimateMissileBoom(b2Vec2(self.car.missile.image:GetXYPos()))
--					self.car.missile.image:EnableCollision(false)
--					self:DeleteObject(self.car.missile.oid, self.owner)
--				end
--			end
--		end
--	end
--end

function uppuRacingMap:SetItemInItemBox(item, index, x, y)
	if self.itemImages[index] == nil then
		local image = self.scene["imageItems"]:Clone()
		self.scene:AddChild(image)
		self.itemImages[index] = image
	end

	--local imageName = "images/itembox_" .. item .. ".bmp"
 --
	--self.itemImages[index]:LoadControlImage(imageName, 1, 1, nil, UIConst.Blue)

	-- Z=booster, X=jump, C=missile
	if index == 1 or index == 2 then
		self.itemImages[index]:SetStaticImageIndex(index+1)
	else
		self.itemImages[index]:SetStaticImageIndex(1)
	end
	--self.itemImages[index]:SetWidth(ITEM_SIZE)
	--self.itemImages[index]:SetHeight(ITEM_SIZE)
	self.itemImages[index]:SetXYPos(x, y)
	self.itemImages[index]:BringToTop()
	--self.itemImages[index]:SetAlpha(0.3)
	self.itemImages[index]:Show(true)
end

function uppuRacingMap:ShowItemBox()
	local pivot = gameapp:GetScreenPivot()
	local textX = pivot.x - SCREEN_SIZE_X/2 + 20
	local textY = pivot.y - SCREEN_SIZE_Y/2 + 20

	self.scene.imageItemBox1:SetXYPos(textX, textY)
	self.scene.imageItemBox1:BringToTop()
	self.scene.imageItemBox1:Show(true)

	-- todo: empty item box
	self:SetItemInItemBox("empty", 1, textX, textY)

	self.scene.textItemZ:SetXYPos(textX+2, textY+2)
	self.scene.textItemZ:BringToTop()
	self.scene.textItemZ:Show(true)

	self.scene.imageItemBox2:SetXYPos(textX+35, textY)
	self.scene.imageItemBox2:BringToTop()
	self.scene.imageItemBox2:Show(true)

	-- todo: empty item box
	self:SetItemInItemBox("empty", 2, textX+35, textY)

	self.scene.textItemX:SetXYPos(textX+36, textY+2)
	self.scene.textItemX:BringToTop()
	self.scene.textItemX:Show(true)

	self.scene.imageItemBox3:SetXYPos(textX+70, textY)
	self.scene.imageItemBox3:BringToTop()
	self.scene.imageItemBox3:Show(true)

	-- todo: empty item box
	self:SetItemInItemBox("empty", 3, textX+70, textY)

	self.scene.textItemC:SetXYPos(textX+71, textY+2)
	self.scene.textItemC:BringToTop()
	self.scene.textItemC:Show(true)
end

function uppuRacingMap:ShowRaceBoard()
	local pivot = gameapp:GetScreenPivot()
	local textX = pivot.x + SCREEN_SIZE_X/2 - 250
	local textY = pivot.y - SCREEN_SIZE_Y/2 + 20

	self.scene.textLaps:SetXYPos(textX, textY)
	self.scene.textLaps:BringToTop()
	self.scene.textLaps:Show(true)

	local carLap = self.car.lap+1
	if carLap > self.finalLap then carLap = self.finalLap end
	self.scene.textLapsData:SetText(string.format("%d/%d", carLap, self.finalLap))
	self.scene.textLapsData:SetXYPos(textX+60, textY)
	self.scene.textLapsData:BringToTop()
	self.scene.textLapsData:Show(true)

	self.scene.textTime:SetXYPos(textX, textY+24)
	self.scene.textTime:BringToTop()
	self.scene.textTime:Show(true)

	if self.scene.start then
		if self.scene.finishTime == 0 then
			self.raceTime = App.GetCurrentSeconds() - self.scene.startTime
		else
			self.raceTime = self.scene.finishTime - self.scene.startTime
		end
	end

	self.scene.textTimeData:SetText(TimeToString(self.raceTime))
	self.scene.textTimeData:SetXYPos(textX+60, textY+24)
	self.scene.textTimeData:BringToTop()
	self.scene.textTimeData:Show(true)

	self.scene.textBest:SetXYPos(textX, textY+48)
	self.scene.textBest:BringToTop()
	self.scene.textBest:Show(true)

	if gameapp.bestRecord then
		self.scene.textBestData:SetText(TimeToString(gameapp.bestRecord.besttime))
		self.scene.textBestNickName:SetText(gameapp.bestRecord.nickname)
	else
		self.scene.textBestData:SetText(string.format("%02d:%02d:%02d", 0, 0, 0))
		self.scene.textBestNickName:SetText("No Record")
	end
	self.scene.textBestData:SetXYPos(textX+60, textY+48)
	self.scene.textBestData:BringToTop()
	self.scene.textBestData:Show(true)

	self.scene.textBestNickName:SetXYPos(textX+165, textY+48)
	self.scene.textBestNickName:BringToTop()
	self.scene.textBestNickName:Show(true)
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

function uppuRacingMap:AddObject(object)
	assert(object)
	assert(object.oid)

	self.objects[object.oid] = object

	if object:GetClassName() == "uppuRacingCarObject" then
		local x, y = self:GetXYPos(self.startPoint[object.owner])
		object:SetPosition(x, y, math.pi*3/2)
		object.lap = 0
		object.pass = 0
	elseif object:GetClassName() == "uppuRacingMissileObject" then
		local msg = object:MakeMessageObject_Create()
		gameapp:SendUnreliableToServer(msg)
	end
end

function uppuRacingMap:FindObject(oid)
	return self.objects[oid]
end

function uppuRacingMap:DeleteObject(oid, triggerPlayerno)
	local object = self.objects[oid]
	if object and triggerPlayerno == self.owner then
		if object:GetClassName() == "uppuRacingMissileObject" or object:GetClassName() == "uppuRacingBombBoxObject" then
			local msg = object:MakeMessageObject_Delete()
			gameapp:SendUnreliableToServer(msg)
		end
		
		-- delayed delete가 아닌 넘들은 여기서 지워진다.
		if object:DelayedDelete() == false then
			object:Destroy()
			self.objects[oid] = nil
		end
	end
end

function uppuRacingMap:UpdateObjects(elapsed)
	for oid, object in pairs(self.objects) do
		assert(object)
		assert(object.classtype)

		-- delayed delete인 넘들은 여기서 지워진다.
		if object:DelayedDelete() and object:CanDelete() then
			object:Destroy()
			self.objects[oid] = nil
		else
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
						-- stop race timer
						self.scene.finishTime = self.scene.startTime + self.raceTime

						local msg = Message(Game_CutFinish)
						msg:SetValue(Game_CutFinish.key.retire, false)
						msg:SetValue(Game_CutFinish.key.time, self.raceTime)

						print (string.format("#### send best time %s", self.raceTime))

						gameapp:SendToServer(msg)
						gameapp:ResetRetireTimer()
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
end

--
-- box2d contact listner
--
function uppuRacingMap:Add( contactPoint )
	--print ("Collision Add")

	local filter1 = contactPoint.shape1:GetFilterData()
	local filter2 = contactPoint.shape2:GetFilterData()
	local body1 = contactPoint.shape1:GetBody()
	local body2 = contactPoint.shape2:GetBody()
	local object1 = body1:GetUserData()
	local object2 = body2:GetUserData()
 
	-- 벽돌에 부딪히면 object == nil
	if object1 == nil or object2 == nil then
		return
	end
 
	-- 둘 중 하나가 미사일이면
	if filter1.categoryBits == COLLISION_FILTER_CATEGORY_MISSILE and object2:GetClassName() == "uppuRacingSlaveCarObject" then
		self:CollisionMissile_Car(object1, object2, contactPoint)
		return
	elseif filter2.categoryBits == COLLISION_FILTER_CATEGORY_MISSILE and object1:GetClassName() == "uppuRacingSlaveCarObject" then
		self:CollisionMissile_Car(object2, object1, contactPoint)
		return
	end
end

function uppuRacingMap:Persist( contactPoint )
	local body1 = contactPoint.shape1:GetBody()
	local body2 = contactPoint.shape2:GetBody()
	local object1 = body1:GetUserData()
	local object2 = body2:GetUserData()

	if object1 and object2 then
		local impulse = contactPoint.normal --b2Vec2(TRAP_FORCE, 0) -- 
		Multiply(impulse, -TRAP_FORCE)

		-- 함정의 효과 적용
		if object1.trap == true and object2.classtype == CLASS_MASTER then
			body2:ApplyTorque(TRAP_TORQUE)
			body2:ApplyForce(impulse, contactPoint.position)
		elseif object2.trap == true and object1.classtype == CLASS_MASTER then
			body1:ApplyTorque(TRAP_TORQUE)
			body1:ApplyForce(impulse, contactPoint.position)
		end

		-- 미끄러짐 효과 적용
		if object1.icetile == true and object2.classtype == CLASS_MASTER then
			object2.nofriction = true
		elseif object2.icetile == true and object1.classtype == CLASS_MASTER then
			object1.nofriction = true
		end
	end
end

function uppuRacingMap:Remove( contactPoint )
	print ("Collision Remove")

	local body1 = contactPoint.shape1:GetBody()
	local body2 = contactPoint.shape2:GetBody()
	local object1 = body1:GetUserData()
	local object2 = body2:GetUserData()

	if object1 and object2 then
		-- 미끄러짐 효과 제거
		if object1.icetile == true and object2.classtype == CLASS_MASTER then
			object2.nofriction = false
		elseif object2.icetile == true and object1.classtype == CLASS_MASTER then
			object1.nofriction = false
		end
	end
end

function uppuRacingMap:Result( contactPoint )
	--print ("Collision Result")

	local filter1 = contactPoint.shape1:GetFilterData()
	local filter2 = contactPoint.shape2:GetFilterData()
	local body1 = contactPoint.shape1:GetBody()
	local body2 = contactPoint.shape2:GetBody()
	local object1 = body1:GetUserData()
	local object2 = body2:GetUserData()

	-- 둘 중 하나가 미사일이면
	if filter1.categoryBits == COLLISION_FILTER_CATEGORY_MISSILE then
		contactPoint.shape1:GetBody():PutToSleep()
 
 		object1:AnimateMissileBoom( contactPoint.position )
		self:DeleteObject(object1.oid, self.owner)
		return
	elseif filter2.categoryBits == COLLISION_FILTER_CATEGORY_MISSILE then
		contactPoint.shape2:GetBody():PutToSleep()
 
		object2:AnimateMissileBoom( contactPoint.position )
		self:DeleteObject(object2.oid, self.owner)
		return
	end
	
	-- 둘 중 하나가 NPO이면
	if object1 and object2 then
		if object1.classtype == CLASS_NPO and object2.classtype == CLASS_MASTER then
			self:CollisionNPO_Master(object1, object2, contactPoint)
		elseif object2.classtype == CLASS_NPO and object1.classtype == CLASS_MASTER then
			self:CollisionNPO_Master(object2, object1, contactPoint)
		else
			self:CollisionNPO_NPO(object1, object2, contactPoint)
		end
	end
end

function uppuRacingMap:GetXYPos(tileIndex)
	local x = ((tileIndex-1) % self.mapSize.x)*TILE_SIZE_X
	local y = ((tileIndex-1 - ((tileIndex-1) % self.mapSize.x)) / self.mapSize.x)*TILE_SIZE_Y

	return x, y
end

function uppuRacingMap:CollisionNPO_Master(npo, master, contactPoint)
	local object1 = npo
	local object2 = master

	local msg = Message(Object_Lock)

	-- bomb box랑 car랑 충돌시
	if object1.classname == "uppuRacingBombBoxObject" and object2.classname == "uppuRacingCarObject" then
		object1.body:PutToSleep()

		object1:AnimateBoom()
		local impulse = contactPoint.normal 
		Multiply(impulse, BOMBBOX_FORCE)
		object2.body:ApplyForce(impulse, contactPoint.position) --object2.body:GetPosition())
		--object2.body:ApplyTorque(BOMBBOX_TORQUE)
		object2:SetGroggy(0.5)
		self:DeleteObject(object1.oid, self.owner)
	else
		object1.owner = object2.owner
		object1:SetDirty()
		msg:SetValue(Object_Lock.key.no, object2.owner)
		msg:SetValue(Object_Lock.key.oid, object1.oid)	
		gameapp:SendToServer(msg)
	end
end

function uppuRacingMap:CollisionNPO_NPO(object1, object2, contactPoint)
	local msg = Message(Object_Lock)
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

function uppuRacingMap:CollisionMissile_Car(object1, object2, contactPoint)
	contactPoint.shape1:GetBody():PutToSleep()

	if object1:AnimateMissileBoom( contactPoint.position ) then
		self:DeleteObject(object1.oid, self.owner)

		local msg = Message(Object_Force)
		msg:SetValue(Object_Force.key.srcoid, object1.oid)
		msg:SetValue(Object_Force.key.tgtoid, object2.oid)
		msg:SetValue(Object_Force.key.fx, contactPoint.normal.x*MISSILE_FORCE)
		msg:SetValue(Object_Force.key.fy, contactPoint.normal.y*MISSILE_FORCE)
		msg:SetValue(Object_Force.key.x, contactPoint.position.x)
		msg:SetValue(Object_Force.key.y, contactPoint.position.y)

		gameapp:SendUnreliableToServer(msg)
	end
end