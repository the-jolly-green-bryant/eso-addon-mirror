--[[ 
    Author: @bluebuiy

    How to add a new buff

    1. Find the collectible id (https://esoitem.uesp.net/viewlog.php?record=collectibles) and add it to EBRAddon.collectible_table
    2. Add the event name to EBRAddon.setting_event_table
    3. Add the conversion from index to event name in EBRAddon.setting_event_index_converter
    4. Add the covnersion from event name to index in EBRAddon.setting_event_name_converter
    5. Find the abillity id. You can use /ebr_listbuffs or use the disabled code in the effect event callback.
    6. Add the ability id to EBRAddon.buffs

    Note that the indices elements appear in these tables all must match.  Except setting_event_table and buffs don't matter.

]]


EBRAddon = {}

EBRAddon.name = "EventBuffReminder"
EBRAddon.has_buff = false
EBRAddon.fragment = nil
EBRAddon.apply_buff_soon = false

-- =======================
--     Start data

EBRAddon.collectible_table = {
    [1] = 1167 -- jester's pie of misrule
    --[2] = 0 -- anniversary cake must be manually eaten
}

EBRAddon.setting_event_table = {
    "Jester",
    "Anniversary"
}

EBRAddon.setting_event_index_converter = {
    [1] = "Jester",
    [2] = "Anniversary"
}

EBRAddon.setting_event_name_converter = {
    ["Jester"] = 1,
    ["Anniversary"] = 2
}

EBRAddon.buffs = {
    [91369] = true, -- jester
    [152514] = true -- anniversary
}


--     End data
-- ========================





EBRAddon.SetAutoApplyOptionFunc = function(value)
    EBRAddon.saved_variables.AutoReapplyBuff = value
    if (value == true and EBRAddon.has_buff ~= true) then
        EBR_ShowRefreshControl() 
    end

    if (value == false and EBRAddon.has_buff ~= true and EBRAddon.saved_variables.ShowingAlert == false) then
        EBR_HideRefreshControl()
    end
end

EBRAddon.SetShowNotificationOptionFunc = function(value)
    EBRAddon.saved_variables.ShowingAlert = value

    if (value == true and EBRAddon.has_buff ~= true) then
        EBR_ShowRefreshControl()
    end

    if (value == false and (EBRAddon.saved_variables.AutoReapplyBuff == false or type(EBRAddon.collectible_table[EBRAddon.saved_variables.CurrentEvent]) == "number")) then
        EBR_HideRefreshControl()
    end

end

EBRAddon.CreateSettings = function()
    local LAM = LibAddonMenu2

    local panelData = {
        type = "panel",
        name = "Event Buff Reminder Settings",
        author = "@bluebuiy"
    }
    local panel = LAM:RegisterAddonPanel("EventBuffReminderPanel", panelData)
    

    local optionsData = {
        {
            type = "description",
            text = "Hover over each option for a description."
        },
        {
            type = "checkbox",
            name = "Auto-apply buff",
            tooltip = "If the addon should automatically reapply the buff.  If the buff cannot be applied automatically and this setting is on, a notification will ALWAYS show.",
            getFunc = function() return EBRAddon.saved_variables.AutoReapplyBuff end,
            setFunc = EBRAddon.SetAutoApplyOptionFunc,
            text = "Auto use the buff."
        },
        {
            type = "checkbox",
            name = "Show notification",
            tooltip = "If a buff that can be automatically reapplied should show a notification.",
            getFunc = function() return EBRAddon.saved_variables.ShowingAlert end,
            setFunc = EBRAddon.SetShowNotificationOptionFunc
        },
        {
            type = "dropdown",
            name = "Current Event",
            choices = EBRAddon.setting_event_table,
            getFunc = function() return EBRAddon.setting_event_index_converter[EBRAddon.saved_variables.CurrentEvent] end,
            setFunc = function(value) EBRAddon.saved_variables.CurrentEvent = EBRAddon.setting_event_name_converter[value] if (EBRAddon.has_buff ~= true) then EBR_ShowRefreshControl() end end,
            tooltip = "Set which event is currently active.  Unfortunately it's not possible to detect which event is currently running."
        },
        {
            type = "description",
            text = "If you like this addon, please consider donating gold or mats so I can continue to make addons instead of farm.  \nSincerely, @bluebuiy"
        }
    }

    LAM:RegisterOptionControls("EventBuffReminderPanel", optionsData)

end

function EBRAddon:OnAddOnLoaded(addonName)
    if addonName == EBRAddon.name then
        EBRAddon:Initialize()
    end
end

function EBR_ShowRefreshControl()
    local hasCollectible = type(EBRAddon.collectible_table[EBRAddon.saved_variables.CurrentEvent]) == "number"

    -- because we show the alert if the current event cannot be automatically reapplied, we have to check beforehand if we don't want to do anything.
    if (EBRAddon.saved_variables.AutoReapplyBuff == false and EBRAddon.saved_variables.ShowingAlert == false) then
        return
    end

    -- actually do something.
    if (EBRAddon.saved_variables.AutoReapplyBuff and hasCollectible) then
        UseCollectible(EBRAddon.collectible_table[EBRAddon.saved_variables.CurrentEvent])
        -- check the buff was actually applied
        zo_callLater(function()
            local buffPrescence = false
            for i = 1, GetNumBuffs("player") do
                local buffName, startTime, endTime, buffSlot, stackCount, iconFile, buffType, effectType, abilityType, statusEffectType, abilityId = GetUnitBuffInfo("player", i)
    
                if (EBRAddon.buffs[abilityId] == true) then
                    buffPrescence = true
                    break
                end
            end
            if (buffPrescence == false) then
                -- show the notification if we failed to apply the buff.
                -- only show this error notification if we want some kind of behavior, either showing notification or auto-reapply.
                if (EBRAddon.saved_variables.AutoReapplyBuff == true or EBRAddon.saved_variables.ShowingAlert == true) then
                    EventBuffReminderControl:SetHidden(false)
                    
                    SCENE_MANAGER:GetScene("hudui"):AddFragment(EBRAddon.fragment)
                    SCENE_MANAGER:GetScene("hud"):AddFragment(EBRAddon.fragment)
                end
            end
        end, 5000)
    else
        if (hasCollectible == false or EBRAddon.saved_variables.ShowingAlert) then
            EventBuffReminderControl:SetHidden(false)
            
            SCENE_MANAGER:GetScene("hudui"):AddFragment(EBRAddon.fragment)
            SCENE_MANAGER:GetScene("hud"):AddFragment(EBRAddon.fragment)
        end
    end
end

function EBR_HideRefreshControl()
    EventBuffReminderControl:SetHidden(true)
    
    SCENE_MANAGER:GetScene("hudui"):RemoveFragment(EBRAddon.fragment)
    SCENE_MANAGER:GetScene("hud"):RemoveFragment(EBRAddon.fragment)
end

EBRAddon.OnCombatState = function(event, inCombat)
    if (inCombat == false and EBRAddon.apply_buff_soon) then
        zo_callLater(EBR_ShowRefreshControl, 10)
        --EBR_ShowRefreshControl()
        EBRAddon.apply_buff_soon = false
    end
end

EBRAddon.OnEffectChange = function(event,  changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    
    if (false) then

        if (changeType == EFFECT_RESULT_FULL_REFRESH) then
            d("Refresh " .. effectName .. "(" .. abilityId .. ")")
        end

        if (changeType == EFFECT_RESULT_FADED) then
            d("Lost " .. effectName .. "(" .. abilityId .. ")")
        end

        if (changeType == EFFECT_RESULT_GAINED) then
            d("Gained " .. effectName .. "(" .. abilityId .. ")")
        end

        if (changeType == EFFECT_RESULT_UPDATED) then
            d("Updated " .. effectName .. "(" .. abilityId .. ")")
        end

    end

    if (unitTag ~= "player") then
        --d("Recieved non-player?")
        return
    end

    if (EBRAddon.buffs[abilityId] ~= true) then
        --d("Recieved non care ability?")
        return
    end
    
    if (changeType == EFFECT_RESULT_FADED) then
        EBRAddon.has_buff = false
        if (IsUnitInCombat("player")) then
            EBRAddon.apply_buff_soon = true
        else
            EBR_ShowRefreshControl()
        end
    end

    if (changeType == EFFECT_RESULT_GAINED) then
        EBR_HideRefreshControl()
    end

    if (changeType == EFFECT_RESULT_REFRESH) then
        EBRAddon.has_buff = true
    end

end

function EBRAddon:Initialize()


    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnCombatState)

    -- filters being weird. putting multiple filters on this event isn't working how I expect and how it's documented in esoui.  Just filtering to player for now then.
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_EFFECT_CHANGED, self.OnEffectChange)
    EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    --for i, k in ipairs(EBRAddon.buffs) do
    --    EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, i)
    --end

    EBRAddon.fragment = ZO_SimpleSceneFragment:New(EventBuffReminderControl)

    SLASH_COMMANDS["/ebr_listbuffs"] = function()
        for i = 1, GetNumBuffs("player") do
            local buffName, startTime, endTime, buffSlot, stackCount, iconFile, buffType, effectType, abilityType, statusEffectType, abilityId = GetUnitBuffInfo("player", i)

            d(buffName .. ": " .. abilityId)
        end
    end

    SLASH_COMMANDS["/ebr_manref"] = function()
        EBR_ShowRefreshControl()
    end

    SLASH_COMMANDS["/ebr_manhide"] = function()
        EBR_HideRefreshControl()
    end

    local defaults = {
        ShowingAlert = true,
        AutoReapplyBuff = false,
        BehaviorEnabled = true,
        CurrentEvent = 2
    }

    self.saved_variables = ZO_SavedVars:NewAccountWide("EventBuffReminderVariables", 1, nil, defaults)

    EBRAddon.has_buff = false

    EBR_HideRefreshControl()


    local f = function()

        -- get initial buff status, toggle alert if needed
        for i = 1, GetNumBuffs("player") do
            local buffName, startTime, endTime, buffSlot, stackCount, iconFile, buffType, effectType, abilityType, statusEffectType, abilityId = GetUnitBuffInfo("player", i)

            if (EBRAddon.buffs[abilityId] == true) then
                EBRAddon.has_buff = true
            end

        end

        if (EBRAddon.has_buff ~= true) then
            EBR_ShowRefreshControl()
        end
    end

    zo_callLater(f, 10)


    EBRAddon:CreateSettings()

end

EVENT_MANAGER:RegisterForEvent(EBRAddon.name, EVENT_ADD_ON_LOADED, EBRAddon.OnAddOnLoaded)


