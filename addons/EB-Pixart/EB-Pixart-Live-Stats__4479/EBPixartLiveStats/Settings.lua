local Addon = EBPixartLiveStats

Addon.Settings = Addon.Settings or {}

local Settings = Addon.Settings
local ACTION_CONTROL_HEIGHT = 32
local ACTION_CONTROL_PADDING = 8
local SUBSECTION_CONTROL_HEIGHT = 28

local function AddOptions(target, source)
    for _, entry in ipairs(source) do
        target[#target + 1] = entry
    end
end

local function CreateSubsectionTitle(title)
    return {
        type = "custom",
        name = title,
        width = "full",
        minHeight = SUBSECTION_CONTROL_HEIGHT,
        maxHeight = SUBSECTION_CONTROL_HEIGHT,
        createFunc = function(control)
            local container = WINDOW_MANAGER:CreateControl(nil, control, CT_CONTROL)
            container:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
            container:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
            container:SetHeight(SUBSECTION_CONTROL_HEIGHT)

            local label = WINDOW_MANAGER:CreateControl(nil, container, CT_LABEL)
            label:SetAnchor(CENTER, container, CENTER, 0, 0)
            label:SetFont("ZoFontHeader2")
            label:SetColor(0.84, 0.84, 0.84, 0.92)
            label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            label:SetText(control.data.name or "")

            local dividerLeft = WINDOW_MANAGER:CreateControl(nil, container, CT_BACKDROP)
            dividerLeft:SetAnchor(LEFT, container, LEFT, 0, 0)
            dividerLeft:SetAnchor(RIGHT, label, LEFT, -10, 0)
            dividerLeft:SetHeight(1)
            dividerLeft:SetCenterColor(1, 1, 1, 0.10)
            dividerLeft:SetEdgeColor(0, 0, 0, 0)

            local dividerRight = WINDOW_MANAGER:CreateControl(nil, container, CT_BACKDROP)
            dividerRight:SetAnchor(LEFT, label, RIGHT, 10, 0)
            dividerRight:SetAnchor(RIGHT, container, RIGHT, 0, 0)
            dividerRight:SetHeight(1)
            dividerRight:SetCenterColor(1, 1, 1, 0.10)
            dividerRight:SetEdgeColor(0, 0, 0, 0)

            control.label = label
        end,
        refreshFunc = function(control)
            if control and control.label then
                control.label:SetText(control.data.name or "")
            end
        end,
    }
end

local function ConfigureLeftAlignedActionButton(control)
    if not control or not control.button then
        return
    end

    local button = control.button
    local width = zo_max(260, control:GetWidth() - ACTION_CONTROL_PADDING)

    button:ClearAnchors()
    button:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    button:SetDimensions(width, ACTION_CONTROL_HEIGHT)
    button:SetText(control.data.name or "")
    button.data = { tooltipText = control.data.tooltip }

    local label = button:GetLabelControl()
    if label then
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    end
end

local function CreateLeftAlignedActionControl(control)
    local button = WINDOW_MANAGER:CreateControlFromVirtual(nil, control, "ZO_DefaultButton")
    control.button = button

    button:SetClickSound("Click")
    button:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
    button:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
    button:SetHandler("OnClicked", function()
        if control.data.func then
            control.data.func()
            LibAddonMenu2.util.RequestRefreshIfNeeded(control)
        end
    end)

    ConfigureLeftAlignedActionButton(control)
end

local function CreateLeftAlignedActionEntry(name, tooltip, callback)
    return {
        type = "custom",
        name = name,
        tooltip = tooltip,
        func = callback,
        width = "full",
        minHeight = ACTION_CONTROL_HEIGHT,
        maxHeight = ACTION_CONTROL_HEIGHT,
        createFunc = CreateLeftAlignedActionControl,
        refreshFunc = ConfigureLeftAlignedActionButton,
    }
end

function Settings:Initialize()
    if not LibAddonMenu2 then
        Addon:Print(GetString(EBPXLIVESTATS_CHAT_LAM_MISSING))
        return
    end

    self:CreatePanel()
    self:RegisterOptions()
end

function Settings:CreatePanel()
    local panelData = {
        type = "panel",
        name = Addon.displayName,
        displayName = Addon.displayName,
        author = "EB-Pixart",
        version = Addon.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    self.panel = LibAddonMenu2:RegisterAddonPanel(Addon.name .. "_Options", panelData)

    if self.panel and CALLBACK_MANAGER and CALLBACK_MANAGER.RegisterCallback then
        CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
            if panel ~= self.panel then
                return
            end

            if Addon.UI and Addon.UI.EnterPreviewMode then
                Addon.UI:EnterPreviewMode()
            end
        end)

        CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
            if panel ~= self.panel then
                return
            end

            if Addon.UI and Addon.UI.ExitPreviewMode then
                Addon.UI:ExitPreviewMode()
            end
        end)
    end
end

function Settings:BuildSessionShareOptions()
    return {
        { type = "header", name = GetString(EBPXLIVESTATS_SETTINGS_SESSION_SHARE_HEADER), width = "full" },
        CreateLeftAlignedActionEntry(
            GetString(EBPXLIVESTATS_SETTINGS_MANUAL_RESET_NAME),
            GetString(EBPXLIVESTATS_SETTINGS_MANUAL_RESET_TOOLTIP),
            function() Addon:ManualResetSession() end
        ),
        CreateLeftAlignedActionEntry(
            GetString(EBPXLIVESTATS_SETTINGS_SHARE_CURRENT_NAME),
            nil,
            function() Addon:ShareCurrentSession() end
        ),
        CreateLeftAlignedActionEntry(
            GetString(EBPXLIVESTATS_SETTINGS_SHARE_LAST_NAME),
            nil,
            function() Addon:ShareLastSession() end
        ),
        CreateLeftAlignedActionEntry(
            GetString(EBPXLIVESTATS_SETTINGS_SHARE_CURRENT_HEALS_NAME),
            nil,
            function() Addon:ShareCurrentHeals() end
        ),
        CreateLeftAlignedActionEntry(
            GetString(EBPXLIVESTATS_SETTINGS_SHARE_LAST_HEALS_NAME),
            nil,
            function() Addon:ShareLastHeals() end
        ),
    }
end

function Settings:BuildMainWindowOptions()
    return {
        { type = "header", name = GetString(EBPXLIVESTATS_SETTINGS_WINDOW_HEADER), width = "full" },
        {
            type = "checkbox",
            name = GetString(EBPXLIVESTATS_SETTINGS_UNLOCK_NAME),
            tooltip = GetString(EBPXLIVESTATS_SETTINGS_UNLOCK_TOOLTIP),
            getFunc = function() return Addon.sv.unlocked end,
            setFunc = function(value) Addon.UI:SetUnlocked(value) end,
            default = Addon.defaults.unlocked,
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(EBPXLIVESTATS_SETTINGS_HIDE_NAME),
            tooltip = GetString(EBPXLIVESTATS_SETTINGS_HIDE_TOOLTIP),
            getFunc = function() return Addon.sv.ui.hidden end,
            setFunc = function(value) Addon.UI:SetWindowHidden(value) end,
            default = Addon.defaults.ui.hidden,
            width = "full",
        },
        {
            type = "button",
            name = GetString(EBPXLIVESTATS_SETTINGS_RESET_POSITION_NAME),
            tooltip = GetString(EBPXLIVESTATS_SETTINGS_RESET_POSITION_TOOLTIP),
            func = function() Addon.UI:ResetPosition() end,
            width = "full",
        },
    }
end

function Settings:BuildMainStatsOptions()
    return {
        { type = "header", name = GetString(EBPXLIVESTATS_SETTINGS_MAIN_STATS_HEADER), width = "full" },
        CreateSubsectionTitle(GetString(EBPXLIVESTATS_SETTINGS_COMBAT_SUBHEADER)),
        {
            type = "checkbox",
            name = GetString(EBPXLIVESTATS_SETTINGS_SHOW_DPS_NAME),
            getFunc = function() return Addon.sv.showDps end,
            setFunc = function(value) Addon.sv.showDps = value; Addon.UI:RefreshAll() end,
            default = Addon.defaults.showDps,
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(EBPXLIVESTATS_SETTINGS_SHOW_DAMAGE_NAME),
            getFunc = function() return Addon.sv.showDamage end,
            setFunc = function(value) Addon.sv.showDamage = value; Addon.UI:RefreshAll() end,
            default = Addon.defaults.showDamage,
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(EBPXLIVESTATS_SETTINGS_SHOW_HEALING_NAME),
            getFunc = function() return Addon.sv.showHealing end,
            setFunc = function(value) Addon.sv.showHealing = value; Addon.UI:RefreshAll() end,
            default = Addon.defaults.showHealing,
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(EBPXLIVESTATS_SETTINGS_SHOW_COMBAT_STATE_NAME),
            getFunc = function() return Addon.sv.showCombatState end,
            setFunc = function(value) Addon.sv.showCombatState = value; Addon.UI:RefreshAll() end,
            default = Addon.defaults.showCombatState,
            width = "full",
        },
        CreateSubsectionTitle(GetString(EBPXLIVESTATS_SETTINGS_PVE_SUBHEADER)),
        {
            type = "checkbox",
            name = GetString(EBPXLIVESTATS_SETTINGS_SHOW_SPELL_CRIT_NAME),
            getFunc = function() return Addon.sv.showSpellCrit end,
            setFunc = function(value) Addon.sv.showSpellCrit = value; Addon.UI:RefreshAll() end,
            default = Addon.defaults.showSpellCrit,
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(EBPXLIVESTATS_SETTINGS_SHOW_WEAPON_CRIT_NAME),
            getFunc = function() return Addon.sv.showWeaponCrit end,
            setFunc = function(value) Addon.sv.showWeaponCrit = value; Addon.UI:RefreshAll() end,
            default = Addon.defaults.showWeaponCrit,
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(EBPXLIVESTATS_SETTINGS_SHOW_SPELL_POWER_NAME),
            getFunc = function() return Addon.sv.showSpellPower end,
            setFunc = function(value) Addon.sv.showSpellPower = value; Addon.UI:RefreshAll() end,
            default = Addon.defaults.showSpellPower,
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(EBPXLIVESTATS_SETTINGS_SHOW_WEAPON_POWER_NAME),
            getFunc = function() return Addon.sv.showWeaponPower end,
            setFunc = function(value) Addon.sv.showWeaponPower = value; Addon.UI:RefreshAll() end,
            default = Addon.defaults.showWeaponPower,
            width = "full",
        },
        CreateSubsectionTitle(GetString(EBPXLIVESTATS_SETTINGS_PVP_SUBHEADER)),
        {
            type = "checkbox",
            name = GetString(EBPXLIVESTATS_SETTINGS_SHOW_SPELL_PEN_NAME),
            getFunc = function() return Addon.sv.showSpellPen end,
            setFunc = function(value) Addon.sv.showSpellPen = value; Addon.UI:RefreshAll() end,
            default = Addon.defaults.showSpellPen,
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(EBPXLIVESTATS_SETTINGS_SHOW_WEAPON_PEN_NAME),
            getFunc = function() return Addon.sv.showWeaponPen end,
            setFunc = function(value) Addon.sv.showWeaponPen = value; Addon.UI:RefreshAll() end,
            default = Addon.defaults.showWeaponPen,
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(EBPXLIVESTATS_SETTINGS_SHOW_INCOMING_HEALING_PERCENT_NAME),
            getFunc = function() return Addon.sv.showIncomingHealingPercent == true end,
            setFunc = function(value) Addon.sv.showIncomingHealingPercent = value == true; Addon.UI:RefreshAll() end,
            default = Addon.defaults.showIncomingHealingPercent,
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(EBPXLIVESTATS_SETTINGS_SHOW_BLOCK_PERCENT_NAME),
            getFunc = function() return Addon.sv.showBlockPercent == true end,
            setFunc = function(value) Addon.sv.showBlockPercent = value == true; Addon.UI:RefreshAll() end,
            default = Addon.defaults.showBlockPercent,
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(EBPXLIVESTATS_SETTINGS_SHOW_BLOCK_COST_NAME),
            getFunc = function() return Addon.sv.showBlockCost == true end,
            setFunc = function(value) Addon.sv.showBlockCost = value == true; Addon.UI:RefreshAll() end,
            default = Addon.defaults.showBlockCost,
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(EBPXLIVESTATS_SETTINGS_SHOW_PHYSICAL_RESISTANCE_NAME),
            getFunc = function() return Addon.sv.showPhysicalResistance == true end,
            setFunc = function(value) Addon.sv.showPhysicalResistance = value == true; Addon.UI:RefreshAll() end,
            default = Addon.defaults.showPhysicalResistance,
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(EBPXLIVESTATS_SETTINGS_SHOW_SPELL_RESISTANCE_NAME),
            getFunc = function() return Addon.sv.showSpellResistance == true end,
            setFunc = function(value) Addon.sv.showSpellResistance = value == true; Addon.UI:RefreshAll() end,
            default = Addon.defaults.showSpellResistance,
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(EBPXLIVESTATS_SETTINGS_SHOW_CRITICAL_RESISTANCE_NAME),
            getFunc = function() return Addon.sv.showCriticalResistance == true end,
            setFunc = function(value) Addon.sv.showCriticalResistance = value == true; Addon.UI:RefreshAll() end,
            default = Addon.defaults.showCriticalResistance,
            width = "full",
        },
    }
end

function Settings:BuildSessionOptions()
    return {
        { type = "header", name = GetString(EBPXLIVESTATS_SETTINGS_SESSION_HEADER), width = "full" },
        {
            type = "checkbox",
            name = GetString(EBPXLIVESTATS_SETTINGS_AUTO_RESET_ENABLED_NAME),
            tooltip = GetString(EBPXLIVESTATS_SETTINGS_AUTO_RESET_ENABLED_TOOLTIP),
            getFunc = function() return Addon.sv.autoResetEnabled == true end,
            setFunc = function(value) Addon.sv.autoResetEnabled = value == true end,
            default = Addon.defaults.autoResetEnabled,
            width = "full",
        },
        {
            type = "slider",
            name = GetString(EBPXLIVESTATS_SETTINGS_AUTO_RESET_DELAY_NAME),
            tooltip = GetString(EBPXLIVESTATS_SETTINGS_AUTO_RESET_DELAY_TOOLTIP),
            min = 5, max = 60, step = 1,
            getFunc = function() return tonumber(Addon.sv.autoResetDelaySeconds) or Addon.defaults.autoResetDelaySeconds end,
            setFunc = function(value) Addon.sv.autoResetDelaySeconds = zo_clamp(tonumber(value) or Addon.defaults.autoResetDelaySeconds, 5, 60) end,
            default = Addon.defaults.autoResetDelaySeconds,
            width = "full",
        },
    }
end

function Settings:BuildMainAppearanceOptions()
    return {
        { type = "header", name = GetString(EBPXLIVESTATS_SETTINGS_MAIN_APPEARANCE_HEADER), width = "full" },
        {
            type = "slider",
            name = GetString(EBPXLIVESTATS_SETTINGS_LABEL_FONT_SIZE_NAME),
            min = 8, max = 28, step = 1,
            getFunc = function() return Addon.sv.fontSizeLabels end,
            setFunc = function(value) Addon.sv.fontSizeLabels = value; Addon.UI:ApplyAppearance(); Addon.UI:RefreshAll() end,
            default = Addon.defaults.fontSizeLabels,
            width = "full",
        },
        {
            type = "slider",
            name = GetString(EBPXLIVESTATS_SETTINGS_VALUE_FONT_SIZE_NAME),
            min = 8, max = 28, step = 1,
            getFunc = function() return Addon.sv.fontSizeValues end,
            setFunc = function(value) Addon.sv.fontSizeValues = value; Addon.UI:ApplyAppearance(); Addon.UI:RefreshAll() end,
            default = Addon.defaults.fontSizeValues,
            width = "full",
        },
        {
            type = "slider",
            name = GetString(EBPXLIVESTATS_SETTINGS_WINDOW_WIDTH_NAME),
            min = 170, max = 560, step = 10,
            getFunc = function() return Addon.sv.windowWidth end,
            setFunc = function(value) Addon.UI:ApplyWindowWidth(value); Addon.UI:UpdateResponsiveLayout(); Addon.UI:RefreshAll() end,
            default = Addon.defaults.windowWidth,
            width = "full",
        },
        {
            type = "slider",
            name = GetString(EBPXLIVESTATS_SETTINGS_WINDOW_HEIGHT_NAME),
            min = 220, max = 900, step = 10,
            getFunc = function() return Addon.sv.windowHeight end,
            setFunc = function(value) Addon.UI:ApplyWindowHeight(value); Addon.UI:UpdateResponsiveLayout(); Addon.UI:RefreshAll() end,
            default = Addon.defaults.windowHeight,
            width = "full",
        },
        {
            type = "colorpicker",
            name = GetString(EBPXLIVESTATS_SETTINGS_TITLE_COLOR_NAME),
            getFunc = function() return Addon.sv.titleColorR, Addon.sv.titleColorG, Addon.sv.titleColorB, Addon.sv.titleColorA end,
            setFunc = function(r, g, b, a) Addon.sv.titleColorR = r; Addon.sv.titleColorG = g; Addon.sv.titleColorB = b; Addon.sv.titleColorA = a; Addon.UI:ApplyAppearance(); Addon.UI:RefreshAll() end,
            default = { Addon.defaults.titleColorR, Addon.defaults.titleColorG, Addon.defaults.titleColorB, Addon.defaults.titleColorA },
            width = "full",
        },
        {
            type = "colorpicker",
            name = GetString(EBPXLIVESTATS_SETTINGS_LABEL_COLOR_NAME),
            getFunc = function() return Addon.sv.labelColorR, Addon.sv.labelColorG, Addon.sv.labelColorB, Addon.sv.labelColorA end,
            setFunc = function(r, g, b, a) Addon.sv.labelColorR = r; Addon.sv.labelColorG = g; Addon.sv.labelColorB = b; Addon.sv.labelColorA = a; Addon.UI:ApplyAppearance(); Addon.UI:RefreshAll() end,
            default = { Addon.defaults.labelColorR, Addon.defaults.labelColorG, Addon.defaults.labelColorB, Addon.defaults.labelColorA },
            width = "full",
        },
        {
            type = "colorpicker",
            name = GetString(EBPXLIVESTATS_SETTINGS_VALUE_COLOR_NAME),
            getFunc = function() return Addon.sv.valueColorR, Addon.sv.valueColorG, Addon.sv.valueColorB, Addon.sv.valueColorA end,
            setFunc = function(r, g, b, a) Addon.sv.valueColorR = r; Addon.sv.valueColorG = g; Addon.sv.valueColorB = b; Addon.sv.valueColorA = a; Addon.UI:ApplyAppearance(); Addon.UI:RefreshAll() end,
            default = { Addon.defaults.valueColorR, Addon.defaults.valueColorG, Addon.defaults.valueColorB, Addon.defaults.valueColorA },
            width = "full",
        },
        {
            type = "button",
            name = GetString(EBPXLIVESTATS_SETTINGS_RESET_APPEARANCE_NAME),
            tooltip = GetString(EBPXLIVESTATS_SETTINGS_RESET_APPEARANCE_TOOLTIP),
            func = function() Addon.UI:ResetAppearance() end,
            width = "full",
        },
    }
end

function Settings:BuildHealWindowOptions()
    return {
        { type = "header", name = GetString(EBPXLIVESTATS_SETTINGS_HEAL_WINDOW_HEADER), width = "full" },
        {
            type = "checkbox",
            name = GetString(EBPXLIVESTATS_SETTINGS_HEAL_WINDOW_SHOW_NAME),
            getFunc = function() return Addon.sv.healWindow.hidden == false end,
            setFunc = function(value) if Addon.HealUI and Addon.HealUI.SetWindowHidden then Addon.HealUI:SetWindowHidden(not value) end end,
            default = not Addon.defaults.healWindow.hidden,
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(EBPXLIVESTATS_SETTINGS_HEAL_WINDOW_UNLOCK_NAME),
            getFunc = function() return Addon.sv.healWindow.unlocked == true end,
            setFunc = function(value) if Addon.HealUI and Addon.HealUI.SetUnlocked then Addon.HealUI:SetUnlocked(value) end end,
            default = Addon.defaults.healWindow.unlocked,
            width = "full",
        },
        {
            type = "button",
            name = GetString(EBPXLIVESTATS_SETTINGS_HEAL_WINDOW_RESET_POSITION_NAME),
            func = function() if Addon.HealUI and Addon.HealUI.ResetPosition then Addon.HealUI:ResetPosition() end end,
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(EBPXLIVESTATS_SETTINGS_HEAL_WINDOW_AUTO_TRACKING_NAME),
            tooltip = GetString(EBPXLIVESTATS_SETTINGS_HEAL_WINDOW_AUTO_TRACKING_TOOLTIP),
            getFunc = function() return Addon.sv.healAnalysisAutoTracking == true end,
            setFunc = function(value) Addon.sv.healAnalysisAutoTracking = value == true end,
            default = Addon.defaults.healAnalysisAutoTracking,
            width = "full",
        },
    }
end

function Settings:BuildHealAppearanceOptions()
    return {
        { type = "header", name = GetString(EBPXLIVESTATS_SETTINGS_HEAL_WINDOW_APPEARANCE_HEADER), width = "full" },
        {
            type = "slider",
            name = GetString(EBPXLIVESTATS_SETTINGS_HEAL_WINDOW_LABEL_FONT_SIZE_NAME),
            min = 8, max = 28, step = 1,
            getFunc = function() return Addon.sv.healWindow.fontSizeLabels end,
            setFunc = function(value) Addon.sv.healWindow.fontSizeLabels = value; if Addon.HealUI and Addon.HealUI.RefreshAll then Addon.HealUI:RefreshAll() end end,
            default = Addon.defaults.healWindow.fontSizeLabels,
            width = "full",
        },
        {
            type = "slider",
            name = GetString(EBPXLIVESTATS_SETTINGS_HEAL_WINDOW_VALUE_FONT_SIZE_NAME),
            min = 8, max = 28, step = 1,
            getFunc = function() return Addon.sv.healWindow.fontSizeValues end,
            setFunc = function(value) Addon.sv.healWindow.fontSizeValues = value; if Addon.HealUI and Addon.HealUI.RefreshAll then Addon.HealUI:RefreshAll() end end,
            default = Addon.defaults.healWindow.fontSizeValues,
            width = "full",
        },
        {
            type = "slider",
            name = GetString(EBPXLIVESTATS_SETTINGS_HEAL_WINDOW_WIDTH_NAME),
            min = 250, max = 620, step = 10,
            getFunc = function() return Addon.sv.healWindow.width end,
            setFunc = function(value) if Addon.HealUI and Addon.HealUI.ApplyWindowWidth then Addon.HealUI:ApplyWindowWidth(value) end; if Addon.HealUI and Addon.HealUI.RefreshAll then Addon.HealUI:RefreshAll() end end,
            default = Addon.defaults.healWindow.width,
            width = "full",
        },
        {
            type = "slider",
            name = GetString(EBPXLIVESTATS_SETTINGS_HEAL_WINDOW_HEIGHT_NAME),
            min = 210, max = 720, step = 10,
            getFunc = function() return Addon.sv.healWindow.height end,
            setFunc = function(value) if Addon.HealUI and Addon.HealUI.ApplyWindowHeight then Addon.HealUI:ApplyWindowHeight(value) end; if Addon.HealUI and Addon.HealUI.RefreshAll then Addon.HealUI:RefreshAll() end end,
            default = Addon.defaults.healWindow.height,
            width = "full",
        },
        {
            type = "colorpicker",
            name = GetString(EBPXLIVESTATS_SETTINGS_HEAL_WINDOW_TITLE_COLOR_NAME),
            getFunc = function() return Addon.sv.healWindow.titleColorR, Addon.sv.healWindow.titleColorG, Addon.sv.healWindow.titleColorB, Addon.sv.healWindow.titleColorA end,
            setFunc = function(r, g, b, a) Addon.sv.healWindow.titleColorR = r; Addon.sv.healWindow.titleColorG = g; Addon.sv.healWindow.titleColorB = b; Addon.sv.healWindow.titleColorA = a; if Addon.HealUI and Addon.HealUI.RefreshAll then Addon.HealUI:RefreshAll() end end,
            default = { Addon.defaults.healWindow.titleColorR, Addon.defaults.healWindow.titleColorG, Addon.defaults.healWindow.titleColorB, Addon.defaults.healWindow.titleColorA },
            width = "full",
        },
        {
            type = "colorpicker",
            name = GetString(EBPXLIVESTATS_SETTINGS_HEAL_WINDOW_LABEL_COLOR_NAME),
            getFunc = function() return Addon.sv.healWindow.labelColorR, Addon.sv.healWindow.labelColorG, Addon.sv.healWindow.labelColorB, Addon.sv.healWindow.labelColorA end,
            setFunc = function(r, g, b, a) Addon.sv.healWindow.labelColorR = r; Addon.sv.healWindow.labelColorG = g; Addon.sv.healWindow.labelColorB = b; Addon.sv.healWindow.labelColorA = a; if Addon.HealUI and Addon.HealUI.RefreshAll then Addon.HealUI:RefreshAll() end end,
            default = { Addon.defaults.healWindow.labelColorR, Addon.defaults.healWindow.labelColorG, Addon.defaults.healWindow.labelColorB, Addon.defaults.healWindow.labelColorA },
            width = "full",
        },
        {
            type = "colorpicker",
            name = GetString(EBPXLIVESTATS_SETTINGS_HEAL_WINDOW_VALUE_COLOR_NAME),
            getFunc = function() return Addon.sv.healWindow.valueColorR, Addon.sv.healWindow.valueColorG, Addon.sv.healWindow.valueColorB, Addon.sv.healWindow.valueColorA end,
            setFunc = function(r, g, b, a) Addon.sv.healWindow.valueColorR = r; Addon.sv.healWindow.valueColorG = g; Addon.sv.healWindow.valueColorB = b; Addon.sv.healWindow.valueColorA = a; if Addon.HealUI and Addon.HealUI.RefreshAll then Addon.HealUI:RefreshAll() end end,
            default = { Addon.defaults.healWindow.valueColorR, Addon.defaults.healWindow.valueColorG, Addon.defaults.healWindow.valueColorB, Addon.defaults.healWindow.valueColorA },
            width = "full",
        },
        {
            type = "button",
            name = GetString(EBPXLIVESTATS_SETTINGS_HEAL_WINDOW_RESET_APPEARANCE_NAME),
            tooltip = GetString(EBPXLIVESTATS_SETTINGS_HEAL_WINDOW_RESET_APPEARANCE_TOOLTIP),
            func = function() if Addon.HealUI and Addon.HealUI.ResetAppearance then Addon.HealUI:ResetAppearance() end end,
            width = "full",
        },
    }
end

function Settings:RegisterOptions()
    local optionsData = {
        { type = "description", text = GetString(EBPXLIVESTATS_SETTINGS_DESCRIPTION), width = "full" },
    }

    AddOptions(optionsData, self:BuildMainWindowOptions())
    AddOptions(optionsData, self:BuildMainStatsOptions())
    AddOptions(optionsData, self:BuildMainAppearanceOptions())
    AddOptions(optionsData, self:BuildHealWindowOptions())
    AddOptions(optionsData, self:BuildHealAppearanceOptions())
    AddOptions(optionsData, self:BuildSessionOptions())
    AddOptions(optionsData, self:BuildSessionShareOptions())

    LibAddonMenu2:RegisterOptionControls(Addon.name .. "_Options", optionsData)
end
