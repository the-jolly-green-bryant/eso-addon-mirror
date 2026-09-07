-- PB's NamePlateChanger
-- Author: PinkBanther
--
-- Adjusts the font of the overhead nametags ("nameplates").
--
-- What is and is not possible here, and why (full evidence in FINDINGS.md):
--
-- Nameplates are drawn by the game engine. Nothing in the client's own Lua builds or lays
-- out that text, so the title / character name / <guild> lines CANNOT be reordered, split
-- onto separate lines or re-centred by an add-on. The whole Lua surface is:
--
--   SetNameplateGamepadFont(fontName, fontStyle) / SetNameplateKeyboardFont(...)
--       -> callable by an add-on (measured, PS5 api 101050)
--   GetSetting(SETTING_TYPE_NAMEPLATES, ...)
--       -> readable, so the add-on can report the player's own settings
--   SetSetting(...)
--       -> PRIVATE. Never call it. pcall does not protect against that: the client raises a
--          UI error and kills the running chunk.
--
-- The font API takes a face and a style but no size, so the size rides inside the face
-- string as an ESO font descriptor ("face|size", the form used throughout
-- esoui/fontdefs/). That was the open question and it is answered: the size does take
-- effect on the nameplate.
--
-- The last remaining hope for changing nameplate *text* was overriding
-- SI_NAMEPLATE_SECOND_LINE_FORMAT, the <guild> line's format string. Measured: the override
-- changes what GetString returns and nothing on screen. The engine formats that line from
-- its own string table. So the font is the whole of it -- size, face, outline.
--
-- Changing the face makes the client reload the UI to build the new font. That is engine
-- behaviour and cannot be avoided, only not paid twice: see WriteSlot.
--
-- The face is kept as an alias such as $(GAMEPAD_MEDIUM_FONT) rather than a resolved path.
-- On the Japanese client those aliases carry CJK backup fonts (FTN57 backed by
-- ESO_FWNTLGUDC70-DB / MYingHeiPRC-W5); a raw Latin path would leave Japanese names
-- unrenderable.

if PBS_NAMEPLATE_CHANGER then
	return
end

local addon = {
	name = "PBsNamePlateChanger",
}

-- The display name is a Lua constant and the version comes from the manifest, the same way
-- PB's MiniMap does it -- reading the name back out of "## Title" mangles the "PB's " prefix
-- in the settings library. Typographic apostrophe (U+2019), not ASCII '.
local DISPLAY_NAME = "PB’s NamePlateChanger"
local AUTHOR = "PinkBanther"
local SLASH = "/pbfont"
local LEGACY_SLASH = "/pbtag"

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

-- ---------------------------------------------------------------------------------------
-- Output
--
-- A message printed at EVENT_ADD_ON_LOADED is thrown away because chat is not up yet, so
-- anything user-facing is either a command response or fires on EVENT_PLAYER_ACTIVATED.
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

-- Calls fn(...) and turns the outcome into one printable string.
--
-- This catches ordinary Lua errors. It does NOT make a call safe: a private function still
-- takes the whole chunk down, pcall or no pcall. Only route known-callable things through it.
local function Attempt(fnName, ...)
	local fn = _G[fnName]
	if type(fn) ~= "function" then
		return false, "MISSING"
	end
	local results = { pcall(fn, ...) }
	if not results[1] then
		return false, "ERR " .. tostring(results[2])
	end
	local parts = {}
	for i = 2, #results do
		parts[#parts + 1] = tostring(results[i])
	end
	return true, #parts > 0 and table.concat(parts, " / ") or "OK"
end

addon.Line = Line
addon.Attempt = Attempt

-- ---------------------------------------------------------------------------------------
-- Faces offered in the settings panel
--
-- Aliases only, never resolved paths. Every one of these is defined per language, so the
-- Japanese client hands back a face that can draw Japanese names.
-- ---------------------------------------------------------------------------------------

-- The faces that are safe to offer.
--
-- Not every face the client defines: only the ones the console UI already has loaded. A face
-- that is not otherwise in use has to be built when it is set, and on console that build is
-- billed to the 100 MB pool every add-on shares -- which kills the add-on.
--
-- Measured on PS5, Japanese client. These four were reported to crash and are retired:
--
--   ANTIQUE_FONT / HANDWRITTEN_FONT / STONE_TABLET_FONT -> ESO_KafuPenji-M, a brush face the
--       UI never uses, so setting any of them means building a whole CJK face
--   CHAT_FONT -> ESO_FWUDC_70-M, not used by the gamepad UI either
--
-- What is left resolves to a face the UI is already drawing with:
--
--   alias                  western             japanese
--   GAMEPAD_MEDIUM_FONT    FTN57               FTN57  (latin; CJK falls back to the gothic)
--   GAMEPAD_BOLD_FONT      FTN87               FTN87  (latin; CJK falls back to the gothic)
--   GAMEPAD_LIGHT_FONT     FTN47               ESO_FWNTLGUDC70-DB  \
--   MEDIUM_FONT            Univers57           ESO_FWNTLGUDC70-DB   > the same gothic
--   BOLD_FONT              Univers67           ESO_FWNTLGUDC70-DB  /
--
-- The Japanese duplication is left in rather than collapsed: the list has to be correct in
-- every client, and the tooltip explains it.
addon.faces = {
	{ alias = "", stringId = "SI_PBSNPC_FACE_DEFAULT" },
	{ alias = "$(GAMEPAD_MEDIUM_FONT)", stringId = "SI_PBSNPC_FACE_GAMEPAD_MEDIUM" },
	{ alias = "$(GAMEPAD_BOLD_FONT)", stringId = "SI_PBSNPC_FACE_GAMEPAD_BOLD" },
	{ alias = "$(GAMEPAD_LIGHT_FONT)", stringId = "SI_PBSNPC_FACE_GAMEPAD_LIGHT" },
	{ alias = "$(MEDIUM_FONT)", stringId = "SI_PBSNPC_FACE_MEDIUM" },
	{ alias = "$(BOLD_FONT)", stringId = "SI_PBSNPC_FACE_BOLD" },
}

-- Anyone who already picked one of the retired faces is still carrying it in saved variables,
-- and it would go on being applied at every login. Checked against the list above rather than
-- against a list of bad names, so removing a face is always enough to stop it being used.
function addon:DropRetiredFace()
	local account = self.account
	local chosen = account.face
	if chosen == nil or chosen == "" then
		return false
	end
	for _, face in ipairs(self.faces) do
		if face.alias == chosen then
			return false
		end
	end
	account.face = ""
	return true
end

-- Styles offered in the settings panel.
--
-- The numeric values of FONT_STYLE_* are read from the client at run time rather than
-- hardcoded: the documentation lists the enum alphabetically, not by value.
-- "Keep the client's own style" needs to be a real, storable value rather than nil.
--
-- nil cannot be told apart from "not set", cannot live in accountDefaults, does not survive
-- a round trip through the settings library, and reads back as the first item in a dropdown.
-- The outline setting used nil and was the only setting that lost its value; face uses ""
-- for the same idea and never did.
addon.STYLE_INHERIT = -1

addon.styles = {
	{ constant = nil, stringId = "SI_PBSNPC_STYLE_DEFAULT" },
	{ constant = "FONT_STYLE_NORMAL", stringId = "SI_PBSNPC_STYLE_NORMAL" },
	{ constant = "FONT_STYLE_SHADOW", stringId = "SI_PBSNPC_STYLE_SHADOW" },
	{ constant = "FONT_STYLE_SOFT_SHADOW_THIN", stringId = "SI_PBSNPC_STYLE_SOFT_SHADOW_THIN" },
	{ constant = "FONT_STYLE_SOFT_SHADOW_THICK", stringId = "SI_PBSNPC_STYLE_SOFT_SHADOW_THICK" },
	{ constant = "FONT_STYLE_OUTLINE", stringId = "SI_PBSNPC_STYLE_OUTLINE" },
	{ constant = "FONT_STYLE_OUTLINE_THICK", stringId = "SI_PBSNPC_STYLE_OUTLINE_THICK" },
	{ constant = "FONT_STYLE_OUTLINE_SHADOW", stringId = "SI_PBSNPC_STYLE_OUTLINE_SHADOW" },
}

addon.DEFAULT_SIZE = 32
addon.MIN_SIZE = 10
addon.MAX_SIZE = 72

addon.accountDefaults = {
	enabled = true,
	size = addon.DEFAULT_SIZE,
	face = "",
	-- STYLE_INHERIT leaves the client's own style alone; anything else is a FONT_STYLE_* value.
	style = addon.STYLE_INHERIT,
	-- Off by default: re-applying a custom face after every loading screen is what kills the
	-- add-on on console. See BuildDescriptor.
	reapplyFace = false,
}

-- ---------------------------------------------------------------------------------------
-- What a stock client looks like
--
-- Measured with an early probe build, on a client this add-on had never written to:
--
--   gamepad  "$(GAMEPAD_MEDIUM_FONT)"  style 4
--   keyboard "$(BOLD_FONT)"            style 4
--
-- Aliases rather than resolved paths, so these stay correct in every language.
--
-- The important part is what they have in common with every other stock value: **no size
-- component**. The client's own nameplate font is a bare face. Only this add-on writes
-- "face|size". That makes it possible to tell a genuine original from something this add-on
-- put there -- which matters, because recording our own output as "the value to go back to"
-- is a one-way door: the untouched value is then gone for good.
-- ---------------------------------------------------------------------------------------

addon.stockFonts = {
	Gamepad = { font = "$(GAMEPAD_MEDIUM_FONT)", style = 4 },
	Keyboard = { font = "$(BOLD_FONT)", style = 4 },
}

local function LooksLikeStock(descriptor)
	return type(descriptor) == "string" and descriptor ~= "" and not descriptor:find("|", 1, true)
end

-- ---------------------------------------------------------------------------------------
-- The client's own font, captured once and kept forever
--
-- The nameplate font is a client setting, so a value written here can outlive both the
-- session and the add-on. The untouched original is therefore captured before the first
-- write and stored account-wide, so "off" and "reset" can always put the game back exactly
-- as it was -- including after a reinstall, and including if this add-on is later removed
-- while a custom font is still applied.
-- ---------------------------------------------------------------------------------------

function addon:CaptureOriginals()
	local account = self.account
	if not account then
		return false
	end
	if account.originalCaptured then
		return true
	end

	for _, slot in ipairs({ "Gamepad", "Keyboard" }) do
		local getter = _G["GetNameplate" .. slot .. "Font"]
		local ok, font, style = false, nil, nil
		if type(getter) == "function" then
			ok, font, style = pcall(getter)
		end

		-- A descriptor with a size in it was written by this add-on, so it is not an
		-- original and must not be recorded as one. Fall back to the measured stock value.
		if not ok or not LooksLikeStock(font) then
			font, style = self.stockFonts[slot].font, self.stockFonts[slot].style
		end

		account["original" .. slot .. "Font"] = font
		account["original" .. slot .. "Style"] = style
	end

	account.originalCaptured = true
	return true
end

-- Repairs a capture that already went wrong.
--
-- An earlier build took whatever the client reported, so a capture that happened
-- while a custom font was applied -- which is what the rename did, when the old saved
-- variables did not come across -- stored that custom font as the original. "Reset" then led
-- back to the custom font rather than to stock. Anything carrying a size is put back to the
-- measured stock value, once, with a line in chat so it is not a silent change.
function addon:HealOriginals()
	local account = self.account
	if not account or not account.originalCaptured then
		return false
	end

	local healed = false
	for _, slot in ipairs({ "Gamepad", "Keyboard" }) do
		local key = "original" .. slot .. "Font"
		if not LooksLikeStock(account[key]) then
			account[key] = self.stockFonts[slot].font
			account["original" .. slot .. "Style"] = self.stockFonts[slot].style
			healed = true
		end
	end
	return healed
end

-- ---------------------------------------------------------------------------------------
-- Applying
-- ---------------------------------------------------------------------------------------

-- Strips any "|size|style" that is already on a descriptor, leaving the bare face.
local function FaceOf(descriptor)
	if type(descriptor) ~= "string" then
		return nil
	end
	return descriptor:match("^([^|]+)") or descriptor
end

-- Builds the descriptor to write.
--
-- cheapOnly drops the two parts that cost the client real work and keeps the one that does
-- not. Measured on PS5:
--
--   size     free. ESO's fonts are .slug -- GPU vector text, resolution independent -- so
--            there is no per-size atlas to build. Size changes have never reloaded the UI
--            or destabilised anything.
--   face     expensive. A face the client has not loaded has to be built; the UI reload on
--            a face change is that build.
--   outline  very expensive on a CJK client. ZOS put it at about 100 MB in their own source.
--
-- That work is billed to the 100 MB pool every console add-on shares, so paying it after
-- every loading screen is what was killing the add-on. Paid once per session it is fine.
function addon:BuildDescriptor(originalDescriptor, originalStyle, cheapOnly)
	local account = self.account
	if not account.enabled then
		return originalDescriptor, originalStyle
	end

	local face = account.face
	if cheapOnly or face == nil or face == "" then
		face = FaceOf(originalDescriptor)
	end
	if not face then
		return originalDescriptor, originalStyle
	end

	local size = tonumber(account.size) or self.DEFAULT_SIZE
	local style = account.style
	if cheapOnly or style == nil or style == self.STYLE_INHERIT then
		style = originalStyle
	end

	return string.format("%s|%d", face, size), style
end

local function ReadSlot(slot)
	local getter = _G["GetNameplate" .. slot .. "Font"]
	if type(getter) ~= "function" then
		return nil
	end
	local ok, font, style = pcall(getter)
	if ok then
		return font, style
	end
	return nil
end

-- ---------------------------------------------------------------------------------------
-- Write budget
--
-- Changing the face makes the client reload the UI so it can build the font. A reload starts
-- a fresh Lua state and raises EVENT_PLAYER_ACTIVATED again -- so any write that keeps
-- looking necessary is a reload loop, and the loading screen it produces is exactly where an
-- add-on gets killed. A session-local counter cannot catch that: the reload resets it. The
-- counter therefore lives in saved variables, which a reload flushes to disk.
--
-- The read-back guard below is the first line of defence, but it only holds if the client
-- hands back the same string it was given. If it normalises the descriptor -- resolves the
-- alias, drops the size -- the comparison never matches and every activation writes again.
-- That is unverified, which is precisely why the budget exists rather than a bigger comment.
-- ---------------------------------------------------------------------------------------

-- Sized to allow one write per zone change during fast travel while still catching a loop.
-- A loop writes as fast as the client can reload; a player cannot cross ten zones a minute.
local WRITE_BUDGET = 10
local WRITE_WINDOW_SECONDS = 60

function addon:Diag()
	local account = self.account
	if not account.diag then
		account.diag = {}
	end
	return account.diag
end

function addon:MayWrite()
	local diag = self:Diag()
	local now = (GetTimeStamp and GetTimeStamp()) or 0

	if not diag.windowStart or now < diag.windowStart or (now - diag.windowStart) > WRITE_WINDOW_SECONDS then
		diag.windowStart = now
		diag.writes = 0
		diag.reportedBudget = nil
	end

	if (diag.writes or 0) >= WRITE_BUDGET then
		if not diag.reportedBudget then
			diag.reportedBudget = true
			Line("|cFF69B4%s|r: stopped writing the nameplate font (%d writes in %d s).", self.title, WRITE_BUDGET, WRITE_WINDOW_SECONDS)
			Line("  Something is undoing it. Run '%s status' and send the diag lines.", SLASH)
		end
		return false
	end

	diag.writes = (diag.writes or 0) + 1
	return true
end

-- Writes a slot only when the value actually differs, and only within the budget.
local function WriteSlot(slot, font, style)
	if font == nil then
		return false, "no value"
	end

	local currentFont, currentStyle = ReadSlot(slot)
	if currentFont == font and currentStyle == style then
		return true, "unchanged"
	end

	if not addon:MayWrite() then
		return false, "over budget"
	end

	local diag = addon:Diag()
	diag.lastSlot = slot
	diag.lastBefore = currentFont
	diag.lastWritten = font

	local ok, result = Attempt("SetNameplate" .. slot .. "Font", font, style)

	-- Whether the client hands the descriptor back unchanged decides whether the guard above
	-- can ever work. Recorded rather than assumed.
	local readBack = ReadSlot(slot)
	diag.lastReadBack = readBack
	diag.readBackMatches = (readBack == font)

	return ok, ok and "set" or result
end

-- Which of the two fonts is actually on screen.
--
-- The nameplate has a gamepad font and a keyboard font and the client draws whichever
-- matches the current mode, so on console the keyboard one is never seen. Writing it anyway
-- was pure cost: picking a face changed *both*, and the unseen keyboard-side change was
-- enough on its own to trigger the UI reload.
function addon:ActiveSlot()
	local gamepadPreferred = IsInGamepadPreferredMode and IsInGamepadPreferredMode()
	return gamepadPreferred and "Gamepad" or "Keyboard"
end

function addon:Apply(cheapOnly)
	local account = self.account
	if not account or not self:CaptureOriginals() then
		return false
	end

	local slot = self:ActiveSlot()
	local originalFont = account["original" .. slot .. "Font"]
	local originalStyle = account["original" .. slot .. "Style"]
	local font, style = self:BuildDescriptor(originalFont, originalStyle, cheapOnly)
	local ok, result = WriteSlot(slot, font, style)
	return ok, result
end

-- Puts the client's own font back without touching the saved settings, so turning the
-- add-on back on restores the player's choices. Both slots, because an earlier version of
-- this add-on wrote both and the keyboard one may still be carrying its value.
function addon:RestoreOriginals()
	local account = self.account
	if not account or not account.originalCaptured then
		return false
	end
	WriteSlot("Gamepad", account.originalGamepadFont, account.originalGamepadStyle)
	WriteSlot("Keyboard", account.originalKeyboardFont, account.originalKeyboardStyle)
	return true
end

function addon:ResetToDefaults()
	local account = self.account
	for key, value in pairs(self.accountDefaults) do
		account[key] = value
	end
	self:Apply()
end

-- ---------------------------------------------------------------------------------------
-- Status and diagnostics
-- ---------------------------------------------------------------------------------------

local function DescribeSetting(label, settingId)
	local settingType = _G.SETTING_TYPE_NAMEPLATES
	if settingType == nil or settingId == nil then
		Line("  %s: enum missing in this client", label)
		return
	end
	local _, value = Attempt("GetSetting", settingType, settingId)
	Line("  %s: %s", label, value)
end

-- Turns a FontStyle number back into its constant name.
--
-- Worth the scan: whether a style is an outline decides whether the client has to build
-- outline glyphs, and on a CJK client the game's own source puts that at about 100 MB --
-- against a 100 MB pool shared by every add-on on console.
local function StyleName(value)
	if type(value) ~= "number" then
		return "none"
	end
	for name, constantValue in pairs(_G) do
		if constantValue == value and type(name) == "string" and name:find("^FONT_STYLE_") then
			return name
		end
	end
	return "unknown"
end

function addon:PrintStatus()
	local account = self.account
	Line("|cFF69B4%s|r", self.title)
	Line("  enabled=%s size=%s face=%q", tostring(account.enabled), tostring(account.size), tostring(account.face))
	Line("  style=%s (%s)  stock style=%s (%s)", tostring(account.style), StyleName(account.style),
		tostring(account.originalGamepadStyle), StyleName(account.originalGamepadStyle))

	local slot = self:ActiveSlot()
	local _, gamepadFont = Attempt("GetNameplateGamepadFont")
	local _, keyboardFont = Attempt("GetNameplateKeyboardFont")
	Line("  in use: %s (only this one is written)", slot)
	Line("  gamepad font now: %s", gamepadFont)
	Line("  keyboard font now: %s", keyboardFont)
	Line("  original gamepad: %s / %s", tostring(account.originalGamepadFont), tostring(account.originalGamepadStyle))
	Line("  original keyboard: %s / %s", tostring(account.originalKeyboardFont), tostring(account.originalKeyboardStyle))

	-- Read-only: these belong to the game's own Nameplates settings and an add-on cannot
	-- write them (SetSetting is private), so the most it can do is report them.
	local diag = self:Diag()
	Line("  diag: activations=%s writes=%s window=%s", tostring(diag.activations), tostring(diag.writes), tostring(diag.windowStart))
	Line("  diag: lastWritten=%s", tostring(diag.lastWritten))
	Line("  diag: lastReadBack=%s matches=%s", tostring(diag.lastReadBack), tostring(diag.readBackMatches))
	Line("  diag: before=%s slot=%s", tostring(diag.lastBefore), tostring(diag.lastSlot))

	Line("  game settings (change these in Settings > Nameplates):")
	DescribeSetting("all nameplates", _G.NAMEPLATE_TYPE_ALL_NAMEPLATES)
	DescribeSetting("show titles", _G.NAMEPLATE_TYPE_SHOW_PLAYER_TITLES)
	DescribeSetting("show guilds", _G.NAMEPLATE_TYPE_SHOW_PLAYER_GUILDS)

	-- How the title arrives from the server.
	--
	-- The nameplate's first line is not built from any client string -- there is no
	-- "name + title" formatter in the string table at all. The remaining explanation for
	-- why some titles read before the name and others after is that the ordering travels
	-- with the title data itself. These two lines are what would show that: if the title
	-- carries a separator or a <<1>> slot, the order is per-title server data.
	local _, name = Attempt("GetUnitName", "player")
	local _, title = Attempt("GetUnitTitle", "player")
	Line("  player name=%q title=%q", tostring(name), tostring(title))
	local indexOk, index = pcall(GetCurrentTitleIndex)
	if indexOk and index then
		local _, raw = Attempt("GetTitle", index)
		Line("  GetTitle(%s)=%q", tostring(index), tostring(raw))
	else
		Line("  GetTitle: no title selected")
	end
	local targetOk, targetName = Attempt("GetUnitName", "reticleover")
	if targetOk and targetName ~= "" then
		local _, targetTitle = Attempt("GetUnitTitle", "reticleover")
		Line("  target name=%q title=%q", tostring(targetName), tostring(targetTitle))
	end
end

-- ---------------------------------------------------------------------------------------
-- Slash commands
-- ---------------------------------------------------------------------------------------

local function Usage()
	Line("|cFF69B4%s|r", addon.title)
	Line("  %s              -- this list", SLASH)
	Line("  %s status       -- current font, settings and the game's nameplate settings", SLASH)
	Line("  %s size <n>     -- set the nameplate font size, e.g. %s size 32", SLASH, SLASH)
	Line("  %s on | off     -- apply or drop the custom font", SLASH)
	Line("  %s reset        -- back to defaults", SLASH)
	Line("  %s safe         -- keep the size, drop the typeface and outline (the cheap setup)", SLASH)
	Line("  %s stock        -- force the game's stock font back and re-record it as the original", SLASH)
	Line("  %s diag clear   -- clear the write counters", SLASH)
	Line("  (%s still works -- the add-on's previous name)", LEGACY_SLASH)
end

local function OnSlash(argumentString)
	local args = {}
	for word in tostring(argumentString or ""):gmatch("%S+") do
		args[#args + 1] = word
	end

	local command = (args[1] or ""):lower()
	local argument = args[2]

	if command == "status" then
		addon:PrintStatus()
	elseif command == "size" then
		local size = tonumber(argument)
		if not size then
			Line("usage: %s size <%d-%d>", SLASH, addon.MIN_SIZE, addon.MAX_SIZE)
			return
		end
		size = math.max(addon.MIN_SIZE, math.min(addon.MAX_SIZE, math.floor(size)))
		addon.account.size = size
		addon.account.enabled = true
		addon:Apply()
		Line("nameplate font size: %d", size)
	elseif command == "on" then
		addon.account.enabled = true
		addon:Apply()
		Line("custom nameplate font on")
	elseif command == "off" then
		addon.account.enabled = false
		addon:RestoreOriginals()
		Line("custom nameplate font off -- the game's own font is back")
	elseif command == "safe" then
		-- Keeps the size, drops the two expensive parts.
		--
		-- Size rides on the same face the client already has loaded, so it costs nothing to
		-- re-apply. A different face has to be built, and an outline style has to have its
		-- glyphs generated -- which the game's own source puts at about 100 MB for a CJK
		-- font, against a 100 MB pool shared by every console add-on.
		addon.account.face = ""
		addon.account.style = addon.STYLE_INHERIT
		addon.account.enabled = true
		addon:Apply()
		Line("safe mode: size %s kept, typeface and outline back to the game's own.", tostring(addon.account.size))
		Line("this is the configuration that costs the client no font building.")
	elseif command == "stock" then
		-- Hard reset of the safety net: forget the capture, take the measured stock values,
		-- and put them on screen. For when the stored original is not trustworthy.
		local account = addon.account
		for _, slot in ipairs({ "Gamepad", "Keyboard" }) do
			account["original" .. slot .. "Font"] = addon.stockFonts[slot].font
			account["original" .. slot .. "Style"] = addon.stockFonts[slot].style
		end
		account.originalCaptured = true
		account.enabled = false
		addon:RestoreOriginals()
		Line("stock font restored: gamepad %s / %s", addon.stockFonts.Gamepad.font, tostring(addon.stockFonts.Gamepad.style))
		Line("the custom font is off. '%s on' puts your settings back.", SLASH)
	elseif command == "diag" then
		if argument and argument:lower() == "clear" then
			addon.account.diag = {}
			Line("diagnostics cleared")
		else
			addon:PrintStatus()
		end
	elseif command == "reset" then
		addon:ResetToDefaults()
		Line("reset to defaults (size %d)", addon.DEFAULT_SIZE)
	else
		Usage()
	end
end

-- ---------------------------------------------------------------------------------------
-- Bootstrap
-- ---------------------------------------------------------------------------------------

-- Carries the settings and the capture over from the add-on's previous names.
--
-- The add-on has been renamed twice: NameTagOptimizer -> NamePlateFontChanger ->
-- NamePlateChanger. Each rename gives it a fresh saved-variables table, and the first one
-- showed why that is dangerous: the capture did not come across, so the add-on re-captured
-- the *custom* font that was applied at the time and recorded it as the value to go back to.
-- Every previous table is therefore still declared in the manifest and read here, newest
-- first. HealOriginals() is the backstop if this still misses.
local LEGACY_SAVED_VARIABLES = {
	"PBsNamePlateFontChanger_Data",
	"PBsNameTagOptimizer_Data",
}

local function MigrateFromOldName()
	local account = addon.account
	if account.originalCaptured then
		return
	end

	for _, legacyName in ipairs(LEGACY_SAVED_VARIABLES) do
		if _G[legacyName] then
			local legacy = ZO_SavedVars:NewAccountWide(legacyName, 1, nil, {})
			if legacy and legacy.originalCaptured then
				for _, key in ipairs({
					"originalCaptured",
					"originalGamepadFont", "originalGamepadStyle",
					"originalKeyboardFont", "originalKeyboardStyle",
					"enabled", "size", "face", "style",
				}) do
					if legacy[key] ~= nil then
						account[key] = legacy[key]
					end
				end
				addon.migratedFrom = legacyName
				return
			end
		end
	end
end

-- How long after a zone load to wait before touching the font.
--
-- Originally five seconds, when every apply wrote the face and the face build was killing the
-- add-on: the moment right after a loading screen is the worst time to ask for one, with
-- every add-on re-initialising at once against the 100 MB pool they share.
--
-- Only the first apply of a session writes a face now; every zone change after it
-- writes the size on the face the client already has, which builds nothing. So the delay no
-- longer has much to protect and a short one keeps the size from visibly lagging the loading
-- screen. What it still covers is that first apply -- which means if the crash ever comes
-- back, it comes back at login rather than at a zone change.
local APPLY_DELAY_MS = 1000

local function OnPlayerActivated()
	-- Applied after every zone load, because the client does NOT carry this setting across a
	-- loading screen: applying once per session was tried, and the nameplate went back to stock on
	-- every zone change. What keeps it safe is the read-back guard (confirmed on PS5 to
	-- compare equal), the write budget, and the delay above.
	local diag = addon:Diag()
	diag.activations = (diag.activations or 0) + 1

	addon:CaptureOriginals()

	if addon.droppedFace and not addon.reportedDrop then
		addon.reportedDrop = true
		Line("|cFF69B4%s|r: your typeface was one that crashes on console and has been set back to the game's own.", addon.title)
	end

	if addon.healedOriginals and not addon.reportedHeal then
		addon.reportedHeal = true
		Line("|cFF69B4%s|r: the stored original font was one of its own and has been put back to the game's stock value.", addon.title)
		Line("  '%s off' now really does restore the game's own font.", SLASH)
	end

	-- The first application of a session pays for the face and the outline. Every zone change
	-- after that re-applies the size only, on the client's own face, unless the player has
	-- explicitly opted back in -- so the size survives a loading screen, which is cheap, and
	-- the font building happens once, which is survivable.
	local cheapOnly = addon.firstApplyDone and not addon.account.reapplyFace
	addon.firstApplyDone = true

	if zo_callLater then
		zo_callLater(function()
			addon:Apply(cheapOnly)
		end, APPLY_DELAY_MS)
	else
		addon:Apply(cheapOnly)
	end
end

local function OnAddOnLoaded(_, loadedName)
	if loadedName ~= addon.name then
		return
	end
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

	addon.account = ZO_SavedVars:NewAccountWide("PBsNamePlateChanger_Data", 1, nil, addon.accountDefaults)
	MigrateFromOldName()
	addon.healedOriginals = addon:HealOriginals()
	addon.droppedFace = addon:DropRetiredFace()

	SLASH_COMMANDS[SLASH] = OnSlash
	-- The add-on used to be called NameTag Optimizer and the old command is in muscle memory.
	SLASH_COMMANDS[LEGACY_SLASH] = OnSlash

	if addon.InitSettings then
		addon:InitSettings()
	end

	EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

	-- Only the font for the mode in use is written, so the other one has to be brought up
	-- to date if the player switches. On console this never fires.
	if EVENT_GAMEPAD_PREFERRED_MODE_CHANGED then
		EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function()
			addon:Apply()
		end)
	end
end

PBS_NAMEPLATE_CHANGER = addon
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
