local IE = InventoryExtensions

IE.MarkItem = {}

local function IsMarked(itemLink)
    return false
end

local function ScrollListCommit(list)
    if (IE.InventoryLists[list]) then
        local scrollData = ZO_ScrollList_GetDataList(list)
        for i = 1, #scrollData do
            local data = scrollData[i].data
            local bagId = data.bagId
            local slotIndex = data.slotIndex
            local itemLink = bagId and GetItemLink(bagId, slotIndex) or GetItemLink(slotIndex)
            if itemLink then
                local isMarked = IsMarked(itemLink)
                data.isMarked = isMarked
            end
        end
    end

    return false
end

local function RefreshMark(control)
    local parent = control
    local markControlName = "IE_Mark"
    local markControl = control:GetNamedChild(markControlName)
    local isMarked = parent.dataEntry.data.isMarked

    if not markControl then
        markControl = WINDOW_MANAGER:CreateControl(parent:GetName() .. markControlName, parent, CT_TEXTURE)
        markControl:SetDimensions(16, 16)
        markControl:SetDrawTier(DT_HIGH)
    end

    markControl:SetHidden(not isMarked)
    markControl:SetTexture([[esoui\art\vendor\vendor_tabicon_sell_over.dds]])
    markControl:ClearAnchors()
    markControl:SetAnchor(TOPLEFT, parent, TOPLEFT, 95, 17)
end

local function InitMarkItem()
    ZO_PreHook("ZO_ScrollList_Commit", ScrollListCommit)

    local lists = IE.InventoryLists
    for listView, _ in pairs(lists) do
        if listView and listView.dataTypes and listView.dataTypes[1] then
            ZO_PreHook(listView.dataTypes[1], "setupCallback", function (control, slot)
                RefreshMark(control)
            end)
        end
    end
end

function IE.MarkItem.Init()
    InitMarkItem()
end