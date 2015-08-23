require "go.ui.control.Group"
require "iDoLobby_PopupMultiEventHandler"

class 'MessageBoxDialog' (Group)

-- Constructor
function MessageBoxDialog:__init(popupScene, id) super(id)
	self:SetClient()
	self:CloneControls(popupScene)

	-- Variables
	self.dragInfo = {btnDown = false, diffX = 0, diffY = 0}

	self:SetMessage()

	-- Event Handlers
	self.OkClick = iDoLobby_PopupMultiEventHandler(self.btnMessageBoxExit, Evt_MouseLClick)

	-- Add internal event handlers
	self.messageBoxBg.MouseDown:AddHandler(self, self.OnBgMouseDown)
	self.messageBoxBg.MouseMove:AddHandler(self, self.OnBgMouseMove)
	self.messageBoxBg.MouseUp:AddHandler(self, self.OnBgMouseUp)
	self.OkClick:AddHandler(self, self.OnExit)
end

function MessageBoxDialog:SetClient(client)
	self.client = client or lobbyapp
end

-- Internal handlers
function MessageBoxDialog:OnBgMouseDown(sender, msg)
	self.dragInfo.btnDown = true
	self.dragInfo.diffX = msg:GetValue(Evt_MouseDown.key.X)
	self.dragInfo.diffY = msg:GetValue(Evt_MouseDown.key.Y)
	self:BringToTop()
end

function MessageBoxDialog:OnBgMouseMove(sender, msg)
	if self.dragInfo.btnDown == false then return end

	local x = self:GetAbsXPos() + msg:GetValue(Evt_MouseMove.key.X)
	local y = self:GetAbsYPos() + msg:GetValue(Evt_MouseMove.key.Y)
	self:SetAbsXYPos(x - self.dragInfo.diffX, y - self.dragInfo.diffY)
	self.imgModal:SetAbsXYPos(0, 0)
end

function MessageBoxDialog:OnBgMouseUp(sender, msg)
	self.dragInfo.btnDown = false

	local x, y = self:GetAbsXYPos()
	local windowSize = self.client:GetWindowSize()

	if x < 0 then
		self:SetAbsXPos(0)
	elseif x + self.messageBoxBg:GetWidth() > windowSize.x then
		self:SetAbsXPos(windowSize.x - self.messageBoxBg:GetWidth())
		self.imgModal:SetAbsXPos(0)
	end

	if y < 0 then
		self:SetAbsYPos(0)
	elseif y + self.messageBoxBg:GetHeight() > windowSize.y then
		self:SetAbsYPos(windowSize.y - self.messageBoxBg:GetHeight())
		self.imgModal:SetAbsYPos(0)
	end
end

function MessageBoxDialog:SetMessage(arg1, arg2, arg3, arg4)
	local msg = {"", "", "", ""}
	local numRow = 0
	
	if type(arg1) == "string" then 
		msg[1] = arg1 
		numRow = 1
	end
	
	if type(arg2) == "string" then 
		msg[2] = arg2 
		numRow = 2
	end
	
	if type(arg3) == "string" then 
		msg[3] = arg3 
		numRow = 3
	end

	if type(arg4) == "string" then 
		msg[4] = arg4 
		numRow = 4
	end

	if type(arg1) == "table" then
		for i, text in ipairs(arg1) do
			if type(text) == "string" then
				msg[i] = text 
				numRow = i
			end
		end
	end

	self.txtMessage1:SetText(msg[1])
	self.txtMessage2:SetText(msg[2])
	self.txtMessage3:SetText(msg[3])
	self.txtMessage4:SetText(msg[4])

	if numRow == 1 then
		self.txtMessage1:SetYPos(31)
	else
		self.txtMessage1:SetYPos(22)
	end

	if numRow <= 2 then
		self.messageBoxBg:Show(true)
		self.messageBoxBg4:Show(false)
		self.btnMessageBoxExit:SetYPos(87)
	else
		self.messageBoxBg:Show(false)
		self.messageBoxBg4:Show(true)
		self.btnMessageBoxExit:SetYPos(129)
	end
end

-- Override
function MessageBoxDialog:Show(show, modal)
	if show and modal then
		local windowSize = self.client:GetWindowSize()
		self.imgModal:SetWidth(windowSize.x)
		self.imgModal:SetHeight(windowSize.y)
		self.imgModal:SetAbsXYPos(0, 0)
	end

	Graphic.Show(self, show)
	self:BringToTop()
end

function MessageBoxDialog:OnExit(sender, msg)
	self:Show(false)
end

function MessageBoxDialog:CloneControls(scene)
	self.imgModal			= scene.imgModal:Clone()
	self.messageBoxBg		= scene.messageBoxBg:Clone()
	self.messageBoxBg4		= scene.messageBoxBg4:Clone()
	self.btnMessageBoxExit	= scene.btnMessageBoxExit:Clone()
	self.txtMessage1		= scene.txtMessage1:Clone()
	self.txtMessage2		= scene.txtMessage2:Clone()
	self.txtMessage3		= scene.txtMessage3:Clone()
	self.txtMessage4		= scene.txtMessage4:Clone()

	self:AddChild(self.imgModal)
	self:AddChild(self.messageBoxBg)
	self:AddChild(self.messageBoxBg4)
	self:AddChild(self.btnMessageBoxExit)
	self:AddChild(self.txtMessage1)
	self:AddChild(self.txtMessage2)
	self:AddChild(self.txtMessage3)
	self:AddChild(self.txtMessage4)

	self:Show(false)
end
