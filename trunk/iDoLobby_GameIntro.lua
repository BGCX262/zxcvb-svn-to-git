require "go.app.Client"
require "go.service.idogame.LobbyList"
require "iDoLobby_LobbyClient"	
require "iDoLobby_GameIntroScene"
require "iDoLobby_PopupScene"
require "iDoLobby_Settings"
require "uppuRacingSoundObject"	-- should be required before the definition of inherited class from Client

class 'iDoLobby_GameIntro' (Client)

local forwarding = App.GetProperty("forwarding")

function iDoLobby_GameIntro:__init()	super()
	-- to use all the sound objects defined in XML directly as a member of this client 
	self:SetupSoundObjects()

	---------------------------------------------------------------------------
	-- 클라이언트 크기 설정
	---------------------------------------------------------------------------
	self:SetWindowSize(760, 586)
	self:SetScreenPivot(760/2, 586/2)

	---------------------------------------------------------------------------
	-- IntroScene
	---------------------------------------------------------------------------
	self.introScene = iDoLobby_GameIntroScene()

	---------------------------------------------------------------------------
	-- Attach popup scene to IntroScene
	---------------------------------------------------------------------------
	self.popup = iDoLobby_PopupScene()
	self.popup.dlgMessageBox:SetClient(self)
	self.introScene.grpPopup:AddChild(self.popup.dlgMessageBox)
	self.popup.dlgMessageBox.OkClick:AddHandler(self, self.OnRetryEnterLobby)
end

function iDoLobby_GameIntro:OnEnter()
	self:ActivateScene(self.introScene)

	---------------------------------------------------------------------------
	-- Show intro splash
	---------------------------------------------------------------------------
	if iDoLobby_Settings.durationIntroSplash > 0 then
		WaitSec(iDoLobby_Settings.durationIntroSplash)
	end
 
	---------------------------------------------------------------------------
	-- 로비 입장
	---------------------------------------------------------------------------
	local result

	-- forwarding 정보에 의해 지정된 로비로의 입장 시도
	local lobbyNo = (forwarding and type(forwarding) == "table" and forwarding.lobbyNo)
	if lobbyNo and lobbyNo > 0 then
		result = self:TryEnterLobby(lobbyNo, true)
		forwarding = nil	-- forwarding은 최초 한번만 실행
	end

	-- 지정된 로비로의 입장에 실패했을 경우 조용히 임의의 로비로 자동 입장시도
	if not result then
		result = self:TryEnterLobby()
	end
end

function iDoLobby_GameIntro:OnReturn(exitArg)
	if exitArg and type(exitArg) == "number" then	-- changing lobby
		self:ActivateScene(self.introScene)
		self:TryEnterLobby(exitArg)
	else
		App.Destroy()
	end
end

function iDoLobby_GameIntro:TryEnterLobby(lobbyNo, silent)
	if self.tryingEnterLobby then return end
	self.tryingEnterLobby = true

	local msgText = iDoLobby_Settings.noticeEnterLobby
	self.popup.dlgMessageBox:SetMessage(msgText[1], msgText[2])
	self.popup.dlgMessageBox:SetXYPos(220, 230)
	self.popup.dlgMessageBox.btnMessageBoxExit:Show(false)
	self.popup.dlgMessageBox:Show(true, true)

	local result, client
	if lobbyNo then
		assert(type(lobbyNo) == "number")
		result, client = LobbyList.EnterLobby(iDoLobby_LobbyClient, self, lobbyNo, iDoLobby_Settings.timeoutEnterLobby)
	else -- randomly 
		result, client = LobbyList.EnterLobbyRandom(iDoLobby_LobbyClient, self, iDoLobby_Settings.timeoutEnterLobby)
	end

	if result then
		lobbyapp = client
	else
		if not silent then
			local msgText
			if client == ServiceError.TIMEOUT then
				msgText = iDoLobby_Settings.errorServerNoResponse
			elseif client == ServiceError.NETWORK_FAILURE then
				msgText = iDoLobby_Settings.errorNetworkUnreachable
			elseif client == ServiceError.EXCEED_CAPACITY then
				msgText = iDoLobby_Settings.errorExceedCapacity
			elseif client == ServiceError.SERVER_SHUTDOWN then
				msgText = iDoLobby_Settings.errorServerRefusal
			elseif client == ServiceError.DUPLICATE_LOGIN then
				msgText = iDoLobby_Settings.errorDuplicateLogin
				self.popup.dlgMessageBox.OkClick:RemoveHandler(self, self.OnRetryEnterLobby)
				self.popup.dlgMessageBox.OkClick:AddHandler(self, self.OnConfirmExit)
			else
				msgText = iDoLobby_Settings.errorUnknownFailure
			end

			self.popup.dlgMessageBox:SetMessage(msgText[1], msgText[2])
			self.popup.dlgMessageBox:SetXYPos(220, 230)
			self.popup.dlgMessageBox.btnMessageBoxExit:Show(true)
			self.popup.dlgMessageBox:Show(true, true)		
		end
	end

	self.tryingEnterLobby = false
	return result
end

function iDoLobby_GameIntro:OnRetryEnterLobby(sender, msg)
	self:TryEnterLobby()
end

function iDoLobby_GameIntro:OnConfirmExit(sender, msg)
	App.Destroy()
end
