-- This file is part of CyrodiilAlert
ZO_CreateStringId("SI_CYRODIIL_ALERT", "CyrodiilAlert")
ZO_CreateStringId("SI_CYRODIIL_ALERT_LANG", "en")

--- CyrodiilAlert.lua

-- InitKeeps
ZO_CreateStringId("SI_CYRODIIL_ALERT_INIT_TEXT", "Cyrodiil Alert Initialized")
ZO_CreateStringId("SI_CYRODIIL_ALERT_CAMP_WELCOME", "|cE6E6E6Welcome to |r<<1>>|cE6E6E6!|r")
ZO_CreateStringId("SI_CYRODIIL_ALERT_CAMP_HOME", "|cE6E6E6Home Campaign:|r <<1>>")
ZO_CreateStringId("SI_CYRODIIL_ALERT_CURRENT_IMPERIAL", "You currently have Imperial City access")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DO_NOT_HAVE_IMPERIAL", "You do not have Imperial City access")
ZO_CreateStringId("SI_CYRODIIL_ALERT_OUTSIDE_CYRODIIL", "Notifications outside of Cyrodiil are OFF")
ZO_CreateStringId("SI_CYRODIIL_ALERT_CHAT_OUTPUT_ON", "Chat output is On")
ZO_CreateStringId("SI_CYRODIIL_ALERT_CHAT_OUTPUT_OFF", "Chat output is Off")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_ON", "On-Screen Notifications are On")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_OFF", "On-Screen Notifications are Off")

-- DumpChat
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOT_IN_CY", "Not in Cyrodiil")
ZO_CreateStringId("SI_CYRODIIL_ALERT_STATUS_TEXT", "Cyrodiil Status:")
ZO_CreateStringId("SI_CYRODIIL_ALERT_UNDER_ATTACK", "Under Attack!")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NO_ATTACK", "No keeps are under attack")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SIEGES_A", "     Sieges: A:")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SLASH_D", " / D:")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SIEGES_ATT", "     Sieges: Att: ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SLASH_DEF", " / Def:")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SIEGES_AD", "     Sieges: AD: ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DC", ", DC: ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_EP", ", EP: ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SIEGES_NONE", "     Sieges: None")

-- dumpImperial
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_CITY", "Imperial City:")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NO_DISTRICT_UNDER_ATTACK", "No districts are under attack")
ZO_CreateStringId("SI_CYRODIIL_ALERT_AD_NAME", "     Aldmeri Dominion")
ZO_CreateStringId("SI_CYRODIIL_ALERT_UNLOCKED", "Unlocked")
ZO_CreateStringId("SI_CYRODIIL_ALERT_KEEP_CONTROLLED", ", Keeps Controlled: ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_OF", " of ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_LOCKED", "Locked")
ZO_CreateStringId("SI_CYRODIIL_ALERT_EP_NAME", "     Ebonheart Pact")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DC_NAME", "     Daggerfall Covenant")

-- dumpDistricts
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOT_IN_IC", "Not in Imperial City")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_DISTRICTS", "Imperial Districts:")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DISTRICTS", ": Districts: ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_TEL_VAR_BONUS", "Tel Var Bonus")

-- CampaignQueue
ZO_CreateStringId("SI_CYRODIIL_ALERT_IS_GROUP", " (Group)")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IS_SOLO", " (Solo)")
ZO_CreateStringId("SI_CYRODIIL_ALERT_QUEUE_POSITION", "<<1>> |cE6E6E6Queue Position:|r <<2>> <<3>>")
ZO_CreateStringId("SI_CYRODIIL_ALERT_QUEUE_READY", "<<1>> |cE6E6E6Campaign Queue Ready|r <<2>>")
ZO_CreateStringId("SI_CYRODIIL_ALERT_AUTO_QUEUE", "Entering Campaign in:")

-- OnAllianceOwnerChanged
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_CAPTURED", "<<2>> |cE6E6E6has captured|r <<1>>")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IN_DISTRICTS_TOTAL", "<<1>> <<2>> |t16:16:<<X:3>>|t |cE6E6E6in Districts  (Total|r <<4>>|cE6E6E6)|r")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IN_DISTRICTS_TOTAL2", "<<1>> <<2>> |t30:30:<<X:3>>|t |cE6E6E6in Districts  (Total|r <<4>>|cE6E6E6)|r")

-- OnKeepUnderAttackChanged
ZO_CreateStringId("SI_CYRODIIL_ALERT_IS_UNDER_ATTACK", "<<1>> |cE6E6E6is under attack!|r")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IS_NO_LONGER_UNDER_ATTACK", "<<1>> |cE6E6E6is no longer under attack|r")

-- OnGateChanged
ZO_CreateStringId("SI_CYRODIIL_ALERT_THE", "|cE6E6E6The|r ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IS_OPEN", "<<1>> |cE6E6E6The|r <<2>> |cE6E6E6is open!|r")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IS_CLOSED", "<<1>> |cE6E6E6The|r <<2>> |cE6E6E6is closed!|r")

-- OnDeposeEmperor
ZO_CreateStringId("SI_CYRODIIL_ALERT_EMPEROR", "|cE6E6E6Emperor|r ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ABDICATED", "<<1>> |cE6E6E6Emperor|r <<3>> |cE6E6E6of|r <<2>> |cE6E6E6has abdicated!|r")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DEPOSED", "<<1>> |cE6E6E6Emperor|r <<3>> |cE6E6E6of|r <<2>> |cE6E6E6has been deposed!|r")

-- OnCoronateEmperor
ZO_CreateStringId("SI_CYRODIIL_ALERT_CROWNED_EMPEROR", "<<1>> <<3>> |cE6E6E6of|r <<2>> |cE6E6E6has been crowned Emperor!|r")

-- OnArtifactControlState
ZO_CreateStringId("SI_CYRODIIL_ALERT_PICKED_UP", "|cE6E6E6<<1>>:|r <<3>> |cE6E6E6of|r <<2>> |cE6E6E6has picked up|r <<4>>")
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_TAKEN", "|cE6E6E6<<1>>:|r <<3>> |cE6E6E6of|r <<2>> |cE6E6E6has taken|r <<5>> |cE6E6E6from|r <<4>>")
ZO_CreateStringId("SI_CYRODIIL_ALERT_FROM", " from ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_DROPPED", "|cE6E6E6<<1>>:|r <<3>> |cE6E6E6of|r <<2>> |cE6E6E6has dropped|r <<4>>")
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_SECURED", "|cE6E6E6<<1>>:|r <<3>> |cE6E6E6of|r <<2>> |cE6E6E6has secured|r <<5>> |cE6E6E6at|r <<4>>")
ZO_CreateStringId("SI_CYRODIIL_ALERT_AT", " at ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_RETURNED", "|cE6E6E6<<1>>:|r <<3>> |cE6E6E6of|r <<2>> |cE6E6E6has returned|r <<4>> |cE6E6E6to|r <<5>>")
ZO_CreateStringId("SI_CYRODIIL_ALERT_TO", " to ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_RETURNED_TO", " |cE6E6E6has returned to|r ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_TIMEOUT", "|cE6E6E6<<1>>:|r <<2>> |cE6E6E6has automatically returned to|r <<3>>")

-- OnObjectiveControlState
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_RECAPTURED", "<<1>> |cE6E6E6has recaptured|r <<2>>")
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_FALLEN", "<<3>> |cE6E6E6has lost|r <<1>>")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NO_CONTROL", "No Control")
ZO_CreateStringId("SI_CYRODIIL_ALERT_UNKNOWN", "Unknown")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DAEDRIC_SPAWNED", "<<1>> |cE6E6E6has appeared in Cyrodiil|r")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DAEDRIC_TAKEN", "<<3>> |cE6E6E6of|r <<1>> |cE6E6E6has picked up|r <<2>>")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DAEDRIC_DROPPED", "<<3>> |cE6E6E6of|r <<1>> |cE6E6E6has dropped|r <<2>>")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DAEDRIC_DESPAWNED", "<<1>> |cE6E6E6has returned to Oblivion|r")

-- OnClaimKeep
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_CLAIMED", "|cE6E6E6<<1>>:|r <<2>> |cE6E6E6has claimed|r <<4>> |cE6E6E6for|r <<3>>")
ZO_CreateStringId("SI_CYRODIIL_ALERT_FOR", " for ")

-- OnImperialAccessGained
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_CITY2", "Imperial City")
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_GAINED_ACCESS", "<<1>> <<2>> has gained access to <<3>>!")

-- OnImperialAccessLost
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_LOST_ACCESS", "<<1>> <<2>> has lost access to <<3>>")

-- OnUnderpopChange
ZO_CreateStringId("SI_CYRODIIL_ALERT_UNDERPOP_TITLE", "Low Population Bonus Updated")
ZO_CreateStringId("SI_CYRODIIL_ALERT_UNDERPOP_ONE", "<<1>> |cE6E6E6are gaining a Low Population Bonus|r")
ZO_CreateStringId("SI_CYRODIIL_ALERT_UNDERPOP_TWO", "<<1>> |cE6E6E6and|r <<2>> |cE6E6E6are gaining a Low Population Bonus|r")
ZO_CreateStringId("SI_CYRODIIL_ALERT_UNDERPOP_THREE", "<<1>> |cE6E6E6are gaining a Low Population Bonus|r")
ZO_CreateStringId("SI_CYRODIIL_ALERT_UNDERPOP_NONE", "No Alliances")
ZO_CreateStringId("SI_CYRODIIL_ALERT_UNDERPOP_ALL", "All Alliances")

-- OnScoreEvaluation
ZO_CreateStringId("SI_CYRODIIL_ALERT_SCORE_EVALUATION", "<<1>> |cE6E6E6Score Evaluation|r")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SCORE_DETAILS", "<<1>>|cE6E6E6: <<2>>|r \n <<3>>|cE6E6E6: <<4>>|r \n <<5>>|cE6E6E6: <<6>>|r")

-- OnPassableChanged
ZO_CreateStringId("SI_CYRODIIL_ALERT_IS_PASSABLE", "<<1>> |cE6E6E6has been repaired!|r")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IS_PASSABLE_2", "The bridge is passable in both directions.")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IS_BLOCKED", "<<1>> |cE6E6E6has been destroyed!|r")

-- OnDirectionalAccessChanged
ZO_CreateStringId("SI_CYRODIIL_ALERT_ACCESS_IGNORE", "(Directional access for <<1>> has been ignored)")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ACCESS_BIDIRECTIONAL", "<<1>> |cE6E6E6has been repaired!|r")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ACCESS_BIDIRECTIONAL_2", "The gate is passable in both directions.")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ACCESS_UNIDIRECTIONAL_A", "<<1>> |cE6E6E6has been blocked!|r")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ACCESS_UNIDIRECTIONAL_B", "<<1>> |cE6E6E6has been unblocked!|r")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ACCESS_UNIDIRECTIONAL_2", "The gate is passable in one direction only.")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ACCESS_BLOCKED", "<<1>> |cE6E6E6has been destroyed!|r")

-- CAslash
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_OUTSIDE_OFF", "Notifications outside of Cyrodiil turned OFF.")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_OUTSIDE_ON", "Notifications outside of Cyrodiil turned ON.")
ZO_CreateStringId("SI_CYRODIIL_ALERT_HELP", "Avalable slash commands: show, hide, status, attacks, score, underpop, imperial, ic, init, clear, help")



--- CyrodiilAlertConfig.lua
ZO_CreateStringId("SI_CYRODIIL_ALERT_DISPLAY_NAME", "Cyrodiil Alert 2")
ZO_CreateStringId("SI_CYRODIIL_ALERT_CONFIG", "Config")
ZO_CreateStringId("SI_CYRODIIL_ALERT_GENERAL_OPTIONS", "General Options")

-- Notification Delay
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_DELAY_NAME", "     Notification Delay")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_DELAY_TOOLTIP", "Seconds for which the notification will remain on screen")

-- Output to chat
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_OUTPUT_CHAT_NAME", "Output to Chat")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_OUTPUT_CHAT_TOOLTIP", "Outputs the notifications to your chat window")

-- On-Screen Notifications
ZO_CreateStringId("SI_CYRODIIL_ALERT_ON_SCREEN_NOTIFICATION_NAME", "On-Screen Notifications")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ON_SCREEN_NOTIFICATION_TOOLTIP", "Display notifications using ESO's built-in announcement system")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ON_SCREEN_NOTIFICATION_DISABLED", "Disabled")

-- Sound
ZO_CreateStringId("SI_CYRODIIL_ALERT_SOUND_NAME", "     Sound")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SOUND_TOOLTIP", "Enable notification sounds")

-- Lock/Unlock
ZO_CreateStringId("SI_CYRODIIL_ALERT_LOCK_UNLOCK_NAME", "Lock/Unlock")
ZO_CreateStringId("SI_CYRODIIL_ALERT_LOCK_UNLOCK_TOOLTIP", "Lock/Unlock the CA UI alert window")

-- Enable Notifications inside IC
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_NOTIFICATION_INSIDE_IC_NAME", "Enable Cyrodiil Notifications Inside Imperial City")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_NOTIFICATION_INSIDE_IC_TOOLTIP", "Get notifications for Cyrodiil when you are in the Imperial City")

-- Enable Notifications outside Cyrodiil
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_NOTIFICATION_OUTSIDE_CY_NAME", "Enable Notifications Outside Cyrodiil")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_NOTIFICATION_OUTSIDE_CY_TOOLTIP", "Get notifications when you are out of Cyrodiil")

-- Show initialization message
ZO_CreateStringId("SI_CYRODIIL_ALERT_REDIRECT_SHOW_INIT_MESSAGE_NAME", "Show Initialization Message")
ZO_CreateStringId("SI_CYRODIIL_ALERT_REDIRECT_SHOW_INIT_MESSAGE_TOOLTIP", "When you enter Cyrodiil or Imperial City, show Campaign Name and current attack status in the chat window")

-- Show keep status initialization message
ZO_CreateStringId("SI_CYRODIIL_ALERT_REDIRECT_SHOW_INIT_KEEPS_NAME", "     Show Initial Keeps Under Attack On-Screen")
ZO_CreateStringId("SI_CYRODIIL_ALERT_REDIRECT_SHOW_INIT_KEEPS_TOOLTIP", "List all keeps that are under attack in the on-screen initialization announcement (keeps under attack are always shown in chat)")

-- Use alliance colors
ZO_CreateStringId("SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_NAME", "Use Alliance Colors")
ZO_CreateStringId("SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_TOOLTIP", "Display alliance names in their colors; ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_AD_NAME", "Aldmeri Dominion")
ZO_CreateStringId("SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_DC_NAME", "Daggerfall Covenant")
ZO_CreateStringId("SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_EP_NAME", "Ebonheart Pact")

-- Queue Options
ZO_CreateStringId("SI_CYRODIIL_ALERT_QUEUE_OPTIONS", "Queue Options")

-- Queue Accept
ZO_CreateStringId("SI_CYRODIIL_ALERT_QUEUE_ACCEPT_NAME", "Automatically Accept Queue")
ZO_CreateStringId("SI_CYRODIIL_ALERT_QUEUE_ACCEPT_TOOLTIP", "Automatically enter Cyrodiil once your position in the Campaign Queue reaches 0")

-- Queue Accept Delay
ZO_CreateStringId("SI_CYRODIIL_ALERT_QUEUE_ACCEPT_DELAY_NAME", "     Acceptance Delay")
ZO_CreateStringId("SI_CYRODIIL_ALERT_QUEUE_ACCEPT_DELAY_TOOLTIP", "Seconds to wait before automatically entering Campaign")

-- Keep status
ZO_CreateStringId("SI_CYRODIIL_ALERT_KEEP_STATUS", "Keep Status")

-- Reinitialize
ZO_CreateStringId("SI_CYRODIIL_ALERT_REINITIALIZE_TITLE", "Reinitialize")
ZO_CreateStringId("SI_CYRODIIL_ALERT_REINITIALIZE_TEXT", "also available via '/ca init'")

-- Update Status
ZO_CreateStringId("SI_CYRODIIL_ALERT_UPDATE_STATUS_NAME", "Update Status")
ZO_CreateStringId("SI_CYRODIIL_ALERT_UPDATE_STATUS_TOOLTIP", "Reinitialize the add-on and update keep and resource ownership for current Cyrodiil campaign")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DUBIOUS_OUTSIDE_CY_WARNING", "Dubious outside Cyrodiil")
ZO_CreateStringId("SI_CYRODIIL_ALERT_MUST_BE_IN_CY", "Must be in Cyrodiil")
ZO_CreateStringId("SI_CYRODIIL_ALERT_MUST_BE_IN_IC", "Must be in Imperial City")

-- Output status to chat
ZO_CreateStringId("SI_CYRODIIL_ALERT_OUTPUT_STATUS_TO_CHAT_TITLE", "Output Status to Chat")
ZO_CreateStringId("SI_CYRODIIL_ALERT_OUTPUT_STATUS_TO_CHAT_TEXT", "also available via '/ca attacks' and '/ca status'")

-- List attacks
ZO_CreateStringId("SI_CYRODIIL_ALERT_LIST_ATTACKS_NAME", "List Attacks")
ZO_CreateStringId("SI_CYRODIIL_ALERT_LIST_ATTACKS_TOOLTIP", "Output list of keeps and resources under attack")

-- List status
ZO_CreateStringId("SI_CYRODIIL_ALERT_LIST_STATUS_NAME", "List Status")
ZO_CreateStringId("SI_CYRODIIL_ALERT_LIST_STATUS_TOOLTIP", "Output ownership and attack status of all keeps and resources")

-- Campaign Options
ZO_CreateStringId("SI_CYRODIIL_ALERT_CAMPAIGN_OPTIONS", "Campaign Options")

-- Keep Options
ZO_CreateStringId("SI_CYRODIIL_ALERT_KEEP_OPTIONS", "Keeps")

-- Outpost Options
ZO_CreateStringId("SI_CYRODIIL_ALERT_OUTPOST_OPTIONS", "Outposts")

-- Resource Options
ZO_CreateStringId("SI_CYRODIIL_ALERT_RESOURCE_OPTIONS", "Resources")

-- Town Options
ZO_CreateStringId("SI_CYRODIIL_ALERT_TOWN_OPTIONS", "Towns")

-- Imperial City
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_CITY_TITLE", "Imperial City")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_CITY_STATUS_TITLE", "Imperial City Status")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_CITY_TEXT", "also available via '/ca ic'")

-- Access & Districts
ZO_CreateStringId("SI_CYRODIIL_ALERT_ACCESS_DISTRICTS_NAME", "List Districts")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ACCESS_DISTRICTS_TOOLTIP", "Output status of Imperial City district control")

-- Notification Options
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_OPTIONS_NAME", "Objective Options")

-- Enable Alliance Capture Notification
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_ALLIANCE_OWNER_NOTIFICATION_NAME", "Alliance Capture Notifications")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_ALLIANCE_OWNER_NOTIFICATION_TOOLTIP", "Get notifications when an alliance captures an objective")

-- Notification Importance
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_IMPORTANCE_NAME", "Capture Importance")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_IMPORTANCE_TOOLTIP", "Alliance ownership changes can be shown as Major or Minor notifications")

-- Enable Keep Notification
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_KEEP_NOTIFICATION_NAME", "Enable Keep Notifications")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_KEEP_NOTIFICATION_TOOLTIP", "Get notifications about Keeps")

-- Enable Resource Notification
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_RESOURCE_NOTIFICATION_NAME", "Enable Resource Notifications")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_RESOURCE_NOTIFICATION_TOOLTIP", "Get notifications about Farms, Mines and Lumbermills")

-- Enable Outpost Notification
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_OUTPOST_NOTIFICATION_NAME", "Enable Outpost Notifications")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_OUTPOST_NOTIFICATION_TOOLTIP", "Get notifications about Outposts")

-- Enable Attack Notification
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_ATTACK_NOTIFICATION_NAME", "Under Attack Notifications")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_ATTACK_NOTIFICATION_TOOLTIP", "Get notifications about objectives being attacked")

-- Attack Importance
ZO_CreateStringId("SI_CYRODIIL_ALERT_ATTACK_IMPORTANCE_NAME", "Attack Importance")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ATTACK_IMPORTANCE_NAME_INDENTED", "     Attack Importance")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ATTACK_IMPORTANCE_TOOLTIP", "Objectives under attack can be shown as Major or Minor notifications")

-- Show Attack/Defence Sieges
ZO_CreateStringId("SI_CYRODIIL_ALERT_ATTACK_DEFENCE_NAME", "     Show Attack/Defense Sieges")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ATTACK_DEFENCE_TOOLTIP", "Show siege weapon numbers by total attacking/defending")

-- Show Sieges by Alliance
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_SIEGES_BY_ALLIANCE_NAME", "     Show Sieges by Alliance")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_SIEGES_BY_ALLIANCE_TOOLTIP", "Show siege weapon numbers by alliance")

-- Enable Attack Ending Notifications
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_ATTACK_ENDING_NOTIFICATIONS_NAME", "Attack Ending Notifications")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_ATTACK_ENDING_NOTIFICATIONS_TOOLTIP", "Get notifications about attacks ending")

-- Enable Resources Update
ZO_CreateStringId("SI_CYRODIIL_ALERT_RESOURCE_UPDATES_NAME", "Enable Resource Updates")
ZO_CreateStringId("SI_CYRODIIL_ALERT_RESOURCE_UPDATES_TOOLTIP", "Get notifications when resources upgrade or degrade")

-- Enable Guild Claim Notification
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_CLAIM_NOTIFICATION_NAME", "Guild Claim Notifications")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_CLAIM_NOTIFICATION_TOOLTIP", "Get notifications about guilds claiming keeps")

-- Enable Emperor Notification
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_EMPEROR_NOTIFICATION_NAME", "Emperor Notifications")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_EMPEROR_NOTIFICATION_TOOLTIP", "Get notifications about Emperors")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_EMPEROR_OUT_NOTIFICATION_NAME", "     Show Emperors when not in Cyrodiil")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_EMPEROR_OUT_NOTIFICATION_TOOLTIP", "Get notifications about Emperors when not in Cyrodiil")

-- Enable Imperial City Notification
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_IC_NOTIFICATION_NAME", "Imperial City Access Notifications")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_IC_NOTIFICATION_TOOLTIP", "Get notifications about Imperial City access")

-- Enable Score Notification
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_SCORE_NOTIFICATION_NAME", "Score Evaluation Notifications")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_SCORE_NOTIFICATION_TOOLTIP", "Get notifications when the campaign score is reevaluated")

-- Enable Underpop Notification
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_UNDERPOP_NOTIFICATION_NAME", "Low Population Notifications")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_UNDERPOP_NOTIFICATION_TOOLTIP", "Get notifications when the low population bonus is activated")

-- Enable Queue Notification
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_QUEUE_NOTIFICATION_NAME", "Queue Position Notifications")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_QUEUE_NOTIFICATION_TOOLTIP", "Get notifications when position in the Campaign Queue changes")

-- Queue Ready
ZO_CreateStringId("SI_CYRODIIL_ALERT_QUEUE_READY_NAME", "Queue Ready Notifications")
ZO_CreateStringId("SI_CYRODIIL_ALERT_QUEUE_READY_TOOLTIP", "Get notifications when the Campaign is ready to enter")

-- Show Only My Alliance
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_ONLY_MY_ALLIANCE_NAME", "Show Only My Alliance")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_ONLY_MY_ALLIANCE_TOOLTIP", "Get keep and resource notifications for <<1>> only")

-- Objective Options
ZO_CreateStringId("SI_CYRODIIL_ALERT_OBJECTIVE_OPTIONS_NAME", "Other Objectives")

-- Enable Town Capture Notifications
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_TOWN_CAPTURE_NOTIFICATION_NAME", "Enable Town Notifications")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_TOWN_CAPTURE_NOTIFICATION_TOOLTIP", "Get notifications about Cyrodiil towns")

-- Enable District Capture Notifications
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_DISTRICT_CAPTURE_NOTIFICATION_NAME", "Enable District Notifications")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_DISTRICT_CAPTURE_NOTIFICATION_TOOLTIP", "Get notifications about Imperial City Districts")

-- Show District Capture in Cyrodiil
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_DISTRICT_CAPTURE_IN_CY_NAME", "     Show District Capture in Cyrodiil")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_DISTRICT_CAPTURE_IN_CY_TOOLTIP", "Get notifications for Imperial District capture when in Cyrodiil")

-- Show Tel Var Capture Bonus
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_TEL_VAR_CAPTURE_BONUS_NAME", "     Show Tel Var Capture Bonus")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_TEL_VAR_CAPTURE_BONUS_TOOLTIP", "Show the changes in the District Tel Var bonus")

-- Enable Indiviual Flag Notifications
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_INDIVIUAL_FLAG_NOTIFICATION_NAME", "Enable Individual Flag Notifications")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_INDIVIUAL_FLAG_NOTIFICATION_TOOLTIP", "Get notifications about alliances securing individual objective flags")

-- Show Keep Flags
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_KEEP_FLAGS_NAME", "Show Keep Flags")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_KEEP_FLAGS_TOOLTIP", "Get notifications for individual flags in Keeps")

-- Show Outpost Flags
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_OUTPOST_FLAGS_NAME", "Show Outpost Flags")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_OUTPOST_FLAGS_TOOLTIP", "Get notifications for individual flags in Outposts")

-- Show Resource Flags
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_RESOURCE_FLAGS_NAME", "Show Resource Flags")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_RESOURCE_FLAGS_TOOLTIP", "Get notifications for flags at Farms, Mines and Lumbermills")

-- Show Town Flags
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_TOWN_FLAGS_NAME", "Show Town Flags")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_TOWN_FLAGS_TOOLTIP", "Get notifications for individual flags in Towns")

-- Show District Flags
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_DISTRICT_FLAGS_NAME", "Show District Flags")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_DISTRICT_FLAGS_TOOLTIP", "Get notifications for flags in Imperial City Districts")

-- Show Flags at Neutral
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_FLAGS_AS_NEUTRAL_NAME", "     Show Flags at Neutral")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_FLAGS_AS_NEUTRAL_TOOLTIP", "Get notifications when an alliance loses a flag during capture")

-- Show Bridges and Milegates
ZO_CreateStringId("SI_CYRODIIL_ALERT_BRIDGES_NAME", "Bridges and Milegates")
ZO_CreateStringId("SI_CYRODIIL_ALERT_BRIDGES_TOOLTIP", "Get notifications when bridges or milegates are attacked, destroyed or repaired")

-- Bridges Importance
ZO_CreateStringId("SI_CYRODIIL_ALERT_BRIDGES_IMPORTANCE_NAME", "     Status Importance")
ZO_CreateStringId("SI_CYRODIIL_ALERT_BRIDGES_IMPORTANCE_TOOLTIP", "Crossings destroyed and repaired can be shown as Major or Minor notifications")

-- Enable Gate Notifications
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_GATE_NOTIFICATION_NAME", "Scroll Temple Gate Notifications")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_GATE_NOTIFICATION_TOOLTIP", "Get notifications about Artifact Gates")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_GATE_OUT_NOTIFICATION_NAME", "     Show Gates when not in Cyrodiil")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_GATE_OUT_NOTIFICATION_TOOLTIP", "Get notifications about Artifact Gates when not in Cyrodiil")

-- Enable Scroll Notifications
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_SCROLL_NOTIFICATION_NAME", "Elder Scroll Notifications")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_SCROLL_NOTIFICATION_TOOLTIP", "Get notifications about Elder Scrolls")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_SCROLL_OUT_NOTIFICATION_NAME", "     Show Scrolls when not in Cyrodiil")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_SCROLL_OUT_NOTIFICATION_TOOLTIP", "Get notifications about Elder Scrolls when not in Cyrodiil")

-- Enable Daedric Artifact Notifications
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_DAEDRIC_NOTIFICATION_NAME", "Daedric Artifact Notifications")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_DAEDRIC_NOTIFICATION_TOOLTIP", "Get notifications about Daedric Weapons")

-- Imperial City DLC
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_CITY_STATUS", "The following options may be unavailable depending on whether or not you own the Imperial City DLC.")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_CITY_DLC_NAME", "Imperial City DLC Collectible")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_CITY_DLC_TOOLTIP", "Indicates whether you have unlocked the Imperial City DLC collectible")

-- Imperial City Override
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_CITY_OVERRIDE_NAME", "Override")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_CITY_OVERRIDE_TOOLTIP", "Temporarily overrides the status of the Imperial City DLC to enable the following options. Persists until the UI is reloaded.")