--[[
  This file is part of Awesome Events.

  Author: Ze_Mi
  Filename: Durability.lua

  Copyright (c) 2017-2024 by Martin Unkel
  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  ]]

local AE = Awesome_Events
local MOD = AE.module_factory({
    id = 'durability',
    title = GetString(SI_AWEMOD_DURABILITY),
    hint = GetString(SI_AWEMOD_DURABILITY_HINT),
    order = 50,
    debug = false,

    fontSize = 4,
    options = {
        valueLowInfo = {
            type = 'slider',
            name = GetString(SI_AWEMOD_DURABILITY_INFO),
            tooltip = GetString(SI_AWEMOD_DURABILITY_INFO_HINT),
            min  = 1,
            max = 60,
            default = 50,
            order = 1,
        },
        valueLowWarning = {
            type = 'slider',
            name = GetString(SI_AWEMOD_DURABILITY_WARNING),
            tooltip = GetString(SI_AWEMOD_DURABILITY_WARNING_HINT),
            min  = 1,
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
        minimumValue = 9999,
        repairCost = 0,
    }
    self:OnInventorySingleSlotUpdate(0)
    self.hasUpdate = true
end

-- EVENT LISTENER

function MOD:GetEventListeners()
    return {
        {
            eventCode = EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
            callback = function(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
                if(bagId == BAG_WORN and inventoryUpdateReason == INVENTORY_UPDATE_REASON_DURABILITY_CHANGE) then
                    MOD:OnInventorySingleSlotUpdate(slotId)
                end
            end,
        }
    }
end

-- EVENT HANDLER

function MOD:OnInventorySingleSlotUpdate(slotId)
    self:d('OnInventorySingleSlotUpdate ' .. slotId)
    -- use slotId if not nil
    --[[
    EQUIP_SLOT_HEAD = 0
    EQUIP_SLOT_NECK = 1
    EQUIP_SLOT_CHEST = 2
    EQUIP_SLOT_SHOULDERS = 3
    EQUIP_SLOT_MAIN_HAND = 4
    EQUIP_SLOT_OFF_HAND = 5
    EQUIP_SLOT_WAIST = 6
    EQUIP_SLOT_WRIST = 7
    EQUIP_SLOT_LEGS = 8
    EQUIP_SLOT_FEET = 9
    EQUIP_SLOT_COSTUME = 10
    EQUIP_SLOT_RING1 = 11
    EQUIP_SLOT_RING2 = 12
    EQUIP_SLOT_POISON = 13
    EQUIP_SLOT_BACKUP_POISON = 14
    EQUIP_SLOT_RANGED = 15
    EQUIP_SLOT_HAND = 16
    EQUIP_SLOT_CLASS1 = 17
    EQUIP_SLOT_CLASS2 = 18
    EQUIP_SLOT_CLASS3 = 19
    EQUIP_SLOT_BACKUP_MAIN = 20
    EQUIP_SLOT_BACKUP_OFF = 21
    EQUIP_SLOT_MAX_VALUE = 21
    EQUIP_SLOT_MIN_VALUE = -1

    EQUIP_SLOT_NONE = -1
    EQUIP_SLOT_TRINKET1 = 222
    EQUIP_SLOT_TRINKET2 = 222
    ]]--

    local repairAllCost = GetRepairAllCost()
    if( repairAllCost ~= self.data.repairCost ) then
        self.data.repairCost = repairAllCost

        local minDura = 100
        for i=0,16,1 do
            if (DoesItemHaveDurability(BAG_WORN,i)) then
                minDura = math.min(minDura,GetItemCondition(BAG_WORN,i))
            end
        end
        self.data.minimumValue = minDura
        self.hasUpdate = true
        self:d(' => hasUpdate')
    end
end

-- LABEL HANDLER

function MOD:Update(options)
    self:d('Update')
    local labelText = ''
    if (self.data.minimumValue <= options.valueLowInfo) then
        if (self.data.minimumValue <= options.valueLowWarning) then
            labelText = MOD.Colorize(AE.const.COLOR_WARNING, GetString(SI_AWEMOD_DURABILITY_LABEL)) .. ': ' .. self.data.minimumValue .. '%'
        else
            labelText = MOD.Colorize(AE.const.COLOR_HINT, GetString(SI_AWEMOD_DURABILITY_LABEL)) .. ': ' .. self.data.minimumValue .. '%'
        end
        labelText = labelText .. ' (' .. self.data.repairCost .. 'g)'
    end
    self.labels[1]:SetText(labelText)
end -- MOD:Update