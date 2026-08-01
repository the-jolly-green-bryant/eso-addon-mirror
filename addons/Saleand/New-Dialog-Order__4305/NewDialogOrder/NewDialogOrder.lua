NewDialogOrder = NewDialogOrder or {}

local name = "NewDialogOrder"
local version = "0.2.5"
local author = "vexaiv"

local numPriorities

local defaults = {
	unreadToFront = true,
	keepConversation = true,
	customize = false,
	priorities = {
		[CHATTER_START_SHOP] = 1, --600
		[CHATTER_START_BANK] = 2, --1200
		[CHATTER_START_GUILDBANK] = 3, --3300
		[CHATTER_START_TRADINGHOUSE] = 4, --3400
		[CHATTER_START_BUY_BAG_SPACE] = 5, --1600
		[CHATTER_TALK_CHOICE_MONEY] = 6, --102
		[CHATTER_START_NEW_QUEST_BESTOWAL] = 7, --200
		[CHATTER_START_COMPLETE_QUEST] = 8, --300
		[CHATTER_START_STABLE] = 9, --3100
	},
	ignore = {},
}

local function populateControlWithNewData(controlIndex, data, dataIndex)
	INTERACTION:PopulateChatterOption(
		controlIndex,
		dataIndex,
		data[dataIndex].optionString,
		data[dataIndex].optionType,
		data[dataIndex].optionalArg,
		data[dataIndex].isImportant,
		data[dataIndex].chosenBefore,
		data[dataIndex].importantOptions,
		data[dataIndex].teleportNPCId,
		data[dataIndex].waypointIdTable,
		data[dataIndex].dialogueTone)
end

local function arraySwap(array, index1, index2)
	if index1 == index2 then return end
	
	local diff = index2 - index1
	local step = diff > 0 and 1 or -1
	
	for i = 0, diff - step, step do
		local swapIndex1 = index1 + i
		local swapIndex2 = index1 + i + step
		local val1 = array[swapIndex1]
		local val2 = array[swapIndex2]
		array[swapIndex1] = val2
		array[swapIndex2] = val1
	end
end

local function arrayMoveValueToIndex(array, value, index)
	for i = 1, #array do
		if array[i] == value then
			arraySwap(array, i, index)
			break
		end
	end
end

local function getPriorityForType(optionType)
	--using savedVars (they are created if LibAddonMenu is loaded)
	if NewDialogOrder.savedVars and NewDialogOrder.savedVars.customize then
		if NewDialogOrder.savedVars.ignore[optionType] then return nil
		else return NewDialogOrder.savedVars.priorities[optionType] end
	--using defaults (without LibAddonMenu or when customize is off)
	else return defaults.priorities[optionType] end
end

local function isTalkContinue(optionType)
	return optionType == CHATTER_TALK_CHOICE
end

local function setNewOrder(optionCount)
	local newOrder = {}
	
	local optionsData = {}
	local importantOptions = {}
	for i = 1, optionCount do
		--get data of the chatter option i
		local optionString, optionType, optionalArg, isImportant, chosenBefore, teleportNPCId, dialogueTone = GetChatterOption(i)
		local waypointIdTable = { GetChatterOptionWaypoints(i) }
		
		--save it
		optionsData[i] = {
			optionString = optionString,
			optionType = optionType,
			optionalArg = optionalArg,
			isImportant = isImportant,
			chosenBefore = chosenBefore,
			importantOptions = importantOptions,
			teleportNPCId = teleportNPCId,
			waypointIdTable = waypointIdTable,
			dialogueTone = dialogueTone,
		}
		
		local priorityType = getPriorityForType(optionType)
		if priorityType then
			--put prioritized option i to appropriate priority index in array
			--index+1 because the index 1 will be used for keepConversation options
			if newOrder[priorityType + 1] == nil then newOrder[priorityType + 1] = {} end
			table.insert(newOrder[priorityType + 1], i)
		elseif not chosenBefore and not NewDialogOrder.savedVars.ignore[optionType] then
			if NewDialogOrder.savedVars.keepConversation and isTalkContinue(optionType) then
				if newOrder[1] == nil then newOrder[1] = {} end
				table.insert(newOrder[1], i)
			elseif NewDialogOrder.savedVars.unreadToFront then
				if newOrder[numPriorities + 2] == nil then newOrder[numPriorities + 2] = {} end
				table.insert(newOrder[numPriorities + 2], i)
			end
		else
			if newOrder[numPriorities + 3] == nil then newOrder[numPriorities + 3] = {} end
			table.insert(newOrder[numPriorities + 3], i)
		end
	end
	
	--populate dialogue controls with newOrder values, skipping nil values
	local controlIndex = 1
	for i = 1, numPriorities + 3 do
		if newOrder[i] then
			for j = 1, #newOrder[i] do
				if newOrder[i][j] then
					populateControlWithNewData(controlIndex, optionsData, newOrder[i][j])
					controlIndex = controlIndex + 1
				end
			end
		end
	end
end

local function onAddOnLoaded(event, addonName)
	if addonName ~= name then return end
	EVENT_MANAGER:UnregisterForEvent(name, EVENT_ADD_ON_LOADED)
	
	--count the number of chatter options to prioritize
	numPriorities = 0
	for key, val in pairs(defaults.priorities) do
		numPriorities = numPriorities + 1
	end
	
	-- clean up saved vars
	if NewDialogOrderSavedVariables then
		local db = NewDialogOrderSavedVariables.Default[GetDisplayName()]
		if db then
			local charsExist = {}
			for i = 1, GetNumCharacters() do
				local name = GetCharacterInfo(i)
				name = zo_strformat(SI_UNIT_NAME, name)
				charsExist[name] = true
			end
			for charName, _ in pairs(db) do
				if charName ~= GetUnitName("player") and charName ~= "$AccountWide" and not charsExist[charName] then
					db[charName] = nil
				end
			end
		end
	end
	
	if LibAddonMenu2 then
		--get or create account-wide saved variables
		NewDialogOrder.savedVars = ZO_SavedVars:NewAccountWide("NewDialogOrderSavedVariables", 0.1, nil, defaults)
		--set to account-wide by default, if haven't been set yet (== nil)
		if NewDialogOrder.savedVars.useAccountWide == nil then
			NewDialogOrder.savedVars.useAccountWide = true
		--if already set to false, get or create character-wide with name change support
		elseif not NewDialogOrder.savedVars.useAccountWide then
			NewDialogOrder.savedVars = ZO_SavedVars:NewCharacterNameSettings("NewDialogOrderSavedVariables", 0.1, nil, defaults)
		end
		
		NewDialogOrderMenu.CreateSettingsMenu(numPriorities)
	end
	
	EVENT_MANAGER:RegisterForEvent(name, EVENT_CHATTER_BEGIN,
		function(eventCode, optionCount) setNewOrder(optionCount) end)
	EVENT_MANAGER:RegisterForEvent(name, EVENT_CONVERSATION_UPDATED,
		function(eventCode, bodyText, optionCount) setNewOrder(optionCount) end)
end

EVENT_MANAGER:RegisterForEvent(name, EVENT_ADD_ON_LOADED, onAddOnLoaded)

NewDialogOrder = {
	name = name,
	version = version,
	author = author,
}
