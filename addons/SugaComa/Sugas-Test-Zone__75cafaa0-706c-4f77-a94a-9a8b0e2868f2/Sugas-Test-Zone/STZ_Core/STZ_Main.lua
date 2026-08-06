local STZ = SUGAS_TEST_ZONE

local VALID_ACCESS_MODES = {
    private = true,
    guild = true,
    public = true,
}

local function CopyGuildIds(source)
    local result = {}
    local seen = {}
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

local function HasApprovedGuild(ids)
    return type(ids) == "table" and #ids > 0
end

local function RestoreSavedConfiguration()
    local access = STZ.Config.access
    local deploymentMode = tostring(access.deploymentMode or "private")
    access.mode = VALID_ACCESS_MODES[deploymentMode] and deploymentMode or "private"
    access.approvedGuildIds = CopyGuildIds(access.deploymentGuildIds)

    -- Only the hard-coded owner may apply local SavedVariable overrides. Other
    -- users always receive the deployment rules shipped in STZ_Config.lua.
    if not STZ.Access:IsOwner() then return end

    local savedMode = tostring(STZ.sv and STZ.sv.accessMode or "")
    if VALID_ACCESS_MODES[savedMode] then
        access.mode = savedMode
    elseif savedMode == "account_or_guild" or savedMode == "guild" then
        access.mode = "guild"
    elseif savedMode == "public" then
        access.mode = "public"
    end

    local savedIds = CopyGuildIds(STZ.sv and STZ.sv.approvedGuildIds)

    -- One-time migration from the former single-guild setting. The selected
    -- numeric guild ID becomes the first approved guild.
    local oldGuildId = tonumber(STZ.sv and STZ.sv.guildId) or 0
    if not HasApprovedGuild(savedIds) and oldGuildId > 0 then
        savedIds[1] = oldGuildId
    end

    if HasApprovedGuild(savedIds) then
        access.approvedGuildIds = savedIds
    end

    if STZ.sv then
        STZ.sv.accessMode = access.mode
        STZ.sv.approvedGuildIds = CopyGuildIds(access.approvedGuildIds)
        STZ.sv.guildId = nil
        STZ.sv.guildName = nil
        STZ.sv.guildRole = nil
    end
end

local function RegisterCommands()
    if type(SLASH_COMMANDS) ~= "table" then return end

    SLASH_COMMANDS["/stzaccount"] = function()
        if STZ.SelfTest and type(STZ.SelfTest.RunOwnerCheck) == "function" then
            STZ.SelfTest:RunOwnerCheck()
        end
    end
    SLASH_COMMANDS["/stzguild"] = function()
        if STZ.SelfTest and type(STZ.SelfTest.RunGuildCheck) == "function" then
            STZ.SelfTest:RunGuildCheck()
        end
    end
    SLASH_COMMANDS["/stzfull"] = function()
        if STZ.SelfTest and type(STZ.SelfTest.RunFullCheck) == "function" then
            STZ.SelfTest:RunFullCheck()
        end
    end
    SLASH_COMMANDS["/stzguilds"] = function()
        STZ:Log("[STZ] Guilds available to this account:")
        local guilds = STZ.Access:GetGuilds()
        if #guilds == 0 then
            STZ:Log("[STZ] - (none)")
            return
        end
        for _, guild in ipairs(guilds) do
            local marker = STZ.Access:IsGuildIdApproved(guild.id) and " [APPROVED]" or ""
            STZ:Log(string.format("[STZ] - %s (ID %d)%s", guild.name, guild.id, marker))
        end
    end
end

function STZ:CanLoadProject(projectName)
    local allowed, reason = self.Access:IsAuthorised()
    if not allowed and self.Notice and type(self.Notice.ShowDenied) == "function" then
        self.Notice:ShowDenied(projectName)
    end
    return allowed, reason
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= STZ.Config.addonName then return end
    local eventManager = EVENT_MANAGER
    if eventManager ~= nil and type(eventManager.UnregisterForEvent) == "function" then
        eventManager:UnregisterForEvent(STZ.Config.addonName, EVENT_ADD_ON_LOADED)
    end

    local defaults = {
        launches = 0,
        accessMode = STZ.Config.access.deploymentMode,
        approvedGuildIds = {},
        lastSelfTest = {},
    }

    local savedVarsManager = ZO_SavedVars
    if savedVarsManager ~= nil and type(savedVarsManager.NewAccountWide) == "function" then
        STZ.sv = savedVarsManager:NewAccountWide("SugasTestZone_SV", 1, nil, defaults)
    else
        STZ.sv = defaults
        STZ:Log("[STZ] SavedVariables API unavailable; using temporary defaults.")
    end

    STZ.sv.launches = (tonumber(STZ.sv.launches) or 0) + 1
    RestoreSavedConfiguration()
    RegisterCommands()

    if STZ.Menu and type(STZ.Menu.Initialize) == "function" then
        STZ.Menu:Initialize()
    end

    local allowed, reason = STZ.Access:IsAuthorised()
    STZ:Log(string.format("[STZ] Access mode: %s", tostring(STZ.Config.access.mode)))
    STZ:Log(string.format("[STZ] Access result: %s (%s)", allowed and "GRANTED" or "DENIED", tostring(reason)))
    STZ:Log("[STZ] Self-test ready. Open LHAS or use /stzfull.")
end

local eventManager = EVENT_MANAGER
if eventManager ~= nil and type(eventManager.RegisterForEvent) == "function" then
    eventManager:RegisterForEvent(STZ.Config.addonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
else
    STZ:Log("[STZ] EVENT_MANAGER:RegisterForEvent unavailable; STZ could not initialize.")
end
