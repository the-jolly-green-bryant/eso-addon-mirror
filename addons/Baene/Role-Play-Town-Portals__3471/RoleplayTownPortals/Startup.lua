if not RTP then RTP = { } end
if not RTP.UI then RTP.UI = { } end
if not RTP.UTIL then RTP.UTIL = { } end

RTP.DefaultVars = {
    IndicatorOffsetX = 0,
    IndicatorOffsetY = 100,
    IndicatorMinimized = false
}

function RTP.Initialize()
    RTP.SavedVars = ZO_SavedVars:NewAccountWide("SavedVars", 1, GetWorldName(), RTP.DefaultVars)
    
    RTPIndicator:ClearAnchors()
    RTPIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RTP.SavedVars.IndicatorOffsetX, RTP.SavedVars.IndicatorOffsetY)

    RTP.IndicatorMinimizedChanged()
    
    zo_callLater(function() RTP.WaitForSceneManager() end, 500)
end

function RTP.WaitForSceneManager()
    if SCENE_MANAGER == nil then
        zo_callLater(function() RTP.WaitForSceneManager() end, 500)
        return;
    end
    
    local fragment = ZO_HUDFadeSceneFragment:New(RTPIndicator, nil, 0)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
    
    RTP.InitializeLocations()
    RTP.UI.InitializeDestinationList()
end

function RTP.IndicatorMinimizedChanged()
    RTPIndicatorTownLabel:SetHidden(RTP.SavedVars.IndicatorMinimized)
    RTPIndicatorLocationLabel:SetHidden(RTP.SavedVars.IndicatorMinimized)
    RTPIndicatorPopulationLabel:SetHidden(RTP.SavedVars.IndicatorMinimized)
    
    RTP.UpdateLocationUI()
end

function RTP.IndicatorOffsetsChanged()
    RTP.SavedVars.IndicatorOffsetX = RTPIndicator:GetLeft()
    RTP.SavedVars.IndicatorOffsetY = RTPIndicator:GetTop()
end

function RTP.OnAddOnLoaded(event, addonName)
    if addonName == RTP.ADDON_NAME then
        RTP.Initialize()
        EVENT_MANAGER:UnregisterForEvent(RTP.ADDON_NAME, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(RTP.ADDON_NAME, EVENT_ADD_ON_LOADED, RTP.OnAddOnLoaded)
