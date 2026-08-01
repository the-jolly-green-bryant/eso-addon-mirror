FT_UI = FT_UI or {}

local MAX_VISIBLE_ROWS = 20
local ROW_HEIGHT = 28
local COL_GOLD = "|cE8C05C"
local COL_GREEN = "|c2DC50E"
local COL_RED = "|cE53935"
local COL_GRAY = "|c888888"
local COL_WHITE = "|cFFFFFF"
local COL_RESET = "|r"

FT_UI.visible = false
FT_UI.scrollOffset = 0
FT_UI.selectedRow = 1
FT_UI.rowPool = {}
FT_UI.initialized = false
FT_UI.listParent = nil
FT_UI.sceneName = "ftScene"
FT_UI.menuAdded = false
FT_UI.searchBox = nil
FT_UI.pageMode = false
FT_UI.previewVisible = false
FT_UI.previewPanel = nil
FT_UI.lastSearchSignature = nil
FT_UI.hubRetryScheduled = false

local function GetChild(name)
    if not FT_Window then
        return nil
    end
    return FT_Window:GetNamedChild(name)
end

local function MakeLabel(name, parent, font, xOffset, width, align)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetFont(font)
    label:SetColor(1, 1, 1, 1)
    label:SetAnchor(LEFT, parent, LEFT, xOffset, 0)
    label:SetDimensions(width, ROW_HEIGHT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetHorizontalAlignment(align or TEXT_ALIGN_LEFT)
    label:SetMouseEnabled(false)
    return label
end

function FT_UI:CreateRowPool()
    self.listParent = GetChild("ListArea")
    if not self.listParent then
        return
    end

    local pw = self.listParent:GetWidth()
    if pw <= 0 then
        pw = 1160
    end

    self.rowPool = {}
    for i = 1, MAX_VISIBLE_ROWS do
        local yOff = (i - 1) * ROW_HEIGHT
        local prefix = "FT_Row" .. i
        local row = WINDOW_MANAGER:CreateControl(prefix, self.listParent, CT_CONTROL)
        row:SetDimensions(pw, ROW_HEIGHT)
        row:SetAnchor(TOPLEFT, self.listParent, TOPLEFT, 0, yOff)
        row:SetMouseEnabled(true)

        local hover = WINDOW_MANAGER:CreateControl(prefix .. "Hover", row, CT_TEXTURE)
        hover:SetColor(0.91, 0.75, 0.36, 0.08)
        hover:SetAnchorFill()
        hover:SetHidden(true)
        hover:SetMouseEnabled(false)

        local selected = WINDOW_MANAGER:CreateControl(prefix .. "Selected", row, CT_TEXTURE)
        selected:SetColor(0.91, 0.75, 0.36, 0.22)
        selected:SetAnchorFill()
        selected:SetHidden(true)
        selected:SetMouseEnabled(false)

        row:SetHandler("OnMouseEnter", function() hover:SetHidden(false) end)
        row:SetHandler("OnMouseExit", function() hover:SetHidden(true) end)

        local rowIndex = i
        row:SetHandler("OnMouseUp", function(_, button)
            if button == MOUSE_BUTTON_INDEX_LEFT then
                FT_UI:OnRowClicked(rowIndex)
            end
        end)

        local iconTex = WINDOW_MANAGER:CreateControl(prefix .. "Icon", row, CT_TEXTURE)
        iconTex:SetDimensions(24, 24)
        iconTex:SetAnchor(LEFT, row, LEFT, 8, 0)
        iconTex:SetMouseEnabled(false)

        local nameLabel = MakeLabel(prefix .. "Name", row, "$(MEDIUM_FONT)|24|soft-shadow-thin", 40, 410, TEXT_ALIGN_LEFT)
        local rarityLabel = MakeLabel(prefix .. "Rarity", row, "$(MEDIUM_FONT)|24|soft-shadow-thin", 460, 150, TEXT_ALIGN_LEFT)
        local statusLabel = MakeLabel(prefix .. "Status", row, "$(MEDIUM_FONT)|24|soft-shadow-thin", 620, 130, TEXT_ALIGN_LEFT)
        local sourceLabel = MakeLabel(prefix .. "Source", row, "$(MEDIUM_FONT)|22|soft-shadow-thin", 760, 390, TEXT_ALIGN_LEFT)

        self.rowPool[i] = {
            control = row,
            selected = selected,
            iconTex = iconTex,
            nameLabel = nameLabel,
            rarityLabel = rarityLabel,
            statusLabel = statusLabel,
            sourceLabel = sourceLabel,
        }
    end
end

function FT_UI:SetupActionButtons()
    local filterBtn = GetChild("FilterBtn")
    if filterBtn then
        filterBtn:SetHandler("OnClicked", function()
            FT:CycleFilter()
            self.scrollOffset = 0
            self.selectedRow = 1
            self:RefreshAll()
        end)
        self.filterBtnLabel = WINDOW_MANAGER:CreateControl("FT_FilterBtnLabel", filterBtn, CT_LABEL)
        self.filterBtnLabel:SetFont("$(MEDIUM_FONT)|22|soft-shadow-thin")
        self.filterBtnLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        self.filterBtnLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        self.filterBtnLabel:SetAnchorFill()
        self.filterBtnLabel:SetMouseEnabled(false)
    end
end

function FT_UI:SetupScrollControls()
    local upBtn = GetChild("ScrollUpBtn")
    if upBtn then
        upBtn:SetHandler("OnClicked", function()
            FT_UI:MoveCursor(-1)
        end)
    end
    local downBtn = GetChild("ScrollDownBtn")
    if downBtn then
        downBtn:SetHandler("OnClicked", function()
            FT_UI:MoveCursor(1)
        end)
    end
end

function FT_UI:RefreshActionButtons()
    if self.filterBtnLabel then
        self.filterBtnLabel:SetText(COL_WHITE .. FT:GetCurrentFilterLabel() .. COL_RESET)
    end
end

local SEARCH_POLL_NAME = "FurnishingTracker_SearchPoll"

function FT_UI:ApplySearch()
    local signature = tostring(FT.searchText or "") .. "|" .. tostring(FT.filterIndex or 1)
    if signature == self.lastSearchSignature then
        return
    end
    self.lastSearchSignature = signature
    self.scrollOffset = 0
    self.selectedRow = 1
    FT:FilterAndSort()
    self:RefreshList()
    self:UpdateFooter()
end

function FT_UI:StartSearchPoll()
    local pollCount = 0
    EVENT_MANAGER:UnregisterForUpdate(SEARCH_POLL_NAME)
    EVENT_MANAGER:RegisterForUpdate(SEARCH_POLL_NAME, 250, function()
        pollCount = pollCount + 1
        if pollCount > 60 then
            EVENT_MANAGER:UnregisterForUpdate(SEARCH_POLL_NAME)
            return
        end
        if self.searchBox then
            local text = self.searchBox:GetText() or ""
            if text ~= (FT.searchText or "") then
                FT.searchText = text
                self:ApplySearch()
            end
        end
    end)
end

function FT_UI:StopSearchPoll()
    EVENT_MANAGER:UnregisterForUpdate(SEARCH_POLL_NAME)
end

function FT_UI:SetupSearchBox()
    local searchBoxCtrl = GetChild("SearchBox")
    if not searchBoxCtrl then
        return
    end
    local editBox = searchBoxCtrl:GetNamedChild("Edit")
    if not editBox then
        return
    end

    self.searchBox = editBox
    editBox:SetMouseEnabled(true)
    editBox:SetMaxInputChars(100)
    editBox:SetDefaultText("Search...")

    editBox:SetHandler("OnTextChanged", function(ctrl)
        FT.searchText = ctrl:GetText() or ""
        FT_UI:ApplySearch()
    end)

    editBox:SetHandler("OnEnter", function(ctrl)
        FT.searchText = ctrl:GetText() or ""
        ctrl:LoseFocus()
        FT_UI:ApplySearch()
    end)

    editBox:SetHandler("OnFocusLost", function(ctrl)
        FT_UI:StopSearchPoll()
        FT.searchText = ctrl:GetText() or ""
        FT_UI:ApplySearch()
    end)

    editBox:SetHandler("OnEscape", function(ctrl)
        ctrl:SetText("")
        FT.searchText = ""
        ctrl:LoseFocus()
        FT_UI:ApplySearch()
    end)
end

function FT_UI:ClearSearch()
    if self.searchBox then
        self.searchBox:SetText("")
        self.searchBox:LoseFocus()
    end
    FT.searchText = ""
end

function FT_UI:GetItemPreviewSystem()
    if not SYSTEMS or type(SYSTEMS.GetObject) ~= "function" then
        return nil
    end
    local ok, itemPreview = pcall(SYSTEMS.GetObject, SYSTEMS, "itemPreview")
    if ok then
        return itemPreview
    end
    return nil
end

function FT_UI:StopFurniturePreview()
    if not self.preview3DActive and not self.previewEnabledByAddon then
        return
    end
    local itemPreview = self:GetItemPreviewSystem()
    if itemPreview then
        if type(itemPreview.EndCurrentPreview) == "function" then
            pcall(itemPreview.EndCurrentPreview, itemPreview)
        end
        if type(itemPreview.SetPreviewInEmptyWorld) == "function" then
            pcall(itemPreview.SetPreviewInEmptyWorld, itemPreview, false)
        end
        if type(itemPreview.SetDynamicFramingConsumedSpace) == "function" then
            pcall(itemPreview.SetDynamicFramingConsumedSpace, itemPreview, 0, 0)
        end
    end
    if self.previewEnabledByAddon and type(DisablePreviewMode) == "function" then
        pcall(DisablePreviewMode)
    end
    self.previewEnabledByAddon = false
    self.preview3DActive = false
end

function FT_UI:TryStartFurniturePreview(entry)
    self:StopFurniturePreview()
    if not entry then
        return false
    end
    local listIndex, recipeIndex = 0, 0
    if FT and type(FT.ResolvePreviewRecipeForEntry) == "function" then
        listIndex, recipeIndex = FT:ResolvePreviewRecipeForEntry(entry)
    else
        listIndex = tonumber(entry.listIndex) or 0
        recipeIndex = tonumber(entry.recipeIndex) or 0
    end
    if listIndex <= 0 or recipeIndex <= 0 then
        return false
    end
    local itemPreview = self:GetItemPreviewSystem()
    if not itemPreview or type(itemPreview.PreviewProvisionerItemAsFurniture) ~= "function" then
        return false
    end

    if type(GetPreviewModeEnabled) == "function" and type(EnablePreviewMode) == "function" then
        local okEnabled, enabled = pcall(GetPreviewModeEnabled)
        if not okEnabled or not enabled then
            local okEnable = pcall(EnablePreviewMode, true)
            if okEnable then
                self.previewEnabledByAddon = true
            end
        end
    end

    if type(itemPreview.SetPreviewInEmptyWorld) == "function" then
        pcall(itemPreview.SetPreviewInEmptyWorld, itemPreview, true)
    end
    if type(itemPreview.SetDynamicFramingConsumedSpace) == "function" then
        -- Reserve space so the model frames away from our right panel.
        pcall(itemPreview.SetDynamicFramingConsumedSpace, itemPreview, 440, 0)
    end

    local ok = pcall(itemPreview.PreviewProvisionerItemAsFurniture, itemPreview, listIndex, recipeIndex)
    if not ok and type(itemPreview.PreviewInventoryItem) == "function" then
        local bagId = tonumber(entry.previewBagId) or 0
        local slotIndex = tonumber(entry.previewSlotIndex) or -1
        if bagId > 0 and slotIndex >= 0 then
            ok = pcall(itemPreview.PreviewInventoryItem, itemPreview, bagId, slotIndex)
        end
    end
    self.preview3DActive = ok and true or false
    return self.preview3DActive
end

function FT_UI:CreatePreviewPanel()
    if not FT_Window then
        return
    end
    local panel = WINDOW_MANAGER:CreateControl("FT_PreviewPanel", FT_Window, CT_CONTROL)
    panel:SetDimensions(430, 560)
    panel:SetAnchor(TOPRIGHT, FT_Window, TOPRIGHT, -14, 128)
    panel:SetHidden(true)
    panel:SetMouseEnabled(false)
    panel:SetDrawLayer(DL_OVERLAY)
    panel:SetDrawLevel(200)
    if panel.SetDrawTier then
        panel:SetDrawTier(DT_HIGH)
    end

    local bg = WINDOW_MANAGER:CreateControl("FT_PreviewPanelBG", panel, CT_TEXTURE)
    bg:SetAnchorFill()
    bg:SetColor(0.02, 0.02, 0.02, 1.00)

    local border = WINDOW_MANAGER:CreateControl("FT_PreviewPanelBorder", panel, CT_BACKDROP)
    border:SetAnchorFill()
    border:SetCenterColor(0, 0, 0, 0)
    border:SetEdgeColor(0.91, 0.75, 0.36, 1)
    border:SetEdgeTexture("", 2, 2, 2, 0)

    local iconTex = WINDOW_MANAGER:CreateControl("FT_PreviewIcon", panel, CT_TEXTURE)
    iconTex:SetDimensions(64, 64)
    iconTex:SetAnchor(TOPLEFT, panel, TOPLEFT, 16, 16)

    local titleLbl = WINDOW_MANAGER:CreateControl("FT_PreviewTitle", panel, CT_LABEL)
    titleLbl:SetFont("$(BOLD_FONT)|22|soft-shadow-thick")
    titleLbl:SetAnchor(TOPLEFT, iconTex, TOPRIGHT, 12, 0)
    titleLbl:SetDimensions(320, 30)
    titleLbl:SetColor(1, 1, 1, 1)

    local subtitleLbl = WINDOW_MANAGER:CreateControl("FT_PreviewSubtitle", panel, CT_LABEL)
    subtitleLbl:SetFont("$(MEDIUM_FONT)|18|soft-shadow-thin")
    subtitleLbl:SetAnchor(BOTTOMLEFT, iconTex, BOTTOMRIGHT, 12, 0)
    subtitleLbl:SetDimensions(320, 24)
    subtitleLbl:SetColor(0.75, 0.75, 0.75, 1)

    local detailLbl = WINDOW_MANAGER:CreateControl("FT_PreviewDetail", panel, CT_LABEL)
    detailLbl:SetFont("$(MEDIUM_FONT)|18|soft-shadow-thin")
    detailLbl:SetAnchor(TOPLEFT, panel, TOPLEFT, 16, 92)
    detailLbl:SetDimensions(396, 440)
    detailLbl:SetColor(1, 1, 1, 1)

    self.previewPanel = panel
    self.previewIcon = iconTex
    self.previewTitle = titleLbl
    self.previewSubtitle = subtitleLbl
    self.previewDetail = detailLbl
end

function FT_UI:ShowPreview(entry)
    if not entry or not self.previewPanel then
        return
    end

    self.previewTitle:SetText("|c" .. tostring(entry.qualityHex or "FFFFFF") .. tostring(entry.name or "?") .. COL_RESET)
    self.previewSubtitle:SetText(tostring(entry.resultName or ""))
    if entry.icon and entry.icon ~= "" then
        pcall(function() self.previewIcon:SetTexture(entry.icon) end)
        self.previewIcon:SetHidden(false)
    else
        self.previewIcon:SetHidden(true)
    end

    local status = entry.known and (COL_GREEN .. "Known" .. COL_RESET) or (COL_RED .. "Unknown" .. COL_RESET)
    local has3D = self:TryStartFurniturePreview(entry)
    local lines = {
        COL_GOLD .. "Plan:" .. COL_RESET .. " " .. tostring(entry.name or "?"),
        COL_GOLD .. "Item:" .. COL_RESET .. " " .. tostring(entry.resultName or "Unknown Result"),
        COL_GOLD .. "Rarity:" .. COL_RESET .. " " .. tostring(entry.qualityLabel or "Common"),
        COL_GOLD .. "Status:" .. COL_RESET .. " " .. status,
        COL_GOLD .. "Category:" .. COL_RESET .. " " .. tostring(entry.listName or "Unknown"),
        "",
        has3D and (COL_GREEN .. "3D Preview: Active" .. COL_RESET) or (COL_GRAY .. "3D Preview: Not available here (needs preview-capable context or plan item in backpack)" .. COL_RESET),
        "",
        COL_GOLD .. "Drop Hint:" .. COL_RESET .. " " .. tostring(entry.source or "Unknown source"),
        "",
        COL_GRAY .. "Press X again to close preview." .. COL_RESET,
    }
    self.previewDetail:SetText(table.concat(lines, "\n"))
    if self.listParent then
        self.listParent:SetHidden(true)
    end
    self.previewPanel:SetHidden(false)
    self.previewVisible = true
end

function FT_UI:HidePreview()
    self:StopFurniturePreview()
    if self.previewPanel then
        self.previewPanel:SetHidden(true)
    end
    if self.listParent then
        self.listParent:SetHidden(false)
    end
    self.previewVisible = false
    self:RefreshList()
end

function FT_UI:OnRowClicked(rowIndex)
    if self.previewVisible then
        self:HidePreview()
        return
    end
    local entry = FT.filteredList[self.scrollOffset + rowIndex]
    if entry then
        self:ShowPreview(entry)
    end
end

function FT_UI:BuildKeybindStrip()
    self.keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            keybind = "UI_SHORTCUT_NEGATIVE",
            name = GetString(SI_GAMEPAD_BACK_OPTION),
            callback = function()
                if self.previewVisible then
                    self:HidePreview()
                else
                    SCENE_MANAGER:HideCurrentScene()
                end
            end,
            sound = SOUNDS.GAMEPAD_MENU_BACK,
        },
        {
            keybind = "UI_SHORTCUT_PRIMARY",
            name = "Preview",
            callback = function()
                if self.previewVisible then
                    self:HidePreview()
                    return
                end
                self:OnRowClicked(self.selectedRow)
            end,
        },
        {
            keybind = "UI_SHORTCUT_LEFT_TRIGGER",
            name = function() return self.pageMode and "Page Up" or "Up" end,
            callback = function()
                if self.previewVisible then return end
                self:MoveCursor(self.pageMode and -MAX_VISIBLE_ROWS or -1)
            end,
        },
        {
            keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
            name = function() return self.pageMode and "Page Down" or "Down" end,
            callback = function()
                if self.previewVisible then return end
                self:MoveCursor(self.pageMode and MAX_VISIBLE_ROWS or 1)
            end,
        },
        {
            keybind = "UI_SHORTCUT_LEFT_STICK",
            name = function() return self.pageMode and "Line Mode" or "Page Mode" end,
            callback = function()
                if self.previewVisible then return end
                self.pageMode = not self.pageMode
                self:RefreshKeybindStrip()
            end,
        },
        {
            keybind = "UI_SHORTCUT_SECONDARY",
            name = "Refresh",
            callback = function()
                if self.previewVisible then return end
                FT:EnsureDataFresh(true)
                self.scrollOffset = 0
                self.selectedRow = 1
                self:RefreshAll()
            end,
        },
        {
            keybind = "UI_SHORTCUT_TERTIARY",
            name = "Search",
            callback = function()
                if self.previewVisible then return end
                if self.searchBox then
                    self.searchBox:TakeFocus()
                    self:StartSearchPoll()
                end
            end,
        },
        {
            keybind = "UI_SHORTCUT_RIGHT_STICK",
            name = "Next Filter",
            callback = function()
                if self.previewVisible then return end
                if self.searchBox then
                    self.searchBox:SetText("")
                end
                FT:CycleFilter()
                self.scrollOffset = 0
                self.selectedRow = 1
                self:RefreshAll()
            end,
        },
    }
end

function FT_UI:RefreshKeybindStrip()
    if self.visible and self.keybindStripDescriptor then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
    end
end

function FT_UI:GetNowMs()
    return (type(GetFrameTimeMilliseconds) == "function" and GetFrameTimeMilliseconds())
        or (type(GetGameTimeMilliseconds) == "function" and GetGameTimeMilliseconds())
        or 0
end

function FT_UI:GetRawLeftStickY()
    local readers = {
        _G["GetGamepadLeftStickY"],
        _G["GetGamepadOrKeyboardLeftStickY"],
        _G["GetGamepadLeftStickDeltaY"],
    }
    for _, reader in ipairs(readers) do
        if type(reader) == "function" then
            local ok, value = pcall(reader)
            if ok and type(value) == "number" then
                return value
            end
        end
    end
    return nil
end

function FT_UI:PollJoystickNavigation()
    if not self.visible or self.previewVisible then
        return
    end
    local rawY = self:GetRawLeftStickY()
    local direction = 0
    if type(rawY) == "number" then
        if rawY >= 0.35 then
            direction = -1
        elseif rawY <= -0.35 then
            direction = 1
        end
    end
    if direction == 0 then
        self.lastJoystickDirection = 0
        return
    end

    local nowMs = self:GetNowMs()
    local repeatMs = 100
    local step = self.pageMode and MAX_VISIBLE_ROWS or 1
    local changedDirection = self.lastJoystickDirection ~= direction
    if changedDirection or not self.lastJoystickMoveMs or (nowMs - self.lastJoystickMoveMs) >= repeatMs then
        self:MoveCursor(direction * step)
        self.lastJoystickMoveMs = nowMs
        self.lastJoystickDirection = direction
    end
end

function FT_UI:SetupScene()
    if not FT_Window then
        return
    end

    local windowFragment = ZO_SimpleSceneFragment:New(FT_Window)
    local scene = ZO_Scene:New(self.sceneName, SCENE_MANAGER)
    scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    -- Attach ESO item preview fragment so 3D preview can render in this custom scene.
    local itemPreview = self:GetItemPreviewSystem()
    if itemPreview and type(itemPreview.GetFragment) == "function" then
        local ok, previewFragment = pcall(itemPreview.GetFragment, itemPreview)
        if ok and previewFragment then
            scene:AddFragment(previewFragment)
        end
    end
    if GAMEPAD_MENU_SOUND_FRAGMENT then
        scene:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
    end
    scene:AddFragment(windowFragment)

    self:BuildKeybindStrip()

    scene:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_SHOWING then
            self:EnsureUICreated()
            FT:EnsureDataFresh(false)
            self.scrollOffset = 0
            self.selectedRow = 1
            self.visible = true
            KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
            EVENT_MANAGER:RegisterForUpdate("FT_JoystickNavPoll", 100, function()
                self:PollJoystickNavigation()
            end)
            self:RefreshAll()
            self:UpdateWatermark()
        elseif newState == SCENE_HIDDEN then
            self.visible = false
            self:HidePreview()
            self:StopSearchPoll()
            self:ClearSearch()
            if FT.savedVars then
                FT.savedVars.filterIndex = FT.filterIndex
            end
            pcall(function()
                KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
            end)
            EVENT_MANAGER:UnregisterForUpdate("FT_JoystickNavPoll")
        end
    end)
end

function FT_UI:RegisterInTrackingToolsHub()
    if ELDIBABALO_TRACKING_TOOLS and ELDIBABALO_TRACKING_TOOLS.Register then
        ELDIBABALO_TRACKING_TOOLS:Register(
            "Furnishing Tracker",
            "EsoUI/Art/Crafting/smithing_tabicon_research_up.dds",
            self.sceneName
        )
        if ELDIBABALO_TRACKING_TOOLS.RefreshList then
            ELDIBABALO_TRACKING_TOOLS:RefreshList()
        end
        self.hubRetryScheduled = false
        return true
    end
    if not self.hubRetryScheduled then
        self.hubRetryScheduled = true
        zo_callLater(function()
            self.hubRetryScheduled = false
            self:RegisterInTrackingToolsHub()
        end, 1500)
    end
    return false
end

function FT_UI:AddToMainMenu()
    -- Intentionally no direct main-menu registration.
    -- This addon should only appear inside Tracking Tools hub.
    self:RegisterInTrackingToolsHub()
    self.menuAdded = true
end

function FT_UI:UpdateWatermark()
    local playerLabel = GetChild("FooterPlayer")
    if not playerLabel then
        return
    end
    local displayName = GetDisplayName and GetDisplayName() or ""
    playerLabel:SetText(COL_GRAY .. displayName .. COL_RESET)
end

function FT_UI:EnsureUICreated()
    if self.uiCreated then
        return
    end
    self:CreateRowPool()
    self:SetupScrollControls()
    self:SetupActionButtons()
    self:SetupSearchBox()
    self:CreatePreviewPanel()
    self:UpdateWatermark()
    self.uiCreated = true
end

function FT_UI:Initialize()
    if self.initialized then
        return
    end
    self:SetupScene()
    self.initialized = true
end

function FT_UI:LateInit()
    self:RegisterInTrackingToolsHub()
end

function FT_UI:Show()
    if not FT_Window then
        return
    end
    self:Initialize()
    self:RegisterInTrackingToolsHub()
    SCENE_MANAGER:Show(self.sceneName)
end

function FT_UI:Hide()
    if SCENE_MANAGER:IsShowing(self.sceneName) then
        SCENE_MANAGER:HideCurrentScene()
    end
    self.visible = false
end

function FT_UI:Toggle()
    if not FT_Window then
        return
    end
    self:Initialize()
    self:RegisterInTrackingToolsHub()
    if SCENE_MANAGER:IsShowing(self.sceneName) then
        SCENE_MANAGER:HideCurrentScene()
    else
        SCENE_MANAGER:Show(self.sceneName)
    end
end

function FT_UI:RefreshAll()
    self:RefreshActionButtons()
    self:RefreshList()
    self:UpdateFooter()
end

function FT_UI:RefreshList()
    local dataList = FT.filteredList
    local noData = (#dataList == 0)
    for i = 1, MAX_VISIBLE_ROWS do
        local dataIndex = self.scrollOffset + i
        local entry = dataList[dataIndex]
        local slot = self.rowPool[i]
        if not slot then
            break
        end
        slot.selected:SetHidden(i ~= self.selectedRow)
        if noData and i == 1 then
            slot.control:SetHidden(false)
            slot.selected:SetHidden(true)
            slot.iconTex:SetHidden(true)
            slot.nameLabel:SetText(COL_GRAY .. "No learned furnishing plans on this character yet." .. COL_RESET)
            slot.rarityLabel:SetText("")
            slot.statusLabel:SetText("")
            slot.sourceLabel:SetText(COL_GRAY .. "Press Square to refresh after learning a plan." .. COL_RESET)
        elseif noData then
            slot.control:SetHidden(true)
            slot.selected:SetHidden(true)
        elseif entry then
            slot.control:SetHidden(false)
            if entry.icon and entry.icon ~= "" then
                pcall(function() slot.iconTex:SetTexture(entry.icon) end)
                slot.iconTex:SetHidden(false)
            else
                slot.iconTex:SetHidden(true)
            end

            slot.nameLabel:SetText("|c" .. tostring(entry.qualityHex or "FFFFFF") .. tostring(entry.name or "") .. COL_RESET)
            slot.rarityLabel:SetText(tostring(entry.qualityLabel or "Common"))
            local tier = entry.qualityTier or entry.quality or 1
            if tier >= 5 then
                slot.rarityLabel:SetColor(0.93, 0.79, 0.36, 1)
            elseif tier >= 4 then
                slot.rarityLabel:SetColor(0.63, 0.18, 0.97, 1)
            elseif tier >= 3 then
                slot.rarityLabel:SetColor(0.23, 0.57, 1.0, 1)
            elseif tier >= 2 then
                slot.rarityLabel:SetColor(0.18, 0.77, 0.05, 1)
            else
                slot.rarityLabel:SetColor(1, 1, 1, 1)
            end
            if entry.known then
                slot.statusLabel:SetText(COL_GREEN .. "Known" .. COL_RESET)
            else
                slot.statusLabel:SetText(COL_RED .. "Unknown" .. COL_RESET)
            end
            slot.sourceLabel:SetText(COL_GRAY .. tostring(entry.source or "") .. COL_RESET)
        else
            slot.control:SetHidden(true)
            slot.selected:SetHidden(true)
        end
    end
end

function FT_UI:GetDataCount()
    return #FT.filteredList
end

function FT_UI:GetMaxOffset()
    return math.max(0, self:GetDataCount() - MAX_VISIBLE_ROWS)
end

function FT_UI:MoveCursor(direction)
    local totalItems = self:GetDataCount()
    if totalItems == 0 then
        return
    end

    local absIndex = self.scrollOffset + self.selectedRow
    local newAbs = absIndex + direction
    if newAbs < 1 then newAbs = 1 end
    if newAbs > totalItems then newAbs = totalItems end

    local visibleRows = math.min(MAX_VISIBLE_ROWS, totalItems)
    if newAbs <= self.scrollOffset then
        self.scrollOffset = newAbs - 1
        self.selectedRow = 1
    elseif newAbs > self.scrollOffset + visibleRows then
        self.scrollOffset = newAbs - visibleRows
        self.selectedRow = visibleRows
    else
        self.selectedRow = newAbs - self.scrollOffset
    end

    self:RefreshList()
    self:UpdateFooter()
end

function FT_UI:KeyScrollUp()
    if self.visible then
        self:MoveCursor(-1)
    end
end

function FT_UI:KeyScrollDown()
    if self.visible then
        self:MoveCursor(1)
    end
end

function FT_UI:UpdateFooter()
    local label = GetChild("FooterStats")
    if not label then
        return
    end

    local totalData = self:GetDataCount()
    local absRow = 0
    if totalData > 0 then
        absRow = self.scrollOffset + self.selectedRow
    end
    local posText = COL_GRAY .. "  [" .. tostring(absRow) .. "/" .. tostring(totalData) .. "]" .. COL_RESET
    local total, _, known, unknown = FT:GetStats()

    if total <= 0 then
        label:SetText(
            "No learned furnishing plans found on this character yet."
            .. " Learn a furnishing plan, then press Refresh."
            .. posText
        )
        return
    end

    label:SetText(
        "Total: " .. tostring(total)
        .. "   " .. COL_GREEN .. "Known: " .. tostring(known) .. COL_RESET
        .. "   " .. COL_RED .. "Unknown: " .. tostring(unknown) .. COL_RESET
        .. posText
    )
end
