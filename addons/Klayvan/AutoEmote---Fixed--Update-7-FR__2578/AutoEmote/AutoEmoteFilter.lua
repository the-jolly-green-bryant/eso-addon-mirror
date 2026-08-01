-- 1: no condition (this one should always be at the bottom of the list, if you use it)
-- 2: check first word/chars
-- 3: check whole string
-- 4: check last word/chars


-- Remember: The first match counts, all following items will be ignored, so put the generic stuff at the bottom of the list and the more specific ones at the top
-- Tip: Add spaces around a keyword to avoid partial matches (if you check the first word, only add a space after it)

-- Use this format:
-- { 
--		type of condition (see above)
-- 		{"Array","of","keywords"},
--		{"/array of emotes to play","/selects one randomly"}
-- },

-- List of relevant chat channels:
-- CHAT_CHANNEL_EMOTE
-- CHAT_CHANNEL_SAY
-- CHAT_CHANNEL_YELL
-- CHAT_CHANNEL_WHISPER
-- CHAT_CHANNEL_PARTY
-- CHAT_CHANNEL_ZONE
-- CHAT_CHANNEL_GUILD_1
-- CHAT_CHANNEL_GUILD_2
-- CHAT_CHANNEL_GUILD_3
-- CHAT_CHANNEL_GUILD_4
-- CHAT_CHANNEL_GUILD_5

AutoEmoteFilter = {
	[CHAT_CHANNEL_YELL] = {
		{	
			1,
			{""},
			{"/shout"}
		}
	},
	[CHAT_CHANNEL_WHISPER] = {
		{	
			1,
			{""},
			{"/read"}
		}
	},
	[CHAT_CHANNEL_EMOTE] = {
		{	
			3,
			{" music "," song "," musik "},
			{"/drum","/flute","/lute"}
		},{	
			3,
			{" dance"," dancing "," tanzt "," tanzen "},
			{"/dance","/dancedrunk"}
		},{	
			3,
			{" prays "," betet "},
			{"/pray"}
		},{	
			3,
			{" applauds "," claps "," klatscht "},
			{"/"}
		},{	
			3,
			{" surrenders "," ergibt sich "},
			{"/surrender"}
		},{	
			3,
			{" taunts "," provoziert "},
			{"/taunt","/doom"}
		},{	
			3,
			{" sits "," setzt sich "},
			{"/sit","/sit2","/sit3","/sit4","/sit5","/sit6"}
		},{	
			3,
			{" whispers "," fl�stert "},
			{"/whisper"}
		},{	
			3,
			{" yawns "," g�hnt "},
			{"/yawn"}
		},{	
			3,
			{" cries "," weint "},
			{"/cry"}
		},{	
			3,
			{" sleeps "," schl�ft "},
			{"/sleep"}
		},{	
			3,
			{" pokes "," stupst "},
			{"/poke"}
		},{	
			3,
			{" whistles "," pfeift "},
			{"/whistle"}
		},{	
			3,
			{" greets "," hails "," welcomes "," gr��t "," begr��t "},
			{"/hello","/greet"}
		},{	
			3,
			{"gratulate","gl�ckw�nscht","gratuliert"},
			{"/congratulate"}
		},{	
			3,
			{" chicken "," huhn "},
			{"/cuckoo"}
		},{	
			3,
			{" bows ","curtsey"," verbeut "},
			{"/bow","/curtsey"}
		},{	
			3,
			{" confused "," verwirrt "},
			{"/headscratch","/shrug"}
		},{	
			3,
			{" reads "," liest "},
			{"/read"}
		},{	
			3,
			{" drinks "," trinkt "},
			{"/drink"}
		},{	
			3,
			{" eats "," isst "},
			{"/eat"}
		},{	
			3,
			{" blesses "," buffs "," segnet "," bufft "},
			{"/bestowblessing"}
		},{	
			3,
			{" thanks "," dankt "," bedankt "," thankful "},
			{"/bow","/thanks"}
		},{	
			3,
			{" salutes "," salutiert "},
			{"/saluteloop","/saluteloop2","/saluteloop3"}
		},{	
			3,
			{" nods "," nickt "},
			{"/nod"}
		},{	
			3,
			{" disagrees "," disapproves "},
			{"/disapprove"}
		},{	
			3,
			{" waits "," wartet "},
			{"/impatient","/bored"}
		}	
	},
	[CHAT_CHANNEL_SAY] = {
		{
			2,
			{"hi ","hi! ","hello","hallo","greetings","hey ","salut"},
			{"/hello"}
		},{
			3,
			{" cu "," bye "," ciao "," gn8 ","see ya","farewell","tsch�ss"," cu!","bye!","++","a+","au revoir"},
			{"/wave"}
		},{
			3,
			{"how dare you","wie kannst du nur","also ehrlich","also wirklich","not cool", "pas cool"}, 
			{"/wagfinger"}
		},{
			2,
			{"thx","thanks","thank you","danke","merci","ty"}, 
			{"/thank"}
		},{
			3,
			{"grats","gratz","congratulations","gl�ckwunsch","nice!","super !"}, 
			{"/cheer"}
		},{
			3,
			{"love you","liebe dich"}, 
			{"/kiss"}
		},{
			3,
			{"lol","mdr","haha"}, 
			{"/lol"}
		},{
			2,
			{"yes ","yes!","ja ","ja!","agreed","oui","ouai","ouais","ok"}, 
			{"/approve"}
		},{
			2,
			{"no ","no!","nein ","nein!","non","nan"}, 
			{"/disapprove"}
		},{
			2,
			{"nooo","oh no"}, 
			{"/cry"}
		},{
			2,
			{"please ","bitte ","stp"}, 
			{"/beg"}
		},{
			2,
			{"get lost","piss off","hau ab","geh weg"}, 
			{"/shakefist"}
		},{
			2,
			{"omg","oh my god","oh mein gott"}, 
			{"/facepalm"}
		},{
			2,
			{"ready","pret","prêt","r "}, 
			{"/knuckles"}
		},{
			2,
			{"here","par ici","ici","over here"}, 
			{"/whistle"}
		},{
			2,
			{"follow me","suivez moi","suis moi"}, 
			{"/followme"}
		},{
			2,
			{"wtf"}, 
			{"/surprised"}
		},{
			2,
			{"cmon ","come on ","ach komm ","komm schon "}, 
			{"/sigh"}
		},{
			3,
			{"boring","langweilig"}, 
			{"/annoyed","/impatient","/bored"}
		},{
			2,
			{"afk","brb"},
			{"/leanbackcoin","/juggleflame"}
		},{
			4,
			{"?!","!?"}, 
			{"/confused"}
		},{
			4,
			{"!!"}, 
			{"/shout"}
		},{
			4,
			{"!"}, 
			{"/self"}
		},{
			4,
			{"??"}, 
			{"/shrug"}
		},{
			4,
			{"?"},
			{"/headscratch"}
		}
	},
	[CHAT_CHANNEL_PARTY] = {
		{
			2,
			{"hi ","hi! ","hello","hallo","greetings","hey ","salut"},
			{"/hello"}
		},{
			3,
			{" cu "," bye "," ciao "," gn8 ","see ya","farewell","tsch�ss"," cu!","bye!","++","a+","au revoir"},
			{"/wave"}
		},{
			3,
			{"how dare you","wie kannst du nur","also ehrlich","also wirklich","not cool", "pas cool"}, 
			{"/wagfinger"}
		},{
			2,
			{"thx","thanks","thank you","danke","merci","ty"}, 
			{"/thank"}
		},{
			3,
			{"grats","gratz","congratulations","gl�ckwunsch","nice!","super !"}, 
			{"/cheer"}
		},{
			3,
			{"love you","liebe dich"}, 
			{"/kiss"}
		},{
			3,
			{"lol","mdr","haha"}, 
			{"/lol"}
		},{
			2,
			{"yes ","yes!","ja ","ja!","agreed","oui","ouai","ouais","ok"}, 
			{"/approve"}
		},{
			2,
			{"no ","no!","nein ","nein!","non","nan"}, 
			{"/disapprove"}
		},{
			2,
			{"nooo","oh no"}, 
			{"/cry"}
		},{
			2,
			{"please ","bitte ","stp"}, 
			{"/beg"}
		},{
			2,
			{"get lost","piss off","hau ab","geh weg"}, 
			{"/shakefist"}
		},{
			2,
			{"omg","oh my god","oh mein gott","oh mon dieu"}, 
			{"/facepalm"}
		},{
			2,
			{"ready","pret","prêt","r "}, 
			{"/knuckles"}
		},{
			2,
			{"here","par ici","ici","over here"}, 
			{"/whistle"}
		},{
			2,
			{"follow me","suivez moi","suis moi"}, 
			{"/followme"}
		},{
			2,
			{"wtf"}, 
			{"/surprised"}
		},{
			2,
			{"cmon ","come on ","ach komm ","komm schon "}, 
			{"/sigh"}
		},{
			3,
			{"boring","langweilig"}, 
			{"/annoyed","/impatient","/bored"}
		},{
			2,
			{"afk","je reviens","brb"},
			{"/leanbackcoin","/juggleflame"}
		},{
			4,
			{"?!","!?"}, 
			{"/confused"}
		},{
			4,
			{"!!"}, 
			{"/shout"}
		},{
			4,
			{"!"}, 
			{"/self"}
		},{
			4,
			{"??"}, 
			{"/shrug"}
		},{
			4,
			{"?"},
			{"/headscratch"}
		}
	}
}