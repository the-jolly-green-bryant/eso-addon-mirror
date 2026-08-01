--[[
Todo:
Optimise stuff
Add animations (wobble)
Add resize
]]
Cruxweaver = Cruxweaver or {}
local lastProcCooldown = -1

local function IsCruxweaverActive()
    for i = 1, GetNumBuffs("player") do
        local _, _, _, _, _, _, _, _, _, _, abilityId, _ = GetUnitBuffInfo("player", i)
        if abilityId == 185908 then
            return true
        end
    end
    return false
end

local function IsCruxweaverSkillSlotted()
    for i, hotbarCategory in pairs({HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP}) do
        for j = 3, 7 do
            if GetSlotBoundId(j, hotbarCategory) == 185908 then
                return true
            end
        end
    end
    return false
end

local function UpdateCounter()
    local diff = lastProcCooldown - GetGameTimeSeconds()
    if not Cruxweaver.SavedVariables.ShowHighlight then
        Cruxweaver_UI_Icon_ActivationHighlight:SetAlpha(0)
    end
    Cruxweaver_UI_Icon_Countdown:SetText(math.ceil(diff))

    if diff < 1 then
        Cruxweaver_UI_Icon_Countdown:SetColor(1, 0, 0) -- Red color for the last second
        -- If the timer has expired
        if diff < 0 then
            if Cruxweaver.SavedVariables.ShowHighlight then
                Cruxweaver_UI_Icon_ActivationHighlight:SetAlpha(1)
            end
            Cruxweaver_UI_Icon_Countdown:SetAlpha(0)
        end
    else
        Cruxweaver_UI_Icon_Countdown:SetColor(1, 1, 1) -- Default color
        Cruxweaver_UI_Icon_ActivationHighlight:SetAlpha(0)
    end
end

local function OnDamageReceived(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, 
                                    targetName, targetType, hitValue, powerType, damageType, isLog, sourceUnitId, targetUnitId, abilityId, overflow)
    --this is pretty suboptimal but w/e, will optimise later
    if IsCruxweaverSkillSlotted() then
        Cruxweaver_UI:SetAlpha(1)
    else
        Cruxweaver_UI:SetAlpha(0)
        return
    end
    if not IsCruxweaverActive() then
        return 
    end

    local seconds = GetGameTimeSeconds()
    if (lastProcCooldown == -1) or (seconds > lastProcCooldown) then
        lastProcCooldown = seconds + 5
        --xd
        for i = 0, 5 do
            zo_callLater(UpdateCounter, 1000 * i)
        end
    end
end

local function OnMoveStop()
    Cruxweaver.SavedVariables.Y = Cruxweaver_UI:GetTop()
    Cruxweaver.SavedVariables.X = Cruxweaver_UI:GetLeft()
end

local function OnAllHotbarsUpdated()
    Cruxweaver_UI:SetAlpha(IsCruxweaverSkillSlotted() and 1 or 0)
end

local function CreateUI()
    local WindowManager = GetWindowManager()
    
    local CruxweaverUI = WindowManager:CreateTopLevelWindow("Cruxweaver_UI")
    sceneFragment = ZO_SimpleSceneFragment:New(CruxweaverUI)
    HUD_SCENE:AddFragment(sceneFragment)
    HUD_UI_SCENE:AddFragment(sceneFragment)
    --CruxweaverUI:SetResizeToFitDescendents(true)
    CruxweaverUI:SetMovable(true)
    CruxweaverUI:SetClampedToScreen(true)
    CruxweaverUI:SetMouseEnabled(true)
    CruxweaverUI:SetHandler("OnMoveStop", OnMoveStop)
    CruxweaverUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, Cruxweaver.SavedVariables.X, Cruxweaver.SavedVariables.Y)
    CruxweaverUI:SetDimensions(64, 64)
    --CruxweaverUI:SetResizeHandleSize(8)
    OnAllHotbarsUpdated()

    local icon = WindowManager:CreateControl("$(parent)_Icon", CruxweaverUI, CT_TEXTURE)
    icon:SetTexture("esoui/art/icons/ability_arcanist_009_a.dds")
    icon:SetAnchorFill(CruxweaverUI)

    local activationHighlight = WindowManager:CreateControl("$(parent)_ActivationHighlight", icon, CT_TEXTURE)
    activationHighlight:SetTexture("EsoUI/Art/ActionBar/abilityHighlightAnimation.dds")
    activationHighlight:SetBlendMode(TEX_BLEND_MODE_ADD)
    activationHighlight:SetAnchorFill(icon)
    activationHighlight:SetAlpha(0)
    
    local activationHighlightAnim = CreateSimpleAnimation(ANIMATION_TEXTURE, activationHighlight)
    activationHighlightAnim:SetImageData(64, 1)
    activationHighlightAnim:SetFramerate(30)
    local activationHighlightAnimTimeline = activationHighlightAnim:GetTimeline()
    activationHighlightAnimTimeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
    activationHighlightAnimTimeline:PlayFromStart()
    
    --[[local animationTimeline = ANIMATION_MANAGER:CreateTimeline()
    animationTimeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
    local CardFloatEase = ZO_GenerateCubicBezierEase(.25, -0.1, .75, 1.1)
    local iconRotateAnim = animationTimeline:InsertAnimation(ANIMATION_TEXTURE_ROTATE, icon)
    iconRotateAnim:SetDuration(500)
    iconRotateAnim:SetEasingFunction(CardFloatEase)
    iconRotateAnim:SetRotationValues(0, 6.2)
    animationTimeline:PlayFromStart()
    local iconRotateAnimTimeline = iconRotateAnim:GetTimeline()
    iconRotateAnimTimeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
    iconRotateAnimTimeline:PlayFromStart()]]
    
    local countdown = WindowManager:CreateControl("$(parent)_Countdown", icon, CT_LABEL)
    countdown:SetAnchor(CENTER, icon, CENTER)
    countdown:SetFont("$(MEDIUM_FONT)|$(KB_54)|soft-shadow-thick")
end

local function Initialize()
    Cruxweaver.InitSavedVariables()
    Cruxweaver.InitSettings()
    CreateUI()

    local damageActionResults = {
        ACTION_RESULT_BLOCKED_DAMAGE, 
        ACTION_RESULT_CRITICAL_DAMAGE,
        ACTION_RESULT_DAMAGE,
        ACTION_RESULT_DAMAGE_SHIELDED,
        ACTION_RESULT_FALL_DAMAGE,
        ACTION_RESULT_PRECISE_DAMAGE,
        ACTION_RESULT_WRECKING_DAMAGE
    }
    
    for k, actionResult in pairs(damageActionResults) do
        EVENT_MANAGER:RegisterForEvent(Cruxweaver.Name .. "DamageReceived" .. k, EVENT_COMBAT_EVENT, OnDamageReceived)
        EVENT_MANAGER:AddFilterForEvent(Cruxweaver.Name .. "DamageReceived" .. k, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
        EVENT_MANAGER:AddFilterForEvent(Cruxweaver.Name .. "DamageReceived" .. k, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, actionResult)
    end

    EVENT_MANAGER:RegisterForEvent(Cruxweaver.Name, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, OnAllHotbarsUpdated) 
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= Cruxweaver.Name then return end
    EVENT_MANAGER:UnregisterForEvent(Cruxweaver.Name, EVENT_ADD_ON_LOADED)
    Initialize()
end

EVENT_MANAGER:RegisterForEvent(Cruxweaver.Name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
