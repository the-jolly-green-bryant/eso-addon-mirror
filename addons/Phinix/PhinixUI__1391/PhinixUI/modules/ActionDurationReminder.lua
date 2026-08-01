
function PUIAddon.ActionDurationReminder()

----------------------------------------------------------------------------------------------------------------
-- Initialize Saved Variable Database Reference
----------------------------------------------------------------------------------------------------------------
	local db = ADRSV.Default[GetDisplayName()]["$AccountWide"]

----------------------------------------------------------------------------------------------------------------
-- Configure Addon Settings
----------------------------------------------------------------------------------------------------------------
	db.cooldownColor = {
		[1] = 1,
		[2] = 1,
		[3] = 0,
	}
	db.barCooldownColor = {
		[1] = 1,
		[2] = 1,
		[3] = 0,
	}
	db.barCooldownEndingColor = {
		[1] = 1,
		[2] = 0,
		[3] = 0,
	}
	db.lureColors = {
		[4] = "345FE2",
		[1] = "C2C444",
		[2] = "7CAECC",
		[3] = "2ECCBE",
	}
	db.barLabelFontSize = 18
	db.alertSoundName = "NEW_TIMED_NOTIFICATION"
	db.barCooldownEndingSeconds = 1
	db.notificationAnim = "Pulse1"
	db.multipleTargetTracking = true
	db.coreMultipleTargetTracking = true
	db.alertOffsetY = 0
	db.showLootOnMap = true
	db.cooldownThickness = 2
	db.barShiftOffsetX = 0
	db.barCooldownOpacity = 100
	db.showPins = false
	db.barEnabled = true
	db.labelFontName = "BOLD_FONT"
	db.barLabelIgnoreDeciamlThreshold = 10
	db.reelInColor = "FFFFFF"
	db.barCooldownThickness = 2
	db.alertCustomFontName = ""
	db.barStackLabelYOffsetInShift = 0
	db.barStackLabelFontName = "BOLD_FONT"
	db.barShowShift = true
	db.barStackLabelFontStyle = "thick-outline"
	db.coreBlackKeyWords = ""
	db.showDefaultLoot = false
	db.pinLevel = 30
	db.labelYOffset = 0
	db.alertKeyWords = ""
	db.cooldownVisible = true
	db.barCooldownVisible = true
	db.alertAheadSeconds = 1
	db.labelFontSize = 18
	db.coreKeyWords = ""
	db.shiftBarOffsetX = 0.0000610352
	db.alertPlaySound = true
	db.alertSoundIndex = 266
	db.barLabelFontStyle = "thick-outline"
	db.autoHideRFT = false
	db.patchMoveBarsEnabled = true
	db.barLabelFontName = "BOLD_FONT"
	db.alertIconOnly = false
	db.showShiftActions = true
	db.alertOffsetX = 0
	db.barShowInQuickslot = false
	db.alertRemoveWhenCastAgain = true
	db.barStackLabelYOffset = 0
	db.autoSwitchBait = false
	db.barLabelYOffsetInShift = 0
	db.barLabelIgnoreDecimal = true
	db.secondsBeforeFade = 5
	db.alertEnabled = false
	db.barShiftOffsetY = -3.2015380859
	db.showReelIn = true
	db.alertBlackKeyWords = ""
	db.barStackLabelFontSize = 18
	db.alertFontStyle = "thick-outline"
	db.pinSize = 24
	db.showLootOnHUD = true
	db.coreClearWhenCombatEnd = false
	db.settingsAccountWide = true
	db.autoReturnInteraction = false
	db.shiftBarOffsetY = 9.1727294922
	db.minimumDurationSeconds = 3
	db.showDebug = false
	db.cooldownOpacity = 100
	db.alertFontSize = 32
	db.alertKeepSeconds = 2
	db.barLabelYOffset = 0
	db.positionGap = 13
	db.alertIconSize = 50
	db.alertFontName = "BOLD_FONT"
	db.coreMinimumDurationSeconds = 3
	db.coreSecondsBeforeFade = 1

end
