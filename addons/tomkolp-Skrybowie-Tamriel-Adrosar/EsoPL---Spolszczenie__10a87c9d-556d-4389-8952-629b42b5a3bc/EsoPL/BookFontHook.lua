-- -----------------------------------------------------------------
-- STRAŻNIK (GUARD)
-- -----------------------------------------------------------------
EsoPL_BookHook_Guard = EsoPL_BookHook_Guard or {}
if EsoPL_BookHook_Guard.Original_GetBookMediumFontInfo then
    return
end
-- -----------------------------------------------------------------

-- 1. Zapisz oryginalną funkcję w BEZPIECZNYM miejscu
EsoPL_BookHook_Guard.Original_GetBookMediumFontInfo = GetBookMediumFontInfo

-- 2. Zdefiniuj nasze czcionki (NAZWY)
local antiqueFont     = "EsoPL/fonts/ProseAntique.slug"      -- Główna czcionka (Książkowa)
local handwrittenFont = "EsoPL/fonts/handwritten_bold.slug"  -- Odręczna (pogrubiona)
local tabletFont      = "EsoPL/fonts/trajanpro-regular.slug" -- Tytułowa (Trajan/Rzymska)


-- 3. Nadpisz globalną funkcję naszą nową funkcją
GetBookMediumFontInfo = function (mediumId, isGamepad)
    
    -- 4. Pobierz WSZYSTKIE 14 oryginalnych wartości (rozmiary, kolory itd.)
    local titleFontName, titleFontSize, titleFontStyle, bodyFontName, bodyFontSize, bodyFontStyle, fontColorR, fontColorG, fontColorB, fontColorA, fontStyleColorR, fontStyleColorG, fontStyleColorB, fontStyleColorA = EsoPL_BookHook_Guard.Original_GetBookMediumFontInfo(mediumId, isGamepad)
    
    -- 5. Sprawdź ID i podmień TYLKO NAZWĘ czcionki
    
    if mediumId == 1 or mediumId == 2 or mediumId == 3 or mediumId == 8 or mediumId == 9 then
        -- PAPER, SKIN, RUBBING, RARE, BLACKMAIL
        titleFontName = antiqueFont
        bodyFontName = antiqueFont
        
    elseif mediumId == 4 or mediumId == 5 or mediumId == 6 or mediumId == 10 or mediumId == 11 then
        -- LETTER, NOTE, SCROLL, JOURNAL, PARCHMENT
        titleFontName = handwrittenFont
        bodyFontName = handwrittenFont
        
    elseif mediumId == 7 then
        -- TABLET
        titleFontName = tabletFont
        bodyFontName = tabletFont
    end

    -- 6. Zwróć zmodyfikowane nazwy, ale ORYGINALNE rozmiary i kolory
    return titleFontName, titleFontSize, titleFontStyle, bodyFontName, bodyFontSize, bodyFontStyle, fontColorR, fontColorG, fontColorB, fontColorA, fontStyleColorR, fontStyleColorG, fontStyleColorB, fontStyleColorA
end

-- -----------------------------------------------------------------
-- FIX: TAMRIEL TOMES (Naprawa brakujących fontów PL)
-- -----------------------------------------------------------------
-- Opis: Wymusza użycie polskich czcionek w nowym oknie intro Tamriel Tomes,
-- ponieważ domyślny interfejs (XML) nie posiada definicji fontów obsługujących polskich znaków.
-- -----------------------------------------------------------------

-- Funkcja pomocnicza: Tworzy sformatowany string definicji czcionki dla ESO
local function GetEsoFontString(path, size, style)
    return string.format("%s|%d|%s", path, size, style)
end

SecurePostHook(ZO_TamrielTomesIntroScreen_Shared, "ShowTomeInfo", function(self)
    
    -- 1. SEKCJA LEWA: GŁÓWNY TYTUŁ KSIĘGI
    if self.titleLabel then
        self.titleLabel:SetFont(GetEsoFontString(antiqueFont, 48, "none"))
        self.titleLabel:SetColor(0.1, 0.1, 0.1, 1) -- Kolor: Ciemny grafit
    end

    -- 2. SEKCJA PRAWA: LISTA NOWOŚCI I OPISÓW
    if self.highlightsControlPool then
        local activeControls = self.highlightsControlPool:GetActiveObjects()
        
        -- Iteracja przez wszystkie aktywne elementy listy
        for _, control in pairs(activeControls) do
            
            -- A. Nagłówki sekcji (np. "Strefa wydarzenia")
            if control.titleLabel then
                -- Wymuszenie ProseAntique, rozmiar 34.
                -- Używamy tej samej czcionki co w treści, różnicując tylko rozmiarem.
                control.titleLabel:SetFont(GetEsoFontString(antiqueFont, 34, "none"))
                control.titleLabel:SetColor(0.1, 0.1, 0.1, 1)
            end
            
            -- B. Treść opisu (np. "Zbadaj ten zakątek...")
            if control.bodyTextLabel then
                -- Wymuszenie ProseAntique, rozmiar 22.
                control.bodyTextLabel:SetFont(GetEsoFontString(antiqueFont, 22, "none"))
                control.bodyTextLabel:SetColor(0.1, 0.1, 0.1, 1)
            end
        end
    end
end)