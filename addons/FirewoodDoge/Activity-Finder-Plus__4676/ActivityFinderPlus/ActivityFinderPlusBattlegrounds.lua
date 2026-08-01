local ACTIVITY_FINDER_PLUS = ACTIVITY_FINDER_PLUS

function ACTIVITY_FINDER_PLUS.OnDeathFragmentStateChange(_, newState)
    if not ACTIVITY_FINDER_PLUS.AutoRelease or newState ~= SCENE_FRAGMENT_SHOWING then return end

    local _, _, _, _, _, _, isBattleGroundDeath = GetDeathInfo()
    if isBattleGroundDeath then
        Release()
    end
end

function ACTIVITY_FINDER_PLUS.OnBattlegroundStateChanged(_, previousState, currentState)
    if not ACTIVITY_FINDER_PLUS.AutoRelease then return end

    if previousState == 0 and currentState ~= 0 then
        PlaySound(SOUNDS.LOCKPICKING_BREAK)
    end
end
