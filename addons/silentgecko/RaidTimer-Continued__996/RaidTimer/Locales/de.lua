local L = {}
-- ---------------------------------------------------
-- SETTINGS ------------------------------------------
-- ---------------------------------------------------
L.Description                 = 'Für weitere Befehler schreibe |c00FF1a/rt help|cFFFFFF in den Chat.'
L.Hardmode                    = 'Hardmode Berechnung?'
L.Hardmode_Tooltip            = '(Addiert +40k Punkte zur vorhergesagten und aktuellen Punktzahl)'
L.Show_Timers_Outside         = 'Zeige die Timer auch außerhalb von Prüfungen'
L.Show_Timers_Outside_Tooltip = 'Diese Einstellung wird bei jedem ausloggen oder /reloadui zurückgesetzt'
L.Unlock_Timers               = 'Entsperre Timer'
L.Unlock_Timers_Tooltip       = 'Damit die Änderungen übernommen werden, musst du die Änderungen bestätigen oder die Position wieder sperren'
L.Total_Time_Color            = 'Timer Farbe'
L.Total_Time_Color_Tooltip    = 'Ändert die Farbe des Timers.'
L.Raid_Score_Color            = 'Punktzahl Farbe'
L.Raid_Score_Color_Tooltip    = 'Ändert die Farbe der Punktzahl.'
L.Vitality_Bonus_Color         = 'Vitalitätsbonus Farbe'
L.Vitality_Bonus_Color_Tooltip = 'Ändert die Farbe des Vitalitätsbonus.'
L.Fonts                       = 'Schriftart'
L.Fonts_Tooltip               = 'Ändert die Schriftart des Timers.'
L.Font_Size                   = 'Schriftgröße'
L.Font_Size_Tooltip           = 'Ändert die Schriftgröße.'
L.Font_Style                  = 'Schriftstil'
L.Font_Style_Tooltip          = 'Ändert den Stil der Schrift.'
L.Debug                       = 'Aktiviere Debug Modus'
L.Debug_Tooltip               = 'Wenn diese Option AN ist, schreibt der Raidtimer detailierte Informationen in den Chat'
L.Apply                       = 'Speichern'
L.Aplly_Tooltip               = 'Speichert die Änderungen.'
-- ---------------------------------------------------
-- TEXT STRINGS --------------------------------------
-- ---------------------------------------------------
L.Total_Time_Template           = 'Zeit:'
L.Raid_Score_Template           = 'Punkte: 0'
L.Vitality_Bonus_Template       = 'Vitalitätsbonus Leben: 0 / 0'
L.Total_Time                    = 'Zeit: <<1>>' -- <<1>> is the formatted time
L.Raid_Score_Without_Estimation = 'Punkte: <<1>>' -- <<1>> ist the current score
L.Raid_Score_With_Estimation    = 'Punkte: <<1>> (~<<2>>)' -- <<1>> ist the current score, <<2>> the estimated score
L.Raid_Score_With_New_TopScore  = 'Punkte: <<1>> (~<<2>>)!!'  -- <<1>> ist the current score, <<2>> the estimated score
L.Vitality_Bonus                = 'Vitalitätsbonus Leben: <<1>> / <<2>>'  -- <<1>> are the current lifes, <<2>> the max lifes
L.Possible_New_TopScore_Debug   = 'Mögliche neue Bestpunktzahl! Vorherige Bestpunktzahl war <<1>> (<<2>>)'  -- <<1>> ist the previous score, <<2>> the previous time
L.Debug_Message                 = 'Punkte: |cFFFFFF<<1>>|r, Total: |cFFFFFF<<2>>|r, Grund: |cFFFFFF<<3>>|r'  -- <<1>> ist the current points, <<2>> the total raidscore and <<3>> the reason for getting points
L.Trial_Start_Message           = 'Prüfung gestartet, aktuelle Bestpunktzahl: |cFFFFFF<<1>>|r, Zeit: |cFFFFFF<<2>>|r' -- <<1>> is the previous topscore, <<2>> the previous top time
L.Trial_Complete                = 'Prüfung |cFFFFFF<<1>>|r erfolgreich abgeschlossen in |cFFFFFF<<2>>|r, Punkte: |cFFFFFF<<3>>|r.' -- <<1>> is the Trial Name, <<2>> the time and <<3>> the score
L.Trial_Failed                  = 'Prüfung |cFFFFFF<<1>>|r fehlgeschlagen. Zeit: |cFFFFFF<<2>>|r, Punkte: |cFFFFFF<<3>>|r.'  -- <<1>> is the Trial Name, <<2>> the time and <<3>> the score
L.New_Topscore                  = 'Neue |cFFFFFFBest|r|cFFFFFFpunktzahl|r !'
L.Trialname_Unknown             = 'Unbekannt'
L.Surprise                      = '|cffe100We\'re no strangers to|r |cff4747love...|r |cffe100You know the rules and so do I! A full commitment\'s what i\'m thinking of! You wouldn\'t get this from any other |cff4747guy!|r|cffe100 I just wanna tell you how I\'m feeling! Gotta make you understand...|r|cff4747 Never gonna give you up!|r |c00FF1aNever gonna let you down!|r |c00D5FFNever gonna run around and desert you!|r |cFFC000Never gonna make you cry!|r |cFF00EFNever gonna say goodbye!|r |cFF0000Never gonna tell a lie and hurt you!|r'
L.Help                          = '|cffe100Schreibe|r |c00FF1a /rt help|r |cffe100in den Chat für Hilfe.|r'
-- ---------------------------------------------------
-- SLASH COMMANDS ------------------------------------
-- ---------------------------------------------------
L.Slash_Help          = '|cffe100----------RaidTimer help----------|r'
L.Slash_Start         = '|c00FF1a/rt start|r |cffe100startet den Timer manuell (funktioniert während einer Prüfung)|r'
L.Slash_Stop          = '|c00FF1a/rt stop|r |cffe100stoppt den Timer manuell (funktioniert während einer Prüfung)|r'
L.Slash_Show          = '|c00FF1a/rt show|r |cffe100zeigt die Timer auch außerhalb von Prüfungen an|r'
L.Slash_Hide          = '|c00FF1a/rt hide|r |cffe100versteckt die Timer außerhalb von Prüfungen|r'
L.Slash_Debug         = '|c00FF1a/rt debug|r |cffe100zeigt detailierte Nachrichten im Chat|r'
L.Slash_Surprise      = '|c00FF1a/rt surprise|r |cffe100für eine Überraschung|r'
L.Slash_Settings_Hint = '|cffe100Ein Optionsmenü findest du unter |r |c00FF1aEinstellungen > Erweiterungen > RaidTimer|cffe100|r'
-- ---------------------------------------------------
-- RAID POINT REASONS --------------------------------
-- ---------------------------------------------------
L.BONUS_ACTIVITY_HIGH   = 'Hoher Bonus! Yay!'
L.BONUS_ACTIVITY_LOW    = 'Kleiner Bonus...'
L.BONUS_ACTIVITY_MEDIUM = 'Mittlerer Bonus!'
L.KILL_BANNERMEN        = 'Böse Bannerträger getötet!'
L.KILL_BOSS             = 'Boss getötet! Sehr gut!'
L.KILL_CHAMPION         = 'Champion getötet'
L.KILL_MINIBOSS         = 'Miniboss? srsly?'
L.KILL_NORMAL_MONSTER   = 'Normales Mob getötet'
L.KILL_NOXP_MONSTER     = 'Haha! Dieses Mob gab keine XP! :)'
L.LIFE_REMAINING        = 'Schon wieder einer gestorben. Noob.'
L.BONUS_POINT_ONE       = 'Bonus Punkte (Eins)'
L.BONUS_POINT_TWO       = 'Bonus Punkte (Zwei)'
L.BONUS_POINT_THREE     = 'Bonus Punkte (Drei)'
L.SYGILLS_USED_NONE     = 'Runde beendet. Keine Sygille benutzt. Großartig!'
L.SYGILLS_USED_THREE    = 'Runde beendet. Drei Sygillen benutzt. Das geht besser!'
L.SYGILLS_USED_TWO      = 'Runde beendet. Zwei Sygillen benutzt. Ok.'
L.SYGILLS_USED_ONE      = 'Runde beendet. Nur eine Sygille benutzt. Super!'
L.ARENA_COMPLETE        = 'Arena Stage beendet!'

for k, v in pairs(L) do
    local string = "RAIDTIMER_" .. string.upper(k)
    ZO_CreateStringId(string, v)
end