DsRAutoINV = DsRAutoINV or {}
local function b(v) if v then return "T" else return "F" end end
local function nn(val) if val == nil then return "NIL" else return val end end
local function dbg(msg) if DsRAutoINV.debug then d("|c999999" .. msg) end end
local function echo(msg) CHAT_ROUTER:AddSystemMessage("|CFFFF00" .. msg) end

DsRAutoINV.kickTable = {}

function DsRAutoINV.checkOffline()
    local now = GetTimeStamp()
    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        if not IsUnitOnline(tag) then
            DsRAutoINV.kickTable[GetUnitName(tag)] = now
        end
    end
end

--Since KickByName doesn't seem to be working
function DsRAutoINV.kickByName(name)
    DsRAutoINV.kickTable[name] = nil
    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        if GetUnitName(tag) == name then
            GroupKick(tag)
            return
        end
    end
    echo(zo_strformat(GetString(SI_DsRAI_ERROR_KICK), name))
end

function DsRAutoINV.kickCheck()
    if not DsRAutoINV.cfg.autoKick then return end
    local now = GetTimeStamp()
    --d("Check kick")
    for p, t in pairs(DsRAutoINV.kickTable) do
        local offTime = GetDiffBetweenTimeStamps(now, t)
        if offTime > DsRAutoINV.cfg.kickDelay then
            echo(zo_strformat(GetString(SI_DsRAI_KICK), p, offTime))
            DsRAutoINV.kickByName(p)
        else
            dbg(p .. " offline for " .. offTime .. " / " .. DsRAutoINV.cfg.kickDelay)
        end
    end
end
