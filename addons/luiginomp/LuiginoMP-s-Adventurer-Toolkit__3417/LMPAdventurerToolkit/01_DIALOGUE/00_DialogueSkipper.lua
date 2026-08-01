DIALOGUE_SKIPPER = {}

local systemName = "Dialogue Skipper"

function DIALOGUE_SKIPPER.GetName() return systemName end

local updateSystemsList = {}
function DIALOGUE_SKIPPER.AddToUpdateSystemsList(system)
    updateSystemsList[system] = system
end

local skipList = {}

local function AddToSkipList(name_title, skip)
    skipList[name_title] = skip
end

function DIALOGUE_SKIPPER.AddNPCToSkipList(name, location, skip)
    if name ~= nil and location ~= nil then
        if MAIN.accountVariables.skipList[name] == nil then MAIN.accountVariables.skipList[name] = {} end
        if MAIN.accountVariables.skipList[name].locations == nil then MAIN.accountVariables.skipList[name].locations = {} end
        if location ~= nil and MAIN.accountVariables.skipList[name].locations[location] == nil then
            MAIN.accountVariables.skipList[name].locations[location] = skip
            d(zo_strformat("Added [<<1>>].locations[<<2>>] to NPC Skip List.",name,location))
        else d(zo_strformat("Warning: [<<1>>].locations[<<2>>] already exists in NPC Skip List. Please use /updatenpcinskiplist to update properly.",name,location))
        end
    end
end

function DIALOGUE_SKIPPER.UpdateNPCInSkipList(name, location, skip)
    if name == nil or location == nil
    then d("Warning: Name and/or location are nil - cannot update NPC in Skip List.")
    else MAIN.accountVariables.skipList[name].locations[location] = skip
    end
end

function DIALOGUE_SKIPPER.GetNPCSkipList() return MAIN.accountVariables.skipList end

local skipSystemList = {}
function DIALOGUE_SKIPPER.AddToSkipSystemList(system)
    skipSystemList[system] = system
end

function DIALOGUE_SKIPPER.GetStatus()
    local activeStatus = MAIN.characterVariables.skipDialogue
    if activeStatus == true then d(systemName.." is active.")
    elseif activeStatus == false then d(systemName.." is inactive.")
    else
        d("WARNING - unkown status for "..systemName..": "..activeStatus)
        SOUNDS.PlayError()
    end
end

local function ProcessDialogue()
    if MAIN.characterVariables.skipDialogue == true then
        local importantOptionPresent = false
        for optionIndex = 1, GetChatterOptionCount() do
            local optionString, optionType, optionalArgument, isImportant, chosenBefore = GetChatterOption(optionIndex)
            if isImportant == true then importantOptionPresent = true end
        end
        if importantOptionPresent == true then
            d("Important option present.")
            SOUNDS.PlayAlert()
        else
            local optionTaken = false
            for optionIndex = 1, GetChatterOptionCount() do
                local optionString, optionType, optionalArgument, isImportant, chosenBefore = GetChatterOption(optionIndex)
                if chosenBefore == false then
                    SelectChatterOption(optionIndex)
                    optionTaken = true
                    break
                end
            end
            if optionTaken == false then EndInteraction(INTERACTION_CONVERSATION) end
        end
    end
end

function DIALOGUE_SKIPPER.SetStatus(isActive)
    MAIN.characterVariables.skipDialogue = isActive
    if MAIN.characterVariables.skipDialogue == true then
        EVENT_MANAGER:RegisterForEvent(systemName, EVENT_CHATTER_BEGIN, function(eventCode, optionCount) ProcessDialogue() end)
        EVENT_MANAGER:RegisterForEvent(systemName, EVENT_CONVERSATION_UPDATED, function(eventCode, conversationBodyText, conversationOptionCount) ProcessDialogue() end)
    elseif MAIN.characterVariables.skipDialogue == false then
        EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_CHATTER_BEGIN)
        EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_CONVERSATION_UPDATED)
    end
    DIALOGUE_SKIPPER.GetStatus()
    for key, system in pairs(updateSystemsList) do
        system.OnDialogueSkipUpdate()
    end
end

local ignoringSkipState = false
local function IgnoreSkipState(ignore)
    ignoringSkipState = ignore
    DIALOGUE_SKIPPER.SetStatus(not MAIN.characterVariables.skipDialogue)
end

EVENT_MANAGER:RegisterForEvent(systemName, EVENT_CLIENT_INTERACT_RESULT, function(eventCode, result, interactTargetName)
    local target = zo_strformat("<<1>>", interactTargetName)
    local title = GetUnitCaption("reticleover")
    if title ~= nil then
        local subTitleBeginning = string.find(title,"(", 1, true)
        if subTitleBeginning ~= nil then title = string.sub(title, 1, subTitleBeginning - 2) end
    end
    local location = GetMapName()
    if MAIN.characterVariables.skipDialogue == true and (skipList[target] == false or skipList[title] == false or (MAIN.accountVariables.skipList[target] ~= nil and MAIN.accountVariables.skipList[target].locations[location] == false)) then
        d("Interacting with non-skip entity.")
        IgnoreSkipState(true)
    elseif MAIN.characterVariables.skipDialogue == false and (skipList[target] == true or skipList[title] == true or (MAIN.accountVariables.skipList[target] ~= nil and MAIN.accountVariables.skipList[target].locations[location] == true)) then
        d("Interacting with skip entity.")
        IgnoreSkipState(true)
    end
end)

EVENT_MANAGER:RegisterForEvent(systemName, EVENT_CHATTER_END, function(eventCode)
    if ignoringSkipState == true then IgnoreSkipState(false) end
end)


function DIALOGUE_SKIPPER.Initialize()
    if MAIN.characterVariables.skipDialogue == nil then DIALOGUE_SKIPPER.SetStatus(false)
    else DIALOGUE_SKIPPER.SetStatus(MAIN.characterVariables.skipDialogue)
    end
    if MAIN.accountVariables.skipList == nil then MAIN.accountVariables.skipList = {} end
    for systemKey, system in pairs(skipSystemList) do
        local counter = 0
        local systemSkipList = system.GetDialogueSkipList()
        for entityKey, entity in pairs(systemSkipList) do
            local name_title = entity[1]
            local skip = entity[2]
            AddToSkipList(name_title, skip)
            counter = counter + 1
        end
        d(system.GetName()..": "..counter)
    end
end

MAIN.AddToInitializeSystemsList(DIALOGUE_SKIPPER)

SLASH_COMMANDS["/dialogueskipon"] = function()
    DIALOGUE_SKIPPER.SetStatus(true)
    SOUNDS.PlayAddonActivated()
end
SLASH_COMMANDS["/dialogueskipoff"] = function()
    DIALOGUE_SKIPPER.SetStatus(false)
    SOUNDS.PlayAddonDeactivated()
end
SLASH_COMMANDS["/dialogueskipstatus"] = function() DIALOGUE_SKIPPER.GetStatus() end
SLASH_COMMANDS["/skipon"] = function()
    DIALOGUE_SKIPPER.SetStatus(true)
    SOUNDS.PlayAddonActivated()
end
SLASH_COMMANDS["/skipoff"] = function()
    DIALOGUE_SKIPPER.SetStatus(false)
    SOUNDS.PlayAddonDeactivated()
end
SLASH_COMMANDS["/skipstatus"] = function() DIALOGUE_SKIPPER.GetStatus() end
SLASH_COMMANDS["/skiplist"] = function()
    local skipping = {}
    local notSkipping = {}
    for name_title, skip in pairs(skipList) do
        if skip == true then table.insert(skipping, name_title)
        elseif skip == false then table.insert(notSkipping, name_title) end
    end
    table.sort(skipping)
    table.sort(notSkipping)
    d("==========================================")
    d("Skipping:")
    for key, name_title in pairs(skipping) do
        d(name_title)
    end
    d("------------------------------------------")
    d("Not Skipping:")
    for key, name_title in pairs(notSkipping) do
        d(name_title)
    end
    d("==========================================")
end
SLASH_COMMANDS["/skiplistclear"] = function() MAIN.accountVariables.skipList = {} end