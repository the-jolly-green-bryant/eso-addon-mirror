-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Settings.lua
-- -----------------------------------------------------------------------------
PvPCooldownTracker = PvPCooldownTracker or {}
PvPCooldownTracker.Settings = {}

local WM = WINDOW_MANAGER
local scaleBase = PvPCooldownTracker.UI.scaleBase

local panelData = {
    type        = "panel",
    name        = "PvPCooldownTracker",
    displayName = "PvPCooldownTracker",
    author      = "Awh_Lina",
    version     = PvPCooldownTracker.version,
    registerForRefresh  = true,
}

local default
local selected
local HasSelected


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
        context:SetScale(size / scaleBase)
    end
end

local function UpdateSelectedAppearance(procType)
    if not HasSelected(procType) then
        return
    end

    local setKey = selected[procType]
    local saved = PvPCooldownTracker.preferences.sets[setKey]
    if not saved then
        return
    end

    PvPCooldownTracker:SetAppearance(saved.x, saved.y, setKey)
end

local function EnsureCharacterProcType(procType)
    if type(PvPCooldownTracker.character) ~= "table" then
        PvPCooldownTracker.character = {}
    end

    if type(PvPCooldownTracker.character[procType]) ~= "table" then
        PvPCooldownTracker.character[procType] = {}
    end

    if procType == "set" then
        for key, setData in pairs(PvPCooldownTracker.Data.Sets) do
            if setData.procType == "set" and PvPCooldownTracker.character.set[key] == nil then
                PvPCooldownTracker.character.set[key] = true
            end
        end
    end

    return PvPCooldownTracker.character[procType]
end

local function GetValidSelectedKey(procType)
    if not HasSelected(procType) then
        return nil
    end

    if type(PvPCooldownTracker.preferences) ~= "table" then
        return nil
    end

    if type(PvPCooldownTracker.preferences.sets) ~= "table" then
        PvPCooldownTracker.preferences.sets = {}
    end

    local preferencesSets = PvPCooldownTracker.preferences.sets

    local key = selected[procType]
    if type(key) ~= "string" then
        return nil
    end

    if type(preferencesSets[key]) ~= "table" then
        local defaults = PvPCooldownTracker.Defaults and PvPCooldownTracker.Defaults.Get and PvPCooldownTracker.Defaults.Get()
        local defaultSet = defaults and defaults.sets and defaults.sets[key]
        if type(defaultSet) == "table" then
            preferencesSets[key] = ZO_DeepTableCopy(defaultSet)
        else
            return nil
        end
    end

    return key
end


-- ============================================================================
-- Sets
-- ============================================================================

-- Selection
default = {
    set = "-- Select a Set --",
}

local setAliases = {
    ["Two-Fanged Snake"] = "Twice-Fanged Serpent",
}

local function ResolveSetAlias(procType, key)
    if procType == "set" and type(key) == "string" and setAliases[key] ~= nil then
        return setAliases[key]
    end

    return key
end

local function IsAliasSetKey(key)
    return setAliases[key] ~= nil
end

local function BuildSortedSetEntries()
    local entries = {}
    local sets = PvPCooldownTracker.Data and PvPCooldownTracker.Data.Sets
    if type(sets) ~= "table" then
        return entries
    end

    for key, setData in pairs(sets) do
        if type(key) == "string" and type(setData) == "table" and setData.procType == "set" and not IsAliasSetKey(key) then
            entries[#entries + 1] = {
                key = key,
                description = setData.description,
            }
        end
    end

    table.sort(entries, function(a, b)
        return string.lower(a.key) < string.lower(b.key)
    end)

    return entries
end

local function GetFirstSelectableSetKey()
    local entries = BuildSortedSetEntries()
    return entries[1] and entries[1].key or nil
end

local function NormalizeSelectedSet(procType)
    if procType ~= "set" then
        return selected[procType]
    end

    if type(PvPCooldownTracker.preferences) ~= "table" or type(PvPCooldownTracker.preferences.sets) ~= "table" then
        return selected[procType]
    end

    local key = ResolveSetAlias(procType, selected[procType])
    if key ~= nil and key ~= default[procType] then
        local data = PvPCooldownTracker.Data
        if type(data) == "table" and type(data.Sets) == "table" and data.Sets[key] ~= nil then
            selected[procType] = key
            return key
        end
    end

    local fallback = GetFirstSelectableSetKey()
    selected[procType] = fallback or default[procType]
    return selected[procType]
end

selected = {
    set = default.set,
}

-- Selection
local function GetSelected(procType)
    local key = NormalizeSelectedSet(procType)
    local resolved = ResolveSetAlias(procType, key)
    if resolved ~= key then selected[procType] = resolved end
    return selected[procType]
end
local function SetSelected(procType, selection)
    selected[procType] = ResolveSetAlias(procType, selection)
    NormalizeSelectedSet(procType)

    if procType == "set" and type(PvPCooldownTracker.preferences) == "table" then
        local key = selected[procType]
        if type(key) == "string" and key ~= "" and key ~= default[procType] then
            PvPCooldownTracker.preferences.lastSelectedSet = key
        end
    end
end

HasSelected = function(procType)
    if type(selected) ~= "table" or type(default) ~= "table" then
        return false
    end

    local key = ResolveSetAlias(procType, selected[procType])
    selected[procType] = key

    key = NormalizeSelectedSet(procType)
    if key == nil or key == default[procType] then
        return false
    end

    if procType == "set" then
        local preferences = PvPCooldownTracker.preferences
        if type(preferences) == "table" and type(preferences.sets) == "table" and preferences.sets[key] ~= nil then
            return true
        end

        local data = PvPCooldownTracker.Data
        return type(data) == "table" and type(data.Sets) == "table" and data.Sets[key] ~= nil
    end

    return true
end
local function GetSelectedXPos(procType)
    local key = GetValidSelectedKey(procType)
    if key then
        return PvPCooldownTracker.preferences.sets[key].x
    else
        return PvPCooldownTracker.preferences.TextureLocation.x
    end
end
local function SetSelectedXPos(procType, x)
    local key = GetValidSelectedKey(procType)
    if not key then return end

    PvPCooldownTracker.preferences.sets[key].x = x
end
local function GetSelectedYPos(procType)
    local key = GetValidSelectedKey(procType)
    if key then
        return PvPCooldownTracker.preferences.sets[key].y
    else
        return PvPCooldownTracker.preferences.TextureLocation.y
    end
end
local function SetSelectedYPos(procType, y)
    local key = GetValidSelectedKey(procType)
    if not key then return end
    PvPCooldownTracker.preferences.sets[key].y = y
end
-- Enabled
local function GetSelectedEnabled(procType)
    local key = GetValidSelectedKey(procType)
    if not key then
        return false
    end

    local procTable = EnsureCharacterProcType(procType)
    if procTable[key] == nil then
        procTable[key] = true
    end

    return procTable[key]
end

local function SetSelectedEnabled(procType, state)
    local key = GetValidSelectedKey(procType)
    if not key then return end

    local procTable = EnsureCharacterProcType(procType)
    PvPCooldownTracker:Trace(0, 'SetSelectedEnabled key=<<1>> state=<<2>>', key, tostring(state))

    if procType == "set" then
        if procTable[key] == false and state == true then
            -- A set was forced disable, now it's on
            PvPCooldownTracker:Trace(0, 'Re-enabling <<1>>.', key)
        elseif state == false then
            PvPCooldownTracker:Trace(0, 'Forcing tracking off for <<1>>. It will not be tracked until you enable it again.', key)
        else
            PvPCooldownTracker:Trace(1, 'Setting <<1>> to <<2>>', key, tostring(state))
        end
    end

    procTable[key] = state
    if PvPCooldownTracker.Tracking and type(PvPCooldownTracker.Tracking.EnableTrackingForSet) == "function" then
        PvPCooldownTracker.Tracking.EnableTrackingForSet(key, state)
    end

    local setData = PvPCooldownTracker.Data and PvPCooldownTracker.Data.Sets and PvPCooldownTracker.Data.Sets[key]
    if setData then
        setData.enabled = state
        if not state then
            setData.onCooldown = false
        end
    end

    if PvPCooldownTracker.UI and type(PvPCooldownTracker.UI.Draw) == "function" then
        PvPCooldownTracker.UI.Draw(key)
        local context = WM:GetControlByName(key .. "_Container")
        if context ~= nil and state then
            context:SetHidden(false)
        end
        if state and type(PvPCooldownTracker.UI.ShowIcon) == "function" then
            PvPCooldownTracker.UI.ShowIcon(true)
        end
        if type(PvPCooldownTracker.UI.SetCombatStateDisplay) == "function" then
            PvPCooldownTracker.UI:SetCombatStateDisplay()
        end
    end

    if state and not PvPCooldownTracker.preferences.showOutsideCombat and not PvPCooldownTracker.isInCombat then
        PvPCooldownTracker:Trace(0, '<<1>> enabled. Visibility is currently combat-only.', key)
    end
end

-- Size
local function GetSelectedSize(procType)
    local key = GetValidSelectedKey(procType)
    if key then
        return PvPCooldownTracker.preferences.sets[key].size
    else
        return PvPCooldownTracker.preferences.size
    end
end

local function SetSelectedSize(procType, size)
    local key = GetValidSelectedKey(procType)
    if not key then return end

    PvPCooldownTracker.preferences.sets[key].size = size
    SetSize(key, size)
end

-- Sounds
local function GetSelectedSoundOnProcEnabled(procType)
    local key = GetValidSelectedKey(procType)
    if not key then
        return PvPCooldownTracker.preferences.sounds.onProc.enabled
    end

    return PvPCooldownTracker.preferences.sets[key].sounds.onProc.enabled
end

local function SetSelectedSoundOnProcEnabled(procType, enabled)
    local key = GetValidSelectedKey(procType)
    if not key then return end

    PvPCooldownTracker.preferences.sets[key].sounds.onProc.enabled = enabled
end

local function GetSelectedSoundOnReadyEnabled(procType)
    local key = GetValidSelectedKey(procType)
    if not key then
        return PvPCooldownTracker.preferences.sounds.onReady.enabled
    end

    return PvPCooldownTracker.preferences.sets[key].sounds.onReady.enabled
end

local function SetSelectedSoundOnReadyEnabled(procType, enabled)
    local key = GetValidSelectedKey(procType)
    if not key then return end

    PvPCooldownTracker.preferences.sets[key].sounds.onReady.enabled = enabled
end

local function GetSelectedSoundOnProc(procType)
    local key = GetValidSelectedKey(procType)
    if not key then
        return PvPCooldownTracker.preferences.sounds.onProc.sound
    end

    return PvPCooldownTracker.preferences.sets[key].sounds.onProc.sound
end

local function SetSelectedSoundOnProc(procType, sound)
    local key = GetValidSelectedKey(procType)
    if not key then return end

    PvPCooldownTracker.preferences.sets[key].sounds.onProc.sound = sound
end

local function GetSelectedSoundOnReady(procType)
    local key = GetValidSelectedKey(procType)
    if not key then
        return PvPCooldownTracker.preferences.sounds.onReady.sound
    end

    return PvPCooldownTracker.preferences.sets[key].sounds.onReady.sound
end

local function SetSelectedSoundOnReady(procType, sound)
    local key = GetValidSelectedKey(procType)
    if not key then return end

    PvPCooldownTracker.preferences.sets[key].sounds.onReady.sound = sound
end

-- Test Sound
local function PlaySelectedTestSound(procType, condition)
    local key = GetValidSelectedKey(procType)
    if not key then return end

    local sound = PvPCooldownTracker.preferences.sets[key].sounds[condition]

    PvPCooldownTracker:Trace(2, "Testing sound <<1>>", sound)

    PvPCooldownTracker.UI.PlaySound(sound)
end

-- Disabled Controls
local function ShouldOptionBeEnabled(procType, consider)
    return false

end
local function ShouldOptionBeDisabled(procType, consider)
    if not GetValidSelectedKey(procType) then
        return true
    end

    if consider ~= nil and not consider then
        return true
    end

    return false
end

-- ============================================================================
-- Create Menu
-- ============================================================================

-- Initialize
function PvPCooldownTracker.Settings.Init()

    -- Copy key/value table to index/value table
    local settingsBreakout = {
        set = {
            name = "|cCD5031Sets (Select 1 to change the X, Y position)|r",
            data = {default.set},
            description = {"Select a set to customize."},
        }
    }

    local sortedSetEntries = BuildSortedSetEntries()
    for i = 1, #sortedSetEntries do
        local entry = sortedSetEntries[i]
        table.insert(settingsBreakout.set.data, entry.key)
        table.insert(settingsBreakout.set.description, entry.description)
    end

    for key, set in pairs(PvPCooldownTracker.Data.Sets) do
        if set.procType ~= "set" then
            PvPCooldownTracker:Trace(1, "Invalid procType: <<1>>", set.procType)
        end
    end

    if type(PvPCooldownTracker.preferences) == "table" then
        local lastSelectedSet = ResolveSetAlias("set", PvPCooldownTracker.preferences.lastSelectedSet)
        if type(lastSelectedSet) == "string"
            and lastSelectedSet ~= ""
            and lastSelectedSet ~= default.set
            and PvPCooldownTracker.Data
            and PvPCooldownTracker.Data.Sets
            and PvPCooldownTracker.Data.Sets[lastSelectedSet]
        then
            selected.set = lastSelectedSet
        end
    end

    if selected.set == default.set or not HasSelected("set") then
        selected.set = GetFirstSelectableSetKey() or default.set
    end

    local optionsTable = {
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
                            UpdateSelectedAppearance(procType)
                         end,
                        min = 0,
                        max = 10,
                        step = 0.01,
                        clampInput = true,
                        decimals = 1,
                        width = "full",
                    },
                    {
                        type = "slider",
                        name = "Label X position",
                        tooltip = "Change X positioning on label",
                        min = 0,
                        max = GuiRoot:GetWidth(),
                        step = 10,
                        getFunc = function() return PvPCooldownTracker.preferences.LabelLocation.x end,
                        setFunc = function(value) 
                            PvPCooldownTracker.preferences.LabelLocation.x = value
                            UpdateSelectedAppearance(procType)
                        end,
                    },
                    {
                        type = "slider",
                        name = "Label Y position",
                        tooltip = "Change Y positioning on label",
                        min = 0,
                        max = GuiRoot:GetHeight(),
                        step = 10,
                        getFunc = function() return PvPCooldownTracker.preferences.LabelLocation.y end,
                        setFunc = function(value) 
                            PvPCooldownTracker.preferences.LabelLocation.y = value
                            UpdateSelectedAppearance(procType)
                        end,
                    },
                    {
                        type = "dropdown",
                        name = "Option",
                        choices = options.data,
                        getFunc = function() return GetSelected(procType) end,
                        setFunc = function(set) SetSelected(procType, set) end,
                        choicesTooltips = options.description,
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
                    },
                    {
                        type = "slider",
                        name = "X Position",
                        getFunc = function() return GetSelectedXPos(procType) end,
                        setFunc = function(x) SetSelectedXPos(procType, x) UpdateSelectedAppearance(procType) end,
                        min = 0,
                        max = GuiRoot:GetWidth(),
                        step = 10,
                        default = 640,
                        clampInput = true,
                        decimals = 0,
                        tooltip = "X Position on screen",
                        width = "full",
                    },
                    {
                        type = "slider",
                        name = "Y Position",
                        getFunc = function() return GetSelectedYPos(procType) end,
                        setFunc = function(y) SetSelectedYPos(procType, y) UpdateSelectedAppearance(procType) end,
                        min = 0,
                        max = GuiRoot:GetHeight(),
                        step = 10,
                        default = 300,
                        clampInput = true,
                        decimals = 0,
                        tooltip = "Y Position on screen",
                        width = "full",
                    },
                    {
                        type = "description",
                        text = "Setting ON or OFF is account-wide. All other settings (such as size, sounds, and position) also apply account-wide.",
                        width = "full",
                    },
                    {
                        type = "slider",
                        name = "Size",
                        getFunc = function() return GetSelectedSize(procType) end,
                        setFunc = function(size) SetSelectedSize(procType, size) UpdateSelectedAppearance(procType) end,
                        min = 0,
                        max = 260,
                        step = 10,
                        clampInput = true,
                        decimals = 0,
                        default = 64,
                        width = "full",
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

    -- Equipped Set Scanner submenu (provided by EquippedSets.lua)
    if PvPCooldownTracker.EquippedSets and type(PvPCooldownTracker.EquippedSets.BuildLAMControls) == "function" then
        table.insert(optionsTable, {
            type     = "submenu",
            name     = "|c92C843Equipped Set Scanner|r",
            controls = PvPCooldownTracker.EquippedSets.BuildLAMControls(),
        })
    end

    local addonId = PvPCooldownTracker.name or panelData.name or "PvPCooldownTracker"
    if type(addonId) ~= "string" or addonId == "" then
        addonId = "PvPCooldownTracker"
    end

    local lam = LibAddonMenu2
    if type(lam) ~= "table" then
        d((PvPCooldownTracker.prefix or "[PvPCooldownTracker] ") .. "LibAddonMenu-2.0 is not available. Settings panel was not registered.")
        return
    end

    local registerAddonPanel = lam.RegisterAddonPanel
    local registerOptionControls = lam.RegisterOptionControls
    if type(registerAddonPanel) ~= "function" or type(registerOptionControls) ~= "function" then
        d((PvPCooldownTracker.prefix or "[PvPCooldownTracker] ") .. "LibAddonMenu-2.0 API mismatch. Settings panel was not registered.")
        return
    end

    registerAddonPanel(lam, addonId, panelData)
    registerOptionControls(lam, addonId, optionsTable)

    if type(PvPCooldownTracker.Trace) == "function" then
        PvPCooldownTracker:Trace(2, "Finished InitSettings()")
    end
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

