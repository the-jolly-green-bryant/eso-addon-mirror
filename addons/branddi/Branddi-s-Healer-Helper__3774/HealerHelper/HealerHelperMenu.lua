HealerHelper = HealerHelper or { }
local HealerHelper = HealerHelper
local fontsDefined = LibMediaProvider:List('font')

local sounds = {
    "Justice_PickpocketFailed",
    "Dialog_Decline",
    "Ability_Ultimate_Ready_Sound",
    "Quest_Shared",
    "Champion_PointsCommitted",
    "GroupElection_Requested",
    "Duel_Boundary_Warning",
}




function HealerHelper.setupMenu()
	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = "Branddi's Healer Helper",
		displayName = "|cff2424B|r|cff4949r|r|cff6d6da|r|cff9292n|r|cffb6b6d|r|cffdbdbd|r|cffffffi|r's Healer Helper",
		author = "Branddi",
		website = "https://www.esoui.com/downloads/fileinfo.php?id=3774",
		feedback = "https://www.esoui.com/downloads/fileinfo.php?id=3774",
		version = ""..HealerHelper.version,
		registerForRefresh = true
	}

	LAM:RegisterAddonPanel(HealerHelper.name.."Options", panelData)

	local options = {}

	table.insert (options,{
		type = "description",
		title = nil,
		text = "For detailed instructions including images and combat examples please click on the 'Visit Website' link above.",
		width = "full",	--or "half" (optional)
	})

	table.insert (options,{
		type = "description",
		title = "Special Thanks",
		text = "Epic healer @Galini99 as primary contributor, feature designer, and quality assurance.",
		width = "full",	--or "half" (optional)
	})

	table.insert (options,{
		type = "description",
		title = nil,
		text = "This addon is an attempt to help healers through the gauntlet of assumptions, misunderstanding and misinformation that is ESO PVE Healing.  Intended to be used with PVE healing, off-healing, dungeons and trials. Some settings will need to be tweaked if used in situations where you intentionally are not wearing supportive sets, or skill morphs.",
		width = "full",	--or "half" (optional)
	})




	table.insert (options,{
		type = "header",
		name = "Fake DPS / Fake Tank"
	})

	table.insert (options,{
		type = "checkbox",
		name = "Enable when marked DPS / Tank",
		tooltip = "(default OFF) Addon will only turn on when marked as healer unless this setting is ON. Reloading will reset this setting back to OFF.  Getting bored of fake healing? Try fake DPS.",
		getFunc = function() return HealerHelper.forceEnable end,
		setFunc = function(value)
			if not value then
				HealerHelper.forceEnable = false
				HealerHelper.checkIfAddonNeedsToBeLoadedOrUnloaded()
			else
				HealerHelper.forceEnable = true
				HealerHelper.checkIfAddonNeedsToBeLoadedOrUnloaded()
			end
		end
	})


	table.insert (options,{
		type = "header",
		name = "Settings"
	})
	table.insert (options,{
		type = "checkbox",
		name = "Account Wide",
		tooltip = "Use account wide settings",
		getFunc = function() return HealerHelper.savedVars.global end,
		setFunc = function(value)
			if HealerHelper.savedVars.global== value then return end

			if value then
				HealerHelper.savedVars.global = true
				HealerHelper.savedVars = ZO_SavedVars:NewAccountWide(HealerHelper.name.."SavedVars",  HealerHelper.varVersion, nil, HealerHelper.defaults)
				HealerHelper.savedVars.global = true
			else
				HealerHelper.savedVars = ZO_SavedVars:NewCharacterIdSettings(HealerHelper.name.."SavedVars",  HealerHelper.varVersion, nil, HealerHelper.defaults)
				HealerHelper.savedVars.global = false
			end
			HealerHelper.savedVars.global = value

			HealerHelper.adjustFrameLocation()
		end
	})


	table.insert (options,{
		type = "header",
		name = "UI Positioning"
	})


		table.insert (options,{
			type = "description",
			title = "Important",	--(optional)
			text = "HUD requires |cff2424Fancy Action Bar|r addon with Static bar positions - ON (default setting)",
			width = "full",	--or "half" (optional)
		})


	--table.insert (options,{
	--	type = "description",
	--	title = nil,	--(optional)
	--	text = "Use custom ESO UI such as Bandits User Interface to move the Action Bar up from the edge of your screen to make room for the Healer Helper HUD indicators.",
	--	width = "full",	--or "half" (optional)
	--})


	table.insert (options,{
		type = "description",
		title = nil,	--(optional)
		text = "Use this button to move the Heavy Attack indicator, Combat messages, Build messages and see the HUD while adjusting your Action Bar using Bandits UI",
		width = "full",	--or "half" (optional)
	})


	table.insert (options,{
		type = "button",
		name = "Show/Hide UI",
		func = function() HealerHelper.showUI() end,
		width = "full"

	})

	table.insert (options,{
		type = "header",
		name = "Action Bar HUD"
	})
	table.insert (options,{
		type = "description",
		title = nil,	--(optional)
		text = "The HUD (Heads Up Display) is a graphical way to represent the status of your skills.  Since your goal as a healer is to keep the majority of your skills up at all times, this skill bar HUD provides the player with a simple way to tell the status of their skills and which need to be cast.",
		width = "full",	--or "half" (optional)
	})

		table.insert (options,{
			type = "description",
			title = nil,	--(optional)
			text = "The goal of the HUD is to provide a simple way to rotate through all their skills. Think 'Whac-A-Mole' (TM) 1975.",
			width = "full",	--or "half" (optional)
		})

	if FancyActionBar == nil  then
		table.insert (options,{
			type = "checkbox",
			name = "Enable HUD without |cff2424FAB|r (not recommended)",
			tooltip = "(DEFAULT OFF) Reload Required.  Should you choose to use the HUD feature without Fancy Action Bar, the icons will point to the top and bottom of the skills on your current bar.  This is much less intuitive, but the option is available.",
			getFunc = function() return HealerHelper.savedVars.enableHudWithoutFancyActionBar end,
			setFunc = function(value)
				HealerHelper.savedVars.enableHudWithoutFancyActionBar = value
				ReloadUI()
			end
		})
	end

	if FancyActionBar == nil and HealerHelper.savedVars.enableHudWithoutFancyActionBar == false then
		table.insert (options,
				{
					type = "description",
					title = nil,	--(optional)
					text = "Required addon |cff2424Fancy Action Bar|r missing.  Please install to enable this feature.",
					width = "full",	--or "half" (optional)
				})



	else
		table.insert (options,{
			type = "checkbox",
			name = "Display Action Bar HUD",
			tooltip = "(DEFAULT ON) Required Fancy Action Bar addon, if you do not wish to use HUD or Fancy Action Bar, turn off this setting. Will also disable the warning about installing Fancy Action Bar.",
			getFunc = function() return HealerHelper.savedVars.enableHud end,
			setFunc = function(value)
				HealerHelper.savedVars.enableHud = value
			end
		})





		table.insert (options,{
			type = "checkbox",
			name = "Yellow dot for DOTs/HOTs ready for cast",
			tooltip = "(DEFAULT ON) Show skill is waiting for you to cast it.",
			getFunc = function() return HealerHelper.savedVars.showYellowforOffCooldownSkills end,
			setFunc = function(value)
				if not value then
					HealerHelper.savedVars.showYellowforOffCooldownSkills = false
				else
					HealerHelper.savedVars.showYellowforOffCooldownSkills = true
				end
			end
		})

		--[[
		table.insert (options,{
			type = "checkbox",
			name = "Are hotkeys visible under action bar?",
			tooltip = "(DEFAULT OFF) Recommended to turn these off following the installation instructions on the website link listed above.  However, if you wish to leave them on turn this option ON.",
			getFunc = function() return HealerHelper.savedVars.hotkeysUnderActonBar end,
			setFunc = function(value)
				HealerHelper.savedVars.hotkeysUnderActonBar = value
			end
		}) --]]





	end
	table.insert (options,{
		type = "header",
		name = "Combat Messages"
	})


	table.insert (options,{
		type = "description",
		title = nil,
		text = "Combat messages are used in combat for real-time feedback about useful actions that will improve your gameplay.  Example: Spaulder needs to be enabled.",
		width = "full",	--or "half" (optional)
	})


		table.insert (options,{
		type = "slider",
		name = "Combat Message font size",
		tooltip = "(DEFAULT 18)",
		min = 14,
		max = 36,
		step = 2,
		getFunc = function() return HealerHelper.savedVars.fontSizeCombatMessage end,
		setFunc = function(value)
			HealerHelper.savedVars.fontSizeCombatMessage = value
			HealerHelper.adjustFrameLocation()
		end,
	})


	table.insert (options,{
            type = "dropdown",
            name = "Combat Message font style",
            tooltip = "(default Univers 57)",
            choices = fontsDefined,
            width = "full",
            getFunc = function() return HealerHelper.savedVars.fontCombatMessage end, --TauntHelper.savedVars.fontTauntBars end,
            setFunc = function(choice)
                HealerHelper.savedVars.fontCombatMessage = choice
                HealerHelper.adjustFrameLocation()
            end,
            scrollable = true,
        })


	table.insert (options,{
			type = "colorpicker",
			name = "Combat Message Color",
			tooltip = "Color for all combat messages",
			getFunc = function() return unpack(HealerHelper.savedVars.fontColorCombatMessage) end,
			setFunc = function(r,g,b,a)
				HealerHelper.savedVars.fontColorCombatMessage = {r,g,b,1}
				HealerHelper.adjustFrameLocation()
			end,
		})



		table.insert (options,{
		type = "header",
		name = "Build Messages"
	})

		table.insert (options,{
		type = "description",
		title = nil,
		text = "Build messages are things that you typically cannot do anything about in combat, for example your gear set bonuses are missing (perhaps due to a gear swap error, or build error)",
		width = "full",	--or "half" (optional)
	})


		table.insert (options,{
		type = "slider",
		name = "Build Message font size",
		tooltip = "(DEFAULT 18)",
		min = 14,
		max = 36,
		step = 2,
		getFunc = function() return HealerHelper.savedVars.fontSizeBuildMessage end,
		setFunc = function(value)
			HealerHelper.savedVars.fontSizeBuildMessage = value
			HealerHelper.adjustFrameLocation()
		end,
	})


	table.insert (options,{
            type = "dropdown",
            name = "Build Message font style",
            tooltip = "(default Univers 57)",
            choices = fontsDefined,
            width = "full",
            getFunc = function() return HealerHelper.savedVars.fontBuildMessage end, --TauntHelper.savedVars.fontTauntBars end,
            setFunc = function(choice)
                HealerHelper.savedVars.fontBuildMessage = choice
                HealerHelper.adjustFrameLocation()
            end,
            scrollable = true,
        })


	table.insert (options,{
			type = "colorpicker",
			name = "Build Message Color",
			tooltip = "Color for all combat messages",
			getFunc = function() return unpack(HealerHelper.savedVars.fontColorBuildMessage) end,
			setFunc = function(r,g,b,a)
				HealerHelper.savedVars.fontColorBuildMessage = {r,g,b,1}
				HealerHelper.adjustFrameLocation()
			end,
		})





	table.insert (options,{
		type = "header",
		name = "Potions"
	})

	if FancyActionBar == nil and HealerHelper.savedVars.enableHudWithoutFancyActionBar == false then
		table.insert (options,
				{
					type = "description",
					title = nil,	--(optional)
					text = "Required addon: |cff2424Fancy Action Bar|r missing.  Please install to enable this feature.",
					width = "full",	--or "half" (optional)
				})
	else
		table.insert (options,{
			type = "checkbox",
			name = "Drink Potion reminder",
			tooltip = "(DEFAULT ON) Put an icon above your potion slot to remind you to drink",
			getFunc = function() return HealerHelper.savedVars.enablePotionReminder end,
			setFunc = function(value)
				HealerHelper.savedVars.enablePotionReminder = value
			end
		})
	end

	table.insert (options,{
		type = "header",
		name = "Pillagers & Pearls"
	})

	if FancyActionBar == nil and HealerHelper.savedVars.enableHudWithoutFancyActionBar == false then
		table.insert (options,
				{
					type = "description",
					title = nil,	--(optional)
					text = "Required addon: |cff2424Fancy Action Bar|r missing.  Please install to enable this feature.",
					width = "full",	--or "half" (optional)
				})
	else

		table.insert (options,{
			type = "checkbox",
			name = "Enable magicka micromanagement",
			tooltip = "(DEFAULT ON) Should the addon attempt to recommend skills to assist in keeping mag low for Pearls?",
			getFunc = function() return  HealerHelper.savedVars.pillagersPearlsEnable end,
			setFunc = function(value)
				HealerHelper.savedVars.pillagersPearlsEnable = value
			end
		})

		table.insert (options,{
			type = "slider",
			name = "Mag percentage",
			tooltip = "(DEFAULT 35) Mag percentage over this will not recommend Potions, Blue Betty, Siphoning Attacks, Channeled Focus",
			min = 10,
			max = 75,
			step = 1,
			getFunc = function() return HealerHelper.savedVars.pillagersPearlsMagTarget end,
			setFunc = function(value)
				HealerHelper.savedVars.pillagersPearlsMagTarget= value
			end,
		})

		table.insert (options,{
			type = "slider",
			name = "Pillagers recommended Ultimate",
			tooltip = "(DEFAULT 375) Recommend Pillager ultimate when reaching this amount.  Note also considered the cost of your ultimate and will only recommend when that threadhshold is reached",
			min = 1,
			max = 400,
			step = 1,
			getFunc = function() return HealerHelper.savedVars.recommendPillagersAtUlt end,
			setFunc = function(value)
				HealerHelper.savedVars.recommendPillagersAtUlt = value
			end,
		})
		table.insert (options,{
			type = "checkbox",
			name = "Nightblade drink on cooldown",
			tooltip = "(DEFAULT ON) When PP/Pearls on nightblade recommend potions on cooldown for ultimate generation",
			getFunc = function() return  HealerHelper.savedVars.pillagersPearlsNightbladeForcePotions end,
			setFunc = function(value)
				HealerHelper.savedVars.pillagersPearlsNightbladeForcePotions = value
			end
		})

		--

	end


	table.insert (options,{
		type = "header",
		name = "Roaring Opportunist / Archdruid"
	})

	table.insert (options,{
		type = "checkbox",
		name = "Show Heavy Attack indicator",
		tooltip = "(DEFAULT ON) Put an HA indicator up when Heavy Attack set (RO/Archdruid) requires proc",
		getFunc = function() return HealerHelper.savedVars.displayHeavyAttack end,
		setFunc = function(value)
			HealerHelper.savedVars.displayHeavyAttack = value
		end
	})


	table.insert (options,{
		type = "checkbox",
		name = "Wrong bar Heavy Attack warning",
		tooltip = "(DEFAULT ON) warns if you heavy attack on the wrong bar for RO",
		getFunc = function() return HealerHelper.savedVars.wrongBarHeavyAttackWarnings end,
		setFunc = function(value)
			HealerHelper.savedVars.wrongBarHeavyAttackWarnings = value
		end
	})

	table.insert (options,{
		type = "slider",
		name = "Heavy Attack indicator font size",
		tooltip = "(DEFAULT 36)",
		min = 14,
		max = 48,
		step = 1,
		getFunc = function() return HealerHelper.savedVars.fontSizeHeavyAttack end,
		setFunc = function(value)
			HealerHelper.savedVars.fontSizeHeavyAttack= value
		end,
	})




	table.insert (options,{
		type = "slider",
		name = "Targets in trials",
		tooltip = "(DEFAULT 2) Minimum number of targets to request RO (warning if using a large number and excluding healers and tanks may cause RO to not be requested under certain situations)",
		min = 1,
		max = 6,
		step = 1,
		getFunc = function() return HealerHelper.savedVars.minimumRojoTargetsTrials end,
		setFunc = function(value)
			HealerHelper.HealerHelper.minimumRojoTargetsTrials = value
		end,
	})

	table.insert (options,{
		type = "slider",
		name = "Targets in dungeons",
		tooltip = "(DEFAULT 1) Minimum number of targets to request RO (warning if using a large number and excluding healers and tanks may cause RO to not be requested under certain situations)",
		min = 1,
		max = 4,
		step = 1,
		getFunc = function() return HealerHelper.savedVars.minimumRojoTargetsDungeons end,
		setFunc = function(value)
			HealerHelper.HealerHelper.minimumRojoTargetsDungeons = value
		end,
	})


	table.insert (options,{
		type = "checkbox",
		name = "Tanks included",
		tooltip = "(DEFAULT OFF) Determine if tanks are included in searching for targets to apply RO to",
		getFunc = function() return HealerHelper.savedVars.tanksIncludedInRojoTargets end,
		setFunc = function(value)
			HealerHelper.savedVars.tanksIncludedInRojoTargets= value
		end
	})

	table.insert (options,{
		type = "checkbox",
		name = "Healers included",
		tooltip = "(DEFAULT OFF) Determine if healers are included in searching for targets to apply RO to",
		getFunc = function() return HealerHelper.savedVars.healersIncludedInRojoTargets end,
		setFunc = function(value)
			HealerHelper.savedVars.healersIncludedInRojoTargets= value
		end
	})



	table.insert (options,{
		type = "checkbox",
		name = "ROJO low duration warning",
		tooltip = "(DEFAULT ON) Warning when insufficient mag/spell damage when activating ROJO. The root problem can be any of these, wrong enchants on body, jewlery, missing buffs (from others in trial group, or self buffs from skills/pots). Turn off to disable warnings related to the length off ROJO procs.  Only active when both RO and JO are equipped.",
		getFunc = function() return HealerHelper.savedVars.RojoProcWarning end,
		setFunc = function(value)
			HealerHelper.savedVars.RojoProcWarning= value
		end
	})


	table.insert (options,{
		type = "slider",
		name = "ROJO duration warning % of 16.8s",
		tooltip = "(DEFAULT 100) If you do not have enough mag and spell damage your ROJO procs will be short causing a decrease major slayer uptimes even if ROJO HA are perfectly timed.  This is the setting to set the threshold for the warning.  The max ROJO proc time is 16.8s, you can adjust the percentage of this value to trigger warnings incase you are unable to reach max length.",
		min = 80,
		max = 100,
		step = 5,
		getFunc = function() return (HealerHelper.savedVars.RojoProcWarningDuration/16.8)*100 end,
		setFunc = function(value)
			HealerHelper.savedVars.RojoProcWarningDuration = (value/100)*16.8
		end,
	})




	table.insert (options,{
			type = "checkbox",
			name = "Audible Roaring Opportunist warning",
			tooltip = "(DEFAULT OFF) If you want to enable Audible warning when ROJO should start a new heavy attack",
			getFunc = function() return HealerHelper.savedVars.audibleRojo end,
			setFunc = function(value)
				HealerHelper.savedVars.audibleRojo = value
			end
		})


		table.insert (options,{
            type = "dropdown",
            name = "Roaring Opportunist Sound Effect",
			tooltip = "(DEFAULT GroupElection_Requested) Select the sound effect to play when ROJO should be cast",
            choices = sounds,
            getFunc = function() return HealerHelper.savedVars.audibleRojoSoundEffect end,
            setFunc = function(value)
                HealerHelper.savedVars.audibleRojoSoundEffect = value
                PlaySound(value)
            end,
        })


	table.insert (options,{
		type = "header",
		name = "Powerful Assault"
	})
	if FancyActionBar == nil and HealerHelper.savedVars.enableHudWithoutFancyActionBar == false then
		table.insert (options,
				{
					type = "description",
					title = nil,	--(optional)
					text = "Required addon: |cff2424Fancy Action Bar|r missing.  Please install to enable this feature.",
					width = "full",	--or "half" (optional)
				})
	else

		table.insert (options,{
			type = "checkbox",
			name = "Enable Powerful Assault",
			tooltip = "(DEFAULT ON) Turn off if you do not want warnings and suggestions regarding Powerful Assault",
			getFunc = function() return HealerHelper.savedVars.powerfulAssaultEnabled end,
			setFunc = function(value)
				HealerHelper.savedVars.powerfulAssaultEnabled = value
			end
		})

		table.insert (options,{
			type = "slider",
			name = "Targets in trials",
			tooltip = "(DEFAULT 2) Minimum number of targets to request PA (warning if using a large number and excluding healers and tanks may cause PA to not be requested under certain situations)",
			min = 1,
			max = 6,
			step = 1,
			getFunc = function() return HealerHelper.savedVars.minimumPaTargetsTrials end,
			setFunc = function(value)
				HealerHelper.HealerHelper.minimumPaTargetsTrials = value
			end,
		})

		table.insert (options,{
			type = "slider",
			name = "Targets in dungeons",
			tooltip = "(DEFAULT 1) Minimum number of targets to request PA (warning if using a large number and excluding healers and tanks may cause PA to not be requested under certain situations)",
			min = 1,
			max = 4,
			step = 1,
			getFunc = function() return HealerHelper.savedVars.minimumPaTargetsDungeons end,
			setFunc = function(value)
				HealerHelper.HealerHelper.minimumPaTargetsDungeons = value
			end,
		})


		table.insert (options,{
			type = "checkbox",
			name = "Tanks included",
			tooltip = "(DEFAULT OFF) Determine if tanks are included in searching for targets to apply PA to",
			getFunc = function() return HealerHelper.savedVars.tanksIncludedInPaTargets end,
			setFunc = function(value)
				HealerHelper.savedVars.tanksIncludedInPaTargets= value
			end
		})
		table.insert (options,{
			type = "checkbox",
			name = "Healers included",
			tooltip = "(DEFAULT OFF) Determine if healers are included in searching for targets to apply RO to",
			getFunc = function() return HealerHelper.savedVars.healersIncludedInPaTargets end,
			setFunc = function(value)
				HealerHelper.savedVars.healersIncludedInPaTargets= value
			end
		})


	end


	table.insert (options,{
		type = "header",
		name = "Olorime"
	})
	if FancyActionBar == nil and HealerHelper.savedVars.enableHudWithoutFancyActionBar == false then
		table.insert (options,
				{
					type = "description",
					title = nil,	--(optional)
					text = "Required addon: |cff2424Fancy Action Bar|r missing.  Please install to enable this feature.",
					width = "full",	--or "half" (optional)
				})
	else

		table.insert (options,{
			type = "checkbox",
			name = "Enable Olorime",
			tooltip = "(DEFAULT ON) Suggests a skill to proc Olorime when ready for proc.",
			getFunc = function() return HealerHelper.savedVars.olorimeEnabled end,
			setFunc = function(value)
				HealerHelper.savedVars.olorimeEnabled = value
			end
		})


	end

	table.insert (options,{
		type = "header",
		name = "Trauma"
	})
	table.insert (options,{
		type = "checkbox",
		name = "Trauma Warning",
		tooltip = "(DEFAULT ON) Lets you know when someone in group has Trauma (healing absorption) such as vCA last boss, vSE first boss, vSE trash, vDSR first boss",
		getFunc = function() return HealerHelper.savedVars.traumaEnabled end,
		setFunc = function(value)
			HealerHelper.savedVars.traumaEnabled = value
		end
	})


	table.insert (options,{
		type = "header",
		name = "Ultimate Generation"
	})
	table.insert (options,{
		type = "checkbox",
		name = "Show Light Attack reminder for ultimate generation",
		tooltip = "(DEFAULT ON)",
		getFunc = function() return HealerHelper.savedVars.displayLightAttackUltigen end,
		setFunc = function(value)
			HealerHelper.savedVars.displayLightAttackUltigen = value
		end
	})

	table.insert (options,{
		type = "slider",
		name = "Light Attack indicator font size",
		tooltip = "(DEFAULT 24)",
		min = 14,
		max = 48,
		step = 1,
		getFunc = function() return HealerHelper.savedVars.fontSizeLightAttackUltigen end,
		setFunc = function(value)
			HealerHelper.savedVars.fontSizeLightAttackUltigen= value
		end,
	})


	table.insert (options,{
		type = "header",
		name = "Heavy Attacking"
	})
	table.insert (options,{
		type = "checkbox",
		name = "Unnecessary Heavy Attack Warning",
		tooltip = "(DEFAULT ON) Warn when heavy attacking when resources are high.  Heavy Attacking does practically no damage on a healer, and has negligible value compared to continuing the 'Whac-A-Mole' game.",
		getFunc = function() return HealerHelper.savedVars.unnecessaryHeavyAttackWarnings end,
		setFunc = function(value)
			HealerHelper.savedVars.unnecessaryHeavyAttackWarnings = value
		end
	})
	table.insert (options,{
		type = "slider",
		name = "Unnecessary Resource Threshold in %",
		tooltip = "(DEFAULT 60) max resource % after which a warning will appear",
		min = 20,
		max = 90,
		step = 1,
		getFunc = function() return HealerHelper.savedVars.unnecessaryResourcePercentage end,
		setFunc = function(value)
			HealerHelper.HealerHelper.unnecessaryResourcePercentage = value
		end,
	})


	table.insert (options,{
		type = "header",
		name = "Gear Sets"
	})

	table.insert (options,{
		type = "checkbox",
		name = "Meta support gear warning",
		tooltip = "(DEFAULT ON) warn if missing or not using suportive meta gear.  If you do not want to be warned about: off-meta gear, selfish gear, incorrectly slotted gear, turn this OFF.",
		getFunc = function() return HealerHelper.savedVars.metaGearWarnings end,
		setFunc = function(value)
			HealerHelper.savedVars.metaGearWarnings = value
		end
	})

	table.insert (options,{
		type = "checkbox",
		name = "Ozezan the Inferno's meta",
		tooltip = "(DEFAULT OFF) Allow Ozezan to be considered meta gear and disable warnings regarding it's use.  This is a selfish healer helm, and while generally selfish helms are not considered meta, it does see some use when other options are not possible.",
		getFunc = function() return HealerHelper.savedVars.ozezanMeta end,
		setFunc = function(value)
			HealerHelper.savedVars.ozezanMeta = value
		end
	})





	table.insert (options,{
		type = "header",
		name = "Skill Morphs"
	})


	table.insert (options,{
		type = "checkbox",
		name = "Incorrect morph warnings",
		tooltip = "(DEFAULT ON) warn of incorrect skill morphs.  There are many skills where both morphs can be used in different situations, but there are others that should generally never be used in PVE healing. Avoid these warnings by turning this OFF.",
		getFunc = function() return HealerHelper.savedVars.skillMorphWarning end,
		setFunc = function(value)
			HealerHelper.savedVars.skillMorphWarning = value
		end
	})

	table.insert (options,{
		type = "checkbox",
		name = "Suppress warning while leveling skill",
		tooltip = "(DEFAULT ON) disable warnings for incorrect morphs while leveling the skill. Once it reaches rank 4 it will be considered for warning.  This allows healers to level up without being nagged with warnings.",
		getFunc = function() return HealerHelper.savedVars.skillMorphWarningSupressedWhileLevelingSkill end,
		setFunc = function(value)
			HealerHelper.savedVars.skillMorphWarningSupressedWhileLevelingSkill = value
		end
	})

	table.insert (options,{
		type = "checkbox",
		name = "Treat Illustrious Healing as an incorrect morph",
		tooltip = "(DEFAULT ON) This morph is inferior morph in almost all situations. Healing Springs heals for more, ticks twice as often, and has a built in resource buff.  The cost is the 33% extra casts required. If you prefer not to see this warning turn OFF.",
		getFunc = function() return HealerHelper.savedVars.skillMorphWarningIllustrusHealing end,
		setFunc = function(value)
			HealerHelper.savedVars.skillMorphWarningIllustrusHealing = value
		end
	})
	table.insert (options,{
		type = "checkbox",
		name = "Treat Merciless Resolve as an incorrect morph",
		tooltip = "(DEFAULT ON) This morph does more damage and less spell damage buff.  Used by damage dealing healers.  Turn off to disable the warning about this morph",
		getFunc = function() return HealerHelper.savedVars.skillMorphWarningMercilessResolve end,
		setFunc = function(value)
			HealerHelper.savedVars.skillMorphWarningMercilessResolve = value
		end
	})

	table.insert (options,{
		type = "header",
		name = "Spaulder of Ruin"
	})

	table.insert (options,{
		type = "checkbox",
		name = "Spaulder needs activation warning",
		tooltip = "(DEFAULT ON) Warn when Spaulder is equipped but not active",
		getFunc = function() return HealerHelper.savedVars.enableSpaulderWarning end,
		setFunc = function(value)
			HealerHelper.savedVars.enableSpaulderWarning = value
		end
	})





	table.insert (options,{
		type = "header",
		name = "Minor Sorcery / Minor Brutality"
	})

	table.insert (options,{
		type = "description",
		title = nil,
		text = "These buffs are only applicable to Templar and Dragonknight healers. This module will be disabled automatically for other classes.",
		width = "full",	--or "half" (optional)
	})

	table.insert (options,{
		type = "checkbox",
		name = "Enable Minor Sorcery / Brutality",
		tooltip = "(DEFAULT ON) Class buffs provided by Templars and Dragonknights.  These buffs are interchangeable, only one or the other is needed. If playing healer and the buff is not provided in some other way, it is usually your responsibility to provide it.",
		getFunc = function() return HealerHelper.savedVars.minorSorceryBrutalityWarning end,
		setFunc = function(value)
			HealerHelper.savedVars.minorSorceryBrutalityWarning = value
		end
	})


	table.insert (options,{
		type = "slider",
		name = "Targets in trials",
		tooltip = "(DEFAULT 3) Minimum number of targets to request mS/B (warning if using a large number and excluding healers and tanks may cause mS/B to not be requested under certain situations)",
		min = 1,
		max = 12,
		step = 1,
		getFunc = function() return HealerHelper.savedVars.minimumMsbTargetsTrials end,
		setFunc = function(value)
			HealerHelper.savedVars.minimumMsbTargetsTrials = value
		end,
	})

	table.insert (options,{
		type = "slider",
		name = "Targets in dungeons",
		tooltip = "(DEFAULT 1) Minimum number of targets to request mS/B (warning if using a large number and excluding healers and tanks may cause mS/B to not be requested under certain situations)",
		min = 1,
		max = 4,
		step = 1,
		getFunc = function() return HealerHelper.savedVars.minimumMsbTargetsDungeons end,
		setFunc = function(value)
			HealerHelper.savedVars.minimumMsbTargetsDungeons = value
		end,
	})


	table.insert (options,{
		type = "checkbox",
		name = "Tanks included",
		tooltip = "(DEFAULT OFF)",
		getFunc = function() return HealerHelper.savedVars.tanksIncludedInMsbTargets end,
		setFunc = function(value)
			HealerHelper.savedVars.tanksIncludedInMsbTargets= value
		end
	})
	table.insert (options,{
		type = "checkbox",
		name = "Healers included",
		tooltip = "(DEFAULT OFF)",
		getFunc = function() return HealerHelper.savedVars.healersIncludedInMsbTargets end,
		setFunc = function(value)
			HealerHelper.savedVars.healersIncludedInMsbTargets= value
		end
	})



	table.insert (options,{
		type = "header",
		name = "Minor Prophecy / Minor Savagery"
	})

	table.insert (options,{
		type = "description",
		title = nil,
		text = "These buffs are only applicable to Sorcery and Nightblade healers. This module will be disabled automatically for other classes. Note: Nightblade healers must do critical damage to proc this buff.",
		width = "full",	--or "half" (optional)
	})

	table.insert (options,{
		type = "checkbox",
		name = "Enable Minor Prophecy / Savagery",
		tooltip = "(DEFAULT ON) Class buffs provided by Sorcerers and Nightblades.  These buffs are interchangeable, only one or the other is needed. If playing healer and the buff is not provided in some other way, it is usually your responsibility to provide it.",
		getFunc = function() return HealerHelper.savedVars.minorProphecySavageryWarning end,
		setFunc = function(value)
			HealerHelper.savedVars.minorProphecySavageryWarning = value
		end
	})


	table.insert (options,{
		type = "slider",
		name = "Targets in trials",
		tooltip = "(DEFAULT 3) Minimum number of targets to request mS/B (warning if using a large number and excluding healers and tanks may cause mP/S to not be requested under certain situations)",
		min = 1,
		max = 12,
		step = 1,
		getFunc = function() return HealerHelper.savedVars.minimumMpsTargetsTrials end,
		setFunc = function(value)
			HealerHelper.savedVars.minimumMpsTargetsTrials = value
		end,
	})

	table.insert (options,{
		type = "slider",
		name = "Targets in dungeons",
		tooltip = "(DEFAULT 1) Minimum number of targets to request mS/B (warning if using a large number and excluding healers and tanks may cause mP/S to not be requested under certain situations)",
		min = 1,
		max = 4,
		step = 1,
		getFunc = function() return HealerHelper.savedVars.minimumMpsTargetsDungeons end,
		setFunc = function(value)
			HealerHelper.savedVars.minimumMpsTargetsDungeons = value
		end,
	})


	table.insert (options,{
		type = "checkbox",
		name = "Tanks included",
		tooltip = "(DEFAULT OFF)",
		getFunc = function() return HealerHelper.savedVars.tanksIncludedInMpsTargets end,
		setFunc = function(value)
			HealerHelper.savedVars.tanksIncludedInMpsTargets= value
		end
	})
	table.insert (options,{
		type = "checkbox",
		name = "Healers included",
		tooltip = "(DEFAULT OFF)",
		getFunc = function() return HealerHelper.savedVars.healersIncludedInMpsTargets end,
		setFunc = function(value)
			HealerHelper.savedVars.healersIncludedInMpsTargets= value
		end
	})



	if HealerHelper.savedVars.betaTestingMinorToughness then

	table.insert (options,{
		type = "header",
		name = "Minor Toughness"
	})

	table.insert (options,{
		type = "description",
		title = nil,
		text = "This buff are only applicable to Warden healers. Unfortunatly there appears to be a bug in the way this buff is reported making the warnings unreliable.",
		width = "full",	--or "half" (optional)
	})

	table.insert (options,{
		type = "checkbox",
		name = "Enable Minor Toughness",
		tooltip = "(DEFAULT ON) Class buffs provided by Wardens.  Will warn if missing this buff on specified number of players.",
		getFunc = function() return HealerHelper.savedVars.minorToughnessWarning end,
		setFunc = function(value)
			HealerHelper.savedVars.minorToughnessWarning = value
		end
	})


	table.insert (options,{
		type = "slider",
		name = "Targets in trials",
		tooltip = "(DEFAULT 3) Minimum number of targets to request mT (warning if using a large number and excluding healers and tanks may cause mT to not be requested under certain situations)",
		min = 1,
		max = 12,
		step = 1,
		getFunc = function() return HealerHelper.savedVars.minimumMtTargetsTrials end,
		setFunc = function(value)
			HealerHelper.savedVars.minimumMtTargetsTrials = value
		end,
	})

	table.insert (options,{
		type = "slider",
		name = "Targets in dungeons",
		tooltip = "(DEFAULT 1) Minimum number of targets to request mT (warning if using a large number and excluding healers and tanks may cause mT to not be requested under certain situations)",
		min = 1,
		max = 4,
		step = 1,
		getFunc = function() return HealerHelper.savedVars.minimumMtTargetsDungeons end,
		setFunc = function(value)
			HealerHelper.savedVars.minimumMtTargetsDungeons = value
		end,
	})


	table.insert (options,{
		type = "checkbox",
		name = "Tanks included",
		tooltip = "(DEFAULT ON)",
		getFunc = function() return HealerHelper.savedVars.tanksIncludedInMtTargets end,
		setFunc = function(value)
			HealerHelper.savedVars.tanksIncludedInMtTargets= value
		end
	})
	table.insert (options,{
		type = "checkbox",
		name = "Healers included",
		tooltip = "(DEFAULT ON)",
		getFunc = function() return HealerHelper.savedVars.healersIncludedInMtTargets end,
		setFunc = function(value)
			HealerHelper.savedVars.healersIncludedInMtTargets= value
		end
	})

	end

	table.insert (options,{
		type = "header",
		name = "Radiating Regeneration"
	})



	if FancyActionBar == nil and HealerHelper.savedVars.enableHudWithoutFancyActionBar == false then
		table.insert (options,
				{
					type = "description",
					title = nil,	--(optional)
					text = "Required addon: |cff2424Fancy Action Bar|r missing.  Please install to enable this feature.",
					width = "full",	--or "half" (optional)
				})
	else
	table.insert (options,{
		type = "description",
		title = nil,	--(optional)
		text = "This skill has some interesting quirks. The addon will help you manage them.  Read following tooltip for more details.",
		width = "full",	--or "half" (optional)
	})

		table.insert (options,{
			type = "checkbox",
			name = "Enable Radiating Regeneration",
			tooltip = "(DEFAULT ON) Radiating Regen (RR) only applies to 3 people at a time meaning it takes 2 casts to apply to a Dungeon group, however casting it early will not necessarily apply to the player that has the lowest time remaining of RR.  This making determine when to cast RR somewhat difficult.  This module will help indicate when your RR cast will actually apply to someone that needs it.",
			getFunc = function() return HealerHelper.savedVars.radiatingRegenerationEnabled end,
			setFunc = function(value)
				HealerHelper.savedVars.radiatingRegenerationEnabled = value
			end
		})



		table.insert (options,{
			type = "checkbox",
			name = "Enable Radiating Regeneration in Trials",
			tooltip = "(DEFAULT OFF) RR only applies to 3 people at a time, meaning it takes 4 consecutive casts to heal a full trial group.  This is impractical as it would consume +40% of all your casts. There are a couple trials where RR is used, however in a proper rotation it will be very difficult to get RR on everyone.  Therefore recommend keeping this setting off.",
			getFunc = function() return HealerHelper.savedVars.radiatingRegenerationTrials end,
			setFunc = function(value)
				HealerHelper.savedVars.radiatingRegenerationTrials = value
			end
		})


	end






	table.insert (options,{
		type = "header",
		name = "Echoing Vigor"
	})


	if FancyActionBar == nil and HealerHelper.savedVars.enableHudWithoutFancyActionBar == false then
		table.insert (options,
				{
					type = "description",
					title = nil,	--(optional)
					text = "Required addon: |cff2424Fancy Action Bar|r missing.  Please install to enable this feature.",
					width = "full",	--or "half" (optional)
				})
	else
	table.insert (options,{
		type = "description",
		title = nil,	--(optional)
		text = "This skill has some interesting quirks in trials. The addon will help you manage them.  Read following tooltip for more details.",
		width = "full",	--or "half" (optional)
	})

		table.insert (options,{
			type = "checkbox",
			name = "Enable Echoing Vigor",
			tooltip = "(DEFAULT ON) provides an indication when EV would hit someone that needs it.",
			getFunc = function() return HealerHelper.savedVars.echoingVigorEnabled end,
			setFunc = function(value)
				HealerHelper.savedVars.echoingVigorEnabled = value
			end
		})


		table.insert (options,{
			type = "slider",
			name = "Targets in trials",
			tooltip = "(DEFAULT 3) Minimum number of guaranteed targets to request Echoing Vigor (warning due to the goofy way Echoing Vigor will re-apply to existing targets first rather than those that need it.  You may need to move to out range existing targets before you can hit new ones.  The addon will recommend this skill only when you are guaranteed to apply the skill to new targets)",
			min = 1,
			max = 5,
			step = 1,
			getFunc = function() return HealerHelper.savedVars.minimumEchoingVigorTargetsTrials end,
			setFunc = function(value)
				HealerHelper.HealerHelper.minimumEchoingVigorTargetsTrials = value
			end,
		})

		table.insert (options,{
			type = "slider",
			name = "Targets in dungeons",
			tooltip = "(DEFAULT 1) for groups with less than 6 players, Echoing Vigor will always apply to the players in range",
			min = 1,
			max = 4,
			step = 1,
			getFunc = function() return HealerHelper.savedVars.minimumEchoingVigorTargetsDungeons end,
			setFunc = function(value)
				HealerHelper.HealerHelper.minimumEchoingVigorTargetsDungeons = value
			end,
		})




	end



	table.insert (options,{
		type = "header",
		name = "Funnel Health (Nightblade)"
	})



	if FancyActionBar == nil and HealerHelper.savedVars.enableHudWithoutFancyActionBar == false then
		table.insert (options,
				{
					type = "description",
					title = nil,	--(optional)
					text = "Required addon: |cff2424Fancy Action Bar|r missing.  Please install to enable this feature.",
					width = "full",	--or "half" (optional)
				})
	else


		table.insert (options,{
			type = "checkbox",
			name = "Enable Funnel Health",
			tooltip = "(DEFAULT ON) Funnel Health (FH) only applies to 2 people at a time meaning it takes 2 casts to apply to a Dungeon group",
			getFunc = function() return HealerHelper.savedVars.funnelHealthEnabled end,
			setFunc = function(value)
				HealerHelper.savedVars.funnelHealthEnabled = value
			end
		})

		table.insert (options,{
			type = "checkbox",
			name = "Enable Funnel Health in Trials",
			tooltip = "(DEFAULT OFF) FH only applies to 2 people at a time, meaning it takes 6 consecutive casts to heal a full trial group.  This is impractical as it would consume +60% of all your casts. There are a no trials where FH is used.  Therefore recommend keeping this setting off.",
			getFunc = function() return HealerHelper.savedVars.funnelHealthTrials end,
			setFunc = function(value)
				HealerHelper.savedVars.funnelHealthTrials = value
			end
		})


	end


	table.insert (options,{
		type = "header",
		name = "Expansive Frost Cloak (Warden)"
	})

	if FancyActionBar == nil and HealerHelper.savedVars.enableHudWithoutFancyActionBar == false then
		table.insert (options,
				{
					type = "description",
					title = nil,	--(optional)
					text = "Required addon: |cff2424Fancy Action Bar|r missing.  Please install to enable this feature.",
					width = "full",	--or "half" (optional)
				})
	else


		table.insert (options,{
			type = "checkbox",
			name = "Enable Frost Cloak",
			tooltip = "(DEFAULT ON) Tracks the use of Expansive Frost Cloak and Ice Fortress (selfish morph) and recommends the skill when someone in range needs Major Resolve",
			getFunc = function() return HealerHelper.savedVars.majorResolveEnabled end,
			setFunc = function(value)
				HealerHelper.savedVars.majorResolveEnabled = value
			end
		})



	end


		table.insert (options,{
		type = "header",
		name = "Minor Vulnerability"
	})

	if FancyActionBar == nil and HealerHelper.savedVars.enableHudWithoutFancyActionBar == false then
		table.insert (options,
				{
					type = "description",
					title = nil,	--(optional)
					text = "Required addon: |cff2424Fancy Action Bar|r missing.  Please install to enable this feature.",
					width = "full",	--or "half" (optional)
				})
	else


		table.insert (options,{
			type = "checkbox",
			name = "Enable Minor Vulnerability",
			tooltip = "(DEFAULT ON) Tracks when the current target is missing Minor Vulnerability and suggests casting Warden Swarm, Arcanist Rune, Nightblade Lotus Fan",
			getFunc = function() return HealerHelper.savedVars.minorVulnerabilityEnabled end,
			setFunc = function(value)
				HealerHelper.savedVars.minorVulnerabilityEnabled = value
			end
		})



	end

		table.insert (options,{
		type = "header",
		name = "Purge"
	})

	if FancyActionBar == nil and HealerHelper.savedVars.enableHudWithoutFancyActionBar == false then
		table.insert (options,
				{
					type = "description",
					title = nil,	--(optional)
					text = "Required addon: |cff2424Fancy Action Bar|r missing.  Please install to enable this feature.",
					width = "full",	--or "half" (optional)
				})
	else


		table.insert (options,{
			type = "checkbox",
			name = "Enable Purge",
			tooltip = "(DEFAULT ON) Provided you have a purge skill slotted, recommends based on if someone in your group has a common purgeable debuff.",
			getFunc = function() return HealerHelper.savedVars.purgeEnabled end,
			setFunc = function(value)
				HealerHelper.savedVars.purgeEnabled = value
			end
		})



	end





	table.insert (options,{
		type = "header",
		name = "Burst Heals"
	})

	table.insert (options,
		{
			type = "description",
			title = nil,	--(optional)
			text = "Combat Prayer is the best burst heal for healers in group content, other class burst heals generally only affect one or two targets, and are mostly not used in group content.",
			width = "full",	--or "half" (optional)
		})

	if FancyActionBar == nil and HealerHelper.savedVars.enableHudWithoutFancyActionBar == false then
		table.insert (options,
				{
					type = "description",
					title = nil,	--(optional)
					text = "Required addon: |cff2424Fancy Action Bar|r missing.  Please install to enable this feature.",
					width = "full",	--or "half" (optional)
				})
	else


		table.insert (options,{
			type = "checkbox",
			name = "Enable Burst Heals",
			tooltip = "(DEFAULT ON) Recommends a burst heal for you or others based on the skills you have slotted",
			getFunc = function() return HealerHelper.savedVars.burstEnabled end,
			setFunc = function(value)
				HealerHelper.savedVars.burstEnabled = value
			end
		})

		table.insert (options,{
			type = "slider",
			name = "Burst Heal HP under %",
			tooltip = "Recommend burst heal when target HP is under this percentage.",
			min = 10,
			max = 90,
			step = 1,
			getFunc = function() return HealerHelper.savedVars.burstHealRecommendedHPUnderPercentage end,
			setFunc = function(value)
				HealerHelper.savedVars.burstHealRecommendedHPUnderPercentage = value
			end,
		})

	end









		table.insert (options,{
		type = "header",
		name = "Ward / Shield"
	})

	if FancyActionBar == nil and HealerHelper.savedVars.enableHudWithoutFancyActionBar == false then
		table.insert (options,
				{
					type = "description",
					title = nil,	--(optional)
					text = "Required addon: |cff2424Fancy Action Bar|r missing.  Please install to enable this feature.",
					width = "full",	--or "half" (optional)
				})
	else


		table.insert (options,{
			type = "checkbox",
			name = "Enable Ward",
			tooltip = "(DEFAULT ON) Recommends a shield for you or others based on the skills you have slotted",
			getFunc = function() return HealerHelper.savedVars.shieldEnabled end,
			setFunc = function(value)
				HealerHelper.savedVars.shieldEnabled = value
			end
		})

		table.insert (options,{
			type = "slider",
			name = "Ward HP under %",
			tooltip = "(DEFAULT 50) Recommend wards when target HP is under this percentage.",
			min = 10,
			max = 90,
			step = 1,
			getFunc = function() return HealerHelper.savedVars.wardRecommendedHPUnderPercentage end,
			setFunc = function(value)
				HealerHelper.savedVars.wardRecommendedHPUnderPercentage = value
			end,
		})

	end





	table.insert (options,

			{
				type = "header",
				name = "Skill Cast Blocking"
			}
	)
	table.insert (options,
			{
				type = "description",
				title = nil,	--(optional)
				text = "Accidentally cast skills only slotted for buffing your bars? Skill cast blocking can help you. (DEFAULT OFF)",
				width = "full",	--or "half" (optional)
			})

	if LibSkillBlocker == nil then
		table.insert (options,
				{
					type = "description",
					title = nil,	--(optional)
					text = "Required addon library: |cff2424rLibSkillBlocker|.  Please install to enable this feature.",
					width = "full",	--or "half" (optional)
				})

	else



		table.insert (options,
				{
					type = "checkbox",
					name = "Barrier (Alliance War)",
					tooltip = "(DEFAULT OFF) This skill is typically slotted on a healer as a 10% magicka regen buff, casting it instead of DPS buff in most situations is the calling card of a new healer.",
					getFunc = function() return HealerHelper.savedVars.blockCastingBarrier end,
					setFunc = function(value)
						HealerHelper.savedVars.blockCastingBarrier = value
						HealerHelper.updateSkillBlocking()
					end
				})

		table.insert (options,
				{
					type = "checkbox",
					name = "Relentless Focus (Nightblade)",
					tooltip = "(DEFAULT OFF) Used on Nightblade healers as a bar buff, typically not cast.",
					getFunc = function() return HealerHelper.savedVars.blockCastingRelentlessFocus end,
					setFunc = function(value)
						HealerHelper.savedVars.blockCastingRelentlessFocus = value
						HealerHelper.updateSkillBlocking()
					end
				})



		table.insert (options,

				{
					type = "checkbox",
					name = "Flawless Dawnbreaker (Fighters Guild)",
					tooltip = "(DEFAULT OFF) Typically slotted by off-healers (ie: damage dealing healers) can be disabled from accidental casting if you wish.",
					getFunc = function() return HealerHelper.savedVars.blockCastingFlawlessDawnbreaker end,
					setFunc = function(value)
						HealerHelper.savedVars.blockCastingFlawlessDawnbreaker = value
						HealerHelper.updateSkillBlocking()
					end
				})


		table.insert (options,
				{
					type = "checkbox",
					name = "Inner Light (Mages Guild)",
					tooltip = "(DEFAULT OFF) While not as popular as it once was, this bar buff should not be cast in PVE.",
					getFunc = function() return HealerHelper.savedVars.blockCastingInnerLight end,
					setFunc = function(value)
						HealerHelper.savedVars.blockCastingInnerLight = value
						HealerHelper.updateSkillBlocking()
					end
				})



		table.insert (options,
				{
					type = "checkbox",
					name = "Camo Hunter (Fighters Guild)",
					tooltip = "(DEFAULT OFF) Typically slotted by off-healers without restoration staff, does not need to be cast in PVE.",
					getFunc = function() return HealerHelper.savedVars.blockCastingCamoHunter end,
					setFunc = function(value)
						HealerHelper.savedVars.blockCastingCamoHunter = value
						HealerHelper.updateSkillBlocking()
					end
				})

		table.insert (options,
				{
					type = "checkbox",
					name = "Temporal Guard (Psijic Order)",
					tooltip = "(DEFAULT OFF) Uncommon bar buff for healers, typically used on tanks for damage reduction.  Should you use it, this can help from accidental casting.",
					getFunc = function() return HealerHelper.savedVars.blockCastingTemporalGuard end,
					setFunc = function(value)
						HealerHelper.savedVars.blockCastingTemporalGuard = value
						HealerHelper.updateSkillBlocking()
					end
				})



		table.insert (options,

				{
					type = "checkbox",
					name = "Revealing Flare (Alliance War)",
					tooltip = "(DEFAULT OFF) Uncommon bar buff for healers, typically used on tanks for damage reduction.  Should you use it, this can help from accidental casting.",
					getFunc = function() return HealerHelper.savedVars.blockCastingRevealingFlare end,
					setFunc = function(value)
						HealerHelper.savedVars.blockCastingRevealingFlare = value
						HealerHelper.updateSkillBlocking()
					end
				})
	end






	if HealerHelper.savedVars.advancedUI then

		table.insert (options,
				{
					type = "header",
					name = "Advanced UI Positioning"
				})

		table.insert (options,
				{
					type = "slider",
					name = "Height",
					tooltip = "(Default 158)",

					min = HealerHelper.MIN_HEIGHT,
					max = HealerHelper.MAX_HEIGHT,
					step = 1,
					getFunc = function() return HealerHelper.savedVars.height end,
					setFunc = function(value)
						HealerHelper.savedVars.height = value
						HealerHelper.adjustFrameLocation()
						---HealerHelper.BuildUI()
					end,
				})

		table.insert (options,
				{
					type = "slider",
					name = "Vertical Offset",
					tooltip = "(Default 56)",
					min = HealerHelper.MIN_VERTICALOFFSET,
					max = HealerHelper.MAX_VERTICALOFFSET,
					step = 1,
					getFunc = function() return HealerHelper.savedVars.verticalOffset end,
					setFunc = function(value)
						HealerHelper.savedVars.verticalOffset = value
						HealerHelper.adjustFrameLocation()
					end,
				})


		table.insert (options,
				{
					type = "slider",
					name = "Gap Width Offset",
					tooltip = "(Default 0)",
					min = 0,
					max = 50,
					step = 1,
					getFunc = function() return HealerHelper.savedVars.gapWidth end,
					setFunc = function(value)
						HealerHelper.savedVars.gapWidth = value
						HealerHelper.adjustFrameLocation()
					end,
				})



		table.insert (options,
				{
					type = "button",
					name = "Reset to Defaults",
					func = function()
						HealerHelper.savedVars.height = 158
						HealerHelper.savedVars.verticalOffset = 56
						HealerHelper.savedVars.gapWidth = 0
						HealerHelper.adjustFrameLocation()
					end,
					width = "half"

				})


	end


	if HealerHelper.savedVars.extraFeatures then

		table.insert (options,
				{
					type = "header",
					name = "Development Only"
				}
		)


		table.insert (options,

				{
					type = "checkbox",
					name = "Debug Skill detection to Chat",
					tooltip = "Used to debug skill detection",
					getFunc = function() return HealerHelper.savedVars.debugCombatEventSkillDetection end,
					setFunc = function(value)
						if not value then
							HealerHelper.savedVars.debugCombatEventSkillDetection = false
						else
							HealerHelper.savedVars.debugCombatEventSkillDetection = true
						end
					end
				}
		)

	else
		HealerHelper.savedVars.debugCombatEventSkillDetection = false
	end

	LAM:RegisterOptionControls(HealerHelper.name.."Options", options)
end
