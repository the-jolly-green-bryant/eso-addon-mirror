local LAM2
local LCM
local AddonVersion = "1.05"
local wasInGroup = false
local addonName = "DeathCounter"
local playerTag = 'player'

local DC = {
	defaultSettings = {
		left = 460,
		top = 734,
		maxRows = 6,
		enabled = true,
		keepActive = false,
		lockUI = false,
		newGroupReset = true,
	},
	
	vars = nil,
	activated = false,
	groupSize = 0,
	units = { },
	panels = { },
	
	roleIcons = {
		[LFG_ROLE_DPS] = "/esoui/art/lfg/lfg_icon_dps.dds",
		[LFG_ROLE_TANK] = "/esoui/art/lfg/lfg_icon_tank.dds",
		[LFG_ROLE_HEAL] = "/esoui/art/lfg/lfg_icon_healer.dds",
		[LFG_ROLE_INVALID] = "/esoui/art/crafting/gamepad/crafting_alchemy_trait_unknown.dds",
	},
}

DeathCounter = DeathCounter or {}


function DC.OnAddOnLoaded( eventCode, name )
    if (name ~= addonName) then return end

    EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)

    DC.vars = ZO_SavedVars:NewAccountWide("DeathCounterSavedVariables", 1, nil, DC.defaultSettings, nil, "$InstallationWide")
	
	LCM = LibCustomMenu
	LAM2 = LibAddonMenu2
	
	DC.CreateSettingsMenu()
    DC.InitializeControls()

    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_GROUP_MEMBER_JOINED, DC.GroupUpdate)
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_GROUP_MEMBER_LEFT, DC.GroupUpdate)
	EVENT_MANAGER:RegisterForEvent(addonName, EVENT_PLAYER_ACTIVATED, DC.GroupUpdate)
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_GROUP_MEMBER_ROLE_CHANGED, DC.GroupMemberRoleChanged)
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_GROUP_SUPPORT_RANGE_UPDATE, DC.GroupSupportRangeUpdate)
	
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_UNIT_DEATH_STATE_CHANGED, DC.UnitDeath)

    DC.CheckActivation()
	if DC.vars.keepActive then 
		DC.Reset()
	end
end

function DeathCounter.OnMoveStop( )
	DC.vars.left = DeathCounterFrame:GetLeft()
	DC.vars.top = DeathCounterFrame:GetTop()
end

function DC.CheckActivation()
    local shouldShow = DC.vars.enabled and ((GetGroupSize() > 0 and IsUnitGrouped(playerTag)) or (DC.vars.keepActive))

    if shouldShow then
        if not DC.activated then
            DC.activated = true
            SCENE_MANAGER:GetScene("hud"):AddFragment(DC.fragment)
            SCENE_MANAGER:GetScene("hudui"):AddFragment(DC.fragment)
        end
    else
        if DC.activated then
            DC.activated = false
			wasInGroup = (IsUnitGrouped(playerTag) and DC.groupSize ~= 0)
            DC.units = { }
            SCENE_MANAGER:GetScene("hud"):RemoveFragment(DC.fragment)
            SCENE_MANAGER:GetScene("hudui"):RemoveFragment(DC.fragment)
            DC.HidePanels()
        end
    end
end

function DC.Reset()
    if not DC.activated then return end
	
	DC.groupSize = GetGroupSize()
	
	if IsUnitGrouped(playerTag) and (DC.groupSize ~= 0) then
		if DC.vars.newGroupReset and DC.vars.keepActive and not wasInGroup then
			DC.units = { }
		end
		wasInGroup = true
	else
		wasInGroup = false
	end
	
	for i = 1, GROUP_SIZE_MAX do
        local soloPanel = i == 1 and DC.groupSize == 0
        if (i <= DC.groupSize or soloPanel) then
            local unitTag = (soloPanel) and playerTag or GetGroupUnitTagByIndex(i)
            if (unitTag == nil) then return end
			local role
			if soloPanel then
				role = GetSelectedLFGRole()
			else
				role = GetGroupMemberSelectedRole(unitTag)
			end
            local playerName = GetUnitDisplayName(unitTag)
            if (DC.units[playerName] == nil) then
                DC.units[playerName] = {
                    panelId = i,
                    deaths = 0,
                    isDead = false,
                    self = AreUnitsEqual(playerTag, unitTag),
                }
            else
                DC.units[playerName].panelId = i
				if not IsUnitDead(unitTag) then
                    DC.units[playerName].isDead = false
                end
            end

            DC.panels[i].name:SetText(playerName)
            DC.panels[i].deaths:SetText(tostring(DC.units[playerName].deaths))
            DC.panels[i].role:SetTexture(DC.roleIcons[role])
            DC.UpdateRange(i, IsUnitInGroupSupportRange(unitTag))

            if (i == 1) then
                DC.panels[i].panel:SetAnchor(TOPLEFT, DeathCounterFrame, TOPLEFT, 0, 0)
            elseif (i <= DC.vars.maxRows) then
                DC.panels[i].panel:SetAnchor(TOPLEFT, DC.panels[i - 1].panel, BOTTOMLEFT, 0, 0)
            else
                DC.panels[i].panel:SetAnchor(TOPLEFT, DC.panels[i - DC.vars.maxRows].panel, TOPRIGHT, 0, 0)
            end

            DC.panels[i].panel:SetHidden(false)
        else
            DC.panels[i].panel:SetAnchor(TOPLEFT, DeathCounterFrame, TOPLEFT, 0, 0)
            DC.panels[i].panel:SetHidden(true)
        end
    end
end

function DC.HidePanels()
	for i = 1, GROUP_SIZE_MAX do
		DC.panels[i].panel:SetAnchor(TOPLEFT, DeathCounterFrame, TOPLEFT, 0, 0)
		DC.panels[i].panel:SetHidden(true)
	end
end

function DC.GroupUpdate(eventCode)
    DC.CheckActivation()
    if DC.activated then
        zo_callLater(function()
            DC.RefreshWithRetry(0)
        end, 1500)
    end
end

function DC.RefreshWithRetry(retryCount)
    DC.Reset()
    if not DC.VerifyPanels() and retryCount < 5 then
        zo_callLater(function()
            DC.RefreshWithRetry(retryCount + 1)
        end, 1000)
    end
end

function DC.VerifyPanels()
    local groupSize = GetGroupSize()
    local expectedCount = groupSize
	if groupSize == 0 then
		expectedCount = 1
	end

    local visibleCount = 0
    for i = 1, GROUP_SIZE_MAX do
        if not DC.panels[i].panel:IsHidden() then
            visibleCount = visibleCount + 1

            local name = DC.panels[i].name:GetText()
            if name == nil or name == "" then
                return false
            end
        end
    end

    return visibleCount == expectedCount
end

function DC.InitializeControls( )
	local wm = GetWindowManager()

	for i = 1, GROUP_SIZE_MAX do
		local panel = wm:CreateControlFromVirtual("DeathCounterPanel" .. i, DeathCounterFrame, "DeathCounterPanel")

		DC.panels[i] = {
			panel = panel,
			bg = panel:GetNamedChild("Backdrop"),
			name = panel:GetNamedChild("Name"),
			role = panel:GetNamedChild("Role"),
			deaths = panel:GetNamedChild("Deaths"),
		}

		DC.panels[i].bg:SetEdgeColor(0, 0, 0, 0)
		DC.panels[i].bg:SetCenterColor(0, 0, 0, 0.5)
		
	end
	
	DeathCounterFrame:SetMouseEnabled(true)
	DeathCounterFrame:SetMovable(not DC.vars.lockUI)
	DeathCounterFrame:SetHandler("OnMouseUp", function(self, button)
		if button == MOUSE_BUTTON_INDEX_RIGHT then
			DC.ShowContextMenu(self)
		end
	end)
	DeathCounterFrame:ClearAnchors()
	DeathCounterFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, DC.vars.left, DC.vars.top)
	
	DC.fragment = ZO_HUDFadeSceneFragment:New(DeathCounterFrame)
end

function DC.GroupMemberRoleChanged( eventCode, unitTag, newRole )
	local playerName = GetUnitDisplayName(unitTag)
	if (DC.units[playerName]) then
		DC.panels[DC.units[playerName].panelId].role:SetTexture(DC.roleIcons[newRole])
	end
end

function DC.GroupSupportRangeUpdate( eventCode, unitTag, status )
	local playerName = GetUnitDisplayName(unitTag)
	if (DC.units[playerName]) then
		DC.UpdateRange(DC.units[playerName].panelId, status)
	end
end

function DC.HasAnyDeaths(units)
    for _, unit in pairs(units) do
        if unit.deaths > 0 then
            return true
        end
    end
    return false
end

function DC.ShowContextMenu(panel)
	if LCM == nil then return end
	
	ClearMenu()

	AddCustomMenuItem("Top 3 Deaths (Session)", DC.PrintTop3SessionDeaths)
	
	AddCustomMenuItem("Top 3 Deaths (Current)", DC.PrintTop3Deaths)
	
	AddCustomMenuItem("Refresh", DC.Reset)

	AddCustomMenuItem("Reset Counter", function()
		DC.units = { }
		DC.Reset()
	end)

	AddCustomMenuItem("Cancel", function()
	end)
	
	ShowMenu(panel)
end

function DC.PrintTop3Deaths()
	local sorted = {}
	local groupSize = GetGroupSize()
		for i = 1, GROUP_SIZE_MAX do
		local soloPanel = i == 1 and groupSize == 0
		if (i <= groupSize or soloPanel) then
			local unitTag = (soloPanel) and playerTag or GetGroupUnitTagByIndex(i)
			if unitTag ~= nil then
				local playerName = GetUnitDisplayName(unitTag)
				if DC.units[playerName] then
					table.insert(sorted, {
						name = playerName,
						deaths = DC.units[playerName].deaths,
					})
				end
			end
		end
	end
		if not DC.HasAnyDeaths(sorted) then
		StartChatInput("No deaths in current group!", CHAT_CHANNEL_GROUP)
		return
	end
		table.sort(sorted, function(a, b) return a.deaths > b.deaths end)
	local parts = {}
	for i = 1, math.min(3, #sorted) do
		if sorted[i].deaths > 0 then
			table.insert(parts, "[" .. sorted[i].name .. " → " .. sorted[i].deaths .. "]")
		end
	end
		local message = "Top 3 Death Count:  " .. table.concat(parts, " , ")
	StartChatInput(message, CHAT_CHANNEL_GROUP)
end

function DC.PrintTop3SessionDeaths()
	local sorted = {}
	for playerName, unit in pairs(DC.units) do
		table.insert(sorted, {
			name = playerName,
			deaths = unit.deaths,
		})
	end
	if not DC.HasAnyDeaths(sorted) then
		StartChatInput("No deaths this session!", CHAT_CHANNEL_GROUP)
		return
	end

	table.sort(sorted, function(a, b) return a.deaths > b.deaths end)
	local parts = {}
	for i = 1, math.min(3, #sorted) do
		if sorted[i].deaths > 0 then
			table.insert(parts, "[" .. sorted[i].name .. " → " .. sorted[i].deaths .. "]")
		end
	end
	local message = "Session Top 3 Death Count:  " .. table.concat(parts, " , ")
	StartChatInput(message, CHAT_CHANNEL_GROUP)
end

function DC.UpdateRange( panelId, status )
	if (status) then
		DC.panels[panelId].panel:SetAlpha(1)
	else
		DC.panels[panelId].panel:SetAlpha(0.5)
	end
end

function DC.UnitDeath( eventCode, unitTag, isDead )
	if not unitTag or unitTag == "" then
        if isDead and IsUnitDead(playerTag) then
            unitTag = playerTag
        end
    end
	
    local playerName = GetUnitDisplayName(unitTag)
	
    if not DC.units[playerName] then return end
	
    if isDead then
        if not DC.units[playerName].isDead then
            DC.units[playerName].isDead = true
            DC.units[playerName].deaths = DC.units[playerName].deaths + 1
            DC.panels[DC.units[playerName].panelId].deaths:SetText(tostring(DC.units[playerName].deaths))
			DC.panels[DC.units[playerName].panelId].name:SetText("|cFF6666" .. playerName .. "|r")
			DC.CheckWayshrineRevive(playerName, unitTag)
        end
    else
        DC.units[playerName].isDead = false
		DC.panels[DC.units[playerName].panelId].name:SetText(playerName)
    end
end

function DC.CheckWayshrineRevive(playerName, unitTag)
    zo_callLater(function()
        if DC.units[playerName] and DC.units[playerName].isDead then
            if not IsUnitDead(unitTag) then
                DC.units[playerName].isDead = false
				DC.panels[DC.units[playerName].panelId].name:SetText(playerName)
				DC.Reset()
            else
                DC.CheckWayshrineRevive(playerName, unitTag)
            end
        end
    end, 2000)
end

function DC.CreateSettingsMenu()
	if LAM2 == nil then return end
	
	local colorCyan    = "|c42cbf4"

	local panelData = {
		type = "panel",
		name = "Death Counter",
		displayName = colorCyan.."Death Counter",
		author = "@Fluffiels",
		version = AddonVersion,
		slashCommand = "/deathcounter",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("DeathCounter_Options", panelData)

	local optionsData = {
		{
			type = "description",
			text = "This addon will count the number of deaths in your group.",
		},
		{
			type = "header",
			name = "General Settings",
		},
		{
			type = "checkbox",
			name = "Enable Addon",
			tooltip = "Enable or disable the Addon.",
			default = true,
			getFunc = function() return DC.vars.enabled end,
			setFunc = function(value)
				DC.vars.enabled = value
				DC.CheckActivation()
				DC.Reset()
			end,
		},
		{
			type = "description",
			text = "You can right click the table to show options to print in chat or reset counter.",
		},	
		{
			type = "checkbox",
			name = "Lock UI",
			tooltip = "Prevents moving the UI by accident.",
			default = false,
			getFunc = function() return DC.vars.lockUI end,
			setFunc = function(value)
				DC.vars.lockUI = value
				DeathCounterFrame:SetMovable(not value)
			end,
		},
		{
			type = "divider",
		},
		{
			type = "checkbox",
			name = "Keep Active",
			tooltip = "Keep the Addon active.",
			default = false,
			getFunc = function() return DC.vars.keepActive end,
			setFunc = function(value)
				DC.vars.keepActive = value
				DC.CheckActivation()
				DC.Reset()
			end,
		},
		{
			type = "description",
			text = "Keep the Addon active even if you're not in a group.",
		},
		{
            type = "checkbox",
            name = "Reset counter in new group",
            tooltip = "If the player was not in a group, it would reset the counter when joining a new one.",
            default = false,
            getFunc = function() return DC.vars.newGroupReset end,
            setFunc = function(value)
                DC.vars.newGroupReset = value
            end,
			disabled = function() return not DC.vars.keepActive end,
        },
	}

	LAM2:RegisterOptionControls("DeathCounter_Options", optionsData)
end

EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, DC.OnAddOnLoaded)
