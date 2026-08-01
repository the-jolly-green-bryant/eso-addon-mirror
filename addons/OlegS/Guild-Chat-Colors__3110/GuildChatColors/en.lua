GuildChatColors = GuildChatColors or {}
if not GuildChatColors.i18n then GuildChatColors.i18n = {} end
local i18n = GuildChatColors.i18n
i18n.Lng = "EN"
--== General options submenu ==--
i18n.OptGeneralMenu = "General options"
i18n.OptAlwaysSetColors = "Always set colors"
i18n.OptAlwaysSetColorsTT = "Automatically set guild colors when a character logins the game." ..
                            "\nIf disabled, you can set colors only with a button or a slash command."
i18n.OptUseGlobalColors = "General colors for all servers"
i18n.OptUseGlobalColorsTT = "Use the same guild color settings for all servers and accounts." ..
                            "\nIf disabled, colors can be adjusted separately for each server."
i18n.OptUseRealmColors = "General colors for server accounts"
i18n.OptUseRealmColorsTT = "Use the same guild color settings for all server accounts." ..
                           "\nIf disabled, colors can be adjusted separately for each account."
i18n.OptUseAccountColors = "General colors for characters"
i18n.OptUseAccountColorsTT = "Use the same guild color settings for all characters in your account." ..
                             "\nIf disabled, colors can be adjusted separately for each character."
--== Additional options submenu ==--
i18n.OptAdditionalMenu = "Additional options"
i18n.OptSetGroupColors = "Set group chat color"
i18n.OptGroupColors = "Group message color"
i18n.OptGroupColorsTT = GetString(SI_SOCIAL_OPTIONS_GROUP_COLOR_TOOLTIP)
i18n.OptSetSystemColors = "Set system chat color"
i18n.OptSystemColors = "System message color"
i18n.OptSystemColorsTT = GetString(SI_SOCIAL_OPTIONS_SYSTEM_COLOR_TOOLTIP)
i18n.OptSetChatFontSize = "Set text size"
i18n.OptChatFontSize = GetString(SI_SOCIAL_OPTIONS_TEXT_SIZE)
i18n.OptChatFontSizeTT = GetString(SI_SOCIAL_OPTIONS_TEXT_SIZE_TOOLTIP)
--== Chat Colors options submenu ==--
i18n.OptDefaultColorsMenu = "Default guild color settings"
--== Named Guild Colors options submenu ==--
i18n.OptNamedColorsMenu = "Named guild color settings"
