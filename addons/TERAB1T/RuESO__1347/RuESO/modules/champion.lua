function RuESO_doubleNamesChampion(RuESO)
	if RuESO:GetLanguage() == "ru" then
		local rsd = RuESO.Settings.Data
		
		local GetChampionSkillNameOld = GetChampionSkillName
	
		function GetChampionSkillName(...)
			local championSkillId = ...
			local abilityId = GetChampionAbilityId(championSkillId)
			local rusName = GetChampionSkillNameOld(...)
			
			if RuESO.Settings.ShowChampionTooltip == "ru" or not abilityId then
				return rusName
			end
			
			if not abilityId or not rsd.Abilities[abilityId] then
				return rusName
			end
			
			if RuESO.Settings.ShowChampionTooltip == "ruen" then
				return string.format("%s (%s)", rusName, rsd.Abilities[abilityId])
			elseif RuESO.Settings.ShowChampionTooltip == "enru" then
				return string.format("%s (%s)", rsd.Abilities[abilityId], rusName)
			else
				return RuESO.Settings.Data.Abilities[abilityId]
			end
		end
		
		-- Tooltips
		
		local function getIdFromSkillId(championSkillId)
			local abilityId = GetChampionAbilityId(championSkillId)
			local rusName = GetChampionSkillNameOld(championSkillId)
			
			return abilityId, rusName
		end
		
		local function getIdFromAbilityId(abilityId)
			local rusName = GetAbilityName(abilityId)
			
			return abilityId, rusName
		end
		
		local function modifyTooltip(abilityId, rusName)
			
			local finalName
			
			if RuESO.Settings.ShowChampionTooltip ~= "ru" and abilityId and rsd.Abilities[abilityId] and rusName then					
				if RuESO.Settings.ShowChampionTooltip == "ruen" then
					finalName = string.format("%s (%s)", rusName, rsd.Abilities[abilityId])
				elseif RuESO.Settings.ShowChampionTooltip == "enru" then
					finalName = string.format("%s (%s)", rsd.Abilities[abilityId], rusName)
				else
					finalName = rsd.Abilities[abilityId]
				end
				
				if finalName then
					SafeAddString(SI_ABILITY_TOOLTIP_NAME, finalName, 10)
				end
			end
		end
		
		local function abilityTooltipHook(tooltipControl, method, linkFunc)
			local origMethod = tooltipControl[method]
			tooltipControl[method] = function(self, ...)
				
				modifyTooltip(linkFunc(...))
				
				origMethod(self, ...)
				
				SafeAddString(SI_ABILITY_TOOLTIP_NAME, RuESO.StringsBackup["SI_ABILITY_TOOLTIP_NAME"], 10)
			end
		end
		
		abilityTooltipHook(ChampionSkillTooltip, "SetChampionSkill", getIdFromSkillId)
		abilityTooltipHook(ChampionSkillTooltip, "SetAbilityId", getIdFromAbilityId)
		ZO_PreHook(CHAMPION_PERKS, "LayoutRightTooltipChampionSkillAbility", function(tooltip, ...)   modifyTooltip(...) end)
		ZO_PostHook(CHAMPION_PERKS, "LayoutRightTooltipChampionSkillAbility", function() SafeAddString(SI_ABILITY_TOOLTIP_NAME, finalName, 10) end)
	end
	RuESO_doubleNamesChampion = nil
end