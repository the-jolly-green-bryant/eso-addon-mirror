--[[
Title:   Utility Functions
Version: 1.1.0
Author:  @Skotharr-do [PC/EU]
--]]

IC.Utility = {}

local PLAYER = 'player'

function IC.Utility.IsTable(input)
	return type(input) == 'table'
end

function IC.Utility.ReturnTable(input)
    if IC.Utility.IsTable(input) then
	  return input
	end
	return {}
end

function IC.Utility.GetCurrentAccountName()
	return GetUnitDisplayName(PLAYER)
end

function IC.Utility.GetCurrentCharacterName()
	return GetUnitName(PLAYER)
end

function IC.Utility.IsCurrentCharacter(characterName)
	return characterName == IC.Utility.GetCurrentCharacterName()
end