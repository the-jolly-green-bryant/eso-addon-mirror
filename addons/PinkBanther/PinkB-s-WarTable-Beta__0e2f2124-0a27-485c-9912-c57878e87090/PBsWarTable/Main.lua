local function report(message) if d then d('戦卓：'..message) end end
function PBWT.Open(mode,difficulty)
    if PBWT.Config.AI.DIFFICULTIES[mode] then difficulty=mode; mode='solo' end
    mode=(mode=='local' or mode=='online' or mode=='tutorial') and mode or 'solo'
    if PBWT.match and PBWT.match:Busy() then mode='online'; difficulty=nil end
    difficulty=PBWT.AI.Difficulty(difficulty or (PBWT.ui and PBWT.ui.difficulty))
    if mode=='online' and (not PBWT.match or PBWT.match.phase=='idle') then report('進行中の対戦はありません。グループの相手へインタラクトしてください'); return end
    if PBWT.ui and PBWT.ui.transition.phase then
        report('画面切替後に /pbwt online で対戦画面を開けます'); return
    end
    if not PBWT.ui then PBWT.ui=PBWT.UI.New(mode,difficulty) else PBWT.ui:SetMode(mode,difficulty) end
    if mode=='online' then PBWT.ui.network=PBWT.match; PBWT.ui.state=PBWT.match.state end
    PBWT.ui:Show()
end
function PBWT.NetworkChanged(match)
    PBWT.Records.ObserveMatch(match)
    if PBWT.ui and PBWT.ui.mode=='online' then
        PBWT.ui.network=match; PBWT.ui.state=match.state; PBWT.ui.selected,PBWT.ui.card=nil,nil
        PBWT.ui:Refresh()
    end
    if match.phase=='invited' then report(match.message); PBWT.Open('online') end
    if match.phase=='closed' then report(match.message) end
    PBWT.WatchNetwork()
end
function PBWT.WatchNetwork()
    if PBWT.networkTicking then return end
    PBWT.networkTicking=true
    EVENT_MANAGER:RegisterForUpdate('PBsWarTableNetwork',500,function()
        local match=PBWT.match
        if not match or match.phase=='idle' or match.phase=='closed' or
            (match.phase=='finished' and not match.pending and match.terminalAt and GetFrameTimeSeconds()-match.terminalAt>PBWT.Config.NETWORK.TIMEOUT) then
            EVENT_MANAGER:UnregisterForUpdate('PBsWarTableNetwork'); PBWT.networkTicking=false; return
        end
        match:Tick()
    end)
end
function PBWT.Challenge(peer)
    local transport=PBWT.transport
    if not transport or not transport.protocol then report(transport and transport.error or '通信を初期化できません'); return end
    if not transport.protocol:IsEnabled() then report('LibGroupBroadcastで本作の通信が無効です'); return end
    local ok,why=transport:Check(peer,true); if not ok then report(why); return end
    -- Distinct per invite, including after /reloadui; not a security token.
    PBWT.nonce=((PBWT.nonce or GetTimeStamp())+1)%4294967295
    local session=(GetTimeStamp()*1000+GetFrameTimeMilliseconds()+PBWT.nonce)%4294967295+1
    ok,why=PBWT.match:Challenge(peer,session)
    if ok then PBWT.Open('online'); PBWT.WatchNetwork() else report(why) end
end
function PBWT.InitializeNetwork()
    PBWT.transport=PBWT.Transport.New(function(peer,packet) PBWT.match:Receive(peer,packet) end,report)
    PBWT.match=PBWT.Match.New({requireFactions=true,now=GetFrameTimeSeconds,
        send=function(peer,packet) return PBWT.transport:Send(peer,packet) end,
        changed=PBWT.NetworkChanged})
end
local function OnLoaded(_,name)
    if name~='PBsWarTable' then return end
    EVENT_MANAGER:UnregisterForEvent('PBsWarTable',EVENT_ADD_ON_LOADED)
    PBWT.Records.Initialize(); PBWT.Assets.Initialize(); PBWT.InitializeNetwork(); PBWT.HookMenu()
    SLASH_COMMANDS['/pbwt']=function(argument)
        if argument=='sync' then PBWT.match:StartSync()
        elseif argument=='debug' then report(PBWT.transport.error or ('ID508 / '..PBWT.match.phase..' / 行動 '..PBWT.match.seq))
        else PBWT.Open(argument) end
    end
end
EVENT_MANAGER:RegisterForEvent('PBsWarTable',EVENT_ADD_ON_LOADED,OnLoaded)
