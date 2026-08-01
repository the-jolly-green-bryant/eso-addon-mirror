AT = AT or {}

local function temporarilyShowLabels()
    --Hide UI 5 seconds after most recent change.
    AsylumTimers:SetHidden(false)
    EVENT_MANAGER:RegisterForUpdate(AT.name.."editUI", 5000, function()
        if SCENE_MANAGER:GetScene("hud"):GetState() == SCENE_HIDDEN or AT.savedVariables.isHidden then
            AsylumTimers:SetHidden(true)
        end
        EVENT_MANAGER:UnregisterForUpdate(AT.name.."editUI")
    end)
end

function AT.setupSettings()
    if not LibHarvensAddonSettings then return end

    --settings
	local settings = LibHarvensAddonSettings:AddAddon("Asylum Timers")
	
    settings:AddSetting({type = LibHarvensAddonSettings.ST_SECTION,label = "General",})

	settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Disable", 
        tooltip = "Disables the addon's displays.",
        default = AT.defaults.isHidden,
        setFunction = function(state) 
            AT.savedVariables.isHidden = state
			AsylumTimers:SetHidden(state)
			
			if state ==  false then
				temporarilyShowLabels()
			end
        end,
        getFunction = function() 
            return AT.savedVariables.isHidden
        end,
    })
	
	settings:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Reset Defaults",
        tooltip = "",
        buttonText = "RESET",
        clickHandler = function(control, button)
			--save
			AT.savedVariables.isHidden = AT.defaults.isHidden
		
			AT.savedVariables.selectedFontNumber_Timers = AT.defaults.selectedFontNumber_Timers
			AT.savedVariables.fontStyle = AT.defaults.fontStyle
			AT.savedVariables.fontWeight = AT.defaults.fontWeight
			
			AT.savedVariables.normalColor = AT.defaults.normalColor
			AT.savedVariables.mechColor = AT.defaults.mechColor
			AT.savedVariables.enragedColor = AT.defaults.enragedColor
			AT.savedVariables.soonColor = AT.defaults.soonColor
			AT.savedVariables.downedColor = AT.defaults.downedColor
			
			AT.savedVariables.offset_x = AT.defaults.offset_x
			AT.savedVariables.offset_y = AT.defaults.offset_y
			
			--apply
			AT.updateFont(string.format("$(%s)|%s|%s", AT.savedVariables.fontStyle, AT.savedVariables.selectedFontNumber_Timers, AT.savedVariables.fontWeight))
			
			AsylumTimers:ClearAnchors()
			AsylumTimers:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, AT.savedVariables.offset_x, AT.savedVariables.offset_y)			
			
			temporarilyShowLabels()
			
		end,
    })
	
    settings:AddSetting({type = LibHarvensAddonSettings.ST_SECTION,label = "Font",})

	settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Font Size",
        tooltip = "",
        setFunction = function(value)
			AT.savedVariables.selectedFontNumber_Timers = value
			AT.updateFont(string.format("$(%s)|%s|%s", AT.savedVariables.fontStyle, AT.savedVariables.selectedFontNumber_Timers, AT.savedVariables.fontWeight))
			temporarilyShowLabels()
		end,
        getFunction = function()
            return AT.savedVariables.selectedFontNumber_Timers
        end,
        default = AT.defaults.selectedFontNumber_Timers,
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
        getFunction = function() return AT.savedVariables.fontStyle end,
        setFunction = function(control, itemName, itemData) 
            AT.savedVariables.fontStyle = itemName
			AT.updateFont(string.format("$(%s)|%s|%s", AT.savedVariables.fontStyle, AT.savedVariables.selectedFontNumber_Timers, AT.savedVariables.fontWeight))
			temporarilyShowLabels()
        end,
        default = AT.defaults.fontStyle
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
        getFunction = function() return AT.savedVariables.fontWeight end,
        setFunction = function(control, itemName, itemData) 
            AT.savedVariables.fontWeight = itemName
			AT.updateFont(string.format("$(%s)|%s|%s", AT.savedVariables.fontStyle, AT.savedVariables.selectedFontNumber_Timers, AT.savedVariables.fontWeight))
			temporarilyShowLabels()
        end,
        default = AT.defaults.fontWeight
    })

    settings:AddSetting({type = LibHarvensAddonSettings.ST_SECTION,label = "Colors",})

	settings:AddSetting({
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Normal Color",
        tooltip = "Change the color of the timer when there are no other mechanics active.",
        setFunction = function(...) --newR, newG, newB, newA
            AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha = ...
        
			temporarilyShowLabels()
		end,
        default = {AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha},
        getFunction = function()
            return AT.savedVariables.normalColor.red, AT.savedVariables.normalColor.green, AT.savedVariables.normalColor.blue, AT.savedVariables.normalColor.alpha
        end,
    })
	
	settings:AddSetting({
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Mechanic Color",
        tooltip = "Change the color of the timer when there is an active mechanic (e.g. kite, interrupt, jump).",
        setFunction = function(...) --newR, newG, newB, newA
            AT.savedVariables.mechColor.red, AT.savedVariables.mechColor.green, AT.savedVariables.mechColor.blue, AT.savedVariables.mechColor.alpha = ...
       
			temporarilyShowLabels()
	    end,
        default = {AT.savedVariables.mechColor.red, AT.savedVariables.mechColor.green, AT.savedVariables.mechColor.blue, AT.savedVariables.mechColor.alpha},
        getFunction = function()
            return AT.savedVariables.mechColor.red, AT.savedVariables.mechColor.green, AT.savedVariables.mechColor.blue, AT.savedVariables.mechColor.alpha
        end,
    })
	
	settings:AddSetting({
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Enraged Color",
        tooltip = "Change the color of the timer when a miniboss is enraged.",
        setFunction = function(...) --newR, newG, newB, newA
            AT.savedVariables.enragedColor.red, AT.savedVariables.enragedColor.green, AT.savedVariables.enragedColor.blue, AT.savedVariables.enragedColor.alpha = ...
			
			temporarilyShowLabels()
		end,
        default = {AT.savedVariables.enragedColor.red, AT.savedVariables.enragedColor.green, AT.savedVariables.enragedColor.blue, AT.savedVariables.enragedColor.alpha},
        getFunction = function()
            return AT.savedVariables.enragedColor.red, AT.savedVariables.enragedColor.green, AT.savedVariables.enragedColor.blue, AT.savedVariables.enragedColor.alpha
        end,
    })
	
	settings:AddSetting({
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Soon Color",
        tooltip = "Change the color of the mechanic timer when it is expected at any moment.",
        setFunction = function(...) --newR, newG, newB, newA
            AT.savedVariables.soonColor.red, AT.savedVariables.soonColor.green, AT.savedVariables.soonColor.blue, AT.savedVariables.soonColor.alpha = ...
        
			temporarilyShowLabels()
		end,
        default = {AT.savedVariables.soonColor.red, AT.savedVariables.soonColor.green, AT.savedVariables.soonColor.blue, AT.savedVariables.soonColor.alpha},
        getFunction = function()
            return AT.savedVariables.soonColor.red, AT.savedVariables.soonColor.green, AT.savedVariables.soonColor.blue, AT.savedVariables.soonColor.alpha
        end,
    })
	
	settings:AddSetting({
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Downed Color",
        tooltip = "Change the color of the timer when a miniboss is respawning.",
        setFunction = function(...) --newR, newG, newB, newA
            AT.savedVariables.downedColor.red, AT.savedVariables.downedColor.green, AT.savedVariables.downedColor.blue, AT.savedVariables.downedColor.alpha = ...
        
			temporarilyShowLabels()
		end,
        default = {AT.savedVariables.downedColor.red, AT.savedVariables.downedColor.green, AT.savedVariables.downedColor.blue, AT.savedVariables.downedColor.alpha},
        getFunction = function()
            return AT.savedVariables.downedColor.red, AT.savedVariables.downedColor.green, AT.savedVariables.downedColor.blue, AT.savedVariables.downedColor.alpha
        end,
    })
	
    settings:AddSetting({type = LibHarvensAddonSettings.ST_SECTION,label = "Position",})

	AT.currentlyChangingPosition = false
	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Joystick Reposition",
		tooltip = "When enabled, you will be able to freely move around the UI with your right joystick.\n\nSet this to OFF after configuring position.",
		getFunction = function() return AT.currentlyChangingPosition end,
		setFunction = function(value) 
			AT.currentlyChangingPosition = value
			if value == true then
				AsylumTimers:SetHidden(false)
				EVENT_MANAGER:RegisterForUpdate(AT.name.."AdjustUI", 10,  function() 
					local posX, posY = GetGamepadRightStickX(true), GetGamepadRightStickY(true)
					if posX ~= 0 or posY ~= 0 then 
						AT.savedVariables.offset_x = AT.savedVariables.offset_x + 10*posX
						AT.savedVariables.offset_y = AT.savedVariables.offset_y - 10*posY

						if AT.savedVariables.offset_x < 0 then AT.savedVariables.offset_x = 0 end
						if AT.savedVariables.offset_y < 0 then AT.savedVariables.offset_y = 0 end
						if AT.savedVariables.offset_x > (GuiRoot:GetWidth() - AsylumTimers:GetWidth()) then AT.savedVariables.offset_x = (GuiRoot:GetWidth() - AsylumTimers:GetWidth()) end
						if AT.savedVariables.offset_y >(GuiRoot:GetHeight() - AsylumTimers:GetHeight()) then AT.savedVariables.offset_y = (GuiRoot:GetHeight() - AsylumTimers:GetHeight()) end

						AsylumTimers:ClearAnchors()
						AsylumTimers:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, AT.savedVariables.offset_x, AT.savedVariables.offset_y)
					end 
				end)
			else
				EVENT_MANAGER:UnregisterForUpdate(AT.name.."AdjustUI")
				temporarilyShowLabels()
			end
		end,
		default = AT.currentlyChangingPosition
	})

	--x position offset
	settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "X Offset",
        tooltip = "",
        setFunction = function(value)
			AT.savedVariables.offset_x = value
			
			AsylumTimers:ClearAnchors()
			AsylumTimers:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, AT.savedVariables.offset_x, AT.savedVariables.offset_y)
			
			temporarilyShowLabels()
		end,
        getFunction = function()
            return AT.savedVariables.offset_x
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
			AT.savedVariables.offset_y = value
			
			AsylumTimers:ClearAnchors()
			AsylumTimers:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, AT.savedVariables.offset_x, AT.savedVariables.offset_y)
			
			temporarilyShowLabels()
		end,
        getFunction = function()
            return AT.savedVariables.offset_y
        end,
        default = 0,
        min = 0,
        max = GuiRoot:GetHeight(),
        step = 5,
        unit = "", --optional unit
        format = "%d", --value format
    })
end