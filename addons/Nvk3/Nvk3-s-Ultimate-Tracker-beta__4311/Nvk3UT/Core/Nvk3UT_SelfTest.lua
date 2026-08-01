-- Core/Nvk3UT_SelfTest.lua
-- Lightweight sanity checks for Nvk3UT. This module must NOT touch UI, ESO events,
-- or SavedVariables creation. It can run very early, before the addon root exists.
-- TODO: Tracker UI presence tests from the legacy SelfTest touched live controls.
--       They will move into a future debug/inspector module once the UI layer is
--       refactored.
-- TODO: Legacy hooks/Recent verification relied on EVENT_MANAGER inspection.
--       Event wiring diagnostics will migrate into the dedicated Events layer.
-- TODO: Legacy recent count consistency checks depended on tracker state.
--       Those validations will move into Model/Runtime self-tests later.

Nvk3UT_SelfTest = Nvk3UT_SelfTest or {}
local SelfTest = Nvk3UT_SelfTest

-- Attach to the addon root when Core is ready without assuming it exists now.
function SelfTest.AttachToRoot(root)
    if type(root) ~= "table" then
        return
    end

    root.SelfTest = SelfTest
    return root.SelfTest
end

local function _format(fmt, ...)
    if fmt == nil then
        return ""
    end
    return string.format(tostring(fmt), ...)
end

-- Helper for safe logging without assuming Core is initialized
local function _debug(fmt, ...)
    if Nvk3UT and type(Nvk3UT.Debug) == "function" then
        Nvk3UT.Debug(fmt, ...)
    elseif Nvk3UT_Diagnostics and type(Nvk3UT_Diagnostics.Debug) == "function" then
        Nvk3UT_Diagnostics.Debug(fmt, ...)
    elseif type(d) == "function" then
        d(_format("[Nvk3UT SelfTest] %s", _format(fmt, ...)))
    end
end

local function _info(fmt, ...)
    if Nvk3UT_Diagnostics and type(Nvk3UT_Diagnostics.Warn) == "function" then
        Nvk3UT_Diagnostics.Warn(fmt, ...)
    elseif Nvk3UT and type(Nvk3UT.Warn) == "function" then
        Nvk3UT.Warn(fmt, ...)
    elseif type(d) == "function" then
        d(_format("[Nvk3UT SelfTest] %s", _format(fmt, ...)))
    end
end

local function _error(fmt, ...)
    if Nvk3UT and type(Nvk3UT.Error) == "function" then
        Nvk3UT.Error(fmt, ...)
    elseif Nvk3UT_Diagnostics and type(Nvk3UT_Diagnostics.Error) == "function" then
        Nvk3UT_Diagnostics.Error(fmt, ...)
    elseif type(d) == "function" then
        d(_format("|cFF0000[Nvk3UT SelfTest ERROR]|r %s", _format(fmt, ...)))
    end
end

local function _newResults()
    return { passed = 0, failed = 0, skipped = 0 }
end

local function _runCheck(results, name, fn)
    local ok, status, detail = pcall(fn)
    if not ok then
        results.failed = results.failed + 1
        _error("%s check threw error: %s", name, tostring(status))
        return
    end

    if status == nil then
        results.skipped = results.skipped + 1
        _info("%s check skipped%s", name, detail and (": " .. detail) or "")
        return
    end

    if status then
        results.passed = results.passed + 1
        _info("%s check ok%s", name, detail and (": " .. detail) or "")
    else
        results.failed = results.failed + 1
        _error("%s check failed: %s", name, detail or "no details provided")
    end
end

local function checkEnvironment()
    local missing = {}
    if EVENT_MANAGER == nil then
        missing[#missing + 1] = "EVENT_MANAGER"
    end
    if ZO_SavedVars == nil then
        missing[#missing + 1] = "ZO_SavedVars"
    end

    if #missing > 0 then
        return false, "Missing globals: " .. table.concat(missing, ", ")
    end

    return true, "Core game APIs available"
end

local function checkDiagnosticsModule()
    if type(Nvk3UT_Diagnostics) ~= "table" then
        return false, "Nvk3UT_Diagnostics table missing"
    end

    local missing = {}
    local required = { "Debug", "Warn", "Error", "SetDebugEnabled" }
    for _, fnName in ipairs(required) do
        if type(Nvk3UT_Diagnostics[fnName]) ~= "function" then
            missing[#missing + 1] = fnName
        end
    end

    if #missing > 0 then
        return false, "Diagnostics missing API: " .. table.concat(missing, ", ")
    end

    return true, "Diagnostics module ready"
end

local function checkUtilsModule()
    if type(Nvk3UT_Utils) ~= "table" then
        return false, "Nvk3UT_Utils table missing"
    end

    local required = { "AttachToRoot", "Debug", "Now" }
    local missing = {}
    for _, fnName in ipairs(required) do
        if type(Nvk3UT_Utils[fnName]) ~= "function" then
            missing[#missing + 1] = fnName
        end
    end

    if #missing > 0 then
        return false, "Utils missing helpers: " .. table.concat(missing, ", ")
    end

    return true, "Utils module exposed expected helpers"
end

local function checkAddonTable()
    if type(Nvk3UT) ~= "table" then
        return nil, "Addon root not initialized yet"
    end

    local missing = {}
    if type(Nvk3UT.SafeCall) ~= "function" then
        missing[#missing + 1] = "SafeCall"
    end
    if type(Nvk3UT.RegisterModule) ~= "function" then
        missing[#missing + 1] = "RegisterModule"
    end
    if type(Nvk3UT.InitSavedVariables) ~= "function" then
        missing[#missing + 1] = "InitSavedVariables"
    end

    if #missing > 0 then
        return false, "Addon root missing functions: " .. table.concat(missing, ", ")
    end

    return true, "Addon root initialized"
end

local function checkSavedVariables()
    if type(Nvk3UT) ~= "table" then
        return nil, "Addon root missing; cannot inspect SavedVariables"
    end

    local sv = rawget(Nvk3UT, "SV")
    if sv == nil then
        return nil, "SavedVariables not initialized yet"
    end

    if type(sv) ~= "table" then
        return false, "Nvk3UT.SV is not a table"
    end

    local general = sv.General
    local questTracker = sv.QuestTracker
    local achievementTracker = sv.AchievementTracker
    local appearance = sv.appearance

    local missing = {}
    if type(general) ~= "table" then
        missing[#missing + 1] = "General"
    end
    if type(questTracker) ~= "table" then
        missing[#missing + 1] = "QuestTracker"
    end
    if type(achievementTracker) ~= "table" then
        missing[#missing + 1] = "AchievementTracker"
    end
    if type(appearance) ~= "table" then
        missing[#missing + 1] = "appearance"
    end

    if #missing > 0 then
        return false, "SavedVariables missing tables: " .. table.concat(missing, ", ")
    end

    if rawget(Nvk3UT, "sv") ~= sv then
        return false, "Legacy alias Nvk3UT.sv not pointing at Nvk3UT.SV"
    end

    return true, "SavedVariables structure looks sane"
end

local function checkFavoritesData()
    if type(Nvk3UT) ~= "table" then
        return nil, "Addon root missing; cannot inspect favorites data"
    end

    local data = Nvk3UT.FavoritesData
    if type(data) ~= "table" then
        return false, "FavoritesData module missing"
    end

    local required = { "InitSavedVars", "IsFavorited", "SetFavorited", "ToggleFavorited", "GetAllFavorites" }
    local missing = {}
    for _, fnName in ipairs(required) do
        if type(data[fnName]) ~= "function" then
            missing[#missing + 1] = fnName
        end
    end

    if #missing > 0 then
        return false, "FavoritesData missing API: " .. table.concat(missing, ", ")
    end

    local accountSV = rawget(_G, "Nvk3UT_Data_Favorites_Account")
    local characterSV = rawget(_G, "Nvk3UT_Data_Favorites_Characters")
    if accountSV == nil or characterSV == nil then
        return nil, "Favorites SavedVariables not initialized yet"
    end

    return true, "FavoritesData ready"
end

local function checkRecentData()
    if type(Nvk3UT) ~= "table" then
        return nil, "Addon root missing; cannot inspect recent data"
    end

    local data = Nvk3UT.RecentData
    if type(data) ~= "table" then
        return false, "RecentData module missing"
    end

    local required = { "InitSavedVars", "ListConfigured", "CountConfigured" }
    local missing = {}
    for _, fnName in ipairs(required) do
        if type(data[fnName]) ~= "function" then
            missing[#missing + 1] = fnName
        end
    end

    if #missing > 0 then
        return false, "RecentData missing API: " .. table.concat(missing, ", ")
    end

    local sv = rawget(_G, "Nvk3UT_Data_Recent")
    if type(sv) ~= "table" then
        return nil, "Recent SavedVariables not initialized yet"
    end

    return true, "RecentData ready"
end

local function summarize(results)
    _info(
        "SelfTest summary: passed=%d, skipped=%d, failed=%d",
        results.passed,
        results.skipped,
        results.failed
    )
    if results.failed > 0 then
        _error("SelfTest detected %d failing checks", results.failed)
    end
end

local function getAddonRoot()
    local root = rawget(_G, "Nvk3UT")
    if type(root) == "table" then
        return root
    end

    if type(Nvk3UT) == "table" then
        return Nvk3UT
    end

    return nil
end

local function ensureBoolean(value)
    return value == true
end

local function checkGoldenStateStatus()
    local root = getAddonRoot()
    if type(root) ~= "table" then
        return nil, "Addon root not initialized; Golden modules unavailable"
    end

    local goldenState = rawget(root, "GoldenState")
    if type(goldenState) ~= "table" or type(goldenState.GetSystemStatus) ~= "function" then
        return false, "GoldenState module missing or does not expose GetSystemStatus"
    end

    local ok, status = pcall(goldenState.GetSystemStatus, goldenState)
    if not ok then
        return false, "GoldenState:GetSystemStatus threw: " .. tostring(status)
    end

    if type(status) ~= "table" then
        return false, "GoldenState:GetSystemStatus returned a non-table value"
    end

    local isAvailable = ensureBoolean(status.isAvailable)
    local isLocked = ensureBoolean(status.isLocked)
    local hasEntries = ensureBoolean(status.hasEntries)

    if isLocked and isAvailable then
        return false, string.format("State inconsistent: locked=true but available=true")
    end

    if not isAvailable and hasEntries then
        return false, "State inconsistent: hasEntries=true while available=false"
    end

    if isLocked and hasEntries then
        return false, "State inconsistent: locked=true while hasEntries=true"
    end

    return true, string.format(
        "GoldenState status ok (available=%s locked=%s hasEntries=%s)",
        tostring(isAvailable),
        tostring(isLocked),
        tostring(hasEntries)
    )
end

local function checkGoldenModelSafeReturns()
    local root = getAddonRoot()
    if type(root) ~= "table" then
        return nil, "Addon root not initialized; Golden modules unavailable"
    end

    local goldenModel = rawget(root, "GoldenModel")
    if type(goldenModel) ~= "table" then
        return false, "GoldenModel module missing"
    end

    local goldenList = rawget(root, "GoldenList")
    if type(goldenList) ~= "table" then
        return false, "GoldenList module missing"
    end

    local okRaw, rawData = pcall(goldenModel.GetRawData, goldenModel)
    if not okRaw then
        return false, "GoldenModel:GetRawData threw: " .. tostring(rawData)
    end

    if type(rawData) ~= "table" or type(rawData.categories) ~= "table" then
        return false, "GoldenModel:GetRawData did not return categories table"
    end

    local okView, viewData = pcall(goldenModel.GetViewData, goldenModel)
    if not okView then
        return false, "GoldenModel:GetViewData threw: " .. tostring(viewData)
    end

    if type(viewData) ~= "table" or type(viewData.categories) ~= "table" then
        return false, "GoldenModel:GetViewData did not return categories table"
    end

    local okCounters, counters = pcall(goldenModel.GetCounters, goldenModel)
    if not okCounters then
        return false, "GoldenModel:GetCounters threw: " .. tostring(counters)
    end

    if type(counters) ~= "table" then
        return false, "GoldenModel:GetCounters did not return a table"
    end

    if counters.campaignCount == nil or counters.completedActivities == nil or counters.totalActivities == nil then
        return false, "GoldenModel:GetCounters missing campaign/activities fields"
    end

    local okStatus, status = pcall(goldenModel.GetSystemStatus, goldenModel)
    if not okStatus then
        return false, "GoldenModel:GetSystemStatus threw: " .. tostring(status)
    end

    if type(status) ~= "table" then
        return false, "GoldenModel:GetSystemStatus did not return a table"
    end

    local okListRaw, listRaw = pcall(goldenList.GetRawData, goldenList)
    if not okListRaw then
        return false, "GoldenList:GetRawData threw: " .. tostring(listRaw)
    end

    if type(listRaw) ~= "table" or type(listRaw.categories) ~= "table" then
        return false, "GoldenList:GetRawData did not return categories table"
    end

    for index = 1, #listRaw.categories do
        local category = listRaw.categories[index]
        if type(category) ~= "table" or type(category.entries) ~= "table" then
            return false, string.format("GoldenList category %d missing entries table", index)
        end
    end

    local okIsEmpty, isEmpty = pcall(goldenList.IsEmpty, goldenList)
    if not okIsEmpty then
        return false, "GoldenList:IsEmpty threw: " .. tostring(isEmpty)
    end

    if type(isEmpty) ~= "boolean" then
        return false, "GoldenList:IsEmpty did not return boolean"
    end

    return true, string.format(
        "GoldenModel safe returns ok (categories=%d viewCategories=%d listCategories=%d)",
        #rawData.categories,
        #viewData.categories,
        #listRaw.categories
    )
end

local function checkGoldenViewModelStructure()
    local root = getAddonRoot()
    if type(root) ~= "table" then
        return nil, "Addon root not initialized; Golden modules unavailable"
    end

    local controller = rawget(root, "GoldenTrackerController")
    if type(controller) ~= "table" or type(controller.BuildViewModel) ~= "function" then
        return false, "GoldenTrackerController missing or does not expose BuildViewModel"
    end

    local okVm, viewModel = pcall(controller.BuildViewModel, controller)
    if not okVm then
        return false, "GoldenTrackerController:BuildViewModel threw: " .. tostring(viewModel)
    end

    if type(viewModel) ~= "table" then
        return false, "BuildViewModel did not return a table"
    end

    local categories = viewModel.categories
    if type(categories) ~= "table" then
        return false, "ViewModel missing categories table"
    end

    local status = viewModel.status
    if type(status) ~= "table" then
        return false, "ViewModel missing status table"
    end

    local header = viewModel.header
    if header ~= nil and type(header) ~= "table" then
        return false, "ViewModel header is not a table"
    end

    local summary = viewModel.summary
    if summary ~= nil and type(summary) ~= "table" then
        return false, "ViewModel summary is not a table"
    end

    if type(summary) == "table" then
        if summary.campaignCount == nil or summary.totalEntries == nil or summary.totalCompleted == nil or summary.totalRemaining == nil then
            return false, "ViewModel summary missing campaign/activity totals"
        end
    end

    local stateStatus
    local goldenState = rawget(root, "GoldenState")
    if type(goldenState) == "table" and type(goldenState.GetSystemStatus) == "function" then
        local okStatus, resolved = pcall(goldenState.GetSystemStatus, goldenState)
        if okStatus and type(resolved) == "table" then
            stateStatus = resolved
        end
    end

    if stateStatus then
        local stateAvailable = ensureBoolean(stateStatus.isAvailable)
        local stateLocked = ensureBoolean(stateStatus.isLocked)
        local stateHasEntries = ensureBoolean(stateStatus.hasEntries)

        if stateAvailable ~= ensureBoolean(status.isAvailable)
            or stateLocked ~= ensureBoolean(status.isLocked)
            or stateHasEntries ~= ensureBoolean(status.hasEntries) then
            return false, string.format(
                "ViewModel status mismatch (state avail=%s locked=%s entries=%s vs vm avail=%s locked=%s entries=%s)",
                tostring(stateAvailable),
                tostring(stateLocked),
                tostring(stateHasEntries),
                tostring(ensureBoolean(status.isAvailable)),
                tostring(ensureBoolean(status.isLocked)),
                tostring(ensureBoolean(status.hasEntries))
            )
        end
    end

    local totalEntries = 0
    local firstCategoryWithEntries
    local firstEntry

    for index = 1, #categories do
        local category = categories[index]
        if type(category) ~= "table" then
            return false, string.format("Category %d is not a table", index)
        end

        if type(category.entries) ~= "table" then
            return false, string.format("Category %d missing entries table", index)
        end

        totalEntries = totalEntries + #category.entries
        if not firstCategoryWithEntries and #category.entries > 0 then
            firstCategoryWithEntries = category
            firstEntry = category.entries[1]
        end
    end

    local hasEntries = ensureBoolean(status.hasEntries)
    if hasEntries and (not firstCategoryWithEntries or type(firstEntry) ~= "table") then
        return false, "ViewModel reports entries but no entry data present"
    end

    if hasEntries then
        if type(firstEntry.entryId) ~= "string" or firstEntry.entryId == "" then
            return false, "First Golden entry missing entryId"
        end

        if type(firstEntry.title) ~= "string" then
            return false, "First Golden entry missing title"
        end

        if type(firstEntry.objectives) ~= "table" then
            return false, "First Golden entry missing objectives table"
        end
    else
        if totalEntries > 0 then
            return false, string.format("ViewModel marked empty but contains %d entries", totalEntries)
        end
    end

    local campaignCount = type(summary) == "table" and (summary.campaignCount or #categories) or #categories

    return true, string.format(
        "Golden VM ok (campaigns=%d categories=%d entries=%d hasEntries=%s)",
        campaignCount,
        #categories,
        totalEntries,
        tostring(hasEntries)
    )
end

-- Main entry point: safe to call via Nvk3UT.SafeCall
function SelfTest.RunCoreSanityCheck()
    local results = _newResults()

    _info("Running core self tests...")

    _runCheck(results, "Environment", checkEnvironment)
    _runCheck(results, "Diagnostics", checkDiagnosticsModule)
    _runCheck(results, "Utils", checkUtilsModule)
    _runCheck(results, "AddonTable", checkAddonTable)
    _runCheck(results, "SavedVariables", checkSavedVariables)
    _runCheck(results, "FavoritesData", checkFavoritesData)
    _runCheck(results, "RecentData", checkRecentData)
    _runCheck(results, "GoldenState", checkGoldenStateStatus)
    _runCheck(results, "GoldenModel", checkGoldenModelSafeReturns)
    _runCheck(results, "GoldenViewModel", checkGoldenViewModelStructure)

    summarize(results)

    return results
end

-- Backward compatibility for legacy callers that used Nvk3UT.SelfTest.Run()
if not SelfTest.Run then
    function SelfTest.Run()
        local function execute()
            return SelfTest.RunCoreSanityCheck()
        end

        if Nvk3UT and type(Nvk3UT.SafeCall) == "function" then
            return Nvk3UT.SafeCall(execute)
        end

        local ok, result = pcall(execute)
        if not ok then
            _error("SelfTest execution failed: %s", tostring(result))
            return nil
        end

        return result
    end
end

-- If the addon root already exists (e.g., in reload scenarios), attach immediately.
if type(Nvk3UT) == "table" then
    SelfTest.AttachToRoot(Nvk3UT)
end

return SelfTest
