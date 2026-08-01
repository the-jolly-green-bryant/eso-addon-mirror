local dlwr = FFFDragonLairWeyrRun --addon name
local classes = dlwr.classes

classes.LeaderBoardWindow = ZO_Object:Subclass()

local window = FFFDragonLairWeyrRunLeaderBoardWindow  -- this is the name of the top level control in the xml file
local itemList = {}
local showFarmed = true

classes.LeaderBoardWindow.SORT_KEYS = {
		["namelabel"] = {},
		["totallabel"] = {tiebreaker="name"}
}

local function ToGold(amount)
	return ZO_CurrencyControl_FormatCurrencyAndAppendIcon(amount, false, CURT_MONEY, false)
end

function classes.LeaderBoardWindow:New()
    local object = ZO_Object.New(self)
    object:Init()
    return object
end

function classes.LeaderBoardWindow:Init()
	--itemList is a control on the xml form
	
    itemList = window:GetNamedChild("DetailPanel"):GetNamedChild("ItemList")
    ZO_ScrollList_AddDataType(itemList, 1, "FFFDragonLairWeyrRunGUILeaderListItemTemplate", 30, function(control, data) self:UpdateDataRow(control, data) end)
	
	
end

function classes.LeaderBoardWindow:Show()
    window:SetHidden(false)
end

function classes.LeaderBoardWindow:Hide()
    window:SetHidden(true)
end

function classes.LeaderBoardWindow:ShowLeaderTotals(ShowFarmed)
	-- This button will toggle between the farmed total and the deposited total for the leaderboard
	-- Showing Farmed is the default start, when True Farmed is shown.
	-- actual update will occur based on timed function.
	local btnLabel = window:GetNamedChild("ButtonShowLeaderTotals"):GetNamedChild("ButtonShowLeaderTotalLabel")
	
	if ShowFarmed then
		btnLabel:SetText("Farmed")
		-- set window local value
		showFarmed = true
		
	else
		btnLabel:SetText("Deposits")
		-- set window local value
		showFarmed = false
		
		
	end
	
	
	
end



function classes.LeaderBoardWindow:UpdateDataRow(control, data)
	control:GetNamedChild("NameLabel"):SetText(zo_strformat('<<t:1>>', data.playerName))
	if showFarmed == true then
		control:GetNamedChild("TotalLabel"):SetText(ToGold(math.floor(data.AllValuedLoot.totalValue)))
	else
		control:GetNamedChild("TotalLabel"):SetText(ToGold(math.floor(data.GuildBankDeposits.totalValue)))
	end
	
end

function classes.LeaderBoardWindow:OnLeaderUpdate(leaderList)
	-- clear for update
	ZO_ScrollList_Clear(itemList)
	ZO_ScrollList_Commit(itemList)
	
	local scrollData = ZO_ScrollList_GetDataList(itemList)
	
	for _,data in pairs(leaderList) do
		scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(1, data)
	end
	--d("this is scrolldata",scrollData[1].data.AllValuedLoot)
	local sortFunction = function(listEntry1,listEntry2) return listEntry1.data.AllValuedLoot.totalValue > listEntry2.data.AllValuedLoot.totalValue end
	if not showFarmed then 
		-- sorting based on bank deposits
		sortFunction = function(listEntry1,listEntry2) return listEntry1.data.GuildBankDeposits.totalValue > listEntry2.data.GuildBankDeposits.totalValue end
	end
	
	table.sort(scrollData, sortFunction)

	ZO_ScrollList_Commit(itemList)
    
end



function classes.LeaderBoardWindow:Reset()
	local scrollData = ZO_ScrollList_GetDataList(itemList)
	ZO_ScrollList_Clear(itemList)
	ZO_ScrollList_Commit(itemList)	
end