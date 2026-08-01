DIALOGUE = {}

local systemName = "Dialogue"
function DIALOGUE.GetName() return systemName end

local dialogueTarget = nil
function DIALOGUE.GetTarget() return dialogueTarget end

function SetTarget(name, title)
    dialogueTarget = {}
    dialogueTarget.name = name
    dialogueTarget.title = title
    if title ~= nil and title ~= "" then d("Dialogue target set to "..name.." ("..title..").")
    elseif title == nil or title == "" then d("Dialogue target set to "..name..".")
    end
end

function DIALOGUE.GetTargetName()
    if dialogueTarget ~= nil
    then return dialogueTarget.name
    else return nil
    end
end
function DIALOGUE.GetTargetTitle()
    if dialogueTarget ~= nil
    then return dialogueTarget.title
    else return nil
    end
end

function ResetTarget()
    dialogueTarget = nil
    d("Dialogue target wiped.")
end

EVENT_MANAGER:RegisterForEvent(systemName, EVENT_CLIENT_INTERACT_RESULT, function(eventCode, result, interactTargetName)
    local name = zo_strformat("<<1>>", interactTargetName)
    local title = GetUnitCaption("reticleover")
    if title ~= nil then
        local subTitleBeginning = string.find(title,"(", 1, true)
        if subTitleBeginning ~= nil then title = string.sub(title, 1, subTitleBeginning - 2) end
    end
    SetTarget(name, title)
end)

EVENT_MANAGER:RegisterForEvent(systemName, EVENT_CHATTER_END, function(eventCode)
    ResetTarget()
end)