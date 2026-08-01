--	Bindings
ZO_CreateStringId("SI_BINDING_NAME_NTLOOT_OVERRIDE_SMART", "Override Smart Stealing")
ZO_CreateStringId("SI_BINDING_NAME_NTLOOT_TOGGLE_AUTOLOOT", "Toggle Auto-loot")


--	Options
NTLnS_Texts = {
	choices = {
		hPosition = {
			"Left",
			"Center",
			"Right",
		},
		vPosition = {
			"Top",
			"Center",
			"Bottom",
		}
	},
	actions = {
		take	= "Take",
		use		= "Use",
	},
	insects = {
		"Butterfly",
		"Torchbug",
		"Wasp",
		"Fleshflies",
		"Dragonfly",
		"Netch Calf",
		"Fetcherfly",
		"Seth's Dovah-Fly",
	},
	seats = {
		"Seat",
	},
	isNeeded	= " needs to be activated.",
	align		= "Alignment",
	alpha		= "Opacity",
	cat00 = {
		title	= "CROSS-CHARACTERS SETTINGS",
	},
	cat0 = {
		title	= "PREFERRED LOOT SETTINGS",
		desc0	= "These settings override the regular loot settings.",
		opt1	= "Auto Loot",
		opt2	= "Auto Loot Stolen Items",
	},
	cat1 = {
		title	= "LOOTING TWEAKS",
		opt1	= "Prevent autoloot if low bag space",
		warn1	= "“Auto Loot Items” gameplay setting will be changed dynamically.",
		opt1b	= "Low limit for backpack space",
		opt11	= "Hide interaction for empty container",
		opt12	= "Hide interaction for insects",
	},
	cat2 = {
		title	= "STEALING TWEAKS",
		opt1	= "Use “Smart Stealing”",
		opt1b	= "Override by double-tap (in ms)",
		warn1	= "“Auto Loot Stolen Items” gameplay setting will be changed dynamically.",
		desc1	= "“Smart Stealing” can prevent unwanted or accidental stealings.\nIf not correctly hidden, containers will be open but not looted,\nand stealing directly from people or in the world will be prevented.\nNote: An override key can be set in the bindings (keep pressed to override).",
		menu	= "Advanced settings",
			desc10	= "Choose to enable or disable “Smart Stealing” for specific actions.\nDon't put the blame on it if you get caught!",
			opt10	= "Use advanced settings",
			opt11	= "Use “Smart Stealing” for containers",
			opt11b	= "Use “Smart Stealing” for lockpicking",
			opt12	= "Use “Smart Stealing” for world items",
			opt13	= "Use “Smart Stealing” for pickpocket",
		opt2	= "over the key-binding when stealing prevented", -- icon ..
		opt2b	= "Alternative position for ", -- .. icon
		opt3	= "Display timers when a bounty is active",
		opt4	= "Prevent sit interaction when stealthy",
	},
	cat3 = {
		title	= "INFORMATION DISPLAY",
		sub0	= "IN INVENTORY",
			opt01	= "Replace “Inventory Space” by ", -- .. icon
			opt02	= "Add a “Stolen” filter in inventory",
			opt03	= "Skip a line (compatibility with other addons)",
			-- opt02tt = "This requires the library \'LibFilters 3.0\' to be installed and activated!",
		sub1	= "IN LOOT WINDOW",
		sub2	= "CONTENT",
			opt21	= "Bag used slots count …",
			opt21b	= "Stolen items count",
			opt22	= "Fenced items count …",
			opt23	= "Laundered items count …",
			opt223	= "Group fenced and laundered",
			optRed	= "… in red color if remaining is below:",
			opt24	= "Reset timer for fenced/laundered items",
	},
}