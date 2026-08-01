
-- generates the pricing content
local function GeneratePricingContent(itemLink, stackCount)
	local pricing = TamrielTradeCentrePrice:GetPriceInfo(itemLink)

	-- normalise the data
	pricing = pricing or {}
	pricing.SuggestedPrice = tonumber(pricing.SuggestedPrice) or 0
	pricing.EntryCount = tonumber(pricing.EntryCount) or 0
	pricing.Avg = tonumber(pricing.Avg) or 0
	pricing.SaleAvg = tonumber(pricing.SaleAvg) or 0
	pricing.SaleEntryCount = tonumber(pricing.SaleEntryCount) or 0

	-- Create the content packet
	local content = {
		unit = {
			hasData = pricing.SuggestedPrice > 0,
			low = pricing.SuggestedPrice,
			high = pricing.SuggestedPrice * PadMerchant.Settings.SuggestionMultiplier,
			statement = PadMerchant.Strings.NO_SUGGESTIONS_AVAILABLE
		},
		stack = {
			hasData = pricing.SuggestedPrice > 0 and stackCount > 1,
			count = stackCount,
			low = pricing.SuggestedPrice * stackCount,
			high = (pricing.SuggestedPrice * PadMerchant.Settings.SuggestionMultiplier) * stackCount,
			statement = ""
		},
		listings = {
			hasData = pricing.EntryCount > 0 and pricing.Avg > 0,
			avg = pricing.Avg,
			count = pricing.EntryCount,
			statement = PadMerchant.Strings.NO_LISTINGS_SEEN
		},
		sales = {
			hasData = pricing.SaleEntryCount > 0 and pricing.SaleAvg > 0,
			count = pricing.SaleEntryCount,
			avg = pricing.SaleAvg,
			statement = PadMerchant.Strings.NO_SALES_SEEN
		}
	}

	-- Add unit and stack suggestions
	if content.unit.hasData then
		local unitMin = PadMerchant.Utils.FormatNumber(content.unit.low, true)
		local unitMax = PadMerchant.Utils.FormatNumber(content.unit.high, true)

		content.unit.statement = unitMin .. PadMerchant.Strings.TO .. unitMax

		local stackMin = PadMerchant.Utils.FormatNumber(content.stack.low, true)
		local stackdMax = PadMerchant.Utils.FormatNumber(content.stack.high, true)

		content.stack.statement = stackMin .. PadMerchant.Strings.TO .. stackdMax
	end

	-- Add listing statement
	if content.listings.hasData then
		local listings = PadMerchant.Utils.FormatNumber(content.listings.count)
		local listingsAvg = PadMerchant.Utils.FormatNumber(content.listings.avg, true)

		content.listings.statement = listings  .. PadMerchant.Strings.LISTINGS_AVG .. listingsAvg
	end

	-- Add sales statement
	if content.sales.hasData then
		local sales = PadMerchant.Utils.FormatNumber(content.sales.count)
		local saleAvg = PadMerchant.Utils.FormatNumber(content.sales.avg, true)

		content.sales.statement = sales .. PadMerchant.Strings.SALES_AVG .. saleAvg
	end

	return content
end

-- Adds the pricing content to the tooltip provided
local function LayoutPricingContent(tooltip, content)

	-- Additional specific style params
	local styles = {
		baseStyle = tooltip:GetStyle("bodySection"),
		header = {
			fontColorField = PadMerchant.Colors.OFF_WHITE,
			fontFace = PadMerchant.FontFaces.BOLD,
			fontSize = PadMerchant.FontSizes.SMALL,
			fontStyle = PadMerchant.FontStyles.SOFT_SHADOW_THICK,
			height = 24,
			uppercase = true
		},
		infoLine = {
			fontColorField = PadMerchant.Colors.WHITE,
			fontFace = PadMerchant.FontFaces.LIGHT,
			fontSize = PadMerchant.FontSizes.LARGE,
			height = 12
		},
		suggestion = {
			fontColorField = PadMerchant.Colors.WHITE,
			fontFace = PadMerchant.FontFaces.LIGHT,
			fontSize = PadMerchant.FontSizes.XLARGE
		},
		suggestionHeader = {
			fontColorField = PadMerchant.Colors.GREY,
			fontFace = PadMerchant.FontFaces.MEDIUM,
			fontSize = PadMerchant.FontSizes.TINY,
			height = 6,
			uppercase = true
		}
	}

	-- We always show our header if we made it this far
	tooltip:AddLine(PadMerchant.Strings.SUGGESTED_PRICING, styles.header, styles.baseStyle)

	-- Show our suggestion only if we have one
	if content.unit.hasData then
		if content.stack.hasData then
			tooltip:AddLine(PadMerchant.Strings.THIS_STACK_OF .. content.stack.count, styles.suggestionHeader, styles.baseStyle)
			tooltip:AddLine(content.stack.statement, styles.suggestion, styles.baseStyle)
		end

		tooltip:AddLine(PadMerchant.Strings.PER_UNIT, styles.suggestionHeader, styles.baseStyle)
		tooltip:AddLine(content.unit.statement, styles.suggestion, styles.baseStyle)
	else
		tooltip:AddLine(content.unit.statement, styles.suggestion, styles.baseStyle)
	end

	tooltip:AddLine(content.sales.statement, styles.infoLine, styles.baseStyle)
	tooltip:AddLine(content.listings.statement, styles.infoLine, styles.baseStyle)

	-- Adds a bit of breathing space below our content without messing with padding, 
	-- etc. Fixes "Seller Name" spacing when in the tradehouse for instance.
	tooltip:AddLine("", styles.infoLine, styles.baseStyle)
end

-- Integrates with the given tooltip panel.
local function ExtendToolTipMethod(tooltip, method)
	local original = tooltip[method]

	local function Wrapper(self, ...)

		-- Run the original method and grab it's return.
		local returnResult = original(self, ...)

		-- Get the item Link and Name without having to list all the
		-- uneeded params. Note, args does not contain any named params.
		local args = {...} or {}
		local itemLink = args[1]
		local itemName = args[6]

		-- Only run our custom code if we have a itemLink. BWe are generically wrapping all calls to LayoutItem, so we 
		-- need to handle cases when what is shown in any of the tooltip panels is not an item (LevelUp Rewards for instance).
		if itemLink ~= nil or itemLink ~= "" then

			-- normalise so match doesn't crash on match.
			if itemName == nil then
				itemName = ""
			end

			-- Having tested a bunch of ways to get the stack count for the itemLink in question, it seems
			-- it is easiest to test if it is in the name (eg. "Some Item (43)") or not. The beauty of doing
			-- it this way is the number is always contextually correct for the item in question. If we queried
			-- the counts we would have to test what context we are in for the tooltip to know which total to use.
			local stackCount = tonumber(string.match(itemName,"%((%d+)%)")) or 1

			-- Add our content now that we know we are dealing with an item.
			local content = GeneratePricingContent(itemLink, stackCount)
			LayoutPricingContent(self, content)
		end

		-- be good citizings and return the original's methods return values (if any)
		return returnResult
	end

	-- add our wrapper method in place of the original method. Our wrapper will be called every time
	-- that ToolTip.LayoutItem is called on the supplied tooltip.
	tooltip[method] = Wrapper
end

-- Public method to run the tooltip integration. The integration simply overrides a method named
-- LayoutItem on the two panels of the Gamepad Mode UI that act as ToolTips.
function PadMerchant.ToolTips.Setup()

	-- In Gamepad Mode there are really only two locations we care about. These are the left
	-- panel and right panels. In all cases for Gamepad Mode, from TradeHouse to Bag and Bank
	-- an item's detail will be presented as a left or right panel, that acts as the tooltip.
	local tooltips = {
		left = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP),
		right = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP)
	}

	-- We only care about the lowest level LayoutItem method on each panel described above. In the ESOUI code
	-- all of the Layout* methods ultimately call down to this base function. This lets us handle any particular
	-- type of tooltip without needing to override all the differing Layout* functions.
	ExtendToolTipMethod(tooltips.left, "LayoutItem")
	ExtendToolTipMethod(tooltips.right, "LayoutItem")

	-- Store a reference to the tooltips in case we need to do something with them later.
	PadMerchant.ToolTips = tooltips
end