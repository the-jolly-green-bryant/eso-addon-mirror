-----------------------------------------------------------
-- Author: SpringPeace2575 | Version: 1.2.0
-- CollectThemAll add-on
-----------------------------------------------------------

CollectThemAll = CollectThemAll or {}
local CTA = CollectThemAll
local CTAResults = CollectThemAllResults
local CTAGui = CollectThemAllGui
local CTAScanner = CollectThemAllScanner

CTA.name = "CollectThemAll"
CTA.displayName = "Collect Them All"
CTA.savedVarsName = "CollectThemAllSavedVars"
CTA.settingsPanelId = "CollectThemAllPanel"
CTA.version = "1.2.0"

CTA.savedVarsVersion = 1
CTA.commandSlashCommand = "/cta"

CTA.state = {
    menuRegistered = false,
    settingsRegistered = false,
}

CTA.defaults = {
    showUncollectedItemsOnly = false,
    rebuildOnDemandOnly = true,
    enablePageRotation = true,
    showIcons = true,
    orderedBy = 3,
    debug = false,
    enable = true,

    selectedCategory = "All",
    selectedSubcategory = "All",
    selectedSource = "All",
    selectedGroup = "All",

    -- collections, values by ix
    results = {},
    categories = {},
    subcategories = {},
    sources = {},
    groups = {},
    types = {},

    collectedCount = 0,
    totalCount = 0,

    lastVersion = "0.0.1",
    nextVersion = nil,
}

function CTA.InitializeSavedVars()
    if type(CTA.sv.showUncollectedItemsOnly) ~= "boolean" then CTA.sv.showUncollectedItemsOnly = CTA.defaults.showUncollectedItemsOnly end
	if type(CTA.sv.rebuildOnDemandOnly) ~= "boolean" then CTA.sv.rebuildOnDemandOnly = CTA.defaults.rebuildOnDemandOnly end
    if type(CTA.sv.enablePageRotation) ~= "boolean" then CTA.sv.enablePageRotation = CTA.defaults.enablePageRotation end
    if type(CTA.sv.showIcons) ~= "boolean" then CTA.sv.showIcons = CTA.defaults.showIcons end
    if type(CTA.sv.orderedBy) ~= "number" then CTA.sv.orderedBy = CTA.defaults.orderedBy end
    if type(CTA.sv.selectedCategory) ~= "string" then CTA.sv.selectedCategory = CTA.defaults.selectedCategory end
    if type(CTA.sv.selectedSubcategory) ~= "string" then CTA.sv.selectedSubcategory = CTA.defaults.selectedSubcategory end
    if type(CTA.sv.selectedSource) ~= "string" then CTA.sv.selectedSource = CTA.defaults.selectedSource end
    if type(CTA.sv.selectedGroup) ~= "string" then CTA.sv.selectedGroup = CTA.defaults.selectedGroup end
    if type(CTA.sv.debug) ~= "boolean" then CTA.sv.debug = CTA.defaults.debug end
    if type(CTA.sv.enable) ~= "boolean" then CTA.sv.enable = CTA.defaults.enable end
    if type(CTA.sv.results) ~= "table" then CTA.sv.results = {} end
    if type(CTA.sv.categories) ~= "table" then CTA.sv.categories = {} end
    if type(CTA.sv.subcategories) ~= "table" then CTA.sv.subcategories = {} end
    if type(CTA.sv.sources) ~= "table" then CTA.sv.sources = {} end
    if type(CTA.sv.groups) ~= "table" then CTA.sv.groups = {} end
    if type(CTA.sv.types) ~= "table" then CTA.sv.types = {} end

    if type(CTA.sv.collectedCount) ~= "number" then CTA.sv.collectedCount = CTA.defaults.collectedCount end
    if type(CTA.sv.totalCount) ~= "number" then CTA.sv.totalCount = CTA.defaults.totalCount end

    if type(CTA.sv.lastVersion) ~= "string" then CTA.sv.lastVersion = CTA.defaults.lastVersion end
    CTA.sv.nextVersion = CTA.version
end

function CTA.GetSettingsOptions()
    return SPFLibUtils.ConcatArrays(SPFLibUtils.GetDonationSettingsOptions(CTA.name), {
        --[[ {
            type = "description",
            text = function()
                return string.format("Saved results: |cffffff%d / %d|r", CTA.sv.collectedCount, CTA.sv.totalCount)
            end,
            width = "full",
        }, ]]{
            type = "checkbox",
            name = "Enable",
			tooltip = "Enable or disable collectible catalog.",
            default = CTA.defaults.enable,
            getFunc = function() return CTA.sv.enable end,
            setFunc = function(value) CTA.sv.enable = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show uncollected items only",
            tooltip = "Main menu view defaults to uncollected items only. If enabled, the custom CTA screen opens with hidden collected items. If disabled, it opens with collected items included.",
            default = CTA.defaults.showUncollectedItemsOnly,
            getFunc = function() return CTA.sv.showUncollectedItemsOnly end,
            setFunc = function(value) CTA.sv.showUncollectedItemsOnly = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Rebuild on demand only",
            tooltip = "If enabled, the results will be rebuild on demand only or when it is necessery (first time, version change). Button for rebuild is below these options and bellow filters in the catalog.",
            default = CTA.defaults.rebuildOnDemandOnly,
            getFunc = function() return CTA.sv.rebuildOnDemandOnly end,
            setFunc = function(value) CTA.sv.rebuildOnDemandOnly = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Enable page rotation",
            tooltip = "If enabled, it is possible to go from first page to last page and vice versa.",
            default = CTA.defaults.enablePageRotation,
            getFunc = function() return CTA.sv.enablePageRotation end,
            setFunc = function(value) CTA.sv.enablePageRotation = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show icons",
            tooltip = "If enabled, icons will be visible. Switch off when you hit ESOUI addons limitation.",
            default = CTA.defaults.showIcons,
            getFunc = function() return CTA.sv.showIcons end,
            setFunc = function(value) CTA.sv.showIcons = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Debug chat output",
            default = CTA.defaults.debug,
            getFunc = function() return CTA.sv.debug end,
            setFunc = function(value) CTA.sv.debug = value end,
            width = "full",
        },
        {
            type = "button",
            name = "Rebuild saved results",
            buttonText = "Rebuild",
            func = function()
                CTAResults.Build(true)
            end,
            width = "half",
        },
    })
end

function CTA.RegisterSettings()
    if CTA.state.settingsRegistered then return end
    CTA.state.settingsRegistered = true

    local panelData = {
        type = "panel",
        name = CTA.name,
        displayName = CTA.displayName,
        author = "SpringPeace2575",
        version = CTA.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local options = CTA.GetSettingsOptions()

    SPFLibSettings.RegisterSettingsPanel(CTA.settingsPanelId, panelData, options, CTA.defaults, CTA.sv)
end

function CTA.RegisterMenu()
    if CTA.state.menuRegistered then return end
    CTA.state.menuRegistered = true

    local menuData = {
        name = function() return CTA.displayName end,
        icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_collections.dds",
        scene = CTAGui.state.menuSceneName,
    }

    SPFLibMainMenu.AddMainMenuEntry(menuData, SPFLibMainMenu.GetActivityFinderIndex())
end

function CTA.RefreshFull()
    SPFLibSettings.RefreshSettings()
    CTAGui.RefreshAll()
end

function CTA.TestCategories()
    for categoryIndex = 1, GetNumCollectibleCategories() do
        local nameC, numSC, u3, unlockedC, totalC, u6 = GetCollectibleCategoryInfo(categoryIndex)
        local categoryId = GetCollectibleCategoryId(categoryIndex)
        d(string.format(
            "[CTA] CIX: %d, CID: %d - %s, %s, %s, %s, %s, %s",
            categoryIndex,
            categoryId,
            SPFLibUtils.SafeText(nameC),
            SPFLibUtils.SafeText(numSC),
            SPFLibUtils.SafeText(u3),
            SPFLibUtils.SafeText(unlockedC),
            SPFLibUtils.SafeText(totalC),
            SPFLibUtils.SafeText(u6)
        ))
        for subcategoryIndex = 1, GetNumSubcategoriesInCollectibleCategory(categoryIndex) do
            local nameSC, v2, unlockedSC, totalSC = GetCollectibleSubCategoryInfo(categoryIndex, subcategoryIndex)
            local subcategoryId = GetCollectibleCategoryId(categoryIndex, subcategoryIndex)
            d(string.format(
                "[CTA] CIX: %d, SIX: %d, SID: %d - %s, %s, %s, %s",
                categoryIndex,
                subcategoryIndex,
                subcategoryId,
                SPFLibUtils.SafeText(nameSC),
                SPFLibUtils.SafeText(v2),
                SPFLibUtils.SafeText(unlockedSC),
                SPFLibUtils.SafeText(totalSC)
            ))
            -- GetNumCollectiblesInCollectibleCategory(categoryIndex, subcategoryIndex)
            -- GetCollectibleCategoryType(collectibleId)
        end
    end
end

function CTA.TestCollectible(collectibleId)
    local categoryIndex, subcategoryIndex, itemIndex = GetCategoryInfoFromCollectibleId(collectibleId)
    d(string.format(
        "[CTA] Collectible ID: %d - %s, %s, %s",
        collectibleId,
        SPFLibUtils.SafeText(categoryIndex),
        SPFLibUtils.SafeText(subcategoryIndex),
        SPFLibUtils.SafeText(itemIndex)
    ))
end

function CTA.RegisterSlashCommands()
    SLASH_COMMANDS[CTA.commandSlashCommand] = function(text)
        text = SPFLibUtils.Trim(text)
        local command, rest = text:match("^(%S+)%s*(.-)$")
        command = SPFLibUtils.Lower(command or "")

        if command == "" or command == "h" then
            d("[CTA] /cta b           - debug counts")
            d("[CTA] /cta c           - display subcategories")
            d("[CTA] /cta t [id]      - test collectible")
            d("[CTA] /cta r [index]   - debug result [index]")
            d("[CTA] /cta s           - rescan collection items and prepare output")
            d("[CTA] /cta x           - reset output cursor to the start")
            d("[CTA] /cta n           - print next batch (default 10 lines)")
            d("[CTA] /cta n [count]   - print next [count] lines")
            d("[CTA] /cta h           - show help")
            return
        elseif command == "b" then
            CTAResults.DebugCounts()
        elseif command == "c" then
            CTA.TestCategories()
        elseif command == "t" then
            local idText = rest:match("^(%d+)$")
            if idText then
                CTA.TestCollectible(tonumber(idText))
            end
        elseif command == "r" then
            local rxText = rest:match("^(%d+)$")
            if rxText then
                CTAResults.DebugResult(tonumber(rxText))
            end
        elseif command == "s" then
            CTAScanner.Scan()
        elseif command == "x" then
            CTAScanner.ResetCursor()
        elseif command == "n" then
            local countText = rest:match("^(%d+)$")
            CTAScanner.PrintNextBatch(countText)
        else
            d("[CTA] Unknown command. Use /cta h")
        end
    end
end

function CTA.RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(CTA.name .. "_Results", EVENT_COLLECTIBLES_UNLOCK_STATE_CHANGED, function(_, ...)
        CTAResults.OnCollectiblesUnlockStateChanged(...)
    end)
end

function CTA.Initialize(savedVariables, dev)
    if dev == true then
        CTA.sv = savedVariables
        if not CTA.sv then
            d("[CTA] SavedVars unavilable")
            return
        end
    else
        CTA.sv = ZO_SavedVars:NewAccountWide(CTA.savedVarsName, CTA.savedVarsVersion, nil, CTA.defaults, GetWorldName())
    end

    CTA.InitializeSavedVars()
    
    zo_callLater(function()
        CTAResults.Initialize(CTA.sv, CTA.RefreshFull)
        CTA.RegisterSettings()

        -- CTA.RegisterSlashCommands() -- TODO: remove after debug
        zo_callLater(function()
            CTAGui.Initialize(CTA.sv, CTAResults)
            CTA.RegisterMenu()
            CTA.RegisterEvents()

            d("[CTA] Initialized")
        end, 2000)
    end, 3000)
end

function CTA.Activate()

end

function CTA.OnAddOnLoaded(eventCode, addonName)
    if addonName ~= CTA.name then return end

    EVENT_MANAGER:UnregisterForEvent(CTA.name, EVENT_ADD_ON_LOADED)

    CTA.Initialize({}, false)
    CTA.Activate()
end
