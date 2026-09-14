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
local previewUntil = 0

local SOUND_KEYS = {
    duel     = { key = "DUEL_START",                      fb = "Duel_Start" },
    alert    = { key = "GENERAL_ALERT_ERROR",             fb = "General_Alert_Error" },
    notify   = { key = "NEW_NOTIFICATION",                fb = "New_Notification" },
    discover = { key = "OBJECTIVE_DISCOVERED",            fb = "Objective_Discovered" },
    kill     = { key = "DEATH_RECAP_KILLING_BLOW_SHOWN",  fb = "Death_Recap_Killing_Blow_Shown" },
    rune     = { key = "ENCHANTING_POTENCY_RUNE_PLACED",  fb = "Enchanting_Potency_Rune_Placed" },
    glyph    = { key = "ENCHANTING_WEAPON_GLYPH_REMOVED", fb = "Enchanting_Weapon_Glyph_Removed" },
    quest    = { key = "QUEST_OBJECTIVE_INCREMENT",       fb = "Quest_Objective_Increment" },
    level    = { key = "LEVEL_UP",                        fb = "Level_Up" },
    mail     = { key = "NEW_MAIL",                        fb = "New_Mail" },
    skill    = { key = "SKILL_GAINED",                    fb = "Skill_Gained" },
    lock     = { key = "LOCKPICKING_SUCCESS",             fb = "Lockpicking_Success" },
    ready    = { key = "GROUP_READY_CHECK_INITIATED",     fb = "Group_Ready_Check_Initiated" },
    tick     = { key = "COUNTDOWN_TICK",                  fb = "Countdown_Tick" },
    bgmin    = { key = "BATTLEGROUND_ONE_MINUTE_WARNING", fb = "Battleground_One_Minute_Warning" },
    bggo     = { key = "BATTLEGROUND_COUNTDOWN_FINISH",   fb = "Battleground_Countdown_Finish" },
    trialok  = { key = "RAID_TRIAL_COMPLETED",            fb = "Raid_Trial_Completed" },
    trialno  = { key = "RAID_TRIAL_FAILED",               fb = "Raid_Trial_Failed" },
    achieve  = { key = "ACHIEVEMENT_AWARDED",             fb = "Achievement_Awarded" },
    sky      = { key = "SKYSHARD_GAINED",                 fb = "Skyshard_Gained" },
    qdone    = { key = "QUEST_COMPLETED",                 fb = "Quest_Completed" },
    qacc     = { key = "QUEST_ACCEPTED",                  fb = "Quest_Accepted" },
    champ    = { key = "CHAMPION_POINTS_COMMITTED",       fb = "Champion_Points_Committed" },
    abil     = { key = "ABILITY_UNLOCKED",                fb = "Ability_Unlocked" },
    coll     = { key = "COLLECTIBLE_UNLOCKED",            fb = "Collectible_Unlocked" },
    book     = { key = "BOOK_ACQUIRED",                   fb = "Book_Acquired" },
    ess      = { key = "ENCHANTING_ESSENCE_RUNE_PLACED",  fb = "Enchanting_Essence_Rune_Placed" },
    asp      = { key = "ENCHANTING_ASPECT_RUNE_PLACED",   fb = "Enchanting_Aspect_Rune_Placed" },
    alc      = { key = "ALCHEMY_SOLVENT_PLACED",          fb = "Alchemy_Solvent_Placed" },
    friend   = { key = "FRIEND_INVITE_RECEIVED",          fb = "Friend_Invite_Received" },
    gjoin    = { key = "GROUP_JOIN",                      fb = "Group_Join" },
    kos      = { key = "JUSTICE_NOW_KOS",                 fb = "Justice_Now_KOS" },
    lbreak   = { key = "LOCKPICKING_BREAK",               fb = "Lockpicking_Break" },
    kick     = { key = "INSTANCE_KICK_WARNING",           fb = "Instance_Kick_Warning" },
    fanfare  = { key = "LEVEL_UP_REWARD_FANFARE",         fb = "Level_Up_Reward_Fanfare" },
    medal    = { key = "BATTLEGROUND_MEDAL_RECEIVED",     fb = "Battleground_Medal_Received" },
    spt      = { key = "SKILL_POINT_GAINED",              fb = "Skill_Point_Gained" },
    map      = { key = "MAP_LOCATION_DISCOVERED",         fb = "Map_Location_Discovered" },
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
    if p < 40 then p = 40 end
    if p > 250 then p = 250 end
    return p / 100
end

local function IconAlpha()
    local v = Vars()
    local p = v and tonumber(v.statusIconAlpha) or 50
    if p < 10 then p = 10 end
    if p > 100 then p = 100 end
    return p / 100
end

local function NowMs()
    if GetGameTimeMilliseconds then
        return GetGameTimeMilliseconds()
    end
    return GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
end

local function PreviewLive()
    return previewUntil > NowMs()
end

local function FightNow()
    return PreviewLive() or InCombat()
end

local function PlayStartSound()
    local v = Vars()
    if not v then return end
    -- Preview / dropdown preview ignore the "sound on combat start" mute
    -- only when called from T.PlayStatusSound; live combat still uses SoundOn.
    local vol = tonumber(v.statusSoundVolume)
    if vol == nil then vol = 2 end
    if vol < 1 then return end
    if vol > 5 then vol = 5 end
    local id = v.statusSoundId
    if id == "ready" or id == "level" or id == "skill" or id == "abil"
        or id == "quest" or id == "sky" or id == "map" or id == "kick" then
        id = "duel"
        v.statusSoundId = "duel"
    end
    local spec = SOUND_KEYS[id] or SOUND_KEYS.duel
    local payload = nil
    if SOUNDS and spec.key and SOUNDS[spec.key] then
        payload = SOUNDS[spec.key]
    elseif spec.fb then
        payload = spec.fb
    end
    if not payload or not PlaySound then return end
    for _ = 1, vol do
        pcall(PlaySound, payload)
    end
end
T.PlayStatusSound = PlayStartSound

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
    iconRoot:SetClampedToScreen(false)
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
    local px = math.floor(28 * sc + 0.5)
    if px < 14 then px = 14 end
    if px > 90 then px = 90 end
    textRoot:SetClampedToScreen(false)
    textRoot:ClearAnchors()
    textRoot:SetAnchor(CENTER, GuiRoot, CENTER, ox, oy)
    textRoot:SetDimensions(math.floor(420 * sc), math.floor(px + 16))
    local fontName = "$(GAMEPAD_BOLD_FONT)|" .. px .. "|soft-shadow-thick"
    local ok = pcall(function()
        textLab:SetFont(fontName)
    end)
    if not ok then
        pcall(function()
            textLab:SetFont(px >= 32 and "ZoFontGamepad34" or (px >= 24 and "ZoFontGamepad27" or "ZoFontGamepad22"))
        end)
    end
    textLab:ClearAnchors()
    textLab:SetAnchor(CENTER, textRoot, CENTER, 0, 0)
    textLab:SetDimensions(math.floor(420 * sc), math.floor(px + 16))
    textLab:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
end

local function Paint()
    local fight = FightNow()
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
    local prev = PreviewLive()
    local hud = WorldHudOpen() or prev
    if iconRoot then
        iconRoot:SetHidden(not ((IconOn() or prev) and hud and StatusOn()))
    end
    if textRoot then
        textRoot:SetHidden(not ((TextOn() or prev) and hud and StatusOn()))
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
    iconRoot:SetClampedToScreen(false)
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
    textRoot:SetClampedToScreen(false)
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
    if inCombat and not lastCombat and soundReady and SoundOn() then
        PlayStartSound()
    end
    lastCombat = inCombat
    Paint()
    ApplyShown()
end

function T.StatusPreview()
    if not StatusOn() then
        return
    end
    previewUntil = NowMs() + 8000
    if not built then
        Build()
    end
    if SoundOn() then
        PlayStartSound()
    end
    T.StatusRefresh()
    EVENT_MANAGER:UnregisterForUpdate(ADDON .. "Prev")
    EVENT_MANAGER:RegisterForUpdate(ADDON .. "Prev", 200, function()
        if not PreviewLive() then
            EVENT_MANAGER:UnregisterForUpdate(ADDON .. "Prev")
            previewUntil = 0
            T.StatusRefresh()
        end
    end)
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
