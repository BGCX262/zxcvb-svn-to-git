
-- DO NOT MODIFY THIS FILE !!!

function uppuRacingScene:SetupUIObjects()
   self.carpos = self:GetTextFromXML(2)
   self.rtt1 = self:GetTextFromXML(3)
   self.rtt2 = self:GetTextFromXML(4)
   self.NowLoading = self:GetTextFromXML(20)
   self.trafficSent = self:GetTextFromXML(21)
   self.rtt3 = self:GetTextFromXML(22)
   self.rtt4 = self:GetTextFromXML(23)
   self.rankNumber = self:GetStaticImageFromXML(24)
   self.passlog = self:GetTextFromXML(25)

end
