local L = {}
-- ---------------------------------------------------
-- SETTINGS ------------------------------------------
-- ---------------------------------------------------
L.Description                 = 'For more commands write |c00FF1a/rt help|cFFFFFF in chat.'
L.Hardmode                    = 'Hardmode Calculation?'
L.Hardmode_Tooltip            = '(Adds +40k to possible end points)'
L.Show_Timers_Outside         = 'Show timers outside of the raid'
L.Show_Timers_Outside_Tooltip = 'This option will automatically be set to off everytime you /reloadui or logout.'
L.Unlock_Timers               = 'Unlock timers'
L.Unlock_Timers_Tooltip       = 'For the changes to be applied you have to lock the position again (Set to OFF) or press Apply.'
L.Total_Time_Color            = 'Total Timer color'
L.Total_Time_Color_Tooltip    = 'Change the color of Total Timer.'
L.Raid_Score_Color            = 'Raid Score color'
L.Raid_Score_Color_Tooltip    = 'Change the color of the Raid Score.'
L.Vitality_Bonus_Color         = 'Vitality Bonus color'
L.Vitality_Bonus_Color_Tooltip = 'Change the color of the Vitality Bonus.'
L.Fonts                       = 'Fonts'
L.Fonts_Tooltip               = 'Change the font of the timers.'
L.Font_Size                   = 'Font Size'
L.Font_Size_Tooltip           = 'Change the size of the font.'
L.Font_Style                  = 'Font Style'
L.Font_Style_Tooltip          = 'Change the style of the font.'
L.Debug                       = 'Enable debug messages'
L.Debug_Tooltip               = 'Whith this option enabled, addon prints detailed raid score information to the chat.'
L.Apply                       = 'Apply'
L.Aplly_Tooltip               = 'Apply the changes.'
-- ---------------------------------------------------
-- TEXT STRINGS --------------------------------------
-- ---------------------------------------------------
L.Total_Time_Template           = 'Total Time:'
L.Raid_Score_Template           = 'Raid Score: 0'
L.Vitality_Bonus_Template       = 'Vitality Bonus Lifes: 0 / 0'
L.Total_Time                    = 'Total Time: <<1>>' -- <<1>> is the formatted time
L.Raid_Score_Without_Estimation = 'Raid Score: <<1>>' -- <<1>> ist the current score
L.Raid_Score_With_Estimation    = 'Raid Score: <<1>> (~<<2>>)' -- <<1>> ist the current score, <<2>> the estimated score
L.Raid_Score_With_New_TopScore  = 'Raid Score: <<1>> (~<<2>>)!!'  -- <<1>> ist the current score, <<2>> the estimated score
L.Vitality_Bonus                = 'Vitality Bonus Lifes: <<1>> / <<2>>'  -- <<1>> are the current lifes, <<2>> the max lifes
L.Possible_New_TopScore_Debug   = 'Possible new Topscore! Previuos Topscore was <<1>> (<<2>>)'  -- <<1>> ist the previous score, <<2>> the previous time
L.Debug_Message                 = 'Raid Score: |cFFFFFF<<1>>|r, total: |cFFFFFF<<2>>|r, reason: |cFFFFFF<<3>>|r'  -- <<1>> ist the current points, <<2>> the total raidscore and <<3>> the reason for getting points
L.Trial_Start_Message           = 'Raid Started, current TopScore: |cFFFFFF<<1>>|r, Time: |cFFFFFF<<2>>|r' -- <<1>> is the previous topscore, <<2>> the previous top time
L.Trial_Complete                = 'Trial |cFFFFFF<<1>>|r completed in |cFFFFFF<<2>>|r, score: |cFFFFFF<<3>>|r.' -- <<1>> is the Trial Name, <<2>> the time and <<3>> the score
L.Trial_Failed                  = 'Trial |cFFFFFF<<1>>|r failed. Total time: |cFFFFFF<<2>>|r, score: |cFFFFFF<<3>>|r.'  -- <<1>> is the Trial Name, <<2>> the time and <<3>> the score
L.New_Topscore                  = 'New |cFFFFFFTop|r |cFFFFFFScore|r !'
L.Trialname_Unknown             = 'Unknown'
L.Surprise                      = '|cffe100We\'re no strangers to|r |cff4747love...|r |cffe100You know the rules and so do I! A full commitment\'s what i\'m thinking of! You wouldn\'t get this from any other |cff4747guy!|r|cffe100 I just wanna tell you how I\'m feeling! Gotta make you understand...|r|cff4747 Never gonna give you up!|r |c00FF1aNever gonna let you down!|r |c00D5FFNever gonna run around and desert you!|r |cFFC000Never gonna make you cry!|r |cFF00EFNever gonna say goodbye!|r |cFF0000Never gonna tell a lie and hurt you!|r'
L.Help                          = '|cffe100Write|r |c00FF1a /rt help|r |cffe100for help.|r'
-- ---------------------------------------------------
-- SLASH COMMANDS ------------------------------------
-- ---------------------------------------------------
L.Slash_Help          = '|cffe100----------RaidTimer help----------|r'
L.Slash_Start         = '|c00FF1a/rt start|r |cffe100to force start the timer(works during raid)|r'
L.Slash_Stop          = '|c00FF1a/rt stop|r |cffe100to force stop the timer (works during raid)|r'
L.Slash_Show          = '|c00FF1a/rt show|r |cffe100to display the timers while outside of a raid|r'
L.Slash_Hide          = '|c00FF1a/rt hide|r |cffe100to hide the timers while out of a raid|r'
L.Slash_Debug         = '|c00FF1a/rt debug|r |cffe100toggles detailed raid score messages|r'
L.Slash_Surprise      = '|c00FF1a/rt surprise|r |cffe100for a surprise|r'
L.Slash_Settings_Hint = '|cffe100Check|r |c00FF1aSettings > Addon Settings > RaidTimer|cffe100 for an option menu|r'
-- ---------------------------------------------------
-- RAID POINT REASONS --------------------------------
-- ---------------------------------------------------
L.BONUS_ACTIVITY_HIGH   = 'High Bonus! Yay!'
L.BONUS_ACTIVITY_LOW    = 'Low Bonus...'
L.BONUS_ACTIVITY_MEDIUM = 'Medium Bonus!'
L.KILL_BANNERMEN        = 'Evil Bannermen killed!'
L.KILL_BOSS             = 'Boss killed! Well done!'
L.KILL_CHAMPION         = 'Champion killed'
L.KILL_MINIBOSS         = 'Miniboss? srsly?'
L.KILL_NORMAL_MONSTER   = 'Normal Mob killed'
L.KILL_NOXP_MONSTER     = 'Haha! No XP Mob killed!'
L.LIFE_REMAINING        = 'Someone died. Noob.'
L.BONUS_POINT_ONE       = 'Bonus Point (One)'
L.BONUS_POINT_TWO       = 'Bonus Point (Two)'
L.BONUS_POINT_THREE     = 'Bonus Point (Three)'
L.SYGILLS_USED_NONE     = 'Round Finished. No Sygills used. Great!'
L.SYGILLS_USED_THREE    = 'Round Finished. Three Sygills used.'
L.SYGILLS_USED_TWO      = 'Round Finished. Two Sygills used. Ok.'
L.SYGILLS_USED_ONE      = 'Round Finished. One Sygill used. Superb!'
L.ARENA_COMPLETE        = 'Arena Stage finished!'

for k, v in pairs(L) do
    local string = "RAIDTIMER_" .. string.upper(k)
    ZO_CreateStringId(string, v)
end