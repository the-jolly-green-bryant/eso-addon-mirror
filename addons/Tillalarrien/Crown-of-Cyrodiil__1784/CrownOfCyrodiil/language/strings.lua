local strings = {

	CROWN_TITLE		= "Crown of Cyrodiil",
	CROWN_SYMBOL		= "Pick Symbol",
	CROWN_SIZE		= "Set Size",
        CYRODIIL_ONLY           = "Active only in Cyrodiil",
	
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end
