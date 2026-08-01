if not GildedUI then return end

local Addon = GildedUI

Addon.READOUT_PADDING_X = 8
Addon.READOUT_PADDING_Y = 4
Addon.READOUT_ICON_GAP = 4

function Addon:ConfigureReadoutWindow(window)
    window:SetMouseEnabled(false)
    window:SetMovable(false)
    window:SetClampedToScreen(false)
    window:SetDrawLayer(DL_CONTROLS)
    window:SetDrawLevel(0)
    window:SetResizeToFitDescendents(true)
end

function Addon:CreateReadout(wm, name, font, r, g, b, placeholder, posX, posY, withIcon)
    local window = wm:CreateTopLevelWindow(name .. "_Window")
    self:ConfigureReadoutWindow(window)
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, posX, posY)

    local backdrop = wm:CreateControl(name .. "_BG", window, CT_BACKDROP)
    backdrop:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    backdrop:SetResizeToFitDescendents(true)
    backdrop:SetResizeToFitPadding(0, 0)
    backdrop:SetCenterColor(0, 0, 0, 0)
    backdrop:SetEdgeColor(0, 0, 0, 0)
    backdrop:SetEdgeTexture("", 1, 1, 1)

    local content
    local icon
    local label

    if withIcon then
        -- Invisible markers force resize-to-fit to include left/top and right/bottom padding.
        -- Offsetting content alone does not work: ESO sizes the parent to child dimensions
        -- and ignores the child's anchor offset, which parks the row in the bottom-right.
        local padOrigin = wm:CreateControl(name .. "_PadOrigin", backdrop, CT_CONTROL)
        padOrigin:SetDimensions(1, 1)
        padOrigin:SetAnchor(TOPLEFT, backdrop, TOPLEFT, 0, 0)
        backdrop.gildedPadOrigin = padOrigin

        local padExtent = wm:CreateControl(name .. "_PadExtent", backdrop, CT_CONTROL)
        padExtent:SetDimensions(0, 0)
        padExtent:SetAnchor(TOPLEFT, backdrop, TOPLEFT, 0, 0)
        backdrop.gildedPadExtent = padExtent

        content = wm:CreateControl(name .. "_Content", backdrop, CT_CONTROL)
        content:SetAnchor(TOPLEFT, backdrop, TOPLEFT, 0, 0)
        content:SetResizeToFitDescendents(true)

        icon = wm:CreateControl(name .. "_Icon", content, CT_TEXTURE)
        icon:SetDimensions(0, 0)
        icon:SetHidden(true)
        icon:SetAnchor(LEFT, content, LEFT, 0, 0)

        label = wm:CreateControl(name .. "_Label", content, CT_LABEL)
        label:SetFont(font)
        label:SetColor(r, g, b, 1)
        label:SetAnchor(LEFT, content, LEFT, 0, 0)
        label:SetText(placeholder)
    else
        label = wm:CreateControl(name .. "_Label", backdrop, CT_LABEL)
        label:SetFont(font)
        label:SetColor(r, g, b, 1)
        label:SetAnchor(CENTER, backdrop, CENTER, 0, 0)
        label:SetText(placeholder)
    end

    return window, backdrop, label, icon, content
end

function Addon:ApplyReadoutLayout(backdrop, content, label, icon, showBackground, showPadding, opacity, iconPath, fontSize)
    if not backdrop or not label then return end

    local usePadding = showBackground and showPadding
    local padX = usePadding and self.READOUT_PADDING_X or 0
    local padY = usePadding and self.READOUT_PADDING_Y or 0

    backdrop:SetCenterColor(0, 0, 0, showBackground and opacity or 0)

    label:ClearAnchors()

    if content then
        -- Icon rows: never use SetResizeToFitPadding — it only grows the backdrop while
        -- left-anchored children stay put, so padding looks wrong. Use markers instead.
        backdrop:SetResizeToFitPadding(0, 0)

        content:ClearAnchors()
        content:SetAnchor(TOPLEFT, backdrop, TOPLEFT, padX, padY)

        local padOrigin = backdrop.gildedPadOrigin
        if padOrigin then
            padOrigin:ClearAnchors()
            padOrigin:SetAnchor(TOPLEFT, backdrop, TOPLEFT, 0, 0)
            padOrigin:SetDimensions(1, 1)
        end

        local padExtent = backdrop.gildedPadExtent
        if padExtent then
            padExtent:ClearAnchors()
            if usePadding then
                padExtent:SetAnchor(TOPLEFT, content, BOTTOMRIGHT, padX, padY)
                padExtent:SetDimensions(1, 1)
                padExtent:SetHidden(false)
            else
                padExtent:SetAnchor(TOPLEFT, content, BOTTOMRIGHT, 0, 0)
                padExtent:SetDimensions(0, 0)
                padExtent:SetHidden(true)
            end
        end

        local showIcon = icon and iconPath and iconPath ~= ""
        if showIcon then
            local iconSize = fontSize or 16
            icon:ClearAnchors()
            icon:SetHidden(false)
            icon:SetDimensions(iconSize, iconSize)
            icon:SetTexture(iconPath)
            icon:SetAnchor(LEFT, content, LEFT, 0, 0)
            label:SetAnchor(LEFT, icon, RIGHT, self.READOUT_ICON_GAP, 0)
        else
            if icon then
                icon:ClearAnchors()
                icon:SetHidden(true)
                icon:SetDimensions(0, 0)
                icon:SetAnchor(LEFT, content, LEFT, 0, 0)
            end
            label:SetAnchor(LEFT, content, LEFT, 0, 0)
        end
    else
        -- Text-only readouts: centered label + resize padding expands evenly around it.
        backdrop:SetResizeToFitPadding(padX, padY)
        label:SetAnchor(CENTER, backdrop, CENTER, 0, 0)
    end
end

function Addon:ApplyReadoutBackground(backdrop, label, showBackground, showPadding, opacity)
    self:ApplyReadoutLayout(backdrop, nil, label, nil, showBackground, showPadding, opacity, nil, nil)
end

function Addon:ApplyReadoutPosition(window, posX, posY)
    if not window then return end

    window:ClearAnchors()
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, posX, posY)
end

function Addon:ApplyReadoutFont(label, fontSize)
    if not label then return end

    local font = self.fontMap[fontSize] or "EsoUI/Common/Fonts/Univers57.otf|16|soft-shadow-thick"
    label:SetFont(font)
end

function Addon:GetReadoutFont(fontSize)
    return self.fontMap[fontSize] or "EsoUI/Common/Fonts/Univers57.otf|16|soft-shadow-thick"
end

function Addon:SanitizeIconIndex(key, maxIndex)
    local sv = self.state.sv
    local index = sv[key]
    if type(index) ~= "number" then
        sv[key] = 1
    else
        sv[key] = zo_clamp(zo_floor(index), 1, maxIndex)
    end
end
