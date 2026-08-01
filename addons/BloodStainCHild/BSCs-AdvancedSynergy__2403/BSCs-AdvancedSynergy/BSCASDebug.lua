BSCASynergy = BSCASynergy or {}
local BSCAS = BSCASynergy

BSCAS.bDebugTab = false

-- ============================ Utils ============================
local DEBUG_TAB_NAME = "BSCAS_Debug"

local function Colorize(text, hex)
    return ("|c%s%s|r"):format(hex or "FFFFFF", tostring(text))
end

local function ChatReady()
    return CHAT_SYSTEM and CHAT_SYSTEM.primaryContainer and ZO_ChatWindowTabTemplate1 ~= nil
end

-- Findet Tab in allen Containern
local function FindTabByName(name)
    if not ChatReady() then return nil end
    for _, container in ipairs(CHAT_SYSTEM.containers) do
        for i = 1, #container.windows do
            if container:GetTabName(i) == name then
                return container, container.windows[i], i
            end
        end
    end
    return nil
end

-- Erstellt (falls nötig) einen neuen Tab im Primary-Container
local function CreateTab(name)
    local container = CHAT_SYSTEM.primaryContainer
    local window, key = container.windowPool:AcquireObject()
    window.key = key
    container:AddRawWindow(window, name)

    local tabIndex = window.tab.index
    container:SetInteractivity(tabIndex, true)
    container:SetLocked(tabIndex, true)
    container:SetTimestampsEnabled(tabIndex, true)

    -- Alle Chatkategorien im Debug-Tab deaktivieren (wir schreiben manuell rein)
    for category = 1, GetNumChatCategories() do
        container:SetWindowFilterEnabled(tabIndex, category, false)
    end
    return container, window, tabIndex
end

-- Sorgt dafür, dass Tab existiert und Referenzen gesetzt sind
local function EnsureTab()
    if not ChatReady() then return nil end

    local container, window, index = FindTabByName(DEBUG_TAB_NAME)
    if not container then
        container, window, index = CreateTab(DEBUG_TAB_NAME)
    end

    BSCAS.ChatContainer = container
    BSCAS.ChatWindow    = window
    BSCAS.bDebugTab     = true
    return container, window, index
end

-- ============================ API ============================
function BSCAS:PrintToDebugTab(msg)
    msg = tostring(msg or "")
    if not self.bDebugTab or not ChatReady() then
        -- Fallback, wenn Tab (noch) nicht bereit ist
        CHAT_ROUTER:AddSystemMessage(Colorize("["..GetTimeString().."] ", "A0A0A0") .. Colorize(msg, "FFFFFF"))
        return
    end

    -- Tab ggf. (re)finden – Index kann sich ändern
    local container, window = FindTabByName(DEBUG_TAB_NAME)
    if not container then
        container, window = EnsureTab()
        if not container then
            CHAT_ROUTER:AddSystemMessage(Colorize("["..GetTimeString().."] ", "A0A0A0") .. Colorize(msg, "FFFFFF"))
            return
        end
    end

    -- Lange Nachrichten splitten (Chat hat Limit ~2k)
    local prefix = Colorize("["..GetTimeString().."] ", "A0A0A0")
    local chunkSize = 1600
    local i = 1
    while i <= #msg do
        local chunk = msg:sub(i, i + chunkSize - 1)
        container:AddMessageToWindow(window, prefix .. Colorize(chunk, "FFFFFF"))
        i = i + chunkSize
    end
end

-- Erstellt Tab (wenn möglich) – versucht es automatisch erneut
function BSCAS:AddChatTab()
    if ChatReady() then
        EnsureTab()
    else
        zo_callLater(function() BSCAS:AddChatTab() end, 200)
    end
end

-- Entfernt Tab (falls vorhanden)
function BSCAS:RemoveChatTab()
    if not ChatReady() then return end
    local container, _, index = FindTabByName(DEBUG_TAB_NAME)
    if container and index then
        container:RemoveWindow(index)  -- wichtig: mit ":" aufrufen
        self.bDebugTab     = false
        self.ChatContainer = nil
        self.ChatWindow    = nil
    end
end

-- Initialisiert/entfernt DebugTab abhängig vom Accountnamen
function BSCAS:InitializeDebugChat()
    local function _init()
        if GetUnitDisplayName('player') ~= '@BloodStainChild666' then
            BSCAS:RemoveChatTab()
        else
            BSCAS:AddChatTab()
        end
    end
    if ChatReady() then
        _init()
    else
        zo_callLater(function() BSCAS:InitializeDebugChat() end, 200)
    end
end
