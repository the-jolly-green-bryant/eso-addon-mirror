if not PUGmo then
    PUGmo = {}
end
local PUG = PUGmo
local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER
local SM = SCENE_MANAGER
local CM = CALLBACK_MANAGER
local CS = CHAT_SYSTEM

-------------------------------------------------------------------------
--- Say Handler
-------------------------------------------------------------------------
function PUG:sayHandler(channel, fromName, msg, isCustomerService, name)
    if GetGroupSize() > 0 then
        PUG:groupHandler(channel, fromName, msg, isCustomerService, name)
    end
    --PUG:debug("* From say channel *: " .. name .. " " .. msg)
end

-------------------------------------------------------------------------
--- Group Handler
-------------------------------------------------------------------------
function PUG:groupHandler(_, _, msg, _, name)
    --PUG:debug(name .. "groupHandler Said: " .. msg)
    local noItem = true
    local index = PUG:getIndex(name)
    --if index == 0 or index > 11 then
        --PUG:debug("* groupHandler index error *: " .. index)
    --end

    for w in string.gmatch(msg, "|H%d:item:.-|h|h") do
        noItem = false
        --- not collected already, not a duplicate listing in our inventory already
        if PUG:isCollectable(w, index) then
            --PUG:debug("* collectable * " .. w)
            table.insert(PUG.groupBuffer[index].items, w)
        end
    end

    if GetUnitDisplayName(GetGroupLeaderUnitTag()) == name and noItem then
        PUG:addAlert(PUG.color.red .. "\nGROUP LEADER|r\n|cff00ff|l1:1:1:4:5:FFAA33|l" .. name .. "|l|r\n\n" .. msg .. "\n", "/esoui/art/lfg/lfg_leader_icon.dds", PUG.SV.alertTime.leader)
        return
    end

    if noItem then
        return
    end

    PUG:updateGroupList()
    --PUG:debug("groupBuffer", PUG:tableToString(PUG.groupBuffer))

end

--- return true to add the item
-------------------------------------------------------------------------
function PUG:isCollectable(itemLink, index)
    --PUG:debug("*** isCollectable? " .. itemLink)

    --- is it bound?
    if IsItemLinkBound(itemLink) then
        --PUG:debug("bound *")
        return false
    end

    --- Check that this is a candidate for set collection
    if not IsItemLinkSetCollectionPiece(itemLink) then
        --PUG:debug("not collection piece ***")
        return false
    end

    if IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink)) then
        --PUG:debug("collected already ***")
        return false
    end

    --- do we have one in inventory already? true = yes
    if PUG:checkBackpack(itemLink) then
        --PUG:debug("in backpack ***")
        return false
    end
    --- at this point its not bound, it is a collection piece, we don't have it yet and we don't have it in the backpack
    --- the following must be done last
    --- the first thing they listed so add it
    if #PUG.groupBuffer[index].items == 0 then
        --PUG:debug("first item and isCollectable. add it ***")
        return true
    end

    --PUG:debug("num of items already listed " .. #PUG.groupBuffer[index].items)
    --- protects against linking the same item more than once. Can not tell if they have more than one
    --- of the exact same trait. should be rare.
    for i = 1, #PUG.groupBuffer[index].items do
        --PUG:debug(PUG.groupBuffer[index].items[i] .. " <- already listed = this item ->" .. itemLink)
        if itemLink == PUG.groupBuffer[index].items[i] then
            --PUG:debug("dupicate ***")
            return false
        end
    end

    --PUG:debug("it isCollectable. add it ***")
    return true

end

-------------------------------------------------------------------------
function PUG:checkBackpack(itemLink)

    local _, setName, _, _, setId = GetItemLinkSetInfo(itemLink)
    local type = GetItemLinkEquipType(itemLink)

    for slot = 1, GetBagSize(BAG_BACKPACK) do
        local _, thisSetName, _, _, thisSetId = GetItemLinkSetInfo(GetItemLink(BAG_BACKPACK, slot))
        --PUG:debug("Bag Item: " .. GetItemLink(BAG_BACKPACK, slot))
        --PUG:debug("Link Name: " .. setName .. "Type: " .. type)
        --PUG:debug("Bag Name: " .. thisSetName .. "Type: " .. GetItemEquipType(BAG_BACKPACK, slot) .. "\n")
        if setName == thisSetName then
            if type == GetItemEquipType(BAG_BACKPACK, slot) then
                if type == EQUIP_TYPE_ONE_HAND or type == EQUIP_TYPE_TWO_HAND then
                    --PUG:debug("Link  Weapon: " .. GetItemLinkWeaponType(itemLink))
                    --PUG:debug("Bag  Weapon: " .. GetItemWeaponType(BAG_BACKPACK, slot))
                    if GetItemLinkWeaponType(itemLink) == GetItemWeaponType(BAG_BACKPACK, slot) then
                        --PUG:debug("* We have this set and *WEAPON* type in inventory *: " .. setName .. " Weapon Type: " .. GetItemLinkWeaponType(itemLink))
                        return true
                    else
                        return false
                    end
                end
                --PUG:debug("* We have this set and *ARMOR* type in inventory *: " .. setName .. " Armor TYpe: " .. type)
                return true
            end
        end
    end
    return false
end

--- is a call back - fires every 0.5 sec
-------------------------------------------------------------------------
-- todo add in the fade for nonOSI edgeColor fade here
function PUG:updateGroupBuffer()
    for index = 1, #PUG.groupBuffer do
        --local items = #PUG.groupBuffer[index].items
        for j = 1, #PUG.groupBuffer[index].items do
            local itemLink = PUG.groupBuffer[index].items[j]
            if PUG:checkBackpack(itemLink) then
                table.remove(PUG.groupBuffer[index].items, j)
            end
        end
        PUG:updateGroupList()
    end
end

-------------------------------------------------------------------------
function PUG:getIndex(name)
    --PUG:debug("* getIndex groupBuffer *: " .. #PUG.groupBuffer)
    --- this is for the first calls to onRoleChange that has unitTag not set
    if type(name) ~= "string" then
        --PUG:debug("* getIndex name error *")
        name = tostring(name)
        --PUG:debug("name: " .. name)
        return
    end
    --- first access
    if not PUG.data.initGroupList then
        PUG:initGroupList()
    end
    for i = 1, #PUG.groupBuffer do
        if name == PUG.groupBuffer[i].name then
            --PUG:debug("* getIndex found *: " .. i)
            return i
        end
    end

    if name ~= PUG.data.me then
        table.insert(PUG.groupBuffer, { name = name, role = "not defined", items = {} })
        PUG:updateGroupList()
        --PUG:debug("* getIndex New Unit added to groupList *: " .. name)
        return #PUG.groupBuffer
    end
    return 12
end

-------------------------------------------------------------------------
function PUG:initGroupList()
    --PUG:debug("*** initGroupList")
    local size = GetGroupSize()
    if size == 0 then
        return
    end

    --PUG:debug("Group Size : " .. size)
    PUG.groupBuffer = {}
    for i = 1, size do
        local name = GetUnitDisplayName("group" .. i)
        local role = PUG.role[GetGroupMemberSelectedRole("group" .. i)]
        if name ~= PUG.data.me then
            table.insert(PUG.groupBuffer, { name = name, role = role, items = {} })
            --PUG:debug("added: " .. name)
        end
    end
    PUG:updateGroupList()
    PUG.data.initGroupList = true
    --PUG:debug("initGroupList ***")
end

-------------------------------------------------------------------------
function PUG:updateGroupList()
    if not PUG.groupBuffer then
        ZO_ScrollList_Clear(PUGmoWindowGroupListUnits)
        ZO_ScrollList_Commit(PUGmoWindowGroupListUnits)
        return
    end
    local dataCopy = ZO_DeepTableCopy(PUG.groupBuffer)
    --- get link to the dataList of the controlList
    local dataList = ZO_ScrollList_GetDataList(PUGmoWindowGroupListUnits)
    ZO_ScrollList_Clear(PUGmoWindowGroupListUnits)
    for i = 1, #PUG.groupBuffer do
        dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(1, dataCopy[i])
        for j = 1, #PUG.groupBuffer[i].items do
        --if #PUG.groupBuffer[i].items > 0 then
            dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(2, dataCopy[i].items)
        end
    end
    PUG.data.item = 1
    --- Commit the list.
    ZO_ScrollList_Commit(PUGmoWindowGroupListUnits)
end

