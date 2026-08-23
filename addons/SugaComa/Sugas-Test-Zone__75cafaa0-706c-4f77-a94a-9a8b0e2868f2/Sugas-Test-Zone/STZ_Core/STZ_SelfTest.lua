local STZ = SUGAS_TEST_ZONE
STZ.SelfTest = STZ.SelfTest or {}
local SelfTest = STZ.SelfTest

local function YesNo(value)
    return value and "YES" or "NO"
end

local function JoinIds(ids)
    if type(ids) ~= "table" or #ids == 0 then return "(none)" end
    local text = {}
    for _, guildId in ipairs(ids) do
        text[#text + 1] = tostring(tonumber(guildId) or 0)
    end
    return table.concat(text, ", ")
end

function SelfTest:RunOwnerCheck()
    local accountName = STZ.Access:GetAccountName()
    local passed = STZ.Access:IsOwner()
    STZ:Log(string.format(
        "[STZ] Owner check: %s %s.",
        accountName ~= "" and accountName or "(unknown)",
        passed and "confirmed" or "not the owner"
    ))
    return passed
end

-- Compatibility alias retained for the existing button and slash command name.
function SelfTest:RunAccountCheck()
    return self:RunOwnerCheck()
end

function SelfTest:RunGuildCheck()
    local result = STZ.Access:CheckGuilds()
    STZ:Log(string.format("[STZ] Approved guild IDs: %s", JoinIds(result.approvedIds)))

    if #result.matchedGuilds > 0 then
        for _, guild in ipairs(result.matchedGuilds) do
            STZ:Log(string.format(
                "[STZ] Approved membership: %s (ID %d)",
                tostring(guild.name or "Unknown Guild"),
                tonumber(guild.id) or 0
            ))
        end
    end

    STZ:Log(string.format("[STZ] Guild access: %s", YesNo(result.authorised)))
    STZ:Log(string.format("[STZ] Guild check reason: %s", tostring(result.reason or "Unknown")))
    return result.authorised
end

function SelfTest:RunFullCheck()
    STZ:Log("[STZ] ----- FULL SELF-TEST START -----")
    local ownerPassed = self:RunOwnerCheck()
    local guildPassed = self:RunGuildCheck()
    local overall, reason = STZ.Access:IsAuthorised()
    STZ:Log(string.format("[STZ] Access mode: %s", tostring(STZ.Config.access.mode)))
    STZ:Log(string.format("[STZ] Owner result: %s", YesNo(ownerPassed)))
    STZ:Log(string.format("[STZ] Guild result: %s", YesNo(guildPassed)))
    STZ:Log(string.format("[STZ] Final access result: %s", YesNo(overall)))
    STZ:Log(string.format("[STZ] Access reason: %s", tostring(reason)))
    STZ:Log("[STZ] ----- FULL SELF-TEST END -----")

    if STZ.sv then
        STZ.sv.lastSelfTest = {
            timestamp = type(GetTimeStamp) == "function" and GetTimeStamp() or 0,
            ownerPassed = ownerPassed,
            guildPassed = guildPassed,
            overall = overall,
            reason = reason,
        }
    end
    return overall
end

