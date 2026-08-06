-- =============================================================================
-- LWTPriceInfoProviders.lua
-- -----------------------------------------------------------------------------
-- PROVIDER API REFERENCE for TamrielTrashCentre ("LWT Price Info")
--
-- This is the ONLY file you edit to teach the addon about a new price source
-- (Tamriel Trade Centre, Master Merchant, Arkadius Trade Tools, ESO Hub, an
-- NPC fallback, ...).  Add an entry to LWTPriceInfo.Providers and the addon
-- does the rest: availability is probed at startup, valid providers are listed
-- in the settings drop-down, and the chosen provider's Price() is queried
-- whenever an item row needs a price tag.
--
-- No Lua expertise required - copy a table, fill in four values, done.
-- Should be safe by design, but be wary (you are editing live code).
-- =============================================================================
--
-- PROVIDER REGISTRY
-- -----------------
-- LWTPriceInfo.Providers is a plain table keyed by a unique, human-readable
-- provider id (e.g. "TTC", "MM").  Each value is a provider definition table
-- with these four keys:
--
--   Key        Type      Required   Meaning
--   ---------- --------- ---------- ---------------------------------------------
--   Priority   number    optional   Fallback order. LOWER = preferred.
--                                  Omitted: treated as math.huge (last).
--                                  math.maxinteger / math.huge -> absolute last.
--                                  Tied priorities keep declaration order.
--   Name       string    yes        Display name shown to the user in settings
--                                  (so they can find & install the source).
--   Available  function  yes        () -> boolean. Cheap dependency probe, e.g.
--                                  `return MasterMerchant ~= nil`. Called once at
--                                  startup; must not error or loop.
--   Price      function  yes        (itemLink) -> priceData | nil.
--                                  itemLink is the ESO itemLink string.
--                                  Return nil when the source has no data for the
--                                  item. Otherwise return the normalized table
--                                  from LWTPriceInfo.FormPriceData (see below).
--                                  A non-nil table whose "Listed Avg" is 0 still
--                                  counts as "no price" - the item is skipped.
--
-- NORMALIZED PRICE TABLE (contract returned by Price)
-- ---------------------------------------------------
-- LWTPriceInfo.FormPriceData(listedAvg, suggested, saleAvg, amount, count)
-- -> table  (defined in LWTPriceInfoPrice.lua). Exact keys:
--
--   "Listed Avg"  number  Average listing price on the trading house.
--   "Suggested"   number  Provider's recommended sale price.
--   "Sale Avg"    number  Average historical sale price.
--   "Amount"      number  # of current listings (shown as [COUNT] for Listed).
--   "Count"       number  # of recorded sales (shown as [COUNT] for Sale/Sugg.).
--
-- nil arguments are coerced to 0. Use -1 for "Amount"/"Count" when a source
-- cannot report a volume (e.g. NPC, ATT in this file).
--
-- VALIDATION
-- ----------
-- LWTPriceInfo.ValidateProvider(name, data) -> boolean
--   Checks a single provider definition against the schema above: data is a
--   table; Name is a non-empty string; Priority (if present) is a number;
--   Available and Price are functions. On rejection it APPENDS a clear message
--   to LWTPriceInfo.errorLog and returns false, so the provider is skipped at
--   startup with a visible reason. You never call this yourself - SetupProviders()
--   runs it for every entry in LWTPriceInfo.Providers.
--
-- STARTUP FLOW (what happens to your provider)
-- --------------------------------------------
--   OnAddOnLoaded calls SetupProviders():
--     for each provider in LWTPriceInfo.Providers:
--       ValidateProvider(name, data)         -- malformed ones are rejected
--       available = data.Available()          -- probe dependencies
--       if available: collect name into LWTPriceInfo.ProviderNames
--     sort ProviderNames by Priority ascending
--   GetAvailablePriceProvider() returns the first available one, used as the
--   default / fallback when the user's saved selection is missing or offline.
--
-- A friendly reminder: Priority has nothing to do with "validity" of price
-- providers. They are all a product of love and care - the sort order is purely
-- arbitrary!
--
-- COMMON PROVIDER PATTERNS (copy, adapt, paste)
-- ---------------------------------------------
-- 1) Minimal provider with listing + sale volume (TTC / ESO Hub style):
--    ["MYPROV"] = {
--        ["Priority"] = 15,
--        ["Name"] = "My Price Source",
--        ["Available"] = function() return MyAddon ~= nil end,
--        ["Price"] = function(itemLink)
--            local info = MyAddon:GetPrice(itemLink)
--            if info == nil then return nil end
--            return LWTPriceInfo.FormPriceData(info.listed, info.suggested,
--                info.sold, info.numListings, info.numSales)
--        end,
--    },
--
-- 2) Provider that cannot report a volume (NPC / ATT style) - pass -1:
--    ["MYPROV"] = {
--        ["Priority"] = math.maxinteger,
--        ["Name"] = "My Fallback",
--        ["Available"] = function() return true end,
--        ["Price"] = function(itemLink)
--            local _, price = GetItemLinkInfo(itemLink)
--            return LWTPriceInfo.FormPriceData(price, price, price, -1, -1)
--        end,
--    },
--
-- 3) Single-number source (Master Merchant style) - reuse the value 3x:
--    ["MYPROV"] = {
--        ["Priority"] = 20,
--        ["Name"] = "Single Number Source",
--        ["Available"] = function() return MyAddon ~= nil end,
--        ["Price"] = function(itemLink)
--            local info = MyAddon:itemStats(itemLink, false)
--            if info == nil then return nil end
--            return LWTPriceInfo.FormPriceData(info.avg, info.avg, info.avg,
--                info.n, info.n)
--        end,
--    },
--
-- 4) What NOT to do (rejected by ValidateProvider at startup):
--    - Missing "Available" or "Price", or they are not functions.
--    - "Name" missing, non-string, or empty string.
--    - "Priority" present but not a number (e.g. a string).
--    Such a provider is skipped and its reason is printed to the error log.
--
-- Real, working examples ship in LWTPriceInfo.Providers below (TTC, ESOHUB, MM,
-- ATT, NPC). Have fun!

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

-- Validate a single provider definition against the required schema.
-- @param name  string   The provider id (the key under LWTPriceInfo.Providers).
-- @param data  table    The provider definition (Priority/Name/Available/Price).
-- @return boolean  true when structurally valid, false when rejected.
-- On rejection a clear, user-friendly message is appended to
-- LWTPriceInfo.errorLog so the user can see exactly what is wrong at startup.
-- You normally never call this yourself - SetupProviders() runs it for every
-- entry in LWTPriceInfo.Providers.
function LWTPriceInfo.ValidateProvider(name, data)
	local keyName = tostring(name)

	if (type(data) ~= "table") then
		LWTPriceInfo.errorLog = LWTPriceInfo.errorLog ..
			"Provider '" .. keyName .. "' is invalid: definition must be a table, got " .. type(data) .. ".\n"
		return false
	end

	if (data["Name"] == nil or type(data["Name"]) ~= "string" or data["Name"] == "") then
		LWTPriceInfo.errorLog = LWTPriceInfo.errorLog ..
			"Provider '" .. keyName .. "' is invalid: 'Name' must be a non-empty string.\n"
		return false
	end

	if (data["Priority"] ~= nil and type(data["Priority"]) ~= "number") then
		LWTPriceInfo.errorLog = LWTPriceInfo.errorLog ..
			"Provider '" .. keyName .. "' is invalid: 'Priority' must be a number.\n"
		return false
	end

	if (type(data["Available"]) ~= "function") then
		LWTPriceInfo.errorLog = LWTPriceInfo.errorLog ..
			"Provider '" .. keyName .. "' is invalid: 'Available' must be a function returning a boolean.\n"
		return false
	end

	if (type(data["Price"]) ~= "function") then
		LWTPriceInfo.errorLog = LWTPriceInfo.errorLog ..
			"Provider '" .. keyName .. "' is invalid: 'Price' must be a function receiving an itemLink.\n"
		return false
	end

	return true
end
