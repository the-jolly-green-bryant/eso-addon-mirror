-- Add here literally whatever you wish!
-- Should be safe by design, but be wary

-- KEY should be a unique and human-readable name, it will be used in settings
-- VALUE should be a table with four keys: "Priority", "Name", "Available" and "Price"
-- "Priority" helps us to decide which provider to use as a fallback, lower = higher, no priority at all = used last
-- "Name" should be a proper name for the provider, we will show it to user to help him find and download new providers
-- "Available" should return true if the provider is available - a simple check of dependencies
-- "Price" should return a table with normalized price data (check out LWTPriceInfo.FormPriceData contents!)

-- Should be simple to add new providers even if you are not a full-fledged developer :)
-- They are checked for availability on start and added to LWTPriceInfo.ProviderNames
-- Have fun!

-- A friendly reminder: priority have nothing to do with "validity" of price providers
-- They are all a product of love and care, but we still need to sort them one way or another :)
-- My selected order is purely arbitrary!

LWTPriceInfo.Providers = {
	["TTC"] = {
		["Priority"] = 0,
		["Name"] = "Tamriel Trade Centre",
		["Available"] = function() return TamrielTradeCentrePrice ~= nil end,
		["Price"] = function(itemLink)
			local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
			if (priceInfo == nil) then return nil end
			return LWTPriceInfo.FormPriceData(priceInfo["Avg"], priceInfo["SuggestedPrice"],
			priceInfo["SaleAvg"], priceInfo["AmountCount"], priceInfo["SaleAmountCount"])
		end
	},
	
	["ESOHUB"] = {
		["Priority"] = 10,
		["Name"] = "ESO Hub",
		["Available"] = function() return LibEsoHubPrices ~= nil end,
		["Price"] = function(itemLink)
			local priceInfo = LibEsoHubPrices.GetItemPriceData(itemLink)
			if (priceInfo == nil) then return nil end
			if (priceInfo["averageListing"] == nil) then priceInfo["averageListing"] = 0 end
			if (priceInfo["averageSales"] == nil) then priceInfo["averageSales"] = 0 end
			return LWTPriceInfo.FormPriceData(priceInfo["averageListing"], (priceInfo["averageListing"] + priceInfo["averageSales"]) / 2,
				priceInfo["averageSales"], priceInfo["numberOfListings"], priceInfo["numberOfSales"])
		end
	},
	
	["MM"] = {
		["Priority"] = 20,
		["Name"] = "Master Merchant",
		["Available"] = function() return MasterMerchant ~= nil end,
		["Price"] = function(itemLink)
			local priceInfo = MasterMerchant:itemStats(itemLink, false)
			if (priceInfo == nil) then return nil end
			return LWTPriceInfo.FormPriceData(priceInfo["avgPrice"], priceInfo["avgPrice"],
				priceInfo["avgPrice"], priceInfo["numItems"], priceInfo["numItems"])
		end
	},
	
	["ATT"] = {
		["Priority"] = 30,
		["Name"] = "Arkadius Trade Tools",
		["Available"] = function() return ArkadiusTradeTools ~= nil and ArkadiusTradeToolsPurchasesData ~= nil end,
		["Price"] = function(itemLink)
			local twoWeeksTime = GetTimeStamp() - (ZO_ONE_DAY_IN_SECONDS * ArkadiusTradeToolsPurchasesData.settings.keepDataDays)
			local priceInfo = ArkadiusTradeTools.Modules.Sales:GetAveragePricePerItem(itemLink, twoWeeksTime)
			if (priceInfo == nil) then return nil end
			return LWTPriceInfo.FormPriceData(priceInfo, priceInfo, priceInfo, -1, -1)
		end
	},
	
	["NPC"] = {
		["Priority"] = math.maxinteger,
		["Name"] = "NPC",
		["Available"] = function() return true end,
		["Price"] = function(itemLink)
			local _, itemPrice = GetItemLinkInfo(itemLink)
			return LWTPriceInfo.FormPriceData(itemPrice, itemPrice, itemPrice, -1, -1)
		end
	}
}
