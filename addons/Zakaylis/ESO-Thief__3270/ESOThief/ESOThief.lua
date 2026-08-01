-- 1 hr 42 mint
--- |H0:item:73778:6:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h --> Kari hitlist item
--  |H1:item:73785:6:1:0:0:0:0:0:0:0:0:0:0:0:17:0:0:1:1:0:0|h|h --> also hitlist

ESOThief = ESOThief or {}

local ULLL = ESOThief
 
ESOThief.name = "ESOThief"
ESOThief.ESOThief_SCENE_NAME = "ESOThief_Scene"
ULLL.LMM2 = LibMainMenu2
ESOThief.WorkStateEnumerator = {
    UNKNOWN=0,
    RUNNING=1,
    STOPPED=2,
}
-- ESOThief.WorkState = ESOThief.WorkStateEnumerator["STOPPED"]
ESOThief.WorkState = ESOThief.WorkStateEnumerator["STOPPED"]

ESOThief.WindowManager = GetWindowManager()
ESOThief.ShortInfoWindow = nil
ESOThief.IsShortInfoWindowShowing = {}
ESOThief.DefaultIsShortInfoWindowShowing = { IsShowing = true}

ESOThief.ShortInfoWindowOffsets = {}
ESOThief.DefaultShortInfoWindowOffsets = { 
	offsetX = 0,
	offsetY = 0
}
ESOThief.BackGround = nil
ESOThief.line1 = nil
ESOThief.line2 = nil
ESOThief.line3 = nil
ESOThief.label1 = nil
ESOThief.label2 = nil
ESOThief.label3 = nil
ESOThief.icon1 = nil
ESOThief.icon2 = nil
ESOThief.icon3 = nil

ESOThief.IsClearStartStop = nil

ULLL.LootedItemsTable = {}
ULLL.LootedItemsUniquePlayers = {}
ULLL.SummarisedLootedItems = ""
ULLL.SummarisedLootedItemsForCurrentPlayer = ""

ULLL.TimerSet = -1
ULLL.TimerValue = nil
ULLL.TimerSetEditBox = nil
local function showULLL()
	ULLL.Show("")
end
SLASH_COMMANDS["/esothief"]       = showULLL
 
function ESOThief:Initialize()	
	
	ESOThief:InitWindow()
	ESOThief.InitShortInfoWindow()
	
	ULLL.LootedItemsList = LootedItemsList:New()
	
	
    -- Register slash commands
    
	
end
 
function ESOThief.OnAddOnLoaded(event, addonName)
  if addonName == ESOThief.name then
	EVENT_MANAGER:RegisterForEvent(ESOThief.name, EVENT_LOOT_RECEIVED, ESOThief.OnLootReceived)
    ESOThief:Initialize()
  end
end

function ESOThief.InitWindow()

  if ULLL.LMM2 == nil then return end
    ULLL.LMM2:Init()
	
  local descriptor = ESOThief.name 
  
  ZO_CreateStringId("ESOThief_TITLE", "BLACK SKY") -- CHANGE THIS LINE TO CHANGE THE HEADER
  ZO_CreateStringId("SI_BINDING_NAME_ESOThief_SHOW_OR_HIDE", "Show or Hide ESO Thief")
  ZO_CreateStringId("SI_BINDING_NAME_ESOThief_SHORT_INFO_SHOW_OR_HIDE", "Show or Hide ESO Thief Short Info")
  ZO_CreateStringId("SI_BINDING_NAME_ESOThief_START", "Start ESO Thief")
  ZO_CreateStringId("SI_BINDING_NAME_ESOThief_STOP", "Stop ESO Thief")
  ZO_CreateStringId("SI_BINDING_NAME_ESOThief_CLEAN_START", "Clean Start ESO Thief")
  ZO_CreateStringId("SI_BINDING_NAME_ESOThief_CLEAN_STOP", "Clean Stop ESO Thief")
  
  ULLL.scene = ZO_Scene:New(ESOThief.ESOThief_SCENE_NAME, SCENE_MANAGER)
  ULLL.scene:AddFragment(ZO_SetTitleFragment:New(ESOThief_TITLE))
  ULLL.scene:AddFragment(ZO_FadeSceneFragment:New(ESOThief_UI))
  ULLL.scene:AddFragment(TITLE_FRAGMENT)
  ULLL.scene:AddFragment(RIGHT_BG_FRAGMENT)
  ULLL.scene:AddFragment(FRAME_EMOTE_FRAGMENT_JOURNAL)
  ULLL.scene:AddFragment(CODEX_WINDOW_SOUNDS)
  ULLL.scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
  ULLL.scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
  
  local sceneName = ESOThief.ESOThief_SCENE_NAME 

  local categoryLayoutInfo =
  {
	binding = "ESOThief_SHOW",
	categoryName = SI_BINDING_NAME_ESOThief_SHOW,
	callback = function() ESOThief.Show(sceneName) end,
	visible = function(buttonData) return true end,
	
	normal = "esoui/art/inventory/inventory_tabicon_consumables_up.dds",
	pressed = "esoui/art/inventory/inventory_tabicon_consumables_down.dds",
	highlight = "esoui/art/inventory/inventory_tabicon_consumables_over.dds",
	disabled = "esoui/art/inventory/inventory_tabicon_consumables_disabled.dds",
  }
  --
  ULLL.LMM2:AddMenuItem(descriptor, sceneName, categoryLayoutInfo, nil)

  ULLL.createToggle(ESOThief_UILootLogTotalControlsIncludeStolenCheckbox,"esoui/art/cadwell/checkboxicon_checked.dds",	"esoui/art/cadwell/checkboxicon_unchecked.dds", 
		"esoui/art/cadwell/checkboxicon_unchecked.dds", "esoui/art/cadwell/checkboxicon_checked.dds", true )
  ESOThief_UILootLogTotalControlsIncludeStolenCheckboxLabel:SetText("Only stolen items")

  ULLL.createToggle(ESOThief_UILootLogTotalControlsIncludeCraftMatsCheckbox,"esoui/art/cadwell/checkboxicon_checked.dds",	"esoui/art/cadwell/checkboxicon_unchecked.dds", 
		"esoui/art/cadwell/checkboxicon_unchecked.dds", "esoui/art/cadwell/checkboxicon_checked.dds", true )
  ESOThief_UILootLogTotalControlsIncludeCraftMatsCheckboxLabel:SetText("Only crafting mats")

  ULLL.createToggle(ESOThief_UILootLogTotalControlsIncludePickpocketCheckbox,"esoui/art/cadwell/checkboxicon_checked.dds",	"esoui/art/cadwell/checkboxicon_unchecked.dds", 
		"esoui/art/cadwell/checkboxicon_unchecked.dds", "esoui/art/cadwell/checkboxicon_checked.dds", true )
  ESOThief_UILootLogTotalControlsIncludePickpocketCheckboxLabel:SetText("Only Pickpocketed items")
  function ESOThief.includeStolen()
  	return ESOThief_UILootLogTotalControlsIncludeStolenCheckbox.toggleValue
  end
  function ESOThief.includeMats()
  	return ESOThief_UILootLogTotalControlsIncludeCraftMatsCheckbox.toggleValue
  end
  function ESOThief.includePickpocket()
  	return ESOThief_UILootLogTotalControlsIncludePickpocketCheckbox.toggleValue
  end
  ESOThief_UILootLogTotalControlsIncludePickpocketCheckbox:toggleOff()
  ESOThief_UILootLogTotalControlsIncludeCraftMatsCheckbox:toggleOff()
  ESOThief_UILootLogTotalControlsIncludeStolenCheckbox:toggleOff()
end

function ESOThief.InitShortInfoWindow()
	
	ESOThief.ShortInfoWindowOffsets = ZO_SavedVars:New("ESOThief_SavedShortInfoWindowOffsets", 1, nil, ESOThief.DefaultShortInfoWindowOffsets)
	
	
		if ESOThief.ShortInfoWindowOffsets == nil then
		  ESOThief.ShortInfoWindowOffsets.offsetX = ESOThief.DefaultShortInfoWindowOffsets.offsetX
		end
		
		if ESOThief.ShortInfoWindowOffsets == nil then
		  ESOThief.ShortInfoWindowOffsets.offsetY = ESOThief.DefaultShortInfoWindowOffsets.offsetY
		end

	ESOThief.IsShortInfoWindowShowing = ZO_SavedVars:New("ESOThief_IsShortInfoWindowShowing", 3, nil, ESOThief.DefaultIsShortInfoWindowShowing)
	
	if ESOThief.IsShortInfoWindowShowing == nil then
		  ESOThief.IsShortInfoWindowShowing.IsShowing = ESOThief.DefaultIsShortInfoWindowShowing.IsShowing
	end

	local labelheight = 25
	local labelwidth = 570

	ESOThief.ShortInfoWindow = ULLL.WindowManager:CreateTopLevelWindow("ESOThief_ShortInfo_Window")
	
	uitemp = ULLL.ShortInfoWindow
    uitemp:SetClampedToScreen(true)
    uitemp:SetMouseEnabled(true) 
    uitemp:SetResizeToFitDescendents(true)
    uitemp:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ESOThief.ShortInfoWindowOffsets.offsetX, ESOThief.ShortInfoWindowOffsets.offsetY)
    uitemp:SetHidden(ESOThief.IsShortInfoWindowShowing.IsShowing)
    uitemp:SetMovable(true)
    uitemp:SetHandler("OnMoveStop", OnMoveStop)
	
	--BackGround init
	
	ULLL.BackGround = ULLL.WindowManager:CreateControl("ESOThief_ShortInfo_BackGround", ULLL.ShortInfoWindow, CT_BACKDROP)
    uitemp = ULLL.BackGround
    uitemp:SetHidden(false)
    uitemp:SetClampedToScreen(false)
    uitemp:SetAnchor(TOPLEFT, ULLL.ShortInfoWindow, TOPLEFT, 0, 0)
    uitemp:SetResizeToFitDescendents(true)
    uitemp:SetResizeToFitPadding(32,16)
    uitemp:SetDimensionConstraints(labelwidth,labelheight*3)
    uitemp:SetInsets (16,16,-16,-16)
    uitemp:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_BG_edge.dds", 256, 256, 16)
    uitemp:SetCenterTexture("EsoUI/Art/ChatWindow/chat_BG_center.dds")
    uitemp:SetAlpha(0.65)
    uitemp:SetDrawLayer(0)
	
	ULLL.GroupBox = ULLL.WindowManager:CreateControl("ESOThief_ShortInfo_GroupBox", ULLL.BackGround, CT_CONTROL)
    uitemp = ULLL.GroupBox
    uitemp:SetAnchor(TOPLEFT, ULLL.BackGround, TOPLEFT, 16, 16)
	
	--	
	
	uitemp = ULLL.GroupBox
    uitemp:SetAnchor(TOPLEFT, ULLL.BackGround, TOPLEFT, 16, 16)
	
	--Line 1 WorkState
	
	ULLL.line1 = ULLL.WindowManager:CreateControl("ESOThief_ShortInfo_Line1", ULLL.GroupBox, CT_CONTROL)
    uitemp = ULLL.line1
    uitemp:SetAnchor(TOPLEFT, ULLL.GroupBox, TOPLEFT, 0, 0)
	
    ULLL.icon1 = ULLL.WindowManager:CreateControl("ESOThief_ShortInfo_Icon1", ULLL.line1, CT_TEXTURE)
    uitemp = ULLL.icon1
    uitemp:SetDimensions(labelheight*0.75,labelheight*0.75)
    uitemp:SetAnchor(LEFT, ULLL.line1, LEFT, labelheight*.2, labelheight*.1)
    uitemp:SetTexture("/esoui/art/hud/starburst.dds")
	
    ULLL.label1 = ULLL.WindowManager:CreateControl("ESOThief_ShortInfo_Label1", ULLL.line1, CT_LABEL)
    uitemp = ULLL.label1
    uitemp:SetColor(0.8, 0.8, 0.8, 1)
    uitemp:SetFont("ZoFontGameMedium")
    uitemp:SetWrapMode(TEX_MODE_CLAMP)
	
    uitemp:SetText(ESOThief.GetCurrentWorkStateText())
    uitemp:SetAnchor(LEFT, ULLL.icon1, RIGHT, 8, 1)
    uitemp:SetDimensions(labelwidth,labelheight)
	
	--Line 2
	
	ULLL.line2 = ULLL.WindowManager:CreateControl("ESOThief_ShortInfo_Line2", ULLL.GroupBox, CT_CONTROL)
    uitemp = ULLL.line2
    uitemp:SetAnchor(TOPLEFT, ULLL.GroupBox, TOPLEFT, 0, labelheight)
	
    ULLL.icon2 = ULLL.WindowManager:CreateControl("ESOThief_ShortInfo_Icon2", ULLL.line2, CT_TEXTURE)
    uitemp = ULLL.icon2
    uitemp:SetDimensions(labelheight*0.75,labelheight*0.75)
    uitemp:SetAnchor(LEFT, ULLL.line2, LEFT, labelheight*.2, labelheight*.1)
    uitemp:SetTexture("/esoui/art/hud/starburst.dds")
	
    ULLL.label2 = ULLL.WindowManager:CreateControl("ESOThief_ShortInfo_Label2", ULLL.line2, CT_LABEL)
    uitemp = ULLL.label2
    uitemp:SetColor(0.8, 0.8, 0.8, 1)
    uitemp:SetFont("ZoFontGameMedium")
    uitemp:SetWrapMode(TEX_MODE_CLAMP)
    uitemp:SetText("TIMER NOT SET")
    uitemp:SetAnchor(LEFT, ULLL.icon2, RIGHT, 8, 1)
    uitemp:SetDimensions(labelwidth,labelheight)
	
	--Line 3
	
	ULLL.line3 = ULLL.WindowManager:CreateControl("ESOThief_ShortInfo_Line3", ULLL.GroupBox, CT_CONTROL)
    uitemp = ULLL.line3
    uitemp:SetAnchor(TOPLEFT, ULLL.GroupBox, TOPLEFT, 0, labelheight*2)
	
    ULLL.icon3 = ULLL.WindowManager:CreateControl("ESOThief_ShortInfo_Icon3", ULLL.line3, CT_TEXTURE)
    uitemp = ULLL.icon3
    uitemp:SetDimensions(labelheight*0.75,labelheight*0.75)
    uitemp:SetAnchor(LEFT, ULLL.line3, LEFT, labelheight*.2, labelheight*.1)
    uitemp:SetTexture("/esoui/art/hud/starburst.dds")
	
    ULLL.label3 = ULLL.WindowManager:CreateControl("ESOThief_ShortInfo_Label3", ULLL.line3, CT_LABEL)
    uitemp = ULLL.label3
    uitemp:SetColor(0.8, 0.8, 0.8, 1)
    uitemp:SetFont("ZoFontGameMedium")
    uitemp:SetWrapMode(TEX_MODE_CLAMP)
    uitemp:SetText("LOOT LOG IS EMPTУ")
    uitemp:SetAnchor(LEFT, ULLL.icon3, RIGHT, 8, 1)
    uitemp:SetDimensions(labelwidth,labelheight)
	
end

function OnMoveStop(self)
  ESOThief.ShortInfoWindowOffsets.offsetX = self:GetLeft()
  ESOThief.ShortInfoWindowOffsets.offsetY = self:GetTop()
  --d(GetUnitName("player"))
end

function ESOThief.IsShowing(sceneName)
	if sceneName == "" or sceneName == nil then
		sceneName = ULLL.ESOThief_SCENE_NAME
	end
	return SCENE_MANAGER:IsShowing(sceneName)
end

function ESOThief.Show(sceneName)
	
	if sceneName == "" or sceneName == nil then
		sceneName = ULLL.ESOThief_SCENE_NAME
	end
	--d(sceneName)
	--d(not ESOThief.IsShowing(sceneName))
	if not ESOThief.IsShowing(sceneName) then
  		SCENE_MANAGER:Show(sceneName)
  	--else
  	--	SCENE_MANAGER:ShowBaseScene()
  	end
end

function ESOThief.Hide(sceneName)
	
	if sceneName == "" or sceneName == nil then
		sceneName = ULLL.ESOThief_SCENE_NAME
	end
	--d(sceneName)
	if ESOThief.IsShowing then
  		SCENE_MANAGER:Hide(sceneName)
  	--else
  	--	SCENE_MANAGER:ShowBaseScene()
  	end
end

function ESOThief.currentFilter(receivedBy, itemName, quantity, itemSound, lootType, isUser, isPickpocketLoot, questItemIcon, itemId, isStolen )
	-- return isPickpocketLoot
	if ESOThief.includeStolen() and not isStolen then
		return false
	end
	if ESOThief.includeMats() and not CanItemLinkBeVirtual(itemName) then
		return false
	end
	if ESOThief.includePickpocket() and not isPickpocketLoot then
		return false
	end
	if quantity == 10 then -- crates of loot
		return false
	end
	if IsItemLinkUnique(itemName) then -- Kari's Hitlist items
		return false
	end
	local type, specialType = GetItemLinkItemType(itemName)
	if specialType == 2550 then
		return true
	end
	-- return false
	return true
end

local function getDisplayNameFromCharName(charName)
	local formattedName = zo_strformat("<<1>>", charName)
	for i = 1, 12 do
		local name = GetUnitName("group"..i)
		local display = GetUnitDisplayName("group"..i)
		if name == 	formattedName then
			return display
		end
	end
	if formattedName == GetUnitName('player') then
		return GetDisplayName()
	end
	return formattedName
end

local goldAmounts = 
{
	[0] = 0,
	[1] = 0,
	[2] = 100,
	[3] = 250,
	[4] = 1500,
	[5] = 0,
}
-- Change this to change the score awarded per player
local scoreAmounts = 
{
	[0] = 0,
	[1] = 0,
	[2] = 1,
	[3] = 2,
	[4] = 3,
	[5] = 4,
}


function ESOThief.IncreaseScores(lootTable)
	local usedQuality = lootTable.quality
	if GetItemLinkItemId(lootTable.itemName) == 76914 then
		usedQuality = 2
	end
	for k, playerTable in pairs(ULLL.LootedItemsUniquePlayers) do
		if lootTable.receivedByDisplay == playerTable[2] then -- player display name matches
			-- if lootTable.stolen then
			if lootTable.quantity ~= 10 then
				if GetItemLinkItemId(lootTable.itemName) == 76914 then
					playerTable[3]['shillings'] =  playerTable[3]['shillings'] + 1*lootTable.quantity
					playerTable.gold = playerTable.gold + 0 * lootTable.quantity
					playerTable.score = playerTable.score + 2 * lootTable.quantity
				else
					playerTable[3][lootTable.quality] =  playerTable[3][lootTable.quality] + 1*lootTable.quantity
					playerTable.gold = playerTable.gold + goldAmounts[lootTable.quality] * lootTable.quantity
					playerTable.score = playerTable.score + scoreAmounts[lootTable.quality] * lootTable.quantity
				end
			else
				-- Shipments usually contain 10 white items, each worth 40g for 400g each, similar to 4 green items
				-- playerTable[3][2] =  playerTable[3][2] + 1*4
				-- playerTable.gold = playerTable.gold + goldAmounts[2] * 4
				-- playerTable.score = playerTable.score + scoreAmounts[2] * 4
			end
		end
	end
end

function ESOThief.OnLootReceived( eventCode, receivedBy, itemName, quantity, itemSound, lootType, isUser, isPickpocketLoot, questItemIcon, itemId , isStolen)
	
	if ESOThief.WorkState == ESOThief.WorkStateEnumerator["RUNNING"] then
	
		local itemType = GetItemLinkItemType(itemName)
		
		-- All exceptions are written here, in order to uncomment the exception, you need to remove two dashes in front of the line and vice versa, ~ = means not equal, itemType is the type of the item (numeric)
		
		if ESOThief.currentFilter(receivedBy, itemName, quantity, itemSound, lootType, isUser, isPickpocketLoot, questItemIcon, itemId, isStolen ) then
			if quantity == 10 then

			end
			local lootTable = { 
					eventCode 		 	= eventCode 
					,receivedBy 	 	= receivedBy
					,itemName		 	= itemName
					,quantity 		 	= quantity 
					,itemSound 		 	= itemSound 
					,lootType 		 	= lootType 
					,self 			 	= isUser
					,isPickpocketLoot 	= isPickpocketLoot
					,questItemIcon 	 	= questItemIcon
					,itemId 			= itemId
					,lootDateTime	 	= ESOThief:GetCurrentDateTimeString() .. " " .. GetTimeString()
					,receivedByDisplay	= getDisplayNameFromCharName(receivedBy) 
					,quality 			= GetItemLinkQuality(itemName)
					,stolen 			= isStolen
				}
			table.insert(ULLL.LootedItemsTable, lootTable)
			
			ESOThief.InsertPlayer(receivedBy)
			ESOThief.IncreaseScores(lootTable)
		
			ULLL.LootedItemsList:Refresh()
			
		end
	end

end

function ESOThief.SummariseLootForPlayers()
	ULLL.SummarisedLootedItems = ""
	local groupGold = 0
	local groupScore = 0
	-- for k, v in ipairs(ULLL.LootedItemsUniquePlayers) do
		
 --        local player = v[1]
	-- 	local playerDisplayName = v[2]
		
	-- 	local itemQuality_TRASH_Count = 0 -- 0 -- Kolya remove it, gray
	-- 	local itemQuality_NORMAL_Count = 0 -- 1
	-- 	local itemQuality_MAGIC_Count = 0 -- 2
	-- 	local itemQuality_ARCANE_Count = 0 -- 3
	-- 	local itemQuality_ARTIFACT_Count = 0 -- 4
	-- 	local itemQuality_LEGENDARY_Count = 0 --5
		
	-- 	local itemQuality_Polished_Shilling_Count = 0 
		
	-- 	-- If necessary, you can add counting by similarity and for other subjects, add a variable for counting, then set the desired if in the cycle, and at the end, when concatenating strings, write what to add where
		
	-- 	for j = 1, #ULLL.LootedItemsTable do
	-- 		if ULLL.LootedItemsTable[j].receivedBy == player then			
	-- 			local currentLootedItemQuality = GetItemLinkQuality(ULLL.LootedItemsTable[j].itemName)
						
	-- 			if currentLootedItemQuality == 0 then itemQuality_TRASH_Count = itemQuality_TRASH_Count + (1*ULLL.LootedItemsTable[j].quantity)
	-- 			elseif ULLL.LootedItemsTable[j].itemId ~= 76914 and currentLootedItemQuality == 1 then itemQuality_NORMAL_Count = itemQuality_NORMAL_Count + (1*ULLL.LootedItemsTable[j].quantity)
	-- 			elseif currentLootedItemQuality == 2 then itemQuality_MAGIC_Count = itemQuality_MAGIC_Count + (1*ULLL.LootedItemsTable[j].quantity)
	-- 			elseif currentLootedItemQuality == 3 then itemQuality_ARCANE_Count = itemQuality_ARCANE_Count + (1*ULLL.LootedItemsTable[j].quantity)
	-- 			elseif currentLootedItemQuality == 4 then itemQuality_ARTIFACT_Count = itemQuality_ARTIFACT_Count + (1*ULLL.LootedItemsTable[j].quantity)
	-- 			elseif currentLootedItemQuality == 5 then itemQuality_LEGENDARY_Count = itemQuality_LEGENDARY_Count + (1*ULLL.LootedItemsTable[j].quantity)
				
	-- 			elseif ULLL.LootedItemsTable[j].itemId == 76914 then itemQuality_Polished_Shilling_Count = itemQuality_Polished_Shilling_Count + (1*ULLL.LootedItemsTable[j].quantity)										
				
	-- 			end			
				
	-- 		end
	-- 	end		
		
	-- 	local SummarisedLootedItemsForPlayer = ""
		
	-- 	--GREYS
	-- 	SummarisedLootedItemsForPlayer = SummarisedLootedItemsForPlayer .. "|cc5c29e" .. itemQuality_TRASH_Count .. "|r - "

	-- 	--WHITES
	-- 	SummarisedLootedItemsForPlayer = SummarisedLootedItemsForPlayer .. "|cffffff" .. itemQuality_NORMAL_Count .. "|r - "

	-- 	--GREENS
	-- 	SummarisedLootedItemsForPlayer = SummarisedLootedItemsForPlayer .. "|c2dc50e" .. itemQuality_MAGIC_Count .. "|r - "

	-- 	--BLUES
	-- 	SummarisedLootedItemsForPlayer = SummarisedLootedItemsForPlayer .. "|c3a92ff" .. itemQuality_ARCANE_Count .. "|r - "

	-- 	--POLISHED SHILLINGS
	-- 	SummarisedLootedItemsForPlayer = SummarisedLootedItemsForPlayer .. "|cFFFFFF" .. itemQuality_Polished_Shilling_Count .. "|r - "

	-- 	--PURPLES
	-- 	SummarisedLootedItemsForPlayer = SummarisedLootedItemsForPlayer .. "|ca02ef7" .. itemQuality_ARTIFACT_Count .. "|r - "

	-- 	--GOLDS
	-- 	SummarisedLootedItemsForPlayer = SummarisedLootedItemsForPlayer .. "|ceeca2a" .. itemQuality_LEGENDARY_Count .. "|r" 
		
		
	-- 	if zo_strformat("<<1>>", player) == GetUnitName("player") then
	-- 		ESOThief.SetSummarisedLootedItemsForCurrentPlayer(SummarisedLootedItemsForPlayer)
	-- 	end
	-- 	local playerScore = 0
	-- 	local playerGold = 0
	-- 	playerGold = ((itemQuality_MAGIC_Count * 100) + (itemQuality_ARCANE_Count * 250) + (itemQuality_Polished_Shilling_Count * 0) + (itemQuality_ARTIFACT_Count * 1500) + (itemQuality_LEGENDARY_Count*0))
	-- 	playerScore = ((itemQuality_MAGIC_Count * 1) + (itemQuality_ARCANE_Count * 2) + (itemQuality_Polished_Shilling_Count * 2) + (itemQuality_ARTIFACT_Count * 3) + (itemQuality_LEGENDARY_Count*4))
	-- 	--SummarisedLootedItemsForPlayer = SummarisedLootedItemsForPlayer
	-- 	--SummarisedLootedItemsForPlayer = zo_strformat("<<1>>", player) .. SummarisedLootedItemsForPlayer
		
	-- 	-- NEED TO GET ACCOUNT NAME
	-- 	--SummarisedLootedItemsForPlayer = SummarisedLootedItemsForPlayer .. " : " .. GetDisplayName("<<1>>", player) .. " / " .. zo_strformat("<<1>>", player) .. " [".. ((itemQuality_MAGIC_Count * 1) + (itemQuality_ARCANE_Count * 2) + (itemQuality_Polished_Shilling_Count * 2) + (itemQuality_ARTIFACT_Count * 3) + (itemQuality_LEGENDARY_Count*4)) .. "]"
	-- 	SummarisedLootedItemsForPlayer = SummarisedLootedItemsForPlayer .. " : " .. zo_strformat("<<1>>", playerDisplayName) .."/" ..zo_strformat("<<1>>", player)
	-- 	SummarisedLootedItemsForPlayer = SummarisedLootedItemsForPlayer .. " [".. playerGold .. "g]"
	-- 	SummarisedLootedItemsForPlayer = SummarisedLootedItemsForPlayer .. " [".. playerScore .. "]"
	-- 	ULLL.SummarisedLootedItems = ULLL.SummarisedLootedItems .. SummarisedLootedItemsForPlayer .. "\n"
	-- 	groupGold = groupGold + playerGold
	-- 	groupScore = groupScore + playerScore
		
 --    end
 local playerSummaries = 
 {

 }
    for k, v in ipairs(ULLL.LootedItemsUniquePlayers) do
    	local player = v[1]
    	local playerDisplayName = v[2]
    	local playerLootSummary = ""
    	-- GREYS
		playerLootSummary = playerLootSummary .. "|cc5c29e" .. v[3][0] .. "|r - "

		--WHITES
		playerLootSummary = playerLootSummary .. "|cffffff" .. v[3][1] .. "|r - "

		--GREENS
		playerLootSummary = playerLootSummary .. "|c2dc50e" .. v[3][2] .. "|r - "

		--BLUES
		playerLootSummary = playerLootSummary .. "|c3a92ff" .. v[3][3] .. "|r - "

		--POLISHED SHILLINGS
		playerLootSummary = playerLootSummary .. "|cFFFFFF" .. v[3]['shillings'] .. "|r - "

		--PURPLES
		playerLootSummary = playerLootSummary .. "|ca02ef7" .. v[3][4] .. "|r - "

		--GOLDS
		playerLootSummary = playerLootSummary .. "|ceeca2a" .. v[3][5] .. "|r"
		if playerDisplayName == GetDisplayName() then
			ESOThief.SetSummarisedLootedItemsForCurrentPlayer(playerLootSummary)
		end
		playerLootSummary = playerLootSummary .. " : " .. zo_strformat("<<1>>", playerDisplayName) .."/" ..zo_strformat("<<1>>", player)
		playerLootSummary = playerLootSummary .. " [".. v.gold .. "g]"
		playerLootSummary = playerLootSummary .. " [".. v.score .. "]"
		table.insert(playerSummaries, {v.score, playerLootSummary})
		-- ULLL.SummarisedLootedItems = ULLL.SummarisedLootedItems .. playerLootSummary .. "\n"
		groupGold = groupGold + v.gold
		groupScore = groupScore + v.score
    end
    -- Sort the player summaries by score in descending order
    table.sort(playerSummaries, function(a, b) return a[1]>b[1] end)
    for i = 1, # playerSummaries do
    	ULLL.SummarisedLootedItems = ULLL.SummarisedLootedItems .. playerSummaries[i][2] .. "\n"
    end
	ESOThief_UILootLogTotalControlsGroupGold:SetText("Group Score: "..groupScore)
	ESOThief_UILootLogTotalControlsGroupScore:SetText("Group Gold: "..groupGold)
	ESOThief_UIResult:SetText(ULLL.SummarisedLootedItems)
	
end

function ESOThief.SetSummarisedLootedItemsForCurrentPlayer(summarisedLootedItemsForPlayer)

	ULLL.SummarisedLootedItemsForCurrentPlayer = summarisedLootedItemsForPlayer
	
	--d(ULLL.SummarisedLootedItemsForCurrentPlayer)
	
	ESOThief.label3:SetText(ULLL.SummarisedLootedItemsForCurrentPlayer)
end


function ESOThief.InsertPlayer(player)
	local isPlayerInLootedItemsUniquePlayers = false
	for i = 1, #ULLL.LootedItemsUniquePlayers do
		if ULLL.LootedItemsUniquePlayers[i][1] == player then
			isPlayerInLootedItemsUniquePlayers = true
		end
	end
	if isPlayerInLootedItemsUniquePlayers == false then
		--d(player)
		local displayName = getDisplayNameFromCharName(player)
		table.insert(ULLL.LootedItemsUniquePlayers, 
		{ 
			player, displayName, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,['shillings'] = 0, [0] = 0},
			gold = 0,
			score = 0,
		})
	end
end

function ESOThief.ClearLootedItems()
	--d("ClearLootedItems")
	ULLL.LootedItemsTable = {}
	ULLL.LootedItemsUniquePlayers = {}
	ULLL.SummarisedLootedItems = ""
	ULLL.SummarisedLootedItemsForCurrentPlayer = ""
	ESOThief_UIResult:SetText(ULLL.SummarisedLootedItems)
	ULLL.LootedItemsList:Refresh()
	ULLL.TimerValue = 0
	ESOThief.label2:SetText(ESOThief.SecondsToClock(ULLL.TimerValue))
	ESOThief.label3:SetText("Loot Log Is Empty")
end

function ESOThief.Start(isClean)
	if isClean == true then
		ESOThief.ClearLootedItems()
	end
	ESOThief.WorkState = ESOThief.WorkStateEnumerator["RUNNING"]
	
	ESOThief.label1:SetText(ESOThief.GetCurrentWorkStateText())
	
	local timerSetEditBoxText = ULLL.TimerSetEditBox:GetText()

	if ULLL.TimerSetEditBox ~= nil and timerSetEditBoxText ~= "" and timerSetEditBoxText ~= nil then
		ULLL.TimerSet = tonumber(timerSetEditBoxText)
		
		if ULLL.TimerValue == nil or ULLL.TimerValue == 0 then
			ULLL.TimerValue = ULLL.TimerSet * 60
		end
		
		EVENT_MANAGER:UnregisterForUpdate(ESOThief.name.."TimerUpdate")
		
		ESOThief.label2:SetText(ESOThief.SecondsToClock(ULLL.TimerValue))
		EVENT_MANAGER:RegisterForUpdate(
		ESOThief.name.."TimerUpdate",
		1000,
		function() ESOThief.TimerTick() end
		)
		ESOThief_UIWorkButtonsTimerCountdown:SetText(FormatTimeSeconds(ULLL.TimerValue))
		
	end
end

function ESOThief.Stop(isClean)
	if isClean == true then
		ESOThief.ClearLootedItems()
	end
	ESOThief.WorkState = ESOThief.WorkStateEnumerator["STOPPED"]
	
	ESOThief.label1:SetText(ESOThief.GetCurrentWorkStateText())
	
	EVENT_MANAGER:UnregisterForUpdate(ESOThief.name.."TimerUpdate")
end

function ESOThief.TimerTick()
	
	if ULLL.TimerValue ~= 0 then
		ESOThief.TimerDecrement()
	else
		ESOThief.Stop(ESOThief.IsClearStartStop)
	end
	
end

function ESOThief.TimerDecrement()
	ULLL.TimerValue = ULLL.TimerValue - 1
	ESOThief.label2:SetText(ESOThief.SecondsToClock(ULLL.TimerValue))
	ESOThief_UIWorkButtonsTimerCountdown:SetText(FormatTimeSeconds(ULLL.TimerValue))
	
end

function ESOThief.IsClearStartStopButtonCheckStateChanged(isClearStartStopButton, relativeTo)
	if ESOThief.IsClearStartStop == false then
		ESOThief.SetIsClearStartStopButtonChecked(isClearStartStopButton, relativeTo)	
	elseif ESOThief.IsClearStartStop == nil or ESOThief.IsClearStartStop == true then
		ESOThief.SetIsClearStartStopButtonUnchecked(isClearStartStopButton, relativeTo)
	end
end

function ESOThief.SetIsClearStartStopButtonChecked(isClearStartStopButton, relativeTo)

	isClearStartStopButton:SetNormalTexture("EsoUI/Art/Buttons/checkbox_checked.dds")
	isClearStartStopButton:SetPressedTexture("EsoUI/Art/Buttons/checkbox_disabled.dds")
	isClearStartStopButton:SetMouseOverTexture("EsoUI/Art/Buttons/checkbox_mouseover.dds")
	isClearStartStopButton:SetAnchor(TOPLEFT, relativeTo, TOPLEFT, 57, -5)
	isClearStartStopButton:SetDimensions(30,30)
	
	ESOThief.IsClearStartStop = true
end

function ESOThief.SetIsClearStartStopButtonUnchecked(isClearStartStopButton, relativeTo)

	isClearStartStopButton:SetNormalTexture("EsoUI/Art/Buttons/checkbox_unchecked.dds")
	isClearStartStopButton:SetPressedTexture("EsoUI/Art/Buttons/checkbox_disabled.dds")
	isClearStartStopButton:SetMouseOverTexture("EsoUI/Art/Buttons/checkbox_mouseover.dds")
	isClearStartStopButton:SetAnchor(TOPLEFT, relativeTo, TOPLEFT, 57, -5)
	isClearStartStopButton:SetDimensions(30,30)
	
	ESOThief.IsClearStartStop = false
end

function ESOThief.TimerSetInitialized(timerSetEditBox)
	ULLL.TimerSetEditBox = timerSetEditBox
end

function ESOThief.LootLogListTab()
	local LogList = GetControl(ESOThief_UI, "List")
	local ListHeaders = GetControl(ESOThief_UI, "Headers")
	local Total = GetControl(ESOThief_UI, "Result")
	local LootLogControls = GetControl(ESOThief_UI, "LootLogTotalControls")
	
	if ListHeaders ~= nil then
		ListHeaders:SetHidden(false)
	end
	
	if LogList ~= nil then
		LogList:SetHidden(false)
	end
	if Total ~= nil then
		Total:SetHidden(true)
	end
	if LootLogControls ~= nil then
		LootLogControls:SetHidden(true)
	end
end

function ESOThief.LootLogListTotal()
	local LogList = GetControl(ESOThief_UI, "List")
	local ListHeaders = GetControl(ESOThief_UI, "Headers")
	local Total = GetControl(ESOThief_UI, "Result")
	local LootLogControls = GetControl(ESOThief_UI, "LootLogTotalControls")

	if ListHeaders ~= nil then
		ListHeaders:SetHidden(true)
	end
	if LogList ~= nil then
		LogList:SetHidden(true)
	end
	if Total ~= nil then
		Total:SetHidden(false)
	end
	if LootLogControls ~= nil then
		LootLogControls:SetHidden(false)
	end
end
-- LootedItemsList

LootedItemsList = ZO_SortFilterList:Subclass()
LootedItemsList.defaults = {}
ULLL.DEFAULT_TEXT = ZO_ColorDef:New(0.4627, 0.737, 0.7647, 1) -- scroll list row text color
ULLL.LootedItemsList = nil

LootedItemsList.SORT_KEYS = {
		["lootDateTime"] = {},
		["itemName"] = {tiebreaker="lootDateTime"},
		["quantity"] = {tiebreaker="lootDateTime"},
		["receivedBy"] = {tiebreaker="lootDateTime"}
}

function LootedItemsList:New()
	local lootedItems = ZO_SortFilterList.New(self, ESOThief_UI)
	return lootedItems
end

function LootedItemsList:Initialize(control)
	ZO_SortFilterList.Initialize(self, control)
	self.sortHeaderGroup:SelectHeaderByKey("lootDateTime")
	ZO_SortHeader_OnMouseExit(ESOThief_UIHeadersLootDateTime)

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
	--d("build")
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
	control.receivedBy:SetText(zo_strformat("<<1>>", data.receivedBy))

	--control.lootDateTime.normalColor = ULLL.DEFAULT_TEXT
	--control.itemName.normalColor = ULLL.DEFAULT_TEXT
	--control.receivedBy.normalColor = ULLL.DEFAULT_TEXT

	ZO_SortFilterList.SetupRow(self, control, data)
end

function LootedItemsList:Refresh()
	--d("refresh")
	self:RefreshData()
	ESOThief.SummariseLootForPlayers()
end
--

-- Help functions
function ESOThief.GetCurrentWorkStateText()
	local result = "WORKSTATE : "
	if ESOThief.WorkState == 0 then
		result = result .. "UNKNOWN"
	elseif ESOThief.WorkState == 1 then
		result = result .. "RUNNING"
	else
		result = result .. "STOPPED"
	end
	
	return result
end

function ESOThief.GetCurrentDateTimeString()
	local currentDateTimeString = GetDateStringFromTimestamp(GetTimeStamp()) .. ""	
	
	return currentDateTimeString
end

function ESOThief.SecondsToClock(seconds)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "00:00:00";
  else
    hours = string.format("%02.f", math.floor(seconds/3600));
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return hours..":"..mins..":"..secs
  end
end
--
 
 EVENT_MANAGER:RegisterForEvent(ESOThief.name, EVENT_ADD_ON_LOADED, ESOThief.OnAddOnLoaded)