local L = {}

L.CCSME_IconChoose = "Pick an icon"
L.CCSME_IconColorDescr = "Colorizing the icon is optional as it can sometimes cause issues with other chat related addons like pChat."
L.CCSME_IconColorize = "Colorize the icon"
L.CCSME_IconColorChoose = "Pick a color"
L.CCSME_ShowKnownByAll = "Show marker in tooltip if all characters know a recipe/motif"
L.CCSME_ShowKnownByAllCustomColor = "Color"
L.CCSME_ShowKnownByAllUseCustomColor = "Use custom color"
L.CCSME_AutoMarkKnownByAllAsJunk = "Automatically mark these recipes/motifs as permament junk for PersonalAssistant (will be applied the moment the tooltip is shown)"
L.CCSME_UnmarkUnknownJunk = "Remove items from permament junk unknown on the current character"

for stringId, stringValue in pairs(L) do
	ZO_CreateStringId(stringId, stringValue)
end