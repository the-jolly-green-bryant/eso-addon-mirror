function RANDOMOTE.Initialize()
	RANDOMOTE.InitializeEmoteData()

	RANDOMOTE.savedVariables	= ZO_SavedVars:NewAccountWide("RandoMoteSavedVars", RANDOMOTE.variableVersion, nil, RANDOMOTE.defaults, GetWorldName())
	RANDOMOTE.enable 			= RANDOMOTE.savedVariables.enable
	RANDOMOTE.useStandard		= RANDOMOTE.savedVariables.useStandard
	RANDOMOTE.useCollectible	= RANDOMOTE.savedVariables.useCollectible
	RANDOMOTE.chatOutput		= RANDOMOTE.savedVariables.chatOutput	
	RANDOMOTE.idleMax 			= RANDOMOTE.savedVariables.idleMax
	RANDOMOTE.minTime 			= RANDOMOTE.savedVariables.minTime
	RANDOMOTE.maxTime 			= RANDOMOTE.savedVariables.maxTime
	RANDOMOTE.useEmote			= RANDOMOTE.savedVariables.useEmote

	RANDOMOTE.CreateSettingsWindow()
end

function RANDOMOTE.InitializeEmoteData()
	local count = 0

	for i = 1, GetNumEmotes() do
		if RANDOMOTE.isValid(i) then
			local slashName, categoryId, id, displayName = GetEmoteInfo(i)
			RANDOMOTE.emoteData[count] = {
				index = i,
				id = id,
				slash = slashName,
				display = displayName
			}
			RANDOMOTE.defaults.useEmote[slashName:sub(2)] = true
			count = count + 1
		end
	end

	table.sort(RANDOMOTE.emoteData, function (a, b) return a.display < b.display end)
end

function RANDOMOTE.Loop()
	local function isTimeForEmote()
		if 	not RANDOMOTE.enable or
			not string.find(SCENE_MANAGER:GetCurrentSceneName(), "hud") or -- Interacting, Menus, etc?
			IsPlayerMoving() or -- Moving?
			IsBlockActive() or -- Blocking?
			IsMounted() or -- Mounted?
			IsUnitInCombat("player") or -- In Combat?
			IsUnitInDungeon("player") or -- In Dungeon?
			IsUnitSwimming("player") or	-- Swimming?		
			IsUnitDeadOrReincarnating("player") or -- Not Alive or Rez?
			GetUnitStealthState("player") ~= STEALTH_STATE_NONE or -- Crouching?
			not ArePlayerWeaponsSheathed() -- Weapon Out?
			then return false end
		return true
	end
	
	if isTimeForEmote() then
		if RANDOMOTE.idleCount >= RANDOMOTE.idleMax then
			if RANDOMOTE.delayCount >= RANDOMOTE.delayMax then
				RANDOMOTE.playRandomEmote()
			else
				RANDOMOTE.delayCount = RANDOMOTE.delayCount + 1
			end
		else
			RANDOMOTE.idleCount = RANDOMOTE.idleCount + 1
		end
	else
		RANDOMOTE.ResetData()
	end

	--d("Idle: "..RANDOMOTE.idleCount.."/"..RANDOMOTE.idleMax.." Emote: "..RANDOMOTE.delayCount.."/"..RANDOMOTE.delayMax)

	zo_callLater(function() RANDOMOTE.Loop() end, 1000)
end

function RANDOMOTE.playRandomEmote()
	math.randomseed(math.random(10000, 99999))

	local emoteList = {}
	local count = 0
	
	for k, v in ipairs(RANDOMOTE.emoteData) do
		if v ~= nil and RANDOMOTE.isValid(RANDOMOTE.emoteData[k].index) and RANDOMOTE.useEmote[RANDOMOTE.emoteData[k].slash:sub(2)] == true then
			emoteList[count] = RANDOMOTE.emoteData[k]
			count = count + 1
		end
	end

	if count > 0 then
		local randomindex = math.random(0, #emoteList)
		local index = emoteList[randomindex]["index"]
		local slash = emoteList[randomindex]["slash"]
		local display = emoteList[randomindex]["display"]
		local delay = math.floor(math.random(RANDOMOTE.minTime, RANDOMOTE.maxTime) + 0.5)
		local count = #emoteList + 1
		
		if index ~= nil then
			PlayEmoteByIndex(index)
			RANDOMOTE.delayCount = 0
			RANDOMOTE.delayMax = delay
			if RANDOMOTE.chatOutput then d("|cb7ff00"..display.."|r |cffffff"..slash.."|r Next In "..delay.."s ("..count.." available)") end -- d("|cb7ff00"..slash.." Next In "..delay.."s ("..count.." available)") end
		end
	else
		d("|cb7ff00"..RANDOMOTE.name.."|r |cffffffNo Emotes Available To Use!")
	end
end

function RANDOMOTE.isValid(index)
	local valid = false
	local collectibleId = GetEmoteCollectibleId(index)
	if
		not collectibleId and RANDOMOTE.useStandard or
		IsCollectibleUnlocked(collectibleId) and RANDOMOTE.useCollectible
		then return true
	end
	return false
end

function RANDOMOTE.GetTotalEmotes()
	local count = 0
	for k, v in ipairs(RANDOMOTE.emoteData) do
		if v ~= nil then
			count = count + 1
		end
	end	
	return count
end

--[[ Does not print entire list even though table is fine, ZOS chat window output limitation?
function RANDOMOTE.DisplayEmoteInfo()
	for k, v in ipairs(RANDOMOTE.emoteData) do
		if v ~= nil then
			d(k..". |cb7ff00"..RANDOMOTE.emoteData[k].display.."|r |cffffff"..RANDOMOTE.emoteData[k].slash.."|r")
		end
	end
end
]]

function RANDOMOTE.ConvertChannelRGBToHex(ChatChannelCategory)
	local r, g, b = GetChatCategoryColor(ChatChannelCategory)
	return string.format("%.2x%.2x%.2x", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
end

function RANDOMOTE.ResetData()
	RANDOMOTE.idleCount = 0
	RANDOMOTE.delayCount = 0
	RANDOMOTE.delayMax = 0
end

