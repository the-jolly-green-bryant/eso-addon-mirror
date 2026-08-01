

ESO_Dialogs["SORTIT_ERROR"] = {
	title = {
		text = "<<1>> ERROR",
	},
	mainText = {
		text = "<<1>>",
		align = TEXT_ALIGN_CENTER,
	},
	buttons = {
		[1] = {
			text = "Ok",
		},
	},
}
------------------------------------------------------------------------------------------------------------------
-- Create the parent loot window 																				--
------------------------------------------------------------------------------------------------------------------
 function SortIt.ShowErrorDialog(_sErrorType, _sErrorMessage)
	ZO_Dialogs_ShowDialog("SORTIT_ERROR", nil, {titleParams={_sErrorType}, mainTextParams={_sErrorMessage}})
end
