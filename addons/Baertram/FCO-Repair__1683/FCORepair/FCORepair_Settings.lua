if FCORep == nil then FCORep = {} end
local FCORep = FCORep

--===================== Default & settings ==============================================

function FCORep.LoadUserSettings()
    local addonVars = FCORep.addonVars
    local svTableName = addonVars.addonSavedVariablesName
    local svVersion = addonVars.addonVersion
    local worldName = GetWorldName()

    --The default values for the language and save mode
    local defaultsSettings = {
        language 	 		    = 1, --Standard: English
        saveMode     		    = 2, --Standard: Account wide settings
    }

    --Pre-set the deafult values
    FCORep.settingsVars.defaults = {
        alwaysUseClientLanguage			= true,
        languageChoosen				    = false,
        colorizeCondition               = true,
        condition                       = {
            ["low"]     = {
                ["color"] = {["r"] = 1, ["g"] = 0, ["b"] = 0, ["a"] = 1},
                --["value"] = 0,
            },
            ["medium"]     = {
                ["color"] = {["r"] = 0, ["g"] = 1, ["b"] = 1, ["a"] = 1},
                ["value"] = 50,
            },
            ["high"]     = {
                ["color"] = {["r"] = 0, ["g"] = 1, ["b"] = 0, ["a"] = 1},
                ["value"] = 80,
            },
        },
        addEquippedSort = false,
        defaultEquippedSort = 0,
        addBracketsAroundName = false,
    }

    --=============================================================================================================
    --	LOAD USER SETTINGS
    --=============================================================================================================
    --Load the user's settings from SavedVariables file -> Account wide of basic version 999 at first
    FCORep.settingsVars.defaultSettings = ZO_SavedVars:NewAccountWide(svTableName, 999, "SettingsForAll", defaultsSettings, worldName, nil)

    --Check, by help of basic version 999 settings, if the settings should be loaded for each character or account wide
    --Use the current addon version to read the settings now
    if (FCORep.settingsVars.defaultSettings.saveMode == 1) then
        FCORep.settingsVars.settings = ZO_SavedVars:NewCharacterIdSettings(svTableName, svVersion , "Settings", FCORep.settingsVars.defaults, worldName)
    else
        FCORep.settingsVars.settings = ZO_SavedVars:NewAccountWide(svTableName, svVersion, "Settings", FCORep.settingsVars.defaults, worldName, nil)
    end
    --=============================================================================================================
end