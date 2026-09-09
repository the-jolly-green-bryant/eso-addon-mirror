-- English, and the base every other language file overrides. Loaded first, so a translation
-- that is missing a line falls back to the line here rather than to "<missing SI_...>".
local strings = {
	-- ---- Settings panel ---------------------------------------------------------------
	SI_PBSCMA_EXPLANATION = "Pick something you know how to make, say how many times you want to make it, and the window lists every ingredient it takes, how many you are carrying, and how many you are short. The candidates are drawn in that window, not here: narrow them with the category below, or search by name with /pbcraft find <text>, then move the candidate slider and press Take.",

	SI_PBSCMA_SECTION_PICK = "What to make",
	SI_PBSCMA_SECTION_AMOUNT = "How many",
	SI_PBSCMA_SECTION_WINDOW = "The window",

	SI_PBSCMA_BROWSE_SHOWING = "Show the candidate list",
	SI_PBSCMA_BROWSE_SHOWING_TOOLTIP = "Turns the window into the list of candidates to choose from. Turning it off, or taking a candidate, puts the material table back.",

	SI_PBSCMA_CATEGORY = "Category",
	SI_PBSCMA_CATEGORY_TOOLTIP = "The client's own recipe categories. Narrowing to one is the fastest way to a short list without typing anything.",
	SI_PBSCMA_CATEGORY_ALL = "All categories",

	SI_PBSCMA_SEARCH = "Search",
	SI_PBSCMA_SEARCH_TOOLTIP = "Part of a name, in any case. This row only appears if this copy of the settings library has a text field; /pbcraft find <text> does the same thing and always works.",

	SI_PBSCMA_REBUILD = "Search again",
	SI_PBSCMA_REBUILD_TOOLTIP = "Runs the current search over the catalogue again. Worth pressing after learning recipes.",
	SI_PBSCMA_REBUILD_BUTTON = "Search",

	SI_PBSCMA_KNOWN_ONLY = "Only what I have learned",
	SI_PBSCMA_KNOWN_ONLY_TOOLTIP = "On, the list is what this character can actually make. Off, it also shows recipes that have not been learned, marked with *, which is useful when deciding what to learn.",

	SI_PBSCMA_PAGE = "Page",
	SI_PBSCMA_PAGE_TOOLTIP = "Which page of the candidate list the window is showing. Dragging past the last page stops at the last page.",

	SI_PBSCMA_CURSOR = "Candidate",
	SI_PBSCMA_CURSOR_TOOLTIP = "Moves the marker down the list in the window. This is the choosing; the button below takes whatever the marker is on.",

	SI_PBSCMA_TAKE = "Take the marked candidate",
	SI_PBSCMA_TAKE_TOOLTIP = "Makes the marked candidate the thing being counted, and puts the material table back in the window.",
	SI_PBSCMA_TAKE_BUTTON = "Take",

	SI_PBSCMA_CLEAR = "Nothing picked",
	SI_PBSCMA_CLEAR_TOOLTIP = "Forgets what is picked. The window stays, and says nothing is picked.",
	SI_PBSCMA_CLEAR_BUTTON = "Clear",

	SI_PBSCMA_QUANTITY = "Times to make it",
	SI_PBSCMA_QUANTITY_TOOLTIP = "How many times the recipe is made, not how many items come out: a recipe that yields four, made three times, is three sets of ingredients and twelve items. The window says what the yield works out at.",

	SI_PBSCMA_SCOPE = "Count what is in",
	SI_PBSCMA_SCOPE_TOOLTIP = "Which storage the held column counts. House banks are storage you cannot reach from a crafting station, which is why they are not counted by default.",
	SI_PBSCMA_SCOPE_BACKPACK = "Backpack",
	SI_PBSCMA_SCOPE_BANK = "Backpack and bank",
	SI_PBSCMA_SCOPE_CRAFTBAG = "Backpack, bank and craft bag",
	SI_PBSCMA_SCOPE_ALL = "Everything, house banks included",

	SI_PBSCMA_ENABLED = "Show the window",
	SI_PBSCMA_ENABLED_TOOLTIP = "The master switch. Turned off the window is taken down and the add-on stops listening to your bags entirely.",

	SI_PBSCMA_WIDTH = "Width",
	SI_PBSCMA_WIDTH_TOOLTIP = "How wide the window is. The three number columns keep their width; the material name column takes what is left, and long names are cut with an ellipsis.",
	SI_PBSCMA_HEIGHT = "Height",
	SI_PBSCMA_HEIGHT_TOOLTIP = "How tall the window is. Too short for the rows and the last of them are simply not drawn -- nothing spills out of the window.",

	SI_PBSCMA_POSITION = "Corner",
	SI_PBSCMA_POSITION_TOOLTIP = "Which part of the screen the window is anchored to. The offsets below move it from there.",
	SI_PBSCMA_POS_TOPLEFT = "Top left",
	SI_PBSCMA_POS_TOP = "Top",
	SI_PBSCMA_POS_TOPRIGHT = "Top right",
	SI_PBSCMA_POS_LEFT = "Left",
	SI_PBSCMA_POS_CENTER = "Centre",
	SI_PBSCMA_POS_RIGHT = "Right",
	SI_PBSCMA_POS_BOTTOMLEFT = "Bottom left",
	SI_PBSCMA_POS_BOTTOM = "Bottom",
	SI_PBSCMA_POS_BOTTOMRIGHT = "Bottom right",

	SI_PBSCMA_OFFSET_X = "Offset across",
	SI_PBSCMA_OFFSET_Y = "Offset down",
	SI_PBSCMA_OFFSET_TOOLTIP = "How far the window sits from the corner it is anchored to. Negative moves it the other way.",

	SI_PBSCMA_FONT_SIZE = "Text size",
	SI_PBSCMA_FONT_SIZE_TOOLTIP = "The size of every line in the window. The number columns widen with it, so the table stays lined up.",

	SI_PBSCMA_FACE = "Typeface",
	SI_PBSCMA_FACE_TOOLTIP = "Only faces the console interface already has loaded are offered. A face nothing else is drawing with has to be built on use, and that build comes out of the memory every add-on on the machine shares.",
	SI_PBSCMA_FACE_GAMEPAD_MEDIUM = "Gamepad, medium",
	SI_PBSCMA_FACE_GAMEPAD_BOLD = "Gamepad, bold",
	SI_PBSCMA_FACE_GAMEPAD_LIGHT = "Gamepad, light",
	SI_PBSCMA_FACE_MEDIUM = "Interface, medium",
	SI_PBSCMA_FACE_BOLD = "Interface, bold",

	SI_PBSCMA_STYLE = "Outline",
	SI_PBSCMA_STYLE_TOOLTIP = "How the text is separated from what is behind it. A thicker outline reads better over a bright background and costs nothing.",
	SI_PBSCMA_STYLE_SOFT_THIN = "Soft shadow, thin",
	SI_PBSCMA_STYLE_SOFT_THICK = "Soft shadow, thick",
	SI_PBSCMA_STYLE_OUTLINE = "Thick outline",
	SI_PBSCMA_STYLE_SHADOW = "Shadow",
	SI_PBSCMA_STYLE_NONE = "None",

	SI_PBSCMA_OPACITY = "Background",
	SI_PBSCMA_OPACITY_TOOLTIP = "How solid the panel behind the text is. At 0 there is no panel at all and only the text is drawn.",

	SI_PBSCMA_DRAW = "Draw order",
	SI_PBSCMA_DRAW_TOOLTIP = "Where the window sits among the other interface elements. In front is the default because the candidate list has to be readable while the settings screen is open.",
	SI_PBSCMA_DRAW_FRONT = "In front",
	SI_PBSCMA_DRAW_NORMAL = "Normal",
	SI_PBSCMA_DRAW_BACK = "Behind",

	SI_PBSCMA_RESET = "Back to defaults",
	SI_PBSCMA_RESET_TOOLTIP = "Every setting on this panel back to the shipped value, and nothing picked.",
	SI_PBSCMA_RESET_BUTTON = "Reset",

	-- ---- The window -------------------------------------------------------------------
	SI_PBSCMA_WINDOW_TITLE = "Craft materials",
	SI_PBSCMA_WINDOW_NOTHING_PICKED = "Nothing picked. Settings panel, or /pbcraft find <text>",
	SI_PBSCMA_WINDOW_TARGET_LOST = "What was picked is not in this client's recipe lists any more.",
	SI_PBSCMA_WINDOW_YIELD = "  (%d made)",
	SI_PBSCMA_WINDOW_SHORT = "Short of %d",
	SI_PBSCMA_WINDOW_ENOUGH = "Everything is here",
	SI_PBSCMA_WINDOW_CRAFTABLE = "   enough for %d",
	SI_PBSCMA_WINDOW_UNCOUNTED = "   (something could not be counted)",

	SI_PBSCMA_COLUMN_MATERIAL = "Material",
	SI_PBSCMA_COLUMN_NEED = "Need",
	SI_PBSCMA_COLUMN_HAVE = "Have",
	SI_PBSCMA_COLUMN_SHORT = "Short",
	SI_PBSCMA_COLUMN_CANDIDATE = "Candidates",
	SI_PBSCMA_COLUMN_INGREDIENTS = "Parts",

	SI_PBSCMA_BROWSE_TITLE = "Candidates -- %s",
	SI_PBSCMA_BROWSE_TITLE_SEARCH = "Search: %s",
	SI_PBSCMA_BROWSE_COUNT = "%d found, page %d of %d",
	SI_PBSCMA_BROWSE_TRUNCATED = "   (stopped counting)",
	SI_PBSCMA_BROWSE_EMPTY = "Nothing matched.",
	SI_PBSCMA_BROWSE_UNKNOWN_MARK = " *",

	-- ---- Chat -------------------------------------------------------------------------
	SI_PBSCMA_ON = "on",
	SI_PBSCMA_OFF = "off",

	SI_PBSCMA_STATUS_TARGET = "making %s, %d times",
	SI_PBSCMA_STATUS_SHORT = "short of %d materials; enough on hand for %d",
	SI_PBSCMA_STATUS_SCOPE = "counting: %s",
	SI_PBSCMA_STATUS_NO_TARGET = "nothing picked yet -- /pbcraft find <text>",
	SI_PBSCMA_STATUS_LOST = "what was picked is not in this client's recipe lists any more",

	SI_PBSCMA_REPLY_MATCHES = "%d found -- page %d of %d",
	SI_PBSCMA_REPLY_NO_MATCHES = "nothing matched",
	SI_PBSCMA_REPLY_PICK_HINT = "/pbcraft pick <number> to take one of these",
	SI_PBSCMA_REPLY_PICKED = "picked %s, %d times",
	SI_PBSCMA_REPLY_QUANTITY = "making it %d times",
	SI_PBSCMA_REPLY_SWITCH = "%s: %s",
	SI_PBSCMA_REPLY_CLEARED = "nothing picked",
	SI_PBSCMA_REPLY_RESET = "every setting back to default",
	SI_PBSCMA_REPLY_PROBE = "%d lists, %d recipes, %d of them learned -- one full pass took %d ms",
	SI_PBSCMA_REPLY_CATEGORIES = "categories -- /pbcraft cat <number>",

	SI_PBSCMA_ERROR_NO_API = "this client does not answer the recipe functions, so there is nothing to list",
	SI_PBSCMA_ERROR_NO_WINDOW = "the window could not be created on this client",
	SI_PBSCMA_ERROR_NEED_NUMBER = "that wants a number",
	SI_PBSCMA_ERROR_NO_SUCH_CANDIDATE = "there is no candidate with that number on this page",
	SI_PBSCMA_ERROR_NO_SUCH_CATEGORY = "there is no category with that number -- /pbcraft list",
	SI_PBSCMA_ERROR_ON_OR_OFF = "that wants on or off",
	SI_PBSCMA_ERROR_QUANTITY = "the count has to be between %d and %d",
	SI_PBSCMA_ERROR_SCOPE = "scope has to be backpack, bank, craftbag or all",
	SI_PBSCMA_ERROR_UNKNOWN = "no such command: %s",
	SI_PBSCMA_ERROR_DRAW_REFUSED = "this client refused the draw order change; the window is drawing where it was",

	-- ---- Help -------------------------------------------------------------------------
	SI_PBSCMA_HELP_HEADER = "commands:",
	SI_PBSCMA_HELP_STATUS = "/pbcraft -- what is picked, and what it is short of",
	SI_PBSCMA_HELP_FIND = "/pbcraft find <text> -- search names, and show the candidates in the window",
	SI_PBSCMA_HELP_PICK = "/pbcraft pick <number> -- take one of the candidates on this page",
	SI_PBSCMA_HELP_PAGE = "/pbcraft next | prev | page <n> -- move through the candidates",
	SI_PBSCMA_HELP_QTY = "/pbcraft qty <n> -- how many times to make it",
	SI_PBSCMA_HELP_LIST = "/pbcraft list -- the categories, with their numbers",
	SI_PBSCMA_HELP_CAT = "/pbcraft cat <n> -- narrow the search to one category, 0 for all",
	SI_PBSCMA_HELP_KNOWN = "/pbcraft known on | off -- only recipes this character has learned",
	SI_PBSCMA_HELP_SCOPE = "/pbcraft scope backpack | bank | craftbag | all -- what the held column counts",
	SI_PBSCMA_HELP_BROWSE = "/pbcraft browse [on | off] -- the candidate list in the window",
	SI_PBSCMA_HELP_CLEAR = "/pbcraft clear -- pick nothing",
	SI_PBSCMA_HELP_MASTER = "/pbcraft on | off -- the master switch",
	SI_PBSCMA_HELP_PROBE = "/pbcraft probe -- count the catalogue once and say how long it took",
	SI_PBSCMA_HELP_RESET = "/pbcraft reset -- every setting back to default",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
