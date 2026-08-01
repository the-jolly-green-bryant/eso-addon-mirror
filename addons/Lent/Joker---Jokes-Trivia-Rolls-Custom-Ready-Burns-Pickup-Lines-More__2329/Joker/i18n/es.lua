JokerL = JokerL or {}
local L = {}

--------------------------------------------------------------------------------------------------------------------
-- Locale: Espanol
-- All strings currently need translated, any help welcome! 
-- Uncomment to enable translated line.
--------------------------------------------------------------------------------------------------------------------

-- -- Basic / General
-- L.Joker_Title = "Joker"
-- L.Joker_Or = "or"
-- L.Joker_And = "and"
-- L.Joker_Of = "of"
-- L.Joker_With = "with"

-- -- SECTION: Intro
-- L.Joker_Intro_Status_Prefix = "You've viewed ~"
-- L.Joker_Intro_Status_Middle = "of"
-- L.Joker_Intro_Status_Suffix	= "loaded jokes, burns, wisdom, fun facts, & more!"

-- -- SECTION: Quick Commands
-- L.Joker_Quick_Title = "Quick Commands"
-- L.Joker_Quick_Subtitle = "Click a button below to get a joke!"
-- L.Joker_Quick_Desc = "Joker will post a joke to your chatbox - just hit 'Enter' to send! Whenever possible, Joker will try to show you jokes you haven't seen before."
-- L.Joker_QuickPop_Desc = "Movies, TV, Pop Culture"
-- L.Joker_QuickUtil_Desc = "Other / Utility"

-- -- Quick Command Buttons (Jokes)
-- L.Joker_Quick_Btn_Joke = "Any Joke"
-- L.Joker_Quick_Btn_Joke_Tip = "Retrieves a random joke of any kind (edgy/adult jokes not included) and pastes in your chatbox!"
-- L.Joker_Quick_Btn_JokeESO = "ESO Joke"
-- L.Joker_Quick_Btn_JokeESO_Tip = "Adds a random ESO-related joke to your active chatbox."
-- L.Joker_Quick_Btn_JokeDad = "Dad Joke"
-- L.Joker_Quick_Btn_JokeDad_Tip = "Adds a random Dad joke to your active chatbox."
-- L.Joker_Quick_Btn_JokeGoT = "Game of Thrones"
-- L.Joker_Quick_Btn_JokeGoT_Tip = "Adds a random Game of Thrones joke to your active chatbox."
-- L.Joker_Quick_Btn_JokeWisdom = "Wisdom"
-- L.Joker_Quick_Btn_JokeWisdom_Tip = "Adds a random wisdom tidbit or shower thought to your active chatbox"
-- L.Joker_Quick_Btn_JokeEdgy = "Edgy Joke"
-- L.Joker_Quick_Btn_JokeEdgy_Tip = "Adds a random edgy joke to your active chatbox. Note that these jokes have been flagged as particularly inappropriate or explicit and likely are *not* suitable for all audiences. Please be considerate with your usage!"
-- L.Joker_Quick_Btn_JokeNorris = "Chuck Norris"
-- L.Joker_Quick_Btn_JokeNorris_Tip = "Adds a random Chuck Norris joke to your active chatbox. See the /slash command for advanced options!"
-- L.Joker_Quick_Btn_JokePickup = "Pickup Line"
-- L.Joker_Quick_Btn_JokePickup_Tip = "Adds a random cheesy/cute pickup line to your active chatbox. See the /slash command for advanced options!"
-- L.Joker_Quick_Btn_JokePickupXXX = "Pickup (Adult)"
-- L.Joker_Quick_Btn_JokePickupXXX_Tip = "Adds a random adult/r-rated pickup line to your active chatbox. Note that these jokes have been flagged as particularly inappropriate or explicit and likely are not suitable for all audiences. See the /slash command for advanced options!"
-- L.Joker_Quick_Btn_JokePickupHP = "Pickup (Harry Potter)"
-- L.Joker_Quick_Btn_JokePickupHP_Tip = "Adds a random Harry Potter pickup line to your active chatbox. See the /slash command for advanced options!"
-- L.Joker_Quick_Btn_JokeBurn = "Burn"
-- L.Joker_Quick_Btn_JokeBurn_Tip = "Adds a random burn to your active chatbox. See the /slash command for advanced options!"


-- -- Quick Command Buttons (Other/Utility)
-- L.Joker_Quick_Btn_Joke8Ball = "8ball"
-- L.Joker_Quick_Btn_Joke8Ball_Tip = "Undecided? Get advice from the sage 8ball."
-- L.Joker_Quick_Btn_JokeTwister = "Tongue Twister"
-- L.Joker_Quick_Btn_JokeTwister_Tip = "Get a random tongue twister! Can you say it 3 times fast?"
-- L.Joker_Quick_Btn_JokeCatFact = "Cat Fact"
-- L.Joker_Quick_Btn_JokeCatFact_Tip = "Get a random Khaji--err, cat fact in your chatbox. Sometimes they're true!"
-- L.Joker_Quick_Btn_JokeReady = "Ready Check"
-- L.Joker_Quick_Btn_JokeReady_Tip = "Ready checks, but funnier & faster! Leerrooyyyyyyy Jeeenkinnssssss!"


-- -- SECTION: Options
-- L.Joker_Options_Title	= "Customize Options"
-- L.Joker_Options_Periodic = "Show me jokes periodically"
-- L.Joker_Options_Periodic_Tip	= "Joker can periodically post a joke to your chat window (only visible to you)!"
-- L.Joker_Options_PeriodicFrequency = "How often should Joker send you a joke?"
-- L.Joker_Options_PeriodicFrequency_Tip	= "This is the frequency ceiling at which Joker sends (just you) a joke. Joker procedurally increase joke chance based on number of zones since last joke (with a guaranteed occurence at the ceiling you set). The lower the value, the more often jokes will appear!"

-- -- SECTION: Available Commands
-- L.Joker_Commands_Title = "/Slash Commands"

-- -- SECTION: More Jokes
-- L.Joker_More_Title = "Want More Jokes?"

-- -- SECTION: Legal
-- L.Joker_Legal_Title	 = "Credits & Legal"

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'es') then -- Overwrite GetLanguage for new language
	for k,v in pairs(JokerL:GetLanguage()) do
		if (not L[k]) then -- No translation for this string, use default
			L[k] = v
		end
	end
	function JokerL:GetLanguage() -- set new language return
		return L
	end
end
