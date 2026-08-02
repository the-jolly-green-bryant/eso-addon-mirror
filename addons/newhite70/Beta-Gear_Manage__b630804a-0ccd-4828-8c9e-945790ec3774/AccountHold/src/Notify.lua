-- Quartermaster/src/Notify.lua
-- Chat + center-screen notifications for the four flow points described in
-- brief §6.

AccountHold = AccountHold or {}
AccountHold.Notify = AccountHold.Notify or {}

local Notify = AccountHold.Notify
local addon

function Notify:Initialize(addonRef)
    addon = addonRef
end

-- ---------------------------------------------------------------------------
-- Output sinks
-- ---------------------------------------------------------------------------

local function chat(msg)
    if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
        CHAT_ROUTER:AddSystemMessage(string.format("|cFFD700[Quartermaster]|r %s", msg))
    end
end

local function center(msg)
    -- Use the standard CenterScreenAnnounce path. CSA exists on every UI mode.
    if not (CENTER_SCREEN_ANNOUNCE and CENTER_SCREEN_ANNOUNCE.AddMessage) then return end

    -- Prefer the message-params path so we can extend the on-screen lifespan:
    -- the default large-text CSA fades a little too fast to comfortably read.
    -- Hold it for ~7s. Fall back to the plain AddMessage if the params API
    -- isn't available on this client build.
    local LIFESPAN_MS = 7000
    if CENTER_SCREEN_ANNOUNCE.CreateMessageParams and CENTER_SCREEN_ANNOUNCE.AddMessageWithParams then
        local ok = pcall(function()
            local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(
                CSA_CATEGORY_LARGE_TEXT or 1, nil)
            params:SetText(msg)
            if params.SetLifespanMS then params:SetLifespanMS(LIFESPAN_MS) end
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
        end)
        if ok then return end
    end

    CENTER_SCREEN_ANNOUNCE:AddMessage(
        EVENT_BROADCAST or 0,
        CSA_CATEGORY_LARGE_TEXT or 1,
        nil,            -- soundId
        msg
    )
end

local function dispatch(msg)
    local style = (addon.sv and addon.sv.settings and addon.sv.settings.notificationStyle) or "both"
    if style == "chat"        then chat(msg)
    elseif style == "centerScreen" then center(msg)
    else                            chat(msg); center(msg)
    end
end

-- Fire a sample notification using the current style. Called from the Settings
-- panel when the player changes the notification-style dropdown so the effect
-- of the setting is immediately visible (bug 5).
function Notify:PreviewStyle()
    dispatch(GetString(SI_ACCOUNTHOLD_SETTINGS_NOTIFY_PREVIEW))
end

-- Always-visible alert (chat + center-screen), independent of the
-- notification-style preference. Used for blocking conditions the player MUST
-- see — e.g. "not enough space to move reserved items" (feature F1).
function Notify:Alert(msg)
    chat(msg)
    center(msg)
end

-- ---------------------------------------------------------------------------
-- Login flow (brief §6.1, §6.3)
-- ---------------------------------------------------------------------------

function Notify:OnPlayerActivated(isInitialActivation)
    -- EVENT_PLAYER_ACTIVATED's first arg is true ONLY on the first activation
    -- after login / reloadUI; it is false for every door / zone / instance
    -- load, and some synthetic dispatches pass nil. Treat anything that is not
    -- strictly the initial activation as "not login" and bail.
    if not isInitialActivation then return end
    if not (addon.sv and addon.sv.settings and addon.sv.settings.autoPromptOnLogin) then return end

    -- In-memory session latch: a duplicate initial=true (or a synthetic
    -- re-dispatch of the login activation) must never emit the banner twice.
    -- It resets naturally on /reloadui because the Lua state is rebuilt, so no
    -- SavedVariables migration is involved.
    if self._loginBannerShown then return end
    self._loginBannerShown = true

    -- Exactly ONE dispatch total per login — never one per role or per hold.
    -- Aggregate the holder and requester counts into a single banner.
    local holderHolds    = addon.Holds:GetActiveHoldsForCurrentCharacterAsHolder() or {}
    local requesterHolds = addon.Holds:GetActiveHoldsForCurrentCharacterAsRequester() or {}
    local holderCount    = #holderHolds
    local requesterCount = #requesterHolds

    if holderCount > 0 and requesterCount > 0 then
        dispatch(GetString(SI_ACCOUNTHOLD_NOTIFY_LOGIN_BOTH):format(holderCount, requesterCount))
    elseif holderCount > 0 then
        dispatch(GetString(SI_ACCOUNTHOLD_NOTIFY_HOLDER_LOGIN):format(holderCount))
    elseif requesterCount > 0 then
        dispatch(GetString(SI_ACCOUNTHOLD_NOTIFY_REQ_LOGIN):format(requesterCount))
    end
end

-- ---------------------------------------------------------------------------
-- At-container flows (brief §6.2, §6.4)
--
-- Three independent prompt toggles in settings — one per container family.
-- Map the live containerKey ("bank" / "guildbank:<id>" / "house:<id>:<bag>")
-- onto the right toggle so each can be silenced independently.
-- ---------------------------------------------------------------------------

local CONTAINER_KEY_BANK            = "bank"
local CONTAINER_PREFIX_GUILDBANK    = "guildbank:"
local CONTAINER_PREFIX_HOUSE        = "house:"

local function isPromptEnabledForContainer(containerKey)
    local s = addon.sv.settings
    if type(containerKey) == "string" then
        if containerKey == CONTAINER_KEY_BANK then
            return s.autoPromptAtBank
        end
        if containerKey:sub(1, #CONTAINER_PREFIX_GUILDBANK) == CONTAINER_PREFIX_GUILDBANK then
            return s.autoPromptAtGuildBank
        end
        if containerKey:sub(1, #CONTAINER_PREFIX_HOUSE) == CONTAINER_PREFIX_HOUSE then
            return s.autoPromptAtHouseStorage
        end
    end
    -- Unknown container — fall back to the generic bank toggle.
    return s.autoPromptAtBank
end

function Notify:OnHolderAtContainer(containerKey, count)
    if not isPromptEnabledForContainer(containerKey) then return end
    dispatch(GetString(SI_ACCOUNTHOLD_NOTIFY_HOLDER_AT_BANK):format(count))
end

function Notify:OnRequesterAtContainer(containerKey, count)
    if not isPromptEnabledForContainer(containerKey) then return end
    dispatch(GetString(SI_ACCOUNTHOLD_NOTIFY_REQ_AT_BANK):format(count))
end

-- ---------------------------------------------------------------------------
-- Delivery hook — opt-in auto-equip
-- ---------------------------------------------------------------------------

-- Map of unambiguous equip types to their single destination slot in BAG_WORN.
-- Weapons are intentionally omitted: they can target main/off/backup-main/
-- backup-off depending on the player's loadout, and silently picking one
-- could disrupt combat. If the player wants weapons auto-equipped they can
-- swap manually after retrieval.
local EQUIP_SLOT_MAP
local function buildEquipSlotMap()
    if EQUIP_SLOT_MAP then return EQUIP_SLOT_MAP end
    EQUIP_SLOT_MAP = {}
    local function add(typeName, slotName)
        local t = _G[typeName]
        local s = _G[slotName]
        if type(t) == "number" and type(s) == "number" then
            EQUIP_SLOT_MAP[t] = s
        end
    end
    add("EQUIP_TYPE_HEAD",      "EQUIP_SLOT_HEAD")
    add("EQUIP_TYPE_NECK",      "EQUIP_SLOT_NECK")
    add("EQUIP_TYPE_CHEST",     "EQUIP_SLOT_CHEST")
    add("EQUIP_TYPE_SHOULDERS", "EQUIP_SLOT_SHOULDERS")
    add("EQUIP_TYPE_WAIST",     "EQUIP_SLOT_WAIST")
    add("EQUIP_TYPE_LEGS",      "EQUIP_SLOT_LEGS")
    add("EQUIP_TYPE_FEET",      "EQUIP_SLOT_FEET")
    add("EQUIP_TYPE_HAND",      "EQUIP_SLOT_HAND")
    add("EQUIP_TYPE_COSTUME",   "EQUIP_SLOT_COSTUME")
    return EQUIP_SLOT_MAP
end

function Notify:OnHoldDelivered(hold)
    -- Only equip if ALL three conditions are true (brief §4.3):
    --   1. settings.autoEquipOnReceive
    --   2. hold.equipOnReceive (set at creation)
    --   3. item is gear with an unambiguous equip slot
    if not (addon.sv.settings.autoEquipOnReceive and hold.equipOnReceive) then return end
    if not CallSecureProtected then return end

    local map = buildEquipSlotMap()

    -- Find the freshly-arrived item in backpack and request a move into the
    -- matching BAG_WORN slot. This is just RequestMoveItem with BAG_WORN as
    -- the destination — there is no separate EquipItem API. Wrapped in
    -- CallSecureProtected because RequestMoveItem is a protected function.
    -- Skip silently if anything is missing or ambiguous.
    local size = GetBagSize(BAG_BACKPACK) or 0
    for slot = 0, size - 1 do
        local link = GetItemLink(BAG_BACKPACK, slot, LINK_STYLE_DEFAULT)
        if link and link == hold.itemLink then
            -- P0 #4: per-piece set holds carry an explicit targetEquipSlot;
            -- prefer it over the equip-type lookup so e.g. a ring goes into
            -- the missing ring slot the user asked for, not the first ring
            -- slot the equip-type map happens to list.
            local destSlot = hold.targetEquipSlot
            if not destSlot then
                local equipType = GetItemLinkEquipType and GetItemLinkEquipType(link) or 0
                destSlot = map[equipType]
            end
            if destSlot then
                pcall(CallSecureProtected,
                    "RequestMoveItem",
                    BAG_BACKPACK, slot, BAG_WORN, destSlot, 1)
            end
            return
        end
    end
end
