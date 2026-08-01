VisitHouse = VisitHouse or {}
VisitHouse.name = "VisitHouse"

-- Returns true if `str` begins with `start`.
local function StartsWith(str, start)
    return str:sub(1, #start) == start
end

-- Returns true if `str` is nil or the empty string.
local function IsEmpty(str)
    return str == nil or str == ""
end

-- Splits `inputstr` on `splitter` (default: whitespace). Returns an array of tokens.
-- Named TokenizeString to avoid shadowing the native ESO global SplitString / zo_strsplit,
-- which has a different signature: SplitString(delimiter, str) -> multiple return values.
local function TokenizeString(inputstr, splitter)
    if splitter == nil then
        splitter = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. splitter .. "]+)") do
        table.insert(t, str)
    end
    return t
end

-- Writes `msg` to the chat window via the system message API.
local function Print(msg)
    CHAT_SYSTEM:AddMessage(msg)
end

-- ---------------------------------------------------------------------------
-- House lookup
-- ---------------------------------------------------------------------------

-- Enumerates all houses via the collectible data manager, which is always
-- authoritative and requires no hardcoded ID ceiling.
-- Returns a sorted array of { name, id } tables where `id` is the house ID
-- passed to JumpToSpecificHouse.  Sort ignores a leading "The ".
local function LoadHouses()
    local allHouses = {}

    for _, categoryData in ZO_COLLECTIBLE_DATA_MANAGER:CategoryIterator({}) do
        if categoryData:IsHousingCategory() then
            for _, collectibleData in categoryData:CollectibleIterator({}) do
                local houseName = collectibleData:GetName()
                if not IsEmpty(houseName) then
                    local collectibleId = collectibleData:GetId()
                    local houseId = GetCollectibleReferenceId(collectibleId)
                    if houseId and houseId > 0 then
                        table.insert(allHouses, { name = houseName, id = houseId, collectibleId = collectibleId })
                    end
                end
            end
            for _, subCategoryData in categoryData:SubcategoryIterator({}) do
                for _, collectibleData in subCategoryData:CollectibleIterator({}) do
                    local houseName = collectibleData:GetName()
                    if not IsEmpty(houseName) then
                        local collectibleId = collectibleData:GetId()
                        local houseId = GetCollectibleReferenceId(collectibleId)
                        if houseId and houseId > 0 then
                            table.insert(allHouses, { name = houseName, id = houseId, collectibleId = collectibleId })
                        end
                    end
                end
            end
        end
    end

    table.sort(allHouses, function(left, right)
        local leftVal  = StartsWith(left.name,  "The ") and left.name:sub(5)  or left.name
        local rightVal = StartsWith(right.name, "The ") and right.name:sub(5) or right.name
        return leftVal < rightVal
    end)
    return allHouses
end

-- Returns a flat list of house names that the local player owns, for use as
-- /visit me autocomplete so only purchaseable/already-owned homes are shown.
local function GetOwnedHouseNames(allHouses)
    local owned = {}
    for _, house in ipairs(allHouses) do
        if IsCollectibleOwnedByDefId(house.collectibleId) then
            table.insert(owned, house.name)
        end
    end
    return owned
end

-- ---------------------------------------------------------------------------
-- Player-list helpers
-- ---------------------------------------------------------------------------

-- Returns display names of group members, excluding the local player.
local function LoadGroup(playerName)
    local group = {}
    for i = 1, GetGroupSize() do
        local unitTag     = GetGroupUnitTagByIndex(i)
        local displayName = GetUnitDisplayName(unitTag)
        if displayName ~= playerName then
            table.insert(group, displayName)
        end
    end
    return group
end

-- Returns display names from the local player's friends list, excluding themselves.
local function LoadFriends(playerName)
    local friends = {}
    for i = 1, GetNumFriends() do
        local displayName = GetFriendInfo(i)
        if displayName ~= playerName then
            table.insert(friends, displayName)
        end
    end
    return friends
end

-- Returns display names from all of the local player's guilds, excluding themselves.
local function LoadGuildmates(playerName)
    local guildMembers = {}
    for g = 1, GetNumGuilds() do
        local guildId = GetGuildId(g)
        for i = 1, GetNumGuildMembers(guildId) do
            local displayName = GetGuildMemberInfo(guildId, i)
            if displayName ~= playerName then
                table.insert(guildMembers, displayName)
            end
        end
    end
    return guildMembers
end

-- Merges group, friends, and guild member lists into a de-duplicated array
-- of display names for slash-command autocomplete.
local function LoadPlayers(playerName)
    local groupList   = LoadGroup(playerName)
    local friendsList = LoadFriends(playerName)
    local guildList   = LoadGuildmates(playerName)

    -- Merge all three source lists
    local merged = {}
    for _, player in ipairs(groupList)   do table.insert(merged, player) end
    for _, player in ipairs(friendsList) do table.insert(merged, player) end
    for _, player in ipairs(guildList)   do table.insert(merged, player) end

    -- De-duplicate while preserving order (first occurrence wins)
    local seen    = {}
    local unique  = {}
    for _, v in ipairs(merged) do
        if not seen[v] then
            unique[#unique + 1] = v
            seen[v] = true
        end
    end
    return unique
end

-- ---------------------------------------------------------------------------
-- Teleport logic
-- ---------------------------------------------------------------------------

-- Case-insensitive search for a house by name. Returns houseId, canonicalName or nil, nil.
local function FindHouseId(houseName, allHouses)
    local lower = houseName:lower()
    for _, house in ipairs(allHouses) do
        if house.name:lower() == lower then
            return house.id, house.name
        end
    end
    return nil, nil
end

-- Error message shown when a house name cannot be resolved.
local HOUSE_NOT_FOUND_MSG =
    ". The name of the house must match the in-game spelling " ..
    "(case insensitive, but punctuation is required - e.g. Water's Edge " ..
    "requires the single quote). If you believe this is an error, please " ..
    "send @TheNickm2 an in-game mail describing the issue."

-- Persists the last-visited destination to account-wide SavedVariables.
-- houseName and houseId are nil when jumping to a primary residence.
local function SaveLastVisit(player, houseName, houseId)
    VisitHouse.db.lastVisit = {
        player    = player,
        houseName = houseName,
        houseId   = houseId,
    }
end

-- Set to true immediately before any jump call; cleared by the EVENT_JUMP_FAILED
-- handler so we only surface errors from jumps we initiated.
local jumpPending = false

-- Human-readable messages for all teleport errors.
-- Numeric keys correspond to JUMP_RESULT_* constants fired by EVENT_JUMP_FAILED.
-- String keys are used for proactive pre-checks inside DoTeleport.
local JUMP_FAIL_MESSAGES = {
    -- EVENT_JUMP_FAILED reason codes
    [JUMP_RESULT_JUMP_FAILED]                         = "Teleport failed.",
    [JUMP_RESULT_JUMP_FAILED_ALREADY_JUMPING]         = "Teleport failed: a teleport is already in progress.",
    [JUMP_RESULT_JUMP_FAILED_DONT_OWN_HOUSE]          = "Teleport failed: you do not own that house.",
    [JUMP_RESULT_JUMP_FAILED_INVALID_HOUSE]           = "Teleport failed: that house does not exist.",
    [JUMP_RESULT_JUMP_FAILED_NO_HOUSE_PERMISSION]     = "Teleport failed: you do not have permission to enter that home.",
    [JUMP_RESULT_JUMP_FAILED_RECALL_BLOCKED]          = "Teleport failed: recall is blocked (e.g. in combat).",
    [JUMP_RESULT_JUMP_ON_COOLDOWN]                    = "Teleport failed: still on cooldown.",
    [JUMP_RESULT_JUMP_FAILED_TOO_MANY_JUMP_REQUESTS]  = "Teleport failed: too many requests, try again shortly.",
    [JUMP_RESULT_NO_JUMP_PERMISSION]                  = "Teleport failed: you do not have permission to teleport there.",
    -- Proactive pre-check messages
    ["IN_COMBAT"]            = "You cannot teleport to a house while in combat.",
    ["LOCATION_BLOCKED"]     = "You cannot teleport to a house from your current location.",
    ["DONT_OWN_HOUSE"]       = "You do not own that house.",
    ["NO_PRIMARY_RESIDENCE"] = "You have no primary residence set.",
}

-- Teleports to a specific house (houseId provided) or primary residence (houseId nil),
-- prints a confirmation message, and records the visit in SavedVariables.
-- When the target player is the local player, uses RequestJumpToHouse instead of
-- JumpToHouse/JumpToSpecificHouse, which cannot be used for your own homes.
local function DoTeleport(player, houseName, houseId)
    if IsUnitInCombat("player") then
        Print(JUMP_FAIL_MESSAGES["IN_COMBAT"])
        return
    end

    if not CanJumpToHouseFromCurrentLocation() then
        Print(JUMP_FAIL_MESSAGES["LOCATION_BLOCKED"])
        return
    end

    local isSelf = (player == GetDisplayName())

    if isSelf then
        if houseId then
            local collectibleId = GetCollectibleIdForHouse(houseId)
            if collectibleId and not IsCollectibleOwnedByDefId(collectibleId) then
                Print(JUMP_FAIL_MESSAGES["DONT_OWN_HOUSE"])
                return
            end
            Print('Teleporting to your "' .. houseName .. '"...')
            SaveLastVisit(player, houseName, houseId)
            jumpPending = true
            RequestJumpToHouse(houseId, false)
        else
            local primaryId = GetHousingPrimaryHouse()
            if not primaryId or primaryId == 0 then
                Print(JUMP_FAIL_MESSAGES["NO_PRIMARY_RESIDENCE"])
                return
            end
            Print("Teleporting to your primary residence...")
            SaveLastVisit(player, nil, nil)
            jumpPending = true
            RequestJumpToHouse(primaryId, false)
        end
    else
        if houseId then
            Print("Teleporting to " .. player .. '\'s "' .. houseName .. '"...')
            SaveLastVisit(player, houseName, houseId)
            jumpPending = true
            JumpToSpecificHouse(player, houseId)
        else
            Print("Teleporting to the primary residence of " .. player .. "...")
            SaveLastVisit(player, nil, nil)
            jumpPending = true
            JumpToHouse(player)
        end
    end
end

-- Handles a teleport when the player name was selected via autocomplete.
-- `input` is a table { player, house }.
local function VisitHouseAutoComplete(input, allHouses)
    -- Guard: input must be a valid table with a player field
    if not input or not input.player then
        return
    end

    if not StartsWith(input.player, "@") then
        input.player = "@" .. input.player
    end

    if IsEmpty(input.house) then
        DoTeleport(input.player, nil, nil)
    else
        local houseId, canonicalName = FindHouseId(input.house, allHouses)
        if not houseId then
            Print("Unable to find a house named " .. input.house .. HOUSE_NOT_FOUND_MSG)
            return
        end
        DoTeleport(input.player, canonicalName, houseId)
    end
end

-- Handles a teleport typed manually without autocomplete.
-- `input` is the raw string after the slash command: "@PlayerName [House Name]"
local function VisitHouseManual(input, allHouses)
    local strSplit = TokenizeString(input)
    local player   = strSplit[1]
    if not player then
        return
    end

    -- Everything after the first token is the (possibly multi-word) house name
    local houseName = input:gsub(player, ""):gsub("^%s*(.-)%s*$", "%1")

    if not StartsWith(player, "@") then
        player = "@" .. player
    end

    -- No house specified, or house name resolved to empty: jump to primary residence
    if #strSplit <= 1 or not houseName or houseName == "" then
        DoTeleport(player, nil, nil)
        return
    end

    local houseId, canonicalName = FindHouseId(houseName, allHouses)
    if not houseId then
        Print("Unable to find a house named " .. houseName .. HOUSE_NOT_FOUND_MSG)
    else
        DoTeleport(player, canonicalName, houseId)
    end
end

-- ---------------------------------------------------------------------------
-- Slash-command registration
-- ---------------------------------------------------------------------------

-- Registers /visit and its aliases with LibSlashCommander, wiring up
-- manual-input, per-player autocomplete sub-commands, and utility sub-commands.
local function RegisterCommands(houses)
    -- Build a flat list of all house names for the autocomplete widget
    local houseNames = {}
    for _, house in ipairs(houses) do
        table.insert(houseNames, house.name)
    end

    -- Build a list of only owned house names for /visit me autocomplete
    local ownedHouseNames = GetOwnedHouseNames(houses)

    local LSC     = LibSlashCommander
    local command = LSC:Register()
    command:AddAlias("/visit")
    command:AddAlias("/gotohouse")
    command:AddAlias("/jumptohouse")
    command:SetDescription("Visit a player's in-game home")
    command:SetCallback(function(input)
        VisitHouseManual(input, houses)
    end)

    -- /visit me [housename] — jump to your own residence
    local meCmd = command:RegisterSubCommand()
    meCmd:AddAlias("me")
    meCmd:SetDescription("Visit your own home")
    meCmd:SetCallback(function(input)
        VisitHouseAutoComplete({ player = GetDisplayName(), house = input }, houses)
    end)
    meCmd:SetAutoComplete(ownedHouseNames)

    -- /visit last — repeat the previous visit
    local lastCmd = command:RegisterSubCommand()
    lastCmd:AddAlias("last")
    lastCmd:SetDescription("Teleport to your last visited house")
    lastCmd:SetCallback(function(_)
        local lv = VisitHouse.db.lastVisit
        if not lv then
            Print("No previous visit recorded.")
            return
        end
        DoTeleport(lv.player, lv.houseName, lv.houseId)
    end)

    -- /visit find <partial> — search house names by substring
    local findCmd = command:RegisterSubCommand()
    findCmd:AddAlias("find")
    findCmd:SetDescription("Search for houses by partial name")
    findCmd:SetCallback(function(input)
        if IsEmpty(input) then
            Print("Usage: /visit find <partial house name>")
            return
        end
        local lower   = input:lower()
        local matches = {}
        for _, house in ipairs(houses) do
            if house.name:lower():find(lower, 1, true) then
                table.insert(matches, house.name)
            end
        end
        local total = #matches
        if total == 0 then
            Print("No houses found matching \"" .. input .. "\".")
            return
        end
        local shown = math.min(total, 5)
        for i = 1, shown do
            Print(matches[i])
        end
        if total > 5 then
            Print("(" .. (total - 5) .. " more result(s) — try refining your search.)")
        end
    end)

    -- /visit saved [alias] — use a saved alias, or list all when called with no argument.
    -- Aliases added via /visit save are registered as sub-commands of savedCmd so that
    -- LibSlashCommander can provide autocomplete for them.
    local savedCmd = command:RegisterSubCommand()
    savedCmd:AddAlias("saved")
    savedCmd:SetDescription("Use a saved house alias, or list all saved aliases")
    savedCmd:SetCallback(function(input)
        if IsEmpty(input) then
            local aliases = VisitHouse.db.savedAliases
            local list    = {}
            for alias, _ in pairs(aliases) do
                table.insert(list, alias)
            end
            table.sort(list)
            if #list == 0 then
                Print("No saved aliases. Use /visit save <alias> @player [house name] to create one.")
                return
            end
            for _, alias in ipairs(list) do
                local data = aliases[alias]
                local dest = data.houseName and ('"' .. data.houseName .. '"') or "primary residence"
                Print(alias .. " → " .. data.player .. "'s " .. dest)
            end
        else
            -- Fallback for aliases registered mid-session (before /reloadui)
            local alias = input:gsub("^%s*(.-)%s*$", "%1")
            local data  = VisitHouse.db.savedAliases[alias]
            if not data then
                Print("No saved alias found for \"" .. alias .. "\".")
                return
            end
            DoTeleport(data.player, data.houseName, data.houseId)
        end
    end)

    -- Register aliases from previous sessions as sub-commands of savedCmd at load time
    for alias, _ in pairs(VisitHouse.db.savedAliases) do
        local sub = savedCmd:RegisterSubCommand()
        sub:AddAlias(alias)
        sub:SetCallback(function(_)
            local data = VisitHouse.db.savedAliases[alias]
            if not data then
                Print("No saved alias found for \"" .. alias .. "\". It may have been removed.")
                return
            end
            DoTeleport(data.player, data.houseName, data.houseId)
        end)
    end

    -- /visit save <alias> <@player> [house name] — create a saved alias
    local saveCmd = command:RegisterSubCommand()
    saveCmd:AddAlias("save")
    saveCmd:SetDescription("Save an alias for a player's house")
    saveCmd:SetCallback(function(input)
        if IsEmpty(input) then
            Print("Usage: /visit save <alias> @player [house name]")
            return
        end
        local alias      = input:match("^(%S+)")
        local afterAlias = input:match("^%S+%s+(.*)")
        if not alias or not afterAlias then
            Print("Usage: /visit save <alias> @player [house name]")
            return
        end
        local player      = afterAlias:match("^(%S+)")
        local afterPlayer = afterAlias:match("^%S+%s+(.*)")
        if not player then
            Print("Usage: /visit save <alias> @player [house name]")
            return
        end
        local houseName = afterPlayer and afterPlayer:gsub("^%s*(.-)%s*$", "%1") or ""
        if not StartsWith(player, "@") then
            player = "@" .. player
        end

        local houseId, canonicalName
        if not IsEmpty(houseName) then
            houseId, canonicalName = FindHouseId(houseName, houses)
            if not houseId then
                Print("Unable to find a house named " .. houseName .. HOUSE_NOT_FOUND_MSG)
                return
            end
        end

        VisitHouse.db.savedAliases[alias] = {
            player    = player,
            houseName = canonicalName,
            houseId   = houseId,
        }

        -- Dynamically register as a sub-command of savedCmd for mid-session use
        local sub = savedCmd:RegisterSubCommand()
        sub:AddAlias(alias)
        sub:SetCallback(function(_)
            local data = VisitHouse.db.savedAliases[alias]
            if not data then
                Print("No saved alias found for \"" .. alias .. "\". It may have been removed.")
                return
            end
            DoTeleport(data.player, data.houseName, data.houseId)
        end)

        if canonicalName then
            Print('Saved "' .. alias .. '" → ' .. player .. '\'s "' .. canonicalName .. '".')
        else
            Print('Saved "' .. alias .. '" → ' .. player .. "'s primary residence.")
        end
    end)

    -- /visit unsave <alias> — remove a saved alias
    local unsaveCmd = command:RegisterSubCommand()
    unsaveCmd:AddAlias("unsave")
    unsaveCmd:SetDescription("Remove a saved house alias")
    unsaveCmd:SetCallback(function(input)
        local alias = input and input:gsub("^%s*(.-)%s*$", "%1") or ""
        if IsEmpty(alias) then
            Print("Usage: /visit unsave <alias>")
            return
        end
        if not VisitHouse.db.savedAliases[alias] then
            Print("No saved alias found for \"" .. alias .. "\".")
            return
        end
        VisitHouse.db.savedAliases[alias] = nil
        Print('Removed alias "' .. alias .. '". It may still appear in autocomplete until you /reloadui.')
    end)

    -- One sub-command per known player, with house-name autocomplete
    local playerDisplayName = GetDisplayName()
    local allPlayers        = LoadPlayers(playerDisplayName)

    for _, player in ipairs(allPlayers) do
        local subCmd = command:RegisterSubCommand()
        subCmd:AddAlias(player)
        subCmd:SetCallback(function(input)
            VisitHouseAutoComplete({ player = player, house = input }, houses)
        end)
        subCmd:SetAutoComplete(houseNames)
    end
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------

-- NOTE: The player autocomplete list is built once at load. LibSlashCommander
-- does not expose a way to cleanly remove and re-add sub-commands on an
-- already-registered root command, so /reloadui is the standard refresh path.

function VisitHouse.OnAddOnLoaded(eventCode, addonName)
    if addonName ~= VisitHouse.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(VisitHouse.name, EVENT_ADD_ON_LOADED)
    VisitHouse.db = ZO_SavedVars:NewAccountWide("VisitHouseSavedVars", 2, nil, {
        lastVisit    = nil,
        savedAliases = {},
    })
    local houses = LoadHouses()
    RegisterCommands(houses)
    EVENT_MANAGER:RegisterForEvent(
        VisitHouse.name,
        EVENT_JUMP_FAILED,
        function(_, reason)
            if not jumpPending then return end
            jumpPending = false
            local msg = JUMP_FAIL_MESSAGES[reason] or ("Teleport failed (reason: " .. tostring(reason) .. ").")
            Print(msg)
        end
    )
end

EVENT_MANAGER:RegisterForEvent(
    VisitHouse.name,
    EVENT_ADD_ON_LOADED,
    VisitHouse.OnAddOnLoaded
)
