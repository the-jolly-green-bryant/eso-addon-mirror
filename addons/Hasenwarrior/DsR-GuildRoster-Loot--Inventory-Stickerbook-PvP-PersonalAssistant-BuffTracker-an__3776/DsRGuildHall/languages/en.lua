local DsRIcon = DsRglobals:HolidayIconLoad()

-- English

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Quality
DsR_Quality_NONE       = "- Inactive -"
DsR_Quality_NORMAL     = "1 - Normal"
DsR_Quality_FINE       = "2 - |c00FF00Fine|r"
DsR_Quality_SUPERIOR   = "3 - |c259EFASuperior|r"
DsR_Quality_EPIC       = "4 - |c8525FAEpic|r"
DsR_Quality_LEGENDARY  = "5 - |cF7C42ALegendary|r"
DsR_Quality_MYTHIC     = "6 - |cFFA500Mythic|r"

-- RavenBar
DsR_Bar_TurnOff        = "Turn off"
DsR_Bar_TurnOn         = "Show"
DsR_Bar_PosTOP         = "Top"
DsR_Bar_PosBOTTOM      = "Bottom"
DsR_Bar_Inventory      = "Inventory"
DsR_Bar_Bank           = "Bank"
DsR_Bar_InventoryBank  = "Inventory/Bank"
DsR_Bar_SoulGemsEmpty  = "Empty"
DsR_Bar_SoulGems       = "Filled"
DsR_Bar_SoulGemsboth   = "Empty/Filled"
DsR_Bar_BankUse        = "Proven"
DsR_Bar_BankMax        = "Size"
DsR_Bar_BankUseMax     = "Proven/Size"

-- Chat
DsR_Chat_SAY     = "Say"
DsR_Chat_ZONE    = "Zone"
DsR_Chat_PARTY   = "Group"
DsR_Chat_G1      = "Guild 1"
DsR_Chat_G2      = "Guild 2"
DsR_Chat_G3      = "Guild 3"
DsR_Chat_G4      = "Guild 4"
DsR_Chat_G5      = "Guild 5"

-- IconText position
DsR_IconTextout   = "Off"
DsR_IconTextright = "Right"
DsR_IconTextleft  = "Left"
DsR_IconTextup    = "Up"
DsR_IconTextdown  = "Down"

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Donation
ZO_CreateStringId("DsRGuild_donationMailSubject"             , "Donation for DsR GuildRoster")
ZO_CreateStringId("DsRGuild_donationMailTxT"                 , "I love your guild add-on, so a donation for you and the guild 'Die sieben Raben', for the work of the add-on.\nThank you very much and keep it up.\n\nGreeting\n<<1>>")
ZO_CreateStringId("DsRGuild_donationSmall"                   , zo_iconFormat("/esoui/art/icons/housing_sum_inc_altcup001.dds", 26, 26) .. "|c9fb6cdSmall|r")
ZO_CreateStringId("DsRGuild_donationMiddle"                  , zo_iconFormat("/esoui/art/icons/housing_sum_inc_altcup003.dds", 26, 26) .. "|c9fb6cdMedium|r")
ZO_CreateStringId("DsRGuild_donationNormal"                  , zo_iconFormat("/esoui/art/icons/housing_sum_inc_altcup003.dds", 26, 26) .. "|c9fb6cdNormal|r")
ZO_CreateStringId("DsRGuild_donationBig"                     , zo_iconFormat("/esoui/art/icons/housing_sum_inc_altcup006.dds", 26, 26) .. "|c9fb6cdAdequate|r")
ZO_CreateStringId("DsRGuild_donationTxt"                     , "|c80dfffI would be happy about a donation for me and the guild 'Die sieben Raben'|r :-)")
-- ZO_CreateStringId("DsRGuild_donationTxt1"                    , "|c80dfffI would be happy about a " .. zo_iconFormat("/esoui/art/currency/currency_gold.dds", 16, 16) .. "-donation for me and the guild 'Die sieben Raben' :-)|r |c8b6914(Click on 'Donate' at the top right)")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- SLASH COMMANDS
ZO_CreateStringId("DsRGuildcmd_addonupdate"                  , "Open the Popup-Window 'Addon-Update News'")
ZO_CreateStringId("DsRGuildcmd_settings"                     , "Open Settings")
ZO_CreateStringId("DsRGuildcmd_inventory"                    , "Open InventoryManager")
ZO_CreateStringId("DsRGuildcmd_buff"                         , "Open the buff management")
ZO_CreateStringId("DsRGuildcmd_binding"                      , "Bind all set items")
ZO_CreateStringId("DsRGuildcmd_post"                         , "Post all set items")
ZO_CreateStringId("DsRGuildcmd_port"                         , "Port back to Mainbase")
ZO_CreateStringId("DsRGuildcmd_deathwindow"                  , "Open the 'Tabele of Death'")
ZO_CreateStringId("DsRGuildcmd_deathreset"                   , "Reset the 'Tabele of Death'")
ZO_CreateStringId("DsRGuildcmd_deathpost"                    , "Post the Playerdeath to chat")
ZO_CreateStringId("DsRGuildcmd_repair"                       , "Repair your entire armor")
ZO_CreateStringId("DsRGuildcmd_recharge"                     , "Recharge your weapons")
ZO_CreateStringId("DsRGuildcmd_repairandrecharge"            , "Repair armor and recharge weapons")
ZO_CreateStringId("DsRGuildcmd_Companion"                    , "|c9fb6cdDsR GuildRoster - Companions|r")
ZO_CreateStringId("DsRGuildcmd_Assistant"                    , "|c9fb6cdDsR GuildRoster - Assistants|r")
ZO_CreateStringId("DsRGuildcmd_General"                      , "|c9fb6cdDsR GuildRoster - General|r")
ZO_CreateStringId("DsRGuildcmd_GroupAttack"                  , "Start the group attack")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- General
ZO_CreateStringId("DsR_Guild"                                , "GUILD HOUSE")
ZO_CreateStringId("DsR_Hall"                                 , "Guildhouse")
ZO_CreateStringId("DsR_Leaders"                              , zo_iconFormat("/DsRGuildHall/misc/DsR_RabenwachtFLO.dds", 26, 26) .. "Gildenleitung" .. zo_iconFormat("/DsRGuildHall/misc/DsR_RabenwachtFLO.dds", 26, 26))
ZO_CreateStringId("DsR_HallMem"                              , "Primary residence")
ZO_CreateStringId("DsR_Post"                                 , "guild mail")
ZO_CreateStringId("DsR_Event"                                , "Upcoming guild events")
ZO_CreateStringId("DsR_Aldmeri"                              , "Aldmeri Dominion")
ZO_CreateStringId("DsR_Ebonheart"                            , "Ebonheart Pact")
ZO_CreateStringId("DsR_Daggerfall"                           , "Daggerfall Covenant")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Holiday center message
ZO_CreateStringId("DsR_valentinTXT"                          , "wish you a nice")
ZO_CreateStringId("DsR_valentinEvent"                        , "Valentine's Day")
ZO_CreateStringId("DsR_esterTXT"                             , "wish you and your family")
ZO_CreateStringId("DsR_esterEvent"                           , "HAPPY ESTER")
ZO_CreateStringId("DsR_halloweenTXT"                         , "wish you a cruel")
ZO_CreateStringId("DsR_halloweenEvent"                       , "HALLOWEEN")
ZO_CreateStringId("DsR_xmasTXT"                              , "wish you and your family")
ZO_CreateStringId("DsR_xmasEvent"                            , "MERRY CHRISTMAS")
ZO_CreateStringId("DsR_newyearTXT"                           , "wish you and your family a healthy and happy")
ZO_CreateStringId("DsR_newyearEvent"                         , "NEW YEAR")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Locations
ZO_CreateStringId("DsR_HelRa"                                , "Hel Ra Citadel")
ZO_CreateStringId("DsR_AA"                                   , "Aetherian Archives")
ZO_CreateStringId("DsR_Schlund"                              , "Maw of Lorkhaj")
ZO_CreateStringId("DsR_Sanctum"                              , "Sanctum Ophidia")
ZO_CreateStringId("DsR_HoF"                                  , "Halls Of Fabrication")
ZO_CreateStringId("DsR_Anstalt"                              , "Asylum Sanctorium")
ZO_CreateStringId("DsR_Wolkenruh"                            , "Cloudrest")
ZO_CreateStringId("DsR_Sonnenspitz"                          , "Sunspire")
ZO_CreateStringId("DsR_Kynes"                                , "Kyne's Aegis")
ZO_CreateStringId("DsR_Fels"                                 , "Rockgrove")
ZO_CreateStringId("DsR_Grauensegel"                          , "Dreadsail Reef")
ZO_CreateStringId("DsR_Wahnsinn"                             , "Sanity's Edge")
ZO_CreateStringId("DsR_Luminit"                              , "Lucent Citadel")
ZO_CreateStringId("DsR_Gebein"                               , "Ossein Cage")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- days
ZO_CreateStringId("DsR_Mo"                                   , "Monday")
ZO_CreateStringId("DsR_Di"                                   , "Tuesday")
ZO_CreateStringId("DsR_Mi"                                   , "Wednesday")
ZO_CreateStringId("DsR_Do"                                   , "Thursday")
ZO_CreateStringId("DsR_Fr"                                   , "Friday")
ZO_CreateStringId("DsR_Sa"                                   , "Saturday")
ZO_CreateStringId("DsR_So"                                   , "Sunday")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Guildmail
ZO_CreateStringId("DsR_TITLE_COMPOSE"                        , "Compose")
ZO_CreateStringId("DsR_TITLE_RECIPIENTS"                     , "Recipients")
ZO_CreateStringId("SI_COMPOSE_BUTTON_SEND"                   , "Send")
ZO_CreateStringId("SI_COMPOSE_BUTTON_CANCEL"                 , "Cancel")
ZO_CreateStringId("SI_COMPOSE_BUTTON_PAUSE"                  , "Pause")
ZO_CreateStringId("SI_COMPOSE_BUTTON_CONTINUE"               , "Continue")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- DsR-AutoInvite
ZO_CreateStringId("SI_DsRAI"                                 , "|c9fb6cdDsR-AutoInvite|r")
ZO_CreateStringId("SI_DsRAI_NO_GROUP_MESSAGE"                , "Group is empty")
ZO_CreateStringId("SI_DsRAI_ENCOUNTER_ON_OFF"                , "Encounterlog status")
ZO_CreateStringId("SI_DsRAI_ENCOUNTER_ON_OFF_TP"             , "As a group leader, display a notification about log status on the screen?\n(Only displayed when you are in the raid)")
ZO_CreateStringId("SI_DsRAI_ENCOUNTER_START"                 , "Encounterlog start")
ZO_CreateStringId("SI_DsRAI_ENCOUNTER_START_TP"              , "Should I ask you if 'Encounterlog' should be started, as soon as you join the raid?")
ZO_CreateStringId("SI_DsRAI_ENCOUNTER_LOG"                   , "Recording for the raid started")
ZO_CreateStringId("SI_DsRAI_ENCOUNTER_LOG_STOP"              , "Recording for the raid stopped")
ZO_CreateStringId("SI_DsRAI_ENCOUNTER_DIALOG"                , "Start recording for the raid?")
ZO_CreateStringId("SI_DsRAI_ENCOUNTER_DIALOG_STOP"           , "Stop recording for the raid?")
ZO_CreateStringId("SI_DsRAI_SEND_TO_USER"                    , " |c9fb6cd[DsR-AI]|r |c32CD32Sending invite to|r |c01A5C6<<1>>|r")
ZO_CreateStringId("SI_DsRAI_USER_LEAVE"                      , " |c9fb6cd[DsR-AI]|r |c01A5C6<<1>>|r |cEE0000leave group|r")
ZO_CreateStringId("SI_DsRAI_KICK"                            , " |c9fb6cd[DsR-AI]|r |cEE0000Kicking|r |c01A5C6<<1>>|r (offline for <<2>>)")
ZO_CreateStringId("SI_DsRAI_GROUP_OPEN_RESTART"              , " |c9fb6cd[DsR-AI]|r Now space in group.")
ZO_CreateStringId("SI_DsRAI_START_ON"                        , " |c9fb6cd[DsR-AI]|r listening on string >> |cFF4242<<1>>|r <<")
ZO_CreateStringId("SI_DsRAI_STOP"                            , " |c9fb6cd[DsR-AI]|rr |cEE0000stopedr")
ZO_CreateStringId("SI_DsRAI_GROUP_FULL_STOP"                 , "Group full. Disabling  |c9fb6cdDsR-AI|r")
ZO_CreateStringId("SI_DsRAI_OFF"                             , "Disabling  |c9fb6cdDsR-AI|r")
ZO_CreateStringId("SI_DsRAI_ERROR_ACCOUNT"                   , " |c9fb6cd[DsR-AI]|r Could not find player name for |c01A5C6<<1>>|r. Please manually invite.")
ZO_CreateStringId("SI_DsRAI_ERROR_ZONE"                      , " |c9fb6cd[DsR-AI]|r Player |c01A5C6<<1>>|r is not in Cyrodiil but in <<2>>")
ZO_CreateStringId("SI_DsRAI_INV_BLOCK"                       , " |c9fb6cd[DsR-AI]|r Blocking invite to prevent crashes.")
ZO_CreateStringId("SI_DsRAI_ERROR_INVITE"                    , " |c9fb6cd[DsR-AI]|r Error - couldn't invite on channel:")
ZO_CreateStringId("SI_DsRAI_ERROR_KICK_TABLE"                , " |c9fb6cd[DsR-AI]|r No one named |c01A5C6<<1>>|r found in group scan. Please manually kick.")
ZO_CreateStringId("SI_DsRAI_OPT_ENABLED"                     , "Enabled")
ZO_CreateStringId("SI_DsRAI_TT_ENABLED"                      , "Whether to enable AutoInvite")
ZO_CreateStringId("SI_DsRAI_OPT_STRING"                      , "Invite String")
ZO_CreateStringId("SI_DsRAI_TT_STRING"                       , "Text to check messages to auto-invite for\nTo check for multiple words, enter them separated by |cFF4242;|r\ne.g. Rabe|cFF4242;|rRaven|cFF4242;|rLFG")
ZO_CreateStringId("SI_DsRAI_OPT_MAX_SIZE"                    , "Max group size")
ZO_CreateStringId("SI_DsRAI_TT_MAX_SIZE"                     , "Maximum number of players to invite to group")
ZO_CreateStringId("SI_DsRAI_OPT_RESTART"                     , "Restart")
ZO_CreateStringId("SI_DsRAI_TT_RESTART"                      , "Restart AutoInvite if drop below max")
ZO_CreateStringId("SI_DsRAI_OPT_CYRCHECK"                    , "Cyrodiil Check")
ZO_CreateStringId("SI_DsRAI_TT_CYRCHECK"                     , "Only invite players that are in Cyrodiil.\n(This only runs if you are in Cyrodiil yourself.)")
ZO_CreateStringId("SI_DsRAI_OPT_KICK"                        , "Auto kick")
ZO_CreateStringId("SI_DsRAI_TT_KICK"                         , "Kick players that go offline")
ZO_CreateStringId("SI_DsRAI_OPT_KICK_TIME"                   , "Time before kick")
ZO_CreateStringId("SI_DsRAI_TT_KICK_TIME"                    , "Number of seconds to wait before kicking an offline player")
ZO_CreateStringId("SI_DsRAI_BTN_REFRESH"                     , "Refresh List")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- DsR-Party
ZO_CreateStringId("DsRGuildGroup_GRP_CHAR_LONG"              , "Charaktername")
ZO_CreateStringId("DsRGuildGroup_GRP_ACC_LONG"               , "Username")
ZO_CreateStringId("DsRGuildGroup_GRP_LOCATION_LONG"          , "Place")
ZO_CreateStringId("DsRGuildGroup_GRP_CLASS_LONG"             , "Class")
ZO_CreateStringId("DsRGuildGroup_GRP_LVL"                    , "LVL")
ZO_CreateStringId("DsRGuildGroup_GRP_ROLE_LONG"              , "Role")
ZO_CreateStringId("DsRGuildGroup_GRP_LEADER_TT"              , "Leader")
ZO_CreateStringId("DsRGuildGroup_GRP_AVA_STRING"             , "AvA Rang")
ZO_CreateStringId("DsRGuildGroup_AVGCP"                      , "Average champion points: |cffffff<<1>>|r")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Setting Menue
ZO_CreateStringId("DsRGuildMenue_DsRinternal"                , "Die sieben Raben - internal")
ZO_CreateStringId("DsRGuildMenue_lootmanager"                , "Lootmanager")
ZO_CreateStringId("DsRGuildMenue_stickerbook"                , "Sticker Book ")
ZO_CreateStringId("DsRGuildMenue_alliancewar"                , "|ced2431Alliance War|r")
ZO_CreateStringId("DsRGuildMenue_cyrostatus"                 , "Cyrodiil")
ZO_CreateStringId("DsRGuildMenue_GroupRaid"                  , "Group & Raids")
ZO_CreateStringId("DsRGuildMenue_Divers"                     , "Other useful things")
ZO_CreateStringId("DsRGuildMenue_PvPandBG"                   , "PvP & Battleground")
ZO_CreateStringId("DsRGuildMenue_general"                    , "|c7393B3General|r")
ZO_CreateStringId("DsRGuildMenue_cyrodiil"                   , "Cyrodiil ")
ZO_CreateStringId("DsRGuildMenue_ImperialCity"               , "|c7393B3Entrances & names|r")
ZO_CreateStringId("DsRGuildMenue_BuffReminder"               , "Reminder - XP-/AP-Scrolls, Food")
ZO_CreateStringId("DsRGuildMenue_InventoryManager"           , "Inventory Manager")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Informationen
ZO_CreateStringId("DsRGuildMenue_DsRInfoNews"                , "Gilden-Update News anzeigen?")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Friends
ZO_CreateStringId("DsRGuildMenue_DsRFriendsONLINE"           , "|c00ff00<<1>>|r |c9fb6cdhas logged in with ->|r <<2>> |c9fb6cd<-|r")
ZO_CreateStringId("DsRGuildMenue_DsRFriendsOFFLINE"          , "|c00ff00<<1>>|r |cFAA0A0has logged out with ->|r <<2>> |c9fb6cd<-|r")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- LootManager
ZO_CreateStringId("DsRGuildLoot_experience"                  , " Experience ")
ZO_CreateStringId("DsRGuildLoot_cAchievementsTxt"            , "Completed! ")
ZO_CreateStringId("DsRGuildLoot_pAchievementsTxt"            , "Progress:")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- StickerBook
ZO_CreateStringId("DsRGuildBind_bindunknown"                 , "Bind all set items")
ZO_CreateStringId("DsRGuildBind_postunbounted"               , "Post all set items")
ZO_CreateStringId("DsRGuildBind_req_requestPrefixdefault"    , "Can I get? -> ")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Buff Analyse
ZO_CreateStringId("DsRGuildMenue_BuffsAnalyseDebug"           , "Display ability in chat")
ZO_CreateStringId("DsRGuildMenue_BuffsAnalyseFilterName"      , "Filter by this name")
ZO_CreateStringId("DsRGuildMenue_BuffsAnalyseCopyID1"         , "Insert ID ")
ZO_CreateStringId("DsRGuildMenue_BuffsAnalyseCopyID2"         , " to the list '")
ZO_CreateStringId("DsRGuildMenue_BuffsAnalyseCopyID3"         , "' in addition")
ZO_CreateStringId("DsRGuildMenue_BuffsAnalyseFilter"          , "Search:")
ZO_CreateStringId("DsRGuildMenue_BuffsAnalyseFilterAll"       , "All")
ZO_CreateStringId("DsRGuildMenue_BuffsAnalyseFilterClose"     , "Close")
ZO_CreateStringId("DsRGuildMenue_BuffsAnalyseFilterSave"      , "Save")
ZO_CreateStringId("DsRGuildMenue_BuffsAnalyseFilterRefresh"   , "|cFF0000Reset|r")
ZO_CreateStringId("DsRGuildMenue_BuffsAnalyseFound"           , "Number: %s%d|r / |cFFA500%d|r")
ZO_CreateStringId("DsRGuildcmd_BuffSettingButtonWindow"       , "Buff-Management")
ZO_CreateStringId("DsRGuildMenue_BuffsIDAnaly"                , "|c00CDCDDsR Buff-Analyse|r")
ZO_CreateStringId("DsRGuildMenue_BuffsIDAnalySearch"          , "|c00CDCDSearch ID's|r")
ZO_CreateStringId("DsRGuildMenue_BuffsWindowButton"           , "|c00CDCDDsR Buff-Management|r")
ZO_CreateStringId("DsRGuildMenue_BuffsWindowChar"             , "Logged-in character: ")
ZO_CreateStringId("DsRGuildMenue_BuffsWhiteDesc"              , "The numbers must always be separated with a |cFFA500COMMA|r.")
ZO_CreateStringId("DsRGuildMenue_BuffsWhiteDesc1"             , "The order on the UI is the order in the list.")
ZO_CreateStringId("DsRGuildMenue_BuffsCheckClean"             , "|cFF0000Check lists for duplicate values|r")
ZO_CreateStringId("DsRGuildMenue_BuffsSetRole"                , "Make yourself the %s")
ZO_CreateStringId("DsRGuildMenue_BuffsShowList"               , "Preview")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- PvP
ZO_CreateStringId("DsRGuildPvP_ap_repairtxt"                 , "Repair: ")
ZO_CreateStringId("DsRGuildPvP_ap_killstxt"                  , "Kill: ")
ZO_CreateStringId("DsRGuildPvP_ap_defensetxt"                , "Defense: ")
ZO_CreateStringId("DsRGuildPvP_ap_offensetxt"                , "Offense: ")
ZO_CreateStringId("DsRGuildPvP_ap_revivaltxt"                , "Revival: ")
ZO_CreateStringId("DsRGuildPvP_ap_awardstxt"                 , "Award: ")
ZO_CreateStringId("DsRGuildPvP_ap_questtxt"                  , "Quest: ")
ZO_CreateStringId("DsRGuildPvP_ap_battlegroundtxt"           , "Placement: ")
ZO_CreateStringId("DsRGuildPvP_ap_telvarBankuse"             , "Enable TelVar Inventory Balance")
ZO_CreateStringId("DsRGuildPvP_ap_telvarBankuseTP"           , "When checked, balances your TelVar in Inventory when opening Bank")
ZO_CreateStringId("DsRGuildPvP_ap_telvarBankinv"             , "Amount to hold")
ZO_CreateStringId("DsRGuildPvP_ap_telvarBankinvTP"           , "Amount of TelVar to hold when opening Bank")
ZO_CreateStringId("DsRGuildPvP_ap_telvarSaverPort"          , " |c9fb6cd[DsR-Port]|r |c35fc38Porte back to base|r")
ZO_CreateStringId("DsRGuildPvP_ap_telvarSaverPort1"          , " |c9fb6cd[DsR-CyroPort]|r |c35fc38Entered queue|r |c5C6BFF<<1>>|r |c35fc38!|r")
ZO_CreateStringId("DsRGuildPvP_ap_telvarSaverPort2"          , " |c9fb6cd[DsR-CyroPort]|r |c35fc38Entered queue|r |c5C6BFF%s|r |c35fc38!|r")
ZO_CreateStringId("DsRGuildPvP_ap_telvarSaverPortBreak"      , " |c9fb6cd[DsR-CyroPort]|r |cff0000You are not in the|r |c5C6BFFPvP-Area|r |cff0000!!!|r")
ZO_CreateStringId("DsRGuildPvP_ap_telvarSaverPortMesHead"    , zo_iconFormat(DsRIcon, 34, 34) .. "|c9fb6cdTelVar Saver|r" .. zo_iconFormat(DsRIcon, 34, 34))
ZO_CreateStringId("DsRGuildPvP_ap_telvarSaverPortMesQuest"   , "Port group to Cyro?")
ZO_CreateStringId("DsRGuildPvP_ap_telvarSaverKeybindmsg"     , "Autom. Port to Cyrodiil")
ZO_CreateStringId("DsRGuildPvP_KillingBlowmsgA"              , "Killing Blow on ")
ZO_CreateStringId("DsRGuildPvP_VictimEmperor"                , "You killed the emperor <<1>>")
ZO_CreateStringId("DsRGuildPvP_KillingBlowmsgB"              , " with ")
ZO_CreateStringId("DsRGuildPvP_KillingChat"                  , "Assist: ")
ZO_CreateStringId("DsRGuildPvP_KillingDeath"                 , "Death: ")
ZO_CreateStringId("DsRGuildPvP_KillingBlow"                  , "Killz: ")
ZO_CreateStringId("DsRGuildPvP_KillingAP"                    , "AP: ")
ZO_CreateStringId("DsRGuildPvP_KillingTV"                    , "TV: ")
ZO_CreateStringId("DsRGuildPvP_qstate_QUEUEING"              , "|c35fc38Queueing for |c5C6BFF%s|r")
ZO_CreateStringId("DsRGuildPvP_qstate_ENTERING"              , "|c35fc38Entering |c5C6BFF%s|r")
ZO_CreateStringId("DsRGuildPvP_qstate_LEAVING"               , "|c35fc38Leaving queue for |c5C6BFF%s|r")
ZO_CreateStringId("DsRGuildPvP_qstate_CONFIRMING"            , "|c35fc38Confirming queue for |c5C6BFF%s|r")
ZO_CreateStringId("DsRGuildPvP_qstate_WAITING"               , "|c35fc38In queue for |c5C6BFF%s|r")
ZO_CreateStringId("DsRGuildPvP_qstate_FINISHED"              , "|c35fc38Finished queue for |c5C6BFF%s|r")
ZO_CreateStringId("DsRGuildPvP_qstate_UNKNOWN"               , "|c35fc38Unknown queue state for |c5C6BFF%s|r")
ZO_CreateStringId("DsRGuildPvP_qstate_UNKNOWN_Q"             , "Unknown queue")
ZO_CreateStringId("DsRGuildPvP_qstate_Q_NUMBER"              , "Number %d ")
ZO_CreateStringId("DsRGuildPvP_qstate_Q_TIME"                , "Time in queue: %s")
ZO_CreateStringId("DsRGuildPvP_VolendrungInACT"              , " Volendrung inactive")
ZO_CreateStringId("DsRGuildPvP_VolendrungACT"                , " Volendrung active, not revealed!")
ZO_CreateStringId("DsRGuildPvP_VolendrungRELEAVED"           , " Volendrung revealed!")
ZO_CreateStringId("DsRGuildPvP_VolendrungDROPPED"            , " Volendrung dropped!")
ZO_CreateStringId("DsRGuildPvP_GroupInviteZonemsg"           , "Cyro LFM")
ZO_CreateStringId("DsRGuildPvP_telVarSaverNoStoneINV"        , "|cb81414No|r %s |cb81414available in inventory!!!|r")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- PvP - Boss Timer
ZO_CreateStringId("DsRPvPBossTimer_AMONCRUL"	             , "Amoncrul")
ZO_CreateStringId("DsRPvPBossTimer_THIRSK"		             , "Baron Thirsk")
ZO_CreateStringId("DsRPvPBossTimer_GLORGOLOCH"	             , "Glorgoloch the Destroyer")
ZO_CreateStringId("DsRPvPBossTimer_CHARR"		             , "Immolator Charr")
ZO_CreateStringId("DsRPvPBossTimer_KHROGO"		             , "King Khrogo")
ZO_CreateStringId("DsRPvPBossTimer_MALYGDA"		             , "Lady Malygda")
ZO_CreateStringId("DsRPvPBossTimer_MAZALUHAD"	             , "Mazaluhad")
ZO_CreateStringId("DsRPvPBossTimer_NUNATAK"		             , "Nunatak")
ZO_CreateStringId("DsRPvPBossTimer_MATRON"		             , "The Screeching Matron")
ZO_CreateStringId("DsRPvPBossTimer_VOLGHASS"	             , "Volghass")
ZO_CreateStringId("DsRPvPBossTimer_YSENDA"		             , "Ysenda Resplendent")
ZO_CreateStringId("DsRPvPBossTimer_ZOAL"		             , "Zoal the Ever-Wakeful")
ZO_CreateStringId("DsRPvPBossTimer_MOLAG"		             , "Simulacrum of Molag Bal")
ZO_CreateStringId("DsRPvPBossTimer_CAN"						 , "(0) Imperial Sewers")
ZO_CreateStringId("DsRPvPBossTimer_MEMORIALDISTRICT"		 , "(1) Memorial District")
ZO_CreateStringId("DsRPvPBossTimer_ARENADISTRICT"			 , "(2) Arena District")
ZO_CreateStringId("DsRPvPBossTimer_ARBORETUMDISTRICT"		 , "(3) Arboretum District")
ZO_CreateStringId("DsRPvPBossTimer_TEMPLEDISTRICT"			 , "(4) Temple District")
ZO_CreateStringId("DsRPvPBossTimer_NOBLESDISTRICT"			 , "(5) Nobles District")
ZO_CreateStringId("DsRPvPBossTimer_ELVENGARDENSDISTRICT"	 , "(6) Elven Gardens District")
ZO_CreateStringId("DsRPvPBossTimer_SLASHcmd"				 , "Start the district's timer, for example /dsrstart 1")
ZO_CreateStringId("DsRPvPBossTimer_Menue"					 , "Imperial City")
ZO_CreateStringId("DsRPvPBossTimer_GUI_WIDTH"				 , "230")
ZO_CreateStringId("DsRPvPBossTimer_StartManu"           	 , "Start boss timer in the corresponding district")
ZO_CreateStringId("DsRPvPBossTimer_enabled"                  , "Enabled")
ZO_CreateStringId("DsRPvPBossTimer_positionfixed"            , "Position Fixed ")
ZO_CreateStringId("DsRPvPBossTimer_showBGtransparent"        , "Background transparent?")
ZO_CreateStringId("DsRPvPBossTimer_hideworldmap"             , "Hide on World Map")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Beams
ZO_CreateStringId("DsRGuildBeam_LightShowAlertDialog"        , "Lights of Meridia will not function properly with the game's current Video Settings.\n\n Please open |cffff33Settings|r > |cffff33Video|r and set |cffff33SubSampling Quality|r to |c33ffffHIGH|r.\n")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Inventory Manager
ZO_CreateStringId("DsRGuildInventory_HeaderWindow"           , zo_iconFormat(DsRIcon, 36, 36) .. "|c9fb6cdDsR - Inventory Manager|r")
ZO_CreateStringId("DsRGuildInventory_Open"                   , "Toggle Inventory Manager")
ZO_CreateStringId("DsRGuildInventory_OpenGrab"               , "Toggle Inventory Manager (don't grab focus)")
ZO_CreateStringId("DsRGuildInventory_ShowOnlyDupl"           , "Show only duplicates")
ZO_CreateStringId("DsRGuildInventory_ShowOnlyMarked"         , "Show only marked items")
ZO_CreateStringId("DsRGuildInventory_ShowOnlyMarkedTP"       , "Show only items that are stolen, etc.")
ZO_CreateStringId("DsRGuildInventory_RescanCharBank"         , "Rescanning current character and bank")
ZO_CreateStringId("DsRGuildInventory_NeedUpdate"              , "Need update")
ZO_CreateStringId("DsRGuildInventory_NoNeedUpdate"            , "Everything up to date")
ZO_CreateStringId("DsRGuildInventory_LoadingInv"             , "Loading inventories ")
ZO_CreateStringId("DsRGuildInventory_LoadingInvOf"           , "Loading inventory of ")
ZO_CreateStringId("DsRGuildInventory_LoadingInvBank"         , "Loading bank inventory")
ZO_CreateStringId("DsRGuildInventory_LoadingInvHouseChest"   , "Loading house chest inventory of ")
ZO_CreateStringId("DsRGuildInventory_LoadingInvGuildBank"    , "Loading guild bank inventory")
ZO_CreateStringId("DsRGuildInventory_SortingInventory"       , "Sorting inventory")
ZO_CreateStringId("DsRGuildInventory_WornSet"                , " (worn)")
ZO_CreateStringId("DsRGuildInventory_InvBank"                , "Bank")
ZO_CreateStringId("DsRGuildInventory_InvGuildBank"           , "Guild Bank")
ZO_CreateStringId("DsRGuildInventory_InvSetItems"            , "%d sets (%d items) , %d items")
ZO_CreateStringId("DsRGuildInventory_InvSetOfItems"          , "%d of %d sets, %d of %d set items")
ZO_CreateStringId("DsRGuildInventory_InvItems"               , "%s (%d items)")
ZO_CreateStringId("DsRGuildInventory_InvOfItems"             , "%s (%d of %d items)")
ZO_CreateStringId("DsRGuildInventory_ItemLock"               , "Lock")
ZO_CreateStringId("DsRGuildInventory_ItemUnLock"             , "Unlock")
ZO_CreateStringId("DsRGuildInventory_ItemLockQueued"         , "Lock (queued)")
ZO_CreateStringId("DsRGuildInventory_ItemLockQueuedCan"      , "Cancel lock (queued)")
ZO_CreateStringId("DsRGuildInventory_ItemUnLockQueued"       , "Unlock (queued)")
ZO_CreateStringId("DsRGuildInventory_ItemUnLockQueuedCan"    , "Cancel unlock (queued)")
ZO_CreateStringId("DsRGuildInventory_LinkInChat"             , "Link in Chat")
ZO_CreateStringId("DsRGuildInventory_ShowOnlyLoots"          , "Show only loots")
ZO_CreateStringId("DsRGuildInventory_ShowCraftedSets"        , "Show crafted sets")
ZO_CreateStringId("DsRGuildInventory_ShowTradeableSets"      , "Show tradeable sets")
ZO_CreateStringId("DsRGuildInventory_ShowBoundSets"          , "Show bound sets")
ZO_CreateStringId("DsRGuildInventory_ShowMonsterSets"        , "Show monster sets")
ZO_CreateStringId("DsRGuildInventory_ShowOtherItems"         , "Show other items")
ZO_CreateStringId("DsRGuildInventory_ShowOnlyCP160"          , "Show only CP160 items")
ZO_CreateStringId("DsRGuildInventory_ShowOnlyNonCP160"       , "Show only non CP160 items")
ZO_CreateStringId("DsRGuildInventory_ResetFilters"           , "|u16:0:: Reset filters|u")
ZO_CreateStringId("DsRGuildInventory_InvOpenSettings"        , "|u16:0:: Settings|u")
ZO_CreateStringId("DsRGuildInventory_InvRescan"              , "|u16:0:: Rescan|u")
ZO_CreateStringId("DsRGuildInventory_Health"                 , "Health")
ZO_CreateStringId("DsRGuildInventory_Magicka"                , "Magicka")
ZO_CreateStringId("DsRGuildInventory_Stamina"                , "Stamina")
ZO_CreateStringId("DsRGuildInventory_PrismaticDef"           , "Prismatic")
ZO_CreateStringId("DsRGuildInventory_AbsorbHealth"           , "Absorb Health")
ZO_CreateStringId("DsRGuildInventory_AbsorbMagicka"          , "Absorb Magicka")
ZO_CreateStringId("DsRGuildInventory_AbsorbStamina"          , "Absorb Stamina")
ZO_CreateStringId("DsRGuildInventory_Crushing"               , "Crushing")
ZO_CreateStringId("DsRGuildInventory_Oblivion"               , "Oblivion")
ZO_CreateStringId("DsRGuildInventory_Flame"                  , "Flame")
ZO_CreateStringId("DsRGuildInventory_Disease"                , "Disease")
ZO_CreateStringId("DsRGuildInventory_Frost"                  , "Frost")
ZO_CreateStringId("DsRGuildInventory_Hardening"              , "Hardening")
ZO_CreateStringId("DsRGuildInventory_Poison"                 , "Poison")
ZO_CreateStringId("DsRGuildInventory_PrismaticWeapon"        , "Prismatic")
ZO_CreateStringId("DsRGuildInventory_Shock"                  , "Shock")
ZO_CreateStringId("DsRGuildInventory_Weakening"              , "Weakening")
ZO_CreateStringId("DsRGuildInventory_WeaponDamage"           , "Weapon Damage")
ZO_CreateStringId("DsRGuildInventory_Bashing"                , "Bashing")
ZO_CreateStringId("DsRGuildInventory_DecreasePhysicalHarm"   , "Decrease Physical Harm")
ZO_CreateStringId("DsRGuildInventory_DecreaseSpellHarm"      , "Decrease Spell Harm")
ZO_CreateStringId("DsRGuildInventory_DiseaseResist"          , "Disease Resist")
ZO_CreateStringId("DsRGuildInventory_FlameResist"            , "Flame Resist")
ZO_CreateStringId("DsRGuildInventory_FrostResist"            , "Frost Resist")
ZO_CreateStringId("DsRGuildInventory_HealthRecovery"         , "Health Recovery")
ZO_CreateStringId("DsRGuildInventory_SpellDamage"            , "Spell Damage")
ZO_CreateStringId("DsRGuildInventory_WeaponDamage"           , "Weapon Damage")
ZO_CreateStringId("DsRGuildInventory_MagickaRecovery"        , "Magicka Recovery")
ZO_CreateStringId("DsRGuildInventory_PoisonResist"           , "Poison Resist")
ZO_CreateStringId("DsRGuildInventory_PotionBoost"            , "Potion Boost")
ZO_CreateStringId("DsRGuildInventory_PotionSpeed"            , "Potion Speed")
ZO_CreateStringId("DsRGuildInventory_ReduceStaminaCost"      , "Reduce Stamina Cost")
ZO_CreateStringId("DsRGuildInventory_ReduceSpellCost"        , "Reduce Spell Cost")
ZO_CreateStringId("DsRGuildInventory_ReduceBashCost"         , "Reduce Bash Cost")
ZO_CreateStringId("DsRGuildInventory_ShockResist"            , "Shock Resist")
ZO_CreateStringId("DsRGuildInventory_StaminaRecovery"        , "Stamina Recovery")
ZO_CreateStringId("DsRGuildInventory_ReduceSkillCost"        , "Reduce Skill Cost")
ZO_CreateStringId("DsRGuildInventory_PrismaticRecovery"      , "Prismatic")
ZO_CreateStringId("DsRGuildInventory_ChatLock"               , "-> locked")
ZO_CreateStringId("DsRGuildInventory_ChatUnLock"             , "-> unlocked")
ZO_CreateStringId("DsRGuildInventory_ChatLockQueued"         , "-> queued for locking")
ZO_CreateStringId("DsRGuildInventory_ChatLockQueuedREM"      , "-> removed from queue")
ZO_CreateStringId("DsRGuildInventory_ChatUnLockQueued"       , "-> queued for unlocking")
ZO_CreateStringId("DsRGuildInventory_FilterChest"            , "ACE-|c9fb6cd-- Chest --|r")
ZO_CreateStringId("DsRGuildInventory_FilterChar"             , "ACA-|c9fb6cd-- Character --|r")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Achievement Tracker
ZO_CreateStringId("DsRGuildAchievTracker_SubMenu"            , "Achievement Tracker")
ZO_CreateStringId("DsRGuildAchievTracker_hideCompleted"      , "Remove completed")
ZO_CreateStringId("DsRGuildAchievTracker_hideCompletedTP"    , "Automatically removes achievements from tracking after they are completed.")
ZO_CreateStringId("DsRGuildAchievTracker_bgAlpha"            , "Strength of the background")
ZO_CreateStringId("DsRGuildAchievTracker_bgAlphaTP"          , "Adjust the alpha value of the background.\n0 = deactivated")
ZO_CreateStringId("DsRGuildAchievTracker_reset"              , "Untrack all")
ZO_CreateStringId("DsRGuildAchievTracker_resetTP"            , "Untracks all tracked achievements")
ZO_CreateStringId("DsRGuildAchievTrackerFav_Fav"             , "|c9fb6cdDsR-Tracker|r")
ZO_CreateStringId("DsRGuildAchievTrackerFav_FavADD"          , "Track achievement")
ZO_CreateStringId("DsRGuildAchievTrackerFav_FavREM"          , "Remove tracking")
ZO_CreateStringId("DsRGuildAchievTrackerFav_FavGoTo"         , "Goto Achievement")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Crafting
ZO_CreateStringId("DsRGuildCrafting_SubMenu"                 , "Crafting")
ZO_CreateStringId("DsRGuildCrafting_PrecraftNoProfessions"   , " |c9fb6cd[DsR-Precrafter]|r |cEE0000There are no professions activated in the settings! Nothing has been put into the queue.|r")
ZO_CreateStringId("DsRGuildCrafting_PrecraftNoInvSpace"      , " |c9fb6cd[DsR-Precrafter]|r |cEE0000Not enough inventory space available|r")
ZO_CreateStringId("DsRGuildCrafting_PrecraftNoZero"          , " |c9fb6cd[DsR-Precrafter]|r |cEE0000The queue has been cleared. Precrafter deactivated!|r")
ZO_CreateStringId("DsRGuildCrafting_PrecraftOneRot"          , " |c00ff00dailys|r")
ZO_CreateStringId("DsRGuildCrafting_PrecraftQueue"           , "|c00ff00Production for |r")
ZO_CreateStringId("DsRGuildCrafting_PrecraftItems"           , " Items")
ZO_CreateStringId("DsRGuildCrafting_PrecraftFinish"          , " finished")
ZO_CreateStringId("DsRGuildCrafting_PrecraftMats"            , "Not enough mats!")
ZO_CreateStringId("DsRGuildCrafting_PrecraftCMDadd"          , "Add x-rotation(s) to the queue. 0=Clear")
ZO_CreateStringId("DsRGuildCrafting_PrecraftCMDrem"          , "Remove everything from the queue")
ZO_CreateStringId("DsRGuildCrafting_AlchemyFinish"           , "Daily " .. zo_iconFormat("/esoui/art/icons/skilllinexp_alchemy.dds", 20, 20) .. " |c42ffa1Alchemie|r finished")
ZO_CreateStringId("DsRGuildCrafting_ProvisionFinish"         , "Daily " .. zo_iconFormat("/esoui/art/icons/skilllinexp_provisioner.dds", 20, 20) .. " |c42ffa1Provision|r finished")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Death Table
ZO_CreateStringId("DsRGuildDeathTable_Window"                , "Death list")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- CrownList
ZO_CreateStringId("DsRGuildMenue_cyrodiilCrownListHead"      , "|c00CDCDDistance Lead|r")


-------------------------------------------------------------------------------------------------------------------------------------------------
-- TradingPrice
ZO_CreateStringId("DsRGuildPrice_Loaded"                     , "loaded")
ZO_CreateStringId("DsRGuildPrice_NoPriceData"                , "Price to chat -> No price")
ZO_CreateStringId("DsRGuildPrice_NoPriceDataChat"            , "No price for ")
ZO_CreateStringId("DsRGuildPrice_PriceToChat"                , " to chat -> ")
ZO_CreateStringId("DsRGuildPrice_AVGPriceToChat"             , "AVG price ")
ZO_CreateStringId("DsRGuildPrice_AVGPrice"                   , "AVG price")
ZO_CreateStringId("DsRGuildPrice_GoldFor"                    , " gold for ")
ZO_CreateStringId("DsRGuildPrice_For"                        , " for ")
ZO_CreateStringId("DsRGuildPrice_detailed"                   , " (Detailed)")
ZO_CreateStringId("DsRGuildPrice_Sale"                       , "sales")
ZO_CreateStringId("DsRGuildPrice_WritVouchers"               , "writ vouchers")
ZO_CreateStringId("DsRGuildPrice_items"                      , "items")
ZO_CreateStringId("DsRGuildPrice_TTCnotavailable"            , "TTC not available!")
ZO_CreateStringId("DsRGuildPrice_MMnotavailable"             , "MM not available!")
ZO_CreateStringId("DsRGuildPrice_ATTnotavailable"            , "ATT not available!")
ZO_CreateStringId("DsRGuildPrice_SPACE"                      , "SPACE")
ZO_CreateStringId("DsRGuildPrice_EMPTY"                      , "EMPTY")
ZO_CreateStringId("DsRGuildPrice_Defaultprice"               , "Default price ")
ZO_CreateStringId("DsRGuildPrice_Profitprice"                , "Profit price ")
ZO_CreateStringId("DsRGuildPrice_TTCprice"                   , "TTC price ")
ZO_CreateStringId("DsRGuildPrice_MMprice"                    , "MM price ")
ZO_CreateStringId("DsRGuildPrice_ATTprice"                   , "ATT price ")
ZO_CreateStringId("DsRGuildPrice_Tradeprice"                 , "Trade price ")
ZO_CreateStringId("DsRGuildPrice_Averageprice"               , "Average price ")
ZO_CreateStringId("DsRGuildPrice_Bestprice"                  , "Best price ")
ZO_CreateStringId("DsRGuildPrice_DisableStartupLog"          , "Remove Startup messages")
ZO_CreateStringId("DsRGuildPrice_DisableStartupLogTP"        , "Removes messages on Startup, except '|c9fb6cd[DsR-Price]|r Initialized'")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Personal
ZO_CreateStringId("DsRGuildPersonal_GeneralZERO"              , "0 disables the option")
ZO_CreateStringId("DsRGuildPersonal_GeneralNothing"           , "Do Nothing")
ZO_CreateStringId("DsRGuildPersonal_GeneralDepoBank"          , "Deposit to Bank")
ZO_CreateStringId("DsRGuildPersonal_GeneralWithBank"          , "Withdraw to Backpack")
ZO_CreateStringId("DsRGuildPersonal_Deposit"                  , "|c35fc38stored|r")
ZO_CreateStringId("DsRGuildPersonal_DepositMenu"              , " |c3b3b3b(only store)|r")
ZO_CreateStringId("DsRGuildPersonal_Withdraw"                 , "|cFAA0A0taken|r")
ZO_CreateStringId("DsRGuildPersonal_MenueLoading"             , "|cFF0000!!!ATTENTION!!!\n\nThe FCOIS settings menu is currently being build. Please wait and do not change any settings until this icon vanished!\n\nESO could be laggy for a few seconds.\nAs soon as all settings are build this icon will vanish and you can start to change the settings.")
ZO_CreateStringId("DsRGuildPersonal_MenueBanking"             , " |cff9029Banking|r")
ZO_CreateStringId("DsRGuildPersonal_MenueBankingAvA"          , " - siege weapons")
ZO_CreateStringId("DsRGuildPersonal_MenueAvAShopping"         , " |c7393B3Siege master|r")
ZO_CreateStringId("DsRGuildPersonal_MenueJunk"                , " |c7393B3Junk / Deconstruct|r")
ZO_CreateStringId("DsRGuildPersonal_BankingDepositTransaction", "|cA52A2A<<2>>x|r <<t:1>> |c35fc38stored|r")
ZO_CreateStringId("DsRGuildPersonal_BankingWithdrawTransaction", "|cA52A2A<<2>>x|r <<t:1>> |cFAA0A0taken|r")
ZO_CreateStringId("DsRGuildPersonal_CurrencyRecipe"           , "|c7393B3recipes / instructions etc|r")
ZO_CreateStringId("DsRGuildPersonal_CurrencyCyro"             , "|c7393B3Cyrodiil|r")
ZO_CreateStringId("DsRGuildPersonal_CurrencyTP"               , "Clear the field to disable it")
ZO_CreateStringId("DsRGuildPersonal_SoulGemEmpty"             , zo_iconFormat(GetItemLinkIcon("|H0:item:33265:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 26, 26) .. LocalizeString("<<1>>", "|H0:item:33265:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"))
ZO_CreateStringId("DsRGuildPersonal_SoulGem"                  , zo_iconFormat(GetItemLinkIcon("|H0:item:33271:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 26, 26) .. LocalizeString("<<1>>", "|H0:item:33271:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"))
ZO_CreateStringId("DsRGuildPersonal_Glyphe"                   , "Glyphe")
ZO_CreateStringId("DsRGuildPersonal_Jewelry"                  , "Jewelry")
ZO_CreateStringId("DsRGuildPersonal_AvAShopTP"                , "The value '0' deactivates trading")
ZO_CreateStringId("DsRGuildPersonal_AvAShopBought"            , "|c35fc38Bought|r <<1>> x <<2>> for <<3>>")
ZO_CreateStringId("DsRGuildPersonal_AvAShopMissing"           , "|cEE0000Couldn't buy|r <<1>>x <<2>> for <<3>> (<<4>> missing)")
ZO_CreateStringId("DsRGuildPersonal_JunkSellFinish"           , "|c00ff00Junk sold for:|r <<1>>")
ZO_CreateStringId("DsRGuildPersonal_JunkManuSetPermJunk"      , "Mark as perm. Junk")
ZO_CreateStringId("DsRGuildPersonal_JunkManuRemPermJunk"      , "Unmark as perm. Junk")
ZO_CreateStringId("DsRGuildPersonal_JunkManuClearPermJunk"    , "Remove from junk list")
ZO_CreateStringId("DsRGuildPersonal_DeconstructAlways"        , " always")
ZO_CreateStringId("DsRGuildPersonal_DeconstructMythic"        , " [Mythic] items")
ZO_CreateStringId("DsRGuildPersonal_DeconstructFinish"        , " |cFF0000<<1>>|r |c00ff00items recycled|r")
ZO_CreateStringId("DsRGuildPersonal_DeconstructFinishOne"     , " |cFF0000<<1>>|r |c00ff00item recycled|r")
ZO_CreateStringId("DsRGuildPersonal_DeconstructAbort"         , " |cFAA0A0Auto deconstruct was blocked because you have an ongoing crafting quest|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeMenu"              , " |c7393B3Feeling of hunger|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeFoodend"           , "|cFF0000"  .. zo_iconFormat("/esoui/art/icons/justice_stolen_food_001.dds", 38, 38) .. " No buff-food active, grab something for yourself!|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeFoodendSec"        , "|cFF0000Will expire in|r |cFFFF00<<1[$d seconds/$d second/$d seconds]>>|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeFoodendMin"        , "|cFF0000Will expire in|r |cFFFF00<<1[$d minutes/$d minute/$d minutes]>>|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeXPend"             , zo_iconFormat("/esoui/art/icons/crowncrate_experiencescroll_002.dds", 38, 38) .. "|cFF0000 No " .. zo_iconFormat("/DsRGuildHall/misc/DsR_XP.dds", 40, 40) .. "-Buff activated|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeXPendSec"          , "|cFF0000" .. zo_iconFormat("/DsRGuildHall/misc/DsR_XP.dds", 38, 38) .. "-Buff will expire in|r |cFFFF00<<1[$d seconds/$d second/$d seconds]>>|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeXPendMin"          , "|cFF0000" .. zo_iconFormat("/DsRGuildHall/misc/DsR_XP.dds", 38, 38) .. "-Buff will expire in|r |cFFFF00<<1[$d minutes/$d minute/$d minutes]>>|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeAPend"             , zo_iconFormat("/esoui/art/icons/ava_skill_boost_food_002.dds", 38, 38) .. " |cFF0000No" .. zo_iconFormat("/DsRGuildHall/misc/DsR_AP.dds", 40, 40) .. "-Buff activated|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeAPendSec"          , "|cFF0000" .. zo_iconFormat("/DsRGuildHall/misc/DsR_AP.dds", 38, 38) .. "-Buff will expire in|r |cFFFF00<<1[$d seconds/$d second/$d seconds]>>|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeAPendMin"          , "|cFF0000" .. zo_iconFormat("/DsRGuildHall/misc/DsR_AP.dds", 38, 38) .. "-Buff will expire in|r |cFFFF00<<1[$d minutes/$d minute/$d minutes]>>|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeAutoEatTyp"        , "|cFFD39BYour selected food: |r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeAutoEatXPAP"       , "|cFFD39BYour selected scroll: |r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeAutoEatTypDesc"    , "|cFFAE42To enable auto-eating for this character, open the inventory, right-click on the desired food or drink, and select the „Satisfy Hunger“ option.|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeSetFood"           , "|c35fc38Activate|r this  " .. zo_iconTextFormat("/esoui/art/icons/justice_stolen_food_001.dds", 20, 20, " ") .. "-Food")
ZO_CreateStringId("DsRGuildPersonal_ConsumeRemFood"           , "|cFAA0A0Stop|r this  " .. zo_iconTextFormat("/esoui/art/icons/justice_stolen_food_001.dds", 20, 20, " ") .. "-Food")
ZO_CreateStringId("DsRGuildPersonal_ConsumeSetAP"             , "|c35fc38Activate|r this " .. zo_iconTextFormat("/DsRGuildHall/misc/DsR_AP.dds", 24, 24, " ") .. "-Scroll")
ZO_CreateStringId("DsRGuildPersonal_ConsumeRemAP"             , "|cFAA0A0Stop|r this " .. zo_iconTextFormat("/DsRGuildHall/misc/DsR_AP.dds", 24, 24, " ") .. "-Scroll")
ZO_CreateStringId("DsRGuildPersonal_ConsumeSetXP"             , "|c35fc38Activate|r this " .. zo_iconTextFormat("/DsRGuildHall/misc/DsR_XP.dds", 24, 24, " ") .. "-Scroll")
ZO_CreateStringId("DsRGuildPersonal_ConsumeRemXP"             , "|cFAA0A0Stop|r this " .. zo_iconTextFormat("/DsRGuildHall/misc/DsR_XP.dds", 24, 24, " ") .. "-Scroll")
ZO_CreateStringId("DsRGuildPersonal_ConsumeFailTyp"           , " |cFAA0A0is no drink/food|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeFailXP"            , " |cFAA0A0is not an XP-Scroll|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeFailAP"            , " |cFAA0A0is not an AP-Scroll|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeSetAutoTyp"        , " |c35fc38is autom. consumed|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeSetAutoXPAp"       , " |c35fc38is activated autom.|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeRemAutoTyp"        , " |cFAA0A0autom. consumption stopped|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeRemAutoXPAP"       , " |cFAA0A0autom. activation stopped|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeEating"            , "|c00ff00Hunger satisfied with: |r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeAttention"         , "|cFAA0A0You have <<1[$d/only $d/only $d]>> left in your bag.|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeAttentionA1"       , "|cFAA0A0You have set |r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeAttentionA2"       , "|cFAA0A0 to Consume Automatically, but have 0 in your bag.|r|cFF0000 Automatic consumption has been deactivated!!|r")
ZO_CreateStringId("DsRGuildPersonal_ConsumeButton"            , "Remove")
ZO_CreateStringId("DsRGuildPersonal_RepairMenue"              , " |c7393B3Armor workshop|r")
ZO_CreateStringId("DsRGuildPersonal_RepairGlobalsAll"         , "All")
ZO_CreateStringId("DsRGuildPersonal_RepairGlobalsWorn"        , "Worn")
ZO_CreateStringId("DsRGuildPersonal_RepairGlobalsNone"        , "None")
ZO_CreateStringId("DsRGuildPersonal_RepairGlobalAlways"       , "Always")
ZO_CreateStringId("DsRGuildPersonal_RepairGlobalRaiding"      , "Only in Raids")
ZO_CreateStringId("DsRGuildPersonal_RepairGlobalNever"        , "Never")
ZO_CreateStringId("DsRGuildPersonal_RepairRepaired"           , "Repaired ")
ZO_CreateStringId("DsRGuildPersonal_RepairRecharged"          , "Recharged ")
ZO_CreateStringId("DsRGuildPersonal_RepairFor"                , " for: ")
ZO_CreateStringId("DsRGuildPersonal_RepairCannotAfford"       , "Repair not possible from ")
ZO_CreateStringId("DsRGuildPersonal_RepairTotalCost"          , "Total workshop costs: ")
ZO_CreateStringId("DsRGuildPersonal_RepairTotalGearCost"      , "All gear repaired for: ")
ZO_CreateStringId("DsRGuildPersonal_RepairGearCostAfford"     , "Cannot afford repair cost of: ")
ZO_CreateStringId("DsRGuildPersonal_SurveyUnkown"             , " |c3b3b3b(incl. Unidentified)|r")
ZO_CreateStringId("DsRGuildPersonal_MasterUnkown"             , " |c3b3b3b(incl. Unknown)|r")
ZO_CreateStringId("DsRGuildPersonal_TreasureUnkown"           , " |c3b3b3b(incl. Unopened)|r")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- MainMenue Window
ZO_CreateStringId("DsRGuildcmd_MainButtonWindow"              , "Junklist")
ZO_CreateStringId("DsRGuildMainWindow_Header"                 , zo_iconFormat(DsRIcon, 36, 36) .. "|c9fb6cdDsR - personal junklist|r" .. zo_iconFormat(DsRIcon, 36, 36))
ZO_CreateStringId("DsRGuildcmd_MainListEmpty"                 , "Junklist is empty")
ZO_CreateStringId("DsRGuildcmd_MainListTRUE"                  , "Always")
ZO_CreateStringId("DsRGuildcmd_MainListFALSE"                 , "Never")
ZO_CreateStringId("DsRGuildcmd_MainListALL"                   , "All")
ZO_CreateStringId("DsRGuildcmd_MainListCLOSE"                 , "Close")
ZO_CreateStringId("DsRGuildcmd_MainListDESC"                  , "|cFFFF00*|r |c9fb6cdis already regulated via the settings (if set)|r")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Unknown Tracker
ZO_CreateStringId("DsRGuildUnknown_MenuLeft"                  , "Left")
ZO_CreateStringId("DsRGuildUnknown_MenuRight"                 , "Right")
ZO_CreateStringId("DsRGuildUnknown_MenuCorner"                , "Iconcorner")
ZO_CreateStringId("DsRGuildUnknown_MenuLearning"              , "Learning")
ZO_CreateStringId("DsRGuildUnknown_MenuLearningNot"           , "Not Learning")
ZO_CreateStringId("DsRGuildUnknown_MenuLearningAll"           , "Learning on All Accounts")
ZO_CreateStringId("DsRGuildUnknown_SelectIcon1"               , "Hook")
ZO_CreateStringId("DsRGuildUnknown_SelectIcon2"               , "Letter 1")
ZO_CreateStringId("DsRGuildUnknown_SelectIcon3"               , "Letter 2")
ZO_CreateStringId("DsRGuildUnknown_SelectIcon4"               , "Attention")
ZO_CreateStringId("DsRGuildUnknown_SelectIcon5"               , "Info")
ZO_CreateStringId("DsRGuildUnknown_SelectIcon6"               , "Book")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Auto Welcome
ZO_CreateStringId("DsRGuildUnknown_WelcomeOnOff"              , "Enable welcome message for this guild")

-------------------------------------------------------------------------------------------------------------------------------------------------
-- NEW MENU
DsR.Localization.en = {
        --Warnings
        ReloadUiWarn  = "|ceab676The result of changes from this option will be visible after the interface is reloaded.|r",
        ReloadUiWarn1 = "|ceab676This option needs to reload UI|r",
        ReloadUiWarn2 = "|ceab676En-/Disabling this option will immediately reload UI|r",

        --IndexMenu
        IndexMisc                = "General",
        IndexLootManager         = "Lootmanager",
        IndexStickerbook         = "Stickerbook",
        IndexAllianceWarGeneral  = "Alliance war - general",
        IndexAllianceWarCyrodiil = "Alliance war - Cyrodiil",
        IndexAllianceWarImpCity  = "Alliance war - ImperialCity",
        IndexGroupRaid           = "Group & Raids - general",
        IndexGroupBuff           = "Group & Raids - buffs",
        IndexAchievTrack         = "Achievement Tracker",
        IndexCrafting            = "Crafting",
        IndexBeams               = "Light of Togetherness",
        IndexInventoryManager    = "Inventory Manager",
        IndexTradingPrice        = "Trading price",
        IndexTrackerGeneral      = "Unknown Tracker",
        IndexPersonalAssBank     = "Banking",
        IndexPersonalAssBankAvA  = "Banking AvA",
        IndexPersonalAssJunk     = "Junk / Deconstruct",
        IndexPersonalAssConsumer = "Feeling of hunger",
        IndexPersonalAssRepair   = "Armor workshop",
        IndexPersonalAssAvAshop  = "Siege master",
        IndexBarMenu             = "RavenBar",

        --Options - 'IndexMisc'
        DsRGuild_donationTxt1         =  "|c80dfffI would be happy about a " .. zo_iconFormat("/esoui/art/currency/currency_gold.dds", 16, 16) .. "-donation for me and the guild 'Die sieben Raben' :-)|r |c8b6914(Click on 'Donate' at the top right)",
        DsRGuildMenue_accsettings     = "|cFFAE42All settings apply account-wide!|r",
        DsRGuildMenue_UpdateNews      = "|c35fc38Show addon-update news?|r",
        DsRGuildMenue_UpdateNewsDesc  = "Should a pop-up window be displayed when logging in for the first time with the changes after updating the add-on?",
        
            -- Submenu - chatcommands
            DsRGuildMenue_chatcommands           = "Chatcommands",
            DsRGuildMenue_accKeybindAddonUpdate  = "|cFFAE42/dsraddonupdate|r = Open the Popup-Window 'Addon-Update News'",
            DsRGuildMenue_accKeybind             = "|cFFAE42/dsr|r = Open the settings over the chat",
            DsRGuildBind_slashdsrim              = "|cFFAE42/dsrinventory|r = Open the DsR InventoryManager",
            DsRGuildBind_slashDESC1              = "|cFFAE42/dsrbind|r = Bind all set items",
            DsRGuildBind_slashDESC2              = "|cFFAE42/dsrpost|r = Post all set items that you already know in the chat",
            DsRGuildBind_slashDESC3              = "|cFFAE42/dsrstart  [Multipler]|r = Start the district's timer, for example /dsrstart 1",
            DsRGuildPvP_ap_telvarSaverKeybind    = "|cFFAE42/dsrport|r = omatically into an empty cryo campaign",
                        
            -- Submenu - Developer
            DsRGuildMenue_Developer              = "Developer-Modus",
            DsRGuildMenue_DeveloperDesc          = "Activated in the inventory, bank etc. in the context menu (right mouse button) options for developers",
            DsRGuildMenue_DeveloperAct           = "Enable developer mode",
            DsRGuildMenue_DeveloperID            = "ID",
            DsRGuildMenue_DeveloperICON          = "ICON",
            DsRGuildMenue_DeveloperLINK          = "LINK",
            DsRGuildMenue_DeveloperTYPE          = "TYPE",
            DsRGuildMenue_DeveloperTRAIT         = "TRAIT",
            DsRGuildMenue_DeveloperShowAll       = "Show all",

            -- Submenu - DsRinternalInfosS
            DsRGuildMenue_DsRinternalInfos  = "Guildinternal |cb81414(only DsR-Guild)|r",
            DsRGuildMenue_DsRInfoHome       = "|cFFAE42Im Gildenhauptfenster werden die Informationen immer dargestellt!|r",
            DsRGuildMenue_DsRInfoRoster     = "Reiter 'Mitglieder'",
            DsRGuildMenue_DsRInfoRank       = "Reiter 'Ränge'",
            DsRGuildMenue_DsRInfoRecrut     = "Reiter 'Rekrutierung'",
            DsRGuildMenue_DsRInfoMasterJoint = "Rabenwacht",
            DsRGuildMenue_DsRMasterJoint     = zo_iconFormat("/esoui/art/chatwindow/chat_notification_up.dds", 26, 26) .. "Chatnachricht wenn " .. zo_iconFormat("/DsRGuildHall/misc/DsR_Rabenwacht.dds", 26, 26) .. "Rabenwacht joint?",
            DsRGuildMenue_DsRMasterJoinSound = zo_iconFormat("/esoui/art/chatwindow/chat_notification_up.dds", 26, 26) .. "Sound abspielen wenn " .. zo_iconFormat("/DsRGuildHall/misc/DsR_Rabenwacht.dds", 26, 26) .. "Rabenwacht joint?",

            -- Submenu - Take 1
            DsRGuildMenue_DsRTakeOneMenue     = zo_iconFormat("/esoui/art/guild/history/gamepad/gp_guildhistory_withdrawitems.dds", 26, 26) .. "|c00CDCDNeed only 1|r",
            DsRGuildMenue_DsRTakeOneOnOff     = "|cFFAE42Activate the option|r",
            DsRGuildMenue_DsRTakeOneOnOffDesc = "If activated, you have the option in the context menu (right mouse button) in the bank etc. to take only 1 item instead of all",
            DsRGuildMenue_DsRTakeOne          = "|c9fb6cd[DsR]|r Take 1",
            DsRGuildMenue_DsRTakeOneBackFull  = "|c9fb6cd[DsR]|r |cFAA0A0You need at least 2 free spaces in your inventory|r",

            -- Submenu - Welcome
            DsRGuildUnknown_WelcomeMain       = zo_iconFormat("/esoui/art/chatwindow/chat_notification_up.dds", 26, 26) .. "|c00CDCDAuto Welcome|r",
            DsRGuildUnknown_WelcomeGenOnOff   = "Enable welcome messages",
            DsRGuildUnknown_WelcomeMemberName = "|cFFAE42%1 = Playername|r",
            DsRGuildUnknown_WelcomeNoGuild    = "|cFAA0A0Join a guild to use this!|r",
            DsRGuildUnknown_WelcomeTXT        = "Text to place in guild chat",
            DsRGuildUnknown_WelcomeAttention  = "|cadff2fThe chat message will only be sent if the new guild member is also ONLINE at that time.|r",
            DsRGuildUnknown_WelcomeAttentionA = "|cadff2fIn addition, the message only appears when you are not in combat.|r",


            -- Submenu - Friends
            DsRGuildMenue_DsRFriendsMenue     = zo_iconFormat("/esoui/art/friends/friends_tabicon_friends.dds", 26, 26) .. "|c00CDCDFriends|r",
            DsRGuildMenue_DsRFriends          = "No Friend status",
            DsRGuildMenue_DsRFriendsDesc      = "Disable friend 'logged on/off' chat messages.",
            DsRGuildMenue_DsRFriendsCOLOR     = "Color-matched notifications",
            DsRGuildMenue_DsRFriendsCOLORDesc = "Only if 'Do not show friend status' is set to |cFF0000OFF|r !!\nReplaces the normal yellow notification with a colorful version.",
            DsRGuildMenue_DsRFriendsLogin     = "Which ACC name should still be displayed (per line: 1 ACC name)",
            DsRGuildMenue_DsRFriendsLoginDesc = "A list in which one friend (Accountname inkl. @) can be entered per line, which will be displayed when logging in/out.\nFor example:\n@Hasenwarrior\n@Hasenwarrior2\n\nPress the ENTER key to start a new line.",

            -- Submenu - GuildChat
            DsRGuildMenue_DsRSTACHATMenue     = zo_iconFormat("/esoui/art/chatwindow/chat_notification_up.dds", 26, 26) .. "|c00CDCDStandardchat|r",
            DsRGuildMenue_DsRSTACHATONOFF     = "Enable standard chat",
            DsRGuildMenue_DsRSTACHATONOFFDesc = "This setting ignores the add-on settings\n|cb81414- pChat\n- rChat\n- AccountSettings|r",
            DsRGuildMenue_DsRSTACHATdropdown  = "Which chat should be set at startup",

        --Options - 'IndexLootManager'
            -- Submenu - Notification Screen
            DsRGuildMenue_notificationscreen     = "Centerscreen",
            DsRGuildLoot_screenloot_deactivate   = "Centerscreen-Loot deactivate",
            DsRGuildLoot_own_loot_quali          = "Show own loot by quality ....",
            DsRGuildMenue_notificationspecial    = "|c00CDCDSpecial loot|r",
            DsRGuildMenue_notificationspecialTxt = "|cFFAE42This is always displayed, even if the main function is deactivated|r",
            DsRGuildLoot_fortified_nirncrux      = zo_iconFormat(GetItemLinkIcon("|H0:item:56863:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22)  .. LocalizeString("<<1>>", "|H0:item:56863:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_potent_nirncrux         = zo_iconFormat(GetItemLinkIcon("|H0:item:56862:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22)  .. LocalizeString("<<1>>", "|H0:item:56862:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_kuta                    = zo_iconFormat(GetItemLinkIcon("|H0:item:45854:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22)  .. LocalizeString("<<1>>", "|H0:item:45854:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_hakeijo                 = zo_iconFormat(GetItemLinkIcon("|H0:item:68342:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22)  .. LocalizeString("<<1>>", "|H0:item:68342:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_LuminousInk             = zo_iconFormat(GetItemLinkIcon("|H0:item:204881:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:204881:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_rubyblossomextract      = zo_iconFormat(GetItemLinkIcon("|H0:item:171328:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:171328:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_mourningdew             = zo_iconFormat(GetItemLinkIcon("|H0:item:171433:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:171433:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_PerfectRoe              = zo_iconFormat(GetItemLinkIcon("|H0:item:64222:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22)  .. LocalizeString("<<1>>", "|H0:item:64222:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_AetherialDust           = zo_iconFormat(GetItemLinkIcon("|H0:item:115026:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:115026:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_AethericCipher          = zo_iconFormat(GetItemLinkIcon("|H0:item:115028:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:115028:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_endeavor                = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_SEALS)) .. "|cA52A2A".. GetCurrencyName(CURT_SEALS, false):gsub("%^.+", "") .. "|r",

            -- Submenu - Notification Chat
            DsRGuildMenue_notificationchat       = "Chat",
            DsRGuildBind_ArmorCollected          = "|cb81414|t30:30:/esoui/art/collections/collections_tabicon_itemsets_down.dds:inheritcolor|t|r" .. "Show only uncollected items.",
            DsRGuildBind_ArmorCollectedDesc      = "Only chat loot from ''armors and weapons'' that are not yet in the sticker book will be displayed.",
            DsRGuildLoot_chatloot_trait          = zo_iconFormat("/esoui/art/inventory/inventory_trait_reconstruct_icon.dds",22 ,22) .. "Show weapon/armor trait",
            DsRGuildLoot_chatloot_deactivate     = "Chat-Loot deactivate",
            DsRGuildLoot_group_loot_deactivate   = "Group-Loot activate",
            DsRGuildLoot_group_loot_quali        = "Show Group-Loot by quality ....",
            DsRGuildLoot_experience_gain         = zo_iconFormat("/DsRGuildHall/misc/DsR_XP.dds",22 ,22) .. "Experience gain",
            DsRGuildLoot_experience_gainTXT      = "Minimum XP gain to display",
            DsRGuildLoot_gold_gain               = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_MONEY)) .. GetCurrencyName(CURT_MONEY, false):gsub("%^.+", ""),
            DsRGuildLoot_gold_gainTXT            = "Minimum gold gain to display",
            DsRGuildLoot_imperial_fragments      = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_IMPERIAL_FRAGMENTS)) .. GetCurrencyName(CURT_IMPERIAL_FRAGMENTS, false):gsub("%^.+", ""),
            DsRGuildMenue_notificationOther      = "|c00CDCDCurrency|r",
            DsRGuildLoot_undauntedkeys           = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_UNDAUNTED_KEYS)) .. GetCurrencyName(CURT_UNDAUNTED_KEYS, false):gsub("%^.+", ""),
            DsRGuildLoot_event_Tickets           = zo_iconFormat("/esoui/art/currency/icon_eventticket_loot.dds",22 ,22) .. "Event tickets ",
            DsRGuildLoot_transmute_crystals      = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_TRANSMUTE_CRYSTALS)) .. GetCurrencyName(CURT_TRANSMUTE_CRYSTALS, false):gsub("%^.+", ""),
            DsRGuildLoot_archival_fortunes       = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_ARCHIVAL_FORTUNES)) .. GetCurrencyName(CURT_ARCHIVAL_FORTUNES, false):gsub("%^.+", ""),
            DsRGuildLoot_completed_Achievements  = zo_iconFormat("/esoui/art/tutorial/journal_tabicon_achievements_up.dds",22 ,22) .. "Completed Achievements",
            DsRGuildLoot_progress_Achievements   = zo_iconFormat("/esoui/art/tutorial/journal_tabicon_achievements_up.dds",22 ,22) .. "FoProgress Achievements",
            DsRGuildLoot_bookloot                = zo_iconFormat("/esoui/art/icons/housing_bre_inc_book_open001.dds",22 ,22) .. "Progress books",
            DsRGuildLoot_experience_skill        = "|c00CDCDSkills|r",
            DsRGuildLoot_experience_A            = "|c00CDCDProgress|r",
            DsRGuildLoot_experience_OnOff        = zo_iconFormat("/DsRGuildHall/misc/DsR_XP.dds",22 ,22) .. "Activate experience gain",
            DsRGuildLoot_exp_WEAPON              = zo_iconFormat("/esoui/art/icons/ability_weapon_016.dds",22 ,22) .. "Weapon",
            DsRGuildLoot_exp_ARMOR               = zo_iconFormat("/esoui/art/icons/passive_armor_012.dds",22 ,22) .. "Armor",
            DsRGuildLoot_exp_GUILD               = zo_iconFormat("/esoui/art/icons/crownstore_skillline_fightersguild.dds",22 ,22) .. "Guilds",
            DsRGuildLoot_exp_AVA                 = zo_iconFormat("/esoui/art/icons/crownstore_skillline_alliancewar_assault.dds",22 ,22) .. "Alliance war",
            DsRGuildLoot_exp_Excavation          = zo_iconFormat("/esoui/art/icons/u26_ability_digging_02.dds",22 ,22) .. "Excavation",
            DsRGuildLoot_exp_Scrying             = zo_iconFormat("/esoui/art/icons/ability_scrying_02.dds",22 ,22) .. "Scrying",
            DsRGuildLoot_exp_Legerdemain         = zo_iconFormat("/esoui/art/icons/skilllinexp_ledgermain.dds",22 ,22) .. "Legerdemain",
            DsRGuildLoot_exp_SoulMagic           = zo_iconFormat("/esoui/art/icons/soulgem_006_filled.dds",22 ,22) .. "Soul Magic",
            DsRGuildLoot_exp_Vampire             = zo_iconFormat("/esoui/art/icons/ability_vampire_007.dds",22 ,22) .. "Vampire",
            DsRGuildLoot_exp_Werewolf            = zo_iconFormat("/esoui/art/icons/ability_werewolf_010.dds",22 ,22) .. "Werewolf",
            DsRGuildLoot_experience_crafting     = "|c00CDCDCrafting|r",
            DsRGuildLoot_exp_alchemy             = zo_iconFormat("/esoui/art/icons/skilllinexp_alchemy.dds",22 ,22) .. "Alchemy",
            DsRGuildLoot_exp_blacksmithing       = zo_iconFormat("/esoui/art/icons/skilllinexp_blacksmithing.dds",22 ,22) .. "Blacksmithing",
            DsRGuildLoot_exp_woodworking         = zo_iconFormat("/esoui/art/icons/skilllinexp_woodworking.dds",22 ,22) .. "Woodworking",
            DsRGuildLoot_exp_clothier            = zo_iconFormat("/esoui/art/icons/skilllinexp_clothier.dds",22 ,22) .. "Clothier",
            DsRGuildLoot_exp_enchanting          = zo_iconFormat("/esoui/art/icons/skilllinexp_enchanting.dds",22 ,22) .. "Enchanting",
            DsRGuildLoot_exp_jewelrymaking       = zo_iconFormat("/esoui/art/icons/skilllinexp_jewelrymaking.dds",22 ,22) .. "Jewelrymaking",
            DsRGuildLoot_exp_provisioner         = zo_iconFormat("/esoui/art/icons/skilllinexp_provisioner.dds",22 ,22) .. "Provision",
            
            -- Submenu - Notification Beuteverlauf
            DsRGuildLootHistory_Menue             = "Loot History",
            DsRGuildLootHistory_MenueOnOff        = "|cFFAE42Disable the customized loot history|r",
            DsRGuildLootHistory_NLootMS           = "Normal loot display duration |c808080(seconds)|r",
            DsRGuildLootHistory_NLootMSDesc       = "Normal loot is any unique loot (ex.: specific item)",
            DsRGuildLootHistory_PLootMS           = "Persistent loot display duration |c808080(seconds)|r",
            DsRGuildLootHistory_PLootMSDesc       = "Persistent loot is a loot that show a cumulative value (ex.: Currency, XP)",
            DsRGuildLootHistory_MaxItem           = "Max simultaneous items shown",
            DsRGuildLootHistory_ShowMenue         = "Show loot history while in menus",
            DsRGuildLootHistory_ShowSkill         = "|cFFAE42Show 'Open World' skills XP|r",

            -- Submenu - Handelswerte - Loot
            DsRGuildMenue_trading       = "|c00CDCDTrading price|r",
            DsRGuildLoot_trade_chat     = "Display in chat",
            DsRGuildLoot_trade_screen   = "Display on screen",
            DsRGuildLoot_trade_history  = "IDisplay in loot history",
            DsRGuildLoot_trade_support1 = "|c7393B3UTo be supported:|r",
            DsRGuildLoot_trade_support2 = "|cadff2fMasterMerchant (MM), Tamriel Trade Centre (TTC) and Arkadius Trade Tool (ATT)|r",

            -- Submenu - Behälter - Loot
            DsRGuildMenue_Container     = "AutoLoot - Bag, Backpack",
            DsRGuildMenue_IC            = "ImperialCity",
            DsRGuildMenue_OW            = "Open World",
            DsRGuildMenue_EA            = "Endless archive",
            DsRGuildLoot_FM             = zo_iconFormat(GetItemLinkIcon("|H0:item:197790:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:197790:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_BGR            = zo_iconFormat(GetItemLinkIcon("|H0:item:188144:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:188144:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_BVS            = zo_iconFormat(GetItemLinkIcon("|H0:item:178470:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:178470:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_hAR            = zo_iconFormat(GetItemLinkIcon("|H0:item:150700:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:150700:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_ICversorger    = zo_iconFormat(GetItemLinkIcon("|H0:item:212238:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:212238:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_ICschmied      = zo_iconFormat(GetItemLinkIcon("|H0:item:212249:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:212249:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_ICschneider    = zo_iconFormat(GetItemLinkIcon("|H0:item:212252:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:212252:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_ICalchemi      = zo_iconFormat(GetItemLinkIcon("|H0:item:212251:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:212251:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_ICrunen        = zo_iconFormat(GetItemLinkIcon("|H0:item:212248:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:212248:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_ICholz         = zo_iconFormat(GetItemLinkIcon("|H0:item:212247:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:212247:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_EAschmuck      = zo_iconFormat(GetItemLinkIcon("|H0:item:203205:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:203205:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_EAversorger    = zo_iconFormat(GetItemLinkIcon("|H0:item:203212:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:203212:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_EAschneider    = zo_iconFormat(GetItemLinkIcon("|H0:item:203200:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:203200:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_EAschmied      = zo_iconFormat(GetItemLinkIcon("|H0:item:203199:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:203199:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_EAalchemi      = zo_iconFormat(GetItemLinkIcon("|H0:item:203181:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:203181:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_EArunen        = zo_iconFormat(GetItemLinkIcon("|H0:item:203201:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:203201:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
            DsRGuildLoot_EAholz         = zo_iconFormat(GetItemLinkIcon("|H0:item:203213:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:203213:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),


        --Options - 'IndexStickerbook'
        DsRGuildBind_autobindloot             = "Automatically bind on pickup?",
        DsRGuildBind_Iconshowin               = "|cFFAE42Where should the icon |r " .. "|cb81414|t30:30:/esoui/art/collections/collections_tabicon_itemsets_down.dds:inheritcolor|t|r" .. " |cFFAE42 be displayed?|r",
        DsRGuildBind_show_bag                 = "Inventory - Bag",
        DsRGuildBind_show_bagDesc             = "Show icon in your character's inventory",
        DsRGuildBind_show_trading             = "Inventory - Trade",
        DsRGuildBind_show_tradingDesc         = "Show icon when trading with other players",
        DsRGuildBind_show_bank                = "Inventory - Bank",
        DsRGuildBind_show_bankDesc            = "Show icon in your personal bank",
        DsRGuildBind_show_housebank           = "Inventory - House Storage",
        DsRGuildBind_show_housebankDesc       = "Show icon in house storage coffers",
        DsRGuildBind_show_guildbank           = "Inventory - Guild Bank",
        DsRGuildBind_show_guildbankDesc       = "Show icon in guild bank",
        DsRGuildBind_show_crafting            = "Inventory - Crafting Station",
        DsRGuildBind_show_craftingDesc        = "Show icon at crafting stations, including the deconstruction assistant",
        DsRGuildBind_show_transmute           = "Inventory - Transmute Station",
        DsRGuildBind_show_transmuteDesc       = "Show icon at transmute stations when retraiting",
        DsRGuildBind_show_guildstore          = "Inventory - Guild Store",
        DsRGuildBind_show_guildstoreDesc      = "Show icon in guild store search list and personal listings",
        DsRGuildBind_chat_SystemShow          = "Chat - System Messages",
        DsRGuildBind_chat_SystemShowDesc      = "Show an icon when a system message contains an item that is not in your set collection",
        DsRGuildBind_chat_MessageShow         = "Chat - Chat Messages",
        DsRGuildBind_chat_MessageShowDesc     = "Show an icon when a player chat message contains an item that is not in your set collection",
        DsRGuildBind_Iconposition             = "|cFFAE42Alignment of the icon in the inventory, etc.|r",
        DsRGuildBind_pos_iconOffset           = "Bag Offset",
        DsRGuildBind_pos_iconOffsetDesc       = "Horizontal offset for the icon in all places except guild store",
        DsRGuildBind_pos_iconStoreOffset      = "Guild Store Offset",
        DsRGuildBind_pos_iconStoreOffsetDesc  = "Horizontal offset for the icon in guild store",
        DsRGuildBind_req_desc                 = "|cFFAE42Provides some tools for easier trading of collectible gear.|r",
        DsRGuildBind_req_showRequestLink      = "Request button",
        DsRGuildBind_req_showRequestLinkDesc  = "Show a [Req] button in front of player-sent messages containing links for uncollected items. Clicking the button will prefill a whisper to that player to request the items",
        DsRGuildBind_req_requestInWhisper     = "Request in whisper",
        DsRGuildBind_req_requestInWhisperDesc = "Use the whisper channel to request items from the player. If turned OFF, the message will be prefilled in the same channel as the original message instead.",
        DsRGuildBind_req_requestPrefix        = "Request button prefix",
        DsRGuildBind_req_requestPrefixDesc    = "The message prefix for requesting items via the [Req] button. Recommended <= 10 character length",

        --Options - 'IndexAllianceWarGeneral'
            -- Submenu - Tötungen
            DsRGuildMenue_PvPandBGkilling    = zo_iconFormat("/esoui/art/deathrecap/deathrecap_killingblow_icon.dds", 28, 28) .. "|c00CDCDKill's|r",
            DsRGuildPvP_PvPKillFeedCyro      = "PvP Kill Feed - Cyrodiil",
            DsRGuildPvP_PvPKillFeedImperial  = "PvP Kill Feed - Imperial City",
            DsRGuildPvP_KillingBlowScreen    = "Show a fatal blow on the screen?",
            DsRGuildPvP_KillingBlowChat      = "Show a fatal blow in the chat?",
            DsRGuildPvP_KillingChatMenue     = "Who else have I killed? (Assist)",
            DsRGuildPvP_KillingChatMenueDesc = "Does it show if you've killed someone without delivering a fatal blow?",
            DsRGuildPvP_EnableAnimation      = "Enable Killing Blow Animation",
            DsRGuildPvP_EnableAnimationDesc  = "Dyes the screen edge in the selected color when your attack was lethal.",
            DsRGuildPvP_ColorAnimation       = "Killing Blow Frame Colour",
            DsRGuildPvP_ColorAnimationDesc   = "Color for Killing Blow Border",

            -- Submenu - Killcounter
            DsRGuildMenue_cyrodiilqueue        = zo_iconFormat("/esoui/art/icons/battleground_medal_killingblow_007.dds", 28, 28) .. "|c00CDCDKill Counter|r",
            DsRGuildMenue_cyrodiilqueueenable  = "Enable Kill Counter?",
            DsRGuildMenue_statsBarLocked       = "Lock Kill Counter location",
            DsRGuildMenue_statsBarLockedDesc   = "When ON you cannot move the Kill Counter. When OFF you can move the Kill Counter anywhere on screen.",
            DsRGuildMenue_hideInPvE            = "Hide Kill Counter when outside PvP zones",
            DsRGuildMenue_hideInPvEDesc        = "When ON the Kill Counter will be hidden whenever you are not in PvP. When OFF the Kill Counter will be visible aslways.",
            DsRGuildMenue_scoreWindowScale     = "Resize the Kill Counter by this percentage:",
            DsRGuildMenue_scoreWindowScaleDesc = "Resize the PVP Kill Counter by the specified percentage",

            -- Submenu - Playercounter
            DsRGuildMenue_cyrodiilCP           = zo_iconFormat("/esoui/art/lfg/lfg_indexicon_group_down.dds", 28, 28) .. "|c00CDCDPlayer Counter|r",
            DsRGuildMenue_cyrodiilCPenable     = "Enable Player Counter?",
            DsRGuildMenue_cyrodiilCPUNK        = "Show unknown player?",
            DsRGuildMenue_cyrodiilCPcompl      = "Show statistics of players already detected",
            DsRGuildMenue_cyrodiilCPenableDesc = "Show you how many players are nearby, whether friend or foe./nIt recognizes all players who: /n - are fighting /n - are using skills /n - are looking at you /n - ...",
            DsRGuildMenue_cyrodiilCPdebug      = "Debug mode?",
            DsRGuildMenue_cyrodiilCPdebugDesc  = "Should be set to OFF!!! For developers only!",

            -- Submenu - Follow the Crown
            DsRGuildMenue_cyrodiilCrown          = zo_iconFormat("/esoui/art/lfg/lfg_leader_icon.dds", 28, 28) .. "|c00CDCDGrouplead|r",
            DsRGuildMenue_cyrodiilCrownPfeil     = "Show me the way to the lead",
            DsRGuildMenue_cyrodiilCrownPfeilSize = "Size",
            DsRGuildMenue_cyrodiilCrownPfeilPos  = "Position of the HUD?",
            DsRGuildMenue_cyrodiilCrownList      = "Show the group's gap to the leader?",
            DsRGuildMenue_cyrodiilCrownPfeilFak  = "Debug: Enable Fake-Crown",

            -- Submenu - Allianzpunkte
            DsRGuildPvP_alliancepointsmsg      = zo_iconFormat("/esoui/art/currency/alliancepoints_64.dds", 28, 28) .. "|c00CDCDAlliancepoint|r",
            DsRGuildPvP_alliancepoints         = zo_iconFormat("/DsRGuildHall/misc/DsR_AP.dds", 26, 26) .. "Show Alliance Points gained",
            DsRGuildPvP_ap_gain                = "Minimum AP gain to display",
            DsRGuildPvP_ap_repair              = zo_iconFormat("/esoui/art/vendor/vendor_tabicon_repair_down.dds", 26, 26) .. "Repair",
            DsRGuildPvP_ap_kills               = zo_iconFormat("/esoui/art/deathrecap/deathrecap_killingblow_icon.dds", 28, 28) .. "Kills",
            DsRGuildPvP_ap_offensechat         = "Offense (Chat)",
            DsRGuildPvP_ap_offensescreen       = "Offense (Centerscreen)",
            DsRGuildPvP_ap_defensechat         = "Defense (Chat)",
            DsRGuildPvP_ap_defensescreen       = "Defense (Centerscreen)",
            DsRGuildPvP_ap_revival             = "Revival",
            DsRGuildPvP_ap_awards              = "Awards / Rank",
            DsRGuildPvP_ap_quest               = zo_iconFormat("/esoui/art/worldmap/map_indexicon_quests_down.dds", 26, 26) .. "Quest",
            DsRGuildPvP_ap_battleground        = zo_iconFormat("/esoui/art/battlegrounds/battlegrounds_tabicon_battlegrounds_down.dds", 26, 26) .. "Placement (Battlegrounds)",

        --Options - 'IndexAllianceWarCyrodiil'
            -- Submenu - Porten
            DsRGuildMenue_cyrodiilPortImp      = zo_iconFormat("/esoui/art/mappins/ava_imperialdistrict_neutral.dds", 28, 28) .. "|c00CDCDImperialCity - Port|r",
            DsRGuildPvP_portImperial           = "Port from Cyrodiil to Imperial City?",
            DsRGuildPvP_portImperialGroup      = "Queue as a group when I have crown?",

            -- Submenu - Burgtore
            DsRGuildMenue_cyrodiildoor              = zo_iconFormat("/DsRGuildHall/misc/DsR_CastleDoor.dds", 28, 28) .. "|c00CDCDKeep door|r",
            DsRGuildMenue_cyrodiildoorOnOff         = "Show keep door?",
            DsRGuildMenue_cyrodiildoorpintint       = "Color",
            DsRGuildMenue_cyrodiildoorpintintDesc   = "The color for the Keep door map pins.",
            DsRGuildMenue_cyrodiildoorpintsize      = "Size",
            DsRGuildMenue_cyrodiildoorpintsizeDesc  = "How large the map pin for Keep doors will be.",
            DsRGuildMenue_cyrodiildoorpintlayer     = "Layer",
            DsRGuildMenue_cyrodiildoorpintlayerDesc = "Pins with higher numbers are drawn on top of pins with lower numbers. Raise the Pin Layer to make it appear over other pin types. Examples: Quests 110, Group Members 130, Wayshrine 140, Player 160",
 
            -- Submenu - Burginfo
            DsRGuildMenue_cyroposition              = zo_iconFormat("esoui/art/mappins/ava_largekeep_neutral.dds", 28, 28) .. "|c00CDCDKeep info|r",
            PvPKeepInfo_enabled                     = "Disable keep information",
            PvPKeepInfo_updatetimer                 = "Updateinterval",
            PvPKeepInfo_updatetimerDesc             = "How often should your position be queried\nDefault: 1 Seconds",
            PvPKeepInfo_showBGtransparent           = "Background transparent?",
           
            -- Submenu - Kampfgeschehen
            DsRGuildMenue_cyrowar                   = zo_iconFormat("/esoui/art/icons/servicemappins/servicepin_fightersguild.dds", 28, 28) .. "|c00CDCDCombat events|r",
            DsRGuildPvPstatus_enabled               = "Enabled",
            DsRGuildPvPstatus_positionfixed         = "Position Fixed" .. zo_iconFormat("/esoui/art/progression/progression_crafting_locked_up.dds", 26, 26),
            DsRGuildPvPstatus_showBGtransparent     = "Background transparent?",
            DsRGuildPvPstatus_hideworldmap          = "Hide on World Map",
            DsRGuildPvPstatus_showflags             = "Show Flags" .. zo_iconFormat("/esoui/art/compass/ava_flagneutral.dds", 26, 26),
            DsRGuildPvPstatus_showsieges            = "Show Sieges" .. zo_iconFormat("/esoui/art/compass/compass_bg_flagattack_pin.dds", 26, 26),
            DsRGuildPvPstatus_showownerchanges      = "Show Keep Flip Timers",
            DsRGuildPvPstatus_showactiontimers      = "Show time to AP points",
            DsRGuildPvPstatus_colordefault          = "Default Color",
            DsRGuildPvPstatus_colorcooldown         = "Cooldown Color",
            DsRGuildPvPstatus_colorflipspositive    = "Positive Flag Flip Color",
            DsRGuildPvPstatus_colorflipsnegative    = "Negative Flag Flip Color",
            DsRGuildPvPstatus_showkeeps             = zo_iconFormat("/esoui/art/compass/ava_largekeep_neutral.dds", 26, 26) .. "Show Keeps",
            DsRGuildPvPstatus_showoutposts          = zo_iconFormat("/esoui/art/compass/ava_outpost_neutral.dds", 26, 26) .. "Show Outposts",
            DsRGuildPvPstatus_showresources         = zo_iconFormat("/esoui/art/mappins/ava_lumbermill_neutral.dds", 28, 28) .. "Show Resources",
            DsRGuildPvPstatus_showvillages          = zo_iconFormat("/esoui/art/compass/ava_town_neutral.dds", 26, 26) .. "Show Towns",
            DsRGuildPvPstatus_showtemples           = zo_iconFormat("/esoui/art/compass/ava_artifacttemple_ebonheart.dds", 26, 26) .. "Show Temples",
            DsRGuildPvPstatus_showdestructibles     = zo_iconFormat("/esoui/art/mappins/ava_milegate_passable.dds", 28, 28) .. "Show Destructibles",

        --Options - 'IndexAllianceWarImpCity'
        DsRGuildMenue_ImperialCityDistrict     = "|cFFAE42Enable sewer entrances / district names labels?|r",
        DsRGuildMenue_ImperialCityDistrictDesc = "Toggle if sewer entrances are labeled on the Imperial City map.",
        DsRGuildMenue_ImperialCitySewers       = "|cFFAE42Show district names on leaders?|r",
        
            -- Submenu - Telvar Steine
            DsRGuildPvP_ap_telvarmsg            = zo_iconFormat("/esoui/art/hud/telvar_meter_currency.dds", 28, 28) .. "|c00CDCDTelvar stones|r",
            DsRGuildPvP_ap_telvar               = "Show Telvar stones?",
            DsRGuildPvP_ap_telvartxt            = "At what value should I show it to you?",
            DsRGuildPvP_ap_telvarSaver          = "Auto-queue to Cyrodiil when my Telvar exceeds:",
            DsRGuildPvP_ap_telvarSaverDesc      = "You will be auto-queued to your home Cyrodill campaign or a random Cyrodill campaign when you are in Imperial City and every time you gain enough Telvar stones to exceed the specified amount. To turn this OFF, set the number to 0",
            DsRGuildPvP_ap_telvarSaverGroup     = "Queue as a group when I have crown?",
            DsRGuildPvP_ap_telvarSaverGroupDesc = "You will auto-queue your entire group when you are the group leader.",
            DsRGuildPvP_telVarSaverU49          = "|cadff2fPorting to the main base to secure the TelVar stones is possible via /dsrport or a key.|r",
            DsRGuildPvP_telVarSaverU49a         = "|cb81414ATTENTION!!|r |H0:item:68347:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h |cb81414is required|r",
            
            -- Submenu - Bosstimer
            DsRPvPBossTimer_BossTimerMenue       = zo_iconFormat("/esoui/art/miscellaneous/timer_32.dds", 28, 28) .. "|c00CDCDStatus & Bosstimer|r",
            DsRPvPBossTimer_OPTION_TIMETABLE     = "Show status & spawntimes",
            DsRPvPBossTimer_OPTION_MAPTIMERS     = "  - Spawntimes on IC map",
            DsRPvPBossTimer_OPTION_MAPTIMERSDesc = "This will disable zoom on Imperial City map.\nDoes not work with Gamepad-Mode!",
            DsRPvPBossTimer_OPTION_EVENT_TIMERS  = "Event timers (7 minutes)",

            DsRGuildPvP_GoldScamp                = zo_iconFormat("DsRGuildHall/misc/DsR_Scamp.dds", 28, 28) .. "|c00CDCDTrove-/Cunning scamp|r",
            DsRGuildPvP_GoldScampOnOff           = "Show scamp spawn locations",

        --Options - 'IndexGroupRaid'
            -- Submenu - Tabelle des Todes
            DsRGuildDeathTable_SubMenu         = "|c00CDCDTable of Death|r",
            DsRGuildDeathTable_GroupJoin       = "Show table on Group Join",
            DsRGuildDeathTable_GroupJoinDesc   = "When ON the 'Table of Death' will be visible when you join a group. When OFF the Tally will not change state at group join.",
            DsRGuildDeathTable_GroupLeave      = "Hide table when leaving Group",
            DsRGuildDeathTable_GroupLeaveDesc  = "When ON the 'Table of Death' will be hidden when you leave a group. When OFF the Tally will not change state when you leave a group.",
            DsRGuildDeathTable_ResetTable      = "TReset table when joining Group",
            DsRGuildDeathTable_ResetTableDesc  = "When ON the 'Table of Death' will be reset when you join a group. When OFF the Tally data will remain unchanged when joining groups.",
            DsRGuildDeathTable_bgAlpha         = "Strength of the background",
            DsRGuildDeathTable_bgAlphaDesc     = "Adjust the alpha value of the background.\n0 = deactivated",
            DsRGuildDeathTable_Color           = "Custom Colors",
            DsRGuildDeathTable_ColorTitle      = "Title Color",
            DsRGuildDeathTable_ColorTitleDesc  = "Changes the Title color of the 'Table of Death'.",
            DsRGuildDeathTable_ColorPlayer     = "Player",
            DsRGuildDeathTable_ColorPlayerDesc = "Changes the Player Name color on the 'Table of Death'.",
            DsRGuildDeathTable_ColorCount      = "Death Count",
            DsRGuildDeathTable_ColorCountDesc  = "Changes the Death Count number color of the 'Table of Death'.",
            DsRGuildDeathTable_Lenght          = "Lenght",
            DsRGuildDeathTable_LenghtDESC      = "|cFFAE42Here you can adjust how many deaths the tally displays|r",
            DsRGuildDeathTable_LenghtDESC1     = "|cFFAE42before it turns into a scroll window.|r",
            DsRGuildDeathTable_LenghtSlid      = "On Screen Lenght",
            DsRGuildDeathTable_LenghtSlidDesc  = "10 = Would be the optimal length for groups of 12",

            -- Submenu - Schatztruhen
            DsRGuildMenue_TreasureFound   = "|c00CDCDTreasure|r",
            DsRGuildLootChest_Desc1       = "|cFFAE42As soon as you find a treasure chest and are in the dungeon / raid and in a group,|r",
            DsRGuildLootChest_Desc2       = "|cFFAE42you can press '|cFFAE42Enter|r' to share the treasure chest you found, as soon as you use it|r",
            DsRGuildLootChest_Desc3       = "|cFAA0A0(Attention! This option only appears if the box is still closed)|r",
            DsRGuildLootChest_MenueOnOff  = "Activate group chat message",
            DsRGuildLootChest_OnlyEN      = "Only in english?",
            DsRGuildLootChest_OnlyENDesc  = "Option only for german client",

            -- Submenu - GroupAttack
            DsRGuildMenue_GroupAttack         = "|c00CDCDGroupattack|r",
            DsRGuildGroupAttackTimer          = "From how many seconds should it start?",
            DsRGuildGroupAttack_FRIENDLYNAME  = "Groupattack",
            DsRGuildGroupAttack_DESCRIPTION   = "Allows you to send attack countdowns to your group.",
            DsRGuildGroupAttack_NOT_LEADER    = "|c9fb6cd[DsR-GroupAttack]|r |cFF0000You must be a group leader to initiate a countdown!",
            DsRGuildGroupAttack_COMMAND_HELP  = "Starts a pull countdown.",
            DsRGuildGroupAttack_Desc1         = "|cFAA0A0Attention! The group attack can only be initiated by the group leader|r",
            DsRGuildGroupAttack_Desc2         = "|cFFA500Note: You can use the countdown in the chat with|r '/dsrattack' |cFFA500or launch via a key binding|r",


        --Options - 'IndexGroupBuff'
        DsRGuildMenue_Buffs           = "|c00CDCDBuffs|r",
        DsRGuildMenue_BuffsDesc       = "|cadff2fDisplay a list of active buffs|r",
        DsRGuildMenue_BuffsEnable     = "|cFFAE42Enable the list|r",
        DsRGuildMenue_BuffsTxtOnOff   = "Hide buff name",
        DsRGuildMenue_BuffsTxtSize    = "Buff designation - Size",
        DsRGuildMenue_BuffsTxtCol     = "Buff designation - Colour",
        DsRGuildMenue_BuffsBarColor   = "Colour of the progress bar",
        DsRGuildMenue_BuffsBarMultiCol = "Different colours for the progress bar?",
        DsRGuildMenue_BuffsBarShield   = "FColour of the progress bar - Shield",
        DsRGuildMenue_BuffsBarHeal     = "Colour of the progress bar - Heal",
        DsRGuildMenue_BuffsBarDamage   = "Colour of the progress bar - Damage",
        DsRGuildMenue_BuffsBarUlti     = "Colour of the progress bar - Ulti",
        DsRGuildMenue_BuffsBarSelfBuff = "Colour of the progress bar - Own-Buffs",
        DsRGuildMenue_BuffsBarGroupBuff = "Colour of the progress bar - Group-Buffs",
        DsRGuildMenue_BuffsBarOtherBuff = "Colour of the progress bar - All other Buffs",
        DsRGuildMenue_BuffsBarDefault   = "Colour of the progress bar - Unknown",
        DsRGuildMenue_BuffsDDSSize    = "Icon size",
        DsRGuildMenue_BuffsTimerCol   = "Color timer number (in the icon)",
        DsRGuildMenue_BuffsCountCol   = "Color group encounters",
        DsRGuildMenue_BuffsCountSiz   = "Size group encounters",
        DsRGuildMenue_BuffsWhitelist  = "|c00FF00Buffs to be displayed (Whitelist)|r",
        DsRGuildMenue_BuffsWhiteDesc  = "The numbers must always be separated with a |cFFA500COMMA|r.",
        DsRGuildMenue_BuffsWhiteDesc1 = "The order on the UI is the order in the list.",
        DsRGuildMenue_BuffsWhiteRaid  = "Setting the whitelist locations according to character selection",
        DsRGuildMenue_BuffsSelectMenu = "|c00FF00Overview of Buff IDs|r",
        DsRGuildMenue_BuffsIDAnalyse  = "|c00CDCDDsR Buff-Analyse'|r",
        DsRGuildMenue_BuffsIDinfo     = "Find the right IDs for your buff list.",
        DsRGuildMenue_BuffsCheckClean = "|cFF0000Check list for duplicates|r",
        DsRGuildMenue_BuffsTableRowMax = "Number of buffs until another column is created",
        DsRGuildMenue_BuffsSettingMenu = "|c00FF00Buff-Management|r",
        DsRGuildMenue_BuffsSettingBUT  = "|c00CDCDDsR Buff-Management|r",
        DsRGuildMenue_BuffsSettingINFO = "Open the Buff Management window",
        DsRGuildMenue_BuffsSettingINFO1 = "|cFFA500Info: You can also open it in chat with|r “/dsrbuff” |cFFA500or via a key assignment|r",


        -- Options - Licht des Zusammenhalts
        DsRGuildMenue_beams                            = "Light of Togetherness",
        DsRGuildMenue_BeamAttention                    = "|cFAA0A0The subsampling quality must be set to >>High<<. Otherwise, this module will not function correctly.|r",
        DsRGuildMenue_BeamAttention2                   = "|cFAA0A0The |c35fc38[Temporary] |cFAA0A0Light does not work in: Cities, Battleground and Imperial City|r",
        DsRGuildBeam_LightEnabled                      = "Envelop your team in the brilliant Light of Togetherness",
        DsRGuildBeam_LightEnabledDesc                  = "Invoke the Light of Togetherness for Her blessings of group support.",
        DsRGuildBeam_LightEnabledTEMP                  = "|c35fc38[TEMPORARY] Envelop your character with light|r",
        DsRGuildBeam_LightEnabledTEMPDesc              = "Invoke the light of unity for the attitudes\nWill be deactivated at the latest after RELOADUI or exit",
        DsRGuildBeam_LightEnabledTEMPRGB               = "|c35fc38[TEMPORARY] What color should it be?|r",
        DsRGuildBeam_LightCombatOnly                   = "Show only during combat " .. zo_iconFormat("/esoui/art/progression/progression_tabicon_combatskills_down.dds", 28, 28),
        DsRGuildBeam_LightCombatOnlyDesc               = "The Light of Togetherness will only appear during the fight.",
        DsRGuildBeam_LightAlpha                        = "The radiance of their light.",
        DsRGuildBeam_LightAlphaDesc                    = "Adjust the divine radiance with which cohesion's Light shines.",
        DsRGuildBeam_LightTyp                          = "The appearance of light",
        DsRGuildBeam_LightHeight                       = "Length of light",
        DsRGuildBeam_LightHeightDesc                   = "Regulate the length of the light.",
        DsRGuildBeam_LightScale                        = "Width of the light",
        DsRGuildBeam_LightScaleDesc                    = "Regulate the width of the light.",
        DsRGuildBeam_LightAlwaysIgnoresDepthBuffer     = "Do not obscure light with obstacles?",
        DsRGuildBeam_LightAlwaysIgnoresDepthBufferDesc = "When switched off, the light is interrupted at obstacles\nDefault = ON",
        DsRGuildBeam_LightOwn                          = "Cover your own " .. zo_iconFormat("/esoui/art/charactercreate/charactercreate_faceicon_down.dds", 28, 28) ..  " in light too?",
        DsRGuildBeam_HeaderTWO                         = zo_iconFormat("/esoui/art/deathrecap/deathrecap_killingblow_icon.dds", 28, 28) .. "|c00CDCDLight of the Fallen...|r",
        DsRGuildBeam_LightDeadONOFF                    = "Report to fallen soldiers?",
        DsRGuildBeam_LightDead                         = "... show at dead",
        DsRGuildBeam_LightDeadDesc                     = "Radiate the brilliant Light of Togetherness from fallen group members.",
        DsRGuildBeam_LightDeadColor                    = "   -> Color",
        DsRGuildBeam_LightBeingResurrecting            = "... display during active resuscitation",
        DsRGuildBeam_LightBeingResurrectingDesc        = "Display the shining light on fallen party members who are currently receiving a revive.",
        DsRGuildBeam_LightResurrecting                 = "... display if resuscitation is successful",
        DsRGuildBeam_LightResurrectingDesc             = "Display the shining light on fallen party members who have been successfully revived.",
        DsRGuildBeam_HeaderTHREE                       = zo_iconFormat("/esoui/art/icons/u38_housing_meridialights.dds", 28, 28) .. "|c00CDCDLight of Champions...|r",
        DsRGuildBeam_HeaderTHREE_desc                  = "|cFFAE42Invoke cohesion's Blessing upon individual group members from the Interact With Player radial menu|r",
        DsRGuildBeam_HighlightLeaderONOFF              = "Separate color regardless of role",
        DsRGuildBeam_HighlightLeader                   = "Group Leader",
        DsRGuildBeam_HighlightTanks                    = "Tanks",
        DsRGuildBeam_HighlightHealers                  = "Healers",
        DsRGuildBeam_HighlightDDs                      = "DD",
        DsRGuildBeam_HeaderFOUR                        = zo_iconFormat("/esoui/art/icons/poi/poi_wayshrine_complete.dds", 28, 28) .. "|c00CDCDPlaces of Light...|r",
        DsRGuildBeam_LightGroupMembers                 = "Radiate Light from all other group members",
        DsRGuildBeam_LightGroupMembersDesc             = "Radiate the brilliant Light of Togetherness from all other group members in the scenario(s) listed below.",
        DsRGuildBeam_LightBattlegroundTeam             = "Battleground",
        DsRGuildBeam_LightBattlegroundTeamDesc         = "Radiate the brilliant Light of Togetherness from Battleground group members.",
        DsRGuildBeam_LightCyrodiilTeam                 = "Cyrodiil",
        DsRGuildBeam_LightCyrodiilTeamDesc             = "Radiate the brilliant Light of Togetherness from Cyrodiil group members",
        DsRGuildBeam_LightImperialCityTeam             = "Imperial city",
        DsRGuildBeam_LightImperialCityTeamDesc         = "Radiate the brilliant Light of Togetherness from Imperial city group members",
        DsRGuildBeam_LightNonPVPTeam                   = "Open World",
        DsRGuildBeam_LightNonPVPTeamDesc               = "Radiate the brilliant Light of Togetherness from group members while you are in Overland and Player Housing zones.",
        DsRGuildBeam_LightRAIDTeam                     = "Dungeon / Raid",
        DsRGuildBeam_LightRAIDTeamDesc                 = "Radiate the brilliant Light of Togetherness from group members while you are in dungeon/raid zones.",
        DsRGuildBeam_HeaderFIVE                        = zo_iconFormat("/DsRGuildHall/misc/DsR_Leader.dds", 28, 28) .. " |c00CDCDGrouleader...|r",

        --Options - 'IndexAchievTrack'
        DsRGuildAchievTracker_Desc1                       = "|cFFAE42The achievement settings are|r account-wide",
        DsRGuildAchievTracker_Desc2                       = "|cFFAE42However, the achievement pursuits set are bound to the|r character",
        DsRGuildAchievTracker_OnOff                       = "Achievement Tracker deactivate",
        DsRGuildAchievTracker_Lock                        = "Position lock" .. zo_iconFormat("/esoui/art/progression/progression_crafting_locked_up.dds", 26, 26),
        DsRGuildAchievTracker_LockDesc                    = "Makes the window unmovable and fixed to its position",
        DsRGuildAchievTracker_ShowIcons                   = "Show icons",
        DsRGuildAchievTracker_ShowIconsDesc               = "Shows the corresponding icon to the left of the achievement name",
        DsRGuildAchievTracker_Show_Desc                   = "Show description",
        DsRGuildAchievTracker_Show_DescDesc               = "Shows the description text underneath the name. Toggle to save space",
        DsRGuildAchievTracker_hideOldZoneAchievements     = "Hide old zone achievements",
        DsRGuildAchievTracker_hideOldZoneAchievementsDesc = "Automatically hides achievements from the old zone when you change zones",
        DsRGuildAchievTracker_maxTracked                  = "Maximum tracked",
        DsRGuildAchievTracker_maxTrackedDesc              = "Adjust the maximum number of tracked achievements.\n0 = means unlimited",
        DsRGuildAchievTracker_fontSizeName                = "Name font size",
        DsRGuildAchievTracker_fontSizeNameDesc            = "Adjust the font size of the tracked achievement names",
        DsRGuildAchievTracker_fontSize_Desc               = "Description font size",
        DsRGuildAchievTracker_fontSize_DescDesc           = "Adjust the font size of the tracked achievement descriptions",

        --Options - 'IndexCrafting'
        DsRGuildCrafting_DailyHeader    = "|c00CDCDAlchemy, Provision - Daily's|r",
        DsRGuildCrafting_Alchemy        = zo_iconFormat("/esoui/art/icons/skilllinexp_alchemy.dds", 26, 26) .. "Automatic production of alchemy",
        DsRGuildCrafting_Provision      = zo_iconFormat("/esoui/art/icons/skilllinexp_provisioner.dds", 26, 26) .. "Automatic production of food and drink",
        DsRGuildCrafting_PrecraftHeader = "|c00CDCDLazy write precarfting|r",
        DsRGuildCrafting_Precraft_DESC1 = "|cFFAE42You have the opportunity to pre-craft armor and jewelry for the daily crafts for 'X'-days.|r",
        DsRGuildCrafting_Precraft_DESC2 = "|cFFAE42/dsrcraft [MULTIPLIER] |cFAA0A0= will craft items for selected daily writs for the desired number|r",
        DsRGuildCrafting_Precraft_DESC3 = "|cFAA0A0of rotations.A rotation is a 3-day cycle for a particular profession.|r",
        
        --Options - 'IndexInventoryManager'
        DsRGuildInventory_InvOnOff             = "|cFFAE42Disable Inventory Manager|r",
        DsRGuildInventory_GeneralSettings      = "|c00CDCDGeneral Settings|r",
        DsRGuildInventory_DefaultSettings      = "|cFAA0A0Default state of the filter options after login or /reloadui:|r",
        DsRGuildInventory_ShowOnlyLoots        = "Show only loots",
        DsRGuildInventory_ShowCraftedSets      = "Show crafted sets" .. zo_iconFormat("/esoui/art/inventory/inventory_tabicon_crafting_up.dds", 32, 32),
        DsRGuildInventory_ShowTradeableSets    = "Show tradeable sets" .. zo_iconFormat("/esoui/art/guild/ownership_icon_guildtrader.dds", 32, 32),
        DsRGuildInventory_ShowBoundSets        = "Show bound sets" .. zo_iconFormat("/esoui/art/worldmap/map_indexicon_key_up.dds", 32, 32),
        DsRGuildInventory_ShowMonsterSets      = "Show monster sets" .. zo_iconFormat("/esoui/art/leveluprewards/levelup_veteran.dds", 32, 32),
        DsRGuildInventory_ShowOtherItems       = "Show other items",
        DsRGuildInventory_WindowSettings       = "|c00CDCDWindow Settings|r",
        DsRGuildInventory_ShowWinInventar      = "Show the manager in the inventory scene",
        DsRGuildInventory_ShowWinInventarDesc  = "Should the inventory manager be displayed automatically as soon as you go into the inventory?",
        DsRGuildInventory_ShowItemPrice        = zo_iconFormat("/DsRGuildHall/misc/tradehammer.dds", 26, 26) .. "Show item trading price",
        DsRGuildInventory_ShowItemEnchantments = zo_iconFormat("/esoui/art/inventory/gamepad/gp_inventory_icon_craftbag_enchanting.dds", 26, 26) .. "Show item enchantments",
        DsRGuildInventory_ShowNonCP160         = "Display the level on nonCP160 items",
        DsRGuildInventory_BagNameWidth         = "Bag name width",
        
        --Options - 'IndexTradingPrice'
        DsRGuildPrice_PriceOnOff                = "|cFFAE42Priceinformation deactivate|r",
        DsRGuildPrice_FormatSettings            = "|c00CDCDFormat settings|r",
        DsRGuildPrice_Thousandsep               = "Thousand separator",
        DsRGuildPrice_ThousandsepDesc           = "Separator to split thousand values",
        DsRGuildPrice_RoundPrice                = "Round price",
        DsRGuildPrice_ToolTipColor              = "Tooltip Color",
        DsRGuildPrice_ToolTipInfoColor          = "Tooltip info color",
        DsRGuildPrice_TooltipLineSpacing        = "Tooltip line spacing",
        DsRGuildPrice_TooltipLineSpacingDesc    = "Change the spacing for each tooltip line",
        DsRGuildPrice_SubMenueBoundItem         = zo_iconFormat("/esoui/art/collections/collections_categoryicon_locked_up.dds", 26, 26) .. "|c00CDCDBound Items|r",
        DsRGuildPrice_SubMenueTooltipFont       = zo_iconFormat("/esoui/art/crafting/sketches_tabicon_up.dds", 26, 26) .. "|c00CDCDTooltip Font|r",
        DsRGuildPrice_SubMenueContextMenu       = zo_iconFormat("/esoui/art/tradinghouse/tradinghouse_listings_tabicon_up.dds", 26, 26) .. "|c00CDCDContext Menu|r",
        DsRGuildPrice_SubMenueLowPriceIndi      = zo_iconFormat("/esoui/art/miscellaneous/gamepad/gp_scrollarrow.dds", 26, 26) .. "|c00CDCDLow price indicator|r",
        DsRGuildPrice_SubMenueOverridePrice     = zo_iconFormat("/esoui/art/bank/gamepad/gp_bank_menuicon_gold_deposit.dds", 26, 26) .. "|c00CDCDOverride settings|r",
        DsRGuildPrice_SubMenuePriceSettings     = zo_iconFormat("/DsRGuildHall/misc/tradehammer.dds", 26, 26) .. "|c00CDCDTrade prices|r",
        DsRGuildPrice_SubMenueDoubleTooltip     = "|c00CDCDTooltip FIX|r",
        DsRGuildPrice_DoubleFix                 = "Remove double tooltip fix",
        DsRGuildPrice_BountVendorPrice          = "Vendor Price for Grid",
        DsRGuildPrice_BountVendorPriceDesc      = "Calculates Vendor Price for Bound Items in Grid",
        DsRGuildPrice_BountIndicator            = "Show indicatorsymbol (*)",
        DsRGuildPrice_BountIndicatorColor       = "Color indicatorsymbol (*)",
        DsRGuildPrice_TooltipFont               = "Tooltip font",
        DsRGuildPrice_TooltipFontDesc           = "Font for the price in the tooltip",
        DsRGuildPrice_TooltipinfoFont           = "Tooltip info font",
        DsRGuildPrice_TooltipinfoFontDesc       = "Font for the info in the tooltip",
        DsRGuildPrice_ContextMenuUse            = "Activate |c9fb6cd[DsR-Price]|r-Menue",
        DsRGuildPrice_ContextMenuColor          = "Context Menu color",
        DsRGuildPrice_LowPriceIndiTooltip       = "Indicatorsymbol (*) in tooltip",
        DsRGuildPrice_LowPriceIndiTooltipDesc   = "Shows low price indicator in tooltip, if price is lower or equal vendor price",
        DsRGuildPrice_LowPriceIndiGrid          = "Indicatorsymbol (*) in grid",
        DsRGuildPrice_LowPriceIndiGridDesc      = "Works when override grid price is enabled",
        DsRGuildPrice_LowPriceIndiColor         = "Color indicatorsymbol (*)",
        DsRGuildPrice_OverridePriceGrid         = "Override grid price",
        DsRGuildPrice_OverridePriceGridDesc     = "Overrides the item price in grid",
        DsRGuildPrice_OverridePriceGridBeh      = "Grid price override behaviour",
        DsRGuildPrice_OverridePriceGridBehDesc  = "Set the behaviour of the override grid price",
        DsRGuildPrice_OverridePriceFirstOn      = "Enable first price (top position)",
        DsRGuildPrice_OverridePriceFirstOnDesc  = "Show the first price in grid (top position)",
        DsRGuildPrice_OverridePriceSecondOn     = "Enable second price (bottom position)",
        DsRGuildPrice_OverridePriceSecondOnDesc = "Show the second price in grid (bottom position)",
        DsRGuildPrice_OverridePriceSwitch       = "Switch single price to top and stack price to bottom",
        DsRGuildPrice_OverridePriceSwitchDesc   = "Show the single price on top and stack price on bottom in grid",
        DsRGuildPrice_PriceSettingsVendor       = "Display vendor price tooltip",
        DsRGuildPrice_PriceSettingsRound        = "Round to the next full value",
        DsRGuildPrice_SubMenueTTCsettings       = "|cadff2fTamriel Trade Centre (TTC)|r",
        DsRGuildPrice_TTCuse                    = "|cFFAE42Use TTC price|r",
        DsRGuildPrice_TTCscale                  = "Scale original TTC price",
        DsRGuildPrice_TTCscaleDesc              = "Scales original TTC price by percent (%)",
        DsRGuildPrice_TTCalternatscale          = "Scale ALT TTC price",
        DsRGuildPrice_TTCalternatscaleDesc      = "Scales Alternative Average TTC price by percent (%)",
        DsRGuildPrice_TTCalternat               = "Include ALT TTC price",
        DsRGuildPrice_TTCalternatDesc           = "Set Alternative Average TTC price when no suggested TTC price exists",
        DsRGuildPrice_TTCalternatColor          = "ALT TTC price color",
        DsRGuildPrice_TTCalternatColorDesc      = "Overrides some colors when price includes Alternative Average TTC price",
        DsRGuildPrice_TTCtooltip                = "Display TTC price in tooltip",
        DsRGuildPrice_TTCtooltipOri             = "Display original TTC price in tooltip",
        DsRGuildPrice_SubMenueMMsettings        = "|cadff2fMaster Merchant (MM)|r",
        DsRGuildPrice_MMuse                     = "|cFFAE42Use MM price|r",
        DsRGuildPrice_MMscale                   = "Scale original MM price",
        DsRGuildPrice_MMscaleDesc               = "Scales original MM price by percent (%)",
        DsRGuildPrice_MMtooltip                 = "Display MM price in tooltip",
        DsRGuildPrice_MMtooltipOri              = "Display original MM price info in tooltip",
        DsRGuildPrice_SubMenueATTsettings       = "|cadff2fArkadius Trade Tool (ATT)|r",
        DsRGuildPrice_ATTuse                    = "|cFFAE42Use ATT price|r",
        DsRGuildPrice_ATTscale                  = "Scale original ATT price",
        DsRGuildPrice_ATTscaleDesc              = "Scales original ATT price by percent (%)",
        DsRGuildPrice_ATTdayrange               = "ATT price days range",
        DsRGuildPrice_ATTdayrangeDesc           = "Calculate ATT price for this amount of days",
        DsRGuildPrice_ATTtooltip                = "Display ATT price in tooltip",
        DsRGuildPrice_ATTtooltipOri             = "Display original ATT price info in tooltip",
        DsRGuildPrice_SubMenueAvgPrice          = "|cadff2fAverage (trade) price|r",
        DsRGuildPrice_AvgPriceuse               = "|cFFAE42Use average (trade) price|r",
        DsRGuildPrice_AvgPriceuseDesc           = "Use average (trade) price from enabled scaled prices: MM, TTC, ATT",
        DsRGuildPrice_AvgPricedisplay           = "Display average (trade) price tooltip",
        DsRGuildPrice_AvgPriceIncTTC            = "Include TTC price",
        DsRGuildPrice_AvgPriceIncTTCalt         = "Include TTC alternate price",
        DsRGuildPrice_AvgPriceIncMM             = "Include MM price",
        DsRGuildPrice_AvgPriceIncATT            = "Include ATT price",
        DsRGuildPrice_SubMenueBestPrice         = "|cadff2fBest price|r",
        DsRGuildPrice_BestPriceuse              = "|cFFAE42Use best price|r",
        DsRGuildPrice_BestPriceuseDesc          = "Use best price from enabled scaled prices: Profit, MM, TTC, ATT",
        DsRGuildPrice_BestPricedisplay          = "Display best price tooltip",
        DsRGuildPrice_BestPriceTTCalt           = "Include TTC alternate price",
        DsRGuildPrice_BestPriceprofit           = "Include profit price",
        DsRGuildPrice_BestPricesource           = "Display source of the price",
        
        --Options - 'IndexTracker'
        DsRGuildUnknown_TrackerOnOff         = "|cFFAE42Disable the tracker|r",
        DsRGuildUnknown_TrackerACCSettings   = "|cFFBF00Account-Settings|r",
        DsRGuildUnknown_MenuInvIcon          = "|c00CDCDIcons at|r",
        SI_SCRIBING_TITLE                    = zo_iconFormat("/esoui/art/crafting/gamepad/gp_crafting_menuicon_scribing.dds", 26, 26) .. GetString(SI_SCRIBING_TITLE),
        SI_ITEMTYPE8                         = zo_iconFormat("/esoui/art/tradinghouse/gamepad/gp_tradinghouse_racial_style_motif_book.dds", 26, 26) .. GetString(SI_ITEMTYPE8),
        SI_ITEMTYPE29                        = zo_iconFormat("/esoui/art/tradinghouse/gamepad/gp_tradinghouse_trophy_recipe_fragment.dds", 26, 26) .. GetString(SI_ITEMTYPE29),
        SI_ITEMTYPE61                        = zo_iconFormat("/esoui/art/crafting/gamepad/gp_crafting_menuicon_furnishings.dds", 26, 26) .. GetString(SI_ITEMTYPE61),
        SI_SPECIALIZEDITEMTYPE82             = zo_iconFormat("/esoui/art/tradinghouse/gamepad/gp_tradinghouse_racial_style_motif_chapter.dds", 26, 26) .. GetString(SI_SPECIALIZEDITEMTYPE82),
        DsRGuildUnknown_Runeboxes            = zo_iconFormat("/esoui/art/tradinghouse/gamepad/gp_tradinghouse_trophy_runebox_fragment.dds", 26, 26) .. "Runebox",
        DsRGuildUnknown_ToolChat             = "|c00CDCDTooltip & Chat|r",
        DsRGuildUnknown_TooltipShow          = "Show in tooltip",
        DsRGuildUnknown_ChatShow             = "Show in chat",
        DsRGuildUnknown_InventarShow         = "Show in inventory",
        DsRGuildUnknown_MenuIcon             = "|c00CDCDIcon (Inventory, Bank ...)|r",
        DsRGuildUnknown_PositionTP           = "Where should the icon be displayed in the inventory etc.?",
        DsRGuildUnknown_IconArt              = "Which icon?",
        DsRGuildUnknown_IconMulti            = "Use Multi Icon ( " .. "|c00ff00|t24:24:/esoui/art/buttons/accept_up.dds:inheritcolor|t|r" .. "/" .. "|c2400db|t24:24:/esoui/art/buttons/plus_up.dds:inheritcolor|t|r" .. "/" .. "|cff0000|t24:24:/esoui/art/buttons/decline_up.dds:inheritcolor|t|r" .. " )",
        DsRGuildUnknown_IconOnlyUnknownINV   = "Display inventory-icon only if 'unknown'",
        DsRGuildUnknown_IconOnlyUnknownCHAT  = "Display chat-icon only if 'unknown'",
        DsRGuildUnknown_ColorUnknown         = "Color: Unknown",
        DsRGuildUnknown_ColorUnknownOther    = "Color: Known (but not by everyone)",
        DsRGuildUnknown_ColorKnownAll        = "Color: Known (to all)",
        DsRGuildUnknown_axesOffset           = "|c00CDCDIcon position|r",
        DsRGuildUnknown_XaxesOffset          = "Offset X-axis (horizontal)",
        DsRGuildUnknown_YaxesOffset          = "Offset Y-axis (vertical)",
        DsRGuildUnknown_IconSize             = "Size of the icon",
        DsRGuildUnknown_Layer                = "Layer",
        DsRGuildUnknown_MenuTrack            = "Track",
        DsRGuildUnknown_MenuPrio             = "Priorität",
        DsRGuildUnknown_MenuPrioDesc         = "Determines the order of the names in the tooltip\n1=First, 20=Last",

        --Options - 'IndexPersonalAss'
        DsRGuildPersonal_GeneralUse                   = "|cFFAE42Activate your personal assistant|r",
        DsRGuildPersonal_General                      = "|cff9029All settings are 'character-related'|r",
        DsRGuildPersonal_ConsumeCHARSettings          = "|cFFBF00Character-Settings|r",
        DsRGuildPersonal_CurrencyUse                  = "|cFFAE42Activate the banking|r",
        DsRGuildPersonal_BankingAvAUse                = "|cFFAE42Activate the Cyrodiil-Banking|r",
        DsRGuildPersonal_BankingStack                 = "|cFFAE42Items automatically stack|r |c3b3b3b(inventory / bank)|r",
        DsRGuildPersonal_GeneralAttention1            = "|cFAA0A0Note:|r",
        DsRGuildPersonal_GeneralAttention2            = "|cFAA0A0The image may freeze briefly if many objects need to be moved!|r",
        DsRGuildPersonal_BankingDefaultMenu           = "|cFFBF00Defaults for all characters|r",
        DsRGuildPersonal_BankingDefaultMenuAttention1 = "|cFAA0A0The settings overwrite the respective settings of the characters|r",
        DsRGuildPersonal_BankingDefaultMenuAttention2 = "|cFAA0A0and cannot be undone|r",
        DsRGuildPersonal_CurrencyCurrency             = "|c00CDCDCurrency|r",
        DsRGuildPersonal_CurrencyGold                 = zo_iconFormat("/esoui/art/currency/currency_gold.dds", 26, 26) .. "Gold",
        DsRGuildPersonal_CurrencyGoldDesc             = "Clear the field to disable it",
        DsRGuildPersonal_CurrencySchrieb              = zo_iconFormat("/esoui/art/icons/icon_writvoucher.dds", 26, 26) .. "Writ vouchers",
        DsRGuildPersonal_CurrencySchriebDesc          = "Clear the field to disable it",
        DsRGuildPersonal_CurrencyAP                   = zo_iconFormat("/esoui/art/currency/alliancepoints_64.dds", 26, 26) .. "Alliance Points",
        DsRGuildPersonal_CurrencyAPDesc               = "Clear the field to disable it",
        DsRGuildPersonal_CurrencyTelVar               = zo_iconFormat("/esoui/art/hud/telvar_meter_currency.dds", 26, 26) .. "TelVar Stones",
        DsRGuildPersonal_CurrencyTelVarDesc           = "Clear the field to disable it",
        DsRGuildPersonal_CurrencyLockPickGem          = "|c00CDCDLock picks / soul gem|r",
        DsRGuildPersonal_SoulGemEmpty                 = "empty",
        DsRGuildPersonal_Repairkit                    = zo_iconFormat(GetItemLinkIcon("|H0:item:44879:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 26, 26) .. LocalizeString("<<1>>", "|H0:item:44879:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
        DsRGuildPersonal_CurrencyMapRecipe            = "|c00CDCDMaps / Fragments etc|r",
        DsRGuildPersonal_CurrencyRecipeALL            = "|c228B22|t30:30:/esoui/art/icons/heraldrycrests_misc_starburst_01.dds:inheritcolor|t|r" .. "Always store everything",
        DsRGuildPersonal_CurrencyRecipeKnown          = "|c228B22|t30:30:/esoui/art/icons/heraldrycrests_misc_starburst_01.dds:inheritcolor|t|r" .. "Only store known",
        DsRGuildPersonal_CurrencyRecipeUnknown        = "|cb81414|t30:30:/esoui/art/icons/heraldrycrests_misc_starburst_01.dds:inheritcolor|t|r" .. "Only take unknowns",
        DsRGuildPersonal_CurrencyPvPSubmenu           = zo_iconFormat("/esoui/art/icons/fragment_gladiator_proof.dds", 26, 26) .. "|c00CDCD Meriten, Brands, Evidence|r",
        DsRGuildPersonal_CurrencyPvPMerite            = zo_iconFormat(GetItemLinkIcon("|H0:item:151939:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:151939:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
        DsRGuildPersonal_CurrencyPvPMarke             = zo_iconFormat(GetItemLinkIcon("|H0:item:212235:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:212235:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
        DsRGuildPersonal_CurrencyPvPBeweis            = zo_iconFormat(GetItemLinkIcon("|H0:item:138783:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:138783:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
        DsRGuildPersonal_CurrencyAmount               = "         Amount",
        DsRGuildPersonal_JunkUse                      = zo_iconFormat("/esoui/art/inventory/inventory_tabicon_junk_up.dds", 26, 26) .. "|cFFAE42Enable marking as junk|r",
        DsRGuildPersonal_JunkSell                     = zo_iconFormat("/esoui/art/inventory/inventory_tabicon_junk_up.dds", 26, 26) .. "|cFFAE42Sell ​​junk automatically|r",
        DsRGuildPersonal_DeconstructUse               = zo_iconFormat("/esoui/art/crafting/enchantment_tabicon_deconstruction_up.dds", 26, 26) .. "|cFFAE42Activate automatic deconstruction|r",
        DsRGuildPersonal_MenueJunkJunk                = "|c00CDCDMark as junk|r",
        DsRGuildPersonal_JunkPlunder                  = zo_iconFormat("/esoui/art/inventory/inventory_tabicon_junk_up.dds", 26, 26) .. "Plunder",
        DsRGuildPersonal_JunkPrey                     = zo_iconFormat("/esoui/art/inventory/inventory_tabicon_junk_up.dds", 26, 26) .. "Prey",
        DsRGuildPersonal_JunkArmorWeaponNoTrait       = zo_iconFormat("/esoui/art/inventory/inventory_trait_retrait_icon.dds", 26, 26) .. "Weapons/Armor without Trait",
        DsRGuildPersonal_MenueJunkDeconstruct         = "|c00CDCDDeconstruct|r",
        DsRGuildPersonal_DeconstructNoTrait           = "Items without [trait] always",
        DsRGuildPersonal_DeconstructJunk              = zo_iconFormat("/esoui/art/inventory/inventory_tabicon_junk_up.dds", 26, 26) .. "Junk-items always",
        DsRGuildPersonal_DeconstructSetItem           = zo_iconFormat("/esoui/art/collections/collections_tabicon_itemsets_up.dds", 26, 26) .. "Set-items",
        DsRGuildPersonal_DeconstructCrafted           = zo_iconFormat("/esoui/art/crafting/reconstruct_tabicon_disabled.dds", 26, 26) .. "[Crafted] items",
        DsRGuildPersonal_DeconstructReconstr          = zo_iconFormat("/esoui/art/inventory/inventory_reconstructeditem.dds", 26, 26) .. "[Reconstructed] items",
        DsRGuildPersonal_DeconstructDescQuali         = "|c00CDCDSet the quality up to which the material should be recycled|r",
        DsRGuildPersonal_Glyphe                       = "Glyphe",
        DsRGuildPersonal_DeconstructWithorBelow       = "|c6d6d6d(with quality equal or lower)|r",
        DsRGuildPersonal_Jewelry                      = "Jewelry",
        DsRGuildPersonal_ConsumeOnOff                 = "|cFFAE42Activate your hunger|r",
        DsRGuildPersonal_ConsumeACCSettings           = "|cFFBF00Account-settings|r",
        DsRGuildPersonal_ConsumeInterval              = "|cFFAE42The notification interval is every 30 seconds!|r",
        DsRGuildPersonal_ConsumeBuffFoodONOff         = zo_iconFormat("/esoui/art/icons/justice_stolen_food_001.dds", 26, 26) .. "Turn on Buff-Food reminder?",
        DsRGuildPersonal_ConsumeBuffFoodfalse         = "Remind when no buff food is available?",
        DsRGuildPersonal_ConsumeBuffFoodMinTime       = "From when would you like us to remind you? |c3b3b3b(in minuts)|r",
        DsRGuildPersonal_ConsumeXPONOff               = zo_iconFormat("/DsRGuildHall/misc/DsR_XP.dds", 26, 26) .. "-Turn on buff reminder?",
        DsRGuildPersonal_ConsumeXPfalse               = "Remind when no XP-buff is available?",
        DsRGuildPersonal_ConsumeXPMinTime             = "From when would you like us to remind you? |c3b3b3b(in minuts)|r",
        DsRGuildPersonal_ConsumeAPONOff               = zo_iconFormat("/DsRGuildHall/misc/DsR_AP.dds", 26, 26) .. "-Turn on buff reminder?",
        DsRGuildPersonal_ConsumeAPfalse               = "Remind when no AP-buff is available?",
        DsRGuildPersonal_ConsumeAPMinTime             = "From when would you like us to remind you? |c3b3b3b(in minuts)|r",
        DsRGuildPersonal_ConsumeInfo1                 = "|cFAA0A0Corresponding buff food, AP-, XP-role can be assigned/removed|r",
        DsRGuildPersonal_ConsumeInfo2                 = "|cFAA0A0in the inventory via the right mouse button|r",
        DsRGuildPersonal_ConsumeAutoEat               = "Satisfy your hunger |c3b3b3b(in minuts)|r",
        DsRGuildPersonal_ConsumeAutoEatDesc           = "The value '0' deactivates the satisfaction of hunger",
        DsRGuildPersonal_ConsumeAutoXP                = "Activate autom. " .. zo_iconFormat("/DsRGuildHall/misc/DsR_XP.dds", 26, 26) .. "-role",
        DsRGuildPersonal_ConsumeAutoAP                = "Activate autom. " .. zo_iconFormat("/DsRGuildHall/misc/DsR_AP.dds", 26, 26) .. "-role",
        DsRGuildPersonal_AvAShopMainDesc1             = "Set how much of what you want to buy / refill",
        DsRGuildPersonal_AvAShopMainDesc2             = "as soon as you speak to a siege master",
        DsRGuildPersonal_AvAShopUse                   = "|cFFAE42Activate trading with any master|r",
        DsRGuildPersonal_RepairMenueDesc              = "|cFAA0A0ATTENTION: This settings account-wide!",
        DsRGuildPersonal_RepairMenueOnOff             = "|cFFAE42Activate the armor workshop|r",
        DsRGuildPersonal_RepairChat                   = "|c35fc38Show workshop news in the chat|r",
        DsRGuildPersonal_RepairStores                 = "|c00CDCDStores|r",
        DsRGuildPersonal_RepairStoresAuto             = "Auto-Repair at Stores",
        DsRGuildPersonal_RepairRepairing              = "|c00CDCDRepairing|r",
        DsRGuildPersonal_RepairRepairingAuto          = "Automatic repair",
        DsRGuildPersonal_RepairRepairingAutoAny       = "Use any Repair Kit",
        DsRGuildPersonal_RepairKit                    = "Repair kit threshold",
        DsRGuildPersonal_RepairRecharging             = "|c00CDCDRecharging|r",
        DsRGuildPersonal_RepairRechargingAuto         = "Automatic recharging",
        DsRGuildPersonal_RepairRechargingAutoAny      = "Use any soul gem",
        DsRGuildPersonal_RepairRecharge               = "Recharge threshold",

        --Options - 'BarMenu'
        DsRGuildBarMenu_OnOff          = "|cFFAE42Activate the Ravenbar|r",
        DsRGuildBarMenu_OnOffDesc      = "View the Raven Bar on your desktop",
        DsRGuildBarMenu_accsettings    = "|cFFAE42All settings apply account-wide!|r",
        DsRGuildBarMenu_PosUPBOT       = "Location of the RavenBar",
        DsRGuildBarMenu_Bankspace      = zo_iconFormat("/esoui/art/icons/mapkey/mapkey_bank.dds", 22, 22) .. "Bank",
        DsRGuildBarMenu_Inventoryspace = zo_iconFormat("/esoui/art/inventory/gamepad/gp_inventory_icon_all.dds", 22, 22) .. "Inventory",
        DsRGuildBarMenu_LockPick       = zo_iconFormat(GetItemLinkIcon("|H0:item:30357:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), 22, 22) .. LocalizeString("<<1>>", "|H0:item:30357:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
        DsRGuildBarMenu_CurrencyAP     = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_ALLIANCE_POINTS)) .. GetCurrencyName(CURT_ALLIANCE_POINTS, false):gsub("%^.+", ""),
        DsRGuildBarMenu_CurrencyTelVar = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_TELVAR_STONES)) .. GetCurrencyName(CURT_TELVAR_STONES, false):gsub("%^.+", ""),
        DsRGuildBarMenu_CurrencyXP     = zo_iconFormat("/DsRGuildHall/misc/DsR_XP.dds", 22, 22) .. "-Progress",
        DsRGuildBarMenu_RefreshTimer   = "Refresh time in sec|u1:4::|u" .. zo_iconFormat("/esoui/art/tutorial/timer_icon.dds",28,28),
        DsRGuildBarMenu_Scale          = "Scaling the font size",
        DsRGuildBarMenu_SpaceOffSet    = "Distance between values",
        DsRGuildBarMenu_MenueHide      = "Hide in menus",
        DsRGuildBarMenu_Campion        = zo_iconFormat("/esoui/art/mainmenu/menubar_champion_up.dds", 24, 24) .. "Champion/Level",
        DsRGuildBarMenu_Crowns         = string.format("|t24:24:%s|t", GetCurrencyKeyboardIcon(CURT_CROWNS)) .. GetCurrencyName(CURT_CROWNS, false):gsub("%^.+", ""),
        DsRGuildBarMenu_writvoucher    = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_WRIT_VOUCHERS)) .. GetCurrencyName(CURT_WRIT_VOUCHERS, false):gsub("%^.+", ""),
        DsRGuildBarMenu_OStime         = zo_iconFormat("/esoui/art/lfg/lfg_indexicon_timedactivities_up.dds", 22, 22) .. "Clock",
        DsRGuildBarMenu_Stolen         = zo_iconFormat("/esoui/art/inventory/inventory_stolenitem_icon.dds", 22, 22) .. "Stolen goods",
        DsRGuildBarMenu_Background     = "Show background",
        DsRGuildBarMenu_BgTransparent  = "Background visibility",
        DsRGuildBarMenu_TomeChallenge  = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_TOME_CHALLENGE_REROLLS)) .. GetCurrencyName(CURT_TOME_CHALLENGE_REROLLS, false):gsub("%^.+", ""),
        DsRGuildBarMenu_TomePoints     = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_TOME_POINTS)) .. GetCurrencyName(CURT_TOME_POINTS, false):gsub("%^.+", ""),
        DsRGuildBarMenu_TomePointCach  = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_TOME_POINT_CACHES)) .. GetCurrencyName(CURT_TOME_POINT_CACHES, false):gsub("%^.+", ""),
        DsRGuildBarMenu_TomeToken      = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_TOME_TOKENS)) .. GetCurrencyName(CURT_TOME_TOKENS, false):gsub("%^.+", ""),
        DsRGuildBarMenu_TradeBars      = string.format("|t22:22:%s|t", GetCurrencyKeyboardIcon(CURT_TRADE_BARS)) .. GetCurrencyName(CURT_TRADE_BARS, false):gsub("%^.+", ""),
}
