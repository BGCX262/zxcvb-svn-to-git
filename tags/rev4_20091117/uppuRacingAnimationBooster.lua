require "uppuRacingCarAnimation"

class 'uppuRacingAnimationBooster' (uppuRacingCarAnimation)

function uppuRacingAnimationBooster:__init(car, aniType) super(car, aniType)
	self:SetLoop(false)				-- 반복여부
	self:SetDelay(0.03)				-- 프레임당 플레이 시간   
	self:SetOffset(0, 0)			-- owner로부터 상대 위치

	-- add boost frames
	self:AddBoostFrames()
end

function uppuRacingAnimationBooster:AddBoostFrames()
	for r=1, 2 do
		for i=0, 7 do
			local frame = StaticImage()
			frame:LoadStaticImage("images/ido_up_ef_006.bmp", 8, 1, nil, UIConst.Blue)	-- 80x80 이미지
			frame:SetStaticImageIndex(i)
			frame:SetXPivot( frame:GetWidth()/2 )
			frame:SetYPivot( frame:GetHeight()/2 )
			self:AddFrame(frame)
		end
	end
end
