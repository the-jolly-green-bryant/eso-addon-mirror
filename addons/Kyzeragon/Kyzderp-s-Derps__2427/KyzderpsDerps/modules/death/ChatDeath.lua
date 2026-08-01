KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.ChatDeath = KyzderpsDerps.ChatDeath or {}
local ChatDeath = KyzderpsDerps.ChatDeath

---------------------------------------------------------------------
---------------------------------------------------------------------
local groupIdToTag = {}
local groupTagToId = {}

local function CacheUnitTag(_, _, _, _, unitTag, _, _, _, _, _, _, _, _, _, unitId)
    local oldId = groupTagToId[unitTag]
    if (oldId ~= nil and oldId ~= unitId) then
        groupIdToTag[oldId] = nil
    end
    groupIdToTag[unitId] = unitTag
    groupTagToId[unitTag] = unitId
end

-- From LibCombat. Seems we only get the info if it's a self killing blow?
local damageTypeColors = {
    [DAMAGE_TYPE_NONE]      = "E6E6E6",
    [DAMAGE_TYPE_GENERIC]   = "E6E6E6",
    [DAMAGE_TYPE_PHYSICAL]  = "f4f2e8",
    [DAMAGE_TYPE_FIRE]      = "ff6600",
    [DAMAGE_TYPE_SHOCK]     = "ffff66",
    [DAMAGE_TYPE_OBLIVION]  = "d580ff",
    [DAMAGE_TYPE_COLD]      = "b3daff",
    [DAMAGE_TYPE_EARTH]     = "bfa57d",
    [DAMAGE_TYPE_MAGIC]     = "9999ff",
    [DAMAGE_TYPE_DROWN]     = "cccccc",
    [DAMAGE_TYPE_DISEASE]   = "c48a9f",
    [DAMAGE_TYPE_POISON]    = "9fb121",
    [DAMAGE_TYPE_BLEED]     = "c20a38",
}

-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
local function OnKillingBlow(_, result, _, _, _, _, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, _, sourceUnitId, targetUnitId, abilityId, overflow)
    local unitTag = groupIdToTag[targetUnitId]
    if (not unitTag) then return end

    -- Blue for others, red for player
    local color = "449fdb"
    if (GetUnitDisplayName(unitTag) == GetUnitDisplayName("player")) then
        color = "e82020"
    end

    -- @name or char name
    local displayName
    if (KyzderpsDerps.savedOptions.deathAlert.chatUseCharName) then
        displayName = GetUnitName(unitTag)
    else
        displayName = GetUnitDisplayName(unitTag)
    end

    local message = string.format("|c%s%s|r |cAAAAAAdied from|r |t100%%:100%%:%s|t |c%s%s",
        -- result == ACTION_RESULT_DIED and "DIED" or "KB",
        color,
        displayName or "",
        GetAbilityIcon(abilityId),
        damageTypeColors[damageType] or "444444",
        GetAbilityName(abilityId))

    -- Without prefix
    if (CHAT_ROUTER) then
        CHAT_ROUTER:AddSystemMessage(message)
    end
    -- KyzderpsDerps:msg(message)
end


---------------------------------------------------------------------
-- Initialize
---------------------------------------------------------------------
function ChatDeath.Initialize()
    KyzderpsDerps:dbg("    Initializing ChatDeath...")

    groupIdToTag = {}
    groupTagToId = {}

    if (not KyzderpsDerps.savedOptions.deathAlert.chatKillingBlow) then
        return
    end

    -- Cache unit ids to tags
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "CacheEffect", EVENT_EFFECT_CHANGED, CacheUnitTag)
    EVENT_MANAGER:AddFilterForEvent(KyzderpsDerps.name .. "CacheEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_GROUP)
    EVENT_MANAGER:AddFilterForEvent(KyzderpsDerps.name .. "CacheEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "PlayerActivationDeathClear", EVENT_PLAYER_ACTIVATED, function()
        groupIdToTag = {}
        groupTagToId = {}
    end)

    -- Killing blows only
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "KillingBlow", EVENT_COMBAT_EVENT, OnKillingBlow)
    EVENT_MANAGER:AddFilterForEvent(KyzderpsDerps.name .. "KillingBlow", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_KILLING_BLOW)

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "ChatDeathDied", EVENT_COMBAT_EVENT, OnKillingBlow)
    EVENT_MANAGER:AddFilterForEvent(KyzderpsDerps.name .. "ChatDeathDied", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED)
end

local function Uninitialize()
    KyzderpsDerps:dbg("    Uninitializing ChatDeath...")

    EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "CacheEffect", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "PlayerActivationDeathClear", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "KillingBlow", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "ChatDeathDied", EVENT_COMBAT_EVENT)
end


---------------------------------------------------------------------
-- Settings called from DeathAlert (to combine them)
---------------------------------------------------------------------
function ChatDeath.GetSettings()
    return {
        {
            type = "checkbox",
            name = "Killing blow to chat",
            tooltip = "Print killing blow on group member (if known) when they die",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.deathAlert.chatKillingBlow end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.deathAlert.chatKillingBlow = value
                Uninitialize()
                ChatDeath.Initialize()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "    Use character names",
            tooltip = "Print character names instead of @names",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.deathAlert.chatUseCharName end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.deathAlert.chatUseCharName = value
            end,
            width = "full",
        },
    }
end
