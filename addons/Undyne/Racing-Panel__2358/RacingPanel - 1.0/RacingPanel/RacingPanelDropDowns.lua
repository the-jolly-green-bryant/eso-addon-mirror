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

-------------------------------
-- Settings Popup initializer
function RacingPanel.Initialize_DropDowns()
    RacingPanel.Initialize_DD_SpeedUnits()
    RacingPanel.Initialize_DD_Layouts()
    -- first forms divider
    RacingPanel.Initialize_DD_EnableMounted()
    RacingPanel.Initialize_DD_EnableOnFoot()
    RacingPanel.Initialize_DD_EnableInMenu()
    RacingPanel.Initialize_DD_HighPrecision()
    -- second column
    RacingPanel.Initialize_DD_ShowSpeedDisplay()
    RacingPanel.Initialize_DD_ShowSpeedMeter()
    RacingPanel.Initialize_DD_ShowStaminaMeter()
    RacingPanel.Initialize_DD_ShowMajorBuffMeter()
    RacingPanel.Initialize_DD_ShowMinorBuffMeter()
    -- second forms divider
    RacingPanel.Initialize_DD_Calibration()
    -- used in v.next branch
    RacingPanel.Initialize_DD_EnableRaceCourse()
    RacingPanel.Initialize_DD_Courses()
    RacingPanel.Initialize_DD_SaveCourseRecords()
    RacingPanel.Initialize_DD_PostRaceResults()
end
function RacingPanel.Initialize_DD_SpeedUnits()
    RacingPanel_Popup_DropDown_SpeedUnits.comboBox = RacingPanel_Popup_DropDown_SpeedUnits.comboBox or ZO_ComboBox_ObjectFromContainer(RacingPanel_Popup_DropDown_SpeedUnits)
    local DD_SpeedUnits = RacingPanel_Popup_DropDown_SpeedUnits.comboBox
    DD_SpeedUnits:AddItem(DD_SpeedUnits:CreateItemEntry("mph - Miles / Hour", RacingPanel.OnSpeedUnitsSelect))
    DD_SpeedUnits:AddItem(DD_SpeedUnits:CreateItemEntry("kph - Km / Hour", RacingPanel.OnSpeedUnitsSelect))
    DD_SpeedUnits:AddItem(DD_SpeedUnits:CreateItemEntry("m/s - Meters / Sec", RacingPanel.OnSpeedUnitsSelect))
    if (RacingPanel.settings.speed_units == "kph") then
        DD_SpeedUnits:SetSelectedItem("kph - Km / Hour")
    elseif (RacingPanel.settings.speed_units == "m/s") then
        DD_SpeedUnits:SetSelectedItem("m/s - Meters / Sec")
    else
        DD_SpeedUnits:SetSelectedItem("mph - Miles / Hour")
    end
end
function RacingPanel.Initialize_DD_Layouts()
    RacingPanel_Popup_DropDown_Layouts.comboBox = RacingPanel_Popup_DropDown_Layouts.comboBox or ZO_ComboBox_ObjectFromContainer(RacingPanel_Popup_DropDown_Layouts)
    local DD_Layouts = RacingPanel_Popup_DropDown_Layouts.comboBox
    DD_Layouts:AddItem(DD_Layouts:CreateItemEntry("Default Layout", RacingPanel.OnLayoutsSelect))
    DD_Layouts:AddItem(DD_Layouts:CreateItemEntry("Extra Wide Layout", RacingPanel.OnLayoutsSelect))
    DD_Layouts:AddItem(DD_Layouts:CreateItemEntry("Far Left Layout", RacingPanel.OnLayoutsSelect))
    DD_Layouts:AddItem(DD_Layouts:CreateItemEntry("Far Right Layout", RacingPanel.OnLayoutsSelect))
    DD_Layouts:AddItem(DD_Layouts:CreateItemEntry("Left Layout", RacingPanel.OnLayoutsSelect))
    DD_Layouts:AddItem(DD_Layouts:CreateItemEntry("N'wah Signature Layout", RacingPanel.OnLayoutsSelect))
    DD_Layouts:AddItem(DD_Layouts:CreateItemEntry("Narrow Layout", RacingPanel.OnLayoutsSelect))
    DD_Layouts:AddItem(DD_Layouts:CreateItemEntry("Right Layout", RacingPanel.OnLayoutsSelect))
    DD_Layouts:AddItem(DD_Layouts:CreateItemEntry("Wide Layout", RacingPanel.OnLayoutsSelect))
    DD_Layouts:SetSelectedItem("Select a Layout...")
end
function RacingPanel.Initialize_DD_EnableMounted()
    RacingPanel_Popup_DropDown_EnableMounted.comboBox = RacingPanel_Popup_DropDown_EnableMounted.comboBox or ZO_ComboBox_ObjectFromContainer(RacingPanel_Popup_DropDown_EnableMounted)
    local DD_EnableMounted = RacingPanel_Popup_DropDown_EnableMounted.comboBox
    DD_EnableMounted:AddItem(DD_EnableMounted:CreateItemEntry("Yes", RacingPanel.OnEnableMountedSelect))
    DD_EnableMounted:AddItem(DD_EnableMounted:CreateItemEntry("No", RacingPanel.OnEnableMountedSelect))
    if RacingPanel.settings.display_mounted then
        DD_EnableMounted:SetSelectedItem("Yes")
    else
        DD_EnableMounted:SetSelectedItem("No")
    end
end
function RacingPanel.Initialize_DD_EnableOnFoot()
    RacingPanel_Popup_DropDown_EnableOnFoot.comboBox = RacingPanel_Popup_DropDown_EnableOnFoot.comboBox or ZO_ComboBox_ObjectFromContainer(RacingPanel_Popup_DropDown_EnableOnFoot)
    local DD_EnableOnFoot = RacingPanel_Popup_DropDown_EnableOnFoot.comboBox
    DD_EnableOnFoot:AddItem(DD_EnableOnFoot:CreateItemEntry("Yes", RacingPanel.OnEnableOnFootSelect))
    DD_EnableOnFoot:AddItem(DD_EnableOnFoot:CreateItemEntry("No", RacingPanel.OnEnableOnFootSelect))
    if RacingPanel.settings.display_on_foot then
        DD_EnableOnFoot:SetSelectedItem("Yes")
    else
        DD_EnableOnFoot:SetSelectedItem("No")
    end
end
function RacingPanel.Initialize_DD_EnableInMenu()
    RacingPanel_Popup_DropDown_EnableInMenu.comboBox = RacingPanel_Popup_DropDown_EnableInMenu.comboBox or ZO_ComboBox_ObjectFromContainer(RacingPanel_Popup_DropDown_EnableInMenu)
    local DD_EnableInMenu = RacingPanel_Popup_DropDown_EnableInMenu.comboBox
    DD_EnableInMenu:AddItem(DD_EnableInMenu:CreateItemEntry("Yes", RacingPanel.OnEnableInMenuSelect))
    DD_EnableInMenu:AddItem(DD_EnableInMenu:CreateItemEntry("No", RacingPanel.OnEnableInMenuSelect))
    if RacingPanel.settings.hiding_enabled then
        DD_EnableInMenu:SetSelectedItem("No")
    else
        DD_EnableInMenu:SetSelectedItem("Yes")
    end
end
function RacingPanel.Initialize_DD_HighPrecision()
    RacingPanel_Popup_DropDown_HighPrecision.comboBox = RacingPanel_Popup_DropDown_HighPrecision.comboBox or ZO_ComboBox_ObjectFromContainer(RacingPanel_Popup_DropDown_HighPrecision)
    local DD_HighPrecision = RacingPanel_Popup_DropDown_HighPrecision.comboBox
    DD_HighPrecision:AddItem(DD_HighPrecision:CreateItemEntry("Yes", RacingPanel.OnHighPrecisionSelect))
    DD_HighPrecision:AddItem(DD_HighPrecision:CreateItemEntry("No", RacingPanel.OnHighPrecisionSelect))
    if RacingPanel.settings.high_precision then
        DD_HighPrecision:SetSelectedItem("Yes")
    else
        DD_HighPrecision:SetSelectedItem("No")
    end
end
function RacingPanel.Initialize_DD_ShowSpeedDisplay()
    RacingPanel_Popup_DropDown_ShowSpeedDisplay.comboBox = RacingPanel_Popup_DropDown_ShowSpeedDisplay.comboBox or ZO_ComboBox_ObjectFromContainer(RacingPanel_Popup_DropDown_ShowSpeedDisplay)
    local DD_ShowSpeedDisplay = RacingPanel_Popup_DropDown_ShowSpeedDisplay.comboBox
    DD_ShowSpeedDisplay:AddItem(DD_ShowSpeedDisplay:CreateItemEntry("Show", RacingPanel.OnShowSpeedDisplaySelect))
    DD_ShowSpeedDisplay:AddItem(DD_ShowSpeedDisplay:CreateItemEntry("Hide", RacingPanel.OnShowSpeedDisplaySelect))
    if RacingPanel.settings.speed_readout_enabled then
        DD_ShowSpeedDisplay:SetSelectedItem("Show")
    else
        DD_ShowSpeedDisplay:SetSelectedItem("Hide")
    end
end
function RacingPanel.Initialize_DD_ShowSpeedMeter()
    RacingPanel_Popup_DropDown_ShowSpeedMeter.comboBox = RacingPanel_Popup_DropDown_ShowSpeedMeter.comboBox or ZO_ComboBox_ObjectFromContainer(RacingPanel_Popup_DropDown_ShowSpeedMeter)
    local DD_ShowSpeedMeter = RacingPanel_Popup_DropDown_ShowSpeedMeter.comboBox
    DD_ShowSpeedMeter:AddItem(DD_ShowSpeedMeter:CreateItemEntry("Show", RacingPanel.OnShowSpeedMeterSelect))
    DD_ShowSpeedMeter:AddItem(DD_ShowSpeedMeter:CreateItemEntry("Hide", RacingPanel.OnShowSpeedMeterSelect))
    if RacingPanel.settings.speed_bar_enabled then
        DD_ShowSpeedMeter:SetSelectedItem("Show")
    else
        DD_ShowSpeedMeter:SetSelectedItem("Hide")
    end
end
function RacingPanel.Initialize_DD_ShowStaminaMeter()
    RacingPanel_Popup_DropDown_ShowStaminaMeter.comboBox = RacingPanel_Popup_DropDown_ShowStaminaMeter.comboBox or ZO_ComboBox_ObjectFromContainer(RacingPanel_Popup_DropDown_ShowStaminaMeter)
    local DD_ShowStaminaMeter = RacingPanel_Popup_DropDown_ShowStaminaMeter.comboBox
    DD_ShowStaminaMeter:AddItem(DD_ShowStaminaMeter:CreateItemEntry("Show", RacingPanel.OnShowStaminaMeterSelect))
    DD_ShowStaminaMeter:AddItem(DD_ShowStaminaMeter:CreateItemEntry("Hide", RacingPanel.OnShowStaminaMeterSelect))
    if RacingPanel.settings.stamina_bar_enabled then
        DD_ShowStaminaMeter:SetSelectedItem("Show")
    else
        DD_ShowStaminaMeter:SetSelectedItem("Hide")
    end
end
function RacingPanel.Initialize_DD_ShowMajorBuffMeter()
    RacingPanel_Popup_DropDown_ShowMajorBuffMeter.comboBox = RacingPanel_Popup_DropDown_ShowMajorBuffMeter.comboBox or ZO_ComboBox_ObjectFromContainer(RacingPanel_Popup_DropDown_ShowMajorBuffMeter)
    local DD_ShowMajorBuffMeter = RacingPanel_Popup_DropDown_ShowMajorBuffMeter.comboBox
    DD_ShowMajorBuffMeter:AddItem(DD_ShowMajorBuffMeter:CreateItemEntry("Show", RacingPanel.OnShowMajorBuffMeterSelect))
    DD_ShowMajorBuffMeter:AddItem(DD_ShowMajorBuffMeter:CreateItemEntry("Hide", RacingPanel.OnShowMajorBuffMeterSelect))
    if RacingPanel.settings.majorbuff_bar_enabled then
        DD_ShowMajorBuffMeter:SetSelectedItem("Show")
    else
        DD_ShowMajorBuffMeter:SetSelectedItem("Hide")
    end
end
function RacingPanel.Initialize_DD_ShowMinorBuffMeter()
    RacingPanel_Popup_DropDown_ShowMinorBuffMeter.comboBox = RacingPanel_Popup_DropDown_ShowMinorBuffMeter.comboBox or ZO_ComboBox_ObjectFromContainer(RacingPanel_Popup_DropDown_ShowMinorBuffMeter)
    local DD_ShowMinorBuffMeter = RacingPanel_Popup_DropDown_ShowMinorBuffMeter.comboBox
    DD_ShowMinorBuffMeter:AddItem(DD_ShowMinorBuffMeter:CreateItemEntry("Show", RacingPanel.OnShowMinorBuffMeterSelect))
    DD_ShowMinorBuffMeter:AddItem(DD_ShowMinorBuffMeter:CreateItemEntry("Hide", RacingPanel.OnShowMinorBuffMeterSelect))
    if RacingPanel.settings.minorbuff_bar_enabled then
        DD_ShowMinorBuffMeter:SetSelectedItem("Show")
    else
        DD_ShowMinorBuffMeter:SetSelectedItem("Hide")
    end
end
function RacingPanel.Initialize_DD_Calibration()
    RacingPanel_Popup_DropDown_Calibration.comboBox = RacingPanel_Popup_DropDown_Calibration.comboBox or ZO_ComboBox_ObjectFromContainer(RacingPanel_Popup_DropDown_Calibration)
    local DD_Calibration = RacingPanel_Popup_DropDown_Calibration.comboBox
    DD_Calibration:AddItem(DD_Calibration:CreateItemEntry("1.25 m/s, 2.80 mph, 4.50 kph - The Elder Strolls", RacingPanel.OnCalibrationSelect))
    DD_Calibration:AddItem(DD_Calibration:CreateItemEntry("1.30 m/s, 2.91 mph, 4.68 kph", RacingPanel.OnCalibrationSelect))
    DD_Calibration:AddItem(DD_Calibration:CreateItemEntry("1.35 m/s, 3.02 mph, 4.86 kph - Default walking speed", RacingPanel.OnCalibrationSelect))
    DD_Calibration:AddItem(DD_Calibration:CreateItemEntry("1.40 m/s, 3.13 mph, 5.04 kph - Cross-walk measurements", RacingPanel.OnCalibrationSelect))
    DD_Calibration:AddItem(DD_Calibration:CreateItemEntry("1.45 m/s, 3.24 mph, 5.22 kph", RacingPanel.OnCalibrationSelect))
    DD_Calibration:AddItem(DD_Calibration:CreateItemEntry("1.50 m/s, 3.36 mph, 5.40 kph", RacingPanel.OnCalibrationSelect))
    DD_Calibration:AddItem(DD_Calibration:CreateItemEntry("1.55 m/s, 3.47 mph, 5.58 kph - A very brisk walk", RacingPanel.OnCalibrationSelect))
    DD_Calibration:AddItem(DD_Calibration:CreateItemEntry("1.60 m/s, 3.58 mph, 5.76 kph - Wut", RacingPanel.OnCalibrationSelect))
    DD_Calibration:SetSelectedItem("1.35 m/s, 3.02 mph, 4.86 kph - Default walking speed")
end
-------------------------------
-- Racing Panel Pro
function RacingPanel.Initialize_DD_EnableRaceCourse()
    RacingPanel_Popup_DropDown_EnableRaceCourse.comboBox = RacingPanel_Popup_DropDown_EnableRaceCourse.comboBox or ZO_ComboBox_ObjectFromContainer(RacingPanel_Popup_DropDown_EnableRaceCourse)
    local DD_EnableRaceCourse = RacingPanel_Popup_DropDown_EnableRaceCourse.comboBox
    DD_EnableRaceCourse:AddItem(DD_EnableRaceCourse:CreateItemEntry("Yes", RacingPanel.OnEnableRaceCourseSelect))
    DD_EnableRaceCourse:AddItem(DD_EnableRaceCourse:CreateItemEntry("No", RacingPanel.OnEnableRaceCourseSelect))
    if RacingPanel.settings.panel_readout_enabled then
        DD_EnableRaceCourse:SetSelectedItem("Yes")
    else
        DD_EnableRaceCourse:SetSelectedItem("No")
    end
end
function RacingPanel.Initialize_DD_Courses()
    RacingPanel_Popup_DropDown_Courses.comboBox = RacingPanel_Popup_DropDown_Courses.comboBox or ZO_ComboBox_ObjectFromContainer(RacingPanel_Popup_DropDown_Courses)
    local DD_Courses = RacingPanel_Popup_DropDown_Courses.comboBox
    DD_Courses:AddItem(DD_Courses:CreateItemEntry("Four-Quarry / Baandari", RacingPanel.OnCoursesSelect))
    DD_Courses:AddItem(DD_Courses:CreateItemEntry("Default1", RacingPanel.OnCoursesSelect))
    DD_Courses:AddItem(DD_Courses:CreateItemEntry("Default2", RacingPanel.OnCoursesSelect))
    DD_Courses:AddItem(DD_Courses:CreateItemEntry("Default4", RacingPanel.OnCoursesSelect))
    DD_Courses:SetSelectedItem("Four-Quarry / Baandari")
end
function RacingPanel.Initialize_DD_SaveCourseRecords()
    RacingPanel_Popup_DropDown_SaveCourseRecords.comboBox = RacingPanel_Popup_DropDown_SaveCourseRecords.comboBox or ZO_ComboBox_ObjectFromContainer(RacingPanel_Popup_DropDown_SaveCourseRecords)
    local DD_SaveCourseRecords = RacingPanel_Popup_DropDown_SaveCourseRecords.comboBox
    DD_SaveCourseRecords:AddItem(DD_SaveCourseRecords:CreateItemEntry("Yes", RacingPanel.OnSaveCourseRecordsSelect))
    DD_SaveCourseRecords:AddItem(DD_SaveCourseRecords:CreateItemEntry("No", RacingPanel.OnSaveCourseRecordsSelect))
    if RacingPanel.settings.course_records then
        DD_SaveCourseRecords:SetSelectedItem("Yes")
    else
        DD_SaveCourseRecords:SetSelectedItem("No")
    end
end
function RacingPanel.Initialize_DD_PostRaceResults()
    RacingPanel_Popup_DropDown_PostRaceResults.comboBox = RacingPanel_Popup_DropDown_PostRaceResults.comboBox or ZO_ComboBox_ObjectFromContainer(RacingPanel_Popup_DropDown_PostRaceResults)
    local DD_PostRaceResults = RacingPanel_Popup_DropDown_PostRaceResults.comboBox
    DD_PostRaceResults:AddItem(DD_PostRaceResults:CreateItemEntry("Yes", RacingPanel.OnPostRaceResultsSelect))
    DD_PostRaceResults:AddItem(DD_PostRaceResults:CreateItemEntry("No", RacingPanel.OnPostRaceResultsSelect))
    if RacingPanel.settings.post_results then
        DD_PostRaceResults:SetSelectedItem("Yes")
    else
        DD_PostRaceResults:SetSelectedItem("No")
    end
end
-------------------------------
-- Settings Popup - dropdown change functions
function RacingPanel.OnSpeedUnitsSelect(_, choiceText, choice)
    --d("speed units : " .. choiceText)
    if choiceText == "kph - Km / Hour" then
        RacingPanel.settings.speed_units = "kph"
    elseif choiceText == "m/s - Meters / Sec" then
        RacingPanel.settings.speed_units = "m/s"
    else
        RacingPanel.settings.speed_units = "mph"
    end
    RacingPanel_SpeedDisplay_UnitsText:SetText(RacingPanel.settings.speed_units)
    RacingPanel.savedVariables.settings = RacingPanel.settings
    PlaySound(SOUNDS.POSITIVE_CLICK)
end
function RacingPanel.OnLayoutsSelect(_, choiceText, choice)
    --d("layout : " .. choiceText)
    local layout_text = string.lower(string.gsub(choiceText, " Layout", ""))
    layout_text = string.gsub(layout_text, " ", "_")
    RacingPanel.SetLayout(layout_text)
    RacingPanel_Popup_DropDown_Layouts.comboBox:SetSelectedItem("Select a Layout...")
    PlaySound(SOUNDS.POSITIVE_CLICK)
end
function RacingPanel.OnEnableMountedSelect(_, choiceText, choice)
    --d("enable mounted : " .. choiceText)
    if choiceText == "Yes" then
        RacingPanel.settings.display_mounted = true
    else
        RacingPanel.settings.display_mounted = false
    end
    RacingPanel.savedVariables.settings = RacingPanel.settings
    RacingPanel.ShowHideMeters(IsMounted())
    PlaySound(SOUNDS.POSITIVE_CLICK)
end
function RacingPanel.OnEnableOnFootSelect(_, choiceText, choice)
    --d("enable on foot : " .. choiceText)
    if choiceText == "Yes" then
        RacingPanel.settings.display_on_foot = true
    else
        RacingPanel.settings.display_on_foot = false
    end
    RacingPanel.savedVariables.settings = RacingPanel.settings
    RacingPanel.ShowHideMeters(IsMounted())
    PlaySound(SOUNDS.POSITIVE_CLICK)
end
function RacingPanel.OnEnableInMenuSelect(_, choiceText, choice)
    --d("enable in menu : " .. choiceText)
    if choiceText == "Yes" then
        RacingPanel.DisableHiding()
    else
        RacingPanel.EnableHiding()
    end
    RacingPanel.savedVariables.settings = RacingPanel.settings
    PlaySound(SOUNDS.POSITIVE_CLICK)
end
function RacingPanel.OnHighPrecisionSelect(_, choiceText, choice)
    --d("high precision : " .. choiceText)
    if choiceText == "Yes" then
        RacingPanel.settings.high_precision = true
        _rp_std_buffer = 10
    else
        RacingPanel.settings.high_precision = false
        _rp_std_buffer = 20
    end
    RacingPanel.savedVariables.settings = RacingPanel.settings
    PlaySound(SOUNDS.POSITIVE_CLICK)
end
function RacingPanel.OnShowSpeedDisplaySelect(_, choiceText, choice)
    --d("show speed display : " .. choiceText)
    if choiceText == "Show" then
        RacingPanel.settings.speed_readout_enabled = true
    else
        RacingPanel.settings.speed_readout_enabled = false
    end
    RacingPanel.savedVariables.settings = RacingPanel.settings
    RacingPanel.ShowHideMeters(IsMounted())
    PlaySound(SOUNDS.POSITIVE_CLICK)
end
function RacingPanel.OnShowSpeedMeterSelect(_, choiceText, choice)
    --d("show speed meter : " .. choiceText)
    if choiceText == "Show" then
        RacingPanel.settings.speed_bar_enabled = true
    else
        RacingPanel.settings.speed_bar_enabled = false
    end
    RacingPanel.savedVariables.settings = RacingPanel.settings
    RacingPanel.ShowHideMeters(IsMounted())
    PlaySound(SOUNDS.POSITIVE_CLICK)
end
function RacingPanel.OnShowStaminaMeterSelect(_, choiceText, choice)
    --d("show stamina meter : " .. choiceText)
    if choiceText == "Show" then
        RacingPanel.settings.stamina_bar_enabled = true
    else
        RacingPanel.settings.stamina_bar_enabled = false
    end
    RacingPanel.savedVariables.settings = RacingPanel.settings
    RacingPanel.ShowHideMeters(IsMounted())
    PlaySound(SOUNDS.POSITIVE_CLICK)
end
function RacingPanel.OnShowMajorBuffMeterSelect(_, choiceText, choice)
    --d("show major buff meter : " .. choiceText)
    if choiceText == "Show" then
        RacingPanel.settings.majorbuff_bar_enabled = true
    else
        RacingPanel.settings.majorbuff_bar_enabled = false
    end
    RacingPanel.savedVariables.settings = RacingPanel.settings
    RacingPanel.ShowHideMeters(IsMounted())
    PlaySound(SOUNDS.POSITIVE_CLICK)
end
function RacingPanel.OnShowMinorBuffMeterSelect(_, choiceText, choice)
    --d("show minor buff meter : " .. choiceText)
    if choiceText == "Show" then
        RacingPanel.settings.minorbuff_bar_enabled = true
    else
        RacingPanel.settings.minorbuff_bar_enabled = false
    end
    RacingPanel.savedVariables.settings = RacingPanel.settings
    RacingPanel.ShowHideMeters(IsMounted())
    PlaySound(SOUNDS.POSITIVE_CLICK)
end
function RacingPanel.OnCalibrationSelect(_, choiceText, choice)
    --d("calibration : " .. choiceText)
    local walkspeed_str = string.sub(choiceText, 1, 4)
    local walkspeed_mps = tonumber(walkspeed_str)
    RacingPanel.SetCalibration(walkspeed_mps)
    PlaySound(SOUNDS.POSITIVE_CLICK)
end
-------------------------------
-- Racing Panel Pro
function RacingPanel.OnEnableRaceCourseSelect(_, choiceText, choice)
    --d("enable race course : " .. choiceText)
    if choiceText == "Yes" then
        RacingPanel.settings.panel_readout_enabled = true
    else
        RacingPanel.settings.panel_readout_enabled = false
    end
    RacingPanel.savedVariables.settings = RacingPanel.settings
    RacingPanel.ShowHideMeters(IsMounted())
    PlaySound(SOUNDS.POSITIVE_CLICK)
end
function RacingPanel.OnCoursesSelect(_, choiceText, choice)
    d("course : " .. choiceText)
    RacingPanel.savedVariables.settings = RacingPanel.settings
    PlaySound(SOUNDS.POSITIVE_CLICK)
end
function RacingPanel.OnSaveCourseRecordsSelect(_, choiceText, choice)
    --d("save course records : " .. choiceText)
    if choiceText == "Yes" then
        RacingPanel.settings.course_records = true
    else
        RacingPanel.settings.course_records = false
    end
    RacingPanel.savedVariables.settings = RacingPanel.settings
    PlaySound(SOUNDS.POSITIVE_CLICK)
end
function RacingPanel.OnPostRaceResultsSelect(_, choiceText, choice)
    --d("post race results : " .. choiceText)
    if choiceText == "Yes" then
        RacingPanel.settings.post_results = true
    else
        RacingPanel.settings.post_results = false
    end
    RacingPanel.savedVariables.settings = RacingPanel.settings
    PlaySound(SOUNDS.POSITIVE_CLICK)
end