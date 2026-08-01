-- This file is part of AutoInvite
--
-- (C) 2016 Scott Yeskie (Sasky)
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

AutoInvite = AutoInvite or {}
local function b(v) if v then return "T" else return "F" end end
local function nn(val) if val == nil then return "NIL" else return val end end
local function dbg(msg) if AutoInvite.debug then d("|c999999" .. msg) end end
local function echo(msg) CHAT_SYSTEM.primaryContainer.currentBuffer:AddMessage("|CFFFF00" .. msg) end

AutoInvite.kickTable = {}
function AutoInvite.checkOffline()
    local now = GetTimeStamp()
    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        if not IsUnitOnline(tag) then
            AutoInvite.kickTable[GetUnitName(tag)] = now
        end
    end
end

--Since KickByName doesn't seem to be working
function AutoInvite.kickByName(name)
    AutoInvite.kickTable[name] = nil
    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        if GetUnitName(tag) == name then
            GroupKick(tag)
            return
        end
    end
    echo(zo_strformat(GetString(SI_AUTO_INVITE_ERROR_KICK), name))
end

function AutoInvite.kickCheck()
    if not AutoInvite.cfg.autoKick then return end
    local now = GetTimeStamp()
    --d("Check kick")
    for p, t in pairs(AutoInvite.kickTable) do
        local offTime = GetDiffBetweenTimeStamps(now, t)
        if offTime > AutoInvite.cfg.kickDelay then
            echo(zo_strformat(GetString(SI_AUTO_INVITE_KICK), p, offTime))
            AutoInvite.kickByName(p)
        else
            dbg(p .. " offline for " .. offTime .. " / " .. AutoInvite.cfg.kickDelay)
        end
    end
end
