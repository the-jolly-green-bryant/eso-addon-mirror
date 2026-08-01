function DovahMova_doubleNamesChampion(DovahMova)
	if DovahMova:GetLanguage() == "ua" then
		local rsd = DovahMova.Settings.Data
		
		local GetChampionSkillNameOld = GetChampionSkillName
		
		function GetChampionSkillName(...)
			local championSkillId = ...
			local abilityId = GetChampionAbilityId(championSkillId)
			local ukrName = GetChampionSkillNameOld(...)
			
			-- Захист від nil
			if not ukrName then
				return ""
			end
			
			if DovahMova.Settings.ShowChampionTooltip == "ua" or not abilityId then
				return ukrName
			end
			
			if not abilityId or not rsd.Abilities[abilityId] then
				return ukrName
			end
			
			if DovahMova.Settings.ShowChampionTooltip == "uaen" then
				return string.format("%s (%s)", ukrName, rsd.Abilities[abilityId])
			else
				return DovahMova.Settings.Data.Abilities[abilityId] or ukrName
			end
		end
		
	-- Tooltips
	
	local function getIdFromSkillId(championSkillId)
		local abilityId = GetChampionAbilityId(championSkillId)
		local ukrName = GetChampionSkillNameOld(championSkillId)
		
		return abilityId, ukrName
	end
	
	local function getIdFromAbilityId(abilityId)
		local ukrName = GetAbilityName(abilityId)
		
		return abilityId, ukrName
	end
	
	local function modifyTooltip(abilityId, ukrName)
		
		local finalName
		
		if DovahMova.Settings.ShowChampionTooltip ~= "ua" and abilityId and rsd.Abilities[abilityId] and ukrName then
			-- Check if the name already has a postfix to prevent duplication
			-- This happens when itemsDisplay.lua has already formatted the name
			if string.find(ukrName, " %(") and string.find(ukrName, "%)$") then
				-- Name already has postfix, don't add another one
				SafeAddString(SI_ABILITY_TOOLTIP_NAME, ukrName, 10)
			else
				if DovahMova.Settings.ShowChampionTooltip == "uaen" then
					finalName = string.format("%s (%s)", ukrName, rsd.Abilities[abilityId])
				else
					finalName = rsd.Abilities[abilityId]
				end
				
				if finalName then
					SafeAddString(SI_ABILITY_TOOLTIP_NAME, finalName, 10)
				end
			end
		end
	end
	
	local function abilityTooltipHook(tooltipControl, method, linkFunc)
		local origMethod = tooltipControl[method]
		tooltipControl[method] = function(self, ...)
			
			modifyTooltip(linkFunc(...))
			
			origMethod(self, ...)
			
			SafeAddString(SI_ABILITY_TOOLTIP_NAME, DovahMova.StringsBackup["SI_ABILITY_TOOLTIP_NAME"], 10)
		end
	end
	
	abilityTooltipHook(ChampionSkillTooltip, "SetChampionSkill", getIdFromSkillId)
	abilityTooltipHook(ChampionSkillTooltip, "SetAbilityId", getIdFromAbilityId)
	ZO_PreHook(CHAMPION_PERKS, "LayoutRightTooltipChampionSkillAbility", function(tooltip, ...)   modifyTooltip(...) end)
	end
end
