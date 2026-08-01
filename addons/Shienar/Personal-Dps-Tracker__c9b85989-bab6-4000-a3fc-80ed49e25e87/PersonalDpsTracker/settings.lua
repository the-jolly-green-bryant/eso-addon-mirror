PDT = PDT or {}

local function temporarilyShowDpsLabel()
    --Hide UI 5 seconds after most recent change.
    PersonalDpsTracker:SetHidden(false)
    EVENT_MANAGER:RegisterForUpdate(PDT.name.."_editDPS", 5000, function()
        if SCENE_MANAGER:GetScene("hud"):GetState() == SCENE_HIDDEN or PDT.savedVariables.isHidden then
            PersonalDpsTracker:SetHidden(true)
        end
        EVENT_MANAGER:UnregisterForUpdate(PDT.name.."_editDPS")
    end)
end

local function temporarilyShowDmgTypes()
    --Hide UI 5 seconds after most recent change.
    DMGTypeBreakdown:SetHidden(false)
    EVENT_MANAGER:RegisterForUpdate(PDT.name.."_editDmgTypes", 5000, function()
        if SCENE_MANAGER:GetScene("hud"):GetState() == SCENE_HIDDEN or PDT.savedVariables.banner_hidden then
            DMGTypeBreakdown:SetHidden(true)
        end
        EVENT_MANAGER:UnregisterForUpdate(PDT.name.."_editDmgTypes")
    end)
end

function PDT.setupSettings()
    if not LibHarvensAddonSettings then return end
    --Settings
	local settings = LibHarvensAddonSettings:AddAddon("Personal Dps Tracker")

    settings:AddSetting({type = LibHarvensAddonSettings.ST_SECTION,label = "General",})

	settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Hide Tracker?", 
        tooltip = "Disables the tracker when set to \"On\"",
        default = PDT.defaults.isHidden,
        setFunction = function(state) 
            PDT.savedVariables.isHidden = state
			PersonalDpsTracker:SetHidden(state)
			
			if state == false then
				PDT.updateText()

				temporarilyShowDpsLabel()
			end
        end,
        getFunction = function() 
            return PDT.savedVariables.isHidden
        end,
    })
	
	settings:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Reset Defaults",
        tooltip = "",
        buttonText = "RESET",
        clickHandler = function(control, button)
			PDT.savedVariables.colorR = PDT.defaults.colorR
			PDT.savedVariables.colorG = PDT.defaults.colorG
			PDT.savedVariables.colorB = PDT.defaults.colorB
			PDT.savedVariables.colorA = PDT.defaults.colorA

			PDT.savedVariables.isHidden = PDT.defaults.isHidden
			PDT.savedVariables.offset_x = PDT.defaults.offset_x
			PDT.savedVariables.offset_y = PDT.defaults.offset_y

			PDT.savedVariables.banner_hidden = PDT.defaults.banner_hidden
			PDT.savedVariables.banner_offset_x = PDT.defaults.banner_offset_x
			PDT.savedVariables.banner_offset_y = PDT.defaults.banner_offset_y

            PDT.savedVariables.fontStyle = PDT.defaults.fontStyle
            PDT.savedVariables.fontSize = PDT.defaults.fontSize
            PDT.savedVariables.fontWeight = PDT.defaults.fontWeight

            PDT.savedVariables.alignment = PDT.defaults.alignment
            PDT.savedVariables.alignmentName = PDT.defaults.alignmentName

	        PersonalDpsTrackerLabel:SetFont(string.format("$(%s)|%s|%s", PDT.savedVariables.fontStyle, PDT.savedVariables.fontSize, PDT.savedVariables.fontWeight))
			
			PersonalDpsTracker:SetHidden(PDT.savedVariables.isHidden)
			PersonalDpsTrackerLabel:SetColor(PDT.savedVariables.colorR, PDT.savedVariables.colorG, PDT.savedVariables.colorB)
			PersonalDpsTrackerLabel:SetAlpha(PDT.savedVariables.colorA)
            PersonalDpsTracker:ClearAnchors()
            PersonalDpsTracker:SetAnchor(PDT.savedVariables.alignment, GuiRoot, TOPLEFT, PDT.savedVariables.offset_x, PDT.savedVariables.offset_y)
			
			DMGTypeBreakdown:SetHidden(PDT.savedVariables.banner_hidden)
			DMGTypeBreakdown:ClearAnchors()
			DMGTypeBreakdown:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PDT.savedVariables.banner_offset_x, PDT.savedVariables.banner_offset_y)
			
			
			PDT.savedVariables.displayText = PDT.defaults.displayText
			PDT.savedVariables.displayText_Boss = PDT.defaults.displayText_Boss

            PDT.savedVariables.abbreviateNumber = PDT.defaults.abbreviateNumber
            PDT.savedVariables.precision = PDT.defaults.precision
            PDT.savedVariables.capitalization = PDT.defaults.capitalization
			PDT.updateText()
			
			temporarilyShowDpsLabel()
		end,
    })
	
    settings:AddSetting({type = LibHarvensAddonSettings.ST_SECTION,label = "Text",})

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_EDIT,
        label = "Display Text",
        tooltip = "This setting lets you modify the display text.\n\n"..
					"This text will display when you aren't fighting a boss.\n\n"..
					"<d> will be replaced with your overall DPS\n"..
					"<D> will be replaced with your overall damage\n"..
					"<b> will be replaced with your boss DPS\n"..
					"<B> will be replaced with your overall damage to bosses\n"..
					"<t> will be replaced with the fight time\n",
        default = PDT.defaults.displayText,
        setFunction = function(value)
            PDT.savedVariables.displayText = value

			PDT.updateText()

			temporarilyShowDpsLabel()
        end,
        getFunction = function()
            return PDT.savedVariables.displayText
        end,
    })
	
	settings:AddSetting({
        type = LibHarvensAddonSettings.ST_EDIT,
        label = "Display Text (Boss)",
        tooltip = "This setting lets you modify the display text.\n\n"..
					"This text will display when you are fighting a boss.\n\n"..
					"<d> will be replaced with your overall DPS\n"..
					"<D> will be replaced with your overall damage\n"..
					"<b> will be replaced with your boss DPS\n"..
					"<B> will be replaced with your overall damage to bosses\n"..
					"<s> will be replaced with your share of damage to the boss (in %, e.g. 25.3%)\n" ..
					"<S> will be replaced with your share of damage to the boss (as a fraction, e.g. 1/4.3)\n" ..
					"<t> will be replaced with the fight time\n" ..
					"\nNB: if boss heals or shields, your share (<s> or <S>) can't be determined reliably. * symbol will be shown next to the value to signal that\n",
        default = PDT.defaults.displayText_Boss,
        setFunction = function(value)
            PDT.savedVariables.displayText_Boss = value
			
			PDT.updateText()
			
			temporarilyShowDpsLabel()
        end,
        getFunction = function()
            return PDT.savedVariables.displayText_Boss
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Abbreviate Number", 
        tooltip = "Abbreviates longer numbers\n\n(e.g. 4,123,561 -> 4.1m)",
        default = PDT.defaults.abbreviateNumber,
        setFunction = function(state) 
            PDT.savedVariables.abbreviateNumber = state

			PDT.updateText()
			temporarilyShowDpsLabel()
        end,
        getFunction = function() 
            return PDT.savedVariables.abbreviateNumber
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Abbreviation Precision",
        tooltip = "Choose the decimal precision for number abbreviations.",
        setFunction = function(value)
			PDT.savedVariables.precision = value
            
			PDT.updateText()
			temporarilyShowDpsLabel()
		end,
        getFunction = function()
            return PDT.savedVariables.precision
        end,
        default = 1,
        min = 0,
        max = 2,
        step = 1,
        unit = "", --optional unit
        format = "%d", --value format
        disable = function() return not PDT.savedVariables.abbreviateNumber end, 
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Capitalized Abbreviation", 
        tooltip = "e.g 4.12M vs 4.12m",
        default = PDT.defaults.capitalization,
        setFunction = function(state) 
            PDT.savedVariables.capitalization = state

			PDT.updateText()
			temporarilyShowDpsLabel()
        end,
        getFunction = function() 
            return PDT.savedVariables.capitalization
        end,
        disable = function() return not PDT.savedVariables.abbreviateNumber end, 
    })
	
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_COLOR,
        label = "Text Color",
        tooltip = "Change the text color of the dps tracker.",
        setFunction = function(...) --newR, newG, newB, newA
            PDT.savedVariables.colorR, PDT.savedVariables.colorG, PDT.savedVariables.colorB, PDT.savedVariables.colorA = ...
			PersonalDpsTrackerLabel:SetColor(PDT.savedVariables.colorR, PDT.savedVariables.colorG, PDT.savedVariables.colorB)
			PersonalDpsTrackerLabel:SetAlpha(PDT.savedVariables.colorA)
        
			temporarilyShowDpsLabel()
		end,
        default = {PDT.defaults.colorR, PDT.defaults.colorG, PDT.defaults.colorB, PDT.defaults.colorA},
        getFunction = function()
            return PDT.savedVariables.colorR, PDT.savedVariables.colorG, PDT.savedVariables.colorB, PDT.savedVariables.colorA
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Font Size",
        tooltip = "",
        setFunction = function(value)
			PDT.savedVariables.fontSize = value

	        PersonalDpsTrackerLabel:SetFont(string.format("$(%s)|%s|%s", PDT.savedVariables.fontStyle, PDT.savedVariables.fontSize, PDT.savedVariables.fontWeight))

			temporarilyShowDpsLabel()
		end,
        getFunction = function()
            return PDT.savedVariables.fontSize
        end,
        default = PDT.defaults.fontSize,
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
        getFunction = function() return PDT.savedVariables.fontStyle end,
        setFunction = function(control, itemName, itemData) 
            PDT.savedVariables.fontStyle = itemName
	        PersonalDpsTrackerLabel:SetFont(string.format("$(%s)|%s|%s", PDT.savedVariables.fontStyle, PDT.savedVariables.fontSize, PDT.savedVariables.fontWeight))
            temporarilyShowDpsLabel()
        end,
        default = PDT.defaults.fontStyle
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
        getFunction = function() return PDT.savedVariables.fontWeight end,
        setFunction = function(control, itemName, itemData) 
            PDT.savedVariables.fontWeight = itemName
	        PersonalDpsTrackerLabel:SetFont(string.format("$(%s)|%s|%s", PDT.savedVariables.fontStyle, PDT.savedVariables.fontSize, PDT.savedVariables.fontWeight))
            temporarilyShowDpsLabel()
        end,
        default = PDT.defaults.fontWeight
    })

    settings:AddSetting({type = LibHarvensAddonSettings.ST_SECTION,label = "Position",})

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_DROPDOWN,
        label = "Alignment",
        tooltip = "Determines which part of the label gets anchored to the screen. The label will expand in the opposit direction(s)",
        items = {
            {name = "Left", data = 1},
            {name = "Right", data = 2},
            {name = "Center", data = 3},
        },
        getFunction = function() return PDT.savedVariables.alignmentName end,
        setFunction = function(control, itemName, itemData)
            PDT.savedVariables.alignmentName = itemName
            if itemData.data == 1 then
                PDT.savedVariables.alignment = TOPLEFT
            elseif itemData.data == 2 then
                PDT.savedVariables.alignment = TOPRIGHT
            else
                PDT.savedVariables.alignment = TOP
            end
            
            PersonalDpsTracker:ClearAnchors()
            PersonalDpsTracker:SetAnchor(PDT.savedVariables.alignment, GuiRoot, TOPLEFT, PDT.savedVariables.offset_x, PDT.savedVariables.offset_y)

            temporarilyShowDpsLabel()
        end,
        default = PDT.defaults.alignmentName
    })

	PDT.currentlyChangingPosition = false
	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Joystick Reposition",
		tooltip = "When enabled, you will be able to freely move around the UI with your right joystick.\n\nSet this to OFF after configuring position.",
		getFunction = function() return PDT.currentlyChangingPosition end,
		setFunction = function(value) 
			PDT.currentlyChangingPosition = value
			if value == true then
				PersonalDpsTracker:SetHidden(false)
				EVENT_MANAGER:RegisterForUpdate(PDT.name.."AdjustUI", 10,  function() 
					local posX, posY = GetGamepadRightStickX(true), GetGamepadRightStickY(true)
					if posX ~= 0 or posY ~= 0 then 
						PDT.savedVariables.offset_x = PDT.savedVariables.offset_x + 10*posX
						PDT.savedVariables.offset_y = PDT.savedVariables.offset_y - 10*posY

						if PDT.savedVariables.offset_x < 0 then PDT.savedVariables.offset_x = 0 end
						if PDT.savedVariables.offset_y < 0 then PDT.savedVariables.offset_y = 0 end
						if PDT.savedVariables.offset_x > (GuiRoot:GetWidth() - 20) then PDT.savedVariables.offset_x = (GuiRoot:GetWidth() - 20) end
						if PDT.savedVariables.offset_y >(GuiRoot:GetHeight() - 20) then PDT.savedVariables.offset_y = (GuiRoot:GetHeight() - 20) end

						PersonalDpsTracker:ClearAnchors()
						PersonalDpsTracker:SetAnchor(PDT.savedVariables.alignment, GuiRoot, TOPLEFT, PDT.savedVariables.offset_x, PDT.savedVariables.offset_y)
					end 
				end)
			else
				EVENT_MANAGER:UnregisterForUpdate(PDT.name.."AdjustUI")
				temporarilyShowDpsLabel()
			end
		end,
		default = PDT.currentlyChangingPosition
	})

	settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "X Offset",
        tooltip = "",
        setFunction = function(value)
			PDT.savedVariables.offset_x = value

            PersonalDpsTracker:ClearAnchors()
            PersonalDpsTracker:SetAnchor(PDT.savedVariables.alignment, GuiRoot, TOPLEFT, PDT.savedVariables.offset_x, PDT.savedVariables.offset_y)
			
			temporarilyShowDpsLabel()
		end,
        getFunction = function()
            return PDT.savedVariables.offset_x
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
			PDT.savedVariables.offset_y = value
			
            PersonalDpsTracker:ClearAnchors()
            PersonalDpsTracker:SetAnchor(PDT.savedVariables.alignment, GuiRoot, TOPLEFT, PDT.savedVariables.offset_x, PDT.savedVariables.offset_y)
			
			temporarilyShowDpsLabel()
		end,
        getFunction = function()
            return PDT.savedVariables.offset_y
        end,
        default = 0,
        min = 0,
        max = GuiRoot:GetHeight(),
        step = 5,
        unit = "", --optional unit
        format = "%d", --value format
    })

    settings:AddSetting({type = LibHarvensAddonSettings.ST_SECTION,label = "Damage Types",})

	settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Hide Damage Type Breakdown?",
        tooltip = "Disables the damagetype breakdown when set to \"On\"\n\n"..
			"Note: When two percentages are visible, the leftmost one is for boss damage and the rightmost one is for overall damage.",
        default = PDT.defaults.banner_hidden,
        setFunction = function(state) 
            PDT.savedVariables.banner_hidden = state
			DMGTypeBreakdown:SetHidden(state)
			
			if state == false then
				PDT.updateBannerText()

				temporarilyShowDmgTypes()
			end
        end,
        getFunction = function() 
            return PDT.savedVariables.banner_hidden
        end,
    })

	PDT.currentlyChangingBannerPosition = false
	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Joystick Reposition",
		tooltip = "When enabled, you will be able to freely move around the UI with your right joystick.\n\nSet this to OFF after configuring position.",
		getFunction = function() return PDT.currentlyChangingBannerPosition end,
		setFunction = function(value) 
			PDT.currentlyChangingBannerPosition = value
			if value == true then
				DMGTypeBreakdown:SetHidden(false)
				EVENT_MANAGER:RegisterForUpdate(PDT.name.."AdjustDMGTypeUI", 10,  function() 
					local posX, posY = GetGamepadRightStickX(true), GetGamepadRightStickY(true)
					if posX ~= 0 or posY ~= 0 then 
						PDT.savedVariables.banner_offset_x = PDT.savedVariables.banner_offset_x + 10*posX
						PDT.savedVariables.banner_offset_y = PDT.savedVariables.banner_offset_y - 10*posY

						if PDT.savedVariables.banner_offset_x < 0 then PDT.savedVariables.banner_offset_x = 0 end
						if PDT.savedVariables.banner_offset_y < 0 then PDT.savedVariables.banner_offset_y = 0 end
						if PDT.savedVariables.banner_offset_x > (GuiRoot:GetWidth() - 20) then PDT.savedVariables.banner_offset_x = (GuiRoot:GetWidth() - 20) end
						if PDT.savedVariables.banner_offset_y >(GuiRoot:GetHeight() - 20) then PDT.savedVariables.banner_offset_y = (GuiRoot:GetHeight() - 20) end

						DMGTypeBreakdown:ClearAnchors()
						DMGTypeBreakdown:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PDT.savedVariables.banner_offset_x, PDT.savedVariables.banner_offset_y)
					end 
				end)
			else
				EVENT_MANAGER:UnregisterForUpdate(PDT.name.."AdjustDMGTypeUI")
				temporarilyShowDmgTypes()
			end
		end,
		default = PDT.currentlyChangingBannerPosition
	})

	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_SLIDER,
        label = "X Offset",
        tooltip = "",
        setFunction = function(value)
			PDT.savedVariables.banner_offset_x = value
			
			DMGTypeBreakdown:ClearAnchors()
			DMGTypeBreakdown:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PDT.savedVariables.banner_offset_x, PDT.savedVariables.banner_offset_y)
			
			temporarilyShowDmgTypes()
		end,
        getFunction = function()
            return PDT.savedVariables.banner_offset_x
        end,
        default = 0,
        min = 0,
        max = GuiRoot:GetWidth(),
        step = 5,
        unit = "", --optional unit
        format = "%d", --value format
	})

	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Y Offset",
        tooltip = "",
        setFunction = function(value)
			PDT.savedVariables.banner_offset_y = value
			
			DMGTypeBreakdown:ClearAnchors()
			DMGTypeBreakdown:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PDT.savedVariables.banner_offset_x, PDT.savedVariables.banner_offset_y)
			
			temporarilyShowDmgTypes()
		end,
        getFunction = function()
            return PDT.savedVariables.banner_offset_y
        end,
        default = 0,
        min = 0,
        max = GuiRoot:GetHeight(),
        step = 5,
        unit = "", --optional unit
        format = "%d", --value format
	})

end