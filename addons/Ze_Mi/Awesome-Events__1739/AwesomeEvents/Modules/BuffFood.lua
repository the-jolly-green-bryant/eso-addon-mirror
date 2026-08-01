--[[
  This file is part of Awesome Events.

  Author: Ze_Mi
  Filename: BuffFood.lua

  Copyright (c) 2017-2024 by Martin Unkel
  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  ]]

local HIDE_TIMEOUT_SECONDS = 300

local AE = Awesome_Events

local MOD = AE.module_factory({
    id = 'bufffood',
    title = GetString(SI_AWEMOD_BUFFFOOD),
    hint = GetString(SI_AWEMOD_BUFFFOOD_HINT),
    order = 30,
    debug = false,

    fontSize = 3,
    options = {
        minutesLeftInfo = {
            type = "slider",
            name = GetString(SI_AWEMOD_BUFFFOOD_TIMER),
            tooltip = GetString(SI_AWEMOD_BUFFFOOD_TIMER_HINT),
            min = 1,
            max = 480,
            default = 60,
            order = 1,
        },
        blinkInCombat = {
            type = "checkbox",
            name = GetString(SI_AWEMOD_BUFFFOOD_BLINKINCOMBAT),
            tooltip = GetString(SI_AWEMOD_BUFFFOOD_BLINKINCOMBAT_HINT),
            default = true,
            order = 2,
        },
        hideNoBuffNoCombat = {
            type = "checkbox",
            name = GetString(SI_AWEMOD_BUFFFOOD_HIDENOCOMBAT),
            tooltip = GetString(SI_AWEMOD_BUFFFOOD_HIDENOCOMBAT_HINT),
            default = false,
            order = 2,
        }
    }
})

-- OVERRIDES

function MOD:Enable(options)
    self:d('Enable (in debug-mode)')
    self.data = {
        availableAt = 1, --OnTimer event lazy call to OnEffectChanged
        minutesLeft = 0,
        buffName = 'Unknown',
        inCombat = false,
        blinkInCombat = options.blinkInCombat,
        blinkColor = AE.const.COLOR_WARNING,
        hideAt = GetTimeStamp() + HIDE_TIMEOUT_SECONDS,
    }
    self.hasUpdate = true
end

function MOD:Set(key, value)
    self:d('Set[' .. key .. ']', value)

    if (key == 'blinkInCombat') then
        self.data.blinkInCombat = value
    end
    self.hasUpdate = true
end

-- EVENT LISTENER

local function __isFoodBuff(abilityId)
    if (LibFoodDrinkBuff) then
        return LibFoodDrinkBuff:IsAbilityADrinkBuff(abilityId) ~= nil
    else
        MOD:d("LibFoodDrinkBuff not available, use primitive detection")
        local foodAbilityIds = {
            [17407] = 1, [17577] = 1, [17581] = 1, [17608] = 1, [17614] = 1, [61218] = 1, [61255] = 1, [61257] = 1, [61259] = 1, [61260] = 1,
            [61261] = 1, [61294] = 1, [61322] = 1, [61325] = 1, [61328] = 1, [61335] = 1, [61340] = 1, [61345] = 1, [61350] = 1, [66125] = 1,
            [66128] = 1, [66130] = 1, [66132] = 1, [66137] = 1, [66141] = 1, [66551] = 1, [66568] = 1, [66576] = 1, [66586] = 1, [66590] = 1,
            [66594] = 1, [68411] = 1, [68416] = 1, [72816] = 1, [72819] = 1, [72822] = 1, [72824] = 1, [72956] = 1, [72959] = 1, [72961] = 1,
            [72965] = 1, [72968] = 1, [72971] = 1, [84678] = 1, [84681] = 1, [84700] = 1, [84704] = 1, [84709] = 1, [84720] = 1, [84725] = 1,
            [84731] = 1, [84735] = 1, [85484] = 1, [85497] = 1, [86559] = 1, [86673] = 1, [86677] = 1, [86746] = 1, [86749] = 1, [86787] = 1,
            [86789] = 1, [86791] = 1, [89955] = 1, [89957] = 1, [89971] = 1, [92433] = 1, [92435] = 1, [92474] = 1, [92476] = 1
        }
        return foodAbilityIds[abilityId] ~= nil
    end
end -- MOD:isFoodBuff

-- EVENT LISTENER

-- EVENT_EFFECT_CHANGED (integer eventCode, integer changeType, integer effectSlot, string effectName, string unitTag, number beginTime, number endTime, integer stackCount, string iconName, string buffType, integer effectType, integer abilityType, integer statusEffectType, string unitName, integer unitId, integer abilityId, integer sourceUnitType)

function MOD:GetEventListeners()
    return {
        {
            eventCode = AE.const.EVENT_TIMER,
            callback = function(eventCode, timestamp)
                return MOD:OnTimer(timestamp)
            end,
        },
        {
            eventCode = EVENT_EFFECT_CHANGED,
            callback = function(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceUnitType)
                if (sourceUnitType == COMBAT_UNIT_TYPE_PLAYER and effectType == BUFF_EFFECT_TYPE_BUFF and statusEffectType == STATUS_EFFECT_TYPE_NONE) then
                    MOD:OnEffectChanged(abilityId, changeType, effectName, endTime)
                end
            end,
        },
        {
            eventCode = EVENT_PLAYER_COMBAT_STATE,
            callback = function(eventCode, inCombat)
                MOD:OnCombatStateChanged(inCombat)
            end,
        }
    }
end

-- EVENT HANDLER

function MOD:OnTimer(timestamp)
    self:d('OnTimer')
    -- has effect
    if (self.data.availableAt > 0) then
        if (timestamp > self.data.availableAt) then
            self:OnEffectChanged()
        else
            self:d(self.data.availableAt, timestamp)
            self.data.minutesLeft = math.floor(GetDiffBetweenTimeStamps(self.data.availableAt, timestamp) / 60)
            self.hasUpdate = true
            self:d(' => hasUpdate')
        end
        return
    end

    -- has no effect, but in combat
    if (self.data.inCombat) then
        if (self.data.blinkInCombat) then
            self.data.blinkColor = (self.data.blinkColor == AE.const.COLOR_WARNING) and AE.const.COLOR_HINT or AE.const.COLOR_WARNING
            self.hasUpdate = true
            self:d(' => hasUpdate (combat)')
            return 1
        end
        -- has no effect and not in combat
    else
        self.hasUpdate = true
        self:d(' => hasUpdate (no-combat)')
        if (timestamp < self.data.hideAt) then
            return (self.data.hideAt - timestamp)
        else
            self.data.hideAt = 0
            return 0
        end
    end
    return 0
end -- MOD:OnTimer

function MOD:OnEffectChanged(abilityId, changeType, effectName, endTime)
    self:d('OnEffectChanged')

    -- single effect update
    if (abilityId ~= nil) then
        if (__isFoodBuff(abilityId)) then
            if (changeType == EFFECT_RESULT_FADED) then
                self.data.buffName = ''
                self.data.availableAt = 0
                self.data.minutesLeft = 0
                self.hasUpdate = true
                self:d(' => hasUpdate (faded)')
                return
            end
            if (changeType == EFFECT_RESULT_GAINED) then
                local secondsLeft = math.ceil(endTime - GetFrameTimeSeconds())
                self.data.buffName = effectName
                self.data.availableAt = GetTimeStamp() + secondsLeft
                self.data.minutesLeft = math.floor(secondsLeft / 60)
                self:StartTimer(1, true)
                self.hasUpdate = true
                self:d(' => hasUpdate (gained)')
                return
            end
        end

        -- scan all buffs for food-buffs
    else
        local numBuffs = GetNumBuffs('player')
        self:d('numBuffs: ' .. numBuffs);
        for i = 1, numBuffs do
            --local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer
            local buffName, _, timeEnding, _, _, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo('player', i)
            local isFoodBuff = __isFoodBuff(abilityId);
            self:d(buffName .. (isFoodBuff and ' is a foodbuff' or ' is not a foodbuff') .. ' ' .. abilityId)
            if (isFoodBuff) then
                local secondsLeft = math.ceil(timeEnding - GetFrameTimeSeconds())
                self.data.buffName = buffName
                self.data.availableAt = GetTimeStamp() + secondsLeft
                self.data.minutesLeft = math.floor(secondsLeft / 60)
                self:StartTimer(1, true)
                self.hasUpdate = true
                self:d(' => hasUpdate (found a buff)')
                return
            end
        end

        if (self.data.minutesLeft > 0 or self.data.buffName ~= '') then
            self.hasUpdate = true
            self:d(' => hasUpdate (no buff)')
        end
        self.data.availableAt = 0
        self.data.buffName = ''
        self.data.minutesLeft = 0
    end
end -- MOD:OnEffectChanged

function MOD:OnCombatStateChanged(inCombat)
    self:d('OnCombatStateChanged', inCombat)
    self.data.inCombat = inCombat
    if (self.data.minutesLeft == 0) then
        self.data.blinkColor = AE.const.COLOR_WARNING
        if (not inCombat) then
            self.data.hideAt = GetTimeStamp() + HIDE_TIMEOUT_SECONDS
        end
        self:StartTimer(1, true)
    end
end -- MOD:OnCombatStateChanged

-- LABEL HANDLER

function MOD:Update(options)
    self:d('Update')
    local labelText = ''
    if (self.data.minutesLeft > 0) then
        if (self.data.minutesLeft <= options.minutesLeftInfo) then
            labelText = MOD.Colorize(AE.const.COLOR_HINT, zo_strformat(SI_AWEMOD_BUFFFOOD_TIMER_LABEL, self.data.buffName)) .. ': ' .. FormatTimeSeconds(60 * self.data.minutesLeft, TIME_FORMAT_STYLE_DESCRIPTIVE_SHORT, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR, TIME_FORMAT_DIRECTION_NONE)
        else
            labelText = ''
        end
    elseif (options.blinkInCombat and self.data.inCombat) then
        labelText = '|t64:64:EsoUI/Art/treeicons/provisioner_indexicon_stew_down.dds|t ' .. MOD.Colorize(self.data.blinkColor, GetString(SI_AWEMOD_BUFFFOOD_READY_LABEL))
    elseif (not options.hideNoBuffNoCombat or self.data.hideAt > 0) then
        labelText = MOD.Colorize(AE.const.COLOR_WARNING, GetString(SI_AWEMOD_BUFFFOOD_READY_LABEL))
    end
    self.labels[1]:SetText(labelText)
end -- MOD:Update