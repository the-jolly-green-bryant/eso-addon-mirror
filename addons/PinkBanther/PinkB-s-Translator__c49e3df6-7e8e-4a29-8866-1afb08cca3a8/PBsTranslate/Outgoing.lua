-- PB's Translate -- /en: Japanese to English for what the player sends (prototype)
--
--   /en チャルマン砦の正門が攻撃されている   ->   [en] chal fd lit
--
-- An add-on cannot send chat: SendChatMessage is *private* (ESOUIDocumentation.txt). The plan
-- was to open the chat entry box with the English already in it and let the player press send.
--
-- THE CRASH
--
-- On PS5, 0.4.12's /en crashed the game -- the whole client, not a Lua error, so nothing was
-- left to read afterwards. That build did five things to the chat box in one go, from a
-- zo_callLater callback 300 ms after the command:
--
--   StartTextEntry(text, nil, nil, true) -> Maximize/FadeIn -> TakeFocus, then
--   GetText, a possible SetText, and 1.5 s later IsVirtualKeyboardOnScreen and GetText again.
--
-- Only the plain open with no text has ever run on PS5 (PB's ChatAssistant does it every day).
-- Which of the rest takes the client down cannot be worked out from a desk, and guessing costs
-- another crash. So:
--
--   * /en now only translates and prints. Nothing touches the chat box.
--   * /en try 1..5 each do exactly one more thing than the step before, safest first. The
--     player runs them in order; the first one that crashes names the call.
--
--     1  open the box EMPTY, the ChatAssistant way                      (known to work on PS5)
--     2  1, then 3 s later read IsVirtualKeyboardOnScreen               (ChatAssistant read it too)
--     3  1, then 3 s later read the edit control's text (GetText)
--     4  1, then 3 s later put "hello" in with SetText
--     5  open the box WITH "hello" in it: StartTextEntry("hello", ...)  (what 0.4.12 did)
--
--   Each step waits 2 s before opening, well past the box the command was typed into, and
--   prints what it is about to do before doing it.
--
-- RESULT OF 1..5 ON PS5 (0.4.14): none crashed. So no single call is the cause, and what is
-- left is how 0.4.12 combined them. Three further steps separate the two differences:
--
--     6  5, but after 300 ms instead of 2 s                     (0.4.12's timing, one call)
--     7  0.4.12's calls after 2 s: open with text, GetText at once,
--        then 1.5 s later IsVirtualKeyboardOnScreen and GetText  (0.4.12's calls, safe timing)
--     8  7 after 300 ms                                          (0.4.12 exactly)
--
-- RESULT OF 6..8 ON PS5 (0.4.15): none crashed either; 0.4.12's crash did not reproduce.
--
-- 0.4.16: /en OPENS THE BOX AGAIN, THE WAY THAT RAN CLEAN
--
-- /en <日本語> opens the entry box with the English in it -- or with 翻訳不可 when nothing
-- could be translated, so the player always sees that the command did something. It uses only
-- what ran on PS5 without crashing: step 5's single StartTextEntry(text, ...) two seconds after
-- the command, with no reads of the edit control or the input screen around it. The one part
-- of 0.4.12 never re-run -- polling every 100 ms while the box was still open -- is gone: a box
-- that is still open after the wait is left alone and the player is told.
--
-- Nothing here wraps or hooks client code.

local addon = PBS_TRANSLATE
local T = PBsTranslate
if not addon or not T or not T.TranslateJaToEn then
	return
end

local OPEN_DELAY_MS = 2000

-- What goes in the box when nothing could be translated.
local UNTRANSLATABLE = "翻訳不可"
local READ_DELAY_MS = 3000

local outgoing = {}
addon.outgoing = outgoing

local function Say(text)
	if addon.Say then
		addon.Say(text)
	elseif CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
		CHAT_ROUTER:AddSystemMessage(text)
	end
end

local PREFIX = "|cFF69B4[en]|r "

-- Every line goes through the UTF-8 check: invalid bytes handed to the chat window are the
-- likely cause of the 0.4.16 crash (see Lexicon.lua, byte-safe text helpers).
local function Report(format, ...)
	local ok, text = pcall(string.format, format, ...)
	local line = T.SanitizeUTF8(ok and text or format)
	Say(PREFIX .. line)
end

local function Later(fn, ms)
	if type(zo_callLater) == "function" then
		zo_callLater(fn, ms)
	else
		fn()
	end
end

local function GetChat()
	if type(ZO_GetChatSystem) ~= "function" then
		return nil
	end
	return ZO_GetChatSystem()
end

local function EditControlOf(chat)
	local textEntry = chat and chat.textEntry
	return textEntry and type(textEntry.GetEditControl) == "function" and textEntry:GetEditControl() or nil
end

-- Step 1: exactly PB's ChatAssistant OpenChatEntry, with the text argument passed through.
-- Returns opened, reason.
local function OpenBox(text)
	local chat = GetChat()
	if not chat or type(chat.StartTextEntry) ~= "function" then
		return false, "no chat system"
	end
	if type(chat.IsTextEntryOpen) == "function" and chat:IsTextEntryOpen() then
		return false, "the chat box is still open"
	end
	if type(chat.SetHUDEnabled) == "function" then
		chat:SetHUDEnabled(true)
	end
	chat:StartTextEntry(text, nil, nil, true)
	if type(chat.IsTextEntryOpen) ~= "function" or not chat:IsTextEntryOpen() then
		return false, "StartTextEntry declined"
	end
	if chat.isMinimized and type(chat.Maximize) == "function" then
		chat:Maximize()
	elseif chat.primaryContainer and type(chat.primaryContainer.FadeIn) == "function" then
		chat.primaryContainer:FadeIn()
	end
	chat.shouldMinimizeAfterEntry = false
	local edit = EditControlOf(chat)
	if edit and type(edit.TakeFocus) == "function" then
		edit:TakeFocus()
	end
	return true
end

local function RunOpen(step, text)
	Report("try %d: opening the chat box %s now", step, text and ("with \"" .. text .. "\"") or "empty")
	local ok, opened, reason = pcall(OpenBox, text)
	if not ok then
		Report("try %d: open error: %s", step, tostring(opened))
		return false
	end
	if not opened then
		Report("try %d: open declined: %s", step, tostring(reason))
		return false
	end
	Report("try %d: opened", step)
	return true
end

-- 0.4.12's sequence after the open: GetText at once, then the screen state and GetText again.
local function ReadLikeRelease(step)
	local ok, text = pcall(function()
		local edit = EditControlOf(GetChat())
		return edit and edit:GetText()
	end)
	Report("try %d: text at once=[%s]%s", step, tostring(text), ok and "" or " (error)")
	Later(function()
		Report("try %d: reading screen state and text now", step)
		local okRead, screen, later = pcall(function()
			local edit = EditControlOf(GetChat())
			return type(IsVirtualKeyboardOnScreen) == "function" and IsVirtualKeyboardOnScreen(), edit and edit:GetText()
		end)
		Report("try %d: screen=%s text=[%s]%s", step, tostring(screen), tostring(later), okRead and "" or " (error)")
	end, 1500)
end

-- How long each step waits before opening. 6 and 8 use 0.4.12's 300 ms.
local STEP_DELAY_MS = { [6] = 300, [8] = 300 }

local STEPS = {
	[1] = function()
		RunOpen(1, nil)
	end,
	[2] = function()
		if not RunOpen(2, nil) then
			return
		end
		Later(function()
			Report("try 2: reading IsVirtualKeyboardOnScreen now")
			local ok, screen = pcall(function()
				return type(IsVirtualKeyboardOnScreen) == "function" and IsVirtualKeyboardOnScreen()
			end)
			Report("try 2: screen=%s%s", tostring(screen), ok and "" or " (error)")
		end, READ_DELAY_MS)
	end,
	[3] = function()
		if not RunOpen(3, nil) then
			return
		end
		Later(function()
			Report("try 3: reading the edit control's text now")
			local ok, text = pcall(function()
				local edit = EditControlOf(GetChat())
				return edit and edit:GetText()
			end)
			Report("try 3: text=[%s]%s", tostring(text), ok and "" or " (error)")
		end, READ_DELAY_MS)
	end,
	[4] = function()
		if not RunOpen(4, nil) then
			return
		end
		Later(function()
			Report("try 4: SetText(\"hello\") now")
			local ok, err = pcall(function()
				local edit = EditControlOf(GetChat())
				if edit then
					edit:SetText("hello")
				end
			end)
			Report("try 4: done%s", ok and "" or (" (error: " .. tostring(err) .. ")"))
		end, READ_DELAY_MS)
	end,
	[5] = function()
		RunOpen(5, "hello")
	end,
	[6] = function()
		RunOpen(6, "hello")
	end,
	[7] = function()
		if RunOpen(7, "hello") then
			ReadLikeRelease(7)
		end
	end,
	[8] = function()
		if RunOpen(8, "hello") then
			ReadLikeRelease(8)
		end
	end,
}

-- ---------------------------------------------------------------------------------------
-- The command
-- ---------------------------------------------------------------------------------------

local function Trim(text)
	return T.Trim(text)
end

function addon:OutgoingCommand(argumentString)
	local argument = Trim(argumentString)

	if argument == "" or argument == "help" then
		Report("/en <日本語> -- 英訳を入れた状態で入力欄を開きます（送信は自分で）。訳せないときは「翻訳不可」")
		Report("/en try 1〜8 -- 入力欄の動作確認。1から順に1つずつ実行してください")
		return
	end

	local step = argument:match("^try +([0-9])$")
	if step then
		local run = STEPS[tonumber(step)]
		if not run then
			Report("/en try 1〜8")
			return
		end
		local delay = STEP_DELAY_MS[tonumber(step)] or OPEN_DELAY_MS
		Report("try %s: starting in %d ms", step, delay)
		Later(function()
			local ok, err = pcall(run)
			if not ok then
				Report("try %s: error: %s", step, tostring(err))
			end
		end, delay)
		return
	end

	if argument == "probe" then
		local probe = T.ProbeLocale()
		Report("locale: E3 letter=%s alnum=%s | A0 space=%s | 85 space=%s | C3 upper=%s lowerChanges=%s",
			tostring(probe.alphaE3), tostring(probe.alnumE3), tostring(probe.spaceA0), tostring(probe.space85),
			tostring(probe.upperC3), tostring(probe.lowerChangesC3))
		local english, unknown = T.TranslateJaToEn("ケーキを食べたい")
		local valid = T.IsValidUTF8(english)
		for _, piece in ipairs(unknown) do
			valid = valid and T.IsValidUTF8(piece)
		end
		Report("untranslatable sample: english=%s pieces=%d valid=%s", english == "" and "empty" or "NOT EMPTY",
			#unknown, tostring(valid))
		return
	end

	local ok, english, unknown = pcall(T.TranslateJaToEn, argument)
	if not ok then
		Report("translation error: %s", tostring(english))
		english, unknown = "", {}
	end
	-- Never hand the client broken UTF-8, whatever the translator produced.
	local dropped
	english, dropped = T.SanitizeUTF8(english)
	if dropped then
		english = ""
	end
	if #unknown > 0 then
		Report("未対応の語: %s", table.concat(unknown, " / "))
	end
	local text = english:find("[A-Za-z0-9]") and english or UNTRANSLATABLE
	outgoing.last = text
	-- Shown in chat as well, so the English is not lost if the box cannot open.
	Report("%s", text)

	Later(function()
		local okOpen, opened, reason = pcall(OpenBox, text)
		if not okOpen then
			Report("入力欄を開けませんでした: %s", tostring(opened))
		elseif not opened then
			Report("入力欄を開けませんでした: %s", tostring(reason))
		end
	end, OPEN_DELAY_MS)
end

local function Install()
	if SLASH_COMMANDS then
		SLASH_COMMANDS["/en"] = function(argumentString)
			local ok, err = pcall(addon.OutgoingCommand, addon, argumentString)
			if not ok then
				Report("command error: %s", tostring(err))
			end
		end
	end
end

local ok, err = pcall(Install)
if not ok then
	addon.outgoingInstallError = tostring(err)
end
