LibMultilingualName = LibMultilingualName
LibMultilingualName_GetRawSetItemName_Data = LibMultilingualName_GetRawSetItemName_Data or {}
local LIB = LibMultilingualName -- local name
local LMN = LIB -- Lib Multilingual Name
local RAW_DATA = LibMultilingualName_GetRawSetItemName_Data

--------
-- Public Methods, Consts
--------

function LIB.GetRawSetItemName(langCode, id)
    if langCode == nil then
        return false
    end
    if id == nil then
        return false
    end
    if RAW_DATA[langCode] == nil then
        return false
    end
    if RAW_DATA[langCode][id] == nil then
        return false
    end

    return RAW_DATA[langCode][id]
end

function LIB.GetSetItemName(langCode, id)
    local name = LIB.GetRawSetItemName(langCode, id)
    if name then
        -- TODO
        return ZO_CachedStrFormat("<<C:1>>", name)
    else
        return "NotFound. Lang Code " .. langCode .. " Id " .. id
    end
end
