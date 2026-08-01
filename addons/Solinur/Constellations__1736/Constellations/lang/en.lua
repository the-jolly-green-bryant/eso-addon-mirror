-- Menu --

local strings = {

    SI_CONSTELLATIONS_LANG = "en",

    SI_CONSTELLATIONS_COLOR_NEUTRAL = "FFFFFFF9",
    SI_CONSTELLATIONS_COLOR_MAGICKA = "FFCCCCFF",
    SI_CONSTELLATIONS_COLOR_STAMINA = "FFCCFFCC",
    SI_CONSTELLATIONS_COLOR_HEALTH = "FFFFCCCC",

    SI_CONSTELLATIONS_BUTTON_IMPORT_TEXT = "Combat Metrics Import",
    SI_CONSTELLATIONS_BUTTON_RESET_TEXT = "Reset Penetration",

    SI_CONSTELLATIONS_RATIOBUTTON_TT = "Damage Stats and Ratios",
    SI_CONSTELLATIONS_CPBUTTON_TT = "Champion Points",

    SI_CONSTELLATIONS_INPUT_STATS = "Stats",
    SI_CONSTELLATIONS_INPUT_RATIOS = "Damage Ratios",
    SI_CONSTELLATIONS_INPUT_OTHER = "Other",

    SI_CONSTELLATIONS_INPUT_STATS_LABEL1 = "Mage CP",
    SI_CONSTELLATIONS_INPUT_STATS_LABEL_TOOLTIP1 = "Total number of available CP in the Mage Constellations",

    SI_CONSTELLATIONS_INPUT_STATS_LABEL2 = "Damage Bonus %",
    SI_CONSTELLATIONS_INPUT_STATS_LABEL_TOOLTIP2 = "Sum of effects of the type 'increasing your damage done by X %', e.g. the 3 piece bonus of trial sets, combat prayer, ... ",

    SI_CONSTELLATIONS_INPUT_STATS_LABEL3 = "Spell Critical %",
    SI_CONSTELLATIONS_INPUT_STATS_LABEL4 = "Spell Critical Damage %",
    SI_CONSTELLATIONS_INPUT_STATS_LABEL5 = "Spell Penetration",

    SI_CONSTELLATIONS_INPUT_STATS_LABEL6 = "Weapon Critical %",
    SI_CONSTELLATIONS_INPUT_STATS_LABEL7 = "Weapon Critical Damage %",
    SI_CONSTELLATIONS_INPUT_STATS_LABEL8 = "Weapon Penetration",

    SI_CONSTELLATIONS_INPUT_RATIOS_LABEL1 = "Magical Damage",
    SI_CONSTELLATIONS_INPUT_RATIOS_LABEL_TOOLTIP1 = "All damage that is related to Magicka, i.e. all magic, flame, frost or lightning damage",
    SI_CONSTELLATIONS_INPUT_RATIOS_LABEL2 = "Magical Direct Damage",
    SI_CONSTELLATIONS_INPUT_RATIOS_LABEL_TOOLTIP2 = "All magical damage that does one hit immediately after it gets triggered, e.g. Crushing Shock",
    SI_CONSTELLATIONS_INPUT_RATIOS_LABEL3 = "Magical Damage over time",
    SI_CONSTELLATIONS_INPUT_RATIOS_LABEL_TOOLTIP3 = "All magical damage that does multiple hits over a duration after it gets triggered, e.g. Elemental Blockade",
    SI_CONSTELLATIONS_INPUT_RATIOS_LABEL4 = "Direct Staff Attacks",
    SI_CONSTELLATIONS_INPUT_RATIOS_LABEL_TOOLTIP4 = "All direct light and heavy attacks done using staffs, i.e. every staff attack except Shock or Resto Staff Heavy Attacks.",
    SI_CONSTELLATIONS_INPUT_RATIOS_LABEL11 = "DoT Staff Attacks",
    SI_CONSTELLATIONS_INPUT_RATIOS_LABEL_TOOLTIP11 = "Shock or Resto Staff Heavy Attacks",
    SI_CONSTELLATIONS_INPUT_RATIOS_LABEL5 = "Magical Critable Damage",
    SI_CONSTELLATIONS_INPUT_RATIOS_LABEL_TOOLTIP5 = "All magical damage that can crit and that isn't pet damage.",

    SI_CONSTELLATIONS_INPUT_RATIOS_LABEL6 = "Physical Damage",
    SI_CONSTELLATIONS_INPUT_RATIOS_LABEL_TOOLTIP6 = "All damage that is related to Stamina, i.e. all physical, poison or disease damage",
    SI_CONSTELLATIONS_INPUT_RATIOS_LABEL7 = "Physical Direct Damage",
    SI_CONSTELLATIONS_INPUT_RATIOS_LABEL_TOOLTIP7 = "All physical damage that does one hit immediately after it gets triggered.",
    SI_CONSTELLATIONS_INPUT_RATIOS_LABEL8 = "Physical Damage over time",
    SI_CONSTELLATIONS_INPUT_RATIOS_LABEL_TOOLTIP8 = "All physical damage that does multiple hits over a duration after it gets triggered, e.g. Poison Injection, ...",
    SI_CONSTELLATIONS_INPUT_RATIOS_LABEL9 = "Physical Weapon Attacks",
    SI_CONSTELLATIONS_INPUT_RATIOS_LABEL_TOOLTIP9 = "All light and heavy attacks done using physical weapons.",
    SI_CONSTELLATIONS_INPUT_RATIOS_LABEL10 = "Physical Critable Damage",
    SI_CONSTELLATIONS_INPUT_RATIOS_LABEL_TOOLTIP10 = "All physical damage that can crit and that isn't pet damage",

    SI_CONSTELLATIONS_INPUT_LABEL_SPELLPEN_TOOLTIP = "Penetration distribution from Combat Metrics Import is active. Changing this value will only offset the distribution. To reset use the \"Reset Penetration\" button below",
    SI_CONSTELLATIONS_INPUT_LABEL_WEAPONPEN_TOOLTIP = "Penetration distribution from Combat Metrics Import is active. Changing this value will only offset the distribution. To reset use the \"Reset Penetration\" button below",

    SI_CONSTELLATIONS_INPUT_OTHER_LABEL1 = "Target Resistance",
    SI_CONSTELLATIONS_INPUT_OTHER_LABEL_TOOLTIP1 = "Targets Weapon and Spell Resistance",
    SI_CONSTELLATIONS_INPUT_OTHER_LABEL2 = "DPS",
    SI_CONSTELLATIONS_INPUT_OTHER_LABEL3 = "Off Balance Uptime",

    SI_CONSTELLATIONS_RESULT_CP = "Champion Points",
    SI_CONSTELLATIONS_RESULT_OLD = "Old",
    SI_CONSTELLATIONS_RESULT_NEW = "New",
    SI_CONSTELLATIONS_RESULT_MIN = "Min",
    SI_CONSTELLATIONS_RESULT_MAX = "Max",
    SI_CONSTELLATIONS_RESULT_LAXOUT = "%+d DPS (%+.2f%%)",
    SI_CONSTELLATIONS_RESULT_LAXOUT_NEUTRAL = "---",

    SI_CONSTELLATIONS_RESULT_RESETCP = "Reset old CP",
    SI_CONSTELLATIONS_BUTTON_CALCULATE = "Calculate",
    SI_CONSTELLATIONS_RESULT_ACCOUNTOLDCP = "Account for old Champion Points",
    SI_CONSTELLATIONS_RESULT_ENFORCE_EXPLOITER = "Enforce Exploiter passive",

    SI_CONSTELLATIONS_RESULT_OLD_DPS = "Old DPS: ",
    SI_CONSTELLATIONS_RESULT_NEW_DPS = "New DPS: ",
    SI_CONSTELLATIONS_RESULT_LAYOUT_DPS = "%s%d",
    
    SI_CONSTELLATIONS_RESULT_OLD_FACTOR = "Old factor: ",
    SI_CONSTELLATIONS_RESULT_NEW_FACTOR = "New factor: ",
    SI_CONSTELLATIONS_RESULT_LAYOUT_FACTOR = "%s%.5f",

    SI_CONSTELLATIONS_RESULT_UNUSED_CP = "<<1>> CP were not used.",

    SI_CONSTELLATIONS_ERROR_TOOMUCHMIN = "Your minimum requirements exceed the available CP.",
    SI_CONSTELLATIONS_ERROR_MINMAX = "You set a minimum larger than the corresponding maximum.",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end