-- OmniStats
-- Provides character attributes in a compact frame
-- Kept up to date by: M0R_Gaming
-- Original author: RunningDuck
-- Original author of version 1.x: stjobe
-- LibAddonMenu courtesy of Seerah: http://www.esoui.com/downloads/info7-LibAddonMenu.html
-- Credits: Autohide code by @uladz
------------------
-- DECLARATIONS --
------------------
local DebugMe = false -- Set to false to inhibit trace printout in chat
local FirstMainLoop = true

local OmniStats = {}
OmniStats.name = "OmniStats"
OmniStats.displayVersion = "4.0.0"
OmniStats.saveVersion = "280"

OmniStats.Initialized = false
OmniStats.ToggledOff = false


local uesp = false


local stats = {
	[STAT_MAGICKA_MAX] = {
		Text = {
			[1] = "STAT_MAGICKA_MAX: ", -- DebugN
			[2] = "Magicka max: ", -- LongN
			[3] = "Magicka: ", -- MediumN
			[4] = "Mag: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 1,
	},

	[STAT_MAGICKA_REGEN_COMBAT] = {
		Text = {
			[1] = "STAT_MAGICKA_REGEN_COMBAT: ", -- DebugN
			[2] = "Magicka Recovery: ", -- LongN
			[3] = "Mag Rec: ", -- MediumN
			[4] = "MaR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 2,
	},

	[STAT_HEALTH_MAX] = {
		Text = {
			[1] = "STAT_HEALTH_MAX: ", -- DebugN
			[2] = "Health Max: ", -- LongN
			[3] = "Health: ", -- MediumN
			[4] = "Hth: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 3,
	},
	[STAT_HEALTH_REGEN_COMBAT] = {
		Text = {
			[1] = "STAT_HEALTH_REGEN_COMBAT: ", -- DebugN
			[2] = "Health Recovery: ", -- LongN
			[3] = "Hth Rec: ", -- MediumN
			[4] = "HtR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 4,
	},
	[STAT_STAMINA_MAX] = {
		Text = {
			[1] = "STAT_STAMINA_MAX: ", -- DebugN
			[2] = "Stamina Max: ", -- LongN
			[3] = "Stamina: ", -- MediumN
			[4] = "Sta: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 5,
	},
	[STAT_STAMINA_REGEN_COMBAT] = {
		Text = {
			[1] = "STAT_STAMINA_REGEN_COMBAT: ", -- DebugN
			[2] = "Stamina Recovery: ", -- LongN
			[3] = "Sta Rec: ", -- MediumN
			[4] = "StR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 6,
	},
	[STAT_SPELL_POWER] = {
		Text = {
			[1] = "STAT_SPELL_POWER: ", -- DebugN
			[2] = "Spell Damage: ", -- LongN
			[3] = "Spe Dmg: ", -- MediumN
			[4] = "SpD: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 7,
	},
	[STAT_POWER] = { -- use STAT_POWER instead of STAT_WEAPON_POWER
		Text = {
			[1] = "STAT_POWER: ", -- DebugN
			[2] = "Weapon Damage: ", -- LongN
			[3] = "Wpn Dmg: ", -- MediumN
			[4] = "WpD: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 8,
	},
	[STAT_SPELL_CRITICAL] = {
		Text = {
			[1] = "STAT_SPELL_CRITICAL: ", -- DebugN
			[2] = "Spell Critical: ", -- LongN
			[3] = "Spe Crit: ", -- MediumN
			[4] = "SpC: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 9,
	},
	[STAT_CRITICAL_STRIKE] = {
		Text = {
			[1] = "STAT_CRITICAL_STRIKE: ", -- DebugN
			[2] = "Weapon Critical: ", -- LongN
			[3] = "Wpn Crit: ", -- MediumN
			[4] = "WpC: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 10,
	},
	[STAT_SPELL_RESIST] = {
		Text = {
			[1] = "STAT_SPELL_RESIST: ", -- DebugN
			[2] = "Spell Resistance: ", -- LongN
			[3] = "Spe Res: ", -- MediumN
			[4] = "SpR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 11,
	},
	[STAT_PHYSICAL_RESIST] = {
		Text = {
			[1] = "STAT_PHYSICAL_RESIST: ", -- DebugN
			[2] = "Physical Resistance: ", -- LongN
			[3] = "Phys Res: ", -- MediumN
			[4] = "PhR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 12,
	},




	
	-- Additional stats
	[STAT_ATTACK_POWER] = {
		Text = {
			[1] = "STAT_ATTACK_POWER: ", -- DebugN
			[2] = "Attack Power: ", -- LongN
			[3] = "Attack: ", -- MediumN
			[4] = "Att: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 13,
	},
	[STAT_HEALTH_REGEN_IDLE] = {
		Text = {
			[1] = "STAT_HEALTH_REGEN_IDLE: ", -- DebugN
			[2] = "Health Rec. Idle: ", -- LongN
			[3] = "Hth Rec I: ", -- MediumN
			[4] = "HRI: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 14,
	},
	[STAT_SPELL_PENETRATION] = {
		Text = {
			[1] = "STAT_SPELL_PENETRATION: ", -- DebugN
			[2] = "Spell Penetration: ", -- LongN
			[3] = "Spell Pen: ", -- MediumN
			[4] = "SpP: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 15,
	},
	[STAT_MAGICKA_REGEN_IDLE ] = {
		Text = {
			[1] = "STAT_MAGICKA_REGEN_IDLE : ", -- DebugN
			[2] = "Magicka Rec. Idle: ", -- LongN
			[3] = "Mag Rec I: ", -- MediumN
			[4] = "MRI: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 16,
	},
	[STAT_PHYSICAL_PENETRATION] = {
		Text = {
			[1] = "STAT_PHYSICAL_PENETRATION: ", -- DebugN
			[2] = "Armor Penetration: ", -- LongN
			[3] = "Armor Pen: ", -- MediumN
			[4] = "ArP: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 17,
	},
	[STAT_STAMINA_REGEN_IDLE ] = {
		Text = {
			[1] = "STAT_STAMINA_REGEN_IDLE : ", -- DebugN
			[2] = "Stamina Rec. Idle: ", -- LongN
			[3] = "Sta Rec I: ", -- MediumN
			[4] = "SRI: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 18,
	},
	[STAT_SPELL_MITIGATION ] = {
		Text = {
			[1] = "STAT_SPELL_MITIGATION : ", -- DebugN
			[2] = "Spell Mitigation: ", -- LongN
			[3] = "Spell Mit: ", -- MediumN
			[4] = "SpM: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 19,
	},
	[STAT_MITIGATION ] = {
		Text = {
			[1] = "STAT_MITIGATION : ", -- DebugN
			[2] = "Mitigation: ", -- LongN
			[3] = "Mitig: ", -- MediumN
			[4] = "Mit: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 20,
	},
	[STAT_HEALING_TAKEN ] = {
		Text = {
			[1] = "STAT_HEALING_TAKEN : ", -- DebugN
			[2] = "Healing Taken: ", -- LongN
			[3] = "Healed: ", -- MediumN
			[4] = "Hea: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 21,
	},
	[STAT_CRITICAL_RESISTANCE ] = {
		Text = {
			[1] = "STAT_CRITICAL_RESISTANCE : ", -- DebugN
			[2] = "Critical Resistance: ", -- LongN
			[3] = "Crit Res: ", -- MediumN
			[4] = "CrR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 22,
	},
	[STAT_DAMAGE_RESIST_COLD ] = {
		Text = {
			[1] = "STAT_DAMAGE_RESIST_COLD : ", -- DebugN
			[2] = "Cold Resistance: ", -- LongN
			[3] = "Cold Res: ", -- MediumN
			[4] = "CoR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 23,
	},
	[STAT_DAMAGE_RESIST_DISEASE ] = {
		Text = {
			[1] = "STAT_DAMAGE_RESIST_DISEASE : ", -- DebugN
			[2] = "Disease Resistance: ", -- LongN
			[3] = "Dis Res: ", -- MediumN
			[4] = "DiR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 24,
	},
	[STAT_DAMAGE_RESIST_DROWN ] = {
		Text = {
			[1] = "STAT_DAMAGE_RESIST_DROWN : ", -- DebugN
			[2] = "Drown Resistance: ", -- LongN
			[3] = "Drow Res: ", -- MediumN
			[4] = "DrR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 25,
	},
	[STAT_DAMAGE_RESIST_EARTH ] = {
		Text = {
			[1] = "STAT_DAMAGE_RESIST_EARTH : ", -- DebugN
			[2] = "Earth Resistance: ", -- LongN
			[3] = "Eath Res: ", -- MediumN
			[4] = "EaR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 26,
	},
	[STAT_DAMAGE_RESIST_FIRE ] = {
		Text = {
			[1] = "STAT_DAMAGE_RESIST_FIRE : ", -- DebugN
			[2] = "Fire Resistance: ", -- LongN
			[3] = "Fire Res: ", -- MediumN
			[4] = "FiR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 27,
	},
	[STAT_DAMAGE_RESIST_GENERIC ] = {
		Text = {
			[1] = "STAT_DAMAGE_RESIST_GENERIC : ", -- DebugN
			[2] = "Generic Resistance: ", -- LongN
			[3] = "Gen Res: ", -- MediumN
			[4] = "GeR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 28,
	},
	[STAT_DAMAGE_RESIST_MAGIC ] = {
		Text = {
			[1] = "STAT_DAMAGE_RESIST_MAGIC : ", -- DebugN
			[2] = "Magic Resistance: ", -- LongN
			[3] = "Mag Res: ", -- MediumN
			[4] = "MaR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 29,
	},
	[STAT_DAMAGE_RESIST_OBLIVION ] = {
		Text = {
			[1] = "STAT_DAMAGE_RESIST_OBLIVION : ", -- DebugN
			[2] = "Oblivion Resistance: ", -- LongN
			[3] = "Obl Res: ", -- MediumN
			[4] = "ObR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 30,
	},
	[STAT_DAMAGE_RESIST_PHYSICAL ] = {
		Text = {
			[1] = "STAT_DAMAGE_RESIST_PHYSICAL : ", -- DebugN
			[2] = "Damage Resistance: ", -- LongN
			[3] = "Dmg Res: ", -- MediumN
			[4] = "Dmg: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 31,
	},
	[STAT_DAMAGE_RESIST_POISON ] = {
		Text = {
			[1] = "STAT_DAMAGE_RESIST_POISON : ", -- DebugN
			[2] = "Poison Resistance: ", -- LongN
			[3] = "Pois Res: ", -- MediumN
			[4] = "PoR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 32,
	},
	[STAT_DAMAGE_RESIST_SHOCK ] = {
		Text = {
			[1] = "STAT_DAMAGE_RESIST_SHOCK : ", -- DebugN
			[2] = "Shock Resistance: ", -- LongN
			[3] = "Sho Res: ", -- MediumN
			[4] = "ShR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 33,
	},
	[STAT_NONE ] = {
		Text = {
			[1] = "STAT_NONE : ", -- DebugN
			[2] = "None: ", -- LongN
			[3] = "None: ", -- MediumN
			[4] = "Non: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 34,
	},
	[STAT_DODGE ] = {
		Text = {
			[1] = "STAT_DODGE : ", -- DebugN
			[2] = "Dodge: ", -- LongN
			[3] = "Dodge: ", -- MediumN
			[4] = "Dge: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 35,
	},
	[STAT_BLOCK] = {
		Text = {
			[1] = "STAT_BLOCK : ", -- DebugN
			[2] = "Block: ", -- LongN
			[3] = "Block: ", -- MediumN
			[4] = "Blk: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 36,
	},
	[STAT_HEALING_DONE] = {
		Text = {
			[1] = "STAT_HEALING_DONE : ", -- DebugN
			[2] = "Healing Done: ", -- LongN
			[3] = "HealDone: ", -- MediumN
			[4] = "HeD: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 37,
	},
	[STAT_MISS ] = {
		Text = {
			[1] = "STAT_MISS : ", -- DebugN
			[2] = "Miss: ", -- LongN
			[3] = "Miss: ", -- MediumN
			[4] = "Mis: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 38,
	},
	[STAT_ARMOR_RATING] = {
		Text = {
			[1] = "STAT_ARMOR_RATING: ", -- DebugN
			[2] = "Armor Rating: ", -- LongN
			[3] = "Armor: ", -- MediumN
			[4] = "Arm: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 39,
	},
	[STAT_MOUNT_STAMINA_MAX ] = {
		Text = {
			[1] = "STAT_MOUNT_STAMINA_MAX : ", -- DebugN
			[2] = "Mount Stamina: ", -- LongN
			[3] = "Mnt Sta: ", -- MediumN
			[4] = "MSt: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 40,
	},
	[STAT_MOUNT_STAMINA_REGEN_MOVING ] = {
		Text = {
			[1] = "STAT_MOUNT_STAMINA_REGEN_MOVING : ", -- DebugN
			[2] = "Mount Stamina Rec: ", -- LongN
			[3] = "Mnt Sta R: ", -- MediumN
			[4] = "MSR: ", -- ShortN
		},
		Current = 0, Ref = 0, Pos = 41,
	},


	-- CUSTOM STATS
	[51] = {
		Text = {
			[1] = "CUSTOM_EFFECTIVE_DAMAGE : ", -- DebugN
			[2] = "Effective Damage: ", -- LongN
			[3] = "Eff Damage: ", -- MediumN
			[4] = "Eff: ", -- ShortN
		},
		Formula = function(self)
			if (uesp) then
				return uespLog.GetEffectiveWeaponPower()
			else
				self.Show = false
				OmniStats.UpdateUI()
				return 0
			end
		end,
		Current = 0, Ref = 0, Pos = 42, Custom = true,
		Dependancy = true,
		DependancySatisfied = function(self)
			return uesp
		end,
		DependancyText = "This calculation requires the addon UESP Log to be installed."
	},

	[52] = {
		Text = {
			[1] = "CUSTOM_EFFECTIVE_SPELL_DAMAGE : ", -- DebugN
			[2] = "Effective Spell: ", -- LongN
			[3] = "Eff Spell: ", -- MediumN
			[4] = "EfS: ", -- ShortN
		},
		Formula = function(self)
			if (uesp) then
				return uespLog.GetEffectiveSpellPower()
			else
				self.Show = false
				OmniStats.UpdateUI()
				return 0
			end
		end,
		Current = 0, Ref = 0, Pos = 43, Custom = true,
		Dependancy = true,
		DependancySatisfied = function(self)
			return uesp
		end,
		DependancyText = "This calculation requires the addon UESP Log to be installed."
	},

	[53] = {
		Text = {
			[1] = "CUSTOM_CRITICAL_DAMAGE : ", -- DebugN
			[2] = "Critical Damage: ", -- LongN
			[3] = "Crit Dmg: ", -- MediumN
			[4] = "CrD: ", -- ShortN
		},
		Formula = function(self)
			_, _, value = GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_CRITICAL_DAMAGE)
			return value + 50
		end,
		Current = 0, Ref = 0, Pos = 44, Custom = true, Suffix = "%"
	},
	--[[


	[54] = {
		Text = {
			[1] = "ADVANCED_SNEAK_SPEED : ", -- DebugN
			[2] = "Sneak Speed: ", -- LongN
			[3] = "Sneak Spd: ", -- MediumN
			[4] = "SnS: ", -- ShortN
		},
		Formula = function(self)
			_, _, value = GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_SNEAK_SPEED_REDUCTION)
			return value
		end,
		Current = 0, Ref = 0, Pos = 45, Custom = true, Suffix = "%"
	},
	[55] = {
		Text = {
			[1] = "CUSTOM_NORMAL_SPEED : ", -- DebugN
			[2] = "Movement Speed: ", -- LongN
			[3] = "Speed: ", -- MediumN
			[4] = "Spd: ", -- ShortN
		},
		Formula = function(self)
			return 100
		end,
		Current = 0, Ref = 0, Pos = 46, Custom = true, Suffix = "%",
		Dependancy = true,
		DependancySatisfied = function(self)
			return false
		end,
		DependancyText = "This calculation is not yet implemented."
	},
	[56] = {
		Text = {
			[1] = "ADVANCED_SPRINT_SPEED : ", -- DebugN
			[2] = "Sprint Speed: ", -- LongN
			[3] = "Sprint Spd: ", -- MediumN
			[4] = "SpS: ", -- ShortN
		},
		Formula = function(self)
			_, _, value = GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_SPRINT_SPEED)
			return value
		end,
		Current = 0, Ref = 0, Pos = 47, Custom = true, Suffix = "%"
	},

	--]]

}


local NewSettings = {
	posX = 30,
	posY = 100,
	ShowMax = true,
	Layout = "3 rows, 2 by 2",
	BDAlpha = 0.3,
	TextAlpha = 1,
	Scale = 1,
	ShowIC = false,
	ShowOOC = true,
	ShowManual = false,
	TextType = 4, -- 1,2,3,4, see CtrlWidth
	ShowTarget = false,
	AutoHide = true,
	locked = false,
	thousandDelimiter = 3, -- Space
	saveMode = false, -- false = use account wide, i.e. same settings for all chars
	refreshTime = 1000, -- refresh interval in milliseconds
	statsShown = {},
	targetsShown = {}
}


-- Pos must be unique, Show = true or false
local targets = {
	[POWERTYPE_MAGICKA] = {
		Text = {[1] = "POWERTYPE_MAGICKA: ", [2] = "Magicka max: ", [3] = "Magicka: ", [4] = "Mag: "},
		Current = 0, Ref = 0, Pos = 1, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil},
	[POWERTYPE_HEALTH] = {
		Text = {[1] = "POWERTYPE_HEALTH: ", [2] = "Health Max: ", [3] = "Health: ", [4] = "Hth: "},
		Current = 0, Ref = 0, Pos = 2, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil},
	[POWERTYPE_STAMINA] = {
		Text = {[1] = "POWERTYPE_STAMINA: ", [2] = "Stamina Max: ", [3] = "Stamina: ", [4] = "Sta: "},
		Current = 0, Ref = 0, Pos = 3, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil},
	[POWERTYPE_ULTIMATE] = {
		Text = {[1] = "POWERTYPE_ULTIMATE: ", [2] = "Ultimate: ", [3] = "Ultimate: ", [4] = "Ult: "},
		Current = 0, Ref = 0, Pos = 5, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil},
	[POWERTYPE_WEREWOLF] = {
		Text = {[1] = "POWERTYPE_WEREWOLF: ", [2] = "Werewolf: ", [3] = "Werewolf: ", [4] = "Wwf: "},
		Current = 0, Ref = 0, Pos = 6, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil},
	[POWERTYPE_MOUNT_STAMINA] = {
		Text = {[1] = "POWERTYPE_MOUNT_STAMINA: ", [2] = "Mount Stamina Max: ", [3] = "Mnt Sta: ", [4] = "MSt: "},
		Current = 0, Ref = 0, Pos = 7, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil},
	[POWERTYPE_HEALTH_BONUS] = {
		Text = {[1] = "POWERTYPE_HEALTH_BONUS: ", [2] = "Health Bonus: ", [3] = "Hth Bonu: ", [4] = "Hbo: "},
		Current = 0, Ref = 0, Pos = 12, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil},
	[101] = {
		Text = {[1] = "Homebrewed: TARGET_NAME: ", [2] = "Target Name: ", [3] = "Name: ", [4] = "T N: "},
		Current = 0, Ref = 0, Pos = 14, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil},
	[102] = {
		Text = {[1] = "Homebrewed: TARGET_CLASS: ", [2] = "Target Class: ", [3] = "Tar Class: ", [4] = "T C: "},
		Current = 0, Ref = 0, Pos = 15, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil},
	[103] = {
		Text = {[1] = "Homebrewed: TARGET_Level: ", [2] = "Target Level: ", [3] = "Tar Lvl: ", [4] = "T L: "},
		Current = 0, Ref = 0, Pos = 16, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil},
	[104] = {
		Text = {[1] = "Homebrewed: TARGET_VET_LVL: ", [2] = "Target Vet Lvl: ", [3] = "Tar Vet: ", [4] = "T V: "},
		Current = 0, Ref = 0, Pos = 17, Show = true, NameCtrl = nil, ValueCtrl = nil, IconCtrl = nil},
}

-- There should be this number of stats in targets
local TargetStats = 11

-- There should be this number of stats in SV.Omni
local NumberOfStats = 44

local SV = {} -- Saved Variables that defaults to DefaultSettings
local vars = {}
local alwaysAccountWide = {} -- Default, except "saveMode", account wide Saved Variables that defaults to DefaultSettings

-- Width for display controls
local CtrlWidth = {
	[1] = {Length = 198, Name = "Debug (35)"}, -- DebugN: 37 chars in text (35 define + 1 : + 1 space)
	[2] = {Length = 126, Name = "Long (19)"}, -- LongN: 21 chars in text (19 define + 1 : + 1 space)
	[3] = {Length = 60, Name = "Medium (8)"}, -- MediumN: 10 chars in text (8 define + 1 : + 1 space)
	[4] = {Length = 30, Name = "Short (3)"}, -- ShortN: 5 chars in text (3 define + 1 : + 1 space)
	[5] = {Length = 36, Name = "Number value"}, -- Number value, after Update 6 need a 5th digit, plus  room for a thousand delimiter
	[6] = {Length = 16, Name = "Icon"}, -- Icon field
	[7] = {Length = 16, Name = "Delimiter"}, -- Width for grouping delimiter
}

---------------
-- FUNCTIONS --
---------------
local panelData = {
	type = "panel",
    name = OmniStats.name,
	author = "RunningDuck",
    version = OmniStats.displayVersion,
	website = "http://www.esoui.com/downloads/info863-OmniStats.html",
	slashCommand = "/omni"
}

function OmniStats.GetBaseValues()
    for stat, statVal in pairs(stats) do
    	if (statVal.Custom) then
			if (vars.statsShown[stat]) then
				stats[stat].Ref = stats[stat]:Formula()
			end
		else
			stats[stat].Ref = GetPlayerStat(stat, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
		end
	end
end

function OmniStats.GetValues()
    for stat, _ in pairs(stats) do
		if (vars.ShowMax == false) then
			if (stat == STAT_HEALTH_MAX) then
				stats[stat].Current, _, _ = GetUnitPower("player", POWERTYPE_HEALTH)
			elseif (stat == STAT_STAMINA_MAX) then
				stats[stat].Current, _, _ = GetUnitPower("player", POWERTYPE_STAMINA)
			elseif (stat == STAT_MAGICA_MAX) then
				stats[stat].Current, _, _ = GetUnitPower("player", POWERTYPE_MAGICA)
			else
				stats[stat].Current = GetPlayerStat(stat, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
			end
		else -- always show max
			if (stat == STAT_HEALTH_MAX) then
				_, _, stats[stat].Current = GetUnitPower("player", POWERTYPE_HEALTH)
			elseif (stat == STAT_STAMINA_MAX) then
				_, _, stats[stat].Current = GetUnitPower("player", POWERTYPE_STAMINA)
			elseif (stat == STAT_MAGICA_MAX) then
				_, _, stats[stat].Current = GetUnitPower("player", POWERTYPE_MAGICA)
			elseif (stats[stat].Custom) then
				if (vars.statsShown[stat]) then
					stats[stat].Current = stats[stat]:Formula()
				end
			else
				stats[stat].Current = GetPlayerStat(stat, STAT_BONUS_OPTION_APPLY_BONUS, STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP)
			end
		end
    end
end

function OmniStats.UpdateUI()
    for stat, _ in pairs(vars.statsShown) do
		stats[stat].ValueCtrl:SetColor(1,1,1,1)


		if (stats[stat].softcap) and (stats[stat].Current > stats[stat].softcap) then -- softcapped
			stats[stat].ValueCtrl:SetColor(0.9,0.5,0.3,1)
			stats[stat].IconCtrl:SetHidden(false)
		else
			stats[stat].IconCtrl:SetHidden(true)
		end

		if stats[stat].Current > stats[stat].Ref then -- buffed
            stats[stat].ValueCtrl:SetColor(0,1,0,1)
        elseif stats[stat].Current < stats[stat].Ref then -- debuffed
            stats[stat].ValueCtrl:SetColor(1,0,0,1)
        end
		
		if (stat == STAT_CRITICAL_STRIKE or stat == STAT_SPELL_CRITICAL) then
			percentvalue = GetCriticalStrikeChance(stats[stat].Current, true)
			stats[stat].ValueCtrl:SetText(string.format("%.0f", percentvalue).."%")
			-- debug
			if (DebugMe == true and FirstMainLoop == false) then
				d(stats[stat])
			end
			-- end debug
		else
			local output = ""
			if vars.thousandDelimiter > 0 and stats[stat].Current > 1000 then
				thousands = math.floor(stats[stat].Current / 1000)
				rest = stats[stat].Current - (thousands * 1000)
				if vars.thousandDelimiter == 1 then delimiter = "."
				elseif vars.thousandDelimiter == 2 then delimiter = ","
				else delimiter = " " end
				output = string.format("%d%s%.3d", thousands, delimiter, rest)
			else -- None
				output = string.format("%d", stats[stat].Current)
			end
			if stats[stat].Suffix then
				output = output .. stats[stat].Suffix
			end
			stats[stat].ValueCtrl:SetText(output)

		end
    end
end

function OmniStats.CreateLayout()
	local xOffset = 0
	local xGOffset = 0
	local yOffset = 0
	local yGOffset = 0
	local DisplayStats = 0
	local DisplayTStats = 0
	local i = 0
	
	-- index of StatPos = display order, array of stats that should be shown, used as index to Omni
	local StatPos = {}
	local TargetPos = {}

	-- StatPos should contain the stat that should be displayed (shown) and in the right display order
	for i=1, NumberOfStats do
		for stat, _ in pairs(stats) do
			if stats[stat].Pos == i and vars.statsShown[stat] then
				DisplayStats = DisplayStats + 1
				StatPos[DisplayStats] = stat
				break -- the inner for-loop as we found the item 
			end
		end
	end
	for i=1, TargetStats do
		for stat, _ in pairs(targets) do
			if targets[stat].Pos == i and targets[stat].Show == true then
				DisplayTStats = DisplayTStats + 1
				TargetPos[DisplayTStats] = stat
				break -- the inner for-loop as we found the item 
			end
		end
	end
	
	-- Reposition controls for new namelength and print new name, hide if it shouldn't be displayed
	for stat, _ in pairs(stats) do
        stats[stat].NameCtrl:SetDimensions(CtrlWidth[vars.TextType].Length, 16)
		stats[stat].NameCtrl:SetText(string.format("%s", stats[stat].Text[vars.TextType]))

		local hide = true
		if vars.statsShown[stat] then
			hide = false
		end
		stats[stat].NameCtrl:SetHidden(hide)
		stats[stat].ValueCtrl:SetHidden(hide)
		stats[stat].IconCtrl:SetHidden(hide)
	end
	for stat, _ in pairs(targets) do
        targets[stat].NameCtrl:SetDimensions(CtrlWidth[vars.TextType].Length, 16)
		targets[stat].NameCtrl:SetText(string.format("%s", targets[stat].Text[vars.TextType]))
		targets[stat].NameCtrl:SetHidden(not targets[stat].Show)
		targets[stat].ValueCtrl:SetHidden(not targets[stat].Show)
	end
	
	-- Width is dependent on type of text + space for digits + an icon
	local width = CtrlWidth[vars.TextType].Length + CtrlWidth[5].Length + CtrlWidth[6].Length
	
	if (vars.Layout == "Vertical") then
		-- Vertical = one column by DisplayStats rows
		for pos=1, DisplayStats do
			stats[StatPos[pos]].NameCtrl:SetAnchor(TOPLEFT, OmniStats.MainWindow, TOPLEFT, 0, yOffset * 16 + yGOffset * 10)
			yOffset = yOffset + 1
			if (yOffset % 2 == 0) then yGOffset = yGOffset + 1 end
		end
		OmniStats.MainWindow:SetDimensions(width, yOffset * 16 + yGOffset * 10)
		
	elseif (vars.Layout == "Horizontal") then
		-- Horizontal = DisplayStats columns by one row
		for pos=1, DisplayStats do
			stats[StatPos[pos]].NameCtrl:SetAnchor(TOPLEFT, OmniStats.MainWindow, TOPLEFT, (xOffset * width + xGOffset * CtrlWidth[7].Length), 0)
			xOffset = xOffset + 1
			if (xOffset % 2 == 0) then xGOffset = xGOffset + 1 end
		end
		OmniStats.MainWindow:SetDimensions(xOffset * width + xGOffset * CtrlWidth[7].Length, 16)
		
	elseif (vars.Layout == "2 columns") then
		-- 2 columns = 2 columns by DisplayStats/2 rows
		local maxcolumns = 1 -- i.e 2, as 0 is first column
		local row = 0
		for pos=1, DisplayStats do
			stats[StatPos[pos]].NameCtrl:SetAnchor(TOPLEFT, OmniStats.MainWindow, TOPLEFT, (xOffset * width), (yOffset * 16 + yGOffset * 10))
			-- Iterate over all columns. After last column increase row and start on first column
			if (xOffset == maxcolumns) then 
				xOffset = 0
				yOffset = yOffset + 1
				if (yOffset % 3 == 0) then 	yGOffset = yGOffset + 1 end
			else 
				xOffset = xOffset + 1 
				row = row+1
			end
		end
		OmniStats.MainWindow:SetDimensions((maxcolumns+1) * width, row * 16 + yGOffset * 10)
		
		-- Target stat currently only available in the "2 columns" mode
		xOffset = 0
		yOffset = 0
		for pos=1, DisplayTStats do
			targets[TargetPos[pos]].NameCtrl:SetAnchor(TOPLEFT, OmniStats.TargetWindow, TOPLEFT, (xOffset * width), (yOffset * 16))
			-- Iterate over all columns. After last column increase row and start on first column
			if (xOffset == maxcolumns) then 
				xOffset = 0
				yOffset = yOffset + 1
			else 
				xOffset = xOffset + 1 
			end
		end
		OmniStats.TargetWindow:SetDimensions((maxcolumns+1) * width, (yOffset+1) * 16)
		
	elseif (vars.Layout == "3 rows, 2 by 2") then
		-- 3 rows = DisplayStats/3 columns by 3 rows
		local maxcolumns = math.ceil(DisplayStats/3) - 1  -- 0 is first column
		if (maxcolumns % 2 == 0) then maxcolumns = maxcolumns + 1 end -- ensure an even number of columns (again; 0 is first column)
		local tempcolumns = 1 -- order stats in first two columns, then next 2 columns
		for pos=1, DisplayStats do
			stats[StatPos[pos]].NameCtrl:SetAnchor(TOPLEFT, OmniStats.MainWindow, TOPLEFT, (xOffset * width + xGOffset * CtrlWidth[7].Length), (yOffset * 16))
			-- Iterate over all columns. After last column increase row and start on first column
			if (xOffset == tempcolumns) then 
				xOffset = xOffset - 1
				yOffset = yOffset + 1
			else 
				xOffset = xOffset + 1 
			end
			-- When two cols are filled, i.e. want to start on 4th row, start with next 2 cols
			if (yOffset >= 3) then 
				xOffset = tempcolumns + 1
				tempcolumns = tempcolumns + 2
				yOffset = 0
				xGOffset = xGOffset + 1
			end	
		end
		OmniStats.MainWindow:SetDimensions((maxcolumns+1) * width + xGOffset * CtrlWidth[7].Length, 3 * 16)
		
	else
		d("OmniStats: Unknown layout parameter")
	end
end


function OmniStats.CreateUI()
	OmniStats.MainWindow = WINDOW_MANAGER:CreateTopLevelWindow(OmniStats.name.."MainWindow")
    OmniStats.MainWindow:SetDimensions(280, 200)
    OmniStats.MainWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, vars.posX, vars.posY)
    OmniStats.MainWindow:SetHidden(false)
    OmniStats.MainWindow:SetMovable(not vars.locked)
    OmniStats.MainWindow:SetMouseEnabled(true)
    OmniStats.MainWindow:SetClampedToScreen(true)
	OmniStats.MainWindow:SetHandler("OnMouseUp", function(_, button)
			if button == 2 then
				OmniStats.GetBaseValues()
			elseif button == 1 then
				vars.posX = math.floor(OmniStatsMainWindow:GetLeft())
				vars.posY = math.floor(OmniStatsMainWindow:GetTop())
			end
		end)
	OmniStats.MainWindow:SetAlpha(vars.TextAlpha)


	OmniStats.CombatWrapper = WINDOW_MANAGER:CreateControl(OmniStats.name.."CombatWrapper", OmniStats.MainWindow, CT_CONTROL)
	OmniStats.CombatWrapper:SetAnchorFill()

	-- Controls
	for stat, _ in pairs(stats) do
		stats[stat].NameCtrl = WINDOW_MANAGER:CreateControl(OmniStats.name.."Name"..stat, OmniStats.CombatWrapper, CT_LABEL)
        stats[stat].NameCtrl:SetHidden(false)
        stats[stat].NameCtrl:SetDimensions(CtrlWidth[vars.TextType].Length, 16)
        stats[stat].NameCtrl:SetAlpha(1)
		stats[stat].NameCtrl:SetFont("ZoFontGameSmall")
        stats[stat].NameCtrl:SetColor(1, 0.98, 0.8, 1)
		stats[stat].NameCtrl:SetText(string.format("%s", stats[stat].Text[vars.TextType]))
		
		stats[stat].ValueCtrl = WINDOW_MANAGER:CreateControl(OmniStats.name.."Value"..stat, OmniStats.CombatWrapper, CT_LABEL)
		stats[stat].ValueCtrl:SetHidden(false)
        stats[stat].ValueCtrl:SetFont("ZoFontGameSmall")
        stats[stat].ValueCtrl:SetDimensions(CtrlWidth[5].Length, 16)
        stats[stat].ValueCtrl:SetColor(1, 1, 1, 1)
        stats[stat].ValueCtrl:SetAlpha(1)
        stats[stat].ValueCtrl:SetAnchor(TOPLEFT, stats[stat].NameCtrl, TOPRIGHT, 0, 0)
		stats[stat].ValueCtrl:SetHorizontalAlignment(2) -- align right
        stats[stat].ValueCtrl:SetText("0")
		
		stats[stat].IconCtrl = WINDOW_MANAGER:CreateControl(OmniStats.name.."Icon"..stat, OmniStats.CombatWrapper, CT_TEXTURE)
		stats[stat].IconCtrl:SetHidden(true)
		stats[stat].IconCtrl:SetDimensions(CtrlWidth[6].Length, 16)
		stats[stat].IconCtrl:SetAlpha(1)
		stats[stat].IconCtrl:SetAnchor(TOPLEFT, stats[stat].ValueCtrl, TOPRIGHT, 0, 0)
		stats[stat].IconCtrl:SetTexture("ESOUI/art/stats/diminishingreturns_icon.dds")
		stats[stat].IconCtrl:SetDrawLevel(1)
    end

	-- Target window
	OmniStats.TargetWindow = WINDOW_MANAGER:CreateTopLevelWindow(OmniStats.name.."TargetWindow")
    OmniStats.TargetWindow:SetDimensions(280, 200)
    OmniStats.TargetWindow:SetAnchor(TOPLEFT, OmniStats.CombatWrapper, TOPRIGHT, 16, 0)
    OmniStats.TargetWindow:SetHidden(false)
	OmniStats.TargetWindow:SetAlpha(vars.TextAlpha)

	-- Target controls
	for stat, _ in pairs(targets) do
		targets[stat].NameCtrl = WINDOW_MANAGER:CreateControl(OmniStats.name.."TarName"..stat, OmniStats.TargetWindow, CT_LABEL)
        targets[stat].NameCtrl:SetHidden(false)
        targets[stat].NameCtrl:SetDimensions(CtrlWidth[vars.TextType].Length, 16)
        targets[stat].NameCtrl:SetAlpha(1)
		targets[stat].NameCtrl:SetFont("ZoFontGameSmall")
        targets[stat].NameCtrl:SetColor(1, 0.98, 0.8, 1)
		targets[stat].NameCtrl:SetText(string.format("%s", targets[stat].Text[vars.TextType]))
		
		targets[stat].ValueCtrl = WINDOW_MANAGER:CreateControl(OmniStats.name.."TarValue"..stat, OmniStats.TargetWindow, CT_LABEL)
		targets[stat].ValueCtrl:SetHidden(false)
        targets[stat].ValueCtrl:SetFont("ZoFontGameSmall")
        targets[stat].ValueCtrl:SetDimensions(CtrlWidth[5].Length, 16)
        targets[stat].ValueCtrl:SetColor(1, 1, 1, 1)
        targets[stat].ValueCtrl:SetAlpha(1)
        targets[stat].ValueCtrl:SetAnchor(TOPLEFT, targets[stat].NameCtrl, TOPRIGHT, 0, 0)
		targets[stat].ValueCtrl:SetHorizontalAlignment(2) -- align right
        targets[stat].ValueCtrl:SetText("0")
    end
	
	
	-- Layout
	OmniStats.CreateLayout()
	
	-- Backdrop
	OmniStats.MainBD = WINDOW_MANAGER:CreateControlFromVirtual(OmniStats.name.."MainBD", OmniStats.CombatWrapper, "ZO_DefaultBackdrop")
	OmniStats.MainBD:SetAlpha(vars.BDAlpha)
	OmniStats.TargetBD = WINDOW_MANAGER:CreateControlFromVirtual(OmniStats.name.."TargetBD", OmniStats.TargetWindow, "ZO_DefaultBackdrop")
	OmniStats.TargetBD:SetAlpha(vars.BDAlpha)

	-- Set scale
	OmniStats.MainWindow:SetScale(vars.Scale)
	OmniStats.TargetWindow:SetScale(vars.Scale)
	--OmniStats.CombatWrapper:SetTransformScale


	-- Initially hide target window
	OmniStats.TargetWindow:SetHidden(true)

	-- Create fragment
	OmniStats.Fragment = ZO_HUDFadeSceneFragment:New(OmniStats.MainWindow, DEFAULT_SCENE_TRANSITION_TIME, 0)
	if vars.AutoHide then
		HUD_SCENE:AddFragment(OmniStats.Fragment)
		HUD_UI_SCENE:AddFragment(OmniStats.Fragment)
	end

end








local function OnCombatState(_, inCombat)
	if vars.ShowManual then return end

	if inCombat then
		OmniStats.CombatWrapper:SetHidden(not vars.ShowIC)
	else
		OmniStats.CombatWrapper:SetHidden(not vars.ShowOOC)
	end
end







function OmniStats.CreateSettings()
	
	local LAM2 = LibAddonMenu2
	local optionsData = {
		{
			type = "checkbox",
			name = "Always show max values",
			tooltip = "Checking this option prevents regular depletion of Magicka, Health, and Stamina to show as debuffed",
			getFunc = function() return vars.ShowMax end,
			setFunc = function(value) 
				vars.ShowMax = value
			end,
		},
		{
			type = "checkbox",
			name = "Lock Window",
			tooltip = "Stops the window from being moved",
			getFunc = function() return vars.locked end,
			setFunc = function(value) 
				vars.locked = value
				OmniStats.MainWindow:SetMovable(not value)
			end,
		},
		{
			type = "dropdown",
			name = "Layout",
			tooltip = "Sets the layout the stats are displayed with",
			choices = {"3 rows, 2 by 2", "2 columns", "Vertical", "Horizontal"},
			getFunc = function() return vars.Layout end,
			setFunc = function(value) 
				if value ~= vars.Layout then
					vars.Layout = value
					OmniStats.CreateLayout()
				end
			end,
		},
		{
			type = "dropdown",
			name = "Text type",
			tooltip = "How much text should be displayed. ('Debug' is the name of the DerivedStats global LUA value)",
			choices = {CtrlWidth[4].Name, CtrlWidth[3].Name, CtrlWidth[2].Name, CtrlWidth[1].Name},
			getFunc = function() return CtrlWidth[vars.TextType].Name end,
			setFunc = function(value) 
				local index = 0
				for ix, _ in pairs(CtrlWidth) do
					if (value == CtrlWidth[ix].Name) then index = ix; end
				end
				if index ~= vars.TextType then
					vars.TextType = index
					OmniStats.CreateLayout()
				end
			end,
		},
		{
			type = "slider",
			name = "Text alpha (percent)",
			tooltip = "Sets the text alpha",
			min = 0,
			max = 100,
			step = 1,
			getFunc = function() return vars.TextAlpha * 100 end,
			setFunc = function(value) 
				if value ~= vars.TextAlpha then
					vars.TextAlpha = value / 100
					OmniStatsMainWindow:SetAlpha(vars.TextAlpha)
				end
			end,
		},
		{
			type = "slider",
			name = "Background alpha (percent)",
			tooltip = "Sets the background alpha",
			min = 0,
			max = 100,
			step = 1,
			getFunc = function() return vars.BDAlpha * 100 end,
			setFunc = function(value) 
				if value ~= vars.BDAlpha then
					vars.BDAlpha = value / 100
					OmniStatsMainBD:SetAlpha(vars.BDAlpha)
				end
			end,
		},
		{
			type = "slider",
			name = "Window scaling (percent)",
			tooltip = "Sets the scaling",
			min = 50,
			max = 300,
			step = 1,
			getFunc = function() return vars.Scale * 100 end,
			setFunc = function(value) 
				if value ~= vars.Scale then
					vars.Scale = value / 100
					OmniStatsMainWindow:SetScale(vars.Scale)
					OmniStatsTargetWindow:SetScale(vars.Scale)
					OmniStats.CreateLayout()
				end
			end,
		},
		{
			type = "dropdown",
			name = "Show all stats",
			tooltip = "When to show and hide the entire stat window, for manual define a key: Control/Keybindings: User Interface/OmniStats toggle on/off",
			choices = {"Manual (keybind)", "Out-Of-Combat", "In-Combat", "Always"},
			getFunc = function()  
				if (vars.ShowManual == true) then 
					return "Manual (keybind)"
				elseif (vars.ShowOOC == true and vars.ShowIC == false) then 
					return "Out-Of-Combat"
				elseif (vars.ShowIC == true and vars.ShowOOC == false) then 
					return "In-Combat"
				else 
					return "Always" 
				end
			end,
			setFunc = function(value) 
				if (value == "Manual (keybind)") then 
					vars.ShowManual = true
					vars.ShowIC = false
					vars.ShowOOC = false
				elseif (value == "In-Combat") then 
					vars.ShowManual = false 
					vars.ShowIC = true
					vars.ShowOOC = false
				elseif (value == "Out-Of-Combat") then 
					vars.ShowManual = false 
					vars.ShowIC = false
					vars.ShowOOC = true
				else -- "Always"
					vars.ShowManual = false 
					vars.ShowIC = true
					vars.ShowOOC = true
				end
				OmniStats.CreateLayout()
				OnCombatState(nil, IsUnitInCombat('player'))
			end,
		},
		{
			type = "dropdown",
			name = "Thousand delimiter",
			tooltip = "Increase readability with a delimiter that separate the last three digits",
			choices = {"Space ' '", "Dot '.'", "Comma ','", "None"},
			getFunc = function()  
				if (vars.thousandDelimiter == 0) then return "None"
				elseif (vars.thousandDelimiter == 1) then return "Dot '.'"
				elseif (vars.thousandDelimiter == 2) then return "Comma ','"
				else return "Space ' '" end
			end,
			setFunc = function(value) 
				if (value == "None") then vars.thousandDelimiter = 0
				elseif (value == "Dot '.'") then vars.thousandDelimiter = 1
				elseif (value == "Comma ','") then vars.thousandDelimiter = 2
				else vars.thousandDelimiter = 3 end -- "Space ' '" 
				OmniStats.CreateLayout()
			end,
		},
        {
			type = "checkbox",
			name = "Autohide when menu or dialog open",
			tooltip = "Hides the stats window whenever you open up a menu or a dialog.",
			getFunc = function() return vars.AutoHide end,
			setFunc = function(value) 
				vars.AutoHide = value
				if value then
					HUD_SCENE:AddFragment(OmniStats.Fragment)
					HUD_UI_SCENE:AddFragment(OmniStats.Fragment)
				else
					HUD_SCENE:RemoveFragment(OmniStats.Fragment)
					HUD_UI_SCENE:RemoveFragment(OmniStats.Fragment)
					OmniStats.MainWindow:SetHidden(false)
				end
            end,
        },		
		{
			type = "checkbox",
			name = "Show target values (experimental)",
			tooltip = "Shows stats for target, alas most are blocked and return zero. Currently only available for the '2 columns' mode.",
			getFunc = function() return vars.ShowTarget end,
			setFunc = function(value) 
				vars.ShowTarget = value
			end,
		},
		{
			type = "checkbox",
			name = "Save settings per character [account wide]",
			tooltip = "Don't use account wide settings, but rather for each character. Note, this setting (only) is ALWAYS account wide.",
			getFunc = function() return alwaysAccountWide.saveMode end,
			setFunc = function(value) 
				alwaysAccountWide.saveMode = value 
			end,
		},
		{
			type = "slider",
			name = "Refresh interval (milliseconds)",
			tooltip = "Sets the time between check of changes in the stats. Note that shorter time steals some performance!",
			min = 100,
			max = 1000,
			step = 100,
			getFunc = function() return vars.refreshTime end,
			setFunc = function(value) 
				vars.refreshTime = value
			end,
		},
		{
			type = "header",
			name = "Show/hide individual stats",
		},
	}



	local customUI = {
	  type = "custom",
	  reference = "OmniStatsDrag",
	  createFunc = function(parent)
	    local fullWidth, fullHeight = parent:GetDimensions()

	    -- Boxes
	    local customControlBig = WINDOW_MANAGER:CreateControlFromVirtual("OmniStatsNotAdded", parent, "OmniList")
	    customControlBig:GetNamedChild("Header"):SetText("Disabled")
	    customControlBig:SetAnchor(TOPLEFT, parent, TOPLEFT, 10)
	    customControlBig:SetDimensions(fullWidth/3,fullHeight)
	    customControlBig:GetNamedChild("BG"):SetDimensions(fullWidth/3+10,fullHeight+5)
	    local customControl = customControlBig:GetNamedChild("List")
	    customControl:SetDimensions(fullWidth/3,fullHeight-20)

	    local addedControlsBig = WINDOW_MANAGER:CreateControlFromVirtual("OmniStatsAdded", parent, "OmniList")
	    addedControlsBig:GetNamedChild("Header"):SetText("Enabled")
	    addedControlsBig:SetAnchor(TOPRIGHT)
	    addedControlsBig:SetDimensions(fullWidth/3,fullHeight)
	    addedControlsBig:GetNamedChild("BG"):SetDimensions(fullWidth/3+10,fullHeight+5)
	    local addedControls = addedControlsBig:GetNamedChild("List")
	    addedControls:SetDimensions(fullWidth/3,fullHeight-20)


	    -- Buttons
	    local leftArrow = WINDOW_MANAGER:CreateControlFromVirtual("OmniStatsLeft", parent, "OmniArrow")
	    leftArrow.tooltip = "Disable Selected Stat"
	    leftArrow.tooltipDirection = RIGHT
	    leftArrow:SetAnchor(CENTER, nil, nil, -fullWidth/6/2)
	    leftArrow:SetDimensions(fullWidth/8,fullWidth/6)
	    leftArrow:SetNormalTexture("esoui/art/buttons/large_leftdoublearrow_up.dds")
	    leftArrow:SetMouseOverTexture("esoui/art/buttons/large_leftdoublearrow_over.dds")
	    leftArrow:SetPressedTexture("esoui/art/buttons/large_leftdoublearrow_down.dds")

	    local rightArrow = WINDOW_MANAGER:CreateControlFromVirtual("OmniStatsRight", parent, "OmniArrow")
	    rightArrow.tooltip = "Enable Selected Stat"
	    rightArrow:SetAnchor(CENTER, nil, nil, fullWidth/6/2)
	    rightArrow:SetDimensions(fullWidth/8,fullWidth/6)
	    rightArrow:SetNormalTexture("esoui/art/buttons/large_rightdoublearrow_up.dds")
	    rightArrow:SetMouseOverTexture("esoui/art/buttons/large_rightdoublearrow_over.dds")
	    rightArrow:SetPressedTexture("esoui/art/buttons/large_rightdoublearrow_down.dds")





	    -- Load Data
        local scrollData = ZO_ScrollList_GetDataList(customControl)
        local scrollData2 = ZO_ScrollList_GetDataList(addedControls)
        for i,v in pairs(stats) do
        	local dependancy = nil
        	if v.Dependancy and (not v:DependancySatisfied()) then
        		dependancy = v.DependancyText
        	end
        	local statData = ZO_ScrollList_CreateDataEntry(1, {
    			name = v.Text[2]:sub(1, -3),
    			id = i,
    			pos = v.Pos,
    			dependancy = dependancy
    		})
        	if vars.statsShown[i] then
        		table.insert(scrollData2, statData)
        	else
        		table.insert(scrollData, statData)
        	end
        end
        local function sortDataByPos(k1, k2) return k1.data.pos < k2.data.pos end
        table.sort(scrollData, sortDataByPos)
        table.sort(scrollData2, sortDataByPos)
	    ZO_ScrollList_Commit(customControl)
	    ZO_ScrollList_Commit(addedControls)



	    -- Setup Click Handlers
	    function rightArrow.onClick()
	    	if not customControl.selectedDataId then return end
	    	table.insert(scrollData2, table.remove(scrollData, customControl.selectedDataIndex))
	    	table.sort(scrollData, sortDataByPos)
        	table.sort(scrollData2, sortDataByPos)
	    	ZO_ScrollList_Commit(customControl)
	    	ZO_ScrollList_Commit(addedControls)
	    	vars.statsShown[customControl.selectedDataId] = true
	    	customControl.selectedDataId = nil
	    	OmniStats.CreateLayout()
	    end
	    function leftArrow.onClick()
	    	if not addedControls.selectedDataId then return end
	    	table.insert(scrollData, table.remove(scrollData2, addedControls.selectedDataIndex))
	    	table.sort(scrollData, sortDataByPos)
        	table.sort(scrollData2, sortDataByPos)
	    	ZO_ScrollList_Commit(customControl)
	    	ZO_ScrollList_Commit(addedControls)
	    	vars.statsShown[addedControls.selectedDataId] = nil
	    	addedControls.selectedDataId = nil
	    	OmniStats.CreateLayout()
	    end



	  end,
	  minHeight = 500,
	}

	table.insert(optionsData, customUI)


	--[[
	-- dynamically add all stats
	local DisplayOrder = {}
	local i = 0
	local found = false
	for i=1, NumberOfStats do
		found = false
		for stat, _ in pairs(stats) do
			if stats[stat].Pos == i then
				DisplayOrder[i] = stat
				found = true
				break -- the inner for-loop as we found the item 
			end
		end
		if found == false then DisplayOrder[i] = STAT_NONE end
	end


	for i=1, NumberOfStats do
		local checkbox = {
			type = "checkbox",
			name = stats[ DisplayOrder[i] ].Text[2],
			tooltip = "Check to show stat, uncheck to hide",
			width = "half",
			getFunc = function()
				if vars.statsShown[ DisplayOrder[i] ] then
					return true
				else
					return false
				end
			end,
			setFunc = function(value)
				if value then
					vars.statsShown[ DisplayOrder[i] ] = true
				else
					vars.statsShown[ DisplayOrder[i] ] = nil
				end
				OmniStats.CreateLayout()
			end
		}
		if stats[ DisplayOrder[i] ].Dependancy then
			checkbox["warning"] = stats[ DisplayOrder[i] ].DependancyText
			checkbox["disabled"] = not stats[ DisplayOrder[i] ]:DependancySatisfied()
		end

		table.insert(optionsData, checkbox)
	end

	--]]
		
	LAM2:RegisterAddonPanel(OmniStats.name.."Options", panelData)
	LAM2:RegisterOptionControls(OmniStats.name.."Options", optionsData)
end

function OmniStatsToggleWindow()
	OmniStats.ToggledOff = not OmniStats.ToggledOff
	OmniStats.CombatWrapper:SetHidden(OmniStats.ToggledOff)
end

-- AuotHide code by uladz
local function AutoHide()
	if vars.AutoHide == true then
		local menu1 = not ZO_GameMenu_InGame:IsHidden()
		local menu2 = not ZO_KeybindStripControl:IsHidden()
		local menu3 = not ZO_InteractWindow:IsHidden()
        local menu4 = not ZO_Character:IsHidden()
        local menu5 = WINDOW_MANAGER:IsSecureRenderModeEnabled()
        if menu1 or menu2 or menu3 or menu4 or menu5 then
			return true;
		end
	end
    return false;
 end










function OmniStats.MainLoop()
	OmniStats.GetValues()
    OmniStats.UpdateUI()
	
	-- debug
	if (DebugMe == true and FirstMainLoop == true) then
		FirstMainLoop = false
		for stat, _ in pairs(stats) do
			if (vars.statsShown[stat]) then 
				d(stats[stat])
			end
		end
	end
	-- end debug
	
    zo_callLater(function() OmniStats.MainLoop() end, vars.refreshTime)
end









function OmniStats.DelayedInit()
	OmniStats.GetBaseValues()
	OmniStats.MainLoop()
	OmniStats.Initialized = true
end

function OmniStats.WaitForPlayerLoad()
	if (OmniStats.PlayerActivated == true) then
		zo_callLater(function() OmniStats.DelayedInit() end, 1000)
	else
		zo_callLater(function() OmniStats.WaitForPlayerLoad() end, 1000)
	end
end


local function OnAddOnLoaded(eventCode, addOnName)
	if (addOnName == OmniStats.name) then

		--Load the user's settings from SavedVariables file -> Account wide of basic version 999 at first
		alwaysAccountWide = ZO_SavedVars:NewAccountWide(OmniStats.name.."_SavedVariables", 999, "SettingsForAll", {saveMode = false})
		--Check, by help of basic version 999 settings, if the settings should be loaded for each character or account wide
		--Use the current addon version to read the settings now
		if (alwaysAccountWide.saveMode == true) then
			--Use each character settings
			SV = ZO_SavedVars:New(OmniStats.name.."_SavedVariables", OmniStats.saveVersion , "Settings", {})
			vars = ZO_SavedVars:New(OmniStats.name.."_SavedVariables", OmniStats.saveVersion , "NewSettings", NewSettings)
		else
			--Use standard: account wide settings
			SV = ZO_SavedVars:NewAccountWide(OmniStats.name.."_SavedVariables", OmniStats.saveVersion, "Settings", {})
			vars = ZO_SavedVars:NewAccountWide(OmniStats.name.."_SavedVariables", OmniStats.saveVersion, "NewSettings", NewSettings)
		end

		--[[
		OSV = SV
		OVARS = vars
		OWIDE = alwaysAccountWide
		--]]

  		-- old SV = ZO_SavedVars:NewAccountWide(OmniStats.name.."_SavedVariables", 8, nil, DefaultSettings)

  		-- TRANSFER FROM OLD SAVED VARS
  		if not (SV.Omni == nil) then
  			for name, value in pairs(getmetatable(SV).__index) do
  				if (name == "Omni") then
  					vars.statsShown = {}
  					for i, v in pairs(SV.Omni) do
  						if (v.Show == true) then
  							vars.statsShown[i] = true
  						end
  					end
  					SV.Omni = nil
  				elseif (name == "Target") then -- Target Migration
  					SV.Target = nil
  				elseif not (name == "version") then
  					vars[name] = value
  					SV[name] = nil
				end
  			end
  		end

  		if not (alwaysAccountWide.Omni == nil) then
  			for name, value in pairs(getmetatable(alwaysAccountWide).__index) do
  				if not (name == "saveMode") and not (name == "version") then
  					alwaysAccountWide[name] = nil
				end
  			end
  		end

  		if vars.statsShown == {} then
  			vars.statsShown = {
				[STAT_MAGICKA_MAX] = true,
				[STAT_MAGICKA_REGEN_COMBAT] = true,
				[STAT_HEALTH_MAX] = true,
				[STAT_HEALTH_REGEN_COMBAT] = true,
				[STAT_STAMINA_MAX] = true,
				[STAT_STAMINA_REGEN_COMBAT] = true,
				[STAT_SPELL_POWER] = true,
				[STAT_POWER] = true,
				[STAT_SPELL_CRITICAL] = true,
				[STAT_CRITICAL_STRIKE] = true,
				[STAT_SPELL_RESIST] = true,
				[STAT_PHYSICAL_RESIST] = true
			}
		end
		
		OmniStats.CreateSettings()
		OmniStats.CreateUI()
		OmniStats.WaitForPlayerLoad()

	elseif (addOnName == "uespLog") then
		uesp = true
	end
end

local function OnPlayerActivated()
	OmniStats.PlayerActivated = true
end

local function OnTargetChanged()
	if (vars.Layout == "2 columns" and OmniStats.Initialized) then
		if (vars.ShowTarget and DoesUnitExist("reticleover") == true) then
			-- get creature info
			for stat, _ in pairs(targets) do
				if (stat < 101) then
					_, targets[stat].Current, _ = GetUnitPower("reticleover", stat)
					targets[stat].ValueCtrl:SetText(string.format("%d", targets[stat].Current))
				elseif (stat == 101) then
					targets[stat].Current = GetUnitName('reticleover')
					targets[stat].ValueCtrl:SetText(string.format("%s", targets[stat].Current))
				elseif (stat == 102) then
					targets[stat].Current	= GetUnitClass('reticleover')
					targets[stat].ValueCtrl:SetText(string.format("%s", targets[stat].Current))
				elseif (stat == 103) then
					targets[stat].Current = GetUnitLevel('reticleover')
					targets[stat].ValueCtrl:SetText(string.format("%d", targets[stat].Current))
				elseif (stat == 104) then
					targets[stat].Current	= GetUnitVeteranRank('reticleover')	
					targets[stat].ValueCtrl:SetText(string.format("%d", targets[stat].Current))
				end
			end
			OmniStats.TargetWindow:SetHidden(false)
		else
			--hide target window
			OmniStats.TargetWindow:SetHidden(true)
		end
	end
end

function OmniStatsInitialize()
	EVENT_MANAGER:RegisterForEvent(OmniStats.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(OmniStats.name, EVENT_PLAYER_COMBAT_STATE, OnCombatState)
	EVENT_MANAGER:RegisterForEvent(OmniStats.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
	EVENT_MANAGER:RegisterForEvent(OmniStats.name, EVENT_RETICLE_TARGET_CHANGED, OnTargetChanged )
end