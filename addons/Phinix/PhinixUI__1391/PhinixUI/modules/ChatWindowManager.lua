
function PUIAddon.ChatWindowManager()

----------------------------------------------------------------------------------------------------------------
-- Initialize Saved Variable Database Reference
----------------------------------------------------------------------------------------------------------------
	local db = ChatWindowManager[GetWorldName()][GetDisplayName()]["$AccountWide"]

----------------------------------------------------------------------------------------------------------------
-- Configure Addon Settings
----------------------------------------------------------------------------------------------------------------
	db.bOffset = 0
	db.sOffset = 0
	db.chatstate = 1
	db.AutoHideChat = true
	db.AddStatusSelect = true
	db.AddReloadButton = true
	db.RememberState = true
	db.StatusChat = true
	db.sBuffer = true
	db.HideFriendLogin = true
	db.reloadConfirm = true
	db.ReloadConfirm = true
	db.SimpleDelete = true
end
