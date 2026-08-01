LibMultilingualName = LibMultilingualName
LibMultilingualName_GetRawQuestTaskName_Data = LibMultilingualName_GetRawQuestTaskName_Data or {}
local LIB = LibMultilingualName -- local name
local LMN = LIB -- Lib Multilingual Name
local RAW_DATA = LibMultilingualName_GetRawQuestTaskName_Data

--------
-- Public Methods, Consts
--------

function LIB.GetRawQuestTaskName(langCode, id)

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


function LIB.GetQuestTaskName(langCode, id)

    local name = LIB.GetRawQuestTaskName(langCode, id)
    if name then
        -- TODO format
        return ZO_CachedStrFormat("<<C:1>>", name)
    else 
        return "NotFound. Lang Code ".. langCode .. " Id " .. id
    end
end