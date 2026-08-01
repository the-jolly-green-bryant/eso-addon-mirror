local dialog =
{
    title = { text = "Confirm Training" },
    mainText = { text = "<<1>>" },
    buttons =
    {
        {
            text = SI_DIALOG_ACCEPT,
            callback = function(dialog)
                ZO_Stable_TrainButtonClicked(dialog.data[1])
            end
        },
        {
            text = SI_DIALOG_CANCEL,
        }
    }
}
ZO_Dialogs_RegisterCustomDialog("HarvensHorseFeedConfirmation", dialog)

local function FeedConfirmation(button, feedType)
	ZO_Dialogs_ShowDialog("HarvensHorseFeedConfirmation", {button}, {mainTextParams={GetString(feedType)}})
end

ZO_StablePanelSpeedTrainRowTrainButton:SetHandler("OnClicked", function(button) FeedConfirmation(button, SI_RIDINGTRAINTYPE1) end)
ZO_StablePanelStaminaTrainRowTrainButton:SetHandler("OnClicked", function(button) FeedConfirmation(button, SI_RIDINGTRAINTYPE3) end)
ZO_StablePanelCarryTrainRowTrainButton:SetHandler("OnClicked", function(button) FeedConfirmation(button, SI_RIDINGTRAINTYPE2) end)