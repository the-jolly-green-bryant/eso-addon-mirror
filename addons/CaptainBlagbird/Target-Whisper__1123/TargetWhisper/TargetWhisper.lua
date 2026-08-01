--[[

Target Whisper
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Addon info
TargetWhisper = {}
TargetWhisper.name = "TargetWhisper"
local SLASH_CMD = GetString(TARGETWHISPER_SLASH_CMD)
-- Local variables
local lastPlayer = ""
local lastEnemy = ""
local savedVars = {}
local num_reset_p = 0
local num_reset_e = 0
-- Language
local MSG_INVALID_INPUT = GetString(TARGETWHISPER_MSG_INVALID_INPUT)
local MSG_USAGE         = GetString(TARGETWHISPER_MSG_USAGE)
local MSG_CURRENT_TIME  = GetString(TARGETWHISPER_MSG_CURRENT_TIME)
local MSG_SET_TO        = GetString(TARGETWHISPER_MSG_SET_TO)
local MSG_SECONDS       = GetString(TARGETWHISPER_MSG_SECONDS)
local MSG_TIME_OFF      = GetString(TARGETWHISPER_MSG_TIME_OFF)


-- Function for starting chat with targeted player
function TargetWhisper.Start(isUntargetedEnabled)
    if IsUnitPlayer("reticleover") then
        -- Open chat in target mode
        local name = GetUnitNameHighlightedByReticle()
        StartChatInput("", CHAT_CHANNEL_WHISPER, name)
    elseif isUntargetedEnabled then
        -- Normal chat behavior
        StartChatInput("")
    end
end

-- Function for starting chat with last targeted player/enemy
function TargetWhisper.StartLast(isEnemyOnlyEnabled)
    local target = lastPlayer
    if isEnemyOnlyEnabled then target = lastEnemy end
    
    if target ~= "" then
        -- Open chat in target mode
        StartChatInput("", CHAT_CHANNEL_WHISPER, target)
    else
        -- Normal chat behavior
        StartChatInput("")
    end
end

-- Event handler function for EVENT_RETICLE_TARGET_CHANGED
local function OnReticleTargetChanged(eventCode)
    -- Only continue if Saved Variables are set up and target is player
    if savedVars.timeLast == nil then return end
    if not IsUnitPlayer("reticleover") then return end
    
    local ms = savedVars.timeLast * 1000
    
    -- Remember player
    lastPlayer = GetUnitNameHighlightedByReticle()
    if savedVars.timeLast > 0 then
        -- Reset after specified time
        num_reset_p = num_reset_p + 1
        zo_callLater(function()
                num_reset_p = num_reset_p - 1
                if num_reset_p <= 0 then
                    num_reset_p = 0
                    lastPlayer=""
                end
            end, ms)
    end
    
    -- Only continue if target is enemy
    if not IsUnitAttackable("reticleover") then return end
    
    -- Remember enemy player
    lastEnemy = lastPlayer
    if savedVars.timeLast > 0 then
        -- Reset after specified time
        num_reset_e = num_reset_e + 1
        zo_callLater(function()
                num_reset_e = num_reset_e - 1
                if num_reset_e <= 0 then
                    num_reset_e = 0
                    lastEnemy=""
                end
            end, ms)
    end
end
EVENT_MANAGER:RegisterForEvent(TargetWhisper.name, EVENT_RETICLE_TARGET_CHANGED, OnReticleTargetChanged)

-- Function to change the timeout time by slash command
local function ChangeTimeout(str)
    local function PrintCurrentTimeout(isNew)
        if savedVars.timeLast == 0 then
            d(MSG_TIME_OFF)
        else
            if isNew then
                d(MSG_SET_TO..tostring(savedVars.timeLast)..MSG_SECONDS)
            else
                d(MSG_CURRENT_TIME..tostring(savedVars.timeLast)..MSG_SECONDS)
            end
        end
    end
    
    -- No argument: Print usage and current timeout
    if str == "" then
        d(MSG_USAGE)
        PrintCurrentTimeout()
        return
    end
    -- Invalid argument: Print error message, usage and current timeout
    local n = tonumber(str)
    if type(n) ~= "number" or n < 0 then
        d(MSG_INVALID_INPUT)
        d(MSG_USAGE)
        PrintCurrentTimeout()
        return
    end
    -- Valid argument: Save value and print current timeout
    savedVars.timeLast = n
    PrintCurrentTimeout(true)
end

-- Event handler function for EVENT_PLAYER_ACTIVATED
local function OnPlayerActivated(event)
    -- Set up Saved Variables
    savedVars = ZO_SavedVars:New("TargetWhisperSavedVariables", 1, nil, {timeLast=0})
    
    -- Set up slash command
    SLASH_COMMANDS[SLASH_CMD] = ChangeTimeout
    
    EVENT_MANAGER:UnregisterForEvent(TargetWhisper.name, EVENT_PLAYER_ACTIVATED)
end
EVENT_MANAGER:RegisterForEvent(TargetWhisper.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)