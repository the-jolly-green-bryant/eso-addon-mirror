-- Localized Globals
local WINDOW_MANAGER = WINDOW_MANAGER
local GuiRoot = GuiRoot
local InitializeTooltip = InitializeTooltip
local ClearTooltip = ClearTooltip
local InformationTooltip = InformationTooltip
local ZO_TOOLTIP_DEFAULT_COLOR = ZO_TOOLTIP_DEFAULT_COLOR
local ipairs = ipairs
local unpack = unpack
local string_format = string.format

-- Constants
local TOPRIGHT = TOPRIGHT
local TOPLEFT = TOPLEFT
local LEFT = LEFT
local CT_LABEL = CT_LABEL
local CT_TEXTURE = CT_TEXTURE
local DT_HIGH = DT_HIGH
local BSTATE_NORMAL = BSTATE_NORMAL
local BSTATE_DISABLED = BSTATE_DISABLED

-- Module Declaration
local Controls = {}

-- Private Functions

--- Validates an anchor array has correct number of elements.
--- @param anchor table The anchor array to validate
--- @return boolean True if anchor has 4 or 5 elements
local function ValidateAnchor(anchor)
    if not anchor then return false end
    local len = #anchor
    return len == 4 or len == 5
end

-- Public Functions

--- Sets up tooltip handlers for a control.
--- @param control any The control to add tooltip to
--- @param tooltipLines table Array of tooltip text lines (nil to remove tooltip)
function Controls.SetTooltip(control, tooltipLines)
    if not tooltipLines or #tooltipLines == 0 then
        control:SetHandler("OnMouseEnter", nil)
        control:SetHandler("OnMouseExit", nil)
        return
    end

    control:SetHandler("OnMouseEnter", function(ctrl)
        InitializeTooltip(InformationTooltip, ctrl, TOPRIGHT, -10, 0, TOPLEFT)
        for _, lineText in ipairs(tooltipLines) do
            InformationTooltip:AddLine(lineText, "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
        end
    end)

    control:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)
end

--- Creates a Label control.
--- @param name string Unique name for the control
--- @param parent any Parent control (nil defaults to GuiRoot)
--- @param dims table Dimensions as {width, height}
--- @param anchor table Anchor definition {point, relativeTo, relativePoint, offsetX, offsetY?}
--- @param font string Font name (defaults to "ZoFontGame")
--- @param color table Color as {r, g, b, a} (defaults to white)
--- @param align table Alignment as {horizontal, vertical} (defaults to {0, 0})
--- @param text string Text to display
--- @param hidden boolean Whether control starts hidden
--- @param tooltipLines table Optional array of tooltip text lines
--- @return any The created Label control
function Controls.Label(name, parent, dims, anchor, font, color, align, text, hidden, tooltipLines)
    if not name or name == "" then return nil end
    if not ValidateAnchor(anchor) then return nil end

    parent = parent or GuiRoot
    font = font or "ZoFontGame"
    color = (color and #color == 4) and color or { 1, 1, 1, 1 }
    align = (align and #align == 2) and align or { 0, 0 }
    hidden = hidden or false

    local label = WINDOW_MANAGER:GetControlByName(name) or WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)

    if dims then
        label:SetDimensions(dims[1], dims[2])
    end

    label:ClearAnchors()
    if #anchor == 5 then
        label:SetAnchor(anchor[1], anchor[2], anchor[3], anchor[4], anchor[5])
    else
        label:SetAnchor(anchor[1], anchor[2], anchor[3], anchor[4])
    end

    label:SetFont(font)
    label:SetColor(unpack(color))
    label:SetHorizontalAlignment(align[1])
    label:SetVerticalAlignment(align[2])
    label:SetText(text)
    label:SetHidden(hidden)
    label:SetDrawTier(DT_HIGH)

    Controls.SetTooltip(label, tooltipLines)

    return label
end

--- Creates a Button control.
--- @param name string Unique name for the control
--- @param parent any Parent control
--- @param dims table Dimensions as {width, height}
--- @param anchor table Anchor definition {point, relativeTo, relativePoint, offsetX, offsetY?}
--- @param text string Button text
--- @param func function Click handler function
--- @param enabled boolean Whether button is enabled
--- @param tooltipLines table Optional array of tooltip text lines
--- @param hidden boolean Whether control starts hidden
--- @return any The created Button control
function Controls.Button(name, parent, dims, anchor, text, func, enabled, tooltipLines, hidden)
    if not name or name == "" then return nil end
    if not ValidateAnchor(anchor) then return nil end

    hidden = hidden or false

    local button = WINDOW_MANAGER:GetControlByName(name) or
        WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "Panicida_Button")

    if dims then
        button:SetDimensions(dims[1], dims[2])
    end

    button:SetText(text)
    button:ClearAnchors()

    if #anchor == 5 then
        button:SetAnchor(anchor[1], anchor[2], anchor[3], anchor[4], anchor[5])
    else
        button:SetAnchor(anchor[1], anchor[2], anchor[3], anchor[4])
    end

    button:SetClickSound("Click")
    button:SetHandler("OnClicked", func)
    button:SetState(enabled and BSTATE_NORMAL or BSTATE_DISABLED)
    button:SetDrawTier(DT_HIGH)
    button:SetHidden(hidden)

    Controls.SetTooltip(button, tooltipLines)

    return button
end

--- Creates a Checkbox control (button with check icon).
--- @param name string Unique name for the control
--- @param parent any Parent control
--- @param dims table Dimensions as {width, height}
--- @param anchor table Anchor definition {point, relativeTo, relativePoint, offsetX, offsetY?}
--- @param text string Checkbox text
--- @param func function Click handler function
--- @param enabled boolean Whether checkbox is enabled
--- @param checked boolean Initial checked state
--- @param hidden boolean Whether control starts hidden
--- @return any The created Checkbox control with SetChecked method
function Controls.Checkbox(name, parent, dims, anchor, text, func, enabled, checked, hidden)
    if not name or name == "" then return nil end
    if not ValidateAnchor(anchor) then return nil end

    local checkbox = Controls.Button(name, parent, dims, anchor, text, func, enabled, nil, hidden)
    if not checkbox then return nil end
    local label = Controls.Label(
        name .. "_Label",
        checkbox,
        { dims[2], dims[2] },
        { LEFT, checkbox, LEFT, 0, 0 },
        nil, nil, { 0, 1 }
    )

    local function SetChecked(check)
        local iconPath = check and
            "/esoui/art/cadwell/checkboxicon_checked.dds" or
            "/esoui/art/cadwell/checkboxicon_unchecked.dds"
        local iconText = string_format("|t%d:%d:%s|t", dims[2], dims[2], iconPath)

        if label then
            label:SetText(iconText)
        end
    end

    checkbox:SetNormalTexture("")
    checkbox:SetDisabledTexture("")
    checkbox.SetChecked = SetChecked

    SetChecked(checked)

    return checkbox
end

--- Creates a Texture control.
--- @param name string Unique name for the control
--- @param parent any Parent control (nil defaults to GuiRoot)
--- @param dims table Dimensions as {width, height}
--- @param anchor table Anchor definition {point, relativeTo, relativePoint, offsetX, offsetY?}
--- @param texture string Path to texture file (optional, can be set later)
--- @return any The created Texture control
function Controls.Texture(name, parent, dims, anchor, texture)
    if not name or name == "" then return nil end
    if not ValidateAnchor(anchor) then return nil end

    parent = parent or GuiRoot

    local control = WINDOW_MANAGER:GetControlByName(name) or WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)

    if dims then
        control:SetDimensions(dims[1], dims[2])
    end

    control:ClearAnchors()
    if #anchor == 5 then
        control:SetAnchor(anchor[1], anchor[2], anchor[3], anchor[4], anchor[5])
    else
        control:SetAnchor(anchor[1], anchor[2], anchor[3], anchor[4])
    end

    if texture then
        control:SetTexture(texture)
    end

    return control
end

--- Creates a MultiIcon control for displaying multiple status icons.
--- @param name string Unique name for the control
--- @param parent any Parent control (nil defaults to GuiRoot)
--- @param dims table Dimensions as {width, height}
--- @param anchor table Anchor definition {point, relativeTo, relativePoint, offsetX, offsetY?}
--- @param tooltipLines table Optional array of tooltip text lines
--- @return any The created MultiIcon control
function Controls.MultiIcon(name, parent, dims, anchor, tooltipLines)
    if not name or name == "" then return nil end
    if not ValidateAnchor(anchor) then return nil end

    parent = parent or GuiRoot

    local multiIcon = WINDOW_MANAGER:GetControlByName(name) or
        WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_MultiIcon")

    if dims then
        multiIcon:SetDimensions(dims[1], dims[2])
    end

    multiIcon:ClearAnchors()
    if #anchor == 5 then
        multiIcon:SetAnchor(anchor[1], anchor[2], anchor[3], anchor[4], anchor[5])
    else
        multiIcon:SetAnchor(anchor[1], anchor[2], anchor[3], anchor[4])
    end

    multiIcon:SetMouseEnabled(true)

    Controls.SetTooltip(multiIcon, tooltipLines)

    return multiIcon
end

-- Module Registration
LibPanicida.Controls = Controls
