-- UI Module
-- Main UI state container - actual implementation in UI/ subdirectory
-- Dependencies: All UI submodules (Window, Tabs, Content, Components)
-- Note: This file only contains the state object. UI functionality is in:
--   - UI/Window.lua: Window creation and management
--   - UI/Tabs.lua: Tab navigation and rendering
--   - UI/Content.lua: Content area rendering for each tab
--   - UI/Components.lua: Reusable UI components

NMGuildHall.UI = {
    window = nil,
    currentTab = "home",
    isShowing = false,
    scrollLists = {},
    teleportButtonPool = nil,
    campaignRowPool = nil,
    maxVisibleButtons = 0,
    actionButtonCounter = 0,
    teleportButtonCounter = 0,
    campaignRowCounter = 0,
    groupContentInitialized = false,
    -- Dialog keybind descriptor persistence
    dialogKeybindDescriptor = nil,
    queueStatusLabel = nil,
    queueStatusCampaignId = nil,
    queueStatusIsGroup = false,
    -- Memory management
    registeredEvents = {},
    activeControls = {}
}

local UI = NMGuildHall.UI
