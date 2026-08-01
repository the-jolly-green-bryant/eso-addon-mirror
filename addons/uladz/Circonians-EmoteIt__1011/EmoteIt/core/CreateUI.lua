

local libScroll = LibStub:GetLibrary("LibScroll")

EmoteIt = EmoteIt or {}

-- Called when an update is needed IF were on the favorites panel
-- called when we remove favorites from either scroll list
local function TryUpdateFavorites()
	local selectedCat = EmoteItWinMenuBar.m_object:GetSelectedDescriptor()
	
	-- Only update the list if were on the Favorite panel
	if selectedCat == EMOTEIT_CATEGORY_FAVORITES then
		EmoteIt:UpdateMainListByCategory(EMOTEIT_CATEGORY_FAVORITES)
		return true
	end
end

-- called when we need an update if were on the trigger panel
-- Called when we delete triggers from trigger scroll list
local function TryUpdateTriggerPanel()
	local selectedCat = EmoteItWinMenuBar.m_object:GetSelectedDescriptor()
	
	-- Only update the list if were on the Favorite panel
	if selectedCat == EMOTEIT_CATEGORY_TRIGGERS then
		EmoteIt:UpdateMainListByCategory(EMOTEIT_CATEGORY_TRIGGERS)
		return true
	end
end

local function AddFavorite(selectedData)
	local emoteIndex = selectedData.emoteIndex
	if not emoteIndex then return end
	
	-- Mark as fav in our saved emoteData
	-- Save it as a favorite in saved vars
	-- Mark the current scroll List data as a favorite
	EmoteIt.emoteData[emoteIndex].favorite = true
	EmoteIt.sv.favEmotes[emoteIndex] = true
	selectedData.favorite = true
	
	TryUpdateFavorites()
end
local function RemoveFavorite(selectedData)
	local emoteIndex = selectedData.emoteIndex
	if not emoteIndex then return end
	
	-- Unmark as fav in our saved emoteData
	-- Remove it as a favorite in saved vars
	-- Unmark the current scroll List data as a favorite
	EmoteIt.sv.favEmotes[emoteIndex] = nil
	selectedData.favorite = nil
	EmoteIt.emoteData[emoteIndex].favorite = nil
	
	TryUpdateFavorites()
end

-- called to delete the selectedEmoteIndex that corresponds to the
-- given triggerText in the given chat channel
local function DeleteEmoteFromTrigger(channel, triggerText, selectedEmoteIndex)
	local triggerTable 	= EmoteIt.sv.triggers[channel][triggerText]
	
	for key, emoteIndex in pairs(triggerTable) do
		if selectedEmoteIndex == emoteIndex then
			local next = next
			-- Remove the emote Index from the triggerText table
			--EmoteIt.sv.triggers[channel][triggerText][key] = nil
			table.remove(EmoteIt.sv.triggers[channel][triggerText], key)
			
			-- If the triggerText table for this channel is now empty, remove it too
			if next(EmoteIt.sv.triggers[channel][triggerText]) == nil then
				EmoteIt.sv.triggers[channel][triggerText] = nil
			end
			-- If there are no more emotes triggered by this text
			-- on ANY channel
			local emotes = EmoteIt:GetEmotesForTrigger(triggerText)
			if next(emotes) == nil then
				-- There are no more triggers for this text, if were on 
				-- the main window trigger panel, update it &
				-- close the trigger window.
				if TryUpdateTriggerPanel() then
					EmoteIt.triggerWin:SetHidden(true)
				end
			end
			return
		end
	end
end

local function DeleteTrigger(selectedData) 
	local channel = selectedData.channel
	-- If the trigger scroll List has emotes in it we can get the trigger text from EmoteIt.addTriggerWin.selectedTriggerText & the selected index from selectedData
	-- if the trigger scroll List has trigger text in it we can get the trigger text from the selected data & the emoteIndex from EmoteIt.addTriggerWin.selectedEmoteIndex 
	
	-- If the trigger scroll list contains emotes use these
	local selectedEmoteIndex 	= selectedData.emoteIndex
	local triggerText 			= EmoteIt.addTriggerWin.selectedTriggerText
	local updateCategory		= EMOTEIT_CATEGORY_ALL
	local updateCondition		= triggerText
	
	-- If not then trigger scroll list contains trigger text
	if not selectedEmoteIndex then
		selectedEmoteIndex 	= EmoteIt.addTriggerWin.selectedEmoteIndex
		triggerText 		= selectedData.displayText
		updateCategory		= EMOTEIT_CATEGORY_TRIGGERS
		updateCondition		= selectedEmoteIndex
	end
	
	if not (triggerText and selectedEmoteIndex and channel) then return end	
	
	DeleteEmoteFromTrigger(channel, triggerText, selectedEmoteIndex)
	EmoteIt:UpdateTriggerList(updateCategory, updateCondition)
end

-- Right click context menu for the main scroll list
local function ShowMainListContextMenu(selectedData)
	ClearMenu()
	local emoteIndex = selectedData.emoteIndex
	
	if emoteIndex then
		if selectedData.favorite then
			AddCustomMenuItem("Unmark As Favorite", function() RemoveFavorite(selectedData) end)
		else
			AddCustomMenuItem("Mark As Favorite", function() AddFavorite(selectedData) end)
		end
	end
	
	ShowMenu()
end

-- Right click context menu for the trigger scroll list
local function ShowTriggerListContextMenu(selectedData)
	ClearMenu()
	local menuEntries = {}
	local emoteIndex = selectedData.emoteIndex
	
	if emoteIndex then
		if selectedData.favorite then
			AddCustomMenuItem("Unmark As Favorite", function() RemoveFavorite(selectedData) end)
		else
			AddCustomMenuItem("Mark As Favorite", function() AddFavorite(selectedData) end)
		end
	end
	AddCustomMenuItem("Delete Trigger", function() DeleteTrigger(selectedData) end)
	
	ShowMenu()
end

-- converts a channel to channel text
function EmoteIt:ChannelToText(channel)
	local channels = {
		[ALL_CHAT_CHANNELS] 	= "(All Channels)",
		[CHAT_CHANNEL_SAY] 		= "(Say Channel)",
		[CHAT_CHANNEL_YELL] 	= "(Yell Channel)",
		[CHAT_CHANNEL_PARTY] 	= "(Party Channel)",
		[CHAT_CHANNEL_EMOTE] 	= "(Emote Channel)",
	}
	return channels[channel]
end
--===================================--
--======== Trigger ScrollList =========--
--===================================--
-- This is the scroll list in the secondary window that holds triggers
-- triggers: Meaning text that triggers the selected emote or emotes that
--   are triggered by the selected text
local function CreateTriggerScrollList(self)
	local function OnTriggerRowSetup(rowControl, data, scrollList)
		local text = ""
		local channel = self:ChannelToText(data.channel)
		text = data.displayText.." "..channel
			
		rowControl:SetText(text)
		rowControl:SetFont("ZoFontWinH4")
		rowControl:SetHandler("OnMouseUp", function(self, button, upInside)
			if not upInside then return end
			-- do nothing on left click
			if button == 2 then
				ShowTriggerListContextMenu(data)
			end
		end)
	end
	local function SortScrollList(a, b) 
		if a.data.channel < b.data.channel then 
			return true 
		elseif a.data.channel == b.data.channel then 
			if a.data.displayText < b.data.displayText then 
				return true 
			end
		end
		return false
	end
	local scrollData = {
		name = "EmoteIt_Trigger_ScrollList",
		parent = self.triggerWin,
		width = 300,
		height = 150,
		rowHeight = 23,
		
		setupCallback = OnTriggerRowSetup,
		selectTemplate 	= "ZO_ThinListHighlight",
		sortFunction	= SortScrollList,
		
		categories	= {1,2,3},
	}
	local scrollList = libScroll:CreateScrollList(scrollData)
	scrollList:ClearAnchors()
	
	local curTrigBg = self.triggerWin:GetNamedChild("TriggersBg")
	
	scrollList:SetAnchor(TOPLEFT, curTrigBg, TOPLEFT, 50, 30)
	scrollList:SetAnchor(BOTTOMRIGHT, curTrigBg, BOTTOMRIGHT, -50, -25)
	
	self.scrollListTriggers = scrollList
end

--===================================--
--====== MAIN ScrollList  ======--
--===================================--
local function CreateMainScrollList(self)
	-- Main scroll list row setupCallback
	local function setupDataRow(rowControl, data, scrollList)
		rowControl:SetFont("ZoFontWinH4")
		rowControl:SetText(data.displayText)    
		
		rowControl:SetHandler("OnMouseUp", function(self, button, upInside)
			if not upInside then return end
			if button == 1 then
				ZO_ScrollList_MouseClick(scrollList, rowControl)
			elseif button == 2 then
				ShowMainListContextMenu(data)
			end
		end)
	end
	-- Main scroll list rowSelectCallback
	local function OnRowSelection(previouslySelectedData, selectedData, reselectingDuringRebuild)
		EmoteIt.triggerEb:Clear()
		if not selectedData then 
			EmoteIt.triggerWin:SetHidden(true)
			return
		end
		EmoteIt.triggerWin:SetHidden(false)
		
		local emoteIndex = selectedData.emoteIndex
		local displayText = selectedData.displayText
		
		EmoteIt.triggerCurName:SetText(displayText)
			
		if emoteIndex then
			EmoteIt.addTriggerWin:SetHidden(false)
			EmoteIt.addTriggerWin.selectedEmoteIndex = emoteIndex
			EmoteIt.addTriggerWin.selectedTriggerText = nil
			
			EmoteIt.triggerCurLabel:SetText("Selected Emote: ")
			local textWidth = EmoteIt.triggerCurLabel:GetTextWidth()
			EmoteIt.triggerCurLabel:SetWidth(125)
			EmoteIt.triggerWinTriggersLabel:SetText("Text that Triggers Emote: ")
			
			EmoteIt:UpdateTriggerList(EMOTEIT_CATEGORY_TRIGGERS, emoteIndex)
			PlayEmoteByIndex(emoteIndex)
		else
			EmoteIt.addTriggerWin:SetHidden(true)
			EmoteIt.addTriggerWin.selectedEmoteIndex = nil
			EmoteIt.addTriggerWin.selectedTriggerText = displayText
			
			EmoteIt.triggerCurLabel:SetText("Selected Trigger: ")
			local textWidth = EmoteIt.triggerCurLabel:GetTextWidth()
			EmoteIt.triggerCurLabel:SetWidth(140)
			EmoteIt.triggerWinTriggersLabel:SetText("Emotes Triggered by Text: ")
			EmoteIt:UpdateTriggerList(EMOTEIT_CATEGORY_ALL, displayText)
		end
	end

	-- Main scroll list Sort fun
	local function SortScrollList(a, b)
		if a.data.displayText < b.data.displayText then return true end
		return false
	end

	local scrollData = {
		name = "MyTestScrollList",
		parent = EmoteItWin,
		width = 300,
		height = 500,
		
		rowHeight = 23,
		setupCallback = setupDataRow,
		
		selectTemplate 	= "ZO_ThinListHighlight",
		selectCallback 	= OnRowSelection,
		sortFunction	= SortScrollList,
		
		categories	= {EMOTEIT_CATEGORY_ALL, EMOTEIT_CATEGORY_FAVORITES},
	}
	local scrollList = libScroll:CreateScrollList(scrollData)
	scrollList:ClearAnchors()
	scrollList:SetAnchor(TOPLEFT, EmoteItWinMenuBar, BOTTOMLEFT, 0, 20)
	scrollList:SetAnchor(BOTTOMRIGHT, EmoteItWin, BOTTOMRIGHT, -10, -10)
	
	ZO_MenuBar_SelectDescriptor(EmoteItWinMenuBar, EMOTEIT_CATEGORY_ALL, false)
	self.scrollListMain = scrollList
end


--===================================--
--====== Initialize Other Stuff ======--
--===================================--
local function CreateDividers()
	local divider2 = CreateControlFromVirtual("EmoteItMenuDivider2", EmoteItWin, "ZO_InventoryFilterDivider")
	divider2:ClearAnchors()
	divider2:SetAnchor(TOPLEFT, EmoteItWinMenuBar, BOTTOMLEFT, 0, 20)
	divider2:SetAnchor(BOTTOMRIGHT, EmoteItWinMenuBar, BOTTOMRIGHT, 0, 20)
end

local function InitializeDropdownChannels(self)
	local ddl = self.triggerDDL
	local comboBox = ddl.m_comboBox
	comboBox:ClearItems()
	
	local function ddlSelectCallback(comboBox, itemName, item, selectionChanged)
		if not selectionChanged then return end
		
		ddl.selectedChannel = item.channel
	end
	
	local ddlItems = {
		[1] = {name = "All", 	callback=ddlSelectCallback, channel=ALL_CHAT_CHANNELS},
		[2] = {name = "/Say", 	callback=ddlSelectCallback, channel=CHAT_CHANNEL_SAY},
		[3] = {name = "/Yell", 	callback=ddlSelectCallback, channel=CHAT_CHANNEL_YELL},
		[4] = {name = "/Party", callback=ddlSelectCallback, channel=CHAT_CHANNEL_PARTY},
		[5] = {name = "/Emote", callback=ddlSelectCallback, channel=CHAT_CHANNEL_EMOTE},
	}
	
	comboBox:AddItems(ddlItems)
	comboBox:SelectFirstItem()
end

local function InitializeMenuBar(self)
	local menuBar = self.menuBar
	ZO_MenuBar_ClearButtons(menuBar)
	
	for _, filterInfo in ipairs(self.filterData) do
		local btn = ZO_MenuBar_AddButton(menuBar, filterInfo)
	end
end

local function InitializeWindowPositions(self)
	local mainWinOffsetX 	= self.sv.mainWinSettings.offsetX
	local mainWinOffsetY 	= self.sv.mainWinSettings.offsetY
	local mainWinWidth 		= self.sv.mainWinSettings.width
	local mainWinHeight		= self.sv.mainWinSettings.height
	
	self.mainWin:ClearAnchors()
	self.mainWin:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mainWinOffsetX, mainWinOffsetY)
	self.mainWin:SetDimensions(mainWinWidth, mainWinHeight)
	self.mainWin:SetHidden(self.sv.mainWinSettings.hidden)
end


function EmoteIt:InitializeUI()
	InitializeMenuBar(self)
	InitializeWindowPositions(self)
	InitializeDropdownChannels(self)
	CreateMainScrollList(self)
	CreateTriggerScrollList(self)
end









