TetsuCombatHealerHelper = TetsuCombatHealerHelper or {}
local T = TetsuCombatHealerHelper

T.Heads = T.Heads or {}
local H = T.Heads

local UPDATE_NAME = "TetsuCHH_HeadUpdate"
local ARM_NAME = "TetsuCHH_PrayerArm"
local SCAN_NAME = "TetsuCHH_BuffScan"

local coverage = {}
local prayerArmed = false
local hudRoot, hudTitle, hudBg
local hudHeader = {}
local hudRows = {}
local worldPips = {}
local camProbe
local hudAttached = false
local overlayAttached = false
local lastAlertMs = 0

local COL_W = 56
local NAME_W = 170
local ROW_H = 26
local TEX_CIRCLE = "TetsuCombatHealerHelper/textures/circle.dds"
local TEX_SQUARE = "TetsuCombatHealerHelper/textures/square.dds"

local function Now()
    return GetGameTimeMilliseconds()
end

local function Vars()
    return T.savedVars
end

local function InCombat()
    if not IsUnitInCombat then return false end
    local ok, v = pcall(IsUnitInCombat, "player")
    return ok and v and true or false
end

local function CovKey(unitTag)
    if T.StableUnitKey then
        return T.StableUnitKey(unitTag)
    end
    return unitTag
end

local function HasEffect(unitTag, key)
    local bag = coverage[CovKey(unitTag)]
    if not bag then return false end
    local t = bag[key]
    if not t then return false end
    if t == 0 then return true end
    return t > Now()
end

local function SetEffect(unitTag, key, active, endTime)
    local ck = CovKey(unitTag)
    if not ck or not key then return end
    coverage[ck] = coverage[ck] or {}
    if active then
        coverage[ck][key] = endTime or 0
    else
        coverage[ck][key] = nil
    end
end

local function HasPrayer(unitTag)
    if HasEffect(unitTag, "prayer") then return true end
    return HasEffect(unitTag, "minorBerserk") and HasEffect(unitTag, "minorResolve")
end

local function ApplyFont(label, small)
    if not label or not label.SetFont then return end
    local fonts = small and {
        "ZoFontGamepadBold27",
        "ZoFontGamepad27",
        "ZoFontGamepadBold22",
        "ZoFontGamepad22",
        "ZoFontAnnounceMedium",
        "ZoFontWinH3",
        "ZoFontGameBold",
        "ZoFontGame",
    } or {
        "ZoFontGamepadBold34",
        "ZoFontGamepad34",
        "ZoFontGamepadBold27",
        "ZoFontAnnounceLarge",
        "ZoFontWinH2",
        "ZoFontGameBold",
        "ZoFontGame",
    }
    for i = 1, #fonts do
        if pcall(function() label:SetFont(fonts[i]) end) then
            return
        end
    end
end

local function UnitUsable(unitTag)
    if not unitTag then return false end
    if DoesUnitExist and not DoesUnitExist(unitTag) then return false end
    if type(IsUnitDead) == "function" then
        local okDead, dead = pcall(IsUnitDead, unitTag)
        if okDead and dead then return false end
    end
    if T.UnitHere and not T.UnitHere(unitTag) then return false end
    return true
end

local function UnitLabel(unitTag)
    if GetUnitDisplayName then
        local n = GetUnitDisplayName(unitTag)
        if n and n ~= "" then return n end
    end
    if GetUnitName then
        local n = GetUnitName(unitTag)
        if n and n ~= "" then return n end
    end
    return unitTag
end

local function HudKeys()
    local vars = Vars() or {}
    local keys = {}
    for i = 1, 5 do
        local key = vars["hudBuff" .. i] or "off"
        if type(key) ~= "string" then key = "off" end
        keys[i] = key
    end
    return keys
end

local function IsSelf(unitTag)
    if T.IsSelf then return T.IsSelf(unitTag) end
    return unitTag == "player"
end

local function HeadGaps(unitTag)
    local vars = Vars()
    if not vars or vars.enabled == false then
        return false, false, false
    end
    local self = IsSelf(unitTag)
    local combat = InCombat()
    local ihOn = self or combat
    local prOn = vars.prayerEnabled ~= false and (self or prayerArmed)
    local ih = ihOn and (not HasEffect(unitTag, "illustrious"))
    local prayer = prOn and (not HasPrayer(unitTag))
    local extraKey = vars.headExtraKey or "off"
    if type(extraKey) ~= "string" then extraKey = "off" end
    local extra = extraKey ~= "off" and (not HasEffect(unitTag, extraKey))
    return ih, prayer, extra
end

local function AttachHud(control)
    if not control or not SCENE_MANAGER then return false end
    local frag
    if ZO_HUDFadeSceneFragment then
        frag = ZO_HUDFadeSceneFragment:New(control)
    elseif ZO_SimpleSceneFragment then
        frag = ZO_SimpleSceneFragment:New(control)
    end
    if not frag then return end
    for _, name in ipairs({ "hud", "hudui" }) do
        local sc = SCENE_MANAGER:GetScene(name)
        if sc and sc.AddFragment then
            pcall(function()
                sc:AddFragment(frag)
            end)
        end
    end
    return true
end

local function EnsureHud()
    if hudRoot then return hudRoot end
    local wm = WINDOW_MANAGER
    if not wm then return nil end
    local root = wm:CreateTopLevelWindow("TetsuCHH_GapHUD")
    if not root then
        root = wm:CreateControl("TetsuCHH_GapHUD", GuiRoot, CT_TOPLEVELCONTROL)
    end
    if not root then return nil end
    root:SetHidden(false)
    root:SetMouseEnabled(false)
    root:SetDimensions(380, 280)
    root:ClearAnchors()
    root:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -24, 132)
    root:SetDrawTier(DT_HIGH)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawLevel(100)
    if root.SetClampedToScreen then root:SetClampedToScreen(true) end

    hudBg = wm:CreateControl("TetsuCHH_GapHUDBg", root, CT_BACKDROP)
    if hudBg then
        hudBg:SetAnchorFill(root)
        if hudBg.SetCenterColor then hudBg:SetCenterColor(0.04, 0.06, 0.08, 0.78) end
        if hudBg.SetEdgeColor then hudBg:SetEdgeColor(0.22, 0.72, 0.48, 0.85) end
    end

    local accent = wm:CreateControl("TetsuCHH_GapHUDAccent", root, CT_TEXTURE)
    if accent then
        accent:SetAnchor(TOPLEFT, root, TOPLEFT, 1, 1)
        accent:SetAnchor(TOPRIGHT, root, TOPRIGHT, -1, 1)
        accent:SetHeight(3)
        accent:SetColor(0.25, 0.85, 0.52, 0.95)
        accent:SetTexture(TEX_SQUARE)
    end

    hudTitle = wm:CreateControl("TetsuCHH_GapHUDTitle", root, CT_LABEL)
    hudTitle:SetAnchor(TOPLEFT, root, TOPLEFT, 10, 8)
    hudTitle:SetDimensions(400, 28)
    hudTitle:SetColor(0.45, 0.95, 0.68, 1)
    ApplyFont(hudTitle, false)
    hudTitle:SetText("Healer Helper")

    for i = 1, 5 do
        local lab = wm:CreateControl("TetsuCHH_HudH" .. i, root, CT_LABEL)
        lab:SetDimensions(COL_W, 24)
        lab:SetColor(0.70, 0.86, 0.74, 1)
        ApplyFont(lab, true)
        if lab.SetHorizontalAlignment and TEXT_ALIGN_CENTER then
            lab:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        end
        hudHeader[i] = lab
    end

    hudRoot = root
    if not hudAttached then
        hudAttached = AttachHud(root) and true or false
    end
    return root
end

local function EnsureRow(i)
    if hudRows[i] then return hudRows[i] end
    local root = EnsureHud()
    if not root then return nil end
    local wm = WINDOW_MANAGER
    local row = wm:CreateControl("TetsuCHH_GapRow" .. i, root, CT_CONTROL)
    row:SetDimensions(340, ROW_H)
    local name = wm:CreateControl(row:GetName() .. "N", row, CT_LABEL)
    ApplyFont(name, true)
    name:SetDimensions(NAME_W, ROW_H)
    name:SetAnchor(LEFT, row, LEFT, 8, 0)
    name:SetColor(0.93, 0.95, 0.90, 1)
    local dots = {}
    for c = 1, 5 do
        local wrap = wm:CreateControl(row:GetName() .. "W" .. c, row, CT_CONTROL)
        wrap:SetDimensions(18, 18)
        local ring = wm:CreateControl(wrap:GetName() .. "R", wrap, CT_TEXTURE)
        ring:SetAnchor(CENTER, wrap, CENTER, 0, 0)
        ring:SetDimensions(16, 16)
        ring:SetTexture(TEX_CIRCLE)
        ring:SetColor(0.35, 0.42, 0.38, 0.35)
        local fill = wm:CreateControl(wrap:GetName() .. "F", wrap, CT_TEXTURE)
        fill:SetAnchor(CENTER, wrap, CENTER, 0, 0)
        fill:SetDimensions(12, 12)
        fill:SetTexture(TEX_CIRCLE)
        fill:SetColor(0.28, 0.92, 0.48, 1)
        fill:SetHidden(true)
        dots[c] = { wrap = wrap, ring = ring, fill = fill }
    end
    hudRows[i] = { row = row, name = name, dots = dots }
    return hudRows[i]
end

local function EnsureCamProbe()
    if camProbe then return camProbe end
    if not WINDOW_MANAGER then return nil end
    local p = WINDOW_MANAGER:CreateControl("TetsuCHH_HeadCam", GuiRoot, CT_CONTROL)
    if not p or not p.Create3DRenderSpace then return nil end
    p:Create3DRenderSpace()
    camProbe = p
    return p
end

local function ProjectRenderToScreen(rx, ry, rz)
    local probe = EnsureCamProbe()
    if not probe then return nil end
    if Set3DRenderSpaceToCurrentCamera then
        pcall(Set3DRenderSpaceToCurrentCamera, probe:GetName())
    end
    if not probe.Get3DRenderSpaceOrigin then return nil end
    local ox, oy, oz = probe:Get3DRenderSpaceOrigin()
    local fx, fy, fz = probe:Get3DRenderSpaceForward()
    local rxv, ryv, rzv = probe:Get3DRenderSpaceRight()
    local ux, uy, uz = probe:Get3DRenderSpaceUp()
    if not ox or not fx or not rxv or not ux then return nil end
    if type(rx) ~= "number" or type(ry) ~= "number" or type(rz) ~= "number" then
        return nil
    end
    if type(ox) ~= "number" or type(oy) ~= "number" or type(oz) ~= "number" then
        return nil
    end
    local dx, dy, dz = rx - ox, ry - oy, rz - oz
    local Z = fx * dx + fy * dy + fz * dz
    if Z < 0.15 then return nil end
    local X = rxv * dx + ryv * dy + rzv * dz
    local Y = ux * dx + uy * dy + uz * dz
    local fw, fh
    if GetWorldDimensionsOfViewFrustumAtDepth then
        local ok, w, h = pcall(GetWorldDimensionsOfViewFrustumAtDepth, Z)
        if ok and type(w) == "number" and type(h) == "number" and w > 0 and h > 0 then
            fw, fh = w, h
        end
    end
    if not fw or not fh or fw == 0 or fh == 0 then
        fw, fh = Z * 1.6, Z * 0.9
    end
    local guiW, guiH = GuiRoot:GetDimensions()
    local sx = guiW * 0.5 + X * (guiW / fw)
    local sy = guiH * 0.5 - Y * (guiH / fh)
    if sx < -50 or sy < -50 or sx > guiW + 50 or sy > guiH + 50 then
        return nil
    end
    return sx, sy
end

local overlayRoot

local function EnsureOverlay()
    if overlayRoot then return overlayRoot end
    local wm = WINDOW_MANAGER
    if not wm then return nil end
    local root = wm:CreateTopLevelWindow("TetsuCHH_WorldOverlay")
    if not root then
        root = wm:CreateControl("TetsuCHH_WorldOverlay", GuiRoot, CT_TOPLEVELCONTROL)
    end
    if not root then return nil end
    root:SetMouseEnabled(false)
    root:SetHidden(false)
    root:SetAnchorFill(GuiRoot)
    root:SetDrawTier(DT_HIGH)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawLevel(90)
    overlayRoot = root
    if not overlayAttached then
        AttachHud(root)
        overlayAttached = true
    end
    return root
end

local function EnsureWorldPips(unitTag)
    if worldPips[unitTag] then return worldPips[unitTag] end
    local wm = WINDOW_MANAGER
    local parent = EnsureOverlay() or GuiRoot
    if not wm or not parent then return nil end
    local function Make2D(name, tex, rot)
        local c = wm:CreateControl(name, GuiRoot, CT_TEXTURE)
        c:SetHidden(true)
        c:SetMouseEnabled(false)
        if c.SetDrawTier then c:SetDrawTier(DT_HIGH) end
        if c.SetDrawLayer then c:SetDrawLayer(DL_OVERLAY) end
        c:SetDrawLevel(200)
        c:SetDimensions(48, 48)
        c:SetTexture(tex)
        if rot and c.SetTextureRotation then c:SetTextureRotation(rot) end
        return c
    end
    local function Make3D(name, tex, rot)
        local c = wm:CreateControl(name .. "3D", GuiRoot, CT_TEXTURE)
        c:SetHidden(true)
        c:SetMouseEnabled(false)
        c:SetTexture(tex)
        if rot and c.SetTextureRotation then c:SetTextureRotation(rot) end
        if c.Create3DRenderSpace then
            c:Create3DRenderSpace()
            if GUI_RENDER_3D_SPACE_SYSTEM_WORLD and c.Set3DRenderSpaceSystem then
                c:Set3DRenderSpaceSystem(GUI_RENDER_3D_SPACE_SYSTEM_WORLD)
            end
            if c.Set3DRenderSpaceUsesDepthBuffer then
                c:Set3DRenderSpaceUsesDepthBuffer(false)
            end
            if c.Set3DLocalDimensions then
                c:Set3DLocalDimensions(1.2, 1.2)
            end
        end
        return c
    end
    worldPips[unitTag] = {
        ih = Make2D("TetsuCHH_WIH_" .. unitTag, "EsoUI/Art/TargetMarkers/Gamepad/Target_Green_Circle.dds"),
        prayer = Make2D("TetsuCHH_WP_" .. unitTag, "EsoUI/Art/TargetMarkers/Gamepad/Target_Gold_Star.dds"),
        extra = Make2D("TetsuCHH_WE_" .. unitTag, "EsoUI/Art/TargetMarkers/Gamepad/Target_Orange_Triangle.dds"),
        ih3 = Make3D("TetsuCHH_WIH_" .. unitTag, "TetsuCombatHealerHelper/textures/circle.dds"),
        pr3 = Make3D("TetsuCHH_WP_" .. unitTag, "TetsuCombatHealerHelper/textures/square.dds", math.pi / 4),
        ex3 = Make3D("TetsuCHH_WE_" .. unitTag, "TetsuCombatHealerHelper/textures/square.dds"),
    }
    return worldPips[unitTag]
end

local function HideWorldPips(pack)
    if not pack then return end
    for _, key in ipairs({ "ih", "prayer", "extra", "ih3", "pr3", "ex3" }) do
        if pack[key] then pack[key]:SetHidden(true) end
    end
end

local function Place3D(pip, on, col, rx, ry, rz, xOff, sizeM)
    if not pip then return end
    if not on or not pip.Set3DRenderSpaceOrigin then
        pip:SetHidden(true)
        return
    end
    pip:SetColor(col.r or 1, col.g or 1, col.b or 1, 1)
    if pip.Set3DLocalDimensions then
        pip:Set3DLocalDimensions(sizeM, sizeM)
    end
    local height = (Vars() and Vars().headHeight) or 2.15
    pip:Set3DRenderSpaceOrigin(rx + (xOff or 0), ry + height, rz)
    if pip.Set3DRenderSpaceOrientation and GetPlayerCameraHeading then
        pip:Set3DRenderSpaceOrientation(0, GetPlayerCameraHeading() or 0, 0)
    end
    pip:SetHidden(false)
end

local function ResolveRenderPos(wx, wy, wz)
    local rx, ry, rz = T.WorldToRender and T.WorldToRender(wx, wy, wz) or nil
    if rx then
        return rx, ry, rz
    end
    -- Overland fallback used by OSI-style addons when the converter is quiet.
    return wx / 100, wy / 100, wz / 100
end

local function ScreenGuessForPlayer()
    -- Default third-person: character sits near screen center, head a bit above mid.
    -- This is the same visual slot Deadmarker's gold star occupies on the screenshot.
    local guiW, guiH = GuiRoot:GetDimensions()
    if not guiW or guiW == 0 then
        guiW, guiH = 1920, 1080
    end
    return guiW * 0.50, guiH * 0.48
end

local function PlaceWorldPack(unitTag, showIH, showP, showE, cols, size)
    local pack = EnsureWorldPips(unitTag)
    if not pack then return end
    HideWorldPips(pack)
    if not (showIH or showP or showE) then
        return
    end

    local vars = Vars() or {}
    local height = vars.headHeight or 2.15
    size = size or 48
    if size < 32 then size = 32 end

    local sx, sy
    if T.IsSelf(unitTag) then
        -- Projection has been silent on this console. Pin self where Deadmarker's
        -- engine star sits in third person so the icons are actually visible.
        sx, sy = ScreenGuessForPlayer()
    else
        local wx, wy, wz = T.GetUnitRaw(unitTag)
        if not wx then return end
        local rx, ry, rz = ResolveRenderPos(wx, wy, wz)
        sx, sy = ProjectRenderToScreen(rx, ry + height, rz)
        if not sx then return end
    end

    local function put2d(pip, on, x)
        if not pip then return end
        if not on then
            pip:SetHidden(true)
            return
        end
        pip:SetHidden(false)
        pip:SetDimensions(size, size)
        pip:SetColor(1, 1, 1, 1)
        pip:ClearAnchors()
        pip:SetAnchor(CENTER, GuiRoot, TOPLEFT, x, sy)
    end
    put2d(pack.ih, showIH, sx - (size + 8))
    put2d(pack.prayer, showP, sx)
    put2d(pack.extra, showE, sx + (size + 8))
end

function H.OnEffectChanged(_, changeType, _slot, effectName, unitTag, beginTime, endTime, _stacks, _icon, _buffType, _effectType, _abilityType, _status, _unitName, _unitId, abilityId, _sourceType)
    if not unitTag or unitTag == "" then return end
    local key = T.LookupKeyForAbilityId(abilityId, effectName)
    if not key then return end
    local gained = (changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED)
    if EFFECT_RESULT_FULL_REFRESH and changeType == EFFECT_RESULT_FULL_REFRESH then
        gained = true
    end
    if gained then
        local endMs = 0
        if endTime and endTime > 0 then
            endMs = math.floor(endTime * 1000)
        end
        SetEffect(unitTag, key, true, endMs)
        if key == "prayer" or ((key == "minorBerserk" or key == "minorResolve") and HasPrayer(unitTag)) then
            prayerArmed = true
            EVENT_MANAGER:UnregisterForUpdate(ARM_NAME)
        end
    elseif changeType == EFFECT_RESULT_FADED then
        SetEffect(unitTag, key, false)
    end
end

function H.OnCombatState(_, inCombat)
    EVENT_MANAGER:UnregisterForUpdate(ARM_NAME)
    if inCombat then
        prayerArmed = false
        EVENT_MANAGER:RegisterForUpdate(ARM_NAME, T.PRAYER_ARM_DELAY_MS or 4000, function()
            EVENT_MANAGER:UnregisterForUpdate(ARM_NAME)
            prayerArmed = true
        end)
    else
        prayerArmed = false
        coverage = {}
    end
end

function H.RefreshAll()
    local vars = Vars()
    local root = EnsureHud()
    if root then
        root:SetHidden(false)
        if not hudAttached then hudAttached = AttachHud(root) and true or false end
    end
    if not vars or vars.enabled == false then
        if root then root:SetHidden(true) end
        for _, pack in pairs(worldPips) do HideWorldPips(pack) end
        return
    end

    local keys = HudKeys()
    local n = GetGroupSize and GetGroupSize() or 0
    if hudTitle then
        hudTitle:SetText(string.format("Healer Helper   %d  ·  %s", n > 0 and n or 1, InCombat() and "IN COMBAT" or "out of combat"))
    end

    local tags = {}
    if T.EachGroupTag then
        T.EachGroupTag(function(tag)
            tags[#tags + 1] = tag
        end)
    else
        tags[1] = "player"
    end

    local ox = vars.hudOffsetX or 0
    local oy = vars.hudOffsetY or 0
    local scale = vars.hudScale or 1
    if scale < 0.7 then scale = 0.7 end
    if scale > 1.4 then scale = 1.4 end
    if root then
        root:ClearAnchors()
        root:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -24 + ox, 132 + oy)
        if root.SetScale then
            pcall(function() root:SetScale(scale) end)
        end
    end

    local hudOn = vars.hudList ~= false
    if hudOn and root then
        root:SetHidden(false)
        local x0 = NAME_W + 14
        for c = 1, 5 do
            local lab = hudHeader[c]
            if lab then
                local key = keys[c]
                lab:ClearAnchors()
                lab:SetAnchor(TOPLEFT, root, TOPLEFT, x0 + (c - 1) * COL_W, 38)
                if key == "off" then
                    lab:SetText("")
                else
                    lab:SetText(T.SlotShort and T.SlotShort(key) or zo_strsub(T.SlotLabel(key) or key, 1, 4))
                end
            end
        end
        local rowI = 0
        for i = 1, #tags do
            if UnitUsable(tags[i]) then
                rowI = rowI + 1
                local r = EnsureRow(rowI)
                if r then
                    r.row:ClearAnchors()
                    r.row:SetAnchor(TOPLEFT, root, TOPLEFT, 4, 64 + (rowI - 1) * ROW_H)
                    local label = UnitLabel(tags[i]) or ""
                    if zo_strlen(label) > 18 then
                        label = zo_strsub(label, 1, 17) .. "…"
                    end
                    r.name:SetText(label)
                    if IsSelf(tags[i]) then
                        r.name:SetColor(0.55, 0.95, 0.75, 1)
                    else
                        r.name:SetColor(0.93, 0.95, 0.90, 1)
                    end
                    for c = 1, 5 do
                        local key = keys[c]
                        local d = r.dots[c]
                        d.wrap:ClearAnchors()
                        d.wrap:SetAnchor(LEFT, r.row, LEFT, x0 + (c - 1) * COL_W + 10, 0)
                        if key == "off" then
                            d.ring:SetHidden(true)
                            d.fill:SetHidden(true)
                        else
                            d.ring:SetHidden(false)
                            local has = HasEffect(tags[i], key)
                            if key == "prayer" then
                                has = HasPrayer(tags[i])
                            end
                            d.fill:SetHidden(not has)
                            if has then
                                d.ring:SetColor(0.20, 0.55, 0.32, 0.55)
                            else
                                d.ring:SetColor(0.38, 0.42, 0.40, 0.32)
                            end
                        end
                    end
                    r.row:SetHidden(false)
                end
            end
        end
        for i = rowI + 1, #hudRows do
            hudRows[i].row:SetHidden(true)
        end
        root:SetDimensions(NAME_W + 24 + 5 * COL_W, math.max(90, 70 + rowI * ROW_H + 8))
    elseif root then
        root:SetHidden(true)
    end

    local cols = {
        ih = vars.ihColor or { r = 0.25, g = 0.95, b = 0.45, a = 1 },
        prayer = vars.prayerColor or { r = 1, g = 0.2, b = 0.2, a = 1 },
        extra = vars.headExtraColor or { r = 1, g = 0.45, b = 0.15, a = 1 },
    }
    local size = vars.iconSize or 40
    if size < 32 then size = 32 end
    local worldOn = vars.worldPips ~= false
    for i = 1, #tags do
        local tag = tags[i]
        if worldOn and UnitUsable(tag) then
            local ih, pr, ex = HeadGaps(tag)
            if ih or pr or ex then
                pcall(PlaceWorldPack, tag, ih, pr, ex, cols, size)
            else
                HideWorldPips(worldPips[tag])
            end
        else
            HideWorldPips(worldPips[tag])
        end
    end
end

local function ScanUnitBuffs(unitTag)
    if type(GetNumBuffs) ~= "function" or type(GetUnitBuffInfo) ~= "function" then
        return
    end
    local okN, n = pcall(GetNumBuffs, unitTag)
    if not okN or not n or n < 1 then return end
    for i = 1, n do
        local ok, buffName, _s, timeEnding, _slot, _stacks, _icon, _bt, _et, _at, _st, abilityId =
            pcall(GetUnitBuffInfo, unitTag, i)
        if ok then
            local mapped = T.LookupKeyForAbilityId(abilityId, buffName)
            if mapped then
                local endMs = 0
                if timeEnding and timeEnding > 0 then
                    endMs = math.floor(timeEnding * 1000)
                end
                SetEffect(unitTag, mapped, true, endMs)
            end
        end
    end
end

function H.ScanGroupBuffs()
    if T.EachGroupTag then
        T.EachGroupTag(function(tag)
            pcall(ScanUnitBuffs, tag)
        end)
    else
        pcall(ScanUnitBuffs, "player")
    end
end

function H.Start()
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
    EVENT_MANAGER:UnregisterForUpdate(SCAN_NAME)
    EnsureHud()
    EnsureOverlay()
    H.ScanGroupBuffs()
    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, 80, function()
        local ok, err = pcall(H.RefreshAll)
        if not ok and ZO_Alert and Now() - lastAlertMs > 15000 then
            lastAlertMs = Now()
            pcall(ZO_Alert, UI_ALERT_CATEGORY_ERROR, nil, tostring(err))
        end
    end)
    EVENT_MANAGER:RegisterForUpdate(SCAN_NAME, 1500, function()
        pcall(H.ScanGroupBuffs)
    end)
    H.RefreshAll()
end

function H.Stop()
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
    EVENT_MANAGER:UnregisterForUpdate(ARM_NAME)
    EVENT_MANAGER:UnregisterForUpdate(SCAN_NAME)
    if hudRoot then hudRoot:SetHidden(true) end
    for _, pack in pairs(worldPips) do HideWorldPips(pack) end
end
