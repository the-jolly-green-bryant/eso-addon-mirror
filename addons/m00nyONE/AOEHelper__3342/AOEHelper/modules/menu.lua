local startLoadTime = GetGameTimeMilliseconds()

AOEHelper = AOEHelper or {}
AOEHelper.loadTime = AOEHelper.loadTime or 0
local LAM2 = LibAddonMenu2

-- create a custom menu by using LibCustomMenu
function AOEHelper.createAddonMenu()
    local panelData = {
        type = "panel",
        name = "AOEHelper",
        displayName = "AOEHelper",
        author = AOEHelper.author,
        version = AOEHelper.version,
        website = "https://www.esoui.com/downloads/fileinfo.php?id=3342",
        feedback = "https://github.com/m00nyONE/AOEHelper",
        donation = AOEHelper.donate,
        slashCommand = "/aoesettings",
        registerForRefresh = true,
        registerForDefaults = false,
    }

    local optionsTable = {
        [1] = {
            type = "description",
            text = "|cff6600" .. GetString(AOEHELPER_MENU_DESCRIPTION) .. "|r",
            width = "full",
        },
        [2] = {
            type = "header",
            name = GetString(AOEHELPER_MENU_CURRENT_HEADER_DESCRIPTION),
            width = "full",
        },
        [3] = {
            type = "colorpicker",
            name = GetString(AOEHELPER_MENU_GENERAL_ENEMY_COLOR_TEXT),
            tooltip = GetString(AOEHELPER_MENU_GENERAL_ENEMY_COLOR_TOOLTIP),
			getFunc = function()
				local c = AOEHelper.GetGameColors().enemyColor
				return tonumber("0x" .. c:sub(1, 2)) / 255, tonumber("0x" .. c:sub(3, 4)) / 255, tonumber("0x" .. c:sub(5, 6)) / 255
			end,
			setFunc = function(red,green,blue,a)
                local colors = {}
				colors.enemyColor = string.format("%02x%02x%02x", red*255, green*255, blue*255)
                AOEHelper.SetGameColors(colors)
			end,
            width = "half"
		},
        [4] = {
            type = "slider",
            name = GetString(AOEHELPER_MENU_GENERAL_ENEMY_BRIGHTNESS_TEXT),
            tooltip = GetString(AOEHELPER_MENU_GENERAL_ENEMY_BRIGHTNESS_TOOLTIP),
            getFunc = function() return GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_BRIGHTNESS) end,
            setFunc = function(value) SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_BRIGHTNESS, value) end,
            clampInput = false,
            width = "half",
            decimals = 0,
            step = 1,
            default = 50,
            min = 1,
            max = 100,
        },
        [5] = {
            type = "colorpicker",
            name = GetString(AOEHELPER_MENU_GENERAL_ALLY_COLOR_TEXT),
            tooltip = GetString(AOEHELPER_MENU_GENERAL_ALLY_COLOR_TOOLTIP),
			getFunc = function()
				local c = AOEHelper.GetGameColors().friendlyColor
				return tonumber("0x" .. c:sub(1, 2)) / 255, tonumber("0x" .. c:sub(3, 4)) / 255, tonumber("0x" .. c:sub(5, 6)) / 255
			end,
			setFunc = function(red,green,blue,a)
                local colors = {}
				colors.friendlyColor = string.format("%02x%02x%02x", red*255, green*255, blue*255)
                AOEHelper.SetGameColors(colors)
			end,
            width = "half"
		},
        [6] = {
            type = "slider",
            name = GetString(AOEHELPER_MENU_GENERAL_ALLY_BRIGHTNESS_TEXT),
            tooltip = GetString(AOEHELPER_MENU_GENERAL_ALLY_BRIGHTNESS_TOOLTIP),
            getFunc = function() return GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_BRIGHTNESS) end,
            setFunc = function(value) SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_BRIGHTNESS, value) end,
            width = "half",
            decimals = 0,
            step = 1,
            default = 50,
            min = 1,
            max = 100,
        },
        [7] = {
            type = "divider"
        },
        [8] = {
            type = "button",
            name = GetString(AOEHELPER_MENU_GENERAL_BUTTON_SETFORCURRENTZONE_TEXT),
            tooltip = GetString(AOEHELPER_MENU_GENERAL_BUTTON_SETFORCURRENTZONE_TOOLTIP),
            func = function()
                local zoneID = GetZoneId(GetUnitZoneIndex("player"))
                AOEHelper.SetZoneColors(zoneID, AOEHelper.GetGameColors())
            end,
            width = "half",
            disabled = function() return not IsUnitInDungeon("player") end,
        },
        [9] = {
            type = "button",
            name = GetString(AOEHELPER_MENU_GENERAL_BUTTON_SETFORCURRENTBOSS_TEXT),
            tooltip = GetString(AOEHELPER_MENU_GENERAL_BUTTON_SETFORCURRENTBOSS_TOOLTIP),
            func = function()
                local bossName = AOEHelper.GetBossName()
                if bossName == "" then return end
                AOEHelper.SetBossColors(bossName, AOEHelper.GetGameColors())
            end,
            disabled = function() if AOEHelper.GetBossName() == "" then return true end return false end,
            width = "half",
        }

    }

    -- submenu - current zone
    optionsTable[#optionsTable + 1] = {
        type = "submenu",
        name = function()
            if IsUnitInDungeon("player") then
                return zo_strformat(GetString(AOEHELPER_MENU_CURRENTZONE_SUBMENU_TEXT), AOEHelper.filterName(GetUnitZone("player")))
            end
            return "ZONE"
        end,
        tooltip = GetString(AOEHELPER_MENU_CURRENTZONE_SUBMENU_TOOLTIP),
        disabled = function() if AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))] == nil then return true end return false end,
        controls = {
            [1] = {
                type = "colorpicker",
                name = GetString(AOEHELPER_MENU_GENERAL_ENEMY_COLOR_TEXT),
                tooltip = GetString(AOEHELPER_MENU_GENERAL_ENEMY_COLOR_TOOLTIP),
                getFunc = function()
                    if AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))] ~= nil then
                        local c = AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))].enemyColor
                        return tonumber("0x" .. c:sub(1, 2)) / 255, tonumber("0x" .. c:sub(3, 4)) / 255, tonumber("0x" .. c:sub(5, 6)) / 255
                    end
                    return 0,0,0
                end,
                setFunc = function(red,green,blue,a)
                    local newColor = string.format("%02x%02x%02x", red*255, green*255, blue*255)
                    AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))].enemyColor = newColor
                    SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_COLOR, newColor)
                end,
                width = "half"
            },
            [2] = {
                type = "slider",
                name = GetString(AOEHELPER_MENU_GENERAL_ENEMY_BRIGHTNESS_TEXT),
                tooltip = GetString(AOEHELPER_MENU_GENERAL_ENEMY_BRIGHTNESS_TOOLTIP),
                getFunc = function()
                    if AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))] ~= nil then
                        return AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))].enemyBrightness
                    end
                    return 0
                end,
                setFunc = function(value)
                    AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))].enemyBrightness = value
                    SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_BRIGHTNESS, value)
                end,
                width = "half",
                decimals = 0,
                step = 1,
                default = 50,
                min = 1,
                max = 100,
            },
            [3] = {
                type = "colorpicker",
                name = GetString(AOEHELPER_MENU_GENERAL_ALLY_COLOR_TEXT),
                tooltip = GetString(AOEHELPER_MENU_GENERAL_ALLY_COLOR_TOOLTIP),
                getFunc = function()
                    if AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))] ~= nil then
                        local c = AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))].friendlyColor
                        return tonumber("0x" .. c:sub(1, 2)) / 255, tonumber("0x" .. c:sub(3, 4)) / 255, tonumber("0x" .. c:sub(5, 6)) / 255
                    end
                    return 0,0,0
                end,
                setFunc = function(red,green,blue,a)
                    d("R: " .. red .. " G: " .. green .. " B: " .. blue .. " A: " .. a)
                    local newColor = string.format("%02x%02x%02x", red*255, green*255, blue*255)
                    AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))].friendlyColor = newColor
                    SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_COLOR, newColor)
                end,
                width = "half"
            },
            [4] = {
                type = "slider",
                name = GetString(AOEHELPER_MENU_GENERAL_ALLY_BRIGHTNESS_TEXT),
                tooltip = GetString(AOEHELPER_MENU_GENERAL_ALLY_BRIGHTNESS_TOOLTIP),
                getFunc = function()
                    if AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))] ~= nil then
                        return AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))].friendlyBrightness
                    end
                    return 0
                end,
                setFunc = function(value)
                    AOEHelper.savedVariables.savedZones[GetZoneId(GetUnitZoneIndex("player"))].friendlyBrightness = value
                    SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_BRIGHTNESS, value)
                end,
                width = "half",
                decimals = 0,
                step = 1,
                default = 50,
                min = 1,
                max = 100,
            },
            [5] = {
                type = "button",
                name = GetString(AOEHELPER_MENU_CURRENTZONE_BUTTON_LOAD_TEXT),
                tooltip = GetString(AOEHELPER_MENU_CURRENTZONE_BUTTON_LOAD_TOOLTIP),
                func = function()
                    local zoneID = GetZoneId(GetUnitZoneIndex("player"))
                    AOEHelper.SetGameColors(AOEHelper.GetZoneColors(zoneID))
                end,
                disabled = function()
                    local zoneID = GetZoneId(GetUnitZoneIndex("player"))
                    if AOEHelper.GetZoneColors(zoneID) == nil then return true end

                    local function compare(t1, t2)
                        for key, value in pairs(t1) do
                            if t2[key] ~= value then
                                return false
                            end
                        end
                        return true
                    end
                    if compare(AOEHelper.GetZoneColors(zoneID), AOEHelper.GetGameColors()) then return true end

                    --if AOEHelper.GetZoneColors(zoneID) == AOEHelper.GetGameColors() then return true end
                    return false
                end,
                width = "half",
            },
            [6] = {
                type = "button",
                name = GetString(AOEHELPER_MENU_CURRENTZONE_BUTTON_DELETE_TEXT),
                tooltip = GetString(AOEHELPER_MENU_CURRENTZONE_BUTTON_DELETE_TOOLTIP),
                warning = GetString(AOEHELPER_MENU_CURRENTZONE_BUTTON_DELETE_WARNING),
                func = function()
                    local zoneID = GetZoneId(GetUnitZoneIndex("player"))
                    AOEHelper.DeleteZoneColors(zoneID)
                end,
                width = "half",
            }
        }

    }

    -- submenu - current boss
    optionsTable[#optionsTable + 1] = {
        type = "submenu",
        name = function()
            if AOEHelper.GetBossName() ~= "" then
                return zo_strformat(GetString(AOEHELPER_MENU_CURRENTBOSS_SUBMENU_TEXT),AOEHelper.GetBossName())
            end
                return "BOSS"
        end,
        tooltip = GetString(AOEHELPER_MENU_CURRENTBOSS_SUBMENU_TOOLTIP),
        disabled = function() if AOEHelper.savedVariables.savedBosses[AOEHelper.GetBossName()] == nil then return true end return false end,
        controls = {
            [1] = {
                type = "colorpicker",
                name = GetString(AOEHELPER_MENU_GENERAL_ENEMY_COLOR_TEXT),
                tooltip = GetString(AOEHELPER_MENU_GENERAL_ENEMY_COLOR_TOOLTIP),
                getFunc = function()
                    local bossName = AOEHelper.GetBossName()
                    if AOEHelper.savedVariables.savedBosses[bossName] ~= nil then
                        local c = AOEHelper.savedVariables.savedBosses[bossName].enemyColor
                        return tonumber("0x" .. c:sub(1, 2)) / 255, tonumber("0x" .. c:sub(3, 4)) / 255, tonumber("0x" .. c:sub(5, 6)) / 255
                    end
                    return 0,0,0
                end,
                setFunc = function(red,green,blue,a)
                    local bossName = AOEHelper.GetBossName()
                    local newColor = string.format("%02x%02x%02x", red*255, green*255, blue*255)
                    AOEHelper.savedVariables.savedBosses[bossName].enemyColor = newColor
                    SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_COLOR, newColor)
                end,
                width = "half"
            },
            [2] = {
                type = "slider",
                name = GetString(AOEHELPER_MENU_GENERAL_ENEMY_BRIGHTNESS_TEXT),
                tooltip = GetString(AOEHELPER_MENU_GENERAL_ENEMY_BRIGHTNESS_TOOLTIP),
                getFunc = function()
                    local bossName = AOEHelper.GetBossName()
                    if AOEHelper.savedVariables.savedBosses[bossName] ~= nil then
                        return AOEHelper.savedVariables.savedBosses[bossName].enemyBrightness
                    end
                    return 0
                end,
                setFunc = function(value)
                    local bossName = AOEHelper.GetBossName()
                    AOEHelper.savedVariables.savedBosses[bossName].enemyBrightness = value
                    SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_BRIGHTNESS, value)
                end,
                width = "half",
                decimals = 0,
                step = 1,
                default = 50,
                min = 1,
                max = 100,
            },
            [3] = {
                type = "colorpicker",
                name = GetString(AOEHELPER_MENU_GENERAL_ALLY_COLOR_TEXT),
                tooltip = GetString(AOEHELPER_MENU_GENERAL_ALLY_COLOR_TOOLTIP),
                getFunc = function()
                    local bossName = AOEHelper.GetBossName()
                    if AOEHelper.savedVariables.savedBosses[bossName] ~= nil then
                        local c = AOEHelper.savedVariables.savedBosses[bossName].friendlyColor
                        return tonumber("0x" .. c:sub(1, 2)) / 255, tonumber("0x" .. c:sub(3, 4)) / 255, tonumber("0x" .. c:sub(5, 6)) / 255
                    end
                    return 0,0,0
                end,
                setFunc = function(red,green,blue,a)
                    local bossName = AOEHelper.GetBossName()
                    d("R: " .. red .. " G: " .. green .. " B: " .. blue .. " A: " .. a)
                    local newColor = string.format("%02x%02x%02x", red*255, green*255, blue*255)
                    AOEHelper.savedVariables.savedBosses[bossName].friendlyColor = newColor
                    SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_COLOR, newColor)
                end,
                width = "half"
            },
            [4] = {
                type = "slider",
                name = GetString(AOEHELPER_MENU_GENERAL_ALLY_BRIGHTNESS_TEXT),
                tooltip = GetString(AOEHELPER_MENU_GENERAL_ALLY_BRIGHTNESS_TOOLTIP),
                getFunc = function()
                    local bossName = AOEHelper.GetBossName()
                    if AOEHelper.savedVariables.savedBosses[bossName] ~= nil then
                        return AOEHelper.savedVariables.savedBosses[bossName].friendlyBrightness
                    end
                    return 0
                end,
                setFunc = function(value)
                    local bossName = AOEHelper.GetBossName()
                    AOEHelper.savedVariables.savedBosses[bossName].friendlyBrightness = value
                    SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_BRIGHTNESS, value)
                end,
                width = "half",
                decimals = 0,
                step = 1,
                default = 50,
                min = 1,
                max = 100,
            },
            [5] = {
                type = "button",
                name = GetString(AOEHELPER_MENU_CURRENTBOSS_BUTTON_LOAD_TEXT),
                tooltip = GetString(AOEHELPER_MENU_CURRENTBOSS_BUTTON_LOAD_TOOLTIP),
                func = function()
                    local zoneID = GetZoneId(GetUnitZoneIndex("player"))
                    AOEHelper.SetGameColors(AOEHelper.GetZoneColors(zoneID))
                end,
                disabled = function()
                    local bossName = AOEHelper.GetBossName()
                    if AOEHelper.GetBossColors(bossName) == nil then return true end

                    local function compare(t1, t2)
                        for key, value in pairs(t1) do
                            if t2[key] ~= value then
                                return false
                            end
                        end
                        return true
                    end
                    if compare(AOEHelper.GetBossColors(bossName), AOEHelper.GetGameColors()) then return true end

                    --if AOEHelper.GetZoneColors(zoneID) == AOEHelper.GetGameColors() then return true end
                    return false
                end,
                width = "half",
            },
            [6] = {
                type = "button",
                name = GetString(AOEHELPER_MENU_CURRENTBOSS_BUTTON_DELETE_TEXT),
                tooltip = GetString(AOEHELPER_MENU_CURRENTBOSS_BUTTON_DELETE_TOOLTIP),
                warning = GetString(AOEHELPER_MENU_CURRENTBOSS_BUTTON_DELETE_WARNING),
                func = function()
                    local bossName = AOEHelper.GetBossName()
                    if bossName ~= "" then
                        AOEHelper.DeleteBossColors(bossName)
                    end
                end,
                width = "half",
            }
        }

    }

    -- submenu - default colors
    optionsTable[#optionsTable + 1] = {
        type = "submenu",
        name = GetString(AOEHELPER_MENU_DEFAULT_SUBMENU_TEXT),
        tooltip = GetString(AOEHELPER_MENU_DEFAULT_SUBMENU_TOOLTIP),
        controls = {
            [1] = {
                type = "colorpicker",
                name = GetString(AOEHELPER_MENU_GENERAL_ENEMY_COLOR_TEXT),
                tooltip = GetString(AOEHELPER_MENU_GENERAL_ENEMY_COLOR_TOOLTIP),
                getFunc = function()
                    local c = AOEHelper.savedVariables.defaultColors.enemyColor
                    return tonumber("0x" .. c:sub(1, 2)) / 255, tonumber("0x" .. c:sub(3, 4)) / 255, tonumber("0x" .. c:sub(5, 6)) / 255
                end,
                setFunc = function(red,green,blue,a)
                    local newColor = string.format("%02x%02x%02x", red*255, green*255, blue*255)
                    AOEHelper.savedVariables.defaultColors.enemyColor = newColor
                end,
                width = "half"
            },
            [2] = {
                type = "slider",
                name = GetString(AOEHELPER_MENU_GENERAL_ENEMY_BRIGHTNESS_TEXT),
                tooltip = GetString(AOEHELPER_MENU_GENERAL_ENEMY_BRIGHTNESS_TOOLTIP),
                getFunc = function() return AOEHelper.savedVariables.defaultColors.enemyBrightness end,
                setFunc = function(value) AOEHelper.savedVariables.defaultColors.enemyBrightness = value end,
                width = "half",
                decimals = 0,
                step = 1,
                default = 50,
                min = 1,
                max = 100,
            },
            [3] = {
                type = "colorpicker",
                name = GetString(AOEHELPER_MENU_GENERAL_ALLY_COLOR_TEXT),
                tooltip = GetString(AOEHELPER_MENU_GENERAL_ALLY_COLOR_TOOLTIP),
                getFunc = function()
                    local c = AOEHelper.savedVariables.defaultColors.friendlyColor
                    return tonumber("0x" .. c:sub(1, 2)) / 255, tonumber("0x" .. c:sub(3, 4)) / 255, tonumber("0x" .. c:sub(5, 6)) / 255
                end,
                setFunc = function(red,green,blue,a)
                    local newColor = string.format("%02x%02x%02x", red*255, green*255, blue*255)
                    AOEHelper.savedVariables.defaultColors.friendlyColor = newColor
                end,
                width = "half"
            },
            [4] = {
                type = "slider",
                name = GetString(AOEHELPER_MENU_GENERAL_ALLY_BRIGHTNESS_TEXT),
                tooltip = GetString(AOEHELPER_MENU_GENERAL_ALLY_BRIGHTNESS_TOOLTIP),
                getFunc = function() return AOEHelper.savedVariables.defaultColors.friendlyBrightness end,
                setFunc = function(value) AOEHelper.savedVariables.defaultColors.friendlyBrightness = value end,
                width = "half",
                decimals = 0,
                step = 1,
                default = 50,
                min = 1,
                max = 100,
            },
            [5] = {
                type = "button",
                name = GetString(AOEHELPER_MENU_DEFAULT_BUTTON_LOAD_TEXT),
                tooltip = GetString(AOEHELPER_MENU_DEFAULT_BUTTON_LOAD_TOOLTIP),
                func = function()
                    AOEHelper.LoadDefaultColors()
                end,
                width = "half",
            },
            [6] = {
                type = "button",
                name = GetString(AOEHELPER_MENU_DEFAULT_BUTTON_SAVE_TEXT),
                tooltip = GetString(AOEHELPER_MENU_DEFAULT_BUTTON_SAVE_TOOLTIP),
                warning = GetString(AOEHELPER_MENU_DEFAULT_BUTTON_SAVE_WARNING),
                func = function()
                    AOEHelper.savedVariables.defaultColors = AOEHelper.GetGameColors()
                end,
                width = "half",
            },
        }
    }

    optionsTable[#optionsTable + 1] = {
        type = "submenu",
        name = "debug",
        controls = {
            [1] = {
                type = "description",
                text = function() return "Took " .. AOEHelper.loadTime .. "ms to load " .. AOEHelper.name end,
            }
        }
    }

    LAM2:RegisterAddonPanel("AOEHelperMenu", panelData)
    LAM2:RegisterOptionControls("AOEHelperMenu", optionsTable)
end

local endLoadTime = GetGameTimeMilliseconds()
AOEHelper.loadTime = AOEHelper.loadTime + (endLoadTime - startLoadTime)