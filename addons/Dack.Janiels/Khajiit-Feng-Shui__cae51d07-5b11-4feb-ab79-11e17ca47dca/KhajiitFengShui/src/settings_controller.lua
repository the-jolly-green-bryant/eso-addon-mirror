---@class KFS_SettingsController
---@field addon KhajiitFengShui Reference to main addon instance
---@field settingsPanel table LibHarvensAddonSettings panel instance
local SettingsController = {};
SettingsController.__index = SettingsController;

local PanelUtils = KhajiitFengShui.PanelUtils;
local PanelDefinitions = KhajiitFengShui.PanelDefinitions;

local SCALE_MIN_PERCENT = 50;
local SCALE_MAX_PERCENT = 150;
local SCALE_STEP_PERCENT = 5;
local DEFAULT_SCALE = 1;

---Creates new SettingsController
---@param addon KhajiitFengShui
---@return KFS_SettingsController
function SettingsController:New(addon)
    local controller =
    {
        addon = addon;
        settingsPanel = nil;
    };

    return setmetatable(controller, self);
end;

---Builds position text for panel
---@param panel KhajiitFengShuiPanel
---@return string
local function BuildPositionText(panel)
    if not (panel and panel.handler) then
        return "N/A";
    end;
    local left, top = PanelUtils.getAnchorPosition(panel.handler);
    return string.format("%d, %d", left, top);
end;

---Adds settings for a panel
---@param panel KhajiitFengShuiPanel
function SettingsController:AddPanelSetting(panel)
    if not self.settingsPanel then
        return;
    end;

    if not panel.sectionAdded then
        self.settingsPanel:AddSetting(
            {
                type = LibHarvensAddonSettings.ST_SECTION;
                label = PanelDefinitions.getLabel(panel.definition);
            });
        panel.sectionAdded = true;
    end;

    if not panel.enableSettingAdded then
        self.settingsPanel:AddSetting(
            {
                type = LibHarvensAddonSettings.ST_CHECKBOX;
                label = GetString(KFS_ENABLE_PANEL);
                tooltip = GetString(KFS_ENABLE_PANEL_DESC);
                default = true;
                getFunction = function ()
                    return self.addon:IsMoverEnabled(panel.definition.id);
                end;
                setFunction = function (value)
                    self.addon:SetMoverEnabled(panel.definition.id, value);
                    self.addon:RefreshSettingsAvailability();
                end;
                disable = function ()
                    local isPyramidBar = panel.definition.id == "playerHealth"
                        or panel.definition.id == "playerMagicka"
                        or panel.definition.id == "playerStamina";
                    if isPyramidBar and self.addon.savedVars.pyramidLayoutEnabled then
                        return true;
                    end;
                    return false;
                end;
            });
        panel.enableSettingAdded = true;
    end;

    -- Unitframes handle their own scaling, don't add scale slider
    local isUnitFrame = panel.definition.id and string.match(panel.definition.id, "^unitFrame");
    if not panel.scaleSettingAdded and not isUnitFrame then
        self.settingsPanel:AddSetting(
            {
                type = LibHarvensAddonSettings.ST_SLIDER;
                label = GetString(KFS_SCALE_SLIDER_LABEL);
                tooltip = GetString(KFS_SCALE_SLIDER_DESC);
                min = SCALE_MIN_PERCENT;
                max = SCALE_MAX_PERCENT;
                step = SCALE_STEP_PERCENT;
                default = zo_roundToNearest((panel.defaultScale or DEFAULT_SCALE) * 100, SCALE_STEP_PERCENT);
                disable = function ()
                    return not self.addon:IsMoverEnabled(panel.definition.id);
                end;
                getFunction = function ()
                    return self.addon:GetPanelScalePercent(panel.definition.id);
                end;
                setFunction = function (value)
                    self.addon:SetPanelScale(panel.definition.id, value / 100);
                end;
            });
        panel.scaleSettingAdded = true;
    end;

    if not panel.hideSettingAdded and panel.definition.supportsUserHidden then
        self.settingsPanel:AddSetting(
            {
                type = LibHarvensAddonSettings.ST_CHECKBOX;
                label = GetString(KFS_HIDE_PANEL);
                tooltip = GetString(KFS_HIDE_PANEL_DESC);
                default = false;
                getFunction = function ()
                    return self.addon.savedVars.panelHidden and self.addon.savedVars.panelHidden[panel.definition.id] == true;
                end;
                setFunction = function (value)
                    self.addon.savedVars.panelHidden = self.addon.savedVars.panelHidden or {};
                    if value then
                        self.addon.savedVars.panelHidden[panel.definition.id] = true;
                    else
                        self.addon.savedVars.panelHidden[panel.definition.id] = nil;
                    end;
                    self.addon:ApplyUserHiddenForPanel(panel);
                end;
            });
        panel.hideSettingAdded = true;
    end;

    if not panel.moveSettingAdded then
        self.settingsPanel:AddSetting(
            {
                type = LibHarvensAddonSettings.ST_BUTTON;
                label = GetString(KFS_MOVE_BUTTON);
                tooltip = function ()
                    local isPyramidBar = panel.definition.id == "playerHealth"
                        or panel.definition.id == "playerMagicka"
                        or panel.definition.id == "playerStamina";
                    if isPyramidBar and self.addon.savedVars.pyramidLayoutEnabled then
                        return GetString(KFS_MOVE_BUTTON_PYRAMID_DESC);
                    else
                        return string.format("%s%s", GetString(KFS_MOVE_BUTTON_DESC), BuildPositionText(panel));
                    end;
                end;
                buttonText = GetString(KFS_MOVE_BUTTON);
                disable = function ()
                    if not self.addon:IsMoverEnabled(panel.definition.id) then
                        return true;
                    end;
                    if panel.handler == nil then
                        return true;
                    end;
                    -- Disable move button for pyramid bars when pyramid layout is enabled
                    local isPyramidBar = panel.definition.id == "playerHealth"
                        or panel.definition.id == "playerMagicka"
                        or panel.definition.id == "playerStamina";
                    return isPyramidBar and self.addon.savedVars.pyramidLayoutEnabled;
                end;
                clickHandler = function ()
                    if self.addon.activePanelId == panel.definition.id then
                        self.addon:StopControlMove();
                    else
                        self.addon:StartControlMove(panel.definition.id);
                    end;
                end;
            });
        panel.moveSettingAdded = true;
    end;
end;

function SettingsController:RefreshDynamicControls()
    local panel = self.settingsPanel;
    if panel and panel.selected and panel.UpdateControls then
        panel:UpdateControls();
    end;
end;

---Creates settings menu
function SettingsController:CreateSettingsMenu()
    local settings = LibHarvensAddonSettings:AddAddon(GetString(KFS_SETTINGS),
                                                      {
                                                          allowDefaults = true;
                                                          defaultsFunction = function ()
                                                              self.addon:SetProfileMode(self.addon.defaults.profileMode, true);
                                                              self.addon.savedVars.grid.enabled = self.addon.defaults.grid.enabled;
                                                              self.addon.savedVars.grid.size = self.addon.defaults.grid.size;
                                                              self.addon:ResetPositions();
                                                              self.addon:ApplySnapSettings();
                                                              self.addon.savedVars.unitframesEnabled = self.addon.defaults.unitframesEnabled;
                                                              self.addon.savedVars.buffAnimationsEnabled = self.addon.defaults.buffAnimationsEnabled;
                                                              self.addon:UpdateBuffAnimationHook();
                                                              self.addon.savedVars.globalCooldownEnabled = self.addon.defaults.globalCooldownEnabled;
                                                              self.addon:ApplyGlobalCooldownSetting();
                                                              self.addon.savedVars.bossBarEnabled = self.addon.defaults.bossBarEnabled;
                                                              self.addon.savedVars.reticleEnabled = self.addon.defaults.reticleEnabled;
                                                              self.addon.savedVars.panelHidden = {};
                                                              for panelId, hidden in pairs(self.addon.defaults.panelHidden or {}) do
                                                                  self.addon.savedVars.panelHidden[panelId] = hidden;
                                                              end;
                                                              self.addon.activePanelId = nil;
                                                              self.addon:ApplyAllUserHiddenStates();
                                                              self.addon:RefreshAllPanels();
                                                              self.addon:RefreshGridOverlay();
                                                          end;
                                                      });

    local controls = {};
    local controlCount = 1;

    controls[controlCount] =
    {
        type = LibHarvensAddonSettings.ST_LABEL;
        label = GetString(KFS_SETTINGS_DESC);
        canSelect = false;
    };
    controlCount = controlCount + 1;

    controls[controlCount] =
    {
        type = LibHarvensAddonSettings.ST_DROPDOWN;
        label = GetString(KFS_PROFILE_MODE);
        tooltip = GetString(KFS_PROFILE_MODE_DESC_RELOAD);
        default = GetString(KFS_PROFILE_ACCOUNT);
        items =
        {
            {
                name = GetString(KFS_PROFILE_ACCOUNT);
                data = "account";
            };
            {
                name = GetString(KFS_PROFILE_CHARACTER);
                data = "character";
            };
        };
        getFunction = function ()
            local mode = self.addon:GetProfileMode();
            if mode == "account" then
                return GetString(KFS_PROFILE_ACCOUNT);
            else
                return GetString(KFS_PROFILE_CHARACTER);
            end;
        end;
        setFunction = function (_, _, itemData)
            self.addon:SetProfileMode(itemData or "account");
            ReloadUI("ingame");
        end;
    };
    controlCount = controlCount + 1;

    controls[controlCount] =
    {
        type = LibHarvensAddonSettings.ST_CHECKBOX;
        label = GetString(KFS_ENABLE_SNAP);
        tooltip = GetString(KFS_ENABLE_SNAP_DESC);
        default = self.addon.defaults.grid.enabled;
        getFunction = function ()
            return self.addon.savedVars.grid.enabled;
        end;
        setFunction = function (value)
            self.addon.savedVars.grid.enabled = value;
            self.addon:ApplySnapSettings();
        end;
    };
    controlCount = controlCount + 1;

    controls[controlCount] =
    {
        type = LibHarvensAddonSettings.ST_SLIDER;
        label = GetString(KFS_SNAP_SIZE);
        tooltip = GetString(KFS_SNAP_SIZE_DESC);
        min = 2;
        max = 128;
        step = 1;
        default = self.addon.defaults.grid.size;
        getFunction = function ()
            return self.addon.savedVars.grid.size;
        end;
        setFunction = function (value)
            self.addon.savedVars.grid.size = value;
            self.addon:ApplySnapSettings();
        end;
    };
    controlCount = controlCount + 1;

    controls[controlCount] =
    {
        type = LibHarvensAddonSettings.ST_CHECKBOX;
        label = GetString(KFS_ENABLE_UNITFRAMES);
        tooltip = GetString(KFS_ENABLE_UNITFRAMES_DESC_RELOAD);
        default = self.addon.defaults.unitframesEnabled;
        getFunction = function ()
            return self.addon.savedVars.unitframesEnabled;
        end;
        setFunction = function (value)
            self.addon.savedVars.unitframesEnabled = value;
            ReloadUI("ingame");
        end;
    };
    controlCount = controlCount + 1;

    controls[controlCount] =
    {
        type = LibHarvensAddonSettings.ST_CHECKBOX;
        label = GetString(KFS_ENABLE_BUFF_ANIMATIONS);
        tooltip = GetString(KFS_ENABLE_BUFF_ANIMATIONS_DESC_RELOAD);
        default = self.addon.defaults.buffAnimationsEnabled;
        getFunction = function ()
            return self.addon.savedVars.buffAnimationsEnabled;
        end;
        setFunction = function (value)
            self.addon.savedVars.buffAnimationsEnabled = value;
            self.addon:UpdateBuffAnimationHook();
            ReloadUI("ingame");
        end;
    };
    controlCount = controlCount + 1;

    controls[controlCount] =
    {
        type = LibHarvensAddonSettings.ST_CHECKBOX;
        label = GetString(KFS_ENABLE_GCD);
        tooltip = GetString(KFS_ENABLE_GCD_DESC);
        default = self.addon.defaults.globalCooldownEnabled;
        getFunction = function ()
            return self.addon.savedVars.globalCooldownEnabled;
        end;
        setFunction = function (value)
            self.addon.savedVars.globalCooldownEnabled = value;
            self.addon:ApplyGlobalCooldownSetting();
        end;
    };
    controlCount = controlCount + 1;

    controls[controlCount] =
    {
        type = LibHarvensAddonSettings.ST_CHECKBOX;
        label = GetString(KFS_ENABLE_BOSS_BAR);
        tooltip = GetString(KFS_ENABLE_BOSS_BAR_DESC_RELOAD);
        default = self.addon.defaults.bossBarEnabled;
        getFunction = function ()
            return self.addon.savedVars.bossBarEnabled;
        end;
        setFunction = function (value)
            self.addon.savedVars.bossBarEnabled = value;
            ReloadUI("ingame");
        end;
    };
    controlCount = controlCount + 1;

    controls[controlCount] =
    {
        type = LibHarvensAddonSettings.ST_CHECKBOX;
        label = GetString(KFS_ENABLE_RETICLE);
        tooltip = GetString(KFS_ENABLE_RETICLE_DESC_RELOAD);
        default = self.addon.defaults.reticleEnabled;
        getFunction = function ()
            return self.addon.savedVars.reticleEnabled;
        end;
        setFunction = function (value)
            self.addon.savedVars.reticleEnabled = value;
            ReloadUI("ingame");
        end;
    };
    controlCount = controlCount + 1;

    controls[controlCount] =
    {
        type = LibHarvensAddonSettings.ST_CHECKBOX;
        label = GetString(KFS_PYRAMID_LAYOUT);
        tooltip = GetString(KFS_PYRAMID_LAYOUT_DESC);
        default = self.addon.defaults.pyramidLayoutEnabled;
        getFunction = function ()
            return self.addon.savedVars.pyramidLayoutEnabled;
        end;
        setFunction = function (value)
            self.addon.savedVars.pyramidLayoutEnabled = value;
            self.addon:ApplyAllPositions();
            if value then
                self.addon:SetMoverEnabled("playerHealth", true);
                self.addon:SetMoverEnabled("playerMagicka", true);
                self.addon:SetMoverEnabled("playerStamina", true);
            end;
            self.addon:RefreshSettingsAvailability();
        end;
    };
    controlCount = controlCount + 1;

    controls[controlCount] =
    {
        type = LibHarvensAddonSettings.ST_CHECKBOX;
        label = GetString(KFS_ALWAYS_EXPANDED_BARS);
        tooltip = GetString(KFS_ALWAYS_EXPANDED_BARS_DESC_RELOAD);
        default = self.addon.defaults.alwaysExpandedBars;
        getFunction = function ()
            return self.addon.savedVars.alwaysExpandedBars;
        end;
        setFunction = function (value)
            self.addon.savedVars.alwaysExpandedBars = value;
            ReloadUI("ingame"); -- Requires UI reload to apply the hook
        end;
    };
    controlCount = controlCount + 1;

    controls[controlCount] =
    {
        type = LibHarvensAddonSettings.ST_BUTTON;
        label = GetString(KFS_RESET_ALL_DESC);
        tooltip = GetString(KFS_RESET_ALL_DESC);
        buttonText = GetString(KFS_RESET_ALL);
        clickHandler = function ()
            self.addon:ResetPositions();
        end;
    };
    settings:AddSettings(controls);

    settings:AddSetting(
        {
            type = LibHarvensAddonSettings.ST_SECTION;
            label = GetString(KFS_SECTION_CONTROLS);
            subMenu = false;
        });
    self.settingsPanel = settings;
    self.addon.settingsPanel = settings;
    for _, panel in ipairs(self.addon.panels) do
        self:AddPanelSetting(panel);
    end;
end;

KhajiitFengShui.SettingsController = SettingsController;
