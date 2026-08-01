-- ScanUtils.lua: Pure functions for scan queue building

local ScanUtils = {}

---Build comprehensive search queue
---@return SearchParams[]
function ScanUtils.BuildSearchQueue()
    local queue = {}

    local focuses = {
        { value = GUILD_FOCUS_ATTRIBUTE_VALUE_TRADING,     name = "Trading" },
        { value = GUILD_FOCUS_ATTRIBUTE_VALUE_PVP,         name = "PVP" },
        { value = GUILD_FOCUS_ATTRIBUTE_VALUE_GROUP_PVE,   name = "PVE" },
        { value = GUILD_FOCUS_ATTRIBUTE_VALUE_SOCIAL,      name = "Social" },
        { value = GUILD_FOCUS_ATTRIBUTE_VALUE_QUESTING,    name = "Questing" },
        { value = GUILD_FOCUS_ATTRIBUTE_VALUE_CRAFTING,    name = "Crafting" },
        { value = GUILD_FOCUS_ATTRIBUTE_VALUE_ROLEPLAYING, name = "Roleplay" },
    }

    local allSizes = {
        { value = GUILD_SIZE_ATTRIBUTE_VALUE_GIGANTIC, name = "Gigantic" },
        { value = GUILD_SIZE_ATTRIBUTE_VALUE_LARGE,    name = "Large" },
        { value = GUILD_SIZE_ATTRIBUTE_VALUE_MEDIUM,   name = "Medium" },
        { value = GUILD_SIZE_ATTRIBUTE_VALUE_SMALL,    name = "Small" },
    }

    for _, focus in ipairs(focuses) do
        table.insert(queue, {
            focus = focus,
            sizes = allSizes,
            alliance = nil,
        })
    end

    return queue
end

---Build size string for logging
---@param sizes SizeType[]
---@return string
function ScanUtils.BuildSizeString(sizes)
    if #sizes == 4 then
        return "All Sizes"
    elseif #sizes > 1 then
        local sizeNames = {}
        for _, size in ipairs(sizes) do
            table.insert(sizeNames, size.name)
        end
        return table.concat(sizeNames, "+")
    else
        return sizes[1].name
    end
end

---Build alliance string for logging
---@param alliance AllianceType|nil
---@return string
function ScanUtils.BuildAllianceString(alliance)
    return alliance and (" [" .. alliance.name .. "]") or ""
end

---Get member range string for a size
---@param size SizeType
---@return string
function ScanUtils.GetMemberRangeString(size)
    if size.value == GUILD_SIZE_ATTRIBUTE_VALUE_SMALL then
        return "10-49"
    elseif size.value == GUILD_SIZE_ATTRIBUTE_VALUE_MEDIUM then
        return "50-149"
    elseif size.value == GUILD_SIZE_ATTRIBUTE_VALUE_LARGE then
        return "150-299"
    elseif size.value == GUILD_SIZE_ATTRIBUTE_VALUE_GIGANTIC then
        return "300+"
    end
    return "any"
end

---Split search parameters when overflow occurs
---@param searchParams SearchParams
---@return SearchParams[], string|nil overflowWarning
function ScanUtils.SplitSearchParams(searchParams)
    local numSizes = #searchParams.sizes
    local splits = {}
    local warning = nil

    if numSizes == 4 then
        -- Split into two groups of 2
        local group1 = { searchParams.sizes[1], searchParams.sizes[2] }
        local group2 = { searchParams.sizes[3], searchParams.sizes[4] }

        table.insert(splits, {
            focus = searchParams.focus,
            sizes = group1,
            alliance = searchParams.alliance,
        })
        table.insert(splits, {
            focus = searchParams.focus,
            sizes = group2,
            alliance = searchParams.alliance,
        })
    elseif numSizes == 2 then
        -- Split into individual sizes
        for _, size in ipairs(searchParams.sizes) do
            table.insert(splits, {
                focus = searchParams.focus,
                sizes = { size },
                alliance = searchParams.alliance,
            })
        end
    elseif numSizes == 1 and not searchParams.alliance then
        -- Split by alliance
        local alliances = {
            { value = ALLIANCE_ALDMERI_DOMINION,    name = "AD" },
            { value = ALLIANCE_DAGGERFALL_COVENANT, name = "DC" },
            { value = ALLIANCE_EBONHEART_PACT,      name = "EP" },
        }

        for _, alliance in ipairs(alliances) do
            table.insert(splits, {
                focus = searchParams.focus,
                sizes = searchParams.sizes,
                alliance = alliance,
            })
        end
    elseif numSizes == 1 and searchParams.alliance then
        -- Can't split further, return warning
        local sizeStr = searchParams.sizes[1].name
        local memberRange = ScanUtils.GetMemberRangeString(searchParams.sizes[1])
        warning = string.format("[SmartTrader] %s %s [%s]",
            searchParams.focus.name,
            searchParams.alliance.name,
            memberRange)
    end

    return splits, warning
end

SmartTrader.ScanUtils = ScanUtils
