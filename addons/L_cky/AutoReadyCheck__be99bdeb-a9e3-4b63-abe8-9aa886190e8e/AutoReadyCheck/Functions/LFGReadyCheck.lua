AutoReadyCheck = AutoReadyCheck or {}

-- Map LFG_ACTIVITY types to settings
local activityToSettingKey = {
    -- [LFG_ACTIVITY_INVALID] = false,
    -- [LFG_ACTIVITY_AVA] = "avaLFGEnabled",
    [LFG_ACTIVITY_ARENA] = "arenaEnabled",
    [LFG_ACTIVITY_ENDLESS_DUNGEON] = "endlessDungeonEnabled",
    [LFG_ACTIVITY_DUNGEON] = "dungeonEnabled",
    [LFG_ACTIVITY_MASTER_DUNGEON] = "vetDungeonEnabled",
    [LFG_ACTIVITY_TRIAL] = "trialEnabled",
    [LFG_ACTIVITY_HOME_SHOW] = "homeShowEnabled",
    [LFG_ACTIVITY_BATTLE_GROUND_CHAMPION] = "bgEnabled",
    [LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION] = "bgEnabled",
    [LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL] = "bgEnabled",
    [LFG_ACTIVITY_TRIBUTE_COMPETITIVE] = "tributeCompEnabled",
    [LFG_ACTIVITY_TRIBUTE_CASUAL] = "tributeCasualEnabled",
    [LFG_ACTIVITY_EXPLORATION] = "explorationEnabled",
}

-- helper function to determine if any of these are set
local function IsAnyActivityEnabled()
    local settings = AutoReadyCheck.settings
    for _, settingKey in pairs(activityToSettingKey) do
        if settings[settingKey] then
            return true 
        end
    end
    return false
end

-- event handler
local function OnStatusUpdate(_eventCode, result)
    if result ~= ACTIVITY_FINDER_STATUS_READY_CHECK then return end

    local activityType = GetLFGReadyCheckActivityType()
    local settingKey = activityToSettingKey[activityType]
    
    if settingKey and AutoReadyCheck.settings[settingKey] then 
        AcceptLFGReadyCheckNotification() 
    end
end

-- update event registration based on current configuration
local function UpdateEventRegistration()
    local shouldBeEnabled = IsAnyActivityEnabled()
    
    if shouldBeEnabled then
        EVENT_MANAGER:RegisterForEvent(AutoReadyCheck.name, EVENT_ACTIVITY_FINDER_STATUS_UPDATE, OnStatusUpdate)
    else
        EVENT_MANAGER:UnregisterForEvent(AutoReadyCheck.name, EVENT_ACTIVITY_FINDER_STATUS_UPDATE)
    end
end

local function ToggleState(Getter, Setter)
    local newVal = not Getter()
    Setter(newVal)
    return newVal
end

local function SetPreference(key, val, msgConstant)
    AutoReadyCheck.settings[key] = val
    UpdateEventRegistration()
    return AutoReadyCheck.SendToggleMessage(val, msgConstant)
end

-- 3. PUBLIC API
-- Battlegrounds
function AutoReadyCheck.SetBattleGrounds(val) return SetPreference("bgEnabled", val, SI_ACTIVITY_FINDER_CATEGORY_BATTLEGROUNDS) end
function AutoReadyCheck.GetBattleGrounds() return AutoReadyCheck.settings.bgEnabled end

-- Dungeons
function AutoReadyCheck.SetDungeon(val) return SetPreference("dungeonEnabled", val, ARC_NORMAL_DUNGEON) end
function AutoReadyCheck.GetDungeon() return AutoReadyCheck.settings.dungeonEnabled end

-- Veteran Dungeons
function AutoReadyCheck.SetVetDungeon(val) return SetPreference("vetDungeonEnabled", val, ARC_VETERAN_DUNGEON) end
function AutoReadyCheck.GetVetDungeon() return AutoReadyCheck.settings.vetDungeonEnabled end

-- Endless Dungeons
function AutoReadyCheck.SetEndlessDungeon(val) return SetPreference("endlessDungeonEnabled", val, SI_ENDLESS_DUNGEON_HUD_TRACKER_TITLE) end
function AutoReadyCheck.GetEndlessDungeon() return AutoReadyCheck.settings.endlessDungeonEnabled end

-- Trials (unimplemented)
function AutoReadyCheck.SetTrial(val) return SetPreference("trialEnabled", val, SI_RAIDCATEGORY0) end
function AutoReadyCheck.GetTrial() return AutoReadyCheck.settings.trialEnabled end

-- Tribute
function AutoReadyCheck.SetTributeCasual(val) return SetPreference("tributeCasualEnabled", val, ARC_TRIBUTE_CASUAL) end
function AutoReadyCheck.GetTributeCasual() return AutoReadyCheck.settings.tributeCasualEnabled end

function AutoReadyCheck.SetTributeComp(val) return SetPreference("tributeCompEnabled", val, ARC_TRIBUTE_COMP) end
function AutoReadyCheck.GetTributeComp() return AutoReadyCheck.settings.tributeCompEnabled end

-- Arena
function AutoReadyCheck.SetArena(val) return SetPreference("arenaEnabled", val, SI_HOUSETOURLISTINGTAG1) end
function AutoReadyCheck.GetArena() return AutoReadyCheck.settings.arenaEnabled end

-- Home Show
function AutoReadyCheck.SetHomeShow(val) return SetPreference("homeShowEnabled", val, SI_LFGACTIVITY6) end
function AutoReadyCheck.GetHomeShow() return AutoReadyCheck.settings.homeShowEnabled end


-- INITIALIZATION
function AutoReadyCheck:InitLFGReadyCheck()
    AutoReadyCheck.activityFinder = false
    UpdateEventRegistration()
end