BattleStats = BattleStats or {}
BattleStats.Settings = BattleStats.Settings or {}
local Settings = BattleStats.Settings
local Util = BattleStats.Util

Settings._sliderLast = Settings._sliderLast or {}

local function ApplyOffsetChange(settings, key, axis, value, minValue, maxValue)
    local step = tonumber(BattleStats.SV and BattleStats.SV.moveStep) or 1
    if step < 1 then step = 1 end

    local lastKey = key .. ":" .. axis
    local last = Settings._sliderLast[lastKey]
    local current = tonumber(value) or 0
    local delta = (last == nil) and 0 or (current - last)
    Settings._sliderLast[lastKey] = current

    if delta == 0 then return end
    local dir = (delta > 0) and 1 or -1

    local block = BattleStats.SV and BattleStats.SV[key]
    if not block then return end
    local existing = tonumber(block[axis]) or 0
    local nextValue = existing + (dir * step)

    if minValue and nextValue < minValue then nextValue = minValue end
    if maxValue and nextValue > maxValue then nextValue = maxValue end

    block[axis] = nextValue
    BattleStats.ApplySettings()
    if settings and settings.RefreshSettings then
        settings:RefreshSettings()
    end
end

local function AddSignature(settings)
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_LABEL,
        label = "|cFFD700Built on Teas, Toast and ADHD. Test live on PS5. - SugaComa|r",
    })
end

function Settings.Init()
    if not LibHarvensAddonSettings then
        Util.ChatMsg("BattleStats: LibHarvensAddonSettings not found. Settings menu disabled.")
        return
    end

    local LHAS = LibHarvensAddonSettings
    local settings = LHAS:AddAddon("BattleStats", { allowDefaults = true, allowRefresh = true })
    if not settings then return end
    Settings.menu = settings

    settings:AddSetting({ type = LHAS.ST_SECTION, label = "General" })

    settings:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Enable BattleStats",
        default = true,
        getFunction = function() return BattleStats.SV.enabled == true end,
        setFunction = function(state)
            BattleStats.SV.enabled = (state == true)
            BattleStats.ApplySettings()
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "SHOW UI (override)",
        tooltip = "Shows BattleStats even when the HUD is hidden.",
        default = false,
        getFunction = function() return BattleStats.SV.forceShow == true end,
        setFunction = function(state)
            BattleStats.SV.forceShow = (state == true)
            BattleStats.ApplySettings()
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Unlock UI",
        tooltip = "Allows dragging while HUD is visible or SHOW UI is on.",
        default = false,
        getFunction = function() return BattleStats.SV.unlocked == true end,
        setFunction = function(state)
            BattleStats.SV.unlocked = (state == true)
            BattleStats.ApplySettings()
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Show Magicka Recovery",
        default = true,
        getFunction = function() return BattleStats.SV.showMagRecovery == true end,
        setFunction = function(state)
            BattleStats.SV.showMagRecovery = (state == true)
            BattleStats.ApplySettings()
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Show Stamina Recovery",
        default = true,
        getFunction = function() return BattleStats.SV.showStamRecovery == true end,
        setFunction = function(state)
            BattleStats.SV.showStamRecovery = (state == true)
            BattleStats.ApplySettings()
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Show Health Recovery",
        default = true,
        getFunction = function() return BattleStats.SV.showHealthRecovery == true end,
        setFunction = function(state)
            BattleStats.SV.showHealthRecovery = (state == true)
            BattleStats.ApplySettings()
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Show Weapon/Spell Damage",
        default = true,
        getFunction = function() return BattleStats.SV.showDamage == true end,
        setFunction = function(state)
            BattleStats.SV.showDamage = (state == true)
            BattleStats.ApplySettings()
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Show Resistances",
        default = true,
        getFunction = function() return BattleStats.SV.showResist == true end,
        setFunction = function(state)
            BattleStats.SV.showResist = (state == true)
            BattleStats.ApplySettings()
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Show Penetration",
        default = true,
        getFunction = function() return BattleStats.SV.showPen == true end,
        setFunction = function(state)
            BattleStats.SV.showPen = (state == true)
            BattleStats.ApplySettings()
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_DROPDOWN,
        label = "Update Rate",
        tooltip = "How often stats refresh when polling or throttling events.",
        items = {
            { name = "200 ms", data = 200 },
            { name = "300 ms", data = 300 },
            { name = "500 ms", data = 500 },
        },
        getFunction = function()
            local v = tonumber(BattleStats.SV.updateMs) or 300
            if v == 200 then return "200 ms" end
            if v == 500 then return "500 ms" end
            return "300 ms"
        end,
        setFunction = function(combobox, name, item)
            if not item or not item.data then return end
            BattleStats.SV.updateMs = tonumber(item.data) or 300
            BattleStats.Updater.RefreshUpdateRate()
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "Scale",
        default = 1,
        min = 0.6,
        max = 1.6,
        step = 0.05,
        format = "%.2f",
        getFunction = function() return tonumber(BattleStats.SV.scale) or 1 end,
        setFunction = function(value)
            BattleStats.SV.scale = tonumber(value) or 1
            BattleStats.ApplySettings()
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "Font Size",
        default = 22,
        min = 16,
        max = 32,
        step = 1,
        format = "%d",
        getFunction = function() return tonumber(BattleStats.SV.fontSize) or 22 end,
        setFunction = function(value)
            BattleStats.SV.fontSize = tonumber(value) or 22
            BattleStats.ApplySettings()
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Background",
        tooltip = "Toggle a soft background behind the stats.",
        default = false,
        getFunction = function() return BattleStats.SV.background == true end,
        setFunction = function(state)
            BattleStats.SV.background = (state == true)
            BattleStats.ApplySettings()
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_DROPDOWN,
        label = "Anchor Base",
        tooltip = "Bars anchors near the attribute bars. Crosshair anchors from screen center.",
        items = {
            { name = "Bars", data = "bars" },
            { name = "Crosshair", data = "reticle" },
        },
        getFunction = function()
            return (BattleStats.SV.anchorBase == "reticle") and "Crosshair" or "Bars"
        end,
        setFunction = function(combobox, name, item)
            if not item or not item.data then return end
            BattleStats.SV.anchorBase = tostring(item.data)
            BattleStats.ApplySettings()
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_DROPDOWN,
        label = "Movement Step",
        tooltip = "Controls how much each slider step moves.",
        items = {
            { name = "Low (1)", data = 1 },
            { name = "High (25)", data = 25 },
        },
        getFunction = function()
            local v = tonumber(BattleStats.SV.moveStep) or 1
            if v == 25 then return "High (25)" end
            return "Low (1)"
        end,
        setFunction = function(combobox, name, item)
            if not item or not item.data then return end
            BattleStats.SV.moveStep = tonumber(item.data) or 1
        end,
    })

    settings:AddSetting({ type = LHAS.ST_SECTION, label = "Magicka Recovery Offsets" })

    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "Magicka Offset X",
        default = 0,
        min = -1000,
        max = 1000,
        step = 1,
        format = "%d",
        getFunction = function() return tonumber(BattleStats.SV.magRecovery.offsetX) or 0 end,
        setFunction = function(value)
            ApplyOffsetChange(settings, "magRecovery", "offsetX", value, -1000, 1000)
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "Magicka Offset Y",
        default = -80,
        min = -1000,
        max = 1000,
        step = 1,
        format = "%d",
        getFunction = function() return tonumber(BattleStats.SV.magRecovery.offsetY) or 0 end,
        setFunction = function(value)
            ApplyOffsetChange(settings, "magRecovery", "offsetY", value, -1000, 1000)
        end,
    })

    settings:AddSetting({ type = LHAS.ST_SECTION, label = "Stamina Recovery Offsets" })

    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "Stamina Offset X",
        default = 0,
        min = -1000,
        max = 1000,
        step = 1,
        format = "%d",
        getFunction = function() return tonumber(BattleStats.SV.stamRecovery.offsetX) or 0 end,
        setFunction = function(value)
            ApplyOffsetChange(settings, "stamRecovery", "offsetX", value, -1000, 1000)
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "Stamina Offset Y",
        default = -55,
        min = -1000,
        max = 1000,
        step = 1,
        format = "%d",
        getFunction = function() return tonumber(BattleStats.SV.stamRecovery.offsetY) or 0 end,
        setFunction = function(value)
            ApplyOffsetChange(settings, "stamRecovery", "offsetY", value, -1000, 1000)
        end,
    })

    settings:AddSetting({ type = LHAS.ST_SECTION, label = "Health Recovery Offsets" })

    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "Health Offset X",
        default = 0,
        min = -1000,
        max = 1000,
        step = 1,
        format = "%d",
        getFunction = function() return tonumber(BattleStats.SV.healthRecovery.offsetX) or 0 end,
        setFunction = function(value)
            ApplyOffsetChange(settings, "healthRecovery", "offsetX", value, -1000, 1000)
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "Health Offset Y",
        default = -30,
        min = -1000,
        max = 1000,
        step = 1,
        format = "%d",
        getFunction = function() return tonumber(BattleStats.SV.healthRecovery.offsetY) or 0 end,
        setFunction = function(value)
            ApplyOffsetChange(settings, "healthRecovery", "offsetY", value, -1000, 1000)
        end,
    })

    settings:AddSetting({ type = LHAS.ST_SECTION, label = "Weapon/Spell Damage Offsets" })

    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "Damage Offset X",
        default = 0,
        min = -1000,
        max = 1000,
        step = 1,
        format = "%d",
        getFunction = function() return tonumber(BattleStats.SV.damage.offsetX) or 0 end,
        setFunction = function(value)
            ApplyOffsetChange(settings, "damage", "offsetX", value, -1000, 1000)
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "Damage Offset Y",
        default = 40,
        min = -1000,
        max = 1000,
        step = 1,
        format = "%d",
        getFunction = function() return tonumber(BattleStats.SV.damage.offsetY) or 0 end,
        setFunction = function(value)
            ApplyOffsetChange(settings, "damage", "offsetY", value, -1000, 1000)
        end,
    })

    settings:AddSetting({ type = LHAS.ST_SECTION, label = "Resistance Offsets" })

    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "Resistance Offset X",
        default = 0,
        min = -1000,
        max = 1000,
        step = 1,
        format = "%d",
        getFunction = function() return tonumber(BattleStats.SV.resist.offsetX) or 0 end,
        setFunction = function(value)
            ApplyOffsetChange(settings, "resist", "offsetX", value, -1000, 1000)
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "Resistance Offset Y",
        default = 70,
        min = -1000,
        max = 1000,
        step = 1,
        format = "%d",
        getFunction = function() return tonumber(BattleStats.SV.resist.offsetY) or 0 end,
        setFunction = function(value)
            ApplyOffsetChange(settings, "resist", "offsetY", value, -1000, 1000)
        end,
    })

    settings:AddSetting({ type = LHAS.ST_SECTION, label = "Penetration Offsets" })

    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "Penetration Offset X",
        default = 0,
        min = -1000,
        max = 1000,
        step = 1,
        format = "%d",
        getFunction = function() return tonumber(BattleStats.SV.pen.offsetX) or 0 end,
        setFunction = function(value)
            ApplyOffsetChange(settings, "pen", "offsetX", value, -1000, 1000)
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "Penetration Offset Y",
        default = 260,
        min = -1000,
        max = 1000,
        step = 1,
        format = "%d",
        getFunction = function() return tonumber(BattleStats.SV.pen.offsetY) or 0 end,
        setFunction = function(value)
            ApplyOffsetChange(settings, "pen", "offsetY", value, -1000, 1000)
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_BUTTON,
        label = "Reset Positions",
        tooltip = "Return all blocks to their default anchors.",
        buttonText = "Reset",
        clickHandler = function()
            BattleStats.UI.ResetPositions()
        end,
    })

    settings:AddSetting({ type = LHAS.ST_SECTION, label = "Build Sheet" })

    settings:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Enable Build Sheet",
        tooltip = "Enables the compact Build Sheet page (Base / Likely / Perfect).",
        default = true,
        getFunction = function() return BattleStats.SV.buildSheetEnabled == true end,
        setFunction = function(state)
            BattleStats.SV.buildSheetEnabled = (state == true)
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_DROPDOWN,
        label = "Default View",
        items = {
            { name = "Base", data = "base" },
            { name = "Likely", data = "likely" },
            { name = "Perfect", data = "perfect" },
        },
        getFunction = function()
            local v = tostring(BattleStats.SV.buildSheetDefaultView or "likely")
            if v == "base" then return "Base" end
            if v == "perfect" then return "Perfect" end
            return "Likely"
        end,
        setFunction = function(_, _, item)
            if not item or not item.data then return end
            BattleStats.SV.buildSheetDefaultView = tostring(item.data)
            if BattleStats.BuildSheet and BattleStats.BuildSheet.Refresh then
                BattleStats.BuildSheet.Refresh()
            end
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_DROPDOWN,
        label = "Likely Preset",
        tooltip = "Controls assumed uptime weighting for the Likely view.",
        items = {
            { name = "Conservative", data = "conservative" },
            { name = "Normal", data = "normal" },
            { name = "Aggressive", data = "aggressive" },
        },
        getFunction = function()
            local v = tostring(BattleStats.SV.buildSheetUptimePreset or "normal")
            if v == "conservative" then return "Conservative" end
            if v == "aggressive" then return "Aggressive" end
            return "Normal"
        end,
        setFunction = function(_, _, item)
            if not item or not item.data then return end
            BattleStats.SV.buildSheetUptimePreset = tostring(item.data)
            if BattleStats.BuildSheet and BattleStats.BuildSheet.Refresh then
                BattleStats.BuildSheet.Refresh()
            end
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Assume Blocking in Sample Hit",
        tooltip = "If enabled, Sample Hit math includes 50% block mitigation.",
        default = false,
        getFunction = function() return BattleStats.SV.buildSheetAssumeBlocking == true end,
        setFunction = function(state)
            BattleStats.SV.buildSheetAssumeBlocking = (state == true)
            if BattleStats.BuildSheet and BattleStats.BuildSheet.Refresh then
                BattleStats.BuildSheet.Refresh()
            end
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "Sample Hit (damage)",
        default = 1000,
        min = 100,
        max = 20000,
        step = 50,
        format = "%d",
        getFunction = function() return tonumber(BattleStats.SV.buildSheetSampleHit) or 1000 end,
        setFunction = function(value)
            BattleStats.SV.buildSheetSampleHit = tonumber(value) or 1000
            if BattleStats.BuildSheet and BattleStats.BuildSheet.Refresh then
                BattleStats.BuildSheet.Refresh()
            end
        end,
    })

    settings:AddSetting({
        type = LHAS.ST_BUTTON,
        label = "Toggle Build Sheet",
        buttonText = "Toggle",
        clickHandler = function()
            if BattleStats.BuildSheet and BattleStats.BuildSheet.Toggle then
                BattleStats.BuildSheet.Toggle()
            end
        end,
    })

    settings:AddSetting({ type = LHAS.ST_SECTION, label = "Debug" })

    settings:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Debug Mode",
        tooltip = "Prints API usage and missing fallbacks to chat.",
        default = false,
        getFunction = function() return BattleStats.SV.debug == true end,
        setFunction = function(state)
            BattleStats.SV.debug = (state == true)
            BattleStats.PrintApiStatus()
        end,
    })

    AddSignature(settings)
end
