HyboremBugsWeeds = HyboremBugsWeeds or {}
local HBW = HyboremBugsWeeds
HBW.name = "HyboremBugsWeeds"

local initialized = false
local hooksInitialized = false

HBW.InsectDropIds = {
    [100] = 77581,
    [101] = 77585,
    [102] = 27043,
    [103] = 77587,
    [104] = 42872,
}

local function GetCurrentLanguage()
    local officialLang = GetCVar("language.2") or "en"
    if officialLang == "en" and IsAddOnLoaded and IsAddOnLoaded("EsoPL") then
        return "pl"
    end
    if HBW[officialLang] then
        return officialLang
    end
    return "en"
end

local function GetLangTable()
    return HBW[GetCurrentLanguage()] or HBW["en"]
end

local function CleanName(fullName, attributes)
    if not fullName then return "" end
    for _, attr in ipairs(attributes or {}) do
        if fullName:find("^" .. attr .. " ") then
            return fullName:sub(#attr + 2)
        end
    end
    return fullName
end

local function GetCategoryId(name)
    if not name or name == "" then return nil end
    
    local langTable = GetLangTable()
    local cleanName = CleanName(name, langTable.attributes)
    
    for id = 1, 20 do
        if langTable[id] == cleanName then
            return id
        end
    end
    
    for id = 100, 104 do
        local list = langTable[id]
        if list then
            for _, insectName in ipairs(list) do
                if cleanName == insectName then
                    return id
                end
            end
        end
    end
    
    return nil
end

local lastColor = nil
local lastTarget = nil
local hasValidTarget = false

local function SetReticleColor(r, g, b, a)
    local reticle = ZO_ReticleContainerInteractContext
    if reticle and reticle.SetColor then
        reticle:SetColor(r, g, b, a or 1)
    end
end

local function ForceColor()
    if not ZO_ReticleContainerInteractContext then return end
    
    local action, name = GetGameCameraInteractableActionInfo()
    
    if action == "Search" then
        if hasValidTarget then
            SetReticleColor(1, 1, 1, 1)
            lastColor = nil
            lastTarget = nil
            hasValidTarget = false
        end
        return
    end
    
    if not name or name == "" then
        if hasValidTarget then
            SetReticleColor(1, 1, 1, 1)
            lastColor = nil
            lastTarget = nil
            hasValidTarget = false
        end
        return
    end
    
    if lastTarget == name then return end
    
    hasValidTarget = true
    lastTarget = name
    
    local categoryId = GetCategoryId(name)
    if not categoryId then
        if lastColor then
            SetReticleColor(1, 1, 1, 1)
            lastColor = nil
        end
        return
    end
    
    local value = HBW.vars.selections and HBW.vars.selections[categoryId]
    local colorIndex = value or 3
    
    if colorIndex and HBW.vars.colors[colorIndex] then
        local c = HBW.vars.colors[colorIndex]
        SetReticleColor(c.r, c.g, c.b, c.a or 1)
        lastColor = colorIndex
    elseif lastColor then
        SetReticleColor(1, 1, 1, 1)
        lastColor = nil
    end
end

local function InitVars()
    if initialized then return end
    initialized = true
    
    local serverKey = ""
    if HBW.vars and HBW.vars.serverMode == "PerServer" then
        serverKey = GetDisplayName() .. "_" .. GetWorldName()
    else
        serverKey = "Shared"
    end
    
    HBW.vars = ZO_SavedVars:NewAccountWide("HyboremBugsWeeds_Vars", 1, nil, {
        colors = {
            [1] = { r = 1, g = 0.01, b = 0.18, a = 1 },
            [2] = { r = 0.12, g = 1, b = 0.26, a = 1 },
            [3] = { r = 0.63, g = 0.63, b = 0.63, a = 1 },
        },
        selections = {},
        serverMode = "Shared",
    }, serverKey)
end

local function SetupHooks()
    if hooksInitialized then return end
    hooksInitialized = true
    
    local frame = CreateControl("HBWUpdateFrame", GuiRoot, CT_CONTROL)
    frame:SetHidden(false)
    frame:SetHandler("OnUpdate", function()
        ForceColor()
    end)
    
    EVENT_MANAGER:RegisterForEvent(HBW.name, EVENT_RETICLE_TARGET_CHANGED, function()
        ForceColor()
    end)
    
    EVENT_MANAGER:RegisterForEvent(HBW.name, EVENT_RETICLE_HIDE, function()
        SetReticleColor(1, 1, 1, 1)
        lastColor = nil
        lastTarget = nil
        hasValidTarget = false
    end)
end

local function OnPlayerActivated(event, initial)
    if not initial then return end
    EVENT_MANAGER:UnregisterForEvent(HBW.name, EVENT_PLAYER_ACTIVATED)
    
    InitVars()
    if HBW.CreateSettingsMenu then HBW.CreateSettingsMenu() end
    
    zo_callLater(function()
        SetupHooks()
    end, 100)
end

EVENT_MANAGER:RegisterForEvent(HBW.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

local function OnAddOnLoaded(event, addonName)
    if addonName == HBW.name then
        EVENT_MANAGER:UnregisterForEvent("HBW_Fallback", EVENT_ADD_ON_LOADED)
        if GetGameTimeSeconds() > 0 and not initialized then
            OnPlayerActivated(nil, true)
        end
    end
end
EVENT_MANAGER:RegisterForEvent("HBW_Fallback", EVENT_ADD_ON_LOADED, OnAddOnLoaded)