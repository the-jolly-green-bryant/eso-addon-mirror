-- Settings menu.
function LootAlert.LoadSettings()
    local LAM = LibStub("LibAddonMenu-2.0")

    local panelData = {
        type = "panel",
        name = LootAlert.menuName,
        displayName = LootAlert.Colorize(LootAlert.menuName),
        author = LootAlert.Colorize(LootAlert.author, "AAF0BB"),
        -- version = LootAlert.Colorize(LootAlert.version, "AA00FF"),
        website = "https://esoitem.uesp.net/itemSearch.php",
        slashCommand = "/lootalert",
        registerForRefresh = true,
        registerForDefaults = false,
    }
    LAM:RegisterAddonPanel(LootAlert.menuName, panelData)

    local optionsTable = {

---------------
-- OVERRIDES --
---------------

        [1] = {
            type = "header",
            name = "Overrides",
            width = "full",	--or "half" (optional)
        },
        [2] = {
            type = "description",
            --title = "My Title",	--(optional)
            title = nil,	--(optional)
            text = "The settings in this section override any other settings in the sections below. With great power comes great responsibility. Choose wisely.",
            width = "full",	--or "half" (optional)
        },
        [3] = {
            type = "checkbox",
            name = "Addon Enabled",
            tooltip = "Turns this addon on or off.",
            getFunc = function() return LootAlert.savedVariables.enabled end,
            setFunc = function(value) LootAlert.ToggleEnable() end,
            width = "full", --or "half" (optional)
            reference = "menuAddonEnabled",
        },
        [4] = {
            type = "checkbox",
            name = "Carpe Diem",
            tooltip = "You love life. You love loot. Celebrate everything in every way all the time.",
            getFunc = function() return LootAlert.savedVariables.overrideAll end,
            setFunc = function(value) LootAlert.SetOverrideAllOnOff(value) end,
            width = "full", --or "half" (optional)
            warning = "May attract odd stares. But probably not. It's an MMO. No one pays attention to anyone else. Be you.",    --(optional)
            disabled = function() return not LootAlert.savedVariables.enabled end,
            reference = "menuCarpeDiem"
        },
        [5] = {
            type = "checkbox",
            name = "Always Log All Loot to Chat",
            tooltip = "Because every detail is important, especially the details that aren't.",
            getFunc = function() return LootAlert.savedVariables.alwaysChat end,
            setFunc = function(value) LootAlert.savedVariables.alwaysChat = value end,
            width = "full", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled or LootAlert.savedVariables.overrideAll end,
            reference = "menuAlwaysChat",
        },
        [6] = {
            type = "checkbox",
            name = "Include Reason for Alert",
            tooltip = "Because sometimes you forget why you care.",
            getFunc = function() return LootAlert.savedVariables.showReason end,
            setFunc = function(value) LootAlert.savedVariables.showReason = value end,
            width = "full", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled end,
            reference = "menuShowReason",
        },        


--------------
-- CHANNELS --
--------------

        [7] = {
            type = "header",
            name = "Channels",
            width = "full", --or "half" (optional)
        },
        [8] = {
            type = "description",
            --title = "My Title",   --(optional)
            title = nil,    --(optional)
            text = "How do you want |c7FD47FLoot|rAlert! to tell you things? Or if you prefer, in what ways would you like LootAlert to kindly shush.",
            width = "full", --or "half" (optional)
        },        
        [9] = {
            type = "checkbox",
            name = "Audio",
            tooltip = "Play a dramatic sound when you loot something delightful.",
            getFunc = function() return LootAlert.savedVariables.doAudio end,
            setFunc = function(value) LootAlert.SetAudioOnOff(value) end,
            width = "full", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled or LootAlert.savedVariables.overrideAll end,
            reference = "menuNotifyAudio",
        },
        [10] = {
            type = "checkbox",
            name = "Emote",
            tooltip = "Perform a cheerful emote to celebrate.",
            getFunc = function() return LootAlert.savedVariables.doEmote end,
            setFunc = function(value) LootAlert.SetEmoteOnOff(value) end,
            width = "full", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled or LootAlert.savedVariables.overrideAll end,
            reference = "menuNotifyEmote",
        },
        [11] = {
            type = "checkbox",
            name = "Emote while Stealthed",
            tooltip = "Honestly, they don't seem to notice.",
            getFunc = function() return LootAlert.savedVariables.doEmoteStealthed end,
            setFunc = function(value) LootAlert.SetEmoteStealthedOnOff(value) end,
            width = "full", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled or LootAlert.savedVariables.overrideAll or not LootAlert.savedVariables.doEmote end,
            reference = "menuNotifyEmoteStealted",
        },
        [12] = {
            type = "checkbox",
            name = "Alerts (top-right)",
            tooltip = "The messages that appear in the top-right that you almost never notice.",
            getFunc = function() return LootAlert.savedVariables.doAlert end,
            setFunc = function(value) LootAlert.SetAlertsOnOff(value) end,
            width = "full", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled or LootAlert.savedVariables.overrideAll end,
            reference = "menuNotifyAlerts",
        },
        [13] = {
            type = "checkbox",
            name = "Announcements (center screen)",
            tooltip = "Exactly like when you complete an achievement. Because that's what picking a flower is. An achievement. Yes it is.",
            getFunc = function() return LootAlert.savedVariables.doAnnounce end,
            setFunc = function(value) LootAlert.SetAnnouncementsOnOff(value) end,
            width = "full", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled or LootAlert.savedVariables.overrideAll end,
            reference = "menuNotifyAnnouncements",
        },
        [14] = {
            type = "checkbox",
            name = "Chat",
            tooltip = "Everything else is ephemeral. The chatbox is the best place to make lasting memories.",
            getFunc = function() return LootAlert.savedVariables.doChatOutput end,
            setFunc = function(value) LootAlert.SetChatOnOff(value) end,
            width = "full", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled or LootAlert.savedVariables.overrideAll end,
            reference = "menuNotifyChat",
        },

-------------------
-- NOTIFICATIONS --
-------------------

        [15] = {
            type = "header",
            name = "Notifications",
            width = "full", --or "half" (optional)
        },
        [16] = {
            type = "description",
            --title = "My Title",   --(optional)
            title = nil,    --(optional)
            text = "Everyone is special. Just like everyone else. Here *you* get to define what's special! What do you want |c7FD47FLoot|rAlert! to tell you about?",
            width = "full", --or "half" (optional)
        },
        [17] = {
            type = "checkbox",
            name = "Everything",
            tooltip = "Now you're talkin'.",
            getFunc = function() return LootAlert.savedVariables.watchEverything end,
            setFunc = function(value) LootAlert.savedVariables.watchEverything = value end,
            width = "full", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled or LootAlert.savedVariables.overrideAll end,
            reference = "menuWatchEverything",
        },
        [18] = {
            type = "checkbox",
            name = "Anything Intricate",
            --tooltip = "Now you're talkin'.",
            getFunc = function() return LootAlert.savedVariables.watchIntricates end,
            setFunc = function(value) LootAlert.savedVariables.watchIntricates = value end,
            width = "full", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled or LootAlert.savedVariables.overrideAll or LootAlert.savedVariables.watchEverything end,
            reference = "menuWatchIntricate",
        },
        [19] = {
            type = "checkbox",
            name = "Treasure Maps and Surveys",
            --tooltip = "Now you're talkin'.",
            getFunc = function() return LootAlert.savedVariables.watchMaps end,
            setFunc = function(value) LootAlert.savedVariables.watchMaps = value end,
            width = "full", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled or LootAlert.savedVariables.overrideAll or LootAlert.savedVariables.watchEverything end,
            reference = "menuWatchMaps",
        },
        [20] = {
            type = "checkbox",
            name = "Unknown Recipes",
            --tooltip = "Now you're talkin'.",
            getFunc = function() return LootAlert.savedVariables.watchRecipes end,
            setFunc = function(value) LootAlert.savedVariables.watchRecipes = value end,
            width = "full", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled or LootAlert.savedVariables.overrideAll or LootAlert.savedVariables.watchEverything end,
            reference = "menuWatchRecipes",
        },
        [21] = {
            type = "checkbox",
            name = "Unknown Blacksmithing Traits",
            --tooltip = "Now you're talkin'.",
            getFunc = function() return LootAlert.savedVariables.watchTraitBS end,
            setFunc = function(value) LootAlert.savedVariables.watchTraitBS = value end,
            width = "half", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled or LootAlert.savedVariables.overrideAll or LootAlert.savedVariables.watchEverything end,
            reference = "menuWatchTraitBS",
        },
        [22] = {
            type = "checkbox",
            name = "Unknown Clothier Traits",
            --tooltip = "Now you're talkin'.",
            getFunc = function() return LootAlert.savedVariables.watchTraitCloth end,
            setFunc = function(value) LootAlert.savedVariables.watchTraitCloth = value end,
            width = "half", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled or LootAlert.savedVariables.overrideAll or LootAlert.savedVariables.watchEverything end,
            reference = "menuWatchTraitCloth",
        },
        [23] = {
            type = "checkbox",
            name = "Unknown Jewelcrafting Traits",
            --tooltip = "Now you're talkin'.",
            getFunc = function() return LootAlert.savedVariables.watchTraitJC end,
            setFunc = function(value) LootAlert.savedVariables.watchTraitJC = value end,
            width = "half", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled or LootAlert.savedVariables.overrideAll or LootAlert.savedVariables.watchEverything end,
            reference = "menuWatchTraitJC",
        },
        [24] = {
            type = "checkbox",
            name = "Unknown Woodworking Traits",
            --tooltip = "Now you're talkin'.",
            getFunc = function() return LootAlert.savedVariables.watchTraitWW end,
            setFunc = function(value) LootAlert.savedVariables.watchTraitWW = value end,
            width = "half", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled or LootAlert.savedVariables.overrideAll or LootAlert.savedVariables.watchEverything end,
            reference = "menuWatchTraitWW",
        },
        [25] = {
            type = "checkbox",
            name = "Anything High Quality",
            tooltip = "OFF means don't notify me about things just because of their quality.",
            getFunc = function() return LootAlert.savedVariables.watchQuality end,
            setFunc = function(value) LootAlert.savedVariables.watchQuality = value end,
            width = "half", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled or LootAlert.savedVariables.overrideAll or LootAlert.savedVariables.watchEverything end,
            reference = "menuWatchQuality",
        },
        [26] = {
            type = "dropdown",
            name = "And by High, I mean this or better:",
            tooltip = "It's not right to judge, but some things are better than others.",
            choices = {
                LootAlert.GetColoredQualityString(ITEM_QUALITY_LEGENDARY), -- legendary, gold
                LootAlert.GetColoredQualityString(ITEM_QUALITY_ARTIFACT), -- epic, purple
                LootAlert.GetColoredQualityString(ITEM_QUALITY_ARCANE), -- superior, blue
                LootAlert.GetColoredQualityString(ITEM_QUALITY_MAGIC), -- fine, green
                LootAlert.GetColoredQualityString(ITEM_QUALITY_NORMAL), -- normal, white
            },
            choicesValues = {
                ITEM_QUALITY_LEGENDARY, -- gold
                ITEM_QUALITY_ARTIFACT,  -- purple, epic
                ITEM_QUALITY_ARCANE,    -- blue,   superior
                ITEM_QUALITY_MAGIC,     -- green,  fine
                ITEM_QUALITY_NORMAL,    -- normal, white
            },
            getFunc = function() return LootAlert.savedVariables.watchQualityLevel end,
            setFunc = function(var) LootAlert.savedVariables.watchQualityLevel = var end,
            width = "half", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled or LootAlert.savedVariables.overrideAll or LootAlert.savedVariables.watchEverything or not LootAlert.savedVariables.watchQuality end,
            reference = "menuWatchQualityLevel",
        },
        [27] = {
            type = "checkbox",
            name = "New Rare Fish",
            --tooltip = "Now you're talkin'.",
            getFunc = function() return LootAlert.savedVariables.watchTrophyFish end,
            setFunc = function(value) LootAlert.savedVariables.watchTrophyFish = value end,
            width = "full", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled or LootAlert.savedVariables.overrideAll or LootAlert.savedVariables.watchEverything end,
            reference = "menuWatchTrophyFish",
        },
        [28] = {
            type = "checkbox",
            name = "New Monster Trophies",
            --tooltip = "Now you're talkin'.",
            getFunc = function() return LootAlert.savedVariables.watchMonsterTrophies end,
            setFunc = function(value) LootAlert.savedVariables.watchMonsterTrophies = value end,
            width = "full", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled or LootAlert.savedVariables.overrideAll or LootAlert.savedVariables.watchEverything end,
            reference = "menuWatchMonsterTrophies",
        },
        [29] = {
            type = "checkbox",
            name = "Quest Items",
            --tooltip = "Now you're talkin'.",
            getFunc = function() return LootAlert.savedVariables.watchQuestItems end,
            setFunc = function(value) LootAlert.savedVariables.watchQuestItems = value end,
            width = "full", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled or LootAlert.savedVariables.overrideAll or LootAlert.savedVariables.watchEverything end,
            reference = "menuWatchQuestItems",
        },
        [30] = {
            type = "checkbox",
            name = "New Lorebooks",
            --tooltip = "Now you're talkin'.",
            getFunc = function() return LootAlert.savedVariables.watchLorebooks end,
            setFunc = function(value) LootAlert.savedVariables.watchLorebooks = value end,
            width = "full", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled or LootAlert.savedVariables.overrideAll or LootAlert.savedVariables.watchEverything end,
            reference = "menuWatchLorebooks",
        },

---------------
-- WATCHLIST --
---------------

        [31] = {
            type = "header",
            name = "Specific Things",
            width = "full", --or "half" (optional)
        },
        [32] = {
            type = "description",
            --title = "My Title",   --(optional)
            title = nil,    --(optional)
            text = "|c7FD47FLoot|rAlert! Can also watch for specific itemIds. You can search for things and find their itemIds here: https://esoitem.uesp.net/itemSearch.php (or use the Visit Website link at the top of this settings page)",
            width = "full", --or "half" (optional)
        },
        [33] = {
            type = "checkbox",
            name = "Specific Things",
            tooltip = "Find itemId's here: https://esoitem.uesp.net/itemSearch.php",
            getFunc = function() return LootAlert.savedVariables.watchItemIds end,
            setFunc = function(value) LootAlert.savedVariables.watchItemIds = value end,
            width = "full", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled or LootAlert.savedVariables.overrideAll or LootAlert.savedVariables.watchEverything end,
            reference = "menuWatchItemIds",
        },
        [34] = {
            type = "description",
            --title = "My Title",   --(optional)
            title = nil,    --(optional)
            text = "To add an item to the watchlist, type an itemId and hit ENTER. For example, the itemId for worms is 42869",
            width = "full", --or "half" (optional)
        },        
        [35] = {
            type = "editbox",
            name = "Add an Item",
            tooltip = "Type an itemId and hit ENTER. For example, the itemId for worms is 42869",
            getFunc = function() return LootAlert.savedVariables.watchedItemId end,
            setFunc = function(text) LootAlert.AddWatchedItemId(text) end,
            isMultiline = false,    --boolean
            width = "full", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled or LootAlert.savedVariables.overrideAll or LootAlert.savedVariables.watchEverything or not LootAlert.savedVariables.watchItemIds end,
            reference = "menuEnterItemId",
            --warning = "Will need to reload the UI.",    --(optional)
            --default = "",   --(optional)
            isExtraWide = true,
        },
        [36] = {
            type = "description",
            --title = "My Title",   --(optional)
            title = nil,    --(optional)
            text = "To remove an item from the watchlist, open the Watchlist and right click the item.",
            width = "full", --or "half" (optional)
        },        
        [37] = {
            type = "button",
            name = "TOGGLE WATCHLIST",
            --tooltip = "Button's tooltip text.",
            func = function() LootAlert.ToggleWindow() end,
            width = "full", --or "half" (optional)
            disabled = function() return not LootAlert.savedVariables.enabled or LootAlert.savedVariables.overrideAll or LootAlert.savedVariables.watchEverything or not LootAlert.savedVariables.watchItemIds end,
            reference = "menuRemoveItemId",
        },

-------------
-- TESTING --
-------------
--[[
        [38] = {
            type = "header",
            name = "Testing",
            width = "full", --or "half" (optional)
        },
--]]
    }
    LAM:RegisterOptionControls(LootAlert.menuName, optionsTable)
end