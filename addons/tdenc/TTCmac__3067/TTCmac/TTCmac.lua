TTCmac = {}
TTCmac.name = "TTCmac"

local function ShowMessage(title, subtext)
    local updateDialog =
    {
        title = { text =  title},
        mainText = { text = "Launch Client/TTCmac.app in Addon folder, update price table and then /reloadui." .. subtext },
        buttons =
        {
            {
                text = "OK"
            }
        }
    }
    ZO_Dialogs_RegisterCustomDialog("TTCmacDialog", updateDialog)
    ZO_Dialogs_ReleaseDialog("TTCmacDialog", false)
    ZO_Dialogs_ShowDialog("TTCmacDialog")
end

function TTCmac:Initialize()
    if (TamrielTradeCentre.LoadItemLookUpTable == nil) then
        ZO_Dialogs_ReleaseDialog("TamrielTradeCentreDialog", false)
        ShowMessage("TTC data is missing", "\nIf you have a trouble, allow app to access \"Documents\" folder:\nChoose Apple menu > System Preferences, click Security & Privacy, click Privacy, select Files and Folders, and select the checkbox below TTCmac.app.")
    else
        local currentStatus = TamrielTradeCentrePrice:GetPriceTableUpdatedDateString()
        local updatedString = TamrielTradeCentre:GetString("TTC_PRICE_UPDATEDTODAY")
        if (currentStatus ~= updatedString) then
            ShowMessage("TTC data is outdated", "")
        end
    end
    EVENT_MANAGER:UnregisterForEvent( TTCmac.name, EVENT_ADD_ON_LOADED)
end

function TTCmac.OnAddOnLoaded(event, addonName)
    if (addonName == TTCmac.name) then
        TTCmac:Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(TTCmac.name, EVENT_ADD_ON_LOADED, TTCmac.OnAddOnLoaded)