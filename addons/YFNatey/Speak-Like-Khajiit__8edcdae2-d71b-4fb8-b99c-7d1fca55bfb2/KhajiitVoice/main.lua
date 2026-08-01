local ADDON_NAME = "KhajiitVoice"
KhajiitVoice = {}
KhajiitVoice.savedVars = nil
KhajiitVoice.currentDialogueReplacements = {}
KhajiitVoice.firstAppearanceCache = {}
KhajiitVoice.defaults = {
    enabled = true,
    ElsewyrRaised = false,
    permKhajiit = false,
    pronounWeights = {
        thisOne = 70,       -- "This one" weight (humble, traditional)
        charName = 20,      -- Character name weight (personal, confident)
        khajiit = 10        -- "Khajiit" weight (generic, formal)
    },
    useCustomAlias = false, -- Toggle to use custom alias instead of character name
    customAliasText = "",
    personalityTraits = {
        replaceGoodbyes = false,
        cyrodiilicTone = 0,

        scholarlyTone = 0,
        kindSoulTone = 0
    },
}
KhajiitVoice.patterns = {
    subjectPronouns = {
        ["^[Ii] "] = true,
        [" [Ii] "] = true,
        ["^[Ii]'"] = true,
        [" [Ii]'"] = true
    },
    objectPronouns = {
        [" me"] = true,
        [" myself"] = true,
        ["^[Mm]e "] = true,
        ["^[Mm]yself "] = true
    },
    possessivePronouns = {
        [" my "] = true,
        [" mine"] = true,
        ["^[Mm]y "] = true,
        ["^[Mm]ine"] = true
    },
    khajiitExpressions = {
        farewell = {
            "May your road lead you to warm sands.",
            "Farewell.",
            "May Jone and Jode guide your steps.",
            "Until the moons bring us together again.",
            "May your path be lit by bright moons.",
        },
        greeting = {
            "Bright moons, walker - ",
            "The moons smile upon this meeting - ",
            "This one's whiskers twitch with joy at seeing you - ",
            "The winds brought whispers of your approach - ",
            "Ah, a familiar scent on the desert wind - ",
        },
        khajQuestion = {
            ", yes?"
        },

        -- Scholarly/poetic expressions
        scholarlyExpressions = {
            greetings = {
                "The moons illuminate our fateful meeting",
                "Like ancient scrolls unfurling, our paths converge",
                "The wisdom of ages whispers of your approach",
                "As ink flows upon parchment, so do our destinies intertwine",
                "The celestial dance brings us to this moment"
            },
            farewells = {
                "May the written word guide your journey's end",
                "The great library of existence awaits your next chapter",
                "As scribes preserve knowledge, so shall this one remember",
                "May your story be writ in starlight and moon-glow"
            },
            replacements = {
                ["I understand"] = "this one comprehends the deeper meaning",
                ["I know"] = "such knowledge rests within this one's learned mind",
                ["I think"] = "this one's scholarly contemplation suggests",
                ["yes"] = "indeed, as the ancient texts would agree",
                ["maybe"] = "perhaps, as the philosophers might ponder"
            },
            questionStarters = {
                -- Simple starters (for intensity < 50)
                simple = {
                    "This one wonders - ",
                    "This one is curious - ",
                    "This one must know - ",
                    "Tell this one - ",
                    "This one seeks to understand - "
                },
                -- Verbose starters (for intensity >= 50)
                verbose = {
                    "The wisdom of ages compels this one to ask - ",
                    "This one's learned mind seeks to understand - ",
                    "As the philosophers would inquire - ",
                    "This one's studies suggest the question - ",
                    "The scrolls of knowledge prompt this one to wonder - ",
                    "Curiosity drives this one to ask - ",
                    "This one begs the question - ",
                }
            }
        },
        kindSoulExpressions = {
            greetings = {
                "Blessings of the warm sands upon you, dear friend",
                "This one's heart brightens like morning sun at your presence",
                "What a lovely soul graces this one's path today",
                "Sweet stranger, the moons have brought us together with purpose",
                "This one feels such warmth in meeting you, gentle spirit",
                "Your kind aura touches this one's whiskers with joy",
                "Like a gentle breeze through the desert, you bring comfort"
            },
            farewells = {
                "May gentle winds carry you to happiness.",
                "This one's heart keeps a warm place for you always.",
                "Until we meet again",
                "May your path be lined with flowers and friendship.",
                "Soft moonlight guide your precious steps, cherished soul.",
                "This one sends you forth wrapped in warmest wishes.",
                "Go well, beautiful spirit, and know you are treasured."
            },
            replacements = {
                ["I'm sorry"] = "this one's heart aches with regret, dear friend",
                ["thank you"] = "this one's soul overflows with gratitude, sweet one",
                ["I hope"] = "this one's tender heart hopes with all its warmth",
                ["good luck"] = "may fortune smile upon your precious endeavors",
                ["I understand"] = "this one's caring heart comprehends completely",
                ["of course"] = "naturally, dear soul, with the greatest pleasure",
            },
            endearments = {
                ", friend",
                ", sweet soul",
                ", precious one",
                ", walker",
            },
            gentleActions = {
                beginnings = {
                    "<whiskers twitch with gentle joy> ",
                    "<ears flutter with tender concern> ",
                    "<eyes sparkling with warmth> ",
                    "<tail curled with affection> ",
                    "<head tilted> "
                },
                endings = {
                    " <purrs softly with contentment>",
                    " <whiskers trembling with emotion>",
                    " <eyes shining with kindness>",
                    " <tail swaying gently>",
                    " <paws placed over heart>",
                    " <soft sigh of compassion>"
                }
            },
            flowerySpeech = {
                intensifiers = {
                    ["very"] = "absolutely precious and",
                    ["really"] = "truly, from the depths of this one's heart,",
                    ["quite"] = "most beautifully",
                    ["pretty"] = "breathtakingly lovely",
                    ["nice"] = "wonderfully heartwarming",
                    ["good"] = "absolutely divine"
                }
            }
        },
    }
}
local function IsPlayerKhajiit()
    local currentCharacterId = GetCurrentCharacterId()
    local currentIsKhajiit = false

    for i = 1, GetNumCharacters() do
        local name, gender, level, classId, raceId, alliance, id, locationId = GetCharacterInfo(i)

        -- Check if this is the current character
        if id == currentCharacterId then
            currentIsKhajiit = (raceId == 9)
        end

        -- Also check if ANY character is Khajiit (for permKhajiit flag)
        if raceId == 9 then
            KhajiitVoice.savedVars.permKhajiit = true
        end
    end

    return currentIsKhajiit
end
-- Addon initialization
local function Initialize()
    -- Load saved variables using the same pattern as your working addon
    KhajiitVoice.savedVars = ZO_SavedVars:NewCharacterIdSettings("KhajiitVoiceSavedVars", 1, nil, KhajiitVoice.defaults)

    local isKhajiit = IsPlayerKhajiit()
    zo_callLater(function()
        if not isKhajiit and not KhajiitVoice.savedVars.permKhajiit then
            -- Automatically disable for non-Khajiit characters
            KhajiitVoice.savedVars.enabled = false
            KhajiitVoice:CreateSettingsMenuNonKhajiit()
        else
            KhajiitVoice.savedVars.enabled = true
            if KhajiitVoice.savedVars.enabled then
                KhajiitVoice:CreateSettingsMenuKhajiit()
            end
        end
    end, 1000)



    -- Hook into dialogue system
    KhajiitVoice:HookDialogueSystem()
end

local function OnAddOnUnloading()
    KhajiitVoice:RestoreDialogueHooks()
end

-- OnAddOnLoaded event
local function OnAddOnLoaded(event, addonName)
    if addonName == ADDON_NAME then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
        Initialize()
    end
end

-- Register for addon loaded event
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_UNLOADING, OnAddOnUnloading)



function KhajiitVoice:HookDialogueSystem()
    -- Register for interaction events
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CHATTER_BEGIN, function()
        KhajiitVoice:StartDialogueSession()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CHATTER_END, function()
        KhajiitVoice:OnDialogueEnd()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GAME_CAMERA_DEACTIVATED, function()
        local interactionType = GetInteractionType()
        if interactionType == INTERACTION_CONVERSATION or interactionType == INTERACTION_QUEST then
            KhajiitVoice:StartDialogueSession()
        end
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_INTERACTION_WINDOW_SHOWN, function()
        KhajiitVoice:StartDialogueSession()
    end)
end
