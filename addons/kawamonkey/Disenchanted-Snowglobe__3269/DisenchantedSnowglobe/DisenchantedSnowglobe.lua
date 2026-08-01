local function IsEnchantedSnowglobe()
	return select(2, GetGameCameraInteractableActionInfo()) == GetCollectibleName(5756)
end

ZO_PreHook(
	RETICLE,
	"TryHandlingInteraction",
	function(_, interactionPossible)
		return interactionPossible and IsEnchantedSnowglobe()
	end
)

local orgStartInteraction = FISHING_MANAGER.StartInteraction

FISHING_MANAGER.StartInteraction = function(...)
	return IsEnchantedSnowglobe() or orgStartInteraction(...)
end