function GuildBankStuffer:Init()
    GuildBankStuffer:InitVariables();
    GuildBankStuffer:InitEvents();
    GuildBankStuffer:InitHooks();
    GuildBankStuffer:InitGui();
end;

-- Process description: While guild bank is open, hover over items and use a keyboard shortcut to "Mark them for deposit". Then click the buttons on the left to stack and deposit everything you have marked.

function GuildBankStuffer:MarkDeposit()
    local itemId = self.G.GetItemId(self.state.hoveredItem.bagId, self.state.hoveredItem.slotIndex);
    local trait = self.G.GetItemTrait(self.state.hoveredItem.bagId, self.state.hoveredItem.slotIndex);

    self.savedVariables.items[itemId] = {
        trait = trait,
        itemType = self.state.hoveredItem.itemType,
    };

    self.G.KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybinds.right);

    if self.state.hoveredItem.bagId == self.G.BAG_BACKPACK then
        self:StartTransferFromGuildBank();
    end
end;

function GuildBankStuffer:UnmarkDeposit()
    local itemId = self.G.GetItemId(self.state.hoveredItem.bagId, self.state.hoveredItem.slotIndex);

    self.savedVariables.items[itemId] = nil;

    self.G.KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybinds.right);

    if self.state.hoveredItem.bagId == self.G.BAG_GUILDBANK then
        self.G.TransferFromGuildBank(self.state.hoveredItem.slotIndex);
    end
end;

function GuildBankStuffer:StartTransferFromGuildBank()
    self:UnregisterTransfer();
    self:HandleItems(self:GetItemsToMove());
end;

function GuildBankStuffer:StartTransferToGuildBank()
    self:UnregisterTransfer();
    self:HandleItems(self:GetItemsToMove(true));
end;

---@param items table<number, table<number, SlotItem>>
function GuildBankStuffer:HandleItems(items)
    if self.savedVariables.debugTotals and table.getn(items) % 10 == 0 then
        self:Debug(table.getn(items) .. " items remaining", true);
    end

    local itemsInner = table.remove(items);

    if itemsInner then
        self:HandleItemsInner(items, itemsInner);
    end
end;

---@param items table<number, table<number, SlotItem>>
---@param itemsInner table<number, SlotItem>
function GuildBankStuffer:HandleItemsInner(items, itemsInner)
    local item = table.remove(itemsInner, 1);
    local nextItem = itemsInner[1];

    if  item
        and item.bagId == self.G.BAG_GUILDBANK
        and self.G.ItemTypesToStack[item.itemType]
    then
        self:EventCallback(self.G.EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(eventCode, bagId, slotIndex)
            item.bagId = bagId;
            item.slotIndex = slotIndex;
            table.insert(itemsInner, item);

            self:HandleItemsInner(items, itemsInner);
        end);

        self:Debug("Withdrawing " .. self.G.GetItemLink(item.bagId, item.slotIndex), self.savedVariables.debug);

        self.G.TransferFromGuildBank(item.slotIndex);
    elseif
        item
        and item.bagId == self.G.BAG_BACKPACK
        and nextItem
        and item.stack ~= item.maxStack
        and nextItem.stack ~= nextItem.maxStack
    then
        self:Debug("Stacking " .. self.G.GetItemLink(item.bagId, item.slotIndex), self.savedVariables.debug);
        self:RequestMoveItem(item, nextItem);
        self:HandleItemsInner(items, itemsInner);
    elseif
        item
        and item.bagId == self.G.BAG_BACKPACK
        and (item.markedForDeposit or item.withdrawingToStackOnly)
        and (item.stack ~= item.maxStack or not self.savedVariables.withdrawFullStacks or not item.stackable)
    then
        self:EventCallback(self.G.EVENT_GUILD_BANK_ITEM_ADDED, function()
            self:HandleItemsInner(items, itemsInner);
        end);

        self:Debug("Depositing " .. self.G.GetItemLink(item.bagId, item.slotIndex), self.savedVariables.debug);

        self.G.TransferToGuildBank(item.bagId, item.slotIndex);
    elseif nextItem then
        self:HandleItemsInner(items, itemsInner);
    else
        self:HandleItems(items);
    end
end;

---@param depositOnly boolean
function GuildBankStuffer:GetItemsToMove(depositOnly)
    ---@type table<number, table<number, SlotItem>>
    local items = {};

    local itemData = depositOnly and self:GetItemData(self.G.BAG_BACKPACK) or self:GetItemData(self.G.BAG_GUILDBANK, self.G.BAG_BACKPACK);

    for _, item in pairs(itemData) do
        local stack, maxStack = self.G.GetSlotStackSize(item.bagId, item.slotIndex);
        local itemId = self.G.GetItemId(item.bagId, item.slotIndex);
        item.stack = stack;
        item.maxStack = maxStack;
        item.markedForDeposit = self.savedVariables.items[itemId];
        item.stackable = self.G.ItemTypesToStack[item.itemType];
        item.withdrawingFullStack = stack == maxStack and self.savedVariables.withdrawFullStacks and item.bagId == self.G.BAG_GUILDBANK and item.stackable;
        item.withdrawingToStackOnly = self.savedVariables.stackAllItems and item.stackable and item.bagId == self.G.BAG_GUILDBANK and not item.markedForDeposit;

        if  stack ~= 0
            and not item.stolen
            and (stack ~= maxStack or item.withdrawingFullStack or not item.stackable)
            and (item.stackable or item.bagId == self.G.BAG_BACKPACK)
            and (item.markedForDeposit or item.withdrawingToStackOnly)
        then
            items[itemId] = items[itemId] or {};

            if item.bagId == self.G.BAG_GUILDBANK then
                table.insert(items[itemId], 1, item);
            else
                table.insert(items[itemId], item);
            end
        end
    end

    ---@type table<number, table<number, SlotItem>>
    local itemsFinal = {};

    for _, itemsInner in pairs(items) do
        local firstItem = itemsInner[1];
        if table.getn(itemsInner) > 1 or firstItem.bagId ~= self.G.BAG_GUILDBANK or firstItem.withdrawingFullStack then
            table.insert(itemsFinal, itemsInner);
        end
    end

    self:Debug("Found " .. table.getn(itemsFinal) .. " items", self.savedVariables.debugTotals);

    return itemsFinal;
end;

---@param from SlotItem
---@param to   SlotItem
function GuildBankStuffer:RequestMoveItem(from, to)
    local over = from.stack + to.stack - from.maxStack;
    local size = over > 0 and from.stack - over or from.stack;

    self.G.CallSecureProtected(self.constants.RequestMoveItem, from.bagId, from.slotIndex, to.bagId, to.slotIndex, size);
    to.stack = to.stack + size;
end;

GuildBankStuffer.G.EVENT_MANAGER:RegisterForEvent(GuildBankStuffer.name, GuildBankStuffer.G.EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName == GuildBankStuffer.name then
        GuildBankStuffer:Unregister(GuildBankStuffer.G.EVENT_ADD_ON_LOADED);
        GuildBankStuffer:Init();
    end
end);
