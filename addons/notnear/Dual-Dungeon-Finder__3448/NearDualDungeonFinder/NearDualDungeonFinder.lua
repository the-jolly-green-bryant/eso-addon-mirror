local addon = {
	name = 'NearDualDungeonFinder',
	title = 'Dual Dungeon Finder',
	version= '1.0.0',
	defaults = {
		dDebug = false,
	},
	LSC = LibSlashCommander,
}
NEAR_DDF = addon

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Gamepad/Keyboard mode cycle
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

function OnGamepadModeChanged(eventCode, gamepadPreferred)
	if (addon.ASV.dDebug) then
		if IsInGamepadPreferredMode() then d(addon.utils.color.white .. 'DDF: |r' .. 'Toggle Gamepad mode')
		else d(addon.utils.color.white .. 'DDF: |r' .. 'Toggle Keyboard mode') end
	end
end

-- Cycle Gamepad Preferred Mode
function addon.cycleGPM()
	--[[ Debug ]] if (addon.ASV.dDebug) then d(addon.utils.color.white .. 'DDF: |r' .. 'cycleGPM') end

	if IsGamepadUISupported() and IsKeyboardUISupported() then
		local mode = IsInGamepadPreferredMode() and INPUT_PREFERRED_MODE_ALWAYS_KEYBOARD or INPUT_PREFERRED_MODE_ALWAYS_GAMEPAD
		SetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_INPUT_PREFERRED_MODE, mode)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Addon loading
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function OnAddonLoaded(event, name)
	if name ~= addon.name then
		return
	end
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

	addon.ASV = ZO_SavedVars:NewAccountWide('NearDualDungeonFinder_Data', 1, nil, addon.defaults)

	addon:activateSlashCommands()
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, OnGamepadModeChanged)
