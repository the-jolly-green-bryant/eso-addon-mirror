local LRM = LibRadialMenu
local ADDON_ID = "ConsoleHideUI"

EVENT_MANAGER:RegisterForEvent(ADDON_ID, EVENT_PLAYER_ACTIVATED, function()
	EVENT_MANAGER:UnregisterForEvent(ADDON_ID, EVENT_PLAYER_ACTIVATED)

	local isActive = false

	local hideUi = function()
		if not isActive then
			isActive = true
			SetFloatingMarkerGlobalAlpha(0)
			ToggleShowIngameGui()
		end
	end

	LRM:RegisterAddon(ADDON_ID, "Console Hide UI")
	LRM:RegisterEntry(ADDON_ID, "Hide UI", "HIDE_UI", "/esoui/art/icons/gp_outfits_hide.dds", function()
		ZO_RadialMenu.ForceActiveMenuClosed()
		INTERACTIVE_WHEEL_MANAGER:CancelCurrentInteraction()
		zo_callLater(hideUi, 500)
	end, "Hides the UI")

	SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", function(_, newState)
		if newState == SCENE_HIDING and isActive then
			isActive = false
			SetFloatingMarkerGlobalAlpha(1)
			ToggleShowIngameGui()
		end
	end)
end)
