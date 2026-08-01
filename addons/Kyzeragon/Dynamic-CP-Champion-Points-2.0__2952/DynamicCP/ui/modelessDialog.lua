local currentCallback = nil

---------------------------------------------------------------------
-- Window
---------------------------------------------------------------------
-- On move stop
function DynamicCP.SaveModelessDialogPosition()
    local x, y = DynamicCPModelessDialog:GetCenter()
    local cX, cY = GuiRoot:GetCenter()
    DynamicCP.savedOptions.modelessX = x - cX
    DynamicCP.savedOptions.modelessY = y - cY
end

function DynamicCP.OnModelessConfirm()
    if (not currentCallback) then
        DynamicCP.msg("There is no dialog to confirm.")
        return
    end

    currentCallback()
    currentCallback = nil
    DynamicCPModelessDialog:SetHidden(true)
end

function DynamicCP.OnModelessCancel()
    currentCallback = nil
    DynamicCPModelessDialog:SetHidden(true)
end

---------------------------------------------------------------------
-- API
function DynamicCP.ShowModelessPrompt(text, callback)
    DynamicCPModelessDialogLabel:SetFont(DynamicCP.GetStyles().gameFont)
    DynamicCPModelessDialogLabel:SetHeight(800)
    DynamicCPModelessDialogLabel:SetText(text)
    local labelHeight = DynamicCPModelessDialogLabel:GetTextHeight() + 5 -- For some reason, U41 makes the text not fit with enough lines?
    DynamicCPModelessDialogLabel:SetHeight(labelHeight)
    DynamicCPModelessDialog:SetHeight(labelHeight + 70)
    DynamicCPModelessDialog:SetHidden(false)
    currentCallback = callback

    -- Update the keybinds in case
    local layerIndex, categoryIndex, actionIndex = GetActionIndicesFromName("DCP_DIALOG_CONFIRM")
    local keyCode, mod1, mod2, mod3, mod4 = GetActionBindingInfo(layerIndex, categoryIndex, actionIndex, 1)
    local confirmString = ZO_Keybindings_GetBindingStringFromKeys(keyCode, mod1, mod2, mod3, mod4)
    DynamicCPModelessDialogConfirmLabel:SetFont(DynamicCP.GetStyles().smallFont)
    DynamicCPModelessDialogConfirmLabel:SetText(confirmString)
    DynamicCPModelessDialogConfirmLabel:SetWidth(80)
    DynamicCPModelessDialogConfirmLabel:SetWidth(DynamicCPModelessDialogConfirmLabel:GetTextWidth())

    layerIndex, categoryIndex, actionIndex = GetActionIndicesFromName("DCP_DIALOG_CANCEL")
    keyCode, mod1, mod2, mod3, mod4 = GetActionBindingInfo(layerIndex, categoryIndex, actionIndex, 1)
    local cancelString = ZO_Keybindings_GetBindingStringFromKeys(keyCode, mod1, mod2, mod3, mod4)
    DynamicCPModelessDialogCancelLabel:SetFont(DynamicCP.GetStyles().smallFont)
    DynamicCPModelessDialogCancelLabel:SetText(cancelString)
end

-- Only called when player enters combat
function DynamicCP.TemporarilyHideModelessPrompt()
    if (DynamicCPModelessDialog:IsHidden()) then return end
    -- So this is if there's a dialog currently showing, but player enters combat
    -- Then we shouldn't remove the callback and instead only hide the dialog so it can be shown after exiting combat
    DynamicCPModelessDialog:SetHidden(true)
    return true
end


---------------------------------------------------------------------
-- Init
function DynamicCP.InitModelessDialog()
    DynamicCPModelessDialog:SetAnchor(CENTER, GuiRoot, CENTER, DynamicCP.savedOptions.modelessX, DynamicCP.savedOptions.modelessY)
end
