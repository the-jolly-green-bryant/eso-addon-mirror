local HT_NAME = "HyboremTutor"

-- Per-server SavedVariables
local serverKey = GetWorldName()  -- "EU Megaserver", "NA Megaserver", "PTS"
local defaults = {
    lM = 5000,
    lR = 20000,
    lP = 3000,
    lS = 5000,
    lST = 10000,
    minScripts = 0,
    enableLogs = false,
    enableTooltips = true,
    autoLearnEnabled = false,
    autolearnBoundStyles = true,
    autolearnUnboundStyles = false,
    autolearnUnboundScripts = false,
    trader = "0",
    scriptLearner = "0",
}

-- Inicjalizacja per-server
HyboremTutor_Vars = HyboremTutor_Vars or {}
HyboremTutor_Vars[serverKey] = HyboremTutor_Vars[serverKey] or {}
local v = HyboremTutor_Vars[serverKey]

-- Ustaw domyślne wartości tylko jeśli brak
for key, defaultValue in pairs(defaults) do
    if v[key] == nil then
        v[key] = defaultValue
    end
end

-- Priority slots (też per-server)
for i = 1, 3 do 
    v["p"..i] = v["p"..i] or { char = "0", m = false, r = false, p = false }
end

local function GetTimestamp()
    return os.date("%H:%M:%S")
end

-- Lokalna funkcja debug (nie globalna)
local function Debug(msg)
    if not msg then return end
    if v.enableLogs then
        CHAT_SYSTEM:AddMessage(string.format("[%s] [Hyborem's Tutor] %s", GetTimestamp(), msg))
    end
end

-- Sprawdza czy LPC jest dostępny
local function IsLPCAvailable()
    return LibPriceCache ~= nil and LibPriceCache.GetPrice ~= nil
end

-- Sprawdza czy LCK jest gotowy (ma listę postaci)
local function IsLCKReady()
    if not LibCharacterKnowledge then return false end
    local list = LibCharacterKnowledge.GetCharacterList()
    return list and type(list) == "table" and #list > 0
end

-- Czekaj na LCK
local function WaitForLCK(callback, attempt)
    attempt = attempt or 1
    local MAX_ATTEMPTS = 30
    
    if IsLCKReady() then
        Debug("LCK is ready")
        if callback then callback() end
        return true
    end
    
    if attempt >= MAX_ATTEMPTS then
        Debug("WARNING: LCK not ready after 15 seconds")
        if callback then callback() end
        return false
    end
    
    zo_callLater(function() WaitForLCK(callback, attempt + 1) end, 500)
    return false
end

-- Główna funkcja inicjalizująca
local function InitializeAll()
    Debug("Initializing all systems...")
    
    HT_LAM.CreateMenu()
    
    if HT_BankLogic and HT_BankLogic.OnBankOpen then
        EVENT_MANAGER:RegisterForEvent(HT_NAME, EVENT_OPEN_BANK, HT_BankLogic.OnBankOpen)
    end
    
    if HT_BankLogic and HT_BankLogic.OnMerchantOpen then
        EVENT_MANAGER:RegisterForEvent(HT_NAME, EVENT_OPEN_MERCHANT, HT_BankLogic.OnMerchantOpen)
    end
    
    if HT_Queue and HT_Queue.LearnAllFromInventory then
        EVENT_MANAGER:RegisterForEvent(HT_NAME, EVENT_CLOSE_BANK, function()
            zo_callLater(function() HT_Queue.LearnAllFromInventory() end, 500)
        end)
    end
    
    if HT_Tooltip and HT_Tooltip.HookTooltips then
        HT_Tooltip.HookTooltips()
    end
    
    Debug("All systems initialized")
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= HT_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(HT_NAME, EVENT_ADD_ON_LOADED)
    
    if not LibCharacterKnowledge then
        Debug("ERROR: LibCharacterKnowledge not found!")
        return
    end
    
    if not IsLPCAvailable() then
        Debug("WARNING: LibPriceCache not available! Price limits will not work.")
    end
    
    Debug("Waiting for LCK to be ready...")
    WaitForLCK(InitializeAll)
    
    Debug("Loaded v1.0.0 on " .. serverKey)
end

EVENT_MANAGER:RegisterForEvent(HT_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

-- Slash command
SLASH_COMMANDS["/httest"] = function(link)
    if not link or not link:find("|H") then
        Debug("Usage: /httest [item link]")
        return
    end

    local char = GetUnitName("player")
    local cat = HT_Knowledge.GetCategory(link)
    local price = 0
    if LibPriceCache and LibPriceCache.GetPrice then
        price = LibPriceCache.GetPrice(link) or 0
    end
    local limit = HT_Knowledge.GetPriceLimit(cat)

    Debug("=== HT TEST: " .. link .. " ===")
    Debug(string.format("Category: %s | Price: %d | Limit: %d", cat, price, limit))

    local lckKnown = "N/A"
    if LibCharacterKnowledge then
        local k = LibCharacterKnowledge.GetItemKnowledgeForCharacter(link, nil, char)
        lckKnown = (k == LibCharacterKnowledge.KNOWLEDGE_KNOWN) and "YES" or (k == LibCharacterKnowledge.KNOWLEDGE_UNKNOWN and "NO" or "NODATA")
    end
    Debug("Known by LCK: " .. lckKnown)

    local should = HT_Queue.ShouldLearnNow(link, char)
    Debug("ShouldLearnNow = " .. (should and "YES" or "NO"))

    Debug("--- PRIORITY SLOTS ---")
    for i = 1, 3 do
        local slot = v["p"..i]
        local pcharId = slot and slot.char or "0"
        if pcharId and pcharId ~= "0" and pcharId ~= "None selected" then
            local pname = HT_LAM.GetCharacterNameById(pcharId)
            local prio = HT_Knowledge.HasPriority(cat, i)
            local pknown = HT_Knowledge.IsKnownByChar(link, pname)
            Debug(string.format("Slot %d (%s): Priority=%s | Known=%s", i, pname, prio and "YES" or "NO", pknown and "YES" or "NO"))
        end
    end

    local learnerId = v.scriptLearner or "0"
    local learnerName = HT_LAM.GetCharacterNameById(learnerId)
    Debug("--- SCRIPT LEARNER: " .. learnerName .. " ---")
    Debug("--- AUTO LEARN: " .. (v.autoLearnEnabled and "ON" or "OFF") .. " ---")
    Debug("============================================")
end