local A, S = PBS_CLOCK, PBS_CLOCK_STRINGS

function A:Command(input)
    local command, arg = string.lower(input or ""):match("^%s*(%S*)%s*(.-)%s*$")
    local target
    if (command=="real" or command=="game") and arg~="" then
        target=command
        command,arg=arg:match("^(%S+)%s*(.-)%s*$")
    end
    local function layout(key,value)
        for _,kind in ipairs(target and {target} or self:VisibleKinds()) do
            self:SetLayout(self.sv.style,kind,key,value)
        end
    end
    if command == "real" or command == "game" or command == "both" then self:Set("display", command)
    elseif command == "analog" or command == "digital" then self:Set("style", command)
    elseif command == "on" or command == "off" then self:Set("enabled", command == "on")
    elseif command == "reset" then self:Reset()
    elseif command == "source" and (arg == "global" or arg == "zone") then self:Set("source", arg)
    elseif command == "text" and self.sv.style == "analog" and (arg == "on" or arg == "off") then
        layout("showText",arg == "on")
    elseif (command == "seconds" or command == "24h") and (arg == "on" or arg == "off") then
        self:Set(command == "24h" and "hour24" or "seconds", arg == "on")
    elseif command=="align" and (arg=="left" or arg=="center" or arg=="right") then layout("align",arg)
    elseif command=="scale" and tonumber(arg) and self.sv.style=="analog" then layout("dialScale",tonumber(arg))
    elseif command=="layer" and (arg=="back" or arg=="normal" or arg=="front") then layout("layer",arg)
    elseif command=="color" and arg:match("^%x%x%x%x%x%x$") then
        layout("color",{tonumber(arg:sub(1,2),16)/255,tonumber(arg:sub(3,4),16)/255,tonumber(arg:sub(5,6),16)/255})
    elseif (command == "size" or command == "font" or command == "x" or command == "y" or command == "opacity") and tonumber(arg) then
        if command=="opacity" then self:Set("opacity",tonumber(arg))
        else
            local key=command=="font" and "fontSize" or command
            if command=="size" then key=self.sv.style=="digital" and "fontSize" or "dialScale" end
            layout(key,tonumber(arg))
        end
    elseif command == "status" then
        d(self.title .. ": " .. S.real .. " " .. self:FormatTime(self:ReadTime("real")) ..
            " / " .. S.game .. " " .. self:FormatTime(self:ReadTime("game")) .. " (" .. S[self.sv.source] .. ")")
    else d(S.help) end
    if self.panel and self.panel.UpdateControls then self.panel:UpdateControls() end
end

local function OnLoaded(_, name)
    if name ~= A.name then return end
    EVENT_MANAGER:UnregisterForEvent(A.name, EVENT_ADD_ON_LOADED)
    A.sv = ZO_SavedVars:NewAccountWide("PBsClock_Data", 1, nil, A.defaults)
    A:Normalize()
    A:CreateUI()
    A:ApplyLayout()
    A:InitSettings()
    SLASH_COMMANDS["/pbclock"] = function(input) A:Command(input) end
    local function refresh() A:RefreshVisibility() end
    HUD_SCENE:RegisterCallback("StateChange", refresh)
    HUD_UI_SCENE:RegisterCallback("StateChange", refresh)
    EVENT_MANAGER:RegisterForEvent(A.name, EVENT_PLAYER_ACTIVATED, function()
        A.active = true
        A:ApplyLayout()
        refresh()
    end)
    EVENT_MANAGER:RegisterForEvent(A.name, EVENT_PLAYER_DEACTIVATED, function()
        A.active = false
        A:SetPanelOpen(false)
        refresh()
    end)
    EVENT_MANAGER:RegisterForEvent(A.name, EVENT_SCREEN_RESIZED, function() A:ApplyLayout() end)
end
EVENT_MANAGER:RegisterForEvent(A.name, EVENT_ADD_ON_LOADED, OnLoaded)
