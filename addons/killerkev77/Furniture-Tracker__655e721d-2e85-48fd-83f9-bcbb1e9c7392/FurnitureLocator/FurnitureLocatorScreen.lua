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

    local DONT_CREATE_TAB_BAR = ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE
    local ACTIVATE_ON_SHOW = true
    ZO_Gamepad_ParametricList_Screen.Initialize(self, control, DONT_CREATE_TAB_BAR, ACTIVATE_ON_SHOW, FURNITURE_LOCATOR_SCENE_GAMEPAD)

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

function FurnitureLocatorScreenClass:InitializeHeader()
    self.headerData = { titleText = "Furniture Locator - Categories" }
    ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)

    -- Drill-down state: "categories" shows the short category list;
    -- "items" shows just that category's items (short too). Nothing here
    -- needs a button press -- scrolling to a "jump" entry (a category, or
    -- the back row) immediately switches view via this confirmed-working
    -- scroll-highlight callback.
    self.viewMode = "categories"
    self.currentCategory = nil

    self.list:SetOnSelectedDataChangedCallback(function(_, selectedData)
        if not selectedData then
            return
        end

        -- Right after any Clear()+AddEntry()+Commit(), the list
        -- auto-selects row 1 and fires this callback once -- that's not
        -- the player actually scrolling, just the rebuild settling. Acting
        -- on it caused an infinite bounce (rebuild -> auto-select row 1,
        -- which is itself a jump target -> rebuild -> ...).
        if self.suppressNextSelectionChange then
            self.suppressNextSelectionChange = false
            return
        end

        -- Debounce: only drill in if the player actually pauses on this
        -- entry, not on every row highlighted while scrolling past it.
        -- Without this, walking down the list drills into whatever you
        -- pass through, and landing on "Back" immediately bounces you
        -- back out -- which is exactly what was happening.
        self.pendingDrillGeneration = (self.pendingDrillGeneration or 0) + 1
        local thisGeneration = self.pendingDrillGeneration
        local capturedData = selectedData

        zo_callLater(function()
            if self.pendingDrillGeneration ~= thisGeneration then
                return -- selection moved on again before the pause completed
            end

            if capturedData.jumpToCategory ~= nil then
                self.viewMode = "items"
                self.currentCategory = capturedData.jumpToCategory
                self:RefreshList()
            elseif capturedData.jumpBack then
                self.viewMode = "categories"
                self.currentCategory = nil
                self:RefreshList()
            end
        end, 500)
    end)
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

-- Drill-down list builder. "categories" mode shows one short row per
-- category (fast to scroll, e.g. 14 rows instead of 800+). Scrolling to
-- one immediately drills into "items" mode for just that category
-- (via the SelectedDataChanged callback in InitializeHeader) -- a
-- "< Back to Categories" row at the top returns the same way, purely by
-- scrolling to it. No buttons, no second screen, no long list to hunt
-- through.
function FurnitureLocatorScreenClass:RefreshList()
    self.list:Clear()

    local ok, err = pcall(function()
        local items = FurnitureLocator.GetAllOwnedItems()

        if self.viewMode == "categories" then
            self.headerData.titleText = "Furniture Locator - Categories"
            ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)

            local categoryCounts = {}
            for _, item in ipairs(items) do
                categoryCounts[item.category] = (categoryCounts[item.category] or 0) + 1
            end

            local categoryNames = {}
            for name, _ in pairs(categoryCounts) do
                table.insert(categoryNames, name)
            end
            table.sort(categoryNames)

            for _, categoryName in ipairs(categoryNames) do
                local label = string.format("%s (%d)", categoryName, categoryCounts[categoryName])
                local entryData = ZO_GamepadEntryData:New(label)
                entryData.jumpToCategory = categoryName
                self.list:AddEntry("ZO_GamepadMenuEntryTemplate", entryData)
            end
        else
            self.headerData.titleText = string.format("Furniture Locator - %s", self.currentCategory)
            ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)

            local backEntry = ZO_GamepadEntryData:New("< Back to Categories")
            backEntry.jumpBack = true
            self.list:AddEntry("ZO_GamepadMenuEntryTemplate", backEntry)

            local filtered = {}
            for _, item in ipairs(items) do
                if item.category == self.currentCategory then
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

    SLASH_COMMANDS["/flocator2"] = function()
        SCENE_MANAGER:Toggle("FurnitureLocatorSceneGamepad")
    end
    d("Furniture Locator real list loaded. Type /flocator2 to open/close (controller-navigable).")
end

EVENT_MANAGER:RegisterForEvent("FurnitureLocatorScreenLoader", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
