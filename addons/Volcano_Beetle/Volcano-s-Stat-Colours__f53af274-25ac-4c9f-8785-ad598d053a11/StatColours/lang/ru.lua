if GetCVar("Language.2") ~= "ru" then return end

local strings = {
    { SI_DERIVEDSTATS7,  "|cd95238Макс. здоровье|r",                2 },
    { SI_DERIVEDSTATS8,  "|cd95238Восст. здоровья|r",               1 },
    { SI_ATTRIBUTES1,    "|cd95238Здоровье|r",                      0 },
    { SI_DERIVEDSTATS10, "|cd95238Получаемое лечение|r",            1 },
    { SI_COMBATMECHANICFLAGS32, "|cd95238ед. здоровья|r",               0 },

    { SI_DERIVEDSTATS4,  "|c4cb4ffМакс. магия|r",                   2 },
    { SI_DERIVEDSTATS5,  "|c4cb4ffВосст. магии|r",                  1 },
    { SI_ATTRIBUTES2,    "|c4cb4ffМагия|r",                         0 },

    { SI_DERIVEDSTATS29, "|c9af24bМакс. запас сил|r",               2 },
    { SI_DERIVEDSTATS30, "|c9af24bВосст. запаса сил|r",             1 },
    { SI_ATTRIBUTES3,    "|c9af24bЗапас сил|r",                  0 },

    { SI_DAMAGETYPE2,    "|cffffffФизического|r",                   0 },
    { SI_DAMAGETYPE3,    "|cff8c00Огненного|r",                     0 },
    { SI_DAMAGETYPE4,    "|c8d6cd2Электрического|r",                0 },
    { SI_DAMAGETYPE6,    "|c00bfffМорозного|r",                     0 },
    { SI_DAMAGETYPE8,    "|cf441a2Магического|r",                   0 },
    { SI_DAMAGETYPE10,   "|c339933Болезнетворного|r",               0 },
    { SI_DAMAGETYPE11,   "|c339933Ядовитого|r",                     0 },
    { SI_DAMAGETYPE12,   "|cbe1515Вызванного кровотечением|r",      0 },

    { SI_DERIVEDSTATS15, "|cbe1515Сопротивляемость кровотечению|r", 0 },
    { SI_DERIVEDSTATS26, "|cffffffМаг. сопротивляемость|r",          0 },
    { SI_DERIVEDSTATS13, "|cffffffМаг. сопротивляемость|r",          0 },
    { SI_DERIVEDSTATS22, "|cffffffФиз. сопротивляемость|r",          2 },
    { SI_DERIVEDSTATS38, "|cffffffФиз. сопротивляемость|r",          0 },
    { SI_DERIVEDSTATS24, "|cffffffСопротивл. крит. урону|r",         0 },

    { SI_DERIVEDSTATS2,  "Сила |c9af24bоружия|r и |c4cb4ffзаклинаний|r", 1 },
    { SI_DERIVEDSTATS25, "|c4cb4ffСила заклинаний|r",                 1 },
    { SI_DERIVEDSTATS35, "|c9af24bСила оружия|r",                     3 },
    { SI_DERIVEDSTATS3,  "|ca9a9a9Броня|r",                           0 },
    { SI_DERIVEDSTATS27, "|ca9a9a9Пробивание|r",                      1 },
    { SI_DERIVEDSTATS33, "|ca9a9a9Физическое пробивание|r",           1 },
    { SI_DERIVEDSTATS34, "|ca9a9a9Магическое пробивание|r",           1 },
    { SI_DERIVEDSTATS28, "|cffff00Шанс крит. удара|r",                1 },
    { SI_DERIVEDSTATS16, "|cffff00Крит. рейтинг оружия|r",            1 },
    { SI_DERIVEDSTATS23, "|cffff00Крит. рейтинг заклинаний|r",        0 },
}

for _, data in ipairs(strings) do
    local id, text, version = unpack(data)
    SafeAddString(id, text, version)
end
