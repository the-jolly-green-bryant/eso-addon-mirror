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

--[[
 Slash Commands
=======================================
 Settings Panel
=======================================
/rp
=======================================
 Layouts
=======================================
/rp_default
/rp_narrow
/rp_wide
/rp_xwide
/rp_right
/rp_wideright
/rp_left
/rp_wideleft
=======================================
 Units selection
=======================================
/rp_set_mph
/rp_set_mps
/rp_set_kph
=======================================
 Enable/disable racing panel displays when mounted
 Enable/disable racing panel displays when on foot
=======================================
/rp_mounted_enabled
/rp_mounted_disabled
/rp_onfoot_enabled
/rp_onfoot_disabled
=======================================
 Enable/disable hiding of racing panel displays when menu is open
=======================================
/rp_inmenus_enabled
/rp_inmenus_disabled
/rp_disable_hiding
/rp_enable_hiding
=======================================
 Enable/disable each of the six elements
=======================================
/rp_speed_readout_enabled
/rp_speed_readout_disabled
/rp_speed_bar_enabled
/rp_speed_bar_disabled
/rp_stamina_bar_enabled
/rp_stamina_bar_disabled
/rp_majorbuff_bar_enabled
/rp_majorbuff_bar_disabled
/rp_minorbuff_bar_enabled
/rp_minorbuff_bar_disabled
/rp_panel_readout_enabled
/rp_panel_readout_disabled
=======================================
 Debug and programming commands
 RacingPanel.data only loads if sampling is on
 To have data, enable sampling and reload ui
=======================================
/rp_sampling_on XX (where X is integer sample size in seconds)
/rp_sampling_off
/rp_logging_enabled
/rp_logging_disabled
/rp_show_raw_data
/rp_delete_raw_data

--]]

SLASH_COMMANDS["/rp"] = function()
    RacingPanel:TogglePopup()
end
-- helper function
function RacingPanel.SetLayout(layout_text)
    RacingPanel.ShowMeters()
    RacingPanel.ClearAnchors()
    if layout_text == "n'wah_signature" then
        RacingPanel_SpeedDisplay:SetAnchor(CENTER, GuiRoot, CENTER, 385, 365)
        RacingPanel_SpeedMeter:SetAnchor(CENTER, GuiRoot, CENTER, 400, 100)
        RacingPanel_StaminaMeter:SetAnchor(CENTER, GuiRoot, CENTER, -400, 100)
        RacingPanel_MajorBuffMeter:SetAnchor(CENTER, GuiRoot, CENTER, -465, 100)
        RacingPanel_MinorBuffMeter:SetAnchor(CENTER, GuiRoot, CENTER, -516, 100)
        RacingPanel_PanelMeter:SetAnchor(CENTER, GuiRoot, CENTER, 0, 450)
    elseif layout_text == "narrow" then
        RacingPanel_SpeedDisplay:SetAnchor(CENTER, GuiRoot, CENTER, 0, 385)
        RacingPanel_SpeedMeter:SetAnchor(CENTER, GuiRoot, CENTER, 200, 100)
        RacingPanel_StaminaMeter:SetAnchor(CENTER, GuiRoot, CENTER, -200, 100)
        RacingPanel_MajorBuffMeter:SetAnchor(CENTER, GuiRoot, CENTER, -265, 100)
        RacingPanel_MinorBuffMeter:SetAnchor(CENTER, GuiRoot, CENTER, -316, 100)
        RacingPanel_PanelMeter:SetAnchor(CENTER, GuiRoot, CENTER, 0, 450)
    elseif layout_text == "wide" then
        RacingPanel_SpeedDisplay:SetAnchor(CENTER, GuiRoot, CENTER, 0, 385)
        RacingPanel_SpeedMeter:SetAnchor(CENTER, GuiRoot, CENTER, 400, 100)
        RacingPanel_StaminaMeter:SetAnchor(CENTER, GuiRoot, CENTER, -400, 100)
        RacingPanel_MajorBuffMeter:SetAnchor(CENTER, GuiRoot, CENTER, -465, 100)
        RacingPanel_MinorBuffMeter:SetAnchor(CENTER, GuiRoot, CENTER, -516, 100)
        RacingPanel_PanelMeter:SetAnchor(CENTER, GuiRoot, CENTER, 0, 450)
    elseif layout_text == "extra_wide" then
        RacingPanel_SpeedDisplay:SetAnchor(CENTER, GuiRoot, CENTER, 0, 385)
        RacingPanel_SpeedMeter:SetAnchor(CENTER, GuiRoot, CENTER, 500, 100)
        RacingPanel_StaminaMeter:SetAnchor(CENTER, GuiRoot, CENTER, -500, 100)
        RacingPanel_MajorBuffMeter:SetAnchor(CENTER, GuiRoot, CENTER, -565, 100)
        RacingPanel_MinorBuffMeter:SetAnchor(CENTER, GuiRoot, CENTER, -616, 100)
        RacingPanel_PanelMeter:SetAnchor(CENTER, GuiRoot, CENTER, 0, 450)
    elseif layout_text == "left" then
        RacingPanel_SpeedDisplay:SetAnchor(CENTER, GuiRoot, CENTER, 0, 385)
        RacingPanel_SpeedMeter:SetAnchor(TOPRIGHT, GuiRoot, CENTER, -345, 40)
        RacingPanel_StaminaMeter:SetAnchor(TOPRIGHT, GuiRoot, CENTER, -405, 40)
        RacingPanel_MajorBuffMeter:SetAnchor(TOPRIGHT, GuiRoot, CENTER, -470, 40)
        RacingPanel_MinorBuffMeter:SetAnchor(TOPRIGHT, GuiRoot, CENTER, -521, 40)
        RacingPanel_PanelMeter:SetAnchor(CENTER, GuiRoot, CENTER, 0, 450)
    elseif layout_text == "far_left" then
        RacingPanel_SpeedDisplay:SetAnchor(CENTER, GuiRoot, CENTER, 0, 385)
        RacingPanel_SpeedMeter:SetAnchor(TOPRIGHT, GuiRoot, CENTER, -580, -20)
        RacingPanel_StaminaMeter:SetAnchor(TOPRIGHT, GuiRoot, CENTER, -640, -20)
        RacingPanel_MajorBuffMeter:SetAnchor(TOPRIGHT, GuiRoot, CENTER, -705, -20)
        RacingPanel_MinorBuffMeter:SetAnchor(TOPRIGHT, GuiRoot, CENTER, -756, -20)
        RacingPanel_PanelMeter:SetAnchor(CENTER, GuiRoot, CENTER, 0, 450)
    elseif layout_text == "right" then
        RacingPanel_SpeedDisplay:SetAnchor(CENTER, GuiRoot, CENTER, 0, 385)
        RacingPanel_SpeedMeter:SetAnchor(TOPLEFT, GuiRoot, CENTER, 405, 40)
        RacingPanel_StaminaMeter:SetAnchor(TOPLEFT, GuiRoot, CENTER,  345, 40)
        RacingPanel_MajorBuffMeter:SetAnchor(TOPLEFT, GuiRoot, CENTER, 470, 40)
        RacingPanel_MinorBuffMeter:SetAnchor(TOPLEFT, GuiRoot, CENTER, 521, 40)
        RacingPanel_PanelMeter:SetAnchor(CENTER, GuiRoot, CENTER, 0, 450)
    elseif layout_text == "far_right" then
        RacingPanel_SpeedDisplay:SetAnchor(CENTER, GuiRoot, CENTER, 0, 385)
        RacingPanel_SpeedMeter:SetAnchor(TOPLEFT, GuiRoot, CENTER, 640, -20)
        RacingPanel_StaminaMeter:SetAnchor(TOPLEFT, GuiRoot, CENTER,  580, -20)
        RacingPanel_MajorBuffMeter:SetAnchor(TOPLEFT, GuiRoot, CENTER, 705, -20)
        RacingPanel_MinorBuffMeter:SetAnchor(TOPLEFT, GuiRoot, CENTER, 756, -20)
        RacingPanel_PanelMeter:SetAnchor(CENTER, GuiRoot, CENTER, 0, 450)
    else -- default
        RacingPanel_SpeedDisplay:SetAnchor(CENTER, GuiRoot, CENTER, 0, 385)
        RacingPanel_SpeedMeter:SetAnchor(CENTER, GuiRoot, CENTER, 300, 100)
        RacingPanel_StaminaMeter:SetAnchor(CENTER, GuiRoot, CENTER, -300, 100)
        RacingPanel_MajorBuffMeter:SetAnchor(CENTER, GuiRoot, CENTER, -365, 100)
        RacingPanel_MinorBuffMeter:SetAnchor(CENTER, GuiRoot, CENTER, -416, 100)
        RacingPanel_PanelMeter:SetAnchor(CENTER, GuiRoot, CENTER, 0, 450)
    end
    RacingPanel.SaveLocations()
end
-- end helper function
SLASH_COMMANDS["/rp_default"] = function()
    RacingPanel.SetLayout("default")
end
SLASH_COMMANDS["/rp_narrow"] = function()
    RacingPanel.SetLayout("narrow")
end
SLASH_COMMANDS["/rp_wide"] = function()
    RacingPanel.SetLayout("wide")
end
SLASH_COMMANDS["/rp_xwide"] = function()
    RacingPanel.SetLayout("extra_wide")
end
SLASH_COMMANDS["/rp_right"] = function()
    RacingPanel.SetLayout("right")
end
SLASH_COMMANDS["/rp_wideright"] = function()
    RacingPanel.SetLayout("far_right")
end
SLASH_COMMANDS["/rp_left"] = function()
    RacingPanel.SetLayout("left")
end
SLASH_COMMANDS["/rp_wideleft"] = function()
    RacingPanel.SetLayout("far_left")
end
SLASH_COMMANDS["/rp_set_mph"] = function()
    RacingPanel.settings.speed_units = "mph"
    RacingPanel_SpeedDisplay_UnitsText:SetText(RacingPanel.settings.speed_units)
    RacingPanel.SaveSettings()
end
SLASH_COMMANDS["/rp_set_mps"] = function()
    RacingPanel.settings.speed_units = "m/s"
    RacingPanel_SpeedDisplay_UnitsText:SetText(RacingPanel.settings.speed_units)
    RacingPanel.SaveSettings()
end
SLASH_COMMANDS["/rp_set_kph"] = function()
    RacingPanel.settings.speed_units = "kph"
    RacingPanel_SpeedDisplay_UnitsText:SetText(RacingPanel.settings.speed_units)
    RacingPanel.SaveSettings()
end
SLASH_COMMANDS["/rp_mounted_enabled"] = function()
    RacingPanel.settings.display_mounted = true
    RacingPanel.SaveSettings()
    RacingPanel.ShowHideMeters(IsMounted())
end
SLASH_COMMANDS["/rp_mounted_disabled"] = function()
    RacingPanel.settings.display_mounted = false
    RacingPanel.SaveSettings()
    RacingPanel.ShowHideMeters(IsMounted())
end
SLASH_COMMANDS["/rp_onfoot_enabled"] = function()
    RacingPanel.settings.display_on_foot = true
    RacingPanel.SaveSettings()
    RacingPanel.ShowHideMeters(IsMounted())
end
SLASH_COMMANDS["/rp_onfoot_disabled"] = function()
    RacingPanel.settings.display_on_foot = false
    RacingPanel.SaveSettings()
    RacingPanel.ShowHideMeters(IsMounted())
end
SLASH_COMMANDS["/rp_enable_hiding"] = function()
    RacingPanel.EnableHiding()
end
SLASH_COMMANDS["/rp_disable_hiding"] = function()
    RacingPanel.DisableHiding()
end
SLASH_COMMANDS["/rp_inmenus_disabled"] = function()
    RacingPanel.EnableHiding()
end
SLASH_COMMANDS["/rp_inmenus_enabled"] = function()
    RacingPanel.DisableHiding()
end
SLASH_COMMANDS["/rp_speed_readout_enabled"] = function()
    RacingPanel.settings.speed_readout_enabled = true
    RacingPanel.SaveSettings()
    RacingPanel.ShowHideMeters(IsMounted())
end
SLASH_COMMANDS["/rp_speed_readout_disabled"] = function()
    RacingPanel.settings.speed_readout_enabled = false
    RacingPanel.SaveSettings()
    RacingPanel.ShowHideMeters(IsMounted())
end
SLASH_COMMANDS["/rp_speed_bar_enabled"] = function()
    RacingPanel.settings.speed_bar_enabled = true
    RacingPanel.SaveSettings()
    RacingPanel.ShowHideMeters(IsMounted())
end
SLASH_COMMANDS["/rp_speed_bar_disabled"] = function()
    RacingPanel.settings.speed_bar_enabled = false
    RacingPanel.SaveSettings()
    RacingPanel.ShowHideMeters(IsMounted())
end
SLASH_COMMANDS["/rp_stamina_bar_enabled"] = function()
    RacingPanel.settings.stamina_bar_enabled = true
    RacingPanel.SaveSettings()
    RacingPanel.ShowHideMeters(IsMounted())
end
SLASH_COMMANDS["/rp_stamina_bar_disabled"] = function()
    RacingPanel.settings.stamina_bar_enabled = false
    RacingPanel.SaveSettings()
    RacingPanel.ShowHideMeters(IsMounted())
end
SLASH_COMMANDS["/rp_majorbuff_bar_enabled"] = function()
    RacingPanel.settings.majorbuff_bar_enabled = true
    RacingPanel.SaveSettings()
    RacingPanel.ShowHideMeters(IsMounted())
end
SLASH_COMMANDS["/rp_majorbuff_bar_disabled"] = function()
    RacingPanel.settings.majorbuff_bar_enabled = false
    RacingPanel.SaveSettings()
    RacingPanel.ShowHideMeters(IsMounted())
end
SLASH_COMMANDS["/rp_minorbuff_bar_enabled"] = function()
    RacingPanel.settings.minorbuff_bar_enabled = true
    RacingPanel.SaveSettings()
    RacingPanel.ShowHideMeters(IsMounted())
end
SLASH_COMMANDS["/rp_minorbuff_bar_disabled"] = function()
    RacingPanel.settings.minorbuff_bar_enabled = false
    RacingPanel.SaveSettings()
    RacingPanel.ShowHideMeters(IsMounted())
end
SLASH_COMMANDS["/rp_panel_readout_enabled"] = function()
    RacingPanel.settings.panel_readout_enabled = true
    RacingPanel.SaveSettings()
    RacingPanel.ShowHideMeters(IsMounted())
end
SLASH_COMMANDS["/rp_panel_readout_disabled"] = function()
    RacingPanel.settings.panel_readout_enabled = false
    RacingPanel.SaveSettings()
    RacingPanel.ShowHideMeters(IsMounted())
end
SLASH_COMMANDS["/rp_sampling_on"] = function(set_sample_size_sec)
    RacingPanel.settings.sampling_on = true
    RacingPanel.data = RacingPanel.savedVariables.data
    if tonumber(set_sample_size_sec) ~= nil then
        RacingPanel.settings.sample_length_sec = tonumber(set_sample_size_sec)
    end
    RacingPanel.SaveSettings()
    local zone, subzone = RacingPanel.GetZoneCommaSubzone()
    RacingPanel_PanelMeter_Line1:SetText("Sampling : " .. zone .. ":" .. subzone)
    RacingPanel.ShowHideMeters(IsMounted())
    RacingPanel.ReInitializeSampling()
    if RacingPanel.settings.logging_enabled then
        d("Racing Panel Sampling : ON")
        d("Racing Panel Sample Length : " .. RacingPanel.settings.sample_length_sec .. " SEC")
    end
end
SLASH_COMMANDS["/rp_sampling_off"] = function()
    RacingPanel.settings.sampling_on = false
    RacingPanel.settings.sample_length_sec = 10
    RacingPanel.SaveSettings()
    RacingPanel.ShowHideMeters(IsMounted())
    _startMove = 0
    _startWatch = 0
    RacingPanel_PanelMeter_Line1:SetText("")
    RacingPanel_PanelMeter_Line2:SetText("")
    if RacingPanel.settings.panel_readout_enabled then
        RacingPanel.ReInitializePanelReadout()
    end
    if RacingPanel.settings.logging_enabled then
        d("Racing Panel Sampling : OFF")
    end
end
SLASH_COMMANDS["/rp_logging_enabled"] = function()
    RacingPanel.settings.logging_enabled = true
    d("Racing Panel Logging : ON")end
SLASH_COMMANDS["/rp_logging_disabled"] = function()
    RacingPanel.settings.logging_enabled = false
    d("Racing Panel Logging : OFF ")
end
SLASH_COMMANDS["/rp_show_raw_data"] = function()
    d(RacingPanel.data)
    for zone, zone_data in pairs(RacingPanel.data) do
        d("     Zone : " .. zone)
        for subzone, subzone_data in pairs(zone_data) do
            d("  Subzone : " .. subzone)
            local count = 0
            local sum = 0
            for i = 1, #subzone_data do
                if (type(subzone_data[i]) == "number") and (subzone_data[i] > 0) then
                    count = count + 1
                    sum = sum + subzone_data[i]
                end
            end
            d("    Count : " .. count)
            d("  Average : " .. (sum / count))
        end
    end
end
SLASH_COMMANDS["/rp_delete_raw_data"] = function()
    RacingPanel.data = {}
    RacingPanel.savedVariables.data = RacingPanel.data
end
-------------------------------
-- End of File