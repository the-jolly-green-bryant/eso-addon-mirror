local Addon = NMGuildHall
local UI = Addon.UI

function UI:CreateTabs()
    local tabBar = WINDOW_MANAGER:CreateControl("NMGuildHall_TabBar", self.window, CT_CONTROL)
    local width = (self.window and self.window.GetWidth and self.window:GetWidth()) or 700
    tabBar:SetDimensions(width, 50)
    tabBar:SetAnchor(TOP, self.header, BOTTOM, 0, 5)

    local tabs = {
        {id = "home", label = GetString(NMGH_TAB_HOME), icon = "EsoUI/Art/TreeIcons/Gamepad/gp_tutorial_idexicon_contacts.dds"},
        {id = "teleport", label = GetString(NMGH_TAB_TELEPORT), icon = "EsoUI/Art/Icons/poi/poi_wayshrine_complete.dds"},
        {id = "group", label = GetString(NMGH_TAB_GROUP), icon = "EsoUI/Art/LFG/Gamepad/gp_lfg_groupfinder_mygroup.dds"},
        {id = "campaign", label = GetString(NMGH_TAB_QUEUE_CAMPAIGN), icon = "EsoUI/Art/Icons/poi/poi_keep_complete.dds"},
        {id = "pledges", label = GetString(NMGH_TAB_PLEDGES), icon = "EsoUI/Art/LevelUpRewards/levelup_veteran_dungeon_64.dds"},
    }

    local numTabs = #tabs
    local tabGap = 4
    local tabWidth = math.floor((tabBar:GetWidth() - (numTabs - 1) * tabGap) / numTabs)
    self.tabs = {}

    for i, tabData in ipairs(tabs) do
        local tab = self:CreateTab(tabBar, tabData, (i-1) * (tabWidth + tabGap), tabWidth)
        self.tabs[tabData.id] = tab
    end

    self.tabBar = tabBar
end

function UI:CreateTab(parent, tabData, xOffset, width)
    local Constants = Addon and Addon.Constants
    local uiColors = Constants and Constants.UI and Constants.UI.COLORS
    local inactiveCenter = (uiColors and uiColors.TAB_INACTIVE_CENTER) or {0.10, 0.10, 0.12, 0.8}
    local inactiveEdge = (uiColors and uiColors.TAB_INACTIVE_EDGE) or {0.3, 0.3, 0.35, 0.6}
    local textNormal = (uiColors and uiColors.TEXT_NORMAL) or {0.7, 0.7, 0.7, 1}
    local textHighlight = (uiColors and uiColors.TEXT_HIGHLIGHT) or {0.9, 0.9, 0.9, 1}
    local hoverCenter = (uiColors and uiColors.TAB_HOVER_CENTER) or {0.14, 0.14, 0.16, 0.9}
    local hoverEdge = (uiColors and uiColors.TAB_HOVER_EDGE) or {0.5, 0.5, 0.55, 0.8}

    local tab = WINDOW_MANAGER:CreateControl("NMGuildHall_Tab_" .. tabData.id, parent, CT_BUTTON)
    tab:SetDimensions(width, 50)
    tab:SetAnchor(LEFT, parent, LEFT, xOffset, 0)

    -- Use ESO's tab background texture for inactive state with transparency
    local bg = WINDOW_MANAGER:CreateControl("NMGuildHall_Tab_" .. tabData.id .. "_BG", tab, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(unpack(inactiveCenter))
    bg:SetEdgeTexture("EsoUI/Art/Buttons/tab_inset.dds", 2, 2, 1, 1)
    bg:SetEdgeColor(unpack(inactiveEdge))
    -- Add shadow for depth
    bg:SetInsets(1, 1, -1, -1)

    -- Tab label with icon using ESO styling
    local label = WINDOW_MANAGER:CreateControl("NMGuildHall_Tab_" .. tabData.id .. "_Label", tab, CT_LABEL)
    label:SetFont("ZoFontGame")
    label:SetText(" |t22:22:" .. tabData.icon .. "|t " .. tabData.label .. " ")
    label:SetAnchor(CENTER, tab, CENTER, 0, 0)
    label:SetColor(unpack(textNormal))

    tab.background = bg
    tab.label = label
    tab.data = tabData

    tab:SetHandler("OnClicked", function()
        self:SwitchTab(tabData.id)
    end)

    tab:SetHandler("OnMouseEnter", function()
        if self.currentTab ~= tabData.id then
            bg:SetCenterColor(unpack(hoverCenter))
            bg:SetEdgeColor(unpack(hoverEdge))
            label:SetColor(unpack(textHighlight))
        end
    end)

    tab:SetHandler("OnMouseExit", function()
        if self.currentTab ~= tabData.id then
            bg:SetCenterColor(unpack(inactiveCenter))
            bg:SetEdgeColor(unpack(inactiveEdge))
            label:SetColor(unpack(textNormal))
        end
    end)

    return tab
end

function UI:SwitchTab(tabId)
    local Constants = Addon and Addon.Constants
    local uiColors = Constants and Constants.UI and Constants.UI.COLORS
    local activeCenter = (uiColors and uiColors.TAB_ACTIVE_CENTER) or {0.8, 0.2, 0.3, 0.9}
    local activeEdge = (uiColors and uiColors.TAB_ACTIVE_EDGE) or {0.9, 0.3, 0.4, 0.8}
    local inactiveCenter = (uiColors and uiColors.TAB_INACTIVE_CENTER) or {0.10, 0.10, 0.12, 0.8}
    local inactiveEdge = (uiColors and uiColors.TAB_INACTIVE_EDGE) or {0.3, 0.3, 0.35, 0.6}
    local textNormal = (uiColors and uiColors.TEXT_NORMAL) or {0.7, 0.7, 0.7, 1}
    local textHighlight = (uiColors and uiColors.TEXT_HIGHLIGHT) or {0.9, 0.9, 0.9, 1}

    -- Update tab appearance using ESO textures with transparency
    if self.tabs then
        for id, tab in pairs(self.tabs) do
            if id == tabId then
                -- Active tab with transparency
                tab.background:SetCenterColor(unpack(activeCenter))
                tab.background:SetEdgeColor(unpack(activeEdge))
                tab.label:SetColor(unpack(textHighlight))
            else
                -- Inactive tab with transparency
                tab.background:SetCenterColor(unpack(inactiveCenter))
                tab.background:SetEdgeColor(unpack(inactiveEdge))
                tab.label:SetColor(unpack(textNormal))
            end
        end
    end

    -- Show/hide content
    if self.contentContainers then
        for id, container in pairs(self.contentContainers) do
            if container then
                container:SetHidden(id ~= tabId)
            end
        end
    end

    self.currentTab = tabId

    -- Update content if needed
    if tabId == "pledges" then
        self:UpdatePledges()
    elseif tabId == "group" then
        self:UpdateGroupContent()
    elseif tabId == "teleport" then
        local searchText = self.teleportSearchBox and self.teleportSearchBox:GetText() or ""
        self:RefreshTeleportList(searchText)
    elseif tabId == "campaign" then
        if self.RefreshCampaignList then
            self:RefreshCampaignList(false)
        end
    end
end

-- Tab navigation functions
function UI:NextTab()
    local tabs = {"home", "teleport", "group", "campaign", "pledges"}
    local currentIndex = 1
    for i, tab in ipairs(tabs) do
        if self.currentTab == tab then
            currentIndex = i
            break
        end
    end
    local nextIndex = (currentIndex % #tabs) + 1
    self:ShowTab(tabs[nextIndex])
end

function UI:PreviousTab()
    local tabs = {"home", "teleport", "group", "campaign", "pledges"}
    local currentIndex = 1
    for i, tab in ipairs(tabs) do
        if self.currentTab == tab then
            currentIndex = i
            break
        end
    end
    local prevIndex = ((currentIndex - 2) % #tabs) + 1
    self:ShowTab(tabs[prevIndex])
end

function UI:ShowTab(tabName)
    if not self.tabs or not self.contentContainers or not self.window or self.initialized ~= true then
        if self.EnsureReady then
            self:EnsureReady(function(success)
                if success then
                    self:ShowTab(tabName)
                end
            end)
        end
        return
    end

    if self.window.IsHidden and self.window:IsHidden() then
        self:Show(tabName)
        return
    end

    self:SwitchTab(tabName)
end
