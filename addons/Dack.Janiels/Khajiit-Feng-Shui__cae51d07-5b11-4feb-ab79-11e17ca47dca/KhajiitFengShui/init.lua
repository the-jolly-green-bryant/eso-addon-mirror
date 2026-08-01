local ADDON_NAME = "KhajiitFengShui";
local ADDON_VERSION = "1.3.7";

---@class KFS_SavedVars
---@field grid { enabled: boolean, size: number }
---@field positions table<string, KFS_Position>
---@field scales table<string, number>
---@field buffAnimationsEnabled boolean
---@field globalCooldownEnabled boolean
---@field pyramidLayoutEnabled boolean
---@field alwaysExpandedBars boolean
---@field pyramidOffset { left: number, top: number }
---@field profileMode string
---@field showAllLabels boolean
---@field disabledPanels table<string, boolean>
---@field bossBarEnabled boolean
---@field reticleEnabled boolean
---@field unitframesEnabled boolean
---@field panelHidden table<string, boolean>

---@class KFS_Defaults
---@field grid { enabled: boolean, size: number }
---@field positions table
---@field scales table
---@field buffAnimationsEnabled boolean
---@field globalCooldownEnabled boolean
---@field profileMode string
---@field pyramidLayoutEnabled boolean
---@field pyramidOffset { left: number, top: number }
---@field alwaysExpandedBars boolean
---@field showAllLabels boolean
---@field disabledPanels table<string, boolean>
---@field bossBarEnabled boolean
---@field reticleEnabled boolean
---@field unitframesEnabled boolean
---@field panelHidden table<string, boolean>

---@class KhajiitFengShui
---@field MoverState KFS_MoverState
---@field name string Addon name
---@field displayName string Localized display name
---@field version string Version string
---@field savedVars KFS_SavedVars|nil Active saved variables (account or character)
---@field accountSavedVars KFS_SavedVars|nil Account-wide saved variables
---@field characterSavedVars KFS_SavedVars|nil Per-character saved variables
---@field panels KhajiitFengShuiPanel[] All created panel instances
---@field panelLookup table<string, KhajiitFengShuiPanel> Panel ID to panel instance map
---@field definitionLookup table<string, KhajiitFengShuiPanelDefinition>|nil Definition ID to definition map
---@field activePanelId string|nil Currently moving panel ID
---@field editModeFocusId string|nil Panel focused in edit mode
---@field profileMode string|nil "account" or "character"
---@field editModeActive boolean Whether edit mode is active
---@field editModeController KFS_EditModeController|nil Edit mode controller instance
---@field settingsController KFS_SettingsController|nil Settings controller instance
---@field gridOverlay KFS_GridOverlay|nil Grid overlay instance
---@field keybindStripDescriptor table?
---@field keybindStripActive boolean
---@field keybindSceneCallbacks table
---@field keybindSceneGroups table
---@field keybindStripReduced boolean
---@field keybindStripOriginalHeight number?
---@field keybindStripBackgroundOriginalHeight number?
---@field keybindStripBackgroundTextureOriginalHeight number?
---@field keybindStripCenterAdjusted boolean
---@field keybindStripBackgroundWasHidden boolean?
---@field keybindFragmentSceneName string?
---@field keybindScenes table?
---@field actionLayerName string?
---@field actionLayerActive boolean
---@field editModeHintShown boolean
---@field compassHookRegistered boolean
---@field buffAnimationHookRegistered boolean
---@field globalCooldownActive boolean
---@field groupFrameHooksRegistered boolean
---@field advZoneHUDTrackerHookRegistered boolean
---@field playerAttributeBarsHookRegistered boolean
---@field LHAS LibHarvensAddonSettings LibHarvensAddonSettings instance
---@field settingsPanel table|nil Settings panel instance
---@field defaults KFS_Defaults Default configuration values
KhajiitFengShui =
{
    name = ADDON_NAME;
    displayName = GetString(KFS_NAME);
    version = ADDON_VERSION;
    savedVars = nil;
    accountSavedVars = nil;
    characterSavedVars = nil;
    panels = {};
    panelLookup = {};
    activePanelId = nil;
    editModeFocusId = nil;
    profileMode = nil;
    editModeActive = false;
    editModeController = nil;
    gridOverlay = nil;
    keybindStripDescriptor = nil;
    keybindStripActive = false;
    keybindSceneCallbacks = {};
    keybindSceneGroups = {};
    keybindStripReduced = false;
    keybindStripOriginalHeight = nil;
    keybindStripBackgroundOriginalHeight = nil;
    keybindStripBackgroundTextureOriginalHeight = nil;
    keybindStripCenterAdjusted = false;
    keybindStripBackgroundWasHidden = nil;
    keybindFragmentSceneName = nil;
    keybindScenes = nil;
    actionLayerName = nil;
    actionLayerActive = false;
    editModeHintShown = false;
    compassHookRegistered = false;
    buffAnimationHookRegistered = false;
    globalCooldownActive = false;
    groupFrameHooksRegistered = false;
    advZoneHUDTrackerHookRegistered = false;
    playerAttributeBarsHookRegistered = false;
    defaults =
    {
        grid =
        {
            enabled = false;
            size = 15;
        };
        positions = {};
        scales = {};
        buffAnimationsEnabled = false;
        globalCooldownEnabled = false;
        profileMode = "account";
        pyramidLayoutEnabled = false;
        pyramidOffset = { left = 0; top = 0 };
        alwaysExpandedBars = false;
        showAllLabels = false;
        disabledPanels = {};
        bossBarEnabled = true;
        reticleEnabled = true;
        unitframesEnabled = true;
        panelHidden = {};
    };
};
