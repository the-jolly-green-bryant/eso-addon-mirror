Near_SkillBlockerBanner = {
	name = "NearSkillBlockerBanner",
	title = "Near's Skill Blocker Banner",
	shortTitle = "Skill Blocker Banner",
	version = "1.0.2",
	author = "|cCC99FFnotnear|r",
}

Near_SkillBlockerBanner.skilldata = {
	[1] = { id = 217699, id1 = 230289, name = zo_strformat("<<C:1>>", GetCraftedAbilityDisplayName(12)), }, -- Banner Bearer
}

Near_SkillBlockerBanner.buffdata = {
    [1] = { -- Banner Bearer
		[227066] = true,
		[227067] = true,
		[227069] = true,
		[227003] = true,
		[227004] = true,
		[227007] = true,
		[227008] = true,
		[227009] = true,
		[227070] = true,
		[227071] = true,
		[227073] = true,
		[227075] = true,
		[227082] = true,
		[227085] = true,
		[227086] = true,
		[227087] = true,
		[227088] = true,
		[227089] = true,
		[217704] = true,
		[217705] = true,
		[217706] = true,
	},
}

--[[
	/script local unitTag = 'player' for buffIndex = 1, GetNumBuffs(unitTag) do
	local buffName, _, _, _, _, _, _, _, _, _, buffAbilityId, _, castByPlayer = GetUnitBuffInfo(unitTag, buffIndex)
	d('- name: '..tostring(buffName), 'id: '..tostring(buffAbilityId), 'cast by player: '..tostring(castByPlayer)) end
]]

local addon = Near_SkillBlockerBanner
local LSB = LibSkillBlocker

function Near_SkillBlockerBanner.AddMessage(message)
	local prefix = string.format('%s%s %s', addon.shortTitle, ':', "|cFFFFFF")
	CHAT_SYSTEM:AddMessage(string.format('%s%s', prefix, message))
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Skill Blocker
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local str_reg = GetString(NEARSB_registered)
local str_unreg = GetString(NEARSB_unregistered)

---@param ability integer
local function register(ability)
	local sv = Near_SkillBlockerBanner.ASV

	local skilldata = addon.skilldata[ability]
	local sv_skilldata = sv.skilldata[ability]

	local function registerBlock(id, msg_pvp, block_pvp, block_inCombat)
		LSB.RegisterSkillBlock(addon.name, id,
			function() return addon.suppressCheck(ability, id, msg_pvp, block_pvp, block_inCombat) end,
			sv.showError
		)
	end

	local function unregisterBlock(id)
		LSB.UnregisterSkillBlock(addon.name, id)
	end

	local function handleVariants(morphData, isRegister)
		local i = 1
		while true do
			local variantId = skilldata["id" .. i]
			if variantId == nil then break end

			if isRegister then
				registerBlock(variantId, morphData.msg.pvp, morphData.pvp, morphData.block_inCombat)
			else
				unregisterBlock(variantId)
			end
			i = i + 1
		end
	end

	local morphData = sv_skilldata
	local abilityId = skilldata.id

	if morphData.block then
		registerBlock(abilityId, morphData.msg.pvp, morphData.pvp, morphData.block_inCombat)
		handleVariants(morphData, true)

		if sv.message and morphData.msg.re_cast then
			local message = str_reg .. skilldata.name
			addon.AddMessage(message)
		end

		morphData.msg.re_cast = false
	else
		unregisterBlock(abilityId)
		handleVariants(morphData, false)

		if sv.message and morphData.msg.re_cast then
			local message = str_unreg .. skilldata.name
			addon.AddMessage(message)
		end

		morphData.msg.re_cast = false
	end
end


function Near_SkillBlockerBanner.Initialize()
	for index in ipairs(addon.skilldata) do
		register(index)
	end
end


-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Addon loading
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function OnAddonLoaded(event, name)
	if name ~= addon.name then return end
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

	addon.ASV = ZO_SavedVars:NewAccountWide(addon.name .. "_Data", 1, GetWorldName(), addon.defaults)

	if AddonCategory then
		AddonCategory.AssignAddonToCategory(addon.name, AddonCategory.baseCategories.Combat)
	end

	Near_SkillBlockerBanner.Initialize()
	Near_SkillBlockerBanner.SetupSettings()

end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
