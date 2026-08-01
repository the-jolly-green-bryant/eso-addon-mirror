--- @class (partial) CustomAbilityIcons
local CustomAbilityIcons = CustomAbilityIcons

local LAM2 = LibAddonMenu2

--- Initializes saved variables and configures their corresponding menus, using LibAddonMenu2 (if it exists).
function CustomAbilityIcons.InitializeSettings()
    CustomAbilityIcons.CONFIG = ZO_SavedVars:NewAccountWide("CustomAbilityIcons_SavedVariables", CustomAbilityIcons.SAVEDVARIABLES_VERSION, nil, CustomAbilityIcons.DEFAULT_ADDON_CONFIG)
    CustomAbilityIcons.CleanupAccountWideSettings(CustomAbilityIcons_SavedVariables, CustomAbilityIcons.DEFAULT_ADDON_CONFIG, nil)

    CustomAbilityIcons.GLOBALSETTINGS = ZO_SavedVars:NewAccountWide("CustomAbilityIcons_Globals", CustomAbilityIcons.SAVEDVARIABLES_VERSION, "global_settings",  CustomAbilityIcons.DEFAULT_SETTINGS)
    CustomAbilityIcons.CleanupAccountWideSettings(CustomAbilityIcons_Globals, CustomAbilityIcons.DEFAULT_SETTINGS, "global_settings")

    CustomAbilityIcons.CHARACTERSETTINGS = ZO_SavedVars:NewCharacterIdSettings("CustomAbilityIcons_Settings", CustomAbilityIcons.SAVEDVARIABLES_VERSION, "character_settings", CustomAbilityIcons.DEFAULT_SETTINGS)
    CustomAbilityIcons.CleanupCharacterIdSettings(CustomAbilityIcons_Settings, CustomAbilityIcons.DEFAULT_SETTINGS, "character_settings")

    if LAM2 == nil then return end

    local panelData = {
		type = "panel",
		name = "Custom Ability Icons",
		displayName = "Custom Ability Icons",
		author = "Vartalus & Iresil",
		version = CustomAbilityIcons.version,
		slashCommand = "/caigb",	-- (optional) will register a keybind to open to this panel
		registerForRefresh = true,	-- boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
		registerForDefaults = true	-- boolean (optional) (will set all options controls back to default values)
	}

	LAM2:RegisterAddonPanel("CustomAbilityIcons_Panel", panelData)

	local optionsData = {
        {
            type = "header",
            name = "Настройки",
        },
        {
            type = "checkbox",
            name = "Одинаковые настройки для всех персонажей",
            getFunc = function()
                return CustomAbilityIcons.CONFIG.saveSettingsGlobally
            end,
            setFunc = CustomAbilityIcons.SetOptionGlobalIcons
        },
        {
            type = "checkbox",
            name = "Иконки стилей навыков на панели способностей",
            getFunc = function()
                return CustomAbilityIcons:GetSettings().showSkillStyleIcons
            end,
            setFunc = CustomAbilityIcons.SetOptionSkillStyleIcons
        },
        {
            type = "checkbox",
            name = "Новые иконки чарописи на панели способностей",
            getFunc = function()
                return CustomAbilityIcons:GetSettings().showCustomScribeIcons
            end,
            setFunc = CustomAbilityIcons.SetOptionCustomIcons
        },
        {
            type = "checkbox",
            name = "Заменить несоответствующие базовые иконки",
            getFunc = function()
                return CustomAbilityIcons:GetSettings().replaceMismatchedBaseIcons
            end,
            setFunc = CustomAbilityIcons.SetOptionMismatchedIcons
        }
    }

    LAM2:RegisterOptionControls("CustomAbilityIcons_Panel", optionsData)
end

--- Retrieves the saved settings, whether global or per character (and the default settings if nothing was previously saved).
function CustomAbilityIcons.GetSettings()
	if CustomAbilityIcons.CONFIG and CustomAbilityIcons.CONFIG.saveSettingsGlobally then
		return CustomAbilityIcons.GLOBALSETTINGS or CustomAbilityIcons.DEFAULT_SETTINGS
	else
        return CustomAbilityIcons.CHARACTERSETTINGS or CustomAbilityIcons.DEFAULT_SETTINGS
    end
end

--- Cleanup account-wide settings from previous versions.
--- @param savedVars table Contains the current account-wide saved variables.
--- @param defaultConfig table Contains the default account-wide saved variables.
--- @param namespace string? The sub-table (if any) in which the saved variables are stored.
function CustomAbilityIcons.CleanupAccountWideSettings(savedVars, defaultConfig, namespace)
    local currentConfig = savedVars["Default"][GetDisplayName()]["$AccountWide"]
    if namespace then
        currentConfig = currentConfig[namespace]
    end
    for key, _ in pairs(currentConfig) do
        if key ~= "version" and defaultConfig[key] == nil then
            currentConfig[key] = nil
        end
    end
end

--- Cleanup character id settings from previous versions.
--- @param savedVars table Contains the current character id saved variables.
--- @param defaultConfig table Contains the default character id saved variables.
--- @param namespace string? The sub-table (if any) in which the saved variables are stored.
function CustomAbilityIcons.CleanupCharacterIdSettings(savedVars, defaultConfig, namespace)
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
end

--- Set the setting for global (Account Wide) icons to on/off
--- @param value boolean
function CustomAbilityIcons.SetOptionGlobalIcons(value)
    local oldSettings = CustomAbilityIcons:GetSettings()
    CustomAbilityIcons.CONFIG.saveSettingsGlobally = value
    CustomAbilityIcons:GetSettings().showSkillStyleIcons = oldSettings.showSkillStyleIcons
    CustomAbilityIcons:GetSettings().showCustomScribeIcons = oldSettings.showCustomScribeIcons
    CustomAbilityIcons:GetSettings().replaceMismatchedBaseIcons = oldSettings.replaceMismatchedBaseIcons
end

--- Set the setting for skill style icons to on/off
--- @param value boolean
function CustomAbilityIcons.SetOptionSkillStyleIcons(value)
    CustomAbilityIcons:GetSettings().showSkillStyleIcons = value
    CustomAbilityIcons.OnCollectibleUpdated()
end

--- Set the setting for custom scribed icons to on/off
--- @param value boolean
function CustomAbilityIcons.SetOptionCustomIcons(value)
    CustomAbilityIcons:GetSettings().showCustomScribeIcons = value
    CustomAbilityIcons.OnCollectibleUpdated()
end

--- Set the setting for mismatched icons to on/off
--- @param value boolean
function CustomAbilityIcons.SetOptionMismatchedIcons(value)
    CustomAbilityIcons:GetSettings().replaceMismatchedBaseIcons = value
    CustomAbilityIcons.ReplaceMismatchedIcons()
end
