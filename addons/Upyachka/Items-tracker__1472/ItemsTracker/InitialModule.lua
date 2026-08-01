-- This module initializes mandatory attributes.
-- Addon root. Used to configure all parts. Only calls to other parts.
Up_ItemsTracker = {}
-- name of addon required by Up_AddonConfigurator.
Up_ItemsTracker.name = "ItemsTracker"
-- version of addon required by Up_SettingsController.
Up_ItemsTracker.version = 2
-- Any default data placed here.
Up_ItemsTracker.Default = {}
-- default settings for addon. Required by Up_SettingsController.
Up_ItemsTracker.Default.Settings = {
    UI = {
        Window = {
            Padding = 11, -- Padding for window content.
            Position = { OffsetX = 33, OffsetY = 33 }, -- Point on screen to align TOPLEFT point of floating window.
            Background = { Enabled = true }, -- Configuration of backdrop.
        },
        UpdateInterval = 200, -- Interval for displayed update.
        Enabled = true, -- Means that info displaying enabled.
    }
}
