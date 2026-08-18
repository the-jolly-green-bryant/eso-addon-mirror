-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t Updated by Geltungsdrang
-- Created: Jan 1, 2018
-- Edited: Geltungsdrang 2026
-- Textures.lua
-- -----------------------------------------------------------------------------

local GFC = GFC
--- @type string Counter texture
GFC.TEXTURE      = "GrimFocusCounter/art/textures/Numbers.dds"

--- @type integer Number of frames across the strip
GFC.COLUMNS      = 16

--- @type integer Frame shown at zero stacks when the zero digit is hidden
GFC.FRAME_BLANK  = 0

--- @type integer Frame holding the digit 0
GFC.FRAME_ZERO   = 11

--- @type table<string, integer> Texture dimensions
GFC.TEXTURE_SIZE = {
    FRAME_HEIGHT = 128,  -- Height of each texture frame
    FRAME_WIDTH  = 128,  -- Width of each texture frame
    ASSET_WIDTH  = 2048, -- Overall texture width
    ASSET_HEIGHT = 128,  -- Overall texture height
}

--- Get the texture coordinates of a frame
--- Returns all four coordinates so the result can be passed straight into
--- SetTextureCoords(), which needs left, right, top and bottom.
--- @param frame integer Frame index within the strip
--- @return number left, number right, number top, number bottom Coordinates in the range 0..1
function GFC:GetFrameCoords(frame)
    if frame < 0 then frame = 0 end
    if frame > self.COLUMNS - 1 then frame = self.COLUMNS - 1 end

    return frame / self.COLUMNS, (frame + 1) / self.COLUMNS, 0, 1
end
