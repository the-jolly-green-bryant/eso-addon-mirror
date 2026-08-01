
function PUIAddon.Postmaster()

----------------------------------------------------------------------------------------------------------------
-- Initialize Saved Variable Database Reference
----------------------------------------------------------------------------------------------------------------
	local db = Postmaster_Account[GetWorldName()][GetDisplayName()]["$AccountWide"]

----------------------------------------------------------------------------------------------------------------
-- Configure Addon Settings
----------------------------------------------------------------------------------------------------------------
	db.chatContentsSummary = {
		sorted = false,
		enabled = false,
	}
	db.deleteDialogSuppress = true
	db.quickTakePlayerAttached = false
	db.takeAllPlayerAttached = false
	db.coloredPrefix = true
	db.quickTakeCodTake = false

end
