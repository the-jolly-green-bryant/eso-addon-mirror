--[[

Map Tools
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Constants
local LONG_PRESS_TIME = 300
local LONGER_PRESS_TIME = 600

-- Strings
local strings = {
    SI_KEYBINDINGS_CATEGORY_MAPTOOLS  = "|c70C0DEMap Tools|r",
    SI_BINDING_NAME_MAPTOOLS_ZOOM_OUT = "Zoom all the way out",
    SI_BINDING_NAME_MAPTOOLS_ZOOM_IN  = "Zoom all the way in",
    SI_BINDING_NAME_MAPTOOLS_STEP_OUT = "Show higher level map",
    SI_BINDING_NAME_MAPTOOLS_STEP_IN  = "Show lower level map |c777777- Mouse cursor has to be over the subzone map.|r",
    SI_BINDING_NAME_MAPTOOLS_OPEN_MAP = "Open/close map, long press for zoomed out",
}
for key, value in pairs(strings) do
   ZO_CreateStringId(key, value)
   SafeAddVersion(key, 1)
end

-- Local variables
local keyDown_time = 0
local longPress
local longerPress


-- Toggle map, long press for zoomed out all the way
function MapTools.BindingMapToggle(keyDown)
    if keyDown then
        if ZO_WorldMap_IsWorldMapShowing() then
            ZO_WorldMap_HideWorldMap()
        else
            keyDown_time = GetGameTimeMilliseconds()
            
            -- Long press function: Zoom out
            longPress = true
            local func_longPress = function() if longPress then ZO_WorldMapZoom_OnMouseWheel(-25) end end
            zo_callLater(func_longPress, LONG_PRESS_TIME)
            -- Longer press function: Go to higher level map
            if GetMapType() <= MAPTYPE_SUBZONE then
                longerPress = true
                local func_longerPress = function() if longerPress then ZO_WorldMap_MouseUp(nil, 2, true) end end
                zo_callLater(func_longerPress, LONGER_PRESS_TIME)
            end
            
            ZO_WorldMap_ShowWorldMap()
        end
    else  -- Key up
        local diff = GetGameTimeMilliseconds() - keyDown_time
        
        -- Don't do long(er) press functions if button was released earlier
        if diff < LONG_PRESS_TIME then
            longPress = false
        end
        if diff < LONGER_PRESS_TIME then
            longerPress = false
        end
    end
end