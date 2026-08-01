local ADDON="WrittenItemQuality"

local QUALITY={
 [0]={"JUNK","808080"},
 [1]={"NORMAL","FFFFFF"},
 [2]={"FINE","2DC50E"},
 [3]={"SUPERIOR","3A92FF"},
 [4]={"EPIC","A02EF7"},
 [5]={"LEGENDARY","CDA100"},
 [6]={"MYTHIC","CC7A00"},
}

local function AddQuality(tt, link)
    if not link or link=="" then return end
    local q=(GetItemLinkDisplayQuality and GetItemLinkDisplayQuality(link)) or GetItemLinkQuality(link)
    local d=QUALITY[q]
    if not d then return end
    tt:AddVerticalPadding(4)
    tt:AddLine(("|c%s[%s]|r"):format(d[2], d[1]))
end

local function Hook(ctrl, fn, linkfn)
    if not ctrl or not ctrl[fn] then return end
    ZO_PostHook(ctrl, fn, function(_, ...)
        local ok, link = pcall(linkfn, ...)
        if ok and link then AddQuality(ctrl, link) end
    end)
end

local function Link(l) return l end

local function OnLoaded(_, addon)
    if addon~=ADDON then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON, EVENT_ADD_ON_LOADED)

    local hooks={
        {PopupTooltip,"SetLink",Link},
        {ItemTooltip,"SetLink",Link},
        {ItemTooltip,"SetBagItem",GetItemLink},
        {ItemTooltip,"SetStoreItem",GetStoreItemLink},
        {ItemTooltip,"SetLootItem",GetLootItemLink},
        {ItemTooltip,"SetBuybackItem",GetBuybackItemLink},
        {ItemTooltip,"SetTradingHouseItem",GetTradingHouseSearchResultItemLink},
        {ItemTooltip,"SetTradingHouseListing",GetTradingHouseListingItemLink},
        {ItemTooltip,"SetAttachedMailItem",GetAttachedItemLink},
        {ItemTooltip,"SetReward",GetItemRewardItemLink},
        {ItemTooltip,"SetQuestReward",GetQuestRewardItemLink},
        {ItemTooltip,"SetTradeItem",GetTradeItemLink},
        {ItemTooltip,"SetWornItem",function(slot,bag) return GetItemLink(bag,slot) end},
    }
    for _,h in ipairs(hooks) do Hook(h[1],h[2],h[3]) end
end

EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_ADD_ON_LOADED, OnLoaded)
