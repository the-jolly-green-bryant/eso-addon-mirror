
--- Local imports:
local ProvidersController = LibStub:GetLibrary("Up_ProvidersController")
local SettingsController = LibStub:GetLibrary("Up_SettingsController")
local UiFactory = LibStub:GetLibrary("Up_UiFactory")
local UiController = LibStub:GetLibrary("Up_UiController")
local FloatingWindowPresenter = LibStub:GetLibrary("Up_FloatingWindowPresenter")
local AddonConfigurator = LibStub:GetLibrary("Up_AddonConfigurator")
local SettingsMenu = LibStub:GetLibrary("Up_WindowSettingsMenu")

--- Local self-reference.
local self = Up_ItemsTracker

--- Other addons can add their custom providers.
self.ProvidersController = ProvidersController:new()

--- Allows to remember link and restore set of trackings after logout.
-- @param link link of item.
--
local function rememberLink(link)
    local history = self.Settings.History or {}
    self.Settings.History = history
    history[#history + 1] = link
end

--- Adds hook to extend native context menu of inventory slot with addon item.
local function configureInventoryContextHook()
    local function addProvider(link)
        --d("Added for tracking: " .. link)
        self.ProvidersController:registerProvider("ItemInfo" .. link, ItemDataProvider:new(link))
        rememberLink(link)
    end
    --- Adds new provider of details for seleted item.
    -- @param rowControl selected control data.
    local function showItemInfoRowControl(rowControl)
        local bagId = rowControl.bagId
        local slotIndex = rowControl.slotIndex
        if bagId and slotIndex then
            local link = GetItemLink(bagId, slotIndex)
            addProvider(link)
        end
    end

    --- Callback for item selection.
    -- @param rowControl selected control data.
    local function addProviderStartItemHook(rowControl)
        local function postponed()
            AddMenuItem(GetString(ITEMS_TRACKER_ADD_TO_TRACKING), function() showItemInfoRowControl(rowControl) end, MENU_ADD_OPTION_LABEL)
            ShowMenu()
        end
        zo_callLater(postponed, 50) -- To avoid double call of ShowMenu()
    end
    ZO_PreHook("ZO_InventorySlot_ShowContextMenu", addProviderStartItemHook)
end

--- Function callback to initialize addon on first loading. Required by Up_AddonConfigurator
function self.onLoaded(event)
    SettingsController.loadSettings(self)
    self.UiController = UiController:new(self.Settings, self)
    self.UiController:initializeUI()
    SettingsMenu.createMenu(self, GetString(ITEMS_TRACKER_ADDON_NAME))

    local history = self.Settings.History
    if history then
        for _, link in pairs(history) do
            self.ProvidersController:registerProvider("ItemInfo" .. link, ItemDataProvider:new(link))
        end
    end

    local presenter = FloatingWindowPresenter:new(self, self.UI.Window, UiFactory, "general", self.Settings)
    presenter:start()

    configureInventoryContextHook()
end

--- Removes all remembered providers.
function self.cleanHistory()
    self.Settings.History = {}
end

--- Invocation of Up_AddonConfigurator to bind onLoaded as callback for first time of addon loading.
AddonConfigurator.configureOnLoadedCallback(self)
