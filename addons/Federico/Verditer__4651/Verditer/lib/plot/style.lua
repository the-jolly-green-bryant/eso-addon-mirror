Verditer = Verditer or {}
Verditer.lib = Verditer.lib or {}
Verditer.lib.plot = Verditer.lib.plot or {}

local M = {}
Verditer.lib.plot.Style = M

--?  grid / axis 
M.GRID_COLOR        = { 0.35, 0.35, 0.35, 0.40 }
M.AXIS_TEXT_COLOR   = { 0.70, 0.70, 0.70, 0.90 }
M.AXIS_TEXT_FONT    = "ZoFontGameSmall"

--?  line rendering 
M.DEFAULT_LINE_WIDTH       = 2
M.DEFAULT_SKIP_BELOW_PX    = 3

--?  strip / fill default textures 
M.WHITE_PIXEL_TEXTURE = "EsoUI/Art/Miscellaneous/listItem_backdrop.dds"
