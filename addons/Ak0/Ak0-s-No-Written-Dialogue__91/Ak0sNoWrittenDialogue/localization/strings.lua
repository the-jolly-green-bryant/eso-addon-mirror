local strings = {

	SI_BINDING_NAME_AKONWD_TOGGLE_TITLE = "Toggle text",

}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end
