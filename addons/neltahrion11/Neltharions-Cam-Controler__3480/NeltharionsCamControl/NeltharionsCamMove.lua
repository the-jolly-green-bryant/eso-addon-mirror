local NeltharionsCamControl = NeltharionsCamControl

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
local FieldViewIncKeyDown = false
local FieldViewDecKeyDown = false
local FieldviewIncAmount = 1

function NeltharionsCamControl.StopHorizontalInc()
   HorIncKeyDown = false
end

function NeltharionsCamControl.StartHorizontalInc()
   HorIncKeyDown = true
   zo_callLater(function() NeltharionsCamControl.HorizontalInc() end, TimeDelay)
end

function NeltharionsCamControl.StopHorizontalDec()
   HorDecKeyDown = false
end

function NeltharionsCamControl.StartHorizontalDec()
   HorDecKeyDown = true
   zo_callLater(function() NeltharionsCamControl.HorizontalDec() end, TimeDelay)
end

function NeltharionsCamControl.StopHorizontalOffsetInc()
   HorOffsetIncKeyDown = false
end

function NeltharionsCamControl.StartHorizontalOffsetInc()
   HorOffsetIncKeyDown = true
   zo_callLater(function() NeltharionsCamControl.HorizontalOffsetInc() end, TimeDelay)
end

function NeltharionsCamControl.StopHorizontalOffsetDec()
   HorOffsetDecKeyDown = false
end

function NeltharionsCamControl.StartHorizontalOffsetDec()
   HorOffsetDecKeyDown = true
   zo_callLater(function() NeltharionsCamControl.HorizontalOffsetDec() end, TimeDelay)
end

function NeltharionsCamControl.StopVerticalInc()
   VerIncKeyDown = false
end

function NeltharionsCamControl.StartVerticalInc()
   VerIncKeyDown = true
   zo_callLater(function() NeltharionsCamControl.VerticalInc() end, VertTimeDelay)
end

function NeltharionsCamControl.StopVerticalDec()
   VerDecKeyDown = false
end

function NeltharionsCamControl.StartVerticalDec()
   VerDecKeyDown = true
   zo_callLater(function() NeltharionsCamControl.VerticalDec() end, VertTimeDelay)
end

function NeltharionsCamControl.StopFieldviewInc()
  FieldViewIncKeyDown = false
end

function NeltharionsCamControl.StartFieldviewInc()
  FieldViewIncKeyDown = true
  zo_callLater(function() NeltharionsCamControl.FieldViewInc() end, TimeDelay)
end

function NeltharionsCamControl.StopFieldviewDec()
  FieldViewDecKeyDown = false
end

function NeltharionsCamControl.StartFieldviewDec()
  FieldViewDecKeyDown = true
  zo_callLater(function() NeltharionsCamControl.FieldViewDec() end, TimeDelay)
end


function NeltharionsCamControl.HorizontalInc()
   local curValue = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_POSITION_MULTIPLIER))
   --d("HorizInc: "..GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_POSITION_MULTIPLIER))

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

   zo_callLater(function() NeltharionsCamControl.HorizontalInc() end, TimeDelay)
end

function NeltharionsCamControl.HorizontalDec()
   local curValue = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_POSITION_MULTIPLIER))
   --d("HorizDec: "..GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_POSITION_MULTIPLIER))

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

   zo_callLater(function() NeltharionsCamControl.HorizontalDec() end, TimeDelay)
end

function NeltharionsCamControl.HorizontalOffsetInc()
   local curValue = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET))
   --d("HorizOffInc: "..GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET))

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

   zo_callLater(function() NeltharionsCamControl.HorizontalOffsetInc() end, TimeDelay)
end

function NeltharionsCamControl.HorizontalOffsetDec()
   local curValue = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET))
   --d("HorizOffDec: "..GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET))

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

   zo_callLater(function() NeltharionsCamControl.HorizontalOffsetDec() end, TimeDelay)
end

function NeltharionsCamControl.VerticalInc()
   local curValue = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET))
   --d("VertInc: "..GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET))

   -- only valid between -1 and +1
   -- inexact due to floating point deltas, but close enough for government work
   if curValue >= 0.5 then
      return
   end

   curValue = curValue + VertIncAmount

   SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET, curValue)

   if VerIncKeyDown == false then
      return
   end

   zo_callLater(function() NeltharionsCamControl.VerticalInc() end, VertTimeDelay)
end

function NeltharionsCamControl.VerticalDec()
   local curValue = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET))
   --d("VertDec: "..GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET))

   -- only valid between -.6 and +.6
   -- inexact due to floating point deltas, but close enough for government work
   if curValue <= -0.3 then
      return
   end

   curValue = curValue - VertIncAmount

   SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET, curValue)
   if VerDecKeyDown == false then
      return
   end

   zo_callLater(function() NeltharionsCamControl.VerticalDec() end, VertTimeDelay)
end

function NeltharionsCamControl.FieldViewInc()
  local curValue = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW))
  --d("FieldviewInc: "..GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW))
  -- only valid between -1 and +1
  -- inexact due to floating point deltas, but close enough for government work
  if curValue >= 65 then
     return
  end

  curValue = curValue + FieldviewIncAmount

  SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW, curValue)

  if FieldViewIncKeyDown == false then
     return
  end

  zo_callLater(function() NeltharionsCamControl.FieldViewInc() end, TimeDelay)
end

function NeltharionsCamControl.FieldViewDec()
  local curValue = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW))
  --d("Fieldviewdec: "..GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW))
  -- only valid between -1 and +1
  -- inexact due to floating point deltas, but close enough for government work
  if curValue <= 35 then
     return
  end

  curValue = curValue - FieldviewIncAmount

  SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW, curValue)

  if FieldViewDecKeyDown == false then
     return
  end

  zo_callLater(function() NeltharionsCamControl.FieldViewDec() end, TimeDelay)
end


function NeltharionsCamControl.ReCenter()
   SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET, 0)
   SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET, 0)
   SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_POSITION_MULTIPLIER, 0)
end
