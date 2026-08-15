-- MailMule: Send crafting materials and gold via in-game mail
-- Author: MATREX-X
-- Usage:
--   /sendmats                  -> send all materials to the saved recipient
--   /sendmats gold <amount>    -> attach gold to the next mail
--   /sendmats to <@handle>     -> change recipient
--   /sendmats show / hide      -> toggle the smiley panel
--   /sendmats status           -> show recipient / queue / state
--   /sendmats help             -> show all commands

MailMule = {}
local ADDON_NAME = "MailMule"
local MAIL_ITEM_SLOTS = 5  -- ESO: 5 attached items + 1 gold slot per mail

local defaults = {
    recipient = "MATREX-X",  -- Console UserID has no @ prefix; PC accounts use @Handle
    subject = "Materials",
    body = "Auto-sent by MailMule",
    pendingGold = 0,
}

local state = {
    queue = {},
    sending = false,
    atMailbox = false,
}

----------------------------------------------------------------
-- Material type table (built defensively so missing constants
-- in any API version do not crash the addon at load time)
----------------------------------------------------------------

local MATERIAL_ITEM_TYPES = {}

local function RegisterMaterialType(name)
    local v = _G[name]
    if v ~= nil then
        MATERIAL_ITEM_TYPES[v] = true
    end
end

RegisterMaterialType("ITEMTYPE_BLACKSMITHING_MATERIAL")
RegisterMaterialType("ITEMTYPE_BLACKSMITHING_RAW_MATERIAL")
RegisterMaterialType("ITEMTYPE_BLACKSMITHING_BOOSTER")
RegisterMaterialType("ITEMTYPE_CLOTHIER_MATERIAL")
RegisterMaterialType("ITEMTYPE_CLOTHIER_RAW_MATERIAL")
RegisterMaterialType("ITEMTYPE_CLOTHIER_BOOSTER")
RegisterMaterialType("ITEMTYPE_WOODWORKING_MATERIAL")
RegisterMaterialType("ITEMTYPE_WOODWORKING_RAW_MATERIAL")
RegisterMaterialType("ITEMTYPE_WOODWORKING_BOOSTER")
RegisterMaterialType("ITEMTYPE_JEWELRYCRAFTING_MATERIAL")
RegisterMaterialType("ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL")
RegisterMaterialType("ITEMTYPE_JEWELRYCRAFTING_BOOSTER")
RegisterMaterialType("ITEMTYPE_POTION_BASE")
RegisterMaterialType("ITEMTYPE_POISON_BASE")
RegisterMaterialType("ITEMTYPE_REAGENT")
RegisterMaterialType("ITEMTYPE_INGREDIENT")
RegisterMaterialType("ITEMTYPE_ENCHANTING_RUNE_ASPECT")
RegisterMaterialType("ITEMTYPE_ENCHANTING_RUNE_ESSENCE")
RegisterMaterialType("ITEMTYPE_ENCHANTING_RUNE_POTENCY")
RegisterMaterialType("ITEMTYPE_STYLE_MATERIAL")
RegisterMaterialType("ITEMTYPE_RAW_MATERIAL")
RegisterMaterialType("ITEMTYPE_TRAIT_MATERIAL")
RegisterMaterialType("ITEMTYPE_TRAIT_ITEM")

----------------------------------------------------------------
-- Small helpers
----------------------------------------------------------------

local function ChatMsg(msg)
    if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
        CHAT_SYSTEM:AddMessage("|cFFD700[MailMule]|r " .. tostring(msg))
    end
end

local function SafeCall(fn, ...)
    if type(fn) == "function" then return fn(...) end
    return nil
end

local function GetCarriedGold()
    if GetCurrencyAmount and CURT_MONEY and CURRENCY_LOCATION_CHARACTER then
        return GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER) or 0
    end
    if GetCarriedCurrencyAmount and CURT_MONEY then
        return GetCarriedCurrencyAmount(CURT_MONEY) or 0
    end
    return 0
end

----------------------------------------------------------------
-- Material detection
----------------------------------------------------------------

local function IsSendableMaterial(bagId, slotIndex)
    if SafeCall(IsItemBound, bagId, slotIndex) then return false end
    if SafeCall(IsItemPlayerLocked, bagId, slotIndex) then return false end
    if SafeCall(IsItemStolen, bagId, slotIndex) then return false end
    local itemType = GetItemType(bagId, slotIndex)
    return MATERIAL_ITEM_TYPES[itemType] == true
end

local function CollectMaterials()
    local list = {}
    local bagSize = GetBagSize(BAG_BACKPACK) or 0
    for slot = 0, bagSize - 1 do
        if GetItemLink(BAG_BACKPACK, slot) ~= "" and IsSendableMaterial(BAG_BACKPACK, slot) then
            table.insert(list, { bagId = BAG_BACKPACK, slotIndex = slot })
        end
    end
    return list
end

----------------------------------------------------------------
-- Mail sending
----------------------------------------------------------------

local function ClearAttachments()
    for i = 1, MAIL_ITEM_SLOTS do
        if RemoveMailAttachment then
            pcall(RemoveMailAttachment, i)
        end
    end
    if QueueMoneyAttachment then
        pcall(QueueMoneyAttachment, 0)
    end
end

local function SendNextBatch()
    if #state.queue == 0 then
        state.sending = false
        ChatMsg("Done. Queue empty.")
        return
    end

    if not state.atMailbox then
        state.sending = false
        ChatMsg("|cFF6060Stop:|r open a mailbox to continue. " .. #state.queue .. " items left in queue.")
        return
    end

    ClearAttachments()

    local attached = 0
    for slot = 1, MAIL_ITEM_SLOTS do
        if #state.queue == 0 then break end
        local item = table.remove(state.queue, 1)
        if GetItemLink(item.bagId, item.slotIndex) ~= "" then
            local ok = pcall(SetMailAttachedItem, slot, item.bagId, item.slotIndex)
            if ok then attached = attached + 1 end
        end
    end

    local sv = MailMule.savedVars
    local gold = sv.pendingGold or 0
    if gold > 0 and QueueMoneyAttachment then
        local maxGold = GetCarriedGold()
        local toSend = math.min(gold, maxGold)
        pcall(QueueMoneyAttachment, toSend)
        sv.pendingGold = 0
        ChatMsg("Attaching " .. toSend .. " gold.")
    end

    if attached == 0 then
        state.sending = false
        ChatMsg("No items could be attached. Aborting.")
        return
    end

    ChatMsg("Sending " .. attached .. " items to " .. sv.recipient .. " ...")
    pcall(RequestSendMail, sv.recipient, sv.subject, sv.body)
end

----------------------------------------------------------------
-- Public: start sending
----------------------------------------------------------------

function MailMule.Start()
    if state.sending then
        ChatMsg("Already sending. Use /sendmats status.")
        return
    end
    if not state.atMailbox then
        ChatMsg("|cFF6060Open a mailbox first|r, then click Send again.")
        return
    end
    state.queue = CollectMaterials()
    if #state.queue == 0 then
        ChatMsg("No materials found in your backpack.")
        return
    end
    state.sending = true
    ChatMsg("Found " .. #state.queue .. " stacks. Sending in batches of " .. MAIL_ITEM_SLOTS .. ".")
    SendNextBatch()
end

----------------------------------------------------------------
-- Event handlers
----------------------------------------------------------------

local function OnMailSendSuccess()
    ChatMsg("|cAAFFAAMail sent.|r " .. #state.queue .. " items left.")
    if #state.queue > 0 then
        zo_callLater(SendNextBatch, 1500)
    else
        state.sending = false
        ChatMsg("All materials mailed.")
    end
end

local function OnMailSendFailed(_, reason)
    state.sending = false
    ChatMsg("|cFF6060Mail failed.|r Code " .. tostring(reason) .. ". " .. #state.queue .. " items left.")
end

local function OnMailboxOpen()
    state.atMailbox = true
    ShowMailKeybind()
end

local function OnMailboxClose()
    state.atMailbox = false
    HideMailKeybind()
end

----------------------------------------------------------------
-- UI window
----------------------------------------------------------------

local function CreateUI()
    if MailMule.window then return MailMule.window end
    local wm = WINDOW_MANAGER

    local window = wm:CreateTopLevelWindow("MailMuleWindow")
    window:SetDimensions(300, 360)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetClampedToScreen(true)
    window:SetHandler("OnMoveStop", function(self) self:StopMovingOrResizing() end)

    local bg = wm:CreateControl("$(parent)Bg", window, CT_BACKDROP)
    bg:SetAnchorFill(window)
    bg:SetCenterColor(0, 0, 0, 0.88)
    bg:SetEdgeColor(1, 0.84, 0, 1)
    bg:SetEdgeTexture("", 1, 1, 1, 0)

    local title = wm:CreateControl("$(parent)Title", window, CT_LABEL)
    title:SetAnchor(TOP, window, TOP, 0, 14)
    title:SetFont("ZoFontWinH3")
    title:SetText("MailMule")
    title:SetColor(1, 0.84, 0, 1)

    -- A label-only smiley face (no external textures = no missing-file risk)
    local smiley = wm:CreateControl("$(parent)Smiley", window, CT_LABEL)
    smiley:SetAnchor(TOP, title, BOTTOM, 0, 24)
    smiley:SetDimensions(128, 128)
    smiley:SetFont("ZoFontWinH1")
    smiley:SetText(":)")
    smiley:SetColor(1, 0.84, 0, 1)
    smiley:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    smiley:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local sendBtn = wm:CreateControl("$(parent)SendBtn", window, CT_BUTTON)
    sendBtn:SetAnchor(TOP, smiley, BOTTOM, 0, 30)
    sendBtn:SetDimensions(220, 46)
    sendBtn:SetFont("ZoFontWinH4")
    sendBtn:SetNormalFontColor(1, 1, 1, 1)
    sendBtn:SetMouseOverFontColor(1, 0.84, 0, 1)
    sendBtn:SetPressedFontColor(0.6, 0.6, 0.6, 1)
    sendBtn:SetText("Send Materials")
    sendBtn:SetHandler("OnClicked", function() MailMule.Start() end)

    local btnBg = wm:CreateControl("$(parent)SendBtnBg", sendBtn, CT_BACKDROP)
    btnBg:SetAnchorFill(sendBtn)
    btnBg:SetCenterColor(0.15, 0.15, 0.15, 1)
    btnBg:SetEdgeColor(1, 0.84, 0, 1)
    btnBg:SetEdgeTexture("", 1, 1, 1, 0)
    btnBg:SetDrawLevel(0)
    sendBtn:SetDrawLevel(1)

    local closeBtn = wm:CreateControl("$(parent)CloseBtn", window, CT_BUTTON)
    closeBtn:SetAnchor(TOPRIGHT, window, TOPRIGHT, -8, 8)
    closeBtn:SetDimensions(28, 28)
    closeBtn:SetFont("ZoFontWinH4")
    closeBtn:SetText("X")
    closeBtn:SetNormalFontColor(1, 0.4, 0.4, 1)
    closeBtn:SetMouseOverFontColor(1, 0.2, 0.2, 1)
    closeBtn:SetHandler("OnClicked", function() window:SetHidden(true) end)

    MailMule.window = window
    return window
end

function MailMule.ShowWindow()
    local w = MailMule.window or CreateUI()
    w:SetHidden(false)
end

function MailMule.HideWindow()
    if MailMule.window then MailMule.window:SetHidden(true) end
end

function MailMule.ToggleWindow()
    local w = MailMule.window or CreateUI()
    w:SetHidden(not w:IsHidden())
end

----------------------------------------------------------------
-- Slash command
----------------------------------------------------------------

local function HandleSlashCommand(rawArgs)
    local args = {}
    for word in string.gmatch(rawArgs or "", "%S+") do
        table.insert(args, word)
    end

    local sv = MailMule.savedVars
    local cmd = args[1]

    if cmd == nil or cmd == "" then
        MailMule.Start()
    elseif cmd == "to" and args[2] then
        sv.recipient = args[2]
        ChatMsg("Recipient set to " .. sv.recipient)
    elseif cmd == "gold" and args[2] then
        local amount = tonumber(args[2])
        if amount and amount >= 0 then
            sv.pendingGold = amount
            ChatMsg("Will attach " .. amount .. " gold to next mail.")
        else
            ChatMsg("Bad amount. Example: /sendmats gold 50000")
        end
    elseif cmd == "status" then
        ChatMsg("Recipient: " .. tostring(sv.recipient))
        ChatMsg("Pending gold: " .. tostring(sv.pendingGold or 0))
        ChatMsg("Queue: " .. #state.queue .. " | Sending: " .. tostring(state.sending) .. " | At mailbox: " .. tostring(state.atMailbox))
    elseif cmd == "show" then
        MailMule.ShowWindow()
    elseif cmd == "hide" then
        MailMule.HideWindow()
    elseif cmd == "help" then
        ChatMsg("/sendmats                  -> send materials")
        ChatMsg("/sendmats gold <amount>    -> include gold")
        ChatMsg("/sendmats to <@handle>     -> change recipient")
        ChatMsg("/sendmats show / hide      -> toggle window")
        ChatMsg("/sendmats status           -> show state")
    else
        ChatMsg("Unknown command. Try /sendmats help")
    end
end

----------------------------------------------------------------
-- Lifecycle
----------------------------------------------------------------

local function RegisterBindingNames()
    -- These strings appear in Controls -> Keybindings on PS5 / Xbox / PC
    if ZO_CreateStringId then
        ZO_CreateStringId("SI_BINDING_NAME_MAILMULE_SEND", "Send Materials")
        ZO_CreateStringId("SI_BINDING_NAME_MAILMULE_TOGGLE_WINDOW", "Show / Hide Window")
    end
end

-- Context keybind that appears in the bottom strip whenever a mailbox is open.
-- On PS5 this shows as a Triangle icon hint; on Xbox it shows as Y; on PC as a key.
-- We use UI_SHORTCUT_TERTIARY because D-Pad arrows are reserved by the mail UI
-- for navigating between recipient / subject / attachments fields.
local mailKeybindDescriptor = {
    name = "Send Materials",
    keybind = "UI_SHORTCUT_TERTIARY",
    callback = function() MailMule.Start() end,
    visible = function() return state.atMailbox end,
}
local mailKeybindGroup = { mailKeybindDescriptor }
local mailKeybindActive = false

local function ShowMailKeybind()
    if mailKeybindActive then return end
    if KEYBIND_STRIP and KEYBIND_STRIP.AddKeybindButtonGroup then
        pcall(function() KEYBIND_STRIP:AddKeybindButtonGroup(mailKeybindGroup) end)
        mailKeybindActive = true
    end
end

local function HideMailKeybind()
    if not mailKeybindActive then return end
    if KEYBIND_STRIP and KEYBIND_STRIP.RemoveKeybindButtonGroup then
        pcall(function() KEYBIND_STRIP:RemoveKeybindButtonGroup(mailKeybindGroup) end)
        mailKeybindActive = false
    end
end

local function OnAddOnLoaded(_, name)
    if name ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    RegisterBindingNames()
    MailMule.savedVars = ZO_SavedVars:NewAccountWide("MailMule_SavedVars", 1, nil, defaults)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_MAIL_SEND_SUCCESS, OnMailSendSuccess)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_MAIL_SEND_FAILED, OnMailSendFailed)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_MAIL_OPEN_MAILBOX, OnMailboxOpen)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_MAIL_CLOSE_MAILBOX, OnMailboxClose)

    SLASH_COMMANDS["/sendmats"] = HandleSlashCommand

    CreateUI()
    MailMule.ShowWindow()

    ChatMsg("Loaded. Recipient: " .. MailMule.savedVars.recipient .. ". At a mailbox, press Triangle to send.")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
