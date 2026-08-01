--[[
    Call-I-Do v2.1.3
    - FIX: Restores the Radial Wheel (wheel keybind functions existed as nil in v2.1.2).
    - Keeps previous fixes: LAM order, Set 2 rule (only slot 9 delayed 3s),
      and visible hint "Enable Sending In LibGroupSocket" when sending is disabled.
]]

CallIDo = CallIDo or {}
local ADDON, NAME, VERSION = CallIDo, "CallIDo", "2.1.3"

----------------------------------------------------------
-- Utils / Config
----------------------------------------------------------

local function CommLib() return LibGroupSocket or LibGroupBroadcast end

local FONT_PRESETS = {
    { name = "Propre (32)",  font = "$(MEDIUM_FONT)|32|soft-shadow-thick" },
    { name = "Propre (40)",  font = "$(BOLD_FONT)|40|soft-shadow-thick" },
    { name = "Antique (36)", font = "EsoUI/Common/Fonts/Antique_Thumb.TTF|36|soft-shadow-thick" },
    { name = "Trajan (34)",  font = "EsoUI/Common/Fonts/TrajanPro-Regular.otf|34|soft-shadow-thick" },
}

local SET1_MESSAGES = {
    [1] = "Push",
    [2] = "Retreat",
    [3] = "Hide",
    [4] = "Camp",
    [5] = "Regroup Crown",
    [6] = "(delayed) proxy",
    [7] = "(delayed) ready",
    [8] = "(delayed) push",
    [9] = "(delayed) empty",
}

local SET2_MESSAGES = {
    [1] = "Siege",
    [2] = "Regroup Crown",
    [3] = "Retreat",
    [4] = "Hide",
    [5] = "Camp",
    [6] = "Ready",
    [7] = "GG",
    [8] = "oops",
    [9] = "Proxy (Delayed 3 sec)",
}

local SET3_MESSAGES = {
    [1] = "-> regroup crown / rebuff <-",
    [2] = "use shalks / delayed burst",
    [3] = "push >:D",
    [4] = "retreat ->>>",
    [5] = "<- degroup / scatter ->",
    [6] = "get barrier ready",
    [7] = "hello o/",
    [8] = "gg :D",
    [9] = "inc many !",
}

local defaults = {
    durationMs = 1500,
    offsetY    = -120,
    maxWidth   = 1100,
    fontIndex  = 1,
    doBroadcast = true,
    countdownSeconds = 3,
    debug = false,
    showSenderId = true,
    activeSet = "custom",
    customMessages = {
        [1] = "Push",
        [2] = "Retreat",
        [3] = "Hide",
        [4] = "Camp",
        [5] = "Regroup Crown",
        [6] = "(delayed) proxy",
        [7] = "(delayed) ready",
        [8] = "(delayed) push",
        [9] = "(delayed) empty",
    },
}

local function log(fmt, ...)
    if ADDON.SV and ADDON.SV.debug then
        d(string.format("[Call-I-Do] "..tostring(fmt), ...))
    end
end

local function GetMessageForSlot(slotIndex)
    local setName = (ADDON.SV and ADDON.SV.activeSet) or defaults.activeSet
    if setName == "set1" then
        return SET1_MESSAGES[slotIndex]
    elseif setName == "set2" then
        return SET2_MESSAGES[slotIndex]
    elseif setName == "set3" then
        return SET3_MESSAGES[slotIndex]
    end
    local t = (ADDON.SV and ADDON.SV.customMessages) or defaults.customMessages
    return t[slotIndex]
end

----------------------------------------------------------
-- Display handles
----------------------------------------------------------
local currentText = { win=nil, lbl=nil }
local countdown = { handle=nil, win=nil, lblNum=nil, lblMsg=nil }

local function ClearCurrentText()
    if currentText.lbl then currentText.lbl:SetParent(nil) end
    if currentText.win then currentText.win:SetHidden(true); currentText.win:SetParent(nil) end
    currentText.win, currentText.lbl = nil, nil
end

local function CancelCountdown()
    if countdown.handle then EVENT_MANAGER:UnregisterForUpdate(countdown.handle) end
    if countdown.win then countdown.win:SetHidden(true) end
    if countdown.lblNum then countdown.lblNum:SetParent(nil) end
    if countdown.lblMsg then countdown.lblMsg:SetParent(nil) end
    if countdown.win then countdown.win:SetParent(nil) end
    countdown.handle, countdown.win, countdown.lblNum, countdown.lblMsg = nil, nil, nil, nil
end

local function ShowTextOnly(text, durationMs, offsetY, maxWidth, fontName)
    if not text or text == "" then return end
    CancelCountdown()
    ClearCurrentText()

    local wm  = WINDOW_MANAGER
    local win = wm:CreateTopLevelWindow(nil)
    win:SetMouseEnabled(false); win:SetMovable(false); win:SetClampedToScreen(true)
    win:SetDrawTier(DT_HIGH); win:SetDrawLayer(DL_FOREGROUND); win:SetDrawLevel(20000)
    win:ClearAnchors(); win:SetAnchor(CENTER, GuiRoot, CENTER, 0, offsetY or defaults.offsetY)
    win:SetDimensions(maxWidth or defaults.maxWidth, 10)

    local lbl = wm:CreateControl(nil, win, CT_LABEL)
    lbl:SetFont(fontName or FONT_PRESETS[defaults.fontIndex].font)
    lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER); lbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    lbl:SetDimensionConstraints(0,0, maxWidth or defaults.maxWidth, 0)
    lbl:SetAnchor(CENTER, win, CENTER, 0, 0)
    lbl:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    lbl:SetText(tostring(text))
    lbl:SetColor(1,1,1,1)
    if lbl.SetShadowColor and lbl.SetShadowOffset then
        lbl:SetShadowColor(0,0,0,0.9); lbl:SetShadowOffset(2,2)
    end
    win:SetHidden(false)

    currentText.win, currentText.lbl = win, lbl

    zo_callLater(function()
        if lbl and lbl.SetParent then lbl:SetParent(nil) end
        if win and win.SetParent then win:SetParent(nil) end
        if currentText.win == win then currentText.win, currentText.lbl = nil, nil end
    end, durationMs or defaults.durationMs)
end

function ADDON:ShowLocal(text)
    local idx      = (ADDON.SV and ADDON.SV.fontIndex) or defaults.fontIndex
    local preset   = FONT_PRESETS[idx] or FONT_PRESETS[1]
    local duration = (ADDON.SV and ADDON.SV.durationMs) or defaults.durationMs
    local offsetY  = (ADDON.SV and ADDON.SV.offsetY)  or defaults.offsetY
    local maxWidth = (ADDON.SV and ADDON.SV.maxWidth) or defaults.maxWidth
    ShowTextOnly(text, duration, offsetY, maxWidth, preset.font)
end

----------------------------------------------------------
-- Countdown
----------------------------------------------------------
local function StartCountdown(seconds, onDone, msgText)
    CancelCountdown()
    ClearCurrentText()

    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    if seconds <= 0 then
        if type(onDone)=="function" then onDone() end
        return
    end

    local wm  = WINDOW_MANAGER
    local win = wm:CreateTopLevelWindow(nil)
    win:SetMouseEnabled(false); win:SetMovable(false); win:SetClampedToScreen(true)
    win:SetDrawTier(DT_HIGH); win:SetDrawLayer(DL_FOREGROUND); win:SetDrawLevel(20001)
    local baseY = (((ADDON.SV and ADDON.SV.offsetY) or defaults.offsetY) - 80)
    win:SetAnchor(CENTER, GuiRoot, CENTER, 0, baseY)
    win:SetDimensions(1000, 120)

    local lblNum = wm:CreateControl(nil, win, CT_LABEL)
    lblNum:SetFont("$(BOLD_FONT)|80|soft-shadow-thick")
    lblNum:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    lblNum:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    lblNum:SetAnchor(CENTER, win, CENTER, 0, 0)
    lblNum:SetColor(1,1,1,1)
    if lblNum.SetShadowColor and lblNum.SetShadowOffset then
        lblNum:SetShadowColor(0,0,0,0.9); lblNum:SetShadowOffset(2,2)
    end

    local idx = (ADDON.SV and ADDON.SV.fontIndex) or defaults.fontIndex
    local lblMsg = wm:CreateControl(nil, win, CT_LABEL)
    lblMsg:SetFont((FONT_PRESETS[idx] or FONT_PRESETS[1]).font)
    lblMsg:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    lblMsg:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    lblMsg:SetDimensionConstraints(0,0, (ADDON.SV and ADDON.SV.maxWidth) or defaults.maxWidth, 0)
    lblMsg:SetAnchor(TOP, lblNum, BOTTOM, 0, 10)
    lblMsg:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    lblMsg:SetColor(1,1,1,1)
    lblMsg:SetText(tostring(msgText or ""))

    countdown.win, countdown.lblNum, countdown.lblMsg = win, lblNum, lblMsg
    win:SetHidden(false)

    local remaining = seconds
    lblNum:SetText(tostring(remaining))
    local handle = NAME.."_Countdown"
    countdown.handle = handle
    EVENT_MANAGER:RegisterForUpdate(handle, 1000, function()
        remaining = remaining - 1
        if remaining <= 0 then
            CancelCountdown()
            if type(onDone)=="function" then zo_callLater(onDone, 0) end
            return
        end
        lblNum:SetText(tostring(remaining))
    end)
end

----------------------------------------------------------
-- Comms
----------------------------------------------------------
local function IsSendingEnabled()
    local lib = CommLib(); if not lib then return false end
    if lib.IsSendingEnabled then return lib:IsSendingEnabled() end
    if type(lib.sendingEnabled)=="boolean" then return lib.sendingEnabled end
    return true
end

local function TryEnableSending()
    local lib = CommLib(); if not lib then return false end
    if lib.SetSendingEnabled then pcall(function() lib:SetSendingEnabled(true) end) end
    if lib.EnableSending     then pcall(function() lib:EnableSending(true)     end) end
    if lib.Enable            then pcall(function() lib:Enable(true)            end) end
    if LibGroupBroadcast and LibGroupBroadcast~=lib then
        pcall(function() LibGroupBroadcast:SetSendingEnabled(true) end)
        pcall(function() LibGroupBroadcast:Enable(true) end)
    end
    return IsSendingEnabled()
end

local Transport = { msgType = 30, enabled = false }

local function GetPayloadFromVarargs(...)
    local args = {...}
    for i=1,#args do
        if type(args[i])=="table" and args[i][1]~=nil then return args[i] end
    end
    return nil
end

local function GetSenderFromVarargs(...)
    local args = {...}
    for i=1,#args do
        local v = args[i]
        if type(v)=="string" and v ~= "" then
            if v:sub(1,1)=="@" then return v end
        end
    end
    for i=1,#args do
        local v = args[i]
        if type(v)=="string" and v ~= "" then return v end
    end
    return nil
end

local function MyGroupIndex()
    local ok, idx = pcall(function() return GetGroupIndexByUnitTag("player") end)
    idx = tonumber(ok and idx) or 0
    if not idx or idx < 1 then idx = 0 end
    return idx
end

local function GetGroupMemberNameByIndex(index)
    if not index or index < 1 then return nil end
    local unitTag = GetGroupUnitTagByIndex(index)
    if not unitTag or unitTag=="" then return nil end
    local display = GetUnitDisplayName(unitTag)
    if display and display ~= "" then return display end
    local name = GetUnitName(unitTag)
    if name and name ~= "" then return name end
    return nil
end

-- Ignore enabled state here; just check presence of lib/group capability.
local function CanBroadcastLibraryReady()
    local doBC = (ADDON.SV and ADDON.SV.doBroadcast) or defaults.doBroadcast
    if not doBC then return false end
    if not IsUnitGrouped("player") then return false end
    local lib = CommLib()
    if not lib or not lib.Send then return false end
    return true
end

local function Transport_Init()
    Transport.enabled = false
    local doBC = (ADDON.SV and ADDON.SV.doBroadcast) or defaults.doBroadcast
    if not doBC then return end
    local lib = CommLib()
    if not lib then d("[Call-I-Do] No LibGroupSocket/LibGroupBroadcast found.") return end

    if lib.RegisterCallback then
        lib:RegisterCallback(Transport.msgType, function(...)
            local sender  = GetSenderFromVarargs(...)
            local payload = GetPayloadFromVarargs(...)
            local slot    = payload and tonumber(payload[1])
            if not slot or slot < 1 or slot > 9 then return end

            local senderIndex = tonumber(payload[2])
            local msg = GetMessageForSlot(slot)

            if msg and msg ~= "" then
                local showId = (ADDON.SV and ADDON.SV.showSenderId ~= nil) and ADDON.SV.showSenderId or defaults.showSenderId
                if showId then
                    local display = GetGroupMemberNameByIndex(senderIndex) or sender
                    if not display and senderIndex and senderIndex >= 1 then
                        display = "#" .. tostring(senderIndex)
                    end
                    if display then
                        msg = string.format("[%s] %s", display, msg)
                    end
                end
                ADDON:ShowLocal(msg)
            end
        end)
    else
        d("[Call-I-Do] Comm lib has no RegisterCallback → cannot receive.")
        return
    end

    if not IsSendingEnabled() then TryEnableSending() end
    Transport.enabled = true
end

local function Transport_Send(slotIndex)
    local doBC = (ADDON.SV and ADDON.SV.doBroadcast) or defaults.doBroadcast
    if not doBC then return false end
    local lib = CommLib()
    if not lib or not lib.Send then return false end
    if not IsUnitGrouped("player") then return false end
    if not IsSendingEnabled() then
        d("[Call-I-Do] Sending disabled in comm lib.")
        ADDON:ShowLocal("Enable Sending In LibGroupSocket")
        return false
    end
    pcall(function() lib:Send(Transport.msgType, {slotIndex, MyGroupIndex()}) end)
    return true
end

----------------------------------------------------------
-- Public API
----------------------------------------------------------
local function CallImmediate(slotIndex)
    local msg = GetMessageForSlot(slotIndex)
    if not msg or msg == "" then
        d(string.format("[Call-I-Do] Message %d is empty.", slotIndex))
        return
    end

    if CanBroadcastLibraryReady() then
        local sent = Transport_Send(slotIndex)
        if sent then
            return -- wait for echoed receive
        else
            return -- hint already shown if disabled
        end
    end

    ADDON:ShowLocal(msg)
end

function ADDON:Call(slotIndex)
    slotIndex = tonumber(slotIndex)
    if not slotIndex or slotIndex < 1 or slotIndex > 9 then
        d("[Call-I-Do] Invalid slot index. Must be 1..9.")
        return
    end

    local setName = (ADDON.SV and ADDON.SV.activeSet) or defaults.activeSet
    if setName == "set2" then
        if slotIndex == 9 then
            local msg = GetMessageForSlot(slotIndex) or ""
            StartCountdown(3, function() CallImmediate(slotIndex) end, msg)
        else
            CallImmediate(slotIndex)
        end
        return
    elseif setName == "set3" then
        CallImmediate(slotIndex)
        return
    end

    local secsCfg = (ADDON.SV and ADDON.SV.countdownSeconds) or defaults.countdownSeconds
    if slotIndex >= 6 and slotIndex <= 9 and (secsCfg or 0) > 0 then
        local secs = math.floor(secsCfg or 0)
        local msg  = GetMessageForSlot(slotIndex) or ""
        StartCountdown(secs, function() CallImmediate(slotIndex) end, msg)
    else
        CallImmediate(slotIndex)
    end
end

for i=1,9 do
    _G[string.format("CallIDo_Call%d", i)] = function() ADDON:Call(i) end
end

local function SlashCommand(arg)
    arg = (arg or ""):lower():gsub("^%s+",""):gsub("%s+$","")
    if arg=="test" then ADDON:Call(1); return end
    if arg=="enable" then TryEnableSending(); return end
    local n = tonumber(arg)
    if n and n>=1 and n<=9 then ADDON:Call(n)
    else d("[Call-I-Do] /callido <1-9> | test | enable") end
end

----------------------------------------------------------
-- LAM (menu)
----------------------------------------------------------
local PANEL_ID = "CallIDoOptions"

local function BuildReadOnlyList(setTable, title)
    local lines = {}
    for i=1,9 do
        local msg = setTable[i] or ""
        table.insert(lines, string.format("%d) %s", i, msg))
    end
    return string.format("|cFFFFFF%s|r\n%s", title, table.concat(lines, "\n"))
end

local function BuildLAM()
    if not LibAddonMenu2 then return end
    local LAM = LibAddonMenu2

    local panelData = {
        type = "panel",
        name = "Call-I-Do",
        displayName = "Call-I-Do",
        author = "Lebiez",
        version = 1.07,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local opts = {}

    -- Description
    table.insert(opts, { type = "header", name = "Description" })
    table.insert(opts, {
        type = "description",
        text = "Choisissez un set actif en bas de cette section. Set 1, Set 2 et Set 3 sont en lecture seule. Le set Custom est éditable. En Set 2, seul le message 9 est retardé (3s).",
        width = "full",
    })

    -- Read-only (Set 1, Set 2 & Set 3)
    table.insert(opts, { type="header", name="Read-only (Set 1, Set 2 & Set 3)" })
    table.insert(opts, {
        type = "description",
        text = BuildReadOnlyList(SET1_MESSAGES, "Set 1"),
        width = "half",
    })
    table.insert(opts, {
        type = "description",
        text = BuildReadOnlyList(SET2_MESSAGES, "Set 2"),
        width = "half",
    })
    table.insert(opts, {
        type = "description",
        text = BuildReadOnlyList(SET3_MESSAGES, "Set 3"),
        width = "full",
    })

    -- Active Set selector
    table.insert(opts, {
        type = "dropdown",
        name = "Active Set",
        choices = { "Set 1", "Set 2", "Set 3", "Custom" },
        getFunc = function()
            local setName = (ADDON.SV and ADDON.SV.activeSet) or defaults.activeSet
            if setName == "set1" then return "Set 1"
            elseif setName == "set2" then return "Set 2"
            elseif setName == "set3" then return "Set 3"
            else return "Custom" end
        end,
        setFunc = function(choice)
            if choice == "Set 1" then ADDON.SV.activeSet = "set1"
            elseif choice == "Set 2" then ADDON.SV.activeSet = "set2"
            elseif choice == "Set 3" then ADDON.SV.activeSet = "set3"
            else ADDON.SV.activeSet = "custom" end
        end,
        width = "full",
    })

    table.insert(opts, { type="divider" })

    -- Editable (Custom)
    table.insert(opts, { type="header", name="Editable (Custom)" })

    for i=1,9 do
        local function suffixForName()
            local secs = (ADDON.SV and ADDON.SV.countdownSeconds) or defaults.countdownSeconds
            if i>=6 and i<=9 and (secs or 0) > 0 then
                return string.format(" (Delayed – %ds)", math.floor(secs or 0))
            end
            return ""
        end
        table.insert(opts, {
            type = "editbox",
            name = function() return string.format("Custom Message %d%s", i, suffixForName()) end,
            tooltip = function() return string.format("Custom text used when the active set is 'Custom' (slot %d).", i) end,
            getFunc = function()
                local t = (ADDON.SV and ADDON.SV.customMessages) or defaults.customMessages
                return t[i]
            end,
            setFunc = function(v)
                ADDON.SV = ADDON.SV or ZO_SavedVars:NewAccountWide("CallIDo_SV", 1, nil, defaults)
                ADDON.SV.customMessages = ADDON.SV.customMessages or {}
                ADDON.SV.customMessages[i] = v or ""
            end,
            isMultiline = false,
            width = "full",
            disabled = function()
                local setName = (ADDON.SV and ADDON.SV.activeSet) or defaults.activeSet
                return setName ~= "custom"
            end,
        })
    end

    -- Display settings
    table.insert(opts, { type="header", name="Display" })
    table.insert(opts, { type="slider", name="Duration (ms)", min=500, max=5000, step=100,
        getFunc=function() return (ADDON.SV and ADDON.SV.durationMs) or defaults.durationMs end,
        setFunc=function(v) ADDON.SV.durationMs=v end })
    table.insert(opts, { type="slider", name="Vertical offset (Y)", min=-400, max=400, step=5,
        getFunc=function() return (ADDON.SV and ADDON.SV.offsetY) or defaults.offsetY end,
        setFunc=function(v) ADDON.SV.offsetY=v end })
    table.insert(opts, { type="slider", name="Max width (px)", min=400, max=1600, step=10,
        getFunc=function() return (ADDON.SV and ADDON.SV.maxWidth) or defaults.maxWidth end,
        setFunc=function(v) ADDON.SV.maxWidth=v end })
    table.insert(opts, { type="dropdown", name="Font",
        choices = (function() local t = {}; for i,p in ipairs(FONT_PRESETS) do t[i]=p.name end; return t end)(),
        getFunc=function()
            local idx = (ADDON.SV and ADDON.SV.fontIndex) or defaults.fontIndex
            return (FONT_PRESETS[idx] and FONT_PRESETS[idx].name) or FONT_PRESETS[1].name
        end,
        setFunc=function(name)
            for i,p in ipairs(FONT_PRESETS) do
                if p.name==name then ADDON.SV.fontIndex=i; break end
            end
        end,
    })

    -- Group settings
    table.insert(opts, { type="header", name="Group" })
    table.insert(opts, { type="checkbox", name="Enable group broadcast",
        tooltip="Send your message to group via LibGroupSocket/LibGroupBroadcast.",
        getFunc=function() return (ADDON.SV and ADDON.SV.doBroadcast) or defaults.doBroadcast end,
        setFunc=function(v) ADDON.SV.doBroadcast = v and true or false end })
    table.insert(opts, { type="checkbox", name="Show sender identity",
        tooltip="Prefix received message with member name (via index) or @Account; otherwise [#index].",
        getFunc=function() return (ADDON.SV and ADDON.SV.showSenderId ~= nil) and ADDON.SV.showSenderId or defaults.showSenderId end,
        setFunc=function(v) ADDON.SV.showSenderId = v and true or false end })
    table.insert(opts, { type="checkbox", name="Debug log",
        getFunc=function() return (ADDON.SV and ADDON.SV.debug) or defaults.debug end,
        setFunc=function(v) ADDON.SV.debug = v and true or false end })

    -- Countdown settings
    table.insert(opts, { type="header", name="Countdown (slots 6–9) — Set 1 & Custom" })
    table.insert(opts, { type="slider", name="Seconds", min=0, max=10, step=1,
        getFunc=function() return (ADDON.SV and ADDON.SV.countdownSeconds) or defaults.countdownSeconds end,
        setFunc=function(v) ADDON.SV.countdownSeconds = math.max(0, math.floor(tonumber(v) or 0)) end })

    LAM:RegisterAddonPanel(PANEL_ID, panelData)
    LAM:RegisterOptionControls(PANEL_ID, opts)
end

----------------------------------------------------------
-- Load
----------------------------------------------------------
local function OnLoaded(_, addonName)
    if addonName ~= NAME then return end
    EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
    ADDON.SV = ZO_SavedVars:NewAccountWide("CallIDo_SV", 1, nil, defaults)
    ADDON.SV.customMessages = ADDON.SV.customMessages or defaults.customMessages
    ADDON.SV.activeSet = ADDON.SV.activeSet or defaults.activeSet

    BuildLAM()
    SLASH_COMMANDS["/callido"] = SlashCommand
    for i=1,9 do
        ZO_CreateStringId(string.format("SI_BINDING_NAME_CALLIDO_%d", i), string.format("Call %d", i))
    end
    Transport_Init()
    d(string.format("[Call-I-Do] Loaded v%s.", VERSION))
end

EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnLoaded)

----------------------------------------------------------
-- Radial Wheel (restored)
----------------------------------------------------------
do
    local wheel = {
        win=nil, buttons={}, labels={}, isVisible=false,
        selected=nil, centerX=0, centerY=0, fullLabel=nil,
    }

    local RADIUS        = 180
    local BTN_SIZE      = 64
    local SEG_COUNT     = 9
    local HILIGHT_SCALE = 1.12

    local INNER_RADIUS  = BTN_SIZE * 0.45
    local OUTER_RADIUS  = RADIUS + BTN_SIZE * 0.55

    local DEADZONE      = 0.25
    local INVERT_GAMEPAD_X = false

    local COLOR_N = {1,1,1,1}
    local COLOR_S = {0,0,0,1}

    local Input = {
        source = "auto",
        lastMouseMovedAt = 0,
        lastStickMovedAt = 0,
        mouseHold = 0.25,
        stickHold = 0.35,
    }

    local function First3(msg)
        msg = tostring(msg or "")
        local tri = zo_strsub(msg, 1, 3) or ""
        tri = tri:gsub("%s", "")
        return zo_strupper(tri)
    end

    local function SetButtonHighlight(idx, on)
        local btn = wheel.buttons[idx]; if not btn then return end
        local lbl = wheel.labels[idx]
        if on then
            btn:SetScale(HILIGHT_SCALE)
            btn:SetMouseOverTexture("EsoUI/Art/ActionBar/abilityFrame64_over.dds")
            if lbl then lbl:SetColor(unpack(COLOR_S)) end
        else
            btn:SetScale(1.0)
            btn:SetMouseOverTexture("EsoUI/Art/ActionBar/abilityFrame64_over.dds")
            if lbl then lbl:SetColor(unpack(COLOR_N)) end
        end
    end

    local function AngleToIndex(angleTopClockwise)
        local twoPi = 2*math.pi
        angleTopClockwise = angleTopClockwise % twoPi
        local step = twoPi / SEG_COUNT
        local idx = math.floor((angleTopClockwise + step/2) / step) + 1
        if idx < 1 then idx = 1 end
        if idx > SEG_COUNT then idx = SEG_COUNT end
        return idx
    end

    local function ComputeMouseSelection()
        local mx, my = GetUIMousePosition()
        local cx, cy = wheel.centerX, wheel.centerY
        local dx = mx - cx
        local dy = cy - my

        local r = math.sqrt(dx*dx + dy*dy)
        if r < INNER_RADIUS or r > OUTER_RADIUS then
            return nil
        end

        local angle = (math.pi/2) - math.atan2(dy, dx)
        return AngleToIndex(angle)
    end

    local function ComputeStickSelection()
        local x = GetGamepadRightStickX and (GetGamepadRightStickX(true) or 0) or 0
        local y = GetGamepadRightStickY and (GetGamepadRightStickY(true) or 0) or 0

        if INVERT_GAMEPAD_X then x = -x end

        local mag = math.sqrt(x*x + y*y)
        if mag < DEADZONE then return nil end

        local angle = (math.pi/2) - math.atan2(y, x)
        return AngleToIndex(angle)
    end

    local function UpdateFullLabelText(idx)
        if not wheel.fullLabel then return end
        local msg = (type(GetMessageForSlot)=="function") and GetMessageForSlot(idx or 0) or ""
        wheel.fullLabel:SetText(tostring(msg or ""))
    end

    local function UpdateSelection()
        if not wheel.isVisible then return end

        local now = GetFrameTimeSeconds()
        local cx, cy = wheel.win:GetCenter()
        wheel.centerX, wheel.centerY = cx, cy

        local sx = GetGamepadRightStickX and (GetGamepadRightStickX(true) or 0) or 0
        local sy = GetGamepadRightStickY and (GetGamepadRightStickY(true) or 0) or 0
        local smag = math.sqrt(sx*sx + sy*sy)
        local stickIdx = nil
        if smag >= DEADZONE then
            stickIdx = ComputeStickSelection()
            Input.lastStickMovedAt = now
            Input.source = "gamepad"
        end

        local mouseIdx = ComputeMouseSelection()
        if mouseIdx then
            Input.lastMouseMovedAt = now
            local gamepadPref = IsInGamepadPreferredMode and IsInGamepadPreferredMode()
            if (not gamepadPref) or (now - Input.lastStickMovedAt > Input.stickHold) then
                Input.source = "mouse"
            end
        end

        local newIdx = wheel.selected
        if Input.source == "gamepad" then
            if stickIdx ~= nil then newIdx = stickIdx end
        else
            if mouseIdx ~= nil then
                newIdx = mouseIdx
            elseif stickIdx ~= nil and (now - Input.lastMouseMovedAt > Input.mouseHold) then
                newIdx = stickIdx
            end
        end

        if newIdx ~= wheel.selected then
            if wheel.selected then SetButtonHighlight(wheel.selected, false) end
            wheel.selected = newIdx
            if wheel.selected then
                SetButtonHighlight(wheel.selected, true)
                UpdateFullLabelText(wheel.selected)
            else
                UpdateFullLabelText(nil)
            end
        end
    end

    local function BuildWheel()
        if wheel.win then return end
        local wm = WINDOW_MANAGER

        local win = wm:CreateTopLevelWindow("CallIDo_RadialWheel")
        win:SetMouseEnabled(true)
        win:SetMovable(false)
        win:SetClampedToScreen(true)
        win:SetDrawTier(DT_HIGH); win:SetDrawLayer(DL_FOREGROUND); win:SetDrawLevel(25000)
        win:ClearAnchors()
        win:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        win:SetHidden(true)
        wheel.win = win

        local dim = wm:CreateControl(nil, win, CT_BACKDROP)
        dim:SetAnchorFill(win)
        dim:SetCenterColor(0,0,0,0.35)
        dim:SetEdgeColor(0,0,0,0)

        local guide = wm:CreateControl(nil, win, CT_TEXTURE)
        guide:SetDimensions(RADIUS*2+20, RADIUS*2+20)
        guide:SetAnchor(CENTER, win, CENTER, 0, 0)
        guide:SetTexture("EsoUI/Art/Crafting/crafting_alchemy_traitSlot.dds")
        guide:SetAlpha(0.15)

        for i=1,SEG_COUNT do
            local btn = wm:CreateControl("CallIDo_RadialBtn"..i, win, CT_BUTTON)
            btn:SetDimensions(BTN_SIZE, BTN_SIZE)
            btn:SetNormalTexture("EsoUI/Art/ActionBar/abilityFrame64_up.dds")
            btn:SetMouseOverTexture("EsoUI/Art/ActionBar/abilityFrame64_over.dds")
            btn:SetPressedTexture("EsoUI/Art/ActionBar/abilityFrame64_down.dds")

            local angle = (i-1) * (2*math.pi/SEG_COUNT) - math.pi/2
            local dx = math.cos(angle) * RADIUS
            local dy = math.sin(angle) * RADIUS
            btn:ClearAnchors()
            btn:SetAnchor(CENTER, win, CENTER, dx, dy)

            local lbl = wm:CreateControl(nil, btn, CT_LABEL)
            lbl:SetAnchor(CENTER, btn, CENTER, 0, 0)
            lbl:SetFont("$(BOLD_FONT)|28|soft-shadow-thick")
            lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            lbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            lbl:SetColor(unpack(COLOR_N))

            btn:SetHandler("OnClicked", function()
                ADDON:Call(i)
                CallIDo_Wheel_Hide()
            end)

            wheel.buttons[i] = btn
            wheel.labels[i]  = lbl
        end

        local full = wm:CreateControl("CallIDo_RadialFullText", win, CT_LABEL)
        full:ClearAnchors()
        full:SetAnchor(TOP, win, CENTER, 0, RADIUS + BTN_SIZE)
        full:SetFont("$(BOLD_FONT)|20|soft-shadow-thick")
        full:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        full:SetVerticalAlignment(TEXT_ALIGN_TOP)
        full:SetColor(1,1,1,1)
        full:SetWidth(RADIUS*2 + 300)
        full:SetText("")
        wheel.fullLabel = full

        win:SetHandler("OnUpdate", function() UpdateSelection() end)
        win:SetHandler("OnEffectivelyHidden", function()
            wheel.isVisible=false
            if wheel.selected then SetButtonHighlight(wheel.selected, false) end
            wheel.selected=nil
            UpdateFullLabelText(nil)
        end)
    end

    local function UpdateWheelLabels()
        if not wheel.win then return end
        for i=1,SEG_COUNT do
            local msg = (type(GetMessageForSlot)=="function") and GetMessageForSlot(i) or tostring(i)
            local tri = First3(msg ~= "" and msg or tostring(i))
            if wheel.labels[i] then
                wheel.labels[i]:SetText(tri)
            end
        end
    end

    function CallIDo_Wheel_Show()
        BuildWheel()
        UpdateWheelLabels()
        SetGameCameraUIMode(true)
        if SetGamepadPreferredMode then SetGamepadPreferredMode(true) end
        wheel.win:SetHidden(false)
        wheel.isVisible = true

        if IsInGamepadPreferredMode and IsInGamepadPreferredMode() then
            Input.source = "gamepad"
        else
            Input.source = "mouse"
        end

        local now = GetFrameTimeSeconds()
        Input.lastMouseMovedAt = now
        Input.lastStickMovedAt = now
    end

    function CallIDo_Wheel_Hide()
        if not wheel.win then return end
        if wheel.isVisible and wheel.selected then
            ADDON:Call(wheel.selected)
        end
        wheel.win:SetHidden(true)
        wheel.isVisible = false
        SetGameCameraUIMode(false)
        if SetGamepadPreferredMode then SetGamepadPreferredMode(false) end
    end

    ZO_CreateStringId("SI_BINDING_NAME_CALLIDO_WHEEL", "Radial Wheel")

    -- Preserve existing OnLoaded
    local prev_OnLoaded = OnLoaded
    OnLoaded = function(eventCode, addonName)
        if prev_OnLoaded then prev_OnLoaded(eventCode, addonName) end
        if addonName ~= NAME then return end
        ZO_CreateStringId("SI_BINDING_NAME_CALLIDO_WHEEL", "Radial Wheel")
    end
end
