require "iDoLobby_GameIntro"

math.randomseed(os.time())

Client.LoadXML("Scene.xml", true)
Client.Create(iDoLobby_GameIntro)
