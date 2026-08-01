---@class KFS_MoverState
local MoverState = {};
KhajiitFengShui.MoverState = MoverState;

local PanelUtils = KhajiitFengShui.PanelUtils;
local AttributeScaler = KhajiitFengShui.AttributeScaler;

local DEFAULT_SCALE = 1;
local ATTRIBUTE_SCALER_PANEL_IDS =
{
    playerHealth = true;
    playerMagicka = true;
    playerStamina = true;
    playerWerewolf = true;
    playerMount = true;
    playerSiege = true;
};

---Checks whether the addon should manage a panel
---@param self KhajiitFengShui
---@param panelId string
---@return boolean
function MoverState.IsMoverEnabled(self, panelId)
    if not panelId then
        return true;
    end;

    local savedVars = self.savedVars;
    if not (savedVars and savedVars.disabledPanels) then
        return true;
    end;

    return savedVars.disabledPanels[panelId] ~= true;
end;

---Destroys mover resources for a panel
---@param self KhajiitFengShui
---@param panel KhajiitFengShuiPanel?
function MoverState.DestroyMover(self, panel)
    if not panel then
        return;
    end;

    if panel.handler and panel.handler.ToggleGamepadMove then
        panel.handler:ToggleGamepadMove(false);
    end;

    panel.handler = nil;
    panel.gamepadActive = false;

    if panel.overlay then
        panel.overlay:SetHidden(true);
        panel.overlay:SetMouseEnabled(false);
        panel.overlay:SetMovable(false);
    end;

    panel.overlay = nil;
    panel.label = nil;
    panel.moverEnabled = false;
end;

---Ensures a panel mover exists
---@param self KhajiitFengShui
---@param panelId string
function MoverState.EnsurePanelMover(self, panelId)
    if not panelId then
        return;
    end;

    local panel = self.panelLookup and self.panelLookup[panelId];
    if not panel then
        local definition = self.definitionLookup and self.definitionLookup[panelId];
        if definition then
            panel = self:TryCreatePanel(definition);
        end;
    end;

    if panel and not panel.handler then
        self:CreateMover(panel);
    end;
end;

---Enables or disables a panel mover
---@param self KhajiitFengShui
---@param panelId string
---@param enabled boolean
function MoverState.SetMoverEnabled(self, panelId, enabled)
    if not (panelId and self.savedVars) then
        return;
    end;

    self.savedVars.disabledPanels = self.savedVars.disabledPanels or {};
    local shouldEnable = enabled == true;
    local currentlyEnabled = MoverState.IsMoverEnabled(self, panelId);
    if shouldEnable == currentlyEnabled then
        return;
    end;

    local panel = self.panelLookup and self.panelLookup[panelId];

    if shouldEnable then
        self.savedVars.disabledPanels[panelId] = nil;
        MoverState.EnsurePanelMover(self, panelId);
        panel = self.panelLookup and self.panelLookup[panelId];
        if panel and panel.handler then
            self:ApplySavedPosition(panel);
            self:ApplyPanelScale(panel);
            self:RefreshPanelState(panel);
        end;
    else
        self.savedVars.disabledPanels[panelId] = true;

        if panel then
            if panel.handler then
                local defaultPosition = panel.defaultPosition or
                    { left = panel.control and panel.control:GetLeft() or 0; top = panel.control and panel.control:GetTop() or 0 };
                panel.handler:UpdatePosition(defaultPosition);
                PanelUtils.applyControlAnchor(panel, defaultPosition.left or 0, defaultPosition.top or 0);
            elseif panel.defaultPosition then
                PanelUtils.applyControlAnchor(panel, panel.defaultPosition.left or 0, panel.defaultPosition.top or 0);
            end;

            if ATTRIBUTE_SCALER_PANEL_IDS[panelId] and AttributeScaler and AttributeScaler.Remove then
                AttributeScaler:Remove(panel);
            elseif panel.control and panel.control.SetTransformScale then
                PanelUtils.enableInheritScaleRecursive(panel.control);
                panel.control:SetTransformScale(panel.defaultScale or DEFAULT_SCALE);
            end;

            MoverState.DestroyMover(self, panel);
        end;

        if self.activePanelId == panelId then
            self.activePanelId = nil;
        end;
        if self.editModeFocusId == panelId then
            self.editModeFocusId = nil;
            if self.editModeActive then
                self:SelectFirstFocusablePanel();
            end;
        end;
    end;

    self:RefreshAllPanels();
    self:RefreshGridOverlay();
    self:RefreshSettingsAvailability();
end;

---Synchronizes mover state for all panels with saved variables
---@param self KhajiitFengShui
function MoverState.SyncPanelMoverStates(self)
    if not self.panels then
        return;
    end;

    for _, panel in ipairs(self.panels) do
        local desired = MoverState.IsMoverEnabled(self, panel.definition.id);
        local currently = panel.moverEnabled == true;
        if desired ~= currently then
            MoverState.SetMoverEnabled(self, panel.definition.id, desired);
        end;
    end;
end;
