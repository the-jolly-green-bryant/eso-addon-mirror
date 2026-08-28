-- PB's ChatAssistant
-- Author: PinkBanther
--
-- On console the chat entry box can only be opened from the controller -- Options + touchpad on
-- PS5 -- and opening it is what makes the platform put its own text input screen up, the IME
-- included. With a USB keyboard plugged into the console that means letting go of the keyboard
-- and reaching for the pad before every single message.
--
-- Press Enter, the box opens, the console's input screen comes up. That is the whole add-on.

if PBS_CHAT_ASSISTANT then
	return
end

local addon = {
	name = "PBsChatAssistant",
}

local em = EVENT_MANAGER

-- ROUTES
--
-- Two ways exist for a key press to reach add-on Lua, and on console only one of them works:
--
--   binding  Bindings.xml declares PBSCHATASSISTANT_START_CHAT and the player binds a key to it.
--            This is the sanctioned route and the only one on PC. On console it is dead:
--            AreKeyboardBindingsSupportedInGamepadUI() returns false, meaning the client does
--            not route keyboard keys into the binding system at all. The action is still
--            declared, because it costs nothing and is the right route wherever it does work.
--
--   catcher  A TopLevelControl with keyboardEnabled="true" and an OnKeyDown handler, kept shown
--            so it is handed key events. The game uses this pattern itself on a console-only
--            screen (ZO_ControllerDisconnect).
--
--            Measured on PS5: the default tier receives keyboard keys. Enter arrives as key 3
--            with IsKeyCodeKeyboardKey() true. The HIGH tier was not needed and is kept only as
--            the fallback to probe if a client update ever moves this.
--
-- captureMode: "auto", "off", "default" or "high".
--
-- It ships OFF, and that is not caution -- a shown catcher was observed to stop the controller
-- responding on PS5, from the moment the add-on loaded and before any key was pressed. Gamepad
-- buttons travel as KeyCodes through the same handler as keyboard keys, so the working theory is
-- that the catcher is swallowing them. Until that is settled the add-on loads doing nothing, and
-- /pbchat probe is how the swallowing gets measured: it reports gamepad and keyboard keys apart,
-- and clears itself after 15 seconds.
--
-- Auto, when chosen explicitly, picks the catcher exactly when the binding route is dead.
local DEFAULTS = {
	enabled = true,
	captureMode = "off",
	delayMs = 500,
	followInput = true,
	triggerOnKeyboard = true,
	log = false,
}

local MIN_DELAY_MS = 0
local MAX_DELAY_MS = 5000

-- Both Enters, because a keyboard has two and neither is more correct than the other.
local ENTER_KEYS = {
	[KEY_ENTER] = true,
	[KEY_NUMPAD_ENTER] = true,
}

local CATCHER_CONTROL_NAMES = {
	default = "PBsChatAssistantKeyCatcher",
	high = "PBsChatAssistantKeyCatcherHigh",
	low = "PBsChatAssistantKeyCatcherLow",
	medium = "PBsChatAssistantKeyCatcherMedium",
}

local PROBE_SECONDS = 15
local TRIAL_SECONDS = 20

-- Watchdog cadence and how long the broken state is tolerated before it is undone. See
-- StartStuckWatchdog.
local WATCHDOG_INTERVAL_MS = 1000
local WATCHDOG_STRIKES = 3

local function Print(formatString, ...)
	d(string.format("|cFF69B4PB’s ChatAssistant|r: " .. formatString, ...))
end

-- ZO_GetChatSystem() returns the gamepad chat system on console and the keyboard one on PC.
-- Both inherit SharedChatSystem, so the shared methods are valid on either; the type checks are
-- there so a client that ever drops the chat system entirely degrades to doing nothing rather
-- than erroring on every key press.
local function GetChatSystem()
	if type(ZO_GetChatSystem) ~= "function" then
		return nil
	end
	return ZO_GetChatSystem()
end

local function IsTextEntryOpen()
	local chat = GetChatSystem()
	if not chat or type(chat.IsTextEntryOpen) ~= "function" then
		return false
	end
	return chat:IsTextEntryOpen()
end

local function IsChatAvailable()
	return type(IsChatSystemAvailableForCurrentPlatform) ~= "function"
		or IsChatSystemAvailableForCurrentPlatform()
end

-- False on console: the client does not route keyboard keys into the binding system there, so
-- Bindings.xml can never fire and a catcher is the only way in.
local function IsBindingRouteAvailable()
	return type(AreKeyboardBindingsSupportedInGamepadUI) ~= "function"
		or AreKeyboardBindingsSupportedInGamepadUI()
end

local function ResolveCaptureMode(mode)
	if mode ~= "auto" then
		return mode
	end
	return IsBindingRouteAvailable() and "off" or "default"
end

----------------------------------------------------------------------------------------------
-- Opening the box
----------------------------------------------------------------------------------------------

-- WHY StartChatInput() IS NOT USED
--
-- It is what the game's own Start Chat binding calls, and it is closed to add-ons on console.
-- It reaches ZO_GamepadChatSystem:StartTextEntry(), which calls the private SetSetting() to
-- persist the chat HUD setting, and a *private* function cannot be called by add-on code at all.
-- The hardware-event rule that lets a keybind reach a *protected* function does not extend to
-- private ones: calling it straight out of OnKeyDown fails exactly as calling it from a timer
-- did, with "Attempt to access a private function 'SetSetting' from insecure code".
--
-- The private call sits behind `if not dontShowHUDWindow`, so passing that flag is the only way
-- an add-on can open the box at all. The flag also skips the work that puts the window on
-- screen, which has to be done here instead -- and it matters that it is done, because a focused
-- entry box with no window activates an input eater (DIRECTIONAL_INPUT:ConsumeAll) and pushes
-- the GamepadChatSystem action layer, leaving nothing on screen to dismiss. StartStuckWatchdog
-- undoes that state if it ever happens anyway.
--
-- Everything below is plain Lua on the chat system. None of it is private or protected.
local function OpenChatEntry()
	local chat = GetChatSystem()
	if not chat or type(chat.StartTextEntry) ~= "function" then
		return
	end

	-- Turns the HUD chat on for this session. Making that persist is the private call itself, so
	-- it is dropped: the add-on shows the chat without quietly rewriting a saved setting.
	if type(chat.SetHUDEnabled) == "function" then
		chat:SetHUDEnabled(true)
	end

	chat:StartTextEntry(nil, nil, nil, true)

	-- StartTextEntry declines in a good number of states -- a dialog is up, the scene blocks
	-- chat, the player is not activated, the game does not have focus -- and says so only by not
	-- opening. Nothing below should run in that case.
	if not chat:IsTextEntryOpen() then
		return false
	end

	if chat.isMinimized and type(chat.Maximize) == "function" then
		chat:Maximize()
	elseif chat.primaryContainer then
		chat.primaryContainer:FadeIn()
	end

	-- Both branches of the skipped code set this to false: the minimized branch assigns
	-- STUB_SETTING_KEEP_MINIMIZED, which is itself false. So they need no telling apart.
	chat.shouldMinimizeAfterEntry = false

	-- What actually puts the console's own input screen up. There is no Lua call that summons
	-- it; IsVirtualKeyboardOnScreen() is read-only, and the screen is the platform's response to
	-- the chat edit control taking focus. TextEntry:Open() already took focus once, and this
	-- re-asserts it after the window moved, exactly as the game does.
	local textEntry = chat.textEntry
	local editControl = textEntry and type(textEntry.GetEditControl) == "function" and textEntry:GetEditControl()
	if editControl then
		editControl:TakeFocus()
	end

	return true
end

-- WHY THE WAIT IS BACK, AND WHY IT IS THE POINT
--
-- The console's input screen -- the IME -- is what makes any of this worth having, and it does
-- not come up when the box is opened in the same frame as the key press. Measured on PS5:
--
--   open immediately   entry open true, edit focus true, input screen FALSE
--   open 5s later      input screen appears
--
-- The input device is not what decides it. The second measurement was repeated without touching
-- the controller at all and the screen still came up, which rules out the platform gating this
-- on whether the player last used a gamepad.
--
-- What it is, is that the key press arrives while the previous focus state is still unwinding --
-- the chat box closing on the Enter that submitted the last message, say. Reopening in that same
-- frame gives the platform no lost-and-regained focus to react to. Let the frame finish and the
-- focus is genuinely fresh, so the screen is raised.
--
-- Which makes the wait the mechanism rather than a safety margin, exactly as first specified.
-- Deferring is free now, too: nothing left on the open path is private, so there is no hardware
-- event trace to preserve.
local openPending = false

local function OpenPending()
	openPending = false
	addon:SuspendCatcher()
	local opened = OpenChatEntry()
	addon:ResumeCatcherWhenChatCloses()
	addon:StartStuckWatchdog()
	return opened
end

function addon:StartChat()
	if not self.sv.enabled then
		return
	end

	-- A held key repeats. One box is enough.
	if openPending or IsTextEntryOpen() or not IsChatAvailable() then
		return
	end

	if self.sv.delayMs <= 0 then
		return OpenPending()
	end

	openPending = true
	zo_callLater(OpenPending, self.sv.delayMs)
	return true
end

----------------------------------------------------------------------------------------------
-- Catching the key
----------------------------------------------------------------------------------------------

-- Tracks EVENT_INPUT_TYPE_CHANGED. Starts as gamepad, which is the safe assumption on console:
-- it keeps the catcher down until the player is known to be at the keyboard.
local inputIsGamepad = true

local probeActive = false
local probeSeen = nil
local probeControl = nil
local catcherSuspended = false

local function GetCatcherControl(mode)
	local controlName = CATCHER_CONTROL_NAMES[mode]
	return controlName and _G[controlName] or nil
end

local function HideAllCatchers()
	for _, controlName in pairs(CATCHER_CONTROL_NAMES) do
		local control = _G[controlName]
		if control then
			control:SetHidden(true)
		end
	end
end

-- The single place that decides what is shown. Everything else sets state and calls this, so
-- probe and capture cannot end up fighting over the same two controls.
function addon:Log(formatString, ...)
	if self.sv and self.sv.log then
		Print(formatString, ...)
	end
end

function addon:ApplyCatcher()
	HideAllCatchers()

	if probeActive then
		if probeControl then
			probeControl:SetHidden(false)
		end
		return
	end

	if catcherSuspended then
		return
	end

	-- Every tier tested on PS5 kills the gamepad buttons while shown, so the catcher cannot
	-- simply be left up. It does not have to be: EVENT_INPUT_TYPE_CHANGED says which device the
	-- player is on, and the catcher is only wanted on the keyboard side of that. The moment a
	-- controller button is pressed the event fires and this puts the catcher away again.
	if self.sv.followInput and inputIsGamepad then
		return
	end

	local control = GetCatcherControl(ResolveCaptureMode(self.sv.captureMode))
	if control then
		control:SetHidden(false)
	end
end

function addon:SuspendCatcher()
	catcherSuspended = true
	self:ApplyCatcher()
end

-- There is no event for the entry box closing, so this polls. It only runs while the box is
-- open, and only when a catcher is actually in use.
function addon:ResumeCatcherWhenChatCloses()
	if not catcherSuspended then
		return
	end

	if IsTextEntryOpen() then
		zo_callLater(function()
			self:ResumeCatcherWhenChatCloses()
		end, 250)
		return
	end

	catcherSuspended = false
	self:ApplyCatcher()
end

function addon:OnCatcherKey(control, key)
	if probeActive then
		-- Key repeat would flood the chat, so each code is reported once per probe.
		if not probeSeen[key] then
			local isGamepad = type(IsKeyCodeGamepadKey) == "function" and IsKeyCodeGamepadKey(key)
			probeSeen[key] = isGamepad and "gamepad" or "keyboard"
			Print("key %d (%s) %s%s", key, tostring(GetKeyName(key)),
				isGamepad and "GAMEPAD" or "keyboard", ENTER_KEYS[key] and " <- ENTER" or "")
		end
		return
	end

	self:Log("key %d (%s), entry %s", key, tostring(GetKeyName(key)), tostring(IsTextEntryOpen()))

	if ENTER_KEYS[key] then
		self:StartChat()
	end
end

----------------------------------------------------------------------------------------------
-- Getting unstuck
----------------------------------------------------------------------------------------------

-- An entry box that is open while the chat window is hidden is the unrecoverable state: the
-- input eater and the action layer are both live, and there is nothing on screen to dismiss.
-- Nothing here should produce it any more, but it costs almost nothing to notice and undo, and
-- the alternative for the player is closing the game.
--
-- Strikes rather than a single check, because the window is legitimately hidden for a moment
-- while it fades in.
local watchdogRunning = false

function addon:ForceCloseTextEntry()
	local chat = GetChatSystem()
	if chat and type(chat.CloseTextEntry) == "function" then
		-- Undoes the whole thing: loses focus, removes the GamepadChatSystem action layer and
		-- deactivates the directional input eater.
		chat:CloseTextEntry()
		return true
	end
	return false
end

function addon:StartStuckWatchdog()
	if watchdogRunning then
		return
	end
	watchdogRunning = true

	local strikes = 0

	local function Tick()
		if not IsTextEntryOpen() then
			watchdogRunning = false
			return
		end

		local chat = GetChatSystem()
		local hidden = chat and type(chat.IsHidden) == "function" and chat:IsHidden()

		if hidden then
			strikes = strikes + 1
			if strikes >= WATCHDOG_STRIKES then
				watchdogRunning = false
				if self:ForceCloseTextEntry() then
					Print("chat entry was open with nothing on screen -- closed it to give the controller back")
				end
				return
			end
		else
			strikes = 0
		end

		zo_callLater(Tick, WATCHDOG_INTERVAL_MS)
	end

	zo_callLater(Tick, WATCHDOG_INTERVAL_MS)
end

----------------------------------------------------------------------------------------------
-- Probe
----------------------------------------------------------------------------------------------

function addon:StopProbe()
	if not probeActive then
		return
	end

	probeActive = false
	probeControl = nil
	self:ApplyCatcher()

	local keyboardCount, gamepadCount = 0, 0
	for _, kind in pairs(probeSeen) do
		if kind == "gamepad" then
			gamepadCount = gamepadCount + 1
		else
			keyboardCount = keyboardCount + 1
		end
	end

	if keyboardCount == 0 and gamepadCount == 0 then
		Print("probe over: nothing arrived. This tier does not receive keys here.")
	else
		Print("probe over: %d keyboard, %d gamepad", keyboardCount, gamepadCount)
		if gamepadCount > 0 then
			-- Reaching the handler and being swallowed before the game sees it are not the same
			-- thing, but a controller that went dead during the probe settles it.
			Print("gamepad keys reach this tier -- likely why the controller stops responding")
		end
	end
	probeSeen = nil
end

function addon:StartProbe(mode)
	local control = GetCatcherControl(mode)
	if not control then
		Print("no such tier: %s (default, high, medium, low)", tostring(mode))
		return
	end

	probeActive = true
	probeSeen = {}
	probeControl = control
	self:ApplyCatcher()

	Print("probe on (%s tier) for %d s -- press Enter, then try the controller", mode, PROBE_SECONDS)
	-- Self-clearing, so a tier that turns out to swallow input cannot strand the session.
	zo_callLater(function()
		self:StopProbe()
	end, PROBE_SECONDS * 1000)
end

----------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------

function addon:DescribeCaptureMode()
	local mode = self.sv.captureMode
	local resolved = ResolveCaptureMode(mode)
	if resolved == mode then
		return mode
	end
	return string.format("%s -> %s", mode, resolved)
end

-- The console's input screen is the platform's response to the chat edit control holding focus.
-- Nothing in Lua summons it and nothing reports why it did not come, so the two readable facts
-- either side of it are taken instead: whether the edit control actually has focus, and whether
-- the screen is up. Sampled twice, because the platform does not necessarily put it up in the
-- same frame as the focus.
function addon:ReportEntryState(label)
	local chat = GetChatSystem()
	local editControl = chat and chat.editControl
	local hasFocus = editControl and type(editControl.HasFocus) == "function" and editControl:HasFocus()
	local keyboardUp = type(IsVirtualKeyboardOnScreen) == "function" and IsVirtualKeyboardOnScreen()
	-- The suspected deciding factor: the platform may only put its input screen up when the
	-- player was last using the gamepad, on the reasoning that someone typing on a keyboard has
	-- no use for an on-screen one. Reported so the theory can be checked rather than argued.
	local lastInputGamepad = type(WasLastInputGamepad) == "function" and WasLastInputGamepad()

	Print("%s: entry open %s, edit focus %s, input screen %s, last input %s",
		label, tostring(IsTextEntryOpen()), tostring(hasFocus or false), tostring(keyboardUp or false),
		lastInputGamepad and "gamepad" or "keyboard")
end

function addon:PrintStatus()
	Print("%s, capture %s, delay %d ms", self.sv.enabled and "on" or "off", self:DescribeCaptureMode(), self.sv.delayMs)
	Print("chat available: %s", tostring(IsChatAvailable()))
	Print("gamepad UI: %s", tostring(IsInGamepadPreferredMode()))
	Print("binding route: %s", tostring(IsBindingRouteAvailable()))
	Print("text entry open: %s", tostring(IsTextEntryOpen()))
	Print("input type: %s, follow %s, trigger %s", inputIsGamepad and "gamepad" or "keyboard",
		tostring(self.sv.followInput), tostring(self.sv.triggerOnKeyboard))
end

function addon:InitSlashCommand()
	SLASH_COMMANDS["/pbchat"] = function(args)
		args = zo_strtrim(args or "")
		local command, argument = args:match("^(%S+)%s*(.*)$")
		command = command and command:lower() or ""
		argument = argument and zo_strtrim(argument):lower() or ""

		if command == "on" or command == "off" then
			self.sv.enabled = (command == "on")
			Print("%s", self.sv.enabled and "on" or "off")
		elseif command == "probe" then
			self:StartProbe(argument ~= "" and argument or "default")
		elseif command == "log" then
			self.sv.log = (argument ~= "off")
			Print("log %s", self.sv.log and "on" or "off")
		elseif command == "follow" then
			self.sv.followInput = (argument ~= "off")
			self:ApplyCatcher()
			Print("follow input %s", self.sv.followInput and "on" or "off")
		elseif command == "trigger" then
			self.sv.triggerOnKeyboard = (argument ~= "off")
			Print("trigger on keyboard switch %s", self.sv.triggerOnKeyboard and "on" or "off")
		elseif command == "delay" and tonumber(argument) then
			self.sv.delayMs = zo_clamp(zo_round(tonumber(argument)), MIN_DELAY_MS, MAX_DELAY_MS)
			Print("delay %d ms", self.sv.delayMs)
		elseif command == "trial" then
			-- The controller died at load with a catcher on, and the probe says the catcher is
			-- not receiving gamepad keys, so the cause is still unaccounted for. This turns a
			-- catcher on for real and takes it away again on its own, which is the only way to
			-- test that safely.
			local mode = argument ~= "" and argument or "default"
			if not CATCHER_CONTROL_NAMES[mode] then
				Print("trial default | high | medium | low")
			else
				local restore = self.sv.captureMode
				self.sv.captureMode = mode
				self:ApplyCatcher()
				Print("catcher on (%s) for %d s -- try the controller now", mode, TRIAL_SECONDS)
				zo_callLater(function()
					self.sv.captureMode = restore
					self:ApplyCatcher()
					Print("catcher off again (back to %s)", restore)
				end, TRIAL_SECONDS * 1000)
			end
		elseif command == "capture" then
			if argument == "auto" or argument == "off" or CATCHER_CONTROL_NAMES[argument] then
				self.sv.captureMode = argument
				self:ApplyCatcher()
				Print("capture %s", self:DescribeCaptureMode())
			else
				Print("capture auto | off | default | high | medium | low")
			end
		elseif command == "unstick" then
			if self:ForceCloseTextEntry() then
				Print("chat entry closed")
			else
				Print("no chat system to close")
			end
		elseif command == "test" and tonumber(argument) then
			-- Deferred open, so the gamepad can be made the last input device before it runs.
			-- If the input screen appears this way and not from an immediate test, the platform
			-- is gating it on the input device and a keyboard key can never be the trigger.
			--
			-- Deferring is safe now in a way it never was before: nothing on the open path is
			-- private any more, so losing the hardware-event trace costs nothing.
			local seconds = zo_clamp(zo_round(tonumber(argument)), 1, 30)
			Print("opening in %d s", seconds)
			zo_callLater(function()
				-- Sampled before the open, because that is the moment the platform makes its
				-- decision, and because once the input screen is up it covers the chat log.
				self:ReportEntryState("before")
				Print("opened: %s", tostring(self:StartChat() or false))
				self:ReportEntryState("now")
				zo_callLater(function()
					self:ReportEntryState("after 1s")
				end, 1000)
			end, seconds * 1000)
		elseif command == "test" then
			-- Tests the open on its own, with no key catching involved. Nothing on this path is
			-- private or protected, so where it runs from no longer matters -- which is what
			-- makes the two unknowns separable: this one answers "does the box open and does the
			-- console put its input screen up", and probe answers "can a key reach us safely".
			Print("opened: %s", tostring(self:StartChat() or false))
			self:ReportEntryState("now")
			-- Second sample, in case the platform is a beat behind the focus.
			zo_callLater(function()
				self:ReportEntryState("after 1s")
			end, 1000)
		else
			self:PrintStatus()
		end
	end
end

local function OnAddOnLoaded(_, name)
	if name ~= addon.name then
		return
	end
	em:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

	-- Version 5 reinstates the delay setting, dropped in 2.0.0 on a wrong conclusion, and keeps
	-- captureMode off: a shown catcher is still what stops the controller responding.
	addon.sv = ZO_SavedVars:NewAccountWide("PBsChatAssistant_Data", 6, nil, DEFAULTS)
	addon:InitSlashCommand()
	addon:ApplyCatcher()

	-- Auto reads the binding route, which on PC depends on which UI is in front. Console never
	-- fires this.
	em:RegisterForEvent(addon.name, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function()
		addon:ApplyCatcher()
	end)

	-- The catcher's visibility rides on this, and so does the first chat of a session.
	--
	-- Switching to the keyboard is reported only as a change, and the key that caused the change
	-- is already gone by the time it arrives -- there is no catcher up yet to have seen it. On
	-- console a keyboard key does nothing else during play, so the switch itself is taken as the
	-- request to chat. The catcher then goes up and handles every following key press directly,
	-- until a controller button switches the input type back and puts it away.
	em:RegisterForEvent(addon.name, EVENT_INPUT_TYPE_CHANGED, function(_, isGamepad)
		inputIsGamepad = isGamepad
		addon:Log("input type -> %s", isGamepad and "gamepad" or "keyboard")
		addon:ApplyCatcher()

		if not isGamepad and addon.sv.triggerOnKeyboard then
			addon:StartChat()
		end
	end)
end

em:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

PBS_CHAT_ASSISTANT = addon
