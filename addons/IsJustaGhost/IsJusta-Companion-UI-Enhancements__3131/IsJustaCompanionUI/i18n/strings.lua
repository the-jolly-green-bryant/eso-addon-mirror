------------------------------------------------
-- English localization
------------------------------------------------

local strings = {
	SI_IJA_MCF_Title					= "|cFF00FFIsJusta|r |cffffffCompanion UI Enhancements|r",
	
	SI_IJA_MCF_ACCOUNT					= "Account Wide",
	SI_IJA_MCF_ACCOUNT_TOOLTIP			= "Sets to use one set of settings for all characters on account. Disabled saves settings per character.",

	SI_IJA_MCF_RAPPORTPROGRESS			= "Rapport Progress ",
	SI_IJA_MCF_RAPPORTPERCENT			= "<<1>>/<<2>> (<<3>>%)",

-- PRI
	SI_IJA_MCF_INDICATOR_HEADER			= "Companion Indicator",
	SI_IJA_MCF_INDICATOR_HEADER_TOOLTIP	= "Requires Player Role Indicator.",
	SI_IJA_MCF_INDICATOR				= "Indicator",
	SI_IJA_MCF_INDICATOR_TOOLTIP		= "Enabled: shows an icon over your companions head. \n\nAdjust it's appearance in the Player Role Indicator's options.",

	SI_IJA_MCF_HIDECOMBAT				= "Combat Icon",
	SI_IJA_MCF_HIDECOMBAT_TOOLTIP		= "Enabled: show over head icon in combat only.",

	SI_IJA_MCF_UPDATEDELAY				= "Update delay",
	SI_IJA_MCF_UPDATEDELAY_TOOLTIP		= "Sets the time, in milliseconds, the overhead indicator refreshes.\n\nThis effects all Player Role Indicator's group icons as well.",

-- frames
	SI_IJA_MCF_FRAME_HEADER				= "Use Custom Companion Frame",
	SI_IJA_MCF_ZOS_HEADER				= "Settings for Custom Companion Frame",
	SI_IJA_MCF_BUI_HEADER				= "Settings for BUI style Companion Frame",

	SI_IJA_MCF_FRAME					= "Enable",
	SI_IJA_MCF_FRAME_TOOLTIP			= "Enabled: Allows the use of the custom Companion Frame or the Bandit UI's companion frame.",

	SI_IJA_MCF_GRADEINT_HEALTH_LEFT		= "Health Gradient Color, Left",
	SI_IJA_MCF_GRADEINT_HEALTH_RIGHT	= "Health Gradient Color, Right",
	SI_IJA_MCF_GRADEINT_HEALTH_RESET	= "Reset Health Gradient",
	
	SI_IJA_MCF_GRADEINT_SHEILD_LEFT		= "Shield Gradient Color, Left",
	SI_IJA_MCF_GRADEINT_SHEILD_RIGHT	= "Shield Gradient Color, Right",
	SI_IJA_MCF_GRADEINT_SHEILD_RESET	= "Reset Shield Gradient",

	SI_IJA_MCF_SHOWLEVEL				= "Show Level",
	SI_IJA_MCF_SHOWLEVEL_TOOLTIP		= "Enabled: Shows the companion's level before it's name.",

	SI_IJA_MCF_GROUPFRAME				= "Use Group Frame",
	SI_IJA_MCF_GROUPFRAME_TOOLTIP		= "Enabled: when in a group, adds the companion to the group list and hides the Companion Frame.",

	SI_IJA_MCF_HIDEBARBG				= "Hide HP Bar Borders",
	SI_IJA_MCF_HIDEBARBG_TOOLTIP		= "Enabled: the Custom Companion Health bar borders are hidden.",

	SI_IJA_MCF_FRAMESTYLE				= "Frame Style",
	SI_IJA_MCF_FRAMESTYLE_TOOLTIP		= "",
	
	SI_IJA_MCF_HEALTHSTYLE				= "Health Numbers Style",
	SI_IJA_MCF_HEALTHSTYLE_TOOLTIP		= "",
	SI_IJA_MCF_HEALTHFORMAT				= "Health Numbers Format",

	SI_IJA_MCF_LOCK						= "<<1>> Lock",
	SI_IJA_MCF_LOCK_TOOLTIP				= "Locks the Companion Frame so it cannot be moved.",

	SI_IJA_MCF_OCCUPANCY				= "Occupancy",
	SI_IJA_MCF_OCCUPANCY_TOOLTIP		= "Sets the transparency of the Companion Frame's background.",

	SI_IJA_MCF_SCALE					= "Scale",
	SI_IJA_MCF_SCALE_TOOLTIP			= "Sets the Custom Companion Frame's scale.",

	SI_IJA_MCF_BUI						= "Use BUI Frame",
	SI_IJA_MCF_BUI_TOOLTIP				= "Uses the Bandit UI Frame group frames Template and settings.",
	
	SI_IJA_MCF_BUI_USEFANCY				= "Use Fancy Frame",
	SI_IJA_MCF_BUI_USEFANCY_TOOLTIP		= "Uses a glossy health bar for the Bandit UI Frame.",
	
	SI_IJA_MCF_COMPANIONFRAME_RESET		= "Reset Position",
	SI_IJA_MCF_COMPANIONFRAME_RESET_TOOLTIP	= "Resets Companion frame's position.",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
