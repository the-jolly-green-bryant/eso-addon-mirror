Harven_SubtitleAddon = ZO_Object:Subclass()

Harven_SubtitleAddon.name = "Harven's Subtitles"
Harven_SubtitleAddon.version = "1.4f"
Harven_SubtitleAddon.author = "Harven"

function Harven_SubtitleAddon:New(...)
	local subtitleAddon = ZO_Object.New(self)
	subtitleAddon:Initialize(...)
	return subtitleAddon
end

function Harven_SubtitleAddon:SetupOptions()
	local LAM = LibStub("LibAddonMenu-2.0")
	local LMP = LibStub("LibMediaProvider-1.0")
	
	-- local LibHarvensAddonSettings = LibStub("LibHarvensAddonSettings-1.0")
	
	-- local settings = LibHarvensAddonSettings:AddAddon("Harven's Subtitles")
	-- if not settings then return end
	
	local panelData = {
		type = "panel",
		name = Harven_SubtitleAddon.name,
		displayName = name,
	 	author = Harven_SubtitleAddon.author,
		version = Harven_SubtitleAddon.version
	}
	
	LAM:RegisterAddonPanel("HarvensSubtitles_OptionsPanel", panelData)
	
	local optionsData = {
		
		{	type = "slider", -- Tooltip Font Size
			name = "Tooltip Font Size",
			min = 400,
			max = 2000,
			step = 1,
			format = "%d",
			getFunc = function() return self.sv.width end,
			setFunc = function(value)
				self.control:SetWidth(value)
				self.subtitleLabel:SetWidth(value-80)
				self.sv.width = value
			end,
		},
		
		{	type = "slider", -- Subtitles Background Transparency
			name = "Subtitles Background Transparency",
			min = 0,
			max = 1,
			step = 0.1,
			format = "%.1f",
			getFunc = function() return self.sv.bgalpha end,
			setFunc = function(value)
				self.control:GetNamedChild("Bg"):SetAlpha(value)
				self.sv.bgalpha = value
			end,
		},
	
		{	type = "slider", -- Subtitles Scale
			name = "Subtitles Scale",
			min = 0.1,
			max = 4,
			step = 0.1,
			format = "%.1f",
			getFunc = function() return self.sv.scale end,
			setFunc = function(value)
				self.control:SetScale(value)
				self.sv.scale = value
			end,
		},
		
		{  -- button begin
			type = "button",
			name = "Test Settings",
			func = function(control) 		
				self:OnUpdateSubtitle(0, CHAT_CHANNEL_MONSTER_SAY, "Heseoden", "Do you know the old saying?")
				self:OnUpdateSubtitle(0, CHAT_CHANNEL_MONSTER_SAY, "Heseoden", "Neither a borrower or a lender be? Rubbish! Without borrowers and lenders, how would we ever be able to buy or sell anything?")		
			end,

		},
		
		{
			type = "checkbox",
			name = "Show NPC names",
			getFunc = function() return self.sv.showNames end,
			setFunc = function(state) self.sv.showNames = state end,
		},

	} -- options data end
	
	LAM:RegisterOptionControls("HarvensSubtitles_OptionsPanel", optionsData)

end

function Harven_SubtitleAddon:UpdateSubtitles()
	EVENT_MANAGER:UnregisterForUpdate("Harven_SubtilesAddon_Update")
	local minTime = 100000

	local now = GetFrameTimeMilliseconds()

	local cmsg = self.chatMessagesLast
	while cmsg ~= nil do
		if cmsg.ttl-now <= 10 and cmsg == self.chatMessagesLast then
			if cmsg.prev ~= nil then
				self.chatMessagesLast = cmsg.prev
				cmsg.prev.next = nil
				cmsg = self.chatMessagesLast
			else
				self.chatMessagesLast = nil
				self.chatMessagesPrev = nil
				break
			end
		elseif cmsg.ttl - now < minTime then
			minTime = cmsg.ttl - now
			if minTime < 0 then
				minTime = 0
			end
			cmsg = cmsg.prev
		else
			cmsg = cmsg.prev
		end
	end

	if self.chatMessagesLast == nil and cmsg ~= nil then
		self.subtitleLabel:SetText( self.sv.showNames and zo_strformat("<<1>>: <<2>>", cmsg.from, cmsg.val) or zo_strformat("- <<1>>", cmsg.val) )
		local height = self.subtitleLabel:GetTextHeight()
		self.control:SetHeight(height + 40)
		self.subtitleAnimation:PlayFromStart(0)
	elseif self.chatMessagesLast ~= nil then
		local messages = "";
		cmsg = self.chatMessagesLast
		while cmsg ~= nil do
			if cmsg ~= self.chatMessagesLast then
				messages = messages.."\n"
			end
			messages = messages..(self.sv.showNames and zo_strformat("<<1>>: <<2>>", cmsg.from, cmsg.val) or zo_strformat("- <<1>>", cmsg.val))
			cmsg = cmsg.prev
		end
		self.subtitleLabel:SetText( messages )
		local height = self.subtitleLabel:GetTextHeight()
		self.control:SetHeight(height + 40)
	end
	EVENT_MANAGER:RegisterForUpdate("Harven_SubtilesAddon_Update", minTime, self.CheckSubtitles)
end

function Harven_SubtitleAddon:OnUpdateSubtitle(eventCode, msgType, from, text)
	if msgType ~= CHAT_CHANNEL_MONSTER_EMOTE and 
		msgType ~= CHAT_CHANNEL_MONSTER_SAY and
		msgType ~= CHAT_CHANNEL_MONSTER_WHISPER and
		msgType ~= CHAT_CHANNEL_MONSTER_YELL then return end

	local from = zo_strformat("<<C:1>>", from)
	
	if self.sv.ignored[string.lower(from)] == 1 then return end
	
	local message = self.sv.showNames and zo_strformat("<<1>>: <<2>>", from, text) or zo_strformat("- <<1>>", text)
	local now = GetFrameTimeMilliseconds()
	local timeout = 1000 * ( 2 + ( #message * 0.05 ) ) + now

	if self.subtitleAnimation:IsPlaying() then
		self.subtitleLabel:SetText( "" )
		self.subtitleAnimation:Stop()
	end

	if self.chatMessagesLast == nil then
		self.chatMessagesFirst = { next = nil, prev = nil, val = text, ttl = timeout, from = from }
		self.chatMessagesLast = self.chatMessagesFirst
	else
		local chatMessage = { next = self.chatMessagesFirst, prev = nil, val = text, ttl = timeout, from = from }
		chatMessage.next.prev = chatMessage 
		self.chatMessagesFirst = chatMessage 
	end
	
	local messages = self.subtitleLabel:GetText()
	if #messages > 0 then
		messages = messages.."\n"..message
	else
		messages = message
	end
	self.subtitleLabel:SetText( messages )
	local height = self.subtitleLabel:GetTextHeight()
	self.control:SetHeight(height + 40)
	self.control:SetHidden(false)
	self.control:SetAlpha(1)

	local minTime = 100000
	local cmsg = self.chatMessagesFirst
	while cmsg ~= nil do
		if cmsg.ttl - now < minTime then
			minTime = cmsg.ttl - now
			if minTime < 0 then
				minTime = 0
			end
		end
		cmsg = cmsg.next
	end

	EVENT_MANAGER:UnregisterForUpdate("Harven_SubtilesAddon_Update")
	EVENT_MANAGER:RegisterForUpdate("Harven_SubtilesAddon_Update", minTime, self.CheckSubtitles)
end

local function Harven_SubtitleAddonOnUpdateSubtitle(...)
	Harven_SubtitleAddon:OnUpdateSubtitle(...)
end

function Harven_SubtitleAddon:OnLoaded()

	local defaults = { x = -20, y = -120, point = BOTTOMRIGHT, relPoint = BOTTOMRIGHT, ignored = {}, showNames = false, scale = 1.0, bgalpha=1.0, width = 840 }
	self.sv = ZO_SavedVars:New("HarvensSubtitleAddon_SavedVariables", 1, nil, defaults)
	self.control:SetAnchor(self.sv.point, nil, self.sv.relPoint, self.sv.x, self.sv.y)
	self.control:GetNamedChild("Bg"):SetAlpha( self.sv.bgalpha )
	self.control:SetScale( self.sv.scale )
	self.control:SetWidth(self.sv.width)
	self.subtitleLabel:SetWidth(self.sv.width-80)
	
	EVENT_MANAGER:RegisterForEvent("Harven_SubtitleAddon", EVENT_CHAT_MESSAGE_CHANNEL, Harven_SubtitleAddonOnUpdateSubtitle)
	
	Harven_SubtitleAddon:SetupOptions()
end

function Harven_SubtitleAddonOnLoaded(eventType, addonName)
	if addonName ~= "HarvensSubtitleAddon" then return end
	Harven_SubtitleAddon:OnLoaded()
end

function Harven_SubtitleAddon:Initialize(control)
	self.control = control
	self.subtitleLabel = control:GetNamedChild("Text")
	self.chatMessagesFirst = nil
	self.chatMessagesLast = nil

	self.subtitleAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("SubtitlesAddonFade", self.control)
	self.subtitleAnimation:SetHandler("OnStop", function(timeline)
		self.subtitleLabel:SetText( "" )
		self.control:SetHidden(true)
		EVENT_MANAGER:UnregisterForUpdate("Harven_SubtilesAddon_Update")
       	end)

	self.CheckSubtitles = function()
		self:UpdateSubtitles()
	end

	local function OnMoveStop()
		_, self.sv.point, _, self.sv.relPoint, self.sv.x, self.sv.y = self.control:GetAnchor(0)
	end

	ESO_Dialogs["HARVENS_SUBTITLES_ADDON_IGNORE_CONFIRMATION"] = {
	    title =
	    {
	        text = "IGNORE NPC SUBTITLES",
	    },
	    mainText = 
	    {
	        text = "Are you sure you want to ignore subtitles for <<1>>?",
	    },
	    buttons =
	    {
	        [1] =
	        {
	            text = SI_DIALOG_YES,
	            callback = function(dialog)
	            			self.sv.ignored[string.lower(dialog.data.npcName)] = 1
	            			CHAT_SYSTEM:AddMessage("Harven's Subtitle Addon: "..dialog.data.npcName.." added to ignore list.")
							end,
	        },
	        
	        [2] =
	        {
	            text = SI_DIALOG_NO,
	        }
	    }
	}

	local function ToggleEnableNPCNames()
		self.sv.showNames = not(self.sv.showNames)
		messages = ""
		cmsg = self.chatMessagesLast
		while cmsg ~= nil do
			if cmsg ~= self.chatMessagesLast then
				messages = messages.."\n"
			end
			messages = messages..(self.sv.showNames and zo_strformat("<<1>>: <<2>>", cmsg.from, cmsg.val) or zo_strformat("- <<1>>", cmsg.val))
			cmsg = cmsg.prev
		end
		self.subtitleLabel:SetText( messages )
		local height = self.subtitleLabel:GetTextHeight()
		self.control:SetHeight(height + 40)
	end

	local function OnMouseDown(control, button)
		if button == 2 then
			ClearMenu()
			if self.sv.showNames == false then
				AddMenuItem("Enable NPC Names", ToggleEnableNPCNames)
			else
				AddMenuItem("Disable NPC Names", ToggleEnableNPCNames)
			end
			local cmsg = self.chatMessagesFirst
			while cmsg ~= nil do
				local name = cmsg.from
				AddMenuItem("Ignore "..cmsg.from, function()
					ZO_Dialogs_ShowDialog("HARVENS_SUBTITLES_ADDON_IGNORE_CONFIRMATION", {npcName=name}, {mainTextParams={name}})
				end)
				cmsg = cmsg.next
			end
			ShowMenu(control, 1)
		end
	end

	SLASH_COMMANDS["/subtitlesunignore"] = function(...)
		local name = ""
		for i=1,select("#",...) do
			name = name..(select(i,...))
		end
		if self.sv.ignored[name] == nil then
			CHAT_SYSTEM:AddMessage("Harven's Subtitle Addon: "..name.." is not ignored.")
			return
		end
		
		self.sv.ignored[name] = nil
		CHAT_SYSTEM:AddMessage("Harven's Subtitle Addon: "..name.." is no longer ignored.")
	end

	local function OnMouseWheel(control, delta, ctr, alt, shift)
		if shift == true then
			local scale = control:GetScale()
			scale = scale + delta*0.1
			if scale < 0.1 then scale = 0.1 end
			control:SetScale( scale )
			self.sv.scale = scale
		else
			local bg = control:GetNamedChild("Bg")
			local r,g,b,a = bg:GetColor()
			a = a + delta*0.1
			if a > 1 then a = 1 end
			if a < 0 then a = 0 end
			bg:SetColor( r, g, b, a )
			self.sv.bgalpha = a
		end
	end

	control:SetHandler("OnMoveStop", OnMoveStop)
	control:SetHandler("OnMouseDown", OnMouseDown)
	control:SetHandler("OnMouseWheel", OnMouseWheel)
	control:RegisterForEvent(EVENT_ADD_ON_LOADED, Harven_SubtitleAddonOnLoaded)
end

function Harven_SubtitleAddonInitialize(control)
	_G["Harven_SubtitleAddon"] = Harven_SubtitleAddon:New(control)
end