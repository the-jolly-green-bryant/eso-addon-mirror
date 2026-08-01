local fm = FarmManager
local classes = fm.classes
local window = FarmManagerWindow
local itemList = {}
local totalFarmed = 0

classes.FarmManagerMainWindow = ZO_Object:Subclass()

local function ToGold(amount)
	return ZO_CurrencyControl_FormatCurrencyAndAppendIcon(amount, false, CURT_MONEY, false)
end

function classes.FarmManagerMainWindow:New(...)
    local object = ZO_Object.New(self)
    object:Init(...)
    return object
end

function classes.FarmManagerMainWindow:Init()
    itemList = window:GetNamedChild("DetailPanel"):GetNamedChild("FmItemList")
    ZO_ScrollList_AddDataType(itemList, 1, "FarmManagerGUIItemListItemTemplate", 30, function(control, data) self:UpdateDataRow(control, data) end)
end

function classes.FarmManagerMainWindow:Show()
    window:SetHidden(false)
end

function classes.FarmManagerMainWindow:Hide()
    window:SetHidden(true)
end

function classes.FarmManagerMainWindow:UpdateDataRow(control, data)
	control:GetNamedChild("Icon"):SetTexture(data.texture)
	control:GetNamedChild("NameLabel"):SetText(zo_strformat('<<t:1>>', data.itemLink))
	control:GetNamedChild("CountsLabel"):SetText(data.quantityFarmed)
    control:GetNamedChild("PriceLabel"):SetText(ToGold(math.floor(data.totalValueFarmed)))
    window:GetNamedChild("TotalLabel"):SetText(ToGold(math.floor(fm.farmer.totalValueFarmed or 0)))
	window:GetNamedChild("GoldPerSecondLabel"):SetText(ToGold(math.floor(fm.farmer:GetGoldPerSecond() * 60)).."/min")
end

function classes.FarmManagerMainWindow:OnItemFarmed(item, actionType)
	local scrollData = ZO_ScrollList_GetDataList(itemList)
	local found = false
	for _, itemData in pairs(scrollData) do
		if itemData.data.itemId == item.itemId then
            itemData.data:Add(item, actionType)
			found = true
			break
		end
	end

	if not found then
		local data = FmDetailEntry:New(item, actionType)
		scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(1, data)
	end

    ZO_ScrollList_Commit(itemList)
end


function classes.FarmManagerMainWindow:Reset()
	local scrollData = ZO_ScrollList_GetDataList(itemList)
	ZO_ScrollList_Clear(itemList)
	ZO_ScrollList_Commit(itemList)
	window:GetNamedChild("TotalLabel"):SetText("")
	window:GetNamedChild("GoldPerSecondLabel"):SetText("")
end