GCDBar = GCDBar or { }
local gb = GCDBar

local EM = GetEventManager()

local defaults = {
	["frameX"] = 500,
	["frameY"] = 500,
	["width"] = 175,
	["height"] = 50,
	["scale"] = 1,
	["color"] = {1, 0, 0, .7},
	["abCooldown"] = false,
	["fastGCD"] = false,
	["advTime"] = 0,
	["reverse"] = false,
	["hideFrame"] = false,
}

gb.name = "GCDBar"
gb.version = "2.6"
local cd = 0
local dur = 1

local function cdHandler()
	local remain, duration, global, globalSlotType = GetSlotCooldownInfo(3)
	local r2, d2, _, _ = GetSlotCooldownInfo(4)
	if (r2 > remain) or ( d2 > duration ) then
		remain = r2
		duration = d2
	end
	--cd = cd - 20
	--if gb.savedVars.fastGCD then cd = cd - 2 end -- count down 10% faster
	--if gb.savedVars.advTime > 0 then cd = cd - (gb.savedVars.advTime/dur)*20 end
	if duration < 1 then duration = 1 end
	gb.UI.gbFront:SetDimensions((remain/duration)*gb.savedVars.width, gb.savedVars.height)
end

--local function rebuildFunction()
--	local updateCooldown = ActionButton.UpdateCooldown
--
--	function ActionButton:UpdateCooldown(options)
--		local slotNum = self:GetSlot()
--		local remain, duration, global, globalSlotType = GetSlotCooldownInfo(slotNum)
--		if slotNum == 3 and remain > 0 and global then
--			cd = remain
--			dur = (duration > 0) and duration or 1
--		end
--
--		updateCooldown(self, options)
--	end
--end

function gb.init(e, addonName)
	if addonName ~= gb.name then return end
	gb.savedVars = ZO_SavedVars:NewCharacterIdSettings("GCDBarSavedVars", 1, nil, defaults)
	gb.UI.buildUI()
	gb.UI.setProperties()
--	rebuildFunction()
	EM:RegisterForUpdate(gb.name.."cooldown", 20, cdHandler)
	gb.buildMenu()
	if gb.savedVars.hideFrame then
		gb.UI.gbFrame:SetHidden(true)
		gb.UI.setHudToggle(false)
	end
	if gb.savedVars.abCooldown then ZO_ActionButtons_ToggleShowGlobalCooldown() end
end

EM:RegisterForEvent(gb.name.."Load", EVENT_ADD_ON_LOADED, gb.init)

