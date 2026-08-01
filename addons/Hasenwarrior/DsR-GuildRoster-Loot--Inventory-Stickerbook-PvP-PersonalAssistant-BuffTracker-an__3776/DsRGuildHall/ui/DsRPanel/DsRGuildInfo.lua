-- Create namespace
DsRGuildInfo = {}


-------------------------------------------------------------------------------------------------------------------------------------------------
----- Check first guild and frame
function DsRGuildInfo.Check()
    local guildId   = GUILD_ROSTER_MANAGER:GetGuildId()
    local guildName = GetGuildName(guildId)

    local ld = os.date("*t")
    local myGuildTextColor       = "FFD700"
    local myGuildEventColor      = "C1FFC1"
    local myGuildEventStartColor = "CAFF70"
    local myGuildEventEndColor   = "F08080"
    
    local InfoTXT = GetString(DsR_Event)
    DsRGuildInfoTXT:SetText(InfoTXT)
    
    
    if guildName ~= "Die sieben Raben" then
        DsRGuildInformations:SetHidden(true)
    else
        DsRGuildInformations:SetHidden(false) 
-- Lotterie    
 -- Tag der Ziehung / Tag der Ziehung    
        -- if ( ld.month == 12 and ld.day >= 20 ) or ( ld.month == 1 and ld.day <= 7 ) then
        --     Ziehung = string.format("%s|c%s%s|r", "nächste Ziehung: ", myGuildTextColor, "07.01.2024")
        -- elseif ( ld.month == 1 and ld.day >= 7 ) or ( ld.month == 2 and ld.day <= 4 ) then
        --     Ziehung = string.format("%s|c%s%s|r", "nächste Ziehung: ", myGuildTextColor, "04.02.2024")
        -- elseif ( ld.month == 2 and ld.day >= 4 ) or ( ld.month == 3 and ld.day <= 3 ) then
        --     Ziehung = string.format("%s|c%s%s|r", "nächste Ziehung: ", myGuildTextColor, "03.03.2024")
        -- elseif ( ld.month == 3 and ld.day >= 3 ) or ( ld.month == 3 and ld.day <= 31 ) then
        --     Ziehung = string.format("%s|c%s%s|r", "nächste Ziehung: ", myGuildTextColor, "31.03.2024")
        -- elseif ( ld.month == 3 and ld.day >= 31 ) or ( ld.month == 4 and ld.day <= 28 ) then
        --     Ziehung = string.format("%s|c%s%s|r", "nächste Ziehung: ", myGuildTextColor, "28.04.2024")
        -- elseif ( ld.month == 4 and ld.day >= 28 ) or ( ld.month == 5 and ld.day <= 26 ) then
        --     Ziehung = string.format("%s|c%s%s|r", "nächste Ziehung: ", myGuildTextColor, "26.05.2024")
        -- elseif ( ld.month == 5 and ld.day >= 26 ) or ( ld.month == 6 and ld.day <= 23 ) then
        --     Ziehung = string.format("%s|c%s%s|r", "nächste Ziehung: ", myGuildTextColor, "23.06.2024")
        -- elseif ( ld.month == 6 and ld.day >= 23 ) or ( ld.month == 7 and ld.day <= 21 ) then
        --     Ziehung = string.format("%s|c%s%s|r", "nächste Ziehung: ", myGuildTextColor, "21.07.2024")
        -- elseif ( ld.month == 7 and ld.day >= 21 ) or ( ld.month == 8 and ld.day <= 25 ) then
        --     Ziehung = string.format("%s|c%s%s|r", "nächste Ziehung: ", myGuildTextColor, "25.08.2024")
        -- elseif ( ld.month == 8 and ld.day >= 25 ) or ( ld.month == 9 and ld.day <= 29 ) then
        --     Ziehung = string.format("%s|c%s%s|r", "nächste Ziehung: ", myGuildTextColor, "29.09.2024")
        -- elseif ( ld.month == 9 and ld.day >= 29 ) or ( ld.month == 10 and ld.day <= 27 ) then
        --     Ziehung = string.format("%s|c%s%s|r", "nächste Ziehung: ", myGuildTextColor, "27.10.2024")
        -- elseif ( ld.month == 10 and ld.day >= 27 ) or ( ld.month == 11 and ld.day <= 24 ) then
        --     Ziehung = string.format("%s|c%s%s|r", "nächste Ziehung: ", myGuildTextColor, "24.11.2024")
        -- elseif ( ld.month == 11 and ld.day >= 24 ) or ( ld.month == 12 and ld.day <= 29 ) then
        --     Ziehung = string.format("%s|c%s%s|r", "nächste Ziehung: ", myGuildTextColor, "29.12.2024")
        -- end
        -- -- DsRGuildInfoLotterieZiehung:SetText(zo_strformat("<<1>>", Ziehung))
        -- DsRGuildInfoLotterieZiehung:SetText(zo_strformat("<<1>>", string.format("%s|c%s%s|r", "nächste Ziehung: ", myGuildTextColor, "-")))

-- Loskauf  
        -- Loskauf  = string.format("|c%s%s|r|c%s%s|r", "FF0000", "Aktuell keine Lose kaufbar!!!!!! ", myGuildTextColor, "")
        -- -- Loskauf  = string.format("|c%s%s|r|c%s%s|r", "999999", "Max. kaufbare Lose pro Spieler: ", myGuildTextColor, "1")
        -- Loskauf1 = string.format("|c%s%s|r|c%s%s|r", "999999", "Preis pro Los: ", myGuildTextColor, "0 Gold")
        -- Loskauf2 = string.format("|c%s%s|r|c%s%s|r", "999999", "Kaufanleitung siehe Discordchannel: ", myGuildTextColor, "#lotterie")
        -- DsRGuildInfoLotterieLoskauf:SetText(zo_strformat("<<1>>", Loskauf))
        -- DsRGuildInfoLotterieLoskauf1:SetText(zo_strformat("<<1>>", Loskauf1))
        -- DsRGuildInfoLotterieLoskauf2:SetText(zo_strformat("<<1>>", Loskauf2))
-- Events
        EventInfo   = string.format("|c%s%s|r", "999999", "( nähere Infos siehe Discordchannel: |cFFD700#angebote-events|r |c999999 )|r")
        DsRGuildInfoEventInfo:SetText(zo_strformat("<<1>>", EventInfo))

        DsRGuildInfo.EventTXTload()
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- load Event-TXT
function DsRGuildInfo.EventTXTload()
    local myGuildTextColor       = "FFD700"
    local myGuildEventColor      = "C1FFC1"
    local myGuildEventStartColor = "CAFF70"
    local myGuildEventEndColor   = "F08080"
-- Event 1
    Event1name  = "Gildentreffen Nürnberg"
    Event1      = string.format("|c%s%s|r", myGuildEventColor, Event1name)
    Event1Start = string.format("%s|c%s%s|r", "Start: ", myGuildEventStartColor, "18.04.26")
    Event1Ende  = string.format("%s|c%s%s|r", "Ende: ", myGuildEventEndColor,   "19.04.26")
    if Event1name ~= "" then
        DsRGuildInfoEvent1:SetText(zo_strformat("<<1>>", Event1))
        DsRGuildInfoEvent1Start:SetText(zo_strformat("<<1>>", Event1Start))
        DsRGuildInfoEvent1Ende:SetText(zo_strformat("<<1>>", Event1Ende))
    end
-- Event 2
    -- Event2name  = "Gildentreffen Nürnberg"
    -- Event2      = string.format("|c%s%s|r", myGuildEventColor, Event2name)
    -- Event2Start = string.format("%s|c%s%s|r", "Start: ", myGuildEventStartColor, "26.04.2025")
    -- Event2Ende  = string.format("%s|c%s%s|r", "Ende: ", myGuildEventEndColor,   "27.04.2025")
    -- if Event2name ~= "" then
    --     DsRGuildInfoEvent2:SetText(zo_strformat("<<1>>", Event2))
    --     DsRGuildInfoEvent2Start:SetText(zo_strformat("<<1>>", Event2Start))
    --     DsRGuildInfoEvent2Ende:SetText(zo_strformat("<<1>>", Event2Ende))
    -- end
-- Event 3  
    -- Event3name  = "FKK-Dungeon"
    -- Event3      = string.format("|c%s%s|r", myGuildEventColor, Event3name)
    -- Event3Start = string.format("%s|c%s%s|r", "Start: ", myGuildEventStartColor, "27.09.2025")
    -- Event3Ende  = string.format("%s|c%s%s|r", "Ende: ", myGuildEventEndColor,   "27.09.2025")
    -- if Event3name ~= "" then
    --     DsRGuildInfoEvent3:SetText(zo_strformat("<<1>>", Event3))
    --     DsRGuildInfoEvent3Start:SetText(zo_strformat("<<1>>", Event3Start))
    --     DsRGuildInfoEvent3Ende:SetText(zo_strformat("<<1>>", Event3Ende))
    -- end
-- Event 4 
    -- Event4name  = "Rabencaching"
    -- Event4      = string.format("|c%s%s|r", myGuildEventColor, Event4name)
    -- Event4Start = string.format("%s|c%s%s|r", "Start: ", myGuildEventStartColor, "-")
    -- Event4Ende  = string.format("%s|c%s%s|r", "Ende: ", myGuildEventEndColor,   "-")
    -- if Event4name ~= "" then
    --     DsRGuildInfoEvent4:SetText(zo_strformat("<<1>>", Event4))
    --     DsRGuildInfoEvent4Start:SetText(zo_strformat("<<1>>", Event4Start))
    --     DsRGuildInfoEvent4Ende:SetText(zo_strformat("<<1>>", Event4Ende))
    -- end
-- Event 5 
    -- Event5name  = "Fashion"
    -- Event5      = string.format("|c%s%s|r", myGuildEventColor, Event5name)
    -- Event5Start = string.format("%s|c%s%s|r", "Start: ", myGuildEventStartColor, "08.12.2024")
    -- Event5Ende  = string.format("%s|c%s%s|r", "Ende: ", myGuildEventEndColor,   "08.12.2024")
    -- if Event5name ~= "" then
    --     DsRGuildInfoEvent5:SetText(zo_strformat("<<1>>", Event5))
    --     DsRGuildInfoEvent5Start:SetText(zo_strformat("<<1>>", Event5Start))
    --     DsRGuildInfoEvent5Ende:SetText(zo_strformat("<<1>>", Event5Ende))
    -- end
-- Event 6 
    -- Event6name  = "Weihnachten"
    -- Event6      = string.format("|c%s%s|r", myGuildEventColor, Event6name)
    -- Event6Start = string.format("%s|c%s%s|r", "Start: ", myGuildEventStartColor, "01.12.2024")
    -- Event6Ende  = string.format("%s|c%s%s|r", "Ende: ", myGuildEventEndColor,   "24.12.2024")
    -- if Event6name ~= "" then
    --     DsRGuildInfoEvent6:SetText(zo_strformat("<<1>>", Event6))
    --     DsRGuildInfoEvent6Start:SetText(zo_strformat("<<1>>", Event6Start))
    --     DsRGuildInfoEvent6Ende:SetText(zo_strformat("<<1>>", Event6Ende))
    -- end
-- Event 7 
    -- Event7name  = ""
    -- Event7      = string.format("|c%s%s|r", myGuildEventColor, Event7name)
    -- Event7Start = string.format("%s|c%s%s|r", "Start: ", myGuildEventStartColor, "xxx")
    -- Event7Ende  = string.format("%s|c%s%s|r", "Ende: ", myGuildEventEndColor,   "xxx")
    -- if Event7name ~= "" then
    --     DsRGuildInfoEvent7:SetText(zo_strformat("<<1>>", Event7))
    --     DsRGuildInfoEvent7Start:SetText(zo_strformat("<<1>>", Event7Start))
    --     DsRGuildInfoEvent7Ende:SetText(zo_strformat("<<1>>", Event7Ende))
    -- end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Change guild
function DsRGuildInfo.OnGuildIdChanged(guild_roster_manager)
    local guildId   = GUILD_ROSTER_MANAGER:GetGuildId()
    local guildName = GetGuildName(guildId)

    if not guild_roster_manager then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, zo_strformat(gettext.gettext("Can’t identify the guild hall yet")))
        return
    end
    if not guildId then
        return
    end
    
    DsRGuildInfo.Check()
end
