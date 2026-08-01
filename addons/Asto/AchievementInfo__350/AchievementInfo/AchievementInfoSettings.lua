--[[
    AchievementInfo
    @author Asto, @Astarax
]]



-- Function to determine if Account Wide Settings should be used
function AchievementInfo.loadUseAccountWideSettings()
    return ZO_SavedVars:New("ACHIEVEMENT_INFO_DB_USE_AW", 1, nil, {
        enabled = false
    })
end



-- Function to set and load the Saved Variables
function AchievementInfo.loadSavedVars()
    local defaults = {
        genEnabled              = true,
        genShowEveryUpdate      = true,
        genShowUpdateSteps      = 25,
        genShowDetails          = false,
        genShowOpenDetailsOnly  = true,
        genOnePerLine           = true,
        cat1  = true,
        cat2  = true,
        cat3  = true,
        cat4  = true,
        cat5  = true,
        cat6  = true,
        cat7  = true,
        cat8  = true,
        cat9  = true,
        cat10 = true,
        cat11 = true,
        cat12 = true,
        cat13 = true,
        cat14 = true,
        cat15 = true,
        cat16 = true,
        cat17 = true,
        cat18 = true,
        cat19 = true,
        cat20 = true,
        cat21 = true,
        cat22 = true,
        -- ... new one default to true
        devDebug                = false
    }

    if AchievementInfo.useAccountWideSettings["enabled"] == true then
        return ZO_SavedVars:NewAccountWide("ACHIEVEMENT_INFO_DB", 1, nil, defaults)
    end

    return ZO_SavedVars:New("ACHIEVEMENT_INFO_DB", 1, nil, defaults)
end



-- Function to create the settings panel
function AchievementInfo.createSettingsPanel()
    local panelData = {
        type = "panel",
        name = AchievementInfo.name,
        displayName = AchievementInfo.clrDefault .. AchievementInfo.name,
        author = AchievementInfo.author,
        version = string.format("%.2f", AchievementInfo.version),
        slashCommand = "/achievementInfo"
    }

    local optionsTable = {
        [1] = {
            type = "header",
            name = AchievementInfo.clrSettingsHeader .. LANG.SettingsHeader.General
        },
        [2] = {
            type = "checkbox",
            name = LANG.SettingsOption.AddOnEnabled,
            tooltip = LANG.SettingsOption.AddOnEnabledTooltip,
            getFunc = function() return AchievementInfo.settingGet("genEnabled") end,
            setFunc = function() AchievementInfo.settingToogle("genEnabled") end,
            warning = LANG.SettingsOption.AddOnEnabledWarning
        },
        [3] = {
            type = "checkbox",
            name = LANG.SettingsOption.AccountWideEnabled,
            tooltip = LANG.SettingsOption.AccountWideEnabledTooltip,
            getFunc = function() return AchievementInfo.useAccountWideSettings["enabled"] end,
            setFunc = function() AchievementInfo.toggleAccountWideSettings() end,
            requiresReload = true
        },
        [4] = {
            type = "checkbox",
            name = LANG.SettingsOption.ShowEveryUpdate,
            tooltip = LANG.SettingsOption.ShowEveryUpdateTooltip,
            getFunc = function() return AchievementInfo.settingGet("genShowEveryUpdate") end,
            setFunc = function() AchievementInfo.settingToogle("genShowEveryUpdate") end
        },
        [5] = {
            type = "slider",
            name = LANG.SettingsOption.ShowUpdateSteps,
            tooltip = LANG.SettingsOption.ShowUpdateStepsTooltip,
            min = 1,
            max = 100,
            step = 1,
            getFunc = function() return AchievementInfo.settingGet("genShowUpdateSteps") end,
            setFunc = function(value) AchievementInfo.settingSet("genShowUpdateSteps", value) end,
            default = 25
        },
        [6] = {
            type = "checkbox",
            name = LANG.SettingsOption.ShowDetails,
            tooltip = LANG.SettingsOption.ShowDetailsTooltip,
            getFunc = function() return AchievementInfo.settingGet("genShowDetails") end,
            setFunc = function() AchievementInfo.settingToogle("genShowDetails") end
        },
        [7] = {
            type = "checkbox",
            name = LANG.SettingsOption.ShowOpenDetailsOnly,
            tooltip = LANG.SettingsOption.ShowOpenDetailsOnlyTooltip,
            getFunc = function() return AchievementInfo.settingGet("genShowOpenDetailsOnly") end,
            setFunc = function() AchievementInfo.settingToogle("genShowOpenDetailsOnly") end
        },
        [8] = {
            type = "checkbox",
            name = LANG.SettingsOption.OneElementPerLine,
            tooltip = LANG.SettingsOption.OneElementPerLineTooltip,
            getFunc = function() return AchievementInfo.settingGet("genOnePerLine") end,
            setFunc = function() AchievementInfo.settingToogle("genOnePerLine") end,
            warning = LANG.SettingsOption.OneElementPerLineWarning
        },
        [9] = {
            type = "header",
            name = AchievementInfo.clrSettingsHeader .. LANG.SettingsHeader.Categories
        },
        [10] = {
            type = "description",
            text = LANG.SettingsHeader.CategoriesDescription .. ":"
        }
    }

    -- Add categories dynamically
    local numCats = GetNumAchievementCategories()

    for i = 1, numCats, 1 do
        catName = GetAchievementCategoryInfo(i)

        table.insert(optionsTable, {
            type = "checkbox",
            name = catName,
            tooltip = LANG.SettingsOption.CategoryTooltip .. " '" .. catName .. "'",
            getFunc = function() return AchievementInfo.settingGetForCategory("cat" .. i) end,
            setFunc = function() AchievementInfo.settingToogle("cat" .. i) end
        })
    end

    -- Debug setting at the end
    table.insert(optionsTable, {
		type = "header",
		name = AchievementInfo.clrSettingsHeader .. LANG.SettingsHeader.Development
	})

    table.insert(optionsTable, {
        type = "checkbox",
        name = LANG.SettingsOption.DebugMode,
        tooltip = LANG.SettingsOption.DebugModeTooltip,
        getFunc = function() return AchievementInfo.settingGet("devDebug") end,
        setFunc = function() AchievementInfo.settingToogle("devDebug") end,
        warning = LANG.SettingsOption.DebugModeWarning
    })

    -- Register
    LibAddonMenu2:RegisterAddonPanel(AchievementInfo.name .. "SettingsPanel", panelData)
    LibAddonMenu2:RegisterOptionControls(AchievementInfo.name .. "SettingsPanel", optionsTable)
end



-- Function to retrieve settings
function AchievementInfo.settingGet(id)
    if AchievementInfo.savedVars[id] == nil then
        AchievementInfo.savedVars[id] = false
        return false
    else
        return AchievementInfo.savedVars[id]
    end
end



-- Function to retrieve settings for categories (default true)
function AchievementInfo.settingGetForCategory(id)
    if AchievementInfo.savedVars[id] == nil then
        AchievementInfo.savedVars[id] = true
        return true
    else
        return AchievementInfo.savedVars[id]
    end
end



-- Function to toggle Checkbox values
function AchievementInfo.settingToogle(id)
    if AchievementInfo.savedVars[id] == false then
        AchievementInfo.savedVars[id] = true
    else
        AchievementInfo.savedVars[id] = false
    end
end



-- Function to toggle Checkbox value for accountWideSettings
function AchievementInfo.toggleAccountWideSettings()
    if AchievementInfo.useAccountWideSettings["enabled"] == false then
        AchievementInfo.useAccountWideSettings["enabled"] = true
    else
        AchievementInfo.useAccountWideSettings["enabled"] = false
    end
end



-- Function to set settings
function AchievementInfo.settingSet(id, value)
    AchievementInfo.savedVars[id] = value
end
