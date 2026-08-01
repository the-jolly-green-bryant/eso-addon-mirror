RoaringOpportunist = RoaringOpportunist or { }
local RO = RoaringOpportunist
local LAM = LibAddonMenu2
local LCA = LibCombatAlerts

function RO.buildMenu()
	local panelData = {
		type = "panel",
		name = RO.name,
		displayName = "|cFFD700"..RO.name.."|r",
		author = "tmbrinks, |cc2ff19Wheels|r",
		version = ""..RO.version,
	}

	LAM:RegisterAddonPanel(RO.name.."Options", panelData)
	
	local movementHide = function(hide)
        if not hide then
            if not hide then
					RO.setHudDisplay(false, false)
				else
					RO.gearUpdate()
				end
				RO.UI.frame:SetMouseEnabled(not hide)
				RO.UI.frame:SetMovable(not hide)
        end
    end

    local gpMovement = false
    local movementOption
    if (IsConsoleUI()) then
        RoaringOpportunist.posHandler:RegisterCallback("GamepadMovementCleanup", LCA.EVENT_CONTROL_MOVE_STOP, function()
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
                RoaringOpportunist.posHandler:ToggleGamepadMove(true)
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
			name = "Positioning",
		},
		movementOption,
		{
			type = "header",
			name = "Options",
		},
		{
			type = "slider",
			name = "Timer Size",
			tooltip = "Scale of the timer (50% to 200%)",
			min = 0.5,
			max = 2.0,
			step = 0.01,
			getFunc = function() return RO.savedVars.scale end,
			setFunc = function(value)
				RO.savedVars.scale = value
				RO.UI.frame:SetScale(value)
			end,
		},
		{
			type = "checkbox",
			name = "Only Display In Combat",
			tooltip = "Only displays timer when the player is in combat",
			getFunc = function() return RO.savedVars.passiveHide end,
			setFunc = function(value)
				RO.savedVars.passiveHide = value
				RO.gearUpdate()
			end
		},
		{
			type = "checkbox",
			name = "Slayer Countdown",
			tooltip = "Do you want the slayer timer to countdown time (ON) or show a static time (OFF)",
			getFunc = function() return RO.savedVars.slayercount end,
			setFunc = function(value)
				RO.savedVars.slayercount = value
			end,	
		},
		{
			type = "colorpicker",
			name = "Available Color",
			tooltip = "Color of timer when RoaringOpportunist proc is available",
			warning = "Color changes go into effect next time timer changes color",
			getFunc = function() return unpack(RO.savedVars.colors.UP) end,
			setFunc = function(r,g,b,a) RO.savedVars.colors.UP = {r,g,b,a} end,
		},
		{
			type = "colorpicker",
			name = "Cooldown Color",
			tooltip = "Color of timer when RoaringOpportunist proc is currently on cooldown",
			warning = "Color changes go into effect next time timer changes color",
			getFunc = function() return unpack(RO.savedVars.colors.DOWN) end,
			setFunc = function(r,g,b,a) RO.savedVars.colors.DOWN = {r,g,b,a} end,
		},
		{
			type = "colorpicker",
			name = "Heavy Attack Timer",
			tooltip = "Color of timer when you can start heavy attack for next proc",
			warning = "Color changes go into effect next time timer changes color",
			getFunc = function() return unpack(RO.savedVars.colors.PROC) end,
			setFunc = function(r,g,b,a) RO.savedVars.colors.PROC = {r,g,b,a} end,
		},
		{
			type = "colorpicker",
			name = "Major Slayer (full proc)",
			tooltip = "Color of the label displaying the duration of the last slayer proc, if the proc hit 6 group members",
			warning = "Color changes go into effect next time timer changes color",
			getFunc = function() return unpack(RO.savedVars.colors.SLAYERTIMER) end,
			setFunc = function(r,g,b,a) RO.savedVars.colors.SLAYERTIMER = {r,g,b,a} end,
		},
		{
			type = "colorpicker",
			name = "Major Slayer (partial proc)",
			tooltip = "Color of the label displaying the duration of the last slayer proc, if the proc hit fewer than 6 group members",
			warning = "Color changes go into effect next time timer changes color",
			getFunc = function() return unpack(RO.savedVars.colors.SLAYERLOW) end,
			setFunc = function(r,g,b,a) RO.savedVars.colors.SLAYERLOW = {r,g,b,a} end,
		},
	}

	LAM:RegisterOptionControls(RO.name.."Options", options)
end
