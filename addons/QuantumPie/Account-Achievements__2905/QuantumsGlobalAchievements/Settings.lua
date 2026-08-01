if QUANTUMPIES_GA == nil then QUANTUMPIES_GA = {} end
local addon = QUANTUMPIES_GA
local compat_votans = QUANTUMPIES_GA_COMPATIBILITY_VOTANS

function addon:InitSettingsPanel()
    local LAM2 = LibAddonMenu2
    local svSettings = self.svSettings
    local svAchievements = self.svAchievements


    local panelName = "QuantumsGA_Settings"

    local panelData = {
        type = "panel",
        name = "Account Achievements",
        author = "@QuantumPie",
        website = "https://www.esoui.com/downloads/info2905-AccountAchievements.html"
    }

    local optionsData = {}

    -- ===== DATA ===== --
    optionsData[#optionsData + 1] = {
        type = "header",
        name = "Data",
    }
    optionsData[#optionsData + 1] = {
        type = "button",
        name = "Update Achievements",
        tooltip = "Use this if achievements were earned on this character while the addon was disabled",
        func = function()
            addon:InitializeDB()
        end,
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Separate Achievements by Server",
        warning = "The game must be re-launched for the change to take effect",
        getFunc = function()
            return svSettings.settingServerSeparation
        end,
        setFunc = function(checked)
            svSettings.settingServerSeparation = checked
        end,
    }

    -- ===== CUSTOMIZATION ===== --
    optionsData[#optionsData + 1] = {
        type = "header",
        name = "Customization",
    }
    optionsData[#optionsData + 1] = {
        type = "colorpicker",
        name = "Account Progress Color",
        getFunc = function()
            return unpack(svSettings.accountProgressBar)
        end,
        setFunc = function(r, g, b, a)
            local color = { r, g, b, a }
            svSettings.accountProgressBar = color
            --addon:InitNewSummary()
        end,
        requiresReload = true
    }
    optionsData[#optionsData + 1] = {
        type = "submenu",
        name = "Achievement Appearance",
        controls = {
            [1] = {
                type = "description",
                text = "Use these settings to customize what parts of an achievement earned on another characters are solid (as opposed to grayed out)"
            },
            [2] = {
                type = "checkbox",
                name = "Achievement Score",
                getFunc = function()
                    return svSettings.settingsSolidScore
                end,
                setFunc = function(checked)
                    svSettings.settingsSolidScore = checked
                end
            },
            [3] = {
                type = "checkbox",
                name = "Achievement Name",
                getFunc = function()
                    return svSettings.settingsSolidName
                end,
                setFunc = function(checked)
                    svSettings.settingsSolidName = checked
                end
            },
            [4] = {
                type = "checkbox",
                name = "Achievement Description",
                getFunc = function()
                    return svSettings.settingsSolidDescription
                end,
                setFunc = function(checked)
                    svSettings.settingsSolidDescription = checked
                end
            }
        }
    }

    -- ===== Compatibility ===== --
    optionsData[#optionsData + 1] = {
        type = "header",
        name = "Compatibility",
    }

    if compat_votans then
        optionsData[#optionsData + 1] = {
            type = "submenu",
            name = "Votan's Achievement Overview",
            controls = {
                [1] = {
                    type = "checkbox",
                    name = "Use Votan's Overview Window",
                    warning = "The UI must be reloaded for the change to take effect",
                    getFunc = function()
                        return svSettings.settingsUseVotansWindow
                    end,
                    setFunc = function(checked)
                        svSettings.settingsUseVotansWindow = checked
                    end
                }
            }
        }
    end

    -- ===== DEBUGGING ===== --
    optionsData[#optionsData + 1] = {
        type = "header",
        name = "Dev",
    }
    optionsData[#optionsData + 1] = {
        type = "submenu",
        name = "Debugging",
        controls = {
            [1] = {
                type = "checkbox",
                name = "Dev Mode",
                warning = "Adds additional information in the achievement window to aid in development",
                getFunc = function()
                    return svSettings.settingDevMode
                end,
                setFunc = function(checked)
                    svSettings.settingDevMode = checked
                end,
            },
            [2] =  {
                type = "button",
                name = "Reset SV",
                warning = "Resets the addon's settings and database to their default state",
                func = function()
                    svAchievements.achievements = QUANTUMPIES_GA_CONSTANTS.defaultAchievements.achievements
                    svAchievements.charactersLoaded = QUANTUMPIES_GA_CONSTANTS.defaultAchievements.charactersLoaded
                end,
            },
        }
    }

    LAM2:RegisterAddonPanel(panelName, panelData)
    LAM2:RegisterOptionControls(panelName, optionsData)

end