-----------------------------------------------------------
-- Author: SpringPeace2575 | Version: 0.9.0
-- Player for RandoMote add-on
-----------------------------------------------------------

RandoMotePlayer = RandoMotePlayer or {}
local RMPlayer = RandoMotePlayer
local RMEmotes = RandoMoteEmotes

RMPlayer.sv = {
	enable = true,
    useFavouriteOnly = false,
    chatOutput = false,
    idleMax = 15,
    minTime = 10,
    maxTime = 30,
}

RMPlayer.state = {
    idleCount = 0,
    delayCount = 0,
    delayMax = 0,
    normalEmoteList = {},
    favEmoteList = {},
}

function RMPlayer.Initialize(sv, state)
	RMPlayer.sv = sv
	RMPlayer.state = state

	RMPlayer.EnsureSavedVariables()
    RMPlayer.EnsureState()
end

function RMPlayer.EnsureSavedVariables()
	if type(RMPlayer.sv.enable) ~= "boolean" then RMPlayer.sv.enable = true end
	if type(RMPlayer.sv.useFavouriteOnly) ~= "boolean" then RMPlayer.sv.useFavouriteOnly = false end
	if type(RMPlayer.sv.chatOutput) ~= "boolean" then RMPlayer.sv.chatOutput = false end
	if type(RMPlayer.sv.idleMax) ~= "number" then RMPlayer.sv.idleMax = 15 end
	if type(RMPlayer.sv.minTime) ~= "number" then RMPlayer.sv.minTime = 10 end
	if type(RMPlayer.sv.maxTime) ~= "number" then RMPlayer.sv.maxTime = 30 end
end

function RMPlayer.EnsureState()
	RMPlayer.state.idleCount = RMPlayer.state.idleCount or 0
	RMPlayer.state.delayCount = RMPlayer.state.delayCount or 0
	RMPlayer.state.delayMax = RMPlayer.state.delayMax or 0
	RMPlayer.state.normalEmoteList = RMPlayer.state.normalEmoteList or {}
	RMPlayer.state.favEmoteList = RMPlayer.state.favEmoteList or {}
end

function RMPlayer.Loop()
	local canPlay, reason = RMPlayer.CanPlayEmoteNow()
	
	if canPlay then
		if RMPlayer.state.idleCount >= RMPlayer.sv.idleMax then
			if RMPlayer.state.delayCount >= RMPlayer.state.delayMax then
				RMPlayer.PlayRandomEmote()
			else
				RMPlayer.state.delayCount = RMPlayer.state.delayCount + 1
			end
		else
			RMPlayer.state.idleCount = RMPlayer.state.idleCount + 1
		end
	else
		RMPlayer.ResetTimer()
	end

	--d("Idle: "..RMPlayer.state.idleCount.."/"..RMPlayer.sv.idleMax.." Emote: "..RMPlayer.state.delayCount.."/"..RMPlayer.state.delayMax)

	zo_callLater(function() RMPlayer.Loop() end, 1000)
end

function RMPlayer.ResetTimer()
	RMPlayer.state.idleCount = 0
	RMPlayer.state.delayCount = 0
	RMPlayer.state.delayMax = 0
end

function RMPlayer.PlayRandomEmote()
	RMEmotes.RebuildEmoteLists()
	local favList = RMPlayer.state.favEmoteList
	local normalList = RMPlayer.state.normalEmoteList
	local favChosen = false

	local pool = {}
	if RMPlayer.sv.useFavouriteOnly then
		pool = favList
	else
		-- Prefer favourites 70/30 when available
		if #favList > 0 and (#normalList == 0 or math.random() < 0.70) then
			pool = favList
			favChosen = true
		else
			pool = normalList
		end
	end

	if pool and #pool > 0 then
		local chosen = pool[math.random(1, #pool)]
		local delay = math.floor(math.random(RMPlayer.sv.minTime, RMPlayer.sv.maxTime) + 0.5)

		-- Try play; if blocked, print reason + prefill chat
		local canPlay, reason = RMPlayer.CanPlayEmoteNow()
		if not canPlay then
			d(reason)
			-- RM.SafeStartChatInput(chosen.slash)
			return
		end

		PlayEmoteByIndex(chosen.index)

		RMPlayer.state.delayCount = 0
		RMPlayer.state.delayMax = delay

		if RMPlayer.sv.chatOutput then
			local favMark = favChosen and " [FAV]" or ""
			d("|cb7ff00"..chosen.display.."|r |cffffff"..chosen.slash.."|r [EMOTE]"..favMark.." Next In "..delay.."s ("..tostring(#pool).." pool)")
		end
	else
		d("|cb7ff00".."RandoMote".."|r |cffffffNo Emotes Available To Use!")
	end
end

function RMPlayer.PlayRandomEmoteNow()
    RMPlayer.ResetTimer()
    SCENE_MANAGER:ShowBaseScene()
    RMPlayer.PlayRandomEmote()
end

function RMPlayer.PlayEmoteNow(emote)
	SCENE_MANAGER:ShowBaseScene()
	zo_callLater(function()
		local canPlay, reason = RMPlayer.CanPlayEmoteNow()
		if not canPlay then
			d(reason)
			-- RM.SafeStartChatInput(emote.slash)
			return
		end
		PlayEmoteByIndex(emote.index)
	end, 200)
end

function RMPlayer.IsPlayEmotePossible()
	if IsUnitDeadOrReincarnating("player") then return false, "RandoMote: cannot play emote while dead/reincarnating" end
	if IsUnitInCombat("player") then return false, "RandoMote: cannot play emote while in combat" end
	-- if IsUnitInDungeon("player") then return false, "RandoMote: cannot play emote while in dungeon" end
	if IsMounted() then return false, "RandoMote: cannot play emote while mounted" end
	if IsUnitSwimming("player") then return false, "RandoMote: cannot play emote while swimming" end
	if IsPlayerMoving() then return false, "RandoMote: cannot play emote while moving" end
	if IsBlockActive() then return false, "RandoMote: cannot play emote while blocking" end
	if IsPlayerInteractingWithObject() then return false, "RandoMote: cannot play emote while interacting" end
	if GetUnitStealthState("player") ~= STEALTH_STATE_NONE then return false, "RandoMote: cannot play emote while sneaking" end
	if not ArePlayerWeaponsSheathed() then return false, "RandoMote: cannot play emote while weapon is out" end

	-- Scene check: many non-HUD scenes block emotes (menus, crafting, etc.)
	local sceneName = SCENE_MANAGER and SCENE_MANAGER:GetCurrentSceneName()
	if sceneName and not string.find(sceneName, "hud") then
		return false, "RandoMote: cannot play emote in current scene (" .. tostring(sceneName) .. ")"
	end

	return true, nil
end

function RMPlayer.CanPlayEmoteNow()
	if not RMPlayer.sv.enable then return false, "RandoMote: disabled" end
	
	return RMPlayer.IsPlayEmotePossible()
end
