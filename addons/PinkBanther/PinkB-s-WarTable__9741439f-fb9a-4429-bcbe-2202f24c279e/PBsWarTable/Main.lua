local function report(message) if d then d(PBWT.L("main_prefix")..message) end end
function PBWT.Open(mode,difficulty,variant)
    if mode=='' then mode='menu' end
    if mode=='menu' then
        if PBWT.match and PBWT.match:Busy() then mode='online'
        elseif PBWT.modeMenu then SCENE_MANAGER:Push(PBWT.ModeMenu.SCENE); return
        else mode='solo' end
    end
    if PBWT.Config.AI.DIFFICULTIES[mode] then difficulty=mode; mode='solo' end
    mode=(mode=='local' or mode=='online' or mode=='tutorial') and mode or 'solo'
    if PBWT.match and PBWT.match:Busy() then mode='online'; difficulty=nil end
    difficulty=PBWT.AI.Difficulty(difficulty or (PBWT.ui and PBWT.ui.difficulty))
    if mode=='online' and (not PBWT.match or PBWT.match.phase=='idle') then report(PBWT.L("main_no_duel")); return end
    if PBWT.ui and PBWT.ui.transition.phase then
        report(PBWT.L("main_after_fade")); return
    end
    if not PBWT.ui then PBWT.ui=PBWT.UI.New(mode,difficulty,variant) else PBWT.ui:SetMode(mode,difficulty,variant) end
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
    if not transport or not transport.protocol then report(transport and transport.error or PBWT.L("main_no_transport")); return end
    if not transport.protocol:IsEnabled() then report(PBWT.L("main_protocol_off")); return end
    local ok,why=transport:Check(peer,true); if not ok then report(why); return end
    -- Distinct per invite, including after /reloadui; not a security token.
    PBWT.nonce=((PBWT.nonce or GetTimeStamp())+1)%4294967295
    local session=(GetTimeStamp()*1000+GetFrameTimeMilliseconds()+PBWT.nonce)%4294967295+1
    ok,why=PBWT.match:Challenge(peer,session,PBWT.ui and PBWT.ui.variant or 'light')
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
    PBWT.Records.Initialize(); PBWT.Locale.Use(PBWT.Records.Data().language)
    PBWT.Assets.Initialize(); PBWT.InitializeNetwork()
    if not PBWT.modeMenu and PBsWarTableModeMenu then PBWT.modeMenu=PBWT.ModeMenu:New(PBsWarTableModeMenu) end
    PBWT.HookMenu()
    EVENT_MANAGER:RegisterForEvent('PBsWarTableMenu',EVENT_PLAYER_ACTIVATED,function() PBWT.HookMenu() end)
    SLASH_COMMANDS['/pbwt']=function(argument)
        argument=argument and argument:match('^%s*(.-)%s*$') or ''
        if argument=='music' then
            local data=PBWT.Records.Data(); data.music=data.music==false
            if not data.music then PBWT.Audio.ReleaseMusic() elseif PBWT.ui and PBWT.ui.visible then PBWT.Audio.Music(true) end
            report(PBWT.L("main_music_label")..(data.music and PBWT.L("main_music_on") or PBWT.L("main_off")))
        elseif argument:match('^lang') then
            -- The language is remembered account-wide; 'auto' returns to the client language.
            local choice=argument:match('^lang%s+(%a+)$')
            local data=PBWT.Records.Data()
            if choice=='auto' then data.language=nil
            elseif choice and PBWT.Locale.strings[choice] then data.language=choice end
            PBWT.Locale.Use(data.language)
            local name=data.language or PBWT.L("main_language_auto",PBWT.Locale.Language())
            report(PBWT.L("main_language",name))
            if PBWT.ui then PBWT.ui:Refresh() end
        elseif argument=='sync' then PBWT.match:StartSync()
        elseif argument=='debug' then report(PBWT.transport.error or ('ID508 / '..PBWT.match.phase..PBWT.L("main_actions")..PBWT.match.seq))
        else PBWT.Open(argument) end
    end
end
EVENT_MANAGER:RegisterForEvent('PBsWarTable',EVENT_ADD_ON_LOADED,OnLoaded)
