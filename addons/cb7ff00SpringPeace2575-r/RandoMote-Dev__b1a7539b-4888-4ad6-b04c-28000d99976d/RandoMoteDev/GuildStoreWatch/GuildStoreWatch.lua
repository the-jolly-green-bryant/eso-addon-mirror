-----------------------------------------------------------
-- Author: SpringPeace2575 | Version: 0.9.0
-- GuildStoreWatch add-on
-----------------------------------------------------------

GuildStoreWatch = GuildStoreWatch or {}
local GSW = GuildStoreWatch
local GSWResults = GuildStoreWatchResults
local GSWGui = GuildStoreWatchGui
local GSWTrader = GuildStoreWatchTrader

GSW.name = "GuildStoreWatch"
GSW.displayName = "Guild Store Watch"
GSW.version = "0.9.0"
GSW.savedVarName = "GuildStoreWatchSavedVars"
GSW.variableVersion = 1
GSW.settingsPanelId = "GuildStoreWatchPanel"
GSW.commandSlashCommand = "/gsw"

GSW.state = {
    menuRegistered = false,
    settingsRegistered = false,
}

GSW.defaults = {
    maxResults = 5000,
    captureSearchResponses = true,
    capturePageResponses = true,
    keepUncollectedItemsOnly = false,
    showCheapestItemsOnly = true,
    showUncollectedItemsOnly = false,
    enablePageRotation = true,
    deleteOnConfirmationOnly = true,
    deleteWholeItem = false,
    clearOnConfirmationOnly = true,
    trimResults = false,
    orderedByName = false,
    debug = false,
    enable = false,

    -- collections, values by ix
    results = {},
    items = {},
    contexts = {},
    sellers = {},
    locations = {},
    traders = {},
    guilds = {},
    searches = {},

    resultsCount = 0,
    resultsLength = 0,
}

function GSW.InitializeSavedVars()
    -- GSW.sv.gsw = ZO_SavedVars:NewAccountWide(GSW.savedVarName, GSW.variableVersion, nil, GSW.defaults, GetWorldName())
    if type(GSW.sv.gsw.maxResults) ~= "number" then GSW.sv.gsw.maxResults = GSW.defaults.maxResults end
    if type(GSW.sv.gsw.captureSearchResponses) ~= "boolean" then GSW.sv.gsw.captureSearchResponses = GSW.defaults.captureSearchResponses end
    if type(GSW.sv.gsw.capturePageResponses) ~= "boolean" then GSW.sv.gsw.capturePageResponses = GSW.defaults.capturePageResponses end
    if type(GSW.sv.gsw.keepUncollectedItemsOnly) ~= "boolean" then GSW.sv.gsw.keepUncollectedItemsOnly = GSW.defaults.keepUncollectedItemsOnly end
    if type(GSW.sv.gsw.showCheapestItemsOnly) ~= "boolean" then GSW.sv.gsw.showCheapestItemsOnly = GSW.defaults.showCheapestItemsOnly end
    if type(GSW.sv.gsw.showUncollectedItemsOnly) ~= "boolean" then GSW.sv.gsw.showUncollectedItemsOnly = GSW.defaults.showUncollectedItemsOnly end
    if type(GSW.sv.gsw.enablePageRotation) ~= "boolean" then GSW.sv.gsw.enablePageRotation = GSW.defaults.enablePageRotation end
    if type(GSW.sv.gsw.deleteWholeItem) ~= "boolean" then GSW.sv.gsw.deleteWholeItem = GSW.defaults.deleteWholeItem end
    if type(GSW.sv.gsw.deleteOnConfirmationOnly) ~= "boolean" then GSW.sv.gsw.deleteOnConfirmationOnly = GSW.defaults.deleteOnConfirmationOnly end
    if type(GSW.sv.gsw.clearOnConfirmationOnly) ~= "boolean" then GSW.sv.gsw.clearOnConfirmationOnly = GSW.defaults.clearOnConfirmationOnly end
    if type(GSW.sv.gsw.trimResults) ~= "boolean" then GSW.sv.gsw.trimResults = GSW.defaults.trimResults end
    if type(GSW.sv.gsw.orderedByName) ~= "boolean" then GSW.sv.gsw.orderedByName = GSW.defaults.orderedByName end
    if type(GSW.sv.gsw.debug) ~= "boolean" then GSW.sv.gsw.debug = GSW.defaults.debug end
    if type(GSW.sv.gsw.enable) ~= "boolean" then GSW.sv.gsw.enable = GSW.defaults.enable end
    if type(GSW.sv.gsw.results) ~= "table" then GSW.sv.gsw.results = {} end
    if type(GSW.sv.gsw.items) ~= "table" then GSW.sv.gsw.items = {} end
    if type(GSW.sv.gsw.contexts) ~= "table" then GSW.sv.gsw.contexts = {} end
    if type(GSW.sv.gsw.sellers) ~= "table" then GSW.sv.gsw.sellers = {} end
    if type(GSW.sv.gsw.locations) ~= "table" then GSW.sv.gsw.locations = {} end
    if type(GSW.sv.gsw.traders) ~= "table" then GSW.sv.gsw.traders = {} end
    if type(GSW.sv.gsw.guilds) ~= "table" then GSW.sv.gsw.guilds = {} end
    if type(GSW.sv.gsw.searches) ~= "table" then GSW.sv.gsw.searches = {} end

    if type(GSW.sv.gsw.resultsCount) ~= "number" then GSW.sv.gsw.resultsCount = GSW.defaults.resultsCount end
    if type(GSW.sv.gsw.resultsLength) ~= "number" then GSW.sv.gsw.resultsLength = GSW.defaults.resultsLength end
end

function GSW.GetSettingsOptions()
    return SPFLibUtils.ConcatArrays(SPFLibUtils.GetDonationSettingsOptions("RandoMoteDev"), { -- TODO: use GSW.name when separated
        {
            type = "description",
            text = function()
                return string.format("Saved rows: |cffffff%d|r", GSW.sv.gsw.resultsCount)
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Capture manual search results",
            tooltip = "Store result rows when a manual Trading House search completes.",
            default = GSW.defaults.captureSearchResponses,
            getFunc = function() return GSW.sv.gsw.captureSearchResponses end,
            setFunc = function(value) GSW.sv.gsw.captureSearchResponses = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Capture manual page changes",
            tooltip = "Store result rows when moving to another Trading House results page.",
            default = GSW.defaults.capturePageResponses,
            getFunc = function() return GSW.sv.gsw.capturePageResponses end,
            setFunc = function(value) GSW.sv.gsw.capturePageResponses = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Keep uncollected items only",
            -- TODO: this tooltip must be changed when there will be defined list for which items is the collectible/learnable relevant
            -- TODO: GSW.uncollectedFilterNamePrefixes and GSW.uncollectedFilterItemTypes, now it is wrongly aplied to all items if this switch is on
            tooltip = "If enabled, only items that are currently learnable/collectible are imported for the configured scope. If no scope lists are configured, this applies to all items.",
            default = GSW.defaults.keepUncollectedItemsOnly,
            getFunc = function() return GSW.sv.gsw.keepUncollectedItemsOnly end,
            setFunc = function(value) GSW.sv.gsw.keepUncollectedItemsOnly = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show cheapest items only",
            tooltip = "If enabled, the custom GSW screen opens in Cheapest view. If disabled, it opens in All Rows view.",
            default = GSW.defaults.showCheapestItemsOnly,
            getFunc = function() return GSW.sv.gsw.showCheapestItemsOnly end,
            setFunc = function(value) GSW.sv.gsw.showCheapestItemsOnly = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show uncollected items only",
            tooltip = "Main menu view defaults to uncollected items only. If enabled, the custom GSW screen opens with hidden collected items. If disabled, it opens with collected items included.",
            default = GSW.defaults.showUncollectedItemsOnly,
            getFunc = function() return GSW.sv.gsw.showUncollectedItemsOnly end,
            setFunc = function(value) GSW.sv.gsw.showUncollectedItemsOnly = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Enable page rotation",
            tooltip = "If enabled, it is possible to go from first page to last page and vice versa.",
            default = GSW.defaults.enablePageRotation,
            getFunc = function() return GSW.sv.gsw.enablePageRotation end,
            setFunc = function(value) GSW.sv.gsw.enablePageRotation = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Delete on confirmation only",
            tooltip = "Delete of selected item will require confirmation",
            default = GSW.defaults.deleteOnConfirmationOnly,
            getFunc = function() return GSW.sv.gsw.deleteOnConfirmationOnly end,
            setFunc = function(value) GSW.sv.gsw.deleteOnConfirmationOnly = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Delete whole item",
            tooltip = "Delete all results for the selected item",
            default = GSW.defaults.deleteWholeItem,
            getFunc = function() return GSW.sv.gsw.deleteWholeItem end,
            setFunc = function(value) GSW.sv.gsw.deleteWholeItem = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Clear on confirmation only",
            tooltip = "Clear of items on current view or all stored items will require confirmation",
            default = GSW.defaults.clearOnConfirmationOnly,
            getFunc = function() return GSW.sv.gsw.clearOnConfirmationOnly end,
            setFunc = function(value) GSW.sv.gsw.clearOnConfirmationOnly = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Trim results",
            tooltip = "When max saved results limit is exceeded, older results are discarded",
            default = GSW.defaults.trimResults,
            getFunc = function() return GSW.sv.gsw.trimResults end,
            setFunc = function(value) GSW.sv.gsw.trimResults = value end,
            width = "full",
        },
        {
            type = "slider",
            name = "Max saved results",
            tooltip = "Older saved results are discarded once this limit is exceeded if Trim results option is enabled, otherwise no more results are saved.",
            min = 1000,
            max = 99000,
            step = 1000,
            default = GSW.defaults.maxResults,
            getFunc = function() return GSW.sv.gsw.maxResults end,
            setFunc = function(value) GSW.sv.gsw.maxResults = value end,
            width = "full",
        },
        {
            type = "button",
            name = "Clear saved rows",
            buttonText = "Clear",
            func = function()
                GSWGui.RequestClearAllRows()
            end,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Debug chat output",
            default = GSW.defaults.debug,
            getFunc = function() return GSW.sv.gsw.debug end,
            setFunc = function(value) GSW.sv.gsw.debug = value end,
            width = "full",
        },
    })
end

function GSW.RegisterSettings()
    if GSW.state.settingsRegistered then return end
    GSW.state.settingsRegistered = true

    local panelData = {
        type = "panel",
        name = GSW.name,
        displayName = GSW.displayName,
        author = "SpringPeace2575",
        version = GSW.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local options = GSW.GetSettingsOptions()

    SPFLibSettings.RegisterSettingsPanel(GSW.settingsPanelId, panelData, options, GSW.defaults, GSW.sv.gsw)
end

function GSW.RegisterMenu()
    if GSW.state.menuRegistered then return end
    GSW.state.menuRegistered = true

    local menuData = {
        name = function() return GSW.displayName end,
        icon = "EsoUI/Art/Icons/mapkey/mapkey_guildkiosk.dds",
        scene = GSWGui.state.menuSceneName,
    }

    SPFLibMainMenu.AddMainMenuEntry(menuData, SPFLibMainMenu.GetActivityFinderIndex())
end

function GSW.RefreshFull()
    SPFLibSettings.RefreshSettings()
    GSWGui.RefreshAll()
end

function GSW.RegisterSlashCommands()
    SLASH_COMMANDS[GSW.commandSlashCommand] = function(text)
        text = SPFLibUtils.Trim(text)
        local command, rest = text:match("^(%S+)%s*(.-)$")
        command = SPFLibUtils.Lower(command or "")

        if command == "" or command == "h" then
            d("[GSW] /gsw b")
            d("[GSW] /gsw r [index]")
            d("[GSW] /gsw i [index]")
            d("[GSW] /gsw c [index]")
            return
        elseif command == "b" then
            GSWResults.DebugCounts()
        elseif command == "r" then
            local rxText = rest:match("^(%d+)$")
            if rxText then
                GSWResults.DebugResult(tonumber(rxText))
            end
        elseif command == "i" then
            local ixText = rest:match("^(%d+)$")
            if ixText then
                GSWResults.DebugItem(tonumber(ixText))
            end
        elseif command == "c" then
            local cxText = rest:match("^(%d+)$")
            if cxText then
                GSWResults.DebugContext(tonumber(cxText))
            end
        else
            d("GSW: Unknown command. Use /gsw h")
        end
    end
end

-- TODO: this is for testing the event only, but probably it is close to final, so only will be moved somewhere
function GSW.RecheckSetItems(itemSetId)
    local itemKey = GSWResults.GetSetItemKey(itemSetId)
    GSWResults.Debug("EVENT_ITEM_SET_COLLECTIONS_UPDATED - " .. tostring(itemKey))
    local refreshed = GSWResults.RecheckUncollectedItem(itemKey)
    if refreshed > 0 then
        local name = GetItemSetName(itemSetId)
        GSWResults.Debug("Item collected - ".. tostring(itemKey) .. " - " .. tostring(name))
    else
        GSWResults.Debug("EVENT_ITEM_SET_COLLECTIONS_UPDATED had no effect - " .. tostring(itemKey))
    end
end

function GSW.RecheckRecipeItem(recipeListIndex, recipeIndex)
    local itemKey = GSWResults.GetRecipeItemKey(recipeListIndex, recipeIndex)
    GSWResults.Debug("EVENT_RECIPE_LEARNED - " .. tostring(itemKey))
    local refreshed = GSWResults.RecheckUncollectedItem(itemKey)
    if refreshed > 0 then
        local _, name = GetRecipeInfo(recipeListIndex, recipeIndex)
        GSWResults.Debug("Item collected - ".. tostring(itemKey) .. " - " .. tostring(name))
    else
        GSWResults.Debug("EVENT_RECIPE_LEARNED had no effect - " .. tostring(itemKey))
    end
end

function GSW.RecheckMotifItem(itemStyleId, chapterIndex)
    local itemKey = GSWResults.GetMotifItemKey(itemStyleId)
    GSWResults.Debug("EVENT_STYLE_LEARNED - " .. tostring(itemKey))
    local refreshed = GSWResults.RecheckUncollectedItem(itemKey)
    if refreshed > 0 then
        GSWResults.RefreshMotifCacheEntry(itemStyleId)
        local name = GetItemStyleName(itemStyleId)
        GSWResults.Debug("Item collected - ".. tostring(itemKey) .. " - " .. tostring(name))
    else
        GSWResults.Debug("EVENT_STYLE_LEARNED had no effect - " .. tostring(itemKey))
    end
end

function GSW.OnItemSetCollectionsUpdated(itemSetIds)
    if not itemSetIds then
        return
    end

    for _, itemSetId in ipairs(itemSetIds) do
        zo_callLater(function() GSW.RecheckSetItems(itemSetId) end, 1000)
    end
end

function GSW.OnItemSetCollectionUpdated(itemSetId, slotsJustUnlockedMask)
    --[[ local slotsJustUnlocked = { GetItemSetCollectionSlotsInMask(slotsJustUnlockedMask) }
    if #slotsJustUnlocked > 0 then
        for _, slotJustUnlocked in ipairs(slotsJustUnlocked) do
            table.insert(self.queuedSlotsJustUnlocked,
            {
                itemSetId = itemSetId,
                slot = slotJustUnlocked,
            })
        end

        EVENT_MANAGER:RegisterForUpdate("ZO_ItemSetCollectionsDataManager_SlotsJustUnlocked", 100, function() self:OnUpdateSlotsJustUnlocked() end)
    end ]]
    zo_callLater(function() GSW.RecheckSetItems(itemSetId) end, 1000)
end

function GSW.OnRecipeLearned(recipeListIndex, recipeIndex) zo_callLater(function() GSW.RecheckRecipeItem(recipeListIndex, recipeIndex) end, 1000) end

function GSW.OnStyleLearned(itemStyleId, chapterIndex, isDefaultRacialStyle)
    if not isDefaultRacialStyle then
        zo_callLater(function() GSW.RecheckMotifItem(itemStyleId, chapterIndex) end, 1000)
    end
end

function GSW.RegisterEvents()
    local eventNamespace = GSW.name .. "_Results"
    EVENT_MANAGER:RegisterForEvent(eventNamespace, EVENT_COLLECTIBLES_UNLOCK_STATE_CHANGED, function(_, ...) GSWResults.OnCollectiblesUnlockStateChanged(...) end)
    EVENT_MANAGER:RegisterForEvent(eventNamespace, EVENT_RECIPE_LEARNED, function(_, ...) GSW.RecheckRecipeItem(...) end)
	EVENT_MANAGER:RegisterForEvent(eventNamespace, EVENT_STYLE_LEARNED, function(_, ...) GSW.OnStyleLearned(...) end)
    EVENT_MANAGER:RegisterForEvent(eventNamespace, EVENT_ITEM_SET_COLLECTIONS_UPDATED, function(_, ...) GSW.OnItemSetCollectionsUpdated(...) end)
    EVENT_MANAGER:RegisterForEvent(eventNamespace, EVENT_ITEM_SET_COLLECTION_UPDATED, function(_, ...) GSW.OnItemSetCollectionUpdated(...) end)
end
-- TODO: this is for testing the event only, but probably it is close to final, so only will be moved somewhere

function GSW.Initialize(savedVariables)
    GSW.sv = savedVariables
    if not GSW.sv or not GSW.sv.gsw then
        -- msg("GSW: savedVars unavilable")
        return
    end
    -- msg("GSW: "..tostring(GSW.sv.gsw.enable))
    if not GSW.sv.gsw.enable then return end

    GSW.InitializeSavedVars()
    GSWResults.Initialize(GSW.sv.gsw, GSW.RefreshFull)
    GSWTrader.Initialize(GSW.sv.gsw, GSW.name, GSWResults.StoreCurrentSearchResults, GSWResults.ClearRowsForTraderSearch, GSW.RefreshFull)
    GSW.RegisterSettings()
    GSW.RegisterSlashCommands() -- TODO: remove after debug
    GSWGui.Initialize(GSW.sv.gsw, GSWResults)
    GSW.RegisterMenu()
    GSW.RegisterEvents()

    d("[GSW] Initialized")
end
