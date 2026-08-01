--[[
  This file is part of Awesome Events.

  Author: Ze_Mi
  Filename: ShadowySupplier.lua

  Copyright (c) 2018-2024 by Martin Unkel
  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  ]]

-- /script local a={}; a.name,_,_,_,_,a.purchased = GetSkillAbilityInfo(5,2,4); d(a)
local DARKBROTHERHOOD_SHADOWYSUPPLIER_ABILITYID = 77396
local DARKBROTHERHOOD_SHADOWYSUPPLIER_SKILLTYPE = SKILL_TYPE_GUILD --5
local DARKBROTHERHOOD_SHADOWYSUPPLIER_SKILLINDEX = 2
local DARKBROTHERHOOD_SHADOWYSUPPLIER_ABILITYINDEX = 4

local AE = Awesome_Events
local MOD = AE.module_factory({
    id = 'shadowysupplier',
    title = GetString(SI_AWEMOD_SHADOWYSUPPLIER),
    hint = GetString(SI_AWEMOD_SHADOWYSUPPLIER_HINT),
    order = 40,
    debug = false,

    options = {
        minutesLeftInfo = {
            type = 'slider',
            name = GetString(SI_AWEMOD_SHADOWYSUPPLIER_TIMER),
            tooltip = GetString(SI_AWEMOD_SHADOWYSUPPLIER_TIMER_HINT),
            min = 1,
            max = 1200,
            default = 480,
            order = 5,
        },
    }
})

-- OVERRIDES

function MOD:Enable(options)
    self:d('Enable (in debug-mode)')
    self.data = {
        hasAbility = false,
        availableAt = 0,
        minutesLeft = 9999,
        name = "Shadowy Supplier"
    }
    self:OnSkillAbilityProgressionUpdate()
    self.hasUpdate = true
end -- MOD:Enable

function MOD:Set(key, value)
    self:d('Set['..key..']', value)
    if (key=='minutesLeftInfo') then
        self:OnTimer(GetTimeStamp())
    end
end -- MOD:Set

-- EVENT LISTENER
function MOD:GetEventListeners()
    return {
        {
            eventCode = AE.const.EVENT_TIMER,
            callback = function (eventCode, timestamp)
                return MOD:OnTimer(timestamp)
            end,
        },
        {
            eventCode = EVENT_SKILL_ABILITY_PROGRESSIONS_UPDATED,
            callback = function (eventCode)
                self:d('EVENT_SKILL_ABILITY_PROGRESSIONS_UPDATED')
                MOD:OnSkillAbilityProgressionUpdate()
            end,
        },
        {
            eventCode = EVENT_CHATTER_END,
            callback = function (eventCode)
                if(self.data.hasAbility) then
                    self:d('EVENT_CHATTER_END')
                    MOD:OnSkillAbilityProgressionUpdate()
                end
            end,
        },
    }
end

-- EVENT HANDLER

function MOD:OnTimer(timestamp)
    self:d('OnTimer')

    if(not self.data.hasAbility) then
        return 0
    end

    if (self.data.availableAt > 0) then
        self.data.minutesLeft = math.ceil( GetDiffBetweenTimeStamps(self.data.availableAt, timestamp) / 60)
        self.hasUpdate = true
        self:d(' => hasUpdate')
    end

    if (self.data.availableAt == 0)then
        self:StopTimer()
    end
end

function MOD:OnSkillAbilityProgressionUpdate()
    self:d('OnSkillAbilityProgressionUpdate')
    local abilityName,_,_,_,_,abilityPurchased = GetSkillAbilityInfo(DARKBROTHERHOOD_SHADOWYSUPPLIER_SKILLTYPE,DARKBROTHERHOOD_SHADOWYSUPPLIER_SKILLINDEX,DARKBROTHERHOOD_SHADOWYSUPPLIER_ABILITYINDEX)

    self.data.name = abilityName
    self.data.hasAbility = abilityPurchased

    local timeRemaining = 0
    if(abilityPurchased) then
        self:d(' => enabled')
        timeRemaining = GetTimeToShadowyConnectionsResetInSeconds()
    else
        self:d(' => disabled')
    end

    if(timeRemaining>0) then
        local timestamp = GetTimeStamp()
        self.data.availableAt = timestamp + timeRemaining
        self.data.minutesLeft = math.ceil(timeRemaining / 60)
    else
        self.data.availableAt = 0
        self.data.minutesLeft = 0
    end

    self.hasUpdate = true
    self:d(' => hasUpdate')
end

-- LABEL HANDLER

function MOD:Update(options)
    self:d('Update')

    if(self.data.hasAbility) then
        self.labels[1]:SetText(self.FormatLabelText(self.data, options.minutesLeftInfo))
    else
        self.labels[1]:SetText("")
    end
end

function MOD.FormatLabelText(data, minutesLeftInfo)
    local text = ''
    if (data.minutesLeft <= minutesLeftInfo) then
        if (data.minutesLeft == 0) then
            text = MOD.Colorize(AE.const.COLOR_AVAILABLE, zo_strformat("<<C:1>>",data.name)) .. ': ' .. GetString(SI_AWEMOD_SHADOWYSUPPLIER_AVAILABLE_LABEL)
        else
            text = MOD.Colorize(AE.const.COLOR_HINT, zo_strformat("<<C:1>>",data.name)) .. ': ' .. FormatTimeSeconds(60 * data.minutesLeft, TIME_FORMAT_STYLE_DESCRIPTIVE_SHORT, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR, TIME_FORMAT_DIRECTION_NONE)
        end
    end
    return text
end