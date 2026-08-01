-- =============================================================================
-- Trial & Arena Tracker — Core Logic v1.2.0
-- Initialisation, achievement scanning via hardcoded IDs.
-- Scene-based UI with GAMEPAD_DRIVEN_UI_WINDOW for native console input.
-- =============================================================================

TAT = TAT or {}
TAT.name    = "TrialArenaTracker"
TAT.version = "1.2.6"

-- Runtime state
TAT.savedVars           = nil
TAT.contentRegistry     = {}   -- key → content definition
TAT.trackedAchievements = {}   -- contentKey → { achType → achData }
TAT.achievementLookup   = {}   -- achievementId → { contentKey, achType }
TAT.scanComplete        = false

-- ---------------------------------------------------------------------------
-- Default saved variables
-- ---------------------------------------------------------------------------
local SAVED_VAR_VERSION = 1
local SV_DEFAULTS = {
    activeTab = "trials",
}

-- ---------------------------------------------------------------------------
-- Keybinding string registration (for Bindings.xml custom actions)
-- ---------------------------------------------------------------------------
ZO_CreateStringId("SI_BINDING_NAME_TAT_TOGGLE",      "Toggle Trial & Arena Tracker")
ZO_CreateStringId("SI_BINDING_NAME_TAT_NEXT_TAB",    "Next Tab")
ZO_CreateStringId("SI_BINDING_NAME_TAT_PREV_TAB",    "Previous Tab")
ZO_CreateStringId("SI_BINDING_NAME_TAT_SCROLL_DOWN", "Scroll Down")
ZO_CreateStringId("SI_BINDING_NAME_TAT_SCROLL_UP",   "Scroll Up")
ZO_CreateStringId("SI_BINDING_NAME_TAT_CLOSE",       "Close Tracker")

-- ═══════════════════════════════════════════════════════════════════════════
-- CONTENT REGISTRY
-- ═══════════════════════════════════════════════════════════════════════════

function TAT:BuildContentRegistry()
    self.contentRegistry   = {}
    self.achievementLookup = {}

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
            }

            if entry.vetId then
                self.achievementLookup[entry.vetId] = { key = key, achType = TAT_Data.ACH_VETERAN }
            end
            if entry.hmId then
                self.achievementLookup[entry.hmId] = { key = key, achType = TAT_Data.ACH_HARD_MODE }
            end
            if entry.srId then
                self.achievementLookup[entry.srId] = { key = key, achType = TAT_Data.ACH_SPEED_RUN }
            end
            if entry.ndId then
                self.achievementLookup[entry.ndId] = { key = key, achType = TAT_Data.ACH_NO_DEATH }
            end
            if entry.triId then
                self.achievementLookup[entry.triId] = { key = key, achType = TAT_Data.ACH_TRIFECTA }
            end
        end
    end

    Register(TAT_Data.Trials, TAT_Data.CONTENT_TRIAL)
    Register(TAT_Data.Arenas, TAT_Data.CONTENT_ARENA)
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

function TAT:ScanAchievements()
    self.trackedAchievements = {}

    for key, content in pairs(self.contentRegistry) do
        local achs = {}

        if content.vetId then
            achs[TAT_Data.ACH_VETERAN] = CheckAchievement(content.vetId)
        end
        if content.hmId then
            achs[TAT_Data.ACH_HARD_MODE] = CheckAchievement(content.hmId)
        end
        if content.srId then
            achs[TAT_Data.ACH_SPEED_RUN] = CheckAchievement(content.srId)
        end
        if content.ndId then
            achs[TAT_Data.ACH_NO_DEATH] = CheckAchievement(content.ndId)
        end
        if content.triId then
            achs[TAT_Data.ACH_TRIFECTA] = CheckAchievement(content.triId)
        end

        self.trackedAchievements[key] = achs
    end

    self.scanComplete = true
end

function TAT:UpdateAchievement(achievementId)
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

function TAT:IsAchievementComplete(contentKey, achType)
    local achs = self.trackedAchievements[contentKey]
    if achs and achs[achType] then
        return achs[achType].completed
    end
    return nil
end

function TAT:GetContentList(contentType)
    local results = {}
    for key, content in pairs(self.contentRegistry) do
        if content.contentType == contentType then
            table.insert(results, {
                key         = key,
                name        = content.name,
                group       = content.group,
                hasTrifecta = content.hasTrifecta,
                index       = content.index,
            })
        end
    end
    table.sort(results, function(a, b) return a.index < b.index end)
    return results
end

-- ═══════════════════════════════════════════════════════════════════════════
-- TOGGLE
-- ═══════════════════════════════════════════════════════════════════════════

function TAT:ToggleWindow()
    if TAT_UI then
        TAT_UI:Toggle()
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- INITIALISATION
-- ═══════════════════════════════════════════════════════════════════════════

function TAT:Initialize()
    self.savedVars = ZO_SavedVars:NewAccountWide("TrialArenaTrackerSV", SAVED_VAR_VERSION, nil, SV_DEFAULTS)

    self:BuildContentRegistry()
    self:ScanAchievements()

    if TAT_UI then
        TAT_UI:Initialize()
    end

    -- Slash commands
    SLASH_COMMANDS["/tat"] = function(args)
        local cmd = string.lower(args or "")

        if cmd == "trials" or cmd == "trial" then
            if TAT_UI then TAT_UI:Show() TAT_UI:SetActiveTab("trials") end
        elseif cmd == "arenas" or cmd == "arena" then
            if TAT_UI then TAT_UI:Show() TAT_UI:SetActiveTab("arenas") end
        elseif cmd == "next" or cmd == "n" then
            if TAT_UI then
                if not TAT_UI.visible then TAT_UI:Show() end
                TAT_UI:NextTab()
            end
        elseif cmd == "prev" or cmd == "p" then
            if TAT_UI then
                if not TAT_UI.visible then TAT_UI:Show() end
                TAT_UI:PrevTab()
            end
        elseif cmd == "close" or cmd == "hide" then
            if TAT_UI then TAT_UI:Hide() end
        elseif cmd == "help" or cmd == "?" then
            d("|cE8C05C[TAT] Commands:|r")
            d("  |c00FFFF/tat|r — toggle tracker")
            d("  |c00FFFF/tat close|r — close tracker")
            d("  |c00FFFF/tat next|r / |c00FFFF/tat prev|r — cycle tabs")
            d("  |c00FFFF/tat trials|r / |c00FFFF/tat arenas|r — open specific tab")
            d("  |c00FFFF/tat help|r — show this list")
            d("  L1/R1 = switch tabs, L2/R2 = scroll, Circle = close")
        else
            self:ToggleWindow()
        end
    end
    SLASH_COMMANDS["/trialtracker"] = function() self:ToggleWindow() end

    -- Update when achievement progress changes mid-session
    EVENT_MANAGER:RegisterForEvent(self.name .. "_AchUpdate", EVENT_ACHIEVEMENT_UPDATED,
        function(_, achievementId)
            self:UpdateAchievement(achievementId)
            if TAT_UI and TAT_UI.visible then
                TAT_UI:RefreshList()
            end
        end)

    -- Update when an achievement is completed/awarded (many HM/SR/ND fire only this)
    EVENT_MANAGER:RegisterForEvent(self.name .. "_AchAwarded", EVENT_ACHIEVEMENT_AWARDED,
        function(_, name, points, achievementId)
            self:UpdateAchievement(achievementId)
            if TAT_UI and TAT_UI.visible then
                TAT_UI:RefreshList()
            end
        end)
end

function TAT:LateInitialize()
    if TAT_UI then
        TAT_UI:LateInit()
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- EVENT HOOKS
-- ═══════════════════════════════════════════════════════════════════════════

local function OnAddonLoaded(_, addonName)
    if addonName ~= TAT.name then return end
    EVENT_MANAGER:UnregisterForEvent(TAT.name, EVENT_ADD_ON_LOADED)
    TAT:Initialize()
end

local function OnPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent(TAT.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED)
    zo_callLater(function()
        TAT:LateInitialize()
    end, 2000)
end

EVENT_MANAGER:RegisterForEvent(TAT.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent(TAT.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
