local dlwr = FFFDragonLairWeyrRun --addon name
local classes = dlwr.classes

classes.GuildBankDepositWindow = ZO_Object:Subclass()

local window = FFFDragonLairWeyrRunGuildBankDepositWindow  -- this is the name of the top level control in the xml file
local itemList = {}


classes.GuildBankDepositWindow.SORT_KEYS = {
		["namelabel"] = {},
		["countslabel"] = {tiebreaker="name"},
		["valuelabel"] = {tiebreaker="name"}
}


local function ToGold(amount)
	return ZO_CurrencyControl_FormatCurrencyAndAppendIcon(amount, false, CURT_MONEY, false)
 end

function classes.GuildBankDepositWindow:New()
    local object = ZO_Object.New(self)
    object:Init()
    return object
end

function classes.GuildBankDepositWindow:Init()
	--itemList is a control on the xml form
    itemList = window:GetNamedChild("DetailPanel"):GetNamedChild("ItemList")
    ZO_ScrollList_AddDataType(itemList, 1, "FFFDragonLairWeyrRunGuildBankDepositItemListTemplate", 50, function(control, data) self:UpdateDataRow(control, data) end)
	ZO_ScrollList_SetTypeSelectable(itemList, 1, true)
	
end

function classes.GuildBankDepositWindow:Show(guildName)
	local windowTitle = window:GetNamedChild("TitleLabel")
	windowTitle:SetText(string.upper(guildName) .." - BANK DEPOSIT")
    window:SetHidden(false)
end

function classes.GuildBankDepositWindow:Hide()
    window:SetHidden(true)
end

function classes.GuildBankDepositWindow:SelectItem(control)
	local scrollData = ZO_ScrollList_GetDataList(control)
	d(scrollData)
	ZO_ScrollList_SelectData(control)
end

function classes.GuildBankDepositWindow:GetSelectedItem(row)
	local scrollData = ZO_ScrollList_GetSelectedData(row)
	return scrollData
end


function classes.GuildBankDepositWindow:ShowDepositItems(playeritemList)
	
	ZO_ScrollList_Clear(itemList)
	ZO_ScrollList_Commit(itemList)
	local scrollData = ZO_ScrollList_GetDataList(itemList)
	
	for _,data in pairs(playeritemList.items) do
		--d(data.itemLink)
		scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(1, DetailEntry:New(data))
	end
	self.sortFunction = function(listEntry1,listEntry2) return listEntry1.data.totalValueFarmed > listEntry2.data.totalValueFarmed end
	table.sort(scrollData, self.sortFunction)
	ZO_ScrollList_Commit(itemList)
	
end

function classes.GuildBankDepositWindow:UpdateDataRow(control, data)
	control:GetNamedChild("Icon"):SetTexture(data.texture)
	control:GetNamedChild("NameLabel"):SetText(zo_strformat('<<t:1>>', data.itemLink))
	control:GetNamedChild("CountsLabel"):SetText(data.quantityFarmed)
	control:GetNamedChild("ValueLabel"):SetText(ToGold(data.totalValueFarmed))
	control:GetNamedChild("ItemId"):SetText(data.itemId)
	
end


function classes.GuildBankDepositWindow:Reset()
	local scrollData = ZO_ScrollList_GetDataList(itemList)
	ZO_ScrollList_Clear(itemList)
	ZO_ScrollList_Commit(itemList)
	
end