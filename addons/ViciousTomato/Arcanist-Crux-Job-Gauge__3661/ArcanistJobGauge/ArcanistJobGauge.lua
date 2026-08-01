ArcanistJobGauge = {
    name             = "ArcanistJobGauge",
    version          = "1.0",
    author           = "@ViciousTomato",
    color            = "92e721",
    menuName         = "Arcanist Job Gauge",
    playerName       = GetRawUnitName("player"),
    isPlayerArcanist = GetUnitClassId("player") == 117,
    fragment         = nil,
}

local CRUX_BUFF_ID = 184220
local TEXTURES = {
    ACTIVE = "ArcanistJobGauge/assets/crux_active.dds",
    INACTIVE = "ArcanistJobGauge/assets/crux_inactive.dds",
}
local COLORS = {
    ACTIVE = { 0.57, 0.9, 0.12 },
    INACTIVE = { 1, 1, 1 }
}

function ArcanistJobGauge.Colorize(text, color)
    if not color then color = ArcanistJobGauge.color end

    text = string.format('|c%s%s|r', color, text)

    return text
end

function ArcanistJobGauge.OnAddOnLoaded(event, addonName)
    if addonName ~= ArcanistJobGauge.name then return end
    EVENT_MANAGER:UnregisterForEvent(ArcanistJobGauge.name, EVENT_ADD_ON_LOADED)

    ArcanistJobGauge.characterSavedVars = ZO_SavedVars:New("ArcanistJobGaugeSavedVariables", 1, nil,
        ArcanistJobGauge.savedVars)
    ArcanistJobGauge.accountSavedVars = ZO_SavedVars:NewAccountWide("ArcanistJobGaugeSavedVariables", 1, nil,
        ArcanistJobGauge.savedVars)

    if not ArcanistJobGauge.characterSavedVars.accountWide then
        ArcanistJobGauge.savedVars = ArcanistJobGauge.characterSavedVars
    else
        ArcanistJobGauge.savedVars = ArcanistJobGauge.accountSavedVars
    end

    ArcanistJobGauge.LoadSettings()
    ArcanistJobGauge:Initialize()
end

function ArcanistJobGauge:Initialize()
    ArcanistJobGaugeWindowLabelBG:SetMouseEnabled(not ArcanistJobGauge.savedVars.isLocked)

    EVENT_MANAGER:RegisterForEvent(ArcanistJobGauge.name, EVENT_COMBAT_EVENT, ArcanistJobGauge.updateCounter)
    EVENT_MANAGER:AddFilterForEvent(ArcanistJobGauge.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
        COMBAT_UNIT_TYPE_PLAYER)
    EVENT_MANAGER:AddFilterForEvent(ArcanistJobGauge.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, false)

    EVENT_MANAGER:RegisterForEvent(ArcanistJobGauge.name, EVENT_PLAYER_COMBAT_STATE, ArcanistJobGauge.updateCombat)

    ArcanistJobGauge.updateVisibility()
    ArcanistJobGauge.setPosition()
    ArcanistJobGauge.updateCounter()
    ArcanistJobGauge.updateCombat()
end

function ArcanistJobGauge.AddSceneFragments()
    if ArcanistJobGauge.fragment ~= nil or not ArcanistJobGauge.savedVars.enabled then return end

    ArcanistJobGauge.fragment = ZO_HUDFadeSceneFragment:New(ArcanistJobGaugeWindow, nil, 0)

    HUD_SCENE:AddFragment(ArcanistJobGauge.fragment)
    HUD_UI_SCENE:AddFragment(ArcanistJobGauge.fragment)
end

function ArcanistJobGauge.RemoveSceneFragments()
    if ArcanistJobGauge.fragment == nil then return end

    HUD_SCENE:RemoveFragment(ArcanistJobGauge.fragment)
    HUD_UI_SCENE:RemoveFragment(ArcanistJobGauge.fragment)

    ArcanistJobGauge.fragment = nil
end

function ArcanistJobGauge.savePosition()
    ArcanistJobGauge.savedVars.left = ArcanistJobGaugeWindowLabelBG:GetLeft()
    ArcanistJobGauge.savedVars.top = ArcanistJobGaugeWindowLabelBG:GetTop()
end

function ArcanistJobGauge.updateCombat()
    ArcanistJobGauge.AddSceneFragments()
    if ArcanistJobGauge.savedVars.hideCombat then
        if IsUnitInCombat("player") then
            ArcanistJobGaugeWindow:SetHidden(false)
        else
            ArcanistJobGaugeWindow:SetHidden(true)
            ArcanistJobGauge.RemoveSceneFragments()
        end
    end
end

function ArcanistJobGauge.updateSimplified()
    if ArcanistJobGauge.savedVars.simplified then
        ArcanistJobGaugeWindowComplex:SetHidden(true)
        ArcanistJobGaugeWindowSimplified:SetHidden(false)
    else
        ArcanistJobGaugeWindowComplex:SetHidden(false)
        ArcanistJobGaugeWindowSimplified:SetHidden(true)
    end
end

function ArcanistJobGauge.updateVisibility()
    if not ArcanistJobGauge.savedVars.enabled then
        ArcanistJobGaugeWindow:SetHidden(true)
        return
    end
    if ArcanistJobGauge.isPlayerArcanist then
        ArcanistJobGaugeWindow:SetHidden(false)
        ArcanistJobGauge.updateSimplified()
    else
        ArcanistJobGaugeWindow:SetHidden(true)
    end
end

function ArcanistJobGauge.setPosition(left, top)
    if left == nil or top == nil then
        left = ArcanistJobGauge.savedVars.left
        top = ArcanistJobGauge.savedVars.top
    end

    ArcanistJobGaugeWindowLabelBG:ClearAnchors()
    ArcanistJobGaugeWindowLabelBG:SetAnchor(TOPLEFT, ArcanistJobGaugeWindow, CENTER, left, top)
end

function ArcanistJobGauge.updateCounter()
    local hasCrux = false

    for i = 1, GetNumBuffs("player") do
        local _, _, _, _, stackCount, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo("player", i)
        if abilityId == CRUX_BUFF_ID then
            hasCrux = true
            -- putting previous crux into higher one just in case there is situation where number goes up or down more than 1
            if stackCount == 1 then
                ArcanistJobGaugeWindowComplexCrux1:SetTexture(TEXTURES.ACTIVE)
                ArcanistJobGaugeWindowSimplifiedCrux1:SetColor(unpack(COLORS.ACTIVE))
                ArcanistJobGaugeWindowComplexCrux2:SetTexture(TEXTURES.INACTIVE)
                ArcanistJobGaugeWindowComplexCrux3:SetTexture(TEXTURES.INACTIVE)
                ArcanistJobGaugeWindowSimplifiedCrux2:SetColor(unpack(COLORS.INACTIVE))
                ArcanistJobGaugeWindowSimplifiedCrux3:SetColor(unpack(COLORS.INACTIVE))
                return
            else
                if stackCount == 2 then
                    ArcanistJobGaugeWindowComplexCrux1:SetTexture(TEXTURES.ACTIVE)
                    ArcanistJobGaugeWindowSimplifiedCrux1:SetColor(unpack(COLORS.ACTIVE))
                    ArcanistJobGaugeWindowComplexCrux2:SetTexture(TEXTURES.ACTIVE)
                    ArcanistJobGaugeWindowSimplifiedCrux2:SetColor(unpack(COLORS.ACTIVE))
                    ArcanistJobGaugeWindowComplexCrux3:SetTexture(TEXTURES.INACTIVE)
                    ArcanistJobGaugeWindowSimplifiedCrux3:SetColor(unpack(COLORS.INACTIVE))
                    return
                else
                    if stackCount == 3 then
                        ArcanistJobGaugeWindowComplexCrux1:SetTexture(TEXTURES.ACTIVE)
                        ArcanistJobGaugeWindowSimplifiedCrux1:SetColor(unpack(COLORS.ACTIVE))
                        ArcanistJobGaugeWindowComplexCrux2:SetTexture(TEXTURES.ACTIVE)
                        ArcanistJobGaugeWindowSimplifiedCrux2:SetColor(unpack(COLORS.ACTIVE))
                        ArcanistJobGaugeWindowComplexCrux3:SetTexture(TEXTURES.ACTIVE)
                        ArcanistJobGaugeWindowSimplifiedCrux3:SetColor(unpack(COLORS.ACTIVE))
                        return
                    end
                end
            end
        end
    end
    if not hasCrux then
        ArcanistJobGaugeWindowComplexCrux1:SetTexture(TEXTURES.INACTIVE)
        ArcanistJobGaugeWindowComplexCrux2:SetTexture(TEXTURES.INACTIVE)
        ArcanistJobGaugeWindowComplexCrux3:SetTexture(TEXTURES.INACTIVE)
        ArcanistJobGaugeWindowSimplifiedCrux1:SetColor(unpack(COLORS.INACTIVE))
        ArcanistJobGaugeWindowSimplifiedCrux2:SetColor(unpack(COLORS.INACTIVE))
        ArcanistJobGaugeWindowSimplifiedCrux3:SetColor(unpack(COLORS.INACTIVE))
    end
end

EVENT_MANAGER:RegisterForEvent(ArcanistJobGauge.name, EVENT_ADD_ON_LOADED, ArcanistJobGauge.OnAddOnLoaded)
