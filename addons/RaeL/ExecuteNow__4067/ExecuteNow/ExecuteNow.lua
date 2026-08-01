-- ExecuteNow.lua (Execute Sound by: RaeL_N1)

ExecuteNow = {}

-- This isn't strictly necessary, but we'll use this string later when registering events.
ExecuteNow.name = "ExecuteNow"
ExecuteNow.version = "|cFFFF00|cFF00000.5.0|r"
ExecuteNow.author = "mooNylo, Patched: PlaceHolder - Execute Sound and new features: |c00FF00@RaeL_N1|r"
ExecuteNow.description = 'Addon to notify when target\'s health is low enough to perform "Execute".'

-- Libraries
local LAM2 = LibAddonMenu2

function ExecuteNow.ApplySettings()          -- ReloadUI is no longer required for any changes to take effect.
    ExecuteNow.executeThreshold = GetExecuteThreshold()
    ExecuteNow.RestorePosition()
    ExecuteNowVisualIndicator:SetScale(ExecuteNow.VisualIndicator.Settings.Scale)
    ExecuteNowVisualIndicator:SetAlpha(ExecuteNow.VisualIndicator.Settings.Alpha)
end

ExecuteNow.VisualIndicator = ExecuteNow.VisualIndicator or {}

-- Help functions
function GetExecuteThreshold()
    return (ExecuteNow.VisualIndicator.Settings.DesiredHealthPercentage / 100)
end

ExecuteNow.ThereIsABoss = false

function ExecuteNow.CheckIfThereIsABoss()
    for i = 1, MAX_BOSSES do
        if DoesUnitExist("boss"..i) then
            return true
        end
    end
    return false
end

function ExecuteNow.UpdateIndicatorColor()
    local r = ExecuteNow.VisualIndicator.Settings.ColorRed or 1
    local g = ExecuteNow.VisualIndicator.Settings.ColorGreen or 0
    local b = ExecuteNow.VisualIndicator.Settings.ColorBlue or 0

    ExecuteNowVisualIndicatorLabel:SetColor(r, g, b, 1)
end

function ExecuteNow.IsExecutableTarget()
    local isUnitAttackable = IsUnitAttackable("reticleover")
    if isUnitAttackable ~= nil and isUnitAttackable then
        local targetCurrentPower, targetMaxPower = GetUnitPower("reticleover", POWERTYPE_HEALTH)
        if targetMaxPower < ExecuteNow.VisualIndicator.Settings.MinimumHitpointsThreshold then return false end
        return true
    else
        return false
    end
end

function ExecuteNow.GetUnitHealthPercentage()
    local targetCurrentPower, targetMaxPower = GetUnitPower("reticleover", POWERTYPE_HEALTH)
    return targetCurrentPower / targetMaxPower
end

-- UI Elements
ExecuteNow.VisualIndicator = {}
ExecuteNow.VisualIndicator.Show = false

-- Defaults
ExecuteNow.VisualIndicator.Default = {
    left = 200,
    top = 25,
    MilliSecondsToShowIndicator = 1000,
    Scale = 2,
    Alpha = 0.8,
    ReShowExecuteWhenTargetChange = false,
    OnlyShowExecuteOnBosses = false,
    MinimumHitpointsThreshold = 3000000,
    DesiredHealthPercentage = 25,
    ExecuteSound = "NONE",
    Enabled = true,
    ColorRed = 1,
    ColorGreen = 0,
    ColorBlue = 0, 
}

ExecuteNow.VisualIndicator.Settings = ExecuteNow.VisualIndicator.Settings or ExecuteNow.VisualIndicator.Default
ExecuteNow.VisualIndicator.variableVersion = 1

function ExecuteNow.OnIndicatorMoveStop()
    ExecuteNow.VisualIndicator.Settings.left = ExecuteNowVisualIndicator:GetLeft()
    ExecuteNow.VisualIndicator.Settings.top = ExecuteNowVisualIndicator:GetTop()
end

function ExecuteNow.RestorePosition()
    local left = ExecuteNow.VisualIndicator.Settings.left
    local top = ExecuteNow.VisualIndicator.Settings.top
    local scale = ExecuteNow.VisualIndicator.Settings.Scale
    local alpha = ExecuteNow.VisualIndicator.Settings.Alpha
    ExecuteNowVisualIndicator:ClearAnchors()
    ExecuteNowVisualIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    ExecuteNowVisualIndicator:SetScale(scale)
    ExecuteNowVisualIndicator:SetAlpha(alpha)
end

local executeIndicatorIdentifier = "myReallyUniqueExecuteIdentifier13377"

function ExecuteNow.HideExectureIndicator()
    ExecuteNowVisualIndicator:SetHidden(true)
    EVENT_MANAGER:UnregisterForUpdate(executeIndicatorIdentifier)
end

function ExecuteNow.ShowExecuteIndicator()
    ExecuteNowVisualIndicator:SetHidden(false)
    local soundToPlay = ExecuteNow.VisualIndicator.Settings.ExecuteSound
    if soundToPlay and soundToPlay ~= "NONE" then
        PlaySound(SOUNDS[soundToPlay])
    end
    EVENT_MANAGER:RegisterForUpdate(executeIndicatorIdentifier, ExecuteNow.VisualIndicator.Settings.MilliSecondsToShowIndicator, ExecuteNow.HideExectureIndicator)
end

-- Main Functions
function ExecuteNow.OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    if not ExecuteNow.VisualIndicator.Settings.Enabled then
        return
    end

    if ExecuteNow.IsExecutableTarget() then
        if ExecuteNow.targetHealthPercentage ~= nil 
            and ExecuteNow.targetHealthPercentage > ExecuteNow.executeThreshold 
            and powerValue / powerMax <= ExecuteNow.executeThreshold 
            and powerValue > 0 then
            ExecuteNow.ShowExecuteIndicator()
        end
        ExecuteNow.targetHealthPercentage = powerValue / powerMax
    end
end

function ExecuteNow.OnReticleTargetChange(eventCode)
    if not ExecuteNow.VisualIndicator.Settings.Enabled then
        return
    end

    ExecuteNow.targetHealthPercentage = nil

    if ExecuteNow.VisualIndicator.Settings.ReShowExecuteWhenTargetChange then
        if ExecuteNow.IsExecutableTarget() and ExecuteNow.GetUnitHealthPercentage() <= ExecuteNow.executeThreshold then
            ExecuteNow.ShowExecuteIndicator()
        end
    end
end

function ExecuteNow.OnPlayerCombatState(eventCode, inCombat)
    if not ExecuteNow.VisualIndicator.Settings.Enabled then
        return
    end

    if inCombat ~= ExecuteNow.inCombat then
        ExecuteNow.inCombat = inCombat
        if inCombat then
            EVENT_MANAGER:RegisterForEvent(ExecuteNow.name, EVENT_RETICLE_TARGET_CHANGED, ExecuteNow.OnReticleTargetChange)
            EVENT_MANAGER:RegisterForEvent(ExecuteNow.name, EVENT_POWER_UPDATE, ExecuteNow.OnPowerUpdate)
            EVENT_MANAGER:AddFilterForEvent(ExecuteNow.name, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
            EVENT_MANAGER:AddFilterForEvent(ExecuteNow.name, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "reticleover")
        else
            EVENT_MANAGER:UnregisterForUpdate(executeIndicatorIdentifier)
            ExecuteNowVisualIndicator:SetHidden(true)
            ExecuteNow.targetHealthPercentage = nil
            EVENT_MANAGER:UnregisterForEvent(ExecuteNow.name, EVENT_RETICLE_TARGET_CHANGED)
            EVENT_MANAGER:UnregisterForEvent(ExecuteNow.name, EVENT_POWER_UPDATE)
        end
    end
end

-- Settings
function ExecuteNow.CreateSettingsWindow()
    local panelData = {
        type = "panel",
        name = "ExecuteNow+",
        displayName = "|cFFFF00Execute|r|cFF0000Now+|r",
        author = "mooNylo - Patched by: PlaceHolder - Execute Sound and new features by: |c00FF00@RaeL_N1|r",
        version = ExecuteNow.version,
        slashCommand = "/executenow",
        registerForRefresh = true,
        --registerForDefaults = true,
    }

    ExecuteNow.ControlPanel = LAM2:RegisterAddonPanel("ExecuteNowControl", panelData)
    if not ExecuteNow.ControlPanel then
    end

    local optionsData = {
        [1] = {
            type = "checkbox",            -- ## Enabled "ON/OFF" by RaeL_N1(ReloadUI is no longer needed for changes to take effect) ##
            name = "Enabled",
            tooltip = "|c00FF00Enable|r/|cFF0000Disable|r this addon.",
            getFunc = function() 
                return ExecuteNow.VisualIndicator.Settings.Enabled 
            end,
            setFunc = function(newValue)
                ExecuteNow.VisualIndicator.Settings.Enabled = newValue
                ExecuteNow.ToggleAddon(newValue)
            end,
            default = true,
        },
        [2] = {
            type = "header",
            name = "|c00FF00Settings|r",
            width = "full",
        },
        [3] = {
            type = "slider",
            name = "Indicator Time",
            tooltip = "Choose how long (in milliseconds) the Execute Indicator will remain visible. Example: 1500ms = 1.5 seconds.",
            min = 500,
            max = 4000,
            step = 100,
            default = 1500,
            getFunc = function() return ExecuteNow.VisualIndicator.Settings.MilliSecondsToShowIndicator end,
            setFunc = function(newValue)
                        ExecuteNow.VisualIndicator.Settings.MilliSecondsToShowIndicator = newValue
                    end,
        },
        [4] = {
            type = "checkbox",
            name = "Show again on target change",
            tooltip = "Enable this option to make the Execute Indicator reappear whenever you switch to a target that meets the execute conditions.",
            getFunc = function() return ExecuteNow.VisualIndicator.Settings.ReShowExecuteWhenTargetChange end,
            setFunc = function(newValue) ExecuteNow.VisualIndicator.Settings.ReShowExecuteWhenTargetChange = newValue end,
            width = "full",
        },
        [5] = {
            type = "slider",
            name = "Hitpoints Threshold",
            tooltip = "Set the minimum hitpoints a target must have for the Execute Indicator to activate. Increase this value to ignore weaker enemies and focus on tougher targets like bosses.",
            min = 0,
            max = 50000000,
            step = 100000,
            default = 100000,
            getFunc = function() return ExecuteNow.VisualIndicator.Settings.MinimumHitpointsThreshold end,
            setFunc = function(newValue)
                        ExecuteNow.VisualIndicator.Settings.MinimumHitpointsThreshold = newValue
                    end,
        },
        [6] = {
            type = "slider",
            name = "Execute Percentage",
            tooltip = "Set the health percentage threshold at which the Execute Indicator should appear. Example: Set to 25% for the alert to trigger when the target's health drops below a quarter.",
            min = 0,
            max = 100,
            step = 5,
            default = 25,
            getFunc = function() return ExecuteNow.VisualIndicator.Settings.DesiredHealthPercentage end,
            setFunc = function(newValue)
                ExecuteNow.SetExecuteThreshold(newValue)
            end,
        },
        [7] = {
            type = "button",
            name = function() if ExecuteNow.VisualIndicator.Show then return "Hide" else return "|cADFF2FS|cFFFFAAh|cFFD700o|cFFA500w|r" end end,
            tooltip = "Toggle the Execute Indicator visibility. Use this option to preview its appearance and adjust its position on the screen.",
            func = function(control)
                        ExecuteNow.VisualIndicator.Show = not ExecuteNow.VisualIndicator.Show
                        ExecuteNowVisualIndicator:SetHidden(not ExecuteNow.VisualIndicator.Show)
                    end,
        },
        [8] = {
            type = "header",
            name = "|cFFFF00Extra|r",
            width = "full",
        },
        [9] = {
            type = "slider",
            name = "Indicator Size",
            tooltip = "Adjust the size of the Execute Indicator",
            min = 1,
            max = 5,
            step = 1,
            default = 2,
            getFunc = function() return ExecuteNow.VisualIndicator.Settings.Scale end,
            setFunc = function(newValue)
                        ExecuteNow.VisualIndicator.Settings.Scale = newValue
                        ExecuteNowVisualIndicator:SetScale(newValue)
                    end,
        },
        [10] = {
            type = "slider",
            name = "Indicator Opacity",
            tooltip = "Adjust the opacity of the Execute Indicator",
            min = 0,
            max = 1,
            step = 0.1,
            default = 0.5,
            getFunc = function() return ExecuteNow.VisualIndicator.Settings.Alpha end,
            setFunc = function(newValue)
                        ExecuteNow.VisualIndicator.Settings.Alpha = newValue
                        ExecuteNowVisualIndicator:SetAlpha(newValue)
                    end,
        },
        [11] = {
            type = "colorpicker",
            name = "Indicator Color",
            tooltip = "Select the color of the Execute Indicator.",
            getFunc = function() 
                return ExecuteNow.VisualIndicator.Settings.ColorRed, ExecuteNow.VisualIndicator.Settings.ColorGreen, ExecuteNow.VisualIndicator.Settings.ColorBlue
            end,
            setFunc = function(r, g, b)
                ExecuteNow.VisualIndicator.Settings.ColorRed = r
                ExecuteNow.VisualIndicator.Settings.ColorGreen = g
                ExecuteNow.VisualIndicator.Settings.ColorBlue = b
                ExecuteNow.UpdateIndicatorColor()
            end,
            default = {r = 1, g = 0, b = 0},
        },
        [12] = {
            type = "dropdown",        -- ## Execute Sound functionality by RaeL_N1 ## with preview
            name = "Execute Sound",
            tooltip = "Choose the sound to play when Execute is triggered.",
            choices = {
                "INSTANCE_SHUTDOWN",
                "BOOK_COLLECTION_COMPLETED",
                "ANTIQUITIES_FANFARE_COMPLETED",
                "CROWN_CRATES_GAIN_GEMS",
                "SCRIBING_SCRIBE_SLOT_ANIMATED",
                "SKILL_PURCHASED",
                "TRIBUTE_SUMMARY_RANK_CHANGE",
                "BATTLEGROUND_ONE_MINUTE_WARNING",
                "DUEL_START",
                "DUEL_ACCEPTED",
                "DUEL_WON",
                "NONE"
            },
            getFunc = function() return ExecuteNow.VisualIndicator.Settings.ExecuteSound end,
            setFunc = function(newValue)
                        ExecuteNow.VisualIndicator.Settings.ExecuteSound = newValue
                        -- Preview sound on selection)
                        if newValue and newValue ~= "NONE" then
                            PlaySound(SOUNDS[newValue])
                        end
                    end,
            default = "NONE",
        },
        [13] = {
            type = "button",
            name = "|cFF0000Restore Defaults|r",
            tooltip = "|cFF0000Reset all settings to their original values.|r",
            func = function()
                ExecuteNow.VisualIndicator.Settings = ZO_DeepTableCopy(ExecuteNow.VisualIndicator.Default)
                
                ExecuteNow.ApplySettings()
                ExecuteNow.RestorePosition()
                ExecuteNow.UpdateIndicatorColor()
        
                ZO_SavedVars:New(
                    "ExecuteNowSavedVariables", 
                    ExecuteNow.VisualIndicator.variableVersion, 
                    nil, 
                    ExecuteNow.VisualIndicator.Settings
                )
                
            end,
            warning = "|cFF0000This will reset all settings to their defaults!|r",
        },
    }

    LAM2:RegisterOptionControls("ExecuteNowControl", optionsData)
end

function ExecuteNow.InitiateAddon()
    EVENT_MANAGER:RegisterForEvent(ExecuteNow.name, EVENT_PLAYER_COMBAT_STATE, ExecuteNow.OnPlayerCombatState)
    EVENT_MANAGER:RegisterForEvent(ExecuteNow.name, EVENT_RETICLE_TARGET_CHANGED, ExecuteNow.OnReticleTargetChange)
    EVENT_MANAGER:RegisterForEvent(ExecuteNow.name, EVENT_POWER_UPDATE, ExecuteNow.OnPowerUpdate)
    EVENT_MANAGER:AddFilterForEvent(ExecuteNow.name, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
    EVENT_MANAGER:AddFilterForEvent(ExecuteNow.name, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "reticleover")
    ExecuteNow.inCombat = IsUnitInCombat("player")
    ExecuteNow.targetHealthPercentage = nil
    ExecuteNow.executeThreshold = GetExecuteThreshold()
end

function ExecuteNow.DisableAddon()
    EVENT_MANAGER:UnregisterForEvent(ExecuteNow.name, EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(ExecuteNow.name, EVENT_RETICLE_TARGET_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(ExecuteNow.name, EVENT_POWER_UPDATE)
    ExecuteNow.HideExectureIndicator()
end

function ExecuteNow.ToggleAddon(enabled)
    if enabled then
        ExecuteNow.VisualIndicator.Settings.Enabled = true
        ExecuteNow.InitiateAddon()
        ExecuteNow.ApplySettings()
        ExecuteNow.RestorePosition()
    else
        ExecuteNow.VisualIndicator.Settings.Enabled = false
        ExecuteNow.DisableAddon()
    end
end

-- Initialization
function ExecuteNow:Initialize()
    if ExecuteNow.VisualIndicator.Settings.Enabled then
        ExecuteNow.InitiateAddon()
    else
        ExecuteNow.DisableAddon()
    end
    
    ExecuteNow.VisualIndicator.Settings = ZO_SavedVars:New("ExecuteNowSavedVariables", ExecuteNow.VisualIndicator.variableVersion, nil, ExecuteNow.VisualIndicator.Default)
    
    ExecuteNow.ApplySettings()
    
    ExecuteNow.RestorePosition()

    ExecuteNow.UpdateIndicatorColor() 
    
    ExecuteNow.CreateSettingsWindow()
end

function ExecuteNow.SetExecuteThreshold(newValue)
    ExecuteNow.VisualIndicator.Settings.DesiredHealthPercentage = newValue
    ExecuteNow.executeThreshold = GetExecuteThreshold()
end

if ExecuteNow.VisualIndicator.Settings.Enabled then
    ExecuteNow.inCombat = IsUnitInCombat("player")
    ExecuteNow.targetHealthPercentage = nil
    ExecuteNow.executeThreshold = GetExecuteThreshold()
    
    if ExecuteNow.executeThreshold > 0 then
        EVENT_MANAGER:RegisterForEvent(ExecuteNow.name, EVENT_PLAYER_COMBAT_STATE, ExecuteNow.OnPlayerCombatState)
    end
    EVENT_MANAGER:UnregisterForEvent(ExecuteNow.name, EVENT_ADD_ON_LOADED)
end

function ExecuteNow.OnAddOnLoaded(event, addonName)
    if addonName == ExecuteNow.name then
        ExecuteNow.VisualIndicator.Settings = ZO_SavedVars:New("ExecuteNowSavedVariables", ExecuteNow.VisualIndicator.variableVersion, nil, ExecuteNow.VisualIndicator.Default)
        
        ExecuteNow.ApplySettings()
        ExecuteNow.RestorePosition()
        ExecuteNow.UpdateIndicatorColor()
        
        if ExecuteNow.VisualIndicator.Settings.Enabled then
            ExecuteNow.InitiateAddon()
        end

        ExecuteNow.CreateSettingsWindow()
    end
end

EVENT_MANAGER:RegisterForEvent(ExecuteNow.name, EVENT_ADD_ON_LOADED, ExecuteNow.OnAddOnLoaded)
