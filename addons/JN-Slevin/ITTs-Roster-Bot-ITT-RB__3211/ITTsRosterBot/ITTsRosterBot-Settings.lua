local LAM2 = LibAddonMenu2
local Settings = {}
ITTsRosterBot.Settings = Settings
local defaults = {
    settings = {
        guilds = {
            { name = "Guild Slot #1", id = 0, disabled = true, selected = false },
            { name = "Guild Slot #2", id = 0, disabled = true, selected = false },
            { name = "Guild Slot #3", id = 0, disabled = true, selected = false },
            { name = "Guild Slot #4", id = 0, disabled = true, selected = false },
            { name = "Guild Slot #5", id = 0, disabled = true, selected = false }
        },
        guildsCache = {
            { name = "Guild Slot #1", id = 0, disabled = true, selected = false },
            { name = "Guild Slot #2", id = 0, disabled = true, selected = false },
            { name = "Guild Slot #3", id = 0, disabled = true, selected = false },
            { name = "Guild Slot #4", id = 0, disabled = true, selected = false },
            { name = "Guild Slot #5", id = 0, disabled = true, selected = false }
        },
        services = {
            sales = "MM3"
        },
        historyHighlighting = true,

        applications = {
            applicationAttachment = true,
            sales = 14,
            rankIcon = true,
            donations = true,
            guildName = true
        }
    },
    UI = {
        history = {
            item = true,
            gold = true
        }
    },
    timeFrameIndex = 4,
    join_records = {}
}
-- --------------------
-- Create Settings
-- --------------------
local lamPanelCreationInitDone = false
local panelData = {
    type = "panel",
    name = "ITT's Roster Bot",
    author = "|c00a313Ghostbane|r & |c268074JN Slevin|r",
    registerForRefresh = true,
    keywords = "guild",
    version = "1.1.0",
    website = "https://www.esoui.com/downloads/info3211-ITTsRosterBotITTRB.html",
}
local function disableServiceDropdown()
    return defaults.settings.services.auto
end
local function buildSettingsOptions()
    local optionsData = {}

    optionsData[ #optionsData + 1 ] = {
        type = "header",
        name = "Guilds"
    }

    optionsData[ #optionsData + 1 ] = {
        type = "description",
        title = "",
        text = [[]]
    }

    for i = 1, 5 do
        optionsData[ #optionsData + 1 ] = {
            type = "checkbox",
            name = function()
                local color = ""
                --[[  if ITTsRosterBot.db.settings.guilds[ i ].selected then
                    color = "|c" .. ITTsRosterBot.Utils:GetGuildColor( i ).hex
                else
                    color = ""
                end ]]
                return color .. ITTsRosterBot.db.settings.guilds[ i ].name
            end,
            tooltip = function()
                -- if db.settings.guilds[i].disabled then
                --     return "You do not have the correct permissions to scan this guild"
                -- else
                return "Turn scanning on or off for " .. ITTsRosterBot.db.settings.guilds[ i ].name
                -- end
            end,
            -- disabled = function() return db.settings.guilds[i].disabled end,
            getFunc = function()
                return ITTsRosterBot.db.settings.guilds[ i ].selected
            end,
            setFunc = function( value )
                ITTsRosterBot.db.settings.guilds[ i ].selected = value
                --  "ITTsRosterBotSettingsGuild" .. tostring( i ):UpdateValue( true )
            end,
            default = defaults.settings.guilds[ i ].selected,
            reference = "ITTsRosterBotSettingsGuild" .. tostring( i )
        }
    end

    optionsData[ #optionsData + 1 ] = {
        type = "description",
        title = "",
        text =
        [[Whilst we try to handle things automatically, stuff can slip through. If the above guild list is not correct due to a recent change, you may need to run the /reloadui command]]
    }

    --[[ optionsData[ #optionsData + 1 ] = {
        type = "checkbox",
        name = "Guild History Highlighting",
        getFunc = function()
            return ITTsRosterBot.db.settings.historyHighlighting
        end,
        setFunc = function( value )
            ITTsRosterBot.db.settings.historyHighlighting = value
        end,
        default = defaults.settings.historyHighlighting
    } ]]
    -- Color dropdown choices based on availability
    local choicesLabels = {}

    local ATT = "|c474747Arkadius' Trade Tools|r"
    local MM = "|c474747Master Merchant 3.8|r"


    for k, v in pairs( ITTsRosterBot.SalesAdapter.adapters ) do
        if ITTsRosterBot.SalesAdapter.adapters[ k ]:Available() then
            if ITTsRosterBot.SalesAdapter.adapters[ k ].settingsLabel == "Arkadius' Trade Tools" then
                ATT = "Arkadius' Trade Tools"
            elseif ITTsRosterBot.SalesAdapter.adapters[ k ].settingsLabel == "Master Merchant 3.8" then
                MM = "Master Merchant 3.8"
            end
        else

        end
    end

    choicesLabels = { "None", ATT, MM }
    local choices = { "None", "Arkadius' Trade Tools", "Master Merchant 3.8" }


    -- Sales Services
    optionsData[ #optionsData + 1 ] = {
        type = "submenu",
        name = "General Settings",
        tooltip = "Here you can chose your prefered trade addon as well as the colors for colorization of join dates!",
        icon = "/esoui/art/tutorial/gamepad/gp_playermenu_icon_settings.dds",

        controls = {
            [ 1 ] = {
                type = "description",
                --title = "My Title",	--(optional)
                title = nil, --(optional)
                text =
                "Here you can edit various settings. If the color of the sales service of your choice is greyed out it is currently not available. You can still select it and it will keep that settings if you have enabled the addon.",
                width = "full" --or "half" (optional)
            },
            [ 2 ] = {
                type = "dropdown",
                name = "Sales Service",
                tooltip = "Choose a Sales Service for the Sidebar stats",
                choices = choicesLabels,
                choicesValues = choices,

                getFunc = function()
                    local choice = "None"

                    if ITTsRosterBot.db.settings.services.sales ~= "None" then
                        choice = ITTsRosterBot.SalesAdapter.adapters[ ITTsRosterBot.db.settings.services.sales ]
                        .settingsLabel
                    end

                    return choice
                end,
                setFunc = function( choice )
                    ITTsRosterBot:SelectSalesService( choice )
                end,


            },
            [ 3 ] = {
                type = "slider",
                name = "Colorize Joindate #1",
                tooltip =
                "If the time of membership is |cff0000below|r this number it will colorize the duration since the join red.",
                getFunc = function()
                    return ITTsRosterBot.db.newcomer
                end,
                setFunc = function( number )
                    ITTsRosterBot.db.newcomer = number
                end,
                width = "half",
                disabled = false,
                min = 0,
                max = 14,
                step = 1
            },
            [ 4 ] = {
                type = "slider",
                name = "Colorize Joindate #2",
                tooltip =
                "If the time of membership is |cff0000above|r this number it will colorize the duration since the join green.",
                getFunc = function()
                    return ITTsRosterBot.db.oldNumber
                end,

                setFunc = function( number )
                    ITTsRosterBot.db.oldNumber = number
                end,
                width = "half",
                disabled = false,
                min = 14,
                max = 180,
                step = 1
            },
            [ 5 ] = {
                type = "checkbox",
                name = "Guild History Highlighting",
                getFunc = function()
                    return ITTsRosterBot.db.settings.historyHighlighting
                end,
                setFunc = function( value )
                    ITTsRosterBot.db.settings.historyHighlighting = value
                end,
                default = defaults.settings.historyHighlighting
            },

        }
    }
    optionsData[ #optionsData + 1 ] = {
        type = "submenu",
        name = "Application Attachments",
        icon = "/esoui/art/guildfinder/gamepad/gp_guildrecruitment_menuicon_applications.dds",
        controls = {
            [ 1 ] = {
                type = "description",
                --title = "My Title",	--(optional)
                title = nil, --(optional)
                text =
                "Here you can edit the attachments to the application tooltips.",
                width = "full" --or "half" (optional)
            },
            [ 2 ] = {
                type = "checkbox",
                name = "Enable Application Attachments",
                width = "full",
                tooltip = "Will attach information about the applicant under the default application tooltip",
                getFunc = function()
                    return ITTsRosterBot.db.settings.applications.applicationAttachment
                end,
                setFunc = function( value )
                    ITTsRosterBot.db.settings.applications.applicationAttachment = value
                end,
                default = defaults.settings.applications.applicationAttachment
            },
            [ 3 ] = {
                type = "checkbox",
                name = "Enable Guild Names",
                width = "half",
                --disabled = not ITTsRosterBot.db.settings.applications.applicationAttachment,
                tooltip = "Include the guild name to the attachment?",
                getFunc = function()
                    return ITTsRosterBot.db.settings.applications.guildName
                end,
                setFunc = function( value )
                    ITTsRosterBot.db.settings.applications.guildName = value
                end,
                disabled = function()
                    return not ITTsRosterBot.db.settings.applications.applicationAttachment
                end,
                default = defaults.settings.applications.guildName
            },
            [ 4 ] = {
                type = "checkbox",
                name = "Enable Rank Icon",
                --disabled = not ITTsRosterBot.db.settings.applications.applicationAttachment,
                width = "half",
                tooltip = "Include the rank icon to the attachment?",
                getFunc = function()
                    return ITTsRosterBot.db.settings.applications.rankIcon
                end,
                disabled = function()
                    return not ITTsRosterBot.db.settings.applications.applicationAttachment
                end,
                setFunc = function( value )
                    ITTsRosterBot.db.settings.applications.rankIcon = value
                end,
                default = defaults.settings.applications.rankIcon
            },
            [ 5 ] = {
                type = "slider",
                name = "Sales Timeframe",
                tooltip =
                "Chose the timeframe which gets used to check the sales and the donations from the applicant. 0 means the option is turned off.",
                -- disabled = not ITTsRosterBot.db.settings.applications.applicationAttachment,
                getFunc = function()
                    return ITTsRosterBot.db.settings.applications.sales
                end,
                setFunc = function( number )
                    ITTsRosterBot.db.settings.applications.sales = number
                end,
                disabled = function()
                    return not ITTsRosterBot.db.settings.applications.applicationAttachment
                end,
                width = "half",
                min = 0,
                max = 30,
                step = 1,
                default = defaults.settings.applications.sales
            },
            [ 6 ] = {
                type = "checkbox",
                name = "Enable Donations",
                width = "half",
                --disabled = not ITTsRosterBot.db.settings.applications.applicationAttachment,
                tooltip = "Include the donations to the attachment?",
                getFunc = function()
                    return ITTsRosterBot.db.settings.applications.donations
                end,
                setFunc = function( value )
                    ITTsRosterBot.db.settings.applications.donations = value
                end,
                disabled = function()
                    return not ITTsRosterBot.db.settings.applications.applicationAttachment
                end,
                default = defaults.settings.applications.donations
            },
        }
    }
    --[[ optionsData[ #optionsData + 1 ] = {
        type = "submenu",
        name = "Chat Formatting",
        icon = "/esoui/art/tutorial/chat-notifications_up.dds",
        controls = {
            [ 1 ] = {
                type = "description",
                --title = "My Title",	--(optional)
                title = nil, --(optional)
                text =
                "Here you can edit the settings for each guild! First choose the guild in the dropdown below, then edit the templates or turn settings on / off!\n\nThe current placeholders are:",
                width = "full" --or "half" (optional)
            }
        }
    } ]]

    optionsData[ #optionsData + 1 ] = {
        type = "description",
        title = "",
        text = [[]]
    }

    optionsData[ #optionsData + 1 ] = {
        type = "description",
        title = "",
        text = [[]]
    }

    optionsData[ #optionsData + 1 ] = {
        type = "description",
        title = "",
        text = [[ ]]
    }

    optionsData[ #optionsData + 1 ] = {
        type = "description",
        title = "",
        text = [[ ]]
    }

    optionsData[ #optionsData + 1 ] = {
        type = "texture",
        image = "ITTsRosterBot/itt-logo.dds",
        imageWidth = "192",
        imageHeight = "192",
        reference = "ITT_RosterBotSettingsLogo"
    }

    optionsData[ #optionsData + 1 ] = {
        type = "checkbox",
        name = "HideMePls",
        getFunc = function()
            return false
        end,
        setFunc = function( value )
            return false
        end,
        default = false,
        disabled = true,
        reference = "ITT_HideMePlsRoster"
    }

    return optionsData
end

local _desc = true

local function makeITTDescription()
    local ITTDTitle = WINDOW_MANAGER:CreateControl( "ITTsRosterBotSettingsLogoTitle", ITT_RosterBotSettingsLogo, CT_LABEL )
    ITTDTitle:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thin" )
    ITTDTitle:SetText( "|Cfcba03INDEPENDENT TRADING TEAM" )
    ITTDTitle:SetDimensions( 240, 31 )
    ITTDTitle:SetHorizontalAlignment( 1 )
    ITTDTitle:SetAnchor( TOP, ITT_RosterBotSettingsLogo, BOTTOM, 0, 40 )

    local ITTDLabel = WINDOW_MANAGER:CreateControl( "ITTsRosterBotSettingsLogoTitleServer", ITTsRosterBotSettingsLogoTitle,
                                                    CT_LABEL )
    ITTDLabel:SetFont( "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thick" )
    ITTDLabel:SetText( "|C646464PC EU" )
    ITTDLabel:SetDimensions( 240, 21 )
    ITTDLabel:SetHorizontalAlignment( 1 )
    ITTDLabel:SetAnchor( TOP, ITTsRosterBotSettingsLogoTitle, BOTTOM, 0, -5 )

    ITT_HideMePlsRoster:SetHidden( true )
end

local function LAMControlsCreatedCallbackFunc( pPanel )
    if pPanel ~= ITTsRosterBot.panel then
        return
    end

    if lamPanelCreationInitDone == true then
        return
    end
    makeITTDescription()
    lamPanelCreationInitDone = true
end


function Settings:Initialize()
    ITTsRosterBot.panel = LAM2:RegisterAddonPanel( "ITTsRosterBotOptions", panelData )
    local settingsOptions = buildSettingsOptions()

    CALLBACK_MANAGER:RegisterCallback( "LAM-PanelControlsCreated", LAMControlsCreatedCallbackFunc )
    LAM2:RegisterOptionControls( "ITTsRosterBotOptions", settingsOptions )
end
