FCOGC = FCOGC or  {}
local FCOGuildCampaign              = FCOGC
------------------------------------------------------------------------------------------------------------------------


local addonVars = FCOGuildCampaign.addonVars
local LAM2 = FCOGuildCampaign.LAM
local myDisplayName = GetDisplayName()

------------------------------------------------------------------------------------------------------------------------
-- SETTINGS MENU
------------------------------------------------------------------------------------------------------------------------

local guildsSettingsControls
local function updateGuildDependentSettingsData()
    local controlsForGuildsSubmenu = {}
    myDisplayName = myDisplayName or GetDisplayName()
    for guildIndex = 1, GetNumGuilds(), 1 do
        local guildId = GetGuildId(guildIndex)
        if guildId ~= nil then
            local guildName = GetGuildName(guildId)
            local lamConrolNameStr = string.format(GetString(FCOGC_LAM_SETTING_ENABLE_GUILD), tostring(guildIndex), tostring(guildName))
            table.insert(controlsForGuildsSubmenu,
                    {-- LAM checkbox for guild
                        type    = "checkbox",
                        name    = lamConrolNameStr,
                        tooltip = lamConrolNameStr,
                        getFunc = function()
                            return FCOGuildCampaign.settingsVars.settings.isGuildEnabled[guildId]
                        end,
                        setFunc = function(newValue)
                            FCOGuildCampaign.settingsVars.settings.isGuildEnabled[guildId] = newValue
                            --Update the enabled guilds
                            FCOGuildCampaign.GetEnabledGuilds()
                            --Update the guild member note
                            FCOGuildCampaign.UpdateGuildMemberNote(guildId, myDisplayName, true, true)
                            --Update the LibGuildRoster column at the guild roster
                            FCOGuildCampaign.HookGuildRoster()
                        end,
                        width   = "full",
                        default = FCOGuildCampaign.settingsVars.defaults.isGuildEnabled[guildId],
                        disabled = function() return not FCOGuildCampaign.DoesHaveGuildMemberNoteChangeRights(guildIndex, guildId) end,
                    }
            )
        end
    end
    return controlsForGuildsSubmenu
end



function FCOGuildCampaign.buildAddonMenu()
    local settings = FCOGuildCampaign.settingsVars.settings
    if not settings or not LAM2 then return false end
    local defaults = FCOGuildCampaign.settingsVars.defaults
    local addonName = addonVars.addonName

    local panelData = {
        type 				= 'panel',
        name 				= addonVars.addonNameMenu,
        displayName 		= addonVars.addonNameMenuDisplay,
        author 				= addonVars.addonAuthor,
        version 			= tostring(addonVars.addonVersion),
        registerForRefresh 	= true,
        registerForDefaults = true,
        slashCommand        = "/FCOGCs",
        website             = addonVars.addonWebsite,
        feedback            = addonVars.addonFeedback,
        donation            = addonVars.addonDonation,
    }
    FCOGuildCampaign.FCOSettingsPanel = LAM2:RegisterAddonPanel(addonName .. "_LAM", panelData)

    local savedVariablesOptions = {
        [1] = GetString(FCOGC_LAM_SV_EACH_CHARACTER),   --'Each character',
        [2] = GetString(FCOGC_LAM_SV_ACCOUNT_WIDE),     --'Account wide'
    }
    local savedVariablesOptionsValues = {
        [1] = 1,
        [2] = 2,
    }

    --Build 1 checkbox for each joined guild in the guilds submenu
    guildsSettingsControls = updateGuildDependentSettingsData()

    local optionsTable =
    {	-- BEGIN OF OPTIONS TABLE

        {
            type = 'dropdown',
            name = GetString(FCOGC_LAM_SV_MODE),
            tooltip = GetString(FCOGC_LAM_SV_MODE_TT),
            choices = savedVariablesOptions,
            choicesValues = savedVariablesOptionsValues,
            getFunc = function() return FCOGuildCampaign.settingsVars.defaultSettings.saveMode end,
            setFunc = function(value)
                FCOGuildCampaign.settingsVars.defaultSettings.saveMode = value
            end,
            requiresReload = true,
        },


        --==============================================================================
        --Add checkbox for each of the guilds
        {
            type = 'submenu',
            name = GetString(FCOGC_LAM_SETTING_HEADER_GUILDS),
            controls = guildsSettingsControls,
            reference = "FCOGC_GUILDS_SETTINGS_DATA_SUBMENU"
        },

        --==============================================================================
        --Guild member notes
        {
            type = 'header',
            name = GetString(FCOGC_LAM_SETTING_HEADER_GUILD_MEMBER_NOTES),
        },
        {
            type    = "checkbox",
            name    = GetString(FCOGC_LAM_SETTING_GMN_RESERVE_LAST_5_CHARS),
            tooltip = GetString(FCOGC_LAM_SETTING_GMN_RESERVE_LAST_5_CHARS_TT),
            getFunc = function()
                return settings.reserveLast5CharsAtGuildMemberNote
            end,
            setFunc = function(newValue)
                settings.reserveLast5CharsAtGuildMemberNote = newValue
            end,
            width   = "full",
            default = defaults.reserveLast5CharsAtGuildMemberNote,
            --disabled = function() return false end,
        },
    } -- optionsTable
    -- END OF OPTIONS TABLE


    --[[
    local lamPanelCreationInitDone = false
    local function LAMControlsCreatedCallbackFunc(pPanel)
        if pPanel ~= FCOGuildCampaign.FCOSettingsPanel then return end
        if lamPanelCreationInitDone == true then return end
        --Do stiff here
        lamPanelCreationInitDone = true
    end
    ]]
    --CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", LAMControlsCreatedCallbackFunc)

    LAM2:RegisterOptionControls(addonName .. "_LAM", optionsTable)
end