RIDING_TRAINER = {}
local systemName = "Riding Trainer"
function RIDING_TRAINER.GetName() return systemName end

function RIDING_TRAINER.GetStatus()
    local activeStatus = MAIN.characterVariables.autoTrainRiding
    if activeStatus == true then d(systemName.." is active.")
    elseif activeStatus == false then d(systemName.." is inactive.")
    else
        d("WARNING - unkown status for "..systemName..": "..activeStatus)
        SOUNDS.PlayError()
    end
    local inventoryBonus, maxInventoryBonus, staminaBonus, maxStaminaBonus, speedBonus, maxSpeedBonus = GetRidingStats()
    d(zo_strformat("Speed: <<1>>/<<2>>",speedBonus,maxSpeedBonus))
    d(zo_strformat("Stamina: <<1>>/<<2>>",staminaBonus,maxStaminaBonus))
    d(zo_strformat("Carry Capacity: <<1>>/<<2>>",inventoryBonus,maxInventoryBonus))
end

function RIDING_TRAINER.SetStatus(isActive)
    MAIN.characterVariables.autoTrainRiding = isActive
    if MAIN.characterVariables.autoTrainRiding == true then
        EVENT_MANAGER:RegisterForEvent(systemName, EVENT_STABLE_INTERACT_START, function(eventCode)
            d("EVENT_STABLE_INTERACT_START")
            local inventoryBonus, maxInventoryBonus, staminaBonus, maxStaminaBonus, speedBonus, maxSpeedBonus = GetRidingStats()
            if speedBonus < maxSpeedBonus then TrainRiding(RIDING_TRAIN_SPEED)
            elseif staminaBonus < maxStaminaBonus then TrainRiding(RIDING_TRAIN_STAMINA)
            else TrainRiding(RIDING_TRAIN_CARRYING_CAPACITY) end
        end)
        EVENT_MANAGER:RegisterForEvent(systemName, EVENT_RIDING_SKILL_IMPROVEMENT, function(eventCode, ridingSkillType, previous, current, source) d("EVENT_RIDING_SKILL_IMPROVEMENT") EndInteraction(INTERACTION_STABLE) end)
        EVENT_MANAGER:RegisterForEvent(systemName, EVENT_STABLE_INTERACT_END, function(eventCode) d("EVENT_STABLE_INTERACT_END") end)
    else
        EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_STABLE_INTERACT_START)
        EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_RIDING_SKILL_IMPROVEMENT)
        EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_STABLE_INTERACT_END)
    end
    RIDING_TRAINER.GetStatus()
end

function RIDING_TRAINER.Initialize()
    if MAIN.characterVariables.autoTrainRiding == nil then RIDING_TRAINER.SetStatus(true)
    else RIDING_TRAINER.SetStatus(MAIN.characterVariables.autoTrainRiding) end
end

MAIN.AddToInitializeSystemsList(RIDING_TRAINER)

SLASH_COMMANDS["/ridingtraineron"] = function() RIDING_TRAINER.SetStatus(true) end
SLASH_COMMANDS["/ridingtraineroff"] = function() RIDING_TRAINER.SetStatus(false) end