-- ESO Adventurer Suite - Built-in Bug Catcher
-- Captures Lua errors without replacing ESO's global error handler. Errors are
-- deduplicated and stored in the Suite SavedVariables so they survive /reloadui.

ESOProgressionCoach = ESOProgressionCoach or {}
local EPC = ESOProgressionCoach

EPC.BugCatcher = EPC.BugCatcher or {}
local B = EPC.BugCatcher

local EARLY_MAX = 20
local TEXT_LIMIT = 6000
local DEFAULT_MAX = 40
local NOTICE_THROTTLE_MS = 1500

-- LibDebugLogger intentionally raises a pair of Time Sync marker errors so its
-- external log viewer can line up timestamps. They are diagnostics, not addon
-- failures, and should never consume Suite Bug Catcher slots or unread counts.
local LIBDEBUGLOGGER_TIME_SYNC_CODES = {
    [0x32BBA739] = true,
    [0xEA5D75AD] = true,
}

local function isIgnoredNoise(kind, text, errorCode)
    if tostring(kind or "LUA") ~= "LUA" then return false end

    local numericCode = tonumber(errorCode)
    if numericCode and LIBDEBUGLOGGER_TIME_SYNC_CODES[numericCode] then
        return true
    end

    text = tostring(text or "")
    if string.find(text, "user:/AddOns/LibDebugLogger/TimeSync.lua", 1, true)
        and string.find(text, "Time Sync B", 1, true) then
        return true
    end

    return false
end

local function nowMs()
    if type(GetFrameTimeMilliseconds) == "function" then return tonumber(GetFrameTimeMilliseconds()) or 0 end
    return 0
end

local function nowStamp()
    if type(GetTimeStamp) == "function" then return tonumber(GetTimeStamp()) or 0 end
    return 0
end

local function trimText(value)
    local text = tostring(value or "")
    if #text > TEXT_LIMIT then
        text = string.sub(text, 1, TEXT_LIMIT) .. "\n...[truncated by ESO Adventurer Suite Bug Catcher]"
    end
    return text
end

local function firstLine(text)
    text = tostring(text or "")
    return string.match(text, "([^\r\n]+)") or text
end

local function sourceFromError(text)
    text = tostring(text or "")
    local addon = string.match(text, "user:/AddOns/([^/]+)/")
    if addon and addon ~= "" then return addon end
    if string.find(text, "EsoUI/", 1, true) then return "ESO UI" end
    return "Unknown source"
end

B.pending = B.pending or {}
B.captureGuard = false
B.ready = B.ready == true

function B:StoreEarly(kind, text, errorCode)
    if isIgnoredNoise(kind, text, errorCode) then return end
    text = trimText(text)
    if text == "" then return end
    self.pending[#self.pending + 1] = { kind = tostring(kind or "LUA"), text = text, stamp = nowStamp(), errorCode = errorCode }
    while #self.pending > EARLY_MAX do table.remove(self.pending, 1) end
end

function B:Capture(kind, text, stamp, errorCode)
    if isIgnoredNoise(kind, text, errorCode) then return true end
    if self.captureGuard then return end
    self.captureGuard = true

    local ok = pcall(function()
        text = trimText(text)
        if text == "" then return end

        if not self.ready or not EPC.saved then
            self:StoreEarly(kind, text, errorCode)
            return
        end
        if EPC.saved.bugCatcherEnabled == false then return end

        EPC.saved.bugCatcherLog = EPC.saved.bugCatcherLog or {}
        local log = EPC.saved.bugCatcherLog
        local maxErrors = math.floor(tonumber(EPC.saved.bugCatcherMaxErrors) or DEFAULT_MAX)
        maxErrors = math.max(10, math.min(100, maxErrors))
        local capturedAt = tonumber(stamp) or nowStamp()
        local source = sourceFromError(text)
        local sessionId = tostring(self.sessionId029123 or "legacy")

        local found
        for i = #log, 1, -1 do
            local entry = log[i]
            if type(entry) == "table" and entry.text == text and entry.kind == tostring(kind or "LUA")
                and tostring(entry.sessionId029123 or "legacy") == sessionId then
                found = entry
                break
            end
        end

        if found then
            found.count = (tonumber(found.count) or 1) + 1
            found.lastAt = capturedAt
            found.source = source
        else
            log[#log + 1] = {
                kind = tostring(kind or "LUA"),
                text = text,
                source = source,
                firstAt = capturedAt,
                lastAt = capturedAt,
                count = 1,
                sessionId029123 = sessionId,
                addonVersion029123 = tostring(EPC.version or "0.29.125"),
            }
            while #log > maxErrors do table.remove(log, 1) end
        end

        EPC.saved.bugCatcherUnread = (tonumber(EPC.saved.bugCatcherUnread) or 0) + 1
        self.sessionCaught = (tonumber(self.sessionCaught) or 0) + 1
        self.lastCaughtText = text

        if EPC.saved.bugCatcherNotifyChat ~= false then
            local now = nowMs()
            if not self.lastNoticeAt or (now - self.lastNoticeAt) >= NOTICE_THROTTLE_MS then
                self.lastNoticeAt = now
                if EPC.Print then
                    EPC:Print(string.format("Bug Catcher caught an error from %s. Type /easbugs last to view it.", tostring(source)))
                end
            end
        end
        self:MaybeSuppressPopup()
    end)

    self.captureGuard = false
    return ok
end

function B:MaybeSuppressPopup()
    if not EPC.saved or EPC.saved.bugCatcherSuppressPopup ~= true then return end
    if type(zo_callLater) == "function" and type(ZO_UIErrors_HideCurrent) == "function" then
        zo_callLater(function() pcall(ZO_UIErrors_HideCurrent) end, 0)
    elseif type(ZO_UIErrors_HideCurrent) == "function" then
        pcall(ZO_UIErrors_HideCurrent)
    end
end

function B:PruneIgnoredNoise()
    if not EPC.saved then return 0 end
    EPC.saved.bugCatcherLog = EPC.saved.bugCatcherLog or {}

    local log = EPC.saved.bugCatcherLog
    local removedOccurrences = 0
    for i = #log, 1, -1 do
        local entry = log[i]
        if type(entry) == "table" and isIgnoredNoise(entry.kind, entry.text, entry.errorCode) then
            removedOccurrences = removedOccurrences + (tonumber(entry.count) or 1)
            table.remove(log, i)
        end
    end

    if removedOccurrences > 0 then
        EPC.saved.bugCatcherUnread = math.max(0, (tonumber(EPC.saved.bugCatcherUnread) or 0) - removedOccurrences)
    end
    return removedOccurrences
end

function B:GetLog()
    if not EPC.saved then return {} end
    EPC.saved.bugCatcherLog = EPC.saved.bugCatcherLog or {}
    return EPC.saved.bugCatcherLog
end

function B:GetUniqueCount()
    return #self:GetLog()
end

function B:GetTotalOccurrences()
    local total = 0
    for _, entry in ipairs(self:GetLog()) do total = total + (tonumber(entry.count) or 1) end
    return total
end

function B:GetLastError()
    local log = self:GetLog()
    return log[#log]
end

function B:Clear()
    if EPC.saved then
        EPC.saved.bugCatcherLog = {}
        EPC.saved.bugCatcherUnread = 0
    end
    self.sessionCaught = 0
    self.lastCaughtText = nil
end

function B:PrintLast()
    local entry = self:GetLastError()
    if not entry then
        if EPC.Print then EPC:Print("Bug Catcher: no stored errors.") end
        return
    end
    if EPC.Print then
        EPC:Print(string.format("Bug Catcher last error [%s] %s (x%d):", tostring(entry.kind or "LUA"), tostring(entry.source or "Unknown"), tonumber(entry.count) or 1))
    end
    if type(d) == "function" then d(tostring(entry.text or ""))
    elseif EPC.Print then EPC:Print(tostring(entry.text or "")) end
    if EPC.saved then EPC.saved.bugCatcherUnread = 0 end
end

function B:PrintList()
    local log = self:GetLog()
    if #log == 0 then
        if EPC.Print then EPC:Print("Bug Catcher: no stored errors.") end
        return
    end
    if EPC.Print then EPC:Print(string.format("Bug Catcher: %d unique / %d total stored occurrences.", #log, self:GetTotalOccurrences())) end
    local first = math.max(1, #log - 4)
    for i = first, #log do
        local entry = log[i]
        local line = firstLine(entry.text)
        if #line > 150 then line = string.sub(line, 1, 147) .. "..." end
        if EPC.Print then EPC:Print(string.format("%d) [%s] %s x%d - %s", i, tostring(entry.kind or "LUA"), tostring(entry.source or "Unknown"), tonumber(entry.count) or 1, line)) end
    end
end

function B:GetStatusText()
    return string.format("Bug Catcher: %d unique errors, %d total occurrences, %d unread. Session: %d.",
        self:GetUniqueCount(), self:GetTotalOccurrences(), tonumber(EPC.saved and EPC.saved.bugCatcherUnread) or 0, tonumber(self.sessionCaught) or 0)
end

function B:TrimToLimit()
    local log = self:GetLog()
    local maxErrors = math.floor(tonumber(EPC.saved and EPC.saved.bugCatcherMaxErrors) or DEFAULT_MAX)
    maxErrors = math.max(10, math.min(100, maxErrors))
    while #log > maxErrors do table.remove(log, 1) end
end

local function addonStateLabel(state)
    local names = {
        "ADDON_STATE_ENABLED",
        "ADDON_STATE_DISABLED",
        "ADDON_STATE_MISSING",
        "ADDON_STATE_DEPENDENCIES_DISABLED",
        "ADDON_STATE_ERROR_STATE_UNABLE_TO_LOAD",
        "ADDON_STATE_VERSION_MISMATCH",
    }
    for _, globalName in ipairs(names) do
        local value = rawget(_G, globalName)
        if value ~= nil and state == value then
            return string.gsub(globalName, "^ADDON_STATE_", "")
        end
    end
    return tostring(state == nil and "UNKNOWN" or state)
end

local function addonStateLooksHealthy(state, enabled)
    local enabledState = rawget(_G, "ADDON_STATE_ENABLED")
    if enabledState ~= nil then return state == enabledState end
    -- If this client does not expose the enum, a successfully enabled addon is
    -- the best signal ESO gives us.
    return enabled == true
end

function B:RunScan()
    self:PruneIgnoredNoise()
    local log = self:GetLog()
    local grouped = {}
    local totalOccurrences = 0
    local historicalOccurrences = 0
    local currentSession = tostring(self.sessionId029123 or "")
    for _, entry in ipairs(log) do
        if type(entry) == "table" and tostring(entry.sessionId029123 or "") == currentSession then
            local source = tostring(entry.source or "Unknown source")
            local count = math.max(1, tonumber(entry.count) or 1)
            totalOccurrences = totalOccurrences + count
            local g = grouped[source]
            if not g then
                g = { source = source, unique = 0, total = 0, latest = 0, sample = "" }
                grouped[source] = g
            end
            g.unique = g.unique + 1
            g.total = g.total + count
            g.latest = math.max(g.latest, tonumber(entry.lastAt) or tonumber(entry.firstAt) or 0)
            if g.sample == "" then g.sample = firstLine(entry.text) end
        end
    end

    for _, entry in ipairs(log) do
        if type(entry) == "table" and tostring(entry.sessionId029123 or "") ~= currentSession then
            historicalOccurrences = historicalOccurrences + math.max(1, tonumber(entry.count) or 1)
        end
    end

    local errorSources = {}
    for _, g in pairs(grouped) do errorSources[#errorSources + 1] = g end
    table.sort(errorSources, function(a,b)
        if a.total ~= b.total then return a.total > b.total end
        return a.latest > b.latest
    end)

    local loadWarnings = {}
    if type(GetNumAddOns) == "function" and type(GetAddOnInfo) == "function" then
        local okCount, numAddons = pcall(GetNumAddOns)
        numAddons = okCount and tonumber(numAddons) or 0
        if numAddons then
            for i = 1, numAddons do
                local ok, name, title, author, description, enabled, state, isOutOfDate, isLibrary = pcall(GetAddOnInfo, i)
                if ok then
                    name = tostring(name or title or ("Addon " .. tostring(i)))
                    local badState = enabled == true and not addonStateLooksHealthy(state, enabled)
                    if badState or isOutOfDate == true then
                        loadWarnings[#loadWarnings + 1] = {
                            name = name,
                            state = addonStateLabel(state),
                            outOfDate = isOutOfDate == true,
                            badState = badState,
                        }
                    end
                end
            end
        end
    end

    if EPC.Print then
        if #errorSources == 0 and #loadWarnings == 0 then
            EPC:Print("EAS Scan: current session is clean; no captured runtime errors or addon load warnings found.")
        else
            EPC:Print(string.format("EAS Scan (current session): %d addon source(s) with captured errors, %d total occurrence(s), %d addon load warning(s).", #errorSources, totalOccurrences, #loadWarnings))
        end
        if historicalOccurrences > 0 then
            EPC:Print(string.format("Bug Catcher history: %d older stored occurrence(s) are retained but are not treated as current errors. Use /easbugs to review them or /easbugs clear to erase history.", historicalOccurrences))
        end

        local maxSources = math.min(8, #errorSources)
        for i = 1, maxSources do
            local g = errorSources[i]
            local sample = tostring(g.sample or "")
            if #sample > 105 then sample = string.sub(sample, 1, 102) .. "..." end
            EPC:Print(string.format("ERROR %d) %s - %d unique / %d total - %s", i, g.source, g.unique, g.total, sample))
        end
        if #errorSources > maxSources then
            EPC:Print(string.format("...and %d more error source(s). Use /easbugs to list recent errors.", #errorSources - maxSources))
        end

        local maxWarnings = math.min(8, #loadWarnings)
        for i = 1, maxWarnings do
            local w = loadWarnings[i]
            local detail = w.badState and ("state=" .. tostring(w.state)) or "state=enabled"
            if w.outOfDate then detail = detail .. ", out-of-date" end
            EPC:Print(string.format("ADDON %d) %s - %s", i, w.name, detail))
        end
        if #loadWarnings > maxWarnings then
            EPC:Print(string.format("...and %d more addon load warning(s).", #loadWarnings - maxWarnings))
        end
        EPC:Print("EAS Scan is a runtime health scan: it reports errors ESO has actually raised and addon load-state warnings; ESO does not allow one addon to statically compile/check every other addon's source files.")
    end

    return #errorSources, totalOccurrences, #loadWarnings
end


-- v0.29.467: safe Suite-wide self-test harness. This intentionally does not
-- blindly execute every addon function: many ESO functions are context-sensitive
-- or protected. Instead it validates module load state, required entry points,
-- dependencies, saved-variable integrity, known secure-action barriers, and a
-- small set of read-only smoke tests. Context-only tests are reported as SKIP.
local SELF_TEST_MODULES_029467 = {
    "AbilityOverlays", "ActiveQuest", "Activities", "ActivityRunHistory", "Advisor",
    "AlchemyPotionMaker", "AllianceRank", "AntiquityAssistant", "AntiquityLeadFinder",
    "AttributeOptimizer", "BattlegroundFinder", "BossMechanicsAssistant", "BugCatcher",
    "ChallengeDifficultyOverlay", "ChampionOptimizer", "ChampionOverlay", "CharacterGearScreen",
    "Clock", "Combat", "CombatPresentation", "CompanionOptimizer", "Compatibility", "Data",
    "DualActionBar", "DungeonChestFinder", "DungeonFinder", "DungeonHistory", "EncounterReminders",
    "Endgame", "EndgameMeta", "Engine", "FinderSuite", "GameModeReport", "GearLoadoutOverlay",
    "GearOptimizer", "GoldenPursuits", "InfiniteArchiveOverlay", "Journal", "LoadoutManager",
    "Maintenance", "MiniMap", "ModernAppUI", "PerformanceOverlay", "QuestFinder",
    "QuickslotOverlay", "RecipeStyleLearner", "RepairCostOverlay", "ResourcePins", "Reticle",
    "Role", "RotationAssistant", "SetJournal", "Settings", "SkillMeta", "StableTimer",
    "SynergyOverlay", "TargetBuild", "TeamVisibility", "TickTracker", "Travel", "TreasureLocator",
    "UI", "UnitFrames", "UtilitySuite", "WayshrineAutoMessage",
}

local SELF_TEST_METHODS_029467 = {
    {"MiniMap", "Initialize"}, {"MiniMap", "Refresh"}, {"MiniMap", "GetPlayerMarkerStyle"},
    {"ResourcePins", "Initialize"}, {"ResourcePins", "RefreshMarkers"}, {"ResourcePins", "GetStatusText"},
    {"CharacterGearScreen", "Initialize"}, {"CharacterGearScreen", "Refresh"}, {"CharacterGearScreen", "IsEnabled"},
    {"LoadoutManager", "Initialize"}, {"LoadoutManager", "RefreshUI"},
    {"UnitFrames", "Initialize"}, {"UnitFrames", "RefreshAll"},
    {"RotationAssistant", "Initialize"}, {"RotationAssistant", "Refresh"},
    {"QuickslotOverlay", "Initialize"}, {"QuickslotOverlay", "Refresh"},
    {"DualActionBar", "Initialize"}, {"DualActionBar", "Refresh"},
    {"TickTracker", "Initialize"}, {"TickTracker", "Refresh"},
    {"ActiveQuest", "Initialize"}, {"ActiveQuest", "Refresh"},
    {"Travel", "Initialize"}, {"Travel", "RefreshMapTeleporter"},
    {"AlchemyPotionMaker", "Initialize"},
    {"BugCatcher", "RunScan"}, {"BugCatcher", "BuildSelfTestReport029467"},
}

local function selfTestSceneShowing029467(name)
    if not SCENE_MANAGER or type(SCENE_MANAGER.GetScene) ~= "function" then return false end
    local ok, scene = pcall(SCENE_MANAGER.GetScene, SCENE_MANAGER, name)
    if not ok or not scene or type(scene.IsShowing) ~= "function" then return false end
    local ok2, showing = pcall(scene.IsShowing, scene)
    return ok2 and showing == true
end

local function selfTestCurrentSessionErrors029467(self)
    local unique, total = 0, 0
    local currentSession = tostring(self.sessionId029123 or "")
    for _, entry in ipairs(self:GetLog()) do
        if type(entry) == "table" and tostring(entry.sessionId029123 or "") == currentSession then
            unique = unique + 1
            total = total + math.max(1, tonumber(entry.count) or 1)
        end
    end
    return unique, total
end

function B:BuildSelfTestReport029467()
    self:PruneIgnoredNoise()
    local lines = {}
    local counts = { PASS=0, WARN=0, FAIL=0, SKIP=0 }
    local function add(status, label, detail)
        status = tostring(status or "WARN")
        counts[status] = (counts[status] or 0) + 1
        local line = string.format("[%s] %s", status, tostring(label or "Test"))
        if detail and tostring(detail) ~= "" then line = line .. " - " .. tostring(detail) end
        lines[#lines + 1] = line
    end

    lines[#lines + 1] = "=== ESO Adventurer Suite Self Test ==="
    lines[#lines + 1] = "Version: " .. tostring(EPC.version or "unknown")
    lines[#lines + 1] = "Session: " .. tostring(self.sessionId029123 or "unknown")

    add(type(EPC) == "table" and "PASS" or "FAIL", "Core namespace", type(EPC))
    add(type(EPC.saved) == "table" and "PASS" or "FAIL", "SavedVariables", type(EPC.saved))
    add(type(SLASH_COMMANDS) == "table" and "PASS" or "FAIL", "Slash command registry")
    add(type(EVENT_MANAGER) == "userdata" or type(EVENT_MANAGER) == "table" and "PASS" or "FAIL", "Event manager")

    local deps = {
        {"LibAddonMenu-2.0", rawget(_G, "LibAddonMenu2") or rawget(_G, "LibAddonMenu")},
        {"LibMapData", rawget(_G, "LibMapData")},
        {"LibGPS", rawget(_G, "LibGPS3") or rawget(_G, "LibGPS")},
        {"LibMapPins-1.0", rawget(_G, "LibMapPins")},
        {"LibMapPing", rawget(_G, "LibMapPing")},
        {"LibDebugLogger", rawget(_G, "LibDebugLogger")},
        {"LibChatMessage", rawget(_G, "LibChatMessage")},
        {"LibCustomMenu", rawget(_G, "LibCustomMenu") or rawget(_G, "LibCustomMenu2")},
    }
    for _, dep in ipairs(deps) do
        add(dep[2] ~= nil and "PASS" or "WARN", "Dependency " .. dep[1], dep[2] ~= nil and "loaded" or "not found in global namespace")
    end

    local missingModules = 0
    for _, name in ipairs(SELF_TEST_MODULES_029467) do
        local mod = EPC[name]
        if type(mod) == "table" then
            add("PASS", "Module " .. name, "loaded")
        else
            missingModules = missingModules + 1
            add("FAIL", "Module " .. name, "missing")
        end
    end

    local inv = rawget(_G, "EASInventoryGrid")
    add(type(inv) == "table" and "PASS" or "FAIL", "Module InventoryGrid", type(inv) == "table" and "loaded" or "missing")
    if type(inv) == "table" then
        add(type(inv.Refresh) == "function" and "PASS" or "FAIL", "InventoryGrid.Refresh")
        add(type(inv.RefreshNativeInteractionCategories029364) == "function" and "PASS" or "FAIL", "Inventory category refresh path")
        add(inv.nativeCategoryCommitHook029364 ~= true and "PASS" or "FAIL", "Skills security: global scroll-list hook", inv.nativeCategoryCommitHook029364 == true and "UNSAFE hook flag is active" or "not installed")
    end

    for _, spec in ipairs(SELF_TEST_METHODS_029467) do
        local mod = EPC[spec[1]]
        local fn = type(mod) == "table" and mod[spec[2]] or nil
        add(type(fn) == "function" and "PASS" or "FAIL", spec[1] .. "." .. spec[2], type(fn) == "function" and "available" or "missing")
    end

    local smc = EPC.SkillMorphCompare
    if type(smc) == "table" then
        add(smc.disabledForSecureSkills029453 == true and "PASS" or "WARN", "Skills security: morph compare barrier", smc.disabledForSecureSkills029453 == true and "native Skills controls untouched" or "secure barrier flag not confirmed")
    else
        add("WARN", "Skills security: morph compare barrier", "module table not present")
    end

    local function readOnlySmoke(label, object, method)
        if type(object) ~= "table" or type(object[method]) ~= "function" then
            add("FAIL", label, "method missing")
            return
        end
        local ok, result = pcall(object[method], object)
        if ok then
            local detail = result ~= nil and ("returned " .. tostring(result)) or "completed"
            if #detail > 120 then detail = string.sub(detail, 1, 117) .. "..." end
            add("PASS", label, detail)
        else
            add("FAIL", label, tostring(result))
        end
    end
    readOnlySmoke("Smoke: MiniMap marker style", EPC.MiniMap, "GetPlayerMarkerStyle")
    readOnlySmoke("Smoke: Character Gear enabled state", EPC.CharacterGearScreen, "IsEnabled")
    readOnlySmoke("Smoke: Resource Pins status", EPC.ResourcePins, "GetStatusText")
    readOnlySmoke("Smoke: Bug Catcher status", self, "GetStatusText")

    local bankOpen = selfTestSceneShowing029467("bank") or selfTestSceneShowing029467("guildBank") or selfTestSceneShowing029467("houseBank")
    if bankOpen then
        add(type(inv) == "table" and type(inv.RefreshNativeInteractionCategories029364) == "function" and "PASS" or "FAIL", "Context: Bank categories", "bank scene is open; refresh path available")
    else
        add("SKIP", "Context: Bank categories", "open a bank and rerun /eastestall")
    end

    local deconOpen = selfTestSceneShowing029467("smithing") or selfTestSceneShowing029467("universalDeconstruction")
    if deconOpen then
        add(type(inv) == "table" and type(inv.RefreshNativeInteractionCategories029364) == "function" and "PASS" or "FAIL", "Context: Deconstruction categories", "craft/decon scene is open; refresh path available")
    else
        add("SKIP", "Context: Deconstruction categories", "open deconstruction and rerun /eastestall")
    end

    local tradeOpen = selfTestSceneShowing029467("tradinghouse") or selfTestSceneShowing029467("trade")
    if tradeOpen then
        add(type(inv) == "table" and type(inv.RefreshNativeInteractionCategories029364) == "function" and "PASS" or "FAIL", "Context: Trader/Trade categories", "trade scene is open; refresh path available")
    else
        add("SKIP", "Context: Trader/Trade categories", "open a trader/trade window and rerun /eastestall")
    end

    if type(IsUnitInCombat) == "function" and IsUnitInCombat("player") == true then
        add(type(EPC.RotationAssistant) == "table" and "PASS" or "FAIL", "Context: Combat modules", "player is in combat")
    else
        add("SKIP", "Context: Combat modules", "enter combat and rerun for live combat context")
    end

    if type(IsUnitGrouped) == "function" and IsUnitGrouped("player") == true then
        add(type(EPC.TeamVisibility) == "table" and type(EPC.UnitFrames) == "table" and "PASS" or "FAIL", "Context: Group modules", "player is grouped")
    else
        add("SKIP", "Context: Group modules", "join a group and rerun for live group context")
    end

    local errorUnique, errorTotal = selfTestCurrentSessionErrors029467(self)
    if errorTotal == 0 then
        add("PASS", "Current-session runtime errors", "0 captured")
    else
        add("FAIL", "Current-session runtime errors", string.format("%d unique / %d total; use /easbugs last", errorUnique, errorTotal))
    end

    lines[#lines + 1] = string.format("SUMMARY: PASS=%d WARN=%d FAIL=%d SKIP=%d", counts.PASS or 0, counts.WARN or 0, counts.FAIL or 0, counts.SKIP or 0)
    if (counts.FAIL or 0) == 0 and (counts.WARN or 0) == 0 then
        lines[#lines + 1] = "RESULT: PASS"
    elseif (counts.FAIL or 0) == 0 then
        lines[#lines + 1] = "RESULT: PASS WITH WARNINGS/SKIPS"
    else
        lines[#lines + 1] = "RESULT: FAIL - copy this report and send it with /easbugs last if an error was captured."
    end
    lines[#lines + 1] = "NOTE: Protected or state-changing ESO actions are never auto-executed by this test. Context tests show SKIP until that UI/state is active."
    lines[#lines + 1] = "=== END REPORT ==="
    return table.concat(lines, "\n"), counts
end

function B:PrintSelfTest029467()
    local report = self:BuildSelfTestReport029467()
    if type(d) == "function" then
        for line in string.gmatch(report .. "\n", "([^\n]*)\n") do
            if line ~= "" then d(line) end
        end
    elseif EPC.Print then
        for line in string.gmatch(report .. "\n", "([^\n]*)\n") do
            if line ~= "" then EPC:Print(line) end
        end
    end
    self.lastSelfTestReport029467 = report
    return report
end

function B:ShowSelfTestCopyWindow029467(report)
    report = tostring(report or self.lastSelfTestReport029467 or self:BuildSelfTestReport029467())
    if not WINDOW_MANAGER or type(WINDOW_MANAGER.CreateTopLevelWindow) ~= "function" then
        if EPC.Print then EPC:Print("Self Test: copy window unavailable; report was printed to chat instead.") end
        return false
    end
    if not self.selfTestCopyWindow029467 then
        local wm = WINDOW_MANAGER
        local win = wm:CreateTopLevelWindow("EAS_SelfTestCopyWindow029467")
        win:SetDimensions(860, 620)
        win:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        win:SetDrawLayer(DL_OVERLAY)
        win:SetDrawLevel(100)
        win:SetMouseEnabled(true)
        win:SetMovable(true)
        win:SetClampedToScreen(true)

        local bg = wm:CreateControl("EAS_SelfTestCopyBG029467", win, CT_BACKDROP)
        bg:SetAnchorFill(win)
        bg:SetCenterColor(0.03, 0.03, 0.03, 0.97)
        bg:SetEdgeColor(0.75, 0.62, 0.22, 0.95)
        if bg.SetEdgeTexture then bg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-TooltipBorder.dds", 16, 4, 4) end

        local title = wm:CreateControl("EAS_SelfTestCopyTitle029467", win, CT_LABEL)
        title:SetFont("$(BOLD_FONT)|20|soft-shadow-thick")
        title:SetColor(1, 0.82, 0.20, 1)
        title:SetText("ESO Adventurer Suite - Self Test Report")
        title:SetAnchor(TOPLEFT, win, TOPLEFT, 16, 12)
        title:SetDimensions(700, 30)

        local hint = wm:CreateControl("EAS_SelfTestCopyHint029467", win, CT_LABEL)
        hint:SetFont("$(MEDIUM_FONT)|14|soft-shadow-thin")
        hint:SetColor(0.92, 0.92, 0.92, 1)
        hint:SetText("Click the report, press Ctrl+A, then Ctrl+C. Paste the complete report into ChatGPT.")
        hint:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 2)
        hint:SetDimensions(800, 24)

        local edit = wm:CreateControl("EAS_SelfTestCopyEdit029467", win, CT_EDITBOX)
        edit:SetAnchor(TOPLEFT, win, TOPLEFT, 16, 74)
        edit:SetDimensions(828, 488)
        edit:SetFont("ZoFontGameSmall")
        edit:SetColor(1, 1, 1, 1)
        if edit.SetMultiLine then edit:SetMultiLine(true) end
        if edit.SetMaxInputChars then edit:SetMaxInputChars(30000) end
        edit:SetMouseEnabled(true)
        if edit.SetKeyboardEnabled then edit:SetKeyboardEnabled(true) end
        if edit.SetCopyEnabled then edit:SetCopyEnabled(true) end
        if edit.SetPasteEnabled then edit:SetPasteEnabled(false) end

        local close = wm:CreateControl("EAS_SelfTestCopyClose029467", win, CT_BUTTON)
        close:SetDimensions(110, 32)
        close:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -16, -14)
        close:SetFont("ZoFontGame")
        close:SetText("CLOSE")
        close:SetHandler("OnClicked", function() win:SetHidden(true) end)

        self.selfTestCopyWindow029467 = win
        self.selfTestCopyEdit029467 = edit
    end
    self.selfTestCopyEdit029467:SetText(report)
    self.selfTestCopyWindow029467:SetHidden(false)
    if self.selfTestCopyEdit029467.TakeFocus then pcall(self.selfTestCopyEdit029467.TakeFocus, self.selfTestCopyEdit029467) end
    return true
end

function B:HandleSelfTestSlash029467(text)
    local arg = string.lower(tostring(text or ""))
    arg = string.match(arg, "^%s*(.-)%s*$") or ""
    local report = self:PrintSelfTest029467()
    if arg == "copy" or arg == "window" then
        self:ShowSelfTestCopyWindow029467(report)
    elseif arg ~= "" and arg ~= "run" then
        if EPC.Print then EPC:Print("Self Test commands: /eastestall or /eastestall copy") end
    end
end

function B:HandleSlash(text)
    local arg = string.lower(tostring(text or ""))
    arg = string.match(arg, "^%s*(.-)%s*$") or ""
    if arg == "clear" then
        self:Clear()
        if EPC.Print then EPC:Print("Bug Catcher log cleared.") end
    elseif arg == "last" or arg == "show" then
        self:PrintLast()
    elseif arg == "list" or arg == "" then
        self:PrintList()
    elseif arg == "status" then
        if EPC.Print then EPC:Print(self:GetStatusText()) end
    elseif arg == "scan" then
        self:RunScan()
    elseif arg == "test" or arg == "testall" then
        self:HandleSelfTestSlash029467("")
    elseif arg == "testcopy" or arg == "copytest" then
        self:HandleSelfTestSlash029467("copy")
    else
        if EPC.Print then EPC:Print("Bug Catcher commands: /easscan, /eastestall, /eastestall copy, /easbugs, /easbugs scan, /easbugs test, /easbugs last, /easbugs clear, /easbugs status") end
    end
end

function B:Initialize()
    self.ready = true
    self.sessionCaught = 0
    -- A scan should describe what is wrong NOW, not errors saved by older addon
    -- builds. History is retained for troubleshooting, but /easscan filters to
    -- this UI session.
    self.sessionId029123 = tostring(nowStamp()) .. ":" .. tostring(nowMs())
    if EPC.saved then
        EPC.saved.bugCatcherLog = EPC.saved.bugCatcherLog or {}
        if EPC.saved.bugCatcherMaxErrors == nil then EPC.saved.bugCatcherMaxErrors = DEFAULT_MAX end
        if EPC.saved.bugCatcherUnread == nil then EPC.saved.bugCatcherUnread = 0 end
        self:PruneIgnoredNoise()
        self:TrimToLimit()
    end

    local pending = self.pending or {}
    self.pending = {}
    for i = 1, #pending do
        local entry = pending[i]
        if type(entry) == "table" then self:Capture(entry.kind, entry.text, entry.stamp, entry.errorCode) end
    end

    SLASH_COMMANDS["/easbugs"] = function(text) self:HandleSlash(text) end
    SLASH_COMMANDS["/easscan"] = function() self:RunScan() end
    SLASH_COMMANDS["/eastestall"] = function(text) self:HandleSelfTestSlash029467(text) end
end

-- Register at file-load time so errors thrown by Suite files loaded after this
-- one can be captured before EPC:Initialize() creates SavedVariables.
local prefix = (EPC.name or "ESOAdventurerSuite") .. "_BugCatcher"
if EVENT_LUA_ERROR ~= nil and EVENT_MANAGER then
    EVENT_MANAGER:RegisterForEvent(prefix .. "_Lua", EVENT_LUA_ERROR, function(_, errorText, errorCode)
        if B.ready and EPC.saved then B:Capture("LUA", errorText, nil, errorCode)
        else B:StoreEarly("LUA", errorText, errorCode) end
    end)
end
if EVENT_SCRIPT_ACCESS_VIOLATION ~= nil and EVENT_MANAGER then
    EVENT_MANAGER:RegisterForEvent(prefix .. "_Protected", EVENT_SCRIPT_ACCESS_VIOLATION, function(_, protectedFunctionName)
        local text = "Protected function access violation: " .. tostring(protectedFunctionName or "unknown")
        if B.ready and EPC.saved then B:Capture("ACCESS", text)
        else B:StoreEarly("ACCESS", text) end
    end)
end
if EVENT_LUA_LOW_MEMORY ~= nil and EVENT_MANAGER then
    EVENT_MANAGER:RegisterForEvent(prefix .. "_Memory", EVENT_LUA_LOW_MEMORY, function()
        local text = "ESO reported low Lua memory."
        if B.ready and EPC.saved then B:Capture("MEMORY", text)
        else B:StoreEarly("MEMORY", text) end
    end)
end
