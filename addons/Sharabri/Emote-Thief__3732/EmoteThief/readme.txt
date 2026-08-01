Ever wanted to use a personality's unique emotes without needing to use the personality itself? This addon provides new commands to allow this.

The following commands will be included by default if you own the personality they are taken from. Please note that they won't work if you are using a polymorph that has its own unique personality.

Minstrel personality:
/bluelute (/lute)
/flute2 (/flute)
/tambourine (/drum)

Passion's Muse personality:
/harp (/lute)
/balance (/stretch)
/plantlight (/ritual)

Deadlands Firewalker personality:
/fireorb (/doom)

Jester personality:
/jestercheer (/cheer)
/breathefire (/spit)

Scholar personality: 
/kneelwithbook (/kneel)

Swashbuckler personality:
/telescope (/search)

Telvanni Magister personality:
/read2books (/read)
/jugglelight (/juggleflame)
/playwithlight (/ritual)

Treasure Hunter personality:
/crouchwithtorch (/crouch)
/readwithtorch (/read)

Worm Wizard personality:
/summonskull (/doom)
/summonskeleton (/ritual)

Maniacal Jester personality:
/maniacal (/idle2)

Master of Schemes personality:
/stoneorb (/doom)


If you want to add an emote from one of your owned personalities that isn't listed here, EmoteThief allows you to register a new command for this!

- Go to your Collections menu and make sure you know the name of the personality the emote is from and the command to play that emote while using the personality.
- Use the command "/searchpersonality name" where name is the name of the personality you would like to add emotes from.
- This displays the ID for the personality, and a list of the personality's unique emotes with their index numbers.
- Now use the command "/stealemote command_name personalityID emoteID" where personalityID is the ID for the personality and emoteID is the index for the emote. This will create a new / command where command_name is the new command to be typed. 

For example. If you want to make a command for the drunk personality's "/drink" emote, type "/searchpersonality Drunk" to get the needed numbers, then "/stealemote getdrunk 368 8" to create the command. You will now be able to use "/getdrunk" as an emote.
