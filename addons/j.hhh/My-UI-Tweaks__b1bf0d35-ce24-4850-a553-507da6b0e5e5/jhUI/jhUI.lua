------------------------------------------------------------
-- Console Minimal UI
-- jh UI release 3.1
--
-- Only two optional features:
--   * Force player Health/Magicka/Stamina to ESO NORMAL width (237)
--   * Hide the vanilla reticle TARGET FRAME
--
-- Attribute-bar anchors/positions are never modified.
-- Boss bar, compass and world/nameplate UI are never modified.
------------------------------------------------------------

local ADDON_NAME = "jhUI"
local NORMAL_WIDTH = 237

------------------------------------------------------------
-- Saved settings / LibAddonMenu-2.0
------------------------------------------------------------

local defaults = {
    normalAttributeWidth = true,
    hideTargetFrame = true,
}

local settings = nil

local function IsEnabled(key)
    return settings and settings[key] == true
end

local function RegisterSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then
        return
    end

    local panelName = ADDON_NAME .. "_Options"

    local panelData = {
        type = "panel",
        name = "jh UI",
        displayName = "|cFFFFFFjh UI|r",
        author = "OpenAI",
        version = "3.1.0",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel(panelName, panelData)

    local optionsData = {
        {
            type = "checkbox",
            name = "Attribute Bars: Normal Width",
            tooltip = "Forces Health, Magicka and Stamina to ESO's normal width (237 px). Position and anchors are left untouched for compatibility with UI-positioning addons.",
            getFunc = function()
                return IsEnabled("normalAttributeWidth")
            end,
            setFunc = function(value)
                settings.normalAttributeWidth = value
            end,
            default = defaults.normalAttributeWidth,
            requiresReload = true,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Hide Target Frame",
            tooltip = "Hides the vanilla reticle target frame only.",
            getFunc = function()
                return IsEnabled("hideTargetFrame")
            end,
            setFunc = function(value)
                settings.hideTargetFrame = value
            end,
            default = defaults.hideTargetFrame,
            requiresReload = true,
            width = "full",
        },
    }

    LAM:RegisterOptionControls(panelName, optionsData)
end

------------------------------------------------------------
-- Attribute bar width
------------------------------------------------------------

local function GetAttributeBars()
    return {
        ZO_PlayerAttributeHealth,
        ZO_PlayerAttributeMagicka,
        ZO_PlayerAttributeStamina,
    }
end

local function ApplyNormalAttributeBarWidth()
    if not IsEnabled("normalAttributeWidth") then
        return
    end

    for _, bar in ipairs(GetAttributeBars()) do
        if bar then
            -- Only control width. Never touch anchors/position.
            -- This keeps compatibility with positioning addons.
            bar:SetDimensionConstraints(NORMAL_WIDTH, 0, NORMAL_WIDTH, 1000)
            bar:SetWidth(NORMAL_WIDTH)

            -- The black gamepad MAX/background is the BgContainer.
            -- Keep it visible, but make it exactly the same width as
            -- the 237px attribute bar so no black extension remains.
            local bg = GetControl(bar, "BgContainer")
            if bg then
                bg:SetWidth(NORMAL_WIDTH)

                local left = GetControl(bg, "BgLeft")
                local center = GetControl(bg, "BgCenter")
                local right = GetControl(bg, "BgRight")

                if left then left:SetWidth(16) end
                if center then center:SetWidth(NORMAL_WIDTH - 32) end
                if right then right:SetWidth(16) end
            end
        end
    end
end

------------------------------------------------------------
-- Vanilla reticle target frame
------------------------------------------------------------

local function HideTargetFrame()
    if not IsEnabled("hideTargetFrame") then
        return
    end

    local targetFrame

    if ZO_UnitFrames_GetUnitFrame then
        targetFrame = ZO_UnitFrames_GetUnitFrame("reticleover")
    end

    if targetFrame then
        if targetFrame.SetAnimateShowHide then
            targetFrame:SetAnimateShowHide(false)
        end

        if targetFrame.SetHiddenForReason then
            targetFrame:SetHiddenForReason(ADDON_NAME, true)
        end
    end

    if UNIT_FRAMES and UNIT_FRAMES.SetFrameHiddenForReason then
        UNIT_FRAMES:SetFrameHiddenForReason("reticleover", ADDON_NAME, true)
    end

    if ZO_UnitFrames_UpdateWindow then
        ZO_UnitFrames_UpdateWindow("reticleover", true)
    end
end

------------------------------------------------------------
-- Apply / event handling
------------------------------------------------------------

local function EnforceUI()
    ApplyNormalAttributeBarWidth()
    HideTargetFrame()
end

local function OnPowerUpdate(_, unitTag)
    if unitTag == "player" then
        ApplyNormalAttributeBarWidth()
    end
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    settings = ZO_SavedVars:NewAccountWide(
        "jhUISavedVariables",
        2,
        nil,
        defaults
    )

    RegisterSettingsMenu()

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "_Stats",
        EVENT_STATS_UPDATED,
        ApplyNormalAttributeBarWidth
    )

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "_Power",
        EVENT_POWER_UPDATE,
        OnPowerUpdate
    )

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "_TargetChanged",
        EVENT_RETICLE_TARGET_CHANGED,
        HideTargetFrame
    )

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "_Combat",
        EVENT_PLAYER_COMBAT_STATE,
        HideTargetFrame
    )

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "_Activated",
        EVENT_PLAYER_ACTIVATED,
        EnforceUI
    )

    -- Small width guard only. It never changes anchors or positions.
    local attributeGuard = WINDOW_MANAGER:CreateControl(
        ADDON_NAME .. "_AttributeGuard",
        GuiRoot,
        CT_CONTROL
    )

    attributeGuard:SetHandler("OnUpdate", function(control, elapsed)
        control._elapsed = (control._elapsed or 0) + elapsed

        if control._elapsed >= 0.03 then
            control._elapsed = 0
            ApplyNormalAttributeBarWidth()
        end
    end)

    -- Small target-frame guard only.
    local targetGuard = WINDOW_MANAGER:CreateControl(
        ADDON_NAME .. "_TargetGuard",
        GuiRoot,
        CT_CONTROL
    )

    targetGuard:SetHandler("OnUpdate", function(control, elapsed)
        control._elapsed = (control._elapsed or 0) + elapsed

        if control._elapsed >= 0.25 then
            control._elapsed = 0
            HideTargetFrame()
        end
    end)

    EnforceUI()
    zo_callLater(EnforceUI, 250)
    zo_callLater(EnforceUI, 1000)

    EVENT_MANAGER:UnregisterForEvent(
        ADDON_NAME,
        EVENT_ADD_ON_LOADED
    )
end

EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME,
    EVENT_ADD_ON_LOADED,
    OnAddOnLoaded
)
