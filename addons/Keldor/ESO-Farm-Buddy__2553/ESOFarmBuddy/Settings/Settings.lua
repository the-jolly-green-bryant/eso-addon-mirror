--- ESO Farm-Buddy AddOn written by Keldor

----
--- Initialize global Variables
----
ESOFarmBuddySettings = {}
ESOFarmBuddySettings.ItemListCtrls = nil
ESOFarmBuddySettings.AlertSounds = {
    [1] = { name = "None", sound = 'No_Sound' },
    [2] = { name = "Add Guild Member", sound = 'GuildRoster_Added' },
    [3] = { name = "Armor Glyph", sound = 'Enchanting_ArmorGlyph_Placed' },
    [4] = { name = "Book Acquired", sound = 'Book_Acquired' },
    [5] = { name = "Book Collection Completed", sound = 'Book_Collection_Completed' },
    [6] = { name = "Boss Killed", sound = 'SkillXP_BossKilled' },
    [7] = { name = "Charge Item", sound = 'InventoryItem_ApplyCharge' },
    [8] = { name = "Completed Event", sound = 'ScriptedEvent_Completion' },
    [9] = { name = "Dark Fissure Closed", sound = 'SkillXP_DarkFissureClosed' },
    [10] = { name = "Emperor Coronated", sound = 'Emperor_Coronated_Ebonheart' },
    [11] = { name = "Gate Closed", sound = 'AvA_Gate_Closed' },
    [12] = { name = "Lockpicking Stress", sound = 'Lockpicking_chamber_stress' },
    [13] = { name = "Mail Attachment", sound = 'Mail_ItemSelected' },
    [14] = { name = "Mail Sent", sound = 'Mail_Sent' },
    [15] = { name = "Money", sound = 'Money_Transact' },
    [16] = { name = "Morph Ability", sound = 'Ability_MorphPurchased' },
    [17] = { name = "Not Enough Gold", sound = 'PlayerAction_NotEnoughMoney' },
    [18] = { name = "Not Junk", sound = 'InventoryItem_NotJunk' },
    [19] = { name = "Not Ready", sound = 'Ability_NotReady' },
    [20] = { name = "Objective Complete", sound = 'Objective_Complete' },
    [21] = { name = "Open System Menu", sound = 'System_Open' },
    [22] = { name = "Quest Abandoned", sound = 'Quest_Abandon' },
    [23] = { name = "Quest Complete", sound = 'Quest_Complete' },
    [24] = { name = "Quickslot Empty", sound = 'Quickslot_Use_Empty' },
    [25] = { name = "Quickslot Open", sound = 'Quickslot_Open' },
    [26] = { name = "Raid Life", sound = 'Raid_Life_Display_Shown' },
    [27] = { name = "Remove Guild Member", sound = 'GuildRoster_Removed' },
    [28] = { name = "Repair Item", sound = 'InventoryItem_Repair' },
    [29] = { name = "Rune Removed", sound = 'Enchanting_PotencyRune_Removed' },
    [30] = { name = "Skill Added", sound = 'SkillLine_Added' },
    [31] = { name = "Skill Leveled", sound = 'SkillLine_Leveled' },
    [32] = { name = "Stat Purchase", sound = 'Stats_Purchase' },
    [33] = { name = "Synergy Ready", sound = 'Ability_Synergy_Ready_Sound' },
}
ESOFarmBuddySettings.OptionsTable = nil


-- Local vars
local LAM = LibAddonMenu2
local ESOFarmBuddy
local SVS
local IL


---
--- Settings getter and setter
---
function ESOFarmBuddySettings.SetShowTitle(var)
    SVS.ShowTitle = var
    ESOFarmBuddy.ToggleAddOnTitle()
end

function ESOFarmBuddySettings.SetClampedToScreen(var)
    SVS.ClampedToScreen = var
    ESOFarmBuddy.ToggleClampedToScreen()
end

function ESOFarmBuddySettings.SetHideWindowInDungeonAndTrial(var)
    SVS.HideWindowInDungeonAndTrial = var
    ESOFarmBuddy.ToggleHideWindow(nil)
end

function ESOFarmBuddySettings.SetHideWindowInPvP(var)
    SVS.HideWindowInPvP = var
    ESOFarmBuddy.ToggleHideWindow(nil)
end

function ESOFarmBuddySettings.SetHideWindowInHomes(var)
    SVS.HideWindowInHomes = var
    ESOFarmBuddy.ToggleHideWindow(nil)
end

function ESOFarmBuddySettings.SetShowItemName(var)
    SVS.ShowItemName = var
    ESOFarmBuddy.RefreshItemList()
end

function ESOFarmBuddySettings.SetDisplayMode(var)
    SVS.DisplayMode = var
    ESOFarmBuddy.RefreshItemList()
end

function ESOFarmBuddySettings.SetProgressDisplayMode(var)
    SVS.ProgressDisplayMode = var
    ESOFarmBuddy.RefreshItemList()
end

function ESOFarmBuddySettings.SetIncludeBank(var)
    SVS.IncludeBank = var
    ESOFarmBuddy.RefreshItemList()
end

function ESOFarmBuddySettings.SetIncludeCraftBag(var)
    SVS.IncludeCraftBag = var
    ESOFarmBuddy.RefreshItemList()
end

function ESOFarmBuddySettings.SetProgressbarNotCompletedColor(r, g, b, a)
    SVS.ProgressbarColors.NotComleted.r = r
    SVS.ProgressbarColors.NotComleted.g = g
    SVS.ProgressbarColors.NotComleted.b = b
    SVS.ProgressbarColors.NotComleted.a = a

    ESOFarmBuddy.RefreshItemList()
end

function ESOFarmBuddySettings.GetProgressbarNotCompletedColor()
    return SVS.ProgressbarColors.NotComleted.r, SVS.ProgressbarColors.NotComleted.g, SVS.ProgressbarColors.NotComleted.b, SVS.ProgressbarColors.NotComleted.a
end

function ESOFarmBuddySettings.SetProgressbarCompletedColor(r, g, b, a)
    SVS.ProgressbarColors.Comleted.r = r
    SVS.ProgressbarColors.Comleted.g = g
    SVS.ProgressbarColors.Comleted.b = b
    SVS.ProgressbarColors.Comleted.a = a

    ESOFarmBuddy.RefreshItemList()
end

function ESOFarmBuddySettings.GetProgressTextNotCompletedColor()
    return SVS.ProgressTextColors.NotComleted.r, SVS.ProgressTextColors.NotComleted.g, SVS.ProgressTextColors.NotComleted.b, SVS.ProgressTextColors.NotComleted.a
end

function ESOFarmBuddySettings.SetProgressTextNotCompletedColor(r, g, b, a)
    SVS.ProgressTextColors.NotComleted.r = r
    SVS.ProgressTextColors.NotComleted.g = g
    SVS.ProgressTextColors.NotComleted.b = b
    SVS.ProgressTextColors.NotComleted.a = a

    ESOFarmBuddy.RefreshItemList()
end

function ESOFarmBuddySettings.GetProgressTextCompletedColor()
    return SVS.ProgressTextColors.Comleted.r, SVS.ProgressTextColors.Comleted.g, SVS.ProgressTextColors.Comleted.b, SVS.ProgressTextColors.Comleted.a
end

function ESOFarmBuddySettings.SetProgressTextCompletedColor(r, g, b, a)
    SVS.ProgressTextColors.Comleted.r = r
    SVS.ProgressTextColors.Comleted.g = g
    SVS.ProgressTextColors.Comleted.b = b
    SVS.ProgressTextColors.Comleted.a = a

    ESOFarmBuddy.RefreshItemList()
end

function ESOFarmBuddySettings.GetProgressbarCompletedColor()
    return SVS.ProgressbarColors.Comleted.r, SVS.ProgressbarColors.Comleted.g, SVS.ProgressbarColors.Comleted.b, SVS.ProgressbarColors.Comleted.a
end

function ESOFarmBuddySettings.GetSoundKeys()
    local keyList = {}
    for i = 1, #ESOFarmBuddySettings.AlertSounds do table.insert(keyList, ESOFarmBuddySettings.AlertSounds[i].sound) end
    return keyList
end

function ESOFarmBuddySettings.GetSoundValues()
    local keyList = {}
    for i = 1, #ESOFarmBuddySettings.AlertSounds do table.insert(keyList, ESOFarmBuddySettings.AlertSounds[i].name) end
    return keyList
end

function ESOFarmBuddySettings.SetSortBy(var)
    SVS.SortBy = var
    ESOFarmBuddy.RefreshItemList()
end

function ESOFarmBuddySettings.SetSortDirection(var)
    SVS.SortDirection = var
    ESOFarmBuddy.RefreshItemList()
end

function ESOFarmBuddySettings.SetProgressStyle(var)

    SVS.ProgressStyle = var
    ESOFarmBuddy.RefreshItemList()
end


---
--- Init settings sections
---
function ESOFarmBuddySettings.InitCountingSettings()

    ESOFarmBuddySettings.OptionsTable[#ESOFarmBuddySettings.OptionsTable + 1] = {
        type = "submenu",
        name = GetString(ESOFB_SETTINGS_COUNTING_SETTINGS),
        width = "full",
        controls = {
            [1] = {
                type = "description",
                title = nil,
                text = GetString(ESOFB_SETTINGS_COUNTING_DESCRIPTION),
                width = "full",
            },
            [2] = {
                type = "dropdown",
                name = GetString(ESOFB_SETTINGS_DISPLAY_MODE),
                tooltip = GetString(ESOFB_SETTINGS_DISPLAY_MODE_TOOLTIP),
                choices = {
                    GetString(ESOFB_DISPLAY_MODE_SESSION),
                    GetString(ESOFB_DISPLAY_MODE_TOTAL),
                },
                choicesValues = {
                    ESOFarmBuddy.DISPLAY_MODE_SESSION,
                    ESOFarmBuddy.DISPLAY_MODE_TOTAL,
                },
                width = "full",
                getFunc = function() return SVS.DisplayMode end,
                setFunc = function(var) ESOFarmBuddySettings.SetDisplayMode(var) end,
            },
            [3] = {
                type = "checkbox",
                name = GetString(ESOFB_SETTINGS_INCLUDE_BANK),
                tooltip = GetString(ESOFB_SETTINGS_INCLUDE_COUNT_TOOLTIP),
                width = "full",
                getFunc = function() return SVS.IncludeBank end,
                setFunc = function(var) ESOFarmBuddySettings.SetIncludeBank(var) end,
            },
            [4] = {
                type = "checkbox",
                name = GetString(ESOFB_SETTINGS_INCLUDE_CRAFT_BAG),
                tooltip = GetString(ESOFB_SETTINGS_INCLUDE_COUNT_TOOLTIP),
                width = "full",
                getFunc = function() return SVS.IncludeCraftBag end,
                setFunc = function(var) ESOFarmBuddySettings.SetIncludeCraftBag(var) end,
            }
        },
    }
end

function ESOFarmBuddySettings.InitDisplaySettings()

    ESOFarmBuddySettings.OptionsTable[#ESOFarmBuddySettings.OptionsTable + 1] = {
        type = "submenu",
        name = GetString(ESOFB_SETTINGS_DISPLAY_SETTINGS),
        width = "full",
        controls = {
            [1] = {
                type = "description",
                title = nil,
                text = GetString(ESOFB_SETTINGS_DISPLAY_DESCRIPTION),
                width = "full",
            },
            [2] = {
                type = "checkbox",
                name = GetString(ESOFB_SETTINGS_LOCK_WINDOW),
                width = "full",
                getFunc = function() return SVS.LockWindow end,
                setFunc = function(var) SVS.LockWindow = var ESOFarmBuddy.ToggleWindowLock() end,
            },
            [3] = {
                type = "checkbox",
                name = GetString(ESOFB_SETTINGS_HIDE_WINDOW),
                width = "full",
                getFunc = function() return SVS.HideWindow end,
                setFunc = function(var) SVS.HideWindow = var ESOFarmBuddy.ToggleHideWindow(nil) end,
            },
            [4] = {
                type = "checkbox",
                name = GetString(ESOFB_SETTINGS_SHOW_WINDOW_IN_SETTINGS),
                width = "full",
                getFunc = function() return SVS.ShowWindowInSettings end,
                setFunc = function(var) SVS.ShowWindowInSettings = var ESOFarmBuddy.ToggleShowWindowInSettings() end,
            },
            [5] = {
                type = "checkbox",
                name = GetString(ESOFB_SETTINGS_SHOW_ADDON_TITLE),
                width = "full",
                getFunc = function() return SVS.ShowTitle end,
                setFunc = function(var) ESOFarmBuddySettings.SetShowTitle(var) end,
            },
            [6] = {
                type = "checkbox",
                name = GetString(ESOFB_SETTINGS_CLAMP_TO_SCREEN),
                tooltip = GetString(ESOFB_SETTINGS_CLAMP_TO_SCREEN_TOOLTIP),
                width = "full",
                getFunc = function() return SVS.ClampedToScreen end,
                setFunc = function(var) ESOFarmBuddySettings.SetClampedToScreen(var) end,
            },
            [7] = {
                type = "checkbox",
                name = GetString(ESOFB_SETTINGS_HIDE_WINDOW_IN_COMBAT),
                width = "full",
                getFunc = function() return SVS.HideWindowInCombat end,
                setFunc = function(var) ESOFarmBuddy.ToggleHideWindowInCombat(var) end,
            },
            [8] = {
                type = "checkbox",
                name = GetString(ESOFB_SETTINGS_HIDE_IN_DUNGEON_AND_TRIAL),
                tooltip = GetString(ESOFB_SETTINGS_HIDE_IN_DUNGEON_AND_TRIAL_TOOLTIP),
                width = "full",
                getFunc = function() return SVS.HideWindowInDungeonAndTrial end,
                setFunc = function(var) ESOFarmBuddySettings.SetHideWindowInDungeonAndTrial(var) end,
            },
            [9] = {
                type = "checkbox",
                name = GetString(ESOFB_SETTINGS_HIDE_IN_PVP),
                tooltip = GetString(ESOFB_SETTINGS_HIDE_IN_PVP_TOOLTIP),
                width = "full",
                getFunc = function() return SVS.HideWindowInPvP end,
                setFunc = function(var) ESOFarmBuddySettings.SetHideWindowInPvP(var) end,
            },
            [10] = {
                type = "checkbox",
                name = GetString(ESOFB_SETTINGS_HIDE_IN_HOMES),
                tooltip = GetString(ESOFB_SETTINGS_HIDE_IN_HOMES_TOOLTIP),
                width = "full",
                getFunc = function() return SVS.HideWindowInHomes end,
                setFunc = function(var) ESOFarmBuddySettings.SetHideWindowInHomes(var) end,
            },
            [11] = {
                type = "checkbox",
                name = GetString(ESOFB_SETTINGS_SHOW_ITEM_NAME),
                width = "full",
                getFunc = function() return SVS.ShowItemName end,
                setFunc = function(var) ESOFarmBuddySettings.SetShowItemName(var) end,
            },
            [12] = {
                type = "colorpicker",
                name = GetString(ESOFB_SETTINGS_DISPLAY_PROGRESS_TEXT_COMPLETED_COLOR),
                getFunc = function() return ESOFarmBuddySettings.GetProgressTextCompletedColor() end,
                setFunc = function(r, g, b, a) ESOFarmBuddySettings.SetProgressTextCompletedColor(r, g, b, a) end,
                width = "full",
            },
            [13] = {
                type = "slider",
                name = GetString(ESOFB_SETTINGS_DISPLAY_BACKGROUND_OPACITY),
                tooltip = GetString(ESOFB_SETTINGS_DISPLAY_BACKGROUND_OPACITY_TOOLTIP),
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return SVS.BackgroundAlpha end,
                setFunc = function(var) SVS.BackgroundAlpha = var ESOFarmBuddy.SetBackgroundOpacity() end,
                width = "full",
            },
        },
    }
end

function ESOFarmBuddySettings.InitProgressBarSettings()

    ESOFarmBuddySettings.OptionsTable[#ESOFarmBuddySettings.OptionsTable + 1] = {
        type = "submenu",
        name = GetString(ESOFB_SETTINGS_PROGRESS_BAR_SETTINGS),
        width = "full",
        controls = {
            [1] = {
                type = "description",
                title = nil,
                text = GetString(ESOFB_SETTINGS_PROGRESS_BAR_DESCRIPTION),
                width = "full",
            },
            [2] = {
                type = "checkbox",
                name = GetString(ESOFB_SETTINGS_SHOW_PROGRESSBAR),
                width = "full",
                getFunc = function() return SVS.ShowProgressBar end,
                setFunc = function(var) SVS.ShowProgressBar = var ESOFarmBuddy.RefreshItemList() end,
            },
            [3] = {
                type = "dropdown",
                name = GetString(ESOFB_SETTINGS_PROGRESS_STYLE),
                choices = {
                    GetString(ESOFB_PROGRESS_STYLE_MATERIAL),
                    GetString(ESOFB_PROGRESS_STYLE_TEXTURE),
                },
                choicesValues = {
                    ESOFarmBuddy.PROGRESS_STYLE_MATERIAL,
                    ESOFarmBuddy.PROGRESS_STYLE_TEXTURE,
                },
                width = "full",
                getFunc = function() return SVS.ProgressStyle end,
                setFunc = function(var) ESOFarmBuddySettings.SetProgressStyle(var) end,
            },
            [4] = {
                type = "dropdown",
                name = GetString(ESOFB_SETTINGS_PROGRESS_DISPLAY_MODE),
                choices = {
                    GetString(ESOFB_PROGRESS_DISPLAY_MODE_FULL),
                    GetString(ESOFB_PROGRESS_DISPLAY_MODE_COUNT),
                    GetString(ESOFB_PROGRESS_DISPLAY_MODE_PERCENT),
                },
                choicesValues = {
                    ESOFarmBuddy.PROGRESS_DISPLAY_MODE_FULL,
                    ESOFarmBuddy.PROGRESS_DISPLAY_MODE_COUNT,
                    ESOFarmBuddy.PROGRESS_DISPLAY_MODE_PERCENT,
                },
                width = "full",
                getFunc = function() return SVS.ProgressDisplayMode end,
                setFunc = function(var) ESOFarmBuddySettings.SetProgressDisplayMode(var) end,
            },
            [5] = {
                type = "colorpicker",
                name = GetString(ESOFB_SETTINGS_DISPLAY_PROGRESSBAR_NOT_COMPLETED_COLOR),
                getFunc = function() return ESOFarmBuddySettings.GetProgressbarNotCompletedColor() end,
                setFunc = function(r, g, b, a) ESOFarmBuddySettings.SetProgressbarNotCompletedColor(r, g, b, a) end,
                width = "full",
            },
            [6] = {
                type = "colorpicker",
                name = GetString(ESOFB_SETTINGS_DISPLAY_PROGRESSBAR_COMPLETED_COLOR),
                getFunc = function() return ESOFarmBuddySettings.GetProgressbarCompletedColor() end,
                setFunc = function(r, g, b, a) ESOFarmBuddySettings.SetProgressbarCompletedColor(r, g, b, a) end,
                width = "full",
            },
            [7] = {
                type = "colorpicker",
                name = GetString(ESOFB_SETTINGS_DISPLAY_PROGRESS_TEXT_NOT_COMPLETED_COLOR),
                getFunc = function() return ESOFarmBuddySettings.GetProgressTextNotCompletedColor() end,
                setFunc = function(r, g, b, a) ESOFarmBuddySettings.SetProgressTextNotCompletedColor(r, g, b, a) end,
                width = "full",
            },
        },
    }
end

function ESOFarmBuddySettings.InitSortingSettings()

    ESOFarmBuddySettings.OptionsTable[#ESOFarmBuddySettings.OptionsTable + 1] = {
        type = "submenu",
        name = GetString(ESOFB_SETTINGS_SORTING_SETTINGS),
        width = "full",
        controls = {
            [1] = {
                type = "description",
                title = nil,
                text = GetString(ESOFB_SETTINGS_SORTING_DESCRIPTION),
                width = "full",
            },
            [2] = {
                type = "dropdown",
                name = GetString(ESOFB_SETTINGS_SORT_BY),
                choices = {
                    GetString(ESOFB_SORT_BY_NAME),
                    GetString(ESOFB_SORT_BY_COUNT),
                    GetString(ESOFB_SORT_BY_GOAL),
                    GetString(ESOFB_SORT_BY_PROGRESS),
                },
                choicesValues = {
                    ESOFarmBuddy.SORT_BY_NAME,
                    ESOFarmBuddy.SORT_BY_COUNT,
                    ESOFarmBuddy.SORT_BY_GOAL,
                    ESOFarmBuddy.SORT_BY_PROGRESS,
                },
                width = "full",
                getFunc = function() return SVS.SortBy end,
                setFunc = function(var) ESOFarmBuddySettings.SetSortBy(var) end,
            },
            [3] = {
                type = "dropdown",
                name = GetString(ESOFB_SETTINGS_SORT_DIRECTION),
                choices = {
                    GetString(ESOFB_SORT_ASC),
                    GetString(ESOFB_SORT_DESC),
                },
                choicesValues = {
                    ESOFarmBuddy.SORT_ASC,
                    ESOFarmBuddy.SORT_DESC,
                },
                width = "full",
                getFunc = function() return SVS.SortDirection end,
                setFunc = function(var) ESOFarmBuddySettings.SetSortDirection(var) end,
            },
        },
    }
end

function ESOFarmBuddySettings.InitBonusSettings()

    ESOFarmBuddySettings.OptionsTable[#ESOFarmBuddySettings.OptionsTable + 1] = {
        type = "submenu",
        name = GetString(ESOFB_SETTINGS_BONUS_SETTINGS),
        width = "full",
        controls = {
            [1] = {
                type = "description",
                title = nil,
                text = GetString(ESOFB_SETTINGS_BONUS_DESCRIPTION),
                width = "full",
            },
            [2] = {
                type = "checkbox",
                name = GetString(ESOFB_SETTINGS_SHOW_GOAL_BONUS),
                tooltip = GetString(ESOFB_SETTINGS_SHOW_GOAL_BONUS_TOOLTIP),
                width = "full",
                getFunc = function() return SVS.ShowGoalBonus end,
                setFunc = function(var) SVS.ShowGoalBonus = var ESOFarmBuddy.RefreshItemList() end,
            },
            [3] = {
                type = "dropdown",
                name = GetString(ESOFB_SETTINGS_SHOW_GOAL_BONUS_TYPE),
                width = "full",
                choices = {
                    GetString(ESOFB_BONUS_DISPLAY_MODE_PERCENT),
                    GetString(ESOFB_BONUS_DISPLAY_MODE_COUNT),
                },
                choicesValues = {
                    ESOFarmBuddy.BONUS_DISPLAY_MODE_PERCENT,
                    ESOFarmBuddy.BONUS_DISPLAY_MODE_COUNT,
                },
                getFunc = function() return SVS.GoalBonusDisplayType end,
                setFunc = function(var) SVS.GoalBonusDisplayType = var ESOFarmBuddy.RefreshItemList() end,
            },
        },
    }
end

function ESOFarmBuddySettings.InitNotificationSettings()

    ESOFarmBuddySettings.OptionsTable[#ESOFarmBuddySettings.OptionsTable + 1] = {
        type = "submenu",
        name = GetString(ESOFB_SETTINGS_NOTIFICATION_SETTINGS),
        width = "full",
        controls = {
            [1] = {
                type = "description",
                title = nil,
                text = GetString(ESOFB_SETTINGS_NOTIFICATION_DESCRIPTION),
                width = "full",
            },
            [2] = {
                type = "checkbox",
                name = GetString(ESOFB_SETTINGS_SHOW_GOAL_NOTIFICATIONS),
                width = "full",
                getFunc = function() return SVS.ShowGoalNotifications end,
                setFunc = function(var) SVS.ShowGoalNotifications = var end,
            },
            [3] = {
                type = "checkbox",
                name = GetString(ESOFB_SETTINGS_PLAY_GOAL_NOTIFICATION_SOUND),
                width = "full",
                getFunc = function() return SVS.PlayGoalNotificationSound end,
                setFunc = function(var) SVS.PlayGoalNotificationSound = var end,
            },
            [4] = {
                type = "dropdown",
                name = GetString(ESOFB_SETTINGS_GOAL_NOTIFICATION_SOUND),
                choices = ESOFarmBuddySettings.GetSoundValues(),
                choicesValues = ESOFarmBuddySettings.GetSoundKeys(),
                width = "full",
                getFunc = function() return SVS.GoalNotificationSound end,
                setFunc = function(var) PlaySound(var) SVS.GoalNotificationSound = var end,
            },
        },
    }
end

function ESOFarmBuddySettings.InitActionSettings()

    ESOFarmBuddySettings.OptionsTable[#ESOFarmBuddySettings.OptionsTable + 1] = {
        type = "header",
        name = GetString(ESOFB_SETTINGS_ACTIONS),
        width = "full",
    }
    ESOFarmBuddySettings.OptionsTable[#ESOFarmBuddySettings.OptionsTable + 1] = {
        type = "description",
        title = nil,
        text = GetString(ESOFB_SETTINGS_ACTIONS_DESCRIPTION),
        width = "full",
    }
    ESOFarmBuddySettings.OptionsTable[#ESOFarmBuddySettings.OptionsTable + 1] = {
        type = "button",
        name = GetString(ESOFB_SETTINGS_ACTIONS_RESET_LIST),
        tooltip = GetString(ESOFB_SETTINGS_ACTIONS_RESET_LIST_TOOLTIP),
        func = function() ESOFarmBuddy.ResetItemList() end,
        width = "half"
    }
    ESOFarmBuddySettings.OptionsTable[#ESOFarmBuddySettings.OptionsTable + 1] = {
        type = "button",
        name = GetString(ESOFB_SETTINGS_ACTIONS_RESET_WINDOWS_POSITION),
        tooltip = GetString(ESOFB_SETTINGS_ACTIONS_RESET_WINDOWS_POSITION_TOOLTIP),
        func = function() ESOFarmBuddy.ResetWindowPosition() end,
        width = "half"
    }
    ESOFarmBuddySettings.OptionsTable[#ESOFarmBuddySettings.OptionsTable + 1] = {
        type = "button",
        name = GetString(ESOFB_SETTINGS_ACTIONS_TEST_NOTIFICATION),
        func = function() ESOFarmBuddy.NotificationTest() end,
        width = "half"
    }
end

function ESOFarmBuddySettings.InitSettingsPanel(ref)

    ESOFarmBuddySettings.OptionsTable = {}
    ESOFarmBuddy = ref
    SVS = ESOFarmBuddy.SV.Settings
    IL = ESOFarmBuddy.SV.ItemList

    local panelData = {
        type = "panel",
        name = ESOFarmBuddy.DisplayName,
        author = "Keldor",
        version = ESOFarmBuddy.AddonVersion,
        donation = ESOFarmBuddy.DonationUrl,
        registerForRefresh = true,
    }

    ESOFarmBuddySettings.OptionsTable[#ESOFarmBuddySettings.OptionsTable + 1] = {
        type = "description",
        title = nil,
        text = GetString(ESOFB_SETTINGS_DESCRIPTION),
        width = "full",
    }

    ESOFarmBuddySettings.InitCountingSettings()
    ESOFarmBuddySettings.InitDisplaySettings()
    ESOFarmBuddySettings.InitProgressBarSettings()
    ESOFarmBuddySettings.InitSortingSettings()
    ESOFarmBuddySettings.InitBonusSettings()
    ESOFarmBuddySettings.InitNotificationSettings()
    ESOFarmBuddySettings.InitActionSettings()

    LAM:RegisterAddonPanel(ESOFarmBuddy.LAMPanelName, panelData)
    LAM:RegisterOptionControls(ESOFarmBuddy.LAMPanelName, ESOFarmBuddySettings.OptionsTable)
end