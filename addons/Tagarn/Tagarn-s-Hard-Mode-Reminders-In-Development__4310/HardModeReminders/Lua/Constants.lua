-- Copyright (c) 2025 by Tagarn

-- This add-on may be copied, shared, and used as-is while playing Elder
-- Scrolls Online, provided this notice is left intact. However, this
-- add-on, in part or in full, may not be used in the creation of other
-- add-ons without the express written consent of Tagarn.

-- The Elder Scrolls Online add-on provided by Tagarn ("we," "us," or "our")
-- is for entertainment purposes only. UNDER NO CIRCUMSTANCE SHALL WE HAVE ANY
-- LIABILITY TO YOU FOR ANY LOSS OR DAMAGE OF ANY KIND INCURRED AS A RESULT OF
-- THE USE OF OUR ADD-ON. YOUR USE OF OUR ADD-ON IS SOLELY AT YOUR OWN RISK.


HardModeReminders = HardModeReminders or {}
local constants = {
	ZONE_LIST_HEIGHT = 30,

	arenaDetect = {
		["presence"] = 1,
		["mapId"] = 2,
		["coordinates"] = 3,
		["arkasis"] = 4, -- Exarch Kraglen (Final, Stone Guarden)
		["stonekeeper"] = 5, -- Stonekeeper (Final, Frostvault)
		["theKnot"] = 6, -- Lucent Citadel - The Knot / Xoryn
		["coordsAtBoss"] = 7, -- Coordinates at boss (Maarselok, Grundwulf / Moongrave Fane)
	},

	hmDetect = {
		["maxHealth"] = 1,
		["maarselok"] = 2, -- Lair of Maarselok
		["stonekeeper"] = 3, -- Stonekeeper (Final, Frostvault)
		["theKnot"] = 4, -- Lucent Citadel - The Knot / Xoryn
		["none"] = 5, -- None (For testing)
	},

	messageType = {
		["inBossArea"] = 1,
	},

	fv = {
		["start"] = 1,
		["inTrashCombat"] = 2,
		["trashCombatComplete"] = 3,
		["skeevaton"] = 4,
		["complete"] = 5,
	},

	testData = {
		"a3f91c0e7bd2458f19e4c7aa03d9b2f4c18e77ad",
		"5e0b9f42d1a7c38e84f2ab19c0d7e3f9b52a10cc",
		"9bd47e21f0c8a53d72e19ab44cf0d3a8e11f66b2",
		"539f43f21a60ca4e3c0c5883ec48763b5af1ffdc",
		"c84f1a93e2b7d05f3a9c4e11b7f2d88a5c0e91f3",
		"1f7a3c9e04d2b85a6c1f93e0a7b4d52c8e0f11aa",
		"d2e91b74c0f3a58e19d4c7b2e0a9f33c7b1e04d9",
		"4c0e9a71b3d2f58c7e1a04f9d3b7c21e8f5a90d4",
		"ef12c48a7b90d3e15c2f8a41d0b7e93c4a1d6f02",
		"73a9d0c4e1b58f2a9c04e7d3b1f6a28d5c0e91b7",
		"08f4c1e9d3b7a52c6e19f0a4b8d7c33e1a5f90bd",
		-- "589a76fac9667f68121e7d43694765b7c5d0ad9e",
	},

}

HardModeReminders.C = constants
