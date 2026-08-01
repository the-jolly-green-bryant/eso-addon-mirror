-- Beltalowda Beam Definitions
-- Based on RdK Group Tool Util Beams
-- Beams 1-4 are vertical beams with increasing thickness

Beltalowda = Beltalowda or {}
Beltalowda.Util = Beltalowda.Util or {}
Beltalowda.Util.Beams = Beltalowda.Util.Beams or {}

local Beams = Beltalowda.Util.Beams

-- Beam thickness levels (1 = thinnest, 4 = thickest)
Beams.MIN_THICKNESS = 1
Beams.MAX_THICKNESS = 4
Beams.DEFAULT_THICKNESS = 1

-- Beam definitions indexed by thickness level
Beams.data = {
    [1] = {
        texture = "Beltalowda/Art/3DObjects/Beam1.dds",
        height = 256,
        width = 1,
        heightOffset = 0,
    },
    [2] = {
        texture = "Beltalowda/Art/3DObjects/Beam2.dds",
        height = 256,
        width = 1,
        heightOffset = 0,
    },
    [3] = {
        texture = "Beltalowda/Art/3DObjects/Beam3.dds",
        height = 256,
        width = 1,
        heightOffset = 0,
    },
    [4] = {
        texture = "Beltalowda/Art/3DObjects/Beam4.dds",
        height = 256,
        width = 1,
        heightOffset = 0,
    },
}

--- Get beam data for a given thickness level.
-- Falls back to thickness 1 if out of range.
function Beams.GetBeamByThickness(thickness)
    thickness = thickness or Beams.DEFAULT_THICKNESS
    if thickness < Beams.MIN_THICKNESS then thickness = Beams.MIN_THICKNESS end
    if thickness > Beams.MAX_THICKNESS then thickness = Beams.MAX_THICKNESS end
    return Beams.data[thickness]
end

-- Legacy compatibility: GetBeamByBeamId maps to GetBeamByThickness
Beams.GetBeamByBeamId = Beams.GetBeamByThickness
