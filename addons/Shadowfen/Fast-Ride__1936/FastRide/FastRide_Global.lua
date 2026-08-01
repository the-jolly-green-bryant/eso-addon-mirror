-- This is always the first source file loaded so that
-- it can create the addon table/namespace.

-- It also loads strings for the proper language.


local SF = LibSFUtils

FastRide = {
	name = "FastRide",
	version = "3.2",
	author = "Shadowfen",
}
local FR = FastRide
FR.version = SF.GetIconized(FR.version, SF.colors.gold.hex)
FR.author = SF.GetIconized(FR.author, SF.colors.purple.hex)
FR.displayName = SF.GetIconized(FR.name, SF.colors.gold.hex)

SF.LoadLanguage(FastRide_localization_strings, "en")

-- keybinding(s)
ZO_CreateStringId("SI_BINDING_NAME_FASTRIDE_FORCESWAP", GetString(FR_BINDING_TOGGLE))
ZO_CreateStringId("SI_BINDING_NAME_FASTRIDE_FORCEBASE", GetString(FR_BINDING_BASE))

