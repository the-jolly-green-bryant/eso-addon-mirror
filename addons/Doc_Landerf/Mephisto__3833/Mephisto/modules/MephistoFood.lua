Mephisto = Mephisto or {}
local MP = Mephisto

MP.food = {}
local MPF = MP.food
local MPQ = MP.queue

function MPF.Init()
	MPF.name = MP.name .. "Food"
	MPF.RegisterEvents()
end

function MPF.RegisterEvents()
	if MP.settings.eatBuffFood then
		EVENT_MANAGER:RegisterForEvent(MPF.name, EVENT_EFFECT_CHANGED, MPF.OnBuffFoodEnd)
		EVENT_MANAGER:AddFilterForEvent(MPF.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
	else
		EVENT_MANAGER:UnregisterForEvent(MPF.name, EVENT_EFFECT_CHANGED)
	end
end

function MPF.OnBuffFoodEnd(_, changeType, _, effectName, _, _, _, _, _, _, _, _, _, _, _, abilityId, _)
	if changeType ~= EFFECT_RESULT_FADED then return end
	if not IsUnitInDungeon("player") and not IsPlayerInRaid() then return end
	if WasRaidSuccessful() then return end
	if not MP.lookupBuffFood[abilityId] then return end
	if MP.HasFoodRunning() then return end
	
	local foodChoice = MP.lookupBuffFood[abilityId]
	local foodIndex = MP.FindFood(foodChoice)
	
	if not foodIndex then
		MP.Log(GetString(MP_MSG_NOFOOD), MP.LOGTYPES.ERROR)
		return
	end
	
	local foodLink = GetItemLink(BAG_BACKPACK, foodIndex, LINK_STYLE_DEFAULT)
	if IsUnitInCombat("player") then
		MP.Log(GetString(MP_MSG_FOOD_COMBAT), MP.LOGTYPES.INFO, nil, foodLink)
	else
		MP.Log(GetString(MP_MSG_FOOD_FADED), MP.LOGTYPES.NORMAL, nil, foodLink)
	end
	
	foodTask = function()
		if MP.HasFoodRunning() then return end
		CallSecureProtected("UseItem", BAG_BACKPACK, foodIndex)
		
		-- check if eaten 
		-- API cannot track sprinting
		zo_callLater(function()
			if not MP.HasFoodRunning() then
				MPQ.Push(foodTask)
			end
		end, 1000)
	end
	MPQ.Push(foodTask)
end