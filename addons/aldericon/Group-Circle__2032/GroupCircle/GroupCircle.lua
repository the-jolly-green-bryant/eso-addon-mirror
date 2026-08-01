--[[
This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. 
The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. 
All rights reserved

You can read the full terms at https://account.elderscrollsonline.com/add-on-terms]]

--[[
Acknowledgments

I'd like to thank the following addons:
- Provision's TeamFormation by Provision
- Combat Reticle by Aetheron
]]

-- Initialized the addon names
GroupCircle = {}
GroupCircle.name = "GroupCircle"
GroupCircle.version = 10.0

GroupCircle.preventChangeCircleHiddenStatus = false
GroupCircle.playerInPvP = false

-- For the addon settings menu
GroupCircle.LAM2 = LibAddonMenu2

GroupCircle.defaultLeft = -6
GroupCircle.defaultTop = 0
GroupCircle.defaultLineWidth = 400

GroupCircle.defaults={
	color={0.46274510025978, 0.73725491762161, 0.76470589637756, 1},
	size=400,
	transparency=0.5,
	enabledOnlyInPvP=true,
	displayLeft=GroupCircle.defaultLeft,
	displayTop=GroupCircle.defaultTop,
	unlocked=false,
	siegeEngine=false,
	dpsLines=false,
	dpsLineSize=350,
	dpsLine1Scale=-80,
	dpsLine2Scale=110
}

-- Loads the addon; only hit once
function GroupCircle.OnAddOnLoaded(event, addonName)
	-- The event fires each time *any* addon loads; but we only care about when our own addon loads.
	if addonName ~= GroupCircle.name then
		return
	end

	GroupCircle.SV = ZO_SavedVars:NewAccountWide("GroupCircleTrackerSettings", 1.0, "AccountWide", GroupCircle.defaults)

	GroupCircle:InitializeAddonMenu()

	EVENT_MANAGER:UnregisterForEvent(GroupCircle.name, EVENT_ADD_ON_LOADED)

	GroupCircle:Initialize()
	GroupCircle.changeCircle()
end

function GroupCircle:Initialize()
	EVENT_MANAGER:RegisterForEvent(GroupCircle.name, EVENT_ACTION_LAYER_PUSHED, GroupCircle.OnActionLayerChange)
	EVENT_MANAGER:RegisterForEvent(GroupCircle.name, EVENT_ACTION_LAYER_POPPED, GroupCircle.OnActionLayerChange)
	EVENT_MANAGER:RegisterForEvent(GroupCircle.name, EVENT_GROUP_MEMBER_JOINED, GroupCircle.OnGroupPlayerJoin)
	EVENT_MANAGER:RegisterForEvent(GroupCircle.name, EVENT_GROUP_MEMBER_LEFT, GroupCircle.OnGroupPlayerLeft)
	EVENT_MANAGER:RegisterForEvent(GroupCircle.name, EVENT_PLAYER_ACTIVATED, GroupCircle.OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(GroupCircle.name, EVENT_BEGIN_SIEGE_CONTROL, GroupCircle.OnSiegeControlStart)
	EVENT_MANAGER:RegisterForEvent(GroupCircle.name, EVENT_END_SIEGE_CONTROL, GroupCircle.OnSiegeControlEnd)
end

function GroupCircle:OnOff()
	if ((GroupCircle.SV.enabledOnlyInPvP == true and GroupCircle.playerInPvP == true) or GroupCircle.SV.enabledOnlyInPvP == false) and GetGroupSize() > 0 then
		EVENT_MANAGER:RegisterForEvent(GroupCircle.name, EVENT_ACTION_LAYER_PUSHED, GroupCircle.OnActionLayerChange)
		EVENT_MANAGER:RegisterForEvent(GroupCircle.name, EVENT_ACTION_LAYER_POPPED, GroupCircle.OnActionLayerChange)
		EVENT_MANAGER:RegisterForEvent(GroupCircle.name, EVENT_GROUP_MEMBER_JOINED, GroupCircle.OnGroupPlayerJoin)
		EVENT_MANAGER:RegisterForEvent(GroupCircle.name, EVENT_GROUP_MEMBER_LEFT, GroupCircle.OnGroupPlayerLeft)
		EVENT_MANAGER:RegisterForEvent(GroupCircle.name, EVENT_PLAYER_ACTIVATED, GroupCircle.OnPlayerActivated)
		EVENT_MANAGER:RegisterForEvent(GroupCircle.name, EVENT_BEGIN_SIEGE_CONTROL, GroupCircle.OnSiegeControlStart)
		EVENT_MANAGER:RegisterForEvent(GroupCircle.name, EVENT_END_SIEGE_CONTROL, GroupCircle.OnSiegeControlEnd)

		GroupCircle.preventChangeCircleHiddenStatus = false
		GroupCircle.HideCircle()
	else
		EVENT_MANAGER:UnregisterForEvent(GroupCircle.name, EVENT_ACTION_LAYER_PUSHED)
		EVENT_MANAGER:RegisterForEvent(GroupCircle.name, EVENT_ACTION_LAYER_POPPED)
		EVENT_MANAGER:RegisterForEvent(GroupCircle.name, EVENT_GROUP_MEMBER_JOINED)
		EVENT_MANAGER:RegisterForEvent(GroupCircle.name, EVENT_GROUP_MEMBER_LEFT)
		EVENT_MANAGER:RegisterForEvent(GroupCircle.name, EVENT_PLAYER_ACTIVATED)
		EVENT_MANAGER:RegisterForEvent(GroupCircle.name, EVENT_BEGIN_SIEGE_CONTROL)
		EVENT_MANAGER:RegisterForEvent(GroupCircle.name, EVENT_END_SIEGE_CONTROL)

		GroupCircle.preventChangeCircleHiddenStatus = true
		GroupCircleWindow:SetHidden(true)
	end
end

function GroupCircle.changeCircle()
	GroupCircleWindow_Circle:SetColor(unpack(GroupCircle.SV.color)) -- obv color
	GroupCircleWindow_Circle:SetAlpha(GroupCircle.SV.transparency) -- transparency
	GroupCircleWindow_Circle:SetDimensions(GroupCircle.SV.size, GroupCircle.SV.size) -- how large
	GroupCircleWindow_Circle:SetAnchor(CENTER, GuiRoot, nil, GroupCircle.SV.displayLeft, GroupCircle.SV.displayTop);
	GroupCircleWindow_Circle:SetMouseEnabled(GroupCircle.SV.unlocked) 
	GroupCircleWindow_Circle:SetMovable(GroupCircle.SV.unlocked)

	GroupCircleWindow_Line1:SetHidden(not GroupCircle.SV.dpsLines)
	GroupCircleWindow_Line2:SetHidden(not GroupCircle.SV.dpsLines)
	GroupCircleWindow_Line1:SetColor(unpack(GroupCircle.SV.color))
	GroupCircleWindow_Line2:SetColor(unpack(GroupCircle.SV.color))
	GroupCircleWindow_Line1:SetMouseEnabled(GroupCircle.SV.unlocked) 
	GroupCircleWindow_Line2:SetMovable(GroupCircle.SV.unlocked)
	GroupCircleWindow_Line1:SetMouseEnabled(GroupCircle.SV.unlocked) 
	GroupCircleWindow_Line2:SetMovable(GroupCircle.SV.unlocked)
	GroupCircleWindow_Line1:SetAlpha(GroupCircle.SV.transparency)
	GroupCircleWindow_Line2:SetAlpha(GroupCircle.SV.transparency)
	GroupCircleWindow_Line1:SetDimensions(GroupCircle.defaultLineWidth, GroupCircle.SV.dpsLineSize)
	GroupCircleWindow_Line2:SetDimensions(GroupCircle.defaultLineWidth, GroupCircle.SV.dpsLineSize)

	GroupCircleWindow_Line1:SetAnchor(CENTER, GroupCircleWindow_Circle, nil, GroupCircle.SV.dpsLine1Scale, 0);
	GroupCircleWindow_Line2:SetAnchor(CENTER, GroupCircleWindow_Circle, nil, GroupCircle.SV.dpsLine2Scale, 0);
end

function GroupCircle.OnActionLayerChange(eventCode, layerIndex, activeLayerIndex)
	if GroupCircle.preventChangeCircleHiddenStatus == true or GroupCircle.SV.unlocked == true then
		return
	end

	GroupCircleWindow:SetHidden(activeLayerIndex > 2)
end

function GroupCircle.HideCircle()
	GroupCircleWindow:SetHidden(GetGroupSize() == 0)
end

function GroupCircle.OnGroupPlayerJoin(eventCode, memberCharacterName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVot)
	GroupCircle:OnOff()
end

function GroupCircle.OnGroupPlayerLeft(eventCode, memberCharacterName)
	GroupCircle:OnOff()
end

function GroupCircle.OnPlayerActivated(eventCode, initial)
	GroupCircle.playerInPvP = IsPlayerInAvAWorld()
	GroupCircle:OnOff()
end

function GroupCircle.OnSiegeControlStart(eventCode)
	if GroupCircle.SV.siegeEngine == true then
		return
	end

	GroupCircle.preventChangeCircleHiddenStatus = true
	GroupCircleWindow:SetHidden(true)
end

function GroupCircle.OnSiegeControlEnd(eventCode)
	if GroupCircle.SV.siegeEngine == true then
		return
	end

	GroupCircle.preventChangeCircleHiddenStatus = false
	GroupCircle.HideCircle()
end

-- Saves the positioning of the display window
function GroupCircle.DisplayOnMoveStop()
	GroupCircle.SV.displayLeft = GroupCircleWindow_Circle:GetLeft();
	GroupCircle.SV.displayTop = GroupCircleWindow_Circle:GetTop();
end

function GroupCircle.CenterCircle()
	GroupCircle.SV.displayLeft = GroupCircle.defaultLeft
	GroupCircle.SV.displayTop = GroupCircle.defaultTop
	GroupCircle.changeCircle()
end

-- Creates the addon settings menu
function GroupCircle:InitializeAddonMenu()
	local panelData = {
		type = "panel",
		name = "Group Circle",
		displayName = "|c66ccffGroup Circle",
		author = "|c4779ce@aldericon|r",
		version = string.format("%.2f", GroupCircle.version),
		slashCommand = "/gc",
		registerForRefresh = true,
		registerForDefaults = true
	}

	local optionsPanel = self.LAM2:RegisterAddonPanel("Group_Circle", panelData)
	local optionsData = {}

	table.insert(optionsData, {
		type = "description",
		text = "Group Circle provides a centralized circle in the middle of your screen. This addon was created to work with Provision's TeamFormation addon and allows you to set a maximum of how far away your group should be from crown. If you are out of the circle, you're not on crown.",
	})
	table.insert(optionsData, {
		type = "header",
		name = "Group Circle Options",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Turn OFF when satisfied with frame positions",
		tooltip = "ON - circle can be moved, OFF - circle cannot be moved",
		default = self.defaults.unlocked,
		getFunc = function() return self.SV.unlocked end,
		setFunc = function(newValue) self.SV.unlocked = newValue GroupCircle.changeCircle() end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Enabled only in PVP:",
		tooltip = "ON - enabled in PVP only (does not include Battlegrounds), OFF - enabled everywhere",
		default = self.defaults.enabledOnlyInPvP,
		getFunc = function() return self.SV.enabledOnlyInPvP end,
		setFunc = function(newValue) self.SV.enabledOnlyInPvP = newValue self:OnOff() end,
	})
	table.insert(optionsData, {
		type = "colorpicker",
		name = "Circle Color:",
		tooltip = "Pick the color of the circle",
        default = ZO_ColorDef:New(unpack(self.SV.color)),
        getFunc = function() return unpack(self.SV.color) end,
		setFunc = function(r,g,b,a)
            self.SV.color = {r,g,b,a}
			self.changeCircle()
        end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Circle Transparency:",
		tooltip = "How much you can see through the circle",
		default = 0.5,
		min     = 0,
        max     = 1,
        step    = 0.1,
		getFunc = function() return self.SV.transparency end,
		setFunc = function(newValue) self.SV.transparency = newValue self.changeCircle() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "Circle Scale:",
		tooltip = "How large the circle is",
		default = self.defaults.size,
		min     = 0,
        max     = 1500,
        step    = 1,
		getFunc = function() return self.SV.size end,
		setFunc = function(newValue) self.SV.size = newValue self.changeCircle() end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Show on Siege Engine:",
		tooltip = "ON - display circle while on a siege engine, OFF - display no circle when on a siege engine",
		default = self.defaults.siegeEngine,
		getFunc = function() return self.SV.siegeEngine end,
		setFunc = function(newValue) self.SV.siegeEngine = newValue end,
	})
	table.insert(optionsData, {
		type = "button",
		name = "Auto-Center Circle",
		tooltip = 'Auto-Center the circle to the middle of your screen',
		func = function ()
			GroupCircle.CenterCircle()
		end,
	})
	--[[table.insert(optionsData, {
		type = "checkbox",
		name = "Display DPS Lines:",
		tooltip = "ON - display dps lines on either side of circle, OFF - display no dps lines",
		default = self.defaults.siegeEngine,
		getFunc = function() return self.SV.dpsLines end,
		setFunc = function(newValue) self.SV.dpsLines = newValue self.changeCircle() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "DPS Line Length:",
		tooltip = "How long the dps lines are",
		default = self.defaults.dpsLineSize,
		disabled = function()
			if self.SV.dpsLines == false then
				return true
			end
		end,
		min     = 0,
        max     = 1500,
        step    = 1,
		getFunc = function() return self.SV.dpsLineSize end,
		setFunc = function(newValue) self.SV.dpsLineSize = newValue self.changeCircle() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "DPS Line #1 Scale:",
		tooltip = "How far away the line is from the center of the circle",
		default = self.defaults.dpsLine1Scale,
		disabled = function()
			if self.SV.dpsLines == false then
				return true
			end
		end,
		min     = -150,
        max     = 0,
        step    = 1,
		getFunc = function() return self.SV.dpsLine1Scale end,
		setFunc = function(newValue) self.SV.dpsLine1Scale = newValue self.changeCircle() end,
	})
	table.insert(optionsData, {
		type = "slider",
		name = "DPS Line #2 Scale:",
		tooltip = "How far away the line is from the center of the circle",
		default = self.defaults.dpsLine2Scale,
		disabled = function()
			if self.SV.dpsLines == false then
				return true
			end
		end,
		min     = 0,
        max     = 150,
        step    = 1,
		getFunc = function() return self.SV.dpsLine2Scale end,
		setFunc = function(newValue) self.SV.dpsLine2Scale = newValue self.changeCircle() end,
	})]]

	self.LAM2:RegisterOptionControls("Group_Circle", optionsData)
end

-- so that ESO can register the addon
EVENT_MANAGER:RegisterForEvent(GroupCircle.name, EVENT_ADD_ON_LOADED, GroupCircle.OnAddOnLoaded)
