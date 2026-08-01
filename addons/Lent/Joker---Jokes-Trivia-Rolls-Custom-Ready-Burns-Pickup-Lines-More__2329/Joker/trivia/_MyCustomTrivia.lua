-- * _JOKER_VERSION: 0.0.1 ** Please do not modify this line.
--[[----------------------------------------------------------
	Joker - Jokes, Riddles, Fun Facts, & Other Tomfoolery
  ----------------------------------------------------------
  *
  * CUSTOM TRIVIA
  * This file is intended for you to add your own custom trivia!
  *
  * INSTRUCTIONS:
  * 1. Add your trivia questions and answers in the format shown below
  * 2. Each trivia item is a table with 'q' (question) and 'a' (answer)
  * 3. Make sure to include commas between each trivia item
  * 4. The last item should NOT have a comma after it
  *
  * EXAMPLE:
  * { q = "What is the answer to life, the universe, and everything?", a = "42" },
  *
]]--

JokerData = JokerData or {}
JokerData.Config = JokerData.Config or {}

JokerData.Config.CustomTrivia = {
  label = "My Custom Trivia",
  command = "trivia-custom",
  trivia = true,
  nsfw = false,
  whitelistSlashCommand = false
}

-- Add your custom trivia below this line!
JokerData.CustomTrivia = {
  { q = "What is the best ESO addon for jokes and trivia?", a = "Joker, obviously!" },
  -- Add more trivia here...
}

