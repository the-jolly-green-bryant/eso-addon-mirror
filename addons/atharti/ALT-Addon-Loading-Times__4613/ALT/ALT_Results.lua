local ALT = AddonLoadingTimes

local LEJ = LibExtendedJournal

LEJ.Used = true

function ALT.ColorizeText(text, hexColor)
    return string.format("|c%s%s|r", hexColor, text)
end

function ALT.RegisterResultsPanel()    
    LEJ.RegisterTab(
        "ALT_Results",
        {
            title = "ALT — Test Results",
            subtitle = "",
            iconNormal = "/esoui/art/inventory/inventory_tabicon_tool_up.dds",
            iconPressed = "/esoui/art/inventory/inventory_tabicon_tool_down.dds",
            iconHighlight = "/esoui/art/inventory/inventory_tabicon_tool_over.dds",
            order = 995,
            control = ALT.CreateResultsPanel(),
            callbackShow = function()
                ALT.RefreshResultsList()
            end,
        }
    )
end

function ALT.CreateResultsPanel()
    local panel = WINDOW_MANAGER:CreateControlFromVirtual("ALT_ResultsPanel", GuiRoot, "ALT_ResultsPanel")
    panel:SetHidden(true)
    
    local scrollList = panel:GetNamedChild("List")
    
    ZO_ScrollList_Initialize(scrollList)
    ZO_ScrollList_AddDataType(scrollList, 1, "ALT_ResultsListRow", 25, function(control, data)
        ALT.SetupResultsRow(control, data)
    end)
    
    ZO_ScrollList_AddDataType(scrollList, 2, "ALT_ModulesListRow", 20, function(control, data)
        ALT.SetupModulesRow(control, data)
    end)
    
    panel.scrollList = scrollList
    
    return panel
end

function ALT.RefreshResultsList()
    local panel = WINDOW_MANAGER:GetControlByName("ALT_ResultsPanel")
    if not panel or not panel.scrollList then return end
    
    ALT.CollectAddonsData()
    ALT.BuildDependencyGraph()
    
    local dataList = {}
    local totalTime = 0
    local totalMemoryKB = 0
    
    for addonName, data in pairs(ALT.Settings.results) do
        local timeContribution = math.max(0, data.time or 0)
        local rawMem = math.max(0, data.memory or 0)
        
        local memContribution = rawMem
        if (rawMem / 1024) < 2.0 then
            memContribution = 0
        end
        
        totalTime = totalTime + timeContribution
        totalMemoryKB = totalMemoryKB + memContribution
        
        local resolvedGroup = ALT.ResolveAddonTestGroup(addonName)
        local moduleList = {}
        for _, depName in ipairs(resolvedGroup) do
            local addonInfo = ALT.AddonsData[depName]
            if depName ~= addonName and (not addonInfo or not addonInfo.isLibrary) then
                table.insert(moduleList, depName)
            end
        end
        
        table.insert(dataList, {
            name = addonName,
            time = timeContribution,
            memory = memContribution,
            modules = moduleList,
        })
    end
    
    local loadTimeLabel = panel:GetNamedChild("LoadTimeSummary")
    local memoryLabel = panel:GetNamedChild("MemorySummary")
    
    if loadTimeLabel then
        loadTimeLabel:SetWidth(250)
        local totalTimeSec = totalTime / 1000
        loadTimeLabel:SetText(string.format("Load Time: |c33CCFF~%.2f sec|r", totalTimeSec))
    end
    
    if memoryLabel then
        memoryLabel:SetWidth(250)
        local totalMemoryMB = totalMemoryKB / 1024
        memoryLabel:SetText(string.format("Memory Usage: |c33CCFF~%.1f MB|r", totalMemoryMB))
    end
        
    local durationLabel = panel:GetNamedChild("TestDurationSummary")
    if not durationLabel and loadTimeLabel then
        durationLabel = WINDOW_MANAGER:CreateControl("$(parent)TestDurationSummary", panel, CT_LABEL)
        durationLabel:SetFont("ZoFontGameLargeBold")
        durationLabel:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_HIGHLIGHT))
        durationLabel:SetAnchor(LEFT, loadTimeLabel, RIGHT, 20, 0)
        durationLabel:SetDimensions(350, 25)
    end
    
    if durationLabel then
        local durationSec = ALT.Settings.testDuration or 0
        local durationMinutes = math.floor(durationSec / 60)
        local durationSeconds = durationSec % 60
        
        local formattedDuration
        if durationMinutes > 0 then
            formattedDuration = string.format("%dm %ds", durationMinutes, durationSeconds)
        else
            formattedDuration = string.format("%ds", durationSeconds)
        end
        
        durationLabel:SetText(string.format("Test Duration: |c33CCFF%s|r", formattedDuration))
    end

    local baselineLabel = panel:GetNamedChild("BaselineSummary")
    if not baselineLabel and memoryLabel then
        baselineLabel = WINDOW_MANAGER:CreateControl("$(parent)BaselineSummary", panel, CT_LABEL)
        baselineLabel:SetFont("ZoFontGameLargeBold")
        baselineLabel:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_HIGHLIGHT))
        baselineLabel:SetAnchor(LEFT, memoryLabel, RIGHT, 20, 0)
        baselineLabel:SetDimensions(350, 25)
    end
    
    if baselineLabel then
        local bTimeMs = ALT.Settings.baselineTime or 0
        local bTimeSec = bTimeMs / 1000
        local bMemKB = ALT.Settings.baselineMemory or 0
        local bMemMB = bMemKB / 1024
        
        baselineLabel:SetText(string.format(
            "Baseline (Libs): |c33CCFF~%.2f sec|r / |c33CCFF%.1f MB|r", 
            bTimeSec, bMemMB
        ))
    end
    
    table.sort(dataList, function(a, b) return a.time > b.time end)
    
    ZO_ScrollList_Clear(panel.scrollList)
    
    local scrollData = ZO_ScrollList_GetDataList(panel.scrollList)
    for i, data in ipairs(dataList) do
        table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, {
            rank = i,
            name = data.name,
            time = data.time,
            memory = data.memory,
            modules = data.modules,
            panel = panel
        }))
        
        if #data.modules > 0 then
            for _, moduleName in ipairs(data.modules) do
                table.insert(scrollData, ZO_ScrollList_CreateDataEntry(2, {
                    name = "  → " .. moduleName,
                    panel = panel
                }))
            end
        end
    end
    
    ZO_ScrollList_Commit(panel.scrollList)
end

function ALT.ShowAddonTooltip(control, addonName)
    local addonManager = GetAddOnManager()
    local addonIndex = nil
    
    for i = 1, addonManager:GetNumAddOns() do
        local name = addonManager:GetAddOnInfo(i)
        if name == addonName then
            addonIndex = i
            break
        end
    end
    
    InitializeTooltip(InformationTooltip, control, RIGHT, -10, 0, LEFT)
    InformationTooltip:ClearLines()
    
    if addonIndex then
        local numDeps = addonManager:GetAddOnNumDependencies(addonIndex)
        if numDeps > 0 then
            local lines = {}
            for j = 1, numDeps do
                local depName, exists, active, minVersion, version, isLib = addonManager:GetAddOnDependencyInfo(addonIndex, j)
                if exists and depName then
                    local color = isLib and "66AAFF" or "FFFFFF"
                    table.insert(lines, string.format("|c%s%s|r", color, depName))
                end
            end
            SetTooltipText(InformationTooltip, table.concat(lines, "\n"))
        else
            InformationTooltip:AddLine("|c666666No dependencies|r")
        end
    end
end

function ALT.SetupResultsRow(control, data)
    local rank = control:GetNamedChild("Rank")
    local name = control:GetNamedChild("Name")
    local time = control:GetNamedChild("Time")
    local memory = control:GetNamedChild("Memory")
    
    rank:SetText(tostring(data.rank))
    name:SetText(data.name)
    
    local timeValue = data.time
    local timeText = string.format("~%.0f ms", timeValue)
    local timeColor
    
    if timeValue <= 50 then
        timeColor = "44FF44" -- Green 
    elseif timeValue <= 500 then
        timeColor = "FFAA44" -- Orange
    else
        timeColor = "FF4444" -- Red
    end
    time:SetText(ALT.ColorizeText(timeText, timeColor))
    
    local memValueMB = data.memory / 1024
    
    local memText
    if memValueMB <= 0 then
        memText = "~0.0 MB"
    else
        memText = string.format("~%.1f MB", memValueMB)
    end

    local memColor
    
    if memValueMB < 1.0 then
        memColor = "44FF44" -- Green
    elseif memValueMB < 25.0 then
        memColor = "FFAA44" -- Orange
    else
        memColor = "FF4444" -- Red
    end
    memory:SetText(ALT.ColorizeText(memText, memColor))
    
    control:SetMouseEnabled(true)
    
    control:SetHandler("OnMouseEnter", function()
        ALT.ShowAddonTooltip(control, data.name)
    end)
    
    control:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)
    
    control:SetHandler("OnMouseUp", nil)
end

function ALT.SetupModulesRow(control, data)
    local name = control:GetNamedChild("Name")
    name:SetText(data.name)
    
    name:SetColor(0.6, 0.6, 0.6, 1) 
    
    name:SetFont("ZoFontGameSmall")
end