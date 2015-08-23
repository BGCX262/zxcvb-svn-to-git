require "uppuRacingGameServer"

math.randomseed(os.time())

local result
result, gameapp = Server.Create(uppuRacingGameServer) 
