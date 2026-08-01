-- CooldownTrackerFramesUtils.lua
-- Pure helpers for frame rendering/layout.

local CooldownTracker = _G["CooldownTracker"]

local FramesUtils = {}
CooldownTracker.FramesUtils = FramesUtils

FramesUtils.FALLBACK_ICON = "/esoui/art/icons/icon_missing.dds"

FramesUtils.STACK_DISPLAY_SIDE = "side"
FramesUtils.STACK_DISPLAY_OVERLAY = "overlay"

---@param mode any
---@return string
function FramesUtils.NormalizeStackDisplayMode(mode)
    if mode == FramesUtils.STACK_DISPLAY_OVERLAY or mode == FramesUtils.STACK_DISPLAY_SIDE then
        return mode
    end
    return FramesUtils.STACK_DISPLAY_SIDE
end

---@param iconSize number
---@param rowHeight number
---@return number
function FramesUtils.GetStackLabelWidth(iconSize, rowHeight)
    local stackSize = math.max(18, math.floor(iconSize * 0.6))
    local baseWidth = stackSize + 4
    local minWidth = math.max(28, rowHeight)
    return math.max(baseWidth, minWidth)
end

--- Format time remaining for display.
---@param remaining number Seconds remaining
---@return string
function FramesUtils.FormatTime(remaining)
    if remaining <= 0 then
        return ""
    elseif remaining < 10 then
        return string.format("%.1fs", remaining)
    elseif remaining < 60 then
        return string.format("%ds", math.floor(remaining))
    elseif remaining < 3600 then
        local mins = math.floor(remaining / 60)
        local secs = math.floor(remaining % 60)
        return string.format("%dm %ds", mins, secs)
    else
        local hours = math.floor(remaining / 3600)
        return string.format("%dh+", hours)
    end
end

--- Get a valid icon texture path with fallbacks.
---@param iconPath string|nil
---@return string
function FramesUtils.GetValidIcon(iconPath)
    if iconPath and type(iconPath) == "string" and iconPath ~= "" then
        return iconPath
    end
    return FramesUtils.FALLBACK_ICON
end

return FramesUtils

