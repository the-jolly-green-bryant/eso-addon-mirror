
UL_LootLog = {}

local ULLL = UL_LootLog
 
UL_LootLog.name = "UL_LootLog"
UL_LootLog.UL_LootLog_SCENE_NAME = "UL_LootLog_Scene"
ULLL.LMM2 = LibMainMenu2
UL_LootLog.WorkStateEnumerator = {
    UNKNOWN=0,
    RUNNING=1,
    STOPPED=2,
}
UL_LootLog.WorkState = UL_LootLog.WorkStateEnumerator["RUNNING"]

ULLL.LootedItemsTable = {}
ULLL.LootedItemsUniquePlayers = {}
ULLL.SummarisedLootedItems = ""
 
function UL_LootLog:Initialize()	
	
	UL_LootLog:InitWindow()
	
	ULLL.LootedItemsList = LootedItemsList:New()
	
	local function showULLL()
        ULLL.Show("")
    end
    -- Register slash commands
    SLASH_COMMANDS["/ulll"]       = showULLL
	
end
 
function UL_LootLog.OnAddOnLoaded(event, addonName)
  if addonName == UL_LootLog.name then
	EVENT_MANAGER:RegisterForEvent(UL_LootLog.name, EVENT_LOOT_RECEIVED, UL_LootLog.OnLootReceived)
    UL_LootLog:Initialize()
  end
end

function UL_LootLog.InitWindow()

  if ULLL.LMM2 == nil then return end
    ULLL.LMM2:Init()
	
  local descriptor = UL_LootLog.name 
  
  ZO_CreateStringId("UL_LootLog_TITLE", "UL LootLog")
  ZO_CreateStringId("SI_BINDING_NAME_UL_LootLog_SHOW_OR_HIDE", "Show or Hide UL LootLog")
  ZO_CreateStringId("SI_BINDING_NAME_UL_LootLog_START", "Start UL LootLog")
  ZO_CreateStringId("SI_BINDING_NAME_UL_LootLog_STOP", "Stop UL LootLog")
  ZO_CreateStringId("SI_BINDING_NAME_UL_LootLog_CLEAN_START", "Clean Start UL LootLog")
  ZO_CreateStringId("SI_BINDING_NAME_UL_LootLog_CLEAN_STOP", "Clean Stop UL LootLog")
  
  ULLL.scene = ZO_Scene:New(UL_LootLog.UL_LootLog_SCENE_NAME, SCENE_MANAGER)
  ULLL.scene:AddFragment(ZO_SetTitleFragment:New(UL_LootLog_TITLE))
  ULLL.scene:AddFragment(ZO_FadeSceneFragment:New(UL_LootLog_UI))
  ULLL.scene:AddFragment(TITLE_FRAGMENT)
  ULLL.scene:AddFragment(RIGHT_BG_FRAGMENT)
  ULLL.scene:AddFragment(FRAME_EMOTE_FRAGMENT_JOURNAL)
  ULLL.scene:AddFragment(CODEX_WINDOW_SOUNDS)
  ULLL.scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
  ULLL.scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
  
  local sceneName = UL_LootLog.UL_LootLog_SCENE_NAME 

  local categoryLayoutInfo =
  {
	binding = "UL_LootLog_SHOW",
	categoryName = SI_BINDING_NAME_UL_LootLog_SHOW,
	callback = function() UL_LootLog.Show(sceneName) end,
	visible = function(buttonData) return true end,
	
	normal = "esoui/art/inventory/inventory_tabicon_consumables_up.dds",
	pressed = "esoui/art/inventory/inventory_tabicon_consumables_down.dds",
	highlight = "esoui/art/inventory/inventory_tabicon_consumables_over.dds",
	disabled = "esoui/art/inventory/inventory_tabicon_consumables_disabled.dds",
  }
  --
  ULLL.LMM2:AddMenuItem(descriptor, sceneName, categoryLayoutInfo, nil)
	
end

function UL_LootLog.IsShowing(sceneName)
	if sceneName == "" or sceneName == nil then
		sceneName = ULLL.UL_LootLog_SCENE_NAME
	end
	return SCENE_MANAGER:IsShowing(sceneName)
end

function UL_LootLog.Show(sceneName)
	
	if sceneName == "" or sceneName == nil then
		sceneName = ULLL.UL_LootLog_SCENE_NAME
	end
	--d(sceneName)
	--d(not UL_LootLog.IsShowing(sceneName))
	if not UL_LootLog.IsShowing(sceneName) then
		--d("try to show")
  		SCENE_MANAGER:Show(sceneName)
  	--else
  	--	SCENE_MANAGER:ShowBaseScene()
  	end
end

function UL_LootLog.Hide(sceneName)
	
	if sceneName == "" or sceneName == nil then
		sceneName = ULLL.UL_LootLog_SCENE_NAME
	end
	--d(sceneName)
	if UL_LootLog.IsShowing then
  		SCENE_MANAGER:Hide(sceneName)
  	--else
  	--	SCENE_MANAGER:ShowBaseScene()
  	end
end

function UL_LootLog.OnLootReceived( eventCode, receivedBy, itemName, quantity, itemSound, lootType, self, isPickpocketLoot, questItemIcon, itemId )
	
	if UL_LootLog.WorkState == UL_LootLog.WorkStateEnumerator["RUNNING"] then
	
		table.insert(ULLL.LootedItemsTable, 
			{ 
				eventCode 		 	= eventCode 
				,receivedBy 	 	= receivedBy 
				,itemName		 	= itemName
				,quantity 		 	= quantity 
				,itemSound 		 	= itemSound 
				,lootType 		 	= lootType 
				,self 			 	= self
				,isPickpocketLoot 	= isPickpocketLoot
				,questItemIcon 	 	= questItemIcon
				,itemId 			= itemId
				,lootDateTime	 	= UL_LootLog:GetCurrentDateTimeString() .. " " .. GetTimeString()
			})
		
		UL_LootLog.InsertPlayer(receivedBy)				
	
		ULLL.LootedItemsList:Refresh()
	end

end

function UL_LootLog.SummariseLootForPlayers()
	ULLL.SummarisedLootedItems = ""
	
	for k, v in ipairs(ULLL.LootedItemsUniquePlayers) do
		
        local player = v[1]
		
		
		local itemQuality_TRASH_Count = 0 -- 0 -- Коля убрать это, gray
		local itemQuality_NORMAL_Count = 0 -- 1
		local itemQuality_MAGIC_Count = 0 -- 2
		local itemQuality_ARCANE_Count = 0 -- 3
		local itemQuality_ARTIFACT_Count = 0 -- 4
		local itemQuality_LEGENDARY_Count = 0 --5
		
		for j = 1, #ULLL.LootedItemsTable do
			if ULLL.LootedItemsTable[j].receivedBy == player then			
				local currentLootedItemQuality = GetItemLinkQuality(ULLL.LootedItemsTable[j].itemName)
				if currentLootedItemQuality == 0 then itemQuality_TRASH_Count = itemQuality_TRASH_Count + (1*ULLL.LootedItemsTable[j].quantity)
				elseif currentLootedItemQuality == 1 then itemQuality_NORMAL_Count = itemQuality_NORMAL_Count + (1*ULLL.LootedItemsTable[j].quantity)
				elseif currentLootedItemQuality == 2 then itemQuality_MAGIC_Count = itemQuality_MAGIC_Count + (1*ULLL.LootedItemsTable[j].quantity)
				elseif currentLootedItemQuality == 3 then itemQuality_ARCANE_Count = itemQuality_ARCANE_Count + (1*ULLL.LootedItemsTable[j].quantity)
				elseif currentLootedItemQuality == 4 then itemQuality_ARTIFACT_Count = itemQuality_ARTIFACT_Count + (1*ULLL.LootedItemsTable[j].quantity)
				elseif currentLootedItemQuality == 5 then itemQuality_LEGENDARY_Count = itemQuality_LEGENDARY_Count + (1*ULLL.LootedItemsTable[j].quantity)
				end
			end
		end		
		
		-- Коля равнение делать здесь
		
		ULLL.SummarisedLootedItems = ULLL.SummarisedLootedItems .. player
		ULLL.SummarisedLootedItems = ULLL.SummarisedLootedItems .. " :"
		--ULLL.SummarisedLootedItems = ULLL.SummarisedLootedItems .. " TRASH - "
		ULLL.SummarisedLootedItems = ULLL.SummarisedLootedItems .. " |c808080Gray|r - "
		ULLL.SummarisedLootedItems = ULLL.SummarisedLootedItems .. itemQuality_TRASH_Count
		--ULLL.SummarisedLootedItems = ULLL.SummarisedLootedItems .. " NORMAL - "
		ULLL.SummarisedLootedItems = ULLL.SummarisedLootedItems .. " |cFFFFFFWhite|r - "
		ULLL.SummarisedLootedItems = ULLL.SummarisedLootedItems .. itemQuality_NORMAL_Count
		--ULLL.SummarisedLootedItems = ULLL.SummarisedLootedItems .. " MAGIC - "
		ULLL.SummarisedLootedItems = ULLL.SummarisedLootedItems .. " |c008000Green|r - "
		ULLL.SummarisedLootedItems = ULLL.SummarisedLootedItems .. itemQuality_MAGIC_Count
		--ULLL.SummarisedLootedItems = ULLL.SummarisedLootedItems .. " ARCANE - "
		ULLL.SummarisedLootedItems = ULLL.SummarisedLootedItems .. " |c0000FFBlue|r - "
		ULLL.SummarisedLootedItems = ULLL.SummarisedLootedItems .. itemQuality_ARCANE_Count
		--ULLL.SummarisedLootedItems = ULLL.SummarisedLootedItems .. " ARTIFACT - "
		ULLL.SummarisedLootedItems = ULLL.SummarisedLootedItems .. " |c800080Purple|r - "
		ULLL.SummarisedLootedItems = ULLL.SummarisedLootedItems .. itemQuality_ARTIFACT_Count
		--ULLL.SummarisedLootedItems = ULLL.SummarisedLootedItems .. " LEGENDARY - "
		ULLL.SummarisedLootedItems = ULLL.SummarisedLootedItems .. " |cFFA500Orange|r - " -- Коля заменить orange на gold
		ULLL.SummarisedLootedItems = ULLL.SummarisedLootedItems .. itemQuality_LEGENDARY_Count
		ULLL.SummarisedLootedItems = ULLL.SummarisedLootedItems .. "\n"
    end
	
	UL_LootLog_UIResult:SetText(ULLL.SummarisedLootedItems)
	
end

function UL_LootLog.InsertPlayer(player)
	local isPlayerInLootedItemsUniquePlayers = false
	for i = 1, #ULLL.LootedItemsUniquePlayers do
		if ULLL.LootedItemsUniquePlayers[i][1] == player then
			isPlayerInLootedItemsUniquePlayers = true
		end
	end
	if isPlayerInLootedItemsUniquePlayers == false then
		--d(player)
		table.insert(ULLL.LootedItemsUniquePlayers, 
		{ 
			player
		})
	end
end

function UL_LootLog.ClearLootedItems()
	--d("ClearLootedItems")
	ULLL.LootedItemsTable = {}
	ULLL.LootedItemsUniquePlayers = {}
	ULLL.SummarisedLootedItems = ""
	UL_LootLog_UIResult:SetText(ULLL.SummarisedLootedItems)
	ULLL.LootedItemsList:Refresh()
end

function UL_LootLog.Start(isClean)
	if isClean == true then
		UL_LootLog.ClearLootedItems()
	end
	UL_LootLog.WorkState = UL_LootLog.WorkStateEnumerator["RUNNING"]
	--d(UL_LootLog.WorkState)
end

function UL_LootLog.Stop(isClean)
	if isClean == true then
		UL_LootLog.ClearLootedItems()
	end
	UL_LootLog.WorkState = UL_LootLog.WorkStateEnumerator["STOPPED"]
	--d(UL_LootLog.WorkState)
end

-- LootedItemsList

LootedItemsList = ZO_SortFilterList:Subclass()
LootedItemsList.defaults = {}
ULLL.DEFAULT_TEXT = ZO_ColorDef:New(0.4627, 0.737, 0.7647, 1) -- scroll list row text color
ULLL.LootedItemsList = nil

LootedItemsList.SORT_KEYS = {
		["lootDateTime"] = {},
		["itemName"] = {tiebreaker="lootDateTime"},
		["receivedBy"] = {tiebreaker="lootDateTime"}
}

function LootedItemsList:New()
	local lootedItems = ZO_SortFilterList.New(self, UL_LootLog_UI)
	return lootedItems
end

function LootedItemsList:Initialize(control)
	ZO_SortFilterList.Initialize(self, control)

	self.sortHeaderGroup:SelectHeaderByKey("lootDateTime")
	ZO_SortHeader_OnMouseExit(UL_LootLog_UIHeadersLootDateTime)

	self.masterList = {}
	ZO_ScrollList_AddDataType(self.list, 1, "BaseLootRowTemplate", 30, 
	function(control, data) 
		self:SetupUnitRow(control, data) 
	end)
	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, LootedItemsList.SORT_KEYS, self.currentSortOrder) end
	self:RefreshData()
end

function LootedItemsList:BuildMasterList()
	self.masterList = {}
    local lootedItems = ULLL.LootedItemsTable
    if lootedItems then
        for k, v in ipairs(lootedItems) do
            local data = v
            table.insert(self.masterList ,data )
        end
    end
end

function LootedItemsList:FilterScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)
	
	for i = 1, #self.masterList do
		local data = self.masterList[i]
		table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
	end
end

function LootedItemsList:SortScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	table.sort(scrollData, self.sortFunction)
end

function LootedItemsList:SetupUnitRow(control, data)
	
	--CHAT_SYSTEM:AddMessage("Setup unit row")
	
	control.data = data

	control.lootDateTime = GetControl(control, "LootDateTime")
	control.itemName = GetControl(control, "ItemName")
	control.quantity = GetControl(control, "Quantity")
	control.receivedBy = GetControl(control, "ReceivedBy")

	control.lootDateTime:SetText(data.lootDateTime)
	control.itemName:SetText(data.itemName)
	control.quantity:SetText(data.quantity)
	control.receivedBy:SetText(data.receivedBy)

	--control.lootDateTime.normalColor = ULLL.DEFAULT_TEXT
	--control.itemName.normalColor = ULLL.DEFAULT_TEXT
	--control.receivedBy.normalColor = ULLL.DEFAULT_TEXT

	ZO_SortFilterList.SetupRow(self, control, data)
end

function LootedItemsList:Refresh()
	self:RefreshData()
	UL_LootLog.SummariseLootForPlayers()
end
--

-- Help functions
function UL_LootLog.GetCurrentDateTimeString()
	local currentDateTimeString = GetDateStringFromTimestamp(GetTimeStamp()) .. ""	
	
	local t={}
    for str in string.gmatch(currentDateTimeString, "([^".. "/" .."]+)") do
            table.insert(t, str)
    end

	return t[2] .. "-" .. t[1] .. "-" .. t[3]
end

--
 
 EVENT_MANAGER:RegisterForEvent(UL_LootLog.name, EVENT_ADD_ON_LOADED, UL_LootLog.OnAddOnLoaded)