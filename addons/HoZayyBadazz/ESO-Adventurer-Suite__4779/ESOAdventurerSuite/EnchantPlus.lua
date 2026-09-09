-- Enchant+ integration adapted from the user-supplied EnchantPlus.lua.
-- Shared by Suite grid cells and native backpack/equipped-item context menus.
EASEnchantPlus = {}
local EP = EASEnchantPlus
local eventName = "EAS_EnchantPlus"

local function ItemIdentity(bag, slot)
    -- ESO returns opaque id64 values; compare their value, not object identity.
    return Id64ToString(GetItemUniqueId(bag, slot))
end

local function SameItem(bag, slot, uniqueId)
    return ItemIdentity(bag, slot) == uniqueId
end

local function SupportsTarget(bag, slot)
    return (bag == BAG_BACKPACK or bag == BAG_WORN)
        and slot ~= nil and IsItemEnchantable(bag, slot)
end

function EP.ClearGlyphTooltip(owner)
    if owner and EP.tooltipOwner ~= owner then return end
    EP.tooltipOwner = nil
    EP.tooltipSerial = (EP.tooltipSerial or 0) + 1
    if ItemTooltip then
        ClearTooltip(ItemTooltip)
        ItemTooltip:SetScale(1)
    end
end

function EP.ClearInventoryTooltips()
    EP.ClearGlyphTooltip()
    if ComparativeTooltip1 then ClearTooltip(ComparativeTooltip1) end
    if ComparativeTooltip2 then ClearTooltip(ComparativeTooltip2) end
end

-- Pick a free rectangle outside BOTH the root menu and glyph submenu.
-- This also handles the submenu opening to the left near the screen edge.
function EP.TooltipPlacement(left, top, right, bottom, width, height, screenW, screenH)
    local gap, margin = 12, 8
    local spaces = {
        {x=right+gap, y=margin, w=screenW-margin-right-gap, h=screenH-2*margin},
        {x=margin, y=margin, w=left-gap-margin, h=screenH-2*margin},
        {x=margin, y=bottom+gap, w=screenW-2*margin, h=screenH-margin-bottom-gap},
        {x=margin, y=margin, w=screenW-2*margin, h=top-gap-margin},
    }
    local best, scale = nil, 0
    for _, area in ipairs(spaces) do
        if area.w > 0 and area.h > 0 then
            local fit = math.min(1, area.w / math.max(1, width), area.h / math.max(1, height))
            if fit > scale then best, scale = area, fit end
        end
    end
    if not best then return nil end
    local x = math.max(best.x, math.min(left, best.x + best.w - width*scale))
    local y = math.max(best.y, math.min(top, best.y + best.h - height*scale))
    return x, y, scale
end

function EP.PositionGlyphTooltip(control)
    if EP.tooltipOwner ~= control then return end
    local left, top, right, bottom = control:GetLeft(), control:GetTop(), control:GetRight(), control:GetBottom()
    local function include(panel)
        if panel and not panel:IsHidden() then
            left = math.min(left, panel:GetLeft())
            top = math.min(top, panel:GetTop())
            right = math.max(right, panel:GetRight())
            bottom = math.max(bottom, panel:GetBottom())
        end
    end
    include(ZO_Menu)
    -- LibCustomMenu owns the submenu's placement; use its actual bounds.
    include(rawget(_G, "LibCustomMenuSubmenu"))
    local parent = control:GetParent()
    if parent and parent ~= GuiRoot and parent ~= ZO_Menu then include(parent) end
    local tip = ItemTooltip
    tip:SetScale(1)
    local x, y, scale = EP.TooltipPlacement(left, top, right, bottom,
        tip:GetWidth(), tip:GetHeight(), GuiRoot:GetWidth(), GuiRoot:GetHeight())
    if not x then EP.ClearGlyphTooltip(control); return end
    tip:SetScale(scale)
    tip:ClearAnchors()
    tip:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

function EP.ShowGlyphTooltip(control, link)
    EP.ClearInventoryTooltips()
    EP.tooltipOwner = control
    InitializeTooltip(ItemTooltip, GuiRoot, TOPLEFT, 0, 0, TOPLEFT)
    ItemTooltip:SetLink(link)
    EP.PositionGlyphTooltip(control)
    -- Tooltip height may settle after the current layout pass. No polling.
    local serial = EP.tooltipSerial
    zo_callLater(function()
        if EP.tooltipOwner == control and EP.tooltipSerial == serial then
            EP.PositionGlyphTooltip(control)
        end
    end, 0)
end

function EP.BuildGlyphEntries(bag, index)
    if not SupportsTarget(bag, index) then return {} end
    local targetId = ItemIdentity(bag, index)
    local itemList = PLAYER_INVENTORY:GenerateListOfVirtualStackedItems(
        INVENTORY_BACKPACK,
        function(glyphBag, glyphSlot)
            return CanItemTakeEnchantment(bag, index, glyphBag, glyphSlot)
        end
    )
    local glyphs = {}
    for _, itemInfo in pairs(itemList or {}) do
        local glyphBag, glyphSlot = itemInfo.bag, itemInfo.index
        if glyphBag ~= nil and glyphSlot ~= nil and CanItemTakeEnchantment(bag, index, glyphBag, glyphSlot) then
            glyphs[#glyphs + 1] = {
                bag = glyphBag, slot = glyphSlot,
                link = GetItemLink(glyphBag, glyphSlot),
                name = GetItemName(glyphBag, glyphSlot),
                id = ItemIdentity(glyphBag, glyphSlot),
                quality = GetItemDisplayQuality(glyphBag, glyphSlot),
            }
        end
    end
    table.sort(glyphs, function(a, b)
        if a.quality ~= b.quality then return a.quality > b.quality end
        if a.name ~= b.name then return a.name < b.name end
        return a.link < b.link
    end)

    local entries = {}
    for _, glyph in ipairs(glyphs) do
        local entry = glyph
        local function StillValid()
            return SameItem(bag, index, targetId)
                and SameItem(entry.bag, entry.slot, entry.id)
                and CanItemTakeEnchantment(bag, index, entry.bag, entry.slot)
        end
        local function DoEnchant()
            -- Inventory can change while a submenu or confirmation is open.
            if not StillValid() then return end
            if type(IsProtectedFunction) == "function" and IsProtectedFunction("EnchantItem") then
                CallSecureProtected("EnchantItem", bag, index, entry.bag, entry.slot)
            else
                EnchantItem(bag, index, entry.bag, entry.slot)
            end
        end
        local rarity = GetString("SI_ITEMDISPLAYQUALITY", entry.quality)
        local color = GetItemQualityColor(entry.quality)
        local name = zo_strformat(SI_TOOLTIP_ITEM_NAME, entry.name)
        entries[#entries + 1] = {
            label = color:Colorize(name .. " (" .. rarity .. ")"),
            normalColor = color,
            tooltip = function(control, inside)
                if inside then
                    EP.ShowGlyphTooltip(control, entry.link)
                else
                    EP.ClearGlyphTooltip(control)
                end
            end,
            callback = function()
                EP.ClearGlyphTooltip()
                if not StillValid() then return end
                if IsItemPlayerLocked(bag, index) then
                    ZO_Dialogs_ShowPlatformDialog("CONFIRM_ENCHANT_LOCKED_ITEM",
                        { onAcceptCallback = DoEnchant },
                        { mainTextParams = { GetString(SI_PERFORM_ACTION_CONFIRMATION) } })
                else
                    DoEnchant()
                end
            end,
        }
    end
    return entries
end

function EP.AddMenu(bag, index)
    if not SupportsTarget(bag, index) or type(AddCustomSubMenuItem) ~= "function" then return false end
    local entries = EP.BuildGlyphEntries(bag, index)
    if #entries == 0 then
        entries[1] = { label = "No compatible backpack glyphs", disabled = true, callback = function() end }
    end
    EP.ClearInventoryTooltips()
    AddCustomSubMenuItem("Enchant+", entries)
    return true
end

-- Filter the finished gear menu, without wrapping the native action builder or
-- changing any native OnSelect callback. Controls stay in their owning pools.
function EP.RemoveNativeEnchantEntry()
    local menu = ZO_Menu
    if not menu or not menu.items then return end
    local enchantName = GetString(SI_ITEM_ACTION_ENCHANT)
    local removed = false
    for i = #menu.items, 1, -1 do
        local entry = menu.items[i]
        local item = entry.item
        if item and item.nameLabel and item.nameLabel:GetText() == enchantName then
            item:SetHidden(true)
            if entry.checkbox then entry.checkbox:SetHidden(true) end
            table.remove(menu.items, i)
            removed = true
        end
    end
    if not removed then return end
    -- Re-anchor remaining rows and indices, including custom submenu controls.
    local previous = menu
    menu.height = 0
    for i, entry in ipairs(menu.items) do
        local item, checkbox = entry.item, entry.checkbox
        item.menuIndex = i
        item:ClearAnchors()
        local anchor = checkbox or item
        if checkbox then checkbox.menuIndex = i; checkbox:ClearAnchors() end
        if previous == menu then
            anchor:SetAnchor(TOPLEFT, menu, TOPLEFT, menu.menuPad, menu.menuPad + (entry.itemYPad or 0))
        else
            anchor:SetAnchor(TOPLEFT, previous, BOTTOMLEFT, 0, menu.spacing + (entry.itemYPad or 0))
        end
        if checkbox then item:SetAnchor(TOPLEFT, checkbox, TOPRIGHT, 0, 0) end
        previous = anchor
        menu.height = menu.height + (item.storedHeight or item:GetHeight()) + (entry.itemYPad or 0)
    end
    menu.nextAnchor = previous
    menu.currentIndex = #menu.items + 1
end

function EP.ContextMenuCallback(inventorySlot)
    if not inventorySlot then return end
    local bag, index = ZO_Inventory_GetBagAndIndex(inventorySlot)
    -- Only append Enchant+. Do not delete/re-anchor ESO's native menu entries:
    -- touching the stock item pool can contaminate protected callbacks such as
    -- TryUseItem -> UseItem on current ESO clients.
    EP.AddMenu(bag, index)
end

function EP.OnAddonLoaded(_, addonName)
    if addonName ~= "ESOAdventurerSuite" then return end
    EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_ADD_ON_LOADED)
    if EP.initialized then return end
    if not LibCustomMenu or type(LibCustomMenu.RegisterContextMenu) ~= "function" then return end
    LibCustomMenu:RegisterContextMenu(EP.ContextMenuCallback, LibCustomMenu.CATEGORY_LATE)
    EP.initialized = true
    SecurePostHook("ClearMenu", function()
        if EP.tooltipOwner then EP.ClearGlyphTooltip() end
    end)

end

EVENT_MANAGER:RegisterForEvent(eventName, EVENT_ADD_ON_LOADED, EP.OnAddonLoaded)
