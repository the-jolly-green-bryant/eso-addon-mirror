-- Advanced Disable Controller UI
-- Author: Lionas, Setsu

ADCUI = {}

ADCUI.default = {
  -- default values
  scale = 1,
  width = 550,
  height = 30,
  point = TOP,
  lockEnabled = false,
  anchorOffsetX = 0,
  anchorOffsetY = 40,
  pinLabelScale = 1,
  useAccountWideSettings = false,
  useControllerUI = false,
  useGamepadButtons = true,
  useGamepadActionBar = true,
  
  -- fonts
  fonts = {
    reticle = "ZoFontKeybindStripDescription",
    reticleContext = "ZoInteractionPrompt",
    stealthIcon = "ZoInteractionPrompt",
  }
}

ADCUI.const = {
  UPDATE_INTERVAL_MSEC = 5000,
  ADDON_NAME = "AdvancedDisableControllerUI",
  CONTROLS_TO_BACKUP = {
    ZO_AddOnsMultiButtonKeyLabel,
    ZO_DeathAvAButton1KeyLabel,
    ZO_DeathAvADeathRecapToggleButtonKeyLabel,
    ZO_DeathBGButton1KeyLabel,
    ZO_DeathBGDeathRecapToggleButtonKeyLabel,
    ZO_DeathImperialPvEButton1KeyLabel,
    ZO_DeathImperialPvEButton2KeyLabel,
    ZO_DeathImperialPvEDeathRecapToggleButtonKeyLabel,
    ZO_DeathImperialPvPButton1KeyLabel,
    ZO_DeathImperialPvPButton2KeyLabel,
    ZO_DeathImperialPvPDeathRecapToggleButtonKeyLabel,
    ZO_DeathInEncounterDeathRecapToggleButtonKeyLabel,
    ZO_DeathReleaseOnlyButton1KeyLabel,
    ZO_DeathReleaseOnlyDeathRecapToggleButtonKeyLabel,
    ZO_DeathResurrectButton1KeyLabel,
    ZO_DeathResurrectButton2KeyLabel,
    ZO_DeathResurrectDeathRecapToggleButtonKeyLabel,
    ZO_DeathTwoOptionButton1KeyLabel,
    ZO_DeathTwoOptionButton2KeyLabel,
    ZO_DeathTwoOptionDeathRecapToggleButtonKeyLabel,
    ZO_FocusedQuestTrackerPanelContainerQuestContainerAssistedKeyLabel,
    ZO_KeybindStripControlLeftStickSlideKeyLabel,
    ZO_LootAlphaContainerButton1KeyLabel,
    ZO_LootAlphaContainerButton2KeyLabel,
    ZO_LootKeybindButtonKeyLabel,
    ZO_OptionsWindowApplyButtonKeyLabel,
    ZO_OptionsWindowResetToDefaultButtonKeyLabel,
    ZO_PlayerToPlayerAreaPromptContainerActionAreaActionKeybindButtonKeyLabel,
    ZO_PlayerToPlayerAreaPromptContainerActionAreaPromptKeybindButton1KeyLabel,
    ZO_PlayerToPlayerAreaPromptContainerActionAreaPromptKeybindButton2KeyLabel,
    ZO_ReticleContainerInteractKeybindButtonKeyLabel,
    ZO_ScreenAdjustInstructionsBindsAdjustKeyLabel,
    ZO_ScreenAdjustInstructionsBindsCancelKeyLabel,
    ZO_ScreenAdjustInstructionsBindsSaveKeyLabel,
    ZO_ScreenAdjustIntroInstructionsBindsAdjustKeyLabel,
    ZO_ScreenAdjustIntroInstructionsBindsCancelKeyLabel,
    ZO_ScreenAdjustIntroInstructionsBindsSaveKeyLabel,
    ZO_SynergyTopLevelContainerKeyKeyLabel,
  },
  FONTS = {
    "ZoFontCallout3",                   -- KB_54
    "ZoFontCallout2",                   -- KB_48
    "ZoFontCenterScreenAnnounceLarge",  -- KB_40
    "ZoFontCallout",                    -- KB_36
    "ZoFontCenterScreenAnnounceSmall",  -- KB_30
    "ZoFontConversationName",           -- KB_28
    "ZoFontHeader4",                    -- KB_26
    "ZoFontKeybindStripDescription",    -- KB_25
    "ZoInteractionPrompt",              -- KB_24
    "ZoFontConversationOption",         -- KB_22
    "ZoFontDialogKeybindDescription",   -- KB_20
    "ZoFontWindowSubtitle",             -- KB_18
    "ZoFontWinH5",                      -- KB_16
    "ZoFontGamepad61",
    "ZoFontGamepad54",
    "ZoFontGamepad45",
    "ZoFontGamepad42",
    "ZoFontGamepad36",
    "ZoFontGamepad34",
    "ZoFontGamepad27",
    "ZoFontGamepad25",
    "ZoFontGamepad22",
    "ZoFontGamepad20",
    "ZoFontGamepad18",
  },
  FONT_NAMES = {
    "Keyboard size 54",
    "Keyboard size 48",
    "Keyboard size 40",
    "Keyboard size 36",
    "Keyboard size 30",
    "Keyboard size 28",
    "Keyboard size 26",
    "Keyboard size 25",
    "Keyboard size 24",
    "Keyboard size 22",
    "Keyboard size 20",
    "Keyboard size 18",
    "Keyboard size 16",
    "Gamepad size 61",
    "Gamepad size 54",
    "Gamepad size 45",
    "Gamepad size 42",
    "Gamepad size 36",
    "Gamepad size 34",
    "Gamepad size 27",
    "Gamepad size 25",
    "Gamepad size 22",
    "Gamepad size 20",
    "Gamepad size 18",
  },
}

ADCUI.vars = {
  isLockpicking = false,
  isGamepadKeysInitialized = false,
  isGamepadActionBarOverrideInitialized = false,
  shouldBlockOverrideRequests = false,  -- internal signaling for temporary use
  backupActionButtonIcons = {},  -- used by gamepad action bar override
}

if LibDebugLogger then
  ADCUI.debugLogger = LibDebugLogger("ADCUI")
end


ADCUI.isDefined = true