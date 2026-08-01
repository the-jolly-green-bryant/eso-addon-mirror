
function PUIAddon.Recharge()

----------------------------------------------------------------------------------------------------------------
-- Initialize Saved Variable Database Reference
----------------------------------------------------------------------------------------------------------------
	local db = AutoRecharge_SavedVariables[GetWorldName()][GetDisplayName()]["$AccountWide"]["Settings"]

----------------------------------------------------------------------------------------------------------------
-- Configure Addon Settings
----------------------------------------------------------------------------------------------------------------
	db.AccountWide = true
	db.alertRepairKitsEmptyOnLogin = true
	db.chatOutputSuppressNothingMessages = true
	db.alertRepairKitsEmpty = false
	db.alertSoulGemsEmpty = false
	db.minConditionPercent = 0
	db.alertSoulGemsSoonEmpty = false
	db.useRepairKitForItemLevel = false
	db.repairDelay = 500
	db.alertSoulGemsEmptyOnLogin = true
	db.alertRepairKitsSoonEmptyThreshold = 10
	db.alertRepairKitsSoonEmpty = false
	db.chargeDuringCombat = true
	db.alertSoulGemsSoonEmptyThreshold = 20
	db.chargeOnWeaponChangeOnlyInCombat = true
	db.chargeOnWeaponChange = false
	db.minChargePercent = 0
	db.repairEnabled = true
	db.dontUseCrownRepairKits = true
	db.chargeEnabled = true
	db.chatOutput = true
	db.showRepairKitsLeftAtVendor = false
	db.rechargeDelay = 500
	db.repairDuringCombat = false

end
