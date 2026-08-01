CraftBagSession = {}
CraftBagSession.name = "CraftBagSession"

SV = nil

local attachments = {}

local function MailReadable (ec, id)
    attachments = {}

    local num = GetMailAttachmentInfo(id)
    for i = 1, num do
        local _, size = GetAttachedItemInfo(id, i)
        local link = GetAttachedItemLink(id, i, LINK_STYLE_DEFAULT)
        attachments[i] = { size=size, link=link}
    end
end

local function LootReceived (ec, rec, name, quantity, ...)
    if not CanItemLinkBeVirtual(name) then return end

    local itemid = name:match("|H.-:item:(.-):.-|h.-|h")

    if SV.stack[itemid] == nil then
        SV.stack[itemid] = quantity
    else
        SV.stack[itemid] = SV.stack[itemid] + quantity
    end
end

local function TakeSuccess (ec, id)
    for i = 1, #attachments do
        LootReceived (nil, nil, attachments[i].link, attachments[i].size or 1)
    end

    attachments = {}
end

local trade_info = {
    [1] = nil,
    [2] = nil,
    [3] = nil,
    [4] = nil,
    [5] = nil
}

local function OnTradeItemAdded (eventCode, who, tradeSlot, itemSoundCategory)
    if who ~= TRADE_THEM then return end

    local _, _, quantity, _ = GetTradeItemInfo(who, tradeSlot)

    trade_info[tradeSlot] = {link=GetTradeItemLink(who, tradeSlot), quantity=quantity}
end

local function OnTradeItemRemoved (eventCode, who, tradeSlot, itemSoundCategory)
    if who ~= TRADE_THEM then return end

    trade_info[tradeSlot] = nil
end

local function OnTradeSucceeded (...)
    for i = 1, 5 do
        if trade_info[i] ~= nil then
            LootReceived (nil, nil, trade_info[i].link, trade_info[i].quantity or 1)
        end
    end
end

local function GetCurrentSession ()
end

local function IsActiveSession ()
    return SV.session.active == true
end

local function HasFetched ()
    return SV.session.fetched == true
end

local function CloseSession ()
    SV.stack = {}
    SV.session.active = false
    SV.session.started = 0
    SV.session.fetched = false
end

local function StartSession ()
    SV.stack = {}
    SV.session.active = true
    SV.session.started = GetTimeStamp()
    SV.session.fetched = false
end

local looping = false

local function FetchSession ()
    if looping then return end

    -- do fetching stuff here
    local free_slots = GetNumBagFreeSlots()

    local needed_slots = 0
    -- first count, find out how many we need
    for itemid, quantity in pairs(SV.stack) do
        local _, max = GetSlotStackSize(BAG_VIRTUAL, itemid)

        local this_slots = quantity / max
        if quantity % max ~= 0 then this_slots = this_slots + 1 end
    end

    if needed_slots > free_slots then
        CHAT_SYSTEM:AddMessage("[CraftBagSession] Not enough bag space. Need " .. needed_slots .. " free, but only have " .. free_slots .. " available!")
        return
    end

    local function place (_i, _q)
        CallSecureProtected("PickupInventoryItem", BAG_VIRTUAL, _i, _q)

        -- get a free slot
        local slot = FindFirstEmptySlotInBag(BAG_BACKPACK)

        if slot == nil then
            CHAT_SYSTEM:AddMessage("[CraftBagSession] Fatal error: somehow out of bag slots!")
            return false
        end

        CallSecureProtected("PlaceInInventory", BAG_BACKPACK, slot)

        return true
    end

    local queue = {}

    for itemid, quantity in pairs(SV.stack) do
        local _, max = GetSlotStackSize(BAG_VIRTUAL, itemid)

        while quantity > 0 do
            if quantity < max then
                table.insert(queue, {itemid=itemid, quantity=quantity})
                quantity = 0
            else
                table.insert(queue, {itemid=itemid, quantity=max})
                quantity = quantity - max
            end
        end
    end

    local cur_index = 1

    local function looper ()
        if queue[cur_index] == nil then
            CHAT_SYSTEM:AddMessage("[CraftBagStore] Finished fetching items for this session!")

            SV.session.fetched = true
            looping = false

            return
        end

        local i = queue[cur_index]

        if not place(i.itemid, i.quantity) then return end

        cur_index = cur_index + 1

        zo_callLater(looper, 300)
    end

    looping = true

    looper()
end

local function timediff (secs)
    local function divmod (a, b)
        return math.floor(a/b), a%b
    end

    local weeks, secs = divmod(secs, 7*24*60*60)
    if weeks == 0 then weeks = nil end
    local days, secs = divmod(secs, 24*60*60)
    if days == 0 then days = nil end
    local hours, secs = divmod(secs, 60*60)
    if hours == 0 then hours = nil end
    local minutes, secs = divmod(secs, 60)
    if minutes == 0 then minutes = nil end

    local n_t = ""

    if weeks then
        n_t = n_t .. weeks .. " weeks, "
    end
    if days then
        n_t = n_t .. days .. " days, "
    end
    if hours then
        n_t = n_t .. hours .. " hours, "
    end
    if minutes then
        n_t = n_t .. minutes .. " minutes, "
    end
    n_t = n_t .. secs .. " seconds ago."

    return n_t
end

local function ShowSession ()
    -- lala client trust reliance that there is a session lol
    local now = GetTimeStamp()
    CHAT_SYSTEM:AddMessage("[CraftBagSession] Session started " .. timediff(now - SV.session.started) .. ":")

    local total = 0

    for k, v in pairs(SV.stack) do
        total = total + v
        CHAT_SYSTEM:AddMessage(v .. "x " .. GetItemLink(BAG_VIRTUAL, k, LINK_STYLE_BRACKETS))
    end

    if total == 0 then
        CHAT_SYSTEM:AddMessage("[CraftBagSession] No items gathered yet.")
    else
        CHAT_SYSTEM:AddMessage("[CraftBagSession] Total of " .. total .. " items gathered.")
    end
end

local function SlashCommandHandler (options)
    options = options:lower()

    if options:match("start") then
        if IsActiveSession() then
            CHAT_SYSTEM:AddMessage("[CraftBagSession] Close out the current session before starting the new one with /cbs stop.")
        else
            StartSession()
            CHAT_SYSTEM:AddMessage("[CraftBagSession] Session started. Type /cbs show to see items.")
        end
    elseif options:match("show") then
        if not IsActiveSession() then
            CHAT_SYSTEM:AddMessage("[CraftBagSession] No active session to show.")
        else
            ShowSession()
        end
    elseif options:match("stop") then
        if IsActiveSession() then
            if HasFetched() then
                CloseSession()
                CHAT_SYSTEM:AddMessage("[CraftBagSession] Session closed.")
            else
                CHAT_SYSTEM:AddMessage("[CraftBagSession] Use /cbs fetch to fetch your items before stopping a session. To start a new session and disregard the current one, use /cbs clear.")
            end
        else
            CHAT_SYSTEM:AddMessage("[CraftBagSession] No active session to stop.")
        end
    elseif options:match("clear") then
        CloseSession()
        CHAT_SYSTEM:AddMessage("[CraftBagSession] Session closed.")
    elseif options:match("fetch") then
        if IsActiveSession() then
            FetchSession()
        else
            CHAT_SYSTEM:AddMessage("[CraftBagSession] No active session to fetch items for.")
        end
    end
end

function CraftBagSession:Initialize()
    SV = ZO_SavedVars:New("CraftBagSession_SavedVariables", 1, nil, {["stack"] = {}, ["session"] = {active=false, started=nil, fetched=false}})

    SLASH_COMMANDS["/cbs"] = SlashCommandHandler

    EVENT_MANAGER:RegisterForEvent(CraftBagSession.name, EVENT_MAIL_READABLE, MailReadable)
    EVENT_MANAGER:RegisterForEvent(CraftBagSession.name, EVENT_LOOT_RECEIVED, LootReceived)
    EVENT_MANAGER:RegisterForEvent(CraftBagSession.name, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, TakeSuccess)
    EVENT_MANAGER:RegisterForEvent(CraftBagSession.name, EVENT_TRADE_ITEM_ADDED, OnTradeItemAdded)
    EVENT_MANAGER:RegisterForEvent(CraftBagSession.name, EVENT_TRADE_ITEM_REMOVED, OnTradeItemRemoved)
    EVENT_MANAGER:RegisterForEvent(CraftBagSession.name, EVENT_TRADE_ITEM_UPDATED, OnTradeItemAdded)
    EVENT_MANAGER:RegisterForEvent(CraftBagSession.name, EVENT_TRADE_SUCCEEDED, OnTradeSucceeded)
end
 
function CraftBagSession.OnAddOnLoaded(event, addonName)
    if addonName == CraftBagSession.name then
        CraftBagSession:Initialize()
    end
end
 
EVENT_MANAGER:RegisterForEvent(CraftBagSession.name, EVENT_ADD_ON_LOADED, CraftBagSession.OnAddOnLoaded)
