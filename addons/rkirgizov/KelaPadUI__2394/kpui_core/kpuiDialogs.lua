
function KelaPadUI:InitializeDialogs ()
	-- диалог для заблокированных вещей при изучении на станции
	ESO_Dialogs["KPUI_GAMEPAD_CONFIRM_RESEARCH_BLOCKED_ITEM"] = {
		gamepadInfo =
		{
			dialogType = GAMEPAD_DIALOGS.BASIC,
		},
		title = 
		{
			text = KELA_GAMEPAD_SMITHING_RESEARCH_CONFIRM_BLOCKED_DIALOG_TITLE,
		},
		mainText = 
		{
			text = KELA_GAMEPAD_SMITHING_RESEARCH_CONFIRM_BLOCKED_DIALOG_TEXT,
		},
		buttons =
		{
			[1] =
			{
				onShowCooldown = 2000,
				text = KELA_GAMEPAD_SMITHING_RESEARCH_CONFIRM_BLOCKED_DIALOG_ACCEPT,
				callback = function(dialog)
					dialog.data.itemUnlock = true
					SCENE_MANAGER:HideCurrentScene()
				end,
			},
			[2] =
			{
				text = SI_DIALOG_CANCEL
			},
		},
		finishedCallback = function(dialog)
			if dialog.data.itemUnlock then
				ResearchSmithingTrait(dialog.data.bagId, dialog.data.slotIndex)
			else
				SetItemIsPlayerLocked(dialog.data.bagId, dialog.data.slotIndex, true)
			end
		end,
		updateFn = function(dialog)
			if IsItemPlayerLocked(dialog.data.bagId, dialog.data.slotIndex) then 
				SetItemIsPlayerLocked(dialog.data.bagId, dialog.data.slotIndex, false)
			end
		end,
	}
end


-- esoui/ingame/globals/ingamedialogs.lua		примеры взять



-- esoui/libraries/zo_dialog/zo_dialog.lua
--
-- To show a dialog, call this function. 
-- The first parameter should be the name of the dialog (as definied in either InGameDialogs or PreGameDialogs). 
-- The second parameter should be an array table, containing any data that will be needed in the callback functions in the dialog
--      you want to display. 
-- The third parameter is a table, which contains parameters used when filling out the strings in your dialog.
--
-- If the main text in the dialog has 2 parameters (e.g "Hello <<1>> <<2>>"), then the 3rd parameter should contain a subtable called
-- mainTextParams which itself contains 2 members, the first will go into the <<1>> and the second will go into the <<2>>. The 3rd parameter
-- in ZO_Dialogs_ShowDialog can also contain a titleParams subtable which is used to fill in the parameters in the title, if needed.
--
-- So as an example, let's say you had defined a dialog in InGameDialogs called "TEST_DIALOG" with
--      title = { text = "Dialog <<1>>" } and mainText = { text = "Main <<1>> Text <<2>>" }
-- And you called 
--      ZO_Dialogs_ShowDialog("TEST_DIALOG", {5}, {titleParams={"Test1"}, mainTextParams={"Test2", "Test3"}})
-- The resulting dialog would have a title that read "Dialog Test1" and a main text field that read "Main Test2 Text Test3".
-- The 5 passed in the second parameter could be used by the callback functions to perform various tasks based on this value.
-- Dialogs themselves (see InGameDialogs.lua, etc.) must contain at least a "mainText" table, with at least the "text" member.
-- mainText.text is filled in using the mainTextParams subtable of the table passed in the 3rd parameter to ZO_Dialogs_ShowDialog. 
-- The mainText table can also optionally contain:
-- An "align" member to set the alignment of the text (TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT, or TEXT_ALIGN_CENTER....left is default).
-- A "timer" field, which indicates that a certain parameter should be treated as a sceonds in a timer, and converted to time format
--      (so if mainText contains "timer = 1", the 1st parameter in mainText.text is converted to time format before being placed
--      in the string).
--
-- Dialogs can also optionally contain:
-- 
-- A "title" table, which works the same way as "mainText" ("text", "align" and "title" fields are allowed), no title is shown if "title" is not set.
-- A "noChoiceCallback" field, which is executed when the dialog is closed without making a choice first.
-- A "hideSound" field, which is a sound id to be played when the dialog is closed without selecting an option
-- An "updateFn" field, which should be a function. If present, this function is called on each update when this dialog is showing.
-- An "editBox" field, which adds an edit box to the dialog. It can specify:
--      textType = The type of input the edit box accepts.
--      To get the value in the editbox, use ZO_Dialogs_GetEditBoxText.
-- A "warning" table, which works the same way as "mainText", which shows some red text at the bottom of the dialog to call attention to the specific action that is occuring
-- Finally, the is a "buttons" table, in which each member corresponds to a button. Dialogs support a maximum of 2 buttons.
-- If the buttons table is present, each of it's members in turn MUST contain a "text" field. Also, each button can optionally contain:
--      A "callback" function field (whose first parameter should always be "dialog"....use "dialog.data[i]" to reference the ith data member passed in).
--      A "clickSound" field that defines what sound to play when the button is clicked.
-- An option to show an animated loading icon near the main text, called "showLoadingIcon"
--
-- See the "DESTROY_AUGMENT_PROMPT" and "DEATH_PROMPT" dialogs in InGameDialogs.lua for examples of dialogs that use these various fields.