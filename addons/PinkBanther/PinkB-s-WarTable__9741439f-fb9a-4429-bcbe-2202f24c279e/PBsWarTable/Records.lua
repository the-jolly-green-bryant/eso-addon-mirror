-- Account-wide aggregates and a bounded journal. Never alters gameplay state.
local R={seen=setmetatable({}, {__mode='k'})}; PBWT.Records=R
function R.Initialize(saved)
    if not saved then
        saved=ZO_SavedVars and ZO_SavedVars:NewAccountWide('PBsWarTableSavedVariables',1,nil,{}) or {}
    end
    saved.totals=saved.totals or {}; saved.history=saved.history or {}; saved.onlineKeys=saved.onlineKeys or {}
    saved.presentation=saved.presentation~='light' and 'full' or 'light'
    if saved.music==nil then saved.music=true end
    R.saved=saved
end
function R.Data() if not R.saved then R.Initialize() end; return R.saved end
function R.Category(state,mode,difficulty)
    if mode~='solo' then return 'online' end
    local variant=state.variant or 'light'
    return variant=='light' and difficulty or (variant..':'..difficulty)
end
function R.Record(state,mode,difficulty,seat,key)
    local data=R.Data()
    if state.status~='finished' or mode=='local' or R.seen[state] then return false end
    if mode~='solo' and mode~='online' then return false end
    if seat~=1 and seat~=2 then return false end
    if mode=='online' then
        if not key then return false end
        for _,old in ipairs(data.onlineKeys) do if old==key then R.seen[state]=true; return false end end
        table.insert(data.onlineKeys,key); if #data.onlineKeys>100 then table.remove(data.onlineKeys,1) end
    end
    R.seen[state]=true
    local category=R.Category(state,mode,difficulty)
    local t=data.totals[category] or {wins=0,losses=0,draws=0,games=0,turns=0}
    data.totals[category]=t
    local outcome=state.winner==0 and 'draws' or state.winner==seat and 'wins' or 'losses'
    t[outcome]=t[outcome]+1; t.games=t.games+1; t.turns=t.turns+state.turn
    table.insert(data.history,1,{variant=state.variant or 'light',faction=state.factions and state.factions[seat] or 0,opponentFaction=state.factions and state.factions[3-seat] or 0,category=category,outcome=outcome,score=state.score[seat],opponentScore=state.score[3-seat],turns=state.turn,reason=state.reason,time=GetTimeStamp and GetTimeStamp() or 0})
    if #data.history>20 then table.remove(data.history) end
    return true
end
function R.ObserveMatch(match)
    if match.phase~='finished' or match.pending then return false end
    return R.Record(match.state,'online',nil,match.seat,tostring(match.peer)..':'..tostring(match.session))
end
function R.Text(index)
    local data=R.Data(); local lines={PBWT.L("rec_title"),''}
    -- Each board keeps its own tally; the light one holds the original keys.
    for _,group in ipairs({{PBWT.L("rec_standard"),'standard:'},{PBWT.L("rec_light"),''}}) do
        for _,item in ipairs({{'beginner',PBWT.L("rec_beginner")},{'intermediate',PBWT.L("rec_intermediate")},{'advanced',PBWT.L("rec_advanced")}}) do
            local t=data.totals[group[2]..item[1]] or {wins=0,losses=0,draws=0}
            lines[#lines+1]=string.format(PBWT.L("rec_line"),group[1],item[2],t.wins,t.losses,t.draws)
        end
    end
    local online=data.totals.online or {wins=0,losses=0,draws=0}
    lines[#lines+1]=string.format(PBWT.L("rec_online"),online.wins,online.losses,online.draws)
    lines[#lines+1]=PBWT.L("rec_presentation")..(data.presentation=='light' and PBWT.L("rec_light") or PBWT.L("rec_full"))
    lines[#lines+1]=PBWT.L("main_music_label")..(data.music==false and PBWT.L("rec_music_off") or PBWT.L("rec_music_on"))
    lines[#lines+1]=PBWT.L("rec_hint")
    index=math.max(1,math.min(index or 1,#data.history))
    local last=data.history[index]
    if last then
        local outcomes={wins=PBWT.L("rec_win"),losses=PBWT.L("rec_loss"),draws=PBWT.L("rec_draw")}
        lines[#lines+1]=string.format(PBWT.L("rec_history"),index,#data.history,outcomes[last.outcome],last.score,last.opponentScore,last.turns)
        if last.variant=='standard' then lines[#lines+1]=PBWT.L("rec_board_standard") end
        if last.reason=='elder_scroll' then lines[#lines+1]=PBWT.L("rec_by_scroll") end
        if last.reason=='emperor' then lines[#lines+1]=PBWT.L("rec_by_emperor") end
    end
    return table.concat(lines,'\n')
end
