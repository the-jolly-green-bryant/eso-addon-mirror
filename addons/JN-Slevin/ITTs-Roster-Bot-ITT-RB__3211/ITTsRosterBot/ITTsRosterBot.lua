ITTsRosterBot = ZO_CallbackObject:New()
ITTsRosterBot.name = "ITTsRosterBot"

local db = {}
ITTsRosterBot.db = db
local LH = LibHistoire
local logger = LibDebugLogger( ITTsRosterBot.name )
ITTsRosterBotListener = {}

logger:SetEnabled( true )

local chat = LibChatMessage( "ITTsRosterBot", "ITTs-RB" )

local SECONDS_IN_HOUR = 60 * 60
local SECONDS_IN_DAY = SECONDS_IN_HOUR * 24
local SECONDS_IN_WEEK = SECONDS_IN_DAY * 7

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
    newcomer = 7,
    oldNumber = 180,
    UI = {
        history = {
            item = true,
            gold = true
        }
    },
    timeFrameIndex = 4
}

local worldName = GetWorldName()

-- --------------------
-- Application Append
-- --------------------
local function GetApplicationAppendage( guildId, displayName )
    local memberInfo = ITTsRosterBot.Utils:GetRelatedGuildInfo( displayName )
    --/esoui/art/miscellaneous/wide_divider_left.dds
    local guildName = ""
    local rankIconString = "x"
    --logger:Debug( #memberInfo )
    local text = ""
    local salesString = ""
    local sales = 0
    local donations = 0
    local donationString = ""
    local t1 = {}
    local divider = "" -- "|t500:5:/esoui/art/charactercreate/windowdivider.dds|t
    for i = 1, #memberInfo do
        local timeframe = ITTsRosterBot.db.settings.applications.sales
        donations = ITTsDonationBot:QueryValues( memberInfo[ i ].guildId, displayName,
            GetTimeStamp() - (timeframe * SECONDS_IN_DAY),
            GetTimeStamp() )
        if ITTsRosterBot.SalesAdapter:Selected() ~= nil then
            sales = ITTsRosterBot.SalesAdapter:GetSaleInformation( memberInfo[ i ].guildId, displayName,
                GetTimeStamp() - (timeframe * SECONDS_IN_DAY),
                GetTimeStamp() ).sales
        end
        if ITTsRosterBot.db.settings.applications.guildName == true then
            guildName = GetGuildName( memberInfo[ i ].guildId )
        end
        if ITTsRosterBot.db.settings.applications.rankIcon == true then
            rankIconString = memberInfo[ i ].rankIconString
        end
        if ITTsRosterBot.db.settings.applications.sales > 0 then
            salesString = "|r\n\t\t\t\t\t\t\tSales: " ..
                ZO_CommaDelimitNumber( sales ) .. " |t20:20:EsoUI/Art/currency/currency_gold.dds|t"
        end
        if ITTsRosterBot.db.settings.applications.donations == true then
            donationString = "|r\n\t\t\t\t\t\t\tDonations: " ..
                ZO_CommaDelimitNumber( donations ) .. " |t20:20:EsoUI/Art/currency/currency_gold.dds|t"
        end
        -- logger:Warn( rankIconString )
        t1[ i ] = "|c" ..
            memberInfo[ i ].guildColor ..
            rankIconString ..
            guildName ..
            salesString ..
            donationString
        -- text = text .. "|c" .. memberInfo[ i ].guildColor .. memberInfo[ i ].guildName .. memberInfo[ i ].rankIconString
    end
    if ITTsRosterBot.db.settings.applications.applicationAttachment == true then
        text = table.concat( t1, "\n|t200:10:/esoui/art/miscellaneous/wide_divider_left.dds|t\n" )
    end
    -- logger:Debug( text )
    -- local relatedGuilds = ITTsRosterBot:BuildRelatedGuilds( displayName, GetGuildName(GUILD_ROSTER_MANAGER.guildId) )
    local relatedGuilds, test = ITTsRosterBot.Utils:BuildInlineRelatedGuilds( displayName, guildId )
    --logger:Warn( test )
    if relatedGuilds ~= "" then
        text = "\n|C4bc8ebRelated Guilds:|C999999 \n" .. text
    end
    return text
end
function ZO_GuildRecruitment_ApplicationsList_Row_OnMouseEnter( control )
    GUILD_RECRUITMENT_APPLICATIONS_KEYBOARD:GetSubcategoryManager(
        ZO_GUILD_RECRUITMENT_APPLICATIONS_SUBCATEGORY_KEYBOARD_RECEIVED ):Row_OnMouseEnter( control )
    local originalMessage = GUILD_FINDER_MANAGER.applicationKeyboardTooltipInfo.messageControl:GetText()
    local guildId = GUILD_ROSTER_MANAGER.guildId
    local displayName = control:GetNamedChild( "Name" ):GetText()
    local text = GetApplicationAppendage( guildId, displayName )
    GUILD_FINDER_MANAGER.applicationKeyboardTooltipInfo.messageControl:SetText( originalMessage .. text )
end

-- --------------------
-- Event Callbacks
-- --------------------
local function OnPlayerActivated( eventCode )
    EVENT_MANAGER:UnregisterForEvent( ITTsRosterBot.name, eventCode )

    ITTsRosterBot:Initialize()
end

local function OnHistoryResponseReceived( ev, guildId, category )
    if category == GUILD_HISTORY_GENERAL and ITTsRosterBot:IsGuildEnabled( guildId ) then
        -- ITTsRosterBot:RunScanCycle( guildId )
    end

    -- logger:Info('---------------------------------')
end

local function ITTsRosterBot_OnAddOnLoaded( eventCode, addOnName )
    if addOnName == ITTsRosterBot.name then
        logger:Info( "ITTsRosterBot_OnAddOnLoaded" )

        db = ZO_SavedVars:NewAccountWide( "ITTsRosterBotSettings", 2, nil, defaults )
        ITTsRosterBot.db = db

        --MyChatHandlersMessageChannelFormatter()
        EVENT_MANAGER:UnregisterForEvent( ITTsRosterBot.name, eventCode )
    end
end

-- --------------------
-- Methods
-- --------------------
function ITTsRosterBot:Initialize()
    logger:Info( "ITTsRosterBot:Initialize()", self.name )

    EVENT_MANAGER:RegisterForEvent( ITTsRosterBot.name, EVENT_GUILD_HISTORY_RESPONSE_RECEIVED, OnHistoryResponseReceived )

    EVENT_MANAGER:RegisterForEvent(
        ITTsRosterBot.name,
        EVENT_GUILD_SELF_JOINED_GUILD,
        function( _, _, newGuildId )
            logger:Info( "EVENT_GUILD_SELF_JOINED_GUILD" )
            ITTsRosterBot:CheckGuildPermissions( newGuildId )
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        ITTsRosterBot.name,
        EVENT_GUILD_SELF_LEFT_GUILD,
        function()
            logger:Info( "EVENT_GUILD_SELF_LEFT_GUILD" )
            ITTsRosterBot:CheckGuildPermissions()
        end
    )

    self.memberCache = {}

    self.SalesAdapter:Initialize()
    self.Settings:Initialize()

    self:CheckGuildPermissions()
    --self:RequestAllHistory()
    ITTsRosterBot.SetupListeners()
    self.Utils:CacheMembers()
    self.UI:Setup()

    -- self:CreateStatusBox()

    GUILD_ROSTER_KEYBOARD.DisplayName_OnMouseEnter = function( self, control )
        local row = control:GetParent()
        local data = ZO_ScrollList_GetData( row )
        local timeString = nil
        local joinString = nil
        local importString = nil
        local text = ""
        local color = "FFFFFF"

        if ITTsRosterBotData[ worldName ].guilds[ GUILD_ROSTER_MANAGER.guildId ].join_records and
            ITTsRosterBotData[ worldName ].guilds[ GUILD_ROSTER_MANAGER.guildId ].join_records[ data.displayName ] and
            ITTsRosterBotData[ worldName ].guilds[ GUILD_ROSTER_MANAGER.guildId ].join_records[ data.displayName ].first
        then
            local joinedFirst = ITTsRosterBotData[ worldName ].guilds[ GUILD_ROSTER_MANAGER.guildId ].join_records[
            data.displayName ].first
            local formatedTime = os.date( "*t", joinedFirst )
            local hour = formatedTime.hour
            local min = formatedTime.min

            if hour < 10 then
                hour = "0" .. tostring( hour )
            end

            if min < 10 then
                min = "0" .. tostring( min )
            end

            timeString =
                "|cF49B22Joined first: |C" ..
                color ..
                ZO_FormatDurationAgo( (GetTimeStamp() - joinedFirst) ) ..
                " |c858585( " .. formatedTime.day .. "/" .. formatedTime.month .. "/" .. formatedTime.year .. " )" .. "\n"
        end

        if ITTsRosterBotData[ worldName ].guilds[ GUILD_ROSTER_MANAGER.guildId ].join_records and
            ITTsRosterBotData[ worldName ].guilds[ GUILD_ROSTER_MANAGER.guildId ].join_records[ data.displayName ] and
            ITTsRosterBotData[ worldName ].guilds[ GUILD_ROSTER_MANAGER.guildId ].join_records[ data.displayName ].last
        then
            local joinedLast = ITTsRosterBotData[ worldName ].guilds[ GUILD_ROSTER_MANAGER.guildId ].join_records[
            data.displayName ].last
            local formatedTime = os.date( "*t", joinedLast )
            local hour = formatedTime.hour
            local min = formatedTime.min
            local newcomer = ITTsRosterBot.db.newcomer * 86400 -- seconds in day
            local oldNumber = ITTsRosterBot.db.oldNumber * 86400
            if GetTimeStamp() - joinedLast < newcomer then
                color = "FA5858"
            end

            if GetTimeStamp() - joinedLast > oldNumber then
                color = "A9F5A9"
            end

            if hour < 10 then
                hour = "0" .. tostring( hour )
            end

            if min < 10 then
                min = "0" .. tostring( min )
            end

            joinString =
                "|c00FFBFLatest join: |C" ..
                color ..
                ZO_FormatDurationAgo( (GetTimeStamp() - joinedLast) ) ..
                " |c858585( " .. formatedTime.day .. "/" .. formatedTime.month .. "/" .. formatedTime.year .. " )" .. "\n"
        end

        if ITTsRosterBotData[ worldName ].guilds[ GUILD_ROSTER_MANAGER.guildId ].join_records and
            ITTsRosterBotData[ worldName ].guilds[ GUILD_ROSTER_MANAGER.guildId ].join_records[ data.displayName ] and
            ITTsRosterBotData[ worldName ].guilds[ GUILD_ROSTER_MANAGER.guildId ].join_records[ data.displayName ].import
        then
            local import = ITTsRosterBotData[ worldName ].guilds[ GUILD_ROSTER_MANAGER.guildId ].join_records
                [ data.displayName ].import
            local formatedTime = os.date( "*t", import )
            local hour = formatedTime.hour
            local min = formatedTime.min

            if hour < 10 then
                hour = "0" .. tostring( hour )
            end

            if min < 10 then
                min = "0" .. tostring( min )
            end

            importString =
                "|c00FFB2Imported: |CFFFFFF" ..
                ZO_FormatDurationAgo( (GetTimeStamp() - import) ) ..
                " |c858585( " .. formatedTime.day .. "/" .. formatedTime.month .. "/" .. formatedTime.year .. " )" .. "\n"
        end

        if timeString ~= nil then
            text = timeString
        end

        if joinString ~= nil then
            text = joinString
        end

        if importString ~= nil then
            text = importString
        end

        if timeString ~= nil and joinString ~= nil then
            text = timeString .. joinString
        end

        if importString ~= nil and joinString ~= nil then
            text = importString .. joinString
        end

        if timeString ~= nil and importString ~= nil then
            text = timeString .. importString
        end

        if timeString ~= nil and joinString ~= nil and importString ~= nil then
            if timeString == joinString then
                return
            elseif timeString == importString then
                return
            elseif joinString == importString then
                return
            else
                text = timeString .. joinString .. importString
            end
        end

        local relatedGuilds = ITTsRosterBot.Utils:BuildInlineRelatedGuilds( data.displayName, GUILD_ROSTER_MANAGER.guildId )

        if data.displayName ~= GetDisplayName() and relatedGuilds ~= "" then
            text = text .. "|C4bc8ebRelated Guilds:|C999999 " .. relatedGuilds .. "\n"
        end

        text = text .. "|C0095bfCharacter: |C999999" .. ZO_FormatUserFacingCharacterName( data.characterName )

        if (text ~= "") then
            InitializeTooltip( InformationTooltip )
            SetTooltipText( InformationTooltip, text )
            InformationTooltip:ClearAnchors()
            InformationTooltip:SetAnchor( BOTTOM, control, TOPLEFT, control:GetTextDimensions() * 0.5, 0 )
        end

        self:EnterRow( row )
    end
end

function ITTsRosterBot:SelectSalesService( choice )
    if choice ~= "None" then
        for k, v in pairs( ITTsRosterBot.SalesAdapter.adapters ) do
            logger:Info( choice )
            if ITTsRosterBot.SalesAdapter.adapters[ k ].settingsLabel == choice then
                choice = ITTsRosterBot.SalesAdapter.adapters[ k ].name
                if ITTsRosterBot.SalesAdapter.adapters[ k ]:Available() then
                    ITTsRosterBot.SalesAdapter.adapters[ k ]:ShowUI()
                    ITTsRosterBot.UI:ConfigureDropdown()
                    ITTsRosterBot.UI:CheckServiceStatus()
                end
            end
        end
    end




    ITTsRosterBot.db.settings.services.sales = choice
    if ITTsRosterBot.db.settings.services.sales ~= "None" then
        ITTsRosterBot_SalesTotalTitle:SetText(
            "|t20:20:EsoUI/Art/Guild/guild_tradingHouseAccess.dds|t SALES   |c66ffc2[ " ..
            ITTsRosterBot.db.settings.services.sales .. " ]"
        )
    else
        ITTsRosterBot_SalesTotalTitle:SetText( "|t20:20:EsoUI/Art/Guild/guild_tradingHouseAccess.dds|t SALES" )
    end
end

function ITTsRosterBot:CacheMembers()
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId( i )
        local gname = GetGuildName( guildId )
        local total = GetNumGuildMembers( guildId )

        if gname ~= "" then
            for l = 1, total do
                local displayName, _, _, _, _ = GetGuildMemberInfo( guildId, l )
                if self.memberCache[ displayName ] == nil then
                    self.memberCache[ displayName ] = {}
                end

                table.insert( self.memberCache[ displayName ], gname )
            end
        end
    end
end

function ITTsRosterBot:CreateStatusBox()
    local statusBox = WINDOW_MANAGER:CreateControl( "ITT_StatusBox", ZO_ChatWindow, CT_LABEL )
    statusBox:SetFont( "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin" )
    statusBox:SetText(
        "|t42:42:esoui/art/tutorial/guild-tabicon_roster_up.dds|t   |C277fa8Writing guild notes ( |C38cff548|C277fa8 / 118 )      ~ 27 mins                     |t18:18:esoui/art/buttons/decline_up.dds|t"
    )
    statusBox:SetDimensions( ZO_ChatWindow:GetWidth(), 48 )
    statusBox:SetHorizontalAlignment( 0 )
    statusBox:SetVerticalAlignment( 1 )
    statusBox:SetAnchor( BOTTOM, ZO_ChatWindow, TOP, 0, -50 )

    local statusBoxBG = WINDOW_MANAGER:CreateControl( "ITT_StatusBoxBG", statusBox, CT_BACKDROP )
    statusBoxBG:SetDimensions( statusBox:GetWidth(), statusBox:GetHeight() )
    statusBoxBG:SetAnchor( CENTER, statusBox, CENTER, 0, 0 )
    statusBoxBG:SetAlpha( 0.7 )
    statusBoxBG:SetCenterColor( ZO_ColorDef:New( 0, 0, 0, 1 ):UnpackRGBA() )
    statusBoxBG:SetEdgeColor( ZO_ColorDef:New( 0, 0, 0, 0 ):UnpackRGBA() )
end

function ITTsRosterBot:BuildRelatedGuilds( displayName, currentGuild )
    local guilds = self.memberCache[ displayName ]
    local gtext = ""

    if guilds ~= nil then
        for k, v in pairs( guilds ) do
            if currentGuild ~= nil and v == currentGuild then
            else
                if gtext ~= "" then
                    gtext = gtext .. ", "
                end

                gtext = gtext .. v
            end
        end

        if gtext ~= "" then
            gtext = gtext .. "."
        end
    end

    return gtext
end

function ITTsRosterBot:CheckGuildPermissions( newGuildId )
    logger:Info( "ITTsRosterBot:CheckGuildPermissions()" )

    for i = 1, 5 do
        local guildId = GetGuildId( i )

        logger:Info( "-----" )
        logger:Info( "Guild #" .. tostring( i ) .. " ", GetGuildName( guildId ), guildId )
        local control = _G[ "ITTsRosterBotSettingsGuild" .. tostring( i ) ]

        if guildId > 0 then
            -- end
            local guildName = GetGuildName( guildId )
            local cachedSetting = ITTsRosterBot.db.settings.guilds[ i ].selected

            if guildId ~= ITTsRosterBot.db.settings.guildsCache[ i ].id then
                logger:Info( "#" .. tostring( i ) .. " is a mis-match" )

                for inc = 1, 5 do
                    logger:Info(
                        "CACHE CHECK for slot #" .. tostring( i ) .. " - [" .. tostring( inc ) .. "]",
                        ITTsRosterBot.db.settings.guildsCache[ inc ].id,
                        guildId,
                        ITTsRosterBot.db.settings.guildsCache[ inc ].id == guildId
                    )

                    if ITTsRosterBot.db.settings.guildsCache[ inc ].id == guildId then
                        cachedSetting = ITTsRosterBot.db.settings.guildsCache[ inc ].selected
                        logger:Info( "The previous value was", cachedSetting )
                    end
                end
            end

            ITTsRosterBot.db.settings.guilds[ i ].name = guildName
            ITTsRosterBot.db.settings.guilds[ i ].id = guildId

            if newGuildId and ITTsRosterBot.db.settings.guilds[ i ].id == newGuildId then
                ITTsRosterBot.db.settings.guilds[ i ].selected = true
                ITTsRosterBot.db.settings.guilds[ i ].disabled = false
            elseif "Guild Slot #" .. tostring( i ) == ITTsRosterBot.db.settings.guildsCache[ i ].name then
                ITTsRosterBot.db.settings.guilds[ i ].selected = true
                ITTsRosterBot.db.settings.guilds[ i ].disabled = false
            end

            -- else

            -- ITTsRosterBot.db.settings.guilds[i].selected = false
            ITTsRosterBot.db.settings.guilds[ i ].disabled = false
        else
            ITTsRosterBot.db.settings.guilds[ i ].name = "Guild Slot #" .. tostring( i )
            ITTsRosterBot.db.settings.guilds[ i ].id = 0
            ITTsRosterBot.db.settings.guilds[ i ].disabled = true
            ITTsRosterBot.db.settings.guilds[ i ].selected = false
        end

        if control then
            control.label:SetText( ITTsRosterBot.db.settings.guilds[ i ].name )
            control:UpdateValue()
            -- control.UpdateDisabled()
        end
    end

    ZO_DeepTableCopy( ITTsRosterBot.db.settings.guilds, ITTsRosterBot.db.settings.guildsCache )
end

function ITTsRosterBot:SaveEvent( guildId, eventType, eventTimeStamp, displayName )
    local timeStamp = GetTimeStamp()
    local secsSinceEvent = timeStamp - eventTimeStamp
    if eventType == GUILD_EVENT_GUILD_JOIN and secsSinceEvent >= 0 then
        if eventTimeStamp < 0 then
            eventTimeStamp = timeStamp
        end

        if not ITTsRosterBotData[ worldName ].guilds[ guildId ].join_records[ displayName ] then
            ITTsRosterBotData[ worldName ].guilds[ guildId ].join_records[ displayName ] = {}
            ITTsRosterBotData[ worldName ].guilds[ guildId ].join_records[ displayName ].last = eventTimeStamp
        end
        if not ITTsRosterBotData[ worldName ].lastEventTimeStamp then
            ITTsRosterBotData[ worldName ].lastEventTimeStamp = eventTimeStamp
        end
        if not ITTsRosterBotData[ worldName ].lastEvent then
            ITTsRosterBotData[ worldName ].lastEvent = eventTimeStamp
        end
        if ITTsRosterBotData[ worldName ].lastEvent < eventTimeStamp then
            ITTsRosterBotData[ worldName ].lastEvent = eventTimeStamp
        end
        if ITTsRosterBotData[ worldName ].lastEventTimeStamp < eventTimeStamp then
            ITTsRosterBotData[ worldName ].lastEventTimeStamp = eventTimeStamp
        end
        if ITTsRosterBotData[ worldName ].guilds[ guildId ].join_records[ displayName ].last ~= nil then
            if eventTimeStamp < ITTsRosterBotData[ worldName ].guilds[ guildId ].join_records[ displayName ].last - 86400 then
                ITTsRosterBotData[ worldName ].guilds[ guildId ].join_records[ displayName ].first = eventTimeStamp
            else
                ITTsRosterBotData[ worldName ].guilds[ guildId ].join_records[ displayName ].last = eventTimeStamp
            end
        end
    end
end

--[[ function ITTsRosterBot:RunScanCycle( guildId, forceIndex )
    self.scanHistory = self.scanHistory or {}
    local start = self.scanHistory[ guildId ] or 1
    local numGuildEvents = GetNumGuildEvents( guildId, GUILD_HISTORY_GENERAL_ROSTER )

    if forceIndex then
        start = 1
    end

    logger:Info( "start:", start )
    logger:Info( "scanHistory:", self.scanHistory[ guildId ] )

    for index = start, numGuildEvents do
        self:SaveEvent( guildId, index )
    end

    self.scanHistory[ guildId ] = numGuildEvents + 1
end ]]

function ITTsRosterBot:GetGuildMap()
    local guilds = {}

    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId( i )
        if ITTsRosterBot.db.settings.guilds[ i ].selected and not ITTsRosterBot.db.settings.guilds[ i ].disabled then
            guilds[ #guilds + 1 ] = ITTsRosterBot.db.settings.guilds[ i ].id

            if not ITTsRosterBotData then
                ITTsRosterBotData = {}
            end

            if not ITTsRosterBotData[ worldName ] then
                ITTsRosterBotData[ worldName ] = {}
            end

            if not ITTsRosterBotData[ worldName ].guilds then
                ITTsRosterBotData[ worldName ].guilds = {}
            end

            if not ITTsRosterBotData[ worldName ].guilds[ guildId ] then
                ITTsRosterBotData[ worldName ].guilds[ guildId ] = {}
            end

            if not ITTsRosterBotData[ worldName ].guilds[ guildId ].join_records then
                ITTsRosterBotData[ worldName ].guilds[ guildId ].join_records = {}
            end
        end
    end
    return guilds
end

function ITTsRosterBot:IsGuildEnabled( guildId )
    local list = self:GetGuildMap()
    local condition = false

    for i = 1, #list do
        if guildId == list[ i ] then
            condition = true
            break
        end
    end

    return condition
end

--[[ function ITTsRosterBot:RequestAllHistory()
    for _, guildId in pairs( self:GetGuildMap() ) do
        self:RequestHistory( guildId, GUILD_HISTORY_GENERAL )
    end
end

function ITTsRosterBot:RequestHistory( gID, guildHistoryCategory )
    local cooldown = 1000 * 60

    logger:Info( "ITTsRosterBot:RequestHistory() running -", GetGuildName( gID ) .. "-" .. guildHistoryCategory )

    if DoesGuildHistoryCategoryHaveOutstandingRequest( gID, guildHistoryCategory ) == false and
        IsGuildHistoryCategoryRequestQueued( gID, guildHistoryCategory ) == false
    then
        if DoesGuildHistoryCategoryHaveMoreEvents( gID, guildHistoryCategory ) then
            logger:Info( "More history exists for ", GetGuildName( gID ) .. "-" .. guildHistoryCategory )

            if RequestMoreGuildHistoryCategoryEvents( gID, guildHistoryCategory ) then
                logger:Info( "Requesting Guild History:", GetGuildName( gID ) .. "-" .. guildHistoryCategory )
                zo_callLater(
                    function()
                        ITTsRosterBot:RequestHistory( gID, guildHistoryCategory )
                    end,
                    cooldown
                )
            else
                logger:Info(
                    "Request cooldown for ",
                    GetGuildName( gID ) .. "-" .. guildHistoryCategory,
                    " has not expired yet, re-calling in a few minutes"
                )
                zo_callLater(
                    function()
                        ITTsRosterBot:RequestHistory( gID, guildHistoryCategory )
                    end,
                    cooldown
                )
            end
        else
            logger:Info( "No more history exists for ", GetGuildName( gID ) .. "-" .. guildHistoryCategory )
            logger:Info( "Total:", GetNumGuildEvents( gID, guildHistoryCategory ) )

            if GetNumGuildEvents( gID, guildHistoryCategory ) > 0 and
                ITTsRosterBotData[ worldName ].guilds[ gID ].join_records == nil then -- ITTsRosterBotData[worldName].guilds[guildId].join_records
                self:RunScanCycle( gID, 1 )
            end
        end
    else
        logger:Info( "Scan requirements not met: Trying again in 1m" )
        zo_callLater(
            function()
                ITTsRosterBot:RequestHistory( gID, guildHistoryCategory )
            end,
            cooldown
        )
    end
end ]]

function ITTsRosterBot:QueueListener( guildId )
    ITTsRosterBotListener[ guildId ] = LH:CreateGuildHistoryListener( guildId, GUILD_HISTORY_GENERAL )
    if not ITTsRosterBotListener[ guildId ] then
        logger:Error( "Failed to create listener for guildId:", guildId )
        zo_callLater( function() ITTsRosterBot:QueueListener( guildId ) end, 1000 )
    else
        logger:Debug( "Listener created for guildId:", guildId )
        ITTsRosterBot:CreateListener( guildId )
    end
end

function ITTsRosterBot:CreateListener( guildId )
    local lastEvent = 1413120020
    if ITTsRosterBotData then
        if ITTsRosterBotData[ worldName ].lastEvent then
            lastEvent = ITTsRosterBotData[ worldName ].lastEvent
        end
    end
    logger:Debug( "LastEvent:", lastEvent )

    local setAfterTimeStamp = lastEvent - ZO_ONE_DAY_IN_SECONDS * 2
    ITTsRosterBotListener[ guildId ]:SetAfterEventTime( 0 )
    logger:Debug( "AfterTimeStamp:", setAfterTimeStamp )
    ITTsRosterBotListener[ guildId ]:SetNextEventCallback( function(
        eventType, eventId, timestampS, actingDisplayName, targetDisplayName, rankId

    )
        if eventType == GUILD_EVENT_GUILD_JOIN then
            self:SaveEvent( guildId, eventType, timestampS, actingDisplayName )
        end
    end )

    ITTsRosterBotListener[ guildId ]:Start()
end

function ITTsRosterBot.SetupListeners()
    local guilds = ITTsRosterBot:GetGuildMap()
    logger:Debug( "Guilds:", #guilds )
    for i = 1, #guilds do
        if not ITTsRosterBotListener[ guilds[ i ] ] then
            ITTsRosterBotListener[ guilds[ i ] ] = {}
        end
        ITTsRosterBot:QueueListener( guilds[ i ] )
        logger:Debug( "Listener queued for guildId:", guilds[ i ] )
    end
end

function ITTsRosterBot:SetupFullScan()
    local guilds = self:GetGuildMap()
    for i = 1, #guilds do
        local guildId = guilds[ i ]
        self:ScanEntireLH( guildId )
    end
end

function ITTsRosterBot:ScanEntireLH( guildId )
    ITTsRosterBotListener[ guildId ]:Stop()

    ITTsRosterBotListener[ guildId ]:SetAfterEventTime( 1413120020 )
    ITTsRosterBotListener[ guildId ]:SetEventCallback(
        function( eventType, eventId, timestampS, actingDisplayName, targetDisplayName, rankId )
            self:SaveEvent( guildId, eventType, timestampS, actingDisplayName, targetDisplayName, rankId )
        end
    )

    ITTsRosterBotListener[ guildId ]:Start()
end

function ITTsRosterBot:GetTimestampOfDayStart( offset )
    local timeObject = os.date( "*t", os.time() - (24 * offset) * 60 * 60 )
    local hours = timeObject.hour
    local mins = timeObject.min
    local secs = timeObject.sec
    local UTCMidnightOffset = (hours * SECONDS_IN_HOUR) + (mins * 60) + secs
    local recordTimestamp = os.time( timeObject )

    return recordTimestamp - UTCMidnightOffset
end

function ITTsRosterBot:GetTraderWeekEnd()
    local _, time, _ = GetGuildKioskCycleTimes()

    return time
end

function ITTsRosterBot:GetTraderWeekStart()
    local time = self:GetTraderWeekEnd()

    return time - SECONDS_IN_WEEK
end

-- --------------------
-- Attach Listeners
-- --------------------
EVENT_MANAGER:RegisterForEvent( ITTsRosterBot.name, EVENT_ADD_ON_LOADED, ITTsRosterBot_OnAddOnLoaded )
EVENT_MANAGER:RegisterForEvent( ITTsRosterBot.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated )
