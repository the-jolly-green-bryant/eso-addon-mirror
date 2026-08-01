-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
SwitchInputMode = {}
 
SwitchInputMode.name = "SwitchInputMode"

-- Next we create a function that will initialize our addon
function SwitchInputMode:Initialize()
 ZO_CreateStringId("SI_BINDING_NAME_CHANGE_INPUT", "Input Change")
end

function SwitchInputMode.OnAddOnLoaded(event, addonName)
  if addonName == SwitchInputMode.name then
    SwitchInputMode:Initialize()
  end
  EVENT_MANAGER:UnregisterForEvent(SwitchInputMode.AddonName, EVENT_ADD_ON_LOADED)
end
	 
function SwitchInputMode.InputChanged()

GamepadPreferredMode = IsInGamepadPreferredMode()

  if GamepadPreferredMode == true then
  Options_Gamepad_PreferredCheckbox:toggleFunction()
  d("Controller Mode Disabled")
  
  elseif GamepadPreferredMode == false  then
  Options_Gamepad_PreferredCheckbox:toggleFunction(true)
  d("Controller Mode Enabled")
  end
end
 
-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(SwitchInputMode.name, EVENT_ADD_ON_LOADED, SwitchInputMode.OnAddOnLoaded)