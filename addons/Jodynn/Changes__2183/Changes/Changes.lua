Changes = {}

local Changes = Changes

Changes.name = "Changes"
Changes.version = 2.11
Changes.displayName = "|cff00ffChanges|r"

Changes.Defaults = {}
Changes.Defaults.hideZoneStory = false
Changes.Defaults.removeGloss  = false
Changes.Defaults.removeFrames = false
Changes.Defaults.removeArmorBuff  = false
Changes.Defaults.removePowerBuff  = false
Changes.Defaults.neverRemoveCompass = false
Changes.Defaults.neverRemoveCompassAlpha = 50
Changes.Defaults.removeCompassBG = false
Changes.Defaults.showPortCost = false

Changes.Defaults.hideTopBar = false
Changes.Defaults.hideBottomBar = false
Changes.Defaults.hideMeterBackground = false
Changes.Defaults.hideChatBackground = false
Changes.Defaults.hideChatDivider = false
Changes.Defaults.hideMinChatBackground = false
Changes.Defaults.hideNotificationIcon = false
Changes.Defaults.hideWeaponSwapIcon = false
Changes.Defaults.hideKeybindBackground = false
Changes.Defaults.hideKeybindText = false
Changes.Defaults.hideEmptyBackground = false
Changes.Defaults.hideButtonOne = false
Changes.Defaults.hideButtonTwo = false
Changes.Defaults.hideButtonThree = false
Changes.Defaults.hideButtonFour = false
Changes.Defaults.hideButtonFive = false
Changes.Defaults.hideUltimate = false
Changes.Defaults.hideQuickbar = false
Changes.Defaults.hideActionBorders = false

Changes.Defaults.keepChatWindowHidden = false
Changes.Defaults.alwaysMinimizeChatOnLoad = false
Changes.Defaults.hideOnFocusLost = false
Changes.Defaults.hideOnFocusWait = 10

Changes.Defaults.customCommand = {
    '/script d ( " you need to enter something homie")',
    '/script d ( " you need to enter something homie")',
    '/script d ( " you need to enter something homie")',
    '/script d ( " you need to enter something homie")',
    '/script d ( " you need to enter something homie")',
    '/script d ( " you need to enter something homie")',
    '/script d ( " you need to enter something homie")',
    '/script d ( " you need to enter something homie")',
    '/script d ( " you need to enter something homie")',
}

Changes.Maximize = CHAT_SYSTEM.Maximize
Changes.Minimize = CHAT_SYSTEM.Minimize
Changes.LOOPS = 10
Changes.Defaults.isMinimized = false
Changes.REFIRE = "CHANGES_CHAT_REFIRE"

-- ZO_GuildRosterManager:New():RefreshData()

function Changes:findThis(text)
    local parents = {};
    parents[1] = GuiRoot
    local newparents = {};
    local loops = 0;
    while loops < Changes.LOOPS do
        newparents = nil
        newparents = {}
        parentcount = 1
        loops = loops + 1;

        for _, x in ipairs(parents) do
            if x.GetChild then
                for i=1, x:GetNumChildren() do
                    local y = x:GetChild(i)
                    if y then
                        -- d ( x:GetName() )
                        if y.GetChild then
                            newparents[parentcount] = y;
                            parentcount = parentcount + 1
                        end

                        if y.GetText and y:GetText():match(text) then
                            d ( y:GetName() )
                            local z = y
                            while z ~= nil do
                                z:SetAlpha(1)
                                z:SetHidden(false)
                                z = z:GetParent()
                            end
                        end
                    end
                end
            end
        end

        parents = nil
        parents = {}

        for i,x in ipairs(newparents) do
            parents[i] = x
        end
    end
end

local function hidetop()
    if Changes.sv.hideTopBar then
        ZO_TopBarBackground:SetAlpha(0)
    else
        ZO_TopBarBackground:SetAlpha(1)
    end
end

local function hidebot()
    if Changes.sv.hideBottomBar then
        RedirectTexture("esoui/art/miscellaneous/bottom_bar.dds", "HideThings\media\hide_blank.dds")
    else
        RedirectTexture("esoui/art/miscellaneous/bottom_bar.dds", "esoui/art/miscellaneous/bottom_bar.dds")
    end
end

local function hidemet()
    if Changes.sv.hideMeterBackground then
        ZO_PerformanceMetersBg:SetAlpha(0)
    else
        ZO_PerformanceMetersBg:SetAlpha(1)
    end
end

local function chatwindow()
    if Changes.sv.keepChatWindowHidden then
        local handler = ZO_ChatWindowMinimize:GetHandler("OnClicked")
        if not CHAT_SYSTEM.isMinimized and Changes.sv.isMinimized then
            handler();
        end
    end
end

local function hidecht()
    if Changes.sv.hideChatBackground then
        ZO_ChatWindowBg:SetAlpha(0)
    else
        ZO_ChatWindowBg:SetAlpha(1)
    end
end

local function hidechtdiv()
    if Changes.sv.hideChatDivider then
        ZO_ChatWindowDivider:SetAlpha(0)
    else
        ZO_ChatWindowDivider:SetAlpha(1)
    end
end


local function hidechtmin()
    if Changes.sv.hideMinChatBackground then
        ZO_ChatWindowMinBar:SetAlpha(0)
    else
        ZO_ChatWindowMinBar:SetAlpha(1)
    end
end

local function hidechtnot()
    if Changes.sv.hideNotificationIcon then
        ZO_ChatWindowNotifications:SetAlpha(0)
    else
        ZO_ChatWindowNotifications:SetAlpha(1)
    end
end

local function hideswp()
    if Changes.sv.hideWeaponSwapIcon then
        ZO_ActionBar1WeaponSwap:SetAlpha(0)
        ZO_ActionBar1WeaponSwapLock:SetAlpha(0)
    else
        ZO_ActionBar1WeaponSwap:SetAlpha(1)
        ZO_ActionBar1WeaponSwapLock:SetAlpha(1)
    end
end

local function hidekybd()
    if Changes.sv.hideKeybindBackground then
        ZO_ActionBar1KeybindBG:SetAlpha(0)
    else
        ZO_ActionBar1KeybindBG:SetAlpha(1)
    end
end

local function hidetxt()
    ActionButton8LeftKeybind:SetHandler("OnShow",function()
        ActionButton8LeftKeybind:SetHidden(Changes.sv.hideKeybindText)
    end)
    ActionButton8RightKeybind:SetHandler("OnShow",function()
        ActionButton8RightKeybind:SetHidden(Changes.sv.hideKeybindText)
    end)

    if Changes.sv.hideKeybindText then
        ActionButton3ButtonText:SetHidden(true)
        ActionButton4ButtonText:SetHidden(true)
        ActionButton5ButtonText:SetHidden(true)
        ActionButton6ButtonText:SetHidden(true)
        ActionButton7ButtonText:SetHidden(true)
        ActionButton8ButtonText:SetHidden(true)
        ActionButton9ButtonText:SetHidden(true)

        if (IsInGamepadPreferredMode()) then
            ActionButton8RightKeybind:SetHidden(true)
            ActionButton8LeftKeybind:SetHidden(true)
        else
            ActionButton8ButtonText:SetHidden(true)
        end
    else
        ActionButton3ButtonText:SetHidden(false)
        ActionButton4ButtonText:SetHidden(false)
        ActionButton5ButtonText:SetHidden(false)
        ActionButton6ButtonText:SetHidden(false)
        ActionButton7ButtonText:SetHidden(false)
        ActionButton8ButtonText:SetHidden(false)
        ActionButton9ButtonText:SetHidden(false)

        if (IsInGamepadPreferredMode()) then
            ActionButton8RightKeybind:SetHidden(false)
            ActionButton8LeftKeybind:SetHidden(false)
        else
            ActionButton8ButtonText:SetHidden(false)
        end
    end
end

local function hidempt()
    if Changes.sv.hideEmptyBackground then
        ActionButton3BG:SetAlpha(0)
        ActionButton4BG:SetAlpha(0)
        ActionButton5BG:SetAlpha(0)
        ActionButton6BG:SetAlpha(0)
        ActionButton7BG:SetAlpha(0)
        ActionButton8BG:SetAlpha(0)
        ActionButton9BG:SetAlpha(0)
    else
        ActionButton3BG:SetAlpha(1)
        ActionButton4BG:SetAlpha(1)
        ActionButton5BG:SetAlpha(1)
        ActionButton6BG:SetAlpha(1)
        ActionButton7BG:SetAlpha(1)
        ActionButton8BG:SetAlpha(1)
        ActionButton9BG:SetAlpha(1)
    end
end

local function hidebor()
    if Changes.sv.hideActionBorders then
        ActionButton3Button:SetAlpha(0)
        ActionButton4Button:SetAlpha(0)
        ActionButton5Button:SetAlpha(0)
        ActionButton6Button:SetAlpha(0)
        ActionButton7Button:SetAlpha(0)
        ActionButton8Button:SetAlpha(0)
        ActionButton9Button:SetAlpha(0)
    else
        ActionButton3Button:SetAlpha(1)
        ActionButton4Button:SetAlpha(1)
        ActionButton5Button:SetAlpha(1)
        ActionButton6Button:SetAlpha(1)
        ActionButton7Button:SetAlpha(1)
        ActionButton8Button:SetAlpha(1)
        ActionButton9Button:SetAlpha(1)
    end
end

local function hideone()
    if Changes.sv.hideButtonOne then
        ActionButton3:SetAlpha(0)
    else
        ActionButton3:SetAlpha(1)
    end
end

local function hidetwo()
    if Changes.sv.hideButtonTwo then
        ActionButton4:SetAlpha(0)
    else
        ActionButton4:SetAlpha(1)
    end
end

local function hidetre()
    if Changes.sv.hideButtonThree then
        ActionButton5:SetAlpha(0)
    else
        ActionButton5:SetAlpha(1)
    end
end

local function hidefor()
    if Changes.sv.hideButtonFour then
        ActionButton6:SetAlpha(0)
    else
        ActionButton6:SetAlpha(1)
    end
end

local function hidefiv()
    if Changes.sv.hideButtonFive then
        ActionButton7:SetAlpha(0)
    else
        ActionButton7:SetAlpha(1)
    end
end

local function hideult()
    if Changes.sv.hideUltimate then
        ActionButton8:SetAlpha(0)
    else
        ActionButton8:SetAlpha(1)
    end
end

local function hideqck()
    if Changes.sv.hideQuickbar then
        ActionButton9:SetAlpha(0)
    else
        ActionButton9:SetAlpha(1)
    end
end

local function portCostShit()
    if not Changes.getDimensionsX then
        Changes.getDimensionsX, Changes.getDimensionsY = ZO_PerformanceMetersBg:GetDimensions()
    end

    if Changes.sv.showPortCost then
        EVENT_MANAGER:UnregisterForUpdate("CHANGES_PORT_COST_SHIT")
        EVENT_MANAGER:RegisterForUpdate("CHANGES_PORT_COST_SHIT", 1000, portCostShit)

        SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_FRAMERATE, 1)
        SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_LATENCY, 1)

        local c = GetRecallCost()

        Changes_Cost_Button:SetHidden(false)
        Changes_Cost_Button:SetParent(ZO_PerformanceMeters)
        Changes_Cost_Button.data = { tooltipText = "Cost to recall to wayshrine : |t80%:80%:/esoui/art/currency/gold_mipmap.dds|t " .. c }
        Changes_Cost_Button:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
        Changes_Cost_Button:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)

        Changes_Cost:SetText(tostring(c))

        ZO_PerformanceMetersBg:SetDimensions(Changes.getDimensionsX + Changes.getDimensionsX / 2, Changes.getDimensionsY)
    else
        EVENT_MANAGER:UnregisterForUpdate("CHANGES_PORT_COST_SHIT")
        Changes_Cost_Button:SetHidden(true)
        ZO_PerformanceMetersBg:SetDimensions(Changes.getDimensionsX, Changes.getDimensionsY)
    end

end

local function compassShit()
    if ( Changes.sv.neverRemoveCompass ) then
        EVENT_MANAGER:UnregisterForUpdate("CHANGES_COMPASS_SHIT")
        EVENT_MANAGER:RegisterForUpdate("CHANGES_COMPASS_SHIT", 1000, compassShit)

        if (ZO_BossBar:GetAlpha() == 0 or ZO_BossBar:IsHidden()) then
            ZO_Compass:SetAlpha(1)
            ZO_CompassContainer:SetAlpha(1)
        else
            ZO_Compass:SetAlpha(Changes.sv.neverRemoveCompassAlpha * 0.01)
            ZO_CompassContainer:SetAlpha(Changes.sv.neverRemoveCompassAlpha * 0.01)
        end
    else
        EVENT_MANAGER:UnregisterForUpdate("CHANGES_COMPASS_SHIT")
    end
end

local function compassFrameShit()
    local compass = Changes.sv.removeCompassBG

    ZO_CompassFrameCenter:SetHidden(compass)
    ZO_CompassFrameLeft:SetHidden(compass)
    ZO_CompassFrameRight:SetHidden(compass)
end

local function zoneStoryShit()
    local hide = Changes.sv.hideZoneStory

    if hide then
        ZO_WorldMapZoneStoryTopLevel_Keyboard:SetHidden(hide)
        ZO_WorldMapZoneStory_Keyboard:OnHiding()
        ZO_WorldMapZoneStoryTopLevel_Gamepad:SetHidden(hide)
        ZO_WorldMapZoneStory_Gamepad:OnHiding()
    end
end

local function powerShit()
    local power = Changes.sv.removePowerBuff

    if ZO_IncreasedPowerTextureArrow1 then
        ZO_IncreasedPowerTextureArrow1:SetHidden(power)
        ZO_IncreasedPowerGlowArrow1:SetHidden(power)
    end

    if ZO_IncreasedPowerTextureArrow2 then
        ZO_IncreasedPowerTextureArrow2:SetHidden(power)
        ZO_IncreasedPowerGlowArrow2:SetHidden(power)
    end
end

local function armorShit()
    local armor = Changes.sv.removeArmorBuff

    if ZO_IncreasedArmorBgContainerArrow1 then
        ZO_IncreasedArmorBgContainerArrow1:SetHidden(armor)
        ZO_IncreasedArmorFrameContainerArrow1:SetHidden(armor)
    end

    if ZO_IncreasedArmorBgContainerArrow2 then
        ZO_IncreasedArmorBgContainerArrow2:SetHidden(armor)
        ZO_IncreasedArmorFrameContainerArrow2:SetHidden(armor)
    end
end

local function frameShit()
    local frame = Changes.sv.removeFrames

    -- 'attributes'
    ZO_PlayerAttributeHealthFrameCenter:SetHidden(frame)
    ZO_PlayerAttributeHealthFrameLeft:SetHidden(frame)
    ZO_PlayerAttributeHealthFrameRight:SetHidden(frame)

    ZO_PlayerAttributeMagickaFrameCenter:SetHidden(frame)
    ZO_PlayerAttributeMagickaFrameLeft:SetHidden(frame)
    ZO_PlayerAttributeMagickaFrameRight:SetHidden(frame)

    ZO_PlayerAttributeStaminaFrameCenter:SetHidden(frame)
    ZO_PlayerAttributeStaminaFrameLeft:SetHidden(frame)
    ZO_PlayerAttributeStaminaFrameRight:SetHidden(frame)

    -- '"special" attributes'
    ZO_PlayerAttributeWerewolfFrame:SetHidden(frame)
    ZO_PlayerAttributeMountStaminaFrame:SetHidden(frame)
    ZO_PlayerAttributeSiegeHealthFrame:SetHidden(frame)

    -- 'boss bar has No Frame'

    -- 'target bar'
    ZO_TargetUnitFramereticleoverFrameCenter:SetHidden(frame)
    ZO_TargetUnitFramereticleoverFrameLeft:SetHidden(frame)
    ZO_TargetUnitFramereticleoverFrameRight:SetHidden(frame)

end

local function glossyShit()
    local gloss = Changes.sv.removeGloss

    -- 'attributes'
    ZO_PlayerAttributeMagickaBarGloss:SetHidden(gloss)
    ZO_PlayerAttributeStaminaBarGloss:SetHidden(gloss)
    ZO_PlayerAttributeHealthBarLeftGloss:SetHidden(gloss)
    ZO_PlayerAttributeHealthBarRightGloss:SetHidden(gloss)

    -- '"special" attributes'
    ZO_PlayerAttributeMountStaminaBarGloss:SetHidden(gloss)
    ZO_PlayerAttributeWerewolfBarGloss:SetHidden(gloss)
    ZO_PlayerAttributeSiegeHealthBarLeftGloss:SetHidden(gloss)
    ZO_PlayerAttributeSiegeHealthBarRightGloss:SetHidden(gloss)

    -- 'boss bar'
    ZO_BossBarHealthBarLeftGloss:SetHidden(gloss)
    ZO_BossBarHealthBarRightGloss:SetHidden(gloss)

    -- 'target bar'
    ZO_TargetUnitFramereticleoverBarRightGloss:SetHidden(gloss)
    ZO_TargetUnitFramereticleoverBarLeftGloss:SetHidden(gloss)

end

local function createSettings()
    local LAM = LibAddonMenu2

    local settingsWindowData = {
        type = "panel",
        name = Changes.displayName,
        author = "|caaffeFJodynn|r",
        version = tostring(Changes.version),
        slashCommand = "/changessettings"
    }

    local settingsOptionsData = {
        {
            type = "checkbox",
            name = "Hide Zone Story Thing",
            tooltip = "Hide the panel with the zone thing when you so the map because it's a lil in the way albeit cool.",
            default = Changes.Defaults.hideZoneStory,
            getFunc = function() return Changes.sv.hideZoneStory end,
            setFunc = function(newValue)
                Changes.sv.hideZoneStory = newValue
            end,
        },

        {
            type = "checkbox",
            name = "Show Wayshrine Cost",
            tooltip = "Shows the recall to wayshrine cost next to latency",
            default = Changes.Defaults.showPortCost,
            getFunc = function() return Changes.sv.showPortCost end,
            setFunc = function(newValue)
                Changes.sv.showPortCost = newValue
                portCostShit()
            end,
        },

        {
            type = "checkbox",
            name = "Gloss Free Attributes",
            tooltip = "Remove the glossy thing from the attribute bars.",
            default = Changes.Defaults.removeGloss,
            getFunc = function() return Changes.sv.removeGloss end,
            setFunc = function(newValue)
                Changes.sv.removeGloss = newValue
                glossyShit()
            end,
        },

        {
            type = "checkbox",
            name = "Frame Free Attributes",
            tooltip = "Remove the frames from the attribute bars.",
            default = Changes.Defaults.removeFrames,
            getFunc = function() return Changes.sv.removeFrames end,
            setFunc = function(newValue)
                Changes.sv.removeFrames = newValue
                frameShit()
            end,
        },

        {
            type = "checkbox",
            name = "Power Free Healthbar",
            tooltip = "Remove power animation from health bar",
            default = Changes.Defaults.removePowerBuff,
            getFunc = function() return Changes.sv.removePowerBuff end,
            setFunc = function(newValue)
                Changes.sv.removePowerBuff = newValue
                powerShit()
            end,
        },

        {
            type = "checkbox",
            name = "Armor Free Healthbar",
            tooltip = "Remove armor animation from health bar",
            default = Changes.Defaults.removeArmorBuff,
            getFunc = function() return Changes.sv.removeArmorBuff end,
            setFunc = function(newValue)
                Changes.sv.removeArmorBuff = newValue
                armorShit()
            end,
        },

        {
            type = "checkbox",
            name = "Never hide compass",
            tooltip = "Never hide the compass SWNE and other pins, during events it would hide, i.e. boss bar",
            default = Changes.Defaults.neverRemoveCompass,
            getFunc = function() return Changes.sv.neverRemoveCompass end,
            setFunc = function(newValue)
                Changes.sv.neverRemoveCompass = newValue
                compassShit()
            end,
        },

        {
            type = "slider",
            name = "Never hide compass alpha",
            tooltip = "Compass alpha when 'never-hiding', i.e. boss bar active, if boss bar isn't active set alpha to normal ( 1 ) ",
            min = 0,
            max = 100,
            step = 1,
            default = Changes.Defaults.neverRemoveCompassAlpha,
            getFunc = function() return Changes.sv.neverRemoveCompassAlpha end,
            setFunc = function(newValue)
                Changes.sv.neverRemoveCompassAlpha = newValue
                compassShit()
            end,
        },

        {
            type = "checkbox",
            name = "No Compass BG Attributes",
            tooltip = "Remove the BG ( Blackish transparent thing and frame) from the compass",
            default = Changes.Defaults.removeCompassBG,
            getFunc = function() return Changes.sv.removeCompassBG end,
            setFunc = function(newValue)
                Changes.sv.removeCompassBG = newValue
                compassFrameShit()
            end,
        },

        {
            type = "editbox",
            name = "Custom Command 1",
            tooltip = "Run a custom command, you can set a keybind to execute it for example /script d ( 'print this message' ) will print that message out",
            default = Changes.Defaults.customCommand[1],
            getFunc = function() return Changes.sv.customCommand[1] end,
            setFunc = function(newValue)
                Changes.sv.customCommand[1] = newValue
            end,
        },
        {
            type = "editbox",
            name = "Custom Command 2",
            tooltip = "Run a custom command, you can set a keybind to execute it for example /script d ( 'print this message' ) will print that message out",
            default = Changes.Defaults.customCommand[2],
            getFunc = function() return Changes.sv.customCommand[2] end,
            setFunc = function(newValue)
                Changes.sv.customCommand[2] = newValue
            end,
        },
        {
            type = "editbox",
            name = "Custom Command 3",
            tooltip = "Run a custom command, you can set a keybind to execute it for example /script d ( 'print this message' ) will print that message out",
            default = Changes.Defaults.customCommand[3],
            getFunc = function() return Changes.sv.customCommand[3] end,
            setFunc = function(newValue)
                Changes.sv.customCommand[3] = newValue
            end,
        },
        {
            type = "editbox",
            name = "Custom Command 4",
            tooltip = "Run a custom command, you can set a keybind to execute it for example /script d ( 'print this message' ) will print that message out",
            default = Changes.Defaults.customCommand[4],
            getFunc = function() return Changes.sv.customCommand[4] end,
            setFunc = function(newValue)
                Changes.sv.customCommand[4] = newValue
            end,
        },
        {
            type = "editbox",
            name = "Custom Command 5",
            tooltip = "Run a custom command, you can set a keybind to execute it for example /script d ( 'print this message' ) will print that message out",
            default = Changes.Defaults.customCommand[5],
            getFunc = function() return Changes.sv.customCommand[5] end,
            setFunc = function(newValue)
                Changes.sv.customCommand[5] = newValue
            end,
        },
        {
            type = "editbox",
            name = "Custom Command 6",
            tooltip = "Run a custom command, you can set a keybind to execute it for example /script d ( 'print this message' ) will print that message out",
            default = Changes.Defaults.customCommand[6],
            getFunc = function() return Changes.sv.customCommand[6] end,
            setFunc = function(newValue)
                Changes.sv.customCommand[6] = newValue
            end,
        },
        {
            type = "editbox",
            name = "Custom Command 7",
            tooltip = "Run a custom command, you can set a keybind to execute it for example /script d ( 'print this message' ) will print that message out",
            default = Changes.Defaults.customCommand[7],
            getFunc = function() return Changes.sv.customCommand[7] end,
            setFunc = function(newValue)
                Changes.sv.customCommand[7] = newValue
            end,
        },
        {
            type = "editbox",
            name = "Custom Command 8",
            tooltip = "Run a custom command, you can set a keybind to execute it for example /script d ( 'print this message' ) will print that message out",
            default = Changes.Defaults.customCommand[8],
            getFunc = function() return Changes.sv.customCommand[8] end,
            setFunc = function(newValue)
                Changes.sv.customCommand[8] = newValue
            end,
        },
        {
            type = "editbox",
            name = "Custom Command 9",
            tooltip = "Run a custom command, you can set a keybind to execute it for example /script d ( 'print this message' ) will print that message out",
            default = Changes.Defaults.customCommand[9],
            getFunc = function() return Changes.sv.customCommand[9] end,
            setFunc = function(newValue)
                Changes.sv.customCommand[9] = newValue
            end,
        },
        {
            type = "header",
            name = "Miscellaneous Options",
        },
        {
            type = 'checkbox',
            name = 'Hide Top Bar',
            tooltip = 'Hides the bar that appears at the top of the screen when you open a menu. \n\nTurning this option OFF requires reloading the UI.',
            getFunc = function() return Changes.sv.hideTopBar end,
            setFunc = function(value) Changes.sv.hideTopBar = value; hidetop() end,
            default = Changes.Defaults.hideTopBar,
        },
        {
            type = 'checkbox',
            name = 'Hide Bottom Bar',
            tooltip = 'Hides the bar that appears at the bottom of the screen when you open a menu. \n\nTurning this option OFF requires reloading the UI.',
            getFunc = function() return Changes.sv.hideBottomBar end,
            setFunc = function(value) Changes.sv.hideBottomBar = value; hidebot() end,
            default = Changes.Defaults.hideBottomBar,
        },
        {
            type = 'checkbox',
            name = 'Hide Performance Meter Background',
            tooltip = 'Hides the background behind the FPS and Latency meters. \n\nTurning this option OFF requires reloading the UI.',
            getFunc = function() return Changes.sv.hideMeterBackground end,
            setFunc = function(value) Changes.sv.hideMeterBackground = value; hidemet() end,
            default = Changes.Defaults.hideMeterBackground,
        },
        {
            type = "header",
            name = "Chat Options",
        },
        {
            type = 'checkbox',
            name = 'Keep chat minimized on reload.',
            tooltip = 'Keeps the chat window minimized on reload.',
            getFunc = function() return Changes.sv.keepChatWindowHidden end,
            setFunc = function(value) Changes.sv.keepChatWindowHidden = value end,
            default = Changes.Defaults.keepChatWindowHidden,
        },
        {
            type = 'checkbox',
            name = 'Always start chat window minimized',
            tooltip = 'Keeps the chat window minimized on reload regardless.',
            getFunc = function() return Changes.sv.alwaysMinimizeChatOnLoad end,
            setFunc = function(value) Changes.sv.alwaysMinimizeChatOnLoad = value end,
            default = Changes.Defaults.alwaysMinimizeChatOnLoad,
        },
        {
            type = 'checkbox',
            name = 'Keep chat minimized after chat loses focus.',
            tooltip = 'Keeps the chat window minimized after you type whatever text you want.',
            getFunc = function() return Changes.sv.hideOnFocusLost end,
            setFunc = function(value) Changes.sv.hideOnFocusLost = value end,
            default = Changes.Defaults.hideOnFocusLost,
        },
        {
            type = 'slider',
            name = 'Wait (s) until we hide after lose focus',
            min = 0,
            max = 20,
            getFunc = function() return Changes.sv.hideOnFocusWait end,
            setFunc = function(value) Changes.sv.hideOnFocusWait = value end,
            default = Changes.Defaults.hideOnFocusWait,
        },
        {
            type = 'checkbox',
            name = 'Hide Chat Background',
            tooltip = 'Hides the background of the chat box.',
            getFunc = function() return Changes.sv.hideChatBackground end,
            setFunc = function(value) Changes.sv.hideChatBackground = value; hidecht() end,
            default = Changes.Defaults.hideChatBackground,
        },
        {
            type = 'checkbox',
            name = 'Hide Chat Divider Bar',
            tooltip = 'Hides the thin divider bar at the top of chat.',
            getFunc = function() return Changes.sv.hideChatDivider end,
            setFunc = function(value) Changes.sv.hideChatDivider = value; hidechtdiv() end,
            default = Changes.Defaults.hideChatDivider,
        },
        {
            type = 'checkbox',
            name = 'Hide Minimized Chat Bar ',
            tooltip = 'This completely hides the minimized chat bar. If you select this option you will have to press enter or click on an invisible button to open chat!',
            getFunc = function() return Changes.sv.hideMinChatBackground end,
            setFunc = function(value) Changes.sv.hideMinChatBackground = value; hidechtmin() end,
            default = Changes.Defaults.hideMinChatBackground,
        },
        {
            type = 'checkbox',
            name = 'Hide Chat Notification Icon ',
            tooltip = 'This hides the chat notification ICON only.\n\nThe number text will still appear when you have an unread notification.',
            getFunc = function() return Changes.sv.hideNotificationIcon end,
            setFunc = function(value) Changes.sv.hideNotificationIcon = value; hidechtnot(); end,
            default = Changes.Defaults.hideNotificationIcon,
        },
        {
            type = "header",
            name = "Action Bar Options",
        },
        {
            type = 'checkbox',
            name = 'Hide Weapon Swap Icon ',
            tooltip = 'Hides the weapon swap icon between the quickbar button and action bar button 1.',
            getFunc = function() return Changes.sv.hideWeaponSwapIcon end,
            setFunc = function(value) Changes.sv.hideWeaponSwapIcon = value; hideswp() end,
            default = Changes.Defaults.hideWeaponSwapIcon,
        },
        {
            type = 'checkbox',
            name = 'Hide Keybind Background ',
            tooltip = 'Hides the black background underneath the keybind text below the action bar.',
            getFunc = function() return Changes.sv.hideKeybindBackground end,
            setFunc = function(value) Changes.sv.hideKeybindBackground = value; hidekybd() end,
            default = Changes.Defaults.hideKeybindBackground,
        },
        {
            type = 'checkbox',
            name = 'Hide Keybind Text ',
            tooltip = 'Hides the keybind text below the action bar.',
            getFunc = function() return Changes.sv.hideKeybindText end,
            setFunc = function(value) Changes.sv.hideKeybindText = value; hidetxt(); end,
            default = Changes.Defaults.hideKeybindText,
        },
        {
            type = 'checkbox',
            name = 'Hide Action Bar Icon Borders ',
            tooltip = 'Hides the borders around ability icons.',
            getFunc = function() return Changes.sv.hideActionBorders end,
            setFunc = function(value) Changes.sv.hideActionBorders = value; hidebor() end,
            default = Changes.Defaults.hideActionBorders,
        },
        {
            type = 'checkbox',
            name = 'Hide Empty Button Background ',
            tooltip = 'Hides the transparent background that appears in empty action bar buttons.',
            getFunc = function() return Changes.sv.hideEmptyBackground end,
            setFunc = function(value) Changes.sv.hideEmptyBackground = value; hidempt() end,
            default = Changes.Defaults.hideEmptyBackground,
        },
        {
            type = "header",
            name = "Individual Action Bar Button Options",
        },
        {
            type = 'checkbox',
            name = 'Hide Button 1 ',
            tooltip = 'Warning: This completely hides the button. Always. Even in combat!',
            getFunc = function() return Changes.sv.hideButtonOne end,
            setFunc = function(value) Changes.sv.hideButtonOne = value; hideone() end,
            default = Changes.Defaults.hideButtonOne,
        },
        {
            type = 'checkbox',
            name = 'Hide Button 2 ',
            tooltip = 'Warning: This completely hides the button. Always. Even in combat!',
            getFunc = function() return Changes.sv.hideButtonTwo end,
            setFunc = function(value) Changes.sv.hideButtonTwo = value; hidetwo() end,
            default = Changes.Defaults.hideButtonTwo,
        },
        {
            type = 'checkbox',
            name = 'Hide Button 3 ',
            tooltip = 'Warning: This completely hides the button. Always. Even in combat!',
            getFunc = function() return Changes.sv.hideButtonThree end,
            setFunc = function(value) Changes.sv.hideButtonThree = value; hidetre() end,
            default = Changes.Defaults.hideButtonThree,
        },
        {
            type = 'checkbox',
            name = 'Hide Button 4 ',
            tooltip = 'Warning: This completely hides the button. Always. Even in combat!',
            getFunc = function() return Changes.sv.hideButtonFour end,
            setFunc = function(value) Changes.sv.hideButtonFour = value; hidefor() end,
            default = Changes.Defaults.hideButtonFour,
        },
        {
            type = 'checkbox',
            name = 'Hide Button 5 ',
            tooltip = 'Warning: This completely hides the button. Always. Even in combat!',
            getFunc = function() return Changes.sv.hideButtonFive end,
            setFunc = function(value) Changes.sv.hideButtonFive = value; hidefiv() end,
            default = Changes.Defaults.hideButtonFive,
        },
        {
            type = 'checkbox',
            name = 'Hide Ultimate Button ',
            tooltip = 'Warning: This completely hides the button. Always. Even in combat!',
            getFunc = function() return Changes.sv.hideUltimate end,
            setFunc = function(value) Changes.sv.hideUltimate = value; hideult() end,
            default = Changes.Defaults.hideUltimate,
        },
        {
            type = 'checkbox',
            name = 'Hide Quickbar Button ',
            tooltip = 'Warning: This completely hides the button. Always. Even in combat!',
            getFunc = function() return Changes.sv.hideQuickbar end,
            setFunc = function(value) Changes.sv.hideQuickbar = value; hideqck() end,
            default = Changes.Defaults.hideQuickbar,
        },
        {
            type = "button",
            name = "Reload UI",
            tooltip = "",
            width = "full",
            func = function()
                ReloadUI("ingame")
            end,
        },
    }

    local settingsOptionPanel = LAM:RegisterAddonPanel(Changes.name.."_LAM", settingsWindowData)
    LAM:RegisterOptionControls(Changes.name.."_LAM", settingsOptionsData)
end

Changes.BANKER   = 267
Changes.FENCE    = 300
Changes.MERCHANT = 301
Changes.CAT_BANKER   = 6376
Changes.CAT_MERCHANT = 6378
Changes.MIRRI     = 9353
Changes.BASTIAN   = 9245

function ChangesMirri()
    UseCollectible(Changes.MIRRI)
end

function ChangesBastian()
    UseCollectible(Changes.BASTIAN)
end

function ChangesBanker()
    UseCollectible(Changes.BANKER)
end

function ChangesBankerCat()
    UseCollectible(Changes.CAT_BANKER)
end

function ChangesMerchant()
    UseCollectible(Changes.MERCHANT)
end

function ChangesMerchantCat()
    UseCollectible(Changes.CAT_MERCHANT)
end

function ChangesFence()
    UseCollectible(Changes.FENCE)
end

function CustomCommand(index)
    DoCommand(Changes.sv.customCommand[index])
end

  local function onAddonLoaded(event, addonName)
    if addonName == ADDON_NAME then
      EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    end
  end

  EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, onAddonLoaded)

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, function(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
    if not Changes.sv then return end

    armorShit()
    powerShit()

    if ZO_PlayerAttributeHealthBgContainer then
        for i=0, 100 do
            zo_callLater(function()
                ZO_PlayerAttributeHealthBgContainer:SetAlpha(0.7)
            end, i * 10)
        end
    end
end)


EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_POWER_UPDATE, function(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
    if ZO_PlayerAttributeHealthBgContainer then
        ZO_PlayerAttributeHealthBgContainer:SetAlpha(0.7)
    end
end)

function Changes:Initialize()
    Changes.sv = ZO_SavedVars:NewAccountWide("Changes_sv", 1, nil, Changes.Defaults)

    createSettings()

    glossyShit()
    frameShit()

    portCostShit()
    compassShit()
    compassFrameShit()

    SLASH_COMMANDS["/changesbanker"]   = ChangesBanker
    SLASH_COMMANDS["/changesfence"]    = ChangesFence
    SLASH_COMMANDS["/changesmerchant"] = ChangesMerchant

    SLASH_COMMANDS["/changescatmerchant"] = ChangesMerchantCat
    SLASH_COMMANDS["/changescatbanker"]   = ChangesBankerCat

    SLASH_COMMANDS["/changesmirri"]   = ChangesMirri
    SLASH_COMMANDS["/changesbastian"] = ChangesBastian

    local scenes = { "gamepad_worldMap", "worldMap" }
    local hud = { "hud", "hudui" }

    for _, scene in ipairs(scenes) do
        local sceneObj = SCENE_MANAGER:GetScene(scene)
        sceneObj:RegisterCallback("StateChange", function(oldState, newState)
            zoneStoryShit()
        end)
    end

    for _, scene in ipairs(hud) do
        local sceneObj = SCENE_MANAGER:GetScene(scene)
        sceneObj:RegisterCallback("StateChange", function(oldState, newState)
            hidetxt()
        end)
    end

    CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", zoneStoryShit)

    hidetop()
    hidebot()
    hidemet()
    hidecht()
    hidechtdiv()
    hidechtmin()
    hidechtnot()
    hideswp()
    hidekybd()
    hidebor()
    hidempt()
    hideone()
    hidetwo()
    hidetre()
    hidefor()
    hidefiv()
    hideult()
    hideqck()

    CHAT_SYSTEM.Maximize = function()
        EVENT_MANAGER:UnregisterForUpdate(Changes.REFIRE)
        Changes.Maximize(CHAT_SYSTEM)
        Changes.sv.isMinimized = false
    end

    CHAT_SYSTEM.Minimize = function()
        EVENT_MANAGER:UnregisterForUpdate(Changes.REFIRE)
        Changes.Minimize(CHAT_SYSTEM)
        Changes.sv.isMinimized = true
    end
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= Changes.name then return end
    Changes:Initialize()
end

local function OnPlayerActivated(event, initial)
    if (Changes.sv.isMinimized and Changes.sv.keepChatWindowHidden) or Changes.sv.alwaysMinimizeChatOnLoad then
        CHAT_SYSTEM:Minimize()
    end

    local gained = ZO_ChatWindowTextEntryEditBox:GetHandler("OnFocusGained")
    ZO_ChatWindowTextEntryEditBox:SetHandler("OnFocusGained", function()
        EVENT_MANAGER:UnregisterForUpdate(Changes.REFIRE)

        if gained ~= nil then
            gained(ZO_ChatWindowTextEntryEditBox)
        end
    end)

    local lost = ZO_ChatWindowTextEntryEditBox:GetHandler("OnFocusLost")
    ZO_ChatWindowTextEntryEditBox:SetHandler("OnFocusLost", function()
        EVENT_MANAGER:UnregisterForUpdate(Changes.REFIRE)

        if lost ~= nil then
            lost(ZO_ChatWindowTextEntryEditBox)
        end

        if Changes.sv.hideOnFocusLost then
            EVENT_MANAGER:RegisterForUpdate(Changes.REFIRE, Changes.sv.hideOnFocusWait * 1000, function ()
                CHAT_SYSTEM:Minimize()
                EVENT_MANAGER:UnregisterForUpdate(Changes.REFIRE)
            end, Changes.sv.hideOnFocusWait)
        end
    end)
end

EVENT_MANAGER:RegisterForEvent(Changes.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent(Changes.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
