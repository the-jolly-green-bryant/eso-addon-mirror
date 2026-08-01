TurningTide = TurningTide or { }
local TurningTide = TurningTide

function TurningTide.setupMenu()
	local LAM = LibAddonMenu2
	local LCA = LibCombatAlerts

	local panelData = {
		type = "panel",
		name = TurningTide.name,
		displayName = "|cFFD700"..TurningTide.name.."|r",
		author = "tmbrinks",
		version = ""..TurningTide.version,
		registerForRefresh = true
	}

	LAM:RegisterAddonPanel(TurningTide.name.."Options", panelData)

	local movementHide = function(hide)
        if not hide then
            EVENT_MANAGER:UnregisterForEvent(TurningTide.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE)
            TurningTideFrame:SetHidden(false)
            TurningTideFrame:SetMovable(true)
            TurningTideFrame:SetMouseEnabled(true)
        else
            EVENT_MANAGER:RegisterForEvent(TurningTide.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, TurningTide.hideFrame)
            TurningTideFrame:SetHidden(IsReticleHidden())
            TurningTideFrame:SetMovable(false)
            TurningTideFrame:SetMouseEnabled(false)
        end
    end

    local gpMovement = false
    local movementOption
    if (IsConsoleUI()) then
        TurningTide.posHandler:RegisterCallback("GamepadMovementCleanup", LCA.EVENT_CONTROL_MOVE_STOP, function()
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
                TurningTide.posHandler:ToggleGamepadMove(true)
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
			getFunc = function() return TurningTide.savedVars.timerSize end,
			setFunc = function(value)
				TurningTide.savedVars.timerSize = value
				TurningTide.setFontSize(value)
			end
		},
		{
			type = "checkbox",
			name = "Only Display In Combat",
			tooltip = "Only displays timer when the player is in combat",
			getFunc = function() return TurningTide.savedVars.passiveHide end,
			setFunc = function(value)
				TurningTide.savedVars.passiveHide = value
				TurningTide.hideOutOfCombat()
			end
		},
		{
			type = "colorpicker",
			name = "Available Color",
			tooltip = "Color of timer when TurningTide proc is available",
			warning = "Color changes go into effect next time timer changes color",
			getFunc = function() return unpack(TurningTide.savedVars.COLORS.UP) end,
			setFunc = function(r,g,b,a) TurningTide.savedVars.COLORS.UP = {r,g,b,a} end,
		},
		{
			type = "colorpicker",
			name = "Warning Color",
			tooltip = "Color of timer when TurningTide is about to expire",
			warning = "Color changes go into effect next time timer changes color",
			getFunc = function() return unpack(TurningTide.savedVars.COLORS.WARNING) end,
			setFunc = function(r,g,b,a) TurningTide.savedVars.COLORS.WARNING = {r,g,b,a} end,
		},
		{
			type = "colorpicker",
			name = "Cooldown Color",
			tooltip = "Color of timer when TurningTide proc is currently on cooldown",
			warning = "Color changes go into effect next time timer changes color",
			getFunc = function() return unpack(TurningTide.savedVars.COLORS.DOWN) end,
			setFunc = function(r,g,b,a) TurningTide.savedVars.COLORS.DOWN = {r,g,b,a} end,
		},
	}

	LAM:RegisterOptionControls(TurningTide.name.."Options", options)
end
