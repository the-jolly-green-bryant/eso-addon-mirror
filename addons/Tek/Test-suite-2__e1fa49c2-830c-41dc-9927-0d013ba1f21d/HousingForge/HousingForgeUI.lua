local HF_HiddenListScreen = ZO_Gamepad_ParametricList_Screen:Subclass()

local function GetLayoutSourceLabel(layout, shortLabel)
    local source = layout and layout.source or "owned"
    if source == "marketplace" then return shortLabel and "MARKET" or "Marketplace" end
    if source == "visited" then return shortLabel and "COPY" or "Copied" end
    if source == "recovery" or (layout and layout.isRecovery) then return shortLabel and "RECOVERY" or "Recovery" end
    if source == "imported" then return shortLabel and "IMPORT" or "Imported" end
    return shortLabel and "OWNED" or "Owned"
end

local PRECISION_ACTIONS = {
    { name = "Align X Centers", hint = "Center the selection left-to-right", run = function() return HF.BlueprintTools.Align("x", "center") end },
    { name = "Align Y Centers", hint = "Center the selection vertically", run = function() return HF.BlueprintTools.Align("y", "center") end },
    { name = "Align Z Centers", hint = "Center the selection front-to-back", run = function() return HF.BlueprintTools.Align("z", "center") end },
    { name = "Distribute on X", hint = "Even horizontal spacing", run = function() return HF.BlueprintTools.Distribute("x") end },
    { name = "Distribute on Y", hint = "Even vertical spacing", run = function() return HF.BlueprintTools.Distribute("y") end },
    { name = "Distribute on Z", hint = "Even depth spacing", run = function() return HF.BlueprintTools.Distribute("z") end },
    { name = "Mirror across X", hint = "Flip the group left-to-right", run = function() return HF.BlueprintTools.Mirror("x") end },
    { name = "Mirror across Z", hint = "Flip the group front-to-back", run = function() return HF.BlueprintTools.Mirror("z") end },
    { name = "Rotate Left 15 degrees", hint = "Rotate around the group center", run = function() return HF.BlueprintTools.Rotate(-15) end },
    { name = "Rotate Right 15 degrees", hint = "Rotate around the group center", run = function() return HF.BlueprintTools.Rotate(15) end },
}

function HF.ExecuteSelectedPrecisionAction()
    if not HF.BlueprintTools then
        HF.Chat("Precision tools are unavailable.")
        return false
    end
    local action = PRECISION_ACTIONS[HF.ui.selectedActionIndex or 1]
    if not action then return false end
    local result = action.run()
    if HF.RefreshUI then HF.RefreshUI() end
    return result
end

function HF_HiddenListScreen:New(control)
    return ZO_Gamepad_ParametricList_Screen.New(self, control)
end

function HF_HiddenListScreen:Initialize(control)
    ZO_Gamepad_ParametricList_Screen.Initialize(self, control, false, true, HF.scene)
end

function HF_HiddenListScreen:PerformUpdate()
end

function HF_HiddenListScreen:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor = {
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = function()
                if HF.ui.screenMode == "precision" then
                    local action = PRECISION_ACTIONS[HF.ui.selectedActionIndex or 1]
                    return action and action.name or "Run Tool"
                end
                local applyQueue = HF.LayoutApplier and HF.LayoutApplier.GetQueue and HF.LayoutApplier.GetQueue()
                if applyQueue then return applyQueue.paused and "Resume Queue" or "Pause Queue" end
                if HF.LayoutExport and HF.LayoutExport.HasPendingExportUrl and HF.LayoutExport.HasPendingExportUrl() then return "Open URL" end
                if HF.ui.screenMode == "export" then return "No URL" end
                if HF.ui.screenMode == "marketplace" then return "Preview"
                end
                if HF.ui.screenMode == "calibration" then return "Scan Room" end
                return HF.ui.screenMode == "settings" and "-10ms" or "Apply Owned"
            end,
            keybind = "UI_SHORTCUT_PRIMARY",
            callback = function()
                if HF.ui.screenMode == "precision" then
                    HF.ExecuteSelectedPrecisionAction()
                    return
                end
                local applyQueue = HF.LayoutApplier and HF.LayoutApplier.GetQueue and HF.LayoutApplier.GetQueue()
                if applyQueue then
                    if applyQueue.paused then HF.LayoutApplier.ResumeQueue() else HF.LayoutApplier.PauseQueue() end
                    return
                end
                if HF.LayoutExport and HF.LayoutExport.HasPendingExportUrl and HF.LayoutExport.HasPendingExportUrl() then
                    HF.LayoutExport.OpenNextQueuedUrl()
                    return
                end
                if HF.ui.screenMode == "export" then return end
                if HF.ui.screenMode == "settings" then HF.AdjustHousingRequestDelay(-10)
                elseif HF.ui.screenMode == "marketplace" then HF.PreviewSelectedLayout()
                elseif HF.ui.screenMode == "calibration" then HF.Calibration.ScanRoom()
                else HF.ApplySelectedLayout() end
            end,
            visible = function()
                local applyQueue = HF.LayoutApplier and HF.LayoutApplier.GetQueue and HF.LayoutApplier.GetQueue()
                return HF.ui.screenMode == "precision"
                    or applyQueue ~= nil
                    or (HF.LayoutExport and HF.LayoutExport.HasPendingExportUrl and HF.LayoutExport.HasPendingExportUrl())
                    or HF.ui.screenMode == "export"
                    or HF.ui.screenMode == "settings"
                    or HF.ui.screenMode == "marketplace"
                    or HF.ui.screenMode == "calibration"
                    or HF.GetSelectedLayout() ~= nil
            end,
        },
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = function()
                if HF.ui.screenMode == "precision" then return "Toggle Target" end
                if HF.ui.screenMode == "settings" then return "+10ms" end
                if HF.ui.screenMode == "export" then return "Status" end
                if HF.ui.screenMode == "calibration" then return "Checklist" end
                return "Record House"
            end,
            keybind = "UI_SHORTCUT_SECONDARY",
            callback = function()
                if HF.ui.screenMode == "precision" then HF.BlueprintTools.Toggle(); HF.RefreshUI()
                elseif HF.ui.screenMode == "settings" then HF.AdjustHousingRequestDelay(10)
                elseif HF.ui.screenMode == "export" then HF.LayoutExport.OpenStatusUrl()
                elseif HF.ui.screenMode == "calibration" then HF.Calibration.ShowMarkerChecklist()
                else HF.RecordCurrentHouse() end
            end,
        },
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = function()
                if HF.ui.screenMode == "precision" then
                    return HF.BlueprintTools and HF.BlueprintTools.IsBusy and HF.BlueprintTools.IsBusy() and "Cancel Precision" or "Clear Selection"
                end
                if HF.LayoutApplier and HF.LayoutApplier.GetQueue and HF.LayoutApplier.GetQueue() then return "Cancel Queue" end
                return HF.ui.screenMode == "settings" and "Fast" or "Delete"
            end,
            keybind = "UI_SHORTCUT_TERTIARY",
            callback = function()
                if HF.ui.screenMode == "precision" then
                    if HF.BlueprintTools.IsBusy() then HF.BlueprintTools.Cancel() else HF.BlueprintTools.Clear() end
                    HF.RefreshUI()
                elseif HF.LayoutApplier and HF.LayoutApplier.GetQueue and HF.LayoutApplier.GetQueue() then HF.LayoutApplier.CancelQueue()
                elseif HF.ui.screenMode == "settings" then HF.SetHousingRequestSpeed("fast")
                elseif HF.ui.screenMode == "export" then HF.LayoutExport.ClearQueue()
                else HF.ShowDeleteLayoutDialog() end
            end,
            visible = function() return HF.ui.screenMode == "precision" or (HF.LayoutApplier and HF.LayoutApplier.GetQueue and HF.LayoutApplier.GetQueue() ~= nil) or HF.ui.screenMode == "settings" or HF.ui.screenMode == "export" or (HF.ui.layoutViewMode == "local" and HF.GetSelectedLayout() ~= nil) end,
        },
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = function()
                if HF.ui.screenMode == "precision" then return "Undo Precision" end
                if HF.LayoutApplier and HF.LayoutApplier.GetQueue and HF.LayoutApplier.GetQueue() then return "Queue Running" end
                if HF.ui.screenMode == "settings" then return "Normal" end
                if HF.ui.screenMode == "export" then return "Retry Missing" end
                return "Clean House"
            end,
            keybind = "UI_SHORTCUT_QUATERNARY",
            callback = function()
                if HF.ui.screenMode == "precision" then HF.BlueprintTools.Undo(); HF.RefreshUI()
                elseif HF.LayoutApplier and HF.LayoutApplier.GetQueue and HF.LayoutApplier.GetQueue() then return
                elseif HF.ui.screenMode == "settings" then HF.SetHousingRequestSpeed("normal")
                elseif HF.ui.screenMode == "export" then HF.LayoutExport.QueueMissing()
                else HF.ShowCleanHouseDialog() end
            end,
        },
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = function()
                if HF.ui.screenMode == "precision" then return "Select All" end
                if HF.ui.screenMode == "settings" then return "Safe" end
                if HF.ui.screenMode == "calibration" then return "Layouts" end
                return "Export"
            end,
            keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
            callback = function()
                if HF.ui.screenMode == "precision" then HF.BlueprintTools.SelectAll(); HF.RefreshUI()
                elseif HF.ui.screenMode == "settings" then HF.SetHousingRequestSpeed("safe")
                elseif HF.ui.screenMode == "calibration" then HF.ShowLayoutsUI()
                else HF.ExportSelectedLayout() end
            end,
            visible = function() return HF.ui.screenMode == "precision" or HF.ui.screenMode == "settings" or HF.ui.screenMode == "calibration" or HF.GetSelectedLayout() ~= nil end,
        },
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = function()
                if HF.ui.screenMode == "precision" or HF.ui.screenMode == "settings" or HF.ui.screenMode == "export" or HF.ui.screenMode == "calibration" then return "Layouts" end
                if HF.ui.screenMode == "marketplace" then return "Local" end
                return HF.ui.layoutViewMode == "marketplace" and "Local" or "Market"
            end,
            keybind = "UI_SHORTCUT_LEFT_SHOULDER",
            callback = function()
                if HF.ui.screenMode == "precision" or HF.ui.screenMode == "settings" or HF.ui.screenMode == "export" or HF.ui.screenMode == "calibration" then HF.ShowLayoutsUI() else HF.ToggleLayoutViewMode() end
            end,
        },
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = function()
                if HF.ui.screenMode == "precision" then return "Move Down 10cm" end
                if HF.ui.screenMode == "settings" then
                    return HF.MiniMap and HF.MiniMap.enabled and "Hide Mini Map" or "Show Mini Map"
                end
                return "Settings"
            end,
            keybind = "UI_SHORTCUT_LEFT_TRIGGER",
            callback = function()
                if HF.ui.screenMode == "precision" then
                    HF.BlueprintTools.Move(0, -10, 0)
                    HF.RefreshUI()
                elseif HF.ui.screenMode == "settings" then
                    if HF.MiniMap then HF.MiniMap.Toggle() end
                else
                    HF.OpenSettingsUI()
                end
            end,
            visible = function() return true end,
        },
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = function()
                if HF.ui.screenMode == "precision" then return "Move Up 10cm" end
                if HF.ui.screenMode == "settings" then
                    local miniFilter = HF.savedVars and HF.savedVars.settings and HF.savedVars.settings.miniMapFilter or "essentials"
                    return "Filter: " .. tostring(miniFilter)
                end
                return "Mini Map"
            end,
            keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
            callback = function()
                if HF.ui.screenMode == "precision" then
                    HF.BlueprintTools.Move(0, 10, 0)
                    HF.RefreshUI()
                elseif HF.ui.screenMode == "settings" then
                    if HF.MiniMap then HF.MiniMap.CycleFilter() end
                elseif HF.MiniMap then
                    HF.MiniMap.Toggle()
                end
            end,
            visible = function() return true end,
        },
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, function() HF.CloseUI() end)
end

function HF.BuildLayoutList()
    HF.ui.sortedLayouts = {}
    if not HF.savedVars then return end

    if HF.ui.layoutViewMode == "marketplace" then
        local catalog = (HF.MarketplaceCatalog and HF.MarketplaceCatalog.layouts) or HF.savedVars.marketplaceLayouts or {}
        for id, layout in pairs(catalog) do
            if layout.layoutData and (not layout.items or #layout.items == 0) and HF.LayoutExport and HF.LayoutExport.DecodeLayoutData then
                local decoded = HF.LayoutExport.DecodeLayoutData(layout.layoutData)
                if decoded then
                    layout.items = decoded.items
                    layout.furnitureCount = decoded.furnitureCount
                    layout.houseId = layout.houseId or decoded.houseId
                    layout.houseName = layout.houseName or decoded.houseName
                end
            end
            layout.id = layout.id or id
            layout.source = layout.source or "marketplace"
            layout.marketplace = true
            table.insert(HF.ui.sortedLayouts, layout)
        end
    elseif HF.savedVars.layouts then
        for id, layout in pairs(HF.savedVars.layouts) do
            layout.id = layout.id or id
            layout.marketplace = false
            table.insert(HF.ui.sortedLayouts, layout)
        end
    end
    table.sort(HF.ui.sortedLayouts, function(a, b)
        return (a.timestamp or 0) > (b.timestamp or 0)
    end)
    if not HF.ui.layoutSelectionInitialized and HF.ui.layoutViewMode == "local" then
        local lastSelectedId = HF.savedVars.lastSelectedLayoutId
        if lastSelectedId then
            for index, layout in ipairs(HF.ui.sortedLayouts) do
                if layout.id == lastSelectedId then
                    HF.ui.selectedLayoutIndex = index
                    break
                end
            end
        end
        HF.ui.layoutSelectionInitialized = true
    end
    if HF.ui.selectedLayoutIndex > #HF.ui.sortedLayouts then
        HF.ui.selectedLayoutIndex = math.max(1, #HF.ui.sortedLayouts)
    end
end

function HF.ToggleLayoutViewMode()
    HF.ui.layoutViewMode = HF.ui.layoutViewMode == "marketplace" and "local" or "marketplace"
    HF.ui.selectedLayoutIndex = 1
    HF.ui.layoutScrollOffset = 0
    HF.SyncHiddenList()
    HF.RefreshUI()
    if KEYBIND_STRIP and HF.hiddenListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(HF.hiddenListScreen.keybindStripDescriptor)
    end
end

function HF.GetSelectedLayout()
    return HF.ui.sortedLayouts and HF.ui.sortedLayouts[HF.ui.selectedLayoutIndex] or nil
end

function HF.SyncHiddenList()
    if not HF.hiddenList then return end
    HF.hiddenList:Clear()
    if HF.ui.screenMode == "precision" then
        for index, action in ipairs(PRECISION_ACTIONS) do
            local entryData = ZO_GamepadEntryData:New(action.name)
            entryData.actionIndex = index
            HF.hiddenList:AddEntry("ZO_GamepadItemEntryTemplate", entryData)
        end
        HF.hiddenList:Commit()
        HF.hiddenList:SetSelectedIndexWithoutAnimation(HF.ui.selectedActionIndex or 1)
        return
    end
    HF.BuildLayoutList()
    local count = math.max(#HF.ui.sortedLayouts, 1)
    for i = 1, count do
        local layout = HF.ui.sortedLayouts[i]
        local emptyText = HF.ui.layoutViewMode == "marketplace" and "No marketplace layouts" or "No saved layouts"
        local entryData = ZO_GamepadEntryData:New(layout and layout.name or emptyText)
        entryData.index = i
        HF.hiddenList:AddEntry("ZO_GamepadItemEntryTemplate", entryData)
    end
    HF.hiddenList:Commit()
    if HF.ui.selectedLayoutIndex and HF.ui.selectedLayoutIndex <= count then
        HF.hiddenList:SetSelectedIndexWithoutAnimation(HF.ui.selectedLayoutIndex)
    end
end

function HF.ScrollLayouts(direction)
    if HF.ui.screenMode == "precision" then
        if direction == "up" then
            HF.ui.selectedActionIndex = math.max(1, (HF.ui.selectedActionIndex or 1) - 1)
        else
            HF.ui.selectedActionIndex = math.min(#PRECISION_ACTIONS, (HF.ui.selectedActionIndex or 1) + 1)
        end
        HF.RefreshUI()
        if KEYBIND_STRIP and HF.hiddenListScreen then
            KEYBIND_STRIP:UpdateKeybindButtonGroup(HF.hiddenListScreen.keybindStripDescriptor)
        end
        return
    end
    local count = #HF.ui.sortedLayouts
    if count == 0 then return end
    if direction == "up" then
        HF.ui.selectedLayoutIndex = math.max(1, HF.ui.selectedLayoutIndex - 1)
    else
        HF.ui.selectedLayoutIndex = math.min(count, HF.ui.selectedLayoutIndex + 1)
    end
    if HF.ui.selectedLayoutIndex <= HF.ui.layoutScrollOffset then
        HF.ui.layoutScrollOffset = HF.ui.selectedLayoutIndex - 1
    elseif HF.ui.selectedLayoutIndex > HF.ui.layoutScrollOffset + HF.ui.maxVisibleLayouts then
        HF.ui.layoutScrollOffset = HF.ui.selectedLayoutIndex - HF.ui.maxVisibleLayouts
    end
    local selected = HF.GetSelectedLayout()
    if selected and HF.savedVars and HF.ui.layoutViewMode == "local" then HF.savedVars.lastSelectedLayoutId = selected.id end
    HF.RefreshUI()
end

local function BuildDelayBar()
    local delay = HF.GetHousingRequestDelayMs()
    local minDelay = 10
    local maxDelay = 1000
    local width = 24
    local clamped = math.max(minDelay, math.min(maxDelay, delay))
    local fill = math.floor(((clamped - minDelay) / (maxDelay - minDelay)) * width + 0.5)
    if fill < 1 then fill = 1 end
    if fill > width then fill = width end
    return string.rep("|cAAFFAA#|r", fill) .. string.rep("|c555555-|r", width - fill)
end

function HF.ShowLayoutsUI()
    HF.ui.screenMode = "layouts"
    if not HF.ui.isOpen then HF.OpenUI() end
    HF.SyncHiddenList()
    HF.RefreshUI()
    if KEYBIND_STRIP and HF.hiddenListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(HF.hiddenListScreen.keybindStripDescriptor)
    end
end

function HF.OpenSettingsUI()
    HF.ui.screenMode = "settings"
    if not HF.ui.isOpen then HF.OpenUI() end
    HF.SyncHiddenList()
    HF.RefreshUI()
    if KEYBIND_STRIP and HF.hiddenListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(HF.hiddenListScreen.keybindStripDescriptor)
    end
end

function HF.OpenExportQueueUI()
    HF.ui.screenMode = "export"
    if not HF.ui.isOpen then HF.OpenUI() end
    HF.SyncHiddenList()
    HF.RefreshUI()
    if KEYBIND_STRIP and HF.hiddenListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(HF.hiddenListScreen.keybindStripDescriptor)
    end
end

function HF.OpenMarketplaceUI()
    HF.ui.layoutViewMode = "marketplace"
    HF.ui.screenMode = "layouts"
    HF.ui.selectedLayoutIndex = 1
    HF.ui.layoutScrollOffset = 0
    if not HF.ui.isOpen then HF.OpenUI() end
    HF.SyncHiddenList()
    HF.RefreshUI()
    if KEYBIND_STRIP and HF.hiddenListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(HF.hiddenListScreen.keybindStripDescriptor)
    end
end

function HF.OpenCalibrationUI()
    HF.ui.screenMode = "calibration"
    if not HF.ui.isOpen then HF.OpenUI() end
    HF.SyncHiddenList()
    HF.RefreshUI()
    if KEYBIND_STRIP and HF.hiddenListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(HF.hiddenListScreen.keybindStripDescriptor)
    end
end

function HF.OpenPrecisionUI()
    HF.ui.screenMode = "precision"
    HF.ui.selectedActionIndex = math.max(1, math.min(#PRECISION_ACTIONS, HF.ui.selectedActionIndex or 1))
    if not HF.ui.isOpen then HF.OpenUI() end
    HF.SyncHiddenList()
    HF.RefreshUI()
    if KEYBIND_STRIP and HF.hiddenListScreen then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(HF.hiddenListScreen.keybindStripDescriptor)
    end
end

local function RefreshExportQueueUI(leftCol, centerCol, rightCol)
    local hasQueue = HF.LayoutExport and HF.LayoutExport.HasPendingExportUrl and HF.LayoutExport.HasPendingExportUrl()
    local queue = HF.LayoutExport and HF.LayoutExport.GetQueue and HF.LayoutExport.GetQueue() or nil
    local queueLabel = HF.LayoutExport and HF.LayoutExport.GetQueueLabel and HF.LayoutExport.GetQueueLabel() or ""

    if leftCol then
        local header = leftCol:GetNamedChild("Header")
        local list = leftCol:GetNamedChild("List")
        local selection = list and list:GetNamedChild("SelectionFrame")
        if header then header:SetText("|cAAFFAAEXPORT QUEUE|r") end
        if selection then selection:SetHidden(true) end
        for i = 1, HF.ui.maxVisibleLayouts do
            local label = list and list:GetNamedChild("Layout" .. i)
            if label then
                if i == 1 then
                    label:SetText(hasQueue and "|cFFFFFFExport queue ready|r\n|c888888Press [A] for one URL at a time|r" or "|c888888No queued export chunks.|r")
                elseif i == 2 then
                    label:SetText("|cFFFFFFStatus Check|r\n|c888888Use [Y] or /hf status after first pass|r")
                elseif i == 3 then
                    label:SetText("|cFFFFFFRetry Missing Only|r\n|c888888/hf retrymissing 1,2,3|r")
                else
                    label:SetText("")
                end
            end
        end
        local footer = leftCol:GetNamedChild("Footer")
        if footer then footer:SetText("LB: back to layouts") end
    end

    if centerCol then
        local layoutName = centerCol:GetNamedChild("LayoutName")
        local house = centerCol:GetNamedChild("House")
        local stats = centerCol:GetNamedChild("Stats")
        local summary = centerCol:GetNamedChild("Summary")
        local actions = centerCol:GetNamedChild("Actions")
        local warning = centerCol:GetNamedChild("Warning")

        if layoutName then layoutName:SetText("|cAAFFAAExport Queue|r") end
        if house then house:SetText(hasQueue and "|cFFFFFFNext chunk is waiting|r" or "|c888888No queued chunks|r") end
        if stats then
            if queue then
                stats:SetText(string.format("|cFFFFAAState:|r %s   |cFFFFAAFormat:|r %s   |cFFFFAASession:|r %s", queue.state or "pending", queue.format or "v2", tostring(queue.sessionId or "")))
            else
                stats:SetText("")
            end
        end
        if summary then
            summary:SetText(hasQueue and "Press [A] to open one URL. Approve it, return to ESO, then press [A] again. After the first pass, open status and retry only chunks the server says are missing." or "Start an export with /hf export, /hf map, or /hf eo.")
        end
        if actions then
            actions:SetText(hasQueue and "|cFFFFFF[A]|r Open next chunk URL\n|cFFFFFF[Y]|r Open status page\n|cFFFFFF[Menu]|r Retry missing only\n|cFFFFFF[X]|r Clear queue\n|cFFFFFF[/hf retrymissing 1,2,3]|r Queue missing chunks\n|cFFFFFF[LB]|r Back to layouts\n|cFFFFFF[B]|r Close" or "|cFFFFFF[LB]|r Back to layouts\n|cFFFFFF[B]|r Close")
        end
        if warning then
            warning:SetText(hasQueue and "Do not start another export until this queue finishes." or "")
        end
    end

    if rightCol then
        local header = rightCol:GetNamedChild("Header")
        local list = rightCol:GetNamedChild("MissingList")
        if header then header:SetText("|cAAFFAAEXPORT HELP|r") end
        for i = 1, HF.ui.maxVisibleMissing do
            local label = list and list:GetNamedChild("Missing" .. i)
            if label then
                if i == 1 then
                    label:SetText("|cFFFFFFStep 1|r\n|c888888Open/approve the URL|r")
                elseif i == 2 then
                    label:SetText("|cFFFFFFStep 2|r\n|c888888Return to ESO|r")
                elseif i == 3 then
                    label:SetText("|cFFFFFFStep 3|r\n|c888888Press [A] for next URL|r")
                else
                    label:SetText("")
                end
            end
        end
        local footer = rightCol:GetNamedChild("Footer")
        if footer then footer:SetText(queueLabel) end
    end
end

local function RefreshSettingsUI(leftCol, centerCol, rightCol)
    if leftCol then
        local header = leftCol:GetNamedChild("Header")
        local list = leftCol:GetNamedChild("List")
        local selection = list and list:GetNamedChild("SelectionFrame")
        if header then header:SetText("|cAAFFAASETTINGS|r") end
        if selection then selection:SetHidden(true) end
        for i = 1, HF.ui.maxVisibleLayouts do
            local label = list and list:GetNamedChild("Layout" .. i)
            if label then
                if i == 1 then
                    label:SetText("|cFFFFFFHousing Requests|r\n|c888888Clean and layout placement pacing|r")
                elseif i == 2 then
                    label:SetText("|cFFFFFFMissing Markers|r\n|c888888Use /hf markers to toggle|r")
                elseif i == 3 then
                    label:SetText("|cFFFFFFExport Endpoint|r\n|c888888Use /hf endpoint <url>|r")
                elseif i == 4 then
                    label:SetText("|cFFFFFFExport Format|r\n|c888888Default: " .. tostring(HF.LayoutExport.GetFormat()) .. "|r")
                elseif i == 5 then
                    label:SetText("|cFFFFFFApply Mode|r\n|c888888Current: " .. tostring(HF.GetApplyMode()) .. "|r")
                elseif i == 6 then
                    local miniFilter = HF.savedVars and HF.savedVars.settings and HF.savedVars.settings.miniMapFilter or "essentials"
                    local miniState = HF.MiniMap and HF.MiniMap.enabled and "ON" or "OFF"
                    label:SetText("|cFFFFFFMini Map|r\n|c888888" .. miniState .. " - " .. tostring(miniFilter) .. "|r")
                elseif i == 7 then
                    local enabled = HF.savedVars and HF.savedVars.settings and HF.savedVars.settings.autoRecordBeforeCleanup ~= false
                    local keep = HF.savedVars and HF.savedVars.settings and HF.savedVars.settings.maxRecoverySnapshots or 5
                    label:SetText(string.format("|cFFFFFFCleanup Safety|r\n|c888888%s - keep %d per house|r", enabled and "ON" or "OFF", keep))
                else
                    label:SetText("")
                end
            end
        end
        local footer = leftCol:GetNamedChild("Footer")
        if footer then footer:SetText("LB: back to layouts") end
    end

    if centerCol then
        local delay = HF.GetHousingRequestDelayMs()
        local layoutName = centerCol:GetNamedChild("LayoutName")
        local house = centerCol:GetNamedChild("House")
        local stats = centerCol:GetNamedChild("Stats")
        local summary = centerCol:GetNamedChild("Summary")
        local actions = centerCol:GetNamedChild("Actions")
        local warning = centerCol:GetNamedChild("Warning")

        if layoutName then layoutName:SetText("|cAAFFAAHousingForge Settings|r") end
        if house then house:SetText("|cFFFFFFHousing Request Delay|r") end
        if stats then stats:SetText(string.format("|cFFFFAACurrent:|r %dms   |cFFFFAARange:|r 10ms - 1500ms", delay)) end
        if summary then
            local miniState = HF.MiniMap and HF.MiniMap.enabled and "on" or "off"
            local miniFilter = HF.savedVars and HF.savedVars.settings and HF.savedVars.settings.miniMapFilter or "essentials"
            local snapshots = HF.savedVars and HF.savedVars.settings and HF.savedVars.settings.autoRecordBeforeCleanup ~= false
            local keep = HF.savedVars and HF.savedVars.settings and HF.savedVars.settings.maxRecoverySnapshots or 5
            summary:SetText(string.format("House cleaning and placement use this delay between ESO housing requests.\n\n%s\n\nExport: %s   Apply: %s\nMini map: %s / %s\nCleanup safety snapshots: %s (keep %d per house)", BuildDelayBar(), HF.LayoutExport.GetFormat(), HF.GetApplyMode(), miniState, miniFilter, snapshots and "on" or "off", keep))
        end
        if actions then
            actions:SetText("|cFFFFFF[A/Y]|r Adjust delay by 10ms\n|cFFFFFF[X/Menu/RB]|r Fast, Normal, Safe delay\n|cFFFFFF[LT]|r Toggle mini map\n|cFFFFFF[RT]|r Next mini map filter\n|cFFFFFF[/hf speed 10]|r Set exact delay\n|cFFFFFF[/hf format v1|v2]|r Export format\n|cFFFFFF[/hf applymode owned|cleanapply|noclean|preview]|r Apply mode\n|cFFFFFF[LB]|r Back to layouts\n|cFFFFFF[B]|r Close")
        end
        if warning then
            warning:SetText("Very low values can still trigger ESO Error 318. If that happens, use Normal or Safe.")
        end
    end

    if rightCol then
        local header = rightCol:GetNamedChild("Header")
        local list = rightCol:GetNamedChild("MissingList")
        if header then header:SetText("|cAAFFAAMINI MAP|r") end
        for i = 1, HF.ui.maxVisibleMissing do
            local label = list and list:GetNamedChild("Missing" .. i)
            if label then
                if i == 1 then
                    local miniState = HF.MiniMap and HF.MiniMap.enabled and "ON" or "OFF"
                    label:SetText("|cFFFFFFState|r\n|c888888" .. miniState .. " - press LT|r")
                elseif i == 2 then
                    local miniFilter = HF.savedVars and HF.savedVars.settings and HF.savedVars.settings.miniMapFilter or "essentials"
                    label:SetText("|cFFFFFFFilter|r\n|c888888" .. tostring(miniFilter) .. " - press RT|r")
                elseif i == 3 then
                    label:SetText("|cFFFFFFMarkers|r\n|c888888C/S/M/V/B/D/U essentials|r")
                elseif i == 4 then
                    label:SetText("|cFFFFFF10ms|r\n|c888888Maximum test speed|r")
                elseif i == 5 then
                    label:SetText("|cFFFFFF250ms Fast|r\n|c888888Use /hf speed fast|r")
                elseif i == 6 then
                    label:SetText("|cFFFFFF350ms Normal|r\n|c888888Default test pace|r")
                elseif i == 7 then
                    label:SetText("|cFFFFFF500ms Safe|r\n|c888888Use if Error 318 returns|r")
                else
                    label:SetText("")
                end
            end
        end
        local footer = rightCol:GetNamedChild("Footer")
        if footer then footer:SetText("Current delay: " .. tostring(HF.GetHousingRequestDelayMs()) .. "ms") end
    end
end

local function RefreshCalibrationUI(leftCol, centerCol, rightCol)
    if leftCol then
        local header = leftCol:GetNamedChild("Header")
        local list = leftCol:GetNamedChild("List")
        local selection = list and list:GetNamedChild("SelectionFrame")
        if header then header:SetText("|cAAFFAASCREEN: CALIBRATION|r") end
        if selection then selection:SetHidden(true) end
        for i = 1, HF.ui.maxVisibleLayouts do
            local label = list and list:GetNamedChild("Layout" .. i)
            local role = HF.Calibration and HF.Calibration.GetRecipeRole and HF.Calibration.GetRecipeRole(i)
            if label then
                if role then
                    label:SetText(string.format("|cFFFFFF%s|r\n|c888888%s|r", role.label, role.itemName))
                elseif i == 10 then
                    label:SetText("|cFFFFAAPlace all 9 markers, then scan once.|r")
                else
                    label:SetText("")
                end
            end
        end
        local footer = leftCol:GetNamedChild("Footer")
        if footer then footer:SetText("Vendor/common marker checklist") end
    end

    if centerCol then
        local layoutName = centerCol:GetNamedChild("LayoutName")
        local house = centerCol:GetNamedChild("House")
        local stats = centerCol:GetNamedChild("Stats")
        local summary = centerCol:GetNamedChild("Summary")
        local actions = centerCol:GetNamedChild("Actions")
        local warning = centerCol:GetNamedChild("Warning")
        if layoutName then layoutName:SetText("|cAAFFAAHouse Calibration|r") end
        if house then house:SetText("|cFFFFFF" .. (HF.GetCurrentHouseName and HF.GetCurrentHouseName() or "Current House") .. "|r") end
        if stats then stats:SetText("|cFFFFAARecipe:|r 9 normal vendor-style markers") end
        if summary then summary:SetText("Place the marker furniture listed on the left in one room. When they are all placed, scan once to save the room bounds. Reuse this for room grouping and map background alignment.") end
        if actions then actions:SetText("|cFFFFFF[A]|r Scan room now\n|cFFFFFF[Y]|r Print checklist to chat\n|cFFFFFF[/hf scanroom Name]|r Named room scan\n|cFFFFFF[/hf calmark role]|r Override a marker with selected furniture\n|cFFFFFF[RB/LB]|r Back to layouts\n|cFFFFFF[B]|r Close") end
        if warning then warning:SetText("Addons cannot add items to inventory. Buy/craft/place these markers first.") end
    end

    if rightCol then
        local header = rightCol:GetNamedChild("Header")
        local list = rightCol:GetNamedChild("MissingList")
        if header then header:SetText("|cAAFFAASAVED ROOMS|r") end
        local rooms = HF.savedVars and HF.savedVars.calibration and HF.savedVars.calibration.rooms or {}
        for i = 1, HF.ui.maxVisibleMissing do
            local label = list and list:GetNamedChild("Missing" .. i)
            local room = rooms[i]
            if label then
                if room then
                    label:SetText(string.format("|cFFFFFF%s|r\n|c888888%s|r", room.name or ("Room " .. i), HF.FormatTimestamp(room.timestamp)))
                else
                    label:SetText(i == 1 and "|c888888No room calibrations saved yet.|r" or "")
                end
            end
        end
        local footer = rightCol:GetNamedChild("Footer")
        if footer then footer:SetText(string.format("%d room(s) saved", #rooms)) end
    end
end

local function RefreshPrecisionUI(leftCol, centerCol, rightCol)
    local selectedCount = HF.BlueprintTools and HF.BlueprintTools.GetSelectionCount and HF.BlueprintTools.GetSelectionCount() or 0
    local busy = HF.BlueprintTools and HF.BlueprintTools.IsBusy and HF.BlueprintTools.IsBusy() or false
    local queueStatus = HF.BlueprintTools and HF.BlueprintTools.GetQueueStatus and HF.BlueprintTools.GetQueueStatus() or nil

    if leftCol then
        local header = leftCol:GetNamedChild("Header")
        local list = leftCol:GetNamedChild("List")
        local selection = list and list:GetNamedChild("SelectionFrame")
        if header then header:SetText("|cAAFFAAPRECISION ACTIONS|r") end
        if selection then
            local index = math.max(1, math.min(#PRECISION_ACTIONS, HF.ui.selectedActionIndex or 1))
            selection:ClearAnchors()
            selection:SetAnchor(TOPLEFT, list, TOPLEFT, 5, (index - 1) * 55)
            selection:SetHidden(false)
        end
        for index = 1, HF.ui.maxVisibleLayouts do
            local label = list and list:GetNamedChild("Layout" .. index)
            local action = PRECISION_ACTIONS[index]
            if label then
                if action then
                    local prefix = index == (HF.ui.selectedActionIndex or 1) and "|cFFD700> |r" or ""
                    label:SetText(string.format("%s|cFFFFFF%s|r\n|c888888%s|r", prefix, action.name, action.hint))
                else
                    label:SetText("")
                end
            end
        end
        local footer = leftCol:GetNamedChild("Footer")
        if footer then footer:SetText("D-pad: choose  |  A: run") end
    end

    if centerCol then
        local layoutName = centerCol:GetNamedChild("LayoutName")
        local house = centerCol:GetNamedChild("House")
        local stats = centerCol:GetNamedChild("Stats")
        local summary = centerCol:GetNamedChild("Summary")
        local actions = centerCol:GetNamedChild("Actions")
        local warning = centerCol:GetNamedChild("Warning")
        local action = PRECISION_ACTIONS[HF.ui.selectedActionIndex or 1]
        if layoutName then layoutName:SetText("|cAAFFAAPrecision Blueprint Tools|r") end
        if house then house:SetText("|cFFFFFF" .. (HF.GetCurrentHouseName and HF.GetCurrentHouseName() or "Current House") .. "|r") end
        if stats then
            local queueText = "ready"
            if queueStatus then
                queueText = queueStatus.canceling and "canceling - waiting for final request" or string.format("%s %d/%d", queueStatus.action or "working", queueStatus.processed or 0, queueStatus.total or 0)
            elseif busy then
                queueText = "working"
            end
            stats:SetText(string.format("|cFFFFAASelected:|r %d furnishing(s)   |cFFFFAAQueue:|r %s", selectedCount, queueText))
        end
        if summary then
            summary:SetText(action and ("|cFFFFFF" .. action.name .. "|r\n" .. action.hint .. ". Each operation captures a one-level transform snapshot so it can be undone.") or "Choose a precision action.")
        end
        if actions then
            actions:SetText(string.format("|cFFFFFF[Y]|r Toggle targeted/selected furnishing\n|cFFFFFF[RB]|r Select every furnishing in this house\n|cFFFFFF[X]|r %s\n|cFFFFFF[A]|r Run highlighted precision action\n|cFFFFFF[Menu]|r Undo last precision operation\n|cFFFFFF[LT/RT]|r Move selection down/up 10cm\n|cFFFFFF[/hf group save <name>]|r Save a reusable group\n|cFFFFFF[LB]|r Back to layouts\n|cFFFFFF[B]|r Close", busy and "Cancel current precision queue" or "Clear selection"))
        end
        if warning then
            warning:SetText("Precision moves affect placed furniture immediately. Work in a house you own and use Undo before starting another operation.")
        end
    end

    if rightCol then
        local header = rightCol:GetNamedChild("Header")
        local list = rightCol:GetNamedChild("MissingList")
        if header then header:SetText("|cAAFFAAQUICK WORKFLOW|r") end
        local tips = {
            { "1. Aim and toggle", "Add furnishings one at a time with Y" },
            { "2. Choose a tool", "Use the D-pad on the left" },
            { "3. Run it", "Press A; requests are safely paced" },
            { "Named groups", "/hf group save/load/delete <name>" },
            { "Exact movement", "/hf move <x> <y> <z>" },
            { "Exact rotation", "/hf rotate <degrees>" },
            { "More alignment", "/hf align x|y|z min|center|max|first" },
            { "Cancel queue", "/hf precisioncancel" },
        }
        for index = 1, HF.ui.maxVisibleMissing do
            local label = list and list:GetNamedChild("Missing" .. index)
            local tip = tips[index]
            if label then
                label:SetText(tip and string.format("|cFFFFFF%s|r\n|c888888%s|r", tip[1], tip[2]) or "")
            end
        end
        local footer = rightCol:GetNamedChild("Footer")
        if footer then footer:SetText(string.format("Selection: %d item(s)", selectedCount)) end
    end
end

function HF.RefreshUI()
    local ui = HF_Main_UI
    if not ui then return end
    HF.BuildLayoutList()

    local leftCol = ui:GetNamedChild("LeftCol")
    local centerCol = ui:GetNamedChild("CenterCol")
    local rightCol = ui:GetNamedChild("RightCol")

    if HF.ui.screenMode == "precision" then
        RefreshPrecisionUI(leftCol, centerCol, rightCol)
        return
    end

    if HF.ui.screenMode == "export" then
        RefreshExportQueueUI(leftCol, centerCol, rightCol)
        return
    end

    if HF.ui.screenMode == "settings" then
        RefreshSettingsUI(leftCol, centerCol, rightCol)
        return
    end

    if HF.ui.screenMode == "calibration" then
        RefreshCalibrationUI(leftCol, centerCol, rightCol)
        return
    end

    if leftCol then
        local list = leftCol:GetNamedChild("List")
        local selection = list and list:GetNamedChild("SelectionFrame")
        if selection then
            local visibleIndex = HF.ui.selectedLayoutIndex - HF.ui.layoutScrollOffset
            if visibleIndex >= 1 and visibleIndex <= HF.ui.maxVisibleLayouts and #HF.ui.sortedLayouts > 0 then
                selection:ClearAnchors()
                selection:SetAnchor(TOPLEFT, list, TOPLEFT, 5, (visibleIndex - 1) * 55)
                selection:SetHidden(false)
            else
                selection:SetHidden(true)
            end
        end

        local header = leftCol:GetNamedChild("Header")
        if header then
            header:SetText(HF.ui.layoutViewMode == "marketplace" and "|cFFD700MARKETPLACE|r" or "|cAAFFAALOCAL LAYOUTS|r")
        end

        for i = 1, HF.ui.maxVisibleLayouts do
            local label = list and list:GetNamedChild("Layout" .. i)
            local layout = HF.ui.sortedLayouts[HF.ui.layoutScrollOffset + i]
            if label then
                if layout then
                    local prefix = (HF.ui.layoutScrollOffset + i == HF.ui.selectedLayoutIndex) and "|cFFD700> |r" or ""
                    local sourceLabel = GetLayoutSourceLabel(layout, true)
                    label:SetText(string.format("%s|cFFFFFF%s|r\n|c888888%s - %d items - %s|r", prefix, layout.name or "Unnamed", sourceLabel, layout.furnitureCount or 0, layout.houseName or "Unknown"))
                else
                    local emptyText = HF.ui.layoutViewMode == "marketplace" and "|c888888No marketplace layouts bundled yet.|r" or "|c888888No local layouts yet. Press [Y] to record.|r"
                    label:SetText(i == 1 and emptyText or "")
                end
            end
        end

        local footer = leftCol:GetNamedChild("Footer")
        if footer then
            local modeLabel = HF.ui.layoutViewMode == "marketplace" and "marketplace" or "local"
            footer:SetText(string.format("%d %s layouts", #HF.ui.sortedLayouts, modeLabel))
        end
    end

    local selected = HF.GetSelectedLayout()
    if centerCol then
        local layoutName = centerCol:GetNamedChild("LayoutName")
        local house = centerCol:GetNamedChild("House")
        local stats = centerCol:GetNamedChild("Stats")
        local summary = centerCol:GetNamedChild("Summary")
        local actions = centerCol:GetNamedChild("Actions")
        local warning = centerCol:GetNamedChild("Warning")

        if selected then
            if layoutName then layoutName:SetText("|cAAFFAA" .. (selected.name or "Unnamed Layout") .. "|r") end
            if house then house:SetText("|cFFFFFF" .. (selected.houseName or "Unknown House") .. "|r") end
            if stats then
                local itemCount = selected.furnitureCount or (selected.items and #selected.items) or 0
                local sourceLabel = GetLayoutSourceLabel(selected, false)
                local ownerText = selected.ownerName and selected.ownerName ~= "" and ("   |cFFFFAAOwner:|r " .. selected.ownerName) or ""
                stats:SetText(string.format("|cFFFFAA%s:|r %d items   |cFFFFAADate:|r %s%s", sourceLabel, itemCount, HF.FormatTimestamp(selected.timestamp), ownerText))
            end
            if summary then
                local apply = HF.ui.lastApplySummary
                local preview = HF.runtime and HF.runtime.ownedPreview
                local queue = HF.LayoutApplier and HF.LayoutApplier.GetQueue and HF.LayoutApplier.GetQueue()
                if queue and queue.layout and queue.layout.name == selected.name then
                    summary:SetText(string.format("|c00FF00Queue: %s|r\nPhase: %s\nProgress: %d / %d\nPlaced: %d  Missing: %d  Failed: %d", queue.actionType or "apply", queue.phase or "", queue.processed or 0, queue.total or 0, #(queue.placed or {}), #(queue.missing or {}), #(queue.failed or {})))
                elseif preview and preview.layoutName == selected.name then
                    summary:SetText(string.format("|c00FF00Owned Preview|r\nOwned: %d / %d\nMissing: %d\nUnknown: %d", preview.owned or 0, preview.total or 0, preview.missing or 0, preview.unknown or 0))
                elseif apply and apply.layoutName == selected.name then
                    summary:SetText(string.format("|c00FF00Last Apply|r\nPlaced: %d / %d   Missing: %d   Failed: %d\nStates restored: %d   State warnings: %d   Removal warnings: %d", apply.placed or 0, apply.total or 0, apply.missing or 0, apply.failed or 0, apply.statesRestored or 0, apply.stateFailed or 0, apply.removeFailed or 0))
                elseif selected.source == "marketplace" then
                    summary:SetText("|cAAAAAAMarketplace layout. Local delete is disabled; apply/export only when layout data is bundled.|r")
                elseif selected.source == "visited" then
                    summary:SetText("|cAAAAAACopied from a visited house. You can export it or apply owned matching items inside a house you own.|r")
                elseif selected.source == "recovery" or selected.isRecovery then
                    summary:SetText("|cAAAAAASafety snapshot created before cleanup. It can restore recorded transforms and states; furnishing links and paths are recorded for reference but are not restored in 1.4.|r")
                elseif selected.source == "imported" then
                    summary:SetText("|cAAAAAAImported HFv2 layout saved locally. Preview your owned items, then apply it only in the matching house.|r")
                else
                    summary:SetText("|cAAAAAASelect Apply Owned to place furniture you currently own. Missing items will be listed and can be marked in 3D.|r")
                end
            end
        else
            if layoutName then layoutName:SetText("|cAAFFAANo Layout Selected|r") end
            if house then house:SetText("|c888888Record your current house to begin.|r") end
            if stats then stats:SetText("") end
            if summary then
                summary:SetText(HF.ui.layoutViewMode == "marketplace" and "|cAAAAAAMarketplace layouts will appear separately from local copies.|r" or "|cAAAAAAUse Record House to save the current owned house layout locally.|r")
            end
        end

        if actions then
            local applyQueue = HF.LayoutApplier and HF.LayoutApplier.GetQueue and HF.LayoutApplier.GetQueue()
            if applyQueue then
                actions:SetText(string.format("|cFFFFFF[A]|r %s housing queue\n|cFFFFFF[X]|r Cancel queue safely\n|cFFFFFFPhase:|r %s\n|cFFFFFFProgress:|r %d / %d\n\nThe final accepted request is allowed to settle before cancellation releases the queue.", applyQueue.paused and "Resume" or "Pause", applyQueue.phase or "working", applyQueue.processed or 0, applyQueue.total or 0))
            elseif HF.LayoutExport and HF.LayoutExport.HasPendingExportUrl and HF.LayoutExport.HasPendingExportUrl() then
                actions:SetText(string.format("|cFFFFFF[A]|r Open next export URL\n|cFFFFFF[/hf next]|r Open next export URL\n|cFFFFFFStatus:|r %s\n\nApprove the prompt, return to ESO, then press [A] again.", HF.LayoutExport.GetQueueLabel()))
            else
                actions:SetText(string.format("|cFFFFFF[A]|r Run selected apply mode\n|cFFFFFF[/hf preview]|r Owned/missing preview\n|cFFFFFF[/hf applymode]|r Current: %s\n|cFFFFFF[LB]|r Switch Local / Marketplace\n|cFFFFFF[Y]|r Record owned house\n|cFFFFFF[/hf copy]|r Copy visited house\n|cFFFFFF[X]|r Delete local layout\n|cFFFFFF[Menu]|r Clean house with confirmation\n|cFFFFFF[RB]|r Export layout\n|cFFFFFF[/hf map]|r Export map viewer\n|cFFFFFF[/hf pause/resume/cancel]|r Queue control\n|cFFFFFF[/hf speed 10]|r Delay: %dms\n|cFFFFFF[B]|r Close", HF.GetApplyMode(), HF.GetHousingRequestDelayMs()))
            end
        end
        if warning then
            warning:SetText("Clean House removes all placed furniture from the current owned house after confirmation.")
        end
    end

    if rightCol then
        local header = rightCol:GetNamedChild("Header")
        local list = rightCol:GetNamedChild("MissingList")
        local combined = {}
        local preview = HF.runtime and HF.runtime.ownedPreview
        if preview and preview.required then
            for _, item in ipairs(preview.required) do
                if item.missing and item.missing > 0 then table.insert(combined, { itemName = item.itemName, missingReason = tostring(item.missing) .. " missing of " .. tostring(item.needed) }) end
            end
        end
        if #combined == 0 then
            for _, item in ipairs(HF.runtime.missingItems or {}) do table.insert(combined, item) end
            for _, item in ipairs(HF.runtime.failedItems or {}) do table.insert(combined, item) end
        end

        if header then
            if #combined > 0 then
                header:SetText("|cFFAAAARECENT MISSING / FAILED|r")
            else
                header:SetText("|cAAFFAACALIBRATION MARKERS|r")
            end
        end

        for i = 1, HF.ui.maxVisibleMissing do
            local label = list and list:GetNamedChild("Missing" .. i)
            local item = combined[HF.ui.missingScrollOffset + i]
            if label then
                if item then
                    local reason = item.missingReason or item.failureReason or "missing"
                    label:SetText(string.format("|cFFAA44%s|r\n|c888888%s|r", item.itemName or "Unknown", tostring(reason)))
                elseif #combined == 0 and HF.Calibration and HF.Calibration.GetRecipeText then
                    local role = HF.Calibration.GetRecipeRole(i)
                    if role then
                        label:SetText(string.format("|cAAFFAA%s|r\n|cFFFFFF%s|r", role.label, role.itemName))
                    else
                        label:SetText("")
                    end
                else
                    label:SetText(i == 1 and "|c888888No missing/failed items from last apply.|r" or "")
                end
            end
        end
        local footer = rightCol:GetNamedChild("Footer")
        if footer then
            if #combined > 0 then
                footer:SetText(string.format("Markers: %s", HF.MissingItemMarkers.enabled and "ON" or "OFF"))
            else
                footer:SetText("Place these, then /hf scanroom Name")
            end
        end
    end
end

function HF.InitScene()
    if HF.ui.sceneInitialized then return end
    if not HF_Main_UI then return end

    local hiddenControl = WINDOW_MANAGER:CreateControlFromVirtual("HF_HiddenList", GuiRoot, "HF_HiddenList_Screen")
    hiddenControl:SetHidden(true)
    hiddenControl:SetAlpha(0)

    HF.scene = ZO_Scene:New("housingForgeScene", SCENE_MANAGER)
    HF.scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    HF.scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    HF.scene:AddFragment(ZO_SimpleSceneFragment:New(HF_Main_UI))
    HF.scene:AddFragment(ZO_SimpleSceneFragment:New(hiddenControl))

    HF.hiddenListScreen = HF_HiddenListScreen:New(hiddenControl)
    HF.hiddenList = HF.hiddenListScreen:GetMainList()
    HF.hiddenList:AddDataTemplate("ZO_GamepadItemEntryTemplate", function(control, data) end, ZO_GamepadMenuEntryTemplateParametricListFunction)
    HF.hiddenList.MovePrevious = function() HF.ScrollLayouts("up") end
    HF.hiddenList.MoveNext = function() HF.ScrollLayouts("down") end
    HF.hiddenList:SetOnSelectedDataChangedCallback(function(list, selectedData)
        if selectedData and selectedData.actionIndex then
            HF.ui.selectedActionIndex = selectedData.actionIndex
            HF.RefreshUI()
        elseif selectedData and selectedData.index then
            HF.ui.selectedLayoutIndex = selectedData.index
            local selected = HF.GetSelectedLayout()
            if selected and HF.savedVars and HF.ui.layoutViewMode == "local" then HF.savedVars.lastSelectedLayoutId = selected.id end
            HF.RefreshUI()
        end
    end)

    HF.scene:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            HF.ui.isOpen = true
            HF.SyncHiddenList()
            HF.RefreshUI()
            if KEYBIND_STRIP and HF.hiddenListScreen then
                KEYBIND_STRIP:AddKeybindButtonGroup(HF.hiddenListScreen.keybindStripDescriptor)
            end
        elseif newState == SCENE_HIDING then
            if KEYBIND_STRIP and HF.hiddenListScreen then
                KEYBIND_STRIP:RemoveKeybindButtonGroup(HF.hiddenListScreen.keybindStripDescriptor)
            end
        elseif newState == SCENE_HIDDEN then
            HF.ui.isOpen = false
        end
    end)

    HF.ui.sceneInitialized = true
end

function HF.OpenUI()
    HF.InitScene()
    if HF.scene then SCENE_MANAGER:Push("housingForgeScene") end
end

function HF.CloseUI()
    if HF.scene then SCENE_MANAGER:Hide("housingForgeScene") end
end

function HF.ToggleUI()
    if HF.ui.isOpen then HF.CloseUI() else HF.OpenUI() end
end

function HF.RecordCurrentHouse(nameOverride)
    local layout = HF.LayoutRecorder.RecordCurrentHouse(nameOverride)
    if layout then
        HF.BuildLayoutList()
        for i, saved in ipairs(HF.ui.sortedLayouts) do
            if saved.id == layout.id then
                HF.ui.selectedLayoutIndex = i
                break
            end
        end
        HF.SyncHiddenList()
        HF.RefreshUI()
    end
end

function HF.CopyCurrentHouse(nameOverride)
    local layout = HF.LayoutRecorder.CopyCurrentHouse(nameOverride)
    if layout then
        HF.BuildLayoutList()
        for i, saved in ipairs(HF.ui.sortedLayouts) do
            if saved.id == layout.id then
                HF.ui.selectedLayoutIndex = i
                break
            end
        end
        HF.SyncHiddenList()
        HF.RefreshUI()
    end
end

function HF.RenameSelectedLayout(newName)
    if HF.ui.layoutViewMode == "marketplace" then
        HF.Chat("Marketplace layouts cannot be renamed locally.")
        return false
    end
    HF.BuildLayoutList()
    local layout = HF.GetSelectedLayout()
    if not layout then
        HF.Chat("No local layout selected.")
        return false
    end
    newName = tostring(newName or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if newName == "" then
        HF.Chat("Usage: /hf rename <new layout name>")
        return false
    end
    if #newName > 64 then newName = string.sub(newName, 1, 64) end
    layout.name = newName
    layout.renamedAt = GetTimeStamp()
    HF.Chat("Layout renamed to: " .. newName)
    HF.SyncHiddenList()
    HF.RefreshUI()
    return true
end

function HF.ApplySelectedLayout()
    HF.BuildLayoutList()
    local layout = HF.GetSelectedLayout()
    if not layout then
        HF.Chat("No layout selected.")
        return
    end
    HF.LayoutApplier.ApplyLayout(layout)
end

function HF.PreviewSelectedLayout()
    HF.BuildLayoutList()
    local layout = HF.GetSelectedLayout()
    if not layout then
        HF.Chat("No layout selected.")
        return
    end
    HF.LayoutApplier.PreviewLayout(layout)
end

function HF.ExportSelectedLayout(formatArg)
    HF.BuildLayoutList()
    local layout = HF.GetSelectedLayout()
    if not layout then
        HF.Chat("No layout selected.")
        return
    end
    local format = formatArg and formatArg:lower():match("^%s*(v%d)") or nil
    HF.LayoutExport.ExportLayout(layout, format)
end

function HF.ExportSelectedMap()
    HF.BuildLayoutList()
    local layout = HF.GetSelectedLayout()
    if not layout then
        HF.Chat("No layout selected.")
        return
    end
    HF.LayoutExport.ExportLayoutMap(layout)
end

function HF.DeleteSelectedLayout()
    if HF.ui.layoutViewMode == "marketplace" then
        HF.Chat("Marketplace layouts cannot be deleted locally.")
        return false
    end

    HF.BuildLayoutList()
    local layout = HF.GetSelectedLayout()
    if not layout or not layout.id then
        HF.Chat("No local layout selected.")
        return false
    end

    HF.savedVars.layouts[layout.id] = nil
    HF.Chat("Deleted layout: " .. tostring(layout.name or layout.id))
    HF.BuildLayoutList()
    if HF.ui.selectedLayoutIndex > #HF.ui.sortedLayouts then
        HF.ui.selectedLayoutIndex = math.max(1, #HF.ui.sortedLayouts)
    end
    local nextLayout = HF.GetSelectedLayout()
    HF.savedVars.lastSelectedLayoutId = nextLayout and nextLayout.id or nil
    HF.SyncHiddenList()
    HF.RefreshUI()
    return true
end

function HF.ShowDeleteLayoutDialog()
    HF.BuildLayoutList()
    if HF.ui.layoutViewMode == "marketplace" then
        HF.Chat("Marketplace layouts cannot be deleted locally.")
        return
    end

    local layout = HF.GetSelectedLayout()
    if not layout then
        HF.Chat("No local layout selected.")
        return
    end

    if not ESO_Dialogs["HF_DELETE_LAYOUT_CONFIRM"] then
        ESO_Dialogs["HF_DELETE_LAYOUT_CONFIRM"] = {
            gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
            canQueue = true,
            title = { text = "DELETE LAYOUT" },
            mainText = { text = "Delete the selected local layout? This only removes the saved HousingForge copy." },
            buttons = {
                {
                    text = "Delete",
                    keybind = "DIALOG_PRIMARY",
                    callback = function() HF.DeleteSelectedLayout() end,
                },
                { text = "Cancel", keybind = "DIALOG_NEGATIVE" },
            },
        }
    end

    if IsInGamepadPreferredMode and IsInGamepadPreferredMode() then
        ZO_Dialogs_ShowGamepadDialog("HF_DELETE_LAYOUT_CONFIRM")
    else
        ZO_Dialogs_ShowDialog("HF_DELETE_LAYOUT_CONFIRM")
    end
end

function HF.ShowCleanHouseDialog()
    if not ESO_Dialogs["HF_CLEAN_HOUSE_CONFIRM"] then
        ESO_Dialogs["HF_CLEAN_HOUSE_CONFIRM"] = {
            gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
            canQueue = true,
            title = { text = "CLEAN HOUSE" },
            mainText = { text = "This removes all placed furniture from the current owned house. HousingForge records a recovery layout first and blocks cleanup when links or paths cannot be safely restored. Disabling cleanup safety forces an unrecoverable clean. Continue?" },
            buttons = {
                {
                    text = "Remove All",
                    keybind = "DIALOG_PRIMARY",
                    callback = function() HF.LayoutApplier.CleanCurrentHouse() end,
                },
                { text = "Cancel", keybind = "DIALOG_NEGATIVE" },
            },
        }
    end

    if IsInGamepadPreferredMode and IsInGamepadPreferredMode() then
        ZO_Dialogs_ShowGamepadDialog("HF_CLEAN_HOUSE_CONFIRM")
    else
        ZO_Dialogs_ShowDialog("HF_CLEAN_HOUSE_CONFIRM")
    end
end
