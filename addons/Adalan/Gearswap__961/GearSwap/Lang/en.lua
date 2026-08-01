---------------------------------------------
-- English localization for GearSwap
---------------------------------------------
-- translated by Adalan@Aruntas


local localization_strings = {
	-- SETTINGS MENU START
	-- options checkboxes
	GEARSWAP_NAME = "GearSwap",
	GEARSWAP_TEXT = "Enable or disable GearSwap",
	SWAPPING_ON_WEAPONSWAP_NAME = "Swap gear on weaponswap",
	SWAPPING_ON_WEAPONSWAP_TEXT = "Enable or disable swapping gearset on weaponswap \n(Gearswap is still possible with keybinds)",	
	CHANGE_COSTUME_NAME = "Change Costume on Weapon Swap",
	CHANGE_COSTUME_TEXT = "Enable or disable costume swapping on the weaponswap event",
	UNEQUIP_SINGLE_ITEMS_NAME = "Unequip single items",
	UNEQUIP_SINGLE_ITEMS_TEXT = "Enable or disable the possibility to save unequipped items and keep the status on swapping.\n\n(Except weapons and costume)",
	SHOW_MESSAGEBOX_NAME = "Show and move messagebox",
	SHOW_MESSAGEBOX_TEXT = "Turns on/off the message window to keep visible and to move on screen",
	MOUNT_ONOFF_NAME =  "Automatically use the mount set",
	MOUNT_ONOFF_TEXT = "If set, the choosen set will automatically switch to, when you |cF083F1mounted|r and switch back to the last used one, when you are unmounted.\n|cF083F1This do not work when you are in combat !|r",
	
	-- options slider
	SLIDER_ADJUST_MESSAGE_DELAY_NAME = "Adjust message delay",
	SLIDER_ADJUST_MESSAGE_DELAY_TEXT = "Set delay for how long the message on screen should be active\n1000 = one second",
	SLIDER_ADJUST_UNMOUNT_DELAY_NAME = "Unmount-Swap-Timer",
	SLIDER_ADJUST_UNMOUNT_DELAY_TEXT = "Timer until the gearset get swapped on unmounting\n1000 = one second",	
	
	-- options dropdown
	OPTIONS_PRIMARY_GEARSET_NAME = "Primary Gear Set",
	OPTIONS_PRIMARY_GEARSET_TEXT = "Will use this set when you weaponswap to your primary bar.",
	OPTIONS_SECONDARY_GEARSET_NAME = "Secondary Gear Set",
	OPTIONS_SECONDARY_GEARSET_TEXT = "Will use this set when you weaponswap to your secondary bar.",
	OPTIONS_MOUNT_GEARSET_NAME = "Default set for mount",
	OPTIONS_MOUNT_GEARSET_TEXT = "Choose a set you want to have equipped on mount",
	
	
	-- options submenu - announcements
	SUBMENU_ANNOUNCEMENTS_NAME = "Announcements",
	SUBMENU_ANNOUNCEMENTS_TEXT = "Enable/Disable messages",
	SUB_MESSAGE_ONSCREEN_NAME = "Output message on screen",
	SUB_MESSAGE_ONSCREEN_TEXT = "Turns on/off the info on screen when you switch your set",
	SUB_CHAT_MESSAGE_ON_SAVE_NAME = "Output message on saved gear",
	SUB_CHAT_MESSAGE_ON_SAVE_TEXT = "Turns on/off the info on chat when you save a gearset.",
	SUB_CHAT_MESSAGE_SINGLE_ITEMS_NAME = "Output message on single items",
	SUB_CHAT_MESSAGE_SINGLE_ITEMS_TEXT = "Turns on/off the info on chat when you have not a full set equipped, which tells you how many slots unused.\nJust for armour, rings and necklace",
	SUB_CHAT_MESSAGE_AUTO_MOUNT_NAME = "Chatinfo for the mount set",
	SUB_CHAT_MESSAGE_AUTO_MOUNT_TEXT = "Shows, whether an info about the settings should be send out to the chat or not",
	-- SETTINGS MENU END
	
	-- GearSwap_VARS_TEXT
	VAR_PRIMARY_SET_TEXT = "Primary Gear Set",
	VAR_SECONDARY_SET_TEXT = "Secondary Gear Set",
	VAR_ADDITIONAL_SET1 = "Additional Set 1",
	VAR_ADDITIONAL_SET2 = "Additional Set 2",
	
	-- Binding-Names
	BINDING_PRIMARY_GEARSET_TEXT = "Equip Primary Gear Set",
	BINDING_SECONDARY_GEARSET_TEXT = "Equip Secondary Gear Set",
	BINDING_ADDITIONAL1_GEARSET_TEXT = "Equip Additional Gear Set 1",
	BINDING_ADDITIONAL2_GEARSET_TEXT = "Equip Additional Gear Set 2",
	BINDING_GO_NAKED_TEXT = "Go naked",
	BINDING_MOUNT_SWAP_TEXT = "Autoset mount On/Off",
	BINDING_GEARSWAP_ONOFF_TEXT = "GearSwap On/Off",
	BINDING_SWAPPING_ONOFF_TEXT = "Swap on Weaponchange On/Off",		

	-- Misc Text
	MISC_BUTTON_LABEL_SAVE_TEXT = "Save Gear Set",
	MISC_ACTIVE_TEXT = " active",
	MISC_EQUIPPED_TEXT = " equipped",
	MISC_SAVED_TEXT = " saved",
	MISC_UNEQUIPPED_ITEMS_GEARSET_PREFIX_TEXT = "Set ",
	MISC_UNEQUIPPED_ITEMS_TEXT = " - Unequipped items : ",
	MISC_UNDRESSING_ALL_ITEMS_TEXT = "Undressing all items...",
	MISC_MOUNT_SWAP_ON = "Mount autoswap ON",
	MISC_MOUNT_SWAP_OFF = "Mount autoswap OFF",
	MISC_SNEAK_SWAP_ON = "Sneak autoswap ON",
	MISC_GEARSWAP_TOGGLE_ON = "GearSwap ON",
	MISC_GEARSWAP_TOGGLE_OFF = "GearSwap OFF",
	MISC_GEARSET_WEAPONSWAP_ON = "Gearswap with weaponswap ON",
	MISC_GEARSET_WEAPONSWAP_OFF = "Gearswap with weaponswap OFF",	
	MISC_BUTTON_LABEL_UNDRESS_TEXT = "Undress all",		
}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end