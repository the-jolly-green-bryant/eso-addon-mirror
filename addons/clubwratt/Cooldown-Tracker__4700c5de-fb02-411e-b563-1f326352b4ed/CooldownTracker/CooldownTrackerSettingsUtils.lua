-- CooldownTrackerSettingsUtils.lua
-- Small helpers/constants for the settings UI.

local CooldownTracker = _G["CooldownTracker"]

local SettingsUtils = {}
CooldownTracker.SettingsUtils = SettingsUtils

SettingsUtils.STACK_DISPLAY_ITEMS = {
    { name = "Side (yellow number)",     data = "side" },
    { name = "Overlay (buff bar white)", data = "overlay" },
}

SettingsUtils.STACK_DISPLAY_NAME_BY_VALUE = {
    side = SettingsUtils.STACK_DISPLAY_ITEMS[1].name,
    overlay = SettingsUtils.STACK_DISPLAY_ITEMS[2].name,
}

---@param icon string|nil
---@param size number|nil
---@return string
function SettingsUtils.FormatIconTag(icon, size)
    local iconSize = tonumber(size) or 32
    local texture = icon
    if type(texture) ~= "string" or texture == "" then
        texture = "/esoui/art/icons/icon_missing.dds"
    end
    return string.format("|t%d:%d:%s|t", iconSize, iconSize, texture)
end

return SettingsUtils

