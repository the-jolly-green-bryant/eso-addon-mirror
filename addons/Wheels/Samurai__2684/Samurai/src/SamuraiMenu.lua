SAMURAI = SAMURAI or { }
local sam = SAMURAI

function sam.buildMenu()
	local LAM = LibAddonMenu2
	local lockUI = true
	
	local panelData = {
		type = "panel",
		name = sam.name,
		displayName = "|cffd000Samur|r.|cffe675ai|r",
		author = "|cc2ff19Wheels|r, |cef42ffMormo|r",
		version = ""..sam.version,
		registerForRefresh = true,
	}

	local moduleData = {
		type = "panel",
		name = sam.name .. " Modules",
		displayName = "|cffd000Samur|r.|cffe675ai|r Modules",
		author = "|cc2ff19Wheels|r, |cef42ffMormo|r",
		version = ""..sam.version,
		registerForRefresh = true,
	}

	LAM:RegisterAddonPanel(sam.name.."GeneralOptions", panelData)
	LAM:RegisterAddonPanel(sam.name.."ModuleOptions", moduleData)

	local generalNotis = {
		{
			type = "description",
			text = "Alerts available in all locations",
		},
		{
			type = "divider",
		},
		{
			type = "checkbox",
			name = "Taking Aim",
			tooltip = "Archer taking aim alert",
			width = "half",
			getFunc = function() return sam.savedVars.notis.TakingAim end,
			setFunc = function(value) sam.savedVars.notis.TakingAim = value end,
		},
		{
			type = "checkbox",
			name = "Heavy Attack",
			tooltip = "General heavy attack notification",
			width = "half",
			getFunc = function() return sam.savedVars.notis.HeavyAttack end,
			setFunc = function(value) sam.savedVars.notis.HeavyAttack = value end,
		},
		{
			type = "checkbox",
			name = "Heavy Slash",
			tooltip = "General heavy slash notification",
			width = "half",
			getFunc = function() return sam.savedVars.notis.HeavySlash end,
			setFunc = function(value) sam.savedVars.notis.HeavySlash = value end,
		},
		{
			type = "checkbox",
			name = "Heavy Strike",
			tooltip = "General heavy strike notification",
			width = "half",
			getFunc = function() return sam.savedVars.notis.HeavyStrike end,
			setFunc = function(value) sam.savedVars.notis.HeavyStrike = value end,
		},
		{
			type = "checkbox",
			name = "Bash",
			tooltip = "General bash attack notification",
			width = "half",
			getFunc = function() return sam.savedVars.notis.Bash end,
			setFunc = function(value) sam.savedVars.notis.Bash = value end,
		},
		{
			type = "checkbox",
			name = "Uppercut",
			tooltip = "General uppercut notification",
			width = "half",
			getFunc = function() return sam.savedVars.notis.UpperCut end,
			setFunc = function(value) sam.savedVars.notis.UpperCut = value end,
		},
		{
			type = "checkbox",
			name = "Anvil Cracker",
			tooltip = "General anvil cracker notification",
			width = "half",
			getFunc = function() return sam.savedVars.notis.AnvilCracker end,
			setFunc = function(value) sam.savedVars.notis.AnvilCracker = value end,
		},
		{
			type = "checkbox",
			name = "Crushing Blow",
			tooltip = "General crushing blow notification",
			width = "half",
			getFunc = function() return sam.savedVars.notis.CrushingBlow end,
			setFunc = function(value) sam.savedVars.notis.CrushingBlow = value end,
		},
		{
			type = "checkbox",
			name = "Boulder",
			tooltip = "General boulder notification",
			width = "half",
			getFunc = function() return sam.savedVars.notis.Boulder end,
			setFunc = function(value) sam.savedVars.notis.Boulder = value end,
		},
		{
			type = "checkbox",
			name = "Slam",
			tooltip = "General slam notification",
			width = "half",
			getFunc = function() return sam.savedVars.notis.Slam end,
			setFunc = function(value) sam.savedVars.notis.Slam = value end,
		},
		{
			type = "checkbox",
			name = "Power Bash",
			tooltip = "General power bash notification",
			width = "half",
			getFunc = function() return sam.savedVars.notis.powerBash end,
			setFunc = function(value) sam.savedVars.notis.powerBash = value end,
		},
		{
			type = "checkbox",
			name = "Lava Whip",
			tooltip = "General lava whip notification",
			width = "half",
			getFunc = function() return sam.savedVars.notis.LavaWhip end,
			setFunc = function(value) sam.savedVars.notis.LavaWhip = value end,
		},
		{
			type = "checkbox",
			name = "Toppling Blow",
			tooltip = "General toppling blow notification",
			width = "half",
			getFunc = function() return sam.savedVars.notis.TopplingBlow end,
			setFunc = function(value) sam.savedVars.notis.TopplingBlow = value end,
		},
		{
			type = "checkbox",
			name = "Clash of Bones",
			tooltip = "General clash of bones notification",
			width = "half",
			getFunc = function() return sam.savedVars.notis.ClashofBones end,
			setFunc = function(value) sam.savedVars.notis.ClashofBones = value end,
		},
		{
			type = "checkbox",
			name = "Drain Resource",
			tooltip = "General drain resource notification",
			width = "half",
			getFunc = function() return sam.savedVars.notis.DrainResource end,
			setFunc = function(value) sam.savedVars.notis.DrainResource = value end,
		},
		{
			type = "checkbox",
			name = "Lava Geyser",
			tooltip = "General lava geyser notification",
			width = "half",
			getFunc = function() return sam.savedVars.notis.LavaGeyser end,
			setFunc = function(value) sam.savedVars.notis.LavaGeyser = value end,
		},
		{
			type = "checkbox",
			name = "Rake",
			tooltip = "General hackwing rake notification",
			width = "half",
			getFunc = function() return sam.savedVars.notis.Rake end,
			setFunc = function(value) sam.savedVars.notis.Rake = value end,
		},
	}

	local blackroseNotis = {
		{
			type = "description",
			text = "Alerts available in Blackrose Prison",
		},
		{
			type = "divider",
		},
		{
			type = "checkbox",
			name = "Dive",
			tooltip = "Hackwing dive notification",
			width = "half",
			getFunc = function() return sam.savedVars.notis.Dive end,
			setFunc = function(value) sam.savedVars.notis.Dive = value end,
		},
	}

	local kynesNotis = {
		{
			type = "description",
			text = "Alerts available in Kyne's Aegis",
		},
		{
			type = "divider",
		},
		{
			type = "checkbox",
			name = "Wrath of Tides",
			tooltip = "Wrath of tides notification",
			width = "half",
			getFunc = function() return sam.savedVars.notis.WrathofTides end,
			setFunc = function(value) sam.savedVars.notis.WrathofTides = value end,
		},
		{
			type = "checkbox",
			name = "Crashing Wave",
			tooltip = "Crashing wave notification",
			width = "half",
			getFunc = function() return sam.savedVars.notis.CrashingWave end,
			setFunc = function(value) sam.savedVars.notis.CrashingWave = value end,
		},
		{
			type = "checkbox",
			name = "Chaurus Totem Poison",
			tooltip = "Alert for an incoming poison from the Chaurus totem (EXPERIMENTAL)",
			width = "half",
			disabled = true,
			getFunc = function() return sam.savedVars.notis.Chaurus end,
			setFunc = function(value)
				sam.savedVars.notis.Chaurus = value
				sam.savedVars.notis.ChaurusInc = value
			end,
		},
		{
			type = "checkbox",
			name = "Gargoyle Totem Stone Curse",
			tooltip = "Alert for an incoming stone curse from the gargoyle totem",
			width = "half",
			getFunc = function() return sam.savedVars.notis.StoneCurse end,
			setFunc = function(value) sam.savedVars.notis.StoneCurse = value end,
		},
	}

	local cloudrestNotis = {
		{
			type = "description",
			text = "Alerts available in Cloudrest",
		},
		{
			type = "divider",
		},
		{
			type = "checkbox",
			name = "Shocking Smash",
			tooltip = "Shocking smash notification",
			width = "half",
			getFunc = function() return sam.savedVars.notis.ShockingSmash end,
			setFunc = function(value) sam.savedVars.notis.ShockingSmash = value end,
		},
		{
			type = "checkbox",
			name = "Direct Current",
			tooltip = "Direct current notification",
			width = "half",
			getFunc = function() return sam.savedVars.notis.DirectCurrent end,
			setFunc = function(value) sam.savedVars.notis.DirectCurrent = value end,
		},
		{
			type = "checkbox",
			name = "Nocturnal's Favor",
			tooltip = "Nocturnal's favor (HA) notification",
			width = "half",
			getFunc = function() return sam.savedVars.notis.NocturnalsFavor end,
			setFunc = function(value) sam.savedVars.notis.NocturnalsFavor = value end,
		},
		{
			type = "checkbox",
			name = "Creeper Spawn",
			tooltip = "Creeper spawn notification",
			width = "half",
			getFunc = function() return sam.savedVars.notis.Creeper end,
			setFunc = function(value) sam.savedVars.notis.Creeper = value end,
		},
		{
			type = "checkbox",
			name = "Creeper Target",
			tooltip = "Alert for an incoming Creeper stun on you",
			width = "half",
			getFunc = function() return sam.savedVars.notis.creeperTarget end,
			setFunc = function(value) sam.savedVars.notis.creeperTarget = value end,
		},
		{
			type = "checkbox",
			name = "Icy Teleport",
			tooltip = "Notification for when Galenwe teleports onto you",
			width = "half",
			getFunc = function() return sam.savedVars.notis.IcyTeleport end,
			setFunc = function(value) sam.savedVars.notis.IcyTeleport = value end,
		},
	}

	local sunspireNotis = {
		{
			type = "description",
			text = "Alerts available in Sunspire",
		},
		{
			type = "divider",
		},
		{
			type = "checkbox",
			name = "Portal Negate",
			tooltip = "Alert for an incoming negate on you in the Navi portal",
			width = "half",
			getFunc = function() return sam.savedVars.notis.ssNegate end,
			setFunc = function(value) sam.savedVars.notis.ssNegate = value end,
		},
		{
			type = "checkbox",
			name = "Portal Gale",
			tooltip = "Alert for an incoming Gale (knockback) on you in the Navi portal",
			width = "half",
			getFunc = function() return sam.savedVars.notis.ssGale end,
			setFunc = function(value) sam.savedVars.notis.ssGale = value end,
		},
		{
			type = "checkbox",
			name = "Portal Ice",
			tooltip = "Alert for an incoming ice comet on you in the Navi portal",
			width = "half",
			getFunc = function() return sam.savedVars.notis.ssIce end,
			setFunc = function(value) sam.savedVars.notis.ssIce = value end,
		},
		{
			type = "checkbox",
			name = "Translation Apocalypse",
			tooltip = "Alert to interrupt the Translation Apocalypse channel in the Navi portal",
			width = "half",
			getFunc = function() return sam.savedVars.notis.transApoc end,
			setFunc = function(value) sam.savedVars.notis.transApoc = value end,
		},
	}

	local asylumNotis = {
		{
			type = "description",
			text = "Alerts available in Asylum Sanctorium",
		},
		{
			type = "divider",
		},
		{
			type = "checkbox",
			name = "Boss Protected",
			tooltip = "Alert for the boss becoming invulnerable from an Ordinated Protector",
			width = "half",
			getFunc = function() return sam.savedVars.notis.asBossProtected end,
			setFunc = function(value) sam.savedVars.notis.asBossProtected = value end,
		},
	}

	local hofNotis = {
		{
			type = "description",
			text = "Alerts available in the Halls of Fabrication",
		},
		{
			type = "divider",
		},
		{
			type = "checkbox",
			name = "Shock Lash",
			tooltip = "Alert for incoming shock lash attacks from the raptors",
			width = "half",
			getFunc = function() return sam.savedVars.notis.ShockLash end,
			setFunc = function(value) sam.savedVars.notis.ShockLash = value end,
		},
	}

	local bossTimers = {
		{
			type = "divider",
		},
		{
			type = "description",
			text = "This adds a timer for the spawn in time before a boss is tangible to a number of trial bosses. This no longer requires subtitles to be enabled!"
		},
		{
			type = "divider",
		},
		{
			type = "checkbox",
			name = "Boss Timers",
			tooltip = "Display a timer counting down to when a spawning boss can be hit",
			width = "half",
			getFunc = function() return sam.savedVars.bossTimers end,
			setFunc = function(value)
				-- if value then
				-- 	SetSetting(SETTING_TYPE_SUBTITLES, SUBTITLE_SETTING_ENABLED, 1)
				-- end
				sam.savedVars.bossTimers = value
			end,
		},
		{
			type = "checkbox",
			name = "Hide Subtitles",
			disabled = true,
			tooltip = "No longer needed",
			width = "half",
			getFunc = function() return sam.savedVars.hideSubtitles end,
			setFunc = function(value) sam.savedVars.hideSubtitles = value end,
		},
	}

	local generalOptions = {
		{
			type = "divider",
		},
		{
			type = "description",
			text = "additional settings to be added",
		},
		{
			type = "header",
			name = "General Display Options",
		},
		{
			type = "checkbox",
			name = "Lock Frames",
			tooltip = "Unlock to position frames in desired location (notifications grow upwards, timed alerts grow downwards)",
			getFunc = function() return lockUI end,
			setFunc = function(value)
				sam.UI.setHudDisplay(value)
				lockUI = value
			end,
		},
		{
			type = "divider",
		},
		{
			type = "submenu",
			name = "Boss Timers",
			controls = bossTimers,
		},
		{
			type = "divider",
		},
		{
			type = "header",
			name = "Notifications",
		},
		{
			type = "submenu",
			name = "General",
			controls = generalNotis,
		},
		{
			type = "submenu",
			name = "Kynes Aegis",
			controls = kynesNotis,
		},
		{
			type = "submenu",
			name = "Cloudrest",
			controls = cloudrestNotis,
		},
		{
			type = "submenu",
			name = "Sunspire",
			controls = sunspireNotis,
		},
		{
			type = "submenu",
			name = "Blackrose Prison",
			controls = blackroseNotis,
		},
		{
			type = "submenu",
			name = "Asylum Sanctorium",
			controls = asylumNotis,
		},
		{
			type = "submenu",
			name = "Halls of Fabrication",
			controls = hofNotis, 
		},
	}

	local potionOptions = {
		{
			type = "description",
			text = "Options to change how potions are displayed (currently, more to come)\nChanges to these settings iwll take effect on the next zone change.",
		},
		{
			type = "divider",
		},
		{
			type = "checkbox",
			name = "Rename Heroism Potions",
			tooltip = "Stop heroism potions from being named generic potion names like 'Essence of Magicka'",
			width = "half",
			getFunc = function() return sam.savedVars.modules.potions.renameHeroism end,
			setFunc = function(value) sam.savedVars.modules.potions.renameHeroism = value end,
		},
		{
			type = "checkbox",
			name = "Rename Tri-Pots",
			tooltip = "Potions that give health, magicka, and stamina back will be renamed to Essence of Tri-Restoration",
			width = "half",
			getFunc = function() return sam.savedVars.modules.potions.renameTri end,
			setFunc = function(value) sam.savedVars.modules.potions.renameTri = value end,
		},
		{
			type = "checkbox",
			name = "Rename Vitality Potions",
			tooltip = "Potions that give health and major vitality will be renamed to Essence of Vitality",
			width = "half",
			getFunc = function() return sam.savedVars.modules.potions.renameVitality end,
			setFunc = function(value) sam.savedVars.modules.potions.renameVitality = value end,
		},
	}

	local targetHealthOptions = {
		{
			type = "description",
			text = "Target health display module (this pretty much duplicates what Combat Metronome displays)",
		},
		{
			type = "divider",
		},
		{
			type = "checkbox",
			name = "Show Target Health",
			tooltip = "Displays the current target's health as a percentage next to the reticle",
			getFunc = function() return sam.savedVars.modules.targetHealth.show end,
			setFunc = function(value) sam.savedVars.modules.targetHealth.show = value end,
		},
	}

	local moduleOptions = {
		{
			type = "divider",
		},
		{
			type = "description",
			text = "Individual module options will be accessible here as more are added",
		},
		{
			type = "header",
			name = "Module Options",
		},
		{
			type = "submenu",
			name = "Potions",
			controls = potionOptions, 
		},
		{
			type = "submenu",
			name = "Target Health",
			controls = targetHealthOptions,
		},
	}

	LAM:RegisterOptionControls(sam.name.."GeneralOptions", generalOptions)
	LAM:RegisterOptionControls(sam.name.."ModuleOptions", moduleOptions)
end
