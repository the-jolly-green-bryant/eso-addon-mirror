-------------------------------------------------------------------------------
-- ESOPie Radial Menu Controller

-------------------------------------------------------------------------------
-- Rolling our own version of ZO_InteractiveRadialMenuController because we
-- need to heavily gut the system to make it work the way we want with subrings
-- and to make sure we can keep navigation snappy.

local TIME_TO_HOLD_KEY_MS = 50

ESOPie_RadialMenuController = ZO_RadialMenu:Subclass()

function ESOPie_RadialMenuController:New(...)
    local radial = ZO_Object.New(self)
    radial:Initialize(...)
    return radial
end

function ESOPie_RadialMenuController:Initialize(control, entryTemplate, animationTemplate, entryAnimationTemplate, actionLayer)
    local actionLayerName = actionLayer or "RadialMenu"
    self.menuControl = control:GetNamedChild("Menu")
    self.menu = ZO_RadialMenu:New(self.menuControl, entryTemplate, animationTemplate, entryAnimationTemplate, actionLayerName)

    local function SetupEntryControl(entryControl, data)
        self:SetupEntryControl(entryControl, data)
    end

    local function OnSelectionChangedCallback(selectedEntry)
        self:OnSelectionChangedCallback(selectedEntry)
    end

    local function OnClear()
        self.currentSelectedEntry = nil
    end

    control:SetHandler("OnUpdate", function() self:OnUpdate() end)
    self.menu:SetCustomControlSetUpFunction(SetupEntryControl)
    self.menu:SetOnSelectionChangedCallback(OnSelectionChangedCallback)
    self.menu:SetOnClearCallback(OnClear)
    self.currentSelectedEntry = nil
end

function ESOPie_RadialMenuController:SetSlotActivateCallback(callback)
    self.onSlotActivateCallback = callback
end

function ESOPie_RadialMenuController:SetSlotNavigateCallback(callback)
    self.onSlotNavigateCallback = callback
end

function ESOPie_RadialMenuController:SetMenuStateChangeCallback(callback)
    self.onMenuStateChange = callback
end

function ESOPie_RadialMenuController:SetCancelCallback(callback)
    self.onCancelCallback = callback
end

function ESOPie_RadialMenuController:SetPopulateSlotsCallback(callback)
    self.onPopulateSlotsCallback = callback
end

function ESOPie_RadialMenuController:StartInteraction()
    if not self.isInteracting and not self.beginHold then
        if self:PrepareForInteraction() then
            self.beginHold = GetFrameTimeMilliseconds()
            return true
        end
    end
end

function ESOPie_RadialMenuController:StopInteraction()
    local wasShowingRadial = self.beginHold == nil
    self.beginHold = nil
    EVENT_MANAGER:UnregisterForEvent("ESOPie", EVENT_GLOBAL_MOUSE_UP)
    LockCameraRotation(false)
    RETICLE:RequestHidden(false)
    if self.isInteracting then
        self.isInteracting = false
        if self.currentSelectedEntry then
            self.menu:SelectCurrentEntry()
        else
            self.menu:Clear()
        end
        if self.onMenuStateChange then
            self.onMenuStateChange(false)
        end
    end
    return wasShowingRadial
end

function ESOPie_RadialMenuController:OnUpdate()
    if self.beginHold and GetFrameTimeMilliseconds() >= self.beginHold + TIME_TO_HOLD_KEY_MS then
        self.beginHold = nil
        if not self.isInteracting then
            self:ShowMenu()
        end
    end
    if self.isInteracting and IsInteracting() and GetInteractionType() ~= INTERACTION_HIDEYHOLE then
        self:StopInteraction()
    end
end

function ESOPie_RadialMenuController:ShowMenu()
    self.menu:Clear()
    if self.onPopulateSlotsCallback then
        self.onPopulateSlotsCallback()
    else
        d("OnPopulateSlots callback not set")
    end
    self.menu:Show()
    if IsInGamepadPreferredMode() then
        self.menuControl.selectedLabel:SetFont("ZoFontGamepad54")
    else
        self.menuControl.selectedLabel:SetFont("ZoInteractionPrompt")
    end
    self.menuControl.selectedLabel:SetText("")
    if not self.isInteracting then
        LockCameraRotation(true)
        RETICLE:RequestHidden(true)
        if self.onMenuStateChange then
            self.onMenuStateChange(true)
        end
    end
    self.isInteracting = true
end

function ESOPie_RadialMenuController:IsInteracting()
    return self.isInteracting and SCENE_MANAGER:IsShowing("hud")
end

function ESOPie_RadialMenuController:PrepareForInteraction()
    if not SCENE_MANAGER:IsShowing("hud") then
        return false
    end
    EVENT_MANAGER:RegisterForEvent("ESOPie", EVENT_GLOBAL_MOUSE_UP, function(eventCode, button, ctrl, alt, shift, command)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            if self.currentSelectedEntry then
                self:NavigateCurrentSelection()
            end
        elseif button == MOUSE_BUTTON_INDEX_RIGHT then
            self.currentSelectedEntry = nil
            self:CancelSelection()
        end
    end)
    return true
end

function ESOPie_RadialMenuController:SetupEntryControl(control, data)
    if not data then return end
    ZO_SetupSelectableItemRadialMenuEntryTemplate(control)
    if data.selected then
        if control.glow then
            control.glow:SetAlpha(1)
        end
        control.animation:GetLastAnimation():SetAnimatedControl(nil)
    else
        if control.glow then
            control.glow:SetAlpha(0)
        end
        control.animation:GetLastAnimation():SetAnimatedControl(control.glow)
    end
end

function ESOPie_RadialMenuController:OnSelectionChangedCallback(selectedEntry)
    if not selectedEntry then return end
    if selectedEntry.name then
        self.menuControl.selectedLabel:SetText(selectedEntry.name)
    else
        self.menuControl.selectedLabel:SetText("")
    end
    self.currentSelectedEntry = selectedEntry

    -- Could use the RegisterForUpdate trick to do an "activate after hovered for X seconds" feature here
    -- https://wiki.esoui.com/Running_LUA-Code_asynchroneously#RegisterForUpdate
end

function ESOPie_RadialMenuController:ActivateCurrentSelection()
    if not self.onSlotActivateCallback then d("OnSlotActivate callback not set") return end
    if self.currentSelectedEntry then
        self.onSlotActivateCallback(self.currentSelectedEntry)
    end
end

function ESOPie_RadialMenuController:NavigateCurrentSelection()
    if not self.onSlotNavigateCallback then d("OnSlotNavigate callback not set") return end
    if self.currentSelectedEntry then
        self.onSlotNavigateCallback(self.currentSelectedEntry)
    end
end

function ESOPie_RadialMenuController:CancelSelection()
    self.currentSelectedEntry = nil
    if self.onCancelCallback then self.onCancelCallback() end
    self:StopInteraction()
end

function ESOPie_RadialMenuController:AddSlot(name, inactiveIcon, activeIcon, uniqueid)
    self.menu:AddEntry(name, inactiveIcon, activeIcon, function() self:ActivateCurrentSelection() end, {name=name, uniqueid=uniqueid})
end

-------------------------------------------------------------------------------
-- Templates

function ESOPieUI_PieMenuInitialize(self)
    self.selectedLabel = self:GetNamedChild("SelectedLabel")
end

function ESOPieUI_EntryTemplateInitialize(self)
    ZO_SelectableItemRadialMenuEntryTemplate_OnInitialized(self)
end