-- English, and the base every other language file overrides. Loaded first, so a translation
-- that is missing a line falls back to the line here rather than to "<missing SI_...>".
--
-- The sentence that describes a roll is NOT here: it is the client's own
-- SI_RANDOM_ROLL_DICE_RESULT, already translated and already knowing that one die is a die and
-- two are dice. SI_PBSDICE_RESULT_FALLBACK below is only used if the client stops shipping it.
local strings = {
	-- ---- Settings panel ---------------------------------------------------------------
	SI_PBSDICE_EXPLANATION = "The chat screen's Random Roll is /roll with nothing after it: one number out of 1 to 100, every time. Set the dice here instead -- up to 10 of them, up to 1000 sides each -- and roll them with /pbdice or with the button at the bottom of this panel. Those dice are rolled by the add-on and printed in your own chat, where only you can see them. For a roll your group can see, the game has to do the rolling: turn on the last setting here and the chat box will already contain the matching /roll command when you open the chat screen, so all that is left to do is send it.",

	SI_PBSDICE_SECTION_DICE = "The dice",
	SI_PBSDICE_SECTION_HOW = "How you roll them",
	SI_PBSDICE_SECTION_OUTPUT = "What is shown",
	SI_PBSDICE_SECTION_REAL = "Rolling where the group can see it",
	SI_PBSDICE_SECTION_NOW = "Roll",

	SI_PBSDICE_COUNT = "How many dice",
	SI_PBSDICE_COUNT_TOOLTIP = "1 to 10. Every die is rolled on its own and the total is what gets announced, which is what 3d20 has always meant.",

	SI_PBSDICE_SIDES = "How many sides",
	SI_PBSDICE_SIDES_TOOLTIP = "2 to 1000. 100 is what the chat screen's Random Roll uses, so 1 die of 100 sides is the roll you already have.",

	SI_PBSDICE_EACH = "Show every die",
	SI_PBSDICE_EACH_TOOLTIP = "Adds a second line with what each die rolled and how they add up. With one die there is nothing to add, so the line is not printed. This is the one thing the game's own roll cannot show you: it reports the total and nothing else.",

	SI_PBSDICE_TAG = "Mark rolls only you can see",
	SI_PBSDICE_TAG_TOOLTIP = "Puts a quiet marker at the end of a roll this add-on made, because it looks exactly like a roll the game made and it is not one -- nobody else saw it. Turn this off only if you already know which is which.",

	SI_PBSDICE_KEYBIND = "Roll on R3 in the chat screen",
	SI_PBSDICE_KEYBIND_TOOLTIP = "Adds a button to the chat screen, on the right stick click. Press it and it rolls your dice in your own chat. Hold it for half a second and it puts the matching /roll command in the chat box instead, so that pressing Send has the game roll them and your group sees the result -- the last press has to be yours, because an add-on cannot send chat. The game's own Random Roll on the third button is untouched and still does what it always did. It is a spare button rather than a long press on that one because the game rolls the instant that button goes down, and an add-on that took the button over could no longer reach the roll the group sees.",

	-- The label on the button, next to the game's own "Random Roll". Named rather than just
	-- described, so that a strip with five buttons on it says which one is not the game's,
	-- and carrying both of its actions because the strip gives a keybind exactly one row:
	-- a second row on the same key asserts and deletes the first (HandleDuplicateAddKeybind).
	SI_PBSDICE_KEYBIND_NAME = "PB's Dice: roll (only you / hold: everyone)",

	SI_PBSDICE_PREFILL = "Put /roll in the chat box",
	SI_PBSDICE_PREFILL_TOOLTIP = "When you open the chat screen, the text box is filled in with the /roll command for your dice -- press Send and the game rolls them, in the group's chat, where everybody sees it. The box is only filled when it is empty, so nothing you left half-typed is ever replaced; when you opened chat to say something instead, clear it and type. Off by default for that reason.",

	SI_PBSDICE_ROLL_NOW = "Roll now",
	SI_PBSDICE_ROLL_NOW_TOOLTIP = "Rolls the dice above and puts the result in chat. Only you can see it.",
	SI_PBSDICE_ROLL_NOW_BUTTON = "Roll",

	SI_PBSDICE_RESET = "Back to defaults",
	SI_PBSDICE_RESET_TOOLTIP = "Every setting on this panel back to the shipped value: one die of 100 sides, which is the roll the chat screen does on its own.",
	SI_PBSDICE_RESET_BUTTON = "Reset",

	-- ---- The roll ---------------------------------------------------------------------
	SI_PBSDICE_STAGE_OCCUPIED = "the chat box already has something in it, so it was left alone -- clear it and hold again",
	SI_PBSDICE_STAGE_NO_BOX = "the chat box is not here to write to",

	SI_PBSDICE_LOCAL_TAG = " |c9d9d9d(only you)|r",
	SI_PBSDICE_BREAKDOWN = "%s = %s",
	SI_PBSDICE_RESULT_FALLBACK = "%s rolls %s with %s x %s-sided dice.",

	-- ---- Status -----------------------------------------------------------------------
	SI_PBSDICE_STATUS_HEADER = "settings (version %s):",
	SI_PBSDICE_STATUS_DICE = "dice: %dd%d",
	SI_PBSDICE_STATUS_EACH = "every die shown: %s",
	SI_PBSDICE_STATUS_TAG = "rolls marked as yours alone: %s",
	SI_PBSDICE_STATUS_KEYBIND = "R3 in the chat screen: %s",
	SI_PBSDICE_STATUS_KEYBIND_PENDING = "  (the button is added when the chat screen is first opened -- it is not there yet)",
	SI_PBSDICE_STATUS_KEYBIND_NA = "  (the gamepad chat screen is not here, so that setting does nothing)",
	SI_PBSDICE_STATUS_KEYBIND_TAKEN = "  (something else claimed R3 there first, so it was left alone)",
	SI_PBSDICE_STATUS_PREFILL = "chat box filled in: %s",
	SI_PBSDICE_STATUS_PREFILL_NA = "  (the gamepad chat screen is not here, so that setting does nothing)",
	SI_PBSDICE_STATUS_COMMAND = "for a roll the group sees, send: %s",
	SI_PBSDICE_STATUS_CLAMPED = "  (the client will not take more than %dd%d, so that is what is sent)",

	SI_PBSDICE_ON = "on",
	SI_PBSDICE_OFF = "off",

	-- ---- Replies ----------------------------------------------------------------------
	SI_PBSDICE_REPLY_COUNT = "dice: %d",
	SI_PBSDICE_REPLY_SIDES = "sides: %d",
	SI_PBSDICE_REPLY_EACH = "every die shown: %s",
	SI_PBSDICE_REPLY_TAG = "rolls marked as yours alone: %s",
	SI_PBSDICE_REPLY_KEYBIND = "R3 in the chat screen: %s",
	SI_PBSDICE_REPLY_PREFILL = "chat box filled in: %s",
	SI_PBSDICE_REPLY_PREFILL_HINT = "the chat screen will open with %s ready to send",
	SI_PBSDICE_REPLY_RESET = "every setting back to default",

	-- ---- Errors -----------------------------------------------------------------------
	SI_PBSDICE_ERROR_COUNT = "the number of dice wants %d to %d",
	SI_PBSDICE_ERROR_SIDES = "the number of sides wants %d to %d",
	SI_PBSDICE_ERROR_ON_OR_OFF = "that wants on or off",
	SI_PBSDICE_ERROR_UNKNOWN = "no such command: %s",

	-- ---- Help -------------------------------------------------------------------------
	SI_PBSDICE_HELP_HEADER = "commands:",
	SI_PBSDICE_HELP_ROLL = "/pbdice -- roll the dice you set",
	SI_PBSDICE_HELP_SPEC = "/pbdice 3d20 -- roll that, just this once, without changing the setting",
	SI_PBSDICE_HELP_COUNT = "/pbdice count 3 -- how many dice, 1 to 10",
	SI_PBSDICE_HELP_SIDES = "/pbdice sides 20 -- how many sides, 2 to 1000",
	SI_PBSDICE_HELP_EACH = "/pbdice each on | off -- show what each die rolled",
	SI_PBSDICE_HELP_TAG = "/pbdice tag on | off -- mark rolls only you can see",
	SI_PBSDICE_HELP_KEYBIND = "/pbdice keybind on | off -- R3 in the chat screen: press to roll, hold to stage /roll",
	SI_PBSDICE_HELP_PREFILL = "/pbdice prefill on | off -- have the chat box ready with /roll",
	SI_PBSDICE_HELP_STATUS = "/pbdice status -- what the settings are",
	SI_PBSDICE_HELP_RESET = "/pbdice reset -- every setting back to default",

	-- ---- Probe ------------------------------------------------------------------------
	-- A diagnostic, not a feature: it asks the client whether an add-on may roll, which is the
	-- one answer this add-on's whole shape depends on. See the note at the top of Main.lua.
	SI_PBSDICE_PROBE_HEADER = "asking the client whether an add-on may roll:",
	SI_PBSDICE_PROBE_CONSTANT = "%s = %s",
	SI_PBSDICE_PROBE_MISSING = "RandomDiceRoll is not there at all -- nothing to try",
	SI_PBSDICE_PROBE_CALL = "RandomDiceRoll(6, 1, 0): called=%s returned=%s",
	SI_PBSDICE_PROBE_ALLOWED = "it went through -- a real 1d6 was just rolled, and this add-on could be rolling for real",
	SI_PBSDICE_PROBE_REFUSED = "refused, as expected: the roll API is private and add-on code cannot reach it",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
