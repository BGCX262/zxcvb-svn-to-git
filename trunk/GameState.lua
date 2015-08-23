require "go.util.GameObject"

MAP_INFO = {
	{1, "SnowMap", 0},
	{2, "WaterMap", 1},
	{0, "(Test) IceMap1", 2}
}

class 'GameState' (GameObject)

function GameState:__init( app ) super()
-- States
	if __main.isServer == true then
		self.server = app
	else
		self.client = app
		self.client.sndWaitingRoom:PlaySound(true)
		self.mapInfo = nil
	end

	self.isReady = false
	self.hostNo = 0
	self.mapNo = 1

	-- GameState.Wait
	self.Wait		= { [Enter] = self.EnterGameWait,	[Execute] = self.OnGameWait,	[Exit] = self.ExitGameWait	}

	-- GameState.Play
	self.Play		= { [Enter] = self.EnterGamePlay,	[Execute] = self.OnGamePlay,	[Exit] = self.ExitGamePlay	}
end

-- GameState.Wait Functions
function GameState:EnterGameWait()

	-- Server Part
	if self.server ~= nil then

	-- Client Part
	elseif self.client ~= nil then
		self.mapInfo = self.client.waitScene.groupMapInfo
		self.mapInfo:GetChildAt(1):SetImageIndex(MAP_INFO[self.mapNo][1])
		self.mapInfo:GetChildAt(2):SetText(MAP_INFO[self.mapNo][2])
		self.mapInfo:GetChildAt(3):SetStaticImageIndex(MAP_INFO[self.mapNo][3])
		self.client.waitScene.btnPrevMap.MouseLClick:AddHandler( self, self.PrevMap )
		self.client.waitScene.btnNextMap.MouseLClick:AddHandler( self, self.NextMap )
	end

end

function GameState:OnGameWait()
end

function GameState:ExitGameWait()
	-- Server Part
	if self.server ~= nil then

	-- Client Part
	elseif self.client ~= nil then
		self.mapInfo = self.client.waitScene.groupMapInfo
		if __main.selfplayer.no == self.hostNo then
			self.client.waitScene.btnPrevMap:Enable(true)
			self.client.waitScene.btnNextMap:Enable(true)
		end
	end
end

-- GameState.Play Functions
function GameState:EnterGamePlay()

	-- Server Part
	if self.server ~= nil then

	-- Client Part
	elseif self.client ~= nil then
		self.client.sndWaitingRoom:StopSound()
		self.client.sndPlaying:PlaySound(true)
	end

end

function GameState:OnGamePlay()
end

function GameState:ExitGamePlay()
	-- Server Part
	if self.server ~= nil then

	-- Client Part
	elseif self.client ~= nil then
		self.client.sndPlaying:StopSound()
		self.client.sndWaitingRoom:PlaySound(true)
	end
end

function GameState:PrevMap(sender, msg)
	if self.mapNo > 1 then
		local msg = Message( Noti_ChangeMap )
		msg:SetValue( Noti_ChangeMap.key.no, self.mapNo - 1	)
		self.client:SendToServer( msg )
	end
end

function GameState:NextMap(sender, msg)
	if self.mapNo < #MAP_INFO then
		local msg = Message( Noti_ChangeMap )
		msg:SetValue( Noti_ChangeMap.key.no, self.mapNo + 1 )
		self.client:SendToServer( msg )
	end
end

function GameState:OnChangeMap(msg)
	local no = msg:GetValue( Noti_ChangeMap.key.no )
	self.mapInfo:GetChildAt(1):SetImageIndex(MAP_INFO[no][1])
	self.mapInfo:GetChildAt(2):SetText(MAP_INFO[no][2])
	self.mapInfo:GetChildAt(3):SetStaticImageIndex(MAP_INFO[no][3])
	self.mapNo = no
end