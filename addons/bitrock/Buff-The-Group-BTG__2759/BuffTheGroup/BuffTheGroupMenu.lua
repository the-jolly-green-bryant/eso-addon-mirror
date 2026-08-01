btg = btg or { }

function btg.buildMenu()
	local panelData = {
		type = "panel",
		name = btg.name,
		displayName = "BuffTheGroup",
		author = "bitrock, garlicmoon",
		version = ""..btg.version,
		registerForDefaults = true,
		registerForRefresh = true
	}

	local options = {
		{
			type = "header",
			name = "Settings",
		},
		{
			type = "checkbox",
			name = "Enabled",
			tooltip = "Toggles the UI",
			default = btg.defaults.enabled,
			getFunc = function() 
				return btg.savedVars.enabled
			end,
			setFunc = function(value)
				btg.savedVars.enabled = value
				btg.CheckActivation()
			end,
		},
		{
			type = "checkbox",
			name = "Show Only DPS",
			tooltip = "Shows only players marked as DPS in the BTG group frames",
			default = btg.defaults.showOnlyDPS,
			getFunc = function() 
				return btg.savedVars.showOnlyDPS
			end,
			setFunc = function(value)
				btg.savedVars.showOnlyDPS = value
				zo_callLater(btg.CheckActivation, 500)
			end,
		},
		{
			type = "checkbox",
			name = "Single Column Mode",
			tooltip = "Lays out the frames in a single column instead of a 6x2 layout",
			default = btg.defaults.singleColumnMode,
			getFunc = function() 
				return btg.savedVars.singleColumnMode
			end,
			setFunc = function(value)
				btg.savedVars.singleColumnMode = value
				if(value) then
					btg.savedVars.maxRows = GROUP_SIZE_MAX
				else
					btg.savedVars.maxRows = 6
				end
				zo_callLater(btg.CheckActivation, 500)
			end,
		},
		{
			type = "checkbox",
			name = "Minimal Mode",
			tooltip = "Reduces the UI to a simple percentage display. The color background represents the time left on the buff. Respects the \'Show Only DPS\' option.",
			default = btg.defaults.minimalMode,
			getFunc = function() 
				return btg.savedVars.minimalMode
			end,
			setFunc = function(value)
				btg.savedVars.minimalMode = value
				zo_callLater(btg.CheckActivation, 500)
			end,
		},
		{
			type = "checkbox",
			name = "Gradient Mode",
			tooltip = "Changes whether the buff duration will decay using a color gradient",
			default = btg.defaults.gradientMode,
			getFunc = function()
				return btg.savedVars.gradientMode
			end,
			setFunc = function(value)
				btg.savedVars.gradientMode = value
			end,
		},
		{
			type = "colorpicker",
			name = "Buff Start Color",
			tooltip = "Sets the color of the start of the gradient for a tracked buff.",
			getFunc = function()
				local red = btg.savedVars.startR / 255.0
				local green = btg.savedVars.startG / 255.0
				local blue = btg.savedVars.startB / 255.0
				return red, green, blue
			end,
			setFunc = function(red,green,blue,alpha)
				btg.savedVars.startR = red * 255
				btg.savedVars.startG = green * 255
				btg.savedVars.startB = blue * 255
				zo_callLater(btg.CheckActivation, 500)
			end,
		},
		{
			type = "colorpicker",
			name = "Buff End Color",
			tooltip = "Sets the color of the end of the gradient for a tracked buff.",
			getFunc = function()
				local red = btg.savedVars.endR / 255.0
				local green = btg.savedVars.endG / 255.0
				local blue = btg.savedVars.endB / 255.0
				return red, green, blue
			end,
			setFunc = function(red,green,blue,alpha)
				btg.savedVars.endR = red * 255
				btg.savedVars.endG = green * 255
				btg.savedVars.endB = blue * 255
				zo_callLater(btg.CheckActivation, 500)
			end,
		},
		{
			type = "header",
			name = " Major Buffs",
		},
		-- 'Major' buffs inserted here
		{
			type = "header",
			name = " Minor Buffs",
		},
		-- 'Minor' buffs inserted here
		{
			type = "header",
			name = " Misc Buffs",
		},
		-- 'Misc' buffs inserted here
		{
			type = "button",
			name = "Deselect All",
			width = "half",
			func = function()
				for i, _ in pairs(btgData.buffs) do
					btg.savedVars.trackedBuffs[i] = false
				end
				btg.CheckActivation()
			end,
		},
		{
			type = "button",
			name = "Reset Positions",
			width = "half",
			func = function()
				for i, _ in pairs(btgData.buffs) do
					btg.savedVars.framePositions[i] = {
						left = 1300,
						top = 150 + (i-1)*10 % 1000,
					}
					btg.frames[i].frame:ClearAnchors()
					btg.frames[i].frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, btg.savedVars.framePositions[i].left, btg.savedVars.framePositions[i].top)
				end
			end,
		},
	}

	local majorInsert = 10
	local minorInsert = 11
	local etcInsert = 12
	for j, buff in pairs(btgData.buffs) do
		local buffName = GetAbilityName(buff)
		local buffOption = {
			type = "checkbox",
			name = buffName,
			default = btg.defaults.trackedBuffs[j],
			getFunc = function()
				return btg.savedVars.trackedBuffs[j]
			end,
			setFunc = function(value)
				btg.savedVars.trackedBuffs[j] = value
				btg.CheckActivation()
			end,
		}
		if ( buffName:find("Major") ) then
			table.insert(options, majorInsert, buffOption)
			majorInsert = majorInsert + 1
			minorInsert = minorInsert + 1
			etcInsert = etcInsert + 1	
		elseif ( buffName:find("Minor") ) then
			table.insert(options, minorInsert, buffOption)
			minorInsert = minorInsert + 1
			etcInsert = etcInsert + 1	
		else
			table.insert(options, etcInsert, buffOption)
			etcInsert = etcInsert + 1	
		end
	end

	LibAddonMenu2:RegisterAddonPanel(btg.name.."Options", panelData)
	LibAddonMenu2:RegisterOptionControls(btg.name.."Options", options)
end

