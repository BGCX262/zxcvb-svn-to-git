require "uppuRacingMap"
require "uppuRacingPenguinBlockObject"
require "uppuRacingHighBlockObject"
require "uppuRacingTileObject"
require "uppuRacingIceTileObject"
require "uppuRacingTrapObject"
require "uppuRacingBombBoxObject"
require "uppuRacingLowBlockObject"

class 'uppuRacingTestMap' (uppuRacingMap)

function uppuRacingTestMap:__init(name, scene, owner) super(name, scene, 20, 20, owner)
	self.tempObjects = {}

	self:LoadLevelIceWorld()
	self.finalLap = 2
end

function uppuRacingTestMap:Destroy()
	for i, object in pairs(self.tempObjects) do
		object:Destroy()
	end
end

function uppuRacingTestMap:LoadLevelIceWorld()
	local objectImageName = "images/ido_up_bg004_002.bmp"
	local tileImageName = "images/ido_up_bg004_001.bmp"
	local imageTile = StaticImage()
	local imageObject = StaticImage()
	imageTile:LoadStaticImage(tileImageName, 15, 17, nil, UIConst.Blue)	-- 60x60 이미지
	imageObject:LoadStaticImage(objectImageName, 15, 10, nil, UIConst.Blue)	-- 60x60 이미지

	-- 13x10 (780x600)
	local tiles =   { 
	                  0  , 1  , 2  , 3  , 4  , 5  , 6  , 7  , 7  , 7  , 7  , 7  , 7  , 7  , 7  , 7  , 7  , 7  , 7  , 8  ,
	                  15 , 16 , 16 , 16 , 16 , 16 , 55 , 16 , 16 , 999, 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 23 ,
	                  15 , 16 , 16 , 16 , 16 , 16 , 55 , 16 , 16 , 999, 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 23 ,
	                  15 , 16 , 16 , 16 , 16 , 16 , 55 , 16 , 16 , 999, 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 23 ,
	                  15 , 16 , 16 , 16 , 16 , 16 , 55 , 16 , 16 , 999, 16 , 16 , 16 , 16 , 16 , 16 , 74 , 16 , 16 , 23 ,
	                  15 , 16 , 16 , 205, 16 , 143, 145, 144, 145, 144, 145, 144, 145, 144, 146, 16 , 16 , 16 , 16 , 23 ,
	                  15 , 16 , 205, 205, 16 , 158, 159, 159, 159, 159, 159, 159, 159, 159, 159, 146, 16 , 16 , 16 , 23 ,
	                  15 , 16 , 16 , 205, 143, 159, 159, 159, 159, 159, 159, 159, 159, 159, 159, 161, 16 , 16 , 16 , 23 ,
	                  15 , 40 , 40 , 40 , 158, 159, 159, 159, 159, 159, 159, 159, 159, 159, 159, 191, 25 , 25 , 25 , 23 ,
	                  15 , 16 , 74 , 16 , 158, 159, 159, 189, 189, 189, 189, 189, 189, 189, 191, 16 , 16 , 16 , 16 , 23 ,
	                  30 , 16 , 16 , 16 , 188, 159, 159, 191, 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 205, 205, 16 , 38 ,
	                  45 , 16 , 16 , 205, 205, 188, 191, 16 , 16 , 16 , 16 , 16 , 16 , 74 , 16 , 16 , 205, 16 , 16 , 53 ,
	                  60 , 16 , 16 , 205, 205, 205, 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 68 ,
	                  75 , 16 , 16 , 205, 205, 205, 155, 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 83 ,
	                  60 , 16 , 16 , 16 , 74 , 74 , 74 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 74 , 74 , 16 , 16 , 68 ,	--
	                  75 , 16 , 74 , 16 , 16 , 16 , 155, 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 83 ,	--
	                  90 , 16 , 16 , 16 , 16 , 16 , 56 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 98 ,
	                  105, 16 , 16 , 16 , 16 , 16 , 56 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 113,
	                  105, 74 , 16 , 16 , 16 , 16 , 56 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 16 , 113,
	                  120, 121, 122, 123, 124, 125, 126, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 128
				    }
	local objects = {
	                  999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999,
	                  999, 999, 999, 999, 999, 999, 999, 999, 999, 999,  -1, 999, 999, 999, 999, 999, 244, 999, 999, 999,
	                  999, 999, 999, 999, 999, 999, 999, 999, 999, 999,  -2, 999, 999, 152, 999, 999, 999, 999, 999, 999,
	                  999, 999, 999, 140, 999, 999, 999, 999, 999, 999,  -3, 999, 999, 999, 999, 999, 999, 999, 999, 999,
	                  999, 999, 999, 141, 999, 999, 999, 999, 999, 999,  -4, 999, 999, 245, 999, 999, 999, 999, 999, 999,
	                  999, 999, 999, 999, 999, 999, 5  , 6  , 6  , 6  , 6  , 6  , 6  , 6  , 9  , 999, 999, 999, 999, 999,
	                  999, 999, 999, 142, 999, 999, 20 , 55 , 56 , 112, 91 , 91 , 92 , 116, 20 , 999, 999, 151, 999, 999,
	                  999, 999, 999, 999, 5  , 6  , 69 , 70 , 71 , 85 , 92 , 130, 130, 999, 65 , 9  , 999, 999, 999, 999,
	                  999, 999, 999, 999, 20 , 91 , 116, 99 , 999, 100, 999, 999, 999, 5  , 6  , 69 , 999, 999, 999, 999,
	                  999, 999, 143, 999, 20 , 130, 5  , 6  , 6  , 6  , 6  , 6  , 6  , 69 , 999, 242, 243, 999, 999, 999,
	                  999, 999, 999, 999, 65 , 6  , 69 , 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999,
	                  999, 999, 999, 999, 999, 113, 112, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999,
	                  999, 999, 999, 999, 999, 999, 999, 999, 999, 114, 78 , 79 , 999, 999, 999, 86 , 87 , 999, 999, 999,
	                  999, 999, 999, 240, 999, 999, 999, 999, 999, 999, 93 , 94 , 999, 999, 999, 101, 102, 999, 999, 999,
	                  999, 999, 999, 999, 999, 999, 999, 113, 999, 999, 999, 999, 999, 146, 999, 999, 999, 999, 999, 999,
	                  999, 999, 999, 999, 121, 122, 21 , 21 , 113, 999, 999, 21 , 999, 999, 999, 147, 148, 999, 999, 999,
	                  999, 999, 999, 144, 999, 999, 999, 999, 999, 999, 999, 21 , 999, 999, 999, 241, 999, 999, 999, 999,
	                  999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 149, 999, 999, 999,
	                  999, 999, 999, 999, 999, 999, 999, 145, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999,
	                  999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999
				    }

	-- load tiles
	for i, tileIndex in pairs(tiles) do
		local tile = nil
		if tileIndex == 999 then
			tile = Scene.latestScene["imageFinishLine"]:Clone()
		else
			tile = imageTile:Clone()
			tile:SetStaticImageIndex(tileIndex)
		end

		local object = nil
		local x, y = self:GetXYPos(i)
		local pos = b2Vec2(x, y)

		-- 바닥 타일이 아니면 물리 설정
		if (tileIndex >= 0 and tileIndex <= 8) or (tileIndex >= 120 and tileIndex <= 128)
		    or (tileIndex >= 0 and tileIndex <= 120 and tileIndex%15 == 0)
			or (tileIndex >= 8 and tileIndex <= 128 and tileIndex%15 == 8) then
			object = uppuRacingHighBlockObject(self.world, pos, 0, tile)
		elseif tileIndex == 74 then
			object = uppuRacingTrapObject(self.world, pos, 0, tile)
		elseif tileIndex == 205 then
			object = uppuRacingIceTileObject(self.world, pos, 0, tile)
		else
			object = uppuRacingTileObject(pos, 0, tile)
		end

		self.tempObjects[#self.tempObjects + 1] = object
	end

	-- load objects
	for i, objectIndex in pairs(objects) do
		if objectIndex ~= 999 and objectIndex > 0 then		
			local object = nil
			local x, y = self:GetXYPos(i)
			local pos = b2Vec2(x, y)
			
			if objectIndex >= 140 and objectIndex <= 199 then
				local oid = self:GetNewOID() -- objectIndex -- objectIndex를 oid로 쓰자
				object = uppuRacingPenguinBlockObject(self.world, oid, pos, 0)

				self.objects[oid] = object
			elseif objectIndex >= 240 and objectIndex <= 250 then
				local oid = self:GetNewOID() -- objectIndex
				object = uppuRacingBombBoxObject(self.world, oid, pos, 0)

				self.objects[oid] = object
			elseif objectIndex >= 112 and objectIndex <= 114 then
				local image = imageObject:Clone()
				image:SetStaticImageIndex(objectIndex)
				object = uppuRacingLowBlockObject(self.world, pos, 0, true, image)
			else 
				local image = imageObject:Clone()
				image:SetStaticImageIndex(objectIndex)
				object = uppuRacingHighBlockObject(self.world, pos, 0, image)

				-- 움직이지 않는 block이므로, self.objects에 추가하지 않아도 됨
			end

			self.tempObjects[#self.tempObjects + 1] = object
		end

		-- set starting point
		if objectIndex < 0 then
			self.startPoint[ math.abs(objectIndex) ] = i
		end
	end

	-- set pass rect
	self.passRects[1] = Rect(0, 480, 240, 540)
	self.passRects[2] = Rect(540, 600, 600, 1140)
	self.passRects[3] = Rect(960, 480, 1200, 540)
	self.passRects[4] = Rect(540, 0, 600, 300)

	self:SendNPOList()
end

function uppuRacingTestMap:SendNPOList()
	local msg = Message(Object_NPO_List)
	local npolist = List()
	local count = 0
	for oid, object in pairs(self.objects) do
		if object.classtype == CLASS_NPO then
			npolist:Add(oid)
			count = count + 1

			-- 10개씩 묶어서 보냄
			-- RUDP 패킷 크기 문제...
			if count == 10 then
				local npostring = npolist:GetString()
				msg:SetValue(Object_NPO_List.key.list, npostring)
				gameapp:SendToServer(msg)

				npolist:Clear()
				count = 0
			end
		end
	end

	local npostring = npolist:GetString()
	msg:SetValue(Object_NPO_List.key.list, npostring)
	gameapp:SendToServer(msg)
end
