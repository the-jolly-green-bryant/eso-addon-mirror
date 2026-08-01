(function()
    return function(Addon)
        Addon.UI = Addon.UI or {}
    
        local UI = Addon.UI
        local MAX_ROWS = 6
        local OPEN_SELECTOR_KEYBIND = "UI_SHORTCUT_SECONDARY"
        local SELECT_KEYBIND = "UI_SHORTCUT_PRIMARY"
        local NEXT_KEYBIND = "UI_SHORTCUT_INPUT_DOWN"
        local PREVIOUS_KEYBIND = "UI_SHORTCUT_INPUT_UP"
        local CLOSE_KEYBIND = "UI_SHORTCUT_NEGATIVE"
        local ROOT_DRAW_LEVEL = 220
        local PROMPT_DRAW_LEVEL = 230
        local SELECTOR_DRAW_LEVEL = 240
        local ROOT_ANCHOR_RELATIVE_POINT = _G.CENTER
        local ROOT_ANCHOR_OFFSET_X = 50
        local ROOT_ANCHOR_OFFSET_Y = 182
    
        local function debugValue(value)
            if value == nil or value == "" then
                return "<nil>"
            end
    
            return tostring(value)
        end
    
        local function boolValue(value)
            return tostring(value == true)
        end
    
        local function updateDebugSection(source)
            if not Addon.DebugOverlay or not Addon.DebugOverlay.SetSection then
                return
            end
    
            local rootHidden = UI.root and UI.root.IsHidden and UI.root:IsHidden() or true
            local rootAlpha = UI.root and UI.root.GetAlpha and UI.root:GetAlpha() or 0
            local hintHidden = UI.promptHint and UI.promptHint.IsHidden and UI.promptHint:IsHidden() or true
            local rootDrawLevel = UI.root and UI.root.GetDrawLevel and UI.root:GetDrawLevel() or -1
            local promptDrawLevel = UI.prompt and UI.prompt.GetDrawLevel and UI.prompt:GetDrawLevel() or -1
            local selectorDrawLevel = UI.selector and UI.selector.GetDrawLevel and UI.selector:GetDrawLevel() or -1
    
            Addon.DebugOverlay.SetSection("ui", "Prompt UI", {
                string.format(
                    "source=%s visible=%s selector=%s canOpen=%s",
                    debugValue(source),
                    boolValue(UI.isVisible),
                    boolValue(UI.selectorVisible),
                    boolValue(UI.canOpenSelector)
                ),
                string.format(
                    "hidden=%s alpha=%s hintHidden=%s",
                    boolValue(rootHidden),
                    string.format("%.2f", rootAlpha),
                    boolValue(hintHidden)
                ),
                string.format(
                    "draw root=%s prompt=%s selector=%s",
                    tostring(rootDrawLevel),
                    tostring(promptDrawLevel),
                    tostring(selectorDrawLevel)
                ),
                string.format(
                    "state=%s | hint=%s",
                    debugValue(UI.model and UI.model.promptStateText),
                    debugValue(UI.model and UI.model.promptHintText)
                ),
            })
        end
    
        local function applyRootAnchor()
            local anchorTarget = _G.ZO_ReticleContainer or GuiRoot
    
            if not UI.root or not UI.root.ClearAnchors or not UI.root.SetAnchor or not anchorTarget then
                return
            end
    
            UI.root:ClearAnchors()
            UI.root:SetAnchor(TOPLEFT, anchorTarget, ROOT_ANCHOR_RELATIVE_POINT, ROOT_ANCHOR_OFFSET_X, ROOT_ANCHOR_OFFSET_Y)
        end
    
        local function getRowSelectionIndex(rows, preferredLureIndex)
            for index, rowData in ipairs(rows) do
                if rowData.lureIndex == preferredLureIndex then
                    return index
                end
            end
    
            return 1
        end
    
        local function updateFadeVisibility(isVisible)
            if not UI.root then
                return
            end
    
            if isVisible then
                if not UI.root.IsHidden or UI.root:IsHidden() then
                    applyRootAnchor()
                end
                UI.root:SetHidden(false)
                UI.root:SetAlpha(1)
                return
            else
                UI.root:SetAlpha(0)
                UI.root:SetHidden(true)
            end
        end
    
        local function applyOverlayDrawOrder(control, drawLevel)
            if not control then
                return
            end
    
            if control.SetDrawLayer then
                control:SetDrawLayer(DL_OVERLAY)
            end
    
            if control.SetDrawTier then
                control:SetDrawTier(DT_HIGH)
            end
    
            if control.SetDrawLevel then
                control:SetDrawLevel(drawLevel)
            end
        end
    
        local function setLabelColor(label, colorValues)
            if not label or not colorValues then
                return
            end
    
            label:SetColor(colorValues[1], colorValues[2], colorValues[3], 1)
        end
    
        local function applyStaticStyles()
            if not UI.promptName or not UI.promptCount or not UI.promptHint or not UI.selectorTitle then
                return
            end
    
            UI.promptName:SetColor(0.95, 0.95, 0.92, 1)
            UI.promptCount:SetColor(0.95, 0.95, 0.92, 1)
            UI.promptCount:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            UI.promptHint:SetColor(0.76, 0.84, 0.92, 1)
            UI.selectorTitle:SetColor(0.95, 0.95, 0.92, 1)
    
            for index = 1, MAX_ROWS do
                local rowControl = UI.selectorRows[index]
                if rowControl and rowControl.count then
                    rowControl.count:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
                end
            end
        end
    
        local function buildCountText(count)
            return "x" .. tostring(count or 0)
        end
    
        local function isNativeFishingWheelOpen()
            return type(FISHING_GAMEPAD) == "table"
                and type(FISHING_GAMEPAD.IsInteracting) == "function"
                and FISHING_GAMEPAD:IsInteracting()
        end
    
        local function tryOpenNativeFishingWheel()
            if type(FISHING_GAMEPAD) ~= "table"
                or type(FISHING_GAMEPAD.PrepareForInteraction) ~= "function"
                or type(FISHING_GAMEPAD.ShowMenu) ~= "function"
            then
                return false
            end
    
            if not FISHING_GAMEPAD:PrepareForInteraction() then
                return false
            end
    
            if not isNativeFishingWheelOpen() then
                FISHING_GAMEPAD:ShowMenu()
            end
            return true
        end
    
        local function setKeybindGroup(keybindGroup, flagName, shouldShow)
            if not KEYBIND_STRIP or not keybindGroup then
                return
            end
    
            if shouldShow and not UI[flagName] then
                KEYBIND_STRIP:AddKeybindButtonGroup(keybindGroup)
                UI[flagName] = true
            elseif not shouldShow and UI[flagName] then
                KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindGroup)
                UI[flagName] = false
            elseif shouldShow and UI[flagName] then
                KEYBIND_STRIP:UpdateKeybindButtonGroup(keybindGroup)
            end
        end
    
        local function refreshKeybinds()
            local nativeWheelOpen = isNativeFishingWheelOpen()
            local canOpenSelector = UI.isVisible and not UI.selectorVisible and UI.canOpenSelector and not nativeWheelOpen
            local showingSelector = UI.isVisible and UI.selectorVisible and not nativeWheelOpen
    
            setKeybindGroup(UI.promptKeybindStripDescriptor, "isPromptKeybindRegistered", canOpenSelector)
            setKeybindGroup(UI.selectorKeybindStripDescriptor, "isSelectorKeybindRegistered", showingSelector)
        end
    
        local function renderSelectorRows()
            if not UI.selectorRows then
                return
            end
    
            local rows = UI.model and UI.model.rows or {}
    
            for index = 1, MAX_ROWS do
                local rowControl = UI.selectorRows[index]
                local rowData = rows[index]
    
                if rowData then
                    rowControl.control:SetHidden(false)
                    rowControl.label:SetText(rowData.name)
                    rowControl.count:SetText(buildCountText(rowData.count))
                    rowControl.highlight:SetHidden(index ~= UI.selectedIndex)
                    rowControl.label:SetColor(0.95, 0.95, 0.92, 1)
                    rowControl.count:SetColor(0.95, 0.95, 0.92, 1)
                else
                    rowControl.control:SetHidden(true)
                end
            end
        end
    
        function UI.Initialize(control)
            UI.root = control
            UI.prompt = control:GetNamedChild("Prompt")
            UI.promptIcon = UI.prompt:GetNamedChild("Icon")
            UI.promptName = UI.prompt:GetNamedChild("Name")
            UI.promptCount = UI.prompt:GetNamedChild("Count")
            UI.promptState = UI.prompt:GetNamedChild("State")
            UI.promptHint = UI.prompt:GetNamedChild("Hint")
            UI.selector = control:GetNamedChild("Selector")
            UI.selectorTitle = UI.selector:GetNamedChild("Title")
            UI.fadeAnimation = ZO_AlphaAnimation:New(control)
            UI.selectorRows = {}
    
            for index = 1, MAX_ROWS do
                local rowControl = UI.selector:GetNamedChild("Row" .. tostring(index))
                UI.selectorRows[index] = {
                    control = rowControl,
                    count = rowControl:GetNamedChild("Count"),
                    highlight = rowControl:GetNamedChild("Highlight"),
                    label = rowControl:GetNamedChild("Label"),
                }
            end
    
            if UI.root.SetTopmost then
                UI.root:SetTopmost(true)
            end
    
            if UI.root.SetClampedToScreen then
                UI.root:SetClampedToScreen(true)
            end
    
            applyRootAnchor()
    
            applyOverlayDrawOrder(UI.root, ROOT_DRAW_LEVEL)
            applyOverlayDrawOrder(UI.prompt, PROMPT_DRAW_LEVEL)
            applyOverlayDrawOrder(UI.selector, SELECTOR_DRAW_LEVEL)
            applyOverlayDrawOrder(UI.promptIcon, PROMPT_DRAW_LEVEL + 1)
            applyOverlayDrawOrder(UI.promptName, PROMPT_DRAW_LEVEL + 2)
            applyOverlayDrawOrder(UI.promptCount, PROMPT_DRAW_LEVEL + 2)
            applyOverlayDrawOrder(UI.promptState, PROMPT_DRAW_LEVEL + 2)
            applyOverlayDrawOrder(UI.promptHint, PROMPT_DRAW_LEVEL + 2)
            applyOverlayDrawOrder(UI.selectorTitle, SELECTOR_DRAW_LEVEL + 1)
    
            for index = 1, MAX_ROWS do
                local rowControl = UI.selectorRows[index]
    
                applyOverlayDrawOrder(rowControl.control, SELECTOR_DRAW_LEVEL + 1)
                applyOverlayDrawOrder(rowControl.highlight, SELECTOR_DRAW_LEVEL + 2)
                applyOverlayDrawOrder(rowControl.label, SELECTOR_DRAW_LEVEL + 3)
                applyOverlayDrawOrder(rowControl.count, SELECTOR_DRAW_LEVEL + 3)
            end
    
            UI.promptKeybindStripDescriptor = {
                {
                    alignment = KEYBIND_STRIP_ALIGN_RIGHT,
                    keybind = OPEN_SELECTOR_KEYBIND,
                    name = function()
                        return Addon.Strings.selectBait
                    end,
                    callback = function()
                        if UI.openSelectorHandler then
                            UI.openSelectorHandler()
                        end
                    end,
                },
            }
    
            UI.selectorKeybindStripDescriptor = {
                {
                    alignment = KEYBIND_STRIP_ALIGN_RIGHT,
                    keybind = SELECT_KEYBIND,
                    name = function()
                        return Addon.Strings.setBait
                    end,
                    callback = function()
                        UI.ConfirmSelection()
                    end,
                },
                {
                    keybind = NEXT_KEYBIND,
                    ethereal = true,
                    name = "TheArtaeumAnglerNext",
                    callback = function()
                        UI.MoveSelection(1)
                    end,
                },
                {
                    keybind = PREVIOUS_KEYBIND,
                    ethereal = true,
                    name = "TheArtaeumAnglerPrevious",
                    callback = function()
                        UI.MoveSelection(-1)
                    end,
                },
                {
                    alignment = KEYBIND_STRIP_ALIGN_RIGHT,
                    keybind = CLOSE_KEYBIND,
                    name = function()
                        return Addon.Strings.close
                    end,
                    callback = function()
                        UI.CloseBaitSelector()
                    end,
                },
            }
    
            UI.root:SetHidden(true)
            applyStaticStyles()
            updateDebugSection("initialize")
    
            if UI.model then
                UI.UpdateReticlePrompt(UI.model)
            end
        end
    
        function UI.SetOpenSelectorHandler(handler)
            UI.openSelectorHandler = handler
        end
    
        function UI.SetConfirmSelectionHandler(handler)
            UI.confirmSelectionHandler = handler
        end
    
        function UI.UpdateReticlePrompt(model)
            UI.model = model
            UI.canOpenSelector = model and model.allowSelector ~= false or false
            UI.isVisible = model ~= nil
    
            if not UI.root or not model then
                return
            end
    
            UI.promptIcon:SetTexture(model.recommendedIcon or Addon.Textures.emptyBait)
            UI.promptName:SetText(model.recommendedName or Addon.Strings.noBait)
            UI.promptCount:SetText(buildCountText(model.recommendedCount))
            UI.promptState:SetText(model.promptStateText or model.waterTypeLabel or Addon.WaterTypeLabels.unknown)
            UI.promptHint:SetText(model.promptHintText or "")
            UI.promptHint:SetHidden(not model.promptHintText or model.promptHintText == "")
            setLabelColor(UI.promptState, model.promptStateColor or model.stateColor)
            updateFadeVisibility(true)
    
            if UI.selectorVisible then
                renderSelectorRows()
            end
    
            refreshKeybinds()
            updateDebugSection("update_prompt")
        end
    
        function UI.HideReticlePrompt()
            UI.canOpenSelector = false
            UI.isVisible = false
            UI.selectorVisible = false
            UI.model = nil
    
            if UI.selector then
                UI.selector:SetHidden(true)
            end
    
            if UI.promptHint then
                UI.promptHint:SetHidden(true)
            end
    
            refreshKeybinds()
            updateFadeVisibility(false)
            if Addon.DebugOverlay and Addon.DebugOverlay.PushEvent then
                Addon.DebugOverlay.PushEvent("Prompt hidden")
            end
            updateDebugSection("hide_prompt")
        end
    
        function UI.OpenBaitSelector(model)
            if model then
                UI.model = model
            end
    
            if tryOpenNativeFishingWheel() then
                UI.selectorVisible = false
    
                if UI.selector then
                    UI.selector:SetHidden(true)
                end
    
            refreshKeybinds()
            if Addon.DebugOverlay and Addon.DebugOverlay.PushEvent then
                Addon.DebugOverlay.PushEvent("Native bait wheel opened")
            end
            updateDebugSection("open_native_wheel")
            return
            end
    
            if not UI.root or not UI.model or #UI.model.rows == 0 then
                return
            end
    
            UI.selectorVisible = true
            UI.selectedIndex = getRowSelectionIndex(UI.model.rows, UI.model.recommendedLureIndex)
            UI.selectorTitle:SetText(Addon.Strings.chooseBait)
            UI.selector:SetHidden(false)
            renderSelectorRows()
            refreshKeybinds()
            if Addon.DebugOverlay and Addon.DebugOverlay.PushEvent then
                Addon.DebugOverlay.PushEvent("Selector opened")
            end
            updateDebugSection("open_selector")
        end
    
        function UI.CloseBaitSelector()
            UI.selectorVisible = false
    
            if UI.selector then
                UI.selector:SetHidden(true)
            end
    
            refreshKeybinds()
            updateDebugSection("close_selector")
        end
    
        function UI.MoveSelection(direction)
            if not UI.model or #UI.model.rows == 0 then
                return
            end
    
            local rowCount = #UI.model.rows
            UI.selectedIndex = UI.selectedIndex or 1
            UI.selectedIndex = UI.selectedIndex + direction
    
            if UI.selectedIndex < 1 then
                UI.selectedIndex = rowCount
            elseif UI.selectedIndex > rowCount then
                UI.selectedIndex = 1
            end
    
            renderSelectorRows()
            refreshKeybinds()
        end
    
        function UI.ConfirmSelection()
            if not UI.model or not UI.confirmSelectionHandler then
                return
            end
    
            local selectedRow = UI.model.rows[UI.selectedIndex or 1]
    
            if not selectedRow then
                return
            end
    
            UI.confirmSelectionHandler(selectedRow)
            UI.CloseBaitSelector()
            updateDebugSection("confirm_selection")
        end
    end
    
end)()(_G["TheArtaeumAngler"])
