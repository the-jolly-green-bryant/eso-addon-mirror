-- Advanced Disable Controller UI
-- Author: Lionas, Setsu

if not ADCUI.isDefined then return end

-- NOTES:
-- ButtonControl.m_object.m_buttonData.callback call this function to click, but would still need to animate the button group control to get the button to show clicked

-- SCENE_MANAGER:CallWhen(sceneName, state, func)
-- SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState, newState)
-- scene:RegisterCallback("StateChange", function(oldState, newState)
    -- if newState == SCENE_SHOWNING then
    -- elseif newState == SCENE_SHOWN then
    -- elseif newState == SCENE_HIDING then
    -- elseif newState == SCENE_HIDDEN then
    -- end
-- end)

-- [Helper Functions]

function ADCUI:getCurrentSceneIndex()
  return MAIN_MENU_KEYBOARD.sceneInfo[SCENE_MANAGER:GetCurrentSceneName()].category
end

function ADCUI:getLastSceneIndex()
  local lastSceneIndex = 0
  
  for _, categoryInfo in ipairs(MAIN_MENU_KEYBOARD.categoryInfo) do
    if categoryInfo.lastSceneGroupName or categoryInfo.lastSceneName then
      lastSceneIndex = lastSceneIndex + 1
    end
  end
  
  return lastSceneIndex
end

function ADCUI:shouldShowInCurrentScene()
  -- don't show in crown store, crates, and champion because it overlaps with stuff
  
  local index = ADCUI:getCurrentSceneIndex()
  
  -- check crown store
  if (index == MAIN_MENU_KEYBOARD.sceneGroupInfo.marketSceneGroup.category) then
    return false
  end
  
  -- check crates
  if (index == MAIN_MENU_KEYBOARD.sceneInfo.crownCrateKeyboard.category) then
    return false
  end
  
  -- check champion perks
  if (index == MAIN_MENU_KEYBOARD.sceneInfo.championPerks.category) then
    return false
  end
  
  return true
end

function ADCUI:isSceneHidden(sceneIndex)
  -- this is to handle cases such as when aliance war is not yet unlocked and the menu won't show
  
  local count = 0
  
  for i = 1, MAIN_MENU_KEYBOARD.categoryBar:GetNumChildren() do
    local control = MAIN_MENU_KEYBOARD.categoryBar:GetChild(i)
    local name = control:GetName()
    
    if string.find(name, "Button") then
      --we avoid the padding bar by checking the name
      count = count + 1
      
      if (count == sceneIndex) then
        return control:IsHidden()
      end
    end
  end
  
  return false
end

function ADCUI:showPreviousCategory()
  local index = ADCUI:getCurrentSceneIndex()
  
  -- isSceneHidden won't work if all buttons are hidden due to a full screen scene
  -- if this is the case just assume the next scene is available
  if ADCUI:isSceneHidden(index) then
    index = index - 1
  else
    while (index > 1) do
      index = index - 1
      
      if not ADCUI:isSceneHidden(index) then
        break
      end
    end
  end
  
  -- special case handling: don't show for crown store because it disables our buttons
  if (index == MAIN_MENU_KEYBOARD.sceneGroupInfo.marketSceneGroup.category) then
    return
  end
  
  if (index > 0) then
    MAIN_MENU_KEYBOARD:ShowCategory(index)
  end
end

function ADCUI:showNextCategory()
  local index = ADCUI:getCurrentSceneIndex()
  local lastIndex = ADCUI:getLastSceneIndex()
  
  -- isSceneHidden won't work if all buttons are hidden due to a full screen scene
  -- if this is the case just assume the next scene is available
  if ADCUI:isSceneHidden(index) then
    index = index + 1
  else
    while (index < lastIndex) do
      index = index + 1
      
      if not ADCUI:isSceneHidden(index) then
        break
      end
    end
  end  
  
  if (index < lastIndex + 1) then
    MAIN_MENU_KEYBOARD:ShowCategory(index)
  end
end

-- [Event Handler]

local keybindButtonGroupDescriptor = {
  alignment = KEYBIND_STRIP_ALIGN_LEFT,
  
  -- display-only button for category changes
  {
    name = "Change Category",
    keybind = "GAMEPAD_ACTION_BUTTON_8",  -- doesn't actually do anything because it's not defined in keybindstrip's xml
    callback = function() return  end,     -- never gets called    
    visible = function() 
      return ADCUI:shouldShowInCurrentScene() 
    end,
    modByADCUI = true,                    -- keeps our own hooks from processing this descriptor
  },
  
  -- hidden button for previous category
  {
    name = "Previous Category",
    keybind = "UI_SHORTCUT_LEFT_SHOULDER",
    callback = function()
        ADCUI:showPreviousCategory() 
      end,
    ethereal = true,
    modByADCUI = true,
  },
  
  -- hidden button for next category
  {
    name = "Next Category",
    keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
    callback = function()
        ADCUI:showNextCategory()
      end,
    ethereal = true,
    modByADCUI = true,
  },    
  
}

-- handle the scene state changed event to inject our own buttons to the main menu strip
local function onSceneStateChanged(scene, oldState, newState)
  -- see if current scene is on the main menu strip
  if not ADCUI:originalIsInGamepadPreferredMode() or not scene or 
    (newState == SCENE_SHOWN) or (newState == SCENE_HIDDEN) then
    return
  end
  
  local sceneInfo = MAIN_MENU_KEYBOARD.sceneInfo[scene:GetName()]
  if not sceneInfo then
    return
  end
    
  if (newState == SCENE_SHOWING) then
    KEYBIND_STRIP:AddKeybindButtonGroup(keybindButtonGroupDescriptor)
  elseif (newState == SCENE_HIDING) then
    KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindButtonGroupDescriptor)
  end
end


SCENE_MANAGER:RegisterCallback("SceneStateChanged", onSceneStateChanged)