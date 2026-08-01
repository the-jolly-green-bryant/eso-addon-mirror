-- ============================================================================
-- DolgubonsLazyWritCreator - Localizzazione Italiana
-- Parte di TraduzioneItalianaESO
-- ============================================================================

WritCreater = WritCreater or {}
WritCreater.name = WritCreater.name or "DolgubonsLazyWritCreator"
WritCreater.Strings = WritCreater.Strings or {}

-- ============================================================================
-- SOGGETTI POSTA (HIRELING)
-- IMPORTANTE: deve stare QUI, in cima, PRIMA di tutto il resto,
-- altrimenti l'addon originale lo sovrascrive durante il suo init.
-- Usa chiavi esatte + metatable case-insensitive ESATTO (non :find() parziale).
-- ============================================================================

WritCreater.hirelingMailSubjects = WritCreater.hirelingMailSubjects or {}
WritCreater.hirelingMailSubjects["Materiali grezzi da sarto"]       = true
WritCreater.hirelingMailSubjects["Materiali grezzi da fabbro"]      = true
WritCreater.hirelingMailSubjects["Materiali grezzi da falegname"]   = true
WritCreater.hirelingMailSubjects["Materiali grezzi da incantatore"] = true
WritCreater.hirelingMailSubjects["Materiali grezzi da alchimista"]  = true
WritCreater.hirelingMailSubjects["Materiali grezzi da cuoco"]       = true
WritCreater.hirelingMailSubjects["Materiali grezzi da gioielliere"] = true
WritCreater.hirelingMailSubjects["Borsa del Sarto"]                 = true
WritCreater.hirelingMailSubjects["Borsa del Sarto (Stoffa) I"]      = true
WritCreater.hirelingMailSubjects["Cassa del Fabbro"]                = true
WritCreater.hirelingMailSubjects["Valigetta del Falegname I"]       = true
WritCreater.hirelingMailSubjects["Scrigno dell'Incantatore"]        = true
WritCreater.hirelingMailSubjects["Recipiente dell'Alchimista"]      = true
WritCreater.hirelingMailSubjects["Borsa del Cuoco"]                 = true
WritCreater.hirelingMailSubjects["Cassa del Gioielliere"]           = true
WritCreater.hirelingMailSubjects["Ingredienti da cucina grezzi"]    = true
WritCreater.hirelingMailSubjects["POSTA DI SISTEMA"]                = true
WritCreater.hirelingMailSubjects["Posta di sistema"]                = true

local function normalizeMailSubject(subject)
    return type(subject) == "string" and subject:lower() or ""
end

local originalHirelingMailCheck = WritCreater.hirelingMailSubjects
WritCreater.hirelingMailSubjects = setmetatable({}, {
    __index = function(t, key)
        local normalizedKey = normalizeMailSubject(key)
        for subject, value in pairs(originalHirelingMailCheck) do
            if normalizeMailSubject(subject) == normalizedKey then
                return value
            end
        end
        return nil
    end
})

-- ============================================================================
-- NOMI E STRINGHE LOCALIZZATE
-- ============================================================================

function WritCreater.langWritNames()
    return {
        ["G"] = "Commissione",
        [CRAFTING_TYPE_ENCHANTING]      = "Incantatore",
        [CRAFTING_TYPE_BLACKSMITHING]   = "Fabbro",
        [CRAFTING_TYPE_CLOTHIER]        = "Sarto",
        [CRAFTING_TYPE_PROVISIONING]    = "Cuoco",
        [CRAFTING_TYPE_WOODWORKING]     = "Falegname",
        [CRAFTING_TYPE_ALCHEMY]         = "Alchimista",
        [CRAFTING_TYPE_JEWELRYCRAFTING] = "Gioielliere",
    }
end

function WritCreater.langCraftKernels()
    return WritCreater.langWritNames()
end

function WritCreater.writCompleteStrings()
    return {
        ["place"]        = "Metti la merce nella cassa",
        ["sign"]         = "Firma il manifesto",
        ["masterPlace"]  = "Ho terminato",
        ["masterSign"]   = "<Termina il lavoro.>",
        ["masterStart"]  = "<Accetta il contratto.>",
        ["Rolis Hlaalu"] = "Rolis Hlaalu",
        ["Deliver"]      = "Consegna",
        ["Acquire"]      = "ottieni",
    }
end

function WritCreater.questExceptions(condition)
    if not condition or type(condition) ~= "string" then
        return condition
    end

    -- Normalizza spazi non-breaking
    condition = condition:gsub("\xc2\xa0", " ")

    local lower = condition:lower()

    -- Variante Cuoco: "Posiziona la merce nella cassa" -> normalizzata a "Metti"
    if lower:find("posiziona la merce nella cassa", 1, true) then
        return "Metti la merce nella cassa"
    end

    -- Flavour text della cassa (per sicurezza)
    if lower:find("la cassa contiene ampio spazio", 1, true) then
        return "Metti la merce nella cassa"
    end

    return condition
end

function WritCreater.langStationNames()
    return {
        ["Postazione da fabbro"]      = 1,
        ["Postazione da sarto"]       = 2,
        ["Tavolo da incantamento"]    = 3,
        ["Postazione da alchimista"]  = 4,
        ["Focolare da cucina"]        = 5,
        ["Postazione da falegname"]   = 6,
        ["Postazione da gioielliere"] = 7,
    }
end

WritCreater.lang = "it"
WritCreater.langIsMasterWritSupported = true

-- ============================================================================
-- AUTO-ACCEPT WRIT
-- ============================================================================

local function OnQuestOffered(eventCode)
    EVENT_MANAGER:UnregisterForEvent(WritCreater.name, EVENT_QUEST_OFFERED)
    AcceptOfferedQuest()
end

local function OnChatterBegin(eventCode, optionCount)
    if optionCount == 0 then return end

    if not WritCreater or type(WritCreater.GetSettings) ~= "function" then return end
    local settings = WritCreater:GetSettings()
    if not settings or not settings.autoAccept then return end

    for i = 1, optionCount do
        local text, optType = GetChatterOption(i)
        if text then
            local lower = text:lower()
            if lower:find("commissione", 1, true) or lower:find("commissioni", 1, true) then
                EVENT_MANAGER:RegisterForEvent(
                    WritCreater.name,
                    EVENT_QUEST_OFFERED,
                    OnQuestOffered
                )
                SelectChatterOption(i)
                return
            end
        end
    end
end

EVENT_MANAGER:RegisterForEvent(
    WritCreater.name .. "_LangIt_AutoAccept",
    EVENT_CHATTER_BEGIN,
    OnChatterBegin
)

-- ============================================================================
-- NOMI DEI CONTENITORI
-- ============================================================================

function WritCreater.GetContainerNames()
    local containers = {}
    local romans = {"I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"}

    local function add(name, rank, craft)
        containers[name] = {rank, craft}
        local nameCap = name:gsub(" del ", " Del "):gsub(" dell'", " Dell'")
        if nameCap ~= name then
            containers[nameCap] = {rank, craft}
        end
    end

    local function addAll(baseName, craft)
        for i = 1, 10 do
            add(baseName, i, craft)
            add(baseName .. " " .. tostring(i), i, craft)
            if romans[i] then
                add(baseName .. " " .. romans[i], i, craft)
            end
        end
    end

    addAll("Cassa del Fabbro",           CRAFTING_TYPE_BLACKSMITHING)
    addAll("Borsa del Sarto",            CRAFTING_TYPE_CLOTHIER)
    addAll("Borsa del Sarto (Stoffa)",   CRAFTING_TYPE_CLOTHIER)
    addAll("Borsa del Sarto (Cuoio)",    CRAFTING_TYPE_CLOTHIER)
    addAll("Valigetta del Falegname",    CRAFTING_TYPE_WOODWORKING)
    addAll("Scrigno dell'Incantatore",   CRAFTING_TYPE_ENCHANTING)
    addAll("Recipiente dell'Alchimista", CRAFTING_TYPE_ALCHEMY)
    addAll("Borsa del Cuoco",            CRAFTING_TYPE_PROVISIONING)
    addAll("Cassa del Gioielliere",      CRAFTING_TYPE_JEWELRYCRAFTING)

    return containers
end

function WritCreater.GetBoxNames()
    local boxNames = {}
    for name, data in pairs(WritCreater.GetContainerNames()) do
        boxNames[name] = data
    end
    boxNames["Scatola Regalo del Giubileo"]  = {0, 0}
    boxNames["Scatola di Zenithar"]          = {0, 0}
    boxNames["Scatola Gloriosa di Zenithar"] = {0, 0}
    return boxNames
end

-- ============================================================================
-- INIZIALIZZAZIONE
-- ============================================================================

local function InitializeItalianSupport()
    if not WritCreater.boxNames then
        WritCreater.boxNames = {}
    end
    local count = 0
    for name, data in pairs(WritCreater.GetBoxNames()) do
        WritCreater.boxNames[name] = data
        count = count + 1
    end
    -- FIX: d() protetta, non è sempre disponibile fuori dalla modalità debug
    if type(d) == "function" then
        d("[WritCreator ITA] Inizializzato: " .. count .. " container registrati")
    end
end

EVENT_MANAGER:RegisterForEvent("WritCreatorItalian", EVENT_ADD_ON_LOADED, function(event, addonName)
    if addonName == "DolgubonsLazyWritCreator" then
        zo_callLater(InitializeItalianSupport, 2000)
        EVENT_MANAGER:UnregisterForEvent("WritCreatorItalian", EVENT_ADD_ON_LOADED)
    end
end)

-- ============================================================================
-- COMANDI DEBUG
-- ============================================================================

SLASH_COMMANDS["/writquest"] = function()
    if type(d) ~= "function" then return end
    d("[WritCreator ITA] === CONDIZIONI QUEST ATTIVE ===")
    local found = 0
    for i = 1, GetJournalQuestCount() do
        local name = GetJournalQuestName(i)
        local numSteps = GetJournalQuestNumSteps(i)
        for step = 1, numSteps do
            local numCond = GetJournalQuestNumConditions(i, step)
            for j = 1, numCond do
                local txt = GetJournalQuestConditionInfo(i, step, j)
                if txt and txt ~= "" then
                    found = found + 1
                    d(string.format("[%d][s%d][c%d]: '%s'", i, step, j, txt))
                end
            end
        end
    end
    if found == 0 then d("Nessuna condizione trovata") end
    d("[WritCreator ITA] === FINE ===")
end

SLASH_COMMANDS["/writit"] = function()
    if type(d) ~= "function" then return end
    if not WritCreater.boxNames then
        d("[WritCreator ITA] ERRORE: boxNames non inizializzato!")
        return
    end
    local italian, total = 0, 0
    for name, _ in pairs(WritCreater.boxNames) do
        total = total + 1
        if name:find("Sarto") or name:find("Falegname") or name:find("Fabbro") or
           name:find("Incantatore") or name:find("Alchimista") or name:find("Cuoco") or
           name:find("Gioielliere") then
            italian = italian + 1
        end
    end
    d(string.format("[WritCreator ITA] Totale: %d | Italiani: %d", total, italian))
    local testNames = {
        "Valigetta del Falegname V", "Valigetta Del Falegname V",
        "Borsa del Sarto (Stoffa) II", "Borsa Del Sarto (Stoffa) II",
        "Cassa del Fabbro I", "Cassa Del Fabbro I",
        "Scrigno dell'Incantatore III", "Recipiente dell'Alchimista I",
    }
    for _, name in ipairs(testNames) do
        if WritCreater.boxNames[name] then
            d("  V " .. name)
        else
            d("  X " .. name)
        end
    end
end

SLASH_COMMANDS["/writdebug"] = function()
    if type(d) ~= "function" then return end
    d("[WritCreator ITA] === DEBUG ===")
    d("lang: " .. tostring(WritCreater.lang))
    if WritCreater.boxNames then
        local italian, total = 0, 0
        for name, _ in pairs(WritCreater.boxNames) do
            total = total + 1
            if name:find("Sarto") or name:find("Falegname") or name:find("Fabbro") then
                italian = italian + 1
            end
        end
        d(string.format("Container: %d totali, %d italiani", total, italian))
    else
        d("ERRORE: boxNames non inizializzato!")
    end
    local testItems = {
        "Valigetta del Falegname V", "Borsa del Sarto (Stoffa) II",
        "Cassa del Fabbro I", "Scrigno dell'Incantatore I",
        "Recipiente dell'Alchimista I",
    }
    for _, itemName in ipairs(testItems) do
        local boxData = WritCreater.boxNames and WritCreater.boxNames[itemName]
        if boxData then
            d(string.format("  V '%s' [rank:%d, craft:%d]", itemName, boxData[1], boxData[2]))
        else
            d(string.format("  X '%s' NON RICONOSCIUTO", itemName))
        end
    end
    d("[WritCreator ITA] === FINE ===")
end
