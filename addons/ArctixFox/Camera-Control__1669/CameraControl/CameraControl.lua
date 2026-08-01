CameraControl = {}

local CC = CameraControl

-- default saved variables
local CameraControlDefaults = {
 
   -- I'm sure there's a better way to do this, but it will suffice
   QuickSlot = {},
}

-- saved variables 
cameraControl_savedVars = {}

-- local variables
local TimeDelay = 50
local IncAmount = 0.1
local VertTimeDelay = 30
local VertIncAmount = 0.03
local HorIncKeyDown = false
local HorDecKeyDown = false
local VerIncKeyDown = false
local VerDecKeyDown = false
local HorOffsetIncKeyDown = false
local HorOffsetDecKeyDown = false

function CC.StopHorizontalInc()
   HorIncKeyDown = false
end

function CC.StartHorizontalInc()
   HorIncKeyDown = true
   zo_callLater(function() CC.HorizontalInc() end, TimeDelay)
end

function CC.StopHorizontalDec()
   HorDecKeyDown = false
end

function CC.StartHorizontalDec()
   HorDecKeyDown = true
   zo_callLater(function() CC.HorizontalDec() end, TimeDelay)
end

function CC.StopHorizontalOffsetInc()
   HorOffsetIncKeyDown = false
end

function CC.StartHorizontalOffsetInc()
   HorOffsetIncKeyDown = true
   zo_callLater(function() CC.HorizontalOffsetInc() end, TimeDelay)
end

function CC.StopHorizontalOffsetDec()
   HorOffsetDecKeyDown = false
end

function CC.StartHorizontalOffsetDec()
   HorOffsetDecKeyDown = true
   zo_callLater(function() CC.HorizontalOffsetDec() end, TimeDelay)
end

function CC.StopVerticalInc()
   VerIncKeyDown = false
end

function CC.StartVerticalInc()
   VerIncKeyDown = true
   zo_callLater(function() CC.VerticalInc() end, VertTimeDelay)
end

function CC.StopVerticalDec()
   VerDecKeyDown = false
end

function CC.StartVerticalDec()
   VerDecKeyDown = true
   zo_callLater(function() CC.VerticalDec() end, VertTimeDelay)
end

function CC.HorizontalInc()
   local curValue = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_POSITION_MULTIPLIER))

   -- only valid between -1 and +1
   -- inexact due to floating point deltas, but close enough for government work
   if curValue >= 1 then 
      return
   end

   curValue = curValue + IncAmount

   SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_POSITION_MULTIPLIER, curValue)

   if HorIncKeyDown == false then
      return
   end

   zo_callLater(function() CC.HorizontalInc() end, TimeDelay)
end

function CC.HorizontalDec()
   local curValue = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_POSITION_MULTIPLIER))
   
   -- only valid between -1 and +1
   -- inexact due to floating point deltas, but close enough for government work
   if curValue <= -1 then
      return
   end

   curValue = curValue - IncAmount

   SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_POSITION_MULTIPLIER, curValue)

   if HorDecKeyDown == false then
      return
   end

   zo_callLater(function() CC.HorizontalDec() end, TimeDelay)
end

function CC.HorizontalOffsetInc()
   local curValue = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET))

   -- only valid between -1 and +1
   -- inexact due to floating point deltas, but close enough for government work
   if curValue >= 1 then 
      return
   end

   curValue = curValue + IncAmount

   SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET, curValue)

   if HorOffsetIncKeyDown == false then
      return
   end

   zo_callLater(function() CC.HorizontalOffsetInc() end, TimeDelay)
end

function CC.HorizontalOffsetDec()
   local curValue = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET))
   
   -- only valid between -1 and +1
   -- inexact due to floating point deltas, but close enough for government work
   if curValue <= -1 then
      return
   end

   curValue = curValue - IncAmount

   SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET, curValue)

   if HorOffsetDecKeyDown == false then
      return
   end

   zo_callLater(function() CC.HorizontalOffsetDec() end, TimeDelay)
end

function CC.VerticalInc()
   local curValue = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET))

   -- only valid between -1 and +1
   -- inexact due to floating point deltas, but close enough for government work
   if curValue >= 0.6 then 
      return
   end

   curValue = curValue + VertIncAmount

   SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET, curValue)

   if VerIncKeyDown == false then
      return
   end

   zo_callLater(function() CC.VerticalInc() end, VertTimeDelay)
end

function CC.VerticalDec()
   local curValue = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET))
   
   -- only valid between -.6 and +.6
   -- inexact due to floating point deltas, but close enough for government work
   if curValue <= -0.6 then
      return
   end

   curValue = curValue - VertIncAmount

   SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET, curValue)
   if VerDecKeyDown == false then
      return
   end

   zo_callLater(function() CC.VerticalDec() end, VertTimeDelay)
end

function CC.ReCenter()
   SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET, 0)
   SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET, 0)
   SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_POSITION_MULTIPLIER, 0)     
end

function CC.SaveQS(slotNumber)
   local slot = tostring(slotNumber)

   if not cameraControl_savedVars.QuickSlot then cameraControl_savedVars.QuickSlot = {} end
	if not cameraControl_savedVars.QuickSlot[slot] then cameraControl_savedVars.QuickSlot[slot] = {} end

   cameraControl_savedVars.QuickSlot[slot].Horizontal = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_POSITION_MULTIPLIER)
   cameraControl_savedVars.QuickSlot[slot].HorizontalOffset = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET)
   cameraControl_savedVars.QuickSlot[slot].Vertical = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET)
   cameraControl_savedVars.QuickSlot[slot].ZoomValue = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE)

   
end

function CC.LoadQS(slotNumber)
   local slot = tostring(slotNumber)

   if not cameraControl_savedVars.QuickSlot then cameraControl_savedVars.QuickSlot = {} end
	if not cameraControl_savedVars.QuickSlot[slot] then cameraControl_savedVars.QuickSlot[slot] = {} end

   SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_POSITION_MULTIPLIER, cameraControl_savedVars.QuickSlot[slot].Horizontal)
   SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET, cameraControl_savedVars.QuickSlot[slot].HorizontalOffset)
   SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET, cameraControl_savedVars.QuickSlot[slot].Vertical)
   SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, cameraControl_savedVars.QuickSlot[slot].ZoomValue)

end

local function OnAddonLoaded(eventCode, addonName)
   if addonName ~= CC.Name then 
      return 
   end

   EVENT_MANAGER:UnregisterForEvent(CC.Name, EVENT_ADD_ON_LOADED)

   -- Fetch the saved variables
   cameraControl_savedVars = ZO_SavedVars:NewAccountWide("cameraControl_savedVars", 1, nil, CameraControlDefaults)
end

-- Hook initialization onto the ADD_ON_LOADED event
EVENT_MANAGER:RegisterForEvent(CC.Name, EVENT_ADD_ON_LOADED, OnAddonLoaded)


