-- Group Encore - Dungeon Reset
-- Version 0.1.3

local ADDON_NAME = "GroupEncore"
local DISPLAY_NAME = "Group Encore"

local GE = {
    version = "0.1.3",
    wasInGroupDungeon = false,
    dungeonWasGrouped = false,
    dungeonWasLeader = false,
    dungeonName = nil,
    resetGrouped = false,
    resetPending = false,
    resetRunning = false,
    originalVeteran = nil,
    oppositeVeteran = nil,
    attempts = 0,
}

local EM = EVENT_MANAGER

local function Chat(message)
    local text = string.format(
        "|c79C8FF[Group Encore]|r %s",
        message
    )

    if CHAT_ROUTER and type(CHAT_ROUTER.AddSystemMessage) == "function" then
        CHAT_ROUTER:AddSystemMessage(text)
    elseif CHAT_SYSTEM and type(CHAT_SYSTEM.AddMessage) == "function" then
        CHAT_SYSTEM:AddMessage(text)
    elseif type(d) == "function" then
        d(text)
    end
end

local function GetDungeonName()
    if type(GetUnitZone) == "function" then
        local name = GetUnitZone("player")
        if name and name ~= "" then
            return name
        end
    end
    return "Unknown Dungeon"
end

local function IsGroupedLeader()
    return IsUnitGrouped("player") and IsUnitGroupLeader("player")
end

local function IsPlayerInGroupDungeon()
    if not IsUnitInDungeon("player") then
        return false
    end

    -- Restrict automatic resets to four-player group dungeons. If an older
    -- client does not expose the zone-type constants, IsUnitInDungeon is the
    -- safest available fallback and the group-leader checks still apply.
    if GetZoneType and GetUnitZoneIndex and ZONE_TYPE_GROUP_DUNGEON then
        return GetZoneType(GetUnitZoneIndex("player")) == ZONE_TYPE_GROUP_DUNGEON
    end

    return true
end

local function GetPlayerVeteranSetting()
    if ZO_GetPlayerDungeonDifficulty and ZO_ConvertToIsVeteranDifficulty then
        return ZO_ConvertToIsVeteranDifficulty(ZO_GetPlayerDungeonDifficulty())
    end
    if IsGroupUsingVeteranDifficulty then
        return IsGroupUsingVeteranDifficulty()
    end
    return false
end

local function GetCurrentDungeonVeteranSetting()
    if GetCurrentZoneDungeonDifficulty and ZO_ConvertToIsVeteranDifficulty then
        return ZO_ConvertToIsVeteranDifficulty(GetCurrentZoneDungeonDifficulty())
    end
    return GetPlayerVeteranSetting()
end

local function AnnounceDungeonEntry()
    GE.dungeonName = GetDungeonName()
    GE.dungeonWasGrouped = IsUnitGrouped("player")
    GE.dungeonWasLeader = GE.dungeonWasGrouped and IsUnitGroupLeader("player")

    local difficulty = GetCurrentDungeonVeteranSetting() and "Veteran" or "Normal"
    local runType
    if GE.dungeonWasGrouped then
        runType = GE.dungeonWasLeader and "Grouped - Leader" or "Grouped - Member"
    else
        runType = "Solo"
    end
    Chat(string.format("Entered %s - %s - %s.", GE.dungeonName, difficulty, runType))
end

local function CancelReset(message)
    EM:UnregisterForUpdate(ADDON_NAME .. "_BeginReset")
    EM:UnregisterForUpdate(ADDON_NAME .. "_ConfirmFlip")
    EM:UnregisterForUpdate(ADDON_NAME .. "_Restore")
    GE.resetPending = false
    GE.resetRunning = false
    GE.originalVeteran = nil
    GE.oppositeVeteran = nil
    GE.attempts = 0
    GE.resetGrouped = false
    if message then
        Chat(message)
    end
end

local function RestoreDifficulty()
    EM:UnregisterForUpdate(ADDON_NAME .. "_Restore")

    if not GE.resetRunning or GE.originalVeteran == nil then
        return
    end
    if IsPlayerInGroupDungeon() then
        CancelReset("Reset cancelled because another dungeon was entered.")
        return
    end
    if GE.resetGrouped and not IsGroupedLeader() then
        CancelReset("Reset cancelled because you are no longer group leader.")
        return
    end
    if not GE.resetGrouped and IsUnitGrouped("player") then
        CancelReset("Solo reset cancelled because the group state changed.")
        return
    end

    SetVeteranDifficulty(GE.originalVeteran)
    local restoredName = GE.originalVeteran and "Veteran" or "Normal"

    zo_callLater(function()
        if GetPlayerVeteranSetting() == GE.originalVeteran then
            if GE.resetGrouped then
                Chat("Dungeon reset - " .. restoredName .. " restored.")
            else
                Chat("Reset applied - " .. restoredName .. " restored. Solo players may find the previous instance remains.")
            end
        else
            Chat("The dungeon reset ran, but ESO did not confirm the original difficulty. Please check Group settings.")
        end
        CancelReset()
    end, 1000)
end

local function ConfirmDifficultyFlip()
    EM:UnregisterForUpdate(ADDON_NAME .. "_ConfirmFlip")

    if not GE.resetRunning then
        return
    end
    if IsPlayerInGroupDungeon() then
        CancelReset("Dungeon reset cancelled because the group state changed.")
        return
    end
    if GE.resetGrouped and not IsGroupedLeader() then
        CancelReset("Dungeon reset cancelled because you are no longer group leader.")
        return
    end
    if not GE.resetGrouped and IsUnitGrouped("player") then
        CancelReset("Solo reset cancelled because the group state changed.")
        return
    end

    if GetPlayerVeteranSetting() == GE.oppositeVeteran then
        EM:RegisterForUpdate(ADDON_NAME .. "_Restore", 3500, RestoreDifficulty)
        return
    end

    GE.attempts = GE.attempts + 1
    if GE.attempts >= 2 then
        CancelReset("ESO did not accept the difficulty change; the dungeon was not reset.")
        return
    end

    SetVeteranDifficulty(GE.oppositeVeteran)
    EM:RegisterForUpdate(ADDON_NAME .. "_ConfirmFlip", 1500, ConfirmDifficultyFlip)
end

local function BeginReset()
    EM:UnregisterForUpdate(ADDON_NAME .. "_BeginReset")

    if not GE.resetPending or GE.resetRunning then
        return
    end
    if IsPlayerInGroupDungeon() then
        CancelReset()
        return
    end
    if GE.resetGrouped and not IsGroupedLeader() then
        CancelReset("No reset: only the group leader can reset the group dungeon.")
        return
    end
    if not GE.resetGrouped and IsUnitGrouped("player") then
        CancelReset("Solo reset cancelled because the group state changed.")
        return
    end
    if IsUnitInCombat("player") then
        CancelReset("No reset: you entered combat before the reset began.")
        return
    end
    if type(SetVeteranDifficulty) ~= "function" then
        CancelReset("This ESO client does not expose the dungeon difficulty control.")
        return
    end

    GE.originalVeteran = GetPlayerVeteranSetting()
    GE.oppositeVeteran = not GE.originalVeteran
    GE.resetPending = false
    GE.resetRunning = true
    GE.attempts = 0

    SetVeteranDifficulty(GE.oppositeVeteran)
    EM:RegisterForUpdate(ADDON_NAME .. "_ConfirmFlip", 1500, ConfirmDifficultyFlip)
end

local function OnPlayerDeactivated()
    -- Capture the old location before the loading screen removes its context.
    -- On console ESO can clear the zone state before this event arrives, so a
    -- known dungeon state from the preceding activation must not be erased.
    GE.wasInGroupDungeon = GE.wasInGroupDungeon or IsPlayerInGroupDungeon()
end

local function OnPlayerActivated(_, initial)
    local nowInGroupDungeon = IsPlayerInGroupDungeon()
    if GE.resetRunning and nowInGroupDungeon then
        CancelReset("Reset cancelled because another dungeon was entered.")
    elseif GE.wasInGroupDungeon and not nowInGroupDungeon then
        -- The player has loaded from a group dungeon into an outside zone.
        -- A short settling delay avoids changing settings during activation.
        GE.resetGrouped = GE.dungeonWasGrouped
        GE.resetPending = true
        local exitType = GE.resetGrouped and "grouped" or "solo"
        Chat(string.format("Exited %s (%s run). Reset check begins in 2 seconds.", GE.dungeonName or "dungeon", exitType))
        EM:UnregisterForUpdate(ADDON_NAME .. "_BeginReset")
        EM:RegisterForUpdate(ADDON_NAME .. "_BeginReset", 2000, BeginReset)
    elseif nowInGroupDungeon and not GE.wasInGroupDungeon then
        AnnounceDungeonEntry()
    end

    GE.wasInGroupDungeon = nowInGroupDungeon
end

local function OnGroupMemberLeft()
    if GE.resetGrouped and (GE.resetPending or GE.resetRunning) then
        zo_callLater(function()
            if not IsGroupedLeader() then
                CancelReset("Reset cancelled because the group changed.")
            end
        end, 250)
    end
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end
    EM:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    EM:RegisterForEvent(ADDON_NAME .. "_Deactivated", EVENT_PLAYER_DEACTIVATED, OnPlayerDeactivated)
    EM:RegisterForEvent(ADDON_NAME .. "_Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EM:RegisterForEvent(ADDON_NAME .. "_MemberLeft", EVENT_GROUP_MEMBER_LEFT, OnGroupMemberLeft)

    Chat("Version " .. GE.version .. " loaded. Waiting for a dungeon.")

    SLASH_COMMANDS["/groupencore"] = function()
        Chat("Version " .. GE.version .. " is active. It resets grouped dungeon runs when the group leader exits to the open world.")
    end
end

EM:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
