require "go.util.GameObject"

class 'RoomState' (GameObject)

function RoomState:__init( app ) super()

	if __main.isServer == true then
		self.server = app
	else
		self.client = app
	end

-- States
	-- RoomState.Open
	self.Open		= {	[Enter] = self.EnterRoomOpen,	[Execute] = self.OnRoomOpen,	[Exit] = self.ExitRoomOpen	}

	---- RoomState.PlayerOpen
	--self.PlayerOpen	= {	[Enter] = self.EnterPlayerOpen,	[Execute] = self.OnPlayerOpen,	[Exit] = self.ExitPlayerOpen}
 --
	---- RoomState.ObserverOpen
	--self.ObserverOpen	= {	[Enter] = self.EnterObserverOpen, [Execute] = self.OnObserverOpen, 	[Exit] = self.ExitObserverOpen}

	-- RoomState.Close
	self.Close		= {	[Enter] = self.EnterRoomClose, 	[Execute] = self.OnRoomClose,	[Exit] = self.ExitRoomClose	}

end

-- RoomState.Open Functions
function RoomState:EnterRoomOpen()

	-- Server Part
	if self.server ~= nil then
		self.server:SetRoomState( RoomOpen )

	-- Client Part
	elseif self.client ~= nil then
	end

end

function RoomState:OnRoomOpen()
end

function RoomState:ExitRoomOpen()
end

---- RoomState.PlayerOpen Functions
--function RoomState:EnterPlayerOpen()
--
--	-- Server Part
--	if self.server ~= nil then
--	
--	-- Client Part
--	elseif self.client ~= nil then
--	end
--
--	self:CloseObserver()
--	self:OpenPlayer()
--
--end
--
--function RoomState:OnPlayerOpen()
--end
--
--function RoomState:ExitPlayerOpen()
--end
--
---- RoomState.ObserverOpen Functions
--function RoomState:EnterObserverOpen()
--
--	-- Server Part
--	if self.server ~= nil then
--	
--	-- Client Part
--	elseif self.client ~= nil then
--	end
--
--	self:ClosePlayer()
--	self:OpenObserver()
--
--end
--
--function RoomState:OnObserverOpen()
--end
--
--function RoomState:ExitObserverOpen()
--end

-- RoomState.Close Functions
function RoomState:EnterRoomClose()

	-- Server Part
	if self.server ~= nil then
		self.server:SetRoomState( RoomClose )

	-- Client Part
	elseif self.client ~= nil then
	end

end

function RoomState:OnRoomClose()
end

function RoomState:ExitRoomClose()

	-- Server Part
	if self.server ~= nil then
		self.server:SetRoomState( RoomOpen )

	-- Client Part
	elseif self.client ~= nil then
	end

end


---- Sub-Functions
--function RoomState:OpenPlayer()
--end
--
--function RoomState:ClosePlayer()
--end
--
--function RoomState:OpenObserver()
--end
--
--function RoomState:CloseObserver()
--end