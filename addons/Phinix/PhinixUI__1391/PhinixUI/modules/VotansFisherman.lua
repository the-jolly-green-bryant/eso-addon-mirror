
function PUIAddon.VotansFisherman()

----------------------------------------------------------------------------------------------------------------
-- Initialize Saved Variable Database Reference
----------------------------------------------------------------------------------------------------------------
	local db = VotansFisherman_Data.Default[GetDisplayName()]["$AccountWide"]

----------------------------------------------------------------------------------------------------------------
-- Configure Addon Settings
----------------------------------------------------------------------------------------------------------------
	db.lureColors = {
		[4] = "345FE2",
		[1] = "C2C444",
		[2] = "7CAECC",
		[3] = "2ECCBE",
	}
	db.pinIcon = {
		[4] = "default",
		[1] = "default",
		[2] = "default",
		[3] = "default",
	}
	db.reelInColor = "FFFFFF"
	db.notificationAnim = "Pulse1"
	db.autoReturnInteraction = false
	db.showLootOnHUD = true
	db.showReelIn = true
	db.showLootOnMap = true
	db.pinSize = 24
	db.autoHideRFT = false
	db.reelInSize = 1
	db.showPins = false
	db.pinLevel = 30
	db.showDefaultLoot = false
	db.showContextMenu = true
	db.showTooltip = true
	db.showDebug = false
	db.autoSwitchBait = false
	db.preferBetterBait = false

end
