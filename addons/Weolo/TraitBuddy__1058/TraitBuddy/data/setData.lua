-- Compatibility layer between TraitBuddy UI and data sources.
-- Routes crafted set data through LibSets. Motifs and all other data
-- pass through to TB_Data unchanged via the proxy in TraitBuddy.lua.

local setData = {}
-- Session cache: built once in Initialize_Sets(), never written to disk.
setData._cachedSets = nil

local zoneIcons = {
	[181]  = "esoui/art/treeicons/tutorial_idexicon_ava_up.dds",           -- Cyrodiil
	[267]  = "/esoui/art/treeicons/antiquities_tabicon_eyevea_up.dds",     -- Eyevea
	[347]  = "/esoui/art/treeicons/antiquities_tabicon_coldharbour_up.dds",-- Coldharbour
	[584]  = "esoui/art/treeicons/tutorial_indexicon_ic_up.dds",           -- Imperial City
	[208]  = "esoui/art/icons/servicemappins/servicepin_fightersguild.dds",-- Earth Forge
	[684]  = "esoui/art/treeicons/tutorial_idexicon_wrothgar_up.dds",      -- Wrothgar
	[726]  = "esoui/art/treeicons/tutorial_idexicon_murkmire_up.dds",      -- Murkmire
	[816]  = "esoui/art/treeicons/tutorial_idexicon_thievesguild_up.dds",  -- Hew's Bane
	[823]  = "esoui/art/treeicons/tutorial_idexicon_darkbrotherhood_up.dds",-- Gold Coast
	[849]  = "esoui/art/treeicons/tutorial_idexicon_morrowind_up.dds",     -- Vvardenfell
	[888]  = "/esoui/art/treeicons/antiquities_tabicon_craglorn_up.dds",   -- Craglorn
	[980]  = "esoui/art/treeicons/tutorial_idexicon_cwc_up.dds",           -- Clockwork City
	[981]  = "esoui/art/treeicons/tutorial_idexicon_cwc_up.dds",           -- Brass Fortress
	[1011] = "/esoui/art/icons/store_psijic_upgrade.dds",                  -- Summerset
	[1027] = "/esoui/art/icons/store_psijic_upgrade.dds",                  -- Artaeum
	[1086] = "esoui/art/treeicons/tutorial_idexicon_elsweyr_up.dds",       -- Northern Elsweyr
	[1133] = "esoui/art/treeicons/tutorial_idexicon_dragonguard_up.dds",   -- Southern Elsweyr
	[1160] = "esoui/art/treeicons/tutorial_indexicon_greymoor_up.dds",     -- Western Skyrim
	[1161] = "esoui/art/treeicons/tutorial_indexicon_greymoor_up.dds",     -- Blackreach: Greymoor Caverns
	[1207] = "esoui/art/treeicons/tutorial_indexicon_markarth_up.dds",     -- The Reach
	[1208] = "esoui/art/treeicons/tutorial_indexicon_markarth_up.dds",     -- Blackreach: Arkthzand Cavern
	[1261] = "/esoui/art/icons/heraldrycrests_misc_tree_01.dds",           -- Blackwood
	[1283] = "esoui/art/treeicons/tutorial_idexicon_deadlands_up.dds",      -- The Shambles (Fargrave sub-zone)
	[1286] = "esoui/art/treeicons/tutorial_idexicon_deadlands_up.dds",     -- Deadlands
	[1318] = "/esoui/art/treeicons/store_indexicon_vanitypets_up.dds",     -- High Isle
	[1338] = "esoui/art/treeicons/tutorial_idexicon_deadlands_up.dds",	   -- Fargrave
	[1383] = "esoui/art/treeicons/tutorial_idexicon_firesong_up.dds",      -- Galen & Y'ffelon
	[1413] = "esoui/art/icons/heraldrycrests_daedra_hermaeusmora_01.dds",  -- Apocrypha
	[1414] = "esoui/art/icons/heraldrycrests_daedra_hermaeusmora_01.dds",  -- Telvanni Peninsula
	[1443] = "/esoui/art/treeicons/tutorial_indexicon_scribing_up.dds",    -- West Weald
	[1502] = "/esoui/art/icons/u46_coin_wormcult.dds",                     -- Solstice (Gold Road)
}

-- Zone IDs that LibSets includes but which are redundant or misleading for crafted set locations.
local suppressedZones = {
    [643] = true,  -- Imperial Sewers: paired with Earth Forge / Eyevea sets
                   -- because the crafting stations are technically accessible
                   -- from the sewers, but it's not useful location information.
}

function setData:Initialize()
	self:Initialize_Sets()
end

function setData:Initialize_Sets()
	self._cachedSets = nil

	local clientLang = GetCVar("language.2")
	local allSetIds  = LibSets.GetAllSetIds()
	if not allSetIds then return end

	-- Build the TB_Data fallback index once, before iterating sets.
	local sets = {}

	for setId, isActive in pairs(allSetIds) do
		if isActive then
			-- GetTraitsNeeded returns nil for non-crafted sets, so this is
			-- the correct filter to keep only crafted sets.
			local traitsNeeded = LibSets.GetTraitsNeeded(setId)

			if traitsNeeded then
				-- Name: prefer the live game API (localised, always current),
				-- fall back to LibSets pre-scanned names.
				local setName = GetItemSetName(setId)
				if not setName or setName == "" then
					setName = LibSets.GetSetName(setId, clientLang) or "Unknown"
				end

				-- Locations: GetZoneIds returns the authoritative zone list
				-- directly from LibSets data — no wayshrine resolution needed.
				-- This correctly handles PvP-gated (Cyrodiil/IC) and
				-- quest-locked (Eyevea/Earth Forge) sets whose wayshrine
				-- entries are negative sentinel values.
				local locations  = {}
				local uniqueZones = {}
				local zoneIds = LibSets.GetZoneIds(setId)

				if zoneIds then
					for _, zoneId in ipairs(zoneIds) do
						if #locations >= 3 then break end
						-- Skip sentinel values (negative) and duplicates.
						if zoneId and zoneId > 0 and not uniqueZones[zoneId] and not suppressedZones[zoneId] then
							uniqueZones[zoneId] = true
							table.insert(locations, {
								zone = TB_Data_SetLocation:New({
									id   = zoneId,
									icon = zoneIcons[zoneId],
								})
							})
						end
					end
				end
				
				table.insert(sets, {
					id        = setId,      -- game/LibSets set ID
					name      = setName,
					traits    = traitsNeeded,
					locations = locations,
					test      = setName,
				})
			end
		end
	end

	-- Sort alphabetically; Unknown entries sink to the bottom.
	table.sort(sets, function(a, b)
		if a.name == "Unknown" then return false end
		if b.name == "Unknown" then return true  end
		return a.name < b.name
	end)

	self._cachedSets = sets
end

function setData:GetSets()
	if self._cachedSets then
		return self._cachedSets
	end
	return {}
end

-- Returns a single set by its position in the sorted list.
function setData:GetSet(index)
	local sets = self:GetSets()
	if sets and sets[index] then
		return sets[index]
	end
	return nil
end

-- Pass-throughs: these methods exist on TB_Data and are reached via the
-- TraitBuddy.lua proxy's __index fallback, so setData does not need
-- to redeclare them. The only methods setData owns are the ones above
-- that specifically deal with LibSets set data.

local passthroughMethods = {
	"GetTraitLinkID",
	"GetJewelryTraitLinkID",
	"GetResearchableTraitMaterials",
	"IsResearchableTrait",
	"GetNumChapters",
	"GetChapterOrder",
}

for _, methodName in ipairs(passthroughMethods) do
	setData[methodName] = function(self, ...)
		if TraitBuddy.Data and TraitBuddy.Data[methodName] then
			return TraitBuddy.Data[methodName](TraitBuddy.Data, ...)
		end
		return nil
	end
end

-- Export
TB_setData = setData