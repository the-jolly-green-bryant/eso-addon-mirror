windexAddon.buildMenuOptions("Experience Bar", "experienceBar", "baseInterface")

function windexAddon.pluginLoadFunctions.experienceBar()
  windexAddon.fragmentHandler(windexAddonDB.isDisabled and windexAddonDB.experienceBar, HUD_SCENE,    PLAYER_PROGRESS_BAR_FRAGMENT)
  windexAddon.fragmentHandler(windexAddonDB.isDisabled and windexAddonDB.experienceBar, HUD_SCENE,    PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
  windexAddon.fragmentHandler(windexAddonDB.isDisabled and windexAddonDB.experienceBar, HUD_UI_SCENE, PLAYER_PROGRESS_BAR_FRAGMENT)
  windexAddon.fragmentHandler(windexAddonDB.isDisabled and windexAddonDB.experienceBar, HUD_UI_SCENE, PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
end

windexAddon.pluginToggleFunctions.experienceBar = windexAddon.pluginLoadFunctions.experienceBar