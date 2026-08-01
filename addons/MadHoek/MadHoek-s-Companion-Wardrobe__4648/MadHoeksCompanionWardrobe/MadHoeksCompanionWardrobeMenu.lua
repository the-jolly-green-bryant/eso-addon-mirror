-- ============================================================================
-- Companion Wardrobe
-- LibAddonMenu Settings
--
-- Responsibilities:
-- - Build the addon settings panel.
-- - Expose user-facing configuration through LibAddonMenu.
-- - Keep settings changes connected to live UI refreshes where needed.
-- - Provide debug-only options behind the debug section.
-- ============================================================================
-- sentry to make sure MHCWL is declared before use
if MHCWL == nil then MHCWL = {} end
local MHCWL = MHCWL
local wasMenuCreated = false

function MHCWL.InitializeSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end
    if wasMenuCreated then return end

    local panelData = {
        type = "panel",
        name = GetString(MHCWL_PANEL),
        displayName = GetString(MHCWL_PANEL),
        author = "MadHoek",
        version = MHCWL.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel("MHCWL_SettingsPanel", panelData)

    local optionsTable = {
        [1] = {
            type = "header",
            name = GetString(MHCWL_PANEL_MAIN_HEADER),
        },
        [2] = {
            type = "checkbox",
            name = GetString(MHCWL_WINDOW_OPEN_WITH),
            tooltip = GetString(MHCWL_WINDOW_OPEN_WITH_TOOLTIP),
            getFunc = function()
                return MHCWL.saved.settings.window.showWith
            end,
            setFunc = function(value)
                MHCWL.saved.settings.window.showWith = value

                if value then
                    MHCWL.Debug("Show with Companion Menu enabled: " .. tostring(value))
                end
            end,
            default = MHCWL.defaults.settings.window.showWith,
            width = "full",
        },
        [3] = {
            type = "checkbox",
            name = GetString(MHCWL_MENU_BUTTON_OPEN_WITH),
            tooltip = GetString(MHCWL_MENU_BUTTON_OPEN_WITH_TOOLTIP),
            getFunc = function()
                return MHCWL.saved.settings.companionButton.enabled
            end,
            setFunc = function(value)
                MHCWL.saved.settings.companionButton.enabled = value

                if MHCWL.companionMenuButton then
                    MHCWL.companionMenuButton:SetHidden(not value)
                end
            end,
            default = MHCWL.defaults.settings.companionButton.enabled,
            width = "full",
        },
        [4] = {
            type = "button",
            name = GetString(MHCWL_SETTINGS_RESET_COMPANION_BUTTON_POSITION),
            tooltip = GetString(MHCWL_SETTINGS_RESET_COMPANION_BUTTON_POSITION_TOOLTIP),
            func = function()
                MHCWL.saved.settings.companionButton.left = nil
                MHCWL.saved.settings.companionButton.top = nil

                if MHCWL.companionMenuButtonHost then
                    MHCWL.companionMenuButtonHost:ClearAnchors()
                    MHCWL.companionMenuButtonHost:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
                end

                MHCWL.Notify(GetString(MHCWL_NOTIFY_COMPANION_BUTTON_POSITION_RESET))
            end,
            width = "full",
        },
        [5] = {
            type = "dropdown",
            name = GetString(MHCWL_SETTINGS_TOOLTIP_MODE),
            tooltip = GetString(MHCWL_SETTINGS_TOOLTIP_MODE_TOOLTIP),
            choices = {
                GetString(MHCWL_SETTINGS_TOOLTIP_MODE_OFF),
                GetString(MHCWL_SETTINGS_TOOLTIP_MODE_SIMPLE),
                GetString(MHCWL_SETTINGS_TOOLTIP_MODE_TUTORIAL),
            },
            choicesValues = {
                MHCWL.TOOLTIP_MODE_OFF,
                MHCWL.TOOLTIP_MODE_SIMPLE,
                MHCWL.TOOLTIP_MODE_TUTORIAL,
            },
            getFunc = function()
                return MHCWL.GetTooltipMode()
            end,
            setFunc = function(value)
                MHCWL.saved.settings.tooltipMode = value
            end,
            default = MHCWL.defaults.settings.tooltipMode,
            width = "full",
        },
        [6] = {
            type = "submenu",
            name = GetString(MHCWL_COLORS_HEADER),
            -- tooltip = GetString(MHCWL_COLORS_HEADER_TOOLTIP),
            controls = {
                [1] = {
                    type = "colorpicker",
                    name = GetString(MHCWL_SETTINGS_ACTIVE_HIGHLIGHT_COLOR),
                    tooltip = GetString(MHCWL_SETTINGS_ACTIVE_HIGHLIGHT_COLOR_TOOLTIP),
                    getFunc = function()
                        local color = MHCWL.saved.settings.activeHighlightColor
                        return color[1], color[2], color[3], color[4]
                    end,
                    setFunc = function(r, g, b, a)
                        MHCWL.saved.settings.activeHighlightColor = {r, g, b, a}
                        MHCWL.RefreshWindow()
                    end,
                    default = MHCWL.defaults.settings.activeHighlightColor,
                    width = "full",
                },
                [2] = {
                    type = "button",
                    name = GetString(MHCWL_SETTINGS_ACTIVE_HIGHLIGHT_COLOR_RESET),
                    tooltip = GetString(MHCWL_SETTINGS_ACTIVE_HIGHLIGHT_COLOR_RESET_TOOLTIP),
                    func = function()
                        MHCWL.saved.settings.activeHighlightColor =
                            MHCWL.DeepCopy(MHCWL.defaults.settings.activeHighlightColor)

                        MHCWL.RefreshWindow()
                        MHCWL.Notify(GetString(MHCWL_NOTIFY_ACTIVE_HIGHLIGHT_COLOR_RESET))
                    end,
                    width = "full",
                },
                [3] = {
                    type = "submenu",
                    name = GetString(MHCWL_SETTINGS_LOADOUT_COLOR_HEADER),
                    -- tooltip = GetString(MHCWL_SETTINGS_LOADOUT_COLOR_HEADER_TOOLTIP,
                    controls = (function()
                    local controls = {}

                    table.insert(controls, {
                        type = "dropdown",
                        name = GetString(MHCWL_COLOR_PROFILE),
                        tooltip = GetString(MHCWL_COLOR_PROFILE_TOOLTIP),
                        choices = {
                            GetString(MHCWL_COLOR_PROFILE_STANDARD),
                            GetString(MHCWL_COLOR_PROFILE_ROLE),
                            GetString(MHCWL_COLOR_PROFILE_CUSTOM),
                        },
                        choicesValues = {
                            MHCWL.COLOR_PROFILE_STANDARD,
                            MHCWL.COLOR_PROFILE_ROLE,
                            MHCWL.COLOR_PROFILE_CUSTOM,
                        },
                        getFunc = function()
                            return MHCWL.saved.settings.colorProfile
                                or MHCWL.COLOR_PROFILE_STANDARD
                        end,
                        setFunc = function(value)
                            MHCWL.ApplyLoadoutColorProfile(value)
                        end,
                        default = MHCWL.defaults.settings.colorProfile,
                        width = "full",
                    })

                    table.insert(controls, {
                        type = "divider",
                        width = "full",
                    })

                    for slotIndex = 1, 10 do
                        local index = slotIndex

                        table.insert(controls, {
                            type = "checkbox",
                            name = GetString(MHCWL_COLOR_SLOT_ENABLED) .. " " .. tostring(index),
                            getFunc = function()
                                local slot = MHCWL.GetLoadoutColorSlot(index)
                                return slot and slot.active == true
                            end,
                            setFunc = function(value)
                                local slot = MHCWL.GetLoadoutColorSlot(index)
                                if not slot then return end

                                slot.active = value == true

                                MHCWL.RefreshLoadoutColorDropdown()
                                MHCWL.RefreshWindow()
                                MHCWL.RefreshOpenInspectWindow()
                            end,
                            width = "full",
                        })

                        table.insert(controls, {
                            type = "editbox",
                            name = GetString(MHCWL_COLOR_SLOT_NAME) .. " " .. tostring(index),
                            getFunc = function()
                                return MHCWL.GetLoadoutColorSlotName(index)
                            end,
                            setFunc = function(value)
                                local slot = MHCWL.GetLoadoutColorSlot(index)
                                if not slot then return end

                                value = zo_strtrim(tostring(value or ""))

                                if value == "" then
                                    value = GetString(MHCWL_COLOR_SLOT_NAME) .. " " .. tostring(index)
                                end

                                slot.name = value

                                MHCWL.RefreshLoadoutColorDropdown()
                                MHCWL.RefreshWindow()
                                MHCWL.RefreshOpenInspectWindow()
                            end,
                            width = "full",
                        })

                        table.insert(controls, {
                            type = "colorpicker",
                            name = GetString(MHCWL_COLOR_SLOT_COLOR) .. " " .. tostring(index),
                            getFunc = function()
                                local color = MHCWL.GetLoadoutColorSlotColor(index)
                                return unpack(color)
                            end,
                            setFunc = function(r, g, b, a)
                                local slot = MHCWL.GetLoadoutColorSlot(index)
                                if not slot then return end

                                slot.color = { r, g, b, a }

                                MHCWL.RefreshLoadoutColorDropdown()
                                MHCWL.RefreshWindow()
                                MHCWL.RefreshOpenInspectWindow()
                            end,
                            width = "full",
                        })

                        if slotIndex < 10 then
                            table.insert(controls, {
                                type = "divider",
                                width = "full",
                            })
                        end
                    end

                    return controls
                end)(),
                },
            },
        },
        [7] = {
            type = "submenu",
            name = GetString(MHCWL_ADVANCED_HEADER),
            -- tooltip = GetString(MHCWL_ADVANCED_HEADER_TOOLTIP),
            controls = {
                [1] = {
                    type = "dropdown",
                    name = GetString(MHCWL_SETTINGS_SILHOUETTE_MODE),
                    tooltip = GetString(MHCWL_SETTINGS_SILHOUETTE_MODE_TOOLTIP),
                    choices = {
                        GetString(MHCWL_SETTINGS_SILHOUETTE_MODE_AUTO),
                        GetString(MHCWL_SETTINGS_SILHOUETTE_MODE_COMPANION_ID),
                    },
                    choicesValues = {
                        MHCWL.SILHOUETTE_MODE_AUTO,
                        MHCWL.SILHOUETTE_MODE_COMPANION_ID,
                    },
                    getFunc = function()
                        return MHCWL.saved.settings.silhouetteMode
                            or MHCWL.SILHOUETTE_MODE_AUTO
                    end,
                    setFunc = function(value)
                        MHCWL.saved.settings.silhouetteMode = value
                        MHCWL.RefreshOpenInspectWindow()
                    end,
                    default = MHCWL.defaults.settings.silhouetteMode,
                    width = "full",
                },
                [2] = {
                    type = "slider",
                    name = GetString(MHCWL_SETTINGS_DEBUG_TIMINGS),
                    tooltip = GetString(MHCWL_SETTINGS_DEBUG_TIMINGS_TOOLTIP),
                    min = 0,
                    max = 250,
                    step = 10,
                    getFunc = function()
                        return MHCWL.saved.settings.debugTimingSafetyMs or 0
                    end,
                    setFunc = function(value)
                        MHCWL.saved.settings.debugTimingSafetyMs = value
                        MHCWL.Debug("Timing safety buffer: " .. tostring(value) .. "ms")
                    end,
                    default = MHCWL.defaults.settings.debugTimingSafetyMs,
                    width = "full",
                },
            },
        },
        [8] = {
            type = "submenu",
            name = GetString(MHCWL_DEBUG_HEADER),
            -- tooltip = GetString(MHCWL_DEBUG_HEADER_TOOLTIP,
            controls = {
                [1] = {
                    type = "checkbox",
                    name = GetString(MHCWL_SETTINGS_DEBUG_MODE),
                    tooltip = GetString(MHCWL_SETTINGS_DEBUG_MODE_TOOLTIP),
                    getFunc = function()
                        return MHCWL.saved.settings.debug
                    end,
                    setFunc = function(value)
                        MHCWL.saved.settings.debug = value

                        if value then
                            MHCWL.Debug("Debug enabled.")
                        end
                    end,
                    default = MHCWL.defaults.settings.debug,
                    width = "full",
                },
                [2] = {
                    type = "checkbox",
                    name = GetString(MHCWL_SETTINGS_DEBUG_MESSAGES),
                    tooltip = GetString(MHCWL_SETTINGS_DEBUG_MESSAGES_TOOLTIP),
                    getFunc = function()
                        return MHCWL.saved.settings.debugMessages
                    end,
                    setFunc = function(value)
                        MHCWL.saved.settings.debugMessages = value
                    end,
                    disabled = function()
                        return not MHCWL.saved.settings.debug
                    end,
                    default = MHCWL.defaults.settings.debugMessages,
                    width = "full",
                },
                [3] = {
                    type = "checkbox",
                    name = GetString(MHCWL_SETTINGS_DEBUG_FORCE_LOCKED),
                    tooltip = GetString(MHCWL_SETTINGS_DEBUG_FORCE_LOCKED_TOOLTIP),
                    getFunc = function()
                        return MHCWL.saved.settings.debug and MHCWL.saved.settings.debugForceLockedSkills
                    end,
                    setFunc = function(value)
                        MHCWL.saved.settings.debugForceLockedSkills = value
                        MHCWL.Debug("Force locked skills: " .. tostring(value))
                    end,
                    disabled = function()
                        return not MHCWL.saved.settings.debug
                    end,
                    default = MHCWL.defaults.settings.debugForceLockedSkills,
                    width = "full",
                },
                [4] = {
                    type = "checkbox",
                    name = GetString(MHCWL_SETTINGS_DEBUG_SLOT7_ULTIMATE),
                    tooltip = GetString(MHCWL_SETTINGS_DEBUG_SLOT7_ULTIMATE_TOOLTIP),
                    getFunc = function()
                        return MHCWL.saved.settings.debug
                            and MHCWL.saved.settings.debugShowSlot7InUltimate
                    end,
                    setFunc = function(value)
                        MHCWL.saved.settings.debugShowSlot7InUltimate = value
                        MHCWL.Debug("Show slot 7 in ultimate: " .. tostring(value))
                        MHCWL.RefreshOpenInspectWindow()
                    end,
                    disabled = function()
                        return not MHCWL.saved.settings.debug
                    end,
                    default = MHCWL.defaults.settings.debugShowSlot7InUltimate,
                    width = "full",
                }
            }
        }
    }

    LAM:RegisterOptionControls("MHCWL_SettingsPanel", optionsTable)
    wasMenuCreated = true
end