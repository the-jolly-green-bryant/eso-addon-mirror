PullCard = PullCard or {}
local PC = PullCard

PC.name = "PullCard"
PC.version = "0.2.0"
PC.window = nil
PC.miniButton = nil
PC.currentBossName = nil
PC.currentBossData = nil
PC.manualIndex = 1
PC.detectedBossNames = {}
PC.debugMode = true

local function Trim(s)
    if not s then return "" end
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function SortedBossNames()
    local names = {}
    for name in pairs(PullCardData.bosses) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

function PC:GetDetectedBossNames()
    local found = {}
    for i = 1, MAX_BOSSES do
        local tag = "boss" .. i
        if DoesUnitExist(tag) then
            local name = Trim(GetUnitName(tag))
            if name ~= "" then
                table.insert(found, name)
            end
        end
    end
    return found
end

function PC:GetBestDetectedBoss()
    local found = self:GetDetectedBossNames()
    self.detectedBossNames = found

    for _, name in ipairs(found) do
        if PullCardData.bosses[name] then
            return name
        end
    end

    return found[1]
end

function PC:GetPlayerRoleText(data)
    if not data then return "" end

    local role = GetSelectedLFGRole()
    if role == LFG_ROLE_TANK then
        return data.tank or ""
    elseif role == LFG_ROLE_HEAL then
        return data.healer or ""
    elseif role == LFG_ROLE_DPS then
        return data.dps or ""
    end

    return ""
end

function PC:GetDebugText()
    if not self.debugMode then return "" end

    local zoneName = GetUnitZone("player") or "?"
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    local bosses = (#self.detectedBossNames > 0) and table.concat(self.detectedBossNames, ", ") or "none"

    return string.format(
        "DEBUG\nZone: %s (%s)\nDetected: %s",
        tostring(zoneName),
        tostring(zoneId),
        bosses
    )
end

function PC:SetBoss(name, source)
    self.currentBossName = name
    self.currentBossData = name and PullCardData.bosses[name] or nil
    self.currentSource = source or "unknown"
    self:Render()
end

function PC:RefreshAuto()
    local detected = self:GetBestDetectedBoss()

    if detected then
        self:SetBoss(detected, "auto")
        self.window:SetHidden(false)
        self.miniButton:SetHidden(true)
    else
        self.currentBossName = nil
        self.currentBossData = nil
        self.currentSource = "none"
        self:Render()
    end
end

function PC:Render()
    if not self.window then return end

    local bossName = self.currentBossName
    local data = self.currentBossData

    if not bossName then
        self.window.title:SetText("PullCard")
        self.window.body:SetText("No active boss detected.\nUse Previous / Next to browse known fights.")
        self.window.role:SetText("")
        self.window.chatButton:SetEnabled(false)
    elseif data then
        self.window.title:SetText((data.dungeon or "Dungeon") .. " — " .. (data.title or bossName))
        self.window.body:SetText("EVERYONE\n" .. (data.everyone or "No notes yet."))

        local roleText = self:GetPlayerRoleText(data)
        if roleText ~= "" then
            self.window.role:SetText("YOUR ROLE\n" .. roleText)
        else
            self.window.role:SetText("")
        end

        self.window.chatButton:SetEnabled(data.tldr ~= nil and data.tldr ~= "")
    else
        self.window.title:SetText(bossName)
        self.window.body:SetText("Boss detected, but no PullCard exists yet.")
        self.window.role:SetText("")
        self.window.chatButton:SetEnabled(false)
    end

    local debug = self:GetDebugText()
    if debug ~= "" then
        self.window.debug:SetText(debug)
        self.window.debug:SetHidden(false)
    else
        self.window.debug:SetHidden(true)
    end
end

function PC:Browse(delta)
    local names = SortedBossNames()
    if #names == 0 then return end

    self.manualIndex = self.manualIndex + delta
    if self.manualIndex < 1 then self.manualIndex = #names end
    if self.manualIndex > #names then self.manualIndex = 1 end

    self:SetBoss(names[self.manualIndex], "manual")
    self.window:SetHidden(false)
    self.miniButton:SetHidden(true)
end

function PC:PrefillGroupChat()
    local d = self.currentBossData
    if not d or not d.tldr or d.tldr == "" then return end

    -- Deliberately isolated. PC behavior is known; console/gamepad behavior
    -- can be swapped here without changing the rest of the addon.
    local chatSystem = ZO_GetChatSystem and ZO_GetChatSystem()
    if chatSystem and chatSystem.StartTextEntry then
        chatSystem:StartTextEntry(d.tldr, CHAT_CHANNEL_PARTY, nil, true)
    end
end

function PC:ToggleWindow()
    local hidden = self.window:IsHidden()
    self.window:SetHidden(not hidden)
    self.miniButton:SetHidden(hidden)
end

function PC:CreateMiniButton()
    local wm = WINDOW_MANAGER

    local button = wm:CreateControlFromVirtual("PullCardMiniButton", GuiRoot, "ZO_DefaultButton")
    self.miniButton = button
    button:SetDimensions(70, 32)
    button:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, -40, -180)
    button:SetText("PullCard")
    button:SetHidden(false)
    button:SetHandler("OnClicked", function()
        PC.window:SetHidden(false)
        button:SetHidden(true)
        PC:Render()
    end)
end

function PC:CreateWindow()
    local wm = WINDOW_MANAGER

    local top = wm:CreateTopLevelWindow("PullCardWindow")
    self.window = top
    top:SetDimensions(470, 360)
    top:SetAnchor(CENTER, GuiRoot, CENTER, 0, 90)
    top:SetMovable(true)
    top:SetMouseEnabled(true)
    top:SetClampedToScreen(true)
    top:SetHidden(true)

    local bg = wm:CreateControl(nil, top, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.05, 0.05, 0.05, 0.94)
    bg:SetEdgeColor(0.5, 0.5, 0.5, 0.9)
    bg:SetEdgeTexture("", 1, 1, 1)

    local title = wm:CreateControl(nil, top, CT_LABEL)
    top.title = title
    title:SetFont("ZoFontWinH3")
    title:SetAnchor(TOPLEFT, top, TOPLEFT, 16, 14)
    title:SetAnchor(TOPRIGHT, top, TOPRIGHT, -16, 14)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    title:SetText("PullCard")

    local body = wm:CreateControl(nil, top, CT_LABEL)
    top.body = body
    body:SetFont("ZoFontGame")
    body:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 18)
    body:SetAnchor(TOPRIGHT, title, BOTTOMRIGHT, 0, 18)
    body:SetHeight(95)
    body:SetVerticalAlignment(TEXT_ALIGN_TOP)

    local role = wm:CreateControl(nil, top, CT_LABEL)
    top.role = role
    role:SetFont("ZoFontGame")
    role:SetAnchor(TOPLEFT, body, BOTTOMLEFT, 0, 8)
    role:SetAnchor(TOPRIGHT, body, BOTTOMRIGHT, 0, 8)
    role:SetHeight(55)
    role:SetVerticalAlignment(TEXT_ALIGN_TOP)

    local debug = wm:CreateControl(nil, top, CT_LABEL)
    top.debug = debug
    debug:SetFont("ZoFontGameSmall")
    debug:SetAnchor(TOPLEFT, role, BOTTOMLEFT, 0, 8)
    debug:SetAnchor(TOPRIGHT, role, BOTTOMRIGHT, 0, 8)
    debug:SetHeight(60)
    debug:SetVerticalAlignment(TEXT_ALIGN_TOP)

    local prev = wm:CreateControlFromVirtual("PullCardPrevButton", top, "ZO_DefaultButton")
    prev:SetDimensions(80, 32)
    prev:SetAnchor(BOTTOMLEFT, top, BOTTOMLEFT, 16, -14)
    prev:SetText("< Prev")
    prev:SetHandler("OnClicked", function() PC:Browse(-1) end)

    local next = wm:CreateControlFromVirtual("PullCardNextButton", top, "ZO_DefaultButton")
    next:SetDimensions(80, 32)
    next:SetAnchor(LEFT, prev, RIGHT, 8, 0)
    next:SetText("Next >")
    next:SetHandler("OnClicked", function() PC:Browse(1) end)

    local chatButton = wm:CreateControlFromVirtual("PullCardChatButton", top, "ZO_DefaultButton")
    top.chatButton = chatButton
    chatButton:SetDimensions(175, 32)
    chatButton:SetAnchor(LEFT, next, RIGHT, 8, 0)
    chatButton:SetText("Explain to Group")
    chatButton:SetHandler("OnClicked", function() PC:PrefillGroupChat() end)

    local hide = wm:CreateControlFromVirtual("PullCardHideButton", top, "ZO_DefaultButton")
    hide:SetDimensions(80, 32)
    hide:SetAnchor(BOTTOMRIGHT, top, BOTTOMRIGHT, -16, -14)
    hide:SetText("Hide")
    hide:SetHandler("OnClicked", function()
        top:SetHidden(true)
        PC.miniButton:SetHidden(false)
    end)
end

function PC:Initialize()
    self:CreateWindow()
    self:CreateMiniButton()

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_BOSSES_CHANGED, function()
        zo_callLater(function()
            PC:RefreshAuto()
        end, 150)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(function()
            PC:RefreshAuto()
        end, 500)
    end)

    self:Render()
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= PC.name then return end

    EVENT_MANAGER:UnregisterForEvent(PC.name, EVENT_ADD_ON_LOADED)
    PC:Initialize()
end

EVENT_MANAGER:RegisterForEvent(PC.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
