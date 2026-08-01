local strings = {
	SI_HOWTOBEAM_LANG = "en",

	--Settings Part 1
	SI_HOWTOBEAM_ENABLE_NAME = "Enable",
	SI_HOWTOBEAM_ENABLE_TT = "Do you want to enable the addon to work.",
	SI_HOWTOBEAM_SETTINGS_HEADER = "Settings",
	SI_HOWTOBEAM_SETTINGS_DESC = "Here you set the configuration of your character to get the most accurate results possible.",
	SI_HOWTOBEAM_SPAMMABLE_NAME = "Spammable",
	SI_HOWTOBEAM_SPAMMABLE_TT = "Choice of the spammable you are using to compare it to Radiant.",
	SI_HOWTOBEAM_MAEL_NAME = "Maelstrom Staff",
	SI_HOWTOBEAM_MAEL_TT = "Are you using a maelstrom staff.",
	SI_HOWTOBEAM_GLYPH_NAME = "Main Bar Glyph",
	SI_HOWTOBEAM_GLYPH_TT =  "Which glyph are you using on your main bar, if you choose 'other' the addon will not take in count your glyph.",
	SI_HOWTOBEAM_INF_GLYPH_NAME = "Is your Glyph Infused",
	SI_HOWTOBEAM_INF_GLYPH_TT = "To set if your main bar glyph is on an Infused Staff or not.",
	SI_HOWTOBEAM_HP_NAME = "HP Threshold",
	SI_HOWTOBEAM_HP_TT = "The minimum target's max Health in Million for the alert to be enabled.",

	--Settings Part 2
	SI_HOWTOBEAM_CUSTOMIZATION_HEADER = "Customization",
	SI_HOWTOBEAM_CUSTOMIZATION_DESC = "Other settings to customize your HowToBeam Add-On.",
	SI_HOWTOBEAM_SPAMMABLEALERT_NAME = "Beggining Alert",
	SI_HOWTOBEAM_SPAMMABLEALERT_TT = "What alert you want, when you can start use Radiant and dropping your spammable or weakest DoT.\nRemember to keep all your DoTs up.",
	SI_HOWTOBEAM_DOTALERT_NAME = "Spear+Blockade Alert",
	SI_HOWTOBEAM_DOTALERT_TT = "What alert you want, when the only DoTs you need to refresh are Spear and Blockade.\n\nOn that patch you also need to continue applying Purifying Light and Trap / Acceleration if you used them.",
	SI_HOWTOBEAM_FINISHALERT_NAME = "Radiant Spam Alert",
	SI_HOWTOBEAM_FINISHALERT_TT = "What alert you want, when you can spam Radiant.",
	SI_HOWTOBEAM_UNLOCK_NAME = "Unlock",
	SI_HOWTOBEAM_UNLOCK_TT = "Use it to reposition the alert.",
	SI_HOWTOBEAM_COLOR_NAME = "Alert Color",
	SI_HOWTOBEAM_COLOR_TT = "Choose the color of the alert that you want.",

	--Settings Part 3
	SI_HOWTOBEAM_DEBUG_HEADER = "Debug",
	SI_HOWTOBEAM_DEBUG_DESC = " ",
	SI_HOWTOBEAM_DEBUG_NAME = "Debug",
	SI_HOWTOBEAM_DEBUG_TT = "Shows you in the chat the theoretical percentage (based on your current magic percentage) where one Radiant would be better than this or that skills (take into account full duration for DoTs).",

	--Spammable
	SI_HOWTOBEAM_PSIJIC_NAME = "Elemental Weapon",
	SI_HOWTOBEAM_PULSE_NAME = "Force Pulse",
	SI_HOWTOBEAM_JABS_NAME = "Puncturing Sweep",
	SI_HOWTOBEAM_FLARE_NAME = "Dark Flare",

	--Glyph
	SI_HOWTOBEAM_FLAME_NAME = "Flame",
	SI_HOWTOBEAM_SHOCK_NAME = "Shock",
	SI_HOWTOBEAM_ABSORB_NAME = "Absorb",
	SI_HOWTOBEAM_OTHER_NAME = "Other",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
