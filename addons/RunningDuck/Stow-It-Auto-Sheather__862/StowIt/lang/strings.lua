--------------------------------------
-- English localization for StowIt --
--------------------------------------

--addon menu
local strings = {
	--Title
    STOWIT_TITEL                    = "Sheaths your weapon",
    --SaveMode
	STOWIT_SAVEMODE  				= "Settings save type",
	STOWIT_SAVEMODE_TT  			= "Use account wide settings for all your characters, or save them seperatley for each character?",
	STOWIT_SAVEMODE1 				= "Each character",
	STOWIT_SAVEMODE2 				= "Account wide",
	--Settings
	STOWIT_STOWAFTERWEAPONSWAP 		= "Hide after swap (out of combat)",
	STOWIT_STOWAFTERWEAPONSWAP_TT 	= "Hide the weapon if you swap it as you are not in combat",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
