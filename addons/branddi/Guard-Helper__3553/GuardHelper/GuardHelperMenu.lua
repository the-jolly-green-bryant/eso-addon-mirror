GuardHelper = GuardHelper or { }
local GuardHelper = GuardHelper



function GuardHelper.setupMenu()

	local LAM = LibAddonMenu2

    local panelData = {
		type = "panel",
		name = "Guard Helper",
		displayName = "Guard Helper",
		author = "Branddi",
		version = GuardHelper.version,

		registerForRefresh = true,
		registerForDefaults = true
	}

	LAM:RegisterAddonPanel(GuardHelper.name.."Options", panelData)



	--local optionsPanel = LibAddonMenu2:RegisterAddonPanel(GuardHelper.name .. "SettingsMenu", panelData)
	--LibAddonMenu2:RegisterOptionControls(GuardHelper.name .. "SettingsMenu", optionsData)

	local optionsData = {}


    -- Description
	table.insert(optionsData, {
		type = "description",
		text = "Shows who you're guarding of who you are being guarded by",
	})

    -- Options header
	table.insert(optionsData, {
		type = "header",
		name = "Options",
	})

    -- Account wide setting
	table.insert(optionsData, {
		type = "checkbox",
		name = "Account Wide Settings",
		requiresReload = true,
		default = GuardHelper.accountWideDefaults.accountWide,
		getFunc = function() return GuardHelper.DS.accountWide end,
		setFunc = function(newValue) GuardHelper.DS.accountWide = newValue end,
	})



	table.insert(optionsData, {
		type = "header",
		name = "Positioning",
	})

    -- Account wide setting
	table.insert(optionsData, {
		type = "checkbox",
		name = "Lock UI",
		tooltip = "Allows moving the Guard Helper icon",
		getFunc = function() return not GuardHelper.overrideReticleHidden end,
		setFunc = function(value)
				if not value then
				    GuardHelper.overrideReticleHidden=true
				else
				    GuardHelper.overrideReticleHidden=false
				end
			end,
	})





    -- Divider
	table.insert(optionsData, {
		type = "header",
		name = "Detection",
	})

    -- Require both bars
    table.insert(optionsData, {
		type = "checkbox",
		name = "Guard required on both bars",
		tooltip = "If On, requires you to have a guard skill equipped on both bars for the addon to function.",
		default = GuardHelper.defaults.bothBarsRequired,
		getFunc = function() return GuardHelper.SV.bothBarsRequired end,
		setFunc = function(newValue)
            GuardHelper.SV.bothBarsRequired = newValue
        end,
	})


    table.insert(optionsData, {
		type = "checkbox",
		name = "First guard becomes target",
		tooltip = "Automatically use first guard recipient as the guard target",
		default = GuardHelper.defaults.targetAsFirstSuccessfulGuard,
		getFunc = function() return GuardHelper.SV.targetAsFirstSuccessfulGuard end,
		setFunc = function(newValue)
            GuardHelper.SV.targetAsFirstSuccessfulGuard = newValue
        end,
	})







	table.insert(optionsData, {
		type = "header",
		name = "Reticle Arrow",
	})

	-- Arrow to intended guarded target during guard
    table.insert(optionsData, {
		type = "checkbox",
		name = "Arrow to target before guard",
		tooltip = "Before guard is up, show arrow towards the intended guard target",
		default = GuardHelper.defaults.arrowToGuardTargetWhenGuardOff,
		getFunc = function() return GuardHelper.SV.arrowToGuardTargetWhenGuardOff end,
		setFunc = function(newValue)
            GuardHelper.SV.arrowToGuardTargetWhenGuardOff = newValue
        end,
	})

    table.insert(optionsData, {
		type = "checkbox",
		name = "Arrow to target during guard",
		tooltip = "When guard is down, show arrow to intended guard target",
		default = GuardHelper.defaults.arrowToGuardTargetWhenGuardOn,
		getFunc = function() return GuardHelper.SV.arrowToGuardTargetWhenGuardOn end,
		setFunc = function(newValue)
            GuardHelper.SV.arrowToGuardTargetWhenGuardOn = newValue
        end,
	})


	table.insert(optionsData, {
		type = "header",
		name = "Target Name",
	})

    table.insert(optionsData, {
		type = "checkbox",
		name = "Display at name of guarded target",
		tooltip = "Show @name of currently guarded target",
		default = GuardHelper.defaults.displayGuardedTargetAtName,
		getFunc = function() return GuardHelper.SV.displayGuardedTargetAtName end,
		setFunc = function(newValue)
            GuardHelper.SV.displayGuardedTargetAtName = newValue
        end,
	})

    table.insert(optionsData, {
		type = "checkbox",
		name = "Display at name of intended target",
		tooltip = "Show @name of intended guarded target",
		default = GuardHelper.defaults.displayIntendedGuardedTargetAtName,
		getFunc = function() return GuardHelper.SV.displayIntendedGuardedTargetAtName end,
		setFunc = function(newValue)
            GuardHelper.SV.displayIntendedGuardedTargetAtName = newValue
        end,
	})



	table.insert(optionsData, {
		type = "header",
		name = "Skill Blocker",
	})

    table.insert(optionsData, {
		type = "checkbox",
		name = "Prevent casting guard on wrong target",
		tooltip = "Block the use of guard until the intended target is being targeted in range",
		default = GuardHelper.defaults.preventCastingGuardOnUnintendedTarget,
		getFunc = function() return GuardHelper.SV.preventCastingGuardOnUnintendedTarget end,
		setFunc = function(newValue)
            GuardHelper.SV.preventCastingGuardOnUnintendedTarget = newValue
        end,
	})


    table.insert(optionsData, {
		type = "checkbox",
		name = "Prevent removing guard on target",
		tooltip = "Block the use of removing guard after the correct target is aquired",
		default = GuardHelper.defaults.preventRemovingGuardFromIntendedTarget,
		getFunc = function() return GuardHelper.SV.preventRemovingGuardFromIntendedTarget end,
		setFunc = function(newValue)
            GuardHelper.SV.preventRemovingGuardFromIntendedTarget = newValue
        end,
	})

	table.insert(optionsData, {
		type = "header",
		name = "Icon",
	})

    table.insert(optionsData, {
		type = "checkbox",
		name = "Blinking Icon on Loss",
		tooltip = "If you unintentionally lose Guard (outranged target), the icon will blink for 5 seconds",
		default = GuardHelper.defaults.blinking,
		getFunc = function() return GuardHelper.SV.blinking end,
		setFunc = function(newValue)
            GuardHelper.SV.blinking = newValue
        end,
	})


	table.insert(optionsData, {
		type = "header",
		name = "Distance",
	})


    table.insert(optionsData, {
		type = "checkbox",
		name = "Guard radius",
		tooltip = "Draw a circle with icons around the intended guard 15m when guard is down and 16m when guard is up",
		default = GuardHelper.defaults.circle16mAroundGuardTarget,
		getFunc = function() return GuardHelper.SV.circle16mAroundGuardTarget end,
		setFunc = function(newValue)
            GuardHelper.SV.circle16mAroundGuardTarget = newValue
        end,
	})


	LAM:RegisterOptionControls(GuardHelper.name .. "Options", optionsData)
end
