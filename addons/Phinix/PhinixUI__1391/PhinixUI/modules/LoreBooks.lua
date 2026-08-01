
function PUIAddon.LoreBooks()

----------------------------------------------------------------------------------------------------------------
-- Initialize Saved Variable Database Reference
----------------------------------------------------------------------------------------------------------------
	local db = LBooks_SavedVariables.Default[GetDisplayName()]["$AccountWide"]

----------------------------------------------------------------------------------------------------------------
-- Configure Addon Settings
----------------------------------------------------------------------------------------------------------------
	db.pinTexture = {
		level = 40,
		size = 20,
		type = 2,
	}
	db.filters = {
		LBooksMapPin_unknown = true,
		LBooksCompassPin_unknown = true,
		LBooksCompassPin_eidetic = true,
		LBooksMapPin_eideticCollected = false,
		LBooksMapPin_bookshelf = false,
		LBooksMapPin_eidetic = true,
		LBooksMapPin_collected = false,
		LBooksCompassPin_bookshelf = false,
	}
	db.pinTextureEidetic = 4
	db.shareData = false
	db.immersiveMode = 1
	db.useQuestBooks = false
	db.pinGrayscale = true
	db.compassMaxDistance = 0.0400000000
	db.unlockEidetic = true
	db.pinGrayscaleEidetic = true

end
