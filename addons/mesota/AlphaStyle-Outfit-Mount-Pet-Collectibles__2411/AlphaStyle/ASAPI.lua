
-- API for AlphaStyle
ASAPI = {}


--- shows the AlphaStyle window
function ASAPI.ShowMains()
	if AS_Main:IsHidden() then
        SCENE_MANAGER:ToggleTopLevel(AS_Main)
		ASUI.ShowStyleSetsTab() 
	end
end


--- returns a sorted list of styles
-- each style has an id, a name and a sortKey
function ASAPI.GetStyles()
    return ASModel.GetStylesSorted() 
end

--- loads the style with the given styleId
function ASAPI.LoadStyle(styleId)
    ASModel.LoadStyleById(styleId)
end
