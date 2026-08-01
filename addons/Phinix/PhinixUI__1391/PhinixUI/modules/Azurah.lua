
function PUIAddon.Azurah()

----------------------------------------------------------------------------------------------------------------
-- Initialize Saved Variable Database Reference
----------------------------------------------------------------------------------------------------------------
	local db = AzurahDB.Default[GetDisplayName()]["$AccountWide"]

----------------------------------------------------------------------------------------------------------------
-- Configure Addon Settings
----------------------------------------------------------------------------------------------------------------
	db.useAccountWide = true

	db.uiData.keyboard = db.uiData.keyboard or {}
	db.uiData.keyboard.ZO_PlayerAttributeHealth				= db.uiData.keyboard.ZO_PlayerAttributeHealth or {}
	db.uiData.keyboard.ZO_PlayerAttributeHealth = {
		y = -148.5000000000,
		scale = 1,
		point = 4,
		x = 0,
	}
	db.uiData.keyboard.ZO_PlayerAttributeMagicka			= db.uiData.keyboard.ZO_PlayerAttributeMagicka or {}
	db.uiData.keyboard.ZO_PlayerAttributeMagicka = {
		y = 560,
		scale = 1,
		point = 8,
		x = -1431.5000000000,
	}
	db.uiData.keyboard.ZO_PlayerAttributeStamina			= db.uiData.keyboard.ZO_PlayerAttributeStamina or {}
	db.uiData.keyboard.ZO_PlayerAttributeStamina = {
		y = 560,
		scale = 1,
		point = 2,
		x = 1431.5000000000,
	}
	db.uiData.keyboard.ZO_PlayerProgress					= db.uiData.keyboard.ZO_PlayerProgress or {}
	db.uiData.keyboard.ZO_PlayerProgress = {
		y = 27.4287109375,
		scale = 1,
		point = 3,
		x = 0,
	}
	db.uiData.keyboard.ZO_CompassFrame						= db.uiData.keyboard.ZO_CompassFrame or {}
	db.uiData.keyboard.ZO_CompassFrame = {
		y = 281.5000000000,
		scale = 1,
		point = 9,
		x = -9,
		opacity = 1,
		copacity = 1,
		altcombat = false,
	}
	db.uiData.keyboard.ZO_TargetUnitFramereticleover		= db.uiData.keyboard.ZO_TargetUnitFramereticleover or {}
	db.uiData.keyboard.ZO_TargetUnitFramereticleover = {
		y = 123.9287109375,
		scale = 1,
		point = 1,
		x = 0,
	}
	db.uiData.keyboard.ZO_ActionBar1						= db.uiData.keyboard.ZO_ActionBar1 or {}
	db.uiData.keyboard.ZO_ActionBar1 = {
		y = 0,
		scale = 1,
		point = 4,
		x = 0,
	}
	db.uiData.keyboard.ZO_LargeGroupAnchorFrame1			= db.uiData.keyboard.ZO_LargeGroupAnchorFrame1 or {}
	db.uiData.keyboard.ZO_LargeGroupAnchorFrame1 = {
		y = 101.5401000977,
		scale = 1,
		point = 3,
		x = 19.6268920898,
	}
	db.uiData.keyboard.ZO_LargeGroupAnchorFrame2			= db.uiData.keyboard.ZO_LargeGroupAnchorFrame2 or {}
	db.uiData.keyboard.ZO_LargeGroupAnchorFrame2 = {
		y = -180,
		scale = 1,
		point = 2,
		x = 19.6268920898,
	}
	db.uiData.keyboard.ZO_LargeGroupAnchorFrame3			= db.uiData.keyboard.ZO_LargeGroupAnchorFrame3 or {}
	db.uiData.keyboard.ZO_LargeGroupAnchorFrame3 = {
		y = 10,
		scale = 1,
		point = 2,
		x = 19.6268920898,
	}
	db.uiData.keyboard.ZO_LargeGroupAnchorFrame4			= db.uiData.keyboard.ZO_LargeGroupAnchorFrame4 or {}
	db.uiData.keyboard.ZO_LargeGroupAnchorFrame4 = {
		y = 101.5401000977,
		scale = 1,
		point = 3,
		x = 139.6268920898,
	}
	db.uiData.keyboard.ZO_LargeGroupAnchorFrame5			= db.uiData.keyboard.ZO_LargeGroupAnchorFrame5 or {}
	db.uiData.keyboard.ZO_LargeGroupAnchorFrame5 = {
		y = -180,
		scale = 1,
		point = 2,
		x = 139.6268920898,
	}
	db.uiData.keyboard.ZO_LargeGroupAnchorFrame6			= db.uiData.keyboard.ZO_LargeGroupAnchorFrame6 or {}
	db.uiData.keyboard.ZO_LargeGroupAnchorFrame6 = {
		y = 10,
		scale = 1,
		point = 2,
		x = 139.6268920898,
	}
	db.uiData.keyboard.ZO_FocusedQuestTrackerPanel			= db.uiData.keyboard.ZO_FocusedQuestTrackerPanel or {}
	db.uiData.keyboard.ZO_FocusedQuestTrackerPanel = {
		y = -310,
		scale = 0.9800000191,
		point = 8,
		x = 0,
	}
	db.uiData.keyboard.ZO_AlertTextNotification				= db.uiData.keyboard.ZO_AlertTextNotification or {}
	db.uiData.keyboard.ZO_AlertTextNotification = {
		y = 240,
		scale = 1,
		point = 8,
		x = -7.4288330078,
	}
	db.uiData.keyboard.ZO_CenterScreenAnnounce				= db.uiData.keyboard.ZO_CenterScreenAnnounce or {}
	db.uiData.keyboard.ZO_CenterScreenAnnounce = {
		y = -270,
		scale = 1,
		point = 128,
		x = -10,
	}
	db.uiData.keyboard.ZO_HUDInfamyMeter					= db.uiData.keyboard.ZO_HUDInfamyMeter or {}
	db.uiData.keyboard.ZO_HUDInfamyMeter = {
		y = 41.4287109375,
		scale = 1,
		point = 9,
		x = -249.4288330078,
	}
	db.uiData.keyboard.ZO_HUDTelvarMeter					= db.uiData.keyboard.ZO_HUDTelvarMeter or {}
	db.uiData.keyboard.ZO_HUDTelvarMeter = {
		y = 41.4287109375,
		scale = 1,
		point = 9,
		x = -249.4288330078,
	}
	db.uiData.keyboard.ZO_TutorialHudInfoTipKeyboard		= db.uiData.keyboard.ZO_TutorialHudInfoTipKeyboard or {}
	db.uiData.keyboard.ZO_TutorialHudInfoTipKeyboard = {
		y = 250,
		scale = 1,
		point = 8,
		x = 0,
	}
	db.uiData.keyboard.Azurah_BagWatcher					= db.uiData.keyboard.Azurah_BagWatcher or {}
	db.uiData.keyboard.Azurah_BagWatcher = {
		y = 0,
		scale = 1,
		point = 2,
		x = -239.9288330078,
	}
	db.uiData.keyboard.ZO_LootHistoryControl_Keyboard		= db.uiData.keyboard.ZO_LootHistoryControl_Keyboard or {}
	db.uiData.keyboard.ZO_LootHistoryControl_Keyboard = {
		y = 150,
		scale = 0.9000000954,
		point = 2,
		x = -0.0000076294,
	}
	db.uiData.keyboard.ZO_RamTopLevel						= db.uiData.keyboard.ZO_RamTopLevel or {}
	db.uiData.keyboard.ZO_RamTopLevel = {
		y = -148.2000732422,
		scale = 0.7600002289,
		point = 4,
		x = -0.0000610352,
	}
	db.uiData.keyboard.ZO_Subtitles							= db.uiData.keyboard.ZO_Subtitles or {}
	db.uiData.keyboard.ZO_Subtitles = {
		y = 190.0000610352,
		scale = 0.7200002670,
		point = 128,
		x = -0.0000610352,
	}
	db.uiData.keyboard.Azurah_PlayerBuffs					= db.uiData.keyboard.Azurah_PlayerBuffs or {}
	db.uiData.keyboard.Azurah_PlayerBuffs = {
		y = -185,
		scale = 1,
		point = 4,
		x = 0,
	}
	db.uiData.keyboard.ZO_BattlegroundHUDFragmentTopLevel	= db.uiData.keyboard.ZO_BattlegroundHUDFragmentTopLevel or {}
	db.uiData.keyboard.ZO_BattlegroundHUDFragmentTopLevel = {
		y = -10,
		scale = 1,
		point = 8,
		x = -42.1268310547,
	}
	if ParlezPlusSavedVariables ~= nil then
		db.uiData.keyboard.ZO_InteractWindowDivider	= db.uiData.keyboard.ZO_InteractWindowDivider or {}
		db.uiData.keyboard.ZO_InteractWindowDivider = {
			y = -190,
			scale = 1,
			point = 12,
			x = -16,
		}
	else
		db.uiData.keyboard.ZO_InteractWindowDivider = nil
	end

	db.uiData.gamepad = db.uiData.gamepad or {}
	db.uiData.gamepad.ZO_PlayerAttributeHealth				= db.uiData.gamepad.ZO_PlayerAttributeHealth or {}
	db.uiData.gamepad.ZO_PlayerAttributeHealth = {
		y = -148.5000000000,
		scale = 1,
		point = 4,
		x = 0,
	}
	db.uiData.gamepad.ZO_PlayerAttributeMagicka			= db.uiData.gamepad.ZO_PlayerAttributeMagicka or {}
	db.uiData.gamepad.ZO_PlayerAttributeMagicka = {
		y = 560,
		scale = 1,
		point = 8,
		x = -1431.5000000000,
	}
	db.uiData.gamepad.ZO_PlayerAttributeStamina			= db.uiData.gamepad.ZO_PlayerAttributeStamina or {}
	db.uiData.gamepad.ZO_PlayerAttributeStamina = {
		y = 560,
		scale = 1,
		point = 2,
		x = 1431.5000000000,
	}
	db.uiData.gamepad.ZO_PlayerProgress					= db.uiData.gamepad.ZO_PlayerProgress or {}
	db.uiData.gamepad.ZO_PlayerProgress = {
		y = 27.4287109375,
		scale = 1,
		point = 3,
		x = 0,
	}
	db.uiData.gamepad.ZO_CompassFrame						= db.uiData.gamepad.ZO_CompassFrame or {}
	db.uiData.gamepad.ZO_CompassFrame = {
		y = 276.5000000000,
		scale = 1,
		point = 9,
		x = -15,
	}
	db.uiData.gamepad.ZO_TargetUnitFramereticleover		= db.uiData.gamepad.ZO_TargetUnitFramereticleover or {}
	db.uiData.gamepad.ZO_TargetUnitFramereticleover = {
		y = 123.9287109375,
		scale = 1,
		point = 1,
		x = 0,
	}
	db.uiData.gamepad.ZO_ActionBar1						= db.uiData.gamepad.ZO_ActionBar1 or {}
	db.uiData.gamepad.ZO_ActionBar1 = {
		y = 0,
		scale = 1,
		point = 4,
		x = 0,
	}
	db.uiData.gamepad.ZO_CenterScreenAnnounce				= db.uiData.gamepad.ZO_CenterScreenAnnounce or {}
	db.uiData.gamepad.ZO_CenterScreenAnnounce = {
		y = -270,
		scale = 1,
		point = 128,
		x = -10,
	}
	db.uiData.gamepad.ZO_HUDInfamyMeter					= db.uiData.gamepad.ZO_HUDInfamyMeter or {}
	db.uiData.gamepad.ZO_HUDInfamyMeter = {
		y = 41.4287109375,
		scale = 1,
		point = 9,
		x = -249.4288330078,
	}
	db.uiData.gamepad.ZO_HUDTelvarMeter					= db.uiData.gamepad.ZO_HUDTelvarMeter or {}
	db.uiData.gamepad.ZO_HUDTelvarMeter = {
		y = 41.4287109375,
		scale = 1,
		point = 9,
		x = -249.4288330078,
	}
	db.uiData.gamepad.Azurah_BagWatcher					= db.uiData.gamepad.Azurah_BagWatcher or {}
	db.uiData.gamepad.Azurah_BagWatcher = {
		y = 0,
		scale = 1,
		point = 2,
		x = -239.9288330078,
	}
	db.uiData.gamepad.Azurah_PlayerBuffs					= db.uiData.gamepad.Azurah_PlayerBuffs or {}
	db.uiData.gamepad.Azurah_PlayerBuffs = {
		y = -185,
		scale = 1,
		point = 4,
		x = 0,
	}
	db.uiData.gamepad.ZO_BattlegroundHUDFragmentTopLevel	= db.uiData.gamepad.ZO_BattlegroundHUDFragmentTopLevel or {}
	db.uiData.gamepad.ZO_BattlegroundHUDFragmentTopLevel = {
		y = -10,
		scale = 1,
		point = 8,
		x = -42.1268310547,
	}

	db.compassPinScale = 1
	db.compassHidePinLabel = false
	db.actTrackerDisable = false
	db.modeChangeReload = false
	db.globalOpacityOn = false
	db.notificationHAlign = 1
	db.attributes = {
		fadeMinAlpha = 0,
		fadeMaxAlpha = 1,
		combatBars = true,
		lockSize = true,
		healthOverlay = 5,
		healthOverlayShield = false,
		healthOverlayFancy = true,
		healthFontFace = "Univers 67",
		healthFontColour = {
			g = 0.9000000000,
			r = 0.9000000000,
			a = 1,
			b = 0.9000000000,
		},
		healthFontOutline = "soft-shadow-thick",
		healthFontSize = 16,
		magickaOverlay = 5,
		magickaOverlayFancy = true,
		magickaFontFace = "Univers 67",
		magickaFontColour = {
			g = 0.9000000000,
			r = 0.9000000000,
			a = 1,
			b = 0.9000000000,
		},
		magickaFontOutline = "soft-shadow-thick",
		magickaFontSize = 16,
		staminaOverlay = 5,
		staminaOverlayFancy = true,
		staminaFontFace = "Univers 67",
		staminaFontColour = {
			g = 0.9000000000,
			r = 0.9000000000,
			a = 1,
			b = 0.9000000000,
		},
		staminaFontOutline = "soft-shadow-thick",
		staminaFontSize = 16,
	}
	db.target = {
		lockSize = true,
		RPName = true,
		RPTitle = false,
		RPInteract = true,
		RPIcon = true,
		colourByBar = 2,
		colourByName = 1,
		colourByLevel = true,
		classShow = true,
		classByName = false,
		allianceShow = true,
		allianceByName = false,
		overlay = 4,
		overlayShield = false,
		overlayFancy = true,
		fontFace = "Univers 67",
		fontColour = {
			g = 0.9000000000,
			r = 0.9000000000,
			a = 1,
			b = 0.9000000000,
		},
		fontOutline = "soft-shadow-thick",
		fontSize = 16,
	}
	db.bossbar = {
		overlay = 6,
		overlayFancy = true,
		fontFace = "Univers 67",
		fontColour = {
			g = 0.9000000000,
			r = 0.9000000000,
			a = 1,
			b = 0.9000000000,
		},
		fontOutline = "soft-shadow-thick",
		fontSize = 16,
	}
	db.actionBar = {
		hideBindBG = true,
		hideBindText = true,
		hideWeaponSwap = false,
		ultValueShow = true,
		ultValueFontFace = "Univers 67",
		ultValueFontColour = {
			g = 1.0000000000,
			r = 1.0000000000,
			a = 1,
			b = 1.0000000000,
		},
		ultPercentFontColour = {
			g = 0.0000000000,
			r = 1.0000000000,
			a = 1,
			b = 1.0000000000,
		},
		ultValueFontOutline = "soft-shadow-thick",
		ultValueFontSize = 16,
		ultPercentShow = true,
		ultPercentFontFace = "Univers 67",
		ultVReadyFontColour = {
			g = 1.0000000000,
			r = 0.0000000000,
			a = 1,
			b = 0.0000000000,
		},
		ultPReadyFontColour = {
			g = 1.0000000000,
			r = 0.0000000000,
			a = 1,
			b = 0.0000000000,
		},
		ultPercentFontOutline = "soft-shadow-thick",
		ultPercentFontSize = 16,
		ultPercentRelative = true,
		ultVUseReadyColor = true,
		ultPUseReadyColor = true,
		ultValueShowCost = true,
		ultValueXoffset = 0,
		ultValueYoffset = 0,
		ultPercentXoffset = 0,
		ultPercentYoffset = 22,
		ultPercentCap = true,
		blockExpertHunter = false,
		blockMageLight = false,
		blockWarning = false,
	}
	db.experienceBar = {
		displayStyle = 1,
		overlay = 2,
		overlayFancy = true,
		fontFace = "Univers 67",
		fontColour = {
			g = 0.9000000000,
			r = 0.9000000000,
			a = 1,
			b = 0.9000000000,
		},
		fontOutline = "soft-shadow-thick",
		fontSize = 16,
	}
	db.bagWatcher = {
		enabled = false,
		reverseAlignment = false,
		lowSpaceLock = true,
		lowSpaceTrigger = 157,
		overlay = 2,
		fontFace = "Univers 67",
		fontColour = {
			g = 0.9000000000,
			r = 0.9000000000,
			a = 1,
			b = 0.9000000000,
		},
		fontOutline = "soft-shadow-thick",
		fontSize = 18,
	}
	db.werewolf = {
		enabled = true,
		flashOnExtend = true,
		iconOnRight = false,
		fontFace = "Univers 67",
		fontColour = {
			g = 0.9000000000,
			r = 0.9000000000,
			a = 1,
			b = 0.9000000000,
		},
		fontOutline = "soft-shadow-thick",
		fontSize = 20,
	}
	db.compass = {
		compassWidth = 240,
		compassLabelScale = 0.9200000000,
		compassEnabled = true,
		compassHeight = 7,
		compassPinLabelY = 0,
		compassHideBackground = false,
		compassHidePinLabel = false,
		compassOpacity = 1,
	}
	db.thievery = {
		theftMakeSafer = true,
		theftPreventAccidental = true,
		theftAnnounceBlock = false,
		theftPMakeSafer = true,
		theftCMakeSafer = true,
	}
end
