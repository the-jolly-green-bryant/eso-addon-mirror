-- Script uses the structure of ResearchAssistantRemix by ingeniousclown
-- CE_Controller is the top-level control declared in CheckEnchantment.xml

if CheckEnchantment then return end -- no double init please

local WM = WINDOW_MANAGER
local BACKPACK = ZO_PlayerInventoryBackpack
local BANK = ZO_PlayerBankBackpack
local GUILD_BANK = ZO_GuildBankBackpack

local INVENTORY = ZO_EnchantingTopLevelInventory 
-- ZO_EnchantingTopLevelInventoryBackpack
-- only difference for now is color
local IS_ENCHANTABLE_ITEM_TEXTURE = [[/esoui/art/icons/servicemappins/servicepin_enchanting.dds]] -- An enchant can be put on, but is just not available
local HAS_AVAILABLE_ENCHANTMENT = [[/esoui/art/icons/servicemappins/servicepin_enchanting.dds]] -- An enchantment can be put on, but is just not available
local HAS_AVAILABLE_ENCHANTMENT_BANK = [[/esoui/art/icons/servicemappins/servicepin_enchanting.dds]] -- An enchantment from the bank can be used 
local HAS_AVAILABLE_ENCHANTMENT_GUILD_BANK = [[/esoui/art/icons/servicemappins/servicepin_enchanting.dds]] -- An enchantment from the guild bank can be used 
local IS_SUITABLE_ENCHANTMENT_TEXTURE = [[/esoui/art/icons/servicemappins/servicepin_enchanting.dds]] -- This enchantment can be used

local TRAIT_HAS_AVAILABLE_ENCHANTMENT = 1
local TRAIT_IS_ENCHANTABLE = 2
local TRAIT_HAS_AVAILABLE_ENCHANTMENT_BANK = 3
local TRAIT_HAS_AVAILABLE_ENCHANTMENT_GUILD_BANK = 4

local controlsToWatch = {}
local ownedTraits = {}

local isScanning = false
local scanMore = 0

local counter = 1
local settings = {}
local childname = "CheckEnchant"
settings.name = "CheckEnchantment"
settings.version = "1.0.20"
settings.command = "/ce"
settings.svName = "CheckEnchantment_SavedVariables" --[[ has to match with the entry in the txt file ]]--
settings.xoffset = 80 -- used 80 to not clash with the 100 of Research Assistant
settings.xoffset_eq = 20
settings.yoffset = 0
settings.yoffset_eq = -16
settings.xdim = 16 
settings.ydim = 16 
settings.xdim_grid = 20
settings.ydim_grid = 20
settings.alpha = 1
settings.add_draw_level = 20
settings.show_glyphs = true
settings.x_threshold = 60 -- adapt this to a slightly higher values, if InventoryGridView has the check-marks in the middle

local enchantments
local bank_enchantments
local guild_bank_enchantments
local suitable_enchantments
local use_string = false -- use a string output

local debug_level = 0

local function debug(level, text)
  if (debug_level >= level) then d(text) end
end

-- CheckEnchantment can't be local, if it is to be used with key-binding
CheckEnchantment = {}

-- store our information on equipment slots
-- The key to the table is the key to the slot id in the global _G variables e.g. _G["EQUIP_SLOT_HEAD"]
-- The value is a table. eng is for English - in case I want to add other translations to the script
-- Control is the graphical control ID
local slots = {
	["EQUIP_SLOT_HEAD"] = { eng = "head" , control = "ZO_CharacterEquipmentSlotsHead"},
	["EQUIP_SLOT_CHEST"] = { eng = "chest", control = "ZO_CharacterEquipmentSlotsChest" },
	["EQUIP_SLOT_HEAD"] = { eng = "head" , control = "ZO_CharacterEquipmentSlotsHead"},
	["EQUIP_SLOT_CHEST"] = { eng = "chest", control = "ZO_CharacterEquipmentSlotsChest" },
	["EQUIP_SLOT_SHOULDERS"] = { eng = "shoulders", control = "ZO_CharacterEquipmentSlotsShoulder" },
	["EQUIP_SLOT_FEET"] = { eng = "feet", control = "ZO_CharacterEquipmentSlotsFoot" },
	["EQUIP_SLOT_HAND"] = { eng = "hand", control = "ZO_CharacterEquipmentSlotsGlove" },
	["EQUIP_SLOT_LEGS"] = { eng = "legs", control = "ZO_CharacterEquipmentSlotsLeg" },
	["EQUIP_SLOT_WAIST"] = { eng = "waist", control = "ZO_CharacterEquipmentSlotsBelt" },
	["EQUIP_SLOT_RING1"] = { eng = "left ring", control = "ZO_CharacterEquipmentSlotsRing1" },
	["EQUIP_SLOT_RING2"] = { eng = "right ring", control = "ZO_CharacterEquipmentSlotsRing2" },
	["EQUIP_SLOT_NECK"] = { eng = "neck", control = "ZO_CharacterEquipmentSlotsNeck" },
	["EQUIP_SLOT_COSTUME"] = { eng = "costume", control = "ZO_CharacterEquipmentSlotsCostume" },
	["EQUIP_SLOT_MAIN_HAND"] = { eng = "main-hand", control = "ZO_CharacterEquipmentSlotsMainHand" },
	["EQUIP_SLOT_OFF_HAND"] = { eng = "off-hand", control = "ZO_CharacterEquipmentSlotsOffHand" },
	["EQUIP_SLOT_BACKUP_MAIN"] = { eng = "backup main-hand", control = "ZO_CharacterEquipmentSlotsBackupMain" },
	["EQUIP_SLOT_BACKUP_OFF"] = { eng = "backup off-hand", control = "ZO_CharacterEquipmentSlotsBackupOff" }
}

local function cleanName(name)
	return string.gsub(name, "%^.", "") -- remove trailing ^ pattern
end

-- register a single enchantment item
local function EnchantmentRegistration(bag, s, enchantment_list)
  debug(1, "EnchantmentRegistration check " .. bag .. "," .. s .. GetItemLink(bag, LINK_STYLE_BRACKET) .. " is an enchantment.")
	if (IsItemEnchantment(bag, s)) then
	  debug(1, "Item " .. bag .. "," .. s .. GetItemLink(bag, LINK_STYLE_BRACKET) .. " is an enchantment.")
		if (bag == BAG_GUILDBANK) then debug(3, "register enchantment item " .. bag .. "," .. s .. " " .. GetItemName(bag, s)) end
		-- create look-up table for glyphs that are getting used
		local instance = GetItemInstanceId(bag, s)
		if (instance ~= nil) then
			if (settings.show_glyphs) then
				if (suitable_enchantments == nil) then suitable_enchantments = {} end
				if (suitable_enchantments[instance] == nil) then suitable_enchantments[instance] = {} end
			end
			local name = cleanName(GetItemLink(bag, s, LINK_STYLE_BRACKET))
			
			if name ~= nil then
			    if (enchantment_list == nil) then enchantment_list = {} end
				enchantment_list[instance] = { name, bag, s }
			else
				debug(1, "Couldn't register enchantment, because of missing name:" .. bag .. "," .. s)
			end
		else
			debug(1, "Couldn't register enchantment (missing instance):" .. bag .. "," .. s)
		end
	end
end

-- collect all available enchantments
local function UpdateEnchantmentsPerBag(bag, enchantment_list)
  debug(1, "Update enchantments for bag " .. bag)
	local slots = GetBagSize(bag)
	if (slots ~= nil) then
		for s = 0, slots do
      EnchantmentRegistration(bag, s, enchantment_list)
		end
	end
end

-- create a list of enchantments
local function UpdateEnchantments()

	enchantments = {}
	UpdateEnchantmentsPerBag(BAG_BACKPACK, enchantments)
	if (not use_string) then -- don't be spammy in string output case
	  bank_enchantments = {}
	  UpdateEnchantmentsPerBag(BAG_BANK, bank_enchantments)
	  -- Guild Bank is separately managed
	end
end

local function min(x,y)
	return x < y and x or y
end

-- fix the positions to the parent window
local function SetPosition(parent, control)
	local xdim = min(settings.xdim, parent:GetWidth())
	local ydim = min(settings.ydim, parent:GetHeight())

	control:SetDimensions(xdim, ydim)

	local x = min(settings.xoffset, parent:GetWidth())
	local y = min(settings.yoffset, parent:GetWidth())

	local anchor = CENTER
	-- we have a small icon here
	if (x < settings.x_threshold) then -- adapt here, if it doesn't work with InventoryGridView
		anchor = TOPRIGHT
		x = 0
	end

  control:ClearAnchors() -- prevent issue with too many anchors?
	if (parent.dataEntry and parent.dataEntry.data) then
		local bagId = parent.dataEntry.data.bagId
		local slotIndex = parent.dataEntry.data.slotIndex

		if (bagId == BAG_BACKPACK) then
			debug(2, "SetPosition for " .. GetItemName(bagId, slotIndex) .. " to " .. x .. "," .. y .. " " .. anchor)
		end
	end
	
	control:SetAnchor(anchor, parent, anchor, x, y)
end

-- Graphics part - add a handle
local function CreateIndicatorControl(parent, xoffset, yoffset)
	local control = WM:CreateControl(parent:GetName() .. childname, parent, CT_TEXTURE)
	control:SetDrawLayer(parent:GetDrawLayer()+1)
	SetPosition(parent, control)
	control:SetAlpha(settings.alpha)
	control:SetHidden(true)

	return control
end

local function CheckSingleItem(bag, slot, ebag, eslot)
    
    if (ebag == BAG_GUILDBANK and bag == BAG_BACKPACK) then debug(3, "Check item "..GetItemName(bag, slot) .. " with " .. GetItemName(ebag, eslot)) end
	
	if CanItemTakeEnchantment(bag, slot, ebag, eslot) then
		if (settings.show_glyphs) then
			if (suitable_enchantments == nil) then suitable_enchantments = {} end
			local instance = GetItemInstanceId(ebag, eslot)
			if (suitable_enchantments[instance] == nil) then suitable_enchantments[instance] = {} end
			if (ebag == BAG_GUILDBANK) then debug(2, "Mark item " .. GetItemName(ebag, eslot) .. " as used.") end
			suitable_enchantments[instance][bag] = 1 -- this enchantment can be used
			debug(3, "Return true for " .. GetItemName(bag, slot) .. " using " .. GetItemName(ebag, eslot))
		end
		return true
	end
	
	return false
end

local function findEnchantingItem(enchantment_bag, bag, slot)
  	local r = nil

    local enchantment_list = nil
    if (enchantment_bag == BAG_BACKPACK) then enchantment_list = enchantments end
    if (enchantment_bag == BAG_BANK) then enchantment_list = bank_enchantments end
    if (enchantment_bag == BAG_GUILDBANK) then enchantment_list = guild_bank_enchantments end
    if (enchantment_list == nil) then return end
    
	for k,v in pairs(enchantment_list) do
		local ebag = v[2]
		local eslot = v[3]
		local tmp = CheckSingleItem(bag, slot, ebag, eslot)
		if (tmp) then
			if (use_string) then
				if (r ~= nil) then
					r = r .. ", "
				end

				local name = cleanName(v[1])
				if (name == "") then name = " " end -- minimum entry
				r = (r and r or "") .. name
			else
				r = true
			end
		end
	end

    debug(2, "Return " .. (r and  "true" or "false") .. " for " .. GetItemName(bag, slot) .. " enchantment in bag " .. enchantment_bag)
	
	return r
end

-- check implicitly, whether items in equipment can be enchanted with glyphs in the guild-bank
local function UpdateEnchantmentForEq(ebag, eslot)
	for k,v in pairs(slots) do
		local slot = _G[k]
		CheckSingleItem(BAG_WORN, slot, ebag, eslot)
	end
end

-- check implicitly, whether items in given bag can be enchanted with glyphs in the guild-bank
local function UpdateEnchantmentForBag(bag, ebag, eslot)
    local slots = GetBagSize(bag)
	if (slots ~= nil) then
		for s = 0, slots do
		  CheckSingleItem(bag, s, ebag, eslot)
		end
	end
end

-- set the icons
local function AddEnchantmentIndicatorToSlot(control, bag, slot)
	local indicatorControl = control:GetNamedChild(childname)
	-- assure that we have a control for each slot
	local is_new = false
	if (not indicatorControl) then
		indicatorControl = CreateIndicatorControl(control, bag ~= 0 and settings.xoffset or settings.xoffset_eq, bag ~= 0 and settings.yoffset or settings.yoffset_eq)
		table.insert(controlsToWatch, indicatorControl) -- necessary?
		is_new = true
	end

	SetPosition(control, indicatorControl) -- TODO: might be superfluous 

	local traitKey = CheckIsItemEnchantable(bag, slot)
	
	if (bag == BAG_WORN) then debug(2, "Item " .. GetItemName(bag, slot) .. " got trait " .. (traitKey and traitKey or "nil")) end
	
	if (traitKey) then
	    if (bag == BAG_WORN) then debug(2, "Item " .. GetItemName(bag, slot) .. " gets shown") end
		if (traitKey == TRAIT_HAS_AVAILABLE_ENCHANTMENT) then
			indicatorControl:SetTexture(HAS_AVAILABLE_ENCHANTMENT)
			indicatorControl:SetColor(0, 1, 0, 1)
		elseif (traitKey == TRAIT_HAS_AVAILABLE_ENCHANTMENT_BANK) then
			indicatorControl:SetTexture(HAS_AVAILABLE_ENCHANTMENT_BANK)
			indicatorControl:SetColor(1, 0.8, 0, 1)
		elseif (traitKey == TRAIT_HAS_AVAILABLE_ENCHANTMENT_GUILD_BANK) then
			indicatorControl:SetTexture(HAS_AVAILABLE_ENCHANTMENT_GUILD_BANK)
			indicatorControl:SetColor(0, 0, 1, 1)
		else
			indicatorControl:SetTexture(IS_ENCHANTABLE_ITEM_TEXTURE)
			indicatorControl:SetColor(1, 0.5, 0.2, 1)
		end
		indicatorControl:SetHidden(false)
	else
	    if (bag == BAG_WORN) then debug(2, "Item " .. GetItemName(bag, slot) .. " gets hidden") end
		indicatorControl:SetHidden(true)
	end
	
	local instance = GetItemInstanceId(bag, slot)
	-- we only see a small window of the guild bank- special treatment therefore
	if (settings.show_glyphs) then
		if (bag == BAG_GUILDBANK and IsItemEnchantment(bag, slot)) then
			if (suitable_enchantments == nil or suitable_enchantments[instance] == nil) then
				EnchantmentRegistration(bag, slot, guild_bank_enchantments)

				UpdateEnchantmentForEq(bag, slot)
				UpdateEnchantmentForBag(BAG_BACKPACK, bag, slot)
			end
		end

		if (IsItemEnchantment(bag, slot) and suitable_enchantments and suitable_enchantments[instance] ~= nil) then
			if (suitable_enchantments[instance][BAG_WORN] ~= nil or suitable_enchantments[instance][BAG_BACKPACK] ~= nil) then
				debug(3, "Show inventory " .. bag .. "," .. slot)
				indicatorControl:SetTexture(IS_SUITABLE_ENCHANTMENT_TEXTURE)
				indicatorControl:SetColor(0, 1, 0, 1)
				indicatorControl:SetHidden(false)
			elseif (suitable_enchantments[instance][BAG_BANK] ~= nil and bag == BAG_BANK) then
				debug(3, "Show bank " .. bag .. "," .. slot)
				indicatorControl:SetTexture(IS_SUITABLE_ENCHANTMENT_TEXTURE)
				indicatorControl:SetColor(1, 0.8, 0, 1)
				indicatorControl:SetHidden(false)
			elseif (suitable_enchantments[instance][BAG_GUILDBANK] ~= nil and bag == BAG_GUILDBANK) then
				debug(3, "Show guild bank " .. bag .. "," .. slot)
				indicatorControl:SetTexture(IS_SUITABLE_ENCHANTMENT_TEXTURE)
				indicatorControl:SetColor(0, 0, 1, 1)
				indicatorControl:SetHidden(false)
			else
				debug(3, "Hide " .. bag .. "," .. slot)
				indicatorControl:SetHidden(true)
			end
		end
	end
end

-- add indicator for single slot
local function AddEnchantmentIndicatorToControl(control)
	local bagId = control.dataEntry.data.bagId
	local slotIndex = control.dataEntry.data.slotIndex
	AddEnchantmentIndicatorToSlot(control, bagId, slotIndex)
end

-- add indicator to every slot in the control
local function AddEnchantmentIndicators(self)
	for _, v in pairs(self.activeControls) do
		AddEnchantmentIndicatorToControl(v)
	end
end

local function CheckNow(self)
	if (#self.activeControls > 0 and not self.isGrid and not self:IsHidden()) then
		AddEnchantmentIndicators(self)
	end
end

-- special stuff for EQ
local function CheckEQ()
	for k,v in pairs(slots) do
		local parent = _G[v.control]
		local slot = _G[k]
		if (parent ~= nil) then 
			--if (parent.activeControls and #parent.activeControls > 0 and not parent.IsHidden()) then
			AddEnchantmentIndicatorToSlot(parent, 0, slot)
			--end
		end
	end
end

function AreAllHidden()
	return BANK and BANK:IsHidden() and BACKPACK and BACKPACK:IsHidden() and GUILD_BANK and GUILD_BANK:IsHidden()
end

local bufferTime = 200 -- ms - TODO: make configurable
local elapsedTime = 0
local stopUpdateWait = 500 -- TODO: make configurable
local elapsedStopUpdateWait = 0
local shouldStopUpdate = false

function CE_OnUpdate()
	elapsedTime = elapsedTime + GetFrameDeltaTimeMilliseconds()
	if (isScanning or elapsedTime < bufferTime) then return end
	elapsedTime = 0

	--if ((AreAllHidden() and GetCraftingInteractionType() == 0) and not isStoreOrBankOpen) then
	if (AreAllHidden() and not isStoreOrBankOpen) then
		shouldStopUpdate = true
		elapsedStopUpdateWait = elapsedStopUpdateWait + GetFrameDeltaTimeMilliseconds()
		if(elapsedStopUpdateWait >= stopUpdateWait) then
			CE_Controller:SetHandler("OnUpdate", nil)
			elapsedStopUpdateWait = 0
		end
		return
	end

	if(shouldStopUpdate) then
		shouldStopUpdate = false
		elapsedStopUpdateWait = 0
	end

	UpdateEnchantments()
	CheckEQ()
	CheckNow(BACKPACK)
    CheckNow(BANK)
    CheckNow(GUILD_BANK)
end

local function CE_InvUpdate ( ... )
	if(not AreAllHidden()) then
		CE_Controller:SetHandler("OnUpdate", CE_OnUpdate)
	end
end

local function CE_ALPush( ... )
	CE_Controller:SetHandler("OnUpdate", CE_OnUpdate)
end

local function CE_StoreOrBankOpen( ... )
	CE_Controller:SetHandler("OnUpdate", CE_OnUpdate)
	isStoreOrBankOpen = true
end

local function CE_StoreOrBankClosed( ... )
	isStoreOrBankOpen = false
end

-- add hooks so that the add-on can work with Inventory Grid View
local function addHooks()
	for _, v in pairs(PLAYER_INVENTORY.inventories) do
		local listView = v.listView
		if (listView and listView.dataTypes and listView.dataTypes[1]) then
			local hookedFunctions = listView.dataTypes[1].setupCallback

			listView.dataTypes[1].setupCallback =
			function(rowControl, slot)
				hookedFunctions(rowControl, slot)
				AddEnchantmentIndicatorToControl(rowControl, 1)
			end
		end
	end
	ZO_ScrollList_RefreshVisible(BACKPACK)
	ZO_ScrollList_RefreshVisible(BANK)
	ZO_ScrollList_RefreshVisible(GUILD_BANK)	
end

function ClearEnchantmentReferences()
   suitable_enchantments = nil
   guild_bank_enchantments = nil
end

-- hook into guild trading houses
local function HookTrading(...)
	if CheckEnchantment.hookedDataFunction then return end
    CheckEnchantment.hookedDataFunction = ZO_TradingHouseItemPaneSearchResults.dataTypes[1].setupCallback
	ZO_TradingHouseItemPaneSearchResults.dataTypes[1].setupCallback = function(...)
		local row, data = ...
        CheckEnchantment.hookedDataFunction(...)
		AddEnchantmentIndicatorToControl(row, data)
	end
end

local function InitializeItems(eventCode, addOnName)
	if(addOnName ~= settings.name) then return end

	d("Initialize CheckEnchantment")
	EVENT_MANAGER:RegisterForEvent("CE_ALPUSH", EVENT_ACTION_LAYER_PUSHED, CE_ALPush)
	EVENT_MANAGER:RegisterForEvent("CE_INV_SLOT_UPDATE", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, CE_InvUpdate)
	EVENT_MANAGER:RegisterForEvent("CE_STORE_OPEN", EVENT_OPEN_STORE, CE_StoreOrBankOpen)
	EVENT_MANAGER:RegisterForEvent("CE_BANK_OPEN", EVENT_OPEN_BANK, CE_StoreOrBankOpen)
	EVENT_MANAGER:RegisterForEvent("CE_STORE_CLOSE", EVENT_CLOSE_STORE, CE_StoreOrBankClosed)
	EVENT_MANAGER:RegisterForEvent("CE_BANK_CLOSE", EVENT_CLOSE_BANK, CE_StoreOrBankClosed)
	EVENT_MANAGER:RegisterForEvent("CE_GUILD", EVENT_OPEN_GUILD_BANK, ClearEnchantmentReferences)
	EVENT_MANAGER:RegisterForEvent("CE_GUILD", EVENT_GUILD_BANK_SELECTED, ClearEnchantmentReferences)
	EVENT_MANAGER:RegisterForEvent("CE_GUILD", EVENT_CLOSE_GUILD_BANK, ClearEnchantmentReferences)
	--EVENT_MANAGER:RegisterForEvent("CE_TRADING_HOUSE", EVENT_OPEN_TRADING_HOUSE, ClearEnchantmentReferences)
	--EVENT_MANAGER:RegisterForEvent("CE_TRADING_HOUSE", EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, HookTrading)

	SLASH_COMMANDS[settings.command] = cmdCheckEnchantment
	savedVars = ZO_SavedVars:NewAccountWide(settings.svName, 1, nil, settings.svDefaults, nil)
	CheckEnchantment.printEnchantable = function (a) printEnchantable() end
	CheckEnchantment.printAllEnchantable = function (a) printEnchantable(1) end
	UpdateEnchantments()
	addHooks()
	-- Install support for key-bindings
	ZO_CreateStringId("SI_BINDING_NAME_SHOW_ENCHANTABLE", "Show available enchantments")
	ZO_CreateStringId("SI_BINDING_NAME_SHOW_ALL_ENCHANTABLE", "Show all enchantable items")
end

function cleanItemName(bag, slot)
	--local name = GetItemName(0, slot)
	return cleanName(GetItemLink(bag, slot, LINK_STYLE_BRACKET))
end

function CheckIsItemEnchantable(bag, slot, liste)
	if IsItemEnchantable (bag, slot) then
	    if (bag == BAG_WORN) then debug(3, "Item " .. GetItemName(bag, slot) .. " is enchantable.") end
		local liste_inventory =  findEnchantingItem(BAG_BACKPACK, bag, slot)
		local liste_bank =       findEnchantingItem(BAG_BANK, bag, slot)
		local liste_guild_bank = findEnchantingItem(BAG_GUILDBANK, bag, slot)
		
		if (use_string) then
			liste = liste_inventory -- only return backpack checks
			if (liste_inventory ~= "") then
				return TRAIT_HAS_AVAILABLE_ENCHANTMENT
			else
				if (liste_bank ~= "") then
					return TRAIT_HAS_AVAILABLE_ENCHANTMENT_BANK
				else
					if (liste_guild_bank ~= "") then
						return TRAIT_HAS_AVAILABLE_ENCHANTMENT_GUILD_BANK
					else
						return TRAIT_IS_ENCHANTABLE
					end
				end
			end
		else
		  --return liste_inventory and TRAIT_HAS_AVAILABLE_ENCHANTMENT or (liste_bank and TRAIT_HAS_AVAILABLE_ENCHANTMENT_BANK or (liste_guild_bank and TRAIT_HAS_AVAILABLE_ENCHANTMENT_GUILD_BANK or TRAIT_IS_ENCHANTABLE))
		  if (liste_inventory == true) then
		    debug(2, bag .. "," .. slot .. " " .. GetItemName(bag, slot) .. " has available enchantment.")
		    return TRAIT_HAS_AVAILABLE_ENCHANTMENT
		  elseif (liste_bank == true) then
		    debug(2, bag .. "," .. slot .. " " ..  GetItemName(bag, slot) .. " has available enchantment in bank.")
		    return TRAIT_HAS_AVAILABLE_ENCHANTMENT_BANK
		  elseif (liste_guild_bank == true) then
		    debug(2, bag .. "," .. slot .. " " ..  GetItemName(bag, slot) .. " has available enchantment in guild bank.")
		    return TRAIT_HAS_AVAILABLE_ENCHANTMENT_GUILD_BANK
		  else
		    debug(2, bag .. "," .. slot .. " " ..  GetItemName(bag, slot) .. " is enchantable.")
		    return TRAIT_IS_ENCHANTABLE
		  end
		end
		
		return nil
	end

	return nil
end

function printEnchantable(showall)
	local lang = "eng"
	local has_items = false

	for k,v in pairs(slots) do
		local slot = _G[k];
		local name = cleanItemName(0, slot)

		local liste
		use_string = true
		local result = CheckIsItemEnchantable(0, slot, liste)
		use_string = false
		if name ~= nil and (result == TRAIT_HAS_AVAILABLE_ENCHANTMENT or (result == TRAIT_IS_ENCHANTABLE and showall)) then
			d(v[lang] .. "(" .. name .. "): " .. (liste ~= "" and liste or "None"))
			has_items = true
		end
	end

	if not has_items then
		d("No enchantable items in worn equipment found.")
	end
end

-- Command display start
function cmdCheckEnchantment(text, test)
	d("Lua version ".. _VERSION)
	d(bit32.band(2,4))
	if (text ~= "") then
		if (text == "enchanting") then
			printEnchantable()
		else
			d("Provide an argument like 'long'")
		end
	else
		d("Running " .. settings.name .. " version " .. settings.version .. ".")
	end
end
-- Command display end

-- have something to trigger initialization
EVENT_MANAGER:RegisterForEvent( settings.name, EVENT_ADD_ON_LOADED , InitializeItems )
