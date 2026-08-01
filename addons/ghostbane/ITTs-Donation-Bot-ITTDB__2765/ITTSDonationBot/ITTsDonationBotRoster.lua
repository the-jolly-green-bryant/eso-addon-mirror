local Roster = {}
ITTsDonationBot.Roster = Roster

local GUILD_ROSTER_MANAGER_SetupEntry
local GUILD_ROSTER_MANAGER_BuildMasterList
local queryTotal = 0
local validRowCount = 0

local SECONDS_IN_HOUR = 60 * 60
local SECONDS_IN_DAY = SECONDS_IN_HOUR * 24
local SECONDS_IN_WEEK = SECONDS_IN_DAY * 7

local worldName = GetWorldName()

local function DonationsTooltip_GetInfo( control, displayName )
    local data = ITTsDonationBot:GetTooltipCache( GUILD_ROSTER_MANAGER.guildId, displayName )

    control:SetDimensionConstraints( 370, -1, 680, -1 )

    if data.total and data.total > 0 then
        for i = 1, 5 do
            local text = control:GetNamedChild( "Log" .. i )
            text:SetWidth( 230 )
            text:SetFont( "$(CHAT_FONT)|18|soft-shadow-thick" )

            if data.log[ i ].none then
                text:SetText( "|c818285" .. ITTsDonationBot:parse( "NONE" ) )
            else
                text:SetText(
                    "|cF49B22" ..
                    data.log[ i ].time ..
                    " :  |CFFFFFF" ..
                    zo_strformat( "<<1>>", ZO_LocalizeDecimalNumber( data.log[ i ].amount ) ) .. " |t14:14:EsoUI/Art/currency/currency_gold.dds|t"
                )
            end
        end

        local colWidth = 220

        if GetCVar( "language.2" ) == "ru" then
            colWidth = 280
        end

        if GetCVar( "language.2" ) == "de" then
            colWidth = 260
        end
        if GetCVar( "language.2" ) == "fr" then
            colWidth = 240
        end

        -- TO-DO: Refacor this into a loop

        local total = control:GetNamedChild( "Today" )
        total:SetWidth( colWidth )
        total:SetFont( "ZoFontGameBold" )
        total:SetText(
            "|C11d936" ..
            ITTsDonationBot:parse( "TIME_TODAY" ) ..
            ": " .. "|CFFFFFF" .. zo_strformat( "<<1>>", ZO_LocalizeDecimalNumber( data.today ) ) .. " |t14:14:EsoUI/Art/currency/currency_gold.dds|t "
        )

        local total2 = control:GetNamedChild( "ThisWeek" )
        total2:SetWidth( colWidth )
        total2:SetFont( "ZoFontGameBold" )
        total2:SetText(
            "|C11d936" ..
            ITTsDonationBot:parse( "TIME_THIS_WEEK" ) ..
            ": " .. "|CFFFFFF" .. zo_strformat( "<<1>>", ZO_LocalizeDecimalNumber( data.thisWeek ) ) ..
            " |t14:14:EsoUI/Art/currency/currency_gold.dds|t "
        )

        local total3 = control:GetNamedChild( "LastWeek" )
        total3:SetWidth( colWidth )
        total3:SetFont( "ZoFontGameBold" )
        total3:SetText(
            "|C11d936" ..
            ITTsDonationBot:parse( "TIME_LAST_WEEK" ) ..
            ": " .. "|CFFFFFF" .. zo_strformat( "<<1>>", ZO_LocalizeDecimalNumber( data.lastWeek ) ) ..
            " |t14:14:EsoUI/Art/currency/currency_gold.dds|t "
        )

        local total4 = control:GetNamedChild( "PriorWeek" )
        total4:SetWidth( colWidth )
        total4:SetFont( "ZoFontGameBold" )
        total4:SetText(
            "|C11d936" ..
            ITTsDonationBot:parse( "TIME_PRIOR_WEEK" ) ..
            ": " .. "|CFFFFFF" .. zo_strformat( "<<1>>", ZO_LocalizeDecimalNumber( data.priorWeek ) ) ..
            " |t14:14:EsoUI/Art/currency/currency_gold.dds|t "
        )

        local total5 = control:GetNamedChild( "Total" )
        total5:SetWidth( colWidth )
        total5:SetFont( "ZoFontGameBold" )
        total5:SetText(
            "|C11d936" ..
            ITTsDonationBot:parse( "TIME_TOTAL" ) ..
            ": " .. "|CFFFFFF" .. zo_strformat( "<<1>>", ZO_LocalizeDecimalNumber( data.total ) ) .. " |t15:15:EsoUI/Art/currency/currency_gold.dds|t "
        )
    end
end

Roster.endRowName = nil

local function UpdateQueryTotal()
    local donationsTotal = ZO_GuildRoster:GetNamedChild( "DonationsTotal" )
    local donationsSelectionTotal = ZO_GuildRoster:GetNamedChild( "DonationsSelectionTotal" )
    local membersTotal = GetNumGuildMembers( GUILD_ROSTER_MANAGER.guildId )
    local selectedPercentage = math.floor( 100 / membersTotal * validRowCount )
    local color = "|cFFFFFF"

    if validRowCount > 0 then
        color = "|cffa600"
    end

    donationsSelectionTotal:SetText( "( " .. color .. validRowCount .. " |cFFFFFF/ " .. membersTotal .. " ) " .. color .. selectedPercentage .. "%" )
    donationsTotal:SetText( zo_strformat( "<<1>>", ZO_LocalizeDecimalNumber( queryTotal ) ) .. " |t14:14:EsoUI/Art/currency/currency_gold.dds|t" )
end

function Roster:Enable( enable )
    local guildRoster = ZO_GuildRoster
    local donationsDays = CreateControlFromVirtual( guildRoster:GetName() .. "DonationsDays", guildRoster, "ZO_ComboBox" )
    local donationsTotal = CreateControlFromVirtual( guildRoster:GetName() .. "DonationsTotal", donationsDays, "ZO_KeyboardGuildRosterRowLabel" )
    local donationsSelectionTotal = CreateControlFromVirtual( guildRoster:GetName() .. "DonationsSelectionTotal", donationsTotal,
                                                              "ZO_KeyboardGuildRosterRowLabel" )

    donationsDays:SetHidden( true )
    donationsTotal:SetHidden( true )
    donationsSelectionTotal:SetHidden( true )

    -- Default is Today
    self:CreateReportUI(
        donationsDays,
        function( ... )
            ITTsDonationBot.db.settings[ worldName ].querySelection = self.queryReportMode:GetSelectedItemData().index
            LibGuildRoster:Refresh()
        end
    )

    local donationsColumn =
        LibGuildRoster:AddColumn(
            {
                key = "ITT_Donations",
                width = 110,
                header = {
                    title = ITTsDonationBot:parse( "HEADER" ),
                    align = TEXT_ALIGN_RIGHT
                },
                priority = 1,
                row = {
                    align = TEXT_ALIGN_RIGHT,
                    data = function( guildId, data, index )
                        return Roster:GetRowValues( guildId, data.displayName )
                    end,
                    format = function( value )
                        return zo_strformat( "<<1>>", ZO_LocalizeDecimalNumber( tonumber( value ) or 0 ) ) ..
                            " |t15:15:EsoUI/Art/currency/currency_gold.dds|t"
                    end,
                    mouseEnabled = function( guildId, data, value )
                        return ITTsDonationBot:HasTooltipInfo( guildId, data.displayName )
                    end,
                    OnMouseEnter = function( guildId, data, control )
                        InitializeTooltip( DonationsTooltip )
                        DonationsTooltip:SetDimensionConstraints( 380, -1, 440, -1 )
                        DonationsTooltip:ClearAnchors()
                        DonationsTooltip:SetAnchor( BOTTOMRIGHT, control, TOPLEFT, 100, 0 )
                        DonationsTooltip_GetInfo( DonationsTooltip, data.displayName )
                    end,
                    OnMouseExit = function( guildId, data, control )
                        ClearTooltip( DonationsTooltip )
                    end
                },
                guildFilter = ITTsDonationBot:GetGuildMap(),
                beforeList = function()
                    queryTotal = 0
                    validRowCount = 0
                end,
                afterList = function()
                    UpdateQueryTotal()
                end
            }
        )

    LibGuildRoster:OnRosterReady(
        function()
            donationsDays:SetDimensions( 145, 32 )
            donationsDays:SetAnchor( TOPLEFT, donationsColumn:GetHeader(), BOTTOMLEFT, 0, ZO_GuildRosterListContents:GetHeight() )

            donationsTotal:SetFont( "$(CHAT_FONT)|18|soft-shadow-thick" )
            donationsTotal:SetText( "0" )
            donationsTotal:SetDimensions( donationsDays:GetWidth(), donationsDays:GetHeight() )
            donationsTotal:SetHorizontalAlignment( 2 )

            if PerfectPixel ~= nil then
                donationsTotal:SetAnchor( RIGHT, ZO_GuildSharedInfo, LEFT, -10, 20 )
            else
                donationsTotal:SetAnchor( TOPRIGHT, donationsDays, BOTTOMRIGHT, 0, 5 )
            end
            donationsSelectionTotal:SetFont( "$(CHAT_FONT)|16|soft-shadow-thick" )
            donationsSelectionTotal:SetText( "0" )
            donationsSelectionTotal:SetDimensions( donationsTotal:GetWidth(), donationsTotal:GetHeight() )
            donationsSelectionTotal:SetHorizontalAlignment( 2 )
            donationsSelectionTotal:SetAnchor( TOPRIGHT, donationsTotal, BOTTOMRIGHT, 0, -2 )

            UpdateQueryTotal()

            SCENE_MANAGER.scenes.guildRoster:RegisterCallback(
                "StateChange",
                function( oldState, newState )
                    -- [STATES]: hiding, showing, shown, hidden
                    local condition = true

                    if (newState == "showing" or newState == "shown") and ITTsDonationBot:IsGuildEnabled( GUILD_ROSTER_MANAGER.guildId ) then
                        condition = false
                    end

                    if ITTsRosterBot then
                        condition = true
                    end

                    donationsDays:SetHidden( condition )
                    donationsTotal:SetHidden( condition )
                    donationsSelectionTotal:SetHidden( condition )
                end
            )

            ZO_PreHook(
                GUILD_ROSTER_MANAGER,
                "OnGuildIdChanged",
                function( self )
                    local condition = true

                    if SCENE_MANAGER.currentScene.name == "guildRoster" and ITTsDonationBot:IsGuildEnabled( GUILD_ROSTER_MANAGER.guildId ) then
                        condition = false
                    end

                    if ITTsRosterBot then
                        condition = true
                    end

                    donationsDays:SetHidden( condition )
                    donationsTotal:SetHidden( condition )
                    donationsSelectionTotal:SetHidden( condition )
                end
            )

            if SCENE_MANAGER.currentScene.name == "guildRoster" and ITTsDonationBot:IsGuildEnabled( GUILD_ROSTER_MANAGER.guildId ) then
                donationsDays:SetHidden( false )
                donationsTotal:SetHidden( false )
                donationsSelectionTotal:SetHidden( false )
            end
        end
    )
end

function Roster:CreateReportUI( control, callback )
    self.queryReportMode = ZO_ComboBox_ObjectFromContainer( control )
    self.queryReportMode:SetSortsItems( false )

    for k, v in ipairs( ITTsDonationBot.reportQueries ) do
        self.queryReportMode:AddItem(
            {
                index = k,
                name = v.name,
                range = v.range,
                callback = callback
            }
        )
    end

    self.queryReportMode:SelectItemByIndex( ITTsDonationBot.db.settings[ worldName ].querySelection )
end

function Roster:GetRowValues( guildId, displayName )
    local query = self.queryReportMode:GetSelectedItemData()
    local start, finish = query.range()
    local value = ITTsDonationBot:QueryValues( guildId, displayName, start, finish )

    queryTotal = value + queryTotal

    if value > 0 then
        validRowCount = validRowCount + 1
    end

    return value
end
