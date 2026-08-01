-- Create namespace
DsRGuildRaid = {}

local ld = os.date("*t")

local myGuildTextColor      = "FFD700"
local myGuildRaidColor      = "C1FFC1"
local myGuildRaidStartColor = "CAFF70"
local myGuildRaidEndColor   = "F08080"
local myGuildPvPColor       = "C1FFC1"
local myGuildPvPStartColor  = "CAFF70"
local myGuildPvPEndColor    = "F08080"

-------------------------------------------------------------------------------------------------------------------------------------------------
----- Check first guild and frame
function DsRGuildRaid.Check()
    local guildId   = GUILD_ROSTER_MANAGER:GetGuildId()
    local guildName = GetGuildName(guildId)

    if guildName ~= "Die sieben Raben" then
        DsRGuildRaidInformations:SetHidden(true)
    else
        DsRGuildRaidInformations:SetHidden(false) 
-- Raid / PvP DC channel
        RaidInfo   = string.format("|c%s%s|r", "999999", "( Infos und Anmeldung siehe entspr. Discord Raid-Channel )|r")
        DsRGuildRaidTXTInfo:SetText(zo_strformat("<<1>>", RaidInfo))
		
        PvPInfo   = string.format("|c%s%s|r", "999999", "( Infos und Anmeldung siehe entspr. Discord PvP-Channel )|r")
        DsRGuildPvPTXTInfo:SetText(zo_strformat("<<1>>", PvPInfo))

        DsRGuildRaid.RaidTXTload()
        DsRGuildRaid.PvPTXTload()
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- load Raid-TXT
function DsRGuildRaid.RaidTXTload()
 -- Dienstag Anfänger
    Raid1date        = DsRGuildRaid.FindDate(GetString(DsR_Di)) or ""
    Raid1name        = "Dienstag (Anfänger)"
    Raid1            = string.format("|c%s%s|r", myGuildRaidColor, Raid1name)
    Raid1Start       = string.format("|c%s%s|r", myGuildRaidStartColor, "20:00 - 22:00")
    local Raid1Place = DsRGuildRaid.Raidplace(Raid1name)
    Raid1Ort         = string.format("|c%s%s|r", myGuildRaidEndColor, Raid1Place)
    DsRGuildRaidDienstag:SetText(zo_strformat("<<1>>", Raid1))
    DsRGuildRaidDienstagTXT:SetText(zo_strformat("<<1>>", Raid1Start))
    DsRGuildRaidDienstagOrt:SetText(zo_strformat("<<1>>", Raid1Ort))
 -- Killerkrähen (Mittwoch)
    Raid2date       = DsRGuildRaid.FindDate(GetString(DsR_Mi)) or ""
    Raid2name       = "Mittwoch (Killerkrähen)"
    Raid2           = string.format("|c%s%s|r", myGuildRaidColor, Raid2name)
    Raid2Start      = string.format("|c%s%s|r", myGuildRaidStartColor, "20:15 - 22:15")
    Raid2Ort        = string.format("|c%s%s|r", myGuildRaidEndColor, "Sämtliche Hardmodes")
    DsRGuildRaidKillerkraehen:SetText(zo_strformat("<<1>>", Raid2))
    DsRGuildRaidKillerkraehenTXT:SetText(zo_strformat("<<1>>", Raid2Start))
    DsRGuildRaidKillerkraehenOrt:SetText(zo_strformat("<<1>>", Raid2Ort))
 -- Freitag VET 
    Raid3date        = DsRGuildRaid.FindDate(GetString(DsR_Fr)) or ""
    Raid3name        = "Freitag (VET)"
    Raid3            = string.format("|c%s%s|r", myGuildRaidColor, Raid3name)
    Raid3Start       = string.format("|c%s%s|r", myGuildRaidStartColor, "20:30 - 22:30")
    local Raid3Place = DsRGuildRaid.Raidplace(Raid3name)
    Raid3Ort         = string.format("|c%s%s|r", myGuildRaidEndColor, Raid3Place)
    DsRGuildRaidFreitag:SetText(zo_strformat("<<1>>", Raid3))
    DsRGuildRaidFreitagTXT:SetText(zo_strformat("<<1>>", Raid3Start))
    DsRGuildRaidFreitagOrt:SetText(zo_strformat("<<1>>", Raid3Ort))
 -- Samstag Anfänger
    Raid4date        = DsRGuildRaid.FindDate(GetString(DsR_Sa)) or ""
    Raid4name        = "Samstag (Anfänger)"
    Raid4            = string.format("|c%s%s|r", myGuildRaidColor, Raid4name)
    Raid4Start       = string.format("|c%s%s|r", myGuildRaidStartColor, "16:00 - 18:00")
    local Raid4Place = DsRGuildRaid.Raidplace(Raid4name)
    Raid4Ort         = string.format("|c%s%s|r", myGuildRaidEndColor, Raid4Place)
    DsRGuildRaidSamstagAnf:SetText(zo_strformat("<<1>>", Raid4))
    DsRGuildRaidSamstagAnfTXT:SetText(zo_strformat("<<1>>", Raid4Start))
    DsRGuildRaidSamstagAnfOrt:SetText(zo_strformat("<<1>>", Raid4Ort))
 -- Samstag Hardmode
    Raid5date        = DsRGuildRaid.FindDate(GetString(DsR_Sa)) or ""
    Raid5name        = "Samstag (VET)"
    Raid5            = string.format("|c%s%s|r", myGuildRaidColor, Raid5name)
    Raid5Start       = string.format("|c%s%s|r", myGuildRaidStartColor, "20:30 - Open")
    local Raid5Place = DsRGuildRaid.Raidplace(Raid5name)
    Raid5Ort         = string.format("|c%s%s|r", myGuildRaidEndColor, Raid5Place)
    DsRGuildRaidSamstagHard:SetText(zo_strformat("<<1>>", Raid5))
    DsRGuildRaidSamstagHardTXT:SetText(zo_strformat("<<1>>", Raid5Start))
    DsRGuildRaidSamstagHardOrt:SetText(zo_strformat("<<1>>", Raid5Ort))
 -- Killerküken (Mittwoch)
    Raid6date        = DsRGuildRaid.FindDate(GetString(DsR_Mi)) or ""
    Raid6name        = "Mittwoch (Killerküken)"
    Raid6            = string.format("|c%s%s|r", myGuildRaidColor, Raid6name)
    Raid6Start       = string.format("|c%s%s|r", myGuildRaidStartColor, "20:00 - 22:00")
    local Raid6Place = DsRGuildRaid.Raidplace(Raid6name)
    Raid6Ort         = string.format("|c%s%s|r", myGuildRaidEndColor, Raid6Place)
    DsRGuildRaidMittwoch:SetText(zo_strformat("<<1>>", Raid6))
    DsRGuildRaidMittwochTXT:SetText(zo_strformat("<<1>>", Raid6Start))
    DsRGuildRaidMittwochOrt:SetText(zo_strformat("<<1>>", Raid6Ort))
 -- Killerkrähen (Freitag)
    Raid7date       = DsRGuildRaid.FindDate(GetString(DsR_Fr)) or ""
    Raid7name       = "Freitag (Killerkrähen)"
    Raid7           = string.format("|c%s%s|r", myGuildRaidColor, Raid7name)
    Raid7Start      = string.format("|c%s%s|r", myGuildRaidStartColor, "18:00 - 20:00")
    Raid7Ort        = string.format("|c%s%s|r", myGuildRaidEndColor, "Sämtliche Hardmodes")
    DsRGuildRaidKillerkraehenFR:SetText(zo_strformat("<<1>>", Raid7))
    DsRGuildRaidKillerkraehenFRTXT:SetText(zo_strformat("<<1>>", Raid7Start))
    DsRGuildRaidKillerkraehenFROrt:SetText(zo_strformat("<<1>>", Raid7Ort))
end

-------------------------------------------------------------------------------------------------------------------------------------------------
----- load PvP-TXT
function DsRGuildRaid.PvPTXTload()
 -- Sonntag
    PvP1date       = DsRGuildRaid.FindDate(GetString(DsR_So)) or ""
    PvP1name       = "Sonntag"
    PvP1           = string.format("|c%s%s|r", myGuildPvPColor, PvP1name)
    PvP1Start      = string.format("|c%s%s|r", myGuildPvPStartColor, "11:00 - 13:00")
    PvP1Ort        = string.format("|c%s%s|r", myGuildPvPEndColor, "Molag Bal (" .. zo_iconFormat("/esoui/art/ava/ava_hud_emblem_ebonheart.dds", 20, 20) .. "Ebenerz, mit CP)")
    DsRGuildPvP1:SetText(zo_strformat("<<1>>", PvP1))
    DsRGuildPvP1Start:SetText(zo_strformat("<<1>>", PvP1Start))
    DsRGuildPvP1Ort:SetText(zo_strformat("<<1>>", PvP1Ort))
 -- Montag
    PvP2date       = DsRGuildRaid.FindDate(GetString(DsR_Mo)) or ""
    PvP2name       = "Montag"
    PvP2           = string.format("|c%s%s|r", myGuildPvPColor, PvP2name)
    PvP2Start      = string.format("|c%s%s|r", myGuildPvPStartColor, "19:00 - 22:00")
    PvP2Ort        = string.format("|c%s%s|r", myGuildPvPEndColor, "Cyrodiil (".. zo_iconFormat("/esoui/art/ava/ava_hud_emblem_ebonheart.dds", 20, 20) .. "Ebenerz)")
    DsRGuildPvP2:SetText(zo_strformat("<<1>>", PvP2))
    DsRGuildPvP2Start:SetText(zo_strformat("<<1>>", PvP2Start))
    DsRGuildPvP2Ort:SetText(zo_strformat("<<1>>", PvP2Ort))
end

-------------------------------------------------------------------------------------------------------------------------------------------------
----- load Raidplaces
function DsRGuildRaid.Raidplace( name )
-- Dienstag (Anfänger)
    if name == "Dienstag (Anfänger)" then
        if ld.month == 1 then
            return GetString(DsR_HelRa) .. " & " .. GetString(DsR_AA) .. " & " .. GetString(DsR_Sanctum)
        elseif ld.month == 2 then
            return GetString(DsR_Schlund) .. " & " .. GetString(DsR_Sonnenspitz)
        elseif ld.month == 3 then
            return GetString(DsR_Wolkenruh) .. " & " .. GetString(DsR_HoF)
        elseif ld.month == 4 then
            return GetString(DsR_Anstalt) .. " & " .. GetString(DsR_Grauensegel)
        elseif ld.month == 5 then
            return GetString(DsR_Fels) .. " & " .. GetString(DsR_Wahnsinn)
        elseif ld.month == 6 then
            return GetString(DsR_Luminit) .. " & " .. GetString(DsR_Gebein)
        elseif ld.month == 7 then
            return "RAIDPAUSE"
        elseif ld.month == 8 then
            return "RAIDPAUSE"
        elseif ld.month == 9 then
            return GetString(DsR_Wolkenruh) .. " & " .. GetString(DsR_Grauensegel)
        elseif ld.month == 10 then
            return GetString(DsR_Wahnsinn) .. " & " .. GetString(DsR_Luminit)
        elseif ld.month == 11 then
            return GetString(DsR_Sonnenspitz) .. " & " .. GetString(DsR_Gebein)
        elseif ld.month == 12 then
            return "Wunschraid, siehe Discord"
        end
-- Killerküken (Mittwoch)
    elseif name == "Mittwoch (Killerküken)" then
            return "siehe Discord"

-- Freitag (Vet)
    elseif name == "Freitag (VET)" then
        if ld.month == 7 then
            return "RAIDPAUSE"
        elseif ld.month == 8 then
            return "RAIDPAUSE"
        else
            return "siehe Discord"
        end
-- Samstag (Anfänger)
    elseif name == "Samstag (Anfänger)" then
        if ld.month == 1 then
            return GetString(DsR_HelRa) .. " & " .. GetString(DsR_AA) .. " & " .. GetString(DsR_Sanctum)
        elseif ld.month == 2 then
            return GetString(DsR_Schlund) .. " & " .. GetString(DsR_Sonnenspitz)
        elseif ld.month == 3 then
            return GetString(DsR_Wolkenruh) .. " & " .. GetString(DsR_HoF)
        elseif ld.month == 4 then
            return GetString(DsR_Anstalt) .. " & " .. GetString(DsR_Grauensegel)
        elseif ld.month == 5 then
            return GetString(DsR_Fels) .. " & " .. GetString(DsR_Wahnsinn)
        elseif ld.month == 6 then
            return GetString(DsR_Luminit) .. " & " .. GetString(DsR_Gebein)
        elseif ld.month == 7 then
            return "RAIDPAUSE"
        elseif ld.month == 8 then
            return "RAIDPAUSE"
        elseif ld.month == 9 then
            return GetString(DsR_Wolkenruh) .. " & " .. GetString(DsR_Grauensegel)
        elseif ld.month == 10 then
            return GetString(DsR_Wahnsinn) .. " & " .. GetString(DsR_Luminit)
        elseif ld.month == 11 then
            return GetString(DsR_Sonnenspitz) .. " & " .. GetString(DsR_Gebein)
        elseif ld.month == 12 then
            return "Wunschraid, siehe Discord"
        end
-- Samstag (Vet Hardmode)
    elseif name == "Samstag (VET)" then
        if ld.month == 1 then
            return GetString(DsR_Fels)
        elseif ld.month == 2 then
            return GetString(DsR_Schlund)
        elseif ld.month == 3 then
            return GetString(DsR_Wolkenruh)
        elseif ld.month == 4 then
            return GetString(DsR_Anstalt)
        elseif ld.month == 5 then
            return GetString(DsR_Wahnsinn)
        elseif ld.month == 6 then
            return GetString(DsR_Gebein)
        elseif ld.month == 7 then
            return "RAIDPAUSE"
        elseif ld.month == 8 then
            return "RAIDPAUSE"
        elseif ld.month == 9 then
            return GetString(DsR_Grauensegel)
        elseif ld.month == 10 then
            return GetString(DsR_Luminit)
        elseif ld.month == 11 then
            return GetString(DsR_Sonnenspitz)
        elseif ld.month == 12 then
            return "Wunschraid, siehe Discord"
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
----- find date
function DsRGuildRaid.FindDate( name )
    local ld    = os.date("*t")
    if string.len(ld.day) < 2 and string.len(ld.month) > 1 then
        ActDate = string.format("0%s-%s-%s", ld.day, ld.month, ld.year)
    elseif string.len(ld.day) < 2 and string.len(ld.month) < 2 then
        ActDate = string.format("0%s-0%s-%s", ld.day, ld.month, ld.year)
    elseif string.len(ld.day) > 1 and string.len(ld.month) < 2 then
        ActDate = string.format("%s-0%s-%s", ld.day, ld.month, ld.year)
    else
        ActDate = string.format("%s-%s-%s", ld.day, ld.month, ld.year)
    end

    local dayValue, monthValue, yearValue = string.match(zo_strformat("<<1>>", ActDate), '(%d%d)-(%d%d)-(%d%d%d%d)')
    dayValue, monthValue, yearValue = tonumber(dayValue), tonumber(monthValue), tonumber(yearValue)
    now = os.time{year = yearValue, month = monthValue, day = dayValue}

    if os.date('%A', now) == name then
        local newDate = os.date('%x', now)
        return newDate
    else  
        for i = 1, 9 do
            if os.date('%A', now+24*3600*i) == name then
                local newDate = os.date('%x', now+24*3600*i)
                return newDate
            end
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
----- INV Button's
function DsRGuildRaid.OnClickedINVon(self, control)
    local guildIndex = nil
    for i = 1, 5 do
        local guildId    = GetGuildId(i)
        local guildName  = GetGuildName(guildId)
        if guildName == "Die sieben Raben" then
            guildIndex = i
        end
    end

    DAYcheck  = os.date("%x")
    TIMEcheck = os.date("%X")

    CheckDate1 = Raid1date
    CheckDate2 = Raid2date
    CheckDate3 = Raid3date
    CheckDate4 = Raid4date
    CheckDate5 = Raid5date
    CheckDate6 = PvP1date
    CheckDate7 = PvP2date
    CheckDate8 = Raid6date

-- Montag
    if zo_strmatch(PvP2date , DAYcheck) then
        Ort      = "Cyrodiil (Ebenerz)"
        EinlText = "Auf geht's edle Krieger. Die Einladung nach ''"
-- Dienstag
    elseif zo_strmatch(CheckDate1 , DAYcheck) then
        Ort      = DsRGuildRaidDienstagOrt:GetText()
        EinlText = "Die Einladung zum Raid nach ''"
        OrtSub   = zo_strsub(Ort , 9 , 100)
        Ort      = zo_strgsub(OrtSub , "|r" , "" )
-- Mittwoch
    elseif zo_strmatch(CheckDate8 , DAYcheck) then
        Ort      = DsRGuildRaidMittwochOrt:GetText()
        EinlText = "Die Einladung zum geschlossenen Farmraid "
        OrtSub   = zo_strsub(Ort , 9 , 100)
        Ort      = ""
-- Freitag
    elseif zo_strmatch(CheckDate3 , DAYcheck) then
        Ort      = DsRGuildRaidFreitagOrt:GetText()
        EinlText = "Die Einladung zum Raid ''"
        OrtSub   = zo_strsub(Ort , 9 , 100)
        Ort      = zo_strgsub(OrtSub , "|r" , "" )
-- Samstag
    elseif zo_strmatch(CheckDate4 , DAYcheck) or zo_strmatch(CheckDate5 , DAYcheck) then
        if TIMEcheck <= "17:00" then
            Ort = DsRGuildRaidSamstagAnfOrt:GetText()
        elseif TIMEcheck >= "18:01" then
            Ort = DsRGuildRaidSamstagHardOrt:GetText()
        end
        EinlText = "Die Einladung zum Raid ''"
        OrtSub   = zo_strsub(Ort , 9 , 100)
        Ort      = zo_strgsub(OrtSub , "|r" , "" )
-- Sonntag
    elseif zo_strmatch(PvP1date , DAYcheck) then
        Ort      = "Molag Bal (Ebenerz, mit CP)"
        EinlText = "Auf geht's edle Krieger. Die Einladung zu ''"
    end

    DsRAutoINV.startListening()
    DsRAutoINVUI.refresh()

    local channel = string.format("%s%s", "/guild", guildIndex)
    if EinlText ~= nil then
        local splittedText = {zo_strsplit(";" , DsRAutoINV.cfg.watchStr)}
        local outputtext   = ""
        if zo_strmatch(PvP2date , DAYcheck) then
            outputtext = string.format("%s%s%s%s%s", EinlText , Ort , "'' startet. Ein >> ", "KRAH (Stammgruppe)"," << für die Gruppeneinladung")
        else
            outputtext = string.format("%s%s%s%s%s", EinlText , Ort , "'' startet. Ein >> ", zo_strupper(splittedText[1]) , " << für die Gruppeneinladung")
        end
        CHAT_SYSTEM:Maximize()
        CHAT_SYSTEM.textEntry:InsertLink( channel )
        CHAT_SYSTEM.textEntry:InsertLink( " " .. outputtext )
        CHAT_SYSTEM.textEntry:Open() CHAT_SYSTEM.textEntry:FadeIn()
    end
end

function DsRGuildRaid.OnClickedINVoff(self, control)
    local function echo(msg) CHAT_ROUTER:AddSystemMessage("|CFFFF00" .. msg) end

    DsRAutoINV.stopListening()
    DsRAutoINVUI.refresh()
    echo(zo_strformat(GetString(SI_DsRAI_OFF)))
end

-------------------------------------------------------------------------------------------------------------------------------------------------
----- Change guild
function DsRGuildRaid.OnGuildIdChanged(guild_roster_manager)
    local guildId   = GUILD_ROSTER_MANAGER:GetGuildId()
    local guildName = GetGuildName(guildId)

    if not guild_roster_manager then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, zo_strformat(gettext.gettext("Can’t identify the guild hall yet")))
        return
    end
    if not guildId then
        return
    end
	
    DsRGuildRaid.Check()
end
