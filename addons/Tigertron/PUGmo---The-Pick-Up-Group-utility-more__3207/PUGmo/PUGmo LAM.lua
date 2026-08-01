if not PUGmo then
    PUGmo = {}
end
local PUG = PUGmo
local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER
local SM = SCENE_MANAGER
local CM = CALLBACK_MANAGER
local CS = CHAT_SYSTEM

-------------------------------------------------------------------------
--- Initialize the settings menu
-------------------------------------------------------------------------
function PUG:makeLAM()
    local LAM = LibAddonMenu2

    local panelData = {
        type = "panel",
        name = PUG.name,
        displayName = "|cFFAA33PUG|rmo",
        author = PUG.author,
        version = PUG.version,
        --  slashCommand = "/pugmo", --(optional) will register a keybind to open to this panel
        registerForRefresh = true, --boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
        --	registerForDefaults = true,	--boolean (optional) (will set all options controls back to default values)
    }
    local optionsTable = {
        {
            type = "header",
            name = "PUGmo Settings",
            width = "full", --or "half" (optional)
        },
        {
            type = "description",
            title = "|c00A000Nothing happens without |cFFC000PUGMO GO!|r |c00A000keybind.|r", --(optional)
            text = "|cFF0000PLEASE READ:|r\n|cCFDCBDI highly recommend you set a keybinding in \"Controls\" on the left for PUGmo GO! (I use \"B\" key), alternatively you can type \"\\pugmo go\" in to the chat box to launch the UI.\nRead the \"PUGmo Docs\" PDF file in:\n\"Documents\\Elder Scrolls Online\\live\\AddOns\\PUGmo\"\nIt details most everything you need to know. The Tooltips here will also help you understand the settings.|r",
            width = "full", --or "half" (optional)
        },
        --{-- -- LAM Option Whisper: Notification by sound slider
        --    type = "slider",
        --    name = "Sound Selector",
        --    tooltip = "Choose a sound",
        --    min = 1,
        --    max = #PUG.sounds,
        --    step = 1,
        --    getFunc = function()
        --        return PUG.whisperSound
        --    end,
        --    setFunc = function(value)
        --        PUG.whisperSound = value
        --        local soundName = PUG.sounds[value]
        --        if value ~= 1 then
        --            if soundName and SOUNDS and SOUNDS[soundName] then
        --                PlaySound(SOUNDS[soundName])
        --            end
        --        end
        --        --Update the label to show the sound name
        --        --UpdateSoundDescription("SoundSlider", value)
        --    end,
        --    width = "full",
        --    default = PUG.whisperSound,
        --    reference = "SoundSlider",
        --},
        --[[dividerData = {
            type = "divider",
            width = "full", -- or "half" (optional)
            height = 10, -- (optional)
            alpha = 0.25, -- (optional)
            reference = "MyAddonDivider" -- unique global reference to control (optional)
        } ]]


        {
            type = "submenu",
            name = "Alert Box Settings",
            tooltip = "Alert Box Popup occurs with incoming whispers, pre-check alert, group leader \"speaking\" and after auto populating chat messages to hint \"HIT ENTER\".\nTimers are doubled when cursor is active. eg. chat typing.", --(optional)
            controls = {
                {
                    type = "checkbox",
                    name = "Alert Box Popup Enabled",
                    tooltip = "If disabled the Alert Box will never show. For anything.",
                    getFunc = function()
                        return PUG.SV.alertOn
                    end,
                    setFunc = function(value)
                        PUG.SV.alertOn = value
                    end,
                    width = "full", --or "half" (optional)
                },
                {
                    type = "divider",
                    width = "full", -- or "half" (optional)
                    height = 20, -- (optional)
                    alpha = 0.5, -- (optional)
                    --reference = "MyAddonDivider" -- unique global reference to control (optional)
                },

                --{
                --    type = "dropdown",
                --    name = "Alert Box Size",
                --    tooltip = "Dropdown's tooltip text.",
                --    choices = { "Small", "Normal", "Large" ,"Extra Large"},
                --    getFunc = function()
                --        return "Normal"
                --    end,
                --    setFunc = function(var)
                --        local scale = {
                --            ["Small"] = "$(MEDIUM_FONT)|14",
                --            ["Normal"] = "$(MEDIUM_FONT)|18",
                --            ["Large"] = "$(MEDIUM_FONT)|24",
                --            ["Extra Large"] = "$(MEDIUM_FONT)|48",
                --        }
                --        PUGmoAlertBoxWindow:SetFont(scale[var])
                --
                --    end,
                --    width = "half", --or "half" (optional)
                --    --warning = "Will need to reload the UI.", --(optional)
                --},

                {
                    type = "checkbox",
                    name = "Alert Box Location Locked",
                    tooltip = "Unlock Alert Box to reposition it.",
                    getFunc = function()
                        return PUGmoAlertBoxWindow:IsHidden()
                    end,
                    setFunc = function(value)
                        PUGmoAlertBoxWindow:SetHidden(value)
                    end,
                    width = "full", --or "half" (optional)
                    disabled = function()
                        return not PUG.SV.alertOn
                    end
                },
                {
                    type = "slider",
                    name = "Alert Box Fade - |cFFAA33General|r",
                    tooltip = "Set the number of seconds that the Alert Box remains on the screen. This is a general setting used when no other time is specified.",
                    min = 1,
                    max = 20,
                    step = 1, --(optional)
                    getFunc = function()
                        return PUG.SV.alertTime.general
                    end,
                    setFunc = function(value)
                        PUG.SV.alertTime.general = value
                    end,
                    width = "full", --or "half" (optional)
                    disabled = function()
                        return not PUG.SV.alertOn
                    end
                    --default = 5, --(optional)
                },
                {
                    type = "slider",
                    name = "Alert Box Fade - |cFFAA33Leader|r",
                    tooltip = "Set the number of seconds that the Leader Speaking Message Box remains on the screen.",
                    min = 1,
                    max = 20,
                    step = 1, --(optional)
                    getFunc = function()
                        return PUG.SV.alertTime.leader
                    end,
                    setFunc = function(value)
                        PUG.SV.alertTime.leader = value
                    end,
                    width = "full", --or "half" (optional)
                    disabled = function()
                        return not PUG.SV.alertOn
                    end
                    --default = 5, --(optional)
                },
                {
                    type = "checkbox",
                    name = "Confirm Whisper",
                    tooltip = "If enabled the Incoming Whisper Alert will not fade and the \"CONFIRM\" box must be clicked. (Never miss a whisper!)",
                    getFunc = function()
                        return PUG.SV.confirmWhisper
                    end,
                    setFunc = function(value)
                        PUG.SV.confirmWhisper = value
                    end,
                    width = "full", --or "half" (optional)
                    disabled = function()
                        return not PUG.SV.alertOn
                    end
                },
                {
                    type = "slider",
                    name = "Alert Box Fade - |cFFAA33Whisper|r",
                    tooltip = "Set the number of seconds that the Incoming Whisper Message Box remains on the screen.",
                    min = 1,
                    max = 20,
                    step = 1, --(optional)
                    getFunc = function()
                        return PUG.SV.alertTime.whisper
                    end,
                    setFunc = function(value)
                        PUG.SV.alertTime.whisper = value
                    end,
                    width = "full", --or "half" (optional)
                    disabled = function()
                        return not PUG.SV.alertOn or PUG.SV.confirmWhisper
                    end
                },
            },
        },
        {
            type = "submenu",
            name = "LFG Settings",
            tooltip = "The UI that is displayed when not in a group or grouped but outside of a delve, dungeon or trial.", --(optional)
            controls = {
                {
                    type = "slider",
                    name = "Message Expiration Time (mins)",
                    tooltip = "Set the amount of time that messages remain on the Group and Trade lists.",
                    min = 1,
                    max = 20,
                    step = 1, --(optional)
                    getFunc = function()
                        return PUG.SV.xtime / 60
                    end,
                    setFunc = function(value)
                        PUG.SV.xtime = value * 60
                        for i = 1, #PUG.zoneBuffer do
                            PUG.zoneBuffer[i].xtime = PUG.SV.xtime + os.time()
                        end
                    end,
                    width = "full", --or "half" (optional)
                    default = 5, --(optional)
                },
                {
                    type = "slider",
                    name = "Set the amount keyword matches.",
                    tooltip = "Min number of Keyword hits to put the message on the list.",
                    min = 1,
                    max = 3,
                    step = 1, --(optional)
                    getFunc = function()
                        return PUG.SV.minLFGKeys
                    end,
                    setFunc = function(value)
                        PUG.SV.minLFGKeys = value
                    end,
                    width = "full", --or "half" (optional)
                    default = 2, --(optional)
                },

            },
        },
        {
            type = "submenu",
            name = "WTS/WTB Settings",
            tooltip = "The lower half of the LFG UI will optionally show WTS/WTB/WTT messages.", --(optional)
            controls = {
                {
                    type = "checkbox",
                    name = "Looking For Trade Enabled",
                    tooltip = "Enable or Disable the WTS feature.",
                    getFunc = function()
                        return PUG.SV.wtsOn
                    end,
                    setFunc = function(value)
                        PUG.SV.wtsOn = value
                    end,
                    width = "full", --or "half" (optional)
                    warning = "Need to Reload UI to take effect.", --(optional)
                },
                {
                    type = "slider",
                    name = "Set the amount keyword matches.",
                    tooltip = "Min number of Keyword hits to put the message on the list.",
                    min = 1,
                    max = 3,
                    step = 1, --(optional)
                    getFunc = function()
                        return PUG.SV.minWTSKeys
                    end,
                    setFunc = function(value)
                        PUG.SV.minWTSKeys = value
                    end,
                    width = "full", --or "half" (optional)
                    default = 1, --(optional)
                },

                {
                    type = "divider",
                    width = "full", -- or "half" (optional)
                    height = 20, -- (optional)
                    alpha = 0.5, -- (optional)
                    --reference = "MyAddonDivider" -- unique global reference to control (optional)
                },

                {
                    type = "description",
                    title = "|c00A000Blacklist|r", --(optional)
                    text = "|cCFDCBDBlacklist items will block the message from being displayed.\nSeparate multiple items with the space.\nIf you want to block CROWNS you would add that to the Blacklist.\nCase does not matter.|r",
                    width = "full", --or "half" (optional)
                    disabled = function()
                        return not PUG.SV.wtsOn
                    end
                },
                {
                    type = "editbox",
                    name = "Black Listed Items",
                    tooltip = "Separated with space",
                    getFunc = function()
                        return table.concat(PUG.SV.itemBlacklist, " ")
                    end,
                    setFunc = function(text)
                        local t, x = {}, 1
                        for k in string.gmatch(text, "%S+") do
                            t[x] = string.upper(k)
                            x= x+1
                            d(k,x)
                        end
                        PUG.SV.itemBlacklist = t
                    end,
                    isMultiline = false, --boolean
                    width = "full", --or "half" (optional)
                    --warning = "Will need to reload the UI.", --(optional)
                    default = "", --(optional)
                    disabled = function()
                        return not PUG.SV.wtsOn
                    end
                },

            },
        },
        {
            type = "submenu",
            name = "List Gear Settings",
            tooltip = "Settings for the UI that is displayed when grouped and in a Delve, Dungeon or Trial.", --(optional)
            controls = {
                {
                    type = "description",
                    title = "|c00A000The prefix and suffix of the whisper when asking for gear.|r", --(optional)
                    text = PUG.color.lightorange .. PUG.SV.lootWhisperPrefix .. " |cCFDCBD(the gear you are requesting)|r " .. PUG.color.lightorange ..PUG.SV.lootWhisperSuffix .. "|r",
                    width = "full", --or "half" (optional)
                },
                {
                    type = "editbox",
                    name = "Whisper Prefix",
                    tooltip = "See above.",
                    getFunc = function()
                        return PUG.SV.lootWhisperPrefix
                    end,
                    setFunc = function(text)
                        PUG.SV.lootWhisperPrefix = text
                    end,
                    isMultiline = false, --boolean
                    width = "full", --or "half" (optional)
                    --warning = "Will need to reload the UI.", --(optional)
                    --default = "", --(optional)
                },
                {
                    type = "editbox",
                    name = "Whisper Suffix",
                    tooltip = "See above.",
                    getFunc = function()
                        return PUG.SV.lootWhisperSuffix
                    end,
                    setFunc = function(text)
                        PUG.SV.lootWhisperSuffix = text
                    end,
                    isMultiline = false, --boolean
                    width = "full", --or "half" (optional)
                    --warning = "Will need to reload the UI.", --(optional)
                    --default = "", --(optional)
                },
                {
                    type = "divider",
                    width = "full", -- or "half" (optional)
                    height = 20, -- (optional)
                    alpha = 0.5, -- (optional)
                    --reference = "MyAddonDivider" -- unique global reference to control (optional)
                },


                {
                    type = "description",
                    title = "|c00A000Choose how jewelery is handled:|r", --(optional)
                    text = "|cCFDCBDDecide if you want to block only gold jewelery or block all jewelery.\nWith both off, all jewelery, including gold quality, WILL BE listed.|r",
                    width = "full", --or "half" (optional)
                },

                {
                    type = "checkbox",
                    name = "Block ALL Jewelery",
                    tooltip = "If enabled jewelery in total will NOT be a part of the listed items.",
                    getFunc = function()
                        return PUG.SV.skipJewelery
                    end,
                    setFunc = function(value)
                        PUG.SV.skipJewelery = value
                    end,
                    width = "full", --or "half" (optional)
                    --warning = "Will need to reload the UI.", --(optional)
                    --disabled = function()
                    --    return not PUG.SV.skipLegendary
                    --end,
                    default = false

                },

                {
                    type = "checkbox",
                    name = "Block Legendary Jewelery",
                    tooltip = "If enabled ONLY jewelery of LEGENDARY (gold) quality will not be part of the listed items.",
                    getFunc = function()
                        return PUG.SV.skipLegendary
                    end,
                    setFunc = function(value)
                        PUG.SV.skipLegendary = value
                    end,
                    width = "full", --or "half" (optional)
                    --warning = "Will need to reload the UI.", --(optional)
                    disabled = function()
                        return PUG.SV.skipJewelery
                    end,
                    default = true

                },
                {
                    type = "divider",
                    width = "full", -- or "half" (optional)
                    height = 20, -- (optional)
                    alpha = 0.5, -- (optional)
                    --reference = "MyAddonDivider" -- unique global reference to control (optional)
                },
                {
                    type = "description",
                    title = "|c00A000The Edge Color assigned to different gear sets.|r", --(optional)
                    text = "|cCFDCBDColors are assigned as they are listed\nFirst set gets first color and so on. At the fifth set only that color is used for the remainder.|r",
                    width = "full", --or "half" (optional)
                },
               {
                    type = "texture",
                    image = "/art/fx/texture/box_softinside.dds",
                    imageWidth = 200, --max of 250 for half width, 510 for full
                    imageHeight = 30, --max of 100
                    tooltip = "Sample Edge Color", --(optional)
                    width = "full", --or "half" (optional)
                    reference = "PUGmoLAMTestButton"

                },

                {
                    type = "colorpicker",
                    name = "1st Set Color",
                    tooltip = "Edge color assigned to the first listed set.\nAll gear of this set will have this edge color for the duration. It will reset after leaving.",
                    getFunc = function()
                        return
                        PUG.SV.itemColor[1].r,
                        PUG.SV.itemColor[1].g,
                        PUG.SV.itemColor[1].b,
                        PUG.SV.itemColor[1].a
                    end, --(alpha is optional)
                    setFunc = function(r, g, b, a)
                        PUG.SV.itemColor[1] = { r = r, g = g, b = b, a = a }
                        PUG:updateTestButton(r, g, b, a)
                    end, --(alpha is optional)
                    width = "full", --or "half" (optional)
                    --warning = "warning text",
                },
                {
                    type = "colorpicker",
                    name = "2nd Set Color",
                    tooltip = "Edge color assigned to the second listed set.\nAll gear of this set will have this edge color for the duration. It will reset after leaving.",
                    getFunc = function()
                        return
                        PUG.SV.itemColor[2].r,
                        PUG.SV.itemColor[2].g,
                        PUG.SV.itemColor[2].b,
                        PUG.SV.itemColor[2].a
                    end, --(alpha is optional)
                    setFunc = function(r, g, b, a)
                        PUG.SV.itemColor[2] = { r = r, g = g, b = b, a = a }
                        PUG:updateTestButton(r, g, b, a)
                    end, --(alpha is optional)
                    width = "full", --or "half" (optional)
                    --warning = "warning text",
                },
                {
                    type = "colorpicker",
                    name = "3rd Set Color",
                    tooltip = "Edge color assigned to the third listed set.\nAll gear of this set will have this edge color for the duration. It will reset after leaving.",
                    getFunc = function()
                        return
                        PUG.SV.itemColor[3].r,
                        PUG.SV.itemColor[3].g,
                        PUG.SV.itemColor[3].b,
                        PUG.SV.itemColor[3].a
                    end, --(alpha is optional)
                    setFunc = function(r, g, b, a)
                        PUG.SV.itemColor[3] = { r = r, g = g, b = b, a = a }
                        PUG:updateTestButton(r, g, b, a)
                    end, --(alpha is optional)
                    width = "full", --or "half" (optional)
                    --warning = "warning text",
                },
                {
                    type = "colorpicker",
                    name = "4th Set Color",
                    tooltip = "Edge color assigned to the forth listed set.\nAll gear of this set will have this edge color for the duration. It will reset after leaving.",
                    getFunc = function()
                        return
                        PUG.SV.itemColor[4].r,
                        PUG.SV.itemColor[4].g,
                        PUG.SV.itemColor[4].b,
                        PUG.SV.itemColor[4].a
                    end, --(alpha is optional)
                    setFunc = function(r, g, b, a)
                        PUG.SV.itemColor[4] = { r = r, g = g, b = b, a = a }
                        PUG:updateTestButton(r, g, b, a)
                    end, --(alpha is optional)
                    width = "full", --or "half" (optional)
                    --warning = "warning text",
                },
                {
                    type = "colorpicker",
                    name = "Overflow Set Color",
                    tooltip = "Edge color assigned to the fifth and on listed sets.\nAll gear of these sets will have this edge color for the duration. It will reset after leaving.",
                    getFunc = function()
                        return
                        PUG.SV.itemColor[5].r,
                        PUG.SV.itemColor[5].g,
                        PUG.SV.itemColor[5].b,
                        PUG.SV.itemColor[5].a
                    end, --(alpha is optional)
                    setFunc = function(r, g, b, a)
                        PUG.SV.itemColor[5] = { r = r, g = g, b = b, a = a }
                        PUG:updateTestButton(r, g, b, a)
                    end, --(alpha is optional)
                    width = "full", --or "half" (optional)
                    --warning = "warning text",
                },
                {
                    type = "editbox",
                    name = "My Best Friend",
                    tooltip = "Shift-Clicking the \"List-All\" button will send the list to this player if they are in the same group.\neg.\"@Ayren1234\"",
                    getFunc = function()
                        return PUG.SV.bestFriend
                    end,
                    setFunc = function(text)
                        PUG.SV.bestFriend = text
                    end,
                    isMultiline = false, --boolean
                    width = "full", --or "half" (optional)
                    --warning = "Will need to reload the UI.", --(optional)
                    default = "", --(optional)
                },

                --{
                --    type = "editbox",
                --    name = "My Editbox",
                --    tooltip = "Editbox's tooltip text.",
                --    getFunc = function()
                --        return "this is some text"
                --    end,
                --    setFunc = function(text)
                --        print(text)
                --    end,
                --    isMultiline = true, --boolean
                --    width = "half", --or "half" (optional)
                --    --warning = "Will need to reload the UI.", --(optional)
                --    default = "", --(optional)
                --},
            },
        },
        {
            type = "submenu",
            name = "Qol Settings",
            tooltip = "Some things that make my life easier, maybe yours as well.", --(optional)
            controls = {
                {
                    type = "checkbox",
                    name = "Auto-enable/disable Encounter Log",
                    tooltip = "If Enabled AND in a group, \"Encounter Log\" will automatically be activated any time you enter any Delve, Dungeon or Trial and then deactivated when you leave",
                    getFunc = function()
                        return PUG.SV.setEncounterLog
                    end,
                    setFunc = function(value)
                        PUG.SV.setEncounterLog = value
                    end,
                    width = "full", --or "half" (optional)
                    --	warning = "Will need to reload the UI.",	--(optional)
                },
                {
                    type = "checkbox",
                    name = "Auto-Switch to Group Chat",
                    tooltip = "When grouped, auto switches to group chat box and primes it with group input upon entering Delve, Dungeon or Trial.\npChat helpful but not required",
                    getFunc = function()
                        return PUG.SV.groupChat
                    end,
                    setFunc = function(value)
                        PUG.SV.groupChat = value
                    end,
                    width = "full", --or "half" (optional)
                    --disabled = function()
                    --    return not PUG.data.isPChat
                    --end,

                    --	warning = "Will need to reload the UI.",	--(optional)
                },
                {
                    type = "slider",
                    name = "Marked player arrow duration (sec)",
                    tooltip = "Set the amount of time in seconds that the bouncy arrow remains over a player when marked.\nOdy Support Icons addon required.",
                    min = 1,
                    max = 60,
                    step = 1, --(optional)
                    getFunc = function()
                        return PUG.SV.markedDelay
                    end,
                    setFunc = function(value)
                        PUG.SV.markedDelay = value
                    end,
                    width = "full", --or "half" (optional)
                    default = 30, --(optional)
                    disabled = function()
                        return not PUG.data.isOSI
                    end,

                },
                {
                    type = "divider",
                    width = "full", -- or "half" (optional)
                    height = 20, -- (optional)
                    alpha = 0.5, -- (optional)
                    --reference = "MyAddonDivider" -- unique global reference to control (optional)
                },
                {
                    type = "description",
                    title = "|c00A000Pre-Check Info|r", --(optional)
                    text = "|cCFDCBDWhen grouped, and upon entering a Delve, Dungeon or Trial or when Hot-Key binding is pressed a Pre-Check Info Box is displayed that will show things such as; your gear condition, food, free bag space, ect.|r",
                    width = "full", --or "half" (optional)
                },

                {
                    type = "checkbox",
                    name = "Pre-Check Info Box Enabled",
                    tooltip = "Should Pre-Check Alert Box pop-up on entering a Delve, Dungeon or Trial?",
                    getFunc = function()
                        return PUG.SV.preCheck
                    end,
                    setFunc = function(value)
                        PUG.SV.preCheck = value
                    end,
                    width = "full", --or "half" (optional)
                    --	warning = "Will need to reload the UI.",	--(optional)
                },
                {
                    type = "checkbox",
                    name = "Show Soul Gems and Repair Kits",
                    tooltip = "If enabled then the number of Soul Gems and Repair Kits will be shown.",
                    getFunc = function()
                        return PUG.SV.showGemsAndKits
                    end,
                    setFunc = function(value)
                        PUG.SV.showGemsAndKits = value
                    end,
                    width = "full", --or "half" (optional)
                    disabled = function()
                        return not PUG.SV.preCheck
                    end
                },
                {
                    type = "slider",
                    name = "Min Gear Condition",
                    tooltip = "This is the min level of Gear Condition to show as green.\nSet to 1 to disable.\nAny gear at 100% will not be shown.",
                    min = 1,
                    max = 99,
                    step = 1, --(optional)
                    getFunc = function()
                        return PUG.SV.minCond
                    end,
                    setFunc = function(value)
                        PUG.SV.minCond = value
                    end,
                    width = "full", --or "half" (optional)
                    default = 20, --(optional)
                    disabled = function()
                        return not PUG.SV.preCheck
                    end
                },
                {
                    type = "slider",
                    name = "Min Enchantment or Show Poison",
                    tooltip = "This is the min level of Enchant Percentage to show as green or type of poison slotted.\nSet to 1 to disable.",
                    min = 1,
                    max = 99,
                    step = 1, --(optional)
                    getFunc = function()
                        return PUG.SV.minCharges
                    end,
                    setFunc = function(value)
                        PUG.SV.minCharges = value
                    end,
                    width = "full", --or "half" (optional)
                    default = 20, --(optional)
                    disabled = function()
                        return not PUG.SV.preCheck
                    end
                },
                {
                    type = "slider",
                    name = "Min Free Bag Slots",
                    tooltip = "This is the min number of Free Bag Slots to show as green.\nSet to 0 to disable.",
                    min = 0,
                    max = GetBagSize(BAG_BACKPACK),
                    step = 1, --(optional)
                    getFunc = function()
                        return PUG.SV.freeSlots
                    end,
                    setFunc = function(value)
                        PUG.SV.freeSlots = value
                    end,
                    width = "full", --or "half" (optional)
                    default = 20, --(optional)
                    disabled = function()
                        return not PUG.SV.preCheck
                    end
                },

            },

        },
        --{
        --    type = "custom",
        --    refreshFunc = function(customControl)
        --    end, --(optional) function to call when panel/controls refresh
        --    width = "half", --or "half" (optional)
        --
        --},
    },

    LAM:RegisterAddonPanel("PUGmoLAM", panelData)
    LAM:RegisterOptionControls("PUGmoLAM", optionsTable)
end

