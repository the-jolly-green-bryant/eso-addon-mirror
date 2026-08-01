------------------------------------------------
-- English localization
------------------------------------------------

local strings = {
	SI_IJA_DIWM_Title				= "|cFF00FFIsJusta|r |cffffffDisable actions while moving|r",

	SI_IJA_DIWM_DISABLEINTERACT		= "Interaction with companions",
	SI_IJA_DIWM_DISABLEINTERACT_TIP	= "Disables interaction with companion while player is moving.",

	SI_IJA_DIWM_DISABLEMORE			= "Other interactions",
	SI_IJA_DIWM_DISABLEMORE_TIP		= "Disables other interactions while player is moving.",
	SI_IJA_DIWM_DISABLEMORE_HEADER	= "Select other interactions to disable",
	
	SI_IJA_DIWM_OPTIONAL			= "Optional Features",
	
	SI_IJA_DIWM_OPTIONAL1			= "Enable reticle visual",
	SI_IJA_DIWM_OPTIONAL_TIP1		= "Enabled: reticle turns red when facing a disabled action",

	SI_IJA_DIWM_OPTIONAL2			= "Disable while crouched",
	SI_IJA_DIWM_OPTIONAL_TIP2		= "Enabled: disables the blocking of interactions while crouched",
	
	SI_IJA_DIWM_OPTIONAL3			= "Disable while in Dungeons/Trials",
	SI_IJA_DIWM_OPTIONAL_TIP3		= "Enabled: disables the blocking of interactions while in Dungeons/Trials",
	
	SI_IJA_DIWM_OPTIONAL4			= "Disable while in PVP zones",
	SI_IJA_DIWM_OPTIONAL_TIP4		= "Enabled: disables the blocking of interactions while in PVP zone",
	
	SI_IJA_DIWM_OPTIONAL5			= "Hide interactions on cooldown",
	SI_IJA_DIWM_OPTIONAL_TIP5		= "Enabled: will completely hide the interaction prompt.",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
