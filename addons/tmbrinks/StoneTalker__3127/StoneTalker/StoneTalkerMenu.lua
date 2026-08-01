StoneTalker = StoneTalker or { }
local StoneTalker = StoneTalker

function StoneTalker.setupMenu()
	local LAM = LibAddonMenu2
	local LCA = LibCombatAlerts

	local panelData = {
		type = "panel",
		name = StoneTalker.name,
		displayName = "|cFFD700"..StoneTalker.name.."|r",
		author = "tmbrinks",
		version = ""..StoneTalker.version,
		registerForRefresh = true
	}

	LAM:RegisterAddonPanel(StoneTalker.name.."Options", panelData)

	local movementHide = function(hide)
        if not hide then
            EVENT_MANAGER:UnregisterForEvent(StoneTalker.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE)
            StoneTalkerFrame:SetHidden(false)
            StoneTalkerFrame:SetMovable(true)
            StoneTalkerFrame:SetMouseEnabled(true)
        else
            EVENT_MANAGER:RegisterForEvent(StoneTalker.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, StoneTalker.hideFrame)
            StoneTalkerFrame:SetHidden(IsReticleHidden())
            StoneTalkerFrame:SetMovable(false)
            StoneTalkerFrame:SetMouseEnabled(false)
        end
    end

    local gpMovement = false
    local movementOption
    if (IsConsoleUI()) then
        StoneTalker.posHandler:RegisterCallback("GamepadMovementCleanup", LCA.EVENT_CONTROL_MOVE_STOP, function()
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
                StoneTalker.posHandler:ToggleGamepadMove(true)
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
			getFunc = function() return StoneTalker.savedVars.timerSize end,
			setFunc = function(value)
				StoneTalker.savedVars.timerSize = value
				StoneTalker.setFontSize(value)
			end
		},
		{
			type = "checkbox",
			name = "Only Display In Combat",
			tooltip = "Only displays timer when the player is in combat",
			getFunc = function() return StoneTalker.savedVars.passiveHide end,
			setFunc = function(value)
				StoneTalker.savedVars.passiveHide = value
				StoneTalker.hideOutOfCombat()
			end
		},
		{
			type = "colorpicker",
			name = "Available Color",
			tooltip = "Color of timer when StoneTalker proc is available",
			warning = "Color changes go into effect next time timer changes color",
			getFunc = function() return unpack(StoneTalker.savedVars.COLORS.UP) end,
			setFunc = function(r,g,b,a) StoneTalker.savedVars.COLORS.UP = {r,g,b,a} end,
		},
		{
			type = "colorpicker",
			name = "Cooldown Color",
			tooltip = "Color of timer when StoneTalker proc is currently on cooldown",
			warning = "Color changes go into effect next time timer changes color",
			getFunc = function() return unpack(StoneTalker.savedVars.COLORS.DOWN) end,
			setFunc = function(r,g,b,a) StoneTalker.savedVars.COLORS.DOWN = {r,g,b,a} end,
		},
	}

	LAM:RegisterOptionControls(StoneTalker.name.."Options", options)
end
