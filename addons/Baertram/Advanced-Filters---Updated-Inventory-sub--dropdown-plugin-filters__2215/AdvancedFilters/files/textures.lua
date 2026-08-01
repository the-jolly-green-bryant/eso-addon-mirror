AdvancedFilters = AdvancedFilters or {}
local AF = AdvancedFilters

local textures = {
    None = "", -- TODO
    All = "esoui/art/inventory/inventory_tabicon_all_%s.dds",
    Trophy = "AdvancedFilters/assets/miscellaneous/trophy/trophy_%s.dds",
    TreasureMaps = "EsoUI/Art/TradingHouse/Tradinghouse_Trophy_Treasure_Map_%s.dds",
    SurveyReport = "/esoui/art/icons/quest_summerset_completed_report.dds",
    --KeyFragment = "EsoUI/Art/TradingHouse/Tradinghouse_Trophy_Key_Fragment_%s.dds",
    MuseumPiece = "esoui/art/icons/servicemappins/servicepin_museum.dds",
    RecipeFragment = "EsoUI/Art/TradingHouse/Tradinghouse_Trophy_Recipe_Fragment_%s.dds",
    Scroll = "EsoUI/Art/TradingHouse/Tradinghouse_Trophy_Scroll_%s.dds",
    CollectibleFragment = "esoui/art/treeicons/store_indexicon_fragments_%s.dds",
    Key = "esoui/art/worldmap/map_indexicon_key_%s.dds",
    MaterialUpgrader = "esoui/art/tradinghouse/tradinghouse_materials_blacksmithing_mats_%s.dds",
    RuneboxFragment = "esoui/art/tradinghouse/tradinghouse_trophy_runebox_fragment_%s.dds",
    Toy = "esoui/art/icons/justice_stolen_toy_001.dds",
    UpgradeFragment = "esoui/art/treeicons/collection_indexicon_upgrade_%s.dds",
    Fish = "esoui/art/icons/housing_gen_exc_fish001.dds",
    Treasure = "/esoui/art/tradinghouse/tradinghouse_sell_tabicon_%s.dds",

    --WEAPONS
    OneHand = "AdvancedFilters/assets/weapons/onehanded_%s.dds",
    TwoHand = "AdvancedFilters/assets/weapons/twohanded_%s.dds",
    Bow = "AdvancedFilters/assets/weapons/bow_%s.dds",
    DestructionStaff = "AdvancedFilters/assets/weapons/destruction_%s.dds",
    Fire = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_Staff_Flame_%s.dds",
    Frost = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_Staff_Frost_%s.dds",
    Lightning = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_Staff_Lightning_%s.dds",
    HealStaff = "AdvancedFilters/assets/weapons/healing_%s.dds",

    --ARMOR
    Heavy = "esoui/art/icons/progression_tabicon_armorheavy_%s.dds",
    Medium = "esoui/art/icons/progression_tabicon_armormedium_%s.dds",
    LightArmor = "esoui/art/icons/progression_tabicon_armorlight_%s.dds",
    Clothing = "AdvancedFilters/assets/apparel/clothing_%s.dds",
    Shield = "AdvancedFilters/assets/apparel/shield_%s.dds",
    Vanity = "AdvancedFilters/assets/apparel/vanity_%s.dds",
    Armor = "EsoUI/Art/Inventory/inventory_tabIcon_armor_%s.dds",

    --Jewelry
    Jewelry = "AdvancedFilters/assets/apparel/jewelry_%s.dds",
    Neck = "AdvancedFilters/assets/apparel/neck_%s.dds",
    Ring = "AdvancedFilters/assets/apparel/ring_%s.dds",

    --CONSUMABLES
    Crown = "esoui/art/housing/keyboard/furniture_tabicon_crownfurnishings_%s.dds",
    Food = "AdvancedFilters/assets/consumables/food/food_%s.dds",
    Drink = "AdvancedFilters/assets/consumables/drinks/drink_%s.dds",
    Recipe = "AdvancedFilters/assets/consumables/recipes/recipe_%s.dds",
    Potion = "AdvancedFilters/assets/consumables/potion/potion_%s.dds",
    Poison = "AdvancedFilters/assets/consumables/poison/poison_%s.dds",
    Motif = "AdvancedFilters/assets/consumables/motifs/motif_%s.dds",
    Writ = "EsoUI/Art/TradingHouse/Tradinghouse_Master_Writ_%s.dds",
    Container = "AdvancedFilters/assets/consumables/containers/container_%s.dds",
    Repair = "AdvancedFilters/assets/consumables/repair/repair_%s.dds",

    --FURNISHINGS
    CraftingStation = "esoui/art/treeicons/housing_indexicon_workshop_%s.dds",
    Light = "esoui/art/treeicons/housing_indexicon_shrine_%s.dds",
    Ornamental = "esoui/art/treeicons/housing_indexicon_gallery_%s.dds",
    Seating = "esoui/art/treeicons/collection_indexicon_furnishings_%s.dds",
    TargetDummy = "esoui/art/treeicons/collection_indexicon_weapons+armor_%s.dds",
    Furnishings = "EsoUI/Art/Crafting/provisioner_indexIcon_furnishings_%s.dds",

    --MATERIALS
    Blacksmithing = "esoui/art/inventory/inventory_tabIcon_Craftbag_blacksmithing_%s.dds",
    Clothier = "esoui/art/inventory/inventory_tabIcon_Craftbag_clothing_%s.dds",
    Woodworking = "esoui/art/inventory/inventory_tabIcon_Craftbag_woodworking_%s.dds",
    Alchemy = "esoui/art/inventory/inventory_tabIcon_Craftbag_alchemy_%s.dds",
    Enchanting = "esoui/art/inventory/inventory_tabIcon_Craftbag_enchanting_%s.dds",
    Provisioning = "esoui/art/inventory/inventory_tabIcon_Craftbag_provisioning_%s.dds",
    Style = "esoui/art/inventory/inventory_tabIcon_Craftbag_styleMaterial_%s.dds",
    WeaponTrait = "AdvancedFilters/assets/materials/wtrait/wtrait_%s.dds",
    ArmorTrait = "AdvancedFilters/assets/materials/atrait/atrait_%s.dds",
    AllTraits = "EsoUI/Art/Inventory/inventory_tabIcon_Craftbag_itemTrait_%s.dds",

    --MISCELLANEOUS
    Glyphs = "AdvancedFilters/assets/miscellaneous/glyphs/glyphs_%s.dds",
    SoulGem = "AdvancedFilters/assets/miscellaneous/soulgem/soulgem_%s.dds",
    Siege = "AdvancedFilters/assets/miscellaneous/avaweapon/avaweapon_%s.dds",
    Bait = "AdvancedFilters/assets/miscellaneous/bait/bait_%s.dds",
    Tool = "AdvancedFilters/assets/consumables/repair/repair_%s.dds",
    Fence = "esoui/art/vendor/vendor_tabicon_fence_%s.dds",
    Trash = "AdvancedFilters/assets/miscellaneous/trash/trash_%s.dds",
    Disguise = "AdvancedFilters/assets/apparel/vanity_%s.dds",

    --JUNK
    Weapon = "esoui/art/inventory/inventory_tabIcon_weapons_%s.dds",
    Apparel = "esoui/art/inventory/inventory_tabIcon_armor_%s.dds",
    Consumable = "esoui/art/inventory/inventory_tabIcon_consumables_%s.dds",
    Materials = "esoui/art/inventory/inventory_tabIcon_crafting_%s.dds",
    Miscellaneous = "esoui/art/inventory/inventory_tabIcon_misc_%s.dds",

    --CRAFT BAG
    --BLACKSMITHING
    RawMaterialSmithing = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Blacksmithing_Rawmats_%s.dds",
    RefinedMaterialSmithing = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Blacksmithing_Mats_%s.dds",
    Temper = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Blacksmithing_Temper_%s.dds",

    --Clothier
    RawMaterialClothier = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Tailoring_Rawmats_%s.dds",
    RefinedMaterialClothier = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Tailoring_Mats_%s.dds",
    Tannin = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Tailoring_Tannin_%s.dds",

    --Woodworking
    RawMaterialWoodworking = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Woodworking_Rawmats_%s.dds",
    RefinedMaterialWoodworking = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Woodworking_Mats_%s.dds",
    Resin = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Woodworking_Resin_%s.dds",

    --Jewelry crafting
    JewelryCrafting = "EsoUI/Art/Inventory/inventory_tabIcon_Craftbag_jewelrycrafting_%s.dds",
    JewelryAllTrait = "AdvancedFilters/assets/apparel/jewelry_%s.dds",
    JewelryRawTrait = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Style_RawMats_%s.dds",
    JewelryRefinedTrait = "EsoUI/Art/Crafting/jewelry_tabIcon_icon_%s.dds",
    RawMaterialJewelry = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Jewelrymaking_Rawmats_%s.dds",
    RefinedMaterialJewelry = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Jewelrymaking_Mats_%s.dds",
    RawPlating = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Jewelrymaking_Rawplating_%s.dds",
    Plating = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Jewelrymaking_Plating_%s.dds",

    --Trait
    RawTrait = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Style_RawMats_%s.dds",
    RefinedTrait = "EsoUI/Art/Inventory/inventory_tabIcon_Craftbag_styleMaterial_%s.dd",

    --Style
    RawMaterialStyle = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Style_RawMats_%s.dds",

    --ALCHEMY
    Reagent = "AdvancedFilters/assets/craftbag/alchemy/reagent_%s.dds",

    --ENCHANTING
    Aspect = "esoui/art/crafting/enchantment_tabIcon_aspect_%s.dds",
    Essence = "esoui/art/crafting/enchantment_tabIcon_essence_%s.dds",
    Potency = "esoui/art/crafting/enchantment_tabIcon_potency_%s.dds",

    --PROVISIONING
    OldIngredient = "esoui/art/worldmap/map_ava_tabicon_foodfarm_%s.dds",
    RareIngredient = "EsoUI/Art/TradingHouse/Tradinghouse_Materials_Provisioning_Rare_%s.dds",

    --STYLE
    NormalStyle = "esoui/art/progression/progression_indexicon_race_%s.dds",
    RareStyle = "esoui/art/progression/progression_indexicon_world_%s.dds",
    AllianceStyle = "esoui/art/charactercreate/charactercreate_raceicon_%s.dds",
    ExoticStyle = "esoui/art/icons/progression_tabicon_magma_%s.dds",

    --Armor part types
    Chest = "EsoUI/Art/TradingHouse/Tradinghouse_Apparel_Chest_%s.dds",
    Feet = "EsoUI/Art/TradingHouse/Tradinghouse_Apparel_Feet_%s.dds",
    Hand = "EsoUI/Art/TradingHouse/Tradinghouse_Apparel_Hands_%s.dds",
    Head = "EsoUI/Art/TradingHouse/Tradinghouse_Apparel_Head_%s.dds",
    Legs = "EsoUI/Art/TradingHouse/Tradinghouse_Apparel_Legs_%s.dds",
    Shoulders = "EsoUI/Art/TradingHouse/Tradinghouse_Apparel_Shoulders_%s.dds",
    Waist = "EsoUI/Art/TradingHouse/Tradinghouse_Apparel_Waist_%s.dds",
    --Weapon part types
    Axe = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_1h_Axe_%s.dds",
    Dagger = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_1h_Dagger_%s.dds",
    Hammer = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_1h_Mace_%s.dds",
    Sword = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_1h_Sword_%s.dds",
    TwoHandAxe = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_2h_Axe_%s.dds",
    TwoHandHammer = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_2h_Mace_%s.dds",
    TwoHandSword = "EsoUI/Art/TradingHouse/Tradinghouse_Weapons_2h_Sword_%s.dds",

    --Retrait
    Retrait = "EsoUI/Art/Crafting/retrait_tabIcon_%s.dds",

    --Traits
    Arcane = "/esoui/art/icons/jewelrycrafting_trait_refined_cobalt.dds",
    Bloodthirsty = "/esoui/art/icons/crafting_enchantment_baxe_bloodstone_r1.dds",
    Harmony = "/esoui/art/icons/crafting_metals_tin.dds",
    Healthy = "/esoui/art/icons/jewelrycrafting_trait_refined_antimony.dds",
    Infused = "/esoui/art/icons/crafting_enchantment_base_jade_r1.dds",
    Intricate = "/esoui/art/inventory/inventory_trait_intricate_icon.dds",
    Ornate = "/esoui/art/inventory/inventory_trait_ornate_icon.dds",
    Protective = "/esoui/art/icons/crafting_runecrafter_armor_component_006.dds",
    Robust = "/esoui/art/icons/jewelrycrafting_trait_refined_zinc.dds",
    Swift = "/esoui/art/icons/crafting_outfitter_plug_component_002.dds",
    Triune = "/esoui/art/icons/jewelrycrafting_trait_refined_dawnprism.dds",
    
    --Companion traits
    Aggressive  = "EsoUI/Art/Campaign/campaignBrowser_indexIcon_normal_up.dds",
    Augmented   = "EsoUI/Art/Campaign/overview_indexIcon_bonus_up.dds",
    Bolstered   = "EsoUI/Art/Campaign/campaign_tabIcon_browser_up.dds",
    Focused     = "EsoUI/Art/Campaign/overview_indexIcon_scoring_up.dds",
    Prolific    = "EsoUI/Art/Crafting/retrait_tabicon_up.dds",
    Quickened   = "EsoUI/Art/Guild/tabIcon_history_up.dds",
    Shattering  = "EsoUI/Art/Repair/inventory_tabIcon_repair_up.dds",
    Soothing    = "EsoUI/Art/Inventory/inventory_tabIcon_healstaff_up.dds",
    Vigorous    = "EsoUI/Art/Crafting/provisioner_indexIcon_beer_up.dds",

    --Recall stones
    RecallStone = "/esoui/art/icons/rune_a.dds",

    Costume         = "AdvancedFilters/assets/apparel/clothing_%s.dds",
    BodyMarking     = "AdvancedFilters/assets/collectibles/body_%s.dds",
    JewelryPiercing = "AdvancedFilters/assets/apparel/jewelry_%s.dds",
    HeadMarking     = "EsoUI/Art/TradingHouse/Tradinghouse_Apparel_Head_%s.dds",
    Facial          = "AdvancedFilters/assets/apparel/vanity_%s.dds",
    Hair            = "/esoui/art/icons/justice_stolen_hair_001.dds", --TODO
    Hat             = "AdvancedFilters/assets/collectibles/hat_%s.dds",
    Skin            = "/esoui/art/icons/skin_infernaceepidermis.dds", --TODO
    Polymorph       = "/esoui/art/icons/container_sealed_polymorph_001.dds", --TODO
    Personality     = "/esoui/art/emotes/emotes_indexicon_personality_%s.dds",

    Crafted         = "/EsoUI/Art/Inventory/inventory_tabIcon_Craftbag_%s.dds",

    Scribing        = "/esoui/art/crafting/scribing_tabicon_scribing_%s.dds",
    ScribingGrimoire= "/esoui/art/icons/grimoire_soulmagic1.dds",
    ScribingScript  = "/esoui/art/icons/scribing_tertiary_intellectendurance.dds",
    ScribingInk     = "/esoui/art/icons/item_grimoire_ink.dds",

    StackableContainer   = "/esoui/art/icons/hirelingmail_jewelrycrafting_generic.dds",

    ConsumableAbility = "/esoui/art/icons/achievement_u46_skill_meta.dds",
}

--ALCHEMY
textures.Water = textures.Potion
textures.Oil = textures.Poison

--PROVISIONING
textures.FoodIngredient = textures.Food
textures.DrinkIngredient = textures.Drink

--STYLE
textures.CrownStyle = textures.Crown

--FURNISHING MATERIAL
textures.FurnishingMat = textures.Seating

--GLYPHS
textures.WeaponGlyph = textures.OneHand
textures.ArmorGlyph = textures.Heavy
textures.JewelryGlyph = textures.Jewelry

--COLLECTIBLES
textures.RareFish = textures.Fish


--Change the size of the textures for the dropdown filter boxes?
--All others will use 28 x 28
local texturesReSize = {
    --[[
        Example entry
        Trophy = {width=20, height=20},
    ]]
    Fish            = {width=20, height=20},
    RareFish        = {width=20, height=20},
    Toy             = {width=20, height=20},
    MuseumPiece     = {width=20, height=20},
    SurveyReport    = {width=20, height=20},
    RecallStone     = {width=20, height=20},
    ScribingInk     = {width=18, height=18},
    ScribingScript  = {width=20, height=20},
    ScribingGrimoire = {width=20, height=20},
    ConsumableAbility = {width=20, height=20},
}
AF.texturesReSize = texturesReSize

--Add the textures to the addon namespace
-->Used in AF_FilterBar:AddSubfilter
AF.textures = textures