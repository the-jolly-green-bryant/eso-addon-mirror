windexAddon.buildMenuOptions("Horse Timers", "horseTimers", "baseAddons")

function windexAddon.pluginLoadFunctions.horseTimers()
  if not HorseTimersTop then return end

  HorseTimersVars.Default[GetDisplayName()]["$AccountWide"].ishidden = not windexAddonDB.isDisabled and windexAddonDB.horseTimers

  if HorseTimersTop    then HorseTimersTop:SetHidden(not windexAddonDB.isDisabled and windexAddonDB.horseTimers)    end
  if HorseTimersExpand then HorseTimersExpand:SetHidden(not windexAddonDB.isDisabled and windexAddonDB.horseTimers) end
  if HorseTimersClose  then HorseTimersClose:SetHidden(true)                                                        end
end

windexAddon.pluginToggleFunctions.horseTimers = windexAddon.pluginLoadFunctions.horseTimers