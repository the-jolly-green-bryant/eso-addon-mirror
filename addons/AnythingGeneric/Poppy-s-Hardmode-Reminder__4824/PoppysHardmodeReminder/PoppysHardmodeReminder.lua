local addon = PoppysHardmodeReminder
local NAME = "PoppysHardmodeReminder"
local debugEnabled = false
-- ESO's boss unit slots are boss1 through boss6. Do not stop at a gap.
local BOSS_SLOTS = 6

local function Say(message)
    d("|cFFAA33[PHR]|r " .. message)
end

local function Snapshot(reason, combatState)
    if not debugEnabled then return end
    local zoneIndex = GetUnitZoneIndex("player")
    local zoneId = zoneIndex and GetZoneId(zoneIndex) or 0
    local zoneName = zoneId ~= 0 and GetZoneNameById(zoneId) or "(unavailable)"
    if combatState == nil then
        combatState = IsUnitInCombat("player")
    end
    Say(string.format("[%s] %s | zone=%s (%s) | combat=%s | API=%s | veteran=%s | normalTest=%s",
        GetTimeString(), reason, tostring(zoneId), zoneName,
        tostring(combatState), tostring(GetAPIVersion()),
        tostring(IsUnitUsingVeteranDifficulty("player")), tostring(addon.normalTest)))
    local found = false
    for i = 1, BOSS_SLOTS do
        local unitTag = "boss" .. i
        if DoesUnitExist(unitTag) then
            found = true
            local name = GetUnitName(unitTag)
            if name == "" then name = "(name unavailable)" end
            Say(unitTag .. " = " .. name)
        end
    end
    if not found then Say("No boss units detected (boss1-boss6).") end
end

local function OnLoaded(_, addonName)
    if addonName ~= NAME then return end
    EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)

    SLASH_COMMANDS["/hmtest"] = addon.ShowWarning
    SLASH_COMMANDS["/hmnormaltest"] = function()
        addon.normalTest = not addon.normalTest
        addon.ResetReminder()
        Say("Normal encounter testing " .. (addon.normalTest and "ON" or "OFF") .. ".")
        addon.CheckReminder()
    end
    SLASH_COMMANDS["/hmrearm"] = function()
        addon.ResetReminder()
        Say("Reminder re-armed; checking current encounter.")
        addon.CheckReminder()
    end
    SLASH_COMMANDS["/hmdebug"] = function()
        debugEnabled = not debugEnabled
        Say("Debug logging " .. (debugEnabled and "ON" or "OFF") .. ".")
        Snapshot("DEBUG ENABLED")
    end

    EVENT_MANAGER:RegisterForEvent(NAME, EVENT_BOSSES_CHANGED, function(_, forceReset)
        Snapshot("BOSSES CHANGED forceReset=" .. tostring(forceReset))
        addon.CheckReminder()
    end)
    EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        Snapshot(inCombat and "COMBAT ENTER (fallback scan)" or "COMBAT EXIT", inCombat)
        addon.CheckReminder()
    end)
    EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PLAYER_ACTIVATED, function()
        Snapshot("PLAYER ACTIVATED / ZONE SNAPSHOT")
        addon.CheckReminder()
    end)
    Say("v0.3 loaded. Listed encounter reminders enabled on Veteran. /hmtest /hmdebug /hmnormaltest /hmrearm")
end

EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnLoaded)
