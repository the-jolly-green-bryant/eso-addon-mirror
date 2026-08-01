AD_BLOCK_PLUS                   = {}
AD_BLOCK_PLUS.name              = "AdBlockPlus"
AD_BLOCK_PLUS.version           = "1.7"
AD_BLOCK_PLUS.playerName        = GetDisplayName()
AD_BLOCK_PLUS.variableVersion   = 1
AD_BLOCK_PLUS.savedVariables    = nil
AD_BLOCK_PLUS.maxHistory        = 100
AD_BLOCK_PLUS.language 			= GetCVar("language.2")
AD_BLOCK_PLUS.languageSupport 	= { "en", "de", "fr", "ru"}
AD_BLOCK_PLUS.controls 			= {}
AD_BLOCK_PLUS.slashCommand		= {
	history 		= "/abp",
	settings 		= "/abps",
}
AD_BLOCK_PLUS.chatStrings       = {

	achievement = {
		--primary     = { "h%d:achievement:", "h%d:collectible:", "level", "skyreach", "%f[%a]sr%f[%A]", "%f[%a]carr" }, -- frontier unsupported
		primary     = { "h%d:achievement:", "h%d:collectible:", "skyreach", "w#sr" }, -- level
		secondary   = { "wts", "wtb", "wtt", "sell", "hire", "buy", "rate", "price", "gold", "pm", "pst", "run", "skin", "gear", "trial", "arena", "loot", "drop", "person", "partner", "round", "free", "level", "carr%a", "%aisp%a", "%dm", "%dk", "%dg" },
		settings 	= {
			en 		= { name = "Achievements", tooltip = "Block Buy/Sell Advertisements For Achievements (Trials, Skins, Mounts, Skyreach Runs, Leveling, etc)" },
			de 		= { name = "Leistungen", tooltip = "Blockieren Sie Kauf- / Verkaufsanzeigen für Erfolge (Testversionen, Skins, Reittiere, Skyreach-Läufe, Leveln usw.)" },
			fr 		= { name = "Réalisations", tooltip = "Bloquer les publicités d'achat/vente pour les succès (essais, skins, montures, courses Skyreach, mise à niveau, etc.) " },
			ru 		= { name = "Достижения", tooltip = "Блокируйте объявления о покупке / продаже достижений (испытания, скины, средства передвижения, забеги по Небесному Пути, повышение уровня и т. Д.)" },
		},
		name 		= {
			en 		= "achievement",
			de 		= "leistung",
			fr 		= "réalisation",
			ru 		= "достижение",
		},
	},

	automated = {
		primary     = { "%w", "%p" },
		secondary   = { nil },
		settings 	= {
			en 		= { name = "Automated", tooltip = "Automated Group Requests\n(Dolmen, World Boss, etc)\nSingle Characters\n(x, y, z, 1, 2, 3, etc)" },
			de 		= { name = "Automatisiert", tooltip = "Automatisierte Anfragen/Einzelzeichen\n(x, y, z usw.)" },
			fr 		= { name = "Automatique", tooltip = "Requêtes automatisées/caractères uniques\n(x, y, z, etc.)" },
			ru 		= { name = "Автоматизированный", tooltip = "Автоматические запросы/отдельные символы\n(x, y, z и т. д.)" },
		},
		name 		= {
			en 		= "auto",
			de 		= "auto",
			fr 		= "auto",
			ru 		= "авто",
		},
	},

	crown = {
		primary     = { "crown" },
		secondary   = { "wts", "wtb", "wtt", "sell", "hire", "buy", "rate", "price", "gold", "pm", "pst", "%aisp%a", "%dm", "%dk", "%dg" },
		settings 	= {
			en 		= { name = "Crowns", tooltip = "Block Buy/Sell Crowns Advertisements" },
			de 		= { name = "Kronen", tooltip = "Block kaufen/verkaufen Kronen Werbung" },
			fr 		= { name = "Couronnes", tooltip = "Bloquer les publicités d'achat/vente de couronnes" },
			ru 		= { name = "Короны", tooltip = "Блокировка рекламы покупки/продажи крон" },
		},
		name 		= {
			en 		= "crown",
			de 		= "krone",
			fr 		= "couronner",
			ru 		= "крона",
		},
	},

	guild = {
		primary     = { "h%d:guild:" },
		secondary   = { nil },
		settings 	= {
			en 		= { name = "Guilds", tooltip = "Block Guild Advertisements" },
			de 		= { name = "Gilden", tooltip = "Gildenwerbung blockieren" },
			fr 		= { name = "Guildes", tooltip = "Bloquer les publicités de guilde" },
			ru 		= { name = "Гильдии", tooltip = "Блокировать рекламу гильдии" },
		},
		name 		= {
			en 		= "guild",
			de 		= "gilde",
			fr 		= "guilde",
			ru 		= "гильдия",
		},
	},

	group = {
		--primary     = { "%f[%a]lf%f[%A]", "%f[%a]lfm%f[%A]", "%f[%a]lfg%f[%A]", "lf%dm", "lf%d%dm" },
		primary     = { "w#lf", "lfm", "lfg", "lf%d" }, -- "need", "look",
		secondary   = { "tank", "dps", "dd", "heal", "partner", "grind", "run", "role", "group", "good", "gtg", "que", "need", "farm", "random", "trial", "arena", "skyreach", "w#sr" }, -- %f[%a]sr%f[%A]
		settings 	= {
			en 		= { name = "Groups", tooltip = "Block Group Advertisements (LFM, LFG, etc)" },
			de 		= { name = "Gruppen", tooltip = "Blockgruppenwerbung (LFM, LFG usw.)" },
			fr 		= { name = "Groupes", tooltip = "Annonces de groupe de blocs (LFM, LFG, etc.)" },
			ru 		= { name = "Группы", tooltip = "Блокировать групповую рекламу (LFM, LFG и т. Д.)" },
		},
		name 		= {
			en 		= "group",
			de 		= "gruppe",
			fr 		= "grouper",
			ru 		= "группа",
		},
	},

	item = {
		--primary     = { "h%d:item:", "%f[%a]wts%f[%A]", "%f[%a]wtb%f[%A]", "%f[%a]wtt%f[%A]" },
		primary     = { "h%d:item:", "wts", "wtb", "wtt" },
		secondary   = { "wts", "wtb", "wtt", "sell", "hire", "buy", "rate", "price", "gold", "pm", "pst", "pc", "ttc", "att", "mm", "free", "w#cod", "%aisp%a", "%dm", "%dk", "%dg", "x%d", "%dx" },
		settings 	= {
			en 		= { name = "Items", tooltip = "Block Item Advertisements (WTS, WTB, Price Check, etc)" },
			de 		= { name = "Artikel", tooltip = "Blockartikelwerbung (WTS, WTB, Preisprüfung usw.)" },
			fr 		= { name = "Articles", tooltip = "Bloquer les publicités d'articles (WTS, WTB, vérification des prix, etc.)" },
			ru 		= { name = "Предметы", tooltip = "Рекламные объявления о блоках (WTS, WTB, проверка цен и т. Д.)" },
		},
		name 		= {
			en 		= "item",
			de 		= "artikel",
			fr 		= "objet",
			ru 		= "предмет",
		},
	},

	url = {
		primary     = { "http:", "https:", "www%.", "discord%.gg" },
		secondary   = { nil },
		settings 	= {
			en 		= { name = "URL", tooltip = "Links (Websites, Discord, etc)" },
			de 		= { name = "URL", tooltip = "Links (Websites, Zwietracht usw.)" },
			fr 		= { name = "URL", tooltip = "Liens (sites Web, Discord, etc.)" },
			ru 		= { name = "URL", tooltip = "Ссылки (веб-сайты, Discord и т. Д.)" },
		},
		name 		= {
			en 		= "url",
			de 		= "url",
			fr 		= "url",
			ru 		= "url",
		},
	},
}

AD_BLOCK_PLUS.chatStringsCustom = {
	custom = {
		primary     = { nil },
		secondary   = { nil },
		settings 	= {
			en 		= { name = "Custom", tooltip = "Word List, Semicolon Separated (a;b;c;d;)" },
			de 		= { name = "Benutzerdefiniert", tooltip = "Wortliste, Semikolon getrennt (a;b;c;d;)" },
			fr 		= { name = "Personnalisé", tooltip = "Liste de mots, séparés par des points-virgules (a;b;c;d;)" },
			ru 		= { name = "Обычай", tooltip = "Список слов, разделенных точкой с запятой (a;b;c;d;)" },
		},
		name 		= {
			en 		= "custom",
			de 		= "benutzerdefiniert",
			fr 		= "douane",
			ru 		= "обычай",
		},
	}
}

local function ConvertChannelRGBToHex(ChatChannelCategory)
	local r, g, b = GetChatCategoryColor(ChatChannelCategory)
	return string.format("%.2x%.2x%.2x", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
end

CHAT_CHANNEL_GUILD_ALL = {
    CHAT_CHANNEL_GUILD_1,
    CHAT_CHANNEL_GUILD_2,
    CHAT_CHANNEL_GUILD_3,
    CHAT_CHANNEL_GUILD_4,
    CHAT_CHANNEL_GUILD_5
}
--local function CHAT_CHANNEL_GUILDS() return CHAT_CHANNEL_GUILD_ALL end


AD_BLOCK_PLUS.chatColor = {
	[CHAT_CHANNEL_SAY]      = ConvertChannelRGBToHex(CHAT_CATEGORY_SAY),
	[CHAT_CHANNEL_WHISPER]  = ConvertChannelRGBToHex(CHAT_CATEGORY_WHISPER_INCOMING),
	[CHAT_CHANNEL_EMOTE]    = ConvertChannelRGBToHex(CHAT_CATEGORY_EMOTE),
	[CHAT_CHANNEL_YELL]     = ConvertChannelRGBToHex(CHAT_CATEGORY_YELL),
	[CHAT_CHANNEL_PARTY]    = ConvertChannelRGBToHex(CHAT_CATEGORY_PARTY),
	[CHAT_CHANNEL_ZONE]     = ConvertChannelRGBToHex(CHAT_CATEGORY_ZONE),
    [CHAT_CHANNEL_GUILD_1]  = ConvertChannelRGBToHex(CHAT_CATEGORY_GUILD_1),
	[CHAT_CHANNEL_GUILD_2]  = ConvertChannelRGBToHex(CHAT_CATEGORY_GUILD_2),
	[CHAT_CHANNEL_GUILD_3]  = ConvertChannelRGBToHex(CHAT_CATEGORY_GUILD_3),
	[CHAT_CHANNEL_GUILD_4]  = ConvertChannelRGBToHex(CHAT_CATEGORY_GUILD_4),
	[CHAT_CHANNEL_GUILD_5]  = ConvertChannelRGBToHex(CHAT_CATEGORY_GUILD_5),
	[CHAT_CHANNEL_SYSTEM]	= ConvertChannelRGBToHex(CHAT_CATEGORY_SYSTEM),
	filter					= "c59e9e",
}

AD_BLOCK_PLUS.chatType      = {

	say 					= {
		channel 	= CHAT_CHANNEL_SAY,
		settings 	= {
			en 		= { name = "Say", tooltip = "Monitor 'Say' Chat Channel" },
			de 		= { name = "Sagen", tooltip = "Überwachen Sie den Chat-Kanal 'Sagen'" },
			fr 		= { name = "Dire", tooltip = "Surveiller le canal de discussion 'Dire'" },
			ru 		= { name = "Сказать", tooltip = "Следите за каналом чата 'Сказать'" },
		},
		name 		= {
			en 		= "say",
			de 		= "sagen",
			fr 		= "dire",
			ru 		= "cказать",
		},
	},
	whisper			= {
		channel 	= CHAT_CHANNEL_WHISPER,
		settings 	= {
			en 		= { name = "Whisper", tooltip = "Monitor 'Whisper' Chat Channel" },
			de 		= { name = "Flüstern", tooltip = "Überwachen Sie den Chat-Kanal 'Flüstern'" },
			fr 		= { name = "Chuchotement", tooltip = "Surveiller le canal de discussion 'Chuchotement'" },
			ru 		= { name = "Шепот", tooltip = "Следите за каналом чата 'Шепот'" },
		},
		name 		= {
			en 		= "whisper",
			de 		= "flüstern",
			fr 		= "chuchotement",
			ru 		= "Шепот",
		},
	},
	emote 			= {
		channel 	= CHAT_CHANNEL_EMOTE,
		settings 	= {
			en 		= { name = "Emote", tooltip = "Monitor 'Emote' Chat Channel" },
			de 		= { name = "Emote", tooltip = "Überwachen Sie den Chat-Kanal 'Emote'" },
			fr 		= { name = "Emote", tooltip = "Surveiller le canal de discussion 'Emote'" },
			ru 		= { name = "Эмоция", tooltip = "Следите за каналом чата 'Эмоция'" },
		},
		name 		= {
			en 		= "emote",
			de 		= "emote",
			fr 		= "emote",
			ru 		= "Эмоция",
		},
	},
	guilds			= {
		channel 	= CHAT_CHANNEL_GUILD_ALL,
		settings 	= {
			en 		= { name = "Guild", tooltip = "Monitor 'Guild' Chat Channel" },
			de 		= { name = "Gilde", tooltip = "Überwachen Sie den Chat-Kanal 'Gilde'" },
			fr 		= { name = "Guilde", tooltip = "Surveiller le canal de discussion 'Guilde'" },
			ru 		= { name = "Гильдия", tooltip = "Следите за каналом чата 'Гильдия'" },
		},
		name 		= {
			en 		= "guild",
			de 		= "gilde",
			fr 		= "guilde",
			ru 		= "гильдия",
		},
	},
	yell 			= {
		channel 	= CHAT_CHANNEL_YELL,
		settings 	= {
			en 		= { name = "Yell", tooltip = "Monitor 'Yell' Chat Channel" },
			de 		= { name = "Schrei", tooltip = "Überwachen Sie den Chat-Kanal 'Schreien'" },
			fr 		= { name = "Crier", tooltip = "Surveiller le canal de discussion 'Crier'" },
			ru 		= { name = "Кричать", tooltip = "Мониторинг канала чата 'Кричать'" },
		},
		name 		= {
			en 		= "Yell",
			de 		= "schrei",
			fr 		= "crier",
			ru 		= "Кричать",
		},
	},
	party 			= {
		channel 	= CHAT_CHANNEL_PARTY,
		settings 	= {
			en 		= { name = "Group", tooltip = "Monitor 'Group' Chat Channel" },
			de 		= { name = "Gruppe", tooltip = "Überwachen Sie den Chat-Kanal 'Gruppe'" },
			fr 		= { name = "Grouper", tooltip = "Surveiller le canal de discussion de groupe" },
			ru 		= { name = "Группа", tooltip = "Мониторинг канала чата 'Группа'" },
		},
		name 		= {
			en 		= "group",
			de 		= "gruppe",
			fr 		= "grouper",
			ru 		= "Группа",
		},
	},
	zone 			= {
		channel 	= CHAT_CHANNEL_ZONE,
		settings 	= {
			en 		= { name = "Zone", tooltip = "Monitor 'Zone' Chat Channel" },
			de 		= { name = "Zone", tooltip = "Überwachen Sie den Chat-Kanal 'Zone'" },
			fr 		= { name = "Zone", tooltip = "Surveiller le canal de discussion 'Zone'" },
			ru 		= { name = "Зона", tooltip = "Мониторинг канала чата 'Зона'" },
		},
		name 		= {
			en 		= "zone",
			de 		= "zone",
			fr 		= "zone",
			ru 		= "Зона",
		},
	},
}
AD_BLOCK_PLUS.defaults = {
	block 			= {},
	blocked         = 0,
	enable          = true,
	firstrun 		= false,
	friend			= true,
	history         = {},
	historyIndex    = 0,
	notify          = true,
	agressive 		= false,
	preset 			= nil,
}

for filterType in pairs(AD_BLOCK_PLUS.chatStrings) do
	AD_BLOCK_PLUS.defaults.block[filterType] = false
end

AD_BLOCK_PLUS.defaults.block.custom = false
AD_BLOCK_PLUS.defaults.block.customWords = ""

for chatChannel in pairs(AD_BLOCK_PLUS.chatType) do
	AD_BLOCK_PLUS.defaults.block[chatChannel] = false
end

AD_BLOCK_PLUS_LIST = ZO_SortFilterList:Subclass()

local function isLanguageSupported()
	for _, lang in pairs(AD_BLOCK_PLUS.languageSupport) do
		if AD_BLOCK_PLUS.language == lang then return true end
	end
	return false
end
if not isLanguageSupported() then AD_BLOCK_PLUS.language = "en" end
