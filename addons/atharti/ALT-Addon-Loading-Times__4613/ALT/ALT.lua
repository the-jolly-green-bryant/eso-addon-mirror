AddonLoadingTimes = {}

local ALT = AddonLoadingTimes
local EM = EVENT_MANAGER
local LEJ = LibExtendedJournal

ALT.name = "ALT"

ZO_CreateStringId("SI_BINDING_NAME_ALT_INTERRUPT", "Interrupt the Test")

local PROTECTED_ADDONS = {
    ["ALT"] = true,
    ["LibAddonMenu-2.0"] = true,
    ["LibExtendedJournal"] = true,
}

local defaultSV = {
    results = {},     
    testActive = false,
    testPhase = "IDLE",
    testStep = 0, 
    testQueue = {}, 
    currentTestAddon = nil,
    baselineTime = nil,
    baselineMemory = nil,  
    firstBaselineTime = nil,
    firstBaselineMemory = nil,
    secondBaselineTime = nil,  
    secondBaselineMemory = nil,
    reloadDelay = 1,
    originalState = {}, 
    showResults = false,
    lastReloadStartTime = nil,
    pendingMessage = nil, 
    testStartTime = 0,
    testDuration = 0,
	savedFilter = nil,
}

-- =========================================================
-- Addon Data Collection & Dependency Graphing
-- =========================================================

function ALT.BuildDependencyGraph()
    ALT.DependencyGraph = {
        dependsOn = {},
        dependedBy = {}
    }

    for name, data in pairs(ALT.AddonsData) do
        ALT.DependencyGraph.dependsOn[name] = {}

        for _, dep in ipairs(data.dependencies) do
            table.insert(ALT.DependencyGraph.dependsOn[name], dep)
        end

        ALT.DependencyGraph.dependedBy[name] = {}
    end

    for name, deps in pairs(ALT.DependencyGraph.dependsOn) do
        for _, depName in ipairs(deps) do
            local matchedKey = nil
            for key, _ in pairs(ALT.DependencyGraph.dependedBy) do
                if key and depName and key:lower() == depName:lower() then
                    matchedKey = key
                    break
                end
            end
            if matchedKey then
                if not ALT.DependencyGraph.dependedBy[matchedKey] then
                    ALT.DependencyGraph.dependedBy[matchedKey] = {}
                end
                table.insert(ALT.DependencyGraph.dependedBy[matchedKey], name)
            else
                if not ALT.DependencyGraph.dependedBy[depName] then
                    ALT.DependencyGraph.dependedBy[depName] = {}
                end
                table.insert(ALT.DependencyGraph.dependedBy[depName], name)
            end
        end
    end
end

function ALT.GetAllDependents(addonName, includeSelf)
    local visited = {}
    local result = {}
    
    local function findDependents(name)
        if visited[name] then return end
        visited[name] = true
        
        local dependents = ALT.DependencyGraph.dependedBy[name] or {}
        for _, dependent in ipairs(dependents) do
            if not visited[dependent] then
                table.insert(result, dependent)
                findDependents(dependent)
            end
        end
    end
    
    if includeSelf then
        table.insert(result, addonName)
    end
    
    findDependents(addonName)
    return result
end

function ALT.GetTestableAddons()
    local testableAddons = {}
    
    for name, data in pairs(ALT.AddonsData) do
        if data.isLibrary ~= true and name ~= ALT.name and not PROTECTED_ADDONS[name] then
            if ALT.Settings.originalState[name] then
                local deps = ALT.DependencyGraph.dependsOn[name] or {}
                local hasNonLibDependencies = false
                
                for _, dep in ipairs(deps) do
                    if ALT.AddonsData[dep] and ALT.AddonsData[dep].isLibrary ~= true then
                        hasNonLibDependencies = true
                        break
                    end
                end
                
                if not hasNonLibDependencies then
                    table.insert(testableAddons, name)
                end
            end
        end
    end
    
    return testableAddons
end

function ALT.ResolveAddonTestGroup(testAddonName)
    local group = {}
    local visited = {}
    
    local function addDependencies(name)
        local deps = ALT.DependencyGraph.dependsOn[name] or {}
        for _, dep in ipairs(deps) do
            if not visited[dep] and not PROTECTED_ADDONS[dep] then
                visited[dep] = true
                group[dep] = true
                addDependencies(dep)
            end
        end
    end

    if ALT.Settings.originalState[testAddonName] then
        group[testAddonName] = true
        visited[testAddonName] = true
        addDependencies(testAddonName)
    end
    
    local dependents = ALT.GetAllDependents(testAddonName, false)
    for _, dep in ipairs(dependents) do
        if not visited[dep] and not PROTECTED_ADDONS[dep] then
            if ALT.Settings.originalState[dep] then
                group[dep] = true
                visited[dep] = true
                addDependencies(dep)
            end
        end
    end
    
    local result = {}
    for name, _ in pairs(group) do
        table.insert(result, name)
    end
    
    return result
end

function ALT.CollectAddonsData()
    local addonManager = GetAddOnManager()
    local numAddons = addonManager:GetNumAddOns()
    ALT.AddonsData = {}
    for i = 1, numAddons do
        local name, title, author, description, enabled, state, isOutOfDate, isLibrary = addonManager:GetAddOnInfo(i)
        if name then
            local dependencies = {}
            local numDeps = addonManager:GetAddOnNumDependencies(i)
            for j = 1, numDeps do
                local depName, exists, active = addonManager:GetAddOnDependencyInfo(i, j)
                if exists then table.insert(dependencies, depName) end
            end
            ALT.AddonsData[name] = {
                index = i,
                title = title,
                isLibrary = isLibrary,
                dependencies = dependencies,
                enabled = enabled,
            }
        end
    end
end

-- =========================================================
-- State Control and Reloader Helpers
-- =========================================================

local function SafeReloadUI()
    ALT.Settings.lastReloadStartTime = GetGameTimeMilliseconds()
    local delay = (ALT.Settings.reloadDelay or 1) * 1000
    if delay == 0 then
        ReloadUI()
    else
        zo_callLater(function() ReloadUI() end, delay)
    end
end

function ALT.GetAddonIndex(addonName)
    local addonManager = GetAddOnManager()
    local numAddons = addonManager:GetNumAddOns()
    for i = 1, numAddons do
        local name = addonManager:GetAddOnInfo(i)
        if name == addonName then
            return i
        end
    end
    return nil
end


function ALT.ExecuteWithSavedFilter(func)
    local addonManager = GetAddOnManager()
    local initialFilter = addonManager:GetAddOnFilter()
    
    addonManager:SetAddOnFilter(ALT.Settings.savedFilter)
    func(addonManager)
    addonManager:SetAddOnFilter(initialFilter)
end

-- =========================================================
-- Test Controller
-- =========================================================

function ALT.StartTest()
    ALT.ClearTestData()

    ALT.ExecuteWithSavedFilter(function(addonManager)
        ALT.CollectAddonsData()
        ALT.BuildDependencyGraph()

        ALT.Settings.originalState = {}
        for name, data in pairs(ALT.AddonsData) do
            ALT.Settings.originalState[name] = data.enabled
        end

        local testableAddons = ALT.GetTestableAddons()
        for _, name in ipairs(testableAddons) do
            table.insert(ALT.Settings.testQueue, name)
        end

        if #ALT.Settings.testQueue == 0 then
            d("[" .. ALT.name .. "] No testable addons found.")
            return
        end

        ALT.Settings.testActive = true
        ALT.Settings.testStep = 1
        ALT.Settings.testPhase = "INIT_DISABLE"
        ALT.Settings.pendingMessage = "[" .. ALT.name .. "] Disabling all addons..."
        ALT.Settings.testStartTime = GetTimeStamp()

        for name, data in pairs(ALT.AddonsData) do
            if not PROTECTED_ADDONS[name] and not data.isLibrary then
                addonManager:SetAddOnEnabled(data.index, false)
            end
        end
    end)

    SafeReloadUI()
end

function ALT.OnTestPlayerActivated(eventCode, initial)
    local currentTime = GetGameTimeMilliseconds()
    local loadTime = currentTime - (ALT.Settings.lastReloadStartTime or currentTime)
    local currentMemory = collectgarbage("count")
    
    if ALT.Settings.pendingMessage then
        d(ALT.Settings.pendingMessage)
        ALT.Settings.pendingMessage = nil
    end
    
    local phase = ALT.Settings.testPhase
    
    if phase == "INIT_DISABLE" then
        ALT.Settings.testPhase = "MEASURE_BASELINE_1"
        ALT.Settings.pendingMessage = "[" .. ALT.name .. "] Measuring baseline #1..."
        SafeReloadUI()
        
    elseif phase == "MEASURE_BASELINE_1" then
        ALT.Settings.firstBaselineTime = loadTime
        ALT.Settings.firstBaselineMemory = currentMemory
        
        ALT.Settings.testPhase = "MEASURE_BASELINE_2"
        ALT.Settings.pendingMessage = "[" .. ALT.name .. "] Purifying... Measuring baseline #2..."
        SafeReloadUI()
        
    elseif phase == "MEASURE_BASELINE_2" then
        ALT.Settings.secondBaselineTime = loadTime
        ALT.Settings.secondBaselineMemory = currentMemory
        
        ALT.Settings.testPhase = "MEASURE_BASELINE_3"
        ALT.Settings.pendingMessage = "[" .. ALT.name .. "] Double purifying... Measuring baseline #3..."
        SafeReloadUI()
        
    elseif phase == "MEASURE_BASELINE_3" then
        local b1Time = ALT.Settings.firstBaselineTime
        local b1Mem = ALT.Settings.firstBaselineMemory
        local b2Time = ALT.Settings.secondBaselineTime
        local b2Mem = ALT.Settings.secondBaselineMemory
        
        ALT.Settings.baselineTime = math.min(b1Time, b2Time, loadTime)
        ALT.Settings.baselineMemory = math.min(b1Mem, b2Mem, currentMemory)
        
        ALT.Settings.testStep = 1
        ALT.Settings.testPhase = "TEST_MEASURE"
        ALT.RunQueueStep()
        
    elseif phase == "TEST_MEASURE" then
        local addonName = ALT.Settings.currentTestAddon
        local timeDelta = loadTime - ALT.Settings.baselineTime
        local memoryDelta = currentMemory - ALT.Settings.baselineMemory
        
        ALT.Settings.results[addonName] = {
            time = timeDelta,
            memory = memoryDelta
        }
        
        ALT.Settings.testStep = ALT.Settings.testStep + 1
        ALT.RunQueueStep()
    end
end

function ALT.RunQueueStep()
    local queue = ALT.Settings.testQueue
    local step = ALT.Settings.testStep
    
    ALT.CollectAddonsData()
    ALT.BuildDependencyGraph()

    ALT.ExecuteWithSavedFilter(function(addonManager)
        local previousAddon = ALT.Settings.currentTestAddon
        if previousAddon then
            local oldGroup = ALT.ResolveAddonTestGroup(previousAddon)
            for _, name in ipairs(oldGroup) do
                local addonInfo = ALT.AddonsData[name]
                if addonInfo and not addonInfo.isLibrary then
                    local index = ALT.GetAddonIndex(name)
                    if index then
                        addonManager:SetAddOnEnabled(index, false)
                    end
                end
            end
        end

        if step > #queue then
            return
        end
        
        local nextAddon = queue[step]
        ALT.Settings.currentTestAddon = nextAddon
        
        ALT.Settings.pendingMessage = string.format("[%s] Testing: %d/%d: %s", ALT.name, step, #queue, nextAddon)
        
        local newGroup = ALT.ResolveAddonTestGroup(nextAddon)
        for _, name in ipairs(newGroup) do
            local index = ALT.GetAddonIndex(name)
            if index then
                addonManager:SetAddOnEnabled(index, true)
            end
        end
    end)

    if step > #queue then
        ALT.EndTest()
        return
    end
    
    SafeReloadUI()
end

function ALT.EndTest()    
    ALT.ExecuteWithSavedFilter(function(addonManager)
        for name, wasEnabled in pairs(ALT.Settings.originalState) do
            local index = ALT.GetAddonIndex(name)
            if index then
                addonManager:SetAddOnEnabled(index, wasEnabled)
            end
        end
    end)
    
    if ALT.Settings.testStartTime and ALT.Settings.testStartTime > 0 then
        ALT.Settings.testDuration = math.max(0, GetTimeStamp() - ALT.Settings.testStartTime)
    else
        ALT.Settings.testDuration = 0
    end
    
    ALT.Settings.pendingMessage = "[" .. ALT.name .. "] Test Completed! Re-enabling all addons..."
    
    ALT.Settings.testActive = false
    ALT.Settings.testPhase = "IDLE"
    ALT.Settings.showResults = true
    
    ALT.Settings.testQueue = nil
    ALT.Settings.currentTestAddon = nil
    ALT.Settings.lastReloadStartTime = nil
    ALT.Settings.testStep = nil
    ALT.Settings.testStartTime = nil
    
    ALT.Settings.firstBaselineTime = nil
    ALT.Settings.firstBaselineMemory = nil
    ALT.Settings.secondBaselineTime = nil
    ALT.Settings.secondBaselineMemory = nil
    ALT.Settings.savedFilter = nil

    EM:UnregisterForEvent(ALT.name .. "_Test", EVENT_PLAYER_ACTIVATED)
    SafeReloadUI()
end

-- =========================================================
-- Dialog and Setup Panels
-- =========================================================

function ALT.RegisterConfirmationDialog()
    ZO_CreateStringId("ALT_DIALOG_HEADER", "Addon Loading Times")

    ESO_Dialogs["ALT_CONFIRMATION_DIALOG"] = {
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title = {
            text = ALT_DIALOG_HEADER,
        },
        mainText = {
            text = function(dialog)
                return dialog.data.mainText
            end,
        },
        mustChoose = true,
        buttons = {
            [1] = {
                text = SI_DIALOG_ACCEPT,
                callback = function(dialog)
                    if dialog.data.callback then
                        dialog.data.callback()
                    end
                end,
            },
            [2] = {
                text = SI_DIALOG_CANCEL,
            },
        },
    }
end

function ALT.ShowTestConfirmationDialog()
    local addonManager = GetAddOnManager()

    ALT.Settings.savedFilter = addonManager:GetAddOnFilter()

    ALT.ExecuteWithSavedFilter(function()
        ALT.CollectAddonsData()
        ALT.BuildDependencyGraph()
    end)

    ALT.Settings.originalState = {}
    for name, data in pairs(ALT.AddonsData) do
        ALT.Settings.originalState[name] = data.enabled
    end

    local testableAddons = ALT.GetTestableAddons()
    local addonCount = #testableAddons
        
    local reloadDelay = ALT.Settings.reloadDelay or 1
    
    local warningText = string.format(
        "|cFFAA44WARNING!|r\n\n" ..
        "You have |cFFFFFF%d|r addons to test.\n\n" ..
        "|cFFAA44Important:|r\n" ..
        "• Move your character to a small location (tavern room without any furnishings) to minimize hardware impact.\n\n" ..
        "• If you got too many addons |cFFFFFF(>40)|r consider increasing Reload Delay to at least |cFFFFFF2|r seconds, so you can move your character from time to time to prevent AFK-timeout.\n\n" ..
        "• Current Reload Delay: |cFFFFFF%.1f|r seconds.\n\n" ..
        "Do you want to proceed?",
        addonCount, reloadDelay
    )
    
    local dialogParams = {
        callback = function()
            ALT.StartTest()
        end,
        mainText = warningText
    }
    
    ZO_Dialogs_ShowDialog("ALT_CONFIRMATION_DIALOG", dialogParams)
end

function ALT.ClearTestData()
    ALT.Settings.results = {}
    ALT.Settings.testQueue = {}
    ALT.Settings.currentTestAddon = nil
    ALT.Settings.baselineTime = nil
    ALT.Settings.baselineMemory = nil
    ALT.Settings.firstBaselineTime = nil
    ALT.Settings.firstBaselineMemory = nil
    ALT.Settings.secondBaselineTime = nil
    ALT.Settings.secondBaselineMemory = nil
    ALT.Settings.testStep = 0
    ALT.Settings.testActive = false
    ALT.Settings.testPhase = "IDLE"
    ALT.Settings.showResults = false
    ALT.Settings.lastReloadStartTime = nil
    ALT.Settings.pendingMessage = nil
    ALT.Settings.testStartTime = 0
    ALT.Settings.testDuration = 0
end

function ALT.displayResults()
    EM:UnregisterForEvent(ALT.name .. "_Results", EVENT_PLAYER_ACTIVATED)
    ALT.Settings.showResults = false
    LEJ.Show("ALT_Results")
end

function ALT_Interrupt()
    if not ALT.Settings.testActive then
        d("[" .. ALT.name .. "] No active test to interrupt.")
        return
    end

    d("[" .. ALT.name .. "] Interrupting test...")
    ALT.EndTest()
end

-- =========================================================
-- Initialization
-- =========================================================
function ALT.Initialize()    
    ALT.Settings = ZO_SavedVars:NewAccountWide("ALT_SV", 3, nil, defaultSV)
    
    ALT.RegisterConfirmationDialog() 
    ALT.RegisterResultsPanel()
    ALT.RegisterSettingsPanel() 
    
    ALT.CollectAddonsData()
    ALT.BuildDependencyGraph()
	
	SLASH_COMMANDS["/alts"] = ALT_Interrupt
    
    if ALT.Settings.testActive then
        EM:RegisterForEvent(ALT.name .. "_Test", EVENT_PLAYER_ACTIVATED, ALT.OnTestPlayerActivated)
    end
	
    if ALT.Settings.showResults then
        EM:RegisterForEvent(ALT.name .. "_Results", EVENT_PLAYER_ACTIVATED, ALT.displayResults)
    end	
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ALT.name then return end
    EM:UnregisterForEvent(ALT.name, EVENT_ADD_ON_LOADED)
    ALT.Initialize()
end

EM:RegisterForEvent(ALT.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)