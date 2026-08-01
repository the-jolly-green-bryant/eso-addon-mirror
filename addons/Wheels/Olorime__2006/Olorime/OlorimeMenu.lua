Olorime = Olorime or { }
local Olorime = Olorime

function Olorime.setupMenu()
	local LAM = LibAddonMenu2
	local LCA = LibCombatAlerts
	
	local panelData = {
		type = "panel",
		name = Olorime.name,
		displayName = "|cFFD700"..Olorime.name.."|r",
		author = "tmbrinks",
		version = ""..Olorime.version,
		registerForRefresh = true
	}

	LAM:RegisterAddonPanel(Olorime.name.."Options", panelData)
	
	local movementHide = function(hide)
        if not hide then
            EVENT_MANAGER:UnregisterForEvent(Olorime.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE)
            OlorimeFrame:SetHidden(false)
            OlorimeFrame:SetMovable(true)
            OlorimeFrame:SetMouseEnabled(true)
        else
            EVENT_MANAGER:RegisterForEvent(Olorime.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, Olorime.hideFrame)
            OlorimeFrame:SetHidden(IsReticleHidden())
            OlorimeFrame:SetMovable(false)
            OlorimeFrame:SetMouseEnabled(false)
        end
    end

    local gpMovement = false
    local movementOption
    if (IsConsoleUI()) then
        Olorime.posHandler:RegisterCallback("GamepadMovementCleanup", LCA.EVENT_CONTROL_MOVE_STOP, function()
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
                Olorime.posHandler:ToggleGamepadMove(true)
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
			getFunc = function() return Olorime.savedVars.timerSize end,
			setFunc = function(value)
				Olorime.savedVars.timerSize = value
				Olorime.setFontSize(value)
			end
		},
		{
			type = "checkbox",
			name = "Only Display In Combat",
			tooltip = "Only displays timer when the player is in combat",
			getFunc = function() return Olorime.savedVars.passiveHide end,
			setFunc = function(value)
				Olorime.savedVars.passiveHide = value
				Olorime.hideOutOfCombat()
			end
		},
		{
			type = "colorpicker",
			name = "Available Color",
			tooltip = "Color of timer when Olorime proc is available",
			warning = "Color changes go into effect next time timer changes color",
			getFunc = function() return unpack(Olorime.savedVars.COLORS.UP) end,
			setFunc = function(r,g,b,a) Olorime.savedVars.COLORS.UP = {r,g,b,a} end,
		},
		{
			type = "colorpicker",
			name = "Cooldown Color",
			tooltip = "Color of timer when Olorime proc is currently on cooldown",
			warning = "Color changes go into effect next time timer changes color",
			getFunc = function() return unpack(Olorime.savedVars.COLORS.DOWN) end,
			setFunc = function(r,g,b,a) Olorime.savedVars.COLORS.DOWN = {r,g,b,a} end,
		},
	}

	LAM:RegisterOptionControls(Olorime.name.."Options", options)
end
