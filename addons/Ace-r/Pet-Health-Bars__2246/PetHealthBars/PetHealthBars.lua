PHB = PHB or {}
PHB.name = "PetHealthBars"
PHB.version = "1.1"
PHB.savedVars = {}
PHB.default = {
	width = 100,
	height = 40,
	x = 400,
	y = 400,
	mov = false,
	fontsize = 19,
	barcolor = {0.7, 0.2, 0.7, 0.8},
	shieldcolor = {0.7, 0.2, 0.2, 0.5},
	format = "<<1>>/<<2>>",
	formatShield = "<<1>>+<<3>>/<<2>>",
}

PHB.UIUtil = {}
PHB.UI = {}
PHB.UI.bars = {}

function PHB.OnLoaded(_, addonName)
    if addonName ~= PHB.name then return end
	PHB.savedVars = ZO_SavedVars:NewAccountWide("PHBVars", 2, nil, PHB.default)
	zo_callLater(PHB.InitUI, 400)
	PHB.CreateSettings()
    EVENT_MANAGER:UnregisterForEvent(PHB.name, EVENT_ADD_ON_LOADED)
end

function PHB.InitUI()
	PHB.UI.topWindow = PHB.UI.topWindow or WINDOW_MANAGER:CreateTopLevelWindow("PHBTopWindow")
	PHB.UI.topBackdrop = WINDOW_MANAGER:CreateControl("PHBTopWindowBack", PHB.UI.topWindow, CT_BACKDROP)
	for i=1,7 do
		PHB.UI.bars[i] = PHB.UIUtil.bar(i, PHB.UI.topWindow, PHB.savedVars.width, PHB.savedVars.height, {0, (PHB.savedVars.height*2+10)*(i-1)})
	end
	
	PHB.LoadUI()
end

function PHB.LoadUI()
	PHB.UI.topWindow:SetDimensions(PHB.savedVars.width, #PHB.UI.bars*(PHB.savedVars.height*2+10)+10)
	PHB.UI.topWindow:ClearAnchors()
	PHB.UI.topWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PHB.savedVars.x, PHB.savedVars.y)
	PHB.UI.topWindow:SetMovable(PHB.savedVars.mov)
	PHB.UI.topWindow:SetMouseEnabled(PHB.savedVars.mov)
	
	PHB.UI.topBackdrop:SetDimensions(PHB.savedVars.width, #PHB.UI.bars*(PHB.savedVars.height*2+10))
	PHB.UI.topBackdrop:ClearAnchors()
	PHB.UI.topBackdrop:SetAnchor(TOPLEFT, PHB.UI.topWindow, TOPLEFT, -1, -1)
	PHB.UI.topBackdrop:SetEdgeTexture("", 8,2,1)
	--PHB.UI.topBackdrop:SetEdgeColor(0.8, 0.2, 0.8, 0.6)
	--PHB.UI.topBackdrop:SetCenterColor(0.9, 0.9, 0.9, 0.2)
	PHB.UI.topBackdrop:SetEdgeColor(0.8, 0.2, 0.8, 0)
	PHB.UI.topBackdrop:SetCenterColor(0.9, 0.9, 0.9, 0)
	
	for i,v in pairs (PHB.UI.bars) do
		v:SetWidth(PHB.savedVars.width)
		v:SetHeight(PHB.savedVars.height)
		v:SetFontSize(PHB.savedVars.fontsize)
		v:SetBarColor(PHB.savedVars.barcolor)
		v:SetShieldColor(PHB.savedVars.shieldcolor)
	end
	
	PHB.UpdateBars()
end

function PHB.UpdateBars()
	local numBars = 0
	for i,v in pairs(PHB.UI.bars) do
		PHB.UpdateBar(i, -1, string.format("%s%s", "playerpet", i))
		if PHB.UI.bars[i]:GetMax() > 0 then numBars = numBars + 1 end
	end
	PHB.UI.topWindow:SetDimensions(PHB.savedVars.width, numBars*(PHB.savedVars.height*2+10)+10)
end

function PHB.SetHidden(b)
	for i, v in pairs(PHB.UI.bars) do
		v:SetHidden(b)
	end
end

function PHB.Preview()
	PHB.LoadUI()
	for i, v in pairs(PHB.UI.bars) do
		v:SetHidden(false)
		v:Demo(PHB.savedVars.format, PHB.savedVars.formatShield)
	end
	zo_callLater(PHB.UpdateBars, 5000)
end

function PHB.Health(eventcode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	if unitTag:sub(1, 9) ~= "playerpet" then return end
	local id = unitTag:sub(-1, -1)+0
	if powerType == POWERTYPE_HEALTH then
		PHB.UpdateBar(id, -1, unitTag)
	end
end

-- Runs on the EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED listener.
function PHB.Shield1(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
	if unitTag:sub(1, 9) ~= "playerpet" then return end
	local id = unitTag:sub(-1, -1)+0
    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
		PHB.UpdateBar(id, value, unitTag)
    end
end

-- Runs on the EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED listener.
function PHB.Shield2(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
	if unitTag:sub(1, 9) ~= "playerpet" then return end
	local id = unitTag:sub(-1, -1)+0
    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
		PHB.UpdateBar(id, 0, unitTag)
    end
end

-- Runs on the EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED listener.
function PHB.Shield3(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue)
	if unitTag:sub(1, 9) ~= "playerpet" then return end
	local id = unitTag:sub(-1, -1)+0
    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
		PHB.UpdateBar(id, newValue, unitTag)
    end
end

function PHB.UpdateBar(id, shield, unitTag)
	local hp, hpmax, _ = GetUnitPower(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH)
	PHB.UI.bars[id]:Update(hp, hpmax, shield, PHB.savedVars.format, PHB.savedVars.formatShield)
end

function PHB.OnSceneChange(oldState, newState)
	if SCENE_MANAGER:GetCurrentScene():GetName() ~= "hud" then return end
	if PHB.savedVars.mov == true then return end
	if newState == SCENE_SHOWN then --all scenes closed
		PHB.SetHidden(true)
	elseif newState == SCENE_HIDDEN then --a scene opened
		PHB.SetHidden(false)
	end
end

function PHB.CreateSettings()
	
	local LAM2 = LibAddonMenu2
	
	local panelData = {
			type = "panel",
			name = PHB.name,
			displayName = "Pet Health Bars",
			author = "Acer",
			version = PHB.version,
			registerForRefresh = true,
			slashCommand = "/phb",
		}
		
	LAM2:RegisterAddonPanel("PetHealthBars", panelData)
	
	local optionsData = {
		{
			type = "header",
			name = "Pet Health Bar Settings",
		},
		{
			type = "description",
			text = "When changing height or font size, the gaps between bars will not update until the next ReloadUI.",
		},
		{
            type = "checkbox",
            name = "Window Unlocked",
            tooltip = "Unlock window",
			getFunc = function() return PHB.savedVars.mov end,
            setFunc = function(t)
				if not t then
					PHB.savedVars.x = PHB.UI.topWindow:GetLeft()
					PHB.savedVars.y = PHB.UI.topWindow:GetTop()
				end
				PHB.savedVars.mov = t
				PHB.LoadUI()
			end,
        },
		{
			type = "slider",
			name = "Width",
			tooltip = "Width of the health bars",
			min = 100,
			max = 300,
			step = 10,
			getFunc = function() return PHB.savedVars.width end,
			setFunc = function(x) 
				PHB.savedVars.width = x
				PHB.Preview()
			end,
		},
		{
			type = "slider",
			name = "Height",
			tooltip = "Height of the health bars",
			min = 20,
			max = 100,
			step = 10,
			getFunc = function() return PHB.savedVars.height end,
			setFunc = function(x) 
				PHB.savedVars.height = x
				PHB.Preview()
			end,
		},
		{
			type = "slider",
			name = "Font Size",
			tooltip = "Font size of the health bars",
			min = 12,
			max = 24,
			step = 1,
			getFunc = function() return PHB.savedVars.fontsize end,
			setFunc = function(x) 
				PHB.savedVars.fontsize = x
				PHB.Preview()
			end,
		},
		{
			type = "submenu",
			name = "Label Format",
			controls = {
				{
					type = "description",
					text = "You can customise the display of the text format on the health bars.\n<<1>> will be replaced with current HP\n<<2>> will be replaced with maximum HP\n<<3>> will be replaced with shield value",
					width = "full"
				},
				{
					type = "editbox",
					name = "Format (no shield)",
					tooltip = "String format for healthbars when there is no shield",
					default = PHB.savedVars.format,
					getFunc = function() return PHB.savedVars.format end,
					setFunc = function(value) 
						PHB.savedVars.format = value
						PHB.Preview()
					end,
				},
				{
					type = "editbox",
					name = "Format (shield)",
					tooltip = "String format for healthbars when there is a shield",
					default = PHB.savedVars.formatShield,
					getFunc = function() return PHB.savedVars.formatShield end,
					setFunc = function(value) 
						PHB.savedVars.formatShield = value
						PHB.Preview()
					end,
				},
			},
		},
		{
			type = "colorpicker",
			name = "Bar Colour",
			tooltip = "Colour of the health bars",
			getFunc = function() return unpack(PHB.savedVars.barcolor) end,
			setFunc = function(r, g, b, a) 
				PHB.savedVars.barcolor = {r, g, b, a}
				PHB.Preview()
			end,
		},
		{
			type = "colorpicker",
			name = "Shield Colour",
			tooltip = "Colour of the shield bar overlay",
			getFunc = function() return unpack(PHB.savedVars.shieldcolor) end,
			setFunc = function(r, g, b, a) 
				PHB.savedVars.shieldcolor = {r, g, b, a}
				PHB.Preview()
			end,
		},
		{
			type = "button",
			name = "Show Preview (5s)",
			tooltip =  "Display a preview for 5 seconds",
			func = function() PHB.Preview() end,
		}
	}
	
	
	LAM2:RegisterOptionControls("PetHealthBars", optionsData)

end

SLASH_COMMANDS["/rl"] = function() ReloadUI() end

EVENT_MANAGER:RegisterForEvent(PHB.name, EVENT_ADD_ON_LOADED, PHB.OnLoaded)
EVENT_MANAGER:RegisterForEvent(PHB.name, EVENT_POWER_UPDATE, PHB.Health)
EVENT_MANAGER:RegisterForEvent(PHB.name, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, PHB.Shield1)
EVENT_MANAGER:RegisterForEvent(PHB.name, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, PHB.Shield2)
EVENT_MANAGER:RegisterForEvent(PHB.name, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, PHB.Shield3)
SCENE_MANAGER:RegisterCallback("SceneStateChanged", PHB.OnSceneChange)