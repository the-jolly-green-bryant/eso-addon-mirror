ArchdruidTracker = ArchdruidTracker or { }
local ArchdruidTracker = ArchdruidTracker

function ArchdruidTracker.setupMenu()
	local LAM = LibAddonMenu2
	local LCA = LibCombatAlerts

	local panelData = {
		type = "panel",
		name = ArchdruidTracker.name,
		displayName = "|cFFD700"..ArchdruidTracker.name.."|r",
		author = "tmbrinks",
		version = ""..ArchdruidTracker.version,
		registerForRefresh = true
	}

	LAM:RegisterAddonPanel(ArchdruidTracker.name.."Options", panelData)

    local movementHide = function(hide)
        if not hide then
            EVENT_MANAGER:UnregisterForEvent(ArchdruidTracker.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE)
            ArchdruidTrackerFrame:SetHidden(false)
            ArchdruidTrackerFrame:SetMovable(true)
            ArchdruidTrackerFrame:SetMouseEnabled(true)
        else
            EVENT_MANAGER:RegisterForEvent(ArchdruidTracker.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, ArchdruidTracker.hideFrame)
            ArchdruidTrackerFrame:SetHidden(IsReticleHidden())
            ArchdruidTrackerFrame:SetMovable(false)
            ArchdruidTrackerFrame:SetMouseEnabled(false)
        end
    end

    local gpMovement = false
    local movementOption
    if (IsConsoleUI()) then
        ArchdruidTracker.posHandler:RegisterCallback("GamepadMovementCleanup", LCA.EVENT_CONTROL_MOVE_STOP, function()
            if (gpMovement) then
                gpMovement = false
                movementHide(true)
            end
        end)
        movementOption = {
            type = "button",
            name = "Move UI",
			tooltip = "Use the right stick to move.  Movement ends when there has been no input for 3s.",
            func = function()
                movementHide(false)
                gpMovement = true
                ArchdruidTracker.posHandler:ToggleGamepadMove(true)
            end

        }
    else
        movementOption = {
            type = "checkbox",
            name = "Lock UI",
            tooltip = "Unlock to position timer in desired location",
            getFunc = function() return true end,
            setFunc = movementHide,
        }
    end

	local options = {
		{
			type = "header",
			name = "Positioning"
		},
		movementOption,
		{
			type = "header",
			name = "Options"
		},
		{
			type = "slider",
			name = "Text Size",
			tooltip = "Size of the displayed timer",
			min = 20,
			max = 100,
			getFunc = function() return ArchdruidTracker.savedVars.timerSize end,
			setFunc = function(value)
				ArchdruidTracker.savedVars.timerSize = value
				ArchdruidTracker.setFontSize(value)
			end
		},
		{
			type = "checkbox",
			name = "Only Display In Combat",
			tooltip = "Only displays timer when the player is in combat",
			getFunc = function() return ArchdruidTracker.savedVars.passiveHide end,
			setFunc = function(value)
				ArchdruidTracker.savedVars.passiveHide = value
				ArchdruidTracker.hideOutOfCombat()
			end
		},
		{
			type = "colorpicker",
			name = "Available Color",
			tooltip = "Color of timer when ArchdruidTracker proc is available",
			warning = "Color changes go into effect next time timer changes color",
			getFunc = function() return unpack(ArchdruidTracker.savedVars.COLORS.UP) end,
			setFunc = function(r,g,b,a) ArchdruidTracker.savedVars.COLORS.UP = {r,g,b,a} end,
		},
		{
			type = "colorpicker",
			name = "Cooldown Color",
			tooltip = "Color of timer when ArchdruidTracker proc is currently on cooldown",
			warning = "Color changes go into effect next time timer changes color",
			getFunc = function() return unpack(ArchdruidTracker.savedVars.COLORS.DOWN) end,
			setFunc = function(r,g,b,a) ArchdruidTracker.savedVars.COLORS.DOWN = {r,g,b,a} end,
		},
		{
			type = "colorpicker",
			name = "Warning Color",
			tooltip = "Color of timer when ArchdruidTracker proc is close to being able to proc again",
			warning = "Color changes go into effect next time timer changes color",
			getFunc = function() return unpack(ArchdruidTracker.savedVars.COLORS.WARNING) end,
			setFunc = function(r,g,b,a) ArchdruidTracker.savedVars.COLORS.WARNING = {r,g,b,a} end,
		},
		{
			type = "colorpicker",
			name = "Other Person Color",
			tooltip = "Color of timer when ArchdruidTracker is proced by someone else",
			warning = "Color changes go into effect next time timer changes color",
			getFunc = function() return unpack(ArchdruidTracker.savedVars.COLORS.OTHER) end,
			setFunc = function(r,g,b,a) ArchdruidTracker.savedVars.COLORS.OTHER = {r,g,b,a} end,
		},
	}

	LAM:RegisterOptionControls(ArchdruidTracker.name.."Options", options)
end
