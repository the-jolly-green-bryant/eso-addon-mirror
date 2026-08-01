-- global namspacing
PITHKA = PITHKA or {} 
PITHKA.ui = PITHKA.ui or {}
PITHKA.ui.icon = {}

-- convenient namespacing
local api = PITHKA.common.api
local constants = PITHKA.common.constants
local utils = PITHKA.common.utils
local ui = PITHKA.ui
local data = PITHKA.data

-- debug printing
local debugEnabled = false
local function debug(msg)
    if debugEnabled then
        d('|cF0A5B0[ui.icon]|r ' .. msg )
    end
end
---------------------------------------------------------------------------------------------------------
-- Basic Icon
---------------------------------------------------------------------------------------------------------

function ui.icon.basic(settings)
    local settings = settings or {}

    -- extract settings and defaults
    local t   = settings.texture or constants.icon.texture
    local s   = settings.size    or constants.icon.size
    local c   = settings.color   or constants.icon.color
    local ttt = settings.tooltipText -- no default, existance is used to conditionally add
    local tta = settings.tooltipAnchor or constants.icon.tooltipAnchor
    local ttc = settings.tooltipColor  or constants.icon.tooltipColor
    local ttf = settings.tooltipFont   or constants.icon.tooltipFont 
    local clickFn = settings.clickFn
    
    -- create UI control
    local control = api.control.newIcon()
    control:SetTexture(t) 
    control:SetDimensions(s, s)      
    control:SetColor(unpack(c))

    -- set tooltip if defined
    if ttt then
        local ttOpenFn  = api.control.tooltipOpenFn(control, ttt, tta, ttc, ttf)
        local ttCloseFn = api.control.tooltipCloseFn(control)
        control:SetMouseEnabled(true)            
		control:SetHandler("OnMouseEnter", ttOpenFn)
		control:SetHandler( "OnMouseExit", ttCloseFn)
    end

    -- set click action if defined
    if clickFn then
        control:SetHandler("OnMouseUp", clickFn)
    end

    return control
end

---------------------------------------------------------------------------------------------------------
-- Achievement Icon
---------------------------------------------------------------------------------------------------------

function ui.icon.achievement(aid)
    local settings = {}

    -- if aid undefined then show achievement does not exist
    if aid == nil then
        settings.texture = constants.textures.X
        settings.color = constants.color.rgbGray
        settings.tooltipText = 'does not exist'
        return ui.icon.basic(settings)
    end

    -- if aid defined but doesn't exist in the API show "coming soon"
    -- used to update addon before patch is released
    if not api.achievement.released(aid) then
        settings.tooltipText = "Coming Soon"
        settings.texture = constants.textures.LOCK
        settings.tooltipAnchor = BOTTOM
        settings.tooltipColor = constants.color.rgbGray
        settings.tooltipFont = constants.font.defaultFont
    
        return ui.icon.basic(settings)
    end

    -- default handling for achievement icon
    -- aid defined and exists
    local control = ui.icon.basic(settings)

    -- set hover behavior
    local ttOpenFn = api.achievement.tooltipFn(aid)
    local ttCloseFn = api.control.tooltipCloseFn(control)
    control:SetMouseEnabled(true)            
    control:SetHandler("OnMouseEnter", ttOpenFn)
    control:SetHandler("OnMouseExit", ttCloseFn)

    -- set click behavior - Context menu with three options
    local contextMenuFn = api.achievement.clickForContextMenu(aid)
    control:SetHandler("OnMouseUp", contextMenuFn)
    
    -- OLD SINGLE CLICK BEHAVIORS (now available in context menu)
    -- local clickFn = api.achievement.clickForGroupListing(aid)
    -- local clickFn = api.achievement.clickForJournal(aid)

    -- set dynamic textures and colors (gray box or green check)
    local updateFn = function(control)
		local complete = api.achievement.IsComplete(aid)
        local t = complete and constants.textures.CHECK or constants.textures.BOX
        local c = complete and constants.color.rgbGreen or constants.color.rgbGray   
        control:SetTexture(t)
        control:SetColor(unpack(c))
    end
    control:SetHandler("OnEffectivelyShown", updateFn)
	--trigger an update immediately, because now we lazy-load screens, and if we don't set the texture
	--it'll just be the default Star texture.
	updateFn(control)
    return control
end


