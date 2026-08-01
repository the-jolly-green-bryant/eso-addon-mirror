SimpleAchievementTracker = {}
SimpleAchievementTracker.name = "SimpleAchievementTracker"

if type(SAT_AchievementData) ~= "table" then
    SAT_AchievementData = { Achievements = {}, Dungeons = {}, Arenas = {} }
end

SimpleAchievementTracker.Achievements = SAT_AchievementData.Achievements or {}
SimpleAchievementTracker.Dungeons = SAT_AchievementData.Dungeons or {}
SimpleAchievementTracker.Arenas = SAT_AchievementData.Arenas or {}
SimpleAchievementTracker.tabContainers = {}

SimpleAchievementTracker.defaults = {
    window = {
        left = 100,
        top = 100,
        width = 1000,
        height = 650
    },
    hidden = true
}

function SimpleAchievementTracker.GetAchievementInfo(achievementId)
    if not achievementId then
        return nil, nil, 0, nil, false
    end

    local success, name, description, points, icon, completed, earnedDate = pcall(GetAchievementInfo, achievementId)

    if not success or not name or name == "" then
        return nil, nil, 0, nil, false
    end

    return name, description, points or 0, icon, completed
end

function SimpleAchievementTracker.GetAchievementStatus(achievementId)
    if not achievementId then
        return false
    end

    local name, description, points, icon, completed = SimpleAchievementTracker.GetAchievementInfo(achievementId)

    if name == nil then
        local directName, directDesc, directPoints, directIcon, directCompleted = GetAchievementInfo(achievementId)
        if directName and directName ~= "" then
            return directCompleted == true
        end
        return false
    end

    return completed == true
end

function SimpleAchievementTracker.PositionTabsWindow()
    if SimpleAchievementTracker.window and SimpleAchievementTracker.tabsWindow then
        SimpleAchievementTracker.tabsWindow:ClearAnchors()
        SimpleAchievementTracker.tabsWindow:SetAnchor(TOPRIGHT, SimpleAchievementTracker.window, TOPLEFT, -5, 0)
    end
end

function SimpleAchievementTracker.CreateWindow()
    local tabsWindow = WINDOW_MANAGER:CreateTopLevelWindow("SimpleAchievementTrackerTabsWindow")
    tabsWindow:SetDimensions(50, 120)
    tabsWindow:SetMouseEnabled(true)
    tabsWindow:SetMovable(false)
    tabsWindow:SetClampedToScreen(true)
    tabsWindow:SetHidden(true)

    local tabsBackground = WINDOW_MANAGER:CreateControl("$(parent)Background", tabsWindow, CT_BACKDROP)
    tabsBackground:SetAnchorFill()
    tabsBackground:SetCenterColor(0.1, 0.1, 0.1, 0.9)
    tabsBackground:SetEdgeColor(0, 0, 0, 0)
    tabsBackground:SetEdgeTexture("/esoui/art/miscellaneous/blanktexture.dds", 128, 16, 16)

    local trialsTabIcon = WINDOW_MANAGER:CreateControl("$(parent)TrialsTabIcon", tabsWindow, CT_LABEL)
    trialsTabIcon:SetDimensions(40, 30)
    trialsTabIcon:SetAnchor(TOP, tabsWindow, TOP, 0, 5)
    trialsTabIcon:SetFont("ZoFontWinH4")
    trialsTabIcon:SetText("T")
    trialsTabIcon:SetColor(0.8, 0.8, 0.8, 1)
    trialsTabIcon:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    trialsTabIcon:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    trialsTabIcon:SetMouseEnabled(true)
    trialsTabIcon:SetHandler(
        "OnMouseDown",
        function(self, button)
            if button == 1 then
                SimpleAchievementTracker.ShowTrialsTab()
            end
        end
    )
    trialsTabIcon:SetHandler(
        "OnMouseEnter",
        function(self)
            self:SetColor(1, 1, 1, 1)
            ZO_Tooltips_ShowTextTooltip(self, TOP, "Trials")
        end
    )
    trialsTabIcon:SetHandler(
        "OnMouseExit",
        function(self)
            self:SetColor(0.8, 0.8, 0.8, 1)
            ZO_Tooltips_HideTextTooltip()
        end
    )

    local dungeonsTabIcon = WINDOW_MANAGER:CreateControl("$(parent)DungeonsTabIcon", tabsWindow, CT_LABEL)
    dungeonsTabIcon:SetDimensions(40, 30)
    dungeonsTabIcon:SetAnchor(TOP, trialsTabIcon, BOTTOM, 0, 5)
    dungeonsTabIcon:SetFont("ZoFontWinH4")
    dungeonsTabIcon:SetText("D")
    dungeonsTabIcon:SetColor(0.8, 0.8, 0.8, 1)
    dungeonsTabIcon:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    dungeonsTabIcon:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    dungeonsTabIcon:SetMouseEnabled(true)
    dungeonsTabIcon:SetHandler(
        "OnMouseDown",
        function(self, button)
            if button == 1 then
                SimpleAchievementTracker.ShowDungeonsTab()
            end
        end
    )
    dungeonsTabIcon:SetHandler(
        "OnMouseEnter",
        function(self)
            self:SetColor(1, 1, 1, 1)
            ZO_Tooltips_ShowTextTooltip(self, TOP, "Dungeons")
        end
    )
    dungeonsTabIcon:SetHandler(
        "OnMouseExit",
        function(self)
            self:SetColor(0.8, 0.8, 0.8, 1)
            ZO_Tooltips_HideTextTooltip()
        end
    )

    local arenasTabIcon = WINDOW_MANAGER:CreateControl("$(parent)ArenasTabIcon", tabsWindow, CT_LABEL)
    arenasTabIcon:SetDimensions(40, 30)
    arenasTabIcon:SetAnchor(TOP, dungeonsTabIcon, BOTTOM, 0, 5)
    arenasTabIcon:SetFont("ZoFontWinH4")
    arenasTabIcon:SetText("A")
    arenasTabIcon:SetColor(0.8, 0.8, 0.8, 1)
    arenasTabIcon:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    arenasTabIcon:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    arenasTabIcon:SetMouseEnabled(true)
    arenasTabIcon:SetHandler(
        "OnMouseDown",
        function(self, button)
            if button == 1 then
                SimpleAchievementTracker.ShowArenasTab()
            end
        end
    )
    arenasTabIcon:SetHandler(
        "OnMouseEnter",
        function(self)
            self:SetColor(1, 1, 1, 1)
            ZO_Tooltips_ShowTextTooltip(self, TOP, "Arenas")
        end
    )
    arenasTabIcon:SetHandler(
        "OnMouseExit",
        function(self)
            self:SetColor(0.8, 0.8, 0.8, 1)
            ZO_Tooltips_HideTextTooltip()
        end
    )

    SimpleAchievementTracker.tabsWindow = tabsWindow

    local window = WINDOW_MANAGER:CreateTopLevelWindow("SimpleAchievementTrackerWindow")
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)

    window:SetDimensions(SimpleAchievementTracker.saved.window.width, SimpleAchievementTracker.saved.window.height)

    window:SetHandler(
        "OnMoveStart",
        function(self)
            self:SetMovable(true)
        end
    )

    window:SetHandler(
        "OnMoveStop",
        function(self)
            self:StopMovingOrResizing()
            SimpleAchievementTracker.saved.window.left = self:GetLeft()
            SimpleAchievementTracker.saved.window.top = self:GetTop()
            SimpleAchievementTracker.PositionTabsWindow()
        end
    )

    local indicator = WINDOW_MANAGER:CreateControl("SimpleAchievementTracker_ActiveTabIndicator", SimpleAchievementTracker.tabsWindow, CT_TEXTURE)
    indicator:SetDimensions(3, 40)
    indicator:SetColor(0.8, 0.8, 0.8, 1)
    indicator:SetHidden(true)
    SimpleAchievementTracker.activeTabIndicator = indicator

    local dragHandle = WINDOW_MANAGER:CreateControl("$(parent)DragHandle", window, CT_BACKDROP)
    dragHandle:SetHandler("OnKeyUp", function() end)
    dragHandle:SetDimensions(960, 30)
    dragHandle:SetAnchor(TOP, window, TOP, 0, 0)
    dragHandle:SetCenterColor(0.1, 0.1, 0.1, 0.98)
    dragHandle:SetEdgeColor(0, 0, 0, 0)
    dragHandle:SetEdgeTexture("/esoui/art/miscellaneous/blanktexture.dds", 128, 16, 16)
    dragHandle:SetMouseEnabled(true)

    dragHandle:SetHandler(
        "OnMouseDown",
        function(self, button)
            if button == 1 then
                window:StartMoving()
            end
        end
    )

    dragHandle:SetHandler(
        "OnMouseUp",
        function(self, button)
            if button == 1 then
                window:StopMovingOrResizing()
            end
        end
    )

    local container = WINDOW_MANAGER:CreateControl("$(parent)Container", window, CT_CONTROL)
    container:SetAnchorFill()

    local background = WINDOW_MANAGER:CreateControl("$(parent)Background", container, CT_BACKDROP)
    background:SetAnchorFill()
    background:SetCenterColor(0.1, 0.1, 0.1, 0.98)
    background:SetEdgeColor(0, 0, 0, 0)
    background:SetEdgeTexture("/esoui/art/miscellaneous/blanktexture.dds", 128, 16, 16)

    local title = WINDOW_MANAGER:CreateControl("$(parent)Title", container, CT_LABEL)
    title:SetDimensions(960, 25)
    title:SetAnchor(TOP, container, TOP, 0, 15)
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetFont("ZoFontWinH3")
    title:SetText("Simple Achievement Tracker")
    title:SetColor(0.8, 0.8, 0.8, 1)

    local closeButton = WINDOW_MANAGER:CreateControl("$(parent)CloseButton", window, CT_LABEL)
    closeButton:SetDimensions(25, 25)
    closeButton:SetAnchor(TOPRIGHT, container, TOPRIGHT, -10, 15)
    closeButton:SetFont("ZoFontWinH2")
    closeButton:SetText("×")
    closeButton:SetColor(0.6, 0.6, 0.6, 0.8)
    closeButton:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    closeButton:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    closeButton:SetMouseEnabled(true)
    closeButton:SetHandler(
        "OnMouseDown",
        function(self, button)
            if button == 1 then
                SimpleAchievementTracker.HideWindow()
            end
        end
    )
    closeButton:SetHandler(
        "OnMouseEnter",
        function(self)
            self:SetColor(0.8, 0.8, 0.8, 1)
        end
    )
    closeButton:SetHandler(
        "OnMouseExit",
        function(self)
            self:SetColor(0.6, 0.6, 0.6, 0.8)
        end
    )

    window.container = container
    window.dragHandle = dragHandle
    window:SetHidden(true)

    SimpleAchievementTracker.sceneFragment = ZO_FadeSceneFragment:New(window)
    SimpleAchievementTracker.sceneFragment:SetHideOnSceneHidden(true)

    SimpleAchievementTracker.scene = ZO_Scene:New("SimpleAchievementTrackerScene", SCENE_MANAGER)
    SimpleAchievementTracker.scene:AddFragment(SimpleAchievementTracker.sceneFragment)
    SimpleAchievementTracker.scene:AddFragment(KEYBIND_STRIP_FADE_FRAGMENT)

    if SimpleAchievementTracker.tabsWindow then
        local tabsFragment = ZO_FadeSceneFragment:New(SimpleAchievementTracker.tabsWindow)
        tabsFragment:SetHideOnSceneHidden(true)
        SimpleAchievementTracker.scene:AddFragment(tabsFragment)
    end

    SimpleAchievementTracker.keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_RIGHT,
        {
            name = "Close",
            keybind = "UI_SHORTCUT_EXIT",
            callback = function()
                SCENE_MANAGER:Hide("SimpleAchievementTrackerScene")
            end,
            visible = function()
                return SCENE_MANAGER:IsShowing("SimpleAchievementTrackerScene")
            end,
        },
    }

    return window
end

function SimpleAchievementTracker.ShowTab(tabType)
    SimpleAchievementTracker.currentTab = tabType

    local dataMap = {
        trials = SimpleAchievementTracker.Achievements,
        dungeons = SimpleAchievementTracker.Dungeons,
        arenas = SimpleAchievementTracker.Arenas
    }

    local data = dataMap[tabType]
    if not data then return end

    SimpleAchievementTracker.CreateSimpleTable(data)
    SimpleAchievementTracker.UpdateActiveTabIndicator(
        SimpleAchievementTracker.tabsWindow:GetNamedChild(tabType:sub(1,1):upper() .. tabType:sub(2) .. "TabIcon")
    )
end

function SimpleAchievementTracker.ShowTrialsTab()
    SimpleAchievementTracker.ShowTab("trials")
end

function SimpleAchievementTracker.ShowDungeonsTab()
    SimpleAchievementTracker.ShowTab("dungeons")
end

function SimpleAchievementTracker.ShowArenasTab()
    SimpleAchievementTracker.ShowTab("arenas")
end

function SimpleAchievementTracker.UpdateActiveTabIndicator(tabControl)
    local indicator = SimpleAchievementTracker.activeTabIndicator
    if not indicator or not tabControl then return end

    indicator:ClearAnchors()
    indicator:SetAnchor(LEFT, tabControl, LEFT, -5, 0)
    indicator:SetHidden(false)
end

function SimpleAchievementTracker.CalculateWindowSizeSimple()
    if SimpleAchievementTracker.currentTab == "trials" then
        return 980, 600
    elseif SimpleAchievementTracker.currentTab == "dungeons" then
        return 1160, 920
    else
        return 980, 400
    end
end

function SimpleAchievementTracker.CreateSimpleTable(data)
    if not SimpleAchievementTracker.window then return end

    SimpleAchievementTracker.tabContainers = SimpleAchievementTracker.tabContainers or {}
    SimpleAchievementTracker.tabSizes = SimpleAchievementTracker.tabSizes or {}

    local tabKey = SimpleAchievementTracker.currentTab
    local existingContainer = SimpleAchievementTracker.tabContainers[tabKey]

    for key, container in pairs(SimpleAchievementTracker.tabContainers) do
        if container and container.SetHidden then
            container:SetHidden(true)
        end
    end

    if existingContainer then
        existingContainer:SetHidden(false)
        SimpleAchievementTracker.window.container = existingContainer

        local size = SimpleAchievementTracker.tabSizes and SimpleAchievementTracker.tabSizes[tabKey]
        if size then
            if SimpleAchievementTracker.window and SimpleAchievementTracker.window.SetDimensions then
                SimpleAchievementTracker.window:SetDimensions(size.width or 900, size.height or 600)
            end
            if existingContainer and existingContainer.SetDimensions then
                existingContainer:SetDimensions(size.width or 900, size.height or 600)
            end
        end

        return
    end

    local uniqueId = tostring(GetGameTimeMilliseconds())
    local newContainerName = "SimpleAchievementTrackerWindowContainer_" .. uniqueId
    local newContainer = WINDOW_MANAGER:CreateControl(newContainerName, SimpleAchievementTracker.window, CT_CONTROL)
    newContainer:SetAnchorFill()
    SimpleAchievementTracker.window.container = newContainer

    newContainer:SetAlpha(0)
    local step = 0
    local function fadeIn()
        step = step + 0.1
        newContainer:SetAlpha(step)
        if step < 1 then
            zo_callLater(fadeIn, 20)
        end
    end
    fadeIn()

    SimpleAchievementTracker.tabContainers[tabKey] = newContainer

    SimpleAchievementTracker.controls = {}

    local background = WINDOW_MANAGER:CreateControl(nil, newContainer, CT_BACKDROP)
    background:SetAnchorFill()
    background:SetCenterColor(0.1, 0.1, 0.1, 0.98)
    background:SetEdgeColor(0, 0, 0, 0)
    background:SetEdgeTexture("/esoui/art/miscellaneous/blanktexture.dds", 128, 16, 16)

    for _, dataset in pairs({
        SimpleAchievementTracker.Achievements,
        SimpleAchievementTracker.Dungeons,
        SimpleAchievementTracker.Arenas
    }) do
        if type(dataset) == "table" then
            for _, entry in ipairs(dataset) do
                entry.TRFN, entry.EXTN, entry._trfLabel, entry._extLabel = nil, nil, nil, nil
            end
        end
    end

    for _, instance in ipairs(data) do
        if instance.TRF and not instance.TRFN then
            local hasTitle, titleName = GetAchievementRewardTitle(instance.TRF)
            instance.TRFN = (hasTitle and titleName and titleName ~= "") and titleName or (select(1, GetAchievementInfo(instance.TRF)) or "")
        end
        if instance.EXT and not instance.EXTN then
            local hasTitle, titleName = GetAchievementRewardTitle(instance.EXT)
            instance.EXTN = (hasTitle and titleName and titleName ~= "") and titleName or (select(1, GetAchievementInfo(instance.EXT)) or "")
        end
    end

    local windowWidth, windowHeight = SimpleAchievementTracker.CalculateWindowSizeSimple()
    SimpleAchievementTracker.window:SetDimensions(windowWidth, windowHeight)
    SimpleAchievementTracker.window.container:SetDimensions(windowWidth, windowHeight)
    SimpleAchievementTracker.tabSizes[SimpleAchievementTracker.currentTab] = {
        width = windowWidth,
        height = windowHeight
    }

    SimpleAchievementTracker.window:ClearAnchors()
    if SimpleAchievementTracker.saved.window.left and SimpleAchievementTracker.saved.window.top then
        SimpleAchievementTracker.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SimpleAchievementTracker.saved.window.left, SimpleAchievementTracker.saved.window.top)
    else
        SimpleAchievementTracker.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end

    local pageTitle = WINDOW_MANAGER:CreateControl(nil, SimpleAchievementTracker.window.container, CT_LABEL)
    pageTitle:SetDimensions(300, 30)
    pageTitle:SetAnchor(TOPLEFT, SimpleAchievementTracker.window.container, TOPLEFT, 25, 55)
    pageTitle:SetFont("ZoFontWinH2")
    pageTitle:SetText(SimpleAchievementTracker.currentTab == "trials" and "TRIALS"
        or SimpleAchievementTracker.currentTab == "dungeons" and "DUNGEONS"
        or "ARENAS")
    pageTitle:SetColor(0.8, 0.8, 0.8, 1)
    pageTitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    table.insert(SimpleAchievementTracker.controls, pageTitle)

    SimpleAchievementTracker.window:ClearAnchors()
    if SimpleAchievementTracker.saved.window.left and SimpleAchievementTracker.saved.window.top then
        SimpleAchievementTracker.window:SetAnchor(
            TOPLEFT,
            GuiRoot,
            TOPLEFT,
            SimpleAchievementTracker.saved.window.left,
            SimpleAchievementTracker.saved.window.top
        )
    else
        SimpleAchievementTracker.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end

    local headerLabels = {}
    if SimpleAchievementTracker.currentTab == "trials" then
        headerLabels = {
            {text = "TRIAL", x = 25, width = 180, align = TEXT_ALIGN_LEFT},
            {text = "VET", x = 210, width = 50, align = TEXT_ALIGN_CENTER},
            {text = "HM 1", x = 270, width = 50, align = TEXT_ALIGN_CENTER},
            {text = "HM 2", x = 330, width = 50, align = TEXT_ALIGN_CENTER},
            {text = "FULL HM", x = 390, width = 70, align = TEXT_ALIGN_CENTER},
            {text = "TRIFECTA", x = 485, width = 110, align = TEXT_ALIGN_LEFT},
            {text = "EXTRA", x = 700, width = 170, align = TEXT_ALIGN_LEFT}
        }
    elseif SimpleAchievementTracker.currentTab == "dungeons" then
        headerLabels = {
            {text = "DUNGEON", x = 25, width = 260, align = TEXT_ALIGN_LEFT},
            {text = "VET", x = 300, width = 50, align = TEXT_ALIGN_CENTER},
            {text = "NO DEATH", x = 363, width = 70, align = TEXT_ALIGN_CENTER},
            {text = "SPEED RUN", x = 442, width = 70, align = TEXT_ALIGN_CENTER},
            {text = "HARDMODE", x = 542, width = 70, align = TEXT_ALIGN_CENTER},
            {text = "TRIFECTA", x = 662, width = 200, align = TEXT_ALIGN_LEFT},
            {text = "EXTRA", x = 910, width = 300, align = TEXT_ALIGN_LEFT}
        }
    elseif SimpleAchievementTracker.currentTab == "arenas" then
        headerLabels = {
            {text = "ARENA", x = 25, width = 180, align = TEXT_ALIGN_LEFT},
            {text = "VET", x = 210, width = 50, align = TEXT_ALIGN_CENTER},
            {text = "NO DEATH", x = 273, width = 70, align = TEXT_ALIGN_CENTER},
            {text = "SPEED RUN", x = 352, width = 70, align = TEXT_ALIGN_CENTER},
            {text = "HARDMODE", x = 438, width = 70, align = TEXT_ALIGN_CENTER},
            {text = "TRIFECTA", x = 545, width = 110, align = TEXT_ALIGN_LEFT},
            {text = "EXTRA", x = 760, width = 170, align = TEXT_ALIGN_LEFT}
        }
    end

    local layoutConfig = {
        trials = {dividerPositions = {205, 265, 325, 385, 470, 683}, triX = 485, triNameX = 515, extX = 700, extNameX = 725},
        dungeons = {dividerPositions = {295, 355, 435, 516, 640, 894}, triX = 660, triNameX = 690, extX = 910, extNameX = 940},
        arenas = {dividerPositions = {205, 265, 345, 425, 520, 740}, triX = 545, triNameX = 575, extX = 760, extNameX = 795}
    }

    local config = layoutConfig[SimpleAchievementTracker.currentTab] or layoutConfig["trials"]
    local dividerPositions = config.dividerPositions

    for _, header in ipairs(headerLabels) do
        local label = WINDOW_MANAGER:CreateControl(nil, SimpleAchievementTracker.window.container, CT_LABEL)
        label:SetDimensions(header.width, 18)
        label:SetAnchor(TOPLEFT, SimpleAchievementTracker.window.container, TOPLEFT, header.x, 100)
        label:SetFont("ZoFontGameSmall")
        label:SetText(header.text)
        label:SetColor(0.7, 0.7, 0.7, 1)
        label:SetHorizontalAlignment(header.align)
        table.insert(SimpleAchievementTracker.controls, label)
    end

    local startY = 125
    local rowHeight = 24
    local rowSpacing = 4

    if SimpleAchievementTracker.currentTab == "dungeons" then
        rowHeight = 22
        rowSpacing = 3
        startY = 122
    end

    local numRows = #data
    local contentHeight = numRows * (rowHeight + rowSpacing)
    local dividerHeight = contentHeight + (startY - 104)

    for _, posX in ipairs(dividerPositions) do
        local divider = WINDOW_MANAGER:CreateControl(nil, SimpleAchievementTracker.window.container, CT_BACKDROP)
        divider:SetDimensions(1, dividerHeight)
        divider:SetAnchor(TOPLEFT, SimpleAchievementTracker.window.container, TOPLEFT, posX, 100)
        divider:SetCenterColor(0.3, 0.3, 0.3, 0.5)
        divider:SetEdgeColor(0.3, 0.3, 0.3, 0.5)
        divider:SetEdgeTexture("/esoui/art/miscellaneous/blanktexture.dds", 128, 16, 16)
        table.insert(SimpleAchievementTracker.controls, divider)
    end

    local function SetupAchievementTooltip(control, achievementId)
        if not achievementId then return end
        control:SetMouseEnabled(true)
        control:SetHandler("OnMouseEnter", function(self)
            InitializeTooltip(InformationTooltip, self, TOP, 0, 5)
            local name, description, points, icon, completed, dateStr, timeStr = GetAchievementInfo(achievementId)
            if not name or name == "" then
                name, description, points, icon, completed = "?", "?", 0, nil, false
            end
            if type(completed) == "number" then
                completed = completed ~= 0
            else
                completed = completed == true
            end
            local ts = type(GetAchievementTimestamp) == "function" and GetAchievementTimestamp(achievementId)
            local dateText
            if ts and ts > 0 then
                if type(ZO_FormatDate) == "function" then
                    dateText = ZO_FormatDate(ts, TIME_FORMAT_STYLE_MEDIUM_DATE, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR)
                else
                    dateText = os.date("%d.%m.%Y %H:%M:%S", ts)
                end
            elseif dateStr and dateStr ~= "" then
                dateText = timeStr and (dateStr .. " " .. timeStr) or dateStr
            end
            local lang = string.lower(GetCVar("Language.2") or "en")
            local locale = {
                ["en"] = {completed = "Completed", incomplete = "Incomplete"},
                ["ru"] = {completed = "Получено", incomplete = "Не получено"},
                ["fr"] = {completed = "Terminé", incomplete = "Non terminé"},
                ["de"] = {completed = "Abgeschlossen", incomplete = "Nicht abgeschlossen"},
                ["es"] = {completed = "Completado", incomplete = "Incompleto"},
                ["jp"] = {completed = "完了", incomplete = "未完了"}
            }
            local completedLabel = locale[lang] and locale[lang].completed or locale["en"].completed
            local incompleteLabel = locale[lang] and locale[lang].incomplete or locale["en"].incomplete
            local statusText = completed and ("|c50C878" .. completedLabel .. "|r") or ("|c8B0000" .. incompleteLabel .. "|r")
            local iconText = icon and string.format("|t24:24:%s|t ", icon) or ""
            InformationTooltip:ClearLines()
            InformationTooltip:AddLine(iconText .. name, "ZoFontWinH4", 1, 1, 1, CENTER)
            InformationTooltip:AddVerticalPadding(8)
            InformationTooltip:AddLine(description or "—", "ZoFontGameSmall", 0.9, 0.9, 0.9, LEFT)
            InformationTooltip:AddVerticalPadding(8)
            InformationTooltip:AddLine(string.format("%s  •  %d Points", statusText, points or 0), "ZoFontGameSmall")
            if completed and dateText and dateText ~= "" then
                InformationTooltip:AddVerticalPadding(8)
                InformationTooltip:AddLine(string.format("|cDDDDDD%s|r", dateText), "ZoFontGameSmall", 1, 1, 1, LEFT)
            end
        end)
        control:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
        control:SetHandler("OnMouseUp", function(self, button)
            if button == MOUSE_BUTTON_INDEX_RIGHT then
                local link = GetAchievementLink(achievementId)
                if link and IsChatSystemAvailableForCurrentPlatform() then
                    StartChatInput(link, nil)
                end
            end
        end)
    end

    for i, instance in ipairs(data)
        do local rowY = startY + (i - 1) * (rowHeight + rowSpacing)
        local rowBg = WINDOW_MANAGER:CreateControl(nil, SimpleAchievementTracker.window.container, CT_BACKDROP)
        rowBg:SetDimensions(windowWidth-45, rowHeight)
        rowBg:SetAnchor(TOPLEFT, SimpleAchievementTracker.window.container, TOPLEFT, 25, rowY)

        if i % 2 == 0 then rowBg:SetCenterColor(0.25,0.25,0.25,0.3) else rowBg:SetCenterColor(0.15,0.15,0.15,0.3) end
        rowBg:SetEdgeColor(0,0,0,0)
        table.insert(SimpleAchievementTracker.controls, rowBg)

        local nameLabel = WINDOW_MANAGER:CreateControl(nil, SimpleAchievementTracker.window.container, CT_LABEL)
        nameLabel:SetDimensions(260,rowHeight)
        nameLabel:SetAnchor(TOPLEFT, SimpleAchievementTracker.window.container, TOPLEFT, 30, rowY)
        nameLabel:SetFont("ZoFontGameSmall")

        local zoneName = instance.NAME or (instance.ZONEID and GetZoneNameById(instance.ZONEID)) or "Unknown Zone"
        zoneName = zoneName:gsub("%^.+", ""):gsub("{%d+}", "")
        nameLabel:SetText(zoneName.." ("..(instance.ABRV or "?")..")")
        nameLabel:SetColor(1,1,1,1)
        nameLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        nameLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)

        nameLabel:SetMouseEnabled(true)
        nameLabel:SetHandler("OnMouseEnter", function(self)
            self:SetColor(0.7, 1.0, 0.7, 1)

            local lang = string.lower(GetCVar("Language.2") or "en")
            local tips = {
                ["en"] = "Fast Travel",
                ["de"] = "Schnellreise",
                ["fr"] = "Voyage rapide",
                ["ru"] = "Быстрое перемещение",
                ["es"] = "Viaje rápido",
                ["jp"] = "高速移動",
            }
            ZO_Tooltips_ShowTextTooltip(self, TOP, tips[lang] or tips["en"])
        end)
        nameLabel:SetHandler("OnMouseExit", function(self)
            self:SetColor(1, 1, 1, 1)
            ZO_Tooltips_HideTextTooltip()
        end)
        nameLabel:SetHandler("OnMouseDown", function(self)
            self:SetColor(1, 1, 1, 1)
        end)

        nameLabel:SetHandler("OnMouseUp", function(self, button)
            if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
            if not instance.ZONEID then return end

            local nodeId
            local nodeTables = { SAT_NodeID.Dungeons, SAT_NodeID.Trials, SAT_NodeID.Arenas }

            for _, t in ipairs(nodeTables) do
                for _, d in ipairs(t) do
                    if d.ZONEID == instance.ZONEID then
                        nodeId = d.NODEID
                        break
                    end
                end
            end

            if not nodeId then
                d("|cFF0000NodeID not found|r")
                return
            end

            ClearMenu()

            AddMenuItem("Teleport: Normal", function()
                if CanPlayerChangeGroupDifficulty() then
                    SetVeteranDifficulty(false)
                end
                SimpleAchievementTracker.HideWindow()
                zo_callLater(function() FastTravelToNode(nodeId) end, 200)
            end)

            AddMenuItem("Teleport: Veteran", function()
                if CanPlayerChangeGroupDifficulty() then
                    SetVeteranDifficulty(true)
                end
                SimpleAchievementTracker.HideWindow()
                zo_callLater(function() FastTravelToNode(nodeId) end, 200)
            end)

            ShowMenu(self)

            zo_callLater(function()
                if self and self.SetColor then
                    self:SetColor(1, 1, 1, 1)
                end
            end, 10)
        end)

        table.insert(SimpleAchievementTracker.controls,nameLabel)
        local achievementsToShow={}
        if SimpleAchievementTracker.currentTab=="trials" then
            achievementsToShow={{id=instance.VET,x=210,width=50},{id=instance.HM1,x=270,width=50},{id=instance.HM2,x=330,width=50},{id=instance.HM,x=390,width=70}}
        elseif SimpleAchievementTracker.currentTab=="dungeons" then
            achievementsToShow={{id=instance.VET,x=300,width=50},{id=instance.ND,x=358,width=70},{id=instance.SR,x=438,width=70},{id=instance.HM,x=542,width=70}}
        elseif SimpleAchievementTracker.currentTab=="arenas" then
            achievementsToShow={{id=instance.VET,x=210,width=50},{id=instance.ND,x=270,width=70},{id=instance.SR,x=350,width=70},{id=instance.HM,x=435,width=70}}
        end
        for _,achievement in ipairs(achievementsToShow) do
            local statusLabel=WINDOW_MANAGER:CreateControl(nil,SimpleAchievementTracker.window.container,CT_LABEL)
            statusLabel:SetDimensions(achievement.width,rowHeight)
            statusLabel:SetAnchor(TOPLEFT,SimpleAchievementTracker.window.container,TOPLEFT,achievement.x,rowY)
            statusLabel:SetFont("ZoFontWinH4")
            statusLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            statusLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            if achievement.id then
                local completed=SimpleAchievementTracker.GetAchievementStatus(achievement.id)
                statusLabel:SetText(completed and "|c50C878+|r" or "|c8B0000-|r")
                SetupAchievementTooltip(statusLabel,achievement.id)
            else
                statusLabel:SetText("|c888888x|r")
            end
            table.insert(SimpleAchievementTracker.controls,statusLabel)
        end
        local triStatus=WINDOW_MANAGER:CreateControl(nil,SimpleAchievementTracker.window.container,CT_LABEL)
        triStatus:SetDimensions(20,rowHeight)
        triStatus:SetAnchor(TOPLEFT,SimpleAchievementTracker.window.container,TOPLEFT,config.triX,rowY)
        triStatus:SetFont("ZoFontWinH4")
        triStatus:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        triStatus:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        if instance.TRF then
            local completed=SimpleAchievementTracker.GetAchievementStatus(instance.TRF)
            triStatus:SetText(completed and "|c50C878+|r" or "|c8B0000-|r")
            SetupAchievementTooltip(triStatus,instance.TRF)
        else
            triStatus:SetText("|c888888x|r")
        end
        table.insert(SimpleAchievementTracker.controls,triStatus)
        local TRFN=WINDOW_MANAGER:CreateControl(nil,SimpleAchievementTracker.window.container,CT_LABEL)
        instance._trfLabel=TRFN
        TRFN:SetDimensions(185,rowHeight)
        TRFN:SetAnchor(TOPLEFT,SimpleAchievementTracker.window.container,TOPLEFT,config.triNameX,rowY)
        TRFN:SetFont("ZoFontGameSmall")
        TRFN:SetText(instance.TRFN or "")
        TRFN:SetColor(1,1,1,1)
        TRFN:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        TRFN:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        table.insert(SimpleAchievementTracker.controls,TRFN)
        local parent=SimpleAchievementTracker.window and SimpleAchievementTracker.window.container
        if parent then
            local extStatus=WINDOW_MANAGER:CreateControl(nil,parent,CT_LABEL)
            extStatus:SetDimensions(20,rowHeight)
            extStatus:SetAnchor(TOPLEFT,parent,TOPLEFT,config.extX,rowY)
            extStatus:SetFont("ZoFontWinH4")
            extStatus:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            extStatus:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            extStatus:SetMouseEnabled(true)
            extStatus:SetDrawTier(DT_HIGH)
            extStatus:SetDrawLayer(DL_OVERLAY)
            if instance.EXT then
                local _,_,_,_,completed=GetAchievementInfo(instance.EXT)
                extStatus:SetText(completed and "|c50C878+|r" or "|c8B0000-|r")
                SetupAchievementTooltip(extStatus,instance.EXT)
            else
                extStatus:SetText("|c888888x|r")
            end
        end
        local EXTN=WINDOW_MANAGER:CreateControl(nil,SimpleAchievementTracker.window.container,CT_LABEL)
        instance._extLabel=EXTN
        EXTN:SetDimensions(175,rowHeight)
        EXTN:SetAnchor(TOPLEFT,SimpleAchievementTracker.window.container,TOPLEFT,config.extNameX,rowY)
        EXTN:SetFont("ZoFontGameSmall")
        EXTN:SetText(instance.EXTN or "")
        EXTN:SetColor(1,1,1,1)
        EXTN:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        EXTN:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        table.insert(SimpleAchievementTracker.controls,EXTN)
    end
    local function GetFormattedDateTime()
        local timestamp=GetTimeStamp()
        local year=os.date("%Y",timestamp)
        local month=os.date("%m",timestamp)
        local day=os.date("%d",timestamp)
        local hour=os.date("%H",timestamp)
        local minute=os.date("%M",timestamp)
        return string.format("%s.%s.%s %s:%s",day,month,year,hour,minute)
    end
    local accountName=GetDisplayName()
    local currentDateTime=GetFormattedDateTime()
    local dateLabel=WINDOW_MANAGER:CreateControl(nil,SimpleAchievementTracker.window.container,CT_LABEL)
    dateLabel:SetDimensions(180,14)
    dateLabel:SetAnchor(BOTTOMRIGHT,SimpleAchievementTracker.window.container,BOTTOMRIGHT,-15,-15)
    dateLabel:SetFont("ZoFontGameSmall")
    dateLabel:SetText(currentDateTime)
    dateLabel:SetColor(0.6,0.6,0.6,0.7)
    dateLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    table.insert(SimpleAchievementTracker.controls,dateLabel)
    local accountLabel=WINDOW_MANAGER:CreateControl(nil,SimpleAchievementTracker.window.container,CT_LABEL)
    accountLabel:SetDimensions(180,14)
    accountLabel:SetAnchor(BOTTOMRIGHT,dateLabel,TOPRIGHT,0,-2)
    accountLabel:SetFont("ZoFontGameSmall")
    accountLabel:SetText("Account: "..accountName)
    accountLabel:SetColor(0.6,0.6,0.6,0.7)
    accountLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    table.insert(SimpleAchievementTracker.controls,accountLabel)
end

local wm = WINDOW_MANAGER

local function SAT_GlobalMouseCheck()
    local lbl = SimpleAchievementTracker._lastHoverLabel
    if not lbl or type(lbl) ~= "userdata" then
        SimpleAchievementTracker._lastHoverLabel = nil
        return
    end

    local mouseOver = wm and wm:GetMouseOverControl() or nil

    if mouseOver ~= lbl then
        if lbl.SetColor and type(lbl.SetColor) == "function" then
            lbl:SetColor(1, 1, 1, 1)
        end
        ZO_Tooltips_HideTextTooltip()
        SimpleAchievementTracker._lastHoverLabel = nil
    end
end

EVENT_MANAGER:RegisterForUpdate("SAT_MouseCheck", 30, SAT_GlobalMouseCheck)


function SimpleAchievementTracker.ShowWindow()
    if not SimpleAchievementTracker.window then
        SimpleAchievementTracker.window = SimpleAchievementTracker.CreateWindow()
    end

    SCENE_MANAGER:Show("SimpleAchievementTrackerScene")

    if SimpleAchievementTracker.tabsWindow then
        SimpleAchievementTracker.tabsWindow:SetHidden(false)
        SimpleAchievementTracker.PositionTabsWindow()
    end

    KEYBIND_STRIP:AddKeybindButtonGroup(SimpleAchievementTracker.keybindStripDescriptor)

    SimpleAchievementTracker.window:ClearAnchors()
    if SimpleAchievementTracker.saved.window.left and SimpleAchievementTracker.saved.window.top then
        SimpleAchievementTracker.window:SetAnchor(
            TOPLEFT, GuiRoot, TOPLEFT,
            SimpleAchievementTracker.saved.window.left,
            SimpleAchievementTracker.saved.window.top
        )
    else
        SimpleAchievementTracker.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end

    if not SimpleAchievementTracker.currentTab then
        SimpleAchievementTracker.ShowTab("trials")
    end
end

function SimpleAchievementTracker.HideWindow()
    if SCENE_MANAGER:IsShowing("SimpleAchievementTrackerScene") then
        SCENE_MANAGER:Hide("SimpleAchievementTrackerScene")
    end
    KEYBIND_STRIP:RemoveKeybindButtonGroup(SimpleAchievementTracker.keybindStripDescriptor)
end

function SimpleAchievementTracker.ToggleWindow()
    if SimpleAchievementTracker.window and not SimpleAchievementTracker.window:IsHidden() then
        SimpleAchievementTracker.HideWindow()
    else
        SimpleAchievementTracker.ShowWindow()
    end
end

function SimpleAchievementTracker.OnAddOnLoaded(event, addonName)
    if addonName ~= "SimpleAchievementTracker" then return end

    EVENT_MANAGER:UnregisterForEvent("SimpleAchievementTracker", EVENT_ADD_ON_LOADED)

    SimpleAchievementTracker.saved =
        ZO_SavedVars:New("SimpleAchievementTrackerSaved", 1, nil, SimpleAchievementTracker.defaults)

    SLASH_COMMANDS["/sat"] = SimpleAchievementTracker.ToggleWindow
    EVENT_MANAGER:RegisterForEvent("SimpleAchievementTracker", EVENT_ACHIEVEMENT_UPDATED, SimpleAchievementTracker.OnAchievementUpdated)
end

EVENT_MANAGER:RegisterForEvent("SimpleAchievementTracker_ESC", EVENT_KEY_DOWN, function(_, key)
    if key == KEY_ESCAPE and SimpleAchievementTracker.window and not SimpleAchievementTracker.window:IsHidden() then
        SimpleAchievementTracker.HideWindow()
        return true
    end
end)

function SimpleAchievementTracker.OnAchievementUpdated(_, achievementId)
    if not SimpleAchievementTracker.window or SimpleAchievementTracker.window:IsHidden() then
        return
    end
    if SimpleAchievementTracker.currentTab then
        SimpleAchievementTracker.CreateSimpleTable(
            (SimpleAchievementTracker.currentTab == "trials" and SimpleAchievementTracker.Achievements)
            or (SimpleAchievementTracker.currentTab == "dungeons" and SimpleAchievementTracker.Dungeons)
            or (SimpleAchievementTracker.currentTab == "arenas" and SimpleAchievementTracker.Arenas)
        )
    end
end

ESO_Dialogs["SAT_CONFIRM_TELEPORT"] = {
    title = {
        text = function()
            local lang = string.lower(GetCVar("Language.2") or "en")
            local titles = {
                ["en"] = "Teleport",
                ["de"] = "Teleportieren",
                ["fr"] = "Téléportation",
                ["ru"] = "Телепортация",
                ["es"] = "Teletransporte",
                ["jp"] = "テレポート",
            }
            return titles[lang] or titles["en"]
        end,
    },
    mainText = {
        text = function(dialog)
            local zoneName = dialog.data.zoneName or GetString(SI_ZONE_NAME_UNKNOWN)
            local lang = string.lower(GetCVar("Language.2") or "en")
            local texts = {
                ["en"] = "Travel to |c00FF00%s|r?",
                ["de"] = "Reisen nach |c00FF00%s|r?",
                ["fr"] = "Voyager vers |c00FF00%s|r ?",
                ["ru"] = "Отправиться в |c00FF00%s|r?",
                ["es"] = "¿Viajar a |c00FF00%s|r?",
                ["jp"] = "|c00FF00%s|r に移動しますか？",
            }
            local fmt = texts[lang] or texts["en"]
            return string.format(fmt, zoneName)
        end,
    },
    buttons = {
        [1] = {
            text = SI_DIALOG_ACCEPT,
            callback = function(dialog)
                local nodeId = dialog.data.nodeId
                if nodeId then
                    if SimpleAchievementTracker and SimpleAchievementTracker.HideWindow then
                        SimpleAchievementTracker.HideWindow()
                    end
                    zo_callLater(function()
                        FastTravelToNode(nodeId)
                    end, 200)
                end
            end,
        },
        [2] = {
            text = SI_DIALOG_CANCEL,
        },
    },
}


ZO_CreateStringId("SI_BINDING_NAME_SIMPLE_ACHIEVEMENT_TRACKER_TOGGLE", "Toggle Simple Achievement Tracker")
EVENT_MANAGER:RegisterForEvent("SimpleAchievementTracker", EVENT_ADD_ON_LOADED, SimpleAchievementTracker.OnAddOnLoaded)