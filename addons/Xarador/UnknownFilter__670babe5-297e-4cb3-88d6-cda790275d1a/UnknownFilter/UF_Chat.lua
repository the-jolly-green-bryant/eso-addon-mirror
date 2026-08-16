-- UF_Chat.lua
local UF = UnknownFilter

function UF:EchoOnce()
    self._echoOnce = true
end

function UF:Say(message)
    if not self._echoOnce and not (self.saved and self.saved.echo) then
        return
    end

    self._echoOnce = false
    local text = "[UF] " .. tostring(message)
    if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
        CHAT_ROUTER:AddSystemMessage(text)
    elseif d then
        d(text)
    end
end

function UF:Dbg(...)
    if not (self.saved and self.saved.debug) then
        return
    end

    local parts = {}
    for index = 1, select("#", ...) do
        table.insert(parts, tostring(select(index, ...)))
    end
    self:EchoOnce()
    self:Say(table.concat(parts, " "))
end

function UF:ActionDebug(message)
    if self.saved and self.saved.debug then
        self:Dbg(message)
    end
end

function UF:ModeLabel(mode)
    if mode == self.MODE_GEAR then
        return self:T("modeGearLong")
    elseif mode == self.MODE_LEARN then
        return self:T("modeLearnLong")
    elseif mode == self.MODE_MOTIF then
        return self:T("modeMotifLong")
    elseif mode == self.MODE_COLLECT then
        return self:T("modeCollectLong")
    end
    return self:T("modeOffLong")
end

function UF:ModeShort(mode)
    if mode == self.MODE_GEAR then
        return self:T("modeGear")
    elseif mode == self.MODE_LEARN then
        return self:T("modeLearn")
    elseif mode == self.MODE_MOTIF then
        return self:T("modeMotif")
    elseif mode == self.MODE_COLLECT then
        return self:T("modeCollect")
    end
    return self:T("modeOff")
end

function UF:SceneName()
    local scene = SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene()
    return scene and scene.GetName and scene:GetName() or "<none>"
end

function UF:ToggleMode(suppressActionDebug)
    if not (self._armed and self.saved) then
        return
    end

    local mode = self.saved.mode or self.MODE_OFF
    if mode == self.MODE_OFF then
        mode = self.MODE_GEAR
    elseif mode == self.MODE_GEAR then
        mode = self.MODE_LEARN
    elseif mode == self.MODE_LEARN then
        mode = self.MODE_MOTIF
    elseif mode == self.MODE_MOTIF then
        mode = self.MODE_COLLECT
    else
        mode = self.MODE_OFF
    end

    self.saved.mode = mode
    self:CancelAutoAdvance(true)
    if self.RefreshAddonKeybinds then
        self:RefreshAddonKeybinds()
    end
    if not suppressActionDebug then
        self:ActionDebug(self:T("filter") .. ": " .. self:ModeShort(mode))
    end
    self:RefreshFilteredResults()
    return mode
end

function UF:Slash_mode()
    if self._armed then
        local mode = self:ToggleMode(true)
        self:EchoOnce()
        self:Say(self:T("filter") .. ": " .. self:ModeShort(mode))
    else
        self:EchoOnce()
        self:Say(self:T("notInitialized"))
    end
end

function UF:Slash_debug(argument)
    self:EchoOnce()
    if not self.saved then
        self:Say(self:T("notInitialized"))
        return
    end

    argument = tostring(argument or ""):lower()
    if argument == "on" or argument == "1" or argument == "true" then
        self.saved.debug = true
    elseif argument == "off" or argument == "0" or argument == "false" then
        self.saved.debug = false
    else
        self.saved.debug = not self.saved.debug
    end
    self:Say("Debug: " .. (self.saved.debug and "On" or "Off"))
end

function UF:Slash_scan(argument)
    self:EchoOnce()
    if not self.saved then
        self:Say(self:T("notInitialized"))
        return
    end

    argument = tostring(argument or ""):lower()
    if argument == "on" or argument == "1" or argument == "true" then
        self.saved.debugScan = true
    elseif argument == "off" or argument == "0" or argument == "false" then
        self.saved.debugScan = false
    else
        self.saved.debugScan = not self.saved.debugScan
    end
    self:Say("DebugScan: " .. (self.saved.debugScan and "On" or "Off"))
end

function UF:Slash_dump()
    self:EchoOnce()
    if not self._armed then
        self:Say(self:T("notInitialized"))
        return
    end

    self:BuildPassMaps()
    self:Say(string.format("Results=%d, filter-evaluated=%d", self._serverItemCount or 0, self._passTotal or 0))
end

function UF:Slash_probe()
    self:EchoOnce()
    if not self._armed then
        self:Say(self:T("notInitialized"))
        return
    end

    local page = TRADING_HOUSE_SEARCH and TRADING_HOUSE_SEARCH.GetPage
        and TRADING_HOUSE_SEARCH:GetPage() or 0
    local previous = TRADING_HOUSE_SEARCH and TRADING_HOUSE_SEARCH.HasPreviousPage
        and TRADING_HOUSE_SEARCH:HasPreviousPage() or false
    local nextPage = TRADING_HOUSE_SEARCH and TRADING_HOUSE_SEARCH.HasNextPage
        and TRADING_HOUSE_SEARCH:HasNextPage() or false

    self:Say(string.format(
        "v%s page=%d server=%d visible=%d prev=%s next=%s mode=%s auto=%s",
        self.version,
        page,
        self._serverItemCount or 0,
        self._visibleItemCount or 0,
        tostring(previous),
        tostring(nextPage),
        self:ModeShort((self.saved and self.saved.mode) or self.MODE_OFF),
        tostring(self.saved and self.saved.autoPage == true)
    ))
end

function UF:Slash_force()
    self:EchoOnce()
    if not self._armed then
        self:Say(self:T("notInitialized"))
        return
    end

    self:RefreshFilteredResults()
    self:Say(self:T("currentPageRebuilt"))
end

function UF:Slash_auto(argument)
    self:EchoOnce()
    if not self.saved then
        self:Say(self:T("notInitialized"))
        return
    end

    argument = tostring(argument or ""):lower()
    local enabled
    if argument == "on" or argument == "1" or argument == "true" then
        enabled = true
    elseif argument == "off" or argument == "0" or argument == "false" then
        enabled = false
    else
        enabled = self.saved.autoPage ~= true
    end

    self:SetAutoPage(enabled, true)
    self:Say(self:T("autoPaging") .. ": " .. self:StateLabel(self.saved.autoPage))
end

function UF:SetAutoPage(enabled, suppressActionDebug)
    if not (self._armed and self.saved) then
        return
    end

    self.saved.autoPage = enabled == true
    self:CancelAutoAdvance(true)

    if self.saved.autoPage then
        self:QueueAutoAdvanceForCurrentPage()
    elseif not self._autoRequestPending and self._filteredPageEmpty and self.SetFilteredEmptyMessage then
        self:SetFilteredEmptyMessage("emptyFilteredPage")
    end
    if self.RefreshAddonKeybinds then
        self:RefreshAddonKeybinds()
    end
    if not suppressActionDebug then
        self:ActionDebug(self:T("autoPaging") .. ": " .. self:StateLabel(self.saved.autoPage))
    end
    return self.saved.autoPage
end

function UF:ToggleAutoPage(suppressActionDebug)
    if not (self._armed and self.saved) then
        return
    end
    return self:SetAutoPage(self.saved.autoPage ~= true, suppressActionDebug)
end

function UF:Slash_skip(argument)
    self:EchoOnce()
    if not self.saved then
        self:Say(self:T("notInitialized"))
        return
    end

    argument = tostring(argument or ""):lower()
    if argument == "on" or argument == "1" or argument == "true" then
        self.saved.skipEmptyPages = true
    elseif argument == "off" or argument == "0" or argument == "false" then
        self.saved.skipEmptyPages = false
    else
        self.saved.skipEmptyPages = not self.saved.skipEmptyPages
    end

    self:CancelAutoAdvance(true)
    self:Say("skipEmptyPages=" .. tostring(self.saved.skipEmptyPages))
end

function UF:Slash_page(argument)
    self:EchoOnce()
    if not self._armed then
        self:Say(self:T("notInitialized"))
        return
    end

    argument = tostring(argument or ""):lower()
    if argument == "next" or argument == "+" or argument == "right" then
        self:Say(self:GoToNextPage() and self:T("nextPageRequested") or self:T("noNextPage"))
    elseif argument == "prev" or argument == "previous" or argument == "-" or argument == "left" then
        self:Say(self:GoToPreviousPage() and self:T("previousPageRequested") or self:T("noPreviousPage"))
    else
        self:Say(self:T("usage") .. ": /ufpage next|prev")
    end
end

function UF:Slash_echo(argument)
    self:EchoOnce()
    if not self.saved then
        self:Say(self:T("notInitialized"))
        return
    end

    argument = tostring(argument or ""):lower()
    if argument == "on" or argument == "1" or argument == "true" then
        self.saved.echo = true
    elseif argument == "off" or argument == "0" or argument == "false" then
        self.saved.echo = false
    else
        self.saved.echo = not self.saved.echo
    end
    self:Say("Echo: " .. self:StateLabel(self.saved.echo))
end

function UF:Slash_limit(argument)
    self:EchoOnce()
    if not self.saved then
        self:Say(self:T("notInitialized"))
        return
    end

    local value = tonumber(argument or "")
    if not value then
        self:Say(self:T("usage") .. ": /uflimit <0..300>")
        return
    end

    value = math.max(0, math.min(300, math.floor(value)))
    self.saved.debugCap = value
    self:Say("debugCap=" .. tostring(value))
end
