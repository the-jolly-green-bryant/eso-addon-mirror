local ADDON_NAME = "EsoPL"
local EsoPL = _G[ADDON_NAME]

function EsoPL.InitChampion()
    -- Uruchamiaj tylko w trybie Gamepada (interfejs konsolowy)
    if not IsInGamepadPreferredMode() then 
        return 
    end

    -- Próba pobrania bazy skilli (obsługa różnych struktur zmiennych)
    local abilityDB
    if EsoPL.Data and EsoPL.Data.Abilities then
        abilityDB = EsoPL.Data.Abilities
    elseif _G.EsoPL_SkillDB_EN and _G.EsoPL_SkillDB_EN.Abilities then
        abilityDB = _G.EsoPL_SkillDB_EN.Abilities
    else
        d("EsoPL: BŁĄD - Nie znaleziono bazy nazw skilli (SkillDB)!")
        return
    end
    
    local originalGetChampionSkillName = _G.GetChampionSkillName
    local originalTooltipString = GetString(SI_ABILITY_TOOLTIP_NAME)

    -- Funkcja pomocnicza do formatowania nazwy
    local function GetFormattedChampionName(championSkillId, polName)
        local mode = EsoPL.GetChampionMode() -- pl / en / plen / enpl
        
        if mode == "pl" then
            return polName
        end

        local abilityId = GetChampionAbilityId(championSkillId)
        
        -- Jeśli brak tłumaczenia, zwróć polską nazwę
        if not abilityId or not abilityDB[abilityId] then
            return polName
        end

        local engName = abilityDB[abilityId]

        if mode == "plen" then
            return string.format("%s (%s)", polName, engName)
        elseif mode == "enpl" then
            return string.format("%s (%s)", engName, polName)
        elseif mode == "en" then
            return engName
        end

        return polName
    end

    --------------------------------------------------------------------------------
    -- 1. Nadpisanie nazwy na środku ekranu (Center Info)
    --------------------------------------------------------------------------------
    _G.GetChampionSkillName = function(championSkillId)
        local polName = originalGetChampionSkillName(championSkillId)
        return GetFormattedChampionName(championSkillId, polName)
    end

    --------------------------------------------------------------------------------
    -- 2. Hook pod Tooltipy Gamepada (Boczny panel ze szczegółami)
    --------------------------------------------------------------------------------
    -- Ten hook działa tuż przed wyświetleniem okienka z opisem
    ZO_PreHook(ZO_ChampionSkillStar, "ShowGamepadTooltip", function(self)
        local championSkillData = self:GetChampionSkillData()
        if not championSkillData then return end
        
        local championSkillId = championSkillData:GetId()
        local polName = originalGetChampionSkillName(championSkillId)
        
        local formattedName = GetFormattedChampionName(championSkillId, polName)
        
        if formattedName and formattedName ~= "" then
            -- Podmieniamy tymczasowo globalny ciąg tekstowy nagłówka
            SafeAddString(SI_ABILITY_TOOLTIP_NAME, formattedName, 100)
        end
    end)

    -- Ten hook działa po wyświetleniu, przywracając stan pierwotny
    ZO_PostHook(ZO_ChampionSkillStar, "ShowGamepadTooltip", function(self)
        SafeAddString(SI_ABILITY_TOOLTIP_NAME, originalTooltipString, 100)
    end)
    
    -- Komunikat diagnostyczny (tylko do testów, można usunąć później)
    d("EsoPL: Moduł Mistrzostwa (Champion) załadowany poprawnie.")
end