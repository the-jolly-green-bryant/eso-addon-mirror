-----------------------------------------------------------
-- DarkScrollsUI - DS_BossBar.lua
-- Soulslike boss health bar. Appears automatically when
-- targeting a boss and fades out when the target changes
-- or the boss dies.
-----------------------------------------------------------

-----------------------------------------------------------
-- VISUAL CONFIGURATION
-----------------------------------------------------------
local BossBarVisualConfiguration = {
    DEFAULT_W       = 742,
    DEFAULT_H       = 10,
    DEFAULT_X       = 590,
    DEFAULT_Y       = 880,

    APPEAR_TIME     = 0.35,
    DISAPPEAR_TIME  = 0.6,
    -- How long the bar lingers after the boss dies
    DEATH_LINGER    = 1.8,

    FILL_SPEED      = 0.55,
    DRAIN_LINGER    = 0.55,

    COLOR_FILL_TOP     = {0.78, 0.10, 0.10, 1},
    COLOR_FILL_BOTTOM  = {0.38, 0.04, 0.04, 1},
    COLOR_DRAIN        = {0.90, 0.52, 0.08, 0.85},
    COLOR_BG           = {0.04, 0.04, 0.04, 0.96},
    COLOR_BORDER       = {0.55, 0.45, 0.35, 1},
    COLOR_SEPARATOR    = {0.55, 0.45, 0.35, 0.55},
    COLOR_FLASH        = {1.0,  0.85, 0.60, 1},

    -- Border pulse when boss HP is below this threshold
    PULSE_THRESHOLD = 0.10,
    PULSE_MIN       = 0.5,
    PULSE_MAX       = 1.0,
    PULSE_SPEED     = 2.8,

    SEGMENTS        = 8,
    CTRL_NAME       = "DarkScrollsUI_BossHealthBarDisplay",

    TEX_DIRTY       = "DarkScrollsUI/Images/bar_dirty.dds",
    TEX_EDGE        = "DarkScrollsUI/Images/bar_edge.dds",
    DIRTY_ALPHA     = 0.40,
    DIRTY_SCROLL    = 0.04,
    EDGE_WIDTH      = 14,
}

-----------------------------------------------------------
-- INTERNAL STATE
-----------------------------------------------------------
local DarkScrollsUI_BossHealthBarControl   = nil
local DarkScrollsUI_BossHealthBarInternalState = {
    displayPct  = 0,
    targetPct   = 0,
    drainPct    = 0,
    drainTimer  = 0,
    fadeAlpha   = 0,
    fadeTarget  = 0,
    deathTimer  = 0,
    isDying     = false,
    dirtyUV     = 0,
    lastBossTag = nil,
    bossName    = "",
}

-----------------------------------------------------------
-- UTILITIES
-----------------------------------------------------------
function DarkScrollsUI.IsBossUnit(unitTag)
    if not DoesUnitExist(unitTag) or IsUnitPlayer(unitTag) then return false end
    if IsUnitJusticeGuard(unitTag) or IsUnitInvulnerableGuard(unitTag) then return false end
    local difficulty = GetUnitDifficulty(unitTag) or 0
    return difficulty >= 3
end

local function GetBossHealth(unitTag)
    local cur, _, effMax = GetUnitPower(unitTag, POWERTYPE_HEALTH)
    if not effMax or effMax <= 0 then return nil, nil end
    return cur, effMax
end

local function Lerp(a, b, t)
    return a + (b - a) * t
end

-----------------------------------------------------------
-- BAR CREATION
-----------------------------------------------------------
local function CreateBossBar()
    local wm   = WINDOW_MANAGER
    local name = BossBarVisualConfiguration.CTRL_NAME
    local bar  = wm:CreateControl(name, GuiRoot, CT_TOPLEVELCONTROL)

    bar:SetDrawLayer(DL_BACKGROUND)
    bar:SetDrawTier(DT_HIGH)
    bar:SetClampedToScreen(true)
    bar:SetMouseEnabled(not DarkScrollsUI.isInterfaceLocked)
    bar:SetMovable(not DarkScrollsUI.isInterfaceLocked)
    bar:SetAlpha(0)
    bar:SetHidden(false)

    if DarkScrollsUI.SavedVariables and DarkScrollsUI.SavedVariables[name] then
        local s = DarkScrollsUI.SavedVariables[name]
        bar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, s.l, s.t)
        bar:SetDimensions(s.w, s.h)
    else
        bar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BossBarVisualConfiguration.DEFAULT_X, BossBarVisualConfiguration.DEFAULT_Y)
        bar:SetDimensions(BossBarVisualConfiguration.DEFAULT_W, BossBarVisualConfiguration.DEFAULT_H)
    end

    bar.bg = wm:CreateControl(name.."BG", bar, CT_BACKDROP)
    bar.bg:SetAnchorFill()
    bar.bg:SetCenterColor(unpack(BossBarVisualConfiguration.COLOR_BG))
    bar.bg:SetEdgeColor(unpack(BossBarVisualConfiguration.COLOR_BORDER))
    bar.bg:SetEdgeTexture("", 1, 2, 2)

    bar.fillDrain = wm:CreateControl(name.."Drain", bar, CT_TEXTURE)
    bar.fillDrain:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, 0)
    bar.fillDrain:SetHeight(bar:GetHeight())
    bar.fillDrain:SetColor(unpack(BossBarVisualConfiguration.COLOR_DRAIN))
    bar.fillDrain:SetDrawLayer(DL_BACKGROUND)
    bar.fillDrain:SetDrawTier(DT_LOW)
    bar.fillDrain:SetHidden(true)

    bar.fillMain = wm:CreateControl(name.."FillMain", bar, CT_CONTROL)
    bar.fillMain:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, 0)
    bar.fillMain:SetDimensions(bar:GetWidth(), bar:GetHeight())

    bar.fillBottom = wm:CreateControl(name.."FillBot", bar.fillMain, CT_BACKDROP)
    bar.fillBottom:SetAnchor(BOTTOMLEFT, bar.fillMain, BOTTOMLEFT, 0, 0)
    bar.fillBottom:SetCenterColor(unpack(BossBarVisualConfiguration.COLOR_FILL_BOTTOM))
    bar.fillBottom:SetEdgeColor(0, 0, 0, 0)

    bar.fillTop = wm:CreateControl(name.."FillTop", bar.fillMain, CT_BACKDROP)
    bar.fillTop:SetAnchor(TOPLEFT, bar.fillMain, TOPLEFT, 0, 0)
    bar.fillTop:SetCenterColor(unpack(BossBarVisualConfiguration.COLOR_FILL_TOP))
    bar.fillTop:SetEdgeColor(0, 0, 0, 0)

    bar.fillEdge = wm:CreateControl(name.."Edge", bar, CT_TEXTURE)
    bar.fillEdge:SetTexture(BossBarVisualConfiguration.TEX_EDGE)
    bar.fillEdge:SetDrawTier(DT_HIGH)
    bar.fillEdge:SetHidden(true)

    bar.fillDirty = wm:CreateControl(name.."Dirty", bar.fillMain, CT_TEXTURE)
    bar.fillDirty:SetParent(bar.fillMain)
    bar.fillDirty:SetAnchorFill()
    bar.fillDirty:SetTexture(BossBarVisualConfiguration.TEX_DIRTY)
    bar.fillDirty:SetAddressMode(TEX_MODE_WRAP)
    bar.fillDirty:SetAlpha(BossBarVisualConfiguration.DIRTY_ALPHA)
    bar.fillDirty:SetDrawTier(DT_LOW)

    bar.segments = {}
    for i = 1, BossBarVisualConfiguration.SEGMENTS - 1 do
        local seg = wm:CreateControl(name.."Seg"..i, bar, CT_TEXTURE)
        seg:SetDrawTier(DT_MEDIUM)
        seg:SetColor(unpack(BossBarVisualConfiguration.COLOR_SEPARATOR))
        seg:SetWidth(1)
        table.insert(bar.segments, seg)
    end

    bar.flash = wm:CreateControl(name.."Flash", bar, CT_BACKDROP)
    bar.flash:SetAnchorFill()
    bar.flash:SetCenterColor(BossBarVisualConfiguration.COLOR_FLASH[1], BossBarVisualConfiguration.COLOR_FLASH[2], BossBarVisualConfiguration.COLOR_FLASH[3], 0)
    bar.flash:SetEdgeColor(0, 0, 0, 0)
    bar.flash:SetDrawTier(DT_TOP)

    -- nameLabel: independent top-level control so it can be moved separately
    local nameName = name .. "Name"
    local nameCtrl = wm:CreateControl(nameName, GuiRoot, CT_TOPLEVELCONTROL)
    nameCtrl:SetDrawLayer(DL_BACKGROUND)
    nameCtrl:SetDrawTier(DT_HIGH)
    nameCtrl:SetClampedToScreen(true)
    nameCtrl:SetMouseEnabled(not DarkScrollsUI.isInterfaceLocked)
    nameCtrl:SetMovable(not DarkScrollsUI.isInterfaceLocked)

    -- Default position: centered above the bar
    local sv = DarkScrollsUI.SavedVariables
    if sv and not sv[nameName] then
        local barS = sv[name]
        local defL = barS and (barS.l + barS.w / 2 - 200) or (BossBarVisualConfiguration.DEFAULT_X + BossBarVisualConfiguration.DEFAULT_W / 2 - 200)
        local defT = barS and (barS.t - 40) or (BossBarVisualConfiguration.DEFAULT_Y - 40)
        sv[nameName] = { l = defL, t = defT, w = 400, h = 36, a = 1, r = 0, fs = 1 }
    end
    local ns = (sv and sv[nameName]) or { l = BossBarVisualConfiguration.DEFAULT_X + BossBarVisualConfiguration.DEFAULT_W / 2 - 200, t = BossBarVisualConfiguration.DEFAULT_Y - 40, w = 400, h = 36 }
    nameCtrl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ns.l, ns.t)
    nameCtrl:SetDimensions(ns.w, ns.h)
    nameCtrl:SetAlpha(ns.a or 1)

    nameCtrl.bg = wm:CreateControl(nameName .. "BG", nameCtrl, CT_BACKDROP)
    nameCtrl.bg:SetAnchorFill()
    nameCtrl.bg:SetCenterColor(0, 1, 0, DarkScrollsUI.isInterfaceLocked and 0 or 0.4)
    nameCtrl.bg:SetEdgeColor(0, 1, 0, DarkScrollsUI.isInterfaceLocked and 0 or 0.8)
    nameCtrl.bg:SetEdgeTexture("", 1, 1, 2)

    bar.nameLabel = wm:CreateControl(nameName .. "Label", nameCtrl, CT_LABEL)
    bar.nameLabel:SetAnchor(CENTER, nameCtrl, CENTER, 0, 0)
    bar.nameLabel:SetFont("ZoFontWinH4")
    bar.nameLabel:SetColor(0.92, 0.86, 0.72, 1)
    bar.nameLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    bar.nameLabel:SetText("")

    bar.nameCtrl = nameCtrl  -- keep reference for show/hide

    DarkScrollsUI.SetupCommonInterfaceHandlers(nameCtrl)
    DarkScrollsUI.UpdateElementTextScaleValue(nameCtrl)

    -- hpLabel: also an independent top-level control
    local hpName = name .. "HP"
    local hpCtrl = wm:CreateControl(hpName, GuiRoot, CT_TOPLEVELCONTROL)
    hpCtrl:SetDrawLayer(DL_BACKGROUND)
    hpCtrl:SetDrawTier(DT_HIGH)
    hpCtrl:SetClampedToScreen(true)
    hpCtrl:SetMouseEnabled(not DarkScrollsUI.isInterfaceLocked)
    hpCtrl:SetMovable(not DarkScrollsUI.isInterfaceLocked)

    if sv and not sv[hpName] then
        local barS = sv[name]
        local defL = barS and (barS.l - 80) or (BossBarVisualConfiguration.DEFAULT_X - 80)
        local defT = barS and (barS.t - 2) or (BossBarVisualConfiguration.DEFAULT_Y - 2)
        sv[hpName] = { l = defL, t = defT, w = 72, h = 20, a = 1, r = 0, fs = 1 }
    end
    local hs = (sv and sv[hpName]) or { l = BossBarVisualConfiguration.DEFAULT_X - 80, t = BossBarVisualConfiguration.DEFAULT_Y - 2, w = 72, h = 20 }
    hpCtrl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, hs.l, hs.t)
    hpCtrl:SetDimensions(hs.w, hs.h)
    hpCtrl:SetAlpha(hs.a or 1)

    hpCtrl.bg = wm:CreateControl(hpName .. "BG", hpCtrl, CT_BACKDROP)
    hpCtrl.bg:SetAnchorFill()
    hpCtrl.bg:SetCenterColor(0, 1, 0, DarkScrollsUI.isInterfaceLocked and 0 or 0.4)
    hpCtrl.bg:SetEdgeColor(0, 1, 0, DarkScrollsUI.isInterfaceLocked and 0 or 0.8)
    hpCtrl.bg:SetEdgeTexture("", 1, 1, 2)

    bar.hpLabel = wm:CreateControl(hpName .. "Label", hpCtrl, CT_LABEL)
    bar.hpLabel:SetAnchor(CENTER, hpCtrl, CENTER, 0, 0)
    bar.hpLabel:SetFont("ZoFontWinH4")
    bar.hpLabel:SetColor(0.80, 0.75, 0.65, 1)
    bar.hpLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    bar.hpLabel:SetText("")

    bar.hpCtrl = hpCtrl  -- keep reference for show/hide

    DarkScrollsUI.SetupCommonInterfaceHandlers(hpCtrl)
    DarkScrollsUI.UpdateElementTextScaleValue(hpCtrl)

    DarkScrollsUI.SetupCommonInterfaceHandlers(bar)

    return bar
end

-----------------------------------------------------------
-- SEGMENT POSITIONING
-----------------------------------------------------------
local function UpdateSegments(bar)
    local w     = bar:GetWidth()
    local h     = bar:GetHeight()
    local count = #bar.segments
    for i, seg in ipairs(bar.segments) do
        local x = (w / (count + 1)) * i
        seg:ClearAnchors()
        seg:SetAnchor(TOPLEFT, bar, TOPLEFT, x, 0)
        seg:SetHeight(h)
    end
end

-----------------------------------------------------------
-- BOSS HP UPDATE
-----------------------------------------------------------
local function OnBossHealthUpdate(unitTag)
    if not DoesUnitExist(unitTag) then return end

    local cur, max = GetBossHealth(unitTag)
    if not cur or not max then return end

    local newPct   = math.max(0, math.min(1, cur / max))
    local st       = DarkScrollsUI_BossHealthBarInternalState

    st.targetPct = newPct

    if DarkScrollsUI_BossHealthBarControl and DarkScrollsUI_BossHealthBarControl.hpLabel then
        DarkScrollsUI_BossHealthBarControl.hpLabel:SetText(string.format("%d%%", math.floor(newPct * 100 + 0.5)))
    end

    if cur <= 0 and not st.isDying and IsUnitDead(unitTag) then
        st.isDying    = true
        st.deathTimer = GetFrameTimeSeconds()
    end
end

-----------------------------------------------------------
-- PER-FRAME TICK
-----------------------------------------------------------
local function TickBossBar(dt)
    if not DarkScrollsUI_BossHealthBarControl then return end

    local st  = DarkScrollsUI_BossHealthBarInternalState
    local bar = DarkScrollsUI_BossHealthBarControl
    local now = GetFrameTimeSeconds()

    -- Fade in / out
    if st.fadeAlpha ~= st.fadeTarget then
        local fadeSpeed = (st.fadeTarget > st.fadeAlpha)
            and (1 / BossBarVisualConfiguration.APPEAR_TIME)
            or  (1 / BossBarVisualConfiguration.DISAPPEAR_TIME)
        local delta = fadeSpeed * dt * (st.fadeTarget > st.fadeAlpha and 1 or -1)
        st.fadeAlpha = math.max(0, math.min(1, st.fadeAlpha + delta))
    end

    local savedAlpha = (DarkScrollsUI.SavedVariables and DarkScrollsUI.SavedVariables[BossBarVisualConfiguration.CTRL_NAME] and DarkScrollsUI.SavedVariables[BossBarVisualConfiguration.CTRL_NAME].a) or 1
    bar:SetAlpha(st.fadeAlpha * savedAlpha)

    -- Apply same fade to independent name and hp controls
    if bar.nameCtrl then
        local nameSavedAlpha = (DarkScrollsUI.SavedVariables and DarkScrollsUI.SavedVariables[BossBarVisualConfiguration.CTRL_NAME .. "Name"] and DarkScrollsUI.SavedVariables[BossBarVisualConfiguration.CTRL_NAME .. "Name"].a) or 1
        bar.nameCtrl:SetAlpha(st.fadeAlpha * nameSavedAlpha)
    end
    if bar.hpCtrl then
        local hpSavedAlpha = (DarkScrollsUI.SavedVariables and DarkScrollsUI.SavedVariables[BossBarVisualConfiguration.CTRL_NAME .. "HP"] and DarkScrollsUI.SavedVariables[BossBarVisualConfiguration.CTRL_NAME .. "HP"].a) or 1
        bar.hpCtrl:SetAlpha(st.fadeAlpha * hpSavedAlpha)
    end

    -- Trigger golden flash at start of fade-in
    if st.fadeTarget == 1 and st.fadeAlpha > 0 and st.fadeAlpha < 0.1 and not st.flashTimer then
        st.flashTimer = now
    end

    if st.fadeAlpha <= 0 then return end

    -- Golden flash animation
    if st.flashTimer then
        local elapsed  = now - st.flashTimer
        local flashDur = 0.4
        if elapsed < flashDur then
            local flashA = (1 - elapsed / flashDur) * 0.45
            bar.flash:SetCenterColor(BossBarVisualConfiguration.COLOR_FLASH[1], BossBarVisualConfiguration.COLOR_FLASH[2], BossBarVisualConfiguration.COLOR_FLASH[3], flashA)
        else
            bar.flash:SetCenterColor(BossBarVisualConfiguration.COLOR_FLASH[1], BossBarVisualConfiguration.COLOR_FLASH[2], BossBarVisualConfiguration.COLOR_FLASH[3], 0)
            st.flashTimer = nil
        end
    end

    -- Fill animation
    if st.displayPct < st.targetPct then
        st.displayPct = math.min(st.targetPct, st.displayPct + BossBarVisualConfiguration.FILL_SPEED * dt)
    elseif st.displayPct > st.targetPct then
        st.displayPct = st.targetPct
    end

    local barW = bar:GetWidth()
    local barH = bar:GetHeight()

    -- Main fill
    local fillW = math.max(0, st.displayPct * barW)
    bar.fillMain:SetWidth(fillW)
    bar.fillMain:SetHeight(barH)
    bar.fillTop:SetDimensions(fillW, barH / 2)
    bar.fillBottom:SetDimensions(fillW, barH / 2)

    -- Edge tip
    if fillW > BossBarVisualConfiguration.EDGE_WIDTH then
        bar.fillEdge:SetWidth(BossBarVisualConfiguration.EDGE_WIDTH)
        bar.fillEdge:SetHeight(barH)
        bar.fillEdge:ClearAnchors()
        bar.fillEdge:SetAnchor(RIGHT, bar.fillMain, RIGHT, 0, 0)
        bar.fillEdge:SetHidden(false)
    else
        bar.fillEdge:SetHidden(true)
    end

    -- Border pulse near death
    if st.targetPct <= BossBarVisualConfiguration.PULSE_THRESHOLD and st.targetPct > 0 then
        local cycle = (now * BossBarVisualConfiguration.PULSE_SPEED) % 1.0
        local pulse = (math.sin(cycle * math.pi * 2) + 1) / 2
        local alpha = Lerp(BossBarVisualConfiguration.PULSE_MIN, BossBarVisualConfiguration.PULSE_MAX, pulse)
        bar.bg:SetEdgeColor(BossBarVisualConfiguration.COLOR_BORDER[1], BossBarVisualConfiguration.COLOR_BORDER[2] * 0.3, BossBarVisualConfiguration.COLOR_BORDER[3] * 0.3, alpha)
    else
        bar.bg:SetEdgeColor(unpack(BossBarVisualConfiguration.COLOR_BORDER))
    end

    -- Dirty texture scroll
    st.dirtyUV = (st.dirtyUV + BossBarVisualConfiguration.DIRTY_SCROLL * dt) % 1.0
    bar.fillDirty:SetTextureCoords(st.dirtyUV, st.dirtyUV + 1.0, 0, 1)

    -- Resize segments if bar dimensions changed
    if bar.lastW ~= barW or bar.lastH ~= barH then
        bar.lastW = barW
        bar.lastH = barH
        UpdateSegments(bar)
    end
end

-----------------------------------------------------------
-- SHOW / HIDE
-----------------------------------------------------------
local function ShowBossBar(unitTag)
    if not DarkScrollsUI_BossHealthBarControl then return end

    DarkScrollsUI.isCustomBossBarActive = true

    if ZO_BossBar                    then ZO_BossBar:SetHidden(true)                    end
    if ZO_TargetUnitFramereticleover then ZO_TargetUnitFramereticleover:SetHidden(true) end
    if ZO_CompassCenterOverlays      then ZO_CompassCenterOverlays:SetHidden(true)      end

    if BOSS_BAR_FRAGMENT then
        HUD_SCENE:RemoveFragment(BOSS_BAR_FRAGMENT)
        HUD_UI_SCENE:RemoveFragment(BOSS_BAR_FRAGMENT)
        if LOOT_SCENE       then LOOT_SCENE:RemoveFragment(BOSS_BAR_FRAGMENT)       end
        if WORLD_MAP_SCENE  then WORLD_MAP_SCENE:RemoveFragment(BOSS_BAR_FRAGMENT)  end
    end

    local name, pct
    if unitTag == "edit" then
        name = "BOSS NAME (EDIT MODE)"
        pct  = 0.65
    else
        name = GetUnitName(unitTag) or "???"
        local cur, max = GetBossHealth(unitTag)
        if not cur or not max then
            pct = 1.0 -- Fallback to 100% if API data is not yet available
        else
            pct = math.max(0, math.min(1, cur / max))
        end
    end

    DarkScrollsUI_BossHealthBarInternalState.lastBossTag = unitTag
    DarkScrollsUI_BossHealthBarInternalState.targetPct   = pct
    DarkScrollsUI_BossHealthBarInternalState.displayPct  = pct
    DarkScrollsUI_BossHealthBarInternalState.drainPct    = pct
    DarkScrollsUI_BossHealthBarInternalState.isDying     = false
    DarkScrollsUI_BossHealthBarInternalState.fadeTarget  = 1
    DarkScrollsUI_BossHealthBarInternalState.bossName    = name

    DarkScrollsUI_BossHealthBarControl.nameLabel:SetText(name:upper())
    if DarkScrollsUI_BossHealthBarControl.nameCtrl then
        DarkScrollsUI_BossHealthBarControl.nameCtrl:SetHidden(false)
    end
    if DarkScrollsUI_BossHealthBarControl.hpCtrl then
        DarkScrollsUI_BossHealthBarControl.hpCtrl:SetHidden(false)
    end
    OnBossHealthUpdate(unitTag)

    if DarkScrollsUI_BossHealthBarControl.bg then
        DarkScrollsUI_BossHealthBarControl.bg:SetCenterColor(unpack(BossBarVisualConfiguration.COLOR_BG))
    end
end

local function HideBossBar()
    if not DarkScrollsUI_BossHealthBarControl then return end

    DarkScrollsUI.isCustomBossBarActive = false

    if BOSS_BAR_FRAGMENT then
        HUD_SCENE:AddFragment(BOSS_BAR_FRAGMENT)
        HUD_UI_SCENE:AddFragment(BOSS_BAR_FRAGMENT)
        if LOOT_SCENE      then LOOT_SCENE:AddFragment(BOSS_BAR_FRAGMENT)      end
        if WORLD_MAP_SCENE then WORLD_MAP_SCENE:AddFragment(BOSS_BAR_FRAGMENT) end
    end

    DarkScrollsUI_BossHealthBarInternalState.fadeTarget  = 0
    DarkScrollsUI_BossHealthBarInternalState.lastBossTag = nil

    if DarkScrollsUI_BossHealthBarControl then
        if DarkScrollsUI_BossHealthBarControl.nameCtrl then
            DarkScrollsUI_BossHealthBarControl.nameCtrl:SetHidden(true)
        end
        if DarkScrollsUI_BossHealthBarControl.hpCtrl then
            DarkScrollsUI_BossHealthBarControl.hpCtrl:SetHidden(true)
        end
    end
end

-----------------------------------------------------------
-- BOSS DETECTION
-----------------------------------------------------------
local function CheckReticleTarget()
    local tags      = {"reticleover", "boss1", "boss2", "boss3", "boss4", "boss5", "boss6"}
    local activeTag = nil

    for i = 1, #tags do
        local tag = tags[i]
        if DoesUnitExist(tag) and DarkScrollsUI.IsBossUnit(tag) and not IsUnitDead(tag) then
            activeTag = tag
            break
        end
    end

    if activeTag then
        local name = GetUnitName(activeTag)
        if DarkScrollsUI_BossHealthBarInternalState.fadeTarget == 0 or DarkScrollsUI_BossHealthBarInternalState.bossName ~= name then
            ShowBossBar(activeTag)
        else
            DarkScrollsUI_BossHealthBarInternalState.lastBossTag = activeTag
        end
    elseif DarkScrollsUI_BossHealthBarInternalState.fadeTarget == 1 and not DarkScrollsUI_BossHealthBarInternalState.isDying then
        if DarkScrollsUI_BossHealthBarInternalState.bossName ~= "BOSS NAME (EDIT MODE)" then
            HideBossBar()
        end
    end
end

-----------------------------------------------------------
-- GLOBAL TICK (integrated into DS_Bars.TickAllBars)
-----------------------------------------------------------
function DarkScrollsUI.TickCustomBossBar(dt)
    local st = DarkScrollsUI_BossHealthBarInternalState
    if st.isDying and st.lastBossTag then
        local now = GetFrameTimeSeconds()
        if now - st.deathTimer >= BossBarVisualConfiguration.DEATH_LINGER then
            st.isDying = false
            HideBossBar()
        end
    end

    local isEditing = (not DarkScrollsUI.isInterfaceLocked or DarkScrollsUI.isGlobalEditModeActive)
    if isEditing then
        if DarkScrollsUI_BossHealthBarInternalState.fadeTarget == 0 then
            ShowBossBar("edit")
            DarkScrollsUI_BossHealthBarInternalState.bossName = "BOSS NAME (EDIT MODE)"
            DarkScrollsUI_BossHealthBarControl.nameLabel:SetText(DarkScrollsUI_BossHealthBarInternalState.bossName)
            DarkScrollsUI_BossHealthBarInternalState.targetPct, DarkScrollsUI_BossHealthBarInternalState.displayPct = 0.65, 0.65
        end
    else
        if DarkScrollsUI_BossHealthBarInternalState.bossName == "BOSS NAME (EDIT MODE)" then
            HideBossBar()
        else
            CheckReticleTarget()
            if DarkScrollsUI_BossHealthBarInternalState.fadeTarget == 1 and DarkScrollsUI_BossHealthBarInternalState.lastBossTag then
                OnBossHealthUpdate(DarkScrollsUI_BossHealthBarInternalState.lastBossTag)
            end
        end
    end

    TickBossBar(dt)
end

-----------------------------------------------------------
-- PUBLIC INITIALIZATION (called from DS_Init.lua)
-----------------------------------------------------------
function DarkScrollsUI.CreateCustomBossBarHealthBar()
    -- Atribuindo à variável de escopo do arquivo para uso em todo o módulo
    DarkScrollsUI_BossHealthBarControl = CreateBossBar()

    local name = BossBarVisualConfiguration.CTRL_NAME
    if DarkScrollsUI.SavedVariables and not DarkScrollsUI.SavedVariables[name] then
        DarkScrollsUI.SavedVariables[name] = {
            l = BossBarVisualConfiguration.DEFAULT_X, t = BossBarVisualConfiguration.DEFAULT_Y,
            w = BossBarVisualConfiguration.DEFAULT_W, h = BossBarVisualConfiguration.DEFAULT_H,
            a = 1, r = 0, fs = 1,
        }
    end

    EVENT_MANAGER:RegisterForEvent(
        DarkScrollsUI.AddonNameIdentifier .. "_BossTarget",
        EVENT_RETICLE_TARGET_CHANGED,
        function() CheckReticleTarget() end
    )

    EVENT_MANAGER:RegisterForEvent(
        DarkScrollsUI.AddonNameIdentifier .. "_BossPower",
        EVENT_POWER_UPDATE,
        function(_, unitTag, _, pType)
            if pType == POWERTYPE_HEALTH then OnBossHealthUpdate(unitTag) end
        end
    )

    -- Ensure SavedVariables entries exist for the independent sub-controls
    local nameName = BossBarVisualConfiguration.CTRL_NAME .. "Name"
    local hpName   = BossBarVisualConfiguration.CTRL_NAME .. "HP"
    if DarkScrollsUI.SavedVariables and not DarkScrollsUI.SavedVariables[nameName] then
        local barS = DarkScrollsUI.SavedVariables[BossBarVisualConfiguration.CTRL_NAME]
        DarkScrollsUI.SavedVariables[nameName] = {
            l  = barS and (barS.l + barS.w / 2 - 200) or (BossBarVisualConfiguration.DEFAULT_X + BossBarVisualConfiguration.DEFAULT_W / 2 - 200),
            t  = barS and (barS.t - 40) or (BossBarVisualConfiguration.DEFAULT_Y - 40),
            w  = 400, h = 36, a = 1, r = 0, fs = 1,
        }
    end
    if DarkScrollsUI.SavedVariables and not DarkScrollsUI.SavedVariables[hpName] then
        local barS = DarkScrollsUI.SavedVariables[BossBarVisualConfiguration.CTRL_NAME]
        DarkScrollsUI.SavedVariables[hpName] = {
            l  = barS and (barS.l - 80) or (BossBarVisualConfiguration.DEFAULT_X - 80),
            t  = barS and (barS.t - 2)  or (BossBarVisualConfiguration.DEFAULT_Y - 2),
            w  = 72, h = 20, a = 1, r = 0, fs = 1,
        }
    end

    UpdateSegments(DarkScrollsUI_BossHealthBarControl)
end

-----------------------------------------------------------
-- Extend GetAllControlNames to include the boss bar
-----------------------------------------------------------
local originalGetAllControlNames = DarkScrollsUI.GetListOfAllControlNames
function DarkScrollsUI.GetListOfAllControlNames()
    local list = originalGetAllControlNames()
    table.insert(list, BossBarVisualConfiguration.CTRL_NAME)
    table.insert(list, BossBarVisualConfiguration.CTRL_NAME .. "Name")
    table.insert(list, BossBarVisualConfiguration.CTRL_NAME .. "HP")
    return list
end
