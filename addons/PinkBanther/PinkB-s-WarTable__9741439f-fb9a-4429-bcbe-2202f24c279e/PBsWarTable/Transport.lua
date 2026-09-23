local N=PBWT.Config.NETWORK
local T={}; T.__index=T; PBWT.Transport=T
function T.Identity(name)
    local hash=PBWT.SHA256(name)
    return tonumber(hash:sub(1,8),16),tonumber(hash:sub(9,16),16)
end
function T:Check(peer,outgoing)
    if not peer or peer=='' or peer==GetDisplayName() then return false,PBWT.L("tr_pick_peer") end
    local tag
    for i=1,GetGroupSize() do
        local unit=GetGroupUnitTagByIndex(i)
        if GetUnitDisplayName(unit)==peer then tag=unit; break end
    end
    if not tag or not IsUnitOnline(tag) then return false,PBWT.L("tr_not_grouped") end
    if IsIgnored(peer) then return false,PBWT.L("tr_ignored") end
    if IsUnitInCombat('player') or IsUnitInCombat(tag) then return false,PBWT.L("tr_in_combat") end
    if outgoing and not CanCommunicateWith(GetUnitName(tag)) then return false,PBWT.L("tr_no_comms") end
    return true
end
function T.New(receive,refused)
    local self=setmetatable({},T)
    if not LibGroupBroadcast then self.error=PBWT.L("tr_needs_lib"); return self end
    local ok,err=pcall(function()
        local handler=assert(LibGroupBroadcast:RegisterHandler('PBsWarTable'))
        handler:SetDisplayName("PB's WarTable"); handler:SetDescription(PBWT.Config.Title())
        local p=handler:DeclareProtocol(N.DEVELOPMENT_ID,'PBsWarTableV1Dev'); self.protocol=p
        p:SetDisplayName(PBWT.Config.Title())
        p:AddField(LibGroupBroadcast.CreateNumericField('version',{numBits=2}))
        p:AddField(LibGroupBroadcast.CreateNumericField('kind',{numBits=4}))
        for _,key in ipairs({'build','target1','target2','session','seq','cmd','hash'}) do
            p:AddField(LibGroupBroadcast.CreateNumericField(key,{numBits=32}))
        end
        p:OnData(function(tag,data)
            local peer=GetUnitDisplayName(tag)
            local name=GetDisplayName()
            if not name or name=='' or not peer or peer==name then return end
            if self.ownName~=name then self.ownName=name; self.own1,self.own2=T.Identity(name) end
            if data.target1~=self.own1 or data.target2~=self.own2 then return end
            if not self:Check(peer,false) then return end
            if data.version~=N.VERSION or data.build~=N.BUILD then
                if refused then refused(PBWT.L("tr_version")) end; return
            end
            receive(peer,data)
        end)
        assert(p:Finalize({isRelevantInCombat=false,replaceQueuedMessages=false}))
    end)
    if not ok then self.protocol=nil; self.error=PBWT.L("tr_init_failed")..N.DEVELOPMENT_ID..'）：'..tostring(err) end
    return self
end
function T:Send(peer,packet)
    if not self.protocol then return false,self.error end
    if not self.protocol:IsEnabled() then return false,PBWT.L("tr_protocol_off") end
    local ok,why=self:Check(peer,true); if not ok then return false,why end
    if self.targetName~=peer then self.targetName=peer; self.target1,self.target2=T.Identity(peer) end
    local data={version=N.VERSION,build=N.BUILD,target1=self.target1,target2=self.target2,
        kind=packet.kind,session=packet.session,seq=packet.seq or 0,cmd=packet.cmd or 0,hash=packet.hash or 0}
    if self.protocol:Send(data,{replaceQueuedMessages=false})~=true then return false,PBWT.L("tr_queue_full") end
    return true
end
