local LAM = LibAddonMenu2

local poukav = LibMarcusModules['Poukav']
local tools = poukav.tools
local utils = poukav.utils

local function getMemberRanksSettingsControls()
    -- ensure all saved variables (data.guilds) exist
    tools.updateGuildsOptionsData()
    local localization = poukav.localization.localized
    local localState = poukav.state
    local guildsOptions = localState.data.guilds

    local subMenus = {}
    
    local numGuilds = GetNumGuilds()
	for i = 1, numGuilds do

        local controls = {}
		local guildId = GetGuildId(i)
        local currentGuildOptions = guildsOptions[guildId]

        local guildName = GetGuildName(guildId)
        table.insert(subMenus, {
            type = "submenu",
            name = guildName .. ' settings',
            controls = controls
        })
        table.insert(controls, {
            type = 'header',
            name = 'Donation'
        })
        table.insert(controls, {
            type = 'divider'
        })
        table.insert(controls, {
            type = 'dropdown',
            name = 'Frequency',
            choices = {'none', 'weekly', 'monthly'},
            width = "full",
            requiresReload = false,
            getFunc = function()
                return currentGuildOptions.donation.frequency
            end,
            setFunc = function(value) currentGuildOptions.donation.frequency = value end,
        })
        table.insert(controls, {
            type = 'slider',
            name = 'Amount',
            min = 1000,
            max = 100000,
            step = 1000,
            clampInput = false,
            width = "full",
            requiresReload = false,
            getFunc = function()
                return currentGuildOptions.donation.amount
            end,
            setFunc = function(value) currentGuildOptions.donation.amount = value end,
        })
        --[[
            DATE_PATTERN = {
                label = 'YYYY/MM/DD',
                pattern = '([0-9][0-9][0-9][0-9])[/-]([0-9][0-9])[/-]([0-9][0-9])',
                format = '%04d/%02d/%02d',
                [1] = 'year', [2] = 'month', [3] = 'day'
            },
        ]]

        table.insert(controls, {
            type = 'editbox',
            name = 'Start Date (' .. localization.DATE_PATTERN.label .. ')',
            getFunc = function()
                if currentGuildOptions.donation.startTime and currentGuildOptions.donation.startTime > 0 then
                    local dt = os.date('*t', currentGuildOptions.donation.startTime)
                    return utils.sformat(
                        localization.DATE_PATTERN.format,
                        dt[localization.DATE_PATTERN[1]],
                        dt[localization.DATE_PATTERN[2]],
                        dt[localization.DATE_PATTERN[3]]
                    )
                end
                return ''
            end,
            setFunc = function(value)
                if not value or utils.trim(value) == '' then
                    currentGuildOptions.donation.startTime = nil
                else
                    local index, _, arg1, arg2, arg3 = string.find(value, localization.DATE_PATTERN.pattern)
                    if index then
                        currentGuildOptions.donation.startTime = os.time({ 
                            [localization.DATE_PATTERN[1]] = tonumber(arg1),
                            [localization.DATE_PATTERN[2]] = tonumber(arg2),
                            [localization.DATE_PATTERN[3]] = tonumber(arg3),
                        })
                    else
                        -- do nothing
                    end
                end
                
                
            end,
        })
        table.insert(controls, {
            type = 'divider'
        })
        table.insert(controls, {
            type = 'header',
            name = 'Auto Ranking'
        })
        local numRanks =  GetNumGuildRanks(guildId)
        for rankIndex = 1, numRanks do
            
            local isAdminRank = DoesGuildRankHavePermission(guildId, rankIndex, GUILD_PERMISSION_DEMOTE) or
				DoesGuildRankHavePermission(guildId, rankIndex, GUILD_PERMISSION_PROMOTE) or
				DoesGuildRankHavePermission(guildId, rankIndex, GUILD_PERMISSION_PERMISSION_EDIT)
            if not isAdminRank then
                table.insert(controls, {
                    type = 'divider'
                })
                local rankName = utils.trim(tools.getGuildRankName(guildId, rankIndex))
                local currentRankOptions = currentGuildOptions.ranks[rankIndex]
                
                table.insert(controls, {
                    type = "description",
                    text = utils.cFormat(rankName or 'Rank' .. rankIndex, isAdminRank and 'ff0000' or nil),
                })
                table.insert(controls, {
                    type = "dropdown",
                    name = "Rank Evaluation Periodicity",
                    choices = { 'none', 'weekly', 'monthly' },
                    width = "full",
                    requiresReload = false,
                    getFunc = function()
                        return currentRankOptions.evaluationPeriodicity
                    end,
                    setFunc = function(value) currentRankOptions.evaluationPeriodicity = value end,
                    disabled = isAdminRank
                })
                table.insert(controls, {
                    type = "slider",
                    name = "Min value",
                    min = 1,
                    max = 10000000,
                    step = 1000,
                    clampInput = false,
                    getFunc = function()
                        return currentRankOptions.minSales
                    end,
                    setFunc = function(value) currentRankOptions.minSales = value end,
                    disabled = isAdminRank
                })
                table.insert(controls, {
                    type = "checkbox",
                    name = "Permanent Promotion",
                    getFunc = function()
                        return currentRankOptions.permanentPromotion
                    end,
                    setFunc = function(value) currentRankOptions.permanentPromotion = value end,
                    disabled = isAdminRank
                })               
            end
        end
    end
    return subMenus
end

poukav.settingsMenu = {
    createMenuPanel = function()
        local localization = poukav.localization.localized
        local localState = poukav.state
        local panelName = "MarcusPoukav"
        local panelData = {
            type = "panel",
            name = "Marcus' Poukav",
            displayName = "|c91a3b0Marcus' |c00CCFFPoukav|r",
            author = "|c91a3b0Marcus Brody|r",
            website = "https://www.esoui.com/downloads/fileinfo.php?id=3484#info",
            feedback = "https://www.esoui.com/downloads/fileinfo.php?id=3484#comments",
            registerForRefresh = true,
            registerForDefaults = true,
            -- donation = true,
        }
        local panel = LAM:RegisterAddonPanel(panelName, panelData)
    
        local lamControls = {}
        utils.move(
            {
                {
                    type = "submenu",
                    name = "Reports",
                    controls = {
                        {
                            type = "description",
                            text = localization.SUS_VALUE_THREASHOLD_DESCRIPTION,
                        },
                        {
                            type = "slider",
                            min = -100000,
                            max = 100000,
                            step = 1000,
                            name = localization.SUS_VALUE_THREASHOLD_LABEL,
                            default = 5000,
                            width = "full",
                            requiresReload = false,
                            getFunc = function() return localState.data.susBalanceThreashold end,
                            setFunc = function(value)
                                localState.data.susBalanceThreashold = value
                            end
                        },
                        {
                            type = 'divider'
                        },
                        {
                            type = "description",
                            text = localization.IGNORE_PLAYER_INACTIVITY_THREASHOLD_DESCRIPTION,
                        },{
                            type = "slider",
                            min = 1,
                            max = 365,
                            step = 1,
                            name = localization.IGNORE_PLAYER_INACTIVITY_THREASHOLD_LABEL,
                            default = 30,
                            width = "full",
                            requiresReload = false,
                            getFunc = function() return localState.data.ignorePlayerInactivityThreashold end,
                            setFunc = function(value)
                                localState.data.ignorePlayerInactivityThreashold = value
                            end
                        },
                        {
                            type = 'divider'
                        },
                        {
                            type = "description",
                            text = localization.SCAN_EXPIRATION_TIME_DESCRIPTION,
                        },
                        {
                            type = "slider",
                            min = 10,
                            max = 1440,
                            step = 10,
                            name = localization.SCAN_EXPIRATION_TIME_LABEL,
                            default = 30,
                            width = "full",
                            requiresReload = false,
                            getFunc = function() return localState.data.scanExpirationTime end,
                            setFunc = function(value)
                                localState.data.scanExpirationTime = value
                            end
                        },
                        {
                            type = 'divider'
                        },
                        {
                            type = "description",
                            text = localization.ACCOUNTING_WEEK_START_DAY_DESCRIPTION,
                        },
                        {
                            type = "dropdown",
                            choices = {
                                localization.MONDAY, localization.TUESDAY, localization.WEDNESDAY, localization.THURSDAY, localization.FRIDAY, localization.SATURDAY, localization.SUNDAY
                            },
                            choicesValues = {2, 3, 4, 5, 6, 7, 1},
                            name = localization.ACCOUNTING_WEEK_START_DAY_LABEL,
                            default = 3,
                            width = "full",
                            requiresReload = false,
                            getFunc = function() return localState.data.accountingWeekStartDay end,
                            setFunc = function(value)
                                localState.data.accountingWeekStartDay = value
                            end
                        },
                        {
                            type = 'divider'
                        },
                        {
                            type = "description",
                            text = localization.ACCOUNTING_DAY_START_HOUR_DESCRIPTION,
                        },
                        {
                            type = "slider",
                            min = 0,
                            max = 23,
                            step = 1,
                            name = localization.ACCOUNTING_DAY_START_HOUR_LABEL,
                            default = 30,
                            width = "full",
                            requiresReload = false,
                            getFunc = function() return localState.data.accountingDayStartHour end,
                            setFunc = function(value)
                                localState.data.accountingDayStartHour = value
                            end
                        },
                        {
                            type = 'divider'
                        },
                        {
                            type = "description",
                            text = localization.OUTPUT_TEXT_COLOR_DESCRIPTION,
                        },
                        {
                            type = "colorpicker",
                            name = localization.OUTPUT_TEXT_COLOR_LABEL,
                            width = "full",
                            requiresReload = false,
                            getFunc = function() return unpack(localState.data.textColor) end,
                            setFunc = function(r, g, b, a)
                                localState.data.textColor = {r, g, b, a}
                            end
                        },
                        {
                            type = 'divider'
                        },
                        {
                            type = "description",
                            text = localization.OUTPUT_MEMBER_TEXT_COLOR_DESCRIPTION,
                        },
                        {
                            type = "colorpicker",
                            name = localization.OUTPUT_MEMBER_TEXT_COLOR_LABEL,
                            width = "full",
                            requiresReload = false,
                            getFunc = function() return unpack(localState.data.memberTextColor) end,
                            setFunc = function(r, g, b, a)
                                localState.data.memberTextColor = {r, g, b, a}
                            end
                        }
                    }
                },
                {
                    type = "submenu",
                    name = "General member ranks",
                    controls = {
                        {
                            type = "description",
                            text = localization.NO_KIOSK_EXERNAL_SALES_RATIO_THREASHOLD_DESCRIPTION,
                        },
                        {
                            type = "slider",
                            min = 0,
                            max = 100,
                            step = 1,
                            name = localization.NO_KIOSK_EXERNAL_SALES_RATIO_THREASHOLD_LABEL,
                            default = 75,
                            width = "full",
                            requiresReload = false,
                            getFunc = function() return localState.data.noKioskExternalSalesRatioThreashold end,
                            setFunc = function(value)
                                localState.data.noKioskExternalSalesRatioThreashold = value
                            end
                        },
                        {
                            type = 'divider'
                        },
                        {
                            type = "description",
                            text = localization.SIMULATE_RANKING_DESCRIPTION,
                        },
                        {
                            type = 'checkbox',
                            name = localization.SIMULATE_RANKING_LABEL,
                            getFunc = function() return localState.data.guilds.simulateRankEvalutation end,
                            setFunc = function(value)
                                localState.data.guilds.simulateRankEvalutation = value
                            end,
                            warning = 'Disabling simulate will make the rank command update your members\' ranks'
                        }
                    }
                }
            },
            nil,
            nil,
            #lamControls + 1,
            lamControls
        )
        utils.move(getMemberRanksSettingsControls(), nil, nil, #lamControls + 1, lamControls)
        utils.move(
            {
                {
                    type = "description",
                    text = localization.LOCALIZATION_ENABLED_DESCRIPTION,
                },
                {
                    type = "checkbox",
                    name = localization.LOCALIZATION_ENABLED_LABEL,
                    width = "full",
                    requiresReload = false,
                    getFunc = function() return localState.data.localizationEnabled end,
                    setFunc = function(v)
                        localState.data.localizationEnabled = v
                        if localState.data.localizationEnabled then
                            localization = poukav.localization.localized
                        else
                            localization = poukav.localization.default
                        end
                    end
                }
            },
            nil,
            nil,
            nil,
            lamControls
        )
        LAM:RegisterOptionControls(
            panelName,
            lamControls
        )
    end
}