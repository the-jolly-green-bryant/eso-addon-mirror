ESOAssistant = {}
local eg = ESOAssistant
eg.name = "ESO Assistant by ESO-hub.com"
eg.version = "1.0.8"
eg.addonVersion = 10008
eg.shortName = "ESO Assistant"
eg.addonName = "ESOAssistant"
eg.internal = {}
local egint = eg.internal

local sv
local logger

local baseUrl = "https://eso-hub.com/"
local addonUrlSegment = "/ca/"
local langSegment = "en"

local debug_accs = {
    ["@Solinur"] = true,
}
local debug = debug_accs[GetDisplayName()]

local supportedLanguages = {
    en = true,
    de = true,
    fr = true,
    ru = true,
    es = true,
}

if LibDebugLogger and debug then
    logger = LibDebugLogger.Create(eg.addonName)
else
    logger = {}
    function logger:Debug(...)
        if not debug then return end
        df(...)
    end

    logger.Warn = logger.Debug
    logger.Info = logger.Debug
    logger.Error = logger.Debug
    logger.Verbose = logger.Debug
end
egint.logger = logger

local function ShowQR(link)
    link = link or baseUrl
    LibQRCode.DrawQRCode(ESOAssistantQRContainer, link)
    ---@cast ESOAssistantQRContainerQRComposite Control
    ESOAssistantQRContainerQRComposite:SetDrawLayer(DL_OVERLAY)
    ESOAssistantQR:SetHidden(false)
    logger:Debug("Show QR Code.")
end

function egint.HideQR()
    ESOAssistantQR:SetHidden(true)
    logger:Debug("Hide QR Code.")
end

---comment
---@param func function
---@param ... any
local function MeasureMemory(func, ...)
    if not debug then return func(...) end

    collectgarbage("stop")
    local before = collectgarbage("count")
    local before2 = GetTotalUserAddOnMemoryPoolUsageMB()

    local returns = { func(...) }

    local after = collectgarbage("count")
    local after2 = GetTotalUserAddOnMemoryPoolUsageMB()

    local size = (after - before) / 1024
    local size2 = (after2 - before2)
    collectgarbage("restart")
    collectgarbage("collect")

    logger:Info("GC: %.3f MB | FCF: %.3f", size, size2)
    logger:Info("Total GC: %.3f | FCF: %.3f", after, after2)

    return unpack(returns)
end

local hudscene = SCENE_MANAGER.baseScene
    
local function onStateChange(link, _, newState)
    if newState == SCENE_SHOWN then
        RequestOpenUnsafeURL(link)
        logger:Info("unreg:", link, hudscene:UnregisterCallback("StateChange", onStateChange, link))
    end
end

local function OpenLink(link)
    logger:Debug("Open URL: %s", link)
    link = link or baseUrl
    if IsInGamepadPreferredMode() or ZO_IsConsoleUI() then
        logger:Info("reg:", hudscene:RegisterCallback("StateChange", onStateChange, link))
        SCENE_MANAGER:Show(hudscene.name)
    else 
        RequestOpenUnsafeURL(link)
    end
    if sv.showQR == true then 
        MeasureMemory(ShowQR, link)
    end
end

function egint.ProcessLink(link_suffix)
    if ESOAssistantQR:IsHidden() == false then egint.HideQR() return end
    local link = baseUrl .. langSegment .. addonUrlSegment .. link_suffix
    if sv.openLink == true then
        OpenLink(link)
    elseif sv.showQR == true then 
        MeasureMemory(ShowQR, link)
    end
end

local defaultSV = { showQR = true, openLink = not ZO_IsConsoleUI(), accountWide = true }
local function initSV()
    egint.svChar = ZO_SavedVars:NewCharacterIdSettings("ESOAssistantSavedVariables", 1, nil, defaultSV)
    egint.svAcc = ZO_SavedVars:NewAccountWide("ESOAssistantSavedVariables", 1, nil, defaultSV)
    egint.sv = egint.svChar.accountWide and egint.svAcc or egint.svChar
    sv = egint.sv
end

if debug then
    function ToggleForceFlow()
        local value = GetCVar("ForceConsoleFlow.2") == "1" and 0 or 1
        SetCVar("ForceConsoleFlow.2", value)
    end
end

local function Initialize(event, addonName)
    if addonName ~= eg.addonName then return end
    EVENT_MANAGER:UnregisterForEvent(eg.name, EVENT_ADD_ON_LOADED)

    initSV()
    egint.InitMenu()
    local lang = GetCVar("language.2")
    if supportedLanguages[lang] then langSegment = lang end

    ZO_DIALOG_SYNC_OBJECT:SetHandler("OnHidden", function() egint.HideQR() end, "ESOAssistant", CONTROL_HANDLER_ORDER_AFTER, "")

    egint.initZoneModule()
    egint.initItemSetsModule()
    egint.initSkillsModule()

    egint.initialized = true
    logger:Debug("ESOAssistant initialized.")
end
EVENT_MANAGER:RegisterForEvent(eg.name, EVENT_ADD_ON_LOADED, Initialize)

if debug then
    SLASH_COMMANDS["/eaqr"] = ShowQR
end
