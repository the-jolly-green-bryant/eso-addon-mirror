AutoWrit = {}
AutoWrit.name = "AutoWrit"

AW = {}

-- this is bad
AW_LANG = "en"

AW.searches = {
    ["en"] = {
        ["chatters"] = {
            ["<Examine the Woodworker Writs.>"] = "woodworking",
            ["<Examine the Blacksmith Writs.>"] = "blacksmithing",
            ["<Examine the Clothier Writs.>"] = "clothing",
            ["<Examine the Provisioner Writs.>"] = "provisioning",
            ["<Examine the Alchemist Writs.>"] = "alchemy",
            ["<Examine the Enchanter Writs.>"] = "enchanting",
            ["<Place the goods within the crate.>"] = "auto_handin",
            ["<Sign the Manifest.>"] = "auto_handin",
            ["I've finished the job."] = "auto_handin_master",
            ["<Finish the job.>"] = "auto_handin_master",
        },
        ["quests"] = {
            ["Seeking skilled enchanters"] = "enchanting",
            ["Seeking skilled provisioners"] = "provisioning",
            ["Seeking skilled alchemists"] = "alchemy",
            ["Seeking skilled clothiers"] = "clothing",
            ["Seeking skilled blacksmiths"] = "blacksmithing",
            ["Seeking skilled woodworkers"] = "woodworking",
            ["<Accept the contract.>"] = "master_writ",
        },
        ["handins"] = {
            ["Sign Delivery Manifest"] = "auto_handin",
            ["<He notes your work and tenders payment.>"] = "auto_handin_master",
        },
        ["strings"] = {
            ["ACCEPT_TITLE"] = "Accept Master Writ?",
            ["ACCEPT"] = "Are you sure you wish to accept this master writ on this character?",
            ["ACCEPT_ACCEPT"] = "Accept",
        }
    },
}

AutoWrit_sv = nil

AutoWrit_awsv = nil
AutoWrit._charsv = nil

AutoWrit.defaults = {
    ["blacksmithing"] = true,
    ["woodworking"] = true,
    ["provisioning"] = true,
    ["clothing"] = true,
    ["alchemy"] = true,
    ["enchanting"] = true,
    ["auto_accept"] = true,
    ["auto_handin"] = true,
    ["auto_handin_master"] = false,
    ["account_wide"] = true,

    ["auto_decline"] = false,

    ["no_accept"] = false,
    ["no_accept_name"] = "",

    ["prompt_before_accept"] = false,
}

local LAM = LibStub('LibAddonMenu-2.0')

function AutoWrit:Initialize()
    -- maybe do stuff here later
    AutoWrit_awsv = ZO_SavedVars:NewAccountWide("AutoWrit_AW_SavedVars", 1, nil, AutoWrit.defaults)
    AutoWrit_charsv = ZO_SavedVars:New("AutoWrit_Char_SavedVars", 1, nil, AutoWrit.defaults)

    local function GetSV ()
        if AutoWrit_awsv["account_wide"] == true then
            AutoWrit_sv = AutoWrit_awsv
        else
            AutoWrit_sv = AutoWrit_charsv
        end
    end

    GetSV()

    ZO_CreateStringId("SI_AUTOWRIT_ACCEPT_TITLE", AW.searches[AW_LANG]["strings"]["ACCEPT_TITLE"])
    ZO_CreateStringId("SI_AUTOWRIT_ACCEPT", AW.searches[AW_LANG]["strings"]["ACCEPT"])
    ZO_CreateStringId("SI_AUTOWRIT_ACCEPT_ACCEPT", AW.searches[AW_LANG]["strings"]["ACCEPT_ACCEPT"])

    local panelData = {
        type = "panel",
        name = "AutoWrit",
        displayName = "AutoWrit",
        author = "@noobanidus",
        version = "2.0.0",
        slashCommand = "/awrit",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel("AutoWrit", panelData)

    local optionsTable = {}

    local index = 1

    local function accepts ()
        return not AutoWrit_sv["auto_accept"]
    end

    optionsTable[index] = {
        type = "header",
        name = "General",
        width = "full",
        }
    index = index + 1
    optionsTable[index] = {
        type = "checkbox",
        name = "Account-wide settings",
        tooltip = "Store settings for AutoWrit account-wide.",
        default = true,
        getFunc = function () return AutoWrit_awsv["account_wide"] end,
        setFunc = function (val)
            AutoWrit_awsv["account_wide"] = val
            GetSV()
        end,
        requiresReload = true,
        width = "full",
        }
    index = index +1
    optionsTable[index] = {
        type = "header",
        name = "Accepting Writ Quests",
        width = "full",
        }
    index = index + 1
    optionsTable[index] = {
        type = "checkbox",
        name = "Accept writs",
        tooltip = "Automatically accept writs.",
        default = true,
        getFunc = function () return AutoWrit_sv["auto_accept"] end,
        setFunc = function (val) AutoWrit_sv["auto_accept"] = val end,
        width = "full",
        }
    index = index + 1
    optionsTable[index] = {
        type = "checkbox",
        name = "Blacksmithing writs",
        tooltip = "Automatically accept blacksmithing writs.",
        default = true,
        getFunc = function () return AutoWrit_sv["blacksmithing"] end,
        setFunc = function (val) AutoWrit_sv["blacksmithing"] = val end,
        width = "full",
        disabled = accepts,
    }
    index = index + 1
    optionsTable[index] = {
        type = "checkbox",
        name = "Clothier writs",
        tooltip = "Automatically accept clothier writs.",
        default = true,
        getFunc = function () return AutoWrit_sv["clothing"] end,
        setFunc = function (val) AutoWrit_sv["clothing"] = val end,
        width = "full",
        disabled = accepts,
    }
    index = index + 1
    optionsTable[index] = {
        type = "checkbox",
        name = "Woodworking writs",
        tooltip = "Automatically accept woodworking writs.",
        default = true,
        getFunc = function () return AutoWrit_sv["woodworking"] end,
        setFunc = function (val) AutoWrit_sv["woodworking"] = val end,
        width = "full",
        disabled = accepts,
    }
    index = index + 1
    optionsTable[index] = {
        type = "checkbox",
        name = "Enchanting writs",
        tooltip = "Automatically accept enchanting writs.",
        default = true,
        getFunc = function () return AutoWrit_sv["enchanting"] end,
        setFunc = function (val) AutoWrit_sv["enchanting"] = val end,
        width = "full",
        disabled = accepts,
    }
    index = index + 1
    optionsTable[index] = {
        type = "checkbox",
        name = "Provisioning writs",
        tooltip = "Automatically accept provisioning writs.",
        default = true,
        getFunc = function () return AutoWrit_sv["provisioning"] end,
        setFunc = function (val) AutoWrit_sv["provisioning"] = val end,
        width = "full",
        disabled = accepts,
    }
    index = index + 1
    optionsTable[index] = {
        type = "checkbox",
        name = "Alchemy writs",
        tooltip = "Automatically accept alchemy writs.",
        default = true,
        getFunc = function () return AutoWrit_sv["alchemy"] end,
        setFunc = function (val) AutoWrit_sv["alchemy"] = val end,
        width = "full",
        disabled = accepts,
    }

    index = index + 1
    optionsTable[index] = {
        type = "header",
        name = "Handing in Writ Quests",
        width = "full",
    }

    index = index + 1
    optionsTable[index] = {
        type = "checkbox",
        name = "Hand in normal writs",
        tooltip = "Automatically hand in completed normal writs.",
        default = true,
        getFunc = function () return AutoWrit_sv["auto_handin"] end,
        setFunc = function (val) AutoWrit_sv["auto_handin"] = val end,
        width = "full",
    }
    index = index + 1
    optionsTable[index] = {
        type = "checkbox",
        name = "Hand in master writs",
        tooltip = "Automatically hand in completed master writs.",
        default = false,
        getFunc = function () return AutoWrit_sv["auto_handin_master"] end,
        setFunc = function (val) AutoWrit_sv["auto_handin_master"] = val end,
        width = "full",
    }

    index = index + 1
    optionsTable[index] = {
        type = "header",
        name = "Master Writs",
        width = "full"
    }
    --index = index + 1
    --optionsTable[index] = {
    --    type = "checkbox",
    --    name = "Decline Master Writs",
    --    tooltip = "Automatically decline master writs when looted from crates.",
    --    default = false,
    --    getFunc = function () return AutoWrit_sv["auto_decline"] end,
    --    setFunc = function (val) AutoWrit_sv["auto_decline"] = val end,
    --    width = "full",
    --}
    index = index + 1
    optionsTable[index] = {
        type = "checkbox",
        name = "Prompt before accepting writs",
        tooltip = "Prompt with a dialog before accepting writs",
        default = false,
        getFunc = function () return AutoWrit_sv["prompt_before_accept"] end,
        setFunc = function (val) AutoWrit_sv["prompt_before_accept"] = val end,
        width = "full",
    }
    index = index + 1
    optionsTable[index] = {
        type = "checkbox",
        name = "Only accept writs on 1 character",
        tooltip = "Disallow accepting writs unless accepted on specified character.",
        default = false,
        getFunc = function () return AutoWrit_sv["no_accept"] end,
        setFunc = function (val) AutoWrit_sv["no_accept"] = val end,
        width = "full",
    }
    index = index + 1
    optionsTable[index] = {
        type = "editbox",
		isMultiline = false,
		isExtraWide = false,
        name = "Character",
        tooltip = "Character to allow accepting on",
        default = false,
        getFunc = function () return AutoWrit_sv["no_accept_name"] end,
        setFunc = function (val) AutoWrit_sv["no_accept_name"] = val end,
        width = "full",
        disabled = function () return not AutoWrit_sv["no_accept"] end,
    }

    LAM:RegisterOptionControls("AutoWrit", optionsTable)

    ZO_Dialogs_RegisterCustomDialog("CONFIRM_ACCEPT_MASTER_WRIT", {
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title =
        {
            text = SI_AUTOWRIT_ACCEPT_TITLE,
        },
        mainText = 
        {
            text = SI_AUTOWRIT_ACCEPT,
        },
        buttons =
        {
            [1] =
            {
                text =      SI_AUTOWRIT_ACCEPT_ACCEPT,
                callback =  function(dialog)
                                dialog.data.callback()
                            end
            },
            
            [2] =
            {
                text =      SI_DIALOG_CANCEL,
            }
        }
    })

    -- this concept taken from http://www.esoui.com/downloads/info865-Nothankyou.html#comments
    -- by Sounomi
    
    --local blockQuest

    --LOOT_SCENE:RegisterCallback("StateChange", function (oldState, newState)
    --    if newState == "hidden" then
    --        blockQuest = true
    --        zo_callLater(function ()
    --            blockQuest = false
    --        end, 500)
    --    end
    --end)

    ZO_PreHook(INTERACTION, 'FinalizeChatterOptions', function (self, optionCount)
        local opt = INTERACTION.optionControls[1]
        if not opt then return end

        local opt_text = opt:GetText()

        if AW.searches[AW_LANG]["quests"][opt_text] == "master_writ" then
            -- check to see which options are enabled
            -- the relevant two here are:
            -- 1. only accept on a specific character name
            -- 2. prompt before accept
     
            -- this happening seems unlikely? but possible
            if opt.optionIndex ~= AcceptOfferedQuest then return end

            --if blockQuest and 
            --if AutoWrit_sv["auto_decline"] then 
            --    zo_callLater(function ()
            --        INTERACTION:CloseChatter()
            --    end, 150)
            --    return
            --end

            opt.optionIndex = function (...)
                accept_writ = true

                if AutoWrit_sv["no_accept"] then
                    if AutoWrit_sv["no_accept_name"] ~= GetUnitName("player") then
                        accept_writ = false
                        CHAT_SYSTEM:AddMessage("[AutoWrit] Declining master writ. Current player is not " .. AutoWrit_sv["no_accept_name"] .. ".")
                    end
                end

                if not accept_writ then return end

                if not AutoWrit_sv["prompt_before_accept"] then
                    AcceptOfferedQuest()
                else
                    local function callback ()
                        AcceptOfferedQuest()
                    end

                    ZO_Dialogs_ShowPlatformDialog("CONFIRM_ACCEPT_MASTER_WRIT", {callback=callback}, {})
                end
            end
        end
    end)
end
 
function AutoWrit.OnAddOnLoaded(event, addonName)
    if addonName == AutoWrit.name then
        AutoWrit:Initialize()
    end
end

function AW.OnInteractBegin (...)
    local numopts = GetChatterOptionCount()

    for i = 1, numopts do
        local text, _, _, _, _ = GetChatterOption(i)

        if AW.searches[AW_LANG]["chatters"][text] ~= nil then
            local writ_type = AW.searches[AW_LANG]["chatters"][text]

            if (writ_type == "auto_handin" and AutoWrit_sv[writ_type]) or AutoWrit_sv["auto_accept"] then
                SelectChatterOption(i)
                break
            end
        end
    end
end

function AW.OnQuestOffer (...)
    if not AutoWrit_sv["auto_accept"] then return end

    local text, val = GetOfferedQuestInfo()

    local opts = AW.searches[AW_LANG]["quests"]

    for match, writ_type in pairs(opts) do
        if text:match(match) then
            if AutoWrit_sv[writ_type] == true then
                AcceptOfferedQuest()
                zo_callLater(AW.OnInteractBegin, 1000)
                break
            end
        end
    end
end

function AW.OnQuestComplete (event, index)
    local val, val2, _ = GetJournalQuestEnding(index)

    local opts = AW.searches[AW_LANG]["handins"]

    for match, handin_type in pairs(opts) do
        if val:match(match) or val2:match(match) then
            if AutoWrit_sv[handin_type] == true then
                CompleteQuest()
            end
        end
    end
end

EVENT_MANAGER:RegisterForEvent(AutoWrit.name, EVENT_ADD_ON_LOADED, AutoWrit.OnAddOnLoaded)

EVENT_MANAGER:RegisterForEvent(AutoWrit.name, EVENT_CHATTER_BEGIN, AW.OnInteractBegin)
EVENT_MANAGER:RegisterForEvent(AutoWrit.name, EVENT_QUEST_OFFERED, AW.OnQuestOffer)
EVENT_MANAGER:RegisterForEvent(AutoWrit.name, EVENT_QUEST_COMPLETE_DIALOG, AW.OnQuestComplete)
