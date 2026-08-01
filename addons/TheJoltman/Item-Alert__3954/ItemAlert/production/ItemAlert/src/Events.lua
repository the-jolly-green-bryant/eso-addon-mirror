--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function OnLootReceived(eventCode, receivedBy, itemName, quantity, itemSoundCategory, lootType, lootedBy, isPickpocketLoot, questItemIcon, itemId, itemLink)

	-- Make sure that we are only checking the active player (exclude group members loot)
	if((receivedBy:sub(1, string.len(receivedBy) - 3)) == GetUnitName("player")) then

		-- ItemName is actually a link of the item. Use GetItemLinkName to retrieve the name as a text string
		local itemLinkName = string.lower(zo_strformat(SI_UNIT_NAME, GetItemLinkName(itemName)))

		-- Get the icon path for this item. used below to display icon on screen when looted
		local iconPath = GetItemLinkIcon(itemName)

		-- If we have not moved since the last looted item then do not add this looted item to nodeTotal
		local x, y = ItemAlertGps:LocalToGlobal(GetMapPlayerPosition("player"))

		-- Initialize variable to store the numerical itemType field
		local itemType = GetItemLinkItemType(itemName)

		-- Any looted item goes into the itemTotal
		local itemTotal = ItemAlert.GetCharacterSpecialItem("ItemTot")
		if itemTotal then

			itemTotal = itemTotal + quantity

		else

			itemTotal = quantity

		end
		ItemAlert.UpdateCharacterSetting("ItemTot", itemTotal)

		-- Add this node to are running total if it is contained within our list of itemTypes
		if ItemAlert.IsInList(itemType, {31, 33, 35, 37, 39, 51, 52, 53, 62, 63}) then

			if not ItemAlert.LootedNodePositions[x..","..y] then

				if ItemAlert.IsInList(string.lower(ItemAlert.InteractionName), ItemAlert.TrackedNodeNames) then

					ItemAlert.LootedNodePositions[x..","..y] = true

					local nodeTotal = ItemAlert.GetCharacterSpecialItem("NodeTot")
					if nodeTotal then

						nodeTotal = nodeTotal + 1

					else

						nodeTotal = 1

					end

					ItemAlert.UpdateCharacterSetting("NodeTot", nodeTotal)
					ItemAlert.LastLootTime = os.clock()

				end

			end

		end

		--d("Item Type:"..itemType..", Item Name:"..itemName..", Item Link Name:"..itemLinkName..", Quantity:"..quantity..", Total:"..itemTotal) --DEBUG JMH

		-- Play sound, display chat and onscreen alert, animate, and increment totals if the item name contains
		-- Note to self...curious glowing green book - "Lost Imperial Notes" ID=35719
		for k, v in pairs(ItemAlert.GetAccountSpecialItems()) do

			if string.lower(k) == itemLinkName and string.match(string.lower(k), "^" .. itemLinkName .. "$") ~= nil then

				local originalScale = ItemAlert.InfoText:GetScale()

				if ItemAlert.GetAccountSpecialItemDetail(k, "animatedisplay") then ItemAlert.PingPongAnimation(ItemAlert.InfoText) end

				if ItemAlert.GetAccountSetting("Chat") then ItemAlertChat:SetTagColor("69EEE1"):Print("Special Item: |t16:16:"..iconPath.."|t "..itemName.." x"..quantity.." Looted from: ("..ItemAlert.InteractionName..")") end
				if ItemAlert.GetAccountSetting("Sound") then

					local soundName = ItemAlert.GetAccountSpecialItemDetail(itemLinkName, "soundname")
					local volume = ItemAlert.GetAccountSpecialItemDetail(itemLinkName, "volume")

					ItemAlert.PlaySoundForSpecialItem(soundName, volume)

				end

				if ItemAlert.GetAccountSpecialItemDetail(itemLinkName, "animatedisplay") then ItemAlert.PingPongAnimation(ItemAlert.InfoText) end

				zo_callLater(function() ItemAlert.InfoText:SetScale(originalScale) end, 1500)

				if ItemAlert.GetAccountSpecialItemDetail(k, "displayscreen") then

					if ItemAlert.GetAccountSpecialItemDetail(k, "alertduration") == nil then ItemAlert.UpdateAccountSpecialItemDetail(k, "alertduration", 2.5) end

					ItemAlert.DisplayAnnouncement(itemName.." x"..quantity, iconPath, ItemAlert.GetAccountSpecialItemDetail(k, "alertduration") * 1000)

				end

				if ItemAlert.GetAccountSpecialItemDetail(k, "iconpath") == "/esoui/art/icons/icon_missing.dds" then

					ItemAlert.UpdateAccountSpecialItemDetail(k, "iconpath", iconPath)

				end

				-- Add to character data totals
				ItemAlert.AddItemQuantity(itemLinkName, quantity)

				break

			end

		end

		ItemAlert.SaveAccountSettings()
		ItemAlert.SaveCharacterSettings()

		-- Update the addons display bar
		ItemAlert.UpdateDisplayBar()

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function OnInteractResult(eventCode, result, interactTargetName)

	-- Save the name of the object we are interacting with. Used in function: IALootReceived
	ItemAlert.InteractionName = zo_strformat(SI_UNIT_NAME, interactTargetName)

	-- for ItemAlert.Debugging purposes only
	if ItemAlert.Debugging then d("-------------------- "..interactTargetName.." --------------------") end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function OnChatWindowContextRightClick(link, button, _, _, linkType, ...)

	-- Handle when the user right clicks on an item in the chat window
	if button == MOUSE_BUTTON_INDEX_RIGHT and linkType == ITEM_LINK_TYPE then

		-- Delay any action to 50ms to allow for lag
		zo_callLater(function() AddCustomMenuItem(ItemAlert.FancyName.." Add Item",
				function()

					-- Add the selected item to our saved variables and let the user know
					local v = zo_strformat(SI_UNIT_NAME, GetItemLinkName(link))

					if ItemAlert.AddItem(v, ItemAlert.GetShortName(v), true, true, 2.5, "CODE_REDEMPTION_SUCCESS", 2, true, GetItemLinkIcon(link)) then

						ItemAlert.AddItemEntries()

						ItemAlertChat:SetTagColor("69EEE1"):Print("Item: "..link.." Added to Tracked Items")

						ItemAlert.OkCreateDialog("IA_ADD_ITEM_DIALOG", "Item Alert", "You will have to reload UI or restart the game for the item added to show up in Tracked Item Settings.")

						ZO_Dialogs_ShowDialog("IA_ADD_ITEM_DIALOG")

						ItemAlert.SaveAccountSettings()
						ItemAlert.SaveCharacterSettings()
						ItemAlert.LoadAccountSettings()
						ItemAlert.LoadCharacterSettings()

					else

						ItemAlert.OkCreateDialog("IA_DUPLICATE_ITEM_DIALOG", "Item Alert", "This item is already being tracked.")

						ZO_Dialogs_ShowDialog("IA_DUPLICATE_ITEM_DIALOG")

					end

				end,
				MENU_ADD_OPTION_LABEL)
			ShowMenu()
		end, 50)

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function OnInventorySlotContextRightClick(rowControl, slotActions)

	-- Handle when the user right clicks on an inventory item
	-- Delay any action to 50ms to allow for lag
	zo_callLater(function() AddCustomMenuItem(ItemAlert.FancyName.." Add Item",
			function()

				-- Add the selected item to our saved variables and let the user know
				local bag, index = ZO_Inventory_GetBagAndIndex(rowControl)
				local link = GetItemLink(bag, index)
				local icon = GetItemInfo(bag, index)
				local v = string.lower(zo_strformat(SI_UNIT_NAME, GetItemLinkName(link)))

				if ItemAlert.AddItem(v, ItemAlert.GetShortName(v), true, true, 2.5, "CODE_REDEMPTION_SUCCESS", 2, true, icon) == true then

					ItemAlert.AddItemEntries()

					ItemAlertChat:SetTagColor("69EEE1"):Print("Item: "..link.." Added to Tracked Items")

					ItemAlert.OkCreateDialog("IA_ADD_ITEM_DIALOG", "Item Alert", "You will have to reload UI or restart the game for the item added to show up in Tracked Item Settings.")

					ZO_Dialogs_ShowDialog("IA_ADD_ITEM_DIALOG")

					ItemAlert.SaveAccountSettings()
					ItemAlert.SaveCharacterSettings()
					ItemAlert.LoadAccountSettings()
					ItemAlert.LoadCharacterSettings()

				else

					ItemAlert.OkCreateDialog("IA_DUPLICATE_ITEM_DIALOG", "Item Alert", "This item is already being tracked.")

					ZO_Dialogs_ShowDialog("IA_DUPLICATE_ITEM_DIALOG")

				end

			end,
			MENU_ADD_OPTION_LABEL)
		ShowMenu(rowControl)

	end, 50)

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function OnScreenSizeChanged()

	ItemAlert.CheckScreenSizeChanged(0)

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function OnSceneStateChangeHide(oldState, newState)

	if(newState == SCENE_SHOWN) then

		ItemAlert.HideDisplayBar()

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function OnSceneStateChangeShow(oldState, newState)

	if(newState == SCENE_SHOWN) then

		ItemAlert.ShowDisplayBar()

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function OnLoad(Event, AddonName)

	if AddonName ~= ItemAlert.AddName then return end

	ItemAlert.Logger:Debug("Saved Variables loaded")

	-- Set reference to our existing account wide settings
	ItemAlert.AccountData = ZO_SavedVars:NewAccountWide(ItemAlert.AddName.."_AccountData", 1, GetWorldName(), {})

	-- Set reference to our existing character settings
	ItemAlert.CharacterData = ZO_SavedVars:New(ItemAlert.AddName.."_CharacterData", 1, GetWorldName(), {})

	-- Note: All slash commands must be lower case
	SLASH_COMMANDS["/iaversion"] = function() ItemAlert.DisplayVersionInfo() end
	SLASH_COMMANDS["/iareset"] = function() ItemAlert.Reset() end
	SLASH_COMMANDS["/iamenu"] = function() LibAddonMenu2:OpenToPanel(ItemAlert.PanelData) end

	-- Load the addon account wide settings from the savedvariables location
	ItemAlert.LoadAccountSettings()

	-- Load the addon character specific settings from the savedvariables location
	ItemAlert.LoadCharacterSettings()

	ItemAlert.InitializeSettings()

	-- Update the available sounds from the game. the user can select these later from the addon menu
	ItemAlert.UpdateSounds()

	-- Set our start time
	ItemAlert.StartTime = os.clock()

	ItemAlert.UpdateCharacterSetting("MinutesTot", ItemAlert.GetCharacterSetting("MinutesTot"))

	ItemAlert.SaveCharacterSettings()

	-- Force update addon display bar every 10 seconds
	EVENT_MANAGER:RegisterForUpdate(ItemAlert.AddName, 10000, function(millisecondsRunning) ItemAlert.UpdateDisplayBar() end)

	-- Occurs when player interacts with an object such as an Node
	EVENT_MANAGER:RegisterForEvent(ItemAlert.AddName.."_Player", EVENT_CLIENT_INTERACT_RESULT, OnInteractResult)

	EVENT_MANAGER:RegisterForEvent(ItemAlert.AddName.."_Player", EVENT_PLAYER_ACTIVATED,
	function()

		-- Initialize our Settings Panel
		ItemAlert.InitializeLAM2Panel()
		ItemAlert.InitializeLAM2OptionData()
		ItemAlert.CreateSpecialThanksFooter(ItemAlert.PanelData)

		ItemAlert.AddItemEntries()

		-- Initialize Display bar
		ItemAlert.InitializeDisplayBar()

		ItemAlert.ShowDisplayBar()

		ItemAlert.UpdateDisplayBar()

		-- Display Version as Major.Minor.Revision. Delayed to allow time for addon to finish loading.
		zo_callLater(function() ItemAlertChat:SetTagColor("00e0ff"):Print("Version "..ItemAlert.GetFriendlyVersion().." by @TheJoltman") end, 1000)

		-- Add a callback function to handle a right click context menu item, in the chat window, that will Add Item to Item Alert
		LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, OnChatWindowContextRightClick)

		-- Add a callback function to handle a right click context menu item, in the inventory panel, that will Add Item to Item Alert
		ItemAlertLcm:RegisterContextMenu(OnInventorySlotContextRightClick)

		-- Resize our Information Bar when the user changes the screen dimensions
		EVENT_MANAGER:RegisterForEvent(ItemAlert.AddName, EVENT_SCREEN_RESIZED, OnScreenSizeChanged)

		-- Register the function to be called when an item is received
		EVENT_MANAGER:RegisterForEvent(ItemAlert.AddName, EVENT_LOOT_RECEIVED, OnLootReceived)

		-- Check mouse events to see if the user is selecting our addon
		EVENT_MANAGER:RegisterForEvent(ItemAlert.AddName.."_Vars", EVENT_GLOBAL_MOUSE_DOWN, function() ItemAlert.UpdatePosition() end)
		EVENT_MANAGER:RegisterForEvent(ItemAlert.AddName.."_Vars", EVENT_GLOBAL_MOUSE_UP, function() ItemAlert.UpdatePosition() end)

		-- If we get a right-click from the mouse then load the addon menu
		ItemAlert.InfoText:SetHandler("OnMouseUp", function(_, button) if button == 2 then LibAddonMenu2:OpenToPanel(ItemAlert.PanelData) end end)

		-- Iterate over all known scenes and hide the addon where needed
		for sceneName, scene in pairs(SCENE_MANAGER.scenes) do

			if sceneName == "hud" or sceneName == "hudui" or sceneName == "gameMenuInGame" then

				SCENE_MANAGER:GetScene(sceneName):RegisterCallback("StateChange", OnSceneStateChangeShow)

			else

				SCENE_MANAGER:GetScene(sceneName):RegisterCallback("StateChange", OnSceneStateChangeHide)

			end

		end

		-- Deregister Player Event No Longer Needed
		EVENT_MANAGER:UnregisterForEvent(ItemAlert.AddName.."_Player", EVENT_PLAYER_ACTIVATED)

		ItemAlert.Logger:Debug("Initialization complete")

	end)

	EVENT_MANAGER:UnregisterForEvent(ItemAlert.AddName.."_OnLoad", EVENT_ADD_ON_LOADED)
	
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function OnAchievementUpdated(eventCode, achievementId)
	if IsAchievementComplete(achievementId) then return end
	numCriteria = GetAchievementNumCriteria(achievementId)
	if numCriteria == 1 then
		local criterionDescription, numCompleted, numRequired = GetAchievementCriterion(achievementId, i)
		d(string.format("Achievement Update %s: %d/%d\n", GetAchievementLink(achievementId, LINK_STYLE_BRACKETS), numCompleted, numRequired))
	end
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--EVENT_MANAGER:RegisterForEvent(ItemAlert.AddName.."_Achieve", EVENT_ACHIEVEMENT_UPDATED, OnAchievementUpdated)
EVENT_MANAGER:RegisterForEvent(ItemAlert.AddName.."_Hide", EVENT_CHATTER_BEGIN, function() ItemAlert.HideDisplayBar() end)
EVENT_MANAGER:RegisterForEvent(ItemAlert.AddName.."_Show", EVENT_CHATTER_END, function() ItemAlert.ShowDisplayBar() ItemAlert.UpdateDisplayBar() end)
EVENT_MANAGER:RegisterForEvent(ItemAlert.AddName.."_OnLoad", EVENT_ADD_ON_LOADED, OnLoad)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------