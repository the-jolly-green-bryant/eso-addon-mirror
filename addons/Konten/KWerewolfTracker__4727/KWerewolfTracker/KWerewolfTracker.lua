-- KWerewolfTracker.lua

local ADDON = "KWerewolfTracker"
local KWerewolfTracker = {}
local SF = KWerewolfTracker
local FURY_ID = 999001
local GROUP_FRENZY_ID = 131353
local GROUP_FRENZY_DURATION = 30
local GROUP_ROW_HEIGHT = 20
SF.fury = 0

SF.groupPanel = nil
SF.groupRows = {}
SF.groupRoster = {}
SF.groupBuffEnd = {}

SF.TRACKED = {
    [267744] = { name = "Blood Hunger",		tooltip = "Each stack of Blood Hunger empowers Gnash and Claw Fury. Maximum: 4 stacks." },
    [131353] = { name = "Feeding Frenzy",	tooltip = "Grants +6% damage and Minor Force for 30 seconds." },
	[109966] = { name = "Major Courage",	tooltip = "Increases Weapon Damage and Spell Damage by 430." },
	[61746]  = { name = "Minor Force",		tooltip = "Increases Critical Damage by 10%." },
	[FURY_ID] = { name = "Werewolf Fury", tooltip = "Shows your current Werewolf Fury amount." },
}

SF.sv = nil
SF.iconSize = 50
SF.panels = {}
SF.active = {}
SF.endTimes = {}
SF.sceneHooked = false

local currentStacks = {}

function SF.CreatePanel(abilityId)
    if SF.panels[abilityId] then return SF.panels[abilityId] end
    if not SF.sv then return end

    local size = SF.iconSize
    local pos = SF.sv.positions[abilityId] or { x = 300, y = 300 }
    local panel = WINDOW_MANAGER:CreateTopLevelWindow("KWerewolfTrackerPanel_" .. abilityId)

    panel:SetDimensions(size, size)
    panel:SetMovable(true)
    panel:SetMouseEnabled(true)
    panel:SetClampedToScreen(true)
    panel:ClearAnchors()
    panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, pos.x, pos.y)
	panel:SetMovable(not SF.sv.locked[abilityId])

    panel.bg = WINDOW_MANAGER:CreateControl(nil, panel, CT_BACKDROP)
    panel.bg:SetAnchorFill(panel)
    panel.bg:SetCenterColor(0, 0, 0, 0.5)
    panel.bg:SetEdgeTexture(nil, 2, 2, 2, 2)
    panel.bg:SetEdgeColor(0, 1, 0, 1)

    panel.icon = WINDOW_MANAGER:CreateControl(nil, panel, CT_TEXTURE)
    panel.icon:SetAnchor(CENTER, panel, CENTER)
    panel.icon:SetDimensions(size - 8, size - 8)
    if abilityId == FURY_ID then
		panel.icon:SetTexture(GetAbilityIcon(32455))
	else
		panel.icon:SetTexture(GetAbilityIcon(abilityId))
	end
	panel.icon:SetColor(0.5, 0.5, 0.5, 0.5)

    panel.timer = WINDOW_MANAGER:CreateControl(nil, panel, CT_LABEL)
    panel.timer:SetAnchor(CENTER, panel, CENTER)
    panel.timer:SetFont("ZoFontWinH2")
    panel.timer:SetText("")

    panel.stacks = WINDOW_MANAGER:CreateControl(nil, panel, CT_LABEL)
    panel.stacks:SetAnchor(RIGHT, panel, LEFT, -10, 0)
    panel.stacks:SetFont("ZoFontWinH2")
    panel.stacks:SetColor(0, 1, 0, 1)
    panel.stacks:SetText("")
	panel.stacks:SetHidden(true)
	
    panel:SetHandler("OnMoveStop", function(self)
        local x = zo_round(self:GetLeft())
        local y = zo_round(self:GetTop())
        SF.sv.positions[abilityId] = { x = x, y = y }
    end)
	
	panel:SetHandler("OnMouseUp", function(self, button, upInside)
		if button ~= MOUSE_BUTTON_INDEX_RIGHT or not upInside then return end

		ClearMenu()

		AddMenuItem(SF.sv.locked[abilityId] and "Unlock" or "Lock", function()
			SF.sv.locked[abilityId] = not SF.sv.locked[abilityId]
			self:SetMovable(not SF.sv.locked[abilityId])
		end)

		if not SF.sv.locked[abilityId] then
			AddMenuItem("Reset Position", function()
				SF.sv.positions[abilityId] = { x = 0, y = 0 }
				self:ClearAnchors()
				self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, 0)
			end)
		end

		ShowMenu(self)
	end)
	
	panel:SetHandler("OnMouseEnter", function(self)
		InitializeTooltip(InformationTooltip, self, TOP, 0, 5)

		local data = SF.TRACKED[abilityId]

		SetTooltipText(
			InformationTooltip,
			string.format("|cFFFFFF%s|r\n%s",
				data.name,
				data.tooltip or "No description."
			)
		)
	end)

	panel:SetHandler("OnMouseExit", function()
		ClearTooltip(InformationTooltip)
	end)

    SF.panels[abilityId] = panel
    return panel
end

function SF.ShowPanel(abilityId)
    local panel = SF.panels[abilityId]
    if panel then panel:SetHidden(false) end
end

function SF.HidePanel(abilityId)
    local panel = SF.panels[abilityId]
    if panel then panel:SetHidden(true) end
end

function SF.RestorePanels()
    for abilityId in pairs(SF.TRACKED) do
        local panel = SF.panels[abilityId]
        local pos = SF.sv.positions[abilityId]
        if panel and pos then
            panel:ClearAnchors()
            panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, pos.x, pos.y)
			panel:SetMovable(not SF.sv.locked[abilityId])
        end
        if SF.sv.enabled[abilityId] then
            SF.ShowPanel(abilityId)
        else
            SF.HidePanel(abilityId)
        end
    end
end

function SF.CreateGroupRow(index)
    if SF.groupRows[index] then return SF.groupRows[index] end
    local panel = SF.groupPanel
    if not panel then return end

    local row = WINDOW_MANAGER:CreateControl(nil, panel, CT_BACKDROP)
    row:SetDimensions(SF.sv.groupPanel.width, GROUP_ROW_HEIGHT)
    row:ClearAnchors()
    row:SetAnchor(TOPLEFT, panel, TOPLEFT, 0, (index - 1) * GROUP_ROW_HEIGHT)
    row:SetEdgeTexture(nil, 1, 1, 1, 1)
    row:SetEdgeColor(0, 0, 0, 1)
    row:SetCenterColor(0.1, 0.1, 0.1, 0.6)

    row.fill = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
    row.fill:SetEdgeTexture(nil, 1, 1, 1, 1)
    row.fill:SetEdgeColor(0, 0, 0, 0)
    row.fill:SetCenterColor(0, 0.6, 0, 0.75)
    row.fill:ClearAnchors()
    row.fill:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
    row.fill:SetDimensions(0, GROUP_ROW_HEIGHT)
    row.fill:SetHidden(true)

    row.icon = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
    row.icon:SetDimensions(GROUP_ROW_HEIGHT - 4, GROUP_ROW_HEIGHT - 4)
    row.icon:SetAnchor(LEFT, row, LEFT, 2, 0)
    row.icon:SetTexture(GetAbilityIcon(GROUP_FRENZY_ID))
    row.icon:SetColor(0.5, 0.5, 0.5, 0.5)

    row.name = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    row.name:SetFont("ZoFontWinT1")
    row.name:SetAnchor(LEFT, row.icon, RIGHT, 4, 0)
    row.name:SetColor(1, 1, 1, 1)
    row.name:SetText("")

    row.timer = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    row.timer:SetFont("ZoFontWinT1")
    row.timer:SetAnchor(RIGHT, row, RIGHT, -4, 0)
    row.timer:SetColor(1, 1, 1, 1)
    row.timer:SetText("0s")

    SF.groupRows[index] = row
    return row
end

function SF.LayoutGroupPanel()
    if not SF.groupPanel then return end

    local count = #SF.groupRoster
    local rowCount = count
    for i in pairs(SF.groupRows) do
        if i > rowCount then rowCount = i end
    end

    SF.groupPanel:SetDimensions(SF.sv.groupPanel.width, math.max(count, 1) * GROUP_ROW_HEIGHT)

    for i = 1, math.max(rowCount, count) do
        local row = SF.CreateGroupRow(i)
        if row then
            if i <= count then
                row:SetHidden(false)
                row.name:SetText(SF.groupRoster[i].key)
            else
                row:SetHidden(true)
            end
        end
    end
end

function SF.RefreshGroupRoster()
    SF.groupRoster = {}

    local function AddMember(unitTag)
        if not DoesUnitExist(unitTag) then return end
        local displayName = GetUnitDisplayName(unitTag)
        local charName = zo_strformat("<<1>>", GetUnitName(unitTag))
        if displayName == "" then displayName = charName end
        table.insert(SF.groupRoster, { key = displayName, name = charName })
    end

    if IsUnitGrouped("player") then
        for i = 1, GetGroupSize() do
            AddMember(GetGroupUnitTagByIndex(i))
        end
    else
        AddMember("player")
    end

    SF.LayoutGroupPanel()
end

function SF.CreateGroupPanel()
    if SF.groupPanel then return SF.groupPanel end
    if not SF.sv then return end

    local gp = SF.sv.groupPanel
    local panel = WINDOW_MANAGER:CreateTopLevelWindow("KWerewolfTrackerGroupPanel")

    panel:SetDimensions(gp.width, GROUP_ROW_HEIGHT)
    panel:SetMovable(not gp.locked)
    panel:SetMouseEnabled(true)
    panel:SetClampedToScreen(true)
    panel:ClearAnchors()
    panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, gp.x, gp.y)

    panel:SetHandler("OnMoveStop", function(self)
        SF.sv.groupPanel.x = zo_round(self:GetLeft())
        SF.sv.groupPanel.y = zo_round(self:GetTop())
    end)

    panel:SetHandler("OnMouseUp", function(self, button, upInside)
        if button ~= MOUSE_BUTTON_INDEX_RIGHT or not upInside then return end

        ClearMenu()

        AddMenuItem(SF.sv.groupPanel.locked and "Unlock" or "Lock", function()
            SF.sv.groupPanel.locked = not SF.sv.groupPanel.locked
            self:SetMovable(not SF.sv.groupPanel.locked)
        end)

        if not SF.sv.groupPanel.locked then
            AddMenuItem("Reset Position", function()
                SF.sv.groupPanel.x = 300
                SF.sv.groupPanel.y = 300
                self:ClearAnchors()
                self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 300, 300)
            end)
        end

        ShowMenu(self)
    end)

    SF.groupPanel = panel
    panel:SetHidden(not gp.enabled)
    return panel
end

function SF.UpdateGroupPanel()
    if not SF.sv.groupPanel.enabled or not SF.groupPanel then return end

    local now = GetFrameTimeSeconds()
    for i, member in ipairs(SF.groupRoster) do
        local row = SF.groupRows[i]
        if row then
            local endTime = SF.groupBuffEnd[member.key] or 0
            local remaining = endTime > now and (endTime - now) or 0

            if remaining > 0 then
                local fraction = remaining / GROUP_FRENZY_DURATION
                if fraction > 1 then fraction = 1 end
                if fraction < 0 then fraction = 0 end

                local r, g, b = 0, 0.6, 0
                local nameHidden = false

                if remaining <= 5 then
                    r, g, b = 0.8, 0, 0
                    nameHidden = (math.floor(now * 4) % 2 == 1)
                elseif remaining <= 10 then
                    r, g, b = 0.8, 0.8, 0
                    nameHidden = (math.floor(now * 2) % 2 == 1)
                end

                row.timer:SetText(string.format("%.1fs", remaining))
                row.fill:SetHidden(false)
                row.fill:SetWidth(SF.sv.groupPanel.width * fraction)
                row.fill:SetCenterColor(r, g, b, 0.75)
                row.icon:SetColor(1, 1, 1, 1)
                row.name:SetHidden(nameHidden)
            else
                row.timer:SetText("0s")
                row.fill:SetHidden(true)
                row.fill:SetWidth(0)
                row.icon:SetColor(0.5, 0.5, 0.5, 0.5)
                row.name:SetHidden(false)
            end
        end
    end
end

local function OnGroupFrenzyEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag,
    beginTime, endTimeParam, stackCount, iconNameParam, buffType, effectType,
    abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)

    if not SF.sv.groupPanel.enabled then return end
    if unitTag ~= "player" and not IsUnitGrouped(unitTag) then return end

    local displayName = GetUnitDisplayName(unitTag)
    if displayName == "" then displayName = zo_strformat("<<1>>", GetUnitName(unitTag)) end

    if changeType == EFFECT_RESULT_FADED then
        SF.groupBuffEnd[displayName] = 0
        return
    end

    SF.groupBuffEnd[displayName] = endTimeParam or 0
end

local function RegisterGroupFrenzyTracking()
    EVENT_MANAGER:RegisterForEvent(ADDON .. "_GroupFrenzy", EVENT_EFFECT_CHANGED, OnGroupFrenzyEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(ADDON .. "_GroupFrenzy", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, GROUP_FRENZY_ID)

    EVENT_MANAGER:RegisterForEvent(ADDON .. "_GroupUpdate", EVENT_GROUP_UPDATE, function() SF.RefreshGroupRoster() end)
    EVENT_MANAGER:RegisterForEvent(ADDON .. "_GroupJoined", EVENT_GROUP_MEMBER_JOINED, function() SF.RefreshGroupRoster() end)
    EVENT_MANAGER:RegisterForEvent(ADDON .. "_GroupLeft", EVENT_GROUP_MEMBER_LEFT, function() SF.RefreshGroupRoster() end)
end

local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag,
    beginTime, endTimeParam, stackCount, iconNameParam, buffType, effectType,
    abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)

    if SF.sv.debug then
        local previous = currentStacks[abilityId] or 0
        local duration = endTimeParam > 0 and (endTimeParam - beginTime) or 0

        if changeType == EFFECT_RESULT_GAINED then
            d(string.format("|c00FF00[GAINED]|r %s | Stacks: %d | AbilityID: %d | Duration: %.1f sec", effectName, stackCount, abilityId, duration))
        elseif changeType == EFFECT_RESULT_UPDATED then
            if stackCount ~= previous then
                local diff = stackCount - previous
                local direction = diff > 0 and "GAINED" or "LOST"
                d(string.format("|cFFFF00[%s]|r %s | Stacks: %d | AbilityID: %d | Duration: %.1f sec", direction, effectName, stackCount, abilityId, duration))
            end

        elseif changeType == EFFECT_RESULT_FADED then
            d(string.format(
                "|cFF0000[FADED]|r %s | Stacks: 0 | AbilityID: %d",
                effectName, abilityId
            ))
        end
    end
	if changeType == EFFECT_RESULT_FADED then
		currentStacks[abilityId] = 0

		local panel = SF.panels[abilityId]
		if panel then panel.stacks:SetHidden(true) end
		return
	end
	
    if not SF.sv.enabled[abilityId] then return end

    local panel = SF.CreatePanel(abilityId)

    SF.active[abilityId] = abilityId
	if endTimeParam and endTimeParam > 0 then
		SF.endTimes[abilityId] = endTimeParam
	end

    currentStacks[abilityId] = stackCount
	if stackCount > 0 then
		panel.stacks:SetHidden(false)
		panel.stacks:SetText(tostring(stackCount))
	else
		panel.stacks:SetHidden(true)
	end
end

function SF.UpdatePanel(abilityId)
    local panel = SF.panels[abilityId]
    if not panel then return end
	
	if abilityId == FURY_ID then
		panel.timer:SetText("")
		panel.stacks:SetHidden(false)
		panel.stacks:SetText(tostring(SF.fury))
		return
	end

    local activeAbility = SF.active[abilityId]
    local endTime = SF.endTimes[abilityId] or 0

    if not activeAbility then
        panel.timer:SetText("")
		panel.bg:SetEdgeColor(0, 0, 0, 1)
		panel.stacks:SetHidden(true)
        return
    end

    local remaining = endTime > 0 and (endTime - GetFrameTimeSeconds()) or 0

    if remaining <= 0 then
        SF.active[abilityId] = nil
        panel.timer:SetText("")
        panel.stacks:SetHidden(true)
		panel.bg:SetEdgeColor(0, 0, 0, 1)
		panel.icon:SetColor(0.5, 0.5, 0.5, 0.5)
        return
    end
	
	local stacks = currentStacks[abilityId] or 0
	if stacks > 0 then
		panel.stacks:SetHidden(false)
		panel.stacks:SetText(tostring(stacks))
	else
		panel.stacks:SetHidden(true)
	end
	
	panel.icon:SetColor(1, 1, 1, 1)
	panel.bg:SetEdgeColor(0, 1, 0, 1)
    panel.timer:SetText(string.format("%.1f", remaining))
end

local function UpdateAllPanels()
    for abilityId in pairs(SF.TRACKED) do
        SF.UpdatePanel(abilityId)
    end
    SF.UpdateGroupPanel()
end

function SF.CreateMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "KWerewolfTracker",
        displayName = "KWerewolfTracker",
        author = "|cFF9B15@Zaan's|r",
        version = "1.6.0",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local options = {
        { type = "header", name = "Tracked Skills" },
    }
	
	table.insert(options, {
		type = "slider",
		name = "Icon Size",
		tooltip = "Adjust the size of all icons.",
		min = 20,
		max = 100,
		step = 1,

		getFunc = function()
			return SF.sv.iconSize
		end,

		setFunc = function(value)
			SF.sv.iconSize = value
			SF.iconSize = value
			for abilityId, panel in pairs(SF.panels) do
				panel:SetDimensions(value, value)
				panel.icon:SetDimensions(value - 8, value - 8)
			end
		end,

		width = "full",
	})


    for abilityId, data in pairs(SF.TRACKED) do
        table.insert(options,{
            type = "checkbox",
            name = data.name,
            tooltip = data.tooltip or "Show/Hide panel for this skill",

            getFunc = function()
                return SF.sv.enabled[abilityId]
            end,

            setFunc = function(value)
                SF.sv.enabled[abilityId] = value

                if value then
                    SF.ShowPanel(abilityId)
                else
                    SF.HidePanel(abilityId)
                end
            end,

            width = "full",
        })
    end

    table.insert(options, { type = "header", name = "Group Panel" })

    table.insert(options, {
        type = "checkbox",
        name = "Group Feeding Frenzy Panel",
        tooltip = "Shows a panel listing every group member and their remaining Feeding Frenzy synergy duration.",

        getFunc = function()
            return SF.sv.groupPanel.enabled
        end,

        setFunc = function(value)
            SF.sv.groupPanel.enabled = value

            if not SF.groupPanel then
                SF.CreateGroupPanel()
            end

            if SF.groupPanel then
                SF.groupPanel:SetHidden(not value)
            end

            if value then
                SF.RefreshGroupRoster()
            end
        end,

        width = "full",
    })

    table.insert(options, {
        type = "slider",
        name = "Group Panel Width",
        tooltip = "Adjust the width of the group Feeding Frenzy panel.",
        min = 100,
        max = 400,
        step = 10,

        getFunc = function()
            return SF.sv.groupPanel.width
        end,

        setFunc = function(value)
            SF.sv.groupPanel.width = value

            if SF.groupPanel then
                SF.groupPanel:SetWidth(value)
                for _, row in pairs(SF.groupRows) do
                    row:SetWidth(value)
                    row.fill:SetWidth(0)
                    row.fill:SetHidden(true)
                end
            end
        end,

        width = "full",
    })

    LAM:RegisterAddonPanel("KWerewolfTrackerOptions", panelData)
    LAM:RegisterOptionControls("KWerewolfTrackerOptions", options)
end

function SF.InitializeSavedVars()
    SF.sv.enabled = SF.sv.enabled or {}
    SF.sv.positions = SF.sv.positions or {}
	SF.sv.locked = SF.sv.locked or {}
	SF.sv.iconSize = SF.sv.iconSize or 50
	SF.iconSize = SF.sv.iconSize

	SF.sv.groupPanel = SF.sv.groupPanel or {}
	if SF.sv.groupPanel.enabled == nil then SF.sv.groupPanel.enabled = false end
	if SF.sv.groupPanel.locked == nil then SF.sv.groupPanel.locked = false end
	SF.sv.groupPanel.x = SF.sv.groupPanel.x or 300
	SF.sv.groupPanel.y = SF.sv.groupPanel.y or 300
	SF.sv.groupPanel.width = SF.sv.groupPanel.width or 180

    for abilityId in pairs(SF.TRACKED) do
		if SF.sv.enabled[abilityId] == nil then SF.sv.enabled[abilityId] = false end
		if SF.sv.locked[abilityId] == nil then SF.sv.locked[abilityId] = false end

		if SF.sv.positions[abilityId] == nil then
			SF.sv.positions[abilityId] = {
				x = 300,
				y = 300
			}
		end
	end
end

local function HookSceneVisibility()
    if SF.sceneHooked then return end
    SF.sceneHooked = true

    SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, _, state)
        if state ~= SCENE_SHOWING then return end

        local visible = scene:GetName() == "hud" or scene:GetName() == "hudui"

        for abilityId, panel in pairs(SF.panels) do
            if SF.sv.enabled[abilityId] then
                panel:SetHidden(not visible)
            end
        end

        if SF.groupPanel and SF.sv.groupPanel.enabled then
            SF.groupPanel:SetHidden(not visible)
        end
    end)
end

function SF.UpdateFury(current, max)
    if current == nil then
        current, max = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_WEREWOLF)
    end
    SF.fury = current

    SF.active[FURY_ID] = FURY_ID

    local panel = SF.panels[FURY_ID]
    if not panel then return end

    panel:SetDimensions(SF.iconSize, SF.iconSize)
    panel.icon:SetDimensions(SF.iconSize - 8, SF.iconSize - 8)

    panel.stacks:SetHidden(false)
    panel.stacks:SetText(tostring(current))

    if current < 1000 then
        panel.icon:SetTexture(GetAbilityIcon(32455))
    else
        panel.icon:SetTexture(GetAbilityIcon(267416))
    end

    if current > 0 then
        panel.icon:SetColor(1, 1, 1, 1)
        panel.bg:SetEdgeColor(1, 0.4, 0, 1)
    else
        panel.icon:SetColor(0.5, 0.5, 0.5, 0.5)
        panel.bg:SetEdgeColor(0, 0, 0, 1)
    end
end

local function RegisterSlashCommands()
	SLASH_COMMANDS["/sfdebug"] = function(arg)
		SF.sv.debug = (string.lower(arg or "") == "on")
		d(SF.sv.debug and "|c00FF00KWerewolfTracker Debug ENABLED|r" or "|cFF0000KWerewolfTracker Debug DISABLED|r")
	end

	SLASH_COMMANDS["/sfreset"] = function()
		for abilityId in pairs(SF.TRACKED) do
			SF.sv.positions[abilityId] = { x = 300, y = 300 }
			local panel = SF.panels[abilityId]
			if panel then
				panel:ClearAnchors()
				panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 300, 300)
			end
		end
		d("|c00FF00KWerewolfTracker|r Panel positions reset.")
	end
end

local function OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	SF.UpdateFury(powerValue, powerMax)
end

local function RegisterFuryTracking()
	EVENT_MANAGER:RegisterForEvent(ADDON .. "_Fury", EVENT_POWER_UPDATE, OnPowerUpdate)
	EVENT_MANAGER:AddFilterForEvent(ADDON .. "_Fury", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player", REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_WEREWOLF)
	SF.UpdateFury()
end

local function RegisterEffectChangedFilters()
	for abilityId in pairs(SF.TRACKED) do
		if abilityId ~= FURY_ID then
			local namespace = ADDON .. "_Effect" .. abilityId
			EVENT_MANAGER:RegisterForEvent(namespace, EVENT_EFFECT_CHANGED, OnEffectChanged)
			EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player", REGISTER_FILTER_ABILITY_ID, abilityId)
		end
	end
end

local function OnPlayerActivated(eventCode)
	EVENT_MANAGER:UnregisterForEvent(ADDON .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED)
	SF.RestorePanels()
	SF.RefreshGroupRoster()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON, EVENT_ADD_ON_LOADED)

    SF.sv = ZO_SavedVars:NewCharacterIdSettings("KWerewolfTrackerSaved", 1, "settings", {
        enabled = {},
        debug = false,
        positions = {},
		locked = {},
    })

    SF.InitializeSavedVars()
    SF.CreateMenu()

    for abilityId in pairs(SF.TRACKED) do
        SF.CreatePanel(abilityId)
    end

	SF.CreateGroupPanel()
	
	HookSceneVisibility()
    EVENT_MANAGER:RegisterForEvent(ADDON .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    RegisterEffectChangedFilters()
    RegisterFuryTracking()
    RegisterGroupFrenzyTracking()
    RegisterSlashCommands()

    EVENT_MANAGER:RegisterForUpdate(ADDON .. "_Update", 50, UpdateAllPanels, false)
end

EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
