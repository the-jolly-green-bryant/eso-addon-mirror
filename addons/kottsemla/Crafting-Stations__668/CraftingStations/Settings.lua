--Local constants -------------------------------------------------------------
local L = CraftingStations.Localization
local PINTYPE_NAME = CraftingStations.PINTYPE_NAME
local KEYBOARD_TOOLTIP_STYLES = CraftingStations.KEYBOARD_TOOLTIP_STYLES
local KEYBOARD_TOOLTIP_STYLE_FULL = unpack(KEYBOARD_TOOLTIP_STYLES)

-- Pin -----------------------------------------------------------------------
local pinTexturesList = {}
for i = 1, 12 do
    pinTexturesList[i] = L[string.format("SETTINGS_MAP_PIN_ICON_%d_LABEL", i)]
end

local pinTextures = {
    [1] = "esoui/art/icons/poi/poi_crafting_complete.dds",
    [2] = "CraftingStations/Icons/white_x.dds",
    [3] = "CraftingStations/Icons/green_dot.dds",
    [4] = "esoui/art/actionbar/passiveabilityframe_round_over.dds",
    [5] = "esoui/art/ava/hookpoint_oil_over.dds",
    -- more icons thanks to Scootworks
    [6] = "esoui/art/crafting/smithing_refine_emptyslot.dds",
    [7] = "esoui/art/tutorial/gamepad/gp_questtypeicon_crafting.dds",
    [8] = "esoui/art/tutorial/gamepad/gp_overview_menuicon_bonus.dds",
    [9] = "esoui/art/tutorial/gamepad/gp_overview_menuicon_scoring.dds",
    [10] = "esoui/art/icons/guildranks/guild_indexicon_recruit_down.dds",
    [11] = "esoui/art/hud/radialicon_cancel_over.dds",
    [12] = "esoui/art/miscellaneous/gamepad/gp_bullet_ochre.dds",
}

--Default values --------------------------------------------------------------
local defaults = {
    showCraftingStations = true,
    showTamrielStations = true,
    showOnlyDiscovered = false,
    showDivider = true,
    pinTexture = {
        path = "esoui/art/icons/poi/poi_crafting_complete.dds",
        size = 40,
        level = 51,
    },
    pinColor = { 0.75, 1, 0.75, 1 },
    showSets = {}, --since there aren't any options for this anymore don't really need to update it for each (new) set
    tooltipEnabled = true,
    tooltipStyle = KEYBOARD_TOOLTIP_STYLE_FULL,
    altAlign = true,
    linePadding = -8,
}

local function CreateSettingsMenu()
    local LAM = LibAddonMenu2
    local LMP = LibMapPins

    -- Load / Create saved variable file
    local savedVariables = ZO_SavedVars:NewCharacterIdSettings("CRAFTINGSTATIONS_DB", 2, nil, defaults)
    if(savedVariables.tooltipEnabled == nil) then
        savedVariables.tooltipEnabled = defaults.tooltipEnabled
    end

    local panelData = {
        type = "panel",
        name = "Crafting Stations",
        displayName = "|cEFEBBECrafting Stations|r",
        author = "Kottsemla (updated by sirinsidiator)",
        version = "1.19.7",
        slashCommand = "/cssettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    local settingsPanel = LAM:RegisterAddonPanel("Crafting_Stations", panelData)

    local optionsData = {}
    local function AddControl(type, data)
        data.type = type
        optionsData[#optionsData + 1] = data
    end

    local function AddHeader(data) AddControl("header", data) end
    local function AddIconPicker(data) AddControl("iconpicker", data) end
    local function AddSlider(data) AddControl("slider", data) end
    local function AddColorPicker(data) AddControl("colorpicker", data) end
    local function AddCheckbox(data) AddControl("checkbox", data) end
    local function AddDropdown(data) AddControl("dropdown", data) end

    AddHeader({
        name = L["SETTINGS_GENERAL_OPTIONS_HEADER"]
    })

    AddIconPicker({
        name = L["SETTINGS_MAP_PIN_ICON_LABEL"],
        tooltip = L["SETTINGS_MAP_PIN_ICON_DESCRIPTION"],
        choices = pinTextures,
        choicesTooltips = pinTexturesList,
        getFunc = function() return savedVariables.pinTexture.path end,
        setFunc = function(selected)
            savedVariables.pinTexture.path = selected
            LMP:SetLayoutKey(PINTYPE_NAME, "texture", selected)
            LMP:RefreshPins(PINTYPE_NAME)
        end,
        default = pinTextures[1]
    })

    AddSlider({
        name = L["SETTINGS_MAP_PIN_SIZE_LABEL"],
        tooltip = L["SETTINGS_MAP_PIN_SIZE_DESCRIPTION"],
        min = 20,
        max = 70,
        getFunc = function() return savedVariables.pinTexture.size end,
        setFunc = function(size)
            savedVariables.pinTexture.size = size
            LMP:SetLayoutKey(PINTYPE_NAME, "size", size)
            LMP:RefreshPins(PINTYPE_NAME)
        end,
        default = defaults.pinTexture.size
    })

    AddColorPicker({
        name = L["SETTINGS_MAP_PIN_COLOR_LABEL"],
        tooltip = L["SETTINGS_MAP_PIN_COLOR_DESCRIPTION"],
        getFunc = function() return unpack(savedVariables.pinColor) end,
        setFunc = function(r,g,b,a)
            savedVariables.pinColor = {r,g,b,a}
            LMP:GetLayoutKey(PINTYPE_NAME, "tint"):SetRGBA(r,g,b,a)
            LMP:RefreshPins(PINTYPE_NAME)
        end,
        default = ZO_ColorDef:New(unpack(defaults.pinColor))
    })

    AddHeader({
        name = L["SETTINGS_FILTER_OPTIONS_HEADER"]
    })

    AddCheckbox({
        name = L["SETTINGS_SHOW_PINS_ON_TAMRIEL_MAP_LABEL"],
        tooltip = L["SETTINGS_SHOW_PINS_ON_TAMRIEL_MAP_DESCRIPTION"],
        getFunc = function() return savedVariables.showTamrielStations end,
        setFunc = function(value) savedVariables.showTamrielStations = value end,
        default = defaults.showTamrielStations
    })

    AddCheckbox({
        name = L["SETTINGS_SHOW_PINS_ONLY_WHEN_DISCOVERED_LABEL"],
        tooltip = L["SETTINGS_SHOW_PINS_ONLY_WHEN_DISCOVERED_DESCRIPTION"],
        getFunc = function() return savedVariables.showOnlyDiscovered end,
        setFunc = function(value) savedVariables.showOnlyDiscovered = value end,
        default = defaults.showOnlyDiscovered
    })

    AddHeader({
        name = L["SETTINGS_TOOLTIP_OPTIONS_HEADER"]
    })

    AddCheckbox({
        name = L["SETTINGS_TOOLTIP_ENABLED_LABEL"],
        tooltip = L["SETTINGS_TOOLTIP_ENABLED_DESCRIPTION"],
        getFunc = function() return savedVariables.tooltipEnabled end,
        setFunc = function(value) savedVariables.tooltipEnabled = value end,
        default = defaults.tooltipEnabled
    })

    local function TooltipsDisabled()
        return not savedVariables.tooltipEnabled
    end

    AddDropdown({
        name = L["SETTINGS_TOOLTIP_STYLE_LABEL"],
        tooltip = L["SETTINGS_TOOLTIP_STYLE_DESCRIPTION"],
        choices = KEYBOARD_TOOLTIP_STYLES,
        getFunc = function() return savedVariables.tooltipStyle end,
        setFunc = function(value) savedVariables.tooltipStyle = value end,
        default = defaults.tooltipStyle,
        disabled = TooltipsDisabled
    })

    AddCheckbox({
        name = L["SETTINGS_ALTERNATIVE_TOOLTIP_ALIGNMENT_LABEL"],
        tooltip = L["SETTINGS_ALTERNATIVE_TOOLTIP_ALIGNMENT_DESCRIPTION"],
        getFunc = function() return savedVariables.altAlign end,
        setFunc = function(value) savedVariables.altAlign = value end,
        default = defaults.altAlign,
        disabled = TooltipsDisabled
    })

    AddSlider({
        name = L["SETTINGS_TOOLTIP_LINE_PADDING_LABEL"],
        tooltip = L["SETTINGS_TOOLTIP_LINE_PADDING_DESCRIPTION"],
        min = -10,
        max = 0,
        getFunc = function() return savedVariables.linePadding end,
        setFunc = function(value) savedVariables.linePadding = value end,
        default = defaults.linePadding,
        disabled = TooltipsDisabled
    })

    LAM:RegisterOptionControls("Crafting_Stations", optionsData)

    return savedVariables
end
CraftingStations.CreateSettingsMenu = CreateSettingsMenu
