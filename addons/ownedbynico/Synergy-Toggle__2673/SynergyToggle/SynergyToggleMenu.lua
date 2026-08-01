SynergyToggle = SynergyToggle or {}
local ST = SynergyToggle

function ST.InitAddonMenu()
	local panelData = {
		type = "panel",
		name = "Synergy Toggle",
		displayName = "Synergy Toggle",
		author = "ownedbynico, helixanon",
		version = ST.version,
		slashCommand = "/synergy",
		registerForRefresh = true,
	}
	
	local optionData = {}
	optionData[#optionData+1] = {
		type = "header",
		name = "General",
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "|t35:35:/esoui/art/icons/sigil_power_001.dds|t Maelstrom Arena & Blackrose Prison Sigils",
		getFunc = function() return ST.savedVariables.general_arenaSigils end,
		setFunc = function(value)
					ST.savedVariables.general_arenaSigils = value
					ST.synergies["/esoui/art/icons/sigil_defense_001.dds"] = value
					ST.synergies["/esoui/art/icons/sigil_healing_001.dds"] = value
					ST.synergies["/esoui/art/icons/sigil_speed_001.dds"] = value
					ST.synergies["/esoui/art/icons/sigil_power_001.dds"] = value
				  end,
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "|t35:35:/esoui/art/icons/ability_sorcerer_065.dds|t Destructive Outbreak (Hel Ra Citadel HM)",
		getFunc = function() return ST.savedVariables.general_destructiveOutbreak end,
		setFunc = function(value) ST.savedVariables.general_destructiveOutbreak = value end,
		tooltip = "Adds a confirmation you have to accept if you want to break out.",
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "|t35:35:/esoui/art/icons/death_recap_cold_aoe2.dds|t Surging Waters (Dreadsail Reef)",
		getFunc = function() return ST.savedVariables.general_surgingWaters end,
		setFunc = function(value) ST.savedVariables.general_surgingWaters = value end,
		tooltip = "Adds a confirmation you have to accept if you want to go up.",
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "|t35:35:/esoui/art/icons/collectible_memento_pearlsummon.dds|t Cloudrest Portal (Dont Portal Twice)",
		getFunc = function() return ST.savedVariables.general_cloudrestPortalDebuff end,
		setFunc = function(value) ST.savedVariables.general_cloudrestPortalDebuff = value end,
		tooltip = "Blocks the synergy if you have the debuff from previous portal and would die to it.",
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "|t35:35:/esoui/art/icons/ability_necromancer_016.dds|t Execration (Kyne's Aegis HM)",
		getFunc = function() return ST.savedVariables.general_execration end,
		setFunc = function(value)
					ST.savedVariables.general_execration = value
					ST.synergies["/esoui/art/icons/ability_necromancer_016.dds"] = value
				  end,
		tooltip = "Disables the synergy in Kyne's Aegis endboss fight where you would harm yourself.",
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "|t35:35:/esoui/art/icons/malatar_agonizingbolts.dds|t Conjurer's Portal (Kyne's Aegis)",
		getFunc = function() return ST.savedVariables.general_conjurersPortal end,
		setFunc = function(value) ST.savedVariables.general_conjurersPortal = value end,
		tooltip = "Disables the portal in Kyne's Aegis where you would get teleported to the ship at the fight against Captain Vrol.",
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "|t35:35:/esoui/art/icons/achievement_murkmire_kill_voriplasm.dds|t Purge Soul (Rockgrove)",
		getFunc = function() return ST.savedVariables.general_purgeSoul end,
		setFunc = function(value) ST.savedVariables.general_purgeSoul = value end,
		tooltip = "Blocks the blob synergy for Xms and notifies you to move outside the group.",
		width = "half",
	}
	optionData[#optionData+1] = {
		type = "slider",
		name = "ms Blocktime",
		getFunc = function() return ST.savedVariables.general_purgeSoul_cooldown end,
		setFunc = function(value) ST.savedVariables.general_purgeSoul_cooldown = value end,
		min = 0,
		max = 5000,
		default = 2000,
		step = 100,
		width = "half",
	}
	optionData[#optionData+1] = {
		type = "header",
		name = "Damage Dealer",
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "|t35:35:/esoui/art/icons/ability_sorcerer_lightning_splash.dds|t Conduit",
		getFunc = function() return ST.savedVariables.dd_conduit end,
		setFunc = function(value)
					ST.savedVariables.dd_conduit = value
					ST.synergies["/esoui/art/icons/ability_sorcerer_lightning_splash.dds"] = value
				  end,
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "|t35:35:/esoui/art/icons/ability_warden_007.dds|t Harvest",
		getFunc = function() return ST.savedVariables.dd_harvest end,
		setFunc = function(value)
					ST.savedVariables.dd_harvest = value
					ST.synergies["/esoui/art/icons/ability_warden_007.dds"] = value
				  end,
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "|t35:35:/esoui/art/icons/ability_necromancer_004.dds|t Grave",
		getFunc = function() return ST.savedVariables.dd_grave end,
		setFunc = function(value)
					ST.savedVariables.dd_grave = value
					ST.synergies["/esoui/art/icons/ability_necromancer_004.dds"] = value
				  end,
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "|t35:35:/esoui/art/icons/ability_necromancer_010_b.dds|t Agony",
		getFunc = function() return ST.savedVariables.dd_agony end,
		setFunc = function(value)
					ST.savedVariables.dd_agony = value
					ST.synergies["/esoui/art/icons/ability_necromancer_010_b.dds"] = value
				  end,
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "|t35:35:/esoui/art/icons/ability_templar_sun_strike.dds|t Blessed Shards",
		getFunc = function() return ST.savedVariables.dd_shards end,
		setFunc = function(value)
					ST.savedVariables.dd_shards = value
					ST.synergies["/esoui/art/icons/ability_templar_sun_strike.dds"] = value
				  end,
		tooltip = "Blocks only the healer morph.",
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "|t35:35:/esoui/art/icons/ability_templar_cleansing_ritual.dds|t Ritual",
		getFunc = function() return ST.savedVariables.dd_ritual end,
		setFunc = function(value)
					ST.savedVariables.dd_ritual = value
					ST.synergies["/esoui/art/icons/ability_templar_cleansing_ritual.dds"] = value
				  end,
		tooltip = "Useful for the Plaguebreak set.\nBlocks base skill and both morphs.",
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "|t35:35:/esoui/art/icons/ability_u23_bloodball_chokeonit.dds|t Lady Thorn",
		getFunc = function() return ST.savedVariables.dd_ladythorn end,
		setFunc = function(value)
					ST.savedVariables.dd_ladythorn = value
					ST.synergies["/esoui/art/icons/ability_u23_bloodball_chokeonit.dds"] = value
				  end,
		tooltip = "Blocks the Sanguine Burst synergy.",
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "|t35:35:/esoui/art/icons/ability_arcanist_004.dds|t Runebreak",
		getFunc = function() return ST.savedVariables.dd_runebreak end,
		setFunc = function(value)
					ST.savedVariables.dd_runebreak = value
					ST.synergies["/esoui/art/icons/ability_arcanist_004.dds"] = value
				  end,
		tooltip = "Blocks the Runebreak synergy.",
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "Lokkestiiz Mode",
		getFunc = function() return ST.savedVariables.dd_lokkestiizMode end,
		setFunc = function(value) ST.savedVariables.dd_lokkestiizMode = value end,
		tooltip = "Disables (non important) synergies while having the Major Slayer buff. You will only be able to use synergies if the 5th set bonus is active (e.g not on your bow backbar). If you drop below 20% stamina you are able to take synergies.",
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "Moondancer Mode",
		getFunc = function() return ST.savedVariables.dd_moondancerMode end,
		setFunc = function(value) ST.savedVariables.dd_moondancerMode = value end,
		tooltip = "Disables (non important) synergies while having the Shadow Blessing buff. You will only be able to use synergies if the 5th set bonus is active (e.g not on your bow backbar).",
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "Kinra's Mode",
		getFunc = function() return ST.savedVariables.dd_kinrasMode end,
		setFunc = function(value) ST.savedVariables.dd_kinrasMode = value end,
		tooltip = "Disables the Sorcerer Atronach synergy while having the Major Berserk buff. Also works for Unchained Aggressor, Heem-Jas' Retribution and Sithis' Touch.",
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "Martial Knowledge Mode",
		getFunc = function() return ST.savedVariables.dd_martialknowledgemode end,
		setFunc = function(value) ST.savedVariables.dd_martialknowledgemode = value end,
		tooltip = "Disables orbs and templar shards while having more than 30% stamina.",
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "Bahsei's / Pearls Mode",
		getFunc = function() return ST.savedVariables.dd_bahseisMode end,
		setFunc = function(value) ST.savedVariables.dd_bahseisMode = value end,
		tooltip = "Disables orbs and templar shards while having more than X% magicka.",
		width = "half",
	}
	optionData[#optionData+1] = {
		type = "slider",
		name = "% Magicka",
		getFunc = function() return ST.savedVariables.dd_bahseisMode_magicka end,
		setFunc = function(value) ST.savedVariables.dd_bahseisMode_magicka = value end,
		min = 0,
		max = 100,
		default = 20,
		width = "half",
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "Coral Riptide Mode",
		getFunc = function() return ST.savedVariables.dd_coralriptideMode end,
		setFunc = function(value) ST.savedVariables.dd_coralriptideMode = value end,
		tooltip = "Disables orbs and templar shards while having more than X% stamina.",
		width = "half",
	}
	optionData[#optionData+1] = {
		type = "slider",
		name = "% Stamina",
		getFunc = function() return ST.savedVariables.dd_coralriptideMode_stamina end,
		setFunc = function(value) ST.savedVariables.dd_coralriptideMode_stamina = value end,
		min = 0,
		max = 100,
		default = 20,
		width = "half",
	}
	optionData[#optionData+1] = {
		type = "description",
		title = "",
		text = "If you are playing with Alkosh you can enable \"Alkosh Mode\" in the tank section. It will also work for damage dealers.",
	}
	
	optionData[#optionData+1] = {
		type = "header",
		name = "Tank",
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "|t35:35:/esoui/art/icons/ability_sorcerer_storm_atronach.dds|t Charged Lightning (Atronach)",
		getFunc = function() return ST.savedVariables.tank_atronarch end,
		setFunc = function(value)
					ST.savedVariables.tank_atronarch = value
					ST.synergies["/esoui/art/icons/ability_sorcerer_storm_atronach.dds"] = value
				  end,
		tooltip = "Disables the Sorcerer Atronach to prevent you from stealing the damage buff.",
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "|t35:35:/esoui/art/icons/ability_nightblade_015.dds|t Hidden Refresh (Nightblade Ultimate)",
		getFunc = function() return ST.savedVariables.tank_nbshadowult end,
		setFunc = function(value)
					ST.savedVariables.tank_nbshadowult = value
					ST.synergies["/esoui/art/icons/ability_nightblade_015.dds"] = value
				  end,
		tooltip = "Disables the nightblade ultimate so you will not get invisible.",
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "Alkosh Mode",
		getFunc = function() return ST.savedVariables.tank_alkoshMode end,
		setFunc = function(value)
					ST.savedVariables.tank_alkoshMode = value
					if value == true then
						EVENT_MANAGER:RegisterForEvent(ST.name, EVENT_RETICLE_TARGET_CHANGED, ST.OnReticleTargetChanged)
					else
						EVENT_MANAGER:UnregisterForEvent(ST.name, EVENT_RETICLE_TARGET_CHANGED)
						EVENT_MANAGER:UnregisterForUpdate(ST.name .. "AlkoshUpdateLoop")
					end
				  end,
		tooltip = "Disables all synergies if the boss you are looking at has Alkosh applied. If you drop below 20% stamina you are able to take synergies.",
	}
	
	optionData[#optionData+1] = {
		type = "header",
		name = "Healer",
	}
	optionData[#optionData+1] = {
		type = "checkbox",
		name = "|t35:35:/esoui/art/icons/collectible_memento_pearlsummon.dds|t Cloudrest Portal (Entirely)",
		getFunc = function() return ST.savedVariables.healer_cloudrestPortalEntirely end,
		setFunc = function(value)
					ST.savedVariables.healer_cloudrestPortalEntirely = value
					ST.synergies["/esoui/art/icons/collectible_memento_pearlsummon.dds"] = value
				  end,
		tooltip = "Disables the Cloudrest Portal Synergy entirely.",
	}
	
	local miscData = {}
	miscData[#miscData+1] = {
		type = "checkbox",
		name = "|t35:35:/esoui/art/icons/ability_warden_005_b.dds|t Warden Portal",
		getFunc = function() return ST.savedVariables.misc_wardenPortal end,
		setFunc = function(value)
					ST.savedVariables.misc_wardenPortal = value
					ST.synergies["/esoui/art/icons/ability_warden_005_b.dds"] = value
				  end,
	}
	miscData[#miscData+1] = {
		type = "checkbox",
		name = "|t35:35:/esoui/art/icons/ability_arcanist_016_b.dds|t Passage",
		getFunc = function() return ST.savedVariables.misc_passage end,
		setFunc = function(value)
					ST.savedVariables.misc_passage = value
					ST.synergies["/esoui/art/icons/ability_arcanist_016_b.dds"] = value
				  end,
	}
	miscData[#miscData+1] = {
		type = "checkbox",
		name = "|t35:35:/esoui/art/icons/ability_u26_vampire_synergy_feed.dds|t Vampire Bite",
		getFunc = function() return ST.savedVariables.misc_vampirebite end,
		setFunc = function(value)
					ST.savedVariables.misc_vampirebite = value
					ST.synergies["/esoui/art/icons/ability_u26_vampire_synergy_feed.dds"] = value
				  end,
	}
	miscData[#miscData+1] = {
		type = "checkbox",
		name = "|t35:35:/esoui/art/icons/achievement_darkbrotherhood_003.dds|t Blade of Woe",
		getFunc = function() return ST.savedVariables.misc_bladeofwoe end,
		setFunc = function(value)
					ST.savedVariables.misc_bladeofwoe = value
					ST.synergies["/esoui/art/icons/achievement_darkbrotherhood_003.dds"] = value
				  end,
	}
	miscData[#miscData+1] = {
		type = "checkbox",
		name = "Debug",
		getFunc = function() return ST.savedVariables.debug end,
		setFunc = function(value) ST.savedVariables.debug = value end,
		tooltip = "Dumps all synergy names and icons into the chat.",
	}
	optionData[#optionData+1] = {
		type = "submenu",
		name = "Miscellaneous",
		controls = miscData,
	}
	
	LibAddonMenu2:RegisterAddonPanel("STS", panelData)
	LibAddonMenu2:RegisterOptionControls("STS", optionData)
end
