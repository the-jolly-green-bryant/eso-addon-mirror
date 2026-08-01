-- Create namespace
DsRGuildAdmin = {}

-------------------------------------------------------------------------------------------------------------------------------------------------
----- Check first
function DsRGuildAdmin.Check()
    local player    = GetDisplayName()
    local guildId   = GUILD_ROSTER_MANAGER:GetGuildId()
    local guildName = GetGuildName(guildId)
    
    if guildName == "Die sieben Raben" then
        for k,v in pairs(DsRglobals.GuildLeader) do
            if player == v then
            -- if player == "@Hasenwarrior" or player == "@flo1980" or player == "@PettiPuuh" or player == "@Siraa" or player == "@Sisiktil" or player == "@Magnolyon" or player == "@Prof_Flausch" or player == "@Ravnic93" then
                DsRGuildAdminPanel:SetHidden(false)
            else
                DsRGuildAdminPanel:SetHidden(true)
            end
        end
        DsRGuildSettingPanel:SetHidden(false)
    else
        DsRGuildAdminPanel:SetHidden(true)
        DsRGuildSettingPanel:SetHidden(true)
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Change guild
function DsRGuildAdmin.OnGuildIdChanged(guild_roster_manager)
    local player    = GetDisplayName()
    local guildId   = GUILD_ROSTER_MANAGER:GetGuildId()
    local guildName = GetGuildName(guildId)
    
    if not guild_roster_manager then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, zo_strformat(gettext.gettext("Can’t identify the guild hall yet")))
        return
    end
    if not guildId then
        return
    end
  
    if guildName == "Die sieben Raben" then
    --     for k,v in pairs(DsRglobals.GuildLeader) do
    --         if player == v then
            if player == "@Hasenwarrior" or player == "@PettiPuuh" or player == "@flo1980" or player == "@Magnolyon" or player == "@Prof_Flausch" or player == "@Ravnic93" then
                DsRGuildAdminPanel:SetHidden(false)
            else
                DsRGuildAdminPanel:SetHidden(true)
            end
    --     end
        DsRGuildSettingPanel:SetHidden(false)
    else
        DsRGuildAdminPanel:SetHidden(true)
        DsRGuildSettingPanel:SetHidden(true)
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
----- Erinnerungen

-- Discord
function DsRGuildAdmin.OnClickedDiscord(self,button)
	local guildIndex = nil
    for i = 1, 5 do
        local guildId    = GetGuildId(i)
        local guildName  = GetGuildName(guildId)
        if guildName == "Die sieben Raben" then
            guildIndex = i
        end
    end

	local channel = string.format("%s%s", "/guild", guildIndex)
	local outputtext = string.format("%s", "Hallo ihr Raben! Guckt doch mal auf unserem Discord Server vorbei. Dort findet ihr neben Mitstreitern aus der Gilde auch unsere Eventangebote, wie z.B. unsere geführten Raids oder PvP-Events. Wir freuen uns auf euch! [Server-Link: https://discord.gg/KFEVcZdwzN]")
	-- local outputtext = string.format("%s", "Teilnahme an RabenLotterie: Max. kaufbare Lose pro Spieler -> 1 ----- Preis pro Los -> 50.000 Gold ----- Loskaufanleitung -> Siehe Discordchannel: #lotterie")
	CHAT_SYSTEM:Maximize()
    CHAT_SYSTEM.textEntry:InsertLink( channel )
    CHAT_SYSTEM.textEntry:InsertLink( " " .. outputtext )
	CHAT_SYSTEM.textEntry:Open() CHAT_SYSTEM.textEntry:FadeIn()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Eventerinnerung
function DsRGuildAdmin.OnClickedEventErinnerung(self,button)
    local guildIndex = nil
    for i = 1, 5 do
        local guildId    = GetGuildId(i)
        local guildName  = GetGuildName(guildId)
        if guildName == "Die sieben Raben" then
            guildIndex = i
        end
    end

    local DayACT = os.time{year=os.date("%Y"), month=os.date("%m"), day=os.date("%d")}
    
    local CheckDate1 = zo_strsub(DsRGuildInfoEvent1Start:GetText() , 8 , 25)
    if string.match(zo_strformat("<<1>>", CheckDate1), 'xxx') then
        EventDay1 = os.time{year = 2020, month = 01, day = 01}
    else
        local dayValue1, monthValue1, yearValue1 = string.match(zo_strformat("<<1>>", CheckDate1), '(%d%d).(%d%d).(%d%d%d%d)')
        local dayValue1, monthValue1, yearValue1 = tonumber(dayValue1), tonumber(monthValue1), tonumber(yearValue1)
        EventDay1 = os.time{year = yearValue1, month = monthValue1, day = dayValue1}
    end

    local CheckDate2 = zo_strsub(DsRGuildInfoEvent2Start:GetText() , 8 , 25)
    if string.match(zo_strformat("<<1>>", CheckDate2), 'xxx') then
        EventDay2 = os.time{year = 2020, month = 01, day = 01}
    else
        local dayValue2, monthValue2, yearValue2 = string.match(zo_strformat("<<1>>", CheckDate2), '(%d%d).(%d%d).(%d%d%d%d)')
        local dayValue2, monthValue2, yearValue2 = tonumber(dayValue2), tonumber(monthValue2), tonumber(yearValue2)
        EventDay2 = os.time{year = yearValue2, month = monthValue2, day = dayValue2}
    end

    local CheckDate3 = zo_strsub(DsRGuildInfoEvent3Start:GetText() , 8 , 25)
    if string.match(zo_strformat("<<1>>", CheckDate3), 'xxx') then
        EventDay3 = os.time{year = 2020, month = 01, day = 01}
    else
        local dayValue3, monthValue3, yearValue3 = string.match(zo_strformat("<<1>>", CheckDate3), '(%d%d).(%d%d).(%d%d%d%d)')
        local dayValue3, monthValue3, yearValue3 = tonumber(dayValue3), tonumber(monthValue3), tonumber(yearValue3)
        EventDay3 = os.time{year = yearValue3, month = monthValue3, day = dayValue3}
    end

    local CheckDate4 = zo_strsub(DsRGuildInfoEvent4Start:GetText() , 8 , 25)
    if string.match(zo_strformat("<<1>>", CheckDate4), 'xxx') then
        EventDay4 = os.time{year = 2020, month = 01, day = 01}
    else
        local dayValue4, monthValue4, yearValue4 = string.match(zo_strformat("<<1>>", CheckDate4), '(%d%d).(%d%d).(%d%d%d%d)')
        local dayValue4, monthValue4, yearValue4 = tonumber(dayValue4), tonumber(monthValue4), tonumber(yearValue4)
        EventDay4 = os.time{year = yearValue4, month = monthValue4, day = dayValue4}
    end
    local CheckDate5 = zo_strsub(DsRGuildInfoEvent5Start:GetText() , 8 , 25)
    if string.match(zo_strformat("<<1>>", CheckDate5), 'xxx') then
        EventDay5 = os.time{year = 2020, month = 01, day = 01}
    else
        local dayValue5, monthValue5, yearValue5 = string.match(zo_strformat("<<1>>", CheckDate5), '(%d%d).(%d%d).(%d%d%d%d)')
        local dayValue5, monthValue5, yearValue5 = tonumber(dayValue5), tonumber(monthValue5), tonumber(yearValue5)
        EventDay5 = os.time{year = yearValue5, month = monthValue5, day = dayValue5}
    end

    local CheckDate6 = zo_strsub(DsRGuildInfoEvent6Start:GetText() , 8 , 25)
    if string.match(zo_strformat("<<1>>", CheckDate6), 'xxx') then
        EventDay6 = os.time{year = 2020, month = 01, day = 01}
    else
        local dayValue6, monthValue6, yearValue6 = string.match(zo_strformat("<<1>>", CheckDate6), '(%d%d).(%d%d).(%d%d%d%d)')
        local dayValue6, monthValue6, yearValue6 = tonumber(dayValue6), tonumber(monthValue6), tonumber(yearValue6)
        EventDay6 = os.time{year = yearValue6, month = monthValue6, day = dayValue6}
    end

    local CheckDate7 = zo_strsub(DsRGuildInfoEvent7Start:GetText() , 8 , 25)
    if string.match(zo_strformat("<<1>>", CheckDate7), 'xxx') then
        EventDay7 = os.time{year = 2020, month = 01, day = 01}
    else
        local dayValue7, monthValue7, yearValue7 = string.match(zo_strformat("<<1>>", CheckDate7), '(%d%d).(%d%d).(%d%d%d%d)')
        local dayValue7, monthValue7, yearValue7 = tonumber(dayValue7), tonumber(monthValue7), tonumber(yearValue7)
        EventDay7 = os.time{year = yearValue7, month = monthValue7, day = dayValue7}
    end

    if DayACT <= EventDay1 then
        Eventname = DsRGuildInfoEvent1:GetText()
    elseif DayACT >= EventDay1 and DayACT <= EventDay2 then
        Eventname = DsRGuildInfoEvent2:GetText()
    elseif DayACT >= EventDay2 and DayACT <= EventDay3 then
        Eventname = DsRGuildInfoEvent3:GetText()
    elseif DayACT >= EventDay3 and DayACT <= EventDay4 then
        Eventname = DsRGuildInfoEvent4:GetText()
    elseif DayACT >= EventDay4 and DayACT <= EventDay5 then
        Eventname = DsRGuildInfoEvent5:GetText()
    elseif DayACT >= EventDay5 and DayACT <= EventDay6 then
        Eventname = DsRGuildInfoEvent6:GetText()
    elseif DayACT >= EventDay6 and DayACT <= EventDay7 then
        Eventname = DsRGuildInfoEvent7:GetText()
    else
        Eventname = "-"
    end

    if Eventname ~= "-" then
        local channel    = string.format("%s%s", "/guild", guildIndex)
        local outputtext = string.format("%s%s%s", "Bald ist es soweit! Das Gildenevent ''", Eventname, "'' startet demnächst. Was ihr tun müsst bzw. um was es geht, kannst Du jetzt / bald im entsprechenden DC-Channel #angebote-events sehen.")
        CHAT_SYSTEM:Maximize()
        CHAT_SYSTEM.textEntry:InsertLink( channel )
        CHAT_SYSTEM.textEntry:InsertLink( " " .. outputtext )
        CHAT_SYSTEM.textEntry:Open() CHAT_SYSTEM.textEntry:FadeIn()
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Händler
function DsRGuildAdmin.OnClickedHaendler(self,button)
    local guildId = GUILD_ROSTER_MANAGER:GetGuildId()
    local traderName = GetGuildOwnedKioskInfo(guildId)
    traderName = zo_strformat(SI_GUILD_HIRED_TRADER, traderName)
 
	local guildIndex = nil
    for i = 1, 5 do
        local guildId    = GetGuildId(i)
        local guildName  = GetGuildName(guildId)
        if guildName == "Die sieben Raben" then
            guildIndex = i
        end
    end

	local channel =    string.format("%s%s", "/guild", guildIndex)
	local outputtext = string.format("%s%s%s", "Unser Händler in dieser Woche: ", traderName, "......Füllt eure Plätze auf!! -> Kleiner Tipp: Setzt immer den Verkaufspreis etwas unter den offiziellen Preisen. So verkauft ihr mehr und schneller.")
	CHAT_SYSTEM:Maximize()
    CHAT_SYSTEM.textEntry:InsertLink( channel )
    CHAT_SYSTEM.textEntry:InsertLink( " " .. outputtext )
	CHAT_SYSTEM.textEntry:Open() CHAT_SYSTEM.textEntry:FadeIn()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Addon
function DsRGuildAdmin.OnClickedAddon(self,button)
	local guildIndex = nil
    for i = 1, 5 do
        local guildId    = GetGuildId(i)
        local guildName  = GetGuildName(guildId)
        if guildName == "Die sieben Raben" then
            guildIndex = i
        end
    end

	local channel = string.format("%s%s", "/guild", guildIndex)
	local outputtext = string.format("%s", "UNSER GILDENADDON: >> DsR GuildRoster << ... U.a. drin ist: Loot-/Inventar-Manager, Personal Assistant, Unknown Tracker, AutoInvite, PvP-Tools, PreisChecker, Hungergefühl, Rüstungswerkstatt, BuffTracker und was so bei den Raben ansteht seht ihr auch in der Gildenübersicht (Taste 'G')")
	CHAT_SYSTEM:Maximize()
    CHAT_SYSTEM.textEntry:InsertLink( channel )
    CHAT_SYSTEM.textEntry:InsertLink( " " .. outputtext )
	CHAT_SYSTEM.textEntry:Open() CHAT_SYSTEM.textEntry:FadeIn()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Time played overall
function DsRGuildAdmin:PlayedTimeOverall(...)
    Total = 0
    
    d("|cFAA0A0--------------------------------------|r")
    for CharName, _ in pairs( DsRGuildLoot.sV.charplayed) do
        local Second     =  DsRGuildLoot.sV.charplayed[CharName]
        local SecToMin   = zo_floor(Second/60)
        local MinToHou   = zo_floor(SecToMin/60)
        d(CharName .. ": |cFFA500" .. DsRglobals:ThousandNumber(MinToHou) .. " |c9fb6cdStunden|r")
        Total = Total + Second
    end

    local SecToMinTotal   = zo_floor(Total/60)
    local MinToHouTotal   = zo_floor(SecToMinTotal/60)

    CHAT_SYSTEM:Maximize()
    d("|cFAA0A0---------|r")
    d("|c35fc38Gesamt|r:")
    d("|c9fb6cdSekunden:  |r" .. "|cFFA500" .. DsRglobals:ThousandNumber(Total))
    d("|c9fb6cdMinuten:     |r" .. "|cFFA500" .. DsRglobals:ThousandNumber(SecToMinTotal))
    d("|c9fb6cdStunden:     |r" .. "|cFFA500" .. DsRglobals:ThousandNumber(MinToHouTotal))
    d("|cFAA0A0--------------------------------------|r")
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Kick Member
local DsRKickWindow = nil

local function DsR_CreateKickWindow()
    if DsRKickWindow then
        DsRKickWindow:SetHidden(false)
        return DsRKickWindow
    end

    local win = WINDOW_MANAGER:CreateTopLevelWindow("DsRKickWindow")
    win:SetDrawTier(DT_HIGH)
    win:SetDrawLayer(DL_OVERLAY)
    win:SetDrawLevel(9999)

    DsRKickWindow = win

    win:SetDimensions(450, 500)
    win:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    win:SetMovable(true)
    win:SetMouseEnabled(true)
    win:SetHidden(false)

    -- Hintergrund
    local bg = WINDOW_MANAGER:CreateControl(nil, win, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.7)
    bg:SetEdgeColor(1, 1, 1, 0.4)

    -- ScrollContainer
    local scroll = WINDOW_MANAGER:CreateControlFromVirtual("DsRKickScroll", win, "ZO_ScrollContainer")
    scroll:SetAnchor(TOPLEFT, win, TOPLEFT, 10, 10)
    scroll:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -10, -60)
    win.scroll = scroll

    -- Schließen-Button unten
    local closeBtn = WINDOW_MANAGER:CreateControl(nil, win, CT_BUTTON)
    closeBtn:SetDimensions(120, 32)
    closeBtn:SetAnchor(BOTTOM, win, BOTTOM, 0, -10)

    closeBtn:SetText("Schließen")
    closeBtn:SetFont("ZoFontGameBold")
    closeBtn:SetNormalFontColor(1, 1, 1, 1)

    closeBtn:SetHandler("OnClicked", function()
        win:SetHidden(true)
    end)

    return win
end

local function DsR_GetNoteForPlayer(displayName)
    local guildId = GUILD_ROSTER_MANAGER:GetGuildId()
    local num = GetNumGuildMembers(guildId)

    for i = 1, num do
        local name, note = GetGuildMemberInfo(guildId, i)
        if name == displayName then
            return note ~= "" and note or "|cFF0000Keine Notiz vorhanden|r"
        end
    end

    return "Keine Notiz gefunden"
end

local function DsR_AddKickEntry(parent, y, days, name, guildId)
    -- Zeile
    local row = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    row:SetDimensions(420, 30)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, y)
    row:SetMouseEnabled(true)

    ---------------------------------------------------------
    -- Popup als eigenes TopLevelWindow (immer sichtbar)
    ---------------------------------------------------------
    local popup = WINDOW_MANAGER:CreateTopLevelWindow(nil)
    popup:SetDimensions(250, 80)
    popup:SetHidden(true)
    popup:SetMovable(false)
    popup:SetMouseEnabled(false)
    popup:SetDrawTier(DT_HIGH)
    popup:SetDrawLayer(DL_OVERLAY)
    popup:SetDrawLevel(9999)

    local popupBG = WINDOW_MANAGER:CreateControl(nil, popup, CT_BACKDROP)
    popupBG:SetAnchorFill()
    popupBG:SetCenterColor(0, 0, 0, 0.85)
    popupBG:SetEdgeColor(1, 1, 1, 0.4)

    local popupLabel = WINDOW_MANAGER:CreateControl(nil, popup, CT_LABEL)
    popupLabel:SetAnchorFill()
    popupLabel:SetFont("ZoFontGame")
    popupLabel:SetColor(1, 1, 1, 1)
    popupLabel:SetText("")

    ---------------------------------------------------------
    -- Label (Tage + Name)
    ---------------------------------------------------------
    local label = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    label:SetFont("ZoFontGame")
    label:SetText(string.format("|cFF0000%d|r Tage - |c9fb6cd%s|r", days, name))
    label:SetAnchor(LEFT, row, LEFT, 0, 0)
    label:SetMouseEnabled(true)

    row.label = label

    local strike = WINDOW_MANAGER:CreateControl(nil, row, CT_CONTROL)
    strike:SetAnchorFill()
    strike:SetDrawTier(DT_HIGH)
    strike:SetDrawLayer(DL_OVERLAY)
    strike:SetDrawLevel(9999)
    strike:SetHidden(true)

    local strikeLine = WINDOW_MANAGER:CreateControl(nil, strike, CT_TEXTURE)
    strikeLine:SetColor(0, 1, 0, 1)
    strikeLine:SetHeight(2)
    strikeLine:SetAnchor(LEFT, label, LEFT, 0, 0)
    strikeLine:SetAnchor(RIGHT, label, RIGHT, 0, 0)

    row.strike = strike
    
    zo_callLater(function()
        local w = label:GetTextWidth()
        strike:ClearAnchors()
        strike:SetAnchor(LEFT, label, LEFT, 0, 0)
        strike:SetAnchor(RIGHT, label, LEFT, w, 0)
    end, 10)

    ---------------------------------------------------------
    -- Kick‑Button (rot)
    ---------------------------------------------------------
    local btn = WINDOW_MANAGER:CreateControl(nil, row, CT_BUTTON)
    btn:SetDimensions(80, 26)
    btn:SetAnchor(RIGHT, row, RIGHT, -5, 0)

    btn:SetText("Kick")
    btn:SetFont("ZoFontGameBold")
    btn:SetNormalFontColor(1, 0, 0, 1)

    btn:SetHandler("OnClicked", function()
        if row.strike then
            row.strike:SetHidden(false)
        end
        row.label:SetColor(0, 1, 0, 1)

        GuildRemove(guildId, name)
    end)

    ---------------------------------------------------------
    -- Mouseover‑Handler am LABEL
    ---------------------------------------------------------
    label:SetHandler("OnMouseEnter", function()
        popupLabel:SetText(DsR_GetNoteForPlayer(name))

        -- Popup links neben der Zeile positionieren
        local left = row:GetLeft()
        local top  = row:GetTop()

        popup:ClearAnchors()
        popup:SetAnchor(TOPRIGHT, GuiRoot, TOPLEFT, left - 10, top)

        popup:SetHidden(false)
    end)

    label:SetHandler("OnMouseExit", function()
        popup:SetHidden(true)
    end)

    return row
end

local DsRKickRows = {}

local function DsR_ShowKickList(kickTable, guildId)
    local win    = DsR_CreateKickWindow()
    local scroll = win.scroll

    -- vorhandenes ScrollChild benutzen
    local content = scroll:GetNamedChild("ScrollChild")
    if not content then return end

    -- alte Zeilen ausblenden (statt GetChildren zu benutzen)
    for _, row in ipairs(DsRKickRows) do
        if row and row.SetHidden then
            row:SetHidden(true)
        end
    end
    DsRKickRows = {}

    local y = 0
    for _, entry in ipairs(kickTable) do
        local row = DsR_AddKickEntry(content, y, entry.Logoff, entry.name, guildId)
        table.insert(DsRKickRows, row)
        y = y + 35
    end
end


function DsRGuildAdmin:OnClickedKickMember(self,button)
    local KickTable           = {}
    local SearchEhrenRabeNote = ""
    local NoGuildMemOver      = 0

    local player = GetDisplayName()
    for k,v in pairs(DsRglobals.GuildLeader) do
        if player == v then
            local guildId   = GUILD_ROSTER_MANAGER:GetGuildId()
            local guildName = GetGuildName(guildId)

            if guildName == "Die sieben Raben" then
                for i = 1, GetNumGuildMembers(guildId) do
                    local displayName, note, rankIndex, status, secsSinceLogoff = GetGuildMemberInfo(guildId, i)

                    local timeString          = DsRglobals:secondsToString(secsSinceLogoff)
                    local days                = zo_floor((secsSinceLogoff)/86400)
                    local SearchEhrenRabeNote = zo_strmatch(zo_strupper(note) , zo_strupper("Ehrenrabe"))

                    if tonumber(days) > 28 and SearchEhrenRabeNote == nil then
                        table.insert(KickTable, {name = displayName, Logoff = days})
                        NoGuildMemOver = 1
                    end
                end
            end

            table.sort(KickTable, function(a, b) return a.Logoff < b.Logoff end)

            DsR_ShowKickList(KickTable, guildId)

            if NoGuildMemOver == 0 then
                d("|cFF0000" .. "Kein Gildenmember über 28 Tage !!" .. "|r")
            end
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- TEST Func
function DsRGuildAdmin:OnClickedTestFunction(self,button)
    local player    = GetDisplayName()
    if player == "@Hasenwarrior" then
        DsRGuildTestDatei.TESTFUNCTION()
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Sounds
function DsRGuildAdmin:OnClickedSoundFunction(self,button)
    local player = GetDisplayName()
    if player == "@Hasenwarrior" then
        local soundButtons = {}
        local content
        local currentCategory = "ALL"
        local searchText = ""
        local lastClickedButton = nil

        -- automatische Kategorien
        local function GetCategory(soundName)
            -- Emotes
            if soundName:find("EMOTE") then return "Emote" end
        
            -- Victory / Celebration
            if soundName:find("DUEL") then return "Victory" end
            if soundName:find("LEVEL_UP") then return "Victory" end
            if soundName:find("ACHIEVEMENT") then return "Victory" end
            if soundName:find("CHAMPION_POINT") then return "Victory" end
            if soundName:find("CROWN_CRATE") then return "Victory" end
            if soundName:find("COLLECTIBLE") then return "Victory" end
        
            -- Standard-Kategorien
            if soundName:find("^UI_") then return "UI" end
            if soundName:find("^CHAMPION_") then return "Champion" end
            if soundName:find("^CROWN_") then return "Crown" end
            if soundName:find("^MARKET_") then return "Market" end
            if soundName:find("^COLLECTIBLE_") then return "Collectibles" end
            if soundName:find("^CRAFTING_") then return "Crafting" end
            if soundName:find("^GROUP_") then return "Group" end
            if soundName:find("^GUILD_") then return "Guild" end
            if soundName:find("^QUEST_") then return "Quest" end
            if soundName:find("^MAP_") then return "Map" end
            if soundName:find("^SOCIAL_") then return "Social" end
            if soundName:find("^SKILL_") or soundName:find("^ABILITY_") then return "Skill" end
        
            return "Misc"
        end

        -- Liste neu anordnen (keine Leerzeilen!)
        local function DsR_UpdateSoundList()
            local y = 0
            local heightPerRow = 28
            local search = string.lower(searchText or "")
        
            for _, btn in ipairs(soundButtons) do
                local matchCategory = (currentCategory == "ALL" or btn.category == currentCategory)
                local matchSearch = (search == "" or string.find(string.lower(btn.soundName), search, 1, true))
            
                if matchCategory and matchSearch then
                    btn:SetHidden(false)
                    btn:ClearAnchors()
                    btn:SetAnchor(TOPLEFT, content, TOPLEFT, 10, y)
                    y = y + heightPerRow
                else
                    btn:SetHidden(true)
                end
            end
        
            content:SetHeight(y)
        end

        local function DsR_CreateSoundTester()
            if DsRSoundTester then
                DsRSoundTester:SetHidden(false)
                return
            end
        
            -- Fenster
            local wnd = WINDOW_MANAGER:CreateTopLevelWindow("DsRSoundTester")
            wnd:SetDimensions(650, 750)
            wnd:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
            wnd:SetMovable(true)
            wnd:SetMouseEnabled(true)
            wnd:SetClampedToScreen(true)
            DsRSoundTester = wnd
        
            local bg = WINDOW_MANAGER:CreateControl(nil, wnd, CT_BACKDROP)
            bg:SetAnchorFill()
            bg:SetCenterColor(0, 0, 0, 0.7)
            bg:SetEdgeColor(1, 1, 1, 0.4)
        
            -- Kategorien Dropdown
            local categories = {
                "ALL", "UI", "Champion", "Crown", "Market", "Collectibles",
                "Crafting", "Group", "Guild", "Quest", "Map", "Social",
                "Skill", "Emote", "Victory", "Misc"
            }
        
            local dropdown = WINDOW_MANAGER:CreateControlFromVirtual("DsRSoundTesterDropdown", wnd, "ZO_ComboBox")
            dropdown:SetAnchor(TOPLEFT, wnd, TOPLEFT, 20, 20)
            dropdown:SetDimensions(250, 30)
        
            local combo = ZO_ComboBox_ObjectFromContainer(dropdown)
            combo:SetSortsItems(false)
        
            for _, cat in ipairs(categories) do
                combo:AddItem(combo:CreateItemEntry(cat, function()
                    currentCategory = cat
                    DsR_UpdateSoundList()
                end))
            end
        
            combo:SetSelectedItem("ALL")
        
            -- Suchfeld rechts neben dem Dropdown
            local searchBox = WINDOW_MANAGER:CreateControlFromVirtual("DsRSoundTesterSearch", wnd, "ZO_DefaultEditForBackdrop")
            searchBox:SetDimensions(250, 24)
            searchBox:SetAnchor(TOPLEFT, dropdown, TOPRIGHT, 20, 0)
            searchBox:SetMaxInputChars(50)
            searchBox:SetFont("ZoFontGame")
            searchBox:SetEditEnabled(true)
            searchBox:SetMouseEnabled(true)
        
            -- ESO-Placeholder-Logik
            ZO_EditDefaultText_Initialize(searchBox, "Suchen…")
        
            searchBox:SetHandler("OnTextChanged", function(self)
                searchText = self:GetText()
                DsR_UpdateSoundList()
            end)
        
            -- ScrollContainer
            local scroll = WINDOW_MANAGER:CreateControlFromVirtual("DsRSoundTesterScroll", wnd, "ZO_ScrollContainer")
            scroll:SetAnchor(TOPLEFT, dropdown, BOTTOMLEFT, 0, 20)
            scroll:SetAnchor(BOTTOMRIGHT, wnd, BOTTOMRIGHT, -20, -60)
        
            content = scroll:GetNamedChild("ScrollChild")
            content:ClearAnchors()
            content:SetAnchor(TOPLEFT, scroll, TOPLEFT, 0, 0)
            content:SetWidth(600)
        
            -- Sounds sortieren
            local sorted = {}
            for soundName, soundId in pairs(SOUNDS) do
                table.insert(sorted, {name = soundName, id = soundId})
            end
            table.sort(sorted, function(a, b) return a.name < b.name end)
        
            -- Buttons erzeugen
            local y = 0
            local heightPerRow = 28
        
            for _, entry in ipairs(sorted) do
                local btn = WINDOW_MANAGER:CreateControl(nil, content, CT_BUTTON)
                btn:SetAnchor(TOPLEFT, content, TOPLEFT, 10, y)
                btn:SetDimensions(540, heightPerRow)
                btn.soundId = entry.id
                btn.soundName = entry.name
                btn.category = GetCategory(entry.name)
            
                -- Label für Text
                local label = WINDOW_MANAGER:CreateControl(nil, btn, CT_LABEL)
                label:SetAnchor(LEFT, btn, LEFT, 0, 0)
                label:SetFont("ZoFontGame")
                label:SetText(entry.name)
                label:SetColor(1, 1, 1, 1)
            
                btn.label = label
            
                btn:SetHandler("OnClicked", function(self)
                    PlaySound(self.soundId)
                
                    -- alten Button zurücksetzen
                    if lastClickedButton then
                        lastClickedButton.label:SetColor(1, 1, 1, 1) -- weiß
                    end
                
                    -- aktuellen rot färben
                    self.label:SetColor(1, 0, 0, 1)
                
                    lastClickedButton = self
                end)
            
                table.insert(soundButtons, btn)
                y = y + heightPerRow
            end
        
            content:SetHeight(y)
        
            -- Schließen‑Button
            local closeBtn = WINDOW_MANAGER:CreateControl(nil, wnd, CT_BUTTON)
            closeBtn:SetDimensions(120, 35)
            closeBtn:SetAnchor(BOTTOM, wnd, BOTTOM, 0, -10)
            closeBtn:SetText("Schließen")
            closeBtn:SetFont("ZoFontGameBold")
            closeBtn:SetHandler("OnClicked", function()
                wnd:SetHidden(true)
            end)
        end

        DsR_CreateSoundTester()
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
----- Jump to guildhouse
function DsRGuildAdmin.OnClickedPortGuild(self,button)
    local player      = GetDisplayName()
    local location_id = GetCurrentZoneHouseId()

    for _,v in pairs(COLLECTIONS_BOOK_SINGLETON:GetOwnedHouses()) do
        if IsPrimaryHouse(v.houseId) then
            house_id = v.houseId
        end
    end
    if player == "@flo1980" then
        RequestJumpToHouse(house_id, false)
    else
        JumpToHouse("@flo1980")
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Jump to primary residence
function DsRGuildAdmin.OnClickedPortMem(self,button)
    local location_id = GetCurrentZoneHouseId()
    
    for _,v in pairs(COLLECTIONS_BOOK_SINGLETON:GetOwnedHouses()) do
        if IsPrimaryHouse(v.houseId) then
            house_id = v.houseId
        end
    end
    if location_id ~= house_id then
        RequestJumpToHouse(house_id, false)
    end
end
