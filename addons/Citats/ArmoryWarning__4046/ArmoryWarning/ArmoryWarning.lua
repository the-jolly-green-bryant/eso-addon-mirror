ArmoryWarning = {}
ArmoryWarning.name = "ArmoryWarning"

function ArmoryWarning.OnAddOnLoaded(event, addonName)
	if addonName == ArmoryWarning.name then
		ArmoryWarning.Initialize()

		EVENT_MANAGER:UnregisterForEvent(ArmoryWarning.name, EVENT_ADD_ON_LOADED)
	end
end

function ArmoryWarning.Initialize()
	ESO_Dialogs["ARMORY_BUILD_SAVE_CONFIRM_DIALOG_ADDITIONAL"] =
	{
		gamepadInfo =
		{
			dialogType = GAMEPAD_DIALOGS.BASIC,
		},
		title =
		{
			text = "FINAL WARNING: SAVE OVER BUILD",
		},
		mainText =
		{
			text = "THIS IS YOUR FINAL WARNING. If you continue your previous build will be lost.",
		},
		buttons =
		{
			{
				text = SI_DIALOG_ACCEPT,
				keybind = "DIALOG_RESET",
				callback = function(dialog)
					local EXEMPTION_LIST =
					{
						"ARMORY_BUILD_SAVE_DIALOG",
						"ARMORY_BUILD_SAVE_SUCCESS_DIALOG",
						"ARMORY_BUILD_SAVE_FAILED_DIALOG",
					}
					ZO_Dialogs_SetDialogQueuePaused(true, EXEMPTION_LIST)
					SaveArmoryBuild(dialog.data.selectedBuildIndex)
				end,
			},
			{
				text = SI_DIALOG_CANCEL
			},
		}
	}

	ESO_Dialogs["ARMORY_BUILD_SAVE_CONFIRM_DIALOG"].title.text = "WARNING: SAVE OVER BUILD"
	ESO_Dialogs["ARMORY_BUILD_SAVE_CONFIRM_DIALOG"].buttons[1].callback = function(dialog)
		zo_callLater(function() ZO_Dialogs_ShowPlatformDialog("ARMORY_BUILD_SAVE_CONFIRM_DIALOG_ADDITIONAL", { selectedBuildIndex = dialog.data.selectedBuildIndex }) end, 0)
	end
end

EVENT_MANAGER:RegisterForEvent(ArmoryWarning.name, EVENT_ADD_ON_LOADED, ArmoryWarning.OnAddOnLoaded)