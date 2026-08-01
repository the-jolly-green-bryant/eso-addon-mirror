local strings = {
	NEARSBB_LAM_co_bcast_name = 'Block Banner removal',
	NEARSBB_LAM_co_bcast_tooltip = 'This setting alone detects if the "Banner Bearer" skill is active and blocks its removal. Works as a base for the other options and needs to be ON for them to work!',
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
