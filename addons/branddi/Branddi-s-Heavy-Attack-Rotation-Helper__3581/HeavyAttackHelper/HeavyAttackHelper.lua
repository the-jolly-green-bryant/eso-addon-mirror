
-- TODO: when atro is up curse higher priority skill*****


HeavyAttackHelper = HeavyAttackHelper or { }
local HeavyAttackHelper = HeavyAttackHelper

local EM		= GetEventManager()
--local Util = DariansUtilities


HeavyAttackHelper.name		= "HeavyAttackHelper"
HeavyAttackHelper.version		= "1.0.8"
HeavyAttackHelper.varVersion 	= "1"

HeavyAttackHelper.addonLoaded = false


HeavyAttackHelper.skillSuggesterActive = false

--HeavyAttackHelper.lastHeavyAttackStartTime = 0 -- last time a heavy attack started
HeavyAttackHelper.lastSoundTime = 0 -- last time a skill cast timer warning was sent

HeavyAttackHelper.movingUI = false -- determine when we want to move the UI

HeavyAttackHelper.currentRecommendedSkillSlot = 0 -- Current skill recommended in rotation


HeavyAttackHelper.heavyEffectEventCode = -1 -- ID to link the start and end of the effect
HeavyAttackHelper.heavyEffectSlot = -1 -- ID of the effect has nothing to do with bar slots, the number will be sequencial as you play the game
HeavyAttackHelper.heavyEffectStartTime = 0
HeavyAttackHelper.heavyEffectHeavyInProgress = false
HeavyAttackHelper.heavyEffectHeavyWasFullyCharged = true



HeavyAttackHelper.heavyActionSlotStartTime = 0
HeavyAttackHelper.heavyActionHeavyInProgress = true



HeavyAttackHelper.mediumEffectDetectionTime = 0

HeavyAttackHelper.MIN_WIDTH = 50
HeavyAttackHelper.MAX_WIDTH = 500
HeavyAttackHelper.MIN_HEIGHT = 10
HeavyAttackHelper.MAX_HEIGHT = 100





HeavyAttackHelper.defaults	= {
	["offsetX"]	= 500,
	["offsetY"]	= 500,

	["arrowWidth"] = 52,
	["arrowYOffset"] = 0,


    ["showYellowforOffCooldownSkills"] = true,
    ["playSoundForNextSkillTime"] = false,

    ["debugCombatEventSkillDetection"] = false,
    ["debugHeavyAttackDetection"] = false,
    ["extraFeatures"] = false,
    ["accountWide"] = false,

    ["compatibilityDetectBandits"] = true,
    ["compatibilityDetectADR"] = true,
    ["compatibilityDetectFAB"] = true,
    ["soundEffectCast"] = "Justice_PickpocketFailed",

    ["mediumAttackWarning"] = false,
    ["noSkillsWarning"] = true,


    ["xOffset"] = math.floor((GuiRoot:GetWidth() - 250) / 2),
    ["yOffset"] = math.floor((GuiRoot:GetHeight() - 40) / 2),
    ["width"] = 250,
    ["height"] = 40,
    ["backgroundColour"] = { 0, 0, 0, 0.5 },
    ["progressColour"] = { 1, 0.84, 0.24, 0.63 },
    ["pingColour"] = { 0, 91/255, 39/255, 0.63 },
    ["align"] = "Center",
    ["skillTimerBar"] = true,

    ["smallIcons"] = true,

}



    -- 1 dragonknight
    -- 2 sorcerer
    -- 3 nightblade
    -- 4 warden
    -- 5 necromancer
    -- 6 templar

HeavyAttackHelper.skillPriorityDatabase = {
[1] =   { -- DK
            [1]= {32722,nil,nil,nil,nil,nil,nil,nil,nil}, -- Coagulating Blood
            [2]= {61505,nil,nil,nil,nil,nil,nil,nil,nil}, -- Echoing Vigor


            [3]= {31874,nil,nil,nil,nil,nil,nil,nil,nil}, -- Igneous Weapons
            [4]= {20252,nil,nil,nil,nil,nil,nil,nil,nil}, -- Burning Talons (hard to recommend as requires mele range, maybe check on status of whip?)
            [5]= {32853,nil,nil,nil,nil,nil,nil,nil,nil}, -- Flames of Oblivion
            [6]= {31810,nil,nil,nil,nil,nil,nil,nil,nil}, -- Venomous Claw
            [7]= {40382,nil,nil,nil,nil,nil,nil,nil,nil}, -- Barbed trap

            [8]= {20930,nil,nil,nil,nil,nil,nil,nil,nil}, -- engulfing flame
            [9]= {40242,nil,nil,nil,nil,nil,nil,nil,nil}, -- Razor Caltrops
           [10]= {40465,nil,nil,nil,nil,nil,nil,nil,nil}, -- Scalding Rune
           [11]= {40452,nil,nil,nil,nil,nil,nil,nil,nil}, -- Structured Entropy
           [12]= {39073,nil,nil,nil,nil,nil,nil,nil,nil}, -- Unstable Wall of Storms



           [13]= {39095,nil,nil,nil,nil,nil,nil,nil,nil}, -- ele Drain
           [14]= {39089,nil,nil,nil,nil,nil,nil,nil,nil}, -- Ele sus


           [15]= {40382,nil,nil,nil,nil,nil,nil,nil,nil}, -- Barbed trap
           [16]= {40465,nil,nil,nil,nil,nil,nil,nil,nil}, -- Scalding Rune
           [17]= {42028,nil,nil,nil,nil,nil,nil,nil,nil}, -- Mystic Orb



            [18]= {32792,nil,nil,nil,nil,nil,nil,nil,nil}, -- Deep Breath
            [19]= {32710,nil,nil,nil,nil,nil,nil,nil,nil}, -- Erruption

            [20]= {20805,nil,nil,nil,nil,nil,nil,nil,nil}, -- Molten Whip
        },-- DK

[2] =   {  -- SORC
            -- raise your healing pet
             [1]= {24639,nil,nil,nil,nil,nil,nil,nil,nil}, -- summon Matriarch Restore

            -- heal only when HP low enough
             [2]= {77369,nil,nil,nil,nil,nil,nil,nil,nil}, -- Matriarch Restore

             [3]= {114716,nil,nil,nil,nil,nil,nil,nil,nil}, -- Crystal Fragments (proc)
            -- HeavyAttackHelper heal (HOT)
             [4]= {23678,nil,nil,nil,nil,nil,nil,nil,nil}, -- crit surge
             [5]= {61505,nil,nil,nil,nil,nil,nil,nil,nil}, -- echoing vigor

             [6]= {24636,nil,nil,nil,nil,nil,nil,nil,nil}, -- Summon twilight tormentor
             [7]= {23316,nil,nil,nil,nil,nil,nil,nil,nil}, -- Summon Volatile Familiar


             [8]= {46331,nil,nil,nil,nil,nil,nil,nil,nil}, -- Crystal Weapon


             [8]= {39095,nil,nil,nil,nil,nil,nil,nil,nil}, -- ele Drain
             [9]= {39089,nil,nil,nil,nil,nil,nil,nil,nil}, -- Ele sus

            -- normal DOTs
            [10]= {46331,nil,nil,nil,nil,nil,nil,nil,nil}, --  Crystal Weapon

            [11]= {24328,nil,nil,nil,nil,nil,nil,nil,nil}, -- Daedric Prey

            [12]= {77182,nil,nil,nil,nil,nil,nil,nil,nil}, -- Volatile Familiar
            [13]= {39073,nil,nil,nil,nil,nil,nil,nil,nil}, -- Unstable Wall of Storms
            [14]= {40382,nil,nil,nil,nil,nil,nil,nil,nil}, -- Barbed trap
            [15]= {23213,nil,nil,nil,nil,nil,nil,nil,nil}, -- Boundless Storm
            [16]= {23231,nil,nil,nil,nil,nil,nil,nil,nil}, -- Hurricane
            [17]= {40242,nil,nil,nil,nil,nil,nil,nil,nil}, -- Razor Caltrops
            [18]= {40465,nil,nil,nil,nil,nil,nil,nil,nil}, -- Scalding Rune
            [19]= {40452,nil,nil,nil,nil,nil,nil,nil,nil}, -- Structured Entropy

            [20]= {24842,nil,nil,nil,nil,nil,nil,nil,nil}, -- Daedric Tomb
            [21]= {42028,nil,nil,nil,nil,nil,nil,nil,nil}, -- Mystic Orb

            [22]= {77140,nil,nil,nil,nil,nil,nil,nil,nil}, -- Twilight Tormentor Enrage (above 50%)


            [23] = {24163,nil,nil,nil,nil,nil,nil,nil,nil}, -- Bound Aegis

            -- spammable


            [24]= {46324,nil,nil,nil,nil,nil,nil,nil,nil}, --  Crystal Fragments
            [25]= {46356,nil,nil,nil,nil,nil,nil,nil,nil}, --  Force Pulse
            [26]= {39073,0,nil,nil,nil,nil,nil,nil,nil}, -- Unstable Wall of Storms
            --[27]= {46331,0,nil,nil,nil,nil,nil,nil,nil}, --  Crystal Weapon
        },-- SORC

[3] =   { -- NIGHTBLADE

           [1]= { 61505,nil,nil,nil,nil,nil,nil,nil,nil}, -- echoing vigor
           [2]= {34835,-1,75,nil,nil,nil,nil,nil,nil}, -- Swallow Soul (HEAL WHEN HP UNDER 75%)

           [3]= {61919,nil,nil,nil,nil,nil,nil,nil,nil}, -- Merciless Resolve
           [4]= {61930,nil,nil,nil,nil,nil,nil,nil,nil}, -- Assassin's Will
           [5]= {36049,nil,nil,nil,nil,nil,nil,nil,nil}, -- Twisting Path

           [6]= {39095,nil,nil,nil,nil,nil,nil,nil,nil}, -- ele Drain
           [7]= {39089,nil,nil,nil,nil,nil,nil,nil,nil}, -- Ele sus
           [8]= {36967,nil,nil,nil,nil,nil,nil,nil,nil}, -- Reaper's Mark

           [9]= {25493,nil,nil,nil,nil,nil,nil,nil,nil}, -- Lotus Fan




          [10]= {35434,nil,nil,nil,nil,nil,nil,nil,nil}, -- Dark Shade
          [11]= {36943,nil,nil,nil,nil,nil,nil,nil,nil}, -- Debilitate

          [12]= {39073,nil,nil,nil,nil,nil,nil,nil,nil}, -- Unstable Wall of Storms
          [13]= {40382,nil,nil,nil,nil,nil,nil,nil,nil}, -- Barbed trap
          [14]= {40242,nil,nil,nil,nil,nil,nil,nil,nil}, -- Razor Caltrops
          [15]= {40465,nil,nil,nil,nil,nil,nil,nil,nil}, -- Scalding Rune
          [16]= {40452,nil,nil,nil,nil,nil,nil,nil,nil}, -- Structured Entropy

          [17]= {42028,nil,nil,nil,nil,nil,nil,nil,nil}, -- Mystic Orb



            -- spammable


          [18]= {34851,nil,nil,nil,nil,nil,nil,nil,nil}, -- Impale
          [19]= {36891,nil,nil,nil,nil,nil,nil,nil,nil}, -- Sap Essence
          [20]= {25267,nil,nil,nil,nil,nil,nil,nil,nil}, -- Concealed Weapon
          [21]= {34835,nil,nil,nil,nil,nil,nil,nil,nil}, -- Swallow Soul


        },-- NIGHTBLADE

[4] =   { -- WARDEN


            [1]= {85862,nil,nil,nil,nil,nil,nil,nil,nil}, -- Enchanted Growth
            -- HeavyAttackHelper heal (HOT)
            [2]= {61505,nil,nil,nil,nil,nil,nil,nil,nil}, -- echoing vigor
            [3]= {61507,nil,nil,nil,nil,nil,nil,nil,nil}, -- resolving vigor


            [4]= {86156,nil,nil,nil,nil,nil,nil,nil,nil},  -- Arctic Blast

            [5]= {86169,nil,nil,nil,nil,nil,nil,nil,nil},  -- Winter's Revenge

            [6]= {86015,nil,nil,nil,nil,nil,nil,nil,nil}, -- Deep Fissure
            [7]= {86019,nil,nil,nil,nil,nil,nil,nil,nil}, -- Subterranean Assault


            [8]= {39095,nil,nil,nil,nil,nil,nil,nil,nil}, -- ele Drain
            [9]= {39089,nil,nil,nil,nil,nil,nil,nil,nil}, -- Ele sus


            -- normal DOTs
            [10]= {86027,nil,nil,nil,nil,nil,nil,nil,nil},  -- Fetcher Infection
            [11]= {86031,nil,nil,nil,nil,nil,nil,nil,nil},  -- Growing Swarm


            [12]= {39073,nil,nil,nil,nil,nil,nil,nil,nil}, -- Unstable Wall of Storms
            [13]= {40382,nil,nil,nil,nil,nil,nil,nil,nil}, -- Barbed trap


            [14]= {40242,nil,nil,nil,nil,nil,nil,nil,nil}, -- Razor Caltrops
            [15]= {40465,nil,nil,nil,nil,nil,nil,nil,nil}, -- Scalding Rune
            [16]= {40452,nil,nil,nil,nil,nil,nil,nil,nil}, -- Structured Entropy

            [17]= {42028,nil,nil,nil,nil,nil,nil,nil,nil}, -- Mystic Orb
            -- spammable
            [18]= {86003,nil,nil,nil,nil,nil,nil,nil,nil}, -- Screaming Cliff Racer
            [19]= {46356,nil,nil,nil,nil,nil,nil,nil,nil}, --  Force Pulse
            [20]= {-86169,nil,nil,nil,nil,nil,nil,nil,nil},  -- Winter's Revenge (Cast Early)
            [21]= {-86015,nil,nil,nil,nil,nil,nil,nil,nil}, -- Deep Fissure (Cast Eearly)

        },-- WARDEN
[5]=    { -- NECRO
            [1]= {117883,nil,nil,nil,nil,nil,nil,nil,nil}, -- Resistant Flesh
            [2]= {118912,nil,nil,nil,nil,nil,nil,nil,nil}, -- Spirit Guardian
            [3]= { 61505,nil,nil,nil,nil,nil,nil,nil,nil}, -- echoing vigor


            [4]= {117749,nil,nil,nil,nil,nil,nil,nil,nil}, -- Stalking Blastbones
            [5]= {117690,nil,nil,nil,nil,nil,nil,nil,nil}, -- Blighted Blastbones


            [6]= { 39095,nil,nil,nil,nil,nil,nil,nil,nil}, -- ele Drain
            [7]= { 39089,nil,nil,nil,nil,nil,nil,nil,nil}, -- Ele sus

            [8]= {118763,nil,nil,nil,nil,nil,nil,nil,nil}, -- Detonating Siphon


            [9]= { 117805,nil,nil,nil,nil,nil,nil,nil,nil}, -- Unerving Boneyard
           [10]= {117850,nil,nil,nil,nil,nil,nil,nil,nil}, -- Avid Boneyard
           [11]= {118726,nil,nil,nil,nil,nil,nil,nil,nil}, -- Skeletal Arcanist
           [12]= {118680,nil,nil,nil,nil,nil,nil,nil,nil}, -- Skeletal Archer

           [13]= {39073,nil,nil,nil,nil,nil,nil,nil,nil}, -- Unstable Wall of Storms
           [14]= {40382,nil,nil,nil,nil,nil,nil,nil,nil}, -- Barbed trap


           [15]= {40242,nil,nil,nil,nil,nil,nil,nil,nil}, -- Razor Caltrops
           [16]= {40465,nil,nil,nil,nil,nil,nil,nil,nil}, -- Scalding Rune
           [17]= {40452,nil,nil,nil,nil,nil,nil,nil,nil}, -- Structured Entropy

           [18]= {42028,nil,nil,nil,nil,nil,nil,nil,nil}, -- Mystic Orb


           [19]= {118763,3,nil,nil,nil,nil,nil,nil,nil}, -- Detonating Siphon (AS Spammable every 3s?)


           [20]= {117637,nil,nil,nil,nil,nil,nil,nil,nil}, -- Ricochet Skull
           [21]= {117624,nil,nil,nil,nil,nil,nil,nil,nil}, -- Venom Skull

           [22]= {46356,nil,nil,nil,nil,nil,nil,nil,nil}, --  Force Pulse
        },-- NECRO
[6]=    { -- TEMPLAR



           --
            -- HEALS
            [1]= {22256,nil,nil,nil,nil,nil,nil,nil,nil}, -- Breath of Life
            [2]= {26797,-1,75,nil,nil,nil,nil,nil,nil}, -- Puncturing Sweep(Heal)
            [3]= {61505,nil,nil,nil,nil,nil,nil,nil,nil}, -- echoing vigor

            --DOTS
            [4]= {21765,nil,nil,nil,nil,nil,nil,nil,nil}, -- Purifying Light
            [5]= {21763,nil,nil,nil,nil,nil,nil,nil,nil}, -- Power of the Light

            [6]= {63046,nil,nil,nil,nil,nil,nil,nil,nil}, -- Radiant Oppression

            [7]= { 39095,nil,nil,nil,nil,nil,nil,nil,nil}, -- ele Drain
            [8]= { 39089,nil,nil,nil,nil,nil,nil,nil,nil}, -- Ele sus

            [9]= {21729,nil,nil,nil,nil,nil,nil,nil,nil}, -- Vampire's Bane
           [10]= {22095,nil,nil,nil,nil,nil,nil,nil,nil}, -- Solar Barrage

           [11]= {22259,nil,nil,nil,nil,nil,nil,nil,nil}, -- Ritual of Retribution

           [12]= { 39073,nil,nil,nil,nil,nil,nil,nil,nil}, -- Unstable Wall of Storms
           [13]= {40382,nil,nil,nil,nil,nil,nil,nil,nil}, -- Barbed trap


           [14]= {40242,nil,nil,nil,nil,nil,nil,nil,nil}, -- Razor Caltrops
           [15]= {40465,nil,nil,nil,nil,nil,nil,nil,nil}, -- Scalding Rune
           [16]= {40452,nil,nil,nil,nil,nil,nil,nil,nil}, -- Structured Entropy

           [17]= {26869,10,nil,nil,nil,nil,nil,nil,nil}, -- Blazing Spear (10 second DOT)



           [18]= {22262,nil,nil,nil,nil,nil,nil,nil,nil}, -- Extended Ritual
             -- spammable
           [19]= {26797,nil,nil,nil,nil,nil,nil,nil,nil}, -- Puncturing Sweep(Spammable)
           [20]= {26869,nil,nil,nil,nil,nil,nil,nil,nil}, -- Blazing Spear(Spammable)
           [21]= {46356,nil,nil,nil,nil,nil,nil,nil,nil}, --  Force Pulse
--]]

        },-- TEMPLAR


}

HeavyAttackHelper.skillPriorityOrder = {}






-- remap some skills to their main variant
HeavyAttackHelper.remapSkillId = {
    [130291] = 24165, -- bound armaments
    --[114716] = 46324, -- crystal frag (maybe don't remap Crystal Frags)
    --[24639] = 77369, -- healy bird
    [23316] = 77182, -- dps familiar
    [123719] = 117637, -- Ricochet Skull
    [123718] = 117637, -- Ricochet Skull

    [123704] = 117624,  -- id for Venom Skull when procing???
    [123699] = 117624,  -- id for Venom Skull when procing???


}




HeavyAttackHelper.combatEventsToSkills = {
    -- combat              name                                        cast skill that started                  result which triggers this
    -- EventID
    [39073] =           {"Unstable Wall of Storms",                 39073,                                   {ACTION_RESULT_EFFECT_GAINED, }        },
    [24328] =           {"Daedric Prey",                            24328,                                   {ACTION_RESULT_EFFECT_GAINED, }        },
    [88933] =           {"Volatile Familiar",                       77182,                                   {ACTION_RESULT_EFFECT_GAINED, }        },
    [23678] =           {"Critical Surge",                          23678,                                   {ACTION_RESULT_EFFECT_GAINED, }        },
    [23213] =           {"Boundless Storm",                         23213,                                   {ACTION_RESULT_EFFECT_GAINED, }        },
    [23231] =           {"Hurricane",                               23231,                                   {ACTION_RESULT_EFFECT_GAINED, }        },

    [24842] =           {"Daedric Tomb",                            24842,                                   {ACTION_RESULT_EFFECT_GAINED_DURATION,ACTION_RESULT_EFFECT_GAINED, }        },
    [42028] =           {"Mystic Orb",                              42028,                                   {ACTION_RESULT_EFFECT_GAINED, }        },
    [61506] =           {"Echoing Vigor",                           61505,                                   {ACTION_RESULT_EFFECT_GAINED_DURATION,ACTION_RESULT_EFFECT_GAINED, }        },
    [61509] =           {"Resolving Vigor",                         61507,                                   {ACTION_RESULT_EFFECT_GAINED_DURATION,ACTION_RESULT_EFFECT_GAINED, }        },



    [40382] =           {"Barbed Trap",                             40382,                                   {ACTION_RESULT_EFFECT_GAINED, }        },

    [40465] =           {"Scalding Rune",                           40465,                                   {ACTION_RESULT_EFFECT_GAINED_DURATION,ACTION_RESULT_EFFECT_GAINED, }        },
    [40242] =           {"Razor Caltrops",                          40242,                                   {ACTION_RESULT_EFFECT_GAINED, }     },



    [86027] =           {"Fetcher Infection",                       86027,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [86031] =           {"Growing Swarm",                           86031,                                   {ACTION_RESULT_EFFECT_GAINED, }     },


    [86169] =           {"Winter's Revenge",                        86169,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [90834] =           {"Arctic Blast",                            86156,                                   {ACTION_RESULT_EFFECT_GAINED, }     },


    [86003] =           {"Screaming Cliff Racer",                   86003,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [86015] =           {"Deep Fissure",                            86015,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [86019] =           {"Subterranean Assault",                    86019,                                   {ACTION_RESULT_EFFECT_GAINED, }     },


    [126371] =          {"Structured Entropy",                      40452,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [62787] =           {"Elemental Drain",                         39095,                                   {ACTION_RESULT_EFFECT_GAINED, }     },-- major breach specific to eledrain
    [62775] =           {"Elemental Susceptibility",                39089,                                   {ACTION_RESULT_EFFECT_GAINED, }     },-- major breach specific to ele sus
    [117749] =          {"Stalking Blastbones",                    117749,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [117690] =          {"Blighted Blastbones",                    117690,                                   {ACTION_RESULT_EFFECT_GAINED, }     },



    [117637] =          {"Ricochet Skull",                         117637,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [123719] =          {"Ricochet Skull",                         117637,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [123718] =          {"Ricochet Skull",                         117637,                                   {ACTION_RESULT_EFFECT_GAINED, }     },


    [117624] =          {"Venom Skull",                            117624,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [123704] =          {"Venom Skull",                            117624,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [123699] =          {"Venom Skull",                            117624,                                   {ACTION_RESULT_EFFECT_GAINED, }     },


    [117805] =          {"Unnerving Boneyard",                     117805,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [117850] =          {"Avid Boneyard",                          117850,                                   {ACTION_RESULT_EFFECT_GAINED, }     },


    [118726] =          {"Skeletal Arcanist",                      118726,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [118680] =          {"Skeletal Archer",                        118680,                                   {ACTION_RESULT_EFFECT_GAINED, }     },

    [118912] =          {"Spirit Guardian",                        118912,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [117883] =          {"Resistant Flesh",                        117883,                                   {ACTION_RESULT_CRITICAL_HEAL,ACTION_RESULT_HEAL }     },


    [20252] =           {"Burning Talons",                          20252,                                   {ACTION_RESULT_DAMAGE,ACTION_RESULT_CRITICAL_DAMAGE, }     }, -- required damage to detect
    [20805] =           {"Molten Whip",                             20805,                                   {ACTION_RESULT_DAMAGE,ACTION_RESULT_CRITICAL_DAMAGE, }     },
    [32722] =           {"Coagulating Blood",                       32722,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [32853] =           {"Flames of Oblivion",                      32853,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [20668] =           {"Venomous Claw",                           20668,                                   {ACTION_RESULT_DAMAGE,ACTION_RESULT_CRITICAL_DAMAGE, }     },
    [20930] =           {"Engulfing Flames",                        20930,                                   {ACTION_RESULT_DAMAGE,ACTION_RESULT_CRITICAL_DAMAGE, }     },
    [32792] =           {"Deep Breath",                             32792,                                   {ACTION_RESULT_DAMAGE,ACTION_RESULT_CRITICAL_DAMAGE, }     },
    [32710] =           {"Eruption",                                32710,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [76518] =           {"Igneous Weapons",                         31874,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [143806] =          {"Crystal Weapon",                          46331,                                   {ACTION_RESULT_EFFECT_GAINED, }     },

    [77354] =           {"Twilight Tormentor Enrage",               77140,                                   {ACTION_RESULT_EFFECT_GAINED, }     },

    [36049] =           {"Twisting Path",                           36049,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [25267] =           {"Concealed Weapon",                        25267,                                   {ACTION_RESULT_DAMAGE,ACTION_RESULT_CRITICAL_DAMAGE, }     },
    [34851] =           {"Impale",                                  34851,                                   {ACTION_RESULT_DAMAGE,ACTION_RESULT_CRITICAL_DAMAGE, }     },
    [34835] =           {"Swallow Soul",                            34835,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [61919] =           {"Merciless Resolve",                       61919,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [61930] =           {"Assassin's Will",                         61930,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [35434] =           {"Dark Shade",                              35434,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [36943] =           {"Debilitate",                              36943,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [36967] =           {"Reaper's Mark",                           36967,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [35336] =           {"Lotus Fan",                               25493,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [45655] =           {"Sap Essence",                             36891,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [46356] =           {"Force Pulse",                             46356,                                   {ACTION_RESULT_EFFECT_GAINED, }     },


    [63046] =           {"Radiant Oppression",                      63046,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [22256] =           {"Breath of Life",                          22256,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [26869] =           {"Blazing Spear",                           26869,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [22262] =           {"Extended Ritual",                         22262,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [21765] =           {"Purifying Light",                         21765,                                   {ACTION_RESULT_EFFECT_GAINED, }     },

    [21763] =           {"Power of the Light",                      21763,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [22259] =           {"Ritual of Retribution",                   22259,                                   {ACTION_RESULT_EFFECT_GAINED, }     },

    [21729] =           {"Vampire's Bane",                          21729,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [22095] =           {"Solar Barrage",                           22095,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [26797] =           {"Puncturing Sweep",                        26797,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
    [85862] =           {"Enchanted Growth",                        85862,                                   {ACTION_RESULT_HEAL,ACTION_RESULT_CRITICAL_HEAL, }     },

   [118763] =           {"Detonating Siphon",                      118763,                                   {ACTION_RESULT_EFFECT_GAINED, }     },
}



HeavyAttackHelper.skillProperties = {
    --              [1]                           [2]         [3]         [4]           [5]         [6]             [7]         [8]        [9]
    --  SkillId     Name                       castSec    castHp%       CombEvent  Ultimate       minim target   target      target      force
    --                                        0.0=spam     player       Triggered  Required       HP/1000           HP%         HP%    require
    --                                      -1.0=never      HP% <                                                 above       under     target
    [77182] = {"Volatile Familiar",           20.0,       100,      true,             0,         0,               0,        100,     false, },
    [23316] = {"Summon Volatile Familiar",     0.0,       100,     false,             0,         0,               0,        100,     false, },

    [39073] = {"Unstable Wall of Storms",     10.0,       100,      true,             0,         0,               0,        100,     false, },
    [23213] = {"Boundless Storm",             30.0,       100,      true,             0,         0,               0,        100,     false, },
    [23231] = {"Hurricane",                   20.0,       100,      true,             0,         0,               0,        100,     false, },


    [24842] = {"Daedric Tomb",                15.0,       100,      true,             0,         0,               0,        100,     false, },
    [42028] = {"Mystic Orb",                  10.0,       100,      true,             0,         0,               0,        100,     false, },

    [46324] = {"Crystal Fragments",            0.0,       100,      false,            0,         0,               0,        100,     false, },
    [114716] = {"Crystal Fragments(proc)",      0.0,       100,      false,            0,         0,               0,        100,     false, },
    [24328] = {"Daedric Prey",                 6.1,       100,      true,             0,      1000,               0,        100,     false, }, -- min 1mil HP
    [23678] = {"Critical Surge",              33.0,       100,      true,             0,         0,               0,        100,     false, },

    [40382] = {"Barbed Trap",                 20.0,       100,      true,             0,         0,               0,        100,     false, },

    [77369] = {"Matriarch Restore",           -1.0,        75,      false,            0,         0,               0,        100,     false, },
    [24639] = {"Summon Matriarch Restore",     0.0,       100,      false,            0,         0,               0,        100,     false, },

    [77140] = {"Twilight Tormentor Enrage",   20.0,       100,       true,            0,      2000,              55,        100,      true, }, -- min 2mil HP
    [24636] = {"Summon Twilight Tormentor",    0.0,       100,      false,            0,         0,               0,        100,     false, },

    [23678] = {"Critical Surge",              33.0,       100,       true,            0,         0,               0,        100,     false, },
    [61505] = {"Echoing Vigor",               15.0,       100,       true,            0,         0,               0,        100,     false, },
    [61507] = {"Resolving Vigor",             20.0,       100,       true,            0,         0,               0,        100,     false, },


    [40465] = {"Scalding Rune",               24.0,       100,       true,            0,         0,               0,        100,     false, },
    [40242] = {"Razor Caltrops",              10.0,       100,       true,            0,         0,               0,        100,     false, },

    [86027] = {"Fetcher Infection",           20.0,       100,       true,            0,         0,               0,        100,     false, },
    [86031] = {"Growing Swarm",               20.0,       100,       true,            0,         0,               0,        100,     false, },


    [86169] = {"Winter's Revenge",            12.0,       100,       true,            0,         0,               0,        100,     false, },
    [86156] = {"Arctic Blast",                20.0,       100,       true,            0,         0,               0,        100,     false, },

    [86003] = {"Screaming Cliff Racer",        0.0,       100,       true,            0,         0,               0,        100,     false, },
    [86015] = {"Deep Fissure",                 9.0,       100,       true,            0,         0,               0,        100,     false, },
    [86019] = {"Subterranean Assault",         6.0,       100,       true,            0,         0,               0,        100,     false, },



    [40452] = {"Structured Entropy",          24.0,       100,       true,            0,         0,               0,        100,     false, },
    [39095] = {"Elemental Drain",             60.0,       100,       true,            0,         0,               0,        100,     false, },
    [39089] = {"Elemental Susceptibility",    30.0,       100,       true,            0,         0,               0,        100,     false, },
   [117749] = {"Stalking Blastbones",          0.0,       100,       true,            0,         0,               0,        100,     false, },
   [117690] = {"Blighted Blastbones",          0.0,       100,       true,            0,         0,               0,        100,     false, },

   [117637] = {"Ricochet Skull",               0.0,       100,       true,            0,         0,               0,        100,     false, },
   [117624] = {"Venom Skull",               0.0,       100,       true,            0,         0,               0,        100,     false, },

   [117805] = {"Unnerving Boneyard",          10.0,       100,       true,            0,         0,               0,        100,     false, },
   [117850] = {"Avid Boneyard",               10.0,       100,       true,            0,         0,               0,        100,     false, },
   [117883] = {"Resistant Flesh",             -1.0,        75,       true,            0,         0,               0,        100,     false, },

   [118726] = {"Skeletal Arcanist",           20.0,       100,       true,            0,         0,               0,        100,     false, },
   [118680] = {"Skeletal Archer",             20.0,       100,       true,            0,         0,               0,        100,     false, },
   [118912] = {"Spirit Guardian",             16.0,       100,       true,            0,         0,               0,        100,     false, },

   [118763] = {"Detonating Siphon",            20,       100,      true,             0,         0,               0,        100,     false, },

    [20252] = {"Burning Talons",               4.0,       100,       true,            0,         0,               0,        100,     false, }, -- note this skill doesn't register unless it actually hits something
    [20805] = {"Molten Whip",                  0.0,       100,       true,            0,         0,               0,        100,     false, },
    [32722] = {"Coagulating Blood",           -1.0,        65,       true,            0,         0,               0,        100,     false, },
    [32853] = {"Flames of Oblivion",            15,       100,       true,            0,         0,               0,        100,     false, },
    [20668] = {"Venomous Claw",                 24,       100,       true,            0,         0,               0,        100,     false, },
    [20930] = {"Engulfing Flames",              24,       100,       true,            0,         0,               0,        100,     false, },
    [32792] = {"Deep Breath",                    4,       100,       true,            0,         0,               0,        100,     false, },
    [32710] = {"Eruption",                      18,       100,       true,            0,         0,               0,        100,     false, },
    [31874] = {"Igneous Weapons",               72,       100,       true,            0,         0,               0,        100,     false, },

    [46331] = {"Crystal Weapon",                 6,       100,       true,            0,         0,               0,        100,     false, },

    [24163] = {"Bound Aegis",                   20,       90,       true,             0,         0,               0,        100,     false, },



    [36049] = {"Twisting Path",                 12,       100,       true,            0,         0,               0,        100,     false, },
    [25267] = {"Concealed Weapon",               0,       100,       true,            0,         0,               0,        100,     false, },
    [34851] = {"Impale",                         0,       100,       true,            0,      1000,               0,         25,     false, },
    [34835] = {"Swallow Soul",                   0,       100,       true,            0,         0,               0,        100,     false, },
    [61919] = {"Merciless Resolve",             40,       100,       true,            0,         0,               0,        100,     false, },
    [61930] = {"Assassin's Will",                0,       100,       true,            0,      1000,              25,        100,     false, },
    [35434] = {"Dark Shade",                    22,       100,       true,            0,         0,               0,        100,     false, },
    [36943] = {"Debilitate",                    20,       100,       true,            0,         0,               0,        100,     false, },
    [36967] = {"Reaper's Mark",                 20,       100,       true,            0,         0,               0,        100,     false, },
    [25493] = {"Lotus Fan",                     20,       100,       true,            0,         0,               0,        100,     false, },
    [36891] = {"Sap Essence",                    0,       100,       true,            0,         0,               0,        100,     false, },
    [46356] = {"Force Pulse",                    0,       100,       true,            0,         0,               0,        100,     false, },


    [85862] = {"Enchanted Growth",            -1.0,        75,       true,            0,         0,               0,        100,     false, },

    [63046] = {"Radiant Oppression",             0,       100,       true,            0,      1000,               0,         50,     false, },
    [22256] = {"Breath of Life",                -1,        75,       true,            0,         0,               0,        100,     false, },
    [26869] = {"Blazing Spear",                  0,       100,       true,            0,         0,               0,        100,     false, },
    [22262] = {"Extended Ritual",               30,       100,       true,            0,         0,               0,        100,     false, },
    [21765] = {"Purifying Light",                6,       100,       true,            0,      1000,              10,        100,     false, },
    [21763] = {"Power of the Light",             6,       100,       true,            0,      1000,              10,        100,     false, },
    [22259] = {"Ritual of Retribution",         20,       100,       true,            0,         0,               0,        100,     false, },

    [21729] = {"Vampire's Bane",                32,       100,       true,            0,         0,               0,        100,     false, },
    [22095] = {"Solar Barrage",                 22,       100,       true,            0,         0,               0,        100,     false, },
    [26797] = {"Puncturing Sweep",               0,       100,       true,            0,         0,               0,        100,     true, },





    -- ULTIMATES
    [23495] = {"Summon Charged Atronach",     -1.0,       100,      false,          170,         0,               0,        100,     false, },
    [23492] = {"Greater Storm Atronach",      -1.0,       100,      false,          170,         0,               0,        100,     false, },
    [85130] = {"Thunderous Rage",             -1.0,       100,      false,          250,         0,               0,        100,     false, },
    [24806] = {"Power Overload",              -1.0,       100,      false,           21,         0,               0,        100,     false, },
    [40493] = {"Shooting Star",               -1.0,       100,      false,          200,         0,               0,        100,     false, },
    [40223] = {"Aggressive Horn",             -1.0,       100,      false,          250,         0,               0,        100,     false, },
    [40237] = {"Reviving Barrier",            -1.0,       100,      false,          250,         0,               0,        100,     false, },
   [122395] = {"Pestilent Colossus",          -1.0,       100,      false,          225,         0,               0,        100,     false, },
   [118379] = {"Animate Blastbones",          -1.0,       100,      false,          320,         0,               0,        100,     false, },
    [32947] = {"Standard of Might",           -1.0,       100,      false,          250,         0,               0,        100,     false, },
   [113105] = {"Incapacitating Strike",       -1.0,       100,      false,           70,         0,               0,        100,     false, },
    [36508] = {"Incapacitating Strike",       -1.0,       100,      false,           70,         0,               0,        100,     false, },
    [36514] = {"Soul Harvest",                -1.0,       100,      false,           70,         0,               0,        100,     false, },
    [86113] = {"Northern Storm",              -1.0,       100,      false,          200,         0,               0,        100,     false, },


}


function HeavyAttackHelper.doSkillNeedToBeCastBasedOnCooldown(slot)
    local skillId = HeavyAttackHelper.Skills[slot]
    local skillProperty = HeavyAttackHelper.skillProperties[skillId]

    if skillProperty == nil then
        --d("slot "..slot.." exit due to nil (skillProperty)")
        return false
    end

    local castTime = skillProperty[2]

    if castTime==nil then
        --d("slot "..slot.." exit due to nil (castTime)")
        return false
    end

    local skillLastUsed = HeavyAttackHelper.SkillLastUsed[slot]
    local skillSinceLastUsed = (currentTime-skillLastUsed)/1000

    if castTime > 0 and skillSinceLastUsed>=castTime then -- is this a time based cast? and if so is it more than 0 seconds
        return true -- we should cast this skill
    else
        return false
    end
end

function HeavyAttackHelper.diffTimeinSeconds(t)
    local difms = GetGameTimeMilliseconds()-t
    local difs = difms/1000
    return difs
end

function HeavyAttackHelper.doSkillSelectionTasks()

    currentTime = GetGameTimeMilliseconds()
    --timeSinceHeavyStart = currentTime-HeavyAttackHelper.lastHeavyAttackStartTime
    timeSinceHeavyStart = currentTime-HeavyAttackHelper.heavyEffectStartTime
    timeSinceHeavySound = currentTime-HeavyAttackHelper.lastSoundTime

    if (HeavyAttackHelper.savedVars.playSoundForNextSkillTime) and (HeavyAttackHelper.heavyEffectHeavyInProgress) and (timeSinceHeavySound > 800) and (timeSinceHeavyStart > 1000) and (timeSinceHeavyStart < 1200)  then
        HeavyAttackHelper.lastSoundTime = GetGameTimeMilliseconds()
        PlaySound(HeavyAttackHelper.savedVars.soundEffectCast)
    end



    local skillFound = false
    local skillToUse = 0

    local current, max, effectiveMax = GetUnitPower("player", POWERTYPE_HEALTH)

    local playerHpPercentage = current / max * 100

    local currentTime = GetGameTimeMilliseconds()





    local currentReticle, maxReticle, effectiveMaxReticle = GetUnitPower("reticleover", POWERTYPE_HEALTH)
    local typeReticle = GetUnitType("reticleover")
    local percentReticle = 100 -- default to 100% for no target

    if currentReticle and maxReticle then
        percentReticle=currentReticle/maxReticle*100
    end

    --difficultyReticle = GetUnitDifficulty("reticleover")
    local attackableReticle = IsUnitAttackable( "reticleover" )
    --local hostileReticle = GetUnitReaction( "reticleover" ) == UNIT_REACTION_HOSTILE

    local haveValidTarget = false
    if attackableReticle then
        haveValidTarget=true
    end








    for i,skillidinPriorityListDic in ipairs(HeavyAttackHelper.skillPriorityOrder) do
        if skillFound then
            break
        end

        --d(skillidinPriorityListDic[1])
        skillidinPriorityList = skillidinPriorityListDic[1] -- load the skill ID from the priority list dictionary

        local castEarlySpammable = false
        if skillidinPriorityList<-1 then
            skillidinPriorityList = skillidinPriorityList * -1
            castEarlySpammable=true
        end

        --d("skillidinPriorityList:"..skillidinPriorityList)
        for skillSlot=1,5 do
            local skillId = HeavyAttackHelper.Skills[skillSlot]
            --d("slot: "..skillSlot.." skillId: "..skillId .. " trying to match to priority list: ".. skillidinPriorityList)
            local skillUsable = HeavyAttackHelper.SkillUsable[skillSlot]


            if skillidinPriorityList == skillId then

                -- special case if skill is talons only use it if whip is viable since whip is the same range?
                if skillId==20252 or skillId==20930 or skillId==32792 then -- if skill is talons, or engulfing (eventhough englifing is 10m), deep breath
                    for skillSlotWhip=1,5 do
                        local skillIdWhip = HeavyAttackHelper.Skills[skillSlotWhip]
                        if skillIdWhip == 20805 or skillIdWhip == 20668  then -- find Molden whip or Venomous Claw
                            local skillUsableWhip = HeavyAttackHelper.SkillUsable[skillSlotWhip]
                            if skillUsableWhip==false then -- if whip/claw isn't viable, then neither is talons
                                skillUsable = false
                            end
                        end
                    end
                end
                -- special case if skill is talons only use it if whip is viable since whip is the same range?

                if skillUsable then
                    if skillFound == false then
                        -- found skill from priority list AND in bar
                        --d("pass if statements")

                        local skillProperty = HeavyAttackHelper.skillProperties[skillId]
                        if not (skillProperty == nil) then
                                -- we have skill data for this skill
                                local name = skillProperty[1]
                                local castTime = skillProperty[2]
                                if not (skillidinPriorityListDic[2]==nil) then castTime = skillidinPriorityListDic[2] end


                                local playerHpUnder = skillProperty[3]
                                if not (skillidinPriorityListDic[3]==nil) then playerHpUnder = skillidinPriorityListDic[3] end

                                local targetHpOver = skillProperty[6]*1000
                                if not (skillidinPriorityListDic[6]==nil) then targetHpOver = skillidinPriorityListDic[6]*1000 end

                                local targetCurrentHpPercentOver = skillProperty[7]
                                if not (skillidinPriorityListDic[7]==nil) then targetCurrentHpPercentOver = skillidinPriorityListDic[7] end


                                local targetCurrentHpPercentUnder = skillProperty[8]
                                if not (skillidinPriorityListDic[8]==nil) then targetCurrentHpPercentUnder = skillidinPriorityListDic[8] end

                                local targetRequiredForced = skillProperty[9]
                                if not (skillidinPriorityListDic[9]==nil) then targetRequiredForced = skillidinPriorityListDic[9] end

                                local skillLastUsed = HeavyAttackHelper.SkillLastUsed[skillSlot]
                                local skillSinceLastUsed = (currentTime-skillLastUsed)/1000


                                local useThisSkill = false

                                if castTime == -1 then -- cast on demand
                                    if playerHpPercentage<=playerHpUnder then -- only current demand is HP is low
                                        useThisSkill = true
                                    end
                                elseif skillSinceLastUsed>=castTime then
                                    useThisSkill = true
                                end

                                if skillId==86156 and playerHpPercentage<=60 then -- artic blast as burst heal
                                    useThisSkill = true
                                end

                                if skillId==61507 and playerHpPercentage<=80 and skillSinceLastUsed > 4.5 then -- resolving vigor after 5s
                                    --d(playerHpPercentage.."<="..playerHpUnder.." since:"..skillSinceLastUsed)
                                    useThisSkill = true
                                end

                                if castEarlySpammable and skillId==86015 and skillSinceLastUsed>3 and skillSinceLastUsed < 5.5 then -- deep fisher early as spammable
                                    useThisSkill = true
                                end

                                if castEarlySpammable and skillId==86169 and skillSinceLastUsed>5 then -- Winters Revenge early as spammable
                                    useThisSkill = true
                                end


                                if skillId==40452 and IsUnitAttackable("reticleover") then -- structured entropy
                                    local needEntropy = true
                                    for buffIndex =1,GetNumBuffs("reticleover") do
                                        local _buffName_, _timeStarted_, _timeEnding_, _buffSlot_, _stackCount_, _iconFilename_, _buffType_, _effectType_, _abilityType_, _statusEffectType_, _abilityId_, _canClickOff_ = GetUnitBuffInfo("reticleover", buffIndex)
                                        if (_buffName_=="Structured Entropy") then
                                            needEntropy = false
                                        end
                                    end
                                    if needEntropy then
                                        --d("missing structured entropy")
                                        useThisSkill = true
                                    end
                                end





                                if playerHpPercentage>playerHpUnder then -- if player HP requirement not met, skip skill
                                    useThisSkill = false
                                end


                                if (targetHpOver > 0) and (targetHpOver > maxReticle) then
                                    useThisSkill = false -- cancel using this skill because the HP is too low
                                    --d("skipped skill targetHpOver:"..targetHpOver.." maxReticle:"..maxReticle)
                                end

                                if (targetRequiredForced) and (not (haveValidTarget)) then
                                    useThisSkill = false -- cancel using this skill because the HP is too low
                                end

                                if targetCurrentHpPercentUnder<100 then
                                    if percentReticle > targetCurrentHpPercentUnder then
                                        useThisSkill = false
                                    end
                                end

                                if targetCurrentHpPercentOver> 0 then
                                    if percentReticle < targetCurrentHpPercentOver then
                                        useThisSkill = false
                                    end
                                end




                                if useThisSkill then

                                    skillFound = true
                                    skillToUse = skillidinPriorityList
                                    --d("skill to use:"..skillidinPriorityList)

                                    break
                                end
                        else
                            --d("failed to find skill properties")
                        end
                    else
                        --d("skill found = false")
                    end
                else
                    --d("skill usable = false")
                end
            else
                --d("skill not in priority list/slot mismatch")
            end
        end
    end


    local locatedSkillSlot = false

    for skillSlot=1,5 do
        local skillId = HeavyAttackHelper.Skills[skillSlot]
        if (skillId==skillToUse) then

            if HeavyAttackExtra then
                HeavyAttackExtra.us(skillId)
            end
            if HeavyAttackHelper.savedVars.smallIcons then
                HeavyAttackHelper.setArrowColor(skillSlot, "smallgreen")
            else
                HeavyAttackHelper.setArrowColor(skillSlot, "green")
            end
            HeavyAttackHelper.currentRecommendedSkillSlot = skillSlot
            locatedSkillSlot = true
        else
            if HeavyAttackExtra then
                HeavyAttackExtra.bs(skillId)
            end


            if HeavyAttackHelper.savedVars.showYellowforOffCooldownSkills then
                --d("check yellow2")
                if HeavyAttackHelper.doSkillNeedToBeCastBasedOnCooldown(skillSlot) then
                    HeavyAttackHelper.setArrowColor(skillSlot, "hexyellow")
                else
                    HeavyAttackHelper.setArrowColor(skillSlot, "")
                end
            else
                HeavyAttackHelper.setArrowColor(skillSlot, "")
            end



        end
    end

    if not (locatedSkillSlot) then -- no recommended skill
        HeavyAttackHelper.currentRecommendedSkillSlot = 0
    end

    -- check ultimate
    local skillId = HeavyAttackHelper.Skills[6]
    local ultiPower = GetUnitPower("player", POWERTYPE_ULTIMATE)

    local skillProperty = HeavyAttackHelper.skillProperties[skillId]
    if not (skillProperty == nil) then
        if ultiPower>=skillProperty[5] then -- required ultimate
            if HeavyAttackHelper.savedVars.smallIcons then
                HeavyAttackHelper.setArrowColor(6, "smallgreen")
            else
                HeavyAttackHelper.setArrowColor(6, "green")
            end
        else
            --if HeavyAttackHelper.savedVars.showRedforNonOptimalSkills then
            --    HeavyAttackHelper.setArrowColor(6, "red")
            --else
                HeavyAttackHelper.setArrowColor(6, "")
            --end
        end
    else
        HeavyAttackHelper.setArrowColor(6, "")
    end

    if (not (skillFound)) and HeavyAttackHelper.savedVars.noSkillsWarning and haveValidTarget then -- only display warning if we have a target

        HeavyAttackHelper.setArrowColor(7, "noskill")
    else
        if HeavyAttackHelper.heavyEffectHeavyWasFullyCharged or HeavyAttackHelper.diffTimeinSeconds(HeavyAttackHelper.mediumEffectDetectionTime) > 3 or not (HeavyAttackHelper.savedVars.mediumAttackWarning)then
            HeavyAttackHelper.setArrowColor(7, "")
        else
            HeavyAttackHelper.setArrowColor(7, "medium")
        end
    end



end





function HeavyAttackHelper.skillSuggesterUpdateTimer()
    if (HeavyAttackHelper.heavyEffectHeavyInProgress) and (HeavyAttackHelper.diffTimeinSeconds(HeavyAttackHelper.heavyEffectStartTime) >= 1.7)  then
        HeavyAttackHelper.heavyEffectEventCode = -1
        HeavyAttackHelper.heavyEffectSlot = -1
        HeavyAttackHelper.heavyEffectHeavyInProgress = false
        HeavyAttackHelper.heavyEffectHeavyWasFullyCharged = true

        HeavyAttackHelper.heavyActionSlotStartTime = 0
        HeavyAttackHelper.heavyActionHeavyInProgress = false

        if HeavyAttackHelper.savedVars.debugHeavyAttackDetection then
            d("Heavy attack over 1.7s") -- this appears to never happen
        end
    end

    HeavyAttackHelper.UpdateBar()


    if HeavyAttackHelper.inCombat and (IsUnitDead("player") == false) then
        HeavyAttackHelperFrame:SetHidden(false) -- show GUI
        HeavyAttackHelper.loadSkills()
        HeavyAttackHelper.doSkillSelectionTasks()
    else
        HeavyAttackHelper.currentRecommendedSkillSlot = 0
        if HeavyAttackHelper.movingUI == false then

            HeavyAttackHelperFrame:SetHidden(true) -- show GUI
        end
        if HeavyAttackExtra then
            HeavyAttackExtra.uas()
        end
    end

end



function HeavyAttackHelper.activateSkillSuggester()
    --d("active skill suggester")
    HeavyAttackHelper.skillSuggesterActive = true
    HeavyAttackHelper.skillSuggesterUpdateTimer()
    EM:RegisterForUpdate(HeavyAttackHelper.name.."SkillSuggester", 100, function(gameTimeMs) HeavyAttackHelper.skillSuggesterUpdateTimer() end)
    EM:RegisterForUpdate(HeavyAttackHelper.name.."BarTimer", 10, function(gameTimeMs) HeavyAttackHelper.UpdateBar() end)
end


function HeavyAttackHelper.deactivateSkillSuggester()

    EM:UnregisterForUpdate(HeavyAttackHelper.name.."SkillSuggester")
    EM:UnregisterForUpdate(HeavyAttackHelper.name.."BarTimer")
    if HeavyAttackExtra then
        HeavyAttackExtra.uas()
    end
    HeavyAttackHelperFrame:SetHidden(true)
    --HeavyAttackHelper.bar:SetHidden(true)
    HeavyAttackHelper.skillSuggesterActive = false
end








function HeavyAttackHelper.OnPlayerCombatState(event, inCombat)

    HeavyAttackHelper.checkIfAddonNeedsToBeLoadedOrUnloaded()

  if inCombat ~= HeavyAttackHelper.inCombat then
    HeavyAttackHelper.inCombat = inCombat
    if not inCombat then
        -- clear any variables out of combat
    else
        HeavyAttackHelper.movingUI = false -- remove moving when going into combat
    end

  end

end

function HeavyAttackHelper.setPos()
	local x, y = HeavyAttackHelper.savedVars.offsetX, HeavyAttackHelper.savedVars.offsetY
	HeavyAttackHelperFrame:ClearAnchors()
	HeavyAttackHelperFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

function HeavyAttackHelper.savePos()
	HeavyAttackHelper.savedVars.offsetX = HeavyAttackHelperFrame:GetLeft()
	HeavyAttackHelper.savedVars.offsetY = HeavyAttackHelperFrame:GetTop()
end

--HeavyAttackHelper.heavyStartTime = 0

function HeavyAttackHelper.combatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
    --d("combat event")

    if targetName==HeavyAttackHelper.playerName and abilityId==46331 and result == ACTION_RESULT_EFFECT_FADED then
        for slot=1,5 do -- look for crystal weapon
            if HeavyAttackHelper.Skills[slot] == 46331 then -- crystal activeWeaponPair
                HeavyAttackHelper.SkillLastUsed[slot]=HeavyAttackHelper.SkillLastUsed[slot]-6000 -- make the skill expire immediatly
            end
        end
    end


-- FULLY HEAVY
--[09:46] [09:46] Heavy attack GAINED
--[09:46] [09:46] Heavy attack BEGIN
--[09:46] [09:46] Heavy attack - DOT ticks
--[09:46] [09:46] Heavy attack GAINED DURATION
--[09:46] [09:46] Heavy attack - DOT ticks
--[09:46] [09:46] Heavy attack (no player) FADED
--[09:46] [09:46] Fully Charnged Heavy successful (via IA)


----

-- interupted heavy
--[09:49] [09:49] Heavy attack GAINED
--[09:49] [09:49] Heavy attack BEGIN
--[09:49] [09:49] Heavy attack - DOT ticks
--[09:49] [09:49] Heavy attack GAINED DURATION
--[09:49] [09:49] Heavy attack (no player) FADED

-- interupted heavy late
--[09:50] [09:50] Heavy attack GAINED
--[09:50] [09:50] Heavy attack BEGIN
--[09:50] [09:50] Heavy attack - DOT ticks
--[09:50] [09:50] Heavy attack GAINED DURATION
--[09:50] [09:50] Heavy attack - DOT ticks
--[09:50] [09:50] Heavy attack (no player) FADED



    if not (sourceName == HeavyAttackHelper.playerName) then return end
    --d("combat event-player")


    if abilityId==81519 and (result == ACTION_RESULT_EFFECT_GAINED) then
        -- detected a fully charged heavy attack by using IA set bonus
        if HeavyAttackHelper.savedVars.debugHeavyAttackDetection then
            d("Fully Charged Heavy successful (via IA)")
        end
    end

    --if abilityId==61509 then
    --    if ACTION_RESULT_EFFECT_GAINED==result then
    --        d("abilityId==61509 ACTION_RESULT_EFFECT_GAINED")
    --    elseif ACTION_RESULT_EFFECT_GAINED_DURATION==result then
    --        d("abilityId==61509 ACTION_RESULT_EFFECT_GAINED_DURATION")
    --    else
    --        d("abilityId==61509 "..result)
    --    end
    --    --[20:18] Brand-eh(1) src:Brand-eh (1) ability:Resolving Vigor(61509) HOT debuff
    --end


    combatEvent = HeavyAttackHelper.combatEventsToSkills[abilityId]
    if combatEvent==nil then return end
    --d("combat event-player-match combat event")







    for i,results in ipairs(combatEvent[3]) do
        if results==result then
            --d("combat event-player-match combat event-match event")
            -- found match now try to match it to the correct skill on your bars
            for slot=1,5 do

                if HeavyAttackHelper.Skills[slot] == combatEvent[2] then


                    if ((GetGameTimeMilliseconds()-HeavyAttackHelper.SkillLastUsed[slot])< 200) then
                        -- some skills re-appear multiple times quickly, remove the second appearance
                        break
                    end

                    -- 61919, -- Merciless Resolve
                    -- 61930, -- Assassin's Will
                    if HeavyAttackHelper.Skills[slot] == 61930 then -- Assassin's Will
                        -- do not record a skill for Assasin's Will as we will just track merc resolve
                    else
                        HeavyAttackHelper.SkillLastUsed[slot] = GetGameTimeMilliseconds()
                    end
                    if HeavyAttackHelper.savedVars.debugCombatEventSkillDetection then
                        d("HeavyAttack-Found: "..combatEvent[1])
                    end
                    break -- done stop searching now
                else
                    --d("slot:"..slot.."  -> "..HeavyAttackHelper.Skills[slot].."!="..combatEvent[2])
                end
            end
            break -- done stop searching now
        end
    end



end

function HeavyAttackHelper.EventWeaponSwap( activeWeaponPair, locked )
    HeavyAttackHelper.currentBar = locked
end





function HeavyAttackHelper.OnActionSlotEffectUpdated(hotBar, hotbarCategory, actionSlotIndex)
    if false then
        d("OnActionSlotEffectUpdated hotBar:".." hotbarCategory:"..hotbarCategory.." actionSlotIndex:"..actionSlotIndex.." bound:"..GetSlotBoundId(actionSlotIndex, hotbarCategory))
    end
    --hotbarCategory = 0,1 for bar 1 and bar 2
    --actionSlotIndex 1,2,3,4,5,6,7,8 for action??
end


--* EVENT_EFFECT_CHANGED (*[MsgEffectResult|#MsgEffectResult]* _changeType_, *integer* _effectSlot_, *string* _effectName_, *string* _unitTag_, *number* _beginTime_, *number* _endTime_, *integer* _stackCount_, *string* _iconName_, *string* _buffType_, *[BuffEffectType|#BuffEffectType]* _effectType_, *[AbilityType|#AbilityType]* _abilityType_, *[StatusEffectType|#StatusEffectType]* _statusEffectType_, *string* _unitName_, *integer* _unitId_, *integer* _abilityId_, *[CombatUnitType|#CombatUnitType]* _sourceType_)

function HeavyAttackHelper.checkEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitID, abilityID)
--



-- change types
--EFFECT_RESULT_FADED
--EFFECT_RESULT_FULL_REFRESH
--EFFECT_RESULT_GAINED
--EFFECT_RESULT_TRANSFER
--EFFECT_RESULT_UPDATED

    if abilityID == 18396 then -- lighting heavy attack
        if changeType == EFFECT_RESULT_GAINED then
            if unitTag == "reticleover" and HeavyAttackHelper.heavyActionHeavyInProgress and (not (HeavyAttackHelper.heavyEffectHeavyInProgress)) then -- should only detect MY heavy attacks
                if HeavyAttackHelper.savedVars.debugHeavyAttackDetection then
                    d("Heavy Attack Effect - GAINED "..eventCode) --.." abilityType:"..abilityType.." effectType:"..effectType.." statusEffectType:"..statusEffectType)
                end
                HeavyAttackHelper.heavyEffectEventCode = eventCode
                HeavyAttackHelper.heavyEffectSlot = effectSlot
                HeavyAttackHelper.heavyEffectStartTime = GetGameTimeMilliseconds()
                HeavyAttackHelper.heavyEffectHeavyInProgress = true
            end
        elseif changeType == EFFECT_RESULT_FADED then
            --if HeavyAttackHelper.heavyEffectSlot== effectSlot then
            --if HeavyAttackHelper.heavyEffectEventCode== eventCode  then
            if HeavyAttackHelper.heavyEffectEventCode == eventCode and HeavyAttackHelper.heavyEffectSlot == effectSlot and HeavyAttackHelper.heavyEffectHeavyInProgress then
                HeavyAttackHelper.heavyEffectEventCode = -1
                HeavyAttackHelper.heavyEffectSlot=-1
                HeavyAttackHelper.heavyEffectHeavyInProgress = false

                HeavyAttackHelper.heavyActionSlotStartTime = 0
                HeavyAttackHelper.heavyActionHeavyInProgress = false


                if HeavyAttackHelper.diffTimeinSeconds(HeavyAttackHelper.heavyEffectStartTime)>=1.45 then
                    if HeavyAttackHelper.savedVars.debugHeavyAttackDetection then
                        d("Fully charged heavy attack "..eventCode)
                    end
                    HeavyAttackHelper.heavyEffectHeavyWasFullyCharged= true
                else
                    if HeavyAttackHelper.savedVars.debugHeavyAttackDetection then
                        d("Medium attack "..HeavyAttackHelper.diffTimeinSeconds(HeavyAttackHelper.heavyEffectStartTime).."s "..eventCode)
                    end
                    HeavyAttackHelper.mediumEffectDetectionTime=GetGameTimeMilliseconds()
                    HeavyAttackHelper.heavyEffectHeavyWasFullyCharged = false
                end
                --d("Heavy Attack Effect - FADED "..HeavyAttackHelper.diffTimeinSeconds(HeavyAttackHelper.heavyEffectStartTime))
            end
        end
    end
end




function HeavyAttackHelper.loadSkills()
    for slot=3,8 do

        value = GetSlotBoundId(slot)

        -- convert skill to main skill id if needed
        if not (HeavyAttackHelper.remapSkillId[value] == nil) then
            value = HeavyAttackHelper.remapSkillId[value]
        end

        u = IsSlotUsable(slot)
        t = HasTargetFailure(slot)
        r = HasRangeFailure(slot)
        w = HasWeaponSlotFailure(slot)
        q = HasRequirementFailure(slot)

        if HeavyAttackHelper.Skills[slot-2] ~= value then
            if value==61930 and HeavyAttackHelper.Skills[slot-2]==61919 then -- do not reset timers for this skill
                -- 61919, -- Merciless Resolve
                -- 61930, -- Assassin's Will
                HeavyAttackHelper.Skills[slot-2] = value
            elseif value==61919 and HeavyAttackHelper.Skills[slot-2]==61930 then
                -- 61919, -- Merciless Resolve
                -- 61930, -- Assassin's Will
                HeavyAttackHelper.Skills[slot-2] = value
            else
                HeavyAttackHelper.Skills[slot-2] = value
                HeavyAttackHelper.SkillLastUsed[slot-2] = 0
            end
        end

        if u and (not t) and (not r) and (not w) and (not q) then
           -- skill is usable
           HeavyAttackHelper.SkillUsable[slot-2] = true
        else
            HeavyAttackHelper.SkillUsable[slot-2] = false
        end
    end
end

function HeavyAttackHelper.checkIfOakensoulEquipped()
	local oakensoul = 0
	_,_,_,oakensoul = GetItemLinkSetInfo("|H1:item:187658:364:50:45884:370:50:31:0:0:0:0:0:0:0:2049:0:0:1:0:0:0|h|h",true)
	if oakensoul>=1 then
		return true
	else
		return false
	end
end

function HeavyAttackHelper.checkIfAddonNeedsToBeLoadedOrUnloaded()
    if HeavyAttackHelper.checkIfOakensoulEquipped() then
	    HeavyAttackHelper.LoadAddon()
	else
	    HeavyAttackHelper.UnloadAddon()
	end
end

function HeavyAttackHelper.LoadAddon()
    if HeavyAttackHelper.addonLoaded == false then
        --d("Heavy Attack Helper Loaded")

        EM:RegisterForEvent(HeavyAttackHelper.name.."ECE", EVENT_COMBAT_EVENT, HeavyAttackHelper.combatEvent)
        EM:RegisterForEvent(HeavyAttackHelper.name, EVENT_ACTION_SLOT_ABILITY_USED, HeavyAttackHelper.onActionSlotAbilityUsed)



        EM:RegisterForEvent(HeavyAttackHelper.name, EVENT_EFFECT_CHANGED, HeavyAttackHelper.checkEffectChanged)
        EM:RegisterForEvent(HeavyAttackHelper.name, EVENT_ACTION_SLOT_EFFECT_UPDATE, HeavyAttackHelper.OnActionSlotEffectUpdated)


	    HeavyAttackHelper.addonLoaded=true

	    HeavyAttackHelper.loadSkills()

	    HeavyAttackHelper.activateSkillSuggester()
	end
end

function HeavyAttackHelper.UnloadAddon()
    if HeavyAttackHelper.addonLoaded == true then
        --d("Heavy Attack Helper Unloaded")
        HeavyAttackHelper.deactivateSkillSuggester()
        EM:UnregisterForEvent(HeavyAttackHelper.name.."ECE", EVENT_COMBAT_EVENT)
        EM:UnregisterForEvent(HeavyAttackHelper.name, EVENT_ACTION_SLOT_ABILITY_USED)
	    HeavyAttackHelper.addonLoaded=false
	end
end


function HeavyAttackHelper.onActionSlotAbilityUsed (eventCode,slotNum)
    --if slotNum == 2 then
    --    HeavyAttackHelper.lastHeavyAttackStartTime=GetGameTimeMilliseconds()
        --d('heavy')
    --end
    if slotNum == 2 then
        HeavyAttackHelper.heavyActionSlotStartTime = GetGameTimeMilliseconds()
        HeavyAttackHelper.heavyActionHeavyInProgress = true
    end

    if slotNum < 3 or slotNum > 7 then return end
    skillProperties = HeavyAttackHelper.skillProperties[HeavyAttackHelper.Skills[slotNum-2]]
    if not(skillProperties==nil) then
        if skillProperties[4]==true then
            return -- do not set time based on AbilityUsed, rather use combatEvents
        end
    end
    HeavyAttackHelper.SkillLastUsed[slotNum-2] = GetGameTimeMilliseconds()
end



function HeavyAttackHelper.printHelp()

    if HeavyAttackHelper.savedVars.extraFeatures then
        d("/ha ?            --> display this list")
        d("/ha help         --> display this list")

        d("/ha dev          --> toggle development mode")
        d("/ha debug        --> dump skill debug info")
        d("/ha skillsuggest --> test one cycle of skill selection")
    end

end




function HeavyAttackHelper.printDebug()
    currentTime = GetGameTimeMilliseconds()
    for skillSlot=1,5 do
        local skillId = HeavyAttackHelper.Skills[skillSlot]
        if skillId == nil then
            skillId = -1
        end

        local skillLastUsed = HeavyAttackHelper.SkillLastUsed[skillSlot]
        local skillSinceLastUsed = (currentTime-skillLastUsed)/1000
        skillSinceLastUsedUnits = "s"
        if skillSinceLastUsed>60 then
            skillSinceLastUsed="never"
            skillSinceLastUsedUnits=""
        end

        local skillProperty = HeavyAttackHelper.skillProperties[skillId]
        local skillName="Unknown Skill"
        local secondsBetweenCasts=-100
        local HpUnderPercentCasts=-1

        if not (skillProperty==nil) then
            skillName=skillProperty[1] -- name of the skill
            secondsBetweenCasts=skillProperty[2] -- how often to cast the skill
            HpUnderPercentCasts=skillProperty[3] -- cast HP under %
            --d("not nil")
        end
        --d(skillProperty)
        secondsBetweenCastsUnits="s"
        if secondsBetweenCasts == -100 then
            secondsBetweenCasts=""
            secondsBetweenCastsUnits=""
        elseif secondsBetweenCasts == -1 then
            secondsBetweenCasts="demand"
            secondsBetweenCastsUnits=""
        elseif secondsBetweenCasts == 0 then
            secondsBetweenCasts="spam"
            secondsBetweenCastsUnits=""
        end

        HpUnderPercentCastsUnits="%"
        if HpUnderPercentCasts==-1 then
            HpUnderPercentCasts="n/a"
            HpUnderPercentCastsUnits=""
        end


        d("slot"..skillSlot..": "..skillName.."  ("..skillId..") cast: "..secondsBetweenCasts..secondsBetweenCastsUnits.." HP%: "..HpUnderPercentCasts..HpUnderPercentCastsUnits.. " LastUsed:"..skillSinceLastUsed..skillSinceLastUsedUnits)


        local activeWeaponPair = GetActiveWeaponPairInfo()

    end
    --d("active Bar:"..activeWeaponPair)
    --if FancyActionBar then
    --    d("FancyActionBar found")
    --else
    --    d("FancyActionBar not found")
    --end
end

function HeavyAttackHelper.toggleExtraFeatures()
    HeavyAttackHelper.savedVars.extraFeatures = not HeavyAttackHelper.savedVars.extraFeatures
    if HeavyAttackHelper.savedVars.extraFeatures then
        d("HeavyAttack: Development features enabled (reloadui required)")
    else
        d("HeavyAttack: Development features disabled (reloadui required)")
    end
end

function HeavyAttackHelper.gamepadMode()
    if IsInGamepadPreferredMode() then
        d("game pad mode")
    else
        d("keyboard mouse mode")
    end
end

function HeavyAttackHelper.slashCommands(name)
    if name == nil then return HeavyAttackHelper.printHelp() end
    if name == "" then return HeavyAttackHelper.printHelp() end
    if name == "?" then return HeavyAttackHelper.printHelp() end
    if name == "help" then return HeavyAttackHelper.printHelp() end

    if name == "gamepad" then return HeavyAttackHelper.gamepadMode() end


    if name == "dev" then return HeavyAttackHelper.toggleExtraFeatures() end
    if HeavyAttackHelper.savedVars.extraFeatures then
        if name == "debug" then return HeavyAttackHelper.printDebug() end
        if name == "skillsuggest" then return HeavyAttackHelper.doSkillSelectionTasks() end
    end

end


function HeavyAttackHelper.setPos()
	local x, y = HeavyAttackHelper.savedVars.offsetX, HeavyAttackHelper.savedVars.offsetY
	HeavyAttackHelperFrame:ClearAnchors()
	HeavyAttackHelperFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

function HeavyAttackHelper.savePos()
	HeavyAttackHelper.savedVars.offsetX = HeavyAttackHelperFrame:GetLeft()
	HeavyAttackHelper.savedVars.offsetY = HeavyAttackHelperFrame:GetTop()
end

function HeavyAttackHelper.hideOutOfCombat()
	if HeavyAttackHelper.savedVars.passiveHide then
		HeavyAttackHelper:SetHidden(not IsUnitInCombat("player"))
	end
end

function HeavyAttackHelper.hideFrame()
	HeavyAttackHelperFrame:SetHidden(IsReticleHidden())
	if not IsReticleHidden() then HeavyAttackHelper.hideOutOfCombat() end
end




function HeavyAttackHelper.setArrowColor(position, color)
    local texture = string.format("HeavyAttackHelper/icons/arrow-%s.dds", color)
    if HeavyAttackHelper.movingUI then return end -- prevent changing icons during moving UI


    if (mcolor == "") or IsReticleHidden() then
          if position == 1 then
            HeavyAttackHelperFrame_Icon1:SetHidden(true)
        elseif position == 2 then
            HeavyAttackHelperFrame_Icon2:SetHidden(true)
        elseif position == 3 then
            HeavyAttackHelperFrame_Icon3:SetHidden(true)
        elseif position == 4 then
            HeavyAttackHelperFrame_Icon4:SetHidden(true)
        elseif position == 5 then
            HeavyAttackHelperFrame_Icon5:SetHidden(true)
        elseif position == 6 then -- ultimate
            HeavyAttackHelperFrame_Icon6:SetHidden(true)
        elseif position == 7 then -- HA status
            HeavyAttackHelperFrame_Icon7:SetHidden(true)

        end

    else
        if position == 1 then
            HeavyAttackHelperFrame_Icon1:SetTexture(texture)
            HeavyAttackHelperFrame_Icon1:SetHidden(false)
        elseif position == 2 then
            HeavyAttackHelperFrame_Icon2:SetTexture(texture)
            HeavyAttackHelperFrame_Icon2:SetHidden(false)
        elseif position == 3 then
            HeavyAttackHelperFrame_Icon3:SetTexture(texture)
            HeavyAttackHelperFrame_Icon3:SetHidden(false)
        elseif position == 4 then
            HeavyAttackHelperFrame_Icon4:SetTexture(texture)
            HeavyAttackHelperFrame_Icon4:SetHidden(false)
        elseif position == 5 then
            HeavyAttackHelperFrame_Icon5:SetTexture(texture)
            HeavyAttackHelperFrame_Icon5:SetHidden(false)
        elseif position == 6 then -- ultimate
            HeavyAttackHelperFrame_Icon6:SetTexture(texture)
            HeavyAttackHelperFrame_Icon6:SetHidden(false)
        elseif position == 7 then -- ha status
            HeavyAttackHelperFrame_Icon7:SetTexture(texture)
            HeavyAttackHelperFrame_Icon7:SetHidden(false)
        end
    end
end


function HeavyAttackHelper.adjustFrameLocation()
    -- compatibility

    --local gapWidth = 0
    if IsInGamepadPreferredMode() then -- GAME PAD MODE
        local gapWidth =10

        HeavyAttackHelper.savedVars.arrowWidth=64
        HeavyAttackHelper.savedVars.arrowYOffset=16


        HeavyAttackHelperFrame_Icon1:SetDimensions(HeavyAttackHelper.savedVars.arrowWidth,HeavyAttackHelper.savedVars.arrowWidth)
        HeavyAttackHelperFrame_Icon2:SetDimensions(HeavyAttackHelper.savedVars.arrowWidth,HeavyAttackHelper.savedVars.arrowWidth)
        HeavyAttackHelperFrame_Icon3:SetDimensions(HeavyAttackHelper.savedVars.arrowWidth,HeavyAttackHelper.savedVars.arrowWidth)
        HeavyAttackHelperFrame_Icon4:SetDimensions(HeavyAttackHelper.savedVars.arrowWidth,HeavyAttackHelper.savedVars.arrowWidth)
        HeavyAttackHelperFrame_Icon5:SetDimensions(HeavyAttackHelper.savedVars.arrowWidth,HeavyAttackHelper.savedVars.arrowWidth)
        HeavyAttackHelperFrame_Icon6:SetDimensions(HeavyAttackHelper.savedVars.arrowWidth,HeavyAttackHelper.savedVars.arrowWidth)

        HeavyAttackHelperFrame_Gap1to2:SetDimensions(gapWidth,HeavyAttackHelper.savedVars.arrowWidth)
        HeavyAttackHelperFrame_Gap2to3:SetDimensions(gapWidth,HeavyAttackHelper.savedVars.arrowWidth)
        HeavyAttackHelperFrame_Gap3to4:SetDimensions(gapWidth,HeavyAttackHelper.savedVars.arrowWidth)
        HeavyAttackHelperFrame_Gap4to5:SetDimensions(gapWidth,HeavyAttackHelper.savedVars.arrowWidth)

        if FancyActionBar and HeavyAttackHelper.savedVars.compatibilityDetectFAB then
            HeavyAttackHelperFrame_GapUltimate:SetDimensions(60,HeavyAttackHelper.savedVars.arrowWidth)
        else
            HeavyAttackHelperFrame_GapUltimate:SetDimensions(67,HeavyAttackHelper.savedVars.arrowWidth)
        end

    else  -- KEYBOARD MODE
        local gapWidth =0

        HeavyAttackHelper.savedVars.arrowWidth=52
        HeavyAttackHelper.savedVars.arrowYOffset=0

        HeavyAttackHelperFrame_Gap1to2:SetDimensions(gapWidth,HeavyAttackHelper.savedVars.arrowWidth)
        HeavyAttackHelperFrame_Gap2to3:SetDimensions(gapWidth,HeavyAttackHelper.savedVars.arrowWidth)
        HeavyAttackHelperFrame_Gap3to4:SetDimensions(gapWidth,HeavyAttackHelper.savedVars.arrowWidth)
        HeavyAttackHelperFrame_Gap4to5:SetDimensions(gapWidth,HeavyAttackHelper.savedVars.arrowWidth)

        HeavyAttackHelperFrame_Icon1:SetDimensions(HeavyAttackHelper.savedVars.arrowWidth,HeavyAttackHelper.savedVars.arrowWidth)
        HeavyAttackHelperFrame_Icon2:SetDimensions(HeavyAttackHelper.savedVars.arrowWidth,HeavyAttackHelper.savedVars.arrowWidth)
        HeavyAttackHelperFrame_Icon3:SetDimensions(HeavyAttackHelper.savedVars.arrowWidth,HeavyAttackHelper.savedVars.arrowWidth)
        HeavyAttackHelperFrame_Icon4:SetDimensions(HeavyAttackHelper.savedVars.arrowWidth,HeavyAttackHelper.savedVars.arrowWidth)
        HeavyAttackHelperFrame_Icon5:SetDimensions(HeavyAttackHelper.savedVars.arrowWidth,HeavyAttackHelper.savedVars.arrowWidth)
        HeavyAttackHelperFrame_Icon6:SetDimensions(HeavyAttackHelper.savedVars.arrowWidth,HeavyAttackHelper.savedVars.arrowWidth)

        HeavyAttackHelperFrame_GapUltimate:SetDimensions(10,HeavyAttackHelper.savedVars.arrowWidth)

        if FancyActionBar and HeavyAttackHelper.savedVars.compatibilityDetectFAB then
            HeavyAttackHelperFrame_GapUltimate:SetDimensions(10,HeavyAttackHelper.savedVars.arrowWidth)
        else
            HeavyAttackHelperFrame_GapUltimate:SetDimensions(5+HeavyAttackHelper.savedVars.arrowWidth,HeavyAttackHelper.savedVars.arrowWidth)
        end
    end



    local slot = ZO_ActionBar_GetButton(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX+1).slot

    local yOffset = -HeavyAttackHelper.savedVars.arrowYOffset -- default yOffset
    if FancyActionBar and HeavyAttackHelper.savedVars.compatibilityDetectFAB then

        local activeWeaponPair = GetActiveWeaponPairInfo()

        yOffset=-HeavyAttackHelper.savedVars.arrowWidth*(activeWeaponPair-1)-HeavyAttackHelper.savedVars.arrowYOffset

    end

    --if HeavyAttackHelper.savedVars.arrowWidth>52 then
        --d("Adjusting size to "..HeavyAttackHelper.savedVars.arrowWidth)

    --end


	HeavyAttackHelperFrame:ClearAnchors()
	HeavyAttackHelperFrame:SetAnchor(BOTTOMLEFT, slot, TOPLEFT, 0, yOffset)






    --HeavyAttackHelper.setPos()
    HeavyAttackHelperFrame:SetHidden(true) -- hide GUI
end



function HeavyAttackHelper.UpdateBar()


    if HeavyAttackHelper.heavyEffectHeavyInProgress and HeavyAttackHelper.savedVars.skillTimerBar then
        local time = GetFrameTimeMilliseconds()
        local duration = 1500
        local start = HeavyAttackHelper.heavyEffectStartTime
        local skillRange = 500

        --HeavyAttackHelper.bar.segments[2].progress = (1 - (time - start) / duration)
        --HeavyAttackHelper.bar.segments[1].progress = skillRange / duration
        --HeavyAttackHelper.bar:Update()
        --HeavyAttackHelper.bar:SetHidden(false)
        --d("show bar")

    else
        --HeavyAttackHelper.bar:SetHidden(true)
    end

end





function HeavyAttackHelper.BuildUI()

    -- Create Bar Frame
    --[[
    if not HeavyAttackHelper.frame then
        HeavyAttackHelper.frame = Util.Controls:NewFrame(HeavyAttackHelper.name.."FrameBar")
        HeavyAttackHelper.frame:SetDimensionConstraints(HeavyAttackHelper.MIN_WIDTH, HeavyAttackHelper.MIN_HEIGHT, HeavyAttackHelper.MAX_WIDTH, HeavyAttackHelper.MAX_HEIGHT)
        HeavyAttackHelper.frame:SetHandler("OnMoveStop", function(...)
            HeavyAttackHelper.savedVars.xOffset = math.floor(HeavyAttackHelper.frame:GetLeft())
            HeavyAttackHelper.savedVars.yOffset = math.floor(HeavyAttackHelper.frame:GetTop())
            HeavyAttackHelper.BuildUI()
        end)
        HeavyAttackHelper.frame:SetHandler("OnResizeStop", function(...)
            HeavyAttackHelper.savedVars.width = math.floor(HeavyAttackHelper.frame:GetWidth())
            HeavyAttackHelper.savedVars.height = math.floor(HeavyAttackHelper.frame:GetHeight())
            HeavyAttackHelper.BuildUI()
        end)
    end
    HeavyAttackHelper.frame:SetDimensions(HeavyAttackHelper.savedVars.width, HeavyAttackHelper.savedVars.height)
    HeavyAttackHelper.frame:ClearAnchors()
    HeavyAttackHelper.frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, HeavyAttackHelper.savedVars.xOffset, HeavyAttackHelper.savedVars.yOffset)

    -- Create Timer Bar

    HeavyAttackHelper.bar = HeavyAttackHelper.bar or Util.Bar:New(HeavyAttackHelper.name.."TimerBar", HeavyAttackHelper.frame)
    HeavyAttackHelper.bar.background:SetCenterColor(unpack(HeavyAttackHelper.savedVars.backgroundColour))
    HeavyAttackHelper.bar.background:SetDimensions(HeavyAttackHelper.savedVars.width, HeavyAttackHelper.savedVars.height)
    HeavyAttackHelper.bar.background:ClearAnchors()
    HeavyAttackHelper.bar.background:SetAnchorFill()
    HeavyAttackHelper.bar.align = ((HeavyAttackHelper.savedVars.align == "Left") and LEFT)
                  or ((HeavyAttackHelper.savedVars.align == "Center") and CENTER)
                  or  RIGHT
    HeavyAttackHelper.bar:UpdateSegment(1, {
        colour = HeavyAttackHelper.savedVars.pingColour,
    })
    HeavyAttackHelper.bar:UpdateSegment(2, {
        colour = HeavyAttackHelper.savedVars.progressColour,
        clip = true,
    })
    HeavyAttackHelper.bar:SetHidden(true)

    --]]
end



function HeavyAttackHelper.Init(event, addon)

	if addon ~= HeavyAttackHelper.name then return end

    HeavyAttackHelper.playerName = GetRawUnitName("player")

    HeavyAttackHelper.Skills = {}
    HeavyAttackHelper.SkillUsable = {}
    HeavyAttackHelper.SkillLastUsed = {}

	HeavyAttackHelper.inCombat = IsUnitInCombat("player")

	EM:UnregisterForEvent(HeavyAttackHelper.name.."Load", EVENT_ADD_ON_LOADED)

	HeavyAttackHelper.savedVars = ZO_SavedVars:New(HeavyAttackHelper.name.."SavedVars", HeavyAttackHelper.varVersion, nil, HeavyAttackHelper.defaults)

    --if HeavyAttackHelper.savedVars.accountWide  then
    --    HeavyAttackHelper.accountWidesavedVars = ZO_SavedVars:NewAccountWide(WeaveDelaysVars, HeavyAttackHelper.varVersion, nil, HeavyAttackHelper.defaults)
    --    HeavyAttackHelper.savedVars = HeavyAttackHelper.accountWidesavedVars
    --    HeavyAttackHelper.savedVars.accountWide = true
    --end

    HeavyAttackHelper.BuildUI()
	HeavyAttackHelper.setupMenu()

	EM:RegisterForEvent(HeavyAttackHelper.name.."PassiveHide", EVENT_PLAYER_COMBAT_STATE, HeavyAttackHelper.OnPlayerCombatState)

    EM:RegisterForEvent(HeavyAttackHelper.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, HeavyAttackHelper.EventWeaponSwap)
    EM:RegisterForEvent(HeavyAttackHelper.name, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, HeavyAttackHelper.adjustFrameLocation)


    HeavyAttackHelper.checkIfAddonNeedsToBeLoadedOrUnloaded()

    SLASH_COMMANDS["/ha"] = HeavyAttackHelper.slashCommands

    HeavyAttackHelper.skillPriorityOrder = HeavyAttackHelper.skillPriorityDatabase[GetUnitClassId("player")]

    HeavyAttackHelper.adjustFrameLocation()



end

EM:RegisterForEvent(HeavyAttackHelper.name.."Load", EVENT_ADD_ON_LOADED, HeavyAttackHelper.Init)
