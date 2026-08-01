--	Bindings
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_SWAP",			"Swap Shoulder")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_SWAP_X",		"Swap Shoulder (Fast)")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_SWAPCENTER",	"Swap/Center")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_SWAPCENTER_X",	"Swap/Center (Fast)")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_CENTER",		"Center Camera")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_CENTER_X",		"Center Camera (Fast)")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_ALT_ALL",		"Alt. camera values")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_ALT_DIST",		"Alt. distance")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_ALT_FOV",		"Alt. field of view")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_SIEGE",		"Toggle Siege Camera")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_STATIC0",		"Switch to preferred camera")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_STATIC1",		"Switch to static camera #1")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_STATIC2",		"Switch to static camera #2")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_STATIC3",		"Switch to static camera #3")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_TOGGLE_CHAT",	"ON/OFF - Chat Camera")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_TOGGLE_CRAFT",	"ON/OFF - Craft Camera")
ZO_CreateStringId("SI_BINDING_NAME_NTCAM_TOGGLE_LOCKP",	"ON/OFF - Lockpicking Cam.")


--	Options
NTCam_Texts = {
	cat0 = {
		title	= "CROSS-CHARACTERS SETTINGS",
	},
	cat1 = {
		title	= "PREFERRED CAMERA",
		desc1	= "These settings override the regular camera settings.",
		opt1	= "Distance from character (0 for 1st person)",
    	opt1b	= "Field of view",
		opt2	= "Shoulder side",
		choices = {
			"Center",
			"Left",
			"Right",
		},
		opt3	= "Horizontal position",
		opt3b	= "Horizontal offset (static)",
		warn3b	= "The value of this setting won't be altered by interactions/events.",
		opt4	= "Vertical position",
		opt5	= "Vertical offset (when toggling to center)",
		warn5	= "This setting is only used when you are toggling to center using the available keybind.\nIf you only use a centered camera, both “Vertical …” settings should have the same value.",
		--
		desc11	= "After an “interaction” or an “event”, the previous camera parameters will be restored. Except if you choose to restore your preferred camera:",
		opt11	= "Restore preferred camera instead of previous",
		--
	},
	cat2 = {
		title0	= "ALTERNATIVE CAMERAS",
		desc0	= "These can be toggled only by keybindings.",
		title1	= "ALTERNATIVE VALUES",
		desc1	= "These alternative values can replace values of the preferred camera.",
		title2	= "STATIC CAMERAS",
		desc2	= "You can switch to these cameras only with keybindings.\nThese cameras will NOT be altered by interactions or events,\nand are meant for temporary use only.", -- \nAlso, note that these cameras have an extended horizontal position range.",
		opt0	= "Output to chat when switching camera",
		msg0	= "Switching to Static Camera #",
		menuX	= "Static camera #",
		opt1	= "Distance",
		opt2	= "Field of view",
		opt3	= "Horizontal position",
		opt3b	= "Horizontal offset",
		opt4	= "Vertical offset",
	},
	menuX = {
		opt0	= "Prevent default camera change",
		warn1	= "You need to use “Prevent camera change on interactions” in order to make it work.",
		opt1	= "Preset",
		choices = {
			"Do nothing",
			"Center in 3rd person",
			"Switch to 1st person",
			"Switch to 3rd person",
			"Zoom-out",
			"Focus",
			"Custom",
		},
		opt2	= "Change distance …",
		opt2b	= "Change field of view …",
		opt3	= "Change horizontal position …",
		opt4	= "Change vertical position …",
		opt5	= "Delay to restore camera (x 100ms)",
		to		= "… to:",
		opt10	= "No other change while ", -- .. Menu title
	},
	cat3 = {
		title	= "INTERACTION CAMERAS", -- CHANGES",
		desc1	= "Manage how interactions alter the preferred camera.",
		menu1 = {
			title	= "Chatting",
		},
		menu2 = {
			title	= "Crafting station",
		},
		menu3 = {
			title	= "Outfit station",
		},
		menu4 = {
			title	= "Lockpicking",
		},
	},
	cat4 = {
		title	= "EVENT-DRIVEN CAMERAS", -- CHANGES",
		desc1	= "Manage how events alter the preferred camera.",
		menu0 = {
			title	= "while moving",
			opt1	= "Output speed to chat",
			opt2	= "Move / Sprint threshold",
			desc1	= "When the movement speed is above the threshold (e.g. while sprinting), the below settings can override the above ones.",
		},
		menu1 = {
			title	= "on mount",
		},
		menu2 = {
			title	= "stealthy",
		},
		menu3 = {
			title	= "on draw/sheath weapon",
			desc1	= "The draw/sheath events are triggered only when using the binding.\n(Unfortunatelly, using skills does not trigger the event.)\nThe below option can be used to also trigger the “draw” event when entering combat.",
			opt1	= "Entering combat also triggers “draw”",
		},
		menu4 = {
			title	= "in combat",
			opt1	= "Auto-sheath weapon after combat",
		},
		menu5 = {
			title	= "in werewolf",
			opt1	= "Distance as minimum while in werewolf",
		},
	}
}