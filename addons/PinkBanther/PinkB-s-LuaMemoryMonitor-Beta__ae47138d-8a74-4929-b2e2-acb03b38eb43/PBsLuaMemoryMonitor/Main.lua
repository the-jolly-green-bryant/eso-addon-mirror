-- PB's LuaMemoryMonitor
-- Author: PinkBanther
--
-- Shows how much memory each add-on uses, so the heavy ones can be found.
--
-- The client keeps no per-add-on figure. Every add-on runs in the one Lua state the UI uses,
-- and the only readings are totals: collectgarbage("count") for the whole UI heap, and
-- GetTotalUserAddOnMemoryPoolUsageMB() for the console add-on pool (what /addonmem shows).
--
-- What the probe builds (0.1.x) measured on a PS5, which this design rests on:
--
--   * The client runs every add-on's files first and only then fires EVENT_ADD_ON_LOADED,
--     add-on by add-on: the very first event already saw globals of add-ons that load long
--     after this one. So the events are seen whatever the load order, but what the files
--     themselves allocate -- code, tables built at file scope -- arrives as one lump before the
--     first event and cannot be split per add-on.
--   * Between one event and the next the client loads that add-on's saved variables, and during
--     its event the add-on runs its own OnAddOnLoaded.
--   * Handlers run in the order they were registered, and one re-registered during an event
--     runs at the end of that same event (39 of 40).
--   * _G has to be walked with InsecureNext: next() fails on the client's private functions.
--   * debug holds only traceback, so a function's source file cannot be read.
--
-- So each add-on gets two kinds of figure:
--
--   measured   saved vars  heap growth from the end of the previous event to its own
--              init        heap growth during its own event
--   estimated  held         the tables and strings reachable from its globals, sized by
--                           Scan.lua. A global is the add-on's if it appeared at the add-on's
--                           event, or else if its name contains the add-on's name.

-- The first reading is taken before this add-on allocates anything of its own.
local function ReadKB()
	if type(collectgarbage) ~= "function" then
		return nil
	end
	local ok, kb = pcall(collectgarbage, "count")
	return ok and type(kb) == "number" and kb or nil
end

local function ReadPoolMB()
	if type(GetTotalUserAddOnMemoryPoolUsageMB) ~= "function" then
		return nil
	end
	local ok, mb = pcall(GetTotalUserAddOnMemoryPoolUsageMB)
	return ok and type(mb) == "number" and mb or nil
end

local START_KB, START_POOL = ReadKB(), ReadPoolMB()

if PBS_LUA_MEMORY_MONITOR then
	return
end

local addon = {
	name = "PBsLuaMemoryMonitor",
	startKB = START_KB,
	startPool = START_POOL,
	walkErrors = 0,
	page = 1,
}
PBS_LUA_MEMORY_MONITOR = addon

addon.ReadKB = ReadKB
addon.ReadPoolMB = ReadPoolMB

-- Typographic apostrophe (U+2019), not ASCII ', like the other PB's add-ons.
local DISPLAY_NAME = "PB’s LuaMemoryMonitor"
addon.slash = "/pbluamem"
addon.shortSlash = "/pbmem"

-- On console, plain next() on _G fails as soon as it reaches one of the client's private
-- functions ("Attempt to access a private function ... from insecure code", raised inside next
-- itself). InsecureNext is the VM's iterator for add-on code; the client's zo_insecurePairs is
-- built on it. Every walk still runs under pcall.
addon.Iterate = type(InsecureNext) == "function" and InsecureNext or next
local Iterate = addon.Iterate

function addon.NowMs()
	if type(GetGameTimeMilliseconds) == "function" then
		return GetGameTimeMilliseconds()
	end
	if type(GetFrameTimeMilliseconds) == "function" then
		return GetFrameTimeMilliseconds()
	end
	return 0
end

function addon.ReadAddOns()
	local list = {}
	local manager = GetAddOnManager and GetAddOnManager()
	if not manager then
		return list
	end
	for index = 1, manager:GetNumAddOns() do
		local name, title, _, _, enabled, state, _, isLibrary = manager:GetAddOnInfo(index)
		list[#list + 1] = {
			index = index,
			name = name,
			title = title,
			enabled = enabled,
			state = state,
			isLibrary = isLibrary,
		}
	end
	return list
end

-- "|cFF69B4PB’s MiniMap|r 2.0.18" -> "PB’s MiniMap"
function addon.PlainTitle(title)
	if type(title) ~= "string" then
		return nil
	end
	local plain = title:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("%s+[vV]?%d[%d%.]*%s*$", "")
	plain = plain:match("^%s*(.-)%s*$")
	return plain ~= "" and plain or nil
end

local function ReadManifestVersion()
	for _, entry in ipairs(addon.ReadAddOns()) do
		if entry.name == addon.name and entry.title then
			local plain = entry.title:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
			return plain:match("([%d]+[%d%.]*)%s*$") or ""
		end
	end
	return ""
end

addon.version = ReadManifestVersion()
addon.title = addon.version ~= "" and (DISPLAY_NAME .. " " .. addon.version) or DISPLAY_NAME

-- ---------------------------------------------------------------------------------------
-- Output and formatting
--
-- A message printed at EVENT_ADD_ON_LOADED is thrown away because chat is not up yet, so
-- anything user-facing is either a command response or fires on EVENT_PLAYER_ACTIVATED.
-- ---------------------------------------------------------------------------------------

function addon.Say(text)
	if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
		CHAT_ROUTER:AddSystemMessage(text)
	elseif CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
		CHAT_SYSTEM:AddMessage(text)
	else
		d(text)
	end
end

function addon:HelpText()
	local slash = self.shortSlash
	return string.format(GetString(SI_PBSLMM_HELP), slash, slash, slash, slash, slash, slash)
end

local function Round(value)
	return value >= 0 and math.floor(value + 0.5) or -math.floor(-value + 0.5)
end

-- A heap reading can dip when the collector runs mid-load; a share below zero is shown as 0.
function addon.FormatKB(kb)
	if kb == nil then
		return "-"
	end
	if kb < 0 then
		kb = 0
	end
	if kb >= 1024 then
		return string.format("%.1f MB", kb / 1024)
	end
	return string.format("%d KB", Round(kb))
end

function addon.FormatChange(kb)
	if kb == nil then
		return "-"
	end
	if Round(kb) == 0 then
		return "0"
	end
	if math.abs(kb) >= 1024 then
		return string.format("%+.1f MB", kb / 1024)
	end
	return string.format("%+d KB", Round(kb))
end

-- For a remainder, which can come out below zero when the estimates run high: shown as it is.
function addon.FormatSignedKB(kb)
	if kb ~= nil and kb < 0 then
		return "-" .. addon.FormatKB(-kb)
	end
	return addon.FormatKB(kb)
end

function addon.FormatMB(mb)
	return mb and string.format("%.1f", mb) or "-"
end

-- ---------------------------------------------------------------------------------------
-- Load events
--
-- Every key of _G is remembered once, now. Each EVENT_ADD_ON_LOADED then notes the keys that
-- appeared since, and takes a heap reading at both ends of the event:
--   FIRST  registered now, so it runs before every other add-on's handler; takes the reading
--          the saved-vars share ends at, and walks _G only if LATE did not run on the event
--          before (one walk per event is enough)
--   LATE   unregistered and registered again by FIRST on every event, which moves it to the
--          end of the handler list: its reading comes after the add-on's own OnAddOnLoaded,
--          and its walk catches the globals that handler made
-- The walk's own allocation lies between two readings and is left out of both shares.
-- ---------------------------------------------------------------------------------------

local seen = {}

local function TakeNewGlobals(list)
	local ok, problem = pcall(function()
		for key in Iterate, _G do
			if seen[key] == nil then
				seen[key] = true
				if list and type(key) == "string" then
					list[#list + 1] = key
				end
			end
		end
	end)
	if not ok then
		addon.walkErrors = addon.walkErrors + 1
		addon.lastWalkError = tostring(problem)
	end
end

TakeNewGlobals(nil)
local BASELINE_END_KB = ReadKB()

local FIRST = addon.name .. "_First"
local LATE = addon.name .. "_Late"

local events = {}
addon.events = events
local current

local function OnLoadedLate(_, name)
	if current and current.name == name and current.lateKB == nil then
		current.lateKB = ReadKB()
		TakeNewGlobals(current.globals)
		current.lateEndKB = ReadKB()
	end
end

local function OnLoadedFirst(_, name)
	local previous = events[#events]
	local record = { name = name, kb = ReadKB(), pool = ReadPoolMB(), globals = {} }
	if previous == nil or previous.lateKB == nil then
		TakeNewGlobals(record.globals)
	end
	record.walkEndKB = ReadKB()
	events[#events + 1] = record
	current = record

	EVENT_MANAGER:UnregisterForEvent(LATE, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent(LATE, EVENT_ADD_ON_LOADED, OnLoadedLate)
end

EVENT_MANAGER:RegisterForEvent(FIRST, EVENT_ADD_ON_LOADED, OnLoadedFirst)

local DEFAULTS = {
	visible = false,
	sort = "held",
	autoScan = 60,
	bgAlpha = 78,
	banner = true,
	collectEvery = 0,
	collectInCombat = false,
	-- x, y: absent until the window is moved; Window.lua works out the default.
}

local function OnOwnLoaded(_, name)
	if name ~= addon.name then
		return
	end
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
	addon.sv = ZO_SavedVars:NewAccountWide("PBsLuaMemoryMonitor_Data", 1, nil, DEFAULTS)
	if addon.InitSettings then
		addon:InitSettings()
	end
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnOwnLoaded)

-- ---------------------------------------------------------------------------------------
-- Rows
--
-- Built once, at login: one row per add-on that loaded, with its two measured shares, and the
-- owner of every global that appeared at an event. The client's own ZO_ modules fire the event
-- too; their globals are marked false, the client's. The first event's globals and heap growth
-- are the lump of every file loaded after this one, so neither is given to anyone.
-- ---------------------------------------------------------------------------------------

local function IsLoaded(entry)
	if not entry.enabled then
		return false
	end
	return ADDON_STATE_ENABLED == nil or entry.state == ADDON_STATE_ENABLED
end

local function BuildRows()
	EVENT_MANAGER:UnregisterForEvent(FIRST, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:UnregisterForEvent(LATE, EVENT_ADD_ON_LOADED)
	current = nil
	seen = nil

	local rows, byName = {}, {}
	for _, entry in ipairs(addon.ReadAddOns()) do
		if IsLoaded(entry) then
			local row = {
				name = entry.name,
				title = addon.PlainTitle(entry.title) or entry.name,
				isLibrary = entry.isLibrary,
			}
			rows[#rows + 1] = row
			byName[row.name] = row
		end
	end

	local owner = {}
	local previousEnd = BASELINE_END_KB
	for i, record in ipairs(events) do
		local load = record.kb and previousEnd and (record.kb - previousEnd)
		local init = record.lateKB and record.walkEndKB and (record.lateKB - record.walkEndKB)
		previousEnd = record.lateEndKB or record.walkEndKB

		local row = byName[record.name]
		if i == 1 then
			addon.fileLumpKB = load
			-- The add-on pool as it stood when the first event fired: every add-on's files had
			-- run, and nothing else had yet. Window.lua shows it as the "file loading" row.
			addon.filesPoolMB = record.pool
		end
		if row then
			row.hasEvent = true
			row.initKB = init
			if i > 1 then
				row.svKB = load
			end
		end
		if i > 1 then
			for _, key in ipairs(record.globals) do
				owner[key] = row and row.name or false
			end
		end
		record.globals = nil
	end

	addon.rows = rows
	addon.rowsByName = byName
	addon.owner = owner
	if not addon.sv then
		addon.sv = {}
		for key, value in pairs(DEFAULTS) do
			addon.sv[key] = value
		end
	end
end

-- ---------------------------------------------------------------------------------------
-- Commands and start-up
-- ---------------------------------------------------------------------------------------

local function OnCommand(argument)
	if not addon.rows then
		addon.Say(GetString(SI_PBSLMM_NOT_READY))
		return
	end
	local command, rest = (argument or ""):match("^%s*(%S*)%s*(.-)%s*$")
	command = (command or ""):lower()
	if command == "" then
		addon:ToggleWindow()
	elseif command == "scan" then
		addon:ShowWindow()
		addon:StartScan()
	elseif command == "sort" then
		addon:SetSort(rest)
		addon:ShowWindow()
	elseif command == "next" then
		addon:NextPage()
		addon:ShowWindow()
	elseif command == "detail" then
		addon:PrintDetail(rest)
	elseif command == "gc" then
		addon:CollectNow(true)
	else
		addon.Say(addon:HelpText())
	end
end

SLASH_COMMANDS[addon.slash] = OnCommand
SLASH_COMMANDS[addon.shortSlash] = OnCommand

local function OnPlayerActivated()
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED)
	BuildRows()
	addon.loginKB = ReadKB()
	addon.loginPool = ReadPoolMB()
	if addon.OnReady then
		addon:OnReady()
	end
	if addon.ApplyCollectTimer then
		addon:ApplyCollectTimer()
	end
	if addon.sv.banner ~= false then
		addon.Say(string.format(GetString(SI_PBSLMM_LOADED), addon.title, addon.shortSlash))
	end
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
