local savedVars
local worldEventInstanceNodeIndexes = {
    -- North Elsweyr
        [1] = 387, -- Hakoshae
        [2] = 397, -- Star Haven
        [3] = 386, -- Scar's End

    -- South Elsweyr
		["12a"] = 406, -- Pridehome
		["12b"] = 405, -- Black Heights
		[13] = 403, -- South Guard Ruins
}

local function IsInElsweyr()
	local zoneId = GetUnitWorldPosition("player")

	return zoneId == 1086 or zoneId == 1133
end

local function GetNextWorldEventInstanceIdIter(state, var1)
	return GetNextWorldEventInstanceId(var1)
end

local function GetNextNodeIndex(list, currentNodeIndex)
	for i, nodeId in ipairs(list) do
		if nodeId == currentNodeIndex then
			return list[ i + 1 ] or list[ 1 ]
		end
	end

	return list[ math.random( #list ) ]
end

local function OnFastTravelInteraction(_, currentNodeIndex)
	if not savedVars.enabled or not IsInElsweyr() then
		return
	end

	local nodeIds = {
		[MAP_PIN_TYPE_DRAGON_IDLE_HEALTHY] = {},
		[MAP_PIN_TYPE_DRAGON_IDLE_WEAK] = {},
		[MAP_PIN_TYPE_DRAGON_COMBAT_HEALTHY] = {},
		[MAP_PIN_TYPE_DRAGON_COMBAT_WEAK] = {},
	}

	for worldEventInstanceId in GetNextWorldEventInstanceIdIter do
		local unitTag = GetWorldEventInstanceUnitTag(worldEventInstanceId, 1)
		local pinType = GetWorldEventInstanceUnitPinType(worldEventInstanceId, unitTag)

		if worldEventInstanceId == 12 then
			local normalizedX, normalizedY = GetMapPlayerPosition(unitTag)

			if normalizedX > 0.35 or normalizedY < 0.35 then
				worldEventInstanceId = worldEventInstanceId .. "a"
			else
				worldEventInstanceId = worldEventInstanceId .. "b"
			end
		end

		local nodeId = worldEventInstanceNodeIndexes[worldEventInstanceId]

		table.insert(nodeIds[pinType], nodeId)
	end

	for pinType = MAP_PIN_TYPE_DRAGON_COMBAT_WEAK, MAP_PIN_TYPE_DRAGON_IDLE_HEALTHY, -1 do
		if #nodeIds[pinType] ~= 0 then
			local newNodeIndex = GetNextNodeIndex(nodeIds[pinType], currentNodeIndex)

			FastTravelToNode(newNodeIndex)
			return
		end
	end

	local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
	params:SetText(zo_iconTextFormat("/esoui/art/mappins/dragon_fly.dds", 64, 64, GetString(SI_DH_NO_ACTIVE)))
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end

local function OnAddOnLoaded(_, addOnName)
	if addOnName == "DragonHunter" then
		savedVars = ZO_SavedVars:New("DragonHunter", 1, nil, {enabled = false})

		-- listen for wayshrine interaction
		EVENT_MANAGER:RegisterForEvent("DragonHunter", EVENT_START_FAST_TRAVEL_INTERACTION, OnFastTravelInteraction)
	end
end

EVENT_MANAGER:RegisterForEvent("DragonHunter", EVENT_ADD_ON_LOADED, OnAddOnLoaded)

SLASH_COMMANDS[GetString(SI_DH_COM)] = function ()
	savedVars.enabled = not savedVars.enabled

	if savedVars.enabled then
		CHAT_ROUTER:AddSystemMessage(GetString(SI_DH_ENABLED))
	else
		CHAT_ROUTER:AddSystemMessage(GetString(SI_DH_DISABLED))
	end
end