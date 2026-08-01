--Register with LibStub
local MAJOR, MINOR = "Up_UiTools", 2
local LIB, _ = LibStub:NewLibrary(MAJOR, MINOR)
if not LIB then return end -- avoid double loading.

--- Used to help with configuration of UI.

-- Default size of shadows.
LIB.DEFAULT_INSET_SIZE = 16

-- Returns content wrapper for any window
function LIB.getContainer(widget)
    local container = widget.Container
    -- Check inner container/backdrop and use it as parent if its exists
    if container == nil then container = widget.Backdrop end
    if container == nil then container = widget.Root end
    if container == nil then container = widget end
    return container
end

-- Returns window backdrop for any window.
function LIB.getBackdrop(widget)
    local container = widget.Backdrop
    if container == nil then container = widget.Root end
    if container == nil then container = widget end
    return container
end

-- Returns root control for any window.
function LIB.getRoot(widget)
    local container = widget.Root
    if container == nil then container = widget end
    return container
end

-- Returns content wrapper for any window
function LIB.addShadow(widget)
    local insetSize = LIB.DEFAULT_INSET_SIZE
    widget:SetInsets(insetSize, insetSize, -insetSize, -insetSize)
    widget:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_BG_edge.dds", 256, 256, insetSize)
    widget:SetCenterTexture("EsoUI/Art/ChatWindow/chat_BG_center.dds")
    widget:SetAlpha(0.7)
    widget:SetDrawLayer(0) -- TODO check better solution
    return widget
end

-- Configures window as floating.
function LIB.configureAsFloat(widget, position)
    widget:SetMovable(true)
    local function onMoveStop(self)
        position.OffsetX = self:GetLeft()
        position.OffsetY = self:GetTop()
    end

    widget:SetHandler("OnMoveStop", onMoveStop)
end

-- Sets widget to switch visibility depends on compass visibility.
function LIB.configureToHideTogetherWithCompass(widget)
    -- Check that compass visible and follows by its state.
    local function hideWithCompass()
        if ZO_CompassFrame then
            widget:SetHidden(ZO_CompassFrame:IsHidden())
        end
    end
    EVENT_MANAGER:RegisterForUpdate(widget:GetName() .. "VisibilityHandler", 100, hideWithCompass)
end
