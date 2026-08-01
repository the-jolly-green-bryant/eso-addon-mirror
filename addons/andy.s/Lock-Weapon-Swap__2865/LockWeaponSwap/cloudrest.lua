-- Disable weapon swap while Voltaic Overload is active.
LockWeaponSwap.cr = {
	name = 'LockWeaponSwapCR'
}

local M = LockWeaponSwap.cr
local NAME = M.name
local EM = EVENT_MANAGER

local overloadActive = false -- Voltaic Overload is currenly active
local overloadSwapped = false -- player swapped bar after Voltaic Overload started

local function OnActiveWeaponPairChanged()
	-- Lock weapon swap if overload is active and player hasn't swapped yet.
	if overloadActive and not overloadSwapped then
		overloadSwapped = true
		LockWeaponSwap.Lock(NAME)
	else
		overloadSwapped = false
	end
end

-- Can use endTime to unlock weapon swap, but EFFECT_RESULT_FADED seems to be reliable enough.
local function VoltaicOverload(_, changeType, _, _, unitTag, beginTime, endTime)
	if unitTag ~= "player" then return end
	-- Player needs to swap weapon bar.
    if changeType == EFFECT_RESULT_GAINED then
		overloadActive = true
		overloadSwapped = false
	-- Effect ended, unlock swap.
	elseif changeType == EFFECT_RESULT_FADED then
		LockWeaponSwap.Unlock(NAME)
		overloadActive = false
    end
end

-- Only register events in Cloudrest.
local function PlayerActivated()

	EM:UnregisterForEvent(NAME, EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
	EM:UnregisterForEvent(NAME, EVENT_EFFECT_CHANGED)

	if GetZoneId(GetUnitZoneIndex("player")) == 1051 then
		EM:RegisterForEvent(NAME, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, OnActiveWeaponPairChanged)

		EM:RegisterForEvent(NAME, EVENT_EFFECT_CHANGED, VoltaicOverload)
		EM:AddFilterForEvent(NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 87346)
		EM:AddFilterForEvent(NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
	end
end

function M.Initialize()
	EM:RegisterForEvent(NAME, EVENT_PLAYER_ACTIVATED, PlayerActivated)
end