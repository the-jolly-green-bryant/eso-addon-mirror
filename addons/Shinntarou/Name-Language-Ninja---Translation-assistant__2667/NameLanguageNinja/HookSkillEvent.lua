local ADDON = NameLanguageNinja
local LMN = LibMultilingualName

--------
-- in this file local use, private
--------

local function getColoredText(langCode, text)
	return ADDON.GetColoredText(langCode, text)
end

local function getSkillInfo(tooltipControl)
	if tooltipControl.skillProgressionData == nil then
		return {
			skillId = nil,
			morphSkillId = nil
		}
	end

	local skillId = tooltipControl.skillProgressionData.abilityId
	local progress = tooltipControl.skillProgressionData.skillProgressionKey
	local progressions = tooltipControl.skillProgressionData.skillData.skillProgressions
	local morphSkillId = nil

	if progress ~= nil and progress > 0 then
		if progressions[0] ~= nil then
			morphSkillId = progressions[0].abilityId
		end
	end

	return {
		skillId = skillId,
		morphSkillId = morphSkillId
	}
end

local function getNames(clientLangCode, skillId)
	if skillId == nil then
		return {}
	end

	local names = {}

	-- get names in your languages for tooltip
	for key, langCode in ipairs(LMN.ALL_LANG_CODES) do
		if ADDON.SaveData.Languages[langCode] then
			if not ADDON.SaveData.DontShowClientLanguage or clientLangCode ~= langCode then
				if LMN.GetRawSkillName(langCode, skillId) then
					local planeText = LMN.GetSkillName(langCode, skillId)
					local coloredText = getColoredText(langCode, planeText)
					names[#names + 1] = coloredText
				end
			end
		end
	end

	return names
end

local function getDescriptions(clientLangCode, skillId)
	ADDON.develop("getDescriptions")
	if skillId == nil then
		return {}
	end
	if not ADDON.SaveData.Description.OutputSkill then
		return {}
	end

	local descriptions = {}

	for key, langCode in ipairs(LMN.ALL_LANG_CODES) do
		if ADDON.SaveData.Description.Languages[langCode] then
			if not ADDON.SaveData.DontShowClientLanguage or clientLangCode ~= langCode then
				if LMN.GetRawAbilityDescription(langCode, skillId) then
					descriptions[#descriptions + 1] = LMN.GetAbilityDescription(langCode, skillId)
				end
			end
		end
	end
	--TODO
	if ADDON.SaveData.Description.OutputSkillId then
		descriptions[#descriptions + 1] = "skillId:" .. skillId
	end

	return descriptions
end

local function beforeTooltipCreation(tooltipControl, skillInfo, names, morphNames)
	-- check
	if (#names < 1) then
		return
	end

	-- TODO
	if ADDON.SaveData.To.Skill.Tooltip.Title then
		local newTitle = skillInfo.name
		for key, val in ipairs(names) do
			if morphNames[key] ~= nil then
				val = val .. " (" .. morphNames[key] .. ")"
			end
			newTitle = newTitle .. "\n" .. val
		end
	end
end

local function afterTooltipCreation(tooltipControl, skillInfo, names, morphNames, descriptions)
	-- check
	if (#names < 1) then
		return
	end

	if ADDON.SaveData.To.Skill.Tooltip.Body then
		if (not ADDON.SaveData.DontShowDivider) then
			ZO_Tooltip_AddDivider(SkillTooltip)
		end
		for key, val in ipairs(names) do
			if morphNames[key] ~= nil then
				val = val .. " (" .. morphNames[key] .. ")"
			end
			SkillTooltip:AddLine(val)
		end
		for key, val in ipairs(descriptions) do
			SkillTooltip:AddLine(val)
		end
	end
end

local function setCallback_ZO_Skills_AbilitySlot_OnMouseEnter()
	local base = ZO_Skills_AbilitySlot_OnMouseEnter
	ZO_Skills_AbilitySlot_OnMouseEnter = function(control)
		ADDON.develop("ZO_Skills_AbilitySlot_OnMouseEnter")

		local clientLangCode = string.lower(GetCVar("language.2"))
		local skillInfo = getSkillInfo(control)
		local names = getNames(clientLangCode, skillInfo.skillId)
		local morphNames = getNames(clientLangCode, skillInfo.morphSkillId)
		local descriptions = getDescriptions(clientLangCode, skillInfo.skillId)

		beforeTooltipCreation(control, skillInfo, names, morphNames) -- before tooltip creation
		base(control) -- Original
		afterTooltipCreation(control, skillInfo, names, morphNames, descriptions) -- after tooltip creation
	end
end

local function afterCpTooltipCreation(cpTooltipControl, names, descriptions)
	-- check
	if (#names < 1) then
		return
	end

	if ADDON.SaveData.To.Skill.Tooltip.Body then
		if (not ADDON.SaveData.DontShowDivider) then
			ZO_Tooltip_AddDivider(cpTooltipControl)
		end
		for key, val in ipairs(names) do
			cpTooltipControl:AddLine(val)
		end
		for key, val in ipairs(descriptions) do
			cpTooltipControl:AddLine(val)
		end
	end
end

local function setCallback_ZO_KeyboardAssignableActionBarButton_OnMouseEnter()
	local base = ZO_KeyboardAssignableActionBarButton_OnMouseEnter
	ZO_KeyboardAssignableActionBarButton_OnMouseEnter = function(control)
		ADDON.develop("ZO_KeyboardAssignableActionBarButton_OnMouseEnter")

		base(control) -- Original
		return
		
		--[[ TODO

		ADDON.var_keys_dump(control)
		ADDON.develop("----")
		ADDON.var_keys_dump(control.owner)
		ADDON.develop("----")
		ADDON.var_keys_dump(GetCursorAbilityId())

		local validTooltip = false
		if control ~= nil and control.owner ~= nil then
			validTooltip = true
		end
		if not validTooltip then
			base(control) -- Original
			return
		end

		local clientLangCode = string.lower(GetCVar("language.2"))

		local skillInfo = getSkillInfo(control.owner)
		local names = getNames(clientLangCode, skillInfo.skillId)
		local morphNames = getNames(clientLangCode, skillInfo.morphSkillId)
		local descriptions = getDescriptions(clientLangCode, skillInfo.skillId)
		names = {"dummy"}

		beforeTooltipCreation(control, skillInfo, names, morphNames) -- before tooltip creation
		base(control) -- Original
		afterTooltipCreation(control, skillInfo, names, morphNames, descriptions) -- after tooltip creation
		]]
	end
end

local function ChampionTooltipHook(tooltipControl, method, linkFunc)
	local previousMethod = tooltipControl[method]

	tooltipControl[method] = function(self, ...)
		ADDON.develop("ChampionTooltipHook")
		local skillId = linkFunc(...)
		local clientLangCode = string.lower(GetCVar("language.2"))
		local names = getNames(clientLangCode, skillId)
		local descriptions = getDescriptions(clientLangCode, skillId)

		local result = previousMethod(self, ...)
		afterCpTooltipCreation(self, names, descriptions) -- after tooltip creation

		return result
	end
end

local function setCallback_ZO_ArmoryChampionActionSlot_OnMouseEnter()
	local base = ZO_ArmoryChampionActionSlot_OnMouseEnter
	ZO_ArmoryChampionActionSlot_OnMouseEnter = function(control)
		ADDON.develop("ZO_ArmoryChampionActionSlot_OnMouseEnter")

		local validTooltip = false
		if
			control ~= nil and control.owner ~= nil and control.owner.championSkillData ~= nil and
				control.owner.championSkillData.championSkillId ~= nil
		 then
			validTooltip = true
		end
		if not validTooltip then
			base(control) -- Original
			return
		end

		local clientLangCode = string.lower(GetCVar("language.2"))

		--ADDON.var_keys_dump(control.owner)
		--ADDON.develop("----")
		--ADDON.var_keys_dump(control.owner.championSkillData)
		--ADDON.develop("----")
		--ADDON.var_keys_dump(control.owner.championSkillData.linkedChampionSkillDatas)

		local skillId = GetChampionAbilityId(control.owner.championSkillData.championSkillId)
		local names = getNames(clientLangCode, skillId)
		local descriptions = getDescriptions(clientLangCode, skillId)

		-- TODO before tooltip creation

		base(control) -- Original

		if ADDON.SaveData.To.Skill.Tooltip.Body then
			if (not ADDON.SaveData.DontShowDivider) then
				ZO_Tooltip_AddDivider(ChampionSkillTooltip)
			end
			for key, val in ipairs(names) do
				ChampionSkillTooltip:AddLine(val)
			end
			for key, val in ipairs(descriptions) do
				ChampionSkillTooltip:AddLine(val)
			end
		end
	end
end

local function setCallback_ZO_ArmoryActionButton_Keyboard_OnMouseEnter()
	local base = ZO_ArmoryActionButton_Keyboard_OnMouseEnter
	ZO_ArmoryActionButton_Keyboard_OnMouseEnter = function(control)
		ADDON.develop("ZO_ArmoryActionButton_Keyboard_OnMouseEnter")

		local validTooltip = false
		if control ~= nil and control.owner ~= nil then
			validTooltip = true
		end
		if not validTooltip then
			base(control) -- Original
			return
		end

		local clientLangCode = string.lower(GetCVar("language.2"))

		local skillInfo = getSkillInfo(control.owner)
		local names = getNames(clientLangCode, skillInfo.skillId)
		local morphNames = getNames(clientLangCode, skillInfo.morphSkillId)
		local descriptions = getDescriptions(clientLangCode, skillInfo.skillId)

		beforeTooltipCreation(control, skillInfo, names, morphNames) -- before tooltip creation
		base(control) -- Original
		afterTooltipCreation(control, skillInfo, names, morphNames, descriptions) -- after tooltip creation
	end
end

--------
-- in this ADDON use, protected
--------

function ADDON.HookSkillEvent()
	ADDON.develop("HookSkillEvent")

	-- @see https://wiki.esoui.com/ESOUI_API_Funcs#ingame.5Cskills

	setCallback_ZO_Skills_AbilitySlot_OnMouseEnter() -- skill ability page
	setCallback_ZO_KeyboardAssignableActionBarButton_OnMouseEnter() -- skill ability page's action bar focus event

	-- Champion Abilities tooltip
	ChampionTooltipHook(ChampionSkillTooltip, "SetChampionSkill", GetChampionAbilityId)

	-- armory CP
	setCallback_ZO_ArmoryChampionActionSlot_OnMouseEnter()
	-- armory Ability
	setCallback_ZO_ArmoryActionButton_Keyboard_OnMouseEnter()
end
