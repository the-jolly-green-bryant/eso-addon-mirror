--[[
  This file is part of Awesome Events.

  Author: Ze_Mi
  Filename: WeaponCharge.lua

  Copyright (c) 2017-2024 by Martin Unkel
  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  ]]

local AE = Awesome_Events
local MOD = AE.module_factory({
    id = 'weaponcharge',
    title = GetString(SI_AWEMOD_WEAPONCHARGE),
    hint = GetString(SI_AWEMOD_WEAPONCHARGE_HINT),
    order = 55,
    debug = false,

    fontSize = 4,
    options = {
        valueLowInfo = {
            type = 'slider',
            name = GetString(SI_AWEMOD_WEAPONCHARGE_INFO),
            tooltip = GetString(SI_AWEMOD_WEAPONCHARGE_INFO_HINT),
            min = 1,
            max = 60,
            default = 50,
            order = 1,
        },
        valueLowWarning = {
            type = 'slider',
            name = GetString(SI_AWEMOD_WEAPONCHARGE_WARNING),
            tooltip = GetString(SI_AWEMOD_WEAPONCHARGE_WARNING_HINT),
            min = 1,
            max = 40,
            default = 25,
            order = 2,
        },
    }
})

-- OVERRIDES

function MOD:Enable(options)
    self:d('Enable (in debug-mode)')
    self.data = {
        minimumValue = 100,
        slotId = 0,
    }
    self:OnInventorySingleSlotUpdate(0)
    self.hasUpdate = true
end

-- EVENT LISTENER

-- test if slotId is a weapon slot
local function isWeaponSlot(slotId)
	if(slotId == nil or slotId == 0)then
		return false
	end
	local weaponSlots = { 4, 5, 20, 21 }
	for i,_slotId in ipairs(weaponSlots) do
		if(slotId == _slotId)then
			return true
		end
	end
	return false
end -- isWeaponSlot

function MOD:GetEventListeners()
    return {
        {
            eventCode = EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
            callback = function(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
				if(bagId == BAG_WORN and isWeaponSlot(slotId))then
					if(inventoryUpdateReason == INVENTORY_UPDATE_REASON_DEFAULT or inventoryUpdateReason == INVENTORY_UPDATE_REASON_ITEM_CHARGE) then
						MOD:OnInventorySingleSlotUpdate(slotId)
					end
				end
            end,
        }
    }
end -- MOD:GetEventListeners


-- EVENT HANDLER
-- Weapon charge alerts
-- Item IDs are 4 & 5 for main weapon set, 20 & 21 for alternate set.
function MOD:OnInventorySingleSlotUpdate(slotId)
    self:d('OnInventorySingleSlotUpdate: '..slotId)
	
    -- use slotId if not nil for single slot update
	if(isWeaponSlot(slotId) and IsItemChargeable(BAG_WORN, slotId))then
		local charges, maxCharges = GetChargeInfoForItem(BAG_WORN, slotId)
		local relativeCharge = math.floor(100 * charges / maxCharges)
		if(relativeCharge <= self.data.minimumValue) then
			self.data.slotId = slotId
			self.data.minimumValue = relativeCharge
			self.hasUpdate = true
			self:d(' => hasUpdate (single)')
			return
		else
			slotId = 0
		end
	end
	
	-- recheck all slots
    local lowestChargeSlotId = 0
    local lowestRelativeCharge = 100
	if(slotId == nil or slotId == 0)then
		local weaponSlotTable = { 4, 5, 20, 21 }
		local i,v
		for i,_slotId in ipairs(weaponSlotTable) do
			if(IsItemChargeable(BAG_WORN, _slotId))then
				local charges, maxCharges = GetChargeInfoForItem(BAG_WORN, _slotId)
				local relativeCharge = math.floor(100 * charges / maxCharges)
				if (relativeCharge < lowestRelativeCharge) then
					lowestRelativeCharge = relativeCharge
					lowestChargeSlotId = _slotId
				end
			end
		end
	end
    self:d(' => old: '..self.data.minimumValue .. '% (Item:'..self.data.slotId..')')
    self:d(' => new: '..lowestRelativeCharge .. '% (Item:'..lowestChargeSlotId..')')

    if(lowestChargeSlotId ~= self.data.slotId or lowestRelativeCharge ~= self.data.minimumValue)then
        self.data.minimumValue = lowestRelativeCharge
        self.data.slotId = lowestChargeSlotId
        self.hasUpdate = true
        self:d(' => hasUpdate')
    end
end -- MOD:OnInventorySingleSlotUpdate

-- LABEL HANDLER

function MOD:Update(options)
    self:d('Update')
    local labelText = ''
    if (self.data.minimumValue <= options.valueLowInfo) then
		local weaponSet = (self.data.slotId<6) and '1' or '2'
		local color = (self.data.minimumValue <= options.valueLowWarning) and AE.const.COLOR_WARNING or AE.const.COLOR_HINT
        labelText = MOD.Colorize(color, zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemName(BAG_WORN, self.data.slotId))) .. ': ' .. self.data.minimumValue .. '%' .. ' (' .. weaponSet .. '. ' .. GetString(SI_AWEMOD_WEAPONCHARGE_SET_LABEL) .. ')'
    end
    self.labels[1]:SetText(labelText)
end -- MOD:Update