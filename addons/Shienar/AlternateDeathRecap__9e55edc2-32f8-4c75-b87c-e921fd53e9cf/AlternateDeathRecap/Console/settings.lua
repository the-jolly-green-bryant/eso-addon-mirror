ADR = ADR or {}

function ADR.InitConsoleSettings()
    
    --LHAS is an optional dependency because of the DMCA drama.
    if not LibHarvensAddonSettings then return end
		
    local settings = LibHarvensAddonSettings:AddAddon("Alternate Death Recap")

    local generalSection = {type = LibHarvensAddonSettings.ST_SECTION,label = "General",}
    local filterSection = {type = LibHarvensAddonSettings.ST_SECTION,label = "Filters",}

    local toggleCompact = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Compact Mode", 
        tooltip = "Replaces the default death recap format with a more compact version.",
        default = ADR.defaults.isCompact,
        setFunction = function(state) 
            ADR.savedVariables.isCompact = state
        end,
        getFunction = function() 
            return ADR.savedVariables.isCompact
        end,
        disable = function() return false end,
    }

    local setAnimationSpeed = {
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Animation Length",
        tooltip = "Set the length of the animation in the death recap.",
        setFunction = function(value)
				ADR.savedVariables.animationSpeed = value 
				EVENT_MANAGER:RegisterForUpdate(ADR.name.."Post Settings Change", 1500, function()
					ADR.updateExistingAnimations()
					EVENT_MANAGER:UnregisterForUpdate(ADR.name.."Post Settings Change")
				end)
        end,
        getFunction = function()
            return ADR.savedVariables.animationSpeed
        end,
        default = 250,
        min = 10,
        max = 1000,
        step = 10,
        unit = "ms", --optional unit
        format = "%d", --value format
        disable = function() return false end,
    }

    local toggleAnimationDisplaying = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Show Animation", 
        tooltip = "Shows the death recap animation. Disable to fully turn off the animation.",
        default = ADR.defaults.animationsEnabled,
        setFunction = function(state) 
            ADR.savedVariables.animationsEnabled = state
        end,
        getFunction = function() 
            return ADR.savedVariables.animationsEnabled
        end,
        disable = function() return false end,
    }



    local setMaxAttacks = {
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Max Attacks",
        tooltip = "Set the limit on how many attacks this addon will keep track of.",
        setFunction = function(value)
            ADR.savedVariables.maxAttacks = value
            
            while ADR.attackList.size > ADR.savedVariables.maxAttacks do
                ADR.DequeueAttack()
            end
        end,
        getFunction = function()
            return ADR.savedVariables.maxAttacks
        end,
        default = 25,
        min = 1,
        max = 50,
        step = 1,
        unit = "", --optional unit
        format = "%d", --value format
        disable = function() return false end,
    }

    local setMaxTime = {
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Max Time",
        tooltip = "The addon will only display attacks that occurred within the last X seconds.",
        setFunction = function(value)
            ADR.savedVariables.timeLength = value
        end,
        getFunction = function()
            return ADR.savedVariables.timeLength
        end,
        default = 10,
        min = 1,
        max = 60,
        step = 1,
        unit = " sec", --optional unit
        format = "%d", --value format
        disable = function() return false end,
    }

    local setSensitivity = {
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Scroll Boost",
        tooltip = "Increases the death recap's scrolling speed by X%.",
        setFunction = function(value)
            ADR.savedVariables.scrollSensitivityBoost = value
        end,
        getFunction = function()
            return ADR.savedVariables.scrollSensitivityBoost
        end,
        default = 0,
        min = 0,
        max = 1000,
        step = 10,
        unit = "%", --optional unit
        format = "%d", --value format
        disable = function() return false end,
    }

    local setHealthDisplayType = {
		type = LibHarvensAddonSettings.ST_DROPDOWN,
		label = "Health Display",
		tooltip = "Choose who the tracker will focus on.",
		items = {
			{name = "Current/Max", data = 1},
			{name = "Current", data = 2},
			{name = "Percentage", data = 3},
			{name = "None", data = 4}
		},
		getFunction = function() return ADR.savedVariables.healthDisplay or "Current/Max" end,
		setFunction = function(control, itemName, itemData)
		    ADR.savedVariables.healthDisplay = itemName
		end,
		default = 1
	}

    local trackHeals = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Heals", 
        tooltip = "Only show this event in recap when this option is set to ON.",
        default = ADR.defaults.trackHeals,
        setFunction = function(state) 
            ADR.savedVariables.trackHeals = state
        end,
        getFunction = function() 
            return ADR.savedVariables.trackHeals
        end,
        disable = function() return false end,
    }

    local trackHealAbsorb = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Heal Absorb", 
        tooltip = "Only show this event in recap when this option is set to ON.",
        default = ADR.defaults.trackHealAbsorb,
        setFunction = function(state) 
            ADR.savedVariables.trackHealAbsorb = state
        end,
        getFunction = function() 
            return ADR.savedVariables.trackHealAbsorb
        end,
        disable = function() return false end,
    }

    local trackDodged = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Dodge", 
        tooltip = "Only show this event in recap when this option is set to ON.",
        default = ADR.defaults.trackDodged,
        setFunction = function(state) 
            ADR.savedVariables.trackDodged = state
        end,
        getFunction = function() 
            return ADR.savedVariables.trackDodged
        end,
        disable = function() return false end,
    }

    local trackInterrupted = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Interrupted", 
        tooltip = "Only show this event in recap when this option is set to ON.",
        default = ADR.defaults.trackInterrupted,
        setFunction = function(state) 
            ADR.savedVariables.trackInterrupted = state
        end,
        getFunction = function() 
            return ADR.savedVariables.trackInterrupted
        end,
        disable = function() return false end,
    }

    local trackRooted = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Rooted", 
        tooltip = "Only show this event in recap when this option is set to ON.",
        default = ADR.defaults.trackRooted,
        setFunction = function(state) 
            ADR.savedVariables.trackRooted = state
        end,
        getFunction = function() 
            return ADR.savedVariables.trackRooted
        end,
        disable = function() return false end,
    }

    local trackSnared = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Snared", 
        tooltip = "Only show this event in recap when this option is set to ON.",
        default = ADR.defaults.trackSnared,
        setFunction = function(state) 
            ADR.savedVariables.trackSnared = state
        end,
        getFunction = function() 
            return ADR.savedVariables.trackSnared
        end,
        disable = function() return false end,
    }

    local trackSilenced = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Silenced", 
        tooltip = "Only show this event in recap when this option is set to ON.",
        default = ADR.defaults.trackSilenced,
        setFunction = function(state) 
            ADR.savedVariables.trackSilenced = state
        end,
        getFunction = function() 
            return ADR.savedVariables.trackSilenced
        end,
        disable = function() return false end,
    }

    local trackStunned = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Stunned", 
        tooltip = "Only show this event in recap when this option is set to ON.",
        default = ADR.defaults.trackStunned,
        setFunction = function(state) 
            ADR.savedVariables.trackStunned = state
        end,
        getFunction = function() 
            return ADR.savedVariables.trackStunned
        end,
        disable = function() return false end,
    }

    local trackFeared = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Feared", 
        tooltip = "Only show this event in recap when this option is set to ON.",
        default = ADR.defaults.trackFeared,
        setFunction = function(state) 
            ADR.savedVariables.trackFeared = state
        end,
        getFunction = function() 
            return ADR.savedVariables.trackFeared
        end,
        disable = function() return false end,
    }

    settings:AddSettings({generalSection, toggleCompact, setAnimationSpeed, toggleAnimationDisplaying, setMaxAttacks, setMaxTime, setSensitivity, setHealthDisplayType, 
                            filterSection, trackHeals, trackHealAbsorb, trackDodged, trackInterrupted, trackRooted, trackSnared, trackSilenced, trackStunned, trackFeared })
end