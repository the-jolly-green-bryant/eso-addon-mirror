-- =====================================================================
-- Already Listed
-- Shows how many of an item you already have listed at the current
-- guild trader, next to the bag/bank counts in gamepad item tooltips.
-- Gamepad/console UI only. Zero dependencies.
-- =====================================================================

AlreadyListed = {
    name = "AlreadyListed",
    atTradingHouse = false,
    listedByLink = {},
    ICON = "EsoUI/Art/TradingHouse/tradinghouse_listings_tabIcon_up.dds",
}

local AL = AlreadyListed

-- ---------------------------------------------------------------------
-- Listings cache
-- ---------------------------------------------------------------------

function AL.RebuildCache()
    local cache = {}
    for i = 1, GetNumTradingHouseListings() do
        local itemLink = GetTradingHouseListingItemLink(i)
        if itemLink and itemLink ~= "" then
            local _, _, _, stackCount = GetTradingHouseListingItemInfo(i)
            cache[itemLink] = (cache[itemLink] or 0) + (stackCount or 0)
        end
    end
    AL.listedByLink = cache
end

function AL.GetListedCount(itemLink)
    return AL.listedByLink[itemLink]
end

function AL.GetActiveCount(itemLink)
    if not AL.atTradingHouse or not itemLink then
        return nil
    end
    if not (TRADING_HOUSE_GAMEPAD and TRADING_HOUSE_GAMEPAD.GetCurrentMode) then
        return nil
    end
    local mode = TRADING_HOUSE_GAMEPAD:GetCurrentMode()
    if mode ~= ZO_TRADING_HOUSE_MODE_SELL and mode ~= ZO_TRADING_HOUSE_MODE_LISTINGS then
        return nil
    end
    local count = AL.GetListedCount(itemLink)
    if count and count > 0 then
        return count
    end
    return nil
end

-- ---------------------------------------------------------------------
-- Refresh driver
-- ---------------------------------------------------------------------

local COOLDOWN_RETRY_BUFFER_MS = 250

function AL.RequestListings()
    if not AL.atTradingHouse then
        return
    end
    if HasTradingHouseListings() then
        AL.RebuildCache()
        return
    end
    local cooldownMs = GetTradingHouseCooldownRemaining()
    if cooldownMs > 0 then
        zo_callLater(AL.RequestListings, cooldownMs + COOLDOWN_RETRY_BUFFER_MS)
    else
        RequestTradingHouseListings()
    end
end

function AL.OnTradingHouseOpened(eventCode)
    AL.atTradingHouse = true
    AL.listedByLink = {}
    AL.RequestListings()
end

function AL.OnTradingHouseClosed(eventCode)
    AL.atTradingHouse = false
    AL.listedByLink = {}
end

function AL.OnSelectedGuildChanged(eventCode, guildId)
    AL.listedByLink = {}
    AL.RequestListings()
end

function AL.OnResponseReceived(eventCode, responseType, result)
    if result ~= TRADING_HOUSE_RESULT_SUCCESS then
        return
    end
    if responseType == TRADING_HOUSE_RESULT_LISTINGS_PENDING then
        AL.RebuildCache()
    elseif responseType == TRADING_HOUSE_RESULT_POST_PENDING
        or responseType == TRADING_HOUSE_RESULT_CANCEL_SALE_PENDING then
        AL.RequestListings()
    end
end

-- ---------------------------------------------------------------------
-- Tooltip injection
-- ---------------------------------------------------------------------

function AL.AddCountLine(section, count)
    local text = zo_iconTextFormat(AL.ICON, 24, 24, count)
    local narration = zo_strformat(SI_GAMEPAD_INVENTORY_STACK_COUNT_NARRATION_FORMATTER,
        GetString(SI_TRADING_HOUSE_MODE_LISTINGS), count)
    section:AddLineWithCustomNarration(text, narration)
end

local installedWrappers = {}

local function MakeAddTopLinesWrapper(origAddTopLines)
    local wrapper = function(tooltip, topSection, itemLink, ...)
        local count = AL.GetActiveCount(itemLink)
        if not (count and topSection) then
            return origAddTopLines(tooltip, topSection, itemLink, ...)
        end
        if type(topSection.AddSectionEvenIfEmpty) ~= "function" then
            return origAddTopLines(tooltip, topSection, itemLink, ...)
        end

        -- The game builds the bag/bank counts in a local subsection and
        -- commits it with topSection:AddSectionEvenIfEmpty(subsection).
        -- Real sections carry that method as their OWN field (zo_mixin),
        -- so shadow it and restore the saved original — never nil it.
        local origAddSectionEvenIfEmpty = topSection.AddSectionEvenIfEmpty
        topSection.AddSectionEvenIfEmpty = function(sectionSelf, subsection)
            sectionSelf.AddSectionEvenIfEmpty = origAddSectionEvenIfEmpty
            if subsection then
                AL.AddCountLine(subsection, count)
            end
            return origAddSectionEvenIfEmpty(sectionSelf, subsection)
        end

        -- pcall so the shadow is removed even if the game function errors
        -- (sections are pooled; a leaked field would corrupt later tooltips)
        local ok, result = pcall(origAddTopLines, tooltip, topSection, itemLink, ...)
        topSection.AddSectionEvenIfEmpty = origAddSectionEvenIfEmpty
        if not ok then
            error(result, 0)
        end
        return result
    end
    installedWrappers[wrapper] = true
    return wrapper
end

local function WrapHostAddTopLines(host)
    if not host then
        return
    end
    local current = host.AddTopLinesToTopSection
    if type(current) ~= "function" or installedWrappers[current] then
        return
    end
    host.AddTopLinesToTopSection = MakeAddTopLinesWrapper(current)
end

function AL.HookTooltips()
    if ZO_Tooltip then
        WrapHostAddTopLines(ZO_Tooltip)
    end
end

-- Gamepad tooltip objects copy ZO_Tooltip's functions onto themselves as
-- OWN fields when they initialize (zo_mixin). On console that happens
-- before addons load, so the class-table hook alone never reaches them —
-- wrap the live left-tooltip instance (the one both trading-house tabs
-- use) as well. The installedWrappers guard prevents double-wrapping when
-- the tip initialized late and already snapshotted the class wrapper.
function AL.HookTooltipInstances()
    if not (GAMEPAD_TOOLTIPS and GAMEPAD_TOOLTIPS.GetAndInitializeTooltipContainerTip
        and GAMEPAD_LEFT_TOOLTIP) then
        return
    end
    local ok, tip = pcall(function()
        return GAMEPAD_TOOLTIPS:GetAndInitializeTooltipContainerTip(GAMEPAD_LEFT_TOOLTIP)
    end)
    if ok and tip then
        WrapHostAddTopLines(tip.tooltip)
    end
end

-- ---------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------

function AL.OnAddOnLoaded(eventCode, addonName)
    if addonName ~= AL.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(AL.name, EVENT_ADD_ON_LOADED)

    EVENT_MANAGER:RegisterForEvent(AL.name, EVENT_OPEN_TRADING_HOUSE, AL.OnTradingHouseOpened)
    EVENT_MANAGER:RegisterForEvent(AL.name, EVENT_CLOSE_TRADING_HOUSE, AL.OnTradingHouseClosed)
    EVENT_MANAGER:RegisterForEvent(AL.name, EVENT_TRADING_HOUSE_SELECTED_GUILD_CHANGED, AL.OnSelectedGuildChanged)
    EVENT_MANAGER:RegisterForEvent(AL.name, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, AL.OnResponseReceived)

    AL.HookTooltips()

    -- Instance hooking must wait until the UI is fully up; the probe-safe
    -- point is player activation (one-shot).
    EVENT_MANAGER:RegisterForEvent(AL.name .. "Activated", EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(AL.name .. "Activated", EVENT_PLAYER_ACTIVATED)
        AL.HookTooltipInstances()
    end)
end

EVENT_MANAGER:RegisterForEvent(AlreadyListed.name, EVENT_ADD_ON_LOADED, AL.OnAddOnLoaded)
