local SIT = SkillIssueTracker
local utils = SIT.utils


utils.getPlayerReticleInfo = function()
    local unitTag = "reticleover"
    if not IsUnitPlayer(unitTag) then return end
    local currentHealth, maxHealth = GetUnitPower(unitTag, POWERTYPE_HEALTH)
    return {
        characterName = zo_strformat(SI_UNIT_NAME, GetUnitName(unitTag)),
        displayName = GetUnitDisplayName(unitTag),
        class = GetUnitClassId(unitTag),
        race = GetUnitRaceId(unitTag),
        level = GetUnitLevel(unitTag),
        cp = GetUnitChampionPoints(unitTag),
        currentMark = GetUnitTargetMarkerType(unitTag),
        currentHealth = currentHealth,
        maxHealth = maxHealth,
        unitTag = unitTag,
        isDead = IsUnitDead(unitTag)
    }
end