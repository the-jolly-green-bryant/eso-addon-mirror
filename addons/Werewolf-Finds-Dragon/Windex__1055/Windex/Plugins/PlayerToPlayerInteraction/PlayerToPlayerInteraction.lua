windexAddon.buildMenuOptions("Player-to-Player Interaction", "playerToPlayerInteraction", "baseInterface")

windexAddon.playerToPlayerInteractionDefaultAlpha = ZO_PlayerToPlayerAreaPromptContainer:GetAlpha()

function windexAddon.pluginLoadFunctions.playerToPlayerInteraction()
  if ZO_PlayerToPlayerAreaPromptContainer then ZO_PlayerToPlayerAreaPromptContainer:SetAlpha((not windexAddonDB.isDisabled and windexAddonDB.playerToPlayerInteraction) and 0 or windexAddon.playerToPlayerInteractionDefaultAlpha) end
end

windexAddon.pluginToggleFunctions.playerToPlayerInteraction = windexAddon.pluginLoadFunctions.playerToPlayerInteraction