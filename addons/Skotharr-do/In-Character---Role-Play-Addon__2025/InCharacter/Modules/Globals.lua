--[[
Title:   Global Variables and Constants
Version: 1.1.0
Author:  @Skotharr-do [PC/EU]
--]]

IC = {}

IC.Addon = {
	NAME = 'InCharacter',
	SAVED_VARIABLES_NAME = 'InCharacter_SavedVariables',
	SAVED_VARIABLES_VERSION = 1,
	SLASH_COMMAND = '/ic'
}

IC.Keywords = {
	Default = {
		STRING = '\194\160', -- Unicode 'No-Break Space' in UTF-8, " "
		BYTE_COUNT = 2, -- takes 2 bytes in UTF-8
		CHARACTER_COUNT = 1 -- is just 1 character
	},
	Alternative = {
		STRING = 'ic/',
		BYTE_COUNT = 3,
		CHARACTER_COUNT = 3
	}
}

IC.UI = {
	menuVisible = false,
	reticleHidden = false
}