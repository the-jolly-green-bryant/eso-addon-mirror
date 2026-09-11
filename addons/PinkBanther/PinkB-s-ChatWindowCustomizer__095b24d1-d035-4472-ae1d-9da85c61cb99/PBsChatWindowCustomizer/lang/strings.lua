local strings = {
	SI_PBSCWC_EXPLANATION = "Moves and resizes the chat window on the HUD and changes the size of its text. The game fixes the window to the bottom right at one size; everything below starts at the game's own values, and nothing is changed until you move something. While this panel is open, a pink frame shows where the window will be.",

	SI_PBSCWC_ENABLED = "Change the chat window",
	SI_PBSCWC_ENABLED_TOOLTIP = "Apply the settings below. Turn this off to put the chat window, and its text, straight back the way the game has them -- your settings are kept for when you turn it on again.",

	SI_PBSCWC_PREVIEW = "Show a preview here",
	SI_PBSCWC_PREVIEW_TOOLTIP = "The chat is only drawn on the HUD, so it cannot be seen from this menu. While this is on, a pink frame with a few lines of sample chat is drawn where the window will be, at the text size you chose.",

	-- ---- Position ----------------------------------------------------------------------
	SI_PBSCWC_SECTION_POSITION = "Position",
	SI_PBSCWC_CORNER = "Measured from",
	SI_PBSCWC_CORNER_TOOLTIP = "Which corner of the screen the position is measured from. The window is held by that same corner of itself, so it also decides which way the window grows: from the bottom right -- the game's own choice -- a taller window grows upwards and the input line stays put. Changing this does not move the window.",
	SI_PBSCWC_CORNER_TOP_LEFT = "Top left",
	SI_PBSCWC_CORNER_TOP_RIGHT = "Top right",
	SI_PBSCWC_CORNER_BOTTOM_LEFT = "Bottom left",
	SI_PBSCWC_CORNER_BOTTOM_RIGHT = "Bottom right",

	SI_PBSCWC_POSITION_X = "Distance from the side",
	SI_PBSCWC_POSITION_X_TOOLTIP = "How far the window is from the left or right edge of the screen, whichever the corner above is on. 0 puts it against that edge.",
	SI_PBSCWC_POSITION_Y = "Distance from the top or bottom",
	SI_PBSCWC_POSITION_Y_TOOLTIP = "How far the window is from the top or bottom edge of the screen, whichever the corner above is on. The game's own window is 215 up from the bottom, clear of the skill bar.",

	-- ---- Size --------------------------------------------------------------------------
	SI_PBSCWC_SECTION_SIZE = "Size",
	SI_PBSCWC_WIDTH = "Width",
	SI_PBSCWC_WIDTH_TOOLTIP = "Width of the window, input line included. The game's own is 490. The game normally keeps the window between 300 and 550; this add-on lets it go from 200 up to the width of the screen.",
	SI_PBSCWC_HEIGHT = "Height",
	SI_PBSCWC_HEIGHT_TOOLTIP = "Height of the window, input line included. The game's own is 280. The game normally keeps the window between 170 and 380; this add-on lets it go from 100 up to the height of the screen.",

	-- ---- Text --------------------------------------------------------------------------
	SI_PBSCWC_SECTION_TEXT = "Text",
	SI_PBSCWC_FONT_SIZE = "Message text size",
	SI_PBSCWC_FONT_SIZE_TOOLTIP = "Size of the chat messages. Starts at the size the game draws them at for your Small / Medium / Large setting under Settings > Social, measured rather than assumed. Once you move it, this size is used instead of that setting. The input line keeps the game's size: its box is a fixed height.",

	-- ---- Both --------------------------------------------------------------------------
	SI_PBSCWC_SECTION_GENERAL = "All settings",
	SI_PBSCWC_RESET = "Reset",
	SI_PBSCWC_RESET_TOOLTIP = "Put the position, the size and the text size back to the game's own.",
	SI_PBSCWC_RESET_BUTTON = "Reset",

	SI_PBSCWC_GAME_SETTINGS_HINT = "Whether the chat is shown on the HUD at all is the game's own setting, under Settings > Social. An add-on cannot change it, so set it there.",

	-- ---- Preview -----------------------------------------------------------------------
	SI_PBSCWC_PREVIEW_CAPTION = "Chat window (preview)",
	SI_PBSCWC_PREVIEW_ENTRY = "Input line",
	SI_PBSCWC_PREVIEW_LINE_1 = "|cC8C8FF[Zone] Traveller: Anyone for the world boss?|r",
	SI_PBSCWC_PREVIEW_LINE_2 = "|c9FE8FF[Group] PinkBanther: On my way!|r",
	SI_PBSCWC_PREVIEW_LINE_3 = "|cE8C4FF[Guild] Friend: Thanks for the mats|r",
	SI_PBSCWC_PREVIEW_LINE_4 = "|cFFB6E4[Whisper] PinkBanther: See you there|r",
	SI_PBSCWC_PREVIEW_LINE_5 = "|cFFFFFFPinkBanther says: Hello, Tamriel!|r",
	SI_PBSCWC_PREVIEW_LINE_6 = "|cC8C8FF[Zone] Traveller: Thank you all|r",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
