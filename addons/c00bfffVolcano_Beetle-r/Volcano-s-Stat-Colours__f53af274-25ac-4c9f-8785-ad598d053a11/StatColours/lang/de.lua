if GetCVar("Language.2") ~= "de" then return end

local strings = {
    { SI_DERIVEDSTATS7,  "|cd95238maximales Leben|r",                     2 },
    { SI_DERIVEDSTATS8,  "|cd95238Lebensregeneration|r",                   1 },
    { SI_ATTRIBUTES1,    "|cd95238Leben|r",                                0 },
    { SI_DERIVEDSTATS10, "|cd95238erhaltene Heilung|r",                    1 },
    { SI_COMBATMECHANICFLAGS32, "|cd95238Leben|r",                          0 },

    { SI_DERIVEDSTATS4,  "|c4cb4ffmaximale Magicka|r",                     2 },
    { SI_DERIVEDSTATS5,  "|c4cb4ffMagickaregeneration|r",                   1 },
    { SI_ATTRIBUTES2,    "|c4cb4ffMagicka|r",                              0 },

    { SI_DERIVEDSTATS29, "|c9af24bmaximale Ausdauer|r",                    2 },
    { SI_DERIVEDSTATS30, "|c9af24bAusdauerregeneration|r",                 1 },
    { SI_ATTRIBUTES3,    "|c9af24bAusdauer|r",                             0 },

    { SI_DAMAGETYPE2,    "|cffffffphysischer Schaden^m|r",                  0 },
    { SI_DAMAGETYPE3,    "|cff8c00Flammenschaden^m|r",                     0 },
    { SI_DAMAGETYPE4,    "|c8d6cd2Schockschaden^m|r",                      0 },
    { SI_DAMAGETYPE6,    "|c00bfffFrostschaden^m|r",                       0 },
    { SI_DAMAGETYPE8,    "|cf441a2Magieschaden^m|r",                       0 },
    { SI_DAMAGETYPE10,   "|c339933Seuchenschaden^m|r",                      0 },
    { SI_DAMAGETYPE11,   "|c339933Giftschaden^m|r",                        0 },
    { SI_DAMAGETYPE12,   "|cbe1515Blutungsschaden^m|r",                     0 },

    { SI_DERIVEDSTATS15, "|cbe1515Blutungsresistenz|r",                    0 },
    { SI_DERIVEDSTATS26, "|cffffffMagieresistenz|r",                       0 },
    { SI_DERIVEDSTATS13, "|cffffffMagieresistenz|r",                       0 },
    { SI_DERIVEDSTATS22, "|cffffffphysische Resistenz|r",                   2 },
    { SI_DERIVEDSTATS38, "|cffffffphysische Resistenz|r",                   0 },
    { SI_DERIVEDSTATS24, "|cffffffkritische Resistenz|r",                   0 },

    { SI_DERIVEDSTATS2,  "|c4cb4ffMagie|r- und |c9af24bWaffen|rkraft",                1 },
    { SI_DERIVEDSTATS25, "|c4cb4ffMagiekraft|r",                           1 },
    { SI_DERIVEDSTATS35, "|c9af24bWaffenkraft|r",                          3 },
    { SI_DERIVEDSTATS3,  "|ca9a9a9Rüstung|r",                              0 },
    { SI_DERIVEDSTATS27, "|ca9a9a9offensive Durchdringung|r",               1 },
    { SI_DERIVEDSTATS33, "|ca9a9a9Rüstungsdurchstoß|r",                    1 },
    { SI_DERIVEDSTATS34, "|ca9a9a9Magiedurchdringung|r",                   1 },
    { SI_DERIVEDSTATS28, "|cffff00Wertung für kritische Treffer|r",        1 },
    { SI_DERIVEDSTATS16, "|cffff00kritische Waffentreffer|r",               1 },
    { SI_DERIVEDSTATS23, "|cffff00kritische Magietreffer|r",                0 },
}

for _, data in ipairs(strings) do
    local id, text, version = unpack(data)
    SafeAddString(id, text, version)
end
