--[[

Missing Map Textures Patch
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- List of textures to replace (Element info: {string texture_to_replace, integer num_tiles, string:nilable existing_replacement_texture})
local textures = {
}

-- Redirect all texture tiles for all maps in the list
local DIR_ORIG  = "/art/maps/"
local DIR_PATCH = "MissingMapTexturesPatch/maps/"
for i, t in ipairs(textures) do
    for j=0, (t[2]-1) do
        -- Generate file string of original texture to be replaced, using j
        local tex_orig = DIR_ORIG..t[1].."_"..tostring(j)..".dds"
        -- Generate file string of patch texture, using j and either existing texture or new texture
        local tex_patch = (t[3] and DIR_ORIG..t[3] or DIR_PATCH..t[1]).."_"..tostring(j)..".dds"
        -- Redirect missing texture to patched texture
        RedirectTexture(tex_orig, tex_patch)
    end
end