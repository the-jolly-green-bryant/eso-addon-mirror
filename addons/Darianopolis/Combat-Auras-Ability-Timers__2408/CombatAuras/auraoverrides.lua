-- Aura override file
-- If any ability isn't being tracked correctly, it's probably because the
--  automated guessing system doesn't have enough information - provide a
--  suitable aura description here and P.M. so I can add it to the base
--  file. Thank you!

-- IMPORTANT - If an ability is tracked the same for it's morphs and it's base ability then
--             then Put the aura override name as the name of the BASE ABILITY E.g. Trap Beast
--             for Rearming Trap. This is because the algorithm will look for a base ability
--             override if it doesn't find one for the morph

-- ICD = Internal Cooldown   This is a timer that starts on ability activation 
--                           and continues for a specified amount of time. This is
--                           used for abilities such as Endless Hail or Resolving Vigor
--							 where there is no buff or debuff to track

-- { }                       Track ICD of ability based on ability duration
-- CombatAuras.DEFAULT_ICD   Constant for above
-- { duration = x }          Track ICD based on given duration
-- { buff = x, target = y }  Track buff on unitTag
-- CombatAuras.NO_AURA       Don't track or override aura on this ability

-- target = "player"         Track buff on player
-- target = "reticleover"    Track buff on current target
-- duration = x	             Override listed ability duration (Only works for internal cooldowns E.g. Resolving Vigor)
-- buff = x                  Name of buff to look for on given target

-- local CombatAuras = DAL:Ext("CombatAuras")

CombatAuras.auraoverrides = {
    ["Trap Beast"] = {
        buff = "Minor Force",
        target = "player",
    },

    ["Summon Shade"] = CombatAuras.DEFAULT_ICD,

    ["Vigor"] = { 
        duration = 5000,
    },

    ["Assassin's Scourge"] = CombatAuras.NO_AURA,
    ["Assassin's Will"]    = CombatAuras.NO_AURA,

    ["Accelerate"] = {
    	buff = "Minor Force",
    	target = "player",
    },

    ["Strife"] = {
        target = "player",
    },

    ["Consuming Trap"] = CombatAuras.DEFAULT_ICD,

    ["Blastbones"] = {
        target = "player",
    },
}