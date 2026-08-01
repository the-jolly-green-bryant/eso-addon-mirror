local mapFont = "EsoPL/fonts/handwritten_bold.slug|34"
local mapFontIndex = 0

local function fixMapFontPL()
    local fail = 0
    -- Przeszukujemy elementy mapy od ostatniego indeksu do 999
    for i = mapFontIndex, 999 do
        local ctrl = _G["ZO_WorldMapContainerBlobName" .. i]
        if ctrl then
            fail = 0
            local font = ctrl:GetFont()
            -- Jeśli czcionka to systemowy "Handwritten", zamień na naszą
            if font:find("Handwritten") then
                ctrl:SetFont(mapFont)
                mapFontIndex = i + 1
            end
        else
            fail = fail + 1
            -- Jeśli 3 razy z rzędu nie znajdziemy kontrolki, przerywamy pętlę w tej klatce
            if fail >= 3 then
                break
            end
        end
    end
end

local function refreshMapFontPL()
    -- Reset indeksu co 60 sekund, aby sprawdzić stare elementy ponownie
    mapFontIndex = 0
end

function EsoPL.InitMapFonts()
    -- Uruchom tylko jeśli język to polski
    if GetCVar("language.2") ~= "pl" then return end

    -- Rejestracja pętli aktualizacyjnych
    EVENT_MANAGER:RegisterForUpdate("EsoPL_FixMapFont", 1000, fixMapFontPL)      -- Co 1 sekunda
    EVENT_MANAGER:RegisterForUpdate("EsoPL_RefreshMapFont", 60000, refreshMapFontPL) -- Co 60 sekund
end