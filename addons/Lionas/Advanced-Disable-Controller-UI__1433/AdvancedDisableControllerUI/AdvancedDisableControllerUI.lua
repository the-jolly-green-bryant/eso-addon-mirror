-- Advanced Disable Controller UI
-- Author: Lionas, Setsu

-- CHANGELOG:
--    preliminary implementation for gamepad action bar override
--    added keybinds for gamepad buttons and action bar

-- TODO:
--    world map zooming...etc [worldmap.lua]

-- BUGS:
--    sprint is now a toggle


if not ADCUI.isDefined then return end


-- set the override early so that other addons react correctly
ADCUI:setGamepadPreferredModeOverrideState(true)


-- Initialize preferences
local function initializePrefs()
  ADCUI.savedVariablesAccountWide = ZO_SavedVars:NewAccountWide("AdvancedDisableControllerUI_SavedPrefs", 1, nil, ADCUI.default)
  ADCUI.savedVariables = ZO_SavedVars:NewCharacterIdSettings("AdvancedDisableControllerUI_SavedPrefs", 1, nil, ADCUI.default)
end

-- update panel
local function loadMenuPanel()
  LoadLAM2Panel() -- load Menu Settings
  EVENT_MANAGER:UnregisterForEvent("AdvancedDisableControllerUI_Player", EVENT_PLAYER_ACTIVATED) -- unregist event handler
end

-- used by the onGamepadModeChanged handler to get the gamepad icons
local function initializeGamepadIcons(eventCode, gamepadPreferred)
  if gamepadPreferred then
    ADCUI:getGamepadIcons()
    ADCUI.vars.shouldBlockOverrideRequests = false
    ADCUI:setGamepadPreferredModeOverrideState(true)
    EVENT_MANAGER:UnregisterForEvent(ADCUI.const.ADDON_NAME, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, initializeGamepadIcons)
    EVENT_MANAGER:RegisterForEvent(ADCUI.const.ADDON_NAME, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, onGamepadModeChanged)
    ADCUI:cycleGamepadPreferredMode() -- next stop -> onGamepadModeChanged
  end
end

-- handle the gamepad mode change event
-- we use this to handle overrides and cleanup
-- has to be global
function onGamepadModeChanged(eventCode, gamepadPreferred)
  KEYBIND_STRIP:ClearKeybindGroupStateStack() -- this call is important! If the user changed modes mid-scene such as quest journal or bank, the strip stack would be left in an inconsistent state eventually leading to LUA errors

  -- switch settings for each mode
  if gamepadPreferred and not ADCUI:shouldUseGamepadUI() then
    if not ADCUI.vars.isGamepadKeysInitialized then
      -- we have not yet cached the gamepad icons yet, so we need to run the initialization
      -- but we already have the override enabled, so we need to disable it and cycle the gamepad state
      -- this is so that we can grab the correct settings, and after we do this we re-enable override and cycle again to have everything set correctly
      EVENT_MANAGER:UnregisterForEvent(ADCUI.const.ADDON_NAME, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, onGamepadModeChanged)
      EVENT_MANAGER:RegisterForEvent(ADCUI.const.ADDON_NAME, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, initializeGamepadIcons)
      ADCUI:setGamepadPreferredModeOverrideState(false)
      ADCUI.vars.shouldBlockOverrideRequests = true -- we need to make sure everything is initialized in gamepad mode before we call ADCUI:getGamepadIcons()
      ADCUI:cycleGamepadPreferredMode() -- next stop -> initializeGamepadIcons
      return
    elseif ADCUI:shouldUseGamepadActionBar() and not ADCUI.vars.isGamepadActionBarOverrideInitialized then
      ADCUI:setGamepadActionBarOverrideState(true)
      ADCUI.vars.isGamepadActionBarOverrideInitialized = true
      ADCUI:cycleGamepadPreferredMode()
      return
    end

    if ADCUI:shouldUseGamepadButtons() then
      ADCUI:setGamepadIcons()
      ADCUI:setGamepadUISettings()
    end
    
    --adjust fonts (we don't need to undo these changes on gamepad mode change, the game will do it for us)
    local settings = ADCUI:getSettings()
    ADCUI:setReticleFont(settings.fonts.reticle, settings.fonts.reticleContext)
    ADCUI:setStealthIconFont(settings.fonts.stealthIcon)

    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.DEFAULT_CLICK, "Gamepad UI override enabled")
  else
    ADCUI:setKeyboardUISettings()
  end
end

-- OnLoad
local function onLoad(event, addon)
  if (addon ~= ADCUI.const.ADDON_NAME) then
    return
  end

  initializePrefs()
  onUpdateCompass()

  if ADCUI:originalIsInGamepadPreferredMode() then
    -- we loaded in gamepad mode but with our override enabled, so many controls initialized in an inconsistent state
    if ADCUI:shouldUseGamepadUI() then
      ADCUI:cycleGamepadPreferredMode() -- fix inconsistent state
    else
      onGamepadModeChanged(0, true) -- let onGamepadModeChanged take care of initialization into proper state
    end
  end

  ZO_CompassFrame:SetHandler("OnUpdate", frameUpdate)

  EVENT_MANAGER:RegisterForEvent("AdvancedDisableControllerUI_Player", EVENT_PLAYER_ACTIVATED, loadMenuPanel)
  EVENT_MANAGER:UnregisterForEvent("AdvancedDisableControllerUI_OnLoad", EVENT_ADD_ON_LOADED)
end

-- Update variables
local function onUpdateVars()

  local anchor, point, rTo, rPoint, offsetx, offsety = ZO_CompassFrame:GetAnchor()
  local settings = ADCUI:getSettings()

  if((offsetx ~= settings.anchorOffsetX and offsetx ~= ADCUI.default.anchorOffsetX)
      or
     (offsety ~= settings.anchorOffsetY and offsety ~= ADCUI.default.anchorOffsetY)) then

    settings.anchorOffsetX = offsetx
    settings.anchorOffsetY = offsety
    settings.point = point

    if(rPoint ~= nil) then
      settings.point = rPoint
    end
  end
end


-- [Register Event Handlers]

EVENT_MANAGER:RegisterForEvent(ADCUI.const.ADDON_NAME, EVENT_ADD_ON_LOADED, onLoad)
EVENT_MANAGER:RegisterForEvent(ADCUI.const.ADDON_NAME, EVENT_GLOBAL_MOUSE_UP, onUpdateVars)
EVENT_MANAGER:RegisterForEvent(ADCUI.const.ADDON_NAME, EVENT_GLOBAL_MOUSE_DOWN, onUpdateVars)
EVENT_MANAGER:RegisterForEvent(ADCUI.const.ADDON_NAME, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, onGamepadModeChanged)
