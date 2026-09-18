TamrielCalendar = TamrielCalendar or {}
local TC = TamrielCalendar

function TC.RegisterSettings()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "Tamriel Calendar",
        displayName = "|c66f2ffTamriel Calendar|r",
        author = "|cff6401Soul_Hagans|r",
        slashCommand = "/tcsettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "header",
            name = "Внешний вид плашки",
        },
        {
            type = "checkbox",
            name = "Автоматическая ширина",
            tooltip = "Плашка сама подстраивает свою ширину под длину текста, чтобы слова никогда не обрезались.",
            getFunc = function() return TC.savedVars.autoWidth end,
            setFunc = function(value)
                TC.savedVars.autoWidth = value
                TC.ApplyVisualSettings()
                TC.UpdateUI()
            end,
            default = true,
        },
        {
            type = "slider",
            name = "Фиксированная ширина (px)",
            tooltip = "Работает, только если выключена автоматическая ширина.",
            min = 200,
            max = 1000,
            step = 10,
            getFunc = function() return TC.savedVars.stripWidth end,
            setFunc = function(value)
                TC.savedVars.stripWidth = value
                TC.ApplyVisualSettings()
            end,
            disabled = function() return TC.savedVars.autoWidth end,
            default = 650,
        },
        {
            type = "slider",
            name = "Высота плашки (px)",
            min = 20,
            max = 80,
            step = 2,
            getFunc = function() return TC.savedVars.stripHeight end,
            setFunc = function(value)
                TC.savedVars.stripHeight = value
                TC.ApplyVisualSettings()
            end,
            default = 32,
        },
        {
            type = "slider",
            name = "Прозрачность фона (%)",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return math.floor(TC.savedVars.stripAlpha * 100) end,
            setFunc = function(value)
                TC.savedVars.stripAlpha = value / 100
                TC.ApplyVisualSettings()
            end,
            default = 80,
        },
        {
            type = "checkbox",
            name = "Закрепить плашку",
            tooltip = "Блокирует случайное перемещение плашки мышью.",
            getFunc = function() return TC.savedVars.stripLocked end,
            setFunc = function(value)
                TC.savedVars.stripLocked = value
                TC.ApplyVisualSettings()
            end,
            default = false,
        },
        {
            type = "header",
            name = "Настройка шрифта и текста",
        },
        {
            type = "colorpicker",
            name = "Цвет текста",
            tooltip = "Выберите цвет текста на плашке.",
            getFunc = function()
                local c = TC.savedVars.textColor or {r = 0.9, g = 0.82, b = 0.5, a = 1}
                return c.r, c.g, c.b, c.a or 1
            end,
            setFunc = function(r, g, b, a)
                TC.savedVars.textColor = {r = r, g = g, b = b, a = a or 1}
                TC.ApplyVisualSettings()
            end,
            default = {r = 0.9, g = 0.82, b = 0.5, a = 1},
        },
        {
            type = "dropdown",
            name = "Гарнитура шрифта",
            choices = {
                "Системный Жирный (Univers Bold)",
                "Системный Обычный (Univers Regular)",
                "Системный Средний (Univers Medium)",
                "Игровой интерфейсный (Game UI)",
                "Книжный / Свитки (Antique)",
                "Рукописный / Записки (Handwritten)",
                "Каменная плита / Заголовки (Stone Tablet)",
            },
            choicesValues = {
                "$(BOLD_FONT)",
                "$(CHAT_FONT)",
                "$(MEDIUM_FONT)",
                "$(GAME_FONT)",
                "$(ANTIQUE_FONT)",
                "$(HANDWRITTEN_FONT)",
                "$(STONE_TABLET_FONT)",
            },
            getFunc = function() return TC.savedVars.fontPath end,
            setFunc = function(value)
                TC.savedVars.fontPath = value
                TC.ApplyVisualSettings()
                TC.UpdateUI()
            end,
            default = "$(BOLD_FONT)",
        },
        {
            type = "slider",
            name = "Размер шрифта (px)",
            min = 12,
            max = 36,
            step = 1,
            getFunc = function() return TC.savedVars.fontSize end,
            setFunc = function(value)
                TC.savedVars.fontSize = value
                TC.ApplyVisualSettings()
                TC.UpdateUI()
            end,
            default = 18,
        },
        {
            type = "dropdown",
            name = "Стиль тени / обводки",
            choices = {
                "Мягкая тень (Рекомендуется)",
                "Четкая тень",
                "Контур (Outline)",
                "Тонкая тень",
                "Без тени",
            },
            choicesValues = {
                "soft-shadow-thick",
                "shadow",
                "outline",
                "soft-shadow-thin",
                "",
            },
            getFunc = function() return TC.savedVars.fontStyle end,
            setFunc = function(value)
                TC.savedVars.fontStyle = value
                TC.ApplyVisualSettings()
                TC.UpdateUI()
            end,
            default = "soft-shadow-thick",
        },
        {
            type = "header",
            name = "Отображаемые элементы",
        },
        {
            type = "checkbox",
            name = "День недели",
            tooltip = "Показывать день недели (Сандас, Морндас...)",
            getFunc = function() return TC.savedVars.showDayOfWeek end,
            setFunc = function(value)
                TC.savedVars.showDayOfWeek = value
                TC.UpdateUI()
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Число и месяц",
            tooltip = "Показывать число и месяц (14 Утренней звезды...)",
            getFunc = function() return TC.savedVars.showDate end,
            setFunc = function(value)
                TC.savedVars.showDate = value
                TC.UpdateUI()
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Год и эра",
            tooltip = "Показывать год (582 год 2-й эры)",
            getFunc = function() return TC.savedVars.showYear end,
            setFunc = function(value)
                TC.savedVars.showYear = value
                TC.UpdateUI()
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Знак зодиака",
            tooltip = "Показывать текущее созвездие (Знак: Ритуал...)",
            getFunc = function() return TC.savedVars.showSign end,
            setFunc = function(value)
                TC.savedVars.showSign = value
                TC.UpdateUI()
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Время Тамриэля",
            tooltip = "Показывать игровое время (часы и минуты)",
            getFunc = function() return TC.savedVars.showTime end,
            setFunc = function(value)
                TC.savedVars.showTime = value
                TC.UpdateUI()
            end,
            default = true,
        },
    }

    LAM:RegisterAddonPanel("TamrielCalendarOptions", panelData)
    LAM:RegisterOptionControls("TamrielCalendarOptions", optionsData)
end