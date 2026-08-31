--[[
Furniture Locator - Gamepad List Screen (item browser)

Subclasses ZO_Gamepad_ParametricList_Screen, the actual base class the
game's own gamepad screens use (confirmed directly from ESOUI source).

This screen ONLY shows a filtered, sorted item list for a given
category + style (theme) -- picking the category and style themselves
now happens via LibConsoleDialogs (FurnitureLocatorDialogs.lua), which
has real, confirmed-working A-confirm/B-back button support (unlike
this screen, which we proved KEYBIND_STRIP doesn't render/respond for).
This screen only ever needs scrolling, which IS confirmed working here,
so it keeps that responsibility and nothing else.

"< Back" (first row, scroll-to-select via the same debounced
SelectedDataChanged pattern used elsewhere) returns to the style
dialog for the current category.
]]

local ADDON_PACKAGE_NAME = "FurnitureLocator"

-- Required so "Open Furniture Locator" is what shows up under
-- Controls > Keybindings, rather than the raw action name.
ZO_CreateStringId("SI_BINDING_NAME_FURNITURE_LOCATOR_TOGGLE", "Open Furniture Locator")

FurnitureLocatorScreenClass = ZO_Gamepad_ParametricList_Screen:Subclass()

function FurnitureLocatorScreenClass:New(...)
    return ZO_Gamepad_ParametricList_Screen.New(self, ...)
end

function FurnitureLocatorScreenClass:Initialize(control)
    FURNITURE_LOCATOR_SCENE_GAMEPAD = ZO_Scene:New("FurnitureLocatorSceneGamepad", SCENE_MANAGER)

    local DONT_CREATE_TAB_BAR = ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE
    local ACTIVATE_ON_SHOW = true
    ZO_Gamepad_ParametricList_Screen.Initialize(self, control, DONT_CREATE_TAB_BAR, ACTIVATE_ON_SHOW, FURNITURE_LOCATOR_SCENE_GAMEPAD)

    local fragment = ZO_SimpleSceneFragment:New(control)
    fragment:SetHideOnSceneHidden(true)
    self.scene:AddFragment(fragment)

    -- Blocks crouch/sprint/other gameplay actions while this screen is up.
    self.scene:AddFragment(GAMEPAD_UI_MODE_FRAGMENT)

    -- Re-anchor to screen center with our own backdrop box, since the
    -- inherited template only positions against a left-side panel meant
    -- to sit next to the game's own pause-menu artwork we never trigger.
    local mask = control:GetNamedChild("Mask")
    mask:ClearAnchors()
    mask:SetDimensions(900, 900)
    mask:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)

    local backdrop = WINDOW_MANAGER:CreateControl("FurnitureLocatorScreenBackdrop", control, CT_BACKDROP)
    backdrop:SetDrawLayer(DL_BACKGROUND)
    backdrop:SetAnchor(TOPLEFT, mask, TOPLEFT, -30, -30)
    backdrop:SetAnchor(BOTTOMRIGHT, mask, BOTTOMRIGHT, 30, 30)
    backdrop:SetCenterColor(0, 0, 0, 0.85)
    backdrop:SetEdgeColor(1, 1, 1, 0.4)

    self.list = self:GetMainList()
    self.currentCategory = nil
    self.currentTheme = nil -- nil = "All Styles"

    self:InitializeHeader()
end

function FurnitureLocatorScreenClass:InitializeHeader()
    self.headerData = { titleText = "Furniture Locator" }
    ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)

    self.list:SetOnSelectedDataChangedCallback(function(_, selectedData)
        if not selectedData then
            return
        end

        -- Ignore the automatic row-1 selection that fires right after
        -- every Clear()+AddEntry()+Commit() -- not real player scrolling.
        if self.suppressNextSelectionChange then
            self.suppressNextSelectionChange = false
            return
        end

        -- Debounce: only trigger "Back" if the player actually pauses on
        -- it, not on every row highlighted while scrolling past it.
        if not selectedData.jumpBack then
            return
        end

        self.pendingBackGeneration = (self.pendingBackGeneration or 0) + 1
        local thisGeneration = self.pendingBackGeneration

        zo_callLater(function()
            if self.pendingBackGeneration ~= thisGeneration then
                return
            end
            SCENE_MANAGER:HideCurrentScene()
            if FurnitureLocatorDialogs then
                FurnitureLocatorDialogs.ShowStyleDialogForCategory(self.currentCategory)
            end
        end, 500)
    end)
end

-- Called from the style dialog (FurnitureLocatorDialogs.lua) when a
-- category+style has been picked with real A-button confirmation.
-- theme == nil means "All Styles" within that category.
function FurnitureLocatorScreenClass:ShowFiltered(category, theme)
    self.currentCategory = category
    self.currentTheme = theme
    SCENE_MANAGER:Show("FurnitureLocatorSceneGamepad")
    self:RefreshList()
end

function FurnitureLocatorScreenClass:OnShowing()
    ZO_Gamepad_ParametricList_Screen.OnShowing(self)
    SCENE_MANAGER:SetInUIMode(true)
    ZO_GamepadGenericHeader_Activate(self.header)
end

function FurnitureLocatorScreenClass:OnHiding()
    ZO_Gamepad_ParametricList_Screen.OnHiding(self)
    SCENE_MANAGER:SetInUIMode(false)
    ZO_GamepadGenericHeader_Deactivate(self.header)
end

function FurnitureLocatorScreenClass:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, function()
        SCENE_MANAGER:HideCurrentScene()
    end)
end

function FurnitureLocatorScreenClass:PerformUpdate()
    self:RefreshList()
    self.dirty = false
end

-- Shows items matching self.currentCategory (required) and
-- self.currentTheme (optional -- nil means all styles within that
-- category). A "< Back" row at the top returns to the style dialog.
function FurnitureLocatorScreenClass:RefreshList()
    self.list:Clear()

    local ok, err = pcall(function()
        local titleSuffix = self.currentCategory or "?"
        if self.currentTheme ~= nil then
            titleSuffix = string.format("%s - %s", titleSuffix, self.currentTheme)
        end
        self.headerData.titleText = string.format("Furniture Locator - %s", titleSuffix)
        ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)

        local backEntry = ZO_GamepadEntryData:New("< Back")
        backEntry.jumpBack = true
        self.list:AddEntry("ZO_GamepadMenuEntryTemplate", backEntry)

        local items = FurnitureLocator.GetAllOwnedItems()
        local filtered = {}
        for _, item in ipairs(items) do
            local categoryMatches = (item.category == self.currentCategory)
            local themeMatches = (self.currentTheme == nil) or (item.theme == self.currentTheme)
            if categoryMatches and themeMatches then
                table.insert(filtered, item)
            end
        end
        table.sort(filtered, function(a, b)
            return tostring(a.name) < tostring(b.name)
        end)

        for _, item in ipairs(filtered) do
            local entryData = ZO_GamepadEntryData:New(item.name, item.icon)
            for _, loc in ipairs(item.locations) do
                entryData:AddSubLabel(string.format("%d in %s", loc.count, loc.name))
            end
            self.list:AddEntry("ZO_GamepadMenuEntryTemplate", entryData)
        end

        -- Second "< Back" row at the bottom too, so a long list doesn't
        -- force scrolling all the way back to the top just to leave --
        -- whichever end you're nearer to, backing out is a few scrolls away.
        if #filtered > 0 then
            local bottomBackEntry = ZO_GamepadEntryData:New("< Back")
            bottomBackEntry.jumpBack = true
            self.list:AddEntry("ZO_GamepadMenuEntryTemplate", bottomBackEntry)
        end
    end)

    if not ok then
        d("Furniture Locator list ERROR: " .. tostring(err))
    end

    self.suppressNextSelectionChange = true
    self.list:Commit()

    if self.keybindStripDescriptor then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
    end
end

-- XML OnInitialized handler -- creates the single screen instance.
function FurnitureLocatorScreen_OnInitialized(control)
    FURNITURE_LOCATOR_SCREEN_GAMEPAD = FurnitureLocatorScreenClass:New(control)
end

local function OnAddOnLoaded(_, addOnName)
    if addOnName ~= ADDON_PACKAGE_NAME then
        return
    end
    EVENT_MANAGER:UnregisterForEvent("FurnitureLocatorScreenLoader", EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent("FurnitureLocatorScreenLoader", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
