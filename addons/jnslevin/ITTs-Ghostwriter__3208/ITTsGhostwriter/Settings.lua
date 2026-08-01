local GW =
    ITTsGhostwriter or
    {
        name = "ITTsGhostwriter",

    }
ITTsGhostwriter = GW
local LAM = LibAddonMenu2
local st
local dateTable = {
    "DD.MM.YY",
    "DD.MM.YYYY",
    "MM/DD/YY",
    "MM/DD/YYYY",
    "YY-MM-DD",
    "YYYY-MM-DD",
    "DD-MM-YY",
    "DD-MM-YYYY",
    "DD/MM/YY",
    "DD/MM/YYYY"
}
local dateValues = {
    "%d.%m.%y",
    "%d.%m.%Y",
    "%m/%d/%y",
    "%m/%d/%Y",
    "%y-%m-%d",
    "%Y-%m-%d",
    "%d-%m-%y",
    "%d-%m-%Y",
    "%d/%m/%y",
    "%d/%m/%Y"
}
local dateTooltips = {
    "31.03.21",
    "31.03.2021",
    "03/31/21",
    "03/31/2021",
    "21-31-03",
    "2021-31-03",
    "31-03-21",
    "31-03-2021",
    "31/03/21",
    "31/03/2021"
}

local function MailPreview()
    return st.guilds[ st.selectedGuild ].settings.mailBody
end
local function makeITTDescription()
    local ITTDTitle = WINDOW_MANAGER:CreateControl( "ITTsGhostwriterSettingsLogoTitle", ITTs_GhostwriterSettingsLogo, CT_LABEL )
    ITTDTitle:SetFont( "$(BOLD_FONT)|$(KB_18)|soft-shadow-thin" )
    ITTDTitle:SetText( "|Cfcba03INDEPENDENT TRADING TEAM" )
    ITTDTitle:SetDimensions( 240, 31 )
    ITTDTitle:SetHorizontalAlignment( 1 )
    ITTDTitle:SetAnchor( TOP, ITTs_GhostWriterSettingsLogo, BOTTOM, 0, 40 )

    local ITTDLabel = WINDOW_MANAGER:CreateControl( "ITTsGhostwriterSettingsLogoTitleServer", ITTsGhostwriterSettingsLogoTitle,
                                                    CT_LABEL )
    ITTDLabel:SetFont( "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thick" )
    ITTDLabel:SetText( "|C646464PC EU" )
    ITTDLabel:SetDimensions( 240, 21 )
    ITTDLabel:SetHorizontalAlignment( 1 )
    ITTDLabel:SetAnchor( TOP, ITTsGhostwriterSettingsLogoTitle, BOTTOM, 0, -5 )

    ITT_HideMePlsGW:SetHidden( true )
end

local lamPanelCreationInitDone = false
local function LAMControlsCreatedCallbackFunc( pPanel )
    if pPanel ~= GW.GWSettingsPanel then
        return
    end
    if lamPanelCreationInitDone == true then
        return
    end


    --! Works but Map Pins will break the menu *sadpanda*
    --[[ ITTGW_LAM_Editbox_MailText:SetHeight(550)
    ITTGW_LAM_Editbox_MailText.container:SetHeight(550)
    ITTGW_LAM_Editbox_MailText.label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    ITTGW_LAM_Editbox_MailText.container:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, 0, 25) ]]
    makeITTDescription()
    lamPanelCreationInitDone = true
end

local function createSettingsWindow()
    local _desc = true
    local text = {}
    local selectedGuildId = GW.guildTableValues[ 1 ]
    local selectedDateFormat = dateValues[ 1 ]
    local color = GW.GetGuildColor( 1 )
    GW.GWSettingsPanel =
        LAM:RegisterAddonPanel(
            "GhostwriterOptions",
            {
                type = "panel",
                name = "ITT's |c" .. GW.COLOR .. "Ghostwriter|r",
                author = "JN Slevin",
                version = tostring( GW.version ),
                registerForRefresh = true,
                registerForDefaults = false,
                website = "https://github.com/JNSlevin/ITTs-Ghostwriter"
            }
        )


    local optionsData = {}
    local guildSettings = {}
    optionsData[ #optionsData + 1 ] = {
        type = "header",
        name = "|c" .. GW.COLOR .. "Ghostwriter|r Settings"
    }
    optionsData[ #optionsData + 1 ] = {
        type        = "description",
        title       = "Setup |c" .. GW.COLOR .. "Ghostwriter|r",
        text        =
        "Please visit the Website (linked in the description). \n\n|cff0000The addon will not work and all guild specific settings will be disabled without setup!",
        enableLinks = true,
        width       = "full"
    }
    optionsData[ #optionsData + 1 ] = {
        type        = "texture",
        image       = "/esoui/art/guild/sectiondivider_left.dds",
        imageWidth  = 510,
        imageHeight = 5
    }
    optionsData[ #optionsData + 1 ] = {
        type = "header",
        name = "General Settings"
    }
    optionsData[ #optionsData + 1 ] = {
        type     = "checkbox",
        name     = "Check for online status",
        default  = false,
        disabled = false,
        width    = "full",
        tooltip  = "Will not paste the chatmessage if the invited member is offline",
        getFunc  = function()
            return st.generalSettings.offlinecheck
        end,
        setFunc  = function( value )
            st.generalSettings.offlinecheck = value
        end,
        d
    }
    optionsData[ #optionsData + 1 ] = {
        type     = "checkbox",
        name     = "Include offline mode check",
        default  = false,
        disabled = false,
        width    = "full",
        tooltip  =
        "Will include the term |cffffffOfflinemode|r in the note if the member is offline for longer than 2 weeks",
        getFunc  = function()
            return st.generalSettings.offlinemodecheck
        end,
        setFunc  = function( value )
            st.generalSettings.offlinemodecheck = value
        end,
        d
    }
    optionsData[ #optionsData + 1 ] = {
        type        = "checkbox",
        name        = "Enable backup button in Guildroster",
        default     = false,
        disabled    = false,
        width       = "full",
        isDangerous = true,
        tooltip     =
        "Will add a button to the guildroster to backup all notes in the selected guild (will be disabled if you do not have the correct permissions!",
        warning     = "This will backup your notes upon loading into the game and if any note is changed in your guild! ",
        getFunc     = function()
            return st.generalSettings.backupButton
        end,
        setFunc     = function( newValue )
            st.generalSettings.backupButton = newValue
            GW.HideBackupButton()
            GW.EnableBackupButton()
        end
    }
    optionsData[ #optionsData + 1 ] = {
        type = "slider",
        name = "Chat window notepad button position",
        getFunc = function() return st.generalSettings.chatWindowButtonOffsetX end,
        setFunc = function( value )
            st.generalSettings.chatWindowButtonOffsetX = value
            ITTsGhostwriter.UI.UpdateShowUIButton()
        end,
        tooltip = "The lower the value the more to the left the button will be",
        min = -350,
        max = -40,

        step = 10,
        width = "full"
    }
    optionsData[ #optionsData + 1 ] = {
        type = "submenu",
        name = "Guild Settings",
        icon = "/esoui/art/tutorial/guildhistory_indexicon_guild_up.dds",
        controls = guildSettings

    }
    guildSettings[ #guildSettings + 1 ] =
    {
        type  = "description",

        text  =
            "Here you can edit the settings for each guild! First choose the guild in the dropdown below, then edit the templates or turn settings on / off!\n\nThe current placeholders are: \n|c" ..
            GW.COLOR ..
            "%DATE%|r\t-\twill be replaced by the current date (in the format you chose below)!\n|c" ..
            GW.COLOR ..
            "%PLAYER%|r\t-\twill be replaced by the account name of the player!\n|c" ..
            GW.COLOR .. "%GUILD%|r\t-\twill be replaced by the guilds name!",
        width = "full"
    }
    guildSettings[ #guildSettings + 1 ] = {
        type            = "dropdown",
        name            = "Choose Guild",
        tooltip         =
        "Choose the guild you'd like to change the settings for. (if you do not have the Ghostwriter permissions in a guild every setting will be disabled)",
        choices         = GW.guildTable,
        choicesValues   = GW.guildTableValues,
        choicesTooltips = GW.guildTableValues,
        disabled        = false,
        getFunc         = function()
            return st.selectedGuild
        end,
        setFunc         = function( guildId )
            st.selectedGuild = guildId
        end,
        width           = "full"
    }
    guildSettings[ #guildSettings + 1 ] = {
        type            = "dropdown",
        name            = "Choose date format",
        tooltip         = "Choose format of the date for the placeholder",
        choices         = dateTable,
        disabled        = function()
            if
                GW.GetPermission_Note( st.selectedGuild ) == true or GW.GetPermission_Mail( st.selectedGuild ) == true or
                GW.GetPermission_Chat( st.selectedGuild ) == true
            then
                return false
            else
                return true
            end
        end,
        choicesValues   = dateValues,
        choicesTooltips = dateTooltips,
        getFunc         = function()
            return st.guilds[ st.selectedGuild ].settings.dateFormat
        end,
        setFunc         = function( dateFormat )
            st.guilds[ st.selectedGuild ].settings.dateFormat = dateFormat
        end,
        width           = "full"
    }
    guildSettings[ #guildSettings + 1 ] = {
        type     = "checkbox",
        name     = "Note alerts",
        default  = false,
        disabled = function()
            if DoesPlayerHaveGuildPermission( st.selectedGuild, GUILD_PERMISSION_NOTE_EDIT ) == true then
                return false
            else
                return true
            end
        end,
        width    = "full",
        tooltip  =
        "Will announce in the system chat if notes got changed in your guild (needs permission to edit notes)",
        getFunc  = function()
            return st.guilds[ st.selectedGuild ].settings.noteAlert
        end,
        setFunc  = function( value )
            st.guilds[ st.selectedGuild ].settings.noteAlert = value
        end
    }
    guildSettings[ #guildSettings + 1 ] = {
        type = "header",
        name = "Application Alert Settings"
    }
    guildSettings[ #guildSettings + 1 ] =
    {
        type     = "checkbox",
        name     = "Application alerts",
        default  = false,
        disabled = function()
            if DoesPlayerHaveGuildPermission( st.selectedGuild, GUILD_PERMISSION_MANAGE_APPLICATIONS ) == true then
                return false
            else
                return true
            end
        end,
        width    = "full",
        tooltip  =
        "Will announce in the system chat if new applications are open in your guild (needs permission to manage applications)!",
        getFunc  = function()
            return st.guilds[ st.selectedGuild ].settings.applicationAlert
        end,
        setFunc  = function( value )
            st.guilds[ st.selectedGuild ].settings.applicationAlert = value
        end
    }
    guildSettings[ #guildSettings + 1 ] =
    {
        type     = "slider",
        name     = "Minimum cp",
        tooltip  =
        "Set the minimum amount of CP for new applications to be shown in the system chat if a new application arrives. (0 will remove it from the alert)",
        getFunc  = function()
            return st.guilds[ st.selectedGuild ].settings.applicationThreshold
        end,
        setFunc  = function( number )
            st.guilds[ st.selectedGuild ].settings.applicationThreshold = number
        end,
        width    = "half",
        disabled = function()
            if st.guilds[ st.selectedGuild ].settings.applicationAlert == true then
                return false
            else
                return true
            end
        end,
        min      = 0,
        max      = 3600,
        step     = 50

    }
    guildSettings[ #guildSettings + 1 ] = {
        type     = "slider",
        name     = "Minimum achievement points",
        tooltip  =
        "Set the minimum amount of achievementpoints for new applications to be shown in the system chat if a new application arrives. (0 will remove it from the alert)",
        getFunc  = function()
            return st.guilds[ st.selectedGuild ].settings.achievementThreshold
        end,
        setFunc  = function( number )
            st.guilds[ st.selectedGuild ].settings.achievementThreshold = number
        end,
        width    = "half",
        disabled = function()
            if st.guilds[ st.selectedGuild ].settings.applicationAlert == true then
                return false
            else
                return true
            end
        end,
        min      = 0,
        max      = 50000,
        step     = 1000
    }
    guildSettings[ #guildSettings + 1 ] = {
        type = "header",
        name = "New member message settings",

    }
    guildSettings[ #guildSettings + 1 ] = {
        type     = "checkbox",
        name     = "Enable new member message",
        default  = false,
        disabled = function()
            if GW.GetPermission_Chat( st.selectedGuild ) == true then
                return false
            else
                return true
            end
        end,
        width    = "half",
        tooltip  = "Will paste the below template in you chat for new members of you guild!",
        getFunc  = function()
            return st.guilds[ st.selectedGuild ].settings.messageEnabled
        end,
        setFunc  = function( value )
            st.guilds[ st.selectedGuild ].settings.messageEnabled = value
        end
    }
    guildSettings[ #guildSettings + 1 ] = {
        type     = "checkbox",
        name     = "Enable new member note",
        default  = false,
        disabled = function()
            if GW.GetPermission_Note( st.selectedGuild ) then
                return false
            else
                return true
            end
        end,
        width    = "half",
        tooltip  = "Will set a note for the new player!",
        getFunc  = function()
            return st.guilds[ st.selectedGuild ].settings.noteEnabled
        end,
        setFunc  = function( value )
            st.guilds[ st.selectedGuild ].settings.noteEnabled = value
        end
    }
    guildSettings[ #guildSettings + 1 ] = {
        type        = "editbox",
        name        = "ChatMessage",
        tooltip     = "This message will be pasted in your chat!\n\nMaximum is " ..
            MAX_TEXT_CHAT_INPUT_CHARACTERS .. " Characters!",
        isExtraWide = true,
        isMultiline = true,
        maxChars    = MAX_TEXT_CHAT_INPUT_CHARACTERS,
        disabled    = function()
            if GW.GetPermission_Chat( st.selectedGuild ) == true then
                return false
            else
                return true
            end
        end,
        width       = "half",
        getFunc     = function()
            return st.guilds[ st.selectedGuild ].settings.messageBody
        end,
        setFunc     = function( text )
            st.guilds[ st.selectedGuild ].settings.messageBody = text
        end
    }
    guildSettings[ #guildSettings + 1 ] = {
        type        = "editbox",
        name        = "Note template",
        tooltip     = "This note will be set for the new player!\n\nMaximum is " ..
            MAX_GUILD_APPLICATION_MESSAGE_LENGTH .. " Characters!",
        isExtraWide = true,
        isMultiline = true,
        maxChars    = MAX_GUILD_APPLICATION_MESSAGE_LENGTH,
        disabled    = function()
            if GW.GetPermission_Note( st.selectedGuild ) == true then
                return false
            else
                return true
            end
        end,
        width       = "half",
        getFunc     = function()
            return st.guilds[ st.selectedGuild ].settings.noteBody
        end,
        setFunc     = function( text )
            st.guilds[ st.selectedGuild ].settings.noteBody = text
        end
    }
    guildSettings[ #guildSettings + 1 ] = {
        type        = "texture",
        image       = "/esoui/art/campaign/campaignbrowser_listdivider_right.dds",
        imageWidth  = 510,
        imageHeight = 5
    }
    guildSettings[ #guildSettings + 1 ] = {
        type = "header",
        name = "Mail Settings",
    }
    guildSettings[ #guildSettings + 1 ] = {
        type     = "checkbox",
        name     = "Enable new member mail",
        default  = false,
        disabled = function()
            if GW.GetPermission_Mail( st.selectedGuild ) == true then
                return false
            else
                return true
            end
        end,
        width    = "full",
        tooltip  = "Will send a mail to the new member!",
        getFunc  = function()
            return st.guilds[ st.selectedGuild ].settings.mailEnabled
        end,
        setFunc  = function( value )
            st.guilds[ st.selectedGuild ].settings.mailEnabled = value
        end
    }
    guildSettings[ #guildSettings + 1 ] = {
        type        = "editbox",
        name        = "Mail subject template",
        tooltip     = "This is the subject of the mail\n\nMaximum is " .. MAIL_MAX_SUBJECT_CHARACTERS .. " Characters",
        isExtraWide = true,
        isMultiline = false,
        maxChars    = MAIL_MAX_SUBJECT_CHARACTERS,
        disabled    = function()
            if GW.GetPermission_Mail( st.selectedGuild ) == true then
                return false
            else
                return true
            end
        end,
        width       = "full",
        getFunc     = function()
            return st.guilds[ st.selectedGuild ].settings.mailSubject
        end,
        setFunc     = function( text )
            st.guilds[ st.selectedGuild ].settings.mailSubject = text
        end,
        reference   = "GW_SubjectWindow",
    }
    guildSettings[ #guildSettings + 1 ] = {
        type        = "editbox",
        name        = "Mail body template",
        tooltip     = "This is the body of the mail\n\nMaximum is " .. MAIL_MAX_BODY_CHARACTERS .. " Characters",
        isExtraWide = true,
        isMultiline = true,
        maxChars    = MAIL_MAX_BODY_CHARACTERS,
        disabled    = function()
            if GW.GetPermission_Mail( st.selectedGuild ) == true then
                return false
            else
                return true
            end
        end,
        width       = "full",
        getFunc     = function()
            return st.guilds[ st.selectedGuild ].settings.mailBody
        end,
        setFunc     = function( text )
            st.guilds[ st.selectedGuild ].settings.mailBody = text
        end,
        reference   = "ITTGW_LAM_Editbox_MailText",
    }
    guildSettings[ #guildSettings + 1 ] = {
        type = "description",
        title = "",
        text = [[ ]]
    }
    guildSettings[ #guildSettings + 1 ] = {
        type      = "submenu",
        name      = "Mail Preview",
        icon      = "/esoui/art/miscellaneous/search_icon.dds",
        reference = "GW_MailPreview",
        controls  = {
            [ 1 ] = {
                type = "description",
                title = "",
                text = MailPreview
            }
        }
    }
    guildSettings[ #guildSettings + 1 ] = {
        type      = "submenu",
        name      = "|cffffffBackup options",
        reference = "GW_BackupOptions",
        disabled  = function()
            if GW.GetPermission_Note( st.selectedGuild ) == true then
                return false
            else
                return true
            end
        end,
        controls  = {
            [ 1 ] = {
                type        = "checkbox",
                name        = "AutoBackup",
                default     = false,
                disabled    = false,
                width       = "full",
                isDangerous = true,
                tooltip     = "Will automatically backup member notes!!",
                warning     =
                "This will backup your notes upon loading into the game and if any note is changed in your guild! ",
                getFunc     = function()
                    return st.guilds[ st.selectedGuild ].settings.autobackup
                end,
                setFunc     = function( newValue )
                    st.guilds[ st.selectedGuild ].settings.autobackup = newValue
                end
            }
        }
    }
    optionsData[ #optionsData + 1 ] = {
        type  = "description",
        title = "",
        text  = [[ ]]
    }
    optionsData[ #optionsData + 1 ] = {
        type  = "description",
        title = "",
        text  = [[ ]]
    }
    optionsData[ #optionsData + 1 ] = {
        type  = "description",
        title = "",
        text  = [[ ]]
    }
    optionsData[ #optionsData + 1 ] = {
        type        = "texture",
        image       = "ITTsGhostwriter/itt-logo.dds",
        imageWidth  = "192",
        imageHeight = "192",
        reference   = "ITTs_GhostwriterSettingsLogo"
    }
    optionsData[ #optionsData + 1 ] = {
        type      = "checkbox",
        name      = "HideMePls",
        getFunc   = function()
            return false
        end,
        setFunc   = function( value )
            return false
        end,
        default   = false,
        disabled  = true,
        reference = "ITT_HideMePlsGW"
    }
    CALLBACK_MANAGER:RegisterCallback( "LAM-PanelControlsCreated", LAMControlsCreatedCallbackFunc )
    LAM:RegisterOptionControls( "GhostwriterOptions", optionsData )
end

function GW.InitializeSettings()
    st = ITTsGhostwriter.Vars
    createSettingsWindow()
end
