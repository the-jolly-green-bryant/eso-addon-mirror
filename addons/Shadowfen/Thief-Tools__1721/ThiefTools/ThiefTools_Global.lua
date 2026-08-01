local SF = LibSFUtils
 
ThiefTools = {
    name = "ThiefTools",
    version = "3.4.3",
	author = "Shadowfen",
    displayName = "Thief Tools",
}

ThiefTools.displayName = SF.colors.gold:Colorize(ThiefTools.displayName)
ThiefTools.version = SF.colors.gold:Colorize(ThiefTools.version)
ThiefTools.author = SF.colors.purple:Colorize(ThiefTools.author)

SF.LoadLanguage(ThiefTools_localization_strings, "en")

ThiefTools.logger = LibDebugLogger.Create("ThiefTools")
ThiefTools.logger:SetEnabled(true)

