-- Shortcuts
local CE = CustomEmotes
local LAM = LibAddonMenu2
local internal = CE.internal
local actions = CE.actions
local CONS = internal.constants

-- Initializes the interpreter
local interpreter = internal.interpreter or {}
internal.interpreter = interpreter

interpreter.currentActionsPlaying = {}
interpreter.currentActionsData = {}
interpreter.shouldOpenEditorOnExit = false
interpreter.antiServerKickLog = {}

-- Personality management
interpreter.initialPersonality = 0
interpreter.lastPersonalitySwap = 0

-- Check the actions logic
function interpreter.checkActionsLogic(actionList)

    -- If logic validation is false return an empty list
    if not CE.savedVars.validatesLogic then
        return {}
    end

    -- Table to store one error per action max
    local errors = {}
    
    -- Control to step through the actions
    local currentIndex = 1

    -- To control if an emote has been played, it clears when a wait is found
    local lastWasEmote = false

    -- To detect infinite loops, it clears when a REPEAT_FROM gate is consumed
    local alreadyCheckedJumps = {}

    -- To detect loops that needed to wait, it clears when a wait is found
    local indexLoopWaits = {}

    -- To simulate REPEAT_FROM asuming 2 repetition
    local consumedRepeats = {}
    -- Initialize the consumedRepeats to 0
    for i = 1, #actionList do
        consumedRepeats[i] = 0
    end
  
    -- Max verifications to avoid infinite loops
    local maxVerifications = 1000
    while maxVerifications > 0 do

        -- Check if the index is out of bounds
        if currentIndex < 1 or currentIndex > #actionList then
            -- Emote has finished
            break
        end

        local currentAction = actionList[currentIndex]
        if currentAction.type == actions.PLAY then

            -- Check if an emote has been played without a wait
            if lastWasEmote then
                errors[currentIndex] = zo_strformat(CONS.INTERPRETER_CONSECUTIVE_EMOTES_ERROR, currentIndex)
            end

            lastWasEmote = true -- Require wait for next emote
            currentIndex = currentIndex + 1 -- Normal jump

        elseif currentAction.type == actions.WAIT then

            lastWasEmote = false -- Clear require wait for emotes
            indexLoopWaits = {} -- Clear all loops that needed to wait
            currentIndex = currentIndex + 1  -- Normal jump

        elseif currentAction.type == actions.JUMP then

            -- Check that the jump first gate has a wait
            if indexLoopWaits[currentIndex] then
                errors[currentIndex] = zo_strformat(CONS.INTERPRETER_LOOP_DETECTED_ERROR, currentIndex)
            end
            indexLoopWaits[currentIndex] = true

            -- Check if this jump has already been validated (Valid infinite loop)
            if alreadyCheckedJumps[currentIndex] then
                break
            end
            alreadyCheckedJumps[currentIndex] = true

            -- Jumps to specified index
            currentIndex = currentAction.value

        elseif currentAction.type == actions.JUMP_FIRST then

            -- Check that the jump first gate has a wait
            if indexLoopWaits[currentIndex] then
                errors[currentIndex] = zo_strformat(CONS.INTERPRETER_LOOP_DETECTED_ERROR, currentIndex)
            end
            indexLoopWaits[currentIndex] = true

            -- Check if this jump has already been validated (Valid infinite loop)
            if alreadyCheckedJumps[currentIndex] then
                break
            end
            alreadyCheckedJumps[currentIndex] = true

            -- Jumps to first action
            currentIndex = 1 

        elseif currentAction.type == actions.REPEAT_FROM then

            -- This gate can behave like a jump or like nothing
            if consumedRepeats[currentIndex] > 1 then
                -- Behave like nothing, next step
                currentIndex = currentIndex + 1 
            else
                consumedRepeats[currentIndex] = consumedRepeats[currentIndex] + 1 -- Increase flag to asume 2 repetitions
                alreadyCheckedJumps = {} -- Reset the jumps check since logic can change inside another loop
    
                -- Gate to check if this loop has a wait
                if indexLoopWaits[currentIndex] then
                    errors[currentIndex] = zo_strformat(CONS.INTERPRETER_LOOP_DETECTED_ERROR, currentIndex)
                end
                indexLoopWaits[currentIndex] = true

                -- Jumps to the specified index
                currentIndex = currentAction.value.action

            end

        elseif currentAction.type == actions.INTERRUPT then
            lastWasEmote = false -- Allow playing consecutive emotes if interrupted
            currentIndex = currentIndex + 1
        elseif currentAction.type == actions.PERSONALITY then
            currentIndex = currentIndex + 1
        end

        maxVerifications = maxVerifications - 1
    end

    -- Return value expects list
    local errorsList = {}
    for _, error in pairs(errors) do
        table.insert(errorsList, error)
    end
    return errorsList

end

-- Compiles an emote into a string
function interpreter.getErrorsFromEmote(emote)

    local errors = {}

    -- Check if the emote has a name
    if emote.name == nil or emote.name == "" then
        table.insert(errors, CONS.INTERPRETER_EMOTE_NO_NAME_ERROR)
    end

    -- Validate emote name must be lowercase and only letters and numbers
    if not string.match(emote.name, "^[a-zA-Z0-9]*$") then
        table.insert(errors, CONS.INTERPRETER_EMOTE_NAME_INVALID_ERROR)
    end

    -- Check if the emote has a description
    if emote.description == nil or emote.description == "" then
        table.insert(errors, CONS.INTERPRETER_EMOTE_NO_DESCRIPTION_ERROR)
    end

    -- Check if the emote has actions
    if emote.actions == nil or #emote.actions == 0 then
        table.insert(errors, CONS.INTERPRETER_EMOTE_NO_ACTIONS_ERROR)
    end

    -- Check for errors in the actions
    local actionErrors = interpreter.getErrorsFromActions(emote.actions)
    for _, error in ipairs(actionErrors) do
        table.insert(errors, error)
    end

    -- If there are not errors, check the logic
    if #errors == 0 then
        local logicErrors = interpreter.checkActionsLogic(emote.actions)
        for _, error in ipairs(logicErrors) do
            table.insert(errors, error)
        end
    end
    
    return errors

end

function interpreter.serialize(emote)
    local result = ""
    for i, action in ipairs(emote.actions) do
        if action.type == CE.actions.PLAY then
            result = result .. CE.actions.PLAY .. "," .. action.value
        elseif action.type == CE.actions.WAIT then
            result = result .. CE.actions.WAIT .. "," .. action.value
        elseif action.type == CE.actions.JUMP then
            result = result .. CE.actions.JUMP .. "," .. action.value
        elseif action.type == CE.actions.JUMP_FIRST then
            result = result .. CE.actions.JUMP_FIRST
        elseif action.type == CE.actions.REPEAT_FROM then
            result = result .. CE.actions.REPEAT_FROM .. "," .. action.value.action .. "," .. action.value.times
        elseif action.type == CE.actions.INTERRUPT then
            result = result .. CE.actions.INTERRUPT .. "," .. action.value
        elseif action.type == CE.actions.PERSONALITY then
            result = result .. CE.actions.PERSONALITY .. "," .. action.value
        end
        if i < #emote.actions then
            result = result .. ";"
        end
    end
    return result
end

function interpreter.deserialize(code)
    local deserializedActions = {}
    local parts = internal.split(code, ";")
    for _, part in ipairs(parts) do
        local action = internal.split(part, ",")
        action[1] = tonumber(action[1])
        if action[1] == nil then
            return nil
        end
        if action[1] == CE.actions.PLAY then
            if #action ~= 2 or not action[2] then return nil end
            table.insert(deserializedActions, { type = CE.actions.PLAY, value = action[2] })
        elseif action[1] == CE.actions.WAIT then
            if #action ~= 2 then return nil end
            action[2] = tonumber(action[2])
            if not action[2] then return nil end
            table.insert(deserializedActions, { type = CE.actions.WAIT, value = action[2] })
        elseif action[1] == CE.actions.JUMP then
            if #action ~= 2 then return nil end
            action[2] = tonumber(action[2])
            if not action[2] then return nil end
            table.insert(deserializedActions, { type = CE.actions.JUMP, value = action[2] })
        elseif action[1] == CE.actions.JUMP_FIRST then
            if #action ~= 1 then return nil end
            table.insert(deserializedActions, { type = CE.actions.JUMP_FIRST })
        elseif action[1] == CE.actions.REPEAT_FROM then
            if #action ~= 3 then return nil end
            action[2] = tonumber(action[2])
            action[3] = tonumber(action[3])
            if not action[2] or not action[3] then return nil end
            table.insert(deserializedActions, { type = CE.actions.REPEAT_FROM, value = { action = action[2], times = action[3] } })
        elseif action[1] == CE.actions.INTERRUPT then
            if #action ~= 2 then return nil end
            action[2] = tonumber(action[2])
            if not action[2] then return nil end
            table.insert(deserializedActions, { type = CE.actions.INTERRUPT, value = action[2] })
        elseif action[1] == CE.actions.PERSONALITY then
            if #action ~= 2 then return nil end
            action[2] = tonumber(action[2])
            if not action[2] then return nil end
            table.insert(deserializedActions, { type = CE.actions.PERSONALITY, value = action[2] })
        else
            return nil
        end
    end
    return deserializedActions
end

-- Checks for any errors in the emote logic (emote has name, description and actions), an action has a type and value
function interpreter.getErrorsFromActions(actionList)

    local errors = {}

    for i, action in ipairs(actionList) do

        if action.type == actions.PLAY then

            local emoteName = internal.getEmoteByName(action.value)

            if not emoteName then
                table.insert(errors, zo_strformat(CONS.INTERPRETER_EMOTE_ACTION_NOT_EXIST_ERROR, i, action.value))
            elseif not internal.isEmoteUnlocked(action.value) then
                table.insert(errors, zo_strformat(CONS.INTERPRETER_EMOTE_ACTION_LOCKED_ERROR, i, action.value))
            end

        elseif action.type == actions.WAIT then

            -- Check if action value is a number
            if action.value <= 0 then
                table.insert(errors, zo_strformat(CONS.INTERPRETER_EMOTE_ACTION_TIME_ERROR, i))
            end

        elseif action.type == actions.JUMP then
            if action.value < 0 or action.value > #actionList then
                table.insert(errors, zo_strformat(CONS.INTERPRETER_EMOTE_ACTION_NOT_EXIST_ERROR, i, action.value))
            end

        elseif action.type == actions.JUMP_FIRST then

            if i ~= #actionList then
                table.insert(errors, CONS.INTERPRETER_EMOTE_ACTION_RESTART_ERROR)
            end

        elseif action.type == actions.REPEAT_FROM then

            -- Validate that value is a table
            if type(action.value) ~= "table" then
                table.insert(errors, zo_strformat(CONS.INTERPRETER_EMOTE_ACTION_DATA_ERROR, i))
            end

            local repeatFrom = action.value.action
            local repeatTimes = action.value.times

            if repeatFrom == nil or repeatFrom < 0 or repeatFrom > #actionList then
                table.insert(errors, zo_strformat(CONS.INTERPRETER_EMOTE_ACTION_NOT_EXIST_ERROR, i, action.value))
            end

            if repeatTimes == nil or repeatTimes <= 0 then
                table.insert(errors, zo_strformat(CONS.INTERPRETER_EMOTE_ACTION_TIMES_ERROR, i))
            end

        elseif action.type == actions.INTERRUPT then
            if action.value <= 0 and action.value >= 1000 then
                table.insert(errors, zo_strformat(CONS.INTERPRETER_EMOTE_ACTION_TIME_ERROR, i))
            end
        elseif action.type == actions.PERSONALITY then
            local personality = internal.personalityList[action.value]
            if not personality then
                table.insert(errors, zo_strformat(CONS.INTERPRETER_INDEX_PERSONALITY_NOT_FOUND_ERROR, i))
            end
        else
            table.insert(errors, zo_strformat(CONS.INTERPRETER_EMOTE_ACTION_INVALID_TYPE_ERROR, i))
        end

    end

    return errors

end

-- Stops the emote
function interpreter.stopEmote()

    internal.listenForEmote(false)
    internal.stopSheduledAction()
    interpreter.restorePersonality()

    interpreter.currentActionsData = {}
    interpreter.currentActionsPlaying = {}

    if (interpreter.shouldOpenEditorOnExit) then
        interpreter.shouldOpenEditorOnExit = false
        PlaySound(SOUNDS.QUEST_COMPLETED)
        zo_callLater(function() DoCommand(CE.menuCommand) end, 1000)
    end

end

-- Executes the emote logic
function interpreter.playEmote(emote)

    interpreter.currentActionsData = {}
    interpreter.currentActionsPlaying = emote.actions

    interpreter.savePersonality()
    internal.listenForEmote(true)
    interpreter.playActions(1)

end

-- Plays an emote animation
function interpreter.executePreventKick(callback)

    -- Logic to prevent server kicks
    if CE.savedVars.preventServerKick then
        local currentTime = GetFrameTimeMilliseconds()
        table.insert(interpreter.antiServerKickLog, currentTime)

        -- Remove timestamps outside the timeframe
        for i = #interpreter.antiServerKickLog, 1, -1 do
            if currentTime - interpreter.antiServerKickLog[i] > CE.timeFrameForEmotes then
                table.remove(interpreter.antiServerKickLog, i)
            end
        end

        if #interpreter.antiServerKickLog >= CE.maxEmotesPerFrame then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, CONS.EMOTE_PREVENT_SERVER_KICK)
            return false
        end
    end
    callback()
    return true
end

-- Restores the original personality, if saved is 0 then turn off current personality
function interpreter.restorePersonality()

    interpreter.swapPersonality(interpreter.initialPersonality, function() end)

end

-- Saves the original personality
function interpreter.savePersonality()

    interpreter.initialPersonality = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_PERSONALITY)

end

-- Changes personality or turns off if 0
function interpreter.usePersonality(personalityId)
    if personalityId == 0 then
        local currentPersonality = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_PERSONALITY)
        UseCollectible(currentPersonality) -- A second time turns off the personality
    else
        UseCollectible(personalityId)
    end
end

-- Swaps the personality
function interpreter.swapPersonality(personalityId, callback)

    -- Skip if the personality is already active
    if GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_PERSONALITY) == personalityId then
        callback()
        return
    end

    -- Don't swap personalities faster than 1 per second
    local timeElapsedSinceLastSwap = GetFrameTimeMilliseconds() - interpreter.lastPersonalitySwap
    if timeElapsedSinceLastSwap < 800 then
        local delay = 1200 - timeElapsedSinceLastSwap
        zo_callLater(function() 
            interpreter.usePersonality(personalityId)
            interpreter.lastPersonalitySwap = GetFrameTimeMilliseconds()
            callback()
        end, delay + 200) -- Add 200 milliseconds for safety
    else
        interpreter.lastPersonalitySwap = GetFrameTimeMilliseconds()
        interpreter.usePersonality(personalityId)
        callback()
    end

end

-- Executes the emote logic
function interpreter.playActions(actionIndex)

    if actionIndex < 1 or actionIndex > #interpreter.currentActionsPlaying then

        interpreter.stopEmote()
        return

    end

    local action = interpreter.currentActionsPlaying[actionIndex]

    if action.type == actions.PLAY then
        local emote = internal.getEmoteByName(action.value)
        if emote then
            if interpreter.executePreventKick(function() PlayEmoteByIndex(emote.index) end) then
                interpreter.playActions(actionIndex + 1)
            else
                interpreter.stopEmote()
            end
        else
            d(zo_strformat(CONS.INTERPRETER_EMOTE_NOT_FOUND_ERROR, action.value))
            interpreter.stopEmote()
        end
        
    elseif action.type == actions.WAIT then
        internal.scheduleAction(action.value, actionIndex + 1)

    elseif action.type == actions.JUMP then
        interpreter.playActions(action.value)

    elseif action.type == actions.JUMP_FIRST then
        interpreter.playActions(1)

    elseif action.type == actions.REPEAT_FROM then
        local repeatFrom = action.value.action
        local repeatTimes = action.value.times

        local currentTimes = interpreter.currentActionsData[repeatFrom]
        if currentTimes == nil then
            currentTimes = 0
            interpreter.currentActionsData[repeatFrom] = 0
        end

        if currentTimes < repeatTimes then
            interpreter.currentActionsData[repeatFrom] = currentTimes + 1
            interpreter.playActions(repeatFrom)
        else
            interpreter.currentActionsData[repeatFrom] = 0
            interpreter.playActions(actionIndex + 1)
        end

    elseif action.type == actions.INTERRUPT then
        internal.interruptEmote(action.value or 0, function() 
            interpreter.playActions(actionIndex + 1)
        end)
    elseif action.type == actions.PERSONALITY then

        local personality = internal.personalityList[action.value]

        if personality then

            local continueEmoteAfterPersonalitySwapCallback = function()
                zo_callLater(function() interpreter.playActions(actionIndex + 1) end, 100)
            end

            local personalityCallback = function()
                interpreter.swapPersonality(personality.collectibleId, continueEmoteAfterPersonalitySwapCallback)
            end

            if not interpreter.executePreventKick(personalityCallback) then
                interpreter.stopEmote()
            end
        else
            d(zo_strformat(CONS.INTERPRETER_PERSONALITY_NOT_FOUND_ERROR, action.value))
            interpreter.stopEmote()
        end
    else
        interpreter.stopEmote()
    end

end