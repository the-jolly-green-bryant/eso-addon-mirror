-- UF_GUI.lua
-- Filters the native Update 50 browse-result rebuild before ESO commits the list.
local UF = UnknownFilter

local function IsCallable(value)
    return type(value) == "function"
end

local function ClearNumericTable(target)
    if not target then
        return
    end
    for index = #target, 1, -1 do
        target[index] = nil
    end
end

function UF:IsTradingSceneShown()
    local scene = TRADING_HOUSE_GAMEPAD_SCENE
    if not scene and SCENE_MANAGER then
        scene = SCENE_MANAGER:GetScene("gamepad_trading_house")
    end
    return scene and scene.IsShowing and scene:IsShowing() or false
end

function UF:IsBrowseMode()
    if not TRADING_HOUSE_GAMEPAD then
        return false
    end
    if IsCallable(TRADING_HOUSE_GAMEPAD.IsInSearchMode) then
        return TRADING_HOUSE_GAMEPAD:IsInSearchMode()
    end
    if IsCallable(TRADING_HOUSE_GAMEPAD.GetCurrentMode) then
        return TRADING_HOUSE_GAMEPAD:GetCurrentMode() == ZO_TRADING_HOUSE_MODE_BROWSE
    end
    return false
end

function UF:GetBrowseResultsObject()
    local results = GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS
    if results and results.list then
        return results
    end
    return nil
end

function UF:GetResultList()
    local results = self:GetBrowseResultsObject()
    return results and results.list or nil
end

function UF:IsBrowseResultsActive()
    local results = self:GetBrowseResultsObject()
    return results and IsCallable(results.IsActive) and results:IsActive() or false
end

function UF:AreAddonKeybindsVisible()
    return self._armed
        and self:IsTradingSceneShown()
        and self:IsBrowseMode()
        and self:IsBrowseResultsActive()
end

function UF:RefreshAddonKeybinds()
    if self._kbGroup and KEYBIND_STRIP and IsCallable(KEYBIND_STRIP.UpdateKeybindButtonGroup) then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self._kbGroup)
    end
end

function UF:SetFilteredEmptyMessage(messageKey)
    local results = self:GetBrowseResultsObject()
    if results and IsCallable(results.SetEmptyText) then
        results:SetEmptyText(self:T(messageKey))
        return true
    end
    return false
end

function UF:ApplyFilterToNativeResults(results)
    if not (results and results.list and IsCallable(ZO_ScrollList_GetDataList)) then
        return
    end

    local scrollData = ZO_ScrollList_GetDataList(results.list)
    if type(scrollData) ~= "table" then
        return
    end

    local resultIndexLimit = self:GetCurrentServerResultCount()
    local serverCount = #scrollData
    local mode = (self.saved and self.saved.mode) or self.MODE_OFF
    local isGuildSpecificPage = TRADING_HOUSE_SEARCH
        and IsCallable(TRADING_HOUSE_SEARCH.ShouldShowGuildSpecificItems)
        and TRADING_HOUSE_SEARCH:ShouldShowGuildSpecificItems()

    if isGuildSpecificPage then
        resultIndexLimit = serverCount
    end

    self._serverItemCount = serverCount
    self._visibleItemCount = #scrollData
    self._filteredPageEmpty = false

    if mode == self.MODE_OFF or isGuildSpecificPage or serverCount == 0 then
        self:ClearResultCaches()
        return
    end

    self:ClearResultCaches()
    local keepIfNoLink = self.saved and self.saved.keepIfNoLink == true
    local visiblePreviewIndices = {}

    for dataIndex = #scrollData, 1, -1 do
        local entry = scrollData[dataIndex]
        local itemData = entry and entry.data
        local itemLink = itemData and itemData.itemLink
        local resultIndex = itemData and itemData.slotIndex
        local keep = keepIfNoLink

        if itemLink and itemLink ~= "" then
            local ok, passes = pcall(self.Passes, self, itemLink, mode)
            keep = ok and passes == true
        end

        if type(resultIndex) == "number" and resultIndex > 0 then
            self._passByIndex[resultIndex] = keep
            self._passTotal = self._passTotal + 1

            if GetItemLinkItemId and itemLink and itemLink ~= "" then
                local idOk, itemId = pcall(GetItemLinkItemId, itemLink)
                if idOk and type(itemId) == "number" and itemId > 0
                    and self._passByLink[itemId] == nil
                then
                    self._passByLink[itemId] = keep
                end
            end
        end

        if keep then
            if type(resultIndex) == "number"
                and IsCallable(results.CanPreviewTradingHouseItem)
                and results:CanPreviewTradingHouseItem(itemData)
            then
                visiblePreviewIndices[resultIndex] = true
            end
        else
            table.remove(scrollData, dataIndex)
        end
    end

    if type(results.previewListEntries) == "table" then
        ClearNumericTable(results.previewListEntries)
        for resultIndex = 1, resultIndexLimit do
            if visiblePreviewIndices[resultIndex] then
                table.insert(results.previewListEntries, resultIndex)
            end
        end

        if TRADING_HOUSE_PREVIEW_GAMEPAD_SCENE
            and TRADING_HOUSE_PREVIEW_GAMEPAD_SCENE.IsShowing
            and TRADING_HOUSE_PREVIEW_GAMEPAD_SCENE:IsShowing()
            and IsCallable(results.UpdatePreviewForChangedData)
        then
            results:UpdatePreviewForChangedData()
        end
    end

    self._visibleItemCount = #scrollData
    self._filteredPageEmpty = serverCount > 0 and self._visibleItemCount == 0

    if self._filteredPageEmpty then
        self:SetFilteredEmptyMessage("emptyFilteredPage")
    end
end

function UF:InstallBrowseResultsHook()
    if self._uiHooksInstalled then
        return true
    end

    local results = self:GetBrowseResultsObject()
    if not (results and ZO_PostHook and IsCallable(results.FilterScrollList)) then
        return false
    end

    ZO_PostHook(results, "FilterScrollList", function(resultsObject)
        UF:ApplyFilterToNativeResults(resultsObject)
    end)

    if IsCallable(results.Activate) then
        ZO_PostHook(results, "Activate", function()
            UF:RefreshAddonKeybinds()
        end)
    end
    if IsCallable(results.Deactivate) then
        ZO_PostHook(results, "Deactivate", function()
            UF:RefreshAddonKeybinds()
        end)
    end

    self._browseResults = results
    self._uiHooksInstalled = true
    return true
end

function UF:RefreshFilteredResults()
    if not self._armed or not self:IsTradingSceneShown() or not self:IsBrowseMode() then
        return
    end

    local results = self:GetBrowseResultsObject()
    if not (results and IsCallable(results.RefreshData)) then
        return
    end

    results:RefreshData()

    if IsCallable(self.ScheduleFilteredEmptyFocus) then
        self:ScheduleFilteredEmptyFocus(0)
    elseif IsCallable(results.RefreshPagingControls) then
        results:RefreshPagingControls()
    end
    if IsCallable(self.QueueAutoAdvanceForCurrentPage) then
        self:QueueAutoAdvanceForCurrentPage()
    end
end

function UF:RebuildAndPrune()
    self:RefreshFilteredResults()
end

function UF:_AddFilterKeybind()
    if self._kbGroup or not KEYBIND_STRIP then
        return
    end

    self._kbGroup = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            name = function()
                local mode = (self.saved and self.saved.mode) or self.MODE_OFF
                return self:T("filter") .. ": " .. self:ModeShort(mode)
            end,
            keybind = "UI_SHORTCUT_LEFT_STICK",
            callback = function()
                self:ToggleMode()
            end,
            visible = function()
                return self:AreAddonKeybindsVisible()
            end,
        },
        {
            name = function()
                local enabled = self.saved and self.saved.autoPage == true
                return self:T("autoPaging") .. ": " .. self:StateLabel(enabled)
            end,
            keybind = "UI_SHORTCUT_TERTIARY",
            callback = function()
                self:ToggleAutoPage()
            end,
            visible = function()
                return self:AreAddonKeybindsVisible()
            end,
        },
    }

    KEYBIND_STRIP:AddKeybindButtonGroup(self._kbGroup)
end

function UF:_RemoveFilterKeybind()
    if self._kbGroup and KEYBIND_STRIP then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(self._kbGroup)
    end
    self._kbGroup = nil
end

function UF:WireSceneKeybind()
    if self._sceneWired then
        return true
    end

    local scene = TRADING_HOUSE_GAMEPAD_SCENE
    if not scene and SCENE_MANAGER then
        scene = SCENE_MANAGER:GetScene("gamepad_trading_house")
    end
    if not (scene and IsCallable(scene.RegisterCallback)) then
        return false
    end

    scene:RegisterCallback("StateChange", function(_, newState)
        if not UF._armed then
            return
        end

        if newState == SCENE_SHOWN then
            UF:InstallBrowseResultsHook()
            if IsCallable(UF.InstallPagingHooks) then
                UF:InstallPagingHooks(UF:GetBrowseResultsObject())
            end
            UF:_AddFilterKeybind()
            UF:RefreshFilteredResults()
        elseif newState == SCENE_HIDDEN then
            UF:_RemoveFilterKeybind()
            UF:FreeMemory()
        end
    end)

    self._sceneWired = true

    if scene.IsShowing and scene:IsShowing() then
        self:_AddFilterKeybind()
        self:RefreshFilteredResults()
    end
    return true
end

function UF:FreeMemory()
    self:_RemoveFilterKeybind()
    self:ClearResultCaches()
    self._serverItemCount = 0
    self._visibleItemCount = 0
    self._filteredPageEmpty = false

    if IsCallable(self.ResetPagingState) then
        self:ResetPagingState()
    end
end
