local SalesAdapter = ZO_CallbackObject:New()
ITTsRosterBot.SalesAdapter = SalesAdapter
SalesAdapter.adapters = {}

SalesAdapter.guildTotals = {}

function SalesAdapter:Register( context )
	self.adapters[ context.name ] = context
end

function SalesAdapter:Initialize()
	if ITTsRosterBot.db.settings.services.sales ~= "None" then
		if not self:Selected():Available() then
			local autoFindService = false

			for k, v in pairs( self.adapters ) do
				if self.adapters[ k ]:Available() and ITTsRosterBot.db.settings.services.sales ~= k and ITTsRosterBot.db.settings.services.sales ~= "None" then
					-- ITTsRosterBot.db.settings.services.sales = k
					autoFindService = true
					break
				end
			end

			if not autoFindService then
				ITTsRosterBot.db.settings.services.sales = "None"
			end
		end
	end

	if self:Selected() and self:Selected():Available() then
		if type( self:Selected()[ "Initialize" ] ) == "function" then self:Selected():Initialize() end
	end
end

function SalesAdapter:Selected()
	return SalesAdapter.adapters[ ITTsRosterBot.db.settings.services.sales ]
end

function SalesAdapter:GetTimeRangeOptions()
	local timeRangeOptions = false

	if ITTsRosterBot.db.settings.services.sales ~= "None" and type( self:Selected()[ "GetTimeRangeOptions" ] ) == "function" then
		timeRangeOptions = self:Selected():GetTimeRangeOptions()
	end

	return timeRangeOptions
end

function SalesAdapter:IsColumnCheckingEnabled()
	local condition = false

	if ITTsRosterBot.db.settings.services.sales ~= "None" and SalesAdapter:Selected():Available() then
		condition = SalesAdapter:Selected():IsColumnCheckingEnabled()
	end

	return condition
end

function SalesAdapter:RefreshAllGuildTotals( start, finish )
	if ITTsRosterBot.db.settings.services.sales == "None" or not SalesAdapter:Selected():Available() then return end

	if not start or not finish then
		start = ITTsRosterBot:GetTraderWeekStart()
		finish = ITTsRosterBot:GetTraderWeekEnd()
	end

	local totals = SalesAdapter:Selected():RefreshAllGuildTotals( start, finish )

	if next( totals ) == nil then
		SalesAdapter.guildTotals = {}
	else
		SalesAdapter.guildTotals = totals
	end
end

function SalesAdapter:SelectColumnTimeRange( timeRangeIndex )
	if not self:IsColumnCheckingEnabled() then return false end

	SalesAdapter:Selected():SelectColumnTimeRange( timeRangeIndex )
end

function SalesAdapter:GetGuildTotal( guildId )
	local guild = ITTsRosterBot.Utils:GetGuildDetails( { id = guildId } )
	local total = SalesAdapter.guildTotals[ guildId ]

	if next( SalesAdapter.guildTotals ) == nil then total = 0 end

	return total
end

function SalesAdapter:GetSaleInformation( guildId, displayName, start, finish )
	return SalesAdapter:Selected():GetSaleInformation( guildId, displayName, start, finish )
end

function SalesAdapter:DisplayUI( choice )
	if ITTsRosterBot.db.settings.services.sales == "None" or not SalesAdapter:Selected():Available() then return end

	if choice then
		self:Selected():ShowUI()
	else
		self:Selected():HideUI()
	end
end
