local STZ = SUGAS_TEST_ZONE
STZ.Menu = STZ.Menu or {}
local Menu = STZ.Menu

local ACCESS_MODE_ITEMS = {
    { name = "Private - Me only", data = "private" },
    { name = "Guild Testing - Me + approved guilds", data = "guild" },
    { name = "Public", data = "public" },
}

local function FindItemName(items, wantedData, fallbackName)
    for _, item in ipairs(items) do
        if item and item.data == wantedData then
            return tostring(item.name or fallbackName)
        end
    end
    return fallbackName
end

local function ResolveSelectedData(item, name, items, fallback)
    if type(item) == "table" and item.data ~= nil then
        return item.data
    end
    local selectedName = tostring(name or "")
    for _, candidate in ipairs(items) do
        if candidate and tostring(candidate.name or "") == selectedName then
            return candidate.data
        end
    end
    return fallback
end

local function CopyApprovedIds()
    local result = {}
    local seen = {}
    local source = STZ.Config and STZ.Config.access and STZ.Config.access.approvedGuildIds or {}
    if type(source) ~= "table" then return result end

    for _, value in ipairs(source) do
        local guildId = tonumber(value) or 0
        if guildId > 0 and not seen[guildId] then
            seen[guildId] = true
            result[#result + 1] = guildId
        end
    end
    return result
end

local function SaveApprovedIds(ids)
    local cleaned = {}
    local seen = {}
    if type(ids) == "table" then
        for _, value in ipairs(ids) do
            local guildId = tonumber(value) or 0
            if guildId > 0 and not seen[guildId] then
                seen[guildId] = true
                cleaned[#cleaned + 1] = guildId
            end
        end
    end

    STZ.Config.access.approvedGuildIds = cleaned
    if STZ.sv then
        STZ.sv.approvedGuildIds = cleaned
        STZ.sv.guildId = nil
        STZ.sv.guildName = nil
        STZ.sv.guildRole = nil
    end
end

local function SetGuildApproved(guildId, enabled)
    local wantedId = tonumber(guildId) or 0
    if wantedId <= 0 then return end

    local approved = CopyApprovedIds()
    local updated = {}
    local alreadyIncluded = false

    for _, value in ipairs(approved) do
        local existingId = tonumber(value) or 0
        if existingId == wantedId then
            alreadyIncluded = true
            if enabled then updated[#updated + 1] = existingId end
        elseif existingId > 0 then
            updated[#updated + 1] = existingId
        end
    end

    if enabled and not alreadyIncluded then
        updated[#updated + 1] = wantedId
    end

    SaveApprovedIds(updated)
end

local function BuildGuildRows()
    local rows = {}
    local included = {}

    for _, guild in ipairs(STZ.Access:GetGuilds()) do
        local guildId = guild and tonumber(guild.id) or 0
        if guildId > 0 and not included[guildId] then
            included[guildId] = true
            rows[#rows + 1] = {
                id = guildId,
                name = tostring(guild.name or string.format("Guild %d", guildId)),
                currentMember = true,
            }
        end
    end

    -- Keep previously approved IDs visible even after the owner leaves that
    -- guild, so stale access can be switched off instead of remaining hidden.
    for _, value in ipairs(CopyApprovedIds()) do
        local guildId = tonumber(value) or 0
        if guildId > 0 and not included[guildId] then
            included[guildId] = true
            rows[#rows + 1] = {
                id = guildId,
                name = string.format("Guild ID %d (not on this account)", guildId),
                currentMember = false,
            }
        end
    end

    return rows
end

function Menu:Initialize()
    local lib = LibHarvensAddonSettings
    if lib == nil or type(lib.AddAddon) ~= "function" then
        STZ:Log("[STZ] LHAS not available. Use /stzaccount, /stzguild, /stzfull and /stzguilds.")
        return
    end
    if lib.ST_DROPDOWN == nil or lib.ST_CHECKBOX == nil or lib.ST_BUTTON == nil then
        STZ:Log("[STZ] LHAS console controls unavailable. Settings menu was not registered.")
        return
    end

    local settings = lib:AddAddon("Suga's Test Zone", {
        allowDefaults = false,
        allowRefresh = false,
    })
    if settings == nil or type(settings.AddSetting) ~= "function" then
        STZ:Log("[STZ] LHAS loaded but the expected settings API was unavailable.")
        return
    end

    local owner = STZ.Access:IsOwner()
    if owner then
        settings:AddSetting({
            type = lib.ST_DROPDOWN,
            label = "Access mode",
            items = ACCESS_MODE_ITEMS,
            getFunction = function()
                return FindItemName(ACCESS_MODE_ITEMS, STZ.Config.access.mode, "Private - Me only")
            end,
            setFunction = function(_, name, item)
                local value = ResolveSelectedData(item, name, ACCESS_MODE_ITEMS, "private")
                STZ.Config.access.mode = value
                if STZ.sv then STZ.sv.accessMode = value end
            end,
        })

        if lib.ST_SECTION ~= nil then
            settings:AddSetting({
                type = lib.ST_SECTION,
                label = "Approved guilds",
            })
        end

        local guildRows = BuildGuildRows()
        for _, guildRow in ipairs(guildRows) do
            local guildId = guildRow.id
            local guildName = guildRow.name
            settings:AddSetting({
                type = lib.ST_CHECKBOX,
                label = guildName,
                tooltip = string.format(
                    "Guild ID %d. When enabled, membership in this guild grants STZ access in Guild Testing mode.",
                    guildId
                ),
                default = false,
                getFunction = function()
                    return STZ.Access:IsGuildIdApproved(guildId)
                end,
                setFunction = function(state)
                    SetGuildApproved(guildId, state == true)
                end,
            })
        end
    end

    if STZ.AbilityTools and type(STZ.AbilityTools.AddSettings) == "function" then
        STZ.AbilityTools:AddSettings(settings, lib)
    end

    settings:AddSetting({
        type = lib.ST_BUTTON,
        label = "Run owner check",
        buttonText = "Run",
        clickHandler = function()
            if STZ.SelfTest and type(STZ.SelfTest.RunOwnerCheck) == "function" then
                STZ.SelfTest:RunOwnerCheck()
            end
        end,
    })

    settings:AddSetting({
        type = lib.ST_BUTTON,
        label = "Run approved-guild check",
        buttonText = "Run",
        clickHandler = function()
            if STZ.SelfTest and type(STZ.SelfTest.RunGuildCheck) == "function" then
                STZ.SelfTest:RunGuildCheck()
            end
        end,
    })

    settings:AddSetting({
        type = lib.ST_BUTTON,
        label = "Run full self-test",
        buttonText = "Run",
        clickHandler = function()
            if STZ.SelfTest and type(STZ.SelfTest.RunFullCheck) == "function" then
                STZ.SelfTest:RunFullCheck()
            end
        end,
    })
end
