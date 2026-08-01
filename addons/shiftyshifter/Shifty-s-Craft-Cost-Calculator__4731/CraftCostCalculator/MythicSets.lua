--[[
	MythicSets
	Known ESO mythic (antiquity) one-piece sets.

	Mythics cannot be crafted or reconstructed for a meaningful station craft
	cost — Build Cost Calculator excludes them from material costing.
	Dungeon / trial / monster gear still gets a cost estimate (reconstruct /
	transmute / substitute craft mats).
]]

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.MythicSets = CCC.MythicSets or {}
local M = CCC.MythicSets

-- Canonical English display names (guides / exports use these).
local MYTHIC_NAMES = {
	"Belharza's Band",
	"Bloodlord's Embrace",
	"Cryptcanon Vestments",
	"Death Dealer's Fete",
	"Dov-rha Sabatons",
	"Esoteric Environment Greaves",
	"Faun's Lark Cladding",
	"Gaze of Sithis",
	"Harpooner's Wading Kilt",
	"Huntsman's Warmask",
	"Lefthander's Aegis Belt",
	"Lefthander's War Girdle", -- older / alternate guide name
	"Mad God's Dancing Shoes",
	"Malacath's Band of Brutality",
	"Markyn Ring of Majesty",
	"Monomyth Reforged",
	"Mora's Whispers",
	"Oakensoul Ring",
	"Pearls of Ehlnofey",
	"Rakkhat's Voidmantle",
	"Ring of the Pale Order",
	"Ring of the Wild Hunt",
	"Rourken Steamguards",
	"Sea-Serpent's Coil",
	"Shapeshifter's Chain",
	"Shattered Paths Signet",
	"Snow Treaders",
	"Spaulder of Ruin",
	"Stormweaver's Cavort",
	"Syrabane's Ward",
	"The Saint and the Seducer",
	"The Shadow Queen's Cowl",
	"Shadow Queen's Cowl",
	"Thrassian Stranglers",
	"Torc of the Last Ayleid King",
	"Torc of the Ayleid King", -- alternate short name
	"Torc of Tonal Constancy",
	"Velothi Ur-Mage's Amulet",
}

local mythicLookup -- normalized name → true

local function normalizeName(name)
	if not name or name == "" then
		return ""
	end
	local s = zo_strlower(name)
	-- Strip apostrophe / quote glyphs without character classes
	-- (ESO Lua patterns break on fancy quotes inside []).
	s = s:gsub("'", "")
	s = s:gsub("`", "")
	s = s:gsub("\226\128\153", "") -- ’
	s = s:gsub("\226\128\152", "") -- ‘
	s = s:gsub("[^%w%s]", " ")
	s = s:gsub("%s+", " ")
	return zo_strtrim(s)
end

function M:Init(addon)
	M.addon = addon
	mythicLookup = {}
	for i = 1, #MYTHIC_NAMES do
		mythicLookup[normalizeName(MYTHIC_NAMES[i])] = true
	end
end

--- True when the set / item name refers to a mythic antiquity piece.
function M:IsMythic(setName)
	if not setName or setName == "" then
		return false
	end
	if not mythicLookup then
		M:Init(M.addon)
	end

	local key = normalizeName(setName)
	if mythicLookup[key] then
		return true
	end

	-- Guides sometimes append "Mythic" or use slightly longer labels.
	if key:find("mythic", 1, true) then
		local stripped = zo_strtrim(key:gsub("mythic", ""))
		if mythicLookup[stripped] then
			return true
		end
	end

	return false
end
