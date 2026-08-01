NEAR_SB = {
	name = "NearSkillBlocker",
	title = "Near's Skill Blocker",
	shortTitle = "Skill Blocker",
	version = "3.10.0",
	author = "|cCC99FFnotnear|r",
}

local addon = NEAR_SB
local LSB = LibSkillBlocker

local function GetCustomAbilityName(id)
    local string = _G["NEARSB_abilityName_" .. id]
    return GetString(string)
end

local function FormatAbilityName(id)
	if addon.hasCustomName[id] then
		return GetCustomAbilityName(id)
	else
		return zo_strformat("<<C:1>>", GetAbilityName(id))
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Registered list
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function updateRegistered()
	local abilityIds = LSB.GetRegisteredAbilityIdsByAddon(addon.name)
	local abilityNames_set = {}

	if abilityIds ~= nil then
		for id, _ in pairs(abilityIds) do
			abilityNames_set[FormatAbilityName(id)] = true
		end
	end

	-- Convert the set to a sorted list
	local abilityNames_table = {}
	for name, _ in pairs(abilityNames_set) do
		table.insert(abilityNames_table, name)
	end
	table.sort(abilityNames_table)

	local abilityNames = table.concat(abilityNames_table, '\n')
	NEAR_SB.registeredAbilityNames = abilityNames
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Skill Blocker
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function checkConditions(morphData, blockType)
	local block = morphData.block
	local block_recast = morphData.block_recast
	local block_notInCombat = morphData.block_notInCombat
	local block_inCombat = morphData.block_inCombat
	local block_isBracing = morphData.block_isBracing
	local block_onMaxCrux = morphData.block_onMaxCrux or false
	local block_onNotMaxCrux = morphData.block_onNotMaxCrux or false
	local block_onStacksEqual = morphData.block_onStacksEqual or false

	local conditions = {
		[0] = { not block, not block_notInCombat, not block_inCombat, not block_isBracing, not block_recast, not block_onMaxCrux, not block_onNotMaxCrux, not block_onStacksEqual }, -- Conditions for unregisterBlock
		[1] = { block, not block_notInCombat, not block_inCombat, not block_isBracing, not block_recast, not block_onMaxCrux, not block_onNotMaxCrux, not block_onStacksEqual },
		[2] = { block_notInCombat or block_inCombat or block_isBracing, not block_recast, not block_onMaxCrux, not block_onNotMaxCrux, not block_onStacksEqual },
		[3] = { block_recast, not block_onMaxCrux, not block_onNotMaxCrux, not block_onStacksEqual },
		[4] = { block_onMaxCrux },
		[5] = { block_onNotMaxCrux },
		[6] = { block_onStacksEqual },
	}

	local cond = conditions[blockType]
	if not cond then return false end -- If invalid blockType
	for _, c in ipairs(cond) do
		if not c then
			return false
		end
	end
	return true
end

local str_reg = GetString(NEARSB_registered)
local str_unreg = GetString(NEARSB_unregistered)
local str_maxcrux = GetString(NEARSB_un_reg_MaxCrux)
local str_notmaxcrux = GetString(NEARSB_un_reg_NotMaxCrux)
local str_stacks = GetString(NEARSB_un_reg_stacks)
local str_recast = GetString(NEARSB_un_reg_recast)
local str_notincombat = GetString(NEARSB_un_reg_notInCombat)
local str_incombat = GetString(NEARSB_un_reg_inCombat)
local str_isbracing = GetString(NEARSB_un_reg_isBracing)

---@param skillType string
---@param ability integer
---@param morph integer
---@param blockType any
local function register(skillType, ability, morph, blockType)
	local sv = NEAR_SB.ASV

	local skilldata = addon.skilldata[skillType]
	local sv_skilldata = sv.skilldata[skillType]

	local function registerBlock(id, skillLine, msg_pvp, block_pvp, block_notInCombat, block_inCombat, block_isBracing)
		LSB.RegisterSkillBlock(addon.name, id,
			function() return addon.suppressCheck(blockType, skillType, skillLine, ability, morph, id, msg_pvp, block_pvp, block_notInCombat, block_inCombat, block_isBracing) end,
			sv.showError
		)
	end

	local function unregisterBlock(id)
		LSB.UnregisterSkillBlock(addon.name, id)
	end

	local function handleVariants(skillLine, morphData, isRegister)
		local i = 1
		while true do
			local variantId = skilldata[skillLine][ability][morph]["id" .. i]
			if variantId == nil then break end

			if isRegister then
				registerBlock(variantId, skillLine, morphData.msg.pvp, morphData.pvp, morphData.block_notInCombat, morphData.block_inCombat, morphData.block_isBracing)
			else
				unregisterBlock(variantId)
			end
			i = i + 1
		end
	end

	for skillLine, v in pairs(skilldata) do
		if sv_skilldata[skillLine][ability] ~= nil then
			local morphData = sv_skilldata[skillLine][ability][morph]
			local abilityId = v[ability][morph].id

			if checkConditions(morphData, blockType) then
				registerBlock(abilityId, skillLine, morphData.msg.pvp, morphData.pvp, morphData.block_notInCombat, morphData.block_inCombat, morphData.block_isBracing)
				handleVariants(skillLine, morphData, true)

				if sv.message and morphData.msg.re_cast then
					local message = str_reg .. FormatAbilityName(v[ability][morph].id)
					if blockType == 2 then
						local suffix = morphData.block_notInCombat and str_notincombat or morphData.block_inCombat and str_incombat or ''
						suffix = morphData.block_isBracing and suffix .. str_isbracing or suffix
						message = message .. suffix
					elseif blockType ~= 1 then
						local prefix = (blockType == 3 and str_recast) or
							(blockType == 4 and str_maxcrux) or
							(blockType == 5 and str_notmaxcrux) or
							(blockType == 6 and str_stacks) or ''
						local suffix = morphData.block_notInCombat and str_notincombat or morphData.block_inCombat and str_incombat or ''
						suffix = morphData.block_isBracing and suffix .. str_isbracing or suffix
						message = message .. prefix .. suffix
					end
					addon.AddMessage(message)
				end

				morphData.msg.re_cast = false
			elseif checkConditions(morphData, 0) then
				unregisterBlock(abilityId)
				handleVariants(skillLine, morphData, false)

				if sv.message and morphData.msg.re_cast then
					local message = str_unreg .. FormatAbilityName(v[ability][morph].id)
					addon.AddMessage(message)
				end

				morphData.msg.re_cast = false
			end
		end
	end
end

function NEAR_SB.Initialize()
	local skillTypeBlockTypes = {
		['class'] = { 1, 2, 3, 4, 5, 6 }, -- Cast, combat / bracing, Recast, onMaxCrux, onNotMaxCrux, onStacksEqual
		['weapon'] = { 1, 2, 3 },
		['armor'] = { 1, 2, 3 },
		['world'] = { 1, 2, 3 },
		['guild'] = { 1, 2, 3 },
		['ava'] = { 1, 2, 3 },
	}

	-- Execute register functions
	for skillType, blockTypes in pairs(skillTypeBlockTypes) do
		for ability = 1, 6 do
			for morph = 0, 2 do
				for _, blockType in ipairs(blockTypes) do
					register(skillType, ability, morph, blockType)
				end
			end
		end
	end

	updateRegistered()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Addon loading
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function OnAddonLoaded(event, name)
	if name ~= addon.name then return end
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

	addon.ASV = ZO_SavedVars:NewAccountWide(addon.name .. "_Data", 4, GetWorldName(), addon.defaults)

	if AddonCategory then
		AddonCategory.AssignAddonToCategory(addon.name, AddonCategory.baseCategories.Combat)
	end

	if addon.ASV.suppressBlockReset then addon.ASV.suppressBlock = addon.defaults.suppressBlock end

	addon.hasCustomName = {
		[addon.skilldata["ava"][3][6][0].id] = true,
		[addon.skilldata["ava"][3][6][1].id] = true,
		[addon.skilldata["ava"][3][6][2].id] = true,
	}

	NEAR_SB.Initialize()

	NEAR_SB.AbilityBarTimers.Init()
	NEAR_SB.RegisterSlashCommands()
	NEAR_SB.SetupSettings()
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
