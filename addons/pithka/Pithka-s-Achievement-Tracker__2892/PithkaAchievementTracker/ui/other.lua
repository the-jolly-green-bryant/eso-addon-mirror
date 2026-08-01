-- global namspacing
PITHKA = PITHKA or {} 
PITHKA.ui = PITHKA.ui or {}
PITHKA.ui.other = {}

-- convenient namespacing
local api = PITHKA.common.api
local constants = PITHKA.common.constants
local utils = PITHKA.common.utils
local ui = PITHKA.ui


---------------------------------------------------------------------------------------------------------
-- Spacer
---------------------------------------------------------------------------------------------------------

function ui.other.spacer(width, height)
    -- extract settings and defaults
	local w      = width  or constants.icon.size
	local h      = height or constants.icon.size
    
    -- create UI control
    local control = api.control.newLabel()
    control:SetDimensions(w, h)
	control:SetHidden(true)
    return control
end

function ui.other.line(width, height)
	local control = api.control.newTexture()
	control:SetDimensions(width, height)
	control:SetColor(unpack(constants.color.rgbGray))
	return control
end

-- ---------------------------------------------------------------------------------------------------------
-- -- Card
-- ---------------------------------------------------------------------------------------------------------

-- function ui.other.card(settings)
--     -- extract settings and defaults
--     local width = settings.width or 500
--     local height = settings.height or 100
--     local padding = settings.padding or 10
--     local backgroundColor = settings.backgroundColor or {0, 0, 0, 0.8}
--     local borderColor = settings.borderColor or constants.color.rgbBlue
--     local mouseEnabled = settings.mouseEnabled or true
    
--     -- create main container
--     local container = api.control.newControl()
--     container:SetDimensions(width, height)
--     container:SetMouseEnabled(mouseEnabled)
    
--     -- create background
--     local bg = api.control.newBackdrop()
--     bg:SetEdgeColor(unpack(borderColor))
--     bg:SetCenterColor(unpack(backgroundColor))
--     bg:SetEdgeTexture("EsoUI/Art/ChatWindow/chatBorder.dds", 16, 16)
--     bg:SetCenterTexture("EsoUI/Art/ChatWindow/chatBackground.dds")
--     bg:SetAnchor(TOPLEFT, container, TOPLEFT, -padding, -padding)
--     bg:SetAnchor(BOTTOMRIGHT, container, BOTTOMRIGHT, padding, padding)
--     container:AddChild(bg)
    
--     -- create content container
--     local content = api.control.newControl()
--     content:SetAnchor(TOPLEFT, bg, TOPLEFT, padding, padding)
--     content:SetAnchor(BOTTOMRIGHT, bg, BOTTOMRIGHT, -padding, -padding)
--     container:AddChild(content)
    
--     -- add mouse enter/exit handlers if enabled
--     if mouseEnabled then
--         container:SetHandler("OnMouseEnter", function(self)
--             bg:SetCenterColor(0.1, 0.1, 0.1, 0.8)
--         end)
--         container:SetHandler("OnMouseExit", function(self)
--             bg:SetCenterColor(unpack(backgroundColor))
--         end)
--     end
    
--     -- add methods to container
--     function container:AddChild(child)
--         content:AddChild(child)
--         return self
--     end
    
--     function container:GetContent()
--         return content
--     end
    
--     return container
-- end


---------------------------------------------------------------------------------------------------------
-- QR Code
---------------------------------------------------------------------------------------------------------

function ui.other.qrCode(settings)
    settings.size       = settings.size or 300
    settings.parent     = settings.parent or PITHKA_GUI
    settings.payload    = settings.payload or "Hello, World!" -- for dynamic payloads use callbacks elsewhere

    -- create control
	local control = api.control.newTexture()
    control:SetDimensions(settings.size, settings.size)      
    control:SetDrawTier(DT_LOW)
    control:SetAnchor(CENTER, settings.parent, CENTER, 0, 0)
    control:SetParent(settings.parent)
    
    -- tooltip
    local ttt = settings.tooltipText -- no default, existance is used to conditionally add
    local tta = settings.tooltipAnchor or constants.icon.tooltipAnchor
    local ttc = settings.tooltipColor  or constants.icon.tooltipColor
    local ttf = settings.tooltipFont   or constants.icon.tooltipFont 
 
    if ttt then
        local ttOpenFn  = api.control.tooltipOpenFn(control, ttt, tta, ttc, ttf)
        local ttCloseFn = api.control.tooltipCloseFn(control)
        control:SetMouseEnabled(true)            
        control:SetHandler("OnMouseEnter", ttOpenFn)
        control:SetHandler( "OnMouseExit", ttCloseFn)
    end

    -- Initial draw
    --LibQRCode.DrawQRCode(control, settings.payload)
    return control
end
