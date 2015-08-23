require "uppuRacingMap"
require "uppuRacingPenguinBlockObject"
require "uppuRacingHighBlockObject"
require "uppuRacingTileObject"

class 'uppuRacingTestMap' (uppuRacingMap)

function uppuRacingTestMap:__init(name, scene, owner) super(name, scene, 14, 12, owner)
	self:LoadLevelIceWorld()
	self.finalLap = 1
end

function uppuRacingTestMap:LoadLevelIceWorld()
	local objectImageName = "images/ido_up_bg004_002.bmp"
	local tileImageName = "images/ido_up_bg004_001.bmp"

	-- 13x10 (780x600)
	local tiles =   { 
	                  0  , 1  , 2  , 3  , 4  , 5  , 6  , 7  , 7  , 7  , 7  , 7  , 7  , 8  ,
	                  15 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 23 ,
	                  30 , 16 , 16 , 16 , 16 , 55 , 55 , 55 , 16 , 16 , 16 , 16 , 16 , 38 ,
	                  45 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 53 ,
	                  60 , 16 , 40 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 25 , 16 , 16 , 68 ,
	                  75 , 16 , 40 , 16 , 16 , 16 , 155, 16 , 16 , 16 , 25 , 16 , 16 , 83 ,
	                  60 , 16 , 40 , 16 , 16 , 16 , 155, 16 , 16 , 16 , 25 , 16 , 16 , 68 ,	--
	                  75 , 16 , 40 , 16 , 16 , 16 , 155, 16 , 16 , 16 , 25 , 16 , 16 , 83 ,	--
	                  90 , 16 , 16 , 16 , 16 , 16 , 155, 16 , 16 , 16 , 16 , 16 , 16 , 98 ,
	                  105, 16 , 16 , 16 , 16 , 56 , 56 , 56 , 16 , 16 , 16 , 16 , 16 , 113,
	                  105, 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 113,
	                  120, 121, 122, 123, 124, 125, 126, 127, 127, 127, 127, 127, 127, 128
				    }
	local objects = {
	                  999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999,
	                  999, 999, 999, 999, 999, 999,  -1, 999, 999, 140, 999, 999, 999, 999,
	                  999, 999, 999, 999, 999, 999,  -2, 999, 999, 999, 999, 999, 999, 999,
	                  999, 141, 999, 999, 999, 999,  -3, 999, 999, 999, 999, 147, 999, 999,
	                  999, 999, 999, 999, 999, 999,  -4, 999, 999, 999, 999, 120, 999, 999,
	                  999, 999, 999, 999, 78 , 79 , 120, 78 , 79 , 999, 999, 135, 999, 999,
	                  999, 999, 999, 999, 93 , 94 , 135, 93 , 94 , 142, 999, 999, 999, 999,
	                  999, 999, 145, 999, 78 , 79 , 120, 78 , 79 , 999, 999, 999, 999, 999,	--
	                  999, 999, 999, 999, 93 , 94 , 135, 93 , 94 , 999, 999, 999, 143, 999,	--
	                  999, 999, 999, 999, 144, 999, 999, 999, 999, 999, 999, 999, 999, 999,
	                  999, 999, 999, 999, 999, 999, 999, 999, 146, 999, 999, 999, 999, 999,
	                  999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999
				    }

	-- load tiles
	for i, tileIndex in pairs(tiles) do
		local tile = StaticImage()
		tile:LoadStaticImage(tileImageName, 15, 17, nil, UIConst.Blue)	-- 60x60 이미지
		tile:SetStaticImageIndex(tileIndex)

		local object = nil
		local x, y = self:GetXYPos(i)
		local pos = b2Vec2(x, y)

		-- 바닥 타일이 아니면 물리 설정
		if tileIndex ~=16 and tileIndex ~=155 and tileIndex ~= 25 and tileIndex ~= 40 and tileIndex ~= 55 and tileIndex ~= 56 then
			object = uppuRacingHighBlockObject(self.world, pos, 0, tile)
		else
			object = uppuRacingTileObject(pos, 0, tile)
		end

		--self.tiles[i] = tile
	end

	-- load objects
	for i, objectIndex in pairs(objects) do
		if objectIndex ~= 999 and objectIndex > 0 then		
			local object = nil
			local x, y = self:GetXYPos(i)
			local pos = b2Vec2(x, y)
			
			if objectIndex >= 140 and objectIndex <= 149 then
				local oid = objectIndex -- objectIndex를 oid로 쓰자
				object = uppuRacingPenguinBlockObject(self.world, oid, pos, 0)

				self.objects[oid] = object
			else
				local image = StaticImage()
				image:LoadStaticImage(objectImageName, 15, 10, nil, UIConst.Blue)	-- 60x60 이미지
				image:SetStaticImageIndex(objectIndex)
				object = uppuRacingHighBlockObject(self.world, pos, 0, image)

				-- 움직이지 않는 block이므로, self.objects에 추가하지 않아도 됨
			end
		end

		-- set starting point
		if objectIndex < 0 then
			self.startPoint[ math.abs(objectIndex) ] = i
		end
	end

	-- set pass rect
	self.passRects[1] = Rect(0, 360, 240, 480)
	self.passRects[2] = Rect(300, 540, 420, 720)
	self.passRects[3] = Rect(540, 360, 900, 480)
	self.passRects[4] = Rect(300, 0, 420, 300)

	self:SendNPOList()
end

function uppuRacingTestMap:SendNPOList()
	local msg = Message(Object_NPO_List)
	local i = 1
	for oid, object in pairs(self.objects) do
		if object.classtype	== CLASS_NPO then
			if i == 1 then msg:SetValue(Object_NPO_List.key.n1, oid) end
			if i == 2 then msg:SetValue(Object_NPO_List.key.n2, oid) end
			if i == 3 then msg:SetValue(Object_NPO_List.key.n3, oid) end
			if i == 4 then msg:SetValue(Object_NPO_List.key.n4, oid) end
			if i == 5 then msg:SetValue(Object_NPO_List.key.n5, oid) end
			if i == 6 then msg:SetValue(Object_NPO_List.key.n6, oid) end
			if i == 7 then msg:SetValue(Object_NPO_List.key.n7, oid) end
			if i == 8 then msg:SetValue(Object_NPO_List.key.n8, oid) end
			if i == 9 then msg:SetValue(Object_NPO_List.key.n9, oid) end
			if i == 10 then msg:SetValue(Object_NPO_List.key.n10, oid) end
			
			i = i + 1 
		end
	end

	gameapp:SendToServer(msg)
end
