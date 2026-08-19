ShoppingListContextMenu = {}

local ContextMenu = ShoppingListContextMenu

local function addLinkedItem(owner, itemLink)
    local item, message = owner:AddItem("", 1, itemLink)
    if not item then
        owner.ui:SetStatus(message, true)
        return
    end

    owner.ui:SetStatus(zo_strformat(
        GetString(SI_SHOPPING_LIST_STATUS_ADDED_ITEM),
        item.name
    ))
    owner.editor:Open(item)
end

local function getAddActionName(owner)
    local list = owner.data:GetCurrentList()
    if not list then
        return nil
    end

    return zo_strformat(
        GetString(SI_SHOPPING_LIST_CONTEXT_ADD_TO_LIST),
        list.name
    )
end

function ContextMenu:Initialize(owner)
    local menu = LibCustomMenu
    if not menu or not menu.RegisterContextMenu then
        return
    end

    menu:RegisterContextMenu(function(inventorySlot, slotActions)
        local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
        if bagId == nil or slotIndex == nil then
            return
        end

        local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
        if not itemLink or itemLink == "" then
            return
        end

        local actionName = getAddActionName(owner)
        if not actionName then
            return
        end

        slotActions:AddCustomSlotAction(actionName, function()
            addLinkedItem(owner, itemLink)
        end, "")
    end, menu.CATEGORY_PRIMARY)

    if not LINK_HANDLER or not LINK_HANDLER.RegisterCallback then
        return
    end

    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT,
        function(itemLink, button, _, _, linkType)
            if button ~= MOUSE_BUTTON_INDEX_RIGHT or linkType ~= ITEM_LINK_TYPE then
                return
            end

            zo_callLater(function()
                local actionName = getAddActionName(owner)
                if not actionName or not AddCustomMenuItem then
                    return
                end

                AddCustomMenuItem(actionName, function()
                    addLinkedItem(owner, itemLink)
                end, MENU_ADD_OPTION_LABEL)
                ShowMenu()
            end, 4)
        end)
end
