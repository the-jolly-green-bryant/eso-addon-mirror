local SK = SwissKnife

local linkPrefix = "|H0:item"
local linkPostfix = "|h|h"
local linkZeroMarker = "#"

local function compressItemLink(itemLink)
    if type(itemLink) ~= "string" then return nil, "string expected, got "..type(itemLink) end
    local data = string.gsub(string.gsub(itemLink, linkPrefix, ""), linkPostfix, "")
    if data == itemLink then return itemLink end
    local count = 0
    local result = ""
    for part in string.gmatch(data, ":%d+") do
        if part ~= ":0" then
            if count ~= 0 then
                result = result..linkZeroMarker..count
                count = 0
            end
            result = result..part
        else
            count = count + 1
        end
    end
    if count ~= 0 then result = result..linkZeroMarker..count end
    return result
end

local function decompressItemLink(itemLink)
    if type(itemLink) ~= "string" then return nil, "string expected, got "..type(itemLink) end
    -- check is not packed link
    local _, foundPrefix = string.gsub(itemLink, linkPrefix, "")
    local _, foundPostfix = string.gsub(itemLink, linkPostfix, "")
    if foundPrefix ~= 0  or foundPostfix ~= 0 then return itemLink end
    for part in string.gmatch(itemLink, linkZeroMarker.."%d+") do
        local countStr, r = string.gsub(part, linkZeroMarker, "")
        if r == 1 then
            local zeroString = ""
            for _=1, tonumber(countStr) do zeroString = zeroString..":0" end
            itemLink = string.gsub(itemLink, part, zeroString)
        end
    end
    return linkPrefix..itemLink..linkPostfix
end

SK.HelperFunctions.compressItemLink = compressItemLink
SK.HelperFunctions.decompressItemLink = decompressItemLink
