-- https://github.com/esoui/esoui/blob/a34599f2cba93196976512d71f3b850cc9975ed9/esoui/ingame/globals/bindings.xml#L104
-- To lock weapon swap, the addon makes the game think we are in the skills menu, where weapon swap can be locked
-- by hooking ACTION_BAR_ASSIGNMENT_MANAGER:CanCycleHotbars() function.
LockWeaponSwap = {
	name = "LockWeaponSwap",
	version = "0.1",
}

local M = LockWeaponSwap
local NAME = M.name
local EM = EVENT_MANAGER
local reasons = {} -- support for multiple sources to lock weapon swap

-- Returns true, if weapon swap is currently locked.
-- Weapon swap is considered locked, if there is at least one reason to lock it.
function M.IsLocked(reason)
	if reason then
		return reasons[reason]
	end
	for _, locked in pairs(reasons) do
		if locked then
			return true
		end
	end
end

-- Lock weapon swap.
function M.Lock(reason)
	reasons[reason] = true
	-- Visuals.
	ZO_WeaponSwap_SetExternallyLocked(ZO_ActionBar1WeaponSwap, true)
	if FAB_ActionBarArrow then -- fancy action bar
		FAB_ActionBarArrow:SetDesaturation(1)
	end
end

-- Unlock weapon swap.
-- If reason is not provided, then unlocks completely.
function M.Unlock(reason)
	if reason then
		reasons[reason] = false
	else
		for reason in pairs(reasons) do
			reasons[reason] = false
		end
	end
	-- Visuals.
	if not M.IsLocked() then
		ZO_WeaponSwap_SetExternallyLocked(ZO_ActionBar1WeaponSwap, false)
		if FAB_ActionBarArrow then -- fancy action bar
			FAB_ActionBarArrow:SetDesaturation(0)
		end
	end
end

local function Initialize()

	-- https://github.com/esoui/esoui/blob/c2491db4a9e40fdb8c8cacfc84523c60c2076c79/esoui/ingame/skills/actionbarassignmentmanager.lua#L922
	ZO_PreHook(ACTION_BAR_ASSIGNMENT_MANAGER, 'CanCycleHotbars', function() return M.IsLocked() end)

	-- Can't use prehook here, because we need to return true to lock weapon swap,
	-- and prehook "returns" nil, also breaking the skills menu.
	local IsShowing = SKILLS_FRAGMENT.IsShowing
	SKILLS_FRAGMENT.IsShowing = function(self) return true and M.IsLocked() or IsShowing(self) end

	-- cloudrest.lua
	if M.cr then M.cr.Initialize() end

end

local function OnAddOnLoaded(event, addonName)
	if addonName == NAME then
		EM:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
		Initialize()
	end
end

EM:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)