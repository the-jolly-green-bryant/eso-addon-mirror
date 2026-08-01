function MoreColourfulGroupFrames.createSettings(vars, grads, resColours)
	local presets = {
		["Dark Blue"] = ZO_POWER_BAR_GRADIENT_COLORS[1],
		["Light Blue"] = ZO_POWER_BAR_GRADIENT_COLORS[2],
		--["Dark Green"] = ZO_POWER_BAR_GRADIENT_COLORS[4],
		["Green"] = ZO_POWER_BAR_GRADIENT_COLORS[16],
		["Red"] = ZO_POWER_BAR_GRADIENT_COLORS[32], -- default health
		["Yellow"] = {ZO_ColorDef:New("D37B00"), ZO_ColorDef:New("FCBD00")}, -- 80 <- 60 colours from https://m3.material.io/styles/color/static/baseline
		["Orange"] = {ZO_ColorDef:New("FF8D41"), ZO_ColorDef:New("C05A01")}, -- 70 -> 50
		["Pink"] = {ZO_ColorDef:New("FF7DD2"), ZO_ColorDef:New("DC258D")}, -- 70 -> 50
		["Purple"] = {ZO_ColorDef:New("AD72FF"), ZO_ColorDef:New("7438D2")}, -- 60 -> 40
		["Tropic"] = {ZO_ColorDef:New("ffff00"), ZO_ColorDef:New("00ffff")} -- random testing hex that turned out to look not bad lol
	}

	local presetLabels = {}
	--SLASH_COMMANDS['/seepresets'] = function() for i,v in pairs(presetLabels) do d(v) end end 
	local presetLabelLookup = {}

	local str_sub = string.sub
	local function colourizeGradString(str, grad, hexGrad) -- not that efficient, 8ms total called during ui load
		if hexGrad then
			grad = {ZO_ColorDef:New(hexGrad[1]), ZO_ColorDef:New(hexGrad[2])}
		end
		local maxLength = #str
		local out = ""
		for i=1, maxLength do
			out = out .. grad[1]:Lerp(grad[2], i/maxLength):Colorize(str_sub(str,i,i))
		end
		return out
	end


	for str,grad in pairs(presets) do
		local out = colourizeGradString(str, grad)
		presetLabels[#presetLabels+1] = out
		presetLabelLookup[str] = out
		presetLabelLookup[out] = str
	end


	local optionsLoop = {
		{LFG_ROLE_TANK, GetString("SI_LFGROLE", LFG_ROLE_TANK)},
		{LFG_ROLE_HEAL, GetString("SI_LFGROLE", LFG_ROLE_HEAL)},
		{LFG_ROLE_DPS, GetString("SI_LFGROLE", LFG_ROLE_DPS)},
		{"Companion", "Companion"},
		{"Player", "Player"},
		{LFG_ROLE_INVALID, "No Role"},
	}

	local optionsTable = {
		{
			type = "checkbox",
			name = "Show Ressurection Status",
			tooltip = "If this is enabled, people's current ressurection status will be displayed in the group frame.",
			width = "half",
			getFunc = function() return vars.showResStatus end,
			setFunc = function(value)
				vars.showResStatus = value
				RefreshGroups()
			end,
		},
		{
			type = "checkbox",
			name = "Colourize Ressurection Status",
			tooltip = "If this is enabled, the ressurection status will be coloured as set via the below colour pickers.",
			disabled = function() return not vars.showResStatus end,
			width = "half",
			getFunc = function() return vars.colourizeResStatus end,
			setFunc = function(value)
				vars.colourizeResStatus = value
				redoStatusColourizes()
			end,
		},
		{
			type = "colorpicker",
			name = "Ressurection Status: Dead",
			tooltip = "",
			width = "full",
			getFunc = function() return ZO_ColorDef.HexToFloats(vars.resDeadColour) end,
			disabled = function() return (not vars.showResStatus) or (not vars.colourizeResStatus) end,
			setFunc = function(r,g,b,a)
				local def = ZO_ColorDef:New(r,g,b,a)
				vars.resDeadColour = def:ToHex()
				resColours.dead = def
				redoStatusColourizes()
			end,
		},
		{
			type = "colorpicker",
			name = "Ressurection Status: Being Ressurected",
			tooltip = "",
			width = "full",
			getFunc = function() return ZO_ColorDef.HexToFloats(vars.beingRessedColour) end,
			disabled = function() return (not vars.showResStatus) or (not vars.colourizeResStatus) end,
			setFunc = function(r,g,b,a)
				local def = ZO_ColorDef:New(r,g,b,a)
				vars.beingRessedColour = def:ToHex()
				resColours.beingRessed = def
				redoStatusColourizes()
			end,
		},
		{
			type = "colorpicker",
			name = "Ressurection Status: Pending Ressurection",
			tooltip = "",
			width = "full",
			getFunc = function() return ZO_ColorDef.HexToFloats(vars.resPendingColour) end,
			disabled = function() return (not vars.showResStatus) or (not vars.colourizeResStatus) end,
			setFunc = function(r,g,b,a)
				local def = ZO_ColorDef:New(r,g,b,a)
				vars.resPendingColour = def:ToHex()
				resColours.pending = def
				redoStatusColourizes()
			end,
		},
	}


	local function RefreshGroups()
		for i = 1, MAX_GROUP_SIZE_THRESHOLD do
			local unitTag = ZO_Group_GetUnitTagForGroupIndex(i)
			local companionTag = GetCompanionUnitTagByGroupUnitTag(unitTag)
			ZO_UnitFrames_UpdateWindow(unitTag)
			ZO_UnitFrames_UpdateWindow(companionTag)
		end
	end

	local function changeGrad(role, colour1, colour2, colour1def, colour2def)
		local roleVar = vars.colours[role]
		if colour1 and roleVar then
			roleVar[1] = colour1
			if not colour1def then colour1def = ZO_ColorDef:New(colour1) end
			grads[role][1] = colour1def
		end
		if colour2 and roleVar then
			roleVar[2] = colour2
			if not colour2def then colour2def = ZO_ColorDef:New(colour2) end
			grads[role][2] = colour2def
		end
		RefreshGroups()
	end

	for i,v in ipairs(optionsLoop) do
		local colorizedString = colourizeGradString(v[2], nil, vars.colours[v[1]])
		local currentOptionTable = {
			{
				type = "divider",
			},
			{
				type = "description",
				title = function() return colorizedString end,
				reference = "MoreColourfulGroupFramesPanelTitle"..tostring(v[1]),
				width = "half",
			},
			{
				type = "dropdown",
				name = "Preset Colour",
				width = "half",
				scrollable = 10,
				choices = presetLabels,
				getFunc = function() end,
				setFunc = function(value)
					local name = presetLabelLookup[value]
					local grad = presets[name]
					local gradStart = grad[1]:ToHex()
					local gradEnd = grad[2]:ToHex()
					changeGrad(v[1], gradStart, gradEnd, grad[1], grad[2])
					colorizedString = colourizeGradString(v[2], grad)
				end,
			},
			{
				type = "colorpicker",
				name = "Gradient Start",
				tooltip = "",
				width = "half",
				getFunc = function()
					local r,g,b,a = ZO_ColorDef.HexToFloats(vars.colours[v[1]][1])
					return r,g,b -- drop alpha cause no support for it in fakehealth
				end,
				setFunc = function(r,g,b,a)
					local def = ZO_ColorDef:New(r,g,b)
					changeGrad(v[1], def:ToHex(), nil, def)
					colorizedString = colourizeGradString(v[2], nil, vars.colours[v[1]])
				end,
			},
			{
				type = "colorpicker",
				name = "Gradient End",
				tooltip = "",
				width = "half",
				getFunc = function()
					local r,g,b,a = ZO_ColorDef.HexToFloats(vars.colours[v[1]][2])
					return r,g,b 
				end,
				setFunc = function(r,g,b,a)
					local def = ZO_ColorDef:New(r,g,b)
					changeGrad(v[1], nil, def:ToHex(), nil, def)
					colorizedString = colourizeGradString(v[2], nil, vars.colours[v[1]])
				end,
			},
		}

		if v[1] == "Player" then
			currentOptionTable[3].width = "full"
			local disabledFunc = function()
				return not vars.uniquePlayerRoleColour
			end
			currentOptionTable[3].disabled = disabledFunc
			currentOptionTable[4].disabled = disabledFunc
			currentOptionTable[5].disabled = disabledFunc
			table.insert(currentOptionTable, 3, {
				type = "checkbox",
				name = "Unique Player Colour",
				tooltip = "If this is disabled, the local player's group frame colour will match their role.",
				width = "half",
				getFunc = function() return vars.uniquePlayerRoleColour end,
				setFunc = function(value)
					vars.uniquePlayerRoleColour = value
					RefreshGroups()
				end,
			})
		end
		ZO_CombineNumericallyIndexedTables(optionsTable, currentOptionTable)
	end

	local function redoStatusColourizes()
		local deadText = GetString(SI_UNIT_FRAME_STATUS_DEAD)
		local beingRessedText = "Being Ressed"
		local pendingText = "Res Pending"

		if vars.colourizeResStatus then resColours.deadText = resColours.dead:Colorize(deadText) else resColours.deadText = deadText end
		if vars.colourizeResStatus then resColours.beingRessedText = resColours.beingRessed:Colorize(beingRessedText) else resColours.beingRessedText = beingRessedText end
		if vars.colourizeResStatus then resColours.pendingText = resColours.pending:Colorize(pendingText) else resColours.pendingText = pendingText end
	end



	local panelName = "MoreColourfulGroupFramesPanel"
	local panelData = {
		type = "panel",
		name = "|cFFD700More Colourful Group Frames|r",
		author = "|c0DC1CF@M0R_Gaming|r",
		registerForRefresh = true
	}

	local panel = LibAddonMenu2:RegisterAddonPanel(panelName, panelData)
	LibAddonMenu2:RegisterOptionControls(panelName, optionsTable)


end