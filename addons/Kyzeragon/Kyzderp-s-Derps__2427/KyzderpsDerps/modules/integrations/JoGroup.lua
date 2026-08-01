KyzderpsDerps.JoGroup = {}
local JG = KyzderpsDerps.JoGroup

local lgcs
local ults = {}
JG.ults = ults
-- /script d(KyzderpsDerps.JoGroup.ults)

-- Whether UI has been refreshed after this player activation
-- Used to do 1 refresh upon receiving data after loadscreen
local refreshedThisActivation = false

-- Same as Hodor
local function GetPercentColor(percentValue)
    if (percentValue >= 100) then return "00FF00" end
    if (percentValue >= 80) then return "FFFF00" end
    return "FFFFFF"
end

-- Mostly copied from Hodor
local function GetUltPercentage(ultValue, ultCost)
    if (ultValue == nil or ultCost == nil) then
        return 200 -- Treat no ult as if it's full, because we want the min
    end

    if (ultValue <= ultCost) then
        return zo_floor((ultValue / ultCost) * 100)
    end

    return zo_clamp(100 + zo_floor(100 * (ultValue - ultCost) / (500 - ultCost)), 0, 200)
end

local function GetPlayerGroupTag()
    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        if (AreUnitsEqual(tag, "player")) then
            return tag
        end
    end
end

local function UpdateUI(unitTag)
    local frameControl = JoGroup.frame[unitTag]

    -- Could be "player" when called from certain places
    if (not frameControl) then
        frameControl = JoGroup.frame[GetPlayerGroupTag()]
    end

    if (not frameControl) then return end

    if (not frameControl.kddUlt) then
        frameControl.kddUlt = CreateControlFromVirtual(
            "$(parent)KDDUlt", -- name
            frameControl, -- parent
            "JoGroup_Ult_Template", -- template
            "") -- suffix
        frameControl.kddUlt:SetAnchor(RIGHT, frameControl.food, LEFT)
    end

    local data = ults[unitTag]
    -- Could be player too
    if (not data and AreUnitsEqual(unitTag, "player")) then
        data = ults["player"]
    end

    if (not data or (data.ult1ID == 0 and data.ult2ID == 0 and data.ultValue == 0) or not IsUnitOnline(unitTag)) then
        frameControl.kddUlt:SetHidden(true)
    else
        local ult1 = frameControl.kddUlt:GetNamedChild("Ult1")
        local ult2 = frameControl.kddUlt:GetNamedChild("Ult2")
        local percent = frameControl.kddUlt:GetNamedChild("Percent")
        ult1:SetTexture(GetAbilityIcon(data.ult1ID))
        ult2:SetTexture(GetAbilityIcon(data.ult2ID))

        local percent1 = GetUltPercentage(data.ultValue, data.ult1Cost)
        local percent2 = GetUltPercentage(data.ultValue, data.ult2Cost)
        local percentValue = math.min(percent1, percent2)
        percent:SetText(string.format("|c%s%d%%|r", GetPercentColor(percentValue), percentValue))
        percent:SetWidth(100)
        percent:SetWidth(percent:GetTextWidth())
        frameControl.kddUlt:SetHidden(false)
    end
end

local function UpdateWholeUI()
    for i = 1, MAX_GROUP_SIZE_THRESHOLD do
        UpdateUI("group" .. i)
    end
end

-- Used when turning off
local function HideAll()
    for i = 1, MAX_GROUP_SIZE_THRESHOLD do
        local frameControl = JoGroup.frame["group" .. i]
        if (frameControl and frameControl.kddUlt) then
            frameControl.kddUlt:SetHidden(true)
        end
    end
end

-- TODO: check cryptcanon

--[[
ultData = {
    ultValue = number, -- ultimate points ( 0-500 )
    ult1ID = number, -- frontbar ultimate skill ID
    ult2ID = number, -- backbar ultimate skill ID
    ult1Cost = number, -- frontbar ultimate cost
    ult2Cost = number, -- backbar ultimate cost
    ultActivatedSetId = number, -- the id of a set that is activated with an ultimate ( see LibGroupCombatStats.ULT_ACTIVATED_SETS_LIST )
    _lastUpdated = number, -- timestamp of last update
    _lastChanged = number, -- timestamp of last value change
}
]]
local function OnUltUpdated(unitTag, ultData, skipUpdate)
    -- Could be currently registered after changing setting within 1 reload
    if (not KyzderpsDerps.savedOptions.integrations.showUltOnJoGroup) then return end
    if (not ultData) then return end

    if (unitTag ~= "player" and not refreshedThisActivation) then
        refreshedThisActivation = true
        JG.RefreshAll()
    end

    local data = ults[unitTag] or {}
    data.ultValue = ultData.ultValue
    data.ult1ID = ultData.ult1ID
    data.ult1Cost = ultData.ult1Cost
    data.ult2ID = ultData.ult2ID
    data.ult2Cost = ultData.ult2Cost
    ults[unitTag] = data

    if (not skipUpdate) then
        UpdateUI(unitTag)
    end
end

local function RefreshAll()
    -- Only clear the inner table
    for i = 1, MAX_GROUP_SIZE_THRESHOLD do
        local tag = "group" .. i
        if (ults[tag]) then
            ZO_ClearTable(ults[tag])
        end
    end
    
    for unitTag, data in pairs(lgcs:GetGroupStats()) do
        OnUltUpdated(unitTag, data.ult, true)
    end

    UpdateWholeUI()
end
JG.RefreshAll = RefreshAll
-- /script KyzderpsDerps.JoGroup.RefreshAll()

local function RefreshAllTimeout()
    EVENT_MANAGER:RegisterForUpdate(KyzderpsDerps.name .. "JGRefreshTimeout", 100, function()
        EVENT_MANAGER:UnregisterForUpdate(KyzderpsDerps.name .. "JGRefreshTimeout")
        RefreshAll()
    end)
end

local lgcsInitialized = false
function JG.Initialize()
    if (not JoGroup or not LibGroupCombatStats or not KyzderpsDerps.savedOptions.integrations.showUltOnJoGroup) then return end -- TODO: setting

    if (not lgcsInitialized) then
        lgcs = LibGroupCombatStats.RegisterAddon("KyzderpsDerps", {"ULT"})
        lgcs:RegisterForEvent(LibGroupCombatStats.EVENT_GROUP_ULT_UPDATE, OnUltUpdated)
        lgcs:RegisterForEvent(LibGroupCombatStats.EVENT_PLAYER_ULT_UPDATE, OnUltUpdated)
        lgcsInitialized = true
    end

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "JGPlayerActivated", EVENT_PLAYER_ACTIVATED, function()
        refreshedThisActivation = false
        RefreshAllTimeout()
        zo_callLater(RefreshAllTimeout, 1500)
    end)
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "JGJoined", EVENT_GROUP_MEMBER_JOINED, RefreshAllTimeout)
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "JGLeft", EVENT_GROUP_MEMBER_LEFT, RefreshAllTimeout)
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "JGUpdate", EVENT_GROUP_UPDATE, RefreshAllTimeout)
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "JGRoleChanged", EVENT_GROUP_MEMBER_ROLE_CHANGED, RefreshAllTimeout)
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "JGConnectedStatus", EVENT_GROUP_MEMBER_CONNECTED_STATUS, RefreshAllTimeout)

    RefreshAll()

end

local function Uninitialize()
    EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "JGPlayerActivated", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "JGJoined", EVENT_GROUP_MEMBER_JOINED)
    EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "JGLeft", EVENT_GROUP_MEMBER_LEFT)
    EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "JGUpdate", EVENT_GROUP_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "JGRoleChanged", EVENT_GROUP_MEMBER_ROLE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "JGConnectedStatus", EVENT_GROUP_MEMBER_CONNECTED_STATUS)

    HideAll()
end


---------------------------------------------------------------------
-- Pocket healing
---------------------------------------------------------------------
local function StartsWith(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
end

local pockets = {}
function JG.Pocket(name)
    if (not CrutchAlerts or not CrutchAlerts.Drawing or not CrutchAlerts.Drawing.AttachControl) then
        KyzderpsDerps:msg("Requires CrutchAlerts v2.16.0+")
        return
    end
    if (not JoGroup) then
        KyzderpsDerps:msg("Requires JoGroup")
        return
    end

    if (not StartsWith(name, "@")) then
        name = "@" .. name
    end

    local unitTag
    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        if (IsUnitOnline(tag) and GetUnitDisplayName(tag) == name) then
            unitTag = tag
            break
        end
    end

    if (not unitTag) then
        KyzderpsDerps:msg("Couldn't find online group member " .. name)
        return
    end

    pockets[unitTag] = true
    CrutchAlerts.Drawing.AttachControl(JoGroup.frame[unitTag], unitTag, "KDDPocket" .. unitTag)

    JoGroup.savedVars.colours.customColour = true -- TODO: setting gradient colors is weird af when in space? zos bug?
end

function JG.ClearPockets()
    if (not JoGroup) then
        KyzderpsDerps:msg("Requires JoGroup")
        return
    end
    for unitTag, _ in pairs(pockets) do
        CrutchAlerts.Drawing.UnattachControl(JoGroup.frame[unitTag], "KDDPocket" .. unitTag)
    end
    JoGroup.ReAnchor()

    JoGroup.savedVars.colours.customColour = false
end


---------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------
function JG.GetSettings()
    return {
        {
            type = "checkbox",
            name = "[BETA] Show ult on JoGroup frames",
            tooltip = "Shows each group member's 2 ultimate icons and lower %, matching Hodor's misc ultimate list, if ultimate info is available via LibGroupCombatStats. Requires JoGroup and LibGroupCombatStats",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.integrations.showUltOnJoGroup end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.integrations.showUltOnJoGroup = value
                Uninitialize()
                JG.Initialize()
            end,
            width = "full",
        },
    }
end
