local strings = {
	SI_BINDING_NAME_NSR_toggle  = 'Toggle Main window',
	SI_BINDING_NAME_NSR_toggle2 = 'Toggle Quick view window',
	SI_BINDING_NAME_NSR_toggle3 = 'Toggle Unranked window',

	NEARSR_nodata               = 'No data is available for the selected character.\nPlease log in with that character first.',
	NEARSR_notdiscovered        = 'Skill line not discovered',

	NEARSR_completed            = 'No skills left to level, unless...',
	NEARSR_vampirism            = "Character hasn't discovered vampirism",
	NEARSR_lycanthropy          = "Character hasn't discovered lycanthropy",

	NEARSR_quick                = 'Show "Skill Line" ranks in Quick view',
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
