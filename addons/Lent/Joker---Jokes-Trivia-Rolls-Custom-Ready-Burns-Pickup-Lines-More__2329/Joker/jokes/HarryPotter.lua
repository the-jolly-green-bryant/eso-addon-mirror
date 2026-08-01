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
  * COMPILATION: Harry Potter jokes
	*
	* SOURCES:
  * http://pun.me,
  * Reddit Search, 
  * Google Search,
  * http://jokes4us.com
  *
	*
]]--

JokerData = JokerData or {}
JokerData.Config = JokerData.Config or {}

JokerData.Config.HarryPotter = {
  command = "potter",
  disable = true,
  label = "Harry Potter",
  joke = true,
  nsfw = false,
  whitelistSlashCommand = true
}

JokerData.HarryPotter = {

}
