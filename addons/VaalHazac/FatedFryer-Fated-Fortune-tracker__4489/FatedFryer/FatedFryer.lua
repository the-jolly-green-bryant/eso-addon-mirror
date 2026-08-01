FatedFryer = {
    name = "FatedFryer",
    version = "1.2",
    buffId = 194875,

    defaults = {
        enabled = true,
        showTimer = true,
        lockWindow = false,
        posX = 300,
        posY = 300,
        iconSize = 36,
        fontSize = 30,
        spacing = 4,
        showBackground = true,
    }
}

local FF = FatedFryer
local NAME = FF.name
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER

local window = nil
local bg = nil
local icon = nil
local label = nil
local hudFragment = nil
local endTimeGlobal = 0

local function SavePosition()
    if not window then return end

    local left = window:GetLeft()
    local top = window:GetTop()

    if left and top then
        FF.settings.posX = math.floor(left + 0.5)
        FF.settings.posY = math.floor(top + 0.5)
    end
end

local function ClampSettings()
    FF.settings.iconSize = zo_clamp(FF.settings.iconSize or 36, 24, 64)
    FF.settings.fontSize = zo_clamp(FF.settings.fontSize or 30, 20, 48)
    FF.settings.spacing = zo_clamp(FF.settings.spacing or 4, 0, 12)
end

local function ClampPositionToScreen()
    if not window then return end

    local x = FF.settings.posX or 300
    local y = FF.settings.posY or 300

    local uiW, uiH = GuiRoot:GetDimensions()
    local w, h = window:GetDimensions()

    x = zo_clamp(x, 0, math.max(0, uiW - w))
    y = zo_clamp(y, 0, math.max(0, uiH - h))

    FF.settings.posX = x
    FF.settings.posY = y
end

local function ApplySavedPosition()
    if not window then return end

    ClampPositionToScreen()

    window:ClearAnchors()
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, FF.settings.posX, FF.settings.posY)
end

local function ApplyFragmentVisibility()
    if not hudFragment then return end

    if FF.settings.enabled then
        hudFragment:Show()
    else
        hudFragment:Hide()
    end
end

local function UpdateLayout()
    if not window or not bg or not icon or not label then return end

    ClampSettings()

    local iconSize = FF.settings.iconSize
    local spacing = FF.settings.spacing
    local fontSize = FF.settings.fontSize

    local labelWidth = math.max(36, fontSize + 6)
    local width = iconSize + spacing + labelWidth + 12
    local height = math.max(iconSize, fontSize) + 8

    window:SetDimensions(width, height)

    bg:ClearAnchors()
    bg:SetAnchorFill(window)
    bg:SetHidden(not FF.settings.showBackground)

    icon:ClearAnchors()
    icon:SetDimensions(iconSize, iconSize)
    icon:SetAnchor(LEFT, window, LEFT, 4, 0)
    icon:SetHidden(false)

    label:ClearAnchors()
    label:SetAnchor(LEFT, icon, RIGHT, spacing, 0)
    label:SetDimensions(labelWidth, height)
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    if fontSize >= 40 then
        label:SetFont("ZoFontWinH1")
    elseif fontSize >= 30 then
        label:SetFont("ZoFontGameLargeBold")
    else
        label:SetFont("ZoFontGame")
    end
end

local function UpdateDisplay()
    if not window or not icon or not label then return end

    icon:SetHidden(false)

    if not FF.settings.enabled then
        return
    end

    if not FF.settings.showTimer then
        icon:SetAlpha(0.45)
        label:SetColor(0.5, 0.5, 0.5, 1)
        label:SetText("")
        return
    end

    if endTimeGlobal <= 0 then
        icon:SetAlpha(0.45)
        label:SetColor(0.5, 0.5, 0.5, 1)
        label:SetText("0.0")
        return
    end

    local remaining = endTimeGlobal - GetFrameTimeSeconds()

    if remaining <= 0 then
        endTimeGlobal = 0
        icon:SetAlpha(0.45)
        label:SetColor(0.5, 0.5, 0.5, 1)
        label:SetText("0.0")
    else
        icon:SetAlpha(1)

        if remaining < 2 then
            label:SetColor(1, 0.2, 0.2, 1)
        else
            label:SetColor(0.2, 1, 1, 1)
        end

        label:SetText(string.format("%.1f", math.max(0, remaining)))
    end
end

local function CreateUI()
    window = WM:CreateTopLevelWindow(NAME .. "Window")
    window:SetDrawLayer(DL_OVERLAY)
    window:SetDrawTier(DT_HIGH)
    window:SetClampedToScreen(true)
    window:SetMouseEnabled(not FF.settings.lockWindow)
    window:SetMovable(not FF.settings.lockWindow)
    window:SetHidden(false)

    window:SetHandler("OnMoveStop", function()
        SavePosition()
    end)

    bg = WM:CreateControl(NAME .. "BG", window, CT_BACKDROP)
    bg:SetCenterColor(0, 0, 0, 0.20)
    bg:SetEdgeColor(0.65, 0.65, 0.65, 0.18)
    bg:SetEdgeTexture("", 1, 1, 1)

    icon = WM:CreateControl(NAME .. "Icon", window, CT_TEXTURE)

    local texture = GetAbilityIcon(FF.buffId)
    if texture and texture ~= "" then
        icon:SetTexture(texture)
    else
        icon:SetTexture("/esoui/art/icons/ability_arcanist_005.dds")
    end

    icon:SetHidden(false)
    icon:SetAlpha(1)

    label = WM:CreateControl(NAME .. "Label", window, CT_LABEL)
    label:SetText("0.0")
    label:SetColor(0.5, 0.5, 0.5, 1)

    UpdateLayout()
    ApplySavedPosition()
    UpdateDisplay()
end

function FF.RefreshUI()
    if not window then return end

    window:SetMouseEnabled(not FF.settings.lockWindow)
    window:SetMovable(not FF.settings.lockWindow)

    UpdateLayout()
    ApplySavedPosition()
    ApplyFragmentVisibility()
    UpdateDisplay()
end

function FF.ResetToDefaults()
    ZO_DeepTableCopy(FF.defaults, FF.settings)
    FF.RefreshUI()
end

local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag,
    beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType,
    statusEffectType, unitName, unitId, abilityId, sourceType)

    if unitTag ~= "player" then return end
    if not FF.settings.enabled then return end
    if abilityId ~= FF.buffId then return end

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        endTimeGlobal = endTime
    elseif changeType == EFFECT_RESULT_FADED then
        endTimeGlobal = 0
    end

    UpdateDisplay()
end

function FF.Initialize()
    FF.settings = ZO_SavedVars:NewAccountWide("FatedFryerSavedVars", 1, GetWorldName(), FF.defaults)

    CreateUI()

    hudFragment = ZO_SimpleSceneFragment:New(window)
    HUD_SCENE:AddFragment(hudFragment)
    HUD_UI_SCENE:AddFragment(hudFragment)

    ApplyFragmentVisibility()

    EM:RegisterForEvent(NAME, EVENT_EFFECT_CHANGED, OnEffectChanged)
    EM:AddFilterForEvent(NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    EM:RegisterForUpdate(NAME .. "_Update", 100, UpdateDisplay)

    if FF.BuildMenu then
        FF.BuildMenu()
    end
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= NAME then return end
    EM:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
    FF.Initialize()
end

EM:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)