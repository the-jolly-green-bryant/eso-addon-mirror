-- ------------------------------------------------------------------------------ --
--                                Addon Loadouts                                  --
--                             All Rights Reserved.                               --
-- ------------------------------------------------------------------------------ --
--
-- Console-only ESO addon: save and load addon enable/disable presets (loadouts)
-- per server. Uses LibHarvensAddonSettings for the settings UI and LibRadialMenu
-- for the "Apply loadout" radial entry. SavedVariables: AddonLoadoutsSavedVars
-- (account-wide, per world). Each loadout stores only enabled addons to save space.
--

--- @class AddonLoadout
--- @field id string Unique id (AddonLoadouts_&lt;timestamp&gt;)
--- @field name string Display name
--- @field addonStates AddonStatesMap Addon name -&gt; true if enabled (only enabled are saved)

--- @alias AddonStatesMap table<string, boolean> Map of addon internal name to enabled state. Only `true` entries are persisted.

--- @class AddonLoadoutsSavedVars
--- @field loadouts AddonLoadout[] Array of saved loadouts (per world)
--- @field activeLoadoutId string|nil Id of the last applied loadout (stable across reorder)

--- @class AddonLoadoutsNamespace
--- @field sv AddonLoadoutsSavedVars? Saved vars (set after addon load, per world)
--- @field settings table? LibHarvensAddonSettings panel (set after addon load)
--- @field pendingLoadoutName string Pending name in the New Loadout Name dialog

local addOnManager = GetAddOnManager()
local eventManager = GetEventManager()

--- @type AddonLoadoutsNamespace
local AddonLoadouts = {}

--- @type string
local ADDON_NAME = "AddonLoadouts"

--- @type integer
local SV_VERSION = 1

--- @type AddonLoadoutsSavedVars
local DEFAULT_SV =
{
    loadouts = {},
    activeLoadoutId = nil,
}

-- Libraries
local LibHarvensAddonSettings = LibHarvensAddonSettings
local LibRadialMenu = LibRadialMenu

-- Lua standard library
local string_format = string.format
local table_insert = table.insert
local table_remove = table.remove
local pairs = pairs
local ipairs = ipairs
local table_sort = table.sort

-- ESO API
local GetString = GetString
local GetWorldName = GetWorldName
local GetTimeStamp = GetTimeStamp
local ReloadUI = ReloadUI
local ZO_Dialogs_ShowPlatformDialog = ZO_Dialogs_ShowPlatformDialog
local ZO_Dialogs_RegisterCustomDialog = ZO_Dialogs_RegisterCustomDialog
local ZO_Dialogs_ReleaseDialogOnButtonPress = ZO_Dialogs_ReleaseDialogOnButtonPress
local ZO_ClearNumericallyIndexedTable = ZO_ClearNumericallyIndexedTable
local ZO_SharedGamepadEntry_OnSetup = ZO_SharedGamepadEntry_OnSetup
local ZO_SavedVars = ZO_SavedVars
local GAMEPAD_DIALOGS = GAMEPAD_DIALOGS
local EVENT_ADD_ON_LOADED = EVENT_ADD_ON_LOADED


--- Build a map of every installed addon to its current enabled state.
--- @return AddonStatesMap states addonName -&gt; enabled (true/false)
local function BuildAddonStates()
    local numAddOns = addOnManager:GetNumAddOns()
    local states = {}
    for i = 1, numAddOns do
        local name, _, _, _, enabled = addOnManager:GetAddOnInfo(i)
        if name then
            states[name] = enabled
        end
    end
    return states
end

--- Build a map containing only currently enabled addons (for SV persistence).
--- Only keys with value true are included to minimize saved variable size.
--- @return AddonStatesMap enabledOnly addonName -&gt; true
local function BuildAddonStatesEnabledOnly()
    local all = BuildAddonStates()
    local enabledOnly = {}
    for addonName, enabled in pairs(all) do
        if enabled then
            enabledOnly[addonName] = true
        end
    end
    return enabledOnly
end

--- Apply a loadout: set every addon enabled per loadout.addonStates, then reload UI.
--- Addons not in addonStates (or with value ~= true) are disabled. Backward compatible with old SVs that store false.
--- @param loadout AddonLoadout|nil Loadout to apply (must have addonStates)
local function ApplyLoadout(loadout)
    if not loadout or not loadout.addonStates then
        return
    end
    local sv = AddonLoadouts.sv
    if sv and loadout.id then
        sv.activeLoadoutId = loadout.id
    end
    local numAddOns = addOnManager:GetNumAddOns()
    for i = 1, numAddOns do
        local name = addOnManager:GetAddOnInfo(i)
        if name then
            local enabled = (loadout.addonStates[name] == true)
            addOnManager:SetAddOnEnabled(i, enabled)
        end
    end
    ReloadUI("ingame")
end

--- Generate a unique loadout id from addon name and current timestamp.
--- @return string id e.g. "AddonLoadouts_1773534262"
local function GenerateLoadoutId()
    return string_format("%s_%d", ADDON_NAME, GetTimeStamp())
end

--- Find the loadout matching saved activeLoadoutId, or nil if missing/stale.
--- @param sv AddonLoadoutsSavedVars
--- @return AddonLoadout|nil
local function FindActiveLoadout(sv)
    if not sv or not sv.activeLoadoutId then
        return nil
    end
    for _, lo in ipairs(sv.loadouts or {}) do
        if lo.id == sv.activeLoadoutId then
            return lo
        end
    end
    return nil
end

--- Clear activeLoadoutId if it does not match any loadout.
--- @param sv AddonLoadoutsSavedVars
local function SanitizeActiveLoadoutId(sv)
    if not sv or not sv.activeLoadoutId then
        return
    end
    if not FindActiveLoadout(sv) then
        sv.activeLoadoutId = nil
    end
end

--- Tooltip for a loadout row: sorted enabled addon internal names (row label is the loadout name).
--- Single LibHarvens `tooltip` string only — no library fork required.
--- @param loadout AddonLoadout
--- @return string
local function BuildLoadoutTooltipText(loadout)
    local states = loadout.addonStates
    if not states then
        return ""
    end
    local names = {}
    for addonName, enabled in pairs(states) do
        if enabled == true then
            names[#names + 1] = addonName
        end
    end
    table_sort(names)
    if #names == 0 then
        return GetString(SI_ADDONLOADOUTS_LOADOUT_TOOLTIP_EMPTY)
    end
    return table.concat(names, "\n")
end

--- @type fun(): table[] BuildSettingsTable
local BuildSettingsTable
--- @type fun(): nil RefreshSettingsContent
local RefreshSettingsContent
--- @type fun(): nil OverwriteActiveLoadoutWithCurrentState
local OverwriteActiveLoadoutWithCurrentState
--- @type fun(indexA: integer, indexB: integer): nil SwapLoadoutsAt
local SwapLoadoutsAt

--- Build the LibHarvensAddonSettings table for the Addon Loadouts panel (sections, save button, load/delete per loadout).
--- @return table[] settingsTable Array of control descriptors for LibHarvensAddonSettings
function BuildSettingsTable()
    local sv = AddonLoadouts.sv
    local loadouts = sv.loadouts or {}
    local activeLo = FindActiveLoadout(sv)
    local updateTooltip
    if activeLo then
        local n = activeLo.name or activeLo.id or ""
        updateTooltip = string_format(GetString(SI_ADDONLOADOUTS_UPDATE_ACTIVE_TOOLTIP_NAMED), n)
    else
        updateTooltip = GetString(SI_ADDONLOADOUTS_UPDATE_ACTIVE_TOOLTIP_NONE)
    end

    local settingsTable =
    {
        {
            type = LibHarvensAddonSettings.ST_SECTION,
            label = GetString(SI_ADDONLOADOUTS_LOADOUTS),
            tooltip = GetString(SI_ADDONLOADOUTS_LOADOUTS),
        },
        {
            type = LibHarvensAddonSettings.ST_BUTTON,
            label = GetString(SI_ADDONLOADOUTS_SAVE_CURRENT),
            tooltip = GetString(SI_ADDONLOADOUTS_SAVE_CURRENT),
            buttonText = GetString(SI_SAVE),
            clickHandler = function ()
                ZO_Dialogs_ShowPlatformDialog("AddonLoadoutsNewLoadoutNameDialog")
            end,
        },
        {
            type = LibHarvensAddonSettings.ST_BUTTON,
            label = GetString(SI_ADDONLOADOUTS_UPDATE_ACTIVE),
            tooltip = updateTooltip,
            buttonText = GetString(SI_ADDONLOADOUTS_UPDATE_ACTIVE),
            clickHandler = function ()
                OverwriteActiveLoadoutWithCurrentState()
            end,
        },
        {
            type = LibHarvensAddonSettings.ST_BUTTON,
            label = GetString(SI_ADDONLOADOUTS_ORGANIZE),
            tooltip = GetString(SI_ADDONLOADOUTS_ORGANIZE),
            buttonText = GetString(SI_ADDONLOADOUTS_ORGANIZE),
            clickHandler = function ()
                ZO_Dialogs_ShowPlatformDialog("AddonLoadoutsOrganizeLoadoutsDialog")
            end,
        },
    }

    if #loadouts == 0 then
        settingsTable[#settingsTable + 1] =
        {
            type = LibHarvensAddonSettings.ST_LABEL,
            label = GetString(SI_ADDONLOADOUTS_NO_LOADOUTS),
            tooltip = GetString(SI_ADDONLOADOUTS_NO_LOADOUTS),
        }
    else
        for i, loadout in ipairs(loadouts) do
            local name = loadout.name or loadout.id or ("Loadout " .. i)
            settingsTable[#settingsTable + 1] =
            {
                type = LibHarvensAddonSettings.ST_BUTTON,
                label = name,
                tooltip = BuildLoadoutTooltipText(loadout),
                buttonText = GetString(SI_ADDONLOADOUTS_LOAD),
                clickHandler = function ()
                    ApplyLoadout(loadout)
                end,
            }
        end
    end

    return settingsTable
end

--- Refresh the Addon Loadouts settings panel with the current loadouts list.
function RefreshSettingsContent()
    local panel = AddonLoadouts.settings
    if not panel then return end
    panel:Clear()
    panel:AddSettings(BuildSettingsTable())
    if LibHarvensAddonSettings.list then
        panel:CreateControls()
    end
end

OverwriteActiveLoadoutWithCurrentState = function ()
    local sv = AddonLoadouts.sv
    if not sv then return end
    local loadout = FindActiveLoadout(sv)
    if not loadout then
        sv.activeLoadoutId = nil
        if AddonLoadouts.settings then
            RefreshSettingsContent()
            LibHarvensAddonSettings.list:RefreshVisible()
        end
        return
    end
    loadout.addonStates = BuildAddonStatesEnabledOnly()
    if AddonLoadouts.settings then
        RefreshSettingsContent()
        LibHarvensAddonSettings.list:RefreshVisible()
    end
end

SwapLoadoutsAt = function (indexA, indexB)
    local sv = AddonLoadouts.sv
    local t = sv and sv.loadouts
    if not t or not t[indexA] or not t[indexB] then return end
    t[indexA], t[indexB] = t[indexB], t[indexA]
    if AddonLoadouts.settings then
        RefreshSettingsContent()
        LibHarvensAddonSettings.list:RefreshVisible()
    end
end

--- Save the current addon enable state as a new loadout and append to SV. Only enabled addons are stored.
--- @param name string Display name for the loadout (non-empty)
local function SaveNewLoadout(name)
    if not name or name == "" then return end
    local sv = AddonLoadouts.sv
    local loadout =
    {
        id = GenerateLoadoutId(),
        name = name,
        addonStates = BuildAddonStatesEnabledOnly(),
    }
    table_insert(sv.loadouts, loadout)
    if AddonLoadouts.settings then
        RefreshSettingsContent()
        LibHarvensAddonSettings.list:RefreshVisible()
    end
end

--- Setup the Apply Loadout parametric dialog: fill parametricList with one entry per loadout (or "no loadouts").
--- @param dialog table ESO gamepad parametric dialog
local function SetupApplyLoadoutDialog(dialog)
    local sv = AddonLoadouts.sv
    local loadouts = (sv and sv.loadouts) or {}
    local parametricList = dialog.info.parametricList or {}
    ZO_ClearNumericallyIndexedTable(parametricList)
    dialog.info.parametricList = parametricList

    local template = "ZO_GamepadMenuEntryTemplate"
    for _, loadout in ipairs(loadouts) do
        table_insert(parametricList,
                     {
                         template = template,
                         text = loadout.name or loadout.id,
                         templateData =
                         {
                             setup = ZO_SharedGamepadEntry_OnSetup,
                             loadout = loadout,
                         },
                     })
    end
    if #loadouts == 0 then
        table_insert(parametricList,
                     {
                         template = template,
                         text = GetString(SI_ADDONLOADOUTS_NO_LOADOUTS),
                         templateData =
                         {
                             setup = ZO_SharedGamepadEntry_OnSetup,
                             loadout = nil,
                         },
                     })
    end
    dialog:setupFunc()
end

--- Fill organize dialog list (selected row: move up/down/delete).
--- @param dialog table ESO gamepad parametric dialog
local function SetupOrganizeLoadoutsDialog(dialog)
    local sv = AddonLoadouts.sv
    local loadouts = (sv and sv.loadouts) or {}
    local parametricList = dialog.info.parametricList or {}
    ZO_ClearNumericallyIndexedTable(parametricList)
    dialog.info.parametricList = parametricList

    local template = "ZO_GamepadMenuEntryTemplate"
    for idx, loadout in ipairs(loadouts) do
        table_insert(parametricList,
                     {
                         template = template,
                         text = loadout.name or loadout.id,
                         templateData =
                         {
                             setup = ZO_SharedGamepadEntry_OnSetup,
                             loadout = loadout,
                             loadoutIndex = idx,
                         },
                     })
    end
    if #loadouts == 0 then
        table_insert(parametricList,
                     {
                         template = template,
                         text = GetString(SI_ADDONLOADOUTS_NO_LOADOUTS),
                         templateData =
                         {
                             setup = ZO_SharedGamepadEntry_OnSetup,
                             loadout = nil,
                             loadoutIndex = nil,
                         },
                     })
    end
    dialog:setupFunc()
end

--- Pending name typed in the New Loadout Name dialog (used by text field and submit callback).
AddonLoadouts.pendingLoadoutName = ""

ZO_Dialogs_RegisterCustomDialog("AddonLoadoutsOrganizeLoadoutsDialog",
                                {
                                    canQueue = true,
                                    blockDialogReleaseOnPress = true,
                                    gamepadInfo =
                                    {
                                        dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
                                    },
                                    title =
                                    {
                                        text = SI_ADDONLOADOUTS_ORGANIZE_TITLE,
                                    },
                                    parametricList = {},
                                    setup = SetupOrganizeLoadoutsDialog,
                                    buttons =
                                    {
                                        {
                                            keybind = "DIALOG_PRIMARY",
                                            text = SI_ADDONLOADOUTS_MOVE_UP,
                                            callback = function (dialog)
                                                local data = dialog.entryList:GetTargetData()
                                                if data and data.loadoutIndex and data.loadoutIndex > 1 then
                                                    SwapLoadoutsAt(data.loadoutIndex, data.loadoutIndex - 1)
                                                    SetupOrganizeLoadoutsDialog(dialog)
                                                end
                                            end,
                                            visible = function (dialog)
                                                local data = dialog.entryList and dialog.entryList:GetTargetData()
                                                return data and data.loadoutIndex ~= nil and data.loadoutIndex > 1
                                            end,
                                        },
                                        {
                                            keybind = "DIALOG_SECONDARY",
                                            text = SI_ADDONLOADOUTS_MOVE_DOWN,
                                            callback = function (dialog)
                                                local data = dialog.entryList:GetTargetData()
                                                local sv = AddonLoadouts.sv
                                                local n = sv and sv.loadouts and #sv.loadouts or 0
                                                if data and data.loadoutIndex and data.loadoutIndex < n then
                                                    SwapLoadoutsAt(data.loadoutIndex, data.loadoutIndex + 1)
                                                    SetupOrganizeLoadoutsDialog(dialog)
                                                end
                                            end,
                                            visible = function (dialog)
                                                local data = dialog.entryList and dialog.entryList:GetTargetData()
                                                local sv = AddonLoadouts.sv
                                                local n = sv and sv.loadouts and #sv.loadouts or 0
                                                return data and data.loadoutIndex ~= nil and n > 0 and data.loadoutIndex < n
                                            end,
                                        },
                                        {
                                            keybind = "DIALOG_TERTIARY",
                                            text = SI_ADDONLOADOUTS_DELETE,
                                            callback = function (dialog)
                                                local data = dialog.entryList:GetTargetData()
                                                if not data or not data.loadout or not data.loadoutIndex then
                                                    return
                                                end
                                                local sv = AddonLoadouts.sv
                                                local removedId = data.loadout.id
                                                table_remove(sv.loadouts, data.loadoutIndex)
                                                if sv.activeLoadoutId == removedId then
                                                    sv.activeLoadoutId = nil
                                                end
                                                RefreshSettingsContent()
                                                LibHarvensAddonSettings.list:RefreshVisible()
                                                SetupOrganizeLoadoutsDialog(dialog)
                                            end,
                                            visible = function (dialog)
                                                local data = dialog.entryList and dialog.entryList:GetTargetData()
                                                return data and data.loadout ~= nil
                                            end,
                                        },
                                        {
                                            keybind = "DIALOG_NEGATIVE",
                                            text = SI_DIALOG_CANCEL,
                                            callback = function ()
                                                ZO_Dialogs_ReleaseDialogOnButtonPress("AddonLoadoutsOrganizeLoadoutsDialog")
                                            end,
                                        },
                                    },
                                })

ZO_Dialogs_RegisterCustomDialog("AddonLoadoutsApplyLoadoutDialog",
                                {
                                    canQueue = true,
                                    blockDialogReleaseOnPress = true,
                                    gamepadInfo =
                                    {
                                        dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
                                    },
                                    title =
                                    {
                                        text = SI_ADDONLOADOUTS_APPLY_LOADOUT,
                                    },
                                    parametricList = {},
                                    setup = SetupApplyLoadoutDialog,
                                    buttons =
                                    {
                                        {
                                            text = SI_ADDONLOADOUTS_APPLY,
                                            callback = function (dialog)
                                                local data = dialog.entryList:GetTargetData()
                                                if data and data.loadout then
                                                    ZO_Dialogs_ReleaseDialogOnButtonPress("AddonLoadoutsApplyLoadoutDialog")
                                                    ApplyLoadout(data.loadout)
                                                end
                                            end,
                                            visible = function (dialog)
                                                local data = dialog.entryList and dialog.entryList:GetTargetData()
                                                return data and data.loadout ~= nil
                                            end,
                                        },
                                        {
                                            text = SI_DIALOG_CANCEL,
                                            callback = function ()
                                                ZO_Dialogs_ReleaseDialogOnButtonPress("AddonLoadoutsApplyLoadoutDialog")
                                            end,
                                        },
                                    },
                                })

ZO_Dialogs_RegisterCustomDialog("AddonLoadoutsNewLoadoutNameDialog",
                                {
                                    canQueue = true,
                                    blockDialogReleaseOnPress = true,
                                    gamepadInfo =
                                    {
                                        dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
                                        allowRightStickPassThrough = true,
                                    },
                                    title =
                                    {
                                        text = SI_ADDONLOADOUTS_NEW_LOADOUT_NAME,
                                    },
                                    setup = function (dialog)
                                        AddonLoadouts.pendingLoadoutName = ""
                                        dialog:setupFunc()
                                    end,
                                    parametricList =
                                    {
                                        {
                                            template = "ZO_Gamepad_GenericDialog_Parametric_TextFieldItem",
                                            headerTemplate = "ZO_GamepadMenuEntryFullWidthHeaderTemplate",
                                            header = SI_ADDONLOADOUTS_NEW_LOADOUT_NAME,
                                            templateData =
                                            {
                                                setup = function (control, data, selected, reselectingDuringRebuild, enabled, active)
                                                    if control.highlight then
                                                        control.highlight:SetHidden(not selected)
                                                    end
                                                    local editBox = control.editBoxControl
                                                    if editBox then
                                                        editBox:SetMaxInputChars(64)
                                                        editBox:SetText(AddonLoadouts.pendingLoadoutName or "")
                                                        editBox.textChangedCallback = function (eb)
                                                            AddonLoadouts.pendingLoadoutName = eb:GetText() or ""
                                                        end
                                                    end
                                                end,
                                                callback = function (dialog)
                                                    local targetControl = dialog.entryList:GetTargetControl()
                                                    if targetControl and targetControl.editBoxControl then
                                                        targetControl.editBoxControl:TakeFocus()
                                                    end
                                                end,
                                            },
                                        },
                                        {
                                            template = "ZO_GamepadTextFieldSubmitItem",
                                            templateData =
                                            {
                                                text = GetString(SI_SAVE),
                                                setup = ZO_SharedGamepadEntry_OnSetup,
                                                callback = function (dialog)
                                                    local name = (AddonLoadouts.pendingLoadoutName and AddonLoadouts.pendingLoadoutName:match("^%s*(.-)%s*$")) or ""
                                                    ZO_Dialogs_ReleaseDialogOnButtonPress("AddonLoadoutsNewLoadoutNameDialog")
                                                    SaveNewLoadout(name)
                                                end,
                                            },
                                        },
                                    },
                                    buttons =
                                    {
                                        {
                                            keybind = "DIALOG_PRIMARY",
                                            text = SI_GAMEPAD_SELECT_OPTION,
                                            callback = function (dialog)
                                                local targetData = dialog.entryList:GetTargetData()
                                                if targetData and targetData.callback then
                                                    targetData.callback(dialog)
                                                end
                                            end,
                                        },
                                        {
                                            keybind = "DIALOG_NEGATIVE",
                                            text = SI_DIALOG_CANCEL,
                                            callback = function ()
                                                ZO_Dialogs_ReleaseDialogOnButtonPress("AddonLoadoutsNewLoadoutNameDialog")
                                            end,
                                        },
                                    },
                                })

--- Create the Addon Loadouts settings panel (LibHarvensAddonSettings) and populate it.
local function CreateSettingsPanel()
    AddonLoadouts.settings = LibHarvensAddonSettings:AddAddon("Addon Loadouts",
                                                              {
                                                                  allowDefaults = false,
                                                                  allowRefresh = true,
                                                              })
    RefreshSettingsContent()
end

--- Handle EVENT_ADD_ON_LOADED: when this addon loads, init SV (per world), create settings panel, register radial entry.
--- @param event number EVENT_ADD_ON_LOADED
--- @param addonName string Name of the addon that loaded
local function OnAddOnLoaded(event, addonName)
    if addonName == ADDON_NAME then
        local worldNamespace = GetWorldName()
        AddonLoadouts.sv = ZO_SavedVars:NewAccountWide(
            "AddonLoadoutsSavedVars",
            SV_VERSION,
            nil,
            DEFAULT_SV,
            worldNamespace
        )

        SanitizeActiveLoadoutId(AddonLoadouts.sv)

        CreateSettingsPanel()

        LibRadialMenu:RegisterAddon("addonloadouts", "Addon Loadouts")
        LibRadialMenu:RegisterEntry(
            "addonloadouts",
            GetString(SI_ADDONLOADOUTS_APPLY_LOADOUT),
            "applyloadout",
            "esoui/art/skillsadvisor/advisor_tabicon_settings_up.dds",
            function ()
                ZO_Dialogs_ShowPlatformDialog("AddonLoadoutsApplyLoadoutDialog")
            end,
            GetString(SI_ADDONLOADOUTS_APPLY_LOADOUT_TOOLTIP)
        )

        eventManager:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    end
end

eventManager:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
