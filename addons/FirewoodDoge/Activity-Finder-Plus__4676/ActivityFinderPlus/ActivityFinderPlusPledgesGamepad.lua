local ACTIVITY_FINDER_PLUS = ACTIVITY_FINDER_PLUS

local DIALOG_NAME = "ACTIVITY_FINDER_PLUS_GAMEPAD_QUICK_SELECT"
local DUNGEON_FINDER_SCENE_NAME = "gamepadDungeonFinder"
local QUICK_SELECT_ACTION = "ACTIVITY_FINDER_PLUS_QUICK_SELECT"
local QUICK_SELECT_SLASH = "/afpqs"

local STRIP_MODE_INJECT = "inject"
local STRIP_MODE_FALLBACK = "fallback"

local keybindDescriptor
local stripMode = STRIP_MODE_INJECT
local dialogRegistered = false
local sceneCallbackRegistered = false
local defaultKeybindRegistered = false
local keybindEventsRegistered = false
local isResettingKeybinds = false

local PRIMARY_BINDING_INDEX = 1

function ACTIVITY_FINDER_PLUS_ShowGamepadQuickSelectDialog()
    ACTIVITY_FINDER_PLUS.ShowGamepadQuickSelectDialog()
end

local function ReleaseQuickSelectDialog()
    ZO_Dialogs_ReleaseDialogOnButtonPress(DIALOG_NAME)
end

local function IsKeybindStripAvailable()
    return type(KEYBIND_STRIP) == "table"
        and type(KEYBIND_STRIP.AddKeybindButtonGroup) == "function"
        and type(KEYBIND_STRIP.RemoveKeybindButtonGroup) == "function"
        and type(KEYBIND_STRIP.HasKeybindButtonGroup) == "function"
end

local function GetDungeonFinderGamepad()
    return rawget(_G, "DUNGEON_FINDER_GAMEPAD")
end

function ACTIVITY_FINDER_PLUS.ShowGamepadQuickSelectDialog()
    if not ACTIVITY_FINDER_PLUS.CanUseQuickSelect() then return end
    ZO_Dialogs_ShowGamepadDialog(DIALOG_NAME)
end

local function BuildQuickSelectStripButton()
    return {
        name = function()
            return GetString(SI_BINDING_NAME_ACTIVITY_FINDER_PLUS_QUICK_SELECT)
        end,
        keybind = QUICK_SELECT_ACTION,
        gamepadPreferredKeybind = QUICK_SELECT_ACTION,
        order = 100,
        visible = function()
            return ACTIVITY_FINDER_PLUS.EnhanceGAF
                and ACTIVITY_FINDER_PLUS.CanUseQuickSelect()
        end,
        enabled = function()
            return ACTIVITY_FINDER_PLUS.CanUseQuickSelect()
        end,
        callback = function()
            ACTIVITY_FINDER_PLUS.ShowGamepadQuickSelectDialog()
        end,
    }
end

local function StripDescriptorHasQuickSelect(stripDescriptor)
    if not stripDescriptor then return false end

    for index = 1, 20 do
        local entry = stripDescriptor[index]
        if not entry then break end
        if entry.keybind == QUICK_SELECT_ACTION then
            return true
        end
    end

    return false
end

local function InjectQuickSelectIntoStripDescriptor(stripDescriptor)
    if not stripDescriptor then return false end
    if stripDescriptor.__afpQuickSelectInjected or StripDescriptorHasQuickSelect(stripDescriptor) then
        stripDescriptor.__afpQuickSelectInjected = true
        return true
    end

    local insertIndex = 1
    while stripDescriptor[insertIndex] do
        insertIndex = insertIndex + 1
    end

    stripDescriptor[insertIndex] = BuildQuickSelectStripButton()
    stripDescriptor.__afpQuickSelectInjected = true
    return true
end

local function TryInjectQuickSelectForFinder(gamepadFinder)
    if stripMode ~= STRIP_MODE_INJECT or not gamepadFinder then return false end
    if not ACTIVITY_FINDER_PLUS.EnhanceGAF then return false end
    return InjectQuickSelectIntoStripDescriptor(gamepadFinder.keybindStripDescriptor)
end

local function RemoveQuickSelectKeybindGroup()
    if stripMode ~= STRIP_MODE_FALLBACK or not IsKeybindStripAvailable() then return end
    if keybindDescriptor and KEYBIND_STRIP:HasKeybindButtonGroup(keybindDescriptor) then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindDescriptor)
    end
end

local function AddQuickSelectKeybindGroup()
    if stripMode ~= STRIP_MODE_FALLBACK or not IsKeybindStripAvailable() then return end
    if not ACTIVITY_FINDER_PLUS.EnhanceGAF then return end
    if not SCENE_MANAGER:IsShowing(DUNGEON_FINDER_SCENE_NAME) then return end

    KEYBIND_STRIP:AddKeybindButtonGroup(keybindDescriptor)
    KEYBIND_STRIP:UpdateKeybindButtonGroup(keybindDescriptor)
end

local function InstallGamepadStripHooks(targetClass)
    if not targetClass or targetClass.__afpQuickSelectHooked then return end

    ZO_PreHook(targetClass, "AddListKeybinds", function(self)
        if self ~= GetDungeonFinderGamepad() then return end
        if stripMode ~= STRIP_MODE_INJECT then return end
        if not ACTIVITY_FINDER_PLUS.EnhanceGAF then return end

        if not TryInjectQuickSelectForFinder(self) then
            stripMode = STRIP_MODE_FALLBACK
        end
    end)

    ZO_PostHook(targetClass, "InitializeKeybindStripDescriptors", function(self)
        if self ~= GetDungeonFinderGamepad() then return end
        if stripMode ~= STRIP_MODE_INJECT then return end

        local descriptor = self.keybindStripDescriptor
        if descriptor then
            descriptor.__afpQuickSelectInjected = nil
            if not TryInjectQuickSelectForFinder(self) then
                stripMode = STRIP_MODE_FALLBACK
            end
        end
    end)

    ZO_PostHook(targetClass, "AddListKeybinds", function(self)
        if self ~= GetDungeonFinderGamepad() then return end
        if stripMode == STRIP_MODE_FALLBACK then
            AddQuickSelectKeybindGroup()
        end
    end)

    targetClass.__afpQuickSelectHooked = true
end

local function GetQuickSelectActionLayerName()
    return GetString(SI_KEYBINDINGS_LAYER_ACTIVITY_FINDER_PLUS)
end

local function PushQuickSelectActionLayer()
    if type(PushActionLayerByName) ~= "function" then return end
    PushActionLayerByName(GetQuickSelectActionLayerName())
end

local function PopQuickSelectActionLayer()
    if type(RemoveActionLayerByName) ~= "function" then return end
    RemoveActionLayerByName(GetQuickSelectActionLayerName())
end

local function OnDungeonFinderSceneStateChange(scene, newState)
    if scene:GetName() ~= DUNGEON_FINDER_SCENE_NAME then return end

    if newState == SCENE_SHOWING or newState == SCENE_SHOWN then
        PushQuickSelectActionLayer()
        if stripMode == STRIP_MODE_FALLBACK then
            AddQuickSelectKeybindGroup()
        end
    elseif newState == SCENE_HIDING or newState == SCENE_HIDDEN then
        PopQuickSelectActionLayer()
        if stripMode == STRIP_MODE_FALLBACK then
            RemoveQuickSelectKeybindGroup()
        end
    end
end

local function RegisterDungeonFinderSceneCallback()
    if sceneCallbackRegistered then return end
    if not SCENE_MANAGER or type(SCENE_MANAGER.RegisterCallback) ~= "function" then return end

    SCENE_MANAGER:RegisterCallback("SceneStateChanged", OnDungeonFinderSceneStateChange)
    sceneCallbackRegistered = true
end

local function BuildCheckboxEntry(labelText, initialChecked, onToggled)
    local entryData = ZO_GamepadEntryData:New(labelText)
    entryData.checked = initialChecked == true

    local function onFilterToggled()
        if entryData.control then
            local control = entryData.control
            ZO_GamepadCheckBoxTemplate_OnClicked(control)
            entryData.checked = ZO_CheckButton_IsChecked(control.checkBox)
            if onToggled then
                onToggled(entryData.checked)
            end
        end
    end

    local function setupFunction(control, data, selected, reselectingDuringRebuild, enabled, active)
        data.callback = onFilterToggled
        ZO_GamepadCheckBoxTemplate_Setup(control, data, selected, reselectingDuringRebuild, enabled, active)

        if entryData.checked then
            ZO_CheckButton_SetChecked(control.checkBox)
        else
            ZO_CheckButton_SetUnchecked(control.checkBox)
        end
        entryData.control = control
    end

    entryData.setup = setupFunction
    entryData.callback = onFilterToggled
    return {
        template = "ZO_CheckBoxTemplate_WithPadding_Gamepad",
        entryData = entryData,
        templateData = {
            setup = setupFunction,
        },
    }
end

local function BuildActionEntry(labelStringId, callback, isEnabled)
    local entryData = ZO_GamepadEntryData:New(GetString(labelStringId))
    entryData.isEnabledFn = isEnabled

    local function setupFunction(control, data, selected, reselectingDuringRebuild, enabled, active)
        data:ClearIcons()
        local rowEnabled = enabled
        if rowEnabled and data.isEnabledFn then
            rowEnabled = data.isEnabledFn()
        end
        ZO_SharedGamepadEntry_OnSetup(control, data, selected, reselectingDuringRebuild, rowEnabled, active)
    end

    entryData.setup = setupFunction
    entryData.callback = function()
        if entryData.isEnabledFn and not entryData.isEnabledFn() then
            return
        end
        callback()
        ReleaseQuickSelectDialog()
    end

    return {
        template = "ZO_GamepadMenuEntryTemplate",
        entryData = entryData,
        templateData = {
            setup = setupFunction,
        },
    }
end

local function BuildQuickSelectParametricList()
    local parametricList = {}
    local veteranState = ACTIVITY_FINDER_PLUS.checkVeteran

    table.insert(parametricList, BuildCheckboxEntry(
        GetString(SI_ACTIVITY_FINDER_PLUS_VETERAN_MODE_LABEL),
        veteranState.sessionEnabled == true,
        function(checked)
            ACTIVITY_FINDER_PLUS.SetVeteranModeEnabled(checked)
        end))

    table.insert(parametricList, BuildActionEntry(SI_ACTIVITY_FINDER_PLUS_CHECK_QUESTS, function()
        ACTIVITY_FINDER_PLUS.RunQuickSelectPledges()
    end))

    if ACTIVITY_FINDER_PLUS.libSetsAvailable then
        table.insert(parametricList, BuildActionEntry(SI_ACTIVITY_FINDER_PLUS_CHECK_SETS, function()
            ACTIVITY_FINDER_PLUS.RunQuickSelectSets()
        end))
    end

    table.insert(parametricList, BuildActionEntry(SI_ACTIVITY_FINDER_PLUS_CHECK_SKILL_QUESTS, function()
        ACTIVITY_FINDER_PLUS.RunQuickSelectSkillQuests()
    end, function()
        return ACTIVITY_FINDER_PLUS.HasAnyIncompleteSkillQuest()
    end))

    return parametricList
end

local function RegisterQuickSelectDialog()
    if dialogRegistered then return end
    if type(ZO_Dialogs_RegisterCustomDialog) ~= "function" then return end

    ZO_Dialogs_RegisterCustomDialog(DIALOG_NAME, {
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
            allowShowOnNextScene = true,
        },
        title = {
            text = GetString(SI_ACTIVITY_FINDER_PLUS_QUICK_SELECT),
        },
        setup = function(dialog)
            dialog.info.parametricList = BuildQuickSelectParametricList()
            dialog:setupFunc()
        end,
        blockDialogReleaseOnPress = true,
        canQueue = true,
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = function(dialog)
                    local data = dialog.entryList:GetTargetData()
                    if data and data.callback then
                        data.callback()
                    end
                end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CLOSE,
                callback = function()
                    ReleaseQuickSelectDialog()
                end,
            },
        },
    })

    dialogRegistered = true
end

local function IsUnboundKey(key)
    return not key or key == 0 or key == KEY_INVALID
end

local function CallSecureBindingFunction(functionName, ...)
    if IsProtectedFunction(functionName) or IsPrivateFunction(functionName) then
        return CallSecureProtected(functionName, ...)
    end

    local bindingFunction = _G[functionName]
    if type(bindingFunction) == "function" then
        return bindingFunction(...)
    end

    return false
end

local function BindKeyToActionSecure(layerIndex, categoryIndex, actionIndex, bindingIndex, key, mod1, mod2, mod3, mod4)
    return CallSecureBindingFunction(
        "BindKeyToAction",
        layerIndex, categoryIndex, actionIndex, bindingIndex,
        key, mod1 or 0, mod2 or 0, mod3 or 0, mod4 or 0)
end

local function IsKeyboardBindingKey(key)
    if IsUnboundKey(key) then return false end
    if type(IsKeyCodeKeyboardKey) == "function" and IsKeyCodeKeyboardKey(key) then
        return true
    end
    if type(IsKeyCodeMouseKey) == "function" and IsKeyCodeMouseKey(key) then
        return true
    end
    return false
end

local function GetGamepadHoldYBinding()
    if type(ConvertKeyPressToHold) == "function" and KEY_GAMEPAD_BUTTON_4 then
        return ConvertKeyPressToHold(KEY_GAMEPAD_BUTTON_4), 0, 0, 0, 0
    end
    if KEY_GAMEPAD_BUTTON_4 then
        return KEY_GAMEPAD_BUTTON_4, 0, 0, 0, 0
    end
    return nil
end

local function GetQuickSelectSavedVariables()
    return ACTIVITY_FINDER_PLUS.savedVariables
end

local function IsSameQuickSelectAction(layerIndex, categoryIndex, actionIndex)
    local layer, category, action = GetActionIndicesFromName(QUICK_SELECT_ACTION)
    return layer ~= nil
        and layerIndex == layer
        and categoryIndex == category
        and actionIndex == action
end

local function IsQuickSelectKeybindTouched()
    local savedVariables = GetQuickSelectSavedVariables()
    return savedVariables ~= nil and savedVariables.gamepadQuickSelectKeybindTouched == true
end

local function MarkQuickSelectKeybindTouched()
    local savedVariables = GetQuickSelectSavedVariables()
    if savedVariables then
        savedVariables.gamepadQuickSelectKeybindTouched = true
    end
end

local function SaveQuickSelectBindingRecord(bindingIndex, key, mod1, mod2, mod3, mod4)
    local savedVariables = GetQuickSelectSavedVariables()
    if not savedVariables then return end

    savedVariables.gamepadQuickSelectBinding = {
        bindingIndex = bindingIndex,
        key = key,
        mod1 = mod1 or 0,
        mod2 = mod2 or 0,
        mod3 = mod3 or 0,
        mod4 = mod4 or 0,
    }
end

local function GetQuickSelectBindingRecord()
    local savedVariables = GetQuickSelectSavedVariables()
    if not savedVariables then return nil end
    return savedVariables.gamepadQuickSelectBinding
end

local function IsValidGamepadQuickSelectBinding(key)
    return not IsUnboundKey(key) and not IsKeyboardBindingKey(key)
end

local function SyncQuickSelectBindingFromGame()
    local layer, category, action = GetActionIndicesFromName(QUICK_SELECT_ACTION)
    if not layer then return false end

    local bindingIndex = PRIMARY_BINDING_INDEX
    local key, mod1, mod2, mod3, mod4 = GetActionBindingInfo(layer, category, action, bindingIndex)
    if IsValidGamepadQuickSelectBinding(key) then
        SaveQuickSelectBindingRecord(bindingIndex, key, mod1, mod2, mod3, mod4)
        return true
    end

    if IsQuickSelectKeybindTouched() then
        local savedVariables = GetQuickSelectSavedVariables()
        if savedVariables then
            savedVariables.gamepadQuickSelectBinding = nil
        end
    end
    return false
end

local function RestoreQuickSelectBindingFromSavedVars()
    local record = GetQuickSelectBindingRecord()
    if not record or IsUnboundKey(record.key) or not IsValidGamepadQuickSelectBinding(record.key) then
        return false
    end
    if record.bindingIndex and record.bindingIndex ~= PRIMARY_BINDING_INDEX and record.bindingIndex ~= 2 then
        return false
    end

    local layer, category, action = GetActionIndicesFromName(QUICK_SELECT_ACTION)
    if not layer then return false end

    local currentKey = GetActionBindingInfo(layer, category, action, PRIMARY_BINDING_INDEX)
    if not IsUnboundKey(currentKey) then return true end

    BindKeyToActionSecure(
        layer, category, action, PRIMARY_BINDING_INDEX,
        record.key, record.mod1, record.mod2, record.mod3, record.mod4)
    local afterKey = GetActionBindingInfo(layer, category, action, PRIMARY_BINDING_INDEX)
    if not IsUnboundKey(afterKey) then
        SaveQuickSelectBindingRecord(PRIMARY_BINDING_INDEX, record.key, record.mod1, record.mod2, record.mod3, record.mod4)
    end
    return not IsUnboundKey(afterKey)
end

local function RegisterFactoryDefaultKeybind()
    if IsQuickSelectKeybindTouched() then return end

    local gamepadKey, mod1, mod2, mod3, mod4 = GetGamepadHoldYBinding()
    if not gamepadKey then return end

    local layer, category, action = GetActionIndicesFromName(QUICK_SELECT_ACTION)
    if not layer then return end

    local currentKey = GetActionBindingInfo(layer, category, action, PRIMARY_BINDING_INDEX)
    if IsUnboundKey(currentKey) then
        local legacyKey, legacyMod1, legacyMod2, legacyMod3, legacyMod4 =
            GetActionBindingInfo(layer, category, action, 2)
        if IsValidGamepadQuickSelectBinding(legacyKey) then
            gamepadKey = legacyKey
            mod1, mod2, mod3, mod4 = legacyMod1, legacyMod2, legacyMod3, legacyMod4
            CallSecureBindingFunction("UnbindKeyFromAction", layer, category, action, 2)
        end
    end

    if type(CreateDefaultActionBind) == "function" then
        CreateDefaultActionBind(QUICK_SELECT_ACTION, gamepadKey, mod1, mod2, mod3, mod4)
    end

    currentKey = GetActionBindingInfo(layer, category, action, PRIMARY_BINDING_INDEX)
    if IsKeyboardBindingKey(currentKey) then
        CallSecureBindingFunction("UnbindKeyFromAction", layer, category, action, PRIMARY_BINDING_INDEX)
        currentKey = GetActionBindingInfo(layer, category, action, PRIMARY_BINDING_INDEX)
    end

    if IsUnboundKey(currentKey) then
        BindKeyToActionSecure(
            layer, category, action, PRIMARY_BINDING_INDEX,
            gamepadKey, mod1, mod2, mod3, mod4)
        currentKey = GetActionBindingInfo(layer, category, action, PRIMARY_BINDING_INDEX)
        if not IsUnboundKey(currentKey) then
            SaveQuickSelectBindingRecord(PRIMARY_BINDING_INDEX, gamepadKey, mod1, mod2, mod3, mod4)
        end
    end
end

local function ClearStaleBindingRecordForFactoryApply()
    local savedVariables = GetQuickSelectSavedVariables()
    if savedVariables then
        savedVariables.gamepadQuickSelectBinding = nil
    end
end

local function OnQuickSelectKeybindChanged(_, layerIndex, categoryIndex, actionIndex, bindingIndex)
    if not IsSameQuickSelectAction(layerIndex, categoryIndex, actionIndex) then return end
    if isResettingKeybinds then return end
    if bindingIndex ~= PRIMARY_BINDING_INDEX then return end

    MarkQuickSelectKeybindTouched()
    zo_callLater(SyncQuickSelectBindingFromGame, 0)
end

local function ResetQuickSelectKeybindSavedState()
    local savedVariables = GetQuickSelectSavedVariables()
    if not savedVariables then return end

    savedVariables.gamepadQuickSelectKeybindTouched = false
    savedVariables.gamepadQuickSelectBinding = nil
end

local function BeginKeybindReset()
    isResettingKeybinds = true
    ResetQuickSelectKeybindSavedState()
end

local function EnsureQuickSelectPrimaryBinding()
    if SyncQuickSelectBindingFromGame() then return end

    if IsQuickSelectKeybindTouched() then
        RestoreQuickSelectBindingFromSavedVars()
        return
    end

    ClearStaleBindingRecordForFactoryApply()
    RegisterFactoryDefaultKeybind()
end

local function EndKeybindResetAndApplyFactory()
    isResettingKeybinds = false
    defaultKeybindRegistered = false
    zo_callLater(RegisterFactoryDefaultKeybind, 0)
end

local function RegisterQuickSelectKeybindEvents()
    if keybindEventsRegistered or not ACTIVITY_FINDER_PLUS.eventManager then return end

    local eventManager = ACTIVITY_FINDER_PLUS.eventManager
    local eventTag = ACTIVITY_FINDER_PLUS.name .. "_QuickSelectKeybind"

    eventManager:RegisterForEvent(eventTag .. "_Set", EVENT_KEYBINDING_SET, OnQuickSelectKeybindChanged)
    eventManager:RegisterForEvent(eventTag .. "_Cleared", EVENT_KEYBINDING_CLEARED, OnQuickSelectKeybindChanged)

    if type(ZO_PreHook) == "function" then
        ZO_PreHook("ResetAllBindsToDefault", BeginKeybindReset)
        ZO_PreHook("ResetGamepadBindsToDefault", BeginKeybindReset)
    end
    if type(ZO_PostHook) == "function" then
        ZO_PostHook("ResetAllBindsToDefault", EndKeybindResetAndApplyFactory)
        ZO_PostHook("ResetGamepadBindsToDefault", EndKeybindResetAndApplyFactory)
    end

    keybindEventsRegistered = true
end

local function RegisterQuickSelectDefaultKeybind()
    if type(GetActionIndicesFromName) ~= "function" then return end

    RegisterQuickSelectKeybindEvents()
    EnsureQuickSelectPrimaryBinding()
    defaultKeybindRegistered = true
end

local function OnKeybindingsLoadedForQuickSelect()
    EnsureQuickSelectPrimaryBinding()
    if not defaultKeybindRegistered then
        RegisterQuickSelectKeybindEvents()
        defaultKeybindRegistered = true
    end
    if ACTIVITY_FINDER_PLUS.eventManager then
        ACTIVITY_FINDER_PLUS.eventManager:UnregisterForEvent(
            ACTIVITY_FINDER_PLUS.name .. "_QuickSelectDefaultKeybind",
            EVENT_KEYBINDINGS_LOADED)
    end
end

local function RegisterQuickSelectSlashCommand()
    SLASH_COMMANDS[QUICK_SELECT_SLASH] = function()
        if not ACTIVITY_FINDER_PLUS.EnhanceGAF then
            ACTIVITY_FINDER_PLUS.print("Enable Enhanced Activity Finder in /afp settings.")
            return
        end
        ACTIVITY_FINDER_PLUS.ShowGamepadQuickSelectDialog()
    end
end

-- Achievement panel text (BuildAchievementPanelText) and dungeon lookup
-- (GetDungeonForActivityId) are shared with the keyboard tooltip hook in
-- ActivityFinderPlusPledges.lua.
local function GetSelectedDungeonForFinder(gamepadFinder)
    if type(gamepadFinder.GetCurrentList) ~= "function" then return nil end
    local currentList = gamepadFinder:GetCurrentList()
    if not currentList then return nil end

    local targetData = currentList:GetTargetData()
    if not targetData or not targetData.data then return nil end

    local entryData = targetData.data
    if entryData.isRoleSelector or not entryData.id then return nil end

    return ACTIVITY_FINDER_PLUS.GetDungeonForActivityId(entryData.id)
end

local function AppendAchievementsToSingularPanel(gamepadFinder)
    if not ACTIVITY_FINDER_PLUS.EnhanceGAF then return end
    if gamepadFinder ~= GetDungeonFinderGamepad() then return end
    if not gamepadFinder.isShowingSingularPanel then return end

    local label = gamepadFinder.descriptionLabel
    if not label then return end

    local dungeon, mode = GetSelectedDungeonForFinder(gamepadFinder)
    if not dungeon then return end

    local achievementText = ACTIVITY_FINDER_PLUS.BuildAchievementPanelText(dungeon, mode)
    if not achievementText then return end

    local currentText = label:GetText()
    if currentText and currentText ~= "" then
        label:SetText(currentText .. "\n\n" .. achievementText)
    else
        label:SetText(achievementText)
    end
end

local function InstallSingularPanelHook(targetClass)
    if not targetClass or targetClass.__afpAchievementPanelHooked then return end
    if type(targetClass.RefreshSingularSectionPanel) ~= "function" then return end

    SecurePostHook(targetClass, "RefreshSingularSectionPanel", function(self)
        AppendAchievementsToSingularPanel(self)
    end)

    targetClass.__afpAchievementPanelHooked = true
end

function ACTIVITY_FINDER_PLUS.RefreshGamepadQuickSelectKeybind()
    local gamepadFinder = GetDungeonFinderGamepad()

    if SCENE_MANAGER:IsShowing(DUNGEON_FINDER_SCENE_NAME) then
        PushQuickSelectActionLayer()
    else
        PopQuickSelectActionLayer()
    end

    if stripMode == STRIP_MODE_INJECT then
        if gamepadFinder and gamepadFinder.keybindStripDescriptor then
            gamepadFinder.keybindStripDescriptor.__afpQuickSelectInjected = nil
            TryInjectQuickSelectForFinder(gamepadFinder)
        end
        if gamepadFinder and type(gamepadFinder.AddListKeybinds) == "function" then
            gamepadFinder:AddListKeybinds()
        end
        return
    end

    if not IsKeybindStripAvailable() then return end

    if KEYBIND_STRIP:HasKeybindButtonGroup(keybindDescriptor) then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(keybindDescriptor)
    elseif SCENE_MANAGER:IsShowing(DUNGEON_FINDER_SCENE_NAME) then
        AddQuickSelectKeybindGroup()
    end
end

function ACTIVITY_FINDER_PLUS.InitializePledgesGamepad()
    if type(IsInGamepadPreferredMode) ~= "function" then return end

    local quickSelectButton = BuildQuickSelectStripButton()
    keybindDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        [1] = quickSelectButton,
    }

    RegisterQuickSelectDialog()
    RegisterQuickSelectSlashCommand()

    if type(GetActionIndicesFromName) == "function" and ACTIVITY_FINDER_PLUS.eventManager then
        ACTIVITY_FINDER_PLUS.eventManager:RegisterForEvent(
            ACTIVITY_FINDER_PLUS.name .. "_QuickSelectDefaultKeybind",
            EVENT_KEYBINDINGS_LOADED,
            OnKeybindingsLoadedForQuickSelect)
        zo_callLater(RegisterQuickSelectDefaultKeybind, 0)
    end

    local templateClass = rawget(_G, "ZO_ActivityFinderTemplate_Gamepad")
    local screenClass = rawget(_G, "ZO_Gamepad_ParametricList_Screen")

    if templateClass then
        InstallGamepadStripHooks(templateClass)
        InstallSingularPanelHook(templateClass)
    end
    if screenClass and screenClass ~= templateClass then
        InstallGamepadStripHooks(screenClass)
    end

    RegisterDungeonFinderSceneCallback()

    local gamepadFinder = GetDungeonFinderGamepad()
    if gamepadFinder and not TryInjectQuickSelectForFinder(gamepadFinder) then
        stripMode = STRIP_MODE_FALLBACK
    end
end
