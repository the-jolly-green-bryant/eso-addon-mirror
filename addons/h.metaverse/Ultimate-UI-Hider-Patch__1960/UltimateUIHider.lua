UltimateUIHider = {}
UltimateUIHider.name = "UltimateUIHider"
UltimateUIHider.version = 1.7002

UltimateUIHider.default = {
    isInterfaceEventHandler = 0,
    UltimateUIHider_isUIHidden = false,

    defaultInteractableGlow = GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_INTERACTABLE_GLOW_ENABLED),
    defaultTargetGlow = GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_TARGET_GLOW_ENABLED),
    defaultQuestBestowerIndicator = GetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_QUEST_BESTOWER_INDICATORS),
    defaultGroupIndicators = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_INDICATORS),
    defaultFollowIndicator = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_FOLLOWER_INDICATORS),
    defaultAllianceIndicators = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ALLIANCE_INDICATORS),
    defaultResurrectIndicator = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_RESURRECT_INDICATORS),
    defaultAllHealthBars = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ALL_HEALTHBARS),
    defaultAllNamePlates = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ALL_NAMEPLATES),
    defaultChatBubbles = GetSetting(SETTING_TYPE_CHAT_BUBBLE, CHAT_BUBBLE_SETTING_ENABLED),
    defaultChatBubbleSpeed = GetSetting(SETTING_TYPE_CHAT_BUBBLE, CHAT_BUBBLE_SETTING_SPEED_MODIFIER)
}

function UltimateUIHider.setSettingsFromFile()
    SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_INTERACTABLE_GLOW_ENABLED, UltimateUIHider.savedVariables.defaultInteractableGlow)
    SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_TARGET_GLOW_ENABLED, UltimateUIHider.savedVariables.defaultTargetGlow)

    SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_QUEST_BESTOWER_INDICATORS, UltimateUIHider.savedVariables.defaultQuestBestowerIndicator)

    SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_INDICATORS, UltimateUIHider.savedVariables.defaultGroupIndicators)
    SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_FOLLOWER_INDICATORS, UltimateUIHider.savedVariables.defaultFollowIndicator)
    SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ALLIANCE_INDICATORS, UltimateUIHider.savedVariables.defaultAllianceIndicators)
    SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_RESURRECT_INDICATORS, UltimateUIHider.savedVariables.defaultResurrectIndicator)
    SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ALL_HEALTHBARS, UltimateUIHider.savedVariables.defaultAllHealthBars)
    SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ALL_NAMEPLATES, UltimateUIHider.savedVariables.defaultAllNamePlates)

    SetSetting(SETTING_TYPE_CHAT_BUBBLE, CHAT_BUBBLE_SETTING_ENABLED, UltimateUIHider.savedVariables.defaultChatBubbles)
    SetSetting(SETTING_TYPE_CHAT_BUBBLE, CHAT_BUBBLE_SETTING_SPEED_MODIFIER, UltimateUIHider.savedVariables.defaultChatBubbleSpeed)

end

--Saves current settings to file.
function UltimateUIHider.saveSettingsToFile()
    if UltimateUIHider.savedVariables.UltimateUIHider_isUIHidden == false then
        UltimateUIHider.savedVariables.defaultInteractableGlow = GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_INTERACTABLE_GLOW_ENABLED)
        UltimateUIHider.savedVariables.defaultTargetGlow = GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_TARGET_GLOW_ENABLED)
        UltimateUIHider.savedVariables.defaultQuestBestowerIndicator = GetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_QUEST_BESTOWER_INDICATORS)
        UltimateUIHider.savedVariables.defaultGroupIndicators = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_INDICATORS)
        UltimateUIHider.savedVariables.defaultFollowIndicator = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_FOLLOWER_INDICATORS)
        UltimateUIHider.savedVariables.defaultAllianceIndicators = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ALLIANCE_INDICATORS)
        UltimateUIHider.savedVariables.defaultResurrectIndicator = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_RESURRECT_INDICATORS)
        UltimateUIHider.savedVariables.defaultAllHealthBars = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ALL_HEALTHBARS)
        UltimateUIHider.savedVariables.defaultAllNamePlates = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ALL_NAMEPLATES)
        UltimateUIHider.savedVariables.defaultChatBubbles =  GetSetting(SETTING_TYPE_CHAT_BUBBLE, CHAT_BUBBLE_SETTING_ENABLED)
        UltimateUIHider.savedVariables.defaultChatBubbleSpeed =  GetSetting(SETTING_TYPE_CHAT_BUBBLE, CHAT_BUBBLE_SETTING_SPEED_MODIFIER)

    end
end

--Event Handler
function UltimateUIHider.interfaceEventHandlerToggle()
    if UltimateUIHider.savedVariables.isInterfaceEventHandler == 1 then
        EVENT_MANAGER:UnregisterForEvent(UltimateUIHider.name, EVENT_INTERFACE_SETTING_CHANGED)
    else
        EVENT_MANAGER:RegisterForEvent(UltimateUIHider.name, EVENT_INTERFACE_SETTING_CHANGED, UltimateUIHider.saveSettingsToFile)
    end
end

--Turns off UI
--Sets all settings to zero.
function UltimateUIHider.turnOffUI()
    SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_INTERACTABLE_GLOW_ENABLED, "false", DO_NOT_SAVE_TO_PERSISTED_DATA)
    SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_TARGET_GLOW_ENABLED, "false", DO_NOT_SAVE_TO_PERSISTED_DATA)
    SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_QUEST_BESTOWER_INDICATORS, "false", DO_NOT_SAVE_TO_PERSISTED_DATA)
    SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_INDICATORS, "false", DO_NOT_SAVE_TO_PERSISTED_DATA)
    SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_FOLLOWER_INDICATORS, "false", DO_NOT_SAVE_TO_PERSISTED_DATA)
    SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ALLIANCE_INDICATORS, NAMEPLATE_CHOICE_NEVER, DO_NOT_SAVE_TO_PERSISTED_DATA)
    SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_RESURRECT_INDICATORS, "false", DO_NOT_SAVE_TO_PERSISTED_DATA)
    SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ALL_HEALTHBARS, "false", DO_NOT_SAVE_TO_PERSISTED_DATA)
    SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ALL_NAMEPLATES, "false", DO_NOT_SAVE_TO_PERSISTED_DATA)
    SetSetting(SETTING_TYPE_CHAT_BUBBLE, CHAT_BUBBLE_SETTING_ENABLED, "false", DO_NOT_SAVE_TO_PERSISTED_DATA)
    SetSetting(SETTING_TYPE_CHAT_BUBBLE, CHAT_BUBBLE_SETTING_SPEED_MODIFIER, "0.80000001")
end

--Toggle UI on an off.
--Toggle 1: Turns everything off.
--Toggle 2: Sets user preferred settings and toggles the default ui back on.
function UltimateUIHider.UltimateUIHiderToggler()
    if not UltimateUIHider.savedVariables.UltimateUIHider_isUIHidden then
        UltimateUIHider.interfaceEventHandlerToggle()
        UltimateUIHider.turnOffUI()
        ToggleShowIngameGui()
        SetGameCameraUIMode(false)
        SetFloatingMarkerGlobalAlpha(0)
        UltimateUIHider.savedVariables.UltimateUIHider_isUIHidden = true
    else
        UltimateUIHider.setSettingsFromFile()
        ToggleShowIngameGui()
        SetGameCameraUIMode(true)
        SetFloatingMarkerGlobalAlpha(100)
        UltimateUIHider.savedVariables.UltimateUIHider_isUIHidden = false
        UltimateUIHider.interfaceEventHandlerToggle()
    end
end

--Initialize settings/get default settings
function UltimateUIHider:Initialize()
    --Our saved variables file. Needs to be in the initializer.
    UltimateUIHider.savedVariables = ZO_SavedVars:New("UltimateUIHiderSavedVariables", UltimateUIHider.version, nil, UltimateUIHider.default)

    --Handles logic to store user preferred settings. (prevents errors if logged out while UI is hidden)
    if UltimateUIHider.savedVariables.UltimateUIHider_isUIHidden == true then
        UltimateUIHider.setSettingsFromFile()
        UltimateUIHider.savedVariables.UltimateUIHider_isUIHidden = false
    else
        UltimateUIHider.saveSettingsToFile()
        UltimateUIHider.savedVariables.UltimateUIHider_isUIHidden = false
    end
    --turn on the event listener for on interface change
    UltimateUIHider.savedVariables.isInterfaceEventHandler = 0
    UltimateUIHider.interfaceEventHandlerToggle()
    EVENT_MANAGER:UnregisterForEvent(UltimateUIHider.name, EVENT_ADD_ON_LOADED)
end

--Function to call the initializer when this specific addon is loaded.
function UltimateUIHider.OnAddOnLoaded(event, addonName)
    if addonName == UltimateUIHider.name then
        UltimateUIHider:Initialize()
    end
end

--Events
EVENT_MANAGER:RegisterForEvent(UltimateUIHider.name, EVENT_ADD_ON_LOADED, UltimateUIHider.OnAddOnLoaded)

--Slash commands
SLASH_COMMANDS["/hideui"] = UltimateUIHider.UltimateUIHiderToggler