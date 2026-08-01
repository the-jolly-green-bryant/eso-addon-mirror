PerfectWeave = {
	name = "PerfectWeave",
	version = "0.8",
}

local DEFAULTS = {
	mode = 1, -- 1: hard; 2: soft; 3: none
	autoLag = true,
	inputLag = 20,
	block = true,
	combat = true,
	blockGroundAbilities = true,
	checkTarget = true,
	blockGrimFocus = true,
	useWhitelist = false,
	whitelist = {
	},
	blacklist = {
	},
}

local M = PerfectWeave
local NAME = M.name
local SW = nil -- account wide saved variables
local EM = EVENT_MANAGER

local GCD_STAGE = 0 -- 0: no GCD; 1: locked, 2: queue window; 3: LA queued; 4: skill queued (and we don't allow to requeue it)
local CHANNEL = 0 -- channel end
local CD_SLOT = 3 -- use first skill to get current cooldown (todo: check if it's a vamp toggle, because it returns no cd info)

local LAST_ABILITY = 0 -- last used or queued ability

local grimFocusSkillIds = {[61905] = true, [61920] = true, [61928] = true} -- contains info about duration
local grimFocusStackIds = {[61902] = true, [61919] = true, [61927] = true} -- contains info about current number of stacks

-- Variables to cache ground abilities check results.
local groundString = GetString(SI_ABILITY_TOOLTIP_TARGET_TYPE_GROUND)
local groundAbilities = {}

local function CheckGroundAbility(id)
	local result = groundAbilities[id]
	if result == nil then
		result = GetAbilityTargetDescription(id) == groundString
		groundAbilities[id] = result
	end
	return result
end

-- Check if we should block the ability based on white/black list.
local function CheckWhiteBlackList(id)
	if SW.useWhitelist then
		return SW.whitelist[id]
	else
		return not SW.blacklist[id]
	end
end

-- Check player buffs if there is an active Grim Focus buff with 4 stacks.
local function CheckGrimFocus()
	local active = false
	local stacks = 0
	for buffIndex = 1, GetNumBuffs('player') do
		local _, _, timeEnding, _, stackCount, _, _, _, _, _, abilityId = GetUnitBuffInfo('player', buffIndex)
		-- Abilities that contain info about stacks and duration are actually different :/
		if grimFocusStackIds[abilityId] then
			if timeEnding > GetGameTimeSeconds() then
				active = true
			else
				break
			end
		elseif grimFocusSkillIds[abilityId] then
			stacks = stackCount
		end
	end
	return active and stacks == 4
end

local function Initialize()

	SW = ZO_SavedVars:NewAccountWide('PerfectWeaveSV', 1, nil, DEFAULTS)

	local function CanUseActionSlots()
		local ignore = false

		-- Check block, combat and target.
		if SW.block and IsBlockActive() or SW.combat and not IsUnitInCombat('player') or SW.checkTarget and not IsUnitAttackable('reticleover') then
			-- Give a chance to block a ground target abilitiy even if the ability is allowed by the conditions above.
			if SW.blockGroundAbilities then
				ignore = true
			else
				return false
			end
		end

		-- Get ability id from the traceback (WTB a cleaner way).
		local n = tonumber(debug.traceback():match('ACTION_BUTTON_(%d)'))
		local id = GetSlotBoundId(n)

		-- Block Grim Focus at 4 stacks.
		if SW.blockGrimFocus and not ignore and GCD_STAGE == 3 and grimFocusStackIds[id] and CheckGrimFocus() then
			return true
		end

		-- Check if it's an attempt to cast a ground ability twice in a row.
		local ground = SW.blockGroundAbilities and LAST_ABILITY == id and CheckGroundAbility(id)

		-- If we are blocking or out of combat or not targeting an enemy and this is not a ground ability, then allow this cast.
		-- Also ignore vampire toggle.
		if ignore and not ground or id == 132141 or id == 134160 or id == 135841 then
			return false
		end

		-- Check if we are outside GCD and not channeling (accounting the input lag).
		local cd = GetSlotCooldownInfo(CD_SLOT)
		local inputLag = SW.autoLag and zo_min(GetLatency() / 2 - 1, 48) or SW.inputLag
		if cd <= inputLag and GetGameTimeMilliseconds() > CHANNEL - inputLag then
			-- Stage 4 blocks double cast of skills during the last few ms of GCD.
			if cd < 1 or GCD_STAGE < 4 then
				GCD_STAGE = 0
			end
		elseif cd > 0 and GCD_STAGE == 0 then -- mystery case
			GCD_STAGE = 1
		end

		-- Block skill if LA is queued or always in Hard mode.
		if GCD_STAGE > 0 and n >= 3 and n <= 8 and (ground or CheckWhiteBlackList(id)) and (GCD_STAGE >= 3 or SW.mode == 1 or ground) then
			return true
		else
			-- This is the case, when the skill has been allowed to fire during GCD.
			-- The problem is, if we allow it twice, sometimes it can break animations and the next skills (tested with high ping).
			-- Stage 4 is to try to prevent this. Only do it in Hard mode, otherwise it alters default behavior.
			if cd > 0 and SW.mode == 1 then
				GCD_STAGE = 4
			end
			return false
		end
	end

	local function AbilityUsed(_, n)
		-- Light attack.
		if n == 1 then
			-- Queue LA.
			if SW.mode ~= 3 then
				GCD_STAGE = 3
			end
		-- Ability.
		elseif n >= 3 and n <= 8 then
			local cd = GetSlotCooldownInfo(CD_SLOT)
			-- Trying to queue an ability during GCD or channel.
			if cd < 600 then
				GCD_STAGE = 2
			-- Casting an ability outside of GCD (normally cd is between 900 and 1000 here).
			else
				GCD_STAGE = 1
			end
			-- Check if it's a channeled ability.
			local id = GetSlotBoundId(n)
			if GetSlotType(n) == ACTION_TYPE_CRAFTED_ABILITY then id = GetAbilityIdForCraftedAbilityId(id) end
			local isChanneled, castTime, channelTime = GetAbilityCastInfo(id)
			if isChanneled or castTime > 0 then
				-- Some ugly random magic here I don't even fully comprehend.
				CHANNEL = GetGameTimeMilliseconds() + zo_max(1050, zo_max(castTime or 0, channelTime or 0) + 150)
			else
				CHANNEL = 0
			end
			LAST_ABILITY = id
		end
	end

	-- Player pressed a skill button.
	EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ACTION_SLOT_ABILITY_USED, AbilityUsed)

	-- Hook to block skills.
	ZO_PreHook("ZO_ActionBar_CanUseActionSlots", CanUseActionSlots)

	-- Context menu.
	local function AddActionMenuItem(abilityId)
		if SW.useWhitelist then
			AddMenuItem(SW.whitelist[abilityId] and "|cFFFF00[PerfectWeave]|r Remove from Whitelist" or "|cFFFF00[PerfectWeave]|r Add to Whitelist", function() M.ToggleWhitelistAbility(abilityId) end)
		else
			AddMenuItem(SW.blacklist[abilityId] and "|cFFFF00[PerfectWeave]|r Remove from Blacklist" or "|cFFFF00[PerfectWeave]|r Add to Blacklist", function() M.ToggleBlacklistAbility(abilityId) end)
		end
	end
	-- Action Bar.
	-- https://github.com/esoui/esoui/blob/3758834f21c665b5ab3d520abde33a2d82b405b4/esoui/ingame/actionbar/abilityslot.lua#L99
	ZO_PreHook("ZO_AbilitySlot_OnSlotClicked", function(abilitySlot, buttonId)
		if buttonId == MOUSE_BUTTON_INDEX_RIGHT then
			local button = ZO_ActionBar_GetButton(abilitySlot.slotNum)
			if button then
				local slotNum = button:GetSlot()
				if GetSlotType(slotNum) == ACTION_TYPE_ABILITY and IsSlotUsed(slotNum) and not IsSlotLocked(slotNum) then
					zo_callLater(function() AddActionMenuItem(GetSlotBoundId(slotNum)); ShowMenu(abilitySlot) end, 0)
				end
			end
		end
	end)
	-- Assignable skills.
	-- https://github.com/esoui/esoui/blob/3758834f21c665b5ab3d520abde33a2d82b405b4/esoui/ingame/skills/keyboard/keyboardassignableactionbar.lua#L261
	ZO_PreHook(ZO_KeyboardAssignableActionBarButton, "ShowActionMenu", function(self)
		local hotbar = ACTION_BAR_ASSIGNMENT_MANAGER:GetCurrentHotbar()
		local slotData = hotbar:GetSlotData(self.slotId)
		if slotData and not slotData:IsEmpty() then			
			zo_callLater(function() AddActionMenuItem(GetSlotBoundId(self.slotId)); ShowMenu(self.button) end, 0)
		end
	end)

	-- Key binding.
	ZO_CreateStringId('SI_BINDING_NAME_PERFECT_WEAVE_MODE', 'Cycle mode')

	-- Settings menu.
	M.BuildMenu(SW, DEFAULTS)

end

function M.CycleMode()
	local msg = ''
	if SW.mode == 1 then
		SW.mode = 2
		msg = "|cFFFF00Soft|r"
	elseif SW.mode == 2 then
		SW.mode = 3
		msg = "|c00FFFFNone|r"
	else
		SW.mode = 1
		msg = "|cFF0000Hard|r"
	end
	d('|cAAAAAAPerfectWeave new mode:|r ' .. msg)
end

function M.ToggleWhitelistAbility(id)
	if SW.whitelist[id] then
		SW.whitelist[id] = nil
	else
		SW.whitelist[id] = true
	end
	SW.blacklist[id] = nil
end

function M.ToggleBlacklistAbility(id)
	if SW.blacklist[id] then
		SW.blacklist[id] = nil
	else
		SW.blacklist[id] = true
	end
	SW.whitelist[id] = nil
end

local function OnAddOnLoaded(event, addonName)
	if addonName == NAME then
		EM:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
		Initialize()
	end
end

EM:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)