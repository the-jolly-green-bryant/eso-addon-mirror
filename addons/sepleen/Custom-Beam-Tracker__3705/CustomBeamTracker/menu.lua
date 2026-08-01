function BT.BuildMenu()
	local LAM = LibAddonMenu2 and LibAddonMenu2 or nil
    if LAM == nil then return end

	local panelData = {
		type = "panel",
		name = "Custom Beam Tracker",
		displayName = "Custom Beam Tracker",
		author = "sepleen",
		version = ""..BT.version,
		registerForRefresh = true,
	}

	LAM:RegisterAddonPanel(BT.name.."Options", panelData)

	local options = {
		{
			type = "header",
			name = "Display Options",
		},
		{
			type = "slider",
			name = "Frame size",
			min      = 32,
            max      = 64,
            step     = 2,
            default  = 40,
			tooltip = "Change the size of the frame",
			getFunc = function() return BT.savedVariables.size end,
			setFunc = function(value)
				BT.savedVariables.size = value
				BTIndicator:SetDimensions(BT.savedVariables.size, BT.savedVariables.size)
				BTIndicatorIcon:SetDimensions(BT.savedVariables.size, BT.savedVariables.size)
				if not BT.savedVariables.vertical then
					BTIndicatorBackdrop:SetDimensions(BT.savedVariables.width, BT.savedVariables.size)
				else
					BTIndicatorBackdrop:SetDimensions(BT.savedVariables.size, BT.savedVariables.width)
				end
			end,
		},
		{
			type = "slider",
			name = "Frame bar length",
			min      = 100,
            max      = 250,
            step     = 10,
            default  = 200,
			tooltip = "Change the maximum length of the frame bar",
			getFunc = function() return BT.savedVariables.width end,
			setFunc = function(value)
				if BTIndicatorBackdrop:IsHidden() then BTIndicatorBackdrop:SetHidden(false) end
					
				BT.savedVariables.width = value
				if not BT.savedVariables.vertical then
					BTIndicatorBackdrop:SetDimensions(BT.savedVariables.width, BT.savedVariables.size)
				else
					BTIndicatorBackdrop:SetDimensions(BT.savedVariables.size, BT.savedVariables.width)
				end
			end,
		},
		{
			type = "divider",
		},
		{
			type = "slider",
			name = "Icon opacity",
			min      = 0,
            max      = 1,
            step     = 0.1,
            default  = 1,
			tooltip = "Change the opacity of the icon",
			getFunc = function() return BT.savedVariables.framealpha end,
			setFunc = function(value)
				BT.savedVariables.framealpha = value
				BTIndicatorIcon:SetAlpha(value)
			end,
		},
		{
			type = "colorpicker",
			name = "Frame bar color",
			tooltip = "Color of the frame",
			getFunc = function() return unpack(BT.savedVariables.color) end,
			setFunc = function(r,g,b,a)
				BT.savedVariables.color = {r,g,b,a}
				BTIndicatorBackdrop:SetCenterColor(r,g,b,a)
			end,
		},
		{
			type = "colorpicker",
			name = "Frame edge color",
			tooltip = "Color of the edges",
			getFunc = function() return unpack(BT.savedVariables.edgecolor) end,
			setFunc = function(r,g,b,a)
				BT.savedVariables.edgecolor = {r,g,b,a}
				BTIndicatorBackdrop:SetEdgeColor(r,g,b,a)
			end,
		},
		{
			type = "divider",
		},
		{
			type = "checkbox",
			name = "Timer",
			tooltip = "Timer",
			default = false,
			getFunc = function() return BT.savedVariables.timer end,
			setFunc = function(value)
				BT.savedVariables.timer = value
			end,
		},
		{
			type = "checkbox",
			name = "Vertical frame",
			tooltip = "Change the direction of the frame to vertical",
			default = false,
			getFunc = function() return BT.savedVariables.vertical end,
			setFunc = function(value)
				BT.savedVariables.vertical = value
				BTIndicatorBackdrop:ClearAnchors()
				if value then
					BTIndicatorBackdrop:SetAnchor(BOTTOM, BTIndicatorIcon, TOP, 0, 1, ANCHOR_CONSTRAINS_XY)
					BTIndicatorBackdrop:SetDimensions(BT.savedVariables.size, BT.savedVariables.width)
				else
					BTIndicatorBackdrop:SetAnchor(LEFT, BTIndicatorIcon, RIGHT, -1, 0, ANCHOR_CONSTRAINS_XY)
					BTIndicatorBackdrop:SetDimensions(BT.savedVariables.width, BT.savedVariables.size)
				end
			end,
		},
	}

	LAM:RegisterOptionControls(BT.name.."Options", options)
end
