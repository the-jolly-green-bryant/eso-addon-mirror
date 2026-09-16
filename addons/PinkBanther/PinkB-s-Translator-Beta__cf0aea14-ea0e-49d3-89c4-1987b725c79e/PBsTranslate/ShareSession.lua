-- Bounded dictionary transfer, independent of ESO UI/network APIs.
-- The host supplies a clock, group membership checks, transport and notifications.
PBsTranslateShare = {}
local S = PBsTranslateShare
local T = PBsTranslate
S.MAX_ENTRIES, S.MAX_BYTES, S.CHUNK = 200, 16384, 80
S.TIMEOUT, S.RETRIES = 30, 3
S.MAGIC = 1346523987 -- wire format 1; never execute received text
S.OFFER, S.ACK, S.DATA, S.CANCEL = 1, 2, 3, 4

function S.Hash(text)
    local a, b = 1, 0 -- Adler32; checksum, not encryption or authentication
    for i = 1, #text do a = (a + text:byte(i)) % 65521; b = (b + a) % 65521 end
    return b * 65536 + a
end
local function Name(name) return T.Lower(name or "") end
local function Integer(n, low, high) return type(n) == "number" and n == math.floor(n) and n >= low and n <= high end
local function Clean(s, limit)
    if type(s) ~= "string" or #s == 0 or #s > limit or s:find("[%z\1-\31\127|]") or not T.IsValidUTF8(s) then return false end
    -- Reject overlong encodings, surrogates and out-of-range code points too.
    for i = 1, #s do
        local a, b = s:byte(i, i + 1)
        if (a == 224 and b and b < 160) or (a == 237 and b and b >= 160)
            or (a == 240 and b and b < 144) or (a == 244 and b and b > 143) then return false end
    end
    return true
end
function S.ValidEntry(key, value)
    if not Clean(key, 80) or not Clean(value, 240) or key:find("=", 1, true)
        or key ~= T.Trim(Name(key)):gsub(" +", " ") or value ~= T.Trim(value) then return false end
    local pos, rest = value:match("^([A-Za-z]+):(.+)$")
    if not pos then return not value:match("^[A-Za-z]+:") end
    if not ({n=true,v=true,a=true,adv=true,x=true,pn=true})[pos] then return false end
    if pos == "v" or pos == "a" then
        local ja = rest:match("^([^/]+)")
        local class = rest:match("^[^/]+/([^/]+)") or (pos == "a" and "i" or "5")
        if not ja or not ({["1"]=true,["5"]=true,s=true,k=true,i=true,na=true,rel=true})[class] then return false end
        if pos == "a" and class ~= "i" and class ~= "na" then return false end
    end
    return true
end
function S.Encode(words)
    local keys, out = {}, {}
    for k, v in pairs(words or {}) do
        if not S.ValidEntry(k, v) then return nil, "invalid" end
        keys[#keys+1] = k
        if #keys > S.MAX_ENTRIES then return nil, "limit" end
    end
    table.sort(keys)
    if #keys == 0 then return nil, "empty" end
    for _, k in ipairs(keys) do out[#out+1] = k .. "\t" .. words[k] .. "\n" end
    local data = table.concat(out)
    if #data > S.MAX_BYTES then return nil, "limit" end
    return data, #keys
end
function S.Decode(data, count)
    if type(data) ~= "string" or #data > S.MAX_BYTES or not Integer(count,1,S.MAX_ENTRIES) then return nil end
    local words, n, pos = {}, 0, 1
    while pos <= #data do
        local ending = data:find("\n", pos, true)
        if not ending then return nil end
        local key, value = data:sub(pos, ending-1):match("^([^\t]+)\t([^\t]+)$")
        if not key or words[key] or not S.ValidEntry(key,value) then return nil end
        n = n + 1
        if n > count then return nil end
        words[key] = value
        pos = ending + 1
    end
    return n == count and words or nil
end
function S.Merge(current, received, overwrite)
    local merged, added, replaced, same, skipped = {}, 0, 0, 0, 0
    for k,v in pairs(current) do merged[k]=v end
    for k,v in pairs(received) do
        if current[k] == v then same=same+1
        elseif current[k] == nil then merged[k]=v; added=added+1
        elseif overwrite then merged[k]=v; replaced=replaced+1
        else skipped=skipped+1 end
    end
    return merged, added, replaced, same, skipped
end
function S.New(host)
    return setmetatable({host=host, serial=math.floor(host.now()*1000)%16777215}, {__index=S})
end
function S:Packet(peer, sid, kind, seq, text)
    return {magic=S.MAGIC, target=S.Hash(Name(peer)), sid=sid, kind=kind, seq=seq, text=text or ""}
end
function S:Emit(packet) return self.host.send(packet) == true end
function S:Notify(event, value) self.host.notify(event, value) end
function S:Cancel(reason, remote)
    local state = self.active
    self.active=nil
    if state then
        if not remote then self:Emit(self:Packet(state.peer,state.sid,S.CANCEL,0)) end
        self:Notify(reason or "cancelled",state)
    end
end
function S:Start(peer, words)
    if self.active or self.review then return false,"busy" end
    if not Clean(peer,64) or Name(peer)==Name(self.host.name()) or not self.host.member(peer) then return false,"group" end
    local data,count=S.Encode(words)
    if not data then return false,count end
    self.serial=self.serial%16777215+1
    local state={direction="send", peer=peer, sid=self.serial, data=data, count=count, seq=0, tries=0, started=self.host.now()}
    state.packet=self:Packet(peer,state.sid,S.OFFER,0,peer.."\n"..count.."\n"..#data.."\n"..S.Hash(data))
    self.active=state
    if not self:Emit(state.packet) then self.active=nil;return false,"transport" end
    state.sent=self.host.now()
    self:Notify("sending",state)
    return true
end
function S:Accept()
    local state=self.active
    if not state or state.direction~="receive" or state.accepted then return false end
    if not self.host.member(state.peer) then self:Cancel("group");return false end
    state.accepted=true;state.last=self.host.now()
    self:Emit(self:Packet(state.peer,state.sid,S.ACK,0))
    self:Notify("receiving",state)
    return true
end
function S:Receive(peer, packet)
    if type(packet)~="table" or packet.magic~=S.MAGIC or not self.host.member(peer) or Name(peer)==Name(self.host.name())
        or packet.target~=S.Hash(Name(self.host.name())) or not Integer(packet.sid,1,16777215)
        or not Integer(packet.seq,0,65535) or not Integer(packet.kind,1,4)
        or type(packet.text)~="string" or #packet.text>96 then return end
    local state=self.active
    local matches=state and Name(state.peer)==Name(peer) and state.sid==packet.sid
    if packet.kind==S.CANCEL then
        if matches then self:Cancel("cancelled",true) end
        return
    end
    if packet.kind==S.OFFER then
        if packet.seq~=0 then return end
        if matches then
            if state.direction=="receive" and state.accepted then self:Emit(self:Packet(peer,state.sid,S.ACK,state.seq)) end
            return
        end
        if state or self.review then self:Emit(self:Packet(peer,packet.sid,S.CANCEL,0));return end
        local target,count,bytes,checksum=packet.text:match("^([^\n]+)\n(%d+)\n(%d+)\n(%d+)$")
        count,bytes,checksum=tonumber(count),tonumber(bytes),tonumber(checksum)
        if Name(target)~=Name(self.host.name()) or not Integer(count,1,S.MAX_ENTRIES)
            or not Integer(bytes,1,S.MAX_BYTES) or not Integer(checksum,0,4294967295) then return end
        local now=self.host.now()
        if self.lastOffer and now-self.lastOffer<15 then return end
        self.lastOffer=now
        self.active={direction="receive",peer=peer,sid=packet.sid,count=count,bytes=bytes,checksum=checksum,
            seq=0,parts={},size=0,last=now,started=now}
        self:Notify("offer",self.active)
        return
    end
    -- ACK a repeated last fragment after receipt, without reopening or importing twice.
    local done=self.completed
    if not matches and done and Name(done.peer)==Name(peer) and done.sid==packet.sid
        and packet.kind==S.DATA and packet.seq==done.seq and self.host.now()<done.untilTime then
        self:Emit(self:Packet(peer,packet.sid,S.ACK,packet.seq));return
    end
    if not matches then return end
    if state.direction=="send" and packet.kind==S.ACK and packet.seq==state.seq then
        if state.seq>0 and state.seq*S.CHUNK>=#state.data then
            self.active=nil;self:Notify("delivered",state);return
        end
        state.seq=state.seq+1
        state.packet=self:Packet(peer,state.sid,S.DATA,state.seq,state.data:sub((state.seq-1)*S.CHUNK+1,state.seq*S.CHUNK))
        state.tries=0;state.sent=self.host.now()
        if not self:Emit(state.packet) then self:Cancel("transport");return end
        self:Notify("progress",state)
    elseif state.direction=="receive" and state.accepted and packet.kind==S.DATA then
        if packet.seq<=state.seq then
            if packet.seq==state.seq then self:Emit(self:Packet(peer,state.sid,S.ACK,state.seq)) end
            return
        end
        if packet.seq~=state.seq+1 or #packet.text==0 or #packet.text>S.CHUNK
            or state.size+#packet.text>state.bytes then self:Cancel("invalid");return end
        local final=state.size+#packet.text==state.bytes
        if not final and #packet.text~=S.CHUNK then self:Cancel("invalid");return end
        state.parts[#state.parts+1]=packet.text
        state.size=state.size+#packet.text;state.seq=packet.seq;state.last=self.host.now()
        if final then
            local data=table.concat(state.parts)
            local words=S.Hash(data)==state.checksum and S.Decode(data,state.count)
            if not words then self:Cancel("invalid");return end
            self.review={peer=peer,words=words,sid=state.sid}
            self.completed={peer=peer,sid=state.sid,seq=state.seq,untilTime=self.host.now()+150}
            self.active=nil
            self:Emit(self:Packet(peer,state.sid,S.ACK,state.seq))
            self:Notify("review",self.review)
        else
            self:Emit(self:Packet(peer,state.sid,S.ACK,state.seq));self:Notify("progress",state)
        end
    end
end
function S:Tick()
    local state=self.active
    if not state then return end
    local now=self.host.now()
    if not self.host.member(state.peer) then self:Cancel("group");return end
    if now-state.started>3600 then self:Cancel("timeout");return end
    if state.direction=="send" and now-state.sent>=S.TIMEOUT then
        if state.tries>=S.RETRIES then self:Cancel("timeout");return end
        state.tries=state.tries+1;state.sent=now
        if not self:Emit(state.packet) then self:Cancel("transport") end
    elseif state.direction=="receive" and now-state.last>150 then self:Cancel("timeout") end
end
