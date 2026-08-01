
LeoGuildManagerSettings = ZO_Object:Subclass()
local LAM = LibStub("LibAddonMenu-2.0")

function LeoGuildManagerSettings:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function LeoGuildManagerSettings:Initialize()
end

function LeoGuildManagerSettings:CreatePanel()
	local OptionsName = "LeoGuildManagerOptions"
	local panelData = {
		type = "panel",
		name = LeoGuildManager.name,
        slashCommand = "/leogmoptions",
		displayName = "|c39B027"..LeoGuildManager.displayName.."|r",
		author = "@LeandroSilva",
		version = LeoGuildManager.version,
		registerForRefresh = true,
		registerForDefaults = false,
		website = "http://www.esoui.com/downloads/info2140-LeosGuildManager.html"
	}
	LAM:RegisterAddonPanel(OptionsName, panelData)

	local optionsData = {
		{
			type = "header",
			name = "|c3f7fffConfiguration|r"
		},{
            type = "dropdown",
            name = "Addon to integrate with",
            choices = LeoGuildManager.integrations,
            getFunc = function() return LeoGuildManager.globalData.settings.integration end,
            setFunc = function(value) LeoGuildManager.globalData.settings.integration = value end,
            requiresReload = true
		},--[[{
            type = "checkbox",
            name = "Scan guilds automatically",
            default = false,
            getFunc = function() return LeoGuildManager.globalData.settings.scanAutomatically end,
            setFunc = function(value) LeoGuildManager.globalData.settings.scanAutomatically = value end,
		},--]]{
			type = "header",
			name = "|c3f7fffGuilds|r"
		}
	}
    for guildId, guild in pairs(LeoGuildManager.guilds) do
        table.insert(optionsData, {
            type = "checkbox",
            name = guild,
            default = false,
            getFunc = function() return LeoGuildManager.globalData.settings.guilds[guild].enabled end,
            setFunc = function(value) LeoGuildManager.globalData.settings.guilds[guild].enabled = value end,
            requiresReload = true
        })
    end
    table.insert(optionsData, {
        type = "button",
        name = "Reload UI",
        width = "full",
        func = function() ReloadUI() end,
    })

    for guildId, guild in pairs(LeoGuildManager.guilds) do

        local guildName = GetGuildName(guildId)

        if LeoGuildManager.globalData.settings.guilds[guild].enabled == true then

            local ranks = LeoGuildManager.GetGuildRanks(guildId)
            ranks[0] = "disabled"

            local purgeWarning = ""
            if not LeoGuildManager.CanScanBankHistory(guildId) then
                purgeWarning = "To use deposits/tickets, you need guild permission to 'View Bank Gold'."
            end
            if not LeoGuildManager.HasIntegrationAddonsLoaded() then
                if purgeWarning ~= "" then
                    purgeWarning = purgeWarning .. "\n"
                end
                purgeWarning = "For purge using sales, you Master Merchant or Arkadiu's Trade Tools installed|r"
            end
            if purgeWarning ~= "" then
                purgeWarning = "|c"..LeoGuildManager.color.hex.red..purgeWarning
            end

            table.insert(optionsData, {
                type = "submenu",
                name = guild,
                controls = {
                    {
                        type = "checkbox",
                        name = "Add guild roster tooltip",
                        default = false,
                        -- warning = "This feature requires periodic guild scan.",
                        getFunc = function() return LeoGuildManager.UseTooltipRoster(guild) end,
                        setFunc = function(value) LeoGuildManager.SetTooltipRoster(guild, value) end,
                    },{
                        type = "slider",
                        name = "Keep Bank history for (days)",
                        tooltip = "Will clean old data. 0 will disable it and will keep the data indefinitely",
                        width = "half",
                        disabled = function() return not LeoGuildManager.CanScanBankHistory(guildId) end,
                        getFunc = function() return LeoGuildManager.GetKeepBankHistory(guildName) end,
                        setFunc = function(value) LeoGuildManager.SetKeepBankHistory(guildName, value) end,
                        min = 0,
                        max = 90,
                        default = 30,
                    },{
                        type = "slider",
                        name = "Keep Roster history for (days)",
                        tooltip = "Will clean old data. 0 will disable it and will keep the data indefinitely",
                        width = "half",
                        getFunc = function() return LeoGuildManager.GetKeepRosterHistory(guildName) end,
                        setFunc = function(value) LeoGuildManager.SetKeepRosterHistory(guildName, value) end,
                        min = 0,
                        max = 90,
                        default = 30,
                    },{
                        type = "submenu",
                        name = "|c3f7fffPurge|r",
                        controls = {
                            {
                                type = "description",
                                text = "|c"..LeoGuildManager.color.hex.red..purgeWarning,
                            },{
                                type = "description",
                                text = "",
                                reference = "LeoGuildManagerSettingsRequirementsDescription" .. guildId
                            },{
                                type = "dropdown",
                                name = "Time frame",
                                tooltip = "When running a purge, the search for sales and deposits will use this range of time. The values are taken from the Addon selected above.",
                                choices = LeoGuildManager.GetCycles(),
                                getFunc = function() return LeoGuildManager.GetCycleName(LeoGuildManager.globalData.settings.guilds[guild].cycle) end,
                                setFunc = function(value) LeoGuildManager.globalData.settings.guilds[guild].cycle = LeoGuildManager.GetCycleIdByName(value) end
                            },{
                                type = "dropdown",
                                name = "Ignore members with rank equal or above",
                                choices = ranks,
                                getFunc = function()
                                    local name = LeoGuildManager.GetGuildRankName(guildId, LeoGuildManager.globalData.settings.guilds[guild].ignoreRank)
                                    if name == nil then name = "disabled" end
                                    return name
                                end,
                                setFunc = function(value)
                                    LeoGuildManager.globalData.settings.guilds[guild].ignoreRank = LeoGuildManager.GetGuildRankId(guildId, value)
                                end
                            },{
                                type = "dropdown",
                                name = "Ignore new members",
                                tooltip = "Recently added members need some time to start, right? :)",
                                choices = {
                                    "None",
                                    "1 week",
                                    "2 weeks",
                                    "3 weeks",
                                    "1 month",
                                },
                                getFunc = function()
                                    local value = LeoGuildManager.globalData.settings.guilds[guild].ignoreNew
                                    return LeoGuildManager.GetNewRangeName(value)
                                end,
                                setFunc = function(value)
                                    if value == "None" then value = 0
                                    elseif value == "1 week" then value = 7
                                    elseif value == "2 weeks" then value = 14
                                    elseif value == "3 weeks" then value = 21
                                    else value = 30 end
                                    LeoGuildManager.globalData.settings.guilds[guild].ignoreNew = value
                                end
                            },{
                                type = "slider",
                                name = "Deposits / Tickets bought (in k)",
                                tooltip = "Required value (deposits or tickets value) to be deposited",
                                width = "half",
                                disabled = function() return not LeoGuildManager.CanScanBankHistory(guildId) end,
                                getFunc = function() return LeoGuildManager.globalData.settings.guilds[guild].tickets end,
                                setFunc = function(value) LeoGuildManager.globalData.settings.guilds[guild].tickets = value end,
                                min = 0,
                                max = 100,
                                default = 10,
                            },{
                                type = "slider",
                                name = "Sales (in k)",
                                tooltip = "Required value of sales",
                                width = "half",
                                disabled = function() return not LeoGuildManager.HasIntegrationAddonsLoaded() end,
                                getFunc = function() return LeoGuildManager.globalData.settings.guilds[guild].sales end,
                                setFunc = function(value) LeoGuildManager.globalData.settings.guilds[guild].sales = value end,
                                min = 0,
                                max = 1000,
                                default = 150,
                            }, {
                                type = "slider",
                                name = "Inactivity (in days)",
                                width = "half",
                                getFunc = function() return LeoGuildManager.globalData.settings.guilds[guild].inactivity end,
                                setFunc = function(value) LeoGuildManager.globalData.settings.guilds[guild].inactivity = value end,
                                min = 0,
                                max = 120,
                                default = 30,
                            },{
                                type = "slider",
                                name = "Purchases (in k)",
                                tooltip = "Required value of purchases. Available only for ATT",
                                width = "half",
                                disabled = function() return not LeoGuildManager.HasIntegrationAddonsLoaded(2) end,
                                getFunc = function() return LeoGuildManager.GetPurgePurchases(guild) end,
                                setFunc = function(value) LeoGuildManager.SetPurgePurchases(guild, value) end,
                                min = 0,
                                max = 1000,
                                default = 0,
                            }
                        }
                    },{
                        type = "submenu",
                        name = "|c3f7fffBlacklist|r",
                        controls = {
                            {
                                type = "description",
                                text = "You can add members to a blacklist and be warned when they are online and even automatically kick them from the guild."
                            }, {
                                type = "checkbox",
                                name = "Warning in chat when member is online",
                                default = true,
                                getFunc = function()
                                    return LeoGuildManager.GetWarnOnline(guild)
                                end,
                                setFunc = function(value)
                                    LeoGuildManager.SetWarnOnline(guild, value)
                                end,
                            }, {
                                type = "checkbox",
                                name = "|c" .. LeoGuildManager.color.hex.red .. "Automatically|r kick members",
                                default = false,
                                getFunc = function()
                                    return LeoGuildManager.GetAutoKick(guild)
                                end,
                                setFunc = function(value)
                                    LeoGuildManager.SetAutoKick(guild, value)
                                end,
                            }, {
                                type = "button",
                                name = "Edit List",
                                width = "half",
                                func = function()
                                    ZO_Dialogs_ShowDialog("EDIT_NOTE", {
                                        displayName = "One UserID per line",
                                        note = table.concat(LeoGuildManager.globalData.settings.guilds[guild].blacklist, "\n"),
                                        changedCallback = function(displayName, text)
                                            LeoGuildManagerWindow.OnBlacklistChanged(guildId, guild, text)
                                        end
                                    })
                                end,
                            }, {
                                type = "description",
                                text = "Members: " .. table.concat(LeoGuildManager.globalData.settings.guilds[guild].blacklist, ", "),
                                reference = "LeoGuildManagerSettingsBlacklistLabel" .. guildId
                            }
                        }
                    }
                }
            })
        end
    end

	LAM:RegisterOptionControls(OptionsName, optionsData)
end

function LeoGuildManagerSettings_OnMouseEnter(control, tooltip)
	InitializeTooltip(InformationTooltip, control, BOTTOMLEFT, 0, -2, TOPLEFT)
	SetTooltipText(InformationTooltip, tooltip)
end

function LeoGuildManagerSettings:OnSettingsControlsCreated(panel)
    --Each time an options panel is created, once for each addon viewed
    if panel:GetName() == "LeoGuildManagerOptions" then
        for guildId, guild in pairs(LeoGuildManager.guilds) do
            if LeoGuildManager.globalData.settings.guilds[guild].enabled == true then
            end
        end
    end
end
