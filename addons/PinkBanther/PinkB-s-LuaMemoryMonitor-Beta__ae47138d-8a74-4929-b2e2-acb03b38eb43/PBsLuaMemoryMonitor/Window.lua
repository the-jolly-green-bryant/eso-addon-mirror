-- PB's LuaMemoryMonitor -- the ranking window
--
-- A fragment on HUD_SCENE and HUD_UI_SCENE, like the client's own /addonmem readout. Adding a
-- fragment only stores it beside the client's own; no client screen is built or shown from
-- here. While the window is up the held figures are rescanned at the interval chosen in the
-- settings (every minute by default), so the Change column shows which add-on keeps growing
-- after login.

local addon = PBS_LUA_MEMORY_MONITOR
if not addon then
	return
end

local control = PBsLuaMemoryMonitorWindow
-- 15 add-ons, a blank line and the three rows that make the ranking add up (see Reconcile)
-- fill the same 19 lines on every page.
local PAGE_SIZE = 15
local NAME_CHARS = 24
local AUTO_NAME = addon.name .. "_AutoScan"
local DEFAULT_X = 60
local DEFAULT_BG_ALPHA = 78

local SORT_ORDER = { "held", "change", "sv", "init" }
local SORT_TITLES = {
	held = SI_PBSLMM_COL_HELD,
	change = SI_PBSLMM_COL_CHANGE,
	sv = SI_PBSLMM_COL_SV,
	init = SI_PBSLMM_COL_INIT,
}
addon.SORT_ORDER = SORT_ORDER
addon.SORT_TITLES = SORT_TITLES

local WINDOW_WIDTH, WINDOW_HEIGHT = 880, 768
if control and control.GetDimensions then
	WINDOW_WIDTH, WINDOW_HEIGHT = control:GetDimensions()
end

local labels = {}
if control then
	for _, child in ipairs({ "Bg", "Title", "Summary", "HeadName", "HeadHeld", "HeadChange", "HeadSv", "HeadInit",
		"Name", "Held", "Change", "Sv", "Init", "Footer" }) do
		labels[child] = control:GetNamedChild(child)
	end
	labels.Title:SetColor(1, 0.41, 0.71, 1)
	labels.Summary:SetColor(0.86, 0.86, 0.86, 1)
	labels.Footer:SetColor(0.67, 0.67, 0.67, 1)
	for _, child in ipairs({ "Name", "Held", "Change", "Sv", "Init" }) do
		labels[child]:SetColor(1, 1, 1, 1)
	end
end

-- ---------------------------------------------------------------------------------------
-- Showing and hiding
-- ---------------------------------------------------------------------------------------

local fragment
local attached = false

local function SetAttached(attach)
	if not control or attach == attached then
		return
	end
	if not fragment then
		fragment = ZO_HUDFadeSceneFragment:New(control)
	end
	for _, scene in ipairs({ HUD_SCENE, HUD_UI_SCENE }) do
		if scene then
			if attach then
				scene:AddFragment(fragment)
			else
				scene:RemoveFragment(fragment)
			end
		end
	end
	attached = attach
end

local function SetAutoScan(on)
	EVENT_MANAGER:UnregisterForUpdate(AUTO_NAME)
	local seconds = tonumber(addon.sv.autoScan) or 0
	if on and seconds > 0 then
		EVENT_MANAGER:RegisterForUpdate(AUTO_NAME, seconds * 1000, function()
			addon:StartScan()
		end)
	end
end

function addon:AutoScanLabel(seconds)
	seconds = tonumber(seconds) or 0
	if seconds <= 0 then
		return GetString(SI_PBSLMM_AUTO_OFF)
	end
	if seconds < 60 then
		return string.format(GetString(SI_PBSLMM_AUTO_SECONDS), seconds)
	end
	return string.format(GetString(SI_PBSLMM_AUTO_MINUTES), math.floor(seconds / 60))
end

function addon:SetAutoScanSeconds(seconds)
	self.sv.autoScan = seconds
	SetAutoScan(self.sv.visible)
	self:RefreshWindow()
end

-- ---------------------------------------------------------------------------------------
-- Position and look
--
-- The position is kept only once it has been moved; until then the window sits where the XML
-- puts it, 60 from the left and centred top to bottom, whatever the screen's size.
-- ---------------------------------------------------------------------------------------

function addon:RootSize()
	if GuiRoot and GuiRoot.GetDimensions then
		return GuiRoot:GetDimensions()
	end
	return 1920, 1080
end

function addon:WindowSize()
	return WINDOW_WIDTH, WINDOW_HEIGHT
end

function addon:DefaultPosition()
	local _, rootHeight = self:RootSize()
	return DEFAULT_X, math.max(0, math.floor((rootHeight - WINDOW_HEIGHT) / 2 + 0.5))
end

function addon:Position()
	local x, y = self:DefaultPosition()
	return self.sv.x or x, self.sv.y or y
end

function addon:ApplyLayout()
	if not control then
		return
	end
	local x, y = self:Position()
	control:ClearAnchors()
	control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
	if labels.Bg then
		labels.Bg:SetAlpha((tonumber(self.sv.bgAlpha) or DEFAULT_BG_ALPHA) / 100)
	end
end

function addon:ShowWindow()
	if not self.rows then
		return
	end
	self.sv.visible = true
	SetAttached(true)
	SetAutoScan(true)
	if not self.lastScan then
		self:StartScan()
	end
	self:RefreshWindow()
end

function addon:HideWindow()
	self.sv.visible = false
	SetAttached(false)
	SetAutoScan(false)
end

function addon:ToggleWindow()
	if self.sv.visible then
		self:HideWindow()
	else
		self:ShowWindow()
	end
end

function addon:OnReady()
	self:ApplyLayout()
	if self.sv.visible then
		self:ShowWindow()
	end
end

function addon:SetSort(key)
	key = (key or ""):lower()
	if not SORT_TITLES[key] then
		-- A bare "sort" moves on to the next order.
		key = SORT_ORDER[1]
		for i, name in ipairs(SORT_ORDER) do
			if name == self.sv.sort then
				key = SORT_ORDER[i % #SORT_ORDER + 1]
			end
		end
	end
	self.sv.sort = key
	self.page = 1
	self:RefreshWindow()
end

function addon:NextPage()
	self.page = self.page + 1
	self:RefreshWindow()
end

-- ---------------------------------------------------------------------------------------
-- Drawing
-- ---------------------------------------------------------------------------------------

local function Change(row)
	return row.heldKB and row.firstHeldKB and (row.heldKB - row.firstHeldKB) or nil
end

-- Rows with no figure for the chosen column go to the bottom.
local function SortValue(row, sort)
	local value
	if sort == "held" then
		value = row.heldKB
	elseif sort == "change" then
		value = Change(row)
	elseif sort == "sv" then
		value = row.svKB
	else
		value = row.initKB
	end
	return value or -math.huge
end

-- Cuts by characters, not bytes, so a Japanese title is never cut mid-character.
local function Truncate(text, limit)
	local count = 0
	for position in text:gmatch("()[\1-\127\194-\244][\128-\191]*") do
		count = count + 1
		if count > limit then
			return text:sub(1, position - 1) .. "…"
		end
	end
	return text
end

local function JoinTitles(titles, limit)
	if #titles <= limit then
		return table.concat(titles, ", ")
	end
	local shown = {}
	for i = 1, limit do
		shown[i] = titles[i]
	end
	return table.concat(shown, ", ") .. string.format(" +%d", #titles - limit)
end

local function Header(stringId, sorted)
	local text = GetString(stringId)
	return sorted and ("|cFF69B4" .. text .. "|r") or text
end

function addon:SummaryText()
	local capacity
	if type(GetTotalUserAddOnMemoryPoolCapacityMB) == "function" then
		local ok, value = pcall(GetTotalUserAddOnMemoryPoolCapacityMB)
		capacity = ok and value or nil
	end
	local heap = self.ReadKB()
	local lines = {
		string.format(GetString(SI_PBSLMM_SUMMARY_MEMORY), self.FormatMB(self.ReadPoolMB()), self.FormatMB(capacity),
			self.FormatMB(self.loginPool), self.FormatMB(heap and heap / 1024)),
	}

	local unmeasured = {}
	for _, row in ipairs(self.rows) do
		if not row.hasEvent then
			unmeasured[#unmeasured + 1] = row.title
		end
	end
	if #unmeasured > 0 then
		lines[#lines + 1] = string.format(GetString(SI_PBSLMM_SUMMARY_NO_EVENT), JoinTitles(unmeasured, 3))
	end

	local scan
	if self.scanning then
		scan = GetString(SI_PBSLMM_SCAN_RUNNING)
	elseif self.lastScan then
		scan = string.format(GetString(SI_PBSLMM_SCAN_DONE), self.lastScan.objects, self.lastScan.seconds)
		if self.lastScan.truncated then
			scan = scan .. GetString(SI_PBSLMM_SCAN_TRUNCATED)
		end
		scan = scan .. "  (" .. self:AutoScanLabel(self.sv.autoScan) .. ")"
	else
		scan = GetString(SI_PBSLMM_SCAN_NONE)
	end
	lines[#lines + 1] = scan

	-- What the last full collection gave back, in the heap and in the add-on pool.
	local collect
	local last = self.lastCollect
	if last and last.ok then
		collect = string.format(GetString(SI_PBSLMM_SUMMARY_COLLECT),
			self.FormatChange(last.heapBefore and last.heapAfter and (last.heapAfter - last.heapBefore)),
			self.FormatChange(last.poolBefore and last.poolAfter and (last.poolAfter - last.poolBefore) * 1024),
			last.ms)
	else
		collect = GetString(SI_PBSLMM_SUMMARY_COLLECT_NONE)
	end
	lines[#lines + 1] = collect .. "  (" .. self:AutoScanLabel(self.sv.collectEvery) .. ")"
	return table.concat(lines, "\n")
end

-- The ranking adds up to the add-on memory the console counts (what /addonmem shows). Two rows
-- stand for what cannot be given to any one add-on:
--   files  the pool as it stood at the first load event -- every add-on's files (their code and
--          what they build at file scope) run before any event, with nothing to measure between
--   other  the rest: the pool now, less files and every add-on's held figure. Garbage not yet
--          collected, data kept only in local variables, controls and textures, allocations the
--          client makes for add-ons, and the estimates' own error all land here. Being a
--          remainder it also absorbs the overlap between the two (a table built at file scope
--          counts in files and in held), and it can go below zero if the estimates run high.
-- Without the pool (the PC client has none) the Lua heap is the total and there is no files row.
function addon:Reconcile()
	local poolMB = self.ReadPoolMB()
	local total = poolMB and poolMB * 1024 or self.ReadKB()
	local files = poolMB and self.filesPoolMB and self.filesPoolMB * 1024 or nil
	local other
	if self.lastScan and total then
		other = total - (files or 0)
		for _, row in ipairs(self.rows) do
			other = other - (row.heldKB or 0)
		end
	end
	return total, files, other
end

function addon:RefreshWindow()
	if not control or not self.rows then
		return
	end
	local sort = SORT_TITLES[self.sv.sort] and self.sv.sort or "held"

	local sorted = {}
	for i, row in ipairs(self.rows) do
		sorted[i] = row
	end
	table.sort(sorted, function(a, b)
		local left, right = SortValue(a, sort), SortValue(b, sort)
		if left ~= right then
			return left > right
		end
		return a.title < b.title
	end)

	local pages = math.max(1, math.ceil(#sorted / PAGE_SIZE))
	if self.page > pages or self.page < 1 then
		self.page = 1
	end
	local first = (self.page - 1) * PAGE_SIZE + 1

	local names, held, change, sv, init = {}, {}, {}, {}, {}
	for i = first, math.min(#sorted, first + PAGE_SIZE - 1) do
		local row = sorted[i]
		names[#names + 1] = string.format("%d. %s", i, Truncate(row.title, NAME_CHARS))
		held[#held + 1] = self.FormatKB(row.heldKB)
		change[#change + 1] = self.FormatChange(Change(row))
		sv[#sv + 1] = self.FormatKB(row.svKB)
		init[#init + 1] = self.FormatKB(row.initKB)
	end

	local total, files, other = self:Reconcile()
	local function AddLine(name, size)
		names[#names + 1] = name
		held[#held + 1] = size
		change[#change + 1] = ""
		sv[#sv + 1] = ""
		init[#init + 1] = ""
	end
	AddLine("", "")
	if files then
		AddLine("|cAAAAAA" .. GetString(SI_PBSLMM_ROW_FILES) .. "|r", self.FormatKB(files))
	end
	AddLine("|cAAAAAA" .. GetString(SI_PBSLMM_ROW_OTHER) .. "|r", self.FormatSignedKB(other))
	AddLine("|cFF69B4" .. GetString(SI_PBSLMM_ROW_TOTAL) .. "|r", self.FormatKB(total))

	labels.Title:SetText(self.title)
	labels.Summary:SetText(self:SummaryText())
	labels.HeadName:SetText(GetString(SI_PBSLMM_COL_NAME))
	labels.HeadHeld:SetText(Header(SI_PBSLMM_COL_HELD, sort == "held"))
	labels.HeadChange:SetText(Header(SI_PBSLMM_COL_CHANGE, sort == "change"))
	labels.HeadSv:SetText(Header(SI_PBSLMM_COL_SV, sort == "sv"))
	labels.HeadInit:SetText(Header(SI_PBSLMM_COL_INIT, sort == "init"))
	labels.Name:SetText(table.concat(names, "\n"))
	labels.Held:SetText(table.concat(held, "\n"))
	labels.Change:SetText(table.concat(change, "\n"))
	labels.Sv:SetText(table.concat(sv, "\n"))
	labels.Init:SetText(table.concat(init, "\n"))
	labels.Footer:SetText(string.format(GetString(SI_PBSLMM_FOOTER), self.page, pages,
		GetString(SORT_TITLES[sort]), self.shortSlash))
end
