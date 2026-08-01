ExtendedItemNames = {}

ExtendedItemNames.name = "ExtendedItemNames"

function ExtendedItemNames.OnAddOnLoaded(event, addonName)
    if addonName ~= ExtendedItemNames.name then
        return
    end
    ExtendedItemNames.Initialize()
end

local function GetNewName(link)
    local newName
    local traitInfo = GetItemLinkTraitType(link)
    local type, descr = GetItemLinkTraitInfo(link)
    local itemName = GetItemLinkName(link)
    local traitName = GetString("SI_ITEMTRAITTYPE", type)
    local formatted = zo_strformat("<<t:1>>", itemName)
    local itemType = GetItemLinkItemType(link)
    if itemType == ITEMTYPE_ARMOR or ITEMTYPE_WEAPON then
        if traitName ~= "No Trait" then
            newName = formatted .. "\n( " .. traitName .. " )"
        else
            newName = formatted
        end
    else
        newName = formatted
    end

    return newName
end

local function OnPlayerActivated(eventCode)
    EVENT_MANAGER:UnregisterForEvent(ExtendedItemNames.name, eventCode)
end

local function replaceNames()
    for _, v in pairs(PLAYER_INVENTORY.inventories) do
        local listView = v.listView
        if listView and listView.dataTypes and listView.dataTypes[1] then
            ZO_PreHook(
                listView.dataTypes[1],
                "setupCallback",
                function(rowControl, slot)
                    local link = GetItemLink(slot.bagId, slot.slotIndex, LINK_STYLE_DEFAULT)
                    local newName = GetNewName(link)

                    slot.name = newName
                end
            )
        end
    end
end
function ExtendedItemNames.Initialize()
    replaceNames()

    EVENT_MANAGER:UnregisterForEvent(ExtendedItemNames.name, EVENT_ADD_ON_LOADED)
end
----------
--Events--
----------
EVENT_MANAGER:RegisterForEvent(ExtendedItemNames.name, EVENT_ADD_ON_LOADED, ExtendedItemNames.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(ExtendedItemNames.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
