-- ============================================
-- Lore Tooltips - Menu Konfiguracyjne
-- ============================================
LoreTooltips = LoreTooltips or {}

-- Domyślne kolory
local DEFAULT_COLOR_DIALOG = "00BFFF"
local DEFAULT_COLOR_BOOK   = "0033CC"
local DEFAULT_COLOR_JOURNAL = "00BFFF"

local function RGBToHex(r, g, b)
    return string.format("%02X%02X%02X", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
end

local function HexToRGB(hex)
    if not hex or #hex ~= 6 then return 1, 1, 1 end
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    return r, g, b
end

local function SyncColorSquare(colorControl)
    if not colorControl or not colorControl.control then return end
    
    local control = colorControl.control
    -- Szukamy dziecka o nazwie "Color" (zdefiniowane w Controls.xml biblioteki)
    local colorSquare = control:GetNamedChild("Color")
    
    if colorSquare and colorControl.getFunction then
        -- Pobieramy kolor za pomocą Twojej funkcji get (która zwróci już zresetowany kolor)
        local r, g, b, a = colorControl.getFunction()
        -- Ręcznie ustawiamy kolor na kwadraciku
        colorSquare:SetColor(r, g, b, a or 1)
    end
    
    -- Odświeżamy też tekst obok, jeśli biblioteka ma na to ochotę
    if colorControl.RefreshControl then colorControl:RefreshControl() end
end

function LoreTooltips.BuildMenu()
    local LHAS = LibHarvensAddonSettings
    if not LHAS then return end

    local L = LoreTooltips.L
    local settings = LHAS:AddAddon("Lore Tooltips")
    if not settings then return end

    -- SEKCJA: OGÓLNE
    settings:AddSetting({
        type = LHAS.ST_SECTION,
        label = L.MENU_OPTIONS_HEADER,
    })

    settings:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = L.MENU_DEBUG,
        tooltip = L.MENU_DEBUG_DESC,
        getFunction = function() return LoreTooltips.savedVars.debugMode end,
        setFunction = function(value) LoreTooltips.savedVars.debugMode = value end,
    })

    -- DIALOGI NPC
    settings:AddSetting({
        type = LHAS.ST_SECTION,
        label = L.MENU_COLOR_DIALOG,
    })

    local dialogColorControl = settings:AddSetting({
        type = LHAS.ST_COLOR,
        label = L.MENU_COLOR_DIALOG_PICKER,
        tooltip = L.MENU_COLOR_DIALOG_DESC,
        getFunction = function()
            local r, g, b = HexToRGB(LoreTooltips.savedVars.highlightColor or DEFAULT_COLOR_DIALOG)
            return r, g, b, 1
        end,
        setFunction = function(r, g, b, a)
            LoreTooltips.savedVars.highlightColor = RGBToHex(r, g, b)
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_BUTTON,
        label = L.MENU_RESET_COLOR_LABEL,
        buttonText = L.MENU_RESET_COLOR_BUTTON,
        clickHandler = function()
            LoreTooltips.savedVars.highlightColor = DEFAULT_COLOR_DIALOG
            SyncColorSquare(dialogColorControl)
        end,
    })

    -- KSIĄŻKI
    settings:AddSetting({
        type = LHAS.ST_SECTION,
        label = L.MENU_COLOR_BOOK,
    })

    local bookColorControl = settings:AddSetting({
        type = LHAS.ST_COLOR,
        label = L.MENU_COLOR_BOOK_PICKER,
        tooltip = L.MENU_COLOR_BOOK_DESC,
        getFunction = function()
            local r, g, b = HexToRGB(LoreTooltips.savedVars.highlightColorBook or DEFAULT_COLOR_BOOK)
            return r, g, b, 1
        end,
        setFunction = function(r, g, b, a)
            LoreTooltips.savedVars.highlightColorBook = RGBToHex(r, g, b)
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_BUTTON,
        label = L.MENU_RESET_COLOR_LABEL,
        buttonText = L.MENU_RESET_COLOR_BUTTON,
        clickHandler = function()
            LoreTooltips.savedVars.highlightColorBook = DEFAULT_COLOR_BOOK
            SyncColorSquare(bookColorControl)
        end,
    })

    -- DZIENNIK
    settings:AddSetting({
        type = LHAS.ST_SECTION,
        label = L.MENU_COLOR_JOURNAL,
    })

    local journalColorControl = settings:AddSetting({
        type = LHAS.ST_COLOR,
        label = L.MENU_COLOR_JOURNAL_PICKER,
        tooltip = L.MENU_COLOR_JOURNAL_DESC,
        getFunction = function()
            local r, g, b = HexToRGB(LoreTooltips.savedVars.highlightColorJournal or DEFAULT_COLOR_JOURNAL)
            return r, g, b, 1
        end,
        setFunction = function(r, g, b, a)
            LoreTooltips.savedVars.highlightColorJournal = RGBToHex(r, g, b)
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_BUTTON,
        label = L.MENU_RESET_COLOR_LABEL,
        buttonText = L.MENU_RESET_COLOR_BUTTON,
        clickHandler = function()
            LoreTooltips.savedVars.highlightColorJournal = DEFAULT_COLOR_JOURNAL
            SyncColorSquare(journalColorControl)
        end,
    })
end