
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
   self.crashAnim = self:GetHgsFromXML(26)
   self.textLaps = self:GetTextFromXML(28)
   self.textTime = self:GetTextFromXML(29)
   self.textBest = self:GetTextFromXML(30)
   self.textLapsData = self:GetTextFromXML(31)
   self.textTimeData = self:GetTextFromXML(32)
   self.textBestData = self:GetTextFromXML(33)
   self.imageItemBox1 = self:GetStaticImageFromXML(35)
   self.imageItemBox2 = self:GetStaticImageFromXML(37)
   self.imageItemBox3 = self:GetStaticImageFromXML(38)
   self.textItemZ = self:GetTextFromXML(39)
   self.textItemX = self:GetTextFromXML(40)
   self.textItemC = self:GetTextFromXML(41)
   self.imageBigNumber = self:GetImageNumberFromXML(42)
   self.imageItems = self:GetStaticImageFromXML(43)
   self.imageBombBox = self:GetImageFromXML(99)
   self.imageMissile = self:GetImageFromXML(100)
   self.hsvIcePenguin = self:GetHsvFromXML(101)
   self.imageBooster = self:GetImageFromXML(102)
   self.imageFinishLine = self:GetStaticImageFromXML(119)
   self.imageRetire = self:GetStaticImageFromXML(214)
   self.hsvGo = self:GetHsvFromXML(305)
   self.imageResultBar = self:GetStaticImageFromXML(306)
   self.textBestNickName = self:GetTextFromXML(307)
   self.textSpeed = self:GetTextFromXML(308)
   self.imageDrift = self:GetStaticImageFromXML(309)

end
