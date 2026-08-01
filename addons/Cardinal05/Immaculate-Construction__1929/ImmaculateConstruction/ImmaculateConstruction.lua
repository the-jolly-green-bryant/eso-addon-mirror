ImmCon = { }


-- Constants


ImmCon.ADDON_NAME = "ImmaculateConstruction"
ImmCon.ADDON_VERSION = "0.99h"

ImmCon.SAVED_VARS_VERSION = 11
ImmCon.SAVED_VARS_FILE = "ImmaculateConstructionSavedVariables"
ImmCon.SAVED_VARS_DEFAULTS = { RenderAfterAddingItems = true, DragToMove = true, DragToOrient = true, HideKeybinds = false }

ImmCon.SLASH_COMMAND_PREFIX = "/imco"

ImmCon.AXIS = { }
ImmCon.AXIS.NONE = "none"
ImmCon.AXIS.YAW = "Rotation"
ImmCon.AXIS.PITCH = "Pitch"
ImmCon.AXIS.ROLL = "Roll"

ImmCon.DEFAULT = { }
ImmCon.DEFAULT.BUTTON_WIDTH = 130
ImmCon.DEFAULT.BUTTON_HEIGHT = 24
ImmCon.DEFAULT.DROPDOWN_WIDTH = 102
ImmCon.DEFAULT.DROPDOWN_HEIGHT = 24
ImmCon.DEFAULT.LABEL_WIDTH = 170
ImmCon.DEFAULT.LABEL_HEIGHT = 24
ImmCon.DEFAULT.TEXTBOX_WIDTH = 50
ImmCon.DEFAULT.TEXTBOX_HEIGHT = 24
ImmCon.DEFAULT.FIELD_MARGIN_TOP = 6
ImmCon.DEFAULT.FIELD_MARGIN_LEFT = 0
ImmCon.DEFAULT.FIELD_DIVIDER_TOP = 20
ImmCon.DEFAULT.FIELD_DIVIDER_LEFT = 12
ImmCon.DEFAULT.HEADING_WIDTH = ImmCon.DEFAULT.LABEL_WIDTH + ImmCon.DEFAULT.TEXTBOX_WIDTH + ( ImmCon.DEFAULT.FIELD_DIVIDER_LEFT * 2 )
ImmCon.DEFAULT.HEADING_HEIGHT = ImmCon.DEFAULT.LABEL_HEIGHT
ImmCon.DEFAULT.WINDOW_MARGIN_X = ImmCon.DEFAULT.FIELD_DIVIDER_LEFT * 2
ImmCon.DEFAULT.WINDOW_MARGIN_Y = 50

ImmCon.DELAY = { }
ImmCon.DELAY.POST_PROCESS = 100
ImmCon.DELAY.RENDER = 100
ImmCon.DELAY.ADD_FURNITURE = 50
ImmCon.DELAY.RESET_FURNITURE = 100

ImmCon.ICON = { }
ImmCon.ICON.ARROW_DOWN = zo_iconFormat( "/esoui/art/tooltips/tooltip_downarrow.dds" )
ImmCon.ICON.ARROW_LEFT = zo_iconFormat( "/esoui/art/tooltips/tooltip_leftarrow.dds" )
ImmCon.ICON.ARROW_RIGHT = zo_iconFormat( "/esoui/art/tooltips/tooltip_rightarrow.dds" )
ImmCon.ICON.ARROW_UP = zo_iconFormat( "/esoui/art/tooltips/tooltip_uparrow.dds" )

ImmCon.PROCESS = { }
ImmCon.PROCESS.RENDER = 1
ImmCon.PROCESS.ADD_FURNITURE = 2
ImmCon.PROCESS.RESET_FURNITURE = 3

ImmCon.SHAPE = { }
ImmCon.SHAPE.ARC = "Arc"
ImmCon.SHAPE.BRIDGE = "Bridge"
ImmCon.SHAPE.CIRCLE = "Circle"
ImmCon.SHAPE.CYLINDER = "Cylinder"
ImmCon.SHAPE.DOME = "Dome"
ImmCon.SHAPE.FLOOR = "Floor"
ImmCon.SHAPE.PYRAMID = "Pyramid"
ImmCon.SHAPE.SPHERE = "Sphere"
ImmCon.SHAPE.SPIRAL = "Spiral"
ImmCon.SHAPE.STAIRS = "Stairs"
ImmCon.SHAPE.TEXT = "Text"
ImmCon.SHAPE.WALL = "Wall"


-- Sample Characters:
--  a b c d e f g h i j k l m n o p q r s t u v w x y z ~ 1 2 3 4 5 6 7 8 9 0 ~ @ . , ` ' " _ - + = / \ ? ( )

ImmCon.LED_CHARS = { }

--                        1  2  3  4  5  6  7  8  9 10 11 12 13
ImmCon.LED_CHARS[" "] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
ImmCon.LED_CHARS["@"] = { 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1 }
ImmCon.LED_CHARS["."] = { 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0 }
ImmCon.LED_CHARS[","] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0 }
ImmCon.LED_CHARS["'"] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0 }
ImmCon.LED_CHARS["\""]= { 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 }
ImmCon.LED_CHARS["`"] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0 }
ImmCon.LED_CHARS["_"] = { 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0 }
ImmCon.LED_CHARS["-"] = { 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0 }
ImmCon.LED_CHARS["+"] = { 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0 }
ImmCon.LED_CHARS["="] = { 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0 }
ImmCon.LED_CHARS["/"] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0 }
ImmCon.LED_CHARS["\\"]= { 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1 }
ImmCon.LED_CHARS["?"] = { 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0 }
ImmCon.LED_CHARS[")"] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0 }
ImmCon.LED_CHARS["("] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1 }
ImmCon.LED_CHARS["0"] = { 1, 1, 0, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0 }
ImmCon.LED_CHARS["1"] = { 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0 }
ImmCon.LED_CHARS["2"] = { 0, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 0 }
ImmCon.LED_CHARS["3"] = { 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0 }
ImmCon.LED_CHARS["4"] = { 1, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0 }
ImmCon.LED_CHARS["5"] = { 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0 }
ImmCon.LED_CHARS["6"] = { 1, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0 }
ImmCon.LED_CHARS["7"] = { 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0 }
ImmCon.LED_CHARS["8"] = { 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0 }
ImmCon.LED_CHARS["9"] = { 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0 }
--                        1  2  3  4  5  6  7  8  9 10 11 12 13
ImmCon.LED_CHARS["a"] = { 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0 }
ImmCon.LED_CHARS["b"] = { 1, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0 }
ImmCon.LED_CHARS["c"] = { 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0 }
ImmCon.LED_CHARS["d"] = { 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0 }
ImmCon.LED_CHARS["e"] = { 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0 }
ImmCon.LED_CHARS["f"] = { 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0 }
ImmCon.LED_CHARS["g"] = { 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0 }
ImmCon.LED_CHARS["h"] = { 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0 }
ImmCon.LED_CHARS["i"] = { 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0 }
ImmCon.LED_CHARS["j"] = { 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0 }
ImmCon.LED_CHARS["k"] = { 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0 }
ImmCon.LED_CHARS["l"] = { 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0 }
ImmCon.LED_CHARS["m"] = { 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0 }
ImmCon.LED_CHARS["n"] = { 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1 }
ImmCon.LED_CHARS["o"] = { 1, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0 }
ImmCon.LED_CHARS["p"] = { 1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0 }
ImmCon.LED_CHARS["q"] = { 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0 }
ImmCon.LED_CHARS["r"] = { 1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 1 }
ImmCon.LED_CHARS["s"] = { 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0 }
ImmCon.LED_CHARS["t"] = { 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0 }
ImmCon.LED_CHARS["u"] = { 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0 }
ImmCon.LED_CHARS["v"] = { 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0 }
ImmCon.LED_CHARS["w"] = { 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1 }
ImmCon.LED_CHARS["x"] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1 }
ImmCon.LED_CHARS["y"] = { 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0 }
ImmCon.LED_CHARS["z"] = { 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 1, 0 }
--                        1  2  3  4  5  6  7  8  9 10 11 12 13

--			 L.E.D.s

--		 777777777777777
--		1 10    3    11 5
--		1  10   3   11  5
--		1   10  3  11   5
--		1    10 3 11    5
--		 888888888888888
--		2    12 4 13    6
--		2   12  4  13   6
--		2  12   4   13  6
--		2 12    4    13 6
--		 999999999999999

local CreateLED = function( xOffset, yOffset, zOffset, pitchOffset, yawOffset, rollOffset ) return { X = xOffset, Y = yOffset, Z = zOffset, Pitch = pitchOffset, Yaw = yawOffset, Roll = rollOffset } end

ImmCon.TEXT_RASTERIZATION_ITEMS = { }

-- Colovian Projection Crystal
ImmCon.TEXT_RASTERIZATION_ITEMS["|H1:item:119848:5:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"] = {

	BlockSize = { 0, -260, 180 },

	LEDOffsets = {
		CreateLED( 0, 150, 0,	180, 0, 0 ),
		CreateLED( 0, 70, 0,	0, 0, 0 ),

		CreateLED( 0, 150, 60,	180, 0, 0 ),
		CreateLED( 0, 70, 60,	0, 0, 0 ),

		CreateLED( 0, 150, 120,	180, 0, 0 ),
		CreateLED( 0, 70, 120,	0, 0, 0 ),

		CreateLED( 0, 220, 60,	90, 0, 0 ),
		CreateLED( 0, 115, 60,	90, 0, 0 ),
		CreateLED( 0, 0, 60,	90, 0, 0 ),

		CreateLED( 0, 170, 30,	-30, 0, 0 ),
		CreateLED( 0, 170, 90,	30, 0, 0 ),

		CreateLED( 0, 70, 30,	30, 0, 0 ),
		CreateLED( 0, 70, 90,	-30, 0, 0 ),
	}

}

-- Light of Meridia
ImmCon.TEXT_RASTERIZATION_ITEMS["|H1:item:119832:5:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"] = {

	BlockSize = { 0, -260, 180 },

	LEDOffsets = {
		CreateLED( 0, 150, 0,	180, 0, 0 ),
		CreateLED( 0, 70, 0,	0, 0, 0 ),

		CreateLED( 0, 150, 60,	180, 0, 0 ),
		CreateLED( 0, 70, 60,	0, 0, 0 ),

		CreateLED( 0, 150, 120,	180, 0, 0 ),
		CreateLED( 0, 70, 120,	0, 0, 0 ),

		CreateLED( 0, 220, 60,	90, 0, 0 ),
		CreateLED( 0, 115, 60,	90, 0, 0 ),
		CreateLED( 0, 0, 60,	90, 0, 0 ),

		CreateLED( 0, 170, 30,	-30, 0, 0 ),
		CreateLED( 0, 170, 90,	30, 0, 0 ),

		CreateLED( 0, 70, 30,	30, 0, 0 ),
		CreateLED( 0, 70, 90,	-30, 0, 0 ),
	}

}

-- Replica Dreamshard
ImmCon.TEXT_RASTERIZATION_ITEMS["|H1:item:119866:4:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"] = {

	BlockSize = { 0, -100, 58 },

	LEDOffsets = {
		CreateLED( 0, 30, 0,	0, 0, 0 ),
		CreateLED( 0, 0, 0,		0, 0, 0 ),

		CreateLED( 0, 30, 16,	0, 0, 0 ),
		CreateLED( 0, 0, 16,	0, 0, 0 ),

		CreateLED( 0, 30, 33,	0, 0, 0 ),
		CreateLED( 0, 0, 33,	0, 0, 0 ),

		CreateLED( 0, 192, 6,	90, 0, 0 ),
		CreateLED( 0, 162, 6,	90, 0, 0 ),
		CreateLED( 0, 132, 6,	90, 0, 0 ),

		CreateLED( 0, 4, 65,	-35, 0, 0 ),
		CreateLED( 0, 84, -8,	35, 0, 0 ),

		CreateLED( 0, 53, -27,	35, 0, 0 ),
		CreateLED( 0, -27, 83,	-35, 0, 0 ),
	}

}


ImmCon.DEFAULT.CONST_PARAMS = { }
ImmCon.DEFAULT.CONST_PARAMS[ ImmCon.SHAPE.ARC ] = {
	XRad = 500,
	ZRad = 500,

	RotationAxis = ImmCon.AXIS.YAW,
	RotationDirection = 1,
	ArcPercent = 50
}

ImmCon.DEFAULT.CONST_PARAMS[ ImmCon.SHAPE.BRIDGE ] = {
	XLen = 3000,
	YLen = 800,

	RotationAxis = ImmCon.AXIS.YAW,
	RotationDirection = 1,
	TiltAxis = ImmCon.AXIS.ROLL,
	TiltRange = 25,
}
--[[
ImmCon.DEFAULT.CONST_PARAMS[ ImmCon.SHAPE.BOX ] = {
	XLen = 500,
	YLen = 500,
	ZLen = 500,

	RotationAxis = ImmCon.AXIS.YAW,
	RotationDirection = 1,
	Width = 4,
	Length = 4,
}
]]
ImmCon.DEFAULT.CONST_PARAMS[ ImmCon.SHAPE.CYLINDER ] = {
	XRad = 250,
	ZRad = 250,
	YRotInc = 50,

	RotationAxis = ImmCon.AXIS.YAW,
	RotationDirection = 1,
	RotationItems = 10,
}

ImmCon.DEFAULT.CONST_PARAMS[ ImmCon.SHAPE.SPIRAL ] = {
	XRad = 250,
	ZRad = 250,
	XRadInc = 0,
	ZRadInc = 0,
	YInc = 50,

	RotationAxis = ImmCon.AXIS.YAW,
	RotationDirection = 1,
	RotationItems = 10,
}

ImmCon.DEFAULT.CONST_PARAMS[ ImmCon.SHAPE.CIRCLE ] = {
	XRad = 500,
	ZRad = 500,

	RotationAxis = ImmCon.AXIS.YAW,
	RotationDirection = 1
}

ImmCon.DEFAULT.CONST_PARAMS[ ImmCon.SHAPE.SPHERE ] = {
	XRad = 500,
	YRad = 500,
	ZRad = 500,

	RotationAxis = ImmCon.AXIS.YAW,
	RotationDirection = 1,
	TiltAxis = ImmCon.AXIS.PITCH,
	TiltRange = 80,
	Rows = 5
}

ImmCon.DEFAULT.CONST_PARAMS[ ImmCon.SHAPE.DOME ] = {
	XRad = 500,
	YRad = 500,
	ZRad = 500,

	RotationAxis = ImmCon.AXIS.YAW,
	RotationDirection = 1,
	TiltAxis = ImmCon.AXIS.PITCH,
	TiltRange = 80,
	Rows = 5
}

ImmCon.DEFAULT.CONST_PARAMS[ ImmCon.SHAPE.FLOOR ] = {
	XLen = 500,
	ZLen = 500,

	RotationAxis = ImmCon.AXIS.YAW,
	RotationDirection = 1,
	Width = 5,
	IndentAlternateRows = false
}

ImmCon.DEFAULT.CONST_PARAMS[ ImmCon.SHAPE.PYRAMID ] = {
	XLen = 1500,
	YLen = 1500,
	ZLen = 1500,

	RotationAxis = ImmCon.AXIS.YAW,
	RotationDirection = 1,
	RotationItems = 12
}

ImmCon.DEFAULT.CONST_PARAMS[ ImmCon.SHAPE.WALL ] = {
	XLen = 500,
	YLen = 500,
	ZLen = 0,

	RotationAxis = ImmCon.AXIS.YAW,
	RotationDirection = 1,
	Height = 5,
	IndentAlternateRows = false
}

ImmCon.DEFAULT.CONST_PARAMS[ ImmCon.SHAPE.STAIRS ] = {
	XLen = 500,
	YLen = 500,

	RotationAxis = ImmCon.AXIS.YAW,
	RotationDirection = 1,
}

ImmCon.DEFAULT.CONST_PARAMS[ ImmCon.SHAPE.TEXT ] = {
	XLen = 500,
	YLen = 500,

	RotationAxis = ImmCon.AXIS.YAW,
	RotationDirection = 1,
}


ImmCon.KEYBIND_STRIP_SELECTION_MODE = {
	{
		name = "Construct",
		keybind = "IMMCON_ACTION_SHOW_HIDE",
		callback = function() ImmCon.ShowHideConstGUI() end,
	},
	alignment = KEYBIND_STRIP_ALIGN_LEFT
}


local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")


-- Variables


ImmCon.Vars = nil
ImmCon.HouseFurniture = { }

ImmCon.ConstGUI = nil
ImmCon.ConstParams = nil
ImmCon.ConstShapeControls = { }

ImmCon.CurrentProcess = nil
ImmCon.PreviousEditorMode = nil
ImmCon.SelectedFurniture = nil


-- Methods: Utility


function ImmCon.Error( msg, ... )

	df( "Error: " .. msg, ... )

end


function ImmCon.Message( msg, ... )

	df( msg, ... )

end


function ImmCon.CloneTable( obj )

	if type( obj ) ~= 'table' then return obj end

	local res = {}
	for k, v in pairs( obj ) do res[ ImmCon.CloneTable( k ) ] = ImmCon.CloneTable( v ) end

	return res

end


function ImmCon.SlashCommand( commandArgs )

	ImmCon.ShowHideConstGUI()

end


-- Methods: Saved Variables & Settings


function ImmCon.CleanVars()

	local vars = ImmCon.Vars

	for k, v in pairs( ImmCon.SAVED_VARS_DEFAULTS ) do
		if nil == vars[ k ] then
			if "table" == type( v ) then
				vars[ k ] = ImmCon.CloneTable( v )
			else
				vars[ k ] = v
			end
		end
	end

end


function ImmCon.SetupSettingsMenu()

	local panelData = {
		type = "panel",
		name = "Immaculate Construction",
		displayName = "Immaculate Construction - Settings",
		author = "Jesus Take The Heal",
		version = ImmCon.ADDON_VERSION,
		slashCommand = "/imcoset",
		registerForRefresh = true,
		registerForDefaults = true,
	}

	LAM:RegisterAddonPanel( "ImmConSettings", panelData )

	local optionsTable = {
		[1] = {
			type = "checkbox",
			name = "Auto-Render After Adding Items",
			tooltip = "When toggled ON, construction will automatically begin as soon as a stack of furniture items have been added.",
			getFunc = function() return ImmCon.Vars.RenderAfterAddingItems end,
			setFunc = function(value) ImmCon.Vars.RenderAfterAddingItems = value end,
			default = ImmCon.SAVED_VARS_DEFAULTS.RenderAfterAddingItems,
			disabled = function() return false end,
		},
		[2] = {
			type = "checkbox",
			name = "Drag An Item To Reposition The Shape",
			tooltip = "When toggled ON, the shape you are constructing will be repositioned if you manually move one of the shape's furnishings.",
			getFunc = function() return ImmCon.Vars.DragToMove end,
			setFunc = function(value) ImmCon.Vars.DragToMove = value end,
			default = ImmCon.SAVED_VARS_DEFAULTS.DragToMove,
			disabled = function() return false end,
		},
		[3] = {
			type = "checkbox",
			name = "Reorient An Item To Reorient The Shape's Items",
			tooltip = "When toggled ON, the furnishings that you are constructing with will be reoriented if you manually rotate/tilt/roll one of the shape's furnishings.",
			getFunc = function() return ImmCon.Vars.DragToOrient end,
			setFunc = function(value) ImmCon.Vars.DragToOrient = value end,
			default = ImmCon.SAVED_VARS_DEFAULTS.DragToOrient,
			disabled = function() return false end,
		},
		[4] = {
			type = "checkbox",
			name = "Hide Keybind Strip",
			tooltip = "Toggle this ON if your Housing Editor Keybind Strip at the bottom of the screen is too cluttered.",
			getFunc = function() return ImmCon.Vars.HideKeybinds end,
			setFunc = function(value) ImmCon.Vars.HideKeybinds = value end,
			default = ImmCon.SAVED_VARS_DEFAULTS.HideKeybinds,
			disabled = function() return false end,
		},
	}

	LAM:RegisterOptionControls( "ImmConSettings", optionsTable )

end


-- Methods: Matrix Translation, Scaling and Rotation


function ImmCon.Distance3d( x1, y1, z1, x2, y2, z2 ) return math.sqrt( ( ( x1 - x2 ) ^ 2 ) + ( ( y1 - y2 ) ^ 2 ) + ( ( z1 - z2 ) ^ 2 ) ) end


function ImmCon.PackPoint( p )

	return p[ 1 ], p[ 2 ], p[ 3 ], p[ 4 ], p[ 5 ], p[ 6 ]

end


function ImmCon.RotatePointOnAxisX( p, radians )

	local x, y, z = p[ 1 ], p[ 2 ], p[ 3 ]
	p[ 2 ] = y * math.cos( radians ) - z * math.sin( radians )
	p[ 3 ] = y * math.sin( radians ) + z * math.cos( radians )

end


function ImmCon.RotatePointOnAxisY( p, radians )

	local x, y, z = p[ 1 ], p[ 2 ], p[ 3 ]
	p[ 1 ] = z * math.sin( radians ) + x * math.cos( radians )
	p[ 3 ] = z * math.cos( radians ) - x * math.sin( radians )

end


function ImmCon.RotatePointOnAxisZ( p, radians )

	local x, y, z = p[ 1 ], p[ 2 ], p[ 3 ]
	p[ 1 ] = x * math.cos( radians ) - y * math.sin( radians )
	p[ 2 ] = x * math.sin( radians ) + y * math.cos( radians )

end


function ImmCon.OrientPointOnPitch( p, radians )

	p[ 4 ] = p[ 4 ] + radians

end


function ImmCon.OrientPointOnYaw( p, radians )

	p[ 5 ] = p[ 5 ] + radians

end


function ImmCon.OrientPointOnRoll( p, radians )

	p[ 6 ] = p[ 6 ] + radians

end


function ImmCon.TranslatePoint( p, translation )

	p[ 1 ] = p[ 1 ] + translation[ 1 ]
	p[ 2 ] = p[ 2 ] + translation[ 2 ]
	p[ 3 ] = p[ 3 ] + translation[ 3 ]

end


function ImmCon.ScalePoint( p, factor )

	p[ 1 ] = p[ 1 ] * factor
	p[ 2 ] = p[ 2 ] * factor
	p[ 3 ] = p[ 3 ] * factor

end


function ImmCon.CalculateOuterBoundsAndCenter( points )

	local minX, minY, minZ, maxX, maxY, maxZ = 999999, 999999, 999999, -999999, -999999, -999999

	for _, p in pairs( points ) do

		if p then
			if minX > p[ 1 ] then minX = p[ 1 ] end
			if minY > p[ 2 ] then minY = p[ 2 ] end
			if minZ > p[ 3 ] then minZ = p[ 3 ] end
			if maxX < p[ 1 ] then maxX = p[ 1 ] end
			if maxY < p[ 2 ] then maxY = p[ 2 ] end
			if maxZ < p[ 3 ] then maxZ = p[ 3 ] end
		end

	end

	return ( maxX + minX ) / 2, ( maxY + minY ) / 2, ( maxZ + minZ ) / 2, minX, minY, minZ, maxX, maxY, maxZ

end


-- Methods: Process Management


function ImmCon.GetProcessName( processType )

	if ImmCon.PROCESS.RENDER == processType then
		return "Render"
	elseif ImmCon.PROCESS.ADD_FURNITURE == processType then
		return "Add Furniture"
	elseif ImmCon.PROCESS.RESET_FURNITURE == processType then
		return "Reset Furniture"
	end

	return nil

end


function ImmCon.GetCurrentProcess()

	if nil ~= ImmCon.CurrentProcess then return ImmCon.CurrentProcess.ProcessType end
	return nil

end


function ImmCon.IsProcessing()

	if nil ~= ImmCon.CurrentProcess then
		local processTypeName = ImmCon.GetProcessName( ImmCon.CurrentProcess.ProcessType )
		return true, ( processTypeName or "A" ) .. " process is already in progress."
	else
		return false, nil
	end

end


function ImmCon.StartProcess( processType, processData, successHandler, failureHandler )

	local isProcessing, processMessage = ImmCon.IsProcessing()
	if isProcessing then return false, processMessage end

	local process = { ProcessType = processType, Data = processData, Index = 1, OnSuccess = successHandler, OnFailure = failureHandler, OnFurniturePlaced = nil, OnFurnitureRemoved = nil }
	local initProcedure = nil

	if ImmCon.PROCESS.RENDER == processType then

		initProcedure = ImmCon.RenderInit

	elseif ImmCon.PROCESS.ADD_FURNITURE == processType then

		initProcedure = ImmCon.AddFurnitureInit
		process.OnFurniturePlaced = ImmCon.AddFurnitureOnFurniturePlaced

	elseif ImmCon.PROCESS.RESET_FURNITURE == processType then

		initProcedure = ImmCon.ResetFurnitureInit
		process.OnFurnitureRemoved = ImmCon.ResetFurnitureOnFurnitureRemoved

	else

		return false, "Invalid Process specified."

	end

	ImmCon.CurrentProcess = process

	local success, message = initProcedure()
	if not success then CurrentProcess = nil end

	return success, message

end


function ImmCon.CompleteProcess( isSuccess, message )

	local process = ImmCon.CurrentProcess
	if nil == process then return end
	
	if isSuccess then
		if process.OnSuccess then
			zo_callLater( function() process.OnSuccess( message ) end, ImmCon.DELAY.POST_PROCESS )
		elseif message then
			ImmCon.Message( message )
		end
	else
		if process.OnFailure then
			zo_callLater( function() process.OnFailure( message ) end, ImmCon.DELAY.POST_PROCESS )
		elseif message then
			ImmCon.Error( message )
		end
	end

	ImmCon.CurrentProcess = nil

end


-- Methods: Construction Settings


function ImmCon.ResetConstParams()

	ImmCon.ConstParams = ImmCon.CloneTable( ImmCon.DEFAULT.CONST_PARAMS[ ImmCon.SHAPE.CIRCLE ] )

	local p = ImmCon.ConstParams
	p.Shape = ImmCon.SHAPE.CIRCLE
	p.Pitch = 0
	p.Yaw = 0
	p.Roll = 0
	ImmCon.CenterOnMe()

end


function ImmCon.GetConstParams()

	if nil == ImmCon.ConstParams then
		ImmCon.ResetConstParams()
	end

	return ImmCon.ConstParams

end


-- Methods: Furniture Management


function ImmCon.GetFurniture()

	local houseId = GetCurrentZoneHouseId() or 0
	if 0 >= houseId then return nil end

	local items = ImmCon.HouseFurniture[ houseId ]

	if nil == items then
		items = { }
		ImmCon.HouseFurniture[ houseId ] = items
	end

	return items

end


function ImmCon.IsFurnitureHomogenous( acceptableItemLinks )

	local acceptableItemNames = { }

	for link, _ in pairs( acceptableItemLinks ) do
		acceptableItemNames[ GetItemLinkName( link ) ] = link
	end

	local items = ImmCon.GetFurniture()
	local itemName = nil
	local validName = false
	local rasterizationData = nil

	if 0 >= #items then return nil end

	for _, item in ipairs( items ) do

		if nil == itemName then

			itemName = GetItemLinkName( item.Link )

			if nil ~= acceptableItemNames[ itemName ] then

				rasterizationData = ImmCon.TEXT_RASTERIZATION_ITEMS[ acceptableItemNames[ itemName ] ]
				validName = true

			end

			if not validName then return nil end

		else

			if GetItemLinkName( item.Link ) ~= itemName then return nil end

		end

	end

	return rasterizationData

end


function ImmCon.GetMaxFurnitureDimensions()

	local items = ImmCon.GetFurniture()
	local maxX, maxY, maxZ = 0, 0, 0

	if nil ~= items then
		for _, item in ipairs( items ) do
			if item.Dimensions then
				if maxX < item.Dimensions.X then maxX = item.Dimensions.X end
				if maxY < item.Dimensions.Y then maxY = item.Dimensions.Y end
				if maxZ < item.Dimensions.Z then maxZ = item.Dimensions.Z end
			end
		end
	end

	if maxX > 1 then maxX = maxX - 1 end
	if maxY > 1 then maxY = maxY - 1 end
	if maxZ > 1 then maxZ = maxZ - 1 end

	return maxX, maxY, maxZ

end


function ImmCon.GetFurnitureCenterOffsets()

	local x, y, z = ImmCon.GetMaxFurnitureDimensions()
	return { X = ( x / 2 ), Y = ( y / 2 ), Z = ( z / 2 ) }

end


function ImmCon.GetFurnitureCount()

	local items = ImmCon.GetFurniture()
	if nil ~= items then
		return #items
	else
		return 0
	end

end


function ImmCon.GetFurnitureById( id )

	if nil == id or "number" ~= type( id ) then return nil, nil end
	local items = ImmCon.GetFurniture()

	for index, item in ipairs( items ) do
		if id == item.Id then return item, index end
	end

	return nil, nil

end


function ImmCon.SortFurniture( groups )

	if nil == groups or 0 >= #groups then return end

	local furniture = ImmCon.GetFurniture()
	local ungroupedFurniture = { }
	local groupFurniture = { }
	local furnitureName
	local matched

	for groupIndex, groupName in ipairs( groups ) do
		table.insert( groupFurniture, groupIndex, { } )
	end

	while 0 < #furniture do

		matched = false
		furnitureName = GetItemLinkName( furniture[ 1 ].Link )

		for groupIndex, groupName in ipairs( groups ) do
			if furnitureName == groupName then

				table.insert( groupFurniture[ groupIndex ], furniture[ 1 ] )
				matched = true
				break

			end
		end

		if not matched then
			table.insert( ungroupedFurniture, furniture[ 1 ] )
		end

		table.remove( furniture, 1 )

	end

	local index = 1

	repeat

		matched = false

		for groupIndex, _ in ipairs( groups ) do

			if index <= #groupFurniture[ groupIndex ] then
				matched = true
				table.insert( furniture, groupFurniture[ groupIndex ][ index ] )
			end

		end

		index = index + 1

	until not matched

	for _, f in ipairs( ungroupedFurniture ) do
		table.insert( furniture, f )
	end

end


function ImmCon.ClearFurniture()

	local houseId = GetCurrentZoneHouseId() or 0
	if 0 >= houseId then return nil end

	ImmCon.HouseFurniture[ houseId ] = { }

end


function ImmCon.RemoveFurniture( id )

	local item, index = ImmCon.GetFurnitureById( id )
	if nil == index then return false end

	local items = ImmCon.GetFurniture()
	table.remove( items, index )
	ImmCon.RefreshConstGUI()

	return true

end


function ImmCon.MeasureFurniture( furniture )

	if nil == furniture then return end

	if "table" == type( furniture ) then

		if nil == furniture.Id then return end

		local minX, minY, minZ, maxX, maxY, maxZ = HousingEditorGetFurnitureWorldBounds( furniture.Id )
		local lengthX, lengthY, lengthZ = 0, 0, 0

		if nil ~= minX and nil ~= minY and nil ~= minZ and nil ~= maxX and nil ~= maxY and nil ~= maxZ then
			furniture.Dimensions = { X = maxX - minX - 2, Y = maxY - minY - 2, Z = maxZ - minZ - 2 }
		else
			furniture.Dimensions = nil
		end

	else

		local minX, minY, minZ, maxX, maxY, maxZ = HousingEditorGetFurnitureWorldBounds( furniture )
		local lengthX, lengthY, lengthZ = 0, 0, 0

		if nil ~= minX and 0 ~= minX then
			return maxX - minX, maxY - minY, maxZ - minZ
		else
			return 0, 0, 0
		end

	end

end


function ImmCon.AddFurniture( id, inventoryItem )

	if nil == inventoryItem then inventoryItem = true end
	if nil == id or "number" ~= type( id ) then return nil end

	local items = ImmCon.GetFurniture()
	if nil == items then return nil end

	local item, _ = ImmCon.GetFurnitureById( id )
	if nil ~= item then return nil end

	local x, y, z = HousingEditorGetFurnitureWorldPosition( id )
	local pitch, yaw, roll = HousingEditorGetFurnitureOrientation( id )
	local link = GetPlacedFurnitureLink( id )

	item = { Id = id, Link = link, Inv = inventoryItem, Origin = { X = x, Y = y, Z = z, Pitch = pitch, Yaw = yaw, Roll = roll } }
	table.insert( items, item )

	zo_callLater( function() ImmCon.MeasureFurniture( item ) end, 100 )

	return item

end


function ImmCon.GetFurnitureGroups()

	local groups, orderedGroups = { }, { }

	local items = ImmCon.GetFurniture()
	if nil == items then return groups end

	local name = nil
	for _, item in ipairs( items ) do

		name = GetItemLinkName( item.Link )

		if nil ~= name and "" ~= name and not groups[ name ] then
			groups[ name ] = true
			table.insert( orderedGroups, name )
		end

	end

	return orderedGroups

end


-- Methods: Add Furniture Process


function ImmCon.AddTargetedFurniture()

	if not HousingEditorCanSelectTargettedFurniture() then
		d( "Place a stack of one type of furniture together; then target the stack and try again." )
		return 0
	end

	HousingEditorSelectTargettedFurniture()
	local furnitureId = HousingEditorGetSelectedFurnitureId()
	HousingEditorRequestSelectedPlacement()

	if nil == furnitureId or 0 == furnitureId then
		d( "Failed to select targeted furniture." )
		return 0
	end

	local oX, oY, oZ = HousingEditorGetFurnitureWorldPosition( furnitureId )

	if 0 == oX or 0 == oY or 0 == oZ then
		d( "Furniture must be placed down first. Please target the stack and try again." )
		return 0
	end

	local lenX, lenY, lenZ = ImmCon.MeasureFurniture( furnitureId )
	local itemLink, collectibleLink = GetPlacedFurnitureLink( furnitureId, LINK_STYLE_BRACKETS )
	local itemName, itemIcon, _ = GetPlacedHousingFurnitureInfo( furnitureId )

	if nil == itemLink or "" == itemLink then
		d( "The ZeniMax API does not yet correctly support collectible furnishings." )
		return 0
	end

	local radius = math.max( lenX, lenY, lenZ )

	if nil == radius or 0 == radius then
		radius = 200
	elseif 200 > radius then
		radius = radius + 100
	end

	local id, x, y, z = nil, nil, nil, nil
	local count = 0

	repeat

		id = GetNextPlacedHousingFurnitureId( id )
		if nil ~= id then

			x, y, z = HousingEditorGetFurnitureWorldPosition( id )
			if radius >= ImmCon.Distance3d( x, y, z, oX, oY, oZ ) then

				-- GetItemLinkName( GetPlacedFurnitureLink( id, LINK_STYLE_BRACKETS ) )
				local name, _, _ = GetPlacedHousingFurnitureInfo( id, "house" )
				if name == itemName then

					if nil ~= ImmCon.AddFurniture( id, false ) then count = count + 1 end

				end

			end

		end

	until nil == id

	if nil ~= itemIcon and "" ~= itemIcon then itemIcon = zo_iconFormat( itemIcon ) end
	df( "Added %s %s x%s.", itemIcon, itemName, tostring( count ) )

	ImmCon.AddFurnitureOnComplete()

	return count

end


function ImmCon.AddInventoryContextMenu( inventorySlot )

	if ZO_PlayerInventoryBackpack:IsHidden() then return end
	if inventorySlot:GetOwningWindow() == ZO_TradingHouse then return end
	if 0 >= GetCurrentZoneHouseId() then return end
	if not IsOwnerOfCurrentHouse() then return end

	local bag, slotIndex = ZO_Inventory_GetBagAndIndex( inventorySlot )
	local link = GetItemLink( bag, slotIndex )

	if not IsItemLinkPlaceableFurniture( link ) then return end

	zo_callLater( function() ImmCon.AddInventoryContextMenuCallback( bag, slotIndex, link ) end, 50 )

end


function ImmCon.AddInventoryContextMenuCallback( bag, slotIndex, link )

	local stackSize, _ = GetSlotStackSize( bag, slotIndex )
	local menuOption = ""

	if 0 < stackSize then
		local items = ImmCon.GetFurnitureCount()

		if 0 < items then
			menuOption = "Add "
		else
			menuOption = "Construct with "
		end

		if 1 < stackSize then
			menuOption = menuOption .. "these " .. tostring( stackSize ) .. " furnishings"
		else
			menuOption = menuOption .. "this furnishing"
		end

		if 0 < items then
			menuOption = menuOption .. " to construction"
		end

		AddCustomMenuItem( menuOption, function() ImmCon.AddItemsFromInventory( bag, slotIndex, link ) end, MENU_ADD_OPTION_LABEL )
		ShowMenu( self )

	end

end


function ImmCon.AddItemsFromInventory( bag, slotIndex, link )

	local processData = { Bag = bag, SlotIndex = slotIndex, Link = link }
	local success, message = ImmCon.StartProcess( ImmCon.PROCESS.ADD_FURNITURE, processData, ImmCon.AddFurnitureOnComplete, ImmCon.AddFurnitureOnComplete )

	if not success then
		if message then ImmCon.Error( message ) end
		return false
	end

	return true

end


function ImmCon.AddFurnitureInit()

	local process = ImmCon.CurrentProcess
	if nil == process or nil == process.Data then return false end

	local bag, slotIndex, link = process.Data.Bag, process.Data.SlotIndex, process.Data.Link
	local stackSize, _ = GetSlotStackSize( bag, slotIndex )
	local stackSizeString = ""

	if 1 < stackSize then stackSizeString = " (x" .. tostring( stackSize ) .. ")" end
	ImmCon.Message( "Placing %s%s for immaculate construction...", link, stackSizeString )

	process.Data.StackIndex = 1
	process.Data.StackSize = stackSize

	zo_callLater( ImmCon.AddFurnitureNext, ImmCon.DELAY.ADD_FURNITURE )

	return true

end


function ImmCon.AddFurnitureNext()

	local process = ImmCon.CurrentProcess
	if nil == process or ImmCon.PROCESS.ADD_FURNITURE ~= process.ProcessType then return end

	local bag, slotIndex, link, index, size = process.Data.Bag, process.Data.SlotIndex, process.Data.Link, process.Data.StackIndex, process.Data.StackSize

	if index > size then
		ImmCon.Message( "Furnishings added." )
		ImmCon.CompleteProcess( true )

		return
	end

	local itemLink = GetItemLink( bag, slotIndex )
	local success = true

	if nil == itemLink or itemLink ~= link then
		success = false
		ImmCon.Error( "Inventory contents changed while processing." )
	else
		local result = HousingEditorRequestItemPlacement( bag, slotIndex, 5000, 5000, 5000, 0, 0, 0 )

		if HOUSING_REQUEST_RESULT_SUCCESS ~= result then
			success = false

			if HOUSING_REQUEST_RESULT_LOW_IMPACT_ITEM_PLACE_LIMIT == result or HOUSING_REQUEST_RESULT_LOW_IMPACT_COLLECTIBLE_PLACE_LIMIT == result or HOUSING_REQUEST_RESULT_HIGH_IMPACT_ITEM_PLACE_LIMIT == result or HOUSING_REQUEST_RESULT_HIGH_IMPACT_COLLECTIBLE_PLACE_LIMIT == result then
				ImmCon.Error( "Cannot place additional furnishings: Item limit reached." )
			end
		end
	end

	if not success then
		ImmCon.CompleteProcess( false )
		return
	end

	process.Data.StackIndex = process.Data.StackIndex + 1

end


function ImmCon.AddFurnitureOnFurniturePlaced( eventCode, furnitureId, collectibleId )

	local process = ImmCon.CurrentProcess

	if nil ~= furnitureId then
		ImmCon.AddFurniture( furnitureId, true )
		zo_callLater( ImmCon.AddFurnitureNext, ImmCon.DELAY.ADD_FURNITURE )
	end

end


function ImmCon.AddFurnitureOnComplete()

	local p = ImmCon.GetConstParams()
	p.Items = ImmCon.GetFurnitureCount()
	if nil == p.X or 0 == p.X then ImmCon.CenterOnMe() end

	local groups = ImmCon.GetFurnitureGroups()
	if nil ~= groups and 1 < #groups then ImmCon.SortFurniture( groups ) end

	ImmCon.ShowConstGUI()
	if ImmCon.Vars.RenderAfterAddingItems then ImmCon.ConstGUIChanged() end

end


-- Methods: Reset Furniture Process


function ImmCon.ResetFurniture( furnitureSet, successHandler, failureHandler )

	local isProcessing, processMessage = ImmCon.IsProcessing()

	if isProcessing then
		ImmCon.Error( processMessage )
		return false
	end

	if nil == furnitureSet then
		ImmCon.Message( "Resetting construction furnishings..." )
		furnitureSet = ImmCon.GetFurniture()
	else
		ImmCon.Message( "Resetting excess furnishings..." )
	end

	local success, message = ImmCon.StartProcess( ImmCon.PROCESS.RESET_FURNITURE, furnitureSet, successHandler, failureHandler )
	if not success then
		if message then ImmCon.Error( message ) end
		return false
	end

	return true

end


function ImmCon.ResetFurnitureInit()

	local process = ImmCon.CurrentProcess
	if nil == process or nil == process.Data then return false end

	zo_callLater( ImmCon.ResetFurnitureNext, ImmCon.DELAY.RESET_FURNITURE )
	return true

end


function ImmCon.ResetFurnitureNext()

	local process = ImmCon.CurrentProcess
	if nil == process or ImmCon.PROCESS.RESET_FURNITURE ~= process.ProcessType then return end

	local complete, success = true, true
	local id, item, o = nil, nil, nil
	local items = process.Data

	if nil ~= items then
		local index = 1

		while index <= #items do
			item = items[ index ]
			id = item.Id

			if nil == id then
				table.remove( items, index )
			else
				if nil == item.Inv or item.Inv then
					local result = HousingEditorRequestRemoveFurniture( id )

					if HOUSING_REQUEST_RESULT_SUCCESS == result then
						table.remove( items, index )
						complete = false
					else
						ImmCon.Error( "Cannot retrieve furnishing." )
						success = false
					end

					break
				else
					table.remove( items, index )
					complete = false

					o = item.Origin
					HousingEditorRequestChangePositionAndOrientation( id, o.X, o.Y, o.Z, o.Pitch, o.Yaw, o.Roll )
					ImmCon.RemoveFurniture( id )

					zo_callLater( ImmCon.ResetFurnitureNext, ImmCon.DELAY.RESET_FURNITURE )
					break
				end
			end
		end
	end

	if complete then
		if success then
			ImmCon.Message( "Furnishings reset." )
			ImmCon.ClearFurniture()
		else
			ImmCon.Error( "Failed to reset all furnishings." )
		end

		ImmCon.CompleteProcess( success, nil )
	end

end


function ImmCon.ResetFurnitureOnFurnitureRemoved( eventCode, furnitureId, collectibleId )

	if nil ~= furnitureId then zo_callLater( ImmCon.ResetFurnitureNext, ImmCon.DELAY.RESET_FURNITURE ) end

end


-- Methods: Render Process


function ImmCon.Render( restartExistingProcess, successHandler, failureHandler )

	if nil == successHandler then successHandler = ImmCon.RenderComplete end
	local data = { Iteration = 0, Index = 1, CenterOffsets = ImmCon.GetFurnitureCenterOffsets() }

	if ImmCon.PROCESS.RENDER == ImmCon.GetCurrentProcess() then
		if nil ~= restartExistingProcess and false == restartExistingProcess then
			return false
		end

		ImmCon.CurrentProcess.Data = data
		ImmCon.CurrentProcess.SuccessHandler = successHandler
		ImmCon.CurrentProcess.FailureHandler = failureHandler
		ImmCon.PreRenderPoints()
		ImmCon.EnableSaveReset( false )

		return true
	else
		local success = ImmCon.StartProcess( ImmCon.PROCESS.RENDER, data, successHandler, failureHandler )
		if success then ImmCon.EnableSaveReset( false ) end
		
		return success
	end

end


function ImmCon.RenderInit()

	ImmCon.PreRenderPoints()
	zo_callLater( ImmCon.RenderNext, ImmCon.DELAY.RENDER )
	return true

end


function ImmCon.RenderComplete()

	ImmCon.EnableSaveReset( true )

end


function ImmCon.PreRenderPoints()

	local process = ImmCon.CurrentProcess
	local p = ImmCon.GetConstParams()
	local data = process.Data
	local originVector = { p.X, p.Y, p.Z }
	local items = tonumber( p.Items or 1 )
	local points = { }

	if 0 == items then items = 1 end
	data.Points = points

	local zRotation, yRotation, xRotation = p.ShapeRoll or 0, p.ShapeRotation or 0, p.ShapePitch or 0

	if ImmCon.SHAPE.TEXT == p.Shape then

		ImmCon.RasterizeText( process, p, data, originVector, items, points, xRotation, yRotation, zRotation )

	elseif ImmCon.SHAPE.ARC == p.Shape or ImmCon.SHAPE.CIRCLE == p.Shape then

		local arcPercent = 1
		if ImmCon.SHAPE.ARC == p.Shape then arcPercent = ( p.ArcPercent or 100 ) / 100 end
		local increment = ( 360 * arcPercent / items ) 
		local xFunc, zFunc = math.cos, math.sin

		for i = 0, items - 1 do
			local xLen, yLen, zLen = p.XRad * xFunc( math.rad( i * increment ) ), 0, p.ZRad * zFunc( math.rad( i * increment ) )
			local point = { xLen, yLen, zLen, math.rad( p.Pitch ), math.rad( p.Yaw ), math.rad( p.Roll ) }

			if		p.RotationAxis == ImmCon.AXIS.PITCH then	point[4] = point[4] + math.rad( ImmCon.CalculateTangentAngle( xLen, zLen, p.RotationDirection ) )
			elseif	p.RotationAxis == ImmCon.AXIS.YAW then		point[5] = point[5] + math.rad( ImmCon.CalculateTangentAngle( xLen, zLen, p.RotationDirection ) )
			elseif	p.RotationAxis == ImmCon.AXIS.ROLL then		point[6] = point[6] + math.rad( ImmCon.CalculateTangentAngle( xLen, zLen, p.RotationDirection ) ) end

			if 0 ~= zRotation then ImmCon.RotatePointOnAxisZ( point, math.rad( zRotation ) ) end
			if 0 ~= xRotation then ImmCon.RotatePointOnAxisX( point, math.rad( xRotation ) ) end
			if 0 ~= yRotation then ImmCon.RotatePointOnAxisY( point, math.rad( yRotation ) ) end

			ImmCon.TranslatePoint( point, originVector )
			points[ #points + 1 ] = point
		end

	elseif ImmCon.SHAPE.BOX == p.Shape then

		local xItems, zItems, yItems = p.Width, p.Length, 0
		if 0 >= xItems then xItems = 1 end
		if 0 >= zItems then zItems = 1 end
		yItems = math.ceil( items / ( xItems * 2 + zItems * 2 ) )
		if 0 >= yItems then yItems = 1 end

		--xItems, yItems, zItems = xItems + 1, yItems + 1, zItems + 1

		local xUnits, zUnits, yUnits = p.XLen / xItems, p.ZLen / zItems, p.YLen / yItems
		local centerVector = { -1 * p.XLen / 2, 0, -1 * p.ZLen / 2 }

		d( "x,y,z Items" )
		d( xItems, yItems, zItems )
		d( "x,y,z Units" )
		d( xUnits, yUnits, zUnits )

		for y = 0.5, yItems - 0.5 do
			for x = 0.5, xItems - 0.5 do
				local point = { x * xUnits, y * yUnits, 0 * zUnits, math.rad( p.Pitch ), math.rad( p.Yaw - 90 + yRotation ), math.rad( p.Roll ) }

				ImmCon.TranslatePoint( point, centerVector )
				if 0 ~= zRotation then ImmCon.RotatePointOnAxisZ( point, math.rad( zRotation ) ) end
				if 0 ~= xRotation then ImmCon.RotatePointOnAxisX( point, math.rad( xRotation ) ) end
				if 0 ~= yRotation then ImmCon.RotatePointOnAxisY( point, math.rad( yRotation ) ) end
				ImmCon.TranslatePoint( point, originVector )

				points[ #points + 1 ] = point

				point = { x * xUnits, y * yUnits, ( zItems - 0 ) * zUnits, math.rad( p.Pitch ), math.rad( p.Yaw + 90 + yRotation ), math.rad( p.Roll ) }

				ImmCon.TranslatePoint( point, centerVector )
				if 0 ~= zRotation then ImmCon.RotatePointOnAxisZ( point, math.rad( zRotation ) ) end
				if 0 ~= xRotation then ImmCon.RotatePointOnAxisX( point, math.rad( xRotation ) ) end
				if 0 ~= yRotation then ImmCon.RotatePointOnAxisY( point, math.rad( yRotation ) ) end
				ImmCon.TranslatePoint( point, originVector )

				points[ #points + 1 ] = point
			end

			for z = 0.5, zItems - 0.5 do
				local point = { 0 * xUnits, y * yUnits, z * zUnits, math.rad( p.Pitch ), math.rad( p.Yaw + 0 + yRotation ), math.rad( p.Roll ) }

				ImmCon.TranslatePoint( point, centerVector )
				if 0 ~= zRotation then ImmCon.RotatePointOnAxisZ( point, math.rad( zRotation ) ) end
				if 0 ~= xRotation then ImmCon.RotatePointOnAxisX( point, math.rad( xRotation ) ) end
				if 0 ~= yRotation then ImmCon.RotatePointOnAxisY( point, math.rad( yRotation ) ) end
				ImmCon.TranslatePoint( point, originVector )

				points[ #points + 1 ] = point

				point = { ( xItems - 0 ) * xUnits, y * yUnits, z * zUnits, math.rad( p.Pitch ), math.rad( p.Yaw - 180 + yRotation ), math.rad( p.Roll ) }

				ImmCon.TranslatePoint( point, centerVector )
				if 0 ~= zRotation then ImmCon.RotatePointOnAxisZ( point, math.rad( zRotation ) ) end
				if 0 ~= xRotation then ImmCon.RotatePointOnAxisX( point, math.rad( xRotation ) ) end
				if 0 ~= yRotation then ImmCon.RotatePointOnAxisY( point, math.rad( yRotation ) ) end
				ImmCon.TranslatePoint( point, originVector )

				points[ #points + 1 ] = point
			end
		end

	elseif ImmCon.SHAPE.BRIDGE == p.Shape then

		local xRad, yRad = p.XLen / 2, p.YLen
		local tiltRange = p.TiltRange
		local incDegree = ( tiltRange * 2 ) / items

		-- Shift Origin Vector's Y-axis by -yRad to compensate for bridges' seemingly upward shift from Cosine function.
		originVector[2] = originVector[2] - yRad

		for i = 1, items do
			local degrees = ( -1 * tiltRange ) + ( ( i - 0.5 ) * incDegree )
			local point = { xRad * math.sin( math.rad( degrees ) ), yRad * math.cos( math.rad( math.abs( degrees ) ) ), 0, math.rad( p.Pitch ), math.rad( p.Yaw ), math.rad( p.Roll ) }

			if		p.TiltAxis == ImmCon.AXIS.PITCH then		point[ 4 ] = math.rad( p.Pitch - tiltRange * math.sin( math.rad( degrees ) ) )
			elseif	p.TiltAxis == ImmCon.AXIS.YAW then			point[ 5 ] = math.rad( p.Yaw - tiltRange * math.sin( math.rad( degrees ) ) )
			elseif	p.TiltAxis == ImmCon.AXIS.ROLL then			point[ 6 ] = math.rad( p.Roll - tiltRange * math.sin( math.rad( degrees ) ) ) end

			if		p.RotationAxis == ImmCon.AXIS.PITCH then	point[ 4 ] = point[ 4 ] + ( p.RotationDirection * math.rad( yRotation ) )
			elseif	p.RotationAxis == ImmCon.AXIS.YAW then		point[ 5 ] = point[ 5 ] + ( p.RotationDirection * math.rad( yRotation ) )
			elseif	p.RotationAxis == ImmCon.AXIS.ROLL then		point[ 6 ] = point[ 6 ] + ( p.RotationDirection * math.rad( yRotation ) ) end

			if 0 ~= zRotation then ImmCon.RotatePointOnAxisZ( point, math.rad( zRotation ) ) end
			if 0 ~= xRotation then ImmCon.RotatePointOnAxisX( point, math.rad( xRotation ) ) end
			if 0 ~= yRotation then ImmCon.RotatePointOnAxisY( point, math.rad( yRotation ) ) end
			ImmCon.TranslatePoint( point, originVector )
			points[ #points + 1 ] = point
		end

	elseif ImmCon.SHAPE.CYLINDER == p.Shape then

		local xRad, zRad = p.XRad, p.ZRad
		local yRotInc = p.YRotInc
		local rotationItems = p.RotationItems
		local xFunc, zFunc = math.cos, math.sin
		
		if nil == rotationItems or 0 >= rotationItems then rotationItems = 1 end
		if nil == yRotInc then yRotInc = 0 end 
		local itemDegrees = 360 / rotationItems
		local yOffset = 0

		for i = 0, items - 1 do
			local point = { xRad * xFunc( math.rad( ( i * itemDegrees ) % 360 ) ), yOffset, zRad * zFunc( math.rad( ( i * itemDegrees ) % 360 ) ), math.rad( p.Pitch ), math.rad( p.Yaw ), math.rad( p.Roll ) }

			if		p.RotationAxis == ImmCon.AXIS.PITCH then	point[4] = math.rad( ImmCon.CalculateTangentAngle( point[1], point[3], p.RotationDirection, p.Pitch ) )
			elseif	p.RotationAxis == ImmCon.AXIS.YAW then		point[5] = math.rad( ImmCon.CalculateTangentAngle( point[1], point[3], p.RotationDirection, p.Yaw ) )
			elseif	p.RotationAxis == ImmCon.AXIS.ROLL then		point[6] = math.rad( ImmCon.CalculateTangentAngle( point[1], point[3], p.RotationDirection, p.Roll ) ) end

			if 0 ~= zRotation then ImmCon.RotatePointOnAxisZ( point, math.rad( zRotation ) ) end
			if 0 ~= xRotation then ImmCon.RotatePointOnAxisX( point, math.rad( xRotation ) ) end
			if 0 ~= yRotation then ImmCon.RotatePointOnAxisY( point, math.rad( yRotation ) ) end
			ImmCon.TranslatePoint( point, originVector )
			points[ #points + 1 ] = point

			if 0 == ( i + 1 ) % rotationItems then yOffset = yOffset + yRotInc end
		end

	elseif ImmCon.SHAPE.DOME == p.Shape then

		local rows = p.Rows
		if 0 >= rows then rows = 1 end
		local width = math.floor( p.Items / rows )
		local xFunc, zFunc = math.cos, math.sin
		local rowIncrement = ( 90 / rows )
		local colIncrement = ( 360 / width )
		local maxIter = rows * width

		for i = 0, maxIter do

			local rowDegrees = rowIncrement * ( i % rows )
			local colDegrees = ( colIncrement * math.floor( i / rows ) ) % 360
			local direction = 1
			if 0 > rowDegrees then direction = -1 end
			rowDegrees = math.abs( rowDegrees )

			local xLen, zLen = 0, 0
			xLen = p.XRad * math.cos( math.rad( rowDegrees ) ) * xFunc( math.rad( colDegrees ) )
			zLen = p.ZRad * math.cos( math.rad( rowDegrees ) ) * zFunc( math.rad( colDegrees ) )

			local point = {
				xLen,
				p.YRad * math.sin( math.rad( rowDegrees ) ) * direction,
				zLen,
				math.rad( p.Pitch ),
				math.rad( p.Yaw ),
				math.rad( p.Roll )
			}

			if		p.RotationAxis == ImmCon.AXIS.PITCH then	point[4] = math.rad( ImmCon.CalculateTangentAngle( xLen, zLen, p.RotationDirection, p.Pitch ) )
			elseif	p.RotationAxis == ImmCon.AXIS.YAW then		point[5] = math.rad( ImmCon.CalculateTangentAngle( xLen, zLen, p.RotationDirection, p.Yaw ) )
			elseif	p.RotationAxis == ImmCon.AXIS.ROLL then		point[6] = math.rad( ImmCon.CalculateTangentAngle( xLen, zLen, p.RotationDirection, p.Roll ) ) end

			if		p.TiltAxis == ImmCon.AXIS.PITCH then		point[4] = math.rad( p.Pitch + p.TiltRange * math.sin( math.rad( rowDegrees ) ) * direction )
			elseif	p.TiltAxis == ImmCon.AXIS.YAW then			point[5] = math.rad( p.Yaw + p.TiltRange * math.sin( math.rad( rowDegrees ) ) * direction )
			elseif	p.TiltAxis == ImmCon.AXIS.ROLL then			point[6] = math.rad( p.Roll + p.TiltRange * math.sin( math.rad( rowDegrees ) ) * direction ) end

			if 0 ~= zRotation then ImmCon.RotatePointOnAxisZ( point, math.rad( zRotation ) ) end
			if 0 ~= xRotation then ImmCon.RotatePointOnAxisX( point, math.rad( xRotation ) ) end
			if 0 ~= yRotation then ImmCon.RotatePointOnAxisY( point, math.rad( yRotation ) ) end
			ImmCon.TranslatePoint( point, originVector )

			points[ #points + 1 ] = point

		end

	elseif ImmCon.SHAPE.FLOOR == p.Shape then

		local xItems, zItems = p.Width, 0
		if 1 > xItems then xItems = 1 end
		zItems = math.floor( items / xItems )

		local xUnits, zUnits = p.XLen / xItems, p.ZLen / zItems
		local centerVector = { data.CenterOffsets.X + -1 * p.XLen / 2, 0, data.CenterOffsets.Z + p.ZLen / 2 * -1 }

		for x = 0, xItems - 1 do
			for z = 0, zItems - 1 do
				local point = { x * xUnits, 0, z * zUnits, math.rad( p.Pitch + xRotation ), math.rad( p.Yaw + yRotation ), math.rad( p.Roll + zRotation ) }
				if p.IndentAlternateRows and 1 == x % 2 then point[ 3 ] = point[ 3 ] + zUnits / 2 end
 
				ImmCon.TranslatePoint( point, centerVector )
				if 0 ~= zRotation then ImmCon.RotatePointOnAxisZ( point, math.rad( zRotation ) ) end
				if 0 ~= xRotation then ImmCon.RotatePointOnAxisX( point, math.rad( xRotation ) ) end
				if 0 ~= yRotation then ImmCon.RotatePointOnAxisY( point, math.rad( yRotation ) ) end
				ImmCon.TranslatePoint( point, originVector )

				points[ #points + 1 ] = point
			end
		end

	elseif ImmCon.SHAPE.PYRAMID == p.Shape then

		local sides = 4
		local rotationUnits = 360 / sides
		local yItems = p.Height or 1
		local baseXLen, baseYLen, baseZLen = p.XLen or 1, p.YLen or 1, p.ZLen or 1
		local baseRotationItems = p.RotationItems or 1
		
		local yInc = baseYLen / yItems
		local xInc, zInc = 1, 1
		local centerVector = { -1 * baseXLen / 2, 0, -1 * baseZLen / 2 }

		for yIndex = 0, yItems - 1 do

			local y = yIndex * yInc
			local tierPercent = ( 1 - ( yIndex / yItems ) )
			local xLen, zLen = baseXLen * tierPercent, baseZLen * tierPercent
			local rotationItems = baseRotationItems * tierPercent
			local sideItems = math.floor( rotationItems / sides )
			local xUnits, zUnits = xLen / sideItems, zLen / sideItems
			local centerVector = { -1 * xLen / 2, y, -1 * zLen / 2 }
			local point = nil

			for xIndex = 0, sideItems - 1 do
				local x = ( xUnits / 2 ) + xIndex * xUnits

				point = { x, y, 0, math.rad( p.Pitch ), math.rad( p.Yaw + yRotation ), math.rad( p.Roll ) }
				ImmCon.TranslatePoint( point, centerVector )
 				if 0 ~= zRotation then ImmCon.RotatePointOnAxisZ( point, math.rad( zRotation ) ) end
				if 0 ~= xRotation then ImmCon.RotatePointOnAxisX( point, math.rad( xRotation ) ) end
				if 0 ~= yRotation then ImmCon.RotatePointOnAxisY( point, math.rad( yRotation ) ) end
				ImmCon.TranslatePoint( point, originVector )
				points[ #points + 1 ] = point

				point = { x, y, zLen, math.rad( p.Pitch ), math.rad( p.Yaw + yRotation + 2 * rotationUnits ), math.rad( p.Roll ) }
				ImmCon.TranslatePoint( point, centerVector )
 				if 0 ~= zRotation then ImmCon.RotatePointOnAxisZ( point, math.rad( zRotation ) ) end
				if 0 ~= xRotation then ImmCon.RotatePointOnAxisX( point, math.rad( xRotation ) ) end
				if 0 ~= yRotation then ImmCon.RotatePointOnAxisY( point, math.rad( yRotation ) ) end
				ImmCon.TranslatePoint( point, originVector )
				points[ #points + 1 ] = point
			end

			for zIndex = 0, sideItems - 1 do
				local z = ( zUnits / 2 ) + zIndex * zUnits

				point = { 0, y, z, math.rad( p.Pitch ), math.rad( p.Yaw + yRotation + rotationUnits ), math.rad( p.Roll ) }
				ImmCon.TranslatePoint( point, centerVector )
 				if 0 ~= zRotation then ImmCon.RotatePointOnAxisZ( point, math.rad( zRotation ) ) end
				if 0 ~= xRotation then ImmCon.RotatePointOnAxisX( point, math.rad( xRotation ) ) end
				if 0 ~= yRotation then ImmCon.RotatePointOnAxisY( point, math.rad( yRotation ) ) end
				ImmCon.TranslatePoint( point, originVector )
				points[ #points + 1 ] = point

				point = { xLen, y, z, math.rad( p.Pitch ), math.rad( p.Yaw + yRotation + 3 * rotationUnits ), math.rad( p.Roll ) }
				ImmCon.TranslatePoint( point, centerVector )
 				if 0 ~= zRotation then ImmCon.RotatePointOnAxisZ( point, math.rad( zRotation ) ) end
				if 0 ~= xRotation then ImmCon.RotatePointOnAxisX( point, math.rad( xRotation ) ) end
				if 0 ~= yRotation then ImmCon.RotatePointOnAxisY( point, math.rad( yRotation ) ) end
				ImmCon.TranslatePoint( point, originVector )
				points[ #points + 1 ] = point
			end

		end

	elseif ImmCon.SHAPE.SPIRAL == p.Shape then

		local xFunc, zFunc = math.cos, math.sin
		local xRadInc, zRadInc, yInc = p.XRadInc, p.ZRadInc, p.YInc
		local xRad, zRad = p.XRad, p.ZRad
		local incPercent, incDegrees, degrees = 0, 0, 0
		local yOffset = 0

		local baseRotationItems = p.RotationItems or 1
		local baseCircum = ( xRad + zRad ) * math.pi

		for i = 0, items - 1 do

			local point = { xRad * xFunc( math.rad( degrees ) ), yOffset, zRad * zFunc( math.rad( degrees ) ), math.rad( p.Pitch + xRotation ), math.rad( p.Yaw + yRotation ), math.rad( p.Roll + zRotation ) }

			if		p.RotationAxis == ImmCon.AXIS.PITCH then	point[4] = math.rad( ImmCon.CalculateTangentAngle( point[1], point[3], p.RotationDirection, p.Pitch ) )
			elseif	p.RotationAxis == ImmCon.AXIS.YAW then		point[5] = math.rad( ImmCon.CalculateTangentAngle( point[1], point[3], p.RotationDirection, p.Yaw ) )
			elseif	p.RotationAxis == ImmCon.AXIS.ROLL then		point[6] = math.rad( ImmCon.CalculateTangentAngle( point[1], point[3], p.RotationDirection, p.Roll ) ) end

			if 0 ~= zRotation then ImmCon.RotatePointOnAxisZ( point, math.rad( zRotation ) ) end
			if 0 ~= xRotation then ImmCon.RotatePointOnAxisX( point, math.rad( xRotation ) ) end
			if 0 ~= yRotation then ImmCon.RotatePointOnAxisY( point, math.rad( yRotation ) ) end
			ImmCon.TranslatePoint( point, originVector )
			points[ #points + 1 ] = point

			xRad, zRad, yOffset = xRad + xRadInc, zRad + zRadInc, yOffset + yInc

			incPercent = ( ( xRad + zRad ) * math.pi ) / baseCircum
			incDegrees = 360 / ( baseRotationItems * incPercent )
			degrees = ( degrees + incDegrees ) % 360

		end

	elseif ImmCon.SHAPE.STAIRS == p.Shape then

		local xInc, yInc = p.XLen / items, p.YLen / items
		local x, y = 0 - p.XLen / 2, 0

		for i = 0, items - 1 do
			local point = { x, y, 0, math.rad( p.Pitch + xRotation ), math.rad( p.Yaw + yRotation ), math.rad( p.Roll + zRotation ) }

			if 0 ~= zRotation then ImmCon.RotatePointOnAxisZ( point, math.rad( zRotation ) ) end
			if 0 ~= xRotation then ImmCon.RotatePointOnAxisX( point, math.rad( xRotation ) ) end
			if 0 ~= yRotation then ImmCon.RotatePointOnAxisY( point, math.rad( yRotation ) ) end
			ImmCon.TranslatePoint( point, originVector )

			points[ #points + 1 ] = point

			x, y = x + xInc, y + yInc
		end

	elseif ImmCon.SHAPE.WALL == p.Shape then

		local xItems, yItems = 0, p.Height
		if 1 > yItems then yItems = 1 end
		xItems = math.floor( items / yItems )

		local xUnits, yUnits = p.XLen / xItems, p.YLen / yItems
		local centerVector = { data.CenterOffsets.X + -1 * p.XLen / 2, 0, 0 }

		for x = 0, xItems - 1 do
			for y = 0, yItems - 1 do
				local point = { x * xUnits, y * yUnits, 0, math.rad( p.Pitch + xRotation ), math.rad( p.Yaw + yRotation ), math.rad( p.Roll + zRotation ) }
				if p.IndentAlternateRows and 1 == y % 2 then point[ 1 ] = point[ 1 ] + xUnits / 2 end

				ImmCon.TranslatePoint( point, centerVector )
				if 0 ~= zRotation then ImmCon.RotatePointOnAxisZ( point, math.rad( zRotation ) ) end
				if 0 ~= xRotation then ImmCon.RotatePointOnAxisX( point, math.rad( xRotation ) ) end
				if 0 ~= yRotation then ImmCon.RotatePointOnAxisY( point, math.rad( yRotation ) ) end
				ImmCon.TranslatePoint( point, originVector )

				points[ #points + 1 ] = point
			end
		end

	end

end


function ImmCon.RenderNext()

	local process = ImmCon.CurrentProcess
	if nil == process or ImmCon.PROCESS.RENDER ~= process.ProcessType then return end

	local items = ImmCon.GetFurniture()
	local p = ImmCon.GetConstParams()
	local q = process.Data

	if nil == p or nil == q or nil == items then
		ImmCon.CompleteProcess( false )
		return
	end

	if q.Index > #items then
		ImmCon.CompleteProcess( true )
		return
	end

	local x, y, z, pitch, yaw, roll = 0, 0, 0, 0, 0, 0
	local indexIncrement = 1

	if q.Index > p.Items then

		-- Hide excess items out of sight at the zone's origin.

	else

		if ImmCon.SHAPE.SPHERE == p.Shape then

			--local invertXZAxis = p.InvertXZAxis or false
			local rows = p.Rows
			if 0 == rows then rows = 1 end
			local width = math.floor( p.Items / rows )
			local xFunc, zFunc = math.cos, math.sin
			--if invertXZAxis then xFunc, zFunc = math.sin, math.cos end

			if ( rows * width ) > q.Iteration then

				local rowIncrement = ( 180 / rows )
				local colIncrement = ( 360 / width )

				local rowDegrees = 90 - ( rowIncrement / 2 ) - rowIncrement * ( q.Iteration % rows )
				local colDegrees = ( colIncrement * math.floor( q.Iteration / rows ) ) % 360
				local direction = 1
				if 0 > rowDegrees then direction = -1 end
				rowDegrees = math.abs( rowDegrees )

				local xLen, zLen = 0, 0
				xLen = p.XRad * math.cos( math.rad( rowDegrees ) ) * xFunc( math.rad( colDegrees ) )
				zLen = p.ZRad * math.cos( math.rad( rowDegrees ) ) * zFunc( math.rad( colDegrees ) )

				x = p.X + xLen
				y = p.Y + p.YRad * math.sin( math.rad( rowDegrees ) ) * direction
				z = p.Z + zLen

				pitch, yaw, roll = math.rad( p.Pitch ), math.rad( p.Yaw ), math.rad( p.Roll )

				if		p.RotationAxis == ImmCon.AXIS.PITCH then	pitch = math.rad( ImmCon.CalculateTangentAngle( xLen, zLen, p.RotationDirection, p.Pitch ) )
				elseif	p.RotationAxis == ImmCon.AXIS.YAW then		yaw = math.rad( ImmCon.CalculateTangentAngle( xLen, zLen, p.RotationDirection, p.Yaw ) )
				elseif	p.RotationAxis == ImmCon.AXIS.ROLL then		roll = math.rad( ImmCon.CalculateTangentAngle( xLen, zLen, p.RotationDirection, p.Roll ) ) end

				if		p.TiltAxis == ImmCon.AXIS.PITCH then		pitch = math.rad( p.Pitch + p.TiltRange * math.sin( math.rad( rowDegrees ) ) * direction )
				elseif	p.TiltAxis == ImmCon.AXIS.YAW then			yaw = math.rad( p.Yaw + p.TiltRange * math.sin( math.rad( rowDegrees ) ) * direction )
				elseif	p.TiltAxis == ImmCon.AXIS.ROLL then			roll = math.rad( p.Roll + p.TiltRange * math.sin( math.rad( rowDegrees ) ) * direction ) end

			end

		else

			local point = q.Points[ q.Index ]
			if nil ~= point then x, y, z, pitch, yaw, roll = ImmCon.PackPoint( point ) end

		end

	end

	local item = items[ q.Index ]
	if nil ~= item and nil ~= item.Id then
		pitch, yaw, roll = ImmCon.GimbalLockAdjustment( pitch, yaw, roll )
		HousingEditorRequestChangePositionAndOrientation( item.Id, x, y, z, pitch, yaw, roll )
	end

	q.Iteration = q.Iteration + 1
	q.Index = q.Index + indexIncrement

	zo_callLater( ImmCon.RenderNext, ImmCon.DELAY.RENDER )

end


function ImmCon.GimbalLockAdjustment( pitch, yaw, roll )

	if 0 == pitch % math.rad( 90 ) and 0 == yaw % math.rad( 90 ) then
		pitch = pitch + math.rad( 0.1 )
	end
	
	return pitch, yaw, roll

end


function ImmCon.CalculateTangentAngle( oppositeLength, adjacentLength, angleConstant, angleOffset )

	if nil == angleConstant then angleConstant = 1 end
	if nil == angleOffset then angleOffset = 0 end

	if 0 == adjacentLength then adjacentLength = 0.001 end
	local angle = math.deg( math.atan( oppositeLength / adjacentLength ) ) + angleOffset
	if 0 <= adjacentLength then angle = angle + 180 end
	angle = ( angle % 360 ) * angleConstant

	return angle

end


-- Methods: User Interface: Construction Dialog


function ImmCon.EnableSaveReset( b )

	if nil == b then b = true end

	if nil ~= ImmCon.ConstGUI then
		ImmCon.ConstGUI.btnSaveExit:SetEnabled( b )
		ImmCon.ConstGUI.btnResetFurniture:SetEnabled( b )
		ImmCon.ConstGUI.btnAutoSize:SetEnabled( b )
	end

end


function ImmCon.ShapeChanged( dropdown )

	if nil == dropdown then return end
	ImmCon.ResetForShape()
	ImmCon.RefreshConstGUI()
	ImmCon.Render()

end


function ImmCon.CenterOnMe()

	local x, y, z, _ = GetPlayerWorldPositionInHouse()
	local p = ImmCon.GetConstParams()

	p.X = x
	p.Y = y
	p.Z = z

	ImmCon.RefreshConstGUI()
	ImmCon.Render()

end


function ImmCon.CenterOnTarget()

	if not HousingEditorCanSelectTargettedFurniture() then
		ImmCon.Error( "Target is not furniture or cannot be selected." )
		return false
	end

	local result = HousingEditorSelectTargettedFurniture()

	if HOUSING_REQUEST_RESULT_SUCCESS ~= result then
		ImmCon.Error( "Target is not furniture or cannot be selected." )
		return false
	end

	local furnitureId = HousingEditorGetSelectedFurnitureId()
	HousingEditorRequestSelectedPlacement()

	local x, y, z = HousingEditorGetFurnitureWorldPosition( furnitureId )

	if nil ~= x and nil ~= y and nil ~= z then
		local p = ImmCon.GetConstParams()
		p.X, p.Y, p.Z = x, y, z

		ImmCon.RefreshConstGUI()
		ImmCon.Render()
	end

end


function ImmCon.SaveExit()

	local items, excessItems = ImmCon.GetFurniture(), { }
	local itemsUsed = ImmCon.GetConstParams().Items or 0

	if itemsUsed < #items then
		for index = itemsUsed + 1, #items do
			table.insert( excessItems, items[ index ] )
		end

		ImmCon.ResetFurniture( excessItems, function() ImmCon.HideConstGUI() ImmCon.ClearFurniture() end )
	else
		ImmCon.HideConstGUI()
		ImmCon.ClearFurniture()
	end

end


function ImmCon.AddControlShapes( validShapes, controls )

	if nil == ImmCon.ConstShapeControls then ImmCon.ConstShapeControls = { } end
	local shapes = nil

	for _, c in pairs( controls ) do
		shapes = ImmCon.ConstShapeControls[ c ]

		if nil == shapes then
			shapes = { }
			ImmCon.ConstShapeControls[ c ] = shapes
		end

		for _, s in pairs( validShapes ) do
			shapes[ s ] = true
		end
	end
	
end


function ImmCon.ConfigureValidShapeControls( shape )

	local isAdvanced = false
	if ZO_CheckButton_IsChecked( ImmCon.ConstGUI.chkAdvancedMode ) then isAdvanced = true end

	if nil == shape or "" == shape then shape = ImmCon.SHAPE.CIRCLE end

	for c, _ in pairs( ImmCon.AdvancedControls ) do
		c:SetHidden( not isAdvanced )
	end
	
	for ctrl, shapes in pairs( ImmCon.ConstShapeControls ) do
		if shapes[ shape ] then
			if isAdvanced or nil == ImmCon.AdvancedControls[ ctrl ] then 
				ctrl:SetHidden( false )
			end
		else
			ctrl:SetHidden( true )
		end
	end	

end


function ImmCon.ResizeToDimensions( x, y, z, useDefaults )

	local p = ImmCon.GetConstParams()
	local shapeDefaults = ImmCon.DEFAULT.CONST_PARAMS[ p.Shape ]

	if not shapeDefaults then return end

	local items = p.Items or 0
	local dimenItems = math.floor( math.sqrt( items ) )

	if 0 < dimenItems then
		if shapeDefaults.Rows then
			if useDefaults then p.Rows = dimenItems end
		end

		if ImmCon.SHAPE.STAIRS == p.Shape then
			if 0 < x and 0 ~= p.XLen then
				p.XLen = items * ( x * 0.8 )
			end

			if 0 < y then
				p.YLen = items * ( y * 0.5 )
			end

			if 0 < z and 0 ~= p.ZLen then
				p.ZLen = items * ( z * 0.8 )
			end
		end

		if shapeDefaults.Height then
			if useDefaults then p.Height = dimenItems end

			if 0 < x and shapeDefaults.XLen then
				p.XLen = math.floor( items / p.Height ) * x
			end

			if 0 < y and shapeDefaults.YLen then
				p.YLen = p.Height * y
			end
		end

		if shapeDefaults.Width then
			if useDefaults then p.Width = dimenItems end

			if 0 < x and shapeDefaults.XLen then
				p.XLen = p.Width * x
			end

			if 0 < z and shapeDefaults.ZLen then
				p.ZLen = math.floor( items / p.Width ) * z
			end
		end
	end

end


function ImmCon.ConfigureShapeDefaultValues()

	local x, y, z = ImmCon.GetMaxFurnitureDimensions()
	ImmCon.ResizeToDimensions( x, y, z, true )

end


function ImmCon.AutoSize()

	local items = ImmCon.GetFurniture()
	local p = ImmCon.GetConstParams()

	if 0 < #items then
		local pitch, yaw, roll = ImmCon.GimbalLockAdjustment( math.rad( p.Pitch ), math.rad( p.Yaw ), math.rad( p.Roll ) )
		HousingEditorRequestChangePositionAndOrientation( items[ 1 ].Id, 5000, 5000, 5000, pitch, yaw, roll )
		ImmCon.EnableSaveReset( false )
		zo_callLater( ImmCon.AutoSizeCallback, 1500 )
	end

end


function ImmCon.AutoSizeCallback()

	ImmCon.EnableSaveReset( true )
	local items = ImmCon.GetFurniture()

	if 0 < #items then
		local item = items[ 1 ]
		ImmCon.MeasureFurniture( item )

		if item.Dimensions then
			ImmCon.ResizeToDimensions( item.Dimensions.X, item.Dimensions.Y, item.Dimensions.Z, false )
			ImmCon.RefreshConstGUI()
			ImmCon.Render()
		end
	end

end


function ImmCon.ResetForShape()

	local shape = ImmCon.ConstGUI.ddShape:GetSelectedItem()
	local p = ImmCon.GetConstParams()
	local x, y, z = p.X, p.Y, p.Z
	local pitch, yaw, roll = p.Pitch, p.Yaw, p.Roll
	local items = p.Items

	if nil == shape or "" == shape or nil == ImmCon.DEFAULT.CONST_PARAMS[ shape ] then shape = ImmCon.SHAPE.CIRCLE end

	p = ImmCon.CloneTable( ImmCon.DEFAULT.CONST_PARAMS[ shape ] )
	p.X, p.Y, p.Z = x, y, z
	p.Pitch, p.Yaw, p.Roll = pitch, yaw, roll
	p.Items = items
	p.Shape = shape
	ImmCon.ConstParams = p

	ImmCon.ConfigureShapeDefaultValues()

end


function ImmCon.RefreshConstGUI()

	local oGUI = ImmCon.ConstGUI
	local p = ImmCon.GetConstParams()

	if nil == oGUI or nil == p then return end

	if nil == p.Shape or "" == p.Shape then p.Shape = ImmCon.SHAPE.CIRCLE end
	oGUI.ddShape:SetSelectedItem( p.Shape )

	local totalItems = ImmCon.GetFurnitureCount()
	if nil == p.Items or 0 >= p.Items then p.Items = totalItems end

	local x, y, z, _ = GetPlayerWorldPositionInHouse()

	oGUI.txtShapeRotation:SetText( tostring( p.ShapeRotation or 0 ) )
	oGUI.txtShapePitch:SetText( tostring( p.ShapePitch or 0 ) )
	oGUI.txtShapeRoll:SetText( tostring( p.ShapeRoll or 0 ) )

	oGUI.txtX:SetText( tostring( p.X or x ) )
	oGUI.txtY:SetText( tostring( p.Y or y ) )
	oGUI.txtZ:SetText( tostring( p.Z or z ) )

	oGUI.txtPitch:SetText( tostring( p.Pitch or 0 ) )
	oGUI.txtYaw:SetText( tostring( p.Yaw or 0 ) )
	oGUI.txtRoll:SetText( tostring( p.Roll or 0 ) )

	oGUI.txtXRad:SetText( tostring( p.XRad or 500 ) )
	oGUI.txtYRad:SetText( tostring( p.YRad or 500 ) )
	oGUI.txtZRad:SetText( tostring( p.ZRad or 500 ) )
	--ZO_CheckButton_SetCheckState( oGUI.chkInvertXZAxis, p.InvertXZAxis )

	oGUI.txtXRadInc:SetText( tostring( p.XRadInc or 500 ) )
	oGUI.txtYInc:SetText( tostring( p.YInc or 500 ) )
	oGUI.txtYRotInc:SetText( tostring( p.YRotInc or 500 ) )
	oGUI.txtZRadInc:SetText( tostring( p.ZRadInc or 500 ) )

	oGUI.txtXLen:SetText( tostring( p.XLen or 500 ) )
	oGUI.txtYLen:SetText( tostring( p.YLen or 500 ) )
	oGUI.txtZLen:SetText( tostring( p.ZLen or 500 ) )

	oGUI.ddRotationAxis:SetSelectedItem( p.RotationAxis )
	if -1 == p.RotationDirection then ZO_CheckButton_SetCheckState( oGUI.chkReverseRotation, true ) else ZO_CheckButton_SetCheckState( oGUI.chkReverseRotation, false ) end

	oGUI.ddTiltAxis:SetSelectedItem( p.TiltAxis )
	oGUI.txtTiltRange:SetText( tostring( p.TiltRange or 80 ) )

	oGUI.txtWidth:SetText( tostring( p.Width or 5 ) )
	oGUI.txtLength:SetText( tostring( p.Length or 5 ) )
	oGUI.txtHeight:SetText( tostring( p.Height or 5 ) )
	ZO_CheckButton_SetCheckState( oGUI.chkIndentAlternateRows, p.IndentAlternateRows )

	oGUI.txtRows:SetText( tostring( p.Rows or 5 ) )
	oGUI.txtArcPercent:SetText( tostring( p.ArcPercent or 0 ) )

	oGUI.txtRotationItems:SetText( tostring( p.RotationItems or 0 ) )

	if nil ~= p.Text then oGUI.txtText:SetText( p.Text ) else oGUI.txtText:SetText( "" ) end

	oGUI.txtItems:SetText( tostring( p.Items or 1 ) )
	oGUI.lblTotalItems:SetText( tostring( totalItems or 0 ) )

	ImmCon.ConfigureValidShapeControls( p.Shape )
	ImmCon.ResizeToFitControls( ImmCon.ConstGUI.window )

end


function ImmCon.ConstGUIChanged()

	local oGUI = ImmCon.ConstGUI
	local p = ImmCon.GetConstParams()

	if p == nil then return end

	local originalShape = p.Shape or ""

	p.Shape = oGUI.ddShape:GetSelectedItem() or ImmCon.SHAPE.CIRCLE
	p.ShapeRotation, p.ShapePitch, p.ShapeRoll = tonumber( oGUI.txtShapeRotation:GetText() ) or 0, tonumber( oGUI.txtShapePitch:GetText() ) or 0, tonumber( oGUI.txtShapeRoll:GetText() ) or 0
	p.X, p.Y, p.Z = tonumber( oGUI.txtX:GetText() ) or 0, tonumber( oGUI.txtY:GetText() ) or 0, tonumber( oGUI.txtZ:GetText() ) or 0
	p.Pitch, p.Yaw, p.Roll = tonumber( oGUI.txtPitch:GetText() ) or 0, tonumber( oGUI.txtYaw:GetText() ) or 0, tonumber( oGUI.txtRoll:GetText() ) or 0
	p.XRad, p.YRad, p.ZRad = tonumber( oGUI.txtXRad:GetText() ) or 0, tonumber( oGUI.txtYRad:GetText() ) or 0, tonumber( oGUI.txtZRad:GetText() ) or 0
	p.YInc, p.YRotInc = tonumber( oGUI.txtYInc:GetText() ) or 0, tonumber( oGUI.txtYRotInc:GetText() ) or 0
	p.XRadInc, p.ZRadInc = tonumber( oGUI.txtXRadInc:GetText() ) or 0, tonumber( oGUI.txtZRadInc:GetText() ) or 0
	--p.InvertXZAxis = ZO_CheckButton_IsChecked( oGUI.chkInvertXZAxis )
	p.XLen, p.YLen, p.ZLen = tonumber( oGUI.txtXLen:GetText() ) or 0, tonumber( oGUI.txtYLen:GetText() ) or 0, tonumber( oGUI.txtZLen:GetText() ) or 0
	p.RotationAxis, p.TiltAxis, p.TiltRange = oGUI.ddRotationAxis:GetSelectedItem() or ImmCon.AXIS.YAW, oGUI.ddTiltAxis:GetSelectedItem() or ImmCon.AXIS.PITCH, tonumber( oGUI.txtTiltRange:GetText() ) or 80
	if ZO_CheckButton_IsChecked( oGUI.chkReverseRotation ) then p.RotationDirection = -1 else p.RotationDirection = 1 end
	p.Width, p.Length, p.Height, p.Rows = tonumber( oGUI.txtWidth:GetText() ) or 0, tonumber( oGUI.txtLength:GetText() ) or 0, tonumber( oGUI.txtHeight:GetText() ) or 0, tonumber( oGUI.txtRows:GetText() ) or 0
	p.IndentAlternateRows = ZO_CheckButton_IsChecked( oGUI.chkIndentAlternateRows )
	p.ArcPercent = tonumber( oGUI.txtArcPercent:GetText() ) or 0
	p.RotationItems = tonumber( oGUI.txtRotationItems:GetText() ) or 1
	p.Text = oGUI.txtText:GetText()
	if nil == p.Text then p.Text = "" end
	p.Items = tonumber( oGUI.txtItems:GetText() ) or 0

	ImmCon.RefreshConstGUI()
	ImmCon.Render()

end


function ImmCon.AdvancedModeChanged()

	ImmCon.RefreshConstGUI()

end


function ImmCon.AddAdvancedControls( ctrls )

	if nil == ImmCon.AdvancedControls then ImmCon.AdvancedControls = { } end

	for k, ctrl in pairs( ctrls ) do
		ImmCon.AdvancedControls[ ctrl ] = true
	end

end


function ImmCon.ShowHideConstGUI()

	local oGUI = ImmCon.ConstGUI

	if nil == oGUI or nil == oGUI.window or oGUI.window:IsHidden() then
		ImmCon.ShowConstGUI()
	else
		oGUI.window:SetHidden( true )
	end

end


function ImmCon.ShowConstGUI()

	local oGUI = ImmCon.ConstGUI

	if nil == oGUI then

		local wndPrefix = "ImmConGui"
		local numberCtrls = { }
		local textCtrls = { }

		oGUI = { }
		ImmCon.ConstGUI = oGUI
		ImmCon.ConstShapeControls = { }


		oGUI.window = WINDOW_MANAGER:CreateTopLevelWindow( wndPrefix .. "Wnd" )	
		oGUI.window:SetDimensions( 100, 100 )
		oGUI.window:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, 50, 50 )
		oGUI.window:SetMovable( true )
		oGUI.window:SetMouseEnabled( true )
		oGUI.window:SetClampedToScreen( true )
		oGUI.window:SetHidden( true )

		oGUI.bdBackdrop = WINDOW_MANAGER:CreateControlFromVirtual( wndPrefix .. "WndBackdrop", oGUI.window, "ZO_DefaultBackdrop" )
		oGUI.bdBackdrop:SetAnchor( TOPLEFT, oGUI.window, TOPLEFT, 4, 4 )
		oGUI.bdBackdrop:SetAnchor( BOTTOMRIGHT, oGUI.window, BOTTOMRIGHT, -4, -4 )
		oGUI.bdBackdrop:SetAlpha( 0.75 )


		oGUI.btnCenterOnMe = ImmCon.AddButton( false, wndPrefix .. "CenterOnMe", "Center On Me", oGUI.window, oGUI.window, TOPLEFT, ImmCon.DEFAULT.FIELD_MARGIN_LEFT, ImmCon.DEFAULT.FIELD_DIVIDER_TOP, ImmCon.DEFAULT.BUTTON_WIDTH + 20 )
		oGUI.btnCenterOnMe:SetHandler( "OnClicked", ImmCon.CenterOnMe )

		oGUI.btnSaveExit = ImmCon.AddButton( false, wndPrefix .. "SaveExit", "Save & Exit", oGUI.window, oGUI.btnCenterOnMe, TOPRIGHT, ImmCon.DEFAULT.FIELD_MARGIN_LEFT, 0 )
		oGUI.btnSaveExit:SetHandler( "OnClicked", ImmCon.SaveExit )

		oGUI.btnResetFurniture = ImmCon.AddButton( false, wndPrefix .. "ResetFurniture", "Undo & Exit", oGUI.window )
		oGUI.btnResetFurniture:SetAnchor( TOPRIGHT, oGUI.window, TOPRIGHT, ImmCon.DEFAULT.FIELD_MARGIN_LEFT, ImmCon.DEFAULT.FIELD_DIVIDER_TOP )
		oGUI.btnResetFurniture:SetHandler( "OnClicked", function() ImmCon.ResetFurniture( nil, function() oGUI.window:SetHidden( true ) end, nil ) end )


		oGUI.chkAdvancedMode = ImmCon.AddCheckButton( wndPrefix .. "AdvancedMode", "Advanced Mode", oGUI.window )
		oGUI.chkAdvancedMode:SetAnchor( BOTTOMRIGHT, oGUI.window, BOTTOMRIGHT, -145, -18 )
		oGUI.window.Controls[ #oGUI.window.Controls ] = nil
		ZO_CheckButton_SetToggleFunction( oGUI.chkAdvancedMode, ImmCon.AdvancedModeChanged )


		oGUI.lblShapeAndItems = ImmCon.AddHeading( wndPrefix .. "ShapeAndItems", "Shape & Items", oGUI.window, oGUI.window, TOPLEFT, ImmCon.DEFAULT.WINDOW_MARGIN_X, ImmCon.DEFAULT.WINDOW_MARGIN_Y )

		oGUI.ddShape, oGUI.lblShape = ImmCon.AddDropdown( wndPrefix .. "Shape", "Shape:", oGUI.window, oGUI.lblShapeAndItems )
		ImmCon.SetupDropdown( oGUI.ddShape, ImmCon.SHAPE, ImmCon.ShapeChanged )

		oGUI.lblTotalItems, oGUI.lblTotalItemsLabel = ImmCon.AddLabelField( wndPrefix .. "TotalItems", "# of Available Items:", oGUI.window, oGUI.lblShape )

		oGUI.txtItems, oGUI.lblItems = ImmCon.AddField( wndPrefix .. "Items", "# of Items to Use:", oGUI.window, oGUI.lblTotalItemsLabel )
		numberCtrls[#numberCtrls + 1] = oGUI.txtItems


		oGUI.lblShapeOrientation = ImmCon.AddHeading( wndPrefix .. "ShapeOrientation", "Shape Orientation", oGUI.window, oGUI.lblShapeAndItems, TOPRIGHT, ImmCon.DEFAULT.FIELD_DIVIDER_LEFT, 0 )
		
		oGUI.txtShapeRotation, oGUI.lblShapeRotation, oGUI.bkdShapeRotation = ImmCon.AddField( wndPrefix .. "ShapeRotation", "Rotate Shape [deg]", oGUI.window, oGUI.lblShapeOrientation )
		numberCtrls[#numberCtrls + 1] = oGUI.txtShapeRotation

		oGUI.txtShapePitch, oGUI.lblShapePitch, oGUI.bkdShapePitch = ImmCon.AddField( wndPrefix .. "ShapePitch", "Pitch Shape [deg]", oGUI.window, oGUI.lblShapeRotation )
		numberCtrls[#numberCtrls + 1] = oGUI.txtShapePitch

		oGUI.txtShapeRoll, oGUI.lblShapeRoll, oGUI.bkdShapeRoll = ImmCon.AddField( wndPrefix .. "ShapeRoll", "Roll Shape [deg]", oGUI.window, oGUI.lblShapePitch )
		numberCtrls[#numberCtrls + 1] = oGUI.txtShapeRoll


		oGUI.lblPosition = ImmCon.AddHeading( wndPrefix .. "Position", "Position & Dimensions", oGUI.window, oGUI.lblItems, nil, nil, ImmCon.DEFAULT.FIELD_DIVIDER_TOP )

		oGUI.txtX, oGUI.lblX = ImmCon.AddField( wndPrefix .. "X", "X [cm] (west to east)", oGUI.window, oGUI.lblPosition )
		numberCtrls[#numberCtrls + 1] = oGUI.txtX
		
		oGUI.txtY, oGUI.lblY = ImmCon.AddField( wndPrefix .. "Y", "Y [cm] (floor to ceiling)", oGUI.window, oGUI.lblX )
		numberCtrls[#numberCtrls + 1] = oGUI.txtY
		
		oGUI.txtZ, oGUI.lblZ = ImmCon.AddField( wndPrefix .. "Z", "Z [cm] (north to south)", oGUI.window, oGUI.lblY )
		numberCtrls[#numberCtrls + 1] = oGUI.txtZ

		
		oGUI.lblOrientation = ImmCon.AddHeading( wndPrefix .. "Orientation", "Item Orientation", oGUI.window, oGUI.lblPosition, TOPRIGHT, ImmCon.DEFAULT.FIELD_DIVIDER_LEFT, 0 )

		oGUI.txtYaw, oGUI.lblYaw = ImmCon.AddField( wndPrefix .. "Yaw", "Rotation [deg]", oGUI.window, oGUI.lblOrientation )
		numberCtrls[#numberCtrls + 1] = oGUI.txtYaw

		oGUI.txtPitch, oGUI.lblPitch = ImmCon.AddField( wndPrefix .. "Pitch", "Pitch [deg]", oGUI.window, oGUI.lblYaw )
		numberCtrls[#numberCtrls + 1] = oGUI.txtPitch
		
		oGUI.txtRoll, oGUI.lblRoll = ImmCon.AddField( wndPrefix .. "Roll", "Roll [deg]", oGUI.window, oGUI.lblPitch)
		numberCtrls[#numberCtrls + 1] = oGUI.txtRoll


		oGUI.txtXRad, oGUI.lblXRad, oGUI.bkdXRad = ImmCon.AddField( wndPrefix .. "XRad", "Radius X [cm]", oGUI.window, oGUI.lblZ, nil, nil, ImmCon.DEFAULT.FIELD_DIVIDER_TOP )
		numberCtrls[#numberCtrls + 1] = oGUI.txtXRad
		
		oGUI.txtZRad, oGUI.lblZRad, oGUI.bkdZRad = ImmCon.AddField( wndPrefix .. "ZRad", "Radius Z [cm]", oGUI.window, oGUI.lblXRad )
		numberCtrls[#numberCtrls + 1] = oGUI.txtZRad

		oGUI.txtYRad, oGUI.lblYRad, oGUI.bkdYRad = ImmCon.AddField( wndPrefix .. "YRad", "Radius Y [cm]", oGUI.window, oGUI.lblZRad )
		numberCtrls[#numberCtrls + 1] = oGUI.txtYRad

		oGUI.txtYInc, oGUI.lblYInc, oGUI.bkdYInc = ImmCon.AddField( wndPrefix .. "YInc", "Y Increment/Item", oGUI.window, oGUI.lblZRad )
		numberCtrls[#numberCtrls + 1] = oGUI.txtYInc

		oGUI.txtYRotInc, oGUI.lblYRotInc, oGUI.bkdYRotInc = ImmCon.AddField( wndPrefix .. "YRotInc", "Y Increment/Rotation", oGUI.window, oGUI.lblZRad )
		numberCtrls[#numberCtrls + 1] = oGUI.txtYRotInc

		--oGUI.chkInvertXZAxis = ImmCon.AddCheckButton( wndPrefix .. "InvertXZAxis", "Invert X / Z Axis", oGUI.window, oGUI.lblZRad )
		--ZO_CheckButton_SetToggleFunction( oGUI.chkInvertXZAxis, ImmCon.ConstGUIChanged )


		oGUI.txtText, oGUI.lblText, oGUI.bkdText = ImmCon.AddField( wndPrefix .. "Text", "Text (use ~ for new lines)", oGUI.window, oGUI.lblZ, nil, nil, ImmCon.DEFAULT.FIELD_DIVIDER_TOP )
		oGUI.lblText:SetWidth( 480 )
		oGUI.bkdText:ClearAnchors()
		oGUI.bkdText:SetAnchor( TOPLEFT, oGUI.lblText, BOTTOMLEFT, 0, ImmCon.DEFAULT.FIELD_MARGIN_TOP )
		--oGUI.bkdText:SetDimensions( 480, ImmCon.DEFAULT.TEXTBOX_HEIGHT * 2 )
		oGUI.bkdText:SetWidth( 480 )
		oGUI.txtText:ClearAnchors()
		oGUI.txtText:SetAnchor( TOPLEFT, oGUI.bkdText, TOPLEFT, 1, 1 )
		oGUI.txtText:SetAnchor( BOTTOMRIGHT, oGUI.bkdText, BOTTOMRIGHT, -1, -1 )
		--oGUI.txtText:SetMultiLine( true )
		--oGUI.txtText:SetNewLineEnabled( true )
		textCtrls[#textCtrls + 1] = oGUI.txtText


		oGUI.txtXLen, oGUI.lblXLen, oGUI.bkdXLen = ImmCon.AddField( wndPrefix .. "XLen", "Length X [cm]", oGUI.window, oGUI.lblZ, nil, nil, ImmCon.DEFAULT.FIELD_DIVIDER_TOP )
		numberCtrls[#numberCtrls + 1] = oGUI.txtXLen
		
		oGUI.txtYLen, oGUI.lblYLen, oGUI.bkdYLen = ImmCon.AddField( wndPrefix .. "YLen", "Length Y [cm]", oGUI.window, oGUI.lblXLen )
		numberCtrls[#numberCtrls + 1] = oGUI.txtYLen
		
		oGUI.txtZLen, oGUI.lblZLen, oGUI.bkdZLen = ImmCon.AddField( wndPrefix .. "ZLen", "Length Z [cm]", oGUI.window, oGUI.lblYLen )
		numberCtrls[#numberCtrls + 1] = oGUI.txtZLen

		oGUI.btnAutoSize = ImmCon.AddButton( true, wndPrefix .. "AutoSize", "Auto-Size", oGUI.window, oGUI.lblZLen )
		oGUI.btnAutoSize:SetHandler( "OnClicked", ImmCon.AutoSize )


		oGUI.ddRotationAxis, oGUI.lblRotationAxis = ImmCon.AddDropdown( wndPrefix .. "RotationAxis", "Rotation Axis", oGUI.window, oGUI.lblRoll, nil, nil, ImmCon.DEFAULT.FIELD_DIVIDER_TOP )
		ImmCon.SetupDropdown( oGUI.ddRotationAxis, ImmCon.AXIS, ImmCon.ConstGUIChanged )
		oGUI.ddRotationAxis:SetSortsItems( false )

		oGUI.chkReverseRotation = ImmCon.AddCheckButton( wndPrefix .. "ReverseRotation", "Reverse Rotation", oGUI.window, oGUI.lblRotationAxis )
		ZO_CheckButton_SetToggleFunction( oGUI.chkReverseRotation, ImmCon.ConstGUIChanged )

		oGUI.ddTiltAxis, oGUI.lblTiltAxis = ImmCon.AddDropdown( wndPrefix .. "TiltAxis", "Tilt Axis", oGUI.window, oGUI.chkReverseRotation )
		ImmCon.SetupDropdown( oGUI.ddTiltAxis, ImmCon.AXIS, ImmCon.ConstGUIChanged )
		oGUI.ddTiltAxis:SetSortsItems( false )

		oGUI.txtTiltRange, oGUI.lblTiltRange, oGUI.bkdTiltRange = ImmCon.AddField( wndPrefix .. "TiltRange", "Tilt Range [deg] (0-90)", oGUI.window, oGUI.lblTiltAxis )
		numberCtrls[#numberCtrls + 1] = oGUI.txtTiltRange


		oGUI.txtRows, oGUI.lblRows, oGUI.bkdRows = ImmCon.AddField( wndPrefix .. "Rows", "# of Rows [items]", oGUI.window, oGUI.lblTiltRange )
		numberCtrls[#numberCtrls + 1] = oGUI.txtRows


		oGUI.txtWidth, oGUI.lblWidth, oGUI.bkdWidth = ImmCon.AddField( wndPrefix .. "Width", "Width [items]", oGUI.window, oGUI.lblRoll, nil, nil, ImmCon.DEFAULT.FIELD_DIVIDER_TOP ) --, oGUI.chkReverseRotation )
		numberCtrls[#numberCtrls + 1] = oGUI.txtWidth
		
		oGUI.txtLength, oGUI.lblLength, oGUI.bkdLength = ImmCon.AddField( wndPrefix .. "Length", "Length [items]", oGUI.window, oGUI.lblWidth ) --, oGUI.chkReverseRotation )
		numberCtrls[#numberCtrls + 1] = oGUI.txtLength
		
		oGUI.txtHeight, oGUI.lblHeight, oGUI.bkdHeight = ImmCon.AddField( wndPrefix .. "Height", "Height [items]", oGUI.window, oGUI.lblWidth ) --, oGUI.chkReverseRotation )
		numberCtrls[#numberCtrls + 1] = oGUI.txtHeight

		oGUI.chkIndentAlternateRows = ImmCon.AddCheckButton( wndPrefix .. "IndentAlternateRows", "Indent Alternate Rows", oGUI.window, oGUI.lblHeight )
		ZO_CheckButton_SetToggleFunction( oGUI.chkIndentAlternateRows, ImmCon.ConstGUIChanged )


		oGUI.txtArcPercent, oGUI.lblArcPercent, oGUI.bkdArcPercent = ImmCon.AddField( wndPrefix .. "ArcPercent", "% of Circle (0-100)", oGUI.window, oGUI.chkReverseRotation )
		numberCtrls[#numberCtrls + 1] = oGUI.txtArcPercent

		oGUI.txtRotationItems, oGUI.lblRotationItems, oGUI.bkdRotationItems = ImmCon.AddField( wndPrefix .. "RotationItems", "# of Items/Rotation", oGUI.window, oGUI.chkReverseRotation )
		numberCtrls[#numberCtrls + 1] = oGUI.txtRotationItems


		oGUI.txtXRadInc, oGUI.lblXRadInc, oGUI.bkdXRadInc = ImmCon.AddField( wndPrefix .. "XRadInc", "Rad-X Increment/Item", oGUI.window, oGUI.lblYRad, nil, nil, ImmCon.DEFAULT.FIELD_DIVIDER_TOP )
		numberCtrls[#numberCtrls + 1] = oGUI.txtXRadInc
		
		oGUI.txtZRadInc, oGUI.lblZRadInc, oGUI.bkdZRadInc = ImmCon.AddField( wndPrefix .. "ZRadInc", "Rad-Z Increment/Item", oGUI.window, oGUI.lblXRadInc )
		numberCtrls[#numberCtrls + 1] = oGUI.txtZRadInc


		ImmCon.AddControlShapes(
			{	ImmCon.SHAPE.ARC },
			{	oGUI.lblXRad, oGUI.txtXRad, oGUI.bkdXRad,
				oGUI.lblZRad, oGUI.txtZRad, oGUI.bkdZRad,
				oGUI.ddRotationAxis.Container, oGUI.lblRotationAxis,
				oGUI.chkReverseRotation,
				oGUI.lblArcPercent, oGUI.txtArcPercent, oGUI.bkdArcPercent } )

		ImmCon.AddControlShapes(
			{	ImmCon.SHAPE.BOX },
			{	oGUI.lblXLen, oGUI.txtXLen, oGUI.bkdXLen,
				oGUI.lblYLen, oGUI.txtYLen, oGUI.bkdYLen,
				oGUI.lblZLen, oGUI.txtZLen, oGUI.bkdZLen,
				oGUI.lblWidth, oGUI.txtWidth, oGUI.bkdWidth,
				oGUI.lblLength, oGUI.txtLength, oGUI.bkdLength,
				oGUI.btnAutoSize } )

		ImmCon.AddControlShapes(
			{	ImmCon.SHAPE.BRIDGE },
			{	oGUI.lblXLen, oGUI.txtXLen, oGUI.bkdXLen,
				oGUI.lblYLen, oGUI.txtYLen, oGUI.bkdYLen,
				oGUI.ddRotationAxis.Container, oGUI.lblRotationAxis,
				oGUI.chkReverseRotation,
				oGUI.ddTiltAxis.Container, oGUI.lblTiltAxis,
				oGUI.txtTiltRange, oGUI.lblTiltRange, oGUI.bkdTiltRange } )

		ImmCon.AddControlShapes(
			{	ImmCon.SHAPE.CYLINDER },
			{	oGUI.lblXRad, oGUI.txtXRad, oGUI.bkdXRad,
				oGUI.lblZRad, oGUI.txtZRad, oGUI.bkdZRad,
				oGUI.lblYRotInc, oGUI.txtYRotInc, oGUI.bkdYRotInc,
				oGUI.ddRotationAxis.Container, oGUI.lblRotationAxis,
				oGUI.chkReverseRotation,
				oGUI.lblRotationItems, oGUI.txtRotationItems, oGUI.bkdRotationItems } )

		ImmCon.AddControlShapes(
			{	ImmCon.SHAPE.SPIRAL },
			{	oGUI.lblXRad, oGUI.txtXRad, oGUI.bkdXRad,
				oGUI.lblZRad, oGUI.txtZRad, oGUI.bkdZRad,
				oGUI.lblYInc, oGUI.txtYInc, oGUI.bkdYInc,
				oGUI.lblXRadInc, oGUI.txtXRadInc, oGUI.bkdXRadInc,
				oGUI.lblZRadInc, oGUI.txtZRadInc, oGUI.bkdZRadInc,
				oGUI.ddRotationAxis.Container, oGUI.lblRotationAxis,
				oGUI.chkReverseRotation,
				oGUI.lblRotationItems, oGUI.txtRotationItems, oGUI.bkdRotationItems } )

		ImmCon.AddControlShapes(
			{	ImmCon.SHAPE.CIRCLE },
			{	oGUI.lblXRad, oGUI.txtXRad, oGUI.bkdXRad,
				oGUI.lblZRad, oGUI.txtZRad, oGUI.bkdZRad,
				oGUI.ddRotationAxis.Container, oGUI.lblRotationAxis,
				oGUI.chkReverseRotation } )

		ImmCon.AddControlShapes(
			{	ImmCon.SHAPE.SPHERE },
			{	oGUI.lblXRad, oGUI.txtXRad, oGUI.bkdXRad,
				oGUI.lblYRad, oGUI.txtYRad, oGUI.bkdYRad,
				oGUI.lblZRad, oGUI.txtZRad, oGUI.bkdZRad,
				oGUI.ddRotationAxis.Container, oGUI.lblRotationAxis,
				oGUI.chkReverseRotation,
				oGUI.ddTiltAxis.Container, oGUI.lblTiltAxis,
				oGUI.txtTiltRange, oGUI.lblTiltRange, oGUI.bkdTiltRange,
				oGUI.lblRows, oGUI.txtRows, oGUI.bkdRows } )

		ImmCon.AddControlShapes(
			{	ImmCon.SHAPE.DOME },
			{	oGUI.lblXRad, oGUI.txtXRad, oGUI.bkdXRad,
				oGUI.lblYRad, oGUI.txtYRad, oGUI.bkdYRad,
				oGUI.lblZRad, oGUI.txtZRad, oGUI.bkdZRad,
				oGUI.ddRotationAxis.Container, oGUI.lblRotationAxis,
				oGUI.chkReverseRotation,
				oGUI.ddTiltAxis.Container, oGUI.lblTiltAxis,
				oGUI.txtTiltRange, oGUI.lblTiltRange, oGUI.bkdTiltRange,
				oGUI.lblRows, oGUI.txtRows, oGUI.bkdRows } )

		ImmCon.AddControlShapes(
			{	ImmCon.SHAPE.STAIRS },
			{	oGUI.lblXLen, oGUI.txtXLen, oGUI.bkdXLen,
				oGUI.lblYLen, oGUI.txtYLen, oGUI.bkdYLen,
				oGUI.btnAutoSize } )

		ImmCon.AddControlShapes(
			{	ImmCon.SHAPE.FLOOR },
			{	oGUI.lblXLen, oGUI.txtXLen, oGUI.bkdXLen,
				oGUI.lblZLen, oGUI.txtZLen, oGUI.bkdZLen,
				oGUI.lblWidth, oGUI.txtWidth, oGUI.bkdWidth,
				oGUI.chkIndentAlternateRows,
				oGUI.btnAutoSize } )

		ImmCon.AddControlShapes(
			{	ImmCon.SHAPE.PYRAMID },
			{	oGUI.lblXLen, oGUI.txtXLen, oGUI.bkdXLen,
				oGUI.lblYLen, oGUI.txtYLen, oGUI.bkdYLen,
				oGUI.lblZLen, oGUI.txtZLen, oGUI.bkdZLen,
				oGUI.btnAutoSize,
				oGUI.lblHeight, oGUI.txtHeight, oGUI.bkdHeight,
				oGUI.lblRotationItems, oGUI.txtRotationItems, oGUI.bkdRotationItems } )

		ImmCon.AddControlShapes(
			{	ImmCon.SHAPE.WALL },
			{	oGUI.lblXLen, oGUI.txtXLen, oGUI.bkdXLen,
				oGUI.lblYLen, oGUI.txtYLen, oGUI.bkdYLen,
				oGUI.lblHeight, oGUI.txtHeight, oGUI.bkdHeight,
				oGUI.chkIndentAlternateRows,
				oGUI.btnAutoSize } )

		ImmCon.AddControlShapes(
			{	ImmCon.SHAPE.TEXT },
			{	oGUI.lblText, oGUI.txtText, oGUI.bkdText } )

		ImmCon.AddAdvancedControls( {
			oGUI.lblShapePitch,
			oGUI.txtShapePitch,
			oGUI.bkdShapePitch,
			oGUI.lblShapeRoll,
			oGUI.txtShapeRoll,
			oGUI.bkdShapeRoll,
			oGUI.lblRotationAxis,
			oGUI.ddRotationAxis.Container,
			oGUI.chkReverseRotation,
			oGUI.lblTiltAxis,
			oGUI.ddTiltAxis.Container,
			oGUI.lblTiltRange,
			oGUI.txtTiltRange,
			oGUI.bkdTiltRange } )

		for i = 1, #numberCtrls do
			numberCtrls[i]:SetHandler( "OnFocusLost", ImmCon.NumberFieldChanged )
		end

		for i = 1, #textCtrls do
			textCtrls[i]:SetHandler( "OnFocusLost", ImmCon.TextFieldChanged )
		end

	end


	oGUI.window:SetHidden( false )
	ImmCon.RefreshConstGUI()

end


function ImmCon.HideConstGUI()

	if nil ~= ImmCon.ConstGUI and nil ~= ImmCon.ConstGUI.window then
		ImmCon.ConstGUI.window:SetHidden( true )
	end

end


-- Methods: User Interface


function ImmCon.AddHeading( name, text, parentWindow, anchorControl, anchorPosition, leftOffset, topOffset, width, height )

	if nil == parentWindow.Controls then parentWindow.Controls = { } end
	if nil == anchorPosition then anchorPosition = BOTTOMLEFT end
	if nil == leftOffset then leftOffset = ImmCon.DEFAULT.FIELD_MARGIN_LEFT end
	if nil == topOffset then topOffset = ImmCon.DEFAULT.FIELD_MARGIN_TOP end
	if nil == width then width = ImmCon.DEFAULT.HEADING_WIDTH end
	if nil == height then height = ImmCon.DEFAULT.HEADING_HEIGHT end

	local lblLabel = WINDOW_MANAGER:CreateControl( name .. "Label", parentWindow, CT_LABEL )
	lblLabel:SetColor( 1, 1, 0.5, 1 )
	lblLabel:SetFont( "ZoFontGameLargeBold" )
	lblLabel:SetText( text )
	lblLabel:SetAnchor( TOPLEFT, anchorControl, anchorPosition, leftOffset, topOffset )
	lblLabel:SetDimensions( width, height )

	parentWindow.Controls[ #parentWindow.Controls + 1 ] = lblLabel

	return lblLabel

end


function ImmCon.AddLine( name, parentWindow, color, thickness, anchorPoint1, anchorControl1, anchorPosition1, anchorOffsetX1, anchorOffsetY1, anchorPoint2, anchorControl2, anchorPosition2, anchorOffsetX2, anchorOffsetY2)

	if nil == parentWindow.Controls then parentWindow.Controls = { } end
	if nil == color then color = { 1, 1, 1, 0.9 } end
	if nil == thickness then thickness = 1 end

	local cLine = WINDOW_MANAGER:CreateControl( name .. "Line", parentWindow, CT_LINE )
	cLine:SetColor( unpack( color ) )
	cLine:SetThickness( thickness )
	cLine:SetAnchor( anchorPoint1, anchorControl1, anchorPosition1, anchorOffsetX1, anchorOffsetY1 )
	cLine:SetAnchor( anchorPoint2, anchorControl2, anchorPosition2, anchorOffsetX2, anchorOffsetY2 )

	parentWindow.Controls[ #parentWindow.Controls + 1 ] = cLine

	return cLine

end


function ImmCon.AddField( name, fieldTitle, parentWindow, anchorControl, anchorPosition, leftOffset, topOffset )

	if nil == parentWindow.Controls then parentWindow.Controls = { } end
	if nil == anchorPosition then anchorPosition = BOTTOMLEFT end
	if nil == leftOffset then leftOffset = ImmCon.DEFAULT.FIELD_MARGIN_LEFT end
	if nil == topOffset then topOffset = ImmCon.DEFAULT.FIELD_MARGIN_TOP end

	local lblTitle = WINDOW_MANAGER:CreateControl( name .. "Title", parentWindow, CT_LABEL )
	lblTitle:SetColor( 1, 1, 1, 1 )
	lblTitle:SetFont( "ZoFontGameLarge" )
	lblTitle:SetText( fieldTitle )
	lblTitle:SetAnchor( TOPLEFT, anchorControl, anchorPosition, leftOffset, topOffset )
	lblTitle:SetDimensions( ImmCon.DEFAULT.LABEL_WIDTH, ImmCon.DEFAULT.LABEL_HEIGHT )

	parentWindow.Controls[ #parentWindow.Controls + 1 ] = lblTitle

	local newBackdrop = WINDOW_MANAGER:CreateControlFromVirtual( name .. "Backdrop", parentWindow, "ZO_SingleLineEditBackdrop_Keyboard" )
	newBackdrop:SetAnchor( TOPLEFT, lblTitle, TOPRIGHT, 10, 0 )
	newBackdrop:SetDimensions( ImmCon.DEFAULT.TEXTBOX_WIDTH, ImmCon.DEFAULT.TEXTBOX_HEIGHT )

	parentWindow.Controls[ #parentWindow.Controls + 1 ] = newBackdrop

	local newTextField = WINDOW_MANAGER:CreateControlFromVirtual( name .. "Text", parentWindow, "ZO_DefaultEditForBackdrop" ) 
	newTextField:SetAnchor( TOPLEFT, newBackdrop, TOPLEFT, 1, 0 )
	newTextField:SetAnchor( BOTTOMRIGHT, newBackdrop, BOTTOMRIGHT, 1, 0 )
	newTextField:SetFont( "ZoFontGameLarge" )

	return newTextField, lblTitle, newBackdrop

end


function ImmCon.AddLabelField( name, fieldTitle, parentWindow, anchorControl, anchorPosition, leftOffset, topOffset )

	if nil == parentWindow.Controls then parentWindow.Controls = { } end
	if nil == anchorPosition then anchorPosition = BOTTOMLEFT end
	if nil == leftOffset then leftOffset = ImmCon.DEFAULT.FIELD_MARGIN_LEFT end
	if nil == topOffset then topOffset = ImmCon.DEFAULT.FIELD_MARGIN_TOP end

	local lblTitle = WINDOW_MANAGER:CreateControl( name .. "Title", parentWindow, CT_LABEL )
	lblTitle:SetColor( 1, 1, 1, 1 )
	lblTitle:SetFont( "ZoFontGameLarge" )
	lblTitle:SetText( fieldTitle )
	lblTitle:SetAnchor( TOPLEFT, anchorControl, anchorPosition, leftOffset, topOffset )
	lblTitle:SetDimensions( ImmCon.DEFAULT.LABEL_WIDTH, ImmCon.DEFAULT.LABEL_HEIGHT )

	parentWindow.Controls[ #parentWindow.Controls + 1 ] = lblTitle

	local lblLabel = WINDOW_MANAGER:CreateControl( name .. "DataLabel", parentWindow, CT_LABEL )
	lblLabel:SetColor( 1, 1, 1, 1 )
	lblLabel:SetFont( "ZoFontGameLarge" )
	lblLabel:SetText( "" )
	lblLabel:SetAnchor( TOPLEFT, lblTitle, TOPRIGHT, 12, 0 )
	lblLabel:SetDimensions( ImmCon.DEFAULT.TEXTBOX_WIDTH, ImmCon.DEFAULT.TEXTBOX_HEIGHT )

	parentWindow.Controls[ #parentWindow.Controls + 1 ] = lblLabel

	return lblLabel, lblTitle

end


function ImmCon.AddDropdown( name, fieldTitle, parentWindow, anchorControl, anchorPosition, leftOffset, topOffset, width, height )

	if nil == parentWindow.Controls then parentWindow.Controls = { } end
	if nil == anchorPosition then anchorPosition = BOTTOMLEFT end
	if nil == leftOffset then leftOffset = ImmCon.DEFAULT.FIELD_MARGIN_LEFT end
	if nil == topOffset then topOffset = ImmCon.DEFAULT.FIELD_MARGIN_TOP end
	if nil == width then width = ImmCon.DEFAULT.DROPDOWN_WIDTH end
	if nil == height then height = ImmCon.DEFAULT.DROPDOWN_HEIGHT end

	local lblTitle = WINDOW_MANAGER:CreateControl( name .. "Title", parentWindow, CT_LABEL )
	lblTitle:SetColor( 1, 1, 1, 1 )
	lblTitle:SetFont( "ZoFontGameLarge" )
	lblTitle:SetText( fieldTitle )
	lblTitle:SetAnchor( TOPLEFT, anchorControl, anchorPosition, leftOffset, topOffset )
	lblTitle:SetDimensions( ImmCon.DEFAULT.LABEL_WIDTH - 50, ImmCon.DEFAULT.LABEL_HEIGHT )

	parentWindow.Controls[ #parentWindow.Controls + 1 ] = lblTitle

	local ddList = WINDOW_MANAGER:CreateControlFromVirtual( name .. "DDList", parentWindow, "ZO_ComboBox" )
	local ddListContainer = ddList
	ddList:SetAnchor( TOPLEFT, lblTitle, TOPRIGHT, 10, 0 )
	ddList:SetDimensions( width, height )
	ddList = ZO_ComboBox_ObjectFromContainer( ddList )
	ddList.Container = ddListContainer
	ddList:SetSortsItems( true )

	return ddList, lblTitle

end


function ImmCon.AddCheckButton( name, fieldTitle, parentWindow, anchorControl, anchorPosition, leftOffset, topOffset )

	if nil == parentWindow.Controls then parentWindow.Controls = { } end
	if nil == anchorPosition then anchorPosition = BOTTOMLEFT end
	if nil == leftOffset then leftOffset = ImmCon.DEFAULT.FIELD_MARGIN_LEFT end
	if nil == topOffset then topOffset = ImmCon.DEFAULT.FIELD_MARGIN_TOP end

	local checkButton = WINDOW_MANAGER:CreateControlFromVirtual( name .. "CheckButton", parentWindow, "ZO_CheckButton" )
	if nil ~= anchorControl then
		checkButton:SetAnchor( TOPLEFT, anchorControl, anchorPosition, leftOffset, topOffset )
	end
	ZO_CheckButton_SetLabelText( checkButton, fieldTitle )

	parentWindow.Controls[ #parentWindow.Controls + 1 ] = checkButton

	return checkButton

end


function ImmCon.AddButton( addToControls, name, buttonTitle, parentWindow, anchorControl, anchorPosition, leftOffset, topOffset, buttonWidth, buttonHeight, buttonVirtual )

	if nil == parentWindow.Controls then parentWindow.Controls = { } end
	if nil == anchorPosition then anchorPosition = BOTTOMLEFT end
	if nil == leftOffset then leftOffset = ImmCon.DEFAULT.FIELD_MARGIN_LEFT end
	if nil == topOffset then topOffset = ImmCon.DEFAULT.FIELD_MARGIN_TOP end
	if nil == buttonWidth then buttonWidth = ImmCon.DEFAULT.BUTTON_WIDTH end
	if nil == buttonHeight then buttonHeight = ImmCon.DEFAULT.BUTTON_HEIGHT end
	if nil == buttonVirtual then buttonVirtual = "ZO_DefaultButton" end

	local btn = WINDOW_MANAGER:CreateControlFromVirtual( name .. "Button", parentWindow, buttonVirtual )
	if nil ~= anchorControl then
		btn:SetAnchor( TOPLEFT, anchorControl, anchorPosition, leftOffset, topOffset )
	end
	btn:SetWidth( buttonWidth )
	btn:SetHeight( buttonHeight )
	btn:SetText( buttonTitle )

	if addToControls then parentWindow.Controls[ #parentWindow.Controls + 1 ] = btn end

	return btn

end


function ImmCon.SetupDropdown( ddList, options, selectedHandler, defaultToFirst )

	if nil == defaultToFirst then defaultToFirst = false end

	if nil ~= ddList then
		local isFirst = true

		ddList:ClearItems()

		for _, o in pairs( options ) do
			ddList:AddItem( ddList:CreateItemEntry( o, selectedHandler ) )

			if isFirst then
				if defaultToFirst then ddList:SetSelectedItem( o ) end
				isFirst = false
			end
		end
	end

end


function ImmCon.ResizeToFitControls( window )

	if nil == window or nil == window.Controls then return end

	local winLeft, winTop, winRight, winBottom = window:GetLeft(), window:GetTop(), window:GetRight(), window:GetBottom()
	if nil == winLeft or nil == winTop or nil == winRight or nil == winBottom then return end

	local minLeft, minTop, maxRight, maxBottom = nil, nil, nil, nil
	local cLeft, cTop, cRight, cBottom

	for _, c in ipairs( window.Controls ) do

		if not c:IsHidden() then
			cLeft, cTop, cRight, cBottom = c:GetLeft(), c:GetTop(), c:GetRight(), c:GetBottom()

			if nil ~= cLeft and nil ~= cTop and nil ~= cRight and nil ~= cBottom then
				if nil == minLeft or cLeft < minLeft then minLeft = cLeft end
				if nil == maxRight or cRight > maxRight then maxRight = cRight end
				if nil == minTop or cTop < minTop then minTop = cTop end
				if nil == maxBottom or cBottom > maxBottom then maxBottom = cBottom end
			end
		end

	end

	if nil ~= minLeft and nil ~= minTop and nil ~= maxRight and nil ~= maxBottom then

		window:SetDimensions( maxRight - winLeft + ImmCon.DEFAULT.WINDOW_MARGIN_X, maxBottom - winTop + ImmCon.DEFAULT.WINDOW_MARGIN_Y )

	end

end


function ImmCon.NumberFieldChanged( editBox )

	if tonumber( editBox:GetText() ) == nil then
		editBox:SetText( "" )
	else
		ImmCon.ConstGUIChanged()
	end

end


function ImmCon.TextFieldChanged( editBox )

	if tostring( editBox:GetText() ) == nil then
		editBox:SetText( "" )
	else
		ImmCon.ConstGUIChanged()
	end

end


function ImmCon.UpdateKeybindStripSelectionMode()

	if ImmCon.Vars then
		if true ~= ImmCon.Vars.HideKeybinds then

			if HOUSING_EDITOR_MODE_SELECTION == GetHousingEditorMode() then
				KEYBIND_STRIP:AddKeybindButtonGroup( ImmCon.KEYBIND_STRIP_SELECTION_MODE )
			else
				KEYBIND_STRIP:RemoveKeybindButtonGroup( ImmCon.KEYBIND_STRIP_SELECTION_MODE )
			end

		end
	end

end


function ImmCon.SetSelectedFurniture( id )

	local items = ImmCon.GetFurniture()
	local isShapeItem = false

	for index, item in ipairs( items ) do
		if id == item.Id then
			isShapeItem = true
			break
		end
	end

	if not isShapeItem then return end

	local x, y, z = HousingEditorGetFurnitureWorldPosition( id )
	local pitch, yaw, roll = HousingEditorGetFurnitureOrientation( id )

	ImmCon.SelectedFurniture = { Id = id, X = x, Y = y, Z = z, Pitch = pitch, Yaw = yaw, Roll = roll }

end


function ImmCon.CheckSelectedFurniture()

	local f = ImmCon.SelectedFurniture
	if nil == f then return end

	local x, y, z = HousingEditorGetFurnitureWorldPosition( f.Id )
	local pitch, yaw, roll = HousingEditorGetFurnitureOrientation( f.Id )
	local p = ImmCon.GetConstParams()
	local changed = false

	if ImmCon.Vars.DragToMove then
		if x ~= f.X then p.X = p.X + ( x - f.X ) changed = true end
		if y ~= f.Y then p.Y = p.Y + ( y - f.Y ) changed = true end
		if z ~= f.Z then p.Z = p.Z + ( z - f.Z ) changed = true end
	end

	if ImmCon.Vars.DragToOrient then
		if pitch ~= f.Pitch then p.Pitch = p.Pitch + math.floor( math.deg( pitch - f.Pitch ) ) changed = true end
		if yaw ~= f.Yaw then p.Yaw = p.Yaw + math.floor( math.deg( yaw - f.Yaw ) ) changed = true end
		if roll ~= f.Roll then p.Roll = p.Roll + math.floor( math.deg( roll - f.Roll ) ) changed = true end
	end

	ImmCon.SelectedFurniture = nil

	if changed then
		ImmCon.RefreshConstGUI()
		ImmCon.Render()
	end

end


-- Event Handlers: System Events


function ImmCon.OnAddOnLoaded( event, addonName )

	if addonName == ImmCon.ADDON_NAME then
		EVENT_MANAGER:UnregisterForEvent( ImmCon.ADDON_NAME, EVENT_ADD_ON_LOADED )
		ImmCon.Initialize()
	end

end


function ImmCon.OnPlayerActivated( event, initial )

	if 0 < ImmCon.GetFurnitureCount() then
		ImmCon.ShowConstGUI()
	else
		ImmCon.HideConstGUI()
	end

end


function ImmCon.OnUIModeChanged( event )

	if 0 >= ( GetCurrentZoneHouseId() or 0 ) then return end

	ImmCon.UpdateKeybindStripSelectionMode()

end


function ImmCon.OnModeChanged( event, oldMode, newMode )

	if 0 >= ( GetCurrentZoneHouseId() or 0 ) then return end

	ImmCon.UpdateKeybindStripSelectionMode()

	local mode = GetHousingEditorMode()

	if HOUSING_EDITOR_MODE_PLACEMENT == mode then

		local id = HousingEditorGetSelectedFurnitureId()
		ImmCon.SetSelectedFurniture( id )

	elseif HOUSING_EDITOR_MODE_PLACEMENT == ImmCon.PreviousEditorMode and nil ~= ImmCon.SelectedFurniture then

		ImmCon.CheckSelectedFurniture()

	end

	ImmCon.PreviousEditorMode = mode

end


function ImmCon.OnHousingEditorFurniturePlaced( eventCode, furnitureId, collectibleId )

	if nil ~= ImmCon.CurrentProcess and ImmCon.CurrentProcess.OnFurniturePlaced then
		ImmCon.CurrentProcess.OnFurniturePlaced( eventCode, furnitureId, collectibleId )
	end

end


function ImmCon.OnHousingEditorFurnitureRemoved( eventCode, furnitureId, collectibleId )

	if nil ~= furnitureId then
		ImmCon.RemoveFurniture( furnitureId )
	end
	
	if nil ~= ImmCon.CurrentProcess and ImmCon.CurrentProcess.OnFurnitureRemoved then
		ImmCon.CurrentProcess.OnFurnitureRemoved( eventCode, furnitureId, collectibleId )
	end

end


function ImmCon.Initialize()

	ZO_CreateStringId( "SI_BINDING_NAME_IMMCON_ACTION_SHOW_HIDE", "Show / Hide" )
	ZO_CreateStringId( "SI_BINDING_NAME_IMMCON_ACTION_CENTER_ON_TARGET", "Center on Target" )
	ZO_CreateStringId( "SI_BINDING_NAME_IMMCON_ACTION_ADD_TARGET", "Add Targeted Furniture Stack" )

	ZO_PreHook( "ZO_InventorySlot_ShowContextMenu", ImmCon.AddInventoryContextMenu )

	ImmCon.Vars = ZO_SavedVars:NewAccountWide( ImmCon.SAVED_VARS_FILE, ImmCon.SAVED_VARS_VERSION, nil, ImmCon.SAVED_VARS_DEFAULTS )
	ImmCon.CleanVars()
	ImmCon.SetupSettingsMenu()

	SLASH_COMMANDS[ ImmCon.SLASH_COMMAND_PREFIX ] = ImmCon.SlashCommand

end


-- Event Registration


EVENT_MANAGER:RegisterForEvent( ImmCon.ADDON_NAME, EVENT_ADD_ON_LOADED, ImmCon.OnAddOnLoaded )
EVENT_MANAGER:RegisterForEvent( ImmCon.ADDON_NAME, EVENT_PLAYER_ACTIVATED, ImmCon.OnPlayerActivated )

EVENT_MANAGER:RegisterForEvent( ImmCon.ADDON_NAME, EVENT_GAME_CAMERA_UI_MODE_CHANGED, ImmCon.OnUIModeChanged )
EVENT_MANAGER:RegisterForEvent( ImmCon.ADDON_NAME, EVENT_HOUSING_EDITOR_MODE_CHANGED, ImmCon.OnModeChanged )

EVENT_MANAGER:RegisterForEvent( ImmCon.ADDON_NAME, EVENT_HOUSING_FURNITURE_PLACED, ImmCon.OnHousingEditorFurniturePlaced )
EVENT_MANAGER:RegisterForEvent( ImmCon.ADDON_NAME, EVENT_HOUSING_FURNITURE_REMOVED, ImmCon.OnHousingEditorFurnitureRemoved )


-- Methods : Text Rasterization


function ImmCon.RasterizeText( process, p, data, originVector, itemCount, points, xRotation, yRotation, zRotation )

	local lineIndex, blockIndex, itemIndex = 1, 1, 1
	local text = p.Text
	local origin = { 0, 0, 0 }

	if nil == text or "" == text then return end

	local rasterizationData = ImmCon.IsFurnitureHomogenous( ImmCon.TEXT_RASTERIZATION_ITEMS )

	if nil == rasterizationData then
		d( "Text can only be rasterized with one of the following items types:" )
		for itemLink, _ in pairs( ImmCon.TEXT_RASTERIZATION_ITEMS ) do df( " %s", itemLink ) end
		return
	end

	local blockSize = rasterizationData.BlockSize
	local ledOffsets = rasterizationData.LEDOffsets
	local ledChars = ImmCon.LED_CHARS

	local FillBlock = function( origin, lineIndex, blockIndex, blockSize, charLed, ledOffsets )

		lineIndex = lineIndex - 1
		blockIndex = blockIndex - 1

		local FillLed = function( x, y, z, pitch, yaw, roll )

			if itemIndex <= itemCount then
				points[ itemIndex ] = { x, y, z, math.rad( pitch ), math.rad( yaw ), math.rad( roll ) }
			end

			itemIndex = itemIndex + 1

		end

		for led = 1, #charLed do
		
			if 1 == charLed[ led ] then

				FillLed( origin[ 1 ] + ( blockIndex * blockSize[ 1 ] ) + ledOffsets[ led ].X,
					origin[ 2 ] + ( lineIndex * blockSize[ 2 ] ) + ledOffsets[ led ].Y,
					origin[ 3 ] + ( blockIndex * blockSize[ 3 ] ) + ledOffsets[ led ].Z,
					ledOffsets[ led ].Pitch,
					ledOffsets[ led ].Yaw,
					ledOffsets[ led ].Roll )

			end

		end

	end

	local charLetter = ""
	local charLed = nil

	for charIndex = 1, #text do

		charLetter = string.sub( text, charIndex, charIndex ):lower()

		if "\n" == charLetter or "~" == charLetter then

			lineIndex = lineIndex + 1
			blockIndex = 1

		else

			charLed = ledChars[ charLetter ]

			if nil ~= charLed then
				FillBlock( origin, lineIndex, blockIndex, blockSize, charLed, ledOffsets )
				blockIndex = blockIndex + 1
			end

		end

	end

	origin[ 1 ], origin[ 2 ], origin[ 3 ] = ImmCon.CalculateOuterBoundsAndCenter( points )
	origin[ 1 ], origin[ 2 ], origin[ 3 ] = -1 * origin[ 1 ], -1 * origin[ 2 ], -1 * origin[ 3 ]

	for _, p in pairs( points ) do

		ImmCon.TranslatePoint( p, origin )
		--if 0 ~= zRotation then ImmCon.RotatePointOnAxisZ( p, math.rad( zRotation ) ) p[ 6 ] = p[ 6 ] + math.rad( zRotation ) end
		if 0 ~= xRotation then ImmCon.RotatePointOnAxisX( p, math.rad( xRotation ) ) p[ 4 ] = p[ 4 ] + math.rad( xRotation ) end
		if 0 ~= yRotation then ImmCon.RotatePointOnAxisY( p, math.rad( yRotation ) ) p[ 5 ] = p[ 5 ] + math.rad( yRotation ) end
		ImmCon.TranslatePoint( p, originVector )

	end

	
	if ( itemIndex or 0 ) > ( itemCount or 0 ) then
		df( "WARNING: Missing %d item(s) to complete the phrase.", ( itemIndex - itemCount ) )
	end

end
