local C = Conductor
C.RaidPlan = C.RaidPlan or {}
local RaidPlan = C.RaidPlan
RaidPlan.SCHEMA_VERSION = 1
RaidPlan.MAX_PLAYERS = 12
RaidPlan.MAX_SERIALIZED_BYTES = 32000

local function Copy(value)
    if type(value) ~= "table" then return value end
    local output = {}; for key,item in pairs(value) do output[key]=Copy(item) end; return output
end
local function Normalize(value)
    if C.NormalizeAccountName then return C:NormalizeAccountName(value or "") end
    return tostring(value or "")
end
local function Now() return GetTimeStamp and GetTimeStamp() or 0 end

function RaidPlan:New(config)
    config=config or {}
    local host=Normalize(config.hostAccount or (GetDisplayName and GetDisplayName() or ""))
    local planId=tostring(config.planId or string.format("RP-%s-%d", string.gsub(host,"[^%w]",""), Now()))
    local participants={}
    for _, player in ipairs(config.players or config.participants or {}) do
        local account=Normalize(type(player)=="table" and player.accountName or player)
        if account ~= "" then participants[#participants+1]={accountName=account,rosterSlot=type(player)=="table" and player.rosterSlot or nil,combatRole=type(player)=="table" and player.combatRole or nil,classKey=type(player)=="table" and player.classKey or nil} end
    end
    return {
        planSchemaVersion=self.SCHEMA_VERSION, snapshotSchemaVersion=self.SCHEMA_VERSION,
        planId=planId, sessionId=planId, revision=tonumber(config.revision) or 1, sessionRevision=tonumber(config.revision) or 1,
        hostAccount=host, createdAt=Now(), sharedAt=Now(), teamName=tostring(config.teamName or config.trial or "Raid Plan"),
        trial=tostring(config.trial or ""), difficulty=tostring(config.difficulty or ""), objective=tostring(config.objective or ""),
        strategyId=tostring(config.strategyId or config.strategy or ""), strategy=tostring(config.strategyLabel or config.strategy or ""),
        strategyVersion=tonumber(config.strategyVersion) or 1, verificationLevel=tostring(config.verificationLevel or "FOUNDATION"),
        planningMode=tostring(config.planningMode or "RECOMMENDED"), players=participants,
        rosterMapping=Copy(config.rosterMapping or {}), responsibilities=Copy(config.responsibilities or {}),
        assignments=Copy(config.assignments or {}), trashPlan=Copy(config.trashPlan or {}), bossPlans=Copy(config.bossPlans or {}),
        manualOverrides=Copy(config.manualOverrides or {}), unresolved=Copy(config.unresolved or {}),
        payloadType="RAID_PLAN",
    }
end
function RaidPlan:ContainsPlayer(plan, accountName)
    local wanted=Normalize(accountName); if wanted=="" then return false end
    for _,player in ipairs(plan and plan.players or {}) do if Normalize(player.accountName)==wanted then return true end end
    return false
end
function RaidPlan:Validate(plan, outgoing)
    if type(plan)~="table" then return false,"Raid Plan is not a table." end
    if tonumber(plan.planSchemaVersion or plan.snapshotSchemaVersion)~=self.SCHEMA_VERSION then return false,"Unsupported Raid Plan schema." end
    if tostring(plan.planId or plan.sessionId or "")=="" then return false,"Raid Plan is missing its ID." end
    if Normalize(plan.hostAccount)=="" then return false,"Raid Plan is missing its host account." end
    if type(plan.players)~="table" or #plan.players<1 or #plan.players>self.MAX_PLAYERS then return false,"Raid Plan roster is invalid." end
    if type(plan.responsibilities)~="table" or type(plan.assignments)~="table" or type(plan.trashPlan)~="table" then return false,"Raid Plan assignments are invalid." end
    local seen={}
    for _,player in ipairs(plan.players) do local account=Normalize(player.accountName); if account=="" or seen[account] then return false,"Raid Plan contains an invalid or duplicate player." end; player.accountName=account; seen[account]=true end
    if outgoing and not self:ContainsPlayer(plan,plan.hostAccount) then return false,"Raid Plan host is not in the roster." end
    local format=tostring(plan.trashPlan.teamFormat or "")
    if format~="" and format~="FOUR_TEAMS_OF_THREE" and format~="THREE_TEAMS_OF_FOUR" and format~="CUSTOM" then return false,"Raid Plan has an invalid trash-team format." end
    return true
end
function RaidPlan:Copy(value) return Copy(value) end
