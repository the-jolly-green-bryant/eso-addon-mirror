-- Functions related to detection if Echoing Vigor is slotted
EchoingVigorTracker.tauntSkills	= {
    [61505]  = "Echoing Vigor", -- Echoing Vigor
}

function EchoingVigorTracker.IsAbilityEchoingVigor(abilityId)
    if EchoingVigorTracker.tauntSkills[abilityId]==nil then
        return false
    else
        return true
    end
end

function EchoingVigorTracker.isEchoingVigorSkillSlotted()
	for hotbarSlot = 3, 7 do -- skill 1,2,3,4,5 (not ults or light attack or heavy attack)
		if EchoingVigorTracker.IsAbilityEchoingVigor(GetSlotBoundId(hotbarSlot, HOTBAR_CATEGORY_PRIMARY)) then
			return true
		end
		if EchoingVigorTracker.IsAbilityEchoingVigor(GetSlotBoundId(hotbarSlot, HOTBAR_CATEGORY_BACKUP)) then
			return true
		end
	end
	return false
end


