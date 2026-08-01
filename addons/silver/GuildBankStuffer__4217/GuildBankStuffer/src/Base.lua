GuildBankStuffer = {
    name = "GuildBankStuffer",
    -- Used globals
    G = {
        ItemTypesToStack = {
            [ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = true,
            [ITEMTYPE_BLACKSMITHING_MATERIAL] = true,
            [ITEMTYPE_BLACKSMITHING_BOOSTER] = true,
            [ITEMTYPE_CLOTHIER_RAW_MATERIAL] = true,
            [ITEMTYPE_CLOTHIER_MATERIAL] = true,
            [ITEMTYPE_CLOTHIER_BOOSTER] = true,
            [ITEMTYPE_WOODWORKING_RAW_MATERIAL] = true,
            [ITEMTYPE_WOODWORKING_MATERIAL] = true,
            [ITEMTYPE_WOODWORKING_BOOSTER] = true,
            [ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = true,
            [ITEMTYPE_JEWELRYCRAFTING_MATERIAL] = true,
            [ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER] = true,
            [ITEMTYPE_JEWELRYCRAFTING_BOOSTER] = true,
            [ITEMTYPE_POTION_BASE] = true,
            [ITEMTYPE_POISON_BASE] = true,
            [ITEMTYPE_REAGENT] = true,
            [ITEMTYPE_ENCHANTING_RUNE_ASPECT] = true,
            [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = true,
            [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = true,
            [ITEMTYPE_INGREDIENT] = true,
            [ITEMTYPE_STYLE_MATERIAL] = true,
            [ITEMTYPE_RAW_MATERIAL] = true,
            [ITEMTYPE_WEAPON_TRAIT] = true,
            [ITEMTYPE_ARMOR_TRAIT] = true,
            [ITEMTYPE_JEWELRY_TRAIT] = true,
            [ITEMTYPE_JEWELRY_RAW_TRAIT] = true,
            [ITEMTYPE_FURNISHING_MATERIAL] = true,
            [ITEMTYPE_LURE] = true,
        },
        SLASH_COMMANDS = SLASH_COMMANDS,
        SCENE_MANAGER = SCENE_MANAGER,
        WINDOW_MANAGER = WINDOW_MANAGER,
        KEYBIND_STRIP = KEYBIND_STRIP,
        EVENT_MANAGER = EVENT_MANAGER,
        SHARED_INVENTORY = SHARED_INVENTORY,
        EVENT_ADD_ON_LOADED = EVENT_ADD_ON_LOADED,
        EVENT_GUILD_BANK_ITEM_ADDED = EVENT_GUILD_BANK_ITEM_ADDED,
        EVENT_GUILD_BANK_ITEM_REMOVED = EVENT_GUILD_BANK_ITEM_REMOVED,
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE = EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        EVENT_OPEN_GUILD_BANK = EVENT_OPEN_GUILD_BANK,
        EVENT_CLOSE_GUILD_BANK = EVENT_CLOSE_GUILD_BANK,
        EVENT_GUILD_BANK_TRANSFER_ERROR = EVENT_GUILD_BANK_TRANSFER_ERROR,
        KEYBIND_STRIP_ALIGN_LEFT = KEYBIND_STRIP_ALIGN_LEFT,
        KEYBIND_STRIP_ALIGN_RIGHT = KEYBIND_STRIP_ALIGN_RIGHT,
        BAG_BACKPACK = BAG_BACKPACK,
        BAG_GUILDBANK = BAG_GUILDBANK,
        TOPLEFT = TOPLEFT,
        BOTTOMLEFT = BOTTOMLEFT,
        CT_LABEL = CT_LABEL,
        GetItemLink = GetItemLink,
        GetItemId = GetItemId,
        GetItemTrait = GetItemTrait,
        TransferToGuildBank = TransferToGuildBank,
        TransferFromGuildBank = TransferFromGuildBank,
        CallSecureProtected = CallSecureProtected,
        StackBag = StackBag,
        GetSlotStackSize = GetSlotStackSize,
        ZO_SavedVars = ZO_SavedVars,
        ZO_PreHook = ZO_PreHook,
        ZO_CreateStringId = ZO_CreateStringId,
        ZO_AlphaAnimation = ZO_AlphaAnimation,
        zo_callLater = zo_callLater,
        debug = d,
    },
    constants = {
        ZO_InventorySlot_OnMouseEnter = "ZO_InventorySlot_OnMouseEnter",
        ZO_InventorySlot_OnMouseExit = "ZO_InventorySlot_OnMouseExit",
        RequestMoveItem = "RequestMoveItem",
        GUILDBANKSTUFFER_SAVED_VARIABLES = "GuildBankStufferVariables",
    },
    state = {
        active = false,
        ---@type SlotItem
        hoveredItem = nil,
    },

    ---@class SlotItem
    ---@field slotIndex number
    ---@field bagId number
    ---@field itemType number
    ---@field itemInstanceId number
    ---@field stolen boolean
    ---@field stack number
    ---@field maxStack number
    ---@field markedForDeposit boolean
    ---@field stackable boolean
    ---@field withdrawingFullStack boolean
    ---@field withdrawingToStackOnly boolean
    SlotItemClass = nil,

    ---@class Callable
    ---@field key string
    ---@field label string
    ---@field callback function
    ---@field keybindPosition string
    ---@field keybindIndex number
    ---@field visible function
    ---@field showInGui boolean
    CallableClass = nil,

    ---@class GuildBankStufferWindowControl
    ---@field DoFadeIn function
    ---@field DoFadeOut function
    GuildBankStufferWindowControl = function() return GuildBankStufferWindowControl end,
};

---@type table<number, Callable>
GuildBankStuffer.callables = {
    [1] = {
        key = "GUILDBANKSTUFFER_START_WITHDRAW",
        label = "Stack and deposit",
        callback = function() GuildBankStuffer:StartTransferFromGuildBank(); end,
        showInGui = true,
    },
    [2] = {
        key = "GUILDBANKSTUFFER_START_DEPOSIT",
        label = "Deposit only",
        callback = function() GuildBankStuffer:StartTransferToGuildBank(); end,
        showInGui = true,
    },
    [3] = {
        key = "GUILDBANKSTUFFER_MARK_DEPOSIT",
        label = "Mark deposit",
        -- Actually called from keyboard shortcut (Bindings.xml), as it requires hovering an item
        callback = GuildBankStuffer.MarkDeposit,
        keybindPosition = "right",
        keybindIndex = 1,
        visible = function() return GuildBankStuffer.state.hoveredItem and not GuildBankStuffer.savedVariables.items[GuildBankStuffer.G.GetItemId(GuildBankStuffer.state.hoveredItem.bagId, GuildBankStuffer.state.hoveredItem.slotIndex)] end,
        showInGui = false,
    },
    [4] = {
        key = "GUILDBANKSTUFFER_UNMARK_DEPOSIT",
        label = "Unmark deposit",
        -- Actually called from keyboard shortcut (Bindings.xml), as it requires hovering an item
        callback = GuildBankStuffer.UnmarkDeposit,
        keybindPosition = "right",
        keybindIndex = 2,
        visible = function() return GuildBankStuffer.state.hoveredItem and GuildBankStuffer.savedVariables.items[GuildBankStuffer.G.GetItemId(GuildBankStuffer.state.hoveredItem.bagId, GuildBankStuffer.state.hoveredItem.slotIndex)] end,
        showInGui = false,
    },
};

GuildBankStuffer.keybinds = (function()
    local keybinds = {
        right = {
            alignment = GuildBankStuffer.G.KEYBIND_STRIP_ALIGN_RIGHT,
        },
    }

    for _, value in pairs(GuildBankStuffer.callables) do
        if value.keybindPosition then
            keybinds[value.keybindPosition][value.keybindIndex] = {
                name = value.label,
                keybind = value.key,
                control = nil,
                callback = value.callback,
                visible = value.visible,
            };
        end
    end

    return keybinds;
end)();

---@param content string
---@param flag boolean
function GuildBankStuffer:Debug(content, flag)
    if flag then self.G.debug("GuildBankStuffer - " .. content) end
end;

---@param bag1 number bag type
---@param bag2 number bag type
---@return table<string, SlotItem>
function GuildBankStuffer:GetItemData(...)
    return self.G.SHARED_INVENTORY:GenerateFullSlotData(nil, ...);
end;

function GuildBankStuffer:Unregister(event)
    self.G.EVENT_MANAGER:UnregisterForEvent(self.name, event);
end;

function GuildBankStuffer:UnregisterTransfer()
    self:Unregister(self.G.EVENT_GUILD_BANK_ITEM_ADDED);
    self:Unregister(self.G.EVENT_GUILD_BANK_ITEM_REMOVED);
end;

function GuildBankStuffer:EventCallback(event, callback)
    self.G.EVENT_MANAGER:RegisterForEvent(self.name, event, function(...)
        self:Unregister(event);
        callback(...);
    end);
end;

function GuildBankStuffer:InitEvents()
    self.G.EVENT_MANAGER:RegisterForEvent(self.Name, self.G.EVENT_OPEN_GUILD_BANK, function()
        self.G.KEYBIND_STRIP:AddKeybindButtonGroup(self.keybinds.right);
        self.state.active = true;

        if self.savedVariables.showWindowOnOpen then
            self.G.zo_callLater(function() self.GuildBankStufferWindowControl().DoFadeIn() end, 200);
        end
    end);

    self.G.EVENT_MANAGER:RegisterForEvent(self.Name, self.G.EVENT_CLOSE_GUILD_BANK, function()
        self.G.KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybinds.right);
        self.state.active = false;
        self.GuildBankStufferWindowControl().DoFadeOut();
        self:UnregisterTransfer();
    end);

    self.G.EVENT_MANAGER:RegisterForEvent(self.name, self.G.EVENT_GUILD_BANK_TRANSFER_ERROR, function(_, errorCode)
        self.G.debug("Error: " .. errorCode);
        self:UnregisterTransfer();
    end);

    self.G.SLASH_COMMANDS["/guildbankstuffer"] = function()
        self.GuildBankStufferWindowControl().DoFadeIn();
    end
end;

function GuildBankStuffer:InitHooks()
    self.G.ZO_PreHook(self.constants.ZO_InventorySlot_OnMouseEnter, function(inventorySlot)
        if self.state.active and inventorySlot.dataEntry then
            self.state.hoveredItem = inventorySlot.dataEntry.data;

            self.G.KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybinds.right);
        end
    end);

    self.G.ZO_PreHook(self.constants.ZO_InventorySlot_OnMouseExit, function()
        if self.state.active then
            self.state.hoveredItem = nil;
            self.G.KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybinds.right);
        end
    end);
end;

function GuildBankStuffer:InitVariables()
    for _, value in pairs(GuildBankStuffer.callables) do
        self.G.ZO_CreateStringId("SI_BINDING_NAME_" .. value.key, value.label);
    end

    self.savedVariables = self.G.ZO_SavedVars:NewAccountWide(self.constants.GUILDBANKSTUFFER_SAVED_VARIABLES, 1, self.name, self.savedVariables);
end;
