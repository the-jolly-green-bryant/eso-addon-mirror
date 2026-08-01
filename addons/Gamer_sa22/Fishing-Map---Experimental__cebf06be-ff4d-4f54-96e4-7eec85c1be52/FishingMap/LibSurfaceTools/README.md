## FlexRect

```lua
-- TLibSurfaceTools.Tools.FlexRect(parentControl, customName)
-- Creates new FlexRect, parent control should be provided, customName is optional

-- SetAnchor works the same as for any default control
-- !! You can chain methods

-- SetTexture(filePath, atlasSizeX, atlasSizeY)
-- Works the same as for any default contols and additionally takes atlas size (for example 3 x 3 = 9 textures in one)

local map = LibSurfaceTools.Tools.FlexRect(ZO_WorldMapContainer)
    :SetAnchor(TOPLEFT)
    :SetAnchor(BOTTOMRIGHT)
    :SetTexture('/esoui/art/tutorial/poi_wayshrine_complete.dds', 2, 2)

-- Add(normalizedX, normalizedY, offsetXpx, offsetYpx, width, heigth, atlasX, atlasY)
-- Adds new surface at coordinate (normalizedX, normzliaedY)
-- with offsetX and offsetY (in px, if you want to place two surfaces at one coorninate with slight offset to each other)
-- of width x height size (desired width and height of surface in px)
-- if atlas provided instead of regular texture, you should also provide atlasX and atlasY to select texture from atlas
-- !! You can provide only one variable - atlasX, it will be treated as texture index in atlas and converted to atlasX and atlasY automatically
-- For atlas 3 x 3 atlas index is integer from 1 to 9 corresponding to 1 of 9 textures, index increased from left to right and from top to bottom
-- 1 2 3
-- 4 5 6
-- 7 8 9
-- So, texture with index 6 has atlas coordinates (3, 2) - third column, second row
-- and texture with coordinates (2, 3) has index 8

map:Add(0.5 + x, 0.5 - y, 0, 0, 16, 16, math.ceil(4 * i / N))

-- RemoveSurfacesOfKind(atlasX, atlasY)
-- Remove surfaces with atlasX atlasY texture
-- Similarly to Add, you can specify either both atals coordinates or one atlas index

map:RemoveSurfacesOfKind(3)

-- Clear()
-- Removes all surfaces

map:Clear()
```