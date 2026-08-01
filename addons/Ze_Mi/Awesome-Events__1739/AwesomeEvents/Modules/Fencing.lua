--[[
  This file is part of Awesome Events.

  Author: Ze_Mi
  Filename: Fencing.lua

  Copyright (c) 2017-2024 by Martin Unkel
  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  ]]

local AE = Awesome_Events
local MOD = AE.module_factory({
    id = 'fencing',
    title = GetString(SI_AWEMOD_FENCING),
    hint = GetString(SI_AWEMOD_FENCING_HINT),
    order = 45,
    debug = false,

    options = {
        showSellsLeft = {
            type = 'checkbox',
            name = GetString(SI_AWEMOD_FENCING_SELLS),
            tooltip = GetString(SI_AWEMOD_FENCING_SELLS_HINT),
            default = true,
            order = 1,
        },
        sellsLeftInfo = {
            type = 'slider',
            name = GetString(SI_AWEMOD_FENCING_SELLS_INFO),
            tooltip = GetString(SI_AWEMOD_FENCING_SELLS_INFO_HINT),
            min  = 0,
            max = 50,
            default = 30,
            order = 2,
        },
        sellsLeftWarning = {
            type = 'slider',
            name = GetString(SI_AWEMOD_FENCING_SELLS_WARNING),
            tooltip = GetString(SI_AWEMOD_FENCING_SELLS_WARNING_HINT),
            min  = 0,
            max = 50,
            default = 10,
            order = 3,
        },
        showLaundersLeft = {
            type = 'checkbox',
            name = GetString(SI_AWEMOD_FENCING_LAUNDERS),
            tooltip = GetString(SI_AWEMOD_FENCING_LAUNDERS_HINT),
            default = true,
            order = 4,
        },
        laundersLeftInfo = {
            type = 'slider',
            name = GetString(SI_AWEMOD_FENCING_LAUNDERS_INFO),
            tooltip = GetString(SI_AWEMOD_FENCING_LAUNDERS_INFO_HINT),
            min  = 0,
            max = 50,
            default = 30,
            order = 5,
        },
        laundersLeftWarning = {
            type = 'slider',
            name = GetString(SI_AWEMOD_FENCING_LAUNDERS_WARNING),
            tooltip = GetString(SI_AWEMOD_FENCING_LAUNDERS_WARNING_HINT),
            min  = 0,
            max = 50,
            default = 10,
            order = 6,
        },
    }
})

-- OVERRIDES

function MOD:Enable(options)
    self:d('Enable (in debug-mode)')
    self.data = {
        fenceOpened = false,
        sells = { total = 0, left = 0, resetAt = 1, minutesLeft = 0, name = GetString(SI_AWEMOD_FENCING_SELLS_LABEL) },
        launders = { total = 0, left = 0, resetAt = 1, minutesLeft = 0, name = GetString(SI_AWEMOD_FENCING_LAUNDERS_LABEL) }
    }
    self.hasUpdate = true
end

-- EVENT LISTENER

function MOD:GetEventListeners()
    return {
        {
            eventCode = AE.const.EVENT_TIMER,
            callback = function(eventCode, timestamp) return MOD:OnTimer(timestamp) end,
        },
        {
            eventCode = EVENT_OPEN_FENCE,
            callback = function(eventCode,allowSell,allowLaunder) MOD.data.fenceOpened = true end,
        },
        {
            eventCode = EVENT_CLOSE_STORE,
            callback = function(eventCode) if(MOD.data.fenceOpened)then MOD:OnCloseStore(GetTimeStamp()) end end,
        },
    }
end

-- EVENT HANDLER

function MOD:OnTimer(timestamp)
    self:d('OnTimer')
    if(self.data.sells.left == 0 and self.data.sells.resetAt > 0)then
        if(timestamp >  self.data.sells.resetAt)then
            self:OnCloseStore(timestamp)
            return
        else
            self.data.sells.minutesLeft = math.ceil( GetDiffBetweenTimeStamps(self.data.sells.resetAt, timestamp) / 60)
            self.hasUpdate = true
            self:d(' => hasUpdate')
        end
    end

    if(self.data.launders.left == 0 and self.data.launders.resetAt > 0)then
        if(timestamp >  self.data.launders.resetAt)then
            self:OnCloseStore(timestamp)
            return
        else
            self.data.launders.minutesLeft = math.ceil( GetDiffBetweenTimeStamps(self.data.launders.resetAt, timestamp) / 60)
            self.hasUpdate = true
            self:d(' => hasUpdate')
        end
    end

    if(self.data.sells.left > 0 and self.data.launders.left > 0)then
        self.hasUpdate = true
        return 0
    end
end


function MOD:OnCloseStore(timestamp)
    self:d('OnCloseStore')
    self.data.fenceOpened = false
    local used, resetSeconds

    self.data.sells.total, used, resetSeconds = GetFenceSellTransactionInfo()
    self.data.sells.left = self.data.sells.total - used
    if(self.data.sells.left == 0)then
        self.data.sells.resetAt = timestamp + resetSeconds
        self.data.sells.minutesLeft = math.ceil(resetSeconds / 60)
        self:StartTimer()
    else
        self.data.sells.resetAt = 0
        self.data.sells.minutesLeft = 0
    end


    self.data.launders.total, used, resetSeconds = GetFenceLaunderTransactionInfo()
    self.data.launders.left = self.data.launders.total - used
    if(self.data.launders.left == 0)then
        self.data.launders.resetAt = timestamp + resetSeconds
        self.data.launders.minutesLeft = math.ceil(resetSeconds / 60)
        self:StartTimer()
    else
        self.data.launders.resetAt = 0
        self.data.launders.minutesLeft = 0
    end

    self.hasUpdate = true
    self:d(' => hasUpdate')
end -- MOD:OnFenceUpdate

-- LABEL HANDLER

function MOD:Update(options)
    self:d('Update',options,self.data.sells)
    local labelText = ''

    -- show only one timer if both would show up
    if(options.showSellsLeft and self.data.sells.left == 0 and options.showLaundersLeft and self.data.launders.left == 0)then
        self.labels[1]:SetText(
            MOD.Colorize(AE.const.COLOR_HINT, GetString(SI_AWEMOD_FENCING_SELLS_LABEL) .. ' & ' .. GetString(SI_AWEMOD_FENCING_LAUNDERS_LABEL)) .. ': ' .. FormatTimeSeconds(60 * self.data.sells.minutesLeft, TIME_FORMAT_STYLE_DESCRIPTIVE_SHORT , TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR , TIME_FORMAT_DIRECTION_NONE)
        )
        return
    end

    -- show sells
    if (options.showSellsLeft and self.data.sells.left <= options.sellsLeftInfo) then
        if(self.data.sells.left == 0)then
            labelText = MOD.Colorize(AE.const.COLOR_HINT, GetString(SI_AWEMOD_FENCING_SELLS_LABEL)) .. ': ' .. FormatTimeSeconds(60 * self.data.sells.minutesLeft, TIME_FORMAT_STYLE_DESCRIPTIVE_SHORT , TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR , TIME_FORMAT_DIRECTION_NONE)
        else
            local color = (self.data.sells.left <= options.sellsLeftWarning) and AE.const.COLOR_WARNING or AE.const.COLOR_HINT
            labelText = MOD.Colorize(color, GetString(SI_AWEMOD_FENCING_SELLS_LABEL)) .. ': ' .. self.data.sells.left
        end
    end

    -- show launders
    if (options.showLaundersLeft and self.data.launders.left <= options.laundersLeftInfo) then
        if (labelText ~= '') then labelText = labelText .. MOD.Colorize(AE.const.COLOR_HINT, ' || ') end
        if(self.data.launders.left == 0)then
            labelText = labelText .. MOD.Colorize(AE.const.COLOR_HINT, GetString(SI_AWEMOD_FENCING_LAUNDERS_LABEL)) .. ': ' .. FormatTimeSeconds(60 * self.data.launders.minutesLeft, TIME_FORMAT_STYLE_DESCRIPTIVE_SHORT , TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR , TIME_FORMAT_DIRECTION_NONE)
        else
            local color = (self.data.launders.left <= options.laundersLeftWarning) and AE.const.COLOR_WARNING or AE.const.COLOR_HINT
            labelText = labelText .. MOD.Colorize(color, GetString(SI_AWEMOD_FENCING_LAUNDERS_LABEL)) .. ': ' .. self.data.launders.left
        end
    end
    self.labels[1]:SetText(labelText)
end -- MOD:Update