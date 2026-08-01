-- TraderFilter v1.0.0
-- Character-specific settings
-- Persistent footer display with filter count

local ADDON_NAME = "TraderFilter"
local ADDON_VERSION = "1.0.0"

local TraderFilter = TraderFilter or {}

TraderFilter.name = ADDON_NAME
TraderFilter.version = ADDON_VERSION
TraderFilter.savedVarsVersion = 1
TraderFilter.savedVarsVersionAccount = 2
TraderFilter.keybindInjected = false

TraderFilter.realHasPreviousPage = false
TraderFilter.realHasNextPage = false
TraderFilter.realCurrentPage = 0

TraderFilter.originalCount = 0
TraderFilter.filteredCount = 0
TraderFilter.savedVars = {}

TraderFilter.defaultFilters = {
    {filter = TraderFilter.filterKnownRecipes, key = "filterKnownRecipes", type = "checkbox", name = "Hide Known Recipes", tooltip = "Hide recipes that you know!", default = true, cache = true},
    {filter = TraderFilter.filterKnownMotifs, key = "filterKnownMotifs", type = "checkbox", name = "Hide Known Motifs", tooltip = "Hide motifs that you know!", default = true, cache = true},
    {filter = TraderFilter.filterKnownStylePages, key = "filterKnownStylePages", type = "checkbox", name = "Hide Known Style Pages", tooltip = "Hide style pages that you know!", default = true, cache = true},
    {filter = TraderFilter.filterCollectedGear, key = "filterCollectedGear",  type = "checkbox", name = "Hide Collected Gear ", tooltip = "Hide collectable gear that you've collected!", default = true, cache = true},
    {filter = TraderFilter.filterNonCollectionsGear,      key = "filterNonCollectionsGear",      type = "checkbox", name = "Hide Gear That Isn't Collectable", tooltip = "Hide gear that isn't collectable!",               default = true,  cache = true },
    {filter = TraderFilter.filterCompanionGear, key = "filterCompanionGear", type = "checkbox", name = "Hide Companion Gear", tooltip = "Hide gear for companions!", default = true, cache = true},
    {filter = TraderFilter.filterAchievementScraperItems, key = "filterAchievementScraperItems", type = "checkbox", name = "Hide Collected Fragments ", tooltip = "Hide fragments to collections you've collected!", default = true, cache = true},

    {filter = TraderFilter.filterTreasureMaps, key = "filterTreasureMaps", type = "checkbox", name = "Hide Treasure Maps", tooltip = "Hide Treasure Maps", default = false, cache = true},
    {filter = TraderFilter.filterSurveys, key = "filterSurveys", type = "checkbox", name = "Hide Surveys", tooltip = "Hide Surveys", default = false, cache = true},
}

TraderFilter.defaults = {
    debugLevel = 0,
    useCharacterSettings = false,
    filterActive = false,
}

local function filterKeys()
    local keys = {}
    for k, v in pairs(TraderFilter.defaultFilters) do
        keys[v.key] = {}
    end

    return keys
end

for k, v in pairs(TraderFilter.defaultFilters) do
    TraderFilter.defaults[v.key] = v.default
end

TraderFilter.defaultAccountWide = {
    filteredIds = filterKeys(),
    accountWideProfile = TraderFilter.defaults,
}

---------------------------------------------------------
-- GetSettings
---------------------------------------------------------
function GetSettings()
    if not TraderFilter or not TraderFilter.savedVars or not TraderFilter.savedVarsAccountWide then
        return false
    end
    if TraderFilter.savedVars.useCharacterSettings then
        return TraderFilter.savedVars
    else
        return TraderFilter.savedVarsAccountWide.accountWideProfile
    end
end

---------------------------------------------------------
-- ShouldShowItem
---------------------------------------------------------
local function ShouldShowItem(itemData)
    if not itemData.itemLink or itemData.itemLink == "" then return true end
    local itemId = GetItemLinkItemId(itemData.itemLink)
    for _, v in ipairs(TraderFilter.defaultFilters) do
        if GetSettings()[v.key] then
            if not v.cache or TraderFilter.defaultAccountWide.filteredIds[v.key][tostring(itemId)] == nil then
                TraderFilter.defaultAccountWide.filteredIds[v.key][tostring(itemId)] = v.filter(itemData, itemId)
            end
            if TraderFilter.defaultAccountWide.filteredIds[v.key][tostring(itemId)] then
                return false
            end
        end
    end
    return true
end

---------------------------------------------------------
-- DEBUG
---------------------------------------------------------
local function debugLog(num, message)
    if TraderFilter.isAuthorized() and GetSettings() and GetSettings().debugLevel >= 1 then
        d(string.format("[TF|%03d] %s", num, tostring(message)))
    end
end

local function debugLog2(num, message)
    if TraderFilter.isAuthorized() and GetSettings() and GetSettings().debugLevel >= 2 then
        d(string.format("[TF|%03d] %s", num, tostring(message)))
    end
end

local function debugLog3(num, message)
    if TraderFilter.isAuthorized() and GetSettings() and GetSettings().debugLevel >= 3 then
        d(string.format("[TF|%03d] %s", num, tostring(message)))
    end
end

---------------------------------------------------------
-- CLEANUP
---------------------------------------------------------
local function CleanupTooltipsAndPanels()
    debugLog3(110, "CleanupTooltipsAndPanels")
    if GAMEPAD_TOOLTIPS then
        GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_LEFT_TOOLTIP)
        GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_RIGHT_TOOLTIP)
        GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_MOVABLE_TOOLTIP)
    end
    if ClearTooltip then ClearTooltip(ItemTooltip) end
    if TRADING_HOUSE_PREVIEW_GAMEPAD_SCENE and TRADING_HOUSE_PREVIEW_GAMEPAD_SCENE:IsShowing() then
        SCENE_MANAGER:Hide("tradingHousePreviewGamepad")
    end
    if ZO_ItemTooltip_ClearComparisonTooltip then ZO_ItemTooltip_ClearComparisonTooltip() end
end

---------------------------------------------------------
-- UPDATE PAGE DISPLAY
---------------------------------------------------------
local function UpdatePageDisplay()
    local browseResults = GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS
    if not browseResults or not browseResults.footer then return end

    local pageLabel = browseResults.footer.pageNumberLabel
    if pageLabel then
        pageLabel:SetHidden(false)

        if GetSettings().filterActive then
            -- Show filter info: "Page X [shown/total]"
            local pageText = zo_strformat(SI_GAMEPAD_PAGED_LIST_PAGE_NUMBER, TraderFilter.realCurrentPage + 1)
            local filterText = string.format(" [%d/%d]", TraderFilter.filteredCount, TraderFilter.originalCount)
            pageLabel:SetText(pageText .. filterText)
        else
            -- Normal page display
            pageLabel:SetText(zo_strformat(SI_GAMEPAD_PAGED_LIST_PAGE_NUMBER, TraderFilter.realCurrentPage + 1))
        end
    end
end

---------------------------------------------------------
-- SET EMPTY MESSAGE
---------------------------------------------------------
local function SetEmptyMessage(browseResults, message)
    if browseResults.emptyLabel then
        browseResults.emptyLabel:SetText(message)
        browseResults.emptyLabel:SetHidden(false)
    end

    if browseResults.SetEmptyText then
        browseResults:SetEmptyText(message)
    end

    if browseResults.emptyRow then
        local emptyRowLabel = browseResults.emptyRow:GetNamedChild("Message")
        if emptyRowLabel then
            emptyRowLabel:SetText(message)
        end
    end

    local control = browseResults.control or browseResults
    if control.GetNamedChild then
        local emptyLabel = control:GetNamedChild("EmptyLabel")
        if emptyLabel then
            emptyLabel:SetText(message)
            emptyLabel:SetHidden(false)
        end
    end
end

---------------------------------------------------------
-- ACTIVATE PANEL FOCUS
---------------------------------------------------------
local function ForceActivatePanelFocus()
    local browseResults = GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS
    if not browseResults then return end

    debugLog3(160, "ForceActivatePanelFocus")

    if browseResults.ActivatePanelFocus then
        success, err = pcall(function() browseResults:ActivatePanelFocus() end)
    elseif browseResults.Activate then
        success, err = pcall(function() browseResults:Activate() end)
    end

    KEYBIND_STRIP:UpdateCurrentKeybindButtonGroups()
end

---------------------------------------------------------
-- TOGGLE FILTER
---------------------------------------------------------
local function ToggleFilter()
    debugLog(500, "ToggleFilter")

    GetSettings().filterActive = not GetSettings().filterActive
    GetSettings().filterActive = GetSettings().filterActive

    debugLog(502, "Filter: " .. tostring(GetSettings().filterActive))

    if GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS then
        GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS:RefreshData()
    end

    if not GetSettings().filterActive then
        CleanupTooltipsAndPanels()
        -- Reset page display to normal
        UpdatePageDisplay()
    end

    KEYBIND_STRIP:UpdateCurrentKeybindButtonGroups()
end

---------------------------------------------------------
-- MAIN FILTER HOOK
---------------------------------------------------------
local function SetupFilterHook()
    debugLog3(600, "SetupFilterHook")

    local browseResults = GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS
    if not browseResults then
        debugLog(601, "ERROR: GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS not found")
        return
    end

    local originalFilterScrollList = browseResults.FilterScrollList

    browseResults.FilterScrollList = function(self)
        TraderFilter.realHasPreviousPage = TRADING_HOUSE_SEARCH:HasPreviousPage()
        TraderFilter.realHasNextPage = TRADING_HOUSE_SEARCH:HasNextPage()
        TraderFilter.realCurrentPage = TRADING_HOUSE_SEARCH:GetPage()

        debugLog3(610, string.format("FilterScrollList: page=%d, prev=%s, next=%s, filter=%s",
            TraderFilter.realCurrentPage,
            tostring(TraderFilter.realHasPreviousPage),
            tostring(TraderFilter.realHasNextPage),
            tostring(GetSettings().filterActive)))

        if not GetSettings().filterActive then
            TraderFilter.originalCount = 0
            TraderFilter.filteredCount = 0
            return originalFilterScrollList(self)
        end

        local scrollData = ZO_ScrollList_GetDataList(self.list)
        ZO_ClearTable(self.searchResultItemDataList)
        ZO_ClearNumericallyIndexedTable(scrollData)
        ZO_ClearNumericallyIndexedTable(self.previewListEntries)

        local originalCount = 0
        local filteredCount = 0

        if TRADING_HOUSE_SEARCH:ShouldShowGuildSpecificItems() then
            originalCount = GetNumGuildSpecificItems()
            for i = 1, originalCount do
                local itemData = TRADING_HOUSE_GAMEPAD:CreateGuildSpecificItemData(i, GetGuildSpecificItemInfo)
                if itemData then
                    if ShouldShowItem(itemData) then
                        itemData.isGuildSpecificItem = true
                        filteredCount = filteredCount + 1
                        self.searchResultItemDataList[i] = itemData
                        local dataEntry = ZO_ScrollList_CreateDataEntry(ZO_GAMEPAD_INTERACTIVE_FILTER_LIST_PRIMARY_DATA_TYPE, itemData)
                        table.insert(scrollData, dataEntry)
                    end
                end
            end
        else
            originalCount = TRADING_HOUSE_SEARCH:GetNumItemsOnPage()
            for tradingHouseIndex = 1, originalCount do
                local itemData = ZO_TradingHouse_CreateSearchResultItemData(tradingHouseIndex)
                if itemData then
                    if ShouldShowItem(itemData) then
                        filteredCount = filteredCount + 1
                        self.searchResultItemDataList[tradingHouseIndex] = itemData
                        local dataEntry = ZO_ScrollList_CreateDataEntry(ZO_GAMEPAD_INTERACTIVE_FILTER_LIST_PRIMARY_DATA_TYPE, itemData)
                        table.insert(scrollData, dataEntry)
                        if self:CanPreviewTradingHouseItem(itemData) then
                            table.insert(self.previewListEntries, tradingHouseIndex)
                        end
                    end
                end
            end
        end

        TraderFilter.originalCount = originalCount
        TraderFilter.filteredCount = filteredCount

        debugLog(620, string.format("Filtered: %d/%d", filteredCount, originalCount))

        if TRADING_HOUSE_PREVIEW_GAMEPAD_SCENE and TRADING_HOUSE_PREVIEW_GAMEPAD_SCENE:IsShowing() then
            self:UpdatePreviewForChangedData()
        end

        -- Update page display with filter counts
        UpdatePageDisplay()

        -- If filtered to 0 results but real items exist, set custom message and force panel focus
        if filteredCount == 0 and originalCount > 0 then
            SetEmptyMessage(self, "No filtered results on this page")

            zo_callLater(function()
                ForceActivatePanelFocus()
            end, 50)
        end
    end

    debugLog3(630, "FilterScrollList hooked")
end

---------------------------------------------------------
-- HOOK REFRESH PAGING CONTROLS TO MAINTAIN OUR DISPLAY
---------------------------------------------------------
local function SetupPagingHook()
    debugLog3(650, "SetupPagingHook")

    local browseResults = GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS
    if not browseResults then return end

    if browseResults.RefreshPagingControls then
        local originalRefreshPaging = browseResults.RefreshPagingControls
        browseResults.RefreshPagingControls = function(self)
            -- Call original first
            originalRefreshPaging(self)

            -- Then override with our display if filter is active
            if GetSettings().filterActive then
                UpdatePageDisplay()
            end
        end
    end

    debugLog3(660, "Paging hook complete")
end

---------------------------------------------------------
-- FOCUS AREA HOOKS - Keep panel focused when list appears empty
---------------------------------------------------------
local function SetupFocusAreaHooks()
    debugLog3(700, "SetupFocusAreaHooks")

    local browseResults = GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS
    if not browseResults then return end

    -- Hook HasEntries - critical for keeping focus on list
    if browseResults.HasEntries then
        local orig = browseResults.HasEntries
        browseResults.HasEntries = function(self)
            local result = orig(self)

            -- If filter is active and there's real data on this page, pretend we have entries
            if GetSettings().filterActive and TraderFilter.originalCount > 0 then
                if not result then
                    debugLog3(710, "HasEntries: " .. tostring(result) .. " -> FORCING TRUE")
                end
                return true
            end

            return result
        end
    else
        debugLog(712, "No HasEntries method found")
    end

    -- Hook IsEmpty
    if browseResults.IsEmpty then
        local orig = browseResults.IsEmpty
        browseResults.IsEmpty = function(self)
            local result = orig(self)

            if GetSettings().filterActive and TraderFilter.originalCount > 0 then
                if result then
                    debugLog3(720, "IsEmpty: " .. tostring(result) .. " -> FORCING FALSE")
                end
                return false
            end

            return result
        end
    else
        debugLog(722, "No IsEmpty method found")
    end

    debugLog3(740, "Focus area hooks complete")
end

---------------------------------------------------------
-- RESULTS RECEIVED - Force focus after results come in
---------------------------------------------------------
local function SetupResultsHook()
    debugLog3(800, "SetupResultsHook")

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Results", EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED, function()
        TraderFilter.realHasPreviousPage = TRADING_HOUSE_SEARCH:HasPreviousPage()
        TraderFilter.realHasNextPage = TRADING_HOUSE_SEARCH:HasNextPage()
        TraderFilter.realCurrentPage = TRADING_HOUSE_SEARCH:GetPage()

        debugLog3(810, string.format("ResultsReceived: page=%d, prev=%s, next=%s",
            TraderFilter.realCurrentPage,
            tostring(TraderFilter.realHasPreviousPage),
            tostring(TraderFilter.realHasNextPage)))

        -- If filter is active, force panel focus after results are processed
        if GetSettings().filterActive then
            zo_callLater(function()
                ForceActivatePanelFocus()
                UpdatePageDisplay()
            end, 100)
        end
    end)

    debugLog3(820, "Results hook setup")
end

---------------------------------------------------------
-- EVENT HOOKS
---------------------------------------------------------
local function SetupEventHooks()
    debugLog3(830, "SetupEventHooks")

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Open", EVENT_OPEN_TRADING_HOUSE, function()
        TraderFilter.scrapeAchievements() -- scrape between searches; they might have purchased and used something.
        TraderFilter.defaultAccountWide.filteredIds = filterKeys() -- reset this between searches.
        debugLog3(831, "Trading house opened")
        TraderFilter.keybindInjected = false
        zo_callLater(function()
            InjectFilterKeybind()
        end, 500)
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Close", EVENT_CLOSE_TRADING_HOUSE, function()
        debugLog3(832, "Trading house closed")
        CleanupTooltipsAndPanels()
    end)

    debugLog3(840, "Event hooks complete")
end

---------------------------------------------------------
-- KEYBIND INJECTION
---------------------------------------------------------
function InjectFilterKeybind()
    debugLog3(900, "InjectFilterKeybind")

    local browseResults = GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS
    if not browseResults then return false end
    if TraderFilter.keybindInjected then return true end

    local descriptor = browseResults.keybindStripDescriptor
    if not descriptor then return false end

    for _, kb in ipairs(descriptor) do
        if kb.keybind == "UI_SHORTCUT_TERTIARY" then
            debugLog3(909, "Tertiary already exists")
            return false
        end
    end

    table.insert(descriptor, {
        name = function()
            return GetSettings().filterActive and "Show All" or "Filter Known"
        end,
        keybind = "UI_SHORTCUT_TERTIARY",
        callback = function()
            debugLog3(910, "Filter keybind pressed")
            ToggleFilter()
        end,
        visible = function()
            return TRADING_HOUSE_SEARCH:GetNumItemsOnPage() > 0
        end,
        sound = SOUNDS.GAMEPAD_MENU_FORWARD,
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
    })

    TraderFilter.keybindInjected = true
    debugLog3(912, "Filter keybind injected")
    KEYBIND_STRIP:UpdateCurrentKeybindButtonGroups()
    return true
end

---------------------------------------------------------
-- SETTINGS
---------------------------------------------------------
local QR_SCENE = nil
function TraderFilter.displayQRCode(url)
    if not TraderFilterQRCode or not LibQRCode then RequestOpenUnsafeURL(url) end
    if url == nil then return end
    if not QR_SCENE then
        local qrcs = ZO_Scene:New("TraderFilterQRCode", SCENE_MANAGER)
        QR_SCENE = qrcs
        QR_SCENE:AddFragment(ZO_SimpleSceneFragment:New(TraderFilterQRCode))
    end

    LibQRCode.DrawQRCode(TraderFilterQRCodeBackdropCode, url)
    SCENE_MANAGER:Show("TraderFilterQRCode")
end

local function CreateSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "Trader Filter",
        displayName = "|cFFD700Trader Filter|r",  -- optional: colored title
        author = "@YourNameHere",                  -- use your @account name
        version = ADDON_VERSION,
        slashCommand = "/traderfilter",            -- optional: open panel with command
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel(ADDON_NAME .. "OptionsPanel", panelData)

    local optionsTable = {
        {
            type = "checkbox",
            name = "Use Character-Specific Settings",
            tooltip = "When enabled, settings are saved per character instead of account-wide.",
            getFunc = function() return TraderFilter.savedVars.useCharacterSettings end,
            setFunc = function(value)
                TraderFilter.savedVars.useCharacterSettings = value
            end,
            default = false,
        },
        {
            type = "header",
            name = "Filtering Options",
        },
        {
            type = "checkbox",
            name = "Enable Trader Filtering",
            tooltip = "Master switch — turns all filtering on/off.",
            getFunc = function() return GetSettings().filterActive end,
            setFunc = function(value) GetSettings().filterActive = value end,
            default = true,
        },
    }

    for k, v in ipairs(TraderFilter.defaultFilters) do
        table.insert(optionsTable, {
            type = v.type,
            name = v.name,
            tooltip = v.tooltip,
            getFunc = function() return GetSettings()[v.key] end,
            setFunc = function(value) GetSettings()[v.key] = value end,
            default = v.default,
        })
    end

    if TraderFilter.isAuthorized() then
        table.insert(optionsTable, {
            type = "header",
            name = "Debug",
        })

        table.insert(optionsTable, {
            type = "slider",
            name = "Debug Level",
            tooltip = "0 = Off, 1 = Errors, 2 = Warnings, 3 = Verbose",
            min = 0,
            max = 3,
            step = 1,
            getFunc = function() return GetSettings().debugLevel end,
            setFunc = function(value) GetSettings().debugLevel = value end,
            default = 0,
        })
    end

    table.insert(optionsTable, {
        type = "button",
        name = "Donate",
        tooltip = "Your donations help fund my work, thank you!",
        func = function()
           TraderFilter.displayQRCode("https://www.paypal.com/donate/?hosted_button_id=TYD4EZ6FGNXN8")
        end,
    })

    LAM:RegisterOptionControls(ADDON_NAME .. "OptionsPanel", optionsTable)
end

---------------------------------------------------------
-- SLASH COMMANDS
---------------------------------------------------------
local function SetupSlashCommands()
    SLASH_COMMANDS["/tf"] = function(args)
        if args == "" or args == "toggle" then
            ToggleFilter()
        elseif args == "on" then
            if not GetSettings().filterActive then ToggleFilter() end
        elseif args == "off" then
            if GetSettings().filterActive then ToggleFilter() end
        elseif args == "status" then
            debugLog(1, "=== STATUS ===")
            debugLog(2, "Filter: " .. tostring(GetSettings().filterActive))
            debugLog(3, "RealPage: " .. TraderFilter.realCurrentPage)
            debugLog(4, "RealHasPrev: " .. tostring(TraderFilter.realHasPreviousPage))
            debugLog(5, "RealHasNext: " .. tostring(TraderFilter.realHasNextPage))
            debugLog(6, "Shown: " .. TraderFilter.filteredCount .. "/" .. TraderFilter.originalCount)
        elseif args == "inject" then
            TraderFilter.keybindInjected = false
            InjectFilterKeybind()
        elseif args == "next" then
            debugLog(1, "Manual next page")
            TRADING_HOUSE_SEARCH:SearchNextPage()
        elseif args == "prev" then
            debugLog(1, "Manual prev page")
            TRADING_HOUSE_SEARCH:SearchPreviousPage()
        elseif args == "activate" then
            debugLog(1, "Manual ActivatePanelFocus")
            ForceActivatePanelFocus()
        else
            d("/tf [toggle|on|off|status|inject|next|prev|activate]")
        end
    end
end

---------------------------------------------------------
-- INIT
---------------------------------------------------------
local function Initialize()
	TraderFilter.savedVarsAccountWide = ZO_SavedVars:NewAccountWide("TraderFilterSavedVars", TraderFilter.savedVarsVersionAccount, nil, TraderFilter.defaultAccountWide)
    TraderFilter.savedVars = ZO_SavedVars:NewCharacterIdSettings("TraderFilterSavedVars", TraderFilter.savedVarsVersion, nil, TraderFilter.savedVarsAccountWide.accountWideProfile)

    debugLog(1000, "=== TRADERFILTER v" .. ADDON_VERSION .. " ===")

    SetupSlashCommands()
    CreateSettingsMenu()
    SetupEventHooks()
    SetupResultsHook()

    zo_callLater(function()
        if GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS then
            SetupFilterHook()
            SetupPagingHook()
            SetupFocusAreaHooks()
            debugLog(1005, "All hooks installed")
        else
            debugLog(1004, "ERROR: Browse results not found")
        end
    end, 2000)
    
    debugLog(1010, "Init complete")
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end
    Initialize()
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
_G[ADDON_NAME] = TraderFilter