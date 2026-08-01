local Addon =
{
    Name = "xTG_ImmersiveInterface",
    NameSpaced = "Immersive Interface",
    Author = "@xTG",
    Version = "0.0.1.c",
    VariableVersion = "1",
}

local constants = {
	health_module = {
		intervalNumber = 5,
		heartBeat = 1,
		heartBeatNumber = 2,
	},
}

local default_config = {
	ui_module = {
		hide_questTracker = true,
		hide_compass = true,
		hide_skillBar = true,
		hide_playerAttributesBar = true,
		hide_targetFrame = true,
		hide_equipmentStatus = true,
	},
	health_module = {
		onlyInFight = false,
		nominal = {
			alphaMin = 0.0,
			alphaMax = 0.2,
		},
		critical = {
			alphaMin = 0.2,
			alphaMax = 0.4,
		},
		hideThreshold = 0.80,
		criticalthreshold = 0.45,
	},
}

local XTGII_config = {
	hide = false,

	ui_module = {
		hide_questTracker = true,
		hide_compass = true,
		hide_skillBar = true,
		hide_playerAttributesBar = true,
		hide_targetFrame = true,
		hide_equipmentStatus = true,
	},
	health_module = {
		onlyInFight = false,
		nominal = {
			alphaMin = 0.0,
			alphaMax = 0.2,
		},
		critical = {
			alphaMin = 0.2,
			alphaMax = 0.4,
		},
		hideThreshold = 0.80,
		criticalthreshold = 0.45,
	},
}

local context = {
	inCombat = false,

	ui_module = {
		updateInterval = 1000,
	},

	health_module = {
		updateInterval = 200,
		intervalNumber = constants.health_module.intervalNumber,
		heartBeat = constants.health_module.heartBeat,
		heartBeatNumber = constants.health_module.heartBeatNumber,
		alpha = XTGII_config.health_module.nominal.alphaMin,
		health = 100,
		healthMax = 100,
		index = 0,
	},
}


local buttonLabel = ZO_ReticleContainerInteractContext

function ii_toggle()
	if XTGII_config.hide == true then
  		XTGII_config.hide = false
  		d("ImmersiveInterface OFF")
  	else
  		XTGII_config.hide = true
  		d("ImmersiveInterface ON")
  	end
end
 
function OnLoad(event, addonName)
	if addonName == Addon.Name then
		zo_callLater(function() 
			XTGII_config = ZO_SavedVars:New("XTGII_config", Addon.VariableVersion, nil, default_config)

			context.inCombat = IsUnitInCombat("player")

			-- health
			EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_PLAYER_COMBAT_STATE, XTGIH_OnPlayerCombatState)
			EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_POWER_UPDATE, UpdatePower)
			EVENT_MANAGER:RegisterForUpdate(Addon.Name .. "_healthModule", context.health_module.updateInterval, XTGIH_Timer)

			-- hide interface
			EVENT_MANAGER:RegisterForUpdate(Addon.Name .. "_hideUI", context.ui_module.updateInterval, XTGII_UI)
			EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_RETICLE_TARGET_CHANGED, OnTargetHasChanged)

			-- command
			SLASH_COMMANDS["/ii_toggle"] = function (extra)
				ii_toggle()
			end

			-- config panel
			XTGII_ConfigPanel()

			WINDOW_MANAGER:CreateControl(nil, control, CT_TEXTURE)

		end, 2000)
	end
end

-- Health functions

function XTGIH_OnPlayerCombatState(event, inCombat)
	-- The ~= operator is "not equal to" in Lua.
	if inCombat ~= context.inCombat then
		-- The player's state has changed. Update the stored state...
		context.inCombat = inCombat
	end
end

function UpdatePower(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax) 
 
	-- Add an if statement to check and make sure its the correct powerType
	if powerType == POWERTYPE_HEALTH and unitTag == "player" then 
		context.health_module.health = powerValue
		context.health_module.healthMax = powerMax
	end
end

function XTGIH_Timer(eventCode, initial)
	if  ( context.health_module.health >= (context.health_module.healthMax * XTGII_config.health_module.hideThreshold) ) or
		( context.inCombat == false and XTGII_config.health_module.onlyInFight == true )
	then 
		if context.health_module.alpha ~= XTGII_config.health_module.nominal.alphaMin then
			context.health_module.alpha = XTGII_config.health_module.nominal.alphaMin
			xTG_ImmersiveHealthBackdrop:SetAlpha(context.health_module.alpha)
		end
		context.health_module.heartBeatNumber = constants.health_module.heartBeatNumber
		context.health_module.intervalNumber = constants.health_module.intervalNumber
		context.health_module.heartBeat = constants.health_module.heartBeat
	else
		if context.health_module.intervalNumber <= 0 then
			if context.health_module.heartBeatNumber <= 0 and context.health_module.heartBeat <= 0 then
				if context.health_module.health > context.health_module.healthMax * XTGII_config.health_module.criticalthreshold then
					context.health_module.alpha = XTGII_config.health_module.nominal.alphaMin
				else
					context.health_module.alpha = XTGII_config.health_module.critical.alphaMin
				end
				xTG_ImmersiveHealthBackdrop:SetAlpha(context.health_module.alpha)

				-- reinit
				context.health_module.heartBeatNumber = constants.health_module.heartBeatNumber
				context.health_module.heartBeat = constants.health_module.heartBeat
				context.health_module.intervalNumber = constants.health_module.intervalNumber * (context.health_module.health / context.health_module.healthMax)
			else
				if context.health_module.heartBeatNumber <= 0 then
					-- init next heartbeat
					context.health_module.heartBeat = context.health_module.heartBeat - 1
					context.health_module.heartBeatNumber = constants.health_module.heartBeatNumber
				end

				context.health_module.heartBeatNumber = context.health_module.heartBeatNumber - 1
				if context.health_module.health > context.health_module.healthMax * XTGII_config.health_module.criticalthreshold then
					if context.health_module.alpha == XTGII_config.health_module.nominal.alphaMin then
						context.health_module.alpha = XTGII_config.health_module.nominal.alphaMax
					else
						context.health_module.alpha = XTGII_config.health_module.nominal.alphaMin
					end
				else
					if context.health_module.alpha == XTGII_config.health_module.critical.alphaMin then
						context.health_module.alpha = XTGII_config.health_module.critical.alphaMax
					else
						context.health_module.alpha = XTGII_config.health_module.critical.alphaMin
					end
				end

				xTG_ImmersiveHealthBackdrop:SetAlpha(context.health_module.alpha)
			end
		else
			context.health_module.intervalNumber = context.health_module.intervalNumber - 1
		end
	end
end

-- Hide UI functions

function OnTargetHasChanged(eventcode, input)
	if XTGII_config.hide == true then
		if DoesUnitExist('reticleover') then
			target = GetUnitName('reticleover')
			xTG_ImmersiveInterfaceUnitName:SetText(target)
			xTG_ImmersiveInterfaceUnitName:SetHidden(false)
		else
			-- target none
			xTG_ImmersiveInterfaceUnitName:SetText("")
			xTG_ImmersiveInterfaceUnitName:SetHidden(true)
		end
	end
end

function XTGII_UI(eventCode, initial)
	if SCENE_MANAGER ~= nil and SCENE_MANAGER.currentScene ~= nil and SCENE_MANAGER.currentScene.name ~= nil then
		local cScene = SCENE_MANAGER.currentScene.name

		zo_callLater(function() 

			if XTGII_config.ui_module.hide_questTracker and XTGII_config.hide then -- current quest
				FOCUSED_QUEST_TRACKER_FRAGMENT:Hide()
			else
				FOCUSED_QUEST_TRACKER_FRAGMENT:Show()
			end

			if XTGII_config.ui_module.hide_compass and XTGII_config.hide then -- compass
				COMPASS_FRAME_FRAGMENT:Hide()
			else
				COMPASS_FRAME_FRAGMENT:Show()
			end

			if XTGII_config.ui_module.hide_skillBar and XTGII_config.hide then
				ACTION_BAR_FRAGMENT:Hide() -- skills
			else
				ACTION_BAR_FRAGMENT:Show()
			end

			if XTGII_config.ui_module.hide_playerAttributesBar and XTGII_config.hide then -- HP/Mana/Stamina
				PLAYER_ATTRIBUTE_BARS_FRAGMENT:Hide() 
			else
				PLAYER_ATTRIBUTE_BARS_FRAGMENT:Show()
			end

			if XTGII_config.ui_module.hide_targetFrame and XTGII_config.hide then -- target frame
				UNIT_FRAMES_FRAGMENT:Hide()
			else
				UNIT_FRAMES_FRAGMENT:Show()
			end

			if XTGII_config.ui_module.hide_equipmentStatus and XTGII_config.hide then -- weapons/armor status
				HUD_EQUIPMENT_STATUS_FRAGMENT:Hide()
			else
				HUD_EQUIPMENT_STATUS_FRAGMENT:Show()
			end

		end, 10)

		if XTGII_config.hide then
			local text = buttonLabel:GetText()
			if text ~= nil and text ~= "" then	-- is there a target ?
				if GetGameCameraInteractableInfo() then -- too far to interact or not ?
					xTG_ImmersiveInterfaceUnitName:SetHidden(true)
				else
					xTG_ImmersiveInterfaceUnitName:SetHidden(false)
				end
			end
		end
	end
end

-- Config Panel

function XTGII_ConfigPanel()
	local panelData = {
		type = "panel",
		name = Addon.Name,
		displayName = Addon.NameSpaced,
		author = Addon.Author,
		version = Addon.Version
	}

	local LAM2 = LibStub("LibAddonMenu-2.0")
    LAM2:RegisterAddonPanel(Addon.Name .. "Options", panelData)

    local optionsData = {
    	{
			type = "description",
			text = GetString(XTGII_GUI_OPTION_DESCRIPTION_LINE_1),
		},
    	{
	    	type = "submenu",
			name = GetString(XTGII_GUI_OPTION_MENU_INTERFACE),
			controls = 
			{
				{
					type = "description",
					text = GetString(XTGII_GUI_OPTION_INTERFACE_DESCRIPTION_LINE),
				},
				{
					type = "checkbox",
					name = GetString(XTGII_GUI_OPTION_INTERFACE_QUEST_TRACKER),
					getFunc = function() return XTGII_config.ui_module.hide_questTracker end,
					setFunc = function(value) XTGII_config.ui_module.hide_questTracker = value end,
				},
				{
					type = "checkbox",
					name = GetString(XTGII_GUI_OPTION_INTERFACE_COMPASS),
					getFunc = function() return XTGII_config.ui_module.hide_compass end,
					setFunc = function(value) XTGII_config.ui_module.hide_compass = value end,
				},
				{
					type = "checkbox",
					name = GetString(XTGII_GUI_OPTION_INTERFACE_SKILLBAR),
					getFunc = function() return XTGII_config.ui_module.hide_skillBar end,
					setFunc = function(value) XTGII_config.ui_module.hide_skillBar = value end,
				},
				{
					type = "checkbox",
					name = GetString(XTGII_GUI_OPTION_INTERFACE_PLAYER_ATTRIBUTES_BARS),
					getFunc = function() return XTGII_config.ui_module.hide_playerAttributesBar end,
					setFunc = function(value) XTGII_config.ui_module.hide_playerAttributesBar = value end,
				},
				{
					type = "checkbox",
					name = GetString(XTGII_GUI_OPTION_INTERFACE_TARGET_FRAME),
					getFunc = function() return XTGII_config.ui_module.hide_targetFrame end,
					setFunc = function(value) XTGII_config.ui_module.hide_targetFrame = value end,
				},
				{
					type = "checkbox",
					name = GetString(XTGII_GUI_OPTION_INTERFACE_EQUIPMENT_STATUS),
					getFunc = function() return XTGII_config.ui_module.hide_equipmentStatus end,
					setFunc = function(value) XTGII_config.ui_module.hide_equipmentStatus = value end,
				},
			},
		}, -- end submenu

	    {
	    	type = "submenu",
			name = GetString(XTGII_GUI_OPTION_MENU_HEALTH),
			controls = 
			{
				{
					type = "description",
					text = GetString(XTGII_GUI_OPTION_HEALTH_DESCRIPTION_LINE_1),
				},
				{
					type = "description",
					text = GetString(XTGII_GUI_OPTION_HEALTH_DESCRIPTION_LINE_2),
				},
				{
					type = "checkbox",
					name = GetString(XTGIH_GUI_OPTION_HEALTH_ONLY_IN_FIGHT),
					getFunc = function() return XTGII_config.health_module.onlyInFight end,
					setFunc = function(value) XTGII_config.health_module.onlyInFight = value end,
				},
				{
					type = "texture",
					image = "EsoUI/Art/Quest/questJournal_divider.dds",
					imageWidth = 510,
					imageHeight = 4,
				},
				{
					type = "slider",
					name = GetString(XTGIH_GUI_OPTION_HEALTH_HIDETHRESHOLD),
					tooltip = GetString(XTGIH_GUI_TOOLTIP_HEALTH_HIDETHRESHOLD),
					min = 0,
					max = 100,
					getFunc = function() return XTGII_config.health_module.hideThreshold * 100 end,
					setFunc = function(value) XTGII_config.health_module.hideThreshold = value / 100 end,
				},
				{
					type = "slider",
					name = GetString(XTGIH_GUI_OPTION_HEALTH_ALPHAMIN),
					tooltip = GetString(XTGIH_GUI_TOOLTIP_HEALTH_ALPHAMIN),
					min = 0,
					max = 100,
					getFunc = function() return XTGII_config.health_module.nominal.alphaMin * 100 end,
					setFunc = function(value) XTGII_config.health_module.nominal.alphaMin = value / 100 end,
				},
				{
					type = "slider",
					name = GetString(XTGIH_GUI_OPTION_HEALTH_ALPHAMAX),
					tooltip = GetString(XTGIH_GUI_TOOLTIP_HEALTH_ALPHAMAX),
					min = 0,
					max = 100,
					getFunc = function() return XTGII_config.health_module.nominal.alphaMax * 100 end,
					setFunc = function(value) XTGII_config.health_module.nominal.alphaMax = value / 100 end,
				},
				{
					type = "texture",
					image = "EsoUI/Art/Quest/questJournal_divider.dds",
					imageWidth = 510,
					imageHeight = 4,
				},
				{
					type = "slider",
					name = GetString(XTGIH_GUI_OPTION_HEALTH_CRITICALTHRESHOLD),
					tooltip = GetString(XTGIH_GUI_TOOLTIP_HEALTH_CRITICALTHRESHOLD),
					min = 0,
					max = 100,
					getFunc = function() return XTGII_config.health_module.criticalthreshold * 100 end,
					setFunc = function(value) XTGII_config.health_module.criticalthreshold = value / 100 end,
				},
				{
					type = "slider",
					name = GetString(XTGIH_GUI_OPTION_HEALTH_ALPHAMIN),
					tooltip = GetString(XTGIH_GUI_TOOLTIP_HEALTH_ALPHAMIN),
					min = 0,
					max = 100,
					getFunc = function() return XTGII_config.health_module.critical.alphaMin * 100 end,
					setFunc = function(value) XTGII_config.health_module.critical.alphaMin = value / 100 end,
				},
				{
					type = "slider",
					name = GetString(XTGIH_GUI_OPTION_HEALTH_ALPHAMAX),
					tooltip = GetString(XTGIH_GUI_TOOLTIP_HEALTH_ALPHAMAX),
					min = 0,
					max = 100,
					getFunc = function() return XTGII_config.health_module.critical.alphaMax * 100 end,
					setFunc = function(value) XTGII_config.health_module.critical.alphaMax = value / 100 end,
				},
			},
		}, -- end submenu
	}
    LAM2:RegisterOptionControls(Addon.Name .. "Options", optionsData)
end

-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED, OnLoad)
ZO_CreateStringId("SI_BINDING_NAME_xTGII_TOGGLE", "Toggle Immersive Interface")
