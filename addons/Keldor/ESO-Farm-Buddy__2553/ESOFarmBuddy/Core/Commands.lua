--- ESO Farm-Buddy AddOn written by Keldor

ESOFarmBuddyCommands = {}
ESOFarmBuddyCommands.ChatCommand = "efb"


function ESOFarmBuddyCommands.AddCommand(itemLink)

    local itemId = GetItemLinkItemId(itemLink)
    if itemId > 0 then
        ESOFarmBuddy.TrackItemFromLink(itemLink)
    else
        ESOFarmBuddyUtils:ChatMsg("|cF10000" .. GetString(ESOFB_INVALID_ITEM_LINK) .. "|r")
    end
end

function ESOFarmBuddyCommands.RemoveCommand(itemLink)

    local itemId = GetItemLinkItemId(itemLink)
    if itemId > 0 then
        ESOFarmBuddy.RemoveItemFromLink(itemLink)
    else
        ESOFarmBuddyUtils:ChatMsg("|cF10000" .. GetString(ESOFB_INVALID_ITEM_LINK) .. "|r")
    end
end

function ESOFarmBuddyCommands.GoalCommand(itemLink, count)

    local itemId = GetItemLinkItemId(itemLink)
    if itemId > 0 then
        ESOFarmBuddy.SetGoalCountValue(itemLink, count)
    else
        ESOFarmBuddyUtils:ChatMsg("|cF10000" .. GetString(ESOFB_INVALID_ITEM_LINK) .. "|r")
    end
end

function ESOFarmBuddyCommands.ClearCommand()
    ESOFarmBuddy.ResetItemList()
    ESOFarmBuddyUtils:ChatMsg(GetString(ESOFB_CMD_CLEAR_MSG))
end

function ESOFarmBuddyCommands.ToggleCommand(toggleCommand)

    local infoStr

    if toggleCommand == "lock" then

        if ESOFarmBuddy.SV.Settings.LockWindow == true then
            ESOFarmBuddy.SV.Settings.LockWindow = false
            infoStr = ESOFB_CMD_TOGGLE_LOCK_UNLOCKED
        else
            ESOFarmBuddy.SV.Settings.LockWindow = true
            infoStr = ESOFB_CMD_TOGGLE_LOCK_LOCKED
        end

        ESOFarmBuddy.ToggleWindowLock()
        ESOFarmBuddyUtils:ChatMsg(GetString(infoStr))

    elseif toggleCommand == "title" then

        if ESOFarmBuddy.SV.Settings.ShowTitle == true then
            ESOFarmBuddy.SV.Settings.ShowTitle = false
            infoStr = ESOFB_CMD_TOGGLE_TITLE_HIDDEN
        else
            ESOFarmBuddy.SV.Settings.ShowTitle = true
            infoStr = ESOFB_CMD_TOGGLE_TITLE_SHOWN
        end

        ESOFarmBuddy.ToggleAddOnTitle()
        ESOFarmBuddyUtils:ChatMsg(GetString(infoStr))

    elseif toggleCommand == "progressbar" then

        if ESOFarmBuddy.SV.Settings.ShowProgressBar == true then
            ESOFarmBuddy.SV.Settings.ShowProgressBar = false
            infoStr = ESOFB_CMD_TOGGLE_PROGRESSBAR_HIDDEN
        else
            ESOFarmBuddy.SV.Settings.ShowProgressBar = true
            infoStr = ESOFB_CMD_TOGGLE_PROGRESSBAR_SHOWN
        end

        ESOFarmBuddy.RefreshItemList()
        ESOFarmBuddyUtils:ChatMsg(GetString(infoStr))

    elseif toggleCommand == "bonus" then

        if ESOFarmBuddy.SV.Settings.ShowGoalBonus == true then
            ESOFarmBuddy.SV.Settings.ShowGoalBonus = false
            infoStr = ESOFB_CMD_TOGGLE_GOAL_BONUS_HIDDEN
        else
            ESOFarmBuddy.SV.Settings.ShowGoalBonus = true
            infoStr = ESOFB_CMD_TOGGLE_GOAL_BONUS_SHOWN
        end

        ESOFarmBuddy.RefreshItemList()
        ESOFarmBuddyUtils:ChatMsg(GetString(infoStr))

    elseif toggleCommand == "notifications" then

        if ESOFarmBuddy.SV.Settings.ShowGoalNotifications == true then
            ESOFarmBuddy.SV.Settings.ShowGoalNotifications = false
            infoStr = ESOFB_CMD_TOGGLE_NOTIFICATIONS_OFF
        else
            ESOFarmBuddy.SV.Settings.ShowGoalNotifications = true
            infoStr = ESOFB_CMD_TOGGLE_NOTIFICATIONS_ON
        end

        ESOFarmBuddyUtils:ChatMsg(GetString(infoStr))

    elseif toggleCommand == "includebank" then

        if ESOFarmBuddy.SV.Settings.IncludeBank == true then
            ESOFarmBuddySettings.SetIncludeBank(false)
            infoStr = ESOFB_CMD_TOGGLE_INCLUDE_BANK_OFF
        else
            ESOFarmBuddySettings.SetIncludeBank(true)
            infoStr = ESOFB_CMD_TOGGLE_INCLUDE_BANK_ON
        end

        ESOFarmBuddyUtils:ChatMsg(GetString(infoStr))

    elseif toggleCommand == "includecraftbag" then

        if ESOFarmBuddy.SV.Settings.IncludeCraftBag == true then
            ESOFarmBuddySettings.SetIncludeCraftBag(false)
            infoStr = ESOFB_CMD_TOGGLE_INCLUDE_CRAFT_BAG_OFF
        else
            ESOFarmBuddySettings.SetIncludeCraftBag(true)
            infoStr = ESOFB_CMD_TOGGLE_INCLUDE_CRAFT_BAG_ON
        end

        ESOFarmBuddyUtils:ChatMsg(GetString(infoStr))

    elseif toggleCommand == "hide" then

        if ESOFarmBuddy.SV.Settings.HideWindow == true then
            ESOFarmBuddy.SV.Settings.HideWindow = false
            infoStr = ESOFB_CMD_TOGGLE_HIDE_ON
        else
            ESOFarmBuddy.SV.Settings.HideWindow = true
            infoStr = ESOFB_CMD_TOGGLE_HIDE_OFF
        end

        ESOFarmBuddy.ToggleHideWindow(nil)

        ESOFarmBuddyUtils:ChatMsg(GetString(infoStr))

    elseif toggleCommand == "clamptoscreen" then

        if ESOFarmBuddy.SV.Settings.ClampedToScreen == true then
            ESOFarmBuddySettings.SetClampedToScreen(false)
            infoStr = ESOFB_CMD_TOGGLE_CLAMP_TO_SCREEN_OFF
        else
            ESOFarmBuddySettings.SetClampedToScreen(true)
            infoStr = ESOFB_CMD_TOGGLE_CLAMP_TO_SCREEN_ON
        end

        ESOFarmBuddyUtils:ChatMsg(GetString(infoStr))

    elseif toggleCommand == "hidecombat" then

        if ESOFarmBuddy.SV.Settings.HideWindowInCombat == true then
            ESOFarmBuddy.ToggleHideWindowInCombat(false)
            infoStr = ESOFB_CMD_TOGGLE_HIDE_WINDOW_IN_COMBAT_ON
        else
            ESOFarmBuddy.ToggleHideWindowInCombat(true)
            infoStr = ESOFB_CMD_TOGGLE_HIDE_WINDOW_IN_COMBAT_OFF
        end

        ESOFarmBuddyUtils:ChatMsg(GetString(infoStr))

    elseif toggleCommand == "hidedungeon" then

        if ESOFarmBuddy.SV.Settings.HideWindowInDungeonAndTrial == true then
            ESOFarmBuddySettings.SetHideWindowInDungeonAndTrial(false)
            infoStr = ESOFB_CMD_TOGGLE_HIDE_WINDOW_IN_DUNGEON_TRIAL_ON
        else
            ESOFarmBuddySettings.SetHideWindowInDungeonAndTrial(true)
            infoStr = ESOFB_CMD_TOGGLE_HIDE_WINDOW_IN_DUNGEON_TRIAL_OFF
        end

        ESOFarmBuddyUtils:ChatMsg(GetString(infoStr))

    elseif toggleCommand == "hidepvp" then

        if ESOFarmBuddy.SV.Settings.HideWindowInPvP == true then
            ESOFarmBuddySettings.SetHideWindowInPvP(false)
            infoStr = ESOFB_CMD_TOGGLE_HIDE_WINDOW_IN_PVP_ON
        else
            ESOFarmBuddySettings.SetHideWindowInPvP(true)
            infoStr = ESOFB_CMD_TOGGLE_HIDE_WINDOW_IN_PVP_OFF
        end

        ESOFarmBuddyUtils:ChatMsg(GetString(infoStr))

    elseif toggleCommand == "hidehomes" then

        if ESOFarmBuddy.SV.Settings.HideWindowInHomes == true then
            ESOFarmBuddySettings.SetHideWindowInHomes(false)
            infoStr = ESOFB_CMD_TOGGLE_HIDE_WINDOW_IN_HOMES_ON
        else
            ESOFarmBuddySettings.SetHideWindowInHomes(true)
            infoStr = ESOFB_CMD_TOGGLE_HIDE_WINDOW_IN_HOMES_OFF
        end

        ESOFarmBuddyUtils:ChatMsg(GetString(infoStr))

    elseif toggleCommand == "itemname" then

        if ESOFarmBuddy.SV.Settings.ShowItemName == true then
            ESOFarmBuddySettings.SetShowItemName(false)
            infoStr = ESOFB_CMD_TOGGLE_ITEMNAME_OFF
        else
            ESOFarmBuddySettings.SetShowItemName(true)
            infoStr = ESOFB_CMD_TOGGLE_ITEMNAME_ON
        end

        ESOFarmBuddyUtils:ChatMsg(GetString(infoStr))

    elseif toggleCommand == "notificationsound" then

        if ESOFarmBuddy.SV.Settings.PlayGoalNotificationSound == true then
            ESOFarmBuddy.SV.Settings.PlayGoalNotificationSound = false
            infoStr = ESOFB_CMD_TOGGLE_NOTIFICATION_SOUND_OFF
        else
            ESOFarmBuddy.SV.Settings.PlayGoalNotificationSound = true
            infoStr = ESOFB_CMD_TOGGLE_NOTIFICATION_SOUND_ON
        end

        ESOFarmBuddyUtils:ChatMsg(GetString(infoStr))

    else
        ESOFarmBuddyUtils:ChatMsg("|cF10000" .. GetString(ESOFB_CMD_TOGGLE_NO_OPTION) .. "|r")
    end
end

function ESOFarmBuddyCommands.NotificationTestCommand()
    ESOFarmBuddy.NotificationTest()
end

function ESOFarmBuddyCommands.SettingsCommand()
    LibAddonMenu2:OpenToPanel(ESOFarmBuddy.DisplayName)
end

function ESOFarmBuddyCommands.HandleCommand(options)

    if options[1] == "track" then
        ESOFarmBuddyCommands.AddCommand(options[2])
    elseif options[1] == "remove" then
        ESOFarmBuddyCommands.RemoveCommand(options[2])
    elseif options[1] == "goal" then
        ESOFarmBuddyCommands.GoalCommand(options[2], options[3])
    elseif options[1] == "clear" then
        ESOFarmBuddyCommands.ClearCommand()
    elseif options[1] == "toggle" then
        ESOFarmBuddyCommands.ToggleCommand(options[2])
    elseif options[1] == "notificationtest" then
        ESOFarmBuddyCommands.NotificationTestCommand()
    elseif options[1] == "settings" then
        ESOFarmBuddyCommands.SettingsCommand()
    elseif options[1] == "version" then
        ESOFarmBuddyUtils:ChatMsg(string.format(GetString(ESOFB_CMD_VERSION_TEXT), ESOFarmBuddy.AddonVersion))
    else
        ESOFarmBuddyUtils:ChatMsg("|cF10000" .. GetString(ESOFB_CMD_NO_OPTION) .. "|r")
    end
end

function ESOFarmBuddyCommands.Handle(...)

    local optionStr = select(1, ...)
    local options = ESOFarmBuddyUtils:split(optionStr, " ")

    if type(options[1]) == "nil" or options[1] == "" then
        local msg = GetString(ESOFB_HELP_TEXT) .. ":\n"
        msg = msg .. "|c009900/" .. ESOFarmBuddyCommands.ChatCommand .. " track <" .. GetString(ESODB_ITEM_LINK) .. ">|r - " .. GetString(ESOFB_CMD_TRACK) .. "\n"
        msg = msg .. "|c009900/" .. ESOFarmBuddyCommands.ChatCommand .. " remove <" .. GetString(ESODB_ITEM_LINK) .. ">|r - " .. GetString(ESOFB_CMD_REMOVE) .. "\n"
        msg = msg .. "|c009900/" .. ESOFarmBuddyCommands.ChatCommand .. " goal <" .. GetString(ESODB_ITEM_LINK) .. "> <" .. GetString(ESOFB_BONUS_DISPLAY_MODE_COUNT) .. ">|r - " .. GetString(ESOFB_CMD_GOAL) .. "\n"
        msg = msg .. "|c009900/" .. ESOFarmBuddyCommands.ChatCommand .. " clear|r - " .. GetString(ESOFB_CMD_CLEAR) .. "\n"
        msg = msg .. "|c009900/" .. ESOFarmBuddyCommands.ChatCommand .. " toggle lock|r - " .. GetString(ESOFB_CMD_TOGGLE_LOCK) .. "\n"
        msg = msg .. "|c009900/" .. ESOFarmBuddyCommands.ChatCommand .. " toggle title|r - " .. GetString(ESOFB_CMD_TOGGLE_TITLE) .. "\n"
        msg = msg .. "|c009900/" .. ESOFarmBuddyCommands.ChatCommand .. " toggle progressbar|r - " .. GetString(ESOFB_CMD_TOGGLE_PROGRESSBAR) .. "\n"
        msg = msg .. "|c009900/" .. ESOFarmBuddyCommands.ChatCommand .. " toggle bonus|r - " .. GetString(ESOFB_CMD_TOGGLE_GOAL_BONUS) .. "\n"
        msg = msg .. "|c009900/" .. ESOFarmBuddyCommands.ChatCommand .. " toggle notifications|r - " .. GetString(ESOFB_CMD_TOGGLE_NOTIFICATIONS) .. "\n"
        msg = msg .. "|c009900/" .. ESOFarmBuddyCommands.ChatCommand .. " toggle includebank|r - " .. GetString(ESOFB_CMD_TOGGLE_INCLUDE_BANK) .. "\n"
        msg = msg .. "|c009900/" .. ESOFarmBuddyCommands.ChatCommand .. " toggle includecraftbag|r - " .. GetString(ESOFB_CMD_TOGGLE_INCLUDE_CRAFT_BAG) .. "\n"
        msg = msg .. "|c009900/" .. ESOFarmBuddyCommands.ChatCommand .. " toggle hide|r - " .. GetString(ESOFB_CMD_TOGGLE_HIDE) .. "\n"
        msg = msg .. "|c009900/" .. ESOFarmBuddyCommands.ChatCommand .. " toggle clamptoscreen|r - " .. GetString(ESOFB_CMD_TOGGLE_CLAMP_TO_SCREEN) .. "\n"
        msg = msg .. "|c009900/" .. ESOFarmBuddyCommands.ChatCommand .. " toggle hidecombat|r - " .. GetString(ESOFB_CMD_TOGGLE_HIDE_WINDOW_IN_COMBAT) .. "\n"
        msg = msg .. "|c009900/" .. ESOFarmBuddyCommands.ChatCommand .. " toggle hidedungeon|r - " .. GetString(ESOFB_CMD_TOGGLE_HIDE_WINDOW_IN_DUNGEON_TRIAL) .. "\n"
        msg = msg .. "|c009900/" .. ESOFarmBuddyCommands.ChatCommand .. " toggle hidepvp|r - " .. GetString(ESOFB_CMD_TOGGLE_HIDE_WINDOW_IN_PVP) .. "\n"
        msg = msg .. "|c009900/" .. ESOFarmBuddyCommands.ChatCommand .. " toggle hidehomes|r - " .. GetString(ESOFB_CMD_TOGGLE_HIDE_WINDOW_IN_HOMES) .. "\n"
        msg = msg .. "|c009900/" .. ESOFarmBuddyCommands.ChatCommand .. " toggle itemname|r - " .. GetString(ESOFB_CMD_TOGGLE_ITEMNAME) .. "\n"
        msg = msg .. "|c009900/" .. ESOFarmBuddyCommands.ChatCommand .. " toggle notificationsound|r - " .. GetString(ESOFB_CMD_TOGGLE_NOTIFICATION_SOUND) .. "\n"
        msg = msg .. "|c009900/" .. ESOFarmBuddyCommands.ChatCommand .. " notificationtest|r - " .. GetString(ESOFB_CMD_NOTIFICATION_TEST) .. "\n"
        msg = msg .. "|c009900/" .. ESOFarmBuddyCommands.ChatCommand .. " settings|r - " .. GetString(ESOFB_CMD_SETTINGS) .. "\n"
        msg = msg .. "|c009900/" .. ESOFarmBuddyCommands.ChatCommand .. " version|r - " .. GetString(ESOFB_CMD_VERSION) .. "\n"

        ESOFarmBuddyUtils:ChatMsg(msg)
    else
        ESOFarmBuddyCommands.HandleCommand(options)
    end
end