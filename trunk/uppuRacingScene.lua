require "go.ui.Scene"
require "go.service.idogame.PlayerInfo"
require "uppuRacingProtocol"
require "uppuRacingCarObject"
require "uppuRacingSlaveCarObject"
require "uppuRacingSlaveMissileObject"
require "uppuRacingTestMap"
require "uppuRacingSnowMap"
require "uppuRacingWaterMap"
require "uppuRacingConsts"

class 'uppuRacingScene' (Scene)

function uppuRacingScene:__init(id)	super(id)
	self:SetupUIObjects()

	-- 800 x 600 screen
	self:SetScreenPivot(SCREEN_SIZE_X/2, SCREEN_SIZE_Y/2)

	math.randomseed(os.clock())

	-- box2d world
	self.map = nil

	self.start = false			-- recv ReadyGo message
	self.startTime = 0			-- time that recv ReadyGo
	self.finishTime = 0			-- time that cut finish
	self.debug = false			-- turn on/off debug
	self.maxTrafficSent = 0		-- max traffic sent

	-- for printing rtt of all player
	self.rtts = { self.rtt1, self.rtt2, self.rtt3, self.rtt4 }
end

function uppuRacingScene:ToggleDebug()
	if self.debug then
		self.debug = false
	else
		self.debug = true
	end
end

function uppuRacingScene:IsDebug()
	return self.debug
end

function uppuRacingScene:PlayReadyGo()
	self.imageCountDown:Show(false)
	self:RemoveChild(self.imageCountDown)
	self.imageCountDown = nil

	local object = self["hsvGo"]:Clone()
	--Hsv()
	--object:LoadHsv("images/go.hsv")
	self:AddChild(object)

	local pivot = gameapp:GetScreenPivot()
	object:SetXPos(pivot.x)
	object:SetYPos(pivot.y-100)
	object:Play(1)
	object:Show(true)

	-- todo: ready go 플레이가 끝나면 키 입력 가능하도록...
end

function uppuRacingScene:PlayWin()
	local object = Hsv()
	object:LoadHsv("images/win.hsv")
	self:AddChild(object)
	object.SpriteFinished:AddHandler( self, self.OnSpriteFinished )

	local pivot = gameapp:GetScreenPivot()
	object:SetXPos(pivot.x - 450)
	object:SetYPos(pivot.y - 200)
	object:Play(1)
	object:Show(true)

	gameapp.sndPlaying:StopSound()
	gameapp.sndYouWin:PlaySound(false)
end

function uppuRacingScene:PlayRetire()
	local pivot = gameapp:GetScreenPivot()
	self.imageRetire:SetXPos(pivot.x - self.imageRetire:GetWidth()/2)
	self.imageRetire:SetYPos(pivot.y - 100)
	self.imageRetire:Show(true)
	self.imageRetire:BringToTop()
	
	--self:RemoveChild(object)

	-- set car retire
	local car = self.map:FindObject(GetCarOID(gameapp.playerNo))
	if car then car.retire = true end
end

function uppuRacingScene:OnSpriteFinished( sender, msg )
	gameapp.sndPlaying:PlaySound(true)
	print("sprite finished")
end

function uppuRacingScene:PlayRank(rank)
	-- confirm: stop race timer
	if self.finishTime == 0 then
		self.finishTime = App.GetCurrentSeconds()
	end

	if rank == 1 then
		self:PlayWin()
		return
	end

	local object = StaticImage()
	object:LoadStaticImage("images/ido_up_tx_005.bmp", 6, 1, nil, 0xFF4AA9EB)
	self:AddChild(object)

	gameapp.sndFinished:PlaySound(false)

	object:SetXPos(350)
	object:SetYPos(270)
	object:SetXScale(2)
	object:SetYScale(2)
	object:AnimateStaticImage(rank-1, rank-1, 1, 1)
	object:Show(true)

end

function uppuRacingScene:PlayCount(count)
	local pivot = gameapp:GetScreenPivot()

	print (string.format("CountDown = %d, pivot = (%f, %f)", count, pivot.x, pivot.y))

	if self.imageCountDown == nil then
		self.imageCountDown = self.imageBigNumber:Clone()
		self:AddChild(self.imageCountDown)
	end

	self.imageCountDown:SetXPos(pivot.x)
	self.imageCountDown:SetYPos(pivot.y-100)
	self.imageCountDown:SetNumber(count-1)
	self.imageCountDown:Show(true)
end

function uppuRacingScene:ShowGameResult(ranks, retireRank)
	-- remove retire image
	self.imageRetire:Show(false)

	self.resultObjects = {}

	for rank, no in pairs(ranks) do
		if no == nil then
			break
		end

		local imageBar = self.imageResultBar:Clone()
		self:AddChild(imageBar)

		local pivot = gameapp:GetScreenPivot()

		local x = pivot.x - 400
		local y = pivot.y - 300 + rank*70
		imageBar:SetXYPos(x, y)
		imageBar:Show(true)

		-- print text
		local textId = Text()
		self:AddChild(textId)
		textId:SetText(self.userList[no].nickname)
		textId:SetTextColor(UIConst.White)
		textId:SetXYPos(x + 172, y + 28)
		textId:Show(true)

		local imageRank = self.rankNumber:Clone()
		self:AddChild(imageRank)
	
		imageRank:SetXYPos(x + 23, y + 21)
		imageRank:SetStaticImageIndex(rank-1)
		imageRank:Show(true)

		self.resultObjects[#self.resultObjects] = imageBar
		self.resultObjects[#self.resultObjects] = textId
		self.resultObjects[#self.resultObjects] = imageRank
	end
end

function uppuRacingScene:HideGameResult()
	if self.resultObjects then
		for i, object in pairs(self.resultObjects) do
			object:Show(false)
			self:RemoveChild(object)
		end
		self.resultObjects = nil
	end
end

function uppuRacingScene:StartRacing()
	self:PlayReadyGo()
	self.start = true
	self.startTime = App.GetCurrentSeconds()
	self.finishTime	= 0
	
	self.userList = {}
	for no, state in pairs(gameapp.listUserState) do
		print (string.format("StartRacing: id = %s", state.nickname))
		self.userList[no] = gameapp.playerInfos[no]
	end
end

function uppuRacingScene:EndRacing()
	self.start = false
end

function uppuRacingScene:IsStarted()
	return self.start
end

function uppuRacingScene:CreateMap(playerno)
	if self.map == nil then
		if gameapp.gameState.mapNo == 1 then
			self.map = uppuRacingSnowMap("SnowMap", self, playerno)
		elseif gameapp.gameState.mapNo == 2 then
			self.map = uppuRacingWaterMap("WaterMap", self, playerno)
		else
			self.map = uppuRacingTestMap("(Test) IceMap1", self, playerno)
		end
	end
end

function uppuRacingScene:DeleteMap()
	self.map:Destroy()
	self.map = nil
end

function uppuRacingScene:CreateMasterCar(name, playerno, startpos)
	local pos = b2Vec2(startpos.x, startpos.y)
	local car = uppuRacingCarObject(name, playerno, self, self.map, pos,
		gameapp.listUserState[playerno].carType )
	self.map:SetUserCar(car)
	self.map:AddObject(car)

	return car	
end

function uppuRacingScene:CreateSlaveCar(name, playerno, startpos)
	local pos = b2Vec2(startpos.x, startpos.y)
	local car = uppuRacingSlaveCarObject(name, playerno, GetCarOID(playerno), pos, 0, 0,
		gameapp.listUserState[playerno].carType, self.map.world)
	self.map:AddObject(car)

	return car	
end

function uppuRacingScene:ObjectCreate(owner, oid, pos0, r0, v0, vr)
	if self.map == nil then
		return
	end

	assert(nil == self.map:FindObject(oid))

	-- todo: 현재는 무조건 missile
	local missile = uppuRacingSlaveMissileObject(owner, oid, pos0, r0, v0)
	self.map:AddObject(missile)
end

function uppuRacingScene:ObjectLock(owner, oid)
	if self.map == nil then
		return
	end

	local object = self.map:FindObject(oid)
	if object and object.classtype ~= CLASS_NPO then
		object.owner = owner
	end
end

function uppuRacingScene:ObjectSync(owner, oid, pos0, r0, v0, vr)
	if self.map == nil then
		return
	end

	local object = self.map:FindObject(oid)
	if object and object.classtype ~= CLASS_MASTER then
		object:Sync(owner, oid, pos0, r0, v0, vr)
	end
end

function uppuRacingScene:ObjectDelete(owner, oid, pos0, r0, v0, vr)
	if self.map == nil then
		return
	end

	local object = self.map:FindObject(oid)
	if object and object.deleteAnimation then
		object:AnimateDeletingObject(pos0)
	end
	self.map:DeleteObject(oid, -1)	-- todo: trigger player id will be set
end

function uppuRacingScene:ObjectForce(srcoid, tgtoid, pos0, force)
	local object = self.map:FindObject(tgtoid)
	if object then
		object:Force(pos0, force)
		-- todo: 현재는 차가 미사일에 맞는 경우만 고려했음
		if object.classname == "uppuRacingCarObject" then
			object:SetGroggy(0.3)
		end
	end
end

function uppuRacingScene:EffectSync(owner, oid, effect)
	if self.map == nil then
		return
	end

	local object = self.map:FindObject(oid)
	if object then
		object:AnimateEffect(effect)
	end
end

function uppuRacingScene:SetScreenPivot(x, y)
	self.pivot = Vector2(x, y)
end

function uppuRacingScene:Update(elapsed)
	if gameapp:GetSelfPlayer() == nil then
		return
	end

	-- update map
	local simulated = false
	if self.map then
		simulated = self.map:Update(elapsed)
	end

	-- update count image
	local pivot = gameapp:GetScreenPivot()
	if self.imageCountDown ~= nil then
		self.imageCountDown:SetXPos(pivot.x)
		self.imageCountDown:SetYPos(pivot.y-100)
	end

	self.imageRetire:SetXPos(pivot.x - self.imageRetire:GetWidth()/2)
	self.imageRetire:SetYPos(pivot.y - 100)

	self:ShowDebugText()
end

function uppuRacingScene:ShowDebugText()
	if self:IsDebug() == false then
		self.carpos:Show(false)
		self.rtt1:Show(false)
		self.rtt2:Show(false)
		self.rtt3:Show(false)
		self.rtt4:Show(false)
		self.trafficSent:Show(false)
		self.passlog:Show(false)
		return
	end

	if self.map and self.map:GetUserCar() then	
		local pivot = gameapp:GetScreenPivot()
		local x = self.map:GetUserCar().body:GetPosition().x
		local y = self.map:GetUserCar().body:GetPosition().y
		local textX = pivot.x - SCREEN_SIZE_X/2 + 9
		local textY = pivot.y - SCREEN_SIZE_Y/2 + 7

		-- debug text (print my car's pos)
		self.carpos:SetXYPos(textX, textY)
		self.carpos:BringToTop()
		self.carpos:Show(true)
		self.carpos:SetText( string.format("my pos (%03d, %03d)", x, y))

		-- show rtts
		for i, text in pairs(self.rtts) do
			self.rtts[i]:SetXYPos(textX, textY+10*i)
			self.rtts[i]:BringToTop()
			self.rtts[i]:Show(true)
			if gameapp.rtt[i] then
				self.rtts[i]:SetText(string.format("player%d's ping: %04dms", i, gameapp.rtt[i]))
			end
		end

		self.trafficSent:SetXYPos(textX+200, textY)
		self.trafficSent:BringToTop()
		self.trafficSent:Show(true)

		local traffic = GetLastTrafficSent()
		if self.maxTrafficSent < traffic then
			self.maxTrafficSent = traffic
		end

		self.trafficSent:SetText(string.format("traffic: %.2fKB/s (max: %.2fKB/s)", traffic/1000, self.maxTrafficSent/1000))

		self.passlog:SetXYPos(textX+200, textY+10)
		self.passlog:BringToTop()
		self.passlog:Show(true)

		local car = self.map:GetUserCar()
		self.passlog:SetText(string.format("lap: %d/%d, pass: %d/%d", car.lap, self.map.finalLap, car.pass, #self.map.passRects))

		self.textSpeed:SetXYPos(textX+200, textY+20)
		self.textSpeed:BringToTop()
		self.textSpeed:Show(true)

		self.textSpeed:SetText(string.format("speed: %f, mass: %f", car:GetSpeed(), car:GetMass()))
	end
end

require "uppuRacingSceneUIObject"
