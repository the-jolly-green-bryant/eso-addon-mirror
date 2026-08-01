-- ***** BountyTimer *****


--------------------------------------------------
-- Initialize addon variables
--------------------------------------------------
BountyTimer = {}
BountyTimer.name = "BountyTimer"
BountyTimer.slashCommand = "/bt"
BountyTimer.debug = false
BountyTimer.settingsMode = false
BountyTimer.callDelay = 280
BountyTimer.showWindow = false


BountyTimer.iconList = {
	[1] = {description = "None", value = ""},
	[2] = {description = "Skulls", value = "/esoui/art/icons/crafting_skeleton_skull.dds"},
	[3] = {description = "Knife", value = "/esoui/art/icons/housing_gen_crf_tablepropsknife001.dds"},
	[4] = {description = "Dagger", value = "/esoui/art/icons/gear_breton_dagger_b.dds"}
}

BountyTimer.fontNames = {
	[1] = {name = "Medium", value = "MEDIUM_FONT"},
	[2] = {name = "Bold", value = "BOLD_FONT"},
	[3] = {name = "Chat", value = "CHAT_FONT"},
	[4] = {name = "Antique", value = "ANTIQUE_FONT"},
	[5] = {name = "Handwritten", value = "HANDWRITTEN_FONT"},
	[6] = {name = "Stone", value = "STONE_TABLET_FONT"}
}

--------------------------------------------------
-- Default saved variable settings
--------------------------------------------------
BountyTimer.defaults = {
	left = 500,
	top = 500,
	hideOriginal = true,
	lockWindow = true,
	icon = 1,
	fontSize = 30,
	fontName = 2,
	background = {0,0,0,0}
}


--------------------------------------------------
-- Initialize settings, load saved variables and register event triggers.
--------------------------------------------------
function BountyTimer.Initialize()
	BountyTimer.savedVariables = ZO_SavedVars:NewAccountWide("BountyTimerSavedVariables", 1, nil, BountyTimer.defaults)
	BountyTimer.RestoreIndicator()

	--------------------------------------------------
	-- Set the event handlers
	--------------------------------------------------
	EVENT_MANAGER:RegisterForEvent(BountyTimer.name, EVENT_JUSTICE_INFAMY_UPDATED, BountyTimer.PlayerHasBounty)
	EVENT_MANAGER:RegisterForEvent(BountyTimer.name, EVENT_PLAYER_ACTIVATED, BountyTimer.PlayerHasBounty)
end


--------------------------------------------------
-- Restores the bounty indicator from the savedVariables
--------------------------------------------------
function BountyTimer.RestoreIndicator()
	local left = BountyTimer.savedVariables.left
	local top = BountyTimer.savedVariables.top
	local font = BountyTimer.fontNames[BountyTimer.savedVariables.fontName].value
	local fontString = "$("..font..") |" .. BountyTimer.savedVariables.fontSize .. "| soft-shadow-thick"
	
	BountyIndicator:ClearAnchors()
	BountyIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
	BountyIndicator:SetMovable(BountyTimer.savedVariables.lockWindow)
	BountyIndicatorLabel:SetFont(fontString)
	BountyIndicator:SetHidden(true)
	local r = BountyTimer.savedVariables.background[1]
	local g = BountyTimer.savedVariables.background[2]
	local b = BountyTimer.savedVariables.background[3]
	local a = BountyTimer.savedVariables.background[4]
	BountyIndicatorBG:SetCenterColor(r, g, b, a)
	BountyIndicatorBG:SetEdgeColor(r, g, b, a)
	BountyTimer.SetSize()

end


--------------------------------------------------
-- Called when the user finishes moving the Indicator - Triggered from BountyTimer.xml.
--------------------------------------------------
function BountyTimer.OnIndicatorMoveStop()
	BountyTimer.savedVariables.left = BountyIndicator:GetLeft()
	BountyTimer.savedVariables.top = BountyIndicator:GetTop()
end


--------------------------------------------------
-- Called when a menu setting is changed - Triggered from BountyTimerSettings.lua.
--------------------------------------------------
function BountyTimer.OptionSet()
	BountyIndicator:SetMovable(BountyTimer.savedVariables.lockWindow)
	ZO_HUDInfamyMeter:SetHidden(BountyTimer.savedVariables.hideOriginal)
end


--------------------------------------------------
-- Called when the icon menu setting is changed - Triggered from BountyTimerSettings.lua.
--------------------------------------------------
function BountyTimer.SetIcon(name)
	local iconDropdownOptions ={}
	
	for key, value in ipairs(BountyTimer.iconList) do
		if BountyTimer.debug then d("Icon Key: " .. key) end
		if name == value.description then
			BountyTimer.savedVariables.icon = tonumber(key)
			break
		end
	end
	
end


--------------------------------------------------
-- Called when a font setting is changed - Triggered from BountyTimerSettings.lua
--------------------------------------------------
function BountyTimer.SetFontName(name)
	for key, value in ipairs(BountyTimer.fontNames) do
		if BountyTimer.debug then d("Font Key: "..key) end
		if name == value.name then
			BountyTimer.savedVariables.fontName = tonumber(key)
			break
		end
	end
end


--------------------------------------------------
-- Called when the user changes font size - Triggered from BountyTimerSettings.lua
--------------------------------------------------
function BountyTimer.SetFont()
	local fontKey = BountyTimer.savedVariables.fontName
	local font = BountyTimer.fontNames[BountyTimer.savedVariables.fontName].value
	local fontString = "$("..font..") |" .. BountyTimer.savedVariables.fontSize .. "| soft-shadow-thick"
	
	BountyIndicatorLabel:SetFont(fontString)
	BountyTimer.SetSize()
	
	if BountyTimer.debug then d("Font String: " .. fontString) end
end

function BountyTimer.SetShowing(value)
	BountyTimer.showWindow = value
	BountyIndicator:SetHidden(not value)
end

function BountyTimer.GetBackground()
	local r = BountyTimer.savedVariables.background[1]
	local g = BountyTimer.savedVariables.background[2]
	local b = BountyTimer.savedVariables.background[3]
	local a = BountyTimer.savedVariables.background[4]
	return r, g, b, a
end

function BountyTimer.SetBackground(r, g, b, a)
	BountyTimer.savedVariables.background = {r, g, b, a}
	BountyIndicatorBG:SetCenterColor(r, g, b, a)
	BountyIndicatorBG:SetEdgeColor(r, g, b, a)
end

function BountyTimer.SetSize()
	local width, height = BountyIndicatorLabel:GetDimensions()
	BountyIndicator:SetDimensions(width + 40, height + 20)
end
--------------------------------------------------
-- Called when EVENT_JUSTICE_INFAMY_UPDATED or EVENT_PLAYER_ACTIVATED triggers.
--------------------------------------------------
function BountyTimer.PlayerHasBounty(event, oldBounty, newBounty, isInitialize)
	--------------------------------------------------
	-- The in-game hud reloads whenever chat, bank, inventory, merchant, etc is closed
	-- so it keeps popping back up.  EVENT_ACTION_LAYER_POPPED seems to triggered
	-- around the time the other screens are closed, and the in-game infamy HUD
	-- reloads.  Added in a bounty check because this can be triggered by
	-- EVENT_PLAYER_ACTIVATED with no actual bounty.
	--------------------------------------------------
	if GetSecondsUntilBountyDecaysToZero() > 0 then
		BountyIndicator:SetHidden(false)
		
		if BountyTimer.debug then d(GetTimeStamp().." - Register for POP") end
		EVENT_MANAGER:RegisterForEvent(BountyTimer.name,  EVENT_ACTION_LAYER_POPPED, BountyTimer.Pop)
		
		--------------------------------------------------
		-- Call the swatter manually because there are conditions where it may not trigger otherwise.
		--------------------------------------------------
		if BountyTimer.debug then d(GetTimeStamp().." - Call Swatter") end
		BountyTimer.Swatter() 
		if BountyTimer.debug then d(GetTimeStamp().." - Run Countdown") end
		BountyTimer.Countdown()
	end
end


--------------------------------------------------
-- Called in a loop to keep updating the bounty amount and the timer.
--------------------------------------------------
function BountyTimer.Countdown()
	local bountySeconds = GetSecondsUntilBountyDecaysToZero()
	
	if bountySeconds ~= 0 then
		local bountyAmount = GetFullBountyPayoffAmount()
		local countdownTimer = BountyTimer.OutputClock(bountySeconds)
		local infamyNumber = GetInfamyLevel(GetInfamy())
		local outputText = "|cFF0000Bounty:|r|cD4AF37 "..bountyAmount.."|r\n"
		
		--------------------------------------------------
		-- INFAMY_THRESHOLD_FUGITIVE is a game-defined global constant: https://wiki.esoui.com/Globals#InfamyThresholdsType
		--------------------------------------------------
		if infamyNumber == INFAMY_THRESHOLD_FUGITIVE then
			local key = BountyTimer.savedVariables.icon
			local texture = BountyTimer.iconList[key].value
			if key == 1 then
				icon = ""
			else
				icon = "|t100%:100%:"..texture.."|t"
			end
			outputText = outputText..icon.."|cFF0000 "..countdownTimer.."|r "..icon	
		else
			outputText = outputText.."|cFFFFFF"..countdownTimer.."|r"
		end
		--  GetPlayerInfamyData() 260
		BountyIndicatorLabel:SetText(outputText)
		BountyTimer.SetSize()
		--------------------------------------------------
		--  Call this function again in 1000 milliseconds.
		--------------------------------------------------
		zo_callLater(BountyTimer.Countdown, 1000)
	else
		
		--------------------------------------------------
		-- There is no more bounty
		-- Allows the infamy level announcements to trigger so it can tell you you are upstanding again.
		-- Somehow the announcement is directly connected to the Infamy Meter.
		--------------------------------------------------
		if BountyTimer.debug then d(GetTimeStamp().." - UnPOP") end
		EVENT_MANAGER:UnregisterForEvent(BountyTimer.name, EVENT_ACTION_LAYER_POPPED)
		BountyIndicator:SetHidden(true)
		ZO_HUDInfamyMeter:SetHidden(false)
	end
end


--------------------------------------------------
-- Called whenever a "pop" event occurs (EVENT_ACTION_LAYER_POPPED),
-- which is usually the time the in-game infamy hud wants to turn itself back on.
--------------------------------------------------
function BountyTimer.Pop()
	if BountyTimer.debug then d(GetTimeStamp().." - POP") end
	
	--------------------------------------------------
	-- Have to build in a delay.  The in-game infamy hud loads a few milliseconds
	-- after the pop.  So if I don't delay, I swat it closed before it even opens
	-- and therefore it never gets hidden.
	--------------------------------------------------
	zo_callLater(BountyTimer.Swatter, BountyTimer.callDelay)
end


--------------------------------------------------
-- Called several milliseconds after the POP event occurs to give the in-game hud time
-- to trigger before we swat it closed again.
--------------------------------------------------
function BountyTimer.Swatter()
	ZO_HUDInfamyMeter:SetHidden(BountyTimer.savedVariables.hideOriginal)
	if BountyTimer.debug then d(GetTimeStamp().." - SWAT") end
end


--------------------------------------------------
-- Changes the number of seconds into a h:m:s clock format
--------------------------------------------------
function BountyTimer.OutputClock(seconds)
  local seconds = tonumber(seconds)
  
  if seconds <= 0 then
    return "00:00:00";
  else
    hours = string.format("%02.f", math.floor(seconds/3600));
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return hours..":"..mins..":"..secs
  end
end


--------------------------------------------------
-- SlashCommand Debug - various debug and development information triggered by the slash command
--------------------------------------------------
function BountyTimer.Tester()
	d("Current Size: " .. BountyTimer.savedVariables.fontSize)
	fontSize = 60
	local fontString = "$(BOLD_FONT) |" .. fontSize .. "| soft-shadow-thick"
		BountyIndicatorLabel:SetFont(fontString)

	d("New Size: " .. fontString)
end


-- ***** Main *****


--------------------------------------------------
-- Check to see if this addon is the one loaded
--------------------------------------------------
function BountyTimer.OnAddOnLoaded(event, addonName)
	if addonName == BountyTimer.name then
		if BountyTimer.debug then SLASH_COMMANDS[BountyTimer.slashCommand] = BountyTimer.Tester end
		BountyTimer.Initialize()
		
		--------------------------------------------------
		-- Was getting an error message from LAM saying the settings panel was trying to load before the
		-- rest of the addon loaded.  Wrapping it in a function seems to have fixed it.
		--------------------------------------------------
		BountyTimer.InitializeSettingsMenu()
		EVENT_MANAGER:UnregisterForEvent(BountyTimer.name, EVENT_ADD_ON_LOADED)
	end
end


EVENT_MANAGER:RegisterForEvent(BountyTimer.name, EVENT_ADD_ON_LOADED, BountyTimer.OnAddOnLoaded)