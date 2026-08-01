--- ESO Farm-Buddy AddOn written by Keldor

ESOFarmBuddyUtils = {}


function ESOFarmBuddyUtils:GetTableIndexByFieldValue(table, field, value)

    local status = false

    for key, obj in ipairs(table) do
        if type(obj[field]) ~= "nil" then
            if obj[field] == value then
                status = key
            end
        end
    end

    return status
end

function ESOFarmBuddyUtils:SetTableIndexByFieldValue(svTable, field, value, default)

    local tableIndex = ESODBUtils:GetTableIndexByFieldValue(svTable, field, value)
    if tableIndex == false then
        table.insert(svTable, default)
        tableIndex = #svTable
    end

    return tableIndex
end

function ESOFarmBuddyUtils:split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function ESOFarmBuddyUtils:ChatMsg(msg)
    CHAT_SYSTEM:AddMessage("[|c2080D0" .. ESOFarmBuddy.DisplayName .. "|r] " .. msg)
end

function ESOFarmBuddyUtils:GetItemData(itemLink)

    local name = GetItemLinkName(itemLink)
    local quality = GetItemLinkQuality(itemLink)
    local qualityColors = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, quality))
    local stackCountBackpack, stackCountBank, stackCountCraftBag = GetItemLinkStacks(itemLink)
    local displayCount = stackCountBackpack

    if ESOFarmBuddy.SV.Settings.IncludeBank == true then
        displayCount = displayCount + stackCountBank
    end
    if ESOFarmBuddy.SV.Settings.IncludeCraftBag == true then
        displayCount = displayCount + stackCountCraftBag
    end

    return {
        Name = zo_strformat(SI_TOOLTIP_ITEM_NAME, name),
        QualityColors = qualityColors,
        DisplayCount = displayCount
    }
end

function ESOFarmBuddyUtils:GetPercent(count, total)

    if count == 0 or total == 0 then
        return 0
    end

    return math.floor(count / total * 100)
end

function ESOFarmBuddyUtils:IsItemIdInSVList(itemId)

    for _, itemTable in pairs(ESOFarmBuddy.SV.ItemList) do
        if itemTable.ItemID == itemId then
            return true
        end
    end

    return false
end

function ESOFarmBuddyUtils:RemoveItemFromList(itemId)

    local tableIndex = ESOFarmBuddyUtils:GetTableIndexByFieldValue(ESOFarmBuddy.SV.ItemList, "ItemID", itemId)
    table.remove(ESOFarmBuddy.SV.ItemList, tableIndex)
    ESOFarmBuddy.RemoveItemIdFromNotificationList(itemId)
    ESOFarmBuddy.RefreshItemList()
end

function ESOFarmBuddyUtils:split(s, delimiter)
    local result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result
end
