local AttributeScaler = KhajiitFengShui.AttributeScaler;
local PanelUtils = KhajiitFengShui.PanelUtils;

---@class KhajiitFengShuiPanelDefinition
---@field id string Unique identifier for the panel
---@field controlName string Name of the game control to track
---@field label? string String constant for localized label
---@field width? number|function Width in pixels or function that returns width
---@field height? number|function Height in pixels or function that returns height
---@field anchorPoint? integer Anchor point constant (TOPLEFT, CENTER, etc)
---@field anchorRelativePoint? integer Relative anchor point on GuiRoot
---@field anchorApply? fun(panel: KhajiitFengShuiPanel, left: number, top: number) Custom anchor application function
---@field scaleApply? fun(panel: KhajiitFengShuiPanel, scale: number) Custom scale application function
---@field preApply? fun(control: userdata, hasCustomPosition: boolean) Called before applying position
---@field postApply? fun(control: userdata, hasCustomPosition: boolean) Called after applying position
---@field condition? fun(): boolean Function to check if panel should be created
---@field fragmentGlobalName? string Global name for ZO_HUDFadeSceneFragment (user hide toggle)
---@field supportsUserHidden? boolean If true, settings expose hide checkbox using fragmentGlobalName

---@type KhajiitFengShuiPanelDefinition[]
local definitions =
{
    {
        id = "infamy";
        controlName = "ZO_HUDInfamyMeter";
        label = KFS_LABEL_INFAMY;
    };
    {
        id = "telvar";
        controlName = "ZO_HUDTelvarMeter";
        label = KFS_LABEL_TELVAR;
    };
    {
        id = "volendrung";
        controlName = "ZO_HUDDaedricEnergyMeter";
        label = KFS_LABEL_VOLENDRUNG;
    };
    {
        id = "equipment";
        controlName = "ZO_HUDEquipmentStatus";
        label = KFS_LABEL_EQUIPMENT;
        width = 64;
        height = 64;
    };
    {
        id = "battleground";
        controlName = "ZO_BattlegroundHUDFragmentTopLevel";
        label = KFS_LABEL_BATTLEGROUND;
        height = 200;
    };
    {
        id = "advZoneHUDTopLevel";
        controlName = "KhajiitFengShui_AdvZoneHUD";
        label = KFS_LABEL_ADV_ZONE_HUD;
        width = 260;
        height = 56;
        fragmentGlobalName = "ADVENTURE_ZONE_HUD_FRAGMENT";
        supportsUserHidden = true;
        condition = function ()
            return GetControl("KhajiitFengShui_AdvZoneHUD") ~= nil
                and GetControl("ZO_AdvZoneHUD_TopLevel") ~= nil
                and _G["ADVENTURE_ZONE_HUD_FRAGMENT"] ~= nil;
        end;
    };
    {
        id = "advZoneHUDTracker";
        controlName = "ZO_AdvZoneHUDTracker";
        label = KFS_LABEL_ADV_ZONE_TRACKER;
        width = function ()
            local control = GetControl("ZO_AdvZoneHUDTracker");
            if control then
                local w = control:GetWidth();
                if w and w > 0 then
                    return w;
                end;
            end;
            return 320;
        end;
        height = function ()
            local control = GetControl("ZO_AdvZoneHUDTracker");
            if control then
                local h = control:GetHeight();
                if h and h > 0 then
                    return h;
                end;
            end;
            return 220;
        end;
        fragmentGlobalName = "ADVENTURE_ZONE_HUD_TRACKER_FRAGMENT";
        supportsUserHidden = true;
        condition = function ()
            return GetControl("ZO_AdvZoneHUDTracker") ~= nil and _G["ADVENTURE_ZONE_HUD_TRACKER_FRAGMENT"] ~= nil;
        end;
    };
    {
        id = "actionbar";
        controlName = "ZO_ActionBar1";
        label = KFS_LABEL_ACTIONBAR;
    };
    {
        id = "subtitles";
        controlName = "KhajiitFengShui_Subtitles";
        label = KFS_LABEL_SUBTITLES;
        width = function ()
            local control = GetControl("KhajiitFengShui_Subtitles");
            if control then
                return control:GetWidth() or 256;
            end;
            return 256;
        end;
        height = function ()
            local control = GetControl("KhajiitFengShui_Subtitles");
            if control then
                return control:GetHeight() or 80;
            end;
            return 80;
        end;
        condition = function ()
            return GetControl("KhajiitFengShui_Subtitles") ~= nil;
        end;
    };
    {
        id = "objective";
        controlName = "KhajiitFengShui_ObjectiveMeter";
        label = KFS_LABEL_OBJECTIVE;
        width = function ()
            local control = GetControl("KhajiitFengShui_ObjectiveMeter");
            if control then
                return control:GetWidth() or 128;
            end;
            return 128;
        end;
        height = function ()
            local control = GetControl("KhajiitFengShui_ObjectiveMeter");
            if control then
                return control:GetHeight() or 128;
            end;
            return 128;
        end;
        condition = function ()
            return GetControl("KhajiitFengShui_ObjectiveMeter") ~= nil;
        end;
        postApply = function (control)
            local gameControl = GetControl("ZO_ObjectiveCaptureMeter");
            if gameControl and ZO_ObjectiveCaptureMeterFrame then
                ZO_ObjectiveCaptureMeterFrame:SetAnchor(BOTTOM, gameControl, BOTTOM, 0, 0);
            end;
        end;
    };
    {
        id = "playerInteract";
        controlName = "KhajiitFengShui_PlayerInteract";
        label = KFS_LABEL_PLAYER_INTERACT;
        width = function ()
            local control = GetControl("KhajiitFengShui_PlayerInteract");
            if control then
                return control:GetWidth() or 870;
            end;
            return 870;
        end;
        height = function ()
            local control = GetControl("KhajiitFengShui_PlayerInteract");
            if control then
                return control:GetHeight() or 30;
            end;
            return 30;
        end;
        condition = function ()
            return GetControl("KhajiitFengShui_PlayerInteract") ~= nil;
        end;
    };
    {
        id = "synergy";
        controlName = "KhajiitFengShui_Synergy";
        label = KFS_LABEL_SYNERGY;
        width = function ()
            local control = GetControl("KhajiitFengShui_Synergy");
            if control then
                return control:GetWidth() or 200;
            end;
            return 200;
        end;
        height = function ()
            local control = GetControl("KhajiitFengShui_Synergy");
            if control then
                return control:GetHeight() or 50;
            end;
            return 50;
        end;
        anchorPoint = BOTTOM;
        anchorRelativePoint = BOTTOM;
        condition = function ()
            return GetControl("KhajiitFengShui_Synergy") ~= nil;
        end;
    };
    {
        id = "compass";
        controlName = "ZO_CompassFrame";
        label = KFS_LABEL_COMPASS;
        width = function ()
            local rootWidth = GuiRoot:GetWidth() or 0;
            return zo_clamp(rootWidth * 0.35, 400, 800);
        end;
        height = function ()
            if IsInGamepadPreferredMode() then
                return ZO_COMPASS_FRAME_HEIGHT_GAMEPAD or 0;
            end;
            return ZO_COMPASS_FRAME_HEIGHT_KEYBOARD or 0;
        end;
        anchorPoint = TOP;
        anchorRelativePoint = TOP;
        preApply = function ()
            if COMPASS_FRAME and COMPASS_FRAME.ApplyStyle then
                COMPASS_FRAME:ApplyStyle();
            end;
        end;
        postApply = function (control)
            if COMPASS_FRAME and COMPASS_FRAME.ApplyStyle then
                zo_callLater(function ()
                                 if control and control.SetAnchor then
                                     COMPASS_FRAME:ApplyStyle();
                                 end;
                             end, 0);
            end;
        end;
        scaleApply = function (panel, scale)
            local control = panel and panel.control;
            if not control then
                return;
            end;

            panel.compassDefaults = panel.compassDefaults or {};
            local defaults = panel.compassDefaults;

            if not defaults.baseWidth or defaults.baseWidth == 0 then
                defaults.baseWidth = control.GetWidth and control:GetWidth() or 0;
            end;
            if not defaults.baseHeight or defaults.baseHeight == 0 then
                defaults.baseHeight = control.GetHeight and control:GetHeight() or 0;
            end;
            if ZO_CompassFrameLeft and (not defaults.leftWidth or defaults.leftWidth == 0) then
                defaults.leftWidth = ZO_CompassFrameLeft:GetWidth();
            end;
            if ZO_CompassFrameRight and (not defaults.rightWidth or defaults.rightWidth == 0) then
                defaults.rightWidth = ZO_CompassFrameRight:GetWidth();
            end;
            if ZO_CompassCenterOverPinLabel then
                if not defaults.labelScale or defaults.labelScale == 0 then
                    defaults.labelScale = ZO_CompassCenterOverPinLabel:GetTransformScale() or 1;
                end;
                if not defaults.labelAnchorPoint then
                    defaults.labelAnchorPoint = BOTTOM;
                    defaults.labelAnchorTarget = ZO_Compass or control;
                    defaults.labelAnchorRelativePoint = TOP;
                    defaults.labelOffsetX = 0;
                    defaults.labelOffsetY = -5;
                end;
            end;

            local baseWidth = defaults.baseWidth or 0;
            local baseHeight = defaults.baseHeight or 0;
            if baseWidth == 0 or baseHeight == 0 then
                return;
            end;

            local targetWidth = zo_round(baseWidth * scale);
            local targetHeight = zo_round(baseHeight * scale);
            targetWidth = zo_max(targetWidth, 1);
            targetHeight = zo_max(targetHeight, 1);

            control:SetDimensionConstraints(targetWidth, targetHeight, targetWidth, targetHeight);
            control:SetDimensions(targetWidth, targetHeight);

            if ZO_Compass then
                ZO_Compass:SetDimensionConstraints(targetWidth, targetHeight, targetWidth, targetHeight);
                ZO_Compass:SetDimensions(targetWidth, targetHeight);
            end;

            local sideHeight = targetHeight;
            local leftWidth = defaults.leftWidth or 0;
            local rightWidth = defaults.rightWidth or 0;

            if ZO_CompassFrameLeft then
                ZO_CompassFrameLeft:SetDimensions(leftWidth, sideHeight);
            end;
            if ZO_CompassFrameRight then
                ZO_CompassFrameRight:SetDimensions(rightWidth, sideHeight);
            end;
            if ZO_CompassFrameCenter then
                local centerWidth = zo_max(targetWidth - (leftWidth + rightWidth), 0);
                ZO_CompassFrameCenter:SetDimensions(centerWidth, sideHeight);
            end;

            if ZO_CompassCenterOverPinLabel then
                ZO_CompassCenterOverPinLabel:SetTransformScale((defaults.labelScale or 1) * scale);
                ZO_CompassCenterOverPinLabel:ClearAnchors();
                ZO_CompassCenterOverPinLabel:SetAnchor(
                    defaults.labelAnchorPoint or BOTTOM,
                    defaults.labelAnchorTarget or control,
                    defaults.labelAnchorRelativePoint or TOP,
                    defaults.labelOffsetX or 0,
                    defaults.labelOffsetY or -5
                );
            end;

            if COMPASS_FRAME and COMPASS_FRAME.ApplyStyle then
                COMPASS_FRAME:ApplyStyle();
            end;
        end;
    };
    {
        id = "playerProgress";
        controlName = "ZO_PlayerProgress";
        label = KFS_LABEL_PLAYER_PROGRESS;
        postApply = function ()
            if PLAYER_PROGRESS_BAR then
                PLAYER_PROGRESS_BAR:RefreshTemplate();
            end;
        end;
    };
    {
        id = "reticle";
        controlName = "ZO_ReticleContainerInteract";
        label = KFS_LABEL_RETICLE;
    };
    {
        id = "lootHistory";
        controlName = "ZO_LootHistoryControl_Gamepad";
        label = KFS_LABEL_LOOT_HISTORY;
        width = 280;
        height = 400;
        condition = IsInGamepadPreferredMode;
        anchorPoint = BOTTOMLEFT;
        anchorRelativePoint = BOTTOMLEFT;
        postApply = function (control)
            if not LOOT_HISTORY_GAMEPAD then
                return;
            end;

            local function refreshBuffer(buffer)
                if not buffer then
                    return;
                end;

                buffer.anchor = ZO_Anchor:New(BOTTOMLEFT, control, BOTTOMLEFT);
            end;

            refreshBuffer(LOOT_HISTORY_GAMEPAD.lootStream);
            refreshBuffer(LOOT_HISTORY_GAMEPAD.lootStreamPersistent);
        end;
    };
    {
        id = "tutorials";
        controlName = "ZO_TutorialHudInfoTipGamepad";
        label = KFS_LABEL_TUTORIALS;
        condition = IsInGamepadPreferredMode;
    };
    {
        id = "alerts";
        controlName = "ZO_AlertTextNotification";
        label = KFS_LABEL_ALERTS;
        width = 600;
        height = 56;
        postApply = function (control, hasCustomPosition)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, " ");
            local alertText = control:GetChild(1);
            if IsInGamepadPreferredMode() and ZO_AlertTextNotificationGamepad then
                alertText = ZO_AlertTextNotificationGamepad:GetChild(1);
            end;
            if alertText and hasCustomPosition then
                alertText.fadingControlBuffer.anchor = ZO_Anchor:New(TOPRIGHT, control, TOPRIGHT);
            end;
        end;
    };
    {
        id = "activeCombatTips";
        controlName = "KhajiitFengShui_CombatTips";
        label = KFS_LABEL_COMBAT_TIPS;
        width = function ()
            local control = GetControl("KhajiitFengShui_CombatTips");
            if control then
                return control:GetWidth() or 250;
            end;
            return 250;
        end;
        height = function ()
            local control = GetControl("KhajiitFengShui_CombatTips");
            if control then
                return control:GetHeight() or 20;
            end;
            return 20;
        end;
        condition = function ()
            return GetControl("KhajiitFengShui_CombatTips") ~= nil;
        end;
        preApply = function (control, hasCustomPosition)
            local gameControl = GetControl("ZO_ActiveCombatTipsTip");
            if gameControl then
                gameControl:SetAlpha(0);
            end;

            if not hasCustomPosition and gameControl then
                gameControl:ClearAnchors();
                gameControl:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0);
            end;
        end;
        postApply = function (control, hasCustomPosition)
            if ACTIVE_COMBAT_TIP_SYSTEM and ACTIVE_COMBAT_TIP_SYSTEM.ApplyStyle then
                ACTIVE_COMBAT_TIP_SYSTEM:ApplyStyle();
            end;
        end;
    };
    {
        id = "questTracker";
        controlName = "ZO_FocusedQuestTrackerPanel";
        label = KFS_LABEL_QUEST_TRACKER;
        anchorPoint = BOTTOMRIGHT;
        anchorRelativePoint = BOTTOMRIGHT;
        width = function ()
            local control = GetControl("ZO_FocusedQuestTrackerPanel");
            if control then
                return control:GetWidth() or 300;
            end;
            return 300;
        end;
        height = function ()
            local control = GetControl("ZO_FocusedQuestTrackerPanel");
            if control then
                return control:GetHeight() or 200;
            end;
            return 200;
        end;
        condition = function ()
            return not IsInGamepadPreferredMode() and GetControl("ZO_FocusedQuestTrackerPanel") ~= nil;
        end;
        scaleApply = function (panel, scale)
            local control = panel and panel.control;
            if not control then
                return;
            end;
            -- Apply scale to quest tracker panel and ensure children inherit scale
            PanelUtils.enableInheritScaleRecursive(control);
            control:SetTransformScale(scale);

            -- Also scale the container if it exists (similar to how buff controls work)
            local container = GetControl("ZO_FocusedQuestTrackerPanelContainer");
            if container then
                container:SetInheritScale(true);
                PanelUtils.enableInheritScaleRecursive(container);
                container:SetTransformScale(scale);
            end;
        end;
    };
    {
        id = "questTrackerGamepad";
        controlName = "ZO_FocusedQuestTrackerPanelContainerQuestContainer";
        label = KFS_LABEL_QUEST_TRACKER;
        anchorPoint = BOTTOMRIGHT;
        anchorRelativePoint = BOTTOMRIGHT;
        width = function ()
            local control = GetControl("ZO_FocusedQuestTrackerPanelContainerQuestContainer");
            if control then
                return control:GetWidth() or 300;
            end;
            return 300;
        end;
        height = function ()
            local control = GetControl("ZO_FocusedQuestTrackerPanelContainerQuestContainer");
            if control then
                return control:GetHeight() or 200;
            end;
            return 200;
        end;
        condition = function ()
            return IsInGamepadPreferredMode() and GetControl("ZO_FocusedQuestTrackerPanelContainerQuestContainer") ~= nil;
        end;
        scaleApply = function (panel, scale)
            local control = panel and panel.control;
            if not control then
                return;
            end;

            PanelUtils.enableInheritScaleRecursive(control);
            control:SetTransformScale(scale);


            local mainContainer = GetControl("ZO_FocusedQuestTrackerPanelContainer");
            if mainContainer then
                mainContainer:SetInheritScale(true);
                PanelUtils.enableInheritScaleRecursive(mainContainer);
                mainContainer:SetTransformScale(scale);
            end;


            if IsInGamepadPreferredMode() then
                local zoneStoryTracker = GetControl("ZO_ZoneStoryTracker");
                if zoneStoryTracker then
                    PanelUtils.enableInheritScaleRecursive(zoneStoryTracker);
                    zoneStoryTracker:SetTransformScale(scale);
                end;


                local promoTracker = GetControl("ZO_PromotionalEventTracker_TL");
                if promoTracker then
                    PanelUtils.enableInheritScaleRecursive(promoTracker);
                    promoTracker:SetTransformScale(scale);
                end;


                local houseTracker = GetControl("ZO_HouseInformationTrackerTopLevel");
                if houseTracker then
                    PanelUtils.enableInheritScaleRecursive(houseTracker);
                    houseTracker:SetTransformScale(scale);
                end;
            end;
        end;
        postApply = function (control, hasCustomPosition)
            if hasCustomPosition and IsInGamepadPreferredMode() then
                local questContainer = GetControl("ZO_FocusedQuestTrackerPanelContainerQuestContainer");
                if not questContainer then
                    questContainer = control;
                end;

                local zoneStoryTracker = GetControl("ZO_ZoneStoryTracker");
                if zoneStoryTracker and questContainer then
                    zoneStoryTracker:ClearAnchors();
                    zoneStoryTracker:SetAnchor(BOTTOMRIGHT, questContainer, BOTTOMRIGHT, 0, 0);
                    zoneStoryTracker:SetInheritScale(true);
                end;


                local anchorTarget = zoneStoryTracker or questContainer;


                local promoTracker = GetControl("ZO_PromotionalEventTracker_TL");
                local promoVisible = promoTracker and not promoTracker:IsHidden();

                if promoTracker and anchorTarget then
                    promoTracker:ClearAnchors();
                    promoTracker:SetAnchor(BOTTOMRIGHT, anchorTarget, BOTTOMRIGHT, 0, 151);
                    promoTracker:SetInheritScale(true);
                end;

                local houseTracker = GetControl("ZO_HouseInformationTrackerTopLevel");
                if houseTracker then
                    houseTracker:ClearAnchors();
                    if promoVisible and promoTracker then
                        local promoHeight = promoTracker:GetHeight() or 0;
                        houseTracker:SetAnchor(BOTTOMRIGHT, promoTracker, BOTTOMRIGHT, 0, promoHeight);
                    else
                        houseTracker:SetAnchor(BOTTOMRIGHT, anchorTarget, BOTTOMRIGHT, 0, 151);
                    end;
                    houseTracker:SetInheritScale(true);
                end;
            end;
        end;
    };
    {
        id = "centerAnnounce";
        controlName = "ZO_CenterScreenAnnounce";
        label = KFS_LABEL_CENTER_ANNOUNCE;
        width = 600;
        height = 100;
        postApply = function ()
            if CENTER_SCREEN_ANNOUNCE and CENTER_SCREEN_ANNOUNCE.ApplyStyle then
                CENTER_SCREEN_ANNOUNCE:ApplyStyle();
            end;
        end;
    };
    {
        id = "stealthIcon";
        controlName = "ZO_ReticleContainerStealthIcon";
        label = KFS_LABEL_STEALTH_ICON;
        width = 64;
        height = 64;
    };
    {
        id = "reticleIcon";
        controlName = "ZO_ReticleContainerReticle";
        label = KFS_LABEL_RETICLE_ICON;
    };
    {
        id = "ramSiege";
        controlName = "ZO_RamTopLevel";
        label = KFS_LABEL_RAM_SIEGE;
    };
    {
        id = "playerHealth";
        controlName = "ZO_PlayerAttributeHealth";
        label = KFS_LABEL_PLAYER_HEALTH;
        width = 237;
        height = 23;
        scaleApply = function (panel, scale)
            AttributeScaler:Apply(panel, scale);
        end;
    };
    {
        id = "playerMagicka";
        controlName = "ZO_PlayerAttributeMagicka";
        label = KFS_LABEL_PLAYER_MAGICKA;
        width = 237;
        height = 23;
        scaleApply = function (panel, scale)
            AttributeScaler:Apply(panel, scale);
        end;
    };
    {
        id = "playerStamina";
        controlName = "ZO_PlayerAttributeStamina";
        label = KFS_LABEL_PLAYER_STAMINA;
        width = 237;
        height = 23;
        scaleApply = function (panel, scale)
            AttributeScaler:Apply(panel, scale);
        end;
    };
    {
        id = "playerWerewolf";
        controlName = "ZO_PlayerAttributeWerewolf";
        label = KFS_LABEL_PLAYER_WEREWOLF;
        width = 228;
        height = 12;
        condition = function ()
            return GetControl("ZO_PlayerAttributeWerewolf") ~= nil;
        end;
        scaleApply = function (panel, scale)
            AttributeScaler:Apply(panel, scale);
        end;
    };
    {
        id = "playerMount";
        controlName = "ZO_PlayerAttributeMountStamina";
        label = KFS_LABEL_PLAYER_MOUNT;
        width = 228;
        height = 12;
        condition = function ()
            return GetControl("ZO_PlayerAttributeMountStamina") ~= nil;
        end;
        scaleApply = function (panel, scale)
            AttributeScaler:Apply(panel, scale);
        end;
    };
    {
        id = "playerSiege";
        controlName = "ZO_PlayerAttributeSiegeHealth";
        label = KFS_LABEL_PLAYER_SIEGE;
        width = 228;
        height = 12;
        condition = function ()
            return GetControl("ZO_PlayerAttributeSiegeHealth") ~= nil;
        end;
        scaleApply = function (panel, scale)
            AttributeScaler:Apply(panel, scale);
        end;
    };
    {
        id = "buffSelf";
        controlName = "KhajiitFengShui_PlayerBuffs";
        label = KFS_LABEL_BUFF_SELF;
        width = function ()
            local control = GetControl("KhajiitFengShui_PlayerBuffs");
            if control then
                return control:GetWidth() or 400;
            end;
            return 400;
        end;
        height = function ()
            local control = GetControl("KhajiitFengShui_PlayerBuffs");
            if control then
                return control:GetHeight() or 70;
            end;
            return 70;
        end;
        anchorPoint = BOTTOM;
        anchorRelativePoint = BOTTOM;
        condition = function ()
            return GetControl("KhajiitFengShui_PlayerBuffs") ~= nil;
        end;
        scaleApply = function (panel, scale)
            local control = panel and panel.control;
            if not control then
                return;
            end;
            PanelUtils.enableInheritScaleRecursive(control);
            control:SetTransformScale(scale);
            local buffContainer = GetControl("ZO_BuffDebuffTopLevelSelfContainer");
            if buffContainer then
                buffContainer:SetTransformScale(scale);
                PanelUtils.enableInheritScaleRecursive(buffContainer);
            end;
        end;
    };
    {
        id = "buffTarget";
        controlName = "KhajiitFengShui_TargetDebuffs";
        label = KFS_LABEL_BUFF_TARGET;
        width = function ()
            local control = GetControl("KhajiitFengShui_TargetDebuffs");
            if control then
                return control:GetWidth() or 400;
            end;
            return 400;
        end;
        height = function ()
            local control = GetControl("KhajiitFengShui_TargetDebuffs");
            if control then
                return control:GetHeight() or 70;
            end;
            return 70;
        end;
        anchorPoint = BOTTOM;
        anchorRelativePoint = BOTTOM;
        condition = function ()
            return GetControl("KhajiitFengShui_TargetDebuffs") ~= nil;
        end;
        scaleApply = function (panel, scale)
            local control = panel and panel.control;
            if not control then
                return;
            end;
            PanelUtils.enableInheritScaleRecursive(control);
            control:SetTransformScale(scale);
            local buffContainer = GetControl("ZO_BuffDebuffTopLevelTargetContainer");
            if buffContainer then
                buffContainer:SetTransformScale(scale);
                PanelUtils.enableInheritScaleRecursive(buffContainer);
            end;
        end;
    };
    {
        id = "miniChat";
        controlName = "ZO_ChatWindow";
        label = KFS_LABEL_CHAT_MINI;
        width = 400;
        height = 200;
    };
    {
        id = "gamepadChat";
        controlName = "ZO_GamepadTextChat";
        label = KFS_LABEL_CHAT_GAMEPAD;
        width = 400;
        height = 200;
        condition = function ()
            return GetControl("ZO_GamepadTextChat") ~= nil;
        end;
    };
};

---@class KFS_PanelDefinitions
---@field list KhajiitFengShuiPanelDefinition[]
local PanelDefinitions = {};

PanelDefinitions.list = definitions;

---Returns all panel definitions
---@return KhajiitFengShuiPanelDefinition[]
function PanelDefinitions.getAll()
    return definitions;
end;

---Gets localized label for a definition
---@param definition KhajiitFengShuiPanelDefinition
---@return string
function PanelDefinitions.getLabel(definition)
    return GetString(definition.label);
end;

---Resolves control from definition
---@param definition KhajiitFengShuiPanelDefinition
---@return userdata?
function PanelDefinitions.resolveControl(definition)
    if definition.condition and not definition.condition() then
        return nil;
    end;

    local control = _G[definition.controlName];
    if not control and GetControl then
        control = GetControl(definition.controlName);
    end;

    if not (control and control.SetAnchor) then
        return nil;
    end;

    return control;
end;

KhajiitFengShui.PanelDefinitions = PanelDefinitions;
