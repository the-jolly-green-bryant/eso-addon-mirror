-- UF_Chat.lua

local UF = UnknownFilter

-- ── Echo control: by default silent; commands call EchoOnce() so their output appears.
function UF:EchoOnce()
    self._echoOnce = true
end

-- ── Chat helpers
function UF:Say(m)
    -- Only print if a command just requested echo, or persistent echo is enabled.
    if not self._echoOnce and not (self.saved and self.saved.echo) then return end
    self._echoOnce = false
    local t = "[UF] " .. tostring(m)
    if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
        CHAT_ROUTER:AddSystemMessage(t)
    else
        d(t)
    end
end

function UF:Dbg(...)
    if not (self.saved and self.saved.debug) then return end
    local parts = {}
    for i=1,select("#",...) do parts[#parts+1] = tostring(select(i,...)) end
    self:Say(table.concat(parts, " "))
end

-- ── Labels / order
function UF:ModeLabel(mode)
    if mode==self.MODE_OFF     then return "Unknown: Off" end
    if mode==self.MODE_GEAR    then return "Unknown: Gear (Weapons/Armor/Jewelry)" end
    if mode==self.MODE_LEARN   then return "Unknown: Learnables (Blueprint/Design/Diagram/Formula/Pattern/Praxis/Recipe/Sketch)" end
    if mode==self.MODE_MOTIF   then return "Unknown: Motif" end
    if mode==self.MODE_COLLECT then return "Unknown: Collectibles (Runebox/StylePage)" end
    return "Unknown: Off"
end

function UF:ModeShort(mode)
    if     mode==self.MODE_GEAR    then return "Gear"
    elseif mode==self.MODE_LEARN   then return "Learnables"
    elseif mode==self.MODE_MOTIF   then return "Motif"
    elseif mode==self.MODE_COLLECT then return "Collectibles"
    else return "Off" end
end

-- ── Scene helpers
function UF:SceneName()
    local sc = SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene()
    return (sc and sc.GetName and sc:GetName()) or "<none>"
end
function UF:InTradingScene()
    local s = string.lower(self:SceneName())
    return s:find("trading",1,true) and s:find("house",1,true)
end

-- ── Slash commands (they all start with EchoOnce() so they talk even when silent)
function UF:ToggleMode()
    if not self._armed then return end
    self:EchoOnce()
    local m = self.saved.mode or self.MODE_OFF
    if m==self.MODE_OFF then m=self.MODE_GEAR
    elseif m==self.MODE_GEAR then m=self.MODE_LEARN
    elseif m==self.MODE_LEARN then m=self.MODE_MOTIF
    elseif m==self.MODE_MOTIF then m=self.MODE_COLLECT
    else m=self.MODE_OFF end
    self.saved.mode = m
    self:Say("Filter: " .. self:ModeShort(m))
    self:RebuildAndPrune()
end

function UF:Slash_mode()    self:EchoOnce(); if self._armed then self:ToggleMode() else self:Say("Not armed") end end

function UF:Slash_debug(arg)
    self:EchoOnce()
    if not self.saved then self:Say("Not armed"); return end
    arg = tostring(arg or ""):lower()
    if arg=="" then self.saved.debug = not self.saved.debug
    elseif arg=="on" or arg=="1" or arg=="true" then self.saved.debug=true
    elseif arg=="off" or arg=="0" or arg=="false" then self.saved.debug=false end
    self:Say("debug="..tostring(self.saved.debug))
end

function UF:Slash_scan(arg)
    self:EchoOnce()
    if not self.saved then self:Say("Not armed"); return end
    arg = tostring(arg or ""):lower()
    if arg=="" then self.saved.debugScan = not self.saved.debugScan
    elseif arg=="on" or arg=="1" or arg=="true" then self.saved.debugScan=true
    elseif arg=="off" or arg=="0" or arg=="false" then self.saved.debugScan=false end
    self:Say("debugScan="..tostring(self.saved.debugScan))
end

function UF:Slash_dump()
    self:EchoOnce()
    if not self._armed then self:Say("Not armed"); return end
    local count, blanks = 0, 0
    for i=1,600 do
        local l = GetTradingHouseSearchResultItemLink and GetTradingHouseSearchResultItemLink(i)
        if l and l~="" then count=count+1; blanks=0 else blanks=blanks+1; if blanks>=3 then break end end
    end
    self:Say(("Manual dump: detected %d items (best effort)"):format(count))
    self:BuildPassMaps(count)
    self:PruneResultList()
end

function UF:Slash_probe()
    self:EchoOnce()
    local ctrl = GetControl(self.TARGET_LIST_NAME)
    self:Say(("Probe armed=%s scene=%s target=%s last=%d pass=%d mode=%s autoPage=%s")
        :format(tostring(self._armed), self:SceneName(), tostring(ctrl~=nil),
                self._lastCount or 0, self._passTotal or 0,
                self:ModeLabel((self.saved and self.saved.mode) or self.MODE_OFF),
                tostring((self.saved and self.saved.autoPage) or false)))
end

function UF:Slash_force()
    self:EchoOnce()
    if not self._armed then self:Say("Not armed"); return end
    if (self.saved.mode or self.MODE_OFF) == self.MODE_OFF then
        self:Say("Mode OFF: no filtering applied")
        return
    end
    if (self._passTotal or 0)==0 then self:BuildPassMapsBestEffort() end
    self:PruneResultList()
end

function UF:Slash_auto(arg)
    self:EchoOnce()
    if not self.saved then self:Say("Not armed"); return end
    arg = tostring(arg or ""):lower()
    if arg=="on" or arg=="1" or arg=="true" then self.saved.autoPage=true
    elseif arg=="off" or arg=="0" or arg=="false" then self.saved.autoPage=false
    else self.saved.autoPage = not self.saved.autoPage end
    self:Say("AutoPage = "..tostring(self.saved.autoPage))
end

function UF:Slash_page(arg)
    self:EchoOnce()
    if not self._armed then self:Say("Not armed"); return end
    local n = tonumber(arg or "")
    if n then self:RequestPage(n) else self:Say("usage: /ufpage <index>") end
end

-- Persistent echo toggle if du mal dauerhaft Status willst:
SLASH_COMMANDS["/ufecho"] = function(arg)
    UF:EchoOnce()
    if not UF.saved then UF:Say("Not armed"); return end
    arg = tostring(arg or ""):lower()
    if arg=="" then UF.saved.echo = not UF.saved.echo
    elseif arg=="on" or arg=="1" or arg=="true" then UF.saved.echo=true
    elseif arg=="off" or arg=="0" or arg=="false" then UF.saved.echo=false end
    UF:Say("echo="..tostring(UF.saved.echo))
end

-- Debug helpers (lassen d() direkt sprechen; bewusst NICHT über Say)
SLASH_COMMANDS["/ufc1"] = function()
    local l = GetTradingHouseSearchResultItemLink and GetTradingHouseSearchResultItemLink(1)
    if not l or l=="" then d("[UFC1] no link #1") return end
    local cid = GetItemLinkContainerCollectibleId and GetItemLinkContainerCollectibleId(l)
    local known = (cid and cid>0 and IsCollectibleUnlocked and IsCollectibleUnlocked(cid)) or false
    d(string.format("[UFC1] cid=%s known=%s", tostring(cid), tostring(known)))
    if UnknownFilter and UnknownFilter.Passes then
        local keep, how = UnknownFilter:Passes(l, UnknownFilter.MODE_COLLECT)
        d(string.format("[UFC1] Passes(MODE_COLLECT) keep=%s via=%s", tostring(keep), tostring(how)))
    end
end

SLASH_COMMANDS["/ufk1"] = function()
    local l = GetTradingHouseSearchResultItemLink and GetTradingHouseSearchResultItemLink(1)
    local id = l and GetItemLinkItemId and GetItemLinkItemId(l)
    local vIdx = UnknownFilter and UnknownFilter._passByIndex and UnknownFilter._passByIndex[1]
    local vKey = UnknownFilter and UnknownFilter._passByLink and id and UnknownFilter._passByLink[id]
    d(string.format("[UFK1] idxKeep=%s | id=%s keyKeep=%s", tostring(vIdx), tostring(id), tostring(vKey)))
end

SLASH_COMMANDS["/uflimit"] = function(arg)
    UF:EchoOnce()
    if not UF.saved then UF:Say("Not armed"); return end
    local n = tonumber(arg or "")
    if not n then UF:Say("usage: /uflimit <0..300>"); return end
    if n < 0 then n = 0 end
    if n > 300 then n = 300 end
    UF.saved.debugCap = n
    UF:Say("debugCap="..tostring(n))
end

SLASH_COMMANDS["/ufrecheck"] = function()
    if not UnknownFilter or not UnknownFilter._armed then d("[UF] Not armed") return end
    UnknownFilter:PruneResultList()
end

SLASH_COMMANDS["/ufwhere"] = function()
    local c = UnknownFilter and UnknownFilter:GetResultList()
    d("[UF] target="..tostring(c and (c.GetName and c:GetName()) or nil))
end

SLASH_COMMANDS["/ufskip"] = function(arg)
    UF:EchoOnce()
    if not UnknownFilter or not UnknownFilter.saved then d("[UF] Not armed") return end
    arg = tostring(arg or ""):lower()
    if arg=="" then UnknownFilter.saved.skipEmptyPages = not UnknownFilter.saved.skipEmptyPages
    elseif arg=="on" or arg=="1" or arg=="true" then UnknownFilter.saved.skipEmptyPages = true
    elseif arg=="off" or arg=="0" or arg=="false" then UnknownFilter.saved.skipEmptyPages = false end
    UF:Say("skipEmptyPages="..tostring(UnknownFilter.saved.skipEmptyPages))
end
