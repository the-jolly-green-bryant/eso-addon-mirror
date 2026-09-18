TamrielCalendar = TamrielCalendar or {}
local TC = TamrielCalendar
TC.name = "TamrielCalendar"

local L = TC.L
local HolidayDates = { [1]={[1]="nl"}, [2]={[16]="hd"}, [4]={[4]="aj",[28]="jd"}, [5]={[16]="zz"}, [6]={[16]="my"}, [10]={[13]="wf"}, [11]={[20]="ud"}, [12]={[30]="ol"} }

TC.viewDate = os.date("*t")
local signFileNames = {"Ritual", "Lover", "Lord", "Mage", "Shadow", "Steed", "Apprentice", "Warrior", "Lady", "Tower", "Atronach", "Thief", "Serpent"}

-- 3. ВРЕМЯ
function TC.GetTamrielTime()
    local timestamp = GetTimeStamp()
    local lengthOfDay = 20955
    local startTime = 1398033648.5
    local tst = 24 * ((timestamp - startTime) % lengthOfDay) / lengthOfDay
    return math.floor(tst), math.floor((tst - math.floor(tst)) * 60)
end

function TC.GetMoonPhaseName(cycleDays, offset)
    local timestamp = (GetTimeStamp() / 86400)
    local phaseIndex = math.floor(((timestamp + (offset or 0)) % cycleDays) / cycleDays * 8) + 1
    if phaseIndex > 8 then phaseIndex = 1 end
    return L.moonPhases[phaseIndex] or L.moonPhases[1]
end

-- 4. УПРАВЛЕНИЕ ОКНОМ И ПЛАШКОЙ
function TC.GetFontString()
    local sv = TC.savedVars
    local fontPath = sv.fontPath or "$(BOLD_FONT)"
    local fontSize = sv.fontSize or 18
    local fontStyle = sv.fontStyle or "soft-shadow-thick"
    if fontStyle and fontStyle ~= "" then
        return string.format("%s|%d|%s", fontPath, fontSize, fontStyle)
    else
        return string.format("%s|%d", fontPath, fontSize)
    end
end

function TC.ApplyVisualSettings()
    if not TamrielCalendarControl then return end
    local sv = TC.savedVars

    if not sv.autoWidth then
        TamrielCalendarControl:SetWidth(sv.stripWidth)
    end
    TamrielCalendarControl:SetHeight(sv.stripHeight)
    TamrielCalendarControl:SetMovable(not sv.stripLocked)
    
    -- Гладкий фон без сжимающихся полос
    local alpha = sv.stripAlpha or 0.8
    TamrielCalendarControlBG:SetEdgeTexture("", 8, 1, 1)
    TamrielCalendarControlBG:SetCenterColor(0, 0, 0, alpha)
    TamrielCalendarControlBG:SetEdgeColor(0.25, 0.25, 0.25, alpha)

    -- Шрифт и цвет текста
    local fontString = TC.GetFontString()
    TamrielCalendarLabel:SetFont(fontString)
    if sv.textColor then
        TamrielCalendarLabel:SetColor(sv.textColor.r, sv.textColor.g, sv.textColor.b, sv.textColor.a or 1)
    end
end

function TC.ChangeMonth(delta)
    local m = TC.viewDate.month + delta
    local y = TC.viewDate.year
    if m > 12 then m = 1 y = y + 1 elseif m < 1 then m = 12 y = y - 1 end
    TC.viewDate.month = m TC.viewDate.year = y
    TC.CreateCalendarGrid(true)
end

function TC.UpdateUI()
    if not TamrielCalendarControl or TamrielCalendarControl:IsHidden() then return end
    local sv = TC.savedVars
    local date = os.date("*t")
    local h, m = TC.GetTamrielTime()
    local tamYear = 582 + (date.year - 2014)

    local dateParts = {}
    if sv.showDayOfWeek then
        table.insert(dateParts, L.days[date.wday])
    end
    if sv.showDate then
        table.insert(dateParts, string.format("%d %s", date.day, L.months[date.month]))
    end
    if sv.showYear then
        table.insert(dateParts, string.format("%d %s", tamYear, L.yearSuffix or ""))
    end

    local finalSections = {}
    if #dateParts > 0 then
        table.insert(finalSections, table.concat(dateParts, ", "))
    end
    if sv.showSign then
        local sPrefix = L.signPrefix and (L.signPrefix .. " ") or ""
        table.insert(finalSections, sPrefix .. L.signs[date.month])
    end
    if sv.showTime then
        table.insert(finalSections, string.format("%02d:%02d", h, m))
    end

    TamrielCalendarLabel:SetText(table.concat(finalSections, " | "))

    -- Автоматическая подгонка ширины под текст
    if sv.autoWidth then
        local textWidth = TamrielCalendarLabel:GetTextWidth()
        local padding = 30
        TamrielCalendarControl:SetWidth(math.max(120, textWidth + padding))
    end
end

function TC.UpdateWindowContent()
    local v = TC.viewDate
    local tamYear = 582 + (v.year - 2014)
    TamrielCalendarWindowYear:SetText(tamYear .. " " .. L.yearSuffix)
    TamrielCalendarWindowMonth:SetText(L.months[v.month])
    TamrielCalendarWindowRealMonth:SetText("(" .. L.realMonths[v.month] .. ")")
    TamrielCalendarWindowSignInfo:SetText(L.signPrefix .. " " .. L.signs[v.month])
    TamrielCalendarPrevBtn:SetText(L.btnPrev)
    TamrielCalendarNextBtn:SetText(L.btnNext)
    local masser = TC.GetMoonPhaseName(24, 2)
    local secunda = TC.GetMoonPhaseName(32, 5)
    TamrielCalendarMoonText:SetText(string.format("Masser: %s  |  Secunda: %s", masser, secunda))
    TamrielCalendarWindowSignArt:SetTexture("TamrielCalendar/img/" .. signFileNames[v.month] .. ".dds")
end

function TC.CreateCalendarGrid(refresh)
    local grid = TamrielCalendarWindowGrid
    if not grid then return end
    if refresh then
        local i = 1
        while _G["TC_Cell"..i] do _G["TC_Cell"..i]:SetHidden(true) i = i + 1 end
    end
    if not _G["TC_Hdr1"] then
        for i=1, 7 do
            local h = WINDOW_MANAGER:CreateControl("TC_Hdr"..i, grid, CT_LABEL)
            h:SetFont("ZoFontGameBold")
            h:SetText(L.shortDays[i])
            h:SetColor(0.9, 0.8, 0.5, 1)
            h:SetDimensions(65, 20)
            h:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            h:SetAnchor(TOPLEFT, grid, TOPLEFT, (i-1)*65, 0)
        end
    end
    local realToday = os.date("*t")
    local v = TC.viewDate
    local firstDayWday = os.date("*t", os.time{year=v.year, month=v.month, day=1}).wday
    local lastDay = os.date("*t", os.time{year=v.year, month=v.month+1, day=0}).day
    for i = 1, lastDay do
        local cellName = "TC_Cell"..i
        local cell = _G[cellName] or WINDOW_MANAGER:CreateControl(cellName, grid, CT_CONTROL)
        cell:SetHidden(false) cell:SetDimensions(60, 60) cell:SetMouseEnabled(true)
        local pos = i + (firstDayWday - 1) - 1
        cell:SetAnchor(TOPLEFT, grid, TOPLEFT, (pos % 7)*65, math.floor(pos / 7)*65 + 30)
        local bg = _G[cellName.."BG"] or WINDOW_MANAGER:CreateControl(cellName.."BG", cell, CT_BACKDROP)
        bg:SetAnchorFill() bg:SetEdgeTexture("", 8, 1, 2) bg:SetCenterColor(0, 0, 0, 0.5) bg:SetEdgeColor(0.5, 0.5, 0.5, 0.8)
        local lbl = _G[cellName.."Num"] or WINDOW_MANAGER:CreateControl(cellName.."Num", cell, CT_LABEL)
        lbl:SetAnchorFill() lbl:SetFont("ZoFontWinH4") lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER) lbl:SetVerticalAlignment(TEXT_ALIGN_CENTER) lbl:SetText(tostring(i))

        local holKey = HolidayDates[v.month] and HolidayDates[v.month][i]

        cell:SetHandler("OnMouseEnter", nil)
        if holKey then
            bg:SetCenterColor(0.4, 0.3, 0.1, 0.7) bg:SetEdgeColor(1, 0.8, 0, 1)
            cell:SetHandler("OnMouseEnter", function(s) ZO_Tooltips_ShowTextTooltip(s, TOP, "|cFFD700"..L.titleHoliday.."|r\n"..(L.hNames[holKey] or "Holiday")) end)
        end
        cell:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)
        if i == realToday.day and v.month == realToday.month and v.year == realToday.year then bg:SetEdgeColor(0, 1, 0, 1) end
    end
    TC.UpdateWindowContent()
end

-- 6. ФУНКЦИИ ПЕРЕКЛЮЧЕНИЯ (ДЛЯ БИНДОВ)
function TC.ToggleStrip()
    local isHidden = TamrielCalendarControl:IsHidden()
    TamrielCalendarControl:SetHidden(not isHidden)
    TC.savedVars.stripHidden = not isHidden
    if not isHidden == false then TC.UpdateUI() end
end

function TC.ToggleWindow()
    local isHidden = TamrielCalendarWindow:IsHidden()
    if isHidden then TC.viewDate = os.date("*t") TC.CreateCalendarGrid(true) end
    TamrielCalendarWindow:SetHidden(not isHidden)
end

function TC.OnMoveStop(control)
    local n = control:GetName()
    if not TC.savedVars.positions then TC.savedVars.positions = {} end
    TC.savedVars.positions[n] = {left = control:GetLeft(), top = control:GetTop()}
end

function TC.Initialize(eventCode, addOnName)
    if addOnName ~= TC.name then return end
    EVENT_MANAGER:UnregisterForEvent(TC.name, EVENT_ADD_ON_LOADED)

    local defaults = {
        stripHidden = false,
        positions = {},
        autoWidth = true,
        stripWidth = 650,
        stripHeight = 32,
        stripAlpha = 0.8,
        stripLocked = false,
        fontPath = "EsoUI/Common/Fonts/Univers67.otf",
        fontSize = 18,
        fontStyle = "soft-shadow-thick",
        showDayOfWeek = true,
        showDate = true,
        showYear = true,
        showSign = true,
        showTime = true,
    }

    TC.savedVars = ZO_SavedVars:NewAccountWide("TamrielCalendarVars", 2, nil, defaults, GetWorldName())

    for _, ctrl in pairs({TamrielCalendarControl, TamrielCalendarWindow}) do
        local n = ctrl:GetName()
        if TC.savedVars.positions[n] then
            local p = TC.savedVars.positions[n]
            ctrl:ClearAnchors() ctrl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, p.left, p.top)
        end
    end
    
    TC.ApplyVisualSettings()
    TC.RegisterSettings()

    TamrielCalendarControl:SetHidden(TC.savedVars.stripHidden)
    EVENT_MANAGER:RegisterForUpdate(TC.name, 1000, TC.UpdateUI)
    
    -- Привязываем функции к командам чата
    SLASH_COMMANDS["/tc"] = TC.ToggleStrip
    SLASH_COMMANDS["/tcal"] = TC.ToggleWindow
    TC.UpdateUI()
end

EVENT_MANAGER:RegisterForEvent(TC.name, EVENT_ADD_ON_LOADED, TC.Initialize)