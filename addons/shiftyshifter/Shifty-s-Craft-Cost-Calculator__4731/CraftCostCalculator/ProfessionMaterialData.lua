--[[
	ProfessionMaterialData
	Isolated static itemId tables for professions that lack a complete
	off-station enumeration API (Alchemy reagents/solvents, Enchanting runes,
	and primary Furnishing materials).

	Provisioning and most Furnishing ingredients are collected dynamically from
	the recipe API in MaterialRepository. Keep this file easy to extend when
	ZOS adds new reagents/runes/mats.
]]

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.ProfessionMaterialData = CCC.ProfessionMaterialData or {}
local P = CCC.ProfessionMaterialData

-- Alchemy reagents (UESP / esoPotionData).
P.ALCHEMY_REAGENTS = {
	30148, -- Blue Entoloma
	30149, -- Stinkhorn
	30151, -- Emetic Russula
	30152, -- Violet Coprinus
	30153, -- Namira's Rot
	30154, -- White Cap
	30155, -- Luminous Russula
	30156, -- Imp Stool
	30157, -- Blessed Thistle
	30158, -- Lady's Smock
	30159, -- Wormwood
	30160, -- Bugloss
	30161, -- Corn Flower
	30162, -- Dragonthorn
	30163, -- Mountain Flower
	30164, -- Columbine
	30165, -- Nirnroot
	30166, -- Water Hyacinth
	77581, -- Torchbug Thorax
	77583, -- Beetle Scuttle
	77584, -- Spider Egg
	77585, -- Butterfly Wing
	77587, -- Fleshfly Larva
	77589, -- Scrib Jelly
	77590, -- Nightshade
	77591, -- Mudcrab Chitin
	139019, -- Powdered Mother of Pearl
	139020, -- Clam Gall
	150669, -- Chaurus Egg
	150670, -- Vile Coagulant
	150671, -- Dragon Rheum
	150672, -- Crimson Nirnroot
	150731, -- Dragon's Blood
	150789, -- Dragon's Bile
}

-- Potion solvents then poison solvents (UESP / esoPotionData).
P.ALCHEMY_SOLVENTS = {
	883, -- Natural Water
	1187, -- Clear Water
	4570, -- Pristine Water
	23265, -- Cleansed Water
	23266, -- Filtered Water
	23267, -- Purified Water
	23268, -- Cloud Mist
	64500, -- Star Dew
	64501, -- Lorkhan's Tears
	75357, -- Grease
	75358, -- Ichor
	75359, -- Slime
	75360, -- Gall
	75361, -- Terebinthine
	75362, -- Pitch-Bile
	75363, -- Tarblack
	75364, -- Night-Oil
	75365, -- Alkahest
}

-- Enchanting essence runes (LibLazyCrafting glyphInfo).
P.ENCHANTING_ESSENCE = {
	45831, -- Oko
	45832, -- Makko
	45833, -- Deni
	45834, -- Okoma
	45835, -- Makkoma
	45836, -- Denima
	45837, -- Kuoko
	45838, -- Rakeipa
	45839, -- Dekeipa
	45840, -- Meip
	45841, -- Haoko
	45842, -- Deteri
	45843, -- Okori
	45846, -- Oru
	45847, -- Taderi
	45848, -- Mahafi
	45849, -- Kaderi
	68342, -- Hakeijo
	166045, -- Indeko
}

-- Enchanting potency runes (additive + subtractive; LibLazyCrafting enchantLevelInfo).
P.ENCHANTING_POTENCY = {
	45855, 45856, 45857, 45806, 45807, 45808, 45809, 45810, 45811, 45812,
	45813, 45814, 45815, 45816, 64509, 68341, -- additive
	45817, 45818, 45819, 45820, 45821, 45822, 45823, 45824, 45825, 45826,
	45827, 45828, 45829, 45830, 64508, 68340, -- subtractive
}

-- Enchanting aspect runes (Ta → Kuta).
P.ENCHANTING_ASPECT = {
	45850, -- Ta
	45851, -- Jejota
	45852, -- Denata
	45853, -- Rekuta
	45854, -- Kuta
}

-- Primary Homestead+ furnishing materials (dedicated node drops).
P.FURNISHING_PRIMARY = {
	114889, -- Regulus
	114890, -- Bast
	114891, -- Clean Pelt
	114892, -- Mundane Rune
	114893, -- Alchemical Resin
	114894, -- Decorative Wax
	114895, -- Heartwood
}

-- Blueprint itemIds used only to discover ingredients via
-- GetItemLinkRecipeIngredientItemLink (works for unknown plans).
-- Includes Ochre and a few other jewelry-era mats.
P.FURNISHING_SEED_BLUEPRINTS = {
	152046, -- Elsweyr Cupboard, Elegant Wooden (Heartwood, Ochre, …)
	139486, -- Alinor Ancestor Clock, Celestial (Ochre, …)
	184156, -- Blackwood Provisioning Station
}

-- Common provisioning quality / special ingredients used in many recipes and furnishings.
P.PROVISIONING_SPECIAL = {
	26954, -- Flour
	27038, -- Bervez Juice
	27059, -- Frost Mirriam
	64222, -- Perfect Roe
}
