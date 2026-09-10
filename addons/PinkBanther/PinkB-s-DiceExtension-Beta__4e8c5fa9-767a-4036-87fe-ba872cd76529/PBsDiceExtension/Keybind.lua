-- PB's DiceExtension -- R3 in the chat screen
--
-- The chat screen's text input area comes with four keybinds: back, focus, send, and the
-- game's Random Roll on the third one. This adds a fifth, on the right stick click, that rolls
-- the dice you configured.
--
-- WHY A SPARE BUTTON AND NOT A LONG PRESS ON THE ROLL BUTTON
--
-- Because a long press there cannot exist. The keybind strip fires a descriptor's callback the
-- instant the key goes DOWN (ZO_KeybindStrip:TryHandlingKeybindDown), so by the time a hold
-- could be measured the game has already rolled. Measuring it instead of the game rolling
-- would mean owning that callback, and an add-on that owns it can no longer reach
-- RandomDiceRoll -- it is private, and one add-on frame on the callstack is enough to lose it.
-- Nor can the hold be timed from outside the keybind system: IsKeyDown is private too.
--
-- So the game's roll button is left exactly as the game wrote it, and the dice get a button of
-- their own. Nothing of the client's is wrapped, replaced or called; a table it reads later
-- gets one more row in it -- the same thing ZO_GamepadMultiFocusArea_Base:AddKeybind does.
--
-- WHEN THE ROW CAN BE ADDED, WHICH IS NOT WHEN YOU WOULD THINK
--
-- Measured on a PS5: nothing appeared. The table is the reason. The chat screen does not build
-- textInputAreaKeybindDescriptor in its Initialize -- it builds it in InitializeFocusKeybinds,
-- which the base class calls from OnDeferredInitialize, which runs the FIRST TIME THE SCREEN
-- IS SHOWN. At EVENT_PLAYER_ACTIVATED there is no table to add a row to, and an add-on that
-- looks then correctly concludes there is no chat screen and does nothing at all.
--
-- The window is the scene's SHOWING state. ZO_Gamepad_ParametricList_Screen:OnStateChanged
-- does, in this order and all within the client's own callback:
--
--     PerformDeferredInitialize()   <- the descriptor comes into existence here
--     AddListKeybinds()
--     OnShowing()
--
-- and the focal area does not push its keybind group to the strip until SHOWN, one state
-- later. A callback of ours on SHOWING therefore lands after the table exists and before
-- anybody has read it. The client registered its own StateChange callback when the screen
-- object was built, long before any add-on loaded, so ours is always the later of the two --
-- which is what puts us on the right side of PerformDeferredInitialize.
--
-- It runs on every open rather than just the first. The row survives, so every later call
-- finds it and does nothing; the cost of that is a loop over five entries, and the benefit is
-- that nothing here depends on the deferred initialize happening exactly once.
--
-- PBS_DICE is nil if Main.lua bailed out early (e.g. already loaded).
if not PBS_DICE then
	return
end

local addon = PBS_DICE

-- R3. The client calls it "Right Stick Click" and a Japanese client calls it "R3", which is
-- what a console player calls it; either way the strip draws the button, not the words.
local ROLL_KEYBIND = "UI_SHORTCUT_RIGHT_STICK"

addon.ROLL_KEYBIND = ROLL_KEYBIND

-- What happened the last time we tried, in one word, so /pbdice status can say something true
-- rather than guess. PENDING is the shipped value and means "the chat screen has not been
-- opened yet", which is not a problem -- it is just not an answer.
addon.KEYBIND_PENDING = "pending"
addon.KEYBIND_ADDED = "added"
addon.KEYBIND_TAKEN = "taken"
addon.KEYBIND_UNAVAILABLE = "unavailable"

addon.chatKeybindState = addon.KEYBIND_PENDING

local function Descriptor()
	local menu = CHAT_MENU_GAMEPAD
	if not menu then
		return nil
	end
	local descriptor = menu.textInputAreaKeybindDescriptor
	if type(descriptor) ~= "table" then
		return nil
	end
	return descriptor
end

function addon:InitChatKeybind()
	local descriptor = Descriptor()
	if not descriptor then
		-- Either the screen has not been opened yet, or this is not a client that has one at
		-- all. Those look identical from here, so the state only moves off PENDING once we
		-- have been called from the scene itself -- see InitChatKeybindWatch.
		if self.chatKeybindWatching then
			self.chatKeybindState = self.KEYBIND_UNAVAILABLE
		end
		return false
	end

	for index = 1, #descriptor do
		local entry = descriptor[index]
		if type(entry) == "table" and entry.keybind == ROLL_KEYBIND then
			-- Ours already: this is the second open, and there is nothing to do. Somebody
			-- else's: leave it alone. A keybind quietly taken from another add-on is how two
			-- add-ons end up half-working, and the strip complains about duplicates rather
			-- than choosing between them.
			self.chatKeybindState = entry.pbsDice and self.KEYBIND_ADDED or self.KEYBIND_TAKEN
			return false
		end
	end

	descriptor[#descriptor + 1] = {
		-- Marked so the loop above recognises our own row rather than reading it as somebody
		-- else's claim on R3.
		pbsDice = true,

		-- One row, one label, and it has to carry both actions: the strip gives a keybind
		-- exactly one button, and a second row on the same key trips an assert and deletes
		-- the first (ZO_KeybindStrip:HandleDuplicateAddKeybind). So the label says what a
		-- press does and what a hold does, which is also how the client's own screens write
		-- a press-or-hold button. It is a function because the strip re-reads it on every
		-- draw, and a translated string is a thing that can change under us.
		name = function()
			return GetString(SI_PBSDICE_KEYBIND_NAME)
		end,

		keybind = ROLL_KEYBIND,

		-- The strip honours this predicate by hiding the button, and a hidden button's keybind
		-- is not handled -- so one checkbox turns the whole thing off with no reload and no
		-- unregistering.
		visible = function()
			return addon:ChatKeybind()
		end,

		-- Ask to be told about the key coming up as well as going down. This is a thing an
		-- add-on may only do to a row it owns: setting it on the game's Random Roll row would
		-- call the game's callback a second time on release, and rolling twice per press is
		-- not a feature.
		handlesKeyUp = true,

		callback = function(up)
			addon:OnRollKeybind(up)
		end,
	}

	self.chatKeybindState = self.KEYBIND_ADDED
	return true
end

-- Half a second. Long enough that nobody stages a command by accident, short enough that
-- holding it does not feel like waiting for something to load.
local HOLD_MS = 500

-- SHORT PRESS rolls the add-on's dice, in your chat, where only you see them.
-- LONG PRESS puts "/roll 3d20" in the chat box, so that pressing Send makes the game roll it
-- and the group sees the result. That is the only way an add-on's dice can reach anybody
-- else: SubmitTextEntry ends at SendChatMessage and DoCommand ends at RandomDiceRoll, and
-- both of those are private, so the last press has to be the player's.
--
-- Because the two have to be told apart, the roll happens on the key coming UP rather than
-- going down. That is a few hundredths of a second later than it used to be and is the whole
-- cost of the feature.
--
-- Writing to the box while the text area has focus makes the client's OnTextChanged run
-- UpdateKeybinds underneath us, which is client code on an add-on frame and therefore worth
-- having checked: it takes ZO_KeybindStrip's updateOnly path, which reuses the existing button
-- controls rather than acquiring from the pool, and skips the re-registration entirely when
-- nothing about the button changed (suppressUpdate). The one callback it would register,
-- OnKeybindLabelChanged, is a file-scope local created at client load, not a closure born
-- during our call. So nothing of the client's is created while we are on the stack.
function addon:OnRollKeybind(up)
	if not up then
		self.rollKeyDownAt = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
		return
	end

	local downAt = self.rollKeyDownAt
	self.rollKeyDownAt = nil

	-- A key up with nothing under it: the screen changed while the button was held, or the
	-- strip delivered one without the other. Read it as the short press, which is the one
	-- that cannot surprise anybody.
	local now = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
	local held = downAt and (now - downAt) or 0

	if held >= HOLD_MS then
		self:StageChatCommand()
	else
		self:RollAndPrint()
	end
end

-- The long press. Everything it can fail at, it says out loud.
function addon:StageChatCommand()
	local filled, why = self:FillChatBox(true)
	if filled then
		return true
	end
	if why == "occupied" then
		self.Print(GetString(SI_PBSDICE_STAGE_OCCUPIED))
	else
		self.Print(GetString(SI_PBSDICE_STAGE_NO_BOX))
	end
	return false
end

function addon:InitChatKeybindWatch()
	local scene = CHAT_MENU_GAMEPAD_SCENE
	if not scene or type(scene.RegisterCallback) ~= "function" then
		self.chatKeybindState = self.KEYBIND_UNAVAILABLE
		return false
	end

	self.chatKeybindWatching = true

	scene:RegisterCallback("StateChange", function(_, newState)
		if newState == SCENE_SHOWING then
			self:InitChatKeybind()
		end
	end)

	return true
end
