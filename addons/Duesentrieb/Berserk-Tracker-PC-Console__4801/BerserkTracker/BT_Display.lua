local BT = BerserkTracker

---------------------------------------------------------------------------
-- CREATE GUI
---------------------------------------------------------------------------
function BT.CreateGuiElements()
    BT.PARENT = WINDOW_MANAGER:CreateTopLevelWindow(BT.NAME .. "_PARENT")
    BT.PARENT:SetDimensions(BT.SV.iconSize, BT.SV.iconSize)
    BT.PARENT:SetClampedToScreen(true)
    BT.PARENT:SetMovable(not BT.SV.isLocked)
    BT.PARENT:SetMouseEnabled(not BT.SV.isLocked)
    BT.PARENT:SetHidden(true)

    BT.PARENT:SetHandler("OnMoveStop", function()
        BT.SV.offsetX = BT.PARENT:GetLeft()
        BT.SV.offsetY = BT.PARENT:GetTop()
    end)

    -- BACKGROUND / BORDER
    BT.BG = WINDOW_MANAGER:CreateControl("$(parent)_BG", BT.PARENT, CT_BACKDROP)
    BT.BG:SetAnchor(TOPLEFT, BT.PARENT, TOPLEFT)
    BT.BG:SetDimensions(BT.SV.iconSize, BT.SV.iconSize)
    BT.BG:SetEdgeTexture("", 1, 1, BT.SV.edgeThickness, 0)
    BT.BG:SetCenterColor(unpack(BT.SV.ColorIdle))
    BT.BG:SetEdgeColor(0, 0, 0, 1)
    BT.BG:SetHidden(not BT.SV.isShowBackground)

    -- ICON
    BT.ICON = WINDOW_MANAGER:CreateControl("$(parent)_ICON", BT.PARENT, CT_TEXTURE)
    BT.ICON:SetAnchor(CENTER, BT.PARENT, CENTER)
    local innerSize = math.max(1, BT.SV.iconSize - (BT.SV.borderThickness * 2))
    BT.ICON:SetDimensions(innerSize, innerSize)
    BT.ICON:SetTexture(BT.SV.textureIcon)
    BT.ICON:SetHidden(not BT.SV.isShowBackground)
    BT.ICON:SetDesaturation(BT.SV.iconDesaturation / 100)

    -- TIMER
    BT.DURATION = WINDOW_MANAGER:CreateControl("$(parent)_DURATION", BT.PARENT, CT_LABEL)
    BT.DURATION:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    BT.DURATION:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    BT.UpdateTimerPosition()

    -- UPTIME PERCENTAGE
    BT.UPTIME_LABEL = WINDOW_MANAGER:CreateControl("$(parent)_UPTIME", BT.PARENT, CT_LABEL)
    BT.UPTIME_LABEL:SetColor(unpack(BT.SV.textColorUptime))
    BT.UPTIME_LABEL:SetAnchor(TOPLEFT, BT.PARENT, TOPLEFT, 7, 4)

    BT.UpdateFonts()
end

---------------------------------------------------------------------------
-- TIMER POSITION
---------------------------------------------------------------------------
function BT.UpdateTimerPosition()
    BT.DURATION:ClearAnchors()

    if BT.SV.isHideUptime then
        BT.DURATION:SetAnchor(CENTER, BT.PARENT, CENTER, 0, BT.SV.offsetYTimer - BT.Default.offsetYTimer)
    else
        BT.DURATION:SetAnchor(CENTER, BT.PARENT, CENTER, 0, BT.SV.offsetYTimer)
    end
end

---------------------------------------------------------------------------
-- FONT STYLE AND SIZE
---------------------------------------------------------------------------
function BT.UpdateFonts()
    local style = BT.SV.isThickOutline and "thick-outline" or "soft-shadow-thick"
    BT.DURATION:SetFont("$(BOLD_FONT)|" .. BT.SV.fontSizeTimer .. "|" .. style)
    BT.UPTIME_LABEL:SetFont("$(BOLD_FONT)|" .. BT.SV.fontSizeUptime .. "|" .. style)
end

---------------------------------------------------------------------------
-- DEFAULT POSITION
---------------------------------------------------------------------------
function BT.SetDefaultPosition()
    BT.PARENT:ClearAnchors()
    BT.PARENT:SetAnchor(CENTER, GuiRoot, CENTER, 0, BT.Default.offsetY)
    BT.SV.offsetX = BT.PARENT:GetLeft()
    BT.SV.offsetY = BT.PARENT:GetTop()
end