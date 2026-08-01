---@class KFS_AttributeScaler
---@field entries table<userdata, KFS_AttributeScalerEntry> Map of controls to scale entries
---@field shrinkExpandModule { barInfo: table, barControls: table, normalWidth: number, expandedWidth: number, shrunkWidth: number, OnValueChanged: function } Shrink/expand visual module reference
---@field originalWidths { normalWidth: number?, expandedWidth: number?, shrunkWidth: number? } Original bar widths before scaling
---@field statScales table<integer, number> Current scale per stat type
---@field eventsRegistered boolean Whether events have been registered
---@field alwaysExpandedEnabled boolean Whether bars should always be expanded
local AttributeScaler = {};
AttributeScaler.__index = AttributeScaler;

local EVENT_NAMESPACE = "KFS_AttributeScaler";

---@class KFS_AttributeScalerEntry
---@field control userdata The attribute bar control
---@field overlay userdata Overlay control reference
---@field scale number Current scale factor
---@field panel KhajiitFengShuiPanel Panel reference

local POWER_TYPE_TO_CONTROL =
{
    [COMBAT_MECHANIC_FLAGS_HEALTH] = ZO_PlayerAttributeHealth;
    [COMBAT_MECHANIC_FLAGS_MAGICKA] = ZO_PlayerAttributeMagicka;
    [COMBAT_MECHANIC_FLAGS_STAMINA] = ZO_PlayerAttributeStamina;
    [COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA] = ZO_PlayerAttributeMountStamina;
    [COMBAT_MECHANIC_FLAGS_WEREWOLF] = ZO_PlayerAttributeWerewolf;
};

local STAT_TO_CONTROL =
{
    [STAT_HEALTH_MAX] = ZO_PlayerAttributeHealth;
    [STAT_MAGICKA_MAX] = ZO_PlayerAttributeMagicka;
    [STAT_STAMINA_MAX] = ZO_PlayerAttributeStamina;
    [STAT_MOUNT_STAMINA_MAX] = ZO_PlayerAttributeMountStamina;
};

local PRIMARY_STATS =
{
    { statType = STAT_HEALTH_MAX;  attributeType = ATTRIBUTE_HEALTH;  powerType = COMBAT_MECHANIC_FLAGS_HEALTH  };
    { statType = STAT_MAGICKA_MAX; attributeType = ATTRIBUTE_MAGICKA; powerType = COMBAT_MECHANIC_FLAGS_MAGICKA };
    { statType = STAT_STAMINA_MAX; attributeType = ATTRIBUTE_STAMINA; powerType = COMBAT_MECHANIC_FLAGS_STAMINA };
};

---Creates new AttributeScaler instance
---@return KFS_AttributeScaler
function AttributeScaler:New()
    local scaler =
    {
        entries = {};
        shrinkExpandModule = nil;
        originalWidths = {};
        statScales = {};
        eventsRegistered = false;
        alwaysExpandedEnabled = false;
    };
    return setmetatable(scaler, self);
end;

---Finds the attribute bar shrink/expand module
---@return table?
local function findShrinkExpandModule()
    if not PLAYER_ATTRIBUTE_BARS or not PLAYER_ATTRIBUTE_BARS.attributeVisualizer then
        return nil;
    end;

    local visualizer = PLAYER_ATTRIBUTE_BARS.attributeVisualizer;
    for _, module in pairs(visualizer.visualModules) do
        if module and module.IsUnitVisualRelevant then
            if module:IsUnitVisualRelevant(ATTRIBUTE_VISUAL_INCREASED_MAX_POWER, STAT_HEALTH_MAX) then
                return module;
            end;
        end;
    end;

    return nil;
end;

---Captures original bar widths from the module
---@return boolean success
function AttributeScaler:CaptureOriginalWidths()
    local module = findShrinkExpandModule();
    if not module then
        return false;
    end;

    if not self.originalWidths.normalWidth then
        self.originalWidths.normalWidth = module.normalWidth;
        self.originalWidths.expandedWidth = module.expandedWidth;
        self.originalWidths.shrunkWidth = module.shrunkWidth;
    end;

    self.shrinkExpandModule = module;
    return true;
end;

---Gets stat type for a control
---@param control userdata
---@return integer?
local function getStatTypeForControl(control)
    for _, stat in ipairs(PRIMARY_STATS) do
        local expectedControl = STAT_TO_CONTROL[stat.statType];
        if expectedControl == control then
            return stat.statType;
        end;
    end;
    return nil;
end;

---Checks if control uses shrink/expand module
---@param control userdata
---@return boolean
local function usesShrinkExpandModule(control)
    local statType = getStatTypeForControl(control);
    return statType ~= nil;
end;

---Applies scale to a control with shrink/expand support
---@param control userdata?
---@param scale number
function AttributeScaler:ApplyScaleToControl(control, scale)
    if not control then
        return;
    end;

    local controlName = control:GetName();
    if controlName == "ZO_PlayerAttributeMountStamina" then
        control:SetScale(scale);
    else
        control:SetTransformScale(scale);
    end;

    if not usesShrinkExpandModule(control) then
        return;
    end;

    if not self.shrinkExpandModule then
        if not self:CaptureOriginalWidths() then
            zo_callLater(function ()
                             self:ApplyScaleToControl(control, scale);
                         end, 50);
            return;
        end;
    end;

    local module = self.shrinkExpandModule;
    if not module then
        return;
    end;

    if not self.originalWidths.normalWidth then
        self:CaptureOriginalWidths();
    end;

    local statType = getStatTypeForControl(control);
    if not statType then
        return;
    end;

    self.statScales[statType] = scale;

    local origNormal = self.originalWidths.normalWidth or module.normalWidth;
    local origExpanded = self.originalWidths.expandedWidth or module.expandedWidth;
    local origShrunk = self.originalWidths.shrunkWidth or module.shrunkWidth;

    local alwaysExpanded = self.alwaysExpandedEnabled or false;

    if module.barInfo and module.barInfo[statType] and module.barControls and module.barControls[statType] then
        local info = module.barInfo[statType];
        local barControl = module.barControls[statType];

        if alwaysExpanded then
            module.normalWidth = zo_round(origExpanded * scale);
            module.expandedWidth = zo_round(origExpanded * scale);
            module.shrunkWidth = zo_round(origExpanded * scale);
        else
            module.normalWidth = zo_round(origNormal * scale);
            module.expandedWidth = zo_round(origExpanded * scale);
            module.shrunkWidth = zo_round(origShrunk * scale);
        end;

        if info.value == nil then
            info.value = 0;
        end;
        if barControl.value == nil then
            barControl.value = 0;
        end;

        zo_callLater(function ()
                         if module.OnValueChanged then
                             module:OnValueChanged(barControl, info, statType, true);
                         end;
                     end, 0);
    end;
end;

---Reapplies all registered scales
function AttributeScaler:ReapplyAll()
    for control, entry in pairs(self.entries) do
        if entry and entry.scale then
            local currentControl = control;
            if control and control:GetName() == "ZO_PlayerAttributeMountStamina" then
                currentControl = GetControl("ZO_PlayerAttributeMountStamina");
                if currentControl and currentControl ~= control then
                    entry.control = currentControl;
                    self.entries[currentControl] = entry;
                    self.entries[control] = nil;
                end;
            end;
            if currentControl then
                self:ApplyScaleToControl(currentControl, entry.scale);
                if entry.panel and entry.panel.overlay then
                    local addon = KhajiitFengShui;
                    if addon and addon.SyncPanelOverlaySize then
                        addon:SyncPanelOverlaySize(entry.panel);
                    else
                        KhajiitFengShui.PanelUtils.syncOverlaySize(entry.panel);
                    end;
                end;
            end;
        end;
    end;
end;

---Handles attribute visual changes
--- @param eventId integer
--- @param unitTag string
--- @param unitAttributeVisual UnitAttributeVisual
--- @param statType DerivedStats
--- @param attributeType Attributes
--- @param powerType CombatMechanicFlags
--- @param oldValue number
--- @param newValue number
--- @param oldMaxValue number
--- @param newMaxValue number
--- @param sequenceId integer
---@diagnostic disable-next-line: unused-local
function AttributeScaler:OnAttributeVisualChange(eventId, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue, sequenceId)
    if unitTag ~= "player" then
        return;
    end;

    local control = STAT_TO_CONTROL[statType] or POWER_TYPE_TO_CONTROL[powerType];
    if control then
        local entry = self.entries[control];
        if entry and entry.scale then
            self:ApplyScaleToControl(control, entry.scale);
        end;
    end;
end;

---Schedules mount stamina scale reapplies after UI changes
---@param delay integer?
function AttributeScaler:ScheduleMountReapply(delay)
    zo_callLater(GenerateFlatClosure(self.ReapplyMountStaminaScale, self), delay or 0);
end;

---Reapplies mount stamina scale while keeping entry references in sync
function AttributeScaler:ReapplyMountStaminaScale()
    local mountControl = GetControl("ZO_PlayerAttributeMountStamina");
    if mountControl then
        local entry = self.entries[mountControl];
        if not entry then
            for control, existingEntry in pairs(self.entries) do
                if
                    existingEntry
                and existingEntry.control
                and existingEntry.control:GetName() == "ZO_PlayerAttributeMountStamina"
                then
                    entry = existingEntry;
                    self.entries[mountControl] = entry;
                    entry.control = mountControl;
                    if control ~= mountControl then
                        self.entries[control] = nil;
                    end;
                    break;
                end;
            end;
        end;
        if entry and entry.scale then
            self:ApplyScaleToControl(mountControl, entry.scale);
        end;
    end;
end;

---Handles mount power updates to keep scaling applied
function AttributeScaler:OnMountPowerUpdate(_, unitTag, _, powerType)
    if unitTag == "player" and powerType == COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA then
        self:ScheduleMountReapply(50);
    end;
end;

---Handles UI setting changes relevant to resource bars
function AttributeScaler:OnInterfaceSettingChanged(_, settingType, settingId)
    if settingType == SETTING_TYPE_UI and settingId == UI_SETTING_SHOW_RESOURCE_BARS then
        self:ScheduleMountReapply(50);
    end;
end;

---Applies scaling adjustments after gamepad mode toggles
function AttributeScaler:ApplyGamepadModeChanges()
    self:ReapplyAll();
    self:ReapplyMountStaminaScale();
end;

---Removes scaling for a panel and restores its default scale
---@param panel KhajiitFengShuiPanel?
function AttributeScaler:Remove(panel)
    if not panel or not panel.control then
        return;
    end;

    local control = panel.control;
    self.entries[control] = nil;

    local defaultScale = panel.defaultScale or 1;
    local statType = getStatTypeForControl(control);
    if statType then
        self.statScales[statType] = defaultScale;
    end;

    self:ApplyScaleToControl(control, defaultScale);
end;

---Handles preferred mode changes to sync scalers
function AttributeScaler:OnGamepadPreferredModeChanged()
    zo_callLater(GenerateFlatClosure(self.ApplyGamepadModeChanges, self), 200);
end;

---Ensures event handlers are registered
function AttributeScaler:EnsureEvents()
    if self.eventsRegistered then
        return;
    end;

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED);
    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE,
        EVENT_PLAYER_ACTIVATED,
        GenerateFlatClosure(self.ReapplyAll, self)
    );

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_VISUAL_ADDED", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED);
    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE .. "_VISUAL_ADDED",
        EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED,
        GenerateClosure(self.OnAttributeVisualChange, self)
    );
    EVENT_MANAGER:AddFilterForEvent(
        EVENT_NAMESPACE .. "_VISUAL_ADDED",
        EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED,
        REGISTER_FILTER_UNIT_TAG,
        "player"
    );

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_VISUAL_REMOVED", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED);
    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE .. "_VISUAL_REMOVED",
        EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED,
        GenerateClosure(self.OnAttributeVisualChange, self)
    );
    EVENT_MANAGER:AddFilterForEvent(
        EVENT_NAMESPACE .. "_VISUAL_REMOVED",
        EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED,
        REGISTER_FILTER_UNIT_TAG,
        "player"
    );

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_VISUAL_UPDATED", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED);
    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE .. "_VISUAL_UPDATED",
        EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED,
        GenerateClosure(self.OnAttributeVisualChange, self)
    );
    EVENT_MANAGER:AddFilterForEvent(
        EVENT_NAMESPACE .. "_VISUAL_UPDATED",
        EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED,
        REGISTER_FILTER_UNIT_TAG,
        "player"
    );

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_MOUNTED", EVENT_MOUNTED_STATE_CHANGED);
    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE .. "_MOUNTED",
        EVENT_MOUNTED_STATE_CHANGED,
        GenerateFlatClosure(self.ScheduleMountReapply, self, 100)
    );

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_MOUNT_POWER", EVENT_POWER_UPDATE);
    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE .. "_MOUNT_POWER",
        EVENT_POWER_UPDATE,
        GenerateClosure(self.OnMountPowerUpdate, self)
    );
    EVENT_MANAGER:AddFilterForEvent(
        EVENT_NAMESPACE .. "_MOUNT_POWER",
        EVENT_POWER_UPDATE,
        REGISTER_FILTER_POWER_TYPE,
        COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA
    );

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_INTERFACE_SETTING", EVENT_INTERFACE_SETTING_CHANGED);
    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE .. "_INTERFACE_SETTING",
        EVENT_INTERFACE_SETTING_CHANGED,
        GenerateClosure(self.OnInterfaceSettingChanged, self)
    );
    EVENT_MANAGER:AddFilterForEvent(
        EVENT_NAMESPACE .. "_INTERFACE_SETTING",
        EVENT_INTERFACE_SETTING_CHANGED,
        REGISTER_FILTER_SETTING_SYSTEM_TYPE,
        SETTING_TYPE_UI
    );

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_GAMEPAD_MODE", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED);
    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE .. "_GAMEPAD_MODE",
        EVENT_GAMEPAD_PREFERRED_MODE_CHANGED,
        GenerateFlatClosure(self.OnGamepadPreferredModeChanged, self)
    );

    self.eventsRegistered = true;
end;

---Sets always expanded mode for attribute bars
---@param enabled boolean
function AttributeScaler:SetAlwaysExpanded(enabled)
    self.alwaysExpandedEnabled = enabled == true;

    -- Note: The actual expansion logic is handled by the PreHook in KhajiitFengShui.lua
    -- This method is kept for compatibility and potential future enhancements

    self:ReapplyAll();
end;

---Applies scale to a panel
---@param panel KhajiitFengShuiPanel?
---@param scale number?
function AttributeScaler:Apply(panel, scale)
    if not panel or not panel.control or not scale then
        return;
    end;

    self:EnsureEvents();

    local control = panel.control;
    self.entries[control] =
    {
        control = control;
        overlay = panel.overlay;
        scale = scale;
        panel = panel;
    };

    self:ApplyScaleToControl(control, scale);

    if panel.overlay then
        local addon = KhajiitFengShui;
        if addon and addon.SyncPanelOverlaySize then
            addon:SyncPanelOverlaySize(panel);
        else
            KhajiitFengShui.PanelUtils.syncOverlaySize(panel);
        end;
    end;
end;

KhajiitFengShui.AttributeScaler = AttributeScaler:New();
