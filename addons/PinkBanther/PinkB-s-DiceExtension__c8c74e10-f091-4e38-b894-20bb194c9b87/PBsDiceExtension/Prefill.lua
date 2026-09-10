-- PB's DiceExtension -- putting the real command in the chat box
--
-- This is the only file that touches the client's UI, and it is written under a rule learned
-- the expensive way (PB's MailerExtension, on a PS5): add-on Lua is insecure code, one add-on
-- frame taints the whole callstack, and any client closure that happens to be created while
-- our frame is on the stack is permanently untrusted -- it will fail later, somewhere else,
-- on a feature we never touched. So this file does only the two things that are known safe:
--
--   * it REGISTERS with the client's own callback manager -- the chat scene's "StateChange".
--     Our function is stored beside the client's; nothing of the client's is wrapped.
--   * it WRITES TO AN EDIT BOX. Data into a control, not code onto a stack.
--
-- Then it stops. The player presses Send, and everything from that keybind down -- the chat
-- system, the slash command table, ZO_RandomRollCommand, the private RandomDiceRoll at the
-- bottom of it -- is the client calling itself with nothing of ours in the way. That is why
-- this roll is a real one that the group sees, and the one in Dice.lua is not.
--
-- WHY SCENE_SHOWING AND NOT SCENE_SHOWN
--
-- The edit box's OnTextChanged handler calls UpdateKeybinds when the text input area is
-- focused, which is client code running with our SetText frame underneath it. At SCENE_SHOWING
-- the screen has not focused its text input yet, so the handler sees an unfocused area and
-- returns without doing anything. Same visible result, one less client path entered from an
-- add-on frame. When there is a cheaper moment, take it.
--
-- PBS_DICE is nil if Main.lua bailed out early (e.g. already loaded).
if not PBS_DICE then
	return
end

local addon = PBS_DICE

local function TextEdit()
	local menu = CHAT_MENU_GAMEPAD
	if not menu then
		return nil
	end
	local edit = menu.textEdit
	if not edit or type(edit.SetText) ~= "function" then
		return nil
	end
	return edit
end

-- force is the difference between the two callers. Opening the chat screen fills the box only
-- if the setting says so; holding R3 is somebody asking for it right now, and does not consult
-- a checkbox. Both obey the rule below.
--
-- Returns whether it filled, and if not, why -- the automatic caller ignores the reason and
-- the deliberate one says it out loud, because an explicit action that silently does nothing
-- is the worst of the three outcomes.
function addon:FillChatBox(force)
	if not force and not self:Prefill() then
		return false, "off"
	end

	local edit = TextEdit()
	if not edit then
		return false, "nobox"
	end

	-- Never overwrite. The box holds whatever the player last left in it, and a half-typed
	-- whisper replaced by "/roll 3d20" is a worse bug than the feature is a feature.
	local existing = type(edit.GetText) == "function" and edit:GetText() or ""
	if existing ~= "" then
		return false, "occupied"
	end

	edit:SetText((self.dice:CommandText(self:Count(), self:Sides())))
	return true
end

function addon:InitPrefill()
	local scene = CHAT_MENU_GAMEPAD_SCENE
	if not scene or type(scene.RegisterCallback) ~= "function" then
		-- The gamepad chat screen is where this feature lives. Without it -- a keyboard-mode
		-- client, or a future where that screen is built differently -- the setting simply
		-- does nothing, and /pbdice status says so rather than lying about it.
		self.prefillAvailable = false
		return false
	end

	-- Registered once and for good, with the setting checked at the moment the screen opens.
	-- Unregistering and re-registering as the checkbox moves would be more code and one more
	-- way to leave a stale closure attached to a client object.
	scene:RegisterCallback("StateChange", function(_, newState)
		if newState == SCENE_SHOWING then
			self:FillChatBox()
		end
	end)

	self.prefillAvailable = true
	return true
end
