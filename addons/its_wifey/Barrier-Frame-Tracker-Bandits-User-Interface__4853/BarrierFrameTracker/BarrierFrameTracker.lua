local ADDON = "BarrierFrameTracker"
local DISPLAY_NAME = "Wifey's Barrier Frame Tracker"
local VERSION = "1.0"
local ICON_SIZE = 24

-- Barrier / morph effect IDs.
local BARRIER_IDS = { [38573]=true, [40237]=true, [40239]=true }
local icons = {}
local SV

local defaults = {
    enabled = true,
}

local function GetMemberIndex(unitTag)
    if not BUI or not BUI.Group or not unitTag then return nil end
    local data = BUI.Group[unitTag]
    return data and data.index or nil
end

local function GetIcon(unitTag)
    local index = GetMemberIndex(unitTag)
    if not index then return nil end

    local member = _G["BUI_RaidFrame" .. index]
    if not member then return nil end

    local icon = icons[index]
    if not icon then
        icon = WINDOW_MANAGER:CreateControl(ADDON .. "_Icon" .. index, member, CT_TEXTURE)
        icon:SetDimensions(ICON_SIZE, ICON_SIZE)
        icon:ClearAnchors()
        icon:SetAnchor(LEFT, member, RIGHT, 3, 0)
        icon:SetDrawTier(DT_HIGH)
        icon:SetDrawLayer(DL_OVERLAY)
        icon:SetHidden(true)
        icons[index] = icon
    end
    return icon
end

local function HideAll()
    for _, icon in pairs(icons) do
        icon:SetHidden(true)
    end
end

local function OnEffectChanged(_, changeType, _, _, unitTag, _, _, _, _, _, _, _, _, _, _, abilityId, sourceType)
    if not SV or not SV.enabled then return end
    if not BARRIER_IDS[abilityId] then return end
    if not unitTag or (unitTag ~= "player" and not unitTag:find("^group%d+$")) then return end

    -- Only display Reviving Barrier applied by the local player.
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then return end

    local icon = GetIcon(unitTag)
    if not icon then return end

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        local texture = GetAbilityIcon(abilityId)
        if texture and texture ~= "" then
            icon:SetTexture(texture)
        end
        icon:SetHidden(false)
    elseif changeType == EFFECT_RESULT_FADED then
        icon:SetHidden(true)
    end
end

local function OnGroupChanged()
    HideAll()
end

local function CreateSettings()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = DISPLAY_NAME,
        displayName = DISPLAY_NAME,
        author = "WifeyRytic",
        version = VERSION,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "checkbox",
            name = "Enable HUD",
            tooltip = "Show Reviving Barrier icons on the right side of Bandits UI group frames.",
            getFunc = function() return SV.enabled end,
            setFunc = function(value)
                SV.enabled = value
                if not value then HideAll() end
            end,
            default = defaults.enabled,
            width = "full",
        },
    }

    LAM:RegisterAddonPanel(ADDON .. "Options", panelData)
    LAM:RegisterOptionControls(ADDON .. "Options", optionsData)
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON, EVENT_ADD_ON_LOADED)

    SV = ZO_SavedVars:NewAccountWide("BarrierFrameTrackerSavedVariables", 1, nil, defaults)
    CreateSettings()

    EVENT_MANAGER:RegisterForEvent(ADDON .. "Effect", EVENT_EFFECT_CHANGED, OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(ADDON .. "Effect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

    EVENT_MANAGER:RegisterForEvent(ADDON .. "PlayerEffect", EVENT_EFFECT_CHANGED, OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(ADDON .. "PlayerEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    EVENT_MANAGER:RegisterForEvent(ADDON .. "Group", EVENT_GROUP_UPDATE, OnGroupChanged)
end

EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_ADD_ON_LOADED, OnAddonLoaded)
