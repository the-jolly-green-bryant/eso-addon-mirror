BannerStatus = {}
BannerStatus.name = "BannerStatus"
BannerStatus.version = "1.0.6"

-- Default settings
BannerStatus.defaults = {
    scale = 7.5, -- Default scale
}

-- All Banner Bearer buff IDs
BannerStatus.bannerEffectIds = {
    217705, 217704, 217706, 227003, 227004, 227007, 227008,
    227066, 227070, 227071, 227073, 227075, 227082
}

-- Addon loaded event
function BannerStatus.OnAddOnLoaded(event, addonName)
    if addonName ~= BannerStatus.name then return end
    EVENT_MANAGER:UnregisterForEvent(BannerStatus.name, EVENT_ADD_ON_LOADED)

    -- Load saved variables (account-wide)
    BannerStatus.SV = ZO_SavedVars:NewAccountWide(
        "BannerStatusSavedVariables",
        1, -- version
        nil, -- namespace
        BannerStatus.defaults
    )

    BannerStatus.Initialize()
end

-- Initialize addon
function BannerStatus.Initialize()
    EVENT_MANAGER:RegisterForUpdate(BannerStatus.name .. "_Init", 100, function()
        if BannerStatusIndicator ~= nil then
            EVENT_MANAGER:UnregisterForUpdate(BannerStatus.name .. "_Init")

            BannerStatusIndicatorLabel:SetColor(1, 0, 0, 1)
            BannerStatusIndicatorLabel:SetAlpha(1)

            -- Keep container centered
            BannerStatusIndicator:ClearAnchors()
            BannerStatusIndicator:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)

            -- Apply saved scale
            BannerStatusIndicatorLabel:SetScale(BannerStatus.SV.scale)

            BannerStatus.UpdateIndicator()

            EVENT_MANAGER:RegisterForEvent(BannerStatus.name, EVENT_EFFECT_CHANGED, BannerStatus.OnEffectChanged)
            EVENT_MANAGER:AddFilterForEvent(BannerStatus.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

            -- Poll for banner status
            EVENT_MANAGER:RegisterForUpdate(BannerStatus.name .. "_Poll", 250, BannerStatus.UpdateIndicator)

            BannerStatus.SetupSettingsMenu()
        end
    end)
end

-- Check if any banner buff is active
function BannerStatus.IsBannerActive()
    for i = 1, GetNumBuffs("player") do
        local _, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        for _, bannerId in ipairs(BannerStatus.bannerEffectIds) do
            if abilityId == bannerId then
                return true
            end
        end
    end
    return false
end

-- Update visibility
function BannerStatus.UpdateIndicator()
    if BannerStatusIndicator ~= nil then
        BannerStatusIndicator:SetHidden(BannerStatus.IsBannerActive())
    end
end

-- Buff event handler
function BannerStatus.OnEffectChanged(event, changeType, effectSlot, effectName, unitTag,
    beginTime, endTime, stackCount, iconName, buffType, effectType, abilityId, source)
    if unitTag ~= "player" then return end
    for _, bannerId in ipairs(BannerStatus.bannerEffectIds) do
        if abilityId == bannerId then
            zo_callLater(BannerStatus.UpdateIndicator, 100)
            return
        end
    end
end

-- Settings menu
function BannerStatus.SetupSettingsMenu()
    if not LibAddonMenu2 then return end

    local panelData = {
        type = "panel",
        name = "BannerStatus",
        displayName = "BannerStatus",
        author = "Phamo 1000",
        version = BannerStatus.version,
        registerForRefresh = true,
        registerForDefaults = true
    }

    local optionsTable = {
        {
            type = "slider",
            name = "Text Scale",
            tooltip = "Adjust the size of the 'Activate Banner' text",
            min = 0.5,
            max = 15.0, -- Increased max range
            step = 0.05,
            getFunc = function() return BannerStatus.SV.scale end,
            setFunc = function(value)
                BannerStatus.SV.scale = value
                if BannerStatusIndicatorLabel then
                    BannerStatusIndicatorLabel:SetScale(value)
                end
            end,
            width = "full",
            default = BannerStatus.defaults.scale
        }
    }

    LibAddonMenu2:RegisterAddonPanel(BannerStatus.name .. "_Panel", panelData)
    LibAddonMenu2:RegisterOptionControls(BannerStatus.name .. "_Panel", optionsTable)
end

-- Register event
EVENT_MANAGER:RegisterForEvent(BannerStatus.name, EVENT_ADD_ON_LOADED, BannerStatus.OnAddOnLoaded)
