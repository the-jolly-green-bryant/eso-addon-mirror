--[[
Addon:    YADE - Yet Another Dice Emulator
Author:   @tridman
File:     YADE.lua

A simple addon providing the possibility to simulate dice throws in different chat channels

]]--


YADE = {}
YADE.version = "1.1.7"
YADE.configversion = 1.1
YADE.addonname = "YADE"
YADE.wordlist = {}


YADE.defaultVar ={
  ["dicecommand"]   = "dice",
  ["pdicecommand"]  = "pdice",
  ["g1dicecommand"] = "g1dice",
  ["g2dicecommand"] = "g2dice",
  ["g3dicecommand"] = "g3dice",
  ["g4dicecommand"] = "g4dice",
  ["g5dicecommand"] = "g5dice",
  ["ldicecommand"]  = "ldice"
}

function YADE.init()

  local language = GetCVar("language.2")

  if language == "en" then YADE.wordlist = YADE_enwordlib:New() end
  if language == "de" then YADE.wordlist = YADE_dewordlib:New() end
  if language == "fr" then YADE.wordlist = YADE_frwordlib:New() end

  YADE.savedVars = ZO_SavedVars:New( "YADE_Variables", math.floor(YADE.configversion * 10 ), nil , YADE.defaultVar, nil)
  
   
    
  YADE.SetCommands()
  --YADE_Menu.CreateOptions()
  YADE.Menu:CreateOptions()
  
end

function YADE.SetCommands()
  SLASH_COMMANDS["/".. YADE.savedVars.dicecommand]   = YADE.ThrowEmote
  SLASH_COMMANDS["/".. YADE.savedVars.pdicecommand]  = YADE.ThrowParty
  SLASH_COMMANDS["/".. YADE.savedVars.g1dicecommand] = YADE.ThrowGuild1
  SLASH_COMMANDS["/".. YADE.savedVars.g2dicecommand] = YADE.ThrowGuild2
  SLASH_COMMANDS["/".. YADE.savedVars.g3dicecommand] = YADE.ThrowGuild3
  SLASH_COMMANDS["/".. YADE.savedVars.g4dicecommand] = YADE.ThrowGuild4
  SLASH_COMMANDS["/".. YADE.savedVars.g5dicecommand] = YADE.ThrowGuild5
  SLASH_COMMANDS["/".. YADE.savedVars.ldicecommand]  = YADE.ThrowLocal
  SLASH_COMMANDS["/yade"] = YADE.ShowHelp
end

function YADE.ShowHelp()

  d( "Yet Another Dice Emulator V".. YADE.version  )
  d( "--Emulates dice throws between 1 and 100 (or any given upper bound)" )
  d( "--Commands: " )
  d( "    /".. YADE.savedVars.dicecommand.. " [upper]               -- Post the dice throw to Emote Chat (currently unsupported)" )
  d( "    /".. YADE.savedVars.pdicecommand.. " [upper]              -- Post the dice throw to Patrty Chat (currently unsupported)" )
  d( "    /".. YADE.savedVars.g1dicecommand.. " [upper]             -- Post the dice throw to Guild_1 Chat (currently unsupported)" )
  d( "    /".. YADE.savedVars.g2dicecommand.. " [upper]             -- Post the dice throw to Guild_2 Chat (currently unsupported)" )
  d( "    /".. YADE.savedVars.g3dicecommand.. " [upper]             -- Post the dice throw to Guild_3 Chat (currently unsupported)" )
  d( "    /".. YADE.savedVars.g4dicecommand.. " [upper]             -- Post the dice throw to Guild_4 Chat (currently unsupported)" )
  d( "    /".. YADE.savedVars.g5dicecommand.. " [upper]             -- Post the dice throw to Guild_5 Chat (currently unsupported)" )
  d( "    /".. YADE.savedVars.ldicecommand.. " [upper]              -- Post the dice throw only in your local chatwindow (no one else will see the result)" )
  d( "    /yade                       -- Shows this help.")
    
end


function YADE.Dice(upper)
  if upper == "" then
    upper = 100
  else
    upper = tonumber(upper)
	if (upper == nil) then
		d(YADE.addonname.. "-Error: Invalid upper bound supplied! Roling a D100")
		upper = 100
	end
  end

  local random = zo_random(1, upper)
  return YADE.wordlist.THROWS_A.. upper.. YADE.wordlist.SIDES_SCORES.. random
end

function YADE.ThrowEmote(upper)
  d(YADE.addonname.. "-Error: Emote chat channel can currently not be accesssed by addons!")
  --SendChatMessage(YADE.Dice(upper), CHAT_CHANNEL_EMOTE)
end

function YADE.ThrowParty(upper)
  d(YADE.addonname.. "-Error: Party chat channel can currently not be accesssed by addons!")
  --SendChatMessage(YADE.Dice(upper), CHAT_CHANNEL_PARTY)
end

function YADE.ThrowGuild1(upper)
  d(YADE.addonname.. "-Error: Guild1 chat channel can currently not be accesssed by addons!")
  --SendChatMessage(YADE.Dice(upper), CHAT_CHANNEL_GUILD_1)
end

function YADE.ThrowGuild2(upper)
  d(YADE.addonname.. "-Error: Guild2 chat channel can currently not be accesssed by addons!")
  --SendChatMessage(YADE.Dice(upper), CHAT_CHANNEL_GUILD_2)
end

function YADE.ThrowGuild3(upper)
  d(YADE.addonname.. "-Error: Guild3 chat channel can currently not be accesssed by addons!")
  --SendChatMessage(YADE.Dice(upper), CHAT_CHANNEL_GUILD_3)
end

function YADE.ThrowGuild4(upper)
  d(YADE.addonname.. "-Error: Guild4 chat channel can currently not be accesssed by addons!")
  --SendChatMessage(YADE.Dice(upper), CHAT_CHANNEL_GUILD_4)
end

function YADE.ThrowGuild5(upper)
  d(YADE.addonname.. "-Error: Guild5 chat channel can currently not be accesssed by addons!")
  --SendChatMessage(YADE.Dice(upper), CHAT_CHANNEL_GUILD_5)
end

function YADE.ThrowLocal(upper)
  d("YADE ".. YADE.Dice(upper))
end
