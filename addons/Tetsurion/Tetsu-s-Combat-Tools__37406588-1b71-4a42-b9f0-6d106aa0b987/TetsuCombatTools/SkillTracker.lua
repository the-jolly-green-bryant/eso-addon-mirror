TetsuCombatTools = TetsuCombatTools or {}
local T = TetsuCombatTools

local ADDON = "TetsuCombatToolsSkill"
local MAX_SLOTS = 8
local GCD_MS = 1000
local LA_DEDUP_MS = 280
local TICK_MS = 40
local EMPTY_ICON = "/esoui/art/actionbar/abilityframe64_up.dds"

local root
local icons = {}
local frames = {}
local gcdBg
local gcdFill
local frag
local history = {}
local gcdUntil = 0
local lastPress = 0
local combatLeftAt = 0
local lastLightAt = 0
local lastSkillAt = 0
local ticking = false
local built = false
local lightOn = false

local COL_EMPTY = { 0.18, 0.18, 0.18, 0.85 }
local COL_WOVEN = { 0.25, 0.85, 0.35, 1 }
local COL_BARE = { 0.90, 0.28, 0.22, 1 }
local COL_LIGHT = { 0.85, 0.75, 0.25, 0.95 }

local function Vars()
    return T.savedVars
end

local function Now()
    if GetGameTimeMilliseconds then
        return GetGameTimeMilliseconds()
    end
    return GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
end

local function InCombat()
    if not IsUnitInCombat then return false end
    local ok, v = pcall(IsUnitInCombat, "player")
    return ok and v and true or false
end

local function SkillOn()
    local v = Vars()
    return v and v.skillEnabled ~= false
end

local function SlotCount()
    local v = Vars()
    local n = v and tonumber(v.skillSlots) or 6
    if n < 4 then n = 4 end
    if n > 8 then n = 8 end
    return n
end

local function Scale()
    local v = Vars()
    local p = v and tonumber(v.skillScale) or 100
    if p < 50 then p = 50 end
    if p > 160 then p = 160 end
    return p / 100
end

local function ShowMode()
    local v = Vars()
    local m = v and v.skillShow
    if m == "always" or m == "idle" then return m end
    return "combat"
end

local function HideAfterMs()
    local v = Vars()
    local s = v and tonumber(v.skillHideAfter) or 8
    if s < 3 then s = 3 end
    if s > 15 then s = 15 end
    return s * 1000
end

local function FirstSkillSlot()
    return ACTION_BAR_FIRST_NORMAL_SLOT_INDEX or 3
end

local function UltSlot()
    return (ACTION_BAR_ULTIMATE_SLOT_INDEX or 7) + 1
end

local function IsBarSkillSlot(slot)
    slot = tonumber(slot) or 0
    return slot >= FirstSkillSlot() and slot <= UltSlot()
end

local function AbilityIcon(abilityId)
    if not abilityId or abilityId == 0 then return EMPTY_ICON end
    if GetAbilityIcon then
        local ok, tex = pcall(GetAbilityIcon, abilityId)
        if ok and type(tex) == "string" and tex ~= "" then
            return tex
        end
    end
    return EMPTY_ICON
end

local function SceneIsShowing(scene)
    if not scene or not scene.IsShowing then return false end
    local ok, showing = pcall(function()
        return scene:IsShowing()
    end)
    return ok and showing and true or false
end

-- World HUD only. Action-layer names are not stable on console (1.0.4 hid the bar forever).
local function WorldHudOpen()
    if HUD_SCENE or HUD_UI_SCENE then
        return SceneIsShowing(HUD_SCENE) or SceneIsShowing(HUD_UI_SCENE)
    end
    return true
end

local function ShouldShow()
    if not SkillOn() then return false end
    if not WorldHudOpen() then return false end
    local mode = ShowMode()
    local t = Now()
    if mode == "always" then
        return true
    end
    if mode == "idle" then
        return lastPress > 0 and (t - lastPress) < HideAfterMs()
    end
    if InCombat() then
        return true
    end
    if combatLeftAt > 0 and (t - combatLeftAt) < HideAfterMs() then
        return true
    end
    return false
end

local function Layout()
    if not root then return end
    local v = Vars()
    local ox = v and tonumber(v.skillOffsetX) or 0
    local oy = v and tonumber(v.skillOffsetY)
    if oy == nil then oy = 330 end
    local sc = Scale()
    local n = SlotCount()
    local size = math.floor(48 * sc + 0.5)
    local gap = math.floor(4 * sc + 0.5)
    local showGcd = not v or v.skillShowGcd ~= false
    local gcdH = 0
    if showGcd then
        gcdH = math.max(3, math.floor(5 * sc + 0.5))
    end
    local width = n * size + (n - 1) * gap
    local height = size + (showGcd and (4 + gcdH) or 0)

    root:ClearAnchors()
    -- 0,0 = screen center / reticle. +Y down, -Y up.
    root:SetAnchor(CENTER, GuiRoot, CENTER, ox, oy)
    root:SetDimensions(width, height)

    for i = 1, MAX_SLOTS do
        local ic = icons[i]
        local fr = frames[i]
        if ic and fr then
            if i <= n then
                fr:SetHidden(false)
                ic:SetHidden(false)
                local x = (i - 1) * (size + gap)
                fr:ClearAnchors()
                fr:SetAnchor(TOPLEFT, root, TOPLEFT, x, 0)
                fr:SetDimensions(size, size)
                ic:ClearAnchors()
                ic:SetAnchor(CENTER, fr, CENTER, 0, 0)
                ic:SetDimensions(size - 4, size - 4)
            else
                fr:SetHidden(true)
                ic:SetHidden(true)
            end
        end
    end

    if gcdBg then
        gcdBg:SetHidden(not showGcd)
        if showGcd then
            gcdBg:ClearAnchors()
            gcdBg:SetAnchor(BOTTOMLEFT, root, BOTTOMLEFT, 0, 0)
            gcdBg:SetDimensions(width, gcdH)
        end
    end
    if gcdFill then
        if not showGcd then
            gcdFill:SetHidden(true)
        else
            gcdFill:ClearAnchors()
            gcdFill:SetAnchor(BOTTOMLEFT, gcdBg or root, BOTTOMLEFT, 0, 0)
            gcdFill:SetHeight(gcdH)
        end
    end
end

local function PaintFrame(fr, col)
    if not fr or not col then return end
    fr:SetEdgeColor(col[1], col[2], col[3], col[4] or 1)
    fr:SetCenterColor(0, 0, 0, 0.45)
end

local function PaintHistory()
    local n = SlotCount()
    local count = #history
    for i = 1, n do
        local ic = icons[i]
        local fr = frames[i]
        if ic then
            local src = history[count - n + i]
            if src and src.icon then
                ic:SetTexture(src.icon)
                ic:SetColor(1, 1, 1, 1)
                ic:SetHidden(false)
                if src.kind == "light" then
                    PaintFrame(fr, COL_LIGHT)
                elseif src.woven then
                    PaintFrame(fr, COL_WOVEN)
                else
                    PaintFrame(fr, COL_BARE)
                end
            else
                ic:SetTexture(EMPTY_ICON)
                ic:SetColor(0.35, 0.35, 0.35, 0.45)
                ic:SetHidden(false)
                PaintFrame(fr, COL_EMPTY)
            end
        end
    end
end

local function PaintGcd()
    if not gcdFill or not gcdBg then return end
    local v = Vars()
    if v and v.skillShowGcd == false then
        gcdFill:SetHidden(true)
        gcdBg:SetHidden(true)
        return
    end
    gcdBg:SetHidden(false)
    local left = gcdUntil - Now()
    local width = gcdBg:GetWidth() or 1
    if left <= 0 then
        gcdFill:SetWidth(0)
        gcdFill:SetHidden(true)
        return
    end
    local frac = left / GCD_MS
    if frac > 1 then frac = 1 end
    gcdFill:SetHidden(false)
    gcdFill:SetWidth(math.max(1, width * frac))
    if frac > 0.33 then
        gcdFill:SetColor(0.95, 0.82, 0.25, 0.95)
    else
        gcdFill:SetColor(0.95, 0.35, 0.2, 0.95)
    end
end

local function StopTick()
    if ticking then
        EVENT_MANAGER:UnregisterForUpdate(ADDON .. "Tick")
        ticking = false
    end
end

local function Tick()
    PaintGcd()
    local show = ShouldShow()
    if root then
        root:SetHidden(not show)
    end
    if gcdUntil <= Now() and not show then
        StopTick()
    elseif gcdUntil <= Now() and ShowMode() == "always" then
        -- keep a slow visibility check only if needed
        if not InCombat() and lastPress > 0 and (Now() - lastPress) > 2000 then
            -- idle always-mode still wants the strip; no extra work
        end
    end
end

local function StartTick()
    if ticking then return end
    ticking = true
    EVENT_MANAGER:RegisterForUpdate(ADDON .. "Tick", TICK_MS, Tick)
end

local function Push(abilityId, icon, kind)
    if not SkillOn() then return end
    abilityId = tonumber(abilityId) or 0
    if abilityId == 0 and (not icon or icon == "") then return end
    local t = Now()
    local woven = false
    if kind ~= "light" then
        woven = lastLightAt > lastSkillAt and lastLightAt > 0
        lastSkillAt = t
    end
    history[#history + 1] = {
        id = abilityId,
        icon = icon or AbilityIcon(abilityId),
        kind = kind or "skill",
        woven = woven,
    }
    while #history > MAX_SLOTS do
        table.remove(history, 1)
    end
    lastPress = t
    PaintHistory()
    if root and ShouldShow() then
        root:SetHidden(false)
    end
    StartTick()
end

local function StartGcd()
    gcdUntil = Now() + GCD_MS
    PaintGcd()
    StartTick()
end

local function OnSlotUsed(_, actionSlotIndex)
    if not SkillOn() then return end
    if not IsBarSkillSlot(actionSlotIndex) then return end
    local abilityId = 0
    if GetSlotBoundId then
        local ok, id = pcall(GetSlotBoundId, actionSlotIndex)
        if ok then abilityId = tonumber(id) or 0 end
    end
    if abilityId == 0 then return end
    local tex
    if GetSlotTexture then
        local ok, t = pcall(GetSlotTexture, actionSlotIndex)
        if ok and type(t) == "string" and t ~= "" then
            tex = t
        end
    end
    Push(abilityId, tex or AbilityIcon(abilityId), "skill")
    StartGcd()
end

local SLOT_LA = ACTION_SLOT_TYPE_LIGHT_ATTACK or 5

local function OnLightFull(_, result, isError, _name, _graphic, slotType, _sName, sourceType, _tName, _tType, _hit, _power, _dmg, _log, _sid, _tid, abilityId)
    if not SkillOn() then return end
    if isError then return end
    if sourceType and COMBAT_UNIT_TYPE_PLAYER and sourceType ~= COMBAT_UNIT_TYPE_PLAYER then
        return
    end
    if slotType and slotType ~= SLOT_LA then
        return
    end
    local t = Now()
    if t - lastLightAt < LA_DEDUP_MS then return end
    lastLightAt = t
    local v = Vars()
    if v and v.skillLightAttacks == true then
        Push(tonumber(abilityId) or 0, AbilityIcon(tonumber(abilityId) or 0), "light")
    end
end

local LA_NS = { ADDON .. "LA1", ADDON .. "LA2", ADDON .. "LA3" }

local function UnregisterLight()
    if not lightOn then return end
    for i = 1, #LA_NS do
        EVENT_MANAGER:UnregisterForEvent(LA_NS[i], EVENT_COMBAT_EVENT)
    end
    lightOn = false
end

local function RegisterLight()
    local want = SkillOn()
    if want and lightOn then return end
    if not want then
        UnregisterLight()
        return
    end
    local results = {
        ACTION_RESULT_DAMAGE or 1,
        ACTION_RESULT_CRITICAL_DAMAGE or 2,
        ACTION_RESULT_BEGIN or 2200,
    }
    for i = 1, #LA_NS do
        EVENT_MANAGER:RegisterForEvent(LA_NS[i], EVENT_COMBAT_EVENT, OnLightFull)
        EVENT_MANAGER:AddFilterForEvent(LA_NS[i], EVENT_COMBAT_EVENT,
            REGISTER_FILTER_IS_ERROR, false,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER,
            REGISTER_FILTER_COMBAT_RESULT, results[i])
    end
    lightOn = true
end

local function OnCombat(_, inCombat)
    if inCombat then
        combatLeftAt = 0
        if SkillOn() and root and ShouldShow() then
            root:SetHidden(false)
            StartTick()
        end
    else
        combatLeftAt = Now()
        StartTick()
    end
end

local function AttachFragment(control)
    if not control then return end
    if ZO_HUDFadeSceneFragment then
        frag = ZO_HUDFadeSceneFragment:New(control)
    elseif ZO_SimpleSceneFragment then
        frag = ZO_SimpleSceneFragment:New(control)
    end
    if not frag then return end
    local function add(scene)
        if scene and scene.AddFragment then
            pcall(function() scene:AddFragment(frag) end)
        end
    end
    add(HUD_SCENE)
    add(HUD_UI_SCENE)
end

local function Build()
    if built then return end
    local wm = GetWindowManager()
    if not wm then return end

    root = wm:CreateTopLevelWindow(ADDON .. "Root")
    if not root then
        root = wm:CreateControl(ADDON .. "Root", GuiRoot, CT_TOPLEVELCONTROL)
    end
    if not root then return end
    root:SetParent(GuiRoot)
    root:SetHidden(true)
    root:SetClampedToScreen(true)
    root:SetMouseEnabled(false)
    root:SetMovable(false)
    root:SetResizeToFitDescendents(false)
    root:SetDrawLayer(DL_CONTROLS)
    root:SetDrawLevel(2)

    for i = 1, MAX_SLOTS do
        local fr = wm:CreateControl(ADDON .. "F" .. i, root, CT_BACKDROP)
        fr:SetCenterColor(0, 0, 0, 0.45)
        fr:SetEdgeColor(0.18, 0.18, 0.18, 0.85)
        fr:SetEdgeTexture("", 2, 2, 3)
        fr:SetInsets(3, 3, 3, 3)
        fr:SetHidden(true)
        frames[i] = fr

        local ic = wm:CreateControl(ADDON .. "I" .. i, fr, CT_TEXTURE)
        ic:SetHidden(true)
        ic:SetColor(1, 1, 1, 1)
        icons[i] = ic
    end

    gcdBg = wm:CreateControl(ADDON .. "GcdBg", root, CT_BACKDROP)
    gcdBg:SetCenterColor(0.05, 0.05, 0.05, 0.7)
    gcdBg:SetEdgeColor(0, 0, 0, 0)
    gcdBg:SetEdgeTexture(nil, 1, 1, 1)

    gcdFill = wm:CreateControl(ADDON .. "GcdFill", root, CT_TEXTURE)
    gcdFill:SetTexture("/esoui/art/miscellaneous/progressbar_genericfill.dds")
    gcdFill:SetColor(0.95, 0.82, 0.25, 0.95)
    gcdFill:SetHidden(true)

    AttachFragment(root)
    built = true
    Layout()
    PaintHistory()
end

function T.SkillRefresh()
    RegisterLight()
    if not SkillOn() then
        StopTick()
        if root then root:SetHidden(true) end
        return
    end
    if not built then
        Build()
    end
    Layout()
    PaintHistory()
    PaintGcd()
    local show = ShouldShow()
    if root then root:SetHidden(not show) end
    if show or gcdUntil > Now() then
        StartTick()
    end
end

function T.SkillStart()
    EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_ACTION_SLOT_ABILITY_USED, OnSlotUsed)
    EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_PLAYER_COMBAT_STATE, OnCombat)
    local function OnLayer()
        if root then
            root:SetHidden(not ShouldShow())
        end
    end
    if EVENT_ACTION_LAYER_PUSHED then
        EVENT_MANAGER:RegisterForEvent(ADDON .. "LayerP", EVENT_ACTION_LAYER_PUSHED, OnLayer)
    end
    if EVENT_ACTION_LAYER_POPPED then
        EVENT_MANAGER:RegisterForEvent(ADDON .. "LayerO", EVENT_ACTION_LAYER_POPPED, OnLayer)
    end
    if SCENE_MANAGER and SCENE_MANAGER.RegisterCallback then
        pcall(function()
            SCENE_MANAGER:RegisterCallback("SceneStateChanged", function()
                OnLayer()
            end)
        end)
    end
    Build()
    T.SkillRefresh()
end
