-- Addon
ChallengeModeSelector = ChallengeModeSelector or {}
local CMS = ChallengeModeSelector

-- Modules
CMS.Helper = CMS.Helper or {}
local Helper = CMS.Helper

-- Helpers
local function map(func, tbl)
	local mapped = {}
	for index, value in ipairs(tbl) do
		table.insert(mapped, func(value))
	end
	return mapped
end

-- Export
Helper.map = map
