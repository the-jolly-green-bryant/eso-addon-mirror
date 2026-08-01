--- @class (partial) AbilityIconsFramework

local AbilityIconsFramework = AbilityIconsFramework
local LAM2 = LibAddonMenu2

AbilityIconsFramework.DEFAULT_SETTINGS = {
    version = AbilityIconsFramework.SAVEDVARIABLES_VERSION,
    showSkillStyleIcons = false,
    showCustomScribeIcons = true,
    replaceMismatchedBaseIcons = true,
    enableHeroismPotionIcons = true,
    autoTypeConfirm = false,
	fixVas = false,
    iconPacksData = {},
    resolution = 256
}

AbilityIconsFramework.resolutionChoices = {
    64,
    128,
    256
}

local currentIconsResolution = 256

AbilityIconsFramework.packSortOrderEntries = {}

function AbilityIconsFramework.InitializeSortOrderEntries()
    AbilityIconsFramework.packSortOrderEntries = {}
    local currentIdx = 1
    for packDirectoryString, packData in AbilityIconsFramework.packPairs() do
        if packData ~= nil then
            AbilityIconsFramework.packSortOrderEntries[currentIdx] = {
                value = packDirectoryString,
                uniqueKey = currentIdx,
                text = "|t45:45:" .. packData.packExampleTexture .. "|t" .. " " .. packData.packDisplayName,
            }
            currentIdx = currentIdx + 1
        end
    end
end

local function UpdatePackLoadOrderFromSortEntries()
    local settings = AbilityIconsFramework:GetSettings()
    for entryIdx, entryData in ipairs(AbilityIconsFramework.packSortOrderEntries) do
        settings.iconPacksData[entryData.value].loadOrder = entryIdx
    end
end

function AbilityIconsFramework.GetHighestIconPackOrder()
    local max = 0
    for _, PackData in AbilityIconsFramework.packPairs() do
        if PackData ~= nil and PackData.loadOrder > max then
            max = PackData.loadOrder
        end
    end
    return max
end

--- Initializes saved variables and configures their corresponding menus, using LibAddonMenu2 (if it exists).
function AbilityIconsFramework.InitializeSettings()
    AbilityIconsFramework.CONFIG = ZO_SavedVars:NewAccountWide("AbilityIconsFramework_SavedVariables", AbilityIconsFramework.SAVEDVARIABLES_VERSION, nil, AbilityIconsFramework.DEFAULT_ADDON_CONFIG)
    AbilityIconsFramework.CleanupAccountWideSettings(AbilityIconsFramework_SavedVariables, AbilityIconsFramework.DEFAULT_ADDON_CONFIG, nil)

    AbilityIconsFramework.GLOBALSETTINGS = ZO_SavedVars:NewAccountWide("AbilityIconsFramework_Globals", AbilityIconsFramework.SAVEDVARIABLES_VERSION, "global_settings", AbilityIconsFramework.DEFAULT_SETTINGS)
    AbilityIconsFramework.CleanupAccountWideSettings(AbilityIconsFramework_Globals, AbilityIconsFramework.DEFAULT_SETTINGS, "global_settings")

    AbilityIconsFramework.CHARACTERSETTINGS = ZO_SavedVars:NewCharacterIdSettings("AbilityIconsFramework_Settings", AbilityIconsFramework.SAVEDVARIABLES_VERSION, "character_settings", AbilityIconsFramework.DEFAULT_SETTINGS)
    AbilityIconsFramework.CleanupCharacterIdSettings(AbilityIconsFramework_Settings, AbilityIconsFramework.DEFAULT_SETTINGS, "character_settings")

    currentIconsResolution = AbilityIconsFramework:GetSettings().resolution

    AbilityIconsFramework.InitBaseIconsPath()

    if LAM2 == nil then return end

    local panelData = {
        type = "panel",
        name = "Ability Icons Framework",
        displayName = "|c66b2b2Ability|r |cffbf00Icons|r |c6C3BAAFramework|r",
        author = "|ce6202dKwiebe-Kwibus|r & Asquart",
        version = AbilityIconsFramework.version,
        website = "https://www.esoui.com/downloads/info4061-AbilityIconsFramework.html",
        slashCommand = "/aifgb",
        registerForRefresh = true,
        registerForDefaults = true
    }

    LAM2:RegisterAddonPanel("AbilityIconsFramework_Panel", panelData)

    local optionsData = {
        {
            type = "header",
            name = "Settings",
        },
        {
            type = "checkbox",
            name = "Use the same settings for all characters",
            getFunc = function()
                return AbilityIconsFramework.CONFIG.saveSettingsGlobally
            end,
            setFunc = AbilityIconsFramework.SetOptionGlobalIcons
        },
        {
            type = "checkbox",
            name = "Use Custom Scribed Ability Icons",
            getFunc = function()
                return AbilityIconsFramework:GetSettings().showCustomScribeIcons
            end,
            setFunc = AbilityIconsFramework.SetOptionCustomIcons
        },
        {
            type = "checkbox",
            name = "Replace Base Game Icons",
            getFunc = function()
                return AbilityIconsFramework:GetSettings().replaceMismatchedBaseIcons
            end,
            setFunc = AbilityIconsFramework.SetOptionMismatchedIcons
        },
        {
            type = "checkbox",
            name = "Enable Heroism Potion Icons",
            getFunc = function()
                return AbilityIconsFramework:GetSettings().enableHeroismPotionIcons
            end,
            setFunc = AbilityIconsFramework.SetHeroismPotionIconsEnabled
        },
        {
            type = "dropdown",
            name = "Base game icons resolution",
            tooltip = 'Texture resolution to use for default game icons',
            choices = AbilityIconsFramework.resolutionChoices,
            scrollable = false,
            getFunc = function() return AbilityIconsFramework:GetSettings().resolution end,
            setFunc = function(selected)
                for _, resolution in ipairs(AbilityIconsFramework.resolutionChoices) do
                    if resolution == selected then
                        AbilityIconsFramework:GetSettings().resolution = resolution
                        break
                    end
                end
            end,
            default = AbilityIconsFramework:GetSettings().resolution,
            warning = "Requires /reloadui to apply the changes"
        },
        {
            type = "button",
            name = "Reload UI",
            width = "full",
            func = function() ReloadUI("ingame") end,
            disabled = function() return AbilityIconsFramework:GetSettings().resolution == currentIconsResolution end
        },
		{
			type = "checkbox",
			name = "Fix vAS",
			tooltip = "Forces the active combat tip icons to 64x64 pixels to prevent them from becoming massive during Veteran Asylum Sanctorium.",
			getFunc = function() return AbilityIconsFramework:GetSettings().fixVas end,
			setFunc = AbilityIconsFramework.SetOptionFixVas
		},
        {
            type = "submenu",
            name = "Icon Packs load order",
            controls = {
                {
                    type = "orderlistbox",
                    name = "Icon pack priority",
                    listEntries = AbilityIconsFramework.packSortOrderEntries,
                    disableDrag = false,
                    disableButtons = true,
                    showPosition = true,
                    getFunc = function() return AbilityIconsFramework.packSortOrderEntries end,
                    setFunc = function(sortedSortListEntries)
                        AbilityIconsFramework.packSortOrderEntries = sortedSortListEntries
                        UpdatePackLoadOrderFromSortEntries()
                        AbilityIconsFramework.ApplyPackLoadOrderChanges()
                    end,
                    width = "full",
                    isExtraWide = true,
                    rowFont = "ZoFontWinH1",
                    minHeight = 250,
                    maxHeight = 400,
                    rowHeight = 45,
                    showRemoveEntryButton = false,
                },
            }
        },
      --  {
      --      type = "header",
       --     name = "Non visual settings",
      --  },
       -- {
       --     type = "checkbox",
       --     name = "Auto-fill confirmation dialogs",
       --     tooltip = 'Automatically fills the required CONFIRM/DELETE/etc text into confirmation dialogs.',
        --    getFunc = function()
        --        return AbilityIconsFramework:GetSettings().autoTypeConfirm
        --    end,
       --     setFunc = AbilityIconsFramework.SetAutoTypeConfirmEnabled
       -- }
    }

    LAM2:RegisterOptionControls("AbilityIconsFramework_Panel", optionsData)
end

--- Retrieves the saved settings, whether global or per character (and the default settings if nothing was previously saved).
function AbilityIconsFramework.GetSettings()
    if AbilityIconsFramework.CONFIG and AbilityIconsFramework.CONFIG.saveSettingsGlobally then
        return AbilityIconsFramework.GLOBALSETTINGS or AbilityIconsFramework.DEFAULT_SETTINGS
    else
        return AbilityIconsFramework.CHARACTERSETTINGS or AbilityIconsFramework.DEFAULT_SETTINGS
    end
end

--- Cleanup account-wide settings from previous versions.
--- @param savedVars table Contains the current account-wide saved variables.
--- @param defaultConfig table Contains the default account-wide saved variables.
--- @param namespace string? The sub-table (if any) in which the saved variables are stored.
function AbilityIconsFramework.CleanupAccountWideSettings(savedVars, defaultConfig, namespace)
    local currentConfig = savedVars["Default"][GetDisplayName()]["$AccountWide"]
    if namespace then
        currentConfig = currentConfig[namespace]
    end

    for key, _ in pairs(currentConfig) do
        if key ~= "version" and defaultConfig[key] == nil then
            currentConfig[key] = nil
        end
    end

    -- Cleanup mismatchedIcons table
    if currentConfig.mismatchedIcons then
        for iconName, _ in pairs(currentConfig.mismatchedIcons) do
            if defaultConfig.mismatchedIcons[iconName] == nil then
                currentConfig.mismatchedIcons[iconName] = nil
            end
        end
    end
end

function AbilityIconsFramework.CleanupCharacterIdSettings(savedVars, defaultConfig, namespace)
    local characterKey = GetCurrentCharacterId()
    local currentConfig = savedVars["Default"][GetDisplayName()][characterKey]
    if namespace then
        currentConfig = currentConfig[namespace]
    end

    for key, _ in pairs(currentConfig) do
        if key ~= "version" and defaultConfig[key] == nil then
            currentConfig[key] = nil
        end
    end

    -- Cleanup mismatchedIcons table
    if currentConfig.mismatchedIcons then
        for iconName, _ in pairs(currentConfig.mismatchedIcons) do
            if defaultConfig.mismatchedIcons[iconName] == nil then
                currentConfig.mismatchedIcons[iconName] = nil
            end
        end
    end
end

--- Set the setting for global (Account Wide) icons to on/off
--- @param value boolean
function AbilityIconsFramework.SetOptionGlobalIcons(value)
    local oldSettings = AbilityIconsFramework:GetSettings()
    AbilityIconsFramework.CONFIG.saveSettingsGlobally = value
    AbilityIconsFramework:GetSettings().showSkillStyleIcons = oldSettings.showSkillStyleIcons
    AbilityIconsFramework:GetSettings().showCustomScribeIcons = oldSettings.showCustomScribeIcons
    AbilityIconsFramework:GetSettings().replaceMismatchedBaseIcons = oldSettings.replaceMismatchedBaseIcons
    AbilityIconsFramework:GetSettings().autoTypeConfirm = oldSettings.autoTypeConfirm
    AbilityIconsFramework.UpdateAllSlots()
end

--- Set the setting for skill style icons to on/off
--- @param value boolean
function AbilityIconsFramework.SetOptionSkillStyleIcons(value)
    AbilityIconsFramework:GetSettings().showSkillStyleIcons = value
    AbilityIconsFramework.UpdateAllSlots()
end

--- Set the setting for custom scribed icons to on/off
--- @param value boolean
function AbilityIconsFramework.SetOptionCustomIcons(value)
    AbilityIconsFramework:GetSettings().showCustomScribeIcons = value
    AbilityIconsFramework.UpdateDefaultScribingIcons()
    AbilityIconsFramework.UpdateAllSlots()
end

--- Set the setting for mismatched icons to on/off
--- @param value boolean
function AbilityIconsFramework.SetOptionMismatchedIcons(value)
    AbilityIconsFramework:GetSettings().replaceMismatchedBaseIcons = value
    AbilityIconsFramework.ReplaceMismatchedIcons()
    AbilityIconsFramework.UpdateAllSlots()
end

--- Set the setting for enabling heroism potion icons to on/off
--- @param value boolean
function AbilityIconsFramework.SetHeroismPotionIconsEnabled(value)
    AbilityIconsFramework:GetSettings().enableHeroismPotionIcons = value
    AbilityIconsFramework.UpdateAllSlots()
end

--- Set the setting for auto-fill confirmation dialogs to on/off
--- @param value boolean
function AbilityIconsFramework.SetAutoTypeConfirmEnabled(value)
    AbilityIconsFramework:GetSettings().autoTypeConfirm = value
end

--- Set the setting for fixing vAS combat tips to on/off
--- @param value boolean
function AbilityIconsFramework.SetOptionFixVas(value)
    AbilityIconsFramework:GetSettings().fixVas = value
    AbilityIconsFramework.ApplyFixVas()
end

function AbilityIconsFramework.ApplyPackLoadOrderChanges()
    AbilityIconsFramework.ResetAllTextureRedirects()
    AbilityIconsFramework.GenerateReplacementLists()
    AbilityIconsFramework.ReplaceMismatchedIcons()
    AbilityIconsFramework.UpdateDefaultScribingIcons()
    AbilityIconsFramework.UpdateAllSlots()
end
