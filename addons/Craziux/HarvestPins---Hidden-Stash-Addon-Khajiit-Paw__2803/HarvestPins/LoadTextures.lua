--[[
RedirectTexture("old texture path", "new texture path")
This instructs the game to replace the old texture by the new one.
Note: If you disable your addon ingame, then the new textures will still be used until you restart the game.
Only after restarting the game will the old textures be visible again.
--]]

EVENT_MANAGER:RegisterForEvent("HarvestPins", EVENT_ADD_ON_LOADED, function()

	RedirectTexture("HarvestMap/Textures/worldMarker.dds", "HarvestPins/Textures/worldMarker.dds")
	RedirectTexture("HarvestMap/Textures/Map/chest.dds", "HarvestPins/Textures/Map/chest.dds")
	RedirectTexture("HarvestMap/Textures/Map/clam.dds", "HarvestPins/Textures/Map/clam.dds")
	RedirectTexture("HarvestMap/Textures/Map/clothing.dds", "HarvestPins/Textures/Map/clothing.dds")
	RedirectTexture("HarvestMap/Textures/Map/enchanting.dds", "HarvestPins/Textures/Map/enchanting.dds")
	RedirectTexture("HarvestMap/Textures/Map/fish.dds", "HarvestPins/Textures/Map/fish.dds")
	RedirectTexture("HarvestMap/Textures/Map/flower.dds", "HarvestPins/Textures/Map/flower.dds")
	RedirectTexture("HarvestMap/Textures/Map/heavysack.dds", "HarvestPins/Textures/Map/heavysack.dds")
	RedirectTexture("HarvestMap/Textures/Map/mining.dds", "HarvestPins/Textures/Map/mining.dds")
	RedirectTexture("HarvestMap/Textures/Map/mushroom.dds", "HarvestPins/Textures/Map/mushroom.dds")
	RedirectTexture("HarvestMap/Textures/Map/solvent.dds", "HarvestPins/Textures/Map/solvent.dds")
	RedirectTexture("HarvestMap/Textures/Map/stash.dds", "HarvestPins/Textures/Map/stash.dds")
	RedirectTexture("HarvestMap/Textures/Map/trove.dds", "HarvestPins/Textures/Map/trove.dds")
	RedirectTexture("HarvestMap/Textures/Map/waterplant.dds", "HarvestPins/Textures/Map/waterplant.dds")
	RedirectTexture("HarvestMap/Textures/Map/wood.dds", "HarvestPins/Textures/Map/wood.dds")
        RedirectTexture("HarvestMap/Textures/Map/justice.dds", "HarvestPins/Textures/Map/justice.dds")

end)