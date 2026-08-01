-- * _JOKER_VERSION: 0.0.1 ** Please do not modify this line.
--[[----------------------------------------------------------
	Joker - Jokes, Riddles, Fun Facts, & Other Tomfoolery
  ----------------------------------------------------------
  *
	* Authors:
	* - Lent (IGN @CallMeLent, Github @adefee)
  *
  * Contents:
  * - Base/Default Joker variables, can be overwritten by /options/customize
  *
]]--

JokerData = JokerData or {} -- Content
JokerData.Config = JokerData.Config or {} -- content-specific config
JokerL = JokerL or {} -- i18n

Joker = {
  name = "Joker",
  version = "8.7.1",
  versionESO = 807100,
  author = "Lent (IGN @CallMeLent, Github @adefee)",
  color = "D66E4A",
  locale = JokerL:GetLanguage(),
  attribution = {
    -- guildName = "Chaotic Redemption (NA)",
    -- guildNameLink = "|cFF0000|H1:guild:610211|hChaotic Redemption|h|r (NA)",
    -- guildID = "",
    -- guildURL = "",
    -- guildDiscord = "https://tinyurl.com/chaotic-discord",
    -- guildDiscordAlt = "https://discord.gg/VWDXkzA",
    author = "Lent",
    authorIGN = "@CallMeLent",
    authorDiscord = "Lent#1337",
    authorGit = "@adefee"
  },
  sadMessages = {
    "Joker is sad!",
    "Sad Joker!",
    "Bad Joker!",
    "Oof.",
    "Aww shucks!",
    "Dammit, Wanda!",
    "Unfortunate."
  },
  happyMessages = {
    "Awesome!",
    "Joker is happy.",
    "Wicked!",
    "Oh yeahhhh!",
    "Swag!",
    "Hot damn!",
    "Sweet!",
    "Joker can dig it!",
    "**Happy dance**"
  },
  utility = {},
  data = {},
  saved = {},
  defaults = {
    activeIntros = {
      "Hey, jTarget, ",
      "Yo, jTarget, ",
      "jTarget, ",
      "jTarget! ",
      "jTarget - ",
      "Listen up, jTarget, ",
      "Check it out, jTarget, ",
      "Guess what, jTarget? ",
      "Oh, jTarget... ",
      "So, jTarget, ",
      "Alright, jTarget, ",
      "Look here, jTarget, ",
      "Hey there, jTarget, ",
      "Psst, jTarget, ",
      "You know what, jTarget? ",
      "Listen here, jTarget, ",
      "Attention, jTarget! ",
      "My dear jTarget, ",
    },
    contentFilter = {
      nsfw_enable = 1,
      nsfw_sendToPublic = 0,
      nsfw_sendToGuild = 1,
      nsfw_sendToFriend = 1,
      spam_enable = 1,
      spam_limit = 3,
      spam_trackChannelsSeparately = 1,
      spam_includeTargetedContent = 0,
      spam_channelTracking = {}
    },
    count = {
      loaded = 0,
      active = 0,
      seen = 0,
      seenAllTime = 0, -- Total jokes viewed all-time (never decreases)
      categories = {},
      triviaLoaded = 0,
      triviaActive = 0,
      triviaSeen = 0,
      triviaSeenAllTime = 0, -- Total trivia viewed all-time (never decreases)
      triviaCategories = {}
    },
    enable = {
      jokeIntros = 1, -- Replace intros (like in burns/pickup lines). Default 1
      contentFilter = 0, -- Enable content filter. Default 0
      consoleOnly = false, -- Show jokes only in console/log, never post to chatbox. Default 0
      triviaPrefixes = 1 -- Show "Q:" and "A:" prefixes in trivia output. Default 1
    },
    internal = {
      lastUpdate = 0,
      enableUpdates = 0,
      firstLoad = 1,
      showDebug = 0
    },
    newsPrefixes = {
      "Today's top story: ",
      "Our top story tonight: ",
      "In the news today: ",
      "Our top story today: ",
      "Tonight at 6: ",
      "This just in: ",
      "Breaking news: ",
      "News flash: ",
      "In other news: ",
      "According to sources: ",
      "We're getting reports that ",
      "Eyewitnesses claim that ",
      "Developing story: ",
      "Live from the scene: ",
      "An anonymous tip reveals that ",
      "Our correspondent reports that ",
      "Unconfirmed reports suggest that ",
      "In a shocking turn of events, ",
      "Exclusive coverage: ",
      "We interrupt this program to report that ",
      "Sources close to the matter say ",
      "Late breaking news: ",
      "Tonight's headline: ",
      "Coming up next: ",
      "Stay tuned, because ",
    },
    periodic = {
      jokes_enable = 1,
      jokes_frequency = 1,
      jokes_lastSeen = 0,
      health_enable = 1,
      health_frequency = 1, -- Integer number of hours after lastSeen to show message
      health_lastSeen = 0 -- Timestamp in seconds a message was last seen or that user logged in
    },
    randomPool = {
      blacklist = {"Burns", "Curse", "CustomJokes", "CustomReadyChecks", "Edgy", "PickupLines", "PickupLinesXXX", "PickupLinesHP", "PickupLinesPokemon", "ReadyChecks", "Riddles"},
      enabledCategories = {}
    },
    randomPoolTrivia = {
      blacklist = {},
      enabledCategories = {}
    },
    rolls = {
      syncWhenAble = 1,
      postToChat = 0
    },
    seenJokes = {
    },
    seenTrivia = {
    }
  }
}
