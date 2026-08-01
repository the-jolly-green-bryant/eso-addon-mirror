--[[
Title:   Key Handling
Version: 1.1.0
Author:  @Skotharr-do [PC/EU]
--]]

function InCharacterToggleReticleWindow()
	IC.ReticleWindow.SetEnabled(not IC.ReticleWindow.IsEnabled())
	if IC.ReticleWindow.IsEnabled() then
		CHAT_SYSTEM:AddMessage(GetString(SI_INCHARACTER_COMMAND_RETICLE_WINDOW_ENABLED))
	else
		CHAT_SYSTEM:AddMessage(GetString(SI_INCHARACTER_COMMAND_RETICLE_WINDOW_DISABLED))
	end
end

function InCharacterToggleEditWindow()
	if IC.EditWindow.IsOpen() then
		IC.EditWindow.Close()
	else
		IC.EditWindow.OpenAndFocus()
	end
end

function InCharacterWriteCharacterDescriptionToChatInput(number)
	IC.CharacterWide.WriteToChatInput(IC.CharacterWide.FindDescriptionByKeyNumber(number))
end

function InCharacterWriteCurrentCharacterDescriptionToChatInput()
	IC.CharacterWide.WriteCurrentDescriptionToChatInput()
end