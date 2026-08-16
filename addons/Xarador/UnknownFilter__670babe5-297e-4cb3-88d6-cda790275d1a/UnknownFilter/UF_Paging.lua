-- UF_Paging.lua
-- Keeps ESO's native Update 50 trigger navigation active on filter-empty pages.
local UF = UnknownFilter

local AUTO_PAGE_DELAY_MS = 1000

local function IsCallable(value)
    return type(value) == "function"
end

function UF:CancelAutoAdvance(resetHops)
    self._autoToken = (self._autoToken or 0) + 1
    if resetHops then
        self._autoHops = 0
    end
end

function UF:ResetPagingState()
    self:CancelAutoAdvance(true)
    self._focusToken = (self._focusToken or 0) + 1
    self._lastCompletedPage = nil
    self._autoRequestPending = false
end

function UF:RefreshNativePagingState()
    local results = self:GetBrowseResultsObject()
    if not results then
        return
    end

    if IsCallable(results.RefreshPagingControls) then
        results:RefreshPagingControls()
    end
    if IsCallable(results.UpdateKeybinds) then
        results:UpdateKeybinds()
    end
    if IsCallable(self.RefreshAddonKeybinds) then
        self:RefreshAddonKeybinds()
    end
end

function UF:RestoreFilteredEmptyFocus()
    if not (self._armed
        and self:IsTradingSceneShown()
        and self:IsBrowseMode()
        and self._filteredPageEmpty
        and (self._serverItemCount or 0) > 0)
    then
        return false
    end

    local results = self:GetBrowseResultsObject()
    if not (results
        and IsCallable(results.IsActive)
        and results:IsActive()
        and results.panelFocalArea
        and IsCallable(results.ActivateFocusArea))
    then
        return false
    end

    -- ESO normally moves an empty committed list to the sort header. The native
    -- LT/RT or L2/R2 descriptors belong to panelFocalArea, so restore that focus.
    results:ActivateFocusArea(results.panelFocalArea)
    self:RefreshNativePagingState()
    return true
end

function UF:ScheduleFilteredEmptyFocus(delayMs)
    self._focusToken = (self._focusToken or 0) + 1
    local token = self._focusToken
    zo_callLater(function()
        if token == UF._focusToken then
            UF:RestoreFilteredEmptyFocus()
        end
    end, tonumber(delayMs) or 0)
end

function UF:CanAutoAdvanceFilteredPage()
    local saved = self.saved
    local mode = (saved and saved.mode) or self.MODE_OFF
    if not (saved
        and saved.autoPage == true
        and saved.skipEmptyPages == true
        and mode ~= self.MODE_OFF
        and self._filteredPageEmpty
        and (self._serverItemCount or 0) > 0)
    then
        return false
    end

    return TRADING_HOUSE_SEARCH
        and IsCallable(TRADING_HOUSE_SEARCH.HasNextPage)
        and TRADING_HOUSE_SEARCH:HasNextPage()
end

function UF:QueueAutoAdvanceForCurrentPage()
    self:CancelAutoAdvance(false)
    if not self:CanAutoAdvanceFilteredPage() then
        return
    end

    local maxHops = tonumber(self.saved.skipMaxHops) or 6
    maxHops = math.max(0, math.min(20, maxHops))
    if maxHops == 0 then
        return
    end
    if (self._autoHops or 0) >= maxHops then
        return
    end

    local token = self._autoToken
    local expectedPage = TRADING_HOUSE_SEARCH:GetPage()
    self:SetFilteredEmptyMessage("emptyFilteredPageAuto")
    zo_callLater(function()
        if token ~= UF._autoToken or not UF:CanAutoAdvanceFilteredPage() then
            return
        end
        if TRADING_HOUSE_SEARCH:GetPage() ~= expectedPage then
            return
        end
        if TRADING_HOUSE_SEARCH:GetSearchState() ~= TRADING_HOUSE_SEARCH_STATE_COMPLETE then
            return
        end

        UF._autoHops = (UF._autoHops or 0) + 1
        UF._autoRequestPending = true
        TRADING_HOUSE_SEARCH:SearchNextPage()
    end, AUTO_PAGE_DELAY_MS)
end

function UF:OnNativeSearchStateChanged(searchState, searchOutcome)
    if searchState == TRADING_HOUSE_SEARCH_STATE_WAITING then
        self:CancelAutoAdvance(false)
        self._focusToken = (self._focusToken or 0) + 1
        if self._autoRequestPending then
            self:SetFilteredEmptyMessage("autoLoadingNextPage")
        end
        return
    end

    if searchState == TRADING_HOUSE_SEARCH_STATE_NONE then
        self:ResetPagingState()
        return
    end

    if searchState ~= TRADING_HOUSE_SEARCH_STATE_COMPLETE then
        return
    end

    self._autoRequestPending = false

    local currentPage = TRADING_HOUSE_SEARCH:GetPage()
    if self._lastCompletedPage == nil or currentPage <= self._lastCompletedPage then
        self._autoHops = 0
    end
    self._lastCompletedPage = currentPage

    if searchOutcome ~= TRADING_HOUSE_SEARCH_OUTCOME_HAS_RESULTS then
        self:CancelAutoAdvance(true)
        self._focusToken = (self._focusToken or 0) + 1
        return
    end

    if (self._visibleItemCount or 0) > 0 then
        self._autoHops = 0
    end

    self:ScheduleFilteredEmptyFocus(0)
    self:QueueAutoAdvanceForCurrentPage()
end

function UF:OnManualPageInput()
    self:CancelAutoAdvance(true)
    self._focusToken = (self._focusToken or 0) + 1
    self._autoRequestPending = false
end

function UF:GoToNextPage()
    if not (TRADING_HOUSE_SEARCH
        and IsCallable(TRADING_HOUSE_SEARCH.HasNextPage)
        and IsCallable(TRADING_HOUSE_SEARCH.SearchNextPage)
        and TRADING_HOUSE_SEARCH:HasNextPage())
    then
        return false
    end

    self:OnManualPageInput()
    TRADING_HOUSE_SEARCH:SearchNextPage()
    return true
end

function UF:GoToPreviousPage()
    if not (TRADING_HOUSE_SEARCH
        and IsCallable(TRADING_HOUSE_SEARCH.HasPreviousPage)
        and IsCallable(TRADING_HOUSE_SEARCH.SearchPreviousPage)
        and TRADING_HOUSE_SEARCH:HasPreviousPage())
    then
        return false
    end

    self:OnManualPageInput()
    TRADING_HOUSE_SEARCH:SearchPreviousPage()
    return true
end

function UF:InstallPagingHooks(results)
    if self._pagingHooksInstalled then
        return true
    end
    if not (results and TRADING_HOUSE_SEARCH and ZO_PreHook) then
        return false
    end

    if IsCallable(results.OnLeftTrigger) then
        ZO_PreHook(results, "OnLeftTrigger", function()
            UF:OnManualPageInput()
            return false
        end)
    end

    if IsCallable(results.OnRightTrigger) then
        ZO_PreHook(results, "OnRightTrigger", function()
            UF:OnManualPageInput()
            return false
        end)
    end

    if IsCallable(results.RefreshSort) then
        ZO_PreHook(results, "RefreshSort", function()
            UF:ResetPagingState()
            return false
        end)
    end

    if TRADING_HOUSE_GAMEPAD and IsCallable(TRADING_HOUSE_GAMEPAD.EnterBrowseResults) then
        ZO_PreHook(TRADING_HOUSE_GAMEPAD, "EnterBrowseResults", function()
            UF:ResetPagingState()
            return false
        end)
    end

    TRADING_HOUSE_SEARCH:RegisterCallback("OnSearchStateChanged", function(searchState, searchOutcome)
        UF:OnNativeSearchStateChanged(searchState, searchOutcome)
    end)
    TRADING_HOUSE_SEARCH:RegisterCallback("OnSearchCriteriaChanged", function()
        UF:ResetPagingState()
    end)
    TRADING_HOUSE_SEARCH:RegisterCallback("OnSelectedGuildChanged", function()
        UF:ResetPagingState()
    end)

    self._pagingHooksInstalled = true
    return true
end
