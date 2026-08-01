-- COMBAT RETICLE - Settings Module
-- Author: Aetheron, |c4EFFF6Calia1120|r
-- See readme.txt for installation and configuration information

local LAM2 = LibAddonMenu2

local g_setting_panel
local g_texture_path = "CombatReticle\\Textures\\"
local g_category_data = {}
local g_category_names = {}
local g_theme_data = {}
local g_theme_names = {}
local g_ret_types = {"None", "Default", "Custom", "Disabled"}
local g_rot_modes = {"None","CW","CCW","Swing15","Swing30","Swing45"}
local g_ani_modes = {"None","Sine","Square","Ramp Up","Ramp Down"}
local g_ani_props = {"Transparency","Saturation","Scale"}
local g_apply = {"Both (same)","Both (opposite)","Reticle 1","Reticle 2"}
local g_interact_modes = { "Normal", "Ignore", "Show Disabled" }
local g_updateAllReticles = nil
local g_slot = "1"
local g_cur_theme = ""
local g_sel_theme = ""
local g_copy = nil
local g_paste = nil

-- "Constructor" for reticle settings table
local function newModeSettings()
    settings = {
        ret_type    = 3,

        category    = "Circle",
        texture     = "CircleOpen",
        color       = {r = 1.0, g = 1.0, b = 1.0, a = 1.0},
        scale       = 50,

        overlay     = false,

        category2   = "Circle",
        texture2    = "CircleOpen",
        color2      = {r = 1.0, g = 1.0, b = 1.0, a = 1.0},
        scale2      = 50,

        rot_mode    = 1,
        rot_apply   = 1,
        rot_vel     = 20,
        ani_mode    = 1,
        ani_prop    = 1,
        ani_apply   = 1,
        ani_speed   = 25,
        ani_min     = 0,
        }
    return settings
end

-- "Constructor" for stealth reticle settings table
local function newStealthModeSettings()
    settings = {
        ret_type    = 3,
        category    = "",
        texture     = "",
        color       = {r = 1.0, g = 1.0, b = 1.0, a = 0.6},
        scale       = 100,
        overlay     = false,
        category2   = "Circle",
        texture2    = "CircleSplitH",
        color2      = {r = 1.0, g = 1.0, b = 1.0, a = 0.6},
        scale2      = 60,
        rot_mode    = 1,
        rot_apply   = 4,
        rot_vel     = 20,
        ani_mode    = 1,
        ani_prop    = 1,
        ani_apply   = 4,
        ani_speed   = 25,
        ani_min     = 0,
    }
    return settings
end

-- Setup sane default values
local g_def_settings = {
    current = {
        hide_interact_text = false,
        hide_stealth_text = false,
        show_owned = true,
        delay_low_priority = true,
        interact_mode = 1,
        normal = newModeSettings(),
        interact = newModeSettings(),
        hostile = newModeSettings(),
        neutral = newModeSettings(),
        combat = newModeSettings(),
        combat_hostile = newModeSettings(),
        combat_friendly = newModeSettings(),
        stealth_normal = newModeSettings(),
        stealth_interact = newModeSettings(),
        stealth_hostile = newModeSettings(),
        stealth_neutral = newModeSettings(),
        stealth_combat = newModeSettings(),
        }
    }

-- Initialize LibAddOnMenu panel table
local g_panel_data = {
    type = "panel",
    name = "Combat Reticle",
    author = "Aetheron, Calia1120",
    version = "2.1.1",
    registerForRefresh = true,
    registerForDefaults = true,
}

-- Utility method: gets index of item in list
local function getListIndex( a_item, a_list )
    for k,v in pairs(a_list) do
        if ( a_item == v ) then
            return k
        end
    end
end

-- Copy an reticle settings table
local function copyReticleSettings( src, dest )
    dest.ret_type    = src.ret_type
    dest.category    = src.category
    dest.texture     = src.texture
    dest.color.r     = src.color.r
    dest.color.g     = src.color.g
    dest.color.b     = src.color.b
    dest.color.a     = src.color.a
    dest.scale       = src.scale
    dest.overlay     = src.overlay
    dest.category2   = src.category2
    dest.texture2    = src.texture2
    dest.color2.r    = src.color2.r
    dest.color2.g    = src.color2.g
    dest.color2.b    = src.color2.b
    dest.color2.a    = src.color2.a
    dest.scale2      = src.scale2
    dest.rot_mode    = src.rot_mode
    dest.rot_apply   = src.rot_apply
    dest.rot_vel     = src.rot_vel
    dest.ani_mode    = src.ani_mode
    dest.ani_prop    = src.ani_prop
    dest.ani_apply   = src.ani_apply
    dest.ani_speed   = src.ani_speed
    dest.ani_min     = src.ani_min
end

-- Deep-copy setting table from source to destination
local function copySettings( src, dest )
    copyReticleSettings( src.normal, dest.normal )
    copyReticleSettings( src.interact, dest.interact )
    copyReticleSettings( src.hostile, dest.hostile )
    copyReticleSettings( src.neutral, dest.neutral )
    copyReticleSettings( src.combat, dest.combat )
    copyReticleSettings( src.combat_hostile, dest.combat_hostile )
    copyReticleSettings( src.combat_friendly, dest.combat_friendly )
    copyReticleSettings( src.stealth_normal, dest.stealth_normal )
    copyReticleSettings( src.stealth_interact, dest.stealth_interact )
    copyReticleSettings( src.stealth_neutral, dest.stealth_neutral )
    copyReticleSettings( src.stealth_hostile, dest.stealth_hostile )
    copyReticleSettings( src.stealth_combat, dest.stealth_combat )
    dest.hide_stealth_text  = src.hide_stealth_text
    dest.hide_interact_text = src.hide_interact_text
    dest.show_owned = src.show_owned
    dest.delay_low_priority = src.delay_low_priority
    dest.interact_mode = src.interact_mode
end

-- Copies settings from one mode to another
local function duplicateSettings()
    if ( g_copy ~= nil and g_paste ~= nil ) then
        copyReticleSettings( g_settings.current[g_copy], g_settings.current[g_paste] )
    end
end

local function initPreviewControls( parent, settings, label )
    if ( parent.texture_backL == nil ) then
        local preview_size = 64

        parent.texture_backL = WINDOW_MANAGER:CreateControl(nil, parent, CT_TEXTURE )
        parent.texture_backL:SetAnchor(CENTER, nil, CENTER, -36 )
        parent.texture_backL:SetDimensions( preview_size, preview_size )
        parent.texture_backL:SetTexture( g_texture_path .. "PreviewBackgroundPvP.dds" )
        parent.texture_backL:SetScale( 1.0 )
        parent.texture_backL:SetBlendMode( TEX_BLEND_MODE_ALPHA )

        parent.texture_backR = WINDOW_MANAGER:CreateControl(nil, parent, CT_TEXTURE )
        parent.texture_backR:SetAnchor(CENTER, nil, CENTER, 36 )
        parent.texture_backR:SetDimensions( preview_size, preview_size )
        parent.texture_backR:SetTexture( g_texture_path .. "PreviewBackgroundBlack.dds" )
        parent.texture_backR:SetScale( 1.0 )
        parent.texture_backR:SetBlendMode( TEX_BLEND_MODE_ALPHA )

        parent.textureL1 = WINDOW_MANAGER:CreateControl(nil, parent, CT_TEXTURE )
        parent.textureL1:SetAnchor(CENTER, nil, CENTER, -36)
        parent.textureL1:SetDimensions( preview_size, preview_size )
        parent.textureL1:SetBlendMode( TEX_BLEND_MODE_ALPHA )
        parent.textureR1 = WINDOW_MANAGER:CreateControl(nil, parent, CT_TEXTURE )
        parent.textureR1:SetAnchor(CENTER, nil, CENTER, 36)
        parent.textureR1:SetDimensions( preview_size, preview_size )
        parent.textureR1:SetBlendMode( TEX_BLEND_MODE_ALPHA )

        parent.textureL2 = WINDOW_MANAGER:CreateControl( nil, parent, CT_TEXTURE )
        parent.textureL2:SetAnchor(CENTER, nil, CENTER, -36)
        parent.textureL2:SetDimensions( preview_size, preview_size )
        parent.textureL2:SetBlendMode( TEX_BLEND_MODE_ALPHA )
        parent.textureR2 = WINDOW_MANAGER:CreateControl( nil, parent, CT_TEXTURE )
        parent.textureR2:SetAnchor(CENTER, nil, CENTER, 36)
        parent.textureR2:SetDimensions( preview_size, preview_size )
        parent.textureR2:SetBlendMode( TEX_BLEND_MODE_ALPHA )
    end

    if ( settings.ret_type == 3 ) then
        parent.textureL1:SetTexture( g_category_data[settings.category].path .. settings.texture .. ".dds" )
        parent.textureL1:SetColor( settings.color.r, settings.color.g, settings.color.b, settings.color.a )
        parent.textureL1:SetScale( settings.scale/100.0 )
        parent.textureR1:SetTexture( g_category_data[settings.category].path .. settings.texture .. ".dds" )
        parent.textureR1:SetColor( settings.color.r, settings.color.g, settings.color.b, settings.color.a )
        parent.textureR1:SetScale( settings.scale/100.0 )

        if ( settings.overlay == true ) then
            parent.textureL2:SetTexture( g_category_data[settings.category2].path .. settings.texture2 .. ".dds" )
            parent.textureL2:SetColor( settings.color2.r, settings.color2.g, settings.color2.b, settings.color2.a )
            parent.textureL2:SetScale( settings.scale2/100.0 )
            parent.textureR2:SetTexture( g_category_data[settings.category2].path .. settings.texture2 .. ".dds" )
            parent.textureR2:SetColor( settings.color2.r, settings.color2.g, settings.color2.b, settings.color2.a )
            parent.textureR2:SetScale( settings.scale2/100.0 )
        else
            parent.textureL2:SetColor( 0, 0, 0, 0 )
            parent.textureR2:SetColor( 0, 0, 0, 0 )
        end
    else
        parent.textureL1:SetColor( 0, 0, 0, 0 )
        parent.textureL2:SetColor( 0, 0, 0, 0 )
        parent.textureR1:SetColor( 0, 0, 0, 0 )
        parent.textureR1:SetColor( 0, 0, 0, 0 )
        parent.textureR2:SetColor( 0, 0, 0, 0 )
    end
end

local function updateImageDropDowns( a_settings, a_label )
    local ctrl = WINDOW_MANAGER:GetControlByName( "CombatReticleBaseTextures" .. a_label )
    ctrl:UpdateChoices( g_category_data[a_settings.category].textures )
    ctrl = WINDOW_MANAGER:GetControlByName( "CombatReticleOverTextures" .. a_label )
    ctrl:UpdateChoices( g_category_data[a_settings.category2].textures )
end

local function updateImageDropDownsStealth( a_settings, a_label )
    local ctrl = WINDOW_MANAGER:GetControlByName( "CombatReticleStealthOver" .. a_label )
    ctrl:UpdateChoices( g_category_data[a_settings.category2].textures )
end

-- Must manually update image dropdowns for all reticle modes
local function updateAllImageDropDowns( a_settings )
    updateImageDropDowns( a_settings.normal, "Normal" )
    updateImageDropDowns( a_settings.interact, "Interactive" )
    updateImageDropDowns( a_settings.neutral, "Neutral Target" )
    updateImageDropDowns( a_settings.hostile, "Hostile Target" )
    updateImageDropDowns( a_settings.combat, "Combat" )
    updateImageDropDowns( a_settings.combat_hostile, "Combat (Hostile)" )
    updateImageDropDowns( a_settings.combat_friendly, "Combat (Friendly)" )

    updateImageDropDownsStealth( a_settings.stealth_normal, "Normal" )
    updateImageDropDownsStealth( a_settings.stealth_interact, "Interactive" )
    updateImageDropDownsStealth( a_settings.stealth_neutral, "Neutral Target" )
    updateImageDropDownsStealth( a_settings.stealth_hostile, "Hostile Target" )
    updateImageDropDownsStealth( a_settings.stealth_combat, "Combat" )    
end


-- Initialize LibAddOnMenu options table
-- Most items are added dynamically from CombatReticleLoaded()
local g_options_table = {
    [1] = {
        type = "description",
        text = "Load a theme or manually adjust reticle settings for each mode. \nView the README file in the docs folder for more information on any of the settings.",
        width = "full",
    },
    [2] = {
        type = "submenu",
        name = "Themes",
        controls = {
			-- Theme dropdown
            [1] = {
                type = "dropdown",
                name = "Available themes:",
                tooltip = "Select a theme to load",
                choices = g_theme_names,
                getFunc = function() return g_cur_theme end,
                setFunc = function(var)
                    g_sel_theme = var
                end,
                width = "full",
            },
			-- Load theme button
            [2] = {
                type = "button",
                name = "Load Theme",
                tooltip = "Load selected theme (current will be overwritten)",
                func = function()
                    if ( g_theme_data[g_sel_theme] ~= nil ) then
                        updateAllImageDropDowns( g_theme_data[g_sel_theme] )
                        copySettings( g_theme_data[g_sel_theme], g_settings.current )
                        g_updateAllReticles()
                        g_cur_theme = g_sel_theme
                    end
                end,
                width = "half",
            }
        }
    }
}


local function primaryDisabled( a_settings )
    res = false

    if ( a_settings.ret_type ~= 3 ) then
        res = true
    end
    return res
end

local function secondaryDisabled( a_settings )
    res = false

    if (( a_settings.ret_type ~= 3 ) or ( a_settings.overlay == false )) then
        res = true
    end
    return res
end

local function rotationDisabled( a_settings )
    res = false

    if (( a_settings.ret_type ~= 3 ) or ( a_settings.rot_mode == 1 )) then
        res = true
    end

    return res
end

local function animationDisabled( a_settings )
    res = false

    if (( a_settings.ret_type ~= 3 ) or ( a_settings.ani_mode == 1 )) then
        res = true
    end

    return res
end

local function initReticleOptionsData( a_settings, a_settings_stealth, a_label )
    --g_options_table[#g_options_table + 1] = {
    local options_table = {}

    options_table[1] = {
        type = "submenu",
        name = "Basic",
        controls = {
			-- Reticle type dropdown
            [1] = {
                type = "dropdown",
                name = "Type",
                tooltip = "Select reticle type",
                choices = g_ret_types,
                getFunc = function() return g_ret_types[a_settings.ret_type] end,
                setFunc = function(var)
                    a_settings.ret_type = getListIndex( var, g_ret_types )
                end,
                width = "full",
            },
			-- Reticle preview description
            [2] = {
                type = "description",
                title = "Custom reticle preview",
                width = "half",
            },
			-- Reticle preview image
            [3] = {
                type = "custom",
                reference = "CombatReticlePreview" .. a_label,
                refreshFunc = function( control )
                    -- create/update reticle preview
                    initPreviewControls( control, a_settings, a_label )
                    -- This is also a convenient/central place to call reticle update cb
                    g_updateAllReticles()
                    g_cur_theme = ""
                end,
                width = "half",
            },
			-- Base reticle image category dropdown
            [4] = {
                type = "dropdown",
                name = "Category",
                tooltip = "Base image category",
                choices = g_category_names,
                getFunc = function() return a_settings.category end,
                setFunc = function(var)
                    a_settings.category = var
                    -- Update choices in image drop-down
                    ctrl = WINDOW_MANAGER:GetControlByName( "CombatReticleBaseTextures" .. a_label )
                    ctrl:UpdateChoices( g_category_data[a_settings.category].textures )
                end,
                disabled = function() return primaryDisabled( a_settings ) end,
                width = "full",
            },
			-- Base reticle image dropdown
            [5] = {
                type = "dropdown",
                name = "Image",
                reference = "CombatReticleBaseTextures" .. a_label,
                tooltip = "Base image",
                choices = g_category_data[a_settings.category].textures,
                getFunc = function() return a_settings.texture end,
                setFunc = function(var)
                        d("set image",var)
                        a_settings.texture = var
                    end,
                disabled = function() return primaryDisabled( a_settings ) end,
                width = "full",
            },
			-- Base image colorpicker
            [6] = {
                type = "colorpicker",
                name = "Color",
                tooltip = "Base image color and transparency",
                getFunc = function() return a_settings.color.r, a_settings.color.g, a_settings.color.b, a_settings.color.a end,
                setFunc = function(r,g,b,a)
                    a_settings.color.r = r
                    a_settings.color.g = g
                    a_settings.color.b = b
                    a_settings.color.a = a
                end,
                disabled = function() return primaryDisabled( a_settings ) end,
                width = "full",
            },
			-- Base image scale slider
            [7] = {
                type = "slider",
                name = "Scale",
                tooltip = "Base image scale (percent)",
                min = 10,
                max = 100,
                step = 1,
                getFunc = function() return a_settings.scale end,
                setFunc = function(value)
                    a_settings.scale = value
                end,
                width = "full",
                disabled = function() return primaryDisabled( a_settings ) end,
                default = 100,
            },
			-- Enable overlay image checkbox
            [8] = {
                type = "checkbox",
                name = "Enable overlay image",
                tooltip = "Enable overlay for composite / multi-color reticles",
                getFunc = function() return a_settings.overlay end,
                setFunc = function(value)
                    a_settings.overlay = value
                end,
                width = "full",
                disabled = function() return primaryDisabled( a_settings ) end,
                default = false,
            },
			-- Overlay image category dropdown
            [9] = {
                type = "dropdown",
                name = "Category",
                tooltip = "Overlay image category",
                choices = g_category_names,
                getFunc = function() return a_settings.category2 end,
                setFunc = function(var)
                    a_settings.category2 = var
                    -- Update choices in image drop-down
                    ctrl = WINDOW_MANAGER:GetControlByName( "CombatReticleOverTextures" .. a_label )
                    ctrl:UpdateChoices( g_category_data[a_settings.category2].textures )
                end,
                disabled = function() return secondaryDisabled( a_settings ) end,
                width = "full",
            },
			-- Overlay image dropdown
            [10] = {
                type = "dropdown",
                name = "Image",
                reference = "CombatReticleOverTextures" .. a_label,
                tooltip = "Overlay image",
                choices = g_category_data[a_settings.category2].textures,
                getFunc = function() return a_settings.texture2 end,
                setFunc = function(var)
                    a_settings.texture2 = var
                end,
                disabled = function() return secondaryDisabled( a_settings ) end,
                width = "full",
            },
			-- Overlay image colorpicker
            [11] = {
                type = "colorpicker",
                name = "Color (overlay)",
                tooltip = "Overlay image color",
                getFunc = function() return a_settings.color2.r, a_settings.color2.g, a_settings.color2.b, a_settings.color2.a end,
                setFunc = function(r,g,b,a)
                    a_settings.color2.r = r
                    a_settings.color2.g = g
                    a_settings.color2.b = b
                    a_settings.color2.a = a
                end,
                disabled = function() return secondaryDisabled( a_settings ) end,
                width = "full",
            },
			-- Overlay image scale slider
            [12] = {
                type = "slider",
                name = "Scale (overlay)",
                tooltip = "Overlay image scale (percent)",
                min = 10,
                max = 100,
                step = 1,   --(optional)
                getFunc = function() return a_settings.scale2 end,
                setFunc = function(value)
                    a_settings.scale2 = value
                end,
                width = "full",
                disabled = function() return secondaryDisabled( a_settings ) end,
                default = 100,
            }
        }
    }

    --g_options_table[#g_options_table + 1] = {
    options_table[2] = {
        type = "submenu",
        name = "Advanced",
        controls = {
			-- Rotation mode dropdown
            [1] = {
                type = "dropdown",
                name = "Rotation",
                tooltip = "Rotation mode",
                choices = g_rot_modes,
                getFunc = function() return g_rot_modes[a_settings.rot_mode] end,
                setFunc = function(var)
                    a_settings.rot_mode = getListIndex( var, g_rot_modes )
                end,
                disabled = function() return primaryDisabled( a_settings ) end,
                width = "full",
                warning = "Rotation may impact frame rate on low-end systems"
            },
			-- Rotation apply to
            [2] = {
                type = "dropdown",
                name = "Apply to",
                tooltip = "Which reticles to rotate",
                choices = g_apply,
                getFunc = function() return g_apply[a_settings.rot_apply] end,
                setFunc = function(var)
                    a_settings.rot_apply = getListIndex( var, g_apply )
                end,
                disabled = function() return rotationDisabled( a_settings ) end,
                width = "full",
            },
			-- Rotation speed slider
            [3] = {
                type = "slider",
                name = "Rotation speed",
                tooltip = "Max speed is 1 revs/sec",
                min = 1,
                max = 100,
                step = 1,
                getFunc = function() return a_settings.rot_vel end,
                setFunc = function(value)
                    a_settings.rot_vel = value
                end,
                width = "full",
                disabled = function() return rotationDisabled( a_settings ) end,
                default = 10,
            },
			-- Animation mode dropdown
            [4] = {
                type = "dropdown",
                name = "Animation",
                tooltip = "Animation mode",
                choices = g_ani_modes,
                getFunc = function() return g_ani_modes[a_settings.ani_mode] end,
                setFunc = function(var)
                    a_settings.ani_mode = getListIndex( var, g_ani_modes )
                end,
                disabled = function() return primaryDisabled( a_settings ) end,
                width = "full",
                warning = "Animation may impact frame rate on low-end systems"
            },
			-- Property animation effects dropdown
            [5] = {
                type = "dropdown",
                name = "Property affected",
                tooltip = "Property animation affects",
                choices = g_ani_props,
                getFunc = function() return g_ani_props[a_settings.ani_prop] end,
                setFunc = function(var)
                    a_settings.ani_prop = getListIndex( var, g_ani_props )
                end,
                disabled = function() return animationDisabled( a_settings ) end,
                width = "full",
            },
			-- Apply to dropdown
            [6] = {
                type = "dropdown",
                name = "Apply to",
                tooltip = "Which reticles to animate",
                choices = g_apply,
                getFunc = function() return g_apply[a_settings.ani_apply] end,
                setFunc = function(var)
                    a_settings.ani_apply = getListIndex( var, g_apply )
                end,
                disabled = function() return animationDisabled( a_settings ) end,
                width = "full",
            },
			-- Animation speed slider
            [7] = {
                type = "slider",
                name = "Speed",
                tooltip = "Animation speed",
                min = 1,
                max = 100,
                step = 1,
                getFunc = function() return a_settings.ani_speed end,
                setFunc = function(value)
                    a_settings.ani_speed = value
                end,
                width = "full",
                disabled = function() return animationDisabled( a_settings ) end,
                default = 25,
            },
			-- Modulation level
            [8] = {
                type = "slider",
                name = "Modulation level",
                tooltip = "Modulation level (or depth) of property affected by animation",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return 100 - a_settings.ani_min end,
                setFunc = function(value)
                    a_settings.ani_min = 100 - value
                end,
                width = "full",
                disabled = function() return animationDisabled( a_settings ) end,
                default = 0,
            }
        }
    }

    if a_settings_stealth then
        options_table[3] = {
            type = "submenu",
            name = "Stealth",
            controls = {
                -- Stealth reticle scale
                [1] = {
                    type = "slider",
                    name = "Scale (stealth)",
                    tooltip = "Stealth reticle scale - applies to all stealth-modes",
                    min = 10,
                    max = 100,
                    step = 1,
                    getFunc = function() return a_settings_stealth.scale end,
                    setFunc = function(value)
                        a_settings_stealth.scale = value
                    end,
                    width = "full",
                    default = 100,
                },
                -- Stealth reticle colorpicker
                [2] = {
                    type = "colorpicker",
                    name = "Color (stealth)",
                    tooltip = "Stealth reticle color - applies to all stealth-modes",
                    getFunc = function() return a_settings_stealth.color.r, a_settings_stealth.color.g, a_settings_stealth.color.b, a_settings_stealth.color.a end,
                    setFunc = function(r,g,b,a)
                        a_settings_stealth.color.r = r
                        a_settings_stealth.color.g = g
                        a_settings_stealth.color.b = b
                        a_settings_stealth.color.a = a
                    end,
                    width = "full",
                },
                -- Enable overlay image checkbox
                [3] = {
                    type = "checkbox",
                    name = "Enable overlay image",
                    tooltip = "Enable overlay for composite / multi-color reticles",
                    getFunc = function() return a_settings_stealth.overlay end,
                    setFunc = function(value)
                        a_settings_stealth.overlay = value
                    end,
                    width = "full",
                    default = false,
                },
                -- Overlay image category dropdown
                [4] = {
                    type = "dropdown",
                    name = "Category (overlay)",
                    tooltip = "Overlay image category",
                    choices = g_category_names,
                    getFunc = function() return a_settings_stealth.category2 end,
                    setFunc = function(var)
                    a_settings_stealth.category2 = var
                        -- Update choices in image drop-down
                        ctrl = WINDOW_MANAGER:GetControlByName( "CombatReticleStealthOver" .. a_label )
                        ctrl:UpdateChoices( g_category_data[a_settings_stealth.category2].textures )
                    end,
                    width = "full",
                    disabled = function() return secondaryDisabled( a_settings_stealth ) end,
                },
                -- Overlay image dropdown
                [5] = {
                    type = "dropdown",
                    name = "Image (overlay)",
                    reference = "CombatReticleStealthOver" .. a_label,
                    tooltip = "Overlay image",
                    choices = g_category_data[a_settings_stealth.category2].textures,
                    getFunc = function() return a_settings_stealth.texture2 end,
                    setFunc = function(var)
                        a_settings_stealth.texture2 = var
                    end,
                    width = "full",
                    disabled = function() return secondaryDisabled( a_settings_stealth ) end,
                },
                -- Overlay image colorpicker
                [6] = {
                    type = "colorpicker",
                    name = "Color (overlay)",
                    tooltip = "Overlay image color",
                    getFunc = function() return a_settings_stealth.color2.r, a_settings_stealth.color2.g, a_settings_stealth.color2.b, a_settings_stealth.color2.a end,
                    setFunc = function(r,g,b,a)
                        a_settings_stealth.color2.r = r
                        a_settings_stealth.color2.g = g
                        a_settings_stealth.color2.b = b
                        a_settings_stealth.color2.a = a
                    end,
                    width = "full",
                    disabled = function() return secondaryDisabled( a_settings_stealth ) end,
                },
                -- Overlay scale slider
                [7] = {
                    type = "slider",
                    name = "Scale (overlay)",
                    tooltip = "Overlay image scale (percent)",
                    min = 10,
                    max = 100,
                    step = 1,
                    getFunc = function() return a_settings_stealth.scale2 end,
                    setFunc = function(value)
                        a_settings_stealth.scale2 = value
                    end,
                    width = "full",
                    default = 100,
                    disabled = function() return secondaryDisabled( a_settings_stealth ) end,
                },
                -- Rotation mode dropdown
                [8] = {
                    type = "dropdown",
                    name = "Rotation",
                    tooltip = "Rotation mode",
                    choices = g_rot_modes,
                    getFunc = function() return g_rot_modes[a_settings_stealth.rot_mode] end,
                    setFunc = function(var)
                        a_settings_stealth.rot_mode = getListIndex( var, g_rot_modes )
                    end,
                    width = "full",
                    warning = "Rotation may impact frame rate on low-end systems",
                    disabled = function() return secondaryDisabled( a_settings_stealth ) end,
                },
                -- Rotation speed slider
                [9] = {
                    type = "slider",
                    name = "Rotation speed",
                    tooltip = "Max speed is 1 revs/sec",
                    min = 1,
                    max = 100,
                    step = 1,
                    getFunc = function() return a_settings_stealth.rot_vel end,
                    setFunc = function(value)
                        a_settings_stealth.rot_vel = value
                    end,
                    width = "full",
                    default = 10,
                    disabled = function() return rotationDisabled( a_settings_stealth ) end,
                },
                -- Animation mode dropdown
                [10] = {
                    type = "dropdown",
                    name = "Animation",
                    tooltip = "Animation mode",
                    choices = g_ani_modes,
                    getFunc = function() return g_ani_modes[a_settings_stealth.ani_mode] end,
                    setFunc = function(var)
                        a_settings_stealth.ani_mode = getListIndex( var, g_ani_modes )
                    end,
                    width = "full",
                    warning = "Animation may impact frame rate on low-end systems",
                    disabled = function() return secondaryDisabled( a_settings_stealth ) end,
                },
                -- Property animation effects dropdown
                [11] = {
                    type = "dropdown",
                    name = "Property affected",
                    tooltip = "Property animation affects",
                    choices = g_ani_props,
                    getFunc = function() return g_ani_props[a_settings_stealth.ani_prop] end,
                    setFunc = function(var)
                        a_settings_stealth.ani_prop = getListIndex( var, g_ani_props )
                    end,
                    width = "full",
                    disabled = function() return animationDisabled( a_settings_stealth ) end,
                },
                -- Speed
                [12] = {
                    type = "slider",
                    name = "Speed",
                    tooltip = "Animation speed",
                    min = 1,
                    max = 100,
                    step = 1,
                    getFunc = function() return a_settings_stealth.ani_speed end,
                    setFunc = function(value)
                        a_settings_stealth.ani_speed = value
                    end,
                    width = "full",
                    default = 25,
                    disabled = function() return animationDisabled( a_settings_stealth ) end,
                },
                -- Modulation level
                [13] = {
                    type = "slider",
                    name = "Modulation level",
                    tooltip = "Modulation level (or depth) of property affected by animation",
                    min = 0,
                    max = 100,
                    step = 1,
                    getFunc = function() return 100 - a_settings_stealth.ani_min end,
                    setFunc = function(value)
                        a_settings_stealth.ani_min = 100 - value
                    end,
                    width = "full",
                    default = 0,
                    disabled = function() return animationDisabled( a_settings_stealth ) end,
                }
            }
        }
    end

    return options_table
end


-- Adds more options to g_options_table after reticle sections have been added
-- Misc Settings header
local function initAdditionalOptionsData()
    g_options_table[#g_options_table+1] = {
        type = "header",
        name = "Misc Settings",
        width = "full",
    }

	-- Show text when hidden
    g_options_table[#g_options_table+1] = {
        type = "checkbox",
        name = "Show stealth and disguised text",
        tooltip = "Enables default status text shown under stealth and disguised reticles",
        getFunc = function() return not g_settings.current.hide_stealth_text end,
        setFunc = function(val) g_settings.current.hide_stealth_text = not val end,
        width = "full",
        default = true,
    }

	-- Show owned icon
    g_options_table[#g_options_table+1] = {
        type = "checkbox",
        name = "Show owned icon",
        tooltip = "Shows icon when interacting with owned items",
        getFunc = function() return  g_settings.current.show_owned end,
        setFunc = function(val) g_settings.current.show_owned = val end,
        width = "full",
        default = true,
    }

	-- Show interaction text
    g_options_table[#g_options_table+1] = {
        type = "checkbox",
        name = "Show interaction text",
        tooltip = "Enables default help/usage text shown under interaction reticle",
        getFunc = function() return not g_settings.current.hide_interact_text end,
        setFunc = function(val) g_settings.current.hide_interact_text = not val end,
        width = "full",
        default = true,
    }
  
	-- Empty/blocked items
    g_options_table[#g_options_table+1]= {
        type = "dropdown",
        name = "Empty/blocked items",
        tooltip = "Set behavior when interacting with an empty or blocked item",
        choices = g_interact_modes,
        getFunc = function() return g_interact_modes[g_settings.current.interact_mode] end,
        setFunc = function(var)
            g_settings.current.interact_mode = getListIndex( var, g_interact_modes )
        end,
        width = "full",
    }

	-- Enable anti-flicker
    g_options_table[#g_options_table+1] = {
        type = "checkbox",
        name = "Enable anti-flicker filter ",
        tooltip = "Reduces spurious activations of interact, hostile, and neutral modes",
        getFunc = function() return g_settings.current.delay_low_priority end,
        setFunc = function(val) g_settings.current.delay_low_priority = val end,
        width = "full",
        default = true,
    }

	-- Copy/Paste - header
    g_options_table[#g_options_table+1] = {
        type = "header",
        name = "Copy-Paste Settings",
        width = "full",
    }

	-- Copy/Paste - copy dropdown
    g_options_table[#g_options_table+1] = {
        type = "dropdown",
        name = "Copy from:",
        tooltip = "Reticle to copy",
		width = "full",
        choices = {"normal","interact", "neutral", "hostile","combat","combat_hostile","combat_friendly"},
        getFunc = function() return g_copy end,
        setFunc = function(var)
            g_copy = var
        end,
        width = "full",
    }

	-- Copy/Paste - paste dropdown
    g_options_table[#g_options_table+1] = {
        type = "dropdown",
        name = "Paste to:",
        tooltip = "Reticle to copy",
        choices = {"normal","interact", "neutral", "hostile","combat","combat_hostile","combat_friendly"},
        getFunc = function() return g_paste end,
        setFunc = function(var)
            g_paste = var
        end,
        width = "full",
    }

	-- Duplicate button
    g_options_table[#g_options_table+1] = {
        type = "button",
        name = "Duplicate",
        tooltip = "Copies settings between selected reticles",
        func = function()
            -- Copy data from slot to current settings (if set)
            duplicateSettings()
        end,
        width = "half",
    }

	-- Quick slot header
    g_options_table[#g_options_table+1] = {
        type = "header",
        name = "Quick Slots",
        width = "full",
    }

	-- Quick slot dropdown
    g_options_table[#g_options_table+1] = {
        type = "dropdown",
        name = "Quick Slot Number:",
        tooltip = "Slot to save/load settings to/from",
        choices = {"1","2","3","4","5","6","7","8","9","0"},
        getFunc = function() return g_slot end,
        setFunc = function(var)
            g_slot = var
        end,
        width = "full",
    }

	-- Save quick slot
    g_options_table[#g_options_table+1] = {
        type = "button",
        name = "Save",
        tooltip = "Save current settings to selected slot",
        func = function()
            if ( g_settings[g_slot] == nil ) then
                g_settings[g_slot] = {
                    normal   = newModeSettings(),
                    interact = newModeSettings(),
                    hostile  = newModeSettings(),
                    neutral  = newModeSettings(),
                    combat   = newModeSettings(),
                    combat_hostile = newModeSettings(),
                    combat_friendly  = newModeSettings(),
                    stealth_normal   = newModeSettings(),
                    stealth_interact = newModeSettings(),
                    stealth_neutral  = newModeSettings(),
                    stealth_hostile  = newModeSettings(),
                    stealth_combat  = newModeSettings()
                }
            end

            -- Copy data from current settings to selected slot
            copySettings( g_settings.current, g_settings[g_slot] )
        end,
        width = "half",
    }

	-- Load quick slot
    g_options_table[#g_options_table+1] = {
        type = "button",
        name = "Load",
        tooltip = "Load settings from selected slot",
        func = function()
            -- Copy data from slot to current settings (if set)
            CombatReticleLoadSettings(g_slot)
        end,
        width = "half",
    }
end


-- Shows config panel
function CombatReticleShowConfig()
    LAM2:OpenToPanel(g_setting_panel)
end

-- Load reticle settings from specified slot or theme
function CombatReticleLoadSettings( a_slot )
    if ( g_settings[a_slot] ~= nil ) then
        g_slot = a_slot
        updateAllImageDropDowns( g_settings[g_slot] )
        copySettings( g_settings[g_slot], g_settings.current )
        g_updateAllReticles()
        g_cur_theme = ""
    else
        if ( g_theme_data[a_slot] ~= nil ) then
        updateAllImageDropDowns( g_theme_data[a_slot] )
            copySettings( g_theme_data[a_slot], g_settings.current )
            g_updateAllReticles()
            g_cur_theme = a_slot
        end
    end
end

function CombatReticleRegisterThemeModule( a_module_data )
    -- If reticle data provided, copy data and names
    if a_module_data["reticles"] then
        for k, v in pairs( a_module_data["reticles"] ) do
            g_category_data[k] = v
            table.insert( g_category_names, k )
        end
    end

    -- If theme data provided, copy data and names
    if a_module_data["themes"] then
        for k, v in pairs( a_module_data["themes"] ) do
            g_theme_data[k] = v
            table.insert( g_theme_names, k )
        end
    end
end

function CombatReticleGetCategoryData()
    return g_category_data
end

-- Initialize settings data
function CombatReticleInitializeSettings( a_updateAllReticles )
    -- Save ref to reticle update function
    g_updateAllReticles = a_updateAllReticles

    CombatReticleRegisterThemeModule( CombatReticleGetBuiltInThemeData() )

    -- Use first theme as default
    copySettings( g_theme_data["Default"], g_def_settings.current )

    -- Get/create saved vars (settings version does not track add-on version)
    g_settings = ZO_SavedVars:NewAccountWide( "CombatReticle_Settings", 3, nil, g_def_settings )

    g_options_table[#g_options_table + 1] = {
        type = "submenu",
        name = "Normal",
        controls = initReticleOptionsData( g_settings.current.normal, g_settings.current.stealth_normal, "Normal" )
    }

    g_options_table[#g_options_table + 1] = {
        type = "submenu",
        name = "Interactive",
        controls = initReticleOptionsData( g_settings.current.interact, g_settings.current.stealth_interact, "Interactive" )
    }

    g_options_table[#g_options_table + 1] = {
        type = "submenu",
        name = "Neutral Target",
        controls = initReticleOptionsData( g_settings.current.neutral, g_settings.current.stealth_neutral, "Neutral Target" )
    }

    g_options_table[#g_options_table + 1] = {
        type = "submenu",
        name = "Hostile Target",
        controls = initReticleOptionsData( g_settings.current.hostile, g_settings.current.stealth_hostile, "Hostile Target" )
    }
    
    g_options_table[#g_options_table + 1] = {
        type = "submenu",
        name = "Combat",
        controls = initReticleOptionsData( g_settings.current.combat, g_settings.current.stealth_combat, "Combat" )
    }

    g_options_table[#g_options_table + 1] = {
        type = "submenu",
        name = "Combat (Hostile Target)",
        controls = initReticleOptionsData( g_settings.current.combat_hostile, nil, "Combat (Hostile)" )
    }

    g_options_table[#g_options_table + 1] = {
        type = "submenu",
        name = "Combat (Friendly Target)",
        controls = initReticleOptionsData( g_settings.current.combat_friendly, nil, "Combat (Friendly)" )
    }

    initAdditionalOptionsData()

    g_setting_panel = LAM2:RegisterAddonPanel("CombatReticleOptions", g_panel_data)
    LAM2:RegisterOptionControls("CombatReticleOptions", g_options_table)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function( newPanel )
        if ( newPanel == g_setting_panel ) then
            LAM2.util.RequestRefreshIfNeeded( CombatReticlePreviewNormal )
            LAM2.util.RequestRefreshIfNeeded( CombatReticlePreviewInteractive )
        end
    end )


    return g_settings.current
end

