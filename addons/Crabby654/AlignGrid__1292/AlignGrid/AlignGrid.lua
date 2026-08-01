--[[
Align Grid. See the LICENSE file for details

This software is under : CreativeCommons CC BY-NC-SA 4.0
Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

You are free to:

    Share — copy and redistribute the material in any medium or format
    Adapt — remix, transform, and build upon the material
    The licensor cannot revoke these freedoms as long as you follow the license terms.


Under the following terms:

    Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
    NonCommercial — You may not use the material for commercial purposes.
    ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
    No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.


Please read full licence at : 
http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
]]--

local WM = WINDOW_MANAGER
local LAM = LibAddonMenu2
local AlignGridWindow
local AlignGrid_Settings = AlignGrid_Settings or {}

-- Addon Default Settings
local AlignGridDefault = {
	reset = false,
	GRID_SIZE = 32,
	LINE_THICKNESS = 2,
	TLW_ALPHA = 1,
	GRID_ALPHA = 1,
	LINE_COLOR = {r = 0, g = 0, b = 0, a = 1},
	CENT_COLOR = {r = 255, g = 0, b = 0, a = 1}
}

-- Line Creation and Pool Storage
local function createLine(pool)
	local line = WM:CreateControl(nil,AlignGridWindow,CT_TEXTURE)
	line:SetColor(0,0,0,AlignGrid_Settings.settings.GRID_ALPHA)
	line:SetPixelRoundingEnabled(false)
	return line
end

local function resetLines(object)
	object:SetHidden(true)
end

AlignGridLinePool = ZO_ObjectPool:New(createLine,resetLines)

local function resetGrid()
	AlignGridLinePool:ReleaseAllObjects()
end

local function showGrid()
	AlignGridWindow:SetHidden(false)
end

local function hideGrid()
	AlignGridWindow:SetHidden(true)
end

local function createGrid()
	local SCREEN_WIDTH, SCREEN_HEIGHT = GuiRoot:GetDimensions()
	local gridStep = AlignGrid_Settings.settings.GRID_SIZE / GetUIGlobalScale()
	local lineWidth = AlignGrid_Settings.settings.LINE_THICKNESS / GetUIGlobalScale()
	local function getAlpha(index)
		if index % 10 == 0 then
			return AlignGrid_Settings.settings.GRID_ALPHA
		elseif index % 5 == 0 then
			return AlignGrid_Settings.settings.GRID_ALPHA * 0.7
		else
			return AlignGrid_Settings.settings.GRID_ALPHA * 0.4
		end
	end
	local function horizLine(offset, color, alpha)
		local line = AlignGridLinePool:AcquireObject()
		line:SetDimensions(SCREEN_WIDTH, lineWidth)
		line:SetAnchor(LEFT, AlignGridWindow, LEFT, 0, offset)
		line:SetHidden(false)
		line:SetColor(color.r, color.g, color.b, alpha or color.a)
	end
	local function vertLine(offset, color, alpha)
		local line = AlignGridLinePool:AcquireObject()
		line:SetDimensions(lineWidth, SCREEN_HEIGHT)
		line:SetAnchor(TOP, AlignGridWindow, TOP, offset, 0)
		line:SetHidden(false)
		line:SetColor(color.r, color.g, color.b, alpha or color.a)
	end
	resetGrid()
	for i = 1, zo_floor(SCREEN_WIDTH / gridStep / 2) do
		local a = getAlpha(i)
		vertLine(i * gridStep, AlignGrid_Settings.settings.LINE_COLOR, a)
		vertLine(-i * gridStep, AlignGrid_Settings.settings.LINE_COLOR, a)
	end
	-- Horizontal Lines
	for i = 1, zo_floor(SCREEN_HEIGHT / gridStep / 2) do
		local a = getAlpha(i)
		horizLine(i * gridStep, AlignGrid_Settings.settings.LINE_COLOR, a)
		horizLine(-i * gridStep, AlignGrid_Settings.settings.LINE_COLOR, a)
	end
	-- Center Cross
	vertLine(0, AlignGrid_Settings.settings.CENT_COLOR, getAlpha(0))
	horizLine(0, AlignGrid_Settings.settings.CENT_COLOR, getAlpha(0))
end

-- Setting Menu
local panelData = {
	type = "panel",
	name = "AlignGrid",
	author = "Crabby654 (Original author Skyraker)",
	version = "1.4.0",
	slashCommand = "/align"
}

local optionsData = {
	[1] = {
		type = "button",
		name = "Reset Grid",
		tooltip = "Resets grid with currently selected sizes",
		func = function() 
						AlignGrid_Settings.settings.reset = true
						createGrid()
					end
	},
	[2] = {
		type = "slider",
		name = "Grid Size",
		tooltip = "Adjust grid box size",
		min = 16,
		max = 54,
		step = 4,
		getFunc = function() return AlignGrid_Settings.settings.GRID_SIZE end,
		setFunc = function(value)
								AlignGrid_Settings.settings.GRID_SIZE = value
							end,
		warning = "PRESS Reset Grid button to show changes"
	},
	[3] = {
		type = "slider",
		name = "Thickness",
		tooltip = "Adjust thickness of gridlines",
		min = 2,
		max = 6,
		step = 1,
		getFunc = function() return AlignGrid_Settings.settings.LINE_THICKNESS end,
		setFunc = function(value)
								AlignGrid_Settings.settings.LINE_THICKNESS = value
							end,
		warning = "PRESS Reset Grid button to show changes"
	},
	[4] = {
		type = "slider",
		name = "Transparency",
		tooltip = "Adjust transparency of grid",
		min = 0,
		max = 10,
		step = .5,
		getFunc = function() return AlignGrid_Settings.settings.TLW_ALPHA * 10.0 end,
		setFunc = function(value)
								AlignGrid:SetAlpha(value / 10.0)
								AlignGrid_Settings.settings.TLW_ALPHA = value / 10.0
							end
	},
	[5] = {
		type = "colorpicker",
		name = "Center Line Color",
		tooltip = "Color the horizontal and vertical center lines",
		getFunc = function() return AlignGrid_Settings.settings.CENT_COLOR.r, AlignGrid_Settings.settings.CENT_COLOR.g, AlignGrid_Settings.settings.CENT_COLOR.b end,
		setFunc = function(r,g,b,a)
						AlignGrid_Settings.settings.CENT_COLOR.r = r
						AlignGrid_Settings.settings.CENT_COLOR.g = g
						AlignGrid_Settings.settings.CENT_COLOR.b = b
					end,
		warning = "PRESS Reset Grid button to show changes"
	},
	[6] = {
		type = "colorpicker",
		name = "Line Color",
		tooltip = "Color the non-center lines",
		getFunc = function() return AlignGrid_Settings.settings.LINE_COLOR.r, AlignGrid_Settings.settings.LINE_COLOR.g, AlignGrid_Settings.settings.LINE_COLOR.b end,
		setFunc = function(r,g,b,a)
						AlignGrid_Settings.settings.LINE_COLOR.r = r
						AlignGrid_Settings.settings.LINE_COLOR.g = g
						AlignGrid_Settings.settings.LINE_COLOR.b = b
					end,
		warning = "PRESS Reset Grid button to show changes"
	}
}

-- Addon Initialization
local function setupSavedVars()
	AlignGrid_Settings = {
		["settings"] = ZO_SavedVars:New("AlignGrid_Settings",2,"settings",AlignGridDefault,nil)
	}
	return AlignGrid_Settings
end

local function AddOnLoaded(eventID,addonName)
	if addonName == "AlignGrid" then
		EVENT_MANAGER:UnregisterForEvent("AlignGrid_Start",eventID)
		LAM:RegisterAddonPanel("AlignGridOptions", panelData)
        LAM:RegisterOptionControls("AlignGridOptions", optionsData)
		setupSavedVars()
		AlignGridWindow = WM:CreateTopLevelWindow("AlignGrid")
		AlignGridWindow:SetAnchorFill(GuiRoot)
		AlignGridWindow:SetDrawLayer(DL_BACKGROUND)
		AlignGridWindow:SetMouseEnabled(false)
		AlignGridWindow:SetAlpha(AlignGrid_Settings.settings.TLW_ALPHA)
		SLASH_COMMANDS["/grid"] = function()
			if AlignGridWindow:IsHidden() then
				AlignGridWindow:SetHidden(false)
			else
				AlignGridWindow:SetHidden(true)
			end
		end
		createGrid()
		hideGrid()
	end
end

function AlignGridToggle()
	if AlignGridWindow:IsHidden() then
		AlignGridWindow:SetHidden(false)
	else
		AlignGridWindow:SetHidden(true)
	end
end

EVENT_MANAGER:RegisterForEvent("AlignGrid_Start",EVENT_ADD_ON_LOADED,AddOnLoaded)

-- Key Binding
ZO_CreateStringId("SI_BINDING_NAME_ALIGNGRID_TOGGLE", "AlignGrid: |cFFFFFFToggle|r")