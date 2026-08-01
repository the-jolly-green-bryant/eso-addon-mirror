--[[
"|ce46b2e" -- Red
"|c59bae7" -- Blue
"|ca5d752" -- Green
    [""] = {
        description = "",
        rules = {
            ["House Green Decon"] = {
                ["dps"] = true,
                ["healer"] = true,
                ["name"] = "House Green Decon",
                ["normal"] = true,
                ["param1"] = "",
                ["param2"] = "",
                ["priority"] = 0,
                ["reeval"] = false,
                ["tank"] = true,
                ["trigger"] = "Player House",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = -1,
                    [2] = 66, -- Steed's Blessing
                    [3] = 86, -- Liquid Efficiency
                    [4] = 83, -- Meticulous Disassembly
                    [5] = -1,
                    [6] = -1,
                    [7] = -1,
                    [8] = -1,
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = -1,
                    ["Red"] = "DPS Rez",
                },
            },
        },
    },
]]

-- [name of group to display] = {description = desc, rules = {}}
DynamicCP.exampleRules = {
    ["Zoooomies"] = {
        description = "A single rule that slots \n\n|ca5d752Steed's Blessing|r whenever entering a zone.",
        rules = {
            ["Zoooomies"] = {
                ["dps"] = true,
                ["healer"] = true,
                ["name"] = "Zoooomies",
                ["normal"] = true,
                ["param1"] = "*",
                ["param2"] = "",
                ["priority"] = 0,
                ["reeval"] = false,
                ["tank"] = true,
                ["trigger"] = "Specific Zone ID",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = 66, -- Steed's Blessing
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = -1,
                    [6] = -1,
                    [7] = -1,
                    [8] = -1,
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = -1,
                },
            },
        },
    },
    ["Trial"] = {
        description = "A set of rules that slots:\n\n|ce46b2eBoundless Vitality|r, |ce46b2eFortified|r, and |ce46b2eRejuvenation|r on all roles;\n\n|ce46b2eSpirit Mastery|r, |c59bae7Exploiter|r, |c59bae7Wrathful Strikes|r, |c59bae7Biting Aura|r, and |c59bae7Master-at-Arms|r on dps;\n\n|ce46b2eCelerity|r, |c59bae7Duelist's Rebuff|r, |c59bae7Enduring Resolve|r, |c59bae7Unassailable|r, and |c59bae7Bulwark|r on tank;\n\n|ce46b2eSlippery|r, |c59bae7Soothing Tide|r, |c59bae7Swift Renewal|r, |c59bae7Enlivening Overflow|r, and |c59bae7From the Brink|r on healer;\n\nwhen you enter a trial.",
        rules = {
            ["Trial Red"] = {
                ["dps"] = true,
                ["healer"] = true,
                ["name"] = "Trial Red",
                ["normal"] = true,
                ["param1"] = "",
                ["param2"] = "",
                ["priority"] = 100,
                ["reeval"] = false,
                ["tank"] = true,
                ["trigger"] = "Trial",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = -1,
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = -1,
                    [6] = -1,
                    [7] = -1,
                    [8] = -1,
                    [9] = 2, -- Boundless Vitality
                    [10] = 34, -- Fortified
                    [11] = 35, -- Rejuvenation
                    [12] = -1,
                },
            },
            ["Trial Dps / Rezzer"] = {
                ["dps"] = true,
                ["healer"] = false,
                ["name"] = "Trial Dps / Rezzer",
                ["normal"] = true,
                ["param1"] = "",
                ["param2"] = "",
                ["priority"] = 110,
                ["reeval"] = false,
                ["tank"] = false,
                ["trigger"] = "Trial",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = -1,
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = 277, -- Exploiter
                    [6] = 8, -- Wrathful Strikes
                    [7] = 23, -- Biting Aura
                    [8] = 264, -- Master-at-Arms
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = 56, -- Spirit Mastery
                },
            },
            ["Trial Tank Blue / Celerity"] = {
                ["dps"] = false,
                ["healer"] = false,
                ["name"] = "Trial Tank Blue / Celerity",
                ["normal"] = true,
                ["param1"] = "",
                ["param2"] = "",
                ["priority"] = 110,
                ["reeval"] = false,
                ["tank"] = true,
                ["trigger"] = "Trial",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = -1,
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = 134, -- Duelist's Rebuff
                    [6] = 136, -- Enduring Resolve
                    [7] = 133, -- Unassailable
                    [8] = 159, -- Bulwark
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = 270, -- Celerity
                },
            },
            ["Trial Healer Blue / Slippery"] = {
                ["dps"] = false,
                ["healer"] = true,
                ["name"] = "Trial Healer Blue / Slippery",
                ["normal"] = true,
                ["param1"] = "",
                ["param2"] = "",
                ["priority"] = 110,
                ["reeval"] = false,
                ["tank"] = false,
                ["trigger"] = "Trial",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = -1,
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = 24, -- Soothing Tide
                    [6] = 28, -- Swift Renewal
                    [7] = 263,-- Enlivening Overflow
                    [8] = 262, -- From the Brink
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = 52, -- Slippery
                },
            },
        },
    },
    ["Dungeon / Group Arena"] = {
        description = "A set of rules that slots:\n\n|ca5d752Steed's Blessing|r, |ce46b2eBoundless Vitality|r, |ce46b2eFortified|r, and |ce46b2eRejuvenation|r on all roles;\n\n|ce46b2eBloody Renewal / Siphoning Spells|r, |c59bae7Backstabber|r, |c59bae7Fighting Finesse|r, |c59bae7Biting Aura|r, and |c59bae7Master-at-Arms|r on dps;\n\n|ce46b2eCelerity|r, |c59bae7Duelist's Rebuff|r, |c59bae7Enduring Resolve|r, |c59bae7Unassailable|r, and |c59bae7Bulwark|r on tank;\n\n|ce46b2eExpert Evasion|r, |c59bae7Soothing Tide|r, |c59bae7Swift Renewal|r, |c59bae7Enlivening Overflow|r, and |c59bae7From the Brink|r on healer;\n\nwhen you enter a group dungeon or group arena.",
        rules = {
            ["Dungeon Green / Red"] = {
                ["dps"] = true,
                ["healer"] = true,
                ["name"] = "Dungeon Green / Red",
                ["normal"] = true,
                ["param1"] = "",
                ["param2"] = "",
                ["priority"] = 300,
                ["reeval"] = false,
                ["tank"] = true,
                ["trigger"] = "Group Dungeon",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = 66, -- Steed's Blessing
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = -1,
                    [6] = -1,
                    [7] = -1,
                    [8] = -1,
                    [9] = 2, -- Boundless Vitality
                    [10] = 34, -- Fortified
                    [11] = 35, -- Rejuvenation
                    [12] = -1,
                },
            },
            ["Dungeon Dps Stab AOE / Sustain"] = {
                ["dps"] = true,
                ["healer"] = false,
                ["name"] = "Dungeon Dps Stab AOE / Sustain",
                ["normal"] = true,
                ["param1"] = "",
                ["param2"] = "",
                ["priority"] = 310,
                ["reeval"] = false,
                ["tank"] = false,
                ["trigger"] = "Group Dungeon",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = -1,
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = 31, -- Backstabber
                    [6] = 12, -- Fighting Finesse
                    [7] = 23, -- Biting Aura
                    [8] = 264, -- Master-at-Arms
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = 48, -- Bloody Renewal
                },
            },
            ["Dungeon Tank Blue / Celerity"] = {
                ["dps"] = false,
                ["healer"] = false,
                ["name"] = "Dungeon Tank Blue / Celerity",
                ["normal"] = true,
                ["param1"] = "",
                ["param2"] = "",
                ["priority"] = 310,
                ["reeval"] = false,
                ["tank"] = true,
                ["trigger"] = "Group Dungeon",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = -1,
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = 134, -- Duelist's Rebuff
                    [6] = 136, -- Enduring Resolve
                    [7] = 133, -- Unassailable
                    [8] = 159, -- Bulwark
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = 270, -- Celerity
                },
            },
            ["Dungeon Healer Blue / Dodge"] = {
                ["dps"] = false,
                ["healer"] = true,
                ["name"] = "Dungeon Healer Blue / Dodge",
                ["normal"] = true,
                ["param1"] = "",
                ["param2"] = "",
                ["priority"] = 310,
                ["reeval"] = false,
                ["tank"] = false,
                ["trigger"] = "Group Dungeon",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = -1,
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = 24, -- Soothing Tide
                    [6] = 28, -- Swift Renewal
                    [7] = 263,-- Enlivening Overflow
                    [8] = 262, -- From the Brink
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = 51, -- Expert Evasion
                },
            },
            ["Arena Green / Red"] = {
                ["dps"] = true,
                ["healer"] = true,
                ["name"] = "Arena Green / Red",
                ["normal"] = true,
                ["param1"] = "",
                ["param2"] = "",
                ["priority"] = 400,
                ["reeval"] = false,
                ["tank"] = true,
                ["trigger"] = "Group Arena",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = 66, -- Steed's Blessing
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = -1,
                    [6] = -1,
                    [7] = -1,
                    [8] = -1,
                    [9] = 2, -- Boundless Vitality
                    [10] = 34, -- Fortified
                    [11] = 35, -- Rejuvenation
                    [12] = -1,
                },
            },
            ["Arena Dps Stab AOE / Sustain"] = {
                ["dps"] = true,
                ["healer"] = false,
                ["name"] = "Arena Dps Stab AOE / Sustain",
                ["normal"] = true,
                ["param1"] = "",
                ["param2"] = "",
                ["priority"] = 410,
                ["reeval"] = false,
                ["tank"] = false,
                ["trigger"] = "Group Arena",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = -1,
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = 31, -- Backstabber
                    [6] = 12, -- Fighting Finesse
                    [7] = 23, -- Biting Aura
                    [8] = 264, -- Master-at-Arms
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = 48, -- Bloody Renewal
                },
            },
            ["Arena Tank Blue / Celerity"] = {
                ["dps"] = false,
                ["healer"] = false,
                ["name"] = "Arena Tank Blue / Celerity",
                ["normal"] = true,
                ["param1"] = "",
                ["param2"] = "",
                ["priority"] = 410,
                ["reeval"] = false,
                ["tank"] = true,
                ["trigger"] = "Group Arena",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = -1,
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = 134, -- Duelist's Rebuff
                    [6] = 136, -- Enduring Resolve
                    [7] = 133, -- Unassailable
                    [8] = 159, -- Bulwark
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = 270, -- Celerity
                },
            },
            ["Arena Healer Blue / Slippery"] = {
                ["dps"] = false,
                ["healer"] = true,
                ["name"] = "Arena Healer Blue / Slippery",
                ["normal"] = true,
                ["param1"] = "",
                ["param2"] = "",
                ["priority"] = 410,
                ["reeval"] = false,
                ["tank"] = false,
                ["trigger"] = "Group Arena",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = -1,
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = 24, -- Soothing Tide
                    [6] = 28, -- Swift Renewal
                    [7] = 263,-- Enlivening Overflow
                    [8] = 262, -- From the Brink
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = 51, -- Expert Evasion
                },
            },
        },
    },
    ["Solo Arena"] = {
        description = "A single rule that slots:\n\n|ca5d752Steed's Blessing|r, |ca5d752Professional Upkeep|r, |ce46b2eBoundless Vitality|r, |ce46b2eFortified|r, |ce46b2eRejuvenation|r, |ce46b2eBloody Renewal / Siphoning Spells|r, |c59bae7Deadly Aim|r, |c59bae7Fighting Finesse|r, |c59bae7Biting Aura|r, and |c59bae7Master-at-Arms|r\n\nwhen you enter a solo arena.",
        rules = {
            ["Solo Arena Green / Red / NonStab"] = {
                ["dps"] = true,
                ["healer"] = true,
                ["name"] = "Solo Arena Green / Red / NonStab",
                ["normal"] = true,
                ["param1"] = "",
                ["param2"] = "",
                ["priority"] = 200,
                ["reeval"] = false,
                ["tank"] = true,
                ["trigger"] = "Solo Arena",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = 66, -- Steed's Blessing
                    [2] = 1, -- Professional Upkeep
                    [3] = -1,
                    [4] = -1,
                    [5] = 25, -- Deadly Aim
                    [6] = 12, -- Fighting Finesse
                    [7] = 23, -- Biting Aura
                    [8] = 264, -- Master-at-Arms
                    [9] = 2, -- Boundless Vitality
                    [10] = 34, -- Fortified
                    [11] = 35, -- Rejuvenation
                    [12] = 48, -- Bloody Renewal
                },
            },
        },
    },
    ["Overland"] = {
        description = "A set of rules that slots:\n\n|ca5d752Steed's Blessing|r, |ca5d752Gifted Rider|r, |ca5d752Master Gatherer|r, |ca5d752War Mount|r, and |ce46b2eCelerity|r on all roles;\n\n|c59bae7Deadly Aim|r, |c59bae7Fighting Finesse|r, |c59bae7Biting Aura|r, and |c59bae7Master-at-Arms|r on dps;\n\nwhen you enter an overland zone.",
        rules = {
            ["Instance Green / Red"] = {
                ["dps"] = true,
                ["healer"] = true,
                ["name"] = "Instance Green / Red",
                ["normal"] = true,
                ["param1"] = "",
                ["param2"] = "",
                ["priority"] = 640,
                ["reeval"] = false,
                ["tank"] = true,
                ["trigger"] = "Group Instance **",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = 66, -- Steed's Blessing
                    [2] = 92, -- Gifted Rider
                    [3] = 78, -- Master Gatherer
                    [4] = 82, -- War Mount
                    [5] = -1,
                    [6] = -1,
                    [7] = -1,
                    [8] = -1,
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = 270, -- Celerity
                },
            },
            ["Instance Dps NonStab"] = {
                ["dps"] = true,
                ["healer"] = false,
                ["name"] = "Instance Dps NonStab",
                ["normal"] = true,
                ["param1"] = "",
                ["param2"] = "",
                ["priority"] = 650,
                ["reeval"] = false,
                ["tank"] = false,
                ["trigger"] = "Group Instance **",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = -1,
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = 25, -- Deadly Aim
                    [6] = 12, -- Fighting Finesse
                    [7] = 23, -- Biting Aura
                    [8] = 264, -- Master-at-Arms
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = -1,
                },
            },
            ["Overland Green / Red"] = {
                ["dps"] = true,
                ["healer"] = true,
                ["name"] = "Overland Green / Red",
                ["normal"] = true,
                ["param1"] = "",
                ["param2"] = "",
                ["priority"] = 600,
                ["reeval"] = false,
                ["tank"] = true,
                ["trigger"] = "Overland",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = 66, -- Steed's Blessing
                    [2] = 92, -- Gifted Rider
                    [3] = 78, -- Master Gatherer
                    [4] = -1,
                    [5] = -1,
                    [6] = -1,
                    [7] = -1,
                    [8] = -1,
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = 270, -- Celerity
                },
            },
            ["Public / Delve Dps NonStab"] = {
                ["dps"] = true,
                ["healer"] = false,
                ["name"] = "Public / Delve Dps NonStab",
                ["normal"] = true,
                ["param1"] = "",
                ["param2"] = "",
                ["priority"] = 630,
                ["reeval"] = false,
                ["tank"] = false,
                ["trigger"] = "Public Instance *",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = -1,
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = 25, -- Deadly Aim
                    [6] = 12, -- Fighting Finesse
                    [7] = 23, -- Biting Aura
                    [8] = 264, -- Master-at-Arms
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = -1,
                },
            },
            ["Public / Delve Green / Red"] = {
                ["dps"] = true,
                ["healer"] = true,
                ["name"] = "Public / Delve Green",
                ["normal"] = true,
                ["param1"] = "",
                ["param2"] = "",
                ["priority"] = 620,
                ["reeval"] = false,
                ["tank"] = true,
                ["trigger"] = "Public Instance *",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = 66, -- Steed's Blessing
                    [2] = 92, -- Gifted Rider
                    [3] = 78, -- Master Gatherer
                    [4] = -1,
                    [5] = -1,
                    [6] = -1,
                    [7] = -1,
                    [8] = -1,
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = 270, -- Celerity
                },
            },
            ["Overland Dps NonStab"] = {
                ["dps"] = true,
                ["healer"] = false,
                ["name"] = "Overland Dps NonStab",
                ["normal"] = true,
                ["param1"] = "",
                ["param2"] = "",
                ["priority"] = 610,
                ["reeval"] = false,
                ["tank"] = false,
                ["trigger"] = "Overland",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = -1,
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = 25, -- Deadly Aim
                    [6] = 12, -- Fighting Finesse
                    [7] = 23, -- Biting Aura
                    [8] = 264, -- Master-at-Arms
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = -1,
                },
            },
        },
    },
    ["PVP"] = {
        description = "A set of rules that slots:\n\n|ca5d752Steed's Blessing|r, |ca5d752Gifted Rider|r, |ca5d752Sustaining Shadows|r, and |ca5d752War Mount|r on all roles;\n\n|ce46b2eBoundless Vitality|r, |ce46b2eJuggernaut|r, |ce46b2eRejuvenation|r, |ce46b2eStrategic Reserve|r, |c59bae7Backstabber|r, |c59bae7Fighting Finesse|r, |c59bae7Deadly Aim|r, and |c59bae7Resilience|r on dps;\n\nwhen you enter Cyrodiil or Imperial City / Sewers.",
        rules = {
            ["IC Dps Red / Blue"] = {
                ["dps"] = true,
                ["healer"] = false,
                ["name"] = "IC Dps Red / Blue",
                ["normal"] = true,
                ["param1"] = "",
                ["param2"] = "",
                ["priority"] = 730,
                ["reeval"] = false,
                ["tank"] = false,
                ["trigger"] = "Imperial City",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = -1,
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = 31, -- Backstabber
                    [6] = 12, -- Fighting Finesse
                    [7] = 25, -- Deadly Aim
                    [8] = 13, -- Resilience
                    [9] = 2, -- Boundless Vitality
                    [10] = 59, -- Juggernaut
                    [11] = 35, -- Rejuvenation
                    [12] = 49, -- Strategic Reserve
                },
            },
            ["Cyro Dps Red / Blue"] = {
                ["dps"] = true,
                ["healer"] = false,
                ["name"] = "Cyro Dps Red / Blue",
                ["normal"] = true,
                ["param1"] = "",
                ["param2"] = "",
                ["priority"] = 710,
                ["reeval"] = false,
                ["tank"] = false,
                ["trigger"] = "Cyrodiil",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = -1,
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = 31, -- Backstabber
                    [6] = 12, -- Fighting Finesse
                    [7] = 25, -- Deadly Aim
                    [8] = 13, -- Resilience
                    [9] = 2, -- Boundless Vitality
                    [10] = 59, -- Juggernaut
                    [11] = 35, -- Rejuvenation
                    [12] = 49, -- Strategic Reserve
                },
            },
            ["IC Green"] = {
                ["dps"] = true,
                ["healer"] = true,
                ["name"] = "IC Green",
                ["normal"] = true,
                ["param1"] = "",
                ["param2"] = "",
                ["priority"] = 720,
                ["reeval"] = false,
                ["tank"] = true,
                ["trigger"] = "Imperial City",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = 66, -- Steed's Blessing
                    [2] = 92, -- Gifted Rider
                    [3] = 65, -- Sustaining Shadows
                    [4] = 82, -- War Mount
                    [5] = -1,
                    [6] = -1,
                    [7] = -1,
                    [8] = -1,
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = -1,
                },
            },
            ["Cyro Green"] = {
                ["dps"] = true,
                ["healer"] = true,
                ["name"] = "Cyro Green",
                ["normal"] = true,
                ["param1"] = "",
                ["param2"] = "",
                ["priority"] = 700,
                ["reeval"] = false,
                ["tank"] = true,
                ["trigger"] = "Cyrodiil",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = 66, -- Steed's Blessing
                    [2] = 92, -- Gifted Rider
                    [3] = 65, -- Sustaining Shadows
                    [4] = 82, -- War Mount
                    [5] = -1,
                    [6] = -1,
                    [7] = -1,
                    [8] = -1,
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = -1,
                },
            },
        },
    },
}

DynamicCP.exampleBossRules = {
    ["Maelstrom Arena"] = {
        description = "Backstabber is viable on some bosses in Maelstrom Arena, especially if you use mechanics to stun the bosses. This set of rules will slot |c59bae7Backstabber|r instead of |c59bae7Deadly Aim|r when you encounter The Control Guardian (arena 4), Champion of Atrocity (arena 6), and Voriak Solkyn (arena 9). Upon death of the bosses, your solo arena rules will be restored.",
        rules = {
            ["vMA ReEval NonStab"] = {
                ["dps"] = true,
                ["healer"] = true,
                ["name"] = "vMA ReEval NonStab",
                ["normal"] = true,
                ["param1"] = "The Control Guardian%Champion of Atrocity",
                ["param2"] = "",
                ["priority"] = 941,
                ["reeval"] = true,
                ["tank"] = true,
                ["trigger"] = "Specific Boss Death",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = -1,
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = -1,
                    [6] = -1,
                    [7] = -1,
                    [8] = -1,
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = -1,
                },
            },
            ["vMA Boss Stab AOE"] = {
                ["dps"] = true,
                ["healer"] = true,
                ["name"] = "vMA Boss Stab AOE",
                ["normal"] = true,
                ["param1"] = "Voriak Solkyn%The Control Guardian%Champion of Atrocity",
                ["param2"] = "",
                ["priority"] = 940,
                ["reeval"] = false,
                ["tank"] = true,
                ["trigger"] = "Specific Boss Name",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = -1,
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = 31, -- Backstabber
                    [6] = 12, -- Fighting Finesse
                    [7] = 23, -- Biting Aura
                    [8] = 264, -- Master-at-Arms
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = -1,
                },
            },
        },
    },
    ["Scalecaller Peak"] = {
        description = "Breaking free prematurely due to |ce46b2eSlippery|r in some Scalecaller Peak mechanics can result in death. Since I sometimes run |ce46b2eSlippery|r on a healer, I make sure I have |ce46b2eExpert Evasion|r in Scalecaller Peak instead.",
        rules = {
            ["SCP Healer Dodge"] = {
                ["dps"] = false,
                ["healer"] = true,
                ["name"] = "SCP Healer Dodge",
                ["normal"] = true,
                ["param1"] = "1010",
                ["param2"] = "",
                ["priority"] = 800,
                ["reeval"] = false,
                ["tank"] = false,
                ["trigger"] = "Specific Zone ID",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = -1,
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = -1,
                    [6] = -1,
                    [7] = -1,
                    [8] = -1,
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = 51, -- Expert Evasion
                },
            },
        },
    },
    ["Asylum Sanctorium"] = {
        description = "There's not much that stuns you in Asylum Sanctorium. Since I typically run |ce46b2eSlippery|r on a healer, I opt for |ce46b2eBastion|r in Asylum instead.",
        rules = {
            ["AS Healer Bastion"] = {
                ["dps"] = false,
                ["healer"] = true,
                ["name"] = "AS Healer Bastion",
                ["normal"] = true,
                ["param1"] = "1000",
                ["param2"] = "",
                ["priority"] = 800,
                ["reeval"] = false,
                ["tank"] = false,
                ["trigger"] = "Specific Zone ID",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = -1,
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = -1,
                    [6] = -1,
                    [7] = -1,
                    [8] = -1,
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = 46, -- Bastion
                },
            },
        },
    },
    ["Rockgrove"] = {
        description = "As a DPS, slots |ce46b2eBastion|r instead of my usual |ce46b2eRejuvenation|r slot at Xalvakka, since it increases the damage done against her shells.",
        rules = {
            ["Xalvakka Bastion"] = {
                ["dps"] = true,
                ["healer"] = false,
                ["name"] = "Xalvakka Bastion",
                ["normal"] = true,
                ["param1"] = "Xalvakka",
                ["param2"] = "",
                ["priority"] = 800,
                ["reeval"] = false,
                ["tank"] = false,
                ["trigger"] = "Specific Boss Name",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = -1,
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = -1,
                    [6] = -1,
                    [7] = -1,
                    [8] = -1,
                    [9] = 2, -- Boundless Vitality
                    [10] = 34, -- Fortified
                    [11] = 46, -- Bastion
                    [12] = 56, -- Spirit Mastery
                },
            },
        },
    },
    ["Infinite Archive"] = {
        description = "For Infinite Archive, I use tankier CPs:\n|c59bae7Duelist's Rebuff|r, |c59bae7Enduring Resolve|r, |c59bae7Unassailable|r, and |c59bae7Thaumaturge|r\n\nIn the side room for Aramril's duel, I slot damage CPs:\n|c59bae7Deadly Aim|r, |c59bae7Fighting Finesse|r, |c59bae7Biting Aura|r, and |c59bae7Master-at-Arms|r.",
        rules = {
            ["IA Tanky"] = {
                ["dps"] = true,
                ["healer"] = true,
                ["name"] = "IA Tanky",
                ["normal"] = true,
                ["param1"] = "1000",
                ["param2"] = "",
                ["priority"] = 420,
                ["reeval"] = false,
                ["tank"] = false,
                ["trigger"] = "Specific Zone ID",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = -1,
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = 134, -- Duelist's Rebuff
                    [6] = 136, -- Enduring Resolve
                    [7] = 133, -- Unassailable
                    [8] = 27, -- Thaumaturge
                    [9] = 2, -- Boundless Vitality
                    [10] = 34, -- Fortified
                    [11] = 35, -- Rejuvenation
                    [12] = 48, -- Bloody Renewal
                },
            },
            ["IA Aramril"] = {
                ["dps"] = true,
                ["healer"] = true,
                ["name"] = "IA Aramril",
                ["normal"] = true,
                ["param1"] = "2424",
                ["param2"] = "",
                ["priority"] = 421,
                ["reeval"] = false,
                ["tank"] = true,
                ["trigger"] = "Specific Map ID",
                ["veteran"] = true,
                ["stars"] = {
                    [1] = -1,
                    [2] = -1,
                    [3] = -1,
                    [4] = -1,
                    [5] = 25, -- Deadly Aim
                    [6] = 12, -- Fighting Finesse
                    [7] = 23, -- Biting Aura
                    [8] = 264, -- Master-at-Arms
                    [9] = -1,
                    [10] = -1,
                    [11] = -1,
                    [12] = -1,
                },
            },
        },
    },
}
