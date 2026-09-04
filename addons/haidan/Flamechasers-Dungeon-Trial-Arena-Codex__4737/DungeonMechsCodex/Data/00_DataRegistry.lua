-- Dungeon registry and query helpers.

local DMC = DungeonMechsCodex
DMC.data = DMC.data or { dungeons = {}, dungeonOrder = {}, dungeonById = {} }

function DMC.RegisterDungeon(dungeon)
    if not dungeon or not dungeon.id or not dungeon.name then return end
    dungeon.type = dungeon.type or "DLC Dungeon"
    dungeon.status = dungeon.status or "stub" -- complete, partial, stub
    dungeon.bosses = dungeon.bosses or {}

    -- Allow a full module to replace the stub from 01_DLC_Index.lua.
    if DMC.data.dungeonById[dungeon.id] then
        for i, existing in ipairs(DMC.data.dungeons) do
            if existing.id == dungeon.id then
                DMC.data.dungeons[i] = dungeon
                DMC.data.dungeonById[dungeon.id] = dungeon
                return
            end
        end
    end

    table.insert(DMC.data.dungeons, dungeon)
    table.insert(DMC.data.dungeonOrder, dungeon.id)
    DMC.data.dungeonById[dungeon.id] = dungeon
end

function DMC.RegisterTrial(trial)
    if not trial then return end
    trial.type = "Trial"
    DMC.RegisterDungeon(trial)
end

function DMC.RegisterArena(arena)
    if not arena then return end
    arena.type = "Arena"
    DMC.RegisterDungeon(arena)
end

function DMC.GetActivityKind(activity)
    if activity and activity.type == "Trial" then return "trial" end
    if activity and activity.type == "Arena" then return "arena" end
    return "dungeon"
end

local DEFAULT_ACTIVITY_CAPABILITIES = {
    dungeon = {
        difficulties = {"vet", "hm"},
        roles = {"all", "quick", "tank", "healer", "dps"},
    },
    trial = {
        difficulties = {"vet", "hm"},
        roles = {"all", "quick", "tank", "healer", "dps"},
    },
    -- Arena modules override these when their format supports more. This
    -- conservative default avoids inventing a Hard Mode or group roles for a
    -- solo arena simply because dungeon/trial controls happen to exist.
    arena = {
        difficulties = {"vet"},
        roles = {"all", "quick"},
    },
}

function DMC.GetActivityCapabilities(activity)
    local defaults = DEFAULT_ACTIVITY_CAPABILITIES[DMC.GetActivityKind(activity)]
        or DEFAULT_ACTIVITY_CAPABILITIES.dungeon
    local configured = activity and activity.capabilities or nil
    return {
        difficulties = configured and configured.difficulties or defaults.difficulties,
        roles = configured and configured.roles or defaults.roles,
    }
end

function DMC.ActivitySupports(activity, capability, value)
    local capabilities = DMC.GetActivityCapabilities(activity)
    for _, candidate in ipairs(capabilities[capability] or {}) do
        if candidate == value then return true end
    end
    return false
end

function DMC.GetDungeonById(id)
    return DMC.data.dungeonById[id]
end

function DMC.GetDungeonsSorted(searchText, currentDungeonId, activityKind)
    local search = DMC.NormalizeText(searchText or "")
    local out = {}
    activityKind = (activityKind == "trial" or activityKind == "dungeon" or activityKind == "arena")
        and activityKind or nil

    if currentDungeonId == nil then
        local currentDungeon = DMC.GetCurrentDungeon()
        currentDungeonId = currentDungeon and currentDungeon.id or false
    end

    for _, dungeon in ipairs(DMC.data.dungeons) do
        local haystack = DMC.NormalizeText((dungeon.name or "") .. " " .. (dungeon.dlc or "") .. " " .. table.concat(dungeon.aliases or {}, " "))
        local kindMatches = activityKind == nil or DMC.GetActivityKind(dungeon) == activityKind
        if kindMatches and (search == "" or haystack:find(search, 1, true)) then
            table.insert(out, dungeon)
        end
    end

    table.sort(out, function(a, b)
        local ac = a.id == currentDungeonId and 1 or 0
        local bc = b.id == currentDungeonId and 1 or 0
        if ac ~= bc then return ac > bc end
        if (a.status == "complete") ~= (b.status == "complete") then return a.status == "complete" end
        return (a.name or "") < (b.name or "")
    end)

    return out
end

-- Activity-named aliases keep the public API clear for new code while retaining
-- every dungeon-named entry point used by existing modules and saved installs.
DMC.GetActivityById = DMC.GetDungeonById
DMC.GetActivitiesSorted = DMC.GetDungeonsSorted

function DMC.GetBossById(dungeon, bossId)
    if not dungeon or not bossId then return nil end
    for _, boss in ipairs(dungeon.bosses or {}) do
        if boss.id == bossId then return boss end
    end
    return nil
end

function DMC.MechanicMatchesRole(mech, role, mode)
    if not mech or not DMC.IsVisibleForMode(mech, mode) then return false end
    if role == nil or role == "all" then return true end
    if role == "quick" then
        local quick = DMC.GetModeValue(mech, "quick", mode)
        local quickChat = DMC.GetModeValue(mech, "quickChat", mode)
        return (quick ~= nil and quick ~= "") or (quickChat ~= nil and #quickChat > 0)
    end
    local roles = DMC.GetModeValue(mech, "roles", mode)
    if roles then
        for _, r in ipairs(roles) do
            if r == role or r == "all" then return true end
        end
    end
    local roleText = DMC.GetModeValue(mech, role, mode)
    return roleText ~= nil and roleText ~= ""
end

function DMC.GetRoleText(mech, role, mode)
    if not mech then return "" end
    local roleText = role and role ~= "all" and DMC.GetModeValue(mech, role, mode) or nil
    if roleText and roleText ~= "" then
        return roleText
    end
    return DMC.GetModeValue(mech, "all", mode) or DMC.GetModeValue(mech, "general", mode) or ""
end

function DMC.GetTagText(tags)
    if not tags or #tags == 0 then return "" end
    return "[" .. table.concat(tags, "][") .. "]"
end
