windexAddon.buildMenuOptions("Compass", "compass", "baseInterface")

function windexAddon.pluginLoadFunctions.compass()
  local state = not windexAddonDB.isDisabled and windexAddonDB.compass

  if ZO_CompassContainer   then ZO_CompassContainer:SetHidden(state)   end
  if ZO_CompassFrameCenter then ZO_CompassFrameCenter:SetHidden(state) end
  if ZO_CompassFrameLeft   then ZO_CompassFrameLeft:SetHidden(state)   end
  if ZO_CompassFrameRight  then ZO_CompassFrameRight:SetHidden(state)  end
end

windexAddon.pluginToggleFunctions.compass = windexAddon.pluginLoadFunctions.compass
windexAddon.pluginPopFunctions.compass    = windexAddon.pluginLoadFunctions.compass