
local ART = {
	AddonName        = "AutoRidingTraining",
	Author           = "Myzael",
	VariablesVersion = 1,
	Defaults         = {
		Order = {
			[1] = RIDING_TRAIN_SPEED,
			[2] = RIDING_TRAIN_CARRYING_CAPACITY,
			[3] = RIDING_TRAIN_STAMINA,
		},
		PerCharacter = false,
	},
	SavedVariables = nil,
	Mapping = {
		[RIDING_TRAIN_SPEED] = "speed",
		[RIDING_TRAIN_CARRYING_CAPACITY] = "capacity",
		[RIDING_TRAIN_STAMINA] = "stamina",
		speed = RIDING_TRAIN_SPEED,
		capacity = RIDING_TRAIN_CARRYING_CAPACITY,
		stamina = RIDING_TRAIN_STAMINA,
	},
}

function ART.OnAddOnLoaded(eventCode, name)
	if name ~= ART.AddonName then
		return
	end
	ART.SavedVariables = ZO_SavedVars:NewAccountWide("AutoRidingTrainingVars", ART.VariablesVersion, nil, ART.Defaults)
	ART.SavedVariablesChar = ZO_SavedVars:New("AutoRidingTrainingVars", ART.VariablesVersion, nil, ART.Defaults)
	EVENT_MANAGER:UnregisterForEvent(ART.AddonName, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent(ART.AddonName, EVENT_PLAYER_ACTIVATED, ART.Initialize)
end

function ART.Initialize()
	EVENT_MANAGER:UnregisterForEvent(ART.AddonName, EVENT_PLAYER_ACTIVATED)
	EVENT_MANAGER:RegisterForEvent(ART.AddonName, EVENT_CHATTER_BEGIN, ART.OnChatterBegin)
end

function ART.OnChatterBegin(eventCode, optionCount)
	local unitCaption = GetUnitCaption('interact')
	if unitCaption and string.find(unitCaption:lower(), GetString(ART_STABLE_MASTER_CAPTION):lower()) then
		EVENT_MANAGER:RegisterForEvent(ART.AddonName, EVENT_STABLE_INTERACT_START, ART.OnStableInteractStart)
		SelectChatterOption(1)
	end
end

function ART.OnStableInteractStart(eventCode)
	EVENT_MANAGER:UnregisterForEvent(ART.AddonName, EVENT_STABLE_INTERACT_START)

	local inventoryBonus, maxInventoryBonus, staminaBonus, maxStaminaBonus, speedBonus, maxSpeedBonus = GetRidingStats()
	local statsMapped = {
		[RIDING_TRAIN_SPEED] = {speedBonus, maxSpeedBonus},
		[RIDING_TRAIN_CARRYING_CAPACITY] = {inventoryBonus, maxInventoryBonus},
		[RIDING_TRAIN_STAMINA] = {staminaBonus, maxStaminaBonus},
	}
	local order = ART.SavedVariablesChar.PerCharacter and ART.SavedVariablesChar.Order or ART.SavedVariables.Order
	for index, skillToTrain in pairs(order) do
		local stats = statsMapped[skillToTrain]
		if stats[1] < stats[2] then
			EVENT_MANAGER:RegisterForEvent(ART.AddonName, EVENT_RIDING_SKILL_IMPROVEMENT, ART.OnRidingSkillImprovement)
			TrainRiding(skillToTrain)
		end
	end
end

-- number
-- RidingTrainType
-- number
-- number
-- RidingTrainSource
function ART.OnRidingSkillImprovement(eventCode, ridingSkillType, previous, current, source)
	EVENT_MANAGER:UnregisterForEvent(ART.AddonName, EVENT_RIDING_SKILL_IMPROVEMENT)
	ZO_SharedInteraction:CloseChatterAndDismissAssistant()
	SCENE_MANAGER:Show('hud')
end

EVENT_MANAGER:RegisterForEvent(ART.AddonName, EVENT_ADD_ON_LOADED, ART.OnAddOnLoaded)

function string:split(delimiter)
	local result = {}
	local from = 1
	local delim_from, delim_to = string.find(self, delimiter, from)
	while delim_from do
		table.insert(result, string.sub(self, from, delim_from - 1))
		from = delim_to + 1
		delim_from, delim_to = string.find(self, delimiter, from)
	end
	table.insert(result, string.sub(self, from))
	return result
end

SLASH_COMMANDS["/art"] = function(command)
	if not command or command == "" then
		CHAT_SYSTEM:AddMessage("Current riding skill order:")
		local order = ART.SavedVariablesChar.PerCharacter and ART.SavedVariablesChar.Order or ART.SavedVariables.Order
		for index, skillType in pairs(order) do
			CHAT_SYSTEM:AddMessage(tostring(index)..". "..ART.Mapping[skillType])
		end
		if ART.SavedVariablesChar.PerCharacter then
			CHAT_SYSTEM:AddMessage("Using character settings.")
		else
			CHAT_SYSTEM:AddMessage("Using account settings.")
		end
		CHAT_SYSTEM:AddMessage("Enter `/art use character settings` or `/art use account settings` to switch between modes.")
		CHAT_SYSTEM:AddMessage("For changing the order enter `/art set order speed,stamina,capacity`, it will save it for the currently active mode.")
		return
	end
	local options = command:split(" ")
	if #options == 3 and options[1] == "use" and options[3] == "settings" then
		if options[2] == "character" then
			ART.SavedVariablesChar.PerCharacter = true
			CHAT_SYSTEM:AddMessage("Switched to character settings")
		elseif options[2] == "account" then
			ART.SavedVariablesChar.PerCharacter = false
			CHAT_SYSTEM:AddMessage("Switched to account settings")
		else
			CHAT_SYSTEM:AddMessage("Invalid input '"..options[2].."'. Try 'character' or 'account'.")
		end
	elseif #options == 3 and options[1] == "set" and options[2] == "order" then
		newOrder = options[3]:split(",")
		if #newOrder ~= 3 then
			CHAT_SYSTEM:AddMessage("Invalid order. Need exactly 3 elements in the order argument.")
			return
		end
		speed = 0
		capacity = 0
		stamina = 0
		for _, v in pairs(newOrder) do
			if v == "stamina" then
				stamina = stamina + 1
			elseif v == "speed" then
				speed = speed + 1
			elseif v == "capacity" then
				capacity = capacity + 1
			else
				CHAT_SYSTEM:AddMessage("Invalid order name '"..v.."'. Use either 'stamina', 'speed' or 'capacity'.")
				return
			end
		end
		if speed ~= 1 or stamina ~= 1 or capacity ~=1 then
			CHAT_SYSTEM:AddMessage("Order must contain every type exactly once.")
			return
		end
		if ART.SavedVariablesChar.PerCharacter then
			ART.SavedVariablesChar.Order[1] = ART.Mapping[newOrder[1]]
			ART.SavedVariablesChar.Order[2] = ART.Mapping[newOrder[2]]
			ART.SavedVariablesChar.Order[3] = ART.Mapping[newOrder[3]]
			CHAT_SYSTEM:AddMessage("Saved new order into character settings")
		else
			ART.SavedVariables.Order[1] = ART.Mapping[newOrder[1]]
			ART.SavedVariables.Order[2] = ART.Mapping[newOrder[2]]
			ART.SavedVariables.Order[3] = ART.Mapping[newOrder[3]]
			CHAT_SYSTEM:AddMessage("Saved new order into account settings")
		end
	end
end
