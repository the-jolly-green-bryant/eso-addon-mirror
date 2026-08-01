BSCASynergy = BSCASynergy or {}
local BSCAS = BSCASynergy
-- AddonInfo
BSCAS.Author = "@BloodStainChild666"
BSCAS.VersionDisplay = "2.3.8"

BSCAS.color_red		= "|cFF0000"
BSCAS.color_green	= "|c47FF47"
------------------------------------------------------------------------------
-- UI Update
------------------------------------------------------------------------------
BSCAS.UPDATE_INTERVAL = 100 -- ms
------------------------------------------------------------------------------
-- UI Hotkeys
------------------------------------------------------------------------------
ZO_CreateStringId("SI_BINDING_NAME_BSCAS_PORTAL", "Enable/Disable Portals &amp; Toggle all Portals (CR, SS, KA)")
ZO_CreateStringId("SI_BINDING_NAME_BSCAS_OPEN_MENU", "Open Addon Settings")
------------------------------------------------------------------------------
-- Synergie Data for blocking and tracking /script SetCVar("language.2","en")
------------------------------------------------------------------------------
local Synergie_NamesDesc = {
	-- UNDAUNTED
	SI_SYNERGY_NAME_BLOODALTAR 		= zo_strformat("<<1>>", GetAbilityName(39489)),				-- Altar
	SI_SYNERGY_DESC_BLOODALTAR 		= zo_strformat("<<1>>", GetAbilityDescription(39489)),		-- Altar
	SI_SYNERGY_NAME_WEBS			= zo_strformat("<<1>>", GetAbilityName(39425)), 			-- Trapping Webs
	SI_SYNERGY_DESC_WEBS 			= zo_strformat("<<1>>", GetAbilityDescription(39425)),		-- Shadow webs	
	SI_SYNERGY_NAME_INNERFIRE		= zo_strformat("<<1>>", GetAbilityName(39475)), 			--"Inner Fire"
	SI_SYNERGY_DESC_INNERFIRE		= zo_strformat("<<1>>", GetAbilityDescription(39475)),
	SI_SYNERGY_NAME_BONE			= zo_strformat("<<1>>", GetAbilityName(39369)), 			--"Bone Shield"
	SI_SYNERGY_DESC_BONE			= zo_strformat("<<1>>", GetAbilityDescription(39369)),
	SI_SYNERGY_NAME_ORB 			= zo_strformat("<<1>>", GetAbilityName(42028)), 			--"Mystic Orb")
	SI_SYNERGY_DESC_ORB 			= zo_strformat("<<1>>", GetAbilityDescription(42028)),
	SI_SYNERGY_NAME_ORB2			= zo_strformat("<<1>>", GetAbilityName(42038)), 			-- "Energy Orb")
	SI_SYNERGY_DESC_ORB2			= zo_strformat("<<1>>", GetAbilityDescription(42038)),
	SI_SYNERGY_NAME_SHARDS	 		= zo_strformat("<<1>>", GetAbilityName(26869)), 			--Blazing Spear
	SI_SYNERGY_DESC_SHARDS			= zo_strformat("<<1>>", GetAbilityDescription(26869)),
	SI_SYNERGY_NAME_TREE_TEMPLAR	= zo_strformat("<<1>>", GetAbilityName(91132)), 			--Templar
	SI_SYNERGY_NAME_SHARDS1			= zo_strformat("<<1>>", GetAbilityName(26858)), 			--Luminous Shards
	SI_SYNERGY_DESC_SHARDS1	 		= zo_strformat("<<1>>", GetAbilityDescription(26858)),
	SI_SYNERGY_NAME_PURGE	 		= zo_strformat("<<1>>", GetAbilityName(22265)), -- Cleansing Ritual
	SI_SYNERGY_DESC_PURGE	 		= zo_strformat("<<1>>", GetAbilityDescription(22265)),
	SI_SYNERGY_NAME_NOVA			= zo_strformat("<<1>>", GetAbilityName(21752)), --Nova
	SI_SYNERGY_DESC_NOVA 			= zo_strformat("<<1>>", GetAbilityDescription(21752)),
	SI_SYNERGY_NAME_TREE_SORC		= zo_strformat("<<1>>", GetAbilityName(91349)), --"Sorcerer")
	SI_SYNERGY_NAME_ATRO			= zo_strformat("<<1>>", GetAbilityName(23492)), --"Atronach")
	SI_SYNERGY_DESC_ATRO			= zo_strformat("<<1>>", GetAbilityDescription(23492)),
	SI_SYNERGY_NAME_CONDUIT			= zo_strformat("<<1>>", GetAbilityName(23182)), --"Lightning")
	SI_SYNERGY_DESC_CONDUIT			= zo_strformat("<<1>>", GetAbilityDescription(23182)),
	SI_SYNERGY_NAME_TREE_DK			= zo_strformat("<<1>>", GetAbilityName(172701)),
	SI_SYNERGY_NAME_IMPALE			= zo_strformat("<<1>>", GetAbilityName(20245)), --"Dark Talons"
	SI_SYNERGY_DESC_IMPALE			= zo_strformat("<<1>>", GetAbilityDescription(20245)),
	SI_SYNERGY_NAME_STANDARTE		= zo_strformat("<<1>>", GetAbilityName(28988)), --"Dragonknight-Standard")
	SI_SYNERGY_DESC_STANDARTE		= zo_strformat("<<1>>", GetAbilityDescription(28988)),
	SI_SYNERGY_NAME_TREE_NB			= zo_strformat("<<1>>", GetAbilityName(91130)), --"Nightblade")
	SI_SYNERGY_NAME_DARK			= zo_strformat("<<1>>", GetAbilityName(25411)), --"Consuming Darkness")
	SI_SYNERGY_DESC_DARK			= zo_strformat("<<1>>", GetAbilityDescription(25411)),
	SI_SYNERGY_NAME_SOUL			= zo_strformat("<<1>>", GetAbilityName(25091)), --"Soul Shred")
	SI_SYNERGY_DESC_SOUL			= zo_strformat("<<1>>", GetAbilityDescription(25091)),
	SI_SYNERGY_NAME_TREE_WARDN		= zo_strformat("<<1>>", GetAbilityName(91351)), --"Warden")
	SI_SYNERGY_NAME_HARVEST			= zo_strformat("<<1>>", GetAbilityName(85578)), --"Healing Seed")
	SI_SYNERGY_DESC_HARVEST			= zo_strformat("<<1>>", GetAbilityDescription(85578)),
	SI_SYNERGY_NAME_ICYESC			= zo_strformat("<<1>>", GetAbilityName(86183)), --"Frozen Retreat")
	SI_SYNERGY_DESC_ICYESC			= zo_strformat("<<1>>", GetAbilityDescription(86183)),
	SI_SYNERGY_NAME_TREE_NECRO		= zo_strformat("<<1>>", GetAbilityName(172703)),
	SI_SYNERGY_NAME_BONEYARD		= zo_strformat("<<1>>", GetAbilityName(115252)), --"Boneyard")
	SI_SYNERGY_DESC_BONEYARD		= zo_strformat("<<1>>", GetAbilityDescription(115252)),
	SI_SYNERGY_NAME_TOTEM			= zo_strformat("<<1>>", GetAbilityName(118404)), --"Agony Totem")
	SI_SYNERGY_DESC_TOTEM			= zo_strformat("<<1>>", GetAbilityDescription(118404)),
	SI_SYNERGY_NAME_TREE_ARCANIST	= zo_strformat("<<1>>", GetAbilityName(59577)), --"Arcanist"
	SI_SYNERGY_NAME_RUNE			= zo_strformat("<<1>>", GetAbilityName(182988)), --"Fulminating Rune"
	SI_SYNERGY_DESC_RUNE			= zo_strformat("<<1>>", GetAbilityDescription(182988)), --"Fulminating Rune"
	SI_SYNERGY_NAME_PORTAL			= zo_strformat("<<1>>", GetAbilityName(186220)), --"Passage Between Worlds"
	SI_SYNERGY_DESC_PORTAL			= zo_strformat("<<1>>", GetAbilityDescription(186220)), --"Passage Between Worlds"
	SI_SYNERGY_NAME_TREE_VAMP		= zo_strformat("<<1>>", GetAbilityName(44134)), --"Vampire"
	SI_SYNERGY_DESC_EAT				= zo_strformat("<<1>>", GetAbilityDescription(40349)),
	SI_SYNERGY_NAME_TREE_WOLF		= zo_strformat("<<1>>", GetAbilityName(32455)), --"Werwolf")
	SI_SYNERGY_NAME_FEEDING_FRENZY	= zo_strformat("<<1>>", GetAbilityName(58775)), --"")
	SI_SYNERGY_DESC_FEEDING_FRENZY	= zo_strformat("<<1>>", GetAbilityDescription(32633)),
	SI_SYNERGY_NAME_DEVOUR			= zo_strformat("<<1>>", GetAbilityName(33208)),
	SI_SYNERGY_DESC_DEVOUR			= zo_strformat("<<1>>", GetAbilityDescription(39050)),
	SI_SYNERGY_NAME_TREE_BH			= zo_strformat("<<1>>", GetAbilityName(15273)),
	SI_SYNERGY_DESC_TREE_BH			= zo_strformat("<<1>>", GetAbilityDescription(15273)),
	SI_SYNERGY_NAME_ARENA	 		= zo_strformat("<<1>> + <<2>>", GetZoneNameById(677), GetZoneNameById(1082)),
	SI_SYNERGY_NAME_RESURRECTION	= zo_strformat("<<1>>", GetAbilityName(112909)), --"Resurrection") -- res sigil
	SI_SYNERGY_DESC_RESURRECTION	= zo_strformat("<<1>>", GetAbilityDescription(112909)),
	SI_SYNERGY_NAME_DEFENSE			= zo_strformat("<<1>>", GetAbilityName(117455)), --"Defense") -- defense sigil
	SI_SYNERGY_DESC_DEFENSE			= zo_strformat("<<1>>", GetAbilityDescription(117455)),
	SI_SYNERGY_NAME_HEALING			= zo_strformat("<<1>>", GetAbilityName(117451)), --"Healing") -- healing sigil
	SI_SYNERGY_DESC_HEALING			= zo_strformat("<<1>>", GetAbilityDescription(117451)),
	SI_SYNERGY_NAME_SUSTAIN			= zo_strformat("<<1>>", GetAbilityName(112874)), --"Sustain") -- sustain sigil
	SI_SYNERGY_DESC_SUSTAIN			= zo_strformat("<<1>>", GetAbilityDescription(112874)),
	SI_SYNERGY_NAME_POWER			= zo_strformat("<<1>>", GetAbilityName(117453)), --"Power") -- damage sigil
	SI_SYNERGY_DESC_POWER			= zo_strformat("<<1>>", GetAbilityDescription(117453)),
	SI_SYNERGY_NAME_HASTE			= zo_strformat("<<1>>", GetAbilityName(117449)), --"Haste") -- speed sigil
	SI_SYNERGY_DESC_HASTE			= zo_strformat("<<1>>", GetAbilityDescription(117449)),
	SI_SYNERGY_DESC_GATEWAY			= zo_strformat("<<1>>", GetAbilityDescription(103489)),
	SI_SYNERGY_ALERT_HRC					= "Press Confirm to enable the synergy",
	SI_SYNERGY_NAME_DESTRUCTIVE_OUTBREAK	= "Outbreak UI",
	SI_SYNERGY_DESC_TIME_BREACH				= zo_strformat("<<1>>", GetAbilityDescription(121216)),
	SI_SYNERGY_DESC_KA_PORTAL				= zo_strformat("<<1>>", GetAbilityDescription(134016)),
	SI_SYNERGY_DESC_KA_EXECRATION	 		= zo_strformat("<<1>>", GetAbilityDescription(129936)), -- Execration
	SI_SYNERGY_DESC_DSR_SURGING_WATERS		= zo_strformat("<<1>>", GetAbilityDescription(163547)),
	SI_SYNERGY_DESC_SE_VANTONS_CLARITY		= "Portal First Boss",
	SI_SYNERGY_DESC_SE_ATTUNEMENT			= "Activate Portal last Boss",
	SI_SYNERGY_DESC_LC_MIRROR				= "Mirror Drain Debuff",
	SI_SYNERGY_DESC_OC_CARRIONSHIELD		= "Debuff Second Boss in OC",
	SI_SYNERGY_DESC_OC_DREADFUL_PORTAL		= "Miniboss Portal in OC",
	SI_SYNERGY_ITEM_NAME_URSUS				= zo_strformat("<<1>>", GetAbilityName(111432)),
	SI_SYNERGY_ITEM_DESC_URSUS				= zo_strformat("<<1>>", GetAbilityDescription(111432)),
	SI_SYNERGY_ITEM_NAME_KRAGLEN			= zo_strformat("<<1>>", GetAbilityName(142686)),
	SI_SYNERGY_ITEM_DESC_KRAGLEN			= zo_strformat("<<1>>", GetAbilityDescription(142686)),
	SI_SYNERGY_ITEM_NAME_SANGUINE			= zo_strformat("<<1>>", GetAbilityName(141897)),
	SI_SYNERGY_ITEM_DESC_SANGUINE			= zo_strformat("<<1>>", GetAbilityDescription(141897)),
	SI_SYNERGY_ITEM_NAME_GPREPRISAL			= zo_strformat("<<1>>", GetAbilityName(167041)),
	SI_SYNERGY_ITEM_DESC_GPREPRISAL			= zo_strformat("<<1>>", GetAbilityDescription(167041)),	
}
for key, value in pairs(Synergie_NamesDesc) do
	SafeAddVersion(key, 1)
	ZO_CreateStringId(key, value)
end

local Synergie_Abilitys = {
	SI_SYNERGY_ABILITY_BLOODALTAR1 		= zo_strformat("<<1>>", GetAbilityName(41963)), -- "Blood Feast"
	SI_SYNERGY_ABILITY_BLOODALTAR2	 	= zo_strformat("<<1>>", GetAbilityName(39500)), --"Blood Funnel"
	SI_SYNERGY_ABILITY_BLACK_WIDOWS1 	= zo_strformat("<<1>>", GetAbilityName(42020)), --"Arachnophobia"
	SI_SYNERGY_ABILITY_BLACK_WIDOWS2 	= zo_strformat("<<1>>", GetAbilityName(41994)), --"Black Widow"
	SI_SYNERGY_ABILITY_INNERFIRE		= zo_strformat("<<1>>", GetAbilityName(41839)), --"Radiate"
	SI_SYNERGY_ABILITY_BONE1			= zo_strformat("<<1>>", GetAbilityName(39377)), -- "Bone Wall"
	SI_SYNERGY_ABILITY_BONE2			= zo_strformat("<<1>>", GetAbilityName(42198)), --"Spinal Surge"
	SI_SYNERGY_ABILITY_ORB1				= zo_strformat("<<1>>", GetAbilityName(39301)), -- "Combustion"
	SI_SYNERGY_ABILITY_ORB2				= zo_strformat("<<1>>", GetAbilityName(63507)), --Healing Combustion
	SI_SYNERGY_ABILITY_SHARDS1			= zo_strformat("<<1>>", GetAbilityName(95922)), 
	SI_SYNERGY_ABILITY_SHARDS2			= zo_strformat("<<1>>", GetAbilityName(26832)),
	SI_SYNERGY_ABILITY_PURGE			= zo_strformat("<<1>>", GetAbilityName(22269)), --Purify
	SI_SYNERGY_ABILITY_NOVA1			= zo_strformat("<<1>>", GetAbilityName(31562)), --Supernova
	SI_SYNERGY_ABILITY_NOVA2			= zo_strformat("<<1>>", GetAbilityName(34443)), --Gravity Crush
	SI_SYNERGY_ABILITY_ATRO				= zo_strformat("<<1>>", GetAbilityName(48076)), --"Charged Lightning")
	SI_SYNERGY_ABILITY_CONDUIT			= zo_strformat("<<1>>", GetAbilityName(23196)), --"Conduit")	
	SI_SYNERGY_ABILITY_IMPALE			= zo_strformat("<<1>>", GetAbilityName(32974)), --"Ignite"
	SI_SYNERGY_ABILITY_STANDARTE		= zo_strformat("<<1>>", GetAbilityName(32910)), --"Shackle")
	SI_SYNERGY_ABILITY_DARK				= zo_strformat("<<1>>", GetAbilityName(37729)), --"Hidden Refresh")
	SI_SYNERGY_ABILITY_SOUL				= zo_strformat("<<1>>", GetAbilityName(25170)), --"Soul Leech")	
	SI_SYNERGY_ABILITY_HARVEST			= zo_strformat("<<1>>", GetAbilityName(85572)), --"Harvest") -- /script d(GetAbilityName(85572)) /script d(GetAbilityName(85583)) /script SetCVar("language.2","en")
	SI_SYNERGY_ABILITY_ICYESC			= zo_strformat("<<1>>", GetAbilityName(88884)), --"Icy Escape")
	SI_SYNERGY_ABILITY_BONEYARD			= zo_strformat("<<1>>", GetAbilityName(115548)), --"Grave Robber" -- /script d(GetAbilityName(115548)) /script d(GetAbilityName(115567))
	SI_SYNERGY_ABILITY_TOTEM			= zo_strformat("<<1>>", GetAbilityName(118618)), --"Pure Agony"
	SI_SYNERGY_ABILITY_RUNE				= zo_strformat("<<1>>", GetAbilityName(191078)), --"Runebreak"
	SI_SYNERGY_ABILITY_PORTAL			= zo_strformat("<<1>>", GetAbilityName(190395)), --"Passage"
	SI_SYNERGY_ABILITY_EAT				= zo_strformat("<<1>>", GetAbilityName(40349)), --"Feed"
	SI_SYNERGY_ABILITY_HUNT				= zo_strformat("<<1>>", GetAbilityName(58775)), --"Feeding Frenzy"
	SI_SYNERGY_ABILITY_DEVOUR			= zo_strformat("<<1>>", GetAbilityName(33208)), --"Devour"
	SI_SYNERGY_ABILITY_BH				= zo_strformat("<<1>>", GetAbilityName(76325)),	
	SI_SYNERGY_SIGIL_RESURRECTION		= zo_strformat("<<1>>", GetAbilityName(112909)), --"Sigil of Resurrection") -- res sigil
	SI_SYNERGY_SIGIL_DEFENSE			= zo_strformat("<<1>>", GetAbilityName(117455)), --"Sigil of Defense") -- defense sigil
	SI_SYNERGY_SIGIL_HEALING			= zo_strformat("<<1>>", GetAbilityName(117451)), --"Sigil of Healing") -- healing sigil
	SI_SYNERGY_SIGIL_SUSTAIN			= zo_strformat("<<1>>", GetAbilityName(112874)), --"Sigil of Sustain") -- sustain sigil
	SI_SYNERGY_SIGIL_POWER				= zo_strformat("<<1>>", GetAbilityName(117453)), --"Sigil of Power") -- damage sigil
	SI_SYNERGY_SIGIL_HASTE				= zo_strformat("<<1>>", GetAbilityName(117449)), --"Sigil of Haste") -- speed sigil
	SI_SYNERGY_ABILITY_GATEWAY			= zo_strformat("<<1>>", GetAbilityName(103489)), --"Gateway") 	
	SI_SYNERGY_ABILITY_DESTRUCTIVE_OUTBREAK	= zo_strformat("<<1>>", GetAbilityName(56667)), --"Destructive Outbreak") 
	SI_SYNERGY_ABILITY_TIME_BREACH			= zo_strformat("<<1>>", GetAbilityName(121216)), --"Time Breach") -- ss last boss portal
	SI_SYNERGY_ABILITY_KA_PORTAL			= zo_strformat("<<1>>", GetAbilityName(134005)), -- 134016 -134005 
	SI_SYNERGY_ABILITY_KA_EXECRATION		= zo_strformat("<<1>>", GetAbilityName(129936)),
	SI_SYNERGY_ABILITY_RG_BLOP				= zo_strformat("<<1>>", GetAbilityName(153034)),
	SI_SYNERGY_ABILITY_DSR_SURGING_WATERS	= zo_strformat("<<1>>", GetAbilityName(163547)),
	SI_SYNERGY_ABILITY_SE_VANTONS_CLARITY	= zo_strformat("<<1>>", GetAbilityName(188089)), -- 10 sec portal
	SI_SYNERGY_ABILITY_SE_ATTUNEMENT		= zo_strformat("<<1>>", GetAbilityName(186057)), -- 
	SI_SYNERGY_ABILITY_URSUS				= zo_strformat("<<1>>", GetAbilityName(111437)),
	SI_SYNERGY_ABILITY_KRAGLEN				= zo_strformat("<<1>>", GetAbilityName(142712)),
	SI_SYNERGY_ABILITY_SANGUINE				= zo_strformat("<<1>>", GetAbilityName(141920)),
	SI_SYNERGY_ABILITY_GPREPRISAL			= zo_strformat("<<1>>", GetAbilityName(167044)),	
	SI_SYNERGY_ABILITY_LC_MIRROR			= zo_strformat("<<1>>", GetAbilityName(213069)),
	SI_SYNERGY_ABILITY_OC_CARRIONSHIELD		= zo_strformat("<<1>>", GetAbilityName(237744)),  	-- OC
	SI_SYNERGY_ABILITY_OC_DREADFUL_PORTAL	= zo_strformat("<<1>>", GetAbilityName(248537)),	-- OC
}
for key, value in pairs(Synergie_Abilitys) do
	SafeAddVersion(key, 1)
	ZO_CreateStringId(key, value)
end

------------------------------------------------------------------------------
-- Icons
------------------------------------------------------------------------------
ICON_UNDAUNTED_ALTAR_0 	= zo_strformat("<<1>>", GetAbilityIcon(39489)) 	-- Altar
ICON_UNDAUNTED_WEBS_0 	= zo_strformat("<<1>>", GetAbilityIcon(39425)) 	-- Witwenbrut
ICON_UNDAUNTED_FIRE_0 	= zo_strformat("<<1>>", GetAbilityIcon(39475)) 	-- Strahlung	
ICON_UNDAUNTED_BONE_0 	= zo_strformat("<<1>>", GetAbilityIcon(39377)) 	-- Knochenwand
ICON_UNDAUNTED_ORB_0 	= zo_strformat("<<1>>", GetAbilityIcon(42028))  -- Verbrennung/Combustion	
ICON_UNDAUNTED_ORB_2 	= zo_strformat("<<1>>", GetAbilityIcon(42038)) 	-- heilende Verbrennung
ICON_TEMPLAR_SPEAR_1 	= zo_strformat("<<1>>", GetAbilityIcon(26858)) 	-- heilige Scherben/Holy Shards
ICON_TEMPLAR_SPEAR_2 	= zo_strformat("<<1>>", GetAbilityIcon(26869)) 	-- gesegnete Scherben/Blessed Shards
ICON_TEMPLAR_RITUAL_0 	= zo_strformat("<<1>>", GetAbilityIcon(22265))  -- Purify
ICON_TEMPLAR_NOVA_0 	= zo_strformat("<<1>>", GetAbilityIcon(21752)) 	-- Supernova
ICON_SORC_ATRO_0 		= zo_strformat("<<1>>", GetAbilityIcon(23492)) 	-- Atronach
ICON_SORC_CONDUIT_0 	= zo_strformat("<<1>>", GetAbilityIcon(23182))  -- Ableiten
ICON_DK_CLAW_0 			= zo_strformat("<<1>>", GetAbilityIcon(20245)) 	-- Entzünden
ICON_NB_HIDE_0 			= zo_strformat("<<1>>", GetAbilityIcon(25411))  -- verborgene Erholung
ICON_NB_SOUL_0 			= zo_strformat("<<1>>", GetAbilityIcon(25091)) 	-- Seelenentzug
ICON_DK_STANDARTE_0 	= zo_strformat("<<1>>", GetAbilityIcon(28988)) 	-- Fessel	
ICON_WARDEN_HARVEST_0 	= zo_strformat("<<1>>", GetAbilityIcon(85578)) 	-- Ernte
ICON_WARDEN_ICE_0 		= zo_strformat("<<1>>", GetAbilityIcon(86183)) 	-- eisige Flucht
ICON_NECRO_GRAVE_0 		= zo_strformat("<<1>>", GetAbilityIcon(115252)) -- Grabräuber
ICON_NECRO_TOTEM_0 		= zo_strformat("<<1>>", GetAbilityIcon(118404)) -- reine Qual
ICON_ARCANIST_RUNE 		= zo_strformat("<<1>>", GetAbilityIcon(191078)) --""
ICON_ARCANIST_PORTAL 	= zo_strformat("<<1>>", GetAbilityIcon(186220)) --"Passage Between Worlds"
ICON_VAMP 				= zo_strformat("<<1>>", GetAbilityIcon(40349))  -- Nähren
ICON_WOLF 				= zo_strformat("<<1>>", GetAbilityIcon(58775))  -- 
ICON_WOLF_DEVOUR 		= zo_strformat("<<1>>", GetAbilityIcon(32634))
ICON_BROTHERHOOD 		= zo_strformat("<<1>>", GetAbilityIcon(76325))	-- Blade of Woe
ICON_ARENA_RESURRECTION = zo_strformat("<<1>>", GetAbilityIcon(112909)) --"/esoui/art/icons/sigil_power_001.dds"
ICON_ARENA_DEFENSE 		= zo_strformat("<<1>>", GetAbilityIcon(117455)) --"/esoui/art/icons/sigil_defense_001.dds"
ICON_ARENA_HEALING 		= zo_strformat("<<1>>", GetAbilityIcon(117451)) --"/esoui/art/icons/sigil_healing_001.dds"
ICON_ARENA_SUSTAIN 		= zo_strformat("<<1>>", GetAbilityIcon(112874)) --"/esoui/art/icons/sigil_speed_001.dds"
ICON_ARENA_SPEED 		= zo_strformat("<<1>>", GetAbilityIcon(112874)) --"/esoui/art/icons/sigil_speed_001.dds"
ICON_ARENA_POWER 		= zo_strformat("<<1>>", GetAbilityIcon(117453)) --"/esoui/art/icons/sigil_power_001.dds"
ICON_VCR_GATE 			= zo_strformat("<<1>>", GetAbilityIcon(103489)) --"/esoui/art/icons/collectible_memento_pearlsummon.dds"
ICON_VSS_TIMESHIFT 		= zo_strformat("<<1>>", GetAbilityIcon(121216)) --"/esoui/art/icons/ability_skeevatontrap.dds" --["Zeitriss"]
ICON_HRC_BREAKOUT 		= zo_strformat("<<1>>", GetAbilityIcon(56694)) --"/esoui/art/icons/ability_mage_065.dds"
ICON_VKA_PORTAL 		= zo_strformat("<<1>>", GetAbilityIcon(134016))
ICON_VKA_EXECRATION 	= zo_strformat("<<1>>", GetAbilityIcon(129936)) -- Execration
ICON_RG_BLOP 			= zo_strformat("<<1>>", GetAbilityIcon(152989))
ICON_DSR_SURGING_WATERS = zo_strformat("<<1>>", GetAbilityIcon(163547))
ICON_SE_VANTONS_CLARITY = zo_strformat("<<1>>", GetAbilityIcon(184041))
ICON_SE_ATTUNEMENT 		= zo_strformat("<<1>>", GetAbilityIcon(186058)) 
ICON_ITEM_URSUS 		= zo_strformat("<<1>>", GetAbilityIcon(111437))
ICON_ITEM_KRAGLEN 		= zo_strformat("<<1>>", GetAbilityIcon(142712))
ICON_ITEM_SANGUINE 		= zo_strformat("<<1>>", GetAbilityIcon(141920))
ICON_ITEM_GPREPRISAL 	= zo_strformat("<<1>>", GetAbilityIcon(167044))
ICON_DSR_DINFESTATION 	= zo_strformat("<<1>>", GetAbilityIcon(166639))
ICON_SE_AGONY 			= zo_strformat("<<1>>", GetAbilityIcon(185792))
ICON_LC_MIRROR			= zo_strformat("<<1>>", GetAbilityIcon(213069))
ICON_OC_CARRIONSHIELD	= zo_strformat("<<1>>", GetAbilityIcon(237744))  	-- OC
ICON_OC_DREADFUL_PORTAL	= zo_strformat("<<1>>", GetAbilityIcon(248537))	-- OC

------------------------------------------------------------------------------
-- Cooldown id's
------------------------------------------------------------------------------
ABILITYID_CD_FEAST_FUNNEL 		= 41966 	-- Blood Feast Cooldown
ABILITYID_CD_BLOOD_FUNNEL 		= 39521 	-- Blood Funnel Cooldown
ABILITYID_CD_INNERFIRE			= 41840		-- Inner fire 
ABILITYID_CD_SPAWNBROODLING		= 39451		-- Spawn Broodling	(unmorphed skill)	
ABILITYID_CD_BLACK_WIDOW 		= 41997 	-- Black Widow Cooldown					
ABILITYID_CD_ARACHNOPHOBIA 		= 42019 	-- Arachnophobia Cooldown	
ABILITYID_CD_RADIATE			= 41840		-- Radiate Cooldown	
ABILITYID_CD_BONE_WALL			= 39424 	-- Bone Wall Cooldown
ABILITYID_CD_SPINALSURGE 		= 42196 	-- Spinal Surge Cooldown 	
ABILITYID_CD_SHARTBUBLE_2		= 85434 	-- Spear Shards / Necrotic Orb CD (Combustion)		
ABILITYID_CD_HEALING_COMBUSTION = 63512		-- Healing Combustion Cooldown
ABILITYID_CD_SHARTBUBLE_3		= 95924 	-- Spear Shards / Necrotic Orb CD 	
ABILITYID_CD_SHARTBUBLE_1		= 48052 	-- Spear Shards / Necrotic Orb CD (Shards)
ABILITYID_CD_PURIFY				= 22270 	-- (Templar) Purify	Cooldown	
ABILITYID_CD_SUPERNOVA			= 48939		-- (Templar) Supernova Cooldown	
ABILITYID_CD_GRAVITY_CRUSH		= 48938		-- (Templar) Gravity Crush Cooldown
ABILITYID_CD_CHARGED_LIGHTNING	= 48085 	-- (Sorc) Charged Lightning Cooldown
ABILITYID_CD_CONDUIT			= 43769 	-- (Sorc) Conduit Cooldown		
ABILITYID_CD_IGNITE 			= 48040		-- (DK) Ignite Cooldown
ABILITYID_CD_SHACKLE			= 67717 	-- (DK) Shackle Cooldown	
ABILITYID_CD_HIDDEN_REFRESH		= 37733 	-- Hidden Refresh Cooldown		
ABILITYID_CD_SOUL_LEECH			= 25172		-- Soul Leech Cooldown					
ABILITYID_CD_HARVEST			= 85576		-- (Warden) Harvest	Cooldown 			
ABILITYID_CD_ICY_ESCAPE			= 88892		-- (Warden) Icy Escape Cooldown			
ABILITYID_CD_GRAVEROBBER		= 115567 	-- (Necro) Grave Robber Cooldown		
ABILITYID_CD_PURE_AGONY			= 118610	-- (Necro) Pure Agony Cooldown		
ABILITYID_CD_RUNE 				= 191080	-- (Arkanist) Rune Cooldown
ABILITYID_CD_PORTAL 			= 190646	-- (Arkanist) Portal Cooldown
ABILITYID_CD_FEEDING_FRENZY		= 58813		-- (Werwolf) Feeding Frenzy Cooldown
ABILITYID_CD_URSUS 				= 111440
ABILITYID_CD_KRAGLEN 			= 142713
ABILITYID_CD_SANGUINE 			= 141971
ABILITYID_CD_GPREPRISAL 		= 167045
ABILITYID_CD_VCRPORTAL			= 104542
ABILITYID_CD_DSR_REEF			= 166639
ABILITYID_CD_SE_AGONY			= 185792 --Agony SE Portal CD
ABILITYID_CD_SE_VANTO_CLARITY   = 188089 --184041
ABILITYID_CD_LC_MIRROR			= 214784
ABILITYID_SYNERGY_ACTIVATE 		= 232750 -- OC
ABILITYID_CD_OC_CARRIONSHIELD	= 237746 -- OC 5 Sec shield
ABILITYID_CD_OC_DREADFUL_PORTAL	= 248539 -- OC

------------------------------------------------------------------------------
BSCAS.VCR_PORT_DBUFF_ID 	= 104542 --Hollowing Torment -- VCR Debuff
BSCAS.HRC_OUTBREAK_DBUFF_ID = 56666 -- using "Remove Stun" (this buff last a few ms longer to avoid show popup again) --56577  	- Stone Form (Main ID of this form)
ABILITYID_RGBLOP 			= 152993 -- Rockgrove
BSCAS.DSR_INFESTATION 		= 166638 -- Trail Dreadsail Reef

BSCAS.OC_CAUSTIC_CARRION_1 	= 240708 -- Trash + Bosses stacks
BSCAS.OC_CAUSTIC_CARRION_2 	= 241089 -- Second Boss stacks
BSCAS.OC_CARRION_PORTAL		= 241091 -- Just Portal
BSCAS.OC_CARRION_PORTAL_2	= 244706 -- Just Portal

-- 232748 -- Trash
-- 237744 -- 2 Boss Portal

-- Tracking recast ids
ABILITYID_URSUS = 111442
ABILITYID_KRAGLEN = 142687
ABILITYID_SANGUINE = 141905
ABILITYID_GPREPRISAL = 167497
--["Sumpfwürze loswerden"] = "/esoui/art/icons/ability_armor_003_a.dds", -- Mazzatun

------------------------------------------------------------------------------
-- Lokke Item for check 
------------------------------------------------------------------------------
BSCAS.LOKKE_ITEM = 
{
	[1] = "|H1:item:151137:363:50:0:0:0:0:0:0:0:0:0:0:0:1:86:0:1:0:10000:0|h|h",
	[2] = "|H1:item:149934:363:50:0:0:0:0:0:0:0:0:0:0:0:1:86:0:1:0:10000:0|h|h",
}
------------------------------------------------------------------------------
-- Lokke ID for MSlayer UI Icon
------------------------------------------------------------------------------
BSCAS.LOKKE_ID = 121871
------------------------------------------------------------------------------
-- Major Slayer ID's for the slayer UI tracking
------------------------------------------------------------------------------
BSCAS.SLAYER_IDS = {
	[93109] = true,		-- 
	[93120] = true,		-- Master Architect
	[93442] = true,		-- War Machine
	[121871] = true, 	-- Tooth of Lokkestiiz
	[135923] = true,	-- Roaring Opportunist
	[137986] = true,	-- Roaring Opportunist
}
------------------------------------------------------------------------------
-- Sets to check
------------------------------------------------------------------------------
BSCAS.B_SETID_N = select(6, GetItemLinkSetInfo("|H0:item:173609:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:122:0:0:0:10000:0|h|h"))
BSCAS.B_SETID_P = select(6, GetItemLinkSetInfo("|H0:item:174440:363:50:0:0:0:0:0:0:0:0:0:0:0:2048:122:0:0:0:10000:0|h|h"))
BSCAS.C_SETID_N = select(6, GetItemLinkSetInfo("|H0:item:186565:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:130:0:0:0:10000:0|h|h"))
BSCAS.C_SETID_P = select(6, GetItemLinkSetInfo("|H0:item:187442:363:50:0:0:0:0:0:0:0:0:0:0:0:2048:130:0:0:0:10000:0|h|h"))
BSCAS.MAKNO = select(6, GetItemLinkSetInfo("|H1:item:95453:364:50:45883:370:50:31:0:0:0:0:0:0:0:1:35:0:1:0:0:0|h|h"))
BSCAS.PEARLSOE = select(6, GetItemLinkSetInfo("|H1:item:171437:364:50:45875:370:50:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"))

------------------------------------------------------------------------------
-- Soundlist 
------------------------------------------------------------------------------
BSCAS.SOUNDLIST = {
	VOICE_CHAT_ALERT_CHANNEL_MADE_ACTIVE        = "Voice_Chat_Alert_Channel_Made_Active",
	VOICE_CHAT_MENU_CHANNEL_MADE_ACTIVE         = "Voice_Chat_Menu_Channel_Made_Active",
	SCRIPTED_WORLD_EVENT_INVITED    			= "Quest_Shared",
	CLOTHIER_EXTRACTED_BOOSTER             	 	= "Clothier_Extracted_Booster",
	DIALOG_DECLINE                 				= "Dialog_Decline",
	RAID_TRIAL_COMPLETED                    	= "Raid_Trial_Completed",
	RETRAITING_RETRAIT_TOOLTIP_GLOW_SUCCESS 	= "Retraiting_Retrait_Tooltip_Glow_Success",
	CONSOLE_GAME_ENTER 							= "Console_Game_Enter",
	AVA_GATE_CLOSED 							= "AvA_Gate_Closed",
	DISPLAY_ANNOUNCEMENT                   	 	= "Display_Announcement",
	BOOK_ACQUIRED                   			= "Book_Acquired",
	KEYBIND_BUTTON_DISABLED                 	= "Keybind_Button_Disabled",
	TELVAR_LOST                     			= "Telvar_Lost",
	TELVAR_GAINED                   			= "Telvar_Gained",
	TELVAR_MULTIPLIERMAX            			= "Telvar_MultiplierMax",
	TELVAR_MULTIPLIERUP             			= "Telvar_MultiplierUp",
	DUEL_INVITE_RECEIVED                        = "Duel_InviteReceived",
    DUEL_ACCEPTED                               = "Duel_Accepted",
    DUEL_START                                  = "Duel_Start",
    DUEL_WON                                    = "Duel_Won",
    DUEL_FORFEIT                                = "Duel_Forfeit",
    DUEL_BOUNDARY_WARNING                       = "Duel_Boundary_Warning",
}

------------------------------------------------------------------------------
-- Alkosh Item for check
------------------------------------------------------------------------------
BSCAS.ALKOSH_ITEM = "|H1:item:73051:364:50:0:0:0:0:0:0:0:0:0:0:0:1:45:0:1:0:10000:0|h|h"
BSCAS.ALKOSH_ITEM_SETID = select(6, GetItemLinkSetInfo(BSCAS.ALKOSH_ITEM))
------------------------------------------------------------------------------
-- Alkosh Debuff ID for Tracking Alkosh UI
------------------------------------------------------------------------------
BSCAS.ALKOSH_DBUFF_ID = 75753 -- line breaker
BSCAS.ALKOSH_DBUFF_ID_2 = 120018
BSCAS.ALKOSH_VALUE = 75752

------------------------------------------------------------------------------
-- Major Berserk id's
------------------------------------------------------------------------------
BSCAS.BERSERK_IDS = {
	[147421] = true,	--  4s
	[150757] = true,	--  5s	
	[188408] = true,	--  5s	
	[36973] = true,		-- 	7s
	[176814] = true,	--  7s
	[62195] = true,		--  8s	
	[84310] = true,		-- 10s
	[137206] = true,	-- 10s
	[134094] = true,	-- 12s
	[134433] = true,	-- 45s	
	[143992] = true,	-- 45s
	[61745] = true,		-- Sorc atro
}

-- Priority system "Known synergys"
BSCAS.SYNERGY_LIST =
{
	[42016] = { priority = 9, zoneid = -1, name = "Arachnophobia" },
	[190401] = { priority = 0, zoneid = -1, name = "Passage" },
	[232066] = { priority = 0, zoneid = 1548, zonename = "Ossein Cage", name = "Carrion Portal" },
	[85572]  = { priority = 7, zoneid = -1, name = "Harvest" },
	[76325]  = { priority = 0, zoneid = -1, name = "Blade of Woe" },
	[191078] = { priority = 9, zoneid = -1, name = "Runebreak" },
	[37729]  = { priority = 7, zoneid = -1, name = "Hidden Refresh" },
	[41994]  = { priority = 9, zoneid = -1, name = "Black Widow" },
	[41963]  = { priority = 7, zoneid = -1, name = "Blood Feast" },
	[48076]  = { priority = 8, zoneid = -1, name = "Charged Lightning" },
	[31538]  = { priority = 9, zoneid = -1, name = "Supernova" },
	[32974]  = { priority = 9, zoneid = -1, name = "Ignite" },
	[63507]  = { priority = 7, zoneid = -1, name = "Healing Combustion" },
	[26832]  = { priority = 8, zoneid = -1, name = "Blessed Shards" },
	[39377]  = { priority = 7, zoneid = -1, name = "Bone Wall" },
	[95922]  = { priority = 8, zoneid = -1, name = "Holy Shards" },
	[31603]  = { priority = 9, zoneid = -1, name = "Gravity Crush" },
	[88884]  = { priority = 8, zoneid = -1, name = "Icy Escape" },
	[115548] = { priority = 9, zoneid = -1, name = "Grave Robber" },
	[39500]  = { priority = 7, zoneid = -1, name = "Blood Funnel" },
	[58775]  = { priority = 8, zoneid = -1, name = "Feeding Frenzy" },
	[118604] = { priority = 9, zoneid = -1, name = "Pure Agony" },
	[32910]  = { priority = 9, zoneid = -1, name = "Shackle" },
	[39301]  = { priority = 8, zoneid = -1, name = "Combustion" },
	[42194]  = { priority = 7, zoneid = -1, name = "Spinal Surge" },
	[23196]  = { priority = 9, zoneid = -1, name = "Conduit" },
	[22269]  = { priority = 7, zoneid = -1, name = "Purify" },
	[41838]  = { priority = 9, zoneid = -1, name = "Radiate" },
	[39429]  = { priority = 9, zoneid = -1, name = "Spawn Broodling" },
}
