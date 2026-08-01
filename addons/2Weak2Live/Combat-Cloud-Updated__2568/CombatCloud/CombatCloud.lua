local LMP = LibMediaProvider

local function SavePosition(panel)
        local anchor = { panel:GetAnchor(0) }
        local dimensions = { panel:GetDimensions() }
        local panelSettings = CombatCloudSettings.panels[panel:GetName()]
        panelSettings.point = anchor[2]
        panelSettings.relativePoint = anchor[4]
        panelSettings.offsetX = anchor[5]
        panelSettings.offsetY = anchor[6]
        panelSettings.dimensions = dimensions
end

---------------------------------------------------------------------------------------------------------------------------------------
    --//ADDON LOADED//--
---------------------------------------------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent('CombatCloud_EVENT_ADD_ON_LOADED', EVENT_ADD_ON_LOADED, function (eventCode, addOnName)
        if(addOnName ~= 'CombatCloud') then return end

        EVENT_MANAGER:UnregisterForEvent('CombatCloud_EVENT_ADD_ON_LOADED', EVENT_ADD_ON_LOADED)
        CombatCloudSettings = ZO_SavedVars:NewAccountWide('CombatCloud_Settings', 15, nil, CombatCloudDefaults)
        CombatCloud.RegisterMedia(LMP) --register fonts
        CombatCloud.RegisterOptions()  --register libAddonMenu-2.0

        --Set panels to player configured settings
        for k, s in pairs (CombatCloudSettings.panels) do
            if _G[k] ~= nil then
                _G[k]:ClearAnchors()
                _G[k]:SetAnchor(s.point, CombatCloud, s.relativePoint, s.offsetX, s.offsetY)
                _G[k]:SetDimensions(unpack(s.dimensions))
                _G[k]:SetHandler('OnMouseUp', SavePosition)
                _G[k .. '_Label']:SetFont(LMP:Fetch('font', CombatCloudSettings.fontFace) .. '|26|' .. CombatCloudSettings.fontOutline)
                _G[k .. '_Label']:SetText(CombatCloudLocalization.panelTitles[k])
            else
                CombatCloudSettings.panels[k] = nil
            end
        end

        --Allow mouse resizing of panels
        CombatCloud_Incoming:SetResizeHandleSize(MOUSE_CURSOR_RESIZE_NS)
        CombatCloud_Outgoing:SetResizeHandleSize(MOUSE_CURSOR_RESIZE_NS)

        --Pool Manager
        local poolManager = CombatCloud_PoolManager:New()
        for _, v in pairs(CombatCloudConstants.poolType) do -- Create a pool for each type
            poolManager:RegisterPool(v, CombatCloud_Pool:New(v))
        end

        --Event Listeners
        CombatCloud_CombatEventListener:New()
        CombatCloud_AlertEventListener:New()
        CombatCloud_PointsAllianceEventListener:New()
        CombatCloud_PointsExperienceEventListener:New()
        CombatCloud_PointsChampionEventListener:New()
        CombatCloud_ResourcesPowerEventListener:New()
        CombatCloud_ResourcesUltimateEventListener:New()
        CombatCloud_ResourcesPotionEventListener:New()

        --Event Viewers
        CombatCloud_CombatCloudEventViewer:New(poolManager, LMP)
        CombatCloud_CombatHybridEventViewer:New(poolManager, LMP)
        CombatCloud_CombatScrollEventViewer:New(poolManager, LMP)
        CombatCloud_CombatEllipseEventViewer:New(poolManager, LMP)
        CombatCloud_AlertEventViewer:New(poolManager, LMP)
        CombatCloud_CrowdControlEventViewer:New(poolManager, LMP)
        CombatCloud_PointEventViewer:New(poolManager, LMP)
        CombatCloud_ResourceEventViewer:New(poolManager, LMP)

        --Hide ingame active combat tips
        ZO_ActiveCombatTips:SetHidden(CombatCloudSettings.toggles.hideIngameTips)

        if (CombatCloudSettings.toggles.showAlertCleanse or
            CombatCloudSettings.toggles.showAlertBlock or
            CombatCloudSettings.toggles.showAlertExploit or
            CombatCloudSettings.toggles.showAlertInterrupt or
            CombatCloudSettings.toggles.showAlertDodge) then
            SetSetting(SETTING_TYPE_ACTIVE_COMBAT_TIP, 0, ACT_SETTING_ALWAYS)
        end

    end)
