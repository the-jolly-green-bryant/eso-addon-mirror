--[[
  This file is part of Awesome Events.

  Author: Ze_Mi
  Filename: Mount.lua

  Copyright (c) 2017-2024 by Martin Unkel
  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  ]]

local AE = Awesome_Events
local MOD = AE.module_factory({
    id = 'mount',
    title = GetString(SI_AWEMOD_MOUNT),
    hint = GetString(SI_AWEMOD_MOUNT_HINT),
    order = 30,
    debug = false,

    options = {
        minutesLeftInfo = {
            type = "slider",
            name = GetString(SI_AWEMOD_MOUNT_TIMER),
            tooltip = GetString(SI_AWEMOD_MOUNT_TIMER_HINT),
            min  = 1,
            max = 960,
            default = 480,
            order = 1,
        },
    }
})

-- OVERRIDES

function MOD:Enable(options)
    self:d('Enable (in debug-mode)')
    self.data = {
        hasTrainableMount = false,
        availableAt = 1,
        minutesLeft = 0
    }
    self.hasUpdate = true
end

-- EVENT LISTENER

-- EVENT_ACTIVE_MOUNT_CHANGED (number eventCode)
-- EVENT_RIDING_SKILL_IMPROVEMENT (integer eventCode,number ridingSkillType, number previous, number current, number source)
-- EVENT_STABLE_INTERACT_END (number eventCode)
-- EVENT_MOUNT_INFO_UPDATED (number eventCode)
function MOD:GetEventListeners()
    return {
        {
            eventCode = AE.const.EVENT_TIMER,
            callback = function(eventCode, timestamp) return MOD:OnTimer(timestamp) end,
        },
        {
            eventCode = EVENT_RIDING_SKILL_IMPROVEMENT,
            callback = function(eventCode, ridingSkillType, previous, current, source) MOD:OnRidingSkillImprovement() end,
        },
    }
end

-- EVENT HANDLER

function MOD:OnTimer(timestamp)
    self:d('OnTimer')
    if(self.data.availableAt > 0)then
        if(timestamp >  self.data.availableAt)then
            self:OnRidingSkillImprovement()
            return
        else
            self.data.minutesLeft = math.ceil( GetDiffBetweenTimeStamps(self.data.availableAt, timestamp) / 60)
            self.hasUpdate = true
            self:d(' => hasUpdate')
        end
    else
        self:StopTimer()
    end
end


function MOD:OnRidingSkillImprovement()
    self:d('OnRidingSkillImprovement')
    self.data.availableAt = 0
    self.data.minutesLeft = 0
    local availableAt = GetTimeUntilCanBeTrained()
    -- char has no mount
    if(availableAt == nil) then
        self.data.hasTrainableMount = false
    else
        local inventoryBonus, maxInventoryBonus, staminaBonus, maxStaminaBonus, speedBonus, maxSpeedBonus = GetRidingStats()
        self.data.hasTrainableMount = not((inventoryBonus == maxInventoryBonus) and (staminaBonus == maxStaminaBonus) and (speedBonus == maxSpeedBonus))

        if(self.data.hasTrainableMount and availableAt>0) then
            self.data.availableAt = GetTimeStamp() + (availableAt / 1000)
            self.data.minutesLeft = math.ceil( (availableAt / 1000) / 60)
            self:StartTimer()
        end
    end

    self.hasUpdate = true
    self:d(' => hasUpdate')
end -- MOD:OnFenceUpdate

-- LABEL HANDLER

function MOD:Update(options)
    self:d('Update')
    local labelText = ''
    if (self.data.hasTrainableMount) then
        if(self.data.availableAt > 0) then
            if(self.data.minutesLeft <= options.minutesLeftInfo) then
                labelText =MOD.Colorize(AE.const.COLOR_HINT, GetString(SI_AWEMOD_MOUNT_TIMER_LABEL)) .. ': ' .. FormatTimeSeconds(60 * self.data.minutesLeft, TIME_FORMAT_STYLE_DESCRIPTIVE_SHORT , TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR , TIME_FORMAT_DIRECTION_NONE)
            end
        else
            labelText = MOD.Colorize(AE.const.COLOR_AVAILABLE, GetString(SI_AWEMOD_MOUNT_READY_LABEL))
        end
    end
    self.labels[1]:SetText(labelText)
end -- MOD:Update