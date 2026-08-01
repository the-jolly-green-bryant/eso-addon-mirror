--[[
=============================================================================
 AuctionHouse - Utilities
 Shared helper functions used across all modules.
=============================================================================
]]--

d("[AuctionHouse] Utilities.lua loading...")

local AH = AuctionHouse

AH.Utils = {}
local Utils = AH.Utils

---------------------------------------------------------------------------
--  Debug & Messaging
---------------------------------------------------------------------------

--- Print a debug message to chat (only if debug mode enabled).
function Utils.Debug(msg, ...)
    if AH.savedVars and AH.savedVars.settings.debug then
        local formatted = string.format(tostring(msg), ...)
        d(string.format("[AH Debug] %s", formatted))
    end
end

--- Print a message to chat.
function Utils.Print(msg, ...)
    local formatted = string.format(tostring(msg), ...)
    CHAT_ROUTER:AddSystemMessage(
        string.format("|c%s[%s]|r %s", AH.Colors.GOLD, AH.displayName, formatted)
    )
end

--- Print an error message to chat.
function Utils.PrintError(msg, ...)
    local formatted = string.format(tostring(msg), ...)
    CHAT_ROUTER:AddSystemMessage(
        string.format("|c%s[%s Error]|r %s", AH.Colors.RED, AH.displayName, formatted)
    )
end

---------------------------------------------------------------------------
--  String Helpers
---------------------------------------------------------------------------

--- Colorize a string with a hex color code.
function Utils.Colorize(text, hexColor)
    return string.format("|c%s%s|r", hexColor, tostring(text))
end

--- Format gold amount with commas and gold icon.
function Utils.FormatGold(amount)
    if not amount or amount == 0 then
        return "0 |t16:16:EsoUI/Art/currency/currency_gold.dds|t"
    end

    local formatted = Utils.FormatNumber(amount)
    return string.format("%s |t16:16:EsoUI/Art/currency/currency_gold.dds|t", formatted)
end

--- Format a number with commas.
function Utils.FormatNumber(num)
    if not num then return "0" end

    local formatted = tostring(math.floor(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end

    -- Add decimals if present
    local decimals = num - math.floor(num)
    if decimals > 0.001 then
        formatted = formatted .. string.format("%.2f", decimals):sub(2)
    end

    return formatted
end

--- Format a percentage.
function Utils.FormatPercent(value, decimals)
    decimals = decimals or 1
    return string.format("%." .. decimals .. "f%%", value * 100)
end

--- Truncate a string to a max length with ellipsis.
function Utils.Truncate(text, maxLen)
    if not text then return "" end
    if #text <= maxLen then return text end
    return string.sub(text, 1, maxLen - 3) .. "..."
end

---------------------------------------------------------------------------
--  Time Helpers
---------------------------------------------------------------------------

--- Get the current Unix timestamp.
function Utils.GetTimestamp()
    return GetTimeStamp()
end

--- Format a Unix timestamp to a readable date string.
function Utils.FormatTimestamp(timestamp)
    if not timestamp or timestamp == 0 then return "Unknown" end

    local secsSince = Utils.GetTimestamp() - timestamp

    if secsSince < 60 then
        return "Just now"
    elseif secsSince < 3600 then
        local mins = math.floor(secsSince / 60)
        return string.format("%d min ago", mins)
    elseif secsSince < 86400 then
        local hours = math.floor(secsSince / 3600)
        return string.format("%d hr ago", hours)
    elseif secsSince < 604800 then
        local days = math.floor(secsSince / 86400)
        return string.format("%d day%s ago", days, days > 1 and "s" or "")
    else
        return GetDateStringFromTimestamp(timestamp)
    end
end

--- Format seconds into a human-readable duration.
function Utils.FormatDuration(seconds)
    if seconds < 60 then
        return string.format("%ds", seconds)
    elseif seconds < 3600 then
        return string.format("%dm %ds", math.floor(seconds / 60), seconds % 60)
    else
        local hours = math.floor(seconds / 3600)
        local mins = math.floor((seconds % 3600) / 60)
        return string.format("%dh %dm", hours, mins)
    end
end

---------------------------------------------------------------------------
--  Item Link Helpers
---------------------------------------------------------------------------

--- Extract the item ID from an ESO item link.
function Utils.GetItemIDFromLink(itemLink)
    if not itemLink then return nil end
    local itemId = select(4, ZO_LinkHandler_ParseLink(itemLink))
    return tonumber(itemId)
end

--- Get a clean item name from an item link (no color codes).
function Utils.GetCleanItemName(itemLink)
    if not itemLink then return "Unknown" end
    local name = GetItemLinkName(itemLink)
    return zo_strformat("<<1>>", name) or "Unknown"
end

--- Get item quality from a link.
function Utils.GetItemQuality(itemLink)
    if not itemLink then return ITEM_DISPLAY_QUALITY_NORMAL end
    return GetItemLinkDisplayQuality(itemLink)
end

--- Get the icon texture path for an item link.
function Utils.GetItemIcon(itemLink)
    if not itemLink then return "EsoUI/Art/Icons/icon_missing.dds" end
    local icon = GetItemLinkIcon(itemLink)
    return icon ~= "" and icon or "EsoUI/Art/Icons/icon_missing.dds"
end

--- Build a unique key for an item based on its link data.
--- Used for grouping identical items across different listings.
function Utils.GetItemUniqueKey(itemLink)
    if not itemLink then return nil end
    -- Use itemId + level + quality + trait + enchant for uniqueness
    local itemId = Utils.GetItemIDFromLink(itemLink)
    local quality = Utils.GetItemQuality(itemLink)
    local requiredLevel = GetItemLinkRequiredLevel(itemLink)
    local requiredCP = GetItemLinkRequiredChampionPoints(itemLink)
    local traitType = GetItemLinkTraitType(itemLink)

    return string.format("%d_%d_%d_%d_%d", itemId or 0, quality, requiredLevel, requiredCP, traitType)
end

--- Get required level info from item link.
function Utils.GetItemLevelInfo(itemLink)
    if not itemLink then return 0, 0 end
    local reqLevel = GetItemLinkRequiredLevel(itemLink)
    local reqCP = GetItemLinkRequiredChampionPoints(itemLink)
    return reqLevel, reqCP
end

---------------------------------------------------------------------------
--  Table Helpers
---------------------------------------------------------------------------

--- Shallow copy a table.
function Utils.ShallowCopy(tbl)
    if type(tbl) ~= "table" then return tbl end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = v
    end
    return copy
end

--- Deep copy a table.
function Utils.DeepCopy(tbl)
    if type(tbl) ~= "table" then return tbl end
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = Utils.DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

--- Count entries in a table (works for non-sequential tables).
function Utils.TableCount(tbl)
    if not tbl then return 0 end
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

--- Check if a table contains a value.
function Utils.TableContains(tbl, value)
    if not tbl then return false end
    for _, v in pairs(tbl) do
        if v == value then return true end
    end
    return false
end

--- Remove entries from a table by predicate.
function Utils.TableRemoveWhere(tbl, predicate)
    local i = 1
    while i <= #tbl do
        if predicate(tbl[i]) then
            table.remove(tbl, i)
        else
            i = i + 1
        end
    end
end

---------------------------------------------------------------------------
--  Math Helpers
---------------------------------------------------------------------------

--- Calculate the median of a list of numbers.
function Utils.Median(values)
    if not values or #values == 0 then return 0 end

    local sorted = {}
    for _, v in ipairs(values) do
        table.insert(sorted, v)
    end
    table.sort(sorted)

    local n = #sorted
    if n % 2 == 1 then
        return sorted[math.ceil(n / 2)]
    else
        return (sorted[n / 2] + sorted[n / 2 + 1]) / 2
    end
end

--- Calculate the average of a list of numbers.
function Utils.Average(values)
    if not values or #values == 0 then return 0 end
    local sum = 0
    for _, v in ipairs(values) do
        sum = sum + v
    end
    return sum / #values
end

--- Calculate standard deviation.
function Utils.StandardDeviation(values)
    if not values or #values < 2 then return 0 end
    local avg = Utils.Average(values)
    local sumSqDiff = 0
    for _, v in ipairs(values) do
        sumSqDiff = sumSqDiff + (v - avg) ^ 2
    end
    return math.sqrt(sumSqDiff / (#values - 1))
end

--- Clamp a value between min and max.
function Utils.Clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

---------------------------------------------------------------------------
--  Async / Throttle Helpers
---------------------------------------------------------------------------

--- Create a debounced function that delays execution.
function Utils.Debounce(func, delayMs)
    local callbackName = "AH_Debounce_" .. tostring(func)
    return function(...)
        local args = { ... }
        EVENT_MANAGER:UnregisterForUpdate(callbackName)
        EVENT_MANAGER:RegisterForUpdate(callbackName, delayMs, function()
            EVENT_MANAGER:UnregisterForUpdate(callbackName)
            func(unpack(args))
        end)
    end
end

--- Create a throttled function that executes at most once per interval.
function Utils.Throttle(func, intervalMs)
    local lastCall = 0
    local callbackName = "AH_Throttle_" .. tostring(func)

    return function(...)
        local now = GetGameTimeMilliseconds()
        if now - lastCall >= intervalMs then
            lastCall = now
            func(...)
        else
            -- Schedule for when the interval expires
            local remaining = intervalMs - (now - lastCall)
            local args = { ... }
            EVENT_MANAGER:UnregisterForUpdate(callbackName)
            EVENT_MANAGER:RegisterForUpdate(callbackName, remaining, function()
                EVENT_MANAGER:UnregisterForUpdate(callbackName)
                lastCall = GetGameTimeMilliseconds()
                func(unpack(args))
            end)
        end
    end
end

--- Execute a function after a delay (ms).
function Utils.Delay(delayMs, func)
    local callbackName = "AH_Delay_" .. tostring(GetGameTimeMilliseconds())
    EVENT_MANAGER:RegisterForUpdate(callbackName, delayMs, function()
        EVENT_MANAGER:UnregisterForUpdate(callbackName)
        func()
    end)
end

---------------------------------------------------------------------------
--  Zone / Location Helpers
---------------------------------------------------------------------------

--- Get the player's current zone name.
function Utils.GetCurrentZone()
    return GetZoneNameByIndex(GetCurrentMapZoneIndex())
end

--- Get the player's current location (zone + subzone).
function Utils.GetCurrentLocation()
    local zone = Utils.GetCurrentZone()
    local subzone = GetPlayerActiveSubzoneName()
    if subzone and subzone ~= "" then
        return string.format("%s - %s", zone, subzone)
    end
    return zone
end

---------------------------------------------------------------------------
--  Player Helpers
---------------------------------------------------------------------------

--- Get the current player's @name.
function Utils.GetPlayerName()
    return GetDisplayName()
end

--- Get the current character's name (not the @account name).
function Utils.GetCharacterName()
    return GetUnitName("player")
end

--- Get the player's guild IDs and names.
function Utils.GetPlayerGuilds()
    local guilds = {}
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        local guildName = GetGuildName(guildId)
        if guildId and guildName and guildName ~= "" then
            table.insert(guilds, {
                id = guildId,
                name = guildName,
                index = i,
            })
        end
    end
    return guilds
end

---------------------------------------------------------------------------
--  Item Tooltip Data Extraction
---------------------------------------------------------------------------

--- Extract comprehensive tooltip information from an item link.
--- @param itemLink string ESO item link
--- @return table Detailed item info for tooltip display
function Utils.ExtractTooltipData(itemLink)
    if not itemLink or itemLink == "" then return {} end

    local data = {}

    -- Basic info
    data.equipType = GetItemLinkEquipType(itemLink) or 0
    data.weaponType = GetItemLinkWeaponType(itemLink) or 0
    data.armorType = GetItemLinkArmorType(itemLink) or 0

    -- Trait
    local traitType = GetItemLinkTraitType(itemLink) or 0
    data.traitType = traitType
    if traitType and traitType > 0 then
        data.traitName = GetString("SI_ITEMTRAITTYPE", traitType) or ""
    end

    -- Enchantment
    local hasEnchant, enchantHeader, enchantDesc = GetItemLinkEnchantInfo(itemLink)
    if hasEnchant then
        data.enchantName = enchantHeader or ""
        data.enchantDesc = enchantDesc or ""
    end

    -- Set info
    local hasSet, setName, numBonuses, numEquipped, maxEquipped = GetItemLinkSetInfo(itemLink)
    if hasSet then
        data.setName = setName or ""
        data.setNumBonuses = numBonuses or 0
        data.setNumEquipped = numEquipped or 0
        data.setMaxEquipped = maxEquipped or 0
        data.setBonuses = {}
        for i = 1, numBonuses do
            local numRequired, bonusDesc = GetItemLinkSetBonusInfo(itemLink, false, i)
            if bonusDesc and bonusDesc ~= "" then
                table.insert(data.setBonuses, {
                    required = numRequired or 0,
                    description = bonusDesc,
                })
            end
        end
    end

    -- Armor rating
    local armorRating = GetItemLinkArmorRating(itemLink, false)
    if armorRating and armorRating > 0 then
        data.armorRating = armorRating
    end

    -- Weapon stats
    local weaponPower = GetItemLinkWeaponPower(itemLink, false)
    if weaponPower and weaponPower > 0 then
        data.weaponPower = weaponPower
    end

    -- Item style
    local itemStyle = GetItemLinkItemStyle(itemLink)
    if itemStyle and itemStyle > 0 then
        data.styleName = GetItemStyleName(itemStyle) or ""
    end

    -- Value (sell to vendor price)
    local value = GetItemLinkValue(itemLink, false)
    if value and value > 0 then
        data.vendorValue = value
    end

    -- Weapon/Armor type names
    if data.weaponType > 0 then
        data.weaponTypeName = GetString("SI_WEAPONTYPE", data.weaponType) or ""
    end
    if data.armorType > 0 then
        data.armorTypeName = GetString("SI_ARMORTYPE", data.armorType) or ""
    end
    if data.equipType > 0 then
        data.equipTypeName = GetString("SI_EQUIPTYPE", data.equipType) or ""
    end

    return data
end
