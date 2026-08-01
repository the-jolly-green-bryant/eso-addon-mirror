Siroria = Siroria or { }
local Siroria = Siroria

function Siroria.setupMenu()
	local LAM = LibAddonMenu2

	local lockUI		= true
	-- local positionGuard	= false
	-- local circleGuard	= true

	local panelData = {
		type = "panel",
		name = Siroria.name,
		displayName = "|cff5938S|riroria",
		author = "Wheels",
		version = ""..Siroria.version,
		registerForRefresh = true
	}

	LAM:RegisterAddonPanel(Siroria.name.."Options", panelData)

	local options = {
		{
			type = "header",
			name = "Positioning"
		},
		{
			type = "checkbox",
			name = "Lock UI",
			tooltip = "Unlock to position timer in desired location",
			getFunc = function() return lockUI end,
			setFunc = function(value)
				if not value then
					EVENT_MANAGER:UnregisterForEvent(Siroria.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE)
					SiroriaFrame:SetHidden(false)
					SiroriaFrame:SetMovable(true)
					SiroriaFrame:SetMouseEnabled(true)
					lockUI = false
					--positionGuard = true
				else
					SiroriaFrame:SetHidden(IsReticleHidden())
					SiroriaFrame:SetMovable(false)
					SiroriaFrame:SetMouseEnabled(false)
					Siroria.gearUpdate()
					lockUI = true
					--positionGuard = false
				end
			end
		},
		--{
		--	type = "checkbox",
		--	name = "Lock Circle Timer",
		--	tooltip = "Unlock to position timer in desired location",
		--	disabled = function() return not positionGuard end,
		--	getFunc = function() return circleGuard end,
		--	setFunc = function(value)
		--		if not value then
		--			SiroriaFrameTime:SetMovable(true)
		--			SiroriaFrameTime:SetMouseEnabled(true)
		--		else
		--			SiroriaFrameTime:SetMovable(false)
		--			SiroriaFrameTime:SetMouseEnabled(false)
		--		end
		--	end
		--},
		{
			type = "header",
			name = "Options"
		},
		-- {
		-- 	type = "slider",
		-- 	name = "Text Size",
		-- 	tooltip = "Size of the displayed timer",
		-- 	min = 20,
		-- 	max = 72,
		-- 	getFunc = function() return Siroria.savedVars.timerSize end,
		-- 	setFunc = function(value)
		-- 		Siroria.savedVars.timerSize = value
		-- 		Siroria.setFontSize(value)
		-- 	end
		-- },
		{
			type = "checkbox",
			name = "Only Display In Combat",
			tooltip = "Only displays timer when the player is in combat",
			getFunc = function() return Siroria.savedVars.passiveHide end,
			setFunc = function(value)
				Siroria.savedVars.passiveHide = value
				Siroria.hideOutOfCombat()
			end
		},
		{
			type = "checkbox",
			name = "Display Stack Count",
			tooltip = "Option to enable/disable counter showing current stacks",
			getFunc = function() return Siroria.savedVars.showStacks end,
			setFunc = function(value)
				Siroria.savedVars.showStacks = value
				SiroriaFrameStacks:SetHidden(not value)
			end
		},
		{
			type = "checkbox",
			name = "Display Stack Timer",
			tooltip = "Option to enable/disable timer for remaining time on stacks",
			getFunc = function() return Siroria.savedVars.showStackTimer end,
			setFunc = function(value)
				Siroria.savedVars.showStackTimer = value
				SiroriaFrameStackTime:SetHidden(not value)
			end
		},
		{
			type = "checkbox",
			name = "Stay/Move Display",
			tooltip = "Replaces the stack timer with text saying whether is it safe to move or not, based on how much time is remaining on proc vs stack (thanks Iceman!)",
			getFunc = function() return Siroria.savedVars.stayGoNoti end,
			setFunc = function(value)
				Siroria.savedVars.stayGoNoti = value
			end
		},
		{
			type = "colorpicker",
			name = "Available Color",
			tooltip = "Color of timer when Siroria proc is available",
			getFunc = function() return unpack(Siroria.savedVars.COLORS.UP) end,
			setFunc = function(r,g,b,a)
				Siroria.savedVars.COLORS.UP = {r,g,b,a}
				Siroria.setColors()
			end,
		},
		{
			type = "colorpicker",
			name = "Cooldown Color",
			tooltip = "Color of timer when Siroria proc is currently on cooldown",
			getFunc = function() return unpack(Siroria.savedVars.COLORS.DOWN) end,
			setFunc = function(r,g,b,a) Siroria.savedVars.COLORS.DOWN = {r,g,b,a} end,
		},
		{
			type = "colorpicker",
			name = "Stack Color",
			tooltip = "Color of stack counter",
			getFunc = function() return unpack(Siroria.savedVars.COLORS.STACK) end,
			setFunc = function(r,g,b,a)
				Siroria.savedVars.COLORS.STACK = {r,g,b,a}
				Siroria.setColors()
			end,
		},
		{
			type = "colorpicker",
			name = "Stack Timer Color",
			tooltip = "Color of timer tracking remaining time on stacks",
			getFunc = function() return unpack(Siroria.savedVars.COLORS.STACKTIMER) end,
			setFunc = function(r,g,b,a)
				Siroria.savedVars.COLORS.STACKTIMER = {r,g,b,a}
				Siroria.setColors()
			end,
		},
	}

	LAM:RegisterOptionControls(Siroria.name.."Options", options)
end

