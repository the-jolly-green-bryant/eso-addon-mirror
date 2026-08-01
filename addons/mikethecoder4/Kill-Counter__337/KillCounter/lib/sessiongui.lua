local session_table = nil
local kills_table = nil
-- ========================================
-- Accessor values
local Kills = 1
local KillingBlows = 2
local Avenge_Kills = 3
local Revent_Kills = 4
local Alliance = 5
local vLevel = 6
local Name = 7
local Level = 8
local Class = 9
local KilledBy = 10
-- ========================================

function KC_G.sessionWindowGUISetup()
    local tlw = Scene_KC_Menu_Session_Session_Table
    -- tlw.Logo = KillCounter_Stats_Window_Kills_Logo
    tlw:ClearAnchors()
    tlw.DataOffset = 0
    tlw.MaxLines = 8
    tlw.MaxColumns = 2
    tlw.DataLines = {}
    tlw.Lines = {}
    tlw:SetHeight(268)
    tlw:SetWidth(300)
    tlw:SetAnchor(TOPLEFT, Scene_KC_Menu_Session, TOPLEFT, 20, 30)
    tlw:SetDrawLayer(DL_BACKGROUND)
    tlw:SetMouseEnabled(true)
    tlw:SetHandler("OnMouseWheel", function(self, delta) end)
    tlw:SetHandler("OnShow", function(self)

        tlw.DataLines = {}
        for i = 1, 4 do
            tlw.DataLines[i] = string.format("kills and stuff %d", 0)
        end

    end)

    tlw.BackGround = WINDOW_MANAGER:CreateControl(nil, tlw, CT_BACKDROP)
    tlw.BackGround:SetAnchorFill(tlw)
    tlw.BackGround:SetCenterColor(0.0, 0.0, 0.0, 0.5)
    tlw.BackGround:SetEdgeColor(1, 1, 1, 0.5)
    tlw.BackGround:SetEdgeTexture(nil, 2, 2, 2.0, 2.0)

    for i = 1, tlw.MaxLines do
        tlw.Lines[i] = WINDOW_MANAGER:CreateControlFromVirtual(
                           "KillCounter_Session_Line_" .. i, tlw,
                           "KillCounter_Overview_Line")
        tlw.Lines[i]:SetDimensions(tlw:GetWidth() - 8, 30)
        if i == 1 then
            tlw.Lines[i]:SetAnchor(TOPLEFT, tlw, TOPLEFT, 5, 5)
        else
            tlw.Lines[i]:SetAnchor(TOPLEFT, tlw.Lines[i - 1], BOTTOMLEFT, 0, 3)
        end

        local index = i
        tlw.Lines[i].Columns = {}
        for j = 1, tlw.MaxColumns do
            tlw.Lines[i].Columns[j] = WINDOW_MANAGER:CreateControl(nil,
                                                                   tlw.Lines[i],
                                                                   CT_LABEL)
            tlw.Lines[i].Columns[j]:SetFont("ZoFontGame")
            tlw.Lines[i].Columns[j]:SetDimensions(tlw.Lines[i]:GetWidth() / 2,
                                                  20)
            if j == 1 then
                tlw.Lines[i].Columns[j]:SetAnchor(TOPLEFT, tlw.Lines[i],
                                                  TOPLEFT, 18, 5)
            else
                local oy = 0
                if i ~= 1 then
                    tlw.Lines[i].Columns[j]:SetFont("ZoFontGame")
                    if j == 2 then oy = 0 end
                end
                tlw.Lines[i].Columns[j]:SetAnchor(TOPLEFT,
                                                  tlw.Lines[i].Columns[j - 1],
                                                  TOPLEFT,
                                                  (tlw.Lines[i]:GetWidth() / 2) +
                                                      35, oy)
            end

            if i == 1 then
                if j == 1 then
                    tlw.Lines[i].Columns[j]:SetText("Session Overview")
                end
                if j == 2 then
                    tlw.Lines[i].Columns[j]:SetText("")
                end

            else
                if i == 2 then
                    if j == 1 then
                        tlw.Lines[i].Columns[j]:SetText("Kills")
                    end
                    if j == 2 then
                        tlw.Lines[i].Columns[j]:SetText("T Kills")
                    end

                end
                if i == 3 then
                    if j == 1 then
                        tlw.Lines[i].Columns[j]:SetText("Deaths: ")
                    end
                    if j == 2 then
                        tlw.Lines[i].Columns[j]:SetText("T Deaths")
                    end
                end

                if i == 4 then
                    if j == 1 then
                        tlw.Lines[i].Columns[j]:SetText("Longest Streak: ")
                    end
                    if j == 2 then
                        tlw.Lines[i].Columns[j]:SetText("T Deaths")
                    end
                end

                if i == 5 then
                    if j == 1 then
                        tlw.Lines[i].Columns[j]:SetText("Longest D Streak: ")
                    end
                    if j == 2 then
                        tlw.Lines[i].Columns[j]:SetText("T Deaths")
                    end
                end

                if i == 6 then
                    if j == 1 then
                        tlw.Lines[i].Columns[j]:SetText("Longest KB Streak: ")
                    end
                    if j == 2 then
                        tlw.Lines[i].Columns[j]:SetText("T Deaths")
                    end
                end
                if i == 7 then
                    if j == 1 then
                        tlw.Lines[i].Columns[j]:SetText("K/D Ratio: ")
                    end
                    if j == 2 then
                        tlw.Lines[i].Columns[j]:SetText("T Deaths")
                    end
                end
                if i == 8 then
                    if j == 1 then
                        tlw.Lines[i].Columns[j]:SetText("AP Gained: ")
                    end
                    if j == 2 then
                        tlw.Lines[i].Columns[j]:SetText("T Deaths")
                    end
                end

            end
            tlw.Lines[i].Columns[j]:SetHidden(false)
        end
    end

    session_table = tlw

    -- start current kills list
    -- START KILLS TABLE
    local tkw = Scene_KC_Menu_Session_Session_Kills_Table
    tkw:ClearAnchors()
    tkw.DataOffset = 0
    tkw.MaxLines = 9
    tkw.MaxColumns = 6
    tkw.DataLines = {}
    tkw.Lines = {}
    tkw:SetHeight(258)
    tkw:SetWidth(570)
    tkw:SetAnchor(TOPLEFT, Scene_KC_Menu_Session, TOPLEFT, 335, 30)
    tkw:SetDrawLayer(DL_BACKGROUND)
    tkw:SetMouseEnabled(true)
    tkw:SetHandler("OnMouseWheel", function(self, delta)
        if kills_table == nil then return end
        local tlw = kills_table
        local value = tlw.DataOffset - delta
        if value < 0 then
            value = 0
        elseif value > KC_Fn.tablelength(tlw.DataLines) - tlw.MaxLines then
            value = KC_Fn.tablelength(tlw.DataLines) - tlw.MaxLines
        end
        tlw.DataOffset = value
        tlw.Slider:SetValue(tlw.DataOffset)
        KC_G.UpdateSessionKillsTable()
    end)
    tkw:SetHandler("OnShow", function(self)
        local session = KC_G.GetCurrentSession()
        tkw.DataLines = {}

        -- for k,v in pairs(KC_G.savedVars.players) do
        for k, v in pairs(session.players) do
            table.insert(tkw.DataLines, v)
        end
        KC_G.UpdateSessionKillsTable()
        -- d("showing")

    end)

    tkw.BackGround = WINDOW_MANAGER:CreateControl(nil, tkw, CT_BACKDROP)
    tkw.BackGround:SetAnchorFill(tkw)
    tkw.BackGround:SetCenterColor(0.0, 0.0, 0.0, 0.5)
    tkw.BackGround:SetEdgeColor(1, 1, 1, 0.5)
    tkw.BackGround:SetEdgeTexture(nil, 2, 2, 2.0, 2.0)

    local tex = "/esoui/art/miscellaneous/scrollbox_elevator.dds"
    tkw.Slider = WINDOW_MANAGER:CreateControl(
                     "KillCounter_THIS_FUCKING_ASSHOLE_SESSION_SCROLLBAR", tkw,
                     CT_SLIDER)

    tkw.Slider:SetDimensions(13, tkw:GetHeight())
    tkw.Slider:SetMouseEnabled(true)
    tkw.Slider:SetThumbTexture(tex, tex, tex, 13, 35, 0, 0, 1, 1)
    tkw.Slider:SetValue(0)
    tkw.Slider:SetValueStep(1)
    tkw.Slider:SetAnchorFill()
    tkw.Slider:SetMinMax(0, 50)
    tkw.Slider:ClearAnchors()
    tkw.Slider:SetAnchor(TOPLEFT, tkw, TOPLEFT, tkw:GetWidth() - 15, 5)

    -- When we change the slider's value we need to change the data offset and redraw the display
    tkw.Slider:SetHandler("OnValueChanged", function(self, value, eventReason)
        -- tkw.DataOffset = math.min(value,#tkw.DataLines - tkw.MaxLines)
        -- d("changing things you bitch")
        if kills_table == nil then return end
        local tlw = kills_table
        tlw.DataOffset = math.min(value, KC_Fn.tablelength(tlw.DataLines) -
                                      tlw.MaxLines)
        KC_G.UpdateSessionKillsTable()
    end)

    for i = 1, tkw.MaxLines do
        tkw.Lines[i] = WINDOW_MANAGER:CreateControlFromVirtual(
                           "KillCounter_Session_Kills_Table_Line_" .. i, tkw,
                           "KillCounter_Kills_Table_Line")
        tkw.Lines[i]:SetDimensions(tkw:GetWidth() - 10, 25)
        if i == 1 then
            tkw.Lines[i]:SetAnchor(TOPLEFT, tkw, TOPLEFT, 0, 5)
        else
            tkw.Lines[i]:SetAnchor(TOPLEFT, tkw.Lines[i - 1], BOTTOMLEFT, 0, 3)
        end

        local index = i
        tkw.Lines[i].Columns = {}
        for j = 1, tkw.MaxColumns do
            tkw.Lines[i].Columns[j] = WINDOW_MANAGER:CreateControl(nil,
                                                                   tkw.Lines[i],
                                                                   CT_LABEL)
            local oy = 0
            if i == 1 then
                tkw.Lines[i].Columns[j]:SetFont("ZoFontGameBold")
            else
                tkw.Lines[i].Columns[j]:SetFont("ZoFontGameSmall")
                -- cell if second cell, set offset y to 3
                oy = 3
            end
            tkw.Lines[i].Columns[j]:SetDimensions(tkw.Lines[i]:GetWidth() / 6,
                                                  25) -- no
            if i == 1 then
                local sw, wh = tkw.Lines[i].Columns[j]:GetTextDimensions()
                -- d(wh)
                tkw.Lines[i].Columns[j]:SetDimensions(sw, 25)
                if j == 1 then
                    tkw.Lines[i].Columns[j]:SetAnchor(TOPLEFT, tkw.Lines[i],
                                                      TOPLEFT, 18, 0)
                else
                    local sw, wh =
                        tkw.Lines[i].Columns[j - 1]:GetTextDimensions()
                    local ox = (tkw.Lines[i]:GetWidth() / tkw.MaxColumns) - sw
                    if j == 2 then ox = ox + 65 end
                    if j == 3 then
                        ox = ox - 45
                        -- tkw.Lines[i].Columns[j]:SetDimensions(tkw.Lines[i].Columns[j]:GetWidth() - 25,25)
                    end
                    if j == 4 then ox = ox - 45 end
                    -- d(tkw.Lines[i].Columns[j]:GetWidth(), (tkw.Lines[i]:GetWidth()/tkw.MaxColumns))
                    tkw.Lines[i].Columns[j]:SetAnchor(TOPLEFT, tkw.Lines[i]
                                                          .Columns[j - 1],
                                                      TOPRIGHT, ox, oy)
                end
            else
                -- .d("happen")
                -- center that bitch

                local w, h = tkw.Lines[1].Columns[j]:GetTextDimensions()

                local offx = 0
                if j ~= 1 and i == 2 and j ~= 5 and j ~= 6 then
                    offx = (w / 2) - tkw.Lines[i].Columns[j]:GetTextDimensions()
                end

                if j ~= 1 and i == 2 and j == 6 then
                    offx = offx + 18
                end
                tkw.Lines[i].Columns[j]:SetAnchor(TOPLEFT,
                                                  tkw.Lines[i - 1].Columns[j],
                                                  BOTTOMLEFT, offx, oy)
            end
            local function SortBy(sortField)
                return function()
                    tkw.Lines[i].Columns[j].SortButton.Desc =
                        not tkw.Lines[i].Columns[j].SortButton.Desc

                    if tkw.Lines[i].Columns[j].SortButton.Desc then
                        table.sort(kills_table.DataLines, function(a, b)
                            return b[sortField] < a[sortField]
                        end)
                    else
                        table.sort(kills_table.DataLines, function(a, b)
                            return a[sortField] < b[sortField]
                        end)
                    end
                    KC_G.UpdateSessionKillsTable()
                end
            end

            -- tkw.Lines[i].Columns[j]:SetText("Column")
            if i == 1 then
                if j == 1 then
                    tkw.Lines[i].Columns[j]:SetText("Name")
                    tkw.Lines[i].Columns[j].SortButton =
                        WINDOW_MANAGER:CreateControl(nil,
                                                     tkw.Lines[i].Columns[j],
                                                     CT_BUTTON)

                    tkw.Lines[i].Columns[j].SortButton:SetWidth(
                        tkw.Lines[i].Columns[j]:GetWidth())
                    tkw.Lines[i].Columns[j].SortButton:SetHeight(
                        tkw.Lines[i].Columns[j]:GetHeight())
                    tkw.Lines[i].Columns[j].SortButton:SetAnchor(TOPLEFT,
                                                                 tkw.Lines[i]
                                                                     .Columns[j],
                                                                 TOPLEFT, 0, 0)
                    tkw.Lines[i].Columns[j].SortButton.Desc = false
                    tkw.Lines[i].Columns[j].SortButton:SetHandler("OnClicked",
                                                                  SortBy(Name))
                    tkw.Lines[i].Columns[j].SortButton:SetHidden(false)
                end
                if j == 2 then
                    tkw.Lines[i].Columns[j]:SetText("Kills")
                    tkw.Lines[i].Columns[j].SortButton =
                        WINDOW_MANAGER:CreateControl(nil,
                                                     tkw.Lines[i].Columns[j],
                                                     CT_BUTTON)

                    tkw.Lines[i].Columns[j].SortButton:SetWidth(
                        tkw.Lines[i].Columns[j]:GetWidth())
                    tkw.Lines[i].Columns[j].SortButton:SetHeight(
                        tkw.Lines[i].Columns[j]:GetHeight())
                    tkw.Lines[i].Columns[j].SortButton:SetAnchor(TOPLEFT,
                                                                 tkw.Lines[i]
                                                                     .Columns[j],
                                                                 TOPLEFT, 0, 0)
                    tkw.Lines[i].Columns[j].SortButton.Desc = false
                    tkw.Lines[i].Columns[j].SortButton:SetHandler("OnClicked",
                                                                  SortBy(Kills))
                    tkw.Lines[i].Columns[j].SortButton:SetHidden(false)
                end
                if j == 3 then
                    tkw.Lines[i].Columns[j]:SetText("KBs")
                    tkw.Lines[i].Columns[j].SortButton =
                        WINDOW_MANAGER:CreateControl(nil,
                                                     tkw.Lines[i].Columns[j],
                                                     CT_BUTTON)

                    tkw.Lines[i].Columns[j].SortButton:SetWidth(
                        tkw.Lines[i].Columns[j]:GetWidth())
                    tkw.Lines[i].Columns[j].SortButton:SetHeight(
                        tkw.Lines[i].Columns[j]:GetHeight())
                    tkw.Lines[i].Columns[j].SortButton:SetAnchor(TOPLEFT,
                                                                 tkw.Lines[i]
                                                                     .Columns[j],
                                                                 TOPLEFT, 0, 0)
                    tkw.Lines[i].Columns[j].SortButton.Desc = false
                    tkw.Lines[i].Columns[j].SortButton:SetHandler("OnClicked",
                                                                  SortBy(
                                                                      KillingBlows))
                    tkw.Lines[i].Columns[j].SortButton:SetHidden(false)
                end
                if j == 4 then
                    tkw.Lines[i].Columns[j]:SetText("Deaths")
                    tkw.Lines[i].Columns[j].SortButton =
                        WINDOW_MANAGER:CreateControl(nil,
                                                     tkw.Lines[i].Columns[j],
                                                     CT_BUTTON)

                    tkw.Lines[i].Columns[j].SortButton:SetWidth(
                        tkw.Lines[i].Columns[j]:GetWidth())
                    tkw.Lines[i].Columns[j].SortButton:SetHeight(
                        tkw.Lines[i].Columns[j]:GetHeight())
                    tkw.Lines[i].Columns[j].SortButton:SetAnchor(TOPLEFT,
                                                                 tkw.Lines[i]
                                                                     .Columns[j],
                                                                 TOPLEFT, 0, 0)
                    tkw.Lines[i].Columns[j].SortButton.Desc = false
                    tkw.Lines[i].Columns[j].SortButton:SetHandler("OnClicked",
                                                                  SortBy(
                                                                      KilledBy))
                    tkw.Lines[i].Columns[j].SortButton:SetHidden(false)
                end
                if j == 5 then
                    tkw.Lines[i].Columns[j]:SetText("Class")
                    tkw.Lines[i].Columns[j].SortButton =
                        WINDOW_MANAGER:CreateControl(nil,
                                                     tkw.Lines[i].Columns[j],
                                                     CT_BUTTON)

                    tkw.Lines[i].Columns[j].SortButton:SetWidth(
                        tkw.Lines[i].Columns[j]:GetWidth())
                    tkw.Lines[i].Columns[j].SortButton:SetHeight(
                        tkw.Lines[i].Columns[j]:GetHeight())
                    tkw.Lines[i].Columns[j].SortButton:SetAnchor(TOPLEFT,
                                                                 tkw.Lines[i]
                                                                     .Columns[j],
                                                                 TOPLEFT, 0, 0)
                    tkw.Lines[i].Columns[j].SortButton.Desc = false
                    tkw.Lines[i].Columns[j].SortButton:SetHandler("OnClicked",
                                                                  SortBy(Class))
                    tkw.Lines[i].Columns[j].SortButton:SetHidden(false)
                end
                if j == 6 then
                    tkw.Lines[i].Columns[j]:SetText("Alliance")
                    tkw.Lines[i].Columns[j].SortButton =
                        WINDOW_MANAGER:CreateControl(nil,
                                                     tkw.Lines[i].Columns[j],
                                                     CT_BUTTON)

                    tkw.Lines[i].Columns[j].SortButton:SetWidth(
                        tkw.Lines[i].Columns[j]:GetWidth())
                    tkw.Lines[i].Columns[j].SortButton:SetHeight(
                        tkw.Lines[i].Columns[j]:GetHeight())
                    tkw.Lines[i].Columns[j].SortButton:SetAnchor(TOPLEFT,
                                                                 tkw.Lines[i]
                                                                     .Columns[j],
                                                                 TOPLEFT, 0, 0)
                    tkw.Lines[i].Columns[j].SortButton.Desc = false
                    tkw.Lines[i].Columns[j].SortButton:SetHandler("OnClicked",
                                                                  SortBy(
                                                                      Alliance))
                    tkw.Lines[i].Columns[j].SortButton:SetHidden(false)
                end
                --
            else
                if j == 1 then
                    tkw.Lines[i].Columns[j].PlayerButton =
                        WINDOW_MANAGER:CreateControl(nil,
                                                     tkw.Lines[i].Columns[j],
                                                     CT_BUTTON)

                    tkw.Lines[i].Columns[j].PlayerButton:SetWidth(
                        tkw.Lines[i]:GetWidth() - 22)
                    tkw.Lines[i].Columns[j].PlayerButton:SetHeight(
                        tkw.Lines[i]:GetHeight())
                    tkw.Lines[i].Columns[j].PlayerButton:SetAnchor(TOPLEFT,
                                                                   tkw.Lines[i]
                                                                       .Columns[j],
                                                                   TOPLEFT, 0, 0)
                    tkw.Lines[i].Columns[j].PlayerButton:SetHandler("OnClicked",
                                                                    function(
                        self, delta)
                        -- d("bitches")
                        KC_G.ShowPlayer(tkw.Lines[i].Columns[j]:GetText())

                    end)
                    tkw.Lines[i].Columns[j].PlayerButton:SetHidden(false)
                end
            end

            tkw.Lines[i].Columns[j]:SetHidden(false)
        end
    end
    -- d(KC_G.savedVars.players)
    -- tkw.DataLines = KC_G.savedVars.players
    -- d(tkw.DataLines)
    local session = KC_G.GetCurrentSession()

    if KC_G.TestMode() then
        tkw.DataLines = {}
        d("Generating Test Data")
        s, sd = SessionTestData()
        if s ~= nil then session.players = s end
        if sd ~= nil then session.players = sd end
    end
    -- for k,v in pairs(session.players) do
    -- table.insert(tkw.DataLines, v)
    -- end
    tkw.DataLines = ParseKillTable(session.players, session.players)

    -- tkw:SetHidden(true)
    kills_table = tkw
    KC_G.UpdateSessionKillsTable()
    -- End kills table
end

function KC_G.UpdateSessionData()
    if kills_table == nil then return end

    local session = KC_G.GetCurrentSession()
    kills_table.DataLines = ParseKillTable(session.players, session.players)
    KC_G.UpdateSessionKillsTable()
end

function ParseKillTable(killed, killedBy)
    local lines = {}
    for k, v in pairs(killed) do
        -- insert all the kills
        table.insert(lines, v)
        -- check if there are any deaths
        if killedBy[k] ~= nil then
            lines[#lines][KilledBy] = killedBy[k][KilledBy]
        else
            lines[#lines][KilledBy] = 0
        end

    end

    for k, v in pairs(killedBy) do
        -- check if we already added them by seeing if they exist in killed
        -- if not add them
        if killed[k] == nil then
            na = KC_G.NewPlayerArray()
            na[Name] = v[Name]
            na[KilledBy] = v[KilledBy]
            na[Class] = v[Class]
            na[Alliance] = v[Alliance]
            table.insert(lines, na)
        end
    end

    return lines

end

function KC_G.updateSessionGui()
    local session = KC_G.GetCurrentSession()
    local kdr = KC_G.GetCounter()
    -- rounding the decimal to nearest 1 for readability
    -- if KC_G.GetDeathCounter() > 0 then kdr = floor(((kdr/KC_G.GetDeathCounter())*10^1 +0.5)/10^1) end
    --	if KC_G.GetDeathCounter() > 0 then kdr = math.round((kdr / KC_G.GetDeathCounter())*10)*0.1 end
    if KC_G.GetDeathCounter() > 0 then
        kdr = KC_Fn.round((kdr / KC_G.GetDeathCounter()), 2)
    end
    -- find fidd between normal kdr

    local ap = KC_G.GetAP()
    -- yellow == 70% or below...easy pz
    local threshold = .70 -- Within 70% of the kdr
    local godMode = 10.0 -- gold plat F9FAA4
    local beastMode = 5.0 -- orange #ff8000
    local superMode = 2.5 -- blue #0070dd

    if kdr >= threshold and kdr < superMode then
        color = "|C00FF00" -- green
    elseif kdr >= superMode and kdr < beastMode then
        color = "|C0070dd"
    elseif kdr >= beastMode and kdr < godMode then
        color = "|Cff8000"
    elseif kdr >= godMode then
        color = "|CF9FAA4"
    elseif kdr <= threshold and kdr >= .50 or kdr == 0 then
        color = "|CFFFF00" -- yellow
    elseif kdr >= godMode then
        color = "|CCCAA1A"
    else
        color = "|CFF0000" -- red
    end

    --[[
	--The commented out section is for showing the difference between avg K/D and current
   local okdr = KC_G.GetCounter()
   local diff = kdr / okdr
   local diffabs = math.abs(diff)
   if diffabs >= threshold then
		color = "|C00FF00 +" -- green
   elseif diffabs <= threshold or diffabs == 0 then
		color = "|CFFFF00"  -- yellow
	  else 
		color = "|CFF0000" --red
	end
	else
	  if diff > 0 then color = color .. "+" 
	end
	]]

    -- combine stringswa

    local kdrstring = color .. kdr -- .. " (" .. color .. KC_Fn.round(diff, 2) .. "|r )"
    for i = 1, session_table.MaxLines do
        for j = 1, session_table.MaxColumns do
            if i == 1 then
                -- do nothing
            else
                if i == 2 then
                    if j == 2 then
                        session_table.Lines[i].Columns[j]:SetText(
                            KC_G.GetCounter())
                    end
                end
                if i == 3 then
                    if j == 2 then
                        session_table.Lines[i].Columns[j]:SetText(
                            KC_G.GetDeathCounter())
                    end
                end
                if i == 4 then
                    if j == 2 then
                        session_table.Lines[i].Columns[j]:SetText(
                            session.longestStreak)
                    end
                end
                if i == 5 then
                    if j == 2 then
                        session_table.Lines[i].Columns[j]:SetText(
                            session.longestDeathStreak)
                    end
                end
                if i == 6 then
                    if j == 2 then
                        session_table.Lines[i].Columns[j]:SetText(
                            session.longestKBStreak)
                    end
                end
                if i == 7 then
                    if j == 2 then
                        session_table.Lines[i].Columns[j]:SetText(kdrstring)
                    end
                end
                if i == 8 then
                    if j == 2 then
                        session_table.Lines[i].Columns[j]:SetText(ap)
                    end
                end
            end
        end
    end

end

function KC_G.UpdateSessionKillsTable(...)
    if kills_table == nil then return end
    local tlw = kills_table
    --[[
      if KC_G.TestMode() and KC_Fn.tablelength(tlw.DataLines) < 1 then
      d("Generating Test Data")
      local session = KC_G.GetCurrentSession()
      s, sd = SessionTestData()
      if s ~= nil then session.players = s end
      if sd ~= nil then session.players = sd end
      --d("Values: ", s, sd)
      tlw.DataLines = {}
      for k,v in pairs(session.players) do
      table.insert(tlw.DataLines, v)
      end
      end
   ]] --

    tlw.DataOffset = tlw.DataOffset or 0
    if tlw.DataOffset < 0 then tlw.DataOffset = 0 end
    -- d(tlw.DataLines)
    if KC_Fn.tablelength(tlw.DataLines) == 0 then return end

    tlw.Slider:SetMinMax(0, KC_Fn.tablelength(tlw.DataLines) - tlw.MaxLines)
    -- d(tlw.DataOffset)
    -- for i=1,tlw.DataOffset-1 do
    -- d("nexting")
    -- pk = next(tlw.DataLines, pk)

    -- end
    local pk = tlw.DataOffset
    -- d(#tlw.DataLines, pk)
    for i = 2, tlw.MaxLines do
        if pk + (i - 1) > #tlw.DataLines then break end
        local curLine = tlw.Lines[i]
        local curData = tlw.DataLines[pk + i - 1]
        -- d(i)
        curLine.Columns[1]:SetText(curData[Name])
        curLine.Columns[2]:SetText(curData[Kills])
        curLine.Columns[3]:SetText(curData[KillingBlows])
        curLine.Columns[4]:SetText(curData[KilledBy])
        curLine.Columns[5]:SetText(zo_strformat("<<1>>", GetClassName(
                                                    GENDER_MALE, curData[Class])))
        curLine.Columns[6]:SetText(KC_Fn.Colored_Alliance_From_Id(
                                       curData[Alliance]))

    end
end

function SessionTestData()
    if KC_G.savedVars == nil then return end
    lenkills = KC_Fn.tablelength(KC_G.savedVars.players)
    lendeaths = KC_Fn.tablelength(KC_G.savedVars.players)
    tkills = {}
    tdeaths = {}
    -- 25 random kills
    for i = 1, 25 do
        -- get a random person from kills
        r = math.random(lenkills)
        -- d(r)
        rk = KC_Fn.table_randFrom(KC_G.savedVars.players)
        if rk ~= nil then
            name = rk[Name]
            na = KC_G.NewPlayerArray()
            na[Name] = name
            na[Kills] = math.random(5)
            na[KillingBlows] = math.random(na[Kills])
            na[Class] = rk[Class]
            na[Alliance] = rk[Alliance]

            table.insert(tkills, na)
        else
            -- d("Null Value (kills) " .. r)
        end

    end

    for i = 1, 25 do
        -- get a random person from kills
        rk = KC_Fn.table_randFrom(KC_G.savedVars.players)
        if rk ~= nil then
            name = rk[Name]
            na = KC_G.NewPlayerArray()
            na[Name] = name
            na[KilledBy] = math.random(5)
            na[Class] = rk[Class]
            na[Alliance] = rk[Alliance]
            table.insert(tdeaths, na)
        else
            -- d("Null Value (deaths)" .. r)
        end
    end
    return tkills, tdeaths
end
