local N=PBWT.Config.NETWORK
local T={}; T.__index=T; PBWT.Transport=T
function T.Identity(name)
    local hash=PBWT.SHA256(name)
    return tonumber(hash:sub(1,8),16),tonumber(hash:sub(9,16),16)
end
function T:Check(peer,outgoing)
    if not peer or peer=='' or peer==GetDisplayName() then return false,'対戦相手を選んでください' end
    local tag
    for i=1,GetGroupSize() do
        local unit=GetGroupUnitTagByIndex(i)
        if GetUnitDisplayName(unit)==peer then tag=unit; break end
    end
    if not tag or not IsUnitOnline(tag) then return false,'相手がグループ外またはオフラインです' end
    if IsIgnored(peer) then return false,'無視リストの相手です' end
    if IsUnitInCombat('player') or IsUnitInCombat(tag) then return false,'戦闘中は対局通信を停止します' end
    if outgoing and not CanCommunicateWith(GetUnitName(tag)) then return false,'相手との通信が許可されていません' end
    return true
end
function T.New(receive,refused)
    local self=setmetatable({},T)
    if not LibGroupBroadcast then self.error='対人戦にはLibGroupBroadcastが必要です'; return self end
    local ok,err=pcall(function()
        local handler=assert(LibGroupBroadcast:RegisterHandler('PBsWarTable'))
        handler:SetDisplayName("PinkB's War Table"); handler:SetDescription(PBWT.Config.TITLE)
        local p=handler:DeclareProtocol(N.DEVELOPMENT_ID,'PBsWarTableV1Dev'); self.protocol=p
        p:SetDisplayName(PBWT.Config.TITLE)
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
                if refused then refused('対戦相手とアドオンのバージョンが異なります') end; return
            end
            receive(peer,data)
        end)
        assert(p:Finalize({isRelevantInCombat=false,replaceQueuedMessages=false}))
    end)
    if not ok then self.protocol=nil; self.error='通信初期化に失敗（ID '..N.DEVELOPMENT_ID..'）：'..tostring(err) end
    return self
end
function T:Send(peer,packet)
    if not self.protocol then return false,self.error end
    if not self.protocol:IsEnabled() then return false,'LibGroupBroadcastで本作の通信が無効です' end
    local ok,why=self:Check(peer,true); if not ok then return false,why end
    if self.targetName~=peer then self.targetName=peer; self.target1,self.target2=T.Identity(peer) end
    local data={version=N.VERSION,build=N.BUILD,target1=self.target1,target2=self.target2,
        kind=packet.kind,session=packet.session,seq=packet.seq or 0,cmd=packet.cmd or 0,hash=packet.hash or 0}
    if self.protocol:Send(data,{replaceQueuedMessages=false})~=true then return false,'通信キューが送信を受け付けませんでした' end
    return true
end
