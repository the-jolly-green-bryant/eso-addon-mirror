----------------------------------------------------------------------
-- SmartGear -- Set Stat Contributions Map
-- Maps meta sets to their primary stat contributions for adaptive scoring.
-- This file is NOT auto-generated and survives MetaData.lua regeneration.
--
-- statContributions values represent the RELATIVE strength of
-- the set's contribution to each stat (0.0 to 1.0 scale).
-- Used by ComputeStatGaps to adjust set scores based on player needs.
----------------------------------------------------------------------
SmartGear = SmartGear or {}

local function PatchSets()
    local sets = SmartGear.MetaSets
    if not sets then return end

    -- ================================================================
    -- DD MONSTER SETS
    -- ================================================================
    if sets["Slimecraw"] then
        sets["Slimecraw"].statContributions = { critPercent = 0.08, damage = 0.05 }
    end
    if sets["Stormfist"] then
        sets["Stormfist"].statContributions = { damage = 0.10 }
    end
    if sets["Maw of the Infernal"] then
        sets["Maw of the Infernal"].statContributions = { damage = 0.12 }
    end
    if sets["Domihaus"] then
        sets["Domihaus"].statContributions = { weaponDamage = 0.08, maxResource = 0.06 }
    end
    if sets["Kra'gh"] then
        sets["Kra'gh"].statContributions = { penetration = 0.10, damage = 0.06 }
    end
    if sets["Maarselok"] then
        sets["Maarselok"].statContributions = { penetration = 0.08, damage = 0.08 }
    end
    if sets["Selene"] then
        sets["Selene"].statContributions = { damage = 0.12 }
    end
    if sets["Velidreth"] then
        sets["Velidreth"].statContributions = { damage = 0.12 }
    end
    if sets["Balorgh"] then
        sets["Balorgh"].statContributions = { weaponDamage = 0.10, penetration = 0.10 }
    end
    if sets["Grothdarr"] then
        sets["Grothdarr"].statContributions = { damage = 0.10 }
    end
    if sets["Ilambris"] then
        sets["Ilambris"].statContributions = { damage = 0.10 }
    end
    if sets["Valkyn Skoria"] then
        sets["Valkyn Skoria"].statContributions = { damage = 0.10 }
    end
    if sets["Zaan"] then
        sets["Zaan"].statContributions = { damage = 0.12 }
    end
    if sets["Iceheart"] then
        sets["Iceheart"].statContributions = { damage = 0.06, resistance = 0.04 }
    end

    -- ================================================================
    -- HEALER/TANK MONSTER SETS
    -- ================================================================
    if sets["Earthgore"] then
        sets["Earthgore"].statContributions = { healingDone = 0.10 }
    end
    if sets["Symphony of Blades"] then
        sets["Symphony of Blades"].statContributions = { magRecovery = 0.12 }
    end
    if sets["Nazaray"] then
        sets["Nazaray"].statContributions = { resistance = 0.06, maxHealth = 0.06 }
    end
    if sets["Lord Warden"] then
        sets["Lord Warden"].statContributions = { resistance = 0.12 }
    end
    if sets["Bloodspawn"] then
        sets["Bloodspawn"].statContributions = { resistance = 0.08, ultimateGen = 0.10 }
    end
    if sets["Chokethorn"] then
        sets["Chokethorn"].statContributions = { healingDone = 0.08 }
    end

    -- ================================================================
    -- DD SETS (DUNGEON/TRIAL/OVERLAND/CRAFTED)
    -- ================================================================
    if sets["Pillar of Nirn"] then
        sets["Pillar of Nirn"].statContributions = { damage = 0.14 }
    end
    if sets["Arms of Relequen"] or sets["Perfected Arms of Relequen"] then
        local s = sets["Arms of Relequen"] or sets["Perfected Arms of Relequen"]
        s.statContributions = { damage = 0.14 }
        if sets["Perfected Arms of Relequen"] then
            sets["Perfected Arms of Relequen"].statContributions = { damage = 0.15 }
        end
    end
    if sets["Kinras's Wrath"] then
        sets["Kinras's Wrath"].statContributions = { critPercent = 0.06, weaponDamage = 0.08 }
    end
    if sets["Tzogvin's Warband"] then
        sets["Tzogvin's Warband"].statContributions = { critPercent = 0.12 }
    end
    if sets["Bahsei's Mania"] then
        sets["Bahsei's Mania"].statContributions = { damage = 0.16 }
    end
    if sets["Coral Riptide"] then
        sets["Coral Riptide"].statContributions = { weaponDamage = 0.14 }
    end
    if sets["Ansuul's Torment"] then
        sets["Ansuul's Torment"].statContributions = { damage = 0.14 }
    end
    if sets["Whorl of the Depths"] or sets["Perfected Whorl of the Depths"] then
        if sets["Whorl of the Depths"] then
            sets["Whorl of the Depths"].statContributions = { damage = 0.12 }
        end
        if sets["Perfected Whorl of the Depths"] then
            sets["Perfected Whorl of the Depths"].statContributions = { damage = 0.13 }
        end
    end
    if sets["Aegis Caller"] then
        sets["Aegis Caller"].statContributions = { damage = 0.10 }
    end
    if sets["Berserking Warrior"] then
        sets["Berserking Warrior"].statContributions = { weaponDamage = 0.12 }
    end
    if sets["Deadly Strike"] then
        sets["Deadly Strike"].statContributions = { damage = 0.12 }
    end
    if sets["Hunding's Rage"] then
        sets["Hunding's Rage"].statContributions = { weaponDamage = 0.10, critPercent = 0.04 }
    end
    if sets["Briarheart"] then
        sets["Briarheart"].statContributions = { weaponDamage = 0.08, critPercent = 0.04 }
    end
    if sets["Leviathan"] then
        sets["Leviathan"].statContributions = { critPercent = 0.14 }
    end
    if sets["Mother's Sorrow"] then
        sets["Mother's Sorrow"].statContributions = { critPercent = 0.14 }
    end
    if sets["Law of Julianos"] then
        sets["Law of Julianos"].statContributions = { weaponDamage = 0.08, critPercent = 0.06 }
    end
    if sets["New Moon Acolyte"] then
        sets["New Moon Acolyte"].statContributions = { weaponDamage = 0.12 }
    end
    if sets["Night Mother's Gaze"] then
        sets["Night Mother's Gaze"].statContributions = { penetration = 0.14 }
    end
    if sets["Spriggan's Thorns"] then
        sets["Spriggan's Thorns"].statContributions = { penetration = 0.14 }
    end
    if sets["Spinner's Garments"] then
        sets["Spinner's Garments"].statContributions = { penetration = 0.14 }
    end
    if sets["Strength of Automaton"] then
        sets["Strength of Automaton"].statContributions = { weaponDamage = 0.10 }
    end
    if sets["Twice-Fanged Serpent"] then
        sets["Twice-Fanged Serpent"].statContributions = { penetration = 0.12 }
    end
    if sets["War Machine"] then
        sets["War Machine"].statContributions = { weaponDamage = 0.08, critPercent = 0.04 }
    end
    if sets["False God's Devotion"] then
        sets["False God's Devotion"].statContributions = { maxResource = 0.06, damage = 0.08 }
    end
    if sets["The Morag Tong"] then
        sets["The Morag Tong"].statContributions = { penetration = 0.10 }
    end
    if sets["Vicious Serpent"] then
        sets["Vicious Serpent"].statContributions = { damage = 0.08, maxResource = 0.04 }
    end
    if sets["Azureblight Reaper"] then
        sets["Azureblight Reaper"].statContributions = { damage = 0.14 }
    end
    if sets["Burning Spellweave"] then
        sets["Burning Spellweave"].statContributions = { weaponDamage = 0.10 }
    end
    if sets["Medusa"] then
        sets["Medusa"].statContributions = { critPercent = 0.10 }
    end
    if sets["Mechanical Acuity"] then
        sets["Mechanical Acuity"].statContributions = { critPercent = 0.10, critDamage = 0.06 }
    end
    if sets["Necropotence"] then
        sets["Necropotence"].statContributions = { maxResource = 0.14 }
    end
    if sets["Scathing Mage"] then
        sets["Scathing Mage"].statContributions = { weaponDamage = 0.10 }
    end
    if sets["Diamond's Victory"] then
        sets["Diamond's Victory"].statContributions = { weaponDamage = 0.10 }
    end

    -- ================================================================
    -- MYTHIC SETS
    -- ================================================================
    if sets["Velothi Ur-Mage's Amulet"] then
        sets["Velothi Ur-Mage's Amulet"].statContributions = { penetration = 0.14, damage = 0.06 }
    end
    if sets["Death Dealer's Fete"] then
        sets["Death Dealer's Fete"].statContributions = { maxResource = 0.10, maxHealth = 0.06 }
    end
    if sets["Harpooner's Wading Kilt"] then
        sets["Harpooner's Wading Kilt"].statContributions = { critPercent = 0.10, critDamage = 0.08 }
    end
    if sets["Ring of the Pale Order"] then
        sets["Ring of the Pale Order"].statContributions = { maxHealth = 0.08 }  -- solo survivability
    end
    if sets["Oakensoul Ring"] then
        sets["Oakensoul Ring"].statContributions = { weaponDamage = 0.06, critPercent = 0.04, penetration = 0.04, maxResource = 0.04 }
    end

    -- ================================================================
    -- HEALER SETS
    -- ================================================================
    if sets["Spell Power Cure"] then
        sets["Spell Power Cure"].statContributions = { weaponDamage = 0.10 }  -- group buff
    end
    if sets["Olorime"] or sets["Vestments of Olorime"] then
        if sets["Olorime"] then
            sets["Olorime"].statContributions = { weaponDamage = 0.12 }  -- group Major Courage
        end
        if sets["Vestments of Olorime"] then
            sets["Vestments of Olorime"].statContributions = { weaponDamage = 0.12 }
        end
    end
    if sets["Roaring Opportunist"] then
        sets["Roaring Opportunist"].statContributions = { critPercent = 0.10 }  -- group Minor Slayer
    end
    if sets["Kagrenac's Hope"] then
        sets["Kagrenac's Hope"].statContributions = { weaponDamage = 0.06 }
    end
    if sets["Transformative Hope"] then
        sets["Transformative Hope"].statContributions = { healingDone = 0.12 }
    end
    if sets["Pillager's Profit"] then
        sets["Pillager's Profit"].statContributions = { healingDone = 0.14 }
    end
    if sets["Powerful Assault"] then
        sets["Powerful Assault"].statContributions = { weaponDamage = 0.08 }  -- group buff
    end
    if sets["Torug's Pact"] then
        sets["Torug's Pact"].statContributions = { enchant = 0.10 }
    end
    if sets["Hollowfang Thirst"] then
        sets["Hollowfang Thirst"].statContributions = { magRecovery = 0.10 }
    end
    if sets["Jorvuld's Guidance"] then
        sets["Jorvuld's Guidance"].statContributions = { healingDone = 0.06 }
    end

    -- ================================================================
    -- TANK SETS
    -- ================================================================
    if sets["Ebon Armory"] then
        sets["Ebon Armory"].statContributions = { maxHealth = 0.10 }  -- group buff
    end
    if sets["Claw of Yolnahkriin"] then
        sets["Claw of Yolnahkriin"].statContributions = { weaponDamage = 0.06 }  -- group Minor Courage
    end
    if sets["Turning Tide"] then
        sets["Turning Tide"].statContributions = { penetration = 0.08, resistance = 0.04 }
    end
    if sets["Saxhleel Champion"] then
        sets["Saxhleel Champion"].statContributions = { maxResource = 0.06 }  -- group sustain
    end
    if sets["Lucent Echoes"] then
        sets["Lucent Echoes"].statContributions = { resistance = 0.08, maxHealth = 0.06 }
    end
    if sets["Fortified Brass"] then
        sets["Fortified Brass"].statContributions = { resistance = 0.14 }
    end
    if sets["Plague Doctor"] then
        sets["Plague Doctor"].statContributions = { maxHealth = 0.14 }
    end
    if sets["Leeching Plate"] then
        sets["Leeching Plate"].statContributions = { maxHealth = 0.06, resistance = 0.04 }
    end
    if sets["Alessian Order"] then
        sets["Alessian Order"].statContributions = { resistance = 0.06, maxHealth = 0.04 }
    end
    if sets["Hircine's Veneer"] then
        sets["Hircine's Veneer"].statContributions = { stamRecovery = 0.10 }  -- group sustain
    end
    if sets["The Worm's Raiment"] then
        sets["The Worm's Raiment"].statContributions = { magRecovery = 0.10 }  -- group sustain
    end

    -- ================================================================
    -- ARENA WEAPONS
    -- ================================================================
    if sets["Perfected Merciless Charge"] then
        sets["Perfected Merciless Charge"].statContributions = { damage = 0.10, critPercent = 0.06 }
    end
    if sets["Merciless Charge"] then
        sets["Merciless Charge"].statContributions = { damage = 0.09, critPercent = 0.05 }
    end
    if sets["Perfected Crushing Wall"] then
        sets["Perfected Crushing Wall"].statContributions = { damage = 0.10 }
    end
    if sets["Perfected Grand Rejuvenation"] then
        sets["Perfected Grand Rejuvenation"].statContributions = { healingDone = 0.08 }
    end
end

-- Run patching after MetaData.lua loads
-- This function is called from SmartGear.lua init or deferred
SmartGear.PatchSetStatMap = PatchSets

-- Auto-patch if MetaSets already loaded
if SmartGear.MetaSets then
    PatchSets()
end
