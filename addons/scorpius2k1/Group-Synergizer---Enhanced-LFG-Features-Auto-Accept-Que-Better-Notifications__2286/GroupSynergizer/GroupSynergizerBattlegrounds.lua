function GROUP_SYNERGIZER.Battlegrounds()

	ZO_PreHookHandler(ZO_DungeonFinder_KeyboardListSection,'OnEffectivelyShown',function()
		--GROUP_SYNERGIZER.AutoAcceptCheckbox(not GROUP_SYNERGIZER.coolDownStatus[LFG_COOLDOWN_BATTLEGROUND_DESERTED])
	end)
	ZO_PreHookHandler(ZO_DungeonFinder_KeyboardListSection,'OnEffectivelyHidden',function()
		--GROUP_SYNERGIZER.AutoAcceptCheckbox(false)
	end)

end

function GROUP_SYNERGIZER.OnDeathFragmentStateChange(oldState, newState) -- AUTO RELEASE ON DEATH
	if GROUP_SYNERGIZER.Enable == false then return end

	if GROUP_SYNERGIZER.AutoRelease == true then
		if newState == SCENE_FRAGMENT_SHOWING then
			local _, _, _, _, _, _, isBattleGroundDeath = GetDeathInfo()
			if isBattleGroundDeath then
				Release()
			end
		end
	end
end

function GROUP_SYNERGIZER.OnBattlegroundStateChanged(eventCode, previousState, currentState) -- BATTLEGROUND STATES
	if GROUP_SYNERGIZER.Enable == false then return end

	if GROUP_SYNERGIZER.AutoRelease == true then
		local battlegroundId = GetCurrentBattlegroundId()
		if previousState == 0 then 
			--d('|c339FFB -Battleground: '..GetBattlegroundName(battlegroundId)..'-|r')
			PlaySound(SOUNDS.LOCKPICKING_BREAK)
		end
		if currentState == 1 then --joined
		end
		if currentState == 2 then --countdown started
		end
		if currentState == 3 then --started
		end
		if currentState == 4 then --ending
		end
	end
end
