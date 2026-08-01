-------------------------------------------------------------------------------
-- PerfStatz_Addon
-------------------------------------------------------------------------------
PerfStatz_Addon = PerfStatz_Addon or {}

PerfStatz_Addon.name = "PerfStatz"
PerfStatz_Addon.version = "1.0.13"
PerfStatz_Addon.displayName = "|cFFFFFFPerformance Statz|r"
PerfStatz_Addon.author = "|c00a313Teebow Ganx|r"
PerfStatz_Addon.website = "https://www.youtube.com/channel/UCqE9Vi36WzTJBBbo9-G40bg"
PerfStatz_Addon.donation = "https://www.youtube.com/channel/UCqE9Vi36WzTJBBbo9-G40bg"

PerfStatz_Addon.SavedVariablesName = "PerfStatz_SavedVariables"
PerfStatz_Addon.savedVarsVersion = 2

--Locals -------------------------------------------------------------

local L = PerfStatz_Addon.Localization


-- Saved Variables --------------------------------------------------------------

local savedVariables = nil

local periodic = TBO_Periodic:New()

local fpsT = { }
local curFPS = 0
local avgFPS = -1

local latencyT = { }
local curLatency = 0
local avgLatency = -1

local logger = nil
local logLevel = { verbose = "V", debug = "D", info = "I", warning = "W", error = "E" }

local whiteColorHex = "FFFFFF"	-- white
local redColorHex = "FF0000"	-- bright red
local yellowColorHex = "FFFF00" -- yellow
local function colorizeStr(str, color)
	return string.format("|c%s%s|r", color, str)
end

local defaults = {
	logToDebugLog = false,
	sampleRate = 1,
	sampleSize = 300,
	logLevel = logLevel.info,
	showPerfWindow = true,
	lockPerfWindow = true,
	statsWindow = { anchorPoint = BOTTOMLEFT, xOff = -9, yOff = 12 },
	doAveraging = true
}

-- Sample Performance --------------------------------------------------------------

local function AddToPerfTable(inTable, inEntry, inMaxEntries) 

	-- If table size is at max, remove first entry
	if #inTable == inMaxEntries then table.remove(inTable, 1) end

	-- First add the latest entry to the end of the table
	table.insert(inTable, inEntry)

	-- calculate a running average of the numeric table elements
	local total = 0
	
	for k,v in pairs(inTable) do
		-- k is key
		-- v is value
		total = total + v
	end

	local avg = total/#inTable
	return avg
end

local esoTextColor = ZO_NORMAL_TEXT:ToHex() -- C5C29E


local function SamplePerformance()

	curLatency = math.floor(GetLatency() + 0.5)
	curFPS = math.floor(GetFramerate() + 0.5)

	if savedVariables.doAveraging == true then

		avgLatency = AddToPerfTable(latencyT, curLatency, savedVariables.sampleSize)
		avgLatency = math.floor(avgLatency + 0.5)
		avgFPS = AddToPerfTable(fpsT, curFPS, savedVariables.sampleSize)
		avgFPS = math.floor(avgFPS + 0.5)

		-- Log to debug log if checkbox is checked
		if savedVariables.logToDebugLog == true then

			local logString = string.format("FPS=%d, PING=%d, µFPS=%d, µPING=%d, S=%d", 
											curFPS, curLatency, avgFPS, avgLatency, #latencyT)
			
			logger = logger or LibDebugLogger("Performance") 

			logger:Log(savedVariables.logLevel, logString)
		end

	elseif #latencyT > 0 or #fpsT > 0 then
		avgLatency = -1
		avgFPS = -1
		latencyT = {}
		fpsT = {}
	end
	
	if savedVariables.showPerfWindow == true then PerfStatz_Addon.StatsWindowUpdate() end

end

-- Stats Window --------------------------------------------------------------

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- The stats pane that by default sits in the lower left corner of the window
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

local debugStatsWindow = false

function PerfStatz_Addon.StatsWindowUpdate()

	local format = L["WINDOW_AVRGS_STRING"]


	local curFPSStr = tostring(curFPS)
	local curLatencyStr = tostring(curLatency)..L["MILLISECONDS_ABBREVIATION"]

	local color = whiteColorHex
	if curFPS <= 15 then color = redColorHex
	elseif curFPS < 30 then color = yellowColorHex
	end
	curFPSStr = colorizeStr(curFPSStr, color)
	curFPSStr = string.format(L["WINDOW_FPS_STRING"], curFPSStr)
	
	color = whiteColorHex
	if curLatency >= 700 then color = redColorHex
	elseif curLatency >= 350 then color = yellowColorHex
	end
	if curLatency > 999 then curLatencyStr = "999+" end
	curLatencyStr = colorizeStr(curLatencyStr, color)
	curLatencyStr = string.format(L["WINDOW_PING_STRING"], curLatencyStr)

	PerfStatzStatsWindowFPSLabel:SetText(curFPSStr)
	PerfStatzStatsWindowPINGLabel:SetText(curLatencyStr)

	savedVariables = savedVariables or defaults

	if savedVariables.doAveraging == true then

		local avgFPSStr = tostring(avgFPS)
		local avgLatencyStr = tostring(avgLatency)..L["MILLISECONDS_ABBREVIATION"]

		color = whiteColorHex
		if avgFPS <= 15 then color = redColorHex
		elseif avgFPS < 30 then color = yellowColorHex
		end
		
		if avgFPS <= 0 then avgFPSStr = "--"
		else avgFPSStr = colorizeStr(avgFPSStr, color)
		end
		avgFPSStr = string.format(L["WINDOW_aFPS_STRING"], avgFPSStr)

		color = whiteColorHex
		if avgLatency >= 700 then color = redColorHex
		elseif avgLatency >= 350 then color = yellowColorHex
		end
		if avgLatency > 999 then avgLatencyStr = "999+" end

		if avgLatency <= 0 then avgLatencyStr = "--"
		else avgLatencyStr = colorizeStr(avgLatencyStr, color)
		end
		avgLatencyStr = string.format(L["WINDOW_aPING_STRING"], avgLatencyStr)

		PerfStatzStatsWindowAFPSLabel:SetText(avgFPSStr)
		PerfStatzStatsWindowAPINGLabel:SetText(avgLatencyStr)

	end

end

function PerfStatz_Addon:RestoreStatsWindowPosition()
	PerfStatzStatsWindow:ClearAnchors()
	PerfStatzStatsWindow:SetAnchor(savedVariables.statsWindow.anchorPoint,
  									GuiRoot, nil,
  									savedVariables.statsWindow.xOff,
  									savedVariables.statsWindow.yOff)
end

function PerfStatz_Addon.ShowStatsWindow()
	PerfStatz_Addon:RestoreStatsWindowPosition()
	PerfStatz_Addon.StatsWindowUpdate()
	PerfStatzStatsWindow:SetHidden(false)
end

function PerfStatz_Addon.HideStatsWindow()
	PerfStatzStatsWindow:SetHidden(true)
	PerfStatz_Addon.StatsWindowUpdate()
end

function PerfStatz_Addon.StatsWindow_OnInitialized()
	-- PerfStatzStatsWindowLabel:SetColor(ZO_NORMAL_TEXT:UnpackRGBA()) -- Set default color to the baby poop brown ESO uses
	PerfStatz_Addon.StatsWindowUpdate()
end

function PerfStatz_Addon.StatsWindow_Min()
	PerfStatzStatsWindowAFPSLabel:SetHidden(true)
	PerfStatzStatsWindowAPINGLabel:SetHidden(true)
	PerfStatzStatsWindow:SetWidth(190)
end

function PerfStatz_Addon.StatsWindow_Max()
	PerfStatzStatsWindow:SetWidth(380)
	PerfStatzStatsWindowAFPSLabel:SetHidden(false)
	PerfStatzStatsWindowAPINGLabel:SetHidden(false)
end

function PerfStatz_Addon.StatsWindow_OnMouseDoubleClick()
	if debugStatsWindow == true then
		zo_callLater(function() d("PerfStatz_Addon.StatsWindow_OnMouseDoubleClick()") end, 300)
	end
	if savedVariables.doAveraging == true then
		savedVariables.doAveraging = false
		PerfStatz_Addon.StatsWindow_Min()
		avgFPS = -1
		avgLatency = -1
	else 
		savedVariables.doAveraging = true
		PerfStatz_Addon.StatsWindow_Max()
	end
	
	PerfStatz_Addon.StatsWindowUpdate()
end

function PerfStatz_Addon.StatsWindow_OnMouseDown()
	if debugStatsWindow == false then return end
	zo_callLater(function() d("PerfStatz_Addon.StatsWindow_OnMouseDown()") end, 300)
end

function PerfStatz_Addon.StatsWindow_OnMouseUp()
	if debugStatsWindow == false then return end
	zo_callLater(function() d("PerfStatz_Addon.StatsWindow_OnMouseUp()") end, 300)
end

function PerfStatz_Addon.StatsWindow_OnMouseEnter()
	if debugStatsWindow == false then return end
	zo_callLater(function() d("PerfStatz_Addon.StatsWindow_OnMouseEnter()") end, 300)
end

function PerfStatz_Addon.StatsWindow_OnMouseExit()
	if debugStatsWindow == false then return end
	zo_callLater(function() d("PerfStatz_Addon.StatsWindow_OnMouseExit()") end, 300)
end

function PerfStatz_Addon.StatsWindow_OnMoveStart()
	if debugStatsWindow == false then return end
	zo_callLater(function() d("PerfStatz_Addon.StatsWindow_OnMoveStart()") end, 300)
end

function PerfStatz_Addon.StatsWindow_OnEffectivelyHidden()
	if debugStatsWindow == false then return end
	zo_callLater(function() d("PerfStatz_Addon.StatsWindow_OnEffectivelyHidden()") end, 300)
	PerfStatzStatsWindow:SetHidden(true)
end

function PerfStatz_Addon.StatsWindow_OnEffectivelyShown()
	if debugStatsWindow == false then return end
	zo_callLater(function() d("PerfStatz_Addon.StatsWindow_OnEffectivelyShown()") end, 300)
	PerfStatzStatsWindow:SetHidden(false)
end

function PerfStatz_Addon.StatsWindow_OnMoveStop()

	-- Control:GetAnchor(number anchorIndex)
	-- Returns: boolean isValidAnchor, number anchorPoint, object relativeTo, number relativePoint, 
	--					number offsetX, number offsetY, number AnchorConstrains anchorConstrains
	
	local isValidAnchor, anchorPoint, relativeTo, relativePoint, xOff, yOff, anchorConstrains
						= PerfStatzStatsWindow:GetAnchor()
	
	savedVariables.statsWindow.anchorPoint = anchorPoint
	savedVariables.statsWindow.xOff = xOff
	savedVariables.statsWindow.yOff = yOff
end

-- Settings Pane --------------------------------------------------------------

local function LogLevelToName(inLogLevel)
	if inLogLevel == logLevel.verbose then return L["SETTINGS_LOG_LEVEL_VERBOSE"] end
	if inLogLevel == logLevel.debug then return L["SETTINGS_LOG_LEVEL_DEBUG"] end
	if inLogLevel == logLevel.warning then return L["SETTINGS_LOG_LEVEL_WARNING"] end
	if inLogLevel == logLevel.error then return L["SETTINGS_LOG_LEVEL_ERROR"] end

	return L["SETTINGS_LOG_LEVEL_INFO"]
end

local function LogNameToLevel(inLogLevelName)

	if inLogLevelName == L["SETTINGS_LOG_LEVEL_VERBOSE"] then return logLevel.verbose end
	if inLogLevelName == L["SETTINGS_LOG_LEVEL_DEBUG"] then return logLevel.debug end
	if inLogLevelName == L["SETTINGS_LOG_LEVEL_INFO"] then return logLevel.info end
	if inLogLevelName == L["SETTINGS_LOG_LEVEL_WARNING"] then return logLevel.warning end
	if inLogLevelName == L["SETTINGS_LOG_LEVEL_ERROR"] then return logLevel.error end

	return logLevel.info
end

local function OnSceneStateChange(oldState, newState)

	local nextName = nil
	local currScene = SCENE_MANAGER:GetCurrentScene()

	if currScene == HUD_UI_SCENE then nextName = HUD_SCENE:GetName()
	elseif currScene == HUD_SCENE then nextName = HUD_UI_SCENE:GetName() 
	end

	if newState == SCENE_HIDING and nextName and not SCENE_MANAGER:IsShowingNext(nextName) then
		PerfStatzStatsWindow:SetHidden(true) -- Hide our stats when HUD is hidden
	elseif newState == SCENE_SHOWING then
		PerfStatzStatsWindow:SetHidden(false) -- Show our stats when HUD is shown
	end
end

local function CreateSettingsMenu()

	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		slashCommand = "/PerfStatz_Addonsettings",
		name = PerfStatz_Addon.displayName,
		displayName = PerfStatz_Addon.displayName,
		author = PerfStatz_Addon.author,
		version = PerfStatz_Addon.version,
		website = PerfStatz_Addon.website,
		donation = PerfStatz_Addon.donation,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local settingsPanel = LAM:RegisterAddonPanel(PerfStatz_Addon.name, panelData)
	
	local optionsData = {}
	local function AddControl(type, data)
		data.type = type
		optionsData[#optionsData + 1] = data
	end

	local function AddHeader(data) AddControl("header", data) end
	local function AddIconPicker(data) AddControl("iconpicker", data) end
	local function AddSlider(data) AddControl("slider", data) end
	local function AddColorPicker(data) AddControl("colorpicker", data) end
	local function AddCheckbox(data) AddControl("checkbox", data) end
	local function AddDescription(data) AddControl("description", data) end
	local function AddDropdown(data) AddControl("dropdown", data) end

	AddHeader({ name = L["SETTINGS_PERF_WINDOW_HEADER_LABEL"] })

	AddCheckbox({
		name = L["SETTINGS_SHOW_WINDOW_LABEL"],
		tooltip = L["SETTINGS_SHOW_WINDOW_DESCRIPTION"],
		getFunc = function() return savedVariables.showPerfWindow end,
		setFunc = function(newValue) 
			if newValue then
				-- Show Stats Window
				PerfStatz_Addon.ShowStatsWindow()
				HUD_UI_SCENE:RegisterCallback("StateChange", OnSceneStateChange)
				HUD_SCENE:RegisterCallback("StateChange", OnSceneStateChange)
			else
				-- Hide Stats Window
				PerfStatz_Addon.HideStatsWindow()
				HUD_UI_SCENE:UnregisterCallback("StateChange", OnSceneStateChange)
				HUD_SCENE:UnregisterCallback("StateChange", OnSceneStateChange)
			end
			savedVariables.showPerfWindow = newValue 
		end,
		default = defaults.showPerfWindow
	})

	AddCheckbox({
		name = L["SETTINGS_LOCK_WINDOW_LABEL"],
		tooltip = L["SETTINGS_LOCK_WINDOW_DESCRIPTION"],
		getFunc = function() return savedVariables.lockPerfWindow end,
		setFunc = function(newValue) 
			PerfStatzStatsWindow:SetMovable(not(newValue))
			savedVariables.lockPerfWindow = newValue 
		end,
		default = defaults.lockPerfWindow
	})

	AddHeader({ name = L["SETTINGS_SAMPLING_HEADER_LABEL"] })

	AddCheckbox({
		name = L["SETTINGS_SAMPLING_LABEL"],
		tooltip = L["SETTINGS_SAMPLING_DESCRIPTION"],
		getFunc = function() return savedVariables.doAveraging end,
		setFunc = function(newValue) savedVariables.doAveraging = newValue end,
		default = defaults.doAveraging
	})
	AddSlider({
		name = L["SETTINGS_SAMPLING_RATE_LABEL"],
		tooltip = L["SETTINGS_SAMPLING_RATE_DESCRIPTION"],
		min = 1,
		max = 10,
		getFunc = function() return savedVariables.sampleRate end,
		setFunc = function(newValue) savedVariables.sampleRate = newValue end,
		default = defaults.sampleRate
	})
	AddSlider({
		name = L["SETTINGS_SAMPLING_SIZE_LABEL"],
		tooltip = L["SETTINGS_SAMPLING_SIZE_DESCRIPTION"],
		min = 60,
		max = 600,
		getFunc = function() return savedVariables.sampleSize end,
		setFunc = function(newValue) savedVariables.sampleSize = newValue end,
		default = defaults.sampleSize
	})

	AddHeader({ name = L["SETTINGS_LOGGING_HEADER_LABEL"] })

	AddDescription({ 
		title = "WARNING",	--(optional)
		text = "This feature requires you to install the LibDebugLogger addon to generate logs and requires you to also install the DebugLogViewer addon to view these logs.",
		width = "full",	--or "half" (optional)
	})

	AddCheckbox({
		name = L["SETTINGS_LOG_TO_DEBUGLOG_LABEL"],
		tooltip = L["SETTINGS_LOG_TO_DEBUGLOG_DESCRIPTION"],
		getFunc = function() return savedVariables.logToDebugLog end,
		setFunc = function(newValue) 
			if newValue then logger = LibDebugLogger(PerfStatz_Addon.name) 
			else logger = nil end
			savedVariables.logToDebugLog = newValue 
		end,
		default = defaults.logToDebugLog
	})
	AddDropdown({
		name = L["SETTINGS_LOG_LEVEL_LABEL"],
		tooltip = L["SETTINGS_LOG_LEVEL_DESCRIPTION"],
		choices = {	L["SETTINGS_LOG_LEVEL_VERBOSE"],
					L["SETTINGS_LOG_LEVEL_DEBUG"],
					L["SETTINGS_LOG_LEVEL_INFO"],
					L["SETTINGS_LOG_LEVEL_WARNING"],
					L["SETTINGS_LOG_LEVEL_ERROR"],
				},
		getFunc = function() return LogLevelToName(savedVariables.logLevel) end,
		setFunc = function(newValue) savedVariables.logLevel = LogNameToLevel(newValue) end,
		default = defaults.logLevel,
		width = "full",	--or "half" (optional)
	})

	LAM:RegisterOptionControls(PerfStatz_Addon.name, optionsData)
end

local function SendLoadedString()
	local loadedStr = "%s v%s Loaded"
	loadedStr = string.format(loadedStr, PerfStatz_Addon.displayName, PerfStatz_Addon.version)
	zo_callLater(function() d(loadedStr) end, 300)
end

local function LogSceneStateChange(oldState, newState)

	local showing = "SCENE_SHOWING"
	local shown = "SCENE_SHOWN"
	local hiding = "SCENE_HIDING"
	local hidden = "SCENE_HIDDEN"
	
	local oldStr = ""
	if oldState == SCENE_SHOWING then oldStr = "SCENE_SHOWING"
	elseif oldState == SCENE_SHOWN then oldStr = "SCENE_SHOWN"
	elseif oldState == SCENE_HIDING then oldStr = "SCENE_HIDING"
	elseif oldState == SCENE_HIDDEN then oldStr = "SCENE_HIDDEN"
	end

	local newStr = ""
	if newState == SCENE_SHOWING then newStr = "SCENE_SHOWING"
	elseif newState == SCENE_SHOWN then newStr = "SCENE_SHOWN"
	elseif newState == SCENE_HIDING then newStr = "SCENE_HIDING"
	elseif newState == SCENE_HIDDEN then newStr = "SCENE_HIDDEN"
	end

	d(string.format("SceneStateChange: %s, old=%s, new=%s", SCENE_MANAGER:GetCurrentScene():GetName(), oldStr, newStr))
end

local function OnLoad(eventCode, addOnName)

	if(addOnName ~= PerfStatz_Addon.name) then return end
	
	-- The pin shape, size and color can be varied by toon.
	savedVariables = ZO_SavedVars:NewCharacterIdSettings(PerfStatz_Addon.SavedVariablesName, PerfStatz_Addon.savedVarsVersion, nil, defaults)

	CreateSettingsMenu()


	if savedVariables.showPerfWindow == true then 
		PerfStatz_Addon.ShowStatsWindow() 
		HUD_UI_SCENE:RegisterCallback("StateChange", OnSceneStateChange)
		HUD_SCENE:RegisterCallback("StateChange", OnSceneStateChange)
		-- SCENE_MANAGER:RegisterCallback("StateChange", LogSceneStateChange)
	end
	
	PerfStatzStatsWindow:SetMovable(not(savedVariables.lockPerfWindow))

	if savedVariables.doAveraging == false then 
		-- zo_callLater(function() d("Calling StatsWindow_Min") end, 300)
		PerfStatz_Addon.StatsWindow_Min() 
	end

	periodic:Start(SamplePerformance, savedVariables.sampleRate)

	SendLoadedString()

	-- Be a good citizen and unregister for load events now
	EVENT_MANAGER:UnregisterForEvent(PerfStatz_Addon.name, EVENT_ADD_ON_LOADED)
end

-- Init
EVENT_MANAGER:RegisterForEvent(PerfStatz_Addon.name, EVENT_ADD_ON_LOADED, OnLoad)