local GH = GroupHistory

function GH.CreateSettingsWindow()
    -- RETURN IF LAM IS NOT INSTALLED
    local LAM2 = LibAddonMenu2
    if not LAM2 then return end

    local panelName = "Group History"
    if GetUnitDisplayName("player") == GH.AUTHOR then panelName = "[Dev] " .. panelName end

    local panelData = {
        type = "panel",
        name = panelName,
        displayName = "|cFF7F00[GH] Group|r |cFFFFFFHistory|r",
        author = "|cFF7F00" .. GH.AUTHOR .. "|r |cFFFFFF[EU]|r",
        version = "|cFF7F00" .. GH.VERSION .. "|r",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "checkbox",
            name = "MASTERSWITCH (Turns the entire addon ON/OFF)",
            tooltip = "Enables or disables all features of the addon. If disabled, no group history will be tracked or reported.",
            getFunc = function() return GH.SV.isEnabled end,
            setFunc = function(value)
                GH.SV.isEnabled = value
                if value == true then
                    GH.Enable()
                else
                    GH.Disable()
                end
            end,
            width = "full",
            default = GH.Default.isEnabled,
        },
        {
            type = "description",
            text = "Type |cFF7F00" .. GH.SLASH .. "|r in chat to list all current group members.",
            width = "full"
        },
        {
            type = "submenu",
            name = "|cFF9F3FADDITIONAL INFORMATION|r",
            controls = {
                {
                    type = "checkbox",
                    name = "enable |cFF7F00[GH]|r prefix",
                    getFunc = function() return GH.SV.enablePrefix end,
                    setFunc = function(value)
                        GH.SV.enablePrefix = value
                    end,
                    disabled = function() return not GH.SV.isEnabled end,
                    default = GH.Default.enablePrefix,
                    width = "full"
                },
                {
                    type = "checkbox",
                    name = "enable |cFF7F00[21:36:12]|r timestamp",
                    getFunc = function() return GH.SV.enableTimestamp end,
                    setFunc = function(value)
                        GH.SV.enableTimestamp = value
                    end,
                    disabled = function() return not GH.SV.isEnabled end,
                    default = GH.Default.enableTimestamp,
                    width = "full"
                },
                {
                    type = "checkbox",
                    name = "enable |cFF7F00CHARACTER|r name",
                    getFunc = function() return GH.SV.enableCharacterName end,
                    setFunc = function(value)
                        GH.SV.enableCharacterName = value
                    end,
                    disabled = function() return not GH.SV.isEnabled end,
                    default = GH.Default.enableCharacterName,
                    width = "full"
                },
            },
        },
        {
            type = "submenu",
            name = "|cFF9F3FNOTIFICATIONS|r",
            color = { 1, 0.625, 0.25, 1 },
            controls = {
                {
                    type = "checkbox",
                    name = "enable |cFF7F00ROLE|r changed",
                    getFunc = function() return GH.SV.enableRoleChange end,
                    setFunc = function(value)
                        GH.SV.enableRoleChange = value
                        if value == true then
                            EVENT_MANAGER:RegisterForEvent(GH.NAME.."EVENT_GROUP_MEMBER_ROLE_CHANGED", EVENT_GROUP_MEMBER_ROLE_CHANGED, GH.OnGroupMemberRoleChanged)
                        else
                            EVENT_MANAGER:UnregisterForEvent(GH.NAME.."EVENT_GROUP_MEMBER_ROLE_CHANGED", EVENT_GROUP_MEMBER_ROLE_CHANGED)
                        end
                    end,
                    disabled = function() return not GH.SV.isEnabled end,
                    default = GH.Default.enableRoleChange,
                    width = "full"
                },
                {
                    type = "checkbox",
                    name = "enable |cFF7F00DIFFICULTY|r changed",
                    getFunc = function() return GH.SV.enableDifficultyChange end,
                    setFunc = function(value)
                        GH.SV.enableDifficultyChange = value
                        if value == true then
                            EVENT_MANAGER:RegisterForEvent(GH.NAME.."EVENT_VETERAN_DIFFICULTY_CHANGED", EVENT_VETERAN_DIFFICULTY_CHANGED, GH.OnDifficultyChanged)
                            EVENT_MANAGER:RegisterForEvent(GH.NAME.."EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED", EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED, GH.OnGroupDifficultyChanged)
                        else
                            EVENT_MANAGER:UnregisterForEvent(GH.NAME.."EVENT_VETERAN_DIFFICULTY_CHANGED", EVENT_VETERAN_DIFFICULTY_CHANGED)
                            EVENT_MANAGER:UnregisterForEvent(GH.NAME.."EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED", EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED)
                        end
                    end,
                    disabled = function() return not GH.SV.isEnabled end,
                    default = GH.Default.enableDifficultyChange,
                    width = "full"
                },
                {
                    type = "checkbox",
                    name = "enable |cFF7F00GROUP LEADER|r changed",
                    getFunc = function() return GH.SV.enableLeaderChange end,
                    setFunc = function(value)
                        GH.SV.enableLeaderChange = value
                        if value == true then
                            EVENT_MANAGER:RegisterForEvent(GH.NAME.."EVENT_LEADER_UPDATE", EVENT_LEADER_UPDATE, GH.OnGroupLeaderChanged)
                        else
                            EVENT_MANAGER:UnregisterForEvent(GH.NAME.."EVENT_LEADER_UPDATE", EVENT_LEADER_UPDATE)
                        end
                    end,
                    disabled = function() return not GH.SV.isEnabled end,
                    default = GH.Default.enableLeaderChange,
                    width = "full"
                },
                {
                    type = "checkbox",
                    name = "enable |cFF7F00OFFLINE|r notification",
                    getFunc = function() return GH.SV.enableOffline end,
                    setFunc = function(value)
                        GH.SV.enableOffline = value
                    end,
                    disabled = function() return not GH.SV.isEnabled end,
                    default = GH.Default.enableOffline,
                    width = "full"
                },
            },
        },
        {
            type = "submenu",
            name = "|cFF9F3FCOLORS & SOUND|r",
            controls = {
                {
                    type = "checkbox",
                    name = "Play Sound: when |cFF7F00GROUP 4/4|r",
                    getFunc = function() return GH.SV.enablePlaySound4 end,
                    setFunc = function(value)
                        GH.SV.enablePlaySound4 = value
                        if value then
                            PlaySound(SOUNDS.LEVEL_UP)
                        end
                    end,
                    disabled = function() return not GH.SV.isEnabled end,
                    default = GH.Default.enablePlaySound4,
                    width = "full"
                },
                {
                    type = "checkbox",
                    name = "Play Sound: when |cFF7F00GROUP 12/12|r",
                    getFunc = function() return GH.SV.enablePlaySound12 end,
                    setFunc = function(value)
                        GH.SV.enablePlaySound12 = value
                        if value then
                            PlaySound(SOUNDS.LEVEL_UP)
                        end
                    end,
                    disabled = function() return not GH.SV.isEnabled end,
                    default = GH.Default.enablePlaySound12,
                    width = "full"
                },
                {
                    type = "colorpicker",
                    name = "Color for Role: [Tank]",
                    tooltip = "Default (rgba): 255, 127, 255, 255",
                    getFunc = function()
                        local colorString = GH.SV.RoleCol[2] or "|cFF7FFF"
                        local r_hex, g_hex, b_hex = string.match(colorString, "|c(%x%x)(%x%x)(%x%x)")
                        local r = tonumber(r_hex, 16) / 255
                        local g = tonumber(g_hex, 16) / 255
                        local b = tonumber(b_hex, 16) / 255
                        return r, g, b, 1
                    end,
                    setFunc = function(r, g, b, a)
                        GH.SV.RoleCol[2] = string.format("|c%02x%02x%02x", r * 255, g * 255, b * 255)
                    end,
                    width = "full"
                },
                {
                    type = "colorpicker",
                    name = "Color for Role: [Heal]",
                    tooltip = "Default (rgba): 127, 255, 127, 255",
                    getFunc = function()
                        local colorString = GH.SV.RoleCol[4] or "|c7FFF7F"
                        local r_hex, g_hex, b_hex = string.match(colorString, "|c(%x%x)(%x%x)(%x%x)")
                        local r = tonumber(r_hex, 16) / 255
                        local g = tonumber(g_hex, 16) / 255
                        local b = tonumber(b_hex, 16) / 255
                        return r, g, b, 1
                    end,
                    setFunc = function(r, g, b, a)
                        GH.SV.RoleCol[4] = string.format("|c%02x%02x%02x", r * 255, g * 255, b * 255)
                    end,
                    width = "full"
                },
                {
                    type = "colorpicker",
                    name = "Color for Role: [DPS]",
                    tooltip = "Default (rgba): 0, 127, 255, 255",
                    getFunc = function()
                        local colorString = GH.SV.RoleCol[1] or "|c007FFF"
                        local r_hex, g_hex, b_hex = string.match(colorString, "|c(%x%x)(%x%x)(%x%x)")
                        local r = tonumber(r_hex, 16) / 255
                        local g = tonumber(g_hex, 16) / 255
                        local b = tonumber(b_hex, 16) / 255
                        return r, g, b, 1
                    end,
                    setFunc = function(r, g, b, a)
                        GH.SV.RoleCol[1] = string.format("|c%02x%02x%02x", r * 255, g * 255, b * 255)
                    end,
                    width = "full"
                },
                {
                    type = "colorpicker",
                    name = "Color for Role: [Offline]",
                    tooltip = "Default (rgba): 255, 0, 0, 255",
                    getFunc = function()
                        local colorString = GH.SV.RoleCol[0] or "|cFF0000"
                        local r_hex, g_hex, b_hex = string.match(colorString, "|c(%x%x)(%x%x)(%x%x)")
                        local r = tonumber(r_hex, 16) / 255
                        local g = tonumber(g_hex, 16) / 255
                        local b = tonumber(b_hex, 16) / 255
                        return r, g, b, 1
                    end,
                    setFunc = function(r, g, b, a)
                        GH.SV.RoleCol[0] = string.format("|c%02x%02x%02x", r * 255, g * 255, b * 255)
                    end,
                    width = "full"
                },
            },
        },
        {
            type = "divider"
        },
        {
            type = "description",
            text = "If you enjoy |cFF7F00Group History|r, consider sharing your feedback or supporting its development. Your input and contributions are greatly appreciated.",
            width = "full"
        },
        {
            type = "button",
            name = "Feedback / Donate",
            tooltip = "Opens a mail to send feedback or donate to the author. <3",
            func = function()
                SCENE_MANAGER:Show('mailSend')
                zo_callLater(function()
                    ZO_MailSendToField:SetText(GH.AUTHOR)
                    ZO_MailSendSubjectField:SetText("Group History")
                    ZO_MailSendBodyField:TakeFocus()
                end, 250)
            end,
            width = "full"
        }
    }
    GH.varAddonPanel = LAM2:RegisterAddonPanel(GroupHistory.NAME .. "Menu", panelData)
    LAM2:RegisterOptionControls(GroupHistory.NAME .. "Menu", optionsData)
end