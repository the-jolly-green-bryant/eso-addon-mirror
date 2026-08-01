local BR = BreakReminder

local function EditNoteDialogSetup(dialog, data)
    GetControl(dialog, "TimerEdit"):SetText(data and data.delay or 10)
    GetControl(dialog, "NoteEdit"):SetText(data and data.note or "")
    -- When nil or true, checked. If false, unchecked
    ZO_CheckButton_SetCheckState(GetControl(dialog, "RememberCheckBox"), not (data and type(data.remember) == 'boolean' and not data.remember))
end

function BreakReminder_EditDialog_OnItilialized(self)
    ZO_Dialogs_RegisterCustomDialog("BREAKREMINDER_EDIT_TIMER",
        {
            customControl = self,
            setup = EditNoteDialogSetup,
            title =
            {
                text = BREAKREMINDER_DIALOG_TITLE,
            },
            buttons =
            {
                {
                    control = GetControl(self, "Save"),
                    text = SI_SAVE,
                    callback = function(dialog)
                        local delay = tonumber(GetControl(dialog, "TimerEdit"):GetText()) or 10
                        local note = GetControl(dialog, "NoteEdit"):GetText()
                        local remember = ZO_CheckButton_IsChecked(GetControl(dialog, "RememberCheckBox"))
                        BR.AddReminder(delay, note, remember)
                    end,
                },
                {
                    control = GetControl(self, "Cancel"),
                    text = SI_DIALOG_CANCEL,
                }
            }
        })
end

function BreakReminder_EditDialog_Hide(owner)
    if (not owner or BreakReminder_EditDialog.owner == owner) then
        BreakReminder_EditDialog:SetHidden(true)
    end
end

-- /script BreakReminder.dialogs_show("BREAKREMINDER_EDIT_TIMER")
-- /script d(BreakReminder.GetSettings().reminders)
function BR.dialogs_show(name, data)
    ZO_Dialogs_ShowDialog(name, data)
end
