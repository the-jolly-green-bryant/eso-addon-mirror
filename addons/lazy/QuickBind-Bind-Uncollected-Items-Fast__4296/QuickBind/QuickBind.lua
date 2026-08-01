QuickBind = {}
local addonName = "QuickBind"

ZO_CreateStringId("SI_BINDING_NAME_QUICKBIND_BIND_ITEM", "Bind Hovered Item")
ZO_CreateStringId("SI_BINDING_NAME_QUICKBIND_BIND_UNCOLLECTED", "Bind All Uncollected Gear")

function QuickBind.BindHoveredItem()
    local moc = WINDOW_MANAGER:GetMouseOverControl()
    if moc and moc.dataEntry and moc.dataEntry.data then
        local data = moc.dataEntry.data
        local bagId = data.bagId
        local slotIndex = data.slotIndex
        if bagId and slotIndex and bagId == BAG_BACKPACK then
            BindItem(bagId, slotIndex)
        end
    end
end

function QuickBind.IsGearType(itemType)
    return itemType == ITEMTYPE_ARMOR or 
           itemType == ITEMTYPE_WEAPON or 
           itemType == ITEMTYPE_JEWELRY
end

function QuickBind.ScanAndBindUncollected()
    -- Check if inventory is open
    if not SCENE_MANAGER:IsShowing("inventory") then
        d("QuickBind: Inventory must be open to use this feature.")
        return
    end
    
    -- Scan inventory for uncollected gear
    local uncollectedItems = {}
    local bagId = BAG_BACKPACK
    local bagSlots = GetBagSize(bagId)
    
    for slotIndex = 0, bagSlots - 1 do
        local itemType = GetItemType(bagId, slotIndex)
        
        if QuickBind.IsGearType(itemType) then
            -- Check if the item is not already bound
            local isAlreadyBound = IsItemBound(bagId, slotIndex)
            if not isAlreadyBound then
                -- Get item link
                local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
                if itemLink and itemLink ~= "" then
                    -- Use the exact same check as BindAll addon
                    if IsItemLinkSetCollectionPiece(itemLink) == true then
                        -- Get the item ID
                        local itemId = GetItemLinkItemId(itemLink)
                        -- Try calling the function with itemId like BindAll does
                        local success, isUnlocked = pcall(IsItemSetCollectionPieceUnlocked, itemId)
                        
                        -- Only add if the function worked and returned false (not unlocked)
                        if success and isUnlocked == false then
                            table.insert(uncollectedItems, {bagId = bagId, slotIndex = slotIndex})
                        end
                    end
                end
            end
        end
    end
    
    if #uncollectedItems == 0 then
        d("QuickBind: No uncollected gear found in inventory.")
        return
    end
    
    -- Show confirmation dialog
    QuickBind.ShowConfirmationDialog(uncollectedItems)
end

function QuickBind.ShowConfirmationDialog(items)
    local itemCount = #items
    
    ZO_Dialogs_ShowDialog("QUICKBIND_CONFIRM_BIND", items, {
        mainTextParams = {itemCount}
    })
end

function QuickBind.BindUncollectedItems(items)
    local boundCount = 0
    
    for _, item in ipairs(items) do
        BindItem(item.bagId, item.slotIndex)
        boundCount = boundCount + 1
    end
    
    d(string.format("QuickBind: Bound %d uncollected gear item(s).", boundCount))
end

function QuickBind.InitializeDialog()
    ZO_Dialogs_RegisterCustomDialog("QUICKBIND_CONFIRM_BIND",
    {
        title = {
            text = "QuickBind - Confirm Action"
        },
        mainText = {
            text = "Are you sure you want to bind <<1>> uncollected gear item(s) to your account? This action cannot be undone."
        },
        buttons = {
            {
                text = SI_DIALOG_CONFIRM,
                callback = function(dialog)
                    local items = dialog.data
                    QuickBind.BindUncollectedItems(items)
                end,
            },
            {
                text = SI_DIALOG_CANCEL,
            },
        },
    })
end

function QuickBind.InitializeSettings()
    local LAM = LibAddonMenu2
    if not LAM then return end
    
    local panelData = {
        type = "panel",
        name = "QuickBind",
        displayName = "QuickBind",
        author = "Lazy",
        version = "1.0.0",
        registerForRefresh = true,
    }
    
    LAM:RegisterAddonPanel("QuickBindSettings", panelData)
    
    local optionsData = {
        {
            type = "header",
            name = "Keybind Settings",
        },
        {
            type = "description",
            text = "To change keybinds, go to Settings > Controls > Keybindings > General > QuickBind",
        },
    }
    
    LAM:RegisterOptionControls("QuickBindSettings", optionsData)
end

function QuickBind.OnAddOnLoaded(event, name)
    if name ~= addonName then return end
    EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)

    -- Initialize confirmation dialog
    QuickBind.InitializeDialog()
    
    -- Initialize settings (optional, requires LibAddonMenu)
    QuickBind.InitializeSettings()

    -- Set default keybinds
    CreateDefaultActionBind("QUICKBIND_BIND_ITEM", KEY_SEMICOLON, KEY_INVALID, KEY_INVALID, KEY_INVALID, KEY_INVALID)
    CreateDefaultActionBind("QUICKBIND_BIND_UNCOLLECTED", KEY_BRACKET_LEFT, KEY_INVALID, KEY_INVALID, KEY_INVALID, KEY_INVALID)
end

EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, QuickBind.OnAddOnLoaded)