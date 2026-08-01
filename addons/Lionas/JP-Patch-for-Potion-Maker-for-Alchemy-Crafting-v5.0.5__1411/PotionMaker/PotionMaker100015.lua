------------------------------------------
--            Potion Maker              --
--      by facit & Khrill & votan       --
------------------------------------------

PotMaker = {
	name = "PotionMaker",
	version = "5.0.5 (ESO 2.4)",
	ResultControls = { },
	MustFilterControls = { },
	MustNotFilterControls = { },
	SolventFilterControls = { },
	ReagentFilterControls = { },
	onlyReagentFilter = nil,
	potion2ReagentFilter = nil,
	questPotionsOnly = false,
	favoritesOnly = false,
	doablePotions = { },
	atAlchemyStation = false,
	resultListShown = false,
	selected = nil,
	samePotions = { },
	sameTraits = { },
	dataDefaults =
	{
		resultsWindowX = 0,
		resultsWindowY = 0,
		mainWindowX = 0,
		mainWindowY = 0,
		enableButton = true,
		showAsDefault = true,
		useUnknown = true,
		useMissing = false,
		fakeThirdSlot = false,
		training = false,
		XPMode = true,
		reagentStackOrder = false,
		showInFavorites = "REAGENTS",
		filterFavoriteByTraits = true,
		filterFavoriteByReagents = false,
		filterFavoriteBySolvents = true,
		showMainMenuItem = true,
		useItemSaver = true,
		lastUsedTab = "PotionMaker",
		suppressNewTraitDialog = false,
	},
	traitColor =
	{
		["-"] = ZO_ColorDef:New("FFFF7F50"),
		["/"] = ZO_ColorDef:New("FFFF0000"),
		["+"] = ZO_ColorDef:New("FFCBFF8C"),
		["*"] = ZO_ColorDef:New("FF00FF00"),
	},
	traitControlNames =
	{
		[1] = "Trait1",
		[2] = "Trait2",
		[3] = "Trait3",
		[4] = "Trait4",
	},
	reagentControlNames =
	{
		[1] = "Reagent1",
		[2] = "Reagent2",
		[3] = "Reagent3",
		[4] = "Reagent4",
	},
	favoriteColor =
	{
		["REAGENTS"] = ZO_ColorDef:New("FFE900"),
		["POTION"] = ZO_ColorDef:New("FF6A00"),
		["TRAITS"] = ZO_TOOLTIP_DEFAULT_COLOR,
	},
	descriptorPotion = "PotionMaker",
	descriptorPoison = "PoisonMaker",
	allReagents = "",
	-- hash table key reservation. Avoid reallocation
	badTraitMatches = "",
	oppositeTraits = "",
	resultsMaxIndex = 0,
	BagMode = true,
	BankMode = true,
}
local PotMaker = PotMaker

local pageSize = 10

local TEXTURE_REAGENTUNKNOWN = "PotionMaker/art/reagent.dds"
local TEXTURE_TRAITUNKNOWN = "/esoui/art/progression/lock.dds"
local TEXTURE_HIGHLIGHT = "PotionMaker/art/gridItem_outline.dds"
local TEXTURE_FAVORITE = "esoui/art/ava/ava_rankicon_general.dds"
local TEXTURE_BAG = "/esoui/art/crafting/crafting_provisioner_inventorycolumn_icon.dds"
local TEXTURE_BANK = "/esoui/art/icons/servicemappins/servicepin_bank.dds"
local TEXTURE_ENABLEBUTTON = "/esoui/art/progression/icon_alchemist.dds"

local COLOR_KHRILLSELECT = ZO_ColorDef:New("FFFF6A00") -- orange ^^
local COLOR_DISABLED = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_DISABLED))
local COLOR_BUTTON = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
local COLOR_USEABLE = ZO_ColorDef:New(1, 1, 1, 0)

local PotionMakerSavedVariables = { }
local PotionMakerSavedFavorites

-- bind common functions to local variable for speed. A myth?
local table = table
local find = string.find
local format = zo_strformat

local LAS
local LMM2

---- common utility functions ----
local function IsThirdAlchemySlotUnlocked()
	-- API function renamed in 100010
	return ZO_Alchemy_IsThirdAlchemySlotUnlocked()
end

local function AddLine(tooltip, text, color, alignment)
	local r, g, b = color:UnpackRGB()
	tooltip:AddLine(text, "", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, alignment, alignment ~= TEXT_ALIGN_LEFT)
end

local function AddLineCenter(tooltip, text, color)
	if not color then color = ZO_TOOLTIP_DEFAULT_COLOR end
	AddLine(tooltip, text, color, TEXT_ALIGN_CENTER)
end

local function AddLineTitle(tooltip, text, color)
	if not color then color = ZO_SELECTED_TEXT end
	local r, g, b = color:UnpackRGB()
	tooltip:AddLine(text, "ZoFontHeader3", r, g, b, CENTER, MODIFY_TEXT_TYPE_UPPERCASE, TEXT_ALIGN_CENTER, true)
end

local function AddLineSubTitle(tooltip, text, color)
	if not color then color = ZO_SELECTED_TEXT end
	local r, g, b = color:UnpackRGB()
	tooltip:AddLine(text, "ZoFontWinH5", r, g, b, CENTER, MODIFY_TEXT_TYPE_UPPERCASE, TEXT_ALIGN_CENTER, true)
end

local function IsScreenRightHalf(sender)
	local x = GuiRoot:GetCenter()
	return sender:GetLeft() > x
end

local function IsScreenLowerHalf(sender)
	local _, y = GuiRoot:GetCenter()
	return sender:GetTop() > y
end

-- local functions --

local function ShowStationOrTopLevel()
	local poison = PotMaker.solventMode == ITEMTYPE_POISON_BASE
	local function GetContentWindow()
		return poison and PotMaker.contentWindowPoison or PotMaker.contentWindowPotion
	end

	local function UseTopLevelWindow()
		PotionMakerOutput.title = PotMaker.modeBarLabel
		PotionMaker.title = PotMaker.modeBarLabel

		PotionMaker:ClearAnchors()
		PotionMaker:SetParent(PotionMakerTopLevel)
		PotionMaker:SetAnchor(TOPLEFT, nil, TOPLEFT, 0, 76)
		PotionMaker:SetHeight(550)
		PotionMakerOutput:ClearAnchors()
		PotionMakerOutput:SetParent(PotionMakerTopLevel)
		PotionMakerOutput:SetAnchor(TOPLEFT, nil, TOPLEFT, 0, 25)

		PotionMakerTopLevel:ClearAnchors()

		PotionMakerTopLevel:SetAnchor(TOPLEFT, ZO_SharedRightPanelBackground, TOPLEFT, 0, 45 + 32)
		PotionMakerTopLevel:SetAnchor(BOTTOMLEFT, ZO_SharedRightPanelBackground, BOTTOMLEFT, 0, -30)
		PotMaker.loading:SetParent(PotionMakerTopLevel)
	end
	local function UseStationMenu()
		PotionMakerOutput.title = LAS
		PotionMaker.title = LAS

		PotionMaker:ClearAnchors()
		PotionMaker:SetParent(GetContentWindow())
		PotionMaker:SetAnchor(TOPLEFT, nil, TOPLEFT, 0, 76)
		PotionMaker:SetHeight(550)
		PotionMakerOutput:ClearAnchors()
		PotionMakerOutput:SetParent(GetContentWindow())
		PotionMakerOutput:SetAnchor(TOPLEFT, nil, TOPLEFT, 0, 25)
		PotionMakerTopLevel:SetHidden(true)
		PotMaker.loading:SetParent(GetContentWindow())
	end
	if not IsInGamepadPreferredMode() and PotMaker.atAlchemyStation then
		UseStationMenu()
	else
		UseTopLevelWindow()
	end

	PotionMakerMustNotLabel:SetText(poison and PotMaker.language.must_have or PotMaker.language.must_not_have)
	PotionMakerAllMustNotCheckBox:SetHidden(poison)
	PotionMakerAllMustNotCheckBoxText:SetHidden(poison)

	local disableThirdSlot = not(IsThirdAlchemySlotUnlocked() or PotionMakerSavedVariables.fakeThirdSlot)
	PotionMakerOnly2:SetHidden(disableThirdSlot)
	PotionMakerOnly2Text:SetHidden(disableThirdSlot)
end

local function ShowFilterPage()
	PotionMaker.title:SetText(GetString(PotMaker.solventMode == ITEMTYPE_POISON_BASE and SI_BINDING_NAME_POISONMAKER or SI_BINDING_NAME_POTIONMAKER))
	PotionMaker:SetHidden(false)
	PotionMakerOutput:SetHidden(true)
	PotMaker.resultListShown = false
	PotMaker.StopJobs()
end

local function ClearTooltips()
	ClearTooltip(InformationTooltip)
	ClearTooltip(ItemTooltip)
	ClearTooltip(PotionMakerTooltip)
end

local function ClearResultList()
	ZO_ClearNumericallyIndexedTable(PotMaker.doablePotions)
	collectgarbage()
end

local function ClearInventory()
	PotMaker.Inventory.reagents = { }
	PotMaker.Inventory.solvents = { }
	for _, v in pairs(PotMaker.SolventFilterControls) do
		v:SetHidden(true)
	end
	for _, v in pairs(PotMaker.ResultControls) do
		v:SetHidden(true)
	end
	PotMaker.quests = nil
end

local function RefreshTitle()
	if PotMaker.resultListShown then
		if PotMaker.favoritesOnly then
			PotionMakerOutput.title:SetText(PotMaker.language.favorites)
		else
			PotionMakerOutput.title:SetText(PotMaker.language.search_results)
		end
	else
		PotionMaker.title:SetText(GetString(SI_BINDING_NAME_POTIONMAKER))
	end
end

local function RefreshCurrentPage()
	if PotMaker.resultListShown then
		PotMaker.restartSearch()
	else
		ClearResultList()
		PotMaker.updateControls()
	end
end

-- PotMaker --

function PotMaker.initVar()
	local traitNames = PotMaker.language.traitNames
	local reagentsById = {
		[30165] =
		{
			traits =
			{
				[traitNames["Ravage Health"]] = false,
				[traitNames["Lower Spell Crit"]] = false,
				[traitNames["Lower Weapon Crit"]] = false,
				[traitNames["Invisible"]] = false
			},
			itemId = 30165,
		},
		[30158] =
		{
			traits =
			{
				[traitNames["Increase Spell Power"]] = false,
				[traitNames["Restore Magicka"]] = false,
				[traitNames["Lower Spell Resist"]] = false,
				[traitNames["Spell Crit"]] = false
			},
			itemId = 30158,
		},
		[30155] =
		{
			traits =
			{
				[traitNames["Ravage Stamina"]] = false,
				[traitNames["Lower Weapon Power"]] = false,
				[traitNames["Restore Health"]] = false,
				[traitNames["Reduce Speed"]] = false
			},
			itemId = 30155,
		},
		[30152] =
		{
			traits =
			{
				[traitNames["Lower Spell Resist"]] = false,
				[traitNames["Ravage Health"]] = false,
				[traitNames["Increase Spell Power"]] = false,
				[traitNames["Ravage Magicka"]] = false
			},
			itemId = 30152,
		},
		[30162] =
		{
			traits =
			{
				[traitNames["Increase Weapon Power"]] = false,
				[traitNames["Restore Stamina"]] = false,
				[traitNames["Lower Armor"]] = false,
				[traitNames["Weapon Crit"]] = false
			},
			itemId = 30162,
		},
		[30148] =
		{
			traits =
			{
				[traitNames["Ravage Magicka"]] = false,
				[traitNames["Lower Spell Power"]] = false,
				[traitNames["Restore Health"]] = false,
				[traitNames["Invisible"]] = false
			},
			itemId = 30148,
		},
		[30149] =
		{
			traits =
			{
				[traitNames["Lower Armor"]] = false,
				[traitNames["Ravage Health"]] = false,
				[traitNames["Increase Weapon Power"]] = false,
				[traitNames["Ravage Stamina"]] = false
			},
			itemId = 30149,
		},
		[30161] =
		{
			traits =
			{
				[traitNames["Restore Magicka"]] = false,
				[traitNames["Increase Spell Power"]] = false,
				[traitNames["Ravage Health"]] = false,
				[traitNames["Detection"]] = false
			},
			itemId = 30161,
		},
		[30160] =
		{
			traits =
			{
				[traitNames["Increase Spell Resist"]] = false,
				[traitNames["Restore Health"]] = false,
				[traitNames["Lower Spell Power"]] = false,
				[traitNames["Restore Magicka"]] = false
			},
			itemId = 30160,
		},
		[30154] =
		{
			traits =
			{
				[traitNames["Lower Spell Power"]] = false,
				[traitNames["Ravage Magicka"]] = false,
				[traitNames["Increase Spell Resist"]] = false,
				[traitNames["Detection"]] = false
			},
			itemId = 30154,
		},
		[30157] =
		{
			traits =
			{
				[traitNames["Restore Stamina"]] = false,
				[traitNames["Increase Weapon Power"]] = false,
				[traitNames["Ravage Health"]] = false,
				[traitNames["Speed"]] = false
			},
			itemId = 30157,
		},
		[30151] =
		{
			traits =
			{
				[traitNames["Ravage Health"]] = false,
				[traitNames["Ravage Magicka"]] = false,
				[traitNames["Ravage Stamina"]] = false,
				[traitNames["Stun"]] = false
			},
			itemId = 30151,
		},
		[30164] =
		{
			traits =
			{
				[traitNames["Restore Health"]] = false,
				[traitNames["Restore Magicka"]] = false,
				[traitNames["Restore Stamina"]] = false,
				[traitNames["Unstoppable"]] = false
			},
			itemId = 30164,
		},
		[30159] =
		{
			traits =
			{
				[traitNames["Weapon Crit"]] = false,
				[traitNames["Reduce Speed"]] = false,
				[traitNames["Detection"]] = false,
				[traitNames["Unstoppable"]] = false
			},
			itemId = 30159,
		},
		[30163] =
		{
			traits =
			{
				[traitNames["Increase Armor"]] = false,
				[traitNames["Restore Health"]] = false,
				[traitNames["Lower Weapon Power"]] = false,
				[traitNames["Restore Stamina"]] = false
			},
			itemId = 30163,
		},
		[30153] =
		{
			traits =
			{
				[traitNames["Spell Crit"]] = false,
				[traitNames["Speed"]] = false,
				[traitNames["Invisible"]] = false,
				[traitNames["Unstoppable"]] = false
			},
			itemId = 30153,
		},
		[30156] =
		{
			traits =
			{
				[traitNames["Lower Weapon Power"]] = false,
				[traitNames["Ravage Stamina"]] = false,
				[traitNames["Increase Armor"]] = false,
				[traitNames["Lower Weapon Crit"]] = false
			},
			itemId = 30156,
		},
		[30166] =
		{
			traits =
			{
				[traitNames["Restore Health"]] = false,
				[traitNames["Spell Crit"]] = false,
				[traitNames["Weapon Crit"]] = false,
				[traitNames["Stun"]] = false
			},
			itemId = 30166,
		},
		[77581] =
		{
			-- Torchbug Thorax
			traits =
			{
				[traitNames["Lower Armor"]] = false,
				[traitNames["Lower Weapon Crit"]] = false,
				[traitNames["Detection"]] = false,
				[traitNames["Vitality"]] = false
			},
			itemId = 77581,
		},
		[77583] =
		{
			-- 	Beetle Scuttle
			traits =
			{
				[traitNames["Lower Spell Resist"]] = false,
				[traitNames["Increase Armor"]] = false,
				[traitNames["Protection"]] = false,
				[traitNames["Vitality"]] = false,
			},
			itemId = 77583
		},
		[77584] =
		{
			-- Spider Egg
			traits =
			{
				[traitNames["Reduce Speed"]] = false,
				[traitNames["Invisible"]] = false,
				[traitNames["Sustained Restore Health"]] = false,
				[traitNames["Defile"]] = false,
			},
			itemId = 77584,
		},
		[77585] =
		{
			-- Butterfly Wing
			traits =
			{
				[traitNames["Restore Health"]] = false,
				[traitNames["Lower Spell Crit"]] = false,
				[traitNames["Sustained Restore Health"]] = false,
				[traitNames["Vitality"]] = false,
			},
			itemId = 77585
		},
		[77587] =
		{
			-- Fleshfly Larva
			traits =
			{
				[traitNames["Ravage Stamina"]] = false,
				[traitNames["Vulnerability"]] = false,
				[traitNames["Creeping Ravage Health"]] = false,
				[traitNames["Vitality"]] = false,
			},
			itemId = 77587
		},
		[77589] =
		{
			-- Scrib Jelly
			traits =
			{
				[traitNames["Ravage Magicka"]] = false,
				[traitNames["Speed"]] = false,
				[traitNames["Vulnerability"]] = false,
				[traitNames["Sustained Restore Health"]] = false,
			},
			itemId = 77589
		},
		[77590] =
		{
			-- Nightshade
			traits =
			{
				[traitNames["Ravage Health"]] = false,
				[traitNames["Protection"]] = false,
				[traitNames["Creeping Ravage Health"]] = false,
				[traitNames["Defile"]] = false,
			},
			itemId = 77590
		},
		[77591] =
		{
			-- Mudcrab Chitin
			traits =
			{
				[traitNames["Increase Spell Resist"]] = false,
				[traitNames["Increase Armor"]] = false,
				[traitNames["Protection"]] = false,
				[traitNames["Defile"]] = false,
			},
			itemId = 77591
		},
	}
	-- generate PotMaker.allReagents from API by item id
	PotMaker.allReagents = { }
	local allReagents = PotMaker.allReagents
	local itemId, reagent, known, traitName, name
	local format, createLink = zo_strformat, string.format
	local getTraitInfo = GetItemLinkReagentTraitInfo
	local getItemLinkName = GetItemLinkName
	for itemId, reagent in pairs(reagentsById) do
		reagent.itemLink = createLink("|H1:item:%i:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", reagent.itemId)
		for i = 1, 4 do
			known, traitName = getTraitInfo(reagent.itemLink, i)
			-- if unknown, traitName is empty
			if known then
				traitName = format("<<C:1>>", traitName)
				reagent.traits[traitName] = known
			end
		end
		name = format(SI_TOOLTIP_ITEM_NAME, getItemLinkName(reagent.itemLink))
		allReagents[name] = reagent
	end

	PotMaker.badTraitMatches = {
		[traitNames["Restore Health"]] = traitNames["Ravage Health"],
		[traitNames["Ravage Health"]] = traitNames["Ravage Health"],
		[traitNames["Restore Magicka"]] = traitNames["Ravage Magicka"],
		[traitNames["Ravage Magicka"]] = traitNames["Ravage Magicka"],
		[traitNames["Restore Stamina"]] = traitNames["Ravage Stamina"],
		[traitNames["Ravage Stamina"]] = traitNames["Ravage Stamina"],
		[traitNames["Increase Weapon Power"]] = traitNames["Lower Weapon Power"],
		[traitNames["Lower Weapon Power"]] = traitNames["Lower Weapon Power"],
		[traitNames["Increase Spell Power"]] = traitNames["Lower Spell Power"],
		[traitNames["Lower Spell Power"]] = traitNames["Lower Spell Power"],
		[traitNames["Weapon Crit"]] = traitNames["Lower Weapon Crit"],
		[traitNames["Lower Weapon Crit"]] = traitNames["Lower Weapon Crit"],
		[traitNames["Spell Crit"]] = traitNames["Lower Spell Crit"],
		[traitNames["Lower Spell Crit"]] = traitNames["Lower Spell Crit"],
		[traitNames["Increase Armor"]] = traitNames["Lower Armor"],
		[traitNames["Lower Armor"]] = traitNames["Lower Armor"],
		[traitNames["Increase Spell Resist"]] = traitNames["Lower Spell Resist"],
		[traitNames["Lower Spell Resist"]] = traitNames["Lower Spell Resist"],
		[traitNames["Unstoppable"]] = traitNames["Stun"],
		[traitNames["Stun"]] = traitNames["Stun"],
		[traitNames["Speed"]] = traitNames["Reduce Speed"],
		[traitNames["Reduce Speed"]] = traitNames["Reduce Speed"],
		[traitNames["Invisible"]] = traitNames["Detection"],
		[traitNames["Detection"]] = traitNames["Invisible"],
		[traitNames["Protection"]] = traitNames["Vulnerability"],
		[traitNames["Sustained Restore Health"]] = traitNames["Creeping Ravage Health"],
		[traitNames["Vitality"]] = traitNames["Defile"],
	}

	PotMaker.oppositeTraits = {
		[traitNames["Restore Health"]] = traitNames["Ravage Health"],
		[traitNames["Ravage Health"]] = traitNames["Restore Health"],
		[traitNames["Restore Magicka"]] = traitNames["Ravage Magicka"],
		[traitNames["Ravage Magicka"]] = traitNames["Restore Magicka"],
		[traitNames["Restore Stamina"]] = traitNames["Ravage Stamina"],
		[traitNames["Ravage Stamina"]] = traitNames["Restore Stamina"],
		[traitNames["Increase Weapon Power"]] = traitNames["Lower Weapon Power"],
		[traitNames["Lower Weapon Power"]] = traitNames["Increase Weapon Power"],
		[traitNames["Increase Spell Power"]] = traitNames["Lower Spell Power"],
		[traitNames["Lower Spell Power"]] = traitNames["Increase Spell Power"],
		[traitNames["Weapon Crit"]] = traitNames["Lower Weapon Crit"],
		[traitNames["Lower Weapon Crit"]] = traitNames["Weapon Crit"],
		[traitNames["Spell Crit"]] = traitNames["Lower Spell Crit"],
		[traitNames["Lower Spell Crit"]] = traitNames["Spell Crit"],
		[traitNames["Increase Armor"]] = traitNames["Lower Armor"],
		[traitNames["Lower Armor"]] = traitNames["Increase Armor"],
		[traitNames["Increase Spell Resist"]] = traitNames["Lower Spell Resist"],
		[traitNames["Lower Spell Resist"]] = traitNames["Increase Spell Resist"],
		[traitNames["Unstoppable"]] = traitNames["Stun"],
		[traitNames["Stun"]] = traitNames["Unstoppable"],
		[traitNames["Speed"]] = traitNames["Reduce Speed"],
		[traitNames["Reduce Speed"]] = traitNames["Speed"],
		[traitNames["Invisible"]] = traitNames["Detection"],
		[traitNames["Detection"]] = traitNames["Invisible"],
		[traitNames["Vitality"]] = traitNames["Defile"],
		[traitNames["Sustained Restore Health"]] = traitNames["Creeping Ravage Health"],
		[traitNames["Protection"]] = traitNames["Vulnerability"],
		[traitNames["Creeping Ravage Health"]] = traitNames["Sustained Restore Health"],
		[traitNames["Defile"]] = traitNames["Vitality"],
		[traitNames["Vulnerability"]] = traitNames["Protection"],
	}
	-- scan matching reagents once
	local reagents = { }
	for name in pairs(allReagents) do
		reagents[#reagents + 1] = name
	end
	local others, name, found, otherName, other
	local count = #reagents
	for i = 1, count do
		others = { }
		name = reagents[i]
		for t = 1, count do
			if i ~= t then
				otherName = reagents[t]
				found = false
				other = allReagents[otherName]
				for trait in pairs(allReagents[name].traits) do
					if other.traits[trait] ~= nil then
						found = true
						break
					end
				end
				if found then others[#others + 1] = otherName end
			end
		end
		allReagents[name].matching = others
	end

end

function PotMaker.IsProtected(bagId, slotIndex)
	if PotionMakerSavedVariables.useItemSaver then
		if FCOIsMarked and FCOIsMarked(GetItemInstanceId(bagId, slotIndex), -1) then return true end
		if ItemSaver_IsItemSaved and ItemSaver_IsItemSaved(bagId, slotIndex) then return true end

	end
	if FilterIt then
		local itemFilterId = FilterIt.AccountSavedVariables.FilteredItems[Id64ToString(GetItemUniqueId(bagId, slotIndex))]
		if itemFilterId and itemFilterId ~= FILTERIT_ALCHEMY then return true end
	end
	return false
end

----- Ingredient -----
PotMaker.Ingredient = {
	name = "",
	level = 0,
	icon = TEXTURE_REAGENTUNKNOWN,
}

function PotMaker.Ingredient:matchIngredient1(passiveIngredient)
	local matched = { }
	local trait
	local badTraitMatches = PotMaker.badTraitMatches
	for trait in pairs(self.traits) do
		if trait == nil then
			return matched
		end
		if passiveIngredient.traits[trait] ~= nil then
			if badTraitMatches[trait] == trait then
				matched[#matched + 1] = trait .. "-"
			else
				matched[#matched + 1] = trait .. "+"
			end
		end
	end
	return matched
end

function PotMaker.Ingredient:matchIngredient(passiveIngredient)
	local matched = { }
	local passSingleTrait = false
	local traitName
	local addsOpposite = false
	local addsBad = false
	local data = PotMaker
	local passiveTraits = passiveIngredient.traits
	local activeTraits = 0
	for traitName in pairs(self.traits) do
		local lastCharOfSelfName
		local trait = traitName:gsub("[%-%+]$", function(m) lastCharOfSelfName = m return "" end)
		local double = lastCharOfSelfName == "-" or lastCharOfSelfName == "+"
		local doubleInserted = false
		if double then activeTraits = activeTraits + 1 end
		if double and passiveTraits[data.oppositeTraits[trait]] ~= nil then
			-- new ingredient has opposite
			doubleInserted = true
			if lastCharOfSelfName == "-" then
				if addsBad then return matched, false end
				addsBad = true
				addsOpposite = true
			end
		end
		if passiveTraits[trait] ~= nil then
			if data.badTraitMatches[trait] == trait then
				if double then
					matched[#matched + 1] = trait .. "/"
					doubleInserted = true
					passSingleTrait = true
				elseif not addsBad then
					matched[#matched + 1] = trait .. "-"
					addsBad = true
				end
			else
				if double then
					matched[#matched + 1] = trait .. "*"
					doubleInserted = true
					passSingleTrait = true
				else
					matched[#matched + 1] = trait .. "+"
				end
			end
		end
		if double and not doubleInserted then
			matched[#matched + 1] = traitName
		end
	end
	if addsOpposite and addsBad and #matched == 1 and activeTraits > 1 then
		-- is a compensate
		passSingleTrait = true
	end
	return matched, passSingleTrait
end

function PotMaker.Ingredient:ResetStack()
	self.pack = { }
	self.stack = 0
end

function PotMaker.Ingredient:new(o)
	o = o or { }
	-- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	local newTraits
	if PotionMakerSavedVariables.useUnknown or PotionMakerSavedVariables.useMissing then
		newTraits = PotMaker.allReagents[o.name]
		if newTraits == nil then
			newTraits = { }
		else
			newTraits = newTraits.traits
		end
	else
		newTraits = { }
	end
	-- scrub nil values, other are known trait
	for _, v in pairs(o.traits) do
		if v ~= nil then
			newTraits[v] = true
		end
	end
	o.traits = newTraits
	o.stack = 0
	return o
end

function PotMaker.Ingredient:solvent(o)
	o = o or { }
	-- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	o.stack = 0
	return o
end

----- ToggleButton -----
function PotMaker.ToggleButton(resultButton, button)
	if button ~= MOUSE_BUTTON_INDEX_LEFT then return end

	if resultButton:GetNamedChild("Outline"):IsControlHidden() then
		PotMaker.SetToggleButton(resultButton, true)
	else
		PotMaker.SetToggleButton(resultButton, false)
	end
end

function PotMaker.SetToggleButton(resultButton, state)
	local control = resultButton:GetNamedChild("Outline")
	if state then
		control:SetColor(COLOR_KHRILLSELECT:UnpackRGB())
		control:SetTexture(TEXTURE_HIGHLIGHT)
		control:SetHidden(false)
	else
		control:SetHidden(true)
	end
end

function PotMaker.ToggleButtonIsChecked(resultButton)
	return not resultButton:GetNamedChild("Outline"):IsControlHidden()
end

----- Class Potion -----
PotMaker.Potion = {
	name = "",
	searchName = "",
	upperName = "",
	ingredients = { },
	solvent = "",
	traits = { },
	qualityColor = "",
	quantity = 0,
	itemLink = "",
	itemId = "",
	samePotionId = "",
	sameTraitsId = ""
}

do
	local GetAlchemyResultingItemLink = GetAlchemyResultingItemLink

	function PotMaker.Potion:new(o)
		-- create object if user does not provide one
		setmetatable(o, self)
		self.__index = self
		if o.solvent.name ~= "" then
			local pack1 = o.ingredients[1].pack[1]
			local pack2 = o.ingredients[2].pack[1]
			local solvent = o.solvent.pack[1]
			if pack1 and pack2 and solvent then
				if o.ingredients[3] and o.ingredients[3].pack[1] then
					local pack3 = o.ingredients[3].pack[1]
					o.itemLink = GetAlchemyResultingItemLink(solvent.bagId, solvent.slotIndex, pack1.bagId, pack1.slotIndex, pack2.bagId, pack2.slotIndex, pack3.bagId, pack3.slotIndex)
				else
					o.itemLink = GetAlchemyResultingItemLink(solvent.bagId, solvent.slotIndex, pack1.bagId, pack1.slotIndex, pack2.bagId, pack2.slotIndex)
				end
			end
		else
			o.searchName = ""
			o.name = ""
			o.itemLink = ""
			o.solvent = nil
		end
		return o
	end
end

function PotMaker.Potion:GetQualityColor()
	if self.qualityColor ~= "" then return self.qualityColor end
	self.qualityColor = GetItemQualityColor(GetItemLinkQuality(self.itemLink))
	return self.qualityColor
end

function PotMaker.Potion:GetName()
	if self.name ~= "" then return self.name end
	self.name = GetItemLinkName(self.itemLink)
	return self.name
end

do
	local upper = string.upper
	function PotMaker.Potion:GetUpperName()
		if self.upperName ~= "" then return self.upperName end
		self.upperName = upper(self:GetName())
		return self.upperName
	end
end

do
	local SI_TOOLTIP_ITEM_NAME = SI_TOOLTIP_ITEM_NAME

	function PotMaker.Potion:GetSearchName()
		if self.searchName ~= "" then return self.searchName end
		if PotMaker.language.name == "de" then
			self.searchName = format("<<Cm:1>>", self:GetName(), 2):gsub("ene", "en")

		---- for Japanese Translation ----
		elseif PotMaker.language.name == "jp" then
			-- Remove space
			self.searchName = format(SI_TOOLTIP_ITEM_NAME, self:GetName():gsub(" ", ""))

		else
			self.searchName = format(SI_TOOLTIP_ITEM_NAME, self:GetName())
		end
		return self.searchName
	end
end

do
	local mustHaves = { }
	local lastCharOfSelfName
	local function GetLastChar(m) lastCharOfSelfName = m return "" end

	function PotMaker.Potion:conformsToSearch(searchTerms)
		-- if no name then not conform
		if self.solvent ~= nil and(self.itemLink == "" and not(PotionMakerSavedVariables.useUnknown or PotionMakerSavedVariables.useMissing)) then return false end

		if PotMaker.questPotionsOnly then
			if self.itemLink == "" then return false end
			if not find(PotMaker.quests, self:GetSearchName()) then return false end
		
			---- for Japanese Translation ----
			if PotMaker.language.name ~= "jp" then
				if not find(PotMaker.quests, zo_strjoin(nil, "%A", self:GetSearchName(), "%A")) then return false end
			end
		end


		if PotMaker.favoritesOnly then
			self:createFavoriteIdentifier()
			if not PotMaker.favoriteFilter(self) then return false end
		end

		searchTerms = searchTerms or { }
		local searchTermsExist = next(searchTerms) ~= nil
		local unknownTrait = false
		local traitName
		ZO_ClearTable(mustHaves)

		local useUnknown = PotionMakerSavedVariables.useUnknown
		if searchTermsExist or useUnknown then
			for i = 1, #self.traits do
				lastCharOfSelfName = nil
				traitName = self.traits[i]:gsub("[%-%+%*%/]$", GetLastChar)
				if lastCharOfSelfName == "-" or lastCharOfSelfName == "/" then
					if searchTerms[traitName] == false then
						return false
					end
					if useUnknown then
						for j = 1, #self.ingredients do
							if self.ingredients[j].traits[traitName] == false then
								-- nil ~= false
								unknownTrait = true
								break
							end
						end
					end
				elseif lastCharOfSelfName == "+" or lastCharOfSelfName == "*" then
					if useUnknown then
						for j = 1, #self.ingredients do
							if self.ingredients[j].traits[traitName] == false then
								-- nil ~= false
								unknownTrait = true
								break
							end
						end
					end
					if searchTerms[traitName] == true then
						mustHaves[traitName] = true
					end
				end
			end
			for k, v in pairs(searchTerms) do
				if v and mustHaves[k] == nil then
					return false
				end
			end
		end
		if not PotionMakerSavedVariables.training or(useUnknown and unknownTrait) then
			return true
		end
		return self.solvent == nil
	end

	function PotMaker.Potion:conformsToSearchPoison(searchTerms)
		-- if no name then not conform
		if self.solvent ~= nil and(self.itemLink == "" and not(PotionMakerSavedVariables.useUnknown or PotionMakerSavedVariables.useMissing)) then return false end

		if PotMaker.questPotionsOnly then
			if self.itemLink == "" then return false end
			if not find(PotMaker.quests, self:GetSearchName()) then return false end

			---- for Japanese Translation ----
			if PotMaker.language.name ~= "jp" then
				if not find(PotMaker.quests, zo_strjoin(nil, "%A", self:GetSearchName(), "%A")) then return false end
			end
		end

		if PotMaker.favoritesOnly then
			self:createFavoriteIdentifier()
			if not PotMaker.favoriteFilter(self) then return false end
		end

		searchTerms = searchTerms or { }
		local searchTermsExist = next(searchTerms) ~= nil
		local unknownTrait = false
		local traitName
		ZO_ClearTable(mustHaves)

		local useUnknown = PotionMakerSavedVariables.useUnknown
		if searchTermsExist or useUnknown then
			for i = 1, #self.traits do
				lastCharOfSelfName = nil
				traitName = self.traits[i]:gsub("[%-%+%*%/]$", GetLastChar)
				if lastCharOfSelfName then
					if useUnknown then
						for j = 1, #self.ingredients do
							if self.ingredients[j].traits[traitName] == false then
								-- nil ~= false
								unknownTrait = true
								break
							end
						end
					end
					if searchTerms[traitName] == true then
						mustHaves[traitName] = true
					end
				end
			end
			for k, v in pairs(searchTerms) do
				if v and mustHaves[k] == nil then
					return false
				end
			end
		end
		if not PotionMakerSavedVariables.training or(useUnknown and unknownTrait) then
			return true
		end
		return self.solvent == nil
	end
end

do
	local ingredients = { 0, 0, 0 }
	local join = zo_strjoin

	function PotMaker.Potion:createFavoriteIdentifier()
		if #self.itemId > 0 then return end
		local item1, item3, item2 = self.itemLink:match("^|H[^:]+:item:([^:]+):[^:]+:([^:]+):[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:([^|]+)|h")
		local allReagents = PotMaker.allReagents
		ingredients[3] = nil
		local index = 1
		for _, ingredient in pairs(self.ingredients) do
			ingredients[index] = allReagents[ingredient.name].itemId
			index = index + 1
		end
		table.sort(ingredients)
		self.itemId = join("_", item1, item2, item3, unpack(ingredients))
		self.samePotionId = join("_", item1, item2, item3)
		self.sameTraitsId = join("_", item1, item2)
	end
end

function PotMaker.Potion.get(resultButton)
	return resultButton.potion
end

function PotMaker:AddToCraftTable(potion)
	local function SwapSound(slot, source, destination)
		slot[destination] = slot[source]
		slot[source] = nil
	end
	local function MuteSlot(slot)
		SwapSound(slot, "placeSound", "placeSoundBackup")
		SwapSound(slot, "removeSound", "removeSoundBackup")
	end
	local function RestoreSlot(slot)
		SwapSound(slot, "placeSoundBackup", "placeSound")
		SwapSound(slot, "removeSoundBackup", "removeSound")
	end

	local hasThreeSlots = PotionMakerSavedVariables.fakeThirdSlot or IsThirdAlchemySlotUnlocked()
	if potion ~= nil and PotMaker.atAlchemyStation and(hasThreeSlots or #potion.ingredients < 3) then
		if CRAFTING_RESULTS.craftingProcessCompleted == false then
			PlaySound(SOUNDS.NEGATIVE_CLICK)
			return
		end

		local ALCHEMY = IsInGamepadPreferredMode() and GAMEPAD_ALCHEMY or ALCHEMY
		MuteSlot(ALCHEMY.solventSlot)

		if ALCHEMY:HasSelections() then
			for i = 1, #ALCHEMY.reagentSlots do MuteSlot(ALCHEMY.reagentSlots[i]) end
			ALCHEMY:ClearSelections()
			for i = 1, #ALCHEMY.reagentSlots do RestoreSlot(ALCHEMY.reagentSlots[i]) end
		end
		if PotMaker.atAlchemyStation and ALCHEMY.inventory.dirty then
			ALCHEMY.inventory:PerformFullRefresh()
		end

		local GetItemInfo = GetItemInfo
		local wasProtected = false
		if potion.solvent ~= nil and potion.solvent.pack then
			for _, p in pairs(potion.solvent.pack) do
				local _, stack = GetItemInfo(p.bagId, p.slotIndex)
				if stack > 0 then
					if not PotMaker.IsProtected(p.bagId, p.slotIndex) then
						ALCHEMY:SetSolventItem(p.bagId, p.slotIndex)
						wasProtected = false
						break
					else
						wasProtected = true
					end
				end
			end
		end
		for k, v in pairs(potion.ingredients) do
			local itemProtected = false
			for _, p in pairs(v.pack) do
				local _, stack = GetItemInfo(p.bagId, p.slotIndex)
				if stack > 0 then
					if not PotMaker.IsProtected(p.bagId, p.slotIndex) then
						itemProtected = false
						ALCHEMY:AddItemToCraft(p.bagId, p.slotIndex)
						break
					else
						itemProtected = true
					end
				end
			end
			wasProtected = wasProtected or itemProtected
		end

		RestoreSlot(ALCHEMY.solventSlot)

		if wasProtected then
			ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, PotMaker.language.item_saver_protected)
		end
		if IsInGamepadPreferredMode() then ALCHEMY:OnWorkbenchUpdated() end
	end
end

function PotMaker.Potion.show(resultButton)
	local potion = PotMaker.Potion.get(resultButton)
	PotMaker:AddToCraftTable(potion)
	PotMaker:SetSelected(potion)
end

function PotMaker.Potion:getIngredientString()
	return zo_strformat("<<1>> (<<2>>)", self:getPotionNameString(), COLOR_KHRILLSELECT:Colorize(self.quantity))
end

function PotMaker.Potion:getInBagString()
	local inBag = ""
	if self.itemLink ~= "" then
		local bagId = PotMaker.Inventory.potions[self.itemLink]
		if bagId == BAG_BANK then
			inBag = "|t28:28:esoui/art/icons/servicemappins/servicepin_bank.dds:inheritColor|t"
		elseif bagId == BAG_BACKPACK then
			inBag = "|t28:28:esoui/art/crafting/crafting_provisioner_inventorycolumn_icon.dds:inheritColor|t"
		end
	end
	return inBag
end

do
	local unknown = {
		[ITEMTYPE_POTION_BASE] = zo_strformat(SI_ALCHEMY_UNKNOWN_RESULT,GetString(SI_ITEM_FORMAT_STR_POTION)),
		[ITEMTYPE_POISON_BASE] = zo_strformat(SI_ALCHEMY_UNKNOWN_RESULT,GetString(SI_ITEM_FORMAT_STR_POISON))
	}
	function PotMaker.Potion:getPotionNameString()
		if self.solvent == nil then
			return COLOR_DISABLED:Colorize(zo_strformat("(<<1>>)", PotMaker.language.need_solvent))
		elseif self.itemLink == "" then
			return unknown[PotMaker.solventMode] or unknown[ITEMTYPE_POTION_BASE]
		else
			return self:GetQualityColor():Colorize(zo_strformat(SI_TOOLTIP_ITEM_NAME, self:GetName()))
		end
	end
end
----- End Class Potion -----

PotMaker.Inventory = {
	reagents = { },
	solvents = { }
}

function PotMaker.toggleBag(button)
	-- // BagButton selected
	PotMaker.BagMode = not PotMaker.BagMode
	if not PotMaker.BagMode then
		PotionMakerBagButtonTexture:SetColor(COLOR_DISABLED:UnpackRGB())
	else
		PotionMakerBagButtonTexture:SetColor(COLOR_KHRILLSELECT:UnpackRGB())
	end
	PotMaker.addStuffToInventory()
	PotMaker.updateControls()
end
function PotMaker.toggleBank(button)
	-- // BankButton selected
	PotMaker.BankMode = not PotMaker.BankMode
	if not PotMaker.BankMode then
		PotionMakerBankButtonTexture:SetColor(COLOR_DISABLED:UnpackRGB())
	else
		PotionMakerBankButtonTexture:SetColor(COLOR_KHRILLSELECT:UnpackRGB())
	end
	PotMaker.addStuffToInventory()
	PotMaker.updateControls()
end

function PotMaker.addAllStuffToInventory()
	local zo_strformat = zo_strformat
	for reagent in pairs(PotMaker.allReagents) do
		local item = PotMaker.Ingredient:new { name = zo_strformat(SI_TOOLTIP_ITEM_NAME, reagent), icon = TEXTURE_REAGENTUNKNOWN, traits = { }, iconTraits = { }, pack = { } }
		item.qualityColor = GetItemQualityColor(ITEM_QUALITY_MAGIC)
		PotMaker.Inventory.reagents[item.name] = item
	end
end

function PotMaker.addStuffToInventoryForBag(bagId)
	local GetItemType = GetItemType
	local GetItemInfo = GetItemInfo
	local GetAlchemyItemTraits = GetAlchemyItemTraits
	local zo_strformat = zo_strformat
	local GetItemName = GetItemName
	local GetItemLevel = GetItemLevel
	local itemType

	local function AddToKnownTrait(iconTraits, trait, icon)
		if trait then
			trait = zo_strformat("<<C:1>>", trait)
			iconTraits[trait] = icon
		end
		return trait
	end

	local function AddReagent(itemType, slotIndex)
		local icon, stack, _, meetsUsageRequirement, _, _, _, quality = GetItemInfo(bagId, slotIndex)
		local name = GetItemName(bagId, slotIndex)
		-- stripTrailingJunk, correct uppercase
		name = zo_strformat(SI_TOOLTIP_ITEM_NAME, name)
		local level = GetItemLevel(bagId, slotIndex)
		if not IsAlchemySolvent(itemType) then
			-- Reagents
			local trait1, icon1, _, _, _, trait2, icon2, _, _, _, trait3, icon3, _, _, _, trait4, icon4 = GetAlchemyItemTraits(bagId, slotIndex)
			local iconTraits = { }
			trait1 = AddToKnownTrait(iconTraits, trait1, icon1)
			trait2 = AddToKnownTrait(iconTraits, trait2, icon2)
			trait3 = AddToKnownTrait(iconTraits, trait3, icon3)
			trait4 = AddToKnownTrait(iconTraits, trait4, icon4)
			local traits = { trait1, trait2, trait3, trait4 }
			local itemAlreadyInInventory = PotMaker.Inventory.reagents[name]
			local item = PotMaker.Ingredient:new { name = name, icon = icon, level = level, traits = traits, iconTraits = iconTraits, pack = { }, protected = true }
			if itemAlreadyInInventory ~= nil then
				-- replace missing reagent placeholder
				itemAlreadyInInventory.icon = icon
				itemAlreadyInInventory.level = level
				itemAlreadyInInventory.iconTraits = iconTraits
				itemAlreadyInInventory.traits = item.traits
				itemAlreadyInInventory.stack = itemAlreadyInInventory.stack + stack
				itemAlreadyInInventory.protected = itemAlreadyInInventory.protected and PotMaker.IsProtected(bagId, slotIndex)
				table.insert(itemAlreadyInInventory.pack, { bagId = bagId, slotIndex = slotIndex })
			else
				table.insert(item.pack, { bagId = bagId, slotIndex = slotIndex })
				item.stack = stack
				item.protected = PotMaker.IsProtected(bagId, slotIndex)
				PotMaker.Inventory.reagents[name] = item
			end
		elseif meetsUsageRequirement and itemType == PotMaker.solventMode then
			-- Solvents
			local itemAlreadyInInventory = PotMaker.Inventory.solvents[name]
			if itemAlreadyInInventory ~= nil then
				itemAlreadyInInventory.stack = itemAlreadyInInventory.stack + stack
				itemAlreadyInInventory.protected = itemAlreadyInInventory.protected and PotMaker.IsProtected(bagId, slotIndex)
				table.insert(itemAlreadyInInventory.pack, { bagId = bagId, slotIndex = slotIndex })
			else
				local item = PotMaker.Ingredient:solvent { name = name, icon = icon, level = level, pack = { { bagId = bagId, slotIndex = slotIndex } } }
				item.stack = stack
				item.protected = PotMaker.IsProtected(bagId, slotIndex)
				PotMaker.Inventory.solvents[name] = item
			end
		end
	end
	local function AddPotion(slotIndex)
		local itemLink = GetItemLink(bagId, slotIndex)
		if PotMaker.Inventory.potions[itemLink] == nil then
			PotMaker.Inventory.potions[itemLink] = bagId
		end
	end

	local GetItemType, ZO_GetNextBagSlotIndex, ZO_Alchemy_IsAlchemyItem, IsAlchemySolvent = GetItemType, ZO_GetNextBagSlotIndex, ZO_Alchemy_IsAlchemyItem, IsAlchemySolvent
	local slotIndex = ZO_GetNextBagSlotIndex(bagId, nil)
	while slotIndex do
		itemType = GetItemType(bagId, slotIndex)
		if itemType == ITEMTYPE_POTION or itemType == ITEMTYPE_POISON then
			AddPotion(slotIndex)
		elseif ZO_Alchemy_IsAlchemyItem(bagId, slotIndex) then
			AddReagent(itemType, slotIndex)
		end
		slotIndex = ZO_GetNextBagSlotIndex(bagId, slotIndex)
	end
end

function PotMaker.updateStuffofInventory()
	-- backpack
	if PotMaker.BagMode then
		PotMaker.addStuffToInventoryForBag(BAG_BACKPACK)
		PotMaker.addStuffToInventoryForBag(BAG_VIRTUAL)
	end
	-- bank
	if PotMaker.BankMode then PotMaker.addStuffToInventoryForBag(BAG_BANK) end
end
function PotMaker.addStuffToInventory()
	PotMaker.Inventory = {
		reagents = { },
		solvents = { },
		potions = { }
	}
	if PotionMakerSavedVariables.useMissing then
		PotMaker.addAllStuffToInventory()
	end
	PotMaker.updateStuffofInventory()
end

local function SortPotions()
	table.sort(PotMaker.doablePotions, function(a, b)
		if a.solvent == b.solvent then
			if a:GetName() == b:GetName() then
				if a.quantity == b.quantity then
					return a.samePotionId < b.samePotionId
				else
					return a.quantity > b.quantity
				end
			else
				return a:GetUpperName() < b:GetUpperName()
			end
		else
			if a.solvent == "" then return true end
			if b.solvent == "" then return false end
			return a.solvent.level < b.solvent.level
		end
	end )
end

do
	local jobs = { }

	local identifier = "POTIONMAKER_JOBS"
	local index
	local function lastjob()
		EVENT_MANAGER:UnregisterForUpdate(identifier)
		SortPotions()
		PotMaker.resultsMaxIndex = math.max(0, math.min(math.floor((#PotMaker.doablePotions - pageSize + 1) / pageSize) * pageSize, PotMaker.resultsMaxIndex))
		PotMaker.RenderPage()
		if PotMaker.questPotionsOnly then
			local potion = PotMaker.doablePotions[1]
			PotMaker:SetSelected(potion)
			PotMaker:AddToCraftTable(potion)
		end
	end
	function PotMaker.StopJobs()
		PotMaker.loading:Hide()
		ZO_ClearNumericallyIndexedTable(jobs)
		EVENT_MANAGER:UnregisterForUpdate(identifier)
	end
	local function nextjob()
		local start = GetFrameTimeMilliseconds()
		-- time we can spend until the next frame must be shown (50% of render time in ms = 1/fps * 1000 / 2):
		local spendTime = 670 / GetFramerate()
		repeat
			local job = jobs[index]
			if job then
				job()
				index = index + 1
				if index > #jobs then
					PotMaker.StopJobs()
					EVENT_MANAGER:RegisterForUpdate(identifier, 0, lastjob)
					return
				end
			else
				PotMaker.StopJobs()
				return
			end
		until (GetGameTimeMilliseconds() - start) >= spendTime
	end
	local function DoJobs()
		index = 1
		EVENT_MANAGER:UnregisterForUpdate(identifier)
		EVENT_MANAGER:RegisterForUpdate(identifier, 0, nextjob)
	end

	local uniqueName = { true, true, true }
	local function GetUniqueName(ingredients)
		uniqueName[3] = nil
		for i = 1, #ingredients do
			uniqueName[i] = ingredients[i].name
		end
		table.sort(uniqueName)
		return table.concat(uniqueName)
	end

	function PotMaker.findDoablePotions(searchTerms, searchSolvent, searchReagent)
		PotMaker.StopJobs()
		local find = string.find
		local function createCombinationIngredient(ingredient1, ingredient2, matches)
			local combinationTraits = matches
			local oppositeTraitInIngredient1
			local oppositeTraitInIngredient2
			local matched
			for trait1 in pairs(ingredient1.traits) do
				matched = false
				for _, match1 in pairs(matches) do
					if find(match1, trait1) == 1 then
						matched = true
						break
					end
				end
				if not matched then
					oppositeTraitInIngredient2 = false
					for trait2 in pairs(ingredient2.traits) do
						if PotMaker.oppositeTraits[trait1] == trait2 then
							oppositeTraitInIngredient2 = true
							break
						end
					end
					if not oppositeTraitInIngredient2 then
						combinationTraits[#combinationTraits + 1] = trait1
					end
				end
			end
			for trait2 in pairs(ingredient2.traits) do
				matched = false
				for _, match1 in pairs(matches) do
					if find(match1, trait2) == 1 then
						matched = true
						break
					end
				end
				if not matched then
					oppositeTraitInIngredient1 = false
					for trait1 in pairs(ingredient1.traits) do
						if PotMaker.oppositeTraits[trait2] == trait1 then
							oppositeTraitInIngredient1 = true
							break
						end
					end
					if not oppositeTraitInIngredient1 then
						combinationTraits[#combinationTraits + 1] = trait2
					end
				end
			end

			return PotMaker.Ingredient:new { traits = combinationTraits }
		end

		ClearResultList()
		searchTerms = searchTerms or { }
		searchSolvent = searchSolvent or { }
		searchReagent = searchReagent or { }

		local useThirdSlot =(IsThirdAlchemySlotUnlocked() or PotionMakerSavedVariables.fakeThirdSlot) and not PotMaker.potion2ReagentFilter

		local processed = { }
		local reagentFilter
		if searchReagent.count == 0 and not PotMaker.onlyReagentFilter then
			reagentFilter = function() return true end
		elseif not PotMaker.onlyReagentFilter then
			-- any match
			reagentFilter = function(reagentList)
				for i = 1, #reagentList do
					if searchReagent[reagentList[i].name] ~= nil then return true end
				end
				return false
			end
		else
			-- all match
			reagentFilter = function(reagentList)
				for i = 1, #reagentList do
					if searchReagent[reagentList[i].name] == nil then return false end
				end
				return true
			end
		end
		local potions = PotMaker.doablePotions
		local quantityFilter
		local useMissing = PotionMakerSavedVariables.useMissing
		if useMissing then
			quantityFilter = function() return true end
		else
			quantityFilter = function(quantity) return quantity > 0 end
		end

		local CreatePotion = PotMaker.solventMode == ITEMTYPE_POISON_BASE and function(potions, traits, ingredients, solvent, quantity)
			if quantityFilter(quantity) then
				-- create potion
				local potion = PotMaker.Potion:new { traits = traits, ingredients = ingredients, solvent = solvent, quantity = quantity }
				if potion:conformsToSearchPoison(searchTerms) then
					potion:createFavoriteIdentifier()
					potion:GetUpperName()
					potions[#potions + 1] = potion
				end
			end
		end or function(potions, traits, ingredients, solvent, quantity)
			if quantityFilter(quantity) then
				-- create potion
				local potion = PotMaker.Potion:new { traits = traits, ingredients = ingredients, solvent = solvent, quantity = quantity }
				if potion:conformsToSearch(searchTerms) then
					potion:createFavoriteIdentifier()
					potion:GetUpperName()
					potions[#potions + 1] = potion
				end
			end
		end

		local solvents = { }
		for name in pairs(searchSolvent) do
			local solvent = PotMaker.Inventory.solvents[name]
			if solvent == nil then
				-- dummy solvent
				solvent = PotMaker.Ingredient:solvent { name = "" }
				useMissing = true
			end
			solvents[#solvents + 1] = solvent
		end

		local allReagents = PotMaker.allReagents
		local reagents = PotMaker.Inventory.reagents
		local min = math.min
		local function FindTripleSlot(combinationIngredient, ingredient1, ingredient2, amount1, amount2, matching)
			for j = 1, #matching do
				-- add more traits
				local ingredient3 = reagents[matching[j]]
				if ingredient3 ~= nil and ingredient1 ~= ingredient3 and ingredient2 ~= ingredient3 then
					local ingredients = { ingredient1, ingredient2, ingredient3 }
					if reagentFilter(ingredients) then
						local uniqueName = GetUniqueName(ingredients)
						if processed[uniqueName] == nil then
							local amount3 = ingredient3.stack
							local combinationMatches, passSingleTrait = combinationIngredient:matchIngredient(ingredient3)
							if #combinationMatches >= 2 or passSingleTrait then
								-- for each selected solvent we make a potion
								for s = 1, #solvents do
									local currentSolvent = solvents[s]

									CreatePotion(potions, combinationMatches, ingredients, currentSolvent, min(amount1, amount2, amount3, currentSolvent.stack))
								end
								processed[uniqueName] = true
							end
						end
					end
				end
			end
		end
		local function FindDoubleSlot(ingredient1, ingredient2, amount1)
			-- required here for third slot
			local amount2 = ingredient2.stack
			local checkMatches = ingredient1:matchIngredient1(ingredient2)

			local ingredients = { ingredient1, ingredient2 }
			if reagentFilter(ingredients) then
				-- for each selected solvent we make a potion
				for s = 1, #solvents do
					local currentSolvent = solvents[s]

					CreatePotion(potions, checkMatches, ingredients, currentSolvent, min(amount1, amount2, currentSolvent.stack))
				end
			end
			-- if three slots for alchemy then
			if useThirdSlot then
				local combinationIngredient = createCombinationIngredient(ingredient1, ingredient2, checkMatches)
				-- long life the Lua enclosure
				jobs[#jobs + 1] = function() FindTripleSlot(combinationIngredient, ingredient1, ingredient2, amount1, amount2, allReagents[ingredient1.name].matching) end
				jobs[#jobs + 1] = function() FindTripleSlot(combinationIngredient, ingredient1, ingredient2, amount1, amount2, allReagents[ingredient2.name].matching) end
			end
		end
		for _, ingredient1 in pairs(reagents) do
			local amount1 = ingredient1.stack
			local matching1 = allReagents[ingredient1.name].matching
			for k = 1, #matching1 do
				local ingredient2 = reagents[matching1[k]]

				if ingredient2 ~= nil and allReagents[ingredient1.name].itemId < allReagents[ingredient2.name].itemId then
					-- long life the Lua enclosure
					jobs[#jobs + 1] = function() FindDoubleSlot(ingredient1, ingredient2, amount1) end
				end
			end
		end
		PotionMaker:SetHidden(true)
		PotMaker.loading:Show()
		PotMaker.resultListShown = true
		DoJobs()
	end
end

function PotMaker.interactWithAlchemyStation(eventCode, craftSkill)
	if craftSkill == CRAFTING_TYPE_ALCHEMY then
		-- check xp gain
		if PotionMakerSavedVariables.XPMode then EVENT_MANAGER:RegisterForEvent(PotMaker.name, EVENT_SKILL_XP_UPDATE, function(eventCode, skillType, skillIndex, reason, rank, previousXP, currentXP) if reason == PROGRESS_REASON_TRADESKILL or reason == PROGRESS_REASON_TRADESKILL_TRAIT then PotMaker:OnSkillXP(skillType, skillIndex, previousXP, currentXP) end end) end

		PotMaker.atAlchemyStation = true

		if CRAFTING_RESULTS.craftingProcessCompleted == false then
			CRAFTING_RESULTS.craftingProcessCompleted = true
		end

		ShowStationOrTopLevel()
		ShowFilterPage()
		PotMaker.addStuffToInventory()
		PotMaker.updateControls()

		if not PotMaker.atAlchemyStation or PotionMakerSavedVariables.showAsDefault then
			if PotMaker.atAlchemyStation then LAS:SelectTab(PotionMakerSavedVariables.lastUsedTab or PotMaker.descriptorPotion) end
		end

		local selected = LAS:GetSelectedTab()
		PotionMaker:SetHidden((selected ~= PotMaker.descriptorPotion and selected ~= PotMaker.descriptorPoison) and not IsInGamepadPreferredMode())

		EVENT_MANAGER:RegisterForEvent(PotMaker.name, EVENT_CRAFT_COMPLETED, PotMaker.craftCompleted)
		EVENT_MANAGER:RegisterForEvent(PotMaker.name, EVENT_END_CRAFTING_STATION_INTERACT, PotMaker.endInteractionWithAlchemyStation)
	end
end

function PotMaker.endInteractionWithAlchemyStation(eventCode)
	ShowFilterPage()
	ClearResultList()
	ClearInventory()
	ClearTooltips()

	PotionMakerSavedVariables.lastUsedTab = IsInGamepadPreferredMode() and ZO_MenuBar_GetSelectedDescriptor(PotMaker.modeBar) or LAS:GetSelectedTab()

	PotMaker.atAlchemyStation = false
	EVENT_MANAGER:UnregisterForEvent(PotMaker.name, EVENT_CRAFT_COMPLETED)
	EVENT_MANAGER:UnregisterForEvent(PotMaker.name, EVENT_SKILL_XP_UPDATE)
	EVENT_MANAGER:UnregisterForEvent(PotMaker.name, EVENT_END_CRAFTING_STATION_INTERACT)
end

function PotMaker.craftCompleted(craftSkill)
	local identifier = "CRAFT_COMPLETED_REFRESH_RESULTLIST"
	local function refreshResultList()
		EVENT_MANAGER:UnregisterForUpdate(identifier)
		-- Still at station?
		if PotMaker.atAlchemyStation then
			local ALCHEMY = IsInGamepadPreferredMode() and GAMEPAD_ALCHEMY or ALCHEMY
			if ALCHEMY.inventory.dirty then
				ALCHEMY.inventory:PerformFullRefresh()
			end
			ALCHEMY:UpdateTooltip()
			PotMaker.updateInventory()
			-- refresh traits icon on result page
			if PotMaker.refreshTraits() then
				PotMaker.restartSearch()
			end
		end
	end
	EVENT_MANAGER:UnregisterForUpdate(identifier)
	EVENT_MANAGER:RegisterForUpdate(identifier, 200, refreshResultList)
end

function PotMaker.slotUpdated(eventCode, bagId, slotIndex, ...)
	local craftingType, subItemType = GetItemCraftingInfo(bagId, slotIndex)
	if craftingType == CRAFTING_TYPE_ALCHEMY then
		PotMaker.updateInventory()
		if PotMaker.resultListShown then
			PotMaker.restartSearch()
		end
	end
end

function PotMaker.updateInventory()
	for _, reagent in pairs(PotMaker.Inventory.reagents) do
		reagent:ResetStack()
	end
	for _, solvent in pairs(PotMaker.Inventory.solvents) do
		solvent:ResetStack()
	end
	PotMaker.updateStuffofInventory()
	PotMaker.updateControls()
end

function PotMaker:OnSkillXP(skillType, skillIndex, previousXP, currentXP)
	-- // when gain xp via crafting
	local name, rank = GetSkillLineInfo(skillType, skillIndex)
	local gainXP = currentXP - previousXP

	CENTER_SCREEN_ANNOUNCE:QueueMessage(EVENT_SKILL_XP_UPDATE, CSA_EVENT_SMALL_TEXT, SOUNDS.QUEST_OBJECTIVE_INCREMENT, zo_strformat("<<1>> <<2>> = <<3>>", PotMaker.language.skill, COLOR_KHRILLSELECT:Colorize(zo_strformat(SI_TOOLTIP_ITEM_NAME, name)), COLOR_KHRILLSELECT:Colorize(zo_strformat("+<<1>>xp", gainXP))))
end

function PotMaker.checkAll(checkButton, isChecked)
	local labelControl = PotionMakerAllMustNotCheckBoxText
	if isChecked then
		labelControl:SetText(PotMaker.language.uncheck_all)
	else
		labelControl:SetText(PotMaker.language.check_all)
	end
	for _, checkBox in pairs(PotMaker.MustNotFilterControls) do
		PotMaker.SetToggleButton(checkBox, isChecked)
	end
end

function PotMaker.checkButtonClicked(checkButton, isChecked)
	local label = checkButton:GetNamedChild("Text")
	if not label then return end
	if isChecked then
		label:SetColor(COLOR_KHRILLSELECT:UnpackRGB())
	else
		label:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL))
	end
end

function PotMaker.showTraitTip(resultButton, state)
	if state then
		if IsScreenRightHalf(resultButton) then
			InitializeTooltip(InformationTooltip, resultButton, TOPRIGHT, 0, 0, BOTTOMLEFT)
		else
			InitializeTooltip(InformationTooltip, resultButton, BOTTOMLEFT, 0, 0, TOPRIGHT)
		end
		if resultButton.GetColor then
			SetTooltipText(InformationTooltip, resultButton.Trait, resultButton:GetColor())
		else
			SetTooltipText(InformationTooltip, zo_strformat(SI_TOOLTIP_ITEM_NAME, resultButton.trait.name), ZO_NORMAL_TEXT)
		end
	else
		ClearTooltip(InformationTooltip)
	end
end

function PotMaker.showReagentTip(sender, state)
	if state then
		for _, p in pairs(sender.reagent.pack) do
			local _, stack = GetItemInfo(p.bagId, p.slotIndex)
			if stack > 0 then
				if IsScreenRightHalf(sender) then
					InitializeTooltip(ItemTooltip, sender, TOPRIGHT, -10, -96, TOPLEFT)
				else
					InitializeTooltip(ItemTooltip, sender, TOPLEFT, 10, -96, TOPRIGHT)
				end
				ItemTooltip:SetBagItem(p.bagId, p.slotIndex)
				return
			end
		end
		if PotionMakerSavedVariables.useUnknown then
			if IsScreenRightHalf(sender) then
				InitializeTooltip(PotionMakerTooltip, sender, TOPRIGHT, -10, -96, TOPLEFT)
			else
				InitializeTooltip(PotionMakerTooltip, sender, TOPLEFT, 10, -96, TOPRIGHT)
			end
			PotionMakerTooltip:SetLink(PotMaker.allReagents[sender.reagent.name].itemLink)
		else
			if IsScreenRightHalf(sender) then
				InitializeTooltip(ItemTooltip, sender, TOPRIGHT, -10, -96, TOPLEFT)
			else
				InitializeTooltip(ItemTooltip, sender, TOPLEFT, 10, -96, TOPRIGHT)
			end
			ItemTooltip:SetForceTooltipNotStolen(true)
			ZO_ItemIconTooltip_OnAddGameData(ItemTooltip, TOOLTIP_GAME_DATA_ITEM_ICON, sender.reagent.icon)
			ItemTooltip:AddHeaderLine(zo_strformat(SI_ITEM_FORMAT_STR_TEXT1, GetString(SI_ITEMTYPE31)), "ZoFontWinT2", 1, TOOLTIP_HEADER_SIDE_LEFT, ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
			ItemTooltip:AddHeaderLine(zo_strformat(SI_ITEM_FORMAT_STR_SPECIFIC_TYPE, GetString(SI_GAMEPADITEMCATEGORY0)), "ZoFontWinT2", 2, TOOLTIP_HEADER_SIDE_LEFT, ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
			ItemTooltip:AddVerticalPadding(14)
			AddLineTitle(ItemTooltip, zo_strformat(SI_TOOLTIP_ITEM_NAME, sender.reagent.name), GetItemQualityColor(2))
			ItemTooltip:AddVerticalPadding(-9)
			ZO_Tooltip_AddDivider(ItemTooltip)
		end
	else
		ClearTooltip(ItemTooltip)
		ClearTooltip(PotionMakerTooltip)
	end
end

function PotMaker.Potion:SetToolTip(resultButton)
	if self.name == "" then
		if IsScreenRightHalf(resultButton) then
			InitializeTooltip(InformationTooltip, resultButton, RIGHT, -32, 0, LFFT)
		else
			InitializeTooltip(InformationTooltip, resultButton, LEFT, 32, 0, RIGHT)
		end
		InformationTooltip:ClearLines()
		local potion = resultButton.potion
		AddLineTitle(InformationTooltip, potion:getPotionNameString())
		InformationTooltip:AddVerticalPadding(-9)
		ZO_Tooltip_AddDivider(InformationTooltip)

		AddLineSubTitle(InformationTooltip, GetString(SI_PROVISIONER_INGREDIENTS_HEADER))
		local color = GetItemQualityColor(2)
		for i = 1, #potion.ingredients do
			local amount = potion.ingredients[i].stack
			AddLineCenter(InformationTooltip, zo_strformat("<<1>> (<<2>>)", color:Colorize(zo_strformat(SI_TOOLTIP_ITEM_NAME, potion.ingredients[i].name)), amount))
		end
		AddLineSubTitle(InformationTooltip, GetString(SI_CRAFTING_COMPONENT_TOOLTIP_TRAITS))
		for _, v in pairs(potion.traits) do
			if v ~= nil then
				local effect = string.sub(v, -1)
				local color = PotMaker.traitColor[effect]
				if color then
					AddLineCenter(InformationTooltip, color:Colorize(v:sub(1, -2)))
				end
			end
		end
	else
		if IsScreenRightHalf(resultButton) then
			InitializeTooltip(PotionMakerTooltip, resultButton, RIGHT, -32, 0, LEFT)
		else
			InitializeTooltip(PotionMakerTooltip, resultButton, LEFT, 32, 0, RIGHT)
		end
		PotionMakerTooltip:SetLink(self.itemLink)
	end
end

function PotMaker.showPotionTip(resultButton, state)
	if state then
		resultButton.potion:SetToolTip(resultButton)
	else
		ClearTooltip(InformationTooltip)
		ClearTooltip(PotionMakerTooltip)
	end
end

function PotMaker.searchAgain()
	PotMaker.resultsMaxIndex = 0
	ClearResultList()
	ShowFilterPage()
	PotMaker.updateControls()
end

function PotMaker.previous()
	PotMaker.resultsMaxIndex = PotMaker.resultsMaxIndex - pageSize
	PotMaker.RenderPage()
end

function PotMaker.next()
	PotMaker.resultsMaxIndex = PotMaker.resultsMaxIndex + pageSize
	PotMaker.RenderPage()
end

function PotMaker.findFavorites()
	local function showFavoriteReagents(potion)
		return PotionMakerSavedFavorites[potion.itemId] ~= nil
	end
	local function showFavoritePotion(potion)
		return PotMaker.samePotions[potion.samePotionId] ~= nil
	end
	local function showFavoriteTraits(potion)
		return PotMaker.sameTraits[potion.sameTraitsId] ~= nil
	end

	PotMaker.resultsMaxIndex = 0
	PotMaker.onlyReagentFilter = false
	PotMaker.potion2ReagentFilter = false
	PotMaker.questPotionsOnly = false
	PotMaker.favoritesOnly = true
	PotionMakerOutput.title:SetText(PotMaker.language.favorites)

	if PotionMakerSavedVariables.showInFavorites == "TRAITS" then
		PotMaker.favoriteFilter = showFavoriteTraits
	elseif PotionMakerSavedVariables.showInFavorites == "POTION" then
		PotMaker.favoriteFilter = showFavoritePotion
	else
		PotMaker.favoriteFilter = showFavoriteReagents
	end

	PotMaker.quests = ""

	PotMaker.restartSearch()
end

local function ParseQuest(quest)

	---- for Japanese Translation ----
	if PotMaker.language.name == "jp" then
		return quest;
	end

	-- UTF8 of &nbsp; french has it. It is breaking ANSI string.find
	quest = quest:gsub("\194\160", " ")
	if PotMaker.language.name == "fr" then
		local article, level, type = quest:match("Preparez (un.*)%s(%S+)%sde [Rr]avage de (.+):")
		if article then
			quest = zo_strjoin(nil, quest, " ", zo_strformat(SI_TOOLTIP_ITEM_NAME, quest), " Ravage de ", zo_strtrim(type), " d’", article, " ", zo_strformat("<<C:1>>", level), " De ")
			return quest
		end
	end
	quest = zo_strjoin(nil, quest, " ", zo_strformat(SI_TOOLTIP_ITEM_NAME, quest))

	return quest
end

local function InternalStartSearch(quests)

	PotMaker.quests = #quests > 8 and quests:gsub("Esssenz", "Essenz") or ""
	PotMaker.resultsMaxIndex = 0
	PotionMakerOutput.title:SetText(PotMaker.language.search_results)
	PotMaker.restartSearch()
end

local function GetQuests()
	local numSteps, numConditions, questIndex, _
	local questType, activeStepText, stepOverrideText, stepIndex, conditionText
	local quests = { }
	-- quest text lines
	for questIndex = 1, MAX_JOURNAL_QUESTS do
		if IsValidQuestIndex(questIndex) then
			questType = GetJournalQuestType(questIndex)
			if questType == QUEST_TYPE_CRAFTING then
				_, _, activeStepText, _, stepOverrideText = GetJournalQuestInfo(questIndex)

				numSteps = GetJournalQuestNumSteps(questIndex)
				for stepIndex = 1, numSteps do
					numConditions = GetJournalQuestNumConditions(questIndex, stepIndex)
					if numConditions == 0 then
						quests[#quests + 1] = ParseQuest(stepOverrideText)
					else
						for conditionIndex = 1, numConditions do
							conditionText = GetJournalQuestConditionInfo(questIndex, stepIndex, conditionIndex)
							if conditionText ~= nil and conditionText ~= "" then
								quests[#quests + 1] = ParseQuest(conditionText)
							end
						end
					end
				end
			end
		end
	end
	-- Last char in text must be non-letter
	quests[#quests + 1] = " "
	-- combine them at once
	quests = table.concat(quests, " ")

	return quests
end

function PotMaker.startSearch()
	PotMaker.onlyReagentFilter = ZO_CheckButton_IsChecked(PotionMakerOnlyReagent)
	PotMaker.potion2ReagentFilter = ZO_CheckButton_IsChecked(PotionMakerOnly2)
	PotMaker.questPotionsOnly = ZO_CheckButton_IsChecked(PotionMakerQuestPotions)
	PotMaker.favoritesOnly = false
	local quests = PotMaker.questPotionsOnly and GetQuests() or ""
	InternalStartSearch(quests)
end

function PotMaker.restartSearch()
	local filters = { }
	local filterSolvents = { }
	local filterReagent = { }
	local allPoison = PotMaker.solventMode == ITEMTYPE_POISON_BASE

	if not PotMaker.questPotionsOnly and(not PotMaker.favoritesOnly or PotionMakerSavedVariables.filterFavoriteByTraits) then
		for _, checkBox in pairs(PotMaker.MustFilterControls) do
			if PotMaker.ToggleButtonIsChecked(checkBox) then
				filters[checkBox.trait.name] = true
			end
		end
		for _, checkBox in pairs(PotMaker.MustNotFilterControls) do
			if PotMaker.ToggleButtonIsChecked(checkBox) then
				filters[checkBox.trait.name] = allPoison
			end
		end
	end

	local count = 0
	if not PotMaker.questPotionsOnly and(not PotMaker.favoritesOnly or PotionMakerSavedVariables.filterFavoriteBySolvents) then
		for _, checkBox in pairs(PotMaker.SolventFilterControls) do
			if not checkBox:IsControlHidden() and PotMaker.ToggleButtonIsChecked(checkBox) then
				filterSolvents[checkBox.solvent.name] = true
				count = count + 1
			end
		end
	elseif PotMaker.questPotionsOnly then
		for _, checkBox in pairs(PotMaker.SolventFilterControls) do
			if not checkBox:IsControlHidden() then
				local pack = checkBox.solvent.pack[1]
				if pack then
					filterSolvents[checkBox.solvent.name] = true
					count = count + 1
				end
			end
		end
	end
	if count == 0 then
		for _, checkBox in pairs(PotMaker.SolventFilterControls) do
			if not checkBox:IsControlHidden() then
				filterSolvents[checkBox.solvent.name] = true
				count = count + 1
			end
		end
	end
	if count == 0 then
		filterSolvents[""] = true
	end

	local count = 0
	if not PotMaker.questPotionsOnly and(not PotMaker.favoritesOnly or PotionMakerSavedVariables.filterFavoriteByReagents) then
		for _, checkBox in pairs(PotMaker.ReagentFilterControls) do
			if not checkBox:IsControlHidden() and PotMaker.ToggleButtonIsChecked(checkBox) then
				filterReagent[checkBox.reagent.name] = true
				count = count + 1
			end
		end
	end
	if count == 0 and(not PotMaker.onlyReagentFilter or(PotMaker.favoritesOnly and not PotionMakerSavedVariables.filterFavoriteByReagents)) then
		for _, checkBox in pairs(PotMaker.ReagentFilterControls) do
			if not checkBox:IsControlHidden() then
				filterReagent[checkBox.reagent.name] = true
				count = count + 1
			end
		end
	end
	filterReagent["count"] = count
	PotMaker.findDoablePotions(filters, filterSolvents, filterReagent)
end
function PotMaker.RenderPage()
	PotMaker:SetSelected(nil)
	local WINDOW_MANAGER = WINDOW_MANAGER
	if #PotMaker.doablePotions > PotMaker.resultsMaxIndex + pageSize then
		PotionMakerOutputNextButton:SetEnabled(true)
	else
		PotionMakerOutputNextButton:SetEnabled(false)
	end
	if PotMaker.resultsMaxIndex > 0 then
		PotionMakerOutputPreviousButton:SetEnabled(true)
	else
		PotionMakerOutputPreviousButton:SetEnabled(false)
	end
	if PotMaker.resultsMaxIndex == 0 and #PotMaker.doablePotions <= pageSize then
		PotionMakerOutputPageLabel:SetHidden(true)
	else
		PotionMakerOutputPageLabel:SetText(zo_strjoin(" / ", COLOR_KHRILLSELECT:Colorize(tostring(math.floor(PotMaker.resultsMaxIndex / pageSize) + 1)), math.floor((#PotMaker.doablePotions - 1) / pageSize) + 1))
		PotionMakerOutputPageLabel:SetHidden(false)
	end

	local uniqueNamePrefix = "PotionMakerResult"
	local resultList = PotionMakerOutputResultsBG
	local control
	for i = 1, resultList:GetNumChildren() do
		control = resultList:GetChild(i)
		if control ~= nil then
			control:SetHidden(true)
			control.potion = nil
		end
	end
	PotionMakerOutput:SetHidden(false)
	PotionMaker:SetHidden(true)
	PotMaker.resultListShown = true

	if #PotMaker.doablePotions == 0 then return end

	local resultLineOffsetX = 10
	local resultLineOffsetY = 4
	local count
	local favControl, index, uniqueName
	local traitColor, traitTexture, traitName
	local allReagents = PotMaker.allReagents

	local startIndex = math.min(PotMaker.resultsMaxIndex, #PotMaker.doablePotions) + 1
	local endIndex = math.min(PotMaker.resultsMaxIndex + pageSize, #PotMaker.doablePotions)
	for i = startIndex, endIndex do
		local v = PotMaker.doablePotions[i]
		index = i - PotMaker.resultsMaxIndex
		control = GetControl(uniqueNamePrefix, index)

		if control == nil then
			control = CreateControlFromVirtual(uniqueNamePrefix .. index, PotionMakerOutputResultsBG, "PotionMakerResult")
			favControl = control:GetNamedChild("Favorite")
			favControl:SetTexture(TEXTURE_FAVORITE)
		else
			control:SetHidden(false)
		end

		-- display icon traits
		for count = 1, 4 do
			local traitControl = control:GetNamedChild(PotMaker.traitControlNames[count])
			traitControl.Trait = nil
			traitControl:SetHidden(true)
		end
		for count = 1, 3 do
			local reagentControl = control:GetNamedChild(PotMaker.reagentControlNames[count])
			reagentControl:SetHidden(true)
			reagentControl.reagent = nil
		end
		count = 1
		table.sort(v.traits)
		for n = 1, #v.traits do
			local t = v.traits[n]
			if t then
				local effect = ""
				traitName = t:gsub("[%-%+%*%/]$", function(m) effect = m return "" end)
				traitColor = PotMaker.traitColor[effect]
				if traitColor ~= nil then
					-- check unknown traits (icon==nil)
					traitTexture = nil
					local known = false
					for _, ingredient in pairs(v.ingredients) do
						if allReagents[ingredient.name] ~= nil and allReagents[ingredient.name].traits[traitName] ~= nil then
							if ingredient.iconTraits[traitName] == nil and not allReagents[ingredient.name].traits[traitName] then
								traitTexture = TEXTURE_TRAITUNKNOWN
							else
								known = true
								if traitTexture == nil then traitTexture = ingredient.iconTraits[traitName] end
							end
						end
					end

					local traitControl = control:GetNamedChild(PotMaker.traitControlNames[count])
					traitControl.Trait = traitName
					traitControl:SetColor(traitColor:UnpackRGB())
					traitControl:SetTexture(traitTexture or(known and TEXTURE_REAGENTUNKNOWN) or TEXTURE_TRAITUNKNOWN)
					traitControl:SetHidden(false)
					count = count + 1
				end
			end
		end

		-- display ingredients
		control:SetSimpleAnchorParent(resultLineOffsetX, resultLineOffsetY +((control:GetHeight()) *(index - 1)))

		for j = 1, #v.ingredients do
			local reagentControl = control:GetNamedChild(PotMaker.reagentControlNames[j])
			reagentControl:SetTexture(v.ingredients[j].icon)
			reagentControl:SetHidden(false)
			reagentControl:SetColor((v.ingredients[j].protected and STAT_LOWER_COLOR or COLOR_USEABLE):UnpackRGB())

			reagentControl.reagent = v.ingredients[j]
		end
		control:GetNamedChild("Text"):SetText(v:getIngredientString())
		control:GetNamedChild("InBag"):SetText(v:getInBagString())

		favControl = control:GetNamedChild("Favorite")
		local hidden = true
		if PotionMakerSavedFavorites[v.itemId] then
			hidden = false
			favControl:SetColor(PotMaker.favoriteColor.REAGENTS:UnpackRGB())
		elseif PotMaker.samePotions[v.samePotionId] then
			hidden = false
			favControl:SetColor(PotMaker.favoriteColor.POTION:UnpackRGB())
		elseif PotMaker.sameTraits[v.sameTraitsId] then
			hidden = false
			favControl:SetColor(PotMaker.favoriteColor.TRAITS:UnpackRGB())
		end
		favControl:SetHidden(hidden)

		control.potion = v
		PotMaker.ResultControls[index] = control
	end
end

function PotMaker.refreshTraits()
	local traitColor, traitTexture, traitName
	local resultList = PotionMakerOutputResultsBG
	local GetItemInfo = GetItemInfo

	for i = 1, resultList:GetNumChildren() do
		local control = resultList:GetChild(i)
		if control.potion then
			local v = control.potion

			local count = 1
			for _, t in pairs(v.traits) do
				if t ~= nil then
					traitName = t:sub(1, -2)
					local effect = string.sub(t, -1)
					traitColor = PotMaker.traitColor[effect]
					if traitColor ~= nil then
						traitTexture = nil
						for _, ingredient in pairs(v.ingredients) do
							-- update traits (if discover new one)
							for _, k1 in pairs(PotMaker.Inventory.reagents) do
								if k1.name == ingredient.name then
									ingredient.traits = k1.traits
									ingredient.iconTraits = k1.iconTraits
									break
								end
							end

							-- check unknown traits (icon==nil)
							if PotMaker.allReagents[ingredient.name] ~= nil and PotMaker.allReagents[ingredient.name].traits[traitName] ~= nil then
								if ingredient.iconTraits[traitName] == nil and not PotMaker.allReagents[ingredient.name].traits[traitName] then
									traitTexture = TEXTURE_TRAITUNKNOWN
								else
									if traitTexture == nil then traitTexture = ingredient.iconTraits[traitName] end
								end
							end
						end
						local traitControl = control:GetNamedChild(PotMaker.traitControlNames[count])
						traitControl.Trait = traitName
						traitControl:SetColor(traitColor:UnpackRGB())
						traitControl:SetTexture(traitTexture or TEXTURE_TRAITUNKNOWN)
						traitControl:SetHidden(false)
						count = count + 1
					end
					local amount = 0
					if v.solvent ~= nil then
						for _, p in pairs(v.solvent.pack) do
							local _, stack = GetItemInfo(p.bagId, p.slotIndex)
							amount = amount + stack
						end
					end
					for _, ingredient in pairs(v.ingredients) do
						local stackSum = 0
						for _, p in pairs(ingredient.pack) do
							local _, stack = GetItemInfo(p.bagId, p.slotIndex)
							stackSum = stackSum + stack
						end
						amount = math.min(amount, stackSum)
					end
					if amount == 0 then return true end
					v.quantity = amount
					control:GetNamedChild("Text"):SetText(v:getIngredientString())
					control:GetNamedChild("InBag"):SetText(v:getInBagString())
					control:SetHidden(false)
				end
			end
		end
	end
	return false
end

do
	local function ReturnItemLink(itemLink) return itemLink end

	function PotMaker.ReagentClicked(sender, button)
		if button == MOUSE_BUTTON_INDEX_RIGHT and IsChatSystemAvailableForCurrentPlatform() and sender.reagent then
			ClearMenu()
			AddCustomMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), function() ZO_LinkHandler_InsertLink(ZO_LinkHandler_CreateChatLink(ReturnItemLink, PotMaker.allReagents[sender.reagent.name].itemLink)) end)
			ShowMenu(sender)
		end
	end
end

do
	local function ReturnItemLink(itemLink) return itemLink:gsub("|H0", "|H1") end

	function PotMaker.PotionClicked(sender, button)
		if button == MOUSE_BUTTON_INDEX_LEFT then
			PotMaker.Potion.show(sender)
		elseif button == MOUSE_BUTTON_INDEX_RIGHT and IsChatSystemAvailableForCurrentPlatform() and sender.potion and sender.potion.itemLink ~= "" then
			ClearMenu()
			AddCustomMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), function() ZO_LinkHandler_InsertLink(ZO_LinkHandler_CreateChatLink(ReturnItemLink, sender.potion.itemLink)) end)
			ShowMenu(sender)
		end
	end
end

function PotMaker.SolventClicked(sender, button)
	if button == MOUSE_BUTTON_INDEX_RIGHT and IsChatSystemAvailableForCurrentPlatform() and sender.solvent then
		ClearMenu()
		AddCustomMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), function()
			local pack = sender.solvent.pack[1]
			if pack then
				ZO_LinkHandler_InsertLink(ZO_LinkHandler_CreateChatLink(GetItemLink, pack.bagId, pack.slotIndex))
			end
		end )
		ShowMenu(sender)
	end
end

function PotMaker.updateControls()
	-- Tooltip handler
	local function TraitTipEnter(sender, ...)
		PotMaker.showTraitTip(sender, true)
	end
	local function TraitTipExit(sender, ...)
		PotMaker.showTraitTip(sender, false)
	end
	local function SolventTipEnter(sender, ...)
		for _, p in pairs(sender.solvent.pack) do
			local _, stack = GetItemInfo(p.bagId, p.slotIndex)
			if stack > 0 then
				if IsScreenRightHalf(sender) then
					InitializeTooltip(ItemTooltip, sender, TOPRIGHT, -10, -96, TOPLEFT)
				else
					InitializeTooltip(ItemTooltip, sender, TOPLEFT, 10, -96, TOPRIGHT)
				end
				ItemTooltip:SetBagItem(p.bagId, p.slotIndex)
				return
			end
		end
		if IsScreenRightHalf(sender) then
			InitializeTooltip(InformationTooltip, sender, TOPRIGHT, -10, 0, TOPLEFT)
		else
			InitializeTooltip(InformationTooltip, sender, TOPLEFT, 10, 0, TOPRIGHT)
		end
		SetTooltipText(InformationTooltip, sender.solvent.name, ZO_TOOLTIP_INSTRUCTIONAL_COLOR)
	end
	local function SolventTipExit(sender, ...)
		ClearTooltip(ItemTooltip)
		ClearTooltip(InformationTooltip)
	end
	local function ReagentTipEnter(sender, ...)
		PotMaker.showReagentTip(sender, true)
	end
	local function ReagentTipExit(sender, ...)
		PotMaker.showReagentTip(sender, false)
	end
	--
	local function updateControl(trait, posX, count)
		local traitName = trait.name
		trait.name = PotMaker.language.traitNames[traitName]
		local checkBoxName = zo_strjoin("_", "PotionMakerCheckBox", posX, count)
		local control = CreateControlFromVirtual(checkBoxName, PotionMakerSearchBG, "PotionMakerToggleButton")
		local height = control:GetHeight()
		local pos = count - 1

		control:SetSimpleAnchorParent(posX + height *(pos % 3), height * math.floor(pos / 3) + 8)
		control.Trait = trait.name
		-- For now
		control.trait = trait
		local iconControl = control:GetNamedChild("Texture")
		iconControl:SetTexture(trait.icon)
		iconControl:SetColor(ZO_NORMAL_TEXT:UnpackRGB())

		control:SetHandler("OnMouseEnter", TraitTipEnter)
		control:SetHandler("OnMouseExit", TraitTipExit)

		return control
	end

	local xPosMustFilter = 14
	local xPosMustNotFilter = xPosMustFilter + 196
	local xPosSolventFilter = xPosMustNotFilter + 196

	if #PotMaker.MustFilterControls == 0 then
		local cnt = 1
		PotMaker.MustFilterControls[cnt] = updateControl( { name = "Restore Health", icon = "esoui/art/icons/alchemy/crafting_alchemy_trait_restorehealth.dds" }, xPosMustFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustFilterControls[cnt] = updateControl( { name = "Restore Magicka", icon = "esoui/art/icons/alchemy/crafting_alchemy_trait_restoremagicka.dds" }, xPosMustFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustFilterControls[cnt] = updateControl( { name = "Restore Stamina", icon = "esoui/art/icons/alchemy/crafting_alchemy_trait_restorestamina.dds" }, xPosMustFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustFilterControls[cnt] = updateControl( { name = "Increase Armor", icon = "esoui/art/icons/alchemy/crafting_alchemy_trait_increasearmor.dds" }, xPosMustFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustFilterControls[cnt] = updateControl( { name = "Unstoppable", icon = "esoui/art/icons/alchemy/crafting_alchemy_trait_unstoppable.dds" }, xPosMustFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustFilterControls[cnt] = updateControl( { name = "Speed", icon = "esoui/art/icons/alchemy/crafting_alchemy_trait_speed.dds" }, xPosMustFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustFilterControls[cnt] = updateControl( { name = "Increase Weapon Power", icon = "esoui/art/icons/alchemy/crafting_alchemy_trait_increaseweaponpower.dds" }, xPosMustFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustFilterControls[cnt] = updateControl( { name = "Increase Spell Power", icon = "esoui/art/icons/alchemy/crafting_alchemy_trait_increasespellpower.dds" }, xPosMustFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustFilterControls[cnt] = updateControl( { name = "Weapon Crit", icon = "esoui/art/icons/alchemy/crafting_alchemy_trait_weaponcrit.dds" }, xPosMustFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustFilterControls[cnt] = updateControl( { name = "Spell Crit", icon = "esoui/art/icons/alchemy/crafting_alchemy_trait_spellcrit.dds" }, xPosMustFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustFilterControls[cnt] = updateControl( { name = "Increase Spell Resist", icon = "esoui/art/icons/alchemy/crafting_alchemy_trait_increasespellresist.dds" }, xPosMustFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustFilterControls[cnt] = updateControl( { name = "Invisible", icon = "esoui/art/icons/alchemy/crafting_alchemy_trait_invisible.dds" }, xPosMustFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustFilterControls[cnt] = updateControl( { name = "Detection", icon = "esoui/art/icons/alchemy/crafting_alchemy_trait_detection.dds" }, xPosMustFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustFilterControls[cnt] = updateControl( { name = "Sustained Restore Health", icon = "esoui/art/icons/alchemy/crafting_poison_trait_hot.dds" }, xPosMustFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustFilterControls[cnt] = updateControl( { name = "Vitality", icon = "esoui/art/icons/alchemy/crafting_poison_trait_increasehealing.dds" }, xPosMustFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustFilterControls[cnt] = updateControl( { name = "Protection", icon = "esoui/art/icons/alchemy/crafting_poison_trait_protection.dds" }, xPosMustFilter, cnt)
	end

	local control
	if #PotMaker.MustNotFilterControls == 0 then
		local cnt = 1
		PotMaker.MustNotFilterControls[cnt] = updateControl( { name = "Ravage Health", icon = "esoui/art/icons/alchemy/crafting_alchemy_trait_ravagehealth.dds" }, xPosMustNotFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustNotFilterControls[cnt] = updateControl( { name = "Ravage Magicka", icon = "esoui/art/icons/alchemy/crafting_alchemy_trait_ravagemagicka.dds" }, xPosMustNotFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustNotFilterControls[cnt] = updateControl( { name = "Ravage Stamina", icon = "esoui/art/icons/alchemy/crafting_alchemy_trait_ravagestamina.dds" }, xPosMustNotFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustNotFilterControls[cnt] = updateControl( { name = "Lower Armor", icon = "esoui/art/icons/alchemy/crafting_alchemy_trait_lowerarmor.dds" }, xPosMustNotFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustNotFilterControls[cnt] = updateControl( { name = "Stun", icon = "esoui/art/icons/alchemy/crafting_alchemy_trait_stun.dds" }, xPosMustNotFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustNotFilterControls[cnt] = updateControl( { name = "Reduce Speed", icon = "esoui/art/icons/alchemy/crafting_alchemy_trait_reducespeed.dds" }, xPosMustNotFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustNotFilterControls[cnt] = updateControl( { name = "Lower Weapon Power", icon = "esoui/art/icons/alchemy/crafting_alchemy_trait_lowerweaponpower.dds" }, xPosMustNotFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustNotFilterControls[cnt] = updateControl( { name = "Lower Spell Power", icon = "esoui/art/icons/alchemy/crafting_alchemy_trait_lowerspellpower.dds" }, xPosMustNotFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustNotFilterControls[cnt] = updateControl( { name = "Lower Weapon Crit", icon = "esoui/art/icons/alchemy/crafting_alchemy_trait_lowerweaponcrit.dds" }, xPosMustNotFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustNotFilterControls[cnt] = updateControl( { name = "Lower Spell Crit", icon = "esoui/art/icons/alchemy/crafting_alchemy_trait_lowerspellcrit.dds" }, xPosMustNotFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustNotFilterControls[cnt] = updateControl( { name = "Lower Spell Resist", icon = "esoui/art/icons/alchemy/crafting_alchemy_trait_lowerspellresist.dds" }, xPosMustNotFilter, cnt)
		cnt = cnt + 1

		PotMaker.MustNotFilterControls[cnt] = updateControl( { name = "Creeping Ravage Health", icon = "esoui/art/icons/alchemy/crafting_poison_trait_dot.dds" }, xPosMustNotFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustNotFilterControls[cnt] = updateControl( { name = "Defile", icon = "esoui/art/icons/alchemy/crafting_poison_trait_decreasehealing.dds" }, xPosMustNotFilter, cnt)
		cnt = cnt + 1
		PotMaker.MustNotFilterControls[cnt] = updateControl( { name = "Vulnerability", icon = "esoui/art/icons/alchemy/crafting_poison_trait_damage.dds" }, xPosMustNotFilter, cnt)
		cnt = cnt + 1

		control = CreateControlFromVirtual("PotionMakerAllMustNotCheckBox", PotionMakerSearchBG, "PotionMakerCheckBox")
		control:SetSimpleAnchorParent(xPosMustNotFilter, 40 * math.floor(cnt / 3) + 23)
		ZO_CheckButton_SetToggleFunction(control, PotMaker.checkAll)
		local labelControl = control:GetNamedChild("Text")
		labelControl:SetText(PotMaker.language.check_all)
	end

	for _, v in pairs(PotMaker.SolventFilterControls) do
		v:SetHidden(true)
	end
	-- order by level
	local tempOrder = { }
	for _, solvent in pairs(PotMaker.Inventory.solvents) do
		if solvent.stack > 0 then tempOrder[#tempOrder + 1] = solvent end
	end
	table.sort(tempOrder, function(a, b)
		if a.level == b.level then
			return a.name < b.name
		else
			return a.level < b.level
		end
	end )

	local WINDOW_MANAGER = WINDOW_MANAGER
	local index, controlName, solvent, iconControl, numControl
	local height, pos
	for index = 1, #tempOrder do
		-- place solvent in order
		controlName = "PotionMakerSolvent" .. index
		control = WINDOW_MANAGER:GetControlByName(controlName)
		if control == nil then
			control = CreateControlFromVirtual(controlName, PotionMakerSearchBG, "PotionMakerToggleButton")
			control:SetHandler("OnMouseEnter", SolventTipEnter)
			control:SetHandler("OnMouseExit", SolventTipExit)
			control:EnableMouseButton(MOUSE_BUTTON_INDEX_RIGHT, true)
			control:SetHandler("OnClicked", PotMaker.SolventClicked)
		else
			control:SetHidden(false)
		end
		solvent = tempOrder[index]
		iconControl = control:GetNamedChild("Texture")
		iconControl:SetTexture(solvent.icon)
		iconControl:SetColor((solvent.protected and STAT_LOWER_COLOR or COLOR_USEABLE):UnpackRGB())
		numControl = control:GetNamedChild("Number")
		numControl:SetText(solvent.stack)
		control.text = solvent.name
		control.solvent = solvent
		height = control:GetHeight() + 4
		pos = index - 1
		control:SetSimpleAnchorParent(xPosSolventFilter + height *(pos % 3), 8 + height * math.floor(pos / 3))
		PotMaker.SolventFilterControls[index] = control
	end

	-- reinit reagent display
	for i = 1, PotionMakerReagentBG:GetNumChildren() do
		PotionMakerReagentBG:GetChild(i):SetHidden(true)
	end

	-- display reagent from inventory
	-- order by name first
	local tempOrder = { }
	for _, ingredient in pairs(PotMaker.Inventory.reagents) do
		tempOrder[#tempOrder + 1] = ingredient
	end
	-- order by name (or by stack if option)
	if PotionMakerSavedVariables.reagentStackOrder then
		table.sort(tempOrder, function(a, b)
			if a.stack == b.stack then
				return a.name < b.name
			else
				return a.stack > b.stack
			end
		end )
	else
		table.sort(tempOrder, function(a, b) return a.name < b.name end)
	end

	local index
	for index = 1, #tempOrder do
		-- place ingredient in order
		controlName = "PotionMakerReagent" .. index
		control = WINDOW_MANAGER:GetControlByName(controlName)
		if control == nil then
			control = CreateControlFromVirtual(controlName, PotionMakerReagentBG, "PotionMakerReagent")
			control:SetHandler("OnMouseEnter", ReagentTipEnter)
			control:SetHandler("OnMouseExit", ReagentTipExit)

			control:EnableMouseButton(MOUSE_BUTTON_INDEX_RIGHT, true)
			control:SetHandler("OnClicked", PotMaker.ReagentClicked)
		else
			control:SetHidden(false)
		end
		local ingredient = tempOrder[index]
		control:SetSimpleAnchorParent(16 + 40 *((index - 1) % 9), 5 +(control:GetHeight() + 2) * math.floor((index - 1) / 9))
		control.reagent = ingredient
		iconControl = control:GetNamedChild("Texture")
		iconControl:SetTexture(ingredient.stack > 0 and ingredient.icon or TEXTURE_REAGENTUNKNOWN)
		iconControl:SetColor((ingredient.protected and STAT_LOWER_COLOR or COLOR_USEABLE):UnpackRGB())
		numControl = control:GetNamedChild("Number")
		numControl:SetText(ingredient.stack)
		PotMaker.ReagentFilterControls[index] = control
	end
end

function PotMaker.close()
	PotMaker.StopJobs()
	collectgarbage()
	ClearInventory()
	ClearTooltips()
	ClearResultList()
end

function PotMaker:SetSelected(potion)
	self.selected = potion
	local hidden = potion == nil or potion.itemLink == ""
	PotionMakerOutputFavorite:SetHidden(hidden)
	if not hidden then
		if PotionMakerSavedFavorites[potion.itemId] ~= nil then
			PotionMakerOutputFavorite:SetText(PotMaker.language.unmark_favorite)
		else
			PotionMakerOutputFavorite:SetText(PotMaker.language.mark_favorite)
		end
	end
end

function PotMaker:ToggleFavorite()
	local potion = self.selected
	if potion == nil then return end
	if PotionMakerSavedFavorites[potion.itemId] ~= nil then
		PotionMakerSavedFavorites[potion.itemId] = nil
	else
		PotionMakerSavedFavorites[potion.itemId] = { samePotion = potion.samePotionId, sameTraits = potion.sameTraitsId }
	end
	PotMaker.initFavorites()
	PotMaker.RenderPage()
	self:SetSelected(potion)
end


---- Init stuff ----

function PotMaker.initWindows()

	---- for Japanese Translation ----
	if PotMaker.language.name == "jp" then
		local fontCommonSettings = "$(CHAT_FONT)|18|soft-shadow-thin"
		PotionMakerSearchButton:SetFont(fontCommonSettings)
		PotionMakerOutputCombinationLabel:SetFont(fontCommonSettings)
		PotionMakerOutputTraitLabel:SetFont(fontCommonSettings)
		PotionMakerOutputSearchButton:SetFont(fontCommonSettings)
		PotionMakerMustLabel:SetFont(fontCommonSettings)
		PotionMakerMustNotLabel:SetFont(fontCommonSettings)
		PotionMakerSolventLabel:SetFont(fontCommonSettings)
		PotionMakerReagentLabel:SetFont(fontCommonSettings)
		PotionMakerOnlyReagentText:SetFont(fontCommonSettings)
		PotionMakerOnly2Text:SetFont(fontCommonSettings)
		PotionMakerQuestPotionsText:SetFont(fontCommonSettings)
		PotionMakerFavorites:SetFont(fontCommonSettings)
		PotionMakerOutputFavorite:SetFont(fontCommonSettings)
		PotionMakerOutputPageLabel:SetFont(fontCommonSettings)

		ZO_CreateStringId("SI_BINDING_NAME_POTIONMAKER", PotMaker.language.descriptorPotion)
		ZO_CreateStringId("SI_BINDING_NAME_POISONMAKER", PotMaker.language.descriptorPoison)
	end
	---- for Japanese Translation end ----

	PotionMakerBagButtonTexture:SetTexture(TEXTURE_BAG)
	PotionMakerBagButtonTexture:SetMouseEnabled(true)
	PotionMakerBagButtonTexture:SetHandler("OnMouseUp", PotMaker.toggleBag)
	PotionMakerBankButtonTexture:SetTexture(TEXTURE_BANK)
	PotionMakerBankButtonTexture:SetMouseEnabled(true)
	PotionMakerBankButtonTexture:SetHandler("OnMouseUp", PotMaker.toggleBank)

	PotionMakerOutput.title = PotionMakerLabel
	PotionMakerOutputCombinationLabel:SetText(PotMaker.language.combinations)
	PotionMakerOutputTraitLabel:SetText(GetString(SI_CRAFTING_COMPONENT_TOOLTIP_TRAITS))

	PotionMakerTopLevel:SetHidden(true)

	PotionMakerSearchButton:SetText(PotMaker.language.search)

	PotionMakerSearchButton:SetHandler("OnClicked", function(...) zo_callLater(PotMaker.startSearch, 100) end)
	PotionMakerOutputSearchButton:SetText(PotMaker.language.search_again)
	PotionMakerOutputSearchButton:SetHandler("OnClicked", function(...) zo_callLater(PotMaker.searchAgain, 100) end)
	PotionMakerMustLabel:SetText(PotMaker.language.must_have)
	PotionMakerSolventLabel:SetText(GetString(SI_ALCHEMY_SOLVENT_HEADER))
	PotionMakerReagentLabel:SetText(GetString(SI_ALCHEMY_REAGENTS_HEADER))
	PotionMakerOnlyReagentText:SetText(PotMaker.language.only)
	ZO_CheckButton_SetToggleFunction(PotionMakerOnlyReagent, PotMaker.checkButtonClicked)
	PotionMakerOnly2Text:SetText(PotMaker.language.potion2reagents)
	ZO_CheckButton_SetToggleFunction(PotionMakerOnly2, PotMaker.checkButtonClicked)
	PotionMakerQuestPotionsText:SetText(PotMaker.language.questpotionsonly)
	ZO_CheckButton_SetToggleFunction(PotionMakerQuestPotions, PotMaker.checkButtonClicked)
	PotionMakerTooltip:SetParent(PopupTooltipTopLevel)
	PotionMakerOutputNextButton:SetHandler("OnClicked", function(...) zo_callLater(PotMaker.next, 100) end)
	PotionMakerOutputPreviousButton:SetHandler("OnClicked", function(...) zo_callLater(PotMaker.previous, 100) end)

	PotionMakerFavorites:SetText(PotMaker.language.favorites)
	PotionMakerFavorites:SetHandler("OnClicked", function(...) zo_callLater(PotMaker.findFavorites, 100) end)
	local control = PotionMakerOutputFavorite
	control:SetText(PotMaker.language.mark_favorite)
	control:SetHandler("OnClicked", function() PotMaker:ToggleFavorite() end)
	control:SetHidden(true)

	control = WINDOW_MANAGER:CreateControlFromVirtual("PotionMakerLoading", PotionMakerOutput, "ZO_Loading")
	control:SetAnchor(CENTER)
	ZO_Loading_Initialize(control, "")
	PotMaker.loading = control

	-- initial update --
	PotMaker.updateControls()
end

function PotMaker.initMainMenu()
	local descriptor = PotMaker.name
	local sceneName = PotMaker.name
	POTIONMAKER_SCENE = ZO_Scene:New(sceneName, SCENE_MANAGER)

	POTIONMAKER_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
	POTIONMAKER_SCENE:AddFragment(RIGHT_PANEL_BG_FRAGMENT)

	POTIONMAKER_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_MAP)
	POTIONMAKER_SCENE:AddFragment(ZO_WindowSoundFragment:New(SOUNDS.ALCHEMY_OPENED, SOUNDS.ALCHEMY_CLOSED))

	POTIONMAKER_FRAGMENT = ZO_FadeSceneFragment:New(PotionMakerTopLevel, false, 0)
	POTIONMAKER_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_FRAGMENT_SHOWING then
			EVENT_MANAGER:RegisterForEvent(PotMaker.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, PotMaker.slotUpdated)
			ShowStationOrTopLevel()
			PotionMakerTopLevel:SetHidden(false)
			if ZO_MenuBar_GetSelectedDescriptor(PotMaker.modeBar) ~= PotionMakerSavedVariables.lastUsedTab then
				ZO_MenuBar_SelectDescriptor(PotMaker.modeBar, PotionMakerSavedVariables.lastUsedTab or PotMaker.descriptorPotion)
			else
				PotMaker.addStuffToInventory()
			end
		elseif newState == SCENE_FRAGMENT_SHOWN then
			RefreshTitle()
			RefreshCurrentPage()
		elseif newState == SCENE_FRAGMENT_HIDING then
			EVENT_MANAGER:UnregisterForEvent(PotMaker.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
			ClearTooltips()
		elseif newState == SCENE_FRAGMENT_HIDDEN then
			if not PotMaker.resultListShown then
				ClearResultList()
				ClearInventory()
			end
			PotionMakerTopLevel:SetHidden(true)
		end
	end )
	POTIONMAKER_SCENE:AddFragment(POTIONMAKER_FRAGMENT)

	SCENE_MANAGER:AddSceneGroup("PotionMakerSceneGroup", ZO_SceneGroup:New(descriptor))

	PotMaker.modeBar = PotionMakerTopLevel:GetNamedChild("ModeMenuBar")
	PotMaker.modeBarLabel = PotMaker.modeBar:GetNamedChild("Label")

	local function Potions()
		local creationData = {
			activeTabText = SI_BINDING_NAME_POTIONMAKER,
			categoryName = SI_BINDING_NAME_POTIONMAKER,
			descriptor = PotMaker.descriptorPotion,
			normal = "esoui/art/inventory/inventory_tabicon_consumables_up.dds",
			pressed = "esoui/art/inventory/inventory_tabicon_consumables_down.dds",
			highlight = "esoui/art/inventory/inventory_tabicon_consumables_over.dds",
			disabled = "esoui/art/inventory/inventory_tabicon_consumables_disabled.dds",
			callback = function()
				PotMaker.solventMode = ITEMTYPE_POTION_BASE
				if PotMaker.atAlchemyStation or SCENE_MANAGER:IsShowing(sceneName) then
					ShowStationOrTopLevel()
					ShowFilterPage()
					PotMaker.addStuffToInventory()
					PotMaker.updateControls()
					PotionMakerSavedVariables.lastUsedTab = PotMaker.descriptorPotion
				end
			end,
		}

		ZO_MenuBar_AddButton(PotMaker.modeBar, creationData)
	end
	local function Poisons()
		local creationData = {
			activeTabText = SI_BINDING_NAME_POISONMAKER,
			categoryName = SI_BINDING_NAME_POISONMAKER,
			descriptor = PotMaker.descriptorPoison,
			normal = "PotionMaker/art/Poison_up.dds",
			pressed = "PotionMaker/art/Poison_down.dds",
			highlight = "PotionMaker/art/Poison_over.dds",
			disabled = "PotionMaker/art/Poison_disabled.dds",
			callback = function()
				PotMaker.solventMode = ITEMTYPE_POISON_BASE
				if PotMaker.atAlchemyStation or SCENE_MANAGER:IsShowing(sceneName) then
					ShowStationOrTopLevel()
					ShowFilterPage()
					PotMaker.addStuffToInventory()
					PotMaker.updateControls()
					PotionMakerSavedVariables.lastUsedTab = PotMaker.descriptorPoison
				end
			end,
		}

		ZO_MenuBar_AddButton(PotMaker.modeBar, creationData)
	end

	Potions()
	Poisons()

	LMM2 = LibStub("LibMainMenu-2.0")
	LMM2:Init()

	-- Add to main menu
	local categoryLayoutInfo =
	{
		binding = "POTIONMAKER",
		categoryName = SI_BINDING_NAME_POTIONMAKER,
		callback = function(buttonData)
			if not SCENE_MANAGER:IsShowing(sceneName) then
				SCENE_MANAGER:Show(sceneName)
			else
				SCENE_MANAGER:ShowBaseScene()
			end
		end,
		visible = function(buttonData) return PotionMakerSavedVariables.showMainMenuItem end,

		normal = "esoui/art/inventory/inventory_tabicon_consumables_up.dds",
		pressed = "esoui/art/inventory/inventory_tabicon_consumables_down.dds",
		highlight = "esoui/art/inventory/inventory_tabicon_consumables_over.dds",
		disabled = "esoui/art/inventory/inventory_tabicon_consumables_disabled.dds",
	}

	LMM2:AddMenuItem(descriptor, sceneName, categoryLayoutInfo, nil)
	GAMEPAD_ALCHEMY_ROOT_SCENE:AddFragment(RIGHT_PANEL_BG_FRAGMENT)
	GAMEPAD_ALCHEMY_ROOT_SCENE:AddFragment(POTIONMAKER_FRAGMENT)

	ZO_MenuBar_SelectDescriptor(PotMaker.modeBar, PotionMakerSavedVariables.lastUsedTab or PotMaker.descriptorPotion)
end

function PotMaker.initFavorites()
	PotMaker.samePotions = { }
	PotMaker.sameTraits = { }
	for _, data in pairs(PotionMakerSavedFavorites) do
		PotMaker.samePotions[data.samePotion] = true
		PotMaker.sameTraits[data.sameTraits] = true
	end
end

function PotMaker.initSettingsMenu()
	-- // Settings panel LAM2
	local LAM2 = LibStub("LibAddonMenu-2.0")
	if (not LAM2) then return end

	local ADDON_NAME = "Potion Maker"
	-- .." |cFF6A00V4.2.0|r"
	local ADDON_VERSION = "v" .. PotMaker.version
	local panelData = {
		type = "panel",
		name = ADDON_NAME,
		displayName = zo_strjoin(nil,ADDON_NAME," (",PotMaker.language.name,")"),
		author = "|cFFFFFFfacit|r, |cFF6A00Khrill|r & |cFFFFFFvotan|r",
		version = ADDON_VERSION,
		-- slashCommand = "/potionmaker",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	LAM2:RegisterAddonPanel(ADDON_NAME, panelData)

	local optionsTable = {
		------------GENERAL--------------
		{
			-- MenuUseMissingEdit
			type = "checkbox",
			name = PotMaker.language.use_missing_reagents_short,
			tooltip = PotMaker.language.use_missing_reagents_long,
			warning = PotMaker.language.use_missing_reagents_warning,
			getFunc = function() return PotionMakerSavedVariables.useMissing end,
			setFunc = function(value) PotionMakerSavedVariables.useMissing = value end,
			width = "full",

			default = PotMaker.dataDefaults.useMissing,
		},
		{
			-- MenuUseUnknownEdit
			type = "checkbox",
			name = PotMaker.language.use_unknown_traits_short,
			tooltip = PotMaker.language.use_unknown_traits_long,
			getFunc = function() return PotionMakerSavedVariables.useUnknown end,
			setFunc = function(value)
				PotionMakerSavedVariables.useUnknown = value
				if value then PotionMakerSavedVariables.training = false end
			end,
			width = "full",

			default = PotMaker.dataDefaults.useUnknown,
		},
		{
			-- MenuTrainingEdit
			type = "checkbox",
			name = " |u12:0::|u" .. PotMaker.language.training_short,
			tooltip = PotMaker.language.training_long,
			getFunc = function() return PotionMakerSavedVariables.training and PotionMakerSavedVariables.useUnknown end,
			setFunc = function(value) PotionMakerSavedVariables.training = value end,
			width = "full",

			default = PotMaker.dataDefaults.training,
			disabled = function() return not PotionMakerSavedVariables.useUnknown end,
		},
		{
			-- MenuFakeThirdSlotEdit
			type = "checkbox",
			name = " |u12:0::|u" .. PotMaker.language.fake_third_slot_short,
			tooltip = PotMaker.language.fake_third_slot_long,
			getFunc = function() return PotionMakerSavedVariables.fakeThirdSlot end,
			setFunc = function(value) PotionMakerSavedVariables.fakeThirdSlot = value end,
			width = "full",

			default = PotMaker.dataDefaults.fakeThirdSlot,
			disabled = function() return not PotionMakerSavedVariables.useUnknown end,
		},
		{
			-- Show XP
			type = "checkbox",
			name = PotMaker.language.show_xp_short,
			tooltip = PotMaker.language.show_xp_long,
			getFunc = function() return PotionMakerSavedVariables.XPMode end,
			setFunc = function(value) PotionMakerSavedVariables.XPMode = value end,
			width = "full",

			default = PotMaker.dataDefaults.XPMode,
		},
		{
			-- Reagent Stack order
			type = "checkbox",
			name = PotMaker.language.reagent_stackorder_short,
			tooltip = PotMaker.language.reagent_stackorder_long,
			getFunc = function() return PotionMakerSavedVariables.reagentStackOrder end,
			setFunc = function(value) PotionMakerSavedVariables.reagentStackOrder = value end,
			width = "full",

			default = PotMaker.dataDefaults.reagentStackOrder,
		},
		{
			-- Show main menu item
			type = "checkbox",
			name = PotMaker.language.show_mainmenu_item_short,
			tooltip = PotMaker.language.show_mainmenu_item_long,
			getFunc = function() return PotionMakerSavedVariables.showMainMenuItem end,
			setFunc = function(value)
				PotionMakerSavedVariables.showMainMenuItem = value
				LMM2:Refresh()
			end,
			width = "full",

			default = PotMaker.dataDefaults.showMainMenuItem,
		},
		{
			-- Show main menu item
			type = "checkbox",
			name = PotMaker.language.show_as_default,
			tooltip = PotMaker.language.show_as_default_long,
			getFunc = function() return PotionMakerSavedVariables.showAsDefault end,
			setFunc = function(value) PotionMakerSavedVariables.showAsDefault = value end,
			width = "full",

			default = PotMaker.dataDefaults.showMainMenuItem,
		},

		{
			type = "header",
			name = PotMaker.language.show_favorite_header,
			width = "full",
		},
		{
			-- Show Favorite Stack order
			type = "dropdown",
			name = PotMaker.language.show_favorite_short,
			tooltip = PotMaker.language.show_favorite_long,
			choices = { PotMaker.language.show_favorite_reagents, PotMaker.language.show_favorite_potion, PotMaker.language.show_favorite_traits },
			getFunc = function()
				local value = PotionMakerSavedVariables.showInFavorites
				if value == "TRAITS" then
					value = PotMaker.language.show_favorite_traits
				elseif value == "POTION" then
					value = PotMaker.language.show_favorite_potion
				else
					value = PotMaker.language.show_favorite_reagents
				end
				return value
			end,
			setFunc = function(value)
				if value == PotMaker.language.show_favorite_traits then
					value = "TRAITS"
				elseif value == PotMaker.language.show_favorite_potion then
					value = "POTION"
				else
					value = "REAGENTS"
				end
				PotionMakerSavedVariables.showInFavorites = value
			end,
			width = "full",

			default = PotMaker.dataDefaults.showInFavorites,
		},
		{
			-- Filter Favorites By Traits
			type = "checkbox",
			name = PotMaker.language.filter_favorite_traits,
			tooltip = PotMaker.language.filter_favorite_traits_long,
			getFunc = function() return PotionMakerSavedVariables.filterFavoriteByTraits end,
			setFunc = function(value) PotionMakerSavedVariables.filterFavoriteByTraits = value end,
			width = "full",
			default = PotMaker.dataDefaults.filterFavoriteByTraits,
		},
		{
			-- Filter Favorites By Reagents
			type = "checkbox",
			name = PotMaker.language.filter_favorite_reagents,
			tooltip = PotMaker.language.filter_favorite_reagents_long,
			getFunc = function() return PotionMakerSavedVariables.filterFavoriteByReagents end,
			setFunc = function(value) PotionMakerSavedVariables.filterFavoriteByReagents = value end,
			width = "full",
			default = PotMaker.dataDefaults.filterFavoriteByReagents,
		},
		{
			-- Filter Favorites By Solvents
			type = "checkbox",
			name = PotMaker.language.filter_favorite_solvents,
			tooltip = PotMaker.language.filter_favorite_solvents_long,
			getFunc = function() return PotionMakerSavedVariables.filterFavoriteBySolvents end,
			setFunc = function(value) PotionMakerSavedVariables.filterFavoriteBySolvents = value end,
			width = "full",
			default = PotMaker.dataDefaults.filterFavoriteBySolvents,
		},
		{
			-- Suppress new trait dialog
			type = "checkbox",
			name = PotMaker.language.suppress_new_trait_dialog,
			tooltip = PotMaker.language.suppress_new_trait_dialog_long,
			getFunc = function() return PotionMakerSavedVariables.suppressNewTraitDialog end,
			setFunc = function(value) PotionMakerSavedVariables.suppressNewTraitDialog = value end,
			width = "full",
			default = PotMaker.dataDefaults.suppressNewTraitDialog,
		},
		{
			type = "header",
			name = PotMaker.language.item_saver_header,
			width = "full",
		},
		{
			-- Use (FCO)ItemSaver protection
			type = "checkbox",
			name = PotMaker.language.use_item_saver,
			tooltip = PotMaker.language.use_item_saver_long,
			getFunc = function() return(FCOIsMarked ~= nil or ItemSaver_IsItemSaved ~= nil) and PotionMakerSavedVariables.useItemSaver end,
			setFunc = function(value) PotionMakerSavedVariables.useItemSaver = value end,
			width = "full",
			default = PotMaker.dataDefaults.useItemSaver,
			disabled = function() return FCOIsMarked == nil and ItemSaver_IsItemSaved == nil end,
		},
	}

	LAM2:RegisterOptionControls(ADDON_NAME, optionsTable)
end

function PotMaker.initTraitLearned()
	local function HookDisplayDiscoveredTraits(orgDialog)
		local orgDisplayDiscoveredTraits = orgDialog.DisplayDiscoveredTraits
		orgDialog.DisplayDiscoveredTraits = function(...)
			if not PotionMakerSavedVariables.suppressNewTraitDialog then
				return orgDisplayDiscoveredTraits(...)
			end
			local numLearnedTraits = GetNumLastCraftingResultLearnedTraits()

			for i = 1, numLearnedTraits do
				local traitName, itemName, icon = GetLastCraftingResultLearnedTraitInfo(i)
				local text = zo_strjoin(nil, zo_iconFormat(icon, 32, 32), " ", zo_strformat(SI_TOOLTIP_ITEM_NAME, itemName), ": ", zo_strformat(SI_ALCHEMY_REAGENT_TRAIT_FORMATTER, traitName))
				CENTER_SCREEN_ANNOUNCE:AddMessage(EVENT_ACHIEVEMENT_AWARDED, CSA_EVENT_SMALL_TEXT, SOUNDS.QUEST_OBJECTIVE_INCREMENT, text)
			end
		end
	end
	-- HookDisplayDiscoveredTraits(GAMEPAD_CRAFTING_RESULTS)
	HookDisplayDiscoveredTraits(CRAFTING_RESULTS)
end

local function AddonLoaded(eventCode, addOnName)
	if addOnName ~= PotMaker.name then
		return
	end
	EVENT_MANAGER:UnregisterForEvent(PotMaker.name, EVENT_ADD_ON_LOADED)

	local language = GetCVar("language.2") or "en"
	PotMaker.languageSupported = PotMaker.language.name == language

	PotionMakerSavedVariables = ZO_SavedVars:New("PotionMaker_Data", 1, nil, PotMaker.dataDefaults, nil)
	local accountSettings = ZO_SavedVars:NewAccountWide("PotionMaker_Data", 1)
	if accountSettings.favorites == nil then
		accountSettings.favorites = PotionMakerSavedVariables.favorites or { }
	elseif PotionMakerSavedVariables.favorites ~= nil then
		for k, v in pairs(PotionMakerSavedVariables.favorites) do
			accountSettings.favorites[k] = v
		end
	end
	PotionMakerSavedFavorites = accountSettings.favorites
	PotionMakerSavedVariables.favorites = nil

	for id, data in pairs(PotionMakerSavedFavorites) do
		if not(data.samePotion and data.sameTraits) then
			PotionMakerSavedVariables.favorites[id] = nil
		end
	end
	PotionMakerSavedVariables.enableButton = PotionMakerSavedVariables.enableButton or false

	LAS = LibStub("LibAlchemyStation")
	LAS:Init()
	do
		local tabData = {
			name = SI_BINDING_NAME_POTIONMAKER,
			descriptor = PotMaker.descriptorPotion,
			normal = "esoui/art/inventory/inventory_tabicon_consumables_up.dds",
			pressed = "esoui/art/inventory/inventory_tabicon_consumables_down.dds",
			highlight = "esoui/art/inventory/inventory_tabicon_consumables_over.dds",
			disabled = "esoui/art/inventory/inventory_tabicon_consumables_disabled.dds",
			callback = function()
				PotMaker.solventMode = ITEMTYPE_POTION_BASE
				ShowStationOrTopLevel()
				PotMaker.addStuffToInventory()
				PotMaker.searchAgain()
				PotionMakerSavedVariables.lastUsedTab = PotMaker.descriptorPotion
			end,
		}
		PotMaker.contentWindowPotion = LAS:AddTab(tabData)
	end
	do
		local tabData = {
			name = SI_BINDING_NAME_POISONMAKER,
			descriptor = PotMaker.descriptorPoison,
			normal = "PotionMaker/art/Poison_up.dds",
			pressed = "PotionMaker/art/Poison_down.dds",
			highlight = "PotionMaker/art/Poison_over.dds",
			disabled = "PotionMaker/art/Poison_disabled.dds",
			callback = function()
				PotMaker.solventMode = ITEMTYPE_POISON_BASE
				ShowStationOrTopLevel()
				PotMaker.addStuffToInventory()
				PotMaker.searchAgain()
				PotionMakerSavedVariables.lastUsedTab = PotMaker.descriptorPoison
			end,
		}
		PotMaker.contentWindowPoison = LAS:AddTab(tabData)
	end

	PotMaker.initVar(language)
	PotMaker.initSettingsMenu()
	PotMaker.initWindows()
	PotMaker.initMainMenu()
	PotMaker.initFavorites()
	PotMaker.initTraitLearned()

	EVENT_MANAGER:RegisterForEvent(PotMaker.name, EVENT_CRAFTING_STATION_INTERACT, PotMaker.interactWithAlchemyStation)

	SLASH_COMMANDS["/potionmaker"] = TogglePotionMaker
end

EVENT_MANAGER:RegisterForEvent(PotMaker.name, EVENT_ADD_ON_LOADED, AddonLoaded)

---- Key Binding ----
function TogglePotionMaker()
	if PotMaker.atAlchemyStation then return end
	LMM2:SelectMenuItem(PotMaker.descriptorPotion)
end

---- Public API ----
function PotMaker:SelectPotionOfWrit()
	if not self.atAlchemyStation then return false end

	ZO_MenuBar_SelectDescriptor(self.modeBar, PotMaker.descriptorPotion)

	self.onlyReagentFilter = false
	self.potion2ReagentFilter = true
	self.questPotionsOnly = true
	self.favoritesOnly = false
	local writQuestDescription = GetQuests()

	if self.resultListShown then self.searchAgain() end
	InternalStartSearch(writQuestDescription)
	return true
end

do
	local function ShallowTableCopy(source, dest)
		dest = dest or { }

		for k, v in pairs(source) do
			if type(v) == "table" then
				dest[k] = ShallowTableCopy(v, dest[k])
			else
				dest[k] = v
			end
		end
		return dest
	end
	function PotMaker:LoadLanguage(translation)
		if self.language then
			self.language = ShallowTableCopy(translation, self.language)
		else
			self.language = translation
		end
	end
end

ZO_CreateStringId("SI_BINDING_NAME_POTIONMAKER", "Potion Maker")
ZO_CreateStringId("SI_BINDING_NAME_POISONMAKER", "Poison Maker")
