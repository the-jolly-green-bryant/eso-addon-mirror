RaidNotifier = RaidNotifier or {}
RaidNotifier.RG = {}

local RaidNotifier = RaidNotifier

local function p() end
local function dbg() end

local data = {}

local function isUnitTank(unitTag)
    local isTank = false

    if GetGroupSize() > 0 then
        isTank = GetGroupMemberSelectedRole(unitTag) == LFG_ROLE_TANK
    elseif AreUnitsEqual(unitTag, "player") then
        isTank = GetSelectedLFGRole() == LFG_ROLE_TANK
    end

    return isTank
end

function RaidNotifier.RG.Initialize()
    p = RaidNotifier.p
    dbg = RaidNotifier.dbg

    data = {}
    data.bahseiPortalCounter = 0
end

function RaidNotifier.RG.OnCombatStateChanged(inCombat)
    if (inCombat and DoesUnitExist("boss1")) then
        local currentHealth, maxHealth = GetUnitPower("boss1", POWERTYPE_HEALTH)

        if currentHealth ~= nil and maxHealth ~= nil and currentHealth > 0 and maxHealth > 0 then
            local healthPercent = currentHealth / maxHealth

            if healthPercent <= 99 then
                return
            end
        end
    end

    data.bahseiPortalCounter = 0
end

function RaidNotifier.RG.OnEffectChangedForGroup(eventCode, changeType, eSlot, eName, uTag, beginTime, endTime, stackCount, iconName, buffType, eType, aType, statusEffectType, uName, uId, abilityId, uType)
    local raidId = RaidNotifier.raidId
    local self   = RaidNotifier

    local buffsDebuffs, settings = self.BuffsDebuffs[raidId], self.Vars.rockgrove

    if (string.sub(uTag, 1, 5) ~= "group") then return end

    -- Prime Meteor
    if (buffsDebuffs.meteor_radiating_heat[abilityId]) then
        if (settings.prime_meteor) then
            if (changeType == EFFECT_RESULT_GAINED) then
                if (AreUnitsEqual(uTag, "player")) then
                    self:StartCountdown(10000, GetString(RAIDNOTIFIER_ALERTS_ROCKGROVE_PRIME_METEOR), "rockgrove", "prime_meteor", true)
                end
            end
        end
    -- Oaxiltso's Noxious Sludge
    elseif (abilityId == buffsDebuffs.oaxiltso_noxious_sludge) then
        if (changeType == EFFECT_RESULT_GAINED) then
            if (settings.oaxiltso_noxious_sludge == 1 and AreUnitsEqual(uTag, "player")) then
                self:AddAnnouncement(GetString(RAIDNOTIFIER_ALERTS_ROCKGROVE_NOXIOUS_SLUDGE_SELF), "rockgrove", "oaxiltso_noxious_sludge")
            elseif (settings.oaxiltso_noxious_sludge == 2) then
                local targetPlayerName = self.UnitIdToString(uId)

                self.DelayedEventHandler.Add(
                    "oaxiltso_noxious_sludge",
                    targetPlayerName,
                    function (argsBag)
                        local alertMessage = RAIDNOTIFIER_ALERTS_ROCKGROVE_NOXIOUS_SLUDGE_OTHER2

                        if (argsBag:GetEventCount() == 1) then
                            alertMessage = RAIDNOTIFIER_ALERTS_ROCKGROVE_NOXIOUS_SLUDGE_OTHER1
                        end

                        self:AddAnnouncement(zo_strformat(GetString(alertMessage), unpack(argsBag:GetValues())), "rockgrove", "oaxiltso_noxious_sludge")
                    end,
                    50
                )
            end
        end
    -- Flame-Herald Bahsei's Embrace of Death (Death Touch debuff)
    elseif (abilityId == buffsDebuffs.bahsei_death_touch) then
        if (changeType == EFFECT_RESULT_GAINED) then
            if (settings.bahsei_embrace_of_death >= 1 and AreUnitsEqual(uTag, "player")) then
                self:StartCountdown(8000, GetString(RAIDNOTIFIER_ALERTS_ROCKGROVE_EMBRACE_OF_DEATH), "rockgrove", "bahsei_embrace_of_death", true)
            elseif (settings.bahsei_embrace_of_death == 2 or settings.bahsei_embrace_of_death == 3 and isUnitTank(uTag)) then
                local targetPlayerName = self.UnitIdToString(uId)

                self:StartCountdown(8000, zo_strformat(GetString(RAIDNOTIFIER_ALERTS_ROCKGROVE_EMBRACE_OF_DEATH_OTHER), targetPlayerName), "rockgrove", "bahsei_embrace_of_death", false)
            end
        end
    end
end

function RaidNotifier.RG.OnEffectChangedForPlayer(eventCode, changeType, eSlot, eName, uTag, beginTime, endTime, stackCount, iconName, buffType, eType, aType, statusEffectType, uName, uId, abilityId, uType)
    local raidId = RaidNotifier.raidId
    local self   = RaidNotifier

    local buffsDebuffs, settings = self.BuffsDebuffs[raidId], self.Vars.rockgrove

    if (uTag ~= "player") then return end

    if (abilityId == buffsDebuffs.xalvakka_unstable_charge and settings.xalvakka_unstable_charge) then
        if (changeType == EFFECT_RESULT_GAINED) then
            self:AddAnnouncement(GetString(RAIDNOTIFIER_ALERTS_ROCKGROVE_XALVAKKA_UNSTABLE_CHARGE), "rockgrove", "xalvakka_unstable_charge")
            self:UpdateXalvakkaUnstableCharge(true)
        elseif (changeType == EFFECT_RESULT_FADED) then
            self:UpdateXalvakkaUnstableCharge(false)
        end
    end
end

function RaidNotifier.RG.OnCombatEvent(_, result, isError, aName, aGraphic, aActionSlotType, sName, sType, tName, tType, hitValue, pType, dType, log, sUnitId, tUnitId, abilityId)
    local raidId = RaidNotifier.raidId
    local self   = RaidNotifier
    local buffsDebuffs, settings = self.BuffsDebuffs[raidId], self.Vars.rockgrove

    if (tName == nil or tName == "") then
        tName = self.UnitIdToString(tUnitId)
    end

    if (result == ACTION_RESULT_BEGIN) then
        -- Sul-Xan Reaver's Sundering Strike
        if (abilityId == buffsDebuffs.sulxan_reaver_sundering_strike) then
            if (settings.sulxan_reaver_sundering_strike >= 1 and tType == COMBAT_UNIT_TYPE_PLAYER) then
                self:AddAnnouncement(GetString(RAIDNOTIFIER_ALERTS_ROCKGROVE_SUNDERING_STRIKE), "rockgrove", "sulxan_reaver_sundering_strike")
            elseif (settings.sulxan_reaver_sundering_strike == 2 and tName ~= "") then
                self:AddAnnouncement(zo_strformat(GetString(RAIDNOTIFIER_ALERTS_ROCKGROVE_SUNDERING_STRIKE_OTHER), tName), "rockgrove", "sulxan_reaver_sundering_strike")
            end
        -- Sul-Xan Soulweaver's Astral Shield (cast)
        elseif (abilityId == buffsDebuffs.sulxan_soulweaver_astral_shield_cast) then
            if (settings.sulxan_soulweaver_astral_shield) then
                self:AddAnnouncement(GetString(RAIDNOTIFIER_ALERTS_ROCKGROVE_ASTRAL_SHIELD_CAST), "rockgrove", "sulxan_soulweaver_astral_shield")
            end
        -- Havocrel Barbarian's Hasted Assault
        elseif (buffsDebuffs.havocrel_barbarian_hasted_assault[abilityId]) then
            if (settings.havocrel_barbarian_hasted_assault) then
                self:AddAnnouncement(GetString(RAIDNOTIFIER_ALERTS_ROCKGROVE_HASTED_ASSAULT), "rockgrove", "havocrel_barbarian_hasted_assault")
            end
        -- Oaxiltso's Savage Blitz
        elseif (buffsDebuffs.oaxiltso_savage_blitz[abilityId]) then
            if (settings.oaxiltso_savage_blitz and tName ~= "") then
                self:AddAnnouncement(zo_strformat(GetString(RAIDNOTIFIER_ALERTS_ROCKGROVE_SAVAGE_BLITZ), tName), "rockgrove", "oaxiltso_savage_blitz")
            end
        -- Havocrel Annihilator's Cinder Cleave at the fight with Oaxiltso
        elseif (abilityId == buffsDebuffs.oaxiltso_annihilator_cinder_cleave) then
            if (settings.oaxiltso_annihilator_cinder_cleave >= 1 and tType == COMBAT_UNIT_TYPE_PLAYER) then
                self:AddAnnouncement(GetString(RAIDNOTIFIER_ALERTS_ROCKGROVE_CINDER_CLEAVE), "rockgrove", "oaxiltso_annihilator_cinder_cleave")
            elseif (settings.oaxiltso_annihilator_cinder_cleave == 2 and tName ~= "") then
                self:AddAnnouncement(zo_strformat(GetString(RAIDNOTIFIER_ALERTS_ROCKGROVE_CINDER_CLEAVE_OTHER), tName), "rockgrove", "oaxiltso_annihilator_cinder_cleave")
            end
        end
    elseif (result == ACTION_RESULT_EFFECT_GAINED) then
        if (abilityId == buffsDebuffs.bahsei_creeping_eye_clockwise or abilityId == buffsDebuffs.bahsei_creeping_eye_countercw) then
            data.bahseiPortalCounter = data.bahseiPortalCounter % 2 + 1

            if (settings.bahsei_portal_number) then
                local text = zo_strformat(GetString(RAIDNOTIFIER_ALERTS_ROCKGROVE_BAHSEI_PORTAL_NUMBER), data.bahseiPortalCounter)
                self:AddAnnouncement(text, "rockgrove", "bahsei_portal_number")
            end
            if (settings.bahsei_cone_direction) then
                local text

                if (abilityId == buffsDebuffs.bahsei_creeping_eye_clockwise) then
                    text = GetString(RAIDNOTIFIER_ALERTS_ROCKGROVE_BAHSEI_CONE_DIRECTION_CLOCKWISE)
                else
                    text = GetString(RAIDNOTIFIER_ALERTS_ROCKGROVE_BAHSEI_CONE_DIRECTION_COUNTERCW)
                end

                self:AddAnnouncement(text, "rockgrove", "bahsei_cone_direction")
            end
        end
    elseif (result == ACTION_RESULT_EFFECT_FADED) then
        -- Sul-Xan Soulweaver's Soul Remnant attack (his Astral Shield is broken)
        if (abilityId == buffsDebuffs.sulxan_soulweaver_astral_shield_self) then
            if (settings.sulxan_soulweaver_soul_remnant) then
                self:AddAnnouncement(GetString(RAIDNOTIFIER_ALERTS_ROCKGROVE_SOUL_REMNANT), "rockgrove", "sulxan_soulweaver_astral_shield")
            end
        end
    end
end
