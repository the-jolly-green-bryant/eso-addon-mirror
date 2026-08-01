windexAddon.buildMenuOptions("Infamy Meter", "infamyMeter", "baseInterface")

function windexAddon.pluginLoadFunctions.infamyMeter(noToggleCall)
  if windexAddonDB.infamyMeter and not windexAddon.infamyMeterHook then
    windexAddon.infamyMeterHook = ZO_HUDInfamyMeter.SetHidden

    function ZO_HUDInfamyMeter:SetHidden(status)
      status = (GetInfamy() == 0 and true) or (not windexAddonDB.isDisabled and windexAddonDB.infamyMeter) or status

      windexAddon.infamyMeterHook(self, status)
    end

  elseif not windexAddonDB.infamyMeter and windexAddon.infamyMeterHook then
    ZO_HUDInfamyMeter.SetHidden = windexAddon.infamyMeterHook
    windexAddon.infamyMeterHook = nil
  end

  if not noToggleCall then windexAddon.pluginToggleFunctions.infamyMeter() end
end

function windexAddon.pluginToggleFunctions.infamyMeter()
  if windexAddonDB.infamyMeter and not windexAddon.infamyMeterHook then
    windexAddon.pluginLoadFunctions.infamyMeter(true)
  end

  if ZO_HUDInfamyMeter then
    ZO_HUDInfamyMeter:SetHidden()

    if (windexAddonDB.isDisabled or not windexAddonDB.infamyMeter) and ZO_HUDInfamyMeter.Update then
      ZO_HUDInfamyMeter:Update()
    end
  end
end