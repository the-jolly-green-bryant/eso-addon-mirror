
function PUIAddon.ParlezPlus()

----------------------------------------------------------------------------------------------------------------
-- Initialize Saved Variable Database Reference
----------------------------------------------------------------------------------------------------------------
	local db = ParlezPlusSavedVariables.Default[GetDisplayName()]["$AccountWide"]

----------------------------------------------------------------------------------------------------------------
-- Configure Addon Settings
----------------------------------------------------------------------------------------------------------------
	db.Flags = {
		NewlineAfterNPCText = true,
		DelayedNPCResponse = false,
		NPCNameOwnLine = false,
		DisplayPlayerName = true,
		PlayerNameOwnLine = false,
		DisplayDialogTitle = false,
		InsertResponseOptionIndex = false,
		DisplayNPCName = true,
		NewlineAfterPlayerText = true,
		DisplayPlayerText = true,
	}
	db.TextColor = {
		PlayerDuplicateResponse = {
			[1] = 110,
			[2] = 90,
			[3] = 70,
		},
		NPCDuplicateText = {
			[1] = 187,
			[2] = 187,
			[3] = 187,
		},
		NPCText = {
			[1] = 245,
			[2] = 245,
			[3] = 245,
		},
		PlayerResponse = {
			[1] = 255,
			[2] = 200,
			[3] = 100,
		},
	}
	db.Timeout = {
		NPCAfterResponse = 600,
	}
	db.FormatString = {
		PlayerNameFormat = "{u}{{name}}:{/u} ",
		NPCNameFormat = "{u}{{name}}:{/u} ",
	}

end
