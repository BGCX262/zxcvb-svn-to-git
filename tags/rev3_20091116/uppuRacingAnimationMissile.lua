require "uppuRacingCarAnimation"

class 'uppuRacingAnimationMissile' (uppuRacingCarAnimation)

function uppuRacingAnimationMissile:__init(car, aniType) super(car, aniType)
	self:SetLoop(true)				-- 반복여부
	self:SetDelay(0.15)				-- 프레임당 플레이 시간   
--	self:SetOffset(0, 0)			-- owner로부터 상대 위치
	self:SetOffset( 30, 30 )

	-- add boost frames
	self:AddBoostFrames()
end

function uppuRacingAnimationMissile:AddBoostFrames()
	for i=0, 3 do
		local frame = StaticImage()
	
		frame:LoadStaticImage("images/ido_up_ob_001.bmp", 4, 6, nil, UIConst.Blue)	-- 60x60 이미지
	
		frame:SetStaticImageIndex(i)
		frame:SetXPivot( frame:GetWidth()/2 )
		frame:SetYPivot( frame:GetHeight()/2 )
		self:AddFrame(frame)
	end
end
