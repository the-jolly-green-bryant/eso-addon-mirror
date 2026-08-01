-- ============================================================================
-- Companion Wardrobe
-- Dialog Windows
--
-- Responsibilities:
-- - Show rename, import, and export dialogs/windows.
-- - Provide shared dialog window helpers.
-- - Manage import/export option checkboxes and action buttons.
-- - Keep dialog position and state consistent across openings.
--
-- IMPORTANT:
-- Dialog windows intentionally use DT_MEDIUM.
--
-- DT_HIGH caused ESO dropdowns and tooltips to render behind dialogs.
-- Use DT_HIGH only for windows that must appear above all popup UI.
-- ============================================================================
if MHCWL == nil then MHCWL = {} end
local MHCWL = MHCWL

function MHCWL.RegisterRenameDialog()
    local dialogName = "MHCWLRenameLoadoutDialog"

    if ESO_Dialogs[dialogName] then
        return
    end

    ESO_Dialogs[dialogName] = {
        canQueue = true,
        uniqueIdentifier = dialogName,
        title = { text = GetString(MHCWL_WINDOW_RENAME_TITLE) },
        mainText = { text = GetString(MHCWL_RENAME_TEXT) },
        editBox = {},
        buttons = {
            [1] = {
                text = SI_DIALOG_CONFIRM,
                callback = function(dialog)
                    local index = dialog.data and dialog.data.index
                    if not index then return end

                    local input = ZO_Dialogs_GetEditBoxText(dialog)
                    input = zo_strtrim(tostring(input or ""))

                    if input ~= "" then
                        MHCWL.RenameSetup(index, input)
                        MHCWL.RefreshWindow()
                        MHCWL.RefreshOpenInspectWindow()
                    end
                end,
            },
            [2] = {
                text = SI_DIALOG_CANCEL,
            },
        },
    }
end

function MHCWL.ShowRenameDialog(index)
    local companionData = MHCWL.GetActiveCompanionSavedData()
    if not companionData then return end

    MHCWL.EnsureCompanionSetups(companionData)

    local setup = companionData.setups[index]
    if not setup then return end

    if setup.locked then
        MHCWL.Debug("Loadout is locked.")
        MHCWL.Notify(GetString(MHCWL_NOTIFY_LOCKED))
        return
    end

    local dialogName = "MHCWLRenameLoadoutDialog"

    MHCWL.RegisterRenameDialog()

    ZO_Dialogs_ShowDialog(dialogName, {
        index = index,
    }, {
        mainTextParams = {},
        initialEditText = setup.name,
    })

    zo_callLater(function()
        local dialog = ZO_Dialogs_FindDialog(dialogName)

        if dialog and MHCWL.window then
            dialog:ClearAnchors()
            dialog:SetAnchor(TOPLEFT, MHCWL.window, TOPRIGHT, 8, 0)
        end
    end, 1)
end

function MHCWL.RefreshExportText()
    local window = MHCWL.exportWindow
    if not window or not window.editBox then return end

    local data = MHCWL.BuildExportData(
        window.targetIndex,
        window.includeGear,
        window.includeSkills
    )

    if not data then
        window.editBox:SetText("")
        return
    end

    window.editBox:SetText(MHCWL.SerializeExport(data))
end

function MHCWL.CreateBaseDialogWindow(key, windowName, titleStringId, width, height)
    MHCWL.saved.settings.dialogs = MHCWL.saved.settings.dialogs or {}
    MHCWL.saved.settings.dialogs[key] = MHCWL.saved.settings.dialogs[key] or {}

    local saved = MHCWL.saved.settings.dialogs[key]

    local window = WINDOW_MANAGER:CreateTopLevelWindow(windowName)
    window:SetDimensions(width, height)

    if saved.left and saved.top then
        window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, saved.left, saved.top)
    else
        window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end

    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)
    window:SetDrawLayer(DL_OVERLAY)
    window:SetDrawTier(DT_MEDIUM)
    window:SetDrawLevel(10)

    window:SetHandler("OnMoveStop", function(self)
        saved.left = self:GetLeft()
        saved.top = self:GetTop()
    end)

    local bg = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    bg:SetAnchorFill(window)
    MHCWL.StyleDialogBackdrop(bg)

    local title = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    window.title = title
    title:SetFont(MHCWL.FONTS.header)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 16, 12)
    title:SetText(GetString(titleStringId))

    local close = MHCWL.CreateIconButton(
        window,
        0,
        0,
        20,
        MHCWL.BUTTONS.close,
        function()
            return MHCWL.GetTutorialTooltip(
                MHCWL_TOOLTIP_CLOSE,
                MHCWL_TOOLTIP_CLOSE_TUTORIAL
            )
        end,
        function()
            window:SetHidden(true)
        end,
        MHCWL.ICON_BUTTON_COLORS
    )

    window.closeButton = close
    close:ClearAnchors()
    close:SetAnchor(TOPRIGHT, window, TOPRIGHT, -12, 12)

    return window
end

function MHCWL.CreateDialogInfoLabel(parent, textStringId)
    local info = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)

    info:SetFont(MHCWL.FONTS.game)
    info:SetAnchor(TOPLEFT, parent, TOPLEFT, 16, 48)
    info:SetText(GetString(textStringId))

    return info
end

function MHCWL.CreateDialogEditBox(parent, editBoxName)
    local textBG = WINDOW_MANAGER:CreateControl(nil, parent, CT_BACKDROP)
    textBG:SetDimensions(590, 320)
    textBG:SetAnchor(TOPLEFT, parent, TOPLEFT, 14, 74)
    textBG:SetMouseEnabled(true)
    textBG:SetHandler("OnMouseDown", function()
        edit:TakeFocus()
    end)
    
    MHCWL.StyleEditBoxBackdrop(textBG)

    local edit = WINDOW_MANAGER:CreateControl(editBoxName, textBG, CT_EDITBOX)

    edit:SetDimensions(570, 300)
    edit:SetAnchor(TOPLEFT, textBG, TOPLEFT, 10, 10)
    edit:SetFont(MHCWL.FONTS.game)
    edit:SetMultiLine(true)
    edit:SetMaxInputChars(20000)
    edit:SetMouseEnabled(true)
    edit:SetEditEnabled(true)
    edit:SetText("")

    edit:SetHandler("OnMouseDown", function(self)
        self:TakeFocus()
    end)

    edit:SetHandler("OnMouseWheel", function(self, delta)
        if delta > 0 then
            self:SetCursorPosition(math.max(0, self:GetCursorPosition() - 100))
        else
            self:SetCursorPosition(self:GetCursorPosition() + 100)
        end
    end)

    return edit, textBG
end

function MHCWL.FitDialogCheckbox(row)
    local textWidth = row.label:GetTextDimensions() or 0
    row.button:SetDimensions(18 + 15 + textWidth + 8, 24)
end

function MHCWL.ShowExportDialog(index)
    index = tonumber(index)

    local data = MHCWL.BuildExportData(index, true, true)
    if not data then
        MHCWL.Debug("Could not build export data.")
        MHCWL.Notify(GetString(MHCWL_NOTIFY_EXPORT_FAILED))
        return
    end

    if not MHCWL.exportWindow then
        local windowWidth = 620
        local windowHeight = 470
        local footerHeight = 42

        local window = MHCWL.CreateBaseDialogWindow(
            "export",
            "MHCWLExportWindow",
            MHCWL_WINDOW_EXPORT_TITLE,
            windowWidth,
            windowHeight
        )

        MHCWL.exportWindow = window

        window.info = MHCWL.CreateDialogInfoLabel(
            window,
            MHCWL_WINDOW_EXPORT_INFO
        )

        window.editBox = MHCWL.CreateDialogEditBox(
            window,
            "MHCWLExportEditBox"
        )

        local footer = MHCWL.CreateFooter(window, windowWidth, footerHeight)
        window.footer = footer

        window.includeGear = true
        window.includeSkills = true

        local function RefreshExportOptions()
            window.gearCheckbox.enabled = window.includeGear
            window.skillsCheckbox.enabled = window.includeSkills

            window.gearCheckbox.Refresh(window.gearCheckbox.enabled)
            window.skillsCheckbox.Refresh(window.skillsCheckbox.enabled)

            MHCWL.RefreshExportText()
        end

        window.gearCheckbox = MHCWL.CreateCheckboxButton(
            footer,
            14,
            0,
            GetString(MHCWL_WINDOW_OPTIONS_EXPORT_GEAR),
            true,
            function(enabled)
                window.includeGear = enabled

                if not window.includeGear and not window.includeSkills then
                    window.includeSkills = true
                end

                RefreshExportOptions()
            end,
            function()
                return MHCWL.GetTutorialTooltip(
                    MHCWL_WINDOW_OPTIONS_EXPORT_GEAR_TOOLTIP,
                    MHCWL_WINDOW_OPTIONS_EXPORT_GEAR_TOOLTIP_TUTORIAL
                )
            end
        )

        MHCWL.FitDialogCheckbox(window.gearCheckbox)

        window.skillsCheckbox = MHCWL.CreateCheckboxButton(
            footer,
            14,
            0,
            GetString(MHCWL_WINDOW_OPTIONS_EXPORT_SKILLS),
            true,
            function(enabled)
                window.includeSkills = enabled

                if not window.includeGear and not window.includeSkills then
                    window.includeGear = true
                end

                RefreshExportOptions()
            end,
            function()
                return MHCWL.GetTutorialTooltip(
                    MHCWL_WINDOW_OPTIONS_EXPORT_SKILLS_TOOLTIP,
                    MHCWL_WINDOW_OPTIONS_EXPORT_SKILLS_TOOLTIP_TUTORIAL
                )
            end
        )

        MHCWL.FitDialogCheckbox(window.skillsCheckbox)

        window.skillsCheckbox.button:ClearAnchors()
        window.skillsCheckbox.button:SetAnchor(LEFT, window.gearCheckbox.button, RIGHT, 14, 0)

        local selectAllButton = MHCWL.CreateSquareButton(
            footer,
            120,
            25,
            GetString(MHCWL_WINDOW_EXPORT_DIALOG_SELECT_ALL),
            function()
                if window.editBox then
                    window.editBox:TakeFocus()
                    window.editBox:SelectAll()
                    MHCWL.Notify(GetString(MHCWL_NOTIFY_EXPORT_SELECTED))
                end
            end,
            function()
                return MHCWL.GetTutorialTooltip(
                    MHCWL_WINDOW_EXPORT_DIALOG_SELECT_ALL_TOOLTIP,
                    MHCWL_WINDOW_EXPORT_DIALOG_SELECT_ALL_TOOLTIP_TUTORIAL
                )
            end
        )

        window.selectAllButton = selectAllButton
        selectAllButton:SetAnchor(RIGHT, footer, RIGHT, -18, 0)
    end

    MHCWL.exportWindow.targetIndex = index
    MHCWL.exportWindow.includeGear = true
    MHCWL.exportWindow.includeSkills = true

    if MHCWL.exportWindow.gearCheckbox
    and MHCWL.exportWindow.skillsCheckbox then
        MHCWL.exportWindow.gearCheckbox.enabled = true
        MHCWL.exportWindow.skillsCheckbox.enabled = true

        MHCWL.exportWindow.gearCheckbox.Refresh(true)
        MHCWL.exportWindow.skillsCheckbox.Refresh(true)
    end

    MHCWL.exportWindow:SetHidden(false)
    MHCWL.exportWindow:BringWindowToTop()

    zo_callLater(function()
        if not MHCWL.exportWindow
        or MHCWL.exportWindow:IsHidden()
        or not MHCWL.exportWindow.editBox then
            return
        end

        MHCWL.RefreshExportText()
        MHCWL.exportWindow.editBox:TakeFocus()
        MHCWL.exportWindow.editBox:SelectAll()
    end, 100)
end

function MHCWL.ShowImportDialog(index, overwrite)
    index = tonumber(index)
    overwrite = overwrite == true

    if not MHCWL.importWindow then
        local windowWidth = 620
        local windowHeight = 470
        local footerHeight = 42

        local window = MHCWL.CreateBaseDialogWindow(
            "import",
            "MHCWLImportWindow",
            MHCWL_WINDOW_IMPORT_TITLE,
            windowWidth,
            windowHeight
        )

        MHCWL.importWindow = window

        window.info = MHCWL.CreateDialogInfoLabel(
            window,
            MHCWL_WINDOW_IMPORT_INFO
        )

        window.editBox = MHCWL.CreateDialogEditBox(
            window,
            "MHCWLImportEditBox"
        )

        local footer = MHCWL.CreateFooter(window, windowWidth, footerHeight)
        window.footer = footer

        window.importGear = true
        window.importSkills = true

        local function RefreshImportOptions()
            window.gearCheckbox.enabled = window.importGear
            window.skillsCheckbox.enabled = window.importSkills

            window.gearCheckbox.Refresh(window.gearCheckbox.enabled)
            window.skillsCheckbox.Refresh(window.skillsCheckbox.enabled)
        end

        window.gearCheckbox = MHCWL.CreateCheckboxButton(
            footer,
            14,
            0,
            GetString(MHCWL_WINDOW_OPTIONS_IMPORT_GEAR),
            true,
            function(enabled)
                window.importGear = enabled

                if not window.importGear and not window.importSkills then
                    window.importSkills = true
                end

                RefreshImportOptions()
            end,
            function()
                return MHCWL.GetTutorialTooltip(
                    MHCWL_WINDOW_OPTIONS_IMPORT_GEAR_TOOLTIP,
                    MHCWL_WINDOW_OPTIONS_IMPORT_GEAR_TOOLTIP_TUTORIAL
                )
            end
        )

        MHCWL.FitDialogCheckbox(window.gearCheckbox)

        window.skillsCheckbox = MHCWL.CreateCheckboxButton(
            footer,
            120,
            0,
            GetString(MHCWL_WINDOW_OPTIONS_IMPORT_SKILLS),
            true,
            function(enabled)
                window.importSkills = enabled

                if not window.importGear and not window.importSkills then
                    window.importGear = true
                end

                RefreshImportOptions()
            end,
            function()
                return MHCWL.GetTutorialTooltip(
                    MHCWL_WINDOW_OPTIONS_IMPORT_SKILLS_TOOLTIP,
                    MHCWL_WINDOW_OPTIONS_IMPORT_SKILLS_TOOLTIP_TUTORIAL
                )
            end
        )

        MHCWL.FitDialogCheckbox(window.skillsCheckbox)

        window.skillsCheckbox.button:ClearAnchors()
        window.skillsCheckbox.button:SetAnchor(LEFT, window.gearCheckbox.button, RIGHT, 14, 0)

        window.favoriteCheckbox = MHCWL.CreateCheckboxButton(
            footer,
            260,
            0,
            GetString(MHCWL_WINDOW_OPTIONS_IMPORT_FAVORITE),
            false,
            function(enabled)
                window.importAsFavorite = enabled
                window.favoriteCheckbox.enabled = enabled
                window.favoriteCheckbox.Refresh(enabled)
            end,
            function()
                return MHCWL.GetTutorialTooltip(
                    MHCWL_WINDOW_OPTIONS_IMPORT_FAVORITE_TOOLTIP,
                    MHCWL_WINDOW_OPTIONS_IMPORT_FAVORITE_TOOLTIP_TUTORIAL
                )
            end
        )

        MHCWL.FitDialogCheckbox(window.favoriteCheckbox)

        window.favoriteCheckbox.button:ClearAnchors()
        window.favoriteCheckbox.button:SetAnchor(LEFT, window.skillsCheckbox.button, RIGHT, 34, 0)

        local importButton = MHCWL.CreateSquareButton(
            footer,
            120,
            25,
            GetString(MHCWL_WINDOW_IMPORT_BUTTON),
            function()
                local text = window.editBox:GetText()

                local data, errorText = MHCWL.ParseImportText(text)

                if not data then
                    MHCWL.Notify(errorText or GetString(MHCWL_NOTIFY_IMPORT_FAILED))
                    MHCWL.Debug(errorText or "Import failed.")
                    return
                end

                local success, result = MHCWL.ApplyImportedLoadout(
                    data,
                    window.targetIndex,
                    window.overwrite,
                    window.importGear,
                    window.importSkills,
                    window.importAsFavorite
                )

                if not success then
                    MHCWL.Notify(result or GetString(MHCWL_NOTIFY_IMPORT_FAILED))
                    MHCWL.Debug(result or "Import failed.")
                    return
                end

                window:SetHidden(true)

                MHCWL.RebuildWindowContent()
                MHCWL.RefreshOpenInspectWindow()

                MHCWL.LoadAndVerify()

                local importedName = data.loadout.name or GetString(MHCWL_IMPORTED_LOADOUT)

                MHCWL.Notify(GetString(MHCWL_NOTIFY_IMPORTED) .. tostring(importedName))
                MHCWL.Debug("Imported loadout into slot " .. tostring(result) .. ".")
            end,
            function()
                return MHCWL.GetTutorialTooltip(
                    MHCWL_WINDOW_IMPORT_BUTTON_TOOLTIP,
                    MHCWL_WINDOW_IMPORT_BUTTON_TOOLTIP_TUTORIAL
                )
            end
        )

        window.importButton = importButton
        importButton:SetAnchor(RIGHT, footer, RIGHT, -18, 0)
    end

    MHCWL.importWindow.targetIndex = index
    MHCWL.importWindow.overwrite = overwrite

    MHCWL.importWindow.importGear = true
    MHCWL.importWindow.importSkills = true
    MHCWL.importWindow.importAsFavorite = false

    if MHCWL.importWindow.gearCheckbox
    and MHCWL.importWindow.skillsCheckbox
    and MHCWL.importWindow.favoriteCheckbox then
        MHCWL.importWindow.gearCheckbox.enabled = true
        MHCWL.importWindow.skillsCheckbox.enabled = true
        MHCWL.importWindow.favoriteCheckbox.enabled = false

        MHCWL.importWindow.gearCheckbox.Refresh(true)
        MHCWL.importWindow.skillsCheckbox.Refresh(true)
        MHCWL.importWindow.favoriteCheckbox.Refresh(false)
    end

    if overwrite then
        MHCWL.importWindow.info:SetText(
            GetString(MHCWL_WINDOW_IMPORT_INFO_OVERWRITE)
        )
    else
        MHCWL.importWindow.info:SetText(
            GetString(MHCWL_WINDOW_IMPORT_INFO_CREATE)
        )
    end

    MHCWL.importWindow.editBox:SetText("")
    MHCWL.importWindow:SetHidden(false)
    MHCWL.importWindow:BringWindowToTop()

    zo_callLater(function()
        if not MHCWL.importWindow
        or MHCWL.importWindow:IsHidden()
        or not MHCWL.importWindow.editBox then
            return
        end

        MHCWL.importWindow.editBox:TakeFocus()
    end, 100)
end