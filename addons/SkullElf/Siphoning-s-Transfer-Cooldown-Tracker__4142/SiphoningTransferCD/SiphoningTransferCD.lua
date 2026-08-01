local COOLDOWN_DURATION
local ABILITY_ID = 45146 -- This is for rank 2 of Transfer
local SKILL_ID = 45145 
local TEXTURE_PATH = "/esoui/art/icons/passive_sorcerer_002.dds"

local cooldownActive = false
local pulseActive = false

-- Shared state
local mode = "none" -- "cooldown", "pulse", or "none"
local startTime = 0

local STCD_Fragment ---@type ZO_HUDFadeSceneFragment

-- ===============================================
-- Forward Function Declarations
-- ===============================================

local IsTransferActive ---@type fun():boolean
local RefreshVisibility ---@type fun()
local SharedOnUpdate ---@type fun()
local StartPulse ---@type fun()
local StopPulse ---@type fun()
local StartCooldown ---@type fun()
local OnCombatEvent ---@type fun(eventCode:integer, result:ActionResult, isError:boolean, abilityName:string, abilityGraphic:integer, abilityActionSlotType:ActionSlotType, sourceName:string, sourceType:CombatUnitType, targetName:string, targetType:CombatUnitType, hitValue:integer, powerType:CombatMechanicFlags, damageType:DamageType, log:boolean, sourceUnitId:integer, targetUnitId:integer, abilityId:integer, overflow:integer)
local OnCombatStateChanged ---@type fun(eventCode:integer, inCombat:boolean)
local OnAddOnsLoaded ---@type fun(eventCode:integer)

-- ===============================================

---@class STCD_Settings_Defaults
local STCD_Settings_Defaults =
{
    unlockUI = false,
    allowPulse = true,
    baseScale = 10, -- 0.5 * 20
    position = { x = 300, y = 300 },
}

---@class STCD_Settings : STCD_Settings_Defaults
local STCD_Settings = ...

-- ===============================================

---@return boolean
IsTransferActive = function ()
    local skillType, skillLineIndex, skillIndex, _, _ = GetSpecificSkillAbilityKeysByAbilityId(SKILL_ID)
    if not skillType or not skillLineIndex or not skillIndex then
        return false
    end
    
    local skillData = SKILLS_DATA_MANAGER:GetSkillDataByIndices(skillType, skillLineIndex, skillIndex)
    if skillData then
        return skillData:IsPurchased()
    end
    
    return false
end

-- Fragment Management Functions
-- ===============================================

---Updates the fragment's visibility based on all current conditions
---@return nil
RefreshVisibility = function ()
    if not STCD_Fragment then
        return
    end
    -- Hide if siphoning skill line is not active
    STCD_Fragment:SetHiddenForReason("skill_line_inactive", not IsTransferActive())

    -- Hide if UI is locked and no active state
    local hasActiveState = (mode == "cooldown") or (mode == "pulse")
    STCD_Fragment:SetHiddenForReason("no_active_state", not STCD_Settings.unlockUI and not hasActiveState)
end

-- ===============================================

SharedOnUpdate = function ()
    if mode == "cooldown" then
        local now = GetFrameTimeMilliseconds()
        local elapsedTime = now - startTime
        local remaining = COOLDOWN_DURATION - elapsedTime

        if remaining <= 0 then
            cooldownActive = false
            STCD_Control_Scaler_TimerLabel:SetText("")
            STCD_Control_Scaler:SetScale(STCD_Settings.baseScale or 1.0)

            if IsUnitInCombat("player") then
                StartPulse()
            else
                mode = "none"
                RefreshVisibility()
            end
        else
            local seconds = zo_floor((remaining / 100)) / 10
            STCD_Control_Scaler_TimerLabel:SetText(string.format("%.1f", seconds))
        end
    elseif mode == "pulse" then
        local base = STCD_Settings.baseScale or 1.0
        local sineScale = base + 0.15 * zo_sin(GetFrameTimeMilliseconds() / 1000 * 2 * ZO_PI)
        STCD_Control_Scaler:SetScale(sineScale)
    elseif mode == "none" then
        STCD_Control:SetHandler("OnUpdate", nil)
        STCD_Control_Scaler:SetScale(STCD_Settings.baseScale or 1.0)
        STCD_Control_Scaler_TimerLabel:SetText("")
        RefreshVisibility()
    end
end

StartPulse = function ()
    if not STCD_Settings.allowPulse then
        return
    end

    if pulseActive then
        return
    end

    pulseActive = true
    cooldownActive = false
    mode = "pulse"

    STCD_Control_Scaler:SetScale(STCD_Settings.baseScale or 1.0)
    STCD_Control_Scaler_TimerLabel:SetText("")
    RefreshVisibility()

    STCD_Control:SetHandler("OnUpdate", SharedOnUpdate)
end

StopPulse = function ()
    pulseActive = false
    mode = "none"
    STCD_Control_Scaler:SetScale(STCD_Settings.baseScale or 1.0)

    STCD_Control:SetHandler("OnUpdate", nil)
    RefreshVisibility()
end

StartCooldown = function ()
    if pulseActive then
        pulseActive = false
        STCD_Control_Scaler:SetScale(STCD_Settings.baseScale or 1.0)
    end

    cooldownActive = true
    mode = "cooldown"
    startTime = GetFrameTimeMilliseconds()

    STCD_Control_Scaler_TimerLabel:SetText("")
    RefreshVisibility()
    STCD_Control:SetHandler("OnUpdate", SharedOnUpdate)
end

--- @param eventCode integer
--- @param result integer
--- @param isError boolean
--- @param abilityName string
--- @param abilityGraphic integer
--- @param abilityActionSlotType integer
--- @param sourceName string
--- @param sourceType integer
--- @param targetName string
--- @param targetType integer
--- @param hitValue integer
--- @param powerType integer
--- @param damageType integer
--- @param log boolean
--- @param sourceUnitId string
--- @param targetUnitId string
--- @param abilityId integer
--- @param overflow integer
OnCombatEvent = function (eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
	if sourceType == COMBAT_UNIT_TYPE_PLAYER then
        StartCooldown()
    end
end

--- @param eventCode integer
--- @param inCombat boolean
OnCombatStateChanged = function (eventCode, inCombat)
    if inCombat then
        -- Only pulse if not on cooldown
        if not cooldownActive then
            StartPulse()
        end
    else
        if pulseActive then
            StopPulse()
        end
    end
    -- Always refresh visibility when combat state changes
    RefreshVisibility()
end

--- @param eventCode integer
OnAddOnsLoaded = function (eventCode)
    COOLDOWN_DURATION = GetAbilityCooldown(ABILITY_ID, "player")

    STCD_Control:UnregisterForEvent(EVENT_ADD_ONS_LOADED)
    STCD_Settings = ZO_SavedVars:NewAccountWide("STCDSavedVariables", 1, nil, STCD_Settings_Defaults, GetWorldName(), zo_strformat(GetString(SI_UNIT_NAME), GetDisplayName()))
    STCD_Control_Scaler_Icon:SetTexture(TEXTURE_PATH)
    STCD_Control:ClearAnchors()
    STCD_Control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, STCD_Settings.position.x, STCD_Settings.position.y)

    STCD_Control:SetMovable(STCD_Settings.unlockUI)

    STCD_Control:SetHandler("OnMoveStop", function ()
        local left = STCD_Control:GetLeft()
        local top = STCD_Control:GetTop()
        STCD_Settings.position.x = left
        STCD_Settings.position.y = top
    end)

    -- Create and setup fragment
    STCD_Fragment = ZO_HUDFadeSceneFragment:New(STCD_Control, nil, 0)

    -- Register state change callback to keep addon logic in sync
    STCD_Fragment:RegisterCallback("StateChange", function (oldState, newState)
        -- Keep visibility logic in sync with fragment state changes
        RefreshVisibility()

        -- Manage animations based on fragment visibility
        if newState == SCENE_FRAGMENT_SHOWING or newState == SCENE_FRAGMENT_SHOWN then
            -- Fragment is becoming/became visible - restart appropriate animations
            if mode == "pulse" or mode == "cooldown" then
                STCD_Control:SetHandler("OnUpdate", SharedOnUpdate)
            end
        elseif newState == SCENE_FRAGMENT_HIDING or newState == SCENE_FRAGMENT_HIDDEN then
            -- Fragment is becoming/became hidden - pause animations to save performance
            STCD_Control:SetHandler("OnUpdate", nil)
        end
    end)

    -- Add to HUD scene
    HUD_SCENE:AddFragment(STCD_Fragment)

    -- Add to HUD UI scene
    HUD_UI_SCENE:AddFragment(STCD_Fragment)

    -- Initial visibility setup
    RefreshVisibility()

    STCD_Control:RegisterForEvent(EVENT_COMBAT_EVENT, OnCombatEvent)
    STCD_Control:AddFilterForEvent(EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, ABILITY_ID, REGISTER_FILTER_IS_ERROR, false)

    STCD_Control:RegisterForEvent(EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)

    local LAM = LibAddonMenu2
    local panel =
    {
        type = "panel",
        name = "Transfer Cooldown Tracker",
        displayName = "Siphoning Transfer CD",
        author = "SkullElf, DakJaniels",
        version = "1.0",
		slashCommand = "/stcd",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local options =
    {
        {
            type = "checkbox",
            name = "Unlock UI",
            tooltip = "Keep the UI visible and movable.",
            getFunc = function ()
                return STCD_Settings.unlockUI
            end,
            setFunc = function (val)
                STCD_Settings.unlockUI = val
                STCD_Control:SetMovable(val)
                RefreshVisibility()
            end,
            width = "full",
            default = STCD_Settings_Defaults.unlockUI,
        },
        {
            type = "checkbox",
            name = "Pulse for Reminder",
            tooltip = "Enable pulsing when the cooldown ends.",
            getFunc = function ()
                return STCD_Settings.allowPulse
            end,
            setFunc = function (val)
                STCD_Settings.allowPulse = val
            end,
            width = "full",
            default = STCD_Settings_Defaults.allowPulse,
        },
        {
            type = "slider",
            name = "Base Scale",
            tooltip = "Set the base size of the cooldown icon.",
            min = 10, -- 0.5 * 20
            max = 40, -- 2.0 * 20
            step = 1, -- 0.05 * 20
            getFunc = function ()
                return zo_floor((STCD_Settings.baseScale or 1.0) * 20 + 0.5)
            end,
            setFunc = function (val)
                local scale = val / 20
                STCD_Settings.baseScale = scale
                STCD_Control_Scaler:SetScale(scale)
            end,
            width = "full",
            default = STCD_Settings_Defaults.baseScale * 20, -- 1.0 * 20
        },
    }

    LAM:RegisterAddonPanel("SiphoningTransferCDPanel", panel)
    LAM:RegisterOptionControls("SiphoningTransferCDPanel", options)

    -- Final visibility check
    RefreshVisibility()
end

STCD_Control:RegisterForEvent(EVENT_ADD_ONS_LOADED, OnAddOnsLoaded)
