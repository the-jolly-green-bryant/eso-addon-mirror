local NeltharionsCamControl = NeltharionsCamControl





function NeltharionsCamControl.OnAddOnLoaded(eventCode, addOnName)
  if(addOnName == NeltharionsCamControl.addOnName) then
    NeltharionsCamControl:Initialize()
    NeltharionsCamControl:CreateSettingsMenu()
  end
end


function NeltharionsCamControl:Initialize()

  NeltharionsCamControl.savedVariables = LibSavedVars
    :NewAccountWide("NeltharionsCamC_Account", NeltharionsCamControl.DEFAULTS)
    :AddCharacterSettingsToggle("NeltharionsCamC_Character")



  EVENT_MANAGER:RegisterForEvent(NeltharionsCamControl.addOnName, EVENT_PLAYER_ACTIVATED, NeltharionsCamControl.OnPlayerActivated)
  EVENT_MANAGER:UnregisterForEvent(NeltharionsCamControl.addonName, EVENT_ADD_ON_LOADED)

end

function NeltharionsCamControl.SaveQS(slotNumber)
   local slot = tostring(slotNumber)

   if not NeltharionsCamControl.savedVariables.QuickSlot then
     NeltharionsCamControl.savedVariables.QuickSlot = {}
   end
	if not NeltharionsCamControl.savedVariables.QuickSlot[slot] then
    NeltharionsCamControl.savedVariables.QuickSlot[slot] = {}
  end

   NeltharionsCamControl.savedVariables.QuickSlot[slot].Horizontal = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_POSITION_MULTIPLIER)
   NeltharionsCamControl.savedVariables.QuickSlot[slot].HorizontalOffset = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET)
   NeltharionsCamControl.savedVariables.QuickSlot[slot].Vertical = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET)
   NeltharionsCamControl.savedVariables.QuickSlot[slot].ZoomValue = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE)
   NeltharionsCamControl.savedVariables.QuickSlot[slot].Fieldview = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW)

   local ch_output = GetString(CONSOLE_OUT_SAVE_SL)..tostring(slotNumber)
   d(ch_output)

end

function NeltharionsCamControl.LoadQS(slotNumber)
   local slot = tostring(slotNumber)

   if not NeltharionsCamControl.savedVariables.QuickSlot then
     NeltharionsCamControl.savedVariables.QuickSlot = {}
   end
	if not NeltharionsCamControl.savedVariables.QuickSlot[slot] then
    NeltharionsCamControl.savedVariables.QuickSlot[slot] = {}
  end

   SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_POSITION_MULTIPLIER, NeltharionsCamControl.savedVariables.QuickSlot[slot].Horizontal)
   SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET, NeltharionsCamControl.savedVariables.QuickSlot[slot].HorizontalOffset)
   SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET, NeltharionsCamControl.savedVariables.QuickSlot[slot].Vertical)
   SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, NeltharionsCamControl.savedVariables.QuickSlot[slot].ZoomValue)
   SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW, NeltharionsCamControl.savedVariables.QuickSlot[slot].Fieldview)

   local ch_output = GetString(CONSOLE_OUT_LOAD_SL)..tostring(slotNumber)
   d(ch_output)
   --d("Load Data from Slot: "..tostring(slotNumber))
end



-- Event handler function for EVENT_PLAYER_ACTIVATED
function NeltharionsCamControl.OnPlayerActivated(event)
    SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, NeltharionsCamControl.savedVariables.Zoom)
end

function NeltharionsCamControl.toggleZoom()
  if NeltharionsCamControl.savedVariables.zoomEnabled == true then
    NeltharionsCamControl.savedVariables.zoomEnabled = false
    d("Zoom enabled")
  else
    NeltharionsCamControl.savedVariables.zoomEnabled = true
    d("Zoom disabled")
  end
end





EVENT_MANAGER:RegisterForEvent(NeltharionsCamControl.addOnName, EVENT_ADD_ON_LOADED,NeltharionsCamControl.OnAddOnLoaded)
