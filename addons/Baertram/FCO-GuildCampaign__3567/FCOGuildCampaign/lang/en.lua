local companionStr = GetString(SI_UNIT_FRAME_NAME_COMPANION)
local companionKeybindBaseStr = "Show/hide " .. companionStr

local campDel = FCOGC.campaignIdDelimiter

local stringsEN = {
    --Keybinds
    FCOGC_SHOW_MY_CAMPAIGN                                  = "Show my campaing in chat",

    FCOGC_NOT_IN_CAMPAIGN                                   = GetString(SI_UNASSIGNCAMPAIGNRESULT4), --You are not assigned to a campaign
    FCOGC_CURRENT_CAMPAIGN                                  = GetString(SI_BATTLEGROUNDQUERYCONTEXTTYPE1), --Current campaign
    FCOGC_CURRENT_CAMPAIGN_HEADER                           = "C",
    FCOGC_CURRENT_CAMPAIGN_HEADER_TT                        = "Campaign",

    FCOGC_SAME_CAMPAIGN_TT                                  = "|c00ff00Same campaign as mine|r",
    FCOGC_DIFFERENT_CAMPAIGN_TT                             = "|cff0000Different campaign!|r",
    FCOGC_CAMPAIGNID_MISSING_IN_MEMBER_NOTE_TT              = "|cADD8E6;~<campaignId>|r missing in member note!",

    --LAM Settings
    FCOGC_LAM_SV_MODE                                       = 'Settings save mode',
    FCOGC_LAM_SV_MODE_TT                                    = 'Use account wide settings (the same for all your characters) or save them individually for each character?',
    FCOGC_LAM_SV_EACH_CHARACTER                             = "Each character",
    FCOGC_LAM_SV_ACCOUNT_WIDE                               = "Account wide",

    FCOGC_LAM_SETTING_HEADER_GUILDS                         = GetString(SI_GUILDHISTORYCATEGORY1), -- Guild
    FCOGC_LAM_SETTING_ENABLE_GUILD                          = "Enable guild %s (%q)",

    FCOGC_LAM_SETTING_HEADER_GUILD_MEMBER_NOTES             = "Guild member note",
    FCOGC_LAM_SETTING_GMN_RESERVE_LAST_5_CHARS              = "Reserve last 5 chars for campaignId",
    FCOGC_LAM_SETTING_GMN_RESERVE_LAST_5_CHARS_TT           = "Reserve the last 5 characters of your guild member note for the "..tostring(campDel).."<campaignId> identifier.\nIf this is enabled the last 5 characters will be overwritten!\nIf this is disabled the guild member note wont be overwitten, if the maxium length was already used. You need to take care of that yourself then as the text wont update unless you have shortened your message to at least provide 5 characters again.",
}

for stringId, stringValue in pairs(stringsEN) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end