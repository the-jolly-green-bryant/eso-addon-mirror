local namespace = "Rhythmos"

EVENT_MANAGER:RegisterForEvent(namespace, EVENT_ADD_ON_LOADED, function(_, addonName)

    if addonName ~= namespace then
        return
    end

    local savedVariables = ZO_SavedVars:NewAccountWide(namespace .. "Vars", 1, nil, {


        enableCustomTimings = false,

        oneHandAnimationTime = 330,
        twoHandAnimationTime = 440,
	skillActionLockTime = 680,

        enableActionBarPulse = true,

        -- default is now SOFT pulse
        aggressivePulseMode = false,


    })



    local panelConfig = {

        type = "panel",
        name = "Rhythmos - Combat Overhaul",
        author = "NICKXON",
        version = "1.0",
        registerForRefresh = true,
    }



    local optionsConfig = {


        {
            type = "checkbox",
            name = "Enable Pulse Effect",
            tooltip = "Displays a pulse effect on the hotbar when skills become available again.",

            getFunc = function()
                return savedVariables.enableActionBarPulse
            end,

            setFunc = function(value)
                savedVariables.enableActionBarPulse = value
            end,
        },

        {
            type = "checkbox",
            name = "Accessibility Pulse Effect",
            tooltip = "Uses a brighter and thicker combat pulse effect.",

            getFunc = function()
                return savedVariables.aggressivePulseMode
            end,

            setFunc = function(value)
                savedVariables.aggressivePulseMode = value
            end,
        },

        {
            type = "checkbox",
            name = "Custom Timing Adjustment",
            tooltip = "These values are for debug reasons mainly. I do not recommend to change them. Decreasing these values will lead to cancelled animations. Increasing them will lead to eaten inputs and clunky gameplay.",

            getFunc = function()
                return savedVariables.enableCustomTimings
            end,

            setFunc = function(value)
                savedVariables.enableCustomTimings = value
            end,
        },

        {
            type = "slider",
            name = "1H Animation Time (Milliseconds)",
            tooltip = "Adjust the lock duration for one-handed weapon attacks.",

            disabled = function()
                return not savedVariables.enableCustomTimings
            end,

            getFunc = function()
                return savedVariables.oneHandAnimationTime
            end,

            setFunc = function(value)
                savedVariables.oneHandAnimationTime = value
            end,

            min = 1,
            max = 2000,
            step = 1,
        },

        {
            type = "slider",
            name = "2H Animation Time (Milliseconds)",
            tooltip = "Adjust the lock duration for two-handed weapon attacks.",

            disabled = function()
                return not savedVariables.enableCustomTimings
            end,

            getFunc = function()
                return savedVariables.twoHandAnimationTime
            end,

            setFunc = function(value)
                savedVariables.twoHandAnimationTime = value
            end,

            min = 1,
            max = 2000,
            step = 1,
        },
{
    type = "slider",
    name = "Skill Dodge Lock Time (Milliseconds)",
    tooltip = "Adjusts how long dodge rolling and weapon swapping are blocked after using a skill.",

    disabled = function()
        return not savedVariables.enableCustomTimings
    end,

    getFunc = function()
        return savedVariables.skillActionLockTime
    end,

    setFunc = function(value)
        savedVariables.skillActionLockTime = value
    end,

    min = 1,
    max = 2000,
    step = 1,
},
        {
            type = "button",
            name = "Reset to Default",
            tooltip = "Restore the recommended default timing values.",

            func = function()

                savedVariables.oneHandAnimationTime = 330
                savedVariables.twoHandAnimationTime = 440
		savedVariables.skillActionLockTime = 680

            end,

            width = "full",
        },
    }



    LibAddonMenu2:RegisterAddonPanel(namespace .. "Settings", panelConfig)

    LibAddonMenu2:RegisterOptionControls(namespace .. "Settings", optionsConfig)



local skillLockEndTime = 0
local attackLockEndTime = 0
local actionLockEndTime = 0


local INPUT_BUFFER_WINDOW = 315


------------------------------------------------
-- COMBAT PULSE
------------------------------------------------

    local combatPulse = WINDOW_MANAGER:CreateTopLevelWindow("CombatPulse")

    combatPulse:SetMouseEnabled(false)

    combatPulse:SetDrawLayer(DL_OVERLAY)

    combatPulse:SetHidden(false)



    local pulseTexture = WINDOW_MANAGER:CreateControl(nil, combatPulse, CT_BACKDROP)

    pulseTexture:SetAnchorFill(combatPulse)



    -- transparent center
    pulseTexture:SetCenterColor(0, 0, 0, 0)

    pulseTexture:SetAlpha(0)



    local function UpdatePulseStyle()

        if savedVariables.aggressivePulseMode then

            -- aggressive pulse
            pulseTexture:SetEdgeColor(1.0, 0.78, 0.22, 0.9)

            pulseTexture:SetEdgeTexture(nil, 64, 16, 16)

        else

            -- soft pulse
            pulseTexture:SetEdgeColor(1.0, 0.78, 0.22, 0.55)

            pulseTexture:SetEdgeTexture(nil, 32, 8, 8)

        end
    end



    local function UpdatePulseDimensions()

        local actionBar = ZO_ActionBar1

        if not actionBar then
            return
        end



        local width = actionBar:GetWidth()
        local height = actionBar:GetHeight()



        combatPulse:ClearAnchors()

local yOffset = 0

if IsInGamepadPreferredMode() then
    yOffset = -2
else
    yOffset = -10

end

        combatPulse:SetAnchor(CENTER, actionBar, CENTER, 0, yOffset)



        local isGamepad = IsInGamepadPreferredMode()

if savedVariables.aggressivePulseMode then

    -- AGGRESSIVE PULSE

    if isGamepad then

        -- CONTROLLER UI
        combatPulse:SetDimensions(

            width * 0.70,
            height * 1.63
        )

    else

        -- KBM UI
        combatPulse:SetDimensions(

            width * 0.63,
            height * 1.34
        )
    end

else

    -- SUBTLE PULSE

    if isGamepad then

        -- CONTROLLER UI
        combatPulse:SetDimensions(

            width * 0.67,
            height * 1.40
        )

    else

        -- KBM UI
        combatPulse:SetDimensions(

            width * 0.61,
            height * 1.13
        )
    end
end
    end



    local function PlayActionBarPulse()

        if not savedVariables.enableActionBarPulse then
            return
        end



        UpdatePulseDimensions()

        UpdatePulseStyle()



        local actionBar = ZO_ActionBar1

        if actionBar then

            actionBar:SetScale(1.018)

            zo_callLater(function()

                actionBar:SetScale(1.00)

            end, 90)
        end



        pulseTexture:SetAlpha(1)

        combatPulse:SetScale(0.96)



        local startTime = GetGameTimeMilliseconds()

        local duration = 180



        EVENT_MANAGER:RegisterForUpdate(namespace .. "PulseFade", 10, function()

            local elapsed = GetGameTimeMilliseconds() - startTime

            local progress = elapsed / duration



            if progress >= 1 then

                pulseTexture:SetAlpha(0)

                EVENT_MANAGER:UnregisterForUpdate(namespace .. "PulseFade")

                return
            end



            -- smooth fade
            pulseTexture:SetAlpha(1 - progress)



            -- soft expansion
            combatPulse:SetScale(0.96 + (progress * 0.06))

        end)
    end


------------------------------------------------
-- FAKE GLOBAL COOLDOWN
------------------------------------------------

local fakeGCDs = {}

local currentGCDId = 0
local gcdPulseConsumed = false

local function InitializeFakeGCDs()

    for i = 3, 7 do

        local button = ZO_ActionBar_GetButton(i)

        if button then

            local cooldown = WINDOW_MANAGER:CreateControl(
                nil,
                button.slot,
                CT_COOLDOWN
            )

            cooldown:SetAnchorFill(button.slot)

            cooldown:SetDrawLayer(DL_OVERLAY)

            cooldown:SetDrawTier(DT_HIGH)

            cooldown:SetHidden(true)

            fakeGCDs[i] = cooldown
        end
    end
end



local function PlayFakeGlobalCooldown()

currentGCDId = currentGCDId + 1

local thisGCD = currentGCDId

gcdPulseConsumed = false

    for i = 3, 7 do

        local cooldown = fakeGCDs[i]

        if cooldown then

            cooldown:SetHidden(false)

            cooldown:SetAlpha(0.65)

            cooldown:StartCooldown(
                2500,
                2500,
                CD_TYPE_RADIAL,
                nil,
                false
            )

        end
    end

    zo_callLater(function()

    if not gcdPulseConsumed
    and thisGCD == currentGCDId then

        PlayActionBarPulse()

    end

end, 2500)
end

InitializeFakeGCDs()

zo_callLater(function()

    for i = 3, 7 do

        local button = ZO_ActionBar_GetButton(i)

        local cooldown = button.slot:GetNamedChild("Cooldown")

        if cooldown then

            cooldown:SetHidden(true)

            cooldown:SetAlpha(0)

            cooldown:SetDrawLevel(-100)

            cooldown:SetDrawTier(-100)

        end
    end

end, 2500)


------------------------------------------------
-- LOCK CHECK
------------------------------------------------

local function IsLocked()

    local now = GetGameTimeMilliseconds()

    return now < skillLockEndTime
        or now < attackLockEndTime
end

------------------------------------------------
-- COMBAT EVENT
------------------------------------------------

EVENT_MANAGER:RegisterForEvent(namespace, EVENT_ACTION_SLOT_ABILITY_USED, function(_, slot)

    if slot >= 1 and slot <= 7 then

local now = GetGameTimeMilliseconds()

if slot >= 3 and slot <= 7
and currentGCDId > 0
and not gcdPulseConsumed
and now < (skillLockEndTime + INPUT_BUFFER_WINDOW) then

    gcdPulseConsumed = true

    PlayActionBarPulse()

end



            local animationTime = 0

if slot == 1 or slot == 2 then

    animationTime = savedVariables.twoHandAnimationTime

    local weaponType = GetItemWeaponType(BAG_WORN, EQUIP_SLOT_MAIN_HAND)

    if weaponType == WEAPONTYPE_AXE
    or weaponType == WEAPONTYPE_DAGGER
    or weaponType == WEAPONTYPE_HAMMER
    or weaponType == WEAPONTYPE_SWORD then

        animationTime = savedVariables.oneHandAnimationTime
    end

else

    -- SKILL GCD
    animationTime = 2500

end

local actionLockDuration = savedVariables.skillActionLockTime

-- weapon attacks use full animation lock
if slot == 1 or slot == 2 then
    actionLockDuration = animationTime
end

if not IsActionLayerActiveByName("No_Roll_Dodge") then
    PushActionLayerByName("No_Roll_Dodge")
end

actionLockEndTime = now + actionLockDuration

local now = GetGameTimeMilliseconds()

if slot >= 3 and slot <= 7 then

    skillLockEndTime = now + (animationTime - INPUT_BUFFER_WINDOW)

else

    attackLockEndTime = now + animationTime

end

zo_callLater(function()

    if GetGameTimeMilliseconds() >= actionLockEndTime then

        if IsActionLayerActiveByName("No_Roll_Dodge") then
            RemoveActionLayerByName("No_Roll_Dodge")
        end

    end

end, actionLockDuration)

if slot >= 3 and slot <= 7 then

    PlayFakeGlobalCooldown()

end

       
    end
end)


------------------------------------------------
-- ACTION BLOCK
------------------------------------------------

    ZO_PreHook("ZO_ActionBar_CanUseActionSlots", function()

        if IsLocked() then
            return true
        end

    end)

end)