require "go.app.ClientApp"

require "MapEditorScene"
require "MapEditorProtocol"

class 'MapEditorClientApp' (ClientApp)

function MapEditorClientApp:__init() super()
	math.randomseed(os.time())

	self:LoadXML("Scene.xml", true)

	self.scene = MapEditorScene(1)
	self:ActivateScene(self.scene)
	
	self:SetupSoundObjects()

	-- record current time
	self.lastsec = self:GetCurrentSeconds()

	self:SetMsgHandler( Evt_InitMap, self.OnInitMap )
	self:SetMsgHandler( Evt_CreateMap, self.OnCreateMap )
	self:SetMsgHandler( Evt_SaveMap, self.OnSaveMap )
	self:SetMsgHandler( Evt_LoadMap, self.OnLoadMap )

	self:SetMsgHandler( Evt_Select, self.OnSelect )
	self:SetMsgHandler( Evt_SelectMapUnit, self.OnSelectMapUnit )
end

---------------------------------------------------------
-- Game Handler
---------------------------------------------------------
function MapEditorClientApp:OnEnterGame(player)
	self.scene:Initialize(player.no)
end

function MapEditorClientApp:OnLeaveGame(player)

end

function MapEditorClientApp:OnDisconnected()

end

function MapEditorClientApp:OnEnterPlayer(player)

end

function MapEditorClientApp:OnLeavePlayer(player)

end

function MapEditorClientApp:OnTimer(timerid)

end

function MapEditorClientApp:Update(seconds)
	self.currentScene:Update(seconds - self.lastsec)
	self.lastsec = seconds
end

---------------------------------------------------------
-- Network Handler
---------------------------------------------------------
function MapEditorClientApp:OnSelect( server, msg )
	self.scene:OnSelect( server, msg )
end

function MapEditorClientApp:OnSelectMapUnit( server, msg )
	self.scene:OnSelectMapUnit( msg )
end

function MapEditorClientApp:OnInitMap( server, msg )
	self.scene.currentMapNumber = msg:GetValue( Evt_InitMap.key.numberOfMaps ) + 1
	if msg:GetValue( Evt_InitMap.key.numberOfMaps ) > 0 then
		self.scene.editLoad:ClearEdit()
		self.scene.editLoad:InsertText( tostring( msg:GetValue( Evt_InitMap.key.numberOfMaps ) ) )
	else
		self.scene.btnLoad:Enable(false)
	end
	self.scene.editSave:ClearEdit()
	self.scene.editSave:InsertText( tostring( self.scene.currentMapNumber ) )
end

function MapEditorClientApp:OnCreateMap( server, msg )
	self.scene.editSave:ClearEdit()
	self.scene.editSave:InsertText( tostring( msg:GetValue( Evt_CreateMap.key.numberOfMaps ) ) )
end

function MapEditorClientApp:OnSaveMap( server, msg )
	self.scene.editLoad:ClearEdit()
	self.scene.editLoad:InsertText( tostring( msg:GetValue( Evt_SaveMap.key.numberOfMaps ) ) )
	self.scene.btnLoad:Enable(true)
end

function MapEditorClientApp:OnLoadMap( server, msg )
	self.scene:OnLoadMap( msg )
end

require "MapEditorSoundObject"