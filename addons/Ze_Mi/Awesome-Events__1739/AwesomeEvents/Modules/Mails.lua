--[[
  This file is part of Awesome Events.

  Author: Ze_Mi
  Filename: Mails.lua

  Copyright (c) 2017-2024 by Martin Unkel
  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  ]]

local AE = Awesome_Events
local MOD = AE.module_factory({
    id = 'mails',
    title = GetString(SI_AWEMOD_MAILS),
    hint = GetString(SI_AWEMOD_MAILS_HINT),
    order = 15,
    debug = false
})

-- OVERRIDES

function MOD:Enable(options)
    self:d('Enable (in debug-mode)')
    self.data = {
        numUnread = 0,
    }
    self:OnMailNumUnreadChanged(GetNumUnreadMail())
    self.hasUpdate = true
end

-- EVENT LISTENER

function MOD:GetEventListeners()
    return {
        {
            eventCode = EVENT_MAIL_NUM_UNREAD_CHANGED,
            callback = function(eventCode,numUnread) MOD:OnMailNumUnreadChanged(numUnread) end
        }
    }
end

-- EVENT HANDLER

function MOD:OnMailNumUnreadChanged(numUnread)
    self:d('OnMailNumUnreadChanged ' .. numUnread)
    if( numUnread ~= self.data.numUnread ) then
        self.data.numUnread = numUnread
        self.hasUpdate = true
        self:d(' => hasUpdate')
    end
end

-- LABEL HANDLER

function MOD:Update(options)
    self:d('Update')
    local labelText = ''
    if (self.data.numUnread > 0) then
        labelText = MOD.Colorize(AE.const.COLOR_AVAILABLE, GetString(SI_AWEMOD_MAILS_LABEL)) .. ': ' .. self.data.numUnread
    end
    self.labels[1]:SetText(labelText)
end -- MOD:Update