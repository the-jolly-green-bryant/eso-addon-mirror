local SIT = SkillIssueTracker
local utils = SIT.utils

local RETICLE_UNIT_TAG = "reticleover"


utils.getPlayerReticleInfo = function()
    if not IsUnitPlayer(RETICLE_UNIT_TAG) then return end
    local currentHealth, maxHealth = GetUnitPower(RETICLE_UNIT_TAG, POWERTYPE_HEALTH)
    local data = {
        characterName = zo_strformat(SI_UNIT_NAME, GetUnitName(RETICLE_UNIT_TAG)),
        displayName = GetUnitDisplayName(RETICLE_UNIT_TAG),
        class = GetUnitClassId(RETICLE_UNIT_TAG),
        race = GetUnitRaceId(RETICLE_UNIT_TAG),
        level = GetUnitLevel(RETICLE_UNIT_TAG),
        cp = GetUnitChampionPoints(RETICLE_UNIT_TAG),
        currentMark = GetUnitTargetMarkerType(RETICLE_UNIT_TAG),
        currentHealth = currentHealth,
        maxHealth = maxHealth,
        unitTag = RETICLE_UNIT_TAG,
        isUnitDead = IsUnitDead(RETICLE_UNIT_TAG)
    }

    if not data.isDead then
        data["seenAt"] = GetFrameTimeMilliseconds()
    end

    return data
end