BattleStats = BattleStats or {}
local BS = BattleStats
local Util = BattleStats.Util
local UI = BattleStats.UI

BS.name = "BattleStats"
BS.svName = "BattleStats_SV"
BS.svVersion = 1

BS.defaults = {
    enabled = true,
    forceShow = false,
    unlocked = false,
    showMagRecovery = true,
    showStamRecovery = true,
    showHealthRecovery = true,
    showDamage = true,
    showResist = true,
    showPen = true,
    updateMs = 200,
    scale = 1.5,
    fontSize = 24,
    background = false,
    debug = false,
    moveStep = 1,
    anchorBase = "bars",

    -- Build Sheet (compact + normal uptime)
    buildSheetEnabled = true,
    buildSheetDefaultView = "likely", -- base | likely | perfect
    buildSheetUptimePreset = "normal", -- conservative | normal | aggressive
    buildSheetAssumeBlocking = false,
    buildSheetSampleHit = 1000,

    magRecovery = {
        useCustom = false,
        posX = 0,
        posY = 0,
        offsetX = -335,
        offsetY = 35,
    },
    stamRecovery = {
        useCustom = false,
        posX = 0,
        posY = 0,
        offsetX = 325,
        offsetY = 35,
    },
    healthRecovery = {
        useCustom = false,
        posX = 0,
        posY = 0,
        offsetX = 0,
        offsetY = 35,
    },
    damage = {
        useCustom = false,
        posX = 0,
        posY = 0,
        offsetX = -370,
        offsetY = -260,
    },
    resist = {
        useCustom = false,
        posX = 0,
        posY = 0,
        offsetX = 360,
        offsetY = -260,
    },
    pen = {
        useCustom = false,
        posX = 0,
        posY = 0,
        offsetX = 0,
        offsetY = -260,
    },
}

local function MergeDefaults(target, defaults)
    for k, v in pairs(defaults) do
        if type(v) == "table" then
            if type(target[k]) ~= "table" then
                target[k] = {}
            end
            MergeDefaults(target[k], v)
        else
            if target[k] == nil then
                target[k] = v
            end
        end
    end
end

local function InitSavedVars()
    if ZO_SavedVars and ZO_SavedVars.NewAccountWide then
        BS.SV = ZO_SavedVars:NewAccountWide(BS.svName, BS.svVersion, nil, BS.defaults)
        MergeDefaults(BS.SV, BS.defaults)
    else
        BS.SV = BS.SV or {}
        MergeDefaults(BS.SV, BS.defaults)
    end

    if type(BS.SV.magRecovery) ~= "table" then BS.SV.magRecovery = {} end
    if type(BS.SV.stamRecovery) ~= "table" then BS.SV.stamRecovery = {} end
    if type(BS.SV.healthRecovery) ~= "table" then BS.SV.healthRecovery = {} end
    if type(BS.SV.damage) ~= "table" then BS.SV.damage = {} end
    if type(BS.SV.resist) ~= "table" then BS.SV.resist = {} end
    if type(BS.SV.pen) ~= "table" then BS.SV.pen = {} end
    MergeDefaults(BS.SV.magRecovery, BS.defaults.magRecovery)
    MergeDefaults(BS.SV.stamRecovery, BS.defaults.stamRecovery)
    MergeDefaults(BS.SV.healthRecovery, BS.defaults.healthRecovery)
    MergeDefaults(BS.SV.damage, BS.defaults.damage)
    MergeDefaults(BS.SV.resist, BS.defaults.resist)
    MergeDefaults(BS.SV.pen, BS.defaults.pen)
    if BS.SV.showUI ~= nil and BS.SV.forceShow == nil then
        BS.SV.forceShow = (BS.SV.showUI == true)
    end
    if BS.SV.unlock ~= nil and BS.SV.unlocked == nil then
        BS.SV.unlocked = (BS.SV.unlock == true)
    end
    BS.SV.forceShow = (BS.SV.forceShow == true)
    BS.SV.unlocked = (BS.SV.unlocked == true)
end

function BS.FormatLine(label, value)
    return string.format("%s: %s", tostring(label), Util.FormatValue(value))
end

function BS.FormatRecoveryLine(label, value, color)
    local text = string.format("%s %s", tostring(label), Util.FormatValue(value))
    if color and color ~= "" then
        return string.format("%s%s|r", color, text)
    end
    return text
end

function BS.RefreshStats(reason)
    if not BS.SV or BS.SV.enabled ~= true then
        UI.UpdateVisibility()
        return
    end

    local cMag = "|c4FC3FF"
    local cStam = "|c4CFF4C"
    local cHealth = "|cFF4C4C"

    local mag = Util.GetRegenValue("STAT_MAGICKA_REGEN_COMBAT", "STAT_MAGICKA_REGEN_IDLE")
    local stam = Util.GetRegenValue("STAT_STAMINA_REGEN_COMBAT", "STAT_STAMINA_REGEN_IDLE")
    local health = Util.GetRegenValue("STAT_HEALTH_REGEN_COMBAT", "STAT_HEALTH_REGEN_IDLE")

    local weapon = Util.GetWeaponDamage()
    local spell = Util.GetSpellDamage()
    local phys = Util.GetDerivedStatValue("STAT_PHYSICAL_RESIST")
    local spellRes = Util.GetDerivedStatValue("STAT_SPELL_RESIST")
    local wpen = Util.GetDerivedStatValue("STAT_PHYSICAL_PENETRATION")
    local spen = Util.GetDerivedStatValue("STAT_SPELL_PENETRATION")

    local damageText = table.concat({
        BS.FormatLine("WP Dmg", weapon),
        BS.FormatLine("SP Dmg", spell),
    }, "\n")

    local resistText = table.concat({
        BS.FormatLine("PH Res", phys),
        BS.FormatLine("SP Res", spellRes),
    }, "\n")

    local penText = table.concat({
        BS.FormatLine("WPen", wpen),
        BS.FormatLine("SPen", spen),
    }, "\n")

    UI.SetBlockText("magRecovery", BS.FormatRecoveryLine("MR", mag, cMag))
    UI.SetBlockText("stamRecovery", BS.FormatRecoveryLine("SR", stam, cStam))
    UI.SetBlockText("healthRecovery", BS.FormatRecoveryLine("HR", health, cHealth))
    UI.SetBlockText("damage", damageText)
    UI.SetBlockText("resist", resistText)
    UI.SetBlockText("pen", penText)
    UI.UpdateVisibility()
end

function BS.ApplySettings()
    UI.ApplySettings()
    BS.Updater.RefreshUpdateRate()
end

function BS.PrintApiStatus()
    if not BS.SV or BS.SV.debug ~= true then return end
    Util.Debug("Using GetPlayerStat: " .. tostring(Util.HasFunction("GetPlayerStat")))
    Util.Debug("Using IsUnitInCombat: " .. tostring(Util.HasFunction("IsUnitInCombat")))
    Util.Debug("STAT_ATTACK_POWER: " .. tostring(Util.HasGlobal("STAT_ATTACK_POWER")))
    Util.Debug("STAT_SPELL_POWER: " .. tostring(Util.HasGlobal("STAT_SPELL_POWER")))
    Util.Debug("STAT_WEAPON_AND_SPELL_DAMAGE: " .. tostring(Util.HasGlobal("STAT_WEAPON_AND_SPELL_DAMAGE")))
    Util.Debug("STAT_PHYSICAL_RESIST: " .. tostring(Util.HasGlobal("STAT_PHYSICAL_RESIST")))
    Util.Debug("STAT_SPELL_RESIST: " .. tostring(Util.HasGlobal("STAT_SPELL_RESIST")))
    Util.Debug("EVENT_STATS_UPDATED: " .. tostring(Util.HasGlobal("EVENT_STATS_UPDATED")))
    Util.Debug("EVENT_EFFECT_CHANGED: " .. tostring(Util.HasGlobal("EVENT_EFFECT_CHANGED")))
    Util.Debug("EVENT_POWER_UPDATE: " .. tostring(Util.HasGlobal("EVENT_POWER_UPDATE")))
    Util.Debug("EVENT_PLAYER_COMBAT_STATE: " .. tostring(Util.HasGlobal("EVENT_PLAYER_COMBAT_STATE")))
    Util.Debug("EVENT_INVENTORY_SINGLE_SLOT_UPDATE: " .. tostring(Util.HasGlobal("EVENT_INVENTORY_SINGLE_SLOT_UPDATE")))
    Util.Debug("EVENT_ACTIVE_WEAPON_PAIR_CHANGED: " .. tostring(Util.HasGlobal("EVENT_ACTIVE_WEAPON_PAIR_CHANGED")))
    Util.Debug("EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED: " .. tostring(Util.HasGlobal("EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED")))
end

BS.Updater = BS.Updater or {}

function BS.Updater.RefreshUpdateRate()
    local em = EVENT_MANAGER
    if not em then return end
    em:UnregisterForUpdate(BS.name .. "_Update")

    em:RegisterForUpdate(BS.name .. "_Update", tonumber(BS.SV.updateMs) or 300, function()
        if BS.Updater.usePolling then
            BS.RefreshStats("poll")
        end
        UI.UpdateVisibility()
        UI.UpdateInteraction()
    end)
end

function BS.Updater.MaybeRefresh(reason)
    if not BS.SV or BS.SV.enabled ~= true then return end

    local now = Util.NowMs()
    local last = BS.Updater.lastUpdate or 0
    local interval = tonumber(BS.SV.updateMs) or 300
    local elapsed = now - last

    if elapsed >= interval then
        BS.Updater.lastUpdate = now
        BS.RefreshStats(reason)
        return
    end

    if BS.Updater.deferScheduled then return end

    local em = EVENT_MANAGER
    if not em then return end
    BS.Updater.deferScheduled = true
    local delay = interval - elapsed
    em:RegisterForUpdate(BS.name .. "_Deferred", delay, function()
        em:UnregisterForUpdate(BS.name .. "_Deferred")
        BS.Updater.deferScheduled = false
        BS.Updater.lastUpdate = Util.NowMs()
        BS.RefreshStats("deferred")
    end)
end

function BS.Updater.RegisterEvents()
    local em = EVENT_MANAGER
    if not em then return end

    local count = 0

    local function TryRegister(eventName, handler)
        local eventId = _G[eventName]
        if eventId then
            em:RegisterForEvent(BS.name, eventId, handler)
            count = count + 1
        else
            Util.DebugMissing("event", eventName)
        end
    end

    TryRegister("EVENT_STATS_UPDATED", function(_, unitTag)
        if unitTag == "player" then
            BS.Updater.MaybeRefresh("stats")
        end
    end)

    TryRegister("EVENT_EFFECT_CHANGED", function(_, changeType, effectSlot, effectName, unitTag)
        if unitTag == "player" then
            BS.Updater.MaybeRefresh("effect")
        end
    end)

    TryRegister("EVENT_POWER_UPDATE", function(_, unitTag)
        if unitTag == "player" then
            BS.Updater.MaybeRefresh("power")
        end
    end)

    TryRegister("EVENT_PLAYER_COMBAT_STATE", function(_, inCombat)
        BS.Updater.MaybeRefresh("combat")
    end)

    TryRegister("EVENT_INVENTORY_SINGLE_SLOT_UPDATE", function()
        BS.Updater.MaybeRefresh("inventory")
    end)

    TryRegister("EVENT_ACTIVE_WEAPON_PAIR_CHANGED", function()
        BS.Updater.MaybeRefresh("weapon")
    end)

    TryRegister("EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED", function()
        BS.Updater.MaybeRefresh("hotbar")
    end)

    TryRegister("EVENT_PLAYER_ACTIVATED", function()
        BS.RefreshStats("activated")
    end)

    BS.Updater.usePolling = (count == 0)
end

local function Initialize()
    InitSavedVars()
    UI.Init()
    if BS.BuildSheet and BS.BuildSheet.Init then
        BS.BuildSheet.Init()
    end
    BS.Settings.Init()
    BS.Updater.RegisterEvents()
    BS.Updater.RefreshUpdateRate()
    BS.RefreshStats("init")
    BS.PrintApiStatus()
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= BS.name then return end
    if EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForEvent(BS.name, EVENT_ADD_ON_LOADED)
    end
    Initialize()
end

if EVENT_MANAGER then
    EVENT_MANAGER:RegisterForEvent(BS.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
end
