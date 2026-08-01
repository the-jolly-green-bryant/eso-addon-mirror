if not GridList then return end
local media = GridList.media

local name_backdrop, backdrop, name_edge, edge = media.name_backdrop, media.backdrop, media.name_edge, media.edge

--Skin 1--
--Backdrop
table.insert(name_backdrop,		"Gradient")
table.insert(backdrop,			"GridListCleanSkin/textures/bg-gradient.dds")
--Edge
table.insert(name_edge,			"Clean Thin")
table.insert(edge,				"GridListCleanSkin/textures/clean-border-thin.dds")

--Skin 2--
--Backdrop
table.insert(name_backdrop,		"Flat")
table.insert(backdrop,			"GridListCleanSkin/textures/bg-flat.dds")

--Edge
table.insert(name_edge,			"Clean Thic")
table.insert(edge,				"GridListCleanSkin/textures/clean-border-thic.dds")
