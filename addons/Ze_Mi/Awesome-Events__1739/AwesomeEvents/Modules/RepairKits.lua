--[[
  This file is part of Awesome Events.

  Author: Ze_Mi
  Filename: RepairKits.lua

  Copyright (c) 2017-2024 by Martin Unkel
  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  ]]

local AE = Awesome_Events
local MOD = AE.module_factory({
    id = 'repairkits',
    title = GetString(SI_AWEMOD_REPAIRKITS),
    hint = GetString(SI_AWEMOD_REPAIRKITS_HINT),
    order = 65,
    debug = false
})

-- MOD FUNCTIONS

function MOD:ScanBag(bagId)
    for slotId=1,GetBagSize(bagId) do
        if IsItemRepairKit(bagId,slotId) then
            local _,stackCount = GetItemInfo(bagId,slotId)
            local tier = GetRepairKitTier(bagId,slotId)
            self.data.details[tier] = (self.data.details[tier]==nil) and stackCount or self.data.details[tier] + stackCount
            self.data.count = self.data.count + stackCount
        end
    end
end

-- OVERRIDES

function MOD:Enable(options)
    self:d('Enable (in debug-mode)')
    self.data = {
        count = 0,
        details = {}
    }
    self:ScanBag(BAG_BACKPACK)
    self:ScanBag(BAG_VIRTUAL)
    self.hasUpdate = true
end -- MOD:Enable

-- EVENT LISTENER

function MOD:GetEventListeners()
    return {
        {
            eventCode = EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
            callback = function(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
                if( (bagId == BAG_BACKPACK or bagId == BAG_VIRTUAL) and IsItemRepairKit(bagId,slotId))then
                    self:d('EVENT_INVENTORY_SINGLE_SLOT_UPDATE',self.data.count,stackCountChange)
                    self.data.count = self.data.count + stackCountChange
                    self.hasUpdate = true
                end
            end
        },
    }
end -- MOD:GetEventListeners

-- EVENT HANDLER

-- LABEL HANDLER


function MOD:Update(options)
    self:d('Update')
    self.labels[1]:SetText(MOD.Colorize(AE.const.COLOR_AVAILABLE, zo_strformat(SI_AWEMOD_REPAIRKITS_LABEL, self.data.count)))
end -- MOD:Update