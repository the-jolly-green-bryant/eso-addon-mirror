function LovelyEmotes.PlayWindowOpenSound()
	PlaySound("Window_Open")
end

function LovelyEmotes.PlayWindowCloseSound()
	PlaySound("Window_Close")
end

function LovelyEmotes.PlayTabSound()
	if LovelyEmotes_Settings.SavedAccountVariables.EnableAlternativeSounds then
		PlaySound("Book_Open")
	else
		PlaySound("Click")
	end
end

function LovelyEmotes.UpdateButtonClickSounds(alternativeSounds)
	local parentControl = LE_MainWindowControl

	if alternativeSounds then
		parentControl:GetNamedChild("LockButton"):SetClickSound("Lock_Value")
		LovelyEmotes.MainWindow.UpdateModeButtonClickSound("Click_MenuBar")
		return
	end

	parentControl:GetNamedChild("LockButton"):SetClickSound("Click")
	LovelyEmotes.MainWindow.UpdateModeButtonClickSound("Click")
end
