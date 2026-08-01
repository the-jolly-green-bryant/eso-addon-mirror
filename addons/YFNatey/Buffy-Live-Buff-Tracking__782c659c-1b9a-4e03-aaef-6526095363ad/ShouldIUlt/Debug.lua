---=============================================================================
-- Debug
--=============================================================================
function ShouldIUlt:DebugListBuffs()
    d("=== Current Player Buffs ===")
    local numBuffs = GetNumBuffs("player")
    for i = 1, numBuffs do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, abilityId =
            GetUnitBuffInfo("player", i)
        d(string.format("%d. %s (ID: %d) - Duration: %.1fs, Stacks: %d",
            i, buffName, abilityId, (timeEnding - timeStarted) / 1000, stackCount))
    end
    d("=== End of Buff List ===")
end

function ShouldIUlt:DebugDetailedBuffInfo()
    d("=== DETAILED BUFF DEBUG ===")
    d("Game time (ms): " .. GetGameTimeMilliseconds())
    d("Game time (s): " .. (GetGameTimeMilliseconds() / 1000))

    local unitTag = "player"
    local numberOfBuffs = GetNumBuffs(unitTag)
    d(string.format("Player has %d buffs:", numberOfBuffs))


    for i = 0, math.min(numberOfBuffs, 10) do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer =
            GetUnitBuffInfo(unitTag, i)

        if buffName then
            d(string.format("Buff %d:", i))
            d(string.format("  Name: %s", buffName))
            d(string.format("  ID: %d", abilityId or 0))
            d(string.format("  Raw times - Start: %.3f, End: %.3f", timeStarted, timeEnding))
            d(string.format("  Duration: %.3f seconds", timeEnding - timeStarted))
            d(string.format("  Stack count: %d", stackCount or 0))
            d(string.format("  Icon: %s", iconFilename or "nil"))
            d(string.format("  Cast by player: %s", tostring(castByPlayer)))
            d(string.format("  Can click off: %s", tostring(canClickOff)))


            if abilityId and ShouldIUlt:IsTrackedBuff(abilityId) then
                d("  *** THIS BUFF IS TRACKED ***")
            end
            d("")
        end
    end
    d("=== END DETAILED BUFF DEBUG ===")
end

function ShouldIUlt:TestBuffAPI()
    d("=== TESTING BUFF API ===")

    local unitTag = "player"
    local numberOfBuffs = GetNumBuffs(unitTag)
    d("Number of buffs: " .. numberOfBuffs)

    if numberOfBuffs > 0 then
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer =
            GetUnitBuffInfo(unitTag, 0)

        d("First buff test:")
        d("  Name: " .. (buffName or "nil"))
        d("  ID: " .. (abilityId or "nil"))
        d("  Start time: " .. (timeStarted or "nil"))
        d("  End time: " .. (timeEnding or "nil"))
        d("  Icon: " .. (iconFilename or "nil"))
    else
        d("No buffs found on player")
    end

    d("=== END BUFF API TEST ===")
end

function ShouldIUlt:DebugBossDebuffsDetailed()
    d("=== SIMPLIFIED BOSS DEBUFF DEBUG ===")
    d("trackBossDebuffs setting: " .. tostring(ShouldIUlt.savedVars.trackBossDebuffs))


    local trackedBuffs = self:GetTrackedBuffs()
    d("Tracked buff IDs: " .. table.concat(trackedBuffs, ", "))


    local bossUnitTags = { "boss1", "boss2", "boss3", "boss4", "boss5", "boss6" }

    for _, unitTag in ipairs(bossUnitTags) do
        d(string.format("--- Checking %s ---", unitTag))
        if DoesUnitExist(unitTag) then
            local unitName = GetUnitName(unitTag)
            local isAttackable = IsUnitAttackable(unitTag)

            d(string.format("%s: %s (Attackable: %s)", unitTag, unitName, tostring(isAttackable)))

            if isAttackable then
                local numberOfBuffs = GetNumBuffs(unitTag)
                d(string.format("  Has %d effects:", numberOfBuffs))


                for i = 0, math.min(numberOfBuffs, 10) do
                    local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer =
                        GetUnitBuffInfo(unitTag, i)

                    if buffName and abilityId then
                        d(string.format("    %d. %s (ID: %d) - Duration: %.1fs",
                            i, buffName, abilityId, (timeEnding - timeStarted)))

                        if self:IsTrackedBuff(abilityId) then
                            d("      *** TRACKED DEBUFF ***")
                        end
                    end
                end
            end
        else
            d(unitTag .. ": Does not exist")
        end
        d("")
    end


    d("--- Checking Current Target ---")
    if DoesUnitExist("reticleover") then
        local targetName = GetUnitName("reticleover")
        local isAttackable = IsUnitAttackable("reticleover")
        d(string.format("Target: %s (Attackable: %s)", targetName, tostring(isAttackable)))

        if isAttackable then
            local numberOfBuffs = GetNumBuffs("reticleover")
            d(string.format("  Target has %d effects:", numberOfBuffs))

            for i = 0, math.min(numberOfBuffs, 5) do
                local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId =
                    GetUnitBuffInfo("reticleover", i)

                if buffName and abilityId then
                    d(string.format("    %d. %s (ID: %d)", i, buffName, abilityId))

                    if self:IsTrackedBuff(abilityId) then
                        d("      *** TRACKED DEBUFF ***")
                    end
                end
            end
        end
    end

    d("=== END SIMPLIFIED BOSS DEBUFF DEBUG ===")
end
