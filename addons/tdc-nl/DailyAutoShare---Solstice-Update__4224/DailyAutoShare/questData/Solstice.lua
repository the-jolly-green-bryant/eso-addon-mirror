local zoneId = 1502 -- Solstice

DAS.shareables[zoneId] = {
	-- World Boss dailies, NPC = Morlia
	GetString(DAS_SOL_GAULM), -- 7264 Gaulm's Lair
	GetString(DAS_SOL_GUARD), -- 7265 Guardians Gone Bad
	GetString(DAS_SOL_TIDE), -- 7266 Tidewash Stranded
	-- Exploration dailies, NPC = Lector Volonaro
	GetString(DAS_SOL_CANDL), -- 7263 Candleflies for the Dead
	GetString(DAS_SOL_SANGU), -- 7262 Sanguine's Solace
	GetString(DAS_SOL_SAVE), -- 7261 Save the Ruins!
}

DAS.makeBingoTable(zoneId, {
	-- World Boss dailies, NPC = Morlia
	{"gl", "gaul", "sol"},
	{"gu", "guard", "sol"},
	{"td", "tide", "sol"},
	-- Exploration dailies, NPC = Lector Volonaro
	{"cn", "candle", "sol"},
	{"sg", "sangu", "sol"},
	{"sv", "save", "sol"},
})

DAS.questStarter[zoneId] = {
	[GetString(DAS_QUEST_SOL_BOSS)] = true, -- 323051 Morlia
	[GetString(DAS_QUEST_SOL_EXPL)] = true, -- 323052 Lector Volonaro
}

DAS.questFinisher[zoneId] = DAS.questStarter[zoneId]

local questIds = {
	-- World Boss dailies, NPC = Morlia
	[7264] = true, -- Gaulm's Lair
	[7265] = true, -- Guardians Gone Bad
	[7266] = true, -- Tidewash Stranded
	-- Exploration dailies, NPC = Lector Volonaro
	[7263] = true, -- Candleflies for the Dead
	[7262] = true, -- Sanguine's Solace
	[7261] = true, -- Save the Ruins!
}

DAS.questIds[zoneId] = questIds

for id, _ in pairs(questIds) do
	DAS_QUEST_IDS[id] = true
end