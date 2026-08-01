-----------------------------------------------------------
-- DarkScrollsUI - DS_TargetBar.lua
-- Custom target health bar and name label for the current
-- reticle-over target. Replaces ZO_TargetUnitFramereticleover
-- with two fully independent, repositionable controls:
--   DarkScrollsUI_TargetHealthBar  – the fill bar
--   DarkScrollsUI_TargetNameLabel  – the name text
-----------------------------------------------------------

DarkScrollsUI = DarkScrollsUI or {}

-----------------------------------------------------------
-- VISUAL CONFIGURATION
-----------------------------------------------------------
local TargetBarConfig = {
    DEFAULT_BAR_L  = 590,
    DEFAULT_BAR_T  = 950,
    DEFAULT_BAR_W  = 400,
    DEFAULT_BAR_H  = 8,

    DEFAULT_NAME_L = 590,
    DEFAULT_NAME_T = 870,
    DEFAULT_NAME_W = 400,
    DEFAULT_NAME_H = 80,

    APPEAR_TIME     = 0.35,
    DISAPPEAR_TIME  = 0.6,

    DRAIN_LINGER_MS = 500,
    FILL_SPEED      = 0.8,

    TEX_DIRTY  = "DarkScrollsUI/Images/bar_dirty.dds",
    TEX_EDGE   = "DarkScrollsUI/Images/bar_edge.dds",
    EDGE_WIDTH = 10,

    BG_COLOR     = {0.06, 0.06, 0.06, 0.95},
    BORDER_COLOR = {0.45, 0.45, 0.45, 1},
    DRAIN_COLOR  = {0.85, 0.45, 0.05, 0.85},
    DIRTY_ALPHA  = 0.50,
    DIRTY_SCROLL = 0.05,

    -- Colour interpolation: full HP = green tint, low HP = red
    COLOR_FULL   = {0.55, 0.10, 0.10, 1},   -- dark red (high HP end)
    COLOR_LOW    = {0.60, 0.05, 0.05, 1},   -- vivid red (low HP end)
    COLOR_BRIGHT = {0.75, 0.20, 0.20, 1},   -- top-half bright
}

-----------------------------------------------------------
-- STATE
-----------------------------------------------------------
local TB = {
    bar         = nil,   -- DarkScrollsUI_TargetHealthBar control
    nameCtrl    = nil,   -- DarkScrollsUI_TargetNameLabel control
    displayPct  = 0,
    targetPct   = 0,
    drainPct    = 0,
    drainTimer  = 0,
    dirtyUV     = 0,
    lastW       = 0,
    lastH       = 0,
    isVisible   = nil,
    fadeAlpha   = 0,
    fadeTarget  = 0,
    cachedFullName = "",
    cachedColor    = {0.92, 0.86, 0.72, 1},
    isLocked       = false,
}

-----------------------------------------------------------
-- HELPERS
-----------------------------------------------------------
local function GetTargetHealthPct()
    if not DoesUnitExist("reticleover") then return nil end
    if IsUnitPlayer("reticleover") then
        local cur, _, max = GetUnitPower("reticleover", POWERTYPE_HEALTH)
        if not max or max == 0 then return nil end
        return zo_clamp(cur / max, 0, 1), GetUnitName("reticleover"), true
    else
        local cur, _, max = GetUnitPower("reticleover", POWERTYPE_HEALTH)
        if not max or max == 0 then return nil end
        return zo_clamp(cur / max, 0, 1), GetUnitName("reticleover"), false
    end
end

local function SetBarVisible(visible)
    if TB.fadeTarget == (visible and 1 or 0) then return end
    TB.fadeTarget = visible and 1 or 0
    TB.isVisible  = visible

    if visible then
        if TB.bar     then TB.bar:SetHidden(false)     end
        if TB.nameCtrl then TB.nameCtrl:SetHidden(false) end
    else
        if TB.fadeAlpha <= 0 then
            if TB.bar     then TB.bar:SetHidden(true)     end
            if TB.nameCtrl then TB.nameCtrl:SetHidden(true) end
        end
    end
end

-----------------------------------------------------------
-- PER-FRAME TICK  (called from DarkScrollsUI.TickAllAttributeBars)
-----------------------------------------------------------
function DarkScrollsUI.TickTargetBar(dt)
    local bar = TB.bar
    if not bar then return end

    local isEditing = not DarkScrollsUI.isInterfaceLocked or DarkScrollsUI.isGlobalEditModeActive
    
    -- Sincroniza o estado de lock com a API apenas se necessário, 
    -- mas mantemos o estado TB.isLocked como prioritário.
    if IsGameCameraUnitTargetLockOnActive then
        TB.isLocked = IsGameCameraUnitTargetLockOnActive()
    end
    
    local isLocked = TB.isLocked

    local currentPct, currentName = GetTargetHealthPct()

    -- Detectar se o alvo atual (mira ou trava) é um Boss
    local targetIsBoss = false
    if not isEditing and DarkScrollsUI.IsBossUnit then
        if isLocked then
            if DoesUnitExist("reticleover") and IsUnitTargetLockOn("reticleover") then
                targetIsBoss = DarkScrollsUI.IsBossUnit("reticleover")
            else
                for i = 1, 6 do
                    if DoesUnitExist("boss"..i) and IsUnitTargetLockOn("boss"..i) then
                        targetIsBoss = true
                        break
                    end
                end
            end
        else
            targetIsBoss = DarkScrollsUI.IsBossUnit("reticleover")
        end
    end

    if isEditing then
        -- Show a fake target in edit mode so the user can position both controls
        SetBarVisible(true)
        TB.targetPct  = 0.72
        TB.displayPct = 0.72
        TB.drainPct   = 0.72
        if TB.nameCtrl and TB.nameCtrl.nameLabel then
            TB.nameCtrl.nameLabel:SetText("TARGET NAME")
        end
    elseif targetIsBoss then
        -- Se for Boss, ocultamos a barra de alvo normal para não poluir a UI
        SetBarVisible(false)
    elseif isLocked then
        -- Se houver lock ativo, priorizamos os dados do alvo travado
        SetBarVisible(true)

        if TB.nameCtrl and TB.nameCtrl.nameLabel then
            local displayName = (TB.cachedFullName and TB.cachedFullName ~= "") and TB.cachedFullName or "LOCKED TARGET"
            TB.nameCtrl.nameLabel:SetText(displayName)
            if TB.cachedColor then
                TB.nameCtrl.nameLabel:SetColor(unpack(TB.cachedColor))
            end
        end

        -- Tenta atualizar o HP do alvo travado
        local foundHP = false
        if currentPct ~= nil and IsUnitTargetLockOn("reticleover") then
            TB.targetPct = currentPct
            foundHP = true
        end
        
        if not foundHP then
            for i = 1, 6 do
                local tag = "boss"..i
                if DoesUnitExist(tag) and IsUnitTargetLockOn(tag) then
                    local cur, _, max = GetUnitPower(tag, POWERTYPE_HEALTH)
                    if max and max > 0 then TB.targetPct = zo_clamp(cur / max, 0, 1) end
                    break
                end
            end
        end
    else
        if currentPct ~= nil then
            SetBarVisible(true)
            if TB.nameCtrl and TB.nameCtrl.nameLabel then
                TB.nameCtrl.nameLabel:SetText((TB.cachedFullName and TB.cachedFullName ~= "") and TB.cachedFullName or currentName or "")
                if TB.cachedColor then
                    TB.nameCtrl.nameLabel:SetColor(unpack(TB.cachedColor))
                end
            end
            TB.targetPct = currentPct
        else
            SetBarVisible(false)
            TB.targetPct = TB.displayPct -- Congela o valor da barra ao perder o alvo para evitar que ela "esvazie" durante o fade
        end
    end

    -- Animação de Fade (Opacidade)
    if TB.fadeAlpha ~= TB.fadeTarget then
        local fadeSpeed = (TB.fadeTarget > TB.fadeAlpha)
            and (1 / TargetBarConfig.APPEAR_TIME)
            or  (1 / TargetBarConfig.DISAPPEAR_TIME)
        local delta = fadeSpeed * dt * (TB.fadeTarget > TB.fadeAlpha and 1 or -1)
        TB.fadeAlpha = math.max(0, math.min(1, TB.fadeAlpha + delta))

        if TB.fadeAlpha <= 0 and TB.fadeTarget == 0 then
            if TB.bar     then TB.bar:SetHidden(true)     end
            if TB.nameCtrl then TB.nameCtrl:SetHidden(true) end
        end
    end

    -- Apply Alpha before early return to ensure visibility matches fadeAlpha
    local barSV  = DarkScrollsUI.SavedVariables and DarkScrollsUI.SavedVariables["DarkScrollsUI_TargetHealthBar"]
    local nameSV = DarkScrollsUI.SavedVariables and DarkScrollsUI.SavedVariables["DarkScrollsUI_TargetNameLabel"]
    
    if bar then
        bar:SetAlpha((barSV and barSV.a or 1) * TB.fadeAlpha)
    end
    if TB.nameCtrl then
        TB.nameCtrl:SetAlpha((nameSV and nameSV.a or 1) * TB.fadeAlpha)
    end

    if TB.fadeAlpha <= 0 and not isEditing then 
        -- Ensure controls stay hidden if fade is 0 and we are not editing
        if TB.fadeTarget == 0 then
            if bar and not bar:IsHidden() then bar:SetHidden(true) end
            if TB.nameCtrl and not TB.nameCtrl:IsHidden() then TB.nameCtrl:SetHidden(true) end
        end
        return 
    end

    -- Sem animação: atualiza a porcentagem visual instantaneamente
    TB.displayPct = TB.targetPct

    local barW = bar:GetWidth()
    local barH = bar:GetHeight()

    -- Resize sub-controls when dimensions change
    if TB.lastW ~= barW or TB.lastH ~= barH then
        TB.lastW = barW
        TB.lastH = barH
        bar.fillMain:SetHeight(barH)
        bar.fillTop:SetDimensions(barW, barH / 2)
        bar.fillBottom:SetDimensions(barW, barH / 2)
        bar.fillDrain:SetHeight(barH)
        bar.fillEdge:SetHeight(barH)
        bar.fillEdgeLeft:SetHeight(barH)
    end

    local fillW = math.max(0, TB.displayPct * barW)
    bar.fillMain:SetWidth(fillW)
    bar.fillTop:SetWidth(fillW)
    bar.fillBottom:SetWidth(fillW)

    -- Ensure orange drain trail remains hidden
    TB.drainPct = TB.displayPct
    bar.fillDrain:SetHidden(true)

    -- Edge tips (one for each side)
    if fillW > TargetBarConfig.EDGE_WIDTH * 2 then
        bar.fillEdge:SetWidth(TargetBarConfig.EDGE_WIDTH)
        bar.fillEdge:ClearAnchors()
        bar.fillEdge:SetAnchor(RIGHT, bar.fillMain, RIGHT, 0, 0)
        bar.fillEdge:SetHidden(false)

        bar.fillEdgeLeft:SetWidth(TargetBarConfig.EDGE_WIDTH)
        bar.fillEdgeLeft:ClearAnchors()
        bar.fillEdgeLeft:SetAnchor(LEFT, bar.fillMain, LEFT, 0, 0)
        bar.fillEdgeLeft:SetHidden(false)
    else
        bar.fillEdge:SetHidden(true)
        bar.fillEdgeLeft:SetHidden(true)
    end

    -- Dirty UV scroll
    TB.dirtyUV = (TB.dirtyUV + TargetBarConfig.DIRTY_SCROLL * dt) % 1.0
    bar.fillDirty:SetTextureCoords(TB.dirtyUV, TB.dirtyUV + 1.0, 0, 1)
end

-----------------------------------------------------------
-- CREATION
-----------------------------------------------------------
local function CreateTargetBar()
    local wm  = WINDOW_MANAGER
    local sv  = DarkScrollsUI.SavedVariables
    local cfg = TargetBarConfig

    ------- Health Bar -------
    local barName = "DarkScrollsUI_TargetHealthBar"
    local barS    = (sv and sv[barName]) or { l = cfg.DEFAULT_BAR_L, t = cfg.DEFAULT_BAR_T, w = cfg.DEFAULT_BAR_W, h = cfg.DEFAULT_BAR_H, a = 1, r = 0, fs = 1 }
    if sv and not sv[barName] then sv[barName] = barS end

    local bar = wm:CreateControl(barName, GuiRoot, CT_TOPLEVELCONTROL)
    bar:SetDrawLayer(DL_BACKGROUND)
    bar:SetDrawTier(DT_HIGH)
    bar:SetClampedToScreen(true)
    bar:SetMouseEnabled(not DarkScrollsUI.isInterfaceLocked)
    bar:SetMovable(not DarkScrollsUI.isInterfaceLocked)
    bar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, barS.l, barS.t)
    bar:SetDimensions(barS.w, barS.h)
    bar:SetAlpha(0)
    bar:SetHidden(true)

    bar.bg = wm:CreateControl(barName .. "BG", bar, CT_BACKDROP)
    bar.bg:SetAnchorFill()
    bar.bg:SetCenterColor(unpack(cfg.BG_COLOR))
    bar.bg:SetEdgeColor(unpack(cfg.BORDER_COLOR))
    bar.bg:SetEdgeTexture("", 1, 2, 1)

    bar.fillDrain = wm:CreateControl(barName .. "Drain", bar, CT_TEXTURE)
    bar.fillDrain:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, 0)
    bar.fillDrain:SetHeight(barS.h)
    bar.fillDrain:SetColor(unpack(cfg.DRAIN_COLOR))
    bar.fillDrain:SetDrawLayer(DL_BACKGROUND)
    bar.fillDrain:SetHidden(true)

    bar.fillMain = wm:CreateControl(barName .. "FillMain", bar, CT_CONTROL)
    bar.fillMain:SetAnchor(CENTER, bar, CENTER, 0, 0)
    bar.fillMain:SetDimensions(barS.w, barS.h)

    bar.fillBottom = wm:CreateControl(barName .. "FillBot", bar.fillMain, CT_BACKDROP)
    bar.fillBottom:SetAnchor(BOTTOMLEFT, bar.fillMain, BOTTOMLEFT, 0, 0)
    bar.fillBottom:SetCenterColor(unpack(cfg.COLOR_FULL))
    bar.fillBottom:SetEdgeColor(0, 0, 0, 0)
    bar.fillBottom:SetDimensions(barS.w, barS.h / 2)

    bar.fillTop = wm:CreateControl(barName .. "FillTop", bar.fillMain, CT_BACKDROP)
    bar.fillTop:SetAnchor(TOPLEFT, bar.fillMain, TOPLEFT, 0, 0)
    bar.fillTop:SetCenterColor(unpack(cfg.COLOR_BRIGHT))
    bar.fillTop:SetEdgeColor(0, 0, 0, 0)
    bar.fillTop:SetDimensions(barS.w, barS.h / 2)

    bar.fillEdge = wm:CreateControl(barName .. "Edge", bar, CT_TEXTURE)
    bar.fillEdge:SetTexture(cfg.TEX_EDGE)
    bar.fillEdge:SetHeight(barS.h)
    bar.fillEdge:SetHidden(true)
    bar.fillEdge:SetDrawTier(DT_HIGH)

    bar.fillEdgeLeft = wm:CreateControl(barName .. "EdgeLeft", bar, CT_TEXTURE)
    bar.fillEdgeLeft:SetTexture(cfg.TEX_EDGE)
    bar.fillEdgeLeft:SetTextureCoords(1, 0, 0, 1) -- Inverte horizontalmente
    bar.fillEdgeLeft:SetHeight(barS.h)
    bar.fillEdgeLeft:SetHidden(true)
    bar.fillEdgeLeft:SetDrawTier(DT_HIGH)

    bar.fillDirty = wm:CreateControl(barName .. "Dirty", bar.fillMain, CT_TEXTURE)
    bar.fillDirty:SetAnchorFill()
    bar.fillDirty:SetTexture(cfg.TEX_DIRTY)
    bar.fillDirty:SetAddressMode(TEX_MODE_WRAP)
    bar.fillDirty:SetAlpha(cfg.DIRTY_ALPHA)

    -- Mark as a bar so OnMouseWheel resize works correctly (fillTop/fillBottom present)
    -- SetupCommonInterfaceHandlers gives OnMoveStop + OnMouseWheel
    DarkScrollsUI.SetupCommonInterfaceHandlers(bar)

    TB.bar   = bar
    TB.lastW = barS.w
    TB.lastH = barS.h

    ------- Name Label -------
    local nameName = "DarkScrollsUI_TargetNameLabel"
    local nameS    = (sv and sv[nameName]) or { l = cfg.DEFAULT_NAME_L, t = cfg.DEFAULT_NAME_T, w = cfg.DEFAULT_NAME_W, h = cfg.DEFAULT_NAME_H, a = 1, r = 0, fs = 1 }
    if sv and not sv[nameName] then sv[nameName] = nameS end

    local nameCtrl = wm:CreateControl(nameName, bar, CT_CONTROL)
    nameCtrl:SetDrawLayer(DL_BACKGROUND)
    nameCtrl:SetDrawTier(DT_HIGH)
    nameCtrl:SetClampedToScreen(true)
    nameCtrl:SetMouseEnabled(false)
    nameCtrl:SetMovable(false)
    nameCtrl:SetAnchor(BOTTOMLEFT, bar, TOPLEFT, 0, 0)
    nameCtrl:SetAnchor(BOTTOMRIGHT, bar, TOPRIGHT, 0, 0)
    nameCtrl:SetDimensions(nameS.w, nameS.h)
    nameCtrl:SetAlpha(0)
    nameCtrl:SetHidden(true)

    nameCtrl.bg = wm:CreateControl(nameName .. "BG", nameCtrl, CT_BACKDROP)
    nameCtrl.bg:SetAnchorFill()
    nameCtrl.bg:SetCenterColor(0, 0, 0, DarkScrollsUI.isInterfaceLocked and 0 or 0)
    nameCtrl.bg:SetEdgeColor(0, 0, 0, 0)
    nameCtrl.bg:SetEdgeTexture("", 1, 1, 2)

    nameCtrl.nameLabel = wm:CreateControl(nameName .. "Label", nameCtrl, CT_LABEL)
    nameCtrl.nameLabel:SetAnchor(BOTTOM, nameCtrl, BOTTOM, 0, -2)
    nameCtrl.nameLabel:SetFont("ZoFontWinH4")
    nameCtrl.nameLabel:SetColor(0.92, 0.86, 0.72, 1)
    nameCtrl.nameLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    nameCtrl.nameLabel:SetText("")

    bar.nameLabel = nameCtrl.nameLabel
    TB.nameCtrl = nameCtrl

    DarkScrollsUI.UpdateElementTextScaleValue(nameCtrl)
end

-----------------------------------------------------------
-- PUBLIC INIT  (called from DS_Init.lua)
-----------------------------------------------------------
function DarkScrollsUI.InitTargetBar()
    -- Hide the native target frame permanently; we replace it entirely
    if ZO_TargetUnitFramereticleover then
        ZO_TargetUnitFramereticleover:SetHidden(true)
        ZO_TargetUnitFramereticleover:SetAlpha(0)
        ZO_PreHook(ZO_TargetUnitFramereticleover, "SetHidden", function(_, hidden)
            if not hidden then return true end  -- block any attempt to show it
        end)
    end

    CreateTargetBar()

    local function UpdateTargetInfo(eventCode, isLockedParam)
        -- Atualiza o estado persistente de lock baseado no evento ou na API
        if eventCode == EVENT_TARGET_LOCK_STATE_CHANGED then
            TB.isLocked = isLockedParam
        elseif IsGameCameraUnitTargetLockOnActive then
            TB.isLocked = IsGameCameraUnitTargetLockOnActive()
        end

        if TB.isLocked then
            -- 1. Se houver algo na mira mas não for o alvo travado, ignoramos para não trocar a barra.
            -- 2. Se não houver nada na mira, ignoramos para manter a barra do alvo travado visível.
            if DoesUnitExist("reticleover") then
                if not IsUnitTargetLockOn("reticleover") then return end
            else
                -- Alvo travado mas fora da mira: mantém a barra
                SetBarVisible(true)
                return 
            end
        end

        local pct, name = GetTargetHealthPct()
        if pct then
            -- Se a barra estava invisível ou quase sumindo, sincronizamos o preenchimento 
            -- para evitar que ela "cresça" do 0% toda vez que você olha para um alvo.
            if TB.fadeAlpha < 0.1 then
                TB.displayPct = pct
                TB.drainPct   = pct
            end
            TB.targetPct = pct

            if TB.nameCtrl and TB.nameCtrl.nameLabel then
                if DoesUnitExist("reticleover") then
                    local isPlayer = IsUnitPlayer("reticleover")
                    local isGuard = IsUnitJusticeGuard("reticleover")
                    local difficulty = GetUnitDifficulty("reticleover") or 0
                    local title = GetUnitTitle("reticleover")
                    local charName = GetUnitName("reticleover")

                    local lvlStr = ""
                    local nameColor = {0.92, 0.86, 0.72, 1} -- Cor padrão (Bege)

                -- Reseta a cor da barra para o padrão (vermelho) antes de checar o tipo de unidade
                if TB.bar then
                    TB.bar.fillBottom:SetCenterColor(unpack(TargetBarConfig.COLOR_FULL))
                    TB.bar.fillTop:SetCenterColor(unpack(TargetBarConfig.COLOR_BRIGHT))
                end

                    if isPlayer then
                        local level = GetUnitLevel("reticleover")
                        local cp = GetUnitChampionPoints("reticleover")
                        if cp and cp > 0 then
                            lvlStr = zo_iconFormat("EsoUI/Art/Champion/champion_icon.dds", 20, 20) .. cp
                        else
                            lvlStr = "Nv. " .. level
                        end
                    elseif isGuard then
                        nameColor = {1, 1, 0.5, 1} -- Amarelo claro para Guardas
                    -- Aplica a cor prateada na barra de vida para guardas
                    if TB.bar then
                        TB.bar.fillBottom:SetCenterColor(0.5, 0.5, 0.55, 1)
                        TB.bar.fillTop:SetCenterColor(0.8, 0.8, 0.85, 1)
                    end
                    elseif difficulty >= 2 then
                        nameColor = {1, 0.15, 0.15, 1} -- Vermelho para Elites e Chefes
                    else
                        nameColor = {0.7, 0.7, 0.7, 1} -- Cinza para NPCs comuns
                    end

                    local finalName = ""
                    if isPlayer then
                        local displayName = GetUnitDisplayName("reticleover")
                        finalName = lvlStr .. "  " .. displayName .. "\n" .. charName
                    else
                        finalName = charName
                    end

                    if title and title ~= "" then
                        finalName = finalName .. "\n" .. title
                    end

                    -- SALVAMOS O NOME AQUI PARA USAR NO TICK
                    if finalName and finalName ~= "" then
                        TB.cachedFullName = finalName 
                        TB.cachedColor    = {nameColor[1], nameColor[2], nameColor[3], 1}

                        if TB.nameCtrl and TB.nameCtrl.nameLabel then
                            TB.nameCtrl.nameLabel:SetText(finalName)
                            TB.nameCtrl.nameLabel:SetColor(unpack(TB.cachedColor))
                        end
                    end
                else
                    if name and name ~= "" then
                        TB.cachedFullName = name
                        TB.cachedColor    = {0.92, 0.86, 0.72, 1}
                        if TB.nameCtrl and TB.nameCtrl.nameLabel then
                            TB.nameCtrl.nameLabel:SetText(TB.cachedFullName)
                            TB.nameCtrl.nameLabel:SetColor(unpack(TB.cachedColor))
                        end
                    end
                end
            end
        else
            if not TB.isLocked then
                SetBarVisible(false)
                TB.targetPct = TB.displayPct -- Congela o valor visual atual
            end
        end
    end

    -- Reage a mudanças de alvo e ativação/desativação de trava
    local evKey = DarkScrollsUI.AddonNameIdentifier .. "_TargetBar"
    EVENT_MANAGER:RegisterForEvent(evKey, EVENT_RETICLE_TARGET_CHANGED, UpdateTargetInfo)
    -- Garante que a barra apareça/suma imediatamente ao travar ou destravar o alvo (Tab)
    if EVENT_TARGET_LOCK_STATE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(evKey .. "_Lock", EVENT_TARGET_LOCK_STATE_CHANGED, UpdateTargetInfo)
    end

    -- Escuta atualizações de vida para que a barra responda a dano sem precisar mover a mira
    EVENT_MANAGER:RegisterForEvent(evKey .. "_Power", EVENT_POWER_UPDATE, function(_, unitTag, _, powerType)
        if powerType == POWERTYPE_HEALTH then
            -- Se for o que estamos olhando ou se estivermos com lock e a unidade for bossX/reticleover
            if unitTag == "reticleover" or (TB.isLocked and string.find(unitTag, "boss")) then
                UpdateTargetInfo()
            end
        end
    end)
end

-----------------------------------------------------------
-- EXPOSE TB controls so DS_EditMode can find them by name
-----------------------------------------------------------
function DarkScrollsUI.GetTargetBarControls()
    return TB.bar, TB.nameCtrl
end
