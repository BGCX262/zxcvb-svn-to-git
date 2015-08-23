
-- DO NOT MODIFY THIS FILE !!!

function Client:SetupSoundObjects()
   self.sndEnterPlayer = Client.GetSoundFromXML(10002)
   self.sndLeavePlayer = Client.GetSoundFromXML(10003)
   self.sndEnterRoom = Client.GetSoundFromXML(10004)
   self.sndWaitingRoom = Client.GetSoundFromXML(10005)
   self.sndPlaying = Client.GetSoundFromXML(10006)
   self.sndYouWin = Client.GetSoundFromXML(10007)
   self.sndFinished = Client.GetSoundFromXML(10008)
end
