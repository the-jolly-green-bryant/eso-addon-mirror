-----------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY ASSISTANT
-----------------------------------------------------------------------------------------------------------------------------------
IA_InventoryAssistant         = ZO_Object:Subclass ( )
IA_InventoryAssistant.name    = "InventoryManager"
IA_InventoryAssistant.version = DsRVersion.version

IA_InventoryAssistant.ReScan    = false
-----------------------------------------------------------------------------------------------------------------------------------
-- DEFAULT SETTINGS
-----------------------------------------------------------------------------------------------------------------------------------
IA_InventoryAssistant.defaults = {
  inventoryAssistantWindowX = 480.0,
  inventoryAssistantWindowY = 110.0,
  inventoryAssistantWindowWidth = 625.0,
  inventoryAssistantWindowHeight = 865.0,
  characters = { },
  inventories = { 
    bank = { },
    chest = { },
  },
  actionQueue = { 
    lock = { },
    unlock = { },
  },
  onlyDuplicates = false,
  onlyMarkedItems = false,
  onlyLoots = false,
  showCrafted = true,
  showBuyable = true,
  showBound = true,
  showMonsterSets = true,
  showNonSetItems = true,
  showItemLevels = true,
  showEnchants = true,
  showTradPrice = true,
  showWinInv = true,
  InvOnOff = false,

  bagNameWidth = 250,
}
-----------------------------------------------------------------------------------------------------------------------------------
-- LOCAL FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------
local EH     = EVENT_MANAGER
local LAM    = LibAddonMenu2
local async  = LibAsync

local METRICS_ENABLED = false
local metrics = { }

local DsRIcon = DsRglobals:HolidayIconLoad()

local MenuOptions,MenuPanel,MenuHandlers={},{},{}
local Settings,SettingsGetFunc,SettingsSetFunc,SettingsDisabled={},{},{},{}

-------------------------------------------------------------------------------------------------------------------------------------------------
local function stopwatch_start ( info )
  if METRICS_ENABLED then 
    local start = metrics [ info ]
    if not start then 
      start = GetFrameTimeMilliseconds ( )
      metrics [ info ] = start
--      d ( string.format ( "%s...", info ) )
    end
  end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function stopwatch_stop ( info )
  if METRICS_ENABLED then 
    local start = metrics [ info ]
    if start then 
      local elapsed = GetGameTimeMilliseconds ( ) - start
      d ( string.format ( "%s : %d ms", info, elapsed ) )
      metrics [ info ] = nil 
    end
  end
end

-----------------------------------------------------------------------------------------------------------------------------------
-- converts unsigned itemId to signed, don't touch unique ids
local INT_MAX = 2^32
local SIGNED_INT_MAX = INT_MAX / 2 - 1
local function SignItemId ( itemId )
    if type ( itemId )  == "number" and itemId > SIGNED_INT_MAX then
        itemId = itemId - INT_MAX
    end
    return itemId
end

-----------------------------------------------------------------------------------------------------------------------------------
local function ScanBagSlot ( bagId, slotIndex, epoch, charId )
  local itemType         = GetItemType ( bagId, slotIndex )
  local bopTimeRemaining = GetItemBoPTimeRemainingSeconds ( bagId, slotIndex )
  local _, stackCount, _, _, _, equipType = GetItemInfo ( bagId, slotIndex )
  
  local link             = GetItemLink ( bagId, slotIndex )
  local isSetItem        = GetItemLinkSetInfo ( link )
  
  local typDescArt       = GetString ( "SI_ITEMTYPE", itemType ) or ""

  if itemType ~= ITEMTYPE_NONE then 
    local item = {
      charId      = charId,
      bagId       = bagId,
      typId       = zo_strformat(SI_TOOLTIP_ITEM_NAME, equipType),
      typDesc     = typDescArt,
      slotIndex   = slotIndex,
      itemId      = SignItemId ( GetItemInstanceId ( bagId, slotIndex ) ),
      uniqueId    = zo_getSafeId64Key ( GetItemUniqueId ( bagId, slotIndex ) ),
      link        = link,
      locked      = IsItemPlayerLocked ( bagId, slotIndex ),
      stolen      = IsItemStolen ( bagId, slotIndex ),
      bopTimeEnds = bopTimeRemaining > 0 and epoch + bopTimeRemaining or 0,
      stackCount  = stackCount,
    }
    return item
  end
end

-----------------------------------------------------------------------------------------------------------------------------------
local function ScanBag ( inventory, bagId, charId, actionQueue )
  local epoch = GetTimeStamp ( )

  if bagId >= BAG_HOUSE_BANK_ONE and bagId <= BAG_HOUSE_BANK_TEN and not IsOwnerOfCurrentHouse ( ) then return end 
  
    for slotIndex=0, GetBagSize ( bagId ), 1 do
      local item = ScanBagSlot ( bagId, slotIndex, epoch, charId )
      if item then 
        if actionQueue and actionQueue.lock [ item.uniqueId ] and item.bagId and item.slotIndex then
          SetItemIsPlayerLocked ( item.bagId, item.slotIndex, true )
          actionQueue.lock [ item.uniqueId ] = nil
          item.locked = true
        end
        if actionQueue and actionQueue.unlock [ item.uniqueId ] and item.bagId and item.slotIndex then
          SetItemIsPlayerLocked ( item.bagId, item.slotIndex, false )
          actionQueue.unlock [ item.uniqueId ] = nil
          item.locked = false
        end
        table.insert ( inventory, item )
      end
    end
end

-----------------------------------------------------------------------------------------------------------------------------------
-- This function is borrowed from Rhyono & votan's excellent EnchantedQuality addon
local subIdToQuality = { }
local function GetEnchantQuality ( itemLink )
	local itemId, itemIdSub, enchantSub = itemLink:match ( "|H[^:]+:item:([^:]+):([^:]+):[^:]+:[^:]+:([^:]+):" )
	if not itemId then return 0 end
	enchantSub = tonumber ( enchantSub )
	if enchantSub == 0 and not IsItemLinkCrafted ( itemLink ) then
		local hasSet = GetItemLinkSetInfo ( itemLink, false )
		-- For non-crafted sets, the "built-in" enchantment has the same quality as the item itself
		if hasSet then enchantSub = tonumber ( itemIdSub ) end
	end
	if enchantSub > 0 then
		local quality = subIdToQuality [ enchantSub ]
		if not quality then
			-- Create a fake itemLink to get the quality from built-in function
			local itemLink = string.format ( "|H1:item:%i:%i:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h", itemId, enchantSub )
			quality = GetItemLinkQuality ( itemLink )
			subIdToQuality [ enchantSub ] = quality
		end
		return quality
	end
	return 0
end
-----------------------------------------------------------------------------------------------------------------------------------
local getEnchantText = function ( itemLink )
  local _, text, _ = GetItemLinkEnchantInfo ( itemLink )
  return text
end
-- Armor Enchants
local ArmorEnchants = {
  [ getEnchantText ( "|H0:item:69893:369:50:26580:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h" ) ] = { text = GetString(DsRGuildInventory_Health),    icon = "/esoui/art/icons/enchantment_armor_healthboost.dds" },
  [ getEnchantText ( "|H0:item:69893:369:50:26582:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h" ) ] = { text = GetString(DsRGuildInventory_Magicka),   icon = "/esoui/art/icons/enchantment_armor_magickaboost.dds" },
  [ getEnchantText ( "|H0:item:69893:369:50:26588:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h" ) ] = { text = GetString(DsRGuildInventory_Stamina),   icon = "/esoui/art/icons/enchantment_armor_staminaboost.dds" },
  [ getEnchantText ( "|H0:item:69893:369:50:68343:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h" ) ] = { text = GetString(DsRGuildInventory_PrismaticDef), icon = "/esoui/art/icons/crafting_enchantment_036.dds" },
}
-- Weapon Enchants
local WeaponEnchants = {
  [ getEnchantText ( "|H0:item:69775:369:50:43573:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h" ) ] = { text = GetString(DsRGuildInventory_AbsorbHealth),  icon = "/esoui/art/icons/enchantment_weapon_healthabsorbtion.dds" },
  [ getEnchantText ( "|H0:item:69775:369:50:45868:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h" ) ] = { text = GetString(DsRGuildInventory_AbsorbMagicka), icon = "/esoui/art/icons/enchantment_weapon_magickaabsorbtion.dds" },
  [ getEnchantText ( "|H0:item:69775:369:50:45867:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h" ) ] = { text = GetString(DsRGuildInventory_AbsorbStamina), icon = "/esoui/art/icons/enchantment_weapon_staminaabsorption.dds" },
  [ getEnchantText ( "|H0:item:69775:369:50:26845:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h" ) ] = { text = GetString(DsRGuildInventory_Crushing),      icon = "/esoui/art/icons/enchantment_weapon_reducearmor.dds" },
  [ getEnchantText ( "|H0:item:69775:369:50:45869:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h" ) ] = { text = GetString(DsRGuildInventory_Oblivion),      icon = "/esoui/art/icons/enchantment_weapon_decreasehealth.dds" },
  [ getEnchantText ( "|H0:item:69775:369:50:26848:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h" ) ] = { text = GetString(DsRGuildInventory_Flame),         icon = "/esoui/art/icons/enchantment_weapon_fireessence.dds" },
  [ getEnchantText ( "|H0:item:69775:369:50:26841:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h" ) ] = { text = GetString(DsRGuildInventory_Disease),       icon = "/esoui/art/icons/enchantment_weapon_diseaseessence.dds" },
  [ getEnchantText ( "|H0:item:69775:369:50:5365:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h" )  ] = { text = GetString(DsRGuildInventory_Frost),         icon = "/esoui/art/icons/enchantment_weapon_frostessence.dds" },
  [ getEnchantText ( "|H0:item:69775:369:50:5366:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h" )  ] = { text = GetString(DsRGuildInventory_Hardening),     icon = "/esoui/art/icons/enchantment_weapon_damageshield.dds" },
  [ getEnchantText ( "|H0:item:69775:369:50:26587:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h" ) ] = { text = GetString(DsRGuildInventory_Poison),        icon = "/esoui/art/icons/enchantment_weapon_poisonessence.dds" },
  [ getEnchantText ( "|H0:item:69775:369:50:68344:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h" ) ] = { text = GetString(DsRGuildInventory_PrismaticWeapon), icon = "/esoui/art/icons/crafting_enchantment_035.dds" },
  [ getEnchantText ( "|H0:item:69775:369:50:26844:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h" ) ] = { text = GetString(DsRGuildInventory_Shock),         icon = "/esoui/art/icons/enchantment_weapon_shockessence.dds" },
  [ getEnchantText ( "|H0:item:69775:369:50:26591:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h" ) ] = { text = GetString(DsRGuildInventory_Weakening),     icon = "/esoui/art/icons/enchantment_weapon_weakeningenchant.dds" },
  [ getEnchantText ( "|H0:item:69775:369:50:54484:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h" ) ] = { text = GetString(DsRGuildInventory_WeaponDamage),  icon = "/esoui/art/icons/enchantment_weapon_berserking.dds" },
}
-- Jewelry Enchants
local JewelryEnchants = {
  [ getEnchantText ( "|H0:item:69276:363:50:45872:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" ) ] = { text = GetString(DsRGuildInventory_Bashing),              icon = "/esoui/art/icons/enchantment_jewelry_increasebashdamage.dds" },
  [ getEnchantText ( "|H0:item:69276:363:50:45885:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" ) ] = { text = GetString(DsRGuildInventory_DecreasePhysicalHarm), icon = "/esoui/art/icons/enchantment_jewelry_decreasephysicaldamage.dds" },
  [ getEnchantText ( "|H0:item:69276:363:50:45886:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" ) ] = { text = GetString(DsRGuildInventory_DecreaseSpellHarm),    icon = "/esoui/art/icons/enchantment_jewelry_decreasespelldamage.dds" },
  [ getEnchantText ( "|H0:item:69276:363:50:26847:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" ) ] = { text = GetString(DsRGuildInventory_DiseaseResist),        icon = "/esoui/art/icons/enchantment_jewelry_diseaseresist.dds" },
  [ getEnchantText ( "|H0:item:69276:363:50:26849:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" ) ] = { text = GetString(DsRGuildInventory_FlameResist),          icon = "/esoui/art/icons/enchantment_jewelry_fireresist.dds" },
  [ getEnchantText ( "|H0:item:69276:363:50:5364:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" )  ] = { text = GetString(DsRGuildInventory_FrostResist),          icon = "/esoui/art/icons/enchantment_jewelry_frostresist.dds" },
  [ getEnchantText ( "|H0:item:69276:363:50:26581:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" ) ] = { text = GetString(DsRGuildInventory_HealthRecovery),       icon = "/esoui/art/icons/enchantment_jewelry_healthregen.dds" },
  [ getEnchantText ( "|H0:item:69276:363:50:45884:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" ) ] = { text = GetString(DsRGuildInventory_SpellDamage),          icon = "/esoui/art/icons/enchantment_jewelry_increasespelldamage.dds" },
  [ getEnchantText ( "|H0:item:69276:363:50:45883:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" ) ] = { text = GetString(DsRGuildInventory_WeaponDamage),         icon = "/esoui/art/icons/enchantment_jewelry_increaseweapondamage.dds" },
  [ getEnchantText ( "|H0:item:69276:363:50:26583:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" ) ] = { text = GetString(DsRGuildInventory_MagickaRecovery),      icon = "/esoui/art/icons/enchantment_jewelry_magickaregen.dds" },
  [ getEnchantText ( "|H0:item:69276:363:50:26586:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" ) ] = { text = GetString(DsRGuildInventory_PoisonResist),         icon = "/esoui/art/icons/enchantment_jewelry_poisonresist.dds" },
  [ getEnchantText ( "|H0:item:69276:363:50:45874:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" ) ] = { text = GetString(DsRGuildInventory_PotionBoost),          icon = "/esoui/art/icons/enchantment_jewelry_potionpotency.dds" },
  [ getEnchantText ( "|H0:item:69276:363:50:45875:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" ) ] = { text = GetString(DsRGuildInventory_PotionSpeed),          icon = "/esoui/art/icons/enchantment_jewelry_increasepotionspeed.dds" },
  [ getEnchantText ( "|H0:item:69276:363:50:45871:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" ) ] = { text = GetString(DsRGuildInventory_ReduceStaminaCost),    icon = "/esoui/art/icons/enchantment_jewelry_reducefeatcosts.dds" },
  [ getEnchantText ( "|H0:item:69276:363:50:45870:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" ) ] = { text = GetString(DsRGuildInventory_ReduceSpellCost),      icon = "/esoui/art/icons/enchantment_jewelry_reducespellcosts.dds" },
  [ getEnchantText ( "|H0:item:69276:363:50:45873:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" ) ] = { text = GetString(DsRGuildInventory_ReduceBashCost),       icon = "/esoui/art/icons/enchantment_jewelry_decreasebashblockcost.dds" },
  [ getEnchantText ( "|H0:item:69276:363:50:43570:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" ) ] = { text = GetString(DsRGuildInventory_ShockResist),          icon = "/esoui/art/icons/enchantment_jewelry_shockresist.dds" },
  [ getEnchantText ( "|H0:item:69276:363:50:26589:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" ) ] = { text = GetString(DsRGuildInventory_StaminaRecovery),      icon = "/esoui/art/icons/enchantment_jewelry_staminaregen.dds" },
  [ getEnchantText ( "|H0:item:69276:363:50:166046:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" ) ] = { text = GetString(DsRGuildInventory_ReduceSkillCost),     icon = "/esoui/art/icons/crafting_u26_enchantment_038.dds" },
  [ getEnchantText ( "|H0:item:69276:363:50:166047:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" ) ] = { text = GetString(DsRGuildInventory_PrismaticRecovery),   icon = "/esoui/art/icons/crafting_u26_enchantment_037.dds" },
}
-----------------------------------------------------------------------------------------------------------------------------------
local sortOrderTable1 = {
  [EQUIP_TYPE_HEAD]              =  10,
  [EQUIP_TYPE_SHOULDERS]         =  20,
  [EQUIP_TYPE_CHEST]             =  30,
  [EQUIP_TYPE_LEGS]              =  40,
  [EQUIP_TYPE_WAIST]             =  50,
  [EQUIP_TYPE_HAND]              =  60,
  [EQUIP_TYPE_FEET]              =  70,
  [EQUIP_TYPE_NECK]              =  80,
  [EQUIP_TYPE_RING]              =  81,
}
local sortOrderTable2 = {
  [ARMORTYPE_LIGHT]              = 1,
  [ARMORTYPE_MEDIUM]             = 2,
  [ARMORTYPE_HEAVY]              = 3,
}
local sortOrderTable3 = {
  [WEAPONTYPE_FIRE_STAFF]        = 500,
  [WEAPONTYPE_LIGHTNING_STAFF]   = 501,
  [WEAPONTYPE_FROST_STAFF]       = 502,
  [WEAPONTYPE_HEALING_STAFF]     = 503,
  [WEAPONTYPE_BOW]               = 510,
  [WEAPONTYPE_AXE]               = 520,
  [WEAPONTYPE_HAMMER]            = 521,
  [WEAPONTYPE_SWORD]             = 522,
  [WEAPONTYPE_DAGGER]            = 523,
  [WEAPONTYPE_SHIELD]            = 530,
  [WEAPONTYPE_TWO_HANDED_AXE]    = 540,
  [WEAPONTYPE_TWO_HANDED_HAMMER] = 541,
  [WEAPONTYPE_TWO_HANDED_SWORD]  = 542,
}
-----------------------------------------------------------------------------------------------------------------------------------
local cache = { }
local function LoadInventory ( inventory, sets, materials, others )
  for i, v in ipairs ( inventory ) do
    local slot = cache [ v.uniqueId ]
    if not slot then
      slot = { }
      slot.itemId      = v.itemId
      slot.uniqueId    = v.uniqueId
      slot.link        = v.link
      slot.bopTimeEnds = v.bopTimeEnds
      slot.itemType, slot.specializedItemType           = GetItemLinkItemType ( slot.link )
      slot.icon, _, _, slot.equipType, slot.itemStyleId = GetItemLinkInfo ( slot.link )
      slot.quality     = GetItemLinkQuality ( slot.link )
      slot.name        = GetItemLinkName ( slot.link )
      
      slot.isSetItem, slot.setName, slot.numBonuses, slot.numEquipped, slot.maxEquipped, slot.setId = GetItemLinkSetInfo ( slot.link, false )
      slot.equipTypeName  = GetString ( "SI_EQUIPTYPE", slot.equipType ) or ""
      slot.traitType, _   = GetItemLinkTraitInfo ( slot.link )
      slot.traitTypeName  = GetString ( "SI_ITEMTRAITTYPE",slot.traitType ) or ""
      slot.armorType      = GetItemLinkArmorType ( slot.link )
      slot.armorTypeName  = GetString ( "SI_ARMORTYPE", slot.armorType ) or ""
      slot.weaponType     = GetItemLinkWeaponType ( slot.link )
      slot.weaponTypeName = GetString ( "SI_WEAPONTYPE", slot.weaponType ) or ""
      
      slot.requiredLevel          = GetItemLinkRequiredLevel ( slot.link )
      slot.requiredChampionPoints = GetItemLinkRequiredChampionPoints ( slot.link )
      
      slot.sortOrder = ( sortOrderTable1 [ slot.equipType ] or 0 ) + ( sortOrderTable2 [ slot.armorType ] or 0 ) + ( sortOrderTable3 [ slot.weaponType ] or 0 )
      
      if slot.itemType == ITEMTYPE_ARMOR and slot.equipType ~= EQUIP_TYPE_NECK and slot.equipType ~= EQUIP_TYPE_RING then
        slot.category    = "Armor"
        slot.subcategory = string.format( "%s %s", slot.armorTypeName, slot.equipTypeName )
      elseif slot.itemType == ITEMTYPE_ARMOR and ( slot.equipType == EQUIP_TYPE_NECK or slot.equipType == EQUIP_TYPE_RING ) then
        slot.category    = "Jewellery"
        slot.subcategory = slot.equipTypeName
      elseif slot.itemType == ITEMTYPE_WEAPON then
        slot.category    = "Weapon"
        slot.subcategory = string.format( "%s %s", slot.equipTypeName, slot.weaponTypeName )
      end
      slot.itemkey = string.format ( "%s:%s", slot.category or "", slot.subcategory or "")
      slot.setName = zo_strformat ( "<<1>>", slot.setName )
      if v.uniqueId then 
        cache [ v.uniqueId ] = slot
      end
    end
    slot.charId     = v.charId
    slot.bagId      = v.bagId
    slot.slotIndex  = v.slotIndex
    slot.locked     = v.locked
    slot.stackCount = v.stackCount
    slot.stolen     = v.stolen
    
    local enchant = ""
    if ( v.armorType ~= ARMORTYPE_NONE or v.weaponType ~= WEAPONTYPE_NONE or v.equipType == EQUIP_TYPE_RING or v.equipType == EQUIP_TYPE_NECK ) then
      local y = getEnchantText ( v.link )
      if y then 
        x = ArmorEnchants [ y ] or WeaponEnchants [ y ] or JewelryEnchants [ y ]
        if x then
          local r,g,b,a = GetInterfaceColor ( INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, GetEnchantQuality ( slot.link ) )
          enchant       = string.format( "  |c%02X%02X%02X(%s)|r", zo_floor ( r * 255) , zo_floor ( g * 255 ), zo_floor ( b * 255 ), x.text )
        end
      end
    end
    slot.enchant = enchant
   
    local prices 	     = DsRGuildPrice.GetPrices(v.link)

	  if prices.bestPrice ~= nil then
	  	TradingPrice = prices.bestPrice
	  elseif prices.originalMMPrice ~= nil then
	  	TradingPrice = prices.originalMMPrice
	  elseif prices.originalTTCPrice ~= nil then
	  	TradingPrice = prices.originalTTCPrice
	  elseif prices.originalATTPrice ~= nil then
	  	TradingPrice = prices.originalATTPrice
	  end

    if TradingPrice == nil then
      TradingPrice = 0
    end

    local _, sellPrice     = GetItemLinkInfo(v.link)

    if tonumber(TradingPrice) == 0 then
      TradingPrice = ZO_CommaDelimitNumber( zo_roundToNearest( sellPrice , 0.1 ) ):gsub("%,","%.")
    end
  
    TradingPrice = DsRGuildPrice_NumberFormat(TradingPrice)

    local tradeIcon     = [[/DsRGuildHall/misc/tradehammer.dds]]
    local tradeIconText = zo_iconTextFormat(tradeIcon, 20, 20, "")
    local colortrade    = "|cFFAE42"

    slot.Price = colortrade .. tradeIconText .. TradingPrice .. "g"

    if slot.isSetItem then 

      if not sets [ slot.setName ] then
        table.insert ( sets, slot.setName )
        sets [ slot.setName ] = { }
      end
      table.insert ( sets [ slot.setName ], slot )
      if not sets [ slot.setName ][ slot.itemkey ] then
        sets [ slot.setName ][ slot.itemkey ] = { }
      end
      table.insert ( sets [ slot.setName ] [ slot.itemkey ], slot )
    else
      local itemTypeText    = GetString ( "SI_ITEMTYPE", slot.itemType ) or ""
      local itemSubTypeText = GetString ( "SI_SPECIALIZEDITEMTYPE", slot.specializedItemType ) or ""
      local category        = "__UNKNOWN__"
      if ( itemTypeText == itemSubTypeText or itemSubTypeText == "" ) then
        category = itemTypeText
      else
        category = string.format ( "%s - %s", itemTypeText , itemSubTypeText )
      end
      if not others [ category ] then
        table.insert ( others, category )
        others [ category ] = { }
      end
      table.insert ( others [ category ], slot )
    end
  end
end
-----------------------------------------------------------------------------------------------------------------------------------
local function GetSetCount ( sets )
  sets = sets or { }
  return #sets
end
-----------------------------------------------------------------------------------------------------------------------------------
local function GetItemCount ( sets, allsets )
  sets = sets or { }
  allsets = allsets or { }
  local count = 0
  for i,v in ipairs ( sets ) do
    count = count + #allsets [ v ]
  end
  return count
end
-----------------------------------------------------------------------------------------------------------------------------------
local function GetEquipSlotData ( setitems )
  setitems = setitems or { }
  local head = 0
  local headIcon = "esoui/art/characterwindow/gearslot_head.dds"
  local shoulders = 0
  local shouldersIcon = "esoui/art/characterwindow/gearslot_shoulders.dds"
  local hands = 0
  local handsIcon = "esoui/art/characterwindow/gearslot_hands.dds"
  local legs = 0
  local legsIcon = "esoui/art/characterwindow/gearslot_legs.dds"
  local chest = 0
  local chestIcon  = "esoui/art/characterwindow/gearslot_chest.dds"
  local belt = 0
  local beltIcon = "esoui/art/characterwindow/gearslot_belt.dds"
  local feet = 0
  local feetIcon = "esoui/art/characterwindow/gearslot_feet.dds"
  local neck = 0
  local neckIcon  = "esoui/art/characterwindow/gearslot_neck.dds"
  local ring = 0
  local ringIcon = "esoui/art/characterwindow/gearslot_ring.dds"
  local mainHand = 0
  local mainHandIcon = "esoui/art/characterwindow/gearslot_mainhand.dds"
  local offHand = 0
  local offHandIcon = "esoui/art/characterwindow/gearslot_offhand.dds"
  for i, v in ipairs ( setitems ) do
    if type ( v.bagId ) == "number" then
      if v.equipType == EQUIP_TYPE_HEAD then
        head = head + 1
        headIcon = v.icon
      elseif v.equipType == EQUIP_TYPE_SHOULDERS then
        shoulders = shoulders + 1
        shouldersIcon = v.icon
      elseif v.equipType == EQUIP_TYPE_HAND then
        hands = hands + 1
        handsIcon = v.icon
      elseif v.equipType == EQUIP_TYPE_LEGS then
        legs = legs + 1
        legsIcon = v.icon
      elseif v.equipType == EQUIP_TYPE_CHEST then
        chest = chest + 1
        chestIcon = v.icon
      elseif v.equipType == EQUIP_TYPE_WAIST then
        belt = belt + 1
        beltIcon = v.icon
      elseif v.equipType == EQUIP_TYPE_FEET then
        feet = feet + 1
        feetIcon = v.icon
      elseif v.equipType == EQUIP_TYPE_NECK then
        neck = neck + 1
        neckIcon = v.icon
      elseif v.equipType == EQUIP_TYPE_RING then
        ring = ring + 1
        ringIcon = v.icon
      elseif v.equipType == EQUIP_TYPE_MAIN_HAND or v.equipType == EQUIP_TYPE_ONE_HAND or v.equipType == EQUIP_TYPE_TWO_HAND then
        mainHand = mainHand + 1
        mainHandIcon = v.icon
      elseif v.equipType == EQUIP_TYPE_OFF_HAND then
        offHand = offHand + 1
        offHandIcon = v.icon
      end
    end
  end
  return {
    head = head, headIcon = headIcon,
    shoulders = shoulders, shouldersIcon = shouldersIcon,
    hands = hands, handsIcon = handsIcon,
    legs = legs, legsIcon = legsIcon,
    chest = chest, chestIcon = chestIcon,
    belt = belt, beltIcon = beltIcon,
    feet = feet, feetIcon = feetIcon,
    neck = neck, neckIcon = neckIcon,
    ring = ring, ringIcon = ringIcon,
    mainHand = mainHand, mainHandIcon = mainHandIcon,
    offHand = offHand, offHandIcon = offHandIcon,
  }
end
-----------------------------------------------------------------------------------------------------------------------------------
local sortKeys = {
  setName       = { tiebreaker = "sortOrder" },
  sortOrder     = { tiebreaker = "quality", isNumeric = true },
  quality       = { tiebreaker = "traitTypeName" },
  traitTypeName = { tiebreaker = "name" },
  name          = { tiebreaker = "bagId" },
  bagId         = { },
}

local sortFunction = function( entry1, entry2 )
  return ZO_TableOrderingFunction ( entry1, entry2, "setName", sortKeys, ZO_SORT_ORDER_UP )
end
local sortKeys2 = {
  setName       = { tiebreaker = "quality" },
  quality       = { tiebreaker = "traitTypeName" },
  traitTypeName = { tiebreaker = "name" },
  name          = { tiebreaker = "bagId" },
  bagId         = { },
}
local sortFunction2 = function( entry1, entry2 )
  return ZO_TableOrderingFunction ( entry1, entry2, "setName", sortKeys2, ZO_SORT_ORDER_UP )
end
-----------------------------------------------------------------------------------------------------------------------------------
-- INITIALIZATION
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistant:New ( control )
  local inventoryAssistant = ZO_Object.New ( self )
  inventoryAssistant:Initialize ( control )
  return inventoryAssistant
end
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistant:Initialize ( control )
  EH:RegisterForEvent ( self.name, EVENT_ADD_ON_LOADED, function ( event, addonName )
    if addonName ~= "DsRGuildHall" then return end
      EH:UnregisterForEvent ( self.name, EVENT_ADD_ON_LOADED )
      IA_InventoryAssistant.settings = ZO_SavedVars:NewAccountWide("DsRGuildInventorySettings", 1, nil, self.defaults)
      IA_InventoryAssistant.async    = LibAsync:Create( self.name ) 
         
      IA_InventoryAssistant.onlyDuplicates     = IA_InventoryAssistant.settings.onlyDuplicates
      IA_InventoryAssistant.onlyMarkedItems    = IA_InventoryAssistant.settings.onlyMarkedItems
      IA_InventoryAssistant.onlyLoots          = IA_InventoryAssistant.settings.onlyLoots
      IA_InventoryAssistant.showCrafted        = IA_InventoryAssistant.settings.showCrafted
      IA_InventoryAssistant.showBuyable        = IA_InventoryAssistant.settings.showBuyable
      IA_InventoryAssistant.showBound          = IA_InventoryAssistant.settings.showBound
      IA_InventoryAssistant.showMonsterSets    = IA_InventoryAssistant.settings.showMonsterSets
      IA_InventoryAssistant.showNonSetItems    = IA_InventoryAssistant.settings.showNonSetItems
      IA_InventoryAssistant.showItemLevels     = IA_InventoryAssistant.settings.showItemLevels
      IA_InventoryAssistant.showEnchants       = IA_InventoryAssistant.settings.showEnchants
      IA_InventoryAssistant.showTradPrice      = IA_InventoryAssistant.settings.showTradPrice
      
      IA_InventoryAssistant.onlyCP160    = false
      IA_InventoryAssistant.onlyNonCP160 = false

      EH:RegisterForEvent ( self.name, EVENT_PLAYER_ACTIVATED, function ( ... ) self:Rescan ( ... ) end )
      EH:RegisterForEvent ( self.name, EVENT_PLAYER_DEACTIVATED, function ( ... ) self:Rescan ( ... ) end )

      if IA_InventoryAssistant.settings.InvOnOff then return end

      self:InitializeWindow ( control )
      self:InitializeHooks ( control )
  end )
end
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistant:InitializeWindow ( control )
  IA_InventoryAssistant.window = control

  IA_InventoryAssistant.window:SetHidden( true )
  IA_InventoryAssistant.window:SetAnchor ( TOPLEFT, GuiRoot, TOPLEFT, IA_InventoryAssistant.settings.inventoryAssistantWindowX, IA_InventoryAssistant.settings.inventoryAssistantWindowY )
  IA_InventoryAssistant.window:SetDimensions ( IA_InventoryAssistant.settings.inventoryAssistantWindowWidth, IA_InventoryAssistant.settings.inventoryAssistantWindowHeight )
  
  IA_InventoryAssistant.list = IA_InventoryAssistantList:New ( IA_InventoryAssistant.window, IA_InventoryAssistant.window:GetNamedChild ( "WindowCanvas" ) )
  IA_InventoryAssistant.searchbox = IA_InventoryAssistant.window:GetNamedChild ( "WindowCanvasSearchBox" )
  IA_InventoryAssistant.searchbox:SetHandler ( "OnTextChanged", function ( ) 
    if not IA_InventoryAssistant.window:IsControlHidden ( ) then
      self:Refresh ( false ) 
    end      
  end )
  IA_InventoryAssistant.searchbox:SetHandler ( "OnEnter", function ( )
    if not IA_InventoryAssistant.window:IsControlHidden ( ) then
      self:Refresh ( false ) 
    end      
  end )
  IA_InventoryAssistant.searchbox:SetHandler ( "OnEscape", function ( ) 
      if IA_InventoryAssistant.searchbox:GetText ( ) ~= "" then
        IA_InventoryAssistant.searchbox:SetText ( "" )
      else
        self:ToggleWindow ( )
      end
  end )
  IA_InventoryAssistant.searchbox:SetHandler ( "OnTab", function ( ) 
        self:ToggleWindow ( )
  end )
  IA_InventoryAssistant.search = ZO_StringSearch:New ( )

  IA_InventoryAssistant.window:SetHandler ( "OnMoveStop", function ( )
      IA_InventoryAssistant.settings.inventoryAssistantWindowX = IA_InventoryAssistant.window:GetLeft ( )
      IA_InventoryAssistant.settings.inventoryAssistantWindowY = IA_InventoryAssistant.window:GetTop ( )
  end )

  IA_InventoryAssistant.window:SetHandler ( "OnResizeStop", function ( )
      IA_InventoryAssistant.settings.inventoryAssistantWindowWidth = IA_InventoryAssistant.window:GetWidth ( )
      IA_InventoryAssistant.settings.inventoryAssistantWindowHeight = IA_InventoryAssistant.window:GetHeight ( )
  end )

  local dropdownPlace = WINDOW_MANAGER:CreateControlFromVirtual("IA_MainPlaceDropdown", IA_MainWindow, "ZO_ScrollableComboBox")
  dropdownPlace:SetAnchor(TOP, IA_MainWindow, TOPRIGHT, -170, -3)
  dropdownPlace:SetWidth(150)

  local comboBoxPlace = ZO_ComboBox_ObjectFromContainer(dropdownPlace)
  comboBoxPlace:SetSortsItems(false)
  comboBoxPlace:SetHeight(400)

  local dropdownArt = WINDOW_MANAGER:CreateControlFromVirtual("IA_MainArtDropdown", IA_MainWindow, "ZO_ScrollableComboBox")
  dropdownArt:SetAnchor(TOP, IA_MainWindow, TOPRIGHT, -320, -3)
  dropdownArt:SetWidth(150)

  local comboBoxArt = ZO_ComboBox_ObjectFromContainer(dropdownArt)
  comboBoxArt:SetSortsItems(false)
  comboBoxArt:SetHeight(400)

  local function AddDropdownItem(comboBoxPlace, text)
    local entry = comboBoxPlace:CreateItemEntry(text:sub ( 5 ), function() IA_InventoryAssistant:FilterList( text ) end)
    comboBoxPlace:AddItem(entry)
  end

  local function AddDropdownItem(comboBoxArt, text)
    local entry = comboBoxArt:CreateItemEntry(text:sub ( 5 ), function() IA_InventoryAssistant:FilterList( text ) end)
    comboBoxArt:AddItem(entry)
  end

  local optionsCHAR = IA_InventoryAssistant.settings.characters
  if optionsCHAR == nil then
  else
    AddDropdownItem(comboBoxPlace, "ALL-|cFFAE42ALL|r")
    AddDropdownItem(comboBoxPlace, GetString(DsRGuildInventory_FilterChar))
    for _, option in pairs(optionsCHAR) do
      AddDropdownItem(comboBoxPlace, "CHA-" .. option)
    end
  end

  AddDropdownItem(comboBoxPlace, GetString(DsRGuildInventory_FilterChest))
  local PlaceCHEST = IA_InventoryAssistant.settings.chest
  if PlaceCHEST == nil then
  else 
    for _, option in pairs(PlaceCHEST) do
      AddDropdownItem(comboBoxPlace, "CHE-" .. option)
    end
  end

  AddDropdownItem(comboBoxPlace, "ABA-|c9fb6cd-- Bank --|r")
  AddDropdownItem(comboBoxPlace, "BAN-Bank")
  comboBoxPlace:SetSelectedItem("|cFFAE42ALL|r")

  AddDropdownItem(comboBoxArt, "ALL-|cFFAE42ALL|r")
  local tableConSort = {}
  local hash         = {}
  local CleanTable   = {}

  for k, v in pairs ( IA_InventoryAssistant.settings.characters ) do
    if k == nil then
      for i, a in pairs ( IA_InventoryAssistant.settings.inventories[ k ] ) do
        local abc = IA_InventoryAssistant.settings.inventories[ k ][ i ].typDesc
        table.insert(tableConSort, abc)
      end
    end
  end
  for k, v in ipairs ( IA_InventoryAssistant.settings.inventories[ "bank" ] ) do
    local abc = IA_InventoryAssistant.settings.inventories[ "bank" ][ k ].typDesc
    table.insert(tableConSort, abc)
  end
  for k, v in ipairs ( IA_InventoryAssistant.settings.inventories[ "chest" ] ) do
    local abc = IA_InventoryAssistant.settings.inventories[ "chest" ][ k ].typDesc
    table.insert(tableConSort, abc)
  end
  for _, wert in ipairs(tableConSort) do
      if not hash[wert] then
          hash[wert] = true
          table.insert(CleanTable, wert)
      end
  end
  table.sort(CleanTable)
  for _, wert in ipairs(CleanTable) do
    local NEW = wert:gsub("%^.+-", "")
    AddDropdownItem(comboBoxArt, "ART-" .. NEW)
  end
  comboBoxArt:SetSelectedItem("|cFFAE42ALL|r")
  
  ReScanButton = CreateControl("IA_MainReScanButton", IA_MainWindow, CT_BUTTON)
  ReScanButton:SetDimensions(32, 32)
  ReScanButton:SetAnchor(TOP, IA_MainWindow, TOPRIGHT, -80, -5)
  ReScanButton:SetNormalTexture("/DsRGuildHall/misc/update_noneed.dds")
  ReScanButton:SetMouseOverTexture("esoui/art/lfg/lfg_groupfinder_refreshsearch_over.dds")
  ReScanButton:SetClickSound("Click")
  ReScanButton:SetHandler("OnClicked", function() 
    IA_InventoryAssistant:Refresh ( true )
    ReScanButton:SetNormalTexture("/DsRGuildHall/misc/update_noneed.dds")
    ReScanButton:SetMouseOverTexture("esoui/art/lfg/lfg_groupfinder_refreshsearch_over.dds")
  end)
  ReScanButton:SetHandler("OnMouseEnter", function() IA_InventoryAssistant.ShowToolTip(false) end)
  ReScanButton:SetHandler("OnMouseExit" , function() IA_InventoryAssistant.HideToolTip()      end)

  -- InventoryMenu open Window
  ZO_PreHookHandler(ZO_PlayerInventoryMenu, "OnShow", function()
    if IA_InventoryAssistant.settings.showWinInv == false then return end
    if IA_InventoryAssistant.ReScan == true then
      IA_InventoryAssistant.window:SetHidden( false )
      IA_InventoryAssistant:Refresh ( false )
    else
      IA_InventoryAssistant:ToggleWindow ( false )
    end
  end)
  ZO_PreHookHandler(ZO_PlayerInventoryMenu, "OnHide", function()
    IA_InventoryAssistant.window:SetHidden( true )
  end)

  ZO_PreHookHandler(ZO_InteractWindow, "OnShow", function()
    IA_InventoryAssistant.window:SetHidden( true )
  end)
  ZO_PreHookHandler(ZO_GameMenu_InGame, "OnShow", function()
    IA_InventoryAssistant.window:SetHidden( true )
  end)
  ZO_PreHookHandler(ZO_KeybindStripControl, "OnShow", function()
    IA_InventoryAssistant.window:SetHidden( true )
  end)
end

function IA_InventoryAssistant.ShowToolTip(data)
  InitializeTooltip(InformationTooltip, ReScanButton, BOTTOM, 0, 80)
  if data == false then
    SetTooltipText(InformationTooltip, GetString(DsRGuildInventory_NoNeedUpdate))
  elseif data == true then
    SetTooltipText(InformationTooltip, GetString(DsRGuildInventory_NeedUpdate))
  end
end

function IA_InventoryAssistant.HideToolTip()
  ClearTooltip(InformationTooltip)
end
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistant:FilterList( text )
  local list      = IA_InventoryAssistant.list
  local sets      = { }
  local materials = { }
  local others    = { }

  local c = IA_InventoryAssistant.async:Call( function ( ) 
    stopwatch_start ( "Rescanning current character and bank" )
    list:Reset ( )
    list:AddText ( { text = GetString(DsRGuildInventory_RescanCharBank) } )
    list:RefreshData ( )
    stopwatch_stop ( "Rescanning current character and bank" )
  end )
      
  c:Then( function ( )
    
    list:Reset ( )
    list:AddText( { text = loadText } )
    list:RefreshData ( )

    if text:sub ( 1, 3 ) == "CHA" then
      for k, v in pairs ( IA_InventoryAssistant.settings.characters ) do
        if v == text:sub ( 5 ) and IA_InventoryAssistant.settings.inventories[ k ] ~= nil then
          local loadText = GetString(DsRGuildInventory_LoadingInvOf) .. text:sub ( 5 )
          c:Call( function ( )
            stopwatch_start ( "Loading inventory of " .. IA_InventoryAssistant.settings.characters[ k ] )

            loadText = loadText .. "."
            list:Reset ( )
            list:AddText( { text = loadText } )
            list:RefreshData ( )
            LoadInventory ( IA_InventoryAssistant.settings.inventories[ k ], sets, materials, others )

            stopwatch_stop ( "Loading inventory of " .. IA_InventoryAssistant.settings.characters[ k ] )
          end )
        end
      end
      ZO_ComboBox_ObjectFromContainer(IA_MainArtDropdown):SetSelectedItem("|cFFAE42ALL|r")
    elseif text:sub ( 1, 3 ) == "BAN" or text:sub ( 1, 3 ) == "ABA" then
        local loadText = GetString(DsRGuildInventory_LoadingInvBank)
        c:Call( function ( )
          stopwatch_start ( "Loading bank inventory" )

          loadText = loadText .. "."
          list:Reset ( )
          list:AddText( { text = loadText } )
          list:RefreshData ( )
          LoadInventory ( IA_InventoryAssistant.settings.inventories[ "bank" ], sets, materials, others )

          stopwatch_stop ( "Loading bank inventory" )
        end )
        ZO_ComboBox_ObjectFromContainer(IA_MainArtDropdown):SetSelectedItem("|cFFAE42ALL|r")
    elseif text:sub ( 1, 3 ) == "CHE" then
        for k, v in pairs ( IA_InventoryAssistant.settings.chest ) do
          if v == text:sub ( 5 ) then
            local loadText = GetString(DsRGuildInventory_LoadingInvHouseChest) .. text:sub ( 5 )
            c:Call( function ( )
              stopwatch_start ( "Loading house chest inventory" )

              loadText = loadText .. "."
              list:Reset ( )
              list:AddText( { text = loadText } )
              list:RefreshData ( )

              local chest = {}
              for aa, bb in ipairs (IA_InventoryAssistant.settings.inventories[ "chest" ]) do
                if bb.charId == k then
                  table.insert( chest, IA_InventoryAssistant.settings.inventories[ "chest" ][aa])
                end
              end

              LoadInventory ( chest, sets, materials, others )

              stopwatch_stop ( "Loading house chest inventory" )
            end )
          end
        end
        ZO_ComboBox_ObjectFromContainer(IA_MainArtDropdown):SetSelectedItem("|cFFAE42ALL|r")
    elseif text:sub ( 1, 3 ) == "ALL" then
      c:Then( function ( )
        local loadText = GetString(DsRGuildInventory_LoadingInv)
        list:Reset ( )
        list:AddText( { text = loadText } )
        list:RefreshData ( )
        
        for k, v in pairs ( IA_InventoryAssistant.settings.characters ) do
          if IA_InventoryAssistant.settings.inventories[ k ] then
            c:Call( function ( )
              stopwatch_start ( "Loading inventory of " .. IA_InventoryAssistant.settings.characters[ k ] )
              
              loadText = loadText .. "."
              list:Reset ( )
              list:AddText( { text = loadText } )
              list:RefreshData ( )
              LoadInventory ( IA_InventoryAssistant.settings.inventories[ k ], sets, materials, others )
    
              stopwatch_stop ( "Loading inventory of " .. IA_InventoryAssistant.settings.characters[ k ] )
            end )
          end
        end 
        if IA_InventoryAssistant.settings.inventories[ "bank" ] then
          c:Call( function ( )
            stopwatch_start ( "Loading bank inventory" )
            
            loadText = loadText .. "."
            list:Reset ( )
            list:AddText( { text = loadText } )
            list:RefreshData ( )
            LoadInventory ( IA_InventoryAssistant.settings.inventories[ "bank" ], sets, materials, others )
            
            stopwatch_stop ( "Loading bank inventory" )
          end )
        end
        if IA_InventoryAssistant.settings.inventories[ "chest" ] then
          c:Call( function ( )
            stopwatch_start ( "Loading chest inventory" )
            
            loadText = loadText .. "."
            list:Reset ( )
            list:AddText( { text = loadText } )
            list:RefreshData ( )
            LoadInventory ( IA_InventoryAssistant.settings.inventories[ "chest" ], sets, materials, others )
  
            stopwatch_stop ( "Loading chest inventory" )
          end )
        end
      end )
      ZO_ComboBox_ObjectFromContainer(IA_MainArtDropdown):SetSelectedItem("|cFFAE42ALL|r")
    elseif text:sub ( 1, 3 ) == "ACA" then
      c:Then( function ( )
        local loadText = GetString(DsRGuildInventory_LoadingInv)
        list:Reset ( )
        list:AddText( { text = loadText } )
        list:RefreshData ( )
        
        for k, v in pairs ( IA_InventoryAssistant.settings.characters ) do
          if IA_InventoryAssistant.settings.inventories[ k ] then
            c:Call( function ( )
              stopwatch_start ( "Loading inventory of " .. IA_InventoryAssistant.settings.characters[ k ] )
              
              loadText = loadText .. "."
              list:Reset ( )
              list:AddText( { text = loadText } )
              list:RefreshData ( )
              LoadInventory ( IA_InventoryAssistant.settings.inventories[ k ], sets, materials, others )
    
              stopwatch_stop ( "Loading inventory of " .. IA_InventoryAssistant.settings.characters[ k ] )
            end )
          end
        end 
      end )
      ZO_ComboBox_ObjectFromContainer(IA_MainArtDropdown):SetSelectedItem("|cFFAE42ALL|r")
    elseif text:sub ( 1, 3 ) == "ACE" then
      c:Then( function ( )
        local loadText = GetString(DsRGuildInventory_LoadingInvHouseChest)
        list:Reset ( )
        list:AddText( { text = loadText } )
        list:RefreshData ( )
        c:Call( function ( )
          stopwatch_start ( "Loading house chest inventory" )
          
          loadText = loadText .. "."
          list:Reset ( )
          list:AddText( { text = loadText } )
          list:RefreshData ( )
          LoadInventory ( IA_InventoryAssistant.settings.inventories[ "chest" ], sets, materials, others )
          
          stopwatch_stop ( "Loading house chest inventory" )
        end )
      end )
      ZO_ComboBox_ObjectFromContainer(IA_MainArtDropdown):SetSelectedItem("|cFFAE42ALL|r")
    elseif text:sub ( 1, 3 ) == "ART" then
      c:Then( function ( )
        local loadText = GetString(DsRGuildInventory_LoadingInv)
        list:Reset ( )
        list:AddText( { text = loadText } )
        list:RefreshData ( )

        local temptable = {}
        c:Call( function ( )
          stopwatch_start ( "Loading inventory of " .. text:sub ( 5 ) )
          
          loadText = loadText .. "."
          list:Reset ( )
          list:AddText( { text = loadText } )
          list:RefreshData ( )
          for k, v in pairs ( IA_InventoryAssistant.settings.characters ) do
            for i, a in pairs ( IA_InventoryAssistant.settings.inventories[ k ] ) do
              local loadText = GetString(DsRGuildInventory_LoadingInvOf) .. text:sub ( 5 )
              if a.typDesc == text:sub ( 5 ) and IA_InventoryAssistant.settings.inventories[ k ] [ i ] ~= nil then
                table.insert( temptable, IA_InventoryAssistant.settings.inventories[ k ][ i ])
              end
            end
          end
          for k, v in ipairs ( IA_InventoryAssistant.settings.inventories[ "bank" ] ) do
            local loadText = GetString(DsRGuildInventory_LoadingInvOf) .. text:sub ( 5 )
            if v.typDesc == text:sub ( 5 ) and IA_InventoryAssistant.settings.inventories[ "bank" ][ k ] ~= nil then
              table.insert( temptable, IA_InventoryAssistant.settings.inventories[ "bank" ][ k ])
            end
          end
          for k, v in ipairs ( IA_InventoryAssistant.settings.inventories[ "chest" ] ) do
            local loadText = GetString(DsRGuildInventory_LoadingInvOf) .. text:sub ( 5 )
            if v.typDesc == text:sub ( 5 ) and IA_InventoryAssistant.settings.inventories[ "chest" ][ k ] ~= nil then
              table.insert( temptable, IA_InventoryAssistant.settings.inventories[ "chest" ][ k ])
            end
          end
          LoadInventory ( temptable, sets, materials, others )
          stopwatch_stop ( "Loading inventory of " .. text:sub ( 5 ) )
        end )
      end )
      ZO_ComboBox_ObjectFromContainer(IA_MainPlaceDropdown):SetSelectedItem("|cFFAE42ALL|r")
    end
  end )

  c:Then( function ( )
    stopwatch_start ( "Sorting inventory" )
    
    local bopTradeableSets = { }
    for _,set in ipairs ( sets ) do
      for _,item in ipairs ( sets[ set ] ) do
        if item.bopTimeEnds and item.bopTimeEnds > GetTimeStamp ( ) then
          if ( type ( item.bagId ) == "number" ) then 
            table.insert ( bopTradeableSets, set )
          end
        end
      end
    end
    
    table.sort ( bopTradeableSets )
    table.sort ( sets )
    table.sort ( materials )
    table.sort ( others )
    
    IA_InventoryAssistant.sets = { }
    for i,v in ipairs ( bopTradeableSets ) do
      if not IA_InventoryAssistant.sets[ v ] then
        table.insert ( IA_InventoryAssistant.sets, v )
        IA_InventoryAssistant.sets[ v ] = sets[ v ]
      end
    end
    for i,v in ipairs ( sets ) do
      if not IA_InventoryAssistant.sets[ v ] then
        table.insert ( IA_InventoryAssistant.sets, v )
        IA_InventoryAssistant.sets[ v ] = sets[ v ]
      end
    end
    
    IA_InventoryAssistant.others = { }
    for i,v in ipairs ( others ) do
      if not IA_InventoryAssistant.others[ v ] then
        table.insert ( IA_InventoryAssistant.others, v )
        IA_InventoryAssistant.others[ v ] = others[ v ]
      end
    end

    stopwatch_stop ( "Sorting inventory" )
    IA_InventoryAssistant:Refresh ( false )
  end )
end

-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistant:InitializeHooks ( control )
  local originalSearchText = nil
  
  local updateSearchFilter = function ( itemLink )
    local searchText
    local isSetItem, setName = GetItemLinkSetInfo ( itemLink, false )
    local itemName = GetItemLinkName ( itemLink )
    if IsShiftKeyDown() then
      if not originalSearchText then
        originalSearchText = IA_InventoryAssistant.searchbox:GetText ( )
      end
      if isSetItem then
        searchText = zo_strformat ( "<<1>>", setName )
      else
        searchText = zo_strformat ( "<<1>>", itemName )
      end
      if searchText and IA_InventoryAssistant.searchbox:GetText ( ) ~= searchText then 
        IA_InventoryAssistant.searchbox:SetText ( searchText )
      end
    end
  end
  
  local originalSetBagItem = ItemTooltip.SetBagItem
  ItemTooltip.SetBagItem = function ( tooltip, bagId, slotIndex, ... )
      originalSetBagItem ( tooltip, bagId, slotIndex, ... )
      local itemLink = GetItemLink ( bagId, slotIndex, LINK_STYLE_DEFAULT )
      updateSearchFilter ( itemLink )
  end
  
  local originalSetLink = ItemTooltip.SetLink
  ItemTooltip.SetLink_IA = originalSetLink
  ItemTooltip.SetLink = function ( tooltip, itemLink, ... )
      originalSetLink ( tooltip, itemLink, ... )
      updateSearchFilter ( itemLink )
  end
  
  local originalSetTradingHouseListing = ItemTooltip.SetTradingHouseListing
  ItemTooltip.SetTradingHouseListing = function ( tooltip, slotIndex, ... )
      originalSetTradingHouseListing ( tooltip, slotIndex, ... )
      local itemLink = GetTradingHouseListingItemLink ( slotIndex )
      updateSearchFilter ( itemLink )
  end
  
  local originalSetTradingHouseItem = ItemTooltip.SetTradingHouseItem
  ItemTooltip.SetTradingHouseItem = function ( tooltip, slotIndex, ... )
      originalSetTradingHouseItem ( tooltip, slotIndex, ... )
      local itemLink = GetTradingHouseSearchResultItemLink ( slotIndex )
      updateSearchFilter ( itemLink )
  end
  
  ZO_PreHookHandler ( ItemTooltip, "OnHide", function ( tooltip, ... )
    if originalSearchText then
      originalSearchText = nil
    end
  end )

  local originalPopupSetLink = PopupTooltip.SetLink
  PopupTooltip.SetLink_IA = originalPopupSetLink
  PopupTooltip.SetLink = function ( tooltip, itemLink, ... )
      originalPopupSetLink ( tooltip, itemLink, ... )
      updateSearchFilter ( itemLink )
      if IA_InventoryAssistant.window:IsControlHidden ( ) and IsShiftKeyDown ( ) then
        self:ToggleWindow ( false )
      end
  end
  
  if ItemBrowserTooltip then 
    local originalIBSetLink = ItemBrowserTooltip.SetLink
    ItemBrowserTooltip.SetLink = function ( tooltip, itemLink, ... )
        originalIBSetLink ( tooltip, itemLink, ... )
        updateSearchFilter ( itemLink )
    end
  end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistant.DsRdonation()
	SCENE_MANAGER:Show('mailSend')
	zo_callLater(function() 
		ZO_MailSendToField:SetText("@Hasenwarrior")
		ZO_MailSendSubjectField:SetText(GetString(DsRGuild_donationMailSubject))
		ZO_MailSendBodyField:SetText(zo_strformat( GetString(DsRGuild_donationMailTxT), GetDisplayName():gsub("^@", "") ))
    QueueMoneyAttachment(500000)
		ZO_MailSendBodyField:TakeFocus()
	end, 250)
end

-----------------------------------------------------------------------------------------------------------------------------------
-- EVENT HANDLERS
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistant:HandleSlashCommand ( command )
  self:ToggleWindow ( ) 
end
-----------------------------------------------------------------------------------------------------------------------------------
-- IMPLEMENTATION
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistant:ToggleWindow ( grabFocus )
  if IA_InventoryAssistant.settings.InvOnOff then return end

  IA_InventoryAssistant.window:SetHidden( not IA_InventoryAssistant.window:IsControlHidden ( ) )

  if not IA_InventoryAssistant.window:IsControlHidden ( ) then
    IA_InventoryAssistant.async:Call( function ( ) self:Refresh ( true ) end )
    if grabFocus then
      IA_InventoryAssistant.searchbox:TakeFocus ( )
      SetGameCameraUIMode ( true )
    end
    self:Refresh ( true )
    IA_InventoryAssistant.hiddenShortly = true
  else
    IA_InventoryAssistant.async:Call( function ( )
      IA_InventoryAssistant.list:Reset ( )
      IA_InventoryAssistant.list:RefreshData ( )
    end )
    IA_InventoryAssistant.hiddenShortly = false
  end
  IA_InventoryAssistant.ReScan = true
  ReScanButton:SetNormalTexture("/DsRGuildHall/misc/update_noneed.dds")
  ReScanButton:SetMouseOverTexture("esoui/art/lfg/lfg_groupfinder_refreshsearch_over.dds")
  ReScanButton:SetHandler("OnMouseEnter", function() IA_InventoryAssistant.ShowToolTip(false) end)
  ReScanButton:SetHandler("OnMouseExit" , function() IA_InventoryAssistant.HideToolTip()      end)
end
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistant:Rescan ( )
  IA_InventoryAssistant.settings.characters = { }
  for charNum=1, GetNumCharacters ( ), 1 do
		local name, gender, level, classId, raceId, alliance, charId, locationId = GetCharacterInfo ( charNum )
    IA_InventoryAssistant.settings.characters [ charId ] = zo_strformat(SI_UNIT_NAME, name)
	end

	local currentCharId = zo_strformat( "<<1>>", GetCurrentCharacterId ( ) )

  local bag = { }
  ScanBag ( bag, BAG_WORN, currentCharId, IA_InventoryAssistant.settings.actionQueue )
  ScanBag ( bag, BAG_BACKPACK, currentCharId, IA_InventoryAssistant.settings.actionQueue )
  IA_InventoryAssistant.settings.inventories [ currentCharId ] = bag
  
  local bank = { }
  ScanBag ( bank, BAG_BANK, nil, IA_InventoryAssistant.settings.actionQueue )
  ScanBag ( bank, BAG_SUBSCRIBER_BANK, nil, IA_InventoryAssistant.settings.actionQueue )
  IA_InventoryAssistant.settings.inventories [ "bank" ] = bank
  
  IA_InventoryAssistant.settings.chest = { }
  if IsOwnerOfCurrentHouse ( ) then
      local chest = { }
      for bag = BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN do
        if IsCollectibleUnlocked ( GetCollectibleForHouseBankBag ( bag ) ) then 
          cId   = zo_strformat( "<<1>>", GetCollectibleForHouseBankBag(bag))
          cName = GetCollectibleNickname(cId)
          IA_InventoryAssistant.settings.chest [ cId ] = zo_strformat( "<<1>>", cName)

          local epoch = GetTimeStamp ( )
          for slotIndex=0, GetBagSize ( bag ) do
            local item = ScanBagSlot ( bag, slotIndex, epoch, cId )
            local actionQueue = IA_InventoryAssistant.settings.actionQueue
            if item then 
                if actionQueue and actionQueue.lock [ item.uniqueId ] and item.bag and item.slotIndex then
                  SetItemIsPlayerLocked ( item.bag, item.slotIndex, true )
                  actionQueue.lock [ item.uniqueId ] = nil
                  item.locked = true
                end
                if actionQueue and actionQueue.unlock [ item.uniqueId ] and item.bag and item.slotIndex then
                  SetItemIsPlayerLocked ( item.bag, item.slotIndex, false )
                  actionQueue.unlock [ item.uniqueId ] = nil
                  item.locked = false
                end
                table.insert ( chest, item )
            end
            IA_InventoryAssistant.settings.inventories [ "chest" ] = chest
          end
        end
      end
  end
end
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistant:Reload ( )
  local list = IA_InventoryAssistant.list
  local sets = { }
  local materials = { }
  local others = { }

  local c = IA_InventoryAssistant.async:Call( function ( ) 
    stopwatch_start ( "Rescanning current character and bank" )
    list:Reset ( )
    list:AddText ( { text = GetString(DsRGuildInventory_RescanCharBank) } )
    list:RefreshData ( )
    stopwatch_stop ( "Rescanning current character and bank" )
  end )
      
  c:Then( function ( )
    local loadText = GetString(DsRGuildInventory_LoadingInv)
    list:Reset ( )
    list:AddText( { text = loadText } )
    list:RefreshData ( )
    
    for k, v in pairs ( IA_InventoryAssistant.settings.characters ) do
      if IA_InventoryAssistant.settings.inventories[ k ] then
        c:Call( function ( )
          stopwatch_start ( "Loading inventory of " .. IA_InventoryAssistant.settings.characters[ k ] )
          
          loadText = loadText .. "."
          list:Reset ( )
          list:AddText( { text = loadText } )
          list:RefreshData ( )
          LoadInventory ( IA_InventoryAssistant.settings.inventories[ k ], sets, materials, others )

          stopwatch_stop ( "Loading inventory of " .. IA_InventoryAssistant.settings.characters[ k ] )
        end )
      end
    end 
    if IA_InventoryAssistant.settings.inventories[ "bank" ] then
      c:Call( function ( )
        stopwatch_start ( "Loading bank inventory" )
        
        loadText = loadText .. "."
        list:Reset ( )
        list:AddText( { text = loadText } )
        list:RefreshData ( )
        LoadInventory ( IA_InventoryAssistant.settings.inventories[ "bank" ], sets, materials, others )
        
        stopwatch_stop ( "Loading bank inventory" )
      end )
    end
    if IA_InventoryAssistant.settings.inventories[ "chest" ] then
      c:Call( function ( )
        stopwatch_start ( "Loading chest inventory" )
        
        loadText = loadText .. "."
        list:Reset ( )
        list:AddText( { text = loadText } )
        list:RefreshData ( )
        LoadInventory ( IA_InventoryAssistant.settings.inventories[ "chest" ], sets, materials, others )
        stopwatch_stop ( "Loading chest inventory" )
      end )
    end
  end )

  c:Then( function ( )
    stopwatch_start ( "Sorting inventory" )
    
    local bopTradeableSets = { }
    for _,set in ipairs ( sets ) do
      for _,item in ipairs ( sets[ set ] ) do
        if item.bopTimeEnds and item.bopTimeEnds > GetTimeStamp ( ) then
          if ( type ( item.bagId ) == "number" ) then 
            table.insert ( bopTradeableSets, set )
          end
        end
      end
    end
    
    table.sort ( bopTradeableSets )
    table.sort ( sets )
    table.sort ( materials )
    table.sort ( others )
    
    IA_InventoryAssistant.sets = { }
    for i,v in ipairs ( bopTradeableSets ) do
      if not IA_InventoryAssistant.sets[ v ] then
        table.insert ( IA_InventoryAssistant.sets, v )
        IA_InventoryAssistant.sets[ v ] = sets[ v ]
      end
    end
    for i,v in ipairs ( sets ) do
      if not IA_InventoryAssistant.sets[ v ] then
        table.insert ( IA_InventoryAssistant.sets, v )
        IA_InventoryAssistant.sets[ v ] = sets[ v ]
      end
    end
    
    IA_InventoryAssistant.others = { }
    for i,v in ipairs ( others ) do
      if not IA_InventoryAssistant.others[ v ] then
        table.insert ( IA_InventoryAssistant.others, v )
        IA_InventoryAssistant.others[ v ] = others[ v ]
      end
    end

    stopwatch_stop ( "Sorting inventory" )
  end )
  IA_InventoryAssistant.HideToolTip()
  ReScanButton:SetHandler("OnMouseEnter", function() IA_InventoryAssistant.ShowToolTip(false) end)
  ReScanButton:SetHandler("OnMouseExit" , function() IA_InventoryAssistant.HideToolTip()      end)
  return c

end
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistant:GetItemMarkers ( itemId, uniqueId, bagId, stolen )
  local markers = { }
  
  if type ( bagId ) == "string" then
    table.insert ( markers, { icon = "esoui/art/contacts/social_status_afk.dds", color = { r=1, g=1, b=1, a=1 } } )
  end
  
  if stolen then
    table.insert ( markers, { icon = "esoui/art/inventory/inventory_stolenItem_icon.dds", color = { r=1, g=1, b=1, a=1 } } )
  end

  return markers
end
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistant:Refresh ( reload )
  local list = IA_InventoryAssistant.list
  
  local c
  if reload then  -- true
    c = self:Reload ( )
  else            -- false
    c = IA_InventoryAssistant.async:Call( function ( ) end )
  end
      
  local onlyDuplicates  = IA_InventoryAssistant.onlyDuplicates
  local onlyMarkedItems = IA_InventoryAssistant.onlyMarkedItems
  local onlyLoots       = IA_InventoryAssistant.onlyLoots
  local showCrafted     = IA_InventoryAssistant.showCrafted
  local showBuyable     = IA_InventoryAssistant.showBuyable
  local showBound       = IA_InventoryAssistant.showBound
  local showMonsterSets = IA_InventoryAssistant.showMonsterSets
  local showNonSetItems = IA_InventoryAssistant.showNonSetItems
  -- local bagNameWidth    = IA_InventoryAssistant.bagNameWidth
  
  c:Then( function ( )
    stopwatch_start ( "Populating UI" )
        
    local set_search_keywords      = { }
    local name_search_keywords     = { }
    local trait_search_keywords    = { }
    local nottrait_search_keywords = { }
    local bag_search_keywords      = { }
    local searchtext               = IA_InventoryAssistant.searchbox:GetText ( ):lower ( )

    for w in searchtext:gmatch ( "%S+" ) do
      if w:sub ( 1, 2 ) == "t:" then
        table.insert ( trait_search_keywords, w:sub ( 3 ) )
      elseif w:sub ( 1, 3 ) == "nt:" then
        table.insert ( nottrait_search_keywords, w:sub ( 4 ) )
      elseif w:sub ( 1, 2 ) == "b:" then
        table.insert ( bag_search_keywords, w:sub ( 3 ) )
      else
        table.insert ( set_search_keywords, w )
        table.insert ( name_search_keywords, w )
      end
    end

    local sets   = IA_InventoryAssistant.sets or { }
    local others = IA_InventoryAssistant.others or { }

    local totalShownSets   = 0
    local totalShownItems  = 0
    local totalComplete    = 0
    local summary = { text = string.format ( GetString(DsRGuildInventory_InvSetItems), totalShownSets, totalShownItems, totalComplete ) }
    list:Reset ( )
    list:AddText ( summary )

    for i,v in ipairs ( sets ) do
      local setitems = IA_InventoryAssistant.sets[ v ] or { }
      table.sort ( setitems, sortFunction )
      
      local header = { text1 = GetString(DsRGuildInventory_InvItems), text2 = GetString(DsRGuildInventory_InvOfItems), name = v, itemCount = #setitems, showCount = 0, color = ZO_DEFAULT_TEXT }
      local headerPrinted = false
      local bopTradeable = false

      for i, v in ipairs ( setitems ) do
        if v.bopTimeEnds and v.bopTimeEnds > GetTimeStamp ( ) then
          if ( type ( v.bagId ) == "number" ) then 
            bopTradeable = true
          end
        end
        
        local isCrafted = IsItemLinkCrafted ( v.link )
        local isBuyable = ( GetItemLinkBindType ( v.link ) ~= BIND_TYPE_ON_PICKUP and GetItemLinkBindType ( v.link ) ~= BIND_TYPE_ON_PICKUP_BACKPACK )
        
        local include1 = true
        local p = 0
        for k,w in ipairs ( set_search_keywords ) do
          if include1 then
            p = v.setName:lower( ):find ( w, p + 1, true )
            if ( not p ) then
              include1 = false
            end
          end
        end
        local include2 = true
        p = 0
        for k,w in ipairs ( name_search_keywords ) do
          if include2 then
            p = v.name:lower( ):find ( w, p + 1, true )
            if ( not p ) then
              include2 = false
            end
          end
        end
        
        if ( include1 or include2 ) and ( ( showCrafted and isCrafted ) or ( showBuyable and isBuyable and not isCrafted ) or ( v.numBonuses == 2 and not isBuyable and showMonsterSets ) or ( showBound and not isBuyable and v.numBonuses ~= 2 ) ) then 
          v.markers = self:GetItemMarkers ( v.itemId, v.uniqueId, v.bagId, v.stolen )
          
          local bagName = ""
          if type ( v.bagId ) == "string" then
            bagName = string.format ( "|c0CD0FF%s|r", v.bagId )
          elseif v.bagId == BAG_WORN then
            bagName = zo_iconFormat("/esoui/art/tooltips/icon_bag.dds", 20, 20) .. ( IA_InventoryAssistant.settings.characters[ v.charId ] or v.charId or "???" ) .. GetString(DsRGuildInventory_WornSet)
          elseif v.bagId == BAG_BACKPACK then
            bagName = zo_iconFormat("/esoui/art/tooltips/icon_bag.dds", 20, 20) .. IA_InventoryAssistant.settings.characters[ v.charId ] or v.charId
          elseif v.bagId == BAG_BANK or v.bagId == BAG_SUBSCRIBER_BANK then
            bagName = zo_iconFormat("/esoui/art/tooltips/icon_bank.dds", 20, 20) .. GetString(DsRGuildInventory_InvBank)
          elseif v.bagId >= BAG_HOUSE_BANK_ONE and v.bagId <= BAG_HOUSE_BANK_TEN then
            bagName = zo_iconFormat("/esoui/art/tooltips/icon_house_bank.dds", 20, 20) .. GetCollectibleNickname ( GetCollectibleForHouseBankBag ( v.bagId ) )
            if bagName == "" then
              bagName = zo_iconFormat("/esoui/art/tooltips/icon_house_bank.dds", 20, 20) .. GetCollectibleName ( GetCollectibleForHouseBankBag ( v.bagId ) )
            end 
            bagName = zo_strformat ( "<<1>>", bagName )
          end
          v.bagName = bagName
          
          local match_trait = #trait_search_keywords == 0 and true or false
          for k,w in ipairs ( trait_search_keywords ) do
            if string.sub ( v.traitTypeName:lower ( ), 1, w:len ( ) ) == w then
              match_trait = true
            end
          end
          
          local match_nottrait = true
          for k,w in ipairs ( nottrait_search_keywords ) do
            if w ~= "" and string.sub ( v.traitTypeName:lower ( ), 1, w:len ( ) ) == w then
              match_nottrait = false
            end
          end
          
          local match_bag = #bag_search_keywords == 0 and true or false
          for k,w in ipairs ( bag_search_keywords ) do
            if string.sub ( bagName:lower ( ), 1, w:len ( ) ) == w then
              match_bag = true
            end
          end
          
          if ( onlyLoots and v.bopTimeEnds and v.bopTimeEnds > GetTimeStamp ( ) ) or not onlyLoots then
            local level, isNonCP160 = "", false
            if ( v.armorType ~= ARMORTYPE_NONE or v.weaponType ~= WEAPONTYPE_NONE or v.equipType == EQUIP_TYPE_RING or v.equipType == EQUIP_TYPE_NECK
              or v.itemType == ITEMTYPE_GLYPH_ARMOR or v.itemType == ITEMTYPE_GLYPH_JEWELRY or v.itemType == ITEMTYPE_GLYPH_WEAPON 
              or v.itemType == ITEMTYPE_FOOD or v.itemType == ITEMTYPE_DRINK or v.itemType == ITEMTYPE_POTION or v.itemType == ITEMTYPE_POISON
            ) then 
              if ( v.requiredChampionPoints == 0 and v.requiredLevel > 0 ) then
                if not ( v.itemType == ITEMTYPE_FOOD or v.itemType == ITEMTYPE_DRINK or v.itemType == ITEMTYPE_POTION or v.itemType == ITEMTYPE_POISON ) then
                  level = string.format ( "|t24:24:esoui/art/lfg/lfg_normaldungeon_down.dds|t%d  ", v.requiredLevel )
                  isNonCP160 = true
                elseif ( v.requiredLevel > 1 ) then
                  level = string.format ( "|t24:24:esoui/art/lfg/lfg_normaldungeon_down.dds|t%d  ", v.requiredLevel )
                  isNonCP160 = true
                end
              elseif ( v.requiredChampionPoints < 160 and v.requiredLevel == 50 and not ( v.itemType == ITEMTYPE_FOOD or v.itemType == ITEMTYPE_DRINK or v.itemType == ITEMTYPE_POTION or v.itemType == ITEMTYPE_POISON ) ) then
                level = string.format ( "|t24:24:esoui/art/lfg/lfg_championdungeon_down.dds|t%d  ", v.requiredChampionPoints )
                isNonCP160 = true
              elseif ( v.requiredChampionPoints < 150 and v.requiredLevel == 50 and ( v.itemType == ITEMTYPE_FOOD or v.itemType == ITEMTYPE_DRINK or v.itemType == ITEMTYPE_POTION or v.itemType == ITEMTYPE_POISON ) ) then
                level = string.format ( "|t24:24:esoui/art/lfg/lfg_championdungeon_down.dds|t%d  ", v.requiredChampionPoints )
                isNonCP160 = true
              end
            end
            if not IA_InventoryAssistant.showItemLevels then
              level = ""
            end
            local enchant     = IA_InventoryAssistant.showEnchants and v.enchant or ""
            local itemprice   = IA_InventoryAssistant.showTradPrice and v.Price or ""
            
            if match_bag and match_trait and match_nottrait 
               and ( ( onlyMarkedItems and #v.markers > 0 ) or not onlyMarkedItems )
               and ( ( IA_InventoryAssistant.onlyNonCP160 and isNonCP160 ) or not IA_InventoryAssistant.onlyNonCP160 )
               and ( ( IA_InventoryAssistant.onlyCP160 and not isNonCP160 ) or not IA_InventoryAssistant.onlyCP160 ) then
              local threshold = v.subcategory == "Ring" and 2 or 1
              
              if not headerPrinted and ( not onlyDuplicates or #setitems[ v.itemkey ] > threshold ) then  
                list:AddHeader( header, "esoui/art/progression/skills_announce_armor.dds", GetEquipSlotData ( setitems ) )
                headerPrinted = true
                totalShownSets = totalShownSets + 1
              end
              if #setitems[ v.itemkey ] > threshold then 
                list:AddData( string.format ( "%s%s|r  |cFFCC00*|r  (%s)%s%s", level, v.link, v.traitTypeName, enchant, itemprice ), v, v.icon, v.link, level, v.bagName, v.itemId, v.uniqueId , itemprice)
                header.showCount = header.showCount + 1
                totalShownItems = totalShownItems + 1
              elseif not onlyDuplicates then 
                list:AddData( string.format ( "%s%s|r  (%s)%s%s", level, v.link, v.traitTypeName, enchant, itemprice ), v, v.icon, v.link, level, v.bagName, v.itemId, v.uniqueId, itemprice )
                header.showCount = header.showCount + 1
                totalShownItems = totalShownItems + 1
              end
            end
          end
        end
      end
      if bopTradeable then
        header.text1 = string.format ( "|c0CD0FF%s|r", header.text1 )
        header.text2 = string.format ( "|c0CD0FF%s|r", header.text2 )
      end
    end
    local totalComplete = GetItemCount ( IA_InventoryAssistant.others, IA_InventoryAssistant.others ) + GetItemCount ( IA_InventoryAssistant.sets, IA_InventoryAssistant.sets )
    if totalShownSets == GetSetCount ( IA_InventoryAssistant.sets ) and totalShownItems == GetItemCount ( IA_InventoryAssistant.sets, IA_InventoryAssistant.sets ) then
      summary.text = string.format ( GetString(DsRGuildInventory_InvSetItems), totalShownSets, totalShownItems, totalComplete )
    else
      summary.text = string.format ( GetString(DsRGuildInventory_InvSetOfItems), totalShownSets, GetSetCount ( IA_InventoryAssistant.sets ), totalShownItems, GetItemCount ( IA_InventoryAssistant.sets, IA_InventoryAssistant.sets ) )
    end

    if showNonSetItems then 
      for i1,v1 in ipairs ( others ) do
        local otheritems = IA_InventoryAssistant.others[ v1 ] or { }
        table.sort ( otheritems, sortFunction2 )
        
        local header = { text1 = GetString(DsRGuildInventory_InvItems), text2 = GetString(DsRGuildInventory_InvOfItems), name = v1, itemCount = #otheritems, showCount = 0, color = ZO_DEFAULT_TEXT }
        local headerPrinted = false

        for i, v in ipairs ( otheritems ) do
          local isCrafted = IsItemLinkCrafted ( v.link )
          local isBuyable = ( GetItemLinkBindType ( v.link ) ~= BIND_TYPE_ON_PICKUP and GetItemLinkBindType ( v.link ) ~= BIND_TYPE_ON_PICKUP_BACKPACK )
          
          local include1 = true
          local p = 0
          for k,w in ipairs ( set_search_keywords ) do
            if include1 then
              p = v1:lower( ):find ( w, p + 1, true )
              if ( not p ) then
                include1 = false
              end
            end
          end
          local include2 = true
          p = 0
          for k,w in ipairs ( name_search_keywords ) do
            if include2 then
              p = v.name:lower( ):find ( w, p + 1, true )
              if ( not p ) then
                include2 = false
              end
            end
          end

          if ( include1 or include2 )  then 
            v.markers = self:GetItemMarkers ( v.itemId, v.uniqueId, v.bagId, v.stolen )
            
            local bagName = ""
            if type ( v.bagId ) == "string" then
              bagName = string.format ( "|c0CD0FF%s|r", v.bagId )
            elseif v.bagId == BAG_WORN then
              bagName = zo_iconFormat("/esoui/art/tooltips/icon_bag.dds", 20, 20) .. ( IA_InventoryAssistant.settings.characters[ v.charId ] or v.charId or "???" ) .. GetString(DsRGuildInventory_WornSet)
            elseif v.bagId == BAG_BACKPACK then
              bagName = zo_iconFormat("/esoui/art/tooltips/icon_bag.dds", 20, 20) .. IA_InventoryAssistant.settings.characters[ v.charId ] or v.charId
            elseif v.bagId == BAG_BANK or v.bagId == BAG_SUBSCRIBER_BANK then
              bagName = zo_iconFormat("/esoui/art/tooltips/icon_bank.dds", 20, 20) .. GetString(DsRGuildInventory_InvBank)
            elseif v.bagId >= BAG_HOUSE_BANK_ONE and v.bagId <= BAG_HOUSE_BANK_TEN then
              bagName = zo_iconFormat("/esoui/art/tooltips/icon_house_bank.dds", 20, 20) .. GetCollectibleNickname ( GetCollectibleForHouseBankBag ( v.bagId ) )
              if bagName == "" then
                bagName = zo_iconFormat("/esoui/art/tooltips/icon_house_bank.dds", 20, 20) .. GetCollectibleName ( GetCollectibleForHouseBankBag ( v.bagId ) )
              end 
              bagName = zo_strformat ( "<<1>>", bagName )
            end
            v.bagName = bagName
            
            local match_trait = #trait_search_keywords == 0 and true or false
            for k,w in ipairs ( trait_search_keywords ) do
              if string.sub ( v.traitTypeName:lower ( ), 1, w:len ( ) ) == w then
                match_trait = true
              end
            end
            
            local match_nottrait = true
            for k,w in ipairs ( nottrait_search_keywords ) do
              if w ~= "" and string.sub ( v.traitTypeName:lower ( ), 1, w:len ( ) ) == w then
                match_nottrait = false
              end
            end
            
            local match_bag = #bag_search_keywords == 0 and true or false
            for k,w in ipairs ( bag_search_keywords ) do
              if string.sub ( bagName:lower ( ), 1, w:len ( ) ) == w then
                match_bag = true
              end
            end
            
            if ( onlyLoots and v.bopTimeEnds and v.bopTimeEnds > GetTimeStamp ( ) ) or not onlyLoots then
              local level, isNonCP160 = "", false
              if ( v.armorType ~= ARMORTYPE_NONE or v.weaponType ~= WEAPONTYPE_NONE or v.equipType == EQUIP_TYPE_RING or v.equipType == EQUIP_TYPE_NECK
                or v.itemType == ITEMTYPE_GLYPH_ARMOR or v.itemType == ITEMTYPE_GLYPH_JEWELRY or v.itemType == ITEMTYPE_GLYPH_WEAPON 
                or v.itemType == ITEMTYPE_FOOD or v.itemType == ITEMTYPE_DRINK or v.itemType == ITEMTYPE_POTION or v.itemType == ITEMTYPE_POISON
              ) then 
                if ( v.requiredChampionPoints == 0 and v.requiredLevel > 0 ) then
                  if not ( v.itemType == ITEMTYPE_FOOD or v.itemType == ITEMTYPE_DRINK or v.itemType == ITEMTYPE_POTION or v.itemType == ITEMTYPE_POISON ) then
                    level = string.format ( "|t24:24:esoui/art/lfg/lfg_normaldungeon_down.dds|t%d  ", v.requiredLevel )
                    isNonCP160 = true
                  elseif ( v.requiredLevel > 1 ) then
                    level = string.format ( "|t24:24:esoui/art/lfg/lfg_normaldungeon_down.dds|t%d  ", v.requiredLevel )
                    isNonCP160 = true
                  end
                elseif ( v.requiredChampionPoints < 160 and v.requiredLevel == 50 and not ( v.itemType == ITEMTYPE_FOOD or v.itemType == ITEMTYPE_DRINK or v.itemType == ITEMTYPE_POTION or v.itemType == ITEMTYPE_POISON ) ) then
                  level = string.format ( "|t24:24:esoui/art/lfg/lfg_championdungeon_down.dds|t%d  ", v.requiredChampionPoints )
                  isNonCP160 = true
                elseif ( v.requiredChampionPoints < 150 and v.requiredLevel == 50 and ( v.itemType == ITEMTYPE_FOOD or v.itemType == ITEMTYPE_DRINK or v.itemType == ITEMTYPE_POTION or v.itemType == ITEMTYPE_POISON ) ) then
                  level = string.format ( "|t24:24:esoui/art/lfg/lfg_championdungeon_down.dds|t%d  ", v.requiredChampionPoints )
                  isNonCP160 = true
                end
              end
              if not IA_InventoryAssistant.showItemLevels then
                level = ""
              end
              local enchant = IA_InventoryAssistant.showEnchants and v.enchant or ""
              
              if match_bag and match_trait and match_nottrait 
                 and ( ( onlyMarkedItems and #v.markers > 0  ) or not onlyMarkedItems )
                 and ( ( IA_InventoryAssistant.onlyNonCP160 and isNonCP160 ) or not IA_InventoryAssistant.onlyNonCP160 )
                 and ( ( IA_InventoryAssistant.onlyCP160 and not isNonCP160 ) or not IA_InventoryAssistant.onlyCP160 ) then
                
                if not headerPrinted then  
                  list:AddHeader( header, "esoui/art/progression/skills_announce_armor.dds" )
                  headerPrinted = true
                end
                
                if v.stackCount and v.stackCount > 1 then
                  if ( v.traitType and v.traitType ~= 0 ) then 
                    list:AddData( string.format ( "%s%s|r  (%d)  (%s)%s - %s", level, v.link, v.stackCount, v.traitTypeName, enchant, v.Price ), v, v.icon, v.link, level, v.bagName, v.itemId, v.uniqueId, v.Price )
                  else
                    list:AddData( string.format ( "%s%s|r  (%d)%s - %s", level, v.link, v.stackCount, enchant, v.Price ), v, v.icon, v.link, level, v.bagName, v.itemId, v.uniqueId, v.Price )
                  end
                else
                  if ( v.traitType and v.traitType ~= 0 ) then 
                    list:AddData( string.format ( "%s%s|r  (%s)%s - %s", level, v.link, v.traitTypeName, enchant, v.Price ), v, v.icon, v.link, level, v.bagName, v.itemId, v.uniqueId, v.Price )
                  else
                    list:AddData( string.format ( "%s%s|r%s - %s", level, v.link, enchant, v.Price ), v, v.icon, v.link, level, v.bagName, v.itemId, v.uniqueId, v.Price )
                  end
                end
                header.showCount = header.showCount + 1
              end
            end
          end
        end
      end
    end

    stopwatch_stop ( "Populating UI" )
  end )
  c:Then( function ( ) 
    stopwatch_start ( "Refreshing UI" )
    list:RefreshData ( )
    stopwatch_stop ( "Refreshing UI" )
  end )
end

-----------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistant_OnInitialize ( control )
  IA_INVENTORY_ASSISTANT = IA_InventoryAssistant:New ( control )
end
