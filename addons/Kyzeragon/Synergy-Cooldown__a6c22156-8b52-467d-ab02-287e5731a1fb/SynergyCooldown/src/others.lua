local SynCool = SynergyCooldown

-- unitId to unitTag, when to clear this? on player activated?
local groupMembers = {}

local useWatch = false
local watched = {}

local isPolling = false

-- Currently used controls for notifications: {[1] = {name = name, expireTime = 123456132}}
local freeControls = {}

-------------------------------------------------------------------------------
-- Reset the unitId:unitTag cache
function SynCool.ClearCache()
    -- SynCool.dbg("Clearing group member cache")
    groupMembers = {}
end

-------------------------------------------------------------------------------
-- Watch only certain names
function SynCool.Watch(names)
    if (names == nil or names == "") then
        useWatch = false
        watched = {}
        SynCool.dbg("Cleared and turned off individual player filter")
        return
    end

    useWatch = true
    for name in names:gmatch("%S+") do
        watched[name] = true
    end
    SynCool.dbg("Watching" .. names)
end

-------------------------------------------------------------------------------
-- Reanchor all controls, used when growth direction changes
function SynCool.ReAnchorOthers()
    for i, data in pairs(freeControls) do
        local lineControl = SynCoolOthers:GetNamedChild("Line" .. tostring(i))

        if (SynCool.savedOptions.othersDisplay.growth == "up") then
            lineControl:SetAnchor(CENTER, SynCoolOthers, CENTER, 0, -44 * (i - 1))
        elseif (SynCool.savedOptions.othersDisplay.growth == "down") then
            lineControl:SetAnchor(CENTER, SynCoolOthers, CENTER, 0, 44 * (i - 1))
        end
    end
end

-------------------------------------------------------------------------------
-- Polling to update display
local function UpdateDisplay()
    local currTime = GetGameTimeMilliseconds()
    local numActive = 0
    local numRemoved = 0
    for i, data in pairs(freeControls) do
        if (data and data.expireTime) then
            local millisRemaining = (data.expireTime - currTime)
            local lineControl = SynCoolOthers:GetNamedChild("Line" .. tostring(i))
            if (millisRemaining < 0) then
                -- Hide
                lineControl:SetHidden(true)
                freeControls[i] = false
                numRemoved = numRemoved + 1
            else
                numActive = numActive + 1
                lineControl:GetNamedChild("Timer"):SetText(string.format("%.1f", millisRemaining / 1000))
                lineControl:GetNamedChild("Bar"):SetValue(millisRemaining)
            end
        end
    end

    -- If any were removed, the others must be shifted forward
    -- Probably more efficient way to reassign them but I'm unclear on how to not get mem leaks atm...
    if (numRemoved > 0) then
        for i = 1, numActive do
            -- Transfer the +numRemoved to the current
            freeControls[i] = freeControls[i + numRemoved]
            freeControls[i + numRemoved] = false

            local newControl = SynCoolOthers:GetNamedChild("Line" .. tostring(i))
            local origControl = SynCoolOthers:GetNamedChild("Line" .. tostring(i + numRemoved))
            newControl:GetNamedChild("Icon"):SetTexture(origControl:GetNamedChild("Icon"):GetTextureFileName())
            newControl:GetNamedChild("Label"):SetText(origControl:GetNamedChild("Label"):GetText())
            newControl:GetNamedChild("Timer"):SetText(origControl:GetNamedChild("Timer"):GetText())
            local min, max = origControl:GetNamedChild("Bar"):GetMinMax()
            newControl:GetNamedChild("Bar"):SetMinMax(min, max)
            newControl:GetNamedChild("Bar"):SetValue(origControl:GetNamedChild("Bar"):GetValue())
            newControl:SetHidden(false)
            local barHidden = not SynCool.savedOptions.othersDisplay.showBar
            newControl:GetNamedChild("Label"):SetHidden(barHidden)
            newControl:GetNamedChild("Bar"):SetHidden(barHidden)
            origControl:SetHidden(true)
        end
    end

    -- Stop polling
    if (numActive == 0) then
        EVENT_MANAGER:UnregisterForUpdate(SynCool.name .. "PollOthers")
        isPolling = false
    end
end


-------------------------------------------------------------------------------
-- Find a free control to use
local function FindOrCreateControl(name)
    -- Do a first pass to check if there's already one being displayed for this name
    -- for i, data in pairs(freeControls) do
    --     if (data and data.name == name) then
    --         return i
    --     end
    -- end

    -- No existing one of the same name
    for i, data in pairs(freeControls) do
        if (data == false) then
            return i
        end
    end

    -- Else, make a new control
    local index = #freeControls + 1
    local lineControl = CreateControlFromVirtual(
        "$(parent)Line" .. tostring(index),     -- name
        SynCoolOthers,                          -- parent
        "SynCool_Line_Template",                -- template
        "")                                     -- suffix
    lineControl:GetNamedChild("Label"):SetFont(SynCool.GetStyles().labelFont)
    lineControl:GetNamedChild("Timer"):SetFont(SynCool.GetStyles().timerFont)

    if (SynCool.savedOptions.othersDisplay.growth == "up") then
        lineControl:SetAnchor(CENTER, SynCoolOthers, CENTER, 0, -44 * (index - 1))
    else
        lineControl:SetAnchor(CENTER, SynCoolOthers, CENTER, 0, 44 * (index - 1))
    end

    return index
end


-------------------------------------------------------------------------------
local function ApplyStyles()
    local styles = SynCool.GetStyles()

    for i, _ in pairs(freeControls) do
        local lineControl = SynCoolOthers:GetNamedChild("Line" .. i)
        lineControl:GetNamedChild("Label"):SetFont(styles.labelFont)
        lineControl:GetNamedChild("Timer"):SetFont(styles.timerFont)
    end
end
SynCool.ApplyStylesOthers = ApplyStyles


-------------------------------------------------------------------------------
-- When a synergy is activated, add it to the display
local function OnSynergyActivated(name, target, unitTag, bypass)
    if (not SynCool.savedOptions.othersDisplay.enabled) then
        return
    end

    if (target == nil) then
        return
    end

    if (useWatch) then
        -- If we're using the custom watchlist, the name must be in this list
        if (not bypass and not watched[target]) then
            return
        end
    else
        -- If not using the custom watchlist...
        target = GetUnitDisplayName(unitTag)
        if (not bypass and target == GetUnitDisplayName("player")) then
            -- Must not be the current player
            return
        end
        local role = GetGroupMemberSelectedRole(unitTag);
        if (not bypass and role ~= LFG_ROLE_TANK) then
            -- Must be a tank
            return
        end
    end

    local data = SynCool.SYNERGIES[name]

    local index = FindOrCreateControl(name)
    freeControls[index] = {name = name, expireTime = GetGameTimeMilliseconds() + data.cooldown}

    local lineControl = SynCoolOthers:GetNamedChild("Line" .. tostring(index))
    lineControl:GetNamedChild("Icon"):SetTexture(SynCool.SYNERGIES[name].texture)
    lineControl:GetNamedChild("Label"):SetText(target)
    lineControl:GetNamedChild("Timer"):SetText(string.format("%.1f", data.cooldown / 1000))
    lineControl:GetNamedChild("Bar"):SetMinMax(0, data.cooldown)
    lineControl:GetNamedChild("Bar"):SetValue(data.cooldown)
    lineControl:SetHidden(false)
    local barHidden = not SynCool.savedOptions.othersDisplay.showBar
    lineControl:GetNamedChild("Label"):SetHidden(barHidden)
    lineControl:GetNamedChild("Bar"):SetHidden(barHidden)

    if (not isPolling) then
        EVENT_MANAGER:RegisterForUpdate(SynCool.name .. "PollOthers", 100, UpdateDisplay)
        isPolling = true
    end
end
SynCool.OnSynergyOthers = OnSynergyActivated


-------------------------------------------------------------------------------
-- When a synergy is activated, add it to the display
function SynCool:InitializeOthers()
    -- Register effect changed just to get unitId : unitTag mappings
    local function OnOthersEffectChanged(_, _, _, _, unitTag, _, _, _, _, _, _, _, _, _, unitId)
        groupMembers[unitId] = unitTag
    end
    EVENT_MANAGER:RegisterForEvent(SynCool.name .. "Others", EVENT_EFFECT_CHANGED, OnOthersEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(SynCool.name .. "Others", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

    -- Register each synergy
    for name, data in pairs(SynCool.SYNERGIES) do
        local function OnCombatOthersEvent(_, _, _, _, _, _, _, _, _, _, hitValue, _, _, _, _, targetUnitId)
            if (hitValue == 1) then
                OnSynergyActivated(name, GetUnitDisplayName(groupMembers[targetUnitId]), groupMembers[targetUnitId])
            end
        end

        for _, id in ipairs(data.ids) do
            -- Others
            EVENT_MANAGER:RegisterForEvent(SynCool.name .. "Others" .. tostring(id), EVENT_COMBAT_EVENT, OnCombatOthersEvent)
            EVENT_MANAGER:AddFilterForEvent(SynCool.name .. "Others" .. tostring(id), EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
            EVENT_MANAGER:AddFilterForEvent(SynCool.name .. "Others" .. tostring(id), EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, id)
        end
    end
end
