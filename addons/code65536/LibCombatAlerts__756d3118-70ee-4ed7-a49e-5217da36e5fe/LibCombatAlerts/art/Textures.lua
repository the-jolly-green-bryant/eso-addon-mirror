local Textures = {
	["blank"] = "blank.dds", -- 0xFFFFFFFF
	["clear"] = "clear.dds", -- 0x00000000

	["arrow-rotate"] = "Arrows/rotate.dds",
	["arrow-rotate-ccw"] = { "Arrows/rotate.dds", 1, 0, 0, 1 },
	["misc-checkered16"] = "Misc/checkered16.dds",
	["misc-check"] = "Misc/check.dds",
	["misc-x"] = "Misc/x.dds",
	["screenborder-edge"] = "ScreenBorder/edge.dds",

	-- "World" textures have no mipmaps and are intended for drawing in the world space rather than for use in alert text
	["world-ring"] = { "World/general.dds", 0, 1, 0, 1, 4, 2 },
	["world-circle"] = { "World/general.dds", 1, 2, 0, 1, 4, 2 },
	["world-triangle-bordered"] = { "World/general.dds", 2, 3, 0, 1, 4, 2 },
	["world-triangle-bordered-down"] = { "World/general.dds", 2, 3, 1, 0, 4, 2 },
	["world-hexagon-bordered"] = { "World/general.dds", 3, 4, 0, 1, 4, 2 },
	["world-circle-bordered"] = { "World/general.dds", 0, 1, 1, 2, 4, 2 },
	["world-diamond-bordered"] = { "World/general.dds", 1, 2, 1, 2, 4, 2 },
	["world-pointer"] = { "World/general.dds", 2, 3, 1, 2, 4, 2 },
	["world-pointer-down"] = { "World/general.dds", 2, 3, 2, 1, 4, 2 },
	["world-teardrop"] = { "World/general.dds", 3, 4, 1, 2, 4, 2 },
	["world-teardrop-down"] = { "World/general.dds", 3, 4, 2, 1, 4, 2 },

	["world-rotate"] = "World/rotate.dds",
	["world-rotate-ccw"] = { "World/rotate.dds", 1, 0, 0, 1 },
	["world-rotate-chevrons"] = "World/rotate-chevrons.dds",
	["world-rotate-chevrons-ccw"] = { "World/rotate-chevrons.dds", 1, 0, 0, 1 },
}

-- Text for use in drawing in the world space
do
	local texture = "World/text.dds"

	for i, dir in ipairs({ "n", "nw", "w", "sw", "s", "se", "e", "ne" }) do
		Textures["world-dir-" .. dir] = { texture, i - 1, i, 0, 1, 8, 4 }
	end

	for i = 0, 12 do
		local col = i % 8
		local row = zo_floor(i / 8)
		Textures["world-num-" .. i] = { texture, col, col + 1, row + 1, row + 2, 8, 4 }
	end
	Textures["world-num-gt9"] = { texture, 7, 8, 2, 3, 8, 4 }

	for i = 1, 8 do
		local char = string.char(0x60 + i)
		Textures["world-letter-" .. char] = {texture, i - 1, i, 3, 4, 8, 4 }
	end
end

LibCombatAlertsInternal.Textures = Textures
