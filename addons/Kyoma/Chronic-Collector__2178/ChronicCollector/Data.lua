--format: { globalX, globalY, criteriaIndex, (optional)miregauntIndex }, -- "tablet name"

local data = {}
data["murkmire"] = {
	["murkmire_base"] = {
		-- First one doesn't exist as an actual item it seems
		--{ 0.3916, 0.5570,  1, 1 }, -- part of quest, no actual item
		{ 0.7532, 0.3477,  2 }, -- Xeech
		{ 0.5451, 0.2714,  3 }, -- Sisei
		{ 0.5413, 0.7877,  4 }, -- Hist-Deek
		{ 0.3940, 0.2740,  5 }, -- Hist-Dooka
		{ 0.2665, 0.5841,  6, }, -- Hist-Tsoko
		{ 0.8782, 0.8024,  7, }, -- Thtithil-Gah
		{ 0.6611, 0.6704,  8, }, -- Thtithil
		{ 0.7043, 0.3403,  9, }, -- Nushmeeko
		{ 0.1455, 0.2985, 10, 2 }, -- Shaja-Nushmeeko / Belly-of-Stone
		{ 0.4614, 0.4197, 11, 3 }, -- Saxhleel / Roots-that-Stumble
		{ 0.7221, 0.2803, 12, 4 }, -- Xulomaht / Breath-like-Decay
	},
	["echoinghollow_base"] = {
		{ 0.7727, 0.7446,  5 }, -- Hist-Dooka
	},
	["lilmothcity_base"] = {
		{ 0.7945, 0.5571,  7 }, -- Thtithil-Gah
	},
	["withervault_base"] = {
		{ 0.2899, 0.3095,  9 }, -- Nushmeeko
	},
}

function ChronicCollector_GetLocalData(zone, subzone)
	if type(zone) == "string" and type(subzone) == "string" and data[zone] and data[zone][subzone] then
		return data[zone][subzone]
	end
end
