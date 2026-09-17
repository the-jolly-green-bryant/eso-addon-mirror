local ADDON_NAME = "NirnsteelUI"
local EVENT_NAMESPACE = ADDON_NAME .. "_ActionBarFrames"

Nirnsteel_UI = Nirnsteel_UI or {}
local Nirnsteel_UI = Nirnsteel_UI
local ActionBarFrames = {}
Nirnsteel_UI.ActionBarFrames = ActionBarFrames

local NORMAL_FRAME = "EsoUI/Art/ActionBar/actionslot_normal.dds"
local PRESSED_FRAME = "EsoUI/Art/ActionBar/actionslot_pressed.dds"
local TOGGLED_FRAME = "EsoUI/Art/ActionBar/actionslot_toggledon.dds"
local STOCK_NORMAL_FRAME = "EsoUI/Art/ActionBar/abilityFrame64_up.dds"
local STOCK_PRESSED_FRAME = "EsoUI/Art/ActionBar/abilityFrame64_down.dds"
local NO_TEXTURE = ""
local USE_SHRINK_SCALE = 0.86
local USE_SHRINK_DURATION_MS = 75
local USE_RESTORE_DURATION_MS = 90
local NO_LEADING_EDGE = false

local function IsModuleEnabled()
    return not Nirnsteel_UI.Settings or Nirnsteel_UI.Settings:IsActionBarFramesEnabled()
end

local function IsUseShrinkEnabled()
    return not Nirnsteel_UI.Settings or Nirnsteel_UI.Settings:IsActionBarSkillUseShrinkEnabled()
end

local function IsGlobalCooldownEnabled()
    return Nirnsteel_UI.Settings and Nirnsteel_UI.Settings:IsActionBarGlobalCooldownEnabled()
end

local function GetFrameStyle()
    local settings = Nirnsteel_UI.Settings
    local style = settings and settings:GetActionBarFrames().frameStyle or "rpg"
    return (style == "original" or style == "none") and style or "rpg"
end

local function GetStyledFrame(pressed)
    local style = GetFrameStyle()
    if style == "none" then return NO_TEXTURE end
    if style == "rpg" then
        return Nirnsteel_UI:GetAssetPath("ui/actionbar/nirnsteel_socket_v3_dxt5.dds")
    end
    return pressed and PRESSED_FRAME or NORMAL_FRAME
end

local function IsUltimateReady(button)
    if not button or not ZO_ActionBar_IsUltimateSlot(button:GetSlot(), button:GetHotbarCategory()) then
        return false
    end

    local cost = GetSlotAbilityCost(button:GetSlot(), COMBAT_MECHANIC_FLAGS_ULTIMATE, button:GetHotbarCategory())
    return cost and cost > 0 and button:GetUltimateCount() >= cost
end

local function IsQuickslotConsumableOnCooldown(button)
    if not button or button:GetHotbarCategory() ~= HOTBAR_CATEGORY_QUICKSLOT_WHEEL then
        return false
    end

    local slotNum = button:GetSlot()
    local hotbarCategory = button:GetHotbarCategory()
    local slotType = GetSlotType(slotNum, hotbarCategory)
    if slotType ~= ACTION_TYPE_ITEM and slotType ~= ACTION_TYPE_COLLECTIBLE and slotType ~= ACTION_TYPE_QUEST_ITEM then
        return false
    end

    local remain, duration = GetSlotCooldownInfo(slotNum, hotbarCategory)
    return duration and duration > 0 and remain and remain > 0
end

local function GetOverlayTexture(button)
    local style = GetFrameStyle()
    if style == "none" then return nil end
    if style == "rpg" then
        -- Ultimate readiness has its own full-size frame and halo.
        if ZO_ActionBar_IsUltimateSlot(button:GetSlot(), button:GetHotbarCategory()) then return nil end
        if IsQuickslotConsumableOnCooldown(button) or IsUltimateReady(button) then
            return Nirnsteel_UI:GetAssetPath("ui/actionbar/socket_glow_dxt5.dds")
        end
        return nil
    end
    if IsQuickslotConsumableOnCooldown(button) then
        return TOGGLED_FRAME
    end

    if IsUltimateReady(button) then
        return PRESSED_FRAME
    end
end

local function GetStockNormalFrameTexture()
    return IsInGamepadPreferredMode() and NO_TEXTURE or STOCK_NORMAL_FRAME
end

local function GetStockPressedFrameTexture()
    return IsInGamepadPreferredMode() and NO_TEXTURE or STOCK_PRESSED_FRAME
end

local function IsStockActionFrame(texture)
    return texture == STOCK_NORMAL_FRAME
        or texture == STOCK_PRESSED_FRAME
        or texture == NO_TEXTURE
end

local function GetSetupNormalFrame(normalFrame)
    if IsModuleEnabled() and IsStockActionFrame(normalFrame) then
        return GetStyledFrame(false)
    end

    return normalFrame
end

local function GetSetupPressedFrame(pressedFrame)
    if IsModuleEnabled() then
        if pressedFrame == STOCK_PRESSED_FRAME then
            return GetStyledFrame(true)
        elseif pressedFrame == STOCK_NORMAL_FRAME then
            return GetStyledFrame(false)
        elseif pressedFrame == NO_TEXTURE then
            return GetStyledFrame(true)
        end
    end

    return pressedFrame
end

local function IsPlayableActionSlot(button)
    if not button then
        return false
    end

    local slotType = GetSlotType(button:GetSlot(), button:GetHotbarCategory())
    return slotType == ACTION_TYPE_ABILITY or slotType == ACTION_TYPE_CRAFTED_ABILITY
end

local function CreateUseShrinkTimeline(control)
    local timeline = ANIMATION_MANAGER:CreateTimeline()

    local shrink = timeline:InsertAnimation(ANIMATION_SCALE, control, 0)
    shrink:SetDuration(USE_SHRINK_DURATION_MS)
    shrink:SetEasingFunction(ZO_EaseInQuadratic)

    local restore = timeline:InsertAnimation(ANIMATION_SCALE, control, USE_SHRINK_DURATION_MS)
    restore:SetDuration(USE_RESTORE_DURATION_MS)
    restore:SetEasingFunction(ZO_EaseOutQuadratic)

    return timeline
end

local function SetUseShrinkTimelineScale(timeline, control)
    local baseScale = control:GetScale()
    local shrinkScale = baseScale * USE_SHRINK_SCALE

    local shrink = timeline:GetAnimation(1)
    shrink:SetScaleValues(baseScale, shrinkScale)

    local restore = timeline:GetAnimation(2)
    restore:SetScaleValues(shrinkScale, baseScale)
end

function ActionBarFrames:PlayUseShrink(button)
    if not IsModuleEnabled() or not IsUseShrinkEnabled() or IsInGamepadPreferredMode() or not IsPlayableActionSlot(button) then
        return
    end

    if not button.NirnsteelUseShrinkTimeline then
        button.NirnsteelUseShrinkTimeline = CreateUseShrinkTimeline(button.slot)
    end

    local timeline = button.NirnsteelUseShrinkTimeline
    if timeline:IsPlaying() then
        timeline:PlayInstantlyToEnd()
    end

    SetUseShrinkTimelineScale(timeline, button.slot)
    timeline:PlayFromStart()
end

function ActionBarFrames:ApplyGlobalCooldown(button)
    if not IsModuleEnabled() or not IsGlobalCooldownEnabled() or not IsPlayableActionSlot(button) or not button.cooldown then
        return
    end

    local remain, duration, global = GetSlotCooldownInfo(button:GetSlot(), button:GetHotbarCategory())
    if global and remain and remain > 0 and duration and duration > 0 then
        button.cooldown:StartCooldown(remain, duration, CD_TYPE_RADIAL, nil, NO_LEADING_EDGE)
        button.cooldown:SetHidden(false)
    end
end

function ActionBarFrames:UpdateSkillFrame(button, enabled)
    local frame = button.NirnsteelSkillFrame
    if not enabled then
        if frame then frame:SetHidden(true) end
        return
    end
    if not frame then
        frame = WINDOW_MANAGER:CreateControl(nil, button.slot, CT_TEXTURE)
        frame:SetAnchor(CENTER, button.slot, CENTER, 0, 0)
        frame:SetTexture(Nirnsteel_UI:GetAssetPath("ui/actionbar/nirnsteel_socket_v3_dxt5.dds"))
        frame:SetMouseEnabled(false)
        frame:SetDrawTier(DT_HIGH)
        frame:SetDrawLayer(DL_OVERLAY)
        frame:SetDrawLevel(4)
        button.NirnsteelSkillFrame = frame
    end
    -- Draw the metal outside the 47px icon, instead of squeezing it into
    -- the native 50px button texture. Slot positions and hit targets stay native.
    local size = button.slot:GetWidth() + 4
    frame:SetDimensions(size, size)
    frame:SetHidden(false)
end

function ActionBarFrames:UpdateUltimateFrame(button, enabled)
    local decoration = button.slot:GetNamedChild("Decoration")
    if decoration then
        if enabled then
            if button.NirnsteelDecorationAlpha == nil then
                button.NirnsteelDecorationAlpha = decoration:GetAlpha()
            end
            decoration:SetAlpha(0)
        elseif button.NirnsteelDecorationAlpha ~= nil then
            decoration:SetAlpha(button.NirnsteelDecorationAlpha)
            button.NirnsteelDecorationAlpha = nil
        end
    end
    local art = button.NirnsteelUltimateArt
    if not enabled then
        if art then
            art.frame:SetHidden(true)
            art.halo:SetHidden(true)
            art.halo:SetHandler("OnUpdate", nil)
            art.ready = false
        end
        return
    end
    if not art then
        art = {}
        for _, key in ipairs({ "halo", "frame" }) do
            local texture = WINDOW_MANAGER:CreateControl(nil, button.slot, CT_TEXTURE)
            texture:SetAnchor(CENTER, button.slot, CENTER, 0, 0)
            texture:SetMouseEnabled(false)
            texture:SetDrawTier(DT_HIGH)
            texture:SetDrawLayer(DL_OVERLAY)
            texture:SetDrawLevel(key == "halo" and 3 or 4)
            art[key] = texture
        end
        art.halo:SetTexture(Nirnsteel_UI:GetAssetPath("ui/actionbar/ultimate_halo_v3_dxt5.dds"))
        button.NirnsteelUltimateArt = art
    end
    local size = button.slot:GetWidth() + 14
    art.frame:SetDimensions(size, size)
    art.halo:SetDimensions(size + 14, size + 14)
    local ready = IsUltimateReady(button)
    art.frame:SetTexture(Nirnsteel_UI:GetAssetPath(ready
        and "ui/actionbar/ultimate_ready_v3_dxt5.dds" or "ui/actionbar/ultimate_iron_v3_dxt5.dds"))
    art.frame:SetHidden(false)
    art.halo:SetHidden(not ready)
    if ready ~= art.ready then
        art.halo:SetHandler("OnUpdate", nil)
        if ready then
            local start = GetFrameTimeMilliseconds()
            art.halo:SetAlpha(0.65)
            art.halo:SetHandler("OnUpdate", function(control)
                local phase = (GetFrameTimeMilliseconds() - start) / 1800 * math.pi * 2
                control:SetAlpha(0.65 + 0.20 * math.sin(phase))
            end)
        end
        art.ready = ready
    end
end

function ActionBarFrames:ApplyToButton(button)
    if not button or not button.button then
        return
    end

    local moduleEnabled = IsModuleEnabled()
    local iron = moduleEnabled and GetFrameStyle() == "rpg"
    local ironUltimate = iron and ZO_ActionBar_IsUltimateSlot(button:GetSlot(), button:GetHotbarCategory())
    button.button:SetNormalTexture(iron and NO_TEXTURE or moduleEnabled and GetStyledFrame(false) or GetStockNormalFrameTexture())
    button.button:SetPressedTexture(iron and NO_TEXTURE or moduleEnabled and GetStyledFrame(true) or GetStockPressedFrameTexture())
    self:UpdateSkillFrame(button, iron and not ironUltimate)
    self:UpdateUltimateFrame(button, ironUltimate)

    if button.status then
        local iron = moduleEnabled and GetFrameStyle() == "rpg"
        button.status:SetColor(1, iron and 0.78 or 1, iron and 0.42 or 1, 1)
        local overlayTexture = moduleEnabled and GetOverlayTexture(button)
        if overlayTexture then
            button.status:SetTexture(overlayTexture)
            button.status:SetHidden(false)
        elseif moduleEnabled then
            button.status:SetHidden(true)
        else
            local slotNum = button:GetSlot()
            local hotbarCategory = button:GetHotbarCategory()
            local slotIsEmpty = GetSlotType(slotNum, hotbarCategory) == ACTION_TYPE_NOTHING
            button.status:SetTexture(TOGGLED_FRAME)
            button.status:SetHidden(slotIsEmpty or IsSlotToggled(slotNum, hotbarCategory) == false)
        end
    end

    self:ApplyGlobalCooldown(button)
end

function ActionBarFrames:ApplyQuickslot()
    if ZO_ActionBar_GetButton then
        self:ApplyToButton(ZO_ActionBar_GetButton(nil, HOTBAR_CATEGORY_QUICKSLOT_WHEEL))
    end
end

function ActionBarFrames:ApplyActiveUltimate()
    if ZO_ActionBar_GetButton then
        self:ApplyToButton(ZO_ActionBar_GetButton(ACTION_BAR_ULTIMATE_SLOT_INDEX + 1))
    end
end

function ActionBarFrames:ApplyCompanionUltimate()
    if ZO_ActionBar_GetButton then
        self:ApplyToButton(ZO_ActionBar_GetButton(ACTION_BAR_ULTIMATE_SLOT_INDEX + 1, HOTBAR_CATEGORY_COMPANION))
    end
end

function ActionBarFrames:ApplyAll()
    if not ZO_ActionBar_GetButton then
        return
    end

    for i = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1, ACTION_BAR_ULTIMATE_SLOT_INDEX + 1 do
        self:ApplyToButton(ZO_ActionBar_GetButton(i))
    end

    self:ApplyQuickslot()
    self:ApplyCompanionUltimate()
end

function ActionBarFrames:RefreshCooldowns()
    if not ZO_ActionBar_GetButton then
        return
    end

    for i = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1, ACTION_BAR_ULTIMATE_SLOT_INDEX + 1 do
        local button = ZO_ActionBar_GetButton(i)
        if button and button.UpdateCooldown then
            button:UpdateCooldown()
        end
    end

    local quickslotButton = ZO_ActionBar_GetButton(nil, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    if quickslotButton and quickslotButton.UpdateCooldown then
        quickslotButton:UpdateCooldown()
    end

    local companionUltimateButton = ZO_ActionBar_GetButton(ACTION_BAR_ULTIMATE_SLOT_INDEX + 1, HOTBAR_CATEGORY_COMPANION)
    if companionUltimateButton and companionUltimateButton.UpdateCooldown then
        companionUltimateButton:UpdateCooldown()
    end
end

function ActionBarFrames:RefreshAssignableActionBars()
    if SKILLS_WINDOW and SKILLS_WINDOW.assignableActionBar then
        SKILLS_WINDOW.assignableActionBar:RefreshAllButtons()
    end

    if GAMEPAD_SKILLS and GAMEPAD_SKILLS.assignableActionBar then
        GAMEPAD_SKILLS.assignableActionBar:RefreshAllButtons()
    end
end

local function WrapActionButtonMethod(methodName)
    if not ActionButton or ActionButton["NirnsteelHooked" .. methodName] then
        return
    end

    if not ZO_PostHook or not ZO_PostHook(ActionButton, methodName, function(button, ...)
        ActionBarFrames:ApplyToButton(button)
    end) then
        return
    end

    ActionButton["NirnsteelHooked" .. methodName] = true
end

function ActionBarFrames:InstallActionSlotHooks()
    if self.actionSlotHooksInstalled or not ZO_PreHook or not ZO_ActionSlot_SetupSlot or not ZO_ActionSlot_ClearSlot then
        return
    end

    local originalSetupSlot = ZO_ActionSlot_SetupSlot
    local setupHooked = ZO_PreHook("ZO_ActionSlot_SetupSlot", function(iconControl, buttonControl, icon, normalFrame, downFrame, cooldownIconControl, mouseOverTexture)
        originalSetupSlot(
            iconControl,
            buttonControl,
            icon,
            GetSetupNormalFrame(normalFrame),
            GetSetupPressedFrame(downFrame),
            cooldownIconControl,
            mouseOverTexture
        )
        return true
    end)

    local originalClearSlot = ZO_ActionSlot_ClearSlot
    local clearHooked = ZO_PreHook("ZO_ActionSlot_ClearSlot", function(iconControl, buttonControl, normalFrame, downFrame, cooldownIconControl, mouseOverTexture)
        originalClearSlot(
            iconControl,
            buttonControl,
            GetSetupNormalFrame(normalFrame),
            GetSetupPressedFrame(downFrame),
            cooldownIconControl,
            mouseOverTexture
        )
        return true
    end)

    self.actionSlotHooksInstalled = setupHooked ~= false and clearHooked ~= false
end

function ActionBarFrames:InstallHooks()
    if self.hooksInstalled then
        return
    end

    self:InstallActionSlotHooks()
    WrapActionButtonMethod("HandleSlotChanged")
    WrapActionButtonMethod("UpdateState")
    WrapActionButtonMethod("UpdateCooldown")
    WrapActionButtonMethod("RefreshCooldown")
    WrapActionButtonMethod("SetUltimateMeter")
    WrapActionButtonMethod("Clear")
    WrapActionButtonMethod("ApplyStyle")

    self.hooksInstalled = true
end

function ActionBarFrames:RegisterEvents()
    if self.eventsRegistered then
        return
    end

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ACTION_UPDATE_COOLDOWNS, function()
        self:ApplyQuickslot()
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_HOTBAR_SLOT_UPDATED, function()
        self:ApplyAll()
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_HOTBAR_SLOT_STATE_UPDATED, function()
        self:ApplyAll()
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, function()
        zo_callLater(function() self:ApplyAll() end, 250)
        zo_callLater(function() self:ApplyAll() end, 550)
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, function()
        zo_callLater(function() self:ApplyAll() end, 100)
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ACTIVE_QUICKSLOT_CHANGED, function()
        self:ApplyQuickslot()
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ACTION_SLOT_ABILITY_USED, function(_, actionSlotIndex)
        if ZO_ActionBar_GetButton then
            self:PlayUseShrink(ZO_ActionBar_GetButton(actionSlotIndex))
        end
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(function() self:ApplyAll() end, 1000)
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_POWER_UPDATE, function()
        self:ApplyActiveUltimate()
    end)
    EVENT_MANAGER:AddFilterForEvent(EVENT_NAMESPACE, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_ULTIMATE, REGISTER_FILTER_UNIT_TAG, "player")

    self.eventsRegistered = true
end

function ActionBarFrames:RefreshSettings()
    self:RegisterEvents()
    self:ApplyAll()
    self:RefreshCooldowns()
    self:RefreshAssignableActionBars()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_Loaded", EVENT_ADD_ON_LOADED)
    ActionBarFrames:InstallHooks()
    ActionBarFrames:RefreshSettings()
    zo_callLater(function() ActionBarFrames:ApplyAll() end, 1000)
end

EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Loaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
