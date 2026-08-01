local ADGM = _G["ADawgsGroupManager"]
local COLOR_TITLE = ADGM.COLOR_TITLE
local COLOR_WARN = ADGM.COLOR_WARN
local COLOR_RESET = ADGM.COLOR_RESET
local ACTION_NOTIFY = ADGM.ACTION_NOTIFY
local ACTION_WOULD_KICK = ADGM.ACTION_WOULD_KICK
local ACTION_AUTO = ADGM.ACTION_AUTO
local RESTRICTION_ANYONE = ADGM.RESTRICTION_ANYONE
local RESTRICTION_FRIENDS = ADGM.RESTRICTION_FRIENDS
local RESTRICTION_GUILD = ADGM.RESTRICTION_GUILD
local RESTRICTION_FRIENDS_GUILD = ADGM.RESTRICTION_FRIENDS_GUILD
local EXPECTED_ZONE_PLAYER = ADGM.EXPECTED_ZONE_PLAYER
local EXPECTED_ZONE_LEADER = ADGM.EXPECTED_ZONE_LEADER
local EXPECTED_ZONE_LOCKED = ADGM.EXPECTED_ZONE_LOCKED
local DEFAULTS = ADGM.DEFAULTS
local Chat = ADGM.Chat
local MarkCustomPreset = ADGM.MarkCustomPreset
local SetTargetGroupSize = ADGM.SetTargetGroupSize
local SetSyncKickSafetyWithTargetSize = ADGM.SetSyncKickSafetyWithTargetSize
local GetPresetChoices = ADGM.GetPresetChoices
local GetPresetLabel = ADGM.GetPresetLabel
local IsCustomPresetKey = ADGM.IsCustomPresetKey
local CustomPresetHasGroupFinderTemplate = ADGM.CustomPresetHasGroupFinderTemplate
local SaveCustomPreset = ADGM.SaveCustomPreset
local UpdateSelectedCustomPreset = ADGM.UpdateSelectedCustomPreset
local RenameSelectedCustomPreset = ADGM.RenameSelectedCustomPreset
local DeleteSelectedCustomPreset = ADGM.DeleteSelectedCustomPreset
local PrintCustomPresets = ADGM.PrintCustomPresets
local SetTwelvePlayerRelistThreshold = ADGM.SetTwelvePlayerRelistThreshold
local ApplyPreset = ADGM.ApplyPreset
local SetGroupFinderRelistOnLeave = ADGM.SetGroupFinderRelistOnLeave
local SetGroupFinderMode = ADGM.SetGroupFinderMode
local SetGroupFinderAutoAcceptApplications = ADGM.SetGroupFinderAutoAcceptApplications
local RescheduleOfflineGuardChecks = ADGM.RescheduleOfflineGuardChecks
local SetAddonEnabled = ADGM.SetAddonEnabled
local SetOfflineGuardEnabled = ADGM.SetOfflineGuardEnabled
local SetZoneGuardEnabled = ADGM.SetZoneGuardEnabled
local SetZoneGuardExpectedZone = ADGM.SetZoneGuardExpectedZone
local SetZoneGuardAction = ADGM.SetZoneGuardAction
local SetZoneGuardGraceSeconds = ADGM.SetZoneGuardGraceSeconds
local SetZoneGuardTimeoutSeconds = ADGM.SetZoneGuardTimeoutSeconds
local SetRoleGuardEnabled = ADGM.SetRoleGuardEnabled
local SetRoleGuardAction = ADGM.SetRoleGuardAction
local SetOfflineGuardTimeout = ADGM.SetOfflineGuardTimeout
local PrintStatus = ADGM.PrintStatus
local CaptureCurrentGroupFinderListing = ADGM.CaptureCurrentGroupFinderListing
local PrintSavedGroupFinderListing = ADGM.PrintSavedGroupFinderListing
local SetGroupFinderRelistMode = ADGM.SetGroupFinderRelistMode
local RelistSavedGroupFinderListing = ADGM.RelistSavedGroupFinderListing
local SetGroupFinderEventLog = ADGM.SetGroupFinderEventLog

local UpdateNativeGroupFinderCreatePanel
local RefreshNativePresetDropdown

local function BuildPresetChoiceSignature(labels, values, tooltips)
    local parts = {}
    for i, value in ipairs(values) do
        parts[#parts + 1] = tostring(value)
        parts[#parts + 1] = tostring(labels[i] or "")
        if tooltips then
            parts[#parts + 1] = tostring(tooltips[i] or "")
        end
    end
    return table.concat(parts, "\31")
end

local function ShowPresetTooltip(owner, text)
    if text and text ~= "" then
        InitializeTooltip(InformationTooltip, owner, TOPLEFT, 0, 0, BOTTOMRIGHT)
        SetTooltipText(InformationTooltip, text)
        InformationTooltipTopLevel:BringWindowToTop()
    end
end

local function HidePresetTooltip()
    ClearTooltip(InformationTooltip)
end

local function GetComboBoxRowTooltip(rowControl)
    local data = rowControl and rowControl.dataEntry and rowControl.dataEntry.data
    if data and data.tooltip then
        return data.tooltip
    end

    data = rowControl and rowControl.m_data
    if data then
        if data.tooltip then
            return data.tooltip
        end
        if data.GetDataSource then
            local source = data:GetDataSource()
            return source and source.tooltip
        end
    end
    return nil
end

local function SetupPresetDropdownTooltips(comboBox)
    if not comboBox then
        return
    end

    comboBox:SetEntryMouseOverCallbacks(function(rowControl)
        ShowPresetTooltip(rowControl, GetComboBoxRowTooltip(rowControl))
    end, HidePresetTooltip)
end

local function GetCustomPresetStore()
    return ADGM.vars and ADGM.vars.customPresets
end

local function ApplyPresetFromUi(presetKey)
    local applyGroupFinderTemplate = CustomPresetHasGroupFinderTemplate(presetKey) == true
    ApplyPreset(presetKey)
    if applyGroupFinderTemplate and ADGM.ApplyCurrentGroupFinderTemplateToNativeDraft then
        ADGM.ApplyCurrentGroupFinderTemplateToNativeDraft("custom preset")
    end
    if UpdateNativeGroupFinderCreatePanel then
        UpdateNativeGroupFinderCreatePanel()
    end
end

local function OpenSettings()
    if ADGM.settingsPanel then
        LibAddonMenu2:OpenToPanel(ADGM.settingsPanel)
    else
        LibAddonMenu2:OpenToPanel("ADawgsGroupManagerOptions")
    end
end

local function OffOnStartCheckbox(key, name, tooltip)
    return {
        type = "checkbox",
        name = name,
        tooltip = tooltip,
        getFunc = function() return ADGM.vars.offOnGameStart[key] end,
        setFunc = function(value) ADGM.vars.offOnGameStart[key] = value == true end,
        default = DEFAULTS.offOnGameStart[key],
    }
end

local function RefreshSettingsPresetDropdown()
    local control = _G.ADGMSettingsPresetDropdown
    if not control or not control.UpdateChoices then
        return
    end

    local labels, values = GetPresetChoices()
    local signature = BuildPresetChoiceSignature(labels, values)
    if control.adgmPresetChoiceSignature ~= signature then
        control.data.choicesTooltips = nil
        control:UpdateChoices(labels, values)
        control.adgmPresetChoiceSignature = signature
    end
    control:UpdateValue()
end

local function UpdatePresetControls()
    RefreshSettingsPresetDropdown()
    if UpdateNativeGroupFinderCreatePanel then
        UpdateNativeGroupFinderCreatePanel()
    end
end

UpdateNativeGroupFinderCreatePanel = function()
    local panel = ADGM.state.nativeGroupFinderCreatePanel
    if not panel then
        return
    end

    local listing = ADGM.vars and ADGM.vars.groupFinder and ADGM.vars.groupFinder.savedListing
    local relistMode = ADGM.vars.groupFinder.mode == ACTION_AUTO and "auto" or "notify"
    if panel.statusLabel then
        panel.statusLabel:SetText("Template: " .. (listing and "saved" or "not saved"))
    end
    if panel.relistLabel then
        panel.relistLabel:SetText("Relist: " .. relistMode)
    end
    if panel.relistCheck then
        ZO_CheckButton_SetCheckState(panel.relistCheck, ADGM.vars.groupFinder.relistOnLeave == true)
    end
    if panel.applicationAcceptCheck then
        ZO_CheckButton_SetCheckState(panel.applicationAcceptCheck, ADGM.vars.groupFinder.autoAcceptApplications == true)
    end
    if panel.modeButton then
        panel.modeButton:SetText(ADGM.vars.groupFinder.mode == ACTION_AUTO and "Mode: Auto" or "Mode: Notify")
    end
    if panel.presetDropdown and panel.presetDropdown.m_comboBox then
        RefreshNativePresetDropdown(panel.presetDropdown)
        panel.presetDropdown.m_comboBox:SetSelectedItemText(GetPresetLabel(ADGM.vars.selectedPreset))
    end
end

local function CreateNativeButton(parent, name, text, relativeTo, offsetX, offsetY, callback)
    local button = WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_DefaultButton")
    button:SetDimensions(104, 26)
    button:SetText(text)
    button:SetAnchor(TOPLEFT, relativeTo, BOTTOMLEFT, offsetX or 0, offsetY or 8)
    button:SetHandler("OnClicked", callback)
    return button
end

local function FindNativeGroupFinderAnchor(groupFinderPanel)
    return groupFinderPanel.enforceRolesCheckbox or groupFinderPanel.control
end

local function CreateNativeCheckbox(parent, name, text, anchorTo)
    local checkbox = WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_CheckButton")
    checkbox:SetAnchor(TOPLEFT, anchorTo, BOTTOMLEFT, 0, 8)
    ZO_CheckButton_SetLabelText(checkbox, text)
    return checkbox
end

RefreshNativePresetDropdown = function(comboBoxControl)
    if not comboBoxControl or not comboBoxControl.m_comboBox then
        return
    end

    local comboBox = comboBoxControl.m_comboBox
    local labels, values, tooltips = GetPresetChoices()
    local signature = BuildPresetChoiceSignature(labels, values, tooltips)
    if comboBoxControl.adgmPresetChoiceSignature == signature then
        comboBox:SetSelectedItemText(GetPresetLabel(ADGM.vars.selectedPreset))
        return
    end

    comboBox:ClearItems()
    for i, presetKey in ipairs(values) do
        local label = labels[i]
        local entry = comboBox:CreateItemEntry(label, function()
            ApplyPresetFromUi(presetKey)
        end)
        entry.tooltip = tooltips[i]
        comboBox:AddItem(entry)
    end
    comboBoxControl.adgmPresetChoiceSignature = signature
    comboBox:SetSelectedItemText(GetPresetLabel(ADGM.vars.selectedPreset))
end

local function RegisterSettingsPresetDropdownCallbacks()
    if ADGM.state.settingsPresetCallbacksRegistered then
        return
    end

    local function RefreshIfAdgmPanel(control)
        if control == ADGM.settingsPanel
            or (control and control.panel == ADGM.settingsPanel)
        then
            zo_callLater(RefreshSettingsPresetDropdown, 0)
        end
    end

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", RefreshIfAdgmPanel)
    CALLBACK_MANAGER:RegisterCallback("LAM-RefreshPanel", RefreshIfAdgmPanel)
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", RefreshIfAdgmPanel)
    ADGM.state.settingsPresetCallbacksRegistered = true
end

local function CreateNativePresetDropdown(parent, relativeTo)
    local comboBoxControl = WINDOW_MANAGER:CreateControlFromVirtual("ADGMGroupFinderCreatePanelPresetDropdown", parent, "ZO_ComboBox")
    comboBoxControl:SetDimensions(176, 28)
    comboBoxControl:SetAnchor(TOPLEFT, relativeTo, BOTTOMLEFT, 0, 8)

    local comboBox = ZO_ComboBox_ObjectFromContainer(comboBoxControl)
    comboBox:SetSortsItems(false)

    comboBoxControl.m_comboBox = comboBox
    SetupPresetDropdownTooltips(comboBox)
    RefreshNativePresetDropdown(comboBoxControl)
    return comboBoxControl
end

local function AttachNativeGroupFinderCreatePanel(groupFinderPanel)
    if not groupFinderPanel or not groupFinderPanel.control then
        return
    end

    ADGM.state.nativeGroupFinderPanel = groupFinderPanel
    if ADGM.state.nativeGroupFinderCreatePanel then
        UpdateNativeGroupFinderCreatePanel()
        ADGM.MaybeApplyCurrentGroupFinderTemplateToNativeDraft("create panel shown")
        UpdateNativeGroupFinderCreatePanel()
        return
    end

    local host = groupFinderPanel.control
    local anchorControl = FindNativeGroupFinderAnchor(groupFinderPanel)
    local panel = WINDOW_MANAGER:CreateControl("ADGMGroupFinderCreatePanel", host, CT_CONTROL)
    panel:SetDimensions(560, 174)
    panel:SetAnchor(TOPLEFT, anchorControl, BOTTOMLEFT, 0, 134)

    local title = WINDOW_MANAGER:CreateControl("ADGMGroupFinderCreatePanelTitle", panel, CT_LABEL)
    title:SetFont("ZoFontWinH5")
    title:SetText("a dawg's Group Manager Options")
    title:SetAnchor(TOPLEFT, panel, TOPLEFT, 0, 0)

    local relistCheck = CreateNativeCheckbox(panel, "ADGMGroupFinderCreatePanelRelistCheck", "Relist when a group member leaves", title)
    ZO_CheckButton_SetToggleFunction(relistCheck, function(_button, checked)
        SetGroupFinderRelistOnLeave(checked)
    end)
    panel.relistCheck = relistCheck

    local applicationAcceptCheck = CreateNativeCheckbox(panel, "ADGMGroupFinderCreatePanelApplicationAcceptCheck", "ADGM auto-accept applications", relistCheck)
    ZO_CheckButton_SetToggleFunction(applicationAcceptCheck, function(_button, checked)
        SetGroupFinderAutoAcceptApplications(checked)
    end)
    panel.applicationAcceptCheck = applicationAcceptCheck

    local presetLabel = WINDOW_MANAGER:CreateControl("ADGMGroupFinderCreatePanelPresetLabel", panel, CT_LABEL)
    presetLabel:SetFont("ZoFontGameSmall")
    presetLabel:SetText("Preset")
    presetLabel:SetAnchor(TOPLEFT, applicationAcceptCheck, BOTTOMLEFT, 0, 8)
    presetLabel:SetDimensions(90, 22)

    local presetDropdown = CreateNativePresetDropdown(panel, presetLabel)
    panel.presetDropdown = presetDropdown

    local status = WINDOW_MANAGER:CreateControl("ADGMGroupFinderCreatePanelStatus", panel, CT_LABEL)
    status:SetFont("ZoFontGameSmall")
    status:SetAnchor(LEFT, presetDropdown, RIGHT, 18, 0)
    status:SetDimensions(120, 22)
    panel.statusLabel = status

    local relistLabel = WINDOW_MANAGER:CreateControl("ADGMGroupFinderCreatePanelRelistLabel", panel, CT_LABEL)
    relistLabel:SetFont("ZoFontGameSmall")
    relistLabel:SetAnchor(LEFT, status, RIGHT, 16, 0)
    relistLabel:SetDimensions(80, 22)
    panel.relistLabel = relistLabel

    CreateNativeButton(panel, "ADGMGroupFinderCreatePanelRelist", "Manual List", presetDropdown, 0, 8, function()
        RelistSavedGroupFinderListing("native create panel")
        UpdateNativeGroupFinderCreatePanel()
    end)

    local modeButton = CreateNativeButton(panel, "ADGMGroupFinderCreatePanelMode", "Toggle Mode", presetDropdown, 112, 8, function()
        SetGroupFinderMode(ADGM.vars.groupFinder.mode == ACTION_AUTO and ACTION_NOTIFY or ACTION_AUTO)
    end)
    panel.modeButton = modeButton

    local saveButton = CreateNativeButton(panel, "ADGMGroupFinderCreatePanelSave", "Save Template", modeButton, 112, -26, function()
        CaptureCurrentGroupFinderListing(false, GROUP_FINDER_GROUP_LISTING_USER_TYPE_GROUP_LISTING_DRAFT)
        UpdateNativeGroupFinderCreatePanel()
    end)
    saveButton:SetWidth(118)
    local showButton = CreateNativeButton(panel, "ADGMGroupFinderCreatePanelShow", "Show Template", saveButton, 126, -26, function()
        PrintSavedGroupFinderListing()
        UpdateNativeGroupFinderCreatePanel()
    end)
    showButton:SetWidth(118)

    ADGM.state.nativeGroupFinderCreatePanel = panel
    UpdateNativeGroupFinderCreatePanel()
    ADGM.MaybeApplyCurrentGroupFinderTemplateToNativeDraft("create panel shown")
    UpdateNativeGroupFinderCreatePanel()
end

function ADGM.HookNativeGroupFinderCreatePanel()
    if ADGM.state.nativeGroupFinderHooked then
        return
    end

    ZO_PreHook(ZO_GroupFinder_CreateEditGroupListing_Keyboard, "Show", function(groupFinderPanel)
        zo_callLater(function()
            AttachNativeGroupFinderCreatePanel(groupFinderPanel)
        end, 100)
    end)
    ADGM.state.nativeGroupFinderHooked = true
end

local function PrintHelp()
    Chat("/adgm status", true)
    Chat("/adgm on | off | debug", true)
    Chat("/adgm preset custom|dolmen|wb|nm|dungeon|trial", true)
    Chat("/adgm presets list|save|update|rename|delete", true)
    Chat("/adgm size 2/4/12", true)
    Chat("/adgm trigger +dolmen,+wb", true)
    Chat("/adgm offlinekick <seconds>", true)
    Chat("/adgm zonekick <seconds>", true)
    Chat("/adgm gfsave | gfshow", true)
    Chat("/adgm gfrelist [on|off|notify|auto]", true)
    Chat("/adgm gfcooldown <seconds>", true)
    Chat("/adgm lockzone - use your current zone for Zone Guard locked mode", true)
    if ADGM.vars and ADGM.vars.debug then
        Chat("Debug commands:", true)
        Chat("/adgm gfevents on | off", true)
    end
end

function ADGM.HandleCommand(args)
    ADGM.state.commandChatDepth = (ADGM.state.commandChatDepth or 0) + 1
    local ok, errorMessage = pcall(function()
        args = args or ""
        local command, rest = args:match("^(%S*)%s*(.-)$")
        command = string.lower(command or "")
        rest = zo_strtrim(rest or "")

        if command == "" then
            OpenSettings()
        elseif command == "help" then
            PrintHelp()
        elseif command == "on" then
            SetAddonEnabled(true)
            Chat("Enabled.", true)
        elseif command == "off" then
            SetAddonEnabled(false)
            Chat("Disabled.", true)
        elseif command == "debug" then
            ADGM.vars.debug = not ADGM.vars.debug
            Chat("Debug " .. (ADGM.vars.debug and "on." or "off."), true)
        elseif command == "status" then
            PrintStatus()
        elseif command == "preset" then
            local presetKey = string.lower(rest or "")
            if presetKey == "wb" then
                presetKey = "worldBoss"
            elseif presetKey == "nm" then
                presetKey = "nightMarket"
            elseif presetKey == "trial" then
                presetKey = "trialFill"
            end
            ApplyPresetFromUi(presetKey)
        elseif command == "presets" then
            local subCommand, value = rest:match("^(%S*)%s*(.-)$")
            subCommand = string.lower(subCommand or "")
            value = zo_strtrim(value or "")
            local store = GetCustomPresetStore()
            local includeTemplate = store and store.includeGroupFinderTemplate == true
            local draftName = store and store.draftName or ""
            local presetName = value ~= "" and value or draftName
            if subCommand == "" or subCommand == "list" then
                PrintCustomPresets()
            elseif subCommand == "save" then
                SaveCustomPreset(presetName, includeTemplate)
            elseif subCommand == "update" then
                UpdateSelectedCustomPreset(includeTemplate)
            elseif subCommand == "rename" then
                RenameSelectedCustomPreset(presetName)
            elseif subCommand == "delete" then
                DeleteSelectedCustomPreset()
            else
                Chat("Usage: /adgm presets list|save|update|rename|delete", true)
            end
        elseif command == "size" then
            local size = tonumber(rest)
            if size == 2 or size == 4 or size == 12 then
                SetTargetGroupSize(size)
                Chat("Target group size set to " .. tostring(size) .. ".", true)
            else
                Chat("Usage: /adgm size 2/4/12", true)
            end
        elseif command == "trigger" then
            if rest ~= "" then
                MarkCustomPreset()
                ADGM.vars.autoInvite.triggers = rest
                Chat("Triggers set to " .. COLOR_WARN .. rest .. COLOR_RESET .. ".", true)
            else
                Chat("Usage: /adgm trigger +dolmen,+wb", true)
            end
        elseif command == "offlinekick" then
            local seconds = tonumber(rest)
            if seconds and seconds >= 5 and seconds <= 600 then
                SetOfflineGuardTimeout(seconds)
                Chat("Offline auto-kick timeout set to " .. tostring(seconds) .. " seconds.", true)
            else
                Chat("Usage: /adgm offlinekick <5-600 seconds>", true)
            end
        elseif command == "zonekick" then
            local seconds = tonumber(rest)
            if seconds and seconds >= 10 and seconds <= 900 then
                SetZoneGuardTimeoutSeconds(seconds)
                Chat("Wrong-zone auto-kick timeout set to " .. tostring(seconds) .. " seconds.", true)
            else
                Chat("Usage: /adgm zonekick <10-900 seconds>", true)
            end
        elseif command == "gfsave" then
            CaptureCurrentGroupFinderListing()
        elseif command == "gfshow" then
            PrintSavedGroupFinderListing()
        elseif command == "gfrelist" then
            local mode = string.lower(rest or "")
            if mode == "" then
                RelistSavedGroupFinderListing("manual")
            else
                SetGroupFinderRelistMode(mode)
            end
        elseif command == "gfcooldown" then
            local seconds = tonumber(rest)
            if seconds and seconds >= 5 and seconds <= 600 then
                MarkCustomPreset()
                ADGM.vars.groupFinder.cooldownSeconds = seconds
                Chat("Group Finder relist cooldown set to " .. tostring(seconds) .. " seconds.", true)
            else
                Chat("Usage: /adgm gfcooldown <5-600 seconds>", true)
            end
        elseif command == "gfevents" then
            if ADGM.vars.debug then
                local value = string.lower(rest or "")
                if value == "on" then
                    SetGroupFinderEventLog(true)
                elseif value == "off" then
                    SetGroupFinderEventLog(false)
                else
                    Chat("Usage: /adgm gfevents on | off", true)
                end
            else
                Chat("Debug mode is off. Run /adgm debug to enable debug commands.", true)
            end
        elseif command == "lockzone" then
            MarkCustomPreset()
            ADGM.vars.zoneGuard.lockedZoneIndex = GetUnitZoneIndex("player")
            SetZoneGuardExpectedZone(EXPECTED_ZONE_LOCKED)
            Chat("Locked expected zone to " .. tostring(ADGM.vars.zoneGuard.lockedZoneIndex) .. ".", true)
        else
            PrintHelp()
        end
    end)
    ADGM.state.commandChatDepth = zo_max(0, (ADGM.state.commandChatDepth or 1) - 1)

    if not ok then
        error(errorMessage)
    end
end

function ADGM.RegisterSettings()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "a dawg's Group Manager",
        displayName = COLOR_TITLE .. "a dawg's Group Manager" .. COLOR_RESET,
        author = "runcarsnowpen",
        version = ADGM.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    ADGM.settingsPanel = LAM:RegisterAddonPanel("ADawgsGroupManagerOptions", panelData)

    local presetLabels, presetValues = GetPresetChoices()
    local options = {
        {
            type = "header",
            name = "Presets",
        },
        {
            type = "dropdown",
            name = "Preset",
            tooltip = "Premade setups and your saved custom presets. Custom keeps your current settings.",
            choices = presetLabels,
            choicesValues = presetValues,
            getFunc = function() return ADGM.vars.selectedPreset end,
            setFunc = ApplyPresetFromUi,
            default = DEFAULTS.selectedPreset,
            reference = "ADGMSettingsPresetDropdown",
        },
        {
            type = "editbox",
            name = "Custom preset name",
            tooltip = "Name used by Save new and Rename.",
            getFunc = function()
                local store = GetCustomPresetStore()
                return store and store.draftName or ""
            end,
            setFunc = function(value)
                local store = GetCustomPresetStore()
                if store then
                    store.draftName = value or ""
                end
            end,
            isMultiline = false,
            width = "full",
            default = DEFAULTS.customPresets.draftName,
        },
        {
            type = "checkbox",
            name = "Include Group Finder template",
            tooltip = "Stores the current saved Group Finder listing template inside new or updated custom presets.",
            getFunc = function()
                local store = GetCustomPresetStore()
                return store and store.includeGroupFinderTemplate == true
            end,
            setFunc = function(value)
                local store = GetCustomPresetStore()
                if store then
                    store.includeGroupFinderTemplate = value == true
                end
            end,
            default = DEFAULTS.customPresets.includeGroupFinderTemplate,
        },
        {
            type = "button",
            name = "Save new custom preset",
            tooltip = "Saves the current ADGM settings as a new custom preset.",
            func = function()
                local store = GetCustomPresetStore()
                SaveCustomPreset(store and store.draftName or "", store and store.includeGroupFinderTemplate == true)
            end,
        },
        {
            type = "button",
            name = "Update selected custom preset",
            tooltip = "Overwrites the selected custom preset with the current ADGM settings.",
            disabled = function() return not IsCustomPresetKey(ADGM.vars.selectedPreset) end,
            func = function()
                local store = GetCustomPresetStore()
                UpdateSelectedCustomPreset(store and store.includeGroupFinderTemplate == true)
            end,
        },
        {
            type = "button",
            name = "Rename selected custom preset",
            tooltip = "Renames the selected custom preset to the custom preset name above.",
            disabled = function() return not IsCustomPresetKey(ADGM.vars.selectedPreset) end,
            func = function()
                local store = GetCustomPresetStore()
                RenameSelectedCustomPreset(store and store.draftName or "")
            end,
        },
        {
            type = "button",
            name = "Delete selected custom preset",
            tooltip = "Deletes the selected custom preset.",
            disabled = function() return not IsCustomPresetKey(ADGM.vars.selectedPreset) end,
            isDangerous = true,
            warning = "Delete the selected custom preset?",
            func = DeleteSelectedCustomPreset,
        },
        {
            type = "header",
            name = "General",
        },
        {
            type = "checkbox",
            name = "Enable a dawg's Group Manager",
            getFunc = function() return ADGM.vars.enabled end,
            setFunc = SetAddonEnabled,
            default = DEFAULTS.enabled,
        },
        {
            type = "submenu",
            name = "Off on game start",
            controls = {
                OffOnStartCheckbox("addon", "a dawg's Group Manager", "Turns the whole addon off when the game starts."),
                OffOnStartCheckbox("autoInvite", "Auto invite", "Turns auto invite off when the game starts."),
                OffOnStartCheckbox("offlineGuard", "Offline guard", "Turns offline guard off when the game starts."),
                OffOnStartCheckbox("zoneGuard", "Zone guard", "Turns zone guard off when the game starts."),
                OffOnStartCheckbox("roleGuard", "Role guard", "Turns role guard off when the game starts."),
                OffOnStartCheckbox("autoRelist", "Auto relist", "Turns relist when a group member leaves off when the game starts."),
                OffOnStartCheckbox("groupFinderAutoAcceptApplications", "Group Finder auto-accept", "Turns ADGM auto-accept applications off when the game starts."),
                OffOnStartCheckbox("autoKick", "Auto kick", "Changes guard actions from Auto kick to Notify only when the game starts."),
            },
        },
        {
            type = "checkbox",
            name = "Print log in chat",
            getFunc = function() return ADGM.vars.chatMessages end,
            setFunc = function(value) MarkCustomPreset(); ADGM.vars.chatMessages = value end,
            default = DEFAULTS.chatMessages,
        },
        {
            type = "dropdown",
            name = "Target group size",
            choices = { "2", "4", "12" },
            choicesValues = { 2, 4, 12 },
            getFunc = function() return ADGM.vars.targetGroupSize end,
            setFunc = SetTargetGroupSize,
            default = DEFAULTS.targetGroupSize,
        },
        {
            type = "slider",
            name = "Auto-kick safety minimum",
            tooltip = "ADGM will not auto-kick when the group size is below this value.",
            min = 1,
            max = 12,
            step = 1,
            getFunc = function() return ADGM.vars.minGroupSizeForAutoKick end,
            setFunc = function(value) MarkCustomPreset(); ADGM.vars.minGroupSizeForAutoKick = value end,
            default = DEFAULTS.minGroupSizeForAutoKick,
        },
        {
            type = "checkbox",
            name = "Sync auto-kick safety with target size",
            tooltip = "When enabled, changing target group size also updates the auto-kick safety minimum.",
            getFunc = function() return ADGM.vars.syncKickSafetyWithTargetSize end,
            setFunc = SetSyncKickSafetyWithTargetSize,
            default = DEFAULTS.syncKickSafetyWithTargetSize,
        },
        {
            type = "header",
            name = "Auto Invite",
        },
        {
            type = "checkbox",
            name = "Enable auto invite",
            getFunc = function() return ADGM.vars.autoInvite.enabled end,
            setFunc = function(value) MarkCustomPreset(); ADGM.vars.autoInvite.enabled = value end,
            default = DEFAULTS.autoInvite.enabled,
        },
        {
            type = "editbox",
            name = "Trigger words",
            tooltip = "Separate triggers with commas or spaces. Example: +dolmen,+wb,+trial",
            getFunc = function() return ADGM.vars.autoInvite.triggers end,
            setFunc = function(value) MarkCustomPreset(); ADGM.vars.autoInvite.triggers = value end,
            isMultiline = false,
            width = "full",
            default = DEFAULTS.autoInvite.triggers,
        },
        {
            type = "checkbox",
            name = "Allow partial trigger match",
            tooltip = "If disabled, the full chat message must equal the trigger.",
            getFunc = function() return ADGM.vars.autoInvite.allowPartialMatch end,
            setFunc = function(value) MarkCustomPreset(); ADGM.vars.autoInvite.allowPartialMatch = value end,
            default = DEFAULTS.autoInvite.allowPartialMatch,
        },
        {
            type = "slider",
            name = "Invite delay (ms)",
            min = 0,
            max = 3000,
            step = 100,
            getFunc = function() return ADGM.vars.autoInvite.delayMs end,
            setFunc = function(value) MarkCustomPreset(); ADGM.vars.autoInvite.delayMs = value end,
            default = DEFAULTS.autoInvite.delayMs,
        },
        {
            type = "dropdown",
            name = "Invite restrictions",
            choices = { "Anyone", "Friends only", "Guild only", "Friends + Guild" },
            choicesValues = { RESTRICTION_ANYONE, RESTRICTION_FRIENDS, RESTRICTION_GUILD, RESTRICTION_FRIENDS_GUILD },
            getFunc = function() return ADGM.vars.autoInvite.restriction end,
            setFunc = function(value) MarkCustomPreset(); ADGM.vars.autoInvite.restriction = value end,
            default = DEFAULTS.autoInvite.restriction,
        },
        {
            type = "submenu",
            name = "Allowed invite channels",
            controls = {
                { type = "checkbox", name = "Zone", getFunc = function() return ADGM.vars.autoInvite.channels.zone end, setFunc = function(v) MarkCustomPreset(); ADGM.vars.autoInvite.channels.zone = v end, default = DEFAULTS.autoInvite.channels.zone },
                { type = "checkbox", name = "Whisper", getFunc = function() return ADGM.vars.autoInvite.channels.whisper end, setFunc = function(v) MarkCustomPreset(); ADGM.vars.autoInvite.channels.whisper = v end, default = DEFAULTS.autoInvite.channels.whisper },
                { type = "checkbox", name = "Say", getFunc = function() return ADGM.vars.autoInvite.channels.say end, setFunc = function(v) MarkCustomPreset(); ADGM.vars.autoInvite.channels.say = v end, default = DEFAULTS.autoInvite.channels.say },
                { type = "checkbox", name = "Yell", getFunc = function() return ADGM.vars.autoInvite.channels.yell end, setFunc = function(v) MarkCustomPreset(); ADGM.vars.autoInvite.channels.yell = v end, default = DEFAULTS.autoInvite.channels.yell },
                { type = "checkbox", name = "Group", getFunc = function() return ADGM.vars.autoInvite.channels.group end, setFunc = function(v) MarkCustomPreset(); ADGM.vars.autoInvite.channels.group = v end, default = DEFAULTS.autoInvite.channels.group },
                { type = "checkbox", name = "Guild 1", getFunc = function() return ADGM.vars.autoInvite.channels.guild1 end, setFunc = function(v) MarkCustomPreset(); ADGM.vars.autoInvite.channels.guild1 = v end, default = DEFAULTS.autoInvite.channels.guild1 },
                { type = "checkbox", name = "Guild 2", getFunc = function() return ADGM.vars.autoInvite.channels.guild2 end, setFunc = function(v) MarkCustomPreset(); ADGM.vars.autoInvite.channels.guild2 = v end, default = DEFAULTS.autoInvite.channels.guild2 },
                { type = "checkbox", name = "Guild 3", getFunc = function() return ADGM.vars.autoInvite.channels.guild3 end, setFunc = function(v) MarkCustomPreset(); ADGM.vars.autoInvite.channels.guild3 = v end, default = DEFAULTS.autoInvite.channels.guild3 },
                { type = "checkbox", name = "Guild 4", getFunc = function() return ADGM.vars.autoInvite.channels.guild4 end, setFunc = function(v) MarkCustomPreset(); ADGM.vars.autoInvite.channels.guild4 = v end, default = DEFAULTS.autoInvite.channels.guild4 },
                { type = "checkbox", name = "Guild 5", getFunc = function() return ADGM.vars.autoInvite.channels.guild5 end, setFunc = function(v) MarkCustomPreset(); ADGM.vars.autoInvite.channels.guild5 = v end, default = DEFAULTS.autoInvite.channels.guild5 },
            },
        },
        {
            type = "header",
            name = "Offline Guard",
        },
        {
            type = "checkbox",
            name = "Enable offline guard",
            getFunc = function() return ADGM.vars.offlineGuard.enabled end,
            setFunc = SetOfflineGuardEnabled,
            default = DEFAULTS.offlineGuard.enabled,
        },
        {
            type = "dropdown",
            name = "Offline action",
            choices = { "Notify only", "Auto kick" },
            choicesValues = { ACTION_NOTIFY, ACTION_AUTO },
            getFunc = function() return ADGM.vars.offlineGuard.action end,
            setFunc = function(value) MarkCustomPreset(); ADGM.vars.offlineGuard.action = value; RescheduleOfflineGuardChecks() end,
            default = DEFAULTS.offlineGuard.action,
        },
        {
            type = "slider",
            name = "Offline auto-kick timeout (seconds)",
            tooltip = "How long a member can stay offline before ADGM notifies or auto-kicks, depending on the selected action.",
            min = 5,
            max = 600,
            step = 5,
            getFunc = function() return ADGM.vars.offlineGuard.timeoutSeconds end,
            setFunc = SetOfflineGuardTimeout,
            default = DEFAULTS.offlineGuard.timeoutSeconds,
        },
        {
            type = "header",
            name = "Zone Guard",
        },
        {
            type = "checkbox",
            name = "Enable zone guard",
            getFunc = function() return ADGM.vars.zoneGuard.enabled end,
            setFunc = SetZoneGuardEnabled,
            default = DEFAULTS.zoneGuard.enabled,
        },
        {
            type = "dropdown",
            name = "Expected zone",
            choices = { "Same as me", "Same as leader", "Locked zone" },
            choicesValues = { EXPECTED_ZONE_PLAYER, EXPECTED_ZONE_LEADER, EXPECTED_ZONE_LOCKED },
            getFunc = function() return ADGM.vars.zoneGuard.expectedZone end,
            setFunc = SetZoneGuardExpectedZone,
            default = DEFAULTS.zoneGuard.expectedZone,
        },
        {
            type = "button",
            name = "Lock current zone",
            func = function()
                MarkCustomPreset()
                ADGM.vars.zoneGuard.lockedZoneIndex = GetUnitZoneIndex("player")
                SetZoneGuardExpectedZone(EXPECTED_ZONE_LOCKED)
                Chat("Locked expected zone to " .. tostring(ADGM.vars.zoneGuard.lockedZoneIndex) .. ".", true)
            end,
        },
        {
            type = "dropdown",
            name = "Wrong-zone action",
            choices = { "Notify only", "Auto kick" },
            choicesValues = { ACTION_NOTIFY, ACTION_AUTO },
            getFunc = function() return ADGM.vars.zoneGuard.action end,
            setFunc = SetZoneGuardAction,
            default = DEFAULTS.zoneGuard.action,
        },
        {
            type = "slider",
            name = "Grace period after join (seconds)",
            min = 0,
            max = 600,
            step = 5,
            getFunc = function() return ADGM.vars.zoneGuard.graceSeconds end,
            setFunc = SetZoneGuardGraceSeconds,
            default = DEFAULTS.zoneGuard.graceSeconds,
        },
        {
            type = "slider",
            name = "Wrong-zone auto-kick timeout (seconds)",
            tooltip = "How long a member can stay in the wrong zone before ADGM notifies or auto-kicks, after the join grace period.",
            min = 10,
            max = 900,
            step = 10,
            getFunc = function() return ADGM.vars.zoneGuard.timeoutSeconds end,
            setFunc = SetZoneGuardTimeoutSeconds,
            default = DEFAULTS.zoneGuard.timeoutSeconds,
        },
        {
            type = "header",
            name = "Role Guard",
        },
        {
            type = "checkbox",
            name = "Enable role guard",
            tooltip = "React when a member changes role shortly after joining. Zone and instance changes stop this guard for that member.",
            getFunc = function() return ADGM.vars.roleGuard.enabled end,
            setFunc = SetRoleGuardEnabled,
            default = DEFAULTS.roleGuard.enabled,
        },
        {
            type = "dropdown",
            name = "Role-change action",
            choices = { "Notify only", "Would kick (debug)", "Auto kick" },
            choicesValues = { ACTION_NOTIFY, ACTION_WOULD_KICK, ACTION_AUTO },
            getFunc = function() return ADGM.vars.roleGuard.action end,
            setFunc = SetRoleGuardAction,
            default = DEFAULTS.roleGuard.action,
        },
        {
            type = "description",
            text = "Role Guard only applies during the first 15 seconds after a member joins.",
        },
        {
            type = "header",
            name = "Group Finder",
        },
        {
            type = "description",
            text = "Save a listing template from ESO's normal Group Finder UI, then ADGM can create that listing again with /adgm gfrelist.",
        },
        {
            type = "checkbox",
            name = "Relist when a group member leaves",
            getFunc = function() return ADGM.vars.groupFinder.relistOnLeave end,
            setFunc = SetGroupFinderRelistOnLeave,
            default = DEFAULTS.groupFinder.relistOnLeave,
        },
        {
            type = "dropdown",
            name = "Relist action",
            choices = { "Notify only", "Auto relist" },
            choicesValues = { ACTION_NOTIFY, ACTION_AUTO },
            getFunc = function() return ADGM.vars.groupFinder.mode end,
            setFunc = SetGroupFinderMode,
            default = DEFAULTS.groupFinder.mode,
        },
        {
            type = "slider",
            name = "Relist cooldown (seconds)",
            tooltip = "Minimum time between Group Finder relist attempts.",
            min = 5,
            max = 600,
            step = 5,
            getFunc = function() return ADGM.vars.groupFinder.cooldownSeconds end,
            setFunc = function(value) MarkCustomPreset(); ADGM.vars.groupFinder.cooldownSeconds = value end,
            default = DEFAULTS.groupFinder.cooldownSeconds,
        },
        {
            type = "checkbox",
            name = "Only relist below target group size",
            tooltip = "Skip auto-relist if the current group size is already at or above the configured target size.",
            getFunc = function() return ADGM.vars.groupFinder.onlyWhenBelowTargetSize end,
            setFunc = function(value) MarkCustomPreset(); ADGM.vars.groupFinder.onlyWhenBelowTargetSize = value end,
            default = DEFAULTS.groupFinder.onlyWhenBelowTargetSize,
        },
        {
            type = "checkbox",
            name = "ADGM auto-accept applications",
            tooltip = "When ESO's Auto Accept Requests is off, ADGM accepts Group Finder applications after saving the applicant role for Role Guard.",
            getFunc = function() return ADGM.vars.groupFinder.autoAcceptApplications end,
            setFunc = SetGroupFinderAutoAcceptApplications,
            default = DEFAULTS.groupFinder.autoAcceptApplications,
        },
        {
            type = "slider",
            name = "Automatic Re-list threshold",
            tooltip = "For 12-player presets except Trial, automatic relist starts when group size is this value or lower.",
            min = 1,
            max = 11,
            step = 1,
            getFunc = function() return ADGM.vars.groupFinder.twelvePlayerRelistThreshold end,
            setFunc = SetTwelvePlayerRelistThreshold,
            default = DEFAULTS.groupFinder.twelvePlayerRelistThreshold,
        },
        {
            type = "button",
            name = "Save current listing template",
            tooltip = "Create a listing with ESO's normal Group Finder UI first, then press this to store it in ADGM.",
            func = CaptureCurrentGroupFinderListing,
        },
        {
            type = "button",
            name = "Show saved listing template",
            func = PrintSavedGroupFinderListing,
        },
        {
            type = "button",
            name = "Relist from saved template",
            tooltip = "Writes the saved template into the Group Finder draft and creates the listing.",
            func = function() RelistSavedGroupFinderListing("settings") end,
        },
    }

    if ADGM.vars.debug then
        options[#options + 1] = {
            type = "header",
            name = "Debug",
        }
        options[#options + 1] = {
            type = "checkbox",
            name = "Log Group Finder events",
            tooltip = "Debug option for testing listing create result events in chat.",
            getFunc = function() return ADGM.vars.groupFinder.eventLog end,
            setFunc = function(value) SetGroupFinderEventLog(value) end,
            default = DEFAULTS.groupFinder.eventLog,
        }
    end

    LAM:RegisterOptionControls("ADawgsGroupManagerOptions", options)
    RegisterSettingsPresetDropdownCallbacks()
    RefreshSettingsPresetDropdown()
end


-- Export shared locals for the following manifest files.
ADGM.UpdateNativeGroupFinderCreatePanel = UpdateNativeGroupFinderCreatePanel
ADGM.UpdatePresetControls = UpdatePresetControls
