-- This is always the first source file loaded so that
-- it can create the addon table/namespace.

-- It also loads strings for the proper language.


local SF = LibSFUtils
local LL = LibLanguage

DefaultGuildBank = {
	name = "DefaultGuildBank",
	displayname = "Shadowfen's Default Guild Bank",
	version = "1.21",
	author = "Shadowfen",
}
local SGB = DefaultGuildBank
SGB.version = SF.GetIconized(SGB.version, SF.colors.gold.hex)
SGB.author = SF.GetIconized(SGB.author, SF.colors.purple.hex)
SGB.displayName = SF.GetIconized(SGB.name, SF.colors.gold.hex)

LL.LoadLanguage(DefaultGuildBank_localization_strings, "en")

