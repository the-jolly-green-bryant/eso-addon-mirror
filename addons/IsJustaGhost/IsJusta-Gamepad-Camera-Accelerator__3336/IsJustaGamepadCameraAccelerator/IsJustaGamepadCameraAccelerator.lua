--[[
- - -2
○ added settings to allow easy access to setting the max look speed
]]

local addonInfo = {
	displayName = "|cFF00FFIsJusta|r |cffffffGamepad Camera Accelerator|r",
	name = "IsJustaGamepadCameraAccelerator",
	version = "2.1",
}

local defaults = {
	maxValue = 2.5, -- 1.05
}
local recomendedMax = 5

local svVersion = 1

local savedVars = {}

local function getGamepadCameraSensitivity()
	local panel = ZO_SharedOptions_SettingsData[SETTING_PANEL_CAMERA] or {}
	local gamepadSetting = panel[SETTING_TYPE_GAMEPAD] or {}
	return gamepadSetting[GAMEPAD_SETTING_CAMERA_SENSITIVITY]
end

local function setMaxGamepadCameraSensitivity(maxValue, onLoad)
	local gamepadCameraSensitivity = getGamepadCameraSensitivity()
	if gamepadCameraSensitivity ~= nil then
		gamepadCameraSensitivity.maxValue = maxValue
		
		if not onLoad then
			-- Applies the new max as the current camera sensitivity.
			SetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_CAMERA_SENSITIVITY, tostring(maxValue))
		end
	else
		d( '-- GAMEPAD_SETTING_CAMERA_SENSITIVITY has not yet been initialized.')
	end
end

local function initializeSettings()
	local LAM2 = LibAddonMenu2
	if not LAM2 then
		return
	end
	
	local panelData = {
		type = "panel",
		name = addonInfo.displayName,
		displayName = addonInfo.displayName,
		author = "IsJustaGhost",
		version = addonInfo.version,
		registerForRefresh = true,
		registerForDefaults = true
	}
	LAM2:RegisterAddonPanel(addonInfo.name .. '_LAM', panelData)

	local optionsTable = {
		{ type = "header",
			width = "full",
			name = GetString(SI_IJA_GAMEPADCAMERAACCELERATOR_NORMAL),
		},
		{ type = "slider",		-- actionBar scale
            name = GetString(SI_IJA_GAMEPADCAMERAACCELERATOR_MAX),
			tooltip = GetString(SI_IJA_GAMEPADCAMERAACCELERATOR_SLIDER_TOOTIP),
			min = 1.05,
			max = recomendedMax,
			step = 0.05,
			decimals = 2,
			getFunc = function() return savedVars.maxValue end,
			setFunc = function(value)
				savedVars.maxValue = value
				setMaxGamepadCameraSensitivity(value)
			end,
		--	warning = function() if savedVars.maxValue > 3 then return "Anything above 3 may be too fast." end end,
			width = "full",
		},
		{ type = "header",
			width = "full",
			name = GetString(SI_IJA_GAMEPADCAMERAACCELERATOR_FORFUN),
		},
		{ type = "slider",		-- actionBar scale
            name = GetString(SI_IJA_GAMEPADCAMERAACCELERATOR_MAX),
			tooltip = GetString(SI_IJA_GAMEPADCAMERAACCELERATOR_FORFUN_TOOTIP),
			min = 1.05,
			max = 100,
			step = 0.5,
			decimals = 1,
			getFunc = function() return savedVars.maxValue end,
			setFunc = function(value)
				savedVars.maxValue = value
				setMaxGamepadCameraSensitivity(value)
			end,
			warning = function()
				local maxValue = tonumber(savedVars.maxValue) or 0
				if maxValue > recomendedMax then 
					return GetString(SI_IJA_GAMEPADCAMERAACCELERATOR_FORFUN_WARNING)
				end 
			end,
			width = "full",
		},
		{ type = "divider",
			height = 10,
			width = "full",
		},
		{ type = "description",
			text = GetString(SI_IJA_GAMEPADCAMERAACCELERATOR_DESCRIPTION), -- or string id or function returning a string
		--	title = addonInfo.displayName,
			width = "full",
		}
	}
	LAM2:RegisterOptionControls(addonInfo.name .. '_LAM', optionsTable)
	
	local function onPanelCreated(control)
		if control:GetName() == 'IJA_GAMEPADCAMERAACCELERATOR_EDITBOX' then
			CALLBACK_MANAGER:UnregisterCallback("LAM-RefreshPanel", onPanelCreated)
		end
	end
	CALLBACK_MANAGER:RegisterCallback("LAM-RefreshPanel", onPanelCreated)
end

local function onLoaded(_, name)
	if name ~= addonInfo.name then return end
	EVENT_MANAGER:UnregisterForEvent(addonInfo.name, EVENT_ADD_ON_LOADED)
	
	savedVars = ZO_SavedVars:NewAccountWide("IJA_GamepadCameraAccelerator_SavedVars", svVersion, nil, defaults, GetWorldName())
	setMaxGamepadCameraSensitivity(savedVars.maxValue, true)
	initializeSettings()
end
EVENT_MANAGER:RegisterForEvent(addonInfo.name, EVENT_ADD_ON_LOADED, onLoaded)



	
--[[


local cursorId = nil
local x = 0
local y = 0
local sensitivityFactor = 0

local function updateCursorPosition()
    local dx, dy = GetUIMousePosition()
    dx, dy = zo_clampLength2D(dx, dy, 1.0) -- clamp dpad output
    local frameDelta = GetFrameDeltaNormalizedForTargetFramerate()
    dx = dx * frameDelta * ZO_CHAMPION_CURSOR_SPEED * sensitivityFactor
    dy = -dy * frameDelta * ZO_CHAMPION_CURSOR_SPEED * sensitivityFactor

    control:SetAnchor(CENTER, GuiRoot, TOPLEFT, x + dx, y + dy)
    x, y = control:GetCenter() -- store clamped values

    local counterScrollX = (x - initialX) * ZO_CHAMPION_COUNTERSCROLL_FACTOR_X
    local counterScrollY = (y - initialY) * -ZO_CHAMPION_COUNTERSCROLL_FACTOR_Y

    CHAMPION_PERKS:SetCameraPanXY(counterScrollX, counterScrollY)

    local constellation = CHAMPION_PERKS:GetChosenConstellation()

    local mouseOverControl
    if WINDOW_MANAGER:AreCustomCursorsEnabled() then
        WINDOW_MANAGER:UpdateCursorPosition(cursorId, x, y)
        mouseOverControl = WINDOW_MANAGER:GetControlAtCursor(cursorId) 
    else
        mouseOverControl = WINDOW_MANAGER:GetControlAtPoint(x, y)
    end
    
    local targetSensitivity
    if mouseOverControl and mouseOverControl.star then
        constellation:SelectStar(mouseOverControl.star)
        targetSensitivity = ZO_CHAMPION_SELECTING_STAR_SENSITIVITY
    else
        constellation:SelectStar(nil)
        targetSensitivity = 1
    end
end

	EVENT_MANAGER:RegisterForUpdate('IJA_MousePointerZoom', 10, function()
		if SCENE_MANAGER:IsInUIMode() then
			if cursorId == nil then
				cursorId = WINDOW_MANAGER:CreateCursor(200, 200)
			end
			updateCursorPosition()
		else
            if cursorId then
                WINDOW_MANAGER:DestroyCursor(cursorId)
                cursorId = nil
            end
		end
	end)
	


/script d(GetUIMousePosition())
LAM2.util.RequestRefreshIfNeeded(IJA_GAMEPADCAMERAACCELERATOR_EDITBOX)


ZO_SharedOptions_SettingsData[SETTING_PANEL_CAMERA][SETTING_TYPE_GAMEPAD][].maxValue

--	ZO_SharedOptions.AddTableToPanel(SETTING_PANEL_CAMERA, Gamepad_Camera_ControlData)
	
local Gamepad_Camera_ControlData = {
    --Gamepad
    [SETTING_TYPE_GAMEPAD] = {
        --Options_Gamepad_CameraSensitivity
        [GAMEPAD_SETTING_CAMERA_SENSITIVITY] = {
            controlType = OPTIONS_SLIDER,
            system = SETTING_TYPE_GAMEPAD,
            settingId = GAMEPAD_SETTING_CAMERA_SENSITIVITY,
            panel = SETTING_PANEL_CAMERA,
            text = SI_GAMEPAD_OPTIONS_CAMERA_SENSITIVITY,
            minValue = 0.65,
            maxValue = defaults.maxValue,
            valueFormat = "%.2f",
            showValue = true,
            showValueMin = 0,
            showValueMax = 100,
        },
        --Options_Gamepad_InvertY
        [GAMEPAD_SETTING_INVERT_Y] = {
            controlType = OPTIONS_CHECKBOX,
            system = SETTING_TYPE_GAMEPAD,
            settingId = GAMEPAD_SETTING_INVERT_Y,
            panel = SETTING_PANEL_CAMERA,
            text = SI_GAMEPAD_OPTIONS_INVERT_Y,
        },
    },
}


do
    local PIN_MOVEMENT_PERCENT = .95
    local PIN_CONSTANT_PERCENT = 1 - PIN_MOVEMENT_PERCENT
    local STRESS_RESISTANCE_FACTOR = .5
    local APPROACH_AMOUNT_PER_NORMALIZED_FRAME = .4
	
    function ZO_Lockpick:UpdateChamber(chamberIndex, stress)
        local spring = self.springs[chamberIndex]
        local chamberState, chamberProgress = GetChamberState(chamberIndex)
        spring.totalProgress = (chamberState + chamberProgress) / (NUM_LOCKPICK_CHAMBER_STATES + 1)
        spring.interpolatedChamberProgress = zo_deltaNormalizedLerp(spring.interpolatedChamberProgress, spring.totalProgress, APPROACH_AMOUNT_PER_NORMALIZED_FRAME)
        local springResistance = 0
        local baseSpringResistance = 0
        if stress then
            baseSpringResistance = stress * STRESS_RESISTANCE_FACTOR
            springResistance = baseSpringResistance * PIN_MOVEMENT_PERCENT * spring.height / (NUM_LOCKPICK_CHAMBER_STATES + 1)
        end
        spring:SetHeight((1 - spring.interpolatedChamberProgress) * PIN_MOVEMENT_PERCENT * spring.height + spring.height * PIN_CONSTANT_PERCENT + springResistance)

		if stress then
            self:ApplyLoosenessToChamber(chamberIndex, baseSpringResistance)
            if chamberProgress < 1 and stress == 0 then
                self:PlayVibration(0.0, self.defaultVibration)
            else
				local lvl = self.defaultVibration + (stress * 0.75)
                self:PlayVibration(lvl, lvl)
            --    self:PlayVibration(0, self.defaultVibration + (stress * 0.75))
            end
        end
    end
end

]]