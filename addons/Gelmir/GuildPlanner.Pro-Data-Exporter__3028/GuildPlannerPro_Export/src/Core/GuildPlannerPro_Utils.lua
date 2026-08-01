GuildPlannerPro_Utils = {}


------------------------------------------------------------------------
--     Global helper functions
------------------------------------------------------------------------
--Create an example itemlink of the setItem's itemId (level 50, CP160) using the itemQuality subtype.
--Standard value for the qualitySubType is 366 which means "Normal" quality.
--The following qualities are available:
--357:  Trash
--366:  Normal
--367:  Magic
--368:  Arcane
--369:  Artifact
--370:  Legendary
--> Parameters: itemId number: The item's itemId
-->             itemQualitySubType number: The itemquality number of ESO, described above (standard value: 366 -> Normal)
--> Returns:    itemLink String: The generated itemLink for the item with the given quality
function GuildPlannerPro_Utils:BuildItemLink(itemId, itemQualitySubType)
    if itemId == nil or itemId == 0 then return end
    --itemQualitySubType is used for the itemLinks quality, see UESP website for a description of the itemLink: https://en.uesp.net/wiki/Online:Item_Link
    itemQualitySubType = itemQualitySubType or 366 -- Normal
    --itemQualitySubType values for Level 50 items:
    --return '|H1:item:'..tostring(itemId)..':30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h'
    return string.format("|H1:item:%d:%d:50:0:0:0:0:0:0:0:0:0:0:0:0:%d:%d:0:0:%d:0|h|h", itemId, itemQualitySubType, ITEMSTYLE_NONE, 0, 10000)
end
--|H1:item:4325:364:50:54484:370:50:0:0:0:0:0:0:0:0:1:6:0:1:0:295:0|h|h

function GuildPlannerPro_Utils:Count(myTable)
    local count = 0
    for _, _ in pairs(myTable) do
        count = count + 1
    end

    return count
end

function GuildPlannerPro_Utils:TableKeyExists(value, myTable)
    for k, _ in pairs(myTable) do
        if (k == value) then
            return true
        end
    end

    return false
end

function GuildPlannerPro_Utils:InTable(value, myTable)
    for _, v in pairs(myTable) do
        if (v == value) then
            return true
        end
    end

    return false
end

function GuildPlannerPro_Utils:IsSupportedLanguage()
    local lang = string.lower(GetCVar("Language.2"))
    if lang ~= "en" then
        return false
    end

    return true
end

function GuildPlannerPro_Utils:PrintMessage(text)
    CHAT_SYSTEM:AddMessage("[|cD08020" .. GuildPlannerPro_Export.DisplayName .. "|r] " .. text)
end
