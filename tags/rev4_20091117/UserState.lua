require "go.util.GameObject"

CAR_IMAGE = {
		{
		"images\\ido_up_ch001_009.bmp",
		"images\\ido_up_ch001_010.bmp",
		"images\\ido_up_ch001_011.bmp",
		"images\\ido_up_ch001_012.bmp",
		"images\\ido_up_ch001_013.bmp",
		"images\\ido_up_ch001_014.bmp",
		"images\\ido_up_ch001_009.bmp",
		"images\\ido_up_ch001_010.bmp" },

		{
		"images\\ido_up_ch002_015.bmp",
		"images\\ido_up_ch002_016.bmp",
		"images\\ido_up_ch002_017.bmp",
		"images\\ido_up_ch002_018.bmp",
		"images\\ido_up_ch002_019.bmp",
		"images\\ido_up_ch002_020.bmp",
		"images\\ido_up_ch002_015.bmp",
		"images\\ido_up_ch002_016.bmp" },

		{
		"images\\ido_up_ch004_009.bmp",
		"images\\ido_up_ch004_010.bmp",
		"images\\ido_up_ch004_011.bmp",
		"images\\ido_up_ch004_012.bmp",
		"images\\ido_up_ch004_013.bmp",
		"images\\ido_up_ch004_020.bmp",
		"images\\ido_up_ch004_009.bmp",
		"images\\ido_up_ch004_010.bmp"  },

		{
		"images\\ido_up_ch009_003.bmp",
		"images\\ido_up_ch009_005.bmp",
		"images\\ido_up_ch009_007.bmp",
		"images\\ido_up_ch009_009.bmp",
		"images\\ido_up_ch009_011.bmp",
		"images\\ido_up_ch009_013.bmp",
		"images\\ido_up_ch009_003.bmp",
		"images\\ido_up_ch009_005.bmp" },

		{
		"images\\ido_up_ch010_002.bmp",
		"images\\ido_up_ch010_004.bmp",
		"images\\ido_up_ch010_006.bmp",
		"images\\ido_up_ch010_008.bmp",
		"images\\ido_up_ch010_010.bmp",
		"images\\ido_up_ch010_012.bmp",
		"images\\ido_up_ch010_002.bmp",
		"images\\ido_up_ch010_004.bmp" }

}

PLAYER_SLOT_LOC = {
	{93, 163}, {273, 163}, {453, 163}, {633, 163}, {93, 343}, {273, 343}, {453, 343}, {633, 343}
}

MAX_CAR_TYPE = 5

class 'UserState' (GameObject)

function UserState:__init( app, userNo, isPlayer ) super()
	if __main.isServer == true then
		self.server = app
	else
		self.client = app
		self.playerSlot = nil
	end

	self.userNo = userNo
	self.isPlayer = isPlayer
	self.nickname = nil
	self.isReady = false
	self.carType = 1
-- States
	-- UserState.Join
	self.Join = {	[Enter] = self.EnterUserJoin,	[Execute] = self.OnUserJoin,	[Exit] = self.ExitUserJoin	}

	-- UserState.Wait
	self.Wait = {	[Enter] = self.EnterUserWait,	[Execute] = self.OnUserWait,	[Exit] = self.ExitUserWait	}

	-- UserState.Play
	self.Play = {	[Enter] = self.EnterUserPlay,	[Execute] = self.OnUserPlay,	[Exit] = self.ExitUserPlay	}

	-- UserState.View
	self.View = {	[Enter]	= self.EnterUserView,	[Execute] = self.OnUserView,	[Exit] = self.ExitUserView	}

	-- UserState.Leave
	self.Leave = {	[Enter] = self.EnterUserLeave,	[Execute] = self.OnUserLeave,	[Exit] = self.ExitUserLeave	}

end

-- UserState.Join Functions
function UserState:EnterUserJoin()

	-- Server Part
	if self.server ~= nil then

	-- Client Part
	elseif self.client ~= nil then
	end

end

function UserState:OnUserJoin()
end

function UserState:ExitUserJoin()
end

-- UserState.Wait Functions
function UserState:EnterUserWait()

	-- Server Part
	if self.server ~= nil then

	-- Client Part
	elseif self.client ~= nil then
		if self.playerSlot == nil then
			self.playerSlot = Group()

			local playerImage = StaticImage()
			playerImage:LoadStaticImage( CAR_IMAGE[self.carType][self.userNo], 4, 5, nil, UIConst.Blue )
			playerImage:SetXYPos( PLAYER_SLOT_LOC[self.userNo][1]+35-(playerImage:GetWidth()/2), PLAYER_SLOT_LOC[self.userNo][2]+35-(playerImage:GetHeight()/2) )
			self.playerSlot:AddChild( playerImage )

			local playerNickname = Text(nil, self.nickname)
			playerNickname:SetXYPos( PLAYER_SLOT_LOC[self.userNo][1], PLAYER_SLOT_LOC[self.userNo][2]-10 )
			self.playerSlot:AddChild( playerNickname )

			if self.userNo == __main.selfplayer.no then
				local playerReadyBtn = self.client.waitScene.btnReady:Clone()
				playerReadyBtn:SetXYPos(  PLAYER_SLOT_LOC[self.userNo][1]-10, PLAYER_SLOT_LOC[self.userNo][2]+75 )
				playerReadyBtn.MouseLClick:AddHandler( self, self.readyBtn_Clicked )
				playerReadyBtn:Show(true)
				playerReadyBtn:Enable(true)
				self.playerSlot:AddChild( playerReadyBtn )
	
				local playerPrevBtn = self.client.waitScene.btnPrev:Clone()
				playerPrevBtn:SetXYPos( PLAYER_SLOT_LOC[self.userNo][1]-50, PLAYER_SLOT_LOC[self.userNo][2]+24 )
				playerPrevBtn.MouseLClick:AddHandler( self, self.prevBtn_Clicked )
				playerPrevBtn:Show(true)
				playerPrevBtn:Enable(true)
				self.playerSlot:AddChild( playerPrevBtn )

				local playerNextBtn = self.client.waitScene.btnNext:Clone()
				playerNextBtn:SetXYPos( PLAYER_SLOT_LOC[self.userNo][1]+66, PLAYER_SLOT_LOC[self.userNo][2]+24 )
				playerNextBtn.MouseLClick:AddHandler( self, self.nextBtn_Clicked )
				playerNextBtn:Show(true)
				playerNextBtn:Enable(true)
				self.playerSlot:AddChild( playerNextBtn )
			end

			self.client.waitScene:AddChild( self.playerSlot )
		end
	end

end

function UserState:OnUserWait()
end

function UserState:ExitUserWait()
	-- Server Part
	if self.server ~= nil then

	-- Client Part
	elseif self.client ~= nil then
	end
end

-- UserState.Play Functions
function UserState:EnterUserPlay()

	-- Server Part
	if self.server ~= nil then

	-- Client Part
	elseif self.client ~= nil then
--		self.playerSlot:RemoveAllChildren()
--		self.client.waitScene:RemoveChild( self.playerSlot )
	end

end

function UserState:OnUserPlay()
end

function UserState:LeaveUserPlay()
end

-- UserState.View Functions
function UserState:EnterUserView()

	-- Server Part
	if self.server ~= nil then

	-- Client Part
	elseif self.client ~= nil then
	end
end

function UserState:OnUserView()
end

function UserState:ExitUserView()
end

-- UserState.Leave Functions
function UserState:EnterUserLeave()

	-- Server Part
	if self.server ~= nil then

	-- Client Part
	elseif self.client ~= nil then
		if self.client.waitScene == Scene.latestScene then
			self.playerSlot:RemoveAllChildren()
			self.client.waitScene:RemoveChild( self.playerSlot )
		end
	end

end

function UserState:OnUserLeave()
end

function UserState:ExitUserLeave()
end

function UserState:readyBtn_Clicked( sender, msg )
	local readyMsg = Message( Noti_PlayerReady )
	readyMsg:SetValue( Noti_PlayerReady.key.no, self.userNo )
	self.client:SendToServer( readyMsg )
	sender:Enable(false)

	self.playerSlot:GetChildAt(4):Show(false)
	self.playerSlot:GetChildAt(4):Enable(false)
	self.playerSlot:GetChildAt(5):Show(false)
	self.playerSlot:GetChildAt(5):Enable(false)
end

function UserState:prevBtn_Clicked( sender, msg )
	if self.carType > 1 then
		self.carType = self.carType - 1
		local changeMsg = Message( Noti_ChangeCarType )
		changeMsg:SetValue( Noti_ChangeCarType.key.no, self.userNo )
		changeMsg:SetValue( Noti_ChangeCarType.key.carType, self.carType )
		self.client:SendToServer( changeMsg )
	end
end

function UserState:nextBtn_Clicked( sender, msg )
	if self.carType < MAX_CAR_TYPE then
		self.carType = self.carType + 1
		local changeMsg = Message( Noti_ChangeCarType )
		changeMsg:SetValue( Noti_ChangeCarType.key.no, self.userNo )
		changeMsg:SetValue( Noti_ChangeCarType.key.carType, self.carType )
		self.client:SendToServer( changeMsg )
	end
end

function UserState:OnUserReady( msg )
	self.playerSlot:GetChildAt(1):AnimateStaticImage( 4, 0, 0.5, -1 )
end

function UserState:OnUserUnready()
	self.playerSlot:GetChildAt(1):StopAnimation()
	if self.playerSlot:GetChildAt(3) then
		self.playerSlot:GetChildAt(3):Enable(true)
		self.playerSlot:GetChildAt(4):Show(true)
		self.playerSlot:GetChildAt(4):Enable(true)
		self.playerSlot:GetChildAt(5):Show(true)
		self.playerSlot:GetChildAt(5):Enable(true)
	end
end

function UserState:OnChangeCarType( msg )
	self.carType = msg:GetValue( Noti_ChangeCarType.key.carType )
	self.playerSlot:GetChildAt(1):LoadStaticImage( CAR_IMAGE[self.carType][self.userNo], 4, 5, nil, UIConst.Blue )
	self.playerSlot:GetChildAt(1):SetXYPos(
		PLAYER_SLOT_LOC[self.userNo][1]+35-(self.playerSlot:GetChildAt(1):GetWidth()/2),
		PLAYER_SLOT_LOC[self.userNo][2]+35-(self.playerSlot:GetChildAt(1):GetHeight()/2) )
	if self.isReady == true then
		self.playerSlot:GetChildAt(1):AnimateStaticImage( 4, 0, 0.5, -1 )
	end
end