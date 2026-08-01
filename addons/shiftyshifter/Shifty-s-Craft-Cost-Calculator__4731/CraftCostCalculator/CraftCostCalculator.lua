-- Shifty's Craft Cost Calculator
-- Core bootstrap, public API, slash commands, and event wiring.

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.Name = "CraftCostCalculator"
CCC.DisplayName = "Shifty's Craft Cost Calculator"
CCC.Version = "1.1.0"
CCC.Author = "CraftCostCalculator"

local DEFAULTS = {
	priceMode = "Suggested", -- Suggested | Avg | SaleAvg | Min
	assumeMaxImprovementExpertise = true,
	showMissingPrices = true,
	printToChat = true,
	showWindow = true,
	contextMenu = true,
	useOwnedMaterials = true,
	checkWritKnowledge = true,
	includeGlyphCosts = true,
	shoppingList = {}, -- [itemIdString] = { itemId, itemLink, name, icon, quantity }
}

function CCC:GetDefaults()
	return DEFAULTS
end

function CCC:DebugWriteLine(message)
	if CCC.Settings and CCC.Settings.debug then
		d(string.format("[%s] %s", CCC.Name, tostring(message)))
	end
end

--- Public entry point used by UI / slash / context menu.
-- @param itemLink string
-- @return table|nil result, string|nil errorMessage
function CCC:CalculateCraftCost(itemLink)
	if not itemLink or itemLink == "" then
		return nil, "No item link provided."
	end

	local craftInfo, err = CCC.CraftResolver:Resolve(itemLink)
	if not craftInfo then
		-- When resolve fails entirely, still try knowledge-only for provisioning writs.
		return CCC:BuildKnowledgeOnlyWritResult(itemLink, err)
	end

	local materials, matErr = CCC.MaterialResolver:Resolve(craftInfo)
	if not materials then
		-- Provisioning: recipe/ingredient APIs may be unavailable for unknown recipes.
		-- Fall back to knowledge-only instead of failing the whole calculation.
		if craftInfo.isProvisioning then
			local knowledgeOnly = CCC.KnowledgeChecker and CCC.KnowledgeChecker:Evaluate(craftInfo)
			if knowledgeOnly and knowledgeOnly.hasRequirements then
				local result = CCC:MakeKnowledgeOnlyResult(itemLink, craftInfo, knowledgeOnly)
				result.ingredientWarning = matErr
				return result, nil
			end
		end
		return nil, matErr or "Unable to resolve materials."
	end

	local priced = CCC.CalculationEngine:Calculate(itemLink, craftInfo, materials)
	if craftInfo.glyphWarning then
		priced.glyphWarning = craftInfo.glyphWarning
	end
	if CCC.KnowledgeChecker and craftInfo.isMasterWrit then
		priced.knowledge = CCC.KnowledgeChecker:Evaluate(craftInfo)
	end
	return priced, nil
end

--- Build a knowledge-only Master Writ result (no material lines).
function CCC:MakeKnowledgeOnlyResult(itemLink, craftInfo, knowledge)
	craftInfo = craftInfo or {}
	craftInfo.isMasterWrit = true
	craftInfo.knowledgeOnly = true
	return {
		itemLink = itemLink,
		itemName = CCC.Utilities:GetItemName(itemLink),
		craftInfo = craftInfo,
		lines = {},
		total = 0,
		fullTotal = 0,
		complete = true,
		pricedCount = 0,
		missingCount = 0,
		fullyOwnedCount = 0,
		useOwnedMaterials = CCC.OwnedMaterials and CCC.OwnedMaterials:IsEnabled(),
		resultMarketPrice = CCC.PriceProvider and CCC.PriceProvider:GetUnitPrice(itemLink) or nil,
		ttcAvailable = CCC.TTCIntegration and CCC.TTCIntegration:IsAvailable(),
		knowledge = knowledge,
		knowledgeOnly = true,
	}
end

--- When CraftResolver cannot resolve the link, try provisioning knowledge-only.
function CCC:BuildKnowledgeOnlyWritResult(itemLink, err)
	local knowledgeOnly = CCC.KnowledgeChecker and CCC.KnowledgeChecker:EvaluateWritLink(itemLink)
	if knowledgeOnly and knowledgeOnly.hasRequirements then
		return CCC:MakeKnowledgeOnlyResult(itemLink, {
			isProvisioning = true,
		}, knowledgeOnly), nil
	end
	return nil, err or "Unable to resolve crafting requirements."
end

--- Upgrade cost from a chosen quality up to Legendary.
-- @param itemLink string
-- @param fromQuality number|nil
-- @param toQuality number|nil
-- @return table|nil result, string|nil errorMessage
function CCC:CalculateUpgradeCost(itemLink, fromQuality, toQuality)
	return CCC.UpgradeCostCalculator:CalculateForItem(itemLink, fromQuality, toQuality)
end

--- Copy legacy non-server-scoped Default profile into the current world once.
-- Pre-1.1.0 SavedVariables used profile "Default", so NA/EU/PTS overwrote each other.
local function migrateLegacyDefaultProfile(savedVars)
	local raw = _G["CraftCostCalculatorVars"]
	if type(raw) ~= "table" or type(savedVars) ~= "table" then
		return
	end
	if savedVars._serverSplitMigrated then
		return
	end

	local displayName = GetDisplayName()
	local legacy = raw.Default and raw.Default[displayName] and raw.Default[displayName]["$AccountWide"]
	if type(legacy) ~= "table" then
		savedVars._serverSplitMigrated = true
		return
	end

	local worldList = savedVars.shoppingList
	local worldListEmpty = type(worldList) ~= "table" or next(worldList) == nil
	if worldListEmpty then
		for key, defaultValue in pairs(DEFAULTS) do
			local legacyValue = legacy[key]
			if legacyValue ~= nil then
				if type(defaultValue) == "table" then
					savedVars[key] = ZO_DeepTableCopy(legacyValue)
				else
					savedVars[key] = legacyValue
				end
			end
		end
	end

	savedVars._serverSplitMigrated = true
	raw.Default = nil
end

function CCC:InitSavedVars()
	local worldName = GetWorldName()
	-- Profile = server (NA Megaserver / EU Megaserver / PTS) so settings & shopping lists stay separate.
	CCC.SavedVars = ZO_SavedVars:NewAccountWide("CraftCostCalculatorVars", 2, nil, DEFAULTS, worldName)
	migrateLegacyDefaultProfile(CCC.SavedVars)
	CCC.Settings = CCC.SavedVars
end

function CCC:OnAddOnLoaded(event, addonName)
	if addonName ~= CCC.Name then
		return
	end

	EVENT_MANAGER:UnregisterForEvent(CCC.Name, EVENT_ADD_ON_LOADED)

	CCC:InitSavedVars()
	CCC.Utilities:Init(CCC)
	CCC.TTCIntegration:Init(CCC)
	CCC.PriceProvider:Init(CCC)
	CCC.WritResolver:Init(CCC)
	CCC.CraftResolver:Init(CCC)
	CCC.GlyphResolver:Init(CCC)
	CCC.MaterialResolver:Init(CCC)
	CCC.OwnedMaterials:Init(CCC)
	CCC.CalculationEngine:Init(CCC)
	CCC.KnowledgeChecker:Init(CCC)
	CCC.UpgradeCostCalculator:Init(CCC)
	CCC.ShoppingList:Init(CCC)
	CCC.MythicSets:Init(CCC)
	CCC.BuildExport:Init(CCC)
	CCC.BuildPieceResolver:Init(CCC)
	CCC.BuildCostCalculator:Init(CCC)
	CCC.MaterialRepository:Init(CCC)
	CCC.MaterialIndex:Init(CCC)
	CCC.MaterialSearchService:Init(CCC)
	CCC.SettingsMenu:Init(CCC)
	CCC.UI:Init(CCC)
	CCC.ShoppingListUI:Init(CCC)
	CCC.MaterialSearchWindow:Init(CCC)
	CCC.UpgradeCostUI:Init(CCC)
	CCC.BuildCostUI:Init(CCC)

	SLASH_COMMANDS["/ccc"] = function(args)
		CCC:HandleSlash(args)
	end
	SLASH_COMMANDS["/craftcost"] = SLASH_COMMANDS["/ccc"]

	d(string.format("%s %s loaded. Use /ccc <item link>, /ccc calculatebuild, or right-click gear/Master Writs.", CCC.DisplayName, CCC.Version))
end

function CCC:HandleSlash(args)
	args = zo_strtrim(args or "")
	local lower = zo_strlower(args)

	if args == "" or lower == "help" then
		d(string.format("|cC5C29E%s|r", CCC.DisplayName))
		d("  /ccc <item link>     – calculate craft cost (gear or Master Writ)")
		d("  /ccc last            – recalculate last item")
		d("  /ccc window          – toggle results window")
		d("  /ccc shoppinglist    – open shopping list")
		d("  /ccc upgrade         – toggle upgrade cost window")
		d("  /ccc calculatebuild  – open Build Cost Calculator")
		return
	end

	if lower == "window" then
		CCC.UI:Toggle()
		return
	end

	if lower == "shoppinglist" or lower == "shopping" or lower == "sl" then
		CCC.ShoppingListUI:Show()
		return
	end

	if lower == "upgrade" or lower == "upgradewindow" then
		if CCC.UpgradeCostUI then
			CCC.UpgradeCostUI:Toggle()
		end
		return
	end

	if lower == "calculatebuild" or lower == "build" or lower == "buildcost" then
		if CCC.BuildCostUI then
			CCC.BuildCostUI:Show()
		end
		return
	end

	if lower == "last" then
		if not CCC.lastItemLink then
			d("No previous item. Link an item with /ccc <item link>.")
			return
		end
		CCC:ShowCostForLink(CCC.lastItemLink)
		return
	end

	-- Extract first item link from args (may include surrounding text)
	local link = args:match("(|H.-|h.-|h)")
	if not link then
		-- Allow pasted raw text that still contains a partial link
		if TamrielTradeCentre and TamrielTradeCentre.IsItemLink and TamrielTradeCentre:IsItemLink(args) then
			link = args
		else
			d("Please provide a valid item link. Example: /ccc [Item Name]")
			return
		end
	end

	CCC:ShowCostForLink(link)
end

function CCC:ShowCostForLink(itemLink, opts)
	opts = opts or {}
	CCC.lastItemLink = itemLink
	local result, err = CCC:CalculateCraftCost(itemLink)
	if not result then
		if not opts.silent then
			d(string.format("|cFF6666%s:|r %s", CCC.DisplayName, err or "Unknown error"))
		end
		return
	end

	-- Avoid chat spam on automatic inventory-driven refreshes
	if CCC.Settings.printToChat and not opts.silent then
		CCC.UI:PrintResultToChat(result)
	end
	if CCC.Settings.showWindow or opts.forceWindow then
		CCC.UI:ShowResult(result)
	end
end

--- Recompute open result windows after inventory/bank changes.
function CCC:RefreshDisplayedResult()
	local craftVisible = CCC.UI and CCC.UI:IsVisible()
	local upgradeVisible = CCC.UpgradeCostUI and CCC.UpgradeCostUI:IsVisible()
	local buildVisible = CCC.BuildCostUI and CCC.BuildCostUI:IsVisible()

	if craftVisible and CCC.lastItemLink then
		CCC:ShowCostForLink(CCC.lastItemLink, {silent = true, forceWindow = true})
	end
	if upgradeVisible then
		CCC.UpgradeCostUI:Refresh()
	end
	if buildVisible and CCC.BuildCostCalculator and CCC.BuildCostCalculator:HasBuild() then
		CCC.BuildCostCalculator:RecalculateAll()
	end
end

EVENT_MANAGER:RegisterForEvent(CCC.Name, EVENT_ADD_ON_LOADED, function(event, addonName)
	CCC:OnAddOnLoaded(event, addonName)
end)
