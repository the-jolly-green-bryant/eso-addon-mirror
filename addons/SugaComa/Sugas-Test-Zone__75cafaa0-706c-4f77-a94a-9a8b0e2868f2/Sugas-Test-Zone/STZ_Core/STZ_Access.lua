local STZ = SUGAS_TEST_ZONE
STZ.Access = STZ.Access or {}
local Access = STZ.Access

local function SafeNumber(value, fallback)
    local numberValue = tonumber(value)
    if numberValue == nil then return fallback end
    return numberValue
end

local function CopyPositiveIds(source)
    local result = {}
    local seen = {}
    if type(source) ~= "table" then return result end

    for _, value in ipairs(source) do
        local guildId = SafeNumber(value, 0)
        if guildId > 0 and not seen[guildId] then
            seen[guildId] = true
            result[#result + 1] = guildId
        end
    end
    return result
end

function Access:GetAccountName()
    if type(GetDisplayName) ~= "function" then return "" end
    return tostring(GetDisplayName() or "")
end

function Access:IsOwner()
    local config = STZ.Config and STZ.Config.access
    local allowed = config and config.ownerAccounts
    return type(allowed) == "table" and allowed[self:GetAccountName()] == true
end

-- Compatibility alias retained for existing project code and slash commands.
function Access:IsAccountAuthorised()
    return self:IsOwner()
end

function Access:GetGuilds()
    local guilds = {}
    if type(GetNumGuilds) ~= "function"
        or type(GetGuildId) ~= "function"
        or type(GetGuildName) ~= "function" then
        return guilds
    end

    local guildCount = math.max(0, SafeNumber(GetNumGuilds(), 0))
    for guildIndex = 1, guildCount do
        local guildId = SafeNumber(GetGuildId(guildIndex), 0)
        if guildId > 0 then
            local guildName = tostring(GetGuildName(guildId) or "")
            if guildName == "" then
                guildName = string.format("Guild %d", guildId)
            end
            guilds[#guilds + 1] = {
                index = guildIndex,
                id = guildId,
                name = guildName,
            }
        end
    end
    return guilds
end

function Access:FindGuildById(guildId)
    local wantedId = SafeNumber(guildId, 0)
    if wantedId <= 0 then return nil end
    for _, guild in ipairs(self:GetGuilds()) do
        if guild.id == wantedId then return guild end
    end
    return nil
end

function Access:GetApprovedGuildIds()
    local accessConfig = STZ.Config and STZ.Config.access or {}
    return CopyPositiveIds(accessConfig.approvedGuildIds)
end

function Access:GetApprovedGuildSet()
    local approved = {}
    for _, guildId in ipairs(self:GetApprovedGuildIds()) do
        approved[guildId] = true
    end
    return approved
end

function Access:IsGuildIdApproved(guildId)
    local wantedId = SafeNumber(guildId, 0)
    return wantedId > 0 and self:GetApprovedGuildSet()[wantedId] == true
end

function Access:CheckGuilds()
    local approvedIds = self:GetApprovedGuildIds()
    local approvedSet = {}
    for _, guildId in ipairs(approvedIds) do
        approvedSet[guildId] = true
    end

    local result = {
        approvedIds = approvedIds,
        currentGuilds = self:GetGuilds(),
        matchedGuilds = {},
        authorised = false,
        reason = "",
    }

    if #approvedIds == 0 then
        result.reason = "No guild IDs are approved"
        return result
    end

    -- Membership in any one approved guild is sufficient. No rank, guild-master
    -- or other permission check is performed, and other guild memberships cannot
    -- cancel a valid approved-guild match.
    for _, guild in ipairs(result.currentGuilds) do
        if guild and approvedSet[SafeNumber(guild.id, 0)] == true then
            result.authorised = true
            result.matchedGuilds[#result.matchedGuilds + 1] = guild
        end
    end

    if result.authorised then
        result.reason = "Approved guild membership found"
    else
        result.reason = "This account is not a member of an approved guild"
    end
    return result
end

-- Compatibility alias retained for older self-test/project calls.
function Access:CheckGuild()
    return self:CheckGuilds()
end

function Access:IsAuthorised()
    local accessConfig = STZ.Config and STZ.Config.access or {}
    local mode = tostring(accessConfig.mode or "private")

    -- The owner always passes, regardless of the selected deployment mode.
    if self:IsOwner() then
        return true, "Owner access"
    end

    if mode == "public" then
        return true, "Public access"
    end

    if mode == "guild" then
        local guildResult = self:CheckGuilds()
        if guildResult.authorised then
            return true, guildResult.reason
        end
        return false, guildResult.reason
    end

    return false, "Private owner-only access"
end

