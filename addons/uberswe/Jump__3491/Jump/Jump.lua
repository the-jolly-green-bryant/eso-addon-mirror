JUMP = {}

JUMP.name = "Jump"
JUMP.savedData = {}
JUMP.isJumping = false
JUMP.overallJumpCount = 0
JUMP.groupJumpCount = 0
JUMP.combatJumpCount = 0
JUMP.timeSinceLastJump = 0
JUMP.delay = 100
JUMP.isInGroup = false
JUMP.isInCombat = false

function JUMP:Initialize()
    -- Do some init stuff
    JUMP.savedData = ZO_SavedVars:NewAccountWide('JumpSavedVariables', 1, nil, systemDefault, nil, JUMP.name)

    if not JUMP.savedData then
        JUMP.savedData = {}
        JUMP.savedData.hidden = false
    end

    if JUMP.savedData.overallJumpCount then
        JUMP.overallJumpCount = JUMP.savedData.overallJumpCount
    end

    if JUMP.savedData.groupJumpCount then
        JUMP.groupJumpCount = JUMP.savedData.groupJumpCount
    end

    if IsUnitGrouped("player") then
        JUMP.isInGroup = true
    else
        JUMP.isInGroup = false
        JUMP.groupJumpCount = 0
    end

    if IsUnitInCombat("player") then
        JUMP.isInCombat = true
        JUMP.combatJumpCount = 0
    else
        JUMP.isInCombat = false
    end
    JUMPUI:SetHidden(JUMP.savedData.hidden)
    JUMP:UpdateUI()
end

function JUMP:UpdateUI()
    JUMP_OVERALL_LABEL:SetText(string.format("Lifetime jumps: %d", JUMP.overallJumpCount))
    JUMP_GROUP_LABEL:SetText(string.format("Group jumps: %d", JUMP.groupJumpCount))
    JUMP_COMBAT_LABEL:SetText(string.format("Combat jumps: %d", JUMP.combatJumpCount))
end

EVENT_MANAGER:RegisterForUpdate("JumpAddon", JUMP.delay, function()
    if IsUnitInAir("player") and not IsUnitFalling("player") then
        if not JUMP.isJumping or JUMP.timeSinceLastJump > 1100 then
            JUMP.isJumping = true
            JUMP.overallJumpCount = JUMP.overallJumpCount + 1
            if JUMP.isInGroup then
                JUMP.groupJumpCount = JUMP.groupJumpCount + 1
                JUMP.savedData.groupJumpCount = JUMP.groupJumpCount
            end
            if JUMP.isInCombat then
                JUMP.combatJumpCount = JUMP.combatJumpCount + 1
            end
            JUMP.savedData.overallJumpCount = JUMP.overallJumpCount
            JUMP.timeSinceLastJump = 0
            JUMP:UpdateUI()
        else
            JUMP.timeSinceLastJump = JUMP.timeSinceLastJump + JUMP.delay
        end
    else
        if JUMP.isJumping then
            JUMP.isJumping = false
            JUMP.timeSinceLastJump = 0
        end
    end
end)

function JUMP.OnCombatState()
    if IsUnitInCombat("player") then
        JUMP.isInCombat = true
        JUMP.combatJumpCount = 0
    else
        JUMP.isInCombat = false
    end
end

function JUMP.OnGroupChange()
    if IsUnitGrouped("player") then
        JUMP.isInGroup = true
    else
        JUMP.isInGroup = false
        JUMP.groupJumpCount = 0
        JUMP.savedData.groupJumpCount = 0
    end
end

function JUMP.OnAddOnLoaded(event, addonName)
    if addonName == JUMP.name then
        JUMP:Initialize()

        EVENT_MANAGER:UnregisterForEvent(JUMP.name, EVENT_ADD_ON_LOADED)

        EVENT_MANAGER:RegisterForEvent(JUMP.name, EVENT_PLAYER_COMBAT_STATE, JUMP.OnCombatState)
        EVENT_MANAGER:RegisterForEvent(JUMP.name, EVENT_GROUP_UPDATE, JUMP.OnGroupChange)
        EVENT_MANAGER:RegisterForEvent(JUMP.name, EVENT_GROUP_MEMBER_LEFT, JUMP.OnGroupChange)
        EVENT_MANAGER:RegisterForEvent(JUMP.name, EVENT_GROUP_MEMBER_JOINED, JUMP.OnGroupChange)


        JUMPUI:ClearAnchors()
        JUMPUI:SetAnchor (JUMP.savedData.point, parent, JUMP.savedData.relativePoint, JUMP.savedData.OffsetX, JUMP.savedData.OffsetY)
    end
end

function JUMP.Help(options)
    CHAT_ROUTER:AddSystemMessage("Jump counts your jumps")
    CHAT_ROUTER:AddSystemMessage("")
    CHAT_ROUTER:AddSystemMessage("/jumpreset - reset the overall Jumps")
    CHAT_ROUTER:AddSystemMessage("/jumpstats - display stats")
    CHAT_ROUTER:AddSystemMessage("/jumptoggle - show/hide ui")
    CHAT_ROUTER:AddSystemMessage("/jsg - post group stats in chat")
    CHAT_ROUTER:AddSystemMessage("/jsc - post combat stats in chat")
    CHAT_ROUTER:AddSystemMessage("/jsl - post lifetime stats in chat")
end

function JUMP.Reset(options)
    CHAT_ROUTER:AddSystemMessage("Jump count has been reset")
    JUMP.groupJumpCount = 0
    JUMP.savedData.groupJumpCount = 0
    JUMP.combatJumpCount = 0
    JUMP.overallJumpCount = 0
    JUMP.savedData.overallJumpCount = 0
end

function JUMP.Stats(options)
    CHAT_ROUTER:AddSystemMessage(string.format("Group jumps: %d", JUMP.groupJumpCount))
    CHAT_ROUTER:AddSystemMessage(string.format("Combat jumps: %d", JUMP.combatJumpCount))
    CHAT_ROUTER:AddSystemMessage(string.format("Lifetime jumps: %d", JUMP.overallJumpCount))
end

function JUMP.ShareGroup(options)
    if IsUnitGrouped("player") then
        StartChatInput(string.format("Group jumps: %d", JUMP.groupJumpCount), CHAT_CHANNEL_PARTY)
    else
        StartChatInput(string.format("Group jumps: %d", JUMP.groupJumpCount))
    end
end

function JUMP.ShareCombat(options)
    if IsUnitGrouped("player") then
        StartChatInput(string.format("Combat jumps: %d", JUMP.combatJumpCount), CHAT_CHANNEL_PARTY)
    else
        StartChatInput(string.format("Combat jumps: %d", JUMP.combatJumpCount))
    end
end

function JUMP.ShareOverall(options)
    if IsUnitGrouped("player") then
        StartChatInput(string.format("Lifetime jumps: %d", JUMP.overallJumpCount), CHAT_CHANNEL_PARTY)
    else
        StartChatInput(string.format("Lifetime jumps: %d", JUMP.overallJumpCount))
    end
end

function JUMP.ToggleUI(options)
    JUMPUI:SetHidden(not JUMP.savedData.hidden)
    JUMP.savedData.hidden = not JUMP.savedData.hidden
end

function JUMP_SaveUIPosition()
    local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = JUMPUI:GetAnchor()
    JUMP.savedData.OffsetX = offsetX
    JUMP.savedData.OffsetY = offsetY
    JUMP.savedData.point = point
    JUMP.savedData.relativePoint = relativePoint
end

SLASH_COMMANDS["/jump"] = JUMP.Help
SLASH_COMMANDS["/jumpreset"] = JUMP.Reset
SLASH_COMMANDS["/jumpstats"] = JUMP.Stats
SLASH_COMMANDS["/jumpsharegroup"] = JUMP.ShareGroup
SLASH_COMMANDS["/jumpsharecombat"] = JUMP.ShareCombat
SLASH_COMMANDS["/jumpsharelifetime"] = JUMP.ShareOverall
SLASH_COMMANDS["/jsg"] = JUMP.ShareGroup
SLASH_COMMANDS["/jsc"] = JUMP.ShareCombat
SLASH_COMMANDS["/jsl"] = JUMP.ShareOverall
SLASH_COMMANDS["/jumptoggle"] = JUMP.ToggleUI

EVENT_MANAGER:RegisterForEvent(JUMP.name, EVENT_ADD_ON_LOADED, JUMP.OnAddOnLoaded)