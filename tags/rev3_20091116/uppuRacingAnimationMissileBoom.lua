require "uppuRacingCarAnimation"

class 'uppuRacingAnimationMissileBoom' (uppuRacingCarAnimation)

function uppuRacingAnimationMissileBoom:__init(car, aniType) super(car, aniType)
	self:SetLoop(false)				-- 반복여부
	self:SetDelay(0.1)				-- 프레임당 플레이 시간   
	self:SetOffset(20, 20)			-- owner로부터 상대 위치

	-- add boost frames
	self:AddBoostFrames()
end

function uppuRacingAnimationMissileBoom:AddBoostFrames()
	for i=4, 9 do
		local frame = StaticImage()
		--frame:LoadStaticImage("images/ido_up_ef_020.bmp", 7, 1, nil, UIConst.Blue)	-- 70x70 이미지
		frame:LoadStaticImage("images/ido_up_ef_012.bmp", 5, 2, nil, UIConst.Blue)	-- 70x70 이미지
		frame:SetStaticImageIndex(i)
		frame:SetXPivot( frame:GetWidth()/2 )
		frame:SetYPivot( frame:GetHeight()/2 )
		self:AddFrame(frame)
	end
end
