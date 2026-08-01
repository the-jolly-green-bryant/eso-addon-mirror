--[[
Copyright (c) 2017-now Dolores Scott
All rights reserved.
See LICENSE file for terms.
]]
local SF = LibSFUtils
local color = SF.hex
local TT = ThiefTools

local L = GetString

local ZOS_addSystemMsg = CHAT_SYSTEM.AddMessage

-- -----------------------------
-- send debug messages to chat if enabled
local TTmsg = SF.addonChatter:New(TT.name)
local debugmode=false
TTmsg:disableDebug()

local function dbg(...)	
	-- [ [
	if not TT.logger then 
		TT.logger = LibDebugLogger:Create("ThievesTools")
		TT.logger:SetEnabled(true)
	end
	if TTmsg:isDebugEnabled() then
		TT.logger:Info(...)
	end
	-- ] ]

	-- mostly because I hate to type
	TTmsg:debugMsg(...)
end

local tempHideBar = false
local message_dest = 0		-- set this to 3 to turn off message on screen and in chat

local function slashToggleDebug()
	-- have a local debugmode variable instead of just using TTmsg:toggleDebug()
	-- (the addonChatter keeps track of its own state without outside assistance)
	-- just so that I can print to chat that I am enabling or disabling debug mode.
	if( debugmode == false ) then
		debugmode = true
		TTmsg:enableDebug()
		TTmsg:systemMessage("Enabling debug")

	else
		TTmsg:systemMessage("Disabling debug")
		debugmode = false
		TTmsg:disableDebug()
	end
end

-- -----------------------------
-- Default Settings

-- default settings for the display and location
local displayTable = {
    offsetx = 0,
    offsety = 0,
    scale = 1,
    border = 10,
    hidden = false,
    locked = false,
    hideMeter = false,
    autoLock = false,
    hide_on_menu = false,
    ann_top = 100,
    ann_left = 100,
}
-- default settings for the status bar
local barTable = {
	Kill = true,
	Loot = true,
    Value = true,
    SellsLeft = true,
    LaundersLeft = true,
    FenceTimer = false,
    BountyTimer = false,
    Bounty = false,
    ClemencyTimer = false,
    Recipes = false,
    Average = false,
    Quality = true,
    Estimate = true,
    Background = true,
    QualityBars = true,
}
local dynamicTable = {
	Kill = true,
	Loot = true,
    Bounty = true,
    BountyTimer = true,
    ClemencyTimer = nil,
}
local filterTable = {
    nojunk = true,
	unjunk = true,
    ignscale = 0,
    autojunkbelow = true,
	never_junk_quality = 5,

    dest_prov_recipe = "Mode_Fence",
    dest_furn_recipe = "Mode_Fence",
    dest_motif      = "Mode_Launder",
    dest_style      = "Mode_Launder",
    dest_trait      = "Mode_Launder",
    dest_gear       = "Mode_Fence",
	dest_jewelry    = "Mode_Ignore",
    dest_furnishing = "Mode_Launder",
    dest_lockpick   = "Mode_Launder",
    dest_soulgem    = "Mode_Launder",
    dest_ingredient = "Mode_Launder",
    dest_ingredient_rare = "Mode_Launder",
    dest_alch_solvent = "Mode_Launder",
    dest_alch_reagent = "Mode_Launder",
    dest_furnmat    = "Mode_Launder",
    dest_mat        = "Mode_Launder",
}
local warnsTable = {
    slotsleft = 5,
    fenceleft = 5,
}

local charTable = {
    not_thief = false,
    autoSteal = false,
	enableJunking = true,
}

-- character-level switches to set if char or AW
-- settings are to be used.
local scopeTable = {
    isFilterAW = true,
    isBarAW = true,
    isDynamicAW = true,
    isWarnAW = true,
    isDisplayAW = true,
}

TT.DefaultAW = {
	filter = filterTable,
	show = barTable,
	dshow = dynamicTable,
	warns = warnsTable,
	display = displayTable,
	-- scope is always character-local
	-- chartt is always character-local
}  -- end of DefaultAW
TT.DefaultC = {
	filter = filterTable,
	show = barTable,
	dshow = dynamicTable,
	warns = warnsTable,
	-- display is always account-wide
	scope = scopeTable,
	chartt = charTable,
} -- end of DefaultC

-- -----------------------------

TT.options = {}

TT.delaying = false
TT.quality = { [0] = 0, 0, 0, 0, 0, 0 }

TT.dshow = { }
TT.bounty = GetFullBountyPayoffAmount()
TT.bounty_start = 0
if( TT.bounty > 0 ) then TT.bounty_start = GetTimeStamp() end

TT.last_fence_d = 0

TT.totalValue = 0
TT.totalQual = 0
TT.recipeCount = 0
TT.motifCount = 0
TT.furnitureCount = 0

TT.fenceCount = 0
TT.launderCount = 0

-- ItemHandlers for each ITEMTYPE.
-- Key = ITEMTYPE_* that the entry applies to
-- See ItemTypeHandler:New()
TT.ItemHandlers = {}
-- ItemHandlers for select EQUIP_TYPEs.
-- Key = EQUIP_TYPE_* that the entry applies to
TT.EquipHandlers = {}

TT.itemChoices = {
	L(TT_CHOICES_FENCE),   -- "Fence",
	L(TT_CHOICES_LAUNDER), -- "Launder",
	L(TT_CHOICES_IGNORE),  -- "Ignore"
	L(TT_CHOICES_JUNK),  -- "Junk"
}
TT.qualityChoices = {
	SF.ColorText(TT_QUAL_LEGENDARY,color.legendary),   -- "Legendary",
	SF.ColorText(TT_QUAL_EPIC,color.epic), -- "Epic",
	SF.ColorText(TT_QUAL_SUPERIOR,color.superior),  -- "Superior",
}
-- Define translation array
TT.ModeArray = {
	["Mode_Fence"] = L(TT_CHOICES_FENCE),
	["Mode_Launder"] = L(TT_CHOICES_LAUNDER),
	["Mode_Ignore"] = L(TT_CHOICES_IGNORE),
	["Mode_Junk"] = L(TT_CHOICES_JUNK),
	[L(TT_CHOICES_FENCE)] = "Mode_Fence",
	[L(TT_CHOICES_LAUNDER)] = "Mode_Launder",
	[L(TT_CHOICES_IGNORE)] = "Mode_Ignore",
	[L(TT_CHOICES_JUNK)] = "Mode_Junk",
}
TT.QualityModeArray = {
	[5] = SF.ColorText(TT_QUAL_LEGENDARY,color.legendary),	-- Legendary
	[4] = SF.ColorText(TT_QUAL_EPIC,color.epic),	-- Epic
	[3] = SF.ColorText(TT_QUAL_SUPERIOR,color.superior),	-- Superior
	[SF.ColorText(TT_QUAL_LEGENDARY,color.legendary)] = 5,
	[SF.ColorText(TT_QUAL_EPIC,color.epic)] = 4,
	[SF.ColorText(TT_QUAL_SUPERIOR,color.superior)] = 3,
	[L(TT_QUAL_LEGENDARY)] = 5,
	[L(TT_QUAL_EPIC)] = 4,
	[L(TT_QUAL_SUPERIOR)] = 3,
}
TT.tempDisableJunking = false
TT.realDisplayValue = false
-- end of ThiefTools options

local WM = WINDOW_MANAGER
local HotItem = ThiefTools_HotItem
local HotList = ThiefTools_HotList
TT.hotSheet = HotList:New(BAG_BACKPACK)

local evtmgr = SF.EvtMgr:New("ThiefTools")

--[[
------------------------------------------------------------------------
	item handler functions that can be assigned to itemtypes
--]]
local function ignoreIt(hotItem)
	TTmsg:debugMsg(SF.str("Ignoring ",hotItem.name," IT=",hotItem.itemType,"  SIT=",hotItem.specializedItemType,"  ET=",hotItem.equipType))
	-- do nothing with it
end

local function fenceIt(hotItem)
	TTmsg:debugMsg(SF.str("Fencing ",hotItem.name," IT=",hotItem.itemType,"  SIT=",hotItem.specializedItemType,"  ET=",hotItem.equipType))
	TT.fenceCount = math.max(0, TT.fenceCount + hotItem.stackCount)
	TT.totalQual  = math.max(0, TT.totalQual + (hotItem.quality * hotItem.stackCount))
	local sellPrice = hotItem.stackSellPrice
	if( hotItem.stackCount < 0 ) then
		TT.totalValue = TT.totalValue - sellPrice

	else
		TT.totalValue = TT.totalValue + sellPrice
	end
	TT.quality[hotItem.quality] = math.max(0, SF.nilDefault(TT.quality[hotItem.quality], 0) + hotItem.stackCount)
end

--[[
    Increment the launder-able items counters given the stack size.
    Unlike fencing, we don't care about the value or quality of laundered items.

    To decrement, pass in a negative stackCount.
]]
local function launderIt(hotItem)
	TTmsg:debugMsg(SF.str("Laundering ",hotItem.name," IT=",hotItem.itemType,"  SIT=",hotItem.specializedItemType,"  ET=",hotItem.equipType))
    TT.launderCount = math.max(0, TT.launderCount + hotItem.stackCount)
end

-- stash it in junk (or not)
local function junkIt(hotItem, isJunk)
	TTmsg:debugMsg("Junking",hotItem.name,"IT=",hotItem.itemType,"  SIT=",hotItem.specializedItemType,"  ET=",hotItem.equipType)
    isJunk = SF.nilDefault(isJunk, true)
    if TT.options.chartt.enableJunking == false or TT.tempDisableJunking == true  then
        return
    end
    if CanItemBeMarkedAsJunk(hotItem.bagId, hotItem.slotIndex) == false then
        return
    end
    if( isJunk == true ) then
		-- never auto-junk legendary items!
		if type(TT.options.filter.never_junk_quality) == "string" then
			TT.options.filter.never_junk_quality = 5
		end
		if hotItem ~= nil and hotItem.quality ~= nil then
			if hotItem.quality >= TT.options.filter.never_junk_quality  then return end

		else
			hotItem.quality = 5
		end
        SetItemIsJunk(hotItem.bagId, hotItem.slotIndex, isJunk)
		hotItem.isJunk = true

	else
		-- unjunking
		if hotItem.isJunk == false  then return end
        SetItemIsJunk(hotItem.bagId, hotItem.slotIndex, false)
		hotItem.isJunk = false
    end
end

--[[
    Increment the fence-able items counters, quality bars, and values
    given the stack size, the adjusted value of a single item,
    and the quality of the item.
]]
local function incrFence( hotItem )
    TTmsg:debugMsg(hotItem.name..": incrFence    "..hotItem.sellPrice)
    -- only increment if the value is greater than the threshold setting
    --local index = hotItem.slotIndex
    if( hotItem.sellPrice >= TT.options.filter.ignscale) then
        --TTmsg:debugMsg("index "..index..": itemValue "..itemValue.." is >= "..TT.options.filter.ignscale)
        fenceIt(hotItem)

    elseif( TT.options.filter.autojunkbelow == true) then
        junkIt(hotItem)
    end
end

-- special handler for ITEMTYPE_FOOD so that we can distinguish (and junk)
-- spoiled food from regular food.
local function foodHandler( hotItem )
	--TTmsg:debugMsg(hotItem.name..": foodHandler")
	if( hotItem.sellPrice == 0) then
		junkIt(hotItem)
	end
  incrFence(hotItem)
end

--[[
	end of item handler functions
------------------------------------------------------------------------
]]

-- Setup for the ItemTypeHandler prototype
local ItemTypeHandler = ThiefTools_ItemTypeHandler
ItemTypeHandler.namelist = {
	[incrFence] = "incrFence",
	[fenceIt] = "fenceIt",
	[launderIt] = "launderIt",
	[ignoreIt] = "ignoreIt",
	[junkIt] = "junkIt",
	[foodHandler] = "foodHandler",
}
ItemTypeHandler.defaultHandler = incrFence

------------------------------------------------------------------------

function TT.setOptionsScope()
    TT.options = {}
    -- scope is always per-char
    TT.options.scope = TT.savedC.scope
	SF.defaultMissing(TT.options.scope, scopeTable)
	local scope = TT.options.scope

    -- chartt is always per-char
    TT.options.chartt = TT.savedC.chartt
	SF.defaultMissing(TT.options.chartt,charTable)

     -- display is always AW
    TT.options.display = TT.savedAW.display
	SF.defaultMissing(TT.options.display,displayTable)

    if( scope.isFilterAW ) then
        TT.options.filter = TT.savedAW.filter

    else
        TT.options.filter = TT.savedC.filter
    end
	SF.defaultMissing(TT.options.filter,filterTable)

    if( scope.isBarAW ) then
        TT.options.show = TT.savedAW.show
        TT.options.dshow = TT.savedAW.dshow

    else
        TT.options.show = TT.savedC.show
        TT.options.dshow = TT.savedC.dshow
    end
	SF.defaultMissing(TT.options.show,barTable)
	SF.defaultMissing(TT.options.dshow,dynamicTable)

    if( scope.isWarnAW ) then
        TT.options.warns = TT.savedAW.warns

    else
        TT.options.warns = TT.savedC.warns
    end
	SF.defaultMissing(TT.options.warns,warnsTable)

end

--[[
local hiddenStates = {
    [STEALTH_STATE_HIDDEN] = true,	-- =3
    [STEALTH_STATE_STEALTH] = true,	-- =4
    [STEALTH_STATE_HIDDEN_ALMOST_DETECTED] = true, 	-- =5
    [STEALTH_STATE_STEALTH_ALMOST_DETECTED] = true,	-- =6
    [STEALTH_STATE_NONE] = false,	-- =0
    [STEALTH_STATE_DETECTED] = false,	-- =1
}
--]]
-- handler for EVENT_STEALTH_STATE_CHANGED
local function onStealthChanged(iEventCode, sUnitTag, iStealthState)
	if (sUnitTag ~= "player") then return end

    local tmsg = SF.GetIconized(L(TT_ANNOUNCE_BE_CAREFUL), color.bronze)
    if (iStealthState == STEALTH_STATE_HIDDEN_ALMOST_DETECTED
            or iStealthState == STEALTH_STATE_STEALTH_ALMOST_DETECTED ) then
        TT:ShowMessage(tmsg, message_dest)
    end
	if( TT.options.chartt == nil ) then return end
	if( TT.options.chartt.autoSteal ~= true ) then return end

    local grabby = { ["look"] = "0", ["take"] = "1" }
	local isAutoLootEnabled = GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN)
	if( iStealthState == STEALTH_STATE_NONE or iStealthState == STEALTH_STATE_DETECTED ) then
		-- not sneaking (or we've been seen!)
		if (isAutoLootEnabled == grabby.take) then
			-- we're not sneaking so disable auto-steal
			SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, grabby.look)
		end
	else
		-- we are sneaking so enable auto-steal
		SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, grabby.take)
	end
end

-- set the primary, secondary, and alternate handlers for the list of ITEMTYPEs in types
-- specializedHandlerMap is a table of handlers keyed with the SPECIALIZED_ITEMTYPEs
-- if some SPECIALIZED_ITEMTYPEs are not specified it will use the primary instead
local function set_item_handlers(types, primaryfunc, secondaryfunc, specializedHandlerMap)
	if( types == nil ) then return end

	-- make sure we have values
	local specializedHandler = SF.nilDefault(specializedHandlerMap,  {})

	-- for each of the ITEMTYPEs passed in, set up the handler set
	for _,v in pairs(types) do
		TT.ItemHandlers[v] = SF.nilDefault(TT.ItemHandlers[v], ItemTypeHandler:New(v))

		TT.ItemHandlers[v].primary = primaryfunc
		TT.ItemHandlers[v].secondary = secondaryfunc
		for skey,shdlr in pairs(specializedHandler) do
			-- because we don't have handler name strings available here
			-- to pass in, we have to have already set them up in
			-- ItemTypeHandler.namelist.
			TT.ItemHandlers[v]:setAlternate( skey, shdlr )
		end
	end
end

-- set the primary handlers for the list of EQUIP_TYPEs in types
local function set_equip_handlers(types, primaryfunc)
	if( types == nil ) then return end

	--TTmsg:debugMsg("Setting equipment handler choices")
	--TTmsg:debugMsg("handler: ", ItemTypeHandler.namelist[primaryfunc])

	-- for each of the EQUIP_TYPEs passed in, set up the handler set
	for _,v in pairs(types) do
		--TTmsg:debugMsg("v: ",v)
		TT.EquipHandlers[v] = SF.nilDefault(TT.EquipHandlers[v], ItemTypeHandler:New(v))
		--TTmsg:debugMsg("Type: ",v,"  handler: ", ItemTypeHandler.namelist[primaryfunc])
		TT.EquipHandlers[v].primary = primaryfunc
	end
end

--[[
    Pick the appropriate handler for an itemtype based on the
    option passed in (one of "Fence", "Launder", "Junk", or "Ignore").
    Return the chosen handler function.
]]
local function pick_handler(opt)
    if(opt == "Mode_Fence") then
        return incrFence
    elseif(opt == "Mode_Launder") then
        return launderIt
    elseif(opt == "Mode_Junk") then
        return junkIt
    else
        return ignoreIt  -- ignore
    end
end

--[[
    Set the handlers for all of the itemtypes that we allow separate settings
    for on the option page. Pass in the table of filter settings. Add entries
    into our ItemHandler table for each of the itemtypes we care about.
    Setting a handler function to nil means ignore that itemtype (alternatively
	you can set the handler function to ignoreIt).
]]
function TT.set_recipe_handler(filters)
	SF.nilDefault(filters, TT.options.filter)
	local types = {ITEMTYPE_RECIPE}
	local furnprime = pick_handler(filters.dest_furn_recipe)	-- this will be the default
	--[[
	-- furnishing recipe subtypes
	local furnishing_subtypes = {
		SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING,
		SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING,
		SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING,
		SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING,
		SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING,
		SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING,
	}
	--]]

	local provfunc = pick_handler(filters.dest_prov_recipe)
	-- provisioning recipe subtypes
	local consumable_subtypes = {
		[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK]=provfunc,
		[SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD]=provfunc,
	}

	-- count all recipes
	local secondfunc  = function(stackCount)
			TT.recipeCount = math.max(0,TT.recipeCount + stackCount)
		end
	set_item_handlers(types, furnprime, secondfunc, consumable_subtypes )
end

function TT.set_motif_handler(filters)
	local types = {ITEMTYPE_RACIAL_STYLE_MOTIF}
	local primefunc = pick_handler(filters.dest_motif)

	-- count motifs
	local secondfunc  = function(stackCount)
			TT.motifCount = math.max(0,TT.motifCount + stackCount)
		end
	set_item_handlers(types, primefunc, secondfunc)
end

function TT.set_alch_reagent_handler(filters)
	local types = {ITEMTYPE_REAGENT}
	local primefunc = pick_handler(filters.dest_alch_reagent)
	set_item_handlers(types, primefunc)
end

function TT.set_alch_solvent_handler(filters)
	local types = {ITEMTYPE_POTION_BASE, ITEMTYPE_POISON_BASE}
	local primefunc = pick_handler(filters.dest_alch_solvent)
	set_item_handlers(types, primefunc)
end

function TT.set_furnishing_handler(filters)
	local types = {ITEMTYPE_FURNISHING}
	local primefunc = pick_handler(filters.dest_furnishing)
    local secondfunc = function(stackCount)
            TT.furnitureCount = math.max(0,TT.furnitureCount + stackCount)
        end
	set_item_handlers(types, primefunc, secondfunc)
end

function TT.set_ingredient_handler(filters)
	local primefunc = pick_handler(filters.dest_ingredient)
	local tertiaryfunc = pick_handler(filters.dest_ingredient_rare)
	set_item_handlers({ITEMTYPE_INGREDIENT}, primefunc, nil, {
		[SPECIALIZED_ITEMTYPE_INGREDIENT_RARE]=tertiaryfunc,
		[SPECIALIZED_ITEMTYPE_INGREDIENT_FOOD_ADDITIVE]=tertiaryfunc,
		})
	local types = {ITEMTYPE_FLAVORING, ITEMTYPE_SPICE}
	set_item_handlers(types, primefunc)
end

function TT.set_furnishing_material_handler(filters)
	local types = {ITEMTYPE_FURNISHING_MATERIAL, ITEMTYPE_ADDITIVE}
	local primefunc = pick_handler(filters.dest_furnmat)
	set_item_handlers(types, primefunc)
end

-- don't really expect this one so it does not have an option setting right now
function TT.set_material_handler(filters)
	local types = {ITEMTYPE_RAW_MATERIAL,
			ITEMTYPE_WOODWORKING_MATERIAL, ITEMTYPE_WOODWORKING_RAW_MATERIAL,
			ITEMTYPE_CLOTHIER_MATERIAL, ITEMTYPE_CLOTHIER_RAW_MATERIAL,
			ITEMTYPE_BLACKSMITHING_MATERIAL, ITEMTYPE_BLACKSMITHING_RAW_MATERIAL}
	local primefunc = pick_handler(filters.dest_mat)
	set_item_handlers(types, primefunc)
end

function TT.set_gear_handler(filters)
	local types = {ITEMTYPE_ARMOR, ITEMTYPE_WEAPON}
	local primefunc = pick_handler(filters.dest_gear)
	set_item_handlers(types, primefunc)
end

function TT.set_jewelry_handler(filters)
	local types = {EQUIP_TYPE_RING, EQUIP_TYPE_NECK}
	local primefunc = pick_handler(filters.dest_jewelry)
	set_equip_handlers(types, primefunc)
end


function TT.set_trait_handler(filters)
    -- handle trait materials
	local types = {ITEMTYPE_ARMOR_TRAIT, ITEMTYPE_WEAPON_TRAIT}
	local primefunc = pick_handler(filters.dest_trait)
	set_item_handlers(types, primefunc)
end

function TT.set_style_handler(filters)
    -- handle style materials
	local types = {ITEMTYPE_STYLE_MATERIAL}
	local primefunc = pick_handler(filters.dest_style)
	set_item_handlers(types, primefunc)
end

function TT.set_lockpick_handler(filters)
    -- handle lockpicks
	local types = {ITEMTYPE_LOCKPICK, ITEMTYPE_TOOL}
	local primefunc = pick_handler(filters.dest_lockpick)
	set_item_handlers(types, primefunc)
end

function TT.set_soulgem_handler(filters)
    -- handle soulgems
	local types = {ITEMTYPE_SOUL_GEM}
	local primefunc = pick_handler(filters.dest_soulgem)
	set_item_handlers(types, primefunc)
end

function TT.set_handlers(filters)
    -- handle gear types
    TT.set_gear_handler(filters)

    -- handle jewelry types
    TT.set_jewelry_handler(filters)

    -- handle trait materials
    TT.set_trait_handler(filters)

    -- handle recipes, blueprints, designs, praxis, etc
    TT.set_recipe_handler(filters)

    -- handle motifs
    TT.set_motif_handler(filters)

    -- handle style materials
    TT.set_style_handler(filters)

    -- handle furnishings
    TT.set_furnishing_handler(filters)

    -- handle lockpicks
    TT.set_lockpick_handler(filters)
    TT.set_soulgem_handler(filters)

    -- handle ingredients
    TT.set_ingredient_handler(filters)
	TT.set_furnishing_material_handler(filters)
	TT.set_material_handler(filters)
	TT.set_alch_solvent_handler(filters)
	TT.set_alch_reagent_handler(filters)

	-- handle food
	set_item_handlers({ITEMTYPE_FOOD},foodHandler)

    -- ignore treasure maps (and other trophies)
	set_item_handlers({ITEMTYPE_TROPHY}, ignoreIt)

    -- automatically junk stuff
	set_item_handlers({ITEMTYPE_DEPRECATED}, junkIt)

	-- always ignore containers
	set_item_handlers({ITEMTYPE_CONTAINER}, ignoreIt)
end

local function fmt_time(t)
    local ss = t % 60
    local mm = (t % 3600) - ss
    local hh = (t % 86400) - mm
    local dd = t - hh

    mm = mm/60
    hh = hh/3600
    dd = dd/86400

    if(dd >= 1) then
        return string.format("%02dd%02dh", dd, hh)
    elseif(hh >= 1) then
        return string.format("%02d:%02d", hh, mm)
    else
        return string.format("%02d:%02d", mm, ss)
    end
end

--[[
    Zero all of our counters
--]]
local function zeroStats()
   TT.recipeCount = 0
   TT.motifCount = 0
   TT.furnitureCount = 0

   TT.fenceCount = 0
   TT.launderCount = 0

   TT.totalValue = 0
   TT.totalQual = 0

   for i = 0,5 do
      TT.quality[i] = 0
   end
end

--[[
    Add the contents of a slot to our counts
	(Relies on ScanStolenGoods having created a hotSheet)
--]]
local function incrGoodsFromSlot(bagId, index)

	local hotItem = TT.hotSheet:getItem(index)
    if( TT.options.filter.nojunk == true and hotItem.isJunk == true ) then return end

	--hotItem:Display()
	local stackCount = hotItem.stackCount

	if( hotItem.equipType ~= nil and hotItem.equipType ~= 0 ) then
		TTmsg:debugMsg("Found non-nil EQUIP_TYPE ",hotItem.equipType)
		local ehandlerSet = TT.EquipHandlers[hotItem.equipType]
		if(ehandlerSet ~= nil) then
			TTmsg:debugMsg("Found EQUIP_TYPE item handler for "..hotItem.name)
			TTmsg:debugMsg(ItemTypeHandler.namelist[ehandlerSet:getEffectivePrimary()])
			ehandlerSet:effectiveEquip(hotItem)
			return
		end
	end

	local handlerSet = TT.ItemHandlers[hotItem.itemType]
	if(handlerSet) then
		TTmsg:debugMsg("Found ITEMTYPE item handler")
		TTmsg:debugMsg(handlerSet:getHandlerName(handlerSet:getEffectivePrimary()))
		handlerSet:effectivePrimary(hotItem)
        if(handlerSet.special) then
            handlerSet.special(stackCount)
        end
    else
		TTmsg:debugMsg("No handler found - fence it")
        -- anything without a handler is counted as fence-able
        incrFence(hotItem)
    end
end

-- Create a list of all stolen items we have in our pack
function TT:ScanStolenGoods()
    local bagId = BAG_BACKPACK
    local bagSlots = GetBagSize(bagId)
    TT.hotSheet:empty()
	TTmsg:debugMsg("bagSlots = "..bagSlots)
    for index = 1, bagSlots do
		isHot = IsItemStolen(bagId, index)
		if( isHot == true ) then
			TTmsg:debugMsg("HotItem - "..bagId.."  "..index)
			local slot = HotItem:New(bagId, index)
			--slot:Display()
			TT.hotSheet:addItem(slot)
		end
    end
end

function TT:CalcStolenGoods()
	if(TT.delaying == true) then return; end

	zeroStats()
	TT:ScanStolenGoods()
    local bagId = BAG_BACKPACK
    for k,v in pairs(TT.hotSheet.itemList) do
        if( v.stolen == true ) then -- should always be true
            incrGoodsFromSlot(bagId, k)
        end
    end
end

function TT:DelayedCalcStolenGoods(dur)
    if(TT.delaying == true) then return end
    TT.delaying = true
    dur = SF.nilDefault(dur, 250)
    EVENT_MANAGER:RegisterForUpdate(TT.name.."DelayedCalc", dur,
      function()
        EVENT_MANAGER:UnregisterForUpdate(TT.name.."DelayedCalc")
		--dbg("doing delayed calc")
        TT.delaying = false
        TT:CalcStolenGoods()
        TT:checkFenceSlotsWarning(INVENTORY_BACKPACK)
        TT:UpdateDisplay()
        TT:UpdateControls()
   end)
end

function TT.SavePosition()
   local x, y
   local win = TT.window

   y = win:GetTop()
   x = win:GetLeft()

   if (x < 0 ) then x = 0 end
   if( y < 0 ) then y = 0 end
   TT.options.display.offsetx = x
   TT.options.display.offsety = y
end

function TT:ResetPosition()
   TT.options.display.offsetx = 0
   TT.options.display.offsety = 0
end

function TT:lockWindow()
    if(TT.options.display.locked == true) then
        TT.window:SetMovable(false)
    else
        TT.window:SetMovable(true)
    end
end

function TT:hideMeter()
    if(TT.options.display.hideMeter == true) then
        ZO_HUDInfamyMeter:SetHidden(true)
    else
        ZO_HUDInfamyMeter:SetHidden(false)
    end
end

--[[
local TT_D = { -- Dungeons ----------------------------------------------------------
		[ 144] = 1, -- Spindleclutch I
		[ 936] = 1, -- Spindleclutch II
		[ 380] = 1, -- The Banished Cells I
		[ 935] = 1, -- The Banished Cells II
		[ 283] = 1, -- Fungal Grotto I
		[ 934] = 1, -- Fungal Grotto II
		[ 146] = 1, -- Wayrest Sewers I
		[ 933] = 1, -- Wayrest Sewers II
		[ 126] = 1, -- Elden Hollow I
		[ 931] = 1, -- Elden Hollow II
		[  63] = 1, -- Darkshade Caverns I
		[ 930] = 1, -- Darkshade Caverns II
		[ 130] = 1, -- Crypt of Hearts I
		[ 932] = 1, -- Crypt of Hearts II
		[ 176] = 1, -- City of Ash I
		[ 681] = 1, -- City of Ash II (Inner Grove)
		[ 148] = 1, -- Arx Corinium
		[  22] = 1, -- Volenfell
		[ 131] = 1, -- Tempest Island
		[ 449] = 1, -- Direfrost Keep
		[  38] = 1, -- Blackheart Haven
		[  31] = 1, -- Selene's Web
		[  64] = 1, -- Blessed Crucible
		[  11] = 1, -- Vaults of Madness
		[ 678] = 1, -- Imperial City Prison (Bastion)
		[ 688] = 1, -- White-Gold Tower (Green Emperor Way)
		[ 843] = 1, -- Ruins of Mazzatun
		[ 848] = 1, -- Cradle of Shadows
		[ 973] = 1, -- Bloodroot Forge
		[ 974] = 1, -- Falkreath Hold
		[1009] = 1, -- Fang Lair
		[1010] = 1, -- Scalecaller Peak
		[1052] = 1, -- Moon Hunter Keep
		[1055] = 1, -- March of Sacrifices (Bloodscent Pass)
		[1080] = 1, -- Frostvault
		[1081] = 1, -- Depths of Malatar
		[1122] = 1, -- Moongrave Fane
		[1123] = 1, -- Lair of Maarselok
		[1152] = 1, -- Icereach
		[1153] = 1, -- Unhallowed Grave
		[1197] = 1, -- Stone Garden
		[1201] = 1, -- Castle Thorn
		[1228] = 1, -- Black Drake Villa
		[1229] = 1, -- The Cauldron
		[1267] = 1, -- Red Petal Bastion
		[1268] = 1, -- The Dread Cellar
		[1301] = 1, -- Coral Aerie
		[1302] = 1, -- Shipwright's Regret
		[1360] = 1, -- Earthen Root Enclave
		[1361] = 1, -- Graven Deep
		[1389] = 1, -- Bal Sunnar
		[1390] = 1, -- Scrivener's Hall
		[1470] = 1, -- Oathsworn Pit
		[1471] = 1, -- Bedlam Veil

	}

local TT_T = { -- Trials ------------------------------------------------------------
		[ 636] = 1, -- Hel Ra Citadel
		[ 638] = 1, -- Aetherian Archive
		[ 639] = 1, -- Sanctum Ophidia
		[ 725] = 1, -- Maw of Lorkhaj
		[ 975] = 1, -- Halls of Fabrication
		[1000] = 1, -- Asylum Sanctorium
		[1051] = 1, -- Cloudrest
		[1121] = 1, -- Sunspire
		[1196] = 1, -- Kyne's Aegis
		[1263] = 1, -- Rockgrove
		[1344] = 1, -- Dreadsail Reef
		[1427] = 1, -- Sanity's Edge
	}
--]]
local TT_A = { -- Arenas ------------------------------------------------------------
		[ 635] = 1, -- Dragonstar Arena
		[ 677] = 1, -- Maelstrom Arena
		[1082] = 1, -- Blackrose Prison
		[1227] = 1, -- Vateshran Hollows
		[1436] = 1, -- Infinite Archive
	}

local zoneType = { DELVE = 1, PUBLICDUNGEON=2, GROUPDUNGEON=3, TRIAL=4, IA =5, ARENA=6, UNKNOWN=7}
local function getCurrentZoneType()

	local currentZoneId = GetZoneId(GetCurrentMapZoneIndex())
    if IsInstanceEndlessDungeon() then  return zoneType.IA end

    if TT_A[currentZoneId] then return zoneType.ARENA end


    if IsPlayerInRaid() or IsPlayerInRaidStagingArea() then return zoneType.TRIAL end
    

    local isInDungeon = (IsUnitInDungeon("player") or GetMapContentType() == MAP_CONTENT_DUNGEON) or false

    --Check if user is in any dungeon
	if isInDungeon then
        --Difficulty will be 0 if not in a dungeon, 1 if in a delve, 2 if elsewhere
        -- if Difficulty is anything other than zero; it's a Group Dungeon
		if ZO_WorldMap_GetMapDungeonDifficulty() > DUNGEON_DIFFICULTY_NONE then
			return zoneType.GROUPDUNGEON
		else
		    -- if Difficulty is zero; it's either a Delve or a Public Dungeon
            --local poiIndex = pin:GetPOIIndex()
            --local poiType = GetPOIType(zoneIndex, poiIndex)
           -- local instanceType = GetPOIInstanceType(zoneIndex, poiIndex)
            --if instanceType == INSTANCE_TYPE_PUBLIC_DUNGEON then
            --    return zoneType.PUBLICDUNGEON
            --end

            -- right now we return delve for public dungeons too
            return zoneType.DELVE
        
		end
	end

    return zoneType.UNKNOWN
end

local function isNotJusticeArea()
	local shouldhide = false
	local zoneName = GetZoneNameByIndex(GetCurrentMapZoneIndex())
	local currentZoneId = GetZoneId(GetCurrentMapZoneIndex())
    local tw = SCENE_MANAGER:GetCurrentScene():GetName()
    local currentZoneType = getCurrentZoneType()
	if IsPlayerInAvAWorld() or IsActiveWorldBattleground() then
		shouldhide = true
	elseif currentZoneType == zoneType.IA and TT.options.display.hide_on_IA then
		shouldhide = true
	elseif currentZoneType == zoneType.GROUPDUNGEON and TT.options.display.hide_on_Dung then
		shouldhide = true
	elseif currentZoneType == zoneType.TRIAL and TT.options.display.hide_on_Trial then
		shouldhide = true
	elseif currentZoneType == zoneType.ARENA and TT.options.display.hide_on_Arena then
		shouldhide = true
	elseif currentZoneType == zoneType.DELVE and TT.options.display.hide_on_PublicDungeon then
		shouldhide = true
	end
	return shouldhide
end

function TT:UpdateDisplay()
    local w = TT.window
	local shouldhide = false
    local tw = SCENE_MANAGER:GetCurrentScene():GetName()
	shouldhide = isNotJusticeArea()
	if not shouldhide then
		if (tw ~= "hudui"  and tw ~= "hud" and TT.options.display.hide_on_menu == true) then
			shouldhide = true
		else
			if( TT.options.chartt.not_thief == true ) then
				shouldhide = true

			elseif( tempHideBar == true ) then
				shouldhide = true

			else
				shouldhide = TT.options.display.hidden
			end
		end
	end
	if w then
		w:SetHidden(shouldhide)

		local totalSells, sellsUsed, sellsReset = GetFenceSellTransactionInfo()
		local totalLaunders, laundersUsed, laundersReset = GetFenceLaunderTransactionInfo()
		local sellsLeft = totalSells - sellsUsed
		local laundersLeft = totalLaunders - laundersUsed
		local totFenceValue = TT.totalValue
		local aveFenceValue = totFenceValue/TT.fenceCount

		w.l_sellsleft:SetText(string.format("%d/%d", TT.fenceCount, sellsLeft))
		if(TT.options.show.LaundersLeft) then
			w.l_laundersleft:SetText(string.format("%d/%d", TT.launderCount, laundersLeft))
		else
			w.l_laundersleft:SetText("")
		end

		w.l_value:SetText(string.format("%d", totFenceValue))

		w.l_bounty:SetText(string.format("%d", GetReducedBountyPayoffAmount()))

		if(TT.fenceCount < 1) then
			w.l_average:SetText(string.format("%.2f", 0))
			w.l_estimate:SetText(string.format("%d", 0))
			w.l_quality:SetText(string.format("%.2f", 0))

			for i = 0,5 do
				w.bar[i]:SetHeight(0)
			end
		else
			w.l_average:SetText(string.format("%.2f", aveFenceValue))
			w.l_estimate:SetText(string.format("%d", math.floor(aveFenceValue) * sellsLeft))
			w.l_quality:SetText(string.format("%.2f", TT.totalQual/TT.fenceCount))
		end -- Text Labels

		for i = 0,5 do
			if(TT.quality[i] and TT.quality[i] > 0) then
				local percent = TT.quality[i] / TT.fenceCount
				w.bar[i]:SetHeight(math.max(1, percent * 14))
			else
				w.bar[i]:SetHeight(0)
			end
		end
	end
end

-- used by bindings.xml
function TT:toggle()
   local sbar = TT.window

   if(sbar:IsHidden() == true) then
      TT:CalcStolenGoods()
      TT:UpdateDisplay()
   end

   TT.options.display.hidden = not sbar:IsHidden()
   sbar:SetHidden(TT.options.display.hidden)
end

-- used by bindings.xml
function TT:lockWindow1()
    if(TT.options.display.locked == true) then
        TT.window:SetMovable(true)
        TT.options.display.locked = false
        TTmsg:systemMessage(L(TT_MSG_UNLOCKED))
        TT.SavePosition()
    else
        TT.window:SetMovable(false)
        TT.options.display.locked = true
        TTmsg:systemMessage(L(TT_MSG_LOCKED))
        TT.SavePosition()
    end
end

function TT:checkFreeSlotsWarning(bagId)
    if( TT.options.warns.slotsleft > 0) then
        local slotsleft = GetNumBagFreeSlots(bagId)
        local fmsg = SF.str(L(TT_FREE_SLOTS_LEFT)," ",slotsleft)
        if( slotsleft == 0 ) then
            TT.ShowMessage(SF.GetIconized(fmsg, color.red), message_dest)
        else
            if( slotsleft <= TT.options.warns.slotsleft ) then
                TT.ShowMessage(fmsg, message_dest)
            end
        end
    end
end

local lastfencelevel = -1
function TT:checkFenceSlotsWarning(bagId)
    if( TT.options.warns.fenceleft and (TT.options.warns.fenceleft > 0)) then
        local sellsLeft = FENCE_MANAGER.totalSells - FENCE_MANAGER.sellsUsed - TT.fenceCount
        local floored = math.max(0,sellsLeft)
        if( floored == lastfencelevel ) then return end
        if( floored == 0 ) then
            TT.ShowMessage("|c"..color.red.." "..L(TT_FENCE_SLOTS_LEFT).." "..floored.."|r", message_dest)
        else
            if( sellsLeft <= TT.options.warns.fenceleft ) then
                TT.ShowMessage(L(TT_FENCE_SLOTS_LEFT).." "..sellsLeft, message_dest)
            end
        end
        lastfencelevel = floored
    end
end


-- Announce the given Message to: 0=both, 1=Chat, 2=Box, 3=No messages ever)
-- (0 depends on what is set in settings)
function TT.ShowMessage(sText, ChatOrBox)
	if( ChatOrBox == 3 or  message_dest == 3 or sText == nil or sText == "") then return end

    if( type(sText) == 'number' ) then
        sText = L(sText)
    end
    if( type(sText) ~= 'string') then return end

	-- info goes to MessageBox, to chat or both
	if( ChatOrBox == 0  or ChatOrBox == 2 ) then
		ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, sText)
	end
	if( ChatOrBox == nil or ChatOrBox == 0  or ChatOrBox == 1 ) then
		TTmsg:systemMessage(sText)
	end
end


-- [[ Event handlers ]]
-- handler for EVENT_ACTION_LAYER_PUSHED and EVENT_ACTION_LAYER_POPPED
local function onLayerChange(evc, index, active)
    if(TT.options.display.hide_on_menu == false) then return end

    TT.window:SetHidden((active ~= 2))
end

local lastLaundered = {}
local function onSlotUpdate(evCode, bagId, slotIndex, isNewItem, 
	itemSoundCategory, updateReason,  stackCountChange)

    --if(bagId ~= INVENTORY_BACKPACK) then  return end
    if updateReason ~= INVENTORY_UPDATE_REASON_DEFAULT then return end
    if IsUnderArrest() then return end

	local itm = HotItem:New(bagId,slotIndex)
	itm.IsJunk = IsItemJunk(bagId, slotIndex)
    if isNewItem and itm.stolen then
        TT.hotSheet:addItem(itm)
    end
	lastLaundered = {}
	if isNewItem == false and itm.IsJunk and stackCountChange >= 0 and itm.stolen == false then
		lastLaundered.bagId = bagId
		lastLaundered.slotIndex = slotIndex
	end

    if(TT.delaying == true) then
		--dbg("Delaying")
		return
	end

    if(isNewItem == true) then
		--dbg("checking free slots")
        TT:checkFreeSlotsWarning(bagId)
    end

   -- All right, we've got some bag management going on, so don't
   -- update every time.
   --dbg("set up for delayed")
   TT:DelayedCalcStolenGoods(250)
end

-- handler for EVENT_LOOT_RECEIVED
local function onLoot(evc, receiver, name, count, isc, itemtype, isself, ispicked)
	dbg("name=",name,"count=",count,
				"itype=",itemtype,"isself=",SF.bool2str(isself),
				"ispicked=",SF.bool2str(ispicked))
    if(not isself) then return end

    -- No way to tell if the item was stolen!  IsItemLinkStolen()
    -- doesn't return true.  Doing this in onSlotUpdate() means we
    -- can't tell if it's being added to a stack, or splitting a stack.
    TT:DelayedCalcStolenGoods(250)
end

-- handler for EVENT_ITEM_LAUNDER_RESULT
local function onLaunder(evc, res)
    if(res ~= ITEM_LAUNDER_RESULT_SUCCESS) then return end

	if TT.options.filter.unjunk and not ZO_IsTableEmpty(lastLaundered)  then
		TT.logger:Debug(SF.str("moving out of junk - bag ", lastLaundered.bagId,
			" slot ", lastLaundered.slotIndex))
		SetItemIsJunk(lastLaundered.bagId, lastLaundered.slotIndex, false)
		lastLaundered={}
	end

    TT:DelayedCalcStolenGoods(500)
end

-- handler for EVENT_OPEN_FENCE and EVENT_CLOSE_STORE
local function onFence(status)
    if(status) then
        TT.isFencing = true

    elseif(TT.isFencing == true) then
        TT.isFencing = false
        TT:UpdateDisplay()
		TT:UpdateControls()
    end
end

-- handler for EVENT_JUSTICE_STOLEN_ITEMS_REMOVED
local function onApprehended(evc)
	zeroStats()
	TT.hotSheet:empty()
	lastLaundered = {}
	TT:UpdateDisplay()
	TT:UpdateControls()
end

-- handler for EVENT_SELL_RECEIPT
local function onSold(evc, itemlink, count, money)
    if(not TT.isFencing) then return end
    if(TT.isFencing == false) then return end

    -- There's no way to tell if the itemlink is junk,
    -- so we can't tell whether to (un)track it or not
    -- Just wait and then rescan the backpack.
    TT:DelayedCalcStolenGoods()
end

-- Stolen item is removed from inventory
local function onRemoved(bagId, slotIndex, slot)
    if( slot.stolen == false ) then return end

	if lastLaundered.slotIndex == slotIndex then
		lastLaundered = {}
	end
	local item = TT.hotSheet:getItem(slotIndex)
	if( not item ) then return end

	item.stackCount = -1 * item.stackCount
    incrGoodsFromSlot(bagId, slotIndex)
	TT.hotSheet:removeItem(slotIndex)

    TT:UpdateDisplay()
	TT:UpdateControls()
end

--[[
	bounty calculation and updating
--]]
local function resetBountyWatch()
    TT.bounty = GetFullBountyPayoffAmount()

    if(TT.bounty == 0) then
        TT.bounty_start = 0
        TT.window.l_bountytimer:SetText("00:00")
    else
        TT.bounty_start = GetTimeStamp()
    end
end

local function bountyCheck(now, drift)
    if(TT.bounty_start == 0) then return end

    local bounty = GetFullBountyPayoffAmount()
	local sec = GetSecondsUntilBountyDecaysToZero()
    if(sec < 0) then
      TT.window.l_bountytimer:SetText("00:00")
    else
      TT.window.l_bountytimer:SetText(SF.secondsToClock(sec))
    end
	TT:UpdateDisplay()
	TT:DynamicBountyCheck()
    if(TT.options.display.hideMeter == true) then
        ZO_HUDInfamyMeter:SetHidden(true)
    else
        ZO_HUDInfamyMeter:SetHidden(false)
    end
end

function TT:DynamicBountyCheck()
	TT.dshow.Bounty = false
	TT.dshow.BountyTimer = false

	value = GetBounty()
	if(value ~= 0) then
		TT.dshow.Bounty = true
		TT.dshow.BountyTimer = true
	end

	TT:UpdateDisplay()
	TT:UpdateControls()
end

local function onBountyChange(evc, old, new)
   resetBountyWatch()
   if ((new == 0) or ( new ~= old )) then
      TT:DynamicBountyCheck()
   end
end

local function fenceCheck(now, drift)
    local reset, d = TT:TimeToFenceReset(now)
    TT.window.l_fencetimer:SetText(reset)
    TT.last_fence_d = d
end

local function clemencyCheck(now, drift)
    --if(TT.clemency_start == 0) then return end

    local sec = GetTimeToClemencyResetInSeconds()
    if(sec <= 0) then
      TT.window.l_clemencytimer:SetText("00:00")
    else
      TT.window.l_clemencytimer:SetText(SF.secondsToClock(sec))
    end
end

local function onTick()
	local now = GetTimeStamp()
	local drift = (now - TT.lasttick - 1)

	bountyCheck(now, drift)
	fenceCheck(now, drift)
	clemencyCheck(now, drift)

	TT:UpdateDisplay()
	TT:UpdateControls()

   TT.lasttick = now
end

local function setupTimer()
   TT.lasttick = GetTimeStamp()
   TT.bounty = GetBounty()
   TT:DynamicBountyCheck()

   EVENT_MANAGER:RegisterForUpdate(TT.name.."OnTick", 5000, onTick)
end

--[[
    Create an addon-unique name for "x"
]]
local function unqx(x,ctl)
    return SF.str(TT.name, SF.nilDefault(ctl, "Window"), SF.nilDefault(x,"") )
end

--[[
    Make the control(s) for an icon/label pair for the
    status bar.

	ex.    {"Kill", 0, 8, "0", "/esoui/art/floatingmarkers/darkbrotherhood_target.dds", rgb.red},
]]
local function make_control(name, rel, lrel, offset, str, dds)
   local w = TT.window
   dbg("making control for "..name)

   local make_icon = function(name, rel, offset, dds)
		dbg("making icon for "..name)
		local icon = WM:CreateControl(unqx(name,"Icon"), w.bg, CT_TEXTURE)
		icon:SetTexture(dds)
		icon:SetDimensions(24,24)

		if(rel) then
			icon:SetAnchor(LEFT, rel, RIGHT, offset, 0)
		else
			icon:SetAnchor(LEFT, w.bg, LEFT, offset, 0)
		end

        return icon
   end

   local make_label = function(name, rel, offset, str)
		dbg("making label for "..name)
		local label = WM:CreateControl(unqx(name,"Label"), w.bg, CT_LABEL)
		label:SetFont("ZoFontGame")

		if(rel) then
			label:SetAnchor(LEFT, rel, RIGHT, offset, 0)
		else
			label:SetAnchor(LEFT, w.bg, LEFT, offset, 0)
		end

		label:SetText(str)
		label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
		label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
		return label
   end



   local icon = make_icon(name, rel, offset * TT.options.display.scale, dds)
   local label = make_label(name, icon, math.min(lrel, TT.options.display.scale*lrel), str)

   name = string.lower(name)

   w["icon_"..name] = icon
   w["l_"..name] = label

   return label
end

--[[
    Make the quality bars of stolen items for the status bar
]]
local function make_bars(rel)
   local w = TT.window
   local last_bar = rel
   local rgb = SF.rgb

   local make_bar = function(name, rgbc, offsetx, offsety)
      local bar = WM:CreateControl(unqx("Bar"..name), w.bg, CT_TEXTURE)
      bar:SetAnchor(BOTTOMLEFT, last_bar, BOTTOMRIGHT, 4+(SF.nilDefault(offsetx, 0)), (SF.nilDefault(offsety, 0)))
      bar:SetDimensions(8, 0)
      bar:SetColor(SF_Color.UnpackRGBA(rgbc))
      last_bar = bar
      return bar
   end
   
   w.bar = {}
   w.bar[0] = make_bar("0", rgb.junk, 4, -4) -- Grey   / Junk
   w.bar[1] = make_bar("1", rgb.normal)      -- White  / Normal
   w.bar[2] = make_bar("2", rgb.fine)        -- Green  / Fine
   w.bar[3] = make_bar("3", rgb.superior)    -- Blue   / Superior
   w.bar[4] = make_bar("4", rgb.epic)        -- Purple / Epic
   w.bar[5] = make_bar("5", rgb.legendary)   -- Yellow / Legendary
end

local rgb = SF.rgb
-- esoui/art/icons/mapkey/mapkey_darkbrotherhood.dds
-- esoui/art/floatingmarkers/darkbrotherhood_target.dds
-- esoui/art/loot/loot_finesseitem.dds
-- esoui/art/icons/item_generic_coinbag.dds
-- esoui/art/icons/item_generic_coinbag_empty.dds
-- esoui/art/tooltips/icon_bag.dds

local controls = {
   {"Kill",        0,   8, " ",       "/esoui/art/floatingmarkers/darkbrotherhood_target.dds",
				rgb.red},		--kill innocents icon
   {"Loot",        10,  4, " ",        "/esoui/art/icons/item_generic_coinbag.dds", 
				rgb.bronze},		--autoloot icon
   {"Value",       10,  8, "00000",    "/esoui/art/tutorial/guildstore_sell_tabicon_up.dds", 
				rgb.gold},
   {"SellsLeft",   10,  4, "000/000",  "/esoui/art/inventory/inventory_stolenitem_icon.dds",
				rgb.purple},
   {"LaundersLeft",10,  4, "000/000",  "/esoui/art/vendor/vendor_tabicon_sell_down.dds",
				rgb.red},
   {"FenceTimer",  10,  4, "00:00",    "/esoui/art/miscellaneous/gamepad/gp_icon_timer32.dds",
				rgb.bronze},
   {"BountyTimer", 10,  4, "00:00",    "/esoui/art/miscellaneous/gamepad/gp_icon_timer32.dds",
				rgb.red},
   {"Bounty",      10,  8, "000",      "/esoui/art/currency/currency_gold.dds", 
				rgb.red},
   {"ClemencyTimer",10, 4, "00:00",    "/esoui/art/miscellaneous/gamepad/gp_icon_timer32.dds",
				rgb.fine},
   {"Average",     10,  6, "000.00",   "/esoui/art/crafting/smithing_tabicon_improve_up.dds",
				rgb.superior},
   {"Estimate",    10,  6, "00000",    "/esoui/art/vendor/vendor_tabicon_sell_down.dds",
				rgb.legendary},
   {"Quality",     10,  8, "0.00",     "/esoui/art/crafting/smithing_tabicon_improve_up.dds",
				rgb.normal},
}

-- set the color for the autoloot icon
local function colorAutoLootIcon()
	local autoLootLine = controls[2]
	if TT.options.chartt.autoSteal then  -- TT autoSteal
		autoLootLine[6] = rgb.bronze

	elseif TTFAS_isEnabled and TTFAS_isEnabled() then
		autoLootLine[6] = rgb.superior

	else
		autoLootLine[6] = rgb.junk
	end
end

local function shouldShowAutoSteal()
	-- control 2 - Auto Steal (Loot)
	if TT.options.chartt.autoSteal then
		TT.dshow.Loot = true

	elseif TTFAS_isEnabled and TTFAS_isEnabled() then
		TT.dshow.Loot = true

	else
		TT.dshow.Loot = false
	end
	colorAutoLootIcon()
end

local InventoryScene = SCENE_MANAGER.scenes.inventory
InventoryScene:RegisterCallback("StateChange", function(oldState, newState)
    -- states: hiding, showing, shown, hidden
    if( newState == "showing" ) then
        -- disable autojunking for now
        TT.tempDisableJunking = true

    elseif( newState == "hiding" ) then
        -- reenable autojunking
        TT.tempDisableJunking = false
    end
end)

function TT:ToggleSafeInnocents()
    local mood = { ["aggressive"] = "0", ["passive"] = "1" }
	local safeInnocents = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS)
	if (safeInnocents == mood.aggressive) then
		SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS, mood.passive)
        TT.ShowMessage(TT_SAFE_INNOCENTS,TT.options.warns.message_dest)
		TT.dshow["Kill"] = false

	else
		SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS, mood.aggressive)
        TT.ShowMessage(TT_UNSAFE_INNOCENTS, message_dest)
		TT.dshow["Kill"] = true
	end
	TT:UpdateDisplay()
	TT:UpdateControls()
end

function TT:GetAutoSteal()
	return TT.options.chartt.autoSteal or false
end

function TT.DisableAutoSteal()
	local chartt = TT.options.chartt
	if chartt.autoSteal == nil then
		dbg("TT.DisableAutoSteal: autoSteal was nil - setting to false")
		chartt.autoSteal = false
	end
	local grabby = { ["look"] = "0", ["take"] = "1" }
	local isAutoLootEnabled = GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN)
	if chartt.autoSteal then
		dbg("TT.DisableAutoSteal: autoSteal was true - setting to false")
		chartt.autoSteal = false
		shouldShowAutoSteal()
		if isAutoLootEnabled == grabby.take then
			SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, grabby.look)
		end
		TT.ShowMessage(TT_AUTOSTEAL_OFF, message_dest)
	end
	dbg("TT.DisableAutoSteal: updating display and controls")
	TT:UpdateDisplay()
	TT:UpdateControls()
end

function TT.EnableAutoSteal()
	if TT.options.chartt.autoSteal == nil then
		dbg("TT.EnableAutoSteal: autoSteal was nil - setting to false")
		TT.options.chartt.autoSteal = false
	end
	local grabby = { ["look"] = "0", ["take"] = "1" }
	local isAutoLootEnabled = GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN)
	if TT.options.chartt.autoSteal == false then
		dbg("TT.EnableAutoSteal: autoSteal was false - setting to true")
		TT.options.chartt.autoSteal = true
		shouldShowAutoSteal()
		TT.ShowMessage(TT_AUTOSTEAL_ON, message_dest)
		if GetUnitStealthState("player") == STEALTH_STATE_NONE then
			SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, grabby.look)

		else
			SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, grabby.take)
		end
	end
	dbg("TT.EnableAutoSteal: updating display and controls")
	TT:UpdateDisplay()
	TT:UpdateControls()
end

function TT:ToggleAutoSteal()
	if TT.options.chartt.autoSteal == nil then
		dbg("TT:ToggleAutoSteal: autoSteal was nil - setting to false")
		TT.options.chartt.autoSteal = false
	end
	local grabby = { ["look"] = "0", ["take"] = "1" }
	if TT.options.chartt.autoSteal == true then
		dbg("TT:ToggleAutoSteal: autoSteal was true - setting to false")
		TT.options.chartt.autoSteal = false
		TT.dshow.Loot = false
		if isAutoLootEnabled == grabby.take then
			SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, grabby.look)
		end
		TT.ShowMessage(L(TT_AUTOSTEAL_OFF), message_dest)

	else
		dbg("TT:ToggleAutoSteal: autoSteal - setting to true")
		TT.options.chartt.autoSteal = true
		TT.dshow.Loot = true
		TT.ShowMessage(TT_AUTOSTEAL_ON, message_dest)
		if GetUnitStealthState("player") == STEALTH_STATE_NONE then
			SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, grabby.look)

		else
			SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, grabby.take)
		end
	end
	dbg("TT:ToggleAutoSteal: updating display and controls")
	TT:UpdateDisplay()
	TT:UpdateControls()
end

function TT:toggleAutoJunk()
    if TT.options.chartt.enableJunking then
        TT.options.chartt.enableJunking = false
        TT.ShowMessage(TT_AUTOJUNK_OFF,1)

    else
        TT.options.chartt.enableJunking = true
        TT.ShowMessage(TT_AUTOJUNK_ON,1)
    end
end


--[[
    Update our Thief Status Bar
]]
function TT:UpdateControls()
	local win = TT.window
	if not win then return end
	--dbg("calling UpdateControls")
	local last

	-- control 1 - Attack Innocents (Kill)
	do
		local mood = { ["aggressive"] = "0", ["passive"] = "1" }
		local safeInnocents = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS)
		if( safeInnocents == mood.aggressive ) then
			TT.dshow.Kill = true

		else
			TT.dshow.Kill = false
		end
	end

	-- control 2 - Auto Steal (Loot)
	shouldShowAutoSteal()

	local name, icon, label
    for i,v in ipairs(controls) do
        name = string.lower(v[1])
		dbg("updating control "..name)
        icon = win["icon_"..name]
        label = win["l_"..name]

		--dbg("updating control "..name)
		--dbg("options.dshow["..v[1].."]="..SF.bool2str(TT.options.dshow[v[1]]))
		--dbg("dshow["..v[1].."]="..SF.bool2str(TT.dshow[v[1]]))
		--dbg("options.show["..v[1].."]="..SF.bool2str(TT.options.show[v[1]]))

        if(not TT.options.dshow[v[1]] and TT.options.show[v[1]]) or
                (TT.options.dshow[v[1]] and TT.dshow[v[1]] and TT.options.show[v[1]]) then
			--d("option 1")
            label:SetParent(win.bg)
            label:ClearAnchors()

			if icon then
				icon:SetParent(win.bg)
				icon:ClearAnchors()
			end

		    -- controls 3 -  #controls
            local text = ""
            if i > 2 then
				text = label:GetText()
				label:SetText(v[4])

            else
				label:SetText(" ")
			end

			label:SetDimensionConstraints((label:GetTextWidth() * 
						math.min(1.0,TT.options.display.scale)) + 8, 
					0, 0, 0)
			label:SetText(text)

			label:SetDimensionConstraints(0,0,0,0)
			label:SetWidth(0)

			if icon then
				if v[6] then
					icon:SetColor(SF_Color.UnpackRGBA(v[6]))
				end

				if last then
					icon:SetAnchor(LEFT, last, RIGHT, v[2]*TT.options.display.scale, 0)

				else
					icon:SetAnchor(LEFT, win.bg, LEFT, TT.options.display.border, 0)
				end
			end
			label:SetAnchor(LEFT, icon, RIGHT, v[3], 0)
			last = label

		else
			--dbg("do not show (nil)")
			if icon then icon:SetParent(nil) end
			label:SetParent(nil)
		end
	end

	-- quality bars
    if(TT.options.show.QualityBars == true) then
        for i = 0,5 do
            win.bar[i]:SetParent(win.bg)
        end

        win.bar[0]:ClearAnchors()
        win.bar[0]:SetAnchor(BOTTOMLEFT, last, BOTTOMRIGHT,
                8*TT.options.display.scale/2, -4*TT.options.display.scale)
    else
        for i = 0,5 do
            win.bar[i]:SetParent(nil)
        end
    end

	-- background
    if(TT.options.show.Background == true) then
        win.bg:SetCenterColor(0, 0, 0, 1)
        win.bg:SetEdgeColor(0, 0, 0, 1)

    else
        win.bg:SetCenterColor(0, 0, 0, 0)
        win.bg:SetEdgeColor(0, 0, 0, 0)
    end

end

-- handler for EVENT_RETICLE_HIDDEN_UPDATE
local function onReticleHidden()
	TT:UpdateControls()
end

function TT.RegisterEvents()
	evtmgr:registerEvt(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, onSlotUpdate)
	evtmgr:filterEvt(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
	evtmgr:filterEvt(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

	evtmgr:registerEvt(EVENT_LOOT_RECEIVED, onLoot)
	evtmgr:registerEvt(EVENT_ITEM_LAUNDER_RESULT, onLaunder)
	evtmgr:registerEvt(EVENT_JUSTICE_STOLEN_ITEMS_REMOVED, onApprehended)
	evtmgr:registerEvt(EVENT_OPEN_FENCE, function(evc) onFence(true) end)
	evtmgr:registerEvt(EVENT_CLOSE_STORE, function(evc) onFence(false) end)
	evtmgr:registerEvt(EVENT_SELL_RECEIPT, onSold)

	evtmgr:registerEvt(EVENT_ACTION_LAYER_PUSHED, onLayerChange)
	evtmgr:registerEvt(EVENT_ACTION_LAYER_POPPED, onLayerChange)

    evtmgr:registerEvt(EVENT_JUSTICE_BOUNTY_PAYOFF_AMOUNT_UPDATED, onBountyChange)
	evtmgr:registerEvt(EVENT_RETICLE_HIDDEN_UPDATE, onReticleHidden)

	evtmgr:registerEvt(EVENT_STEALTH_STATE_CHANGED, onStealthChanged)
	evtmgr:filterEvt(EVENT_STEALTH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    SHARED_INVENTORY:RegisterCallback("SlotRemoved", onRemoved)
end

function TT.UnregisterEvents()
	evtmgr:unregAllEvt()
    SHARED_INVENTORY:UnregisterCallback("SlotRemoved", onRemoved)
end

-- Build ThiefTools Bar
function TT:BuildUI()
    local w = WM:CreateTopLevelWindow(unqx())
    local border = TT.options.display.border
    local a = TOPLEFT

   -- Toplevel
   local shouldhide = TT.options.display.hidden
    if( TT.options.chartt.not_thief == true ) then
        shouldhide = true
    end
	w:SetHidden(shouldhide)
    w:SetMovable(true)
    w:SetMouseEnabled(true)
    w:SetClampedToScreen(true)
    w:SetClampedToScreenInsets(4, 4, -4, -4)
    w:SetAnchor(a, GuiRoot, a, TT.options.display.offsetx, TT.options.display.offsety)
    w:SetHandler("OnMoveStop", TT.SavePosition)

    w:SetResizeToFitDescendents(true)
    TT.window = w

    -- Background
    w.bg = WM:CreateControl(unqx("BG"), w, CT_BACKDROP)
    w.bg:SetEdgeTexture("/esoui/art/chatwindow/chat_bg_edge.dds", 256, 256, border)
    w.bg:SetCenterTexture("/esoui/art/chatwindow/chat_bg_center.dds")
    w.bg:SetInsets(border, border, -border, -border)
    w.bg:SetAnchor(BOTTOMLEFT, w, BOTTOMLEFT, 0, 0)
    w.bg:SetResizeToFitDescendents(true)
    w.bg:SetResizeToFitPadding(border*2, border)

   -- Controls
   dbg("BuildUI - making controls")
   local last
   for _, v in ipairs(controls) do
      last = make_control(v[1], last, v[2], v[3], v[4], v[5])
   end
   make_bars(last)
   clemencyCheck()
   TT:CalcStolenGoods()
   TT:UpdateControls()
   TT:UpdateDisplay()
   w:SetScale(TT.options.display.scale)

   TT.RegisterEvents()

   setupTimer()
   TT:lockWindow()
end

function TT:TimeToFenceReset(t)
   -- Seems to reset at 3am utc
   local fence_start = 10800

   t = SF.nilDefault(t, GetTimeStamp())

   local one_day = (24*60*60)
   local d = one_day - ((t - fence_start) % one_day)

   local timestr = fmt_time(d)
   return timestr, d
end

-- Things to do when zone changes...
local function onPlayerActivated()
	--local shouldhideZone = false
    --local tw = SCENE_MANAGER:GetCurrentScene():GetName()
	--if IsPlayerInAvAWorld() or IsActiveWorldBattleground() or tw == "Infinite Archive" or (tw ~= "hudui"  and tw ~= "hud" and TT.options.display.hide_on_menu == true) then
	--	shouldhideZone = true
	--end
	
	TT:UpdateDisplay()
end

local function onPlayerActivatedOnce()
    evtmgr:unregEvt(EVENT_PLAYER_ACTIVATED)
    TT.set_handlers(TT.options.filter)

    TT:BuildUI()
    TT:checkFreeSlotsWarning(BAG_BACKPACK)
    TT:checkFenceSlotsWarning(BAG_BACKPACK)
	evtmgr:registerEvt(EVENT_PLAYER_ACTIVATED, onPlayerActivated)
end

local function onLoaded(ev, addon)
    if(addon ~= TT.name) then return end
    evtmgr:unregEvt(EVENT_ADD_ON_LOADED)

    TT.savedAW = ZO_SavedVars:NewAccountWide("ThiefToolsVars", 3, GetWorldName(), TT.DefaultAW)
    TT.savedC = ZO_SavedVars:New("ThiefToolsVars", 3, GetWorldName(), TT.DefaultC)
    TT.setOptionsScope()
    TT:RegisterSettings()
	evtmgr:registerEvt(EVENT_PLAYER_ACTIVATED, onPlayerActivatedOnce)
end

evtmgr:registerEvt(EVENT_ADD_ON_LOADED, onLoaded)

local function slashHelp()
	if TTmsg == nil then return end
    local cmdtable = {
        {"/thieftools", "Print this help message"},
        {"/tt", 		TT_CHAT_CMD_TOGGLE},
        {"/tt.lock" , 	TT_CHAT_CMD_LOCK_BAR_POSITION},
        {"/tt.meter", 	TT_CHAT_CMD_METER},
        {"/tt.fencetime", TT_CHAT_CMD_FENCETIME},
        {"/tt.update", 	TT_CHAT_CMD_RECALC},
        {"/tt.counts", 	TT_CHAT_CMD_COUNTS},
        {"/tt.safe", 	TT_CHAT_CMD_SAFE},
        {"/tt.as", 		TT_CHAT_CMD_AUTOSTEAL},
        {"/tt.fas", 	TT_CHAT_CMD_TTFAS},
        {"/tt.junk", 	TT_CHAT_CMD_AUTOJUNK},
        {"/tt.stop", 	TT_CHAT_CMD_STOP},
    }
    local title = L(TT_CHAT_THIEFTOOLS_COMMANDS)
    TTmsg:slashHelp(title, cmdtable)
end

SLASH_COMMANDS["/thieftools"] = function()
	local sysmsg = function (cmd, desc)
		cmd = SF.ColorText(cmd, SF.hex.teal)
		if( type(desc) == "number" ) then
			desc = L(desc)
		end
		desc = SF.ColorText(" = "..SF.str(desc), TTmsg.normalcolor)
		local msg = SF.dstr( " ", TTmsg.prefix, cmd, desc )
		ZOS_addSystemMsg(msg);
	end

    if tempHideBar == true then
        TTmsg:systemMessage(L(TT_CHAT_NOT_RUNNING))
        TTmsg:systemMessage(L(TT_CHAT_THIEFTOOLS_COMMANDS))
        sysmsg("/tt.start", TT_CHAT_CMD_START)
		
    else
        slashHelp()
    end
end

SLASH_COMMANDS["/tt"] = function()
    if tempHideBar == true then TTmsg:systemMessage(L(TT_CHAT_NOT_RUNNING));return end
	local win = TT.window

   if(win:IsHidden()) then
		TT:CalcStolenGoods()
		TT:UpdateDisplay()
		TT:UpdateControls()
   end

   TT.options.display.hidden = not win:IsHidden()
   win:SetHidden(TT.options.display.hidden)
end

SLASH_COMMANDS["/tt.lock"] = function()
    if tempHideBar == true then TTmsg:systemMessage(L(TT_CHAT_NOT_RUNNING));return end

    local lockwin = TT.options.display.locked
    if(lockwin == true) then
        TT.window:SetMovable(true)
        TT.options.display.locked = false
        TTmsg:systemMessage(L(TT_MSG_UNLOCKED))
        TT.SavePosition()

    else
        TT.window:SetMovable(false)
        TT.options.display.locked = true
        TTmsg:systemMessage(L(TT_MSG_LOCKED))
        TT.SavePosition()
    end
end

SLASH_COMMANDS["/tt.meter"] = function()
    if tempHideBar == true then TTmsg:systemMessage(L(TT_CHAT_NOT_RUNNING));return end

    if(TT.options.display.hideMeter == true) then
        ZO_HUDInfamyMeter:SetHidden(false)
        TT.options.display.hideMeter = false
		
    else
        ZO_HUDInfamyMeter:SetHidden(true)
        TT.options.display.hideMeter = true
    end
end

SLASH_COMMANDS["/tt.resetbar"] = function()
    --if tempHideBar == true then TTmsg:systemMessage(L(TT_CHAT_NOT_RUNNING));return end
	local win = TT.window

	TT.options.chartt.not_thief = false
	ZO_HUDInfamyMeter:SetHidden(true)
	TT.options.display.hideMeter = true
	win:SetMovable(true)
	TT.options.display.locked = false
	TT.options.display.hidden = false

	win:SetHidden(false)
	TT:ResetPosition()
	TT.SavePosition()
    win:SetMovable(true)
    win:SetMouseEnabled(true)
    win:SetClampedToScreen(true)
    win:SetClampedToScreenInsets(4, 4, -4, -4)
    win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, 0)
end


SLASH_COMMANDS["/tt.fencetime"] = function()
    if tempHideBar == true then TTmsg:systemMessage(L(TT_CHAT_NOT_RUNNING));return end

   local str = TT:TimeToFenceReset()
   TTmsg:systemMessage("Fence will reset in", str)
end

-- --------------------------------------------------------
local rescan = function()
    if tempHideBar == true then 
		TTmsg:systemMessage(L(TT_CHAT_NOT_RUNNING))
		return
	end

    TT.set_handlers(TT.options.filter)
	TTmsg:systemMessage(L(TT_CHAT_CMD_RECALC_ACK))
	TT.delaying = false
	TT:CalcStolenGoods()
	--TTmsg:debugMsg("EQUIP_TYPE_RING=",EQUIP_TYPE_RING)
	--TTmsg:debugMsg("EQUIP_TYPE_NECK=",EQUIP_TYPE_NECK)
end

SLASH_COMMANDS["/tt.rescan"] = rescan
SLASH_COMMANDS["/tt.update"] = rescan

-- --------------------------------------------------------
local statcounter = function()
    if tempHideBar == true then 
		TTmsg:systemMessage(L(TT_CHAT_NOT_RUNNING))
		return
	end

    TTmsg:systemMessage(L(TT_STATS_RECIPES), TT.recipeCount)
    TTmsg:systemMessage(L(TT_STATS_MOTIFS), TT.motifCount)
    TTmsg:systemMessage(L(TT_STATS_FURNITURE), TT.furnitureCount)
    TTmsg:systemMessage(L(TT_STATS_FENCE), TT.fenceCount)
    TTmsg:systemMessage(L(TT_STATS_LAUNDER), TT.launderCount)
end

SLASH_COMMANDS["/tt.count"] = statcounter
SLASH_COMMANDS["/tt.counts"] = statcounter

-- --------------------------------------------------------

SLASH_COMMANDS["/tt.safe"] = function()
    if tempHideBar == true then TTmsg:systemMessage(L(TT_CHAT_NOT_RUNNING));return end
    TT.ToggleSafeInnocents()
end
SLASH_COMMANDS["/tt.tm"] = SLASH_COMMANDS["/tt.safe"]

-- --------------------------------------------------------
SLASH_COMMANDS["/tt.as"] = function()
    if tempHideBar == true then 
		TTmsg:systemMessage(L(TT_CHAT_NOT_RUNNING))
		return 
	end
	local autoSteal = ThiefTools.options.chartt.autoSteal
	if autoSteal == true then
		TT.DisableAutoSteal()

	else
		TT.EnableAutoSteal()
	end
end

SLASH_COMMANDS["/tt.fas"] = function()
    if tempHideBar == true then 
		TTmsg:systemMessage(L(TT_CHAT_NOT_RUNNING))
		return
	end
	local autoSteal = ThiefTools.options.chartt.autoSteal

	if not TTFAS then
		TTmsg:systemMessage(L(TT_CHAT_TTFAS_NOT_AVAIL))
		return
	end
	if autoSteal == true then
		TT.DisableAutoSteal()
	end
	if not TTFAS_isEnabled() then
		TTFAS_Enable()
		TTmsg:systemMessage(L(TT_TTFAS_ON))

	else
		TTFAS_Disable() -- this also runs TT.DisableAutoSteal
		TTmsg:systemMessage(L(TT_TTFAS_OFF))
	end
end

-- --------------------------------------------------------
SLASH_COMMANDS["/tt.junk"] = function()
    if tempHideBar == true then TTmsg:systemMessage(L(TT_CHAT_NOT_RUNNING));return end
    TT.toggleAutoJunk()
end

SLASH_COMMANDS["/tt.debug"] = function()
    if tempHideBar == true then TTmsg:systemMessage(L(TT_CHAT_NOT_RUNNING));return end
    slashToggleDebug()
end

SLASH_COMMANDS["/tt.stop"] = function()
    if not tempHideBar then
        TTmsg:systemMessage(L(TT_STOPPING))

		tempHideBar = true
        TT.window:SetHidden(true)
        TT.UnregisterEvents()

    else
        TTmsg:systemMessage(L(TT_ALREADY_STOPPED))
    end
end

SLASH_COMMANDS["/tt.start"] = function()
    if tempHideBar then
        TTmsg:systemMessage(L(TT_STARTING))
        tempHideBar = false
        onBountyChange(nil,0,0)
        TT:CalcStolenGoods()
        TT:UpdateDisplay()
        TT:UpdateControls()
        TT.RegisterEvents()

    else
        TTmsg:systemMessage(L(TT_ALREADY_RUNNING))
    end
end
