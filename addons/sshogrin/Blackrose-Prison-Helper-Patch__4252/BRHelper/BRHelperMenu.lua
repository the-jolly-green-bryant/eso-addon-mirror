local BR = BRHelper

function BR.BuildMenu(savedVars)

	local settings = savedVars

	local function SetSavedVars(control, value)
		settings[control] = value
		BR.savedVariables[control] = value
	end

    local panelInfo = {
        type = 'panel',
        name = 'Blackrose Prison Helper',
        displayName = 'Blackrose Prison Helper',
        author = "|cFFFF00@andy.s|r",
        version = "|c00FF00" .. BR.version .. "|r",
        registerForRefresh = true
    }

    LibAddonMenu2:RegisterAddonPanel(BR.name .. "Options", panelInfo)

    local options = {
		--[[
		{
			type = "description",
			text = "There are more notifications provided by the addon than you can configure here. I just didn't want to add a separate switch for every single mechanic. Most of the notifications will save your life, so you don't really want to disable them. Enjoy and good luck! ;)",
		},
		]]
		-- POSITION
		{
			type = "header",
			name = "|cFFFACDPositioning|r"
		},
		{
			type = "checkbox",
			name = "UI Locked",
			tooltip = "Reposition notifications.",
			getFunc = function() return BR.uiLocked end,
			setFunc = function(value)
				if not value then
					BR.UnlockUI()
				else
					BR.LockUI()
				end
			end
		},
		-- COLORS
		{
			type = "header",
			name = "|cFFFACDColors|r"
		},
		{
			type = "colorpicker",
			name = "Dangerous mechanics",
			default = ZO_ColorDef:New(unpack(BR.savedVariables.win1Color)),
			getFunc = function() return unpack(BR.savedVariables.win1Color) end,
			setFunc = function(r, g, b)
				SetSavedVars("win1Color", {r, g, b})
				BRHelperWin1_Label:SetColor(unpack(BR.savedVariables.win1Color))
			end,
		},
		{
			type = "colorpicker",
			name = "Important mechanics",
			default = ZO_ColorDef:New(unpack(BR.savedVariables.win2Color)),
			getFunc = function() return unpack(BR.savedVariables.win2Color) end,
			setFunc = function(r, g, b)
				SetSavedVars("win2Color", {r, g, b})
				BRHelperWin2_Label:SetColor(unpack(BR.savedVariables.win2Color))
			end,
		},
		{
			type = "colorpicker",
			name = "Various mechanics",
			default = ZO_ColorDef:New(unpack(BR.savedVariables.win3Color)),
			getFunc = function() return unpack(BR.savedVariables.win3Color) end,
			setFunc = function(r, g, b)
				SetSavedVars("win3Color", {r, g, b})
				BRHelperWin3_Label:SetColor(unpack(BR.savedVariables.win3Color))
			end,
		},
		-- GENERAL SETTINGS
		{
			type = "header",
			name = "|cFFFACDGeneral Notifications|r"
		},
		{
			type = "checkbox",
			name = "Wave Info",
			tooltip = "Show information about the current wave.",
            default = settings.showWaveInfo,
			getFunc = function() return BR.savedVariables.showWaveInfo end,
			setFunc = function(value)
				BR.savedVariables.showWaveInfo = value or false
			end,
		},
		{
			type = "checkbox",
			name = "Show Arrow",
			tooltip = "Show an arrow pointing at mages/archers spawns. If two mages or archers spawn, then arrows will be different depending on your role.",
            default = settings.showArrow,
			getFunc = function() return BR.savedVariables.showArrow end,
			setFunc = function(value)
				BR.savedVariables.showArrow = value or false
			end,
		},
		{
			type = "colorpicker",
			name = "Arrow Color",
			default = ZO_ColorDef:New(unpack(BR.savedVariables.arrowColor)),
			getFunc = function() return unpack(BR.savedVariables.arrowColor) end,
			setFunc = function(r, g, b)
				SetSavedVars("arrowColor", {r, g, b})
				BR.UpdateArrowStyle()
			end,
			width = "full",
			disabled = function() return not BR.savedVariables.showArrow end,
		},
		{
			type = "slider",
			name = "Arrow Scale",
			min = 1,
			max = 2,
			step = 0.1,
			decimals = 1,
			clampInput = true,
			default = settings.arrowScale,
			getFunc = function() return BR.savedVariables.arrowScale end,
			setFunc = function(value)
				SetSavedVars("arrowScale", value)
				BR.UpdateArrowStyle()
			end,
			width = "full",
			disabled = function() return not BR.savedVariables.showArrow end,
		},
		-- ARENA 3
		{
			type = "header",
			name = "|cFFFACDArena 3|r"
		},
		{
			type = "checkbox",
			name = "Bat Swarm",
			tooltip = "Lady Minara's AoE on the tank.",
            default = settings.trackBatSwarm,
			getFunc = function() return BR.savedVariables.trackBatSwarm end,
			setFunc = function(value)
				BR.savedVariables.trackBatSwarm = value or false
			end,
		},
		{
			type = "checkbox",
			name = "Bat Swarm Countdown",
			tooltip = "Shows a 10 seconds countdown before Bat Swarm. NOTE: it can happen a few seconds sooner or even 10s later depending on the boss animations and RNG, especially on the 4th arena.",
            default = settings.enableBatSwarmCountdown,
			getFunc = function() return BR.savedVariables.enableBatSwarmCountdown end,
			setFunc = function(value)
				BR.savedVariables.enableBatSwarmCountdown = value or false
			end,
			disabled = function() return not BR.savedVariables.trackBatSwarm end,
		},
		-- ARENA 5
		{
			type = "header",
			name = "|cFFFACDArena 5|r"
		},
		{
			type = "checkbox",
			name = "Void",
			tooltip = "Interruptible AoE cast. Unfortunately it's impossible to tell if you interrutped the caster or not, so you will always see a full duration countdown for this cast.",
            default = settings.trackVoid,
			getFunc = function() return BR.savedVariables.trackVoid end,
			setFunc = function(value)
				BR.savedVariables.trackVoid = value or false
			end,
		},
		{
			type = "checkbox",
			name = "Chill Spear",
			tooltip = "Ice spears are casted by ghosts and apply maim. You need to dodge or block them. It is recommended to disable for a tank, because it can overlap with heavy attack notifications.",
            default = settings.trackChillSpear,
			getFunc = function() return BR.savedVariables.trackChillSpear end,
			setFunc = function(value)
				BR.savedVariables.trackChillSpear = value or false
			end,
		},
		{
			type = "checkbox",
			name = "Barrage of Stone",
			tooltip = "Totem's attack. It is recommended to disable for a tank, because it can overlap with heavy attack notifications.",
            default = settings.trackBarrageOfStone,
			getFunc = function() return BR.savedVariables.trackBarrageOfStone end,
			setFunc = function(value)
				BR.savedVariables.trackBarrageOfStone = value or false
			end,
		},
		-- MISC
		{
			type = "header",
			name = "|cFFFACDMisc|r"
		},
		{
			type = "checkbox",
			name = "Chat Messages",
			tooltip = "Prints the current stage/wave number into the chatbox.",
            default = settings.enableChatMessages,
			getFunc = function() return BR.savedVariables.enableChatMessages end,
			setFunc = function(value)
				BR.savedVariables.enableChatMessages = value or false
			end,
		},
	}

    LibAddonMenu2:RegisterOptionControls(BR.name .. "Options", options)

end