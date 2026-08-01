-- * _JOKER_VERSION: 0.0.1 ** Please do not modify this line.
--[[----------------------------------------------------------
	Joker - Jokes, Riddles, Fun Facts, & Other Tomfoolery
  ----------------------------------------------------------
  *
  * COMPILATION: Your Custom Jokes!
	*
  * SOURCES:
  * It's common practice & kindness to cite any non-original jokes:
  * e.g. https://icanhazdadjoke.com, 
  * Reddit Search, 
  * Reader's Digest,
  * My Friend Bob,
  * etc
	*
]]--

JokerData = JokerData or {}
JokerData.Config = JokerData.Config or {}

JokerData.Config.CustomJokes = {
  label = "My Custom Jokes",
  command = "custom",
  nsfw = false,
  joke = true,
  disabled = true
}

JokerData.CustomJokes = {
  "Seven days without a pun makes one weak.",
  "When does a joke become a dad joke? When it becomes apparent."
}
