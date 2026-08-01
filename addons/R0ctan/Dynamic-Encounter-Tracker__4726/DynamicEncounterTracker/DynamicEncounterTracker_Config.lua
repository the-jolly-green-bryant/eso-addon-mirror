local DE = DynamicEncounterTracker

-- Encounter-specific data only; the engine has no zone-specific branches.
-- Names and step descriptions are not stored here; ESO supplies them localized.
DE.encountersByZoneId = {
    [41] = {
        {
            key = "stonefalls_bilsa_delivery",
            zoneId = 41,
            parentWorldEventInstanceId = 95,
            knownChildInstanceIds = {
                [106] = true,
                [107] = true,
                [108] = true,
                [109] = true,
                [110] = true,
                [112] = true,
            },
            settingsOrder = 10,
            respawn = {
                earliestSeconds = 30 * 60,
                expectedSeconds = 33 * 60,
            },
            knownStepSequence = { 22, 23, 24, 25, 26, 27, 28, 27, 40, 29, 30 },
            chestRules = {
                stepStarts = {
                    [23] = {
                        id = "zone41-chest-1",
                        chestNumber = 1,
                        requiresParticipationInStep = 22,
                        notificationType = "reward",
                    },
                    [29] = {
                        id = "zone41-chest-2",
                        chestNumber = 2,
                        requiresParticipationInStep = 28,
                        notificationType = "reward",
                    },
                },
                encounterEnd = {
                    id = "zone41-final-chest",
                    chestNumber = 3,
                    requiresParticipationInStep = 30,
                    notificationType = "final",
                },
            },
        },
    },

    [3] = {
        {
            key = "glenumbra_vampire_hunt",
            zoneId = 3,
            parentWorldEventInstanceId = 96,
            knownChildInstanceIds = {
                [99] = true,
                [100] = true,
                [101] = true,
                [102] = true,
                [103] = true,
                [104] = true,
                [105] = true,
            },
            settingsOrder = 20,
            respawn = {
                earliestSeconds = 30 * 60,
                expectedSeconds = (30 * 60) + 11,
            },
            knownStepSequence = { 10, 11, 12, 18, 13, 18, 14, 18, 15, 18, 16, 18, 17 },
            chestRules = {
                stepStarts = {
                    [11] = {
                        id = "zone3-chest-1",
                        chestNumber = 1,
                        requiresPreviousStep = 10,
                        requiresParticipationInStep = 10,
                        notificationType = "reward",
                    },
                    [18] = {
                        id = "zone3-chest-2",
                        chestNumber = 2,
                        requiresPreviousStep = 14,
                        requiresParticipationInStep = 14,
                        notificationType = "reward",
                    },
                },
                encounterEnd = {
                    id = "zone3-final-chest",
                    chestNumber = 3,
                    requiresParticipationInStep = 17,
                    notificationType = "final",
                },
            },
        },
    },

    [381] = {
        {
            key = "auridon_flower_vine_court",
            zoneId = 381,
            parentWorldEventInstanceId = 98,
            knownChildInstanceIds = {
                [131] = true,
            },
            settingsOrder = 30,
            respawn = {
                earliestSeconds = 30 * 60,
                expectedSeconds = (31 * 60) + 2,
            },
            knownStepSequence = { 31, 32, 33, 34, 35 },
            chestRules = {
                stepStarts = {
                    [33] = {
                        id = "zone381-chest-1",
                        chestNumber = 1,
                        requiresParticipationInStep = 32,
                        notificationType = "reward",
                    },
                },
                encounterEnd = {
                    id = "zone381-final-chest",
                    chestNumber = 2,
                    requiresParticipationInStep = 35,
                    notificationType = "final",
                },
            },
        },
    },
}
