-- =============================================================================
-- Dungeon Tracker — Core Logic v1.3.3
-- Initialisation, achievement scanning via hardcoded IDs.
-- Per-character dungeon story quest completion via GetCompletedQuestInfo.
-- Scene-based UI with GAMEPAD_DRIVEN_UI_WINDOW for native console input.
-- =============================================================================

DTT = DTT or {}
DTT.name    = "DungeonTrialTracker"
DTT.version = "1.3.3"

-- Runtime state
DTT.savedVars           = nil
DTT.contentRegistry     = {}   -- key → content definition
DTT.trackedAchievements = {}   -- contentKey → { achType → achData }
DTT.achievementLookup   = {}   -- achievementId → { contentKey, achType }
DTT.questLookup         = {}   -- questId → contentKey (dungeon story quests only)
DTT.questCompletion     = {}   -- contentKey → bool (story quest done on this character)
DTT.scanComplete        = false

-- ---------------------------------------------------------------------------
-- Default saved variables
-- ---------------------------------------------------------------------------
local SAVED_VAR_VERSION = 1
local SV_DEFAULTS = {
    position   = { x = 300, y = 150 },
    activeTab  = "base_dungeons",
    uiScale    = nil,
    collapsedGroups = {},
}

-- ---------------------------------------------------------------------------
-- Keybinding string registration (for Bindings.xml custom actions)
-- ---------------------------------------------------------------------------
ZO_CreateStringId("SI_BINDING_NAME_DTT_TOGGLE",      "Toggle Dungeon Tracker")
ZO_CreateStringId("SI_BINDING_NAME_DTT_NEXT_TAB",    "Next Tab")
ZO_CreateStringId("SI_BINDING_NAME_DTT_PREV_TAB",    "Previous Tab")
ZO_CreateStringId("SI_BINDING_NAME_DTT_SCROLL_DOWN", "Scroll Down")
ZO_CreateStringId("SI_BINDING_NAME_DTT_SCROLL_UP",   "Scroll Up")
ZO_CreateStringId("SI_BINDING_NAME_DTT_CLOSE",       "Close Tracker")

-- ═══════════════════════════════════════════════════════════════════════════
-- CONTENT REGISTRY
-- ═══════════════════════════════════════════════════════════════════════════

function DTT:BuildContentRegistry()
    self.contentRegistry   = {}
    self.achievementLookup = {}
    self.questLookup       = {}

    local function Register(list, contentType)
        for i, entry in ipairs(list) do
            local key = contentType .. "_" .. i
            local hasTri = (entry.triId ~= nil)
            self.contentRegistry[key] = {
                name         = entry.name,
                group        = entry.group,
                contentType  = contentType,
                hasTrifecta  = hasTri,
                index        = i,
                vetId        = entry.vetId,
                hmId         = entry.hmId,
                srId         = entry.srId,
                ndId         = entry.ndId,
                triId        = entry.triId,
                questId      = entry.questId,
            }

            if entry.questId and contentType == DTT_Data.CONTENT_DUNGEON then
                self.questLookup[entry.questId] = key
            end

            if entry.vetId then
                self.achievementLookup[entry.vetId] = { key = key, achType = DTT_Data.ACH_VETERAN }
            end
            if entry.hmId then
                self.achievementLookup[entry.hmId] = { key = key, achType = DTT_Data.ACH_HARD_MODE }
            end
            if entry.srId then
                self.achievementLookup[entry.srId] = { key = key, achType = DTT_Data.ACH_SPEED_RUN }
            end
            if entry.ndId then
                self.achievementLookup[entry.ndId] = { key = key, achType = DTT_Data.ACH_NO_DEATH }
            end
            if entry.triId then
                self.achievementLookup[entry.triId] = { key = key, achType = DTT_Data.ACH_TRIFECTA }
            end
        end
    end

    Register(DTT_Data.Dungeons, DTT_Data.CONTENT_DUNGEON)
    Register(DTT_Data.Trials,   DTT_Data.CONTENT_TRIAL)
    Register(DTT_Data.Arenas,   DTT_Data.CONTENT_ARENA)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ACHIEVEMENT SCANNING (direct ID lookup — no text matching)
-- ═══════════════════════════════════════════════════════════════════════════

local function CheckAchievement(achievementId)
    if not achievementId then return nil end
    local name, description, points, icon, completed = GetAchievementInfo(achievementId)
    if not name or name == "" then return nil end
    return {
        id          = achievementId,
        name        = name,
        description = description or "",
        completed   = completed,
        icon        = icon,
        points      = points or 0,
    }
end

function DTT:ScanAchievements()
    self.trackedAchievements = {}

    for key, content in pairs(self.contentRegistry) do
        local achs = {}

        if content.vetId then
            achs[DTT_Data.ACH_VETERAN] = CheckAchievement(content.vetId)
        end
        if content.hmId then
            achs[DTT_Data.ACH_HARD_MODE] = CheckAchievement(content.hmId)
        end
        if content.srId then
            achs[DTT_Data.ACH_SPEED_RUN] = CheckAchievement(content.srId)
        end
        if content.ndId then
            achs[DTT_Data.ACH_NO_DEATH] = CheckAchievement(content.ndId)
        end
        if content.triId then
            achs[DTT_Data.ACH_TRIFECTA] = CheckAchievement(content.triId)
        end

        self.trackedAchievements[key] = achs
    end

    self.scanComplete = true
end

-- ═══════════════════════════════════════════════════════════════════════════
-- STORY QUEST (per character — GetCompletedQuestInfo)
-- ═══════════════════════════════════════════════════════════════════════════

local function IsStoryQuestCompleted(questId)
    if not questId then return nil end
    local ok, name = pcall(GetCompletedQuestInfo, questId)
    if not ok or not name or name == "" then
        return false
    end
    return true
end

function DTT:ScanQuests()
    self.questCompletion = {}
    for key, content in pairs(self.contentRegistry) do
        if content.contentType == DTT_Data.CONTENT_DUNGEON and content.questId then
            self.questCompletion[key] = IsStoryQuestCompleted(content.questId)
        end
    end
end

function DTT:IsStoryQuestComplete(contentKey)
    return self.questCompletion[contentKey]
end

function DTT:UpdateQuestCompletion(questId)
    if not questId then return end
    local key = self.questLookup[questId]
    if not key then return end
    local content = self.contentRegistry[key]
    if not content or not content.questId then return end
    self.questCompletion[key] = IsStoryQuestCompleted(content.questId)
end

function DTT:UpdateAchievement(achievementId)
    local lookup = self.achievementLookup[achievementId]
    if not lookup then return end

    local achData = CheckAchievement(achievementId)
    if achData then
        if not self.trackedAchievements[lookup.key] then
            self.trackedAchievements[lookup.key] = {}
        end
        self.trackedAchievements[lookup.key][lookup.achType] = achData
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- PUBLIC HELPERS
-- ═══════════════════════════════════════════════════════════════════════════

function DTT:GetContentAchievements(contentKey)
    return self.trackedAchievements[contentKey] or {}
end

function DTT:IsAchievementComplete(contentKey, achType)
    local achs = self.trackedAchievements[contentKey]
    if achs and achs[achType] then
        return achs[achType].completed
    end
    return nil
end

function DTT:GetContentList(contentType)
    local results = {}
    for key, content in pairs(self.contentRegistry) do
        if content.contentType == contentType then
            table.insert(results, {
                key         = key,
                name        = content.name,
                group       = content.group,
                hasTrifecta = content.hasTrifecta,
                hasStoryQuest = (content.questId ~= nil),
                index       = content.index,
            })
        end
    end
    table.sort(results, function(a, b) return a.index < b.index end)
    return results
end

function DTT:GetProgress(contentType)
    local total, completed = 0, 0
    for key, content in pairs(self.contentRegistry) do
        if content.contentType == contentType then
            local achs = self.trackedAchievements[key]
            if achs then
                for achType, achData in pairs(achs) do
                    if achType ~= DTT_Data.ACH_OTHER then
                        total = total + 1
                        if achData.completed then
                            completed = completed + 1
                        end
                    end
                end
            end
        end
    end
    return completed, total
end

-- ═══════════════════════════════════════════════════════════════════════════
-- TOGGLE
-- ═══════════════════════════════════════════════════════════════════════════

function DTT:ToggleWindow()
    if DTT_UI then
        DTT_UI:Toggle()
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- INITIALISATION
-- ═══════════════════════════════════════════════════════════════════════════

function DTT:Initialize()
    self.savedVars = ZO_SavedVars:NewAccountWide("DungeonTrialTrackerSV", SAVED_VAR_VERSION, nil, SV_DEFAULTS)

    self:BuildContentRegistry()
    self:ScanAchievements()
    self:ScanQuests()

    -- Initialize UI (creates row pool, scroll controls, tab buttons, scene)
    if DTT_UI then
        DTT_UI:Initialize()
    end

    -- Slash commands
    SLASH_COMMANDS["/dtt"] = function(args)
        local cmd = string.lower(args or "")

        if cmd == "dungeons" or cmd == "base" then
            if DTT_UI then DTT_UI:Show() DTT_UI:SetActiveTab("base_dungeons") end
        elseif cmd == "dlc" then
            if DTT_UI then DTT_UI:Show() DTT_UI:SetActiveTab("dlc_dungeons") end
        elseif cmd == "next" or cmd == "n" then
            if DTT_UI then
                if not DTT_UI.visible then DTT_UI:Show() end
                DTT_UI:NextTab()
            end
        elseif cmd == "prev" or cmd == "p" or cmd == "previous" then
            if DTT_UI then
                if not DTT_UI.visible then DTT_UI:Show() end
                DTT_UI:PrevTab()
            end
        elseif cmd == "close" or cmd == "hide" then
            if DTT_UI then DTT_UI:Hide() end
        elseif cmd == "help" or cmd == "?" then
            d("|cE8C05C[DTT] Commands:|r")
            d("  |c00FFFF/dtt|r — toggle tracker")
            d("  |c00FFFF/dtt close|r — close tracker")
            d("  |c00FFFF/dtt next|r / |c00FFFF/dtt prev|r — cycle tabs")
            d("  |c00FFFF/dtt base|r / |c00FFFF/dtt dlc|r — open specific tab")
            d("  |c00FFFF/dtt help|r — show this list")
            d("  L1/R1 = switch tabs, L2/R2 = scroll, Circle = close")
        else
            self:ToggleWindow()
        end
    end
    SLASH_COMMANDS["/dungeontracker"] = function() self:ToggleWindow() end

    -- Update when achievement progress changes mid-session
    EVENT_MANAGER:RegisterForEvent(self.name .. "_AchUpdate", EVENT_ACHIEVEMENT_UPDATED,
        function(_, achievementId)
            self:UpdateAchievement(achievementId)
            if DTT_UI and DTT_UI.visible then
                DTT_UI:RefreshList()
            end
        end)

    -- Update when an achievement is completed/awarded (many HM/SR/ND fire only this)
    EVENT_MANAGER:RegisterForEvent(self.name .. "_AchAwarded", EVENT_ACHIEVEMENT_AWARDED,
        function(_, name, points, achievementId)
            self:UpdateAchievement(achievementId)
            if DTT_UI and DTT_UI.visible then
                DTT_UI:RefreshList()
            end
        end)

    -- Story quest row updates when a quest leaves the journal (incl. completion)
    EVENT_MANAGER:RegisterForEvent(self.name .. "_QuestRemoved", EVENT_QUEST_REMOVED,
        function(_, isCompleted, journalIndex, questName, zoneIndex, poiIndex, questID)
            if isCompleted then
                self:UpdateQuestCompletion(questID)
                if DTT_UI and DTT_UI.visible then
                    DTT_UI:RefreshList()
                end
            end
        end)
end

-- Late initialization: add to Journal menu after game UI is fully loaded
function DTT:LateInitialize()
    if DTT_UI then
        DTT_UI:LateInit()
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- EVENT HOOKS
-- ═══════════════════════════════════════════════════════════════════════════

local function OnAddonLoaded(_, addonName)
    if addonName ~= DTT.name then return end
    EVENT_MANAGER:UnregisterForEvent(DTT.name, EVENT_ADD_ON_LOADED)
    DTT:Initialize()
end

-- Menu integration must happen after the game UI is fully loaded.
-- EVENT_PLAYER_ACTIVATED fires after the player loads in.
-- Additional delay ensures ZO_MENU_ENTRIES and MAIN_MENU_GAMEPAD exist.
local function OnPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent(DTT.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED)
    zo_callLater(function()
        DTT:LateInitialize()
    end, 2000)
end

-- Rescan story quests when switching characters (per-character completion)
local function OnPlayerActivatedRescan()
    DTT:ScanQuests()
    if DTT_UI and DTT_UI.visible then
        DTT_UI:RefreshList()
    end
end

EVENT_MANAGER:RegisterForEvent(DTT.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent(DTT.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
EVENT_MANAGER:RegisterForEvent(DTT.name .. "_PlayerActivatedQuests", EVENT_PLAYER_ACTIVATED, OnPlayerActivatedRescan)
