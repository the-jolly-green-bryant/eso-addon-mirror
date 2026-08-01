--------------------------------------------------------------
-- VSRMenu_v2.lua — VampireStageReminder_v2 Settings Menu
-- Author: SugaComa (Rik Sprint)
-- Version: v2.0.1-test1 "Stage One Guard"
-- Standardised LHAS layout used across SugaComa addons.
--------------------------------------------------------------

local VSRMenu_v2 = {}
VSRMenu_v2.name    = "VSRMenu_v2"
VSRMenu_v2.version = "2.0.1-test1"

local LHA = LibHarvensAddonSettings
if not LHA then
    CHAT_ROUTER:AddSystemMessage("[VSRMenu_v2] LibHarvensAddonSettings not found. Please install or enable it.")
    return
end

--------------------------------------------------------------
-- Safety wrapper for defaults + SavedVars sync
--------------------------------------------------------------
local function coalesce(addon)
    addon.SV = addon.SV or addon.saved or {}
    addon.SV.finalStageMin      = addon.SV.finalStageMin or addon.finalStageMin or 3
    addon.SV.finalStageInterval = addon.SV.finalStageInterval or addon.finalStageInterval or 15
    addon.SV.soundEnabled       = (addon.SV.soundEnabled ~= false)

    addon.finalStageMin         = addon.SV.finalStageMin
    addon.finalStageInterval    = addon.SV.finalStageInterval
    addon.soundEnabled          = addon.SV.soundEnabled
end

--------------------------------------------------------------
-- Setup menu
--------------------------------------------------------------
function VSRMenu_v2.Setup(addon)
    coalesce(addon)

    local settings = LHA:AddAddon("Vampire Stage Reminder", {
        allowDefaults = true,
        allowRefresh  = true,
        defaultsFunction = function()
            addon.SV.finalStageMin      = 3
            addon.SV.finalStageInterval = 15
            addon.SV.soundEnabled       = true

            addon.finalStageMin         = 3
            addon.finalStageInterval    = 15
            addon.soundEnabled          = true
        end,
    })
    if not settings then return end

    -- Console LHAS keeps settings after a normal ST_SECTION inside that
    -- section until another section resets it. A section with subMenu=false
    -- acts as a top-level visual divider without opening an options page.
    local function AddCategoryHeader(label)
        settings:AddSetting({
            type = LHA.ST_SECTION,
            subMenu = false,
            label = "|cFFD700-- " .. label .. " --|r",
        })
    end

    AddCategoryHeader("REMINDER SETTINGS")

    ----------------------------------------------------------
    -- Section: Final Stage Timing
    ----------------------------------------------------------
    settings:AddSetting({
        type  = LHA.ST_SECTION,
        label = "Final Stage Timing",
    })
    settings:AddSetting({
        type        = LHA.ST_SLIDER,
        label       = "Final Stage Window (minutes)",
        tooltip     = "Set when center-screen alerts begin before the next stage. Default: 3 minutes.",
        min         = 1,
        max         = 5,
        step        = 1,
        unit        = "min",
        format      = "%d",
        default     = 3,
        getFunction = function() return addon.SV.finalStageMin end,
        setFunction = function(value)
            addon.finalStageMin      = value
            addon.SV.finalStageMin   = value
        end,
    })

    ----------------------------------------------------------
    -- Section: Reminder Frequency
    ----------------------------------------------------------
    settings:AddSetting({
        type  = LHA.ST_SECTION,
        label = "Final Stage Reminder Frequency",
    })
    settings:AddSetting({
        type        = LHA.ST_DROPDOWN,
        label       = "Reminder Interval",
        tooltip     = "How often to repeat center-screen alerts during the final stage window.",
        items       = {
            { name = "Every 15 seconds", data = 15 },
            { name = "Every 30 seconds", data = 30 },
            { name = "Every 60 seconds", data = 60 },
        },
        default     = "Every 15 seconds",
        getFunction = function()
            if addon.SV.finalStageInterval == 30 then return "Every 30 seconds"
            elseif addon.SV.finalStageInterval == 60 then return "Every 60 seconds"
            else return "Every 15 seconds" end
        end,
        setFunction = function(_, name, item)
            local val = item and item.data or (name:find("30") and 30 or name:find("60") and 60 or 15)
            addon.finalStageInterval    = val
            addon.SV.finalStageInterval = val
        end,
    })

    AddCategoryHeader("ALERTS")

    ----------------------------------------------------------
    -- Section: Sound Alerts
    ----------------------------------------------------------
    settings:AddSetting({
        type  = LHA.ST_SECTION,
        label = "Sound Alerts",
    })
    settings:AddSetting({
        type        = LHA.ST_CHECKBOX,
        label       = "Enable Sound Alerts",
        tooltip     = "Toggles reminder sounds on or off.",
        default     = true,
        getFunction = function() return addon.SV.soundEnabled end,
        setFunction = function(state)
            addon.soundEnabled       = state
            addon.SV.soundEnabled    = state
        end,
    })

    AddCategoryHeader("TOOLS")

    ----------------------------------------------------------
    -- Section: Test Utility
    ----------------------------------------------------------
    settings:AddSetting({
        type         = LHA.ST_SECTION,
        label        = "Test Utility",
    })
    settings:AddSetting({
        type         = LHA.ST_BUTTON,
        label        = "Test Final Stage Alert",
        tooltip      = "Displays a sample center-screen reminder message using your current color and timing.",
        buttonText   = "Run Test",
        clickHandler = function()
            local COLOR_MAGENTA = "|cFF00FF"
            local COLOR_END     = "|r"
            local timerColor    = "|cFFA500"
            local stage, h, m, s = 3, 0, 2, 15

            local msg = string.format(
                "%sStage %d%s — %s%02dh %02dm %02ds%s to next stage",
                COLOR_MAGENTA, stage, COLOR_END,
                timerColor, h, m, s, COLOR_END
            )

            local CSA = CENTER_SCREEN_ANNOUNCE
            if CSA and CSA.CreateMessageParams then
                local p = CSA:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.ABILITY_ULTIMATE_READY)
                p:SetText(msg)
                CSA:DisplayMessage(p)
            else
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.POSITIVE_CLICK, msg)
            end
        end,
    })

    ----------------------------------------------------------
    -- SugaComa signature and contact
    ----------------------------------------------------------
    settings:AddSetting({
        type = LHA.ST_SECTION,
        subMenu = false,
        label = "|cFFD700Built on tea, toast and ADHD – tested live on PS5.|r\n" ..
                "|cB427D3Su|c546D6Aga|c889764Co|cDA34CDma|r",
    })
    settings:AddSetting({
        type = LHA.ST_LABEL,
        label = "Contact",
        tooltip = "Found an error or need to contact me about Vampire Stage Reminder?\n\nPlayStation User / PSN: SugaComa\nEmail: eso.addons@rik-sprint.co.uk",
    })

    ----------------------------------------------------------
    -- Exit confirmation & Save Hook
    ----------------------------------------------------------
    local scene = SCENE_MANAGER:GetScene("addonSettingsScene")
    if scene and not scene.vsrHooked then
        scene.vsrHooked = true
        scene:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_HIDDEN then
                if addon.SV then
                    addon.SV.finalStageMin      = addon.finalStageMin
                    addon.SV.finalStageInterval = addon.finalStageInterval
                    addon.SV.soundEnabled       = addon.soundEnabled
                end
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.POSITIVE_CLICK,
                    "[VampireStageReminder_v2] Settings saved.")
            end
        end)
    end

    CHAT_ROUTER:AddSystemMessage("[VSRMenu_v2] Settings menu registered.")
end

_G["VSRMenu_v2"] = VSRMenu_v2
