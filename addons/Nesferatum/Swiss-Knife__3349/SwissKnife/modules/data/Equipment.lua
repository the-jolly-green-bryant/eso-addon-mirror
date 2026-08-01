local SK = SwissKnife
local TRUE, FALSE = SK.TRUE, SK.FALSE

SK.Data.equipmentData = {
	SETS_DEFAULTS = {
	    -- itemType, equipType, name, checked, icon, offsets
	    {ITEMTYPE_ARMOR, EQUIP_TYPE_HEAD, GetString("SI_EQUIPTYPE", EQUIP_TYPE_HEAD), TRUE,
	     "/SwissKnife/textures/apparel/head.dds", {0, 44}}, -- Голова
	    {ITEMTYPE_ARMOR, EQUIP_TYPE_SHOULDERS, GetString("SI_EQUIPTYPE", EQUIP_TYPE_SHOULDERS), TRUE,
	     "/SwissKnife/textures/apparel/shoulders.dds", {155, 44}}, -- Плечи
	    {ITEMTYPE_ARMOR, EQUIP_TYPE_CHEST, GetString("SI_EQUIPTYPE", EQUIP_TYPE_CHEST), TRUE,
	     "/SwissKnife/textures/apparel/chest.dds", {0, 79}}, -- Грудь
	    {ITEMTYPE_ARMOR, EQUIP_TYPE_HAND, GetString("SI_EQUIPTYPE", EQUIP_TYPE_HAND), TRUE,
	     "/SwissKnife/textures/apparel/hand.dds", {155, 79}}, -- Руки
	    {ITEMTYPE_ARMOR, EQUIP_TYPE_WAIST, GetString("SI_EQUIPTYPE", EQUIP_TYPE_WAIST), TRUE,
	     "/SwissKnife/textures/apparel/waist.dds", {310, 79}}, -- Талия
	    {ITEMTYPE_ARMOR, EQUIP_TYPE_LEGS, GetString("SI_EQUIPTYPE", EQUIP_TYPE_LEGS), TRUE,
	     "/SwissKnife/textures/apparel/legs.dds", {465, 79}}, -- Ноги
	    {ITEMTYPE_ARMOR, EQUIP_TYPE_FEET, GetString("SI_EQUIPTYPE", EQUIP_TYPE_FEET), TRUE,
	     "/SwissKnife/textures/apparel/feet.dds", {620, 79}}, -- Стопы
	    {ITEMTYPE_ARMOR, EQUIP_TYPE_NECK, GetString("SI_EQUIPTYPE", EQUIP_TYPE_NECK), FALSE,
	     "/SwissKnife/textures/apparel/neck.dds", {0, 114}}, -- Шея
	    {ITEMTYPE_ARMOR, EQUIP_TYPE_RING, GetString("SI_EQUIPTYPE", EQUIP_TYPE_RING), FALSE,
	     "/SwissKnife/textures/apparel/ring.dds", {155, 114}}, -- Кольцо
	    {ITEMTYPE_WEAPON, WEAPONTYPE_AXE, GetString("SI_WEAPONTYPE", WEAPONTYPE_AXE), TRUE,
	     "/SwissKnife/textures/weapons/axe.dds", {0, 160}}, -- Топор
	    {ITEMTYPE_WEAPON, WEAPONTYPE_HAMMER, GetString("SI_WEAPONTYPE", WEAPONTYPE_HAMMER), TRUE,
	     "/SwissKnife/textures/weapons/hammer.dds", {155, 160}}, -- Молот
	    {ITEMTYPE_WEAPON, WEAPONTYPE_SWORD, GetString("SI_WEAPONTYPE", WEAPONTYPE_SWORD), TRUE,
	     "/SwissKnife/textures/weapons/sword.dds", {310, 160}}, -- Меч
	    {ITEMTYPE_WEAPON, WEAPONTYPE_DAGGER, GetString("SI_WEAPONTYPE", WEAPONTYPE_DAGGER), TRUE,
	     "/SwissKnife/textures/weapons/dagger.dds", {465, 160}}, -- Кинжал
	    {ITEMTYPE_WEAPON, WEAPONTYPE_SHIELD, GetString("SI_WEAPONTYPE", WEAPONTYPE_SHIELD), TRUE,
	     "/SwissKnife/textures/apparel/shield.dds", {620, 160}}, -- Щит
	    {ITEMTYPE_WEAPON, WEAPONTYPE_TWO_HANDED_AXE, GetString("SI_WEAPONTYPE", WEAPONTYPE_TWO_HANDED_AXE).." "..GetString(SI_SK_INFO_WEAPON_TWO_HANDED), TRUE,
	     "/SwissKnife/textures/weapons/th_axe.dds", {0, 206}}, -- Топор двуруч
	    {ITEMTYPE_WEAPON, WEAPONTYPE_TWO_HANDED_HAMMER, GetString("SI_WEAPONTYPE", WEAPONTYPE_TWO_HANDED_HAMMER).." "..GetString(SI_SK_INFO_WEAPON_TWO_HANDED), TRUE,
	     "/SwissKnife/textures/weapons/th_hammer.dds", {167, 206}}, -- Молот двуруч
	    {ITEMTYPE_WEAPON, WEAPONTYPE_TWO_HANDED_SWORD, GetString("SI_WEAPONTYPE", WEAPONTYPE_TWO_HANDED_SWORD).." "..GetString(SI_SK_INFO_WEAPON_TWO_HANDED), TRUE,
	     "/SwissKnife/textures/weapons/th_sword.dds", {334, 206}}, -- Меч двуруч
	    {ITEMTYPE_WEAPON, WEAPONTYPE_BOW, GetString("SI_WEAPONTYPE", WEAPONTYPE_BOW), TRUE,
	     "/SwissKnife/textures/weapons/bow.dds", {499, 206}}, -- Лук
	    {ITEMTYPE_WEAPON, WEAPONTYPE_FIRE_STAFF, GetString("SI_WEAPONTYPE", WEAPONTYPE_FIRE_STAFF), TRUE,
	     "/SwissKnife/textures/weapons/fire_staff.dds", {0, 241}}, -- Посох огня
	    {ITEMTYPE_WEAPON, WEAPONTYPE_FROST_STAFF, GetString("SI_WEAPONTYPE", WEAPONTYPE_FROST_STAFF), TRUE,
	     "/SwissKnife/textures/weapons/ice_staff.dds", {167, 241}}, -- Посох льда
	    {ITEMTYPE_WEAPON, WEAPONTYPE_LIGHTNING_STAFF, GetString("SI_WEAPONTYPE", WEAPONTYPE_LIGHTNING_STAFF), TRUE,
	     "/SwissKnife/textures/weapons/lightning_staff.dds", {334, 241}}, -- Посох молний
	    {ITEMTYPE_WEAPON, WEAPONTYPE_HEALING_STAFF, GetString("SI_WEAPONTYPE", WEAPONTYPE_HEALING_STAFF), TRUE,
	     "/SwissKnife/textures/weapons/healing_staff.dds", {499, 241}}, -- Хил посох
	},
	EQUIPMENT_SLOTS = {
	    {EQUIP_SLOT_MAIN_HAND, "MainHand", true},
	    {EQUIP_SLOT_OFF_HAND,"OffHand", true},
	    {EQUIP_SLOT_BACKUP_MAIN,"BackupMain", false},
	    {EQUIP_SLOT_BACKUP_OFF, "BackupOff", false},
	    {EQUIP_SLOT_HEAD, "Head", true},
	    {EQUIP_SLOT_CHEST, "Chest", true},
	    {EQUIP_SLOT_LEGS, "Leg", true},
	    {EQUIP_SLOT_SHOULDERS, "Shoulder", true},
	    {EQUIP_SLOT_FEET, "Foot", true},
	    {EQUIP_SLOT_WAIST, "Belt", true},
	    {EQUIP_SLOT_HAND, "Glove", true},
	    {EQUIP_SLOT_NECK, "Neck", true},
	    {EQUIP_SLOT_RING1, "Ring1", true},
	    {EQUIP_SLOT_RING2, "Ring2", true}
	},
	IGNORE_EQUIPMENT_SLOTS = {EQUIP_SLOT_COSTUME, EQUIP_SLOT_POISON, EQUIP_SLOT_BACKUP_POISON},
	CONTEXT_MENU_SLOTS = {
		-- SLOT_TYPE_QUEST_ITEM,
		SLOT_TYPE_ITEM,
		SLOT_TYPE_EQUIPMENT,
		SLOT_TYPE_MY_TRADE,
		SLOT_TYPE_THEIR_TRADE,
		--SLOT_TYPE_STORE_BUY,
		--SLOT_TYPE_STORE_BUYBACK,
		--SLOT_TYPE_BUY_MULTIPLE,
		SLOT_TYPE_BANK_ITEM,
		SLOT_TYPE_GUILD_BANK_ITEM,
		SLOT_TYPE_MAIL_QUEUED_ATTACHMENT,
		SLOT_TYPE_MAIL_ATTACHMENT,
		-- SLOT_TYPE_LOOT,
		-- SLOT_TYPE_ACHIEVEMENT_REWARD,
		-- SLOT_TYPE_PENDING_CHARGE,
		-- SLOT_TYPE_ENCHANTMENT,
		-- SLOT_TYPE_ENCHANTMENT_RESULT,
		--SLOT_TYPE_TRADING_HOUSE_POST_ITEM,
		--SLOT_TYPE_TRADING_HOUSE_ITEM_RESULT,
		--SLOT_TYPE_TRADING_HOUSE_ITEM_LISTING,
		-- SLOT_TYPE_REPAIR,
		-- SLOT_TYPE_PENDING_REPAIR,
		-- SLOT_TYPE_STACK_SPLIT,
		 SLOT_TYPE_CRAFTING_COMPONENT,
		-- SLOT_TYPE_PENDING_CRAFTING_COMPONENT,
		-- SLOT_TYPE_MULTIPLE_PENDING_CRAFTING_COMPONENTS,
		-- SLOT_TYPE_SMITHING_MATERIAL,
		-- SLOT_TYPE_SMITHING_STYLE,
		-- SLOT_TYPE_SMITHING_TRAIT,
		-- SLOT_TYPE_SMITHING_BOOSTER,
		-- SLOT_TYPE_LIST_DIALOG_ITEM,
		-- SLOT_TYPE_DYEABLE_EQUIPMENT,
		-- SLOT_TYPE_GUILD_SPECIFIC_ITEM,
		-- SLOT_TYPE_LAUNDER,
		-- SLOT_TYPE_GAMEPAD_INVENTORY_ITEM,
		-- SLOT_TYPE_COLLECTIONS_INVENTORY,
		-- SLOT_TYPE_CRAFT_BAG_ITEM,
		-- SLOT_TYPE_PENDING_RETRAIT_ITEM,
	},
	TWO_HANDED = {
		WEAPONTYPE_TWO_HANDED_AXE,
		WEAPONTYPE_TWO_HANDED_HAMMER,
		WEAPONTYPE_TWO_HANDED_SWORD
	},
	ITEM_PRESETS = {
	    [0] = {
	        itemType = ITEMTYPE_ARMOR,
	        equipTypes = {
	            EQUIP_TYPE_HEAD, EQUIP_TYPE_SHOULDERS, EQUIP_TYPE_CHEST, EQUIP_TYPE_HAND, EQUIP_TYPE_WAIST,
	            EQUIP_TYPE_LEGS, EQUIP_TYPE_FEET
	        }
	    },
	    [1] = {
	        itemType = ITEMTYPE_ARMOR,
	        equipTypes = {
	            EQUIP_TYPE_NECK, EQUIP_TYPE_RING,
	        }
	    },
	    [2] = {
	        itemType = ITEMTYPE_WEAPON,
	        equipTypes = {
	            WEAPONTYPE_AXE, WEAPONTYPE_HAMMER, WEAPONTYPE_SWORD, WEAPONTYPE_DAGGER, WEAPONTYPE_SHIELD
	        }
	    },
	    [3] = {
	        itemType = ITEMTYPE_WEAPON,
	        equipTypes = {
	            WEAPONTYPE_TWO_HANDED_AXE, WEAPONTYPE_TWO_HANDED_HAMMER, WEAPONTYPE_TWO_HANDED_SWORD, WEAPONTYPE_BOW
	        }
	    },
	    [4] = {
	        itemType = ITEMTYPE_WEAPON,
	        equipTypes = {
	            WEAPONTYPE_FIRE_STAFF, WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF, WEAPONTYPE_HEALING_STAFF
	        }
	    },
	}
}