PBJ = PBJ or {}
local Transport = {}
Transport.__index = Transport
PBJ.Transport = Transport
-- DEVELOPMENT ONLY: reserve a permanent ID with the LGB author before release.
Transport.PROTOCOL_ID = 511
function Transport.Identity(name)
    local h=PBJ.SHA256(name)
    return tonumber(h:sub(1,8),16),tonumber(h:sub(9,16),16)
end
function Transport:FindPeer(name)
    for i=1,GetGroupSize() do
        local tag=GetGroupUnitTagByIndex(i)
        if GetUnitDisplayName(tag)==name then return tag end
    end
end
function Transport:Allowed(name)
    local tag=self:FindPeer(name)
    return tag~=nil and name~=GetDisplayName() and IsUnitOnline(tag)
        and not IsIgnored(name) and CanCommunicateWith(GetUnitName(tag))
        and not IsUnitInCombat("player") and not IsUnitInCombat(tag)
end
function Transport.New(receive)
    local self=setmetatable({},Transport)
    if not LibGroupBroadcast then self.error="missingLibrary"; return self end
    local stage="registerHandler"
    local ok,err=pcall(function()
        -- The optional alias must differ from addonName. No alias is needed here.
        local handler=assert(LibGroupBroadcast:RegisterHandler("PBsJanken"),"Handler registration returned nil")
        handler:SetDisplayName("PB's Tamriel de Janken")
        handler:SetDescription("Rock-paper-scissors with a group member. Development protocol.")
        stage="declareProtocol"
        local protocol=handler:DeclareProtocol(Transport.PROTOCOL_ID,"PBsJyankenV2Dev")
        self.protocol=protocol
        protocol:SetDisplayName("PB's Tamriel de Janken")
        stage="createFields"
        protocol:AddField(LibGroupBroadcast.CreateNumericField("version",{numBits=2}))
        protocol:AddField(LibGroupBroadcast.CreateNumericField("kind",{numBits=3}))
        for _,key in ipairs({"target1","target2","session","a","b","c","d"}) do
            protocol:AddField(LibGroupBroadcast.CreateNumericField(key,{numBits=32}))
        end
        stage="registerReceiver"
        local own1,own2=Transport.Identity(GetDisplayName())
        protocol:OnData(function(unitTag,data)
            if data.version~=2 or data.target1~=own1 or data.target2~=own2 then return end
            local sender=GetUnitDisplayName(unitTag)
            if sender and self:Allowed(sender) then receive(sender,data) end
        end)
        stage="finalizeProtocol"
        assert(protocol:Finalize({isRelevantInCombat=false,replaceQueuedMessages=false}),"Protocol validation failed")
    end)
    if not ok then
        self.protocol=nil
        self.error="protocolFailed"
        self.errorStage,self.errorDetail=stage,tostring(err)
    end
    return self
end
function Transport:ErrorText()
    local text=PBJ.Text(self.error or "protocolFailed")
    if self.errorDetail then
        -- Keep the original failure available instead of guessing ID conflicts.
        text=text.."\n["..self.errorStage.."] "..self.errorDetail:gsub("|","/")
    end
    return text
end
function Transport:Send(peer,packet)
    if not self.protocol or not self.protocol:IsEnabled() or not self:Allowed(peer) then return false end
    local wire={}
    for k,v in pairs(packet) do wire[k]=v end
    wire.version=2
    wire.target1,wire.target2=Transport.Identity(peer)
    return self.protocol:Send(wire,{replaceQueuedMessages=false})==true
end
