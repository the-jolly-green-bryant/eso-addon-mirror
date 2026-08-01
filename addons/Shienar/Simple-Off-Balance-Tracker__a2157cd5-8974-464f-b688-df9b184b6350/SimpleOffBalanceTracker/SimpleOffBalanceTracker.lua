SOBT = { name = "SimpleOffBalanceTracker" }

SOBT.defaults = {
	isHidden = false,

	colorR = 0.0,
	colorG = 1.0,
	colorB = 0.0,
	colorA = 1.0,

	colorR_Cooldown = 1.0,
	colorG_Cooldown = 1.0,
	colorB_Cooldown = 0.0,
	colorA_Cooldown = 1.0,

	colorR_Inactive = 1.0,
	colorG_Inactive = 0.0,
	colorB_Inactive = 0.0,
	colorA_Inactive = 1.0,

	inCombatOnly = true,

	fontStyle = "GAMEPAD_MEDIUM_FONT",
	fontWeight = "soft-shadow-thick",
	selectedText_font = "34", --fontsize. Legacy variable name kept to not mess with user settings.

	offset_x = 0,
	offset_y = 0,
}

function SOBT.onCombat(code, inCombat)
	if inCombat == true then
		if SOBT.savedVariables.inCombatOnly then
			OBIndicator:SetHidden(SOBT.savedVariables.isHidden)
		end
	else
		if SOBT.savedVariables.inCombatOnly then
			OBIndicator:SetHidden(true)
		end
	end
end

function SOBT.OnUpdate()
	--Off balance: 39077 (7 seconds)
	--Off balance immunity: 134599 (15 seconds)

	if DoesUnitExist("reticleover") == true and IsUnitAttackable("reticleover") == true then
		local hasOffBalance = false
		for i=1, GetNumBuffs("reticleover") do
			local _, _, endTime, _, _, _, _, _, _, _, abilityID, _, _ = GetUnitBuffInfo("reticleover", i)
			local timeRemaining = math.floor((endTime-(GetGameTimeMilliseconds()/1000))*10)/10 -- precision to 0.1 seconds
			if abilityID == 39077 or
				abilityID == 45902 or --OB from blocking charge attack.
				abilityID == 2727 or --Generic off balance
				abilityID == 120014 or --trial dummy off balance
				abilityID == 23808 or --lava whip off balance
				abilityID == 20806 or --molten whip off balance
				abilityID == 34117 or --flame lash off balance
				abilityID == 25256 or --veiled strike
				abilityID == 34733 or --surprise attack
				abilityID ==34737 or --concealed weapon
				abilityID == 130129 or --dive
				abilityID == 130139 or --cutting dive
				abilityID == 130145 or --screaming cliff racer
				abilityID == 125750 or --ruinous scythe
				abilityID == 131562 or --dizzying swing
				abilityID == 62968 or --concussed (wall)
				abilityID == 39077 or --concussed (unstable)
				abilityID == 62988 or --concussed (blockade
				abilityID == 137257 or --roar
				abilityID == 45834 or --ferocious roar
				abilityID == 137312 --deafening roar
			then
				if timeRemaining > 2 then
					timeRemaining = zo_round(timeRemaining)
				end
				OBIndicatorLabel:SetText(timeRemaining)
				OBIndicatorLabel:SetColor(SOBT.savedVariables.colorR, SOBT.savedVariables.colorG, SOBT.savedVariables.colorB)
				OBIndicatorLabel:SetAlpha(SOBT.savedVariables.colorA)
				hasOffBalance = true
				break
			elseif abilityID == 134599 then
				if timeRemaining > 2 then
					timeRemaining = zo_round(timeRemaining)
				end
				OBIndicatorLabel:SetText(timeRemaining)
				OBIndicatorLabel:SetColor(SOBT.savedVariables.colorR_Cooldown, SOBT.savedVariables.colorG_Cooldown, SOBT.savedVariables.colorB_Cooldown)
				OBIndicatorLabel:SetAlpha(SOBT.savedVariables.colorA_Cooldown)
				hasOffBalance = true
				break
			end
		end
		if hasOffBalance == false then
			OBIndicatorLabel:SetText("0")
			OBIndicatorLabel:SetColor(SOBT.savedVariables.colorR_Inactive, SOBT.savedVariables.colorG_Inactive, SOBT.savedVariables.colorB_Inactive)
			OBIndicatorLabel:SetAlpha(SOBT.savedVariables.colorA_Inactive)
		end
	end
end

local function fragmentChange(oldState, newState)
	if newState == SCENE_FRAGMENT_SHOWN then
		if SOBT.savedVariables.inCombatOnly == false then
			OBIndicator:SetHidden(SOBT.savedVariables.isHidden)
		elseif IsUnitInCombat("player") then
			OBIndicator:SetHidden(SOBT.savedVariables.isHidden)
		else
			OBIndicator:SetHidden(true)
		end
	elseif newState == SCENE_FRAGMENT_HIDDEN then
		OBIndicator:SetHidden(true)
	end
end

local function temporarilyShowTracker()
    --Hide UI 5 seconds after most recent change.
    OBIndicator:SetHidden(false)
    EVENT_MANAGER:RegisterForUpdate(SOBT.name.."_editUI", 5000, function()
        if SCENE_MANAGER:GetScene("hud"):GetState() == SCENE_HIDDEN or SOBT.savedVariables.isHidden or (IsUnitInCombat("player") == false and SOBT.savedVariables.inCombatOnly) then
            OBIndicator:SetHidden(true)
		end
        EVENT_MANAGER:UnregisterForUpdate(SOBT.name.."_editUI")
    end)
end

function SOBT.Initialize()
	--Load and apply saved variables
	SOBT.savedVariables = ZO_SavedVars:NewAccountWide("SOBTSavedVariables", 1, nil, SOBT.defaults, GetWorldName())

	HUD_FRAGMENT:RegisterCallback("StateChange", fragmentChange)

	if SOBT.savedVariables.inCombatOnly == false then
		OBIndicator:SetHidden(SOBT.savedVariables.isHidden)
	elseif IsUnitInCombat("player") then
		OBIndicator:SetHidden(SOBT.savedVariables.isHidden)
	else
		OBIndicator:SetHidden(true)
	end

	OBIndicatorLabel:SetColor(SOBT.savedVariables.colorR_Inactive, SOBT.savedVariables.colorG_Inactive, SOBT.savedVariables.colorB_Inactive)
	OBIndicatorLabel:SetAlpha(SOBT.savedVariables.colorA_Inactive)
	OBIndicatorLabel:SetFont(string.format("$(%s)|%s|%s", SOBT.savedVariables.fontStyle, SOBT.savedVariables.selectedText_font, SOBT.savedVariables.fontWeight))
	OBIndicator:ClearAnchors()
	OBIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SOBT.savedVariables.offset_x, SOBT.savedVariables.offset_y)

	if LibHarvensAddonSettings then

		--Settings
		local settings = LibHarvensAddonSettings:AddAddon("Simple Off Balance Tracker")

		settings:AddSetting({type = LibHarvensAddonSettings.ST_SECTION,label = "General",})

		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = "Hide Tracker?",
			tooltip = "Disables the tracker when set to \"On\"",
			default = SOBT.defaults.isHidden,
			setFunction = function(state)
				SOBT.savedVariables.isHidden = state
				OBIndicator:SetHidden(state)

				if state ==  false then
					temporarilyShowTracker()
				end
			end,
			getFunction = function()
				return SOBT.savedVariables.isHidden
			end,
		})

		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = "Only In Combat",
			tooltip = "Disables the tracker outside of combat when set to \"On\"",
			default = SOBT.defaults.inCombatOnly,
			setFunction = function(state)
				SOBT.savedVariables.inCombatOnly = state
				temporarilyShowTracker()
			end,
			getFunction = function()
				return SOBT.savedVariables.inCombatOnly
			end,
		})

		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_BUTTON,
			label = "Reset Defaults",
			tooltip = "",
			buttonText = "RESET",
			clickHandler = function(control, button)
				SOBT.savedVariables.colorR = SOBT.defaults.colorR
				SOBT.savedVariables.colorG = SOBT.defaults.colorG
				SOBT.savedVariables.colorB = SOBT.defaults.colorB
				SOBT.savedVariables.colorA = SOBT.defaults.colorA

				SOBT.savedVariables.colorR_Cooldown = SOBT.defaults.colorR_Cooldown
				SOBT.savedVariables.colorG_Cooldown = SOBT.defaults.colorG_Cooldown
				SOBT.savedVariables.colorB_Cooldown = SOBT.defaults.colorB_Cooldown
				SOBT.savedVariables.colorA_Cooldown = SOBT.defaults.colorA_Cooldown

				SOBT.savedVariables.selectedText_font = SOBT.defaults.selectedText_font
				SOBT.savedVariables.fontStyle = SOBT.defaults.fontStyle
				SOBT.savedVariables.fontWeight = SOBT.defaults.fontWeight

				SOBT.savedVariables.isHidden = SOBT.defaults.isHidden
				SOBT.savedVariables.inCombatOnly = SOBT.defaults.inCombatOnly

				SOBT.savedVariables.offset_x = SOBT.defaults.offset_x
				SOBT.savedVariables.offset_y = SOBT.defaults.offset_y

				temporarilyShowTracker()

				OBIndicatorLabel:SetColor(SOBT.savedVariables.colorR, SOBT.savedVariables.colorG, SOBT.savedVariables.colorB)
				OBIndicatorLabel:SetAlpha(SOBT.savedVariables.colorA)
				OBIndicatorLabel:SetFont(string.format("$(%s)|%s|%s", SOBT.savedVariables.fontStyle, SOBT.savedVariables.selectedText_font, SOBT.savedVariables.fontWeight))

				OBIndicator:ClearAnchors()
				OBIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SOBT.savedVariables.offset_x, SOBT.savedVariables.offset_y)
			end,
		})

		settings:AddSetting({type = LibHarvensAddonSettings.ST_SECTION,label = "Color",})

		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_COLOR,
			label = "Active Color",
			tooltip = "Change the color of the text for when off balance is active.",
			setFunction = function(...) --newR, newG, newB, newA
				SOBT.savedVariables.colorR, SOBT.savedVariables.colorG, SOBT.savedVariables.colorB, SOBT.savedVariables.colorA = ...
				OBIndicatorLabel:SetColor(SOBT.savedVariables.colorR, SOBT.savedVariables.colorG, SOBT.savedVariables.colorB)
				OBIndicatorLabel:SetAlpha(SOBT.savedVariables.colorA)

				temporarilyShowTracker()
			end,
			default = {SOBT.defaults.colorR, SOBT.defaults.colorG, SOBT.defaults.colorB, SOBT.defaults.colorA},
			getFunction = function()
				return SOBT.savedVariables.colorR, SOBT.savedVariables.colorG, SOBT.savedVariables.colorB, SOBT.savedVariables.colorA
			end,
		})

		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_COLOR,
			label = "Cooldown Color",
			tooltip = "Change the color of the text for when off balance is on cooldown.",
			setFunction = function(...) --newR, newG, newB, newA
				SOBT.savedVariables.colorR_Cooldown, SOBT.savedVariables.colorG_Cooldown, SOBT.savedVariables.colorB_Cooldown, SOBT.savedVariables.colorA_Cooldown = ...
				OBIndicatorLabel:SetColor(SOBT.savedVariables.colorR_Cooldown, SOBT.savedVariables.colorG_Cooldown, SOBT.savedVariables.colorB_Cooldown)
				OBIndicatorLabel:SetAlpha(SOBT.savedVariables.colorA_Cooldown)

				temporarilyShowTracker()
		end,
			default = {SOBT.defaults.colorR_Cooldown, SOBT.defaults.colorG_Cooldown, SOBT.defaults.colorB_Cooldown, SOBT.defaults.colorA_Cooldown},
			getFunction = function()
				return SOBT.savedVariables.colorR_Cooldown, SOBT.savedVariables.colorG_Cooldown, SOBT.savedVariables.colorB_Cooldown, SOBT.savedVariables.colorA_Cooldown
			end,
		})

		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_COLOR,
			label = "Inactive Color",
			tooltip = "Change the text color of the text for when off balance is neither active nor on cooldown.",
			setFunction = function(...) --newR, newG, newB, newA
				SOBT.savedVariables.colorR_Inactive, SOBT.savedVariables.colorG_Inactive, SOBT.savedVariables.colorB_Inactive, SOBT.savedVariables.colorA_Inactive= ...
				OBIndicatorLabel:SetColor(SOBT.savedVariables.colorR_Inactive, SOBT.savedVariables.colorG_Inactive, SOBT.savedVariables.colorB_Inactive)
				OBIndicatorLabel:SetAlpha(SOBT.savedVariables.colorA_Inactive)

				temporarilyShowTracker()
			end,
			default = {SOBT.defaults.colorR_Inactive, SOBT.defaults.colorG_Inactive, SOBT.defaults.colorB_Inactive, SOBT.defaults.colorA_Inactive},
			getFunction = function()
				return SOBT.savedVariables.colorR_Inactive, SOBT.savedVariables.colorG_Inactive, SOBT.savedVariables.colorB_Inactive, SOBT.savedVariables.colorA_Inactive
			end,
		})

		settings:AddSetting({type = LibHarvensAddonSettings.ST_SECTION,label = "Font",})

		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = "Font Size",
			tooltip = "",
			setFunction = function(value)
				SOBT.savedVariables.selectedText_font = value
				OBIndicatorLabel:SetFont(string.format("$(%s)|%s|%s", SOBT.savedVariables.fontStyle, SOBT.savedVariables.selectedText_font, SOBT.savedVariables.fontWeight))
				temporarilyShowTracker()
			end,
			getFunction = function()
				return SOBT.savedVariables.selectedText_font
			end,
			default = SOBT.defaults.selectedText_font,
			min = 18,
			max = 61,
			step = 1,
			unit = "", --optional unit
			format = "%d", --value format
		})

		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_DROPDOWN,
			label = "Font Style",
			tooltip = "",
			items = {
				{name = "GAMEPAD_MEDIUM_FONT", data = 1},
				{name = "GAMEPAD_LIGHT_FONT", data = 2},
				{name = "GAMEPAD_BOLD_FONT", data = 3},
				{name = "MEDIUM_FONT", data = 4},
				{name = "BOLD_FONT", data = 5},
			},
			getFunction = function() return SOBT.savedVariables.fontStyle end,
			setFunction = function(control, itemName, itemData)
				SOBT.savedVariables.fontStyle = itemName
				OBIndicatorLabel:SetFont(string.format("$(%s)|%s|%s", SOBT.savedVariables.fontStyle, SOBT.savedVariables.selectedText_font, SOBT.savedVariables.fontWeight))
				temporarilyShowTracker()
			end,
			default = SOBT.defaults.fontStyle
		})

		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_DROPDOWN,
			label = "Font Weight",
			tooltip = "",
			items = {
				{name = "soft-shadow-thick", data = 1},
				{name = "soft-shadow-thin", data = 2},
				{name = "thick-outline", data = 3},
			},
			getFunction = function() return SOBT.savedVariables.fontWeight end,
			setFunction = function(control, itemName, itemData)
				SOBT.savedVariables.fontWeight = itemName
				OBIndicatorLabel:SetFont(string.format("$(%s)|%s|%s", SOBT.savedVariables.fontStyle, SOBT.savedVariables.selectedText_font, SOBT.savedVariables.fontWeight))
				temporarilyShowTracker()
			end,
			default = SOBT.defaults.fontWeight
		})

		settings:AddSetting({type = LibHarvensAddonSettings.ST_SECTION,label = "Position",})

		SOBT.currentlyChangingPosition = false
		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = "Joystick Reposition",
			tooltip = "When enabled, you will be able to freely move around the UI with your right joystick.\n\nSet this to OFF after configuring position.",
			getFunction = function() return SOBT.currentlyChangingPosition end,
			setFunction = function(value)
				SOBT.currentlyChangingPosition = value
				if value == true then
					OBIndicator:SetHidden(false)
					EVENT_MANAGER:RegisterForUpdate(SOBT.name.."AdjustUI", 10,  function()
						local posX, posY = GetGamepadRightStickX(true), GetGamepadRightStickY(true)
						if posX ~= 0 or posY ~= 0 then
							SOBT.savedVariables.offset_x = SOBT.savedVariables.offset_x + 10*posX
							SOBT.savedVariables.offset_y = SOBT.savedVariables.offset_y - 10*posY

							if SOBT.savedVariables.offset_x < 0 then SOBT.savedVariables.offset_x = 0 end
							if SOBT.savedVariables.offset_y < 0 then SOBT.savedVariables.offset_y = 0 end
							if SOBT.savedVariables.offset_x > (GuiRoot:GetWidth() - OBIndicator:GetWidth()) then SOBT.savedVariables.offset_x = (GuiRoot:GetWidth() - OBIndicator:GetWidth()) end
							if SOBT.savedVariables.offset_y >(GuiRoot:GetHeight() - OBIndicator:GetHeight()) then SOBT.savedVariables.offset_y = (GuiRoot:GetHeight() - OBIndicator:GetHeight()) end

							OBIndicator:ClearAnchors()
							OBIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SOBT.savedVariables.offset_x, SOBT.savedVariables.offset_y)
						end
					end)
				else
					EVENT_MANAGER:UnregisterForUpdate(SOBT.name.."AdjustUI")
					temporarilyShowTracker()
				end
			end,
			default = SOBT.currentlyChangingPosition
		})

		--x position offset
		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = "X Offset",
			tooltip = "",
			setFunction = function(value)
				SOBT.savedVariables.offset_x = value

				OBIndicator:ClearAnchors()
				OBIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SOBT.savedVariables.offset_x, SOBT.savedVariables.offset_y)

				temporarilyShowTracker()
			end,
			getFunction = function()
				return SOBT.savedVariables.offset_x
			end,
			default = 0,
			min = 0,
			max = GuiRoot:GetWidth(),
			step = 5,
			unit = "", --optional unit
			format = "%d", --value format
		})

		--y position offset
		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = "Y Offset",
			tooltip = "",
			setFunction = function(value)
				SOBT.savedVariables.offset_y = value

				OBIndicator:ClearAnchors()
				OBIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SOBT.savedVariables.offset_x, SOBT.savedVariables.offset_y)

				temporarilyShowTracker()
			end,
			getFunction = function()
				return SOBT.savedVariables.offset_y
			end,
			default = 0,
			min = 0,
			max = GuiRoot:GetHeight(),
			step = 5,
			unit = "", --optional unit
			format = "%d", --value format
		})
	end

	EVENT_MANAGER:RegisterForUpdate(SOBT.name, 100, SOBT.OnUpdate)
	EVENT_MANAGER:RegisterForEvent(SOBT.name, EVENT_PLAYER_COMBAT_STATE, SOBT.onCombat)
end

function SOBT.OnAddOnLoaded(event, addonName)
	if addonName == SOBT.name then
		SOBT.Initialize()
		EVENT_MANAGER:UnregisterForEvent(SOBT.name, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(SOBT.name, EVENT_ADD_ON_LOADED, SOBT.OnAddOnLoaded)