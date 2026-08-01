-- global variable where we will keep all addon related
ShowMotifs = {}

--[[ Current style globals and IDs
http://wiki.esoui.com/Constant_Values#ITEMSTYLE_NONE

ITEMSTYLE_NONE                      = 0
ITEMSTYLE_RACIAL_BRETON             = 1
ITEMSTYLE_RACIAL_REDGUARD           = 2
ITEMSTYLE_RACIAL_ORC                = 3
ITEMSTYLE_RACIAL_DARK_ELF           = 4
ITEMSTYLE_RACIAL_NORD               = 5
ITEMSTYLE_RACIAL_ARGONIAN           = 6
ITEMSTYLE_RACIAL_HIGH_ELF           = 7
ITEMSTYLE_RACIAL_WOOD_ELF           = 8
ITEMSTYLE_RACIAL_KHAJIIT            = 9
ITEMSTYLE_UNIQUE                    = 10
ITEMSTYLE_ORG_THIEVES_GUILD         = 11
ITEMSTYLE_ORG_DARK_BROTHERHOOD      = 12
ITEMSTYLE_DEITY_MALACATH            = 13
ITEMSTYLE_AREA_DWEMER               = 14
ITEMSTYLE_AREA_ANCIENT_ELF          = 15
ITEMSTYLE_DEITY_AKATOSH             = 16
ITEMSTYLE_AREA_REACH                = 17
ITEMSTYLE_ENEMY_BANDIT              = 18
ITEMSTYLE_ENEMY_PRIMITIVE           = 19
ITEMSTYLE_ENEMY_DAEDRIC             = 20
ITEMSTYLE_DEITY_TRINIMAC            = 21
ITEMSTYLE_AREA_ANCIENT_ORC          = 22
ITEMSTYLE_ALLIANCE_DAGGERFALL       = 23
ITEMSTYLE_ALLIANCE_EBONHEART        = 24
ITEMSTYLE_ALLIANCE_ALDMERI          = 25
ITEMSTYLE_UNDAUNTED                 = 26
ITEMSTYLE_RAIDS_CRAGLORN            = 27
ITEMSTYLE_GLASS                     = 28
ITEMSTYLE_AREA_XIVKYN               = 29
ITEMSTYLE_AREA_SOUL_SHRIVEN         = 30
ITEMSTYLE_ENEMY_DRAUGR              = 31
ITEMSTYLE_ENEMY_MAORMER             = 32
ITEMSTYLE_AREA_AKAVIRI              = 33
ITEMSTYLE_RACIAL_IMPERIAL           = 34
ITEMSTYLE_AREA_YOKUDAN              = 35
ITEMSTYLE_UNIVERSAL                 = 36
ITEMSTYLE_AREA_REACH_WINTER         = 37
ITEMSTYLE_AREA_TSAESCI              = 38
ITEMSTYLE_ENEMY_MINOTAUR            = 39
ITEMSTYLE_EBONY                     = 40
ITEMSTYLE_ORG_ABAHS_WATCH           = 41
ITEMSTYLE_HOLIDAY_SKINCHANGER       = 42
ITEMSTYLE_ORG_MORAG_TONG            = 43
ITEMSTYLE_AREA_RA_GADA              = 44
ITEMSTYLE_ENEMY_DROMOTHRA           = 45
ITEMSTYLE_ORG_ASSASSINS             = 46
ITEMSTYLE_ORG_OUTLAW                = 47
ITEMSTYLE_ORG_REDORAN               = 48
ITEMSTYLE_ORG_HLAALU                = 49
ITEMSTYLE_ORG_ORDINATOR             = 50
ITEMSTYLE_ORG_TELVANNI              = 51
ITEMSTYLE_ORG_BUOYANT_ARMIGER       = 52
ITEMSTYLE_HOLIDAY_FROSTCASTER       = 53
ITEMSTYLE_AREA_ASHLANDER            = 54
ITEMSTYLE_ORG_WORM_CULT             = 55
ITEMSTYLE_ENEMY_SILKEN_RING         = 56
ITEMSTYLE_ENEMY_MAZZATUN            = 57
ITEMSTYLE_HOLIDAY_GRIM_HARLEQUIN    = 58
ITEMSTYLE_HOLIDAY_HOLLOWJACK        = 59


61 - Bloodforge			Bloodroot Flux				/esoui/art/icons/quest_dragonfire_dust.dds		
62 - Dreadhorn			Minotaur Bezoar				/esoui/art/icons/crafting_style_item_dreadhorn_r2.dds	
65 - Apostle			Tempered Brass				/esoui/art/icons/justice_stolen_prop_sesnits_paperweight.dds	
66 - Ebonshadow			Tenebrous Cord				/esoui/art/icons/crafting_style_item_ebonshadow_r2.dds

69 - Fang Lair			Dragon Bone					/esoui/art/icons/crafting_ore_base_dragonbone_r2.dds
70 - Scalecaller		Infected Flesh				/esoui/art/icons/crafting_outfitter_potion_002.dds
71 - Psijic				Vitrified Malondo			/esoui/art/icons/crafting_leather_nitre.dds
72 - Sapiarch			Culanda Lacquer				/esoui/art/icons/crafting_leather_phlegm.dds
73 - Welkynar			Gryphon Plume				/esoui/art/icons/crafting_style_item_welkynar_r2.dds
74 - Dremora			Warrior's Heart Ashes		/esoui/art/icons/item_warriorsheartashes.dds
75 - Pyandonean			Sea Serpent Hide			/esoui/art/icons/crafting_leather_base_horkerskin_r2.dds

77 - Huntsman			Bloodscent Dew				/esoui/art/icons/crafting_style_item_moonhunter_r2.dds
78 - Silver Dawn		Aegent Pelt					/esoui/art/icons/crafting_style_item_silverdawn_r2.dds
79 - Dead-Water			Crocodile Leather			/esoui/art/icons/crafting_style_item_deadwater_r1.dds
80 - Honor Guard		Red Diamond Seal			/esoui/art/icons/crafting_style_item_honorguard.dds
81 - Elder Argonian		Hackwing Plumage			/esoui/art/icons/crafting_style_item_elderargonian_r2.dds


/script d(GetItemStyleMaterialLink(55))
/script d(GetItemLinkInfo(""))

/script d(GetItemLinkInfo(GetItemStyleMaterialLink(55)))

/script d(GetItemStyleName(38))
/script d(GetItemLinkItemStyle(""))


--]]

-- to add new theme, need to create new element in ShowMotifs.STYLES_TEXTURES and ShowMotifs.ARMOR_TEXTURES with same name(ex: Default)
-- textures for racial motifs
ShowMotifs.STYLES_TEXTURES = {
---------------------------------------------------------------------------------------------------------------------------
-- Icons
---------------------------------------------------------------------------------------------------------------------------
	["Default \(Phinix\)"] = {
		[0] = {
			texture = [[ShowMotifs/bin/themes/Default/monster.dds]],
		},
		[1] = { -- ITEMSTYLE_RACIAL_BRETON
			texture = [[ShowMotifs/bin/themes/Default/breton.dds]],
		},
		[2] = { -- ITEMSTYLE_RACIAL_REDGUARD
			texture = [[ShowMotifs/bin/themes/Default/redguard.dds]],
		},
		[3] = { -- ITEMSTYLE_RACIAL_ORC
			texture = [[ShowMotifs/bin/themes/Default/orsimer.dds]],
		},
		[4] = { -- ITEMSTYLE_RACIAL_DARK_ELF
			texture = [[ShowMotifs/bin/themes/Default/dunmer.dds]],
		},
		[5] = { -- ITEMSTYLE_RACIAL_NORD
			texture = [[ShowMotifs/bin/themes/Default/nord.dds]],
		},
		[6] = { -- ITEMSTYLE_RACIAL_ARGONIAN
			texture = [[ShowMotifs/bin/themes/Default/argonian.dds]],
		},
		[7] = { -- ITEMSTYLE_RACIAL_HIGH_ELF
			texture = [[ShowMotifs/bin/themes/Default/altmer.dds]],
		},
		[8] = { -- ITEMSTYLE_RACIAL_WOOD_ELF
			texture = [[ShowMotifs/bin/themes/Default/bosmer.dds]],
		},
		[9] = { -- ITEMSTYLE_RACIAL_KHAJIIT
			texture = [[ShowMotifs/bin/themes/Default/khajiit.dds]],
		},
--		[10] = { -- ITEMSTYLE_UNIQUE
--			texture = [[ShowMotifs/bin/themes/Default/]],
--		},
		[11] = { -- ITEMSTYLE_ORG_THIEVES_GUILD
			texture = [[ShowMotifs/bin/themes/Default/thieves.dds]],
		},
		[12] = { -- ITEMSTYLE_ORG_DARK_BROTHERHOOD
			texture = [[ShowMotifs/bin/themes/Default/brotherhood.dds]],
		},
		[13] = { -- ITEMSTYLE_DEITY_MALACATH
			texture = [[ShowMotifs/bin/themes/Default/malacath.dds]],
		},
		[14] = { -- ITEMSTYLE_AREA_DWEMER
			texture = [[ShowMotifs/bin/themes/Default/dwemer.dds]],
		},
		[15] = { -- ITEMSTYLE_AREA_ANCIENT_ELF
			texture = [[ShowMotifs/bin/themes/Default/ancientelf.dds]],
		},
		[16] = { -- ITEMSTYLE_DEITY_AKATOSH
			texture = [[ShowMotifs/bin/themes/Default/akatosh.dds]],
		},
		[17] = { -- ITEMSTYLE_AREA_REACH
			texture = [[ShowMotifs/bin/themes/Default/reach.dds]],
		},
		[18] = { -- ITEMSTYLE_ENEMY_BANDIT
			texture = [[ShowMotifs/bin/themes/Default/bandit.dds]],
		},
		[19] = { -- ITEMSTYLE_ENEMY_PRIMITIVE
			texture = [[ShowMotifs/bin/themes/Default/primitive.dds]],
		},
		[20] = { -- ITEMSTYLE_ENEMY_DAEDRIC
			texture = [[ShowMotifs/bin/themes/Default/daedric.dds]],
		},
		[21] = { -- ITEMSTYLE_DEITY_TRINIMAC
			texture = [[ShowMotifs/bin/themes/Default/trinimac.dds]],
		},
		[22] = { -- ITEMSTYLE_AREA_ANCIENT_ORC
			texture = [[ShowMotifs/bin/themes/Default/ancientorc.dds]],
		},
		[23] = { -- ITEMSTYLE_ALLIANCE_DAGGERFALL
			texture = [[ShowMotifs/bin/themes/Default/covenant.dds]],
		},
		[24] = { -- ITEMSTYLE_ALLIANCE_EBONHEART
			texture = [[ShowMotifs/bin/themes/Default/pact.dds]],
		},
		[25] = { -- ITEMSTYLE_ALLIANCE_ALDMERI
			texture = [[ShowMotifs/bin/themes/Default/dominion.dds]],
		},
		[26] = { -- ITEMSTYLE_UNDAUNTED
			texture = [[ShowMotifs/bin/themes/Default/mercenary.dds]],
		},
		[27] = { -- ITEMSTYLE_RAIDS_CRAGLORN
			texture = [[ShowMotifs/bin/themes/Default/craglorn.dds]],
		},
		[28] = { -- ITEMSTYLE_GLASS
			texture = [[ShowMotifs/bin/themes/Default/glass.dds]],
		},
		[29] = { -- ITEMSTYLE_AREA_XIVKYN
			texture = [[ShowMotifs/bin/themes/Default/xivkyn.dds]],
		},
		[30] = { -- ITEMSTYLE_AREA_SOUL_SHRIVEN
			texture = [[ShowMotifs/bin/themes/Default/shriven.dds]],
		},
		[31] = { -- ITEMSTYLE_ENEMY_DRAUGR
			texture = [[ShowMotifs/bin/themes/Default/draugr.dds]],
		},
		[32] = { -- ITEMSTYLE_ENEMY_MAORMER
			texture = [[ShowMotifs/bin/themes/Default/maomer.dds]],
		},
		[33] = { -- ITEMSTYLE_AREA_AKAVIRI
			texture = [[ShowMotifs/bin/themes/Default/akaviri.dds]],
		},
		[34] = { -- ITEMSTYLE_RACIAL_IMPERIAL
			texture = [[ShowMotifs/bin/themes/Default/imperial.dds]],
		},
		[35] = { -- ITEMSTYLE_AREA_YOKUDAN
			texture = [[ShowMotifs/bin/themes/Default/yokudan.dds]],
		},
--		[36] = { -- ITEMSTYLE_UNIVERSAL
--			texture = [[ShowMotifs/bin/themes/Default/]],
--		},
		[37] = { -- ITEMSTYLE_AREA_REACH_WINTER
			texture = [[ShowMotifs/bin/themes/Default/winterreach.dds]],
		},
		[38] = { -- ITEMSTYLE_AREA_TSAESCI
			texture = [[ShowMotifs/bin/themes/Default/tsaesci.dds]],
		},
		[39] = { -- ITEMSTYLE_ENEMY_MINOTAUR
			texture = [[ShowMotifs/bin/themes/Default/minotaur.dds]],
		},
		[40] = { -- ITEMSTYLE_EBONY
			texture = [[ShowMotifs/bin/themes/Default/ebony.dds]],
		},
		[41] = { -- ITEMSTYLE_ORG_ABAHS_WATCH
			texture = [[ShowMotifs/bin/themes/Default/abah.dds]],
		},
		[42] = { -- ITEMSTYLE_HOLIDAY_SKINCHANGER
			texture = [[ShowMotifs/bin/themes/Default/skinchanger.dds]],
		},
		[43] = { -- ITEMSTYLE_ORG_MORAG_TONG
			texture = [[ShowMotifs/bin/themes/Default/moragtong.dds]],
		},
		[44] = { -- ITEMSTYLE_AREA_RA_GADA
			texture = [[ShowMotifs/bin/themes/Default/ragada.dds]],
		},
		[45] = { -- ITEMSTYLE_ENEMY_DROMOTHRA
			texture = [[ShowMotifs/bin/themes/Default/dromathra.dds]],
		},
		[46] = { -- ITEMSTYLE_ORG_ASSASSINS
			texture = [[ShowMotifs/bin/themes/Default/assassin.dds]],
		},
		[47] = { -- ITEMSTYLE_ORG_OUTLAW
			texture = [[ShowMotifs/bin/themes/Default/outlaw.dds]],
		},
		[48] = { -- ITEMSTYLE_ORG_REDORAN
			texture = [[ShowMotifs/bin/themes/Default/redoran.dds]],
		},
		[49] = { -- ITEMSTYLE_ORG_HLAALU
			texture = [[ShowMotifs/bin/themes/Default/hlaalu.dds]],
		},
		[50] = { -- ITEMSTYLE_ORG_ORDINATOR
			texture = [[ShowMotifs/bin/themes/Default/ordinator.dds]],
		},
		[51] = { -- ITEMSTYLE_ORG_TELVANNI
			texture = [[ShowMotifs/bin/themes/Default/telvanni.dds]],
		},
		[52] = { -- ITEMSTYLE_ORG_BUOYANT_ARMIGER
			texture = [[ShowMotifs/bin/themes/Default/armiger.dds]],
		},
		[53] = { -- ITEMSTYLE_HOLIDAY_FROSTCASTER
			texture = [[ShowMotifs/bin/themes/Default/stalhrim.dds]],
		},
		[54] = { -- ITEMSTYLE_AREA_ASHLANDER
			texture = [[ShowMotifs/bin/themes/Default/ashlander.dds]],
		},
		[55] = { -- ITEMSTYLE_ORG_WORM_CULT
			texture = [[ShowMotifs/bin/themes/Default/wormcult.dds]],
		},
		[56] = { -- ITEMSTYLE_ENEMY_SILKEN_RING
			texture = [[ShowMotifs/bin/themes/Default/silken.dds]],
		},
		[57] = { -- ITEMSTYLE_ENEMY_MAZZATUN
			texture = [[ShowMotifs/bin/themes/Default/mazzatun.dds]],
		},
		[58] = { -- ITEMSTYLE_HOLIDAY_GRIM_HARLEQUIN
			texture = [[ShowMotifs/bin/themes/Default/harlequin.dds]],
		},
		[59] = { -- ITEMSTYLE_HOLIDAY_HOLLOWJACK
			texture = [[ShowMotifs/bin/themes/Default/hollowjack.dds]],
		},

		[60] = { -- ITEMSTYLE_REFABRICATED (?)
			texture = [[ShowMotifs/bin/themes/Default/refabricated.dds]],
		},

-- Clockwork City Styles
		[61] = { -- Bloodforge
			texture = [[ShowMotifs/bin/themes/Default/bloodroot.dds]],
		},
		[62] = { -- Dreadhorn
			texture = [[ShowMotifs/bin/themes/Default/dreadhorn.dds]],
		},
		[65] = { -- Apostle
			texture = [[ShowMotifs/bin/themes/Default/apostle.dds]],
		},
		[66] = { -- Ebonshadow
			texture = [[ShowMotifs/bin/themes/Default/ebonshadow.dds]],
		},

-- Should use 0 as all are monster sets
--		[67] = { -- Undaunted
--			texture = [[esoui/art/icons/rep_undaunted_64.dds]],
--		},

-- Morrowind Styles
		[69] = { -- Fang Lair
			texture = [[ShowMotifs/bin/themes/Default/fanglair.dds]],
		},
		[70] = { -- Scalecaller
			texture = [[ShowMotifs/bin/themes/Default/scalecaller.dds]],
		},

-- Summerset Styles
		[71] = { -- Psijic
			texture = [[ShowMotifs/bin/themes/Default/psijic.dds]],
		},
		[72] = { -- Sapiarch
			texture = [[ShowMotifs/bin/themes/Default/sapiarch.dds]],
		},
		[73] = { -- Welkynar
			texture = [[ShowMotifs/bin/themes/Default/welkynar.dds]],
		},
		[74] = { -- Dremora
			texture = [[ShowMotifs/bin/themes/Default/dremora.dds]],
		},
		[75] = { -- Pyandonean
			texture = [[ShowMotifs/bin/themes/Default/pyandonean.dds]],
		},

		[76] = { -- Divine Prosecution
			texture = [[ShowMotifs/bin/themes/Default/divine_prosecution.dds]],
		},
		
-- Wolfhunter Styles
		[77] = { -- Huntsman
			texture = [[ShowMotifs/bin/themes/Default/huntsman.dds]],
		},
		[78] = { -- Silver Dawn
			texture = [[ShowMotifs/bin/themes/Default/silverdawn.dds]],
		},

-- Murkmire Styles
		[79] = { -- Dead-Water	
			texture = [[ShowMotifs/bin/themes/Default/deadwater.dds]],
		},
		[80] = { -- Honor Guard	
			texture = [[ShowMotifs/bin/themes/Default/honorguard.dds]],
		},
		[81] = { -- Elder Argonian
			texture = [[ShowMotifs/bin/themes/Default/elderargonian.dds]],
		},

-- Elsweyr Styles
[82] = { -- Coldsnap
	texture = [[esoui/art/icons/crafting_goblin-cloth_scrap.dds]],
},
[83] = { -- Meridian
	texture = [[esoui/art/icons/crafting_auroran_dust.dds]],
},
[84] = { -- Anequina
	texture = [[esoui/art/icons/crafting_shimmering_sand.dds]],
},
[85] = { -- Pellitine
	texture = [[esoui/art/icons/crafting_dragonthread.dds]],
},
[86] = { -- Sunspire
	texture = [[esoui/art/icons/crafting_style_item_celestial_r1.dds]],
},


[87] = { -- Dragon Bone
	texture = [[ShowMotifs/bin/themes/Default/monster.dds]],
},


[89] = { -- Stags of Z'en
	texture = [[esoui/art/icons/crafting_light_armor_vendor_component_002.dds]],
},


[92] = { -- Dragonguard
	texture = [[esoui/art/icons/crafting_humanoid_daedra_fire_salts.dds]],
},
[93] = { -- Moongrave Fane
	texture = [[esoui/art/icons/crafting_critter_vertebrate_cold_blood.dds]],
},
[94] = { -- New Moon Priest
	texture = [[esoui/art/icons/item_u25_aeonstoneshard.dds]],
},
[95] = { -- Shield of Senchal
	texture = [[esoui/art/icons/item_u25_carmineshieldsilk.dds]],
},


[97] = { -- Icereach Coven
	texture = [[esoui/art/icons/crafting_style_item_icereach_coven.dds]],
},
[98] = { -- Pyre Watch
	texture = [[esoui/art/icons/crafting_style_item_pyre_watch.dds]],
},
[99] = { -- Swordthane
	texture = [[ShowMotifs/bin/themes/Default/monster.dds]],
},
[100] = { -- Blackreach Vanguard
	texture = [[esoui/art/icons/crafting_style_item_blackreach_vanguard.dds]],
},
[101] = { -- Greymoor
	texture = [[ShowMotifs/bin/themes/Default/monster.dds]],
},
[102] = { -- Sea Giant
	texture = [[ShowMotifs/bin/themes/Default/monster.dds]],
},
[103] = { -- Ancestral Nord
	texture = [[esoui/art/icons/crafting_style_item_antiquities_nord.dds]],
},
[104] = { -- Ancestral High Elf
	texture = [[esoui/art/icons/crafting_style_item_antiquities_altmer.dds]],
},
[105] = { -- Ancestral Orc
	texture = [[esoui/art/icons/crafting_style_item_antiquities_orc.dds]],
},


[106] = { -- Thorn Legion
	texture = [[esoui/art/icons/item_u27_greyhost_sigil.dds]],
},
[107] = { -- Hazardous Alchemy
	texture = [[esoui/art/icons/crafting_style_item_hazardous_academy.dds]],
},
[108] = { -- Ancestral Akaviri
	texture = [[esoui/art/icons/crafting_style_item_burnishedgoldscale.dds]],
},
[110] = { -- Ancestral Reach
	texture = [[esoui/art/icons/crafting_style_item_ancestral_reach.dds]],
},
[111] = { -- Nighthollow
	texture = [[esoui/art/icons/crafting_style_item_nighthollow.dds]],
},
[112] = { -- Arkthzand Armory
	texture = [[esoui/art/icons/crafting_style_item_arkthzand_armory.dds]],
},
[113] = { -- Wayward Guardian
	texture = [[esoui/art/icons/crafting_style_item_wayward_guardian.dds]],
},
--[115] = { --  Deadlands Gladiator
--	texture = [[]],
--},
[116] = { -- True-Sworn
	texture = [[esoui/art/icons/crafting_style_item_fulgid_epidote.dds]],
},
[117] = { -- Waking Flame
	texture = [[esoui/art/icons/crafting_style_item_chokeberry_extract.dds]],
},
--[118] = { -- Dremora Kynreeve
--	texture = [[]],
--},
[120] = { -- Black Fin Legion
	texture = [[esoui/art/icons/style_item_blackfin.dds]],
},
[121] = { -- Ivory Brigade
	texture = [[esoui/art/icons/crafting_style_item_ivory_brigade.dds]],
},
[122] = { -- Sul-Xan
	texture = [[esoui/art/icons/style_item_sul-xan.dds]],
},

	},
---------------------------------------------------------------------------------------------------------------------------
-- Materials
---------------------------------------------------------------------------------------------------------------------------
	["Materials"] = {
		[0] = { -- ITEMSTYLE_NONE
			texture = [[EsoUI/Art/Crafting/crafting_tooltip_glow_center.dds]], --transparent
		},
		[1] = { -- ITEMSTYLE_RACIAL_BRETON
			texture = [[EsoUI/Art/Icons/crafting_metals_molybdenum.dds]], --Molybdenum
		},
		[2] = { -- ITEMSTYLE_RACIAL_REDGUARD
			texture = [[EsoUI/Art/Icons/crafting_medium_armor_sp_names_002.dds]], --Starmetal
		},
		[3] = { -- ITEMSTYLE_RACIAL_ORC
			texture = [[EsoUI/Art/Icons/crafting_metals_manganese.dds]], --Manganese
		},
		[4] = { -- ITEMSTYLE_RACIAL_DARK_ELF
			texture = [[EsoUI/Art/Icons/crafting_metals_graphite.dds]], --Obsidian
		},
		[5] = { -- ITEMSTYLE_RACIAL_NORD
			texture = [[EsoUI/Art/Icons/crafting_metals_corundum.dds]], --Corundum
		},
		[6] = { -- ITEMSTYLE_RACIAL_ARGONIAN
			texture = [[EsoUI/Art/Icons/crafting_smith_potion_standard_f_002.dds]], --Flint
		},
		[7] = { -- ITEMSTYLE_RACIAL_HIGH_ELF
			texture = [[EsoUI/Art/Icons/grafting_gems_adamantine.dds]], --Adamantite
		},
		[8] = { -- ITEMSTYLE_RACIAL_WOOD_ELF
			texture = [[EsoUI/Art/Icons/crafting_gems_daedra_skull.dds]], --Bone
		},
		[9] = { -- ITEMSTYLE_RACIAL_KHAJIIT
			texture = [[EsoUI/Art/Icons/crafting_smith_plug_sp_names_001.dds]], --Moonstone
		},
--		[10] = { -- ITEMSTYLE_UNIQUE
--			texture = [[EsoUI/Art/Crafting/crafting_tooltip_glow_center.dds]],
--		},
		[11] = { -- ITEMSTYLE_ORG_THIEVES_GUILD
			texture = [[esoui/art/icons/crafting_style_item_thieves_guild_r2.dds]], --Fine Chalk
		},
		[12] = { -- ITEMSTYLE_ORG_DARK_BROTHERHOOD
			texture = [[esoui/art/icons/crafting_style_item_dark_brotherhood_r2.dds]], --Black Beeswax
		},
		[13] = { -- ITEMSTYLE_DEITY_MALACATH
			texture = [[esoui/art/icons/crafting_style_item_malacath.dds]], --Potash
		},
		[14] = { -- ITEMSTYLE_AREA_DWEMER
			texture = [[EsoUI/Art/Icons/crafting_dwemer_shiny_tube.dds]], --Dwemer Frame
		},
		[15] = { -- ITEMSTYLE_AREA_ANCIENT_ELF
			texture = [[EsoUI/Art/Icons/crafting_ore_palladium.dds]], --Palladium
		},
		[16] = { -- ITEMSTYLE_DEITY_AKATOSH
			texture = [[esoui/art/icons/crafting_style_item_orderoth_r2.dds]], --Pearl Sand
		},
		[17] = { -- ITEMSTYLE_AREA_REACH
			texture = [[EsoUI/Art/Icons/crafting_smith_potion_standard_f_001.dds]], --Copper
		},
		[18] = { -- ITEMSTYLE_ENEMY_BANDIT
			texture = [[EsoUI/Art/Crafting/crafting_tooltip_glow_center.dds]],
		},
		[19] = { -- ITEMSTYLE_ENEMY_PRIMITIVE
			texture = [[EsoUI/Art/Icons/crafting_metals_argentum.dds]], --Argentum
		},
		[20] = { -- ITEMSTYLE_ENEMY_DAEDRIC
			texture = [[EsoUI/Art/Icons/crafting_walking_dead_mort_heart.dds]], --Daedra Heart
		},
		[21] = { -- ITEMSTYLE_DEITY_TRINIMAC
			texture = [[esoui/art/icons/crafting_style_item_trinimac.dds]], --Auric Tusk
		},
		[22] = { -- ITEMSTYLE_AREA_ANCIENT_ORC
			texture = [[esoui/art/icons/crafting_smith_plug_standard_f_001.dds]], --Cassiterite
		},
		[23] = { -- ITEMSTYLE_ALLIANCE_DAGGERFALL
			texture = [[esoui/art/icons/crafting_style_item_daggerfall_covenant.dds]], --Lion Fang
		},
		[24] = { -- ITEMSTYLE_ALLIANCE_EBONHEART
			texture = [[esoui/art/icons/crafting_style_item_ebonheart_pact.dds]], --Dragon Scute
		},
		[25] = { -- ITEMSTYLE_ALLIANCE_ALDMERI
			texture = [[esoui/art/icons/crafting_style_item_aldmeri_dominion.dds]], --Eagle Feather
		},
		[26] = { -- ITEMSTYLE_UNDAUNTED
			texture = [[esoui/art/icons/crafting_laurel.dds]], --Laurel
		},
		[27] = { -- ITEMSTYLE_RAIDS_CRAGLORN
			texture = [[esoui/art/icons/crafting_style_item_celestial_r2.dds]], -- Star Sapphire
		},
		[28] = { -- ITEMSTYLE_GLASS
			texture = [[esoui/art/icons/crafting_ore_base_malachite_r2.dds]], --Malachite
		},
		[29] = { -- ITEMSTYLE_AREA_XIVKYN
			texture = [[esoui/art/icons/crafting_smith_potion_008.dds]], --Charcoal of Remorse
		},
		[30] = { -- ITEMSTYLE_AREA_SOUL_SHRIVEN
			texture = [[esoui/art/icons/crafting_runecrafter_plug_component_005.dds]], --Azure Plasm
		},
		[31] = { -- ITEMSTYLE_ENEMY_DRAUGR
			texture = [[esoui/art/icons/crafting_style_item_draugr_r2.dds]], -- Pristine Shroud
		},
		[32] = { -- ITEMSTYLE_ENEMY_MAORMER
			texture = [[EsoUI/Art/Crafting/crafting_tooltip_glow_center.dds]],
		},
		[33] = { -- ITEMSTYLE_AREA_AKAVIRI
			texture = [[esoui/art/icons/crafting_medium_armor_vendor_003.dds]], --Goldscale
		},
		[34] = { -- ITEMSTYLE_RACIAL_IMPERIAL
			texture = [[EsoUI/Art/Icons/crafting_heavy_armor_sp_names_001.dds]], --Nickel
		},
		[35] = { -- ITEMSTYLE_AREA_YOKUDAN
			texture = [[esoui/art/icons/crafting_humanoid_daedra_void_salts.dds]], -- Ferrous Salts
		},
--		[36] = { -- ITEMSTYLE_UNIVERSAL
--			texture = [[EsoUI/Art/Crafting/crafting_tooltip_glow_center.dds]],
--		},
		[37] = { -- ITEMSTYLE_AREA_REACH_WINTER
			texture = [[EsoUI/Art/Crafting/crafting_tooltip_glow_center.dds]],
		},
		[38] = { -- ITEMSTYLE_AREA_TSAESCI
			texture = [[esoui/art/icons/crafting_lizard_fangs.dds]], -- Snake Fang
		},
		[39] = { -- ITEMSTYLE_ENEMY_MINOTAUR
			texture = [[esoui/art/icons/crafting_style_item_minotaur_r2.dds]], --Oxblood Fungus
		},
		[40] = { -- ITEMSTYLE_EBONY
			texture = [[esoui/art/icons/crafting_style_item_ebony_r2.dds]], -- Night Pumicee
		},
		[41] = { -- ITEMSTYLE_ORG_ABAHS_WATCH
			texture = [[esoui/art/icons/crafting_style_item_abahs_watch_r2.dds]], --Polished Shilling
		},
		[42] = { -- ITEMSTYLE_HOLIDAY_SKINCHANGER
			texture = [[esoui/art/icons/crafting_style_item_wolfsbane_r2.dds]], -- Wolfsbane Incense
		},
		[43] = { -- ITEMSTYLE_ORG_MORAG_TONG
			texture = [[esoui/art/icons/crafting_style_item_morag_tong_r2.dds]], --Boiled Carapace
		},
		[44] = { -- ITEMSTYLE_AREA_RA_GADA
			texture = [[esoui/art/icons/crafting_style_item_ragada_r2.dds]], -- Ancient Sandstone
		},
		[45] = { -- ITEMSTYLE_ENEMY_DROMOTHRA
			texture = [[esoui/art/icons/crafting_style_item_dromothra_r2.dds]], --Defiled Whiskers
		},
		[46] = { -- ITEMSTYLE_ORG_ASSASSINS
			texture = [[esoui/art/icons/crafting_style_item_assassins_league_r2.dds]], --Tainted Blood
		},
		[47] = { -- ITEMSTYLE_ORG_OUTLAW
			texture = [[esoui/art/icons/crafting_outlaw_styleitem.dds]], --Rogue's Soot
		},
		[48] = { -- ITEMSTYLE_ORG_REDORAN
			texture = [[esoui/art/icons/crafting_style_item_redoran_r2.dds]], --Polished Scarab Elytra
		},
		[49] = { -- ITEMSTYLE_ORG_HLAALU
			texture = [[esoui/art/icons/crafting_style_item_hlaalu_r2.dds]], --Refined Bonemold Resin
		},
		[50] = { -- ITEMSTYLE_ORG_ORDINATOR
			texture = [[esoui/art/icons/crafting_style_item_militant_ordinator_r2.dds]], --Lustrous Sphalerite
		},
		[51] = { -- ITEMSTYLE_ORG_TELVANNI
			texture = [[esoui/art/icons/crafting_style_item_telvanni_r2.dds]], --Wrought Ferrofungus
		},
		[52] = { -- ITEMSTYLE_ORG_BUOYANT_ARMIGER
			texture = [[esoui/art/icons/crafting_style_item_buoyant_armiger_r1.dds]], --Viridian Dust
		},
		[53] = { -- ITEMSTYLE_HOLIDAY_FROSTCASTER
			texture = [[esoui/art/icons/crafing_universal_item.dds]], -- Crown Mimic Stone
		},
		[54] = { -- ITEMSTYLE_AREA_ASHLANDER
			texture = [[esoui/art/icons/crafting_style_item_ashlander_r2.dds]], --Ash Canvas
		},
		[55] = { -- ITEMSTYLE_ORG_WORM_CULT
			texture = [[esoui/art/icons/quest_monster_ash_001.dds]], -- Desecrated Grave Soil
		},
		[56] = { -- ITEMSTYLE_ENEMY_SILKEN_RING
			texture = [[esoui/art/icons/crafting_style_item_mirrorsheen_r2.dds]], -- Distilled Slowsilver
		},
		[57] = { -- ITEMSTYLE_ENEMY_MAZZATUN
			texture = [[esoui/art/icons/crafting_style_item_mazzatun_r2.dds]], -- Laviathan Scrimshaw
		},
		[58] = { -- ITEMSTYLE_HOLIDAY_GRIM_HARLEQUIN
			texture = [[esoui/art/icons/crafing_universal_item.dds]], -- Crown Mimic Stone
		},
		[59] = { -- ITEMSTYLE_HOLIDAY_HOLLOWJACK
			texture = [[esoui/art/icons/crafting_style_item_hollowjack_r2.dds]], -- Amber Marble
		},


		[60] = { -- ITEMSTYLE_REFABRICATED (?)
			texture = [[esoui/art/icons/crafting_style_item_fabricant_r2.dds]],
		},


-- Clockwork City Styles
		[61] = { -- Bloodforge
			texture = [[esoui/art/icons/quest_dragonfire_dust.dds]], -- Bloodroot Flux
		},
		[62] = { -- Dreadhorn
			texture = [[esoui/art/icons/crafting_style_item_dreadhorn_r2.dds]], -- Minotaur Bezoar
		},
		[65] = { -- Apostle
			texture = [[esoui/art/icons/justice_stolen_prop_sesnits_paperweight.dds]], -- Tempered Brass
		},
		[66] = { -- Ebonshadow
			texture = [[esoui/art/icons/crafting_style_item_ebonshadow_r2.dds]], -- Tenebrous Cord
		},

--		[67] = { -- Undaunted
--			texture = [[EsoUI/Art/Crafting/crafting_tooltip_glow_center.dds]],
--		},

-- Morrowind Styles
		[69] = { -- Fang Lair
			texture = [[esoui/art/icons/crafting_ore_base_dragonbone_r2.dds]], -- Dragon Bone	
		},
		[70] = { -- Scalecaller
			texture = [[esoui/art/icons/crafting_outfitter_potion_002.dds]], -- Infected Flesh
		},

-- Summerset Styles
		[71] = { -- Psijic
			texture = [[esoui/art/icons/crafting_leather_nitre.dds]], -- Vitrified Malondo
		},
		[72] = { -- Sapiarch
			texture = [[esoui/art/icons/crafting_leather_phlegm.dds]], -- Culanda Lacquer
		},
		[73] = { -- Welkynar
			texture = [[esoui/art/icons/crafting_style_item_welkynar_r2.dds]], -- Gryphon Plume
		},
		[74] = { -- Dremora
			texture = [[esoui/art/icons/item_warriorsheartashes.dds]], -- Warrior's Heart Ashes
		},
		[75] = { -- Pyandonean
			texture = [[esoui/art/icons/crafting_leather_base_horkerskin_r2.dds]], -- Sea Serpent Hide
		},


		[76] = { -- Divine Prosecution
			texture = [[EsoUI/Art/Crafting/crafting_tooltip_glow_center.dds]],
		},


-- Wolfhunter Styles
		[77] = { -- Huntsman
			texture = [[esoui/art/icons/crafting_style_item_moonhunter_r2.dds]], -- Bloodscent Dew
		},
		[78] = { -- Silver Dawn
			texture = [[esoui/art/icons/crafting_style_item_silverdawn_r2.dds]], -- Argent Pelt
		},

-- Murkmire Styles
		[79] = { -- Dead-Water
			texture = [[esoui/art/icons/crafting_style_item_deadwater_r1.dds]], -- Crocodile Leather
		},
		[80] = { -- Honor Guard
			texture = [[esoui/art/icons/crafting_style_item_honorguard.dds]], -- Red Diamond Seal
		},
		[81] = { -- Elder Argonian
			texture = [[esoui/art/icons/crafting_style_item_elderargonian_r2.dds]], -- Hackwing Plumage
		},


-- Elsweyr Styles
		[82] = { -- Coldsnap
			texture = [[esoui/art/icons/crafting_goblin-cloth_scrap.dds]],
		},
		[83] = { -- Meridian
			texture = [[esoui/art/icons/crafting_auroran_dust.dds]],
		},
		[84] = { -- Anequina
			texture = [[esoui/art/icons/crafting_shimmering_sand.dds]],
		},
		[85] = { -- Pellitine
			texture = [[esoui/art/icons/crafting_dragonthread.dds]],
		},
		[86] = { -- Sunspire
			texture = [[esoui/art/icons/crafting_style_item_celestial_r1.dds]],
		},


		[87] = { -- Dragon Bone
			texture = [[EsoUI/Art/Crafting/crafting_tooltip_glow_center.dds]],
		},


		[89] = { -- Stags of Z'en
			texture = [[esoui/art/icons/crafting_light_armor_vendor_component_002.dds]],
		},


		[92] = { -- Dragonguard
			texture = [[esoui/art/icons/crafting_humanoid_daedra_fire_salts.dds]],
		},
		[93] = { -- Moongrave Fane
			texture = [[esoui/art/icons/crafting_critter_vertebrate_cold_blood.dds]],
		},
		[94] = { -- New Moon Priest
			texture = [[esoui/art/icons/item_u25_aeonstoneshard.dds]],
		},
		[95] = { -- Shield of Senchal
			texture = [[esoui/art/icons/item_u25_carmineshieldsilk.dds]],
		},


		[97] = { -- Icereach Coven
			texture = [[esoui/art/icons/crafting_style_item_icereach_coven.dds]],
		},
		[98] = { -- Pyre Watch
			texture = [[esoui/art/icons/crafting_style_item_pyre_watch.dds]],
		},
		[99] = { -- Swordthane
			texture = [[EsoUI/Art/Crafting/crafting_tooltip_glow_center.dds]],
		},
		[100] = { -- Blackreach Vanguard
			texture = [[esoui/art/icons/crafting_style_item_blackreach_vanguard.dds]],
		},
		[101] = { -- Greymoor
			texture = [[EsoUI/Art/Crafting/crafting_tooltip_glow_center.dds]],
		},
		[102] = { -- Sea Giant
			texture = [[EsoUI/Art/Crafting/crafting_tooltip_glow_center.dds]],
		},
		[103] = { -- Ancestral Nord
			texture = [[esoui/art/icons/crafting_style_item_antiquities_nord.dds]],
		},
		[104] = { -- Ancestral High Elf
			texture = [[esoui/art/icons/crafting_style_item_antiquities_altmer.dds]],
		},
		[105] = { -- Ancestral Orc
			texture = [[esoui/art/icons/crafting_style_item_antiquities_orc.dds]],
		},


		[106] = { -- Thorn Legion
			texture = [[esoui/art/icons/item_u27_greyhost_sigil.dds]],
		},
		[107] = { -- Hazardous Alchemy
			texture = [[esoui/art/icons/crafting_style_item_hazardous_academy.dds]],
		},
		[108] = { -- Ancestral Akaviri
			texture = [[esoui/art/icons/crafting_style_item_burnishedgoldscale.dds]],
		},
		[110] = { -- Ancestral Reach
			texture = [[esoui/art/icons/crafting_style_item_ancestral_reach.dds]],
		},
		[111] = { -- Nighthollow
			texture = [[esoui/art/icons/crafting_style_item_nighthollow.dds]],
		},
		[112] = { -- Arkthzand Armory
			texture = [[esoui/art/icons/crafting_style_item_arkthzand_armory.dds]],
		},
		[113] = { -- Wayward Guardian
			texture = [[esoui/art/icons/crafting_style_item_wayward_guardian.dds]],
		},
		--[115] = { --  Deadlands Gladiator
		--	texture = [[]],
		--},
		[116] = { -- True-Sworn
			texture = [[esoui/art/icons/crafting_style_item_fulgid_epidote.dds]],
		},
		[117] = { -- Waking Flame
			texture = [[esoui/art/icons/crafting_style_item_chokeberry_extract.dds]],
		},
		--[118] = { -- Dremora Kynreeve
		--	texture = [[]],
		--},
		[120] = { -- Black Fin Legion
			texture = [[esoui/art/icons/style_item_blackfin.dds]],
		},
		[121] = { -- Ivory Brigade
			texture = [[esoui/art/icons/crafting_style_item_ivory_brigade.dds]],
		},
		[122] = { -- Sul-Xan
			texture = [[esoui/art/icons/style_item_sul-xan.dds]],
		},

	},
}

-- textures for armor types
ShowMotifs.ARMOR_TEXTURES = {
	["Default \(Phinix\)"] = {
		[ARMORTYPE_LIGHT] = {
			texture = [[ShowMotifs/bin/themes/Default/armor_light.dds]],
			letter =  [[ShowMotifs/bin/themes/Default/armor_light_letter.dds]],
			},
		[ARMORTYPE_MEDIUM] = {
			texture = [[ShowMotifs/bin/themes/Default/armor_medium.dds]],
			letter =  [[ShowMotifs/bin/themes/Default/armor_medium_letter.dds]],
		},
		[ARMORTYPE_HEAVY] = {
			texture = [[ShowMotifs/bin/themes/Default/armor_heavy.dds]],
			letter =  [[ShowMotifs/bin/themes/Default/armor_heavy_letter.dds]],
		},
	},
	["Materials"] = {
		[ARMORTYPE_LIGHT] = {
			texture = [[EsoUI/Art/CharacterCreate/CharacterCreate_bodyIcon_up.dds]],
			letter =  [[ShowMotifs/bin/themes/Default/armor_light_letter.dds]],
			},
		[ARMORTYPE_MEDIUM] = {
			texture = [[EsoUI/Art/Campaign/overview_indexIcon_scoring_up.dds]],
			letter =  [[ShowMotifs/bin/themes/Default/armor_medium_letter.dds]],
		},
		[ARMORTYPE_HEAVY] = {
			texture = [[EsoUI/Art/Inventory/inventory_tabIcon_armor_up.dds]],
			letter =  [[ShowMotifs/bin/themes/Default/armor_heavy_letter.dds]],
		},
	},
}

local pChars = {
	["Dar'jazad"] = "Rajhin's Echo",
	["Quantus Gravitus"] = "Maker of Things",
	["Nina Romari"] = "Sanguine Coalescence",
	["Valyria Morvayn"] = "Dragon's Teeth",
	["Sanya Lightspear"] = "Thunderbird",
	["Divad Arbolas"] = "Gravity of Words",
	["Dro'samir"] = "Dark Matter",
	["Irae Aundae"] = "Prismatic Inversion",
	["Quixoti'coatl"] = "Time Toad",
	["Cythirea"] = "Mazken Stormclaw",
	["Fear-No-Pain"] = "Soul Sap",
	["Wax-in-Winter"] = "Cold Blooded",
	["Nateo Mythweaver"] = "In Strange Lands",
	["Cindari Atropa"] = "Dragon's Breath",
	["Kailyn Duskwhisper"] = "Nowhere's End",
	["Draven Blightborn"] = "From Outside",
	["Lorein Tarot"] = "Entanglement",
	["Koh-Ping"] = "Global Cooling",
}

local function modifyTitle(oTitle, uName)
	local tLang = {
		en = "Volunteer",
		fr = "Volontaire",
		de = "Freiwillige",
	}
	local client = GetCVar("Language.2")
	if oTitle == tLang[client] then
		return (pChars[uName] ~= nil) and pChars[uName] or oTitle
	end
	return oTitle
end

local modifyGetTitle = GetTitle
GetTitle = function(index)
	local oTitle = modifyGetTitle(index)
	local uName = GetUnitName('player')
	local rTitle = modifyTitle(oTitle, uName)
	return rTitle
end

local modifyGetUnitTitle = GetUnitTitle
GetUnitTitle = function(unitTag)
	local oTitle = modifyGetUnitTitle(unitTag)
	local uName = GetUnitName(unitTag)
	local rTitle = modifyTitle(oTitle, uName)
	return rTitle
end
