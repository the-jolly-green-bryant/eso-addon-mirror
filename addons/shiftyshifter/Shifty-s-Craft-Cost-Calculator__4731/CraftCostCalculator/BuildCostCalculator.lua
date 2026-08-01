--[[
	BuildCostCalculator
	Orchestrates CCC export import → per-piece craft cost using existing services.

	Does NOT reimplement material / price math.
	Calls MaterialResolver + CalculationEngine (+ OwnedMaterials via engine).
]]

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.BuildCostCalculator = CCC.BuildCostCalculator or {}
local BC = CCC.BuildCostCalculator

local CALC_EVENT = "CraftCostCalculatorBuildCalc"
local PIECES_PER_TICK = 1

function BC:Init(addon)
	BC.addon = addon
	BC.build = nil
	BC.entries = {} -- enriched piece rows
	BC.calcQueue = {}
	BC.calcIndex = 0
	BC.isCalculating = false
	BC.filter = "all"
	BC.sortKey = "slot"
	BC.sortAsc = true
	BC.onUpdate = nil -- UI callback
end

function BC:SetUpdateCallback(cb)
	BC.onUpdate = cb
end

function BC:Notify()
	if BC.onUpdate then
		BC.onUpdate()
	end
end

function BC:Clear()
	BC:StopLazyCalc()
	BC.build = nil
	BC.entries = {}
	BC.calcQueue = {}
	BC.calcIndex = 0
	BC:Notify()
end

function BC:HasBuild()
	return BC.build ~= nil
end

function BC:GetBuild()
	return BC.build
end

function BC:GetEntries()
	return BC.entries
end

--- Import a CCC export string. Resolves costability immediately; costs are lazy.
-- Mythics are never costed. All other resolvable pieces are (including dungeon /
-- trial / monster gear — reconstruct / substitute craft estimate).
-- @return boolean ok, string|nil errorMessage
function BC:ImportExport(exportString)
	local build, err = BC.addon.BuildExport:Decode(exportString)
	if not build then
		return false, err
	end

	BC:StopLazyCalc()
	BC.build = build
	BC.entries = {}
	BC.calcQueue = {}

	for i = 1, #build.pieces do
		local piece = build.pieces[i]
		local category = BC.addon.BuildPieceResolver:ClassifyPiece(piece)
		local isMythic = BC.addon.MythicSets:IsMythic(piece.setName)
		local craftInfo, resolveErr, warnings = nil, nil, {}

		if isMythic then
			resolveErr = "Mythic item — excluded from craft cost."
			warnings = { "Mythics cannot be station-crafted or reconstructed." }
		else
			craftInfo, resolveErr, warnings = BC.addon.BuildPieceResolver:Resolve(piece)
		end

		local costable = (not isMythic) and (craftInfo ~= nil)

		local entry = {
			index = i,
			piece = piece,
			category = category,
			craftInfo = craftInfo,
			isMythic = isMythic,
			costable = costable,
			-- legacy alias used by older UI paths during transition
			craftable = costable,
			resolveError = resolveErr,
			warnings = warnings or {},
			result = nil,
			calcState = costable and "pending" or "skipped", -- pending|ready|error|skipped
			calcError = nil,
			expanded = false,
			craftCost = nil, -- missing-mat cost
			fullCraftCost = nil,
		}

		BC.entries[#BC.entries + 1] = entry
		if costable then
			BC.calcQueue[#BC.calcQueue + 1] = #BC.entries
		end
	end

	BC.calcIndex = 0
	BC:StartLazyCalc()
	BC:Notify()
	return true
end

function BC:StopLazyCalc()
	BC.isCalculating = false
	EVENT_MANAGER:UnregisterForUpdate(CALC_EVENT)
end

function BC:StartLazyCalc()
	if #BC.calcQueue == 0 then
		BC.isCalculating = false
		return
	end
	BC.isCalculating = true
	EVENT_MANAGER:RegisterForUpdate(CALC_EVENT, 0, function()
		BC:ProcessCalcTick()
	end)
end

function BC:ProcessCalcTick()
	local processed = 0
	while processed < PIECES_PER_TICK and BC.calcIndex < #BC.calcQueue do
		BC.calcIndex = BC.calcIndex + 1
		local entryIndex = BC.calcQueue[BC.calcIndex]
		BC:CalculateEntry(entryIndex)
		processed = processed + 1
	end

	BC:Notify()

	if BC.calcIndex >= #BC.calcQueue then
		BC:StopLazyCalc()
	end
end

--- Calculate a single entry using existing MaterialResolver + CalculationEngine.
function BC:CalculateEntry(entryIndex)
	local entry = BC.entries[entryIndex]
	if not entry or not entry.costable or not entry.craftInfo then
		return
	end

	local materials, matErr = BC.addon.MaterialResolver:Resolve(entry.craftInfo)
	if not materials then
		entry.calcState = "error"
		entry.calcError = matErr or "Unable to resolve materials."
		entry.result = nil
		entry.craftCost = nil
		entry.fullCraftCost = nil
		return
	end

	-- Synthetic link: CalculationEngine uses it for finished-item market price only.
	local displayLink = string.format("|H0:item:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h%s|h",
		entry.piece.setName or entry.piece.slot or "Build Piece")

	local ok, result = pcall(function()
		return BC.addon.CalculationEngine:Calculate(displayLink, entry.craftInfo, materials)
	end)

	if not ok or not result then
		entry.calcState = "error"
		entry.calcError = type(result) == "string" and result or "Cost calculation failed."
		entry.result = nil
		entry.craftCost = nil
		entry.fullCraftCost = nil
		return
	end

	entry.result = result
	if entry.craftInfo and entry.craftInfo.glyphWarning then
		result.glyphWarning = entry.craftInfo.glyphWarning
		entry.glyphWarning = entry.craftInfo.glyphWarning
	end
	entry.calcState = "ready"
	entry.calcError = nil
	entry.craftCost = result.total
	entry.fullCraftCost = result.fullTotal
end

function BC:ToggleExpanded(entryIndex)
	local entry = BC.entries[entryIndex]
	if not entry then
		return
	end
	entry.expanded = not entry.expanded

	-- Ensure cost/materials are ready when expanding.
	if entry.expanded and entry.costable and entry.calcState ~= "ready" then
		BC:CalculateEntry(entryIndex)
	end
	BC:Notify()
end

function BC:SetFilter(filter)
	BC.filter = filter or "all"
	BC:Notify()
end

function BC:GetFilter()
	return BC.filter
end

function BC:SetSort(key)
	if BC.sortKey == key then
		BC.sortAsc = not BC.sortAsc
	else
		BC.sortKey = key
		BC.sortAsc = true
	end
	BC:Notify()
end

local function entryMatchesFilter(entry, filter)
	if filter == "all" then
		return true
	elseif filter == "costed" or filter == "craftable" then
		return entry.costable
	elseif filter == "mythics" then
		return entry.isMythic
	elseif filter == "skipped" or filter == "noncraftable" then
		return (not entry.costable) and (not entry.isMythic)
	elseif filter == "weapons" then
		return entry.category == "weapon"
	elseif filter == "armor" then
		return entry.category == "armor"
	elseif filter == "jewelry" then
		return entry.category == "jewelry"
	end
	return true
end

local function sortValue(entry, key, resolver)
	if key == "slot" then
		return entry.index
	elseif key == "set" then
		return zo_strlower(entry.piece.setName or "")
	elseif key == "trait" then
		return zo_strlower(entry.piece.trait or "")
	elseif key == "quality" then
		return entry.piece.quality or 0
	elseif key == "cost" then
		return entry.craftCost or -1
	elseif key == "fullCost" then
		return entry.fullCraftCost or -1
	elseif key == "craftable" or key == "costable" then
		-- Mythic < skipped < costable for sort stability
		if entry.isMythic then
			return 0
		elseif entry.costable then
			return 2
		end
		return 1
	elseif key == "type" then
		return entry.category or ""
	end
	return entry.index
end

--- Filtered + sorted entries for the table (piece rows only).
function BC:GetVisibleEntries()
	local list = {}
	for i = 1, #BC.entries do
		local entry = BC.entries[i]
		if entryMatchesFilter(entry, BC.filter) then
			list[#list + 1] = entry
		end
	end

	local key = BC.sortKey
	local asc = BC.sortAsc
	local resolver = BC.addon.BuildPieceResolver
	table.sort(list, function(a, b)
		local va = sortValue(a, key, resolver)
		local vb = sortValue(b, key, resolver)
		if va == vb then
			return a.index < b.index
		end
		if asc then
			return va < vb
		end
		return va > vb
	end)

	return list
end

--- Flat display list: piece rows with optional expanded material lines.
function BC:GetDisplayRows()
	local rows = {}
	local visible = BC:GetVisibleEntries()
	for i = 1, #visible do
		local entry = visible[i]
		rows[#rows + 1] = { kind = "piece", entry = entry }

		if entry.expanded and entry.result and entry.result.lines then
			for m = 1, #entry.result.lines do
				rows[#rows + 1] = {
					kind = "material",
					entry = entry,
					line = entry.result.lines[m],
				}
			end
			local glyphWarn = entry.glyphWarning or (entry.result and entry.result.glyphWarning)
			if glyphWarn and glyphWarn ~= "" then
				rows[#rows + 1] = {
					kind = "message",
					entry = entry,
					text = "Glyph: " .. glyphWarn,
				}
			end
		elseif entry.expanded and entry.calcState == "error" then
			rows[#rows + 1] = {
				kind = "message",
				entry = entry,
				text = entry.calcError or "Calculation failed.",
			}
		elseif entry.expanded and entry.isMythic then
			rows[#rows + 1] = {
				kind = "message",
				entry = entry,
				text = "Mythic — no craft / reconstruct cost.",
			}
		elseif entry.expanded and not entry.costable then
			rows[#rows + 1] = {
				kind = "message",
				entry = entry,
				text = entry.resolveError or "Cannot estimate craft cost for this piece.",
			}
		elseif entry.expanded and entry.calcState == "pending" then
			rows[#rows + 1] = {
				kind = "message",
				entry = entry,
				text = "Calculating…",
			}
		end
	end
	return rows
end

function BC:GetSummary()
	local totalPieces = #BC.entries
	local costed = 0
	local mythics = 0
	local skipped = 0
	local totalMissingCost = 0
	local totalFullCost = 0
	local pending = 0
	local complete = true
	local hasPriced = false

	for i = 1, #BC.entries do
		local e = BC.entries[i]
		if e.isMythic then
			mythics = mythics + 1
		elseif e.costable then
			costed = costed + 1
		else
			skipped = skipped + 1
		end

		if e.calcState == "pending" then
			pending = pending + 1
			complete = false
		elseif e.calcState == "ready" and e.result then
			hasPriced = true
			totalMissingCost = totalMissingCost + (e.result.total or 0)
			totalFullCost = totalFullCost + (e.result.fullTotal or 0)
			if not e.result.complete then
				complete = false
			end
		elseif e.calcState == "error" then
			complete = false
		end
	end

	return {
		name = BC.build and BC.build.name or "",
		setupName = BC.build and BC.build.setupName or nil,
		totalPieces = totalPieces,
		costedPieces = costed,
		mythicPieces = mythics,
		skippedPieces = skipped,
		-- aliases for older UI string paths
		craftablePieces = costed,
		nonCraftablePieces = mythics + skipped,
		totalCraftCost = totalFullCost,
		totalMissingMaterialCost = totalMissingCost,
		totalTtcMaterialValue = totalFullCost,
		pending = pending,
		calculating = BC.isCalculating,
		complete = complete and pending == 0,
		hasPriced = hasPriced,
	}
end

--- Merge missing mats from every ready craftable piece into the shopping list.
-- @return addedKinds, mergedKinds, totalQty
function BC:AddEntireBuildToShoppingList()
	local added, merged, totalQty = 0, 0, 0
	local sl = BC.addon.ShoppingList

	for i = 1, #BC.entries do
		local e = BC.entries[i]
		if e.calcState == "ready" and e.result then
			local a, m, q = sl:AddFromResult(e.result)
			added = added + a
			merged = merged + m
			totalQty = totalQty + q
		end
	end

	return added, merged, totalQty
end

--- Recalculate all ready/pending pieces (e.g. after inventory change).
function BC:RecalculateAll()
	if not BC.build then
		return
	end

	BC:StopLazyCalc()
	BC.calcQueue = {}
	for i = 1, #BC.entries do
		local e = BC.entries[i]
		if e.costable then
			e.calcState = "pending"
			e.result = nil
			e.craftCost = nil
			e.fullCraftCost = nil
			BC.calcQueue[#BC.calcQueue + 1] = i
		end
	end
	BC.calcIndex = 0
	BC:StartLazyCalc()
	BC:Notify()
end
