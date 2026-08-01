
wssAddon = {}
wssAddon.name = "WeaponSprintSensitivityFix"

WSS_SPRINT_STATE_SPRINTING_HAS_STAM = 1 -- sprint button is down, player is sprinting (has stamina)
WSS_SPRINT_STATE_TRYING_SPRINT_NO_STAM = 2 -- sprint button is down, player is not sprinting (out of stamina)
WSS_SPRINT_STATE_NOT_SPRINTING = 3  -- sprint button is up, and player is not sprinting (duh)

--[[
    possible state transitions:
        NOT_SPRINTING -> SPRINTING_HAS_STAM             player pressed sprint while char has stamina
        SPRINTING_HAS_STAM -> NOT_SPRINTING             player stopped pressing sprint while sprinting
        SPRINTING_HAS_STAM -> TRYING_SPRINT_NO_STAM     character ran out of stamina while player was pressing sprint
        TRYING_SPRINT_NO_STAM -> NOT_SPRINTING          player stopped pressing sprint afeter char ran out of stamina while sprinting

    The only way to start sprinting after running out of sprint is to release and re-press the sprint button.
--]]

WSS_CAM_STATE_FAST = 0
WSS_CAM_STATE_SLOW = 1

wssAddon.camera_state = WSS_CAM_STATE_SLOW
wssAddon.weapons_sheathed = true
wssAddon.sprint_state = WSS_SPRINT_STATE_NOT_SPRINTING
wssAddon.sprint_button = false
wssAddon.moving = false
wssAddon.position_cache = {x = 0, y = 0, z = 0}
wssAddon.res_status = false -- true = ghost form
wssAddon.hamstrung = false
wssAddon.prevHamstrung = false

function wssAddon:OnAddOnLoaded(addonName)
    if addonName == RTIaddon.name then
        wssAddon:Initialize()
    end
end


function tokenizeCommand(argString)
    local args = {}
    local argTable = { string.match(argString,"^(%S*)%s*(.-)$") }
        for i,v in pairs(argTable) do
        if (v ~= nil and v ~= "") then
            args[i] = string.lower(v)
        end
    end
    return args
end

function wssAddon:ApplyNormalCameraSettings()
    SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_SENSITIVITY_THIRD_PERSON, "" .. self.saved_variables.cam_sens.third_person)
    SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_SENSITIVITY_FIRST_PERSON, "" .. self.saved_variables.cam_sens.first_person)
    --d("Applying normal settings")
end

function wssAddon:ApplyFasterCameraSettings()
    SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_SENSITIVITY_THIRD_PERSON, "" .. self.saved_variables.cam_sens.third_person * 2)
    SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_SENSITIVITY_FIRST_PERSON, "" .. self.saved_variables.cam_sens.first_person * 2)
   --d("Applying sprint settings")
end

-- sprint combat event does not trigger.
-- there's no event for weapon sheath/unsheath.
-- either of those two mean we have to constantly check to know when state changes.  

function wssAddon:CheckWeaponSprintStatus()
    local shift = IsShiftKeyDown()
    local toggledSprintOn = false
    local toggledSprintOff = false
    if shift ~= wssAddon.sprint_button then
        --d("toggled sprint")
        wssAddon.sprint_button = shift
        toggledSprintOn = shift == true
        toggledSprintOff = shift == false
    end

    local gainedHamstrung = false --(not wssAddon.prevHamstrung) and wssAddon.hamstrung
    local lostHamstrung = false --wssAddon.prevHamstrung and (not wssAddon.hamstrung)

    local moving = false
    local id, x, y, z = GetUnitWorldPosition("player")
    --d("pos: " .. x .. ", " .. y .. ", " .. z)
    if (not (x == wssAddon.position_cache.x and z == wssAddon.position_cache.z)) then
        moving = true
        wssAddon.position_cache.x = x
        wssAddon.position_cache.z = z
    else
        moving = false
    end

    local startedMoving = false
    local stoppedMoving = false
    if moving ~= wssAddon.moving then
        startedMoving = moving == true
        stoppedMoving = moving == false
        wssAddon.moving = moving
    end

    local weaponStatus = ArePlayerWeaponsSheathed()
    local weaponsEquipped = false
    local weaponsUnequipped = false
    if weaponStatus ~= wssAddon.weapons_sheathed then
        --d("weapon status")
        weaponsEquipped = weaponStatus == false
        weaponsUnequipped = weaponStatus == true
    end

    local startedSprinting = false
    local stoppedSprinting = false

    if wssAddon.sprint_state == WSS_SPRINT_STATE_NOT_SPRINTING then
        if toggledSprintOn then
            local cur, max, effMax = GetUnitPower("player", POWERTYPE_STAMINA)
            if cur > 0 then
                wssAddon.sprint_state = WSS_SPRINT_STATE_SPRINTING_HAS_STAM
                startedSprinting = true
            end
        elseif toggledSprintOff then
            -- d("State machine warning A") -- released sprint button.  Not really a problem.  Happens on ui load/reload.
            stoppedSprinting = true
        end
    elseif wssAddon.sprint_state == WSS_SPRINT_STATE_SPRINTING_HAS_STAM then
        local cur, max, effMax = GetUnitPower("player", POWERTYPE_STAMINA)
        if toggledSprintOn then
            d("[WeapnSprintSens] State machine error B. Notify the addon author!") -- sprint button pressed while already sprinting
        elseif toggledSprintOff then
            -- don't care about our stamina, go right to the no sprint state.
            wssAddon.sprint_state = WSS_SPRINT_STATE_NOT_SPRINTING
            stoppedSprinting = true
        elseif cur <= 0 then
            wssAddon.sprint_state = WSS_SPRINT_STATE_TRYING_SPRINT_NO_STAM
            stoppedSprinting = true
        end
    elseif wssAddon.sprint_state == WSS_SPRINT_STATE_TRYING_SPRINT_NO_STAM then
        if toggledSprintOn then
            d("[WeapnSprintSens] State machine error C. Notify the addon author!") -- pressed sprint button when the sprint button should still be down
            stoppedSprinting = true
        elseif toggledSprintOff then
            wssAddon.sprint_state = WSS_SPRINT_STATE_NOT_SPRINTING
        end
    end

    if      (startedMoving or startedSprinting or weaponsEquipped or lostHamstrung)
        and ((not weaponStatus) and moving and wssAddon.sprint_state == WSS_SPRINT_STATE_SPRINTING_HAS_STAM)
    then
        wssAddon:ApplyFasterCameraSettings()
        --d("Sprointjing")
        wssAddon.camera_state = WSS_CAM_STATE_FAST
    end

    if      (stoppedMoving or stoppedSprinting or weaponsUnequipped or gainedHamstrung)
        and (wssAddon.camera_state == WSS_CAM_STATE_FAST)
    then
        wssAddon:ApplyNormalCameraSettings()
        --d("Not prointging")
        wssAddon.camera_state = WSS_CAM_STATE_SLOW
    end

    wssAddon.weapons_sheathed = weaponStatus

end

function wssAddon:saveCamSens()
    local cam_sens = {}
    cam_sens.third_person = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_SENSITIVITY_THIRD_PERSON)
    cam_sens.first_person = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_SENSITIVITY_FIRST_PERSON)
    self.saved_variables.cam_sens = cam_sens
end

function wssAddon:applyCamSens()
    SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_SENSITIVITY_THIRD_PERSON, "" .. self.saved_variables.cam_sens.third_person)
    SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_SENSITIVITY_FIRST_PERSON, "" .. self.saved_variables.cam_sens.first_person)
end



function wssAddon.Effect(event, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceUnitType)
    -- hamstrung
    if abilityId == 8239 then
        if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_FULL_REFRESH then
            --d("Hamstrung")
            wssAddon.hamstrung = true
        elseif changeType == EFFECT_RESULT_FADED then
            --d("no longer hamstrung")
            wssAddon.hamstrung = false
        end
    end
    
    --d(effectName .. ", " .. abilityId .. ", " .. changeType .. ", " .. buffType)
    --if abilityId == 8239 then
    --    d("hamstrung: " .. buffType .. ", " .. statusEffectType .. " (" .. STATUS_EFFECT_TYPE_SNARE .. ")")
    --end
    --if buffType == BUFF_EFFECT_TYPE_DEBUFF and statusEffectType == STATUS_EFFECT_TYPE_SNARE and unitTag == "player" then
    --    d("Snared")
    --end
    --GetAbilityName(abilityId)
end

function wssAddon:Initialize()
    EVENT_MANAGER:RegisterForUpdate(wssAddon.name, 1, wssAddon.CheckWeaponSprintStatus)
    --EVENT_MANAGER:RegisterForEvent(wssAddon.name, EVENT_EFFECT_CHANGED, wssAddon.Effect)

    wssAddon.weapons_sheathed = ArePlayerWeaponsSheathed()
    wssAddon.sprint_button = IsShiftKeyDown()

    SLASH_COMMANDS["/camsens"] = function(argstr)
        local args = tokenizeCommand(argstr)
        --d(args)
        if args[1] == "apply" then
            -- apply cachced sens to game.  Useful if you crash while sens is modified.
            wssAddon:applyCamSens()

        elseif args[1] == "clean" then
            -- re-cache the sens settings.  For when we didn't detect a change.
            wssAddon:saveCamSens()
        elseif args[1] == "print" then
            d("Saved cam sens is: " .. wssAddon.saved_variables.cam_sens.third_person .. ", " .. wssAddon.saved_variables.cam_sens.first_person)
            d("cam sens is: " .. GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_SENSITIVITY_THIRD_PERSON) .. ", " .. GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_SENSITIVITY_FIRST_PERSON))
            d("If they don't match, run /camsens apply or /camsens clean")
        else
            d(wssAddon.saved_variables.cam_sens)
            d("Invalid arguments!\n\"/camsens apply\" to reapply saved cam sens.  Useful if you crash.\n\"/camsens clean\" to update the cached cam sens.  Use if you change your cam sens setting.")
        end

    end

    self.saved_variables = ZO_SavedVars:New("CachedCamSens", 1, nil, {})
    if self.saved_variables.cam_sens == nil then
        local cam_sens = {}
        cam_sens.third_person = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_SENSITIVITY_THIRD_PERSON)
        cam_sens.first_person = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_SENSITIVITY_FIRST_PERSON)
        self.saved_variables.cam_sens = cam_sens
    end

end


EVENT_MANAGER:RegisterForEvent(wssAddon.name, EVENT_ADD_ON_LOADED, wssAddon.OnAddOnLoaded)











