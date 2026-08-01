-- Advanced Disable Controller UI
-- Author: Lionas, Setsu

if not ADCUI.isDefined then return end


-- Adjust Compass
function ADCUI:adjustCompass()

--d("adjustCompass")
  local topLayer = -1
  local settings = ADCUI:getSettings()

  -- unlock
  ZO_CompassFrame:SetMovable(true)
  ZO_CompassFrame:SetMouseEnabled(true)

  ZO_CompassFrame:ClearAnchors()

  -- redraw compass
  ZO_CompassFrame:SetAnchor(settings.point, GuiRoot, nil, settings.anchorOffsetX, settings.anchorOffsetY) -- load saved compass position
  ZO_CompassFrame:SetClampedToScreen(false) -- prevent draging off screen
  ZO_CompassFrame:SetDrawLayer(topLayer)

  -- lock/unlock compass
  if(settings.lockEnabled) then
    -- lock
    ZO_CompassFrame:SetMovable(false)
    ZO_CompassFrame:SetMouseEnabled(false)
  else
    -- unlock
    ZO_CompassFrame:SetMovable(true)
    ZO_CompassFrame:SetMouseEnabled(true)
  end
end

-- frame update
function ADCUI:frameUpdate()

--d("frameUpdate")
  local widthDimension = 10
  local settings = ADCUI:getSettings()

  ZO_Compass:SetScale(settings.scale)
  ZO_Compass:SetDimensions(settings.width, settings.height)
  ZO_CompassCenterOverPinLabel:SetScale(settings.pinLabelScale)
  ZO_CompassFrameLeft:SetDimensions(widthDimension, settings.height)
  ZO_CompassFrameRight:SetDimensions(widthDimension, settings.height)
  ZO_CompassFrame:SetDimensions(settings.width, settings.height)
end

-- update compass
function onUpdateCompass()

--d("onUpdateCompass")

  local anchor, point, rTo, rPoint, offsetx, offsety = ZO_CompassFrame:GetAnchor() 
  local settings = ADCUI:getSettings()
    
  if((offsetx ~= settings.anchorOffsetX) or (offsety ~= settings.anchorOffsetY)) then
    ADCUI:frameUpdate()
    ADCUI:adjustCompass()
  end
end


EVENT_MANAGER:RegisterForUpdate(ADCUI.const.ADDON_NAME, ADCUI.const.UPDATE_INTERVAL_MSEC, onUpdateCompass)