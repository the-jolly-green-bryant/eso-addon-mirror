if not GridList then return end
local media = GridList.media

local name_backdrop, backdrop, name_edge, edge = media.name_backdrop, media.backdrop, media.name_edge, media.edge

--===============================================================================================--

-- Observe such a sequence for each skin separately, if there are several. 
--You can add only “Backdrop” or only “Edge”, “Font”, remove unnecessary.

--Skin 1-------------------------------------------------------------------------------------------

--Backdrop
table.insert(name_backdrop,		"Dirt")
table.insert(backdrop,			"GridListSkins/textures/backdrop_dirt.dds")
--Edge
table.insert(name_edge,			"Edge-ESO\nWidth-256, Height-256")
table.insert(edge,				"GridListSkins/textures/edge_eso.dds")
--Font
-- table.insert(GL.media.fonts,	"EsoUI/Common/Fonts/univers57.otf")

--///////////////////////////////////////////////////////////////////////////////////////////////--

--Skin 2-------------------------------------------------------------------------------------------

--Edge
table.insert(name_edge,			"Edge-Outline\nWidth-32, Height-4")
table.insert(edge,				"GridListSkins/textures/edge_outline.dds")

--///////////////////////////////////////////////////////////////////////////////////////////////--

--Skin 3-------------------------------------------------------------------------------------------

--Edge
table.insert(name_edge,			"Edge-Rounded\nWidth-128, Height-16")
table.insert(edge,				"GridListSkins/textures/edge_rounded.dds")

--///////////////////////////////////////////////////////////////////////////////////////////////--
--Skin 4-------------------------------------------------------------------------------------------

--Edge
table.insert(name_edge,			"Edge-Glow\nWidth-128, Height-16")
table.insert(edge,				"GridListSkins/textures/edge_glow.dds")

--///////////////////////////////////////////////////////////////////////////////////////////////--
