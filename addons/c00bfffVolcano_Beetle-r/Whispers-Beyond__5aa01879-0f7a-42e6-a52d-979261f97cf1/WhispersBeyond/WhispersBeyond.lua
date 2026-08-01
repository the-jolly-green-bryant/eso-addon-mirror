local ADDON_NAME = "WhispersBeyond"
local savedVarsName = "WhispersBeyond_Saved"

local LAM = LibAddonMenu2

local popupLabel
local saved

local divineQuotes = {
    -- Akatosh
	"Time flows as he wills. |cFFD700Akatosh|r does not delay, nor does he forget.",
	"In the turning of stars and the silence between seconds, |cFFD700Akatosh|r keeps the world from unraveling.",
	"The first breath of creation was his roar. |cFFD700Akatosh|r began the world, and he shall end it.",

	-- Arkay
	"Do not dread the grave — |cFFD700Arkay|r records every ending, and guards what lies beyond.",
	"To be born, to live, to die — |cFFD700Arkay|r walks each path with you, unseen and ever present.",
	"The silence of the grave is not the end — it is |cFFD700Arkay's|r lullaby, sung to souls returning home.",

	-- Dibella
	"Beauty is the breath of the soul. |cFFD700Dibella|r speaks in every heartbeat that loves.",
	"Where words fail, beauty speaks. |cFFD700Dibella|r dances in every act of art and affection.",
	"What is sacred cannot be forged, only felt. |cFFD700Dibella|r dwells in every gentle touch.",

	-- Julianos
	"Wisdom is not found, but earned — |cFFD700Julianos|r teaches the mind to see what others dismiss.",
	"A sharp mind cuts deeper than any blade — |cFFD700Julianos|r offers wisdom to those who seek, not those who shout.",
	"The ignorant fear what they do not understand — |cFFD700Julianos|r blesses those who ask the second question.",

	-- Kynareth
	"The winds carry her song across the world. Breathe deep, for |cFFD700Kynareth|r is in every sky.",
	"The storm rages, the sky weeps, the breeze comforts. All are |cFFD700Kynareth's|r breath.",
	"Even the mountains bow before the sky. |cFFD700Kynareth|r teaches that true power flows, not stands still.",

	-- Mara
	"Where kindness lives, so does |cFFD700Mara|r. Her embrace binds hearts and heals all sorrow.",
	"Let your heart not harden. In |cFFD700Mara’s|r name, love endures even the coldest war.",
	"No oath binds tighter than love freely given. |cFFD700Mara|r watches the heart more than the hand.",

	-- Stendarr
	"The strong protect the weak, and the faithful shield the innocent. This is |cFFD700Stendarr’s|r will.",
	"When mercy seems weak, remember: |cFFD700Stendarr|r stands where others flee.",
	"Compassion is a sword unseen — |cFFD700Stendarr's|r justice wounds only those who prey upon the helpless.",

	-- Talos
	"From man to god, he rose. |cFFD700Talos|r reminds you: the mortal path can shake the heavens.",
	"The will of men can shake mountains — |cFFD700Talos|r proved that mortal blood need not be bound by mortal fate.",
	"He wore a crown of war and carved peace from chaos. |cFFD700Talos|r rises in the courage of mortals.",

	-- Zenithar
	"Labor is sacred. In honest work, |cFFD700Zenithar|r grants strength without sword or spell.",
	"Gold is not given, but earned. |cFFD700Zenithar|r blesses the sweat of honest hands.",
	"From hammer to harvest, the world is shaped by toil. |cFFD700Zenithar|r grants prosperity through perseverance.",
}

local daedricQuotes = {
	-- Azura
	"Twilight is the hour when secrets stir — speak softly, and |cDC143CAzura|r may answer.",
	"The dusk heralds change; |cDC143CAzura’s|r eyes pierce the veil of fate.",
	"Beneath the stars’ fading light, |cDC143CAzura|r whispers prophecy and doom.",

	-- Boethiah
	"Glory is born in betrayal; |cDC143CBoethiah|r rewards the blade that turns when least expected.",
	"Power is seized, not given. |cDC143CBoethiah’s|r blade never dulls.",
	"Victory is forged in betrayal; |cDC143CBoethiah’s|r champions know no mercy.",

	-- Clavicus Vile
	"Every deal has its price, and |cDC143CClavicus Vile|r always collects — in laughter or in loss.",
	"A smile that bargains souls, |cDC143CClavicus Vile’s|r gifts come wrapped in shadows.",
	"Promises are currency; |cDC143CClavicus Vile|r collects debts owed in blood.",

	-- Hermaeus Mora
	"The pages turn without your hand — and still |cDC143CHermaeus Mora|r knows what you will become.",
	"In forgotten tomes and whispered secrets, |cDC143CHermaeus Mora|r waits patiently.",
	"Knowledge is a curse and a gift — |cDC143CHermaeus Mora|r holds both tightly.",

	-- Hircine
	"The hunt is eternal; |cDC143CHircine|r cares not if you flee, only that you run.",
	"The thrill of the chase is eternal; |cDC143CHircine’s|r call cannot be silenced.",
	"The hunt reveals the true nature of all; |cDC143CHircine’s|r prey never rest.",

	-- Malacath
	"Scorned and broken, the strong rise through ash — |cDC143CMalacath|r does not coddle, only harden.",
	"Honor forged in pain; |cDC143CMalacath|r demands the strength to endure.",
	"From exile to warlord, |cDC143CMalacath’s|r strength is born of scorn.",

	-- Mehrunes Dagon
	"Destruction is not death — it is the seed of a world remade in Dagon’s|r image.",
	"Through fire and fury, |cDC143CMehrunes Dagon|r sculpts the new order.",
	"The world must be broken to be remade — |cDC143CMehrunes Dagon’s|r will is absolute.",

	-- Mephala
	"Webs are spun in whispers — |cDC143CMephala’s|r truths are wrapped in lies too sweet to ignore.",
	"Threads of deceit weave the tapestry of fate — |cDC143CMephala’s|r web is never broken.",
	"Secrets and shadows cloak |cDC143CMephala’s|r endless game.",

	-- Meridia
	"Light is not mercy. |cDC143CMeridia’s|r radiance burns what festers, no matter how deeply it hides.",
	"Light that burns away corruption — |cDC143CMeridia’s|r wrath is relentless.",
	"Her light sears corruption — |cDC143CMeridia’s|r crusade never ends.",

	-- Molag Bal
	"To dominate is to shape. |cDC143CMolag Bal|r breaks the self so he may mold it anew.",
	"Domination is absolute; |cDC143CMolag Bal|r claims all who resist.",
	"Chains bind bodies but not spirits — |cDC143CMolag Bal|r enslaves both.",

	-- Namira
	"Beauty fades, but |cDC143CNamira’s|r rot is eternal — she sees the worth in what others cast away.",
	"In darkness and decay, |cDC143CNamira|r finds her worshippers.",
	"Decay feeds life unseen — |cDC143CNamira’s|r embrace is both feared and desired.",

	-- Nocturnal
	"The shadow needs no permission — |cDC143CNocturnal|r moves where light dares not linger.",
	"Shadows conceal truth; |cDC143CNocturnal’s|r silence is complete.",
	"In darkness, |cDC143CNocturnal’s|r truths are revealed only to the worthy.",

	-- Peryite
	"Order comes through balance. Even pestilence has a purpose, if |cDC143CPeryite|r wills it.",
	"Balance is maintained through pestilence — |cDC143CPeryite’s|r domain is order in rot.",
	"Plague and order entwined — |cDC143CPeryite’s|r rule is harsh but just.",

	-- Sanguine
	"Joy is but a mask. Behind it, |cDC143CSanguine|r grins — ever drunk, ever watching.",
	"Pleasure and chaos dance hand in hand in |cDC143CSanguine’s|r revelry.",
	"Chaos and revelry flow from |cDC143CSanguine’s|r endless feast.",

	-- Sheogorath
	"Madness does not knock — it dances in, eats your shoes, and redecorates your spine.",
	"Madness is the key — |cDC143CSheogorath|r unlocks the mind’s hidden doors.",
	"Madness twists reality, and |cDC143CSheogorath|r laughs at the unraveling.",

	-- Vaermina
	"In sleep, you are hers. |cDC143CVaermina|r waits in dreams you will not remember but never forget.",
	"Nightmares are but dreams twisted; |cDC143CVaermina|r crafts your fears.",
	"Dreams become nightmares beneath |cDC143CVaermina’s|r watchful eye.",

	-- Jyggalag
	"There is no fate, only order. |cDC143CJyggalag|r marches where chaos once reigned, unshaken and absolute.",
	"Order will reclaim chaos; |cDC143CJyggalag’s|r march is inevitable.",
	"Where chaos falls, |cDC143CJyggalag’s|r order rises without mercy.",
	
	--Ithelia
	"Paths untaken ripple through the fabric of fate — |cDC143CIthelia|r walks where none remember to follow.",
	"Erased from memory, yet forever shaping the turning of destinies unseen — such is |cDC143CIthelia’s|r will.",
	"The road forgotten is the road chosen — to |cDC143CIthelia|r, all futures bend and sway.",
}

local divineDeathQuotes = {
    -- Akatosh
    "Time does not end with death — |cFFD700Akatosh|r turns every fall into a new beginning.",
    "Even in your final breath, the timeline flows — |cFFD700Akatosh|r watches unblinking.",
    "The wheel of time does not mourn. It moves on — with |cFFD700Akatosh|r at its helm.",

    -- Arkay
    "Fear not the end — |cFFD700Arkay|r guides every soul to its destined rest.",
    "You walk the path all must take. |cFFD700Arkay|r ensures no step is in vain.",
    "The veil is lifted, the cycle continues. |cFFD700Arkay|r receives you in silence and truth.",

    -- Dibella
    "Even in death, love lingers. |cFFD700Dibella|r cradles the heart when the body fails.",
    "Beauty lies not only in life — |cFFD700Dibella|r paints sorrow with grace.",
    "The final sigh is still sacred — |cFFD700Dibella|r kisses every soul goodbye.",

    -- Julianos
    "The last breath is not the end of learning — |cFFD700Julianos|r grants clarity beyond the veil.",
    "To pass on is to pass through wisdom’s final door — |cFFD700Julianos|r holds it open.",
    "Even in your end, knowledge persists — |cFFD700Julianos|r remembers what others forget.",

    -- Kynareth
    "The wind carries your final breath. |cFFD700Kynareth|r welcomes you to the sky’s embrace.",
    "Your spirit joins the storm — |cFFD700Kynareth|r sings your passing in the wind.",
    "From soil to sky, all return — |cFFD700Kynareth|r carries you beyond the clouds.",

    -- Mara
    "Where sorrow ends, love begins anew — |cFFD700Mara|r does not abandon the fallen.",
    "No distance is too great for her embrace — |cFFD700Mara|r walks beside every end.",
    "Grief may bloom, but |cFFD700Mara|r plants hope in its shadow.",

    -- Stendarr
    "The weak shall not fall alone. |cFFD700Stendarr|r stands beside even in death.",
    "Compassion does not fade — |cFFD700Stendarr|r holds even the broken in his grasp.",
    "Justice follows the fallen — |cFFD700Stendarr|r guards the soul beyond the sword.",

    -- Talos
    "Fall with honor — for |cFFD700Talos|r, no death is final to the worthy.",
    "You’ve earned your scars — |cFFD700Talos|r remembers every battle fought.",
    "Blood may cease, but will endures — |cFFD700Talos|r crowns the brave beyond death.",

    -- Zenithar
    "Your labor ends, but not your worth. |cFFD700Zenithar|r honors work in life and beyond.",
    "Even in rest, your hands hold value — |cFFD700Zenithar|r sees honest toil in all things.",
    "Let your spirit rest — your efforts are known to |cFFD700Zenithar|r.",
}

local daedricDeathQuotes = {
    -- Azura
    "Your death was seen in the stars. |cDC143CAzura|r waits beyond the dusk.",
    "Twilight falls once more — |cDC143CAzura|r cradles the end with grace.",
    "Even endings are beautiful in |cDC143CAzura's|r light.",

    -- Boethiah
    "Only through death may the strong rise anew. |cDC143CBoethiah|r is watching.",
    "Weakness dies screaming. |cDC143CBoethiah|r demands it.",
    "Fall in betrayal, rise in glory — such is |cDC143CBoethiah’s|r truth.",

    -- Clavicus Vile
    "A deal undone, a soul claimed — |cDC143CClavicus Vile|r never forgets a contract.",
    "This end was in fine print. |cDC143CClavicus Vile|r thanks you for reading none of it.",
    "You lost everything — just as |cDC143CClavicus Vile|r promised.",

    -- Hermaeus Mora
    "Another chapter ends. |cDC143CHermaeus Mora|r archives your failure.",
    "Your death is a footnote. |cDC143CHermaeus Mora|r remembers what you’ve forgotten.",
    "Knowledge buried with the dead — and |cDC143CHermaeus Mora|r digs deepest.",

    -- Hircine
    "The hunt does not end with death. |cDC143CHircine|r calls you back to the chase.",
    "You were prey — and worthy. |cDC143CHircine|r howls in triumph.",
    "In the stillness of your end, the wild beats louder — |cDC143CHircine|r remembers.",

    -- Malacath
    "Scorned in death, forged in pain — |cDC143CMalacath|r will make use of your fall.",
    "Pain tempers even the fallen — |cDC143CMalacath|r is not done forging you.",
    "The outcast dies alone — and |cDC143CMalacath|r respects the silence.",

    -- Mehrunes Dagon
    "Destruction is rebirth. |cDC143CMehrunes Dagon|r smiles at your undoing.",
    "Fire claims the weak — |cDC143CMehrunes Dagon|r offers no pity.",
    "Ruins remember the strong. |cDC143CMehrunes Dagon|r carves your failure in ash.",

    -- Mephala
    "One thread cut, a thousand still spin. |cDC143CMephala|r weaves your demise into her web.",
    "The blade in the dark was hers — |cDC143CMephala|r thanks you for bleeding quietly.",
    "Secrets die with the body, but |cDC143CMephala|r keeps the whispers.",

    -- Meridia
    "Your light flickers — |cDC143CMeridia|r may yet rekindle it in judgment.",
    "Even in death, filth must burn — |cDC143CMeridia|r's light cleanses all.",
    "One spark dims, but |cDC143CMeridia|r watches for signs of rebirth.",

    -- Molag Bal
    "Chains break, souls shatter — |cDC143CMolag Bal|r claims you in death as in life.",
    "This is not your freedom — |cDC143CMolag Bal|r calls it a transfer of ownership.",
    "Submission is eternal — |cDC143CMolag Bal|r binds even the fallen.",

    -- Namira
    "The rot welcomes you — |cDC143CNamira|r sees beauty in your decay.",
    "The worms feast, and |cDC143CNamira|r smiles — you are useful at last.",
    "You are now as forgotten as she prefers — |cDC143CNamira|r thanks you for the gift.",

    -- Nocturnal
    "The shadow deepens — |cDC143CNocturnal|r enfolds you in her endless veil.",
    "In darkness, your final breath fades. |cDC143CNocturnal|r listens still.",
    "Nocturnal claims the forgotten — and you are fading fast.",

    -- Peryite
    "Even death must follow order. |cDC143CPeryite|r claims what chaos leaves behind.",
    "Pestilence lingers on the soul — |cDC143CPeryite|r completes the balance.",
    "Decay does not discriminate — |cDC143CPeryite|r ensures your equilibrium.",

    -- Sanguine
    "The revel ends in silence — but |cDC143CSanguine|r will toast to your fall.",
    "Your corpse is an invitation — |cDC143CSanguine|r parties with the dead too.",
    "Drink deep, die loud — |cDC143CSanguine|r enjoys the drama.",

    -- Sheogorath
    "That was delightfully tragic! |cDC143CSheogorath|r approves of your messy exit.",
    "You died with style! Or was it a goose? |cDC143CSheogorath|r can’t tell, and doesn’t care.",
    "Your demise was as sensible as a fork in soup. Well done, says |cDC143CSheogorath|r!",

    -- Vaermina
    "You dream no more, but |cDC143CVaermina|r keeps your nightmares alive.",
    "Sleep forever, child — |cDC143CVaermina|r walks the halls of your silence.",
    "The dream ends. |cDC143CVaermina|r begins.",

    -- Jyggalag
    "Chaos dies with you. |cDC143CJyggalag|r continues his march undisturbed.",
    "Your disorder was inefficient. |cDC143CJyggalag|r corrects your failure.",
    "Order claims the fallen. |cDC143CJyggalag|r files your end neatly.",

    -- Ithelia
    "One forgotten path ends — |cDC143CIthelia|r shifts the threads once more.",
    "This death was not foretold — which pleases |cDC143CIthelia|r greatly.",
    "What is forgotten returns again — |cDC143CIthelia|r will reroute your fate.",
}

local vampireQuotes = {
    [1] = {
        "Your thirst has been awakened by the |cDC143CDaughter of Coldharbour.|r",
		"The night whispers secrets only the cursed can hear.",
		"|cDC143CLamae Bal|r watches; your blood belongs to her now.",
		"This new hunger is but the first step into eternal shadow.",
    },
    [2] = {
        "Your shadow deepens; the curse feeds your power.",
		"With every pulse, the |cDC143CDaughter’s|r ancient will strengthens within you.",
		"|cDC143CColdharbour’s|r chill burns hotter in your veins.",
		"You walk a path few dare to tread — the night is yours to command.",
    },
    [3] = {
        "Your thirst is a symphony conducted by |cDC143CLamae Bal|r herself.",
		"The blood of the living sings; answer its call with fury.",
		"You have become more shadow than flesh, a predator born of darkness.",
		"What once was torment is now your strength unleashed.",
    },
    [4] = {
        "You wear the night as a crown forged in eternal torment.",
		"|cDC143CThe Daughter of Coldharbour|r grants you dominion over the shadows.",
		"Your enemies shudder as you become the nightmare stalking their dreams.",
		"Blood is your power, and the night bends to your will.",
    },
}

local vampireStageFadeQuotes = {
    [1] = {
		"The curse slips away… but the night still calls.",
		"|cDC143CColdharbour’s|r grasp loosens, yet your thirst lingers.",
		"You taste freedom, but shadows cling to your soul.",
		"|cDC143CLamae Bal’s|r whisper fades, but does not vanish.",
	},
    [2] = {
		"The darkness recedes, but the hunger haunts still.",
		"The bond bends, not breaks — and she knows you’ll return.",
		"Your power dims, yet the night watches patiently.",
		"|cDC143CThe Daughter’s|r chill loosens its grip — yet your soul still shivers.",
	},
    [3] = {
		"Your crown slips, yet darkness still follows your steps.",
		"The night’s dominion wanes, but does not surrender.",
		"You fade from nightmare into restless twilight.",
		"|cDC143CThe Daughter’s|r grip loosens, but her presence lingers.",
	},
    [4] = {
		"Your claws retract, but the beast waits in silence.",
		"The shadow within ebbs, yet the curse endures.",
		"You lose strength, but the thirst remains unquenched.",
		"No dawn fully breaks over one touched by |cDC143CColdharbour.|r",
	},
}

--========================--
--       UI ELEMENTS     --
--========================--

local function CreatePopupLabel()
    local label = WINDOW_MANAGER:CreateTopLevelWindow("WhispersBeyondPopup")
    label:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    label:SetDimensions(600, 50)
    label:SetHidden(true)

    local text = WINDOW_MANAGER:CreateControl(nil, label, CT_LABEL)
    text:SetAnchor(CENTER, label, CENTER, 0, -100)

    local uiScale = tonumber(GetSetting(SETTING_TYPE_UI, UI_SETTING_CUSTOM_SCALE)) or 1.0
    local scaledFontSize = math.floor(32 * uiScale) -- 32 is your base font size

    text:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thin", scaledFontSize))
    text:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    text:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    label.text = text
    return label
end


--========================--
--     POPUP HANDLERS     --
--========================--

local function ShowPopupMessage(text)
    if not popupLabel or not popupLabel.text then return end -- safety check

    popupLabel.text:SetText(text)
    popupLabel:SetAlpha(0)
    popupLabel:SetHidden(false)

    local timeline = ANIMATION_MANAGER:CreateTimeline()
    timeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)

    -- Fade-in
    local fadeIn = timeline:InsertAnimation(ANIMATION_ALPHA, popupLabel, 0)
    fadeIn:SetDuration(1000)
    fadeIn:SetAlphaValues(0, 1)
    fadeIn:SetEasingFunction(ZO_EaseInOutQuad)

    -- Fade-out
    local fadeOut = timeline:InsertAnimation(ANIMATION_ALPHA, popupLabel, 6000)
    fadeOut:SetDuration(1200)
    fadeOut:SetAlphaValues(1, 0)
    fadeOut:SetEasingFunction(ZO_EaseInOutQuad)

    timeline:SetHandler("OnStop", function()
        popupLabel:SetHidden(true)
    end)

    timeline:PlayFromStart()
end

local function ShowRandomMessage()
    if not saved or not saved.mode then return end
    local quotePool = (saved.mode == "Daedric") and daedricQuotes or divineQuotes
    local quote = quotePool[math.random(#quotePool)]
    ShowPopupMessage(quote)
end

local function ShowRandomDeathMessage()
    if not saved or not saved.mode then return end
    local quotePool = (saved.mode == "Daedric") and daedricDeathQuotes or divineDeathQuotes
    local quote = quotePool[math.random(#quotePool)]
    ShowPopupMessage(quote)
end

local function ShowRandomVampireQuote(stage)
    local quotes = vampireQuotes[stage]
    if quotes and #quotes > 0 then
        local quote = quotes[math.random(#quotes)]
        ShowPopupMessage(quote)
    end
end

local function ShowRandomVampireFadingQuote(stage)
    local quotes = vampireStageFadeQuotes[stage]
    if quotes and #quotes > 0 then
        local quote = quotes[math.random(#quotes)]
        ShowPopupMessage(quote)
    end
end

local function UpdateChampionPointEnlightenmentVisibility()
    if saved and saved.hideCPEText then
        if ZO_ChampionPointsEnlightenmentControl then
            ZO_ChampionPointsEnlightenmentControl:SetHidden(true)
        end
    else
        if ZO_ChampionPointsEnlightenmentControl then
            ZO_ChampionPointsEnlightenmentControl:SetHidden(false)
        end
    end
end

--========================--
--     CHOICE DIALOG      --
--========================--

local function ShowInitialChoiceDialog()
    ZO_Dialogs_RegisterCustomDialog("WHISPERS_BEYOND_CHOICE_DIALOG", {
        title = { text = "|cff8c00Whispers Beyond|r" },
        mainText = { text = "|cFFFFFFChoose your path:|r\nWalk with the Divines or heed the Daedric whispers?" },

        buttons = {
            {
                text = "|cFFD700Divine|r",
                callback = function()
                    saved.mode = "Divine"
                    saved.firstRunComplete = true
                    ShowRandomMessage()
                end,
            },
            {
                text = "|cDC143CDaedric|r",
                callback = function()
                    saved.mode = "Daedric"
                    saved.firstRunComplete = true
                    ShowRandomMessage()
                end,
            },
        },

        -- This ensures dialog cannot be queued multiple times
        canQueue = false,

        -- Gamepad support
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.BASIC,
            allowRightStickPassThrough = true,
            header = {
                titleText = "|cff8c00Whispers Beyond|r",
            },
        },
		
        buttonsGamepad = {
            [1] = {
                text = "|cFFD700Divine|r",
                callback = function()
                    saved.mode = "Divine"
                    saved.firstRunComplete = true
                    ShowRandomMessage()
                end,
            },
            [2] = {
                text = "|cDC143CDaedric|r",
                callback = function()
                    saved.mode = "Daedric"
                    saved.firstRunComplete = true
                    ShowRandomMessage()
                end,
            },
        },
    })

    ZO_Dialogs_ShowDialog("WHISPERS_BEYOND_CHOICE_DIALOG")
end

--========================--
--     EVENT HANDLERS     --
--========================--

local VAMPIRE_STAGE_BUFFS = {
    [135397] = 1,
    [135399] = 2,
    [135400] = 3,
    [135402] = 4,
}

local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if unitTag ~= "player" then return end

    local newStage = VAMPIRE_STAGE_BUFFS[abilityId]
    if not newStage then return end

    if not saved.previousVampireStage then
        saved.previousVampireStage = newStage
        return
    end

    if newStage > saved.previousVampireStage then
        zo_callLater(function()
            ShowRandomVampireQuote(newStage)
        end, 100)
    elseif newStage < saved.previousVampireStage then
        zo_callLater(function()
            ShowRandomVampireFadingQuote(saved.previousVampireStage)
        end, 100)
    end

    saved.previousVampireStage = newStage
end


local function OnPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
    zo_callLater(function()
        if not saved or not saved.firstRunComplete then
            ShowInitialChoiceDialog()
        else
            ShowRandomMessage()
        end
    end, 100)
end

local function OnPlayerLevelChanged(_, unitTag, level, oldLevel)
    if unitTag == "player" and level > oldLevel then
        zo_callLater(ShowRandomMessage, 100)
    end
end

local function OnChampionPointsChanged(_, unitTag, current, previous)
    if unitTag == "player" and current > previous then
        zo_callLater(ShowRandomMessage, 100)
    end
end

local function OnPlayerDeath(_, unitTag, isDead)
    if unitTag == "player" and isDead then
        zo_callLater(ShowRandomDeathMessage, 100)
    end
end

--========================--
--   ADDON SETTINGS MENU  --
--========================--

local function CreateSettingsMenu()
    local panelData = {
        type = "panel",
        name = "Whispers Beyond",
        author = "Volcano_Beetle",
        version = "1.0.6",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel("WhispersBeyondOptions", panelData)

    local optionsData = {
        {
            type = "dropdown",
            name = "Choose your path:",
            choices = { "Divine", "Daedric" },
            getFunc = function() return saved and saved.mode or "Divine" end,
            setFunc = function(value) 
                if saved then saved.mode = value end
            end,
            default = "Divine",
        },
		{
            type = "checkbox",
            name = "Hide Champion Point Enlightenment Text",
            tooltip = "Toggle to hide the 'Champion points gained at an accelerated rate' text.",
            getFunc = function() return saved and saved.hideCPEText or false end,
            setFunc = function(value)
                if saved then
                    saved.hideCPEText = value
                    UpdateChampionPointEnlightenmentVisibility()
                end
            end,
            default = false,
        },
    }

    LAM:RegisterOptionControls("WhispersBeyondOptions", optionsData)
end

--========================--
--     ADDON LOADING      --
--========================--

local function OnAddonLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end

    saved = ZO_SavedVars:NewAccountWide(savedVarsName, 1, nil, {
        mode = "Divine", -- default to Divine so saved.mode is never nil
        firstRunComplete = false,
    })

    popupLabel = CreatePopupLabel()
    CreateSettingsMenu()
	UpdateChampionPointEnlightenmentVisibility()

	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_EFFECT_CHANGED, OnEffectChanged)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_LEVEL_CHANGED, OnPlayerLevelChanged)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CHAMPION_POINTS_CHANGED, OnChampionPointsChanged)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_UNIT_DEATH_STATE_CHANGED, OnPlayerDeath)

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
