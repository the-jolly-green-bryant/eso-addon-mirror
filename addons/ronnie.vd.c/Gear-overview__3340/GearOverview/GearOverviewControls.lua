local lib = GearOverview
lib.UI = {}

function lib.UI.Control(name, parent, dims, anchor, hidden)
    --Validate arguments
    local point = parent
    if anchor[5] then
        if type(anchor[5]) == "function" then
            point = anchor[5]()
        else
            point = anchor[5]
        end
    end
    if not parent then
        parent = GuiRoot
        point = GuiRoot
    end
    if dims == "inherit" or #dims ~= 2 then
        dims = { parent:GetWidth(), parent:GetHeight() }
    end
    hidden = hidden == nil and false or hidden

    --Create the control
    local control = _G[name] or WINDOW_MANAGER:CreateControl(name, parent, CT_CONTROL)

    --Apply properties
    control:SetDimensions(dims[1], dims[2])
    control:ClearAnchors()
    control:SetAnchor(anchor[1], point, anchor[2], anchor[3], anchor[4])
    control:SetParent(parent)
    control:SetHidden(hidden)
    return control
end

function lib.UI.Label(name, parent, dims, anchor, font, color, align, text, hidden)
    --Validate arguments
    parent = (parent == nil) and GuiRoot or parent
    if (#anchor ~= 4 and #anchor ~= 5) then
        return
    end
    font = (font == nil) and "ZoFontGame" or font
    color = (color ~= nil and #color == 4) and color or { 1, 1, 1, 1 }
    align = (align ~= nil and #align == 2) and align or { 0, 0 }
    hidden = (hidden == nil) and false or hidden

    --Create the label
    local label = _G[name] or WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)

    if dims then
        label:SetDimensions(dims[1], dims[2])
    end
    label:ClearAnchors()
    label:SetAnchor(anchor[1], #anchor == 5 and anchor[5] or parent, anchor[2], anchor[3], anchor[4])
    label:SetFont(font)
    label:SetColor(unpack(color))
    label:SetHorizontalAlignment(align[1])
    label:SetVerticalAlignment(align[2])
    label:SetText(text)
    label:SetHidden(hidden)
    return label
end

function lib.UI.Button(name, parent, dims, anchor, state, font, align, normal, pressed, mouseover, hidden)
    --Validate arguments
    if (name == nil or name == "") then
        return
    end
    parent = (parent == nil) and GuiRoot or parent
    if (dims == "inherit" or #dims ~= 2) then
        dims = { parent:GetWidth(), parent:GetHeight() }
    end
    if (#anchor ~= 4 and #anchor ~= 5) then
        return
    end
    state = (state ~= nil) and state or BSTATE_NORMAL
    font = (font == nil) and "ZoFontGame" or font
    align = (align ~= nil and #align == 2) and align or { 1, 1 }
    normal = (normal ~= nil and #normal == 4) and normal or { 1, 1, 1, 1 }
    pressed = (pressed ~= nil and #pressed == 4) and pressed or { 1, 1, 1, 1 }
    mouseover = (mouseover ~= nil and #mouseover == 4) and mouseover or { 1, 1, 1, 1 }
    hidden = (hidden == nil) and false or hidden

    --Create the button
    local button = _G[name]
    if (button == nil) then
        button = WINDOW_MANAGER:CreateControl(name, parent, CT_BUTTON)
    end

    --Apply properties
    button = Chain(button)
            :SetDimensions(dims[1], dims[2])
            :ClearAnchors()
            :SetAnchor(anchor[1], #anchor == 5 and anchor[5] or parent, anchor[2], anchor[3], anchor[4])
            :SetState(state)
            :SetFont(font)
            :SetNormalFontColor(normal[1], normal[2], normal[3], normal[4])
            :SetPressedFontColor(pressed[1], pressed[2], pressed[3], pressed[4])
            :SetMouseOverFontColor(mouseover[1], mouseover[2], mouseover[3], mouseover[4])
            :SetHorizontalAlignment(align[1])
            :SetVerticalAlignment(align[2])
            :SetHidden(hidden)
            .__END
    return button
end

function lib.UI.ComboBox(name, parent, dims, anchor, array, val, fun, hidden, scroll)
    --Validate arguments
    if (name == nil or name == "") then
        return
    end
    parent = (parent == nil) and GuiRoot or parent
    if (dims == "inherit" or #dims ~= 2) then
        dims = { parent:GetWidth(), parent:GetHeight() }
    end
    if (#anchor ~= 4 and #anchor ~= 5) then
        return
    end
    hidden = (hidden == nil) and false or hidden
    --Create the control
    local control = _G[name] or WINDOW_MANAGER:CreateControlFromVirtual(name, parent, (scroll and #array > 20) and "ZO_ScrollableComboBox" or "ZO_ComboBox")
    control:GetNamedChild("BGMungeOverlay"):SetHidden(true)
    --Apply properties
    control:SetDimensions(dims[1], dims[2])
    control:ClearAnchors()
    control:SetAnchor(anchor[1], #anchor == 5 and anchor[5] or parent, anchor[2], anchor[3], anchor[4])
    control:SetHidden(hidden)
    control.m_comboBox:SetSortsItems(false)
    control.m_comboBox:SetFont("ZoFontGameMedium")
    if scroll and #array > 20 then
        control.m_comboBox:SetHeight(math.min(control.m_comboBox:GetEntryTemplateHeightWithSpacing() * #array - control.m_comboBox.m_spacing + ZO_SCROLLABLE_COMBO_BOX_LIST_PADDING_Y * 2, 400))
    end
    --Set values
    control.UpdateValues = function(self, valuesArray, index)
        local comboBox = self.m_comboBox
        if valuesArray then
            comboBox:ClearItems()
            for i, v in pairs(valuesArray) do
                local entry = ZO_ComboBox:CreateItemEntry(v, function()
                    control.value = i
                    fun(i, v)
                    self:UpdateParent()
                end)
                entry.id = i
                comboBox:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
            end
        end
        comboBox:SelectItemByIndex(index, true)
        control.value = index
        self:UpdateParent()
    end
    control.SetDisabled = function(self, value)
        self.disabled = value
        self:SetMouseEnabled(not value)
        self:GetNamedChild("OpenDropdown"):SetMouseEnabled(not value)
        self:SetAlpha(value and .5 or 1)
        self:UpdateParent()
    end
    control.UpdateParent = function(self)
        if parent:GetType() == CT_LABEL then
            local color = self.disabled and { .3, .3, .3, 1 } or array[control.value] == "Disabled" and { .5, .5, .4, 1 } or { .8, .8, .6, 1 }
            parent:SetColor(unpack(color))
        end
    end

    local index = type(val) == "function" and val() or val
    if type(index) == "string" then
        control.array = {}
        for i, value in pairs(array) do
            control.array[value] = i
        end
        index = control.array[index]
    end

    control:UpdateValues(array, index)
    return control
end

function lib.UI.TextBox(name, parent, dims, anchor, chars, val, fun, hidden, isMultiline)
    --Validate arguments
    parent = (parent == nil) and GuiRoot or parent
    if (dims == "inherit" or #dims ~= 2) then
        dims = { parent:GetWidth(), parent:GetHeight() }
    end
    if (#anchor ~= 4 and #anchor ~= 5) then
        return
    end
    hidden = (hidden == nil) and false or hidden
    local text = val and (type(val) == "number" or type(val) == "string") and val or type(val) == "function" and val() or ""

    --Create the control
    local control = _G[name]
    if (control == nil) then
        control = WINDOW_MANAGER:CreateControl(name, parent, CT_EDITBOX)
        control.bg = WINDOW_MANAGER:CreateControlFromVirtual(nil, control, "ZO_EditBackdrop_Gamepad")
        if isMultiline then
            control.eb = WINDOW_MANAGER:CreateControlFromVirtual(nil, control, "ZO_DefaultEditMultiLineForBackdrop")
        else
            control.eb = WINDOW_MANAGER:CreateControlFromVirtual(nil, control, "ZO_DefaultEditForBackdrop")
        end
    end
    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, #anchor == 5 and anchor[5] or parent, anchor[2], anchor[3], anchor[4])
    control:SetAnchor(BOTTOMRIGHT, #anchor == 5 and anchor[5] or parent, anchor[2], anchor[3] + dims[1], anchor[4] + dims[2])
    control:SetHidden(hidden)
    control.bg:ClearAnchors()
    control.bg:SetAnchorFill()
    control.eb:ClearAnchors()
    control.eb:SetAnchorFill()
    control.eb:SetMaxInputChars(chars)
    if fun then
        control.eb:SetHandler("OnFocusLost", function(self)
            fun(self:GetText())
        end)
    end
    control.SetDisabled = function(self, value)
        self.disabled = value
        self.eb:SetMouseEnabled(not value)
        self:SetAlpha(value and .5 or 1)
        self:UpdateParent()
    end
    control.UpdateParent = function(self)
        if parent:GetType() == CT_LABEL then
            local color = self.disabled and { .3, .3, .3, 1 } or { .8, .8, .6, 1 }
            parent:SetColor(unpack(color))
        end
    end

    control.eb:SetText(text)
    return control
end
