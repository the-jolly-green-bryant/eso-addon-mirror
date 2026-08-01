LibMultilingualName = LibMultilingualName
LibMultilingualName_GetRawItemName_Data = LibMultilingualName_GetRawItemName_Data or {}
local LIB = LibMultilingualName -- local name
local LMN = LIB -- Lib Multilingual Name
local RAW_DATA = LibMultilingualName_GetRawItemName_Data

--------
-- Public Methods, Consts
--------

function LIB.GetItemNameTableLen(langCode)
    local counter = 0
    local lastKey, lastVal
    for key, val in pairs(LibMultilingualName_GetRawItemName_Data[langCode]) do
        counter = counter +1
        lastKey = key
        lastVal = val
    end

    return counter, lastKey, lastVal
end

function LIB.GetRawItemName(langCode, id)
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

function LIB.GetItemName(langCode, id)
    local name = LIB.GetRawItemName(langCode, id)
    if name then
        -- TODO potion, poison, weapon, etc
        return ZO_CachedStrFormat("<<C:1>>", name)
    else
        return "NotFound. Lang Code " .. langCode .. " Id " .. id
    end
end
