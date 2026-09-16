-- Common Works -- tabbed shell for the settings panel.
--
-- Replace a LAM placeholder with fixed navigation and one page per CW.settingsTabs entry.
-- Parent navigation to the panel, outside its scroll child.

CommonWorksUI = CommonWorksUI or {}
local CW = CommonWorksUI

local WM = WINDOW_MANAGER
local CM = CALLBACK_MANAGER

local TAB_BAR_HEIGHT  = 30
local TAB_BAR_GAP     = 12    -- nav row to content
local TAB_BUTTON_GAP  = 4
local TAB_BUTTON_PAD  = 16    -- breathing room either side of a label
local WIDGET_SPACING  = 15    -- vertical, between stacked widgets
local HALF_WIDGET_GAP = 10    -- horizontal, between a half-width pair

local tabBar
local tabButtons = {}
local tabPages   = {}
local selectedTab

local function SelectTab(index)
    selectedTab = index

    -- Preview only this page's widgets to avoid overlapping stand-ins.
    CW.SetHudPlacementMode(true, CW.SelectedSettingsTabKey())

    for i, button in ipairs(tabButtons) do
        button.button:SetState(i == index and BSTATE_PRESSED or BSTATE_NORMAL, i == index)
    end
    for i, page in ipairs(tabPages) do
        page:SetHidden(i ~= index)
    end

    ZO_Scroll_ResetToTop(CW.settingsPanel.container)
end


-- nil before the panel is built.
function CW.SelectedSettingsTabKey()
    local tab = selectedTab and CW.settingsTabs[selectedTab]
    return tab and tab.key or nil
end

-- Keyed by the groupset's key: { getFunc, members = { key -> frame } }.
local groupSets = {}

local BuildWidgets, BuildGroupSet

-- Pair consecutive half-width widgets as LAM does; return last control and total height.
-- Sum heights for groupsets: unresolved build-time anchors make GetBottom return 0.
function BuildWidgets(page, options, lastControl)
    local pendingHalf
    local height, rowHeight = 0, 0

    local function StartRow(widget, widgetHeight)
        if lastControl then
            widget:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, 0, WIDGET_SPACING)
            height = height + WIDGET_SPACING
        else
            widget:SetAnchor(TOPLEFT, page, TOPLEFT, 0, 0)
        end
        rowHeight = widgetHeight
        height = height + rowHeight
    end

    for _, data in ipairs(options) do
        if data.type == "groupset" then
            local frame, frameHeight = BuildGroupSet(page, data, lastControl)
            StartRow(frame, frameHeight)
            lastControl, pendingHalf = frame, nil
        else
            local widget = LAMCreateControl[data.type](page, data)

            if pendingHalf and widget.isHalfWidth then
                widget:SetAnchor(TOPLEFT, pendingHalf, TOPRIGHT, HALF_WIDGET_GAP, 0)
                height = height - rowHeight + zo_max(rowHeight, widget:GetHeight())
                lastControl = pendingHalf
                pendingHalf = nil
            else
                StartRow(widget, widget:GetHeight())
                lastControl = widget
                pendingHalf = widget.isHalfWidth and widget or nil
            end
        end
    end

    return lastControl, height
end

-- Stack alternative option lists in one slot sized to the tallest.
-- Shorter lists leave blank space so switching cannot move later controls.
function BuildGroupSet(page, data)
    local set = { getFunc = data.getFunc, members = {} }
    local tallest = 0

    for _, member in ipairs(data.groups) do
        local frame = WM:CreateControl(nil, page, CT_CONTROL)
        frame.panel = page.panel   -- LAM reads width and owner off .panel, not the parent
        frame:SetWidth(page:GetWidth())
        local _, height = BuildWidgets(frame, member.options)
        tallest = zo_max(tallest, height)
        set.members[member.key] = frame
    end

    -- Only the first member is placed by the caller; the rest stack onto it.
    local first = set.members[data.groups[1].key]
    for _, frame in pairs(set.members) do
        frame:SetHeight(tallest)
        if frame ~= first then frame:SetAnchor(TOPLEFT, first, TOPLEFT, 0, 0) end
    end
    groupSets[data.key] = set

    return first, tallest
end

-- Show the member named by getFunc on LAM refresh, so any setting can drive the groupset.
local function RefreshGroupSets()
    for _, set in pairs(groupSets) do
        local shown = set.getFunc()
        for key, frame in pairs(set.members) do
            frame:SetHidden(key ~= shown)
        end
    end
end

local function BuildPage(panel, tab)
    local page = WM:CreateControl("CW_SettingsPage_" .. tab.key, panel.scroll, CT_CONTROL)
    -- LAM walks .panel upward to find the owner, so widgets built here join refresh
    -- and "Reset to defaults" as if LAM had created them.
    page.panel = panel
    page:SetWidth(panel:GetWidth() - 60)
    -- No height: LAM's scroll child fits its descendents, skipping hidden pages.
    page:SetAnchor(TOPLEFT, panel.scroll, TOPLEFT, 0, 0)

    -- Named after the nav button, so the tab stays obvious once scrolled.
    local header = LAMCreateControl.header(page, { type = "header", name = tab.label })
    header:SetAnchor(TOPLEFT, page, TOPLEFT, 0, 0)

    BuildWidgets(page, tab.options, header)

    return page
end

local function BuildTabBar(panel, tabs)
    tabBar = WM:CreateControl("CW_SettingsTabBar", panel, CT_CONTROL)
    -- LAM widgets read width and owner from the parent, so the bar claims the panel
    -- even though it sits outside the scroll.
    tabBar.panel = panel
    tabBar.data  = { type = "container" }

    -- Take the anchor LAM gave the scroll container, and push the container below us.
    local _, point, relativeTo, relativePoint, offsetX, offsetY = panel.container:GetAnchor(0)
    tabBar:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)

    local width = panel:GetWidth() - 60
    tabBar:SetDimensions(width, TAB_BAR_HEIGHT)

    panel.container:ClearAnchors()
    panel.container:SetAnchor(TOPLEFT, tabBar, BOTTOMLEFT, 0, TAB_BAR_GAP)
    panel.container:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, -3, -3)

    -- Built first, measured second: an even split clips whichever label is longest.
    local widths, total = {}, 0
    for i, tab in ipairs(tabs) do
        tabButtons[i] = LAMCreateControl.button(tabBar, {
            type = "button",
            name = tab.label,
            func = function() SelectTab(i) end,
        })
        widths[i] = tabButtons[i].button:GetLabelControl():GetTextDimensions() + TAB_BUTTON_PAD
        total = total + widths[i]
    end

    -- Distribute spare width evenly to give labels equal padding and fill the bar.
    local extra = zo_max((width - total - TAB_BUTTON_GAP * (#tabs - 1)) / #tabs, 0)

    local x = 0
    for i, button in ipairs(tabButtons) do
        local w = widths[i] + extra
        button:ClearAnchors()
        button:SetAnchor(TOPLEFT, tabBar, TOPLEFT, x, 0)
        button:SetDimensions(w, TAB_BAR_HEIGHT)
        button.button:ClearAnchors()
        button.button:SetAnchor(CENTER, button, CENTER, 0, 0)
        button.button:SetDimensions(w, TAB_BAR_HEIGHT)
        x = x + w + TAB_BUTTON_GAP
    end
end

local built = false

local function OnPanelControlsCreated(panel)
    if built or panel ~= CW.settingsPanel then return end
    built = true

    -- The placeholder exists only to fire this callback; collapse it to no space.
    CW_SettingsTabAnchor:SetHidden(true)
    CW_SettingsTabAnchor:SetDimensionConstraints(0, 0, 0, 0)
    CW_SettingsTabAnchor:SetDimensions(0, 0)

    local tabs = CW.settingsTabs

    BuildTabBar(panel, tabs)

    -- Build all pages up front; LAM ForceDefaults/RefreshPanel skip uncreated controls.
    for i, tab in ipairs(tabs) do
        tabPages[i] = BuildPage(panel, tab)
    end

    RefreshGroupSets()
    CM:RegisterCallback("LAM-RefreshPanel", RefreshGroupSets)

    SelectTab(1)
end

-- Called by CW.CreateSettings once the panel is registered and CW.settingsTabs filled.
function CW.CreateSettingsTabs(LAM)
    LAM:RegisterOptionControls("CW_SettingsPanel", {
        { type = "custom", reference = "CW_SettingsTabAnchor", minHeight = 0 },
    })
    CM:RegisterCallback("LAM-PanelControlsCreated", OnPanelControlsCreated)
end
