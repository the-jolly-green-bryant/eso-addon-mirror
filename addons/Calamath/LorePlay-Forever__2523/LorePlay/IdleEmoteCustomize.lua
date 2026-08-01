LorePlay = LorePlay or {}

-- --- definitions : LPEmotesTable.lua
local LPEmotesTable = LPEmotesTable or {}
local customIdleEmotesTable = LPEmotesTable.idleEmotesTable or {}


-- ===========
-- HOW TO USE
-- ===========
-- (1) Create LorePlayUserData folder in your AddOns folder.
-- (2) Copy and paste this file, IdleEmoteCustomize.lua, into the folder you created.
-- (3) Modify the emote table in the copied file as you like.
-- (4) Back up the important file you edited (don't forget!).

-- ===============
-- THINGS TO KNOW
-- ===============
-- * This file contains the latest list of emote index list. But the numbers in the ist may be reassigned in the future when the ESO base game is updated.
-- * This file includes the idle emotes tables created by the original author. It was created by copying and pasting rows from the emote index list.
-- * By copying and pasting rows from the emote index list into the idle emotes table, you can customize idle emotes to your favorite style.
-- * The reason for copying and pasting into the LorePlayUserData folder is to prevent Minion from replacing your modified version of the file when updating the add-on.
-- * This file and modified versions thereof shall not be bound by the license of this add-on. Enjoy!  -- Calamath

-- -----------------------------------
-- Emote Index List based on Update 50
-- -----------------------------------
--[[
    1  ,    -- /torch                   Set fire with torch
    2  ,    -- /wand2                   Use wand
    3  ,    -- /whistle                 Whistle
    4  ,    -- /horn                    Blow horn
    5  ,    -- /lute                    Play lute
    6  ,    -- /flute                   Play flute
    7  ,    -- /drum                    Play drum
    8  ,    -- /drink                   Drinking from flagon
    9  ,    -- /eat2                    Eat bread quickly
    10 ,    -- /read                    Read book
    11 ,    -- /potion                  Drink potion
    12 ,    -- /angry                   Angry
    13 ,    -- /applaud                 Applaud
    14 ,    -- /approve                 Approve
    15 ,    -- /armscrossed             Arms crossed
    16 ,    -- /beckon                  Beckon
    17 ,    -- /comehere                Come here
    18 ,    -- /come                    Beckon
    19 ,    -- /plead                   Plead
    20 ,    -- /bless                   Bless
    21 ,    -- /kiss                    Blow Kiss
    22 ,    -- /shout                   Shout
    23 ,    -- /boo                     Booing
    24 ,    -- /bow                     Bow
    25 ,    -- /cheer                   Cheer
    26 ,    -- /fistpump                Fistpump
    27 ,    -- /cower                   Cower
    28 ,    -- /cuckoo                  Cuckoo
    29 ,    -- /disapprove              Disapprove
    30 ,    -- /disgust                 Disgust
    31 ,    -- /downcast                Downcast
    32 ,    -- /exasperated             Exasperated
    33 ,    -- /facepalm                Facepalm
    34 ,    -- /followme                Follow me
    35 ,    -- /give                    Give
    36 ,    -- /take                    Take
    37 ,    -- /stop                    Stop
    38 ,    -- /handsonhips             Hands on hips
    39 ,    -- /handtoheart             Hand to heart
    40 ,    -- /headscratch             Scratch head
    41 ,    -- /laugh                   Laugh
    42 ,    -- /yes                     Yes
    43 ,    -- /no                      No
    44 ,    -- /payme                   Pay me
    45 ,    -- /point                   Point forward
    46 ,    -- /pointb                  Point behind
    47 ,    -- /pointd                  Point down
    48 ,    -- /pointl                  Point left
    49 ,    -- /pointr                  Point right
    50 ,    -- /self                    Point to self
    51 ,    -- /poke                    Poke
    52 ,    -- /pray                    Pray
    53 ,    -- /push                    Push
    54 ,    -- /rubhands                Rub hands
    55 ,    -- /rude                    Rude gesture
    56 ,    -- /salute                  Salute 1
    57 ,    -- /salute2                 Salute 2
    58 ,    -- /salute3                 Salute 3
    59 ,    -- /saluteloop              Salute Loop 1
    60 ,    -- /saluteloop2             Salute Loop 2
    61 ,    -- /saluteloop3             Salute Loop 3
    62 ,    -- /shakefist               Shake fist
    63 ,    -- /scared                  Scared
    64 ,    -- /cold                    Shiver cold
    65 ,    -- /shh                     Shush
    66 ,    -- /welcome                 Welcome
    67 ,    -- /surprised               Surprised
    68 ,    -- /threaten                Threaten
    69 ,    -- /thumbsdown              Thumbs down
    70 ,    -- /wave                    Waving
    71 ,    -- /crying                  Weep
    72 ,    -- /dance                   Dance
    73 ,    -- /dismiss                 Dismiss 1
    74 ,    -- /goaway                  Dismiss 2
    75 ,    -- /leaveme                 Dismiss 3
    76 ,    -- /beg                     Beg
    77 ,    -- /nod                     Nod head
    78 ,    -- /brushoff                Brush off shoulder
    79 ,    -- /dancedrunk              Dance drunk
    80 ,    -- /dustoff                 Dust off
    81 ,    -- /shrug                   Shrug
    82 ,    -- /preen                   Preening
    83 ,    -- /scratch                 Head scratch
    84 ,    -- /jumpingjacks            Jumping jacks
    85 ,    -- /pushups                 Push-ups strong
    86 ,    -- /pushup                  Push-ups weak
    87 ,    -- /you                     You
    88 ,    -- /knock                   Knock on door
    89 ,    -- /pour                    Pour
    90 ,    -- /sick                    Sickened
    91 ,    -- /stretch                 Stretch
    92 ,    -- /tilt                    Tilt head
    93 ,    -- /wagfinger               Wag finger
    94 ,    -- /whisper                 Whisper
    95 ,    -- /phew                    Wipe brow
    96 ,    -- /yawn                    Yawn
    97 ,    -- /celebrate               Celebration
    98 ,    -- /ritual                  Ritual
    99 ,    -- /sit                     Sit ground
    100,    -- /sitchair                Sit chair
    101,    -- /crouch                  Crouch
    102,    -- /kneel                   Kneel
    103,    -- /humble                  Humble
    104,    -- /kneelpray               Kneel praying
    105,    -- /beggar                  Beggar
    106,    -- /shieldeyes              Shield eyes
    107,    -- /prov                    Stir Bowl
    108,    -- /touch                   Touch
    109,    -- /kick                    Kick
    110,    -- /search                  Search
    111,    -- /thank                   Thank You
    112,    -- /hammer                  Hammer crate
    113,    -- /situps                  Situps
    114,    -- /breathless              Breathless
    115,    -- /playdead                Play dead
    116,    -- /sleep                   Sleep side
    117,    -- /overhere                Over here
    118,    -- /sleep2                  Sleep back
    119,    -- /sit2                    Sit ground 2
    120,    -- /sit3                    Sit ground 3
    121,    -- /sit4                    Sit ground 4
    122,    -- /sit5                    Sit ground 5
    123,    -- /sit6                    Sit ground 6
    124,    -- /pointu                  Point upward
    125,    -- /write                   Write
    126,    -- /huh                     Huh
    127,    -- /hammerwall              Hammer wall
    128,    -- /hammerlow               Hammer kneel
    129,    -- /thumbsup                Thumbs up
    130,    -- /curtsey                 Curtsey
    131,    -- /leanside                Wall lean (side)
    132,    -- /leanback                Wall lean (back)
    133,    -- /sigh                    Sigh
    134,    -- /taunt                   Taunt
    135,    -- /greet                   Greet
    136,    -- /hail                    Hail
    137,    -- /hello                   Hello
    138,    -- /bored                   Bored
    139,    -- /drunk                   Drunk
    140,    -- /lol                     Guffaw
    141,    -- /headache                Headache
    142,    -- /kowtow                  Kowtow
    143,    -- /congratulate            Congratulate
    144,    -- /congrats                Congrats
    145,    -- /grats                   Grats
    146,    -- /flirt                   Flirt
    147,    -- /rally                   Rally
    148,    -- /stagger                 Stagger
    149,    -- /thanks                  Thanks
    150,    -- /thankyou                Thank You
    151,    -- /doom                    Doom
    152,    -- /confused                Confused
    153,    -- /impatient               Impatient
    154,    -- /tap                     Tap
    155,    -- /twiddle                 Twiddle
    156,    -- /clap                    Clap
    157,    -- /heartbroken             Broken Hearted
    158,    -- /surrender               Surrender
    159,    -- /controlrod              Dwarven control rod
    160,    -- /bucketsplash            Water bucket
    161,    -- /shovel                  Shovel
    162,    -- /faint                   Faint
    163,    -- /wand                    Use wand once
    164,    -- /bestowblessing          Bestow Blessing
    165,    -- /blowkiss                Blow Kiss
    166,    -- /annoyed                 Annoyed
    167,    -- /knockeddown             Knocked down
    168,    -- /eat                     Eat turkey
    169,    -- /smash                   Break Object
    170,    -- /knuckles                Crack Knuckles
    171,    -- /blessing                Blessing
    172,    -- /cry                     Cry
    173,    -- /drink2                  Drinking from chalice
    174,    -- /honor                   Honor
    175,    -- /dishonor                Dishonor
    176,    -- /eatbread                Eat bread
    177,    -- /eat3                    Eat apple
    178,    -- /spit                    Spit
    179,    -- /idle                    Idle
    180,    -- /dancebreton             Dance Breton
    181,    -- /dancealtmer             Dance Altmer
    182,    -- /danceargonian           Dance Argonian
    183,    -- /dancebosmer             Dance Bosmer
    184,    -- /dancedunmer             Dance Dunmer
    185,    -- /danceimperial           Dance Imperial
    186,    -- /dancekhajiit            Dance Khajiit
    187,    -- /dancenord               Dance Nord
    188,    -- /danceorc                Dance Orc
    189,    -- /danceredguard           Dance Redguard
    190,    -- /idle2                   Idle royalty
    191,    -- /rake                    Rake
    192,    -- /sweep                   Sweeping
    193,    -- /leanbackcoin            Wall lean (back, coinflip)
    194,    -- /juggleflame             Juggle flame
    195,    -- /sad                     Sad
    196,    -- /idle3                   Idle casual
    197,    -- /idle4                   Idle angry
    198,    -- /idle5                   Idle heroic
    199,    -- /stomp                   Stomp
    200,    -- /drink3                  Drinking from bottle
    201,    -- /eat4                    Eat from bowl
    202,    -- /lookup                  Look up
    203,    -- /attention               Attention
    204,    -- /dancehighelf            Dance High Elf
    205,    -- /dancewoodelf            Dance Wood Elf
    206,    -- /dancedarkelf            Dance Dark Elf
    207,    -- /pie                     Eat pie
    208,    -- /soupbowl                Eat soup
    209,    -- /smallbread              Eat roll
    210,    -- /meal                    Eat a meal
    211,    -- /letter                  Read letter
    212,    -- /bow2                    Bow flourish
    213,    -- /colder                  Shivering cold
    214,    -- /crownstore              Crown Store
    215,    -- /toast3                  Toast - Wine
    216,    -- /teatime                 TeaTime
    217,    -- /kissthis                Kiss This
    218,    -- /bellylaugh              Belly Laugh
    219,    -- /goquietly               Go Quietly
    220,    -- /eat5                    Forbidden Dinner
    221,    -- /flex                    Flex
    222,    -- /bullhorns               Bull Horns
    223,    -- /admireme                Admire Me
    224,    -- /soulgem                 Soulgem
    225,    -- /parchment               Parchment
    226,    -- /clippers                Clippers
    227,    -- /begone                  Begone!
    228,    -- /flipthebird             Flip the bird
    229,    -- /lineinsand              Line in the sand
    230,    -- /iseeyou                 I see you
    231,    -- /comegetsome             Come Get Some
    232,    -- /kickthedirt             Kick the Dirt
    233,    -- /whenever                Whenever
    234,    -- /dancefactotum           Factotum Dance
    235,    -- /happyface               Happy Face
    236,    -- /sadface                 Sad Face
    237,    -- /tada                    Ta Da!
    238,    -- /glowglobe               Glowglobe
    239,    -- /showtime                Showtime
    240,    -- /jugglepumpkin           Juggle Pumpkins
    241,    -- /throweggs               Throw Eggs
    242,    -- /throwtreats             Throw Treats
    243,    -- /festivalbeggar          Festival Beggar
    244,    -- /skullponder             Skull Ponder
    245,    -- /tracker                 Tracker
    246,    -- /greethist               Greeting Hist
    247,    -- /mistletoe               Mistletoe
    248,    -- /mistletoeposterior      Mistletoe Posterior
    249,    -- /festivebellring         Festive Bell Ring
    250,    -- /greetdeadwater          Greeting Dead-Water
    251,    -- /greetbrightthroat       Greeting Bright-Throat
    252,    -- /greetmurkmire           Greeting Murkmire
    253,    -- /carve                   Carve Knickknack
    254,    -- /communehist             Commune with Hist
    255,    -- /teebadribble            Teeba Dribble
    256,    -- /teebawarmup             Teeba Warm-Up
    257,    -- /teebaready              Teeba Ready Position
    258,    -- /catcontemplation        Cat Contemplation
    259,    -- /felinehygiene           Feline Hygiene
    260,    -- /pedlarbeckoning         Pedlar Beckoning
    261,    -- /cardsharp               Cardsharp
    262,    -- /gladiatortaunt          Gladiator Taunt
    263,    -- /mimetugofwar            Pantomime Tug-of-War
    264,    -- /handpuppet              Hand Puppet
    265,    -- /guarstomp               Guar Stomp
    266,    -- /warmhands               Warm Hands
    267,    -- /kissfrog                Lick Frog
    268,    -- /mimewall                Mime Wall
    269,    -- /esraj                   Play Esraj
    270,    -- /qanun                   Play Qanun
    271,    -- /bannerebonheart         Holding Banner EP
    272,    -- /rollingpin              Baker Rolling Pin
    273,    -- /salty                   Salty
    274,    -- /slicefood               Slice Food
    275,    -- /goutfang                Goutfang Kata
    276,    -- /whisperingclaw          Whispering Claw Kata
    277,    -- /desertrain              Desert Rain Kata
    278,    -- /brightmoonsgreeting     Khajiit Greet
    279,    -- /banneraldmeri           Holding Banner AD
    280,    -- /bannercovenant          Holding Banner DC
    281,    -- /chaosballvictory        Chaos Ball Victory Dance
    282,    -- /chaosballboom           Chaos Ball Boom
    283,    -- /scorchingchaosball      Scorching Chaos Ball
    284,    -- /drinkhorn               Drink From Horn
    285,    -- /dragoncall              Dragon Call
    286,    -- /dragontrophy            Polish Dragon Trophy
    287,    -- /drinkfromskull          Drink From Skull
    288,    -- /summonbat               Summon Bat
    289,    -- /wardingsymbol           Warding Symbol
    290,    -- /arrowtoknee             Arrow to the Knee CE
    291,    -- /sweetroll               Missing Sweetroll
    292,    -- /ragnarthered            Play Ragnar the Red
    293,    -- /slapknee                Laugh Knee Slapper
    294,    -- /arachnophobia           Arachnophobia
    295,    -- /onyourmark              On Your Mark …
    296,    -- /eggscramble             Egg Scramble
    297,    -- /egghatch                Horrifying Egg Hatch
    298,    -- /angrydustoff            Dust Off
    299,    -- /lichen                  Let There Be Lichen!
    300,    -- /wickerman               Wickerman Mishap
    301,    -- /iceblossom              Iceblossom Summoning
    302,    -- /tamelightning           Tame Lightning
    303,    -- /pondermap               Ponder Poorly Drawn Map
    304,    -- /bannermorthal           Morthal Banner
    305,    -- /bannerkarthwatch        Karthwatch Banner
    306,    -- /bannersolitude          Solitude Banner
    307,    -- /biteme                  Bite Me
    308,    -- /playtinyviolin          Play Tiny Violin
    309,    -- /cosmicstarburst         Psijic Cosmic Starburst
    310,    -- /falkreathfrolic         Falkreath Frolic
    311,    -- /alinorallemande         Alinor Allemande
    312,    -- /boozyboot               Boozy Boot
    313,    -- /memorialtoast           Memorial Toast
    314,    -- /hiss                    Hiss
    315,    -- /firespinning            Fire Spinning
    316,    -- /scarecrow               Scarecrow Pose
    317,    -- /washyourdamnhands       Wash Your Damn Hands
    318,    -- /offerweapon             Offer Weapon
    319,    -- /ragereach               Rage of the Reach
    320,    -- /marshmallowtreat        Marshmallow Toasty Treat
    321,    -- /barkeep                 Barkeep
    322,    -- /ownthrone               Own the Throne
    323,    -- /eliteseat               Elite Seat
    324,    -- /misersmuse              Miser's Muse
    325,    -- /dayoflights             Day of Lights Spectacle
    326,    -- /firesalts               Fire Salts
    327,    -- /blowbubbles             Blow Bubbles
    328,    -- /crochet                 Crochet
    329,    -- /spicysoup               Spicy Soup
    330,    -- /chefkiss                Chef Kiss
    331,    -- /trebuchet               Wargame Trebuchet
    332,    -- /fightme                 Fight Me
    333,    -- /twothumbsup             Two Thumbs Up
    334,    -- /nodice                  No Dice
    335,    -- /petplant                Pet Plant
    336,    -- /befuddled               Befuddled
    337,    -- /washhandsofit           Wash Hands Of It
    338,    -- /nevermind               Uh … Never Mind
    339,    -- /ritualcasting           Ritual Casting
    340,    -- /bumble                  Bumbling Artificer
    341,    -- /waiter                  Wait the Great
    342,    -- /juggleyarn              Feline's Fancy Juggling
    343,    -- /stargazer               Stargazer
    344,    -- /flowerfling             Flower Fling
    345,    -- /airtheheir              Air the Heir
    346,    -- /siegestomper            Siegestomper
    347,    -- /ballista                Wargame Ballista
    348,    -- /crabpinch               Crab Pinch
    349,    -- /wheredrink              Where's My Drink?
    350,    -- /sitdrink                Sit and Drink
    351,    -- /sworddance              Sword Dance
    352,    -- /feedbird                Feed Bird
    353,    -- /popthecork              Pop the Cork
    354,    -- /spyglass                Spyglass
    355,    -- /glimmerdust             Glimmer Dust
    356,    -- /shriekingcheese         Alik'r Shrieking Cheese
    357,    -- /trumpet1                Trumpet 1
    358,    -- /aethericarms            Contemplation of Aetheric Arms
    359,    -- /conchshell              Souvenir Conch Shell
    360,    -- /jig                     Jig
    361,    -- /lookatthis              LookAtThis
    362,    -- /propose                 Proposal
    363,    -- /taichi                  TaiChi
    364,    -- /tot                     Tales of Tribute Idle
    365,    -- /plantyourself           Plant Yourself
    366,    -- /keyharp                 Key Harp
    367,    -- /trumpet2                Trumpet 2
    368,    -- /trumpet3                Trumpet 3
    369,    -- /roundofapplause         Round of Applause
    370,    -- /trumpetsolo             Trumpet Solo
    371,    -- /eatintimidate           Apple Intimidation
    372,    -- /bowknightly             Knightly Bow
    373,    -- /palelord                Pale Lord's Throne
    374,    -- /knighting               Sapphire Knighting
    375,    -- /flowertrick             Apprentice's Flower Trick
    376,    -- /pocketscrib             Handy Pocket Scrib
    377,    -- /petalpresent            Petal Presentation
    378,    -- /cliffracers             Cliff Racer Catastrophe
    379,    -- /getout                  Get Out
    380,    -- /aerialescapades         Aerial Escapades
    381,    -- /leafshade               Galenwood Leafshade
    382,    -- /wayrestparty            Wayrest Party Incident
    383,    -- /sweep                   Sweeping
    384,    -- /fingerscrossed          Fingers Crossed
    385,    -- /fungaldrum              Ashlander's Fungal Beat
    386,    -- /leaningscholar          Leaning Scholar
    387,    -- /sittingscholar          Sitting Scholar
    388,    -- /standingscholar         Standing Scholar
    389,    -- /cardconjuring           Card Conjuring
    390,    -- /dancejig                Jester's Jig
    391,    -- /lost                    Lost in the Woods
    392,    -- /foecrusher              Foe Crusher
    393,    -- /knifesavant             Knife Savant
    394,    -- /panflute                Play Pan Flute
    395,    -- /sextant                 Sailor's Sextant
    396,    -- /bagpipes                Play Netch Bagpipes
    397,    -- /ashhopperchomp          Ash Hopper Chomp
    398,    -- /handpan                 Boneshaped Handpan
    399,    -- /danceskaal              Skaal Maul Dance
    400,    -- /tentaculartome          Tentacular Tome
    401,    -- /noblesnack              Skingrad Noble Snack
    402,    -- /claphands               Clap Hands
    403,    -- /pyromancer              Pyromancer's Quandary
    404,    -- /makecheese              Make Cheese
    405,    -- /stompgrapes             Stomp Grapes
    406,    -- /sommelierswirl          Sommelier Swirl
    407,    -- /hattrick                Varkenel's Hat Trick
    408,    -- /idlemagic               Apprentice's Idle Magic
    409,    -- /playglassarmonica       Play Glass Armonica
    410,    -- /livingstatue            Syrabane Living Statue
    411,    -- /potionpeddler           Potion Peddler
    412,    -- /dancecelebration        Celebratory Dance
    413,    -- /rememberthis            I Shall Remember This!
    414,    -- /truesight               True-Sight Viewing
    415,    -- /blademastersconundrum   Blademaster's Conundrum
    416,    -- /blademasterstaunt       Blademaster's Taunt
    417,    -- /sitdrink                Sit and Drink
    418,    -- /fetcherflykill          Fetcherfly Frustration
    419,    -- /nightmotherstouch       Night Mother's Touch
    420,    -- /mirrorballtrickery      Mirrorball Trickery
    421,    -- /glassharp               Mirrormoor Glass Harp
    422,    -- /teebatrick              Teeba Trick
    423,    -- /beachdrink              Beachside Drink
    424,    -- /beachbask               Beachside Bask
    425,    -- /frolickingfrog          Frolicking Frog
    426,    -- /regentswave             Regent's Wave
    427,    -- /selfreflection          Self Reflection
    428,    -- /dancefestive            Carnaval Festive Dance
    429,    -- /dancefan                Carnaval Fan Dance
    430,    -- /rattlers                Play Solstice Rattlers
    431,    -- /tipsytopple             Tipsy Topple
    432,    -- /jugglefood              Street Food Juggle
    433,    -- /dance2                  Dance2
    434,    -- /nordicyell              Nordic Yell and Yawp
    435,    -- /firedance               World-Eater's Fire Dance
    436,    -- /slumberglow             Slumberglow the Great
    437,    -- /sneezeattack            Sneaky Sneeze Attack
    438,    -- /light                   Brandish Lantern
    439,    -- /snakesidekick           Snake Sidekick
    440,    -- /alliancebanner          Alliance Banner
    441,    -- /skullblocks             Valenwood Skull Blocks
    442,    -- /releasedoves            Release the Doves
    443,    -- /ringdance               Traditional Ring Dance
    444,    -- /heartsdaykiss           Heart's Day Kiss
    445,    -- /twirl                   Elegant Twirl
    446,    -- /chairslam               Chair Slam
    447,    -- /spittake                Spit Take
    448,    -- /featofstrength          Feat of Strength!
    449,    -- /crouch                  Crouch
    450,    -- /sabersparring           Saber Sparring
    451,    -- /warriorwavedance        Warrior Wave Celebration Dance
    452,    -- /navigator               Confident Navigator
    453,    -- /nodeal                  Deal Breaker
    454,    -- /intavasname             In Tava's Name
    455,    -- /notmycoins              Not My Coins!
    456,    -- /orderharp               Harp of Harmonious Order
    457,    -- /playtocrowd             Play to the Crowd
    458,    -- /channelduality          Channel Duality
    459,    -- /cheesestatue            Sheogorath's Blessed Cheese
    460,    -- /sick                    Sickened
]]

-- ----------------------------------------------------------------------------

-- -----------------------------------------------
-- Idle Emotes Tables for LorePlay Forever add-on
-- -----------------------------------------------

customIdleEmotesTable["Zone"] = {
    99,     -- /sit                     Sit ground
    119,    -- /sit2                    Sit ground 2
    120,    -- /sit3                    Sit ground 3
    121,    -- /sit4                    Sit ground 4
    123,    -- /sit6                    Sit ground 6
    102,    -- /kneel                   Kneel
    200,    -- /drink3                  Drinking from bottle
    15,     -- /armscrossed             Arms crossed
    10,     -- /read                    Read book
    38,     -- /handsonhips             Hands on hips
    190,    -- /idle2                   Idle royalty
}

customIdleEmotesTable["City"] = {
    201,    -- /eat4                    Eat from bowl
    107,    -- /prov                    Stir Bowl
    194,    -- /juggleflame             Juggle flame
    8,      -- /drink                   Drinking from flagon
    173,    -- /drink2                  Drinking from chalice
    100,    -- /sitchair                Sit chair
    38,     -- /handsonhips             Hands on hips
    168,    -- /eat                     Eat turkey
    9,      -- /eat2                    Eat bread quickly
    190,    -- /idle2                   Idle royalty
    198,    -- /idle5                   Idle heroic
}

customIdleEmotesTable["Dungeon"] = {
    194,    -- /juggleflame             Juggle flame
    1,      -- /torch                   Set fire with torch
    153,    -- /impatient               Impatient
    1,      -- /torch                   Set fire with torch
    1,      -- /torch                   Set fire with torch
    122,    -- /sit5                    Sit ground 5
    101,    -- /crouch                  Crouch
}

customIdleEmotesTable["Housing"] = {
    10,     -- /read                    Read book
    10,     -- /read                    Read book
    99,     -- /sit                     Sit ground
    119,    -- /sit2                    Sit ground 2
    191,    -- /rake                    Rake
    191,    -- /rake                    Rake
    192,    -- /sweep                   Sweeping
    192,    -- /sweep                   Sweeping
    9,      -- /eat2                    Eat bread quickly
    177,    -- /eat3                    Eat apple
    207,    -- /pie                     Eat pie
    208,    -- /soupbowl                Eat soup
    125,    -- /write                   Write
    125,    -- /write                   Write
    118,    -- /sleep2                  Sleep back
    116,    -- /sleep                   Sleep side
}

customIdleEmotesTable["Drunk"] = {
    8,      -- /drink                   Drinking from flagon
    8,      -- /drink                   Drinking from flagon
    139,    -- /drunk                   Drunk
    139,    -- /drunk                   Drunk
    162,    -- /faint                   Faint
    162,    -- /faint                   Faint
    79,     -- /dancedrunk              Dance drunk
    79,     -- /dancedrunk              Dance drunk
    115,    -- /playdead                Play dead
    153,    -- /impatient               Impatient
}

customIdleEmotesTable["Worship"] = {
    104,    -- /kneelpray               Kneel praying
    52,     -- /pray                    Pray
    171,    -- /blessing                Blessing
}

customIdleEmotesTable["Exercise"] = {
    84,     -- /jumpingjacks            Jumping jacks
    85,     -- /pushups                 Push-ups strong
    113,    -- /situps                  Situps
}

customIdleEmotesTable["Dance"] = {
    72,     -- /dance                   Dance
    189,    -- /danceredguard           Dance Redguard
    181,    -- /dancealtmer             Dance Altmer
    182,    -- /danceargonian           Dance Argonian
    183,    -- /dancebosmer             Dance Bosmer
    180,    -- /dancebreton             Dance Breton
    206,    -- /dancedarkelf            Dance Dark Elf
    185,    -- /danceimperial           Dance Imperial
    186,    -- /dancekhajiit            Dance Khajiit
    187,    -- /dancenord               Dance Nord
    188,    -- /danceorc                Dance Orc
}

customIdleEmotesTable["Instruments"] = {
    5,      -- /lute                    Play lute
    6,      -- /flute                   Play flute
    7,      -- /drum                    Play drum
}

LorePlay.hasCustomizedIdleEmoteTables = true
