-- * _JOKER_VERSION: 0.0.1 ** Please do not modify this line.
--[[----------------------------------------------------------
	Joker - Jokes, Riddles, Fun Facts, & Other Tomfoolery
  ----------------------------------------------------------

  *
  * ADDING YOUR OWN JOKES:
  * Be aware that modifying this file incorrectly could break Joker,
  * so for normal users I recommend just compiling your checks in the
  * '_MyCustomReadyChecks.lua' file instead.
  *
  * COMPILATION: Ready-Check Prompts
	*
	* SOURCES:
  * @manavortex
  * @silvereyes333
  * Reddit search
  * Google search
	*
]]--

JokerData = JokerData or {}
JokerData.Config = JokerData.Config or {}

JokerData.Config.ReadyChecks = {
  label = "Ready Checks",
  command = "ready",
  nsfw = false,
  joke = false,
  whitelistSlashCommand = true
}

JokerData.ReadyChecks = {
  "Ready to rumble?",
  "Ready to wipe?",
  "Ready to die?",
  "I mean, it could be worse...",
  "Scared sh*tless?",
  "Time is money - let's go!",
  "Leeeroy Jenkiiiinnnns!!!", --@silvereyes333
  "Stand in front of the boss?",
  "Cat removed from keyboard?", -- @manavortex
  "Glasses on, hearing aids in?",
  "Fallen and you can't get up?",
  "It's dangerous to go alone, take us with you?",
  "Is the cake a lie?",
  "Finish him?",
  "I herd u liek mudkips?",
  "You have died of dysentery.",
  "Is the princess in another castle?",
  "Do a barrel roll?",
  "Is your body ready?",
  "All your base are belong to us?",
  "C-C-C-Combo Breaker!",
  "Take an arrow to the knee?",
  "Falcon Punch?",
  "Are the Argonians all sacrificed?", --@silvereyes333
  "Is the trash taken out?",
  "Ready to blame the healers?", --@silvereyes333
  "Leeroy, you got your fried chicken?", --@silvereyes333
  "Ready to blame the tanks?",
  "Hamsters running full speed?",
  "Liquids sufficiently distanced from keyboard?",
  "We're going to die.",
  "Legends never die.",
  "W.W.J.D. - What Would Julianos Do?"
}
