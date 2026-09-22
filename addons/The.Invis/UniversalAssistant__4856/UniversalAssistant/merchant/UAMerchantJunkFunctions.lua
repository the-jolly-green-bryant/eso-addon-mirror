local ua = UAssistant
local merchant = ua.Merchant
local junk = {}
merchant.Junk = junk

local SELECTOR_REFERENCE = "UAMerchantJunkRememberedItems"
local REMOVE_REFERENCE = "UAMerchantJunkRemoveItem"
local selectedKey
local observedItems = {}
local observedProfile

local function L(key)
    return ua.GetString("MERCHANT_JUNK_" .. key)
end

merchant.RegisterProfile("junk", function()
    return { sellEnabled = false, rememberEnabled = false, items = {}, ignored = {} }
end, function(profile)
    if type(profile.items) ~= "table" then
        profile.items = {}
    end
    if type(profile.ignored) ~= "table" then
        profile.ignored = {}
    end
end)

local function GetKey(itemLink)
    return itemLink and string.match(itemLink, "|H%d+:(.-)|h")
end

function junk.SyncInventory()
    local profile = merchant.GetProfile("junk")
    if observedProfile ~= profile then
        observedItems = {}
        observedProfile = profile
    end
    if not ua.savedVariables.merchantEnabled or not profile.rememberEnabled then
        observedItems = {}
        return false
    end

    local currentItems = {}
    local changed = false
    for slotIndex = 0, GetBagSize(BAG_BACKPACK) - 1 do
        local safe, itemLink = merchant.IsSafeToSell(BAG_BACKPACK, slotIndex)
        local key = safe and GetKey(itemLink)
        if key then
            local uniqueId = tostring(GetItemUniqueId(BAG_BACKPACK, slotIndex))
            local marked = IsItemJunk(BAG_BACKPACK, slotIndex)
            local previous = observedItems[uniqueId]
            currentItems[uniqueId] = { key = key, marked = marked }
            if marked and not profile.ignored[key] then
                if not profile.items[key] then
                    profile.items[key] = itemLink
                    changed = true
                end
            elseif not marked and previous and previous.key == key and previous.marked then
                changed = changed or profile.items[key] ~= nil
                profile.items[key] = nil
                profile.ignored[key] = nil
            end
        end
    end
    observedItems = currentItems
    return changed
end

local function GetChoices()
    local entries = {}

    for key, itemLink in pairs(merchant.GetProfile("junk").items) do
        if type(itemLink) == "string" and GetKey(itemLink) == key then
            entries[#entries + 1] = { key = key, link = itemLink, name = GetItemLinkName(itemLink) }
        end
    end

    table.sort(entries, function(left, right)
        if left.name == right.name then
            return left.key < right.key
        end
        return left.name < right.name
    end)

    local choices, values = {}, {}
    local foundSelected = false

    for _, entry in ipairs(entries) do
        choices[#choices + 1] = zo_iconFormat(GetItemLinkIcon(entry.link), 20, 20)
            .. " "
            .. entry.link
        values[#values + 1] = entry.key
        foundSelected = foundSelected or selectedKey == entry.key
    end

    if not foundSelected then
        selectedKey = values[1]
    end

    if #choices == 0 then
        choices[1], values[1] = L("EMPTY"), ""
    end

    return choices, values
end

function junk.RefreshChoices()
    junk.SyncInventory()
    local choices, values = GetChoices()
    local control = _G[SELECTOR_REFERENCE]

    if control and control.UpdateChoices then
        control.data.choices, control.data.choicesValues = choices, values
        control:UpdateChoices(choices, values)
        control:UpdateValue()
    end

    local button = _G[REMOVE_REFERENCE]
    if button and button.UpdateDisabled then
        button:UpdateDisabled()
    end
end

function junk.RemoveSelected()
    if not selectedKey then
        return
    end

    local profile = merchant.GetProfile("junk")
    profile.items[selectedKey] = nil
    profile.ignored[selectedKey] = true
    selectedKey = nil
    junk.RefreshChoices()
end

function junk.ApplyToSlot(bagId, slotIndex)
    if junk.applying or not ua.savedVariables.merchantEnabled or bagId ~= BAG_BACKPACK then
        return
    end

    local profile = merchant.GetProfile("junk")
    if not profile.rememberEnabled or IsItemJunk(bagId, slotIndex) then
        return
    end

    local safe, itemLink = merchant.IsSafeToSell(bagId, slotIndex)
    local key = safe and GetKey(itemLink)
    if not key or not profile.items[key] or not CanItemBeMarkedAsJunk(bagId, slotIndex) then
        return
    end

    junk.applying = true
    local success, message = pcall(function()
        if IsProtectedFunction("SetItemIsJunk") then
            CallSecureProtected("SetItemIsJunk", bagId, slotIndex, true)
        else
            SetItemIsJunk(bagId, slotIndex, true)
        end
    end)
    junk.applying = false

    if not success then
        error(message)
    end
end

function junk.Initialize()
    if junk.initialized then
        return
    end
    junk.initialized = true

    EVENT_MANAGER:RegisterForUpdate("UAMerchantJunkSync", 500, function()
        if junk.SyncInventory() then
            junk.RefreshChoices()
        end
    end)
    EVENT_MANAGER:RegisterForEvent(
        "UAMerchantJunk",
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        function(_, bagId, slotIndex, isNewItem, _, _, stackCountChange)
            if bagId == BAG_BACKPACK and (isNewItem or (stackCountChange or 0) > 0) then
                local key = GetKey(GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT))
                zo_callLater(function()
                    if key and GetKey(GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)) == key then
                        junk.ApplyToSlot(bagId, slotIndex)
                    end
                end, 0)
            end
        end
    )
    EVENT_MANAGER:AddFilterForEvent(
        "UAMerchantJunk",
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        REGISTER_FILTER_BAG_ID,
        BAG_BACKPACK
    )
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", junk.RefreshChoices)
    CALLBACK_MANAGER:RegisterCallback("LAM-RefreshPanel", junk.RefreshChoices)
end

function junk.CreateMenuControl()
    local profile = merchant.GetProfile("junk")
    local choices, values = GetChoices()
    return {
        type = "submenu",
        name = zo_iconFormat("/esoui/art/inventory/inventory_tabicon_junk_up.dds", 32, 32)
            .. " "
            .. L("NAME"),
        controls = {
            {
                type = "checkbox",
                name = L("SELL"),
                tooltip = L("SELL_TOOLTIP"),
                default = false,
                getFunc = function()
                    return profile.sellEnabled
                end,
                setFunc = function(value)
                    profile.sellEnabled = value
                end,
            },
            {
                type = "checkbox",
                name = L("REMEMBER"),
                tooltip = L("REMEMBER_TOOLTIP"),
                default = false,
                getFunc = function()
                    return profile.rememberEnabled
                end,
                setFunc = function(value)
                    profile.rememberEnabled = value
                    junk.RefreshChoices()
                end,
            },
            { type = "divider" },
            {
                type = "dropdown",
                name = L("LIST"),
                tooltip = L("LIST_TOOLTIP"),
                choices = choices,
                choicesValues = values,
                scrollable = 12,
                reference = SELECTOR_REFERENCE,
                getFunc = function()
                    return selectedKey or ""
                end,
                setFunc = function(value)
                    selectedKey = value ~= "" and value or nil
                    local button = _G[REMOVE_REFERENCE]
                    if button and button.UpdateDisabled then
                        button:UpdateDisabled()
                    end
                end,
            },
            {
                type = "button",
                name = L("REMOVE"),
                tooltip = L("REMOVE_TOOLTIP"),
                reference = REMOVE_REFERENCE,
                func = junk.RemoveSelected,
                disabled = function()
                    return not selectedKey
                end,
            },
        },
    }
end
