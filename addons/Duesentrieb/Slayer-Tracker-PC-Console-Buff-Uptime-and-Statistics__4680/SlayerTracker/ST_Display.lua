local ST = SlayerTracker

---------------------------------------------------------------------------
-- CREATE GUI
---------------------------------------------------------------------------
function ST.CreateGuiElements()
    ST.PARENT = WINDOW_MANAGER:CreateTopLevelWindow(ST.NAME .. "_PARENT")
    ST.PARENT:SetDimensions(ST.SV.iconSize, ST.SV.iconSize)
    ST.PARENT:SetClampedToScreen(true)
    ST.PARENT:SetMovable(not ST.SV.isLocked)
    ST.PARENT:SetMouseEnabled(not ST.SV.isLocked)
    ST.PARENT:SetHidden(true)

    ST.PARENT:SetHandler("OnMoveStop", function()
        ST.SV.offsetX = ST.PARENT:GetLeft()
        ST.SV.offsetY = ST.PARENT:GetTop()
    end)

    -- BACKGROUND / BORDER
    ST.BG = WINDOW_MANAGER:CreateControl("$(parent)_BG", ST.PARENT, CT_BACKDROP)
    ST.BG:SetAnchor(TOPLEFT, ST.PARENT, TOPLEFT)
    ST.BG:SetDimensions(ST.SV.iconSize, ST.SV.iconSize)
    ST.BG:SetEdgeTexture("", 1, 1, ST.SV.edgeThickness, 0)
    ST.BG:SetCenterColor(unpack(ST.SV.ColorIdle))
    ST.BG:SetEdgeColor(0, 0, 0, 1)
    ST.BG:SetHidden(not ST.SV.isShowBackground)

    -- ICON
    ST.ICON = WINDOW_MANAGER:CreateControl("$(parent)_ICON", ST.PARENT, CT_TEXTURE)
    ST.ICON:SetAnchor(CENTER, ST.PARENT, CENTER)
    local innerSize = math.max(1, ST.SV.iconSize - (ST.SV.borderThickness * 2))
    ST.ICON:SetDimensions(innerSize, innerSize)
    ST.ICON:SetTexture(ST.SV.textureIcon)
    ST.ICON:SetHidden(not ST.SV.isShowBackground)
    ST.ICON:SetDesaturation(ST.SV.iconDesaturation / 100)

    -- TIMER
    ST.DURATION = WINDOW_MANAGER:CreateControl("$(parent)_DURATION", ST.PARENT, CT_LABEL)
    ST.DURATION:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    ST.DURATION:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    ST.UpdateTimerPosition()

    -- UPTIME PERCENTAGE
    ST.UPTIME_LABEL = WINDOW_MANAGER:CreateControl("$(parent)_UPTIME", ST.PARENT, CT_LABEL)
    ST.UPTIME_LABEL:SetColor(unpack(ST.SV.textColorUptime))
    ST.UPTIME_LABEL:SetAnchor(TOPLEFT, ST.PARENT, TOPLEFT, 7, 4)

    -- EXPECTED SECONDS
    ST.EXPSEC_LABEL = WINDOW_MANAGER:CreateControl("$(parent)_EXPSEC", ST.PARENT, CT_LABEL)
    ST.EXPSEC_LABEL:SetColor(unpack(ST.SV.textColorExpSec))
    ST.EXPSEC_LABEL:SetAnchor(TOPRIGHT, ST.PARENT, TOPRIGHT, -7, 4)

    ST.UpdateFonts()
end

---------------------------------------------------------------------------
-- TIMER POSITION
---------------------------------------------------------------------------
function ST.UpdateTimerPosition()
    ST.DURATION:ClearAnchors()

    local showExpSec = (not ST.SV.isHideExpSec) and (ST.isWearingSlayerSet or ST.isPreview)

    if ST.SV.isHideUptime and not showExpSec then
        ST.DURATION:SetAnchor(CENTER, ST.PARENT, CENTER, 0, ST.SV.offsetYTimer - ST.Default.offsetYTimer)
    else
        ST.DURATION:SetAnchor(CENTER, ST.PARENT, CENTER, 0, ST.SV.offsetYTimer)
    end
end

---------------------------------------------------------------------------
-- FONT STYLE AND SIZE
---------------------------------------------------------------------------
function ST.UpdateFonts()
    local style = ST.SV.isThickOutline and "thick-outline" or "soft-shadow-thick"
    ST.DURATION:SetFont("$(BOLD_FONT)|" .. ST.SV.fontSizeTimer .. "|" .. style)
    ST.UPTIME_LABEL:SetFont("$(BOLD_FONT)|" .. ST.SV.fontSizeUptime .. "|" .. style)
    ST.EXPSEC_LABEL:SetFont("$(BOLD_FONT)|" .. ST.SV.fontSizeExpSec .. "|" .. style)
end

---------------------------------------------------------------------------
-- DEFAULT POSITION
---------------------------------------------------------------------------
function ST.SetDefaultPosition()
    ST.PARENT:ClearAnchors()
    ST.PARENT:SetAnchor(CENTER, GuiRoot, CENTER, 0, ST.Default.offsetY)
    ST.SV.offsetX = ST.PARENT:GetLeft()
    ST.SV.offsetY = ST.PARENT:GetTop()
end