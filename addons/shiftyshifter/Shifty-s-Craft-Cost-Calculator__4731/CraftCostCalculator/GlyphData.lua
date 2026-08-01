--[[
	GlyphData
	Isolated static tables for glyph ↔ rune resolution.

	ESO has no offline reverse API (glyph → potency/essence/aspect). Official
	GetEnchantingResultingItemLink only works forward at a station with bag
	slots. These tables mirror the same data LibLazyCrafting uses and stay
	isolated so they can be updated when ZOS adds runes/glyphs.
]]

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.GlyphData = CCC.GlyphData or {}
local G = CCC.GlyphData

-- Aspect rune itemIds by functional quality (1–5).
G.ASPECT_BY_QUALITY = {
	[1] = 45850, -- Ta
	[2] = 45851, -- Jejota
	[3] = 45852, -- Denata
	[4] = 45853, -- Rekuta
	[5] = 45854, -- Kuta
}

--[[
	glyphInfo rows (LibLazyCrafting layout):
	  [1] subtractive enchant ability id
	  [2] additive enchant ability id
	  [3] subtractive glyph itemId
	  [4] additive glyph itemId
	  [5] subtractive short name
	  [6] additive short name
	  [7] subtractive glyph item type
	  [8] additive glyph item type
	  [9] essence rune itemId
]]
G.GLYPH_INFO = {
	{29, 17, 43573, 26580, "Absorb Health", "Health", ITEMTYPE_GLYPH_WEAPON, ITEMTYPE_GLYPH_ARMOR, 45831},
	{83, 19, 45868, 26582, "Absorb Magicka", "Magicka", ITEMTYPE_GLYPH_WEAPON, ITEMTYPE_GLYPH_ARMOR, 45832},
	{82, 25, 45867, 26588, "Absorb Stamina", "Stamina", ITEMTYPE_GLYPH_WEAPON, ITEMTYPE_GLYPH_ARMOR, 45833},
	{84, 18, 45869, 26581, "Decrease Health", "Health Recovery", ITEMTYPE_GLYPH_WEAPON, ITEMTYPE_GLYPH_JEWELRY, 45834},
	{86, 20, 45870, 26583, "Reduce Spell Cost", "Magicka Recovery", ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_JEWELRY, 45835},
	{87, 26, 45871, 26589, "Reduce Feat Cost", "Stamina Recovery", ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_JEWELRY, 45836},
	{23, 24, 26586, 26587, "Poison Resist", "Poison", ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_WEAPON, 45837},
	{11, 10, 26849, 26848, "Flame Resist", "Flame", ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_WEAPON, 45838},
	{14, 15, 5364, 5365, "Frost Resist", "Frost", ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_WEAPON, 45839},
	{31, 6, 43570, 26844, "Shock Resist", "Shock", ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_WEAPON, 45840},
	{9, 3, 26847, 26841, "Disease Resist", "Foulness", ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_WEAPON, 45841},
	{7, 16, 26845, 5366, "Crushing", "Hardening", ITEMTYPE_GLYPH_WEAPON, ITEMTYPE_GLYPH_WEAPON, 45842},
	{28, 4, 26591, 54484, "Weakening", "Weapon Damage", ITEMTYPE_GLYPH_WEAPON, ITEMTYPE_GLYPH_WEAPON, 45843},
	{91, 90, 45875, 45874, "Potion Speed", "Potion Boost", ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_JEWELRY, 45846},
	{94, 92, 45885, 45883, "Decrease Physical Harm", "Increase Physical Harm", ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_JEWELRY, 45847},
	{95, 93, 45886, 45884, "Decrease Spell Harm", "Increase Magical Harm", ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_JEWELRY, 45848},
	{89, 88, 45873, 45872, "Shielding", "Bashing", ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_JEWELRY, 45849},
	{147, 146, 68344, 68343, "Prismatic Onslaught", "Prismatic Defense", ITEMTYPE_GLYPH_WEAPON, ITEMTYPE_GLYPH_ARMOR, 68342},
	{178, 179, 166046, 166047, "Reduce Skill Cost", "Prismatic Recovery", ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_JEWELRY, 166045},
}

-- Potency runes: [1]=parity (-1 subtractive / +1 additive), [2]=itemId, lvl/cp.
G.POTENCY_LEVELS = {
	{-1, 45817, lvl = 1, cp = nil},
	{1, 45855, lvl = 1, cp = nil},
	{-1, 45818, lvl = 5, cp = nil},
	{1, 45856, lvl = 5, cp = nil},
	{1, 45857, lvl = 10, cp = nil},
	{-1, 45819, lvl = 10, cp = nil},
	{-1, 45820, lvl = 15, cp = nil},
	{1, 45806, lvl = 15, cp = nil},
	{-1, 45821, lvl = 20, cp = nil},
	{1, 45807, lvl = 20, cp = nil},
	{-1, 45822, lvl = 25, cp = nil},
	{1, 45808, lvl = 25, cp = nil},
	{-1, 45823, lvl = 30, cp = nil},
	{1, 45809, lvl = 30, cp = nil},
	{-1, 45824, lvl = 35, cp = nil},
	{1, 45810, lvl = 35, cp = nil},
	{-1, 45825, lvl = 40, cp = nil},
	{1, 45811, lvl = 40, cp = nil},
	{1, 45812, lvl = nil, cp = 10},
	{-1, 45826, lvl = nil, cp = 10},
	{-1, 45827, lvl = nil, cp = 30},
	{1, 45813, lvl = nil, cp = 30},
	{1, 45814, lvl = nil, cp = 50},
	{-1, 45828, lvl = nil, cp = 50},
	{-1, 45829, lvl = nil, cp = 70},
	{1, 45815, lvl = nil, cp = 70},
	{1, 45816, lvl = nil, cp = 100},
	{-1, 45830, lvl = nil, cp = 100},
	{-1, 64508, lvl = nil, cp = 150},
	{1, 64509, lvl = nil, cp = 150},
	{1, 68341, lvl = nil, cp = 160},
	{-1, 68340, lvl = nil, cp = 160},
}

-- Level leaps for snapping requested gear level to a craftable potency tier.
-- Key = level, or level+50 when CP.
G.LEVEL_LEAPS = {
	{Key = 1, lvl = 1, cp = nil},
	{Key = 5, lvl = 5, cp = nil},
	{Key = 10, lvl = 10, cp = nil},
	{Key = 15, lvl = 15, cp = nil},
	{Key = 20, lvl = 20, cp = nil},
	{Key = 25, lvl = 25, cp = nil},
	{Key = 30, lvl = 30, cp = nil},
	{Key = 35, lvl = 35, cp = nil},
	{Key = 40, lvl = 40, cp = nil},
	{Key = 60, lvl = nil, cp = 10},
	{Key = 80, lvl = nil, cp = 30},
	{Key = 100, lvl = nil, cp = 50},
	{Key = 120, lvl = nil, cp = 70},
	{Key = 150, lvl = nil, cp = 100},
	{Key = 200, lvl = nil, cp = 150},
	{Key = 210, lvl = nil, cp = 160},
}

-- Extra name aliases used by build guides (Hyperioxes, etc.).
G.NAME_ALIASES = {
	["maximum health"] = "Health",
	["max health"] = "Health",
	["maximum magicka"] = "Magicka",
	["max magicka"] = "Magicka",
	["maximum stamina"] = "Stamina",
	["max stamina"] = "Stamina",
	["spell damage"] = "Weapon Damage",
	["weapon and spell damage"] = "Weapon Damage",
	["physical harm"] = "Increase Physical Harm",
	["magical harm"] = "Increase Magical Harm",
	["spell harm"] = "Increase Magical Harm",
	["prismatic"] = "Prismatic Defense",
	["tri-stat"] = "Prismatic Defense",
	["tristat"] = "Prismatic Defense",
}
