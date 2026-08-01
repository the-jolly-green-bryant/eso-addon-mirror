local C = Conductor
local SRC = SupportRotationCallouts
C.RaidPlanCompiler = C.RaidPlanCompiler or {}
local Compiler = C.RaidPlanCompiler

local function Normalize(value) return C.NormalizeAccountName and C:NormalizeAccountName(value or "") or tostring(value or "") end
local function Copy(value) if type(value)~="table" then return value end local o={} for k,v in pairs(value) do o[k]=Copy(v) end return o end
local RESPONSIBILITIES={"WARHORN","BARRIER","MAJOR_SLAYER","MAJOR_VULNERABILITY","PILLAGER","NAZARAY","MAJOR_BRITTLE","POWERFUL_ASSAULT"}

local function CapabilityPlayer(sessionPlayer)
    local account=Normalize(sessionPlayer.accountName)
    local db=C.Database and C.Database:GetPlayer(account) or nil
    return db or sessionPlayer
end
local function CanProvide(player,key)
    return C.AssignmentEngine and C.AssignmentEngine:CanPlayerProvide(player,{key=key,effectKey=key}) or false
end
local function RoleRank(player)
    local role=string.upper(tostring(player.combatRole or player.role or "")); if role=="HEALER" then return 1 elseif role=="TANK" then return 2 else return 3 end
end
local function ResolveResponsibilities(session, overrides)
    local output, unresolved, used={}, {}, {}
    overrides=overrides or {}
    for _,key in ipairs(RESPONSIBILITIES) do
        local explicit=Normalize(overrides[key])
        if explicit~="" then output[key]={responsibilityKey=key,assignedAccount=explicit,player=explicit,resolutionSource="MANUAL"}; used[explicit]=true
        else
            local providers={}
            for _,sessionPlayer in ipairs(session.players or {}) do local player=CapabilityPlayer(sessionPlayer); if CanProvide(player,key) then providers[#providers+1]={session=sessionPlayer,player=player} end end
            table.sort(providers,function(a,b) local ar,br=RoleRank(a.session),RoleRank(b.session); if ar~=br then return ar<br end return Normalize(a.session.accountName)<Normalize(b.session.accountName) end)
            local selected=providers[1]
            if selected then local account=Normalize(selected.session.accountName); output[key]={responsibilityKey=key,assignedAccount=account,player=account,resolutionSource="EQUIPPED_PROVIDER"}; used[account]=true
            else unresolved[#unresolved+1]=key end
        end
    end
    return output,unresolved
end
local function BuildGroups(players,format)
    local supports,dds={},{}
    for _,p in ipairs(players or {}) do if tostring(p.combatRole)=="DD" then dds[#dds+1]=Normalize(p.accountName) else supports[#supports+1]=Normalize(p.accountName) end end
    local count=format=="THREE_TEAMS_OF_FOUR" and 3 or 4
    local size=format=="THREE_TEAMS_OF_FOUR" and 4 or 3
    local groups={}; for i=1,count do groups[i]={id=i,players={}} end
    local gi=1
    for _,account in ipairs(supports) do if #groups[gi].players<size then groups[gi].players[#groups[gi].players+1]=account end; gi=(gi%count)+1 end
    gi=1
    for _,account in ipairs(dds) do local attempts=0 while #groups[gi].players>=size and attempts<count do gi=(gi%count)+1; attempts=attempts+1 end; if #groups[gi].players<size then groups[gi].players[#groups[gi].players+1]=account end; gi=(gi%count)+1 end
    return groups
end
function Compiler:Compile(session, options)
    if type(session)~="table" then return nil,"No active Raid Session is available." end
    options=options or {}; local saved=SRC.saved or {}
    local strategy=C.RaidStrategies and C.RaidStrategies:GetById(options.strategyId or saved.raidPlanStrategyId) or nil
    if not strategy and C.RaidStrategies then strategy=C.RaidStrategies:GetRecommended(session.trial,session.difficulty,session.objective) end
    if not strategy then return nil,"No Raid Plan strategy is available for the selected encounter." end
    local format=tostring(options.trashTeamFormat or saved.raidPlanTrashTeamFormat or strategy.trashTeamFormat or "FOUR_TEAMS_OF_THREE")
    if format=="RECOMMENDED" then format=strategy.trashTeamFormat or "FOUR_TEAMS_OF_THREE" end
    local responsibilities,unresolved=ResolveResponsibilities(session,saved.raidPlanManualResponsibilities)
    local groups
    if format == "CUSTOM" then
        groups = {}
        for team=1,4 do
            if saved["trashUltimateTeam"..team.."Enabled"] == true then
                groups[#groups+1] = { id=team, players=Copy(saved["trashUltimateTeam"..team] or {}) }
            end
        end
        if #groups == 0 then groups=BuildGroups(session.players,"FOUR_TEAMS_OF_THREE") end
    else
        groups=BuildGroups(session.players,format)
    end
    local assignments={trashUltimateGroups=Copy(groups),ultimateGroups=Copy(groups),responsibilities=Copy(responsibilities)}
    local bossPlans={ default={ultimatePattern=strategy.ultimatePattern or "OPENING_RECOVERY_EXECUTE",preBossPolicy=strategy.preBossPolicy or "HOLD_FINAL_PULL"} }
    local plan=C.RaidPlan:New({hostAccount=session.hostAccount,trial=session.trial,difficulty=session.difficulty,objective=session.objective,
        strategyId=strategy.id,strategyLabel=strategy.label,strategyVersion=strategy.version,verificationLevel=strategy.verification,
        planningMode=options.planningMode or saved.raidPlanPlanningMode or "RECOMMENDED",players=session.players,
        responsibilities=responsibilities,assignments=assignments,trashPlan={teamFormat=format,defaultPattern="ROTATE",groups=groups,preBossPolicy=strategy.preBossPolicy or "HOLD_FINAL_PULL",pullOverrides={}},bossPlans=bossPlans,unresolved=unresolved})
    session.strategy=strategy.id; session.assignments=Copy(assignments); session.responsibilities=Copy(responsibilities); session.raidPlan=Copy(plan)
    saved.activeRaidPlan=Copy(plan); saved.raidPlanStrategyId=strategy.id; saved.raidPlanTrashTeamFormat=format
    for team=1,4 do local group=groups[team]; saved["trashUltimateTeam"..team.."Enabled"]=group~=nil; saved["trashUltimateTeam"..team.."Count"]=group and #group.players or 1; saved["trashUltimateTeam"..team]=group and Copy(group.players) or {"","","","","",""} end
    if C.EventBus then C.EventBus:Publish("RAID_PLAN_COMPILED",{plan=plan,session=session}) end
    return plan
end
function Compiler:Initialize() self.initialized=true end
