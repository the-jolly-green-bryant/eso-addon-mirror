--[[
Furniture Locator - Gamepad List Screen (Milestone 3b: real controller nav)

Subclasses ZO_Gamepad_ParametricList_Screen, the actual base class the
game's own gamepad screens use (confirmed directly from ESOUI source,
esoui/ingame/leveluprewards/gamepad/leveluprewardspostclaim_gamepad.lua,
which is the minimal real example this is modeled on).

This gives real D-pad/stick navigation, selection highlighting, and
proper scrolling "for free" -- none of that is hand-rolled here, it's
all inherited from the base class.

Each row shows the item name (entry text) with a sub-label line per
location (e.g. "1 in Alinor Crest Townhouse"), via the confirmed
ZO_GamepadEntryData:AddSubLabel API.

Toggle with /flocator2 (kept separate from the Milestone 3a /flocator
plain-text preview so that one still works as a fallback if this
breaks).
]]

local ADDON_PACKAGE_NAME = "FurnitureLocator"

-- Required so "Open Furniture Locator" is what shows up under
-- Controls > Keybindings, rather than the raw action name. Must exist
-- before the Controls menu tries to display it -- placing it at file
-- scope here means it runs as soon as this file loads.
ZO_CreateStringId("SI_BINDING_NAME_FURNITURE_LOCATOR_TOGGLE", "Open Furniture Locator")

FurnitureLocatorScreenClass = ZO_Gamepad_ParametricList_Screen:Subclass()

function FurnitureLocatorScreenClass:New(...)
    return ZO_Gamepad_ParametricList_Screen.New(self, ...)
end

function FurnitureLocatorScreenClass:Initialize(control)
    FURNITURE_LOCATOR_SCENE_GAMEPAD = ZO_Scene:New("FurnitureLocatorSceneGamepad", SCENE_MANAGER)

    local CREATE_TAB_BAR = ZO_GAMEPAD_HEADER_TABBAR_CREATE
    local ACTIVATE_ON_SHOW = true
    ZO_Gamepad_ParametricList_Screen.Initialize(self, control, CREATE_TAB_BAR, ACTIVATE_ON_SHOW, FURNITURE_LOCATOR_SCENE_GAMEPAD)

    local fragment = ZO_SimpleSceneFragment:New(control)
    fragment:SetHideOnSceneHidden(true)
    self.scene:AddFragment(fragment)

    -- GAMEPAD_UI_MODE_FRAGMENT is a pre-built fragment the base game uses
    -- on every real gamepad screen -- it pushes a keybind layer that
    -- blocks crouch/sprint/other gameplay actions while active. Without
    -- it, D-pad input still reaches those raw keybinds even with
    -- SetInUIMode(true) on, which is exactly the crouch-toggling seen.
    self.scene:AddFragment(GAMEPAD_UI_MODE_FRAGMENT)

    -- The inherited template only positions the list against a fixed
    -- left-side panel meant to sit next to the game's own pause-menu
    -- background artwork -- which we never trigger, since we're not
    -- going through that menu system. Re-anchor to screen center and
    -- draw our own simple box behind it instead of fighting that coupling.
    local mask = control:GetNamedChild("Mask")
    mask:ClearAnchors()
    mask:SetDimensions(900, 900)
    mask:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)

    local backdrop = WINDOW_MANAGER:CreateControl("FurnitureLocatorScreenBackdrop", control, CT_BACKDROP)
    backdrop:SetDrawLayer(DL_BACKGROUND) -- forces it behind the list regardless of creation order
    backdrop:SetAnchor(TOPLEFT, mask, TOPLEFT, -30, -30)
    backdrop:SetAnchor(BOTTOMRIGHT, mask, BOTTOMRIGHT, 30, 30)
    backdrop:SetCenterColor(0, 0, 0, 0.85)
    backdrop:SetEdgeColor(1, 1, 1, 0.4)

    self.list = self:GetMainList()

    self:InitializeHeader()
end

-- nil selectedCategory means "All" (no filter).
function FurnitureLocatorScreenClass:InitializeHeader()
    self.selectedCategory = nil
    self:RebuildCategoryTabs()
end

-- Builds one tab per distinct category actually present among owned
-- items, plus an "All" tab, sorted alphabetically. Rebuilt from a fresh
-- data snapshot each time it's called (e.g. on PerformUpdate) so newly
-- discovered categories (from visiting a new house, etc.) show up next
-- time the screen is refreshed.
function FurnitureLocatorScreenClass:RebuildCategoryTabs()
    local categorySet = {}
    local ok = pcall(function()
        local items = FurnitureLocator.GetAllOwnedItems()
        for _, item in ipairs(items) do
            categorySet[item.category] = true
        end
    end)

    local categoryNames = {}
    if ok then
        for name, _ in pairs(categorySet) do
            table.insert(categoryNames, name)
        end
        table.sort(categoryNames)
    end

    local tabBarEntries = {
        {
            text = "All",
            callback = function()
                self.selectedCategory = nil
                self:RefreshList()
            end,
        },
    }

    for _, categoryName in ipairs(categoryNames) do
        table.insert(tabBarEntries, {
            text = categoryName,
            callback = function()
                self.selectedCategory = categoryName
                self:RefreshList()
            end,
        })
    end

    self.headerData = {
        titleText = "Furniture Locator",
        tabBarEntries = tabBarEntries,
    }
    ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)
end

-- SetInUIMode(true) is what redirects the left stick to UI navigation
-- instead of camera/character movement -- confirmed from the base
-- game's ZO_IngameSceneManager source. Without this, the stick drives
-- both the list AND the character at the same time, which is exactly
-- what was happening before this was added.
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

-- Pulls the confirmed-working data from FurnitureLocator_Data.lua and
-- populates the real scrollable list. Wrapped in pcall so a problem here
-- surfaces as a chat error rather than a UI crash.
function FurnitureLocatorScreenClass:RefreshList()
    self.list:Clear()

    local ok, err = pcall(function()
        local items = FurnitureLocator.GetAllOwnedItems()
        for _, item in ipairs(items) do
            if self.selectedCategory == nil or item.category == self.selectedCategory then
                local entryData = ZO_GamepadEntryData:New(item.name, item.icon)
                for _, loc in ipairs(item.locations) do
                    entryData:AddSubLabel(string.format("%d in %s", loc.count, loc.name))
                end
                self.list:AddEntry("ZO_GamepadMenuEntryTemplate", entryData)
            end
        end
    end)

    if not ok then
        d("Furniture Locator list ERROR: " .. tostring(err))
    end

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

    SLASH_COMMANDS["/flocator2"] = function()
        SCENE_MANAGER:Toggle("FurnitureLocatorSceneGamepad")
    end
    d("Furniture Locator real list loaded. Type /flocator2 to open/close (controller-navigable).")
end

EVENT_MANAGER:RegisterForEvent("FurnitureLocatorScreenLoader", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
