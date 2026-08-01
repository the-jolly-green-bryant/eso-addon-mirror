-- * _JOKER_VERSION: 0.0.1 ** Please do not modify this line.
--[[----------------------------------------------------------
	Joker - Jokes, Riddles, Fun Facts, & Other Tomfoolery
  ----------------------------------------------------------
  *
  * ADDING YOUR OWN JOKES:
  * Be aware that modifying this file incorrectly could break Joker,
  * so for normal users I recommend just compiling your jokes in the
  * '_MyCustomJokes.lua' file instead.
  *
  * COMPILATION: Riddles
	*
  * SOURCES:
  * pun.me,
  * smart-words.org,
  * Reddit Search, 
  * Google Search
	*
]]--

JokerData = JokerData or {}
JokerData.Config = JokerData.Config or {}

JokerData.Config.Riddles = {
  label = "Riddles",
  command = "riddles",
  nsfw = false,
  joke = false,
  disable = true,
  whitelistSlashCommand = true
}

JokerData.Riddles = {
  ""
}
