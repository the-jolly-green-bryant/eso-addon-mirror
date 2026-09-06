TetsuCombatTools = TetsuCombatTools or {}
local T = TetsuCombatTools

local ADDON = "TetsuCombatToolsStatus"

-- Round radio mark exists on console. highlight.dds is missing there and hid the lamp.
local ICON_TEX = "/esoui/art/buttons/radiobuttonup.dds"
local COL_FIGHT = { 0.92, 0.18, 0.16, 1 }
local COL_PEACE = { 0.22, 0.82, 0.32, 1 }

local iconRoot
local iconBg
local iconTex
local textRoot
local textLab
local built = false
local lastCombat = false
local soundReady = false

local SOUND_KEYS = {
    duel = { SOUNDS_KEY = "DUEL_START", fallback = "Duel_Start" },
    alert = { SOUNDS_KEY = "GENERAL_ALERT_ERROR", fallback = "General_Alert_Error" },
    notify = { SOUNDS_KEY = "NEW_NOTIFICATION", fallback = "New_Notification" },
    discover = { SOUNDS_KEY = "OBJECTIVE_DISCOVERED", fallback = "Objective_Discovered" },
}

local function Vars()
    return T.savedVars
end

local function L(key, fallback)
    local loc = T.L or {}
    return loc[key] or fallback or key
end

local function StatusOn()
    local v = Vars()
    return v and v.statusEnabled ~= false
end

local function IconOn()
    local v = Vars()
    return StatusOn() and v and v.statusIcon ~= false
end

local function TextOn()
    local v = Vars()
    return StatusOn() and v and v.statusText == true
end

local function SoundOn()
    local v = Vars()
    return StatusOn() and v and v.statusSound ~= false
end

local function InCombat()
    if not IsUnitInCombat then return false end
    local ok, v = pcall(IsUnitInCombat, "player")
    return ok and v and true or false
end

local function SceneIsShowing(scene)
    if not scene or not scene.IsShowing then return false end
    local ok, showing = pcall(function()
        return scene:IsShowing()
    end)
    return ok and showing and true or false
end

local function WorldHudOpen()
    if HUD_SCENE or HUD_UI_SCENE then
        return SceneIsShowing(HUD_SCENE) or SceneIsShowing(HUD_UI_SCENE)
    end
    return true
end

local function ClampIconScale(p)
    p = tonumber(p) or 50
    if p < 30 then p = 30 end
    if p > 180 then p = 180 end
    return p / 100
end

local function ClampTextScale(p)
    p = tonumber(p) or 100
    if p < 50 then p = 50 end
    if p > 180 then p = 180 end
    return p / 100
end

local function IconAlpha()
    local v = Vars()
    local p = v and tonumber(v.statusIconAlpha) or 50
    if p < 10 then p = 10 end
    if p > 100 then p = 100 end
    return p / 100
end

local function FightColor()
    if InCombat() then return COL_FIGHT end
    return COL_PEACE
end

local function PlayStartSound()
    if not SoundOn() then return end
    local v = Vars()
    local key = v and v.statusSoundId or "duel"
    local spec = SOUND_KEYS[key] or SOUND_KEYS.duel
    local played = false
    if SOUNDS and spec.SOUNDS_KEY and SOUNDS[spec.SOUNDS_KEY] then
        played = pcall(PlaySound, SOUNDS[spec.SOUNDS_KEY])
    end
    if not played and spec.fallback and PlaySound then
        pcall(PlaySound, spec.fallback)
    end
end

local function AttachFragment(control)
    if not control then return end
    local frag
    if ZO_HUDFadeSceneFragment then
        frag = ZO_HUDFadeSceneFragment:New(control)
    elseif ZO_SimpleSceneFragment then
        frag = ZO_SimpleSceneFragment:New(control)
    end
    if not frag then return end
    if HUD_SCENE and HUD_SCENE.AddFragment then
        pcall(function() HUD_SCENE:AddFragment(frag) end)
    end
    if HUD_UI_SCENE and HUD_UI_SCENE.AddFragment then
        pcall(function() HUD_UI_SCENE:AddFragment(frag) end)
    end
end

local function LayoutIcon()
    if not iconRoot then return end
    local v = Vars()
    local ox = v and tonumber(v.statusIconX) or 0
    local oy = v and tonumber(v.statusIconY) or 0
    local sc = ClampIconScale(v and v.statusIconScale)
    local size = math.floor(48 * sc + 0.5)
    iconRoot:ClearAnchors()
    iconRoot:SetAnchor(CENTER, GuiRoot, CENTER, ox, oy)
    iconRoot:SetDimensions(size, size)
    iconRoot:SetAlpha(1)
    local a = IconAlpha()
    if iconBg then
        iconBg:SetHidden(true)
        iconBg:SetAlpha(0)
    end
    if iconTex then
        iconTex:ClearAnchors()
        iconTex:SetAnchor(CENTER, iconRoot, CENTER, 0, 0)
        iconTex:SetDimensions(size, size)
        iconTex:SetAlpha(a)
    end
end

local function LayoutText()
    if not textRoot or not textLab then return end
    local v = Vars()
    local ox = v and tonumber(v.statusTextX) or 0
    local oy = v and tonumber(v.statusTextY)
    if oy == nil then oy = 250 end
    local sc = ClampTextScale(v and v.statusTextScale)
    local fontSize = math.floor(28 * sc + 0.5)
    textRoot:ClearAnchors()
    textRoot:SetAnchor(CENTER, GuiRoot, CENTER, ox, oy)
    textRoot:SetDimensions(math.floor(280 * sc), math.floor(36 * sc + 0.5))
    if ZO_CreateFont then
        -- keep gamepad fonts
    end
    local fontName = "ZoFontGamepad27"
    if fontSize >= 34 then
        fontName = "ZoFontGamepad34"
    elseif fontSize <= 22 then
        fontName = "ZoFontGamepad22"
    end
    pcall(function()
        textLab:SetFont(fontName)
    end)
    textLab:ClearAnchors()
    textLab:SetAnchor(CENTER, textRoot, CENTER, 0, 0)
    textLab:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
end

local function Paint()
    local fight = InCombat()
    local col = fight and COL_FIGHT or COL_PEACE
    local a = IconAlpha()
    if iconBg then
        iconBg:SetHidden(true)
    end
    if iconTex then
        iconTex:SetColor(col[1], col[2], col[3], 1)
        iconTex:SetAlpha(a)
    end
    if textLab then
        textLab:SetColor(col[1], col[2], col[3], 1)
        if fight then
            textLab:SetText(L("STATUS_IN", "IN COMBAT"))
        else
            textLab:SetText(L("STATUS_OUT", "OUT OF COMBAT"))
        end
    end
end

local function ApplyShown()
    local hud = WorldHudOpen()
    if iconRoot then
        iconRoot:SetHidden(not (IconOn() and hud))
    end
    if textRoot then
        textRoot:SetHidden(not (TextOn() and hud))
    end
end

local function Build()
    if built then return end
    local wm = GetWindowManager()
    if not wm then return end

    iconRoot = wm:CreateTopLevelWindow(ADDON .. "Icon")
    if not iconRoot then
        iconRoot = wm:CreateControl(ADDON .. "Icon", GuiRoot, CT_TOPLEVELCONTROL)
    end
    iconRoot:SetParent(GuiRoot)
    iconRoot:SetHidden(true)
    iconRoot:SetClampedToScreen(true)
    iconRoot:SetMouseEnabled(false)
    iconRoot:SetDrawLayer(DL_CONTROLS)
    iconRoot:SetDrawLevel(3)

    iconBg = wm:CreateControl(ADDON .. "IconBg", iconRoot, CT_BACKDROP)
    iconBg:SetHidden(true)
    iconBg:SetAlpha(0)

    iconTex = wm:CreateControl(ADDON .. "IconTex", iconRoot, CT_TEXTURE)
    iconTex:SetTexture(ICON_TEX)
    iconTex:SetColor(1, 1, 1, 1)

    textRoot = wm:CreateTopLevelWindow(ADDON .. "Text")
    if not textRoot then
        textRoot = wm:CreateControl(ADDON .. "Text", GuiRoot, CT_TOPLEVELCONTROL)
    end
    textRoot:SetParent(GuiRoot)
    textRoot:SetHidden(true)
    textRoot:SetClampedToScreen(true)
    textRoot:SetMouseEnabled(false)
    textRoot:SetDrawLayer(DL_CONTROLS)
    textRoot:SetDrawLevel(3)

    textLab = wm:CreateControl(ADDON .. "Lab", textRoot, CT_LABEL)
    textLab:SetFont("ZoFontGamepad27")
    textLab:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    textLab:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

    AttachFragment(iconRoot)
    AttachFragment(textRoot)
    built = true
    LayoutIcon()
    LayoutText()
    Paint()
    ApplyShown()
end

local function OnCombat(_, inCombat)
    inCombat = inCombat and true or false
    if inCombat and not lastCombat and soundReady then
        PlayStartSound()
    end
    lastCombat = inCombat
    Paint()
    ApplyShown()
end

function T.StatusRefresh()
    if not StatusOn() then
        if iconRoot then iconRoot:SetHidden(true) end
        if textRoot then textRoot:SetHidden(true) end
        return
    end
    if not built then
        Build()
    end
    LayoutIcon()
    LayoutText()
    Paint()
    ApplyShown()
end

function T.StatusStart()
    EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_PLAYER_COMBAT_STATE, OnCombat)
    EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_PLAYER_ACTIVATED, function()
        lastCombat = InCombat()
        soundReady = true
        T.StatusRefresh()
    end)
    local function OnLayer()
        ApplyShown()
    end
    if EVENT_ACTION_LAYER_PUSHED then
        EVENT_MANAGER:RegisterForEvent(ADDON .. "LayerP", EVENT_ACTION_LAYER_PUSHED, OnLayer)
    end
    if EVENT_ACTION_LAYER_POPPED then
        EVENT_MANAGER:RegisterForEvent(ADDON .. "LayerO", EVENT_ACTION_LAYER_POPPED, OnLayer)
    end
    if SCENE_MANAGER and SCENE_MANAGER.RegisterCallback then
        pcall(function()
            SCENE_MANAGER:RegisterCallback("SceneStateChanged", OnLayer)
        end)
    end
    Build()
    lastCombat = InCombat()
    T.StatusRefresh()
    zo_callLater(function()
        soundReady = true
    end, 1500)
end
