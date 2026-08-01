local ABF = AetheriusBadgeFilter
local internal = ABF.internal
local gettext = internal.gettext

local BUTTON_NORMAL_TEXTURE = "EsoUI/Art/TreeIcons/store_indexicon_trophy_up.dds"
local BUTTON_PRESSED_TEXTURE = "EsoUI/Art/TreeIcons/store_indexicon_trophy_down.dds"
local r, g, b = ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()

local GROUP_ENTRY = 1
local BADGE_ENTRY = 2

local guildRoster = GUILD_ROSTER_KEYBOARD
local guildRosterScene = SCENE_MANAGER:GetScene("guildRoster")

local function RefreshFilters()
    guildRoster:RefreshFilters()
end

local function CreateEntry(entry, entryType)
    if(type(entry) ~= "table") then
        entry = {name = entry}
    end
    entry.type = entryType
    return entry
end

function internal.CreateGroupEntry(entry)
    return CreateEntry(entry, GROUP_ENTRY)
end

function internal.CreateBadgeEntry(entry)
    return CreateEntry(entry, BADGE_ENTRY)
end

local FilterWindow = ZO_InitializingObject:Subclass()
ABF.class.FilterWindow = FilterWindow

function FilterWindow:Initialize(window, saveData, defaultData, filter)
    self.window = window
    self.saveData = saveData
    self.defaultData = defaultData
    self.filter = filter

    local control = window:GetNamedChild("Filter")
    self.labelControl = control:GetNamedChild("Label")
    -- TRANSLATORS: Title of the filter window in the guild roster menu
    self.labelControl:SetText(gettext("Badge Filter"))
    self.listControl = control:GetNamedChild("List")
    self.fragment = ZO_SimpleSceneFragment:New(window)
    self.control = control

    local resizing = false
    control:SetMovable(not saveData.locked)
    control:SetResizeHandleSize(not saveData.locked and 5 or 0)
    control:SetHandler("OnMoveStop", function() self:SavePosition() end)
    control:SetHandler("OnResizeStart", function() resizing = true end)
    control:SetHandler("OnUpdate", function() if(resizing) then self:HandleResize() end end)
    control:SetHandler("OnResizeStop", function() self:HandleResize() self:SavePosition() resizing = false end)

    self:InitializeButtons(saveData)
    self:InitializeScrollList(self.listControl, filter)
    self:LoadPosition()
end

function FilterWindow:InitializeButtons(saveData)
    local optionsButton = self.control:GetNamedChild("Options")
    optionsButton:SetHandler("OnClicked", function(control)
        ClearMenu()

        -- TRANSLATORS: Entry in the options menu of the filter window for rescanning the roster for badges
        AddCustomMenuItem(gettext("Refresh Badges"), function() self:Update(true) end)

        if(saveData.showScannedBadges) then
            -- TRANSLATORS: Entry in the options menu of the filter window for showing badges from the data file for the current guild
            AddCustomMenuItem(gettext("Show Defined Badges"), function()
                saveData.showScannedBadges = false
                self:Update()
            end)
        else
            -- TRANSLATORS: Entry in the options menu of the filter window for showing badges found in the roster for the current guild
            AddCustomMenuItem(gettext("Show Scanned Badges"), function()
                saveData.showScannedBadges = true
                self:Update()
            end)
        end

        if(saveData.showMemberCount) then
            -- TRANSLATORS: Entry in the options menu of the filter window for hiding the member count on each badge
            AddCustomMenuItem(gettext("Hide Member Count"), function()
                saveData.showMemberCount = false
                self:Update()
            end)
        else
            -- TRANSLATORS: Entry in the options menu of the filter window for showing the member count on each badge
            AddCustomMenuItem(gettext("Showing Member Count"), function()
                saveData.showMemberCount = true
                self:Update()
            end)
        end

        if(self:IsLocked()) then
            -- TRANSLATORS: Entry in the options menu of the filter window to unlock the position of the window so it can be moved around
            AddCustomMenuItem(gettext("Unlock Window"), function() self:Unlock() end)
        else
            -- TRANSLATORS: Entry in the options menu of the filter window to lock the position of the window
            AddCustomMenuItem(gettext("Lock Window"), function() self:Lock() end)
            -- TRANSLATORS: Entry in the options menu of the filter window to reset the position of the window
            AddCustomMenuItem(gettext("Reset Window"), function() self:ResetPosition() end)
        end

        -- TRANSLATORS: Entry in the options menu of the filter window to hide the window
        AddCustomMenuItem(gettext("Hide Window"), function()
            self:Disable()
        end)

        ShowMenu(optionsButton)
    end)
    self.optionsButton = optionsButton

    local toggleWindowButton = self.window:GetNamedChild("Button")
    toggleWindowButton:SetHandler("OnClicked", function(control)
        if(self:IsEnabled()) then
            self:Disable()
        else
            self:Enable()
        end
    end)
    toggleWindowButton:SetHandler("OnMouseEnter", function(control)
        InitializeTooltip(InformationTooltip)
        InformationTooltip:ClearAnchors()
        InformationTooltip:SetOwner(control, BOTTOM, 0, 0)
        -- TRANSLATORS: Tooltip for the button in the guild roster menu to show or hide the filter window
        InformationTooltip:AddLine(gettext("Toggle Aetherius Badge Filter Window"), "", r, g, b)
    end)
    toggleWindowButton:SetHandler("OnMouseExit", function(control)
        ClearTooltip(InformationTooltip)
    end)
    self.toggleWindowButton = toggleWindowButton

    -- properly initialize the button state
    if(self:IsEnabled()) then
        self:Enable()
    else
        self:Disable()
    end
end

local function ShowTooltip(rowControl, name, description)
    InitializeTooltip(InformationTooltip)
    InformationTooltip:ClearAnchors()
    InformationTooltip:SetOwner(rowControl, RIGHT, -5, 0)
    InformationTooltip:AddLine(name, "ZoFontGameBold", r, g, b)
    if(description) then
        InformationTooltip:AddLine(description, "", r, g, b)
    end
end

function FilterWindow:InitializeScrollList(listControl, filter)
    local saveData = self.saveData

    local function InitializeGroupRow(rowControl, entry)
        local nameControl = rowControl:GetNamedChild("Name")
        nameControl:SetText(entry.name)

        local function FadeIn()
            ShowTooltip(rowControl, entry.name, entry.description)
        end

        local function FadeOut()
            ClearTooltip(InformationTooltip)
        end

        rowControl:SetHandler("OnMouseEnter", FadeIn)
        rowControl:SetHandler("OnMouseExit", FadeOut)
    end

    local function DestroyGroupRow(rowControl)
        ZO_ObjectPool_DefaultResetControl(rowControl)
    end

    local function InitializeBadgeRow(rowControl, entry)
        local nameControl = rowControl:GetNamedChild("Name")
        local name = entry.name
        if(entry.color) then
            name = string.format("|c%s%s|r", entry.color, name)
        end
        if(saveData.showMemberCount) then
            nameControl:SetText(string.format("%s (%d)", name, entry.count))
        else
            nameControl:SetText(name)
        end

        local highlight = rowControl:GetNamedChild("Highlight")
        if not highlight.animation then
            highlight.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual("ShowOnMouseOverLabelAnimation", highlight)
        end

        local alpha = filter:GetBadge(entry.name) and 0.5 or 0
        highlight:SetAlpha(alpha)
        highlight.animation:GetFirstAnimation():SetAlphaValues(alpha, 1)

        local function FadeIn()
            highlight.animation:PlayForward()
            ShowTooltip(rowControl, entry.name, entry.description)
        end

        local function FadeOut()
            highlight.animation:PlayBackward()
            ClearTooltip(InformationTooltip)
        end

        rowControl:SetHandler("OnMouseEnter", FadeIn)
        rowControl:SetHandler("OnMouseExit", FadeOut)

        rowControl:SetHandler("OnMouseUp", function(control, button, isInside, ctrl, alt, shift, command)
            if(isInside and button == MOUSE_BUTTON_INDEX_LEFT) then
                if(self.memberEditor) then
                    if(not self.memberEditor:HasBadge(entry.name)) then
                        self.memberEditor:AwardBadge(entry.name, nil, entry.color)
                    end
                else
                    local selected = filter:GetBadge(entry.name)
                    if(not shift) then
                        if(filter:GetFilteredCount() > 1) then
                            selected = false
                        end
                        filter:ClearAll()
                    end
                    filter:SetBadge(entry.name, not selected)
                    RefreshFilters()
                    ZO_ScrollList_RefreshVisible(listControl)
                end
                PlaySound("Click")
            end
        end)
    end

    local function DestroyBadgeRow(rowControl)
        local highlight = rowControl:GetNamedChild("Highlight")
        highlight.animation:PlayFromEnd(highlight.animation:GetDuration())
        ZO_ObjectPool_DefaultResetControl(rowControl)
    end

    ZO_ScrollList_Initialize(listControl)
    ZO_ScrollList_AddDataType(listControl, GROUP_ENTRY, "AetheriusBadgeFilterGroupTemplate", 30, InitializeGroupRow, nil, nil, DestroyGroupRow)
    ZO_ScrollList_AddDataType(listControl, BADGE_ENTRY, "AetheriusBadgeFilterBadgeTemplate", 24, InitializeBadgeRow, nil, nil, DestroyBadgeRow)
    ZO_ScrollList_AddResizeOnScreenResize(listControl)

    self.emptyRow = CreateControlFromVirtual("$(parent)EmptyRow", listControl, "ZO_SortFilterListEmptyRow")
    -- TRANSLATORS: Text shown in the filter window when there are no badges for the current guild
    GetControl(self.emptyRow, "Message"):SetText(gettext("No Badges found"))
end

function FilterWindow:Update(forced)
    local filter = self.filter
    if(self:IsShowing()) then
        filter:CollectBadges(forced)

        local listControl = self.listControl
        local scrollData = ZO_ScrollList_GetDataList(listControl)
        ZO_ScrollList_Clear(listControl)

        local list = filter:GetListEntries()
        self.emptyRow:SetHidden(#list > 0)
        for _, entry in ipairs(list) do
            scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(entry.type, ZO_ShallowTableCopy(entry))
        end

        ZO_ScrollList_Commit(listControl)
        RefreshFilters()
    end
end

function FilterWindow:IsShowing()
    local filter = self.filter
    return guildRosterScene:IsShowing() and filter:SupportsBadges() and self:IsEnabled()
end

function FilterWindow:AddToScene(scene)
    scene:AddFragment(self.fragment)
end

function FilterWindow:RemoveFromScene(scene)
    scene:RemoveFragment(self.fragment)
end

function FilterWindow:SavePosition()
    local control, saveData = self.control, self.saveData
    saveData.x, saveData.y = control:GetScreenRect()
    saveData.width, saveData.height = control:GetDimensions()
end

function FilterWindow:HandleResize()
    ZO_ScrollList_Commit(self.listControl)
end

function FilterWindow:LoadPosition()
    local control, saveData = self.control, self.saveData
    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, saveData.x, saveData.y)
    control:SetDimensions(saveData.width, saveData.height)
    self:HandleResize()
end

function FilterWindow:ResetPosition()
    local saveData, defaultData = self.saveData, self.defaultData
    saveData.x, saveData.y = defaultData.x, defaultData.y
    saveData.width, saveData.height = defaultData.width, defaultData.height
    self:LoadPosition()
end

function FilterWindow:IsLocked()
    return self.saveData.locked
end

function FilterWindow:Lock()
    self.saveData.locked = true
    self.control:SetMovable(false)
    self.control:SetResizeHandleSize(0)
end

function FilterWindow:Unlock()
    self.saveData.locked = false
    self.control:SetMovable(true)
    self.control:SetResizeHandleSize(5)
end

function FilterWindow:IsEnabled()
    return self.saveData.enabled
end

function FilterWindow:Enable()
    self.saveData.enabled = true
    self.control:SetHidden(false)
    self.toggleWindowButton:SetNormalTexture(BUTTON_PRESSED_TEXTURE)
    self.toggleWindowButton:SetPressedTexture(BUTTON_NORMAL_TEXTURE)
    self:Update()
end

function FilterWindow:Disable()
    self.saveData.enabled = false
    self.control:SetHidden(true)
    self.toggleWindowButton:SetNormalTexture(BUTTON_NORMAL_TEXTURE)
    self.toggleWindowButton:SetPressedTexture(BUTTON_PRESSED_TEXTURE)
    RefreshFilters()
end

function FilterWindow:GetBadgeList()
    return self.listControl
end

function FilterWindow:ResetBadgeList()
    local list = self.listControl
    list:SetParent(self.control)
    list:ClearAnchors()
    list:SetAnchor(TOPLEFT, self.labelControl, BOTTOMLEFT, 0, 5)
    list:SetAnchor(BOTTOMRIGHT, self.control, BOTTOMRIGHT, -25, -10)
    self:HandleResize()
end

function FilterWindow:SetMemberEditor(memberEditor)
    self.memberEditor = memberEditor
end