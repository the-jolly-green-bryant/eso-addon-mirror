local ADDON_NAME = "TaichouIconHighlight"
local DISPLAY_NAME = "Taichou's Icon Highlight"

local defaults = {
    enablePlayer = true,
    enableQuest = true,
    enableArea = true,
    shineDuration = 2.0,
    fadeOut = 0.6,
    paletteSpeed = 2.0,
    pulseSpeed = 9.0,
    pulseBase = 1.6,
    pulseAmplitude = 0.25,
    areaPulseBase = 1.2,
    areaPulseAmplitude = 0.15,
    areaAlphaBoost = 0.85,
    playerColor1 = {r = 0.000, g = 1.000, b = 0.851}, -- #00FFD9
    playerColor2 = {r = 0.851, g = 0.000, b = 1.000}, -- #D900FF
    questColor1  = {r = 1.000, g = 0.918, b = 0.000}, -- #FFEA00
    questColor2  = {r = 0.000, g = 1.000, b = 0.918}, -- #00FFEA
    areaColor1   = {r = 1.000, g = 0.000, b = 0.816}, -- #FF00D0
    areaColor2   = {r = 0.000, g = 0.318, b = 1.000}, -- #0051FF
    characterSettings = {},
}

local accountSV = nil
local characterSV = nil
local sv = nil
local currentCharId = nil
local accountWide = true

local PLAYER_PALETTE = {{1,1,1},{1,1,1}}
local QUEST_PALETTE  = {{1,1,1},{1,1,1}}
local AREA_PALETTE   = {{1,1,1},{1,1,1}}

local function RebuildPalettes()
    PLAYER_PALETTE[1] = {sv.playerColor1.r, sv.playerColor1.g, sv.playerColor1.b}
    PLAYER_PALETTE[2] = {sv.playerColor2.r, sv.playerColor2.g, sv.playerColor2.b}
    QUEST_PALETTE[1]  = {sv.questColor1.r,  sv.questColor1.g,  sv.questColor1.b}
    QUEST_PALETTE[2]  = {sv.questColor2.r,  sv.questColor2.g,  sv.questColor2.b}
    AREA_PALETTE[1]   = {sv.areaColor1.r,   sv.areaColor1.g,   sv.areaColor1.b}
    AREA_PALETTE[2]   = {sv.areaColor2.r,   sv.areaColor2.g,   sv.areaColor2.b}
end

local WATCHED_PIN_TYPE_NAMES = {
    "MAP_PIN_TYPE_PLAYER",

    "MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION",
    "MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION",
    "MAP_PIN_TYPE_ASSISTED_QUEST_ENDING",
    "MAP_PIN_TYPE_ASSISTED_QUEST_OFFER",
    "MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION_AREA",
    "MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION_AREA",
    "MAP_PIN_TYPE_ASSISTED_QUEST_ENDING_AREA",
    "MAP_PIN_TYPE_ASSISTED_QUEST_OFFER_AREA",

    "MAP_PIN_TYPE_TRACKED_QUEST_CONDITION",
    "MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION",
    "MAP_PIN_TYPE_TRACKED_QUEST_ENDING",
    "MAP_PIN_TYPE_TRACKED_QUEST_OFFER",
    "MAP_PIN_TYPE_TRACKED_QUEST_CONDITION_AREA",
    "MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION_AREA",
    "MAP_PIN_TYPE_TRACKED_QUEST_ENDING_AREA",
    "MAP_PIN_TYPE_TRACKED_QUEST_OFFER_AREA",

    "MAP_PIN_TYPE_FOCUSED_QUEST_CONDITION",
    "MAP_PIN_TYPE_FOCUSED_QUEST_OPTIONAL_CONDITION",
    "MAP_PIN_TYPE_FOCUSED_QUEST_ENDING",
    "MAP_PIN_TYPE_FOCUSED_QUEST_OFFER",
}

local WATCHED_PIN_TYPES = {}
local AREA_PIN_TYPES = {}
local KIND_BY_PIN_TYPE = {}

for _, name in ipairs(WATCHED_PIN_TYPE_NAMES) do
    local pt = _G[name]
    if pt ~= nil then
        WATCHED_PIN_TYPES[pt] = true
        if name == "MAP_PIN_TYPE_PLAYER" then
            KIND_BY_PIN_TYPE[pt] = "player"
        elseif name:find("_AREA$") then
            AREA_PIN_TYPES[pt] = true
            KIND_BY_PIN_TYPE[pt] = "area"
        else
            KIND_BY_PIN_TYPE[pt] = "quest"
        end
    end
end

local EXTRA_AREA_CANDIDATES = {
    "MAP_PIN_TYPE_QUEST_AREA",
    "MAP_PIN_TYPE_QUEST_ZONE_STORY_AREA",
    "MAP_PIN_TYPE_POI_QUEST_AREA",
    "MAP_PIN_TYPE_QUEST_OBJECTIVE_AREA",
    "MAP_PIN_TYPE_QUEST_TARGET_AREA",
    "MAP_PIN_TYPE_QUEST_CONDITION_AREA",
    "MAP_PIN_TYPE_QUEST_OPTIONAL_CONDITION_AREA",
    "MAP_PIN_TYPE_QUEST_ENDING_AREA",
    "MAP_PIN_TYPE_QUEST_OFFER_AREA",
    "MAP_PIN_TYPE_QUEST_REPEATABLE_AREA",
    "MAP_PIN_TYPE_ACTIVE_QUEST_AREA",
    "MAP_PIN_TYPE_INACTIVE_QUEST_AREA",
}

for _, name in ipairs(EXTRA_AREA_CANDIDATES) do
    local pt = _G[name]
    if pt ~= nil and not WATCHED_PIN_TYPES[pt] then
        WATCHED_PIN_TYPES[pt] = true
        AREA_PIN_TYPES[pt] = true
        KIND_BY_PIN_TYPE[pt] = "area"
    end
end

local ASSISTED_AREA_TYPES = {}
for _, name in ipairs({
    "MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION_AREA",
    "MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION_AREA",
    "MAP_PIN_TYPE_ASSISTED_QUEST_ENDING_AREA",
    "MAP_PIN_TYPE_ASSISTED_QUEST_OFFER_AREA",
    "MAP_PIN_TYPE_FOCUSED_QUEST_CONDITION_AREA",
    "MAP_PIN_TYPE_FOCUSED_QUEST_OPTIONAL_CONDITION_AREA",
    "MAP_PIN_TYPE_FOCUSED_QUEST_ENDING_AREA",
    "MAP_PIN_TYPE_FOCUSED_QUEST_OFFER_AREA",
}) do
    local pt = _G[name]
    if pt then ASSISTED_AREA_TYPES[pt] = true end
end

local EXTRA_ASSISTED_AREA_NUMERIC = { 10 }
for _, pt in ipairs(EXTRA_ASSISTED_AREA_NUMERIC) do
    ASSISTED_AREA_TYPES[pt] = true
end

local HAS_ASSISTED_FILTER = next(ASSISTED_AREA_TYPES) ~= nil

local function PaletteColor(palette, t)
    local n = #palette
    local p = t % n
    local i = math.floor(p)
    local f = p - i
    local c1 = palette[i + 1]
    local c2 = palette[((i + 1) % n) + 1]
    return c1[1] + (c2[1] - c1[1]) * f,
           c1[2] + (c2[2] - c1[2]) * f,
           c1[3] + (c2[3] - c1[3]) * f
end

local function IteratePins(pinManager)
    if pinManager.ActiveObjectIterator then
        return pinManager:ActiveObjectIterator()
    end
    if pinManager.m_Active then
        return pairs(pinManager.m_Active)
    end
    return function() end
end

local function ApplyToPinControl(control, r, g, b, scale)
    if control.SetScale then control:SetScale(scale) end
    if control.SetColor then control:SetColor(r, g, b, 1) end
    if control.GetNumChildren then
        for i = 1, control:GetNumChildren() do
            local child = control:GetChild(i)
            if child and child.SetColor then
                child:SetColor(r, g, b, 1)
            end
        end
    end
end

local startTime = 0
local effectActive = false
local origAssistedColor = nil

local function CaptureOriginalAssistedColor()
    if ZO_MAP_PIN_ASSISTED_COLOR and not origAssistedColor then
        origAssistedColor = {
            r = ZO_MAP_PIN_ASSISTED_COLOR.r,
            g = ZO_MAP_PIN_ASSISTED_COLOR.g,
            b = ZO_MAP_PIN_ASSISTED_COLOR.b,
        }
    end
end

local function RestoreAssistedColor()
    if ZO_MAP_PIN_ASSISTED_COLOR and origAssistedColor then
        ZO_MAP_PIN_ASSISTED_COLOR.r = origAssistedColor.r
        ZO_MAP_PIN_ASSISTED_COLOR.g = origAssistedColor.g
        ZO_MAP_PIN_ASSISTED_COLOR.b = origAssistedColor.b
    end
end

local function ApplyAssistedColor(r, g, b, effect)
    if not ZO_MAP_PIN_ASSISTED_COLOR or not origAssistedColor then return end
    ZO_MAP_PIN_ASSISTED_COLOR.r = origAssistedColor.r + (r - origAssistedColor.r) * effect
    ZO_MAP_PIN_ASSISTED_COLOR.g = origAssistedColor.g + (g - origAssistedColor.g) * effect
    ZO_MAP_PIN_ASSISTED_COLOR.b = origAssistedColor.b + (b - origAssistedColor.b) * effect
end

local function UpdateShine()
    local pinManager = ZO_WorldMap_GetPinManager()
    if not pinManager then return end

    local t = GetFrameTimeSeconds()
    local elapsed = t - startTime

    local effect
    if elapsed < sv.shineDuration - sv.fadeOut then
        effect = 1
    elseif elapsed < sv.shineDuration then
        effect = 1 - (elapsed - (sv.shineDuration - sv.fadeOut)) / sv.fadeOut
    else
        effect = 0
    end

    local paletteT = t * sv.paletteSpeed
    local fullScale = sv.pulseBase + sv.pulseAmplitude * math.sin(t * sv.pulseSpeed)
    local scale = 1 + (fullScale - 1) * effect
    local areaFullScale = sv.areaPulseBase + sv.areaPulseAmplitude * math.sin(t * sv.pulseSpeed)
    local areaScale = 1 + (areaFullScale - 1) * effect

    local ar, ag, ab = PaletteColor(AREA_PALETTE, paletteT)
    if sv.enableArea then
        ApplyAssistedColor(ar, ag, ab, effect)
    end
    local r_area = 1 + (ar - 1) * effect
    local g_area = 1 + (ag - 1) * effect
    local b_area = 1 + (ab - 1) * effect

    for _, pin in IteratePins(pinManager) do
        local pt = pin.GetPinType and pin:GetPinType() or nil
        if pt and WATCHED_PIN_TYPES[pt] then
            local kind = KIND_BY_PIN_TYPE[pt]
            local enabled = (kind == "player" and sv.enablePlayer)
                            or (kind == "quest" and sv.enableQuest)
                            or (kind == "area" and sv.enableArea)
            if enabled then
                local control = pin.GetControl and pin:GetControl() or nil
                if control then
                    local palette = (kind == "player") and PLAYER_PALETTE
                                    or (kind == "area") and AREA_PALETTE
                                    or QUEST_PALETTE
                    local hr, hg, hb = PaletteColor(palette, paletteT)
                    local r = 1 + (hr - 1) * effect
                    local g = 1 + (hg - 1) * effect
                    local b = 1 + (hb - 1) * effect
                    local pinScale = AREA_PIN_TYPES[pt] and 1 or scale
                    ApplyToPinControl(control, r, g, b, pinScale)
                end
            end
        end

        if sv.enableArea and pin.pinBlob then
            local applyBlob = true
            if HAS_ASSISTED_FILTER then
                applyBlob = pt and ASSISTED_AREA_TYPES[pt] or false
            end
            if applyBlob then
                local blob = pin.pinBlob
                if pin._tih_origAlpha == nil and blob.GetAlpha then
                    pin._tih_origAlpha = blob:GetAlpha()
                end
                local origAlpha = pin._tih_origAlpha or 0.3
                if blob.SetColor then blob:SetColor(r_area, g_area, b_area, 1) end
                if blob.SetVertexColors then
                    blob:SetVertexColors(0, r_area, g_area, b_area, 1)
                    blob:SetVertexColors(1, r_area, g_area, b_area, 1)
                    blob:SetVertexColors(2, r_area, g_area, b_area, 1)
                    blob:SetVertexColors(3, r_area, g_area, b_area, 1)
                end
                if blob.SetAlpha then
                    blob:SetAlpha(origAlpha + (sv.areaAlphaBoost - origAlpha) * effect)
                end
                if blob.SetScale then blob:SetScale(areaScale) end
                if pin.UpdateSize then pin:UpdateSize() end
            end
        end
    end

    if elapsed >= sv.shineDuration then
        EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_Update")
        effectActive = false
    end
end

local function ResetPins()
    local pm = ZO_WorldMap_GetPinManager()
    if not pm then return end
    RestoreAssistedColor()
    for _, pin in IteratePins(pm) do
        local pt = pin.GetPinType and pin:GetPinType() or nil
        if pt and WATCHED_PIN_TYPES[pt] then
            local control = pin.GetControl and pin:GetControl() or nil
            if control then
                ApplyToPinControl(control, 1, 1, 1, 1)
            end
        end
        if pin.pinBlob then
            if pin._tih_origAlpha ~= nil and pin.pinBlob.SetAlpha then
                pin.pinBlob:SetAlpha(pin._tih_origAlpha)
            end
            if pin.pinBlob.SetScale then pin.pinBlob:SetScale(1) end
            if pin.UpdateSize then pin:UpdateSize() end
        end
    end
end

local function StartShine()
    startTime = GetFrameTimeSeconds()
    if not effectActive then
        effectActive = true
        EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_Update", 0, UpdateShine)
    end
end

local function StopShine()
    if effectActive then
        EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_Update")
        effectActive = false
    end
end

local function OnWorldMapShown()
    StartShine()
end

local function OnWorldMapHidden()
    StopShine()
    ResetPins()
end

local function OnWorldMapChanged()
    if SCENE_MANAGER and SCENE_MANAGER:IsShowing("worldMap") then
        StartShine()
    end
end

local function HookSceneCallbacks()
    local scene = _G["WORLD_MAP_SCENE"] or (SCENE_MANAGER and SCENE_MANAGER:GetScene("worldMap")) or nil
    if scene and scene.RegisterCallback then
        scene:RegisterCallback("StateChange", function(oldState, newState)
            if newState == SCENE_SHOWN then
                OnWorldMapShown()
            elseif newState == SCENE_HIDDEN or newState == SCENE_HIDING then
                OnWorldMapHidden()
            end
        end)
    end
    if CALLBACK_MANAGER and CALLBACK_MANAGER.RegisterCallback then
        CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", OnWorldMapChanged)
    end
end

local function BuildMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = DISPLAY_NAME,
        author = "VitorTaichou",
        version = "1.1.0",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(ADDON_NAME, panelData)

    local optionsTable = {
        { type = "header", name = "Settings storage" },
        {
            type = "checkbox",
            name = "Use account-wide settings",
            tooltip = "When enabled, settings are shared across all your characters. When disabled, this character uses its own settings.",
            getFunc = function() return accountWide end,
            setFunc = function(v) SwitchAccountWide(v) end,
            default = true,
        },

        { type = "header", name = "Enable" },
        {
            type = "checkbox",
            name = "Highlight player icon",
            getFunc = function() return sv.enablePlayer end,
            setFunc = function(v) sv.enablePlayer = v end,
            default = defaults.enablePlayer,
        },
        {
            type = "checkbox",
            name = "Highlight tracked quest icon",
            getFunc = function() return sv.enableQuest end,
            setFunc = function(v) sv.enableQuest = v end,
            default = defaults.enableQuest,
        },
        {
            type = "checkbox",
            name = "Highlight tracked quest area",
            getFunc = function() return sv.enableArea end,
            setFunc = function(v) sv.enableArea = v end,
            default = defaults.enableArea,
        },

        { type = "header", name = "Timing & speed" },
        {
            type = "slider",
            name = "Effect duration (seconds)",
            min = 0.5, max = 10, step = 0.1, decimals = 1,
            getFunc = function() return sv.shineDuration end,
            setFunc = function(v) sv.shineDuration = v end,
            default = defaults.shineDuration,
            width = "full",
        },
        {
            type = "slider",
            name = "Color cycle speed",
            tooltip = "Higher = faster transitions. 2.0 = one color every 0.5s",
            min = 0.1, max = 10, step = 0.1, decimals = 1,
            getFunc = function() return sv.paletteSpeed end,
            setFunc = function(v) sv.paletteSpeed = v end,
            default = defaults.paletteSpeed,
            width = "full",
        },
        {
            type = "slider",
            name = "Pulse speed",
            min = 1, max = 20, step = 0.5, decimals = 1,
            getFunc = function() return sv.pulseSpeed end,
            setFunc = function(v) sv.pulseSpeed = v end,
            default = defaults.pulseSpeed,
            width = "full",
        },

        { type = "header", name = "Icon size (player & quest)" },
        {
            type = "slider",
            name = "Base size (multiplier)",
            tooltip = "1.0 = normal, 1.6 = 60% larger on average",
            min = 1.0, max = 3.0, step = 0.05, decimals = 2,
            getFunc = function() return sv.pulseBase end,
            setFunc = function(v) sv.pulseBase = v end,
            default = defaults.pulseBase,
            width = "full",
        },
        {
            type = "slider",
            name = "Pulse amplitude",
            tooltip = "How much it grows/shrinks above/below the base size",
            min = 0.0, max = 1.0, step = 0.05, decimals = 2,
            getFunc = function() return sv.pulseAmplitude end,
            setFunc = function(v) sv.pulseAmplitude = v end,
            default = defaults.pulseAmplitude,
            width = "full",
        },

        { type = "header", name = "Player colors" },
        {
            type = "colorpicker",
            name = "Color 1",
            getFunc = function() return sv.playerColor1.r, sv.playerColor1.g, sv.playerColor1.b end,
            setFunc = function(r, g, b)
                sv.playerColor1.r, sv.playerColor1.g, sv.playerColor1.b = r, g, b
                RebuildPalettes()
            end,
            default = defaults.playerColor1,
            width = "half",
        },
        {
            type = "colorpicker",
            name = "Color 2",
            getFunc = function() return sv.playerColor2.r, sv.playerColor2.g, sv.playerColor2.b end,
            setFunc = function(r, g, b)
                sv.playerColor2.r, sv.playerColor2.g, sv.playerColor2.b = r, g, b
                RebuildPalettes()
            end,
            default = defaults.playerColor2,
            width = "half",
        },

        { type = "header", name = "Quest colors" },
        {
            type = "colorpicker",
            name = "Color 1",
            getFunc = function() return sv.questColor1.r, sv.questColor1.g, sv.questColor1.b end,
            setFunc = function(r, g, b)
                sv.questColor1.r, sv.questColor1.g, sv.questColor1.b = r, g, b
                RebuildPalettes()
            end,
            default = defaults.questColor1,
            width = "half",
        },
        {
            type = "colorpicker",
            name = "Color 2",
            getFunc = function() return sv.questColor2.r, sv.questColor2.g, sv.questColor2.b end,
            setFunc = function(r, g, b)
                sv.questColor2.r, sv.questColor2.g, sv.questColor2.b = r, g, b
                RebuildPalettes()
            end,
            default = defaults.questColor2,
            width = "half",
        },

        { type = "header", name = "Area colors" },
        {
            type = "colorpicker",
            name = "Color 1",
            getFunc = function() return sv.areaColor1.r, sv.areaColor1.g, sv.areaColor1.b end,
            setFunc = function(r, g, b)
                sv.areaColor1.r, sv.areaColor1.g, sv.areaColor1.b = r, g, b
                RebuildPalettes()
            end,
            default = defaults.areaColor1,
            width = "half",
        },
        {
            type = "colorpicker",
            name = "Color 2",
            getFunc = function() return sv.areaColor2.r, sv.areaColor2.g, sv.areaColor2.b end,
            setFunc = function(r, g, b)
                sv.areaColor2.r, sv.areaColor2.g, sv.areaColor2.b = r, g, b
                RebuildPalettes()
            end,
            default = defaults.areaColor2,
            width = "half",
        },
        {
            type = "slider",
            name = "Area opacity (during effect)",
            min = 0.1, max = 1.0, step = 0.05, decimals = 2,
            getFunc = function() return sv.areaAlphaBoost end,
            setFunc = function(v) sv.areaAlphaBoost = v end,
            default = defaults.areaAlphaBoost,
            width = "full",
        },
    }

    LAM:RegisterOptionControls(ADDON_NAME, optionsTable)
end

local function ApplyActiveSettings()
    if accountSV.characterSettings[currentCharId] then
        accountWide = false
        if not characterSV then
            characterSV = ZO_SavedVars:NewCharacterIdSettings("TaichouIconHighlightSavedVars", 1, nil, defaults)
        end
        sv = characterSV
    else
        accountWide = true
        sv = accountSV
    end
    RebuildPalettes()
end

local function SwitchAccountWide(useAccountWide)
    if useAccountWide then
        accountSV.characterSettings[currentCharId] = nil
    else
        accountSV.characterSettings[currentCharId] = true
    end
    ApplyActiveSettings()
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    accountSV = ZO_SavedVars:NewAccountWide("TaichouIconHighlightSavedVars", 1, nil, defaults)
    currentCharId = GetCurrentCharacterId()
    if accountSV.characterSettings == nil then
        accountSV.characterSettings = {}
    end
    ApplyActiveSettings()

    CaptureOriginalAssistedColor()
    BuildMenu()
    HookSceneCallbacks()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
