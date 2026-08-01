
function PrintSkillVariants()

	-- Each skill category
	for category = SKILL_TYPE_ITERATION_BEGIN, SKILL_TYPE_ITERATION_END do

	-- Each skill line.
	for line = 1, GetNumSkillLines(category) do
		local lineName = GetSkillLineNameById(GetSkillLineId(category, line))

	-- Each skill.
	for skill = 1, GetNumSkillAbilities(category, line) do
		local progression = GetProgressionSkillProgressionId(category, line, skill)
		
	-- Each skill morph.
	for morph = MORPH_SLOT_ITERATION_BEGIN, MORPH_SLOT_ITERATION_END do
		local ability  = GetProgressionSkillMorphSlotAbilityId(progression, morph)
		local variants = {GetProgressionSkillMorphSlotChainedAbilityIds(progression, morph)}

	-- Each variant.
	for _, variant in ipairs(variants) do
		local abilityName = GetAbilityName(ability)
		local variantName = GetAbilityName(variant)

		df("|cBD80FF%s|r / (%d) |c27BEF5%s|r / (%d) |c27BEF5%s|r",
			lineName, ability, abilityName, variant, variantName)
		
	end end end end end
end


function GetSkillIdFromAbilityId(abilityId)
	if not abilityId then return end

	local craftedId = GetAbilityCraftedAbilityId(abilityId)
	if craftedId > 0 then return abilityId end

	local craftedId = GetAbilityIdForCraftedAbilityId(abilityId)
	if craftedId > 0 then return craftedId end

	local _, progression = GetAbilityProgressionXPInfoFromAbilityId(abilityId)
	return GetSkillAbilityId(GetSkillAbilityIndicesFromProgressionIndex(progression))
end
