require "uppuRacingCarAnimation"

class 'uppuRacingCarAnimationJump' (uppuRacingCarAnimation)

function uppuRacingCarAnimationJump:__init(car, aniType, filename) super(car, aniType)
	self:SetLoop(false)				-- 반복여부
	self:SetDelay(0.03)				-- 프레임당 플레이 시간   
	self:SetOffset(0, 0)			-- owner로부터 상대 위치

	-- add boost frames
	self:AddBoostFrames(filename)
end

function uppuRacingCarAnimationJump:AddBoostFrames(filename)
	local curScale = 1
	for i=0, 23 do
		local frame = StaticImage()
		frame:LoadStaticImage(filename, 4, 5, nil, UIConst.Blue)	-- 70x70 이미지
		frame:SetStaticImageIndex(0)
		frame:SetXPivot( frame:GetWidth()/2 )
		frame:SetYPivot( frame:GetHeight()/2 )
		if i < 6 then
			curScale = curScale + 0.1
		elseif i >=6 and i <= 18 then
		else
			curScale = curScale - 0.1
		end
		frame:SetXScale( curScale )
		frame:SetYScale( curScale )
		self:AddFrame(frame)
	end
end
