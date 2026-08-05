--------------------------------------------------------------
-- FRMenu.lua — FoodReminder_v2 Settings Menu (Console Safe)
-- Author: SugaComa (Rik Sprint)
-- Version: 2.8.1-test1 (Optional same-food auto refresh from 5 minutes)
-- Requires: LibHarvensAddonSettings
--------------------------------------------------------------

local FRMenu = {}
FRMenu.name    = "FRMenu"
FRMenu.version = "2.8.1-test1"

local LHA = LibHarvensAddonSettings
if not LHA then
    CHAT_ROUTER:AddSystemMessage("[FRMenu] LibHarvensAddonSettings not found. Please install or enable it.")
    return
end

--------------------------------------------------------------
-- Safety wrapper for defaults + SV sync
--------------------------------------------------------------
local function coalesce(addon)
    addon.SV = addon.SV or addon.saved or {}

    addon.SV.mode               = addon.SV.mode               or addon.mode               or "subtle"
    addon.SV.finalStageMin      = addon.SV.finalStageMin      or addon.finalStageMin      or 3
    addon.SV.finalStageInterval = addon.SV.finalStageInterval or addon.finalStageInterval or 15
    addon.SV.soundEnabled       = (addon.SV.soundEnabled ~= false)
    addon.SV.finalStageSound    = addon.SV.finalStageSound    or SOUNDS.DUEL_WON
    addon.SV.autoRefreshFood     = (addon.SV.autoRefreshFood == true)
    addon.SV.maxAutoRefreshesPerSession = tonumber(addon.SV.maxAutoRefreshesPerSession) or 2

    addon.mode               = addon.SV.mode
    addon.finalStageMin      = addon.SV.finalStageMin
    addon.finalStageInterval = addon.SV.finalStageInterval
    addon.soundEnabled       = addon.SV.soundEnabled
    addon.finalStageSound    = addon.SV.finalStageSound
    addon.autoRefreshFood     = addon.SV.autoRefreshFood
    addon.maxAutoRefreshesPerSession = addon.SV.maxAutoRefreshesPerSession
end

--------------------------------------------------------------
-- Setup menu
--------------------------------------------------------------
function FRMenu.Setup(addon)
    coalesce(addon)

    local settings = LHA:AddAddon("Food Reminder", {
        allowDefaults = true,
        allowRefresh  = true,
        defaultsFunction = function()
            addon.SV.mode               = "subtle"
            addon.SV.finalStageMin      = 3
            addon.SV.finalStageInterval = 15
            addon.SV.soundEnabled       = true
            addon.SV.finalStageSound    = SOUNDS.DUEL_WON
            addon.SV.autoRefreshFood     = false
            addon.SV.maxAutoRefreshesPerSession = 2
            addon.mode               = addon.SV.mode
            addon.finalStageMin      = addon.SV.finalStageMin
            addon.finalStageInterval = addon.SV.finalStageInterval
            addon.soundEnabled       = addon.SV.soundEnabled
            addon.finalStageSound    = addon.SV.finalStageSound
            addon.autoRefreshFood     = addon.SV.autoRefreshFood
            addon.maxAutoRefreshesPerSession = addon.SV.maxAutoRefreshesPerSession
            if addon.RefreshAutoRefreshSchedule then
                addon.RefreshAutoRefreshSchedule()
            end
        end,
    })
    if not settings then return end

    ----------------------------------------------------------
    -- Section: Display Mode
    ----------------------------------------------------------
    settings:AddSetting({ type = LHA.ST_SECTION, label = "Display Mode" })
    settings:AddSetting({
        type        = LHA.ST_DROPDOWN,
        label       = "Mode",
        tooltip     = "Subtle: All alerts top-right.\nIn Your Face: Final-stage alerts appear center-screen.",
        items       = {
            { name = "Subtle", data = "subtle" },
            { name = "In Your Face", data = "inyourface" },
        },
        default     = "Subtle",
        getFunction = function()
            return (addon.SV.mode == "inyourface") and "In Your Face" or "Subtle"
        end,
        setFunction = function(_, name, item)
            local val = item and item.data or ((name == "In Your Face") and "inyourface" or "subtle")
            addon.mode     = val
            addon.SV.mode  = val
        end,
    })

    ----------------------------------------------------------
    -- Section: Final Stage Settings
    ----------------------------------------------------------
    settings:AddSetting({ type = LHA.ST_SECTION, label = "Final Stage Settings" })

    -- Editable Final Stage Window (minutes)
    settings:AddSetting({
        type        = LHA.ST_SLIDER,
        label       = "Start Final Stage (minutes before expiry)",
        tooltip     = "Set how long before food expires the final countdown begins.",
        min         = 1, max = 10, step = 1, unit = "min",
        default     = 3,
        getFunction = function() return addon.SV.finalStageMin or 3 end,
        setFunction = function(value)
            addon.finalStageMin    = value
            addon.SV.finalStageMin = value
        end,
    })

    -- Editable reminder frequency (seconds)
    settings:AddSetting({
        type        = LHA.ST_SLIDER,
        label       = "Reminder Interval (seconds)",
        tooltip     = "How often to repeat reminders during the final stage.",
        min         = 15, max = 120, step = 15, unit = "s",
        default     = 15,
        getFunction = function() return addon.SV.finalStageInterval or 15 end,
        setFunction = function(value)
            addon.finalStageInterval    = value
            addon.SV.finalStageInterval = value
        end,
    })

    ----------------------------------------------------------
    -- Section: Optional automatic food refresh
    ----------------------------------------------------------
    settings:AddSetting({ type = LHA.ST_SECTION, label = "Automatic Food Refresh" })
    settings:AddSetting({
        type        = LHA.ST_CHECKBOX,
        label       = "Auto-Refresh Same Food When Safe",
        tooltip     = "Optional. At 5 minutes remaining, Food Reminder arms auto-refresh and waits for a safe state: out of combat, alive, unmounted, not swimming and stationary. It then attempts to consume the same food or drink from your backpack. Off by default. Auto-refresh results are written to chat so technical messages are not hidden by overlapping alerts.",
        default     = false,
        getFunction = function()
            return addon.SV.autoRefreshFood == true
        end,
        setFunction = function(state)
            addon.autoRefreshFood = (state == true)
            addon.SV.autoRefreshFood = addon.autoRefreshFood
            if addon.RefreshAutoRefreshSchedule then
                addon.RefreshAutoRefreshSchedule()
            end
        end,
    })

    settings:AddSetting({
        type        = LHA.ST_SLIDER,
        label       = "Maximum Auto-Refreshes Per Session",
        tooltip     = "Safety limit for automatic food/drink consumption. Only confirmed successful auto-refreshes count. Once the limit is reached, automatic consumption stops until the UI session is restarted; normal expiry reminders continue.",
        min         = 1, max = 10, step = 1,
        default     = 2,
        getFunction = function()
            return tonumber(addon.SV.maxAutoRefreshesPerSession) or 2
        end,
        setFunction = function(value)
            value = math.max(1, math.min(10, math.floor(tonumber(value) or 2)))
            addon.maxAutoRefreshesPerSession = value
            addon.SV.maxAutoRefreshesPerSession = value
        end,
    })

    ----------------------------------------------------------
    -- Section: Final Stage Sound
    ----------------------------------------------------------
    settings:AddSetting({ type = LHA.ST_SECTION, label = "Final Stage Sound" })
    settings:AddSetting({
        type        = LHA.ST_DROPDOWN,
        label       = "Select Sound",
        tooltip     = "Choose which sound plays during the final 5 minutes.",
        items       = {
            { name = "Soft Ping",       data = SOUNDS.POSITIVE_CLICK },
            { name = "Drum Hit",        data = SOUNDS.DUEL_WON },
            { name = "Chime",           data = SOUNDS.CHAMPION_POINT_GAINED },
            { name = "Subtle Tick",     data = SOUNDS.TELVAR_MULIPLIERUP },
            { name = "None (Silent)",   data = SOUNDS.NONE },
        },
        default     = SOUNDS.DUEL_WON,
        getFunction = function()
            return addon.SV.finalStageSound or SOUNDS.DUEL_WON
        end,
        setFunction = function(_, _, item)
            local sound = item and item.data or SOUNDS.DUEL_WON
            addon.finalStageSound    = sound
            addon.SV.finalStageSound = sound
            if sound ~= SOUNDS.NONE then
                PlaySound(sound)
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, "[FoodReminder_v2] Preview sound played.")
            else
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, "[FoodReminder_v2] Silent mode selected.")
            end
        end,
    })

    ----------------------------------------------------------
    -- Section: Sound Alerts toggle
    ----------------------------------------------------------
    settings:AddSetting({ type = LHA.ST_SECTION, label = "Sound Alerts Toggle" })
    settings:AddSetting({
        type        = LHA.ST_CHECKBOX,
        label       = "Enable All Sounds",
        tooltip     = "Toggles reminder sounds globally on or off.",
        default     = true,
        getFunction = function() return addon.SV.soundEnabled end,
        setFunction = function(state)
            addon.soundEnabled       = state
            addon.SV.soundEnabled    = state
        end,
    })

    ----------------------------------------------------------
    -- Section: Test Reminder
    ----------------------------------------------------------
    settings:AddSetting({ type = LHA.ST_SECTION, label = "Utilities" })
    settings:AddSetting({
        type         = LHA.ST_BUTTON,
        label        = "Test Reminder Message",
        tooltip      = "Show a sample reminder message using your current settings.",
        buttonText   = "Run Test",
        clickHandler = function()
            local label = "Clockwork Citrus Filet"
            local h, m, s = 0, 2, 45
            local colorEnd = "|r"
            local colorTimer =
                (addon.SV.finalStageMin <= 2 and "|cFF0000") or
                (addon.SV.finalStageMin <= 4 and "|cFFA500") or
                "|c00FF00"

            local msg = string.format("|c800080%s%s — %s%02dh %02dm %02ds%s left",
                label, colorEnd, colorTimer, h, m, s, colorEnd)

            if addon.SV.mode == "inyourface" then
                local CSA = CENTER_SCREEN_ANNOUNCE
                if CSA and CSA.CreateMessageParams then
                    local p = CSA:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, addon.SV.finalStageSound or SOUNDS.DUEL_WON)
                    p:SetText(msg)
                    CSA:DisplayMessage(p)
                else
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, addon.SV.finalStageSound or SOUNDS.DUEL_WON, msg)
                end
            else
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, addon.SV.finalStageSound or SOUNDS.DUEL_WON, msg)
            end
        end,
    })

    ----------------------------------------------------------
    -- Section: Simulated 2-Minute Warning Test
    ----------------------------------------------------------
    settings:AddSetting({ type = LHA.ST_SECTION, label = "Simulation" })
    settings:AddSetting({
        type         = LHA.ST_BUTTON,
        label        = "Simulate 2-Minute Warning",
        tooltip      = "Runs a live two-minute test using your current settings. Shows how final-stage reminders will appear and sound.",
        buttonText   = "Start Test",
        clickHandler = function()
            local testDuration   = 120          -- total 2 minutes
            local interval       = addon.SV.finalStageInterval or 15
            local mode           = addon.SV.mode or "subtle"
            local sound          = addon.SV.finalStageSound or SOUNDS.DUEL_WON
            local remaining      = testDuration
            local active         = true

            local function tick()
                if not active then return end
                local h = 0
                local m = math.floor(remaining / 60)
                local s = remaining % 60
                local color =
                    (remaining <= 30 and "|cFF0000") or
                    (remaining <= 60 and "|cFFA500") or
                    "|c00FF00"
                local msg = string.format(
                    "|c800080[Food Reminder Test]|r — %s%02dm %02ds%s left",
                    color, m, s, "|r"
                )

                if mode == "inyourface" then
                    local CSA = CENTER_SCREEN_ANNOUNCE
                    if CSA and CSA.CreateMessageParams then
                        local p = CSA:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, sound)
                        p:SetText(msg)
                        CSA:DisplayMessage(p)
                    else
                        ZO_Alert(UI_ALERT_CATEGORY_ALERT, sound, msg)
                    end
                else
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, sound, msg)
                end

                remaining = remaining - interval
                if remaining > 0 then
                    zo_callLater(tick, interval * 1000)
                else
                    active = false
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, "[FoodReminder_v2] Test complete — food expired!")
                end
            end

            tick()
        end,
    })


    ----------------------------------------------------------
    -- Exit confirmation (scene event listener)
    ----------------------------------------------------------
    local scene = SCENE_MANAGER:GetScene("addonSettingsScene")
    if scene and not scene.frHooked then
        scene.frHooked = true
        scene:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_HIDDEN then
                if addon.SV then
                    addon.SV.mode               = addon.mode
                    addon.SV.finalStageMin      = addon.finalStageMin
                    addon.SV.finalStageInterval = addon.finalStageInterval
                    addon.SV.soundEnabled       = addon.soundEnabled
                    addon.SV.finalStageSound    = addon.finalStageSound
                    addon.SV.autoRefreshFood     = (addon.autoRefreshFood == true)
                    addon.SV.maxAutoRefreshesPerSession = tonumber(addon.maxAutoRefreshesPerSession) or 2
                end
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.POSITIVE_CLICK, "[FoodReminder_v2] Settings saved.")
            end
        end)
    end

    CHAT_ROUTER:AddSystemMessage("[FRMenu] Settings menu registered.")
end

_G["FRMenu"] = FRMenu
