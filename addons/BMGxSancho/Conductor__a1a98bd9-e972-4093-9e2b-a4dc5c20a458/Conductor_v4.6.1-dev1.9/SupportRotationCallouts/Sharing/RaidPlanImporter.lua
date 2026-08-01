local C = Conductor
local SRC = SupportRotationCallouts
C.RaidPlanImporter = C.RaidPlanImporter or {}
local Importer=C.RaidPlanImporter
local function Copy(value) if type(value)~="table" then return value end local o={} for k,v in pairs(value) do o[k]=Copy(v) end return o end
local function Normalize(value) return C.NormalizeAccountName and C:NormalizeAccountName(value or "") or tostring(value or "") end
function Importer:Import(plan,sender)
    local valid,err=C.RaidPlan:Validate(plan,false); if not valid then return nil,err end
    local strategy=C.RaidStrategies and C.RaidStrategies:GetById(plan.strategyId)
    if not strategy or tonumber(strategy.version)~=tonumber(plan.strategyVersion) then return nil,"The shared strategy is missing or incompatible. Update Conductor and try again." end
    local current=C.RaidSession and C.RaidSession:GetActive() or nil
    local players={}
    if current and type(current.players)=="table" then players=Copy(current.players) else players=Copy(plan.players or {}) end
    local session=C.RaidSession:New({sessionId=plan.planId,sessionVersion=plan.revision,mode=C.RaidSession.MODES.ROSTERED,hostAccount=Normalize(sender or plan.hostAccount),trial=plan.trial,difficulty=plan.difficulty,objective=plan.objective,strategy=plan.strategyId,players=players,assignments=plan.assignments,responsibilities=plan.responsibilities})
    session.raidPlan=Copy(plan); session.remoteHost=true; session.sharedTeamName=plan.teamName
    local imported=C.RaidSession:ApplyRemoteSnapshot(session,"validated shared Raid Plan accepted")
    if not imported then return nil,"The Raid Plan could not be activated." end
    SRC.saved.activeRaidPlan=Copy(plan); SRC.saved.raidPlanStrategyId=plan.strategyId; SRC.saved.raidPlanPlanningMode=plan.planningMode; SRC.saved.raidPlanTrashTeamFormat=(plan.trashPlan or {}).teamFormat
    SRC.saved.sharedRaidSessionId=plan.planId; SRC.saved.sharedRaidSessionHost=Normalize(sender or plan.hostAccount); SRC.saved.sharedRaidSessionName=plan.teamName
    if C.PersonalSession then C.PersonalSession:InitializeFromSession(imported, "shared Raid Plan accepted") end
    if C.EventBus then C.EventBus:Publish("RAID_PLAN_IMPORTED",{session=imported,plan=plan}); C.EventBus:Publish("RAID_SETUP_REFRESH_REQUESTED",{reason="shared Raid Plan imported",session=imported}) end
    return imported
end
