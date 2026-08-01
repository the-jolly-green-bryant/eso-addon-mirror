-- Grubmaster add-on for Elder Scrolls Online
-- Author: AethronX

-- Uses LibFoodDrinkBuff library by Scootworks, Baertram
-- Uses LibCustomMenu library by votan

-- KNOWN ISSUES (MINOR):
-- Food and drink items do not show option to autoconsume in gamepad mode
-- Text is not localized
-- Timer isn't unregistered when auto-consumption is turned off

-- FUTURE IDEAS:
-- On screen messages (not chat) for some things (low inventory, food eaten, etc.)
-- Add visual indicator on screen showing selected food, inventory, and status messages
-- Add setup dialog to change food, buffer, and other settings
-- Add ability to craft selected food automatically when inventory under a certain threshold
-- Allow backup foods to be selected
-- Add more interesting/fun/characterbased messages after eating
-- Add an indicator icon to the selected food in inventory
-- Add option to automatically remove additional food from bank when under threshold
-- Consider adding confirmation dialogs when adding/turning off via context menu
-- Add option to prompt for confirmation for gold food (suggested by Tonyleila)
-- Add option to use different food based on where you are: Food a) enter pvp zone and food b) enter a trail / veteran DLC dungeon etc. (suggested by Tonyleila)

-- Version 1.00 09/07/2018
-- Version 1.01 10/22/2018 Updated for Murkmire (100025)
-- Version 1.02 02/25/2019 Updated for Wrathstone DLC (100026)
-- Version 1.03 05/19/2019 Updated for Elsweyr (100027); Calls addon with global LIB_FOOD_DRINK_BUFF  
-- Version 1.04 08/12/2019 Updated for Scalebreaker (100028); Updated embedded LibFoodDrinkBuff library
-- Version 1.05 12/08/2019 Updated for Dragonhold (100029); Updated LibFoodDrinkBuff library; Adds LibCustomMenu
-- Version 1.06 05/14/2020 Updated for Greymoor (100031); Updated LibFoodDrinkBuff library; Updated LibCustomMenu
-- Version 1.07 08/24/2020 Updated for Stonethorn (100032); Updated LibFoodDrinkBuff library; Updated LibCustomMenu; Adds check for scrying/digging games

Grubmaster = {
	Name = "Grubmaster",
	Author = "AethronX",
	Version = 1.07,
	SettingsVersion = 1.0,
	SettingsName = "Grubmaster_SavedVariables"
	}
	
Grubmaster.defaults = {
    isAutoEatFood = false,
	foodLink = "",
	foodBufferSeconds = 300 -- seconds
	}
			
Grubmaster.savedVariables = {}

-- LibFoodDrinkBuff library
local LFDB = LIB_FOOD_DRINK_BUFF

-- local constants
local context_menu_label_on = "Consume Automatically"
local context_menu_label_off = "Stop Consuming Automatically"
local slash_command_turn_on = "/grubmasteron"
local slash_command_turn_off = "/grubmasteroff"	
local slash_command_show_settings = "/grubmastershowsettings"
local slash_command_change_buffer = "/grubmasterbufferseconds"
local update_timer_period = 10000 -- milliseconds
local low_inventory_warning_threshold = 5 -- items
local player_unit_tag = "player"
local context_menu_delay = 50 -- milliseconds
local consumed_message_delay = 2000 -- milliseconds
local food_buffer_seconds_min = 0 -- seconds
local food_buffer_seconds_max = 600 -- seconds
local out_of_inventory_warning_frequency = 60 -- seconds
local update_sound = SOUNDS.DIALOG_ACCEPT

-- flags
local isEatOnNextUpdate = false
local lastOutOfInventoryWarningTime = GetFrameTimeSeconds()

local function GetBackpackInventory(itemLink) -- Returns: number inventoryCount
	local inventoryCount = 0
	
	if itemLink == "" then return inventoryCount end

	-- get the character bag size
	local numSlots = GetBagSize(BAG_BACKPACK)
	
	-- iterate through backpack bag to find all matching items, and add their counts to the total
	for slotIndex = 0, numSlots do
		local slotItemLink = GetItemLink(BAG_BACKPACK, slotIndex)
		if slotItemLink == itemLink then
			local itemCount = GetItemTotalCount(BAG_BACKPACK, slotIndex)
			inventoryCount = inventoryCount + itemCount
		end
	end
	
	return inventoryCount
end

local function ShowSettingsInChat()
    local foodBufferMinutes = math.floor(Grubmaster.savedVariables.foodBufferSeconds / 60)
	
	if Grubmaster.savedVariables.foodLink == "" then
		d("No food has been selected yet. Open inventory, right click on the food or drink you want, and choose the " .. context_menu_label_on .. " option.")
		return
	end
	
	if not Grubmaster.savedVariables.isAutoEatFood then
		d("Automatic eating is turned off. But you have selected " .. Grubmaster.savedVariables.foodLink .. " as your preferred food.")
		d("To enable automatic eating for this character use " .. slash_command_turn_on .. ", or open inventory, right click on the food or drink you want, and choose the " .. context_menu_label_on .. " option.")
	else
		d("Looks like " .. Grubmaster.savedVariables.foodLink .. " is on the menu.")

		if Grubmaster.savedVariables.foodBufferSeconds > 60 then
			d(zo_strformat("This will be consumed  <<1[when/$d minute before/$d minutes before]>> your current food expires.", foodBufferMinutes))
		else
			d(zo_strformat("This will be consumed  <<1[when/$d second before/$d seconds before]>> your current food expires.", Grubmaster.savedVariables.foodBufferSeconds))
		end

		local remainingInventory = GetBackpackInventory(Grubmaster.savedVariables.foodLink)
		if remainingInventory <= low_inventory_warning_threshold and remainingInventory ~= 0 then
			d("You have only " .. remainingInventory .. " left in your bag.")
		else
			d("You have " .. remainingInventory .. " left in your bag.")
		end
		
		d("If you wish to stop automatic eating for this character, use " .. slash_command_turn_off .. " in the chat window.")
	end;
end	
	
local function SetFoodBufferSeconds(foodBufferSeconds)
	local oldBuffer = Grubmaster.savedVariables.foodBufferSeconds
	local newBuffer = tonumber(foodBufferSeconds)
	
	if type(newBuffer) == "number" then
		newBuffer = math.floor(newBuffer)
		if newBuffer >= food_buffer_seconds_min and newBuffer <= food_buffer_seconds_max then
			if newBuffer ~= oldBuffer then
				Grubmaster.savedVariables.foodBufferSeconds = newBuffer
				PlaySound(update_sound)				
			end
		end
	end
	
	d("Food will be consumed " .. Grubmaster.savedVariables.foodBufferSeconds .. " seconds before current food expires.")
	
	if oldBuffer == Grubmaster.savedVariables.foodBufferSeconds then
		d("Use a number between " .. food_buffer_seconds_min .. " and " .. food_buffer_seconds_max .. " with " .. slash_command_change_buffer .. " to change buffer time.")
	end
end

	
local function SetIsAutoEating(isAutoEating)

	-- only have to change anything if auto eating is already in the requested status
	if Grubmaster.savedVariables.isAutoEatFood ~= isAutoEating then

		-- if turning on, check to make sure foodLink has been set already
		if isAutoEating then
			if Grubmaster.savedVariables.foodLink == "" then
				Grubmaster.savedVariables.isAutoEatFood = false			
			else
				Grubmaster.savedVariables.isAutoEatFood = true
			end
		else
			Grubmaster.savedVariables.isAutoEatFood = false
		end

	end
	
	-- show the settings
	PlaySound(update_sound)
	ShowSettingsInChat()
end
	
local function IsExperienceDrink(bagId, slotIndex) -- Returns: boolean isExpDrink
	-- get the bag item's itemId
	local itemId = GetItemId(bagId, slotIndex)

	-- check to see if the itemId matches any of the experience drinks, and return true if it does
	if		itemId == 64221		then return	true	-- Psijic Ambrosia
	elseif	itemId == 120076	then return	true	-- Aetherial Ambrosia
	elseif	itemId == 115027	then return	true	-- Mythic Aetherial Ambrosia
	else return false end
end

local function IsValidFoodOrDrink(bagId, slotIndex) -- Returns: boolean isValidFood
	-- get the bag item's itemType
	local itemType = GetItemType(bagId, slotIndex)
	
	-- check to see if it's not a food or drink
	if not (itemType == ITEMTYPE_DRINK or itemType == ITEMTYPE_FOOD) then 
		return false
	end

	-- make sure it's not one of the experience drinks
	if IsExperienceDrink(bagId, slotIndex) then return false end
	
	return true
end

local function AddContextMenuItem(rowControl)
	-- add a context menu item to select for automatic consumption if right clicking on a usable food or drink
	-- does not work in gamepad mode

	if IsValidFoodOrDrink(rowControl.bagId, rowControl.slotIndex) then
		local itemLink = GetItemLink(rowControl.bagId, rowControl.slotIndex)
		
		if (itemLink == Grubmaster.savedVariables.foodLink) and (Grubmaster.savedVariables.isAutoEatFood) then
			AddCustomMenuItem(context_menu_label_off, 
				function() 
					SetIsAutoEating(false)
				end, 
				MENU_ADD_OPTION_LABEL)
		else
			AddCustomMenuItem(context_menu_label_on, 
				function()
					Grubmaster.savedVariables.foodLink = itemLink
					SetIsAutoEating(true)
				end, 
				MENU_ADD_OPTION_LABEL)
		end
	end

	ShowMenu(self)
end

local function AddContextMenuItemWithDelay(rowControl)
	zo_callLater(function() AddContextMenuItem(rowControl) end, context_menu_delay)
end

local function CanUseItem(bagId, slotIndex) -- Returns: boolean canUseItem
	-- check that it's a usable item
	local usable, usableOnlyFromActionSlot = IsItemUsable(bagId, slotIndex)
	local canInteract = CanInteractWithItem(bagId, slotIndex)
	return usable and not usableOnlyFromActionSlot and canInteract
end

local function TryUseFoodItem(bagId, slotIndex) -- Returns: boolean success
	-- make sure that what we're about to use really is a valid food item and is usable
	if IsValidFoodOrDrink(bagId, slotIndex) then
		if CanUseItem(bagId, slotIndex) then
			-- use the food item
			-- UseItem is protected, so CallSecureProtected is used to make the call
			local success = CallSecureProtected("UseItem", bagId, slotIndex)
			return success
		end
	end
end

local function ShowLowInventoryWarning(itemLink)
	-- note: item count doesn't update quickly enough right after item is used, so this should be a delayed call if after item use
	-- calculate the remaining inventory for itemLink and show a warning if it's under the threshold
	local remainingInventory = GetBackpackInventory(itemLink)

	if remainingInventory <= low_inventory_warning_threshold then
		d(zo_strformat("You have <<1[$d/only $d/only $d]>> left in your bag.", remainingInventory))
	end
end

local function VerifyConsumed() -- Returns: boolean wasConsumed
	-- load the LibFoodDrinkBuff library and get the player's current food buff status
	local isBuffActive, timeLeftInSeconds, abilityId = LFDB:IsFoodBuffActiveAndGetTimeLeft(player_unit_tag)

	-- make sure the food buff activated. if it has more than the max food buffer left, then it must be a new buff
	return isBuffActive and timeLeftInSeconds > food_buffer_seconds_max
end

local function ShowConsumedMessage(itemLink)
	-- verify that food was consumed (in case useitem call failed without returning false), tell player, and warn if inventory is running out
	-- this should be called with a delay so inventory and buff information has time to update first
	if VerifyConsumed() then
		-- show a message that the item was consumed
		d(itemLink .. " has been automatically consumed.")
	
		ShowLowInventoryWarning(itemLink)
	end
end

local function EatFood() -- Returns: boolean success
	-- get the character bag size
	local numSlots = GetBagSize(BAG_BACKPACK)
	
	-- iterate through bag to find the item that matches stored foodLink setting
	for slotIndex = 0, numSlots do
		local slotItemLink = GetItemLink(BAG_BACKPACK, slotIndex)
		if slotItemLink == Grubmaster.savedVariables.foodLink then
			local success = TryUseFoodItem(BAG_BACKPACK, slotIndex)
			if success then
				-- doesn't seem to update inventory quickly enough to get a correct low inventory count, so call the message with a delay
				zo_callLater(function() ShowConsumedMessage(slotItemLink) end, consumed_message_delay)	
				return true
			else
				return false
			end
		end
	end
	
	-- item wasn't found
	-- get the player's current food buff status and warn in chat
	-- don't want to warn on every timer loop, so check the last warning time flag and the frequency first
	local currentFrameTimeSecs = GetFrameTimeSeconds()
	if currentFrameTimeSecs - lastOutOfInventoryWarningTime > 60 then
		lastOutOfInventoryWarningTime = currentFrameTimeSecs
	
		-- load the LibFoodDrinkBuff library and get the player's current food buff status
		local isBuffActive, timeLeftInSeconds, abilityId = LFDB:IsFoodBuffActiveAndGetTimeLeft(player_unit_tag)
		local timeLeftInMinutes = math.floor(timeLeftInSeconds / 60)
	
		d("You have set " .. Grubmaster.savedVariables.foodLink .. " to " .. context_menu_label_on .. " but have 0 in your bag.")

		if isBuffActive then
			if timeLeftInSeconds < 60 then
				d(zo_strformat("Your current food will expire in <<1[$d seconds./$d second./$d seconds.]>>", timeLeftInSeconds)) 
			else
				d(zo_strformat("Your current food will expire in <<1[$d minutes./$d minute./$d minutes.]>>", timeLeftInMinutes))
			end
		end
	end
	
end

local function IsUnitAbleToUseFood(unitTag) -- Returns: boolean isAbleToUseFood
	-- check for certain player statuses that make using food impossible or undesirable
	if IsUnitInCombat(unitTag) then return
	elseif IsUnitDeadOrReincarnating(unitTag) then return
	elseif IsUnitSwimming(unitTag) then return
	elseif IsPlayerInteractingWithObject() then return
	elseif IsScryingInProgress() then return
	elseif IsDiggingGameActive() then return
	else return true end

end

local function OnUpdateTimer()
	-- exit immediately if automatic eating is turned off, no food is selected, or the player is currently in combat, dead, or in some other unvailable state
	if not Grubmaster.savedVariables.isAutoEatFood then return end
	if not IsUnitAbleToUseFood(player_unit_tag) then return end
	if Grubmaster.savedVariables.foodLink == "" then return end

	-- get the player's current food buff status
	local isBuffActive, timeLeftInSeconds, abilityId = LFDB:IsFoodBuffActiveAndGetTimeLeft(player_unit_tag)
	
	-- if not already food buffed, set a flag to eat on the next try and exit
	-- flag could prevent potential problem if this triggers between current buff fading and new one starting
	if not isBuffActive then
		if not isEatOnNextUpdate then
			isEatOnNextUpdate = true
		else
			isEatOnNextUpdate = false
			EatFood()
		end
		return
	end

	-- clear the flag if we got this far in case they manually ate something while waiting for the next update
	isEatOnNextUpdate = false

	-- eat if the current buff time is less than or equal to the buffer
	-- we don't want to eat all the food up immediately if the buffer gets set really high somehow, so validate that the buffer is in range first
	local foodBuffer = Grubmaster.savedVariables.foodBufferSeconds
	if foodBuffer >= food_buffer_seconds_min and foodBuffer <= food_buffer_seconds_max then
		if timeLeftInSeconds <= foodBuffer then
			EatFood()
		end
	else
		-- fix the buffer
		Grubmaster.savedVariables.foodBufferSeconds = Grubmaster.defaults.foodBufferSeconds
	end
	
end	

local function Initialize()
	-- load saved variables
    Grubmaster.savedVariables = ZO_SavedVars:NewCharacterNameSettings(Grubmaster.SettingsName, Grubmaster.SettingsVersion, nil, Grubmaster.defaults)

	-- set up slash commands
	SLASH_COMMANDS[slash_command_turn_on] = function() SetIsAutoEating(true) end
	SLASH_COMMANDS[slash_command_turn_off] = function() SetIsAutoEating(false) end
	SLASH_COMMANDS[slash_command_show_settings] = ShowSettingsInChat
	SLASH_COMMANDS[slash_command_change_buffer] = SetFoodBufferSeconds
	
	-- start the timer
	EVENT_MANAGER:RegisterForUpdate(Grubmaster.name, update_timer_period, OnUpdateTimer)
end

local function OnAddOnLoaded(eventCode, name)
    if (name == Grubmaster.Name) then
		EVENT_MANAGER:UnregisterForEvent(Grubmaster.Name, eventCode)
		Initialize()
    end
end


EVENT_MANAGER:RegisterForEvent(Grubmaster.Name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

ZO_PreHook("ZO_InventorySlot_ShowContextMenu", AddContextMenuItemWithDelay)