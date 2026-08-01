--[[
  This file is part of Awesome Events.

  Author: Ze_Mi
  Filename: core.lua

  Copyright (c) 2018-2024 by Martin Unkel
  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  ]]
local AE = Awesome_Events

local core = {
    modules = {},
    labelToMod = {}
}

local __labelIndex = 3 -- synchronous to ui-child-index
local function __getNextLabelId()
    local id = __labelIndex
    __labelIndex = id + 1
    return id
end

local function sort(options)
    local orderToKeyMap, orderedNumbers, orderedIndex = {}, {}, {}
    for key, option in pairs(options) do
        local order = (option.order or 40) * 100
        while (orderToKeyMap[order] ~= nil) do
            order = order + 1
        end
        orderToKeyMap[order] = key
        table.insert(orderedNumbers, order)
    end
    table.sort(orderedNumbers)
    for i, order in ipairs(orderedNumbers) do
        table.insert(orderedIndex, orderToKeyMap[order])
    end
    return orderedIndex
end

local function sorted_iterator(t, state)

    -- Equivalent of the next function, but returns the keys in the alphabetic order
    local key = nil
    --d("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        for i = 1, table.getn(t.__orderedIndex) do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i + 1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

core.pairs = function(items)
    if (items == nil) then
        AE.logging.d("Empty list for pairs")
        return nil, nil, nil
    end

    if (items.__orderedIndex == nil) then
        items.__orderedIndex = sort(items)
    end
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return sorted_iterator, items, nil
end

local function loadDefaults(defaults)
    for mod_id, mod in AE.core.pairs(AE.core.modules) do
        local default = {
            enabled = true,
            spacingPosition = mod.spacingPosition or TEXT_ALIGN_BOTTOM,
            spacing = mod.spacing or 5,
            fontSize = mod.fontSize or 1
        }
        for key, value in pairs(mod.options) do
            default[key] = value.default
        end

        defaults[mod_id] = default
    end
end

local function reloadModules(templateName, parentControl, previousControl)
    local _previousControl = previousControl

    if (__labelIndex == 3) then
        AE.logging.d('core', 'Create Labels')
        -- create labels and preload data
        for mod_id, mod in AE.core.pairs(AE.core.modules) do
            -- create labels
            for i, _label in ipairs(mod.labels) do
                local labelId = __getNextLabelId()
                core.labelToMod[labelId] = mod_id

                local label = CreateControlFromVirtual(templateName, parentControl, templateName, labelId)
                label:SetAnchor(TOP, _previousControl, BOTTOM, 0, 0)

                mod.labels[i] = label
                _previousControl = label
            end
        end
    end

    -- restore config
    for mod_id, mod in pairs(core.modules) do
        if (mod.active) then
            mod:Disable()
            mod.active = false
        end
        if (AE.vars[mod_id].enabled) then
            mod.active = true
            mod:Enable(AE.vars[mod_id])
        end
    end

    CALLBACK_MANAGER:FireCallbacks(AE.const.CALLBACK_CORE)
end

CALLBACK_MANAGER:RegisterCallback(AE.const.CALLBACK_VARS_DEFAULTS, loadDefaults)
CALLBACK_MANAGER:RegisterCallback(AE.const.CALLBACK_UI_PRE, reloadModules)

AE.core = core