-- PB's CraftMaterialAssistant
-- Author: PinkBanther
--
-- "How many of these do I still need?" -- answered in a window, while you are standing at the
-- station rather than after you have walked to it.
--
-- Pick something you know how to make, say how many times you want to make it, and the window
-- lists every ingredient it takes, how many you are carrying, and how many you are short.
--
-- ---------------------------------------------------------------------------------------
-- WHAT COUNTS AS A CRAFTABLE ITEM HERE
-- ---------------------------------------------------------------------------------------
--
-- Recipes: everything the client keeps in the recipe lists. That is food, drink, and every
-- furnishing plan, blueprint, design, diagram, pattern, praxis, formula and sketch -- they all
-- live in the same system and are all read with the same five functions:
--
--     GetNumRecipeLists()                                    how many categories there are
--     GetRecipeListInfo(list)          -> name, numRecipes
--     GetRecipeInfo(list, recipe)      -> known, name, numIngredients, ..., resultItemId
--     GetRecipeIngredientItemInfo(list, recipe, i)  -> name, icon, requiredQuantity
--     GetRecipeIngredientItemLink(list, recipe, i, style) -> link, for counting what you hold
--
-- Every one is a read of data the client already holds. Nothing here asks the server for
-- anything, nothing here crafts anything, and taking the add-on out leaves no trace.
--
-- Smithing (blacksmithing, clothier, woodworking, jewellery), alchemy and enchanting are NOT
-- here. They are not a list you pick one row out of: a smithed item is a pattern crossed with
-- a material, a material quantity that IS the item level, a style and a trait, and alchemy and
-- enchanting are combinations rather than entries. They would need their own picker, and they
-- can be added later without disturbing anything below -- Recipes.lua is the only file that
-- knows where a requirement came from.
--
-- ---------------------------------------------------------------------------------------
-- WHY THE PICKER IS SHAPED THE WAY IT IS
-- ---------------------------------------------------------------------------------------
--
-- There are thousands of recipes, so the list has to be narrowed before it can be shown, and
-- narrowing it on a console means text entry -- the one thing a controller is worst at.
--
-- So the add-on never asks the settings library to draw a list that changes. The candidates
-- are drawn in the add-on's OWN window, which it controls completely, and the panel offers
-- only rows whose labels are fixed: a category dropdown built once from the client's own
-- recipe-list names, a "candidate number" slider, and a button that takes the number the
-- slider is on. Moving the slider moves a marker in the window, so the choosing happens where
-- the names are.
--
-- Text search is /pbcraft find <text>, which is the input route every other PB's add-on uses
-- and the only one proven to work on a PS5. If the settings library on this client turns out
-- to have an edit row, Settings.lua adds one as well -- but nothing depends on it.
--
-- ---------------------------------------------------------------------------------------
-- WHAT IT DOES WHEN IT IS NOT SURE
-- ---------------------------------------------------------------------------------------
--
--   * recipe API missing on this client       -> nothing is scanned, /pbcraft says so
--   * a stored pick whose index has moved      -> re-found by its result item id, and only
--     (a patch inserted recipes above it)         given up on when that fails too
--   * an ingredient the client will not price  -> the row is drawn with a held count of 0
--   * a count the client will not give at all  -> "?" in the column, never a guessed number
--   * nothing picked yet                       -> the window says so instead of drawing an
--                                                 empty table
-- ---------------------------------------------------------------------------------------

if PBS_CRAFT_MATERIAL_ASSISTANT then
	return
end

local addon = {
	name = "PBsCraftMaterialAssistant",
}

local em = EVENT_MANAGER

-- The display name is a Lua constant and the version comes from the manifest, the same way
-- every other PB's add-on does it -- reading the name back out of "## Title" mangles the
-- "PB's " prefix in the settings library.
--
-- TYPOGRAPHIC apostrophe (U+2019). With an ASCII ' here the settings panel eats the whole
-- "PB's " and shows "CraftMaterialAssistant". The manifest keeps the ASCII form, because that
-- is what the in-game add-on list and the store listing want. Written as the character itself
-- and not as "\u{2019}": that escape is Lua 5.3 and the client is 5.1.
local DISPLAY_NAME = "PB’s CraftMaterialAssistant"
local AUTHOR = "PinkBanther"
local SLASH = "/pbcraft"
local SHORT_SLASH = "/pbcm"

local function ReadManifestVersion()
	local manager = GetAddOnManager and GetAddOnManager()
	if not manager then
		return ""
	end
	for index = 1, manager:GetNumAddOns() do
		local name, title = manager:GetAddOnInfo(index)
		if name == addon.name and title then
			local plain = title:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
			return plain:match("([%d]+[%d%.]*)%s*$") or ""
		end
	end
	return ""
end

addon.author = AUTHOR
addon.baseTitle = DISPLAY_NAME
addon.version = ReadManifestVersion()
addon.title = addon.version ~= "" and (DISPLAY_NAME .. " " .. addon.version) or DISPLAY_NAME
addon.slash = SLASH

-- ---------------------------------------------------------------------------------------
-- Output
--
-- The add-on never writes to chat on its own. Not at login, not when a setting is changed,
-- not when the material table changes -- every line below happens because somebody typed a command,
-- and is the answer to that command.
--
-- That is the whole rule, and it is worth stating as one: an add-on with a display surface of
-- its own has no business also keeping a running commentary in the chat window, which is
-- somebody's conversation. Anything the add-on wants to say about itself goes in the window;
-- anything it is asked goes back to whoever asked.
--
-- The material table never goes to chat either way: it is a table, and a table pushed through
-- a chat window one line at a time is what this add-on exists to avoid.
-- ---------------------------------------------------------------------------------------

local function Say(text)
	if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
		CHAT_ROUTER:AddSystemMessage(text)
	elseif CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
		CHAT_SYSTEM:AddMessage(text)
	else
		d(text)
	end
end

local function Line(text, ...)
	if select("#", ...) > 0 then
		local ok, formatted = pcall(string.format, text, ...)
		Say(ok and formatted or text)
	else
		Say(text)
	end
end

local PREFIX = "|cFF69B4" .. DISPLAY_NAME .. "|r: "

local function Print(text, ...)
	if select("#", ...) > 0 then
		local ok, formatted = pcall(string.format, text, ...)
		Line(PREFIX .. (ok and formatted or text))
	else
		Line(PREFIX .. text)
	end
end

addon.Say = Say
addon.Line = Line
addon.Print = Print

local function Format(stringId, ...)
	local ok, text = pcall(string.format, GetString(stringId), ...)
	return ok and text or GetString(stringId)
end

addon.Format = Format

-- ---------------------------------------------------------------------------------------
-- Where "how many do I have" is counted
--
-- GetItemLinkStacks answers with six numbers for one link -- backpack, bank, craft bag, house
-- banks, furniture vault, vengeance bag -- which is the whole reason this add-on does not walk
-- the bags itself. Walking BAG_BACKPACK and BAG_BANK slot by slot for eight ingredients, every
-- time a single item moves, is work; this is six numbers already in memory.
--
-- The craft bag is in the default scope because that is where a subscriber's ingredients
-- actually are, and a shopping list that says you have none of something sitting in the craft
-- bag is worse than no list. It is a setting because a non-subscriber has no craft bag, and
-- because "what is on me right now" is a fair question to want answered.
--
-- House banks are last and off by default: they are real storage, but they are storage you
-- cannot reach from a crafting station, so counting them by default would answer the wrong
-- question.
-- ---------------------------------------------------------------------------------------

addon.SCOPES = {
	{ token = "BACKPACK", label = "SI_PBSCMA_SCOPE_BACKPACK" },
	{ token = "BANK", label = "SI_PBSCMA_SCOPE_BANK" },
	{ token = "CRAFTBAG", label = "SI_PBSCMA_SCOPE_CRAFTBAG" },
	{ token = "ALL", label = "SI_PBSCMA_SCOPE_ALL" },
}

local SCOPE_VALID = {}
for _, scope in ipairs(addon.SCOPES) do
	SCOPE_VALID[scope.token] = true
end
addon.SCOPE_VALID = SCOPE_VALID

-- ---------------------------------------------------------------------------------------
-- Limits
--
-- PAGE_SIZE is how many candidates are drawn in the window at once, and the "candidate
-- number" slider in the panel runs 1..PAGE_SIZE. It is deliberately small: the slider is
-- driven with a thumbstick, and a page you can read without scrolling is a page you can
-- choose from without scrolling.
--
-- MAX_MATCHES bounds what a search is allowed to remember. A search for "e" against a
-- Japanese client matches nothing and against an English one matches most of the game; the
-- cap is what keeps that from turning into a few thousand small tables in a memory pool every
-- add-on on the machine shares.
-- ---------------------------------------------------------------------------------------

addon.PAGE_SIZE = 12
addon.MAX_PAGES = 40
addon.MAX_MATCHES = addon.PAGE_SIZE * addon.MAX_PAGES
addon.MIN_QUANTITY, addon.MAX_QUANTITY = 1, 200

-- ---------------------------------------------------------------------------------------
-- Settings
-- ---------------------------------------------------------------------------------------

local DEFAULTS = {
	-- The master switch. Off, the window is taken down and the inventory events are
	-- unregistered -- the add-on costs nothing at all until it is switched back on.
	enabled = true,

	-- Only recipes this character has learned. Off, the picker also shows recipes you own the
	-- book for but have not read, which is useful when you are deciding what to learn.
	knownOnly = true,

	scope = "CRAFTBAG",

	-- What is being made. The indices are how the client is asked; the name and the result
	-- item id are how the pick is recognised again after a patch has moved the indices.
	target = {
		list = 0,
		recipe = 0,
		name = "",
		itemId = 0,
		quantity = 1,
	},

	-- The picker's state. Kept in saved variables so that a reloadui in the middle of choosing
	-- does not throw away the search you just typed with a controller.
	browse = {
		text = "",
		category = 0,
		page = 1,
		cursor = 1,
		showing = false,
	},

	window = {
		width = 620,
		height = 420,
		size = 26,
		face = "$(GAMEPAD_MEDIUM_FONT)",
		style = "soft-shadow-thin",
		position = "TOPLEFT",
		offsetX = 60,
		offsetY = 140,
		draw = "FRONT",
		opacity = 70,
	},
}

addon.DEFAULTS = DEFAULTS

-- Filled in by Recipes.lua and Hud.lua. Declared here so that every caller below can reach
-- them without asking whether the file that owns them has run yet.
addon.recipes = {}
addon.hud = {}

-- The last search's results: { { list = , recipe = , name = , category = } , ... }
-- Never saved. It is derived from the client, it can be a few hundred entries, and rebuilding
-- it costs one scan.
addon.matches = {}
addon.searched = false

local function Clamp(value, low, high)
	value = tonumber(value)
	if not value then
		return nil
	end
	if value < low then
		return low
	elseif value > high then
		return high
	end
	return value
end

addon.Clamp = Clamp

function addon:Enabled()
	return self.sv and self.sv.enabled ~= false
end

function addon:SetEnabled(value)
	self.sv.enabled = value and true or false
	self:ApplyEvents()
	self.hud:Refresh()
end

function addon:Scope()
	local wanted = self.sv and self.sv.scope
	if SCOPE_VALID[wanted] then
		return wanted
	end
	return DEFAULTS.scope
end

function addon:SetScope(token)
	if not SCOPE_VALID[token] then
		return false
	end
	self.sv.scope = token
	self.hud:Refresh()
	return true
end

function addon:Quantity()
	return Clamp(self.sv and self.sv.target and self.sv.target.quantity,
		self.MIN_QUANTITY, self.MAX_QUANTITY) or 1
end

function addon:SetQuantity(value)
	local quantity = Clamp(value, self.MIN_QUANTITY, self.MAX_QUANTITY)
	if not quantity then
		return false
	end
	self.sv.target.quantity = math.floor(quantity)
	self.hud:Refresh()
	return true
end

-- ---------------------------------------------------------------------------------------
-- The pick
-- ---------------------------------------------------------------------------------------

function addon:HasTarget()
	local target = self.sv and self.sv.target
	return target ~= nil and (target.list or 0) >= 1 and (target.recipe or 0) >= 1
end

function addon:Select(entry)
	if not entry then
		return false
	end
	local target = self.sv.target
	target.list = entry.list
	target.recipe = entry.recipe
	target.name = entry.name or ""
	target.itemId = entry.itemId or 0
	-- The quantity is deliberately kept across a change of pick. Somebody making twenty of one
	-- thing is usually about to make twenty of the next.
	self.sv.browse.showing = false
	self:ApplyEvents()
	self.hud:Refresh()
	return true
end

function addon:ClearTarget()
	local target = self.sv.target
	target.list, target.recipe, target.name, target.itemId = 0, 0, "", 0
	self:ApplyEvents()
	self.hud:Refresh()
end

-- ---------------------------------------------------------------------------------------
-- The picker's page
-- ---------------------------------------------------------------------------------------

function addon:PageCount()
	local total = #self.matches
	if total <= 0 then
		return 1
	end
	local pages = math.ceil(total / self.PAGE_SIZE)
	if pages > self.MAX_PAGES then
		pages = self.MAX_PAGES
	end
	return pages
end

function addon:Page()
	return Clamp(self.sv and self.sv.browse and self.sv.browse.page, 1, self:PageCount()) or 1
end

function addon:SetPage(value)
	local page = Clamp(value, 1, self:PageCount())
	if not page then
		return false
	end
	self.sv.browse.page = math.floor(page)
	self.hud:Refresh()
	return true
end

function addon:Cursor()
	return Clamp(self.sv and self.sv.browse and self.sv.browse.cursor, 1, self.PAGE_SIZE) or 1
end

function addon:SetCursor(value)
	local cursor = Clamp(value, 1, self.PAGE_SIZE)
	if not cursor then
		return false
	end
	self.sv.browse.cursor = math.floor(cursor)
	-- Redrawn rather than merely stored: the marker moving in the window while the slider
	-- moves is the whole of what makes this a picker rather than a number entry.
	self.hud:Refresh()
	return true
end

-- The candidates on the page that is showing, in the order they are drawn.
function addon:PageEntries()
	local page = self:Page()
	local first = (page - 1) * self.PAGE_SIZE + 1
	local entries = {}
	for offset = 0, self.PAGE_SIZE - 1 do
		local entry = self.matches[first + offset]
		if not entry then
			break
		end
		entries[offset + 1] = entry
	end
	return entries
end

function addon:EntryAt(number)
	local entries = self:PageEntries()
	return entries[math.floor(tonumber(number) or 0)]
end

function addon:Showing()
	return self.sv and self.sv.browse and self.sv.browse.showing == true
end

function addon:SetShowing(value)
	self.sv.browse.showing = value and true or false
	if value and not self.searched then
		-- Somebody asked for the list before asking for anything in particular. The whole
		-- catalogue, narrowed by whatever the category is set to, is a reasonable answer --
		-- and it is exactly what an empty search means.
		self:Search(self.sv.browse.text or "")
	end
	-- The browse flag is one of the three things WantsInventoryEvents is made of, so it has
	-- to be re-asked here: while the candidate list is up there is no material table to keep
	-- current, and no reason to be listening to the bags.
	self:ApplyEvents()
	self.hud:Refresh()
end

-- ---------------------------------------------------------------------------------------
-- Redrawing
--
-- Inventory traffic is bursty: looting a container, emptying a bag into the bank and crafting
-- all fire the single-slot event many times in a row. Each one is answered by setting a flag
-- and asking for one redraw a little later, so a hundred events cost one pass over eight
-- ingredients rather than a hundred.
--
-- The events are only registered while there is something to redraw -- switched on, with a
-- pick, not in the middle of browsing. An add-on that is not showing you anything should not
-- be listening to your bags.
-- ---------------------------------------------------------------------------------------

local REFRESH_DELAY_MS = 400

function addon:QueueRefresh()
	if self.refreshQueued then
		return
	end
	self.refreshQueued = true
	zo_callLater(function()
		self.refreshQueued = false
		self.hud:Refresh()
	end, REFRESH_DELAY_MS)
end

function addon:WantsInventoryEvents()
	return self:Enabled() and self:HasTarget() and not self:Showing()
end

function addon:ApplyEvents()
	local wanted = self:WantsInventoryEvents()
	if wanted == self.eventsRegistered then
		return
	end
	self.eventsRegistered = wanted

	if not wanted then
		if EVENT_INVENTORY_SINGLE_SLOT_UPDATE then
			em:UnregisterForEvent(self.name .. "Inv", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
		end
		if EVENT_INVENTORY_FULL_UPDATE then
			em:UnregisterForEvent(self.name .. "InvFull", EVENT_INVENTORY_FULL_UPDATE)
		end
		if EVENT_CRAFT_COMPLETED then
			em:UnregisterForEvent(self.name .. "Craft", EVENT_CRAFT_COMPLETED)
		end
		return
	end

	local queue = function()
		self:QueueRefresh()
	end
	if EVENT_INVENTORY_SINGLE_SLOT_UPDATE then
		em:RegisterForEvent(self.name .. "Inv", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, queue)
	end
	if EVENT_INVENTORY_FULL_UPDATE then
		em:RegisterForEvent(self.name .. "InvFull", EVENT_INVENTORY_FULL_UPDATE, queue)
	end
	if EVENT_CRAFT_COMPLETED then
		em:RegisterForEvent(self.name .. "Craft", EVENT_CRAFT_COMPLETED, queue)
	end
end

-- Settings.lua fills this in when the library is there. Defined here so every command can
-- call it without asking whether a panel exists.
function addon:RefreshPanel()
	if self.settingsControls and self.settingsControls.UpdateControls then
		self.settingsControls:UpdateControls()
	end
end

-- ---------------------------------------------------------------------------------------
-- The slash command
-- ---------------------------------------------------------------------------------------

local function Words(text)
	local words = {}
	for word in tostring(text or ""):gmatch("%S+") do
		words[#words + 1] = word
	end
	return words
end

local function OnOff(value)
	return GetString(value and SI_PBSCMA_ON or SI_PBSCMA_OFF)
end

local function ParseSwitch(word)
	word = tostring(word or ""):lower()
	if word == "on" or word == "1" or word == "true" then
		return true
	elseif word == "off" or word == "0" or word == "false" then
		return false
	end
	return nil
end

function addon:PrintStatus()
	if not self.recipes:Available() then
		Print(GetString(SI_PBSCMA_ERROR_NO_API))
		return
	end

	if self:HasTarget() then
		local summary = self.recipes:Summary()
		if summary then
			Print(Format(SI_PBSCMA_STATUS_TARGET, summary.name, self:Quantity()))
			Print(Format(SI_PBSCMA_STATUS_SHORT, summary.shortCount, summary.craftable))
		else
			Print(GetString(SI_PBSCMA_STATUS_LOST))
		end
	else
		Print(GetString(SI_PBSCMA_STATUS_NO_TARGET))
	end

	Print(Format(SI_PBSCMA_STATUS_SCOPE, GetString(_G[self:ScopeLabel()])))
	if not self.hud:Available() then
		Print(GetString(SI_PBSCMA_ERROR_NO_WINDOW))
	elseif self.hud.drawOrderRefused then
		-- Said here rather than at the moment the dropdown was changed: the panel is not a
		-- place this add-on speaks from, and a refusal that only mattered once is still true
		-- the next time the status is asked for.
		Print(GetString(SI_PBSCMA_ERROR_DRAW_REFUSED))
	end
end

function addon:ScopeLabel()
	local token = self:Scope()
	for _, scope in ipairs(self.SCOPES) do
		if scope.token == token then
			return scope.label
		end
	end
	return self.SCOPES[1].label
end

function addon:PrintMatches()
	local entries = self:PageEntries()
	if #entries == 0 then
		Print(GetString(SI_PBSCMA_REPLY_NO_MATCHES))
		return
	end
	Print(Format(SI_PBSCMA_REPLY_MATCHES, #self.matches, self:Page(), self:PageCount()))
	for number, entry in ipairs(entries) do
		Line("  %d. %s  |c888888(%s)|r", number, entry.name, entry.category or "")
	end
	Print(GetString(SI_PBSCMA_REPLY_PICK_HINT))
end

function addon:PrintCategories()
	local categories = self.recipes:Categories()
	if #categories == 0 then
		Print(GetString(SI_PBSCMA_ERROR_NO_API))
		return
	end
	Print(GetString(SI_PBSCMA_REPLY_CATEGORIES))
	Line("  0. %s", GetString(SI_PBSCMA_CATEGORY_ALL))
	for _, category in ipairs(categories) do
		Line("  %d. %s", category.index, category.name)
	end
end

function addon:PrintHelp()
	Print(GetString(SI_PBSCMA_HELP_HEADER))
	for _, stringId in ipairs({
		SI_PBSCMA_HELP_STATUS,
		SI_PBSCMA_HELP_FIND,
		SI_PBSCMA_HELP_PICK,
		SI_PBSCMA_HELP_PAGE,
		SI_PBSCMA_HELP_QTY,
		SI_PBSCMA_HELP_LIST,
		SI_PBSCMA_HELP_CAT,
		SI_PBSCMA_HELP_KNOWN,
		SI_PBSCMA_HELP_SCOPE,
		SI_PBSCMA_HELP_BROWSE,
		SI_PBSCMA_HELP_CLEAR,
		SI_PBSCMA_HELP_MASTER,
		SI_PBSCMA_HELP_PROBE,
		SI_PBSCMA_HELP_RESET,
	}) do
		Line("  " .. GetString(stringId))
	end
end

function addon:HandleCommand(argumentString)
	local words = Words(argumentString)
	local command = (words[1] or ""):lower()

	if command == "" or command == "status" then
		self:PrintStatus()
		return
	end

	if command == "help" or command == "?" then
		self:PrintHelp()
		return
	end

	if command == "find" or command == "search" then
		-- Everything after the command word, spaces and all: a recipe name is usually more
		-- than one word, and "Solitude Salmon-Millet" is not two searches.
		local text = tostring(argumentString or ""):gsub("^%s*%S+%s*", "")
		self:Search(text)
		self:SetShowing(true)
		self:RefreshPanel()
		self:PrintMatches()
		return
	end

	if command == "pick" then
		local number = tonumber(words[2] or "")
		if not number then
			Print(GetString(SI_PBSCMA_ERROR_NEED_NUMBER))
			return
		end
		local entry = self:EntryAt(number)
		if not entry then
			Print(GetString(SI_PBSCMA_ERROR_NO_SUCH_CANDIDATE))
			return
		end
		self:Select(entry)
		self:RefreshPanel()
		Print(Format(SI_PBSCMA_REPLY_PICKED, entry.name, self:Quantity()))
		return
	end

	if command == "next" or command == "prev" then
		local step = command == "next" and 1 or -1
		self:SetPage(self:Page() + step)
		self:RefreshPanel()
		self:PrintMatches()
		return
	end

	if command == "page" then
		local number = tonumber(words[2] or "")
		if not number then
			Print(GetString(SI_PBSCMA_ERROR_NEED_NUMBER))
			return
		end
		self:SetPage(number)
		self:RefreshPanel()
		self:PrintMatches()
		return
	end

	if command == "qty" or command == "count" then
		local number = tonumber(words[2] or "")
		-- Refused rather than clamped: somebody who typed 500 asked for 500, and answering
		-- "making it 200 times" to that reads as though the number was accepted.
		if number and (number < self.MIN_QUANTITY or number > self.MAX_QUANTITY) then
			number = nil
		end
		if not number or not self:SetQuantity(number) then
			Print(Format(SI_PBSCMA_ERROR_QUANTITY, self.MIN_QUANTITY, self.MAX_QUANTITY))
			return
		end
		self:RefreshPanel()
		Print(Format(SI_PBSCMA_REPLY_QUANTITY, self:Quantity()))
		return
	end

	if command == "probe" then
		local started = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
		local lists, total, known = self.recipes:Census()
		local elapsed = (GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0) - started
		Print(Format(SI_PBSCMA_REPLY_PROBE, lists, total, known, elapsed))
		return
	end

	if command == "list" or command == "categories" then
		self:PrintCategories()
		return
	end

	if command == "cat" or command == "category" then
		local number = tonumber(words[2] or "")
		if not number then
			Print(GetString(SI_PBSCMA_ERROR_NEED_NUMBER))
			return
		end
		if not self:SetCategory(number) then
			Print(GetString(SI_PBSCMA_ERROR_NO_SUCH_CATEGORY))
			return
		end
		self:RefreshPanel()
		self:PrintMatches()
		return
	end

	if command == "known" then
		local value = ParseSwitch(words[2] or "")
		if value == nil then
			Print(GetString(SI_PBSCMA_ERROR_ON_OR_OFF))
			return
		end
		self.sv.knownOnly = value
		self:Search(self.sv.browse.text or "")
		self:RefreshPanel()
		Print(Format(SI_PBSCMA_REPLY_SWITCH, GetString(SI_PBSCMA_KNOWN_ONLY), OnOff(value)))
		return
	end

	if command == "scope" then
		local token = (words[2] or ""):upper()
		if not self:SetScope(token) then
			Print(GetString(SI_PBSCMA_ERROR_SCOPE))
			return
		end
		self:RefreshPanel()
		Print(Format(SI_PBSCMA_STATUS_SCOPE, GetString(_G[self:ScopeLabel()])))
		return
	end

	if command == "browse" then
		local value = ParseSwitch(words[2] or "")
		if value == nil then
			value = not self:Showing()
		end
		self:SetShowing(value)
		self:RefreshPanel()
		Print(Format(SI_PBSCMA_REPLY_SWITCH, GetString(SI_PBSCMA_BROWSE_SHOWING), OnOff(value)))
		return
	end

	if command == "clear" then
		self:ClearTarget()
		self:RefreshPanel()
		Print(GetString(SI_PBSCMA_REPLY_CLEARED))
		return
	end

	if command == "reset" then
		self:Reset()
		self:RefreshPanel()
		Print(GetString(SI_PBSCMA_REPLY_RESET))
		return
	end

	local masterSwitch = ParseSwitch(command)
	if masterSwitch ~= nil and not words[2] then
		self:SetEnabled(masterSwitch)
		self:RefreshPanel()
		self:PrintStatus()
		return
	end

	Print(Format(SI_PBSCMA_ERROR_UNKNOWN, command))
	self:PrintHelp()
end

local function DeepCopy(value)
	if type(value) ~= "table" then
		return value
	end
	local copy = {}
	for key, item in pairs(value) do
		copy[key] = DeepCopy(item)
	end
	return copy
end

function addon:Reset()
	for key, value in pairs(DEFAULTS) do
		self.sv[key] = DeepCopy(value)
	end
	self.matches = {}
	self.searched = false
	self:ApplyEvents()
	self.hud:Reset()
	self.hud:Refresh()
end

function addon:InitSlashCommand()
	local handler = function(argumentString)
		self:HandleCommand(argumentString)
	end
	SLASH_COMMANDS[SLASH] = handler
	SLASH_COMMANDS[SHORT_SLASH] = handler
end

-- ---------------------------------------------------------------------------------------
-- Load
-- ---------------------------------------------------------------------------------------

local function OnPlayerActivated()
	if not addon.panelBuilt then
		addon.panelBuilt = true
		if addon.InitSettings then
			addon:InitSettings()
		end
	end

	-- A pick made before a patch can have moved; this is where it is checked and, if it can
	-- be, put right. Done at activation rather than at load because the recipe lists are not
	-- necessarily populated before the world is.
	addon.recipes:ResolveTarget()
	addon:ApplyEvents()
	addon.hud:Refresh()
end

local function OnAddOnLoaded(_, name)
	if name ~= addon.name then
		return
	end
	em:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

	addon.sv = ZO_SavedVars:NewAccountWide("PBsCraftMaterialAssistant_Data", 1, nil, DEFAULTS)

	addon:InitSlashCommand()

	-- Learning a recipe changes what the picker may show, and it is the one thing that can
	-- happen while the picker is open. Cheap to answer: the current search is run again.
	if EVENT_RECIPE_LEARNED then
		em:RegisterForEvent(addon.name, EVENT_RECIPE_LEARNED, function()
			if addon.searched then
				addon:Search(addon.sv.browse.text or "")
				addon.hud:Refresh()
			end
		end)
	end

	em:RegisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

em:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

PBS_CRAFT_MATERIAL_ASSISTANT = addon
