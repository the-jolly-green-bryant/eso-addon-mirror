Junkee = Junkee or {}
Junkee.__index = Junkee
Junkee.name = "Junkee2018"

local LAM = LibAddonMenu2

local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER

-- local INVENTORIES_TO_HOOK = {INVENTORY_BACKPACK, INVENTORY_BANK}
local BAGS_TO_HOOK = {}
BAGS_TO_HOOK[BAG_BACKPACK] = true
BAGS_TO_HOOK[BAG_BANK] = true

Junkee.firstActivation = true -- First time activation event runs.
Junkee.slotControl = nil -- Reference for misc' properties.
Junkee.bagId = nil
Junkee.slotId = nil
Junkee.isJunk = false
Junkee.zoneName = nil -- Track zone name changes.
Junkee.hadZoneChat = nil -- And if there was any zone chat since, to avoid spam.
Junkee.chatWasMinimized = nil

-- Defaults.
Junkee.savedVars = {
    accountWide = true,
    visible = true, -- All items visible.
    DestroyVisible = true,
    LinkVisible = true,
    LockVisible = true,
    firstRun = true,
    copyName = false,
    hideMainQuest = false,
    trackZone = false,
    shortGuildNames = false,
    startInZoneChat = false,
    hideAutoinvites = false,
    playerLinkSendMail = false,
    playerLinkJumpTo = false,
    playerLinkToHouse = false,
    minimizeChatWithInventory = false,
    maximizeChatWithStore = false,
    minimizeChatWithSkills = false,
    inventoryShowAP = false,
    guildsChatAdded = {false, false, false, false, false},
    guildsChatRemoved = {false, false, false, false, false},
    slashCmdsActive = {
        GroupLeave = false,
        GroupDisband = false,
        d = false,
        ToggleDifficulty = false,
        EnterCampaign = false,
        EnterImperialCity = false,
    },
    hideCompassFrame = false,
}

local function LoadCampaignData(f)
    -- If campaigns window was not opened yet, mimic its behavior to load the data.
    if #CAMPAIGN_BROWSER_MANAGER.selectionCampaignList == 0 then
        QueryCampaignSelectionData()

        zo_callLater(
            function()
                if Junkee.RetriedCampaignQueue == 3 then
                    CHAT_SYSTEM:AddMessage('Failed to queue for a campaign.')
                    Junkee.RetriedCampaignQueue = 0
                    return
                end

                Junkee.RetriedCampaignQueue = Junkee.RetriedCampaignQueue + 1

                f()
            end,
            1000
        )

        return
    end

    Junkee.RetriedCampaignQueue = 0

    return true
end

local function LoadQueueForCampaign()
    if not LoadCampaignData(LoadQueueForCampaign) then return end

    Junkee.AssignedCampaignId = GetAssignedCampaignId()
    local campName = GetCampaignName(Junkee.AssignedCampaignId)

    -- EVENT_CAMPAIGN_QUEUE_STATE_CHANGED

    -- GetSelectionCampaignId()
    -- campaignId, isGroup, AcceptCampaignEntry
    -- ConfirmCampaignEntry(Junkee.AssignedCampaignId, false, true)

    QueueForCampaign(Junkee.AssignedCampaignId, false)

    CHAT_SYSTEM:AddMessage(string.format('Queuing for the |cFFFFFF%s|r campaign...', campName))
end

local function LoadQueueForIC()
    if not LoadCampaignData(LoadQueueForIC) then return end

    local campaignList = CAMPAIGN_BROWSER_MANAGER:GetCampaignDataList()

    local campaign
    local campaignName = "CP Imperial City"

    for i=1, #campaignList do
        local campaignData = campaignList[i]

        if campaignData.name == campaignName then
            QueueForCampaign(campaignData.id, false)
            campaign = campaignData
        end
    end

    if campaign then
        CHAT_SYSTEM:AddMessage(string.format('Queuing for the |cFFFFFF%s|r campaign...', campaignName))
    end
end

-- Avoid endless loop.
Junkee.RetriedCampaignQueue = 0

-- Each command name will have "/" prepended to it automatically.
Junkee.slashCmds = {
    GroupLeave = {
        cmd = "/gl",
        f = function()
            if IsUnitGrouped("player") then
                GroupLeave()
            end
        end
    },
    GroupDisband = {
        cmd = "/gd",
        f = function()
            if IsUnitGrouped("player") and IsUnitGroupLeader("player") then
                GroupDisband()
            end
        end
    },
    d = {
        cmd = "/d",
        f = function(text)
            CHAT_SYSTEM:StartTextEntry("/script d(" .. text .. ")")
        end
    },
    ToggleDifficulty = {
        cmd = "/vet",
        f = function()
            -- Check if can change group difficulty.
            if not CanPlayerChangeGroupDifficulty() then
                if IsUnitUsingVeteranDifficulty("player") then
                    CHAT_SYSTEM:AddMessage("Difficulty locked to |cFFFFFFVeteran|r.")
                else
                    CHAT_SYSTEM:AddMessage("Difficulty locked to |cFFFFFFNormal|r.")
                end
                return
            end

            -- Toggle group difficulty.
            -- Mimicks pressing the buttons, as the game relies on this to update the visuals.
            if IsUnitUsingVeteranDifficulty("player") then
                ZO_VeteranDifficultyButton_OnClicked(ZO_GroupListVeteranDifficultySettingsNormalDifficulty)
                CHAT_SYSTEM:AddMessage("Difficulty changed to |cFFFFFFNormal|r.")
            else
                ZO_VeteranDifficultyButton_OnClicked(ZO_GroupListVeteranDifficultySettingsVeteranDifficulty)
                CHAT_SYSTEM:AddMessage("Difficulty changed to |cFFFFFFVeteran|r!")
            end
        end
    },
    EnterCampaign = {
        cmd = "/cyro",
        f = function()
            LoadQueueForCampaign()
        end
    },
    EnterImperialCity = {
        cmd = "/imp",
        f = function()
            LoadQueueForIC()
        end
    },
}

-- Auto-confirm campaign entry from queue.
local function OnCampaignQueueChangedJunkee(eventCode, campaignId)
    if Junkee.AssignedCampaignId then
        ConfirmCampaignEntry(Junkee.AssignedCampaignId, IsPlayerInGroup(), true)
        Junkee.AssignedCampaignId = nil
    end
end
EVENT_MANAGER:RegisterForEvent(Junkee.name, EVENT_CAMPAIGN_QUEUE_STATE_CHANGED, OnCampaignQueueChangedJunkee)

Junkee.OnMouseEnter = function(control)
    Junkee.slotControl = control
    Junkee.bagId = control.dataEntry.data.bagId
    Junkee.slotId = control.dataEntry.data.slotIndex
    Junkee.isJunk = control.dataEntry.data.isJunk
    if Junkee.savedVars.visible then
        Junkee.AddJunkAction()
    end
end

Junkee.OnMouseExit = function(control)
    Junkee.slotControl = nil
    Junkee.bagId = nil
    Junkee.slotId = nil
    Junkee.isJunk = false
    if Junkee.savedVars.visible then
        Junkee.RemoveJunkAction()
    end
end

local function SetCompassFrameHidden(hidden)
    -- Remember original scale.
    if not Junkee.originalCompassFrameScale then
        Junkee.originalCompassFrameScale = ZO_CompassFrame:GetScale()
    end

    if hidden then
        ZO_CompassFrame:SetScale(0)
    else
        ZO_CompassFrame:SetScale(Junkee.originalCompassFrameScale)
    end
end

-- OUTDATED insecure.
-- local function registerHook(inventory)
--     local listView = inventory.listView
--     if listView and listView.dataTypes and listView.dataTypes[1] then
--         local originalCallback = listView.dataTypes[1].setupCallback
--         listView.dataTypes[1].setupCallback = function(rowControl, slot)
--             originalCallback(rowControl, slot)
--             ZO_PreHookHandler(rowControl, "OnMouseEnter", Junkee.OnMouseEnter)
--             ZO_PreHookHandler(rowControl, "OnMouseExit", Junkee.OnMouseExit)
--         end
--     end
-- end

-- local function registerHooks()
--     for _, index in pairs(INVENTORIES_TO_HOOK) do
--         registerHook(PLAYER_INVENTORY.inventories[index])
--     end
-- end

local function createMenu()
    -- Add menu with options.
    Junkee.panelData = {
        type = "panel",
        name = "Junkee 2018",
        displayName = "Junkee Settings",
        registerForRefresh = true,
        registerForDefaults = true
    }

    Junkee.optionsTable = {}

    table.insert(
        Junkee.optionsTable,
        {
            type = "checkbox",
            name = "Account Wide",
            tooltip = "Use the same settings throughout the entire account - instead of per character.",
            getFunc = function()
                return Junkee.savedVars.accountWide
            end,
            setFunc = function(v)
                Junkee.characterSavedVars.accountWide = v
                Junkee.accountSavedVars.accountWide = v
            end,
            width = "full", --or "half",
            requiresReload = true,
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "checkbox",
            name = "Display Keybindings",
            tooltip = "Display the addon's keybindings when opening the Inventory. " .. "They appear on the bottom left.",
            getFunc = function()
                return Junkee.savedVars.visible
            end,
            setFunc = function(v)
                Junkee.savedVars.visible = v
            end,
            width = "full" --or "half",
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "checkbox",
            name = "Display the Destroy Keybinding",
            tooltip = "Display the addon's keybinding for Destroy when opening the Inventory.",
            getFunc = function()
                return Junkee.savedVars.visible and Junkee.savedVars.DestroyVisible
            end,
            setFunc = function(v)
                Junkee.savedVars.DestroyVisible = v
            end,
            width = "full" --or "half",
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "checkbox",
            name = "Display the Link Keybinding",
            tooltip = "Display the addon's keybinding for Link when opening the Inventory.",
            getFunc = function()
                return Junkee.savedVars.visible and Junkee.savedVars.LinkVisible
            end,
            setFunc = function(v)
                Junkee.savedVars.LinkVisible = v
            end,
            width = "full" --or "half",
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "checkbox",
            name = "Display the Lock Keybinding",
            tooltip = "Display the addon's keybinding for Lock when opening the Inventory.",
            getFunc = function()
                return Junkee.savedVars.visible and Junkee.savedVars.LockVisible
            end,
            setFunc = function(v)
                Junkee.savedVars.LockVisible = v
            end,
            width = "full" --or "half",
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "header",
            name = "Extra Settings",
            width = "full",	--or "half" (optional)
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "checkbox",
            name = Junkee.slashCmds["GroupLeave"].cmd,
            tooltip = "Chat command to leave your group.",
            getFunc = function()
                return Junkee.savedVars.slashCmdsActive["GroupLeave"]
            end,
            setFunc = function(v)
                local cmd = Junkee.slashCmds["GroupLeave"].cmd

                Junkee.savedVars.slashCmdsActive["GroupLeave"] = v
                if v then
                    SLASH_COMMANDS[cmd] = Junkee.slashCmds["GroupLeave"].f
                else
                    SLASH_COMMANDS[cmd] = nil
                end
                -- Reset autocomplete cache to update it.
                CHAT_SYSTEM.textEntry.slashCommandAutoComplete:InvalidateSlashCommandCache()
            end,
            width = "full" --or "half",
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "checkbox",
            name = Junkee.slashCmds["GroupDisband"].cmd,
            tooltip = "Chat command to disband your group.",
            getFunc = function()
                return Junkee.savedVars.slashCmdsActive["GroupDisband"]
            end,
            setFunc = function(v)
                local cmd = Junkee.slashCmds["GroupDisband"].cmd

                Junkee.savedVars.slashCmdsActive["GroupDisband"] = v
                if v then
                    SLASH_COMMANDS[cmd] = Junkee.slashCmds["GroupDisband"].f
                else
                    SLASH_COMMANDS[cmd] = nil
                end
                -- Reset autocomplete cache to update it.
                CHAT_SYSTEM.textEntry.slashCommandAutoComplete:InvalidateSlashCommandCache()
            end,
            width = "full" --or "half",
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "checkbox",
            name = Junkee.slashCmds["d"].cmd,
            tooltip = "Chat command to automatically replace /d CMD with /script d(CMD).",
            getFunc = function()
                return Junkee.savedVars.slashCmdsActive["d"]
            end,
            setFunc = function(v)
                local cmd = Junkee.slashCmds["d"].cmd

                Junkee.savedVars.slashCmdsActive["d"] = v
                if v then
                    SLASH_COMMANDS[cmd] = Junkee.slashCmds["d"].f
                else
                    SLASH_COMMANDS[cmd] = nil
                end
                -- Reset autocomplete cache to update it.
                CHAT_SYSTEM.textEntry.slashCommandAutoComplete:InvalidateSlashCommandCache()
            end,
            width = "full"
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "checkbox",
            name = Junkee.slashCmds["ToggleDifficulty"].cmd,
            tooltip = "Chat command to toggle the dungeon or trial difficulty mode.",
            getFunc = function()
                return Junkee.savedVars.slashCmdsActive["ToggleDifficulty"]
            end,
            setFunc = function(v)
                local cmd = Junkee.slashCmds["ToggleDifficulty"].cmd

                Junkee.savedVars.slashCmdsActive["ToggleDifficulty"] = v
                if v then
                    SLASH_COMMANDS[cmd] = Junkee.slashCmds["ToggleDifficulty"].f
                else
                    SLASH_COMMANDS[cmd] = nil
                end
                -- Reset autocomplete cache to update it.
                CHAT_SYSTEM.textEntry.slashCommandAutoComplete:InvalidateSlashCommandCache()
            end,
            width = "full"
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "checkbox",
            name = Junkee.slashCmds["EnterCampaign"].cmd,
            tooltip = "Chat command to enter your assigned home campaign.",
            getFunc = function()
                return Junkee.savedVars.slashCmdsActive["EnterCampaign"]
            end,
            setFunc = function(v)
                local cmd = Junkee.slashCmds["EnterCampaign"].cmd

                Junkee.savedVars.slashCmdsActive["EnterCampaign"] = v
                if v then
                    SLASH_COMMANDS[cmd] = Junkee.slashCmds["EnterCampaign"].f
                else
                    SLASH_COMMANDS[cmd] = nil
                end
                -- Reset autocomplete cache to update it.
                CHAT_SYSTEM.textEntry.slashCommandAutoComplete:InvalidateSlashCommandCache()
            end,
            width = "full"
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "checkbox",
            name = Junkee.slashCmds["EnterImperialCity"].cmd,
            tooltip = "Chat command to enter the CP Imperial City campaign.",
            getFunc = function()
                return Junkee.savedVars.slashCmdsActive["EnterImperialCity"]
            end,
            setFunc = function(v)
                local cmd = Junkee.slashCmds["EnterImperialCity"].cmd

                Junkee.savedVars.slashCmdsActive["EnterImperialCity"] = v
                if v then
                    SLASH_COMMANDS[cmd] = Junkee.slashCmds["EnterImperialCity"].f
                else
                    SLASH_COMMANDS[cmd] = nil
                end
                -- Reset autocomplete cache to update it.
                CHAT_SYSTEM.textEntry.slashCommandAutoComplete:InvalidateSlashCommandCache()
            end,
            width = "full"
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "checkbox",
            name = "Name in Chat",
            tooltip = "Middle-Mouse clicking an item in your inventory, mail, or a chat link or player name, " ..
                "will copy it into the chat and select it - for quick copying.",
            getFunc = function()
                return Junkee.savedVars.copyName
            end,
            setFunc = function(v)
                Junkee.savedVars.copyName = v
            end,
            width = "full"
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "checkbox",
            name = "Hide Main Quest",
            tooltip = "Hides the Main Quest from the Journal.",
            getFunc = function()
                return Junkee.savedVars.hideMainQuest
            end,
            setFunc = function(v)
                Junkee.savedVars.hideMainQuest = v
                -- Apply change now. Reload all quests, in case we're adding them back.
                QUEST_JOURNAL_KEYBOARD:RefreshQuestMasterList()
                QUEST_JOURNAL_KEYBOARD:RefreshQuestList()

                if v then
                    FOCUSED_QUEST_TRACKER.fragment:Hide()
                else
                    FOCUSED_QUEST_TRACKER.fragment:Show()
                end
            end,
            width = "full"
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "checkbox",
            name = "Track Zone Changes",
            tooltip = "Informs the player when the zone-chat has changed (only after any chatter - to reduce spam.)",
            getFunc = function()
                return Junkee.savedVars.trackZone
            end,
            setFunc = function(v)
                Junkee.savedVars.trackZone = v
            end,
            width = "full"
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "checkbox",
            name = "Short Guild Names",
            tooltip = "Shortens the guild names in your chat into their abbreviations.",
            getFunc = function()
                return Junkee.savedVars.shortGuildNames
            end,
            setFunc = function(v)
                Junkee.savedVars.shortGuildNames = v
            end,
            width = "full"
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "checkbox",
            name = "Start in Zone Chat",
            tooltip = "After logging in, the chat will start in /zone chat instead of the default /say.",
            getFunc = function()
                return Junkee.savedVars.startInZoneChat
            end,
            setFunc = function(v)
                Junkee.savedVars.startInZoneChat = v
            end,
            width = "full"
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "checkbox",
            name = "Hide AutoInvites in Zone Chat",
            tooltip = "Hides Zone messages that are one character long, such as 'x' or 'y'. (Disabled if AutoInvite is Enabled!)",
            getFunc = function()
                return Junkee.savedVars.hideAutoinvites
            end,
            setFunc = function(v)
                Junkee.savedVars.hideAutoinvites = v
            end,
            width = "full"
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "checkbox",
            name = GetString(SI_SOCIAL_MENU_SEND_MAIL),
            tooltip = "When right-clicking a player link in the chat, adds an option to mail them.",
            getFunc = function()
                return Junkee.savedVars.playerLinkSendMail
            end,
            setFunc = function(v)
                Junkee.savedVars.playerLinkSendMail = v
            end,
            width = "full"
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "checkbox",
            name = GetString(SI_SOCIAL_MENU_VISIT_HOUSE),
            tooltip = "When right-clicking a player link in the chat, adds an option to visit their primary house.",
            getFunc = function()
                return Junkee.savedVars.playerLinkToHouse
            end,
            setFunc = function(v)
                Junkee.savedVars.playerLinkToHouse = v
            end,
            width = "full"
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "checkbox",
            name = "Minimize Chat with Inventory",
            tooltip = "The chat window will minimize when opening the player inventory, and restore to its previous state when closed.",
            getFunc = function()
                return Junkee.savedVars.minimizeChatWithInventory
            end,
            setFunc = function(v)
                Junkee.savedVars.minimizeChatWithInventory = v
            end,
            width = "full"
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "checkbox",
            name = "Maximize Chat with Store",
            tooltip = "The chat window will maximize when opening a store, and restore to its previous state when closed.",
            getFunc = function()
                return Junkee.savedVars.maximizeChatWithStore
            end,
            setFunc = function(v)
                Junkee.savedVars.maximizeChatWithStore = v
            end,
            width = "full"
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "checkbox",
            name = "Minimize Chat with Skills",
            tooltip = "The chat window will minimize when opening the player skills, and restore to its previous state when closed.",
            getFunc = function()
                return Junkee.savedVars.minimizeChatWithSkills
            end,
            setFunc = function(v)
                Junkee.savedVars.minimizeChatWithSkills = v
            end,
            width = "full"
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "checkbox",
            name = "Display AP In Inventory",
            tooltip = "Whenever the secondary currency slot isn't used, Alliance Points will be shown under Gold.",
            getFunc = function()
                return Junkee.savedVars.inventoryShowAP
            end,
            setFunc = function(v)
                Junkee.savedVars.inventoryShowAP = v
            end,
            width = "full"
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "checkbox",
            name = "Hide Compass",
            tooltip = "Toggle the Compass frame to not show.",
            getFunc = function()
                return Junkee.savedVars.hideCompassFrame
            end,
            setFunc = function(v)
                Junkee.savedVars.hideCompassFrame = v
                SetCompassFrameHidden(v)
            end,
            width = "full"
        }
    )

    table.insert(
        Junkee.optionsTable,
        {
            type = "submenu",
            name = "Guild Chat Notifications",
            controls = {
                [1] = {
                    type = "checkbox",
                    name = "Member Joined " .. GetGuildName(GetGuildId(1)),
                    tooltip = "Display a notification in the chat, when a player has joined the guild.",
                    getFunc = function()
                        return Junkee.savedVars.guildsChatAdded[1]
                    end,
                    setFunc = function(v)
                        Junkee.savedVars.guildsChatAdded[1] = v
                    end,
                    width = "full"
                },
                [2] = {
                    type = "checkbox",
                    name = "Member Joined " .. GetGuildName(GetGuildId(2)),
                    tooltip = "Display a notification in the chat, when a player has joined the guild.",
                    getFunc = function()
                        return Junkee.savedVars.guildsChatAdded[2]
                    end,
                    setFunc = function(v)
                        Junkee.savedVars.guildsChatAdded[2] = v
                    end,
                    width = "full"
                },
                [3] = {
                    type = "checkbox",
                    name = "Member Joined " .. GetGuildName(GetGuildId(3)),
                    tooltip = "Display a notification in the chat, when a player has joined the guild.",
                    getFunc = function()
                        return Junkee.savedVars.guildsChatAdded[3]
                    end,
                    setFunc = function(v)
                        Junkee.savedVars.guildsChatAdded[3] = v
                    end,
                    width = "full"
                },
                [4] = {
                    type = "checkbox",
                    name = "Member Joined " .. GetGuildName(GetGuildId(4)),
                    tooltip = "Display a notification in the chat, when a player has joined the guild.",
                    getFunc = function()
                        return Junkee.savedVars.guildsChatAdded[4]
                    end,
                    setFunc = function(v)
                        Junkee.savedVars.guildsChatAdded[4] = v
                    end,
                    width = "full"
                },
                [5] = {
                    type = "checkbox",
                    name = "Member Joined " .. GetGuildName(GetGuildId(5)),
                    tooltip = "Display a notification in the chat, when a player has joined the guild.",
                    getFunc = function()
                        return Junkee.savedVars.guildsChatAdded[5]
                    end,
                    setFunc = function(v)
                        Junkee.savedVars.guildsChatAdded[5] = v
                    end,
                    width = "full"
                },
                [6] = {
                    type = "divider",
                    width = "full",
                    height = 10,
                    alpha = 0.25,
                },
                [7] = {
                    type = "checkbox",
                    name = "Member Left " .. GetGuildName(GetGuildId(1)),
                    tooltip = "Display a notification in the chat, when a player has left the guild.",
                    getFunc = function()
                        return Junkee.savedVars.guildsChatRemoved[1]
                    end,
                    setFunc = function(v)
                        Junkee.savedVars.guildsChatRemoved[1] = v
                    end,
                    width = "full"
                },
                [8] = {
                    type = "checkbox",
                    name = "Member Left " .. GetGuildName(GetGuildId(2)),
                    tooltip = "Display a notification in the chat, when a player has left the guild.",
                    getFunc = function()
                        return Junkee.savedVars.guildsChatRemoved[2]
                    end,
                    setFunc = function(v)
                        Junkee.savedVars.guildsChatRemoved[2] = v
                    end,
                    width = "full"
                },
                [9] = {
                    type = "checkbox",
                    name = "Member Left " .. GetGuildName(GetGuildId(3)),
                    tooltip = "Display a notification in the chat, when a player has left the guild.",
                    getFunc = function()
                        return Junkee.savedVars.guildsChatRemoved[3]
                    end,
                    setFunc = function(v)
                        Junkee.savedVars.guildsChatRemoved[3] = v
                    end,
                    width = "full"
                },
                [10] = {
                    type = "checkbox",
                    name = "Member Left " .. GetGuildName(GetGuildId(4)),
                    tooltip = "Display a notification in the chat, when a player has left the guild.",
                    getFunc = function()
                        return Junkee.savedVars.guildsChatRemoved[4]
                    end,
                    setFunc = function(v)
                        Junkee.savedVars.guildsChatRemoved[4] = v
                    end,
                    width = "full"
                },
                [11] = {
                    type = "checkbox",
                    name = "Member Left " .. GetGuildName(GetGuildId(5)),
                    tooltip = "Display a notification in the chat, when a player has left the guild.",
                    getFunc = function()
                        return Junkee.savedVars.guildsChatRemoved[5]
                    end,
                    setFunc = function(v)
                        Junkee.savedVars.guildsChatRemoved[5] = v
                    end,
                    width = "full"
                },
            },
        }
    )
end

local function LoadMenu()
    createMenu()
    LAM:RegisterAddonPanel("Junkee 2018", Junkee.panelData)
    LAM:RegisterOptionControls("Junkee 2018", Junkee.optionsTable)
end

Junkee.JunkIt = function()
    if Junkee.bagId == nil then
        return
    end
    local isJunk = IsItemJunk(Junkee.bagId, Junkee.slotId)
    SetItemIsJunk(Junkee.bagId, Junkee.slotId, not isJunk)
    if isJunk then
        PlaySound(SOUNDS.INVENTORY_ITEM_UNJUNKED)
    else
        PlaySound(SOUNDS.INVENTORY_ITEM_JUNKED)
    end
end

Junkee.DeleteIt = function()
    if Junkee.bagId == nil then
        return
    end
    DestroyItem(Junkee.bagId, Junkee.slotId)
end

local function createJunkStripDescriptor(name)
    return JunkeeKeyStrip:New(name, "JUNKEE_JUNK_IT", Junkee.JunkIt)
end

local junkStripDescriptor = createJunkStripDescriptor(Junkee.tr("JunkLabel"))
local unjunkStripDescriptor = createJunkStripDescriptor(Junkee.tr("UnjunkLabel"))
local deleteStripDescriptor = JunkeeKeyStrip:New(Junkee.tr("DeleteLabel"), "JUNKEE_DELETE_IT", Junkee.DeleteIt)
local linkStripDescriptor = JunkeeKeyStrip:New(Junkee.tr("LinkLabel"), "JUNKEE_LINK_IT", Junkee.LinkIt)
local lockStripDescriptor = JunkeeKeyStrip:New(Junkee.tr("LockLabel"), "JUNKEE_LOCK_IT", Junkee.LockIt)

Junkee.AddJunkAction = function()
    if (Junkee.isJunk) then
        junkStripDescriptor:Remove()
        unjunkStripDescriptor:Add(true)
    else
        unjunkStripDescriptor:Remove()
        junkStripDescriptor:Add(true)
    end

    if Junkee.savedVars.DestroyVisible then
        deleteStripDescriptor:Add(true)
    end
    if Junkee.savedVars.LinkVisible then
        linkStripDescriptor:Add(true)
    end
    if Junkee.savedVars.LockVisible then
        lockStripDescriptor:Add(true)
    end
end

Junkee.RemoveJunkAction = function()
    unjunkStripDescriptor:Remove()
    junkStripDescriptor:Remove()

    deleteStripDescriptor:Remove()
    linkStripDescriptor:Remove()
    lockStripDescriptor:Remove()
end

-- Link item in chat.
Junkee.LinkIt = function()
    if Junkee.bagId == nil then
        return
    end

    local link = GetItemLink(Junkee.bagId, Junkee.slotId, 1)
    ZO_LinkHandler_InsertLink(link)
end

-- Un/Lock item.
Junkee.LockIt = function()
    if Junkee.bagId == nil then
        return
    end

    local bag, index = Junkee.bagId, Junkee.slotId
    local locking = not IsItemPlayerLocked(bag, index) -- The locking state to apply.
    if CanItemBePlayerLocked(bag, index) then
        SetItemIsPlayerLocked(bag, index, locking)
        PlaySound(not locking and SOUNDS.INVENTORY_ITEM_LOCKED or SOUNDS.INVENTORY_ITEM_UNLOCKED)
    end

    -- Below is taken from the game code for locking.
    -- IsItemAlreadySlottedToCraft() errors,
    -- so until that's solved I use the above code. Reference:
    -- http://www.esoui.com/forums/showthread.php?p=34500

    -- local inventorySlot = Junkee.slotControl
    -- local bag, index = Junkee.bagId, Junkee.slotId -- ZO_Inventory_GetBagAndIndex(inventorySlot)
    -- local locking = not IsItemPlayerLocked(bag, index) -- The locking state to apply.
    -- local action

    -- if locking then
    --     action = SI_ITEM_ACTION_MARK_AS_LOCKED
    --     -- Can't lock these.
    --     if IsItemAlreadySlottedToCraft(inventorySlot) then return end
    -- else
    --     action = SI_ITEM_ACTION_UNMARK_AS_LOCKED
    -- end

    --    if CanItemBePlayerLocked(bag, index) and
    --        not QUICKSLOT_WINDOW:AreQuickSlotsShowing() then
    --        slotActions:AddSlotAction(action,
    --            function() MarkAsPlayerLockedHelper(bag, index, locking) end,
    --            "secondary")
    --    end
end

-- Toggle character or user name displayed in Nameplates.
Junkee.ToggleDisplayName = function()
    local state = GetSetting(SETTING_TYPE_UI, UI_SETTING_PRIMARY_PLAYER_NAME_KEYBOARD)

    -- Flip
    state = 1 - state

    SetSetting(SETTING_TYPE_UI, UI_SETTING_PRIMARY_PLAYER_NAME_KEYBOARD, state)
end

-- Needed to bind CTRL/Shift+KEY.
function KEYBINDING_MANAGER:IsChordingAlwaysEnabled()
    return true
end

ZO_CreateStringId("SI_BINDING_NAME_JUNKEE_JUNK_IT", Junkee.tr("JunkBindingName"))
ZO_CreateStringId("SI_BINDING_NAME_JUNKEE_DELETE_IT", Junkee.tr("DeleteBindingName"))
ZO_CreateStringId("SI_BINDING_NAME_JUNKEE_LINK_IT", Junkee.tr("LinkBindingName"))
ZO_CreateStringId("SI_BINDING_NAME_JUNKEE_LOCK_IT", Junkee.tr("LockBindingName"))
ZO_CreateStringId("SI_BINDING_NAME_JUNKEE_TOGGLE_DISPLAY_NAME", Junkee.tr("DisplayNameBindingName"))

ZO_CreateStringId("SI_BINDING_NAME_JUNKEE_COPY_NAME", "Name in Chat")

-- Copies text to chat inputbox and selects it, for quick copying.
local function CopyToChatInput(text)
    CHAT_SYSTEM:StartTextEntry(text)
    ZO_ChatWindowTextEntryEditBox:SelectAll()
end

-- Get formatted item name from slot.
local function SlotToName(inventorySlot)
    local bag, index = ZO_Inventory_GetBagAndIndex(inventorySlot)

    if index and bag then
        -- Some slot items require formatting. Taking this from game code:
        -- https://esodata.uesp.net/100017/src/ingame/crafting/craftinginventory.lua.html#192
        return GetItemName(bag, index)
    end
end

-- Some cases return the row, so get the name from that.
local function RowToName(inventorySlot)
    if inventorySlot.dataEntry then
        return inventorySlot.dataEntry.data.name
    end
end

-- Find the matching slot index in list.
local function AttachmentToName(inventorySlot)
    local link =
        GetAttachedItemLink(MAIL_INBOX:GetOpenMailId(), ZO_Inventory_GetSlotIndex(inventorySlot), LINK_STYLE_DEFAULT)
    if link then
        return GetItemLinkName(link)
    end
end

-- Add middle-mouse button to click listener.
local function AddMiddleMouseButton(slotControl, stackCount, iconFile, meetsUsageRequirement, locked)
    -- Patch for mail items, or any Control really.
    slotControl:EnableMouseButton(MOUSE_BUTTON_INDEX_MIDDLE, true)
end

-- Middle mouse copies item name to chat.
local function MiddleMouseCopiesNameToChat(inventorySlot, button)
    -- Disabled.
    if not Junkee.savedVars.copyName then return end

    -- Middle mouse button.
    if button == MOUSE_BUTTON_INDEX_MIDDLE then
        -- Rows.
        local name = RowToName(inventorySlot)
        -- Slots.
        if not name then
            name = SlotToName(inventorySlot)
        end
        -- Mail attachments.
        if not name then
            name = AttachmentToName(inventorySlot)
        end

        -- Silent failure.
        if name then
            name = zo_strformat(SI_TOOLTIP_ITEM_NAME, name)
            CopyToChatInput(name)

        -- DEBUG open link in TTC?
        -- GetItemLinkQuality()
        -- GetItemLinkInfo()
        -- GetItemLinkItemId()
        -- GetItemLinkItemStyle()
        -- GetItemLinkRequiredLevel()
        -- ...

        -- RequestOpenUnsafeURL()
        end
    end
end

-- Hides the Main Quest category from the Journal.
local function HideMainQuest()
    -- Disabled.
    if not Junkee.savedVars.hideMainQuest then
        return
    end

    -- Quests.
    local remove = {}

    for i = 1, #QUEST_JOURNAL_KEYBOARD.questMasterList.quests do
        if QUEST_JOURNAL_KEYBOARD.questMasterList.quests[i].categoryName == "Main Quest" then
            table.insert(remove, i)
        end
    end
    -- Remove matches.
    for i = 1, #remove do
        table.remove(QUEST_JOURNAL_KEYBOARD.questMasterList.quests, remove[i])
    end

    -- Quest Categories.
    remove = {}

    for i = 1, #QUEST_JOURNAL_KEYBOARD.questMasterList.categories do
        if QUEST_JOURNAL_KEYBOARD.questMasterList.categories[i].name == "Main Quest" then
            table.insert(remove, i)
        end
    end
    -- Remove matches.
    for i = 1, #remove do
        table.remove(QUEST_JOURNAL_KEYBOARD.questMasterList.categories, remove[i])
    end
end

-- Pre-hook main quest from journal.
local function PreHookMainQuest()
    ZO_PreHook(QUEST_JOURNAL_KEYBOARD, "RefreshQuestList", HideMainQuest)
    -- Apply.
    QUEST_JOURNAL_KEYBOARD:RefreshQuestList()

    -- Hide in Quest Tracker.
    ZO_PreHook(FOCUSED_QUEST_TRACKER.fragment, "OnShown", function()
        -- Disabled.
        if not Junkee.savedVars.hideMainQuest then
            return
        end

        local index = FOCUSED_QUEST_TRACKER.tracked[1]:GetJournalIndex()
        if (index and GetJournalQuestType(index) == QUEST_TYPE_MAIN_STORY) then
            -- d(FOCUSED_QUEST_TRACKER.assistedData:GetJournalIndex(), GetJournalQuestType(FOCUSED_QUEST_TRACKER.assistedData:GetJournalIndex()))
            -- FOCUSED_QUEST_TRACKER.fragment:Hide()
            FOCUSED_QUEST_TRACKER:ClearTracker() -- Keeps it cleared until another quest is selected.
        end
    end)
end

-- Track zone chat messages.
local function TrackChat(messageType, fromName, text, isFromCustomerService, fromDisplayName)
    -- Zone chat tracker.
    if not Junkee.hadZoneChat and messageType == CHAT_CHANNEL_ZONE then
        Junkee.hadZoneChat = true
    end

    -- Hide AutoInvite posts in zone. It's usually "x" or "y", so this is close enough.
    if Junkee.savedVars.hideAutoinvites and messageType == CHAT_CHANNEL_ZONE and #text:gsub("%s+", "") == 1 then
        -- Display the message if AutoInvite is active.
        if AutoInvite and AutoInvite.enabled then
            return
        end

        return true
    end
end

local function LinkHandler_OnLinkMouseUp(link, button, _, _, linkType, ...)
    -- Disabled.
    if not Junkee.savedVars.copyName then
        return
    end

    if
        button == MOUSE_BUTTON_INDEX_MIDDLE and linkType == ITEM_LINK_TYPE and type(link) == "string" and #link > 0 and
            link ~= ""
     then
        CopyToChatInput(GetItemLinkName(link))
    end
end

-- Overrides the game function, for guild channels.
-- TODO don't repeat this every time, but just update a table with abbreviations on guild changes and load.
local OriginalCreateChannelLink = _G["ZO_LinkHandler_CreateChannelLink"]
local GuildNameAbbreviations = {}
local function CreateChannelLink(channelName)
    -- Disabled.
    if not Junkee.savedVars.shortGuildNames then
        return OriginalCreateChannelLink(channelName)
    end

    local name = channelName

    -- 12 to 16.
    for i = CHAT_CHANNEL_GUILD_1, CHAT_CHANNEL_GUILD_5 do
        if GetChannelName(i) == channelName then
            if GuildNameAbbreviations[i] then
                -- Already made an abbr for it.
                name = GuildNameAbbreviations[i]
            else
                -- Get only the intials and special characters. Remove the spaces.
                name = name:gsub("(%w)%w+", "%1"):gsub("%s", "")
                -- Save it.
                GuildNameAbbreviations[i] = name
            end
        end
    end

    -- Only change the appearance, not the data.
    return ZO_LinkHandler_CreateLink(name, nil, CHANNEL_LINK_TYPE, channelName)
end

local function ClearGuildNameAbbreviations()
    GuildNameAbbreviations = {}
end

EM:RegisterForEvent("GuildRoster", EVENT_GUILD_SELF_JOINED_GUILD, function() ClearGuildNameAbbreviations() end)
EM:RegisterForEvent("GuildRoster", EVENT_GUILD_SELF_LEFT_GUILD, function() ClearGuildNameAbbreviations() end)

local function TrackZone()
    local zone = GetUnitZone("player")

    if zone ~= Junkee.zoneName then
        if not Junkee.zoneName then
            -- First load. No verbose.
            Junkee.zoneName = zone
        else
            -- Avoid spamming the chatbox,
            -- so only verbose if any zone chat activity found.
            if Junkee.hadZoneChat then
                -- Print system message with the color of /zone chat.
                local r, g, b = GetChatCategoryColor(CHAT_CATEGORY_ZONE)
                local itemColor = ZO_ColorDef:New(r, g, b, 1)
                local msg =
                    "|t16:16:esoui/art/buttons/large_leftarrow_up.dds|t" ..
                    itemColor:Colorize(ZO_CachedStrFormat(SI_ZONE_NAME, zone)) .. "|t16:16:esoui/art/buttons/large_rightarrow_up.dds|t"

                -- msg = itemColor:Colorize(msg)
                CHAT_SYSTEM:AddMessage(msg)
            end

            -- Update zone tracker.
            Junkee.zoneName = zone
            Junkee.hadZoneChat = nil
        end
    end
end

-- local OriginalShowPlayerContextMenu = CHAT_SYSTEM.ShowPlayerContextMenu
local function AddToShowPlayerContextMenu(playerName, rawName)
    -- Run the original function.
    -- d(playerName, rawName)
    -- OriginalShowPlayerContextMenu(self, playerName, rawName)

    if Junkee.savedVars.playerLinkSendMail then
        AddMenuItem(
            GetString(SI_SOCIAL_MENU_SEND_MAIL),
            function()
                MAIN_MENU_KEYBOARD:Hide() -- In case it's open. Necessary!
                MAIN_MENU_KEYBOARD:ShowScene("mailSend")

                SCENE_MANAGER:CallWhen(
                    "mailSend",
                    SCENE_SHOWN,
                    function()
                        MAIL_SEND.to:SetText(playerName)
                        MAIL_SEND.subject:TakeFocus()
                    end
                )
            end
        )

        -- Update menu dimensions.
        ZO_Menu:SetDimensions(
            (ZO_Menu.menuPad * 2) + ZO_Menu.width,
            (ZO_Menu.menuPad * 2) + ZO_Menu.height + ZO_Menu.spacing * (#ZO_Menu.items - 1)
        )

        -- Update item dimensions.
        local item = ZO_Menu.items[#ZO_Menu.items].item
        item:SetDimensions(ZO_Menu.width, item.storedHeight)
    end

    if Junkee.savedVars.playerLinkToHouse then
        AddMenuItem(
            GetString(SI_SOCIAL_MENU_VISIT_HOUSE),
            function()
                JumpToHouse(playerName)
            end
        )

        -- Update menu dimensions.
        ZO_Menu:SetDimensions(
            (ZO_Menu.menuPad * 2) + ZO_Menu.width,
            (ZO_Menu.menuPad * 2) + ZO_Menu.height + ZO_Menu.spacing * (#ZO_Menu.items - 1)
        )

        -- Update item dimensions.
        local item = ZO_Menu.items[#ZO_Menu.items].item
        item:SetDimensions(ZO_Menu.width, item.storedHeight)
    end
end

-- Toggle chat display with different UI scene windows.
local function toggleChatWith()
    local inventoryScene = SCENE_MANAGER:GetScene("inventory")
    -- hidden, showing - showing, shown
    inventoryScene:RegisterCallback("StateChange", function(oldState, newState)
        -- Disabled.
        if not Junkee.savedVars.minimizeChatWithInventory then return end

        if newState == 'shown' then
            CHAT_SYSTEM:Minimize()
        elseif newState == 'showing' then
            -- Track original chat state.
            Junkee.chatWasMinimized = CHAT_SYSTEM.isMinimized
        elseif newState == 'hidden' then
            if not Junkee.chatWasMinimized then
                -- Restore chat.
                CHAT_SYSTEM:Maximize()
            end
        end
    end)

    local storeScene = SCENE_MANAGER:GetScene("store")
    -- hidden, showing - showing, shown
    storeScene:RegisterCallback("StateChange", function(oldState, newState)
        -- Disabled.
        if not Junkee.savedVars.maximizeChatWithStore then return end

        if newState == 'shown' then
            CHAT_SYSTEM:Maximize()
        elseif newState == 'showing' then
            -- Track original chat state.
            Junkee.chatWasMinimized = CHAT_SYSTEM.isMinimized
        elseif newState == 'hidden' then
            if Junkee.chatWasMinimized then
                -- Restore chat.
                CHAT_SYSTEM:Minimize()
            end
        end
    end)

    local inventoryScene = SCENE_MANAGER:GetScene("skills")
    -- hidden, showing - showing, shown
    inventoryScene:RegisterCallback("StateChange", function(oldState, newState)
        -- Disabled.
        if not Junkee.savedVars.minimizeChatWithSkills then return end

        if newState == 'shown' then
            CHAT_SYSTEM:Minimize()
        elseif newState == 'showing' then
            -- Track original chat state.
            Junkee.chatWasMinimized = CHAT_SYSTEM.isMinimized
        elseif newState == 'hidden' then
            if not Junkee.chatWasMinimized then
                -- Restore chat.
                CHAT_SYSTEM:Maximize()
            end
        end
    end)
end

-- Displays a notification in chat, according to event.
local function guildsNotify(guildId, displayName, characterName, event)
    -- Get guild local index.
    local index
    for i = 1, GetNumGuilds() do
        if GetGuildId(i) == guildId then
            index = i
        end
    end

    local guildName = GetGuildName(guildId)
    local name = ZO_FormatUserFacingDisplayName(displayName)

    local character = ''
    if characterName then
        character = string.format(' (|cFFFF96%s|r)', zo_strformat(SI_UNIT_NAME, characterName))
    end

    -- Notification enabled for guild.
    if event == EVENT_GUILD_MEMBER_ADDED then
        if Junkee.savedVars.guildsChatAdded[index] then
            CHAT_SYSTEM:AddMessage(string.format("%s%s |cFFFFFFhas joined|r %s.", name, character, guildName))
        end
    elseif event == EVENT_GUILD_MEMBER_REMOVED then
        if Junkee.savedVars.guildsChatRemoved[index] then
            CHAT_SYSTEM:AddMessage(string.format("%s%s |cFFFFFFhas left|r %s.", name, character, guildName))
        end
    end
end

local function ExtraOnLinkClicked(self, link, button, text, color, linkType, ...)
    -- Disabled.
    if not Junkee.savedVars.copyName then return end

    if linkType == CHARACTER_LINK_TYPE then
        local rawName = select(1, ...)
        local characterName = zo_strformat(SI_UNIT_NAME, rawName)

        if button ~= MOUSE_BUTTON_INDEX_MIDDLE then return end

        CopyToChatInput(characterName)

        return true
    elseif linkType == DISPLAY_NAME_LINK_TYPE then
        local displayName = ...
        local decoratedDisplayName = zo_strformat("<<1>>", DecorateDisplayName(displayName))

        if button ~= MOUSE_BUTTON_INDEX_MIDDLE then return end

        CopyToChatInput(decoratedDisplayName)

        return true
    -- elseif linkType == CHANNEL_LINK_TYPE then
    --     local channelName = ...

    --     if button ~= MOUSE_BUTTON_INDEX_MIDDLE then return end

    --     CopyToChatInput(channelName)

    --     return true
    end
end

-- Do once after activation.
local function OnActivatedOnce()
    -- Do on first run of addon.
    if Junkee.savedVars.firstRun then
        Junkee.savedVars.firstRun = false
        CHAT_SYSTEM:AddMessage("Junkee recommends these keybindings:\n" .. "Junk/UnJunk = Z, Destroy = Shift+Z, Link = F2, Lock = Tab.")
    end

    -- Add copy name to chat item links.
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, LinkHandler_OnLinkMouseUp)

    -- Pre-hook enabling middle-mouse button for all slots (mail, inventory, etc.)
    ZO_PreHook("ZO_Inventory_SetupSlot", AddMiddleMouseButton)

    -- Pre-hook adding name copying with middle-mouse click.
    ZO_PreHook("ZO_InventorySlot_OnSlotClicked", MiddleMouseCopiesNameToChat)

    -- Remove Main Quests from quests list, so they're hidden.
    PreHookMainQuest()

    -- Listen to chat events.
    ZO_PreHook(ZO_ChatSystem_GetEventHandlers(), EVENT_CHAT_MESSAGE_CHANNEL, TrackChat)

    -- Override guild names in chat.
    _G["ZO_LinkHandler_CreateChannelLink"] = CreateChannelLink

    -- Start in /zone chat.
    if Junkee.savedVars.startInZoneChat then
        CHAT_SYSTEM:SetChannel(CHAT_CHANNEL_ZONE)
    end

    -- Override right-click menu for player links in chat.
    -- CHAT_SYSTEM.ShowPlayerContextMenu = AddToShowPlayerContextMenu
    ZO_PreHook(CHAT_SYSTEM, "ShowPlayerContextMenu", function(_, playerName, rawName)
        zo_callLater(function()
            -- d(playerName, rawName)
            AddToShowPlayerContextMenu(playerName, rawName)
        end, 10)
    end)

    -- Track scene state changes for toggling chat display.
    toggleChatWith()

    -- Track guild members joining and leaving.
    EM:RegisterForEvent(Junkee.name, EVENT_GUILD_MEMBER_ADDED, function(_, guildId, displayName)
        -- Ignore invite events.
        if GetGuildMemberIndexFromDisplayName(guildId, displayName) then
            -- Optionally, get current character name.
            local characterName = nil
            local data = GUILD_ROSTER_MANAGER:FindDataByDisplayName(displayName)
            if data and data.characterName then characterName = data.characterName end

            guildsNotify(guildId, displayName, characterName, EVENT_GUILD_MEMBER_ADDED)
        end
    end)
    EM:RegisterForEvent(Junkee.name, EVENT_GUILD_MEMBER_REMOVED, function(_, guildId, displayName, characterName, ...)
        if ShouldDisplayGuildMemberRemoveAlert(characterName) then
            guildsNotify(guildId, displayName, characterName, EVENT_GUILD_MEMBER_REMOVED)
        end
    end)

    -- Add AP to inventory.
    -- PLAYER_INVENTORY:RegisterForEvent(EVENT_MONEY_UPDATE, function()
    ZO_PreHook(PLAYER_INVENTORY, "RefreshMoney", function()
        -- Disabled.
        if not Junkee.savedVars.inventoryShowAP then return end

        local moneyBar, altMoneyBar = PLAYER_INVENTORY:GetContextualMoneyControls()
        ZO_CurrencyControl_SetSimpleCurrency(altMoneyBar, CURT_ALLIANCE_POINTS, GetCurrencyAmount(CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_CHARACTER), ZO_KEYBOARD_CURRENCY_OPTIONS)
        -- altMoneyBar:SetHidden(false)
        zo_callLater(function() altMoneyBar:SetHidden(false) end, 10)
    end)

    -- Middle-click copies player name to chat.
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, ExtraOnLinkClicked, CHAT_SYSTEM)

    -- Hide compass.
    if Junkee.savedVars.hideCompassFrame then
        SetCompassFrameHidden(true)
    end
end

-- Do when player and UI are ready.
Junkee.OnActivated = function(eventCode, initial)
    if Junkee.firstActivation then
        Junkee.firstActivation = false
        OnActivatedOnce()
    end

    -- Repeat whenever player is loaded (after loading screens, usually.)
    -- NOTE Maybe use EVENT_ZONE_CHANNEL_CHANGED?
    if Junkee.savedVars.trackZone then
        TrackZone()
    end
end

EM:RegisterForEvent(Junkee.name, EVENT_PLAYER_ACTIVATED, Junkee.OnActivated)

Junkee.Loaded = function(eventCode, addonName)
    if (Junkee.name == addonName) then
        EM:UnregisterForEvent(Junkee.name, EVENT_ADD_ON_LOADED)

        -- Hook to inventories. OUTDATED insecure.
        -- registerHooks()

        -- Hook to slot events.
        ZO_PreHook("ZO_InventorySlot_OnMouseEnter", function(control)
            if control and control.dataEntry and control.dataEntry.data then
                if control.dataEntry.data.bagId and BAGS_TO_HOOK[control.dataEntry.data.bagId] == true then
                    Junkee.OnMouseEnter(control)
                end
            end
        end)

        ZO_PreHook("ZO_InventorySlot_OnMouseExit", function(control)
            if control and control.dataEntry and control.dataEntry.data then
                if control.dataEntry.data.bagId and BAGS_TO_HOOK[control.dataEntry.data.bagId] == true then
                    Junkee.OnMouseExit(control)
                end
            end
        end)

        -- Load saved variables.
        Junkee.characterSavedVars = ZO_SavedVars:New("JunkeeAddonSavedVars", 14, nil, Junkee.savedVars)
        Junkee.accountSavedVars = ZO_SavedVars:NewAccountWide("JunkeeAddonSavedVars", 14, nil, Junkee.savedVars)

        if not Junkee.characterSavedVars.accountWide then
            Junkee.savedVars = Junkee.characterSavedVars
        else
            Junkee.savedVars = Junkee.accountSavedVars
        end

        -- Settings menu.
        LoadMenu()

        -- Chat /slash commands.
        for name, item in pairs(Junkee.savedVars.slashCmdsActive) do
            if item then
                SLASH_COMMANDS[Junkee.slashCmds[name].cmd] = Junkee.slashCmds[name].f
            end
        end
    end
end

EM:RegisterForEvent(Junkee.name, EVENT_ADD_ON_LOADED, Junkee.Loaded)
