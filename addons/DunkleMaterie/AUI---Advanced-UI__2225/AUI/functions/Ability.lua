AUI.Ability = {}


local abilityAssignment = {
	[46327] = 46324,     	-- Crystal Fragments Proc (Crystal Fragments)
	[62124] = 62124,		-- Assassin's Will (Grim Focus)
	[61930] = 61930,		-- Assassin's Will (Merciless Resolve)
	[62126] = 62126,		-- Assassin's Will (Relentless Focus)	
	[23903] = 23903,		-- Power Lash (Flame Lash)
	[62549] = 62549,		-- Deadly Throw (Deadly Cloak)
}

function AUI.Ability.IsProc(_abilityId)
	if abilityAssignment[_abilityId] then	
		return true
	end
	
	return false
end

function AUI.Ability.GetProcAssignment(_abilityId)
	return abilityAssignment[_abilityId]
end

function AUI.Ability.IsAbility(_slotId)
	return _slotId > ACTION_BAR_FIRST_NORMAL_SLOT_INDEX and _slotId < ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + ACTION_BAR_SLOTS_PER_PAGE
end