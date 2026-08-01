
CyroChat.printMessages = false
CyroChat.messageUsedPlayerLocation = false
CyroChat.matchedLocationOn = nil
CyroChat.foundDoubleLocations = false
CyroChat.usePlayerLocation = false
CyroChat.locationStatusLost = false
CyroChat.matchedAllianceOn = nil
CyroChat.locationNumber = 3

CyroChat.allianceNames = {
	['ad'] = 'Aldmeri Dominion',
	['yellow'] = 'Aldmeri Dominion',
	['ep'] = 'Ebonheart Pact',
	['red'] = 'Ebonheart Pact',
	['dc'] = 'Daggerfall Covenant',
	['blue'] = 'Daggerfall Covenant',
	['bloo'] = 'Daggerfall Covenant',
	['ants'] = 'Ebonheart Pact',
	['tomato'] = 'Ebonheart Pact',
	['smurf'] = 'Daggerfall Covenant',
	['banana'] = 'Aldmeri Dominion',
	['bleu'] = 'Daggerfall Covenant',
	['jaune'] = 'Aldmeri Dominion',
	['rouge'] = 'Ebonheart Pact',
	['blueberries'] = 'Daggerfall Covenant'
}

CyroChat.keeps = {
    [3] = "Fort Warden",
    [4] = "Fort Rayles",
    [5] = "Fort Glademist",
    [6] = "Fort Ash",
    [7] = "Fort Aleswell",
    [8] = "Fort Dragonclaw",
    [9] = "Chalman Keep",
    [10] = "Arrius Keep",
    [11] = "Kingscrest Keep",
    [12] = "Farragut Keep",
    [13] = "Blue Road Keep",
    [14] = "Drakelowe Keep",
    [15] = "Castle Alessia",
    [16] = "Castle Faregyl",
    [17] = "Castle Roebeck",
    [18] = "Castle Brindle",
    [19] = "Castle Black Boot",
    [20] = "Castle Bloodmayne",
    [22] = "Castle Bloodmayne Farm",
    [23] = "Castle Bloodmayne Mine",
    [24] = "Castle Bloodmayne Lumbermill",
    [34] = "Castle Black Boot Lumbermill",
    [35] = "Castle Black Boot Mine",
    [36] = "Castle Black Boot Farm",
    [37] = "Farragut Keep Lumbermill",
    [38] = "Farragut Keep Mine",
    [39] = "Farragut Keep Farm",
    [40] = "Fort Warden Farm",
    [41] = "Fort Warden Lumbermill",
    [42] = "Fort Warden Mine",
    [43] = "Castle Faregyl Farm",
    [44] = "Castle Faregyl Lumbermill",
    [45] = "Castle Faregyl Mine",
    [46] = "Arrius Keep Farm",
    [47] = "Arrius Keep Lumbermill",
    [48] = "Arrius Keep Mine",
    [49] = "Fort Glademist Farm",
    [50] = "Fort Glademist Lumbermill",
    [51] = "Fort Glademist Mine",
    [52] = "Kingscrest Keep Farm",
    [53] = "Kingscrest Keep Lumbermill",
    [54] = "Kingscrest Keep Mine",
    [55] = "Fort Rayles Farm",
    [56] = "Fort Rayles Lumbermill",
    [57] = "Fort Rayles Mine",
    [61] = "Fort Ash Farm",
    [62] = "Fort Ash Lumbermill",
    [63] = "Fort Ash Mine",
    [64] = "Fort Aleswell Mine",
    [65] = "Fort Aleswell Lumbermill",
    [66] = "Fort Aleswell Farm",
    [67] = "Fort Dragonclaw Mine",
    [68] = "Fort Dragonclaw Lumbermill",
    [69] = "Fort Dragonclaw Farm",
    [70] = "Chalman Keep Mine",
    [71] = "Chalman Keep Lumbermill",
    [72] = "Chalman Keep Farm",
    [73] = "Blue Road Keep Mine",
    [74] = "Blue Road Keep Lumbermill",
    [75] = "Blue Road Keep Farm",
    [76] = "Drakelowe Keep Mine",
    [77] = "Drakelowe Keep Lumbermill",
    [78] = "Drakelowe Keep Farm",
    [79] = "Castle Alessia Mine",
    [80] = "Castle Alessia Lumbermill",
    [81] = "Castle Alessia Farm",
    [82] = "Castle Roebeck Mine",
    [83] = "Castle Roebeck Lumbermill",
    [84] = "Castle Roebeck Farm",
    [85] = "Castle Brindle Mine",
    [86] = "Castle Brindle Lumbermill",
    [87] = "Castle Brindle Farm",
    [132] = "Nikel Outpost",
    [133] = "Sejanus Outpost",
    [134] = "Bleaker's Outpost",
    [149] = "Vlastarus",
    [151] = "Bruma",
    [152] = "Cropsford",
	[154] = 'Alessia Bridge',
	[155] = 'Ash Milegate',
	[156] = 'Niben River Bridge',
	[157] = 'Bay Bridge',
	[158] = 'Priory Milegate',
	[159] = 'Chorrol Milegate',
	[160] = 'Kingscrest Milegate',
	[161] = 'Horunn Milegate',
	[162] = 'Chalman Milegate',
	[163] = "Winter's Peak Outpost",
	[164] = 'Carmala Outpost',
	[165] = "Harlun's Outpost"
}

CyroChat.resourceNames = {
	[1] = {['check'] = 'Lumbermill', ['means'] = 'Lumbermill'},
	[2] = {['check'] = 'Mine', ['means'] = 'Mine'},
	[3] = {['check'] = 'Farm', ['means'] = 'Farm'},
	[4] = {['check'] = 'lumber', ['means'] = 'Lumbermill'},
	[5] = {['check'] = 'lm', ['means'] = 'Lumbermill'},
	[6] = {['check'] = 'mill', ['means'] = 'Lumbermill'},
	[7] = {['check'] = 'lumb', ['means'] = 'Lumbermill'},
	[8] = {['check'] = 'lum', ['means'] = 'Lumbermill'}
}

-- do not add: save, flip, wall
CyroChat.siegeWords = {
	[1] = 'front door',
	[10] = 'fd',
	[11] = 'ua',
	[14] = 'cut',
	[15] = 'siege',
	[16] = 'sieging',
	[17] = 'flagged',
	[18] = 'attack',
	[19] = 'lit',
	[20] = 'taking',
	[22] = 'reinforce',
	[23] = 'flipping',
	[24] = 'flagging',
	[25] = 'fire',
	[26] = 'breach',
	[27] = 'breached',
	[28] = 'sieged',
	[29] = 'poked',
	[31] = 'pvdoor',
	[32] = 'burst',
	[33] = 'hitting',
	[34] = 'hit',
	[35] = 'taken',
	[36] = 'flag',
	[37] = 'flags',
	[38] = 'inside',
	[39] = "flag'd",
	[40] = 'open',
	[42] = 'breech',
	[43] = 'entering',
	[44] = 'postern',
	[45] = 'wrecked',
	[46] = 'dying',
	[47] = 'backdooring',
	[48] = 'backdoor',
	[49] = 'south wall',
	[50] = 'kicked',
	[51] = 'heavy',
	[52] = 'north wall',
	[53] = 'mg', -- EU, 'main gate'
	[54] = 'main gate', -- EU
	[55] = 'rammed',
	[56] = 'defense',
	[57] = 'walls down',
	[58] = 'battle',
	[59] = 'struggling',
	[60] = 'lighting',
	[61] = 'issue',
	[62] = 'sos',
	[63] = 'holding',
	[64] = 'n wall'
}

-- do not add: save, I, I'm, now, yes, just, flagged, there, like, siege, never, not, we, ok, some, that, more, we're
CyroChat.startsWithWords = {
	[1] = 'heading',
	[2] = 'get to',
	[3] = 'all',
	[5] = 'taking',
	[8] = 'hey',
	[9] = 'to',
	[10] = 'get',
	[12] = 'go',
	[13] = "let",
	[14] = 'and then',
	[15] = 'you',
	[16] = 'attack',
	[17] = 'hang',
	[18] = 'flag',
	[19] = 'take',
	[20] = 'going',
	[21] = 'might',
	[22] = 'hit',
	[23] = 'res',
	[24] = 'oils',
	[25] = 'watching',
	[26] = 'flagging',
	[28] = 'for',
	[29] = 'otw',
	[30] = "don't go",
	[31] = 'forget',
	[32] = 'someone',
	[33] = 'just me',
	[34] = 'omg',
	[36] = 'waiting',
	[37] = 'defend',
	[38] = 'time',
	[39] = 'anyone',
	[40] = 'look',
	[42] = 'quick',
	[43] = 'make',
	[44] = 'I lost',
	[45] = 'please',
	[47] = 'wtf',
	[48] = 'people',
	[49] = 'or',
	[50] = 'backdoor',
	[51] = 'any one',
	[52] = 'drop',
	[53] = 'heal',
	[54] = 'push',
	[55] = 'support',
	[56] = 'they want',
	[58] = 'guys',
	[59] = 'whoever',
	[60] = 'on the',
	[61] = 'fuck it',
	[62] = 'hence',
	[63] = 'port',
	[64] = 'and hit',
	[65] = 'clear',
	[66] = 'I got',
	[67] = 'unless',
	[68] = "I'm out",
	[70] = 'killed',
	[71] = 'wait',
	[72] = 'well',
	[73] = 'somebody',
	[74] = 'my',
	[75] = 'fine',
	[76] = 'hold',
	[77] = 'thats',
	[78] = 'lf',
	[80] = 'gather',
	[81] = 'open',
	[82] = 'any',
	[83] = 'leave',
	[84] = 'come',
	[85] = 'as long',
	[86] = 'pls',
	[87] = 'set up',
	[88] = 'we take',
	[89] = 'I feel',
	[90] = 'gotta',
	[92] = 'I help',
	[93] = 'we can',
	[94] = 'just let',
	[95] = "couldn't",
	[96] = 'cease',
	[97] = 'being',
	[99] = "don't",
	[100] = 'hail',
	[101] = 'charge',
	[103] = 'thanks',
	[104] = 'mostly',
	[105] = 'setup',
	[106] = 'stack',
	[107] = 'ulti',
	[108] = 'never repair',
	[109] = 'search',
	[110] = 'man',
	[111] = 'defense',
	[112] = 'deploy',
	[113] = 'abandon',
	[114] = 'redeploy',
	[115] = 'repair',
	[116] = 'secure',
	[117] = 'saved',
	[118] = 'in',
	[119] = 'lay',
	[120] = 'on',
	[121] = 'focus',
	[122] = 'not the',
	[123] = 'fight',
	[124] = 'keep',
	[125] = 'we arent',
	[126] = "I'm going",
	[127] = 'im right',
	[128] = 'could',
	[129] = 'i bet',
	[130] = "I'll go",
	[131] = 'Im waiting',
	[132] = 'AD to',
	[133] = 'Im hiding',
	[134] = 'lets',
	[135] = 'before',
	[136] = 'once',
	[137] = 'some get',
	[138] = 'before',
	[139] = 'storm',
	[140] = 'that or',
	[141] = 'yay',
	[142] = 'siege limit',
	[143] = 'try',
	[144] = "I'm inside",
	[145] = 'pick',
	[146] = 'help',
	[147] = 'tag',
	[148] = 'pull',
	[149] = '*',
	[150] = 'few',
	[151] = 'zerg it',
	[152] = 'at some point',
	[153] = 'anything',
	[154] = 'point',
	[155] = 'anybody',
	[156] = 'anyway',
	[157] = 'sorry',
	[158] = 'invite',
	[160] = 'operation',
	[161] = 'our',
	[162] = 'lookin',
	[163] = "I'm a",
	[164] = 'inside',
	[165] = 'then',
	[166] = 'I think',
	[167] = 'I assume',
	[168] = 'I want',
	[169] = 'I like',
	[170] = 'Use',
	[171] = 'we do',
	[172] = 'I hope',
	[173] = 'I am',
	[174] = 'We could',
	[175] = 'like attacks',
	[176] = 'i mean'
}

-- do not add: for now, crazy
CyroChat.endsWithWords = {
	[1] = 'guys',
	[2] = 'uh',
	[3] = 'next',
	[4] = 'plz',
	[6] = 'fd soon',
	[7] = 'with me',
	[8] = 'that',
	[9] = 'pugs',
	[10] = 'as well',
	[11] = 'right',
	[12] = 'get here',
	[13] = 'fyi',
	[14] = 'get crazy',
	[15] = 'alot',
	[16] = 'first',
	[17] = 'know',
	[18] = 'indeed',
	[19] = 'you'
}

-- do not add: take, wait, come, meant, seems, could
CyroChat.tenseWords = {
	'said',
	'went',
	'took',
	'came',
	'drove',
	'traveled',
	'was',
	'named',
	'assumed',
	'likely',
	'possibly',
	'need',
	'before',
	'may',
	'would',
	'needs',
	'after',
	'probably',
	'should',
	'flip',
	'possibility',
	'moved',
	'guess',
	'harmed',
	'had',
	'already',
	'were',
	'managed',
	'eventually',
	'kept',
	'thought',
	'shouldnt',
	'couldnt',
	'wwould'
}

CyroChat.questionWords = {
	'who', 'what', 'when', 'where', 'why', 'how', 'is', 'can', 'does', 'do', 'has', 'have', 'which', 'are', 'will', 'sup', 'did'
}

-- do not add: scroll, ap farmers, maybe, clean, opportunity, all day, but, man
CyroChat.ignoreWords = {
	'sex',
	'bad idea',
	'worry',
	'amazing',
	'strategy',
	'clusterfuck',
	'seconds',
	'guild',
	'forces',
	'alts',
	'dtick',
	'tick',
	'wipes',
	'cya',
	'hurts',
	'funnier',
	'strange',
	'complains',
	'wear',
	'removal',
	'attractive',
	'luv',
	'tush',
	'spais',
	'ass',
	'records',
	'breast',
	'win',
	'winning',
	'button',
	'blah',
	'expect',
	'while',
	'wonder',
	'titty',
	'bacon',
	'butts',
	'butt',
	'fucking',
	'scrolls',
	'tap',
	'blood',
	'everyone',
	'zerglings',
	'juvenile',
	'do not',
	'dance party',
	'shit',
	'ask',
	'heals',
	'listen',
	'to emp',
	'easy',
	'favorite',
	'afk',
	'tired',
	'laughing',
	'ticks',
	'lmfao',
	'good luck',
	'swiss cheese',
	'thank you',
	'good idea',
	'draw',
	'animal',
	'fps',
	'might',
	'noobs',
	'ty',
	'good time',
	'waste',
	'dced',
	'him',
	'make it happen',
	'blocktard',
	'press',
	'weird',
	'blame',
	'watch',
	'because',
	'wont',
	'usually',
	'stop',
	'nothin',
	'tell',
	'trapped',
	'prob',
	'loves',
	'cares',
	'bored',
	'vote',
	'thx',
	'get to',
	'knows',
	'every',
	'learn',
	'honestly',
	'chance',
	'sure',
	'PVE',
	'afraid',
	'person',
	'can we',
	'happens',
	'nerf',
	'nerfing',
	'points',
	'run',
	'guys at',
	'business',
	'clean up',
	'penetrate',
	'bnack',
	'pretend',
	'can go',
	'zero fucks',
	'forcing',
	'helping',
	'place',
	'dps',
	'tank',
	'shame',
	'spai',
	'sometimes',
	'to go',
	'rules',
	'nice try',
	'territory',
	'all day',
	'tbag',
	'not like',
	'quality',
	'fuck not',
	'eye',
	'put siege',
	'butter',
	'scared',
	'fuck',
	'shop',
	'twats',
	'sucks',
	'zerg down',
	'am going',
	'dunno',
	'that case',
	'i died',
	'they want',
	'newbs',
	'uniforms',
	'home keep',
	'rogue',
	'ready',
	'take your',
	'themselves known',
	'high enough',
	'they look',
	'x up',
	'marginal',
	"didn't help",
	'save their',
	'cant work',
	'cant move',
	'without',
	'buy',
	'siege up',
	'talking about',
	'everytime',
	'cry',
	'alt',
	'will get',
	'just hit',
	'toss up',
	'unlikely',
	'backyard',
	'quest',
	'try pass',
	'i am inside',
	'troll',
	'setup def',
	'gather up',
	'AD make',
	'AD try',
	'take it back',
	'eval',
	'be safe',
	'wasting',
	'we can push',
	'ping',
	'why didnt',
	'forgot',
	'believe',
	'get out',
	'drop that scroll',
	'some go for',
	'flashbacks',
	'negated',
	'I am sieging',
	'idiots',
	'drama',
	'I will assist you',
	'you save',
	'luck',
	'good spot',
	'could fail',
	'angry with me',
	'leads',
	'tutorial',
	'surprised',
	'gameplay',
	'kills',
	'price',
	'deserved',
	'blow',
	'ffs', -- for fuck's sake
	'i hit you',
	'please siege',
	'time to hit',
	'I cannot lie',
	'invite',
	'reform',
	'motivation',
	'please flag',
	'christmas',
	'take back',
	'2018',
	'good lad',
	'get resources',
	'build',
	'greasy',
	'merchant',
	'about to be',
	'lost them',
	'I just got here',
	'oil',
	'treat',
	'part',
	'sounds good',
	'pants',
	'hardcast',
	'status effect',
	'gtfo',
	'group for',
	'album',
	'stall',
	'mins ago',
	'chat',
	'holez',
	'ya you',
	'eating',
	'takes it in the',
	'revenge',
	'the only good',
	'bosmer',
	'right in the',
	'fetish',
	'/reloadui',
	'houses',
	'pizza',
	'I lived',
	'type',
	'for you',
	'you could',
	'they always',
	'put it in',
	'provide',
	'i wish',
	'123',
	'important',
	'shitty',
	'dumb',
	'title',
	"you're welcome",
	'great move',
	'kill counter',
	'puns',
	'otherwise',
	'group open',
	'pretending',
	'shocked',
	'lease',
	'they did',
	'battlegrounds',
	'banned',
	'helpful',
	'patch',
	'overrated',
	'sufficient',
	'group cleaning',
	'tax',
	'coherent',
	'shifts',
	'server',
	'crates',
	'we dont',
	'pug',
	'earlier',
	"I'm good",
	'talking',
	'hear',
	'spirit',
	'not a zerg'
}

CyroChat.weirdLocationWordsMatching = {
	'bridge', -- Brindle
	'aoe', -- Ash
	'arrows', -- Arrius
	'rules', -- Rayles
	'radius', -- Arrius
	'wrinkle', -- Brindle
	'raids', -- Rayles
	'rates', -- Rayles
	'proxy', -- Priory Milegate
	'pricey', -- Priory Milegate
}

CyroChat.clearWords = {
	[1] = 'safe',
	[2] = 'good',
	[3] = 'clear',
	[4] = 'cool',
	[5] = 'repair',
	[6] = 'repairs',
	[7] = 'restored',
	[8] = 'fine',
	[9] = 'saving',
	[10] = 'repairable',
	[11] = 'saved',
	[13] = 'ok',
	[14] = 'stable',
	[15] = 'repaired',
	[16] = 'repairing',
	[17] = 'relax',
	[18] = 'transit open',
	[19] = 'quiet',
	[20] = 'unflagged',
	[22] = 'defended',
	[23] = 'port',
	[24] = 'retook',
	[25] = 'better',
	[26] = 'shut',
	[27] = 'under control',
	[28] = 'empty',
	[29] = 'evicted',
	[30] = 'cleared',
	[31] = 'handled',
	[32] = 'worked out',
	[33] = 'nothing happening',
	[34] = 'repping',
	[35] = 'secure',
	[36] = 'set'
}

-- do not add: gone
CyroChat.lostWords = {
	[1] = 'lost',
	[2] = 'failed',
	[3] = 'good try',
	[4] = 'done for',
	[5] = 'rip',
	[6] = 'condemned',
	[7] = 'wiped',
	[8] = 'see ya',
	[9] = 'toast',
	[10] = 'fked',
	[11] = 'sunk',
	[12] = 'wipe',
	[13] = 'fucked',
	[14] = 'burns',
	[15] = 'taken',
	[16] = 'wiping',
	[17] = 'fallen',
	[18] = 'bye',
	[19] = 'steamrolled'
}

-- do not add: watch, guys
CyroChat.incWords = {
	[10] = 'incoming',
	[11] = 'inc',
	[12] = 'coming',
	[14] = 'help',
	[15] = 'hiding',
	[16] = 'visitors',
	[17] = 'they',
	[19] = 'side',
	[20] = 'tower',
	[21] = 'resources',
	[22] = 'people',
	[23] = 'camp',
	[24] = 'action',
	[25] = 'otw',
	[26] = 'raid',
	[28] = 'heading',
	[29] = 'fc', -- foward camp
	[30] = 'crazy',
	[31] = 'stacked',
	[32] = 'east',
	[33] = 'lots',
	[34] = 'inbound',
	[35] = 'bomber',
	[36] = 'group',
	[37] = 'zerg',
	[38] = 'heads',
	[39] = 'heading',
	[40] = 'cutting',
	[41] = 'leaving',
	[42] = 'cleanup',
	[48] = 'rss', -- resources
	[49] = "they're",
	[50] = 'res' -- resources
}

CyroChat.keepNames = {
	['Bloodmayne'] = 'Castle Bloodmayne',
	['Faregyl'] = 'Castle Faregyl',
	['Alessia'] = 'Castle Alessia',
	['Roebeck'] = 'Castle Roebeck',
	['Brindle'] = 'Castle Brindle',
	['Drakelowe'] = 'Drakelowe Keep',
	['Farragut'] = 'Farragut Keep',
	['Arrius'] = 'Arrius Keep',
	['Kingscrest'] = 'Kingscrest Keep',
	['Chalman'] = 'Chalman Keep',
	['Ash'] = 'Fort Ash',
	['Dragonclaw'] = 'Fort Dragonclaw',
	['Aleswell'] = 'Fort Aleswell',
	['Glademist'] = 'Fort Glademist',
	['Warden'] = 'Fort Warden',
	['Rayles'] = 'Fort Rayles',
	["Bleaker's"] = "Bleaker's Outpost",
	['Sejanus'] = 'Sejanus Outpost',
	['Nikel'] = 'Nikel Outpost',
	['Vlastarus'] = "Vlastarus",
    ['Bruma'] = "Bruma",
    ['Cropsford'] = "Cropsford",
	['Black Boot'] = 'Castle Black Boot',
	['Blue Road'] = 'Blue Road Keep',
	["Alessia Bridge"] = "Alessia Bridge",
	["Niben River"] = "Niben River Bridge",
	["Bay"] = "Bay Bridge",
	["Priory"] = "Priory Milegate",
	["Chorrol"] = "Chorrol Milegate",
	["Kingscrest Milegate"] = "Kingscrest Milegate",
	["Horunn"] = "Horunn Milegate",
	["Chalman Milegate"] = "Chalman Milegate",
	["Winter's Peak"] = "Winter's Peak Outpost",
	["Carmala"] = "Carmala Outpost",
	["Harlun's"] = "Harlun's Outpost",
	["Ash Milegate"] = "Ash Milegate",
}

CyroChat.keepNicknames = {
	['BB'] = 'Black Boot',
	['BM'] = 'Bloodmayne',
	['Fare'] = 'Faregyl',
	['Roe'] = 'Roebeck',
	['Drake'] = 'Drakelowe',
	['BRK'] = 'Blue Road',
	['Kings'] = 'Kingscrest',
	['Chal'] = 'Chalman',
	['Glade'] = 'Glademist',
	['bleak'] = "Bleaker's",
	['Sej'] = 'Sejanus',
	['nik'] = 'Nikel',
	['Brenda'] = 'Brindle',
	['nick'] = 'Nikel',
	['vlast'] = 'Vlastarus',
	['vlas'] = 'Vlastarus',
	['Crops'] = "Cropsford",
	['roeb'] = 'Roebeck',
	['brin'] = 'Brindle',
	['nickel'] = 'Nikel',
	['fara'] = 'Farragut',
	['farra'] = 'Farragut',
	['nickle'] = 'Nikel',
	['Alicia'] = 'Alessia',
	['nic'] = 'Nikel',
	['nikle'] = 'Nikel',
	['lessia'] = 'Alessia', -- EU
	['arr'] = 'Arrius', -- EU
	['alebrunn'] = 'Aleswell', -- EU
	['houblon'] = 'Glademist', -- EU
	['brindell'] = 'Brindle', -- EU
	['brinduru'] = 'Brindle',
	['allicia'] = 'Alessia',
	['Nikkel'] = 'Nikel',
	['carm'] = 'Carmala'
}

function CyroChat.trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function CyroChat.endsWith(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

function CyroChat.messageChanges(text)
	-- everything lowercase
	text = string.lower(text)

	-- get rid of all non-alphanumeric characters
	text = text:gsub("[\\.+]", " ")
	text = text:gsub("[^%w '%%/<>*:]", "")
	text = text:gsub("%'s", "")

	text = CyroChat.trim(text)

	local messageSplit = CyroChat.string_split(text)
	local message = ''

	for i=1, #messageSplit do
		local wordToCheck = messageSplit[i]

		if wordToCheck:sub(1,1) == "'" then
			message = message .. " " .. wordToCheck:sub(2)
		elseif string.sub(wordToCheck, -1) == "'" then
			message = message .. " " .. wordToCheck:sub(0, string.len(wordToCheck)-1)
		else
			message = message .. " " .. wordToCheck
		end
	end

	return message
end

function CyroChat.startsWith(word, startsWithWord, useMatches)
	if string.find(startsWithWord, "'") then
		
	elseif string.len(startsWithWord) <= 3 or string.len(word) <= 4 then
		useMatches = false
	end

	if startsWithWord .. "s" == word then
		return false
	end

	if useMatches == true then
		local matches = CyroChat.findMatches(false, word, startsWithWord, 2, false)

		if matches >= 0 and matches <= 1 then
			if CyroChat.printMessages == true then
				d("Matched startWord '" .. startsWithWord .. "' with score: " .. matches)
			end

			return true
		end
	else
		if word == string.lower(startsWithWord) then
			return true
		end
	end

	return false
end

function CyroChat.checkMessage(text, channelType, fromName, fromDisplayName, testRun, fakeLocation)
	--[[if CyroChat.printMessages == true then
		d("Starting checkMessage")
	end]]

	CyroChat.messageUsedPlayerLocation = false
	CyroChat.usePlayerLocation = false
	CyroChat.locationStatusLost = false
	CyroChat.matchedAllianceOn = nil

	if CyroChat.printMessages == true and testRun == true then
		d("Original Message: "..text)
	end

	-- excessive exclamation points
	if string.match(text, '!!!!!+') ~= nil then
		return nil
	end

	-- clearing out can leave weird spacing
	text = CyroChat.trim(text)

	-- check if it's a question (part 1)
	if CyroChat.endsWith(text:gsub("[^%w ?]", ""), '?') == true then
		if CyroChat.printMessages == true then
			d("Returning early1")
		end

		return nil
	end

	local message = CyroChat.messageChanges(text)

	if message == "" then
		return nil
	end

	local messageSplit = CyroChat.string_split(message)

	if next(messageSplit) == nil then
		return nil
	end

	for _, startsWithWord in pairs(CyroChat.startsWithWords) do
		if string.find(startsWithWord, " ") then
			local startsWithWordSplit = CyroChat.string_split(startsWithWord)

			if messageSplit[1] == string.lower(startsWithWordSplit[1]) and messageSplit[2] == string.lower(startsWithWordSplit[2]) then
				if CyroChat.printMessages == true then
					d("Returning early9")
				end

				return nil
			end

			local firstStartWord = string.lower(startsWithWordSplit[1])
			firstStartWord = firstStartWord:gsub("[^%w]", "")

			if messageSplit[1] == firstStartWord and messageSplit[2] == string.lower(startsWithWordSplit[2]) then
				if CyroChat.printMessages == true then
					d("Returning early12")
				end

				return nil
			end
		else
			if CyroChat.startsWith(messageSplit[1], startsWithWord, true) then
				if CyroChat.printMessages == true then
					d("Returning early2: "..startsWithWord)
				end

				return nil
			end
		end
	end

	for _, endsWithWord in pairs(CyroChat.endsWithWords) do
		if string.find(endsWithWord, " ") then
			local endsWithWordSplit = CyroChat.string_split(endsWithWord)

			if messageSplit[#messageSplit-1] == string.lower(endsWithWordSplit[1]) and messageSplit[#messageSplit] == string.lower(endsWithWordSplit[2]) then
				if CyroChat.printMessages == true then
					d("Returning early11")
				end

				return nil
			end
		else
			if CyroChat.endsWith(message, endsWithWord) then
				if CyroChat.printMessages == true then
					d("Returning early3")
				end

				return nil
			end
		end
	end

	if string.find(message, 'cut you off') or string.find(message, 'just in case') then
		if CyroChat.printMessages == true then
			d("Returning early4")
		end

		return nil
	end

	-- check if it's a question (part 2)
	for i=1, #messageSplit do
		if messageSplit[i] == 'if' then
			if CyroChat.printMessages == true then
				d("Returning early5")
			end

			return nil
		end
	end

	for j=1, #CyroChat.questionWords do
		if CyroChat.startsWith(messageSplit[1], CyroChat.questionWords[j], false) or CyroChat.questionWords[j] .. "s" == messageSplit[1] then
			if CyroChat.printMessages == true then
				d("Returning early6")
			end

			return nil
		end
	end

	-- any that are just completely ignore
	--local useMatches = true

	for j=1, #CyroChat.ignoreWords do
		local ignoreWord = string.lower(CyroChat.ignoreWords[j])

		if string.find(ignoreWord, " ") then
			if string.find(message, ignoreWord) then
				if CyroChat.printMessages == true then
					d("Returning early10")
				end

				return nil
			end
		else
			for i=1, #messageSplit do
				--[[useMatches = true

				if string.find(ignoreWord, "'") then
					
				elseif string.len(ignoreWord) <= 7 or string.len(messageSplit[i]) <= 4 then
					useMatches = false
				end

				if useMatches == true then
					local matches = CyroChat.findMatches(false, messageSplit[i], ignoreWord, 2, false)

					if matches >= 0 and matches <= 1 then
						if CyroChat.printMessages == true then
							d("Matched ignoreWord '" .. ignoreWord .. "' with score: " .. matches)
						end

						return nil
					end
				else]]
					if messageSplit[i] == ignoreWord then
						if CyroChat.printMessages == true then
							d("Returning early7: "..ignoreWord)
						end

						return nil
					end
				--end
			end
		end
	end

	-- remove all 'stop' words
	message = CyroChat.clearOutChatMessage(message)

	-- clearing out can leave weird spacing
	message = CyroChat.trim(message)

	if CyroChat.printMessages == true then
		d("After clearing out common words: "..message)
	end

	if message == '' then
		if CyroChat.printMessages == true then
			d("Returning early8")
		end

		return
	end

	--[[if CyroChat.printMessages == true then
		d("Looking for location....")
	end]]

	messageSplit = CyroChat.string_split(message)

	-- find which location in Cyro you're talking about
	local foundLocation = CyroChat.findLocation(message, messageSplit)

	if foundLocation == nil then
		-- if the user yells/says, same location as we are, so we can get the location from our current location
		if channelType == CHAT_CHANNEL_YELL or channelType == CHAT_CHANNEL_SAY then
			CyroChat.messageUsedPlayerLocation = true

			if testRun == true and fakeLocation ~= nil then
				foundLocation = fakeLocation
			else
				foundLocation = CyroChat.playerZoneId
			end
		end
	end

	if foundLocation == nil or foundLocation == '' then
		if CyroChat.printMessages == true then
			d("Returning; no location found")
		end

		return
	end

	if CyroChat.printMessages == true then
		d("Location: "..tostring(CyroChat.keeps[foundLocation]))
	end

	--[[if CyroChat.printMessages == true then
		d("Looking for category...")
	end]]
	
	-- find out which category we're looking at
	-- 1 of: sieged keep, incoming players, whether a keep is lost / good
	local categoryId = CyroChat.findCategory(message, messageSplit, CyroChat.keeps[foundLocation])

	if categoryId == nil or categoryId == false then
		return
	end
	
	if CyroChat.printMessages == true then
		d("Category: "..tostring(categoryId))
	end

	if CyroChat.usePlayerLocation == true then
		if channelType == CHAT_CHANNEL_YELL or channelType == CHAT_CHANNEL_SAY then
			CyroChat.messageUsedPlayerLocation = true

			if testRun == true and fakeLocation ~= nil then
				foundLocation = fakeLocation
			else
				foundLocation = CyroChat.playerZoneId
			end

			if CyroChat.printMessages == true then
				d("(New) Location: "..tostring(CyroChat.keeps[foundLocation]))
			end
		end
	end

	if testRun == true then
		return categoryId
	end

	CyroChat.postToFeed(text, fromName, fromDisplayName, foundLocation, categoryId)
end

function CyroChat.removeLocationFromMessage(message, location)
	if CyroChat.printMessages == true then
		d("Removing from message: "..location)
	end

	message = message:gsub(location, " ")
	message = message:gsub(location..'[^%a]', " ")
	message = message:gsub('[^%a]'..location, " ")
	message = message:gsub('[^%a]'..location..'[^%a]', " ")

	return message
end

function CyroChat.findLocation(message, messageSplit)
	if CyroChat.printMessages == true then
		d("Inside findLocation")
	end

	local doResourceCheck = true
	local foundDistanceLocation = nil
	local foundOverallLocation = nil
	CyroChat.matchedLocationOn = nil
	local changedMessage = false
	CyroChat.foundDoubleLocations = false

	if string.find(message, 'inner') then
		doResourceCheck = false
	end

	if string.find(message, 'ash mile gate') then
		return 6
	end

	if doResourceCheck == true then
		for keepName, fullName in pairs(CyroChat.keepNames) do
			for _, resourceInfo in pairs(CyroChat.resourceNames) do
				local resourceName = resourceInfo.means
				local resourceCheck = resourceInfo.check

				local checkResources = {
					[1] = keepName .. " " .. resourceName,
					[2] = resourceName .. " " .. keepName
				}

				if resourceName ~= resourceCheck then
					checkResources[3] = keepName .. " " .. resourceCheck
					checkResources[4] = resourceCheck .. " " .. keepName
				end

				for _, checkResource in pairs(checkResources) do
					checkResource = string.lower(checkResource)

					if string.find(message, checkResource) and keepName ~= 'Alessia Bridge' then
						if CyroChat.printMessages == true then
							d("Found location 2: "..checkResource)
						end

						if foundOverallLocation ~= nil then
							return nil
						end

						foundOverallLocation = fullName .. " " .. resourceName
						CyroChat.matchedLocationOn = checkResource

						if message == checkResource then
							return CyroChat.getKeepId(foundOverallLocation, false)
						end

						message = CyroChat.removeLocationFromMessage(message, checkResource)
						changedMessage = true

						if CyroChat.printMessages == true then
							d("Updated message: "..message)
						end
					end
				end
			end
		end

		for keepNickName, halfName in pairs(CyroChat.keepNicknames) do
			for _, resourceInfo in pairs(CyroChat.resourceNames) do
				local resourceName = resourceInfo.means
				local resourceCheck = resourceInfo.check

				local checkResources = {
					[1] = keepNickName .. " " .. resourceName .. "s",
					[2] = resourceName .. " " .. keepNickName,
					[5] = keepNickName .. " " .. resourceName,
				}

				if resourceName ~= resourceCheck then
					checkResources[3] = keepNickName .. " " .. resourceCheck
					checkResources[4] = resourceCheck .. " " .. keepNickName
				end

				for _, checkResource in pairs(checkResources) do
					checkResource = string.lower(checkResource)

					if string.find(message, checkResource) then
						if CyroChat.printMessages == true then
							d("Found location 1")
						end

						if foundOverallLocation ~= nil then
							return nil
						end

						foundOverallLocation = CyroChat.keepNames[halfName] .. " " .. resourceName
						CyroChat.matchedLocationOn = checkResource

						if message == checkResource then
							return CyroChat.getKeepId(foundOverallLocation, false)
						end

						message = CyroChat.removeLocationFromMessage(message, checkResource)
						changedMessage = true

						if CyroChat.printMessages == true then
							d("Updated message: "..message)
						end
					end
				end
			end
		end

		if changedMessage == true then
			messageSplit = CyroChat.string_split(message)
			changedMessage = false
		end

		if CyroChat.printMessages == true then
			d("Calling foundDistanceLocation1")
			d("Already found: "..tostring(foundOverallLocation))
		end

		foundDistanceLocation = CyroChat.checkMisspellings(messageSplit, CyroChat.keepNames, true, CyroChat.locationNumber, true, foundOverallLocation)

		if CyroChat.foundDoubleLocations == true then
			return nil
		end

		if foundDistanceLocation ~= nil then
			if foundOverallLocation ~= nil then
				return nil
			end

			for keepName, fullName in pairs(CyroChat.keepNames) do
				keepName = string.lower(keepName)

				for _, resourceInfo in pairs(CyroChat.resourceNames) do
					if keepName == foundDistanceLocation then
						local resourceName = resourceInfo.means
						local resourceCheck = resourceInfo.check
						
						local checkResources = {
							[1] = CyroChat.matchedLocationOn .. " " .. resourceCheck,
							[2] = resourceCheck .. " " .. CyroChat.matchedLocationOn
						}

						for _, checkResource in pairs(checkResources) do
							checkResource = string.lower(checkResource)

							if string.find(message, checkResource) then
								if CyroChat.printMessages == true then
									d("Found location 4")
								end

								if foundOverallLocation ~= nil then
									return nil
								end

								foundOverallLocation = fullName .. " " .. resourceName
								CyroChat.matchedLocationOn = checkResource

								if message == checkResource then
									return CyroChat.getKeepId(foundOverallLocation, false)
								end

								message = CyroChat.removeLocationFromMessage(message, checkResource)
								changedMessage = true

								if CyroChat.printMessages == true then
									d("Updated message: "..message)
								end
							end
						end
					end
				end
			end

			for keepName, fullName in pairs(CyroChat.keepNames) do
				keepName = string.lower(keepName)

				for _, resourceInfo in pairs(CyroChat.resourceNames) do
					if keepName == foundDistanceLocation then
						local resourceName = resourceInfo.means

						if changedMessage == true then
							messageSplit = CyroChat.string_split(message)
							changedMessage = false
						end

						if CyroChat.printMessages == true then
							d("Calling checkMisspellingsWord")
						end

						-- need to check for things like 'alessia famr'
						local checkResourceMisspell = CyroChat.checkMisspellingsWord(messageSplit, resourceName, 2, true, foundOverallLocation)

						if CyroChat.foundDoubleLocations == true then
							return nil
						end

						if checkResourceMisspell ~= nil then
							local checkResource = string.lower(CyroChat.matchedLocationOn .. " " .. checkResourceMisspell)

							if string.find(message, checkResource) then
								if CyroChat.printMessages == true then
									d("Found location 5")
								end

								if foundOverallLocation ~= nil then
									return nil
								end

								foundOverallLocation = fullName .. " " .. resourceName
								CyroChat.matchedLocationOn = checkResource

								if message == checkResource then
									return CyroChat.getKeepId(foundOverallLocation, false)
								end

								message = CyroChat.removeLocationFromMessage(message, checkResource)
								changedMessage = true

								if CyroChat.printMessages == true then
									d("Updated message: "..message)
								end
							end
						end
					end
				end
			end
		end
	end

	for keepName, fullName in pairs(CyroChat.keepNames) do
		keepName = string.lower(keepName)

		if string.find(keepName, " ") then
			if string.find(message, keepName) then
				if CyroChat.printMessages == true then
					d("Matched location2")
				end

				if foundOverallLocation ~= nil then
					return nil
				end

				foundOverallLocation = fullName
				CyroChat.matchedLocationOn = keepName

				if message == keepName then
					return CyroChat.getKeepId(foundOverallLocation, false)
				end

				message = CyroChat.removeLocationFromMessage(message, keepName)
				changedMessage = true

				if CyroChat.printMessages == true then
					d("Updated message: "..message)
				end
			end
		end
	end

	if changedMessage == true then
		messageSplit = CyroChat.string_split(message)
		changedMessage = false
	end

	--[[if CyroChat.printMessages == true then
		d("Calling foundOverallLocation3")
	end

	foundOverallLocation = CyroChat.checkMisspellings(messageSplit, CyroChat.keepNicknames, true, 3, true, foundOverallLocation)

	if CyroChat.printMessages == true then
		d("From foundOverallLocation: "..tostring(foundOverallLocation))
	end

	if CyroChat.foundDoubleLocations == true then
		return nil
	end]]

	for nickName, keepName in pairs(CyroChat.keepNicknames) do
		nickName = string.lower(nickName)

		for i=1, #messageSplit do
			if messageSplit[i] == nickName or messageSplit[i] == nickName .. 's' or messageSplit[i] == nickName .. "'ll" then
				if CyroChat.printMessages == true then
					d("Matched location4")
				end

				if foundOverallLocation ~= nil then
					return nil
				end

				foundOverallLocation = CyroChat.keepNames[keepName]

				if messageSplit[i] == nickName .. 's' then
					CyroChat.matchedLocationOn = nickName .. 's'
				elseif messageSplit[i] == nickName .. "'ll" then
					CyroChat.matchedLocationOn = nickName .. "'ll"
				else
					CyroChat.matchedLocationOn = nickName
				end

				if message == nickName then
					return CyroChat.getKeepId(foundOverallLocation, false)
				end

				message = CyroChat.removeLocationFromMessage(message, CyroChat.matchedLocationOn)
				changedMessage = true

				if CyroChat.printMessages == true then
					d("Updated message: "..message)
				end
			end
		end
	end

	if changedMessage == true then
		messageSplit = CyroChat.string_split(message)
		changedMessage = false
	end

	if CyroChat.printMessages == true then
		d("Calling foundDistanceLocation2")
		d(messageSplit)
	end

	foundDistanceLocation = CyroChat.checkMisspellings(messageSplit, CyroChat.keepNames, true, CyroChat.locationNumber, true, foundOverallLocation)

	if CyroChat.foundDoubleLocations == true then
		return nil
	end

	if CyroChat.matchedLocationOn ~= nil then
		if CyroChat.matchedLocationOn == 'wardens' then
			return nil
		end
	end

	if foundDistanceLocation ~= nil then
		if CyroChat.printMessages == true then
			d("Matched location5")
		end

		if foundOverallLocation ~= nil then
			return nil
		end

		return CyroChat.getKeepId(foundDistanceLocation, true)
	end

	if foundOverallLocation ~= nil then
		return CyroChat.getKeepId(foundOverallLocation, false)
	end

	return nil
end

function CyroChat.findCategory(message, messageSplit, finalMessageLocation)
	if CyroChat.printMessages == true then
		d("Inside findCategory")
		--d(message)
		--d(messageSplit)
	end

	if string.find(message, 'no one') or string.find(message, 'penis') ~= nil or string.match(message, 'hi%d') ~= nil then
		if CyroChat.printMessages == true then
			d("Returning nil (1)")
		end

		return nil
	end

	if string.find(message, 'leaving') then
		if CyroChat.printMessages == true then
			d("Returning 2 (8)")
		end

		return 2
	end

	if message == 'group' or message == "they're" then
		if CyroChat.printMessages == true then
			d("Returning nil (9)")
		end

		return nil
	end

	if CyroChat.messageUsedPlayerLocation == false then
		-- if no spaces, and we had to have found a location to get this far, then only location
		if string.find(message, ' ') or string.find(message, '*') then
			
		else
			if CyroChat.printMessages == true then
				d("Returning 1 (11)")
			end

			return 1
		end

		if CyroChat.matchedLocationOn ~= nil then
			if finalMessageLocation ~= nil then
				if string.find(finalMessageLocation, 'Lumbermill') or string.find(finalMessageLocation, 'Farm') or string.find(finalMessageLocation, 'Mine') then
					if message == CyroChat.matchedLocationOn then
						if CyroChat.printMessages == true then
							d("Returning 1 (12)")
						end

						return 1
					end
				end
			end
		end

		for nickName, keepName in pairs(CyroChat.keepNames) do
			if string.find(nickName, " ") then
				if message == string.lower(nickName) then
					if CyroChat.printMessages == true then
						d("Returning 1 (13)")
					end

					return 1
				end
			end
		end
	end

	if CyroChat.matchedLocationOn ~= nil then
		if string.find(message, "attacking "..CyroChat.matchedLocationOn) then
			if CyroChat.printMessages == true then
				d("Returning 1 (10)")
			end

			return 1
		end

		if string.find(message, CyroChat.matchedLocationOn.." ours") then
			if CyroChat.printMessages == true then
				d("Returning 3 (1)")
			end

			return 3
		end
	end
	
	for j=1, #CyroChat.tenseWords do
		local tenseWord = string.lower(CyroChat.tenseWords[j])

		for i=1, #messageSplit do
			if messageSplit[i] == tenseWord then
				if CyroChat.printMessages == true then
					d("Returning nil (2): "..tenseWord)
				end

				return nil
			end
		end
	end

	if CyroChat.matchedLocationOn ~= nil then
		if string.find(message, 'wiped at ' .. CyroChat.matchedLocationOn) then
			if CyroChat.printMessages == true then
				d("Returning 3 (16)")
			end

			return 3
		end
	end

	for _, lostWord in pairs(CyroChat.lostWords) do
		if string.find(lostWord, " ") then
			if string.find(message, lostWord) then
				return 4
			end
		else
			lostWord = string.lower(lostWord)

			for i=1, #messageSplit do
				if messageSplit[i] == lostWord then
					return 4
				end
			end
		end
	end

	--[[if CyroChat.checkMisspellings(messageSplit, CyroChat.lostWords, false, 2, false) ~= nil then
		return 4
	end]]

	for i=1, #messageSplit do
		if i == 2 then
			if messageSplit[1] .. ' ' .. messageSplit[2] == 'nice job' then
				if CyroChat.printMessages == true then
					d("Returning 3 (6)")
				end

				return 3
			end
		end
	end
	
	for _, clearWord in pairs(CyroChat.clearWords) do 
		if string.find(clearWord, " ") then
			if string.find(message, clearWord) then
				if CyroChat.printMessages == true then
					d("Returning 3 (2)")
				end

				return 3
			end
		else
			clearWord = string.lower(clearWord)

			for i=1, #messageSplit do
				if i > 1 then
					if messageSplit[i-1] == 'nice' and messageSplit[i] == 'save' then
						if CyroChat.printMessages == true then
							d("Returning 3 (4)")
						end

						return 3
					end

					if messageSplit[i-1] == 'no' and messageSplit[i] == 'holes' then
						if CyroChat.printMessages == true then
							d("Returning 3 (5)")
						end

						return 3
					end

					if messageSplit[i-1] == 'not' and messageSplit[i] == clearWord then
						if CyroChat.printMessages == true then
							d("Returning 1 (20)")
						end

						return 1
					end

					if messageSplit[i-1] == 'cant' or messageSplit[i-1] == "can't" then
						if messageSplit[i] == clearWord and clearWord == 'port' then
							if CyroChat.printMessages == true then
								d("Returning 1 (19)")
							end

							return 1
						end
					end
				end

				if messageSplit[i] == clearWord and messageSplit[1] ~= 'ok' then
					if CyroChat.printMessages == true then
						d("Returning 3 (3): "..clearWord)
					end

					return 3
				end
			end
		end
	end

	--[[if CyroChat.checkMisspellings(messageSplit, CyroChat.clearWords, false, 2, false) ~= nil then
		if CyroChat.printMessages == true then
			d("Returning 3 (17)")
		end

		return 3
	end]]

	if CyroChat.matchedLocationOn ~= nil then
		if message == 'maybe ' .. CyroChat.matchedLocationOn then
			if CyroChat.printMessages == true then
				d("Returning nil (3)")
			end

			return nil
		end

		if message == 'there is ' .. CyroChat.matchedLocationOn then
			if CyroChat.printMessages == true then
				d("Returning nil (4)")
			end

			return nil
		end

		if message == 'lots at ' .. CyroChat.matchedLocationOn then
			if CyroChat.printMessages == true then
				d("Returning 2 (6)")
			end

			return 2
		end

		if string.find(message, CyroChat.matchedLocationOn .. " door") then
			if CyroChat.printMessages == true then
				d("Returning 1 (23)")
			end

			return 1
		end

		if message == CyroChat.matchedLocationOn .. ' d:' then -- D: but lowercase
			if CyroChat.printMessages == true then
				d("Returning 1 (21)")
			end

			return 1
		end

		if message == 'from ' .. CyroChat.matchedLocationOn or message == 'and ' .. CyroChat.matchedLocationOn then
			if CyroChat.printMessages == true then
				d("Returning nil (5)")
			end

			return nil
		end

		if message == 'got ' .. CyroChat.matchedLocationOn then
			if CyroChat.printMessages == true then
				d("Returning 3 (7)")
			end

			return 3
		end

		for i=1, #messageSplit-1 do
			if messageSplit[i] == 'save' and messageSplit[i+1] == CyroChat.matchedLocationOn then
				if CyroChat.printMessages == true then
					d("Returning 1 (15)")
				end

				return 1
			end

			if messageSplit[i] == CyroChat.matchedLocationOn and messageSplit[i+1] == 'gone' then
				return 4
			end

			if messageSplit[i] == CyroChat.matchedLocationOn and messageSplit[i+1] == 'flipped' then
				if CyroChat.printMessages == true then
					d("Returning 3 (14)")
				end

				return 3
			end

			if messageSplit[i] == 'got' and messageSplit[i+1] == CyroChat.matchedLocationOn then
				if CyroChat.printMessages == true then
					d("Returning 2 (7)")
				end

				return 2
			end
		end
	end

	local checkDont = CyroChat.checkMisspellingsWord(messageSplit, "don't", 2, false, nil)

	for _, siegeWord in pairs(CyroChat.siegeWords) do
		if string.find(siegeWord, " ") then
			if string.find(message, siegeWord) then
				if CyroChat.printMessages == true then
					d("Returning 1 (2)")
				end

				return 1
			end
		else
			siegeWord = string.lower(siegeWord)

			for i=1, #messageSplit do
				if i > 1 then
					if messageSplit[i-1] == 'no' and messageSplit[i] == siegeWord then
						if CyroChat.printMessages == true then
							d("Returning 3 (8)")
						end

						return 3
					end

					if messageSplit[i-1] == 'not' and messageSplit[i] == siegeWord then
						if CyroChat.printMessages == true then
							d("Returning 3 (9): "..siegeWord)
						end

						return 3
					end

					if messageSplit[i-1] == 'guarding' and messageSplit[i] == siegeWord then
						if CyroChat.printMessages == true then
							d("Returning 2 (8)")
						end

						return 2
					end
				end

				if messageSplit[i] == siegeWord then
					if CyroChat.printMessages == true then
						d("Returning 1 (3): "..siegeWord)
					end

					return 1
				end
			end
		end
	end

	-- check for revelant words spelled incorrectly
	if CyroChat.checkMisspellings(messageSplit, CyroChat.siegeWords, false, 2, false) ~= nil then
		if checkDont ~= nil then
			if CyroChat.printMessages == true then
				d("Returning 3 (15)")
			end

			return 3
		else
			if CyroChat.printMessages == true then
				d("Returning 1 (4)")
			end

			return 1
		end
	end

	if finalMessageLocation ~= nil then
			local foundDown = false

			local checkDownMisspell = CyroChat.checkMisspellingsWord(messageSplit, 'down', 2, false, nil)

			if checkDownMisspell ~= nil then
				foundDown = true
			end

			local checkOuterMisspell = CyroChat.checkMisspellingsWord(messageSplit, 'outer', 2, false, nil)

			for i=1, #messageSplit do
				if i < #messageSplit then
					if messageSplit[i+1] == 'up' then
						if messageSplit[i] == 'inner' or messageSplit[i] == checkOuterMisspell then
							if CyroChat.printMessages == true then
								d("Returning 3 (10)")
							end

							return 3
						end
					end

					if messageSplit[i+1] == 'gone' then
						if messageSplit[i] == 'inner' or messageSplit[i] == checkOuterMisspell then
							if CyroChat.printMessages == true then
								d("Returning 1 (16)")
							end

							return 1
						end
					end
				end

				if i > 1 then
					if foundDown == true then
						if messageSplit[i-1] == 'side' and messageSplit[i] == checkDownMisspell then
							if CyroChat.printMessages == true then
								d("Returning 1 (10)")
							end

							return 1
						end

						if messageSplit[i-1] == 'coming' and messageSplit[i] == checkDownMisspell then
							if CyroChat.printMessages == true then
								d("Returning 1 (14)")
							end

							return 1
						end

						if messageSplit[i-1] == checkOuterMisspell and messageSplit[i] == checkDownMisspell then
							if CyroChat.printMessages == true then
								d("Returning 1 (17)")
							end

							return 1
						end

						if messageSplit[i-1] == 'wall' and messageSplit[i] == checkDownMisspell then
							if CyroChat.printMessages == true then
								d("Returning 1 (22)")
							end

							return 1
						end
					end

					if messageSplit[i-1] == checkOuterMisspell and messageSplit[i] == 'wall' then
						if CyroChat.printMessages == true then
							d("Returning 1 (18)")
						end

						return 1
					end
				end

				if messageSplit[i] == 'inner' then
					if CyroChat.printMessages == true then
						d("Returning 1 (5)")
					end

					return 1
				end

				if messageSplit[i] == checkOuterMisspell and foundDown == true then
					if CyroChat.printMessages == true then
						d("Returning 1 (6)")
					end

					return 1
				end
			end
	end

	if CyroChat.checkMisspellings(messageSplit, CyroChat.clearWords, false, 2, false) ~= nil and messageSplit[1] ~= 'ok' then
		if CyroChat.printMessages == true then
			d("Returning 3 (11)")
		end

		return 3
	end

	if string.match(message, '%d%%') ~= nil then
		if CyroChat.printMessages == true then
			d("Returning 1 (7)")
		end

		return 1
	end

	local checkSide = CyroChat.checkMisspellingsWord(messageSplit, 'side', 2, false, nil)

	if checkSide ~= nil then
		if string.match(message, checkSide .. ' %d') ~= nil then
			if CyroChat.printMessages == true then
				d("Returning 1 (8)")
			end

			return 1
		end
	end

	if CyroChat.matchedLocationOn ~= nil then
		for i=1, #messageSplit-1 do
			if messageSplit[i] == 'from' and messageSplit[i+1] == CyroChat.matchedLocationOn then
				if CyroChat.printMessages == true then
					d("Returning 2 (5)")
				end

				CyroChat.usePlayerLocation = true

				return 2
			end
		end
	end

	local atLeastOneAlliance = false
	local participatingAlliances = CyroChat.participatingAlliances(message, messageSplit)

	for alliance, isParticipating in pairs(participatingAlliances) do
		if isParticipating == true then
			atLeastOneAlliance = true
			break
		end
	end

	if atLeastOneAlliance == true then
		if CyroChat.matchedAllianceOn ~= nil then
			for i=1, #messageSplit-1 do
				if messageSplit[i] == 'flipped' and messageSplit[i+1] == CyroChat.matchedAllianceOn then
					if CyroChat.printMessages == true then
						d("Returning 3 (12)")
					end

					return 3
				end
			end
		end

		if CyroChat.printMessages == true then
			d("Returning 2 (1)")
		end

		return 2
	end

	-- check for revelant words
	if messageSplit[1] == 'some' then
		if CyroChat.printMessages == true then
			d("Returning 2 (4)")
		end

		return 2
	end
	
	if CyroChat.checkMisspellings(messageSplit, CyroChat.incWords, false, 2, false) ~= nil then
		if CyroChat.printMessages == true then
			d("Returning 2 (2)")
		end

		return 2
	end

	if string.match(message, '%d/20') ~= nil then
		if CyroChat.printMessages == true then
			d("Returning 1 (9)")
		end

		return 1
	end

	if string.match(message, 'wall %d') ~= nil or string.match(message, 'wall at %d') ~= nil then
		if CyroChat.printMessages == true then
			d("Returning 3 (13)")
		end

		return 3
	end

	if string.match(message, '%d.%dk') ~= nil or string.match(message, '%dk') ~= nil then
		if CyroChat.printMessages == true then
			d("Returning nil (6)")
		end

		return nil
	end

	if string.match(message, '%d mins') ~= nil then
		if CyroChat.printMessages == true then
			d("Returning nil (7)")
		end

		return nil
	end

	if string.match(message, '%d') ~= nil and string.find(message, '<3') == nil and string.find(message, ':3') == nil then
		if CyroChat.printMessages == true then
			d("Returning 2 (3)")
		end

		return 2
	end

	if CyroChat.printMessages == true then
		d("Returning nil (8) ; reached end of findCategory")
	end

	return nil
end

-- "hude group of ep just hit blue road"
function CyroChat.participatingAlliances(text, messageSplit)
	if messageSplit == nil then
		local message = CyroChat.messageChanges(text)
		messageSplit = CyroChat.string_split(message)
	end

	local participatingAlliances = {
		['ad'] = false,
		['dc'] = false,
		['ep'] = false
	}

	for nickName, allianceName in pairs(CyroChat.allianceNames) do
		nickName = string.lower(nickName)

		for i=1, #messageSplit do
			local foundMatch = false

			local checkAlliances = {
				[1] = string.lower(allianceName),
				[2] = nickName,
				[3] = nickName .. 's'
			}

			for _, checkAlliance in pairs(checkAlliances) do
				if string.len(checkAlliance) > 3 then
					local matches = CyroChat.findMatches(false, messageSplit[i], checkAlliance, 2, false)

					if matches >= 0 and matches <= 1 then
						if CyroChat.printMessages == true then
							d("Alliance Match1 on "..checkAlliance.." > " .. messageSplit[i])
						end

						foundMatch = true
						break
					end
				--[[elseif string.len(checkAlliance) == 3 then
					local matches = CyroChat.findMatches(false, messageSplit[i], checkAlliance, 1, false)

					if matches >= 0 and matches <= 1 then
						if CyroChat.printMessages == true then
							d("Alliance Match2 on "..checkAlliance.." > " .. messageSplit[i])
						end

						foundMatch = true
						break
					end]]
				else
					if messageSplit[i] == checkAlliance then
						if CyroChat.printMessages == true then
							d("Alliance Match3 on "..nickName.." > " .. messageSplit[i])
						end

						foundMatch = true
						break
					end
				end
			end

			if foundMatch == true then
				CyroChat.matchedAllianceOn = messageSplit[i]

				if allianceName == 'Aldmeri Dominion' then
					participatingAlliances['ad'] = true
				elseif allianceName == 'Daggerfall Covenant' then
					participatingAlliances['dc'] = true
				elseif allianceName == 'Ebonheart Pact' then
					participatingAlliances['ep'] = true
				end
			end
		end
	end

	return participatingAlliances
end

function CyroChat.checkMisspellingsWord(messageSplit, wordToCheck, lowestScore, checkingLocation, foundOverallLocation)
	local bestWord = nil
	local name = string.lower(wordToCheck)

	for i=1, #messageSplit do
		-- despite checkingLocation, pass false
		local matches = CyroChat.findMatches(false, messageSplit[i], name, lowestScore, false)

		if matches < 0 then
			
		elseif matches == 0 then
			if CyroChat.printMessages == true then
				d("Matched1: " .. messageSplit[i] .. " > " .. name .. " ; score " .. matches)
			end

			if checkingLocation == true then
				if foundOverallLocation ~= nil then
					CyroChat.foundDoubleLocations = true
					return nil
				end

				foundOverallLocation = messageSplit[i]
			end

			lowestScore = matches
			bestWord = messageSplit[i]
		elseif matches < lowestScore then
			if CyroChat.printMessages == true then
				d("Matched2: " .. messageSplit[i] .. " > " .. name .. " ; score " .. matches)
			end

			if checkingLocation == true then
				if foundOverallLocation ~= nil then
					CyroChat.foundDoubleLocations = true
					return nil
				end

				foundOverallLocation = messageSplit[i]
			end

			lowestScore = matches
			bestWord = messageSplit[i]
		end
	end

	return bestWord
end

-- wordToCheck == messageSplit
function CyroChat.findMatches(checkingLocation, wordToCheck, wordToCompare, lowestScore, checkLength)
	--[[if CyroChat.printMessages == true then
		d("Inside findMatches: "..tostring(wordToCheck).." > "..tostring(wordToCompare))
	end]]

	if wordToCheck == wordToCompare then
		return 0
	end

	local matches = -1

	if wordToCheck == 'fara' then
		return matches
	end

	if checkingLocation == true then
		for j=1, #CyroChat.weirdLocationWordsMatching do
			if wordToCheck == string.lower(CyroChat.weirdLocationWordsMatching[j]) then
				return matches
			end
		end

		if string.len(wordToCompare) <= 5 then
			return matches
		end
	else
		if CyroChat.matchedLocationOn ~= nil then
			if CyroChat.matchedLocationOn == wordToCheck then
				return matches
			end
		end
	end

	if string.sub(wordToCheck, 1, 1) ~= string.sub(wordToCompare, 1, 1) then
		return matches
	end

	if checkLength == true then
		if string.len(wordToCompare) <= 4 or string.len(wordToCheck) <= 4 then
			return matches
		end

		if string.len(wordToCheck) <= 2 then
			return matches
		end
	end

	if string.match(wordToCheck, '%d') ~= nil then
		return matches
	end

	if string.find(wordToCheck, '%%') then
		return matches
	end

	return CyroChat.EditDistance(wordToCheck, wordToCompare)
end

function CyroChat.checkMisspellings(messageSplit, arrayToCheck, sideToUse, lowestScore, checkingLocation, foundOverallLocation)
	local bestWord = nil
	local matches = -1

	for key, value in pairs(arrayToCheck) do
		if sideToUse == true then
			name = string.lower(key)
		elseif sideToUse == false then
			name = string.lower(value)
		end

		for i=1, #messageSplit do
			matches = CyroChat.findMatches(checkingLocation, messageSplit[i], name, lowestScore, true)

			if CyroChat.printMessages == true and matches > 0 then
				d("Possible Match: " .. messageSplit[i] .. " > " .. name .. " ; score " .. matches)
			end

			if matches < 0 then
				
			elseif matches == 0 or matches < lowestScore then
				if CyroChat.printMessages == true then
					d("Matched3: " .. messageSplit[i] .. " > " .. name .. " ; score " .. matches)
				end

				if checkingLocation == true then
					if foundOverallLocation ~= nil then
						CyroChat.foundDoubleLocations = true
						return nil
					end

					CyroChat.matchedLocationOn = messageSplit[i]

					foundOverallLocation = messageSplit[i]
				end

				bestWord = name
				lowestScore = matches
			elseif checkingLocation == true and matches < CyroChat.locationNumber and foundOverallLocation ~= nil then
				if CyroChat.printMessages == true then
					d("Matched4: " .. messageSplit[i] .. " > " .. name .. " ; score " .. matches)
				end

				CyroChat.foundDoubleLocations = true
				return nil
			end
		end
	end

	--[[if checkingLocation == true then
		if bestWord == nil and foundOverallLocation ~= nil then
			return foundOverallLocation
		end
	end]]

	return bestWord
end

function CyroChat.string_split(string, pattern)
	pattern = pattern or "%S+"
	local array = {}

	for i in string.gmatch(string, pattern) do
		table.insert(array, i)
	end

	return array
end

function CyroChat.clearOutChatMessage(message)
	local messageSplit = CyroChat.string_split(message)

	for stopWord, _ in pairs(CyroChat.removeWords) do
		stopWord = string.lower(stopWord)

		for i=1, #messageSplit do
			if messageSplit[i] == stopWord then
				if i == 1 then
					message = message:gsub(stopWord..'[^%a]', " ")
				elseif i == #messageSplit then
					message = message:gsub('[^%a]'..stopWord, " ")
				else
					message = message:gsub('[^%a]'..stopWord..'[^%a]', " ")
				end
			end
		end
	end

	return message
end

function CyroChat.getKeepId(lookingKeepName, looseSearch)
	for keepId, keepName in pairs(CyroChat.keeps) do
		if keepName == lookingKeepName then
			return keepId
		end

		if looseSearch == true then
			if string.find(string.lower(keepName), lookingKeepName) then
				return keepId
			end
		end
	end

	return nil
end

-- Copied from: https://gist.github.com/Nayruden/427389
-- Damerau–Levenshtein distance
--[[
    Function: EditDistance
    Finds the edit distance between two strings or tables. Edit distance is the minimum number of
    edits needed to transform one string or table into the other.
    
    Parameters:
    
        s - A *string* or *table*.
        t - Another *string* or *table* to compare against s.
        lim - An *optional number* to limit the function to a maximum edit distance. If specified
            and the function detects that the edit distance is going to be larger than limit, limit
            is returned immediately.
            
    Returns:
    
        A *number* specifying the minimum edits it takes to transform s into t or vice versa. Will
            not return a higher number than lim, if specified.
            
    Example:
        :EditDistance( "Tuesday", "Teusday" ) -- One transposition.
        :EditDistance( "kitten", "sitting" ) -- Two substitutions and a deletion.
        returns...
        :1
        :3
            
    Notes:
    
        * Complexity is O( (#t+1) * (#s+1) ) when lim isn't specified.
        * This function can be used to compare array-like tables as easily as strings.
        * The algorithm used is Damerau–Levenshtein distance, which calculates edit distance based
            off number of subsitutions, additions, deletions, and transpositions.
        * Source code for this function is based off the Wikipedia article for the algorithm
            <http://en.wikipedia.org/w/index.php?title=Damerau%E2%80%93Levenshtein_distance&oldid=351641537>.
        * This function is case sensitive when comparing strings.
        * If this function is being used several times a second, you should be taking advantage of
            the lim parameter.
        * Using this function to compare against a dictionary of 250,000 words took about 0.6
            seconds on my machine for the word "Teusday", around 10 seconds for very poorly 
            spelled words. Both tests used lim.
            
    Revisions:
        v1.00 - Initial.
]]
function CyroChat.EditDistance( s, t, lim )
    local s_len, t_len = #s, #t -- Calculate the sizes of the strings or arrays
    if lim and math.abs( s_len - t_len ) >= lim then -- If sizes differ by lim, we can stop here
        return lim
    end
    
    -- Convert string arguments to arrays of ints (ASCII values)
    if type( s ) == "string" then
        s = { string.byte( s, 1, s_len ) }
    end
    
    if type( t ) == "string" then
        t = { string.byte( t, 1, t_len ) }
    end
    
    local min = math.min -- Localize for performance
    local num_columns = t_len + 1 -- We use this a lot
    
    local d = {} -- (s_len+1) * (t_len+1) is going to be the size of this array
    -- This is technically a 2D array, but we're treating it as 1D. Remember that 2D access in the
    -- form my_2d_array[ i, j ] can be converted to my_1d_array[ i * num_columns + j ], where
    -- num_columns is the number of columns you had in the 2D array assuming row-major order and
    -- that row and column indices start at 0 (we're starting at 0).
    
    for i=0, s_len do
        d[ i * num_columns ] = i -- Initialize cost of deletion
    end
    for j=0, t_len do
        d[ j ] = j -- Initialize cost of insertion
    end
    
    for i=1, s_len do
        local i_pos = i * num_columns
        local best = lim -- Check to make sure something in this row will be below the limit
        for j=1, t_len do
            local add_cost = (s[ i ] ~= t[ j ] and 1 or 0)
            local val = min(
                d[ i_pos - num_columns + j ] + 1,                               -- Cost of deletion
                d[ i_pos + j - 1 ] + 1,                                         -- Cost of insertion
                d[ i_pos - num_columns + j - 1 ] + add_cost                     -- Cost of substitution, it might not cost anything if it's the same
            )
            d[ i_pos + j ] = val
            
            -- Is this eligible for tranposition?
            if i > 1 and j > 1 and s[ i ] == t[ j - 1 ] and s[ i - 1 ] == t[ j ] then
                d[ i_pos + j ] = min(
                    val,                                                        -- Current cost
                    d[ i_pos - num_columns - num_columns + j - 2 ] + add_cost   -- Cost of transposition
                )
            end
            
            if lim and val < best then
                best = val
            end
        end
        
        if lim and best >= lim then
            return lim
        end
    end
    
    return d[ #d ]
end
