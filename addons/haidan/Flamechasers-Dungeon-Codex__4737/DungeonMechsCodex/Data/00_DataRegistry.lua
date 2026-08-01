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

function DMC.GetDungeonById(id)
    return DMC.data.dungeonById[id]
end

function DMC.GetDungeonsSorted(searchText)
    local search = DMC.NormalizeText(searchText or "")
    local currentZoneName = DMC.NormalizeText(DMC.GetCurrentZoneName())
    local out = {}

    for _, dungeon in ipairs(DMC.data.dungeons) do
        local haystack = DMC.NormalizeText((dungeon.name or "") .. " " .. (dungeon.dlc or "") .. " " .. table.concat(dungeon.aliases or {}, " "))
        if search == "" or haystack:find(search, 1, true) then
            table.insert(out, dungeon)
        end
    end

    table.sort(out, function(a, b)
        local ac = DMC.IsCurrentDungeon(a) and 1 or 0
        local bc = DMC.IsCurrentDungeon(b) and 1 or 0
        if ac ~= bc then return ac > bc end
        if (a.status == "complete") ~= (b.status == "complete") then return a.status == "complete" end
        return (a.name or "") < (b.name or "")
    end)

    return out
end

function DMC.GetBossById(dungeon, bossId)
    if not dungeon or not bossId then return nil end
    for _, boss in ipairs(dungeon.bosses or {}) do
        if boss.id == bossId then return boss end
    end
    return nil
end

function DMC.MechanicMatchesRole(mech, role)
    if not mech then return false end
    if role == nil or role == "all" then return true end
    if role == "quick" then
        return (mech.quick ~= nil and mech.quick ~= "") or (mech.quickChat ~= nil and #mech.quickChat > 0)
    end
    if mech.roles then
        for _, r in ipairs(mech.roles) do
            if r == role or r == "all" then return true end
        end
    end
    return mech[role] ~= nil and mech[role] ~= ""
end

function DMC.GetRoleText(mech, role)
    if not mech then return "" end
    if role and role ~= "all" and mech[role] and mech[role] ~= "" then
        return mech[role]
    end
    return mech.all or mech.general or ""
end

function DMC.GetTagText(tags)
    if not tags or #tags == 0 then return "" end
    return "[" .. table.concat(tags, "][") .. "]"
end
