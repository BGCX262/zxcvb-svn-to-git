require "go.service.idogame.GameData"

class 'uppuRacingMapRecord' (Serializable)

function uppuRacingMapRecord:__init() super()
	-- best record
	self.mapname = nil		-- map name ex."testmap"
	self.nickname = nil		-- 최고기록 경신한 사용자의 nickname
	self.id = nil			-- 최고기록 경신한 사용자의 id
	self.besttime = nil		-- 최고기록
end

class 'uppuRacingGameData' (Serializable)

function uppuRacingGameData:__init() super()
	self.bestRecords = {}
	self.check = "first"
end

----------------------
-- load/save game data
----------------------
function SaveGameData(uppudata)
	local gamedata = GameData()
	gamedata.version = 1
	gamedata.userdata = uppudata	-- uppudata는 uppuRacingGameData 타입
	gamedata:Save()
end

function LoadGameData()
	local gamedata = GameData()
	if gamedata.version == 1 then
		gamedata.userdata = uppuRacingGameData()
	else
		assert(false, "not supported gamedata version")
		return nil
	end

	gamedata:Load()

	-- check가 first이면 이미 DB에 한번이라도 write가 된 상태
	-- first가 아니면, DB에 아무것도 없는 상태
	if gamedata.userdata.check == "first" then
		return gamedata.userdata
	else
		local uppudata = uppuRacingGameData()
		SaveGameData(uppudata)
		return uppudata
	end
end