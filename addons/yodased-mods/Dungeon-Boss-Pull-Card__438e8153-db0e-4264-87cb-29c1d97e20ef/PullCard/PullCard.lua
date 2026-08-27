PullCard = PullCard or {}
local PC = PullCard

PC.name = "PullCard"
PC.version = "0.3.0"
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
PC.settingsPanelRegistered = false
PC.savedVars = nil
PC.defaults = {
    debugMode = false,
    openOnStartup = true,
    showMiniButton = true,
}

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

local function IsDismissKey(key)
    return key == KEY_ESCAPE
        or key == KEY_GAMEPAD_BUTTON_1
        or key == KEY_GAMEPAD_BACK
        or key == KEY_GAMEPAD_START
end

local function IsFocusNextKey(key)
    return key == KEY_RIGHT
        or key == KEY_D
        or key == KEY_GAMEPAD_DPAD_RIGHT
        or key == KEY_GAMEPAD_RIGHT_SHOULDER
end

local function IsFocusPrevKey(key)
    return key == KEY_LEFT
        or key == KEY_A
        or key == KEY_GAMEPAD_DPAD_LEFT
        or key == KEY_GAMEPAD_LEFT_SHOULDER
end

local function IsActivateKey(key)
    return key == KEY_ENTER
        or key == KEY_SPACE
        or key == KEY_GAMEPAD_BUTTON_2
        or key == KEY_GAMEPAD_BUTTON_3
end

local function SetReadableFont(control, size, isBold)
    if not control then return end
    local base = isBold and "$(BOLD_FONT)" or "$(MEDIUM_FONT)"
    control:SetFont(string.format("%s|%d|soft-shadow-thick", base, size))
end

local function SetButtonReadableFont(button, size, isBold)
    if not button then return end
    local text = button:GetNamedChild("Text")
    if text then
        SetReadableFont(text, size, isBold)
    end
end

local function IsActionEnabled(action)
    if not action or not action.control then return false end
    if action.control.IsEnabled then
        return action.control:IsEnabled()
    end
    return true
end

local function GetLAM2()
    if LibAddonMenu2 then
        return LibAddonMenu2
    end

    if LibStub and LibStub.GetLibrary then
        local lam = LibStub:GetLibrary("LibAddonMenu-2.0", true)
        if lam then
            return lam
        end
    end

    return nil
end

local function SetWindowActionFocus(window, index)
    if not window or not window.actionButtons then return end
    local actions = window.actionButtons
    if #actions == 0 then return end

    if index < 1 then index = #actions end
    if index > #actions then index = 1 end

    local startIndex = index
    while #actions > 0 and not IsActionEnabled(actions[index]) do
        index = index + 1
        if index > #actions then index = 1 end
        if index == startIndex then break end
    end

    window.focusedActionIndex = index

    for i, action in ipairs(actions) do
        if action and action.control and action.label then
            if i == index then
                action.control:SetText("[ " .. action.label .. " ]")
            else
                action.control:SetText(action.label)
            end
        end
    end
end

local function StepWindowActionFocus(window, delta)
    if not window or not window.actionButtons then return end
    local current = window.focusedActionIndex or 1
    local actions = window.actionButtons
    if #actions == 0 then return end

    local nextIndex = current
    for _ = 1, #actions do
        nextIndex = nextIndex + delta
        if nextIndex < 1 then nextIndex = #actions end
        if nextIndex > #actions then nextIndex = 1 end
        if IsActionEnabled(actions[nextIndex]) then
            SetWindowActionFocus(window, nextIndex)
            return
        end
    end

    SetWindowActionFocus(window, current)
end

local function ActivateFocusedWindowAction(window)
    if not window or not window.actionButtons then return false end
    local index = window.focusedActionIndex or 1
    local action = window.actionButtons[index]
    if action and IsActionEnabled(action) and action.callback then
        action.callback()
        return true
    end
    return false
end

local function GetPreferredDungeonName()
    local zoneName = Trim(GetUnitZone("player"))
    if zoneName ~= "" then
        return zoneName
    end
    return nil
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

function PC:ResolveBossName(candidate, preferredDungeon)
    if not candidate then return nil end
    local key = NormalizeBossName(candidate)
    if key == "" then return nil end

    local matches = {}

    if PullCardData and PullCardData.bosses then
        for bossName, data in pairs(PullCardData.bosses) do
            if NormalizeBossName(bossName) == key then
                table.insert(matches, bossName)
            end

            if data and data.aliases then
                for _, alias in ipairs(data.aliases) do
                    if NormalizeBossName(alias) == key then
                        table.insert(matches, bossName)
                        break
                    end
                end
            end
        end
    end

    if #matches == 0 then
        return nil
    end
    if #matches == 1 then
        return matches[1]
    end

    local preferred = preferredDungeon and NormalizeBossName(preferredDungeon) or ""
    if preferred ~= "" then
        for _, bossName in ipairs(matches) do
            local data = PullCardData and PullCardData.bosses and PullCardData.bosses[bossName] or nil
            if data and NormalizeBossName(data.dungeon) == preferred then
                return bossName
            end
        end
    end

    if self.currentBossData and self.currentBossData.dungeon then
        local currentDungeon = NormalizeBossName(self.currentBossData.dungeon)
        for _, bossName in ipairs(matches) do
            local data = PullCardData and PullCardData.bosses and PullCardData.bosses[bossName] or nil
            if data and NormalizeBossName(data.dungeon) == currentDungeon then
                return bossName
            end
        end
    end

    table.sort(matches)
    return matches[1]
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
    local preferredDungeon = GetPreferredDungeonName()

    for _, name in ipairs(found) do
        local resolved = self:ResolveBossName(name, preferredDungeon)
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
    if self.savedVars then
        self.savedVars.debugMode = self.debugMode
    end
    self:Render()
    self:RenderTipsLibrary()
end

function PC:LoadSettings()
    self.savedVars = ZO_SavedVars:NewAccountWide("PullCardSavedVariables", 1, nil, self.defaults)
    self.debugMode = self.savedVars.debugMode and true or false
end

function PC:ShouldShowMiniButton()
    return self.savedVars and self.savedVars.showMiniButton == true
end

function PC:RegisterSettingsPanel()
    if self.settingsPanelRegistered then return true end

    local LAM2 = GetLAM2()
    if not LAM2 then return false end

    local panelId = "PullCardSettingsPanel"
    local panelData = {
        type = "panel",
        name = "PullCard",
        displayName = "PullCard",
        author = "yodased-mods",
        version = tostring(self.version),
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "description",
            text = "Controller-first dungeon boss guidance.",
            width = "full",
        },
        {
            type = "button",
            name = "Open Live View",
            width = "full",
            func = function() PC:OpenWindow(true) end,
        },
        {
            type = "button",
            name = "Open Tips Library",
            width = "full",
            func = function() PC:OpenTipsLibrary() end,
        },
        {
            type = "checkbox",
            name = "Enable Debug Text",
            width = "full",
            default = false,
            getFunc = function() return PC.debugMode end,
            setFunc = function(value)
                PC.debugMode = value
                if PC.savedVars then
                    PC.savedVars.debugMode = value
                end
                PC:Render()
                PC:RenderTipsLibrary()
            end,
        },
        {
            type = "checkbox",
            name = "Open Live View On Login",
            width = "full",
            default = true,
            getFunc = function() return PC.savedVars and PC.savedVars.openOnStartup == true end,
            setFunc = function(value)
                if PC.savedVars then
                    PC.savedVars.openOnStartup = value and true or false
                end
            end,
        },
        {
            type = "checkbox",
            name = "Show PullCard Mini Button",
            width = "full",
            default = true,
            getFunc = function() return PC.savedVars and PC.savedVars.showMiniButton == true end,
            setFunc = function(value)
                if PC.savedVars then
                    PC.savedVars.showMiniButton = value and true or false
                end
                if PC.miniButton then
                    local shouldShow = PC:ShouldShowMiniButton() and (not PC.window or PC.window:IsHidden()) and (not PC.tipsWindow or PC.tipsWindow:IsHidden())
                    PC.miniButton:SetHidden(not shouldShow)
                end
            end,
        },
    }

    LAM2:RegisterAddonPanel(panelId, panelData)
    LAM2:RegisterOptionControls(panelId, optionsData)
    self.settingsPanelRegistered = true
    return true
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
    SetWindowActionFocus(self.window, self.window.focusedActionIndex or 1)
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
        self.miniButton:SetHidden(not self:ShouldShowMiniButton())
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
    SetWindowActionFocus(self.tipsWindow, self.tipsWindow.focusedActionIndex or 1)
    self:RenderTipsLibrary()
end

function PC:CloseTipsLibrary()
    if not self.tipsWindow then return end
    self.tipsWindow:SetHidden(true)
    if self.miniButton then
        self.miniButton:SetHidden(not self:ShouldShowMiniButton())
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

    SetWindowActionFocus(self.window, self.window.focusedActionIndex or 1)
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
    else
        d("PullCard: Chat prefill is not available in this UI mode.")
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

function PC:RegisterSlashCommands()
    SLASH_COMMANDS["/pullcard"] = function(arg)
        local cleanArg = Trim(arg or "")
        local lowerArg = cleanArg:lower()
        local cmd = NormalizeBossName(cleanArg)
        if cmd == "" or cmd == "show" then
            PC:OpenWindow(true)
        elseif cmd == "live" then
            PC:OpenWindow(true)
        elseif cmd == "tips" then
            PC:OpenTipsLibrary()
        elseif cmd == "refresh" then
            PC:RefreshAuto()
            PC:OpenWindow(true)
        elseif cmd == "hide" then
            if PC.tipsWindow and not PC.tipsWindow:IsHidden() then
                PC:CloseTipsLibrary()
            end
            PC:CloseWindow()
        elseif cmd == "debug" then
            PC:ToggleDebug()
            d(string.format("PullCard debug: %s", PC.debugMode and "ON" or "OFF"))
        elseif lowerArg:find("^boss%s+") == 1 then
            local bossQuery = Trim(cleanArg:sub(6))
            if bossQuery == "" then
                d("PullCard: usage /pullcard boss <name>")
                return
            end
            local resolved = PC:ResolveBossName(bossQuery, GetPreferredDungeonName())
            if resolved then
                PC:SetBoss(resolved, "manual")
                PC:OpenWindow(true)
            else
                d("PullCard: boss not found in dataset.")
            end
        elseif cmd == "help" then
            d("PullCard commands: /pullcard show | live | tips | refresh | hide | debug | boss <name>")
        else
            d("PullCard commands: /pullcard show | live | tips | refresh | hide | debug | boss <name>")
        end
    end
end

function PC:CreateMiniButton()
    local wm = WINDOW_MANAGER

    local button = wm:CreateControlFromVirtual("PullCardMiniButton", GuiRoot, "ZO_DefaultButton")
    self.miniButton = button
    button:SetDimensions(140, 48)
    button:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, -40, -180)
    button:SetText("PullCard")
    SetButtonReadableFont(button, 22, true)
    button:SetHidden(not self:ShouldShowMiniButton())
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
    top:SetKeyboardEnabled(true)
    top:SetClampedToScreen(true)
    top:SetHidden(true)
    top:SetHandler("OnKeyDown", function(_, key)
        if IsDismissKey(key) then
            PC:CloseWindow()
            return true
        end
        if IsFocusPrevKey(key) then
            StepWindowActionFocus(top, -1)
            return true
        end
        if IsFocusNextKey(key) then
            StepWindowActionFocus(top, 1)
            return true
        end
        if IsActivateKey(key) then
            return ActivateFocusedWindowAction(top)
        end
    end)

    local bg = wm:CreateControl(nil, top, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.05, 0.05, 0.05, 0.94)
    bg:SetEdgeColor(0.5, 0.5, 0.5, 0.9)
    bg:SetEdgeTexture("", 1, 1, 1)

    local title = wm:CreateControl(nil, top, CT_LABEL)
    top.title = title
    SetReadableFont(title, 36, true)
    title:SetAnchor(TOPLEFT, top, TOPLEFT, 18, 16)
    title:SetAnchor(TOPRIGHT, top, TOPRIGHT, -18, 16)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    title:SetText("PullCard")

    local notice = wm:CreateControl(nil, top, CT_LABEL)
    top.notice = notice
    SetReadableFont(notice, 24, false)
    notice:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 10)
    notice:SetAnchor(TOPRIGHT, title, BOTTOMRIGHT, -120, 10)
    notice:SetHeight(34)
    notice:SetVerticalAlignment(TEXT_ALIGN_TOP)
    notice:SetText("PullCard loaded. Use the controls below to browse.")

    local body = wm:CreateControl(nil, top, CT_LABEL)
    top.body = body
    SetReadableFont(body, 22, false)
    body:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 28)
    body:SetAnchor(TOPRIGHT, title, BOTTOMRIGHT, 0, 28)
    body:SetHeight(170)
    body:SetVerticalAlignment(TEXT_ALIGN_TOP)

    local role = wm:CreateControl(nil, top, CT_LABEL)
    top.role = role
    SetReadableFont(role, 21, false)
    role:SetAnchor(TOPLEFT, body, BOTTOMLEFT, 0, 10)
    role:SetAnchor(TOPRIGHT, body, BOTTOMRIGHT, 0, 10)
    role:SetHeight(96)
    role:SetVerticalAlignment(TEXT_ALIGN_TOP)

    local debug = wm:CreateControl(nil, top, CT_LABEL)
    top.debug = debug
    SetReadableFont(debug, 18, false)
    debug:SetAnchor(TOPLEFT, role, BOTTOMLEFT, 0, 8)
    debug:SetAnchor(TOPRIGHT, role, BOTTOMRIGHT, 0, 8)
    debug:SetHeight(60)
    debug:SetVerticalAlignment(TEXT_ALIGN_TOP)

    local controlsHint = wm:CreateControl(nil, top, CT_LABEL)
    SetReadableFont(controlsHint, 18, false)
    controlsHint:SetAnchor(BOTTOMLEFT, top, BOTTOMLEFT, 18, -56)
    controlsHint:SetAnchor(BOTTOMRIGHT, top, BOTTOMRIGHT, -18, -56)
    controlsHint:SetHeight(28)
    controlsHint:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    controlsHint:SetColor(0.84, 0.84, 0.84, 1)
    controlsHint:SetText("Left/Right: focus   Activate: run action   Back: close")

    local prev = wm:CreateControlFromVirtual("PullCardPrevButton", top, "ZO_DefaultButton")
    prev:SetDimensions(96, 36)
    prev:SetAnchor(BOTTOMLEFT, top, BOTTOMLEFT, 18, -16)
    local prevAction = function() PC:Browse(-1) end
    prev:SetText("< Prev")
    SetButtonReadableFont(prev, 20, true)
    prev:SetHandler("OnClicked", prevAction)

    local next = wm:CreateControlFromVirtual("PullCardNextButton", top, "ZO_DefaultButton")
    next:SetDimensions(96, 36)
    next:SetAnchor(LEFT, prev, RIGHT, 10, 0)
    local nextAction = function() PC:Browse(1) end
    next:SetText("Next >")
    SetButtonReadableFont(next, 20, true)
    next:SetHandler("OnClicked", nextAction)

    local chatButton = wm:CreateControlFromVirtual("PullCardChatButton", top, "ZO_DefaultButton")
    top.chatButton = chatButton
    chatButton:SetDimensions(185, 36)
    chatButton:SetAnchor(LEFT, next, RIGHT, 10, 0)
    local chatAction = function() PC:PrefillGroupChat() end
    chatButton:SetText("Explain to Group")
    SetButtonReadableFont(chatButton, 20, true)
    chatButton:SetHandler("OnClicked", chatAction)

    local hide = wm:CreateControlFromVirtual("PullCardHideButton", top, "ZO_DefaultButton")
    hide:SetDimensions(90, 36)
    hide:SetAnchor(BOTTOMRIGHT, top, BOTTOMRIGHT, -18, -16)
    local hideAction = function() PC:CloseWindow() end
    hide:SetText("Hide")
    SetButtonReadableFont(hide, 20, true)
    hide:SetHandler("OnClicked", hideAction)

    local tips = wm:CreateControlFromVirtual("PullCardTipsButton", top, "ZO_DefaultButton")
    tips:SetDimensions(90, 36)
    tips:SetAnchor(RIGHT, hide, LEFT, -10, 0)
    local tipsAction = function() PC:OpenTipsLibrary() end
    tips:SetText("Tips")
    SetButtonReadableFont(tips, 20, true)
    tips:SetHandler("OnClicked", tipsAction)

    top.actionButtons = {
        { control = prev, label = "< Prev", callback = prevAction },
        { control = next, label = "Next >", callback = nextAction },
        { control = chatButton, label = "Explain to Group", callback = chatAction },
        { control = tips, label = "Tips", callback = tipsAction },
        { control = hide, label = "Hide", callback = hideAction },
    }
    top.focusedActionIndex = 1
    SetWindowActionFocus(top, 1)
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
    SetWindowActionFocus(self.tipsWindow, self.tipsWindow.focusedActionIndex or 1)
end

function PC:CreateTipsWindow()
    local wm = WINDOW_MANAGER

    local top = wm:CreateTopLevelWindow("PullCardTipsWindow")
    self.tipsWindow = top
    top:SetDimensions(620, 530)
    top:SetAnchor(CENTER, GuiRoot, CENTER, 0, 80)
    top:SetMovable(true)
    top:SetMouseEnabled(true)
    top:SetKeyboardEnabled(true)
    top:SetClampedToScreen(true)
    top:SetHidden(true)
    top:SetHandler("OnKeyDown", function(_, key)
        if IsDismissKey(key) then
            PC:CloseTipsLibrary()
            return true
        end
        if IsFocusPrevKey(key) then
            StepWindowActionFocus(top, -1)
            return true
        end
        if IsFocusNextKey(key) then
            StepWindowActionFocus(top, 1)
            return true
        end
        if IsActivateKey(key) then
            return ActivateFocusedWindowAction(top)
        end
    end)

    local bg = wm:CreateControl(nil, top, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.05, 0.05, 0.05, 0.94)
    bg:SetEdgeColor(0.5, 0.5, 0.5, 0.9)
    bg:SetEdgeTexture("", 1, 1, 1)

    local title = wm:CreateControl(nil, top, CT_LABEL)
    top.title = title
    SetReadableFont(title, 34, true)
    title:SetAnchor(TOPLEFT, top, TOPLEFT, 18, 16)
    title:SetAnchor(TOPRIGHT, top, TOPRIGHT, -18, 16)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    title:SetText("PullCard Tips Library")

    local dungeon = wm:CreateControl(nil, top, CT_LABEL)
    top.dungeon = dungeon
    SetReadableFont(dungeon, 20, false)
    dungeon:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 12)
    dungeon:SetAnchor(TOPRIGHT, title, BOTTOMRIGHT, 0, 12)
    dungeon:SetHeight(56)
    dungeon:SetVerticalAlignment(TEXT_ALIGN_TOP)
    dungeon:SetText("Vanilla dungeons only")

    local body = wm:CreateControl(nil, top, CT_LABEL)
    top.body = body
    SetReadableFont(body, 21, false)
    body:SetAnchor(TOPLEFT, dungeon, BOTTOMLEFT, 0, 20)
    body:SetAnchor(TOPRIGHT, dungeon, BOTTOMRIGHT, 0, 20)
    body:SetHeight(180)
    body:SetVerticalAlignment(TEXT_ALIGN_TOP)

    local role = wm:CreateControl(nil, top, CT_LABEL)
    top.role = role
    SetReadableFont(role, 20, false)
    role:SetAnchor(TOPLEFT, body, BOTTOMLEFT, 0, 10)
    role:SetAnchor(TOPRIGHT, body, BOTTOMRIGHT, 0, 10)
    role:SetHeight(108)
    role:SetVerticalAlignment(TEXT_ALIGN_TOP)

    local debug = wm:CreateControl(nil, top, CT_LABEL)
    top.debug = debug
    SetReadableFont(debug, 18, false)
    debug:SetAnchor(TOPLEFT, role, BOTTOMLEFT, 0, 8)
    debug:SetAnchor(TOPRIGHT, role, BOTTOMRIGHT, 0, 8)
    debug:SetHeight(60)
    debug:SetVerticalAlignment(TEXT_ALIGN_TOP)

    local controlsHint = wm:CreateControl(nil, top, CT_LABEL)
    SetReadableFont(controlsHint, 18, false)
    controlsHint:SetAnchor(BOTTOMLEFT, top, BOTTOMLEFT, 18, -56)
    controlsHint:SetAnchor(BOTTOMRIGHT, top, BOTTOMRIGHT, -18, -56)
    controlsHint:SetHeight(28)
    controlsHint:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    controlsHint:SetColor(0.84, 0.84, 0.84, 1)
    controlsHint:SetText("Left/Right: focus   Activate: run action   Back: close")

    local prevDungeon = wm:CreateControlFromVirtual("PullCardTipsPrevDungeonButton", top, "ZO_DefaultButton")
    prevDungeon:SetDimensions(120, 36)
    prevDungeon:SetAnchor(BOTTOMLEFT, top, BOTTOMLEFT, 18, -16)
    local prevDungeonAction = function() PC:BrowseTipsDungeon(-1) end
    prevDungeon:SetText("< Dungeon")
    SetButtonReadableFont(prevDungeon, 20, true)
    prevDungeon:SetHandler("OnClicked", prevDungeonAction)

    local nextDungeon = wm:CreateControlFromVirtual("PullCardTipsNextDungeonButton", top, "ZO_DefaultButton")
    nextDungeon:SetDimensions(120, 36)
    nextDungeon:SetAnchor(LEFT, prevDungeon, RIGHT, 10, 0)
    local nextDungeonAction = function() PC:BrowseTipsDungeon(1) end
    nextDungeon:SetText("Dungeon >")
    SetButtonReadableFont(nextDungeon, 20, true)
    nextDungeon:SetHandler("OnClicked", nextDungeonAction)

    local prev = wm:CreateControlFromVirtual("PullCardTipsPrevButton", top, "ZO_DefaultButton")
    prev:SetDimensions(96, 36)
    prev:SetAnchor(TOPLEFT, prevDungeon, TOPRIGHT, 18, 0)
    local prevAction = function() PC:BrowseTips(-1) end
    prev:SetText("< Prev")
    SetButtonReadableFont(prev, 20, true)
    prev:SetHandler("OnClicked", prevAction)

    local next = wm:CreateControlFromVirtual("PullCardTipsNextButton", top, "ZO_DefaultButton")
    next:SetDimensions(96, 36)
    next:SetAnchor(LEFT, prev, RIGHT, 10, 0)
    local nextAction = function() PC:BrowseTips(1) end
    next:SetText("Next >")
    SetButtonReadableFont(next, 20, true)
    next:SetHandler("OnClicked", nextAction)

    local explain = wm:CreateControlFromVirtual("PullCardTipsExplainButton", top, "ZO_DefaultButton")
    explain:SetDimensions(150, 36)
    explain:SetAnchor(BOTTOMRIGHT, top, BOTTOMRIGHT, -18, -16)
    local explainAction = function() PC:PrefillGroupChat() end
    explain:SetText("Explain to Group")
    SetButtonReadableFont(explain, 20, true)
    explain:SetHandler("OnClicked", explainAction)

    local live = wm:CreateControlFromVirtual("PullCardLiveButton", top, "ZO_DefaultButton")
    live:SetDimensions(120, 36)
    live:SetAnchor(LEFT, explain, LEFT, -266, 0)
    local liveAction = function()
        PC:CloseTipsLibrary()
        PC:OpenWindow(true)
    end
    live:SetText("Live View")
    SetButtonReadableFont(live, 20, true)
    live:SetHandler("OnClicked", liveAction)

    local hide = wm:CreateControlFromVirtual("PullCardTipsHideButton", top, "ZO_DefaultButton")
    hide:SetDimensions(90, 36)
    hide:SetAnchor(LEFT, explain, RIGHT, 10, 0)
    local hideAction = function() PC:CloseTipsLibrary() end
    hide:SetText("Hide")
    SetButtonReadableFont(hide, 20, true)
    hide:SetHandler("OnClicked", hideAction)

    top.chatButton = explain
    top.actionButtons = {
        { control = prevDungeon, label = "< Dungeon", callback = prevDungeonAction },
        { control = nextDungeon, label = "Dungeon >", callback = nextDungeonAction },
        { control = prev, label = "< Prev", callback = prevAction },
        { control = next, label = "Next >", callback = nextAction },
        { control = live, label = "Live View", callback = liveAction },
        { control = explain, label = "Explain to Group", callback = explainAction },
        { control = hide, label = "Hide", callback = hideAction },
    }
    top.focusedActionIndex = 1
    SetWindowActionFocus(top, 1)
end

function PC:Initialize()
    self:LoadSettings()
    self:CreateWindow()
    self:CreateTipsWindow()
    self:CreateMiniButton()
    self:RegisterSlashCommands()
    self:RegisterSettingsPanel()
    zo_callLater(function()
        if not PC.settingsPanelRegistered then PC:RegisterSettingsPanel() end
    end, 500)
    zo_callLater(function()
        if not PC.settingsPanelRegistered then PC:RegisterSettingsPanel() end
    end, 2000)
    zo_callLater(function()
        if not PC.settingsPanelRegistered then PC:RegisterSettingsPanel() end
    end, 5000)
    zo_callLater(function()
        if not PC.settingsPanelRegistered then
            d("PullCard: LibAddonMenu-2.0 not found. Use /pullcard for built-in controls.")
        end
    end, 5500)

    EVENT_MANAGER:RegisterForEvent(self.name .. "_LAM", EVENT_ADD_ON_LOADED, function(_, addonName)
        if addonName == "LibAddonMenu-2.0" or addonName == "LibAddonMenu" then
            if PC:RegisterSettingsPanel() then
                EVENT_MANAGER:UnregisterForEvent(PC.name .. "_LAM", EVENT_ADD_ON_LOADED)
            end
        end
    end)

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

    if self.savedVars and self.savedVars.openOnStartup then
        self:OpenWindow(true)
    else
        self:CloseWindow()
    end
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
