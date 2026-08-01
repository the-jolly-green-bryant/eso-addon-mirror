--[[
    ________             _____                    ________                   ______
    ___  __ \_____ _________(_)_____________ _    ___  __ \_____ _______________  /
    __  /_/ /  __ `/  ___/_  /__  __ \_  __ `/    __  /_/ /  __ `/_  __ \  _ \_  /
    _  _, _// /_/ // /__ _  / _  / / /  /_/ /     _  ____// /_/ /_  / / /  __/  /
    /_/ |_| \__,_/ \___/ /_/  /_/ /_/_\__, /      /_/     \__,_/ /_/ /_/\___//_/
                                        /____/

    =======================================
                Racing Panel
            Proudly Sponsored By
            N'wah Leaf Importers
	=======================================
	       @Undyne Keith Mitchell
]]--=======================================

RacingPanel = {}
RacingPanel.name = "RacingPanel"
RacingPanel.version = 1.0 -- 2018-07-24
RacingPanel.variableVersion = 1.0
-- local refs to the global vars table
local GetGameTimeMilliseconds = _G["GetGameTimeMilliseconds"]
local GetMapPlayerPosition = _G["GetMapPlayerPosition"]
local IsMounted = _G["IsMounted"]
local ServerName = GetWorldName()
-- display units are "mph", "kph", or "m/s"
RacingPanel.settings = {
    speed_units = "mph",
    base_walkspeed_mps = 1.35,
    display_on_foot = true,
    display_mounted = true,
    stamina_bar_enabled = true,
    majorbuff_bar_enabled = true,
    minorbuff_bar_enabled = true,
    speed_bar_enabled = true,
    speed_readout_enabled = true,
    panel_readout_enabled = false,
    high_precision = false,
    hiding_enabled = true,
    course_records = false,
    post_results =  false,
    sampling_on = false,
    sample_length_sec = 10,
    logging_enabled = false,
}
RacingPanel.layout = {
    stamina_offset_x = 883.6215820313,
    stamina_offset_y = 578.1308593750,
    majorbuff_offset_x = 823.6215820313,
    majorbuff_offset_y = 578.1308593750,
    minorbuff_offset_x = 775.1215820313,
    minorbuff_offset_y = 578.1308593750,
    speed_offset_x = 1483.6215820313,
    speed_offset_y = 578.1308593750,
    display_offset_x = 1095.1215820313,
    display_offset_y = 1035.6308593750,
    panel_offset_x = 1001.1215820313,
    panel_offset_y = 1101.6308593750,
}
RacingPanel.data = {}
RacingPanel.Default = {
    settings = RacingPanel.settings,
    layout = RacingPanel.layout,
    data = RacingPanel.data
}
--popup
local popup_active = false;
--calibration
local _rp_calibration_mps = 4.5
local _rp_calibration_mph = 10.0662
local _rp_calibration_kph = 16.2
local _rp_calibration_maxscale_mps = 15.75
local _rp_calibration_maxscale_mph = 35.2317
local _rp_calibration_maxscale_kph = 56.7
--speedo
local _rp_std_buffer = 20
local _rp_tick = 0
local _rp_speed_then = 0
local _rp_speed_then_then = 0
local _rp_then, _rp_X_then, _rp_Y_then, _rp_zone_then, _rp_subzone_then
local _rp_map_scale_value
--major buff; gallop or expedition
local _rp_major_buff_tick = 0
local _rp_major_expedition_active = false
local _rp_major_expedition_endtime
local _rp_major_expedition_max_scale_duration_ms = 27000
local _rp_major_gallop_active = false
local _rp_major_gallop_endtime
local _rp_major_gallop_max_scale_duration_ms = 27000
--minor expedition
local _rp_minor_buff_tick = 0
local _rp_minor_buff_active = false
local _rp_minor_buff_endtime
local _rp_minor_buff_max_scale_duration_ms = 8000
--sampling
local _rs_std_buffer = 5
local _rs_tick = 0
local _rs_start_zone, _rs_start_subzone, _rs_start_move, _rs_start_watch, _rs_start_x, _rs_start_y
-------------------------------
-- OnAddOnLoaded
function RacingPanel.OnAddOnLoaded(event, addonName)
   if addonName ~= RacingPanel.name then return end
   RacingPanel:Initialize()
end
-------------------------------
-- Initialize
function RacingPanel:Initialize()
    -- user settings and keybinding
    --RacingPanel.savedVariables = ZO_SavedVars:New("RacingPanelSettings", RacingPanel.variableVersion, nil, RacingPanel.Default)
    RacingPanel.savedVariables = ZO_SavedVars:New("RacingPanelSettings", RacingPanel.variableVersion, ServerName, RacingPanel.Default)
    ZO_CreateStringId("SI_BINDING_NAME_RACINGPANEL_TOGGLE", "Show Racing Panel Settings")
    -- restore user settings
    if (RacingPanel.savedVariables ~= nil) then
        if RacingPanel.savedVariables.settings then
             RacingPanel.settings = RacingPanel.savedVariables.settings
        end
        if RacingPanel.savedVariables.layout then
            RacingPanel.layout = RacingPanel.savedVariables.layout
        end
        if RacingPanel.settings.sampling_on then
            if RacingPanel.savedVariables.data then
                RacingPanel.data = RacingPanel.savedVariables.data
            end
        end
    else
        RacingPanel.SaveSettings()
    end
    -- set local (fast) calibration values
    local walkspeed_mps = RacingPanel.settings.base_walkspeed_mps
    RacingPanel.SetCalibration(walkspeed_mps)
    -- set buffer according to precision
    if RacingPanel.settings.high_precision then
        _rp_std_buffer = 10
    end
    -- popup settings panel
    RacingPanel.Initialize_DropDowns()
    -- initialize speedometer
    RacingPanel_SpeedDisplay_UnitsText:SetText(RacingPanel.settings.speed_units)
    -- initialize stamina meter
    if IsMounted() then -- On your horse? In your spider?
        RacingPanel_MajorBuffMeter_Label:SetText("M-Ga")
        local current, max, effectiveMax = GetUnitPower("player", POWERTYPE_MOUNT_STAMINA)
        if RacingPanel.settings.display_mounted then
            RacingPanel.ShowMeters()
        else
            RacingPanel.HideMeters()
        end
    else -- Or just on your lowly feet?
        RacingPanel_MajorBuffMeter_Label:SetText("M-Ex")
        local current, max, effectiveMax = GetUnitPower("player", POWERTYPE_STAMINA)
        if RacingPanel.settings.display_on_foot then
            RacingPanel.ShowMeters()
        else
            RacingPanel.HideMeters()
        end
    end
    RacingPanel_StaminaMeter_StatusBar:SetMinMax(0, max)
    RacingPanel_StaminaMeter_StatusBar:SetValue(current)
    -- initialize major buff meter (gallop or expedition)
    RacingPanel_MajorBuffMeter_StatusBar:SetMinMax(0, 27000)
    RacingPanel_MajorBuffMeter_StatusBar:SetValue(0) --22000
    -- initialize minor buff meter expedition
    RacingPanel_MinorBuffMeter_StatusBar:SetMinMax(0, 8000)
    RacingPanel_MinorBuffMeter_StatusBar:SetValue(0) --4000
    -- initialize panel meter
    local zone, subzone = RacingPanel.GetZoneCommaSubzone()
    -- if racing panel logging, warn
    if RacingPanel.settings.logging_enabled then
        d("Racing Panel Logging : ON")
    end
    -- if racing panel readout, show panel
    if RacingPanel.settings.panel_readout_enabled then
        RacingPanel.ReInitializePanelReadout()
        if RacingPanel.settings.logging_enabled then
            d("Racing Panel Readout : ON")
            d("Race Course Selected : None")
        end
    end
    -- if taking samples, show panel
    if RacingPanel.settings.sampling_on then
        RacingPanel_PanelMeter_Line1:SetText("Sampling : " .. zone .. ":" .. subzone)
        RacingPanel.ReInitializeSampling()
        if RacingPanel.settings.logging_enabled then
            d("Racing Panel Sampling : ON")
            d("Racing Panel Sample Length : " .. RacingPanel.settings.sample_length_sec .. " SEC")
        end
    end
    -- initialize UI
    RacingPanel.ClearAnchors()
    if RacingPanel.savedVariables.layout then
        -- mount to UI
        RacingPanel_StaminaMeter:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RacingPanel.savedVariables.layout.stamina_offset_x, RacingPanel.savedVariables.layout.stamina_offset_y)
        RacingPanel_MajorBuffMeter:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RacingPanel.savedVariables.layout.majorbuff_offset_x, RacingPanel.savedVariables.layout.majorbuff_offset_y)
        RacingPanel_MinorBuffMeter:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RacingPanel.savedVariables.layout.minorbuff_offset_x, RacingPanel.savedVariables.layout.minorbuff_offset_y)
        RacingPanel_SpeedMeter:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RacingPanel.savedVariables.layout.speed_offset_x, RacingPanel.savedVariables.layout.speed_offset_y)
        RacingPanel_SpeedDisplay:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RacingPanel.savedVariables.layout.display_offset_x, RacingPanel.savedVariables.layout.display_offset_y)
        RacingPanel_PanelMeter:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RacingPanel.savedVariables.layout.panel_offset_x, RacingPanel.savedVariables.layout.panel_offset_y)
    else
        -- use defaults
        RacingPanel_StaminaMeter:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RacingPanel.layout.stamina_offset_x, RacingPanel.layout.stamina_offset_y)
        RacingPanel_MajorBuffMeter:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RacingPanel.layout.majorbuff_offset_x, RacingPanel.layout.majorbuff_offset_y)
        RacingPanel_MinorBuffMeter:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RacingPanel.layout.minorbuff_offset_x, RacingPanel.layout.minorbuff_offset_y)
        RacingPanel_SpeedMeter:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RacingPanel.layout.speed_offset_x, RacingPanel.layout.speed_offset_y)
        RacingPanel_SpeedDisplay:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RacingPanel.layout.display_offset_x, RacingPanel.layout.display_offset_y)
        RacingPanel_PanelMeter:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RacingPanel.layout.panel_offset_x, RacingPanel.layout.panel_offset_y)
    end
    RacingPanel.SaveLocations()
    -- no need to run the OnLoaded function again
    EVENT_MANAGER:UnregisterForEvent(RacingPanel.name, EVENT_ADD_ON_LOADED)
    -- Zone Change Events
    EVENT_MANAGER:RegisterForEvent(RacingPanel.name, EVENT_ZONE_CHANGED, RacingPanel.OnZoneChange)
    EVENT_MANAGER:RegisterForEvent(RacingPanel.name, EVENT_ZONE_UPDATE, RacingPanel.OnZoneUpdate)
    -- Stamina Change Event
    EVENT_MANAGER:RegisterForEvent(RacingPanel.name, EVENT_POWER_UPDATE, RacingPanel.UpdateStamina)
    -- Effects/Buffs Change Event
    EVENT_MANAGER:RegisterForEvent(RacingPanel.name, EVENT_EFFECT_CHANGED, RacingPanel.UpdateEffects)
    -- Mounted State and Menu-Mode Toggle Events
    EVENT_MANAGER:RegisterForEvent(RacingPanel.name, EVENT_MOUNTED_STATE_CHANGED, RacingPanel.OnMountedStateChange)
    EVENT_MANAGER:RegisterForEvent(RacingPanel.name, EVENT_RETICLE_HIDDEN_UPDATE, RacingPanel.OnReticleHidden)
end
-------------------------------
-- OnUpdate Functions, as specified in XML
-- THESE RUN ONLY FOR ELEMENTS WHICH ARE DISPLAYED
function RacingPanel.OnSpeedMeterUpdate()
    -- only run the speedo bar-meter game-tick
    -- IF THE SPEED DISPLAY (NUMERIC SPEEDOMENTER) IS NOT DISPLAYED
    if RacingPanel_SpeedDisplay:IsHidden() then
        RacingPanel.GetSpeed()
    end
end
function RacingPanel.OnSpeedDisplayUpdate()
    -- the speedo game-tick runs
    -- IF THE SPEED DISPLAY (NUMERIC SPEEDOMENTER) IS DISPLAYED
    -- the speedo game-tick CANNOT be used to show/hide the speedo
    RacingPanel.GetSpeed()
end
function RacingPanel.OnMajorBuffMeterUpdate()
    -- the major buff game-tick runs if the meter is displayed
    if (_rp_major_expedition_active or _rp_major_gallop_active) and RacingPanel.settings.majorbuff_bar_enabled then
        RacingPanel.RunMajorBuffMeter()
    end
end
function RacingPanel.OnMinorBuffMeterUpdate()
    -- the minor buff game-tick runs if the meter is displayed
    if _rp_minor_buff_active and RacingPanel.settings.minorbuff_bar_enabled then
        RacingPanel.RunMinorBuffMeter()
    end
end
function RacingPanel.OnPanelMeterUpdate()
    -- THESE ONLY RUN IF THE TWO-LINE PANEL DISPLAY IS SHOWING
    -- sampling or race tracks
    if RacingPanel.settings.sampling_on then
        RacingPanel.RunSamplingMeter()
    else
        RacingPanel.RunRacingPanel()
    end
end
-------------------------------
-- Speed Functions
function RacingPanel.GetSpeed()
    if IsPlayerMoving() then
        if _rp_tick >= _rp_std_buffer then
            --d(_rp_std_buffer)
            local _rp_zone, _rp_subzone = RacingPanel.GetZoneCommaSubzone()
            local _rp_now = GetGameTimeMilliseconds()
            local _rp_X, _rp_Y = GetMapPlayerPosition("player")
            if ((_rp_zone == _rp_zone_then) and (_rp_subzone == _rp_subzone_then)) then
                if MapScaleData.hasMapScale(_rp_zone, _rp_subzone) then
                    -- we're in business
                    local _rp_units = RacingPanel.GetCoordinateDistance(_rp_X, _rp_Y, _rp_X_then, _rp_Y_then)
                    local _rp_milli_units = _rp_units * 1000
                    local _rp_msecs = _rp_now - _rp_then
                    local _rp_secs = _rp_msecs / 1000
                    local _rp_milli_units_per_sec = _rp_milli_units / _rp_secs
                    --d(_rp_milli_units_per_sec) 7.983427055816
                    _rp_map_scale_value = MapScaleData.getMapScale(_rp_zone, _rp_subzone)
                    --d(_rp_map_scale_value) 8.61773
                    local _rp_speed_value = RacingPanel.GetSpeedValue(_rp_milli_units_per_sec, _rp_map_scale_value)
                    -- if high-precision mode, take average, to reduce flicker
                    -- if not high-precision mode, take weighted average
                    if RacingPanel.settings.high_precision then
                        RacingPanel.SetSpeedValue((_rp_speed_value + _rp_speed_then)/2)
                    else
                        RacingPanel.SetSpeedValue((_rp_speed_value + _rp_speed_value + _rp_speed_then + _rp_speed_then)/4)
                    end
                    -- display was updated
                    _rp_speed_then_then = _rp_speed_then
                    _rp_speed_then = _rp_speed_value
                end
            end
            -- set reference values for next loop
            _rp_zone_then = _rp_zone
            _rp_subzone_then = _rp_subzone
            _rp_then = _rp_now
            _rp_X_then = _rp_X
            _rp_Y_then = _rp_Y
            _rp_tick = 0
        else -- increment
            _rp_tick = _rp_tick + 1
        end
    else
        RacingPanel.ZeroSpeedDisplay()
    end
end
function RacingPanel.GetSpeed_Miles_Per_Hour_mph(measured_value, scale)
    return ((measured_value * _rp_calibration_mph) / scale)
end
function RacingPanel.GetSpeed_Meters_Per_Second_mps(measured_value, scale)
    return ((measured_value * _rp_calibration_mps) / scale)
end
function RacingPanel.GetSpeed_Kilometers_Per_Hour_kph(measured_value, scale)
    return ((measured_value * _rp_calibration_kph) / scale)
end
function RacingPanel.GetSpeedValue(measured_value, scale)
    if (RacingPanel.settings.speed_units == "mph") then
        return ((measured_value * _rp_calibration_mph) / scale)
    elseif (RacingPanel.settings.speed_units == "m/s") then
        return ((measured_value * _rp_calibration_mps) / scale)
    elseif (RacingPanel.settings.speed_units == "kph") then
        return ((measured_value * _rp_calibration_kph) / scale)
    end
    return 0
end
function RacingPanel.SetSpeedValue(speed_value)
    -- small text display
    RacingPanel_SpeedDisplay_ValueText:SetText(string.format("%.2f",speed_value)) --"%4d",speed_value)) --"%02d",speed_value))
    -- moving display bar
    if RacingPanel.settings.speed_units == "mph" then
        RacingPanel_SpeedMeter_StatusBar:SetMinMax(0, _rp_calibration_maxscale_mph)
    elseif RacingPanel.settings.speed_units == "m/s" then
        RacingPanel_SpeedMeter_StatusBar:SetMinMax(0, _rp_calibration_maxscale_mps)
    elseif RacingPanel.settings.speed_units == "kph" then
        RacingPanel_SpeedMeter_StatusBar:SetMinMax(0, _rp_calibration_maxscale_kph)
    end
    RacingPanel_SpeedMeter_StatusBar:SetValue(speed_value)
end
function RacingPanel.ZeroSpeedDisplay()
    -- small text display
    RacingPanel_SpeedDisplay_ValueText:SetText(" -.--")
    -- moving display bar
    RacingPanel_SpeedMeter_StatusBar:SetValue(0)
end
function RacingPanel.SetCalibration(walkspeed_mps)
    -- establish valid default
    local valid = {
        [1.25] = true,
        [1.30] = true,
        [1.35] = true,
        [1.40] = true,
        [1.45] = true,
        [1.50] = true,
        [1.55] = true,
        [1.60] = true,
    }
    if not valid[walkspeed_mps] then
        walkspeed_mps = 1.35
    end
    -- set local variables before saving calibration
    -- walk speed is 30% of default/jogging/calibration speed
    _rp_calibration_mps = walkspeed_mps / 0.3
    -- convert to kph, multiply by 3.6
    -- (3600 * meters/sec) / 1000 m/km
    _rp_calibration_kph = 3.6 * _rp_calibration_mps
    -- convert to mph
    _rp_calibration_mph = 0.6213712 * _rp_calibration_kph
    -- more local variables
    _rp_calibration_maxscale_mps = 3.5 * _rp_calibration_mps
    _rp_calibration_maxscale_mph = 3.5 * _rp_calibration_mph
    _rp_calibration_maxscale_kph = 3.5 * _rp_calibration_kph
    -- save calibration
    RacingPanel.settings.base_walkspeed_mps = walkspeed_mps
    RacingPanel.savedVariables.settings = RacingPanel.settings
end
-------------------------------
-- major buff meter
function RacingPanel.RunMajorBuffMeter()
    if _rp_major_buff_tick >= _rp_std_buffer then
        local time_remains = 0
        local isMounted = IsMounted()
        if isMounted and _rp_major_gallop_active then
            time_remains = 100
            if _rp_major_gallop_endtime > 0 then
                time_remains = _rp_major_gallop_endtime - GetGameTimeMilliseconds()
                if time_remains <= 0 then
                    time_remains = 0
                    _rp_major_gallop_endtime = 0
                    _rp_major_gallop_active = false
                end
            end
        elseif (not isMounted) and _rp_major_expedition_active then
            time_remains = 100
            if _rp_major_expedition_endtime > 0 then
                time_remains = _rp_major_expedition_endtime - GetGameTimeMilliseconds()
                if time_remains <= 0 then
                    time_remains = 0
                    _rp_major_expedition_endtime = 0
                    _rp_major_expedition_active = false
                end
            end
        end
        RacingPanel_MajorBuffMeter_StatusBar:SetValue(time_remains)
        _rp_major_buff_tick = 0
    else -- increment
        _rp_major_buff_tick = _rp_major_buff_tick + 1
    end
end
-- minor buff meter
function RacingPanel.RunMinorBuffMeter()
    if _rp_minor_buff_tick >= _rp_std_buffer then
        local time_remains = 0
        if _rp_minor_buff_active then
            time_remains = 100
            if _rp_minor_buff_endtime >= 0 then
                time_remains = _rp_minor_buff_endtime - GetGameTimeMilliseconds()
                if time_remains < 0 then
                    time_remains = 0
                    _rp_minor_buff_endtime = 0
                    _rp_minor_buff_active = false
                end
            end
        end
        RacingPanel_MinorBuffMeter_StatusBar:SetValue(time_remains)
        _rp_minor_buff_tick = 0
    else -- increment
        _rp_minor_buff_tick = _rp_minor_buff_tick + 1
    end
end
-------------------------------
-- Race Panel Functions
function RacingPanel.RunRacingPanel()
end
function RacingPanel.ReInitializePanelReadout()
    RacingPanel_PanelMeter_Line1:SetText("Racing Panel Says:")
    RacingPanel_PanelMeter_Line2:SetText("Please Choose a Race Course")
    RacingPanel_PanelMeter:SetHidden(false)
end
-------------------------------
-- Sampling Meter Functions
function RacingPanel.RunSamplingMeter()
    if IsPlayerMoving() then
        if _rs_tick >= _rs_std_buffer then
            local _rs_zone, _rs_subzone = RacingPanel.GetZoneCommaSubzone()
            RacingPanel_PanelMeter_Line1:SetText("Sampling : " .. _rs_zone .. ":" .. _rs_subzone)
            if (_rs_start_move == 0) then
                _rs_start_move = GetGameTimeMilliseconds()
                _rs_start_watch = 0
                _rs_tick = 0
            else
                local _rs_now = GetGameTimeMilliseconds()
                local _rs_diff = _rs_now - _rs_start_move
                local _rs_pre_sample_time_ms = 3000
                if (RacingPanel.settings.sample_length_sec < 3) then
                    _rs_pre_sample_time_ms = RacingPanel.settings.sample_length_sec * 1000
                end
                -- have we started the timer yet?
                if (_rs_start_watch == 0) then -- no, start it
                    if (_rs_diff > _rs_pre_sample_time_ms) then
                        _rs_start_x, _rs_start_y = GetMapPlayerPosition("player")
                        _rs_start_watch = GetGameTimeMilliseconds()
                        _rs_start_zone = _rs_zone
                        _rs_start_subzone = _rs_subzone
                        RacingPanel_PanelMeter_Line2:SetText("Sample Started... ")
                    end
                else -- yes, determine if can stop it
                    if (_rs_diff > ((RacingPanel.settings.sample_length_sec * 1000) + _rs_pre_sample_time_ms)) then
                        local _rs_end_x, _rs_end_y = GetMapPlayerPosition("player")
                        local _rs_end_watch = GetGameTimeMilliseconds()
                        if  ((_rs_zone == _rs_start_zone) and (_rs_subzone == _rs_start_subzone)) then
                            local _rs_units = RacingPanel.GetCoordinateDistance(_rs_start_x, _rs_start_y, _rs_end_x, _rs_end_y)
                            local _rs_milli_units = _rs_units * 1000
                            local _rs_msecs = _rs_end_watch - _rs_start_watch
                            local _rs_secs = _rs_msecs / 1000
                            local _rs_milli_units_per_sec = _rs_milli_units / _rs_secs
                            MapScaleData.appendRawData(RacingPanel.data, _rs_zone, _rs_subzone, _rs_milli_units_per_sec)
                            _rs_start_move = 0
                            _rs_start_watch = 0
                            RacingPanel_PanelMeter_Line2:SetText("Sample Taken : " .. _rs_milli_units_per_sec)
                            if RacingPanel.settings.logging_enabled then
                                local _rs_sample_count, _rs_sample_average =  MapScaleData.getRawDataCountAndAverage(RacingPanel.data, _rs_zone, _rs_subzone)
                                d("---" .. _rs_zone .. ":" .. _rs_subzone .. "----------------")
                                d("    data sample: " .. _rs_milli_units_per_sec .. " milli-units/s")
                                d("   data entries: " .. _rs_sample_count)
                                d("   data average: " .. _rs_sample_average)
                                d("---------------------------------------------------")
                            end
                            --
                            RacingPanel.savedVariables.data = RacingPanel.data
                        else
                            RacingPanel.ReInitializeSampling()
                        end
                    else
                        RacingPanel_PanelMeter_Line2:SetText("Sample Started... " .. string.format("%.1f", ((_rs_diff - _rs_pre_sample_time_ms) / 1000)) .. " sec")
                    end
                end
            end
            _rs_tick = 0
        else -- increment
            _rs_tick = _rs_tick + 1
        end
    else
        RacingPanel.ReInitializeSampling()
    end
end
function RacingPanel.ReInitializeSampling()
    _rs_start_move = 0
    _rs_start_watch = 0
    _rs_tick = 0
    RacingPanel_PanelMeter_Line2:SetText("Jog steadily to take a sample")
    RacingPanel_PanelMeter:SetHidden(false)
end
-------------------------------
-- Clear Anchors, Save Locations
-- Save Settings, Show/Hide Meters
-- Enable/Disable Hiding when menu is open
function RacingPanel.ClearAnchors()
    RacingPanel_StaminaMeter:ClearAnchors()
    RacingPanel_MajorBuffMeter:ClearAnchors()
    RacingPanel_MinorBuffMeter:ClearAnchors()
    RacingPanel_SpeedMeter:ClearAnchors()
    RacingPanel_SpeedDisplay:ClearAnchors()
    RacingPanel_PanelMeter:ClearAnchors()
end
function RacingPanel.SaveLocations()
    RacingPanel.layout.stamina_offset_x = RacingPanel_StaminaMeter:GetLeft()
	RacingPanel.layout.stamina_offset_y = RacingPanel_StaminaMeter:GetTop()
    RacingPanel.layout.majorbuff_offset_x = RacingPanel_MajorBuffMeter:GetLeft()
	RacingPanel.layout.majorbuff_offset_y = RacingPanel_MajorBuffMeter:GetTop()
    RacingPanel.layout.minorbuff_offset_x = RacingPanel_MinorBuffMeter:GetLeft()
	RacingPanel.layout.minorbuff_offset_y = RacingPanel_MinorBuffMeter:GetTop()
	RacingPanel.layout.speed_offset_x = RacingPanel_SpeedMeter:GetLeft()
	RacingPanel.layout.speed_offset_y = RacingPanel_SpeedMeter:GetTop()
	RacingPanel.layout.display_offset_x = RacingPanel_SpeedDisplay:GetLeft()
	RacingPanel.layout.display_offset_y = RacingPanel_SpeedDisplay:GetTop()
	RacingPanel.layout.panel_offset_x = RacingPanel_PanelMeter:GetLeft()
    RacingPanel.layout.panel_offset_y = RacingPanel_PanelMeter:GetTop()
    RacingPanel.savedVariables.layout = RacingPanel.layout
end
function RacingPanel.SaveSettings()
    RacingPanel.savedVariables.settings = RacingPanel.settings
    RacingPanel.savedVariables.layout = RacingPanel.layout
end
function RacingPanel.ShowHideMeters(isMounted)
    if isMounted == nil then
        isMounted = IsMounted()
    end
    if isMounted then
        if RacingPanel.settings.display_mounted then
            RacingPanel.ShowMeters()
        else
            RacingPanel.HideMeters()
        end
    else
        if RacingPanel.settings.display_on_foot then
            RacingPanel.ShowMeters()
        else
            RacingPanel.HideMeters()
        end
    end
end
function RacingPanel.ShowMeters()
    RacingPanel_SpeedDisplay:SetHidden(RacingPanel.settings.speed_readout_enabled == false)
    RacingPanel_SpeedMeter:SetHidden(RacingPanel.settings.speed_bar_enabled == false)
    RacingPanel_StaminaMeter:SetHidden(RacingPanel.settings.stamina_bar_enabled == false)
    RacingPanel_MajorBuffMeter:SetHidden(RacingPanel.settings.majorbuff_bar_enabled == false)
    RacingPanel_MinorBuffMeter:SetHidden(RacingPanel.settings.minorbuff_bar_enabled == false or IsMounted())
    if RacingPanel.settings.panel_readout_enabled or RacingPanel.settings.sampling_on then
        RacingPanel_PanelMeter:SetHidden(false)
    else
        RacingPanel_PanelMeter:SetHidden(true)
    end
end
function RacingPanel.HideMeters()
    RacingPanel_StaminaMeter:SetHidden(true)
    RacingPanel_MajorBuffMeter:SetHidden(true)
    RacingPanel_MinorBuffMeter:SetHidden(true)
    RacingPanel_SpeedMeter:SetHidden(true)
    RacingPanel_SpeedDisplay:SetHidden(true)
    if not RacingPanel.settings.sampling_on then
        RacingPanel_PanelMeter:SetHidden(true)
    end
end
-------------------------------
-- Enable/Disable hiding when menu is open
function RacingPanel.EnableHiding()
    RacingPanel.settings.hiding_enabled = true
    RacingPanel.savedVariables.settings = RacingPanel.settings
end
function RacingPanel.DisableHiding()
    RacingPanel.settings.hiding_enabled = false
    RacingPanel.savedVariables.settings = RacingPanel.settings
end
-------------------------------
-- Settings Popup
function RacingPanel:TogglePopup()
    RacingPanel_Popup:SetHidden(popup_active)
	popup_active = not popup_active
    SetGameCameraUIMode(popup_active)
end
-------------------------------
--GetCurrentMapIndex()
--GetMapIndexByZoneId(zoneid)
--GetMapInfo(index) name, mapType, mapContentType, zoneId, description
--GetZoneDescription(zoneindex)
--GetZoneNameById(zoneid)
--GetZoneDescriptionById(zoneid)
--GetZoneId(zoneindex)
--GetZoneIndex(zoneid)
--GetCurrentMapZoneIndex()
--GetZoneNameByIndex(number zoneIndex)
--GetMapNameByIndex(number mapIndex)
-------------------------------
-- Core Tools
function RacingPanel.GetZoneSlashSubzone()
    return select(3,(GetMapTileTexture()):lower():find("maps/([%w%-]+/[%w%-]+_[%w%-]+)"))
end
function RacingPanel.GetZoneCommaSubzone()
    return select(3,(GetMapTileTexture()):lower():find("maps/([%w%-]+)/([%w%-]+_[%w%-]+)"))
end
function RacingPanel.GetCoordinateDistance(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt(dx * dx + dy * dy)
end
function RacingPanel.OnZoneChange(eventCode, newZone, newSubzone, is_new_subzone, zoneId, subzoneId)
    zone, subzone = RacingPanel.GetZoneCommaSubzone()
end
function RacingPanel.OnZoneUpdate(eventCode, unitTag, newZone)
    zone, subzone = RacingPanel.GetZoneCommaSubzone()
end
function RacingPanel.OnMountedStateChange(eventCode, isMounted)
    if isMounted then
        RacingPanel_MajorBuffMeter_Label:SetText("M-Ga")
        if RacingPanel.settings.display_mounted then
            local current, max, effectiveMax = GetUnitPower("player", POWERTYPE_MOUNTED_STAMINA)
            RacingPanel_StaminaMeter_StatusBar:SetMinMax(0, max)
            RacingPanel_StaminaMeter_StatusBar:SetValue(current)
            RacingPanel.ShowMeters()
        else
            RacingPanel.HideMeters()
        end
    else
        RacingPanel_MajorBuffMeter_Label:SetText("M-Ex")
        if RacingPanel.settings.display_on_foot then
            local current, max, effectiveMax = GetUnitPower("player", POWERTYPE_MOUNTED_STAMINA)
            RacingPanel_StaminaMeter_StatusBar:SetMinMax(0, max)
            RacingPanel_StaminaMeter_StatusBar:SetValue(current)
            RacingPanel.ShowMeters()
        else
            RacingPanel.HideMeters()
        end
    end
    if RacingPanel.settings.sampling_on then
        RacingPanel.ReInitializeSampling()
    end
end
function RacingPanel.UpdateStamina(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    local isMounted = IsMounted()
    if powerType == POWERTYPE_MOUNT_STAMINA then
        if isMounted then
            RacingPanel_StaminaMeter_StatusBar:SetMinMax(0, powerMax)
            RacingPanel_StaminaMeter_StatusBar:SetValue(powerValue)
        end
    elseif powerType == POWERTYPE_STAMINA then
        if (not isMounted) then
            RacingPanel_StaminaMeter_StatusBar:SetMinMax(0, powerMax)
            RacingPanel_StaminaMeter_StatusBar:SetValue(powerValue)
        end
    end
end
function RacingPanel.UpdateEffects(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if RacingPanel.settings.majorbuff_bar_enabled or RacingPanel.settings.minorbuff_bar_enabled then
        if unitTag == "player" then
            local isMajorExpedition = true
            local isMajorGallop = true
            local isMinorExpedition = true
            if string.find(iconName, "buff_major_gallop") == nil then
                isMajorGallop = false
            end
            if string.find(iconName, "buff_major_expedition") == nil then
                isMajorExpedition = false
            end
            if string.find(iconName, "buff_minor_expedition") == nil then
                isMinorExpedition = false
            end
            --d(" changeType 1=start, 2=end: " .. changeType)
            --d("                beginTime : " .. beginTime)
            --d("                  endTime : " .. endTime)
            if isMajorExpedition or isMajorGallop or isMinorExpedition then
                -- begin DO SOMETHING (try to let this function exit as quickly as possible)
                local isMounted = IsMounted()
                if isMajorGallop and RacingPanel.settings.majorbuff_bar_enabled then
                    _rp_major_gallop_active = false
                    _rp_major_gallop_endtime  = 0
                    _rp_major_gallop_max_scale_duration_ms = 100
                    if changeType == 1 then
                        _rp_major_gallop_active = true
                        if not (beginTime == nil or endTime == nil) then
                            _rp_major_gallop_endtime = endTime * 1000
                            _rp_major_gallop_max_scale_duration_ms = _rp_major_gallop_endtime - (beginTime * 1000)
                        end
                        if isMounted then
                            RacingPanel_MajorBuffMeter_StatusBar:SetMinMax(0, _rp_major_gallop_max_scale_duration_ms)
                        end
                    elseif changeType == 2 then
                        if isMounted then
                            RacingPanel_MajorBuffMeter_StatusBar:SetValue(0)
                        end
                    end
                    --d("     _rp_major_gallop_endtime : " .. _rp_major_gallop_endtime)
                    --d("    _rp_max_scale_duration_ms : " .. _rp_major_gallop_max_scale_duration_ms)
                elseif isMajorExpedition and RacingPanel.settings.majorbuff_bar_enabled then
                    _rp_major_expedition_active = false
                    _rp_major_expedition_endtime  = 0
                    _rp_major_expedition_max_scale_duration_ms = 100
                    if changeType == 1 then
                        _rp_major_expedition_active = true
                        if not (beginTime == nil or endTime == nil) then
                            _rp_major_expedition_endtime = endTime * 1000
                            _rp_major_expedition_max_scale_duration_ms = _rp_major_expedition_endtime - (beginTime * 1000)
                        end
                        if not isMounted then
                            RacingPanel_MajorBuffMeter_StatusBar:SetMinMax(0, _rp_major_expedition_max_scale_duration_ms)
                        end
                    elseif changeType == 2 then
                        if not isMounted then
                            RacingPanel_MajorBuffMeter_StatusBar:SetValue(0)
                        end
                    end
                    --d(" _rp_major_expedition_endtime : " .. _rp_major_expedition_endtime)
                    --d("    _rp_max_scale_duration_ms : " .. _rp_major_expedition_max_scale_duration_ms)
                elseif isMinorExpedition and RacingPanel.settings.minorbuff_bar_enabled then
                    _rp_minor_buff_active = false
                    _rp_minor_buff_endtime = 0
                    _rp_minor_buff_max_scale_duration_ms = 100
                    if changeType == 1 then
                        _rp_minor_buff_active = true
                        if not (beginTime == nil or endTime == nil) then
                            _rp_minor_buff_endtime = endTime * 1000
                            _rp_minor_buff_max_scale_duration_ms = _rp_minor_buff_endtime - (beginTime * 1000)
                        end
                        if not isMounted then
                            RacingPanel_MinorBuffMeter_StatusBar:SetMinMax(0, _rp_minor_buff_max_scale_duration_ms)
                        end
                    elseif changeType == 2 then
                        if not isMounted then
                            RacingPanel_MinorBuffMeter_StatusBar:SetValue(0)
                        end
                    end
                end
                -- end DO SOMETHING
            end
        end
    end
end
function RacingPanel.OnReticleHidden(eventCode, hidden)
    if hidden then
        if RacingPanel.settings.hiding_enabled then
            RacingPanel.HideMeters()
        end
    else
        RacingPanel.ShowHideMeters()
    end
end
-------------------------------
-- OnLoad
EVENT_MANAGER:RegisterForEvent(RacingPanel.name, EVENT_ADD_ON_LOADED, RacingPanel.OnAddOnLoaded)
-- End