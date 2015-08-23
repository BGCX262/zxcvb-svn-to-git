require "go.util.GameObject"

PLAYER_SLOT_LOC = {
	{438, 264}, {554, 264}, {670, 264}, {438, 368}, {554, 368}, {670, 368}
}

BIG_CAR_LOC = {
	{169, 216}, {147, 209}, {173, 216}, {156, 200}, {156, 222}
}

SMALL_CHAR_LOC = {
	{27, 92}, {104, 92}, {181, 92}, {258, 92}, {335, 92}
}

CLONE_CAR_LOC = {
	40, 275
}

READY_LOC = {
	432, 530
}

CAR_IMAGE = {
		{
		"images\\ido_up_ch001_009.bmp",
		"images\\ido_up_ch001_010.bmp",
		"images\\ido_up_ch001_011.bmp",
		"images\\ido_up_ch001_012.bmp",
		"images\\ido_up_ch001_013.bmp",
		"images\\ido_up_ch001_014.bmp" },	-- 한(디폴트)

		{
		"images\\ido_up_ch002_020.bmp",
		"images\\ido_up_ch002_017.bmp",
		"images\\ido_up_ch002_018.bmp",
		"images\\ido_up_ch002_019.bmp",
		"images\\ido_up_ch002_016.bmp",
		"images\\ido_up_ch002_015.bmp" },	-- 풍장군

		{
		"images\\ido_up_ch004_007.bmp",
		"images\\ido_up_ch004_009.bmp",
		"images\\ido_up_ch004_010.bmp",
		"images\\ido_up_ch004_011.bmp",
		"images\\ido_up_ch004_012.bmp",
		"images\\ido_up_ch004_013.bmp" },	-- 뺘기

		{
		"images\\ido_up_ch009_003.bmp",
		"images\\ido_up_ch009_005.bmp",
		"images\\ido_up_ch009_007.bmp",
		"images\\ido_up_ch009_009.bmp",
		"images\\ido_up_ch009_011.bmp",
		"images\\ido_up_ch009_013.bmp" },	-- 토토(외계인)

		{
		"images\\ido_up_ch010_001.bmp",
		"images\\ido_up_ch010_002.bmp",
		"images\\ido_up_ch010_004.bmp",
		"images\\ido_up_ch010_006.bmp",
		"images\\ido_up_ch010_008.bmp",
		"images\\ido_up_ch010_012.bmp" }	-- 후치(거미)
}

-- car define
CAR_TYPE_HAAN = 1
CAR_TYPE_POONG = 2
CAR_TYPE_PYAGI = 3
CAR_TYPE_TOTO = 4
CAR_TYPE_HOOCHI = 5

MAX_CAR_TYPE = 5

class 'UserState' (GameObject)

function UserState:__init( app, userNo, isPlayer ) super()
	if __main.isServer == true then
		self.server = app
	else
		self.client = app
		self.carImage = nil
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
			self.carImage = self.client.waitScene.groupCar:GetChildAt(self.carType):GetChildAt(self.userNo):Clone()
			self.carImage:SetXYPos( PLAYER_SLOT_LOC[self.userNo][1]+42-(self.carImage:GetWidth()/2), PLAYER_SLOT_LOC[self.userNo][2]+40-(self.carImage:GetHeight()/2) )
			self.client.waitScene:AddChild(self.carImage)

			self.playerSlot = Group()

			local playerReadyBg = self.client.waitScene.imageReady:Clone()
			playerReadyBg:SetXYPos( PLAYER_SLOT_LOC[self.userNo][1], PLAYER_SLOT_LOC[self.userNo][2] )
			playerReadyBg:Show(false)
			self.playerSlot:AddChild( playerReadyBg )

			local playerNickname = self.client.waitScene.textPlayer:Clone()
			playerNickname:SetText(self.nickname)
			playerNickname:SetXYPos( PLAYER_SLOT_LOC[self.userNo][1]+5, PLAYER_SLOT_LOC[self.userNo][2]+78 )
			self.playerSlot:AddChild( playerNickname )
			if __main.selfplayer.no == self.userNo then
				playerNickname:SetTextColor( 0xffff0000 )
			end

			self.client.waitScene:AddChild( self.playerSlot )

			if __main.selfplayer.no == self.userNo then
				self.bigCarImage = self.client.waitScene.groupBigCar:GetChildAt(self.carType):Clone()
				self.bigCarImage:SetXYPos(BIG_CAR_LOC[self.carType][1], BIG_CAR_LOC[self.carType][2])
				self.bigCarImage:SetStaticImageIndex( __main.selfplayer.no-1 )
				self.client.waitScene:AddChild(self.bigCarImage)

				self.carCloneImage = self.carImage:Clone()
				self.carCloneImage:SetXPos( CLONE_CAR_LOC[1] + 40 - self.carCloneImage:GetWidth()/2 )
				self.carCloneImage:SetYPos( CLONE_CAR_LOC[2] + 40 - self.carCloneImage:GetHeight()/2 )
				self.carCloneImage:AnimateStaticImage( 0, 4, 1, -1 )
				self.carCloneImage:SetXPivot(self.carCloneImage:GetWidth()/2)
				self.carCloneImage:SetYPivot(self.carCloneImage:GetHeight()/2)

				self.smallCharImage = { }

				for i = 1, #CAR_IMAGE do
					self.smallCharImage[i] = self.client.waitScene.groupSmallChar:GetChildAt(i):Clone()
					self.smallCharImage[i]:SetXYPos(SMALL_CHAR_LOC[i][1], SMALL_CHAR_LOC[i][2])
					self.smallCharImage[i]:SetImageIndex( __main.selfplayer.no )
					self.client.waitScene:AddChild(self.smallCharImage[i])
					self.smallCharImage[i].MouseLClick:AddHandler( self, self.changeCarTypeBtn_Clicked )
				end

				local readyBtn = self.client.waitScene.btnReady
				readyBtn:SetXYPos( READY_LOC[1], READY_LOC[2] )
				readyBtn.MouseLClick:AddHandler( self, self.readyBtn_Clicked )
			end

			self.playerSlot:BringToTop()
			self.client.waitScene.imageHost:BringToTop()

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
	self.isReady = false
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
--		if self.client.waitScene == Scene.latestScene then
			self.playerSlot:RemoveAllChildren()
			self.client.waitScene:RemoveChild( self.playerSlot )
			self.client.waitScene:RemoveChild( self.carImage )
--		end
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
end

function UserState:changeCarTypeBtn_Clicked( sender, msg )
	for i = 1, #SMALL_CHAR_LOC do
		if sender.UIObjectID == self.smallCharImage[i].UIObjectID then
			self.carType = i
			local changeMsg = Message( Noti_ChangeCarType )
			changeMsg:SetValue( Noti_ChangeCarType.key.no, self.userNo )
			changeMsg:SetValue( Noti_ChangeCarType.key.carType, self.carType )
			self.client:SendToServer( changeMsg )
			return
		end
	end
end

function UserState:OnUserReady( msg )
	if self.isReady == true then
		self.isReady = false
		self:OnUserUnready()
	else
		if __main.selfplayer.no == self.userNo then
			for i = 1, #CAR_IMAGE do
				self.smallCharImage[i]:Enable(false)
			end
		end
		self.isReady = true
		self.carImage:AnimateStaticImage( 4, 0, 0.5, -1 )
		self.playerSlot:GetChildAt(1):Show(true)
		self.playerSlot:GetChildAt(1):BringToTop()
	end
end

function UserState:OnUserUnready()
	self.carImage:StopAnimation()
	self.playerSlot:GetChildAt(1):Show(false)
	if __main.selfplayer.no == self.userNo then
		for i = 1, #CAR_IMAGE do
			self.smallCharImage[i]:Enable(true)
		end
	end

	if __main.selfplayer.no == self.client.gameState.hostNo then
		self.client.waitScene.btnReady:Enable(false)
		self.client.waitScene.btnPrevMap:Enable(true)
		self.client.waitScene.btnNextMap:Enable(true)
	end
end

function UserState:OnChangeCarType( msg )
	self.carType = msg:GetValue( Noti_ChangeCarType.key.carType )
	
	self.client.waitScene:RemoveChild( self.carImage )
	self.carImage = self.client.waitScene.groupCar:GetChildAt(self.carType):GetChildAt(self.userNo):Clone()
	self.carImage:SetXYPos(
		PLAYER_SLOT_LOC[self.userNo][1]+42-(self.carImage:GetWidth()/2),
		PLAYER_SLOT_LOC[self.userNo][2]+40-(self.carImage:GetHeight()/2) )
	self.client.waitScene:AddChild( self.carImage )
	self.playerSlot:BringToTop()
	self.client.waitScene.imageHost:BringToTop()

	if __main.selfplayer.no == self.userNo then
		self.client.waitScene:RemoveChild( self.bigCarImage )
		self.bigCarImage = self.client.waitScene.groupBigCar:GetChildAt(self.carType):Clone()
		self.bigCarImage:SetXYPos( BIG_CAR_LOC[self.carType][1], BIG_CAR_LOC[self.carType][2] )
		self.client.waitScene:AddChild( self.bigCarImage )
		self.bigCarImage:SetStaticImageIndex( __main.selfplayer.no-1 )

		self.client.waitScene:RemoveChild( self.carCloneImage )
		self.carCloneImage = self.carImage:Clone()
		self.carCloneImage:SetXPos( CLONE_CAR_LOC[1] + 40 - self.carCloneImage:GetWidth()/2 )
		self.carCloneImage:SetYPos( CLONE_CAR_LOC[2] + 40 - self.carCloneImage:GetHeight()/2 )
		self.carCloneImage:AnimateStaticImage( 0, 4, 1, -1 )
		self.carCloneImage:SetXPivot(self.carCloneImage:GetWidth()/2)
		self.carCloneImage:SetYPivot(self.carCloneImage:GetHeight()/2)
		self.client.waitScene.offsetX = 0
		self.client.waitScene.offsetY = 0
	end
end