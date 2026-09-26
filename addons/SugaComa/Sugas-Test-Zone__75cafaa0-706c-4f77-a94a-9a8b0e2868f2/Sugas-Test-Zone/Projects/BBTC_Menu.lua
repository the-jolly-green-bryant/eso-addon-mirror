SugasTestZoneBBTCadence = SugasTestZoneBBTCadence or {}
local Project = SugasTestZoneBBTCadence

Project.Menu = Project.Menu or {}
local Menu = Project.Menu

local MODE_ITEMS = {
    { name = "PvE (Per-Skill)", data = "pve" },
    { name = "PvP (Grouped)", data = "pvp" },
    { name = "Dual-Bar HUD", data = "hud" },
}

local function GetModeName()
    for _, item in ipairs(MODE_ITEMS) do
        if item.data == Project.sv.mode then return item.name end
    end
    return MODE_ITEMS[2].name
end

local function ResolveMode(name, item)
    if type(item) == "table" and item.data then return item.data end
    for _, candidate in ipairs(MODE_ITEMS) do
        if candidate.name == name then return candidate.data end
    end
    return "pvp"
end

local function AddSlotToggle(settings, lib, hotbar, slot)
    local settingsKey = hotbar == HOTBAR_CATEGORY_PRIMARY and "frontSlots" or "backSlots"
    local barName = hotbar == HOTBAR_CATEGORY_PRIMARY and "Front" or "Back"
    local positionName = string.format("Skill %d", slot - 2)
    settings:AddSetting({
        type = lib.ST_CHECKBOX,
        label = string.format("%s %s", barName, positionName),
        tooltip = string.format("Track %s on the %s bar in Dual-Bar HUD mode.",
            string.lower(positionName), string.lower(barName)),
        default = true,
        getFunction = function()
            return Project.sv[settingsKey][slot] ~= false
        end,
        setFunction = function(value)
            Project.sv[settingsKey][slot] = value == true
            Project.HUD:Refresh()
            Project.Tracker:RefreshScheduler()
        end,
    })
end

function Menu:Initialize()
    local lib = LibHarvensAddonSettings
    if not lib or type(lib.AddAddon) ~= "function" then
        Project:Log("LibHarvensAddonSettings unavailable; experiment menu not registered", true)
        return
    end
    if not lib.ST_DROPDOWN or not lib.ST_SLIDER
        or not lib.ST_CHECKBOX or not lib.ST_BUTTON then
        Project:Log("Required console settings controls are unavailable", true)
        return
    end

    local settings = lib:AddAddon("STZ: BackBarTimer + Cadence", {
        allowDefaults = false,
        allowRefresh = false,
    })
    if not settings or type(settings.AddSetting) ~= "function" then return end

    settings:AddSetting({
        type = lib.ST_DROPDOWN,
        label = "Mode",
        tooltip = "Retains the two BackBarTimer modes and adds the experimental dual-bar HUD.",
        items = MODE_ITEMS,
        default = "PvP (Grouped)",
        getFunction = GetModeName,
        setFunction = function(_, name, item)
            Project.sv.mode = ResolveMode(name, item)
            Project.State.clusterAlerted = {}
            Project.HUD:Refresh()
            Project.Tracker:RefreshScheduler()
        end,
    })

    settings:AddSetting({
        type = lib.ST_SLIDER,
        label = "Legacy alert lead time",
        tooltip = "Seconds before expiry for PvE and PvP alerts. HUD mode always changes at 2 seconds.",
        min = 1, max = 10, step = 1,
        default = 2,
        getFunction = function() return tonumber(Project.sv.leadSeconds) or 2 end,
        setFunction = function(value) Project.sv.leadSeconds = value end,
        unit = "s",
        format = "%d",
    })

    if lib.ST_SECTION then
        settings:AddSetting({ type = lib.ST_SECTION, label = "Dual-Bar Skill Tracking" })
    end
    for slot = Project.Config.firstSlot, Project.Config.lastSlot do
        AddSlotToggle(settings, lib, HOTBAR_CATEGORY_BACKUP, slot)
    end
    for slot = Project.Config.firstSlot, Project.Config.lastSlot do
        AddSlotToggle(settings, lib, HOTBAR_CATEGORY_PRIMARY, slot)
    end

    if lib.ST_SECTION then
        settings:AddSetting({ type = lib.ST_SECTION, label = "Dual-Bar Countdown" })
    end
    settings:AddSetting({
        type = lib.ST_CHECKBOX,
        label = "Show full skill countdown",
        tooltip = "Show each qualifying skill prompt for its full tracked duration. When off, the custom countdown start time is used.",
        default = false,
        getFunction = function() return Project.sv.hudFullCountdown == true end,
        setFunction = function(value)
            Project.sv.hudFullCountdown = value == true
            Project.HUD:Refresh()
        end,
    })
    settings:AddSetting({
        type = lib.ST_SLIDER,
        label = "Custom countdown start",
        tooltip = "When full countdown is off, choose how many seconds before expiry the button prompt appears.",
        min = 3, max = 60, step = 1,
        default = 10,
        getFunction = function() return tonumber(Project.sv.hudCountdownSeconds) or 10 end,
        setFunction = function(value)
            Project.sv.hudCountdownSeconds = value
            Project.HUD:Refresh()
        end,
        unit = "s",
        format = "%d",
    })

    if lib.ST_SECTION then
        settings:AddSetting({ type = lib.ST_SECTION, label = "Cadence Prompts" })
    end
    settings:AddSetting({
        type = lib.ST_CHECKBOX,
        label = "Block cadence",
        tooltip = "First detected block in combat starts a shield cue every 2 seconds until combat ends.",
        default = false,
        getFunction = function() return Project.sv.blockCadence == true end,
        setFunction = function(value)
            Project.sv.blockCadence = value == true
            if not Project.sv.blockCadence then
                Project.State.blockCadenceStartedMs = nil
                Project.State.blockPulseUntilMs = 0
            end
            Project.Tracker:RefreshScheduler()
            Project.HUD:Refresh()
        end,
    })
    settings:AddSetting({
        type = lib.ST_CHECKBOX,
        label = "Light-attack cadence",
        tooltip = "First detected light attack in combat starts a weapon cue every 2 seconds until combat ends.",
        default = false,
        getFunction = function() return Project.sv.lightCadence == true end,
        setFunction = function(value)
            Project.sv.lightCadence = value == true
            if not Project.sv.lightCadence then
                Project.State.lightCadenceStartedMs = nil
                Project.State.lightPulseUntilMs = 0
            end
            Project.Tracker:RefreshScheduler()
            Project.HUD:Refresh()
        end,
    })

    if lib.ST_SECTION then
        settings:AddSetting({ type = lib.ST_SECTION, label = "HUD Layout" })
    end
    settings:AddSetting({
        type = lib.ST_SLIDER,
        label = "HUD scale",
        min = 50, max = 300, step = 5,
        default = 100,
        getFunction = function() return math.floor((tonumber(Project.sv.hudScale) or 1.0) * 100) end,
        setFunction = function(value)
            Project.sv.hudScale = value / 100
            Project.HUD:ApplySettings()
        end,
        unit = "%",
        format = "%d",
    })
    settings:AddSetting({
        type = lib.ST_SLIDER,
        label = "Left inset",
        min = 0, max = 700, step = 10,
        default = 110,
        getFunction = function() return tonumber(Project.sv.leftInset) or 110 end,
        setFunction = function(value) Project.sv.leftInset = value; Project.HUD:ApplySettings() end,
        unit = "px",
        format = "%d",
    })
    settings:AddSetting({
        type = lib.ST_SLIDER,
        label = "Left vertical offset",
        min = -500, max = 500, step = 10,
        default = 0,
        getFunction = function() return tonumber(Project.sv.leftY) or 0 end,
        setFunction = function(value) Project.sv.leftY = value; Project.HUD:ApplySettings() end,
        unit = "px",
        format = "%d",
    })
    settings:AddSetting({
        type = lib.ST_SLIDER,
        label = "Right inset",
        min = 0, max = 700, step = 10,
        default = 110,
        getFunction = function() return tonumber(Project.sv.rightInset) or 110 end,
        setFunction = function(value) Project.sv.rightInset = value; Project.HUD:ApplySettings() end,
        unit = "px",
        format = "%d",
    })
    settings:AddSetting({
        type = lib.ST_SLIDER,
        label = "Right vertical offset",
        min = -500, max = 500, step = 10,
        default = 0,
        getFunction = function() return tonumber(Project.sv.rightY) or 0 end,
        setFunction = function(value) Project.sv.rightY = value; Project.HUD:ApplySettings() end,
        unit = "px",
        format = "%d",
    })

    if lib.ST_SECTION then
        settings:AddSetting({ type = lib.ST_SECTION, label = "Diagnostics" })
    end
    settings:AddSetting({
        type = lib.ST_CHECKBOX,
        label = "Debug mode",
        default = false,
        getFunction = function() return Project.sv.debug == true end,
        setFunction = function(value) Project.sv.debug = value == true end,
    })
    settings:AddSetting({
        type = lib.ST_BUTTON,
        label = "Rebuild slot cache",
        buttonText = "Rebuild",
        clickHandler = function() Project.Tracker:OnLayoutChanged() end,
    })
end
