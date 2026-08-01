DungeonHistory = {}
DungeonHistory.name     = 'DungeonHistory'
DungeonHistory.slashShort   = '/dh'
DungeonHistory.slashLong   = '/dungeonhistory'
DungeonHistory.slashDateFormat = '/dhdateformat'
DungeonHistory.slashEraseAllData = '/dherasealldata'
DungeonHistory.version  = '1.1.2'
DungeonHistory.author   = '@oInsideOut'


function DungeonHistory.InitSpecificValues()

    DungeonHistory.vars = {
        inDungeon = false,
        startTime = nil,
        finishTime = nil,
        started = false,
        dungeonName = nil,
        characterName = nil,
        completed = true,
        dungeonDuration = nil,
        dungeonDifficulty = nil--,
--        groupMembers = {},
    }
end

DungeonHistory.Default = {
    dungeonCompleted = {},
    options = {
        dateMDY = false
    },
    dungeonStats = {}
}

function DungeonHistory.TimeFormat(secs)

    local hours = math.floor(secs / 3600)
    local minutes = math.floor((secs % 3600) / 60)
    return string.format('%02d:%02d', hours, minutes)
end

function DungeonHistory.UpdatePlayerInDungeon()

    DungeonHistory.vars.inDungeon = IsUnitInDungeon('player')
end

function DungeonHistory.dungeonDifficultyToString(difficulty)
    if difficulty == 0 then
        return "None"
    end
    if difficulty == 1 then
        return "Normal"
    end
    if difficulty == 2 then
        return "Veteran"
    end
end

function DungeonHistory.GetSavedDungeonEntityNames()
    local entityNames = {}
    local counter = 1

    for key, value in pairs(DungeonHistory.saveData.dungeonCompleted) do
        entityNames[counter] = key
        counter = counter +1
    end
    return entityNames
end

function DungeonHistory.GetAllDungeonNames()
    local dungeonList = {}
    dungeonList[1] = "All Dungeons"
    local AFDT = (ZO_ACTIVITY_FINDER_ROOT_MANAGER:GetLocationsData(2))

    for key, value in pairs(AFDT) do
        if value.zoneId then
            table.insert(dungeonList, value.rawName)
        end
    end
    return dungeonList
end

function DungeonHistory.SetDungeonStatsSavedVarsDefaults()

    for key, value in pairs(DungeonHistory.allDungeons) do
        DungeonHistory.Default.dungeonStats[value] = {
            dungeonCounter = 0,
            lastCounterReset = os.time(),
            dungeonNotes = ""
        }
    end
end

function DungeonHistory.eraseAllData()
    DungeonHistory.saveData.dungeonCompleted = {}
    DungeonHistory.saveData.options = DungeonHistory.Default.options
    DungeonHistory.saveData.dungeonStats = DungeonHistory.Default.dungeonStats
    d("[DungeonHistory] All Data has been erased. Reload the UI or restart the game for it to take effect.")
end

--[[
function DungeonHistory.GetGroupMembers()
    local groupMembers = {}

    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        local displayName = GetUnitDisplayName(unitTag)
        local unitClass = GetUnitClass(unitTag)
        local unitRole = GetGroupMemberSelectedRole(unitTag)

        table.insert(groupMembers, {memberAccountName = displayName, memberClass = unitClass, memberRole = unitRole})
    end

    return groupMembers
end

function DungeonHistory.UnitClassToString(class)
    
    LFGRole:
        LFG_ROLE_DPS
        LFG_ROLE_HEAL
        LFG_ROLE_INVALID
        LFG_ROLE_TANK
    
    if class == 0 then
        return "Invalid"
    end
    if class == 1 then
        return "DPS"
    end
    if class == 2 then
        return "TANK"
    end
    if class == 4 then
        return "HEAL"
    end
end

function DungeonHistory.DebugPrintTable(t)
    for index, value in ipairs(t) do
        d(value)
    end
end
]]--

function DungeonHistory.CheckDungeonNameArticle(dungeon)
    for _, str in ipairs(DungeonHistory.allDungeons) do
        if string.match(str, dungeon) then
            return tostring(str)
        end
    end
    return nil
end

function DungeonHistory.StartDungeon(event, ActivityFinderStatus)

    if DungeonHistory.vars.inDungeon ~= IsUnitInDungeon('player') then

        DungeonHistory.UpdatePlayerInDungeon()
    end

    if ActivityFinderStatus == ACTIVITY_FINDER_STATUS_IN_PROGRESS and DungeonHistory.vars.inDungeon and DungeonHistory.vars.completed then
        
        if not DungeonHistory.vars.started then
            DungeonHistory.vars.startTime = os.time()
            DungeonHistory.vars.started = true
            DungeonHistory.vars.characterName = GetUnitName('player')
            DungeonHistory.vars.dungeonDifficulty = GetCurrentZoneDungeonDifficulty()
            DungeonHistory.vars.completed = false
        end

    elseif ActivityFinderStatus == ACTIVITY_FINDER_STATUS_COMPLETE and DungeonHistory.vars.inDungeon and DungeonHistory.vars.started then
        
        if not DungeonHistory.vars.completed then
            DungeonHistory.vars.finishTime = os.time()
            DungeonHistory.vars.dungeonName = string.match(GetUnitZone('player'), "([^%^]+)")
            if DungeonHistory.saveData.dungeonStats[DungeonHistory.vars.dungeonName] == nil then
                DungeonHistory.vars.dungeonName = DungeonHistory.CheckDungeonNameArticle(DungeonHistory.vars.dungeonName)
            end
            DungeonHistory.vars.completed = true
            DungeonHistory.vars.dungeonDuration = DungeonHistory.TimeFormat(DungeonHistory.vars.finishTime - DungeonHistory.vars.startTime)
            --DungeonHistory.vars.groupMembers = DungeonHistory.GetGroupMembers()
            --DungeonHistory.DebugPrintTable(DungeonHistory.vars.groupMembers)
            DungeonHistory.saveData.dungeonCompleted[os.time()] = {
                Dungeon = DungeonHistory.vars.dungeonName,
                Character = DungeonHistory.vars.characterName,
                Started = DungeonHistory.vars.startTime,
                Duration = DungeonHistory.vars.dungeonDuration,
                Difficulty = DungeonHistory.vars.dungeonDifficulty--,
                --Members = DungeonHistory.vars.groupMembers
            }
            DungeonHistory.saveData.dungeonStats[DungeonHistory.vars.dungeonName].dungeonCounter = DungeonHistory.saveData.dungeonStats[DungeonHistory.vars.dungeonName].dungeonCounter + 1
            DungeonHistory.saveData.dungeonStats[DungeonHistory.allDungeons[1]].dungeonCounter = DungeonHistory.saveData.dungeonStats[DungeonHistory.allDungeons[1]].dungeonCounter + 1
            DungeonHistory.vars.started = false
            DungeonHistory.XML.FillListSavedVariables()
            DungeonHistory.XML.SL.DungeonList:Refresh()
        end
    
    elseif ActivityFinderStatus == ACTIVITY_FINDER_STATUS_NONE and DungeonHistory.vars.started then

        DungeonHistory.InitSpecificValues()
    end
end

function DungeonHistory.Initialize()

    DungeonHistory.InitSpecificValues()
    DungeonHistory.CurrAccount = GetDisplayName()
    DungeonHistory.CurrServer = GetWorldName()

    DungeonHistory.XML.InitializeComboBox()
    DungeonHistory.XML.InitializeEditBox()

    DungeonHistory.XML.SL.DungeonList = DungeonHistory.XML.DungeonList:New()
    DungeonHistory.XML.FillListSavedVariables()
	DungeonHistory.XML.SL.DungeonList:Refresh()

    ZO_CreateStringId("SI_BINDING_NAME_DH_TOGGLE_UI", "Show/Hide History Window")

    if DungeonHistory.AddonMenu.LAM2 then
        DungeonHistory.AddonMenu.LAM2:RegisterAddonPanel(DungeonHistory.AddonMenu.panelName, DungeonHistory.AddonMenu.panelData)
        DungeonHistory.AddonMenu.LAM2:RegisterOptionControls(DungeonHistory.AddonMenu.panelName, DungeonHistory.AddonMenu.optionsData)
    end

    EVENT_MANAGER:RegisterForEvent(DungeonHistory.name, EVENT_ACTIVITY_FINDER_STATUS_UPDATE, DungeonHistory.StartDungeon)
end

function DungeonHistory.OnAddOnLoaded(event, addonName)

    if addonName ~= DungeonHistory.name then return end
    EVENT_MANAGER:UnregisterForEvent(DungeonHistory.name, EVENT_ADD_ON_LOADED)

    DungeonHistory.allDungeons = DungeonHistory.GetAllDungeonNames()
    DungeonHistory.SetDungeonStatsSavedVarsDefaults()

    DungeonHistory.saveData = ZO_SavedVars:NewAccountWide('DungeonHistoryData', 1, nil, DungeonHistory.Default, GetWorldName())
    DungeonHistory.Initialize()
end

EVENT_MANAGER:RegisterForEvent(DungeonHistory.name, EVENT_ADD_ON_LOADED, DungeonHistory.OnAddOnLoaded)