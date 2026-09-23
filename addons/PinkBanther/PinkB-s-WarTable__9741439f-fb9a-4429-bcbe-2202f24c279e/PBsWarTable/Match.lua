-- Pure two-peer state machine. Host validates all actions; both replay the same log.
local E,W,N=PBWT.Engine,PBWT.Wire,PBWT.Config.NETWORK
local K=W.K
local M={}; M.__index=M; PBWT.Match=M
function M.New(options)
    return setmetatable({o=options,variant=options.variant or 'light',
        phase='idle',state=E.New(options.requireFactions,options.variant),seq=0,log={}},M)
end
function M:InitialState() return E.New(self.o.requireFactions,self.variant) end
function M:Notify(message)
    if message then self.message=message end
    if self.o.changed then self.o.changed(self) end
end
function M:Busy() return self.phase~='idle' and self.phase~='closed' and (self.phase~='finished' or self.pending~=nil) end
function M:Send(kind,seq,cmd,hash)
    return self.o.send(self.peer,{kind=kind,session=self.session,seq=seq or 0,cmd=cmd or 0,hash=hash or 0})
end
function M:Reliable(kind,seq,cmd,hash)
    self.pending={kind=kind,seq=seq or 0,cmd=cmd or 0,hash=hash or 0,sent=self.o.now(),deadline=self.o.now()+N.TIMEOUT}
    self:Send(kind,seq,cmd,hash)
end
function M:Reset(peer,session,seat,phase)
    self.peer,self.session,self.seat,self.phase=peer,session,seat,phase
    self.state,self.seq,self.log,self.pending=self:InitialState(),0,{},nil
    self.stage,self.syncCount,self.syncIndex,self.replaying=nil,nil,nil,nil
    self.lastHeard,self.lastPing,self.started=self.o.now(),self.o.now(),self.o.now()
    self.terminalAt=nil; self.syncEpoch=0; self.completedSyncEpoch=0
end
function M:Challenge(peer,session,variant)
    if self:Busy() then return false,PBWT.L("net_busy") end
    if not W.Integer(session,4294967295) or session==0 then return false,PBWT.L("net_bad_session") end
    self.variant=PBWT.Config.VARIANTS[variant] and variant or 'light'
    self:Reset(peer,session,1,'inviting')
    -- The challenger's board travels with the invite so both sides start the same game.
    self:Reliable(K.INVITE,0,PBWT.Config.VARIANTS[self.variant].id)
    self:Notify(PBWT.L("net_inviting")..peer); return true
end
function M:Accept()
    if self.phase~='invited' then return false end
    self.phase='accepting'; self:Reliable(K.ACCEPT); self:Notify(PBWT.L("net_waiting_start")); return true
end
function M:Close(reason,notifyPeer)
    if notifyPeer then self:Send(K.CLOSE) end
    self.phase,self.pending,self.stage='closed',nil,nil
    self:Notify(reason or PBWT.L("net_closed"))
end
function M:Decline()
    self:Send(K.DECLINE); self:Close(PBWT.L("net_invite_cancelled"))
end
function M:Playable()
    return self.phase=='active' and not self.pending and self.state.player==self.seat
end
function M:CommittedPhase()
    self.phase=self.state.status=='finished' and 'finished' or 'active'
    if self.phase=='finished' and not self.terminalAt then self.terminalAt=self.o.now() end
end
function M:Commit(packed)
    if self.seq>=N.MAX_LOG then self:Close(PBWT.L("net_log_full"),true); return false end
    local command,actor=W.Unpack(packed)
    if not command then return false,PBWT.L("net_bad_command") end
    if command.type=='roll_dice' then
        if command.roll or not PBWT.Opening.CanRoll(self.state,actor) then return false,'invalid_roll' end
        command.roll=PBWT.Opening.Draw(self.o.random)
        packed=W.Pack(command,actor)
    end
    local copy=E.Clone(self.state)
    local ok,reason=W.Apply(copy,actor,command)
    if not ok then return false,reason end
    self.state,self.seq=copy,self.seq+1
    local hash=E.Checksum(copy)
    self.log[self.seq]={cmd=packed,hash=hash}
    self:CommittedPhase(); self:Reliable(K.COMMIT,self.seq,packed,hash)
    self:Notify(PBWT.L("net_waiting_ack")); return true,reason
end
function M:Submit(command)
    local surrender=command.type=='resign'
    if self.phase~='active' or self.pending or (not surrender and self.state.player~=self.seat) then return false,PBWT.L("net_not_your_turn") end
    local packed=W.Pack(command,self.seat)
    if not packed then return false,PBWT.L("net_bad_command") end
    local valid=W.Unpack(packed); if not valid then return false,PBWT.L("net_bad_command") end
    local ok,reason
    if valid.type=='roll_dice' then ok=not valid.roll and PBWT.Opening.CanRoll(self.state,self.seat);reason='invalid_roll'
    else ok,reason=W.Apply(E.Clone(self.state),self.seat,valid) end
    if not ok then return false,reason end
    if self.seat==1 then return self:Commit(packed) end
    self:Reliable(K.REQUEST,self.seq+1,packed,E.Checksum(self.state))
    self:Notify(PBWT.L("net_waiting_ack")); return true,reason
end
function M:ReplayPacket(index)
    local sequence=self.syncEpoch*512+index
    if index==0 then self:Reliable(K.REPLAY,sequence,#self.log,E.Checksum(self:InitialState()))
    elseif index<=#self.log then local item=self.log[index]; self:Reliable(K.REPLAY,sequence,item.cmd,item.hash)
    else self:Reliable(K.REPLAY,sequence,0,E.Checksum(self.state)) end
end
function M:StartSync()
    if self.phase~='active' and self.phase~='finished' and self.phase~='syncing' then return end
    if self.phase=='syncing' then return end
    self.phase='syncing'; self.pending=nil; self.syncAt=self.o.now()
    if self.seat==2 then
        self:Reliable(K.SYNC,self.seq); self:Notify(PBWT.L("net_resyncing")); return
    end
    -- Rebuild the host too: never use a potentially corrupted live state as authority.
    local rebuilt=self:InitialState()
    for _,entry in ipairs(self.log) do
        local command,actor=W.Unpack(entry.cmd)
        if not command or not W.Apply(rebuilt,actor,command) or E.Checksum(rebuilt)~=entry.hash then
            self:Close(PBWT.L("net_replay_failed"),true); return
        end
    end
    self.state,self.seq=rebuilt,#self.log; self.replaying=0; self.syncEpoch=self.syncEpoch+1
    self:ReplayPacket(0); self:Notify(PBWT.L("net_replaying"))
end
function M:Receive(peer,p)
    if type(p)~='table' or not W.Integer(p.kind,15) or p.kind==0 or not W.Integer(p.session,4294967295) or p.session==0 then return end
    for _,key in ipairs({'seq','cmd','hash'}) do if not W.Integer(p[key],4294967295) then return end end
    if p.kind==K.INVITE then
        if self.peer==peer and self.session==p.session and self.phase~='idle' then
            if self.phase=='accepting' then self:Send(K.ACCEPT) end
            return
        end
        if self:Busy() then
            -- Refuse without replacing the current peer/session, including crossed invites.
            self.o.send(peer,{kind=K.DECLINE,session=p.session,seq=0,cmd=0,hash=0}); return
        end
        self.variant=PBWT.Config.VariantKey(p.cmd)
        self:Reset(peer,p.session,2,'invited')
        self:Notify(peer..PBWT.L("net_invite_from")..PBWT.Config.VariantName(PBWT.Config.VARIANTS[self.variant])..PBWT.L("net_invite_hint")); return
    end
    if peer~=self.peer or p.session~=self.session or self.phase=='idle' or self.phase=='closed' then return end
    self.lastHeard=self.o.now()
    local kind=p.kind
    if kind==K.DECLINE and (self.phase=='inviting' or self.phase=='accepting' or self.phase=='starting') then self:Close(PBWT.L("net_invite_refused")); return end
    if kind==K.CLOSE then self:Close(PBWT.L("net_peer_closed")); return end
    if self.seat==1 and kind==K.ACCEPT then
        if self.phase=='inviting' then self.phase='starting'; self:Reliable(K.START,0,0,E.Checksum(self.state)); self:Notify(PBWT.L("net_start_confirm"))
        elseif self.phase=='starting' then self:Send(K.START,0,0,E.Checksum(self.state)) end
        return
    end
    if self.seat==2 and kind==K.START then
        if self.phase=='accepting' then
            if p.hash~=E.Checksum(self.state) then self:Close(PBWT.L("net_board_mismatch"),true); return end
            self.phase,self.pending='active',nil; self:Notify(PBWT.L("net_start_p2"))
        end
        if self.seq==0 and self.phase=='active' then self:Send(K.READY,0,0,E.Checksum(self.state)) end
        return
    end
    if self.seat==1 and kind==K.READY and self.phase=='starting' then
        if p.hash~=E.Checksum(self.state) then self:Close(PBWT.L("net_board_mismatch"),true); return end
        self.phase,self.pending='active',nil; self:Notify(PBWT.L("net_start_p1")); return
    end
    if self.phase~='active' and self.phase~='syncing' and self.phase~='finished' then return end
    if kind==K.PING then
        self:Send(K.PONG,self.seq,0,E.Checksum(self.state))
        if self.phase~='syncing' and not self.pending and p.seq==self.seq and p.hash~=E.Checksum(self.state) then self:StartSync() end
        return
    elseif kind==K.PONG then
        if self.phase~='syncing' and not self.pending and p.seq==self.seq and p.hash~=E.Checksum(self.state) then self:StartSync() end
        return
    end
    if self.seat==1 and kind==K.SYNC then self:StartSync(); return end
    if self.seat==1 and kind==K.REPLAY_ACK and self.phase=='syncing' then
        local epoch,index=math.floor(p.seq/512),p.seq%512
        if epoch~=self.syncEpoch or index~=self.replaying or not self.pending or p.hash~=self.pending.hash then return end
        if index==#self.log+1 then
            self.pending,self.replaying=nil,nil; self:CommittedPhase(); self:Notify(PBWT.L("net_resync_done"))
        else self.replaying=self.replaying+1; self:ReplayPacket(self.replaying) end
        return
    end
    if self.seat==2 and kind==K.REPLAY then
        local epoch,index=math.floor(p.seq/512),p.seq%512
        if epoch==0 or epoch<self.syncEpoch then return end
        if epoch<=self.completedSyncEpoch then
            if p.hash==E.Checksum(self.state) and index==self.seq+1 then self:Send(K.REPLAY_ACK,p.seq,0,p.hash) end
            return
        end
        if index==0 then
            if p.cmd>N.MAX_LOG or p.hash~=E.Checksum(self:InitialState()) then self:Close(PBWT.L("net_resync_bad"),true); return end
            if epoch>self.syncEpoch or not self.stage then
                if self.phase~='syncing' then self.syncAt=self.o.now() end
                self.syncEpoch=epoch
                self.phase,self.stage,self.syncCount,self.syncIndex,self.pending='syncing',self:InitialState(),p.cmd,0,nil
            elseif self.syncCount~=p.cmd then return end
            self:Send(K.REPLAY_ACK,p.seq,0,p.hash); self:Notify(PBWT.L("net_resync_replay")); return
        end
        if self.phase~='syncing' or not self.stage or epoch~=self.syncEpoch then return end
        if index<=self.syncIndex then
            if index==self.syncIndex and p.hash==E.Checksum(self.stage) then self:Send(K.REPLAY_ACK,p.seq,0,p.hash) end
            return
        end
        if index~=self.syncIndex+1 then return end
        if index==self.syncCount+1 then
            if p.cmd~=0 or p.hash~=E.Checksum(self.stage) then self:Close(PBWT.L("net_resync_mismatch"),true); return end
            self.state,self.seq,self.stage,self.pending=self.stage,self.syncCount,nil,nil
            self.completedSyncEpoch=epoch
            self:CommittedPhase(); self:Send(K.REPLAY_ACK,p.seq,0,p.hash); self:Notify(PBWT.L("net_resync_done")); return
        end
        local command,actor=W.Unpack(p.cmd)
        if not command or not W.Apply(self.stage,actor,command) or E.Checksum(self.stage)~=p.hash then self:Close(PBWT.L("net_resync_action"),true); return end
        self.syncIndex=index; self:Send(K.REPLAY_ACK,p.seq,0,p.hash); return
    end
    if self.phase=='syncing' then return end
    if self.seat==1 and kind==K.REQUEST then
        if p.seq<self.seq then return end
        if p.seq==self.seq and self.log[self.seq] then
            local old=W.Unpack(self.log[self.seq].cmd);local request,actor=W.Unpack(p.cmd)
            local same=self.log[self.seq].cmd==p.cmd or (actor==2 and request and request.type=='roll_dice' and not request.roll and old.type=='roll_dice' and select(2,W.Unpack(self.log[self.seq].cmd))==2)
            if same then self:Send(K.COMMIT,self.seq,self.log[self.seq].cmd,self.log[self.seq].hash); return end
        end
        if self.pending or self.phase~='active' then return end
        if p.seq~=self.seq+1 or p.hash~=E.Checksum(self.state) then self:StartSync(); return end
        local command,actor=W.Unpack(p.cmd)
        if not command or actor~=2 then self:Close(PBWT.L("net_bad_request"),true); return end
        local ok=self:Commit(p.cmd)
        if not ok then self:Close(PBWT.L("net_apply_failed"),true) end
        return
    end
    if self.seat==2 and kind==K.COMMIT then
        if p.seq<self.seq then return end
        if p.seq==self.seq and p.hash==E.Checksum(self.state) then self:Send(K.ACK,self.seq,0,p.hash); return end
        if p.seq~=self.seq+1 then self:StartSync(); return end
        local command,actor=W.Unpack(p.cmd)
        if not command then self:Close(PBWT.L("net_bad_received"),true); return end
        -- Host cannot invent moves for the guest without its pending request.
        local matching=self.pending and self.pending.kind==K.REQUEST and self.pending.cmd==p.cmd
        if actor==2 and self.pending and self.pending.kind==K.REQUEST and command.type=='roll_dice' then
            local requested,seat=W.Unpack(self.pending.cmd)
            matching=requested and seat==2 and requested.type=='roll_dice' and not requested.roll and command.roll~=nil and self.pending.seq==p.seq
        end
        if actor==2 and not matching then
            self:Close(PBWT.L("net_unrequested"),true); return
        end
        local copy=E.Clone(self.state)
        if not W.Apply(copy,actor,command) or E.Checksum(copy)~=p.hash then self:StartSync(); return end
        self.state,self.seq,self.pending=copy,p.seq,nil
        self:CommittedPhase(); self:Send(K.ACK,self.seq,0,p.hash); self:Notify(PBWT.L("net_synced")); return
    end
    if self.seat==1 and kind==K.ACK and self.pending and self.pending.kind==K.COMMIT and p.seq==self.seq then
        if p.hash~=E.Checksum(self.state) then self:StartSync(); return end
        self.pending=nil; self:Notify(PBWT.L("net_synced"))
    end
end
function M:Tick()
    if self.phase=='idle' or self.phase=='closed' then return end
    local now=self.o.now()
    if self.phase=='finished' and not self.pending and self.terminalAt and now-self.terminalAt>N.TIMEOUT then return end
    if (self.phase=='invited' or self.phase=='inviting') and now-self.started>N.INVITE_TIMEOUT then self:Close(PBWT.L("net_invite_timeout"),true); return end
    if self.phase=='syncing' and self.syncAt and now-self.syncAt>N.SYNC_TIMEOUT then self:Close(PBWT.L("net_resync_timeout"),true); return end
    if self.pending then
        if now>self.pending.deadline then self:Close(PBWT.L("net_ack_timeout"),true); return end
        if now-self.pending.sent>=N.RETRY then
            local p=self.pending; p.sent=now; self:Send(p.kind,p.seq,p.cmd,p.hash)
        end
    end
    if self.phase=='active' or self.phase=='syncing' then
        if now-self.lastHeard>N.TIMEOUT then self:Close(PBWT.L("net_lost_peer"),true); return end
        if not self.pending and now-self.lastPing>=N.HEARTBEAT then
            self.lastPing=now; self:Send(K.PING,self.seq,0,E.Checksum(self.state))
        end
    end
end
