-- Stopwatch, by Gordias

Stopwatch = {
	-- AddOn information
	name = "Stopwatch",
	version = 1.1,
	variableVersion = 1.1,
	-- AddOn Variables
	debugFlag = true,
	startTimeStamp = 0,
	activeFlag = false,
	labelColor = {r = 197/255, g = 194/255, b = 158/255, a = 1},
	labelFontType = "Bold",
	labelFontSize = 24,
	labelFont = "$(BOLD_FONT)|$(KB_24)|soft-shadow-thick",
	offsetX = -100,
	offsetY = 200,
	-- Default settings for Account SavedVariables
    defaultAccount = {
        --1: Account wide
        --2: Each character
        saveMode = 1, --use Account Wide settings as default
    },
	-- Default settings
	default = {
		offsetX = -100,
		offsetY = 200,
		labelColor = {r = 197/255, g = 194/255, b = 158/255, a = 1},
		labelFontType = "Bold",
		labelFontSize = 24,
		labelFont = "$(BOLD_FONT)|$(KB_24)|soft-shadow-thick",
	},
}

-- LAM Panel Data
Stopwatch.panelData = {
    type = "panel",
    name = "Stopwatch",
    displayName = "Stopwatch",
    author = "Gordias",
    version = "1.1",
    registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
    registerForDefaults = true,	--boolean (optional) (will set all options controls back to default values)
}

-- LAM Options
Stopwatch.optionsTable = {
	{
        type = "header",
        name = "General Settings",
        width = "full",	--or "half" (optional)
	},
	{
        type = "dropdown",
        name = "Save Mode",
        tooltip = "Choose if you want to save Account wide or settings for each character",
        choices = {
            [1] = "Account wide",
            [2] = "Each character",
        },
        choicesValues = {
            [1] = 1,
            [2] = 2,
        },
        getFunc = function() return Stopwatch.savedVariablesAccount.saveMode end,
        setFunc = function(var) 
            Stopwatch.savedVariablesAccount.saveMode = var
            end,
        width = "full",
        default = Stopwatch.defaultAccount.saveMode,
		requiresReload = true,
	},
	{
        type = "header",
        name = "UI Location",
        width = "full",	--or "half" (optional)
	},
    {
		type = "button",
		name = "Change UI Location",
		tooltip = "This button pops up the UI for you to move to a prefered location",
		func = function() 
			if not Stopwatch.activeFlag then
				SWWindow:SetHidden(false) 
			end 
		end,
		width = "half",	--or "half" (optional)
	},
	{
		type = "button",
		name = "Set Default Location",
		tooltip = "This button moves the UI to the default location",
		func = function() 
			Stopwatch.savedVariables.offsetX = Stopwatch.default.offsetX
			Stopwatch.savedVariables.offsetY = Stopwatch.default.offsetY
			SWWindow:ClearAnchors()
			SWWindow:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, Stopwatch.savedVariables.offsetX, Stopwatch.savedVariables.offsetY) 
		end,
		width = "half",	--or "half" (optional)
	},
	{
        type = "header",
        name = "Label Settings",
        width = "full",	--or "half" (optional)
    },
	{
		type = "colorpicker",
		name = "Label Color",
		tooltip = "This option sets the label color",
		getFunc = function() return Stopwatch.labelColor.r, Stopwatch.labelColor.g, Stopwatch.labelColor.b, Stopwatch.labelColor.a end,	--(alpha is optional)
		setFunc = function(r,g,b,a) 
			Stopwatch.labelColor.r = r
			Stopwatch.labelColor.g = g
			Stopwatch.labelColor.b = b
			Stopwatch.labelColor.a = a		
			Stopwatch.savedVariables.labelColor = Stopwatch.labelColor
			SWWindowLabel:SetColor(Stopwatch.labelColor.r, Stopwatch.labelColor.g, Stopwatch.labelColor.b, Stopwatch.labelColor.a) 
		end,	--(alpha is optional)
		width = "half",	--or "half" (optional)
		default =  {r = Stopwatch.default.labelColor.r, g = Stopwatch.default.labelColor.g, b = Stopwatch.default.labelColor.b, a = Stopwatch.default.labelColor.a},
	},
	{
		type = "dropdown",
		name = "Label Font",
		tooltip = "This option sets the label font",
		choices = {"Medium",
			"Bold",
			"Antique",
			"Handwritten"},
		getFunc = function() return Stopwatch.savedVariables.labelFontType end,
		setFunc = function(var) 
			Stopwatch.labelFontType = var
			Stopwatch.labelFont = zo_strformat("$(<<Z:1>>_FONT)||<<2>>||soft-shadow-thick", Stopwatch.labelFontType, Stopwatch.labelFontSize) 
			Stopwatch.savedVariables.labelFontType = Stopwatch.labelFontType
			Stopwatch.savedVariables.labelFont = Stopwatch.labelFont
			SWWindowLabel:SetFont(Stopwatch.labelFont)
			end,
		width = "half",	--or "half" (optional)
		default = Stopwatch.default.labelFontType,
	},
	{
		type = "slider",
		name = "Font Size",
		tooltip = "This slider sets the font size", -- or string id or function returning a string (optional)
		getFunc = function() return Stopwatch.savedVariables.labelFontSize end,
		setFunc = function(value) 				
			Stopwatch.labelFontSize = value
			Stopwatch.labelFont = zo_strformat("$(<<Z:1>>_FONT)||<<2>>||soft-shadow-thick", Stopwatch.labelFontType, Stopwatch.labelFontSize) 
			Stopwatch.savedVariables.labelFontSize = Stopwatch.labelFontSize
			Stopwatch.savedVariables.labelFont = Stopwatch.labelFont
			SWWindowLabel:SetFont(Stopwatch.labelFont) end,
		min = 8,
		max = 54,
		step = 1, --(optional)
		width = "full", --or "half" (optional)
		default = Stopwatch.default.labelFontSize, -- default value or function that returns the default value (optional)
	},
}

-- Get reference to the LibAddonMenu-2.0 library table
local LAM = LibAddonMenu2

-- Add Keybindings from bindings.xml to Controls
ZO_CreateStringId("SI_BINDING_NAME_STW_STARTSTOP", "Start/Stop Stopwatch")
ZO_CreateStringId("SI_BINDING_NAME_STW_RESET", "Reset Stopwatch")

-- This function is for debug purposes
function Stopwatch.DebugText(text)
	if Stopwatch.debugFlag then
		 d(text)
	end
end

-- This function saves the location of the GUI once it has been moved by the player
function Stopwatch.SaveGUILocation()
	Stopwatch.savedVariables.offsetX = SWWindow:GetRight() - GuiRoot:GetRight()
	Stopwatch.savedVariables.offsetY = SWWindow:GetTop()
	SWWindow:ClearAnchors()
	SWWindow:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, Stopwatch.savedVariables.offsetX, Stopwatch.savedVariables.offsetY) 
	if not Stopwatch.activeFlag then SWWindow:SetHidden(true) end
end

-- This function starts or stops the stopwatch
function Stopwatch.StartStop()

	-- Check fi the stopwatch is activated
	if not Stopwatch.activeFlag then
		
		-- Activate stopwatch
		Stopwatch.activeFlag = true

		-- Show the GUI
		SWWindow:SetHidden(false)

		-- Get the start time stamp
		Stopwatch.startTimeStamp = GetGameTimeMilliseconds()
		
		-- Register the event to update the stopwatch
		EVENT_MANAGER:RegisterForUpdate(Stopwatch.name, 100, Stopwatch.OnUpdateStopwatch)

	else
		
		-- Deactivate stopwatch
		Stopwatch.activeFlag = false

		-- Show the GUI
		SWWindow:SetHidden(false)
		
		-- Unregister the event to update the stopwatch
		EVENT_MANAGER:UnregisterForUpdate(Stopwatch.name)

	end

end

-- This function resets the stopwatch
function Stopwatch.Reset()

	-- Hide the GUI
	SWWindow:SetHidden(true)

	-- Unregister the event to update the stopwatch
	EVENT_MANAGER:UnregisterForUpdate(Stopwatch.name)

end

-- This function updates the stopwatch based on the available information
function Stopwatch.OnUpdateStopwatch()

	-- Initialize local variables
	local currentTimeStamp = GetGameTimeMilliseconds()

	local diffTimeStamp = (currentTimeStamp - Stopwatch.startTimeStamp) / 1000

	local stringDiffTimeStamp = string.format("%.1f", diffTimeStamp)

	SWWindowLabel:SetText(stringDiffTimeStamp)

end

-- Initialization function
function Stopwatch:Initialize()

	-- Load saved variables for Account settings
    Stopwatch.savedVariablesAccount = ZO_SavedVars:NewAccountWide("StopWatchVars_AccountSettings", Stopwatch.variableVersion, nil, Stopwatch.defaultAccount, GetWorldName())
    -- Check if Account wide settings has selected
    if Stopwatch.savedVariablesAccount.saveMode == 1 then
        -- Load saved variables
        Stopwatch.savedVariables = ZO_SavedVars:NewAccountWide("StopwatchVars", Stopwatch.variableVersion, nil, Stopwatch.default, GetWorldName())
    else
         Stopwatch.savedVariables = ZO_SavedVars:NewCharacterIdSettings("StopwatchVars", Stopwatch.variableVersion, nil, Stopwatch.default, GetWorldName())
    end

	-- Assign saved variables
	Stopwatch.labelColor = Stopwatch.savedVariables.labelColor
	Stopwatch.labelFontType = Stopwatch.savedVariables.labelFontType
	Stopwatch.labelFontSize = Stopwatch.savedVariables.labelFontSize
	Stopwatch.labelFont = Stopwatch.savedVariables.labelFont

	-- Re-anchor the GUI to GuiRoot
	SWWindow:ClearAnchors()
	SWWindow:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, Stopwatch.savedVariables.offsetX, Stopwatch.savedVariables.offsetY)

	-- Apply GUI Settings
	SWWindowLabel:SetColor(Stopwatch.labelColor.r, Stopwatch.labelColor.g, Stopwatch.labelColor.b, Stopwatch.labelColor.a)
	SWWindowLabel:SetFont(Stopwatch.labelFont)

	-- Hide the GUI
	SWWindow:SetHidden(true)

	-- Initialize Settings
	LAM:RegisterAddonPanel("StopwatchOptions", Stopwatch.panelData)
	LAM:RegisterOptionControls("StopwatchOptions", Stopwatch.optionsTable)

	-- Unregister the initialization event
	EVENT_MANAGER:UnregisterForEvent(Stopwatch.name, EVENT_ADD_ON_LOADED)

end

-- Event handler function for the "addon loaded" event
function Stopwatch.OnAddOnLoaded(event, addonName)
	if addonName == Stopwatch.name then
		Stopwatch:Initialize()
	end
end
 
-- Register the initialization event
EVENT_MANAGER:RegisterForEvent(Stopwatch.name, EVENT_ADD_ON_LOADED, Stopwatch.OnAddOnLoaded)