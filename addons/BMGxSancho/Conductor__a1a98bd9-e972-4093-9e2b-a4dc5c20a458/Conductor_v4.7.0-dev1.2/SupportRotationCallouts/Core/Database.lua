local C = Conductor
C.Database = C.Database or {}
local Database = C.Database

Database.players = Database.players or {}

local function NormalizeAccount(name)
    if C.NormalizeAccountName then return C:NormalizeAccountName(name) end
    if not name or name == "" then return "" end
    name = string.lower(tostring(name))
    if string.sub(name, 1, 1) ~= "@" then name = "@" .. name end
    return name
end

local function NewPlayer(accountName)
    return {
        accountName = accountName,
        characterName = "",
        classId = 0,
        role = "UNKNOWN",
        gear = {},
        skills = {},
        ultimates = {},
        effects = {},
        masteries = {},
        championPoints = {},
        capabilities = {},
        responsibilities = {},
        source = "manual",
        conductorVersion = nil,
        networkSeenAt = 0,
        updatedAt = 0,
    }
end

function Database:GetOrCreatePlayer(accountName)
    local key = NormalizeAccount(accountName)
    if key == "" then return nil end
    self.players[key] = self.players[key] or NewPlayer(key)
    return self.players[key]
end

function Database:GetPlayer(accountName)
    return self.players[NormalizeAccount(accountName)]
end

function Database:UpdatePlayer(accountName, patch, source)
    local player = self:GetOrCreatePlayer(accountName)
    if not player or type(patch) ~= "table" then return nil end
    for key, value in pairs(patch) do
        if key ~= "accountName" then player[key] = value end
    end
    player.source = source or player.source or "manual"
    player.updatedAt = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
    if C.EventBus then C.EventBus:Publish("PLAYER_UPDATED", { accountName = player.accountName, player = player, source = source }) end
    return player
end

function Database:GetPlayers()
    local output = {}
    for _, player in pairs(self.players) do output[#output + 1] = player end
    table.sort(output, function(a, b) return tostring(a.accountName) < tostring(b.accountName) end)
    return output
end

function Database:ClearSessionPlayers()
    self.players = {}
    if C.EventBus then C.EventBus:Publish("SESSION_PLAYERS_CLEARED", {}) end
end

function Database:Initialize()
    self.initialized = true
end

function Database:PruneRoster(seen)
    seen = seen or {}
    for key, player in pairs(self.players) do
        if player.source ~= "manual" and not seen[string.lower(key)] then
            self.players[key] = nil
            if C.EventBus then C.EventBus:Publish("PLAYER_LEFT", { accountName = key, player = player }) end
        end
    end
end

function Database:GetPlayerCount()
    local count = 0
    for _ in pairs(self.players) do count = count + 1 end
    return count
end

function Database:GetCapabilitySummary()
    local summary = { players = 0, localPlayers = 0, networkPlayers = 0 }
    for _, player in pairs(self.players) do
        summary.players = summary.players + 1
        if player.isLocalPlayer then summary.localPlayers = summary.localPlayers + 1 end
        if player.source == "network" then summary.networkPlayers = summary.networkPlayers + 1 end
    end
    return summary
end
