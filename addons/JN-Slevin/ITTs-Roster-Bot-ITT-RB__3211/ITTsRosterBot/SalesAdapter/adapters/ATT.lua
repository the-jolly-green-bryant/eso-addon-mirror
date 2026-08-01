local Adapter = {}

Adapter.name = "ATT"

Adapter.settingsLabel = "Arkadius\' Trade Tools"

Adapter.salesColumnKey = "ATT_Sales"

Adapter.purchasesColumnKey = "ATT_Purchases"

function Adapter:Available()
	local condition = false
	if ArkadiusTradeTools and ArkadiusTradeTools.Modules.Sales then
		condition = true
	end
	return condition
end

function Adapter:RefreshAllGuildTotals( start, finish )
	local data = ArkadiusTradeTools.Modules.Sales:GetStatistics( start, finish )
	local sales = {}

	for i = 1, #data do
		if data[ i ].displayName == "" and data[ i ].guildName ~= "" then
			local guild = ITTsRosterBot.Utils:GetGuildDetails( { name = data[ i ].guildName } )
			sales[ guild.id ] = data[ i ].salesVolume
		end
	end

	return sales
end

function Adapter:IsColumnCheckingEnabled()
	return ArkadiusTradeTools.Modules.Sales.GuildRoster:IsEnabled()
end

function Adapter:SelectColumnTimeRange( timeRangeIndex )
	-- ATT does not have a total option, and caps at an optional 30 days
	if timeRangeIndex > 10 then timeRangeIndex = 10 end

	local selectedTimeRange = ArkadiusTradeTools.Modules.Sales.GuildRoster.timeSelect:GetItems()[ timeRangeIndex ]

	ITTsRosterBot.SalesAdapter:RefreshAllGuildTotals( selectedTimeRange.NewerThanTimeStamp(), selectedTimeRange.OlderThanTimeStamp() )

	ArkadiusTradeTools.Modules.Sales.GuildRoster.timeSelect:SelectItemByIndex( timeRangeIndex )
end

function Adapter:GetSaleInformation( guildId, displayName, start, finish )
	local guild = ITTsRosterBot.Utils:GetGuildDetails( { id = guildId } )
	local purchases, sales = ArkadiusTradeTools.Modules.Sales:GetPurchasesAndSalesVolumes( guild.name, displayName, start, finish )

	return {
		sales = sales,
		purchases = purchases
	}
end

function Adapter:HideUI()
	if ZO_GuildRosterSalesDays then
		ZO_GuildRosterSalesDays:SetAlpha( 0 )
		ZO_GuildRosterSalesDays:SetHidden( true )
	end
end

function Adapter:ShowUI()
	if ZO_GuildRosterSalesDays then
		ZO_GuildRosterSalesDays:SetAlpha( 1 )
		ZO_GuildRosterSalesDays:SetHidden( false )
	end
end

----
-- Register Adapter
----
ITTsRosterBot.SalesAdapter:Register( Adapter )
