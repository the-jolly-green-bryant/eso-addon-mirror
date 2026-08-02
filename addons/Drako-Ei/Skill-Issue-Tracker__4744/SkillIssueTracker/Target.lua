local SIT = SkillIssueTracker
local target = SIT.target
target.targetList = {}

-- Sets a target marker for a specific player
target.setTarget = function(targetName, targetMark)

    if target.targetList[targetName] == targetMark then return end

    for name, mark in pairs(target.targetList) do
        if mark == targetMark then
            target.targetList[name] = nil
        end
    end

    target.targetList[targetName] = targetMark

end

-- Removes all targets
target.reset = function()
    target.targetList = {}
end

-- Called on reticle over event, sets the markers on players
target.updateTarget = function(targetInfo)
    if not targetInfo then return end
    local characterName = targetInfo.characterName
    local displayName = targetInfo.displayName

    local targetMark = target.targetList[displayName]
    if not targetMark then
        targetMark = target.targetList[characterName]
    end

    if targetMark then
        if targetInfo.currentMark ~= targetMark then
            AssignTargetMarkerToReticleTarget(targetMark)
        end
    end

end