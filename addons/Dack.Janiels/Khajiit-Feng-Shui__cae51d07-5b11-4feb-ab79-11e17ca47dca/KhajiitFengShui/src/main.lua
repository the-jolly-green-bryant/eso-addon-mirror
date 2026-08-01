local ADDON_NAME = "KhajiitFengShui";

local SCALE_MIN_PERCENT = 50;
local SCALE_MAX_PERCENT = 150;
local SCALE_STEP_PERCENT = 5;
local DEFAULT_SCALE = 1;
local KFS_FRAGMENT_HIDDEN_REASON_USER = "KhajiitFengShuiUserHidden";

---@type LibCombatAlerts
local LCA;

local em = GetEventManager();
local sceneManager = SCENE_MANAGER;
local SecurePostHook = SecurePostHook;

local PanelUtils = KhajiitFengShui.PanelUtils;
local PanelDefinitions = KhajiitFengShui.PanelDefinitions;
local GridOverlay = KhajiitFengShui.GridOverlay;
local EditModeController = KhajiitFengShui.EditModeController;
local SettingsController = KhajiitFengShui.SettingsController;
local AttributeScaler = KhajiitFengShui.AttributeScaler;
local MoverState = KhajiitFengShui.MoverState;

local ATTRIBUTE_SCALER_PANEL_IDS =
{
    playerHealth = true;
    playerMagicka = true;
    playerStamina = true;
    playerWerewolf = true;
    playerMount = true;
    playerSiege = true;
};

---Builds overlay message with position and scale
---@param panel KhajiitFengShuiPanel
---@param left number
---@param top number
---@return string
function KhajiitFengShui:BuildOverlayMessage(panel, left, top)
    local labelText = PanelDefinitions.getLabel(panel.definition);
    local message = PanelUtils.formatPositionMessage(left, top, labelText);
    local scalePercent = zo_roundToNearest(self:GetPanelScale(panel.definition.id) * 100, SCALE_STEP_PERCENT);
    return string.format("%s | %d%%", message, scalePercent);
end;

---Ensures saved vars has all required fields
---@param savedVars KFS_SavedVars?
---@param defaults KFS_Defaults?
local function EnsureSavedVarStructure(savedVars, defaults)
    if not savedVars then
        return;
    end;

    defaults = defaults or {};

    savedVars.grid = savedVars.grid or PanelUtils.copyPosition(defaults.grid);
    if savedVars.grid then
        if savedVars.grid.enabled == nil and defaults.grid then
            savedVars.grid.enabled = defaults.grid.enabled;
        end;
        if not savedVars.grid.size and defaults.grid then
            savedVars.grid.size = defaults.grid.size;
        end;
    end;

    savedVars.positions = savedVars.positions or {};
    savedVars.scales = savedVars.scales or {};
    savedVars.disabledPanels = savedVars.disabledPanels or {};
    if defaults.disabledPanels then
        for panelId, disabled in pairs(defaults.disabledPanels) do
            if savedVars.disabledPanels[panelId] == nil then
                savedVars.disabledPanels[panelId] = disabled;
            end;
        end;
    end;

    if savedVars.buffAnimationsEnabled == nil then
        savedVars.buffAnimationsEnabled = defaults.buffAnimationsEnabled or false;
    end;
    if savedVars.globalCooldownEnabled == nil then
        savedVars.globalCooldownEnabled = defaults.globalCooldownEnabled or false;
    end;
    if savedVars.pyramidLayoutEnabled == nil then
        savedVars.pyramidLayoutEnabled = defaults.pyramidLayoutEnabled or false;
    end;
    if savedVars.alwaysExpandedBars == nil then
        savedVars.alwaysExpandedBars = defaults.alwaysExpandedBars or false;
    end;
    if savedVars.pyramidOffset == nil then
        savedVars.pyramidOffset = PanelUtils.copyPosition(defaults.pyramidOffset);
    end;
    if savedVars.showAllLabels == nil then
        savedVars.showAllLabels = defaults.showAllLabels or false;
    end;
    if savedVars.bossBarEnabled == nil then
        savedVars.bossBarEnabled = defaults.bossBarEnabled ~= false;
    end;
    if savedVars.reticleEnabled == nil then
        savedVars.reticleEnabled = defaults.reticleEnabled ~= false;
    end;

    savedVars.panelHidden = savedVars.panelHidden or {};
    if defaults.panelHidden then
        for panelId, hidden in pairs(defaults.panelHidden) do
            if savedVars.panelHidden[panelId] == nil then
                savedVars.panelHidden[panelId] = hidden;
            end;
        end;
    end;
end;

---@class KhajiitFengShuiPanel
---@field definition KhajiitFengShuiPanelDefinition Panel definition
---@field control userdata Game UI control being tracked
---@field overlay userdata Movable overlay window
---@field handler LibCombatAlerts.MoveableControl LibCombatAlerts MoveableControl handler
---@field label userdata Overlay label control
---@field defaultPosition { left: number, top: number } Original position before any moves
---@field defaultScale number Original scale before any changes
---@field gamepadActive boolean Whether gamepad movement is active
---@field moverEnabled boolean? Whether the mover is currently active
---@field sectionAdded boolean Settings section created flag
---@field enableSettingAdded boolean Enable toggle created flag
---@field scaleSettingAdded boolean Scale slider created flag
---@field moveSettingAdded boolean Move button created flag
---@field hideSettingAdded boolean Hide-via-fragment checkbox created flag
---@field compassDefaults { baseWidth: number?, baseHeight: number?, leftWidth: number?, rightWidth: number?, labelScale: number?, labelAnchorPoint: integer?, labelAnchorTarget: userdata?, labelAnchorRelativePoint: integer?, labelOffsetX: number?, labelOffsetY: number? } Compass-specific defaults

---Updates overlay label text
---@param panel KhajiitFengShuiPanel
---@param message string
local function UpdateOverlayLabel(panel, message)
    PanelUtils.updateOverlayLabel(panel.label, message);
end;

---@param panelId string
---@return boolean
local function isPrimaryAttributePanelId(panelId)
    return panelId == "playerHealth"
        or panelId == "playerMagicka"
        or panelId == "playerStamina";
end;

---Gets layout-space width (before transform scale) for an attribute bar control
---@param panel KhajiitFengShuiPanel
---@return number
local function getLayoutBarWidth(panel)
    if not panel or not panel.control then
        return panel and panel.definition and panel.definition.width or 237;
    end;

    local actualWidth = panel.control:GetWidth();
    if actualWidth and actualWidth > 0 then
        return actualWidth;
    end;

    return panel.definition.width or 237;
end;

---Gets layout-space height (before transform scale) for an attribute bar control
---@param panel KhajiitFengShuiPanel
---@return number
local function getLayoutBarHeight(panel)
    if not panel or not panel.control then
        return panel and panel.definition and panel.definition.height or 23;
    end;

    local actualHeight = panel.control:GetHeight();
    if actualHeight and actualHeight > 0 then
        return actualHeight;
    end;

    return panel.definition.height or 23;
end;

---Gets scale applied on the control (TransformScale for attribute bars, else SetScale)
---@param control userdata?
---@param fallbackScale number?
---@return number
local function getAppliedControlScale(control, fallbackScale)
    if control then
        if control.GetTransformScale then
            local transformScale = control:GetTransformScale();
            if transformScale and transformScale > 0 then
                return transformScale;
            end;
        end;
        if control.GetScale then
            local legacyScale = control:GetScale();
            if legacyScale and legacyScale > 0 then
                return legacyScale;
            end;
        end;
    end;
    return fallbackScale or 1;
end;

---Gets on-screen width for pyramid layout and mover overlays (layout size × transform scale)
---@param panel KhajiitFengShuiPanel
---@param scale number
---@return number
local function getExpectedBarWidth(panel, scale)
    local layoutWidth = getLayoutBarWidth(panel);
    local appliedScale = getAppliedControlScale(panel and panel.control, scale);
    return zo_round(layoutWidth * appliedScale);
end;

---Gets on-screen height for pyramid layout and mover overlays (layout size × transform scale)
---@param panel KhajiitFengShuiPanel
---@param scale number
---@return number
local function getExpectedBarHeight(panel, scale)
    local layoutHeight = getLayoutBarHeight(panel);
    local appliedScale = getAppliedControlScale(panel and panel.control, scale);
    return zo_round(layoutHeight * appliedScale);
end;

---Vertical gap between pyramid rows for the given bar scales
---@param healthScale number
---@param magickaScale number
---@param staminaScale number
---@param alwaysExpanded boolean
---@return number
local function getPyramidVerticalSpacing(healthScale, magickaScale, staminaScale, alwaysExpanded)
    local baseVerticalSpacing = alwaysExpanded and 15 or 5;
    local scaleAdjustment = zo_max(healthScale, magickaScale, staminaScale);
    local extraForLargeScale = scaleAdjustment > 1 and (scaleAdjustment - 1) * 8 or 0;
    return (baseVerticalSpacing + extraForLargeScale) * scaleAdjustment;
end;

---Distance from screen bottom to top row of pyramid (scales with bar size)
---@param screenHeight number
---@param healthScale number
---@param magickaScale number
---@param staminaScale number
---@return number baseHealthTop
local function getPyramidBaseHealthTop(screenHeight, healthScale, magickaScale, staminaScale)
    local scaleAdjustment = zo_max(healthScale, magickaScale, staminaScale);
    return screenHeight - zo_round(100 * scaleAdjustment);
end;

---Syncs mover overlay to panel control visual bounds
---@param addon KhajiitFengShui
---@param panel KhajiitFengShuiPanel
local function SyncOverlaySize(addon, panel)
    if not panel then
        return;
    end;

    local widthOverride;
    local heightOverride;
    local panelId = panel.definition and panel.definition.id;
    if isPrimaryAttributePanelId(panelId) then
        widthOverride = getLayoutBarWidth(panel);
        heightOverride = getLayoutBarHeight(panel);
    end;

    PanelUtils.syncOverlaySize(panel, widthOverride, heightOverride);
end;

---Gets scale for a panel
---@param panelId string
---@return number
function KhajiitFengShui:GetPanelScale(panelId)
    if not (panelId and self.savedVars) then
        return DEFAULT_SCALE;
    end;
    local panel = self.panelLookup and self.panelLookup[panelId];
    local defaultScale = (panel and panel.defaultScale) or DEFAULT_SCALE;
    local scales = self.savedVars.scales;
    if scales and scales[panelId] and scales[panelId] > 0 then
        return scales[panelId];
    end;
    return defaultScale;
end;

---Gets scale as percentage for a panel
---@param panelId string
---@return number
function KhajiitFengShui:GetPanelScalePercent(panelId)
    return zo_roundToNearest(self:GetPanelScale(panelId) * 100, SCALE_STEP_PERCENT);
end;

---Checks whether the addon should manage a panel
---@param panelId string
---@return boolean
function KhajiitFengShui:IsMoverEnabled(panelId)
    return MoverState.IsMoverEnabled(self, panelId);
end;

---Applies scale to a panel
---@param panel KhajiitFengShuiPanel?
function KhajiitFengShui:ApplyPanelScale(panel)
    if not panel or not self:IsMoverEnabled(panel.definition.id) then
        return;
    end;

    -- Unitframes handle their own scaling, don't apply main addon scaling
    if panel.definition.id and string.match(panel.definition.id, "^unitFrame") then
        return;
    end;

    -- For quest trackers, only apply scale if there's an explicit saved scale
    local isQuestTracker = panel.definition.id == "questTracker" or panel.definition.id == "questTrackerGamepad";
    if isQuestTracker then
        local scales = self.savedVars and self.savedVars.scales;
        local hasExplicitScale = scales and scales[panel.definition.id] and scales[panel.definition.id] > 0;
        if not hasExplicitScale then
            -- Don't apply scale to quest trackers unless user explicitly set one
            return;
        end;
    end;

    PanelUtils.applyScale(panel, self:GetPanelScale(panel.definition.id));
end;

---Sets scale for a panel
---@param panelId string
---@param scale number
function KhajiitFengShui:SetPanelScale(panelId, scale)
    if not (panelId and self.savedVars) then
        return;
    end;

    self.savedVars.scales = self.savedVars.scales or {};

    local panel = self.panelLookup and self.panelLookup[panelId];
    local defaultScale = (panel and panel.defaultScale) or DEFAULT_SCALE;
    local normalized = zo_clamp(scale or defaultScale, SCALE_MIN_PERCENT / 100, SCALE_MAX_PERCENT / 100);
    local rounded = zo_roundToNearest(normalized, SCALE_STEP_PERCENT / 100);

    if zo_floatsAreEqual(rounded, defaultScale) then
        self.savedVars.scales[panelId] = nil;
    else
        self.savedVars.scales[panelId] = rounded;
    end;

    if not panel then
        return;
    end;

    if self:IsMoverEnabled(panelId) then
        self:ApplyPanelScale(panel);
    end;
    if panel.definition and panel.definition.postApply then
        local hasCustomPosition = self.savedVars.positions and self.savedVars.positions[panelId] ~= nil;
        panel.definition.postApply(panel.control, hasCustomPosition);
    end;
    SyncOverlaySize(self, panel);

    if
        self.savedVars.pyramidLayoutEnabled
    and (panelId == "playerHealth" or panelId == "playerMagicka" or panelId == "playerStamina")
    then
        self:ApplyPyramidLayout();
    elseif self:IsMoverEnabled(panelId) then
        self:ApplySavedPosition(panel);
    end;

    if panel.handler then
        local left, top = PanelUtils.getAnchorPosition(panel.handler);
        UpdateOverlayLabel(panel, self:BuildOverlayMessage(panel, left, top));
    end;
end;

---Attempts to create a panel from definition
---@param definition KhajiitFengShuiPanelDefinition?
---@return KhajiitFengShuiPanel?
function KhajiitFengShui:TryCreatePanel(definition)
    if not definition then
        return nil;
    end;

    local control = PanelDefinitions.resolveControl(definition);
    if not control then
        return nil;
    end;

    local existing = self.panelLookup[definition.id];
    if existing then
        existing.control = control;
        existing.defaultScale = control:GetTransformScale() or existing.defaultScale or DEFAULT_SCALE;
        return existing;
    end;

    local left = control:GetLeft() or 0;
    local top = control:GetTop() or 0;
    local panel =
    {
        definition = definition;
        control = control;
        defaultPosition =
        {
            left = left;
            top = top;
        };
        defaultScale = control:GetTransformScale() or DEFAULT_SCALE;
    };

    table.insert(self.panels, panel);
    self.panelLookup[definition.id] = panel;

    panel.moverEnabled = self:IsMoverEnabled(definition.id);
    if panel.moverEnabled then
        self:CreateMover(panel);
    end;

    -- Register quest tracker hooks when panel is created (for gamepad mode)
    -- Only register hooks if mover is enabled
    if definition.id == "questTrackerGamepad" and panel.moverEnabled then
        self:EnsureQuestTrackerHooks();
    end;

    if self.settingsController then
        self.settingsController:AddPanelSetting(panel);
    end;
    return panel;
end;

---Checks if panel overlay should be visible
---@param panel KhajiitFengShuiPanel
---@return boolean
function KhajiitFengShui:IsPanelVisible(panel)
    if self.editModeActive then
        return true;
    end;

    return self.activePanelId == panel.definition.id;
end;

---Checks if panel should be unlocked for movement
---@param panel KhajiitFengShuiPanel
---@return boolean
function KhajiitFengShui:IsPanelUnlocked(panel)
    if self.editModeActive then
        return true;
    end;

    if not self.activePanelId then
        return false;
    end;

    if self.activePanelId == panel.definition.id then
        return true;
    end;

    if self.savedVars.pyramidLayoutEnabled then
        local isPyramidBar = panel.definition.id == "playerHealth"
            or panel.definition.id == "playerMagicka"
            or panel.definition.id == "playerStamina";
        local isActivePyramidBar = self.activePanelId == "playerHealth"
            or self.activePanelId == "playerMagicka"
            or self.activePanelId == "playerStamina";
        if isPyramidBar and isActivePyramidBar then
            return true;
        end;
    end;

    return false;
end;

---Refreshes panel state (locked, visible, etc)
---@param panel KhajiitFengShuiPanel
function KhajiitFengShui:RefreshPanelState(panel)
    if not (panel and panel.handler) then
        return;
    end;
    -- Don't refresh state for disabled movers
    if not self:IsMoverEnabled(panel.definition.id) then
        return;
    end;

    -- Determine active panel ID based on current mode
    local activePanelId = self.editModeActive and self.editModeFocusId or self.activePanelId;
    local isActive = panel.definition.id == activePanelId;
    local shouldGamepadMove = activePanelId ~= nil and isActive;

    -- Update lock state
    local unlocked = self:IsPanelUnlocked(panel);
    panel.handler:ToggleLock(not unlocked);

    -- Update gamepad move state if changed
    if panel.gamepadActive ~= shouldGamepadMove then
        panel.handler:ToggleGamepadMove(shouldGamepadMove, 10000);
        panel.gamepadActive = shouldGamepadMove;
    end;

    -- Update overlay visibility and highlight
    if panel.overlay then
        panel.overlay:SetHidden(not self:IsPanelVisible(panel));
        PanelUtils.setOverlayHighlight(panel, isActive);
    end;

    -- Update label visibility
    if panel.label then
        local isPanelVisible = self:IsPanelVisible(panel);
        local showLabel = isPanelVisible and (self.savedVars.showAllLabels or isActive);
        panel.label:SetHidden(not showLabel);
    end;
end;

---Refreshes state for all panels
function KhajiitFengShui:RefreshAllPanels()
    for _, panel in ipairs(self.panels) do
        self:RefreshPanelState(panel);
    end;
end;

---Handles compass ApplyStyle post hook
function KhajiitFengShui:OnCompassApplyStyle()
    local compassPanel = self.panelLookup and self.panelLookup.compass;
    if not (compassPanel and compassPanel.handler and compassPanel.control and compassPanel.control.SetAnchor) then
        return;
    end;
    -- Don't apply position if mover is disabled
    if not self:IsMoverEnabled("compass") then
        return;
    end;

    local position = compassPanel.handler:GetPosition(true);
    if position then
        local gridSize = self:GetSnapSize();
        PanelUtils.applyControlAnchorFromPosition(compassPanel, position, gridSize);
    end;
end;

---Ensures compass hook is registered
function KhajiitFengShui:EnsureCompassHook()
    if self.compassHookRegistered then
        return;
    end;

    if not (COMPASS_FRAME and COMPASS_FRAME.ApplyStyle and ZO_PostHook) then
        return;
    end;

    ZO_PostHook(COMPASS_FRAME, "ApplyStyle", GenerateFlatClosure(self.OnCompassApplyStyle, self));

    self.compassHookRegistered = true;
end;

---Applies user fragment hide preference for one panel
---@param panel KhajiitFengShuiPanel?
function KhajiitFengShui:ApplyUserHiddenForPanel(panel)
    if not (panel and panel.definition and panel.definition.supportsUserHidden and panel.definition.fragmentGlobalName) then
        return;
    end;

    local fragment = _G[panel.definition.fragmentGlobalName];
    if not (fragment and fragment.SetHiddenForReason) then
        return;
    end;

    local hidden = self.savedVars and self.savedVars.panelHidden and self.savedVars.panelHidden[panel.definition.id] == true;
    fragment:SetHiddenForReason(KFS_FRAGMENT_HIDDEN_REASON_USER, hidden);
end;

---Applies user fragment hide preferences for all panels that support them
function KhajiitFengShui:ApplyAllUserHiddenStates()
    for _, panel in ipairs(self.panels or {}) do
        self:ApplyUserHiddenForPanel(panel);
    end;
end;

---Reapplies saved Adventure Zone HUD tracker position after game refreshes anchors
function KhajiitFengShui:OnAdvZoneHUDTrackerRefreshAnchorsAfter()
    local panel = self.panelLookup and self.panelLookup["advZoneHUDTracker"];
    if not panel then
        return;
    end;
    if not self:IsMoverEnabled("advZoneHUDTracker") then
        return;
    end;
    if not (self.savedVars and self.savedVars.positions and self.savedVars.positions["advZoneHUDTracker"]) then
        return;
    end;
    self:ApplySavedPosition(panel);
end;

---Ensures PostHook runs after ZO_AdventureZoneHUDTracker:RefreshAnchors so KFS position persists
function KhajiitFengShui:EnsureAdvZoneHUDTrackerHook()
    if self.advZoneHUDTrackerHookRegistered then
        return;
    end;

    if not (ZO_PostHook and ZO_AdventureZoneHUDTracker and ZO_AdventureZoneHUDTracker.RefreshAnchors) then
        return;
    end;

    ZO_PostHook(ZO_AdventureZoneHUDTracker, "RefreshAnchors", GenerateFlatClosure(self.OnAdvZoneHUDTrackerRefreshAnchorsAfter, self));

    self.advZoneHUDTrackerHookRegistered = true;
end;

---Reapplies attribute bar positions after vanilla PlayerAttributeBars refreshes layout
function KhajiitFengShui:OnPlayerAttributeBarsLayoutRefresh()
    if not self.savedVars or not self.panelLookup then
        return;
    end;

    if self.savedVars.pyramidLayoutEnabled then
        self:ApplyPyramidLayoutImmediate(false);
        return;
    end;

    for _, panelId in ipairs({ "playerHealth"; "playerMagicka"; "playerStamina" }) do
        local panel = self.panelLookup[panelId];
        if panel and panel.handler and self:IsMoverEnabled(panelId) then
            local savedPosition = self.savedVars.positions and self.savedVars.positions[panelId];
            if savedPosition then
                panel.handler:UpdatePosition(savedPosition);
                PanelUtils.applyControlAnchorFromPosition(panel, savedPosition, 0);
                SyncOverlaySize(self, panel);
            end;
        end;
    end;
end;

---Ensures PostHook runs after PlayerAttributeBars layout changes so KFS positions persist
function KhajiitFengShui:EnsurePlayerAttributeBarsHook()
    if self.playerAttributeBarsHookRegistered then
        return;
    end;

    if not ZO_PostHook or not ZO_PlayerAttributeBars then
        return;
    end;

    ZO_PostHook(
        ZO_PlayerAttributeBars,
        "ApplyStyle",
        function ()
            zo_callLater(GenerateFlatClosure(self.OnPlayerAttributeBarsLayoutRefresh, self), 0);
        end
    );
    ZO_PostHook(
        ZO_PlayerAttributeBars,
        "OnScreenResized",
        function ()
            zo_callLater(GenerateFlatClosure(self.OnPlayerAttributeBarsLayoutRefresh, self), 0);
        end
    );

    self.playerAttributeBarsHookRegistered = true;
end;

---Syncs mover overlay dimensions for a panel (used from AttributeScaler and elsewhere)
---@param panel KhajiitFengShuiPanel
function KhajiitFengShui:SyncPanelOverlaySize(panel)
    SyncOverlaySize(self, panel);
end;

---Ensures quest tracker hooks are registered for gamepad mode
function KhajiitFengShui:EnsureQuestTrackerHooks()
    if self.questTrackerHooksRegistered then
        return;
    end;

    if not IsInGamepadPreferredMode() then
        return;
    end;

    local function reapplyQuestTrackerAnchors()
        local panel = self.panelLookup and self.panelLookup["questTrackerGamepad"];
        if panel and panel.definition then
            -- Don't reapply if mover is disabled
            if not self:IsMoverEnabled("questTrackerGamepad") then
                return;
            end;
            local hasCustomPosition = self.savedVars and self.savedVars.positions and self.savedVars.positions["questTrackerGamepad"] ~= nil;
            -- Reapply scale to ensure promo/house trackers are scaled correctly (only if explicit scale is set)
            if panel.definition.scaleApply then
                local scales = self.savedVars and self.savedVars.scales;
                local hasExplicitScale = scales and scales["questTrackerGamepad"] and scales["questTrackerGamepad"] > 0;
                if hasExplicitScale then
                    local scale = self:GetPanelScale("questTrackerGamepad");
                    panel.definition.scaleApply(panel, scale);
                end;
            end;
            -- Always reapply anchors to handle promo visibility changes
            if panel.definition.postApply then
                panel.definition.postApply(panel.control, hasCustomPosition);
            end;
        end;
    end;

    -- Hook into quest tracker container show events to re-anchor promotional/house trackers
    local questContainer = GetControl("ZO_FocusedQuestTrackerPanelContainer");
    if questContainer then
        questContainer:SetHandler("OnShow", function ()
            zo_callLater(reapplyQuestTrackerAnchors, 50);
        end);
    end;

    local zoneStoryContainer = GetControl("ZO_ZoneStoryTrackerContainer");
    if zoneStoryContainer then
        zoneStoryContainer:SetHandler("OnShow", function ()
            zo_callLater(reapplyQuestTrackerAnchors, 50);
        end);
    end;

    -- Hook into promo tracker show/hide to re-anchor house when promo appears/disappears
    local promoTracker = GetControl("ZO_PromotionalEventTracker_TL");
    if promoTracker then
        promoTracker:SetHandler("OnShow", function ()
            zo_callLater(reapplyQuestTrackerAnchors, 50);
        end);
        promoTracker:SetHandler("OnHide", function ()
            zo_callLater(reapplyQuestTrackerAnchors, 50);
        end);
    end;

    self.questTrackerHooksRegistered = true;
end;

---Sets up a custom control wrapper for a game control
---@param customControlName string Name for the custom control
---@param gameControlName string Name of the game control to wrap
---@param width number Width of the custom control
---@param height number Height of the custom control
---@param defaultAnchor fun(customControl: userdata)? Function to set default anchor for new controls
---@param useAnchorFill boolean? If true, use AnchorFill instead of CENTER anchor (for TopLevelControls)
local function setupCustomControlWrapper(customControlName, gameControlName, width, height, defaultAnchor, useAnchorFill)
    local customControl = _G[customControlName];
    local isNewControl = false;
    if not customControl then
        customControl = WINDOW_MANAGER:CreateControl(customControlName, GuiRoot, CT_CONTROL);
        isNewControl = true;
    end;

    local gameControl = GetControl(gameControlName);
    if gameControl then
        customControl:SetDimensions(width, height);
    else
        customControl:SetDimensions(width, height);
    end;

    customControl:SetDrawLayer(DL_CONTROLS);

    if gameControl then
        -- Only set initial anchor if this is a new control
        if isNewControl and defaultAnchor then
            defaultAnchor(customControl);
        end;
        -- Always ensure the original container is anchored to our custom control
        gameControl:ClearAnchors();
        if useAnchorFill then
            -- For TopLevelControls that use AnchorFill, make them fill our custom control
            gameControl:SetAnchor(TOPLEFT, customControl, TOPLEFT, 0, 0);
            gameControl:SetAnchor(BOTTOMRIGHT, customControl, BOTTOMRIGHT, 0, 0);
        else
            gameControl:SetAnchor(CENTER, customControl, CENTER, 0, 0);
        end;
        -- Ensure game control inherits scale from custom control
        gameControl:SetInheritScale(true);
    end;
end;

---Sets up custom control wrappers for UI elements to enable proper positioning
function KhajiitFengShui:SetupCustomControls()
    -- Create a custom control to hold the player buffs/debuffs
    setupCustomControlWrapper(
        "KhajiitFengShui_PlayerBuffs",
        "ZO_BuffDebuffTopLevelSelfContainer",
        400,
        70,
        function (customControl)
            local playerAttribute = GetControl("ZO_PlayerAttribute");
            if playerAttribute then
                customControl:SetAnchor(CENTER, playerAttribute, TOP, 0, -40);
            end;
        end
    );

    -- Create a custom control to hold the target debuffs
    setupCustomControlWrapper(
        "KhajiitFengShui_TargetDebuffs",
        "ZO_BuffDebuffTopLevelTargetContainer",
        400,
        70,
        function (customControl)
            local targetFrame = GetControl("ZO_TargetUnitFramereticleover");
            if targetFrame then
                customControl:SetAnchor(CENTER, targetFrame, BOTTOM, 0, 40);
            end;
        end
    );

    -- Create a custom control for subtitles
    setupCustomControlWrapper(
        "KhajiitFengShui_Subtitles",
        "ZO_Subtitles",
        256,
        80,
        function (customControl)
            customControl:SetAnchor(CENTER, GuiRoot, BOTTOM, 0, -150);
        end
    );

    -- Create a custom control for objective meter
    setupCustomControlWrapper(
        "KhajiitFengShui_ObjectiveMeter",
        "ZO_ObjectiveCaptureMeter",
        128,
        128,
        function (customControl)
            customControl:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0);
        end
    );

    -- Create a custom control for player interaction
    setupCustomControlWrapper(
        "KhajiitFengShui_PlayerInteract",
        "ZO_PlayerToPlayerAreaPromptContainer",
        870,
        30,
        function (customControl)
            customControl:SetAnchor(CENTER, GuiRoot, BOTTOM, 0, -100);
        end
    );

    -- Create a custom control for synergy prompt
    setupCustomControlWrapper(
        "KhajiitFengShui_Synergy",
        "ZO_SynergyTopLevelContainer",
        200,
        50,
        function (customControl)
            customControl:SetAnchor(CENTER, GuiRoot, BOTTOM, 0, -200);
        end
    );

    -- Adventure Zone player score HUD: wrapper is the mover target; TopLevel fills wrapper (same pattern as buff containers)
    setupCustomControlWrapper(
        "KhajiitFengShui_AdvZoneHUD",
        "ZO_AdvZoneHUD_TopLevel",
        260,
        56,
        function (customControl)
            customControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 15, 15);
        end,
        true
    );

    -- Create a custom control for active combat tips
    setupCustomControlWrapper(
        "KhajiitFengShui_CombatTips",
        "ZO_ActiveCombatTipsTip",
        250,
        20,
        function (customControl)
            customControl:SetAnchor(CENTER, GuiRoot, BOTTOM, 0, -250);
        end
    );
end;

---Handles buff/debuff icon initialization for animation settings
---@param control userdata
function KhajiitFengShui:OnBuffDebuffIconInitialized(control)
    if self.savedVars and self.savedVars.buffAnimationsEnabled then
        control.showCooldown = true;
    end;
end;

---Registers buff animation hook
function KhajiitFengShui:RegisterBuffAnimationHook()
    if self.buffAnimationHookRegistered then
        return;
    end;
    if not SecurePostHook then
        return;
    end;
    SecurePostHook("ZO_BuffDebuffIcon_OnInitialized", GenerateClosure(self.OnBuffDebuffIconInitialized, self));
    self.buffAnimationHookRegistered = true;
end;

---Updates buff animation hook based on settings
function KhajiitFengShui:UpdateBuffAnimationHook()
    if self.savedVars and self.savedVars.buffAnimationsEnabled then
        self:RegisterBuffAnimationHook();
    end;
end;

---Applies global cooldown setting
function KhajiitFengShui:ApplyGlobalCooldownSetting()
    local enabled = self.savedVars and self.savedVars.globalCooldownEnabled;
    local desired = enabled == true;
    if self.globalCooldownActive ~= desired then
        ZO_ActionButtons_ToggleShowGlobalCooldown();
        self.globalCooldownActive = desired;
    end;
end;

---Gets current snap grid size
---@return number
function KhajiitFengShui:GetSnapSize()
    if not self.savedVars.grid.enabled then
        return 0;
    end;
    return self.savedVars.grid.size or self.defaults.grid.size;
end;

---Applies saved position to panel
---@param panel KhajiitFengShuiPanel
function KhajiitFengShui:ApplySavedPosition(panel)
    if not panel.handler then
        return;
    end;
    -- Don't apply position for disabled movers
    if not self:IsMoverEnabled(panel.definition.id) then
        return;
    end;

    if
        self.savedVars.pyramidLayoutEnabled
    and (
        panel.definition.id == "playerHealth"
        or panel.definition.id == "playerMagicka"
        or panel.definition.id == "playerStamina"
    )
    then
        self:ApplyPyramidLayout();
        return;
    end;

    -- For quest trackers / Adv Zone tracker, ensure valid dimensions before applying position
    local needsDimensionDeferral =
        panel.definition.id == "questTracker"
        or panel.definition.id == "questTrackerGamepad"
        or panel.definition.id == "advZoneHUDTracker";
    if needsDimensionDeferral then
        local control = panel.control;
        local controlWidth = control:GetWidth() or 0;
        local controlHeight = control:GetHeight() or 0;

        -- If dimensions are invalid, try to get from definition
        if controlWidth == 0 or controlHeight == 0 then
            local definition = panel.definition;
            if definition.width then
                controlWidth = ZO_Eval(definition.width, control, nil) or 300;
            end;
            if definition.height then
                controlHeight = ZO_Eval(definition.height, control, nil) or 200;
            end;
        end;

        -- If still invalid, delay application slightly
        if controlWidth == 0 or controlHeight == 0 then
            zo_callLater(function ()
                             self:ApplySavedPosition(panel);
                         end, 100);
            return;
        end;
    end;

    local hasCustom = self.savedVars.positions[panel.definition.id] ~= nil;
    local handler = panel.handler;
    local savedPosition = self.savedVars.positions[panel.definition.id];

    if savedPosition then
        handler:UpdatePosition(savedPosition);
        PanelUtils.applyControlAnchorFromPosition(panel, savedPosition, 0);
    else
        local left = panel.control:GetLeft();
        local top = panel.control:GetTop();
        local defaultPosition = { left = left; top = top };
        handler:UpdatePosition(defaultPosition);
        PanelUtils.applyControlAnchorFromPosition(panel, defaultPosition, 0);
    end;

    if panel.definition.preApply then
        panel.definition.preApply(panel.control, hasCustom);
    end;
    self:ApplyPanelScale(panel);

    if panel.definition.postApply then
        panel.definition.postApply(panel.control, hasCustom);
    end;

    -- Sync overlay size and position to match control after applying saved position
    SyncOverlaySize(self, panel);

    local message = self:BuildOverlayMessage(panel, panel.control:GetLeft(), panel.control:GetTop());
    UpdateOverlayLabel(panel, message);
    self:RefreshPanelState(panel);
end;

---Starts moving a control
---@param panelId string
function KhajiitFengShui:StartControlMove(panelId)
    local panel = self.panelLookup[panelId];
    if not (panel and panel.handler) then
        return;
    end;
    -- Don't start moving disabled movers
    if not self:IsMoverEnabled(panelId) then
        return;
    end;

    self.activePanelId = panelId;
    self:RefreshAllPanels();
    self:RefreshGridOverlay();
end;

---Handles move start event
---@param panel KhajiitFengShuiPanel
---@param handler LibCombatAlerts.MoveableControl
function KhajiitFengShui:OnMoveStart(panel, handler)
    local updateName = string.format("%s_MoveUpdate_%s", self.name, panel.definition.id);
    local panelId = panel.definition.id;
    local pyramidDrag = self.editModeActive
        and self.savedVars.pyramidLayoutEnabled
        and isPrimaryAttributePanelId(panelId);

    em:RegisterForUpdate(updateName, 0, function ()
        local left, top = PanelUtils.getAnchorPosition(handler);
        if pyramidDrag then
            self:UpdatePyramidLayoutFromPosition(panelId, left, top, false);
        else
            PanelUtils.applyControlAnchor(panel, left, top);
            local message = self:BuildOverlayMessage(panel, left, top);
            UpdateOverlayLabel(panel, message);
        end;
    end);
end;

---Updates pyramid layout from a moved panel position
---@param movedPanelId string
---@param left number
---@param top number
---@param applyGridSnapOnOffset boolean?
function KhajiitFengShui:UpdatePyramidLayoutFromPosition(movedPanelId, left, top, applyGridSnapOnOffset)
    local healthPanel = self.panelLookup["playerHealth"];
    local magickaPanel = self.panelLookup["playerMagicka"];
    local staminaPanel = self.panelLookup["playerStamina"];

    if
    not (
        healthPanel
        and healthPanel.handler
        and magickaPanel
        and magickaPanel.handler
        and staminaPanel
        and staminaPanel.handler
    )
    then
        return;
    end;

    local healthScale = self:GetPanelScale("playerHealth");
    local magickaScale = self:GetPanelScale("playerMagicka");
    local staminaScale = self:GetPanelScale("playerStamina");

    local healthWidth = getExpectedBarWidth(healthPanel, healthScale);
    local magickaWidth = getExpectedBarWidth(magickaPanel, magickaScale);
    local staminaWidth = getExpectedBarWidth(staminaPanel, staminaScale);

    local healthHeight = getExpectedBarHeight(healthPanel, healthScale);

    local screenWidth = GuiRoot:GetWidth();
    local screenHeight = GuiRoot:GetHeight();

    local alwaysExpanded = AttributeScaler and AttributeScaler.alwaysExpandedEnabled or false;
    local verticalSpacing = getPyramidVerticalSpacing(healthScale, magickaScale, staminaScale, alwaysExpanded);
    local horizontalSpacing = 0;
    local baseHealthTop = getPyramidBaseHealthTop(screenHeight, healthScale, magickaScale, staminaScale);
    local baseHealthLeft = (screenWidth - healthWidth) / 2;

    local offsetLeft, offsetTop;
    if movedPanelId == "playerHealth" then
        offsetLeft = left - baseHealthLeft;
        offsetTop = top - baseHealthTop;
    elseif movedPanelId == "playerMagicka" then
        local baseMagickaLeft = (screenWidth - magickaWidth - staminaWidth - horizontalSpacing) / 2;
        local baseMagickaTop = baseHealthTop + healthHeight + verticalSpacing;
        offsetLeft = left - baseMagickaLeft;
        offsetTop = top - baseMagickaTop;
    elseif movedPanelId == "playerStamina" then
        local baseMagickaLeft = (screenWidth - magickaWidth - staminaWidth - horizontalSpacing) / 2;
        local baseStaminaLeft = baseMagickaLeft + magickaWidth + horizontalSpacing;
        local baseStaminaTop = baseHealthTop + healthHeight + verticalSpacing;
        offsetLeft = left - baseStaminaLeft;
        offsetTop = top - baseStaminaTop;
    else
        return;
    end;

    if applyGridSnapOnOffset then
        local gridSize = self:GetSnapSize();
        if gridSize > 0 then
            offsetLeft = zo_roundToNearest(offsetLeft, gridSize);
            offsetTop = zo_roundToNearest(offsetTop, gridSize);
        end;
    end;

    self.savedVars.pyramidOffset = { left = offsetLeft; top = offsetTop };
    self:ApplyPyramidLayoutImmediate(false);
end;

---Handles move stop event
---@param panel KhajiitFengShuiPanel
---@param handler LibCombatAlerts.MoveableControl
---@param newPos KFS_Position?
---@param isExplicitStop boolean?
function KhajiitFengShui:OnMoveStop(panel, handler, newPos, isExplicitStop)
    local updateName = string.format("%s_MoveUpdate_%s", self.name, panel.definition.id);
    em:UnregisterForUpdate(updateName);

    -- Only apply pyramid layout updates when in edit mode
    -- When using settings move button, treat as individual bar movement
    if
        self.editModeActive
    and self.savedVars.pyramidLayoutEnabled
    and (
        panel.definition.id == "playerHealth"
        or panel.definition.id == "playerMagicka"
        or panel.definition.id == "playerStamina"
    )
    then
        local left, top = PanelUtils.getAnchorPosition(handler);
        self:UpdatePyramidLayoutFromPosition(panel.definition.id, left, top, true);
    else
        local position = newPos or handler:GetPosition(true);
        self.savedVars.positions[panel.definition.id] = PanelUtils.copyPosition(position);

        -- newPos is already snapped by LCA MoveableControl on move stop
        PanelUtils.applyControlAnchorFromPosition(panel, position, 0);

        if panel.definition.postApply then
            panel.definition.postApply(panel.control, true);
        end;

        SyncOverlaySize(self, panel);

        local left, top = PanelUtils.getAnchorPosition(handler);
        local message = self:BuildOverlayMessage(panel, left, top);
        UpdateOverlayLabel(panel, message);
    end;

    if isExplicitStop or IsInGamepadPreferredMode() then
        self.activePanelId = nil;
        self:RefreshAllPanels();
        self:RefreshGridOverlay();
    else
        self:RefreshAllPanels();
    end;
end;

---Creates overlay for panel
---@param panel KhajiitFengShuiPanel
---@return userdata
local function CreateOverlay(panel)
    local overlay, label = PanelUtils.createOverlay(panel.definition.id, panel.control);
    panel.label = label;
    return overlay;
end;

---Creates mover handler for panel
---@param panel KhajiitFengShuiPanel
function KhajiitFengShui:CreateMover(panel)
    if not panel then
        return;
    end;

    panel.overlay = CreateOverlay(panel);
    if not panel.overlay then
        return;
    end;
    local m_options = { color = 0x33DD33FF; size = 2 };
    panel.handler = LCA.MoveableControl:New(panel.overlay, m_options);
    if not panel.handler then
        return;
    end;

    panel.handler:RegisterCallback(
        string.format("%s_MoveStart_%s", self.name, panel.definition.id),
        LCA.EVENT_CONTROL_MOVE_START,
        function ()
            self:OnMoveStart(panel, panel.handler);
        end
    );
    panel.handler:RegisterCallback(
        string.format("%s_MoveStop_%s", self.name, panel.definition.id),
        LCA.EVENT_CONTROL_MOVE_STOP,
        function (newPos)
            self:OnMoveStop(panel, panel.handler, newPos);
        end
    );
    panel.gamepadActive = false;

    local snapSize = self:GetSnapSize();
    panel.handler:SetSnap(snapSize > 0 and snapSize or nil);
    panel.handler:ToggleLock(true);

    local panelId = panel.definition.id;
    local control = panel.control;
    if isPrimaryAttributePanelId(panelId) and control then
        local currentWidth = control:GetWidth() or 0;
        local currentHeight = control:GetHeight() or 0;
        if currentWidth == 0 or currentHeight == 0 then
            PanelUtils.applySizing(control, panel.definition.width, panel.definition.height);
        end;
    else
        PanelUtils.applySizing(control, panel.definition.width, panel.definition.height);
    end;

    self:ApplySavedPosition(panel);

    if panel.definition.id == "compass" then
        self:EnsureCompassHook();
    end;

    if panel.definition.id == "advZoneHUDTracker" then
        self:EnsureAdvZoneHUDTrackerHook();
    end;

    if isPrimaryAttributePanelId(panelId) then
        self:EnsurePlayerAttributeBarsHook();
    end;

    if panel.definition.id == "questTrackerGamepad" then
        self:EnsureQuestTrackerHooks();
    end;

    panel.moverEnabled = true;
end;

---Destroys mover resources for a panel
---@param panel KhajiitFengShuiPanel?
function KhajiitFengShui:DestroyMover(panel)
    MoverState.DestroyMover(self, panel);
end;

---Ensures a panel mover exists
---@param panelId string
function KhajiitFengShui:EnsurePanelMover(panelId)
    MoverState.EnsurePanelMover(self, panelId);
end;

---Enables or disables a panel mover
---@param panelId string
---@param enabled boolean
function KhajiitFengShui:SetMoverEnabled(panelId, enabled)
    MoverState.SetMoverEnabled(self, panelId, enabled);
end;

---Synchronizes mover state for all panels with saved variables
function KhajiitFengShui:SyncPanelMoverStates()
    MoverState.SyncPanelMoverStates(self);
end;

---Updates settings availability based on current panel states
function KhajiitFengShui:RefreshSettingsAvailability()
    if not (self.settingsController and self.settingsController.settingsPanel) then
        return;
    end;

    local pyramidEnabled = self.savedVars and self.savedVars.pyramidLayoutEnabled;
    for _, panel in ipairs(self.panels or {}) do
        local enabled = self:IsMoverEnabled(panel.definition.id);
        panel.moverEnabled = enabled;
        if enabled and not panel.handler then
            self:CreateMover(panel);
        elseif not enabled and panel.handler then
            -- Destroy handler if mover is disabled but handler still exists
            MoverState.DestroyMover(self, panel);
        end;

        local isPyramidBar = panel.definition.id == "playerHealth"
            or panel.definition.id == "playerMagicka"
            or panel.definition.id == "playerStamina";
        panel.moveDisabledByPyramid = pyramidEnabled and isPyramidBar;
    end;

    if self.settingsController and self.settingsController.RefreshDynamicControls then
        self.settingsController:RefreshDynamicControls();
    end;
end;

---Applies snap settings to all panels
function KhajiitFengShui:ApplySnapSettings()
    local snapSize = self:GetSnapSize();
    for _, panel in ipairs(self.panels) do
        if panel.handler and self:IsMoverEnabled(panel.definition.id) then
            panel.handler:SetSnap(snapSize > 0 and snapSize or nil);
        end;
    end;

    self:RefreshGridOverlay();
end;

---Refreshes grid overlay visibility and size
function KhajiitFengShui:RefreshGridOverlay()
    if not self.gridOverlay then
        return;
    end;

    local gridEnabled = self.savedVars and self.savedVars.grid and self.savedVars.grid.enabled;
    local snapSize = self:GetSnapSize();
    local shouldShow = gridEnabled and (self.editModeActive or self.activePanelId ~= nil);
    self.gridOverlay:Refresh(shouldShow, snapSize);
end;

---Enumerates all focusable panel IDs
---@param self KhajiitFengShui
---@return string[]
local function EnumerateFocusablePanelIds(self)
    local ids = {};
    for _, panel in ipairs(self.panels) do
        if panel.handler then
            table.insert(ids, panel.definition.id);
        end;
    end;
    return ids;
end;

---Clears edit mode focus
function KhajiitFengShui:ClearEditModeFocus()
    self.editModeFocusId = nil;
    self:RefreshAllPanels();
end;

---Sets edit mode focus to a panel
---@param panelId string?
function KhajiitFengShui:SetEditModeFocus(panelId)
    if not self.editModeActive then
        return;
    end;

    if panelId and self.panelLookup[panelId] and self.panelLookup[panelId].handler then
        self.editModeFocusId = panelId;
    else
        self.editModeFocusId = nil;
    end;

    self:RefreshAllPanels();
    self:RefreshKeybindStrip();
end;

---Selects first focusable panel
function KhajiitFengShui:SelectFirstFocusablePanel()
    local ids = EnumerateFocusablePanelIds(self);
    if #ids == 0 then
        self.editModeFocusId = nil;
        return;
    end;

    local target = self.editModeFocusId;
    if not target or not (self.panelLookup[target] and self.panelLookup[target].handler) then
        target = ids[1];
    end;
    self:SetEditModeFocus(target);
end;

---Cycles focused panel in direction
---@param direction integer
function KhajiitFengShui:CycleFocusedPanel(direction)
    if not (self.editModeActive and direction and direction ~= 0) then
        return;
    end;

    local ids = EnumerateFocusablePanelIds(self);
    local count = #ids;
    if count == 0 then
        return;
    end;

    local currentIndex = 1;
    for index, id in ipairs(ids) do
        if id == self.editModeFocusId then
            currentIndex = index;
            break;
        end;
    end;

    local nextIndex = ((currentIndex - 1 + direction) % count) + 1;
    self:SetEditModeFocus(ids[nextIndex]);
end;

---Shows edit mode hint
function KhajiitFengShui:ShowEditModeHint()
    if self.editModeHintShown then
        return;
    end;

    if IsInGamepadPreferredMode() then
        ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil, GetString(KFS_EDIT_MODE_HINT));
        self.editModeHintShown = true;
    end;
end;

---Activates action layer
function KhajiitFengShui:ActivateActionLayer()
    if not self.actionLayerName or self.actionLayerActive then
        return;
    end;
    PushActionLayerByName(self.actionLayerName);
    self.actionLayerActive = true;
end;

---Deactivates action layer
function KhajiitFengShui:DeactivateActionLayer()
    if not self.actionLayerName or not self.actionLayerActive then
        return;
    end;
    RemoveActionLayerByName(self.actionLayerName);
    self.actionLayerActive = false;
end;

---Ensures keybind descriptor is created
function KhajiitFengShui:EnsureKeybindDescriptor()
    if self.keybindStripDescriptor then
        return;
    end;

    self.actionLayerName = GetString(SI_KEYBINDINGS_LAYER_USER_INTERFACE_SHORTCUTS);

    local addon = self;
    self.keybindStripDescriptor =
    {
        {
            ethereal = true;
            name = function ()
                return GetString(KFS_KEYBIND_ENTER_EDIT_MODE);
            end;
            keybind = "UI_SHORTCUT_TERTIARY";
            visible = function ()
                return IsInGamepadPreferredMode() and not addon:IsEditModeActive();
            end;
            callback = function ()
                addon:SetEditModeActive(true);
            end;
        };
        {
            name = function ()
                return GetString(KFS_KEYBIND_EXIT_EDIT_MODE);
            end;
            keybind = "UI_SHORTCUT_NEGATIVE";
            visible = function ()
                return IsInGamepadPreferredMode() and addon:IsEditModeActive();
            end;
            callback = function ()
                addon:SetEditModeActive(false);
            end;
        };
        {
            name = function ()
                return GetString(KFS_KEYBIND_PREVIOUS_PANEL);
            end;
            keybind = "UI_SHORTCUT_INPUT_LEFT";
            gamepadPreferredKeybind = "UI_SHORTCUT_LEFT_SHOULDER";
            alignment = KEYBIND_STRIP_ALIGN_RIGHT;
            visible = function ()
                return IsInGamepadPreferredMode() and addon:IsEditModeActive();
            end;
            callback = function ()
                addon:CycleFocusedPanel(-1);
            end;
        };
        {
            name = function ()
                return GetString(KFS_KEYBIND_NEXT_PANEL);
            end;
            keybind = "UI_SHORTCUT_INPUT_RIGHT";
            gamepadPreferredKeybind = "UI_SHORTCUT_RIGHT_SHOULDER";
            alignment = KEYBIND_STRIP_ALIGN_RIGHT;
            visible = function ()
                return IsInGamepadPreferredMode() and addon:IsEditModeActive();
            end;
            callback = function ()
                addon:CycleFocusedPanel(1);
            end;
        };
        {
            name = function ()
                return GetString(KFS_KEYBIND_TOGGLE_LABELS);
            end;
            keybind = "UI_SHORTCUT_QUATERNARY";
            alignment = KEYBIND_STRIP_ALIGN_RIGHT;
            visible = function ()
                return IsInGamepadPreferredMode() and addon:IsEditModeActive();
            end;
            callback = function ()
                addon:ToggleLabels();
            end;
        };
    };
end;

---Removes keybind strip
function KhajiitFengShui:RemoveKeybindStrip()
    if not (self.keybindStripActive and self.keybindStripDescriptor) then
        return;
    end;

    KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor);
    self.keybindStripActive = false;

    self:ApplyKeybindStripSizing();

    if self.keybindFragmentSceneName then
        local scene = sceneManager:GetScene(self.keybindFragmentSceneName);
        if scene and scene:HasFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT) then
            scene:RemoveFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT);
        end;
        self.keybindFragmentSceneName = nil;
    end;
end;

local REDUCED_KEYBIND_STRIP_HEIGHT = 48;

---Applies keybind strip sizing based on edit mode
function KhajiitFengShui:ApplyKeybindStripSizing()
    local shouldReduce = self.editModeActive and IsInGamepadPreferredMode();
    if shouldReduce then
        if not self.keybindStripReduced then
            if KEYBIND_STRIP and KEYBIND_STRIP.control then
                self.keybindStripOriginalHeight = self.keybindStripOriginalHeight or KEYBIND_STRIP.control:GetHeight();
                KEYBIND_STRIP.control:SetHeight(REDUCED_KEYBIND_STRIP_HEIGHT);
            end;
            if ZO_KeybindStripGamepadBackground then
                self.keybindStripBackgroundOriginalHeight = self.keybindStripBackgroundOriginalHeight
                    or ZO_KeybindStripGamepadBackground:GetHeight();
                ZO_KeybindStripGamepadBackground:SetHeight(REDUCED_KEYBIND_STRIP_HEIGHT);
                if self.keybindStripBackgroundWasHidden == nil then
                    self.keybindStripBackgroundWasHidden = ZO_KeybindStripGamepadBackground:IsHidden();
                end;
                ZO_KeybindStripGamepadBackground:SetHidden(true);
            end;
            if ZO_KeybindStripGamepadBackgroundTexture then
                self.keybindStripBackgroundTextureOriginalHeight = self.keybindStripBackgroundTextureOriginalHeight
                    or ZO_KeybindStripGamepadBackgroundTexture:GetHeight();
                ZO_KeybindStripGamepadBackgroundTexture:SetHeight(REDUCED_KEYBIND_STRIP_HEIGHT);
                ZO_KeybindStripGamepadBackgroundTexture:SetHidden(true);
            end;
            if KEYBIND_STRIP and KEYBIND_STRIP.centerParent and not self.keybindStripCenterAdjusted then
                KEYBIND_STRIP.centerParent:ClearAnchors();
                KEYBIND_STRIP.centerParent:SetAnchor(BOTTOM, KEYBIND_STRIP.control, BOTTOM, 0, -6);
                self.keybindStripCenterAdjusted = true;
            end;
            self.keybindStripReduced = true;
        end;
    elseif self.keybindStripReduced then
        if KEYBIND_STRIP and KEYBIND_STRIP.control and self.keybindStripOriginalHeight then
            KEYBIND_STRIP.control:SetHeight(self.keybindStripOriginalHeight);
        end;
        if ZO_KeybindStripGamepadBackground and self.keybindStripBackgroundOriginalHeight then
            ZO_KeybindStripGamepadBackground:SetHeight(self.keybindStripBackgroundOriginalHeight);
        end;
        if ZO_KeybindStripGamepadBackgroundTexture and self.keybindStripBackgroundTextureOriginalHeight then
            ZO_KeybindStripGamepadBackgroundTexture:SetHeight(self.keybindStripBackgroundTextureOriginalHeight);
            ZO_KeybindStripGamepadBackgroundTexture:SetHidden(false);
        end;
        if KEYBIND_STRIP and KEYBIND_STRIP.centerParent and self.keybindStripCenterAdjusted then
            KEYBIND_STRIP.centerParent:ClearAnchors();
            KEYBIND_STRIP.centerParent:SetAnchor(CENTER, KEYBIND_STRIP.control, CENTER, 0, 0);
            self.keybindStripCenterAdjusted = false;
        end;
        if ZO_KeybindStripGamepadBackground then
            if self.keybindStripBackgroundWasHidden ~= nil then
                ZO_KeybindStripGamepadBackground:SetHidden(self.keybindStripBackgroundWasHidden);
            end;
        end;
        self.keybindStripBackgroundWasHidden = nil;
        self.keybindStripReduced = false;
    end;
end;

---Handles keybind scene state change
---@param sceneName string
---@param oldState integer?
---@param newState integer?
function KhajiitFengShui:OnKeybindSceneStateChange(sceneName, oldState, newState)
    newState = newState or oldState;
    if not IsInGamepadPreferredMode() then
        return;
    end;

    if not self.editModeActive then
        return;
    end;

    if newState == SCENE_SHOWING or newState == SCENE_SHOWN then
        local scene = sceneManager:GetScene(sceneName);
        if scene and not scene:HasFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT) then
            scene:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT);
            self.keybindFragmentSceneName = sceneName;
        end;
        if not self.keybindStripActive then
            self:RefreshKeybindStrip();
        end;
    elseif newState == SCENE_HIDDEN or newState == SCENE_HIDING then
        local scene = sceneManager:GetScene(sceneName);
        if scene and scene:HasFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT) then
            scene:RemoveFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT);
        end;
        if self.keybindFragmentSceneName == sceneName then
            self.keybindFragmentSceneName = nil;
        end;
        self:RemoveKeybindStrip();
    end;
end;

---Refreshes keybind strip
function KhajiitFengShui:RefreshKeybindStrip()
    self:EnsureKeybindDescriptor();
    if not self.keybindStripDescriptor then
        return;
    end;

    self:UpdateKeybindFragments();

    self:ApplyKeybindStripSizing();

    if not (self.editModeActive and IsInGamepadPreferredMode()) then
        self:RemoveKeybindStrip();
        return;
    end;

    local currentScene = sceneManager:GetCurrentScene();
    local currentName = currentScene and currentScene:GetName();
    local allowed = false;
    if currentName and self.keybindScenes then
        for _, name in ipairs(self.keybindScenes) do
            if name == currentName then
                allowed = true;
                break;
            end;
        end;
    end;

    if not allowed then
        self:RemoveKeybindStrip();
        return;
    end;

    currentScene = sceneManager:GetCurrentScene();
    if
        KEYBIND_STRIP_GAMEPAD_FRAGMENT
    and currentScene
    and not currentScene:HasFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
    then
        currentScene:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT);
        self.keybindFragmentSceneName = currentName;
    end;

    if self.keybindStripActive then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor);
    else
        KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor);
        self.keybindStripActive = true;
    end;
end;

---Registers a scene for keybind callbacks
---@param sceneName string
function KhajiitFengShui:RegisterKeybindScene(sceneName)
    if self.keybindSceneCallbacks[sceneName] then
        return;
    end;

    local scene = sceneManager:GetScene(sceneName);
    if not scene then
        return;
    end;

    scene:RegisterCallback(
        "StateChange",
        GenerateClosure(self.OnKeybindSceneStateChange, self, sceneName)
    );

    self.keybindSceneCallbacks[sceneName] = true;
end;

---Updates keybind fragments
function KhajiitFengShui:UpdateKeybindFragments()
    if not self.keybindScenes then
        return;
    end;

    -- Scene fragments manage the keybind strip visibility. No-op here.
end;

---Initializes keybind strip
function KhajiitFengShui:InitializeKeybindStrip()
    if not KEYBIND_STRIP then
        return;
    end;

    self:EnsureKeybindDescriptor();
    self.keybindScenes = { "hud"; "hudui"; "gamepadInteract" };
    for _, sceneName in ipairs(self.keybindScenes) do
        self:RegisterKeybindScene(sceneName);
    end;
    if self.editModeActive then
        self:RefreshKeybindStrip();
    end;
end;

---Stops control movement
function KhajiitFengShui:StopControlMove()
    if not self.activePanelId then
        return;
    end;
    local panel = self.panelLookup[self.activePanelId];
    if panel and panel.handler then
        local position = panel.handler:GetPosition(true);
        self:OnMoveStop(panel, panel.handler, position, true);
    end;
end;

---Checks if edit mode is active
---@return boolean
function KhajiitFengShui:IsEditModeActive()
    return self.editModeActive == true;
end;

---Gets current profile mode
---@return string
function KhajiitFengShui:GetProfileMode()
    return self.profileMode or self.defaults.profileMode;
end;

---Resolves saved vars for a mode
---@param self KhajiitFengShui
---@param mode string
---@return KFS_SavedVars?
local function ResolveSavedVarsForMode(self, mode)
    if mode == "character" then
        return self.characterSavedVars;
    end;
    return self.accountSavedVars;
end;

---Sets profile mode
---@param mode string
---@param suppressRefresh boolean?
function KhajiitFengShui:SetProfileMode(mode, suppressRefresh)
    if not mode or mode ~= "character" then
        mode = "account";
    end;

    local target = ResolveSavedVarsForMode(self, mode);
    if not target then
        return;
    end;

    EnsureSavedVarStructure(target, self.defaults);

    self.profileMode = mode;
    if self.accountSavedVars then
        self.accountSavedVars.profileMode = mode;
    end;

    self.savedVars = target;
    self:SyncPanelMoverStates();

    if suppressRefresh then
        return;
    end;

    self:UpdateBuffAnimationHook();
    self:ApplyGlobalCooldownSetting();
    self:ApplyAllPositions();
    self:ApplySnapSettings();
    self:RefreshAllPanels();
    self:RefreshGridOverlay();
end;

---Sets edit mode active state
---@param active boolean
function KhajiitFengShui:SetEditModeActive(active)
    local shouldEnable = active == true;
    if self.editModeActive == shouldEnable then
        return;
    end;

    self.editModeActive = shouldEnable;

    if shouldEnable then
        self:SelectFirstFocusablePanel();
        self:ActivateActionLayer();
    else
        self:ClearEditModeFocus();
        self:DeactivateActionLayer();
    end;

    self.activePanelId = nil;

    self:RefreshAllPanels();
    self:RefreshGridOverlay();
    self:RefreshKeybindStrip();

    local message = shouldEnable and GetString(KFS_EDIT_MODE_ENABLED) or GetString(KFS_EDIT_MODE_DISABLED);

    CHAT_ROUTER:AddSystemMessage(message);

    if shouldEnable then
        self:ShowEditModeHint();
    end;
end;

---Toggles edit mode
function KhajiitFengShui:ToggleEditMode()
    self:SetEditModeActive(not self.editModeActive);
end;

---Toggles label visibility
function KhajiitFengShui:ToggleLabels()
    if not self.savedVars then
        return;
    end;

    if not self:IsEditModeActive() then
        return;
    end;

    self.savedVars.showAllLabels = not self.savedVars.showAllLabels;
    local status = self.savedVars.showAllLabels and "all labels visible" or "only active label visible";
    CHAT_ROUTER:AddSystemMessage(string.format("[KhajiitFengShui] Labels: %s", status));

    self:RefreshAllPanels();
end;

---Resets all positions and scales
function KhajiitFengShui:ResetPositions()
    local preservePyramid = self.savedVars.pyramidLayoutEnabled;
    local preservePyramidOffset = preservePyramid and PanelUtils.copyPosition(self.savedVars.pyramidOffset);

    self.savedVars.positions = {};
    self.savedVars.scales = {};

    if preservePyramid and preservePyramidOffset then
        self.savedVars.pyramidOffset = preservePyramidOffset;
    else
        self.savedVars.pyramidOffset = PanelUtils.copyPosition(self.defaults.pyramidOffset);
    end;

    ReloadUI("ingame");
end;

---Handles target frame creation
---@param targetFrame { GetPrimaryControl: fun(): userdata }
function KhajiitFengShui:OnTargetFrameCreated(targetFrame)
    local definition = self.definitionLookup and self.definitionLookup.targetFrame;
    if not definition then
        return;
    end;

    local control = targetFrame and targetFrame.GetPrimaryControl and targetFrame:GetPrimaryControl();
    if control then
        definition.controlName = control:GetName();
    end;

    local panel = self:TryCreatePanel(definition);
    if not panel then
        return;
    end;

    if control then
        panel.control = control;
    end;

    if panel.control and not panel.defaultPosition then
        panel.defaultPosition =
        {
            left = panel.control:GetLeft() or 0;
            top = panel.control:GetTop() or 0;
        };
    end;

    if panel.control then
        self:ApplySavedPosition(panel);
    end;

    if panel.definition.id == "compass" then
        self:EnsureCompassHook();
    end;

    if panel.definition.id == "advZoneHUDTracker" then
        self:EnsureAdvZoneHUDTrackerHook();
    end;

    if self.settingsController then
        self.settingsController:AddPanelSetting(panel);
    end;
end;

---Handles scene state change
---@param oldState integer
---@param newState integer
function KhajiitFengShui:OnSceneChange(oldState, newState)
    if not self.activePanelId then
        return;
    end;

    if newState == SCENE_SHOWN then
        for _, panel in ipairs(self.panels) do
            if panel.overlay then
                panel.overlay:SetHidden(true);
            end;
        end;
        self:RefreshKeybindStrip();
    elseif newState == SCENE_HIDDEN then
        self:RefreshAllPanels();
        self:RefreshKeybindStrip();
    end;
end;

---Initializes all panels
function KhajiitFengShui:InitializePanels()
    self.definitionLookup = {};
    self.panels = {};
    self.panelLookup = {};

    -- Setup custom control wrappers before creating panels
    self:SetupCustomControls();

    for _, definition in ipairs(PanelDefinitions.getAll()) do
        self.definitionLookup[definition.id] = definition;
        self:TryCreatePanel(definition);
    end;

    self:RefreshAllPanels();

    local scene = sceneManager:GetScene("gameMenuInGame");
    if scene then
        scene:RegisterCallback("StateChange", GenerateClosure(self.OnSceneChange, self));
    end;
end;

---Applies all saved positions
function KhajiitFengShui:ApplyAllPositions()
    if self.savedVars.pyramidLayoutEnabled then
        self:ApplyPyramidLayout();
    end;
    for _, panel in ipairs(self.panels) do
        if
        not (
            self.savedVars.pyramidLayoutEnabled
            and (
                panel.definition.id == "playerHealth"
                or panel.definition.id == "playerMagicka"
                or panel.definition.id == "playerStamina"
            )
        )
        then
            self:ApplySavedPosition(panel);
        end;
    end;

    self:ApplyAllUserHiddenStates();
end;

---Applies pyramid layout to attribute bars (synchronous core)
---@param allowDefer boolean? When true, retry after a short delay if bar dimensions are not ready
function KhajiitFengShui:ApplyPyramidLayoutImmediate(allowDefer)
    local healthPanel = self.panelLookup["playerHealth"];
    local magickaPanel = self.panelLookup["playerMagicka"];
    local staminaPanel = self.panelLookup["playerStamina"];

    if
    not (
        healthPanel
        and healthPanel.handler
        and magickaPanel
        and magickaPanel.handler
        and staminaPanel
        and staminaPanel.handler
    )
    then
        return;
    end;

    local healthScale = self:GetPanelScale("playerHealth");
    local magickaScale = self:GetPanelScale("playerMagicka");
    local staminaScale = self:GetPanelScale("playerStamina");

    self:ApplyPanelScale(healthPanel);
    self:ApplyPanelScale(magickaPanel);
    self:ApplyPanelScale(staminaPanel);

    local healthWidth = getExpectedBarWidth(healthPanel, healthScale);
    local magickaWidth = getExpectedBarWidth(magickaPanel, magickaScale);
    local staminaWidth = getExpectedBarWidth(staminaPanel, staminaScale);
    local healthHeight = getExpectedBarHeight(healthPanel, healthScale);

    if allowDefer and (healthWidth <= 0 or magickaWidth <= 0 or staminaWidth <= 0 or healthHeight <= 0) then
        zo_callLater(function ()
                         self:ApplyPyramidLayoutImmediate(false);
                     end, 100);
        return;
    end;

    local screenWidth = GuiRoot:GetWidth();
    local screenHeight = GuiRoot:GetHeight();

    local alwaysExpanded = AttributeScaler and AttributeScaler.alwaysExpandedEnabled or false;
    local verticalSpacing = getPyramidVerticalSpacing(healthScale, magickaScale, staminaScale, alwaysExpanded);
    local horizontalSpacing = 0;
    local baseHealthTop = getPyramidBaseHealthTop(screenHeight, healthScale, magickaScale, staminaScale);
    local baseHealthLeft = (screenWidth - healthWidth) / 2;

    local offset = self.savedVars.pyramidOffset or { left = 0; top = 0 };
    local healthTop = baseHealthTop + (offset.top or 0);
    local healthLeft = baseHealthLeft + (offset.left or 0);

    local magickaTop = healthTop + healthHeight + verticalSpacing;
    local magickaLeft = (screenWidth - magickaWidth - staminaWidth - horizontalSpacing) / 2 + (offset.left or 0);

    local staminaTop = magickaTop;
    local staminaLeft = magickaLeft + magickaWidth + horizontalSpacing;

    local healthPos = { left = healthLeft; top = healthTop };
    healthPanel.handler:UpdatePosition(healthPos);
    PanelUtils.applyControlAnchor(healthPanel, healthLeft, healthTop);
    SyncOverlaySize(self, healthPanel);
    local message = self:BuildOverlayMessage(healthPanel, healthLeft, healthTop);
    UpdateOverlayLabel(healthPanel, message);

    local magickaPos = { left = magickaLeft; top = magickaTop };
    magickaPanel.handler:UpdatePosition(magickaPos);
    PanelUtils.applyControlAnchor(magickaPanel, magickaLeft, magickaTop);
    SyncOverlaySize(self, magickaPanel);
    message = self:BuildOverlayMessage(magickaPanel, magickaLeft, magickaTop);
    UpdateOverlayLabel(magickaPanel, message);

    local staminaPos = { left = staminaLeft; top = staminaTop };
    staminaPanel.handler:UpdatePosition(staminaPos);
    PanelUtils.applyControlAnchor(staminaPanel, staminaLeft, staminaTop);
    SyncOverlaySize(self, staminaPanel);
    message = self:BuildOverlayMessage(staminaPanel, staminaLeft, staminaTop);
    UpdateOverlayLabel(staminaPanel, message);

    self:RefreshPanelState(healthPanel);
    self:RefreshPanelState(magickaPanel);
    self:RefreshPanelState(staminaPanel);
end;

---Applies pyramid layout to attribute bars
function KhajiitFengShui:ApplyPyramidLayout()
    self:ApplyPyramidLayoutImmediate(true);
end;

--hide reticle if disabled
function KhajiitFengShui:RedirectReticleContainer()
    local reticleEnabled = self.savedVars.reticleEnabled;
    if not reticleEnabled then
        ZO_ReticleContainerReticle:SetTexture("/esoui/art/icons/heraldrycrests_misc_blank_01.dds");
    end;
end;

---Handles player activated event
---@param eventId integer
---@param initial boolean
function KhajiitFengShui:EVENT_PLAYER_ACTIVATED(eventId, initial)
    self:RedirectReticleContainer();
    self:ApplyAllUserHiddenStates();
    -- Ensure custom control wrappers are set up
    zo_callLater(GenerateFlatClosure(self.SetupCustomControls, self), 100);
    zo_callLater(GenerateFlatClosure(self.ApplyAllPositions, self), 200);
end;

---Handles addon loaded event
---@param event integer
---@param addonName string
function KhajiitFengShui:OnAddOnLoaded(event, addonName)
    if addonName ~= self.name then
        return;
    end;

    em:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED);

    LCA = LibCombatAlerts;

    self.accountSavedVars = ZO_SavedVars:NewAccountWide("KhajiitFengShui_SavedVariables", 1, nil, self.defaults);
    self.characterSavedVars = ZO_SavedVars:NewCharacterIdSettings("KhajiitFengShui_SavedVariables", 1, nil, self.defaults);

    EnsureSavedVarStructure(self.accountSavedVars, self.defaults);
    EnsureSavedVarStructure(self.characterSavedVars, self.defaults);

    self.accountSavedVars.profileMode = self.accountSavedVars.profileMode or self.defaults.profileMode;
    self:SetProfileMode(self.accountSavedVars.profileMode, true);

    self:UpdateBuffAnimationHook();
    self:ApplyGlobalCooldownSetting();

    -- Hook boss bar to hide it if disabled
    if BOSS_BAR then
        local bossBarEnabled = self.savedVars.bossBarEnabled;
        local RefreshBossHealthBar = function (bossBarSelf, smoothAnimate)
            local totalHealth = 0;
            local totalMaxHealth = 0;

            for _, bossEntry in pairs(bossBarSelf.bossHealthValues) do
                totalHealth = totalHealth + bossEntry.health;
                totalMaxHealth = totalMaxHealth + bossEntry.maxHealth;
            end;

            local halfHealth = zo_floor(totalHealth / 2);
            local halfMax = zo_floor(totalMaxHealth / 2);
            for i = 1, #bossBarSelf.bars do
                ZO_StatusBar_SmoothTransition(bossBarSelf.bars[i], halfHealth, halfMax, not smoothAnimate);
            end;
            bossBarSelf.healthText:SetText(ZO_FormatResourceBarCurrentAndMax(totalHealth, totalMaxHealth));

            -- Hide or show boss bar based on setting
            if COMPASS_FRAME then
                COMPASS_FRAME:SetBossBarActive(bossBarEnabled and totalHealth > 0);
            end;
        end;
        rawset(BOSS_BAR, "RefreshBossHealthBar", RefreshBossHealthBar);
    end;

    if self.savedVars.alwaysExpandedBars then
        -- Hook OnValueChanged to force expanded state when enabled
        ZO_PreHook(ZO_UnitVisualizer_ShrinkExpandModule, "OnValueChanged", function (moduleself, bar, info, stat, instant)
            -- Force expanded state and width
            info.state = ATTRIBUTE_BAR_STATE_EXPANDED;
            bar:SetWidth(moduleself.expandedWidth);
            bar.bgContainer:SetWidth(moduleself.expandedWidth);
            -- Prevent original method from running
            return true;
        end);

        -- Force re-initialization if bars were already created before the hook
        local module = PLAYER_ATTRIBUTE_BARS and PLAYER_ATTRIBUTE_BARS.attributeVisualizer;
        if module then
            for _, visualModule in pairs(module.visualModules) do
                if visualModule.InitializeBarValues then
                    visualModule:InitializeBarValues();
                end;
            end;
        end;
    end;

    AttributeScaler:SetAlwaysExpanded(self.savedVars.alwaysExpandedBars);

    self:InitializePanels();
    self:EnsureAdvZoneHUDTrackerHook();
    self:EnsurePlayerAttributeBarsHook();
    self.settingsController = SettingsController:New(self);
    self.settingsController:CreateSettingsMenu();
    self:ApplyAllPositions();
    self:ApplySnapSettings();
    self:RefreshSettingsAvailability();

    self.editModeController = EditModeController:New(self);
    self.editModeController:Initialize();

    self.gridOverlay = GridOverlay:New();
    self:RefreshGridOverlay();

    self:InitializeKeybindStrip();

    CALLBACK_MANAGER:RegisterCallback("TargetFrameCreated", GenerateClosure(self.OnTargetFrameCreated, self));

    em:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, GenerateClosure(self.EVENT_PLAYER_ACTIVATED, self));

    em:RegisterForEvent(
        self.name,
        EVENT_GAMEPAD_PREFERRED_MODE_CHANGED,
        GenerateFlatClosure(self.OnGamepadPreferredModeChanged, self)
    );
end;

---Handles preferred mode changes to refresh keybinds
function KhajiitFengShui:OnGamepadPreferredModeChanged()
    self:UpdateKeybindFragments();
    self:RefreshKeybindStrip();
end;

em:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, GenerateClosure(KhajiitFengShui.OnAddOnLoaded, KhajiitFengShui));
