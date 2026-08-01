-------------------------------------------------------------------------------
-- Author
-- ragingpix3l
--
-- Full terms
-- https://account.elderscrollsonline.com/add-on-terms
--
---------------------------------------------------------------------------------
COOKIESMAILINFO = COOKIESMAILINFO or {}
local cmi = COOKIESMAILINFO

cmi.AddonName    = "CookiesMailInfo"
cmi.version      = "0.03"

cmi.averagePrices = {}

local AddonName = cmi.AddonName
local MAX_READ_ATTACHMENTS = MAIL_MAX_ATTACHED_ITEMS + 1

cmi.Initialized = false

local iDay = 60*60*24

function cmi.GetAvgPrice(itemLink)
    local averagePrices = cmi.averagePrices;
    if not averagePrices[itemLink]  then
        averagePrices[itemLink] = {}
    else
        return averagePrices[itemLink].perUnit
    end
    if MasterMerchant then
        local stats = MasterMerchant:itemStats(itemLink,false)

        if stats and stats.avgPrice then
            averagePrices[itemLink].perUnit = math.floor(stats.avgPrice)
            return stats.avgPrice
        end

    end
    if ArkadiusTradeTools and ArkadiusTradeTools.Modules and ArkadiusTradeTools.Modules.Sales then
        local atts = ArkadiusTradeTools.Modules.Sales
        averagePrices[itemLink].perUnit = math.floor(atts:GetAveragePricePerItem(itemLink, GetTimeStamp() - iDay * 10))
        return averagePrices[itemLink].perUnit
    end
    return 0
end


local function enableHooks()
    --Mail Inbox hook to display attached items price from ATT
    ZO_PostHook(MAIL_INBOX  , "OnMailReadable", function(self)
        --d("mail readable")

        if not self.mailId then
            return
        end

        if not cmi.Initialized then
            local wm = WINDOW_MANAGER
            local expiresControl = GetControl(self.messageControl, "Expires")

            if  expiresControl then
                local parent = expiresControl:GetParent()
                local label = wm:CreateControl("ItemsValue", parent, CT_LABEL)
                label:SetAnchor (TOPLEFT,expiresControl,BOTTOMLEFT,-40,40)
                label:SetFont("ZoFontWinH4")
                label:SetHeight(40)
                label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
                label:SetWidth(300)
                label.data = label.data or {}
                label.data.tooltipText = ""
                label:SetMouseEnabled(true)
                label:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
                label:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
                cmi.itemsValueLabel = label
                cmi.Initialized = true
            end
        end

        local mailData = self:GetMailData(self.mailId)
        local numAttachments = mailData.numAttachments
        --d ("Attachments : " .. numAttachments)
        local sum = 0
        local tooltipText = "Items value: "




        for i = 1, numAttachments do
            local inventorySlot = self.attachmentSlots[i]
            local slotType = ZO_InventorySlot_GetType(inventorySlot)
            if slotType == SLOT_TYPE_MAIL_ATTACHMENT then
                local index = ZO_Inventory_GetSlotIndex(inventorySlot)

                if index then
                    if not inventorySlot.money then
                        local itemLink = GetAttachedItemLink(self.mailId, index)
                        local _, stack, _ = GetAttachedItemInfo(self.mailId, index)
                        local avgPrice = cmi.GetAvgPrice(itemLink)
                        if not avgPrice  then avgPrice = 0 end
                        tooltipText = tooltipText .. "\n" .. itemLink .. " x " ..stack .." = " .. cmi.PrettyPrintAmount(math.floor(stack * (avgPrice) ))
                        sum = sum + stack * avgPrice
                    end
                end
            end


            --d(cmi.GetItemLinkFromInventorySlot(ZO_InventorySlot_GetInventorySlotComponents()))

            --d(GetItemLink(bag, index, LINK_STYLE_DEFAULT))
        end
        if sum > 0 then
            cmi.itemsValueLabel:SetText(cmi.PrettyPrintAmount(math.floor(sum)).." |t16:16:EsoUI/Art/currency/currency_gold.dds|t")
            cmi.itemsValueLabel.data.tooltipText = tooltipText
            cmi.itemsValueLabel:SetHidden(false)
        else
            cmi.itemsValueLabel:SetHidden(true)
        end
    end)
end

function cmi.PrettyPrintAmount(sGoldAmount)
    local s = tostring(sGoldAmount)
    local n = 1
    local ret = ""

    if string.len(s) <= 1 then
        return s
    end

    for i = string.len(s), 1, -1 do
        if n == 4 then
            ret = ret .. ","
            n = 1
        end
        ret = ret .. string.sub(s, i, i)
        n = n + 1
    end
    ret = string.reverse(ret)

    return ret
end

function cmi.Startup()


    --Load the hooks
    enableHooks()
end

function cmi.H_PlayerActivated (eventCode)

    EVENT_MANAGER:UnregisterForEvent(AddonName, eventCode)

    cmi.Startup()
end

local function onAddOnLoaded(eventCode, pAddonName)
    --As EVENT_ADD_ON_LOADED will be called for ALL addons from Z to A, in the order of ## (Optional)DependsOn:
    --Only run the code after this line for my own addon!

    if not pAddonName == AddonName then return end


    EVENT_MANAGER:UnregisterForEvent(AddonName, EVENT_ADD_ON_LOADED)

    EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_PLAYER_ACTIVATED, cmi.H_PlayerActivated)

end

EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_ADD_ON_LOADED, onAddOnLoaded)