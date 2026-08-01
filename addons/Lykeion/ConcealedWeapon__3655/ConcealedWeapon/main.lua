ConcealedWeapon = {
    name = "ConcealedWeapon",
    version = "1.3",

    varVersion = 1, -- savedVariables version
    uiLocked = true,
    defaultSettings = {}
}

local CW_SKILL_ID = 25267 -- CW skill id
-- local CW_BUFF_ID = 34739 -- CW buff id
local CW_BUFF_ID = 34739 -- Major Berserker buff id
local ME_BUFF_ID = 61736 -- Major Expedition buff id

local ST = ConcealedWeapon
local NAME = ST.name
local EM = EVENT_MANAGER
local SV

local inCombat = false

local stFragment
local cwSlotted = false -- currently tracking Stagger (player is DK, Stone Giant is slotted)
local meEnd = 0 -- when ME effect ends (game seconds)
local meActive = false -- whether ME effect is active
local cwEnd = 0 -- when CW effect ends (game seconds)
local cwActive = false -- whether CW effect is active
local stStacks = 0 -- current number of stacks

local function Initialize()

    SV = ZO_SavedVars:New("ConcealedWeaponSV", ST.varVersion, nil, ST.defaultSettings)

    ST.RestorePosition()

    -- Create UI fragment.
    stFragment = ZO_SimpleSceneFragment:New(ConcealedWeaponControl)
    stFragment:SetConditional(function()
        return cwSlotted and inCombat or not ST.uiLocked
    end)
    HUD_SCENE:AddFragment(stFragment)
    HUD_UI_SCENE:AddFragment(stFragment)

    -- Update CW duration.
    local function UpdateDuration()
        local cwRemain = cwEnd - GetGameTimeSeconds()
        if cwRemain < 0 then
            cwRemain = 0
        end
        local meRemain = meEnd - GetGameTimeSeconds()
        if meRemain < 0 then
            meRemain = 0
        end

        ConcealedWeaponControl_CWDuration:SetText(zo_ceil(cwRemain))
        -- ConcealedWeaponControl_MEDuration:SetText(zo_ceil(meRemain))

        if cwActive then
            ConcealedWeaponControl_BG:SetColor(0, 0, 1)
        end
        if meActive then
            if not cwActive then
                ConcealedWeaponControl_BG:SetColor(0, 1, 0)
            end
        else
            if not cwActive then
                ConcealedWeaponControl_BG:SetColor(1, 0, 0)
            end
        end
    end

    local function OnMajorExpedition(_, changeType, _, _, _, _, endTime, stackCount, _, _, _, _, _, _, unitId, abilityId)
        meEnd = endTime
        UpdateDuration()
        if changeType == EFFECT_RESULT_FADED then
            meActive = false
        elseif (changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED) then
            meActive = true
        end
    end

    local function OnConcealedWeapon(_, changeType, _, _, _, _, endTime, stackCount, _, _, _, _, _, _, unitId, abilityId)
        cwEnd = endTime
        UpdateDuration()
        if changeType == EFFECT_RESULT_FADED then
            cwActive = false
        elseif changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
            cwActive = true
        end
    end

    -- Combat state changes.
    local function CombatState()
        inCombat = IsUnitInCombat("player")
        EM:UnregisterForUpdate(NAME .. 'Update')
        if inCombat and cwSlotted then
            EM:RegisterForUpdate(NAME .. 'Update', 200, function()
                UpdateDuration()
            end)
        end
        stFragment:Refresh()
    end

    -- Check if CW is slotted.
    local function SkillCheck()
        cwSlotted = false
        for i = 3, 7 do
            local slot1 = GetSlotBoundId(i, HOTBAR_CATEGORY_PRIMARY)
            local slot2 = GetSlotBoundId(i, HOTBAR_CATEGORY_BACKUP)
            if CW_SKILL_ID == slot1 or CW_SKILL_ID == slot2 then
                cwSlotted = true
                break
            end
        end
        CombatState()
    end

    local function OnSlotUpdated(_, n)
        local id = GetSlotBoundId(n)
        if id == CW_SKILL_ID then
            ConcealedWeaponControl_Icon:SetDesaturation(1)
        end
    end

    if GetUnitClassId('player') == 3 then -- register events only for NB
        EM:RegisterForEvent(NAME, EVENT_PLAYER_ACTIVATED, SkillCheck)
        EM:RegisterForEvent(NAME, EVENT_PLAYER_COMBAT_STATE, CombatState)
        EM:RegisterForEvent(NAME, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, SkillCheck)
        EM:RegisterForEvent(NAME, EVENT_ACTION_SLOT_UPDATED, OnSlotUpdated)

        EM:RegisterForEvent(NAME .. "ME", EVENT_EFFECT_CHANGED, OnMajorExpedition)
        EM:AddFilterForEvent(NAME .. "ME", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, ME_BUFF_ID)

        EM:RegisterForEvent(NAME .. "CW", EVENT_EFFECT_CHANGED, OnConcealedWeapon)
        EM:AddFilterForEvent(NAME .. "CW", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, CW_BUFF_ID)
        EM:AddFilterForEvent(NAME .. "CW", EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
            COMBAT_UNIT_TYPE_PLAYER)
    end

end

function ST.Move()

    SV.controlCenterX, SV.controlCenterY = ConcealedWeaponControl:GetCenter()

    ConcealedWeaponControl:ClearAnchors()
    ConcealedWeaponControl:SetAnchor(CENTER, GuiRoot, TOPLEFT, SV.controlCenterX, SV.controlCenterY)

end

function ST.RestorePosition()

    local controlCenterX = SV.controlCenterX
    local controlCenterY = SV.controlCenterY

    if controlCenterX or controlCenterY then
        ConcealedWeaponControl:ClearAnchors()
        ConcealedWeaponControl:SetAnchor(CENTER, GuiRoot, TOPLEFT, controlCenterX, controlCenterY)
    end

    ConcealedWeaponControl_Icon:SetTexture(GetAbilityIcon(CW_BUFF_ID))

end

local function OnAddOnLoaded(event, addonName)
    if addonName == NAME then
        EM:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
        Initialize()
    end
end

EM:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

SLASH_COMMANDS["/ConcealedWeapon"] = function(str)
    ST.uiLocked = not ST.uiLocked
    stFragment:Refresh()
end
