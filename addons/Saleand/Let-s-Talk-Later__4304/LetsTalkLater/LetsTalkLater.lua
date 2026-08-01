LetsTalkLater = LetsTalkLater or {}

local name = "LetsTalkLater"
local author = "vexaiv"
local version = "0.1.4"

local function moveToFront(origin, toMove)
	local result = {}
	local frontIndex = 1
	local regularIndex = #toMove + 1
	
	for i = 1, #origin do
		if origin[i] == toMove[frontIndex] then
			result[frontIndex] = origin[i]
			frontIndex = frontIndex + 1
		else
			result[regularIndex] = origin[i]
			regularIndex = regularIndex + 1
		end
	end
	
	return result
end

local function populateControlWithNewData(control, data, dataIndex)
	INTERACTION:PopulateChatterOption(
		control,
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

local function onChatterBegin(_, optionCount)
	local optionsData = {}
	local importantOptions = {}
	
	local origin = {} --for original indexes 1,2,3,4...
	local toMove = {} --for more important entries, e.g. 2,3
	
	for i = 1, optionCount do
		origin[i] = i
		
		--get data of the chatter option i
		local optionString, optionType, optionalArg, isImportant, chosenBefore, teleportNPCId, dialogueTone = GetChatterOption(i)
		local waypointIdTable = { GetChatterOptionWaypoints(i) }
		
		--save it
		table.insert(optionsData, {
			optionString = optionString,
			optionType = optionType,
			optionalArg = optionalArg,
			isImportant = isImportant,
			chosenBefore = chosenBefore,
			importantOptions = importantOptions,
			teleportNPCId = teleportNPCId,
			waypointIdTable = waypointIdTable,
			dialogueTone = dialogueTone,
		})
		
		--should it be moved?
		if optionType == CHATTER_START_SHOP
		or optionType == CHATTER_START_BANK
		or optionType == CHATTER_START_GUILDBANK
		or optionType == CHATTER_START_TRADINGHOUSE
		or optionType == CHATTER_START_BUY_BAG_SPACE
		or optionType == CHATTER_TALK_CHOICE_MONEY
		or optionType == CHATTER_START_NEW_QUEST_BESTOWAL
		or optionType == CHATTER_START_COMPLETE_QUEST
		or optionType == CHATTER_START_STABLE
		then
			table.insert(toMove, i)
		end
	end
	
	--get new options order
	local swapped = moveToFront(origin, toMove)
	
	--populate dialogue options with swapped data
	for i = 1, optionCount do
		populateControlWithNewData(i, optionsData, swapped[i])
	end
end

local function onAddOnLoaded(event, addonName)
	if addonName ~= name then return end
	EVENT_MANAGER:UnregisterForEvent(name, EVENT_ADD_ON_LOADED)
	
	EVENT_MANAGER:RegisterForEvent(name, EVENT_CHATTER_BEGIN, onChatterBegin)
end

EVENT_MANAGER:RegisterForEvent(name, EVENT_ADD_ON_LOADED, onAddOnLoaded)
