local TTK = TimeToKill

---------------------------------------------------------------------------
-- INTERFACE ELEMENTS
---------------------------------------------------------------------------
function TTK.CreateGuiElements()
    -- PARENT
    TTK.PARENT = WINDOW_MANAGER:CreateTopLevelWindow(TTK.name .. "_CONTROL")
    TTK.PARENT:SetDimensions(TTK.SV.iconSize, TTK.SV.iconSize)
    TTK.PARENT:SetClampedToScreen(true)
    TTK.PARENT:SetMovable(not TTK.SV.isLocked)
    TTK.PARENT:SetMouseEnabled(not TTK.SV.isLocked)
    TTK.PARENT:SetDrawTier(DT_HIGH)
    TTK.PARENT:SetDrawLayer(DL_OVERLAY)
    TTK.PARENT:SetHidden(true)

    TTK.PARENT:SetHandler("OnMoveStop", function()
        TTK.SV.offsetX = TTK.PARENT:GetLeft()
        TTK.SV.offsetY = TTK.PARENT:GetTop()
    end)

    TTK.BG = WINDOW_MANAGER:CreateControl("$(parent)_BG", TTK.PARENT, CT_BACKDROP)
    TTK.BG:SetAnchor(TOPLEFT, TTK.PARENT, TOPLEFT)
    TTK.BG:SetDimensions(TTK.SV.iconSize, TTK.SV.iconSize)
    local r, g, b, a = unpack(TTK.SV.colorHigh)
    TTK.BG:SetCenterColor(r, g, b, a)
    TTK.BG:SetEdgeColor(0, 0, 0, 1)
    TTK.BG:SetEdgeTexture("", 1, 1, TTK.SV.edgeThickness, 0)

    -- ICON
    TTK.ICON = WINDOW_MANAGER:CreateControl("$(parent)_ICON", TTK.PARENT, CT_TEXTURE)
    TTK.ICON:SetAnchor(CENTER, TTK.PARENT, CENTER)
    local innerSize = math.max(1, TTK.SV.iconSize - (TTK.SV.borderThickness * 2))
    TTK.ICON:SetDimensions(innerSize, innerSize)
    TTK.ICON:SetTexture("/esoui/art/icons/vmh_speed_challenge.dds")
    TTK.ICON:SetDesaturation(TTK.SV.iconDesaturation / 100)

    -- TTK TIMER (CENTER)
    TTK.DURATION = WINDOW_MANAGER:CreateControl("$(parent)_DURATION", TTK.PARENT, CT_LABEL)
    TTK.DURATION:SetColor(unpack(TTK.SV.textColorTimer))
    TTK.DURATION:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    TTK.DURATION:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    -- DPS (TOP LEF)
    TTK.DPS_LABEL = WINDOW_MANAGER:CreateControl("$(parent)_DPS", TTK.PARENT, CT_LABEL)
    TTK.DPS_LABEL:SetColor(unpack(TTK.SV.textColorDPS))
    TTK.DPS_LABEL:SetAnchor(TOPLEFT, TTK.PARENT, TOPLEFT, 7, 3)

    TTK.UpdateTimerPosition()
    TTK.UpdateFonts()
end

function TTK.UpdateTimerPosition()
    TTK.DURATION:ClearAnchors()
    TTK.DURATION:SetAnchor(CENTER, TTK.PARENT, CENTER, 0, TTK.SV.offsetYTimer)
end

function TTK.GetFontStyle()
    return TTK.SV.isThickOutline and "thick-outline" or "soft-shadow-thick"
end

function TTK.UpdateFonts()
    local style = TTK.GetFontStyle()
    TTK.DURATION:SetFont("$(BOLD_FONT)|" .. TTK.SV.fontSizeTimer .. "|" .. style)
    TTK.DPS_LABEL:SetFont("$(BOLD_FONT)|" .. TTK.SV.fontSizeDPS .. "|" .. style)
end

---------------------------------------------------------------------------
-- VISUAL UPDATE
---------------------------------------------------------------------------
function TTK.UpdateVisuals(ttk, dps, currentHealth, maxHealth)
    if not TTK.PARENT then return end

    if not TTK.hasTriggered then
        if currentHealth > 0 and (TTK.SV.thresholdSec == 0 or (ttk > 0 and ttk <= TTK.SV.thresholdSec)) then
            TTK.hasTriggered = true
            TTK.UpdateVisibility()
        end
    end

    -- CALC %
    -- local healthPercent = maxHealth > 0 and (currentHealth / maxHealth * 100) or 0

    TTK.DPS_LABEL:SetText(TTK.FormatDPS(dps))
    TTK.DPS_LABEL:SetHidden(TTK.SV.isHideDPSLabel or currentHealth <= 0)

    -- TTK CALC AND COLOR
    local r, g, b, a = unpack(TTK.SV.colorHigh)
    local timeText = TTK.FormatTTK(ttk, TTK.SV.thresholdSec)

    TTK.DURATION:SetText(timeText)

    if timeText ~= "∞" and TTK.SV.thresholdSec > 0 then
        local percentage = ttk / TTK.SV.thresholdSec
        r, g, b, a = TTK.GetPercentageColor(percentage, TTK.SV.colorHigh, TTK.SV.colorMid, TTK.SV.colorLow)
    end

    if not TTK.SV.isColoredTimer then
        r, g, b, a = unpack(TTK.SV.textColorTimer)
    end

    if TTK.SV.edgeThickness == 0 then TTK.BG:SetEdgeColor(0, 0, 0, 0)
    else TTK.BG:SetEdgeColor(0, 0, 0, 1) end

    TTK.BG:SetCenterColor(r, g, b, a)
    TTK.DURATION:SetColor(r, g, b, a)
end

---------------------------------------------------------------------------
-- VISIBILITY / HIDE IN MENU AND STUFF
---------------------------------------------------------------------------
function TTK.UpdateVisibility()
    -- PREVIEW AFTER SLASH OR MENU
    if TTK.isPreview then
        TTK.UpdateVisuals(9, 798000, 7182000, 41496000)
        TTK.PARENT:SetHidden(false)
        return
    end

    local isHidden = not (SCENE_MANAGER:GetScene("hud"):IsShowing() or SCENE_MANAGER:GetScene("hudui"):IsShowing())

    if isHidden or (TTK.SV.isOnlyCombat and not TTK.isCombat) then
        TTK.PARENT:SetHidden(true)
    elseif TTK.SV.thresholdSec > 0 and not TTK.hasTriggered then
        TTK.PARENT:SetHidden(true)
    else
        TTK.PARENT:SetHidden(false)
    end
end