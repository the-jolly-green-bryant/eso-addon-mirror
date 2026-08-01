------------------------------------------------
-- English localization
------------------------------------------------

local simpleChat = 'Simple Chat Position'
local strings = {
	SI_IJA_DYNAMIC_CHAT					= 'Dynamic Chat Position',
	SI_IJA_SIMPLE_CHAT					= simpleChat,
	SI_IJA_DYNAMIC_CHAT_TOOLTIP			= string.format('Disabled: does not move the "Keyboard Chat" on scene change.\nCustom: the "Keyboard Chat" window will reposition dynamically based on what Gamepad UI is displayed.\n%s: the "Keyboard Chat" window will not follow displayed UI elements. Instead, it will move to far right at bottom or above the keybind strip.', simpleChat),

	SI_IJA_LOOTHISTORY_MOVE				= 'Use custom Keyboard Loot History',
	SI_IJA_LOOTHISTORY_MOVE_TOOLTIP 	= 'Disabled: uses the "Gamepad Loothistory" with selectable fonts.\nCustom:uses the "Keyboard LootHistory clone" with selectable fonts.\nStandard: "Keyboard LootHistory" with no modifications.',

	SI_IJA_LOOTHISTORY_FONTS_OVERLAY	= 'Set Icon Overlay Text Font',
	SI_IJA_LOOTHISTORY_FONTS_LABEL		= 'Loot Text Font',

	SI_IJA_HUDMETERS_MOVE				= 'Move HUD Meters',
	SI_IJA_HUDMETERS_MOVE_TOOLTIP		= 'Enabled: will use the keyboard Telvar, Infamy, and Daedric energy meters',
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
