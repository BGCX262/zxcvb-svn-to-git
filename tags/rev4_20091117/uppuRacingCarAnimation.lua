require "go.ui.control.StaticImage"
require "go.ui.sound.Sound"
require "uppuRacingConsts"

class 'uppuRacingCarAnimation'

function uppuRacingCarAnimation:__init(car, aniType)
	--self.name = name				-- animation name (id)
	self.car = car					-- owner
	self.aniType = aniType			-- 0: car, 1: effect, 2: missile
	self.frame = {}					-- 프레임 테이블

	self:SetLoop(false)				-- 반복여부
	self:SetDelay(0.15)				-- 프레임당 플레이 시간   
	self:SetOffset(0, 0)			-- owner로부터 상대 위치
	
	self:Reset()					-- animation reset
end

function uppuRacingCarAnimation:SetOffset(x, y)
	self.offset = Vector2(x, y)
end

function uppuRacingCarAnimation:SetLoop(loop)
	if loop == nil then return end
	self.loop = loop
end

function uppuRacingCarAnimation:SetDelay(delay)
	self.delayPerFrame = delay
end

function uppuRacingCarAnimation:AddFrame(staticimage, sound)
	local id = #self.frame+1

	local frame = staticimage
	Scene.latestScene:AddChild(frame)

	frame:Show(false)
	frame.sound = sound

	self.frame[id] = frame

	return frame
end

--function uppuRacingCarAnimation:AddMoveFrame(sound)
----	if self.name == "idle" then
--		startIndex = 0
--		endIndex = 3
--	--elseif self.name == "walk" then
--	--	startIndex = 0
--	--	endIndex = 3
--	--end
--
--	for i=0, 7 do
--		local id = #self.frame+1
--		local frame = Image()
--	
--		Scene.latestScene:AddChild(frame)
--	
--		frame:LoadControlImage("images/ido_up_ch001_010.bmp", 4, 5, nil, UIConst.Blue)	-- 70x70 이미지
--		--if i < 8 then
--			frame:SetImageIndex(i%2)		-- 0, 1 반복
--		--else
--		--	frame:SetStaticImageIndex(3)		-- 3 추가
--		--end
--
--		frame:SetXPivot(35)
--		frame:SetYPivot(35)
--		frame:Show(false)
--
--		self.frame[id] = frame
--		frame.sound = sound
--	end
--
--	return frame
--end

function uppuRacingCarAnimation:NextFrame(elapsed, bodyx, bodyy, angle)
	local frameNo = math.floor((self.playtime+elapsed)/self.delayPerFrame)+1
	if frameNo > self.frameNo then
		self.frameNo = self.frameNo+1
 		frameNo = self.frameNo
	end

	if frameNo <= #self.frame then
		if self.frame[frameNo-1] then
			self.frame[frameNo-1]:Show(false)
		end
		if self.frame[frameNo] then
			local x = bodyx - self.offset.x
 			local y = bodyy - self.offset.y
			self.frame[frameNo]:SetXYPos(x, y)

 			self.frame[frameNo]:SetRotate(angle)
			self.frame[frameNo]:Show(true)
		else
			print("error! frame missing : ", frameNo)
		end
	elseif self.loop then
		self:Reset()
		self:NextFrame(elapsed, bodyx, bodyy, angle)
	else
		self.car:OnAnimationEnd(elapsed, self.aniType)
	end
end

function uppuRacingCarAnimation:Reset()
	for i=1, #self.frame do
		self.frame[i]:Show(false)
	end
	self.frameNo = 0
	self.playtime = -0.0001
end

function uppuRacingCarAnimation:UpdateSound()
	local frame = self.frame[self.frameNo]
	if frame == nil then return nil end
	if frame.sound == nil then return nil end
	frame.sound:PlaySound()
end

function uppuRacingCarAnimation:Update(elapsed, bodyx, bodyy, angle)
	self:NextFrame(elapsed, bodyx, bodyy, angle)
	self:UpdateSound()

	self.playtime = self.playtime + elapsed
end
