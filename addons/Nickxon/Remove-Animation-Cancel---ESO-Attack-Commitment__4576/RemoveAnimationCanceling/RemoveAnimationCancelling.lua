local namespace = "RemoveAnimationCancelling"

EVENT_MANAGER:RegisterForEvent(namespace, EVENT_ADD_ON_LOADED, function(_, addonName)

    if addonName ~= namespace then
        return
    end

    local savedVariables = ZO_SavedVars:NewAccountWide(namespace .. "Vars", 1, nil, {

        skillBlockEnabled = true,

        enableCustomTimings = false,

        oneHandAnimationTime = 365,
        twoHandAnimationTime = 540,

        enableActionBarPulse = true,

        -- default is now SOFT pulse
        aggressivePulseMode = false,
    })



    local panelConfig = {

        type = "panel",
        name = "Remove Animation Cancelling",
        author = "@STUDLETON + @NICKXON",
        version = "1.0",
        registerForRefresh = true,
    }



    local optionsConfig = {

        {
            type = "checkbox",
            name = "Enable Skill Blocking",
            tooltip = "Enable blocking skill casts until attacks finish.",

            getFunc = function()
                return savedVariables.skillBlockEnabled
            end,

            setFunc = function(value)
                savedVariables.skillBlockEnabled = value
            end,
        },

        {
            type = "checkbox",
            name = "Enable Combat Pulse Effect",
            tooltip = "Displays a combat pulse when combat actions become available again.",

            getFunc = function()
                return savedVariables.enableActionBarPulse
            end,

            setFunc = function(value)
                savedVariables.enableActionBarPulse = value
            end,
        },

        {
            type = "checkbox",
            name = "Use Aggressive Combat Pulse",
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
            name = "Enable Custom Timing Adjustment",
            tooltip = "Changing timing values may affect combat pacing and DPS comparability.",

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
            type = "button",
            name = "Reset to Default",
            tooltip = "Restore the recommended default timing values.",

            func = function()

                savedVariables.oneHandAnimationTime = 365
                savedVariables.twoHandAnimationTime = 540

            end,

            width = "full",
        },
    }



    LibAddonMenu2:RegisterAddonPanel(namespace .. "Settings", panelConfig)

    LibAddonMenu2:RegisterOptionControls(namespace .. "Settings", optionsConfig)



    local lastAttack = nil
    local currentAnimationTime = 0



------------------------------------------------
-- COMBAT PULSE
------------------------------------------------

    local combatPulse = WINDOW_MANAGER:CreateTopLevelWindow("RACCombatPulse")

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
-- COMBAT EVENT
------------------------------------------------

    EVENT_MANAGER:RegisterForEvent(namespace, EVENT_ACTION_SLOT_ABILITY_USED, function(_, slot)

        if slot == 1 or slot == 2 then

            lastAttack = GetGameTimeMilliseconds()



            if savedVariables.skillBlockEnabled then

                if not IsActionLayerActiveByName("No_Roll_Dodge") then
                    PushActionLayerByName("No_Roll_Dodge")
                end



                local animationTime = savedVariables.twoHandAnimationTime



                local weaponType = GetItemWeaponType(BAG_WORN, EQUIP_SLOT_MAIN_HAND)



                if weaponType == WEAPONTYPE_AXE
                or weaponType == WEAPONTYPE_DAGGER
                or weaponType == WEAPONTYPE_HAMMER
                or weaponType == WEAPONTYPE_SWORD then

                    animationTime = savedVariables.oneHandAnimationTime
                end



                currentAnimationTime = animationTime



                zo_callLater(function()

                    if IsActionLayerActiveByName("No_Roll_Dodge") then
                        RemoveActionLayerByName("No_Roll_Dodge")
                    end



                    PlayActionBarPulse()

                end, animationTime)
            end
        end
    end)



------------------------------------------------
-- LOCK CHECK
------------------------------------------------

    local function IsLocked()

        if not lastAttack then
            return false
        end



        return (GetGameTimeMilliseconds() - lastAttack) < currentAnimationTime
    end



------------------------------------------------
-- ACTION BLOCK
------------------------------------------------

    ZO_PreHook("ZO_ActionBar_CanUseActionSlots", function()

        if savedVariables.skillBlockEnabled and IsLocked() then
            return true
        end

    end)

end)