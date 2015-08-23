require "go.ui.Scene"
require "uppuRacingProtocol"
require "uppuRacingConsts"

class 'Scene_WaitingRoom' (Scene)

function Scene_WaitingRoom:__init(id)	super(id)
	self:SetupUIObjects()

	self:SetMsgHandler(Evt_KeyboardDown, self.OnKeyDown)
	self.btnExit.MouseLClick:AddHandler( self, self.OnExit )
	self.editChat.KeyboardDown:AddHandler( self, self.OnChat )

	for i = 1, 6 do
		local playerBg = self.playerSlotBg:Clone()
		playerBg:SetXYPos( PLAYER_SLOT_LOC[i][1], PLAYER_SLOT_LOC[i][2] )
	end

	self.offsetX = 0
	self.offsetY = 0
end

function Scene_WaitingRoom:OnKeyDown(msg)
	local keyValue = msg:GetValue(Evt_KeyboardDown.key.Value)
	if keyValue == UIConst.KeyEnter then
		self.editChat:SetFocus()
	end
end

function Scene_WaitingRoom:OnChat(sender, msg)
	local keyValue = msg:GetValue(Evt_KeyboardDown.key.Value)
	if keyValue == UIConst.KeyEnter and string.len(self.editChat:GetText()) > 0 then
		local chatText = "[" .. gameapp.listUserState[__main.selfplayer.no].nickname .. "] " .. self.editChat:GetText()
		local chatMsg = Message( Noti_Chat )
		chatMsg:SetValue( Noti_Chat.key.no, __main.selfplayer.no )
		chatMsg:SetValue( Noti_Chat.key.chatText, chatText )
		gameapp:SendToServer( chatMsg )
		self.editChat:ClearEdit()
	end
end

function Scene_WaitingRoom:Update(elapsed)
	if self:GetKeyPressed( UIConst.KeyUp ) == true or self:GetKeyPressed( UIConst.KeyDown ) == true or
		self:GetKeyPressed( UIConst.KeyLeft ) == true or self:GetKeyPressed( UIConst.KeyRight ) == true then

		local car = gameapp.listUserState[__main.selfplayer.no].carCloneImage

		if self:GetKeyPressed( UIConst.KeyUp ) then
			if self.offsetY > -10 then
				self.offsetY = self.offsetY - 1
				car:SetYPos( car:GetYPos() - 1 )
			end
			if car:GetRotate() > 0 and car:GetRotate() <= 180 then
				car:SetRotate( car:GetRotate() - 5 )
			elseif car:GetRotate() > 180 then
				car:SetRotate( car:GetRotate() + 5 )
			end

		elseif self:GetKeyPressed( UIConst.KeyDown ) then
			if self.offsetY < 10 then
				self.offsetY = self.offsetY + 1
				car:SetYPos( car:GetYPos() + 1 )
			end
			if car:GetRotate() >= 0 and car:GetRotate() < 180 then
				car:SetRotate( car:GetRotate() + 5 )
			elseif car:GetRotate() > 180 then
				car:SetRotate( car:GetRotate() - 5 )
			end
	
		elseif self:GetKeyPressed( UIConst.KeyLeft ) then
			if self.offsetX > -10 then
				self.offsetX = self.offsetX - 1
				car:SetXPos( car:GetXPos() - 1 )
			end
			if car:GetRotate() >= 90 and car:GetRotate() < 270 then
				car:SetRotate( car:GetRotate() + 5 )
			elseif car:GetRotate() < 90 or car:GetRotate() > 270 then
				car:SetRotate( car:GetRotate() - 5 )
			end

		elseif self:GetKeyPressed( UIConst.KeyRight ) then
			if self.offsetX < 10 then
				self.offsetX = self.offsetX + 1
				car:SetXPos( car:GetXPos() + 1 )
			end
			if car:GetRotate() > 90 and car:GetRotate() <= 270 then
				car:SetRotate( car:GetRotate() - 5 )
			elseif car:GetRotate() < 90 or car:GetRotate() > 270 then
				car:SetRotate( car:GetRotate() + 5 )
			end

		end

	end
end

function Scene_WaitingRoom:OnExit( sender, msg )
	gameapp:Exit()
end

require "Scene_WaitingRoomUIObject"