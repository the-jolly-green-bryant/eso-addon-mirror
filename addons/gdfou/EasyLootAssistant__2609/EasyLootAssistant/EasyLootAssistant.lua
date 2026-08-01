-- EasyLootAssistant
local EasyLootAssistant_Version = "1.5"

-- Constantes pour item.result (NE PAS MODIFER CAR UTILISER DANS LA CONFIG)
local ITEM_RESULT_NOT_PROCESSED = 0	-- pas encore traité
local ITEM_RESULT_JUNK = 1			-- à jeter
local ITEM_RESULT_KEEP = 2			-- à garder
local ITEM_RESULT_TO_DELETE = 3		-- à supprimer
local ITEM_RESULT_TO_LEARN = 4		-- à apprendre

local FORCE_BANK_TRANSFER_DEFAULT = 0
local FORCE_BANK_TRANSFER_DONT_TRANSFER = 1
local FORCE_BANK_TRANSFER_TO_BANK = 2
local FORCE_BANK_TRANSFER_FROM_BANK = 3

local BANK_TRANSFER_NO_TRANSFER = 0
local BANK_TRANSFER_TO_BANK_IF_POSSIBLE = 1
local BANK_TRANSFER_TO_BANK_FORCE = 2
local BANK_TRANSFER_FROM_BANK_FORCE = 3

local addon = {
	name = "EasyLootAssistant",
	title = "Easy Loot Assistant",
	slash_name = "easylootassistant_",
	defaults_a = -- base pour 'settings_a' -> account settings
	{
		auto_junking = {
			enabled = false,
			showChatMessage = true,
		},
		auto_selling = {
			enabled = false,
			showChatMessage = true,
		},
		auto_destroy = {
			enabled = false,
			simulation = false,
			showChatMessage = true,
		},
		price_TTC = {
			enabled = false,
			price_dont_destroy = 500, -- Limite du prix 'proposé' par TTC pour ne pas détruire automatiquement l'objet
		},
		defaultTradingHouse = {
			guildName = "Default",
		},
		backpack = {
			alarm_enabled = false,
			alarm_threshold = 5,
		},
		debug = {
			enabled = false,
			level = 0,
		},
		autoTransferToBank = {
			delayS = 1,
		},
		ItemIDExceptionList = 
		{
			[42877] = "delete",	-- appât simple
			[74728] = "keep",	-- potion roublarde
			[74729] = "keep", 	-- potion roublarde
			[77591] = "force_transfer_to_bank", -- chitine de vasard
		}
	},
	defaults_c = -- base pour 'settings_c' -> character settings
	{
		enablePrintLoot = false,
		autoTransferToBank = {
			enabled = false,
			showChatMessage = true,
			transfertFullStack = false,
		},
		search_unknown = 
		{
			enabled_loot_chat_message = false,
			enabled_search = false,
			enabled_auto_search = false,
		},
	},
	fct_delayed_start_time = 0,
	fct_delayed_stop_time = 0,
	junkReceivedList = {},
	debug_level = 0,
	unknownLockList = {},	
}

-- Define Color (utilisation Color:Colorize("")) => |cRRGGBB<text>|r
local Red       = ZO_ColorDef:New("FF0000")
local Red_1     = ZO_ColorDef:New("ff3935")
local Green     = ZO_ColorDef:New("00FF00")
local Green_1   = ZO_ColorDef:New("00CC00")
local Green_2   = ZO_ColorDef:New("01bc00")
local Blue      = ZO_ColorDef:New("0000FF")
local Blue_1    = ZO_ColorDef:New("98defb")
local Yellow    = ZO_ColorDef:New("FFFF00")
local Yellow_1  = ZO_ColorDef:New("999900")
local Cyan      = ZO_ColorDef:New("00FFFF")
local Cyan_1    = ZO_ColorDef:New("009999")
local Magenta   = ZO_ColorDef:New("FF00FF")
local White     = ZO_ColorDef:New("FFFFFF")

local PROCESS_JUNK_ONLY = true

local bagStr = 
{
	[BAG_WORN] = "WORN",
	[BAG_BACKPACK] = "BACKPACK",
	[BAG_BANK] = "BANK",
	[BAG_GUILDBANK] = "GUILDBANK",
	[BAG_BUYBACK] = "BUYBACK]",
	[BAG_VIRTUAL] = "VIRTUAL",
	[BAG_SUBSCRIBER_BANK] = "SUBSCRIBER_BANK",
	[BAG_HOUSE_BANK_ONE]   = "HOUSE_BANK_ONE",
	[BAG_HOUSE_BANK_TWO]   = "HOUSE_BANK_TWO",
	[BAG_HOUSE_BANK_THREE] = "HOUSE_BANK_THREE",
	[BAG_HOUSE_BANK_FOUR]  = "HOUSE_BANK_FOUR",
	[BAG_HOUSE_BANK_FIVE]  = "HOUSE_BANK_FIVE",
	[BAG_HOUSE_BANK_SIX]   = "HOUSE_BANK_SIX",
	[BAG_HOUSE_BANK_SEVEN] = "HOUSE_BANK_SEVEN",
	[BAG_HOUSE_BANK_EIGHT] = "HOUSE_BANK_EIGHT",
	[BAG_HOUSE_BANK_NINE]  = "HOUSE_BANK_NINE",
	[BAG_HOUSE_BANK_TEN]   = "HOUSE_BANK_TEN",
	[BAG_DELETE] = "DELETE",
}

local LCM = LibChatMessage(addon.name, addon.name)

-- DEBUG MODE / LEVEL
function addon:GetDebugLevel()
	if self.settings_a.debug.enabled == true then
		return self.settings_a.debug.level
	end
	return 0
end

function addon:SetDebugLevel()
	self.debug_level = self:GetDebugLevel()
end

local function tableLength(t)
	local count = 0
	for _ in pairs(t) do count = count + 1 end
	return count
end

local function apply_result(items, result)
	for _, it in ipairs(items) do
		it.result = result
	end
end

-- rappel . et :
-- x:bar(3,4) <==> x.bar(x,3,4)

-- Pour savoir si armure d'indomptable: GetItemLinkOutfitStyleId => IsOutfitStyleArmor => GetOutfitStyleVisualArmorType => VISUAL_ARMORTYPE_UNDAUNTED

-- Retour de GetItemLinkCraftingSkillType()
-- CRAFTING_TYPE_INVALID			0 => matériaux de trait, de style, d'ameublement
-- CRAFTING_TYPE_BLACKSMITHING		1 = forge
-- CRAFTING_TYPE_CLOTHIER			2 = couture
-- CRAFTING_TYPE_ENCHANTING			3 = enchantement
-- CRAFTING_TYPE_ALCHEMY			4 = alchimie
-- CRAFTING_TYPE_PROVISIONING		5 = cuisine
-- CRAFTING_TYPE_WOODWORKING		6 = bois
-- CRAFTING_TYPE_JEWELRYCRAFTING	7 = bijoux (matériaux, placage)

-- crochet = ITEMFILTERTYPE_MISCELLANEOUS + ITEMTYPE_TOOL => ITEMTYPE_LOCKPICK
-- leurre  = ITEMFILTERTYPE_MISCELLANEOUS + ITEMTYPE_LURE
-- kit de réparation = ITEMFILTERTYPE_CONSUMABLE + ITEMTYPE_TOOL
-- potion/posion = ITEMFILTERTYPE_CONSUMABLE + ITEMTYPE_POTION ou ITEMTYPE_POISON

-- quality: trash = 0, normal(blanc) = 1, magic(vert) = 2, arcane(bleu) = 3, artifact(violet) = 4, legendary(jaune) = 5

-- pour les armes et les armures faire une seule config mais ajouter le choix couture/bois/forge

-- Convertion du code de retour de GetItemLinkWeaponType() en un code CRAFTING_TYPE_xxx
local WEAPONTYPE_CRAFTING_TYPE =
{
	[WEAPONTYPE_NONE] = CRAFTING_TYPE_INVALID,
	[WEAPONTYPE_AXE] = CRAFTING_TYPE_BLACKSMITHING,
	[WEAPONTYPE_HAMMER] = CRAFTING_TYPE_BLACKSMITHING,
	[WEAPONTYPE_SWORD] = CRAFTING_TYPE_BLACKSMITHING,
	[WEAPONTYPE_TWO_HANDED_SWORD] = CRAFTING_TYPE_BLACKSMITHING,
	[WEAPONTYPE_TWO_HANDED_AXE] = CRAFTING_TYPE_BLACKSMITHING,
	[WEAPONTYPE_TWO_HANDED_HAMMER] = CRAFTING_TYPE_BLACKSMITHING,
	[WEAPONTYPE_PROP] = CRAFTING_TYPE_INVALID,
	[WEAPONTYPE_BOW] = CRAFTING_TYPE_WOODWORKING,
	[WEAPONTYPE_HEALING_STAFF] = CRAFTING_TYPE_WOODWORKING,
	[WEAPONTYPE_RUNE] = CRAFTING_TYPE_INVALID,
	[WEAPONTYPE_DAGGER] = CRAFTING_TYPE_BLACKSMITHING,
	[WEAPONTYPE_FIRE_STAFF] = CRAFTING_TYPE_WOODWORKING,
	[WEAPONTYPE_FROST_STAFF] = CRAFTING_TYPE_WOODWORKING,
	[WEAPONTYPE_SHIELD] = CRAFTING_TYPE_WOODWORKING,
	[WEAPONTYPE_LIGHTNING_STAFF] = CRAFTING_TYPE_WOODWORKING,
}

local MATERIAL_LIST_LEVEL = 
{
	[64489]  = 160, -- lingot de cuprite
	[64502]  = 160,	-- frêne roux poncé
	[64504]  = 160, -- soie ancestrale
	[64506]  = 160, -- cuir pourpre
	[71198]  = 160, -- minerai de cuprite
	[71199]  = 160, -- frêne roux brut
	[71200]  = 160, -- soie ancestrale brute
	[135145] = 160, -- poussière de platine
	[135146] = 160, -- once de platine
}

-- Convertion du code de retour de GetItemLinkArmorType() et GetItemLinkWeaponType() en un code CRAFTING_TYPE_xxx
-- Attention car un bouclier est une pièce d'armure mais elle est classé dans les armes pour le type !
local function GetCraftingType(itemLink)
	local armorType = GetItemLinkArmorType(itemLink)
	if armorType == ARMORTYPE_HEAVY then 
		return CRAFTING_TYPE_BLACKSMITHING 
	elseif armorType == ARMORTYPE_NONE then 
		local weaponType = GetItemLinkWeaponType(itemLink)
		return WEAPONTYPE_CRAFTING_TYPE[weaponType]
	else 
		return CRAFTING_TYPE_CLOTHIER 
	end
end

local function GetItemCraftingLevel(item)
	if item.craftingType ~= CRAFTING_TYPE_INVALID then
		local level = MATERIAL_LIST_LEVEL[item.itemId]
		if level then
			return level
		end
	end
	return 0
end

local function IsItemLinkCanBeSell(itemLink)
	return GetItemLinkSellInformation(itemLink) ~= ITEM_SELL_INFORMATION_CANNOT_SELL
end

local function IsContainerCollectibleUnknown(itemLink)
	local containerCollectibleId = GetItemLinkContainerCollectibleId(itemLink)
	local isValidForPlayer = IsCollectibleValidForPlayer(containerCollectibleId)
	local isUnlocked = IsCollectibleUnlocked(containerCollectibleId)
	return isValidForPlayer and not isUnlocked
end

-- Construit une commande pour la console
function addon:BuildSlashCmd(cmd)
	return "/" .. self.slash_name .. cmd
end

-- Printf dans le chat
function addon:Printf(formatString, ...)
	CHAT_SYSTEM:AddMessage(White:Colorize("[" .. self.name .. "] ") .. string.format(formatString, ...))
end
function addon:ColorPrintf(color, formatString, ...)
	CHAT_SYSTEM:AddMessage(color:Colorize("[" .. self.name .. "] ") .. string.format(formatString, ...))
end

-- Called by Bindings
function addon:Binding_BankAction()
	if self.Buttons.BankAction.enabled then
		d("addon:Binding_Action !")
	end
end

function addon:Binding_SearchUnknown()
	if self.settings_c.search_unknown.enabled_search and self.Buttons.InventorySearch.enabled then
		if IsBankOpen() then
			self:ScanBagForUnknown(BAG_BANK)
		elseif IsGuildBankOpen() then
			self:ScanBagForUnknown(BAG_GUILDBANK)
		elseif self.Buttons.InventorySearch.IsTradingHouse then
			self:StartScanTradingHouse()
		end
	end
end

function addon:Binding_PreventAttackingInnocents()
	local str = ""
	local setting = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS)
	if setting == "1" then 
		setting = "0"
		str = GetString(SI_EASYLOOTASSISTANT_DISABLED_F)
	else 
		setting = "1" 
		str = GetString(SI_EASYLOOTASSISTANT_ENABLED_F)
	end
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS, setting, 1)
	self:Printf("Option %s %s", GetString(SI_INTERFACE_OPTIONS_COMBAT_PREVENT_ATTACKING_INNOCENTS), str)
	-- LOOT_SETTING_AUTO_LOOT_STOLEN
end

function addon:Binding_AutoLootStolen()
	local str = ""
	local setting = GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN)
	if setting == "1" then 
		setting = "0"
		str = GetString(SI_EASYLOOTASSISTANT_DISABLED_F)
	else 
		setting = "1" 
		str = GetString(SI_EASYLOOTASSISTANT_ENABLED_F)
	end
	SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, setting, 1)
	self:Printf("Option %s %s", GetString(SI_INTERFACE_OPTIONS_LOOT_USE_AUTOLOOT_STOLEN), str)
end

function addon:OnInventoryUpdated()
	if KEYBIND_STRIP:HasKeybindButton(self.Buttons.SellAllJunk) and self.Buttons.SellAllJunk.enable_use then
		-- Attention la fonction 'UpdateKeybindButton' ajoute le bouton si celui-ci n'existe pas !
		KEYBIND_STRIP:UpdateKeybindButton(self.Buttons.SellAllJunk)
	end
end

function addon:InitializeKeybind()
	self.Buttons = {}
    self.Buttons.BankAction = { 
		alignment = KEYBIND_STRIP_ALIGN_RIGHT,
		name = GetString(SI_EASYLOOTASSISTANT_TRANSFER),
		keybind = "RUN_EASYLOOTASSISTANT_ACTION", -- lien avec le fichier 'bindings.xml'
		visible = function()
			return false --self.Buttons.BankAction.enabled
		end,
		callback = function() 
			self:Binding_BankAction() 
		end,
		enabled = false
    }
    self.Buttons.SellAllJunk = { -- bouton 'Vendre tous les rebuts'
		alignment = KEYBIND_STRIP_ALIGN_RIGHT,
		order = 200,
		name = GetString(SI_SELL_ALL_JUNK_KEYBIND_TEXT),
		keybind = "UI_SHORTCUT_NEGATIVE",
		visible = function() return HasAnyJunk(BAG_BACKPACK, true) end,
		callback =  function()
			ZO_Dialogs_ShowDialog("SELL_ALL_JUNK")
		end,
		enable_use = false, -- variable perso
    }
    self.Buttons.InventorySearch = { 
		alignment = KEYBIND_STRIP_ALIGN_LEFT,
		order = 200,
		name = function() 
			if self.scanTradingHouse then
				return GetString(SI_EASYLOOTASSISTANT_SEARCH_CANCEL)
			else
				return GetString(SI_EASYLOOTASSISTANT_SEARCH_UNKNOWN)
			end
		end,
		keybind = "RUN_EASYLOOTASSISTANT_SEARCH", -- lien avec le fichier 'bindings.xml'
        visible = function()
			return self.Buttons.InventorySearch.enabled
		end,
		callback = function() 
			self:Binding_SearchUnknown()
		end,
		enabled = false
	}
	KEYBIND_STRIP:AddKeybindButton(self.Buttons.BankAction)
end

-- Récupération du prix de l'objet sur TTC
function addon:GetTTCPriceInfo(itemLink)
	local ttc_price_result = 0
	if self.settings_a.price_TTC.enabled and TamrielTradeCentrePrice then
		local ttc_price = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
		if ttc_price then
			if ttc_price.SuggestedPrice == nil then
				ttc_price_result = ttc_price.Avg
			else
				ttc_price_result = ttc_price.SuggestedPrice
			end
		end
	end
	return ttc_price_result
end

-- ITEMTYPE_xx en version locale pour le lien entre les configs, les widgets et les filtres
local CFGTYPE_EQUIPMENT_BLACKSMITHING = 1			-- Equipment / Blacksmithing / Forge
local CFGTYPE_EQUIPMENT_CLOTHING = 2				-- Equipment / Clothing / Vêtements
local CFGTYPE_EQUIPMENT_WOODWORKING = 3				-- Equipment / Woodworking / Travail du bois
local CFGTYPE_JEWELRY = 4							-- Jewelry / Bijoux
local CFGTYPE_POTIONS = 5							-- Potion / Potion
local CFGTYPE_POISONS = 6							-- Poison / Poison
local CFGTYPE_DRINK = 7								-- Drink / Boisson
local CFGTYPE_FOOD = 8								-- Food / Nourriture
local CFGTYPE_LOCKPICK = 9							-- Lockpick / Crocket
local CFGTYPE_LURE = 10								-- Lure / Appât
local CFGTYPE_GLYPHS = 11							-- Glyphs / Glyphes
local CFGTYPE_TRASH = 12							-- Trash / Camelote
local CFGTYPE_TREASURE = 13							-- Trésors / Treasure
local CFGTYPE_RAW_MATERIAL = 14						-- Raw Material / Matériau brut
local CFGTYPE_CRAFTING_BLACKSMITHING = 15			-- Crafting / Blacksmithing
local CFGTYPE_CRAFTING_CLOTHING = 16				-- Crafting / Clothing
local CFGTYPE_ENCHANTING = 17						-- Enchanting / Enchantement
local CFGTYPE_REAGENTS = 18							-- Reagents / Réactifs
local CFGTYPE_SOLVENT_POTION = 19					-- Solvent / Solvant (potion)
local CFGTYPE_PROVISIONING = 20						-- Provisioning / Cuisine
local CFGTYPE_CRAFTING_WOODWORKING = 21				-- Crafting / Woodworking
local CFGTYPE_JEWELRYCRAFTING = 22					-- Jewelry Crafting / Joaillerie		- ITEMFILTERTYPE_JEWELRYCRAFTING
local CFGTYPE_FURNISHING_MATERIAL = 23				-- Furnishing Material / Matériau d'ameublement
local CFGTYPE_ORNATE = 24							-- Ornate / Orné
local CFGTYPE_MINTTCPRICE_EQUIPMENT = 25			-- MinTTCPrice equipement
local CFGTYPE_MINTTCPRICE_MATERIAL = 26				-- MinTTCPrice materiaux
local CFGTYPE_SOLVENT_POISON = 27					-- Solvent / Solvant (poison)
local CFGTYPE_RARE_FISH = 28						-- Poisson rare / Rare fish
local CFGTYPE_STYLE_MATERIAL = 29					-- Style Material / Matériau de style
local CFGTYPE_TRAIT_MATERIAL = 30					-- Trait Material / Matériau de trait
local CFGTYPE_FINE_MATERIAL = 31					-- Fine Material / Matériau raffiné
local CFGTYPE_BOOSTER_MATERIAL = 32					-- Booster / Tanins

-- Garde ou jete des objets selon le nombre de pile
local function Filter_keepStackInBagpack(items, keepStackInBagpack)
	for i = 1, math.min(keepStackInBagpack,#items) do
		items[i].result = ITEM_RESULT_KEEP
		items[i].keepLock = true
	end
	for i = keepStackInBagpack+1, #items do
		if items[i].result == ITEM_RESULT_NOT_PROCESSED then
			items[i].result = ITEM_RESULT_JUNK
		end
	end
end

-- Attention la liste 'items' doit être trié par stack
local function Filter_keepTotal(items, keepTotal)
	local item = items[1]
	local nb_to_keep = keepTotal - item.bankCount - item.craftBagCount
	local total = 0
	for _, it in ipairs(items) do
		if it.result == ITEM_RESULT_KEEP then
			total = total + it.stack
		elseif total < nb_to_keep then
			it.result = ITEM_RESULT_KEEP
			total = total + it.stack
		elseif it.result == ITEM_RESULT_NOT_PROCESSED then
			it.result = ITEM_RESULT_JUNK
		end
	end
end

addon.WIDGETS =
{
	keepOrnate = 
	{
		name = GetString(SI_EASYLOOTASSISTANT_WIDGETS_KEEP_ORNATE),
		type = "checkbox",
		tooltip = GetString(SI_EASYLOOTASSISTANT_WIDGETS_KEEP_ORNATE_TT),
		default = true,
	},
	keepIntricate = 
	{
		name = GetString(SI_EASYLOOTASSISTANT_WIDGETS_KEEP_INTRICATE),
		type = "checkbox",
		tooltip = GetString(SI_EASYLOOTASSISTANT_WIDGETS_KEEP_INTRICATE_TT),
		default = true,
		process = function(items, filter) 
			for _, it in ipairs(items) do
				if it.itemTraitInformation == ITEM_TRAIT_INFORMATION_INTRICATE and filter == true then 
					it.result = ITEM_RESULT_KEEP 
				end 
			end
		end,
	},
	keepALL = 
	{
		name = GetString(SI_EASYLOOTASSISTANT_WIDGETS_KEEP_ALL),
		type = "checkbox",
		tooltip = GetString(SI_EASYLOOTASSISTANT_WIDGETS_KEEP_ALL_TT),
		default = true,
		master = true,
		process = function(items, filter) 
			if filter and (filter == true) then
				--for _, it in ipairs(items) do
				--	it.result = ITEM_RESULT_KEEP
				--end
				apply_result(items,ITEM_RESULT_KEEP)
			end
		end,
	},
	forceBankTransfer = 
	{
		name = GetString(SI_EASYLOOTASSISTANT_WIDGETS_FORCE_BANK_TRANSFER),
		type = "dropdown",
		tooltip = GetString(SI_EASYLOOTASSISTANT_WIDGETS_FORCE_BANK_TRANSFER_TT),
		choices = {
			GetString(SI_EASYLOOTASSISTANT_WIDGETS_FORCE_BANK_TRANSFER_0),
			GetString(SI_EASYLOOTASSISTANT_WIDGETS_FORCE_BANK_TRANSFER_1),
			GetString(SI_EASYLOOTASSISTANT_WIDGETS_FORCE_BANK_TRANSFER_2),
			GetString(SI_EASYLOOTASSISTANT_WIDGETS_FORCE_BANK_TRANSFER_3) },
		choicesValues = {FORCE_BANK_TRANSFER_DEFAULT, 
						FORCE_BANK_TRANSFER_DONT_TRANSFER, 
						FORCE_BANK_TRANSFER_TO_BANK, 
						FORCE_BANK_TRANSFER_FROM_BANK},
		default = 0,
		character = true,	-- active la config de ce widget pour le perso
		disabled = function() return false end,
		process = function(items, filter_a, filter_c) 
			if filter_c then
				for _, it in ipairs(items) do
					it.forceBankTransfer = filter_c
				end
			end
		end,
	},
	transferCP160 = 
	{
		name = "Transfer CP160",
		type = "dropdown",
		--tooltip = GetString(SI_EASYLOOTASSISTANT_WIDGETS_KEEP_SETS_TT),
		choices = {
			GetString(SI_EASYLOOTASSISTANT_WIDGETS_FORCE_BANK_TRANSFER_0),
			GetString(SI_EASYLOOTASSISTANT_WIDGETS_FORCE_BANK_TRANSFER_1),
			GetString(SI_EASYLOOTASSISTANT_WIDGETS_FORCE_BANK_TRANSFER_2),
			GetString(SI_EASYLOOTASSISTANT_WIDGETS_FORCE_BANK_TRANSFER_3) },
		choicesValues = {FORCE_BANK_TRANSFER_DEFAULT, 
						FORCE_BANK_TRANSFER_DONT_TRANSFER,
						FORCE_BANK_TRANSFER_TO_BANK, 
						FORCE_BANK_TRANSFER_FROM_BANK},
		default = 0,
		character = true,	-- active la config de ce widget pour le perso
		disabled = false,
		process = function(items, filter_a, filter_c) 
			for _, it in ipairs(items) do
				it.transferCP160 = filter_c
			end
		end,
	},
	keepQuality = 
	{
		name = GetString(SI_EASYLOOTASSISTANT_WIDGETS_KEEP_QUALITY),
		type = "dropdown",
		tooltip = GetString(SI_EASYLOOTASSISTANT_WIDGETS_KEEP_QUALITY_TT),
		choices = {
			ZO_ColorDef:New("4c4c4c"):Colorize(GetString(SI_EASYLOOTASSISTANT_DISABLED_F)),
			GetString(SI_ITEMQUALITY1), -- blanc
			ZO_ColorDef:New("2dc50e"):Colorize(GetString(SI_ITEMQUALITY2)), -- vert
			ZO_ColorDef:New("3a92ff"):Colorize(GetString(SI_ITEMQUALITY3)), -- bleu
			ZO_ColorDef:New("a02ef7"):Colorize(GetString(SI_ITEMQUALITY4)), -- violet
			ZO_ColorDef:New("eeca2a"):Colorize(GetString(SI_ITEMQUALITY5)) }, -- jaune
		choicesValues = {0, 1, 2, 3, 4, 5},
		default = ITEM_QUALITY_TRASH,
		process = function(items, filter) 
			if filter > 0 and items[1].quality >= filter then
				--for _, it in ipairs(items) do
				--	it.result = ITEM_RESULT_KEEP
				--end
				apply_result(items, ITEM_RESULT_KEEP)
			end
		end,
	},
	keepSets = 
	{
		name = GetString(SI_EASYLOOTASSISTANT_WIDGETS_KEEP_SETS),
		type = "checkbox",
		tooltip = GetString(SI_EASYLOOTASSISTANT_WIDGETS_KEEP_SETS_TT),
		default = true,
		process = function(items, filter) 
			for _, it in ipairs(items) do
				if GetItemLinkSetInfo(it.itemLink, false) and filter == true then
					it.result = ITEM_RESULT_KEEP
				end
			end
		end,
	},
	junk = -- règle sans widget donc pas de 'type'
	{
		process = function(items, filter) 
			for _, it in ipairs(items) do
				if it.result == ITEM_RESULT_NOT_PROCESSED then
					it.result = ITEM_RESULT_JUNK
				end
			end
		end,
	},
	keepStackInBagpack =
	{
		type = "combo",
		-- combo avec la 'checkbox' qui controle le 'widget'
		checkbox = 
		{
			name = GetString(SI_EASYLOOTASSISTANT_WIDGETS_KEEP_STACK_BAGPACK),
			type = "checkbox",
			tooltip = GetString(SI_EASYLOOTASSISTANT_WIDGETS_KEEP_STACK_BAGPACK_TT),
			width = "half",
			default = false,
		},
		widget = 
		{
			name = GetString(SI_EASYLOOTASSISTANT_WIDGETS_KEEP_NUMBER_STACK),
			type = "editbox",
			tooltip = GetString(SI_EASYLOOTASSISTANT_WIDGETS_KEEP_NUMBER_STACK_TT),
			width = "half",
			default = 0,
		},
		process = function(items, filter) 
			if filter.enabled then
				Filter_keepStackInBagpack(items, filter.value)
			end
		end,
	},
	keepTotal =
	{
		type = "combo",
		-- combo avec la 'checkbox' qui controle le 'widget'
		checkbox = 
		{
			name = GetString(SI_EASYLOOTASSISTANT_WIDGETS_KEEP_TOTAL),
			type = "checkbox",
			tooltip = GetString(SI_EASYLOOTASSISTANT_WIDGETS_KEEP_TOTAL_TT),
			width = "half",
			default = false,
		},
		widget = 
		{
			name = GetString(SI_EASYLOOTASSISTANT_WIDGETS_KEEP_TOTAL_V),
			type = "editbox",
			tooltip = GetString(SI_EASYLOOTASSISTANT_WIDGETS_KEEP_TOTAL_V_TT),
			width = "half",
			default = 0,
		},
		process = function(items, filter) 
			if filter.enabled then
				Filter_keepTotal(items, filter.value)
			else
				for _, it in ipairs(items) do
					if it.result == ITEM_RESULT_NOT_PROCESSED then
						it.result = ITEM_RESULT_JUNK
					end
				end
			end
		end,
	},
	keepMinTTCPrice =
	{
		type = "combo",
		-- combo avec la 'checkbox' qui controle le 'widget'
		checkbox = 
		{
			name = GetString(SI_EASYLOOTASSISTANT_WIDGETS_KEEP_TTC_PRICE),
			type = "checkbox",
			tooltip = GetString(SI_EASYLOOTASSISTANT_WIDGETS_KEEP_TTC_PRICE_TT),
			width = "half",
			default = false,
		},
		widget = 
		{
			name = GetString(SI_EASYLOOTASSISTANT_WIDGETS_KEEP_TTC_PRICE_V),
			type = "editbox",
			tooltip = GetString(SI_EASYLOOTASSISTANT_WIDGETS_KEEP_TTC_PRICE_V_TT),
			width = "half",
			default = 0,
		},
		process = function(items, filter) 
			if filter.enabled and self.settings_a.price_TTC.enabled then
				if items[1].ttc_price >= filter.value then
					--for _, it in ipairs(items) do
					--	it.result = ITEM_RESULT_KEEP
					--end
					apply_result(items, ITEM_RESULT_KEEP)
				end
			end
		end,
	},
}

local CONFIG_RULES = 
{
	-- Attention l'ordre de déclaration des filtres dans la section 'widgets' est important !
	{
		name = Yellow_1:Colorize(GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES401)), -- "Armes / Armures / Bijoux",
		items = {
			{
				cfg = CFGTYPE_ORNATE,
				widgets = {
					"keepOrnate"
				 }
			},
			{
				cfg = CFGTYPE_MINTTCPRICE_EQUIPMENT,
				widgets = {
					"keepMinTTCPrice"
				 }
			},
			{
				cfg = CFGTYPE_EQUIPMENT_BLACKSMITHING,
				title = { prefix="SI_ITEMFILTERTYPE", idx=ITEMFILTERTYPE_BLACKSMITHING },
				widgets = { 
					"keepIntricate",
					"keepQuality",
					"keepSets",
					"junk"
				}
			},
			{
				cfg = CFGTYPE_EQUIPMENT_CLOTHING,
				title = { prefix="SI_ITEMFILTERTYPE", idx=ITEMFILTERTYPE_CLOTHING },
				widgets = {
					"keepIntricate",
					"keepQuality",
					"keepSets",
					"junk"
				}
			},
			{
				cfg = CFGTYPE_EQUIPMENT_WOODWORKING,
				title = { prefix="SI_ITEMFILTERTYPE", idx=ITEMFILTERTYPE_WOODWORKING },
				widgets = {
					"keepIntricate",
					"keepQuality",
					"keepSets",
					"junk"
				},
			},
			{
				cfg = CFGTYPE_JEWELRY,
				title = { prefix="SI_ITEMFILTERTYPE", idx=ITEMFILTERTYPE_JEWELRYCRAFTING },
				widgets = {
					"keepIntricate",
					"keepQuality",
					"keepSets",
					"junk"
				},
			}
		},
	},
	{
		-- Consommables = SI_ITEMFILTERTYPE3
		-- Divers = SI_ITEMFILTERTYPE5
		name = Yellow_1:Colorize(GetString(SI_ITEMFILTERTYPE3) .. " / " .. GetString(SI_ITEMFILTERTYPE5)), --"Consommables / Divers",
		items = {
			{
				cfg = CFGTYPE_POTIONS,
				title = { prefix="SI_ITEMTYPE", idx=ITEMTYPE_POTION },
				widgets = 
				{
					"keepALL",
					"keepStackInBagpack",
					"keepTotal",
				}
			},
			{
				cfg = CFGTYPE_POISONS,
				title = { prefix="SI_ITEMTYPE", idx=ITEMTYPE_POISON },
				widgets = 
				{
					"keepALL",
					"keepStackInBagpack",
					"keepTotal",
				}
			},
			{
				cfg = CFGTYPE_DRINK,
				title = { prefix="SI_ITEMTYPE", idx=ITEMTYPE_DRINK },
				widgets = 
				{
					"keepALL",
					"keepStackInBagpack",
					"keepTotal",
				}
			},
			{
				cfg = CFGTYPE_FOOD,
				title = { prefix="SI_ITEMTYPE", idx=ITEMTYPE_FOOD },
				widgets = 
				{
					"keepALL",
					"keepStackInBagpack",
					"keepTotal",
				}
			},
			{
				cfg = CFGTYPE_LOCKPICK,
				title = { prefix="SI_ITEMTYPE", idx=ITEMTYPE_LOCKPICK },
				widgets = 
				{
					"keepALL",
					"keepStackInBagpack",
					"keepTotal",
				}
			},
			{
				cfg = CFGTYPE_LURE,
				title = { prefix="SI_ITEMTYPE", idx=ITEMTYPE_LURE },
				widgets = 
				{
					"keepALL",
					"keepStackInBagpack",
					"keepTotal",
				}
			},
			{
				cfg = CFGTYPE_GLYPHS,
				title = { idx=GAMEPAD_ITEM_CATEGORY_GLYPHS, prefix="SI_GAMEPADITEMCATEGORY" },
				widgets = 
				{
					"keepALL",
					"keepStackInBagpack",
					"keepTotal",
				}
			},
			{
				cfg = CFGTYPE_TRASH,
				title = { prefix="SI_ITEMTYPE", idx=ITEMTYPE_TRASH },
				widgets = 
				{
					"keepALL",
					"keepStackInBagpack",
					"keepTotal",
				}
			},
			{
				cfg = CFGTYPE_TREASURE,
				title = { prefix="SI_ITEMTYPE", idx=ITEMTYPE_TREASURE },
				widgets = 
				{
					"keepALL",
					"keepStackInBagpack",
					"keepTotal",
				}
			},
			{
				cfg = CFGTYPE_RARE_FISH,
				title = { prefix="SI_SPECIALIZEDITEMTYPE", idx=SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH },
				widgets = 
				{
					"keepALL",
					"keepStackInBagpack",
					"keepTotal",
				}
			},
		}
	},
	{
		name = Yellow_1:Colorize(GetString(SI_ITEMFILTERTYPE4)), --Matériaux
		items = {
			{
				cfg = CFGTYPE_MINTTCPRICE_MATERIAL,
				widgets = {
					"keepMinTTCPrice"
				 }
			},
			{
				cfg = CFGTYPE_RAW_MATERIAL,
				title = { prefix="SI_ITEMTYPE", idx=ITEMTYPE_RAW_MATERIAL },
				widgets = 
				{
					"forceBankTransfer",
					"transferCP160",
					"keepALL",
					"keepTotal",
				}
			},
			{
				cfg = CFGTYPE_FINE_MATERIAL,
				title = { prefix="SI_ITEMTYPE", idx=ITEMTYPE_CLOTHIER_MATERIAL },
				widgets = 
				{
					"forceBankTransfer",
					"transferCP160",
					"keepALL",
					"keepTotal",
				}
			},
			{
				cfg = CFGTYPE_BOOSTER_MATERIAL,
				title = { prefix="SI_ITEMTYPE", idx=ITEMTYPE_CLOTHIER_BOOSTER },
				widgets = 
				{
					"forceBankTransfer",
					"keepALL",
					"keepTotal",
				}
			},
			{
				cfg = CFGTYPE_STYLE_MATERIAL,
				title = { prefix="SI_ITEMTYPE", idx=ITEMTYPE_STYLE_MATERIAL },
				widgets = 
				{
					"forceBankTransfer",
					"keepALL",
					"keepTotal",
				}
			},
			{
				cfg = CFGTYPE_TRAIT_MATERIAL,
				title = { prefix=SI_EASYLOOTASSISTANT_TRAIT_MATERIAL },
				widgets = 
				{
					"forceBankTransfer",
					"keepALL",
					"keepTotal",
				}
			},
			{
				cfg = CFGTYPE_FURNISHING_MATERIAL, -- ameublement
				title = { prefix="SI_ITEMTYPE", idx=ITEMTYPE_FURNISHING_MATERIAL },
				widgets = 
				{
					"forceBankTransfer",
					"keepALL",
					"keepQuality",
					"keepTotal",
				}
			},
			{
				cfg = CFGTYPE_PROVISIONING, -- cuisine
				title = { prefix="SI_ITEMFILTERTYPE", idx=ITEMFILTERTYPE_PROVISIONING },
				widgets = 
				{
					"forceBankTransfer",
					"keepALL",
					"keepQuality",
					"keepTotal",
				}
			},
			{
				cfg = CFGTYPE_ENCHANTING,
				title = { prefix="SI_ITEMFILTERTYPE", idx=ITEMFILTERTYPE_ENCHANTING },
				widgets = 
				{
					"forceBankTransfer",
					"keepALL",
					"keepQuality",
					"keepTotal",
				}
			},
			{
				cfg = CFGTYPE_REAGENTS,
				title = { prefix="SI_ITEMTYPE", idx=ITEMTYPE_REAGENT },
				widgets = 
				{
					"forceBankTransfer",
					"keepALL",
					"keepQuality",
					"keepTotal",
				}
			},
			{
				cfg = CFGTYPE_SOLVENT_POTION,
				title = { prefix="", idx=SI_ITEMTYPE33 },
				widgets = 
				{
					"keepALL",
					"keepTotal",
				}
			},
			{
				cfg = CFGTYPE_SOLVENT_POISON,
				title = { prefix="", idx=SI_ITEMTYPE58 },
				widgets = 
				{
					"keepALL",
					"keepTotal",
				}
			},
			--[[
			{
				cfg = CFGTYPE_CRAFTING_BLACKSMITHING,
				title = { prefix="SI_ITEMFILTERTYPE", idx=ITEMFILTERTYPE_BLACKSMITHING },
				widgets = 
				{
					"keepALL",
					"keepQuality",
					"keepTotal",
				}
			},
			{
				cfg = CFGTYPE_CRAFTING_CLOTHING,
				title = { prefix="SI_ITEMFILTERTYPE", idx=ITEMFILTERTYPE_CLOTHING },
				widgets = 
				{
					"keepALL",
					"keepQuality",
					"keepTotal",
				}
			},
			{
				cfg = CFGTYPE_CRAFTING_WOODWORKING,
				title = { prefix="SI_ITEMFILTERTYPE", idx=ITEMFILTERTYPE_WOODWORKING },
				widgets = 
				{
					"keepALL",
					"keepQuality",
					"keepTotal",
				}
			},
			--]]
			{
				cfg = CFGTYPE_JEWELRYCRAFTING,
				title = { prefix="SI_ITEMFILTERTYPE", idx=ITEMFILTERTYPE_JEWELRYCRAFTING },
				widgets = 
				{
					"keepALL",
					"keepQuality",
					"keepTotal",
				}
			},
		}
	},
}

-- Cette liste est construite par la fonction BuildRulesSettings à partir de CONFIG_RULES
-- input  = CFGTYPE_xxx
-- output = widgets list
local CONFIG_RULES_WIDGETS =
{
}

-- filtre spécifique pour les armes, armures et bijoux en fonction des métiers de craft associés (CRAFTING_TYPE_xxx)
-- ITEMFILTERTYPE_WEAPONS => (weaponType) CRAFTING_TYPE_BLACKSMITHING, CRAFTING_TYPE_WOODWORKING, CRAFTING_TYPE_INVALID
-- ITEMFILTERTYPE_ARMOR   => (armorType)  ARMORTYPE_HEAVY => CRAFTING_TYPE_BLACKSMITHING, ARMORTYPE_NONE => CRAFTING_TYPE_INVALID sinon CRAFTING_TYPE_CLOTHIER
-- ITEMFILTERTYPE_JEWELRY => CRAFTING_TYPE_JEWELRYCRAFTING
-- 		WEAPONS_ARMOR_JEWELRY[craftingType]
local WEAPONS_ARMOR_JEWELRY =
{
	[CRAFTING_TYPE_BLACKSMITHING] = CFGTYPE_EQUIPMENT_BLACKSMITHING,
	[CRAFTING_TYPE_CLOTHIER] = CFGTYPE_EQUIPMENT_CLOTHING,
	[CRAFTING_TYPE_WOODWORKING] = CFGTYPE_EQUIPMENT_WOODWORKING,
	[CRAFTING_TYPE_JEWELRYCRAFTING] = CFGTYPE_JEWELRY,
}

-- Table de fonction de process associés à un filtre de type d'objet
-- ITEMFILTERTYPE_CONSUMABLE
local CONSUMABLE_LIST =
{
	[ITEMTYPE_POTION] = CFGTYPE_POTIONS,
	[ITEMTYPE_POISON] = CFGTYPE_POISONS,
	[ITEMTYPE_DRINK] = CFGTYPE_DRINK,
	[ITEMTYPE_FOOD] = CFGTYPE_FOOD,
}

-- ITEMFILTERTYPE_MISCELLANEOUS
local MISCELLANEOUS_LIST = -- 5
{
	[ITEMTYPE_TOOL] = CFGTYPE_LOCKPICK, 		-- 9 => crochet
	[ITEMTYPE_LURE] = CFGTYPE_LURE, 			-- 16 => leurre
	[ITEMTYPE_GLYPH_WEAPON] = CFGTYPE_GLYPHS,	-- 20
	[ITEMTYPE_GLYPH_ARMOR] = CFGTYPE_GLYPHS,	-- 21
	[ITEMTYPE_GLYPH_JEWELRY] = CFGTYPE_GLYPHS,	-- 26
	[ITEMTYPE_TRASH] = CFGTYPE_TRASH,			-- 48
	[ITEMTYPE_TREASURE] = CFGTYPE_TREASURE,		-- 56
	[ITEMTYPE_COLLECTIBLE] = 					-- 34.S80 => poisson rare
	{
		getkey = function(item) return item.specializedItemType end,
		[SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH] = CFGTYPE_RARE_FISH,
	}
}

-- Table de fonction de process associés à un filtre de type de craft
-- ITEMFILTERTYPE_CRAFTING
-- 		CRAFTING_LIST[craftingType][itemType]
local CRAFTING_LIST = -- ITEMFILTERTYPE_CRAFTING = 4
{
	[CRAFTING_TYPE_INVALID] = -- => sous-sélection avec itemType
	{
		getkey = function(item) return item.itemType end,
		-- ITEMTYPE_RAW_MATERIAL   				17 -- materiaux bruts
		[ITEMTYPE_RAW_MATERIAL] = CFGTYPE_RAW_MATERIAL,
		-- ITEMTYPE_STYLE_MATERIAL 				44 -- materiaux de style
		[ITEMTYPE_STYLE_MATERIAL] = CFGTYPE_STYLE_MATERIAL,
		-- ITEMTYPE_ARMOR_TRAIT					45 -- trait d'armure
		-- ITEMTYPE_WEAPON_TRAIT				46 -- trait d'arme
		[ITEMTYPE_ARMOR_TRAIT]    = CFGTYPE_TRAIT_MATERIAL,
		[ITEMTYPE_WEAPON_TRAIT]   = CFGTYPE_TRAIT_MATERIAL,
		-- ITEMTYPE_FURNISHING_MATERIAL			62 -- ameublement
		[ITEMTYPE_FURNISHING_MATERIAL] = CFGTYPE_FURNISHING_MATERIAL,
		-- ITEMTYPE_JEWELRY_TRAIT				66 -- trait de bijoux
		-- ITEMTYPE_JEWELRY_RAW_TRAIT			68 -- materiaux bruts de trait de bijoux
		[ITEMTYPE_JEWELRY_TRAIT] = CFGTYPE_JEWELRYCRAFTING,
		[ITEMTYPE_JEWELRY_RAW_TRAIT] = CFGTYPE_JEWELRYCRAFTING,
	},
	[CRAFTING_TYPE_BLACKSMITHING] = 
	{
		getkey = function(item) return item.itemType end,
		-- ITEMTYPE_BLACKSMITHING_RAW_MATERIAL 	35
		-- ITEMTYPE_BLACKSMITHING_MATERIAL	 	36
		-- ITEMTYPE_BLACKSMITHING_BOOSTER 		41
		[ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = CFGTYPE_RAW_MATERIAL,
		[ITEMTYPE_BLACKSMITHING_MATERIAL] = CFGTYPE_FINE_MATERIAL,
		[ITEMTYPE_BLACKSMITHING_BOOSTER] = CFGTYPE_BOOSTER_MATERIAL,
	},
	[CRAFTING_TYPE_CLOTHIER] = 
	{
		getkey = function(item) return item.itemType end,
		-- ITEMTYPE_CLOTHIER_RAW_MATERIAL		39
		-- ITEMTYPE_CLOTHIER_MATERIAL			40
		-- ITEMTYPE_CLOTHIER_BOOSTER			43
		[ITEMTYPE_CLOTHIER_RAW_MATERIAL] = CFGTYPE_RAW_MATERIAL,
		[ITEMTYPE_CLOTHIER_MATERIAL] = CFGTYPE_FINE_MATERIAL,
		[ITEMTYPE_CLOTHIER_BOOSTER] = CFGTYPE_BOOSTER_MATERIAL,
	},
	[CRAFTING_TYPE_WOODWORKING] = 
	{
		getkey = function(item) return item.itemType end,
		-- ITEMTYPE_WOODWORKING_RAW_MATERIAL	37
		-- ITEMTYPE_WOODWORKING_MATERIAL		38
		-- ITEMTYPE_WOODWORKING_BOOSTER			42
		[ITEMTYPE_WOODWORKING_RAW_MATERIAL] = CFGTYPE_RAW_MATERIAL,
		[ITEMTYPE_WOODWORKING_MATERIAL] = CFGTYPE_FINE_MATERIAL,
		[ITEMTYPE_WOODWORKING_BOOSTER] = CFGTYPE_BOOSTER_MATERIAL,
	},
	-- ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL	63
	-- ITEMTYPE_JEWELRYCRAFTING_MATERIAL		64
	-- ITEMTYPE_JEWELRYCRAFTING_BOOSTER			65
	-- ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER		67
	[CRAFTING_TYPE_JEWELRYCRAFTING] = CFGTYPE_JEWELRYCRAFTING,
	-- ITEMTYPE_INGREDIENT					10
	[CRAFTING_TYPE_PROVISIONING] = CFGTYPE_PROVISIONING,
	-- ITEMTYPE_ENCHANTING_RUNE_POTENCY		51
	-- ITEMTYPE_ENCHANTING_RUNE_ASPECT		52
	-- ITEMTYPE_ENCHANTING_RUNE_ESSENCE		53
	[CRAFTING_TYPE_ENCHANTING] = CFGTYPE_ENCHANTING,
	[CRAFTING_TYPE_ALCHEMY] = -- => ALCHEMY
	{
		getkey = function(item) return item.itemType end,
		-- ITEMTYPE_REAGENT						31
		[ITEMTYPE_REAGENT] = CFGTYPE_REAGENTS,
		-- ITEMTYPE_POTION_BASE					33
		-- ITEMTYPE_POISON_BASE					58
		[ITEMTYPE_POTION_BASE] = CFGTYPE_SOLVENT_POTION,
		[ITEMTYPE_POISON_BASE] = CFGTYPE_SOLVENT_POISON,
	},
}

--[[
TABLE[ITEMFILTERTYPE] => fonction qui détermine le prochain index :
	- ITEMFILTERTYPE_CRAFTING 		=> craftingType => (itemType)						=> filtre
	- ITEMFILTERTYPE_CONSUMABLE 	=> itemType											=> filtre
	- ITEMFILTERTYPE_MISCELLANEOUS  => itemType											=> filtre
	- ITEMFILTERTYPE_WEAPONS		=> weaponType	=> CRAFTING_TYPE_xxx				=> filtre
	- ITEMFILTERTYPE_ARMOR  		=> armorType	=> CRAFTING_TYPE_xxx				=> filtre
	- ITEMFILTERTYPE_JEWELRY		=> 				=> CRAFTING_TYPE_JEWELRYCRAFTING	=> filtre
]]--
local MAIN_TABLE =
{
	[ITEMFILTERTYPE_WEAPONS] = -- 1
	{
		getkey = function(item) return item.craftingType end,
		table = WEAPONS_ARMOR_JEWELRY,
	},
	[ITEMFILTERTYPE_ARMOR] = -- 2
	{
		getkey = function(item) return item.craftingType end,
		table = WEAPONS_ARMOR_JEWELRY,
	},
	[ITEMFILTERTYPE_CONSUMABLE] = -- 3
	{
		getkey = function(item) return item.itemType end,
		table = CONSUMABLE_LIST,
	},
	[ITEMFILTERTYPE_CRAFTING] = -- 4
	{
		getkey = function(item) return item.craftingType end,
		table = CRAFTING_LIST,
	},
	[ITEMFILTERTYPE_MISCELLANEOUS] = -- 5
	{
		getkey = function(item) return item.itemType end,
		table = MISCELLANEOUS_LIST,
	},
	[ITEMFILTERTYPE_JEWELRY] = -- 25
	{
		getkey = function(item) return item.craftingType end,
		table = WEAPONS_ARMOR_JEWELRY,
	},
}

----------------- Config Management -----------------------
local function add_to_controls(controls, inlist)
	for _, it in ipairs(inlist) do
		table.insert(controls, it)
	end
end

local function add_separator(list)
	table.insert(list.controls, {type = "custom"})
end

function addon:Build_Config_AutoJunking(config)
	add_to_controls(config.controls,
	{
		{
			-- Mise automatique d'objets aux rebus
			type = "header",
			name = Yellow_1:Colorize(GetString(SI_EASYLOOTASSISTANT_ITEMS_MARK_TITLE)),
		},
		{
			type = "description",
			text = GetString(SI_EASYLOOTASSISTANT_ITEMS_MARK_ITEMS_DESCRIPTION),
		},
		{
			type = "checkbox",
			name = GetString(SI_EASYLOOTASSISTANT_ITEMS_MARK_ITEMS),
			tooltip = GetString(SI_EASYLOOTASSISTANT_ITEMS_MARK_ITEMS_TT),
			getFunc = function() return self.settings_a.auto_junking.enabled end,
			setFunc = function(value) self.settings_a.auto_junking.enabled = value end,
			default = self.defaults_a.auto_junking.enabled,
		},
		{
			type = "checkbox",
			name = GetString(SI_EASYLOOTASSISTANT_ITEMS_MESSAGE),
			tooltip  = GetString(SI_EASYLOOTASSISTANT_ITEMS_MARK_ITEMS_MESSAGE_TT),
			getFunc  = function() return self.settings_a.auto_junking.showChatMessage end,
			setFunc  = function(value) self.settings_a.auto_junking.showChatMessage = value end,
			disabled = function() return not self.settings_a.auto_junking.enabled end,
			default  = self.defaults_a.auto_junking.showChatMessage,
		},
	})
end

function addon:Build_Config_AutoSelling(config)
	add_to_controls(config.controls,
	{
		{
			-- Vente automatique des objets mis au rebus
			type = "header",
			name = Yellow_1:Colorize(GetString(SI_EASYLOOTASSISTANT_ITEMS_SELL_JUNK_TITLE)),
		},
		{
			type = "checkbox",
			name = GetString(SI_EASYLOOTASSISTANT_ITEMS_SELL_JUNK),
			tooltip = GetString(SI_EASYLOOTASSISTANT_ITEMS_SELL_JUNK_TT),
			getFunc = function() return self.settings_a.auto_selling.enabled end,
			setFunc = function(value) self.settings_a.auto_selling.enabled = value end,
			default = self.defaults_a.auto_selling.enabled,
		},
		{
			type = "checkbox",
			name = GetString(SI_EASYLOOTASSISTANT_ITEMS_MESSAGE),
			tooltip  = GetString(SI_EASYLOOTASSISTANT_ITEMS_SELL_JUNK_MESSAGE_TT),
			getFunc  = function() return self.settings_a.auto_selling.showChatMessage end,
			setFunc  = function(value) self.settings_a.auto_selling.showChatMessage = value end,
			disabled = function() return not self.settings_a.auto_selling.enabled end,
			default  = self.defaults_a.auto_selling.showChatMessage,
		},
	})
end

function addon:Build_Config_AutoDestroy(config)
	add_to_controls(config.controls,
	{
		{
			-- Destruction automatique des objets mis au rebus
			type = "header",
			name = Red_1:Colorize(GetString(SI_EASYLOOTASSISTANT_ITEMS_AUTO_DESTROY_TITLE)),
		},
		{
			type = "checkbox",
			name = GetString(SI_EASYLOOTASSISTANT_ITEMS_AUTO_DESTROY_SIMULATION),
			getFunc = function() return self.settings_a.auto_destroy.simulation end,
			setFunc = function(value) self.settings_a.auto_destroy.simulation = value end,
			default = self.defaults_a.auto_destroy.simulation,
		},
		{
			type = "checkbox",
			name = GetString(SI_EASYLOOTASSISTANT_ITEMS_AUTO_DESTROY),
			tooltip = GetString(SI_EASYLOOTASSISTANT_ITEMS_AUTO_DESTROY_TT),
			getFunc = function() return not self.settings_a.auto_destroy.simulation and self.settings_a.auto_destroy.enabled end,
			setFunc = function(value) self.settings_a.auto_destroy.enabled = value end,
			disabled = function() return self.settings_a.auto_destroy.simulation end,
			default = self.defaults_a.auto_destroy.enabled,
			warning = GetString(SI_EASYLOOTASSISTANT_ITEMS_AUTO_DESTROY_WARNING),
		},
		{
			type = "checkbox",
			name = GetString(SI_EASYLOOTASSISTANT_ITEMS_MESSAGE),
			getFunc  = function() return self.settings_a.auto_destroy.showChatMessage or self.settings_a.auto_destroy.simulation end,
			setFunc  = function(value) self.settings_a.auto_destroy.showChatMessage = value end,
			disabled = function() return not self.settings_a.auto_destroy.enabled or self.settings_a.auto_destroy.simulation end,
			default  = self.defaults_a.auto_destroy.showChatMessage,
		},
	})
end

function addon:Build_Config_AutoTransferToBank(config)
	add_to_controls(config.controls,
	{
		{
			-- Transfert automatique dans la banque
			type = "header",
			name = Green_2:Colorize(GetString(SI_EASYLOOTASSISTANT_TRANSFER_AUTO)),
		},
		{
			type = "checkbox",
			name = GetString(SI_EASYLOOTASSISTANT_TRANSFER_ENABLED),
			getFunc  = function() return self.settings_c.autoTransferToBank.enabled end,
			setFunc  = function(value) self.settings_c.autoTransferToBank.enabled = value end,
			default  = self.defaults_c.autoTransferToBank.enabled,
		},
		{
			type = "checkbox",
			name = GetString(SI_EASYLOOTASSISTANT_ITEMS_MESSAGE),
			getFunc  = function() return self.settings_c.autoTransferToBank.showChatMessage end,
			setFunc  = function(value) self.settings_c.autoTransferToBank.showChatMessage = value end,
			disabled = function() return not self.settings_c.autoTransferToBank.enabled end,
			default  = self.defaults_c.autoTransferToBank.showChatMessage,
		},
		{
			type = "slider",
			name = GetString(SI_EASYLOOTASSISTANT_TRANSFER_DELAY),
			min = 0,
			max = 10,
			getFunc  = function() return self.settings_a.autoTransferToBank.delayS end,
			setFunc  = function(value) self.settings_a.autoTransferToBank.delayS = value end,
			default  = self.defaults_a.autoTransferToBank.delayS,
			disabled = function() return not self.settings_c.autoTransferToBank.enabled end,
		},
	})
end

function addon:Build_Config_TTC(config)
	add_to_controls(config.controls,
	{
		{
			-- Utilisation de TTC
			type = "header",
			name = Yellow_1:Colorize("Tamriel Trade Centre (TTC) add-on"),
		},
		{
			type = "checkbox",
			name = GetString(SI_EASYLOOTASSISTANT_TTC_ENABLED),
			getFunc  = function() return self.settings_a.price_TTC.enabled and TamrielTradeCentrePrice end,
			setFunc  = function(value) self.settings_a.price_TTC.enabled = value end,
			disabled = function() return not TamrielTradeCentrePrice end,
			default  = self.defaults_a.price_TTC.enabled,
		},
		{
			type = "editbox",
			name = GetString(SI_EASYLOOTASSISTANT_TTC_AUTO_DELETE),
			tooltip  = GetString(SI_EASYLOOTASSISTANT_TTC_AUTO_DELETE_TT),
			getFunc  = function() return self.settings_a.price_TTC.price_dont_destroy end,
			setFunc  = function(value) self.settings_a.price_TTC.price_dont_destroy = value end,
			disabled = function() return not self.settings_a.price_TTC.enabled or not TamrielTradeCentrePrice end,
			default  = self.defaults_a.price_TTC.price_dont_destroy,
		},
	})
end

local function buildGuildNameList()
	local guildListName = {}
	guildListName[1] = ZO_ColorDef:New("4c4c4c"):Colorize(GetString(SI_EASYLOOTASSISTANT_DISABLED_F))
	local nbg = GetNumGuilds()
	for i = 1, nbg do
		local guildID = GetGuildId(i)
		local guildName = GetGuildName(guildID)
		guildListName[1+i] = guildName
	end
	return guildListName
end

function addon:Build_Config_DefaultTradingHouse(config)
	add_to_controls(config.controls,
	{
		{
			-- Utilisation de TTC
			type = "header",
			name = Yellow_1:Colorize(GetString(SI_EASYLOOTASSISTANT_DEFAULT_TRADING_HOUSE)),
		},
		{
			type = "dropdown",
			name = GetString(SI_EASYLOOTASSISTANT_DEFAULT_TRADING_HOUSE),
			tooltip = "",
			choices = buildGuildNameList(),
			getFunc  = function() return self.settings_a.defaultTradingHouse.guildName end,
			setFunc  = function(value) self.settings_a.defaultTradingHouse.guildName = value end,
			default = "Default",
		},
	})
end

function addon:Build_Config_SearchUnknown(config)
	add_to_controls(config.controls,
	{
		{
			-- Search
			type = "header",
			name = Green_2:Colorize(GetString(SI_EASYLOOTASSISTANT_SEARCH_UNKNOWN)),
		},
		{
			type = "checkbox",
			name = GetString(SI_EASYLOOTASSISTANT_SEARCH_INFORM_LOOT_UNKNOWN),
			tooltip  = GetString(SI_EASYLOOTASSISTANT_SEARCH_INFORM_LOOT_UNKNOWN_TT),
			getFunc  = function() return self.settings_c.search_unknown.enabled_loot_chat_message end,
			setFunc  = function(value) self.settings_c.search_unknown.enabled_loot_chat_message = value end,
			default  = self.defaults_c.search_unknown.enabled_loot_chat_message,
		},
		{
			type = "checkbox",
			name = GetString(SI_EASYLOOTASSISTANT_SEARCH_ENABLE_SEARCH_BANK),
			tooltip  = GetString(SI_EASYLOOTASSISTANT_SEARCH_ENABLE_SEARCH_BANK_TT),
			getFunc  = function() return self.settings_c.search_unknown.enabled_search end,
			setFunc  = function(value) self.settings_c.search_unknown.enabled_search = value end,
			default  = self.defaults_c.search_unknown.enabled_search,
		},
		{
			type = "checkbox",
			name = GetString(SI_EASYLOOTASSISTANT_SEARCH_ENABLE_SEARCH_AUTO_BANK),
			tooltip  = GetString(SI_EASYLOOTASSISTANT_SEARCH_ENABLE_SEARCH_AUTO_BANK_TT),
			getFunc  = function() return self.settings_c.search_unknown.enabled_auto_search end,
			setFunc  = function(value) self.settings_c.search_unknown.enabled_auto_search = value end,
			default  = self.defaults_c.search_unknown.enabled_auto_search,
		},
	})
end

function addon:Build_Config_Divers(config)
	add_to_controls(config.controls,
	{
		{
			-- enablePrintLoot
			-- Divers
			type = "header",
			name = GetString(SI_ITEMFILTERTYPE5),
		},
		{
			type = "checkbox",
			name = Green_2:Colorize(GetString(SI_EASYLOOTASSISTANT_LOOT_CHAT_MESSSAGE)),
			getFunc  = function() return self.settings_c.enablePrintLoot end,
			setFunc  = function(value) self.settings_c.enablePrintLoot = value end,
			default  = self.defaults_c.enablePrintLoot,
		},
		{
			type = "checkbox",
			name = Yellow_1:Colorize(GetString(SI_EASYLOOTASSISTANT_MSG_BAG_FULL)),
			getFunc  = function() return self.settings_a.backpack.alarm_enabled end,
			setFunc  = function(value) self.settings_a.backpack.alarm_enabled = value end,
			default  = self.defaults_a.backpack.alarm_enabled,
		},
		{
			type = "slider",
			name = Yellow_1:Colorize(GetString(SI_EASYLOOTASSISTANT_SLOT_ALERT)),
			min = 2,
			max = 10,
			getFunc  = function() return self.settings_a.backpack.alarm_threshold end,
			setFunc  = function(value) self.settings_a.backpack.alarm_threshold = value end,
			default  = self.defaults_a.backpack.alarm_threshold,
			disabled = function() return not self.settings_a.backpack.alarm_enabled end,
		},
	})
end

local function buildExceptionList()
	--[[local guildListName = {}
	guildListName[1] = ZO_ColorDef:New("4c4c4c"):Colorize(GetString(SI_EASYLOOTASSISTANT_DISABLED_F))
	local nbg = GetNumGuilds()
	for i = 1, nbg do
		local guildID = GetGuildId(i)
		local guildName = GetGuildName(guildID)
		guildListName[1+i] = guildName
	end
	return guildListName
	--]]
	df("buildExceptionList")
	--self.defaults_a.ItemExceptionList
	local list = {"apats : delete", "potion : keep"}
	--for i, k in ipairs(self.defaults_a.ItemExceptionList) do
	--	list[i] = k
	--end
	return list
end

local ItemIDExceptionMap =
{
	["delete"] = function(items) apply_result(items, ITEM_RESULT_TO_DELETE) end,
	["keep"] = function(items) apply_result(items, ITEM_RESULT_KEEP) end,
	["junk"] = function(items) apply_result(items, ITEM_RESULT_JUNK) end,
	["force_transfer_to_bank"] = function(items) 
		for _, it in ipairs(items) do
			it.result = ITEM_RESULT_KEEP
			it.forceBankTransfer = FORCE_BANK_TRANSFER_TO_BANK
		end
	end,
	["no_transfer"] = function(items) 
		for _, it in ipairs(items) do
			it.result = ITEM_RESULT_KEEP
			it.forceBankTransfer = FORCE_BANK_TRANSFER_DONT_TRANSFER
		end
	end,
}

function addon:Build_Config_Debug(config)
	add_to_controls(config.controls,
	{
		{
			-- DEBUG
			type = "header",
			name = Yellow_1:Colorize("Debug"),
		},
		{
			type = "checkbox",
			name = "Debug mode",
			getFunc  = function() return self.settings_a.debug.enabled end,
			setFunc  = function(value) 
				self.settings_a.debug.enabled = value 
				self:SetDebugLevel()
			end,
			default  = self.settings_a.debug.enabled,
			--requiresReload = true,
		},
		{
			type = "slider",
			name = "Debug level",
			min = 0,
			max = 2,
			getFunc  = function() return self.settings_a.debug.level end,
			setFunc  = function(value) 
				self.settings_a.debug.level = value 
				self:SetDebugLevel()
			end,
			default  = self.settings_a.debug.level,
			disabled = function() return not self.settings_a.debug.enabled end,
		},
	})
end

function addon:Build_Config_General()
	local config =
	{
		type = "submenu",
		name = GetString(SI_KEYBINDINGS_CATEGORY_GENERAL),
		controls = {},
	}
	self:Build_Config_AutoJunking(config)
	add_separator(config)
	self:Build_Config_AutoSelling(config)
	add_separator(config)
	self:Build_Config_AutoDestroy(config)
	add_separator(config)
	self:Build_Config_AutoTransferToBank(config)
	add_separator(config)
	self:Build_Config_TTC(config)
	add_separator(config)
	self:Build_Config_DefaultTradingHouse(config)
	add_separator(config)
	self:Build_Config_SearchUnknown(config)
	add_separator(config)
	self:Build_Config_Divers(config)
	add_separator(config)
	self:Build_Config_Debug(config)
	return config
end

-- Build settings table from config
function addon:BuildRulesSettings()
	local settings_a = {}
	local settings_c = {}
	for _, cfg in ipairs(CONFIG_RULES) do
		for _, cfgitem in ipairs(cfg.items) do
			if cfgitem.widgets then
				local itemsettings_a = {}
				local itemsettings_c = {}
				for _, cfgwidget in ipairs(cfgitem.widgets) do
					local widget_def = self.WIDGETS[cfgwidget]
					if widget_def.type then
						if widget_def.type == "combo" then
							local combosettings = {}
							combosettings.enabled = widget_def.checkbox.default
							combosettings.value = widget_def.widget.default
							itemsettings_a[cfgwidget] = combosettings
						else
							if widget_def.character then
								itemsettings_c[cfgwidget] = widget_def.default
							else
								itemsettings_a[cfgwidget] = widget_def.default
							end
						end
					end
				end
				settings_a[cfgitem.cfg] = itemsettings_a
				if tableLength(itemsettings_c) > 0 then
					settings_c[cfgitem.cfg] = itemsettings_c
				end
				CONFIG_RULES_WIDGETS[cfgitem.cfg] = cfgitem.widgets
			end
		end
	end
	self.defaults_a["rules"] = settings_a
	if tableLength(settings_c) > 0 then		
		self.defaults_c["rules"] = settings_c
	end
end

-- copy from widget_def to control
local function copy_widget(widget_def, ctrl)
	for key, value in pairs(widget_def) do
		ctrl[key] = value
	end
	if ctrl.character then
		ctrl.name = Green_2:Colorize(ctrl.name)
	end
end

local function build_color(str, mode)
	if mode then
		return Green_2:Colorize(str)
	else
		return str
	end
end

local function ShowMsgBox(msg)
	local dialog = 
	{
		title = { text = addon.name },
		mainText = { text = msg },
		buttons = 
		{
			{
				text = "OK", 
			}
		}
   }
   ZO_Dialogs_RegisterCustomDialog("EasyLootAssistantDialog1", dialog)
   ZO_Dialogs_ReleaseDialog("EasyLootAssistantDialog1", false)
   ZO_Dialogs_ShowDialog("EasyLootAssistantDialog1")
end

-- Build options table from config
function addon:Build_Config_FromJunkRules(optionsTable)
	self.settings_rules_a = self.settings_a["rules"]
	self.settings_rules_c = self.settings_c["rules"]

	-- Process RULES VERSION
	if self.settings_rules_a.version == nil or self.settings_rules_a.version == 1 then
		self.settings_rules_a.version = 2
		zo_callLater(function() 
			ShowMsgBox(GetString(SI_EASYLOOTASSISTANT_UPGRADE_MSG))
		end, 20000) -- 20s
	end

	for _, cfg in ipairs(CONFIG_RULES) do

		local ctrl_main = {type = "submenu", name = cfg.name, controls = {}}
		for _, cfgitem in ipairs(cfg.items) do

			local itemsettings_a = self.settings_rules_a[cfgitem.cfg]
			local itemsettings_c = self.settings_rules_c[cfgitem.cfg]

			local function get_itemsettings(_cfgwidget)
				local i1 = itemsettings_a[_cfgwidget]
				if i1 == nil then
					return itemsettings_c[_cfgwidget]
				else
					return i1
				end
			end
			local function set_itemsettings(_cfgwidget, _v)
				local i1 = itemsettings_a[_cfgwidget]
				if i1 == nil then
					itemsettings_c[_cfgwidget] = _v
				else
					itemsettings_a[_cfgwidget] = _v
				end
			end

			if cfgitem.title then
				local ctrl_header = {type="header", name=zo_strformat(SI_INVENTORY_HEADER, GetString(cfgitem.title.prefix, cfgitem.title.idx))}
				table.insert(ctrl_main.controls, ctrl_header)
			end

			if cfgitem.widgets then
				-- Mettre de coté l'option global master 'keepALL'
				local master = nil

				local function get_master(cfgwidget)
					if master and (master ~= cfgwidget) then 
						return get_itemsettings(master)
					else
						return false
					end
				end

				for _, cfgwidget in ipairs(cfgitem.widgets) do
					local widget_def = self.WIDGETS[cfgwidget]
					if widget_def.master then
						master = cfgwidget
					end
					if widget_def.type then						
						if widget_def.type == "combo" then
							-- combo
							local combosettings = get_itemsettings(cfgwidget)
							local ctrl_checkbox = {
								disabled = function() return get_master(cfgwidget) end,
								getFunc  = function() return combosettings.enabled end,
								setFunc  = function(value) combosettings.enabled = value end }
							copy_widget(widget_def.checkbox, ctrl_checkbox)
							table.insert(ctrl_main.controls, ctrl_checkbox)	
							
							local ctrl_value = {
								disabled = function() return get_master(cfgwidget) or not combosettings.enabled end,
								getFunc = function() return combosettings.value end,
								setFunc = function(value) combosettings.value = value end }
							copy_widget(widget_def.widget, ctrl_value)
							table.insert(ctrl_main.controls, ctrl_value)	
						else
							local ctrl = {
								disabled = function() return get_master(cfgwidget) end,
								getFunc = function() return get_itemsettings(cfgwidget) end,
								setFunc = function(value) set_itemsettings(cfgwidget, value) end }
							copy_widget(widget_def, ctrl)
							table.insert(ctrl_main.controls, ctrl)
						end
					end
				end
			end
		end

		table.insert(optionsTable, ctrl_main)
	end
end
----------------- Config Management End -------------------

----------------- Waste Management -----------------------
function addon:GetAutoDestroyMode()
	return self.settings_a.auto_destroy.simulation or self.settings_a.auto_destroy.enabled
end

function addon:GetAutoDestroyRealMode()
	return not self.settings_a.auto_destroy.simulation and self.settings_a.auto_destroy.enabled
end

function addon:GetAutoDestroyChatMessage()
	return self.settings_a.auto_destroy.simulation or self.settings_a.auto_destroy.showChatMessage
end

-- Process de décision si delete en fonction du prix
function addon:DestroyProcessItem(item)
	if (item.result == ITEM_RESULT_JUNK) and (item.sellPrice == 0) and (item.ttc_price < tonumber(self.settings_a.price_TTC.price_dont_destroy)) then
		item.result = ITEM_RESULT_TO_DELETE
	end
end
function addon:DestroyProcess(items)
	for _, it in ipairs(items) do
		self:DestroyProcessItem(it)
	end
end

-- Process générique
function addon:ProcessFilterGeneric(items, cfg_filter)
	local item = items[1]
	if type(cfg_filter) == "table" and cfg_filter.getkey then
		cfg_filter = cfg_filter[cfg_filter.getkey(item)]
	end
	if self.debug_level > 1 then
		df("%s: cfg=%d", item.itemLink, cfg_filter)
	end
	if cfg_filter then
		for _, it in ipairs(items) do
			it.cfg = cfg_filter
		end
		-- Attention l'ordre de déclaration des filtres est important !
		-- Donc on prend l'ordre dans CONFIG_RULES_WIDGETS et on va chercher les valeurs dans les settings_rules_a
		-- La fonction de process se trouve, elle, dans WIDGETS
		local filters_a = self.settings_rules_a[cfg_filter]
		if filters_a then

			-- Attention: ne pas recopier 'filters_c' dans 'filters_a' sinon vous allez propager les infos 
			-- directement dans 'settings_rules_a' et donc dans la config du perso !
			local filters_c = self.settings_rules_c[cfg_filter]
			if filters_c then
				if self.debug_level > 1 then
					d(filters_c)
				end
			else
				filters_c = {}
			end

			for key, filter_item in pairs(CONFIG_RULES_WIDGETS[cfg_filter]) do
				if self.debug_level > 1 then
					d(filter_item)
					d(filters_a[filter_item])
				end
				local process = self.WIDGETS[filter_item].process
				if process then
					process(items, filters_a[filter_item], filters_c[filter_item])
				end
			end
		end
	end
end

-- ITEMFILTERTYPE_CONSUMABLE => ITEMTYPE_RECIPE
-- 								ITEMTYPE_RACIAL_STYLE_MOTIF
--								ITEMTYPE_CONTAINER + SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE
function addon:CheckIfUnknown(item)
	if item.filterType == ITEMFILTERTYPE_CONSUMABLE then	
		if item.itemType == ITEMTYPE_RECIPE and not IsItemLinkRecipeKnown(item.itemLink) then
			item.result = ITEM_RESULT_TO_LEARN
			return item
		elseif item.itemType == ITEMTYPE_RACIAL_STYLE_MOTIF and not IsItemLinkBookKnown(item.itemLink) then
			item.result = ITEM_RESULT_TO_LEARN
			return item
		elseif item.itemType == ITEMTYPE_CONTAINER and item.specializedItemType == SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE then
			if IsContainerCollectibleUnknown(item.itemLink) then
				item.result = ITEM_RESULT_TO_LEARN
				return item
			end
		end
	end
	return
end

function addon:PrintItemResult(items)
	if self.debug_level > 1 then
		for _, it in ipairs(items) do
			--df("INFO %s = %d", it.itemLink, it.result)
		end
	end
end

-- Process de décision (attention prend en paramètre une liste d'item !)
function addon:CheckIfJunk(items)
	local item = items[1]
	if item.filterType == ITEMFILTERTYPE_CONSUMABLE then
		self:CheckIfUnknown(item)
	end
	if item.result == ITEM_RESULT_NOT_PROCESSED then
		local exception_state = self.settings_a.ItemIDExceptionList[item.itemId]
		if item.isOrnate and self.settings_rules_a[CFGTYPE_ORNATE]["keepOrnate"] == false then
			apply_result(items, ITEM_RESULT_JUNK)
		elseif exception_state then  
			exception_state = ItemIDExceptionMap[exception_state]
			exception_state(items)
		end
		if item.result == ITEM_RESULT_NOT_PROCESSED then
			local table_filter = MAIN_TABLE[item.filterType]
			if self.debug_level > 1 then
				df("%s : FT=%d", item.itemLink, item.filterType)
			end
			if table_filter then
				local key = table_filter.getkey(item)
				local cfg_filter = table_filter.table[key]
				if self.debug_level > 1 then
					df("k=%d",key)
				end
				if cfg_filter then
					self:ProcessFilterGeneric(items, cfg_filter)
				end
			end
		end
		for _, it in ipairs(items) do
			-- forceBankTransfer = FORCE_BANK_TRANSFER_DEFAULT       => transfert si bankCount > 0 et pile en banque non pleine
			-- forceBankTransfer = FORCE_BANK_TRANSFER_DONT_TRANSFER => pas de transfert
			-- forceBankTransfer = FORCE_BANK_TRANSFER_TO_BANK       => force le transfert dans la banque (création si besoin)
			if it.result == ITEM_RESULT_KEEP and it.keepLock == false then
				if it.forceBankTransfer == FORCE_BANK_TRANSFER_DEFAULT then
					if it.bankCount > 0 then
						if it.stack == it.maxStack and it.maxStack > 1 then
							if self.settings_c.autoTransferToBank.transfertFullStack then
								it.bankTransfer = BANK_TRANSFER_TO_BANK_IF_POSSIBLE
							end
						else
							it.bankTransfer = BANK_TRANSFER_TO_BANK_IF_POSSIBLE
						end
					end
				elseif it.forceBankTransfer == FORCE_BANK_TRANSFER_TO_BANK then
					it.bankTransfer = BANK_TRANSFER_TO_BANK_FORCE
				elseif it.forceBankTransfer == FORCE_BANK_TRANSFER_FROM_BANK then
					it.bankTransfer = BANK_TRANSFER_FROM_BANK_FORCE
				end
			end
			if it.craftingLevel == 160 then
				if it.transferCP160 == FORCE_BANK_TRANSFER_FROM_BANK then
					it.bankTransfer = BANK_TRANSFER_FROM_BANK_FORCE
				elseif it.transferCP160 == FORCE_BANK_TRANSFER_TO_BANK then
					it.bankTransfer = BANK_TRANSFER_TO_BANK_FORCE
				elseif it.transferCP160 == FORCE_BANK_TRANSFER_DONT_TRANSFER then
					it.bankTransfer = BANK_TRANSFER_NO_TRANSFER
				end
			end
		end
	end
	if self:GetAutoDestroyMode() then
		self:DestroyProcess(items)
	end
	self:PrintItemResult(items)
end

-- Construction d'un objet avec les infos de base (bagId, slotIndex, itemLink, itemId, filterType, itemType, itemTraitInformation, stack, maxStack, quality)
-- Si l'objet est crafté, verrouillé, volé ou ne peut pas être vendu alors il n'est pas pris en compte
function addon:BuildSecurItem(bagId, slotIndex, processJunkOnly)
	if processJunkOnly == nil or processJunkOnly == false then
		if IsItemJunk(bagId, slotIndex) then return end
	else
		if not IsItemJunk(bagId, slotIndex) then return end
	end
	if IsItemPlayerLocked(bagId, slotIndex) then return end
	local itemLink = GetItemLink(bagId, slotIndex)
	if itemLink ~= "" then
		if not IsItemLinkCrafted(itemLink) and not IsItemLinkStolen(itemLink) and IsItemLinkCanBeSell(itemLink) then
			local item = {bagId = bagId, slotIndex = slotIndex, itemLink = itemLink, result = ITEM_RESULT_NOT_PROCESSED}
			item.bankTransfer = BANK_TRANSFER_NO_TRANSFER
			item.forceBankTransfer = FORCE_BANK_TRANSFER_DEFAULT
			item.transferCP160 = FORCE_BANK_TRANSFER_DEFAULT
			item.keepLock = false
			item.test = 0
			item.itemId = GetItemLinkItemId(itemLink)
			item.filterType = GetItemLinkFilterTypeInfo(itemLink)
			item.itemType, item.specializedItemType = GetItemLinkItemType(itemLink)
			item.itemTraitInformation = GetItemTraitInformationFromItemLink(itemLink)
			item.quality = GetItemLinkQuality(itemLink)
			item.stack, item.maxStack = GetSlotStackSize(bagId, slotIndex)
			item.sellPrice = GetItemSellValueWithBonuses(bagId, slotIndex)
			item.inventoryCount, item.bankCount, item.craftBagCount = GetItemLinkStacks(item.itemLink)
			item.ttc_price = self:GetTTCPriceInfo(item.itemLink)
			item.isOrnate = (item.itemTraitInformation == ITEM_TRAIT_INFORMATION_ORNATE)
			if item.filterType == ITEMFILTERTYPE_WEAPONS then
				item.craftingType = GetCraftingType(item.itemLink)
			elseif item.filterType == ITEMFILTERTYPE_ARMOR then
				item.craftingType = GetCraftingType(item.itemLink)
			elseif item.filterType == ITEMFILTERTYPE_JEWELRY then
				item.craftingType = CRAFTING_TYPE_JEWELRYCRAFTING
			else
				item.craftingType = GetItemLinkCraftingSkillType(item.itemLink)
			end
			item.craftingLevel = GetItemCraftingLevel(item)
			return item
		else -- stolen or cannot be sell or crafted
			local item = {bagId = bagId, slotIndex = slotIndex, itemLink = itemLink, result = ITEM_RESULT_NOT_PROCESSED}
			item.itemId = GetItemLinkItemId(itemLink)
			item.filterType = GetItemLinkFilterTypeInfo(itemLink)
			item.itemType, item.specializedItemType = GetItemLinkItemType(itemLink)
			return self:CheckIfUnknown(item) -- return item only if ITEM_RESULT_TO_LEARN
		end
	end
	return 
end

-- Construit une liste 'sécurisé' d'objets rangés par itemId
function addon:GenerateSecurListOfStackedItems(bagId, processJunkOnly, sort_ascent)
	local list = {}
	for slotIndex in ZO_IterateBagSlots(bagId) do
		local item = self:BuildSecurItem(bagId, slotIndex, processJunkOnly)
		if item then
			if list[item.itemId] == nil then
				list[item.itemId] = {item}
			else
				table.insert(list[item.itemId], item)
			end
		end
	end
	for _, items in pairs(list) do
		-- on ne garde que les stacks les plus pleines -> donc il faut faire un trie par stack size de la plus grande à la plus petite
		if #items > 1 then
			if sort_ascent then
				table.sort(items, function(a,b) 
						if a.stack ~= nil and b.stack ~= nil then
							return a.stack < b.stack 
						else
							return 0
						end
					end)
			else
				table.sort(items, function(a,b) 
					if a.stack ~= nil and b.stack ~= nil then
						return a.stack > b.stack 
					else
						return 0
					end
				end)
			end
		end
		self:CheckIfJunk(items)
	end
	return list
end

function addon:PrintItemInfo(item)
	if item then
		local info = "     "
		if item.result == ITEM_RESULT_JUNK then
			info = Cyan:Colorize("JUNK  ")
		elseif item.result == ITEM_RESULT_KEEP then
			if item.keepLock then
				info = Red_1:Colorize("KEPT  ")
			else
				info = Green:Colorize("KEPT  ")
			end
		elseif item.result == ITEM_RESULT_TO_DELETE then
			info = Red_1:Colorize("Del!  ")
		elseif item.result == ITEM_RESULT_TO_LEARN then
			info = Red_1:Colorize("LEARN ")
		else
			info = White:Colorize(string.format("Kept%d ",item.result))
		end

		local strhdr = ""
		local strp = ""
		if self.debug_level > 0 then
			strhdr = string.format("%s [%02d.%02d.S%d] ", info, item.filterType, item.itemType, item.specializedItemType)
			if item.craftingType then
				strhdr = strhdr .. string.format("[C%d] ", item.craftingType)
			end
			if item.cfg then
				strhdr = strhdr .. string.format("(F%d) ", item.cfg)
			end
			strp = " : "
			if item.level then
				strp = strp .. string.format("L%d ", item.level)
			end
			if item.itemTraitInformation then
				strp = strp .. string.format("TI%d Q%d S%d/%d ", item.itemTraitInformation, item.quality, item.stack, item.maxStack)
			end
			if item.inventoryCount then
				strp = strp .. string.format("I%d B%d A%d ", item.inventoryCount, item.bankCount, item.craftBagCount)
			end
			if item.sellPrice and item.sellPrice == 0 or item.result == ITEM_RESULT_TO_DELETE then
				--strp = strp .. string.format("P=%d TTC=%d", item.sellPrice * item.stack, item.ttc_price * item.stack)
				strp = strp .. string.format("TTC:%d ", item.ttc_price * item.stack)
			end
			if item.craftingLevel > 0 then
				strp = strp .. string.format("CL:%d ", item.craftingLevel)
			end
			if item.isOrnate then
				strp = strp .. " Ornate"
			end
			if item.bankTransfer > BANK_TRANSFER_NO_TRANSFER then
				strp = strp .. string.format(" TBank%d!",item.bankTransfer)
			end
		else
			strhdr = info .. " "
		end
		local link = item.itemLink .. string.format(" (Id:%d)", item.itemId)
		d(strhdr .. link .. strp)
	end
end

local function CreateChatList(message)
	list = LibLootSummary:New({chat = LCM})
	list:SetHideSingularQuantities(true)
	list:SetDelimiter(", ")
	list:SetShowTrait(true)
	list:SetShowIcon(true)
	list:SetLinkStyle(LINK_STYLE_BRACKETS)
	list:SetPrefix(message)
	return list
end

function addon:ScanBagForJunk(bagId, printinfo)
	local junk_chat_list = nil
	if printinfo == nil and self.settings_a.auto_junking.showChatMessage then
		junk_chat_list = CreateChatList(GetString(SI_EASYLOOTASSISTANT_ITEMS_MARKED_AS_JUNK))
	end

	local delete_chat_list = nil
	if self:GetAutoDestroyMode() and self:GetAutoDestroyChatMessage() then
		if self:GetAutoDestroyRealMode() then
			delete_chat_list = CreateChatList(Red_1:Colorize(GetString(SI_EASYLOOTASSISTANT_DESTROY_MESSAGE)))
		else
			delete_chat_list = CreateChatList(Red_1:Colorize(GetString(SI_EASYLOOTASSISTANT_SIMULDESTROY_MESSAGE)))
		end
	end

	-- Construction de la liste de objets
	local list = self:GenerateSecurListOfStackedItems(bagId)

	-- Process Junk/Delete
	if printinfo then
		df("ScanBagForJunk for bag %s (%d)", bagStr[bagId], bagId)
		for _, items in pairs(list) do
			for _,item in ipairs(items) do
				self:PrintItemInfo(item)
			end
		end
	else
		for _, items in pairs(list) do
			for _, item in ipairs(items) do
				if item.result == ITEM_RESULT_JUNK then
					SetItemIsJunk(item.bagId, item.slotIndex, true)
					if junk_chat_list then
						junk_chat_list:AddItemLink(item.itemLink, item.stack)
					end
				elseif item.result == ITEM_RESULT_TO_DELETE then
					if self:GetAutoDestroyRealMode() then
						DestroyItem(item.bagId, item.slotIndex)
					else
						SetItemIsJunk(item.bagId, item.slotIndex, true)
					end
					if delete_chat_list then
						delete_chat_list:AddItemLink(item.itemLink, item.stack)
					end
				end
			end
		end
	end

	if junk_chat_list and junk_chat_list.itemList then
		junk_chat_list:Print()
	end
	if delete_chat_list and delete_chat_list.itemList then
		delete_chat_list:Print()
	end
end

-- Scan pour rechercher les objets à détruites
function addon:ScanBagForDelete(bagId, delete)
	local delete_list = {}
	local function callback(list)
		for _, item in ipairs(delete_list) do
			DestroyItem(item.bagId, item.slotIndex)
		end
	end
	local delete_chat_list = CreateChatList(Red_1:Colorize(GetString(SI_EASYLOOTASSISTANT_DESTROY_LIST)))
	local list = self:GenerateSecurListOfStackedItems(bagId, PROCESS_JUNK_ONLY)
	for _, items in pairs(list) do
		for _, item in ipairs(items) do
			if item.result == ITEM_RESULT_TO_DELETE then
				delete_chat_list:AddItemLink(item.itemLink, item.stack)
				if delete then
					table.insert(delete_list, item)
				end
			end
		end
	end
	if next(delete_chat_list.itemList) ~= nil then
		delete_chat_list:Print()
		if delete and LibAddonMenu2 and #delete_list > 0 then
			LibAddonMenu2.util.ShowConfirmationDialog(addon.title, GetString(SI_EASYLOOTASSISTANT_DESTROY_FCT_MSG), callback)
		end
	else
		self:Printf(GetString(SI_EASYLOOTASSISTANT_DESTROY_NONE))
	end
end

-- Scan pour rechercher les recettes, plans et motif inconnus
function addon:ScanBagForUnknown(bagId, message_if_empty)
	if self.debug_level > 1 then
		df("addon:ScanBagForUnknown(%d,%s)", bagId, tostring(message_if_empzty))
	end
	if bagId ~= nil then
		--[[if bagId >= BAG_HOUSE_BANK_ONE and bagId <= BAG_HOUSE_BANK_TEN then
			local collectibleId = GetCollectibleForHouseBankBag(nagId)
			if IsCollectibleUnlocked(collectibleId) then
				df(" => '%s' (%s)", GetCollectibleName(collectibleId), GetCollectibleNickname(collectibleId))
			end
		end]]
		local chatList = CreateChatList(GetString(SI_EASYLOOTASSISTANT_SEARCH_CAN_BE_LEARNED))
		for slotIndex in ZO_IterateBagSlots(bagId) do
			local itemLink = GetItemLink(bagId, slotIndex)
			if itemLink ~= "" then
				local item = {bagId = bagId, slotIndex = slotIndex, itemLink = itemLink}
				item.itemType, item.specializedItemType = GetItemLinkItemType(itemLink)
				item.filterType = GetItemLinkFilterTypeInfo(itemLink)
				item.itemId = GetItemLinkItemId(itemLink)
				item.stack = GetSlotStackSize(bagId, slotIndex)
				item.uniqueId = GetItemUniqueId(bagId, slotIndex)
				if item.uniqueId == nil then
					item.uniqueId = item.itemId
				end
				if self:CheckIfUnknown(item) then
					if self.debug_level > 1 then
						df("  > %s (%d)", item.itemLink, item.stack)
					end
					-- Check and managed unknownLockList only if process BAG_BACKPACK
					local add_to_chat = true
					if bagId == BAG_BACKPACK then
						if self.unknownLockList[item.uniqueId] == nil then
							self.unknownLockList[item.uniqueId] = item.itemLink
						else
							add_to_chat = false
						end
					end
					if add_to_chat then
						chatList:AddItemLink(item.itemLink, item.stack)
					end
				end
			end
		end
		if next(chatList.itemList) ~= nil then
			chatList:Print()
		elseif message_if_empty == nil or message_if_empty == true and self.settings_c.search_unknown.enabled_loot_chat_message then
			self:Printf(GetString(SI_EASYLOOTASSISTANT_SEARCH_NO_UNKNOWN_FOUND))
		end
	end
end

function addon:UnJunkAll(bagId)
	for slotIndex in ZO_IterateBagSlots(bagId) do
		-- Only items marked as a junk
		if IsItemJunk(bagId, slotIndex) then
			SetItemIsJunk(bagId, slotIndex, false)
		end
	end
end

function addon:PrintUnknownLockList()
	self:Printf("UnknownLockList: ")
	for _, itemLink in pairs(self.unknownLockList) do
		d(itemLink)
	end
end

-- OnLootReceived version différée
function addon:OnLootReceived_Delayed()
	if self.settings_c.search_unknown.enabled_loot_chat_message then
		self:ScanBagForUnknown(BAG_BACKPACK, false)
	end
	if self.settings_a.auto_junking.enabled then
		self:ScanBagForJunk(BAG_BACKPACK)
	end
	if self.settings_a.backpack.alarm_enabled then
		local free_slots = GetNumBagFreeSlots(BAG_BACKPACK)
		if free_slots < self.settings_a.backpack.alarm_threshold then
			self:ColorPrintf(Red_1, GetString(SI_EASYLOOTASSISTANT_FREE_SLOT), free_slots)
		end
	end
end

function addon:CanItemsBeStoredInCraftBag(itemLink)
	-- Filter Type = CRAFTING
	-- Item Type = LURE
	if HasCraftBagAccess() and (GetItemLinkFilterTypeInfo(itemLink) == ITEMFILTERTYPE_CRAFTING or GetItemLinkItemType(itemLink) == ITEMTYPE_LURE) then
		return true
	end
	return false
end

-- EVENT_LOOT_RECEIVED (*string* _receivedBy_, *string* _itemName_, *integer* _quantity_, *[ItemUISoundCategory|#ItemUISoundCategory]* _soundCategory_, 
--						*[LootItemType|#LootItemType]* _lootType_, *bool* _self_, *bool* _isPickpocketLoot_, *string* _questItemIcon_, *integer* _itemId_, *bool* _isStolen_)
function addon:OnLootReceived(_, receivedBy, itemLink, quantity, _, lootType, player, _, _, itemId)
	if not player then return end
	if not lootType == LOOT_TYPE_ITEM then return end

	local run_callLater = not self:CanItemsBeStoredInCraftBag(itemLink)
	
	if self.settings_c.enablePrintLoot and run_callLater then
		self:Printf("%s", itemLink)
	end

	-- Gestion d'un délai d'appel à la fonction de process pour éviter les appels trop rapproché dans le temps
	if run_callLater then
		local time = GetFrameTimeMilliseconds()
		if time >= self.fct_delayed_stop_time then
			local delay = 500
			self.fct_delayed_start_time = time
			self.fct_delayed_stop_time = self.fct_delayed_start_time + delay
			zo_callLater(function() self:OnLootReceived_Delayed() end, delay)
		end
	end
end
----------------- End Waste Management -----------------------

----------------- Store / Fence ------------------------------
function addon:OnOpenStore()
	if self.debug_level > 1 then
		df("addon:OnOpenStore: CanStoreRepair = %s, IsStoreEmpty = %s",tostring(CanStoreRepair()), tostring(IsStoreEmpty()))
	end
	-- Check si marchande (pas de panneau d'achat)
	if IsStoreEmpty() then
		self.Buttons.SellAllJunk.enable_use = true
		KEYBIND_STRIP:AddKeybindButton(self.Buttons.SellAllJunk)
	end
	if self.settings_a.auto_selling.enabled and HasAnyJunk(BAG_BACKPACK, true) then
		if self.settings_a.auto_selling.showChatMessage then
			self:Printf(GetString(SI_EASYLOOTASSISTANT_AUTO_SELL))
		end
		SellAllJunk()
	end
end

function addon:OnCloseStore()
	self.Buttons.SellAllJunk.enable_use = false
	KEYBIND_STRIP:RemoveKeybindButton(self.Buttons.SellAllJunk)
end
----------------- End Store / Fence --------------------------

----------------- Bank ---------------------------------------

local function requestMoveItem(sourceBag, sourceSlot, destBag, destSlot, stackCount)
    if IsProtectedFunction("RequestMoveItem") then
        CallSecureProtected("RequestMoveItem", sourceBag, sourceSlot, destBag, destSlot, stackCount)
	else
        RequestMoveItem(sourceBag, sourceSlot, destBag, destSlot, stackCount)
    end
end

-- Transfert d'un objet dans la banque (s'il y a de la place dans une des stacks)
function addon:MoveItemToBank(bank_list, item, emptySlots)
	-- on transfert dans les piles existantes pour commencer
	if bank_list then
		local bank_items = bank_list[item.itemId]
		if bank_items then
			for _, bank_item in ipairs(bank_items) do
				if bank_item.stack < bank_item.maxStack then
					local quantity = zo_min(bank_item.maxStack-bank_item.stack, item.stack)
					if self.debug_level > 1 then
						df("MoveItemToBank >> %s (%d/%d) : %d", bank_item.itemLink, bank_item.stack, bank_item.maxStack, quantity)
					end
					requestMoveItem(BAG_BACKPACK, item.slotIndex, BAG_BANK, bank_item.slotIndex, quantity)
					bank_item.stack = bank_item.stack + quantity
					if bank_item.stack == bank_item.maxStack then
						self:ColorPrintf(Red_1,GetString(SI_EASYLOOTASSISTANT_STACK_FULL), bank_item.itemLink)
					end
					return quantity
				end
			end
		end
	end
	if emptySlots and #emptySlots then
		local quantity = item.stack
		if self.debug_level > 0 then
			df("MoveItemToBank(F) >> %s (%d/%d) : %d", item.itemLink, item.stack, item.maxStack, quantity)
		end
		local emptySlotIndex = emptySlots[1]
		requestMoveItem(BAG_BACKPACK, item.slotIndex, BAG_BANK, emptySlotIndex, quantity)
		table.remove(emptySlots,1)
		return quantity
	end
	return 0
end

-- Retourne la pile ayant encore de la place
local function getItemStackFromSecurList(itemId, list)
	local items = list[itemId]
	if items then
		for _, item in ipairs(items) do
			if item.stack < item.maxStack then
				return item
			end
		end
	end
	return nil
end

-- Transfert d'un ensemble d'objet de la banque dans le sac à dos
function addon:MoveItemsFromBank(bitems, baglist, emptyBagSlots)
	local process = 0
	local bitem = bitems[1]
	local bagitem = getItemStackFromSecurList(bitem.itemId, baglist)
	for _, it in pairs(bitems) do
		it.bank_transfer_ok = 0
	end
	if bagitem then
		-- transfert complet sinon creation d'une nouvelle pile
		if (bagitem.stack + bitem.stack) <= bagitem.maxStack then
			requestMoveItem(BAG_BANK, bitem.slotIndex, BAG_BACKPACK, bagitem.slotIndex, bitem.stack)
			bitem.bank_transfer_ok = 1
			process = process + bitem.stack
		end
	end
	for _, bitem in pairs(bitems) do
		df("bankTransfer %s: %d %d", bitem.itemLink, bitem.stack, bitem.bank_transfer_ok)
		if bitem.bank_transfer_ok == 0 then
			d(" >> create new stack")
			local emptySlotIndex = emptyBagSlots[1]
			requestMoveItem(BAG_BANK, bitem.slotIndex, BAG_BACKPACK, emptySlotIndex, bitem.stack)
			table.remove(emptyBagSlots,1)
			bitem.bank_transfer_ok = 1
			process = process + bitem.stack
		end
	end
	return process
end

-- Transfert d'objets de la banque dans le sac à dos
function addon:MoveFromBank()
	-- Move from bank !!
	local chat_list = nil
	if self.settings_c.autoTransferToBank.showChatMessage then
		chat_list = CreateChatList(GetString(SI_EASYLOOTASSISTANT_TRANSFER_MSG_FROM))
	end
	local process = 0
	emptyBagSlots = {}
	for i = FindFirstEmptySlotInBag(BAG_BACKPACK) or 250, GetBagSize(BAG_BACKPACK) - 1 do
		if GetItemName(BAG_BACKPACK, i) == "" then
			emptyBagSlots[#emptyBagSlots + 1] = i
		end
	end
	local baglist = self:GenerateSecurListOfStackedItems(BAG_BACKPACK, nil, true)
	local bank_list = self:GenerateSecurListOfStackedItems(BAG_BANK, nil, true)	
	for _, bitems in pairs(bank_list) do
		if bitems[1].bankTransfer == FORCE_BANK_TRANSFER_FROM_BANK then
			local quantity = self:MoveItemsFromBank(bitems, baglist, emptyBagSlots)
			process = process + quantity
			if quantity > 0 and chat_list then
				chat_list:AddItemLink(bitems[1].itemLink, quantity)
			end

		end
	end
	if chat_list and chat_list.itemList then
		chat_list:Print()
	else
		self:Printf(GetString(SI_EASYLOOTASSISTANT_TRANSFER_AUTO_FROM))
	end
	if process > 0 then
		StackBag(BAG_BACKPACK)
	end
end

-- Process de transfert automatique dans la banque
-- Si une pile de l'objet est dispo alors on place dedant sinon on fait rien !
function addon:Process_AutoTransferToBank()
	if not IsBankOpen() then return end

	StackBag(BAG_BANK)

	-- Move from bank !!
	self:MoveFromBank()

	-- Move to bank
	emptyBankSlots = {}
	for i = FindFirstEmptySlotInBag(BAG_BANK) or 250, GetBagSize(BAG_BANK) - 1 do
		if GetItemName(BAG_BANK, i) == "" then
			emptyBankSlots[#emptyBankSlots + 1] = i
		end
	end
	local bank_list = self:GenerateSecurListOfStackedItems(BAG_BANK, nil, true)
	local list = self:GenerateSecurListOfStackedItems(BAG_BACKPACK)
	local chat_list = nil
	if self.settings_c.autoTransferToBank.showChatMessage then
		chat_list = CreateChatList(GetString(SI_EASYLOOTASSISTANT_TRANSFER_MSG))
	end
	-- Si un objet est marqué 'KEPT' et est présent dans la banque !
	for _, items in pairs(list) do
		local it1 = items[1]
		if self.debug_level > 0 then
			if it1.craftingLevel == 160 then
				--df("ATTB %s T=%d CL=%d", it1.itemLink, it1.transferCP160, it1.craftingLevel)
			end
		end
		for _, item in ipairs(items) do
			if (item.bankTransfer == BANK_TRANSFER_TO_BANK_IF_POSSIBLE) or (item.bankTransfer == BANK_TRANSFER_TO_BANK_FORCE) then
				local emptySlots = nil
				if item.bankTransfer == BANK_TRANSFER_TO_BANK_FORCE then
					emptySlots = emptyBankSlots
				end
				local quantity = self:MoveItemToBank(bank_list, item, emptySlots)
				if quantity > 0 and chat_list then
					chat_list:AddItemLink(item.itemLink, quantity)
				end
			end
		end
	end
	if chat_list and chat_list.itemList then
		chat_list:Print()
	else
		self:Printf(GetString(SI_EASYLOOTASSISTANT_TRANSFER_AUTO))
	end
end

function addon:OnOpenBank(_, bankBag)
	if bankBag ~= BAG_BANK then return end
	self.Buttons.BankAction.enabled = true
	self.Buttons.InventorySearch.alignment = KEYBIND_STRIP_ALIGN_LEFT
	self.Buttons.InventorySearch.enabled = self.settings_c.search_unknown.enabled_search
	KEYBIND_STRIP:UpdateKeybindButton(self.Buttons.BankAction)
	if KEYBIND_STRIP:HasKeybindButton(self.Buttons.InventorySearch) == false then
		KEYBIND_STRIP:AddKeybindButton(self.Buttons.InventorySearch) -- necessaire sinon le bouton n'est pas redessiner et apparait encore
	end
	if self.settings_c.search_unknown.enabled_auto_search then
		self:ScanBagForUnknown(bankBag)
	end
	if self.settings_c.autoTransferToBank.enabled then
		if self.settings_a.autoTransferToBank.delayS then 
			zo_callLater(function() self:Process_AutoTransferToBank(bankBag) end, 1000*self.settings_a.autoTransferToBank.delayS)
		else
			self:Process_AutoTransferToBank(bankBag)
		end
	end
end

function addon:OnCloseBank()
	self.Buttons.BankAction.enabled = false
	self.Buttons.InventorySearch.enabled = false
	KEYBIND_STRIP:UpdateKeybindButton(self.Buttons.BankAction)
	if KEYBIND_STRIP:HasKeybindButton(self.Buttons.InventorySearch) == true then
		KEYBIND_STRIP:RemoveKeybindButton(self.Buttons.InventorySearch) -- necessaire sinon le bouton n'est pas redessiner et apparait encore
	end
end
----------------- End Bank -----------------------

----------------- Guild Bank -----------------------
function addon:OnGuildBankReady()
	local guildBankId = GetSelectedGuildBankId()
	if guildBankId ~= nil then
		local pgp_deposit = DoesPlayerHaveGuildPermission(guildBankId, GUILD_PERMISSION_BANK_DEPOSIT)
		if pgp_deposit then
			self.Buttons.InventorySearch.alignment = KEYBIND_STRIP_ALIGN_LEFT
			self.Buttons.InventorySearch.enabled = self.settings_c.search_unknown.enabled_search
			if KEYBIND_STRIP:HasKeybindButton(self.Buttons.InventorySearch) == false then
				KEYBIND_STRIP:AddKeybindButton(self.Buttons.InventorySearch) -- necessaire sinon le bouton n'est pas redessiner et apparait encore
			end
			if self.settings_c.search_unknown.enabled_auto_search then
				self:ScanBagForUnknown(BAG_GUILDBANK)
			end
		end
	end
end

function addon:OnOpenGuildBank(_, bankBag)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_BANK_ITEMS_READY, function() self:OnGuildBankReady() end)
end

function addon:OnCloseGuildBank()
	self.Buttons.InventorySearch.enabled = false
	if KEYBIND_STRIP:HasKeybindButton(self.Buttons.InventorySearch) == true then
		KEYBIND_STRIP:RemoveKeybindButton(self.Buttons.InventorySearch) -- necessaire sinon le bouton n'est pas redessiner et apparait encore
	end
	EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_GUILD_BANK_ITEMS_READY)
end

----------------------------------------------------------------------------------------------
local TRADING_HOUSE_FILTER_LIST = 
{
	--{TRADING_HOUSE_FILTER_TYPE_ITEM, ITEMTYPE_RECIPE},
	{TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM, 
		SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD, 
		SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK,
	},
	{TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM,
		SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING,
		SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING,
		SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING,
		SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING,
		SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING,
		SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING,
		SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING,
	},
	{TRADING_HOUSE_FILTER_TYPE_ITEM, 
		ITEMTYPE_RACIAL_STYLE_MOTIF,
	},
	{TRADING_HOUSE_FILTER_TYPE_SPECIALIZED_ITEM, 
		SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE,
	},
}

function addon:TradingHouseNextFilter()
	self:Printf("Start Trading House Search for filter %d/%d",self.scanTradingHouseFilter,#TRADING_HOUSE_FILTER_LIST)
	ClearAllTradingHouseSearchTerms()
	SetTradingHouseFilter(unpack(TRADING_HOUSE_FILTER_LIST[self.scanTradingHouseFilter]))
end

-- call from Binding_SearchUnknown()
function addon:StartScanTradingHouse()
	if self.scanTradingHouse == nil then
		self.scanTradingHouse = true
		self.scanTradingHouseFilter = 1
		self.scanTradingHouseList = {}
		self:TradingHouseNextFilter()
		ExecuteTradingHouseSearch()
	else
		self.scanTradingHouse = nil
		self:Printf(GetString(SI_EASYLOOTASSISTANT_SEARCH_UNKNOWN_CANCELED))
	end
	if KEYBIND_STRIP:HasKeybindButton(self.Buttons.InventorySearch) == true then
		KEYBIND_STRIP:UpdateKeybindButton(self.Buttons.InventorySearch) -- necessaire sinon le bouton n'est pas redessiner et apparait encore
	end	
end

local function GetScanDelay()
	return math.max(GetTradingHouseCooldownRemaining() + 1000, 5000)
end

function addon:GuildListingScanLoop(scanPage)
	ExecuteTradingHouseSearch(scanPage)
end

function addon:OnTradingHouseError(errorCode)
	if self.scanTradingHouse then
		self:Printf(Red_1:Colorize(string.format("OnTradingHouseError %d",errorCode)))
	end
end

-- EVENT_TRADING_HOUSE_RESPONSE_RECEIVED (*[TradingHouseResult|#TradingHouseResult]* _responseType_, *[TradingHouseResult|#TradingHouseResult]* _result_)
function addon:OnTradingHouseResponseReceived(responseType, result)
	if self.scanTradingHouse then
		if self.debug_level > 1 then
			self:Printf("OnTradingHouseResponseReceived %d", result)
		end
		if result == TRADING_HOUSE_RESULT_SEARCH_PENDING then
			local numItemsOnPage, currentPage, hasMorePages = GetTradingHouseSearchResultsInfo()
			if self.debug_level > 1 then
				self:Printf("  > %d %d %s",numItemsOnPage,currentPage,tostring(hasMorePages))
			end
			for i = 1, numItemsOnPage do
				local itemLink = GetTradingHouseSearchResultItemLink(i)
				if (itemLink == nil or itemLink == "") then
					break
				end
				local _, _, _, _, _, _, totalPrice = GetTradingHouseSearchResultItemInfo(i)
				local item = {itemLink=itemLink}
				item.itemType, item.specializedItemType = GetItemLinkItemType(itemLink)
				item.filterType = GetItemLinkFilterTypeInfo(itemLink)
				item.totalPrice = totalPrice
				item.Unknown = self:CheckIfUnknown(item)
				if item.Unknown then
					if self.scanTradingHouseList[itemLink] == nil then
						self.scanTradingHouseList[itemLink] = totalPrice
					else
						local price = self.scanTradingHouseList[itemLink]
						local min_price = math.min(totalPrice, price)
						if min_price < price then
							self.scanTradingHouseList[itemLink] = min_price
						end
					end
				end
			end
			if hasMorePages then
				local delay = GetScanDelay()
				self:Printf("Trading House Search Filter %d/%d, Page %d (delay %ds)", 
					self.scanTradingHouseFilter,#TRADING_HOUSE_FILTER_LIST,currentPage+1, delay/1000)
				zo_callLater(function() self:GuildListingScanLoop(currentPage+1) end, delay)
			else
				-- search completed for this filter => print list
				local list = {}
				for link, price in pairs(self.scanTradingHouseList) do
					table.insert(list, {link=link, price=price})
				end				
				table.sort(list, function(a,b) 
					return a.price < b.price
				end)
				for i=1, #list do
					self:Printf("%s: price %d", list[i].link, list[i].price)
				end
				self.scanTradingHouseList = {}
				if self.scanTradingHouseFilter < #TRADING_HOUSE_FILTER_LIST then
					self.scanTradingHouseFilter = self.scanTradingHouseFilter + 1
					self:TradingHouseNextFilter()
					local delay = GetScanDelay()
					zo_callLater(function() self:GuildListingScanLoop(0) end, delay)
				else
					self.scanTradingHouse = nil
					self:Printf("Ending Trading House Search")
				end
			end
		end
	end
end

local function findGuildByName(guildNameToFind)
	local nbtg = GetNumTradingHouseGuilds()
	for i = 1, nbtg do
		local guildID, guildName = GetTradingHouseGuildDetails(i)
		--df("%d: %s",guildID,guildName)
		if guildName == guildNameToFind then
			return guildID, guildName
		end
	end
	return nil, nil
end

function addon:OnTradingHouseOpened()
	local curGuildID, curGuildName = GetCurrentTradingHouseGuildDetails()
	local defaultTradingHouse = self.settings_a.defaultTradingHouse.guildName
	if self.debug_level > 1 then
		df("current = %d, %s, default %s",curGuildID,curGuildName, defaultTradingHouse)
	end
	if curGuildName ~= defaultTradingHouse then
		selGuildID, selGuildName = findGuildByName(defaultTradingHouse)
		if curGuildID ~= nil then
			if self.debug_level > 1 then
				df("change trading house guild to : %s", selGuildName)
			end
			SelectTradingHouseGuildId(selGuildID)
		end
	end
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, function(...) self:OnTradingHouseResponseReceived(...) end)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_TRADING_HOUSE_ERROR, function(...) self:OnTradingHouseError(...) end)
	self.Buttons.InventorySearch.IsTradingHouse = true
	self.Buttons.InventorySearch.alignment = KEYBIND_STRIP_ALIGN_RIGHT
	self.Buttons.InventorySearch.enabled = self.settings_c.search_unknown.enabled_search
	if KEYBIND_STRIP:HasKeybindButton(self.Buttons.InventorySearch) == false then
		KEYBIND_STRIP:AddKeybindButton(self.Buttons.InventorySearch) -- necessaire sinon le bouton n'est pas redessiner et apparait encore
	end
end

function addon:OnTradingHouseClosed()
	if self.debug_level > 1 then
		self:Printf("OnTradingHouseClosed")
	end
	self.scanTradingHouse = nil
	self.Buttons.InventorySearch.enabled = false
	self.Buttons.InventorySearch.IsTradingHouse = nil
	if KEYBIND_STRIP:HasKeybindButton(self.Buttons.InventorySearch) == true then
		KEYBIND_STRIP:RemoveKeybindButton(self.Buttons.InventorySearch) -- necessaire sinon le bouton n'est pas redessiner et apparait encore
	end
	EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED)
	EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_TRADING_HOUSE_ERROR)
end
----------------- End Guild Bank -----------------------

----------------- Settings -----------------------
function addon:SetupSettings()
	local LAM2 = LibAddonMenu2
	if not LAM2 then return end

	local panelData = {
		type = "panel",
		name = addon.title,
		displayName = Green:Colorize(addon.title),
		author = Blue_1:Colorize("gdfou"),
		version = EasyLootAssistant_Version,
		slashCommand = self:BuildSlashCmd("config"),
		registerForRefresh = true,
		registerForDefaults = true,
		--website = "",
	}
	LAM2:RegisterAddonPanel(addon.name, panelData)

	local optionsTable = {}
	local language = GetCVar("Language.2")
	if language == "fr" then
		local optionsTable_FR = {
			{
				type = "description",
				text = [[Vous pouvez configurer les raccourcis clavier suivant:
	- |c009999Transfert automatique vers la banque|r.
	- |c009999Ouverture du menu de configration|r.
	- |c009999Recherche des inconnus|r.
	- |c009999Option Empêcher d'attaquer des innocents|r.
	- |c009999Option Butin volé auto|r.
Commandes disponibles:
	- |c009999easylootassistant_config|r : ouverture du panneau de config.
	- |c009999easylootassistant_junk|r : exécute le traitement de mise au rebut.
	- |c009999easylootassistant_unjunk|r : sort tout les objets du rebut.
	- |c009999easylootassistant_search|r : exécute la recherche d'objets inconnus.
	- |c009999easylootassistant_list|r : donne le résultat du traitement de mise au rebut.
	- |c009999easylootassistant_list_delete|r : liste des objets à détruire.
	- |c009999easylootassistant_delete|r : détruit les objets pouvants être détruit.
Code de couleur des menus de configuration:
	- |c999900Les paramètres en jaune sont pour le compte.|r
	- |c00CC00Les paramètres en vert sont pour le personnage courant.|r
]],
			}
		}
		optionsTable = optionsTable_FR
	else
		local optionsTable_EN = {
			{
				type = "description",
				text = [[You can configure the following keyboard shortcuts:
	- |c009999Automatic transfer to the bank|r.
	- |c009999Opening the configuration menu|r.
	- |c009999Search unknown|r.
	- |c009999Option Prevent attacking innocent people|r.
	- |c009999Option Auto Stolen Loot|r.
Commands available:
	- |c009999easylootassistant_config|r : opening the config panel.
	- |c009999easylootassistant_junk|r : performs junk processing.
	- |c009999easylootassistant_unjunk|r : take out all junked items.
	- |c009999easylootassistant_search|r : performs search unknown processing.
	- |c009999easylootassistant_list|r : gives the result of the junk process.
	- |c009999easylootassistant_list_delete|r : list of objects to destroy.
	- |c009999easylootassistant_delete|r : destroys objects that can be destroyed.
Configuration menu color code:
	- |c999900The parameters in yellow are for the account.|r
	- |c00CC00The parameters in green are for the current character.|r
]],
			}
		}
		optionsTable = optionsTable_EN
	end
	table.insert(optionsTable, self:Build_Config_General())
	self:Build_Config_FromJunkRules(optionsTable)
	LAM2:RegisterOptionControls(addon.name, optionsTable)
end
--------------- End Settings ---------------------

function addon:SlashCommand()
	-- parametre possible 
	SLASH_COMMANDS[self:BuildSlashCmd("junk")] = function()
		self:ScanBagForJunk(BAG_BACKPACK)
	end
	SLASH_COMMANDS[self:BuildSlashCmd("unjunk")] = function()
		self:UnJunkAll(BAG_BACKPACK)
	end
	SLASH_COMMANDS[self:BuildSlashCmd("list")] = function(bagidstr)
		local bagid = BAG_BACKPACK
		if bagidstr ~= "" then
			bagid = tonumber(bagidstr)
		end
		self:ScanBagForJunk(bagid, true)
	end
	SLASH_COMMANDS[self:BuildSlashCmd("list_delete")] = function()
		self:ScanBagForDelete(BAG_BACKPACK)
	end
	SLASH_COMMANDS[self:BuildSlashCmd("delete")] = function()
		self:ScanBagForDelete(BAG_BACKPACK, true)
	end
	SLASH_COMMANDS[self:BuildSlashCmd("unknown_lock_list")] = function()
		self:PrintUnknownLockList()
	end
	if self.debug_level > 0 then
		--[[
		SLASH_COMMANDS[self:BuildSlashCmd("test")] = function(str)
			local styles = {}
			for i = 1, GetNumValidItemStyles() do
				local styleItemId = GetValidItemStyleId(i)
				local styleName = GetItemStyleName(styleItemId)
				local styleItem = GetSmithingStyleItemInfo(styleItemId)
				self.settings_a.StyleList[styleItemId] = {name=styleName, item=styleItem}
			end			
		end
		--]]
		---[[
		--]]
	end
end

function addon:RegisterEvents()
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_LOOT_RECEIVED, function(...) self:OnLootReceived(...) end)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_OPEN_STORE, function() self:OnOpenStore() end)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CLOSE_STORE, function() self:OnCloseStore() end)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_OPEN_BANK, function(...) self:OnOpenBank(...) end)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CLOSE_BANK, function() self:OnCloseBank() end)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_INVENTORY_FULL_UPDATE, function() self:OnInventoryUpdated() end)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function() self:OnInventoryUpdated() end)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_OPEN_GUILD_BANK, function() self:OnOpenGuildBank() end)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CLOSE_GUILD_BANK, function() self:OnCloseGuildBank() end)

	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_OPEN_TRADING_HOUSE, function() self:OnTradingHouseOpened() end)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CLOSE_TRADING_HOUSE, function() self:OnTradingHouseClosed() end)

	if self.debug_level > 1 then
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_OPEN_HOUSE_STORE, function() d("EVENT_OPEN_HOUSE_STORE") end)
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_OPEN_FENCE, function(allowSell, allowLaunder) df("EVENT_OPEN_FENCE(allowSell=%s,allowLaunder=%s)",tostring(allowSell),tostring(allowLaunder)) end)

		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_RECIPE_LEARNED, function() df("EVENT_RECIPE_LEARNED") end)
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_MULTIPLE_RECIPES_LEARNED, function() df("EVENT_MULTIPLE_RECIPES_LEARNED") end)
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_STYLE_LEARNED, function() df("EVENT_STYLE_LEARNED") end)
	end
end

function CreateBindingName(name, action)
	ZO_CreateStringId("SI_BINDING_NAME_" .. name, action)
end

function addon:OnAddonLoaded(event, name)
	if name ~= self.name then return end
	EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)

	-- Ajoute le raccourci clavier 'Action' dans le menu de TESO avec le texte 'SI_BINDING_NAME_' et le nom de l'action dans le fichier de bind 'RUN_EASYLOOTASSISTANT_ACTION'
	CreateBindingName("RUN_EASYLOOTASSISTANT_ACTION", GetString(SI_EASYLOOTASSISTANT_TRANSFER))
	CreateBindingName("RUN_EASYLOOTASSISTANT_CONFIG", "Configuration")
	CreateBindingName("RUN_EASYLOOTASSISTANT_SEARCH", GetString(SI_EASYLOOTASSISTANT_SEARCH_UNKNOWN))
	CreateBindingName("RUN_EASYLOOTASSISTANT_INNOCENTS", GetString(SI_INTERFACE_OPTIONS_COMBAT_PREVENT_ATTACKING_INNOCENTS))
	CreateBindingName("RUN_EASYLOOTASSISTANT_LOOTSTOLEN", GetString(SI_INTERFACE_OPTIONS_LOOT_USE_AUTOLOOT_STOLEN))

	self:BuildRulesSettings()

	self.settings_a = ZO_SavedVars:NewAccountWide(self.name .. "_Data", 1, nil, self.defaults_a)
	self.settings_c = ZO_SavedVars:NewCharacterNameSettings(self.name .. "_Data", 1, nil, self.defaults_c)
	self:SetDebugLevel()

	self:SlashCommand()
	self:RegisterEvents()
	self:SetupSettings()
	self:InitializeKeybind()
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, function(...) addon:OnAddonLoaded(...) end)

EASYLOOTASSISTANT = addon
