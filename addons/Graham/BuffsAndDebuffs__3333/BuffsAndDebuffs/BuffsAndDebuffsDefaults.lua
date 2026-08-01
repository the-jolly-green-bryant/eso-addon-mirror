local bad = GlByGrhmForBuffsAndDebuffs

bad.defaultsChar = {}
bad.defaultsChar.selProfile = 1

bad.defaults = {}
bad.defaults.profiles = {}
bad.defaults.profiles[1] = {} 
bad.defaults.profiles[1].name = "WardenBuffsPvP"
bad.defaults.profiles[1].frames = {}
bad.defaults.profiles[1].frames[1] = {}
bad.defaults.profiles[1].frames[1].name = "Power: +power"
bad.defaults.profiles[1].frames[1].show = true
bad.defaults.profiles[1].frames[1].size = 20
bad.defaults.profiles[1].frames[1].color = { r = 1.0 , g = 0.87, b = 0.68, a = 1.0 }
bad.defaults.profiles[1].frames[1].width = 150
bad.defaults.profiles[1].frames[1].x = 1800
bad.defaults.profiles[1].frames[1].y = 900
bad.defaults.profiles[1].frames[1].bars = {
	[1] = {
		name = "Beetles",
		show = true,
		target = "player",
		source = COMBAT_UNIT_TYPE_PLAYER,
		sitsOn = false,
		charge = "Fill",
		thick = 30,
		startColor = { r = 0.5, g = 0.2, b = 0 , a = 1 },
		endColor = { r = 1.0, g = 0, b = 0 , a = 1 },
		backColor = { r = 0, g = 0, b = 0 , a = 0.5 },
		timer = CENTER,
		timerColor = { r = 1.0, g = 1.0, b = 1.0 , a = 1.0 },
		IDs = { 86019, 94440, 94441, 94442 }
	},
	[2] = {
		name = "2ndBeetles",
		show = true,
		target = "player",
		source = COMBAT_UNIT_TYPE_PLAYER,
		sitsOn = true,
		charge = "Fill",
		thick = 30,
		startColor = { r = 0.5, g = 0.2, b = 0 , a = 1 },
		endColor = { r = 1.0, g = 0, b = 0 , a = 1 },
		backColor = { r = 0, g = 0, b = 0 , a = 0.5 },
		timer = CENTER,
		timerColor = { r = 1.0, g = 1.0, b = 1.0 , a = 1.0 },
		IDs = { 146919 }
	},
	[3] = {
		name = "Netch",
		show = true,
		target = "any",
		source = COMBAT_UNIT_TYPE_PLAYER,
		sitsOn = false,
		charge = "Drain",
		thick = 10,
		startColor = { r = 0.2, g = 0.8, b = 0.6 , a = 1 },
		endColor = { r = 0.2, g = 0.8, b = 0.6 , a = 1 },
		backColor = { r = 0.0, g = 0.0, b = 0.0 , a = 0.5 },
		timer = 0,
		timerColor = { r = 1.0, g = 1.0, b = 1.0 , a = 1.0 },
		IDs = { 86058 }
	},
	[4] = {
		name = "Speed",
		show = true,
		target = "player",
		source = 0,
		sitsOn = false,
		charge = "Drain",
		thick = 5,
		startColor = { r = 0.9, g = 0.7, b = 0.0 , a = 1 },
		endColor = { r = 0.9, g = 0.7, b = 0.0 , a = 1 },
		backColor = { r = 0.0, g = 0.0, b = 0.0 , a = 0.5 },
		timer = 0,
		timerColor = { r = 1.0, g = 1.0, b = 1.0 , a = 1.0 },
		IDs = { 89078, 101161, 101178 }
	},
	[5] = {
		name = "Evasion",
		show = true,
		target = "player",
		source = COMBAT_UNIT_TYPE_PLAYER,
		sitsOn = false,
		charge = "Drain",
		thick = 10,
		startColor = { 0.0, g = 0.8, b = 1.0 , a = 1 },
		endColor = { r = 0.0, g = 0.8, b = 1.0 , a = 1 },
		backColor = { r = 0.0, g = 0.0, b = 0.0 , a = 0.5 },
		timer = 0,
		timerColor = { r = 1.0, g = 1.0, b = 1.0 , a = 1.0 },
		IDs = { 63019 }
	},
	[6] = {
		name = "Shuffle",
		show = true,
		target = "player",
		source = COMBAT_UNIT_TYPE_PLAYER,
		sitsOn = true,
		charge = "Drain",
		thick = 10,
		startColor = { r = 0.2, g = 0.2, b = 1.0 , a = 1 },
		endColor = { r = 0.2, g = 0.2, b = 1.0 , a = 1 },
		backColor = { r = 0.0, g = 0.0, b = 1.0 , a = 0.0 },
		timer = 0,
		timerColor = { r = 1.0, g = 1.0, b = 1.0 , a = 1.0 },
		IDs = { 39196 }
	},
	[7] = {
		name = "Vigor",
		show = true,
		target = "any",
		source = COMBAT_UNIT_TYPE_PLAYER,
		sitsOn = false,
		charge = "Drain",
		thick = 10,
		startColor = { r = 0.7, g = 1.0, b = 0.0 , a = 1 },
		endColor = { r = 0.7, g = 1.0, b = 0.0 , a = 1 },
		backColor = { r = 0.0, g = 0.0, b = 0.0 , a = 0.5 },
		timer = 0,
		timerColor = { r = 1.0, g = 1.0, b = 1.0 , a = 1.0 },
		IDs = { 61506 }
	},
	[8] = {
		name = "Eye of Storm",
		show = true,
		target = "player",
		source = COMBAT_UNIT_TYPE_PLAYER,
		sitsOn = false,
		charge = "Drain",
		thick = 15,
		startColor = { r = 0.9, g = 0.0, b = 8.0 , a = 1 },
		endColor = { r = 1.0, g = 1.0, b = 1.0 , a = 1 },
		backColor = { r = 0.0, g = 0.0, b = 0.0 , a = 0.5 },
		timer = CENTER,
		timerColor = { r = 1.0, g = 1.0, b = 1.0 , a = 1.0 },
		IDs = { 83682, 83684, 83686 }
	},
	[9] = {
		name = "Swarm",
		show = true,
		target = "any",
		source = COMBAT_UNIT_TYPE_PLAYER,
		sitsOn = false,
		charge = "Drain",
		thick = 10,
		startColor = { r = 0.7, g = 0.0, b = 1.0 , a = 1 },
		endColor = { r = 0.7, g = 0.0, b = 1.0 , a = 1 },
		backColor = { r = 0.0, g = 0.0, b = 0.0 , a = 0.5 },
		timer = 0,
		timerColor = { r = 1.0, g = 1.0, b = 1.0 , a = 1.0 },
		IDs = { 101944 }
	},
	[10] = {
		name = "Deto",
		show = false,
		target = "group",
		source = COMBAT_UNIT_TYPE_GROUP,
		sitsOn = false,
		charge = "Fill",
		thick = 15,
		startColor = { r = 0.6, g = 0.0, b = 8.0 , a = 1 },
		endColor = { r = 0.6, g = 0.0, b = 8.0 , a = 1 },
		backColor = { r = 0.0, g = 0.0, b = 0.0 , a = 0.5 },
		timer = CENTER,
		timerColor = { r = 1.0, g = 1.0, b = 1.0 , a = 1.0 },
		IDs = { 61500 }
	},
}
bad.defaults.profiles[1].frames[2] = {}
bad.defaults.profiles[1].frames[2].name = "Debuffs"
bad.defaults.profiles[1].frames[2].show = false
bad.defaults.profiles[1].frames[2].size = 20
bad.defaults.profiles[1].frames[2].color = { r = 1.0 , g = 0.87, b = 0.68, a = 1.0 }
bad.defaults.profiles[1].frames[2].width = 150
bad.defaults.profiles[1].frames[2].x = 1800
bad.defaults.profiles[1].frames[2].y = 800
bad.defaults.profiles[1].frames[2].bars = {
	[1] = {
		name = "Oil",
		show = true,
		target = "player",
		source = 0,
		sitsOn = false,
		charge = "Drain",
		thick = 20,
		startColor = { r = 1.0, g = 0.4, b = 0.4 , a = 1.0 },
		endColor = { r = 1.0, g = 0.4, b = 0.4 , a = 1.0 },
		backColor = { r = 0.4, g = 0.2, b = 0.0 , a = 1.0 },
		timer = 0,
		timerColor = { r = 1.0, g = 1.0, b = 1.0 , a = 1.0 },
		IDs = { 15775, 15776 }
	},
	[2] = {
		name = "Negate",
		show = true,
		target = "group",
		source = 0,
		sitsOn = false,
		charge = "Drain",
		thick = 30,
		startColor = { r = 0.43, g = 0.0, b = 0.74 , a = 1 },
		endColor = { r = 0.43, g = 0.0, b = 0.74 , a = 1 },
		backColor = { r = 1.0, g = 1.0, b = 0.5 , a = 1.0 },
		timer = 0,
		timerColor = { r = 1.0, g = 1.0, b = 1.0 , a = 1.0 },
		IDs = { 47160, 28341, 47195 }
	}
}
bad.defaults.profiles[2] = {}
bad.defaults.profiles[2].name = "DK2Hand"
bad.defaults.profiles[2].frames = {}
bad.defaults.profiles[2].frames[1] = {}
bad.defaults.profiles[2].frames[1].name = "Power: +power"
bad.defaults.profiles[2].frames[1].show = true
bad.defaults.profiles[2].frames[1].size = 20
bad.defaults.profiles[2].frames[1].color = { r = 1.0 , g = 0.87, b = 0.68, a = 1.0 }
bad.defaults.profiles[2].frames[1].width = 150
bad.defaults.profiles[2].frames[1].x = 1800
bad.defaults.profiles[2].frames[1].y = 900
bad.defaults.profiles[2].frames[1].bars = {
	[1] = {
		name = "Rally",
		show = true,
		target = "player",
		source = 0,
		sitsOn = false,
		charge = "Drain",
		thick = 10,
		startColor = { r = 0.2, g = 0.7, b = 0.0 , a = 1 },
		endColor = { r = 0.6, g = 0.3, b = 0.0 , a = 1 },
		backColor = { r = 0.0, g = 0.0, b = 0.0 , a = 0.5 },
		timer = 0,
		timerColor = { r = 1.0, g = 1.0, b = 1.0 , a = 1.0 },
		IDs = { 38802 }
	},
	[2] = {
		name = "Igneous shield",
		show = true,
		target = "player",
		source = 0,
		sitsOn = false,
		charge = "Drain",
		thick = 10,
		startColor = { r = 1.0, g = 0.4, b = 0.0 , a = 1 },
		endColor = { r = 1.0, g = 0.6, b = 0.0 , a = 1 },
		backColor = { r = 0.0, g = 0.0, b = 0.0 , a = 0.5 },
		timer = 0,
		timerColor = { r = 1.0, g = 1.0, b = 1.0 , a = 1.0 },
		IDs = { 29224, 29225 }
	},
	[3] = {
		name = "Speed",
		show = true,
		target = "player",
		source = 0,
		sitsOn = false,
		charge = "Drain",
		thick = 5,
		startColor = { r = 0.9, g = 0.7, b = 0.0 , a = 1 },
		endColor = { r = 0.9, g = 0.7, b = 0.0 , a = 1 },
		backColor = { r = 0.0, g = 0.0, b = 0.0 , a = 0.5 },
		timer = 0,
		timerColor = { r = 1.0, g = 1.0, b = 1.0 , a = 1.0 },
		IDs = { 89078, 101161, 101178 }
	},
	[4] = {
		name = "Evasion",
		show = true,
		target = "player",
		source = COMBAT_UNIT_TYPE_PLAYER,
		sitsOn = false,
		charge = "Drain",
		thick = 10,
		startColor = { 0.0, g = 0.8, b = 1.0 , a = 1 },
		endColor = { r = 0.0, g = 0.8, b = 1.0 , a = 1 },
		backColor = { r = 0.0, g = 0.0, b = 0.0 , a = 0.5 },
		timer = 0,
		timerColor = { r = 1.0, g = 1.0, b = 1.0 , a = 1.0 },
		IDs = { 63019 }
	},
	[5] = {
		name = "Shuffle",
		show = true,
		target = "player",
		source = COMBAT_UNIT_TYPE_PLAYER,
		sitsOn = true,
		charge = "Drain",
		thick = 10,
		startColor = { r = 0.2, g = 0.2, b = 1.0 , a = 1 },
		endColor = { r = 0.2, g = 0.2, b = 1.0 , a = 1 },
		backColor = { r = 0.0, g = 0.0, b = 1.0 , a = 0.0 },
		timer = 0,
		timerColor = { r = 1.0, g = 1.0, b = 1.0 , a = 1.0 },
		IDs = { 39196 }
	},
	[6] = {
		name = "Vigor",
		show = true,
		target = "any",
		source = COMBAT_UNIT_TYPE_PLAYER,
		sitsOn = false,
		charge = "Drain",
		thick = 10,
		startColor = { r = 0.7, g = 1.0, b = 0.0 , a = 1 },
		endColor = { r = 0.7, g = 1.0, b = 0.0 , a = 1 },
		backColor = { r = 0.0, g = 0.0, b = 0.0 , a = 0.5 },
		timer = 0,
		timerColor = { r = 1.0, g = 1.0, b = 1.0 , a = 1.0 },
		IDs = { 61506 }
	},
}