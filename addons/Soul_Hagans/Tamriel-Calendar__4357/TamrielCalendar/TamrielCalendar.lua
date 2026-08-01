TamrielCalendar = TamrielCalendar or {}
local TC = TamrielCalendar
TC.name = "TamrielCalendar"

-- 1. СТРОКИ
ZO_CreateStringId("SI_BINDING_NAME_TC_TOGGLE_UI", "Показать/Скрыть плашку")
ZO_CreateStringId("SI_BINDING_NAME_TC_TOGGLE_WINDOW", "Открыть большой календарь")

-- 2. ЛОКАЛИЗАЦИЯ
local LStrings = {
    ru = {
        days = {"Сандас", "Морндас", "Тирдас", "Миддас", "Турдас", "Фредас", "Лоредас"},
        shortDays = {"Сн", "Мн", "Тд", "Мд", "Тр", "Фр", "Лр"},
        months = {"Утренней звезды", "Восхода солнца", "Первоцвета", "Руки дождя", "Второго зерна", "Середины года", "Высокого солнца", "Последнего зерна", "Огня очага", "Начала морозов", "Заката солнца", "Вечерней звезды"},
        realMonths = {"Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"},
        signs = {"Ритуал", "Любовник", "Лорд", "Маг", "Тени", "Конь", "Ученик", "Воин", "Леди", "Башня", "Атронах", "Вор", "Змей"},
        moonPhases = {"Новолуние", "Растущий серп", "Первая четверть", "Растущая луна", "Полнолуние", "Убывающая луна", "Последняя четверть", "Убывающий серп"},
        yearSuffix = "год 2-й эры", monthPrefix = "Месяц", signPrefix = "Знак:", stripFormat = "%s, %d %s %d г. | %s | %02d:%02d",
        titleHoliday = "День праздника (Лор):", btnPrev = "Назад", btnNext = "Вперед",
        hNames = { nl="Фестиваль Новой жизни", hd="День Сердец (Сангвин)", aj="Юбилей ESO", jd="День Шута", zz="День Зенитара", my="Середина года (Пелинал)", wf="Фестиваль Ведьм", ud="День Воина (Неустрашимые)", ol="Старая жизнь" }
    },
    en = {
        days = {"Sundas", "Morndas", "Tirdas", "Middas", "Turdas", "Fredas", "Loredas"},
        shortDays = {"Su", "Mo", "Tu", "We", "Th", "Fr", "Lo"},
        months = {"Morning Star", "Sun's Dawn", "First Seed", "Rain's Hand", "Second Seed", "Midyear", "Sun's Height", "Last Seed", "Hearthfire", "Frostfall", "Sun's Dusk", "Evening Star"},
        realMonths = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"},
        signs = {"Ritual", "Lover", "Lord", "Mage", "Shadow", "Steed", "Apprentice", "Warrior", "Lady", "Tower", "Atronach", "Thief", "Serpent"},
        moonPhases = {"New Moon", "Waxing Crescent", "First Quarter", "Waxing Gibbous", "Full Moon", "Waning Gibbous", "Last Quarter", "Waning Crescent"},
        yearSuffix = "year of 2nd Era", monthPrefix = "Month of", signPrefix = "Sign:", stripFormat = "%s, %d %s %d | %s | %02d:%02d",
        titleHoliday = "Holiday (Lore):", btnPrev = "Prev", btnNext = "Next",
        hNames = { nl="New Life Festival", hd="Heart's Day (Sanguine)", aj="ESO Anniversary", jd="Jester's Day", zz="Zenithar's Day", my="Midyear (Pelinal)", wf="Witches Festival", ud="Warrior's Day", ol="Old Life" }
    },
    de = {
        days = {"Sandas", "Morndas", "Tirdas", "Middas", "Turdas", "Fredas", "Loredas"}, shortDays = {"Sa", "Mo", "Ti", "Mi", "Tu", "Fr", "Lo"},
        months = {"Morgenstern", "Sonnendämmerung", "Erstsaat", "Regenhand", "Zweitsaat", "Mittjahr", "Sonnenerhöhung", "Letzte Saat", "Herzfeuer", "Eisfall", "Sonnenuntergang", "Abendstern"},
        realMonths = {"Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"},
        signs = {"Das Ritual", "Die Liebenden", "Der Fürst", "Der Magier", "Der Schatten", "Das Ross", "Der Lehrling", "Der Krieger", "Die Fürstin", "Der Turm", "Der Atronach", "Die Diebin", "Die Schlange"},
        moonPhases = {"Neumond", "Zunehmende Sichel", "Erstes Viertel", "Zunehmender Mond", "Vollmond", "Abnehmender Mond", "Letztes Viertel", "Abnehmende Sichel"},
        yearSuffix = "Jahr der 2. Ära", monthPrefix = "Monat", signPrefix = "Sternzeichen:", stripFormat = "%s, %d. %s %d | %s | %02d:%02d",
        titleHoliday = "Feiertag:", btnPrev = "Zurück", btnNext = "Weiter",
        hNames = { nl="Neujahrsfest", hd="Herztag", aj="ESO-Jubiläum", jd="Tag der Narren", zz="Tag von Zenithar", my="Mittjahr-Feier", wf="Hexenfest", ud="Kriegerfest" }
    },
    fr = {
        days = {"Sandaas", "Morndaas", "Tirdaas", "Middaas", "Turdaas", "Fredaas", "Loredaas"}, shortDays = {"Sa", "Mo", "Ti", "Mi", "Tu", "Fr", "Lo"},
        months = {"Étoile du matin", "Clair de ciel", "Premier semer", "Pluie de main", "Deuxième semer", "Mi-l'an", "Haut zénith", "Dernier semer", "Âtrefeu", "Soufflegivre", "Sommeil du soleil", "Étoile du soir"},
        realMonths = {"Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"},
        signs = {"Le Rituel", "L'Amant", "Le Seigneur", "Le Mage", "L'Ombre", "Le Destrier", "L'Apprenti", "Le Guerrier", "La Dame", "La Tour", "L'Atronach", "Le Voleur", "Le Serpent"},
        moonPhases = {"Nouvelle lune", "Premier croissant", "Premier quartier", "Lune gibbeuse", "Pleine lune", "Lune décroissante", "Dernier quartier", "Dernier croissant"},
        yearSuffix = "2ème Ère", monthPrefix = "Mois de", signPrefix = "Signe:", stripFormat = "%s, %d %s %d | %s | %02d:%02d",
        titleHoliday = "Jour férié:", btnPrev = "Précédent", btnNext = "Suivant",
        hNames = { nl="Nouvelle vie", hd="Jour du Coeur", aj="Jubilé ESO", jd="Jour de la Farce", zz="Jour de Zenithar", wf="Festival des Sorcières" }
    },
    es = {
        days = {"Sandas", "Morndas", "Tirdas", "Middas", "Turdas", "Fredas", "Loredas"}, shortDays = {"Sa", "Mo", "Ti", "Mi", "Tu", "Fr", "Lo"},
        months = {"Estrella del Alba", "Amanecer", "Semilla Primera", "Mano de Lluvia", "Segunda Semilla", "Mitad del Año", "Cénit del Sol", "Última Semilla", "Fuego del Hogar", "Helada", "Ocaso", "Estrella del Sur"},
        realMonths = {"Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"},
        signs = {"El Ritual", "El Amante", "El Señor", "El Mago", "La Sombra", "El Corcel", "El Aprendiz", "El Guerrero", "La Dama", "La Tower", "El Atromach", "El Ladrón", "El Serpiente"},
        moonPhases = {"Luna nueva", "Luna creciente", "Cuarto creciente", "Gibosa creciente", "Luna llena", "Gibosa menguante", "Cuarto menguante", "Luna menguante"},
        yearSuffix = "2.ª Era", monthPrefix = "Mes de", signPrefix = "Signo:", stripFormat = "%s, %d de %s %d | %s | %02d:%02d",
        titleHoliday = "Festividad:", btnPrev = "Anterior", btnNext = "Siguiente",
        hNames = { nl="Nueva Vida", hd="Día del Corazón", aj="Aniversario ESO", jd="Día del Bufón", my="Midyear", wf="Festival de las Brujas" }
    }
}
-- DE, FR, ES наследуют из EN в Initialize

local HolidayDates = { [1]={[1]="nl"}, [2]={[16]="hd"}, [4]={[4]="aj",[28]="jd"}, [5]={[16]="zz"}, [6]={[16]="my"}, [10]={[13]="wf"}, [11]={[20]="ud"}, [12]={[30]="ol"} }

local lang = GetCVar("language.2")
if not LStrings[lang] then lang = "en" end
local L = LStrings[lang]

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

-- 4. УПРАВЛЕНИЕ ОКНОМ
function TC.ChangeMonth(delta)
    local m = TC.viewDate.month + delta
    local y = TC.viewDate.year
    if m > 12 then m = 1 y = y + 1 elseif m < 1 then m = 12 y = y - 1 end
    TC.viewDate.month = m TC.viewDate.year = y
    TC.CreateCalendarGrid(true)
end

function TC.UpdateUI()
    if not TamrielCalendarControl or TamrielCalendarControl:IsHidden() then return end
    local date = os.date("*t")
    local h, m = TC.GetTamrielTime()
    local tamYear = 582 + (date.year - 2014)
    TamrielCalendarLabel:SetText(string.format(L.stripFormat, L.days[date.wday], date.day, L.months[date.month], tamYear, L.signs[date.month], h, m))
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
    TC.savedVars = ZO_SavedVars:NewAccountWide("TamrielCalendarVars", 2, nil, {stripHidden = false, positions = {}}, GetWorldName())
    
    -- Наследование недостающих строк
    for langKey, table in pairs(LStrings) do
        if langKey ~= "en" then
            for k,v in pairs(LStrings.en) do if not table[k] then table[k] = v end end
            for k,v in pairs(LStrings.en.hNames) do if not table.hNames[k] then table.hNames[k] = v end end
        end
    end

    for _, ctrl in pairs({TamrielCalendarControl, TamrielCalendarWindow}) do
        local n = ctrl:GetName()
        if TC.savedVars.positions[n] then
            local p = TC.savedVars.positions[n]
            ctrl:ClearAnchors() ctrl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, p.left, p.top)
        end
    end
    
    TamrielCalendarControl:SetHidden(TC.savedVars.stripHidden)
    EVENT_MANAGER:RegisterForUpdate(TC.name, 1000, TC.UpdateUI)
    
    -- Привязываем функции к командам чата
    SLASH_COMMANDS["/tc"] = TC.ToggleStrip
    SLASH_COMMANDS["/tcal"] = TC.ToggleWindow
    TC.UpdateUI()
end

EVENT_MANAGER:RegisterForEvent(TC.name, EVENT_ADD_ON_LOADED, TC.Initialize)