
function PUIAddon.MapPins()

----------------------------------------------------------------------------------------------------------------
-- Initialize Saved Variable Database Reference
----------------------------------------------------------------------------------------------------------------
	local sg = MP_SavedGlobal.Default[GetDisplayName()]["$AccountWide"]
	local sc = MP_SavedVars.Default[GetDisplayName()][GetUnitName('player')]

----------------------------------------------------------------------------------------------------------------
-- Configure Addon Settings
----------------------------------------------------------------------------------------------------------------
	sg.pinsize = 20

	sc = {
		[1] = true,
		[2] = true,
		[3] = false,
		[4] = false,
		[5] = false,
		[6] = true,
		[7] = false,
		[8] = true,
		[9] = true,
		[10] = false,
		[11] = false,
		[12] = false,
		[13] = false,
		[14] = false,
		[15] = true,
		[16] = true,
		[17] = false,
		[18] = false,
		[19] = false,
		[21] = true,
	}

end
