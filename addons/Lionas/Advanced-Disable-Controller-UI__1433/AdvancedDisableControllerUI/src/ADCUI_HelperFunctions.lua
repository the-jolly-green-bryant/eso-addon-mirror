-- Advanced Disable Controller UI
-- Author: Lionas, Setsu

-- Note to addon authors: these are safe to call from your code, but make sure you add ADCUI as an optional dependency

if not ADCUI.isDefined then return end


-- get settings for either character or account wide
function ADCUI:getSettings()
  if not ADCUI.savedVariablesAccountWide and not ADCUI.savedVariables then
    return nil  -- this will cause us to default to override in the very early stages of ui loading
  else
    return ADCUI.savedVariablesAccountWide.useAccountWideSettings and ADCUI.savedVariablesAccountWide or ADCUI.savedVariables
  end
end
local function getSettingHelper(settingName)
  local settings = ADCUI:getSettings()

  return settings and settings[settingName]
end

-- call the original IsInGamepadPreferredMode function
local originalIsInGamepadPreferredMode = IsInGamepadPreferredMode
function ADCUI:originalIsInGamepadPreferredMode()
  return originalIsInGamepadPreferredMode()
end

-- disable overriding of IsInGamepadPreferredMode
-- essentially renders ADCUI:setGamepadPreferredModeOverrideState() a no-op
-- intended for internal use to manage override timing and gamepad setting caching
local shouldDisableOverride = false
function ADCUI:disableGamepadOverride(setDisabled)
  shouldDisableOverride = setDisabled
end

-- enable or disable override of IsInGamepadPreferredMode
local function myIsInGamepadPreferredMode()
  local isInGamepadMode = ADCUI:originalIsInGamepadPreferredMode()

  if getSettingHelper("useControllerUI") then
    return isInGamepadMode
  else
    return isInGamepadMode and ADCUI.vars.isLockpicking
  end
end
function ADCUI:setGamepadPreferredModeOverrideState(state)
  if ADCUI.vars.shouldBlockOverrideRequests then
    -- do nothing, requests blocked
  elseif state then
    _G["IsInGamepadPreferredMode"] = myIsInGamepadPreferredMode
  else
    _G["IsInGamepadPreferredMode"] = originalIsInGamepadPreferredMode
  end
end

-- switch the gamepad enabled state twice, because some UI elements grab the state before we can properly do an update
function ADCUI:cycleGamepadPreferredMode()
  if ADCUI:originalIsInGamepadPreferredMode() then
    SetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_GAMEPAD_PREFERRED, "false")
    SetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_GAMEPAD_PREFERRED, "true")
  else
    SetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_GAMEPAD_PREFERRED, "true")
    SetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_GAMEPAD_PREFERRED, "false")
  end
end

-- return whether default gamepad UI should be used
function ADCUI:shouldUseGamepadUI()
  return getSettingHelper("useControllerUI") and ADCUI:originalIsInGamepadPreferredMode()
end

-- return whether gamepad buttons should be used
function ADCUI:shouldUseGamepadButtons()
  return getSettingHelper("useGamepadButtons") and not ADCUI:shouldUseGamepadUI() and ADCUI:originalIsInGamepadPreferredMode()
end

-- return whether gamepad action bar should be used
function ADCUI:shouldUseGamepadActionBar()
  return getSettingHelper("useGamepadActionBar") and not ADCUI:shouldUseGamepadUI() and ADCUI:originalIsInGamepadPreferredMode()
end

-- set the reticle fonts
function ADCUI:setReticleFont(reticleFont, contextFont, isGamepad)
  local style = {
      font = contextFont,
      keybindButtonStyle = ZO_ShallowTableCopy(KEYBIND_STRIP_STANDARD_STYLE),
    }
    
  if isGamepad then
    style.keybindButtonStyle = ZO_ShallowTableCopy(KEYBIND_STRIP_GAMEPAD_STYLE)
  end
  
  style.keybindButtonStyle.nameFont = reticleFont
  
  RETICLE:ApplyPlatformStyle(style)
end

-- set the stealth icon fonts
function ADCUI:setStealthIconFont(fontName)
  local style = { font = fontName }
  
  RETICLE.stealthIcon:ApplyPlatformStyle(style)
  LOCK_PICK.stealthIcon:ApplyPlatformStyle(style)
end

