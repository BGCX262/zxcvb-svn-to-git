require "go.app.ServerApp"
require "MapEditorProtocol"
require "MapEditorConsts"
require "go.service.idogame.GameData"

class 'MapEditorServerApp' (ServerApp)

function MapEditorServerApp:__init()	super()	
	math.randomseed(os.time())

	self.gameData = GameData()
	self.gameData:Load()

	if self.gameData.userdata.n == nil then
		self.gameData.userdata.n = 0
		self.gameData.userdata.row = { }
		self.gameData.userdata.col = { }
		self.gameData.userdata.tn = { }
		self.gameData.userdata.ti = { }
		self.gameData.userdata.tt = { }
		self.gameData.userdata.on = { }
		self.gameData.userdata.oi = { }
		self.gameData.userdata.ot = { }
	end

	self.mapNumber = self.gameData.userdata.n + 1

	self.mapRow = 0
	self.mapCol = 0
	self.mapUnitTileImageNumberList = { }
	self.mapUnitTileImageIndexList = { }
	self.mapUnitTileImageTypeList = { }
	self.mapUnitObjectImageNumberList = { }
	self.mapUnitObjectImageIndexList = { }
	self.mapUnitObjectImageTypeList = { }

	self.currentMapImage = 1
	self.currentMapImageIndex = 0
	self.currentType = "T"

	self:SetMsgHandler( Evt_CreateMap, self.OnCreateMap )
	self:SetMsgHandler( Evt_SaveMap, self.OnSaveMap )
	self:SetMsgHandler( Evt_LoadMap, self.OnLoadMap )
	self:SetMsgHandler( Evt_PrintMap, self.OnPrintMap )

	self:SetMsgHandler( Evt_Select, self.OnSelect )
	self:SetMsgHandler( Evt_SelectMapUnit, self.OnSelectMapUnit )
	self:SetMsgHandler( Evt_CancelMapUnit, self.OnCancelMapUnit )
end

---------------------------------------------------------
-- Game Handler
---------------------------------------------------------
function MapEditorServerApp:OnEnterPlayer(player)
	if player.no == 2 then
		local msg = Message( Evt_InitMap )
		msg:SetValue( Evt_InitMap.key.numberOfMaps, self.gameData.userdata.n )
		self:SendTo( player, msg )
	end
end

function MapEditorServerApp:OnLeavePlayer(player)
		
end

---------------------------------------------------------
-- Network Handler
---------------------------------------------------------
function MapEditorServerApp:OnCreateMap( player, msg )
	self.mapNumber = self.gameData.userdata.n + 1

	self.mapRow = msg:GetValue( Evt_CreateMap.key.row )
	self.mapCol = msg:GetValue( Evt_CreateMap.key.col )

	for i = 1, self.mapRow do
		self.mapUnitTileImageNumberList[i] = { }
		self.mapUnitTileImageIndexList[i] = { }
		self.mapUnitTileImageTypeList[i] = { }
		self.mapUnitObjectImageNumberList[i] = { }
		self.mapUnitObjectImageIndexList[i] = { }
		self.mapUnitObjectImageTypeList[i] = { }

		for j = 1, self.mapCol do

			self.mapUnitTileImageNumberList[i][j] = self.currentMapImage
			self.mapUnitTileImageIndexList[i][j] = self.currentMapImageIndex
			self.mapUnitTileImageTypeList[i][j] = "T"
			self.mapUnitObjectImageNumberList[i][j] = -1
			self.mapUnitObjectImageIndexList[i][j] = 999
			self.mapUnitObjectImageTypeList[i][j] = "N"
		end
	end

	msg:SetValue( Evt_CreateMap.key.numberOfMaps, self.mapNumber )
	self:SendTo( player, msg )
end

function MapEditorServerApp:OnLoadMap( player, msg )
	self.gameData:Load()

	self.mapNumber = msg:GetValue( Evt_LoadMap.key.mapNumber )

	self.mapRow = self.gameData.userdata.row[ self.mapNumber ]
	self.mapCol = self.gameData.userdata.col[ self.mapNumber ]

	self.mapUnitTileImageNumberList = self:Copy2DimTable( self.gameData.userdata.tn[ self.mapNumber ] )
	self.mapUnitTileImageIndexList = self:Copy2DimTable( self.gameData.userdata.ti[ self.mapNumber ] )
	self.mapUnitTileImageTypeList = self:Copy2DimTable( self.gameData.userdata.tt[ self.mapNumber ] )
	self.mapUnitObjectImageNumberList = self:Copy2DimTable( self.gameData.userdata.on[ self.mapNumber] )
	self.mapUnitObjectImageIndexList = self:Copy2DimTable( self.gameData.userdata.oi[ self.mapNumber ] )
	self.mapUnitObjectImageTypeList = self:Copy2DimTable( self.gameData.userdata.ot[ self.mapNumber ] )

	msg:SetValue( Evt_LoadMap.key.row, self.mapRow )
	msg:SetValue( Evt_LoadMap.key.col, self.mapCol )
	self:SendTo( player, msg )

	local selectMsg = Message( Evt_Select )
	local selectUnitMsg = Message( Evt_SelectMapUnit )

	for i = 1, self.mapRow do
		for j = 1, self.mapCol do
			selectMsg:SetValue( Evt_Select.key.mapImage, self.mapUnitTileImageNumberList[i][j] )
			selectMsg:SetValue( Evt_Select.key.mapImageIndex, self.mapUnitTileImageIndexList[i][j] )
			selectMsg:SetValue( Evt_Select.key.mapType, self.mapUnitTileImageTypeList[i][j] )
			self:SendTo( player, selectMsg )

			selectUnitMsg:SetValue( Evt_SelectMapUnit.key.row, i )
			selectUnitMsg:SetValue( Evt_SelectMapUnit.key.col, j )
			self:SendTo( player, selectUnitMsg )

			if self.mapUnitObjectImageNumberList[i][j] ~= -1 then
				selectMsg:SetValue( Evt_Select.key.mapImage, self.mapUnitObjectImageNumberList[i][j] )
				selectMsg:SetValue( Evt_Select.key.mapImageIndex, self.mapUnitObjectImageIndexList[i][j] )
				selectMsg:SetValue( Evt_Select.key.mapType, self.mapUnitObjectImageTypeList[i][j] )
				
				self:SendTo( player, selectMsg )
				self:SendTo( player, selectUnitMsg )
			end

		end
	end

end

function MapEditorServerApp:OnSaveMap( player, msg )
	self.mapNumber = msg:GetValue( Evt_SaveMap.key.numberOfMaps )

	if self.mapNumber > self.gameData.userdata.n then
		self.gameData.userdata.n = self.mapNumber
		msg:SetValue( Evt_SaveMap.key.numberOfMaps, self.mapNumber )
		self:SendTo( player, msg )
	end

	self.gameData.userdata.row[self.mapNumber] = self.mapRow
	self.gameData.userdata.col[self.mapNumber] = self.mapCol

	
	self.gameData.userdata.tn[self.mapNumber] = self:Copy2DimTable( self.mapUnitTileImageNumberList )
	self.gameData.userdata.ti[self.mapNumber] = self:Copy2DimTable( self.mapUnitTileImageIndexList )
	self.gameData.userdata.tt[self.mapNumber] = self:Copy2DimTable( self.mapUnitTileImageTypeList )
	self.gameData.userdata.on[self.mapNumber] = self:Copy2DimTable( self.mapUnitObjectImageNumberList )
	self.gameData.userdata.oi[self.mapNumber] = self:Copy2DimTable( self.mapUnitObjectImageIndexList )
	self.gameData.userdata.ot[self.mapNumber] = self:Copy2DimTable( self.mapUnitObjectImageTypeList )

	self.gameData:Save()
	self.gameData:Load()

end

function MapEditorServerApp:OnPrintMap( player, msg )
	local no = msg:GetValue( Evt_PrintMap.key.mapNumber )
	local mapName = "uppuRacingMap" .. no

	local str = ""

-- require field
	str = str .. "require \34uppuRacingMap\34\n"
	str = str .. "require \34uppuRacingPenguinBlockObject\34\n"
	str = str .. "require \34uppuRacingHighBlockObject\34\n"
	str = str .. "require \34uppuRacingTileObject\34\n"
	str = str .. "require \34uppuRacingIceTileObject\34\n"
	str = str .. "require \34uppuRacingTrapObject\34\n"
	str = str .. "require \34uppuRacingBombBoxObject\34\n"
	str = str .. "require \34uppuRacingLowBlockObject\34\n\n"

-- class definition
	str = str .. "class '" .. mapName .. "' (uppuRacingMap)\n\n"

-- __init
	str = str .. "function " .. mapName .. ":__init(name, scene, owner) super(name, scene, "
		.. self.mapCol .. ", " .. self.mapRow .. ", owner)\n\n"
	str = str .. "\tself:LoadLevelIceWorld()\n"
	str = str .. "\tself.finalLap = 1\n"
	str = str .. "end\n\n"

-- LoadLevelIceWorld
	str = str .. "function " .. mapName .. ":LoadLevelIceWorld()\n\n"

	str = str .. "\tlocal imageList = { }\n"
	for i = 1, #MAP_IMAGE_FILE do
		local tempStr = MAP_IMAGE_FILE[i]
		local tx = 0
		local ty = 0
		tx, ty = string.find( tempStr, "\\" )
		tempStr = string.sub( tempStr, 1, tx-1 ) .. "\\\\" .. string.sub( tempStr, ty+1 )

		str = str .. "\timageList[" .. i .. "] = StaticImage()\n"
		str = str .. "\timageList[" .. i .. "]:LoadStaticImage(\34" .. tempStr .. "\34, "
		str = str .. MAP_IMAGE_FILE_COL[i] .. ", " .. MAP_IMAGE_FILE_ROW[i] .. ", nil, UIConst.Blue)\n"
	end
	str = str .. "\n"

	str = str .. "\tlocal tileImageNumber = { \n"
	for i = 1, self.mapRow do
		str = str .. "\t\t"
		for j = 1, self.mapCol do
			if i == self.mapRow and j == self.mapCol then
				str = str .. self.mapUnitTileImageNumberList[i][j]
			else
				str = str .. self.mapUnitTileImageNumberList[i][j] .. ", "
			end
		end
		str = str .. "\n"
	end
	str = str .."\t}\n\n"

	str = str .. "\tlocal tileImageIndex = { \n"
	for i = 1, self.mapRow do
		str = str .. "\t\t"
		for j = 1, self.mapCol do
			if i == self.mapRow and j == self.mapCol then
				str = str .. self.mapUnitTileImageIndexList[i][j]
			else
				str = str .. self.mapUnitTileImageIndexList[i][j] .. ", "
			end
		end
		str = str .. "\n"
	end
	str = str .."\t}\n\n"

	str = str .. "\tlocal tileImageType = { \n"
	for i = 1, self.mapRow do
		str = str .. "\t\t"
		for j = 1, self.mapCol do
			if i == self.mapRow and j == self.mapCol then
				str = str .. "\34" .. self.mapUnitTileImageTypeList[i][j] .. "\34"
			else
				str = str .. "\34" .. self.mapUnitTileImageTypeList[i][j] .. "\34, "
			end
		end
		str = str .. "\n"
	end
	str = str .."\t}\n\n"

	str = str .. "\tlocal objectImageNumber = { \n"
	for i = 1, self.mapRow do
		str = str .. "\t\t"
		for j = 1, self.mapCol do
			if i == self.mapRow and j == self.mapCol then
				str = str .. self.mapUnitObjectImageNumberList[i][j]
			else
				str = str .. self.mapUnitObjectImageNumberList[i][j] .. ", "
			end
		end
		str = str .. "\n"
	end
	str = str .."\t}\n\n"

	str = str .. "\tlocal objectImageIndex = { \n"
	for i = 1, self.mapRow do
		str = str .. "\t\t"
		for j = 1, self.mapCol do
			if i == self.mapRow and j == self.mapCol then
				str = str .. self.mapUnitObjectImageIndexList[i][j]
			else
				str = str .. self.mapUnitObjectImageIndexList[i][j] .. ", "
			end
		end
		str = str .. "\n"
	end
	str = str .."\t}\n\n"

	str = str .. "\tlocal objectImageType = { \n"
	for i = 1, self.mapRow do
		str = str .. "\t\t"
		for j = 1, self.mapCol do
			if i == self.mapRow and j == self.mapCol then
				str = str .. "\34" .. self.mapUnitObjectImageTypeList[i][j] .. "\34"
			else
				str = str .. "\34" .. self.mapUnitObjectImageTypeList[i][j] .. "\34, "
			end
		end
		str = str .. "\n"
	end
	str = str .."\t}\n\n"

	str = str .. "\tfor i, tileIndex in pairs(tileImageIndex) do\n"
	str = str .. "\t\tlocal tile = imageList[ tileImageNumber[i] ]:Clone()\n"
	str = str .. "\t\ttile:SetStaticImageIndex( tileImageIndex[i] )\n\n"

	str = str .. "\t\tlocal object = nil\n"
	str = str .. "\t\tlocal x, y = self:GetXYPos(i)\n"
	str = str .. "\t\tlocal pos = b2Vec2(x, y)\n\n"

	str = str .. "\t\tif tileImageType[i] == \34TH\34 then\n"
	str = str .. "\t\t\tobject = uppuRacingHighBlockObject(self.world, pos, 0, tile)\n"
	str = str .. "\t\telseif tileImageType[i] == \34TT\34 then\n"
	str = str .. "\t\t\tobject = uppuRacingTrapObject(self.world, pos, 0, tile)\n"
	str = str .. "\t\telseif tileImageType[i] == \34TI\34 then\n"
	str = str .. "\t\t\tobject = uppuRacingIceTileObject(self.world, pos, 0, tile)\n"
	str = str .. "\t\telse\n"
	str = str .. "\t\t\tobject = uppuRacingTileObject(pos, 0, tile)\n"
	str = str .. "\t\tend\n\n"

	str = str .. "\tend\n\n"

	str = str .. "\tfor i, objectIndex in pairs(objectImageIndex) do\n"
	str = str .. "\t\tif objectIndex ~= 999 and objectIndex > 0 then\n"

	str = str .. "\t\t\tlocal object = nil\n"
	str = str .. "\t\t\tlocal x, y = self:GetXYPos(i)\n"
	str = str .. "\t\t\tlocal pos = b2Vec2(x, y)\n\n"

	str = str .. "\t\t\tif objectImageType[i] == \34OP\34 then\n"
	str = str .. "\t\t\t\tlocal oid = self:GetNewOID()\n"
	str = str .. "\t\t\t\tobject = uppuRacingPenguinBlockObject(self.world, oid, pos, 0)\n"
	str = str .. "\t\t\t\tself.objects[oid] = object\n"
	str = str .. "\t\t\telseif objectImageType[i] == \34OB\34 then\n"
	str = str .. "\t\t\t\tlocal oid = self:GetNewOID()\n"
	str = str .. "\t\t\t\tobject = uppuRacingBombBoxObject(self.world, oid, pos, 0)\n"
	str = str .. "\t\t\t\tself.objects[oid] = object\n"
	str = str .. "\t\t\telseif objectImageType[i] == \34OL\34 then\n"
	str = str .. "\t\t\t\timageList[ objectImageNumber[i] ]:SetStaticImageIndex( objectImageIndex[i] )\n"
	str = str .. "\t\t\t\tobject = uppuRacingLowBlockObject(self.world, pos, 0, true, imageList[ objectImageNumber[i] ]:Clone() )\n"
	str = str .. "\t\t\telse\n"
	str = str .. "\t\t\t\timageList[ objectImageNumber[i] ]:SetStaticImageIndex( objectImageIndex[i] )\n"
	str = str .. "\t\t\t\tobject = uppuRacingHighBlockObject(self.world, pos, 0, imageList[ objectImageNumber[i] ]:Clone() )\n"
	str = str .. "\t\t\tend\n\n"

	str = str .. "\t\tend\n\n"

	str = str .. "\t\tif objectIndex < 0 then\n"
	str = str .. "\t\t\tself.startPoint[ math.abs(objectIndex) ] = i\n"
	str = str .. "\t\tend\n"

	str = str .. "\tend\n\n"

	str = str .. "\tself.passRects[1] = Rect(0, 480, 240, 540)\n"
	str = str .. "\tself.passRects[2] = Rect(540, 600, 600, 1140)\n"
	str = str .. "\tself.passRects[3] = Rect(960, 480, 1200, 540)\n"
	str = str .. "\tself.passRects[4] = Rect(540, 0, 600, 300)\n\n"

	str = str .. "\tself:SendNPOList()\n"
	str = str .. "end\n\n"

-- SendNPOList
	str = str .. "function " .. mapName .. ":SendNPOList()\n"
	str = str .. "\tlocal msg = Message(Object_NPO_List)\n"
	str = str .. "\tlocal npolist = List()\n"
	str = str .. "\tfor oid, object in pairs(self.objects) do\n"
	str = str .. "\t\tif object.classtype == CLASS_NPO then\n"
	str = str .. "\t\t\tnpolist:Add(oid)\n"
	str = str .. "\t\tend\n"
	str = str .. "\tend\n\n"

	str = str .. "\tlocal npostring = npolist:GetString()\n"
	str = str .. "\tmsg:SetValue(Object_NPO_List.key.list, npostring)\n"
	str = str .. "\tgameapp:SendToServer(msg)\n"

	str = str .. "end\n"

	print(str)

end

function MapEditorServerApp:OnSelect( player, msg )
	self.currentMapImage = msg:GetValue( Evt_Select.key.mapImage )
	self.currentMapImageIndex = msg:GetValue( Evt_Select.key.mapImageIndex )
	self.currentType = msg:GetValue( Evt_Select.key.mapType )

	self:SendToAll( msg, player )
end

function MapEditorServerApp:OnSelectMapUnit( player, msg )
	local row = msg:GetValue( Evt_SelectMapUnit.key.row )
	local col = msg:GetValue( Evt_SelectMapUnit.key.col )

	if string.find(self.currentType, "T") ~= nil then
		self.mapUnitTileImageNumberList[row][col] = self.currentMapImage
		self.mapUnitTileImageIndexList[row][col] = self.currentMapImageIndex
		self.mapUnitTileImageTypeList[row][col] = self.currentType
	else
		self.mapUnitObjectImageNumberList[row][col] = self.currentMapImage
		self.mapUnitObjectImageIndexList[row][col] = self.currentMapImageIndex
		self.mapUnitObjectImageTypeList[row][col] = self.currentType
	end

end

function MapEditorServerApp:OnCancelMapUnit( player, msg )
	local row = msg:GetValue( Evt_CancelMapUnit.key.row )
	local col = msg:GetValue( Evt_CancelMapUnit.key.col )

	self.mapUnitObjectImageNumberList[row][col] = -1
	self.mapUnitObjectImageIndexList[row][col] = 999
	self.mapUnitObjectImageTypeList[row][col] = "N"
end
			
function MapEditorServerApp:Copy2DimTable( from )
	local to = { }
	for i = 1, #from do
		to[i] = { }
		for j = 1, #from[i] do
			to[i][j] = from[i][j]
		end
	end

	return to
end