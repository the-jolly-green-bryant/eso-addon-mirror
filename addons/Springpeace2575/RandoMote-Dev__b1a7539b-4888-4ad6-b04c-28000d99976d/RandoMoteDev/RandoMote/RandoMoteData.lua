-----------------------------------------------------------
-- Author: SpringPeace2575 | Version: 0.9.0
-- Data for RandoMote add-on
-----------------------------------------------------------

RandoMoteDataInner = RandoMoteDataInner or {}
local RMData = RandoMoteDataInner

RMData.Presets = { "None", "Dancer", "Musician", "Goofball", "Custom1", "Custom2", "Custom3" }
RMData.PresetNames = { "None", "Dancer", "Musician", "Goofball", "Custom 1", "Custom 2", "Custom 3" }
RMData.PresetNamesMap = {
    None     = "None",
    Dancer   = "Dancer",
    Musician = "Musician",
    Goofball = "Goofball",
    Custom1  = "Custom 1",
    Custom2  = "Custom 2",
    Custom3  = "Custom 3",
}

RMData.PresetEmoteKey = {
    None = "None",
    Dancer = "Dancer",
    Musician = "Musician",
    Goofball = "Goofball",
    Custom1 = "Custom1",
    Custom2 = "Custom2",
    Custom3 = "Custom3",
}

-- TODO: more predefined presets
RMData.predefinedPresetEmote = {
	Dancer = {
		alinorallemande = true,
		dancefan = true,
		dancefestive = true,
		dancecelebration = true,
		dance = true,
		dancealtmer = true,
		danceargonian = true,
		dancebosmer = true,
		dancebreton = true,
		dancedarkelf = true,
		dancedrunk = true,
		dancedunmer = true,
		dancehighelf = true,
		danceimperial = true,
		dancekhajiit = true,
		dancenord = true,
		danceorc = true,
		danceredguard = true,
		dancewoodelf = true,
		twirl = true,
		dancefactotum = true,
		falkreathfrolic = true,
		dancejig = true,
		jig = true,
		danceskaal = true,
		sworddance = true,
		ringdance = true,
		firedance = true,
	},
	Musician = {
		fungaldrum = true,
		handpan = true,
		keyharp = true,
		glassharp = true,
		drum = true,
		esraj = true,
		flute = true,
		playglassarmonica = true,
		lute = true,
		bagpipes = true,
		panflute = true,
		qanun = true,
		ragnarthered = true,
		rattlers = true,
		playtinyviolin = true,
		trumpet1 = true,
		trumpet2 = true,
		trumpet3 = true,
		trumpetsolo = true,
		skullblocks = true,
	},
	Goofball = {
		arrowtoknee = true,
		bellylaugh = true,
		bullhorns = true,
		bumble = true,
		pocketscrib = true,
		happyface = true,
		felinehygiene = true,
		juggleyarn = true,
		kissthis = true,
		slapknee = true,
		lost = true,
		sweetroll = true,
		sadface = true,
		stompgrapes = true,
		teatime = true,
		teebatrick = true,
		wayrestparty = true,
		wickerman = true,
	},
	Custom1 = {},
	Custom2 = {},
	Custom3 = {},
	None = {},
}

RMData.categoryNames = {
	[1]  = "Ceremonial",
	[2]  = "Cheers and Jeers",
	[4]  = "Emotion",
	[5]  = "Entertainment",
	[6]  = "Food and Drink",
	[7]  = "Give Directions",
	[9]  = "Physical",
	[10] = "Poses and Fidgets",
	[11] = "Prop",
	[12] = "Social",
}

-- also length could be specified here
-- TODO: do this later
RMData.emotes = {
	-- Ceremonial STD
	attention = { loop = true },


	-- Poses and Fidgets STD
	sick = { loop = true, Drunk = { loop = false } },
}
