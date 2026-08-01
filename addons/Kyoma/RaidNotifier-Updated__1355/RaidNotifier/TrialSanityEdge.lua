RaidNotifier = RaidNotifier or {}
RaidNotifier.SE = {}

local RaidNotifier = RaidNotifier

local function p() end
local function dbg() end

local data = {}

function RaidNotifier.SE.Initialize()
    p = RaidNotifier.p
    dbg = RaidNotifier.dbg

    data = {}
end

function RaidNotifier.SE.OnCombatEvent(_, result, _, _, _, _, _, _, tName, tType, hitValue, _, _, _, _, tUnitId, abilityId)
    local raidId = RaidNotifier.raidId
    local self   = RaidNotifier
    local buffsDebuffs, settings = self.BuffsDebuffs[raidId], self.Vars.sanityEdge

    if (tName == nil or tName == "") then
        tName = self.UnitIdToString(tUnitId)
    end

    if (result == ACTION_RESULT_BEGIN) then
        -- Ansuul's Sunburst
        if (abilityId == buffsDebuffs.ansuul_sunburst and settings.ansuul_sunburst > 0) then
            if (tType == COMBAT_UNIT_TYPE_PLAYER) then
                self:AddAnnouncement(GetString(RAIDNOTIFIER_ALERTS_SANITYEDGE_ANSUUL_SUNBURST), "sanityEdge", "ansuul_sunburst")
            elseif (settings.ansuul_sunburst == 2 and tName ~= "") then
                self:AddAnnouncement(zo_strformat(GetString(RAIDNOTIFIER_ALERTS_SANITYEDGE_ANSUUL_SUNBURST_OTHER), tName), "sanityEdge", "ansuul_sunburst")
            end
        end
    end

    if (result == ACTION_RESULT_EFFECT_GAINED_DURATION) then
        -- Chimera's Sunburst
        if (abilityId == buffsDebuffs.chimera_sunburst and settings.chimera_sunburst and tType == COMBAT_UNIT_TYPE_PLAYER) then
            self:AddAnnouncement(GetString(RAIDNOTIFIER_ALERTS_SANITYEDGE_CHIMERA_SUNBURST), "sanityEdge", "chimera_sunburst")
        -- Ansuul's Poisoned Mind
        elseif (abilityId == buffsDebuffs.ansuul_poisoned_mind and settings.ansuul_poisoned_mind > 0) then
            if (tType == COMBAT_UNIT_TYPE_PLAYER) then
                self:AddAnnouncement(GetString(RAIDNOTIFIER_ALERTS_SANITYEDGE_ANSUUL_POISONED_MIND), "sanityEdge", "ansuul_poisoned_mind")
            elseif (settings.ansuul_poisoned_mind == 2 and tName ~= "") then
                self:AddAnnouncement(zo_strformat(GetString(RAIDNOTIFIER_ALERTS_SANITYEDGE_ANSUUL_POISONED_MIND_OTHER), tName), "sanityEdge", "ansuul_poisoned_mind")
            end
        end
    end
end
