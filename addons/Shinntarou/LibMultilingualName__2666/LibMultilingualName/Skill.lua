LibMultilingualName = LibMultilingualName
LibMultilingualName_GetRawSkillName_Data = LibMultilingualName_GetRawSkillName_Data or {}
local LIB = LibMultilingualName -- local name
local LMN = LIB -- Lib Multilingual Name
local RAW_DATA = LibMultilingualName_GetRawSkillName_Data


--------
-- Public Methods, Consts
--------

function LIB.GetRawSkillName(langCode, id)

    if langCode == nil then return false end
    if id == nil then return false end

    if RAW_DATA[langCode] == nil then
        return false
    end
    if RAW_DATA[langCode][id] == nil then
        return false
    end

    return RAW_DATA[langCode][id]
end

function LIB.GetSkillName(langCode, id)

    local name = LIB.GetRawSkillName(langCode, id)
    if name then
        -- TODO format, morph, skill level
        return ZO_CachedStrFormat("<<C:1>>", name)
    else 
        return "NotFound. Lang Code ".. langCode .. " Id " .. id
    end
end
