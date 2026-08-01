NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local UI = NQOL.Features.UI

local APPLY_DELAY_MS = 50
local ANIMATION_UPDATE_MS = 25
local EVENT_NAMESPACE = "NQOL_UI_CombatReticle"
local UPDATE_NAMESPACE = "NQOL_UI_CombatReticle_Update"
local HIT_INDICATOR_DURATION_MS = 750
local SHAPE_DEFAULT = "default"
local RETICLE_DEFAULT_TEXTURE = "EsoUI/Art/Reticle/reticleAnim.dds"
local DEFAULT_COLOR = { r = 1, g = 1, b = 1, a = 1 }
local OPEN_ANIMATION_SCALE = 1
local CLOSED_ANIMATION_SCALE = 0.72
local ANIMATION_SCALE_STEP = 0.07
local SCALE_DEFAULT = 1
local SCALE_MIN = 1
local SCALE_MAX = 10
local SHAPES = {
    SHAPE_DEFAULT,
    "dot",
    "bigDot",
    "cross",
    "plus",
    "ring",
    "ringDot",
    "xCross",
    "diamond",
    "chevron",
    "tShape",
    "brackets",
    "duplex",
}
local SHAPE_NAMES = NQOL.Lexicon.LocalizedList({
    "features.ui_combat_reticle.shape_default", "features.ui_combat_reticle.shape_dot",
    "features.ui_combat_reticle.shape_big_dot", "features.ui_combat_reticle.shape_gap_cross",
    "features.ui_combat_reticle.shape_plus", "features.ui_combat_reticle.shape_ring",
    "features.ui_combat_reticle.shape_ring_dot", "features.ui_combat_reticle.shape_x_cross",
    "features.ui_combat_reticle.shape_diamond", "features.ui_combat_reticle.shape_chevron",
    "features.ui_combat_reticle.shape_t_shape", "features.ui_combat_reticle.shape_brackets",
    "features.ui_combat_reticle.shape_duplex",
})
local SHAPE_STYLES = {
    dot = { controlType = "dds", textureFile = "nqol_dot.dds", width = 32, height = 32 },
    bigDot = { controlType = "dds", textureFile = "nqol_big_dot.dds", width = 32, height = 32 },
    cross = { controlType = "dds", textureFile = "nqol_gap_cross.dds", width = 32, height = 32 },
    plus = { controlType = "dds", textureFile = "nqol_plus.dds", width = 32, height = 32 },
    ring = { controlType = "dds", textureFile = "nqol_ring.dds", width = 32, height = 32 },
    ringDot = { controlType = "dds", textureFile = "nqol_ring_dot.dds", width = 32, height = 32 },
    xCross = { controlType = "dds", textureFile = "nqol_x.dds", width = 32, height = 32 },
    diamond = { controlType = "dds", textureFile = "nqol_diamond.dds", width = 32, height = 32 },
    chevron = { controlType = "dds", textureFile = "nqol_chevron.dds", width = 32, height = 32 },
    tShape = { controlType = "dds", textureFile = "nqol_t.dds", width = 32, height = 32 },
    brackets = { controlType = "dds", textureFile = "nqol_brackets.dds", width = 32, height = 32 },
    duplex = { controlType = "dds", textureFile = "nqol_duplex.dds", width = 32, height = 32 },
}
local GAMEPLAY_SCENES = {
    hud = true,
    siegeBar = true,
}
local SHAPE_VALID = {
    default = true,
    dot = true,
    bigDot = true,
    cross = true,
    plus = true,
    ring = true,
    ringDot = true,
    xCross = true,
    diamond = true,
    chevron = true,
    tShape = true,
    brackets = true,
    duplex = true,
}

local applyQueued = false
local initialized = false
local hooksInstalled = false
local hookAttempts = 0
local updateLoopInstalled = false
local sceneCallbackInstalled = false
local appliedShape
local appliedTexturePath
local animationScale = OPEN_ANIMATION_SCALE
local customRoot
local customTexture
local RefreshAnimationLoop

local function GetSettings()
    return UI.GetCombatReticleSettings()
end

local function GetShape()
    local settings = GetSettings()
    local shape = settings.shape
    if SHAPE_VALID[shape] ~= true then
        shape = SHAPE_DEFAULT
        settings.shape = shape
    end

    return shape
end

local function GetScale()
    local scale = tonumber(GetSettings().scale) or SCALE_DEFAULT
    scale = NQOL.Util.Clamp(scale, SCALE_MIN, SCALE_MAX)
    return math.floor(scale + 0.5)
end

local function IsAnimatedReticleEnabled()
    return GetSettings().animated == true
end

local function SetControlScale(control, scale)
    if control and control.SetScale and (not control.GetScale or control:GetScale() ~= scale) then
        control:SetScale(scale)
    end
end

local function RestoreVanillaReticleControls()
    SetControlScale(ZO_ReticleContainerReticle, 1)
    SetControlScale(ZO_ReticleContainerCombatLock, 1)

    if ZO_ReticleContainerReticle and ZO_ReticleContainerReticle.SetAlpha then
        ZO_ReticleContainerReticle:SetAlpha(1)
    end

    if ZO_ReticleContainerCombatLock and ZO_ReticleContainerCombatLock.SetAlpha then
        ZO_ReticleContainerCombatLock:SetAlpha(1)
    end
end

local function HideVanillaReticleControls()
    SetControlScale(ZO_ReticleContainerReticle, 0)
    SetControlScale(ZO_ReticleContainerCombatLock, 0)
end

local function IsPlayerInStealthOrDisguise()
    local disguiseNone = DISGUISE_STATE_NONE or 0
    local stealthNone = STEALTH_STATE_NONE or 0
    local disguiseState = GetUnitDisguiseState and GetUnitDisguiseState("player") or disguiseNone
    local stealthState = GetUnitStealthState and GetUnitStealthState("player") or stealthNone

    return disguiseState ~= disguiseNone or stealthState ~= stealthNone
end

local function ShouldCloseReticle()
    local interactionPossible = RETICLE and RETICLE.interact and RETICLE.interact.IsHidden and not RETICLE.interact:IsHidden()
    local hasPlayerTarget = PLAYER_TO_PLAYER and PLAYER_TO_PLAYER.HasTarget and PLAYER_TO_PLAYER:HasTarget()
    local hasAttackableTarget = IsGameCameraUnitHighlightedAttackable and IsGameCameraUnitHighlightedAttackable()

    return interactionPossible or hasPlayerTarget or hasAttackableTarget
end

local function MoveToward(value, target, step)
    if math.abs(target - value) <= step then
        return target
    elseif value < target then
        return value + step
    end

    return value - step
end

local function UpdateAnimationScale()
    local targetScale = ShouldCloseReticle() and CLOSED_ANIMATION_SCALE or OPEN_ANIMATION_SCALE
    animationScale = MoveToward(animationScale, targetScale, ANIMATION_SCALE_STEP)
end

local function ApplyReticleColor(texture)
    if not texture then
        return
    end

    local color = GetSettings().color or DEFAULT_COLOR
    texture:SetColor(color.r or DEFAULT_COLOR.r, color.g or DEFAULT_COLOR.g, color.b or DEFAULT_COLOR.b, 1)
end

local function GetAddonTexturePath(textureFile)
    return "/" .. tostring(NQOL.name or "NQOL") .. "/Art/Reticle/" .. textureFile
end

local function EnsureCustomReticle()
    if customTexture or not WINDOW_MANAGER or not GuiRoot then
        return customTexture
    end

    customRoot = WINDOW_MANAGER:CreateTopLevelWindow("NQOL_CombatReticleRoot")
    customRoot:SetDimensions(72, 72)
    customRoot:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    customRoot:SetMouseEnabled(false)
    customRoot:SetMovable(false)
    customRoot:SetHidden(true)
    if customRoot.SetDrawTier then customRoot:SetDrawTier(DT_HIGH) end
    if customRoot.SetDrawLayer then customRoot:SetDrawLayer(DL_OVERLAY) end
    if customRoot.SetDrawLevel then customRoot:SetDrawLevel(219900) end

    customTexture = WINDOW_MANAGER:CreateControl("NQOL_CombatReticleTexture", customRoot, CT_TEXTURE)
    customTexture:SetAnchor(CENTER, customRoot, CENTER, 0, 0)
    customTexture:SetDimensions(32, 32)
    customTexture:SetHidden(true)
    if customTexture.SetDrawTier then customTexture:SetDrawTier(DT_HIGH) end
    if customTexture.SetDrawLayer then customTexture:SetDrawLayer(DL_OVERLAY) end
    if customTexture.SetDrawLevel then customTexture:SetDrawLevel(220000) end

    return customTexture
end

local function HideCustomReticle()
    if customTexture then
        customTexture:SetHidden(true)
    end
    if customRoot then
        customRoot:SetHidden(true)
    end
end

local function GetCurrentSceneName()
    if not SCENE_MANAGER then
        return nil
    end

    if SCENE_MANAGER.GetCurrentSceneName then
        return SCENE_MANAGER:GetCurrentSceneName()
    end

    if SCENE_MANAGER.GetCurrentScene then
        local scene = SCENE_MANAGER:GetCurrentScene()
        if scene and scene.GetName then
            return scene:GetName()
        end
    end

    return nil
end

local function IsGameplaySceneShowing()
    if not SCENE_MANAGER then
        return true
    end

    return GAMEPLAY_SCENES[GetCurrentSceneName()] == true
end

local function ApplyCombatReticle()
    local shape = GetShape()
    local style = SHAPE_STYLES[shape]
    local reticleTexture = RETICLE and RETICLE.reticleTexture or nil
    local useCustomShape = style ~= nil
    local useVanillaShape = useCustomShape and style.controlType == "vanilla"
    local useDdsShape = useCustomShape and style.controlType == "dds"
    local ddsTexture = useDdsShape and EnsureCustomReticle() or nil

    if not reticleTexture and not useDdsShape then
        return
    end

    if useCustomShape and not IsGameplaySceneShowing() then
        HideCustomReticle()
        if reticleTexture then
            reticleTexture:SetHidden(true)
        end
        return
    end

    if useVanillaShape then
        if appliedShape ~= shape then
            reticleTexture:SetTexture(RETICLE_DEFAULT_TEXTURE)
            reticleTexture:SetDimensions(style.width, style.height)
            appliedTexturePath = nil
        end
    elseif useDdsShape and ddsTexture then
        local texturePath = GetAddonTexturePath(style.textureFile)
        if IsAnimatedReticleEnabled() then
            UpdateAnimationScale()
        else
            animationScale = OPEN_ANIMATION_SCALE
        end
        local scale = GetScale() * animationScale
        local width = math.floor((style.width * scale) + 0.5)
        local height = math.floor((style.height * scale) + 0.5)
        local rootSize = math.max(width, height) + 40
        customRoot:ClearAnchors()
        customRoot:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        customRoot:SetDimensions(rootSize, rootSize)
        ddsTexture:ClearAnchors()
        ddsTexture:SetAnchor(CENTER, customRoot, CENTER, 0, 0)
        ddsTexture:SetDimensions(width, height)
        if appliedTexturePath ~= texturePath then
            ddsTexture:SetTexture(nil)
            ddsTexture:SetTexture(texturePath)
            appliedTexturePath = texturePath
        end
    elseif not useCustomShape and appliedShape ~= shape then
        reticleTexture:SetTexture(RETICLE_DEFAULT_TEXTURE)
        reticleTexture:SetDimensions(64, 64)
        appliedTexturePath = nil
    end

    appliedShape = shape

    if useCustomShape and RETICLE and RETICLE.reticleOpenCloseTimeline and RETICLE.reticleOpenCloseTimeline.Stop then
        RETICLE.reticleOpenCloseTimeline:Stop()
    end

    if useVanillaShape then
        HideCustomReticle()
        RestoreVanillaReticleControls()
        reticleTexture:SetHidden(IsPlayerInStealthOrDisguise())
        if reticleTexture.SetTextureCoords then
            reticleTexture:SetTextureCoords(style.left, style.right, style.top, style.bottom)
        end
    elseif useDdsShape then
        HideVanillaReticleControls()
        if reticleTexture then
            reticleTexture:SetHidden(false)
        end
        if ddsTexture then
            customRoot:SetHidden(false)
            ddsTexture:SetHidden(false)
            ApplyReticleColor(ddsTexture)
        end
    else
        HideCustomReticle()
        RestoreVanillaReticleControls()
        reticleTexture:SetHidden(IsPlayerInStealthOrDisguise())
        if reticleTexture.SetTextureCoords then
            reticleTexture:SetTextureCoords(0, 1, 0, 1)
        end
    end

    if reticleTexture then
        ApplyReticleColor(reticleTexture)
    end
end

function UI.QueueCombatReticleApply()
    if applyQueued then
        return
    end

    applyQueued = true
    zo_callLater(function()
        applyQueued = false
        ApplyCombatReticle()
    end, APPLY_DELAY_MS)
end

local function StopReticleHitIndicator()
    if RETICLE and RETICLE.hitIndicatorTimeline and RETICLE.hitIndicatorTimeline.Stop then
        RETICLE.hitIndicatorTimeline:Stop()
    end
end

local function InstallReticleHooks()
    if hooksInstalled then
        return
    end

    if not RETICLE or not RETICLE.OnImpactfulHit or not RETICLE.UpdateHiddenState or type(ZO_PostHook) ~= "function" then
        hookAttempts = hookAttempts + 1
        if hookAttempts < 10 then
            zo_callLater(InstallReticleHooks, 1000)
        end
        return
    end

    ZO_PostHook(RETICLE, "OnImpactfulHit", function()
        if GetShape() ~= SHAPE_DEFAULT then
            StopReticleHitIndicator()
            ApplyCombatReticle()
        end
    end)

    ZO_PostHook(RETICLE, "UpdateHiddenState", function()
        ApplyCombatReticle()
    end)

    hooksInstalled = true
end

local function InstallSceneCallback()
    if sceneCallbackInstalled or not SCENE_MANAGER or not SCENE_MANAGER.RegisterCallback then
        return
    end

    sceneCallbackInstalled = true
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, _, newState)
        if GetShape() ~= SHAPE_DEFAULT then
            local sceneName = scene and scene.GetName and scene:GetName() or nil
            local isGameplayScene = GAMEPLAY_SCENES[sceneName] == true
            local isShowing = newState == SCENE_SHOWING or newState == SCENE_SHOWN

            if isShowing and not isGameplayScene then
                HideCustomReticle()
                if RETICLE and RETICLE.reticleTexture then
                    RETICLE.reticleTexture:SetHidden(true)
                end
            end

            UI.QueueCombatReticleApply()
        end
    end)
end

local function InstallUpdateLoop()
    if updateLoopInstalled or not EVENT_MANAGER then
        return
    end

    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAMESPACE, ANIMATION_UPDATE_MS, function()
        if GetShape() ~= SHAPE_DEFAULT then
            ApplyCombatReticle()
        else
            animationScale = OPEN_ANIMATION_SCALE
        end
    end)
    updateLoopInstalled = true
end

local function UninstallUpdateLoop()
    if updateLoopInstalled and EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAMESPACE)
    end

    updateLoopInstalled = false
    animationScale = OPEN_ANIMATION_SCALE
end

RefreshAnimationLoop = function()
    if IsAnimatedReticleEnabled() and GetShape() ~= SHAPE_DEFAULT then
        InstallUpdateLoop()
    else
        UninstallUpdateLoop()
    end
end

function UI.InitializeCombatReticle()
    if initialized or not EVENT_MANAGER then
        return
    end

    initialized = true
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, function()
        InstallReticleHooks()
        InstallSceneCallback()
        UI.QueueCombatReticleApply()
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ALIVE, UI.QueueCombatReticleApply)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_DEAD, UI.QueueCombatReticleApply)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_RETICLE_HIDDEN_UPDATE, UI.QueueCombatReticleApply)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_STEALTH_STATE_CHANGED, function(_, unitTag)
        if unitTag == "player" then
            UI.QueueCombatReticleApply()
        end
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_DISGUISE_STATE_CHANGED, function(_, unitTag)
        if unitTag == "player" then
            UI.QueueCombatReticleApply()
        end
    end)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_IMPACTFUL_HIT, function()
        if IsAnimatedReticleEnabled() and GetShape() ~= SHAPE_DEFAULT then
            zo_callLater(ApplyCombatReticle, HIT_INDICATOR_DURATION_MS + APPLY_DELAY_MS)
        end
    end)

    InstallReticleHooks()
    InstallSceneCallback()
    RefreshAnimationLoop()
    UI.QueueCombatReticleApply()
end

function UI.GetCombatReticleColor()
    local color = GetSettings().color
    color.a = 1
    return color.r, color.g, color.b, 1
end

function UI.SetCombatReticleColor(red, green, blue, alpha)
    local color = GetSettings().color
    color.r = NQOL.Util.Clamp(tonumber(red) or DEFAULT_COLOR.r, 0, 1)
    color.g = NQOL.Util.Clamp(tonumber(green) or DEFAULT_COLOR.g, 0, 1)
    color.b = NQOL.Util.Clamp(tonumber(blue) or DEFAULT_COLOR.b, 0, 1)
    color.a = 1
    UI.QueueCombatReticleApply()
end

function UI.GetCombatReticleShape()
    return GetShape()
end

function UI.SetCombatReticleShape(shape)
    if SHAPE_VALID[shape] ~= true then
        shape = SHAPE_DEFAULT
    end

    GetSettings().shape = shape
    RefreshAnimationLoop()
    UI.QueueCombatReticleApply()
end

function UI.GetCombatReticleShapeChoices()
    return SHAPES
end

function UI.GetCombatReticleShapeChoiceNames()
    return SHAPE_NAMES
end

function UI.GetCombatReticleShapeDefault()
    return SHAPE_DEFAULT
end

function UI.GetCombatReticleScale()
    return GetScale()
end

function UI.SetCombatReticleScale(value)
    local scale = NQOL.Util.Clamp(tonumber(value) or SCALE_DEFAULT, SCALE_MIN, SCALE_MAX)
    GetSettings().scale = math.floor(scale + 0.5)
    UI.QueueCombatReticleApply()
end

function UI.GetAnimatedCombatReticle()
    return IsAnimatedReticleEnabled()
end

function UI.SetAnimatedCombatReticle(value)
    GetSettings().animated = value == true
    RefreshAnimationLoop()
    UI.QueueCombatReticleApply()
end

function UI.GetAnimatedCombatReticleDefault()
    return true
end

function UI.GetCombatReticleScaleDefault()
    return SCALE_DEFAULT
end

function UI.GetCombatReticleScaleMin()
    return SCALE_MIN
end

function UI.GetCombatReticleScaleMax()
    return SCALE_MAX
end

function UI.GetCombatReticleColorLabel()
    return NQOL.L("features.ui_combat_reticle.combat_reticle_color_label")
end

function UI.GetCombatReticleColorTooltip()
    return NQOL.L("features.ui_combat_reticle.combat_reticle_color_tooltip")
end

function UI.GetCombatReticleShapeLabel()
    return NQOL.L("features.ui_combat_reticle.combat_reticle_shape_label")
end

function UI.GetCombatReticleShapeTooltip()
    return NQOL.L("features.ui_combat_reticle.combat_reticle_shape_tooltip")
end

function UI.GetCombatReticleScaleLabel()
    return NQOL.L("features.ui_combat_reticle.combat_reticle_scale_label")
end

function UI.GetCombatReticleScaleTooltip()
    return NQOL.L("features.ui_combat_reticle.combat_reticle_scale_tooltip")
end

function UI.GetAnimatedCombatReticleLabel()
    return NQOL.L("features.ui_combat_reticle.animated_combat_reticle_label")
end

function UI.GetAnimatedCombatReticleTooltip()
    return NQOL.L("features.ui_combat_reticle.animated_combat_reticle_tooltip")
end
