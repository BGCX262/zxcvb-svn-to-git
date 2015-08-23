require "uppuRacingCarAnimation"

class 'uppuRacingCarAnimationRun' (uppuRacingCarAnimation)

function uppuRacingCarAnimationRun:__init(car, aniType, filename) super(car, aniType)
	self:SetLoop(true)				-- 반복여부
	self:SetDelay(0.15)				-- 프레임당 플레이 시간   
	self:SetOffset(0, 0)			-- owner로부터 상대 위치

	-- add boost frames
	self:AddBoostFrames(filename)
end

function uppuRacingCarAnimationRun:AddBoostFrames(filename)
	local frame = StaticImage()

	frame:LoadStaticImage(filename, 4, 5, nil, UIConst.Blue)	-- 70x70 이미지

	frame:SetStaticImageIndex(0)
	frame:SetXPivot( frame:GetWidth()/2 )
	frame:SetYPivot( frame:GetHeight()/2 )
	self:AddFrame(frame)
end
