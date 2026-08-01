-- ============================================
-- Lore Tooltips - Manager Baz Danych (Tryb Wyłączności)
-- ============================================

LoreTooltips = LoreTooltips or {}
LoreTooltips.Databases = LoreTooltips.Databases or {}
LoreTooltips.Database = {} 

-- Zmienna przechowująca status ładowania, aby wyświetlić go później na czacie
LoreTooltips.LoadStatus = {
    result = "none", -- "success", "error_conflict", "error_none"
    details = ""
}

LoreTooltips.DatabaseConfig = {
    supportedLibraries = {
        "LibLoreLibraryCesarska", -- Zaktualizowana nazwa
        "LibLoreLibraryUESP",     -- Zaktualizowana nazwa
        "CesarskaBiblioteka",     -- (Kompatybilność wsteczna)
        "UESP_EN",                -- (Kompatybilność wsteczna)
    }
}

-- ============================================
-- 1. Inicjalizacja (Działa w tle przy starcie)
-- ============================================

function LoreTooltips.InitializeDatabases()
    LoreTooltips.Database = {}
    local detectedLibs = {}
    local supportedLibs = LoreTooltips.DatabaseConfig.supportedLibraries

    -- Wykrywanie
    for _, libName in ipairs(supportedLibs) do
        if LoreTooltips.Databases[libName] then
            table.insert(detectedLibs, libName)
        end
    end
    local libCount = #detectedLibs

    -- Walidacja: Konflikt
    if libCount > 1 then
        LoreTooltips.LoadStatus.result = "error_conflict"
        LoreTooltips.LoadStatus.details = table.concat(detectedLibs, ", ")
        return
    end

    -- Walidacja: Brak
    if libCount == 0 then
        LoreTooltips.LoadStatus.result = "error_none"
        return
    end

    -- Sukces: Ładowanie
    local activeSourceName = detectedLibs[1]
    local dbObj = LoreTooltips.Databases[activeSourceName]
    
    if not dbObj or not dbObj.entries then return end

    local count = 0
    for key, entry in pairs(dbObj.entries) do
        if not entry.sourceName then entry.sourceName = dbObj.source or activeSourceName end
        LoreTooltips.Database[key] = entry
        count = count + 1
    end

    -- Zapisujemy sukces
    LoreTooltips.LoadStatus.result = "success"
    LoreTooltips.LoadStatus.details = (dbObj.source or activeSourceName)
    LoreTooltips.LoadStatus.count = count
end

-- ============================================
-- 2. Raportowanie (Wielojęzyczne)
-- ============================================

function LoreTooltips.PrintLoadStatus()
    local status = LoreTooltips.LoadStatus
    -- Pobieramy załadowaną tabelę językową (lub pustą, żeby nie wywaliło błędu)
    local L = LoreTooltips.L or {} 
    
    -- Helper do bezpiecznego pobierania tekstu (gdyby brakowało tłumaczenia)
    local function GetText(key, default)
        return L[key] or default or key
    end

    if status.result == "error_conflict" then
        d(" ")
        d("|cFF0000[LoreTooltips] " .. GetText("DB_CRITICAL_ERROR", "ERROR") .. ":|r " .. GetText("DB_CONFLICT_HEADER", "Conflict!"))
        d(zo_strformat(GetText("DB_CONFLICT_DESC"), status.details))
        d(GetText("DB_CONFLICT_ACTION"))
        
    elseif status.result == "error_none" then
        d(" ")
        d("|cFF0000[LoreTooltips] " .. GetText("DB_WARNING_HEADER", "WARNING") .. ":|r " .. GetText("DB_MISSING_HEADER", "Missing DB"))
        d(GetText("DB_MISSING_DESC"))
        
    elseif status.result == "success" then
        local msg = zo_strformat(GetText("DB_SUCCESS_LOADED"), status.details, status.count)
        d("|ce6db5f[LoreTooltips]|r " .. msg)
        
    end
end