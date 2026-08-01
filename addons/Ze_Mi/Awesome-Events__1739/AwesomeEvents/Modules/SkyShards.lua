--[[
  This file is part of Awesome Events.

  Author: Ze_Mi
  Filename: SkyShards.lua

  Copyright (c) 2017-2024 by Martin Unkel
  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  ]]

local AE = Awesome_Events
local MOD = AE.module_factory({
    id = 'skyshards',
    title = GetString(SI_AWEMOD_SKYSHARDS),
    hint = GetString(SI_AWEMOD_SKYSHARDS_HINT),
    order = 25,
    debug = false,

    options = {
        shardsLeftInfo = {
            type = 'slider',
            name = GetString(SI_AWEMOD_SKYSHARDS_REMAINING),
            tooltip = GetString(SI_AWEMOD_SKYSHARDS_REMAINING_HINT),
            min  = 1,
            max = 3,
            default = 1,
            order = 1,
        },
    }
})

-- OVERRIDES

function MOD:Enable(options)
    self:d('Enable (in debug-mode)')
    self.data = {
        shardsLeft = 0,
    }
    self:OnAchievementUpdate(0)
    self.hasUpdate = true
end

-- EVENT LISTENER

function MOD:GetEventListeners()
    return {
        {
            eventCode = EVENT_ACHIEVEMENT_UPDATED,
            callback = function(eventCode,id) MOD:OnAchievementUpdate(id) end
        }
    }
end

-- EVENT HANDLER

function MOD:OnAchievementUpdate(id)
    self:d('OnAchievementUpdate ' .. id)
    local shardsLeft = 3-GetNumSkyShards()
    if( shardsLeft ~= self.data.shardsLeft ) then
        self.data.shardsLeft = shardsLeft
        self.hasUpdate = true
        self:d(' => hasUpdate')
    end
end

-- LABEL HANDLER

function MOD:Update(options)
    self:d('Update')
    local labelText = ''
    if (self.data.shardsLeft <= options.shardsLeftInfo) then
        local color = (self.data.shardsLeft == 1) and AE.const.COLOR_AVAILABLE or AE.const.COLOR_HINT
        labelText = MOD.Colorize(color, GetString(SI_AWEMOD_SKYSHARDS_REMAINING_LABEL)) .. ': ' .. self.data.shardsLeft
    end
    self.labels[1]:SetText(labelText)
end -- MOD:Update