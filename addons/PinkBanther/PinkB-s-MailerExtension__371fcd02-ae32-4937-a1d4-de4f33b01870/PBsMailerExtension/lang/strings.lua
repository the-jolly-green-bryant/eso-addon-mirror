-- English, and the base every other language file overrides. Loaded first, so a translation
-- that is missing a line falls back to the line here rather than to "<missing SI_...>".
local strings = {
	-- ---- Where the page is ------------------------------------------------------------
	SI_PBSMX_WHERE_KEYBOARD = "The Send page is open (keyboard interface).",
	SI_PBSMX_WHERE_GAMEPAD = "The Send page is open (gamepad interface).",
	SI_PBSMX_WHERE_CLOSED = "The Send page is not open. Open Mail and go to the page you write on.",

	-- ---- Saving and restoring ---------------------------------------------------------
	SI_PBSMX_SAVED = "Saved as draft %s -- %s",
	SI_PBSMX_LOADED = "%s %s is on the page. Read it before you press Send.",
	SI_PBSMX_DELETED = "Deleted %s %s -- %s",
	SI_PBSMX_DELETED_ALL = "Emptied %s: %d deleted.",

	SI_PBSMX_LIST_EMPTY = "No drafts saved.",
	SI_PBSMX_LIST_HEADER = "%s -- %d of %d:",

	SI_PBSMX_DESCRIBE = "%s -> %s",
	SI_PBSMX_DESCRIBE_ITEMS = "%d items",
	SI_PBSMX_DESCRIBE_GOLD = "%sg",
	SI_PBSMX_DESCRIBE_COD = "C.O.D. %sg",
	SI_PBSMX_NO_SUBJECT = "(no subject)",
	SI_PBSMX_NO_ADDRESSEE = "(nobody)",

	-- ---- What could not be put back ---------------------------------------------------
	SI_PBSMX_NOTE_ITEM_GONE = "%s is not in your backpack any more -- not attached.",
	SI_PBSMX_NOTE_NOT_ATTACHED = "%s could not be attached: %s",
	SI_PBSMX_NOTE_UNNAMED_ITEM = "An item",
	SI_PBSMX_NOTE_COD = "This draft had a C.O.D. of %sg. Set it yourself: the page has one money field, and which of the two it means is the radio button, not the number.",
	SI_PBSMX_NOTE_GOLD_NOT_SET = "The page is set to C.O.D., so the draft's %sg of attached gold was not put back.",

	-- ---- Refusals ---------------------------------------------------------------------
	SI_PBSMX_ERROR_NOT_OPEN = "The Send page is not open, so there is nothing to read or write. Open Mail and go to the page you write on.",
	SI_PBSMX_ERROR_NOT_LOADED = "Saved variables are not ready yet.",
	SI_PBSMX_ERROR_BLANK = "The page is empty -- nothing to save.",
	SI_PBSMX_ERROR_FULL = "%s holds %d and its limit is %d. Delete one, or raise the limit in the settings panel or with /pbmail max.",
	SI_PBSMX_ERROR_NEED_NUMBER = "Which draft? Give the number from /pbmail list.",
	SI_PBSMX_ERROR_NO_SUCH = "There is no %s %s. The list says what there is.",
	SI_PBSMX_NOUN_DRAFT = "draft",
	SI_PBSMX_NOUN_SENT = "sent letter",
	SI_PBSMX_ERROR_UNKNOWN = "I do not know the command '%s'.",

	-- ---- Help -------------------------------------------------------------------------
	SI_PBSMX_HELP_SAVE = "/pbmail save [name] -- put what is on the Send page into the drafts box",
	SI_PBSMX_HELP_LIST = "/pbmail list -- the drafts box, numbered",
	SI_PBSMX_HELP_LOAD = "/pbmail load <n> -- put draft n back on the Send page (you press Send)",
	SI_PBSMX_HELP_DELETE = "/pbmail delete <n> | all -- throw a draft away",
	SI_PBSMX_HELP_WHERE = "/pbmail where -- whether the add-on can see the Send page right now",

	-- ---- The boxes in the mail window --------------------------------------------------
	SI_PBSMX_TAB_DRAFTS = "Drafts",
	SI_PBSMX_TAB_DRAFTS_COUNT = "%s (%d)",
	SI_PBSMX_SAVE_ENTRY = "Save as draft",
	SI_PBSMX_KEYBIND_LOAD = "Put on the page",
	SI_PBSMX_KEYBIND_DELETE = "Delete",
	SI_PBSMX_PAGE_PREVIOUS = "Previous",
	SI_PBSMX_PAGE_NEXT = "Next",
	SI_PBSMX_PAGE_OF = "Page %d of %d",

	SI_PBSMX_PREVIEW_TO = "To: %s",
	SI_PBSMX_PREVIEW_SUBJECT = "Subject: %s",
	SI_PBSMX_PREVIEW_NO_BODY = "(no message)",
	SI_PBSMX_PREVIEW_ATTACHMENTS = "Attached (%d):",

	SI_PBSMX_DELETE_TITLE = "Delete this draft?",
	SI_PBSMX_DELETE_PROMPT = "<<1>>\n\nThis cannot be undone.",

	-- ---- Said over the game, for when the chat window is not on screen ------------------
	SI_PBSMX_ALERT_SAVED = "Saved as draft %s",
	SI_PBSMX_ALERT_LOADED = "The draft is on the page",
	SI_PBSMX_ALERT_LOADED_WITH_NOTES = "The draft is on the page -- %d things could not be put back, see chat",
	SI_PBSMX_ALERT_DELETED = "Draft deleted",
	SI_PBSMX_ERROR_NO_DIALOG = "This client has no dialog to confirm with, so nothing was deleted. Use /pbmail delete <n>.",

	SI_PBSMX_WHERE_TABS = "Drafts tab -- keyboard: %s, gamepad: %s",
	SI_PBSMX_YES = "yes",
	SI_PBSMX_NO = "no",

	-- ---- The sent box ------------------------------------------------------------------
	SI_PBSMX_TAB_SENT = "Sent",
	SI_PBSMX_SENT_EMPTY = "Nothing sent yet. Letters are recorded here as you send them -- the game keeps no copy of its own, so nothing sent before this add-on was installed can appear.",
	SI_PBSMX_HELP_SENT = "/pbmail sent [load <n> | delete <n> | all] -- what you have sent, and putting one back on the page",

	-- ---- Limits ------------------------------------------------------------------------
	SI_PBSMX_EXPLANATION = "Two boxes the mail window does not have: what you have started and not sent, and what you have sent. Both live in the mail window as tabs, and everything they do is also on /pbmail.",
	SI_PBSMX_SECTION_LIMITS = "How much to keep",

	SI_PBSMX_LIMIT_DRAFTS = "Drafts kept",
	SI_PBSMX_LIMIT_DRAFTS_TOOLTIP = "How many drafts the box holds. Full means saving is refused, never that the oldest is thrown away -- a draft is something you chose to keep. Lowering this deletes nothing; it means no new drafts until you are back under it. /pbmail max drafts <n> sets any exact figure.",

	SI_PBSMX_LIMIT_SENT = "Sent letters kept",
	SI_PBSMX_LIMIT_SENT_TOOLTIP = "How many sent letters are remembered. Full means the oldest is dropped as a new one arrives -- a log that stops recording has stopped being a log. Lowering this deletes nothing straight away: the box is trimmed to the new figure the next time you send. /pbmail max sent <n> sets any exact figure.",

	SI_PBSMX_LIMIT_STATUS = "%s: %d kept, limit %d",
	SI_PBSMX_LIMIT_SET = "%s: the limit is now %d.",
	SI_PBSMX_LIMIT_OVER_ROLLING = "There are %d in there, which is over that. Nothing has been deleted -- the box is trimmed to %d the next time you send.",
	SI_PBSMX_LIMIT_OVER_KEPT = "There are %d in there, which is over that. Nothing has been deleted -- no new ones until it is back under %d.",
	SI_PBSMX_ERROR_WHICH_BOX = "Which box? /pbmail max drafts <n> or /pbmail max sent <n>.",
	SI_PBSMX_ERROR_NEED_LIMIT = "How many? A number between %d and %d.",
	SI_PBSMX_HELP_MAX = "/pbmail max [drafts | sent] <n> -- how many each box keeps",

	SI_PBSMX_GO_TO_SEND = "It is on the compose page. Go to the Send tab to read it -- and read it before you press Send.",
	SI_PBSMX_ALERT_GO_TO_SEND = "Go to the Send tab to read it",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
