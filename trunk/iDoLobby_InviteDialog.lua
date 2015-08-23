require "go.ui.control.Group"
require "iDoLobby_PopupMultiEventHandler"

class 'InviteDialog' (Group)

-- Constructor
function InviteDialog:__init(popupScene, id) super(id)
	self:CloneControls(popupScene)

	-- Variables
	self.dragInfo = {btnDown = false, diffX = 0, diffY = 0}

	-- Export MultiEventHandler to be handled by external class implementation
	self.OkClick     = iDoLobby_PopupMultiEventHandler(self.btnInviteOK,     Evt_MouseLClick)
	self.CancelClick = iDoLobby_PopupMultiEventHandler(self.btnInviteCancel, Evt_MouseLClick)
	self.CloseClick  = iDoLobby_PopupMultiEventHandler(self.btnInviteClose,  Evt_MouseLClick)

	-- Add internal event handlers
	self.OkClick:AddHandler(self, self.OnOK)
	self.CancelClick:AddHandler(self, self.OnCancel)
	self.CloseClick:AddHandler(self, self.OnCancel)
	self.inviteBg.MouseDown:AddHandler(self, self.OnBgMouseDown)
	self.inviteBg.MouseMove:AddHandler(self, self.OnBgMouseMove)
	self.inviteBg.MouseUp:AddHandler(self, self.OnBgMouseUp)
	self.btnInviteFind.MouseLClick:AddHandler(self, self.OnFind)
	self.scrCandidates.ScrollBarChanged:AddHandler(self, function () self:OnScroll(self.scrCandidates, self.candidates) end)
	self.scrChosens.ScrollBarChanged:AddHandler(self, function () self:OnScroll(self.scrChosens, self.chosens) end)
end

-- [public]
-- open dialog to show list of players to invite
-- @param clear boolean. clear the list of chosen players first if true 
function InviteDialog:Open(clear)
	if clear then self:ClearChosenList() end

	-- TODO: message box for waiting

	-- request query for candidates
	local query = PlayerListQuery(lobbyapp)
	query:AddListener(self, self.OnPlayerList)
	query.sort.joinTime =  ListQuery.ORDER_DESC
	query.filter.isInRoom = false
	query:Request()
end

-- [public]
-- return the array having userkeys of chosen players
-- CAUTION: it is different from internal information, "self.chosen"
function InviteDialog:GetChosenList()
	local userkeys = {}
	for _, ch in ipairs(self.chosens) do
		table.insert(userkeys, ch.userkey)
	end
	return userkeys
end

function InviteDialog:ClearChosenList()
	self.chosens = {}
	self.backup  = {}
end

function InviteDialog:BackupChosenList()
	self.backup  = {}
	self.chosens = self.chosens or {}
	for _, p in ipairs(self.chosens) do
		table.insert(self.backup, p)
	end
end

function InviteDialog:RevertChosenList()
	self.backup  = self.backup or {}
	self.chosens = {}
	for _, p in ipairs(self.backup) do
		table.insert(self.chosens, p)
	end
end

-- Internal handlers
function InviteDialog:OnBgMouseDown(sender, msg)
	self.dragInfo.btnDown = true
	self.dragInfo.diffX = msg:GetValue(Evt_MouseDown.key.X)
	self.dragInfo.diffY = msg:GetValue(Evt_MouseDown.key.Y)
	self:BringToTop()
end

function InviteDialog:OnBgMouseMove(sender, msg)
	if self.dragInfo.btnDown == false then return end

	local x = self:GetAbsXPos() + msg:GetValue(Evt_MouseMove.key.X)
	local y = self:GetAbsYPos() + msg:GetValue(Evt_MouseMove.key.Y)
	self:SetAbsXYPos(x - self.dragInfo.diffX, y - self.dragInfo.diffY)
end

function InviteDialog:OnBgMouseUp(sender, msg)
	self.dragInfo.btnDown = false

	local x, y = self:GetAbsXYPos()
	local windowSize = lobbyapp:GetWindowSize()

	if x < 0 then
		self:SetAbsXPos(0)
	elseif x + self.inviteBg:GetWidth() > windowSize.x then
		self:SetAbsXPos(windowSize.x - self.inviteBg:GetWidth())
	end

	if y < 0 then
		self:SetAbsYPos(0)
	elseif y + self.inviteBg:GetHeight() > windowSize.y then
		self:SetAbsYPos(windowSize.y - self.inviteBg:GetHeight())
	end
end

function InviteDialog:OnScroll(scr, list)
	local diff = scr:GetScrollValue()
	for i, p in pairs(list) do
		p.txtNick:SetYPos(p.y - diff)
		p.txtLevel:SetYPos(p.y - diff)
		p.txtRecord:SetYPos(p.y - diff)
		p.btnSelect:SetYPos(p.y - diff)
	end
end

function InviteDialog:OnOK(sender, msg)
	self:BackupChosenList()
	self:Show(false) 
end

function InviteDialog:OnCancel(sender, msg)
	self:RevertChosenList()
	self:Show(false) 
end

function InviteDialog:OnFind(sender, msg)
	local pattern = self.edtPlayerSearch:GetText()
	
	local magiclist = {"(", ")", ".", "+", "?", "[", "]", "^", "$"}
	for _, mchar in ipairs(magiclist) do
		pattern = string.gsub(pattern, "%" .. mchar, "%%%" .. mchar)
	end
	
	self.candidates = {}
	for i, p in ipairs(self.allplayers) do
		local found = false
		if string.match(p.nickname, pattern) then
			found = true

			-- check found player is already chosen in previous trial
			for _, ch in ipairs(self.chosens) do
				if ch.userkey == p.userkey then
					found = false
					break
				end
			end
		end

		-- insert found player to candidates list
		if found then
			local cd = {}
			cd.index   = i
			cd.userkey = p.userkey
			table.insert(self.candidates, cd)
		end
	end

	self:UpdateList()
end

-- Override
function InviteDialog:Show(show)
	Graphic.Show(self, show)
	self:BringToTop()
end

function InviteDialog:CloneControls(scene)
	self.inviteBg = scene.inviteBg:Clone()
	self.btnInviteClose = scene.btnInviteClose:Clone()
	self.btnInviteCancel = scene.btnInviteCancel:Clone()
	self.btnInviteOK = scene.btnInviteOK:Clone()
	self.btnInviteFind = scene.btnInviteFind:Clone()
	self.edtPlayerSearch = scene.edtPlayerSearch:Clone()
	self.grpCandidates = scene.grpCandidates:Clone()
	self.scrCandidates = scene.scrCandidates:Clone()
	self.grpChosens = scene.grpChosens:Clone()
	self.scrChosens = scene.scrChosens:Clone()
	self.imgChosens = scene.imgChosens:Clone()
	self.imgCandidates = scene.imgCandidates:Clone()
	self.grpCandidatesScr = scene.grpCandidatesScr:Clone()
	self.grpChosensScr = scene.grpChosensScr:Clone()

	self:AddChild(self.inviteBg)
	self:AddChild(self.btnInviteClose)
	self:AddChild(self.btnInviteCancel)
	self:AddChild(self.btnInviteOK)
	self:AddChild(self.btnInviteFind)
	self:AddChild(self.edtPlayerSearch)
	self:AddChild(self.grpCandidates)
	self:AddChild(self.scrCandidates)
	self:AddChild(self.grpChosens)
	self:AddChild(self.scrChosens)

	self:AddChild(self.grpCandidatesScr)
	self.grpCandidatesScr:AddChild(self.scrCandidates)
	self.grpCandidatesScr:AddChild(self.imgCandidates)
	self:AddChild(self.grpChosensScr)
	self.grpChosensScr:AddChild(self.scrChosens)
	self.grpChosensScr:AddChild(self.imgChosens)

	self:Show(false)
end
  
function InviteDialog:ClearListUI(grp, scr)
	for i=1, grp:GetChildCount() do
		grp:GetChildAt(i):RemoveObject()
	end
	grp:RemoveAllChildren()
	scr:SetScrollValue(0)
	scr:Enable(false)
end

function InviteDialog:OnPlayerList(query)
	-- construct candidates pool
	self.allplayers = {}
	self.candidates = {}
	self.chosens    = self.chosens or {}
	for _, c in ipairs(self.chosens) do c.index = nil end	-- reset index field in chosens

	for pi in query:Items() do
		if pi.userkey ~= PlayerInfo.GetSelf().userkey then
			local pgd = pi:GetGameData()	-- PlayerGameData for each candidates

			local p = {}
			p.userkey   = pi.userkey
			p.nickname  = pi.nickname
			p.level		= pgd.sLevel
			p.win		= pgd.winCount
			p.lose		= pgd.defeatCount

			table.insert(self.allplayers, p)

			-- check this player is already chosen in previous trial
			local found = false
			for i, ch in ipairs(self.chosens) do
				if ch.userkey == p.userkey then
					ch.index = #self.allplayers
					found = true
				end
			end
			-- if not found in chosens list, insert to candidates list
			if not found then
				local cd = {}
				cd.index   = #self.allplayers
				cd.userkey = p.userkey
				table.insert(self.candidates, cd)
			end
		end
	end


	-- check whether each previously chosen player is still avaialble to be invited or not
	for i = #self.chosens, 1, -1 do		-- backward iteration to use table.remove()
		local ch = self.chosens[i]
		if not ch.index then
			table.remove(self.chosens, i)
		end	
	end

	self:UpdateList()
	
	-- show self
	self:SetXYPos(220, 130)
	self:Show(true)

end

function InviteDialog:UpdateList()
	-- show candidates and chosens list
	self:DrawList(self.candidates, self.grpCandidates, self.scrCandidates, self.chosens)
	self:DrawList(self.chosens, self.grpChosens, self.scrChosens, self.candidates)
end

local function createTextToGroup(grp, str, x, y)
	local text = Text()
	text:SetFont(iDoLobby_Settings.fontNormalText)
	text:SetTextColor(iDoLobby_Settings.colorNormalText)
	text:SetText(str)
	text:SetXYPos(x, y)
	grp:AddChild(text)
	return text
end

local function createButtonToGroup(grp, img, x, y)
	local btn = Button()
	btn:LoadButtonImage(img)
	btn:SetXYPos(x, y)
	grp:AddChild(btn)
	return btn
end

function InviteDialog:DrawList(list, grp, scr, dest)
	self:ClearListUI(grp, scr)

	for i = 1, #list do
		local p = self.allplayers[list[i].index]
		local y = i * 22 - 15
		local strRecord = p.win.."승 "..p.lose.."패"

		list[i].y = y	-- store y coordinate to enable scrolling
		list[i].txtNick   = createTextToGroup(grp, p.nickname,  20, y)
		list[i].txtLevel  = createTextToGroup(grp, p.level,    153, y)
		list[i].txtRecord = createTextToGroup(grp, strRecord,  191, y)
		list[i].btnSelect = createButtonToGroup(grp, "images\\iDoLobby\\creatroom_btn_select.png", 252, y)
		list[i].btnSelect.MouseLClick:AddHandler(self, 
			function (sender, msg) 
				self:MovePlayer(list, dest, i) 
			end
		)
	end

	grp:EnableClip(true)
	grp:SetClipRect (Rect(0, 0, 287, 75))
	grp:Show(true)

	if #list >= 4 then
		scr:Enable(true)
		scr:SetMinValue(0)
		scr:SetMaxValue((#list - 3) * 22)
	else
		scr:Enable(false)
	end
end

function InviteDialog:MovePlayer(from, to, index)
	table.insert(to, table.remove(from, index))
	self:UpdateList()
end
