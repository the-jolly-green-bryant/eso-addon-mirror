-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Settings.lua
-- -----------------------------------------------------------------------------

PvPCooldownTracker.Settings = {}

local WM = WINDOW_MANAGER
local LAM = LibAddonMenu2
local scaleBase = PvPCooldownTracker.UI.scaleBase

local panelData = {
    type        = "panel",
    name        = "PvPCooldownTracker",
    displayName = "PvPCooldownTracker",
    author      = "Awh_Lina",
    version     = PvPCooldownTracker.version,
    registerForRefresh  = true,
}


-- ============================================================================
-- Global Options
-- ============================================================================

-- Grid Options
local function GetSnapToGrid()
    return PvPCooldownTracker.preferences.snapToGrid
end

local function SetSnapToGrid(snap)
    PvPCooldownTracker.preferences.snapToGrid = snap
end

local function GetGridSize()
    return PvPCooldownTracker.preferences.gridSize
end

local function SetGridSize(gridSize)
    PvPCooldownTracker.preferences.gridSize = gridSize
end

-- Locked State
local function ToggleLocked(control)
    PvPCooldownTracker.preferences.unlocked = not PvPCooldownTracker.preferences.unlocked
    for key, set in pairs(PvPCooldownTracker.Data.Sets) do
        local context = WM:GetControlByName(key .. "_Container")
        if context ~= nil then
            context:SetMovable(PvPCooldownTracker.preferences.unlocked)
            if PvPCooldownTracker.preferences.unlocked then
                control:SetText("Lock All")
            else
                control:SetText("Unlock All")
            end
        end
    end
end

-- Force Showing
local function ForceShow(control)
    PvPCooldownTracker.ForceShow = not PvPCooldownTracker.ForceShow

    if PvPCooldownTracker.ForceShow then
        control:SetText("Hide All Enabled")
        PvPCooldownTracker.HUDHidden = false
        PvPCooldownTracker.UI.ShowIcon(true)
    else
        control:SetText("Show All Enabled")
        PvPCooldownTracker.HUDHidden = true
        PvPCooldownTracker.UI.ShowIcon(false)
    end

end

-- Combat State Display
local function GetShowOutOfCombat()
    return PvPCooldownTracker.preferences.showOutsideCombat
end

local function SetShowOutOfCombat(value)
    PvPCooldownTracker.preferences.showOutsideCombat = value
    PvPCooldownTracker.UI:SetCombatStateDisplay()

    if value then
        PvPCooldownTracker.Tracking.UnregisterCombatEvent()
    else
        PvPCooldownTracker.Tracking.RegisterCombatEvent()
    end
end

-- Lag Compensation
local function GetLagCompensation()
    return PvPCooldownTracker.preferences.lagCompensation
end

local function SetLagCompensation(value)
    PvPCooldownTracker.preferences.lagCompensation = value
end

-- Sizing
local function SetSize(setKey, size)
    local context = WM:GetControlByName(setKey .. "_Container")

    PvPCooldownTracker.preferences.sets[setKey].size = size

    if context ~= nil then
        context:SetScale(size)
    end
end


-- ============================================================================
-- Sets
-- ============================================================================

-- Selection
local default = {
    set = "-- Select a Set --",
}

local selected = {
    set = default.set,
}

-- Selection
local function GetSelected(procType)
    return selected[procType]
end
local function SetSelected(procType, selection)
    selected[procType] = selection
end

local function HasSelected(procType)
    if selected[procType] ~= default[procType] then
        return true
    else
        return false
    end
end
local function GetSelectedXPos(procType)
    if HasSelected(procType) then
        return PvPCooldownTracker.preferences.sets[selected[procType]].x
    else
        return PvPCooldownTracker.preferences.TextureLocation.x
    end
end
local function SetSelectedXPos(procType, x)
    PvPCooldownTracker.preferences.sets[selected[procType]].x = x
end
local function GetSelectedYPos(procType)
    if HasSelected(procType) then
        return PvPCooldownTracker.preferences.sets[selected[procType]].y
    else
        return PvPCooldownTracker.preferences.TextureLocation.y
    end
end
local function SetSelectedYPos(procType, y)
    PvPCooldownTracker.preferences.sets[selected[procType]].y = y
end
-- Enabled
local function GetSelectedEnabled(procType)
    if HasSelected(procType) then
        return PvPCooldownTracker.character[procType][selected[procType]]
    else
        return false
    end
end

local function SetSelectedEnabled(procType, state)
    if procType == "set" then
        if PvPCooldownTracker.character[procType][selected[procType]] == false and state == true then
            -- A set was forced disable, now it's on
            -- Notify player to re-equip
            PvPCooldownTracker:Trace(0, 'Re-enabling <<1>>. You may need to take off and re-equip this set to resume tracking.', selected[procType])
            PvPCooldownTracker.character[procType][selected[procType]] = true
            return
        elseif state == false then
            PvPCooldownTracker:Trace(0, 'Forcing tracking off for <<1>>. It will not be tracked until you enable it again.', selected[procType])
        else
            PvPCooldownTracker:Trace(1, 'Setting <<1>> to <<2>>', selected[procType], tostring(state))
        end
    end

    PvPCooldownTracker.character[procType][selected[procType]] = state
    PvPCooldownTracker.Tracking.EnableTrackingForSet(selected[procType], state)
end

-- Size
local function GetSelectedSize(procType)
    if HasSelected(procType) then
        return PvPCooldownTracker.preferences.sets[selected[procType]].size
    else
        return PvPCooldownTracker.preferences.size
    end
end

local function SetSelectedSize(procType, size)
    PvPCooldownTracker.preferences.sets[selected[procType]].size = size
    SetSize(selected[procType], size)
end

-- Sounds
local function GetSelectedSoundOnProcEnabled(procType)
    if HasSelected(procType) then
        return PvPCooldownTracker.preferences.sets[selected[procType]].sounds.onProc.enabled
    else
        return PvPCooldownTracker.preferences.sounds.onProc.enabled
    end
end

local function SetSelectedSoundOnProcEnabled(procType, enabled)
    PvPCooldownTracker.preferences.sets[selected[procType]].sounds.onProc.enabled = enabled
end

local function GetSelectedSoundOnReadyEnabled(procType)
    if HasSelected(procType) then
        return PvPCooldownTracker.preferences.sets[selected[procType]].sounds.onReady.enabled
    else
        return PvPCooldownTracker.preferences.sounds.onReady.enabled
    end
end

local function SetSelectedSoundOnReadyEnabled(procType, enabled)
    PvPCooldownTracker.preferences.sets[selected[procType]].sounds.onReady.enabled = enabled
end

local function GetSelectedSoundOnProc(procType)
    if HasSelected(procType) then
        return PvPCooldownTracker.preferences.sets[selected[procType]].sounds.onProc.sound
    else
        return PvPCooldownTracker.preferences.sounds.onProc.sound
    end
end

local function SetSelectedSoundOnProc(procType, sound)
    PvPCooldownTracker.preferences.sets[selected[procType]].sounds.onProc.sound = sound
end

local function GetSelectedSoundOnReady(procType)
    if HasSelected(procType) then
        return PvPCooldownTracker.preferences.sets[selected[procType]].sounds.onReady.sound
    else
        return PvPCooldownTracker.preferences.sounds.onReady.sound
    end
end

local function SetSelectedSoundOnReady(procType, sound)
    PvPCooldownTracker.preferences.sets[selected[procType]].sounds.onReady.sound = sound
end

-- Test Sound
local function PlaySelectedTestSound(procType, condition)
    local sound = PvPCooldownTracker.preferences.sets[selected[procType]].sounds[condition]

    PvPCooldownTracker:Trace(2, "Testing sound <<1>>", sound)

    PvPCooldownTracker.UI.PlaySound(sound)
end

-- Disabled Controls
local function ShouldOptionBeEnabled(procType, consider)
    return false

end
local function ShouldOptionBeDisabled(procType, consider)
    -- Nothing selected, always disable
    if not HasSelected(procType) then
        return true

    -- Something selected
    else

        -- If disabled, disable all fields
        if not GetSelectedEnabled(procType) then
            return true
        end

        -- If our other consideration says to disable, do it
        if consider ~= nil and not consider then
            return true
        end

    end

end

-- ============================================================================
-- Create Menu
-- ============================================================================

-- Initialize
function PvPCooldownTracker.Settings.Init()

    -- Copy key/value table to index/value table
    local settingsBreakout = {
        set = {
            name = "|cCD5031Sets|r",
            data = {default.set},
            description = {"Select a set to customize."},
        }
    }

    for key, set in pairs(PvPCooldownTracker.Data.Sets) do
        if set.procType == "set" then
            table.insert(settingsBreakout.set.data, key)
            table.insert(settingsBreakout.set.description, set.description)
        else
            PvPCooldownTracker:Trace(1, "Invalid procType: <<1>>", set.procType)
        end
    end

    optionsTable = {
        {
            type = "header",
            name = "Global Settings",
            width = "full",
        },
        {
            type = "editbox",
            name = "Cooldown Expired Text",
            tooltip = "Edit the cooldown expired text",
            getFunc = function() return PvPCooldownTracker.preferences.cooldown_expired end,
            setFunc = function(text) PvPCooldownTracker.preferences.cooldown_expired = text end,
            default = "FFFF00",	--(optional)
        },
        {
            type = "editbox",
            name = "Cooldown Started Text",
            tooltip = "Edit the cooldown expired text",
            getFunc = function() return PvPCooldownTracker.preferences.set_active end,
            setFunc = function(text) PvPCooldownTracker.preferences.set_active = text end,
            default = "3CB043",	--(optional)
        },
        {
            type = "checkbox",
            name = "Lag Compensation",
            tooltip = "Attempt to adjust proc timing based on lag conditions. Set to ON if you are falsely seeing back-to-back procs and set to OFF if procs in close proximity to being ready are being missed.",
            getFunc = function() return GetLagCompensation() end,
            setFunc = function(value) SetLagCompensation(value) end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show Outside of Combat",
            tooltip = "Set to ON to show while out of combat and OFF to only show while in combat.",
            getFunc = function() return GetShowOutOfCombat() end,
            setFunc = function(value) SetShowOutOfCombat(value) end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Snap to Grid",
            tooltip = "Set to ON to snap position to the specified grid.",
            getFunc = function() return GetSnapToGrid() end,
            setFunc = function(value) SetSnapToGrid(value) end,
            width = "full",
        },
        {
            type = "slider",
            name = "Grid Size",
            tooltip = "Grid dimensions to snap positioning of display elements to.",
            getFunc = function() return GetGridSize() end,
            setFunc = function(size) SetGridSize(size) end,
            min = 1,
            max = 100,
            step = 1,
            clampInput = true,
            decimals = 0,
            width = "full",
            disabled = function() return not GetSnapToGrid() end,
        },
        {
            type = "divider",
            width = "full",
            height = 16,
            alpha = 0.25,
        }
    }
    for procType, options in pairs(settingsBreakout) do
        table.insert(optionsTable, {
                type = "submenu",
                name = options.name,
                controls = {
                    {
                        type = "slider",
                        name = "Label Size",
                        tooltip = "Grid dimensions to snap positioning of display elements to.",
                        getFunc = function() return PvPCooldownTracker.preferences.labelSize end,
                        setFunc = function(size) 
                            PvPCooldownTracker.preferences.labelSize = size
                            PvPCooldownTracker:SetAppearance(PvPCooldownTracker.preferences.LabelLocation.x, PvPCooldownTracker.preferences.LabelLocation.y, selected[procType])
                         end,
                        min = 0,
                        max = 10,
                        step = 0.5,
                        clampInput = true,
                        decimals = 1,
                        width = "full",
                        disabled = false,
                    },
                    {
                        type = "slider",
                        name = "Label X position",
                        tooltip = "Change X positioning on label",
                        min = 0,
                        max = 1920,
                        step = 10,
                        getFunc = function() return PvPCooldownTracker.preferences.LabelLocation.x end,
                        setFunc = function(value) 
                            PvPCooldownTracker.preferences.LabelLocation.x = value
                            PvPCooldownTracker:SetAppearance(PvPCooldownTracker.preferences.LabelLocation.x, PvPCooldownTracker.preferences.LabelLocation.y, selected[procType])
                        end,
                        disabled = false
                    },
                    {
                        type = "slider",
                        name = "Label Y position",
                        tooltip = "Change Y positioning on label",
                        min = 0,
                        max = 1080,
                        step = 10,
                        getFunc = function() return PvPCooldownTracker.preferences.LabelLocation.y end,
                        setFunc = function(value) 
                            PvPCooldownTracker.preferences.LabelLocation.y = value
                            PvPCooldownTracker:SetAppearance(PvPCooldownTracker.preferences.LabelLocation.x, PvPCooldownTracker.preferences.LabelLocation.y, selected[procType])
                        end,
                        disabled = false
                    },
                    {
                        type = "dropdown",
                        name = "Option",
                        choices = options.data,
                        getFunc = function() return GetSelected(procType) end,
                        setFunc = function(set) SetSelected(procType, set) end,
                        choicesTooltips = options.description,
                        sort = "name-up",
                        width = "full",
                        scrollable = true,
                    },
                    {
                        type = "checkbox",
                        name = "Enable Tracking",
                        tooltip = "Set to ON to enable tracking. Note: Sets will still disable automatically when not worn.",
                        getFunc = function() return GetSelectedEnabled(procType) end,
                        setFunc = function(value) SetSelectedEnabled(procType, value) end,
                        width = "full",
                        disabled = function() return not HasSelected(procType) end,
                    },
                    {
                        type = "slider",
                        name = "X Position",
                        getFunc = function() return GetSelectedXPos(procType) end,
                        setFunc = function(x) SetSelectedXPos(procType, x) PvPCooldownTracker:SetAppearance(PvPCooldownTracker.preferences.sets[selected[procType]].x, PvPCooldownTracker.preferences.sets[selected[procType]].y, selected[procType]) end,
                        min = 0,
                        max = 3840,
                        step = 10,
                        default = 640,
                        clampInput = true,
                        decimals = 0,
                        tooltip = "X Position on screen",
                        disabled = function() ShouldOptionBeDisabled(procType) end,
                        width = "full",
                    },
                    {
                        type = "slider",
                        name = "Y Position",
                        getFunc = function() return GetSelectedYPos(procType) end,
                        setFunc = function(y) SetSelectedYPos(procType, y) PvPCooldownTracker:SetAppearance(PvPCooldownTracker.preferences.sets[selected[procType]].x, PvPCooldownTracker.preferences.sets[selected[procType]].y, selected[procType]) end,
                        min = 0,
                        max = 2160,
                        step = 10,
                        default = 300,
                        clampInput = true,
                        decimals = 0,
                        tooltip = "Y Position on screen",
                        disabled = function() ShouldOptionBeDisabled(procType) end,
                        width = "full",
                    },
                    {
                        type = "description",
                        text = "Setting ON or OFF is per-character. All other settings (such as size, sounds, and position) apply account-wide.",
                        width = "full",
                    },
                    {
                        type = "slider",
                        name = "Size",
                        getFunc = function() return GetSelectedSize(procType) end,
                        setFunc = function(size) SetSelectedSize(procType, size) PvPCooldownTracker:SetAppearance(PvPCooldownTracker.preferences.sets[selected[procType]].x, PvPCooldownTracker.preferences.sets[selected[procType]].y, selected[procType]) end,
                        min = 0,
                        max = 260,
                        step = 10,
                        clampInput = true,
                        decimals = 0,
                        default = 64,
                        width = "full",
                        disabled = function() ShouldOptionBeDisabled(procType) end,
                    },
                    {
                        type = "checkbox",
                        name = "Play Sound On Proc",
                        tooltip = "Set to ON to play a sound when the set procs.",
                        getFunc = function() return GetSelectedSoundOnProcEnabled(procType) end,
                        setFunc = function(value) SetSelectedSoundOnProcEnabled(procType, value) end,
                        width = "full",
                        disabled = function() return ShouldOptionBeDisabled(procType) end,
                    },
                    {
                        type = "dropdown",
                        name = "Sound On Proc",
                        choices = PvPCooldownTracker.Sounds.names,
                        choicesValues = PvPCooldownTracker.Sounds.options,
                        getFunc = function() return GetSelectedSoundOnProc(procType) end,
                        setFunc = function(value) SetSelectedSoundOnProc(procType, value) end,
                        tooltip = "Sound volume based on Interface volume setting.",
                        sort = "name-up",
                        width = "full",
                        scrollable = true,
                        disabled = function() return ShouldOptionBeDisabled(procType, GetSelectedSoundOnProcEnabled(procType)) end,
                    },
                    {
                        type = "button",
                        name = "Test Sound",
                        func = function() PlaySelectedTestSound(procType, "onProc") end,
                        width = "full",
                        disabled = function() return ShouldOptionBeDisabled(procType, GetSelectedSoundOnProcEnabled(procType)) end,
                    },
                    {
                        type = "checkbox",
                        name = "Play Sound On Ready",
                        tooltip = "Set to ON to play a sound when the set is off cooldown and ready to proc again.",
                        getFunc = function() return GetSelectedSoundOnReadyEnabled(procType) end,
                        setFunc = function(value) SetSelectedSoundOnReadyEnabled(procType, value) end,
                        width = "full",
                        disabled = function() return ShouldOptionBeDisabled(procType) end,
                    },
                    {
                        type = "dropdown",
                        name = "Sound On Ready",
                        choices = PvPCooldownTracker.Sounds.names,
                        choicesValues = PvPCooldownTracker.Sounds.options,
                        getFunc = function() return GetSelectedSoundOnReady(procType) end,
                        setFunc = function(value) SetSelectedSoundOnReady(procType, value) end,
                        tooltip = "Sound volume based on game interface volume setting.",
                        sort = "name-up",
                        width = "full",
                        scrollable = true,
                        disabled = function() return ShouldOptionBeDisabled(procType, GetSelectedSoundOnReadyEnabled(procType)) end,
                    },
                    {
                        type = "button",
                        name = "Test Sound",
                        func = function() PlaySelectedTestSound(procType, "onReady") end,
                        width = "full",
                        disabled = function() return ShouldOptionBeDisabled(procType, GetSelectedSoundOnReadyEnabled(procType)) end,
                    },
                },
        })
    end

    LAM:RegisterAddonPanel(PvPCooldownTracker.name, panelData)
    LAM:RegisterOptionControls(PvPCooldownTracker.name, optionsTable)

    PvPCooldownTracker:Trace(2, "Finished InitSettings()")
end

function PvPCooldownTracker.Settings.Upgrade()
    -- v1.1.0 changes setKey names, restore previous user settings
    if PvPCooldownTracker.preferences.upgradedv110 == nil or not PvPCooldownTracker.preferences.upgradedv110 then
        local previousSetKeys = {
            ["Lich"] = "Shroud of the Lich",
            ["Olorime"] = "Vestment of Olorime",
            ["Trappings"] = "Trappings of Invigoration",
            ["Warlock"] = "Vestments of the Warlock",
            ["Wyrd"] = "Wyrd Tree's Blessing",
        }

        for previous, new in pairs(previousSetKeys) do
            if PvPCooldownTracker.preferences.sets[previous] ~= nil then
                PvPCooldownTracker.preferences.sets[new] = PvPCooldownTracker.preferences.sets[previous]
                PvPCooldownTracker.preferences.sets[previous] = nil
            end
        end

        d("[PvPCooldownTracker] Upgraded settings to v1.1.0")
        PvPCooldownTracker.preferences.upgradedv110 = true
    end

    -- v1.6.0 changes character settings, migrate
    if PvPCooldownTracker.character.upgradedv154 == nil or not PvPCooldownTracker.character.upgradedv154 then

        for key, set in pairs(PvPCooldownTracker.Data.Sets) do
            if PvPCooldownTracker.character[key] ~= nil then
                if set.procType == "set" then
                    PvPCooldownTracker.character.set[key] = true
                else
                    -- Unsupported procType
                end

                PvPCooldownTracker.character[key] = nil
            end
        end

        PvPCooldownTracker:Trace(0, "Upgraded character settings to v1.6.0")
        PvPCooldownTracker.character.upgradedv154 = true
    end
end

