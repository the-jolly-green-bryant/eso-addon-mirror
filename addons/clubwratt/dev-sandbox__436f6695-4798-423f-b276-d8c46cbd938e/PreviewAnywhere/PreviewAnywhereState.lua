-- PreviewAnywhereState.lua: Pure data initialization
-- Creates the initial state structure (defaults).

local PreviewAnywhereState = {}

function PreviewAnywhereState.Create()
    ---@type PreviewAnywhereState
    return {
        savedVars = {
            enabled = true,
        },
        pendingLinkPreviews = nil,
        pendingLinkPreviewIndex = nil,
    }
end

PreviewAnywhere.State = PreviewAnywhereState
