local AddonName = "MailItemsSummary"

function MailItemsSummary ()
    if not SCENE_MANAGER:IsShowing('mailSend') then
        return
    end
    local s = ""
    local bid=BAG_BACKPACK
    local tp=0
    for idx=0,GetBagSize(bid)-1 do
        local lnk = GetItemLink(bid, idx)
        local _,cnt,_, _,lk=GetItemInfo(bid, idx)
        if lk then
            p = xprice(lnk)
            s = s..lnk.."x"..cnt.." "..p.."="..cnt*p.."\n"
            tp=tp+p*cnt
        end
    end
    ZO_MailSendBodyField:SetText(s.."\n"..tp)
end


function xprice(lnk)
    if ArkadiusTradeTools and ArkadiusTradeTools.Modules and ArkadiusTradeTools.Modules.Sales then
        local ATTS = ArkadiusTradeTools.Modules.Sales
        return math.floor(ATTS:GetAveragePricePerItem(lnk, GetTimeStamp() - 60*60*24*10))
    end
    return 0
end

function onAddOnLoaded(_,addonName)

    if addonName~=AddonName then return end
    EVENT_MANAGER:UnregisterForEvent(AddonName, EVENT_ADD_ON_LOADED)
    zo_callLater(function ()
        SLASH_COMMANDS["/mis"] = MailItemsSummary
    end, 1200)



end

EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_ADD_ON_LOADED, onAddOnLoaded)
