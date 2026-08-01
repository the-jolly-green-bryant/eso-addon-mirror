local L = EasyTravel_AEM.Localization

local JUMP_STATUS_DIALOG = "EasyTravelDialog"

local DialogHelper = ZO_Object:Subclass()

function DialogHelper:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

function DialogHelper:Initialize()
    local function ClearDialog()
        CancelCast()
        self.dialog = nil
    end

    local function Update()
        if(not self.countdown) then return end
        local remaining = math.max(self.countdown - GetTimeStamp(), 0)
        self:SetTextParameter(remaining)
    end

    self.dialogInfo = {
        canQueue = true,
        showLoadingIcon = ZO_Anchor:New(BOTTOM, ZO_Dialog1Text, BOTTOM, 0, 40),
        title = {
            text = L["DIALOG_TITLE"],
        },
        mainText = {
            align = TEXT_ALIGN_CENTER,
            text = "",
        },
        buttons = {
            {
                text = SI_DIALOG_CANCEL,
                keybind = "DIALOG_NEGATIVE",
            }
        },
        updateFn = Update,
        finishedCallback = ClearDialog,
    }

    ESO_Dialogs[JUMP_STATUS_DIALOG] = self.dialogInfo
end

function DialogHelper:ShowDialog(zoneName)
    self.dialog = ZO_Dialogs_ShowDialog(JUMP_STATUS_DIALOG, {}, {titleParams = {zoneName}})
end

function DialogHelper:HideDialog()
    ZO_Dialogs_ReleaseDialog(JUMP_STATUS_DIALOG)
end

function DialogHelper:SetText(text)
    if(not self.dialog) then return end
    ZO_Dialogs_UpdateDialogMainText(self.dialog, {text=text})
    self.currentText = text
end

function DialogHelper:SetTextParameter(parameter)
    if(not self.dialog) then return end
    ZO_Dialogs_UpdateDialogMainText(self.dialog, {text=self.currentText}, {parameter})
end

function DialogHelper:SetCountdown(length)
    self.countdown = GetTimeStamp() + length
end

function DialogHelper:ClearCountdown()
    self.countdown = nil
end

EasyTravel_AEM.DialogHelper = DialogHelper:New()
