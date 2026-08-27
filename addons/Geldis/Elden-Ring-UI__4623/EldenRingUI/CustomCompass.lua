local COMPASS_WIDTH = 400    
local COMPASS_HEIGHT = 4    
local POS_X = 0            
local POS_Y = 135          
local TEXT_SCALE = 0       
local ICON_SCALE = 0.85        
local TEXT_OFFSET_Y = -15

ZO_PreHook("TryAutoTrackNextPromotionalEventCampaign", function() return true end)
ZO_ChatWindowMinBar:SetAlpha(0)
ZO_UnitFramesGroups:SetHidden(true)
ZO_AlertTextNotification:SetAlpha(0)
ZO_HousingHUDFragmentTopLevelKeybindButton:SetHidden(true)

ZO_PlayerProgress:SetAlpha(0)
ZO_PlayerProgress:SetHidden(true)
ZO_PlayerProgress.SetHidden = function() end

ZO_PlayerAttributeMountStamina:SetHidden(true)
ZO_PlayerAttributeWerewolf:SetHidden(true)
ZO_PlayerAttributeSiegeHealth:SetHidden(true)

ZO_CompassAreaOverrideLabel:SetHidden(true)

ZO_GetPrimaryPlayerNameWithSecondary = function(displayName, characterName) return displayName end

local INVbackground = ZO_SharedWideLeftPanelBackgroundLeft
INVbackground:ClearAnchors()
INVbackground:SetAnchor(LEFT, GuiRoot, LEFT, -20, -50)
INVbackground:SetDimensions(240, 650)

ZO_CharacterWindowStatsScrollScrollChildStatEntry4:SetHidden(true)
ZO_CharacterWindowStatsScrollScrollChildStatEntry5:SetHidden(true)
ZO_CharacterWindowStatsScrollScrollChildStatEntry7:SetHidden(true)
ZO_CharacterWindowStatsScrollScrollChildStatEntry8:SetHidden(true)
ZO_CharacterWindowStatsScrollScrollChildStatEntry29:SetHidden(true)
ZO_CharacterWindowStatsScrollScrollChildStatEntry30:SetHidden(true)
ZO_CharacterWindowStatsScrollScrollChildStatEntry25:SetHidden(true)
ZO_CharacterWindowStatsScrollScrollChildStatEntry23:SetHidden(true)
ZO_CharacterWindowStatsScrollScrollChildStatEntry34:SetHidden(true)
ZO_CharacterWindowStatsScrollScrollChildStatEntry35:SetHidden(true)
ZO_CharacterWindowStatsScrollScrollChildStatEntry16:SetHidden(true)
ZO_CharacterWindowStatsScrollScrollChildStatEntry33:SetHidden(true)
ZO_CharacterWindowStatsScrollScrollChildStatEntry13:SetHidden(true)
ZO_CharacterWindowStatsScrollScrollChildStatEntry22:SetHidden(true)
ZO_CharacterWindowStatsScrollScrollChildStatEntry24:SetHidden(true)
ZO_CharacterWindowStatsScrollScrollChildZO_MundusStonesStatsEntry:SetHidden(true)
ZO_CharacterWindowStatsScrollScrollChildZO_MundusStonesStatsEntryMundusIcon1:SetHidden(true)

	
RedirectTexture("esoui/art/actionbar/abilityframe64_up.dds", "EldenRingUI/Textures/abilityframe64_up.dds")
RedirectTexture("esoui/art/actionbar/abilityframe64_down.dds", "EldenRingUI/Textures/abilityframe64_up.dds")
RedirectTexture("esoui/art/miscellaneous/interactkeyframe_center.dds", "EldenRingUI/Textures/interactkeyframe_center.dds")
RedirectTexture("esoui/art/miscellaneous/interactkeyframe_edge.dds", "EldenRingUI/Textures/interactkeyframe_edge.dds")

RedirectTexture("esoui/art/compass/area2frameanim_assisted_center.dds", "EldenRingUI/Textures/empty.dds")
RedirectTexture("esoui/art/compass/area2frameanim_assisted_endcap.dds", "EldenRingUI/Textures/empty.dds")
RedirectTexture("esoui/art/compass/area2frameanim_centers.dds", "EldenRingUI/Textures/empty.dds")
RedirectTexture("esoui/art/compass/areapin2frame_ends.dds", "EldenRingUI/Textures/empty.dds")
RedirectTexture("esoui/art/compass/area2frameanim_standard_center.dds", "EldenRingUI/Textures/empty.dds")
RedirectTexture("esoui/art/compass/area2frameanim_standard_endcap.dds", "EldenRingUI/Textures/empty.dds")
RedirectTexture("esoui/art/mappins/hostile_pin.dds", "EldenRingUI/Textures/empty.dds")

RedirectTexture("esoui/art/compass/compass.dds", "EldenRingUI/Textures/compass.dds")
RedirectTexture("esoui/art/compass/compass_frame.dds", "EldenRingUI/Textures/compass.dds")
RedirectTexture("esoui/art/compass/compass_waypoint.dds", "EldenRingUI/Textures/compass_waypoint.dds")

local function RunOneTimeSetup()

    SafeAddString(SI_COMPASS_PIN_DISTANCE_FORMATTER, "", 1)       
    SafeAddString(SI_COMPASS_PIN_LONG_DISTANCE_FORMATTER, "", 1)  

    if ZO_SynergyTopLevel then
        local c = ZO_SynergyTopLevel:GetNamedChild('Container')
        if c then
            c:ClearAnchors()
            c:SetAnchor(BOTTOM, GuiRoot, BOTTOM, 40, -260)

            local a = c:GetNamedChild('Action')
            local x = c:GetNamedChild('Key')
            local i = c:GetNamedChild('Icon')

            if a then a:SetHidden(true) end

            if i then
                i:SetDimensions(60, 60)
                local e = i:GetNamedChild('Edge')
                if not e then
                    e = WINDOW_MANAGER:CreateControl('$(parent)Edge', i, CT_TEXTURE)
                    e:SetDimensions(60, 60)
                    e:ClearAnchors()
                    e:SetAnchor(TOPLEFT, i, TOPLEFT, 0, 0)
                    e:SetTexture('EldenRingUI/Textures/abilityframe64_up_old.dds')
                    e:SetDrawLayer(2)
                end
            end

            if x and i then
                x:ClearAnchors()
                x:SetAnchor(TOPLEFT, i, TOPLEFT, -45, 12)
            end
        end
    end

    if COMPASS_FRAME then
        COMPASS_FRAME.SetTargetTopOffsetY = function() end
        COMPASS_FRAME.ApplyStyle = function() end
    end
end

local frameFixer = WINDOW_MANAGER:CreateControl("ERUI_CustomCompassFixer", GuiRoot, CT_CONTROL)
frameFixer:SetHandler("OnUpdate", function()
    if ZO_CompassFrame then
        local valid, _, _, _, _, y = ZO_CompassFrame:GetAnchor(0)
        if not valid or y ~= POS_Y then
            ZO_CompassFrame:ClearAnchors()
            ZO_CompassFrame:SetAnchor(TOP, GuiRoot, TOP, POS_X, POS_Y)
        end
        
        if ZO_CompassFrame:GetWidth() ~= COMPASS_WIDTH then
            ZO_CompassFrame:SetDimensions(COMPASS_WIDTH, COMPASS_HEIGHT)
            if ZO_CompassFrameLeft then ZO_CompassFrameLeft:SetDimensions(COMPASS_HEIGHT, COMPASS_HEIGHT) end
            if ZO_CompassFrameRight then ZO_CompassFrameRight:SetDimensions(COMPASS_HEIGHT, COMPASS_HEIGHT) end
            if ZO_CompassFrameCenter then ZO_CompassFrameCenter:SetHeight(COMPASS_HEIGHT) end
        end

        if ZO_Compass and ZO_Compass:GetScale() ~= ICON_SCALE then
            ZO_Compass:SetScale(ICON_SCALE)
            ZO_Compass:SetDimensions(COMPASS_WIDTH / ICON_SCALE, COMPASS_HEIGHT / ICON_SCALE)
            ZO_Compass:ClearAnchors()
            ZO_Compass:SetAnchor(CENTER, ZO_CompassFrame, CENTER, 0, 0)
			ZO_Compass:SetAlpha(0.95)
        end
		
        if ZO_CompassCenterOverPinLabel then
            local validL, _, _, _, _, yL = ZO_CompassCenterOverPinLabel:GetAnchor(0)
            if not validL or yL ~= TEXT_OFFSET_Y or ZO_CompassCenterOverPinLabel:GetScale() ~= TEXT_SCALE then
                ZO_CompassCenterOverPinLabel:ClearAnchors()
                ZO_CompassCenterOverPinLabel:SetAnchor(BOTTOM, ZO_CompassFrame, TOP, 0, TEXT_OFFSET_Y)
                ZO_CompassCenterOverPinLabel:SetScale(TEXT_SCALE)
            end
        end
    end
end)

EVENT_MANAGER:RegisterForEvent("EldenRingUI_Compass", EVENT_PLAYER_ACTIVATED, RunOneTimeSetup)