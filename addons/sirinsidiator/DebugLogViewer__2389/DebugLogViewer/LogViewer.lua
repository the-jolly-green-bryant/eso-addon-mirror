local DLV = DebugLogViewer
local LDL = LibDebugLogger

local internal = DLV.internal
local gettext = internal.gettext
local PrepareOutput = internal.PrepareOutput

local DEFAULT_SETTINGS = internal.DEFAULT_SETTINGS
local LEVEL_TO_LOCALIZED_STRING = internal.LEVEL_TO_LOCALIZED_STRING
local LOG_VIEWER_TAG_TEMPLATE = "%s/%s"
local LOG_VIEWER_TAG_WITH_REPS_TEMPLATE = "%s/%s (%dx)"
local LOG_DATA = internal.LOG_DATA
local LOG_ENTRY_HEIGHT = 30

local TIME_FILTER_SESSION = DLV.internal.TIME_FILTER_SESSION
local TIME_FILTER_UI_LOAD = DLV.internal.TIME_FILTER_UI_LOAD
local TIME_FILTER_ALL = DLV.internal.TIME_FILTER_ALL
local TIME_FILTER_START_TIME_BY_ID = {
    [TIME_FILTER_SESSION] = LDL.SESSION_START_TIME,
    [TIME_FILTER_UI_LOAD] = LDL.UI_LOAD_START_TIME,
    [TIME_FILTER_ALL] = nil, -- useless assignment, but should make clear our intention
}
local TAG_SEPARATOR = ","
local SKIP_SCROLL_ANIMATION = true

local LogViewer = ZO_Object:Subclass()
internal.class.LogViewer = LogViewer

function LogViewer:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

function LogViewer:Initialize(saveData)
    self.saveData = saveData
    self.scrollLockedToBottom = true
    self.skipNextScrollAnimation = false

    local window = DebugLogViewerMainWindow

    self:InitializeToolbar(window)
    local filter = self:InitializeFilter(saveData)
    local list = self:InitializeEntryList(window, saveData, filter)
    self:InitializeScrollBar(window, list)
    self:InitializeWindow(window, saveData, filter, list)

    self:ApplyFilters()
end

function LogViewer:InitializeScrollBar(window, list)
    local contents = window:GetNamedChild("ListContents")
    local scrollBar = window:GetNamedChild("ListScrollBar")
    local scrollUp = scrollBar:GetNamedChild("Up")
    local scrollDown = scrollBar:GetNamedChild("Down")

    local scrollTop = CreateControlFromVirtual("$(parent)Top", scrollBar, "ZO_ScrollEndButton")
    scrollTop:SetTextureCoords(1, 0, 1, 0) -- flip it around so the texture points up
    scrollTop:SetAnchor(BOTTOM, scrollUp, TOP, 0, 0)
    scrollTop:SetDimensions(16, 16)

    local scrollBottom = CreateControlFromVirtual("$(parent)Bottom", scrollBar, "ZO_ScrollEndButton")
    scrollBottom:SetAnchor(TOP, scrollDown, BOTTOM, 0, 0)
    scrollBottom:SetDimensions(16, 16)

    scrollBar:ClearAnchors()
    scrollBar:SetAnchor(TOPLEFT, contents, TOPRIGHT, 0, 32)
    scrollBar:SetAnchor(BOTTOMLEFT, contents, BOTTOMRIGHT, 0, -32)

    scrollTop:SetHandler("OnClicked", function()
        ZO_ScrollList_ScrollDataIntoView(list.list, 1, nil, SKIP_SCROLL_ANIMATION)
    end)

    scrollBottom:SetHandler("OnClicked", function()
        ZO_ScrollList_ScrollDataIntoView(list.list, #list.list.data, nil, SKIP_SCROLL_ANIMATION)
    end)

    ZO_PreHookHandler(scrollBar, "OnValueChanged", function()
        local min, max = scrollBar:GetMinMax()
        local current = scrollBar:GetValue()
        scrollTop:SetEnabled(current > min)
        scrollBottom:SetEnabled(current < max)
        self.scrollLockedToBottom = (current == max)
    end)
end

function LogViewer:InitializeToolbar(window)
    local toolbar = window:GetNamedChild("Toolbar")

    local buttonContainer = toolbar:GetNamedChild("LevelFilterButtons")
    local levelFilterButton = {}
    self.levelFilterButton = levelFilterButton

    local resetButton = toolbar:GetNamedChild("ResetFilters")
    -- TRANSLATORS: Tooltip text for the reset filter button in the log viewer toolbar
    resetButton.tooltipText = gettext("Reset Filters")

    local optionsButton = toolbar:GetNamedChild("Options")
    -- TRANSLATORS: Tooltip text for the options button in the log viewer toolbar
    optionsButton.tooltipText = gettext("Open Settings")

    local closeButton = toolbar:GetNamedChild("Close")
    -- TRANSLATORS: Tooltip text for the close button in the log viewer toolbar
    closeButton.tooltipText = gettext("Close Window")

    local tagFilterLabel = toolbar:GetNamedChild("TagFilterLabel")
    local tagFilterBehavior = toolbar:GetNamedChild("TagFilterBehavior")
    local tagFilterBox = toolbar:GetNamedChild("TagFilterBox")
    self.tagFilterBehavior = tagFilterBehavior
    self.tagFilterBox = tagFilterBox

    -- TRANSLATORS: Text for the tag filter label in the log viewer
    tagFilterLabel:SetText(gettext("Tags:"))
    -- TRANSLATORS: Tooltip text for the tag filter label in the log viewer
    tagFilterLabel.tooltipText = gettext("Limits the visible entries to the selected tags. Can be used to blacklist or whitelist tags.")
    -- TRANSLATORS: Tooltip text for the tag filter whitelist/blacklist toggle button in the log viewer
    tagFilterBehavior.tooltipText = gettext("Toggle Blacklist/Whitelist Tags")
    -- TRANSLATORS: Placeholder text for when the tag filter input box in the log viewer is empty
    ZO_EditDefaultText_Initialize(tagFilterBox, gettext("tagA, tagB, ..."))

    local levelFilterLabel = toolbar:GetNamedChild("LevelFilterLabel")
    -- TRANSLATORS: Text for the tag level label in the log viewer
    levelFilterLabel:SetText(gettext("Levels:"))
    -- TRANSLATORS: Tooltip text for the level filter label in the log viewer
    levelFilterLabel.tooltipText = gettext("Limits the visible entries to the selected log levels.")

    local previousButton
    for i = 1, #LDL.LOG_LEVELS do
        local level = LDL.LOG_LEVELS[i]
        local button = CreateControlFromVirtual("$(parent)Level", buttonContainer, "DebugLogViewerLevelButton", level)
        if previousButton then
            button:SetAnchor(LEFT, previousButton, RIGHT, 0, 0)
        else
            button:SetAnchor(LEFT, buttonContainer, LEFT, 0, 0)
        end
        button.color = button:GetNamedChild("Color")
        button.level = level
        -- TRANSLATORS: Tooltip text for the level filter buttons in the log viewer. Placeholder is for the already localized level string
        button.tooltipText = gettext("Toggle <<1>> Level Entries", LEVEL_TO_LOCALIZED_STRING[level])
        previousButton = button
        levelFilterButton[level] = button
        self:UpdateFilterButtonColor(level)
    end

    local timeFilter = toolbar:GetNamedChild("TimeFilter")
    local timeFilterLabel = toolbar:GetNamedChild("TimeFilterLabel")
    self.timeFilter = timeFilter

    -- TRANSLATORS: Text for the time level label in the log viewer
    timeFilterLabel:SetText(gettext("Time:"))
    -- TRANSLATORS: Tooltip text for the time filter label in the log viewer
    timeFilterLabel.tooltipText = gettext("Limits the visible entries to the selected time frame.")
end

function LogViewer:InitializeFilter(saveData)
    local filter = internal.class.LogFilter:New()
    filter:SetTagSeparator(TAG_SEPARATOR)

    self.tagFilterBox:SetHandler("OnTextChanged", function(control)
        ZO_EditDefaultText_OnTextChanged(control)
        saveData.logViewer.tagFilter = control:GetText()
        filter:SetTagFilter(saveData.logViewer.tagFilter)
        self:RequestRefresh(SKIP_SCROLL_ANIMATION)
    end)

    local timeFilterComboBox = ZO_ComboBox_ObjectFromContainer(self.timeFilter)
    timeFilterComboBox:SetSortsItems(false)

    local function OnSelectionChanged(comboBox, selectedName, selectedEntry)
        saveData.logViewer.timeFilter = selectedEntry.id
        filter:SetStartTime(TIME_FILTER_START_TIME_BY_ID[selectedEntry.id])
        self:RequestRefresh(SKIP_SCROLL_ANIMATION)
    end

    local timeFilterEntries = {}
    local timeFilterEntryById = {}
    local function AddSelectionEntry(id, label)
        local entry = timeFilterComboBox:CreateItemEntry(label, OnSelectionChanged)
        entry.id = id
        timeFilterEntries[#timeFilterEntries + 1] = entry
        timeFilterEntryById[id] = label
    end

    -- TRANSLATORS: Label for limiting the log viewer to only show entries since the latest game start
    AddSelectionEntry(TIME_FILTER_SESSION, gettext("Current Session"))
    -- TRANSLATORS: Label for limiting the log viewer to only show entries since the latest UI reload
    AddSelectionEntry(TIME_FILTER_UI_LOAD, gettext("Current UI Load"))
    -- TRANSLATORS: Label for showing all available entries in the log viewer
    AddSelectionEntry(TIME_FILTER_ALL, gettext("All Available"))
    timeFilterComboBox:AddItems(timeFilterEntries)

    self.timeFilterEntryById = timeFilterEntryById
    self.timeFilterComboBox = timeFilterComboBox
    self.filter = filter
    return filter
end

function LogViewer:InitializeEntryList(window, saveData, filter)
    local list = ZO_SortFilterList:New(window)
    -- TRANSLATORS: Label when no entries are currently visible in the log viewer
    list:SetEmptyText(gettext("Nothing to show"))
    list:SetAlternateRowBackgrounds(true)
    list:SetAutomaticallyColorRows(false)

    self.refreshLogList = function()
        self.pendingRefresh = nil
        list:RefreshFilters()
        if(self.scrollLockedToBottom) then
            ZO_ScrollList_ScrollDataIntoView(list.list, #list.list.data, nil, self.skipNextScrollAnimation)
            self.skipNextScrollAnimation = false
        end
    end

    local function SetupRow(control, data)
        list:SetupRow(control, data)

        local time, formattedTime, count, level, tag, message, trace = unpack(data.log)
        message = PrepareOutput(message)
        if trace == "" then trace = nil end
        trace = PrepareOutput(trace)

        local color = saveData.logViewer.color[level]
        local r, g, b = unpack(color)

        local timeControl = control:GetNamedChild("Time")
        timeControl:SetText(data.time)
        timeControl:SetColor(r, g, b, 1)
        timeControl.tooltipText = formattedTime

        local tagControl = control:GetNamedChild("Tag")
        local tagTemplate = LOG_VIEWER_TAG_TEMPLATE
        if(count > 1) then tagTemplate = LOG_VIEWER_TAG_WITH_REPS_TEMPLATE end
        tagControl:SetText(tagTemplate:format(level, tag, count))
        tagControl:SetColor(r, g, b, 1)
        tagControl.tooltipText = data.tagTooltip

        local messageControl = control:GetNamedChild("Message")
        messageControl:SetText(message)
        messageControl:SetColor(r, g, b, 1)
        messageControl.tooltipText = message

        local stackControl = control:GetNamedChild("Stack")
        stackControl:SetColor(r, g, b, 1)
        stackControl:SetHidden(not trace)
        stackControl.tooltipText = trace
    end
    ZO_ScrollList_AddDataType(list.list, LOG_DATA, "DebugLogViewerRow", LOG_ENTRY_HEIGHT, SetupRow)
    ZO_ScrollList_EnableHighlight(list.list, "ZO_ThinListHighlight")

    function list:FilterScrollList()
        local output = ZO_ScrollList_GetDataList(self.list)
        ZO_ClearNumericallyIndexedTable(output)

        local masterList = self.masterList
        if(not masterList) then return end

        for i = 1, #masterList do
            local data = ZO_ScrollList_GetDataEntryData(masterList[i])
            local time, _, _, level, tag, message = unpack(data.log)
            if(filter:ShouldShow(time, level, tag, message)) then
                output[#output + 1] = masterList[i]
            end
        end
    end

    self.list = list
    return list
end

function LogViewer:InitializeWindow(window, saveData, filter, list)
    window.container = self
    window:ClearAnchors()
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, saveData.logViewer.window.x, saveData.logViewer.window.y)

    window:SetHandler("OnEffectivelyShown", function()
        list:RefreshFilters()
        if(self.scrollLockedToBottom) then
            ZO_ScrollList_ScrollDataIntoView(list.list, #list.list.data, nil, true)
        end
    end)

    window.OnMoveStop = function()
        saveData.logViewer.window.x, saveData.logViewer.window.y = window:GetScreenRect()
        ZO_ScrollList_UpdateScroll(self.list.list)
    end

    window.OnMouseEnterRow = function(control)
        if(control.tooltipText) then
            InitializeTooltip(InformationTooltip, control, BOTTOM, 5, 0)
            SetTooltipText(InformationTooltip, control.tooltipText)
            control = control:GetParent()
        end
        list:EnterRow(control)
    end

    window.OnMouseExitRow = function(control)
        if(control.tooltipText) then
            ClearTooltip(InformationTooltip)
            control = control:GetParent()
        end
        list:ExitRow(control)
    end

    window.OnMouseEnter = function(control)
        if(control.tooltipText) then
            InitializeTooltip(InformationTooltip, control, BOTTOM, 5, 0)
            SetTooltipText(InformationTooltip, control.tooltipText)
        end
    end

    window.OnMouseExit = function(control)
        if(control.tooltipText) then
            ClearTooltip(InformationTooltip)
        end
    end

    local linkClicked = false
    window.OnMouseUpRow = function(control, button, upInside)
        if(linkClicked) then
            linkClicked = false
            return
        end

        local data = ZO_ScrollList_GetData(control)
        internal:FireCallbacks(internal.callback.OPEN_LOG_DETAILS, data.id)
    end

    window.OnLinkClicked = function(control, linkData, linkText, button, ctrl, alt, shift, command)
        linkClicked = true
        ZO_LinkHandler_OnLinkClicked(linkText, button, control)
    end

    window.OnCloseClicked = function(control, button, upInside)
        self:Hide()
    end

    window.OnOptionsClicked = function(control, button, upInside)
        internal:FireCallbacks(internal.callback.OPEN_SETTINGS)
    end

    window.OnResetClicked = function(control, button, upInside)
        self:ResetFilters()
    end

    window.ToggleLevelFilter = function(control)
        local newState = not filter:IsLevelFiltered(control.level)
        saveData.logViewer.levelFilter[control.level] = newState
        filter:SetLevelFiltered(control.level, newState)
        control:SetState(newState and BSTATE_NORMAL or BSTATE_PRESSED)
        self:RequestRefresh(SKIP_SCROLL_ANIMATION)
    end

    window.ToggleTagFilterBehavior = function(control)
        local newState = not filter:IsTagFilterBlacklist()
        saveData.logViewer.tagFilterIsBlacklist = newState
        filter:SetTagFilterBlacklist(newState)
        control:SetState(newState and BSTATE_NORMAL or BSTATE_PRESSED)
        self:RequestRefresh(SKIP_SCROLL_ANIMATION)
    end

    self.control = window
    return window
end

function LogViewer:SetMasterList(masterList)
    self.list.masterList = masterList
end

function LogViewer:ApplyFilters()
    local saveData = self.saveData
    local filter = self.filter

    filter:SetStartTime(TIME_FILTER_START_TIME_BY_ID[saveData.logViewer.timeFilter])
    self.timeFilterComboBox:SetSelectedItem(self.timeFilterEntryById[saveData.logViewer.timeFilter])

    filter:SetLevelFilter(saveData.logViewer.levelFilter)
    for level, button in pairs(self.levelFilterButton) do
        button:SetState(saveData.logViewer.levelFilter[level] and BSTATE_NORMAL or BSTATE_PRESSED)
    end

    filter:SetTagFilter(saveData.logViewer.tagFilter)
    self.tagFilterBox:SetText(saveData.logViewer.tagFilter)

    filter:SetTagFilterBlacklist(saveData.logViewer.tagFilterIsBlacklist)
    self.tagFilterBehavior:SetState(saveData.logViewer.tagFilterIsBlacklist and BSTATE_NORMAL or BSTATE_PRESSED)
end

function LogViewer:ResetFilters()
    local saveData = self.saveData
    saveData.logViewer.levelFilter = ZO_ShallowTableCopy(DEFAULT_SETTINGS.logViewer.levelFilter)
    saveData.logViewer.tagFilter = DEFAULT_SETTINGS.logViewer.tagFilter
    saveData.logViewer.tagFilterIsBlacklist = DEFAULT_SETTINGS.logViewer.tagFilterIsBlacklist
    saveData.logViewer.timeFilter = DEFAULT_SETTINGS.logViewer.timeFilter
    self:ApplyFilters()
end

function LogViewer:UpdateFilterButtonColor(level)
    local button = self.levelFilterButton[level]
    local color = self.saveData.logViewer.color[level]
    local r, g, b = unpack(color)
    button.color:SetColor(r, g, b, 1)
end

function LogViewer:RequestRefresh(skipScrollAnimation)
    if(not self.pendingRefresh and not self.control:IsHidden()) then
        if(self.scrollLockedToBottom and skipScrollAnimation) then
            self.skipNextScrollAnimation = true
        end
        self.pendingRefresh = zo_callLater(self.refreshLogList, 0)
    end
end

function LogViewer:Show()
    self.control:SetHidden(false)
end

function LogViewer:Hide()
    self.control:SetHidden(true)
end

function LogViewer:Toggle()
    self.control:SetHidden(not self.control:IsHidden())
end

function LogViewer:IsShowing()
    return not self.control:IsHidden()
end
