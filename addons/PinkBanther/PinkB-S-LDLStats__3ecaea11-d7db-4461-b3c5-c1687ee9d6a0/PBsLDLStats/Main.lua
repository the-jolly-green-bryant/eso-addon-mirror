-- PB's LDL Stats
-- Author: PinkBanther
--
-- Reports what LibDebugLogger holds, to answer one question: why does the log fill up?
-- The library's author expects 500-1500 entries per session. The stock library also keeps
-- entries from earlier sessions for up to a day (they come back from saved variables at every
-- login, character switch and /reloadui), so the report splits the log into sessions and shows
-- which tags and messages take up the most entries.
--
-- The report goes to chat with CHAT_ROUTER:AddSystemMessage, not d(): LibDebugLogger logs every
-- d() call, so printing with d() would add to the very log being counted.

if PBS_LDL_STATS then
	return
end

local addon = {
	name = "PBsLDLStats",
}
PBS_LDL_STATS = addon

local TOP_TAGS = 5
local TOP_MESSAGES = 5
local SESSIONS_SHOWN = 10
local EXCERPT_BYTES = 48
local SESSION_MARKER = "Initializing..."
local PRINT_DELAY_MS = 3000

local function MessageText(value)
	-- the stock library splits text longer than 1999 bytes into a table of chunks
	if type(value) == "table" then
		return value[1] or ""
	end
	return type(value) == "string" and value or ""
end

local function TextBytes(value)
	if type(value) == "table" then
		local bytes = 0
		for i = 1, #value do
			bytes = bytes + #value[i]
		end
		return bytes
	end
	return type(value) == "string" and #value or 0
end

local function Excerpt(text)
	text = text:gsub("[\r\n]+", " ")
	if #text > EXCERPT_BYTES then
		local cut = EXCERPT_BYTES
		-- step back to the start of a UTF-8 character so the excerpt does not end in half of one
		while cut > 1 do
			local byte = text:byte(cut + 1)
			if not byte or byte < 0x80 or byte >= 0xC0 then
				break
			end
			cut = cut - 1
		end
		text = text:sub(1, cut) .. "..."
	end
	-- a lone | starts a markup code in chat; || shows a literal one
	return (text:gsub("|", "||"))
end

local function FormatKB(bytes)
	if bytes >= 1024 * 1024 then
		return string.format("%.2f MB", bytes / (1024 * 1024))
	end
	return string.format("%.1f KB", bytes / 1024)
end

local function TopEntries(map, limit)
	local list = {}
	for key, stats in pairs(map) do
		list[#list + 1] = { key = key, entries = stats.entries, repeats = stats.repeats }
	end
	table.sort(list, function(a, b)
		if a.entries ~= b.entries then
			return a.entries > b.entries
		end
		return a.repeats > b.repeats
	end)
	for i = #list, limit + 1, -1 do
		list[i] = nil
	end
	return list
end

local function FindLibraryVersion(name)
	if type(GetAddOnManager) ~= "function" then
		return nil
	end
	local manager = GetAddOnManager()
	for i = 1, manager:GetNumAddOns() do
		local addOnName = manager:GetAddOnInfo(i)
		if addOnName == name then
			return manager:GetAddOnVersion(i)
		end
	end
	return nil
end

--- @return the report as a list of chat lines
function addon.BuildReport(lib)
	local lines = {}
	if not lib or type(lib.GetLog) ~= "function" then
		lines[1] = "[LDL stats] LibDebugLogger is not loaded"
		return lines
	end

	local log = lib:GetLog()
	local TIME = lib.ENTRY_TIME_INDEX
	local COUNT = lib.ENTRY_OCCURENCES_INDEX
	local LEVEL = lib.ENTRY_LEVEL_INDEX
	local TAG = lib.ENTRY_TAG_INDEX
	local MESSAGE = lib.ENTRY_MESSAGE_INDEX
	local STACK = lib.ENTRY_STACK_INDEX

	local numEntries = #log
	local totalRepeats = 0
	local levels = {}
	local tags = {}
	local messages = {} -- messages[tag][text] = stats; nested so no key strings are built
	local sessions = {}
	local sessionEntries = 0
	local messageBytes, stackBytes, numStacks = 0, 0, 0

	for i = 1, numEntries do
		local entry = log[i]
		local tag = entry[TAG] or "?"
		local repeats = entry[COUNT] or 1
		local text = MessageText(entry[MESSAGE])

		if tag == lib.id and text:sub(1, #SESSION_MARKER) == SESSION_MARKER then
			if i > 1 then
				sessions[#sessions + 1] = sessionEntries
			end
			sessionEntries = 0
		end
		sessionEntries = sessionEntries + 1

		totalRepeats = totalRepeats + repeats
		local level = entry[LEVEL] or "?"
		levels[level] = (levels[level] or 0) + 1

		local tagStats = tags[tag]
		if not tagStats then
			tagStats = { entries = 0, repeats = 0 }
			tags[tag] = tagStats
		end
		tagStats.entries = tagStats.entries + 1
		tagStats.repeats = tagStats.repeats + repeats

		local byText = messages[tag]
		if not byText then
			byText = {}
			messages[tag] = byText
		end
		local messageStats = byText[text]
		if not messageStats then
			messageStats = { entries = 0, repeats = 0 }
			byText[text] = messageStats
		end
		messageStats.entries = messageStats.entries + 1
		messageStats.repeats = messageStats.repeats + repeats

		messageBytes = messageBytes + TextBytes(entry[MESSAGE])
		-- the stock library stores "" when there is no stack, so only a non-empty one counts
		local bytes = TextBytes(entry[STACK])
		if bytes > 0 then
			numStacks = numStacks + 1
			stackBytes = stackBytes + bytes
		end
	end
	if numEntries > 0 then
		sessions[#sessions + 1] = sessionEntries
	end

	local version = FindLibraryVersion(lib.id)
	local build = type(lib.GetNumEntries) == "function" and "modified build, this session only" or "stock build"
	lines[#lines + 1] = string.format("[LDL stats] %s AddOnVersion %s (%s)", lib.id, tostring(version or "?"), build)

	local age = ""
	if numEntries > 0 and lib.SESSION_START_TIME and type(GetGameTimeMilliseconds) == "function" then
		local now = lib.SESSION_START_TIME + GetGameTimeMilliseconds()
		age = string.format(", oldest %.1f h ago", (now - (log[1][TIME] or now)) / 3600000)
	end
	lines[#lines + 1] = string.format("Entries: %d (%d with repeats)%s", numEntries, totalRepeats, age)

	local perSession = {}
	for i = #sessions, math.max(1, #sessions - SESSIONS_SHOWN + 1), -1 do
		perSession[#perSession + 1] = tostring(sessions[i])
	end
	lines[#lines + 1] = string.format("Sessions: %d | entries per session, newest first: %s",
		#sessions, table.concat(perSession, ", "))

	lines[#lines + 1] = string.format("Levels: E %d, W %d, I %d, D %d, V %d",
		levels.E or 0, levels.W or 0, levels.I or 0, levels.D or 0, levels.V or 0)

	-- 56 byte table header plus 8 array slots of 16 bytes, the layout of a stock entry
	local entryBytes = numEntries * (56 + 8 * 16)
	lines[#lines + 1] = string.format("Size: entries %s, messages %s, stacks %s (%d with a stack)",
		FormatKB(entryBytes), FormatKB(messageBytes), FormatKB(stackBytes), numStacks)

	lines[#lines + 1] = "Top tags (entries / with repeats):"
	for _, item in ipairs(TopEntries(tags, TOP_TAGS)) do
		lines[#lines + 1] = string.format("  %s  %d / %d", Excerpt(item.key), item.entries, item.repeats)
	end

	-- flatten tag -> text into one list only for the ranking
	local flat = {}
	for tag, byText in pairs(messages) do
		for text, stats in pairs(byText) do
			flat[#flat + 1] = { key = { tag = tag, text = text }, entries = stats.entries, repeats = stats.repeats }
		end
	end
	table.sort(flat, function(a, b)
		if a.entries ~= b.entries then
			return a.entries > b.entries
		end
		return a.repeats > b.repeats
	end)
	lines[#lines + 1] = "Top messages (entries / with repeats):"
	for i = 1, math.min(TOP_MESSAGES, #flat) do
		local item = flat[i]
		lines[#lines + 1] = string.format("  [%s] %d / %d  %s",
			Excerpt(item.key.tag), item.entries, item.repeats, Excerpt(item.key.text))
	end

	return lines
end

local function PrintReport()
	local ok, result = pcall(addon.BuildReport, LibDebugLogger)
	if not ok then
		result = { "[LDL stats] failed: " .. tostring(result) }
	end
	for i = 1, #result do
		CHAT_ROUTER:AddSystemMessage(result[i])
	end
end
addon.PrintReport = PrintReport

local function OnPlayerActivated()
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED)
	-- give the chat window a moment, so the report is not lost behind the login messages
	zo_callLater(PrintReport, PRINT_DELAY_MS)
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
SLASH_COMMANDS["/ldlstats"] = PrintReport
