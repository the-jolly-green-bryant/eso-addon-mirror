-- CooldownTracker.lua
-- Root namespace + small shared helpers.

---@type CooldownTracker
CooldownTracker = _G["CooldownTracker"] or {}
_G["CooldownTracker"] = CooldownTracker

CooldownTracker.name = CooldownTracker.name or "CooldownTracker"
CooldownTracker.version = CooldownTracker.version or "1.0.0"
CooldownTracker.savedVarsName = CooldownTracker.savedVarsName or "CooldownTrackerSavedVars"
CooldownTracker.savedVarsVersion = CooldownTracker.savedVarsVersion or 2

CooldownTracker.savedVars = CooldownTracker.savedVars or nil
CooldownTracker.playerName = CooldownTracker.playerName or ""
CooldownTracker.refreshHandle = CooldownTracker.refreshHandle or nil
CooldownTracker.previewActive = CooldownTracker.previewActive == true

-- Module refs (assigned by the module files as they load)
CooldownTracker.TrackingUtils = CooldownTracker.TrackingUtils or nil
CooldownTracker.TrackingActions = CooldownTracker.TrackingActions or nil
CooldownTracker.FramesUtils = CooldownTracker.FramesUtils or nil
CooldownTracker.FramesActions = CooldownTracker.FramesActions or nil
CooldownTracker.SettingsUtils = CooldownTracker.SettingsUtils or nil
CooldownTracker.SettingsActions = CooldownTracker.SettingsActions or nil

--- Log a message
---@param msg string
function CooldownTracker:Log(msg)
    if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
        CHAT_SYSTEM:AddMessage(string.format("[%s] %s", self.name or "CooldownTracker", tostring(msg)))
    end
end

--- Save frame position after dragging
---@param frameId string
---@param point number
---@param x number
---@param y number
function CooldownTracker:SaveFramePosition(frameId, point, x, y)
    if not self.savedVars or not self.savedVars.frames then
        return
    end

    local frameConfig = self.savedVars.frames[frameId]
    if frameConfig then
        frameConfig.point = point
        frameConfig.x = x
        frameConfig.y = y
        self:Log(string.format("Frame '%s' position saved: x=%d, y=%d", frameId, x, y))
    end
end

--- Toggle preview mode for settings overlay
---@param enabled boolean
function CooldownTracker:SetPreviewActive(enabled)
    if self.previewActive == enabled then
        return
    end
    self.previewActive = enabled
    if self.State then
        self.State.previewActive = enabled == true
    end
    if self.RefreshUI then
        self:RefreshUI()
    end
end

--- Build dummy entries for settings preview
---@return { id: string, name: string, icon: string, remaining: number, maxDuration: number, isCooldown: boolean, stackCount: number|nil }[]
function CooldownTracker:GetPreviewEntries()
    local frame = self.FramesActions and self.FramesActions.GetFrame and self.FramesActions.GetFrame("main")
    local maxRows = frame and frame.config and frame.config.maxRows or 5
    local entries = {}
    local maxDuration = 60
    for i = 1, maxRows do
        entries[#entries + 1] = {
            id = string.format("preview_%d", i),
            name = "Preview",
            icon = "/esoui/art/icons/icon_missing.dds",
            remaining = math.max(5, maxDuration - ((i - 1) * 5)),
            maxDuration = maxDuration,
            isCooldown = true,
            stackCount = i == 1 and 3 or nil,
        }
    end
    return entries
end
