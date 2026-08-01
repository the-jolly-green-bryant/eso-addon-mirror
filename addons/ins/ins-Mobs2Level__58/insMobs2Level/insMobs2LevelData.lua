-- This is translation file for ins:Mobs2Level
insM2L = {}

--  we setup our addon name and version
insM2L.name = "insMobs2Level"
insM2L.version = 20211111
insM2L.author = "iNSTANT & mra4nii"

insM2L.strings = {
	["en"] = {
		["base"] = {
			"Kills", -- 1
			"Craftings", -- 2
			"Quests", -- 3
			"Events", -- 4
		},
		["phrases"] = {
			INTRO = "<cW>ins<cY>:<cG>Mobs2Level<cW> has loaded.",
			GENERAL = "General",
			TIMESTAMP = "Enable Timestamp",
			TAB = "Output to Chat Tab",
			TAB_WARNING = "Non-existing chat tab ID will be silently ignored",
			CRAFT = "Crafting XP output",
			KILL = "Kill XP output",
			QUEST = "Quest XP output",
			EVENT = "Event XP output",
			DEBUG = "Debug mode",
			CUSTOMHEAD = "Customize Output",
			CUSTOM = "Use Custom output",
			CUSTOM_DESCRIPTION1 = "Please note: These are CASE SENSITIVE\n" ..
								"<1> = xp gain\n" ..
								"<2> = xp to go\n" ..
								"<3> = xp to go / xp gain = kills\n" ..
								"<4> = Tradeskill name",
			CUSTOM_DESCRIPTION2 = "<999> = Kill/Quest/Crafting/Event depending on what event occurred.\n" ..
								"<cW> - |cFFFFFFWhite|r\n" ..
								"<cG> - |c00FF00Green|r\n" ..
								"<cR> - |cFF0000Red|r",
			CUSTOM_DESCRIPTION3 = "<cT> - |c00FFFFTeal|r\n" .. 
								"<cY> - |cFFFF00Yellow|r\n" ..
								"Ex: <cY>+<cG><1> <cY>(<cT><4><cY>)\n" ..
								"Out: |cFFFF00+|r|c00FF00125|r |cFFFF00(|r|c00FFFFWoodworking|r|cFFFF00)|r",
			CUSTOMSKILL = "Custom output for Craftings",
			CUSTOMKILL = "Custom output for Kills",
			CUSTOMQUEST = "Custom output for Quests",
			CUSTOMEVENT = "Custom output for Events",
		},
		["xppredefined"] = "<cW>You gained <cG><1><cY> XP <cW>: <cG><2><cW> to go (<cG><3> <cY><999><cW>)",
	},
	["de"] = {
		["base"] = {
			"Kills", -- 1
			"Craftings", -- 2
			"Quests", -- 3
			"Events", -- 4
		},
		["phrases"] = {
			INTRO = "<cW>ins<cY>:<cG>Mobs2Level<cW> has loaded.",
			GENERAL = "General",
			TIMESTAMP = "Enable Timestamp",
			TAB = "Output to Chat Tab",
			TAB_WARNING = "Non-existing chat tab ID will be silently ignored",
			CRAFT = "Crafting XP output",
			KILL = "Kill XP output",
			QUEST = "Quest XP output",
			EVENT = "Event XP output",
			DEBUG = "Debug mode",
			CUSTOMHEAD = "Customize Output",
			CUSTOM = "Use Custom output",
			CUSTOM_DESCRIPTION1 = "Please note: These are CASE SENSITIVE\n" ..
								"<1> = xp gain\n" ..
								"<2> = xp to go\n" ..
								"<3> = xp to go / xp gain = kills\n" ..
								"<4> = Tradeskill name",
			CUSTOM_DESCRIPTION2 = "<999> = Kill/Quest/Crafting/Event depending on what event occurred.\n" ..
								"<cW> - |cFFFFFFWhite|r\n" ..
								"<cG> - |c00FF00Green|r\n" ..
								"<cR> - |cFF0000Red|r",
			CUSTOM_DESCRIPTION3 = "<cT> - |c00FFFFTeal|r\n" .. 
								"<cY> - |cFFFF00Yellow|r\n" ..
								"Ex: <cY>+<cG><1> <cY>(<cT><4><cY>)\n" ..
								"Out: |cFFFF00+|r|c00FF00125|r |cFFFF00(|r|c00FFFFWoodworking|r|cFFFF00)|r",
			CUSTOMSKILL = "Custom output for Craftings",
			CUSTOMKILL = "Custom output for Kills",
			CUSTOMQUEST = "Custom output for Quests",
			CUSTOMEVENT = "Custom output for Events",
		},
		["xppredefined"] = "<cW>You gained <cG><1><cY> XP <cW>: <cG><2><cW> to go (<cG><3> <cY><999><cW>)",
	},
	["fr"] = {
		["base"] = {
			"Kills", -- 1
			"Craftings", -- 2
			"Quests", -- 3
			"Events", -- 4
		},
		["phrases"] = {
			INTRO = "<cW>ins<cY>:<cG>Mobs2Level<cW> has loaded.",
			GENERAL = "General",
			TIMESTAMP = "Enable Timestamp",
			TAB = "Output to Chat Tab",
			TAB_WARNING = "Non-existing chat tab ID will be silently ignored",
			CRAFT = "Crafting XP output",
			KILL = "Kill XP output",
			QUEST = "Quest XP output",
			EVENT = "Event XP output",
			DEBUG = "Debug mode",
			CUSTOMHEAD = "Customize Output",
			CUSTOM = "Use Custom output",
			CUSTOM_DESCRIPTION1 = "Please note: These are CASE SENSITIVE\n" ..
								"<1> = xp gain\n" ..
								"<2> = xp to go\n" ..
								"<3> = xp to go / xp gain = kills\n" ..
								"<4> = Tradeskill name",
			CUSTOM_DESCRIPTION2 = "<999> = Kill/Quest/Crafting/Event depending on what event occurred.\n" ..
								"<cW> - |cFFFFFFWhite|r\n" ..
								"<cG> - |c00FF00Green|r\n" ..
								"<cR> - |cFF0000Red|r",
			CUSTOM_DESCRIPTION3 = "<cT> - |c00FFFFTeal|r\n" .. 
								"<cY> - |cFFFF00Yellow|r\n" ..
								"Ex: <cY>+<cG><1> <cY>(<cT><4><cY>)\n" ..
								"Out: |cFFFF00+|r|c00FF00125|r |cFFFF00(|r|c00FFFFWoodworking|r|cFFFF00)|r",
			CUSTOMSKILL = "Custom output for Craftings",
			CUSTOMKILL = "Custom output for Kills",
			CUSTOMQUEST = "Custom output for Quests",
			CUSTOMEVENT = "Custom output for Events",
		},
		["xppredefined"] = "<cW>You gained <cG><1><cY> XP <cW>: <cG><2><cW> to go (<cG><3> <cY><999><cW>)",
	},
}
