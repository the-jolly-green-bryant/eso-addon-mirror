PullCard = PullCard or {}
local PC = PullCard

PC.name = "PullCard"
PC.version = "0.2.0"
PC.window = nil
PC.tipsWindow = nil
PC.miniButton = nil
PC.currentBossName = nil
PC.currentBossData = nil
PC.manualIndex = 1
PC.tipsDungeonIndex = 1
PC.tipsBossIndex = 1
PC.detectedBossNames = {}
PC.debugMode = false

local function Trim(s)
    if not s then return "" end
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function NormalizeBossName(name)
    local s = Trim(name)
    if s == "" then return "" end
    return s:lower():gsub("[%s%p]+", " ")
end

local function SortedBossNames()
    if not PullCardData or not PullCardData.bosses then return {} end

    local names = {}
    for name in pairs(PullCardData.bosses) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

local function IsVanillaBoss(data)
    return not (data and data.dlc)
end

local function BuildDungeonCatalog(vanillaOnly)
    local byDungeon = {}
    local order = {}

    if not PullCardData or not PullCardData.bosses then
        return order, byDungeon
    end

    local sourceOrder = nil
    if vanillaOnly and PullCardData.baseGameDungeonOrder then
        sourceOrder = PullCardData.baseGameDungeonOrder
    elseif PullCardData.dungeons then
        sourceOrder = {}
        for dungeonName in pairs(PullCardData.dungeons) do
            table.insert(sourceOrder, dungeonName)
        end
        table.sort(sourceOrder)
    end

    if sourceOrder then
        for _, dungeonName in ipairs(sourceOrder) do
            local dungeonEntry = PullCardData.dungeons and PullCardData.dungeons[dungeonName] or nil
            local bossNames = dungeonEntry and dungeonEntry.bosses or nil
            if bossNames and #bossNames > 0 then
                local filteredBosses = {}
                for _, bossName in ipairs(bossNames) do
                    local data = PullCardData.bosses[bossName]
                    if not vanillaOnly or IsVanillaBoss(data) then
                        table.insert(filteredBosses, bossName)
                    end
                end

                if #filteredBosses > 0 then
                    byDungeon[dungeonName] = { name = dungeonName, bosses = filteredBosses }
                    table.insert(order, dungeonName)
                end
            end
        end

        return order, byDungeon
    end

    for bossName, data in pairs(PullCardData.bosses) do
        if not vanillaOnly or IsVanillaBoss(data) then
            local dungeonName = (data and data.dungeon) or "Unknown Dungeon"
            local dungeonEntry = byDungeon[dungeonName]

            if not dungeonEntry then
                dungeonEntry = { name = dungeonName, bosses = {} }
                byDungeon[dungeonName] = dungeonEntry
                table.insert(order, dungeonName)
            end

            table.insert(dungeonEntry.bosses, bossName)
        end
    end

    table.sort(order)
    for _, dungeonName in ipairs(order) do
        table.sort(byDungeon[dungeonName].bosses)
    end

    return order, byDungeon
end

function PC:ResolveBossName(candidate)
    if not candidate then return nil end
    local key = NormalizeBossName(candidate)
    if key == "" then return nil end

    if PullCardData and PullCardData.bosses then
        for bossName, data in pairs(PullCardData.bosses) do
            if NormalizeBossName(bossName) == key then
                return bossName
            end

            if data and data.aliases then
                for _, alias in ipairs(data.aliases) do
                    if NormalizeBossName(alias) == key then
                        return bossName
                    end
                end
            end
        end
    end

    return nil
end

local MAX_BOSSES = 8

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
        local resolved = self:ResolveBossName(name)
        if resolved then
            return resolved
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

function PC:ToggleDebug()
    self.debugMode = not self.debugMode
    self:Render()
end

function PC:SetBoss(name, source)
    local resolved = name and self:ResolveBossName(name) or nil
    self.currentBossName = resolved or name
    self.currentBossData = self.currentBossName and PullCardData and PullCardData.bosses and PullCardData.bosses[self.currentBossName] or nil
    self.currentSource = source or "unknown"
    self:Render()
end

function PC:SetTipsBoss(name)
    local resolved = name and self:ResolveBossName(name) or nil
    self.currentBossName = resolved or name
    self.currentBossData = self.currentBossName and PullCardData and PullCardData.bosses and PullCardData.bosses[self.currentBossName] or nil
    self:RenderTipsLibrary()
end

function PC:GetTipsContext()
    local dungeonOrder, dungeonLookup = BuildDungeonCatalog(true)
    if #dungeonOrder == 0 then
        return dungeonOrder, dungeonLookup, nil, nil, nil, nil
    end

    if self.tipsDungeonIndex < 1 then self.tipsDungeonIndex = #dungeonOrder end
    if self.tipsDungeonIndex > #dungeonOrder then self.tipsDungeonIndex = 1 end

    local dungeonName = dungeonOrder[self.tipsDungeonIndex]
    local dungeonEntry = dungeonLookup[dungeonName]
    local bossNames = dungeonEntry and dungeonEntry.bosses or {}

    if #bossNames == 0 then
        return dungeonOrder, dungeonLookup, dungeonName, dungeonEntry, nil, bossNames
    end

    if self.tipsBossIndex < 1 then self.tipsBossIndex = #bossNames end
    if self.tipsBossIndex > #bossNames then self.tipsBossIndex = 1 end

    local bossName = bossNames[self.tipsBossIndex]
    return dungeonOrder, dungeonLookup, dungeonName, dungeonEntry, bossName, bossNames
end

function PC:GetTipsContextForBoss(targetBossName)
    local dungeonOrder, dungeonLookup = BuildDungeonCatalog(true)
    if #dungeonOrder == 0 then
        return dungeonOrder, dungeonLookup, nil, nil, nil, nil
    end

    local resolved = targetBossName and self:ResolveBossName(targetBossName) or nil
    local desiredBossName = resolved or targetBossName

    if desiredBossName then
        for dungeonIndex, dungeonName in ipairs(dungeonOrder) do
            local bossNames = dungeonLookup[dungeonName].bosses
            for bossIndex, bossName in ipairs(bossNames) do
                if bossName == desiredBossName then
                    return dungeonOrder, dungeonLookup, dungeonIndex, dungeonLookup[dungeonName], bossIndex, bossName, bossNames
                end
            end
        end
    end

    local dungeonName = dungeonOrder[1]
    local dungeonEntry = dungeonLookup[dungeonName]
    local bossNames = dungeonEntry and dungeonEntry.bosses or {}
    local bossName = bossNames[1]

    return dungeonOrder, dungeonLookup, 1, dungeonEntry, 1, bossName, bossNames
end

function PC:OpenWindow(preserveMiniButton)
    if not self.window then return end
    if self.tipsWindow then
        self.tipsWindow:SetHidden(true)
    end
    self.window:SetHidden(false)
    if self.miniButton and not preserveMiniButton then
        self.miniButton:SetHidden(true)
    end
    self:Render()
end

function PC:DismissStartupNotice()
    if self.window and self.window.notice then
        self.window.notice:SetHidden(true)
    end
end

function PC:CloseWindow()
    if not self.window then return end
    self.window:SetHidden(true)
    if self.miniButton then
        self.miniButton:SetHidden(false)
    end
end

function PC:OpenTipsLibrary()
    if not self.tipsWindow then return end
    if self.window then
        self.window:SetHidden(true)
    end

    local dungeonOrder, dungeonLookup, dungeonName, dungeonEntry, bossName, bossNames
    if self.currentBossName then
        dungeonOrder, dungeonLookup, self.tipsDungeonIndex, dungeonEntry, self.tipsBossIndex, bossName, bossNames = self:GetTipsContextForBoss(self.currentBossName)
        dungeonName = dungeonOrder and dungeonOrder[self.tipsDungeonIndex] or nil
    else
        dungeonOrder, dungeonLookup, dungeonName, dungeonEntry, bossName, bossNames = self:GetTipsContext()
        if not dungeonName and #dungeonOrder > 0 then
            self.tipsDungeonIndex = 1
            self.tipsBossIndex = 1
            dungeonOrder, dungeonLookup, dungeonName, dungeonEntry, bossName, bossNames = self:GetTipsContext()
        end
    end

    if bossName then
        self:SetTipsBoss(bossName)
    elseif dungeonName then
        self.currentBossName = nil
        self.currentBossData = nil
    end

    self.tipsWindow:SetHidden(false)
    if self.miniButton then
        self.miniButton:SetHidden(true)
    end
    self:RenderTipsLibrary()
end

function PC:CloseTipsLibrary()
    if not self.tipsWindow then return end
    self.tipsWindow:SetHidden(true)
    if self.miniButton then
        self.miniButton:SetHidden(false)
    end
end

function PC:RefreshAuto()
    local detected = self:GetBestDetectedBoss()

    if detected then
        self:SetBoss(detected, "auto")
        self:OpenWindow()
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
        local summary = data.summary or "Watch the encounter flow, protect your team, and execute one clean mechanic cycle."
        self.window.title:SetText((data.dungeon or "Dungeon") .. " — " .. (data.title or bossName))
        self.window.body:SetText("SUMMARY\n" .. summary .. "\n\nEVERYONE\n" .. (data.everyone or "No notes yet."))

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
    self:OpenWindow()
end

function PC:BrowseTips(delta)
    local _, _, _, _, _, bossNames = self:GetTipsContext()
    if not bossNames or #bossNames == 0 then return end

    self.tipsBossIndex = self.tipsBossIndex + delta
    if self.tipsBossIndex < 1 then self.tipsBossIndex = #bossNames end
    if self.tipsBossIndex > #bossNames then self.tipsBossIndex = 1 end

    self:SetTipsBoss(bossNames[self.tipsBossIndex])
    self:OpenTipsLibrary()
end

function PC:BrowseTipsDungeon(delta)
    local dungeonOrder = BuildDungeonCatalog(true)
    if not dungeonOrder or #dungeonOrder == 0 then return end

    self.tipsDungeonIndex = self.tipsDungeonIndex + delta
    if self.tipsDungeonIndex < 1 then self.tipsDungeonIndex = #dungeonOrder end
    if self.tipsDungeonIndex > #dungeonOrder then self.tipsDungeonIndex = 1 end

    self.tipsBossIndex = 1
    local _, _, _, _, bossName = self:GetTipsContext()
    if bossName then
        self:SetTipsBoss(bossName)
    end
    self:OpenTipsLibrary()
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
    if not self.window then return end
    local hidden = self.window:IsHidden()
    if hidden then
        self:OpenWindow()
    else
        self:CloseWindow()
    end
end

function PC:CreateMiniButton()
    local wm = WINDOW_MANAGER

    local button = wm:CreateControlFromVirtual("PullCardMiniButton", GuiRoot, "ZO_DefaultButton")
    self.miniButton = button
    button:SetDimensions(140, 48)
    button:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, -40, -180)
    button:SetText("PullCard")
    button:SetHidden(false)
    button:SetDrawTier(DT_HIGH)
    button:SetDrawLayer(DL_OVERLAY)

    local bg = wm:CreateControl(nil, button, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.8, 0.1, 0.1, 0.9)
    bg:SetEdgeColor(1, 1, 1, 1)
    bg:SetEdgeTexture("", 1, 1, 1)
    bg:SetDrawLevel(-1)
    button:SetHandler("OnClicked", function()
        PC:OpenWindow()
    end)
end

function PC:CreateWindow()
    local wm = WINDOW_MANAGER

    local top = wm:CreateTopLevelWindow("PullCardWindow")
    self.window = top
    top:SetDimensions(600, 470)
    top:SetAnchor(CENTER, GuiRoot, CENTER, 0, 80)
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
    title:SetFont("ZoFontGamepadBold36")
    title:SetAnchor(TOPLEFT, top, TOPLEFT, 18, 16)
    title:SetAnchor(TOPRIGHT, top, TOPRIGHT, -18, 16)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    title:SetText("PullCard")

    local notice = wm:CreateControl(nil, top, CT_LABEL)
    top.notice = notice
    notice:SetFont("ZoFontGamepad24")
    notice:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 10)
    notice:SetAnchor(TOPRIGHT, title, BOTTOMRIGHT, -120, 10)
    notice:SetHeight(34)
    notice:SetVerticalAlignment(TEXT_ALIGN_TOP)
    notice:SetText("PullCard loaded. Use the controls below to browse.")

    local body = wm:CreateControl(nil, top, CT_LABEL)
    top.body = body
    body:SetFont("ZoFontGamepad24")
    body:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 28)
    body:SetAnchor(TOPRIGHT, title, BOTTOMRIGHT, 0, 28)
    body:SetHeight(170)
    body:SetVerticalAlignment(TEXT_ALIGN_TOP)

    local role = wm:CreateControl(nil, top, CT_LABEL)
    top.role = role
    role:SetFont("ZoFontGamepad22")
    role:SetAnchor(TOPLEFT, body, BOTTOMLEFT, 0, 10)
    role:SetAnchor(TOPRIGHT, body, BOTTOMRIGHT, 0, 10)
    role:SetHeight(96)
    role:SetVerticalAlignment(TEXT_ALIGN_TOP)

    local debug = wm:CreateControl(nil, top, CT_LABEL)
    top.debug = debug
    debug:SetFont("ZoFontGamepad18")
    debug:SetAnchor(TOPLEFT, role, BOTTOMLEFT, 0, 8)
    debug:SetAnchor(TOPRIGHT, role, BOTTOMRIGHT, 0, 8)
    debug:SetHeight(60)
    debug:SetVerticalAlignment(TEXT_ALIGN_TOP)

    local prev = wm:CreateControlFromVirtual("PullCardPrevButton", top, "ZO_DefaultButton")
    prev:SetDimensions(96, 36)
    prev:SetAnchor(BOTTOMLEFT, top, BOTTOMLEFT, 18, -16)
    prev:SetText("< Prev")
    prev:SetHandler("OnClicked", function() PC:Browse(-1) end)

    local next = wm:CreateControlFromVirtual("PullCardNextButton", top, "ZO_DefaultButton")
    next:SetDimensions(96, 36)
    next:SetAnchor(LEFT, prev, RIGHT, 10, 0)
    next:SetText("Next >")
    next:SetHandler("OnClicked", function() PC:Browse(1) end)

    local chatButton = wm:CreateControlFromVirtual("PullCardChatButton", top, "ZO_DefaultButton")
    top.chatButton = chatButton
    chatButton:SetDimensions(185, 36)
    chatButton:SetAnchor(LEFT, next, RIGHT, 10, 0)
    chatButton:SetText("Explain to Group")
    chatButton:SetHandler("OnClicked", function() PC:PrefillGroupChat() end)

    local hide = wm:CreateControlFromVirtual("PullCardHideButton", top, "ZO_DefaultButton")
    hide:SetDimensions(90, 36)
    hide:SetAnchor(BOTTOMRIGHT, top, BOTTOMRIGHT, -18, -16)
    hide:SetText("Hide")
    hide:SetHandler("OnClicked", function()
        PC:CloseWindow()
    end)

    local tips = wm:CreateControlFromVirtual("PullCardTipsButton", top, "ZO_DefaultButton")
    tips:SetDimensions(90, 36)
    tips:SetAnchor(RIGHT, hide, LEFT, -10, 0)
    tips:SetText("Tips")
    tips:SetHandler("OnClicked", function()
        PC:OpenTipsLibrary()
    end)
end

function PC:RenderTipsLibrary()
    if not self.tipsWindow then return end

    local dungeonOrder, dungeonLookup, dungeonName, dungeonEntry, bossName, bossNames = self:GetTipsContext()
    local data = self.currentBossData

    if not dungeonName then
        self.tipsWindow.title:SetText("PullCard Tips Library")
        self.tipsWindow.dungeon:SetText("Vanilla dungeons only")
        self.tipsWindow.body:SetText("Browse the full dungeon list with Previous Dungeon / Next Dungeon, then move between bosses inside each dungeon.")
        self.tipsWindow.role:SetText("")
        self.tipsWindow.chatButton:SetEnabled(false)
    elseif data then
        local summary = data.summary or "Watch the encounter flow, protect your team, and execute one clean mechanic cycle."
        self.tipsWindow.title:SetText((dungeonName or data.dungeon or "Dungeon") .. " — " .. (data.title or bossName))
        self.tipsWindow.dungeon:SetText("BOSSES: " .. table.concat(bossNames or {}, ", "))
        self.tipsWindow.body:SetText("SUMMARY\n" .. summary .. "\n\nEVERYONE\n" .. (data.everyone or "No notes yet."))

        local roleText = self:GetPlayerRoleText(data)
        if roleText ~= "" then
            self.tipsWindow.role:SetText("YOUR ROLE\n" .. roleText)
        else
            self.tipsWindow.role:SetText("")
        end

        self.tipsWindow.chatButton:SetEnabled(data.tldr ~= nil and data.tldr ~= "")
    else
        self.tipsWindow.title:SetText(bossName)
        self.tipsWindow.dungeon:SetText(dungeonName or "Unknown Dungeon")
        self.tipsWindow.body:SetText("Boss detected, but no PullCard exists yet.")
        self.tipsWindow.role:SetText("")
        self.tipsWindow.chatButton:SetEnabled(false)
    end

    self.tipsWindow.debug:SetHidden(true)
end

function PC:CreateTipsWindow()
    local wm = WINDOW_MANAGER

    local top = wm:CreateTopLevelWindow("PullCardTipsWindow")
    self.tipsWindow = top
    top:SetDimensions(620, 530)
    top:SetAnchor(CENTER, GuiRoot, CENTER, 0, 80)
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
    title:SetFont("ZoFontGamepadBold36")
    title:SetAnchor(TOPLEFT, top, TOPLEFT, 18, 16)
    title:SetAnchor(TOPRIGHT, top, TOPRIGHT, -18, 16)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    title:SetText("PullCard Tips Library")

    local dungeon = wm:CreateControl(nil, top, CT_LABEL)
    top.dungeon = dungeon
    dungeon:SetFont("ZoFontGamepad20")
    dungeon:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 12)
    dungeon:SetAnchor(TOPRIGHT, title, BOTTOMRIGHT, 0, 12)
    dungeon:SetHeight(56)
    dungeon:SetVerticalAlignment(TEXT_ALIGN_TOP)
    dungeon:SetText("Vanilla dungeons only")

    local body = wm:CreateControl(nil, top, CT_LABEL)
    top.body = body
    body:SetFont("ZoFontGamepad24")
    body:SetAnchor(TOPLEFT, dungeon, BOTTOMLEFT, 0, 20)
    body:SetAnchor(TOPRIGHT, dungeon, BOTTOMRIGHT, 0, 20)
    body:SetHeight(180)
    body:SetVerticalAlignment(TEXT_ALIGN_TOP)

    local role = wm:CreateControl(nil, top, CT_LABEL)
    top.role = role
    role:SetFont("ZoFontGamepad22")
    role:SetAnchor(TOPLEFT, body, BOTTOMLEFT, 0, 10)
    role:SetAnchor(TOPRIGHT, body, BOTTOMRIGHT, 0, 10)
    role:SetHeight(108)
    role:SetVerticalAlignment(TEXT_ALIGN_TOP)

    local debug = wm:CreateControl(nil, top, CT_LABEL)
    top.debug = debug
    debug:SetFont("ZoFontGamepad18")
    debug:SetAnchor(TOPLEFT, role, BOTTOMLEFT, 0, 8)
    debug:SetAnchor(TOPRIGHT, role, BOTTOMRIGHT, 0, 8)
    debug:SetHeight(60)
    debug:SetVerticalAlignment(TEXT_ALIGN_TOP)

    local prevDungeon = wm:CreateControlFromVirtual("PullCardTipsPrevDungeonButton", top, "ZO_DefaultButton")
    prevDungeon:SetDimensions(120, 36)
    prevDungeon:SetAnchor(BOTTOMLEFT, top, BOTTOMLEFT, 18, -16)
    prevDungeon:SetText("< Dungeon")
    prevDungeon:SetHandler("OnClicked", function() PC:BrowseTipsDungeon(-1) end)

    local nextDungeon = wm:CreateControlFromVirtual("PullCardTipsNextDungeonButton", top, "ZO_DefaultButton")
    nextDungeon:SetDimensions(120, 36)
    nextDungeon:SetAnchor(LEFT, prevDungeon, RIGHT, 10, 0)
    nextDungeon:SetText("Dungeon >")
    nextDungeon:SetHandler("OnClicked", function() PC:BrowseTipsDungeon(1) end)

    local prev = wm:CreateControlFromVirtual("PullCardTipsPrevButton", top, "ZO_DefaultButton")
    prev:SetDimensions(96, 36)
    prev:SetAnchor(TOPLEFT, prevDungeon, TOPRIGHT, 18, 0)
    prev:SetText("< Prev")
    prev:SetHandler("OnClicked", function() PC:BrowseTips(-1) end)

    local next = wm:CreateControlFromVirtual("PullCardTipsNextButton", top, "ZO_DefaultButton")
    next:SetDimensions(96, 36)
    next:SetAnchor(LEFT, prev, RIGHT, 10, 0)
    next:SetText("Next >")
    next:SetHandler("OnClicked", function() PC:BrowseTips(1) end)

    local explain = wm:CreateControlFromVirtual("PullCardTipsExplainButton", top, "ZO_DefaultButton")
    explain:SetDimensions(150, 36)
    explain:SetAnchor(BOTTOMRIGHT, top, BOTTOMRIGHT, -18, -16)
    explain:SetText("Explain to Group")
    explain:SetHandler("OnClicked", function() PC:PrefillGroupChat() end)

    local live = wm:CreateControlFromVirtual("PullCardLiveButton", top, "ZO_DefaultButton")
    live:SetDimensions(120, 36)
    live:SetAnchor(LEFT, explain, LEFT, -266, 0)
    live:SetText("Live View")
    live:SetHandler("OnClicked", function()
        PC:CloseTipsLibrary()
        PC:OpenWindow(true)
    end)

    local hide = wm:CreateControlFromVirtual("PullCardTipsHideButton", top, "ZO_DefaultButton")
    hide:SetDimensions(90, 36)
    hide:SetAnchor(LEFT, explain, RIGHT, 10, 0)
    hide:SetText("Hide")
    hide:SetHandler("OnClicked", function()
        PC:CloseTipsLibrary()
    end)

    top.chatButton = explain
end

function PC:Initialize()
    self:CreateWindow()
    self:CreateTipsWindow()
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

    self:OpenWindow(true)
    zo_callLater(function()
        PC:DismissStartupNotice()
    end, 3500)
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= PC.name then return end

    EVENT_MANAGER:UnregisterForEvent(PC.name, EVENT_ADD_ON_LOADED)
    PC:Initialize()
end

EVENT_MANAGER:RegisterForEvent(PC.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
