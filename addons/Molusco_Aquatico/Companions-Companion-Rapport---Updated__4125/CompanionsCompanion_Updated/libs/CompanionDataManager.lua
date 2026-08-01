----------------------------------
-- Companion Rapport Information
---------------------------------

---Table containing all the compaion rapport information
local CC_COMPANION_DATA = {
    [9245] = { -- Bastian Hallix
        good = {
            {
                text = CC_SHARED_COMPLETE_PERSONAL_QUEST,
                time = CC_SHARED_BASTIAN_MIRRI,
                rapport = 500,
            },
            {
                text = CC_SHARED_COMPLETE_MAGES_DAILY,
                time = CC_24_HOURS,
                rapport = 125,
            },
            {
                text = CC_GOOD_BASTIAN_TEXT_2,
                time = CC_20_HOURS,
                rapport = 10,
            },
            {
                text = CC_GOOD_BASTIAN_TEXT_3,
                time = CC_20_HOURS,
                rapport = 10,
            },
            {
                text = CC_GOOD_BASTIAN_TEXT_4,
                time = CC_UNKNOWN_TIME,
                rapport = 10,
            },
            {
                text = CC_GOOD_BASTIAN_TEXT_8,
                time = CC_15_MINUTES,
                rapport = 5,
            },
            {
                text = CC_GOOD_BASTIAN_TEXT_9,
                time = CC_10_MINUTES,
                rapport = 5,
            },
            {
                text = CC_SHARED_LOOTING_PSIJIC_PORTAL,
                time = CC_5_MINUTES,
                rapport = 5,
            },
            {
                text = CC_GOOD_BASTIAN_TEXT_6,
                time = CC_5_MINUTES,
                rapport = 5,
            },
            {
                text = CC_GOOD_BASTIAN_TEXT_12,
                time = CC_1_MINUTE,
                rapport = 5,
            },
            {
                text = CC_GOOD_BASTIAN_TEXT_10,
                time = CC_1_MINUTE,
                rapport = 5,
            },
            {
                text = CC_GOOD_BASTIAN_TEXT_7,
                time = CC_5_MINUTES,
                rapport = 1,
            }
        },
        bad  = {
            {
                text = CC_SHARED_MURDER,
                time = {
                    CC_OFF_COOLDOWN,
                    CC_DURING_COOLDOWN,
                },
                rapport = {
                    25,
                    1
                },
            },
            {
                text = CC_BAD_BASTIAN_TEXT_9,
                time = {
                    CC_5_MINUTES,
                    CC_DURING_COOLDOWN,
                },
                rapport = {
                    10,
                    1,
                },
            },
            {
                text = CC_BAD_BASTIAN_TEXT_1,
                time = CC_UNKNOWN_TIME,
                rapport = 10
            },
            {
                text = CC_BAD_BASTIAN_TEXT_3,
                time = CC_UNKNOWN_TIME,
                rapport = 5,
            },
            {
                text = CC_BAD_BASTIAN_TEXT_6,
                time = CC_UNKNOWN_TIME,
                rapport = 5,
            },
            {
                text = CC_BAD_BASTIAN_TEXT_5,
                time = CC_UNKNOWN_TIME,
                rapport = 5,
            },
            {
                text = CC_BAD_BASTIAN_TEXT_7,
                time = CC_UNKNOWN_TIME,
                rapport = 1,
            },
            {
                text = CC_BAD_BASTIAN_TEXT_8,
                time = CC_UNKNOWN_TIME,
                rapport = 1,
            },
        }
    },
    [9353] = { -- Mirri Elendis
        good = {
            {
                text = CC_SHARED_COMPLETE_PERSONAL_QUEST,
                time = CC_SHARED_BASTIAN_MIRRI,
                rapport = 500,
            },
            {
                text = CC_GOOD_MIRRI_TEXT_2,
                time = CC_24_HOURS,
                rapport = 125,
            },
            {
                text = CC_GOOD_MIRRI_TEXT_1,
                time = CC_24_HOURS,
                rapport = 125,
            },
            {
                text = CC_GOOD_MIRRI_TEXT_3,
                time = {
                    CC_FIRST_TIME,
                    CC_20_HOURS
                },
                rapport = {
                    75,
                    5
                },
            },
            {
                text = CC_GOOD_MIRRI_TEXT_4,
                time = {
                    CC_FIRST_TIME,
                    CC_20_HOURS,
                },
                rapport = {
                    75,
                    5,
                },
            },
            {
                text = CC_GOOD_MIRRI_TEXT_9,
                time = {
                    CC_FIRST_TIME,
                    CC_20_HOURS,
                },
                rapport = {
                    75,
                    5,
                },
            },
            {
                text = CC_GOOD_MIRRI_TEXT_10,
                time = {
                    CC_FIRST_TIME,
                    CC_20_HOURS,
                },
                rapport = {
                    75,
                    5,
                },
            },
            {
                text = CC_GOOD_MIRRI_TEXT_11,
                time = {
                    CC_FIRST_TIME,
                    CC_20_HOURS,
                },
                rapport = {
                    75,
                    5,
                },
            },
            {
                text = CC_GOOD_MIRRI_TEXT_12,
                time = {
                    CC_FIRST_TIME,
                    CC_20_HOURS,
                },
                rapport = {
                    75,
                    5,
                },
            },
            {
                text = CC_GOOD_MIRRI_TEXT_6,
                time = CC_24_HOURS,
                rapport = 10,
            },
            {
                text = CC_GOOD_MIRRI_TEXT_5,
                time = CC_30_MINUTES,
                rapport = 10,
            },
            {
                text = CC_GOOD_MIRRI_TEXT_19,
                time = {
                    CC_1_HOUR,
                    CC_DURING_COOLDOWN
                },
                rapport = {
                    10,
                    1
                },
            },
            {
                text = CC_GOOD_MIRRI_TEXT_8,
                time = CC_UNKNOWN_TIME,
                rapport = 10,
            },
            {
                text = CC_GOOD_MIRRI_TEXT_7,
                time = CC_5_MINUTES,
                rapport = 5,
            },
            {
                text = CC_GOOD_MIRRI_TEXT_14,
                time = CC_5_MINUTES,
                rapport = 1,
            },
            {
                text = CC_GOOD_MIRRI_TEXT_20,
                time = CC_5_MINUTES,
                rapport = 1,
            },
            {
                text = CC_GOOD_MIRRI_TEXT_15,
                time = CC_3_MINUTES,
                rapport = 1,
            },
            {
                text = CC_GOOD_MIRRI_TEXT_16,
                time = CC_5_MINUTES,
                rapport = 1,
            },
            {
                text = CC_GOOD_MIRRI_TEXT_17,
                time = CC_UNKNOWN_TIME,
                rapport = 1,
            },
            {
                text = CC_GOOD_MIRRI_TEXT_18,
                time = CC_UNKNOWN_TIME,
                rapport = 1,
            },
        },
        bad  = {
            {
                text = CC_SHARED_USE_BLADE_OF_WOE_NPC,
                time = {
                    CC_5_MINUTES,
                    CC_DURING_COOLDOWN,
                },
                rapport = {
                    25,
                    5
                },
            },
            {
                text = CC_BAD_MIRRI_TEXT_1,
                time = CC_UNKNOWN_TIME,
                rapport = 25,
            },
            {
                text = CC_SHARED_DARK_BROTHERHOOD,
                time = CC_UNKNOWN_TIME,
                rapport = 10,
            },
            {
                text = CC_BAD_MIRRI_TEXT_2,
                time = CC_5_MINUTES,
                rapport = 1,
            },

        }
    },
    [9911] = { -- Ember
        good = {
            {
                text = CC_SHARED_COMPLETE_PERSONAL_QUEST,
                time = CC_SHARED_PERSONAL_QUEST_RAPPORT,
                rapport = 500,
            },
            {
                text = CC_SHARED_COMPLETE_MAGES_DAILY,
                time = CC_24_HOURS,
                rapport = 125,
            },
            {
                text = CC_GOOD_EMBER_TEXT_1,
                time = CC_24_HOURS,
                rapport = 125,
            },
            {
                text = CC_GOOD_EMBER_TEXT_2,
                time = CC_24_HOURS,
                rapport = 125,
            },
            {
                text = CC_GOOD_EMBER_TEXT_3,
                time = {
                    CC_24_HOURS,
                    CC_DURING_COOLDOWN
                },
                rapport = {
                    25,
                    5,
                },
            },
            {
                text = CC_GOOD_EMBER_TEXT_5,
                time = CC_24_HOURS,
                rapport = 10,
            },
            {
                text = CC_GOOD_EMBER_TEXT_6,
                time = {
                    CC_1_HOUR,
                    CC_DURING_COOLDOWN,
                },
                rapport = {
                    10,
                    1,
                },
            },
            {
                text = CC_SHARED_PICKPOCKET_GUARD,
                time = {
                    CC_1_HOUR,
                    CC_DURING_COOLDOWN,
                },
                rapport = {
                    10,
                    1,
                },
            },
            {
                text = CC_GOOD_EMBER_TEXT_4,
                time = {
                    CC_24_HOURS,
                    CC_DURING_COOLDOWN,
                },
                rapport = {
                    10,
                    1,
                },
            },
            {
                text = CC_GOOD_EMBER_TEXT_9,
                time = CC_1_HOUR,
                rapport = 5,
            },
            {
                text = CC_GOOD_EMBER_TEXT_10,
                time = CC_UNKNOWN_TIME,
                rapport = 5,
            },
            {
                text = CC_GOOD_EMBER_TEXT_8,
                time = {
                    CC_1_HOUR,
                    CC_DURING_COOLDOWN,
                },
                rapport = {
                    5,
                    1,
                },
            },
            {
                text = CC_GOOD_EMBER_TEXT_17,
                time = CC_24_HOURS,
                rapport = 1,
            },
            {
                text = CC_GOOD_EMBER_TEXT_18,
                time = CC_24_HOURS,
                rapport = 1,
            },
            {
                text = CC_GOOD_EMBER_TEXT_16,
                time = CC_1_HOUR,
                rapport = 1,
            },
            {
                text = CC_GOOD_EMBER_TEXT_11,
                time = CC_5_MINUTES,
                rapport = 1,
            },
            {
                text = CC_GOOD_EMBER_TEXT_12,
                time = CC_5_MINUTES,
                rapport = 1,
            },
            {
                text = CC_GOOD_EMBER_TEXT_13,
                time = CC_5_MINUTES,
                rapport = 1,
            },
            {
                text = CC_SHARED_FLEE_GUARD,
                time = CC_UNKNOWN_TIME,
                rapport = 1,
            },
            {
                text = CC_SHARED_TRESPASS,
                time = CC_UNKNOWN_TIME,
                rapport = 1,
            },
            {
                text = CC_GOOD_EMBER_TEXT_15,
                time = CC_UNKNOWN_TIME,
                rapport = 1,
            }
        },
        bad  = {
            {
                text = CC_BAD_EMBER_TEXT_2,
                time = {
                    CC_1_HOUR,
                    CC_DURING_COOLDOWN,
                },
                rapport = {
                    25,
                    5,
                },
            },
            {
                text = CC_BAD_EMBER_TEXT_1,
                time = CC_5_MINUTES,
                rapport = 10,
            },
            {
                text = CC_BAD_EMBER_TEXT_3,
                time = CC_UNKNOWN_TIME,
                rapport = 10,
            },
            {
                text = CC_BAD_EMBER_TEXT_6,
                time = CC_UNKNOWN_TIME,
                rapport = 10,
            },
            {
                text = CC_BAD_EMBER_TEXT_4,
                time = CC_NO_COOLDOWN,
                rapport = 5,
            },
            {
                text = CC_BAD_EMBER_TEXT_5,
                time = {
                    CC_5_MINUTES,
                    CC_DURING_COOLDOWN
                },
                rapport = {
                    5,
                    1
                },
            },
        }
    },
    [9912] = { -- Isobel Veloise
        good = {
            {
                text = CC_SHARED_COMPLETE_PERSONAL_QUEST,
                time = CC_SHARED_PERSONAL_QUEST_RAPPORT,
                rapport = 500,
            },
            {
                text = CC_GOOD_ISOBEL_TEXT_2,
                time = CC_24_HOURS,
                rapport = 125,
            },
            {
                text = CC_GOOD_ISOBEL_TEXT_3,
                time = CC_24_HOURS,
                rapport = 125,
            },
            {
                text = CC_GOOD_ISOBEL_TEXT_11,
                time = {
                    CC_20_HOURS,
                    CC_DURING_COOLDOWN,
                },
                rapport = {
                    25,
                    5
                },
            },
            {
                text = CC_GOOD_ISOBEL_TEXT_12,
                time = CC_ISOBEL_LEADERS,
                rapport = 10,
            },
            {
                text = CC_GOOD_ISOBEL_TEXT_13,
                time = CC_ISOBEL_LEADERS,
                rapport = 5,
            },
            {
                text = CC_GOOD_ISOBEL_TEXT_14,
                time = CC_ISOBEL_LEADERS,
                rapport = 1,
            },
            {
                text = CC_GOOD_ISOBEL_TEXT_15,
                time = CC_1_HOUR,
                rapport = 10,
            },
            {
                text = CC_GOOD_ISOBEL_TEXT_4,
                time = CC_5_MINUTES,
                rapport = 10,
            },
            {
                text = CC_GOOD_ISOBEL_TEXT_10,
                time = CC_UNKNOWN_TIME,
                rapport = 10,
            },
            {
                text = CC_GOOD_ISOBEL_TEXT_6,
                time = CC_1_HOUR,
                rapport = 5,
            },
            {
                text = CC_GOOD_ISOBEL_TEXT_8,
                time = CC_1_HOUR,
                rapport = 5,
            },
            {
                text = CC_GOOD_ISOBEL_TEXT_9,
                time = CC_1_HOUR,
                rapport = 5,
            },
            {
                text = CC_GOOD_ISOBEL_TEXT_1,
                time = CC_UNKNOWN_TIME,
                rapport = 5,
            },
            {
                text = CC_GOOD_ISOBEL_TEXT_16,
                time = CC_24_HOURS,
                rapport = 1,
            },
            {
                text = CC_GOOD_ISOBEL_TEXT_17,
                time = CC_1_HOUR,
                rapport = 1,
            },
            {
                text = CC_GOOD_ISOBEL_TEXT_18,
                time = CC_1_HOUR,
                rapport = 1,
            },
            {
                text = CC_GOOD_ISOBEL_TEXT_7,
                time = CC_5_MINUTES,
                rapport = 1,
            },
        },
        bad  = {
            {
                text = CC_SHARED_MURDER,
                time = {
                    CC_5_MINUTES,
                    CC_DURING_COOLDOWN,
                },
                rapport = {
                    10,
                    1
                },
            },
            {
                text = CC_SHARED_DARK_BROTHERHOOD,
                time = CC_20_HOURS,
                rapport = 5,
            },
            {
                text = CC_BAD_ISOBEL_TEXT_2,
                time = CC_1_HOUR,
                rapport = 1,
            },
            {
                text = CC_BAD_ISOBEL_TEXT_1,
                time = CC_5_MINUTES,
                rapport = 1,
            }
        }
    },
    [11113] = { -- Sharp-As-Night
        good = {
            {
                text = CC_SHARED_COMPLETE_PERSONAL_QUEST,
                time = CC_SHARED_PERSONAL_QUEST_RAPPORT,
                rapport = 500,
            },
            {
                text = CC_GOOD_SHARP_TEXT_9,
                time = CC_24_HOURS,
                rapport = 125,
            },
            {
                text = CC_SHARED_COMPLETE_ASHLANDER_DAILY,
                time = CC_24_HOURS,
                rapport = 125,
            },
            {
                text = CC_GOOD_SHARP_TEXT_11,
                time = CC_10_MINUTES,
                rapport = 10,
            },
            {
                text = CC_GOOD_SHARP_TEXT_17,
                time = CC_10_MINUTES,
                rapport = 10,
            },
            {
                text = CC_GOOD_SHARP_TEXT_12,
                time = CC_UNKNOWN_TIME,
                rapport = 10,
            },
            {
                text = CC_GOOD_SHARP_TEXT_13,
                time = CC_1_HOUR,
                rapport = 5,
            },
            {
                text = CC_GOOD_SHARP_TEXT_14,
                time = CC_1_HOUR,
                rapport = 5,
            },
            {
                text = CC_GOOD_SHARP_TEXT_5,
                time = {
                    CC_1_HOUR,
                    CC_DURING_COOLDOWN,
                },
                rapport = {
                    5,
                    1
                },
            },
            {
                text = CC_SHARED_HEAVY_SACK,
                time = {
                    CC_OFF_COOLDOWN,
                    CC_DURING_COOLDOWN,
                },
                rapport = {
                    5,
                    1
                },
            },
            {
                text = CC_GOOD_SHARP_TEXT_16,
                time = {
                    CC_FIRST_TIME,
                    CC_OTHER_TIMES,
                },
                rapport = {
                    5,
                    1
                },
            },
            {
                text = CC_GOOD_SHARP_TEXT_4,
                time = CC_10_MINUTES,
                rapport = 1,
            },
            {
                text = CC_GOOD_SHARP_TEXT_2,
                time = CC_24_HOURS,
                rapport = 1,
            },
            {
                text = CC_GOOD_SHARP_TEXT_10,
                time = CC_5_MINUTES,
                rapport = 1,
            },
            {
                text = CC_GOOD_SHARP_TEXT_15,
                time = CC_5_MINUTES,
                rapport = 1,
            },
            {
                text = CC_GOOD_SHARP_TEXT_3,
                time = CC_1_HOUR,
                rapport = 1,
            },
            {
                text = CC_GOOD_SHARP_TEXT_6,
                time = CC_UNKNOWN_TIME,
                rapport = 1,
            }
        },
        bad = {
            {
                text = CC_BAD_SHARP_TEXT_2,
                time = CC_UNKNOWN_TIME,
                rapport = 10,
            },
            {
                text = CC_BAD_SHARP_TEXT_4,
                time = CC_5_MINUTES,
                rapport = 5,
            },
            {
                text = CC_BAD_SHARP_TEXT_3,
                time = CC_UNKNOWN_TIME,
                rapport = 5,
            },
            {
                text = CC_BAD_SHARP_TEXT_1,
                time = CC_UNKNOWN_TIME,
                rapport = 1,
            },
            {
                text = CC_BAD_SHARP_TEXT_5,
                time = CC_UNKNOWN_TIME,
                rapport = 1,
            }
        }
    },
    [11114] = { -- Azandar Al-Cybiades
        good = {
            {
                text = CC_SHARED_COMPLETE_PERSONAL_QUEST,
                time = CC_SHARED_PERSONAL_QUEST_RAPPORT,
                rapport = 500,
            },
            {
                text = CC_GOOD_AZANDAR_TEXT_16,
                time = CC_24_HOURS,
                rapport = 125,
            },
            {
                text = CC_GOOD_AZANDAR_TEXT_1,
                time = CC_24_HOURS,
                rapport = 125,
            },
            {
                text = CC_GOOD_AZANDAR_TEXT_10,
                time = CC_15_MINUTES,
                rapport = 15,
            },
            {
                text = CC_SHARED_LOOTING_PSIJIC_PORTAL,
                time = CC_15_MINUTES,
                rapport = 15
            },
            {
                text = CC_SHARED_MUNDUS_STONE,
                time = CC_24_HOURS,
                rapport = 10,
            },
            {
                text = CC_GOOD_AZANDAR_TEXT_18,
                time = CC_20_HOURS,
                rapport = 10,
            },
            {
                text = CC_GOOD_AZANDAR_TEXT_3,
                time = CC_15_MINUTES,
                rapport = 5,
            },
            {
                text = CC_GOOD_AZANDAR_TEXT_4,
                time = CC_UNKNOWN_TIME,
                rapport = 5,
            },
            {
                text = CC_GOOD_AZANDAR_TEXT_6,
                time = CC_1_HOUR,
                rapport = 5,
            },
            {
                text = CC_GOOD_AZANDAR_TEXT_19,
                time = CC_NO_COOLDOWN,
                rapport = 5,
            },
            {
                text = CC_GOOD_AZANDAR_TEXT_20,
                time = CC_1_HOUR,
                rapport = 5,
            },
            {
                text = CC_GOOD_AZANDAR_TEXT_7,
                time = CC_1_HOUR,
                rapport = 5,
            },
            {
                text = CC_GOOD_AZANDAR_TEXT_11,
                time = CC_UNKNOWN_TIME,
                rapport = 5,
            },
            {
                text = CC_GOOD_AZANDAR_TEXT_12,
                time = {
                    CC_OFF_COOLDOWN,
                    CC_DURING_COOLDOWN
                },
                rapport = {
                    5,
                    1
                },
            },
            {
                text = CC_GOOD_AZANDAR_TEXT_5,
                time = {
                    CC_OFF_COOLDOWN,
                    CC_DURING_COOLDOWN
                },
                rapport = {
                    5,
                    1
                },
            },
            {
                text = CC_GOOD_AZANDAR_TEXT_8,
                time = {
                    CC_1_HOUR,
                    CC_DURING_COOLDOWN
                },
                rapport = {
                    5,
                    1
                },
            },
            {
                text = CC_GOOD_AZANDAR_TEXT_9,
                time = CC_UNKNOWN_TIME,
                rapport = 1,
            },
        },
        bad = {
            {
                text = CC_BAD_AZANDAR_TEXT_1,
                time = CC_UNKNOWN_TIME,
                rapport = 10,
            },
            {
                text = CC_BAD_AZANDAR_TEXT_2,
                time = CC_5_MINUTES,
                rapport = 1,
            },
            {
                text = CC_BAD_AZANDAR_TEXT_3,
                time = CC_5_MINUTES,
                rapport = 1,
            },
            {
                text = CC_BAD_AZANDAR_TEXT_4,
                time = CC_UNKNOWN_TIME,
                rapport = 1,
            },
        }
    },
    [12172] = { -- Tanlorin
        good = {
            {
                text = CC_SHARED_COMPLETE_PERSONAL_QUEST,
                time = CC_SHARED_PERSONAL_QUEST_RAPPORT,
                rapport = 500
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_1,
                time = CC_24_HOURS,
                rapport = 125
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_2,
                time = CC_24_HOURS,
                rapport = 125
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_3,
                time = CC_UNKNOWN_TIME,
                rapport = 25
            },
            {
                text = CC_SHARED_MUNDUS_STONE,
                time = CC_24_HOURS,
                rapport = 10
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_4,
                time = CC_UNKNOWN_TIME,
                rapport = 10
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_5,
                time = CC_UNKNOWN_TIME,
                rapport = 10
            },
            {
                text = CC_SHARED_PICKPOCKET_GUARD,
                time = {
                    CC_OFF_COOLDOWN,
                    CC_DURING_COOLDOWN
                },
                rapport = {
                    10,
                    1
                }
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_6,
                time = {
                    CC_OFF_COOLDOWN,
                    CC_DURING_COOLDOWN
                },
                rapport = {
                    10,
                    1
                }
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_7,
                time = CC_UNKNOWN_TIME,
                rapport = 5
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_8,
                time = CC_UNKNOWN_TIME,
                rapport = 5
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_9,
                time = CC_UNKNOWN_TIME,
                rapport = 5
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_10,
                time = CC_1_HOUR,
                rapport = 5
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_11,
                time = CC_1_HOUR,
                rapport = 5
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_12,
                time = CC_UNKNOWN_TIME,
                rapport = 5
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_13,
                time = CC_UNKNOWN_TIME,
                rapport = 5
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_15,
                time = CC_UNKNOWN_TIME,
                rapport = 5
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_16,
                time = CC_1_HOUR,
                rapport = 5
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_17,
                time = CC_5_MINUTES,
                rapport = 5
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_14,
                time = {
                    CC_OFF_COOLDOWN,
                    CC_DURING_COOLDOWN
                },
                rapport = {
                    5,
                    1
                }
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_18,
                time = {
                    CC_1_HOUR,
                    CC_DURING_COOLDOWN
                },
                rapport = {
                    5,
                    1
                }
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_19,
                time = {
                    CC_1_HOUR,
                    CC_DURING_COOLDOWN
                },
                rapport = {
                    5,
                    1
                }
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_20,
                time = {
                    CC_OFF_COOLDOWN,
                    CC_DURING_COOLDOWN
                },
                rapport = {
                    5,
                    1
                }
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_21,
                time = {
                    CC_OFF_COOLDOWN,
                    CC_DURING_COOLDOWN
                },
                rapport = {
                    5,
                    1
                }
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_22,
                time = {
                    CC_OFF_COOLDOWN,
                    CC_DURING_COOLDOWN
                },
                rapport = {
                    5,
                    1
                }
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_23,
                time = {
                    CC_OFF_COOLDOWN,
                    CC_DURING_COOLDOWN
                },
                rapport = {
                    5,
                    1
                }
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_24,
                time = {
                    CC_1_HOUR,
                    CC_DURING_COOLDOWN
                },
                rapport = {
                    5,
                    1
                }
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_25,
                time = CC_1_HOUR,
                rapport = 1
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_26,
                time = CC_1_HOUR,
                rapport = 1
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_27,
                time = CC_1_HOUR,
                rapport = 1
            },
            {
                text = CC_SHARED_TRESPASS,
                time = CC_UNKNOWN_TIME,
                rapport = 1
            },
            {
                text = CC_SHARED_FLEE_GUARD,
                time = CC_UNKNOWN_TIME,
                rapport = 1
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_28,
                time = CC_5_MINUTES,
                rapport = 1
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_29,
                time = CC_5_MINUTES,
                rapport = 1
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_30,
                time = CC_NO_COOLDOWN,
                rapport = 1
            },
            {
                text = CC_GOOD_TANLORIN_TEXT_31,
                time = CC_UNKNOWN_TIME,
                rapport = 1
            },
        },
        bad = {
            {
                text = CC_SHARED_MURDER,
                time = {
                    CC_3_HOURS,
                    CC_DURING_COOLDOWN
                },
                rapport = {
                    10,
                    1
                }
            },
            {
                text = CC_SHARED_USE_BLADE_OF_WOE_NPC,
                time = {
                    CC_5_MINUTES,
                    CC_DURING_COOLDOWN
                },
                rapport = {
                    10,
                    1
                }
            },
            {
                text = CC_BAD_TANLORIN_TEXT_1,
                time = CC_UNKNOWN_TIME,
                rapport = 5
            },
            {
                text = CC_SHARED_LOOTING_PSIJIC_PORTAL,
                time = CC_UNKNOWN_TIME,
                rapport = 1
            },
            {
                text = CC_BAD_TANLORIN_TEXT_2,
                time = CC_UNKNOWN_TIME,
                rapport = 1
            },
            {
                text = CC_BAD_TANLORIN_TEXT_3,
                time = CC_1_HOUR,
                rapport = 1
            },
            {
                text = CC_BAD_TANLORIN_TEXT_4,
                time = CC_1_HOUR,
                rapport = 1
            },
            {
                text = CC_BAD_TANLORIN_TEXT_5,
                time = CC_UNKNOWN_TIME,
                rapport = 1
            },
            {
                text = CC_BAD_TANLORIN_TEXT_6,
                time = CC_UNKNOWN_TIME,
                rapport = 1
            },
        }
    },
    [12173] = { -- Zerith-var
        good = {
            {
                text = CC_SHARED_COMPLETE_PERSONAL_QUEST,
                time = CC_SHARED_PERSONAL_QUEST_RAPPORT,
                rapport = 500,
            },
            {
                text = CC_GOOD_ZERITH_TEXT_1,
                time = CC_24_HOURS,
                rapport = 125,
            },
            {
                text = CC_GOOD_ZERITH_TEXT_2,
                time = CC_24_HOURS,
                rapport = 125,
            },
            {
                text = CC_GOOD_ZERITH_TEXT_3,
                time = CC_UNKNOWN_TIME,
                rapport = 25,
            },
            {
                text = CC_GOOD_ZERITH_TEXT_4,
                time = {
                    CC_1_HOUR,
                    CC_DURING_COOLDOWN
                },
                rapport = {
                    10,
                    1
                },
            },
            {
                text = CC_GOOD_ZERITH_TEXT_5,
                time = {
                    CC_1_HOUR,
                    CC_DURING_COOLDOWN
                },
                rapport = {
                    10,
                    1
                },
            },
            {
                text = CC_GOOD_ZERITH_TEXT_6,
                time = {
                    CC_OFF_COOLDOWN,
                    CC_DURING_COOLDOWN
                },
                rapport = {
                    10,
                    1
                },
            },
            {
                text = CC_GOOD_ZERITH_TEXT_7,
                time = CC_UNKNOWN_TIME,
                rapport = 10,
            },
            {
                text = CC_GOOD_ZERITH_TEXT_8,
                time = CC_UNKNOWN_TIME,
                rapport = 10,
            },
            {
                text = CC_GOOD_ZERITH_TEXT_9,
                time = CC_UNKNOWN_TIME,
                rapport = 10,
            },
            {
                text = CC_GOOD_ZERITH_TEXT_10,
                time = CC_UNKNOWN_TIME,
                rapport = 10,
            },
            {
                text = CC_GOOD_ZERITH_TEXT_11,
                time = CC_UNKNOWN_TIME,
                rapport = 10,
            },
            {
                text = CC_GOOD_ZERITH_TEXT_12,
                time = CC_UNKNOWN_TIME,
                rapport = 10,
            },
            {
                text = CC_GOOD_ZERITH_TEXT_13,
                time = CC_UNKNOWN_TIME,
                rapport = 10,
            },
            {
                text = CC_GOOD_ZERITH_TEXT_14,
                time = CC_UNKNOWN_TIME,
                rapport = 5,
            },
            {
                text = CC_SHARED_HEAVY_SACK,
                time = CC_5_HOURS,
                rapport = 5,
            },
            {
                text = CC_GOOD_ZERITH_TEXT_16,
                time = CC_1_HOUR,
                rapport = 5,
            },
            {
                text = CC_GOOD_ZERITH_TEXT_17,
                time = CC_UNKNOWN_TIME,
                rapport = 5,
            },
            {
                text = CC_GOOD_ZERITH_TEXT_18,
                time = CC_UNKNOWN_TIME,
                rapport = 5,                      -- Needs confirmation on exact rapport ammount
            },
            {
                text = CC_GOOD_ZERITH_TEXT_19,
                time = CC_3_MINUTES,
                rapport = 1,
            },
            {
                text = CC_GOOD_ZERITH_TEXT_20,
                time = CC_2_MINUTES,
                rapport = 1,
            },
            {
                text = CC_GOOD_ZERITH_TEXT_21,
                time = CC_UNKNOWN_TIME,
                rapport = 1,
            },
        },
        bad = {
            {
                text = CC_BAD_ZERITH_TEXT_1,
                time = CC_UNKNOWN_TIME,
                rapport = 50,
            },
            {
                text = CC_BAD_ZERITH_TEXT_2,
                time = CC_UNKNOWN_TIME,
                rapport = 25,
            },
            {
                text = CC_BAD_ZERITH_TEXT_3,
                time = CC_UNKNOWN_TIME,
                rapport = 10,
            },
            {
                text = CC_BAD_ZERITH_TEXT_4,
                time = {
                    CC_1_HOUR,
                    CC_DURING_COOLDOWN
                },
                rapport = {
                    5,
                    1
                },
            },
            {
                text = CC_BAD_ZERITH_TEXT_5,
                time = CC_UNKNOWN_TIME,
                rapport = 5,
            },
            {
                text = CC_BAD_ZERITH_TEXT_6,
                time = CC_UNKNOWN_TIME,
                rapport = 5,
            },
            {
                text = CC_BAD_ZERITH_TEXT_7,
                time = CC_UNKNOWN_TIME,
                rapport = 5,
            },
            {
                text = CC_BAD_ZERITH_TEXT_8,
                time = CC_UNKNOWN_TIME,
                rapport = 5,
            },
            {
                text = CC_BAD_ZERITH_TEXT_9,
                time = CC_UNKNOWN_TIME,
                rapport = 5,
            },
            {
                text = CC_BAD_ZERITH_TEXT_10,
                time = CC_UNKNOWN_TIME,
                rapport = 1,
            },
            {
                text = CC_BAD_ZERITH_TEXT_11,
                time = CC_UNKNOWN_TIME,
                rapport = 1,
            },
            {
                text = CC_BAD_ZERITH_TEXT_12,
                time = CC_UNKNOWN_TIME,
                rapport = 1,
            },
            {
                text = CC_BAD_ZERITH_TEXT_13,
                time = CC_UNKNOWN_TIME,
                rapport = 1,
            },
        }
    }
}

---List of rapport items in order
local CC_RAPPORT_LIST = {}

---Give each companions rapport item a unique identifier.
local function SetupRapportIds()
    local id = 1

    ---Assings a unique id to each of
    ---@param characterId any
    ---@param rapportType any
    ---@param interactionList any
    local function AssignIds(characterId, rapportType, interactionList)
        for rapportIndex, interactionData in pairs(interactionList) do
            CC_COMPANION_DATA[characterId][rapportType][rapportIndex]['id'] = id
            CC_RAPPORT_LIST[id] = CC_COMPANION_DATA[characterId][rapportType][rapportIndex]
            id = id + 1
        end
    end

    for characterId, characterRapport in pairs(CC_COMPANION_DATA) do
        AssignIds(characterId, "good", characterRapport.good)
        AssignIds(characterId, "bad", characterRapport.bad)
    end
end

local CC_CompanionDataManager = ZO_InitializingObject:Subclass()

---Performs the nessesery setup up on the rapport information
function CC_CompanionDataManager:Initialize()
    SetupRapportIds()
end

---Get the unique identifier for the requsted rapport object.
---@param rapport table
---@return number
function CC_CompanionDataManager:GetRapportId(rapport)
    return rapport.id
end

---Get the rapport data from it's unqiue identifier.  If none can be found, nill is returned.
---@param rapportId number
---@return table|nil
function CC_CompanionDataManager:GetRapportData(rapportId)
    return CC_RAPPORT_LIST[rapportId]
end

---Gets the rapport interaction text id.
---@param rapportId number
---@return number|nil
function CC_CompanionDataManager:GetInteractionName(rapportId)
    local rapportData = self:GetRapportData(rapportId)

    if rapportData == nil then
        return nil
    end

    return rapportData.text
end

---Get a rapport and time list for a given rapport.
---Each rapport interaction has the ability to have different rapport values and timers.  This
---function will return both the rapport amounts and timers for the rapport interaction
---provided.
---@param rapportId any
---@return table|nil
---@return table|nil
function CC_CompanionDataManager:GetRapportTimeComponents(rapportId)
    local rapportData = self:GetRapportData(rapportId)

    if rapportData == nil then
        return nil, nil
    end

    -- List of rapport/timers
    local rapportList = {}
    local timeList    = {}

    if CC_Libs.is_array(rapportData.rapport) then
        for i, value in ipairs(rapportData.rapport) do
            table.insert(rapportList, value)
            table.insert(timeList, GetString(rapportData.time[i]))
        end
    else
        table.insert(rapportList, rapportData.rapport)
        table.insert(timeList, GetString(rapportData.time))
    end

    return rapportList, timeList
end

---Get a list of a companions good rapport options.
---@param companionId number
---@return table|nil
function CC_CompanionDataManager:GetCompanionGoodRaport(companionId)
    if CC_COMPANION_DATA[companionId] ~= nil then
        return CC_COMPANION_DATA[companionId].good
    end
    return nil
end

---Get a list of a companions bad rapport options.
---@param companionId number
---@return table|nil
function CC_CompanionDataManager:GetCompanionBadRaport(companionId)
    if CC_COMPANION_DATA[companionId] ~= nil then
        return CC_COMPANION_DATA[companionId].bad
    end
    return nil
end

CC_COMPANION_DATA_MANAGER = CC_CompanionDataManager:New()
