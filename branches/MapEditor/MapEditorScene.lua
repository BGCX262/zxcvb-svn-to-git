require "go.ui.Scene"
require "MapEditorProtocol"

require "MapEditorConsts"

class 'MapEditorScene' (Scene)

function MapEditorScene:__init(id)	super(id)
	self:SetupUIObjects()

	self:SetMsgHandler(Evt_KeyboardDown, self.OnKeyDown)
	self.currentMapNumber = 0
	self.mapImageList = { }
	self.mapSelectBtnList = { }
	self.mapUnitTileImageList = { }
	self.mapUnitObjectImageList = { }
	self.currentMapImage = 1
	self.currentMapImageIndex = 0
	self.currentType = "T"

end

function MapEditorScene:OnKeyDown(msg)
	local keyValue = msg:GetValue(Evt_KeyboardDown.key.Value)
	--print(keyValue)
	if keyValue == UIConst.KeyUp and self.imageSelected:GetYPos() >= MAIN_MAP_IMAGE_LOC[2] and
		self:PickGraphic( self.imageSelected:GetXPos()+10-gameapp:GetScreenPivot().x+512, self.imageSelected:GetYPos()-MAP_UNIT_SIZE[2]-gameapp:GetScreenPivot().y+384 ) ~= nil then
		self.imageSelected:SetYPos( self.imageSelected:GetYPos()-MAP_UNIT_SIZE[2] )

		if gameapp:GetScreenPivot().y - self.imageSelected:GetYPos() >= 414-MAIN_MAP_IMAGE_LOC[2] then
			gameapp:SetScreenPivot( gameapp:GetScreenPivot().x, gameapp:GetScreenPivot().y-30 )
		end

	elseif keyValue == UIConst.KeyDown then
		if self:PickGraphic( self.imageSelected:GetXPos()+10-gameapp:GetScreenPivot().x+512,
					self.imageSelected:GetYPos()+MAP_UNIT_SIZE[2]+10-gameapp:GetScreenPivot().y+384 ) ~= nil then
			self.imageSelected:SetYPos( self.imageSelected:GetYPos()+MAP_UNIT_SIZE[2] )

			if gameapp:GetScreenPivot().y >= 384 and self.imageSelected:GetYPos() >= 738 then
				gameapp:SetScreenPivot( gameapp:GetScreenPivot().x, gameapp:GetScreenPivot().y+30 )
			end
		end

	elseif keyValue == UIConst.KeyLeft and self.imageSelected:GetXPos() >= MAIN_MAP_IMAGE_LOC[1] and
		self:PickGraphic( self.imageSelected:GetXPos()-MAP_UNIT_SIZE[1]+10-gameapp:GetScreenPivot().x+512, self.imageSelected:GetYPos()+10-gameapp:GetScreenPivot().y+384 ) ~= nil then
		self.imageSelected:SetXPos( self.imageSelected:GetXPos()-MAP_UNIT_SIZE[1] )

		if gameapp:GetScreenPivot().x - self.imageSelected:GetXPos() >= 542-MAIN_MAP_IMAGE_LOC[1] then
			gameapp:SetScreenPivot( gameapp:GetScreenPivot().x-30, gameapp:GetScreenPivot().y )
		end

	elseif keyValue == UIConst.KeyRight then
		if self:PickGraphic( self.imageSelected:GetXPos()+MAP_UNIT_SIZE[1]+10-gameapp:GetScreenPivot().x+512,
					self.imageSelected:GetYPos()+10-gameapp:GetScreenPivot().y+384 ) ~= nil then
			self.imageSelected:SetXPos( self.imageSelected:GetXPos()+MAP_UNIT_SIZE[1] )

			if gameapp:GetScreenPivot().x >= 512 and self.imageSelected:GetXPos() >= 994 then
				gameapp:SetScreenPivot( gameapp:GetScreenPivot().x+30, gameapp:GetScreenPivot().y )
			end
		end

	elseif keyValue == UIConst.KeySpace and __main.selfplayer.no == 1 then

		for i = 1, #self.mapImageList do
			self.imageSelected:BringToBottom()
			if self:PickGraphic( self.imageSelected:GetXPos()+10, self.imageSelected:GetYPos()+10 ).UIObjectID == self.mapImageList[i].UIObjectID then
				local x = self.imageSelected:GetXPos()+10 - MENU_MAP_IMAGE_LOC[1]
				local y = self.imageSelected:GetYPos()+10 - MENU_MAP_IMAGE_LOC[2]

				for j = 0, MAP_IMAGE_FILE_ROW[i]-1 do
					for k = 0, MAP_IMAGE_FILE_COL[i]-1 do
						if x >= MAP_UNIT_SIZE[1] * k and x < MAP_UNIT_SIZE[1] * (k+1) and
							y >= MAP_UNIT_SIZE[2] * j and y <= MAP_UNIT_SIZE[2] * (j+1) then
	
							self.currentMapImageIndex = j*MAP_IMAGE_FILE_COL[i]+k
							self.textCurrentIndex:SetText( tostring( self.currentMapImageIndex ) )
							self.currentType = MAP_IMAGE_TYPE[i][j+1][k+1]
							self.textCurrentType:SetText( self.currentType )	
	
							self:SendCurrentSelection()
							self.imageSelected:BringToTop()
								
							return
						end
					end
				end
			end
		end

	elseif keyValue == UIConst.KeySpace and __main.selfplayer.no == 2 then

		for i = 1, #self.mapUnitTileImageList do
			for j = 1, #self.mapUnitTileImageList[i] do
				if self.mapUnitTileImageList[i][j]:GetXPos() == self.imageSelected:GetXPos() and
					self.mapUnitTileImageList[i][j]:GetYPos() == self.imageSelected:GetYPos() then

					if string.find( self.currentType, "T" ) ~= nil then
						self:RemoveChild( self.mapUnitTileImageList[i][j] )
						self.mapUnitTileImageList[i][j] = self.mapImageList[self.currentMapImage]:Clone()
						self.mapUnitTileImageList[i][j]:SetImageIndex( self.currentMapImageIndex )
						self.mapUnitTileImageList[i][j]:SetXPos( self.imageSelected:GetXPos() )
						self.mapUnitTileImageList[i][j]:SetYPos( self.imageSelected:GetYPos() )
						self.mapUnitTileImageList[i][j]:Show(true)
						self.mapUnitTileImageList[i][j]:Enable(true)
						self.mapUnitTileImageList[i][j].mapImageFileNumber = self.currentMapImage
						self.mapUnitTileImageList[i][j].MouseLClick:AddHandler( self, self.SelectMapUnitLoc )
						self.mapUnitTileImageList[i][j].MouseRClick:AddHandler( self, self.CancelMapUnit )
						if self.mapUnitObjectImageList[i][j] ~= nil and self.mapUnitObjectImageList[i][j] ~= -1 then
							self.mapUnitObjectImageList[i][j]:BringToTop()
						end

					else
						if self.mapUnitObjectImageList[i][j] ~= nil and self.mapUnitObjectImageList[i][j] ~= -1 then
							self:RemoveChild( self.mapUnitObjectImageList[i][j] )
						end
						self.mapUnitObjectImageList[i][j] = self.mapImageList[self.currentMapImage]:Clone()
						self.mapUnitObjectImageList[i][j]:SetImageIndex( self.currentMapImageIndex )
						self.mapUnitObjectImageList[i][j]:SetXPos( self.imageSelected:GetXPos() )
						self.mapUnitObjectImageList[i][j]:SetYPos( self.imageSelected:GetYPos() )
						self.mapUnitObjectImageList[i][j]:Show(true)
						self.mapUnitObjectImageList[i][j]:Enable(false)
						self.mapUnitObjectImageList[i][j].mapImageFileNumber = self.currentMapImage
						self.mapUnitObjectImageList[i][j]:BringToTop()
						self.imageSelected:BringToTop()
					end

					self.imageSelected:BringToTop()

					local selectMsg = Message( Evt_SelectMapUnit )
					selectMsg:SetValue( Evt_SelectMapUnit.key.row, i )
					selectMsg:SetValue( Evt_SelectMapUnit.key.col, j )
					gameapp:SendToServer( selectMsg )

					return
				end
			end
		end


	end
end

function MapEditorScene:Update(elapsed)
end

function MapEditorScene:Initialize(playerNo)
	for i = 1, #MAP_IMAGE_FILE do
		self.mapImageList[i] = Image()
		self.mapImageList[i]:Show(false)
		self.mapImageList[i]:Enable(false)

		if __main.selfplayer.no == 1 then
			self.mapImageList[i]:LoadControlImage( MAP_IMAGE_FILE[i] )--, 1, 1, nil, UIConst.Blue )
			self.mapImageList[i]:SetXYPos( MENU_MAP_IMAGE_LOC[1], MENU_MAP_IMAGE_LOC[2] )
			self.mapImageList[i].MouseLClick:AddHandler( self, self.SelectMapUnit )
			self.mapSelectBtnList[i] = self.btnSelect:Clone()
			self.mapSelectBtnList[i]:SetXYPos( MENU_MAP_SELECT_LOC[1]+(50*i), MENU_MAP_SELECT_LOC[2] )
			self.mapSelectBtnList[i].MouseLClick:AddHandler( self, self.SelectMap )
		else
			self.mapImageList[i]:LoadControlImage( MAP_IMAGE_FILE[i], MAP_IMAGE_FILE_COL[i], MAP_IMAGE_FILE_ROW[i], nil, UIConst.Blue )
		end

		self.mapImageList[i]:SetXScale(0.5)
		self.mapImageList[i]:SetYScale(0.5)
		self:AddChild( self.mapImageList[i] )
	end

	self.textCurrentImage:SetText( MAP_IMAGE_FILE[1] )
	self.textCurrentIndex:SetText( tostring( self.currentMapImageIndex ) )
	self.textCurrentType:SetText( self.currentType )

	if __main.selfplayer.no == 1 then
		self.mapImageList[1]:Show(true)
		self.mapImageList[1]:Enable(true)
		self.mapImageList[1]:BringToTop()
		self.mapSelectBtnList[1]:Enable(false)
		self.imageSelected:SetXYPos( MENU_MAP_IMAGE_LOC[1], MENU_MAP_IMAGE_LOC[2] )
		self.imageSelected:BringToTop()
	else
		self.groupNew:SetXYPos( MAIN_MAP_NEW_LOC[1], MAIN_MAP_NEW_LOC[2] )
		self.editSizeX:InsertText( "20" )
		self.editSizeY:InsertText( "10" )
		self.btnNew.MouseLClick:AddHandler( self, self.CreateNewMap )

		self.groupLoad:SetXYPos( MAIN_MAP_LOAD_LOC[1], MAIN_MAP_LOAD_LOC[2] )
		self.btnLoad.MouseLClick:AddHandler( self, self.LoadMap )

		self.groupSave:SetXYPos( MAIN_MAP_SAVE_LOC[1], MAIN_MAP_SAVE_LOC[2] )
		self.btnSave.MouseLClick:AddHandler( self, self.SaveMap )
		self.btnSave:Enable( false )

		self.btnPrint:SetXYPos( MAIN_MAP_PRINT_LOC[1], MAIN_MAP_PRINT_LOC[2] )
		self.btnPrint.MouseLClick:AddHandler( self, self.PrintMap )
		self.btnPrint:Enable( false )

		self.groupState:SetXYPos( MAIN_MAP_STATE_LOC[1], MAIN_MAP_STATE_LOC[2] )
	end

end

function MapEditorScene:SelectMap( sender, msg )
	self.mapSelectBtnList[self.currentMapImage]:Enable(true)
	self.mapImageList[self.currentMapImage]:Show(false)
	self.mapImageList[self.currentMapImage]:Enable(false)

	for i = 1, #self.mapSelectBtnList do
		if sender.UIObjectID == self.mapSelectBtnList[i].UIObjectID then
			self.currentMapImage = i
			self.currentMapImageIndex = 999
			self.mapImageList[i]:Show(true)
			self.mapImageList[i]:Enable(true)
			self.mapImageList[i]:BringToTop()
			self.mapSelectBtnList[i]:Enable(false)
			self.textCurrentImage:SetText( MAP_IMAGE_FILE[i] )
			self.textCurrentIndex:SetText( tostring( self.currentMapImageIndex ) )
			break
		end
	end
end

function MapEditorScene:SelectMapUnit( sender, msg )
	for i = 1, #self.mapImageList do
		if sender.UIObjectID == self.mapImageList[i].UIObjectID then
			local x = msg:GetValue( Evt_MouseLClick.key.X )
			local y = msg:GetValue( Evt_MouseLClick.key.Y )

			for j = 0, MAP_IMAGE_FILE_ROW[i]-1 do
				for k = 0, MAP_IMAGE_FILE_COL[i]-1 do
					if x >= MAP_UNIT_SIZE[1] * k and x < MAP_UNIT_SIZE[1] * (k+1) and
						y >= MAP_UNIT_SIZE[2] * j and y <= MAP_UNIT_SIZE[2] * (j+1) then

						self.imageSelected:SetXPos( MAP_UNIT_SIZE[1]*k+MENU_MAP_IMAGE_LOC[1] )
						self.imageSelected:SetYPos( MAP_UNIT_SIZE[2]*j+MENU_MAP_IMAGE_LOC[2] )
						self.imageSelected:Show(true)
						self.imageSelected:BringToTop()
						self.currentMapImageIndex = j*MAP_IMAGE_FILE_COL[i]+k
						self.textCurrentIndex:SetText( tostring( self.currentMapImageIndex ) )
						self.currentType = MAP_IMAGE_TYPE[i][j+1][k+1]
						self.textCurrentType:SetText( self.currentType )

						self:SendCurrentSelection()

						return
					end
				end
			end
		end
	end
end

function MapEditorScene:CreateNewMap( sender, msg )
	local x = tonumber( self.editSizeX:GetText() )
	local y = tonumber( self.editSizeY:GetText() )

	for i = 1, y do
		self.mapUnitTileImageList[i] = { }
		self.mapUnitObjectImageList[i] = { }
		for j = 1, x do
			self.mapUnitTileImageList[i][j] = self.mapImageList[self.currentMapImage]:Clone()
			self.mapUnitTileImageList[i][j]:SetImageIndex( self.currentMapImageIndex )
			self.mapUnitTileImageList[i][j]:SetXPos( MAP_UNIT_SIZE[1]*(j-1)+MAIN_MAP_IMAGE_LOC[1] )
			self.mapUnitTileImageList[i][j]:SetYPos( MAP_UNIT_SIZE[2]*(i-1)+MAIN_MAP_IMAGE_LOC[2] )
			self.mapUnitTileImageList[i][j]:Show(true)
			self.mapUnitTileImageList[i][j]:Enable(true)
			self.mapUnitTileImageList[i][j].MouseLClick:AddHandler( self, self.SelectMapUnitLoc )
			self.mapUnitTileImageList[i][j].MouseRClick:AddHandler( self, self.CancelMapUnit )
			self.mapUnitTileImageList[i][j].MouseDown:AddHandler( self, self.SelectMapUnitLocFrom )
			self.mapUnitTileImageList[i][j].MouseUp:AddHandler( self, self.SelectMapUnitLocTo )
			self.mapUnitTileImageList[i][j].mapImageFileNumber = self.currentMapImage
		end
	end

	self.btnSave:Enable(true)
	self.btnPrint:Enable(true)

	local createMsg = Message( Evt_CreateMap )
	createMsg:SetValue( Evt_CreateMap.key.row, y )
	createMsg:SetValue( Evt_CreateMap.key.col, x )
	gameapp:SendToServer( createMsg )

	self.imageSelected:SetXYPos( MAIN_MAP_IMAGE_LOC[1], MAIN_MAP_IMAGE_LOC[2] )
	self.imageSelected:BringToTop()
end

function MapEditorScene:LoadMap( sender, msg )
	local loadMsg = Message( Evt_LoadMap )
	loadMsg:SetValue( Evt_LoadMap.key.mapNumber, tonumber( self.editLoad:GetText() ) )
	gameapp:SendToServer( loadMsg )
	self.editSave:ClearEdit()
	self.editSave:InsertText( self.editLoad:GetText() )

	for i = 1, #self.mapUnitTileImageList do
		for j = 1, #self.mapUnitTileImageList[i] do
			self:RemoveChild( self.mapUnitTileImageList[i][j] )

			if self.mapUnitObjectImageList[i][j] ~= nil and self.mapUnitObjectImageList[i][j] ~= -1 then
				self:RemoveChild( self.mapUnitObjectImageList[i][j] )
			end
		end
	end

	self.btnSave:Enable(true)
	self.btnPrint:Enable(true)

	self.imageSelected:SetXYPos( MAIN_MAP_IMAGE_LOC[1], MAIN_MAP_IMAGE_LOC[2] )
	self.imageSelected:BringToTop()
end

function MapEditorScene:OnLoadMap( msg )
	local row = msg:GetValue( Evt_LoadMap.key.row )
	local col = msg:GetValue( Evt_LoadMap.key.col )

	for i = 1, row do
		self.mapUnitTileImageList[i] = { }
		self.mapUnitObjectImageList[i] = { }
		for j = 1, col do
			self.mapUnitTileImageList[i][j] = -1
			self.mapUnitObjectImageList[i][j] = -1			
		end
	end

end

function MapEditorScene:SaveMap( sender, msg )
	local saveMsg = Message( Evt_SaveMap )
	saveMsg:SetValue( Evt_SaveMap.key.numberOfMaps, tonumber(self.editSave:GetText()) )
	gameapp:SendToServer( saveMsg )
end

function MapEditorScene:PrintMap( sender, msg )
	local printMsg = Message( Evt_PrintMap )
	printMsg:SetValue( Evt_PrintMap.key.mapNumber, self.currentMapNumber )
	gameapp:SendToServer( printMsg )
end

function MapEditorScene:SelectMapUnitLoc( sender, msg )

	for i = 1, #self.mapUnitTileImageList do
		for j = 1, #self.mapUnitTileImageList[i] do
			if self.mapUnitTileImageList[i][j].UIObjectID == sender.UIObjectID then
				
				self.imageSelected:SetXPos( self.mapUnitTileImageList[i][j]:GetXPos() )
				self.imageSelected:SetYPos( self.mapUnitTileImageList[i][j]:GetYPos() )

				if string.find( self.currentType, "T" ) ~= nil then
					self:RemoveChild( self.mapUnitTileImageList[i][j] )
					self.mapUnitTileImageList[i][j] = self.mapImageList[self.currentMapImage]:Clone()
					self.mapUnitTileImageList[i][j]:SetImageIndex( self.currentMapImageIndex )
					self.mapUnitTileImageList[i][j]:SetXPos( self.imageSelected:GetXPos() )
					self.mapUnitTileImageList[i][j]:SetYPos( self.imageSelected:GetYPos() )
					self.mapUnitTileImageList[i][j]:Show(true)
					self.mapUnitTileImageList[i][j]:Enable(true)
					self.mapUnitTileImageList[i][j].mapImageFileNumber = self.currentMapImage
					self.mapUnitTileImageList[i][j].MouseLClick:AddHandler( self, self.SelectMapUnitLoc )
					if self.mapUnitObjectImageList[i][j] ~= nil and self.mapUnitObjectImageList[i][j] ~= -1 then
						self.mapUnitObjectImageList[i][j]:BringToTop()
					end

				else
					if self.mapUnitObjectImageList[i][j] ~= nil and self.mapUnitObjectImageList[i][j] ~= -1 then
						self:RemoveChild( self.mapUnitObjectImageList[i][j] )
					end
					self.mapUnitObjectImageList[i][j] = self.mapImageList[self.currentMapImage]:Clone()
					self.mapUnitObjectImageList[i][j]:SetImageIndex( self.currentMapImageIndex )
					self.mapUnitObjectImageList[i][j]:SetXPos( self.imageSelected:GetXPos() )
					self.mapUnitObjectImageList[i][j]:SetYPos( self.imageSelected:GetYPos() )
					self.mapUnitObjectImageList[i][j]:Show(true)
					self.mapUnitObjectImageList[i][j]:Enable(false)
					self.mapUnitObjectImageList[i][j].mapImageFileNumber = self.currentMapImage
					self.mapUnitObjectImageList[i][j]:BringToTop()
					self.imageSelected:BringToTop()
				end

				self.imageSelected:BringToTop()

				local selectMsg = Message( Evt_SelectMapUnit )
				selectMsg:SetValue( Evt_SelectMapUnit.key.row, i )
				selectMsg:SetValue( Evt_SelectMapUnit.key.col, j )
				gameapp:SendToServer( selectMsg )

				return
			end
		end
	end

end

function MapEditorScene:CancelMapUnit( sender, msg )

	for i = 1, #self.mapUnitTileImageList do
		for j = 1, #self.mapUnitTileImageList[i] do
			if self.mapUnitTileImageList[i][j].UIObjectID == sender.UIObjectID and
				self.mapUnitObjectImageList[i][j] ~= nil and self.mapUnitObjectImageList[i][j] ~= -1 then
				self:RemoveChild( self.mapUnitObjectImageList[i][j] )
				self.mapUnitObjectImageList[i][j] = -1
	
				local cancelMsg = Message( Evt_CancelMapUnit )
				cancelMsg:SetValue( Evt_CancelMapUnit.key.row, i )
				cancelMsg:SetValue( Evt_CancelMapUnit.key.col, j )
				gameapp:SendToServer( cancelMsg )

				return
			end
		end
	end

end

function MapEditorScene:SelectMapUnitLocFrom( sender, msg )
end

function MapEditorScene:SelectMapUnitLocTo( sender, msg )
end

function MapEditorScene:SendCurrentSelection()
	local msg = Message( Evt_Select )
	msg:SetValue( Evt_Select.key.mapImage, self.currentMapImage )
	msg:SetValue( Evt_Select.key.mapImageIndex, self.currentMapImageIndex )
	msg:SetValue( Evt_Select.key.mapType, self.currentType )
	gameapp:SendToServer( msg )
end

function MapEditorScene:OnSelect( server, msg )
	self.currentMapImage = msg:GetValue( Evt_Select.key.mapImage )
	self.currentMapImageIndex = msg:GetValue( Evt_Select.key.mapImageIndex )
	self.currentType = msg:GetValue( Evt_Select.key.mapType )

	self.textCurrentImage:SetText( MAP_IMAGE_FILE[ self.currentMapImage ] )
	self.textCurrentIndex:SetText( tostring( self.currentMapImageIndex ) )
	self.textCurrentType:SetText( self.currentType )

end

function MapEditorScene:OnSelectMapUnit( msg )
	local i = msg:GetValue( Evt_SelectMapUnit.key.row )
	local j = msg:GetValue( Evt_SelectMapUnit.key.col )

	if string.find( self.currentType, "T" ) ~= nil then
		self.mapUnitTileImageList[i][j] = self.mapImageList[self.currentMapImage]:Clone()
		self.mapUnitTileImageList[i][j]:SetImageIndex( self.currentMapImageIndex )
		self.mapUnitTileImageList[i][j]:SetXPos( MAP_UNIT_SIZE[1]*(j-1)+MAIN_MAP_IMAGE_LOC[1] )
		self.mapUnitTileImageList[i][j]:SetYPos( MAP_UNIT_SIZE[2]*(i-1)+MAIN_MAP_IMAGE_LOC[2] )
		self.mapUnitTileImageList[i][j]:Show(true)
		self.mapUnitTileImageList[i][j]:Enable(true)
		self.mapUnitTileImageList[i][j].mapImageFileNumber = self.currentMapImage
		self.mapUnitTileImageList[i][j].MouseLClick:AddHandler( self, self.SelectMapUnitLoc )
		self.mapUnitTileImageList[i][j].MouseRClick:AddHandler( self, self.CancelMapUnit )
		self.mapUnitTileImageList[i][j]:BringToTop()
		if self.mapUnitObjectImageList[i][j] ~= nil and self.mapUnitObjectImageList[i][j] ~= -1 then
			self.mapUnitObjectImageList[i][j]:BringToTop()
		end
	else
		self.mapUnitObjectImageList[i][j] = self.mapImageList[self.currentMapImage]:Clone()
		self.mapUnitObjectImageList[i][j]:SetImageIndex( self.currentMapImageIndex )
		self.mapUnitObjectImageList[i][j]:SetXPos( MAP_UNIT_SIZE[1]*(j-1)+MAIN_MAP_IMAGE_LOC[1] )
		self.mapUnitObjectImageList[i][j]:SetYPos( MAP_UNIT_SIZE[2]*(i-1)+MAIN_MAP_IMAGE_LOC[2] )
		self.mapUnitObjectImageList[i][j]:Show(true)
		self.mapUnitObjectImageList[i][j]:Enable(false)
		self.mapUnitObjectImageList[i][j].mapImageFileNumber = self.currentMapImage
		self.mapUnitObjectImageList[i][j]:BringToTop()
	end

	self.imageSelected:BringToTop()

end

require "MapEditorSceneUIObject"