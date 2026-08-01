local Adapter = {}

Adapter.name = "MM3"

Adapter.settingsLabel = "Master Merchant 3.6"

Adapter.salesColumnKey = "MM_Sold"

Adapter.purchasesColumnKey = "MM_Bought"

function Adapter:Available()
    local condition = false

    if MasterMerchant and _G[ "LibGuildStore_Internal" ].LibHistoireListener then
        condition = true
    end

    return condition
end

local MM_TimeIndexOptions = {
    ITTsDonationBot:parse( "TIME_TODAY" ),
    ITTsDonationBot:parse( "TIME_YESTERDAY" ),
    ITTsDonationBot:parse( "TIME_THIS_WEEK" ),
    ITTsDonationBot:parse( "TIME_LAST_WEEK" ),
    ITTsDonationBot:parse( "TIME_PRIOR_WEEK" ),
    ITTsDonationBot:parse( "TIME_7_DAYS" ),
    ITTsDonationBot:parse( "TIME_10_DAYS" ),
    ITTsDonationBot:parse( "TIME_30_DAYS" )
}

function Adapter:Initialize()
end

-- Date Time Ranges for API from MM (provided by @Sharlikran)
local MM_DATERANGE_TODAY = 1
local MM_DATERANGE_YESTERDAY = 2
local MM_DATERANGE_THISWEEK = 3
local MM_DATERANGE_LASTWEEK = 4
local MM_DATERANGE_PRIORWEEK = 5
local MM_DATERANGE_7DAY = 6
local MM_DATERANGE_10DAY = 7
local MM_DATERANGE_30DAY = 8
local MM_DATERANGE_CUSTOM = 9

Adapter.DonationMapOptions = {}
Adapter.DonationMapOptions[ MM_DATERANGE_TODAY ] = 1
Adapter.DonationMapOptions[ MM_DATERANGE_YESTERDAY ] = 2
Adapter.DonationMapOptions[ MM_DATERANGE_THISWEEK ] = 4
Adapter.DonationMapOptions[ MM_DATERANGE_LASTWEEK ] = 5
Adapter.DonationMapOptions[ MM_DATERANGE_PRIORWEEK ] = 6
Adapter.DonationMapOptions[ MM_DATERANGE_7DAY ] = 7
Adapter.DonationMapOptions[ MM_DATERANGE_10DAY ] = 8
Adapter.DonationMapOptions[ MM_DATERANGE_30DAY ] = 10

function Adapter:GetTimeRangeOptions()
    return MM_TimeIndexOptions
end

function Adapter:RefreshAllGuildTotals(start, finish)
    local sales = {}
    local dateRange = ITTsRosterBot.db.timeFrameIndex

    for guildIndex = 1, GetNumGuilds() do
        local guildId = GetGuildId(guildIndex)
        local guildName = GetGuildName(guildId)

        if ITTsRosterBot:IsGuildEnabled(guildId) then
            sales[guildId] = MMGuild:GetGuildSalesTotal(guildName, dateRange)
        end
    end

    return sales
end

function Adapter:IsColumnCheckingEnabled()
    return MasterMerchant.systemSavedVariables.diplayGuildInfo and MasterMerchant.systemSavedVariables.diplaySalesInfo
end

function Adapter:SelectColumnTimeRange( timeRangeIndex )
    -- ATT does not have a total option, and caps at an optional 30 days
    -- if timeRangeIndex > 10 then timeRangeIndex = 10 end
    -- local selectedTimeRange = ArkadiusTradeTools.Modules.Sales.GuildRoster.timeSelect:GetItems()[timeRangeIndex]

    ITTsRosterBot.SalesAdapter:RefreshAllGuildTotals()

    MasterMerchant.UI_GuildTime.m_comboBox:SelectItemByIndex( timeRangeIndex )
end

function Adapter:GetSaleInformation( guildId, displayName, start, finish )
    local MasterMerchant = _G[ "LibGuildStore_Internal" ]

    if not MasterMerchant then
        return {
            sales = 0,
            purchases = 0
        }
    end

    local guildName = GUILD_ROSTER_MANAGER.guildName
    local dateRange = ITTsRosterBot.db.timeFrameIndex

    local purchases = mmUtils:GetGuildPurchases( guildName, displayName, dateRange )
    local sales = mmUtils:GetGuildSales( guildName, displayName, dateRange )

    return {
        sales = sales,
        purchases = purchases
    }
end

function Adapter:HideUI()
    if MasterMerchant.UI_GuildTime then
        MasterMerchant.UI_GuildTime:SetAlpha( 0 )
        MasterMerchant.UI_GuildTime:SetHidden( true )
    end
end

function Adapter:ShowUI()
    if MasterMerchant.UI_GuildTime then
        MasterMerchant.UI_GuildTime:SetAlpha( 1 )
        MasterMerchant.UI_GuildTime:SetHidden( false )
    end
end

----
-- Register Adapter
----
ITTsRosterBot.SalesAdapter:Register( Adapter )
