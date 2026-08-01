Scholar_Helpers = {}

local NodeSkills = {
	[1] = {name = GetString(SI_ITEMFILTERTYPE13), abbr = GetString(SCHOLAR_ABBR_BLACKSMITHING)},
	[2] = {name = GetString(SI_ITEMFILTERTYPE14), abbr = GetString(SCHOLAR_ABBR_CLOTHING)},
	[3] = {name = GetString(SI_ITEMFILTERTYPE15), abbr = GetString(SCHOLAR_ABBR_WOODWORKING)},
	[4] = {name = GetString(SI_ITEMFILTERTYPE24), abbr = GetString(SCHOLAR_ABBR_JEWELCRAFTING)},
	[5] = {name = GetString(SI_ITEMTRAITTYPE1), abbr = GetString(SCHOLAR_ABBR_POWERED)},
	[6] = {name = GetString(SI_ITEMTRAITTYPE2), abbr = GetString(SCHOLAR_ABBR_CHARGED)},
	[7] = {name = GetString(SI_ITEMTRAITTYPE3), abbr = GetString(SCHOLAR_ABBR_PRECISE)},
	[8] = {name = GetString(SI_ITEMTRAITTYPE4), abbr = GetString(SCHOLAR_ABBR_INFUSED)},
	[9] = {name = GetString(SI_ITEMTRAITTYPE5), abbr = GetString(SCHOLAR_ABBR_DEFENDING)},
	[10] = {name = GetString(SI_ITEMTRAITTYPE6), abbr = GetString(SCHOLAR_ABBR_TRAINING)},
	[11] = {name = GetString(SI_ITEMTRAITTYPE7), abbr = GetString(SCHOLAR_ABBR_SHARPENED)},
	[12] = {name = GetString(SI_ITEMTRAITTYPE8), abbr = GetString(SCHOLAR_ABBR_DECISIVE)},
	[13] = {name = GetString(SI_ITEMTRAITTYPE11), abbr = GetString(SCHOLAR_ABBR_STURDY)},
	[14] = {name = GetString(SI_ITEMTRAITTYPE12), abbr = GetString(SCHOLAR_ABBR_IMPENETRABLE)},
	[15] = {name = GetString(SI_ITEMTRAITTYPE13), abbr = GetString(SCHOLAR_ABBR_REINFORCED)},
	[16] = {name = GetString(SI_ITEMTRAITTYPE14), abbr = GetString(SCHOLAR_ABBR_WELLFITTED)},
	[17] = {name = GetString(SI_ITEMTRAITTYPE15), abbr = GetString(SCHOLAR_ABBR_TRAINING)},
	[18] = {name = GetString(SI_ITEMTRAITTYPE16), abbr = GetString(SCHOLAR_ABBR_INFUSED)},
	[19] = {name = GetString(SI_ITEMTRAITTYPE17), abbr = GetString(SCHOLAR_ABBR_PROSPEROUS)},
	[20] = {name = GetString(SI_ITEMTRAITTYPE18), abbr = GetString(SCHOLAR_ABBR_DIVINES)},
	[21] = {name = GetString(SI_ITEMTRAITTYPE21), abbr = GetString(SCHOLAR_ABBR_HEALTHY)},
	[22] = {name = GetString(SI_ITEMTRAITTYPE22), abbr = GetString(SCHOLAR_ABBR_ARCANE)},
	[23] = {name = GetString(SI_ITEMTRAITTYPE23), abbr = GetString(SCHOLAR_ABBR_ROBUST)},
	[24] = {name = GetString(SI_ITEMTRAITTYPE25), abbr = GetString(SCHOLAR_ABBR_NIRNHONED)},
	[25] = {name = GetString(SI_ITEMTRAITTYPE26), abbr = GetString(SCHOLAR_ABBR_NIRNHONED)},
	[26] = {name = GetString(SI_ITEMTRAITTYPE28), abbr = GetString(SCHOLAR_ABBR_SWIFT)},
	[27] = {name = GetString(SI_ITEMTRAITTYPE29), abbr = GetString(SCHOLAR_ABBR_HARMONY)},
	[28] = {name = GetString(SI_ITEMTRAITTYPE30), abbr = GetString(SCHOLAR_ABBR_TRIUNE)},
	[29] = {name = GetString(SI_ITEMTRAITTYPE31), abbr = GetString(SCHOLAR_ABBR_BLOODTHIRSTY)},
	[30] = {name = GetString(SI_ITEMTRAITTYPE32), abbr = GetString(SCHOLAR_ABBR_PROTECTIVE)},
	[31] = {name = GetString(SI_RIDINGTRAINTYPE1), abbr = GetString(SCHOLAR_ABBR_SPEED)},
	[32] = {name = GetString(SI_RIDINGTRAINTYPE2), abbr = GetString(SCHOLAR_ABBR_CAPACITY)},
	[33] = {name = GetString(SI_RIDINGTRAINTYPE3), abbr = GetString(SCHOLAR_ABBR_STAMINA)},
	[34] = {name = GetString(SCHOLAR_STABLE_TIMER_UNKNOWN), abbr = GetString(SCHOLAR_ABBR_UNKNOWN)}
}

function Scholar_Helpers:AbbrSkill(skill)
	local abbr = ""

	for k,v in ipairs(NodeSkills) do
		if v.name == skill then
			abbr = v.abbr
		end
	end

	return abbr
end

function Scholar_Helpers:GetSkill(craftingSkillType, researchLineIndex, traitIndex)
	local skillName = ""
	local traitName = ""

	if craftingSkillType == "riding" then
		local inv, _, sta, _, spd, _ = GetRidingStats()

		skillName = GetString(SCHOLAR_TRAIN_RIDING_SKILL)

		if Scholar_Timers.parent.savedVariables.timers.riding then
			if inv > Scholar_Timers.parent.savedVariables.timers.riding.inv then
				traitName = GetString(SCHOLAR_STABLE_TIMER_INVENTORY)
			elseif sta > Scholar_Timers.parent.savedVariables.timers.riding.sta then
				traitName = GetString(SCHOLAR_STABLE_TIMER_STAMINA)
			elseif spd > Scholar_Timers.parent.savedVariables.timers.riding.spd then
				traitName = GetString(SCHOLAR_STABLE_TIMER_SPEED)
			else
				-- This should never happen. It's really only here for my testing
				traitName = GetString(SCHOLAR_STABLE_TIMER_UNKNOWN)
			end
		else
			-- This triggers if a user updates from a pre-1.2.0 version and has an active stable timer
			traitName = GetString(SCHOLAR_STABLE_TIMER_UNKNOWN)
		end

		if Scholar_Timers.parent.savedVariables.timers.useAbbr then
			skillName = GetString(SCHOLAR_ABBR_RIDING)
			traitName = Scholar_Helpers:AbbrSkill(traitName)
		end
	else
		local name = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)

		skillName = GetSkillLineInfo(GetCraftingSkillLineIndices(craftingSkillType))
		traitName = GetString("SI_ITEMTRAITTYPE", GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex))

		if Scholar_Timers.parent.savedVariables.timers.useAbbr then
			skillName = Scholar_Helpers:AbbrSkill(skillName);
			traitName = Scholar_Helpers:AbbrSkill(traitName);
		end
	end

	return skillName, traitName
end
