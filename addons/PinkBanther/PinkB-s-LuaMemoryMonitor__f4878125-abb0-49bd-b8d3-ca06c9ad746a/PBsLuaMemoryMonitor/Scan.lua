-- PB's LuaMemoryMonitor -- held memory, estimated
--
-- Lua reports only the size of the whole heap, so what an add-on holds is estimated: every
-- table and string reachable from its globals is counted once, at a size taken from how a
-- 64-bit Lua 5.1 lays them out. The client runs Havok Script, whose layout is not published,
-- so the figures are for comparing add-ons with each other and over time, not exact bytes.
--
-- What is not seen: data an add-on keeps only in local variables (Lua cannot reach into a
-- function's upvalues without the debug library, which the client strips), the code itself,
-- and controls, which are the client's userdata.
--
-- Ownership is decided per global, before anything is walked:
--   * a global that appeared at an add-on's own load event is that add-on's (Main.lua);
--   * otherwise it is the add-on whose name it contains, the longest name winning
--     ("LibAddonMenu-2.0" -> "libaddonmenu" -> LibAddonMenu2);
--   * everything else is the client's, and every table that is a direct value of a client
--     global is marked as seen, so an add-on that keeps a reference to a client singleton does
--     not have the client's data counted as its own.
-- A table reachable from two add-ons is counted for whichever reaches it first.
--
-- The walk runs a little each frame. A single table is always walked whole within one frame,
-- since a table walked across frames can change under the iterator.

local addon = PBS_LUA_MEMORY_MONITOR
if not addon then
	return
end

local Iterate = addon.Iterate
local UPDATE_NAME = addon.name .. "_Scan"
local ENTRY_BUDGET = 20000
local MAX_OBJECTS = 250000

local TABLE_BYTES = 56
local ARRAY_SLOT_BYTES = 16
local HASH_NODE_BYTES = 40
local STRING_BYTES = 25

local function PowerOfTwo(count)
	if count <= 0 then
		return 0
	end
	local size = 1
	while size < count do
		size = size * 2
	end
	return size
end

local function Normalize(text)
	return (text:lower():gsub("[^%w]", ""))
end

-- "LibAddonMenu-2.0" publishes LibAddonMenu2, so the version suffix is not part of the name.
local function Needle(name)
	local needle = Normalize((name:gsub("[%-_]?%d[%d%.]*$", "")))
	return #needle >= 4 and needle or nil
end

-- The scan's state lives in these locals only. Nothing reachable from _G may point at it, or
-- the scan would walk its own bookkeeping.
local visited, objects
local queueTable, queueOwner, queueRoot, head, tail
local bytesByOwner, bytesByRoot
local currentOwner, currentRoot, currentBytes, currentEntries
local frames, startMs, truncated

local function Push(value)
	if visited[value] then
		return
	end
	if objects >= MAX_OBJECTS then
		truncated = true
		return
	end
	visited[value] = true
	objects = objects + 1
	tail = tail + 1
	queueTable[tail], queueOwner[tail], queueRoot[tail] = value, currentOwner, currentRoot
end

-- Strings are interned, so each one is counted once however many tables use it.
local function CountString(text)
	if visited[text] then
		return
	end
	if objects >= MAX_OBJECTS then
		truncated = true
		return
	end
	visited[text] = true
	objects = objects + 1
	currentBytes = currentBytes + STRING_BYTES + #text
end

local function WalkTable(target)
	for key, value in Iterate, target do
		currentEntries = currentEntries + 1
		local kind = type(key)
		if kind == "string" then
			CountString(key)
		elseif kind == "table" then
			Push(key)
		end
		kind = type(value)
		if kind == "string" then
			CountString(value)
		elseif kind == "table" then
			Push(value)
		end
	end
end

local function Length(target)
	return #target
end

local function MeasureTable(target)
	currentBytes, currentEntries = 0, 0
	pcall(WalkTable, target)
	local ok, length = pcall(Length, target)
	local arrayCount = ok and type(length) == "number" and math.min(length, currentEntries) or 0
	return currentEntries, currentBytes + TABLE_BYTES
		+ ARRAY_SLOT_BYTES * PowerOfTwo(arrayCount)
		+ HASH_NODE_BYTES * PowerOfTwo(currentEntries - arrayCount)
end

local function Add(owner, root, bytes)
	bytesByOwner[owner] = (bytesByOwner[owner] or 0) + bytes
	bytesByRoot[root] = (bytesByRoot[root] or 0) + bytes
end

local function Finish()
	EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
	for _, row in ipairs(addon.rows) do
		row.heldKB = (bytesByOwner[row.name] or 0) / 1024
		if row.firstHeldKB == nil then
			row.firstHeldKB = row.heldKB
		end
	end
	addon.rootBytes = bytesByRoot
	addon.lastScan = {
		objects = objects,
		frames = frames,
		seconds = (addon.NowMs() - startMs) / 1000,
		truncated = truncated,
	}
	addon.scanning = false
	visited, queueTable, queueOwner, queueRoot, bytesByOwner, bytesByRoot = nil, nil, nil, nil, nil, nil
	if addon.RefreshWindow then
		addon:RefreshWindow()
	end
end

local function Step()
	frames = frames + 1
	local budget = ENTRY_BUDGET
	while budget > 0 do
		if head > tail then
			Finish()
			return
		end
		local target = queueTable[head]
		currentOwner, currentRoot = queueOwner[head], queueRoot[head]
		queueTable[head], queueOwner[head], queueRoot[head] = nil, nil, nil
		head = head + 1
		local entries, bytes = MeasureTable(target)
		Add(currentOwner, currentRoot, bytes)
		budget = budget - entries - 1
	end
end

function addon:StartScan()
	if self.scanning or not self.rows then
		return
	end
	self.scanning = true
	visited, objects = { [_G] = true }, 0
	queueTable, queueOwner, queueRoot, head, tail = {}, {}, {}, 1, 0
	bytesByOwner, bytesByRoot = {}, {}
	frames, truncated, startMs = 0, false, self.NowMs()

	local needles = {}
	for _, row in ipairs(self.rows) do
		local needle = Needle(row.name)
		if needle then
			needles[#needles + 1] = { needle = needle, name = row.name }
		end
	end
	table.sort(needles, function(a, b) return #a.needle > #b.needle end)

	local function Match(key)
		if key:find("^[Zz][Oo]_") then
			return nil
		end
		local normalized = Normalize(key)
		for _, entry in ipairs(needles) do
			if normalized:find(entry.needle, 1, true) then
				return entry.name
			end
		end
		return nil
	end

	-- Every client table is marked before any add-on table is walked.
	local owner = self.owner
	local rootOwner, rootHow = {}, {}
	local rootKeys, rootValues = {}, {}
	pcall(function()
		for key, value in Iterate, _G do
			local kind = type(value)
			if (kind == "table" or kind == "string") and type(key) == "string" then
				local who, how = owner[key], "event"
				if who == nil then
					who, how = Match(key), "name"
				end
				if who then
					rootOwner[key], rootHow[key] = who, how
					rootKeys[#rootKeys + 1] = key
					rootValues[#rootKeys] = value
				elseif kind == "table" then
					visited[value] = true
				end
			end
		end
	end)

	for i, key in ipairs(rootKeys) do
		local value = rootValues[i]
		currentOwner, currentRoot = rootOwner[key], key
		if type(value) == "string" then
			currentBytes = 0
			CountString(value)
			Add(currentOwner, currentRoot, currentBytes)
		else
			Push(value)
		end
	end

	self.rootOwner, self.rootHow = rootOwner, rootHow
	EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, 0, Step)
	if self.RefreshWindow then
		self:RefreshWindow()
	end
end

-- ---------------------------------------------------------------------------------------
-- Detail: which globals make up one add-on's figure, largest first
-- ---------------------------------------------------------------------------------------

local DETAIL_LINES = 12

function addon:PrintDetail(query)
	query = (query or ""):lower()
	if query == "" then
		self.Say(self:HelpText())
		return
	end

	local row
	for _, candidate in ipairs(self.rows) do
		if candidate.name:lower():find(query, 1, true) or candidate.title:lower():find(query, 1, true) then
			row = candidate
			break
		end
	end
	if not row then
		self.Say(string.format(GetString(SI_PBSLMM_DETAIL_NONE), query))
		return
	end
	if not self.lastScan then
		self:StartScan()
		self.Say(GetString(SI_PBSLMM_DETAIL_WAIT))
		return
	end

	self.Say(string.format(GetString(SI_PBSLMM_DETAIL_HEAD), row.title,
		self.FormatKB(row.heldKB), self.FormatKB(row.svKB), self.FormatKB(row.initKB)))

	local roots = {}
	for key, who in pairs(self.rootOwner or {}) do
		if who == row.name then
			roots[#roots + 1] = key
		end
	end
	local bytes = self.rootBytes or {}
	table.sort(roots, function(a, b) return (bytes[a] or 0) > (bytes[b] or 0) end)
	if #roots == 0 then
		self.Say(GetString(SI_PBSLMM_DETAIL_NO_ROOTS))
	end
	for i = 1, math.min(DETAIL_LINES, #roots) do
		local key = roots[i]
		local how = self.rootHow[key] == "event" and SI_PBSLMM_BY_EVENT or SI_PBSLMM_BY_NAME
		self.Say(string.format(GetString(SI_PBSLMM_DETAIL_ROOT), key, self.FormatKB((bytes[key] or 0) / 1024), GetString(how)))
	end
	if #roots > DETAIL_LINES then
		self.Say(string.format(GetString(SI_PBSLMM_DETAIL_MORE), #roots - DETAIL_LINES))
	end
end
