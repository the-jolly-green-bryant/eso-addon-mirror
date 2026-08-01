local BST = {}
BST.__index = BST
BST.LAM2 = LibAddonMenu2
BST.name = "BetterStealthText"
BST.version = 1.10
BST.textVersion = "1.10"
BST.animationManager = GetAnimationManager()
BST.eventManager = GetEventManager()


local BST_CONTROL = ZO_ReticleContainerStealthIconStealthText

local DEFAULT_COLOR = { 0.937, 0.921, 0.745, 1 }
local DEFAULT_HIDDEN_COLOR = { 0, 1, 0, 1 }
local DEFAULT_ALMOST_DETECTED_COLOR = { 1, 1, 0, 1 }
local DEFAULT_DETECTED_COLOR = { 1, 0.1, 0, 1 }
local DEFAULT_REVEALED_COLOR = { 0, 0.7, 1, 1 }
local STEALTH_STATE_REVEALED = 69

BST.stealthTexts =
{
    [STEALTH_STATE_HIDDEN] = GetString(SI_STEALTH_HIDDEN),
    [STEALTH_STATE_STEALTH] = GetString(BETTERSTEALTHTEXT_INVISIBLE),
    [STEALTH_STATE_HIDDEN_ALMOST_DETECTED] = GetString(SI_STEALTH_HIDDEN),
    [STEALTH_STATE_STEALTH_ALMOST_DETECTED] = GetString(BETTERSTEALTHTEXT_INVISIBLE),
    [STEALTH_STATE_DETECTED] = GetString(SI_STEALTH_DETECTED),
    [STEALTH_STATE_HIDING] = GetString(BETTERSTEALTHTEXT_HIDING),
    [STEALTH_STATE_REVEALED] = GetString(BETTERSTEALTHTEXT_REVEALED),
    [STEALTH_STATE_NONE] = "",
}

BST.disguiseTexts =
{
    [DISGUISE_STATE_DISGUISED] = GetString(SI_DISGUISE_DISGUISED),
    [DISGUISE_STATE_DISCOVERED] = GetString(SI_DISGUISE_DISCOVERED),
    [DISGUISE_STATE_SUSPICIOUS] = GetString(SI_DISGUISE_SUSPICIOUS),
    [DISGUISE_STATE_DANGER] = GetString(SI_DISGUISE_DANGER),
}

BST.revealedIds =
{
    [74621] = true,
    [42440] = true,
    [80328] = true,
    [80338] = true,
}

BST.accountWideDefaults =
{
    accountWide = true
}

BST.defaults =
{
    enabled = true,
    controlScale = 1.2,
    hiding = true,
    hiddenInvisible = true,
    almostHiddenInvisible = true,
    stealthColors =
    {
        [STEALTH_STATE_HIDDEN] = DEFAULT_HIDDEN_COLOR,
        [STEALTH_STATE_STEALTH] = DEFAULT_HIDDEN_COLOR,
        [STEALTH_STATE_HIDDEN_ALMOST_DETECTED] = DEFAULT_ALMOST_DETECTED_COLOR,
        [STEALTH_STATE_STEALTH_ALMOST_DETECTED] = DEFAULT_ALMOST_DETECTED_COLOR,
        [STEALTH_STATE_DETECTED] = DEFAULT_DETECTED_COLOR,
        [STEALTH_STATE_HIDING] = DEFAULT_COLOR,
        [STEALTH_STATE_REVEALED] = DEFAULT_REVEALED_COLOR,
    },
    disguiseColors =
    {
        [DISGUISE_STATE_DISGUISED] = DEFAULT_HIDDEN_COLOR,
        [DISGUISE_STATE_DISCOVERED] = DEFAULT_DETECTED_COLOR,
        [DISGUISE_STATE_SUSPICIOUS] = DEFAULT_ALMOST_DETECTED_COLOR,
        [DISGUISE_STATE_DANGER] = DEFAULT_ALMOST_DETECTED_COLOR,
    },
}

--- @param eventId integer
--- @param result ActionResult
--- @param isError boolean
--- @param abilityName string
--- @param abilityGraphic integer
--- @param abilityActionSlotType ActionSlotType
--- @param sourceName string
--- @param sourceType CombatUnitType
--- @param targetName string
--- @param targetType CombatUnitType
--- @param hitValue integer
--- @param powerType CombatMechanicFlags
--- @param damageType DamageType
--- @param log boolean
--- @param sourceUnitId integer
--- @param targetUnitId integer
--- @param abilityId integer
--- @param overflow integer
function BST.OnRevealed(eventId, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if result == ACTION_RESULT_EFFECT_GAINED_DURATION and
    targetName == GetRawUnitName("player") and
    sourceName ~= GetRawUnitName("player") and
    (abilityName == "Revealed" or
        abilityName == "Radiant Magelight" or
        abilityName == "Inner Light" or
        abilityName == "Magelight" or
        abilityName == "Revealing Flare" or
        BST.revealedIds[abilityId]) then
        BST.isRevealed = true
        BST.OnStealthState(nil, nil, STEALTH_STATE_REVEALED)
        zo_callLater(function ()
                         -- d("revealed end")
                         BST.isRevealed = false
                         BST.ResetState()
                         BST.OnStealthState(nil, nil, STEALTH_STATE_NONE)
                         -- d("control text", BST_CONTROL:GetText())
                         -- d("conmparison text", SI_STEALTH_REVEALED)
                         if BST_CONTROL:GetText() == GetString(BETTERSTEALTHTEXT_REVEALED) then
                             -- d("text = revealed")
                             BST.OnStealthState(nil, nil, STEALTH_STATE_NONE)
                         end
                     end, hitValue + 50)
        -- d("abilityName", abilityName)
        -- d("abilityId", abilityId)
        -- d("hitValue", hitValue)
        -- d("sourceName", sourceName)
        -- d("sourceType", sourceType)
    end
end

function BST:AnimateInStealthTextHook()
    ZO_PreHook(ZO_StealthIcon, "AnimateInStealthText", function ()
        return self.SV.enabled
    end)
    ZO_PreHook(ZO_StealthIcon, "HideStealthText", function ()
        return self.SV.enabled
    end)
end

--- @param eventId integer|nil
--- @param unitTag string|nil
--- @param stealthState StealthState
function BST.OnStealthState(eventId, unitTag, stealthState)
    -- d('slteathstate',BST.stealthTexts[stealthState])

    if GetUnitDisguiseState("player") ~= DISGUISE_STATE_NONE then
        return
    end
    if BST.isRevealed and stealthState ~= STEALTH_STATE_REVEALED then
        return
    end


    if stealthState == STEALTH_STATE_HIDDEN then
        if BST_CONTROL:GetText() ~= GetString(BETTERSTEALTHTEXT_HIDING) and BST_CONTROL:GetText() ~= GetString(SI_STEALTH_HIDDEN) then
            BST:AnimateText("IN")
        end
        BST:SetControlText(stealthState, true)
        BST:SetControlColor(stealthState, true)
    elseif stealthState == STEALTH_STATE_STEALTH_ALMOST_DETECTED then
        BST:SetControlText(stealthState, true)
        BST:SetControlColor(stealthState, true)
    elseif stealthState == STEALTH_STATE_HIDDEN_ALMOST_DETECTED then
        BST:SetControlText(stealthState, true)
        BST:SetControlColor(stealthState, true)
    elseif stealthState == STEALTH_STATE_STEALTH then
        BST:SetControlText(stealthState, true)
        BST:SetControlColor(stealthState, true)
        BST:AnimateText("IN")
    elseif stealthState == STEALTH_STATE_DETECTED then
        BST:SetControlText(stealthState, true)
        BST:SetControlColor(stealthState, true)
        BST:AnimateText("IN")
    elseif stealthState == STEALTH_STATE_HIDING then
        if BST.SV.hiding then
            BST:SetControlText(stealthState, true)
            BST:SetControlColor(stealthState, true)
            BST:AnimateText("HIDING")
        else
            if BST_CONTROL:GetText() ~= "" then
                BST:AnimateText("OUT")
            end
        end
    elseif stealthState == STEALTH_STATE_REVEALED then
        BST:SetControlText(stealthState, true)
        BST:SetControlColor(stealthState, true)
        BST:AnimateText("IN")
    elseif (stealthState == STEALTH_STATE_NONE) then
        if BST_CONTROL:GetText() ~= "" then
            BST:AnimateText("OUT")
        end
    end
end

--- @param eventId integer|nil
--- @param unitTag string|nil
--- @param disguiseState DisguiseState
function BST.OnDisguiseState(eventId, unitTag, disguiseState)
    -- d("disguise")
    if BST.isRevealed and disguiseState ~= DISGUISE_STATE_NONE then
        return
    end

    if disguiseState == DISGUISE_STATE_DISGUISED then
        BST:SetControlText(disguiseState, false)
        BST:SetControlColor(disguiseState, false)
        BST:AnimateText("IN")
    elseif disguiseState == DISGUISE_STATE_DISCOVERED then
        BST:SetControlText(disguiseState, false)
        BST:SetControlColor(disguiseState, false)
        BST:AnimateText("IN")
    elseif disguiseState == DISGUISE_STATE_SUSPICIOUS then
        BST:SetControlText(disguiseState, false)
        BST:SetControlColor(disguiseState, false)
        BST:AnimateText("IN")
    elseif disguiseState == DISGUISE_STATE_DANGER then
        BST:SetControlText(disguiseState, false)
        BST:SetControlColor(disguiseState, false)
        BST:AnimateText("IN")
    else
        BST.OnStealthState(nil, nil, GetUnitStealthState("player"))
    end
end

--- @param animType AnimationType
function BST:AnimateText(animType)
    for i = 0, MAX_ANCHORS - 1 do
        local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY, anchorConstrains = BST_CONTROL:GetAnchor(i)
        if isValidAnchor then
            BST_CONTROL:ClearAnchors()
            BST_CONTROL:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY, anchorConstrains)

            local timeline = self.animationManager:CreateTimeline()

            if animType == "IN" then
                self:InsertAnimationType(timeline, ANIMATION_ALPHA, BST_CONTROL, 200, 0, ZO_EaseInQuadratic, 0, 1)
            elseif animType == "OUT" then
                local alpha = 1
                if BST_CONTROL:GetText() == GetString(BETTERSTEALTHTEXT_HIDING) then
                    alpha = BST_CONTROL:GetAlpha()
                end
                self:InsertAnimationType(timeline, ANIMATION_ALPHA, BST_CONTROL, 150, 0, ZO_EaseOutQuadratic, alpha, 0)
            elseif animType == "HIDING" then
                local currentTime = GetFrameTimeSeconds()
                local hidingEndTime = GetUnitHidingEndTime("player")
                local hidingTimeRemaining = zo_max(zo_ceil(hidingEndTime - currentTime), 0)
                hidingTimeRemaining = hidingTimeRemaining * 1000
                self:InsertAnimationType(timeline, ANIMATION_ALPHA, BST_CONTROL, hidingTimeRemaining, 0, ZO_LinearEase, 0, 1)
            end
            timeline:SetHandler("OnStop", function ()
                if animType == "OUT" then
                    BST_CONTROL:SetText("")
                end
                BST_CONTROL:SetScale(BST.SV.controlScale)
                BST_CONTROL:ClearAnchors()
                BST_CONTROL:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY, anchorConstrains)
            end)

            timeline:PlayFromStart()
        end
    end
end

---
--- @param animHandler AnimationTimeline
--- @param animType AnimationType
--- @param control userdata
--- @param animDuration integer
--- @param animDelay integer
--- @param animEasing function
--- @param ... unknown
function BST:InsertAnimationType(animHandler, animType, control, animDuration, animDelay, animEasing, ...)
    if not animHandler then return end
    if animType == ANIMATION_SCALE then
        local animationScale, startScale, endScale = animHandler:InsertAnimation(ANIMATION_SCALE, control, animDelay), ...
        animationScale:SetScaleValues(startScale, endScale)
        animationScale:SetDuration(animDuration)
        animationScale:SetEasingFunction(animEasing)
    elseif animType == ANIMATION_ALPHA then
        local animationAlpha, startAlpha, endAlpha = animHandler:InsertAnimation(ANIMATION_ALPHA, control, animDelay), ...
        animationAlpha:SetAlphaValues(startAlpha, endAlpha)
        animationAlpha:SetDuration(animDuration)
        animationAlpha:SetEasingFunction(animEasing)
    elseif animType == ANIMATION_TRANSLATE then
        local animationTranslate, startX, startY, offsetX, offsetY = animHandler:InsertAnimation(ANIMATION_TRANSLATE, control, animDelay), ...
        animationTranslate:SetTranslateOffsets(startX, startY, offsetX, offsetY)
        animationTranslate:SetDuration(animDuration)
        animationTranslate:SetEasingFunction(animEasing)
    end
end

---
--- @param state any
--- @param stealthOrDisguise any
function BST:SetControlText(state, stealthOrDisguise)
    if stealthOrDisguise and state == STEALTH_STATE_NONE then
        return
    end
    local sod
    if stealthOrDisguise then
        sod = BST.stealthTexts
    else
        sod = BST.disguiseTexts
    end
    BST_CONTROL:SetText(sod[state])
end

---
--- @param state any
--- @param stealthOrDisguise any
function BST:SetControlColor(state, stealthOrDisguise)
    if stealthOrDisguise and state == STEALTH_STATE_NONE then
        return
    end
    local sod
    if stealthOrDisguise then
        sod = BST.SV.stealthColors
    else
        sod = BST.SV.disguiseColors
    end
    BST_CONTROL:SetColor(unpack(sod[state]))
end

function BST:OnOff()
    if self.SV.enabled then
        if not self.addonEnabled then
            self.addonEnabled = true
            self.eventManager:RegisterForEvent(self.name, EVENT_STEALTH_STATE_CHANGED, self.OnStealthState)
            self.eventManager:AddFilterForEvent(self.name, EVENT_STEALTH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
            self.eventManager:RegisterForEvent(self.name, EVENT_DISGUISE_STATE_CHANGED, self.OnDisguiseState)
            self.eventManager:AddFilterForEvent(self.name, EVENT_DISGUISE_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
            self.eventManager:RegisterForEvent(self.name, EVENT_COMBAT_EVENT, self.OnRevealed)
            BST_CONTROL:SetScale(BST.SV.controlScale)
            self.OnPlayerActivated()
        end
    else
        if self.addonEnabled then
            self.addonEnabled = false
            self.eventManager:UnregisterForEvent(self.name, EVENT_STEALTH_STATE_CHANGED)
            self.eventManager:UnregisterForEvent(self.name, EVENT_DISGUISE_STATE_CHANGED)
            self.eventManager:UnregisterForEvent(self.name, EVENT_COMBAT_EVENT)
            BST_CONTROL:SetScale(1)
            BST_CONTROL:SetColor(unpack(DEFAULT_COLOR))
        end
    end
end

function BST:InitializeAddonMenu()
    local panelData =
    {
        type = "panel",
        name = GetString(BETTERSTEALTHTEXT_ADDON_NAME),
        displayName = GetString(BETTERSTEALTHTEXT_ADDON_NAME),
        author = "Dorrino",
        version = self.textVersion,
        slashCommand = "/stealthtext",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {}

    optionsData[#optionsData + 1] =
    {
        type = "header",
        name = GetString(BETTERSTEALTHTEXT_ADDON_OPTIONS),
    }

    optionsData[#optionsData + 1] =
    {
        type = "checkbox",
        name = GetString(BETTERSTEALTHTEXT_ADDON_ENABLED),
        tooltip = GetString(BETTERSTEALTHTEXT_ADDON_ENABLED_TOOLTIP),
        default = self.defaults.enabled,
        getFunc = function ()
            return self.SV.enabled
        end,
        setFunc = function (newValue)
            self.SV.enabled = newValue
            self:OnOff()
        end,
    }

    optionsData[#optionsData + 1] =
    {
        type = "checkbox",
        name = GetString(BETTERSTEALTHTEXT_ACCOUNTWIDE),
        tooltip = GetString(BETTERSTEALTHTEXT_ACCOUNTWIDE_TOOLTIP),
        default = self.accountWideDefaults.accountWide,
        disabled = function ()
            return not self.SV.enabled
        end,
        getFunc = function ()
            return self.DS.accountWide
        end,
        setFunc = function (newValue)
            self.DS.accountWide = newValue
            ReloadUI("ingame")
        end,
        warning = GetString(BETTERSTEALTHTEXT_ACCOUNTWIDE_WARNING),
    }

    optionsData[#optionsData + 1] =
    {
        type = "header",
        name = GetString(BETTERSTEALTHTEXT_DISPLAY_OPTIONS),
    }

    optionsData[#optionsData + 1] =
    {
        type     = "slider",
        name     = GetString(BETTERSTEALTHTEXT_SCALE),
        tooltip  = GetString(BETTERSTEALTHTEXT_SCALE_TOOLTIP),
        default  = tonumber(string.format("%.0f", 100 * self.defaults.controlScale)),
        disabled = function ()
            return not self.SV.enabled
        end,
        min      = 50,
        max      = 400,
        step     = 1,
        getFunc  = function ()
            return tonumber(string.format("%.0f", 100 * self.SV.controlScale))
        end,
        setFunc  = function (newValue)
            self.SV.controlScale = newValue / 100
        end,
    }

    optionsData[#optionsData + 1] =
    {
        type = "header",
        name = GetString(BETTERSTEALTHTEXT_STEALTH_COLORS_OPTIONS),
    }

    optionsData[#optionsData + 1] =
    {
        type = "checkbox",
        name = GetString(BETTERSTEALTHTEXT_SAME_HIDDEN_INVISIBLE),
        tooltip = GetString(BETTERSTEALTHTEXT_SAME_HIDDEN_INVISIBLE_TOOLTIP),
        default = self.defaults.enabled,
        disabled = function ()
            return not self.SV.enabled
        end,
        getFunc = function ()
            return self.SV.hiddenInvisible
        end,
        setFunc = function (newValue)
            self.SV.hiddenInvisible = newValue
        end,
    }

    optionsData[#optionsData + 1] =
    {
        type = "colorpicker",
        name = GetString(BETTERSTEALTHTEXT_HIDDEN_COLOR),
        tooltip = GetString(BETTERSTEALTHTEXT_HIDDEN_COLOR_TOOLTIP),
        default = ZO_ColorDef:New(unpack(self.defaults.stealthColors[STEALTH_STATE_HIDDEN])),
        disabled = function ()
            return not self.SV.enabled
        end,
        getFunc = function ()
            return unpack(self.SV.stealthColors[STEALTH_STATE_HIDDEN])
        end,
        setFunc = function (r, g, b, a)
            self.SV.stealthColors[STEALTH_STATE_HIDDEN] = { r, g, b, a }
            if self.SV.hiddenInvisible then
                self.SV.stealthColors[STEALTH_STATE_STEALTH] = { r, g, b, a }
            end
        end,
    }

    optionsData[#optionsData + 1] =
    {
        type = "colorpicker",
        name = GetString(BETTERSTEALTHTEXT_INVISIBLE_COLOR),
        tooltip = GetString(BETTERSTEALTHTEXT_INVISIBLE_COLOR_TOOLTIP),
        default = ZO_ColorDef:New(unpack(self.defaults.stealthColors[STEALTH_STATE_STEALTH])),
        disabled = function ()
            return (not self.SV.enabled) or self.SV.hiddenInvisible
        end,
        getFunc = function ()
            return unpack(self.SV.stealthColors[STEALTH_STATE_STEALTH])
        end,
        setFunc = function (r, g, b, a)
            self.SV.stealthColors[STEALTH_STATE_STEALTH] = { r, g, b, a }
        end,
    }

    optionsData[#optionsData + 1] =
    {
        type = "checkbox",
        name = GetString(BETTERSTEALTHTEXT_SAME_ALMOST_HIDDEN_INVISIBLE),
        tooltip = GetString(BETTERSTEALTHTEXT_SAME_ALMOST_HIDDEN_INVISIBLE_TOOLTIP),
        default = self.defaults.enabled,
        disabled = function ()
            return not self.SV.enabled
        end,
        getFunc = function ()
            return self.SV.almostHiddenInvisible
        end,
        setFunc = function (newValue)
            self.SV.almostHiddenInvisible = newValue
        end,
    }

    optionsData[#optionsData + 1] =
    {
        type = "colorpicker",
        name = GetString(BETTERSTEALTHTEXT_HIDDEN_ALMOST_COLOR),
        tooltip = GetString(BETTERSTEALTHTEXT_HIDDEN_ALMOST_COLOR_TOOLTIP),
        default = ZO_ColorDef:New(unpack(self.defaults.stealthColors[STEALTH_STATE_HIDDEN_ALMOST_DETECTED])),
        disabled = function ()
            return not self.SV.enabled
        end,
        getFunc = function ()
            return unpack(self.SV.stealthColors[STEALTH_STATE_HIDDEN_ALMOST_DETECTED])
        end,
        setFunc = function (r, g, b, a)
            self.SV.stealthColors[STEALTH_STATE_HIDDEN_ALMOST_DETECTED] = { r, g, b, a }
            if self.SV.almostHiddenInvisible then
                self.SV.stealthColors[STEALTH_STATE_STEALTH_ALMOST_DETECTED] = { r, g, b, a }
            end
        end,
    }

    optionsData[#optionsData + 1] =
    {
        type = "colorpicker",
        name = GetString(BETTERSTEALTHTEXT_INVISIBLE_ALMOST_COLOR),
        tooltip = GetString(BETTERSTEALTHTEXT_INVISIBLE_ALMOST_COLOR_TOOLTIP),
        default = ZO_ColorDef:New(unpack(self.defaults.stealthColors[STEALTH_STATE_STEALTH_ALMOST_DETECTED])),
        disabled = function ()
            return (not self.SV.enabled) or self.SV.almostHiddenInvisible
        end,
        getFunc = function ()
            return unpack(self.SV.stealthColors[STEALTH_STATE_STEALTH_ALMOST_DETECTED])
        end,
        setFunc = function (r, g, b, a)
            self.SV.stealthColors[STEALTH_STATE_STEALTH_ALMOST_DETECTED] = { r, g, b, a }
        end,
    }

    optionsData[#optionsData + 1] =
    {
        type = "checkbox",
        name = GetString(BETTERSTEALTHTEXT_ENABLE_HIDING),
        tooltip = GetString(BETTERSTEALTHTEXT_ENABLE_HIDING_TOOLTIP),
        default = self.defaults.enabled,
        disabled = function ()
            return not self.SV.enabled
        end,
        getFunc = function ()
            return self.SV.hiding
        end,
        setFunc = function (newValue)
            self.SV.hiding = newValue
        end,
    }

    optionsData[#optionsData + 1] =
    {
        type = "colorpicker",
        name = GetString(BETTERSTEALTHTEXT_HIDING_COLOR),
        tooltip = GetString(BETTERSTEALTHTEXT_HIDING_COLOR_TOOLTIP),
        default = ZO_ColorDef:New(unpack(self.defaults.stealthColors[STEALTH_STATE_HIDING])),
        disabled = function ()
            return (not self.SV.enabled) or (not self.SV.hiding)
        end,
        getFunc = function ()
            return unpack(self.SV.stealthColors[STEALTH_STATE_HIDING])
        end,
        setFunc = function (r, g, b, a)
            self.SV.stealthColors[STEALTH_STATE_HIDING] = { r, g, b, a }
        end,
    }

    optionsData[#optionsData + 1] =
    {
        type = "colorpicker",
        name = GetString(BETTERSTEALTHTEXT_DETECTED_COLOR),
        tooltip = GetString(BETTERSTEALTHTEXT_DETECTED_COLOR_TOOLTIP),
        default = ZO_ColorDef:New(unpack(self.defaults.stealthColors[STEALTH_STATE_DETECTED])),
        disabled = function ()
            return not self.SV.enabled
        end,
        getFunc = function ()
            return unpack(self.SV.stealthColors[STEALTH_STATE_DETECTED])
        end,
        setFunc = function (r, g, b, a)
            self.SV.stealthColors[STEALTH_STATE_DETECTED] = { r, g, b, a }
        end,
    }

    optionsData[#optionsData + 1] =
    {
        type = "colorpicker",
        name = GetString(BETTERSTEALTHTEXT_REVEALED_COLOR),
        tooltip = GetString(BETTERSTEALTHTEXT_REVEALED_COLOR_TOOLTIP),
        default = ZO_ColorDef:New(unpack(self.defaults.stealthColors[STEALTH_STATE_REVEALED])),
        disabled = function ()
            return not self.SV.enabled
        end,
        getFunc = function ()
            return unpack(self.SV.stealthColors[STEALTH_STATE_REVEALED])
        end,
        setFunc = function (r, g, b, a)
            self.SV.stealthColors[STEALTH_STATE_REVEALED] = { r, g, b, a }
        end,
    }

    optionsData[#optionsData + 1] =
    {
        type = "header",
        name = GetString(BETTERSTEALTHTEXT_DISGUISE_COLORS_OPTIONS),
    }

    optionsData[#optionsData + 1] =
    {
        type = "colorpicker",
        name = GetString(BETTERSTEALTHTEXT_DISGUISED_COLOR),
        tooltip = GetString(BETTERSTEALTHTEXT_DISGUISED_COLOR_TOOLTIP),
        default = ZO_ColorDef:New(unpack(self.defaults.disguiseColors[DISGUISE_STATE_DISGUISED])),
        disabled = function ()
            return not self.SV.enabled
        end,
        getFunc = function ()
            return unpack(self.SV.disguiseColors[DISGUISE_STATE_DISGUISED])
        end,
        setFunc = function (r, g, b, a)
            self.SV.disguiseColors[DISGUISE_STATE_DISGUISED] = { r, g, b, a }
        end,
    }

    optionsData[#optionsData + 1] =
    {
        type = "colorpicker",
        name = GetString(BETTERSTEALTHTEXT_SUSPICIOUS_COLOR),
        tooltip = GetString(BETTERSTEALTHTEXT_SUSPICIOUS_COLOR_TOOLTIP),
        default = ZO_ColorDef:New(unpack(self.defaults.disguiseColors[DISGUISE_STATE_SUSPICIOUS])),
        disabled = function ()
            return not self.SV.enabled
        end,
        getFunc = function ()
            return unpack(self.SV.disguiseColors[DISGUISE_STATE_SUSPICIOUS])
        end,
        setFunc = function (r, g, b, a)
            self.SV.disguiseColors[DISGUISE_STATE_SUSPICIOUS] = { r, g, b, a }
        end,
    }

    optionsData[#optionsData + 1] =
    {
        type = "colorpicker",
        name = GetString(BETTERSTEALTHTEXT_DANGER_COLOR),
        tooltip = GetString(BETTERSTEALTHTEXT_DANGER_COLOR_TOOLTIP),
        default = ZO_ColorDef:New(unpack(self.defaults.disguiseColors[DISGUISE_STATE_DANGER])),
        disabled = function ()
            return not self.SV.enabled
        end,
        getFunc = function ()
            return unpack(self.SV.disguiseColors[DISGUISE_STATE_DANGER])
        end,
        setFunc = function (r, g, b, a)
            self.SV.disguiseColors[DISGUISE_STATE_DANGER] = { r, g, b, a }
        end,
    }

    optionsData[#optionsData + 1] =
    {
        type = "colorpicker",
        name = GetString(BETTERSTEALTHTEXT_DISCOVERED_COLOR),
        tooltip = GetString(BETTERSTEALTHTEXT_DISCOVERED_COLOR_TOOLTIP),
        default = ZO_ColorDef:New(unpack(self.defaults.disguiseColors[DISGUISE_STATE_DISCOVERED])),
        disabled = function ()
            return not self.SV.enabled
        end,
        getFunc = function ()
            return unpack(self.SV.disguiseColors[DISGUISE_STATE_DISCOVERED])
        end,
        setFunc = function (r, g, b, a)
            self.SV.disguiseColors[DISGUISE_STATE_DISCOVERED] = { r, g, b, a }
        end,
    }

    self.LAM2:RegisterAddonPanel("Better_Stealth_Text", panelData)
    self.LAM2:RegisterOptionControls("Better_Stealth_Text", optionsData)
end

function BST.ResetState()
    BST.isRevealed = false
    if GetUnitStealthState("player") == STEALTH_STATE_NONE then
        BST:SetControlText(STEALTH_STATE_NONE, true)
    end
    BST.OnStealthState(nil, nil, GetUnitStealthState("player"))
    BST.OnDisguiseState(nil, nil, GetUnitDisguiseState("player"))
end

function BST.OnPlayerActivated()
    if IsPlayerActivated() then
        BST:OnOff()
        if BST.SV.enabled then
            BST.ResetState()
        end
    end
end

function BST.OnLoaded(eventCode, addonName)
    if addonName ~= BST.name and eventCode == EVENT_ADD_ON_LOADED then
        return
    end
    BST.eventManager:UnregisterForEvent(BST.name, EVENT_ADD_ON_LOADED, BST.OnLoaded)
    BST.DS = ZO_SavedVars:NewAccountWide("BetterStealthTextSettings", 999, "AccountWide", BST.accountWideDefaults)
    if BST.DS.accountWide then
        BST.SV = ZO_SavedVars:NewAccountWide("BetterStealthTextSettings", BST.version, "Settings", BST.defaults)
    else
        BST.SV = ZO_SavedVars:New("BetterStealthTextSettings", BST.version, "Settings", BST.defaults)
    end
    BST:InitializeAddonMenu()
    BST:AnimateInStealthTextHook()
    BST.eventManager:RegisterForEvent(BST.name, EVENT_PLAYER_ACTIVATED, BST.OnPlayerActivated)
end

return BST.eventManager:RegisterForEvent(BST.name, EVENT_ADD_ON_LOADED, BST.OnLoaded)
