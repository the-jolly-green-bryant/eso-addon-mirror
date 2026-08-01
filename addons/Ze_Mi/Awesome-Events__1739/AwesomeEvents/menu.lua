--[[
  This file is part of Awesome Events.

  Author: Ze_Mi
  Filename: menu.lua

  Copyright (c) 2018-2024 by Martin Unkel
  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  ]]

local AE = Awesome_Events

local __importFromCharacterName = ""

--- create a getFcn function callback for LAM panelOptions
local function __get(mod_id, key, transformer)
    if (AE.core.modules[mod_id] == nil) then
        return
    end
    local mod = AE.core.modules[mod_id]
    if (key == 'spacingPosition') then
        return function()
            return AE.GetSpacingPositionString(AE.vars[mod_id][key])
        end
    else
        if (transformer ~= nil) then
            return function()
                return transformer(AE.vars[mod_id][key])
            end
        else
            return function()
                return AE.vars[mod_id][key]
            end
        end
    end
end -- __get

--- create a setFcn function callback for LAM panelOptions
local function __set(mod_id, key, transformer)
    if (AE.core.modules[mod_id] == nil) then
        return
    end
    local mod = AE.core.modules[mod_id]
    if (key == 'enabled') then
        return function(value)
            AE.vars[mod.id][key] = value
            if (value) then
                mod.active = true
                AE.logging.d('menu', 'Enable[' .. mod_id .. ']')
                mod:Enable(AE.vars[mod_id])
            else
                AE.logging.d('menu', 'Disable[' .. mod_id .. ']')
                mod:Disable()
                mod.active = false
            end
            CALLBACK_MANAGER:FireCallbacks(AE.const.CALLBACK_CORE)
            AE.ui.UpdateViewSize()
        end
    elseif (key == 'spacingPosition') then
        return function(value)
            AE.vars[mod_id].spacingPosition = AE.GetSpacingPosition(value)
            AE.ui.UpdateViewSize()
        end
    elseif (key == 'spacing') then
        return function(value)
            AE.vars[mod_id][key] = value
            AE.ui.UpdateViewSize()
        end
    elseif (key == 'fontSize') then
        return function(value)
            AE.vars[mod_id][key] = value
            AE.ui.UpdateFontSize()
            AE.ui.UpdateViewSize()
        end
    end
    return function(value)
        if (transformer ~= nil) then
            value = transformer(value)
        end
        AE.vars[mod_id][key] = value
        AE.logging.d('menu', 'Set[' .. mod_id .. ']: ' .. key, value)
        mod:Set(key, value)
    end
end -- __set

--- create a disabled function callback for LAM panelOptions
local function __disable(mod_id, key)
    return function()
        return not (AE.vars[mod_id][key])
    end
end -- __disable


--- load module configuration and inject getter/setter, build default configuration
local function buildModulesConfiguration()
    -- load characters for copy button
    local importOptions = { GetString(SI_AWEVS_IMPORT_CHARACTER_SELECT) }
    for i = 1, GetNumCharacters() do
        local name, _, _, _, _, _, characterId = GetCharacterInfo(i)
        if (characterId ~= GetCurrentCharacterId()) then
            table.insert(importOptions, zo_strformat("<<1>>", name))
        end
    end

    local panelOptions = {
        {
            type = 'description',
            text = GetString(SI_AWEVS_DESCRIPTION),
        },
        {
            type = 'header',
            name = '|c45D7F7' .. GetString(SI_AWEVS_APPEARANCE) .. '|r',
        },
        {
            type = 'checkbox',
            name = GetString(SI_AWEVS_APPEARANCE_MOVABLE),
            tooltip = GetString(SI_AWEVS_APPEARANCE_MOVABLE_HINT),
            getFunc = function()
                return AE.vars.window.movable
            end,
            setFunc = function(newValue)
                AE.vars.window.movable = newValue
                AE.ui.SetMovable()
            end,
            default = AE.vars.default.window.movable,
        },
        {
            type = 'dropdown',
            name = GetString(SI_AWEVS_APPEARANCE_TEXTALIGN),
            tooltip = GetString(SI_AWEVS_APPEARANCE_TEXTALIGN_HINT),
            choices = { GetString(SI_AWEVS_APPEARANCE_TEXTALIGN_LEFT), GetString(SI_AWEVS_APPEARANCE_TEXTALIGN_CENTER), GetString(SI_AWEVS_APPEARANCE_TEXTALIGN_RIGHT) },
            getFunc = function()
                return AE.GetTextAlignString(AE.vars.window.textAlign)
            end,
            setFunc = function(newValue)
                AE.ui.SetTextAlign(AE.GetTextAlign(newValue))
            end,
            default = function()
                return AE.GetTextAlignString(AE.vars.default.window.textAlign)
            end,
        },
        {
            type = 'slider',
            name = GetString(SI_AWEVS_APPEARANCE_UISCALE),
            tooltip = GetString(SI_AWEVS_APPEARANCE_UISCALE_HINT),
            min = 5,
            max = 15,
            getFunc = function()
                return 10 * AE.vars.window.scaling
            end,
            setFunc = function(newValue)
                AE.vars.window.scaling = newValue / 10
                AE.ui.SetScale()
            end,
            default = 10 * AE.vars.default.window.scaling,
        },
        {
            type = 'slider',
            name = GetString(SI_AWEVS_APPEARANCE_BACKGROUND_ALPHA),
            tooltip = GetString(SI_AWEVS_APPEARANCE_BACKGROUND_ALPHA_HINT),
            min = 0,
            max = 100,
            getFunc = function()
                return 100 * AE.vars.window.backgroundAlpha
            end,
            setFunc = function(newValue)
                AE.vars.window.backgroundAlpha = newValue / 100
                AE.ui.SetBackgroundTransparency()
            end,
            default = 100 * AE.vars.default.window.backgroundAlpha,
        },
        {
            type = 'colorpicker',
            name = GetString(SI_AWEVS_APPEARANCE_COLOR_AVAILABLE),
            tooltip = GetString(SI_AWEVS_APPEARANCE_COLOR_AVAILABLE_HINT),
            getFunc = function()
                local c = AE.vars.window.textColor[AE.const.COLOR_AVAILABLE];
                return c.r, c.g, c.b, 1
            end,
            setFunc = function(r, g, b, a)
                local c = AE.GetColor(r, g, b)
                AE.setColorDef(AE.const.COLOR_AVAILABLE,  c.r, c.g, c.b)
                AE.vars.window.textColor[AE.const.COLOR_AVAILABLE] = c
                AE.ui.MarkAllDirty()
            end,
            default = AE.vars.default.window.textColor[AE.const.COLOR_AVAILABLE],
        },
        {
            type = 'colorpicker',
            name = GetString(SI_AWEVS_APPEARANCE_COLOR_HINT),
            tooltip = GetString(SI_AWEVS_APPEARANCE_COLOR_HINT_HINT),
            getFunc = function()
                local c = AE.vars.window.textColor[AE.const.COLOR_HINT];
                return c.r, c.g, c.b, 1
            end,
            setFunc = function(r, g, b, a)
                local c = AE.GetColor(r, g, b)
                AE.setColorDef(AE.const.COLOR_HINT,  c.r, c.g, c.b)
                AE.vars.window.textColor[AE.const.COLOR_HINT] = c
                AE.ui.MarkAllDirty()
            end,
            default = AE.vars.default.window.textColor[AE.const.COLOR_HINT],
        },
        {
            type = 'colorpicker',
            name = GetString(SI_AWEVS_APPEARANCE_COLOR_WARNING),
            tooltip = GetString(SI_AWEVS_APPEARANCE_COLOR_WARNING_HINT),
            getFunc = function()
                local c = AE.vars.window.textColor[AE.const.COLOR_WARNING];
                return c.r, c.g, c.b, 1
            end,
            setFunc = function(r, g, b, a)
                local c = AE.GetColor(r, g, b)
                AE.setColorDef(AE.const.COLOR_WARNING,  c.r, c.g, c.b)
                AE.vars.window.textColor[AE.const.COLOR_WARNING] = c
                AE.ui.MarkAllDirty()
            end,
            default = AE.vars.default.window.textColor[AE.const.COLOR_WARNING],
        },
        {
            type = 'checkbox',
            name = GetString(SI_AWEVS_APPEARANCE_SHOWDISABLEDTEXT),
            tooltip = GetString(SI_AWEVS_APPEARANCE_SHOWDISABLEDTEXT_HINT),
            getFunc = function()
                return AE.vars.showDisabledText
            end,
            setFunc = function(newValue)
                AE.vars.showDisabledText = newValue;
                AE.ui.UpdateViewSize();
            end,
            default = AE.vars.default.window.movable,
        },
        {
            type = 'header',
            name = '|c45D7F7' .. GetString(SI_AWEVS_IMPORT) .. '|r',
        },
        {
            type = 'description',
            text = GetString(SI_AWEVS_IMPORT_DESCRIPTION),
        },
        {
            type = 'dropdown',
            name = GetString(SI_AWEVS_IMPORT_CHARACTER_LABEL),
            choices = importOptions,
            getFunc = function()
                return GetString(SI_AWEVS_IMPORT_CHARACTER_SELECT)
            end,
            setFunc = function(newValue)
                __importFromCharacterName = newValue
            end,
            default = GetString(SI_AWEVS_IMPORT_CHARACTER_SELECT),
        },
        {
            type = 'button',
            name = GetString(SI_AWEVS_IMPORT_BUTTON),
            func = function()
                AE.importConfigFromCharacter(__importFromCharacterName)
            end,
        },
    }
    -- foreach module
    for mod_id, mod in AE.core.pairs(AE.core.modules) do
        AE.logging.d('menu', 'LoadModule[' .. mod_id .. ']')
        table.insert(panelOptions, {
            type = 'header',
            name = '|c45D7F7' .. mod.title .. '|r',
        })
        table.insert(panelOptions, {
            type = 'checkbox',
            name = GetString(SI_AWEMOD_SHOW),
            tooltip = mod.hint,
            getFunc = __get(mod_id, 'enabled'),
            setFunc = __set(mod_id, 'enabled'),
            default = AE.vars.default[mod_id].enabled,
        })
        table.insert(panelOptions, {
            type = 'dropdown',
            name = GetString(SI_AWEMOD_SPACING_POSITION),
            tooltip = GetString(SI_AWEMOD_SPACING_POSITION_HINT),
            choices = { GetString(SI_AWEMOD_SPACING_TOP), GetString(SI_AWEMOD_SPACING_BOTTOM), GetString(SI_AWEMOD_SPACING_BOTH) },
            getFunc = __get(mod_id, 'spacingPosition'),
            setFunc = __set(mod_id, 'spacingPosition'),
            disabled = __disable(mod_id, 'enabled'),
            default = AE.GetSpacingPositionString(AE.vars.default[mod_id].spacingPosition),
        })
        table.insert(panelOptions, {
            type = 'slider',
            name = GetString(SI_AWEMOD_SPACING),
            tooltip = GetString(SI_AWEMOD_SPACING_HINT),
            min = 0,
            max = 30,
            getFunc = __get(mod_id, 'spacing'),
            setFunc = __set(mod_id, 'spacing'),
            disabled = __disable(mod_id, 'enabled'),
            default = AE.vars.default[mod_id].spacing,
        })
        table.insert(panelOptions, {
            type = 'slider',
            name = GetString(SI_AWEMOD_FONTSIZE),
            tooltip = GetString(SI_AWEMOD_FONTSIZE_HINT),
            min = 1,
            max = 5,
            getFunc = __get(mod_id, 'fontSize'),
            setFunc = __set(mod_id, 'fontSize'),
            disabled = __disable(mod_id, 'enabled'),
            default = AE.vars.default[mod_id].fontSize,
        })
        -- foreach options
        for key, option in AE.core.pairs(mod.options) do
            if (option.type ~= nil and option.name ~= nil and option.tooltip ~= nil and option.default ~= nil) then
                if (option.getTransformer ~= nil) then
                    option.getFunc = __get(mod_id, key, option.getTransformer)
                    option.default = option.getTransformer(option.default)
                else
                    option.getFunc = __get(mod_id, key)
                end
                if (option.setTransformer ~= nil) then
                    option.setFunc = __set(mod_id, key, option.setTransformer)
                else
                    option.setFunc = __set(mod_id, key)
                end
                option.disabled = __disable(mod_id, 'enabled')
                table.insert(panelOptions, option)
            else
                AE.logging.d('menu', 'LoadModule[' .. mod_id .. ']', GetString(SI_AWEVS_DEBUG_MODULE_OPTION_INVALID), option)
            end
        end
    end
    return panelOptions
end -- buildModulesConfiguration


--- create the settings menu
local function registerSettingsMenu()
    -- run only once
    CALLBACK_MANAGER:UnregisterCallback(AE.const.CALLBACK_CORE, registerSettingsMenu)

    if (LibAddonMenu2 == nil) then
        AE.logging.d('menu', "LibAddonMenu-2.0 not found, cannot create settings menu")
        return
    end

    local panelData = {
        type = 'panel',
        name = AE.title,
        author = '|c60FF60Ze_Mi|r',
        version = '|c60FF60' .. AE.version .. '|r',
        displayName = '|c8080FF' .. AE.title .. '|r',
        slashCommand = '/aecfg',
        registerForRefresh = true,
        registerForDefaults = true,
        resetFunc = function()
            -- reset options that are not available via settings panel
            AE.vars.window.top = AE.vars.default.window.top
            AE.vars.window.left = AE.vars.default.window.left
        end
    }

    local aePanel = LibAddonMenu2:RegisterAddonPanel(AE.panelName, panelData)
    LibAddonMenu2:RegisterOptionControls(AE.panelName, buildModulesConfiguration())

    -- register LAM/optionsPanel events
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
        if panel == aePanel then
            AE.ui.show()
        end
    end)
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
        if panel == aePanel then
            AE.ui.hide()
        end
    end)
end -- registerSettingsMenu


CALLBACK_MANAGER:RegisterCallback(AE.const.CALLBACK_CORE, registerSettingsMenu)