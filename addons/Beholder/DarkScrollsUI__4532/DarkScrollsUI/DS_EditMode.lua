-----------------------------------------------------------
-- DarkScrollsUI - DS_EditMode.lua
-- Individual edit mode (/ds) and group edit mode (/dsall):
-- snap-to-grid, mouse wheel resizing, GlobalFrame overlay.
-----------------------------------------------------------

-----------------------------------------------------------
-- SNAP & PERSISTENCE
-----------------------------------------------------------
local function SnapToGrid(value)
    local gridSize = 10
    return math.floor((value / gridSize) + 0.5) * gridSize
end

local function UpdateGuideLines(show)
    local wm    = WINDOW_MANAGER
    local hLine = _G["DarkScrollsUI_EditModeHorizontalGuideLine"]
    local vLine = _G["DarkScrollsUI_EditModeVerticalGuideLine"]

    if show then
        if not hLine then
            hLine = wm:CreateControl("DarkScrollsUI_EditModeHorizontalGuideLine", GuiRoot, CT_TOPLEVELCONTROL)
            hLine:SetDrawLayer(DL_OVERLAY)
            hLine:SetDrawTier(DT_TOP)
            hLine:SetMouseEnabled(false)
            hLine.bg = wm:CreateControl("DarkScrollsUI_EditModeHorizontalGuideLineBackground", hLine, CT_BACKDROP)
            hLine.bg:SetAnchorFill()
            hLine.bg:SetCenterColor(1, 1, 1, 0.4)
            hLine.bg:SetEdgeColor(0, 0, 0, 0)
        end
        if not vLine then
            vLine = wm:CreateControl("DarkScrollsUI_EditModeVerticalGuideLine", GuiRoot, CT_TOPLEVELCONTROL)
            vLine:SetDrawLayer(DL_OVERLAY)
            vLine:SetDrawTier(DT_TOP)
            vLine:SetMouseEnabled(false)
            vLine.bg = wm:CreateControl("DarkScrollsUI_EditModeVerticalGuideLineBackground", vLine, CT_BACKDROP)
            vLine.bg:SetAnchorFill()
            vLine.bg:SetCenterColor(1, 1, 1, 0.4)
            vLine.bg:SetEdgeColor(0, 0, 0, 0)
        end

        local w, h = GuiRoot:GetDimensions()

        hLine:ClearAnchors()
        hLine:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        hLine:SetDimensions(w, 2)
        hLine:SetHidden(false)

        vLine:ClearAnchors()
        vLine:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        vLine:SetDimensions(2, h)
        vLine:SetHidden(false)
    else
        if hLine then hLine:SetHidden(true) end
        if vLine then vLine:SetHidden(true) end
    end
end

function DarkScrollsUI.ResetEditModeTimer()
    DarkScrollsUI.lastEditActivityTime = GetFrameTimeSeconds()
end

function DarkScrollsUI.SaveElementControlChanges(control, bypassGrid, explicitX, explicitY, explicitW, explicitH)
    local name = control:GetName()
    if not DarkScrollsUI.SavedVariables[name] then DarkScrollsUI.SavedVariables[name] = {} end

    local oldData     = DarkScrollsUI.SavedVariables[name]
    local snappedLeft = explicitX or control:GetLeft()
    local snappedTop  = explicitY or control:GetTop()
    local w = explicitW or control:GetWidth()
    local h = explicitH or control:GetHeight()

    if not bypassGrid then
        snappedLeft = SnapToGrid(snappedLeft)
        snappedTop  = SnapToGrid(snappedTop)
        control:ClearAnchors()
        control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, snappedLeft, snappedTop)
    end

    DarkScrollsUI.SavedVariables[name].l  = snappedLeft
    DarkScrollsUI.SavedVariables[name].t  = snappedTop
    DarkScrollsUI.SavedVariables[name].w  = w
    DarkScrollsUI.SavedVariables[name].h  = h
    DarkScrollsUI.SavedVariables[name].a  = oldData.a or control:GetAlpha()
    DarkScrollsUI.SavedVariables[name].r  = control.rotation or oldData.r or 0
    DarkScrollsUI.SavedVariables[name].fs = oldData.fs or 1

    DarkScrollsUI.ResetEditModeTimer()
end

-----------------------------------------------------------
-- BAR RESET
-----------------------------------------------------------
function DarkScrollsUI.ResetAllAttributeBars()
    local current = DarkScrollsUI.MasterSavedVariables.currentProfile
    DarkScrollsUI.MasterSavedVariables.profiles[current] = DarkScrollsUI.GetDefaultProfileSettings()
    DarkScrollsUI.SavedVariables = DarkScrollsUI.MasterSavedVariables.profiles[current]
    DarkScrollsUI.DisplayProfileSystemMessage("|cFF0000[Reset]|r Resetting Profile " .. current .. " to Default!")
    zo_callLater(function() ReloadUI() end, 1000)
end

-----------------------------------------------------------
-- TEXT SCALE
-----------------------------------------------------------
function DarkScrollsUI.UpdateElementTextScaleValue(control)
    local name = control:GetName()
    local fs = (DarkScrollsUI.SavedVariables[name] and DarkScrollsUI.SavedVariables[name].fs) or 1

    if control.isQuestTracker then
        local baseWidth = 300
        local currentScale = (control:GetWidth() / baseWidth) * fs
        control.title:SetScale(currentScale)
        -- Labels são gerados dinamicamente pelo pool; basta atualizar o tracker
        if DarkScrollsUI.UpdateQuestTrackerInformation then
            DarkScrollsUI.UpdateQuestTrackerInformation()
        end
        return
    end

    if name == "DarkScrollsUI_PlayerGroupStatusFrame" and control.rows then
        for i = 1, #control.rows do
            if control.rows[i].label then control.rows[i].label:SetScale(fs) end
        end
        return
    end

    if control.timer      then control.timer:SetScale(fs)      end
    if control.ultPercent then control.ultPercent:SetScale(fs) end
    if control.nameLabel  then control.nameLabel:SetScale(fs)  end
    if control.hpLabel    then control.hpLabel:SetScale(fs)    end
    if control.numberLabel then control.numberLabel:SetScale(fs) end

    if name == "DarkScrollsUI_CompassNavigationFrame" and ZO_CompassFrame then
        ZO_CompassFrame:SetScale((control:GetWidth() / 600) * fs)
    end
end

-----------------------------------------------------------
-- MOUSE WHEEL (individual edit)
-----------------------------------------------------------
function DarkScrollsUI.OnMouseWheelInteractionEvent(control, delta)
    if DarkScrollsUI.isInterfaceLocked or DarkScrollsUI.isGlobalEditModeActive then return end

    local name = control:GetName()
    if not DarkScrollsUI.SavedVariables[name] then
        DarkScrollsUI.SavedVariables[name] = {
            a  = control:GetAlpha() or 1,
            w  = control:GetWidth(),
            h  = control:GetHeight(),
            r  = control.rotation or 0,
            fs = 1,
        }
    end

    local isShift   = IsShiftKeyDown()
    local isControl = IsControlKeyDown()
    local isAlt     = IsAltKeyDown()
    local step      = (delta > 0) and 1 or -1
    local skipSnap  = false

    if isControl and isShift then
        -- Rotation
        local newRotation = (DarkScrollsUI.SavedVariables[name].r or 0) + (step * DarkScrollsUI.CONSTANT_PI_QUARTER)
        control.rotation = newRotation
        DarkScrollsUI.SavedVariables[name].r = newRotation
        if control.icon  then control.icon:SetTextureRotation(newRotation)  end
        if control.bgTex then control.bgTex:SetTextureRotation(newRotation) end
        skipSnap = true

    elseif isControl and not isShift and not isAlt then
        -- Font scale
        local newFs = math.max(0.2, (DarkScrollsUI.SavedVariables[name].fs or 1) + (step * 0.1))
        DarkScrollsUI.SavedVariables[name].fs = newFs
        skipSnap = true

    elseif isAlt then
        -- Alpha
        local newAlpha = zo_clamp((DarkScrollsUI.SavedVariables[name].a or control:GetAlpha()) + (step * 0.1), 0.1, 1.0)
        newAlpha = math.floor(newAlpha * 10 + 0.5) / 10
        DarkScrollsUI.SavedVariables[name].a = newAlpha
        control:SetAlpha(newAlpha)
        skipSnap = true

    else
        local isBar     = control.fillTop  ~= nil
        local isTracker = control.iconPool ~= nil
        local isQuest   = control.isQuestTracker ~= nil
        local isGroup   = (name == "DarkScrollsUI_PlayerGroupStatusFrame")

        if isBar then
            if isShift then
                control:SetHeight(math.max(4, control:GetHeight() + (step * 2)))
            else
                control:SetWidth(math.max(10, control:GetWidth() + (step * 2)))
            end
            local newH = control:GetHeight()
            control.fillTop:SetHeight(newH / 2)
            control.fillBottom:SetHeight(newH / 2)

        elseif isTracker or isQuest or isGroup then
            if isShift then
                control:SetHeight(math.max(16, control:GetHeight() + (step * 2)))
            else
                control:SetWidth(math.max(30, control:GetWidth() + (step * 10)))
            end

        elseif name == "DarkScrollsUI_CompassNavigationFrame" then
            if isShift then
                control:SetHeight(math.max(20, control:GetHeight() + (step * 2)))
            else
                control:SetWidth(math.max(100, control:GetWidth() + (step * 10)))
            end

        else
            local speedMultiplier = isShift and 4 or 2
            local newSize = math.max(16, control:GetWidth() + (step * speedMultiplier))
            control:SetWidth(newSize)
            control:SetHeight(newSize)
        end
    end

    DarkScrollsUI.SaveElementControlChanges(control, skipSnap)

    if control.fillTop and control.powerType then
        DarkScrollsUI.UpdateAttributeBarFillValue(control, control.powerType)
    end

    if not control.iconPool then
        DarkScrollsUI.UpdateElementTextScaleValue(control)
    end
end

-----------------------------------------------------------
-- COMMON HANDLER SETUP
-----------------------------------------------------------
function DarkScrollsUI.SetupCommonInterfaceHandlers(control)
    control:SetHandler("OnMoveStop",   function(self) DarkScrollsUI.SaveElementControlChanges(self, false) end)
    control:SetHandler("OnMouseWheel", function(self, delta) DarkScrollsUI.OnMouseWheelInteractionEvent(self, delta) end)
end

-----------------------------------------------------------
-- INDIVIDUAL TOGGLE LOCK (/ds)
-----------------------------------------------------------
function DarkScrollsUI.ToggleInterfaceLockStatus()
    DarkScrollsUI.isInterfaceLocked = not DarkScrollsUI.isInterfaceLocked

    if DarkScrollsUI.isInterfaceLocked then
        if _G["StaminaMontaria"] and not IsMounted() then
            _G["StaminaMontaria"]:SetHidden(true)
        end
    else
        if DarkScrollsUI.isGlobalEditModeActive then DarkScrollsUI.ToggleGlobalEditModeActive() end
        d("DarkScrollsUI: " .. DarkScrollsUI.LocalizationStrings.Unlocked)
        if _G["StaminaMontaria"] then
            _G["StaminaMontaria"]:SetHidden(false)
        end
    end

    local controls = {
        "DarkScrollsUI_PlayerHealthBar", "DarkScrollsUI_PlayerMagickaBar", "DarkScrollsUI_PlayerStaminaBar", 
        "DarkScrollsUI_PlayerShieldBar", "DarkScrollsUI_PlayerMountStaminaBar",
        "DarkScrollsUI_ActionButtonSlotThree", "DarkScrollsUI_ActionButtonSlotFour", "DarkScrollsUI_ActionButtonSlotFive", 
        "DarkScrollsUI_ActionButtonSlotSix", "DarkScrollsUI_ActionButtonSlotSeven", "DarkScrollsUI_UltimateAbilitySlot", 
        "DarkScrollsUI_QuickslotItemSlot", "DarkScrollsUI_PlayerBuffTracker", "DarkScrollsUI_TargetBuffTracker", 
        "DarkScrollsUI_PrimaryWeaponIndicator", "DarkScrollsUI_SecondaryWeaponIndicator", 
        "DarkScrollsUI_CompassNavigationFrame", "DarkScrollsUI_BossHealthBarDisplay", 
        "DarkScrollsUI_BossHealthBarDisplayName", "DarkScrollsUI_BossHealthBarDisplayHP",
        "DarkScrollsUI_TargetHealthBar",
        "DarkScrollsUI_QuestObjectiveTracker", "DarkScrollsUI_PlayerGroupStatusFrame"
    }

    -- Controls that use green highlight in edit mode (they are repositionable containers,
    -- not content bars). Each entry: name -> label shown in the centre of the box.
    local greenControls = {
        ["DarkScrollsUI_CompassNavigationFrame"]    = "COMPASS",
        ["DarkScrollsUI_BossHealthBarDisplayName"]  = "BOSS NAME",
        ["DarkScrollsUI_BossHealthBarDisplayHP"]    = "BOSS HP",
        ["DarkScrollsUI_TargetHealthBar"]           = "TARGET UNIT",
    }

    local editing = not DarkScrollsUI.isInterfaceLocked

    for _, name in ipairs(controls) do
        local ctrl = _G[name]
        if ctrl then
            ctrl:SetMouseEnabled(editing)
            ctrl:SetMovable(editing)
            local isGreen = greenControls[name] ~= nil
            if ctrl.bg then
                if isGreen then
                    ctrl.bg:SetCenterColor(0, 1, 0, editing and 0.4 or 0)
                    ctrl.bg:SetEdgeColor(0, 1, 0, editing and 0.8 or 0)
                else
                    ctrl.bg:SetCenterColor(0, 0, 0, editing and 0.4 or 0)
                end
            end
            -- Create (once) and show/hide an identification label inside each green control
            if isGreen then
                if not ctrl.editLabel then
                    local lbl = WINDOW_MANAGER:CreateControl(name .. "EditLabel", ctrl, CT_LABEL)
                    lbl:SetAnchor(CENTER, ctrl, CENTER, 0, 0)
                    lbl:SetFont("ZoFontWinH5")
                    lbl:SetColor(0, 1, 0, 1)
                    lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
                    lbl:SetText(greenControls[name])
                    lbl:SetDrawLayer(DL_OVERLAY)
                    ctrl.editLabel = lbl
                end
                ctrl.editLabel:SetHidden(not editing)
            end
        end
    end

    if DarkScrollsUI.UpdateWeaponIndicatorIcons then DarkScrollsUI.UpdateWeaponIndicatorIcons() end

    UpdateGuideLines(not DarkScrollsUI.isInterfaceLocked)

    if not DarkScrollsUI.isInterfaceLocked and not DarkScrollsUI.ConfigurationBackupBeforeEdit then DarkScrollsUI.ConfigurationBackupBeforeEdit = ZO_DeepTableCopy(DarkScrollsUI.SavedVariables) end
    if not DarkScrollsUI.isInterfaceLocked then DarkScrollsUI.ResetEditModeTimer() end
    DarkScrollsUI.UpdateEditPanelVisibilityStatus()
end

-----------------------------------------------------------
-- GROUP EDIT (/dsall)
-----------------------------------------------------------
local function GetBoundingBox()
    local minX, minY =  999999,  999999
    local maxX, maxY = -999999, -999999
    for _, name in ipairs(DarkScrollsUI.GetListOfAllControlNames()) do
        local s = DarkScrollsUI.SavedVariables[name]
        if s then
            if s.l         < minX then minX = s.l         end
            if s.t         < minY then minY = s.t         end
            if (s.l + s.w) > maxX then maxX = s.l + s.w  end
            if (s.t + s.h) > maxY then maxY = s.t + s.h  end
        end
    end
    if minX == 999999 then return 100, 100, 500, 200 end
    return minX - 10, minY - 10, (maxX - minX) + 20, (maxY - minY) + 20
end

local function CreateGlobalFrame()
    local wm    = WINDOW_MANAGER
    local frame = wm:CreateControl("DarkScrollsUIGlobalFrame", GuiRoot, CT_TOPLEVELCONTROL)
    frame:SetDrawLayer(DL_BACKGROUND)
    frame:SetDrawTier(DT_LOW)
    frame:SetMouseEnabled(true)
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)

    frame.bg = wm:CreateControl("DarkScrollsUIGlobalFrameBG", frame, CT_BACKDROP)
    frame.bg:SetAnchorFill()
    frame.bg:SetCenterColor(0, 1, 0, 0.2)
    frame.bg:SetEdgeColor(0, 1, 0, 0.8)
    frame.bg:SetEdgeTexture("", 1, 1, 2)

    frame:SetHidden(true)
    frame.startX, frame.startY = 0, 0

    frame:SetHandler("OnMouseDown", function(self)
        self.startX = self:GetLeft()
        self.startY = self:GetTop()
    end)

    frame:SetHandler("OnMoveStop", function(self)
        local guiW, guiH = GuiRoot:GetDimensions()

        local minX, minY, maxX, maxY = 999999, 999999, -999999, -999999
        for _, name in ipairs(DarkScrollsUI.GetListOfAllControlNames()) do
            local s = DarkScrollsUI.SavedVariables[name]
            if s then
                if s.l         < minX then minX = s.l        end
                if s.t         < minY then minY = s.t        end
                if (s.l + s.w) > maxX then maxX = s.l + s.w end
                if (s.t + s.h) > maxY then maxY = s.t + s.h end
            end
        end

        local rawDeltaX = self:GetLeft() - self.startX
        local rawDeltaY = self:GetTop()  - self.startY
        local deltaX = math.max(-minX, math.min(rawDeltaX, guiW - maxX))
        local deltaY = math.max(-minY, math.min(rawDeltaY, guiH - maxY))

        for _, name in ipairs(DarkScrollsUI.GetListOfAllControlNames()) do
            local ctrl = _G[name]
            local s    = DarkScrollsUI.SavedVariables[name]
            if ctrl and s then
                local targetX = s.l + deltaX
                local targetY = s.t + deltaY
                ctrl:ClearAnchors()
                ctrl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, targetX, targetY)
                DarkScrollsUI.SaveElementControlChanges(ctrl, true, targetX, targetY, s.w, s.h)
            end
        end

        local bx, by = GetBoundingBox()
        self:ClearAnchors()
        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, bx, by)
    end)

    frame:SetHandler("OnMouseWheel", function(self, delta)
        local step        = (delta > 0) and 1 or -1
        local scaleFactor = 1 + (step * 0.02)
        local centerX     = self:GetLeft() + (self:GetWidth()  / 2)
        local centerY     = self:GetTop()  + (self:GetHeight() / 2)

        for _, name in ipairs(DarkScrollsUI.GetListOfAllControlNames()) do
            local ctrl = _G[name]
            local s    = DarkScrollsUI.SavedVariables[name]
            if ctrl and s then
                local newL = centerX + ((s.l - centerX) * scaleFactor)
                local newT = centerY + ((s.t - centerY) * scaleFactor)
                local newW = s.w * scaleFactor
                local newH = s.h * scaleFactor

                ctrl:ClearAnchors()
                ctrl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, newL, newT)
                ctrl:SetDimensions(newW, newH)

                if ctrl.fillTop then
                    ctrl.fillTop:SetHeight(newH / 2)
                    ctrl.fillBottom:SetHeight(newH / 2)
                end

                DarkScrollsUI.SaveElementControlChanges(ctrl, true, newL, newT, newW, newH)

                if ctrl.fillTop then
                    DarkScrollsUI.UpdateAttributeBarFillValue(ctrl, ctrl.powerType)
                elseif not ctrl.iconPool then
                    DarkScrollsUI.UpdateElementTextScaleValue(ctrl)
                end
            end
        end

        local x, y, w, h = GetBoundingBox()
        self:ClearAnchors()
        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
        self:SetDimensions(w, h)
    end)

    return frame
end

function DarkScrollsUI.ToggleGlobalEditModeActive()
    DarkScrollsUI.isGlobalEditModeActive = not DarkScrollsUI.isGlobalEditModeActive

    if not DarkScrollsUI.GlobalInterfaceEditFrame then
        DarkScrollsUI.GlobalInterfaceEditFrame = CreateGlobalFrame()
    end

    if DarkScrollsUI.isGlobalEditModeActive then
        if not DarkScrollsUI.isInterfaceLocked then DarkScrollsUI.ToggleInterfaceLockStatus() end

        local x, y, w, h = GetBoundingBox()
        DarkScrollsUI.GlobalInterfaceEditFrame:ClearAnchors()
        DarkScrollsUI.GlobalInterfaceEditFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
        DarkScrollsUI.GlobalInterfaceEditFrame:SetDimensions(w, h)
        DarkScrollsUI.GlobalInterfaceEditFrame:SetHidden(false)

        if _G["StaminaMontaria"] then _G["StaminaMontaria"]:SetHidden(false) end
        d("DarkScrollsUI: " .. DarkScrollsUI.LocalizationStrings.GlobalOn)
    else
        DarkScrollsUI.GlobalInterfaceEditFrame:SetHidden(true)
        if _G["StaminaMontaria"] and not IsMounted() then
            _G["StaminaMontaria"]:SetHidden(true)
        end
    end

    if DarkScrollsUI.UpdateWeaponIndicatorIcons then DarkScrollsUI.UpdateWeaponIndicatorIcons() end
    UpdateGuideLines(DarkScrollsUI.isGlobalEditModeActive)

    if DarkScrollsUI.isGlobalEditModeActive and not DarkScrollsUI.ConfigurationBackupBeforeEdit then DarkScrollsUI.ConfigurationBackupBeforeEdit = ZO_DeepTableCopy(DarkScrollsUI.SavedVariables) end
    if DarkScrollsUI.isGlobalEditModeActive then DarkScrollsUI.ResetEditModeTimer() end

    DarkScrollsUI.UpdateEditPanelVisibilityStatus()
end

-----------------------------------------------------------
-- EDIT CONFIRMATION PANEL
-----------------------------------------------------------
function DarkScrollsUI.UpdateEditPanelVisibilityStatus()
    if not DarkScrollsUI.EditModeConfirmationPanel then
        local wm    = WINDOW_MANAGER
        local panel = wm:CreateControl("DarkScrollsUI_EditModeConfirmationPanel", GuiRoot, CT_TOPLEVELCONTROL)
        panel:SetDimensions(340, 260)
        panel:SetAnchor(CENTER, GuiRoot, CENTER, 0, -180)
        panel:SetDrawLayer(DL_OVERLAY)
        panel:SetDrawTier(DT_TOP)
        panel:SetDrawLevel(100)
        panel:SetClampedToScreen(true)
        panel:SetMouseEnabled(true)

        panel.bg = wm:CreateControl("DarkScrollsUI_EditModeConfirmationPanelBackground", panel, CT_BACKDROP)
        panel.bg:SetAnchorFill()
        panel.bg:SetCenterColor(0, 0, 0, 0.85)
        panel.bg:SetEdgeColor(0.2, 0.7, 1, 1)
        panel.bg:SetEdgeTexture("", 1, 1, 1)

        panel.label = wm:CreateControl("DarkScrollsUI_EditModeConfirmationPanelTitleLabel", panel, CT_LABEL)
        panel.label:SetAnchor(TOP, panel, TOP, 0, 15)
        panel.label:SetFont("ZoFontWinH3")
        panel.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

        panel.timerLabel = wm:CreateControl("DarkScrollsUI_EditModeConfirmationPanelTimerLabel", panel, CT_LABEL)
        panel.timerLabel:SetAnchor(TOP, panel.label, BOTTOM, 0, 2)
        panel.timerLabel:SetFont("ZoFontWinH4")
        panel.timerLabel:SetColor(1, 1, 0.5, 0.8)
        panel.timerLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

        panel.instrLabel = wm:CreateControl("DarkScrollsUI_EditModeConfirmationPanelInstructionsLabel", panel, CT_LABEL)
        panel.instrLabel:SetAnchor(TOP, panel.timerLabel, BOTTOM, 0, 15)
        panel.instrLabel:SetFont("ZoFontWinH5")
        panel.instrLabel:SetColor(0.9, 0.9, 0.9, 1)
        panel.instrLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

        panel:SetHandler("OnUpdate", function(self)
            if self:IsHidden() then return end
            local now      = GetFrameTimeSeconds()
            local elapsed  = now - (DarkScrollsUI.lastEditActivityTime or now)
            local remaining = 30 - elapsed

            if remaining <= 0 then
                if DarkScrollsUI.ConfigurationBackupBeforeEdit then
                    DarkScrollsUI.MasterSavedVariables.profiles[DarkScrollsUI.MasterSavedVariables.currentProfile] = ZO_DeepTableCopy(DarkScrollsUI.ConfigurationBackupBeforeEdit)
                    DarkScrollsUI.ConfigurationBackupBeforeEdit = nil
                    ReloadUI()
                end
            elseif elapsed >= 10 then
                self.timerLabel:SetHidden(false)
                self.timerLabel:SetText(string.format("Auto-cancel in: %.1fs", remaining))
            else
                self.timerLabel:SetHidden(true)
            end
        end)

        panel.btn = wm:CreateControlFromVirtual("DarkScrollsUI_EditModeSaveButton", panel, "ZO_DefaultButton")
        panel.btn:SetAnchor(BOTTOMLEFT, panel, BOTTOMLEFT, 15, -15)
        panel.btn:SetWidth(150)
        panel.btn:SetText("Save & Finish")
        panel.btn:SetHandler("OnClicked", function()
            DarkScrollsUI.ConfigurationBackupBeforeEdit = nil
            if not DarkScrollsUI.isInterfaceLocked then DarkScrollsUI.ToggleInterfaceLockStatus()
            elseif DarkScrollsUI.isGlobalEditModeActive then DarkScrollsUI.ToggleGlobalEditModeActive() end
        end)

        panel.cancelBtn = wm:CreateControlFromVirtual("DarkScrollsUI_EditModeCancelButton", panel, "ZO_DefaultButton")
        panel.cancelBtn:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, -15, -15)
        panel.cancelBtn:SetWidth(150)
        panel.cancelBtn:SetText("|cFF0000Cancel|r")
        panel.cancelBtn:SetHandler("OnClicked", function()
            if DarkScrollsUI.ConfigurationBackupBeforeEdit then
                DarkScrollsUI.MasterSavedVariables.profiles[DarkScrollsUI.MasterSavedVariables.currentProfile] = ZO_DeepTableCopy(DarkScrollsUI.ConfigurationBackupBeforeEdit)
                DarkScrollsUI.ConfigurationBackupBeforeEdit = nil
                ReloadUI()
            end
        end)

        DarkScrollsUI.EditModeConfirmationPanel = panel
    end

    local isActive = (not DarkScrollsUI.isInterfaceLocked) or DarkScrollsUI.isGlobalEditModeActive
    DarkScrollsUI.EditModeConfirmationPanel:SetHidden(not isActive)
    if isActive then
        DarkScrollsUI.EditModeConfirmationPanel.label:SetText(DarkScrollsUI.isGlobalEditModeActive and "|c00FF00Group Edit Mode|r" or "|c00FF00Individual Edit Mode|r")

        if DarkScrollsUI.isGlobalEditModeActive then
            DarkScrollsUI.EditModeConfirmationPanel.instrLabel:SetText("|cFFFFFF• Drag Green Area:|r Move Group\n|cFFFFFF• Mouse Wheel:|r Scale Group (Center)")
        else
            DarkScrollsUI.EditModeConfirmationPanel.instrLabel:SetText("|cFFFFFF• Drag Element:|r Move\n|cFFFFFF• Wheel:|r Width / Size\n|cFFFFFF• Shift + Wheel:|r Height\n|cFFFFFF• Alt + Wheel:|r Opacity\n|cFFFFFF• Ctrl + Wheel:|r Font Scale\n|cFFFFFF• Ctrl + Shift + Wheel:|r Rotation")
        end
    end
end
