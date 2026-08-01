function RuESO_doubleNamesAbilities(RuESO)
	if RuESO:GetLanguage() == "ru" then
		local rsd = RuESO.Settings.Data
		
		-- Main Window
		local ZO_Skills_AbilityEntry_SetupOrg = ZO_Skills_AbilityEntry_Setup
		ZO_Skills_AbilityEntry_Setup = function(control, skillData)
			ZO_Skills_AbilityEntry_SetupOrg(control, skillData)
			
			local skillPointAllocator = skillData:GetPointAllocator()
			local skillProgressionData = skillPointAllocator:GetProgressionData()
			local currentAbilityId = skillProgressionData:GetAbilityId()
			
			if RuESO.Settings.ShowAbilitiesMenu == "en" then
				local finalName
				local rusName = GetAbilityName(currentAbilityId)
				local rusNameLower = ZO_CachedStrFormat("<<z:1>>", rusName)

				if rsd.CraftAbilities[rusNameLower] then
					finalName = rsd.CraftAbilities[rusNameLower]
				elseif rsd.Abilities[currentAbilityId] then
					finalName = rsd.Abilities[currentAbilityId]
				else
					finalName = rusName
				end

				control:GetNamedChild("Name"):SetText(RuESO:MagicReplace(control:GetNamedChild("Name"):GetText(), rusName, finalName))
			end
		end
		
		local ZO_Skills_CompanionSkillEntry_SetupOrg = ZO_Skills_CompanionSkillEntry_Setup
		ZO_Skills_CompanionSkillEntry_Setup = function(control, skillData)
			ZO_Skills_CompanionSkillEntry_SetupOrg(control, skillData)
			
			local skillPointAllocator = skillData:GetPointAllocator()
			local skillProgressionData = skillPointAllocator:GetProgressionData()
			local currentAbilityId = skillProgressionData:GetAbilityId()
			
			if rsd.Abilities[currentAbilityId] ~= nil and RuESO.Settings.ShowAbilitiesMenu == "en" then
				control:GetNamedChild("Name"):SetText(RuESO:MagicReplace(control:GetNamedChild("Name"):GetText(), GetAbilityName(currentAbilityId), rsd.Abilities[currentAbilityId]))
			end
		end

		ZO_SkillsConfirmDialog:SetHandler("OnShow", function()
			
			local skillProgressionData = ZO_SkillsConfirmDialog.data
			local currentAbilityId = skillProgressionData:GetAbilityId()
			
			if rsd.Abilities[currentAbilityId] and RuESO.Settings.ShowAbilitiesMenu == "en" then
				ZO_SkillsConfirmDialog:GetNamedChild("AbilityName"):SetText(RuESO:MagicReplace(ZO_SkillsConfirmDialog:GetNamedChild("AbilityName"):GetText(), GetAbilityName(currentAbilityId), rsd.Abilities[currentAbilityId]))
			end
		end)
		
		ZO_SkillsMorphDialog:SetHandler("OnShow", function()
			
			local bsAbility = ZO_SkillsMorphDialog:GetNamedChild("BaseAbility")
			local skillProgressionData = bsAbility.skillProgressionData
			local currentAbilityId = skillProgressionData:GetAbilityId()
			
			if rsd.Abilities[currentAbilityId] and RuESO.Settings.ShowAbilitiesMenu == "en" then
				ZO_SkillsMorphDialog.desc:SetText(zo_strformat(SI_SKILLS_SELECT_MORPH, rsd.Abilities[currentAbilityId]))
			end
		end)
		
		-- Advisor
		
		local AdvSetupAbilityEntryOrg = ZO_SKILLS_ADVISOR_SUGGESTION_WINDOW.SetupAbilityEntry
		ZO_SKILLS_ADVISOR_SUGGESTION_WINDOW.SetupAbilityEntry = function(manager, control, skillProgressionData)
			AdvSetupAbilityEntryOrg(manager, control, skillProgressionData)
			
			local skillData = skillProgressionData:GetSkillData()
			local currentAbilityId = skillProgressionData:GetAbilityId()
			
			if RuESO.Settings.Data.Abilities[currentAbilityId] ~= nil and RuESO.Settings.ShowAbilitiesMenu == "en" then
				control:GetNamedChild("Name"):SetText(RuESO:MagicReplace(control:GetNamedChild("Name"):GetText(), GetAbilityName(currentAbilityId), RuESO.Settings.Data.Abilities[currentAbilityId]))
			end
		end
		
		-- Tooltips
		
		local function modifyTooltip(isPassive, isNew, ...)
			local finalName, finalName2, rusName
			
			if RuESO.Settings.ShowAbilitiesTooltip ~= "ru" then
				if isPassive then
					local skillType, skillLineIndex, skillIndex, rank = ...
					local abilityId = GetSpecificSkillAbilityInfo(skillType, skillLineIndex, skillIndex, 0, rank)
					
					if abilityId and rsd.Abilities[abilityId] then
						rusName = GetAbilityName(abilityId)
						finalName = rsd.Abilities[abilityId]
					end
				elseif isNew then
					local skillType, skillLineIndex, skillIndex = ...
					local abilityId = GetSpecificSkillAbilityInfo(skillType, skillLineIndex, skillIndex, 0, 1)
					
					if abilityId and rsd.Abilities[abilityId] then
						rusName = GetAbilityName(abilityId)
						finalName = rsd.Abilities[abilityId]
					end
				else
					local skillType, skillLineIndex, skillIndex, morphChoice, _, _, _, _, _, _, _, _, _, overrideAbilityId = ...
					local abilityId = GetSpecificSkillAbilityInfo(skillType, skillLineIndex, skillIndex, morphChoice, 1)
					
					if overrideAbilityId and rsd.Abilities[overrideAbilityId] then
						finalName = rsd.Abilities[overrideAbilityId]
						rusName = GetAbilityName(overrideAbilityId)
					elseif overrideAbilityId and not rsd.Abilities[overrideAbilityId] then
						-- finalName2 = nmIcon .. rsd.Abilities[abilityId]
					elseif abilityId and rsd.Abilities[abilityId] then
						finalName = rsd.Abilities[abilityId]
						rusName = GetAbilityName(abilityId)
					end
				end
				
				if finalName and rusName then
					if RuESO.Settings.ShowAbilitiesTooltip == "ruen" then
						finalName = string.format("%s (%s)", rusName, finalName)
					elseif RuESO.Settings.ShowAbilitiesTooltip == "enru" then
						finalName = string.format("%s (%s)", finalName, rusName)
					end
					
					SafeAddString(SI_ABILITY_NAME_AND_RANK, GetString(SI_ABILITY_NAME_AND_RANK):gsub("<<1>>", finalName), 10)
					SafeAddString(SI_ABILITY_TOOLTIP_NAME, finalName, 10)
				end
			end
		end
		
		local function modifyTooltipCompanion(...)
			local finalName, rusName, rusNameLower
			
			if RuESO.Settings.ShowAbilitiesTooltip ~= "ru" then
				local abilityId = ...
				
				if abilityId then
					rusName = GetAbilityName(abilityId)
					rusNameLower = ZO_CachedStrFormat("<<z:1>>", rusName)

					if rsd.CraftAbilities[rusNameLower] then
						finalName = rsd.CraftAbilities[rusNameLower]
					elseif rsd.Abilities[abilityId] then
						finalName = rsd.Abilities[abilityId]
					end
				end
				
				if finalName and rusName then
					if RuESO.Settings.ShowAbilitiesTooltip == "ruen" then
						finalName = string.format("%s (%s)", rusName, finalName)
					elseif RuESO.Settings.ShowAbilitiesTooltip == "enru" then
						finalName = string.format("%s (%s)", finalName, rusName)
					end
					
					SafeAddString(SI_ABILITY_NAME_AND_RANK, GetString(SI_ABILITY_NAME_AND_RANK):gsub("<<1>>", finalName), 10)
					SafeAddString(SI_ABILITY_TOOLTIP_NAME, finalName, 10)
				end
			end
		end
		
		local function abilityTooltipHook(tooltipControl, method, isPassive, isNew, isCompanion)
			local origMethod = tooltipControl[method]
			tooltipControl[method] = function(self, ...)
				if isCompanion then
					modifyTooltipCompanion(...)
				else
					modifyTooltip(isPassive, isNew, ...)
				end
				
				origMethod(self, ...)
					
				SafeAddString(SI_ABILITY_NAME_AND_RANK, RuESO.StringsBackup["SI_ABILITY_NAME_AND_RANK"], 10)
				SafeAddString(SI_ABILITY_TOOLTIP_NAME, RuESO.StringsBackup["SI_ABILITY_TOOLTIP_NAME"], 10)
			end
		end
		
		abilityTooltipHook(SkillTooltip, "SetActiveSkill", false, false, false)
		abilityTooltipHook(SkillTooltip, "SetPassiveSkill", true, false, false)
		abilityTooltipHook(SkillTooltip, "SetSkillAbility", false, true, false)
		abilityTooltipHook(SkillTooltip, "SetCompanionSkill", false, false, true)
		abilityTooltipHook(SkillTooltip, "SetAbilityId", false, false, true)
		
		-- Эксперименты
		
		local oldFunction = ZO_SkillProgressionData_Base.GetName
		
		function ZO_SkillProgressionData_Base:GetName()
			if rsd.Abilities[self:GetAbilityId()] and IsInGamepadPreferredMode() then
				return rsd.Abilities[self:GetAbilityId()]
			else
				return oldFunction(self)
			end
		end
		
		local oldFunction4 = ZO_SkillProgressionData_Base.GetFormattedName
		
		function ZO_SkillProgressionData_Base:GetFormattedName(formatter)
			if rsd.Abilities[self:GetAbilityId()] and IsInGamepadPreferredMode() then
				return ZO_CachedStrFormat(formatter or SI_ABILITY_NAME, rsd.Abilities[self:GetAbilityId()])
			else
				return oldFunction(self)
			end
		end
		
		--[[ZO_PreHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP), "LayoutSkillProgression", function(tooltip, progressionData)
			local abilityId = progressionData:GetAbilityId()
			local rusName = GetAbilityName(abilityId)
			local finalName = rsd.Abilities[abilityId]
			
			d(abilityId, rusName, finalName)
			
			if finalName and rusName then
				if RuESO.Settings.ShowAbilitiesTooltip == "ruen" then
					finalName = string.format("%s (%s)", rusName, finalName)
				elseif RuESO.Settings.ShowAbilitiesTooltip == "enru" then
					finalName = string.format("%s (%s)", finalName, rusName)
				end
				
				SafeAddString(SI_ABILITY_NAME_AND_RANK, GetString(SI_ABILITY_NAME_AND_RANK):gsub("<<1>>", finalName), 10)
				SafeAddString(SI_ABILITY_TOOLTIP_NAME, finalName, 10)
			end
		end)
		
		ZO_PostHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP), "LayoutSkillProgression", function()
			SafeAddString(SI_ABILITY_NAME_AND_RANK, RuESO.StringsBackup["SI_ABILITY_NAME_AND_RANK"], 10)
			SafeAddString(SI_ABILITY_TOOLTIP_NAME, RuESO.StringsBackup["SI_ABILITY_TOOLTIP_NAME"], 10)
		end)]]
	end
	RuESO_doubleNamesAbilities = nil
end