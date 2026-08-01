if not GetFormattedAbilityName then
	GetFormattedAbilityName = function( abilityId )
		local name = GetAbilityName(abilityId)
		return(name ~= "" and LocalizeString("<<t:1>>", name) or string.format("[#%d]", abilityId))
	end
end
