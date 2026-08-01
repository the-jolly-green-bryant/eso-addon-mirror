windexAddon.buildMenuOptions("Quest Tracker", "questTracker", "baseInterface")

function windexAddon.pluginLoadFunctions.questTracker()
  if ZO_FocusedQuestTrackerPanel then ZO_FocusedQuestTrackerPanel:SetHidden(not windexAddonDB.isDisabled and windexAddonDB.questTracker) end
end

windexAddon.pluginToggleFunctions.questTracker = windexAddon.pluginLoadFunctions.questTracker