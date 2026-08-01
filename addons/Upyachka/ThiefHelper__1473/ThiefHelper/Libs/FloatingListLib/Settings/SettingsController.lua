--Register with LibStub
local MAJOR, MINOR = "Up_SettingsController", 1
local LIB, _ = LibStub:NewLibrary(MAJOR, MINOR)
if not LIB then return end -- avoid double loading.

--- Handles addon settings.

---
-- Use this method to create reference to virtual table with settings of your object.
-- @param object instance of your object.
-- ATTENTION: this method requires next fields for your object:
-- @field #string object.name An unique string identifier of your object.
-- @field #integer object.version An number which represents version of your settings. Used for handling
-- of backward incompatible settings.
-- @field #table object.Default.Settings Table which contains default settings of this object.
-- For example: object.name = "KevinInfoWindow"
-- Loads settings from saved variables or uses default.
--
function LIB.loadSettings(addon)
    addon.Settings = ZO_SavedVars:New(addon.name .. "_settings", addon.version, nil, addon.Default.Settings)
end
