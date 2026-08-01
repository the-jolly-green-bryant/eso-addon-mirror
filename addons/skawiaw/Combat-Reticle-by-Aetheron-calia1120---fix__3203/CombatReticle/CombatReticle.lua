-- COMBAT RETICLE - Main Module
-- Author: Aetheron, updated by Calia1120
-- See docs/readme.txt for installation and configuration information

local g_category_data = nil
local g_ret_data = {} -- Container for per-mode reticle data
local g_ret_last = nil
local g_ret_next = nil
local g_ret_detect_time = 0
local g_last_time = 0
local g_ret_angle = 0   -- Current reticle angle
local g_settings = nil -- The CURRENT reticle settings (for all modes)
local g_reticle_size = 64 -- Size of reticle textures on-screen
local g_alliance = nil
local g_2PI = math.pi*2
local g_ani_trans_time = 0
local g_brightness = 1.0
local g_use_interact = true
local g_use_neutral = true
local g_use_hostile = true
local g_use_combat = true
local g_use_combat_target = false
local g_use_combat_hostile = false
local g_use_combat_friendly = false
local g_render_reticle = false
local g_in_combat = false
local g_in_stealth = false
local g_delay_low_priority = true
local g_hide_interact_text = false
local g_hide_stealth_text = false
local g_show_owned = true
local g_interact_mode = 1
local g_disabled_c = 0.35

-------------------------------------------------------------------------------
-- Mode Detection and Rendering Code ------------------------------------------


-- Function to determine if camera target can be interacted with.
local function IsTargetInteractable()
    local action, _, blocked, owned = GetGameCameraInteractableActionInfo()
    if ( action ~= nil ) then
        if ( blocked == true ) then
            if ( g_interact_mode == 2 ) then -- Mode 2 == ignore container if blocked
                return 0, owned
            else
                return 2, owned
            end
        else
            return 1, owned
        end
    elseif (( not SHARED_INFORMATION_AREA:IsSuppressed()) and
        DoesUnitExist("reticleoverplayer") and
        IsUnitOnline("reticleoverplayer") and
        g_alliance == GetUnitAlliance("reticleoverplayer")) then

        if ( IsUnitResurrectableByPlayer("reticleoverplayer") or CanUnitTrade("reticleoverplayer")) then
            return 1, owned
        end
    end

    return 0, nil
end


local function IsFriendlyCombatTarget()
    if DoesUnitExist("reticleoverplayer") then
        return true
    end

    return false
end

-- Generates sine, square, and ramp signals for animation/modulation
local function signalGenerator( a_time )
    local val = 0.0

    if ( g_ret_next.ani_mode == 2 ) then -- Sine wave
        val =  0.5*(1.0 + math.sin(a_time * g_ret_next.ani_fac ))
    elseif ( g_ret_next.ani_mode == 3 ) then -- Square
        local diff = g_ani_trans_time - a_time
        if ( diff > g_ret_next.ani_fac*0.5 ) then
            val = 1.0
        elseif ( diff > 0 ) then
            val = 0.0
        else
            val = 1.0
            g_ani_trans_time = a_time + g_ret_next.ani_fac
        end
    else -- Ramp Up/Down
        if ( a_time < g_ani_trans_time ) then
            val = (g_ani_trans_time - a_time)/g_ret_next.ani_fac
        else
            val = 1.0
            g_ani_trans_time = a_time + g_ret_next.ani_fac
        end

        if ( g_ret_next.ani_mode == 4 ) then
            val = 1.0 - val
        end
    end

    return val
end

-- This is a global function --
-- This is the per-frame reticle update function. Tests environment and sets visible
-- reticle(s) accordingly. Also applies rotation and animation if enabled.
function CombatReticleOnUpdate( a_frame, a_time )
    if ( g_render_reticle ) then
        local low_priority = false
        local inter_mode = 0
        local owned

        owned_icon:SetHidden(true)
        
        -- This is the reticle mode detection logic
        if ( g_use_combat and g_in_combat ) then
            if ( g_in_stealth ) then
                g_ret_next = g_ret_data.stealth_combat
            else
                if g_use_combat_target then
                    --- Must get target info to determine normal/hostile/friendly mode
                    if IsUnitAttackable( "reticleover" ) then
                        if g_use_combat_hostile then
                            if GetUnitReaction( "reticleover" ) == UNIT_REACTION_HOSTILE then
                                g_ret_next = g_ret_data.combat_hostile
                            else
                                g_ret_next = g_ret_data.combat
                            end
                        else
                            g_ret_next = g_ret_data.combat
                        end
                    elseif g_use_combat_friendly then
                        if ( IsFriendlyCombatTarget() ) then
                            g_ret_next = g_ret_data.combat_friendly
                        else
                            g_ret_next = g_ret_data.combat
                        end
                    else
                        g_ret_next = g_ret_data.combat
                    end
                else
                    g_ret_next = g_ret_data.combat
                end
            end
        else
            local reaction = GetUnitReaction( "reticleover" )
            local attackable = IsUnitAttackable( "reticleover" )

            if ( g_use_hostile and attackable and reaction == UNIT_REACTION_HOSTILE ) then
                if ( g_in_stealth ) then
                    g_ret_next = g_ret_data.stealth_hostile
                else
                    low_priority = true
                    g_ret_next = g_ret_data.hostile
                end
            elseif ( g_use_neutral and attackable  and reaction ~= UNIT_REACTION_HOSTILE ) then
                if ( g_in_stealth ) then
                    g_ret_next = g_ret_data.stealth_neutral
                else
                    low_priority = true
                    g_ret_next = g_ret_data.neutral
                end
            else
                inter_mode, owned = IsTargetInteractable()

                if ( g_use_interact and inter_mode ~= 0 ) then
                    if ( inter_mode == 2 and  g_interact_mode == 3 ) then -- item is blocked and we need to display disabled state
                        if ( g_in_stealth ) then
                            g_ret_next = g_ret_data.stealth_interact_dis
                        else
                            low_priority = true
                            g_ret_next = g_ret_data.interact_dis
                        end
                    else
                        if ( g_in_stealth ) then
                            g_ret_next = g_ret_data.stealth_interact
                        else
                            low_priority = true
                            g_ret_next = g_ret_data.interact
                        end
                        
                        if ( g_show_owned and owned ) then
                                owned_icon:SetHidden(false)
                        end
                    end
                else
                    if ( g_in_stealth ) then
                        g_ret_next = g_ret_data.stealth_normal
                    else
                        g_ret_next = g_ret_data.normal
                    end
                end
            end
        end

        -- Note: due to stealth event timing, we can be in combat and in stealth-mode at the same time
 
        -- This is a bit of a hack - hiding alone doesn't seem to work, so set alpha to 0 as well
        if ( g_hide_interact_text ) then
            ZO_ReticleContainerInteract:SetHidden( true )
            ZO_ReticleContainerInteract:SetAlpha(0)
        end

        -- Suppress spurious low-priority reticle state changes faster than 0.2 seconds
        -- Respond immediately if going to combat, stealth, or normal modes
        if ( low_priority and g_delay_low_priority and ( g_ret_next ~= g_ret_last )) then
            if ( g_ret_detect_time ~= 0 ) then
                -- Count-down is running, check for expiration
                if ( a_time - g_ret_detect_time < 0.1 ) then
                    -- Still too soon, undo mode change
                    g_ret_next = g_ret_last
                else
                    -- Count-down expired, allow mode change 
                    g_ret_detect_time =  0
                end
            elseif ( g_ret_last ~= nil ) then
                -- Initial detection of low-priority mode change, begin count-down
                g_ret_detect_time = a_time
                -- Undo mode change
                g_ret_next = g_ret_last
            end
        else -- Mode switch may have been caneled, reset count-down
            g_ret_detect_time =  0
        end

        -- Don't currently track when the default reticle may have been shown
        -- by the client, so just hide it every time (it will be shown again if it's next)
        ZO_ReticleContainerReticle:SetHidden( true )

        if ( g_in_stealth and not g_in_combat ) then
            -- Apply stealth eye color/scale
            g_ret_next.reticle1:SetColor( g_ret_next.stealth_color_r, g_ret_next.stealth_color_g, g_ret_next.stealth_color_b, g_ret_next.stealth_color_a )
            g_ret_next.reticle1:SetScale( g_ret_next.stealth_scale )

            -- Hide stealth text
            if ( g_hide_stealth_text ) then
                ZO_ReticleContainerStealthIconStealthText:SetHidden( true )
            else
                ZO_ReticleContainerStealthIconStealthText:SetHidden( false )
            end
        end

        -- Hide previous reticles
        if ( g_ret_last ) then
            if ( g_ret_last.reticle1 ) then g_ret_last.reticle1:SetHidden( true ) end
            if ( g_ret_last.reticle2 ) then g_ret_last.reticle2:SetHidden( true ) end
        end

        -- Only continue if next base reticle is not nil
        if ( g_ret_next.reticle1 ) then
            -- Process rotation settings
            local mode = g_ret_next.rot_mode

            if ( mode > 1 ) then
                local apply = g_ret_next.rot_apply

                -- Calc delta t
                local t = 0
                if ( g_last_time > 0 ) then
                    t = a_time - g_last_time
                end

                g_ret_angle = g_ret_angle + (g_ret_next.rot_vel * t)

                if ( g_ret_angle > g_2PI ) then
                    g_ret_angle  = g_ret_angle - g_2PI
                elseif ( g_ret_angle < 0 ) then
                    g_ret_angle  = g_ret_angle + g_2PI
                end

                local val1 = g_ret_angle

                if ( mode > 3 ) then
                    val1 = (mode - 3)*.261799*math.sin( g_ret_angle )
                elseif ( mode == 2 ) then
                    val1 = -g_ret_angle
                end

                local val2 = val1

                if ( apply == 2 ) then
                    val2 = -val1
                end

                -- Rotate reticle 1, if appropriate
                if ( apply < 4 ) then
                    g_ret_next.reticle1:SetTextureRotation( val1 )
                end
                -- Rotate reticle 2, if appropriate
                if ( g_ret_next.rot_apply_r2 ) then
                    g_ret_next.reticle2:SetTextureRotation( val2 )
                end
            end

            -- Process animation settings
            if ( g_ret_next.ani_mode > 1 ) then
                local apply = g_ret_next.ani_apply

                -- generate modulation value
                local val1 = ((1.0 - g_ret_next.ani_min)*signalGenerator( a_time ))
                local val2

                if ( apply == 2 ) then
                    val2 = 1-val1
                else
                    val2 = val1 + g_ret_next.ani_min
                end

                val1 = val1 + g_ret_next.ani_min

                if ( g_ret_next.ani_prop == 1 ) then -- Transparency
                    if ( apply < 4 ) then
                        g_ret_next.reticle1:SetAlpha( val1 * g_ret_next.ani_v1 )
                    end
                    if ( g_ret_next.ani_apply_r2 ) then
                        g_ret_next.reticle2:SetAlpha( val2 * g_ret_next.ani_v2 )
                    end
                elseif ( g_ret_next.ani_prop == 2 ) then -- Saturation
                    if ( apply < 4 ) then
                        g_ret_next.reticle1:SetDesaturation( val1 )
                    end
                    if ( g_ret_next.ani_apply_r2 ) then
                        g_ret_next.reticle2:SetDesaturation( val2 )
                    end
                else -- Scale
                    if ( apply < 4 ) then
                        g_ret_next.reticle1:SetScale( val1 * g_ret_next.ani_v1 )
                    end
                    if ( g_ret_next.ani_apply_r2 ) then
                        g_ret_next.reticle2:SetScale( val2 * g_ret_next.ani_v2 )
                    end
                end
            end

            -- Show next reticles

            g_ret_next.reticle1:SetHidden( false )
            if ( g_ret_next.reticle2 ) then g_ret_next.reticle2:SetHidden( false ) end
        end

        g_ret_last = g_ret_next
        g_last_time = a_time
    end
end


-------------------------------------------------------------------------------
-- Reticle-related event handlers----------------------------------------------

local function CombatReticleHiddenState( a_event_code, a_hidden )
    if ( a_hidden ) then
        g_render_reticle = false
    else
        g_render_reticle = true
    end
end

local function CombatReticleCombatState( a_event_code, a_in_combat )
    g_in_combat = a_in_combat
end

local function CombatReticleStealthStateChanged( a_event_code, a_unit_tag, a_stealth_state )
    if ( a_unit_tag == "player" ) then
        if ( a_stealth_state == STEALTH_STATE_NONE ) then
            g_in_stealth = false
        else
            g_in_stealth = true
        end
    end
end

local function CombatReticleDisguiseStateChanged( a_event_code, a_unit_tag, a_disguise_state )
    if ( a_unit_tag == "player" ) then
        if ( a_disguise_state == DISGUISE_STATE_NONE ) then
            g_in_stealth = false
        else
            g_in_stealth = true
        end
    end
end

-------------------------------------------------------------------------------
-- Reticle Update Functions ---------------------------------------------------


-- Update an individual reticle based on specified settings
local function updateReticleFromSettings( a_ret_data, a_settings, a_stealth, a_disabled )
    -- Reset current reticle refs
    a_ret_data.reticle1 = nil
    a_ret_data.reticle2 = nil

    -- Hide custom controls whenever reticle is updated
    if ( not a_stealth ) then
        a_ret_data.custom1:SetHidden( true )
    end
    a_ret_data.custom2:SetHidden( true )

    -- Type 1 = None, setting reticle1/2 to nil above will disable all reticle processing for this mode
    -- Type 4 = Disable, globals set outside this function will cause this mode to be skipped
    if ( a_settings.ret_type == 1 or a_settings.ret_type == 4 ) then
        return
    end

    -- Type 2 = Default, ensure rotation and animation are disabled
    if ( a_settings.ret_type == 2 ) then
        a_ret_data.reticle1 = ZO_ReticleContainerReticle
        a_ret_data.rot_mode = 1
        a_ret_data.ani_mode = 1
        return
     end

    -- From here down, Type 3 - custom reticles only
    if ( not a_stealth ) then
        a_ret_data.reticle1 = a_ret_data.custom1
        a_ret_data.reticle1:SetTexture( g_category_data[a_settings.category].path .. a_settings.texture .. ".dds" )
        a_ret_data.reticle1:SetColor( a_settings.color.r, a_settings.color.g, a_settings.color.b, a_settings.color.a )
        a_ret_data.reticle1:SetScale( a_settings.scale/100.0 )
        a_ret_data.reticle1:SetTextureRotation( 0 )
        a_ret_data.reticle1:SetDesaturation(0)
    else
        a_ret_data.reticle1 = ZO_ReticleContainerStealthIconStealthEye
    end

    if ( a_settings.overlay == true ) then
        a_ret_data.reticle2 = a_ret_data.custom2
        a_ret_data.reticle2:SetTexture( g_category_data[a_settings.category2].path .. a_settings.texture2 .. ".dds" )
        a_ret_data.reticle2:SetColor( a_settings.color2.r, a_settings.color2.g, a_settings.color2.b, a_settings.color2.a )
        a_ret_data.reticle2:SetScale( a_settings.scale2/100.0 )
        a_ret_data.reticle2:SetTextureRotation( 0 )
        a_ret_data.reticle2:SetDesaturation(0)
    end

    if ( a_disabled ) then
        -- Disabled modes get grey color and rot/ani disabled
        if ( a_ret_data.reticle1 ) then
        a_ret_data.reticle1:SetColor( g_disabled_c, g_disabled_c, g_disabled_c, 1 )
        end
        
        if ( a_settings.overlay == true and a_ret_data.reticle2 ~= nil ) then
            a_ret_data.reticle2:SetColor( g_disabled_c, g_disabled_c, g_disabled_c, 1 )
        end

        a_ret_data.rot_mode = 1
        a_ret_data.ani_mode = 1
    else
        -- Rotation settings
        a_ret_data.rot_mode = a_settings.rot_mode
        a_ret_data.rot_apply = a_settings.rot_apply
        a_ret_data.rot_vel = g_2PI*a_settings.rot_vel*.02

        if (( a_ret_data.rot_apply ~= 3 ) and a_ret_data.reticle2 ~= nil ) then
            a_ret_data.rot_apply_r2 = true
        else
            a_ret_data.rot_apply_r2 = false
        end

        -- Animation settings
        a_ret_data.ani_mode = a_settings.ani_mode

        if ( a_settings.ani_mode > 1 ) then
            a_ret_data.ani_apply = a_settings.ani_apply
            a_ret_data.ani_min = a_settings.ani_min/100.0
            a_ret_data.ani_prop = a_settings.ani_prop

            if (( a_ret_data.ani_apply ~= 3 ) and a_ret_data.reticle2 ~= nil ) then
                a_ret_data.ani_apply_r2 = true
            else
                a_ret_data.ani_apply_r2 = false
            end

            if ( a_settings.ani_prop == 1 ) then -- Transparency
                a_ret_data.ani_v1 = a_settings.color.a
                a_ret_data.ani_v2 = a_settings.color2.a
            elseif ( a_settings.ani_prop == 3 ) then
                a_ret_data.ani_v1 = a_settings.scale/100.0
                a_ret_data.ani_v2 = a_settings.scale2/100.0
            end

            if ( a_settings.ani_mode == 2 ) then -- Sine, fac = frequency
                a_ret_data.ani_fac = g_2PI*a_settings.ani_speed*0.02
            elseif ( a_settings.ani_mode == 3 ) then -- Square,fac = 1/2 period
                a_ret_data.ani_fac = 0.5/(a_settings.ani_speed*0.02)
            else -- Ramps, fac = period
                a_ret_data.ani_fac = 1.0/(a_settings.ani_speed*0.02)
            end
        end
    end
 
    -- Override stealth constant settings
    if ( a_stealth ) then
        a_ret_data.rot_apply = 4;     -- Rotation can only affect reticle 2
        a_ret_data.ani_apply = 4;     -- Animation can only affect reticle 2
        if ( a_disabled ) then
            a_ret_data.stealth_color_r = g_disabled_c
            a_ret_data.stealth_color_g = g_disabled_c
            a_ret_data.stealth_color_b = g_disabled_c
            a_ret_data.stealth_color_a = 1
        else
            a_ret_data.stealth_color_r = a_settings.color.r
            a_ret_data.stealth_color_g = a_settings.color.g
            a_ret_data.stealth_color_b = a_settings.color.b
            a_ret_data.stealth_color_a = a_settings.color.a
        end

        a_ret_data.stealth_scale = a_settings.scale/100.0;
    end
end


-- Update all reticles based on current settings
local function updateAllReticlesFromSettings()
    -- Reset brightness on config updates
    g_brightness = 1.0

    -- Handle reticle type 4 ("disabled") here - these globals cause the mode to be skipped
    if ( g_settings.interact.ret_type == 4 ) then g_use_interact = false else g_use_interact = true end
    if ( g_settings.neutral.ret_type == 4 ) then g_use_neutral = false else g_use_neutral = true end
    if ( g_settings.hostile.ret_type == 4 ) then g_use_hostile = false else g_use_hostile = true end
    if ( g_settings.combat.ret_type == 4 ) then g_use_combat = false else g_use_combat = true end
    if ( g_settings.combat_hostile.ret_type == 4 ) then g_use_combat_hostile = false else g_use_combat_hostile = true end
    if ( g_settings.combat_friendly.ret_type == 4 ) then g_use_combat_friendly = false else g_use_combat_friendly = true end

    updateReticleFromSettings( g_ret_data.normal, g_settings.normal, false, false )
    updateReticleFromSettings( g_ret_data.hostile, g_settings.hostile, false, false )
    updateReticleFromSettings( g_ret_data.neutral, g_settings.neutral, false, false )
    updateReticleFromSettings( g_ret_data.combat, g_settings.combat, false, false )
    updateReticleFromSettings( g_ret_data.combat_hostile, g_settings.combat_hostile, false, false )
    updateReticleFromSettings( g_ret_data.combat_friendly, g_settings.combat_friendly, false, false )
    updateReticleFromSettings( g_ret_data.interact, g_settings.interact, false, false )

    --Update stealth modes here...
    updateReticleFromSettings( g_ret_data.stealth_normal, g_settings.stealth_normal, true, false )
    updateReticleFromSettings( g_ret_data.stealth_interact, g_settings.stealth_interact, true, false )
    updateReticleFromSettings( g_ret_data.stealth_neutral, g_settings.stealth_neutral, true, false )
    updateReticleFromSettings( g_ret_data.stealth_hostile, g_settings.stealth_hostile, true, false )
    updateReticleFromSettings( g_ret_data.stealth_combat, g_settings.stealth_combat, true, false )

    -- Copy interact settings to disabled interaction reticle and adjust colors/animations
    updateReticleFromSettings( g_ret_data.interact_dis, g_settings.interact, false, true )
    updateReticleFromSettings( g_ret_data.stealth_interact_dis, g_settings.stealth_interact, true, true )

    g_delay_low_priority = g_settings.delay_low_priority
    g_hide_interact_text = g_settings.hide_interact_text
    g_hide_stealth_text = g_settings.hide_stealth_text
    g_show_owned = g_settings.show_owned
    g_interact_mode = g_settings.interact_mode
    g_use_combat_target = g_use_combat_hostile or g_use_combat_friendly

    -- Undo alpha setting if user enables interact text
    if ( not g_hide_interact_text ) then
        ZO_ReticleContainerInteract:SetAlpha(1.0)
    end

    g_ret_last = nil
end

-- Internal brightness adjust for a single reticle
local function adjustReticleBrightness( a_ret_data, a_settings, a_stealth )
    if ( a_stealth ) then
        a_ret_data.stealth_color_r = a_settings.color.r * g_brightness
        a_ret_data.stealth_color_g = a_settings.color.g * g_brightness
        a_ret_data.stealth_color_b = a_settings.color.b * g_brightness
    else
        a_ret_data.custom1:SetColor(
            a_settings.color.r * g_brightness,
            a_settings.color.g * g_brightness,
            a_settings.color.b * g_brightness,
            a_settings.color.a )
    end

    a_ret_data.custom2:SetColor(
        a_settings.color2.r * g_brightness,
        a_settings.color2.g * g_brightness,
        a_settings.color2.b * g_brightness,
        a_settings.color2.a )
end

-- Internal brightness adjust for a disabled reticle
local function adjustReticleBrightnessDisabled( a_ret_data, a_stealth )
    if ( a_stealth ) then
        a_ret_data.stealth_color_r = g_disabled_c * g_brightness
        a_ret_data.stealth_color_g = g_disabled_c * g_brightness
        a_ret_data.stealth_color_b = g_disabled_c * g_brightness
    else
        a_ret_data.custom1:SetColor(
            g_disabled_c * g_brightness,
            g_disabled_c * g_brightness,
            g_disabled_c * g_brightness,
            1 )
    end

    a_ret_data.custom2:SetColor(
        g_disabled_c * g_brightness,
        g_disabled_c * g_brightness,
        g_disabled_c * g_brightness,
        1 )
end

-- Internal brightness adjust for all reticle modes
local function adjustBrightness( a_adj_lev )
    g_brightness = g_brightness + 0.2*a_adj_lev
    if ( g_brightness < 0 ) then
        g_brightness = 0
    elseif ( g_brightness > 1.0 ) then
        g_brightness = 1.0
    end

    adjustReticleBrightness( g_ret_data.normal, g_settings.normal, false )
    adjustReticleBrightness( g_ret_data.hostile, g_settings.hostile, false )
    adjustReticleBrightness( g_ret_data.neutral, g_settings.neutral, false )
    adjustReticleBrightness( g_ret_data.combat, g_settings.combat, false )
    adjustReticleBrightness( g_ret_data.combat_hostile, g_settings.combat_hostile, false )
    adjustReticleBrightness( g_ret_data.combat_friendly, g_settings.combat_friendly, false )
    adjustReticleBrightness( g_ret_data.interact, g_settings.interact, false )
 
    adjustReticleBrightness( g_ret_data.stealth_normal, g_settings.stealth_normal, true )
    adjustReticleBrightness( g_ret_data.stealth_hostile, g_settings.stealth_hostile, true )
    adjustReticleBrightness( g_ret_data.stealth_neutral, g_settings.stealth_neutral, true )
    adjustReticleBrightness( g_ret_data.stealth_interact, g_settings.stealth_interact, true )
    adjustReticleBrightness( g_ret_data.stealth_combat, g_settings.stealth_combat, true )

    adjustReticleBrightnessDisabled( g_ret_data.interact_dis, false )
    adjustReticleBrightnessDisabled( g_ret_data.stealth_interact_dis, true )
end


-- Process slash command
local function CombatReticleSettingsCommand( a_cmd )
    if ( a_cmd == nil or a_cmd:len() == 0 ) then
        CombatReticleShowConfig()
    elseif ( a_cmd:sub(1,1) == "+" ) then
        adjustBrightness( string.len(a_cmd));
    elseif ( a_cmd:sub(1,1) == "-" ) then
        adjustBrightness( -string.len(a_cmd));
    else
        -- Assume it's a slot or theme
        CombatReticleLoadSettings( a_cmd )
    end
end


-- Global function for hot-key brightness increase
function CombatReticleBrightnessIncrease()
    adjustBrightness(1)
end


-- Global function for hot-key brightness decrease
function CombatReticleBrightnessDecrease()
    adjustBrightness(-1)
end

-------------------------------------------------------------------------------
-- Add-on Initialization Code -------------------------------------------------

-- Creates and initializes reticle rendering control table for a specific mode
-- Includes reticle-specific on-screen controls (two per reticle-mode)
local function createReticleData( a_name, a_stealth )
    local data = {
        custom1 = nil,  -- Custom base texture control
        custom2 = nil,  -- Custom overlay texture control
        rot_mode = 1, -- Rotation enabled
        rot_apply = 1,  -- Which reticle rotation applies to
        rot_vel = 0.0,  -- Rotation angular velocity
        ani_mode = 1,
        ani_apply = 1,   -- Which reticle animation applies to
        ani_prop = 1,
        ani_fac = 0,
        ani_min = 0,
        ani_v1 = 1,
        ani_v2 = 1,
        reticle1 = nil, -- Current base reticle control (nil,ZO,Custom)
        reticle2 = nil  -- Current overlay reticle (nil,Custom)
    }

    -- Stealth mode uses default ZO control for reticle1
    if ( not a_stealth ) then
        data.custom1 = WINDOW_MANAGER:CreateControl( a_name .. "1", ZO_ReticleContainer, CT_TEXTURE )
        data.custom1:ClearAnchors()
        data.custom1:SetAnchor( CENTER, ZO_ReticleContainer, CENTER, 0, 0 )
        data.custom1:SetDimensions( g_reticle_size, g_reticle_size )
        data.custom1:SetHidden(true)
    end

    data.custom2 = WINDOW_MANAGER:CreateControl( a_name .. "2", ZO_ReticleContainer, CT_TEXTURE )
    data.custom2:ClearAnchors()
    data.custom2:SetAnchor( CENTER, ZO_ReticleContainer, CENTER, 0, 0 )
    data.custom2:SetDimensions( g_reticle_size, g_reticle_size )
    data.custom2:SetHidden(true)

    -- Force stealth-specific settings

    return data
end

-- Add-on Loaded callback function. Everything starts from here...
local function CombatReticleLoaded( a_event, a_name )
    if ( a_name == "CombatReticle" ) then
        --d("cr loaded")
    
        g_alliance = GetUnitAlliance("player")

        -- Construct reticle rendering control tables
        g_ret_data.normal   = createReticleData( "normal", false )
        g_ret_data.interact = createReticleData( "interact", false )
        g_ret_data.interact_dis = createReticleData( "interact_dis", false )
        g_ret_data.hostile  = createReticleData( "hostile", false )
        g_ret_data.neutral  = createReticleData( "neutral", false )
        g_ret_data.combat   = createReticleData( "combat", false )
        g_ret_data.combat_hostile   = createReticleData( "combat_hostile", false )
        g_ret_data.combat_friendly   = createReticleData( "combat_friendly", false )
        g_ret_data.stealth_normal   = createReticleData( "stealth_normal", true )
        g_ret_data.stealth_interact = createReticleData( "stealth_interact", true )
        g_ret_data.stealth_interact_dis = createReticleData( "stealth_interact_dis", true )
        g_ret_data.stealth_neutral  = createReticleData( "stealth_neutral", true )
        g_ret_data.stealth_hostile  = createReticleData( "stealth_hostile", true )
        g_ret_data.stealth_combat  = createReticleData( "stealth_combat", true )

        owned_icon = WINDOW_MANAGER:CreateControl( "CR_OWNED_ICON", ZO_ReticleContainer, CT_TEXTURE )
        owned_icon:ClearAnchors()
        owned_icon:SetAnchor( CENTER, ZO_ReticleContainer, CENTER, 36, -24 )
        owned_icon:SetTexture( "CombatReticle\\Textures\\Owned.dds" )
        owned_icon:SetDimensions( 64, 64 )
        owned_icon:SetColor( 255, 0, 0, .75 )
        owned_icon:SetScale( .4 )
        owned_icon:SetHidden(true)

        g_category_data = CombatReticleGetCategoryData()

        -- initialize settings module and get current settings
        g_settings = CombatReticleInitializeSettings( updateAllReticlesFromSettings )

        -- Update reticle control tables from current settings
        updateAllReticlesFromSettings()

        -- Register for various reticle events
        EVENT_MANAGER:RegisterForEvent( "CombatReticle", EVENT_RETICLE_HIDDEN_UPDATE, CombatReticleHiddenState )
        EVENT_MANAGER:RegisterForEvent( "CombatReticle", EVENT_PLAYER_COMBAT_STATE, CombatReticleCombatState )
        EVENT_MANAGER:RegisterForEvent( "CombatReticle", EVENT_STEALTH_STATE_CHANGED, CombatReticleStealthStateChanged )
        EVENT_MANAGER:RegisterForEvent( "CombatReticle", EVENT_DISGUISE_STATE_CHANGED, CombatReticleDisguiseStateChanged )
        
        CALLBACK_MANAGER:UnregisterCallback("CRT_Fubar", CRT_Fubar_Loaded )
    end
end

-- Register slash command
SLASH_COMMANDS["/cr"] = CombatReticleSettingsCommand

-- Register event callbacks
EVENT_MANAGER:RegisterForEvent( "CombatReticle", EVENT_ADD_ON_LOADED, CombatReticleLoaded )
