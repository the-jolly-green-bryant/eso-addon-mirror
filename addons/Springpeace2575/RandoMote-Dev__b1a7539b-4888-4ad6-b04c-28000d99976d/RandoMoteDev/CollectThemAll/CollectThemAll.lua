-----------------------------------------------------------
-- Author: SpringPeace2575 | Version: 0.9.0
-- CollectThemAll add-on
-----------------------------------------------------------

CollectThemAll = CollectThemAll or {}
local CTA = CollectThemAll
local CTAResults = CollectThemAllResults
local CTAGui = CollectThemAllGui
local CTAScanner = CollectThemAllScanner

CTA.name = "CollectThemAll"
CTA.displayName = "Collect Them All"
CTA.version = "0.9.0"
CTA.savedVarName = "CollectThemAllSavedVars"
CTA.variableVersion = 1
CTA.settingsPanelId = "CollectThemAllPanel"
CTA.commandSlashCommand = "/cta"

CTA.state = {
    menuRegistered = false,
    settingsRegistered = false,
}

CTA.defaults = {
    showUncollectedItemsOnly = false,
    enablePageRotation = true,
    showIcons = true,
    orderedBy = 3,
    debug = false,
    enable = false,

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
}

function CTA.InitializeSavedVars()
    -- CTA.sv.cta = ZO_SavedVars:NewAccountWide(CTA.savedVarName, CTA.variableVersion, nil, CTA.defaults, GetWorldName())
    if type(CTA.sv.cta.showUncollectedItemsOnly) ~= "boolean" then CTA.sv.cta.showUncollectedItemsOnly = CTA.defaults.showUncollectedItemsOnly end
    if type(CTA.sv.cta.enablePageRotation) ~= "boolean" then CTA.sv.cta.enablePageRotation = CTA.defaults.enablePageRotation end
    if type(CTA.sv.cta.showIcons) ~= "boolean" then CTA.sv.cta.showIcons = CTA.defaults.showIcons end
    if type(CTA.sv.cta.orderedBy) ~= "number" then CTA.sv.cta.orderedBy = CTA.defaults.orderedBy end
    if type(CTA.sv.cta.selectedCategory) ~= "string" then CTA.sv.cta.selectedCategory = CTA.defaults.selectedCategory end
    if type(CTA.sv.cta.selectedSubcategory) ~= "string" then CTA.sv.cta.selectedSubcategory = CTA.defaults.selectedSubcategory end
    if type(CTA.sv.cta.selectedSource) ~= "string" then CTA.sv.cta.selectedSource = CTA.defaults.selectedSource end
    if type(CTA.sv.cta.selectedGroup) ~= "string" then CTA.sv.cta.selectedGroup = CTA.defaults.selectedGroup end
    if type(CTA.sv.cta.debug) ~= "boolean" then CTA.sv.cta.debug = CTA.defaults.debug end
    if type(CTA.sv.cta.enable) ~= "boolean" then CTA.sv.cta.enable = CTA.defaults.enable end
    if type(CTA.sv.cta.results) ~= "table" then CTA.sv.cta.results = {} end
    if type(CTA.sv.cta.categories) ~= "table" then CTA.sv.cta.categories = {} end
    if type(CTA.sv.cta.subcategories) ~= "table" then CTA.sv.cta.subcategories = {} end
    if type(CTA.sv.cta.sources) ~= "table" then CTA.sv.cta.sources = {} end
    if type(CTA.sv.cta.groups) ~= "table" then CTA.sv.cta.groups = {} end
    if type(CTA.sv.cta.types) ~= "table" then CTA.sv.cta.types = {} end

    if type(CTA.sv.cta.collectedCount) ~= "number" then CTA.sv.cta.collectedCount = CTA.defaults.collectedCount end
    if type(CTA.sv.cta.totalCount) ~= "number" then CTA.sv.cta.totalCount = CTA.defaults.totalCount end
end

function CTA.GetSettingsOptions()
    return SPFLibUtils.ConcatArrays(SPFLibUtils.GetDonationSettingsOptions("RandoMoteDev"), { -- TODO: use CTA.name when separated
        --[[ {
            type = "description",
            text = function()
                return string.format("Saved results: |cffffff%d / %d|r", CTA.sv.cta.collectedCount, CTA.sv.cta.totalCount)
            end,
            width = "full",
        }, ]]
        {
            type = "checkbox",
            name = "Show uncollected items only",
            tooltip = "Main menu view defaults to uncollected items only. If enabled, the custom CTA screen opens with hidden collected items. If disabled, it opens with collected items included.",
            default = CTA.defaults.showUncollectedItemsOnly,
            getFunc = function() return CTA.sv.cta.showUncollectedItemsOnly end,
            setFunc = function(value) CTA.sv.cta.showUncollectedItemsOnly = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Enable page rotation",
            tooltip = "If enabled, it is possible to go from first page to last page and vice versa.",
            default = CTA.defaults.enablePageRotation,
            getFunc = function() return CTA.sv.cta.enablePageRotation end,
            setFunc = function(value) CTA.sv.cta.enablePageRotation = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show icons",
            tooltip = "If enabled, icons will be visible. Switch off when you hit ESOUI addons limitation.",
            default = CTA.defaults.showIcons,
            getFunc = function() return CTA.sv.cta.showIcons end,
            setFunc = function(value) CTA.sv.cta.showIcons = value end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Debug chat output",
            default = CTA.defaults.debug,
            getFunc = function() return CTA.sv.cta.debug end,
            setFunc = function(value) CTA.sv.cta.debug = value end,
            width = "full",
        },
        {
            type = "button",
            name = "Rebuild saved results",
            buttonText = "Rebuild",
            func = function()
                CTAResults.Build()
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

    SPFLibSettings.RegisterSettingsPanel(CTA.settingsPanelId, panelData, options, CTA.defaults, CTA.sv.cta)
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
            "CTA: CIX: %d, CID: %d - %s, %s, %s, %s, %s, %s",
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
                "CTA: CIX: %d, SIX: %d, SID: %d - %s, %s, %s, %s",
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
        "CTA: Collectible ID: %d - %s, %s, %s",
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
            d("CTA: Unknown command. Use /cta h")
        end
    end
end

function CTA.RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(CTA.name .. "_Results", EVENT_COLLECTIBLES_UNLOCK_STATE_CHANGED, function(_, ...)
        CTAResults.OnCollectiblesUnlockStateChanged(...)
    end)
end

function CTA.Initialize(savedVariables)
    CTA.sv = savedVariables
    if not CTA.sv or not CTA.sv.cta then
        -- msg("CTA: savedVars unavilable")
        return
    end
    -- msg("CTA: "..tostring(CTA.sv.cta.enable))
    if not CTA.sv.cta.enable then return end

    CTA.InitializeSavedVars()
    
    zo_callLater(function()
        CTAResults.Initialize(CTA.sv.cta, CTA.RefreshFull)
        CTA.RegisterSettings()
    end, 1000)

    CTA.RegisterSlashCommands() -- TODO: remove after debug
    CTAGui.Initialize(CTA.sv.cta, CTAResults)
    CTA.RegisterMenu()
    CTA.RegisterEvents()

    d("[CTA] Initialized")
end
