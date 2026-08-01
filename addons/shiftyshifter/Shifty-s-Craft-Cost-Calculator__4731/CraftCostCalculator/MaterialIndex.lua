--[[
	MaterialIndex
	In-memory search index over MaterialRepository entries.

	Built once from the repository catalog. Search is a case-insensitive
	substring scan over cached nameLower values — fast enough for a few
	hundred materials. Options leave room for category filters / sort later.
]]

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.MaterialIndex = CCC.MaterialIndex or {}
local MI = CCC.MaterialIndex

local DEFAULT_LIMIT = 50

function MI:Init(addon)
	MI.addon = addon
	MI.entries = nil
	MI.built = false
end

function MI:IsBuilt()
	return MI.built == true
end

--- Build from MaterialRepository. No-op if already built.
function MI:Build()
	if MI.built then
		return
	end

	local catalog = MI.addon.MaterialRepository:GetCatalog()
	MI.entries = catalog
	MI.built = true
end

function MI:EnsureBuilt()
	if not MI.built then
		MI:Build()
	end
end

local function matchesCategory(entry, category)
	if not category then
		return true
	end
	return entry.category == category
end

local function matchesQuery(entry, queryLower)
	if not queryLower or queryLower == "" then
		return true
	end
	local nameLower = entry.nameLower or ""
	return string.find(nameLower, queryLower, 1, true) ~= nil
end

--- Search materials.
-- @param query string|nil partial name (case-insensitive)
-- @param opts table|nil { limit, category, sort } — sort currently "name" only
-- @return table matching entries (references into the index; do not mutate)
function MI:Search(query, opts)
	MI:EnsureBuilt()
	opts = opts or {}

	local limit = opts.limit or DEFAULT_LIMIT
	if limit < 1 then
		limit = DEFAULT_LIMIT
	end

	local category = opts.category
	local queryLower = nil
	if query and query ~= "" then
		queryLower = zo_strlower(zo_strtrim(query))
		if queryLower == "" then
			queryLower = nil
		end
	end

	local results = {}
	local entries = MI.entries or {}
	for i = 1, #entries do
		local entry = entries[i]
		if matchesCategory(entry, category) and matchesQuery(entry, queryLower) then
			results[#results + 1] = entry
			if #results >= limit then
				break
			end
		end
	end

	-- Catalog is already sorted by name; future sort modes can reorder here.
	return results
end

function MI:GetEntry(itemId)
	MI:EnsureBuilt()
	return MI.addon.MaterialRepository:GetByItemId(itemId)
end
