
-- DO NOT MODIFY THIS FILE !!!

function iDoLobby_GameGuideScene01:SetupUIObjects()
   self.btnGameStart = self:GetButtonFromXML(59192)
   self.btnTutorial = self:GetButtonFromXML(59193)
   self.txtGameTitle = self:GetTextFromXML(59194)
   self.grpGuide1 = self:GetGroupFromXML(59195)
   self.staticimageImageTop = self:GetStaticImageFromXML(59196)
   self.staticimageImageBottom = self:GetStaticImageFromXML(59197)
   self.staticimageImageMiddle = self:GetStaticImageFromXML(59198)
   self.staticimageImageExample = self:GetStaticImageFromXML(59199)
   self.staticimageTextTop = self:GetStaticImageFromXML(59200)
   self.staticimageTextMiddle = self:GetStaticImageFromXML(59201)
   self.staticimageTextBottom = self:GetStaticImageFromXML(59202)
   self.staticimageGuide1 = self:GetStaticImageFromXML(59203)
   self.textGuideTitle = self:GetTextFromXML(59204)
   self.textGuideDesc1 = self:GetTextFromXML(59205)
   self.textGuideDesc2 = self:GetTextFromXML(59206)
   self.grpGuide2 = self:GetGroupFromXML(59207)
   self.staticimageImageTop2 = self:GetStaticImageFromXML(59208)
   self.staticimageImageBottom2 = self:GetStaticImageFromXML(59209)
   self.staticimageImageMiddle2 = self:GetStaticImageFromXML(59210)
   self.staticimageTextTop2 = self:GetStaticImageFromXML(59211)
   self.staticimageTextMiddle2 = self:GetStaticImageFromXML(59212)
   self.staticimageTextBottom2 = self:GetStaticImageFromXML(59213)
   self.staticimageGuide2 = self:GetStaticImageFromXML(59214)
   self.grpGuide3 = self:GetGroupFromXML(59215)
   self.staticimageImageTop3 = self:GetStaticImageFromXML(59216)
   self.staticimageImageBottom3 = self:GetStaticImageFromXML(59217)
   self.staticimageImageMiddle3 = self:GetStaticImageFromXML(59218)
   self.staticimageTextTop3 = self:GetStaticImageFromXML(59219)
   self.staticimageTextMiddle3 = self:GetStaticImageFromXML(59220)
   self.staticimageTextBottom3 = self:GetStaticImageFromXML(59221)
   self.staticimageGuide3 = self:GetStaticImageFromXML(59222)
   self.grpGuide4 = self:GetGroupFromXML(59223)
   self.staticimageImageTop4 = self:GetStaticImageFromXML(59224)
   self.staticimageImageBottom4 = self:GetStaticImageFromXML(59225)
   self.staticimageImageMiddle4 = self:GetStaticImageFromXML(59226)
   self.staticimageTextTop4 = self:GetStaticImageFromXML(59227)
   self.staticimageTextMiddle4 = self:GetStaticImageFromXML(59228)
   self.staticimageTextBottom4 = self:GetStaticImageFromXML(59229)
   self.staticimageGuide4 = self:GetStaticImageFromXML(59230)

   self.grpGuide1:AddChild(self.staticimageImageTop)
   self.grpGuide1:AddChild(self.staticimageImageBottom)
   self.grpGuide1:AddChild(self.staticimageImageMiddle)
   self.grpGuide1:AddChild(self.staticimageImageExample)
   self.grpGuide1:AddChild(self.staticimageTextTop)
   self.grpGuide1:AddChild(self.staticimageTextMiddle)
   self.grpGuide1:AddChild(self.staticimageTextBottom)
   self.grpGuide1:AddChild(self.staticimageGuide1)
   self.grpGuide1:AddChild(self.textGuideTitle)
   self.grpGuide1:AddChild(self.textGuideDesc1)
   self.grpGuide1:AddChild(self.textGuideDesc2)
   self.grpGuide2:AddChild(self.staticimageImageTop2)
   self.grpGuide2:AddChild(self.staticimageImageBottom2)
   self.grpGuide2:AddChild(self.staticimageImageMiddle2)
   self.grpGuide2:AddChild(self.staticimageTextTop2)
   self.grpGuide2:AddChild(self.staticimageTextMiddle2)
   self.grpGuide2:AddChild(self.staticimageTextBottom2)
   self.grpGuide2:AddChild(self.staticimageGuide2)
   self.grpGuide3:AddChild(self.staticimageImageTop3)
   self.grpGuide3:AddChild(self.staticimageImageBottom3)
   self.grpGuide3:AddChild(self.staticimageImageMiddle3)
   self.grpGuide3:AddChild(self.staticimageTextTop3)
   self.grpGuide3:AddChild(self.staticimageTextMiddle3)
   self.grpGuide3:AddChild(self.staticimageTextBottom3)
   self.grpGuide3:AddChild(self.staticimageGuide3)
   self.grpGuide4:AddChild(self.staticimageImageTop4)
   self.grpGuide4:AddChild(self.staticimageImageBottom4)
   self.grpGuide4:AddChild(self.staticimageImageMiddle4)
   self.grpGuide4:AddChild(self.staticimageTextTop4)
   self.grpGuide4:AddChild(self.staticimageTextMiddle4)
   self.grpGuide4:AddChild(self.staticimageTextBottom4)
   self.grpGuide4:AddChild(self.staticimageGuide4)
end
