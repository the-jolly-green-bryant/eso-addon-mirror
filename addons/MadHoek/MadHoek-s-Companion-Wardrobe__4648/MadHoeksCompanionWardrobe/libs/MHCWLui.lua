-- ============================================================================
-- Companion Wardrobe
-- Shared UI Helpers
--
-- Responsibilities:
-- - Provide reusable button, checkbox, dropdown, and panel helpers.
-- - Centralize common UI styling.
-- - Keep window/dropdown construction consistent across the addon.
-- - Reduce duplicated ESO control setup code.
-- ============================================================================
if MHCWL == nil then MHCWL = {} end
local MHCWL = MHCWL

function MHCWL.IsAnyWindowOpen()
    return (MHCWL.window and not MHCWL.window:IsHidden())
        or (MHCWL.inspectWindow and not MHCWL.inspectWindow:IsHidden())
        or (MHCWL.exportWindow and not MHCWL.exportWindow:IsHidden())
        or (MHCWL.importWindow and not MHCWL.importWindow:IsHidden())
end

function MHCWL.CloseWardrobeWindows()
    if MHCWL.window then
        MHCWL.window:SetHidden(true)
    end

    if MHCWL.inspectWindow then
        MHCWL.inspectWindow:SetHidden(true)
    end
end

function MHCWL.CloseWindows()
    MHCWL.CloseWardrobeWindows()

    if MHCWL.companionMenuButtonHost then
        MHCWL.companionMenuButtonHost:SetHidden(true)
    end
end

function MHCWL.CloseDropdowns()
    if MHCWL.settingsDropdown then
        MHCWL.settingsDropdown:SetHidden(true)
    end

    if MHCWL.inspectOptionsDropdown then
        MHCWL.inspectOptionsDropdown:SetHidden(true)
    end

    if MHCWL.loadoutColorDropdown then
        MHCWL.loadoutColorDropdown:SetHidden(true)
    end
end

function MHCWL.CloseDialogs()
    if ZO_Dialogs_FindDialog("MHCWLRenameLoadoutDialog") then
        ZO_Dialogs_ReleaseDialog("MHCWLRenameLoadoutDialog")
    end

    if MHCWL.exportWindow then
        MHCWL.exportWindow:SetHidden(true)
    end

    if MHCWL.importWindow then
        MHCWL.importWindow:SetHidden(true)
    end
end

function MHCWL.ToggleAllWindows()
    if MHCWL.IsAnyWindowOpen() then
        MHCWL.CloseWardrobeWindows()
        MHCWL.CloseDropdowns()
        MHCWL.CloseDialogs()
        return
    end

    MHCWL.ToggleWindow()
end

function MHCWL.StylePanelBackdrop(control)
    control:SetCenterColor(unpack(MHCWL.UI_COLORS.panelCenter))
    control:SetEdgeColor(unpack(MHCWL.UI_COLORS.panelEdge))
    control:SetEdgeTexture("", 1, 1, 1)
end

function MHCWL.StyleDropdownBackdrop(control)
    control:SetCenterColor(unpack(MHCWL.UI_COLORS.dropdownCenter))
    control:SetEdgeColor(unpack(MHCWL.UI_COLORS.dropdownEdge))
    control:SetEdgeTexture("", 1, 1, 1)
end

function MHCWL.StyleDialogBackdrop(control)
    control:SetCenterColor(unpack(MHCWL.UI_COLORS.dialogCenter))
    control:SetEdgeColor(unpack(MHCWL.UI_COLORS.dialogEdge))
    control:SetEdgeTexture("", 1, 1, 1)
end

function MHCWL.StyleEditBoxBackdrop(control)
    control:SetCenterColor(unpack(MHCWL.UI_COLORS.editBoxCenter))
    control:SetEdgeColor(unpack(MHCWL.UI_COLORS.editBoxEdge))
    control:SetEdgeTexture("", 1, 1, 1)
end

function MHCWL.MeasureDropdownWidth(rows)
    local maxWidth = 0

    if not MHCWL.measureDropdownLabel then
        MHCWL.measureDropdownLabel =
            WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_LABEL)

        MHCWL.measureDropdownLabel:SetHidden(true)
        MHCWL.measureDropdownLabel:SetFont(MHCWL.FONTS.game)
    end

    local measure = MHCWL.measureDropdownLabel

    for _, row in ipairs(rows or {}) do
        if row.label then
            measure:SetText(row.label)

            local width = measure:GetTextDimensions() or 0

            if row.type == "checkbox" then
                width = width + 18 + 15
            end

            maxWidth = math.max(maxWidth, width)
        end
    end

    return maxWidth
end

function MHCWL.CreateCompanionMenuButton()
    MHCWL.Debug("CreateCompanionMenuButton called.")

    if not MHCWL.saved.settings.companionButton.enabled then
        MHCWL.Debug("Companion menu button disabled in settings.")

        if MHCWL.companionMenuButton then
            MHCWL.companionMenuButton:SetHidden(true)
        end

        if MHCWL.companionMenuButtonHost then
            MHCWL.companionMenuButtonHost:SetHidden(true)
        end

        return
    end

    if MHCWL.companionMenuButton then
        MHCWL.Debug("Companion menu button already exists. Showing.")

        MHCWL.companionMenuButton:SetHidden(false)

        if MHCWL.companionMenuButtonHost then
            MHCWL.companionMenuButtonHost:SetHidden(false)
        end

        MHCWL.companionMenuButton.RefreshState()
        return
    end

    MHCWL.Debug("Creating companion menu button.")

    local settings = MHCWL.saved.settings.companionButton

    local buttonHost = WINDOW_MANAGER:CreateTopLevelWindow("MHCWLCompanionMenuButtonHost")
    buttonHost:SetDimensions(48, 48)
    buttonHost:SetMouseEnabled(true)
    buttonHost:SetClampedToScreen(true)
    buttonHost:SetDrawLayer(DL_OVERLAY)
    buttonHost:SetDrawTier(DT_HIGH)
    buttonHost:SetDrawLevel(100)
    buttonHost:SetHidden(false)

    local button = MHCWL.CreateIconButton(
        buttonHost,
        0,
        0,
        48,
        MHCWL.BUTTONS.cw,
        GetString(MHCWL_WINDOW_MAIN_TITLE),
        function()
            if MHCWL.saved.settings.companionButton.unlocked then return end

            MHCWL.ToggleAllWindows()
        end,
        function()
            local unlocked = MHCWL.saved.settings.companionButton.unlocked

            return {
                normal = unlocked and MHCWL.UI_COLORS.dragRed or MHCWL.UI_COLORS.white,
                over = unlocked and MHCWL.UI_COLORS.dragRedOver or MHCWL.UI_COLORS.white,
                down = unlocked and MHCWL.UI_COLORS.dragRedDown or MHCWL.UI_COLORS.downBlue,
            }
        end
    )

    MHCWL.companionMenuButton = button

    buttonHost:ClearAnchors()

    if settings.left and settings.top then
        buttonHost:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settings.left, settings.top)
    else
        buttonHost:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end

    button:ClearAnchors()
    button:SetAnchorFill(buttonHost)

    button:SetHidden(false)
    buttonHost:SetHidden(false)

    MHCWL.companionMenuButtonHost = buttonHost

    button:SetDrawLayer(DL_OVERLAY)
    button:SetDrawTier(DT_HIGH)
    button:SetDrawLevel(100)

    button:SetHidden(false)

    local baseMouseDown = button:GetHandler("OnMouseDown")
    local baseMouseUp = button:GetHandler("OnMouseUp")
    local baseMouseEnter = button:GetHandler("OnMouseEnter")
    local baseMouseExit = button:GetHandler("OnMouseExit")

    button:SetHandler("OnMouseDown", function(self)
        if MHCWL.saved.settings.companionButton.unlocked then
            local mx, my = GetUIMousePosition()

            self.dragging = true
            self.dragOffsetX = mx - buttonHost:GetLeft()
            self.dragOffsetY = my - buttonHost:GetTop()

            return
        end

        if baseMouseDown then
            baseMouseDown(self)
        end
    end)

    button:SetHandler("OnMouseUp", function(self)
        if self.dragging then
            self.dragging = false

            MHCWL.saved.settings.companionButton.left = buttonHost:GetLeft()
            MHCWL.saved.settings.companionButton.top = buttonHost:GetTop()

            if MHCWL.saved.settings.companionButton.unlocked then
                WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_PAN or 12)
            end

            MHCWL.Debug("Saved companion button position.")
        end

        if not MHCWL.saved.settings.companionButton.unlocked then
            if ClearCursor then
                ClearCursor()
            end
        end

        if baseMouseUp then
            baseMouseUp(self)
        end
    end)

    button:SetHandler("OnMouseEnter", function(self)
        if MHCWL.saved.settings.companionButton.unlocked then
            WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_PAN or 12)
        end

        if baseMouseEnter then
            baseMouseEnter(self)
        end
    end)

    button:SetHandler("OnMouseExit", function(self)
        WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DEFAULT_CURSOR or 0)

        if baseMouseExit then
            baseMouseExit(self)
        end
    end)

    button:SetHandler("OnUpdate", function(self)
        if not self.dragging then return end

        local mx, my = GetUIMousePosition()
        local left = mx - self.dragOffsetX
        local top = my - self.dragOffsetY

        buttonHost:ClearAnchors()
        buttonHost:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end)

    button.RefreshState = function()
        button.RefreshIcon()
    end

    button.RefreshState()
end

function MHCWL.CreateSquareButton(parent, width, height, labelText, onClick, tooltipText)
    local button = WINDOW_MANAGER:CreateControl(nil, parent, CT_BUTTON)
    button:SetDimensions(width, height)

    button:SetNormalTexture(MHCWL.BUTTONS.squareButton.up)
    button:SetPressedTexture(MHCWL.BUTTONS.squareButton.down)
    button:SetMouseOverTexture(MHCWL.BUTTONS.squareButton.over)

    local label = WINDOW_MANAGER:CreateControl(nil, button, CT_LABEL)
    button.label = label

    label:SetAnchor(CENTER, button, CENTER, 0, -2)
    label:SetFont(MHCWL.FONTS.game)
    label:SetText(labelText)
    label:SetColor(unpack(MHCWL.UI_COLORS.white))

    button:SetHandler("OnMouseEnter", function(control)
        label:SetColor(unpack(MHCWL.UI_COLORS.softYellow))
        MHCWL.ShowControlTooltip(control, tooltipText)
    end)

    button:SetHandler("OnMouseExit", function()
        label:SetColor(unpack(MHCWL.UI_COLORS.white))
        label:ClearAnchors()
        label:SetAnchor(CENTER, button, CENTER, 0, -2)
        MHCWL.HideControlTooltip()
    end)

    button:SetHandler("OnMouseDown", function()
        label:ClearAnchors()
        label:SetAnchor(CENTER, button, CENTER, 0, 1)
    end)

    button:SetHandler("OnMouseUp", function()
        label:ClearAnchors()
        label:SetAnchor(CENTER, button, CENTER, 0, -2)
    end)

    button:SetHandler("OnClicked", onClick)

    return button
end

function MHCWL.CreateIconButton(parent, x, y, size, icons, tooltipText, onClick, color)
    local button = WINDOW_MANAGER:CreateControl(nil, parent, CT_BUTTON)
    button:SetDimensions(size, size)
    button:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)

    local texture = WINDOW_MANAGER:CreateControl(nil, button, CT_TEXTURE)
    button.texture = texture
    texture:SetAnchorFill(button)

    local function GetIcons()
        return type(icons) == "function" and icons() or icons
    end

    local function GetColor()
        local current = type(color) == "function" and color() or color
        return current or MHCWL.ICON_BUTTON_COLORS
    end

    function button.RefreshIcon()
        local currentIcons = GetIcons()
        local currentColor = GetColor()

        texture:SetTexture(currentIcons.up)
        texture:SetColor(unpack(currentColor.normal))
    end

    button:SetHandler("OnMouseEnter", function(control)
        local currentIcons = GetIcons()
        local currentColor = GetColor()

        texture:SetTexture(currentIcons.over or currentIcons.up)
        texture:SetColor(unpack(currentColor.over))

        MHCWL.ShowControlTooltip(control, tooltipText)
    end)

    button:SetHandler("OnMouseExit", function()
        button.RefreshIcon()
        MHCWL.HideControlTooltip()
    end)

    button:SetHandler("OnMouseDown", function()
        local currentIcons = GetIcons()
        local currentColor = GetColor()

        texture:SetTexture(currentIcons.down or currentIcons.up)
        texture:SetColor(unpack(currentColor.down))
    end)

    button:SetHandler("OnMouseUp", function()
        button.RefreshIcon()
    end)

    button:SetHandler("OnClicked", onClick)

    button.RefreshIcon()

    return button
end

function MHCWL.CreateTextButton(parent, x, y, width, height, text, onClick, tooltipText, colors)
    local button = WINDOW_MANAGER:CreateControl(nil, parent, CT_BUTTON)

    button:SetDimensions(width, height)
    button:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)

    button:SetFont(MHCWL.FONTS.game)
    button:SetText(text)

    local normalColor = colors and colors.normal or MHCWL.UI_COLORS.white
    local overColor = colors and colors.over or MHCWL.UI_COLORS.hoverBlue
    local downColor = colors and colors.down or MHCWL.UI_COLORS.pressedBlue

    button:SetNormalFontColor(unpack(normalColor))
    button:SetMouseOverFontColor(unpack(overColor))
    button:SetPressedFontColor(unpack(downColor))

    button:SetHandler("OnMouseEnter", function(control)
        MHCWL.ShowControlTooltip(control, tooltipText)
    end)

    button:SetHandler("OnMouseExit", function()
        MHCWL.HideControlTooltip()
    end)

    button:SetHandler("OnClicked", onClick)

    return button
end

function MHCWL.CreateCheckboxButton(
    parent,
    x,
    y,
    labelText,
    initialState,
    onToggle,
    tooltipText
)
    local row = {}

    row.button = WINDOW_MANAGER:CreateControl(nil, parent, CT_BUTTON)
    row.button:SetDimensions(parent:GetWidth() - 28, 24)
    row.button:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)

    row.checkbox = WINDOW_MANAGER:CreateControl(nil, row.button, CT_TEXTURE)
    row.checkbox:SetDimensions(18, 18)
    row.checkbox:SetAnchor(BOTTOMLEFT, row.button, BOTTOMLEFT, 0, 2)

    row.label = WINDOW_MANAGER:CreateControl(nil, row.button, CT_LABEL)
    row.label:SetFont(MHCWL.FONTS.game)
    row.label:SetAnchor(LEFT, row.checkbox, RIGHT, 15, 2)
    row.label:SetText(labelText)


    local function Refresh(enabled)
        local color =
            enabled
            and MHCWL.UI_COLORS.white
            or MHCWL.UI_COLORS.disabled

        row.checkbox:SetTexture(
            enabled
            and MHCWL.BUTTONS.checkbox.checked
            or MHCWL.BUTTONS.checkbox.unchecked
        )

        row.checkbox:SetColor(unpack(color))
        row.label:SetColor(unpack(color))
    end

    row.Refresh = Refresh

    row.button:SetHandler("OnMouseEnter", function()
        row.checkbox:SetColor(unpack(MHCWL.UI_COLORS.hoverBlue))
        row.label:SetColor(unpack(MHCWL.UI_COLORS.hoverBlue))

        MHCWL.ShowControlTooltip(row.button, tooltipText)
    end)

    row.button:SetHandler("OnMouseExit", function()
        Refresh(row.enabled)
        MHCWL.HideControlTooltip()
    end)

    row.button:SetHandler("OnClicked", function()
        row.enabled = not row.enabled
        Refresh(row.enabled)

        if onToggle then
            onToggle(row.enabled)
        end
    end)

    row.enabled = initialState or false
    Refresh(row.enabled)

    return row
end

function MHCWL.CreateDropdown(config)
    local dropdown = WINDOW_MANAGER:CreateTopLevelWindow(config.name)

    dropdown:SetMouseEnabled(true)
    dropdown:SetClampedToScreen(true)
    dropdown:SetDrawLayer(DL_OVERLAY)
    dropdown:SetDrawTier(DT_HIGH)
    dropdown:SetDrawLevel(10)
    dropdown:SetHidden(true)

    dropdown.config = config
    dropdown.rows = {}
    dropdown.rowControls = {}

    local padding = 14
    local rowHeight = 28

    local function IsRowHidden(row)
        return row.hidden and row.hidden() == true
    end

    local bg = WINDOW_MANAGER:CreateControl(nil, dropdown, CT_BACKDROP)
    bg:SetAnchorFill(dropdown)
    MHCWL.StyleDropdownBackdrop(bg)

    local function ClearDropdownRows()
        for _, entry in ipairs(dropdown.rowControls or {}) do
            if entry.control then
                entry.control:SetHidden(true)
                entry.control:SetMouseEnabled(false)
            end
        end

        dropdown.rows = {}
        dropdown.rowControls = {}
    end

    local function BuildDropdownRows(rows)
        ClearDropdownRows()

        rows = rows or {}

        local labelWidth = MHCWL.MeasureDropdownWidth(rows)
        local width = padding + labelWidth + padding + (config.extraWidth or 0)

        local currentY = padding

        for _, row in ipairs(rows) do
            if not IsRowHidden(row) then
                currentY = currentY + (row.gapBefore or 0)
                currentY = currentY + rowHeight
                currentY = currentY + (row.gapAfter or 0)
            end
        end

        dropdown:SetDimensions(width, currentY + padding)

        local y = padding

        for _, row in ipairs(rows) do
            y = y + (row.gapBefore or 0)

            if row.type == "text" then
                local control = MHCWL.CreateTextButton(
                    dropdown,
                    padding,
                    y,
                    width - (padding * 2),
                    24,
                    row.label,
                    function()
                        dropdown:SetHidden(true)

                        if row.onClick then
                            row.onClick()
                        end
                    end,
                    row.tooltip,
                    row.colors
                )

                table.insert(dropdown.rows, {
                    control = control,
                    data = row,
                })

                table.insert(dropdown.rowControls, {
                    control = control,
                })

            elseif row.type == "checkbox" then
                local checkboxRow = MHCWL.CreateCheckboxButton(
                    dropdown,
                    padding,
                    y,
                    row.label,
                    row.get(),
                    function(enabled)
                        if row.set then
                            row.set(enabled)
                        end
                    end,
                    row.tooltip
                )

                table.insert(dropdown.rows, {
                    control = checkboxRow.button,
                    rowObject = checkboxRow,
                    data = row,
                })

                table.insert(dropdown.rowControls, {
                    control = checkboxRow.button,
                    rowObject = checkboxRow,
                })
            end

            y = y + rowHeight + (row.gapAfter or 0)
        end
    end

    dropdown:SetAnchor(
        config.anchorPoint,
        config.anchorTo,
        config.relativePoint,
        config.offsetX or 0,
        config.offsetY or 0
    )

    BuildDropdownRows(config.rows)

    dropdown:SetHandler("OnUpdate", function(control)
        if control:IsHidden() then return end

        local mx, my = GetUIMousePosition()

        local inside =
            mx >= control:GetLeft()
            and mx <= control:GetRight()
            and my >= control:GetTop()
            and my <= control:GetBottom()

        if not inside and WINDOW_MANAGER:IsMouseOverWorld() then
            control:SetHidden(true)
        end
    end)

    function dropdown.Refresh()
        if not dropdown.rows then return end

        local y = padding

        for _, entry in ipairs(dropdown.rows) do
            local row = entry.data
            local hidden = IsRowHidden(row)

            if entry.control then
                entry.control:SetHidden(hidden)
                entry.control:SetMouseEnabled(not hidden)
            end

            if not hidden then
                y = y + (row.gapBefore or 0)

                entry.control:ClearAnchors()
                entry.control:SetAnchor(
                    TOPLEFT,
                    dropdown,
                    TOPLEFT,
                    padding,
                    y
                )

                if entry.rowObject
                and entry.rowObject.Refresh
                and row.get then
                    entry.rowObject.enabled = row.get()
                    entry.rowObject.Refresh(entry.rowObject.enabled)
                end

                y = y + rowHeight + (row.gapAfter or 0)
            end
        end

        dropdown:SetHeight(y + padding)
    end

    function dropdown:Rebuild(rows)
        config.rows = rows or config.rows or {}

        BuildDropdownRows(config.rows)

        dropdown:ClearAnchors()
        dropdown:SetAnchor(
            config.anchorPoint,
            config.anchorTo,
            config.relativePoint,
            config.offsetX or 0,
            config.offsetY or 0
        )

        dropdown.Refresh()
    end

    return dropdown
end

function MHCWL.ToggleLoadoutColorDropdown()
    if MHCWL.loadoutColorDropdown
    and not MHCWL.loadoutColorDropdown:IsHidden() then
        MHCWL.loadoutColorDropdown:SetHidden(true)
        return
    end

    if not MHCWL.loadoutColorDropdown then
        MHCWL.CreateLoadoutColorDropdown()
    end

    MHCWL.loadoutColorDropdown.Refresh()

    MHCWL.inspectDropdownIgnoreMouseUntil = GetFrameTimeMilliseconds() + 250
    MHCWL.loadoutColorDropdown:SetHidden(false)
end

function MHCWL.BuildLoadoutColorDropdownRows()
    local rows = {}

    MHCWL.EnsureLoadoutColorSlots()

    for slotIndex = 0, 10 do
        local index = slotIndex
        local slot = MHCWL.GetLoadoutColorSlot(index)

        if slot and slot.active then
            table.insert(rows, {
                type = "text",
                label = MHCWL.GetLoadoutColorSlotName(index),
                colors = {
                    normal = MHCWL.GetLoadoutColorSlotColor(index),
                    over = MHCWL.UI_COLORS.hoverBlue,
                    down = MHCWL.UI_COLORS.pressedBlue,
                },
                onClick = function()
                    if not MHCWL.inspectIndex then return end

                    local companionData = MHCWL.GetActiveCompanionSavedData()
                    if not companionData then return end

                    local setup = companionData.setups[MHCWL.inspectIndex]
                    if not setup then return end

                    MHCWL.SetSetupColorSlot(setup, index)

                    MHCWL.RefreshWindow()
                    MHCWL.RefreshInspectWindow(MHCWL.inspectIndex)
                end,
            })
        end
    end

    table.insert(rows, {
        type = "checkbox",
        label = GetString(MHCWL_COLOR_USE_FOR_FAVORITES),
        gapBefore = 8,

        hidden = function()
            local companionData = MHCWL.GetActiveCompanionSavedData()
            if not companionData then return true end

            local setup = companionData.setups[MHCWL.inspectIndex or 0]
            if not setup then return true end

            return not setup.isFavorite
        end,

        get = function()
            local companionData = MHCWL.GetActiveCompanionSavedData()
            local setup = companionData
                and companionData.setups[MHCWL.inspectIndex or 0]

            return setup and setup.useColorWhenFavorite == true
        end,

        set = function(enabled)
            local companionData = MHCWL.GetActiveCompanionSavedData()
            local setup = companionData
                and companionData.setups[MHCWL.inspectIndex or 0]

            if not setup then return end

            setup.useColorWhenFavorite = enabled == true

            MHCWL.RefreshWindow()
            MHCWL.RefreshInspectWindow(MHCWL.inspectIndex)
        end,
    })
    return rows
end

function MHCWL.CreateLoadoutColorDropdown()
    local rows = MHCWL.BuildLoadoutColorDropdownRows()

    MHCWL.loadoutColorDropdown = MHCWL.CreateDropdown({
        name = "MHCWLLoadoutColorDropdown",
        anchorPoint = TOPLEFT,
        anchorTo = MHCWL.inspectWindow.colorButton,
        relativePoint = BOTTOMLEFT,
        offsetX = 0,
        offsetY = 4,
        extraWidth = 0,
        rows = rows,
    })
end

function MHCWL.RefreshLoadoutColorDropdown()
    if not MHCWL.loadoutColorDropdown then
        return
    end

    local wasHidden = MHCWL.loadoutColorDropdown:IsHidden()
    local rows = MHCWL.BuildLoadoutColorDropdownRows()

    MHCWL.loadoutColorDropdown:Rebuild(rows)
    MHCWL.loadoutColorDropdown:SetHidden(wasHidden)
end

function MHCWL.CreateHeader(parent, width, height)
    local header = WINDOW_MANAGER:CreateControl(nil, parent, CT_BACKDROP)

    header:SetDimensions(width, height)
    header:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
    MHCWL.StylePanelBackdrop(header)

    return header
end

function MHCWL.CreateFooter(parent, width, height, anchorPoint, relativePoint, offsetX, offsetY)
    local footer = WINDOW_MANAGER:CreateControl(nil, parent, CT_BACKDROP)

    footer:SetDimensions(width - 2, height)

    footer:SetAnchor(
        anchorPoint or BOTTOMLEFT,
        parent,
        relativePoint or BOTTOMLEFT,
        offsetX or 1,
        offsetY or -1
    )

    MHCWL.StylePanelBackdrop(footer)

    return footer
end