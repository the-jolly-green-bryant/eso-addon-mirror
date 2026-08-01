--[[
Title:   Character-Wide Data
Version: 1.1.3
Author:  @Skotharr-do [PC/EU]
--]]

IC.CharacterWide = {}

local CHARACTER_WIDE_VERSION = 3

local characterWide = {
	icVersion = 1,
	descriptions = {},
	selectedDescriptionKey = 'Default',
	ui = {
		reticleWindow = {
			offsetX = GuiRoot:GetWidth() / 2 - 250,
			offsetY = GuiRoot:GetHeight() / 2,
			width = 500,
			anchor = TOP,
			alpha = 1,
			backgroundAlpha = 0.8,
			enabled = true,
			alwaysVisible = false,
			timestampVisible = true
		},
		editWindow = {
			width = 500,
			height = 400
		}
	}
}

function IC.CharacterWide.AcquireDescriptions(key)
	local descriptions = characterWide.descriptions
	descriptions[key] = IC.Utility.ReturnTable(descriptions[key])
	return descriptions[key]
end

function IC.CharacterWide.DeleteDescription(key)
	local descriptions = characterWide.descriptions
	if descriptions[key] ~= nil then
		descriptions[key] = nil
	end
end

function IC.CharacterWide.MoveDescription(oldKey, newKey)
	local descriptions = characterWide.descriptions
	descriptions[newKey] = descriptions[oldKey]
	IC.CharacterWide.DeleteDescription(oldKey)
	return descriptions[newKey]
end

function IC.CharacterWide.InitializeDescription(description, name)
	description.name = name
	description.text = ''
	description.outfitIndex = nil
	description.keyNumber = nil
end

function IC.CharacterWide.GetDescriptionCount()
	local counter = 0
	for _ in pairs(characterWide.descriptions) do
		counter = counter + 1
	end
	return counter
end

function IC.CharacterWide.GetCurrentDescriptionKey()
	return characterWide.selectedDescriptionKey
end

function IC.CharacterWide.SetCurrentDescriptionKey(key)
	characterWide.selectedDescriptionKey = key
end

function IC.CharacterWide.GetCurrentDescription()
	return IC.CharacterWide.AcquireDescriptions(IC.CharacterWide.GetCurrentDescriptionKey())
end

function IC.CharacterWide.GetDescriptions()
	return characterWide.descriptions
end

function IC.CharacterWide.WriteToChatInput(description)
	if description ~= nil and description.text ~= nil then
		StartChatInput(IC.Keywords.Default.STRING..description.text)
	end
end

function IC.CharacterWide.WriteCurrentDescriptionToChatInput()
	IC.CharacterWide.WriteToChatInput(IC.CharacterWide.GetCurrentDescription())
end

function IC.CharacterWide.FindDescriptionByKey(key)
	local descriptions = characterWide.descriptions
	for _, description in pairs(descriptions) do
		if description.name == key then
			return description
		end
	end
	return nil
end

function IC.CharacterWide.FindDescriptionByOutfitIndex(outfitIndex)
	if outfitIndex == nil then
		return nil
	end
	local descriptions = characterWide.descriptions
	for _, description in pairs(descriptions) do
		if description.outfitIndex == outfitIndex then
			return description
		end
	end
	return nil
end

function IC.CharacterWide.FindDescriptionByKeyNumber(keyNumber)
	if keyNumber == nil then
		return nil
	end
	local descriptions = characterWide.descriptions
	for _, description in pairs(descriptions) do
		if description.keyNumber == keyNumber then
			return description
		end
	end
	return nil
end

function IC.CharacterWide.HasDescription(key)
	return IC.CharacterWide.FindDescriptionByKey(key) ~= nil
end

function IC.CharacterWide.IsOutfitIndexAssigned(outfitIndex)
	return IC.CharacterWide.FindDescriptionByOutfitIndex(outfitIndex) ~= nil
end

function IC.CharacterWide.IsKeyNumberAssigned(keyNumber)
	return IC.CharacterWide.FindDescriptionByKeyNumber(keyNumber) ~= nil
end

function IC.CharacterWide.GetReticleWindow()
	return characterWide.ui.reticleWindow
end

function IC.CharacterWide.GetEditWindow()
	return characterWide.ui.editWindow
end

local function MigrateSaves()
	if characterWide.icVersion >= CHARACTER_WIDE_VERSION then
		return
	end	
	
	-- step by step migrate to newer versions
	if characterWide.icVersion == 1 then
		characterWide.ui.editWindow.height = 400
	
		local characterDescription = IC.AccountWide.ReadCharacter(IC.Utility.GetCurrentAccountName(), IC.Utility.GetCurrentCharacterName())
		local descriptionText = ''
		if characterDescription ~= nil then
			descriptionText = characterDescription.description
		else
			descriptionText = ''
		end
		characterWide.descriptions = {
								Default = {
										name = 'Default',
										text = descriptionText
									}
								}
		
		characterWide.icVersion = 2
	end
	if characterWide.icVersion == 2 then
		characterWide.ui.reticleWindow.timestampVisible = true
		characterWide.icVersion = 3
	end
	-- if characterWide.icVersion == 3 then
		-- HelloWorld()
		-- characterWide.icVersion = 4
	-- end
end

function IC.CharacterWide.Initialize()
	characterWide = ZO_SavedVars:NewCharacterNameSettings(IC.Addon.SAVED_VARIABLES_NAME, IC.Addon.SAVED_VARIABLES_VERSION, nil, characterWide, nil)
	MigrateSaves()
end