local strings = {
	--Settings
	NEW_DIALOG_ORDER_USE_ACCOUNTWIDE = "Use account-wide settings profile",
	NEW_DIALOG_ORDER_UNREAD_TO_FRONT = "Move unread options up",
	NEW_DIALOG_ORDER_UNREAD_TO_FRONT_DESC = "Place the not yet chosen options (white ones) on top above already chosen ones (gray)",
	NEW_DIALOG_ORDER_KEEP_CONVERSATION = "Keep conversation",
	NEW_DIALOG_ORDER_KEEP_CONVERSATION_DESC = "When you select some conversation option, next dialog options which are treated by the game as the conversation continuation will be moved up, even above the prioritized options (bank, shop, etc.). This allows to have a natural way of conversation where if you intentionally start to talk about something, the bank/shop won't jump up in your way.",
	NEW_DIALOG_ORDER_CUSTOMIZE = "Customize the order",
	NEW_DIALOG_ORDER_CUSTOMIZE_DESC = "By default the addon doesn't change the order of functional dialog options. Only the order relative to the other - conversational - options.\nIf banker NPC has 'Bank', 'Guild bank', and then 'Guild store', then the options will be moved up in the list in the same order.\nIf you want 'Guild bank' to be first before 'Bank', enable this option and set up your custom priority order in the menu below.",
	NEW_DIALOG_ORDER_PRIORITY_ORDER = "Priority order",
	NEW_DIALOG_ORDER_UNMANAGED = "Standard order",
	NEW_DIALOG_ORDER_MANAGE_DESC = "Set priorities for options in dialogs.\n'Standard order' means that the option will be handled as a regular conversation option and won't be moved up.",

	--dialog options without localization
	NEW_DIALOG_ORDER_102 = "Give money (beggars, information, etc.)",
	NEW_DIALOG_ORDER_200 = "New quest bestowal",
	NEW_DIALOG_ORDER_300 = "Complete quest",
}

--Create the string values, so other languages can add new versions
for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end