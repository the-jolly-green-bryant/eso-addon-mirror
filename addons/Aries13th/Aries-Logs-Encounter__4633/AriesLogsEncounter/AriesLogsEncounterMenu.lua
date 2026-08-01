AriesLogsEncounter = AriesLogsEncounter or {}
local ALE = AriesLogsEncounter
ALE.Menu = {}

function ALE.Menu.AddonMenu()
    local menuOptions = {
        type         = "panel",
        name         = "Aries logs Encounter",
        displayName  = "|cFF4500Aries logs Encounter|r",
        author       = ALE.author,
        version      = ALE.version,
        registerForRefresh  = true,
        registerForDefaults = true,
    }
    local dataTable = {
        {
            type = "description",
            text = GetString(SI_NAME__ALE__MENU__DESCRIPTION),
        },
        {
            type = "header",
            name = GetString(SI_NAME__ALE__MENU__HEADER_CONFIGURATION),
        },
        {
            type    = "checkbox",
            name    = GetString(SI_NAME__ALE__MENU__CONFIGURATION_SKIP_NORMAL),
            default = true,
            getFunc = function() return ALE.savedVars.skipNormal end,
            setFunc = function(newValue) ALE.savedVars.skipNormal = newValue; ALE.OnPlayerActivated() end,
        },
        {
            type = "dropdown",
            name = GetString(SI_NAME__ALE__MENU__CONFIGURATION_BEHAVIOUR),
            reference = "ALE_MENU_BEHAVIOUR_DROPDOWN",
            choices = {},
            getFunc = function() return ALE.Menu.GetBehaviour() end,
            setFunc = function(v) ALE.Menu.SetBehaviour(v) end,
        },
        {
            type    = "checkbox",
            name    = GetString(SI_NAME__ALE__MENU__CONFIGURATION_AUTO_STOP),
            default = false,
            getFunc = function() return ALE.savedVars.autoStop end,
            setFunc = function(newValue) ALE.savedVars.autoStop = newValue; ALE.OnPlayerActivated() end,
        },
        {
            type    = "checkbox",
            name    = GetString(SI_NAME__ALE__MENU__CONFIGURATION_SHOW_STATUS),
            default = false,
            getFunc = function() return ALE.savedVars.showStatus end,
            setFunc = function(newValue) ALE.savedVars.showStatus = newValue; ALE.OnPlayerActivated() end,
        },
        {
            type    = "checkbox",
            name    = GetString(SI_NAME__ALE__MENU__CONFIGURATION_ONLY_RT),
            default = false,
            getFunc = function() return ALE.savedVars.onlyOnRT end,
            setFunc = function(newValue) ALE.savedVars.onlyOnRT = newValue; ALE.OnPlayerActivated() end,
        },
        {
            type      = "submenu",
            name      = GetString(SI_NAME__ALE__MENU__CONFIGURATION__HEADER_RT),
            disabled  = function() return not ALE.savedVars.onlyOnRT end,
            controls  = {
                {
                    type = "description",
                    text = GetString(SI_NAME__ALE__MENU__CONFIGURATION__RT_DESCR1),
                },
                {
                    type = "custom",
                    reference = "ALE_Schedules_List",
                    minHeight = 26,
                    maxHeight = 1000,
                    createFunc = function(customControl) ALE.Menu.Create_Schedules_List(customControl) end,
                    refreshFunc = function(customControl) ALE.Menu.Update_Schedules_List(customControl) end,
                },
                {
                    type    = "button",
                    name    = GetString(SI_NAME__ALE__MENU__CONFIGURATION__RT_ADD_RT),
                    func = function() ALE.Menu.Add_Schedules_List_Elem() end,
                },
                {
                    type    = "checkbox",
                    name    = GetString(SI_NAME__ALE__MENU__CONFIGURATION_SKIP_NORMAL),
                    default = true,
                    getFunc = function() return ALE.savedVars.skipNormalRT end,
                    setFunc = function(newValue) ALE.savedVars.skipNormalRT = newValue; ALE.OnPlayerActivated() end,
                },
                {
                    type = "dropdown",
                    name = GetString(SI_NAME__ALE__MENU__CONFIGURATION_BEHAVIOUR),
                    reference = "ALE_MENU_BEHAVIOUR2_DROPDOWN",
                    choices = {},
                    getFunc = function() return ALE.Menu.GetBehaviour2() end,
                    setFunc = function(v) ALE.Menu.SetBehaviour2(v) end,
                },
                {
                    type    = "checkbox",
                    name    = GetString(SI_NAME__ALE__MENU__CONFIGURATION_SHOW_STATUS),
                    default = false,
                    getFunc = function() return ALE.savedVars.showStatusRT end,
                    setFunc = function(newValue) ALE.savedVars.showStatusRT = newValue; ALE.OnPlayerActivated() end,
                },
                {
                    type    = "checkbox",
                    name    = GetString(SI_NAME__ALE__MENU__CONFIGURATION_AUTO_STOP),
                    default = false,
                    getFunc = function() return ALE.savedVars.autoStopRT end,
                    setFunc = function(newValue) ALE.savedVars.autoStopRT = newValue; ALE.OnPlayerActivated() end,
                },
                {
                    type    = "checkbox",
                    name    = GetString(SI_NAME__ALE__MENU__CONFIGURATION__RT_AUTO_STOP_WHEN_ENDS),
                    default = false,
                    warning = GetString(SI_NAME__ALE__MENU__CONFIGURATION__RT_AUTO_STOP_WHEN_ENDS_WARNING),
                    disabled = function() return not ALE.savedVars.autoStopRT end,
                    getFunc = function() return ALE.savedVars.autoStopRTWhenEnds end,
                    setFunc = function(newValue) ALE.savedVars.autoStopRTWhenEnds = newValue; ALE.OnPlayerActivated() end,
                },
            }
        },
        {
            type      = "submenu",
            name      = GetString(SI_NAME__ALE__MENU__CONFIGURATION__HEADER_ZONES),
            controls  = {
                {
                    type = "description",
                    text = GetString(SI_NAME__ALE__MENU__CONFIGURATION__ZONES_DESCR1),
                },
                {
                    type = "dropdown",
                    name = GetString(SI_NAME__ALE__MENU__CONFIGURATION__ZONES_REMOVE),
                    reference = "ALE_MENU_ZONES_DROPDOWN",
                    choices = {},
                    getFunc = function() return ALE.Menu.UpdateZonesList() end,
                    setFunc = function(zone) ALE.OnZoneRemove(zone) end,
                },
                {
                    type    = "button",
                    name    = GetString(SI_NAME__ALE__MENU__CONFIGURATION__ZONES_ADD),
                    func = function() ALE.OnZoneAdd() end,
                },
                {
                    type    = "button",
                    name    = GetString(SI_NAME__ALE__MENU__CONFIGURATION__ZONES_RESET),
                    func = function() ALE.OnZonesReset() end,
                },
                {
                    type    = "button",
                    name    = GetString(SI_NAME__ALE__MENU__CONFIGURATION__ZONES_ADD_DUNGEONS),
                    func = function() ALE.OnZonesAddDungeons() end,
                },
            }
        },
        {
            type = "header",
            name = GetString(SI_NAME__ALE__MENU__HEADER_ADJUSTMENTS),
        },
        {
            type    = "checkbox",
            name    = GetString(SI_NAME__ALE__MENU__ADJUSTMENTS_UNLOCK_STATUS_PANEL),
            default = false,
            getFunc = function() return ALE.settings.unlockStatus end,
            setFunc = function(newValue) ALE.settings.unlockStatus = newValue; ALE.OnPlayerActivated(); end,
        },
        {
            type    = "checkbox",
            name    = GetString(SI_NAME__ALE__MENU__ADJUSTMENTS_UNLOCK_PANEL),
            default = false,
            getFunc = function() return ALE.settings.unlockReminer end,
            setFunc = function(newValue) ALE.settings.unlockReminer = newValue; ALE.OnPlayerActivated(); end,
        },
        {
            type = "header",
            name = GetString(SI_NAME__ALE__MENU__HEADER_USAGE),
        },
        {
            type = "description",
            text = GetString(SI_NAME__ALE__MENU__USAGE_DESCR1),
        },
        {
            type = "description",
            text = GetString(SI_NAME__ALE__MENU__USAGE_DESCR2),
        },
        {
            type = "description",
            text = GetString(SI_NAME__ALE__MENU__USAGE_DESCR3),
        },
        {
            type = "description",
            text = GetString(SI_NAME__ALE__MENU__USAGE_DESCR4),
        },
    }
    d(1)
    LAM = LibAddonMenu2
    LAM:RegisterAddonPanel(ALE.name .. "Options", menuOptions)
    LAM:RegisterOptionControls(ALE.name .. "Options", dataTable)
    d(2)
end

function ALE.Menu.UpdateZonesList()
    local keys = {}
    for k, v in pairs(ALE.savedVars.zones) do
        if v ~= nil then
            table.insert(keys, k)
        end
    end
    table.sort(keys)
    local values = {}
    for i, k in ipairs(keys) do
        values[i] = ALE.savedVars.zones[k]
    end
    ALE_MENU_ZONES_DROPDOWN.UpdateChoices(ALE_MENU_ZONES_DROPDOWN, values, keys, values)
    return nil
end

function ALE.Menu.UpdateBehaviour()
    local values = {GetString(SI_NAME__ALE__MENU__CONFIGURATION_AUTO_START), GetString(SI_NAME__ALE__MENU__CONFIGURATION_SHOW_DIALOG), GetString(SI_NAME__ALE__MENU__CONFIGURATION_SHOW_REMINDER), GetString(SI_NAME__ALE__MENU__CONFIGURATION_DO_NOTHING)}
    ALE_MENU_BEHAVIOUR_DROPDOWN.UpdateChoices(ALE_MENU_BEHAVIOUR_DROPDOWN, values, values, values)
end

function ALE.Menu.GetBehaviour()
    ALE.Menu.UpdateBehaviour()
    if ALE.savedVars.autoStart then
        return GetString(SI_NAME__ALE__MENU__CONFIGURATION_AUTO_START)
    elseif ALE.savedVars.showDialog then
        return GetString(SI_NAME__ALE__MENU__CONFIGURATION_SHOW_DIALOG)
    elseif ALE.savedVars.showReminder then
        return GetString(SI_NAME__ALE__MENU__CONFIGURATION_SHOW_REMINDER)
    end
    return GetString(SI_NAME__ALE__MENU__CONFIGURATION_DO_NOTHING)
end

function ALE.Menu.SetBehaviour(value)
    ALE.savedVars.autoStart = false
    ALE.savedVars.showDialog = false
    ALE.savedVars.showReminder = false
    ALE.savedVars.doNothing = false
    if value == GetString(SI_NAME__ALE__MENU__CONFIGURATION_AUTO_START) then
        ALE.savedVars.autoStart = true
    elseif value == GetString(SI_NAME__ALE__MENU__CONFIGURATION_SHOW_DIALOG) then
        ALE.savedVars.showDialog = true
    elseif value == GetString(SI_NAME__ALE__MENU__CONFIGURATION_SHOW_REMINDER) then
        ALE.savedVars.showReminder = true
    else
        ALE.savedVars.doNothing = true
    end
    ALE.OnPlayerActivated()
end

function ALE.Menu.UpdateBehaviour2()
    local values = {GetString(SI_NAME__ALE__MENU__CONFIGURATION_AUTO_START), GetString(SI_NAME__ALE__MENU__CONFIGURATION_SHOW_DIALOG), GetString(SI_NAME__ALE__MENU__CONFIGURATION_SHOW_REMINDER)}
    ALE_MENU_BEHAVIOUR2_DROPDOWN.UpdateChoices(ALE_MENU_BEHAVIOUR2_DROPDOWN, values, values, values)
end

function ALE.Menu.GetBehaviour2()
    ALE.Menu.UpdateBehaviour2()
    if ALE.savedVars.autoStartRT then
        return GetString(SI_NAME__ALE__MENU__CONFIGURATION_AUTO_START)
    elseif ALE.savedVars.showDialogRT then
        return GetString(SI_NAME__ALE__MENU__CONFIGURATION_SHOW_DIALOG)
    end
    return GetString(SI_NAME__ALE__MENU__CONFIGURATION_SHOW_REMINDER)
end

function ALE.Menu.SetBehaviour2(value)
    ALE.savedVars.autoStartRT = false
    ALE.savedVars.showDialogRT = false
    ALE.savedVars.showReminderRT = false
    if value == GetString(SI_NAME__ALE__MENU__CONFIGURATION_AUTO_START) then
        ALE.savedVars.autoStartRT = true
    elseif value == GetString(SI_NAME__ALE__MENU__CONFIGURATION_SHOW_DIALOG) then
        ALE.savedVars.showDialogRT = true
    else
        ALE.savedVars.showReminderRT = true
    end
    ALE.OnPlayerActivated()
end

local function ALE_parse_time(str)
    local h, m = string.match(str, "^(%d%d?):(%d%d)$")
    h = tonumber(h)
    m = tonumber(m)
    if (not h) or (not m) then
        return nil
    end
    if h < 0 or h > 23 then
        return nil
    end
    if m < 0 or m > 59 then
        return nil
    end
    return h * 3600 + m * 60
end

local function ALE_create_time(val)
    local h = math.floor(val / 3600)
    local m = math.floor((val % 3600) / 60)
    return string.format("%02d:%02d", h, m)
end

function ALE.Menu.Create_Schedules_List(parent)
    ALE.Menu.Update_Schedules_List(parent)
end

function ALE.Menu.Add_Schedules_List_Elem()
    table.insert(ALE.savedVars.RT, {weekday = 1, startTime = 64800, duration = 2.0})
end

function ALE.Menu.Update_Schedules_List(parent)
    parent.elems = parent.elems or {}
    for idx, v in ipairs(ALE.savedVars.RT) do
        if parent.elems[idx] == nil then
            -- combobox
            parent.elems[idx] = {}
            parent.elems[idx].combobox = WINDOW_MANAGER:CreateControlFromVirtual("ALE_MENU_ELEM_Combobox" .. tostring(idx), parent, "ZO_ComboBox")
            if parent.elems[idx - 1] == nil then
                parent.elems[idx].combobox:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
            else
                parent.elems[idx].combobox:SetAnchor(TOPLEFT, parent.elems[idx - 1].combobox, BOTTOMLEFT, 0, 10)
            end
            parent.elems[idx].combobox:SetDimensions(140, 30)
            parent.elems[idx].dropdown = ZO_ComboBox_ObjectFromContainer(parent.elems[idx].combobox)
            local dropdown = parent.elems[idx].dropdown
            dropdown:SetSortsItems(false)
            function OnDropdownSelect(control, choiceText, somethingElse)
                for index, val in pairs(ALE.settings.weekdays) do
                    if val == choiceText then
                        ALE.savedVars.RT[idx].weekday = index
                    end
                end
            end
            for index, val in pairs(ALE.settings.weekdays) do
                dropdown:AddItem(dropdown:CreateItemEntry(val, OnDropdownSelect))
                if index == v.weekday then
                    dropdown:SetSelectedItem(val)
                end
            end

            -- Label
            local label = WINDOW_MANAGER:CreateControl(
                "ALE_MENU_ELEM_Label_" .. tostring(idx),
                parent,
                CT_LABEL
            )
            if parent.elems[idx - 1] == nil then
                label:SetAnchor(TOPLEFT, parent, TOPLEFT, 142, 0)
            else
                label:SetAnchor(TOPLEFT, parent.elems[idx - 1].combobox, BOTTOMLEFT, 142, 10)
            end
            label:SetFont("ZoFontGame")
            label:SetText(GetString(SI_NAME__ALE__MENU__CONFIGURATION__RT_ELEM_FROM))
            parent.elems[idx].label = label

            -- editbox
            local editbox_bg = WINDOW_MANAGER:CreateControlFromVirtual(nil, parent, "ZO_EditBackdrop")
            local editbox = WINDOW_MANAGER:CreateControlFromVirtual(
                "ALE_MENU_ELEM_Editbox_" .. tostring(idx),
                editbox_bg,
                "ZO_DefaultEditForBackdrop"
            )
            editbox_bg:SetDimensions(100, 30)
            editbox:SetDimensions(100, 30)
            if parent.elems[idx - 1] == nil then
                editbox_bg:SetAnchor(TOPLEFT, parent, TOPLEFT, 200, 0)
                editbox:SetAnchor(TOPLEFT, editbox_bg, TOPLEFT, 0, 0)
            else
                editbox_bg:SetAnchor(TOPLEFT, parent.elems[idx - 1].combobox, BOTTOMLEFT, 200, 10)
                editbox:SetAnchor(TOPLEFT, editbox_bg, TOPLEFT, 0, 0)
            end
            editbox:SetText(ALE_create_time(v.startTime))
            editbox_bg.editbox = editbox
            parent.elems[idx].editbox = editbox_bg
            editbox:SetHandler("OnFocusLost", function(self)
                local newValue = ALE_parse_time(self:GetText())
                if newValue == nil then
                    parent.elems[idx].editbox.editbox:SetText(ALE_create_time(ALE.savedVars.RT[idx].startTime))
                else
                    ALE.savedVars.RT[idx].startTime = newValue
                end
            end)

            -- Label2
            label = WINDOW_MANAGER:CreateControl(
                "ALE_MENU_ELEM_Label2_" .. tostring(idx),
                parent,
                CT_LABEL
            )
            if parent.elems[idx - 1] == nil then
                label:SetAnchor(TOPLEFT, parent, TOPLEFT, 310, 0)
            else
                label:SetAnchor(TOPLEFT, parent.elems[idx - 1].combobox, BOTTOMLEFT, 310, 10)
            end
            label:SetFont("ZoFontGame")
            label:SetText(GetString(SI_NAME__ALE__MENU__CONFIGURATION__RT_ELEM_DURATION))
            parent.elems[idx].label2 = label

            -- editbox2
            editbox_bg = WINDOW_MANAGER:CreateControlFromVirtual(nil, parent, "ZO_EditBackdrop")
            editbox = WINDOW_MANAGER:CreateControlFromVirtual(
                "ALE_MENU_ELEM_Editbox2_" .. tostring(idx),
                editbox_bg,
                "ZO_DefaultEditForBackdrop"
            )
            editbox_bg:SetDimensions(80, 30)
            editbox:SetDimensions(80, 30)
            if parent.elems[idx - 1] == nil then
                editbox_bg:SetAnchor(TOPLEFT, parent, TOPLEFT, 450, 0)
                editbox:SetAnchor(TOPLEFT, editbox_bg, TOPLEFT, 0, 0)
            else
                editbox_bg:SetAnchor(TOPLEFT, parent.elems[idx - 1].combobox, BOTTOMLEFT, 450, 10)
                editbox:SetAnchor(TOPLEFT, editbox_bg, TOPLEFT, 0, 0)
            end
            editbox:SetText(v.duration)
            editbox_bg.editbox = editbox
            parent.elems[idx].editbox2 = editbox_bg
            editbox:SetHandler("OnFocusLost", function(self)
                local newValue = tonumber(self:GetText())
                if (newValue < 0) or (newValue > 24) then
                    newValue = nil
                end
                if newValue == nil then
                    parent.elems[idx].editbox2.editbox:SetText(ALE.savedVars.RT[idx].duration)
                else
                    ALE.savedVars.RT[idx].duration = newValue
                end
            end)

            -- button
            local button = WINDOW_MANAGER:CreateControlFromVirtual(
                "ALE_MENU_ELEM_Button_" .. tostring(idx),
                parent,
                "ZO_DefaultButton"
            )
            button:SetDimensions(30, 30)
            if parent.elems[idx - 1] == nil then
                button:SetAnchor(TOPLEFT, parent, TOPLEFT, 550, 0)
            else
                button:SetAnchor(TOPLEFT, parent.elems[idx - 1].combobox, BOTTOMLEFT, 550, 10)
            end
            button:SetText("х")
            button:SetHandler("OnClicked", function()
                table.remove(ALE.savedVars.RT, idx)
                ALE.Menu.Update_Schedules_List(parent)
            end)
            parent.elems[idx].button = button
        else
            parent.elems[idx].combobox:SetHidden(false)
            parent.elems[idx].label:SetHidden(false)
            parent.elems[idx].label2:SetHidden(false)
            parent.elems[idx].button:SetHidden(false)
            parent.elems[idx].editbox:SetHidden(false)
            parent.elems[idx].editbox2:SetHidden(false)

            for index, val in pairs(ALE.settings.weekdays) do
                if index == v.weekday then
                    parent.elems[idx].dropdown:SetSelectedItem(val)
                end
            end
            parent.elems[idx].editbox.editbox:SetText(ALE_create_time(v.startTime))
            parent.elems[idx].editbox2.editbox:SetText(v.duration)
        end
    end
    for idx = #ALE.savedVars.RT + 1, #parent.elems do
        parent.elems[idx].combobox:SetHidden(true)
        parent.elems[idx].label:SetHidden(true)
        parent.elems[idx].label2:SetHidden(true)
        parent.elems[idx].button:SetHidden(true)
        parent.elems[idx].editbox:SetHidden(true)
        parent.elems[idx].editbox2:SetHidden(true)
    end
end