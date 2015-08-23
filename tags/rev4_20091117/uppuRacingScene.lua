require "go.ui.Scene"
require "uppuRacingProtocol"
require "uppuRacingCarObject"
require "uppuRacingSlaveCarObject"
require "uppuRacingTestMap"
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
	local object = Hsv()
	object:LoadHsv("images/readygo.hsv")
	self:AddChild(object)

	object:SetXPos(300)
	object:SetYPos(250)
	object:Play(1)
	object:Show(true)

	-- todo: ready go 플레이가 끝나면 키 입력 가능하도록...
end

function uppuRacingScene:PlayWin()
	local object = Hsv()
	object:LoadHsv("images/win.hsv")
	self:AddChild(object)
	object.SpriteFinished:AddHandler( self, self.OnSpriteFinished )

	object:SetXPos(100)
	object:SetYPos(100)
	object:Play(1)
	object:Show(true)

	gameapp.sndPlaying:StopSound()
	gameapp.sndYouWin:PlaySound(false)
end

function uppuRacingScene:OnSpriteFinished( sender, msg )
	gameapp.sndPlaying:PlaySound(true)
	print("sprite finished")
end

function uppuRacingScene:PlayRank(rank)
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

function uppuRacingScene:StartRacing()
	self:PlayReadyGo()
	self.start = true	
end

function uppuRacingScene:EndRacing()
	self.start = false
end

function uppuRacingScene:IsStarted()
	return self.start
end

function uppuRacingScene:CreateMap(playerno)
	if self.map == nil then
		self.map = uppuRacingTestMap("basicMap", self, playerno)
	end
end

function uppuRacingScene:DeleteMap()
	self.map = nil
end

function uppuRacingScene:CreateMasterCar(name, playerno, controltype, startpos)
	local pos = b2Vec2(startpos.x, startpos.y)
	local car = uppuRacingCarObject(name, playerno, self, self.map, controltype, pos,
		gameapp.listUserState[playerno].carType )
	self.map:SetUserCar(car)
	self.map:AddObject(car)

	return car	
end

function uppuRacingScene:CreateSlaveCar(name, playerno, controltype, startpos)
	local pos = b2Vec2(startpos.x, startpos.y)
	local car = uppuRacingSlaveCarObject(name, playerno, playerno*100+1, pos, 0, 0,
		gameapp.listUserState[playerno].carType )
	self.map:AddObject(car)

	return car	
end

function uppuRacingScene:DeleteCar(playerno)
	self.map:DeleteObject(playerno*100+1)
end

function uppuRacingScene:ObjectLock(owner, oid)
	local object = self.map:FindObject(oid)
	if object and object.classtype ~= CLASS_NPO then
		object.owner = owner
	end
end

function uppuRacingScene:ObjectSync(owner, oid, pos0, r0, v0, vr)
	local object = self.map:FindObject(oid)
	if object and object.classtype ~= CLASS_MASTER then
		object:Sync(owner, oid, pos0, r0, v0, vr)
	end
end

--function uppuRacingScene:FindCar(playerno)
--	for name, car in pairs(self.carlist) do
--		if car.owner == playerno then
--			return car
--		end
--	end
--
--	-- not found
--	return nil
--end

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
	end
end

require "uppuRacingSceneUIObject"
