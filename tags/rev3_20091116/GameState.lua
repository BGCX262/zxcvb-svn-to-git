require "go.util.GameObject"

class 'GameState' (GameObject)

function GameState:__init( app ) super()
-- States
	if __main.isServer == true then
		self.server = app
	else
		self.client = app
	end

	self.isReady = false

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
	end

end

function GameState:OnGameWait()
end

function GameState:ExitGameWait()
end

-- GameState.Play Functions
function GameState:EnterGamePlay()

	-- Server Part
	if self.server ~= nil then

	-- Client Part
	elseif self.client ~= nil then
	end

end

function GameState:OnGamePlay()
end

function GameState:ExitGamePlay()
end