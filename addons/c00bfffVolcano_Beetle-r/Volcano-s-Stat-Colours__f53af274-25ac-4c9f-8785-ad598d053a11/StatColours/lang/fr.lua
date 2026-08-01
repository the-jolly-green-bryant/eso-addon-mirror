if GetCVar("Language.2") ~= "fr" then return end

local strings = {
    { SI_DERIVEDSTATS7,  "|cd95238Santé maximale|r",                            2 },
    { SI_DERIVEDSTATS8,  "|cd95238Récupération de Santé|r",                     1 },
    { SI_ATTRIBUTES1,    "|cd95238Santé|r",                                     0 },
    { SI_DERIVEDSTATS10, "|cd95238Soins reçus|r",                               1 },
    { SI_COMBATMECHANICFLAGS32, "|cd95238Santé|r",                              0 },

    { SI_DERIVEDSTATS4,  "|c4cb4ffMagie maximale|r",                            2 },
    { SI_DERIVEDSTATS5,  "|c4cb4ffRécupération de Magie|r",                     1 },
    { SI_ATTRIBUTES2,    "|c4cb4ffMagie|r",                                     0 },

    { SI_DERIVEDSTATS29, "|c9af24bVigueur maximale|r",                          2 },
    { SI_DERIVEDSTATS30, "|c9af24bRécupération de Vigueur|r",                   1 },
    { SI_ATTRIBUTES3,    "|c9af24bVigueur|r",                                   0 },

    { SI_DAMAGETYPE2,    "|cffffffPhysique|r",                                  0 },
    { SI_DAMAGETYPE3,    "|cff8c00Feu|r",                                       0 },
    { SI_DAMAGETYPE4,    "|c8d6cd2Foudre|r",                                    0 },
    { SI_DAMAGETYPE6,    "|c00bfffGivre|r",                                     0 },
    { SI_DAMAGETYPE8,    "|cf441a2Magie|r",                                     0 },
    { SI_DAMAGETYPE10,   "|c339933Maladie|r",                                   0 },
    { SI_DAMAGETYPE11,   "|c339933Poison|r",                                    0 },
    { SI_DAMAGETYPE12,   "|cbe1515Saignement|r",                                0 },

    { SI_DERIVEDSTATS15, "|cbe1515Résistance au saignement|r",                  0 },
    { SI_DERIVEDSTATS26, "|cffffffRésistance aux sorts|r",                      0 },
    { SI_DERIVEDSTATS13, "|cffffffRésistance aux sorts|r",                      0 },
    { SI_DERIVEDSTATS22, "|cffffffRésistance physique|r",                       2 },
    { SI_DERIVEDSTATS38, "|cffffffRésistance physique|r",                       0 },
    { SI_DERIVEDSTATS24, "|cffffffRésistance aux coups critiques|r",           0 },

    { SI_DERIVEDSTATS2,  "Dégâts des |c9af24barmes|r et des |c4cb4ffsorts|r",  1 },
    { SI_DERIVEDSTATS25, "|c4cb4ffDégâts magiques|r",                           1 },
    { SI_DERIVEDSTATS35, "|c9af24bDégâts des armes|r",                          3 },
    { SI_DERIVEDSTATS3,  "|ca9a9a9Armure|r",                                    0 },
    { SI_DERIVEDSTATS27, "|ca9a9a9Pénétration Offensive|r",                     1 },
    { SI_DERIVEDSTATS33, "|ca9a9a9Pénétration physique|r",                      1 },
    { SI_DERIVEDSTATS34, "|ca9a9a9Pénétration des sorts|r",                     1 },
    { SI_DERIVEDSTATS28, "|cffff00Chance de critique|r",                        1 },
    { SI_DERIVEDSTATS16, "|cffff00Critique physique|r",                         1 },
    { SI_DERIVEDSTATS23, "|cffff00Critique magique|r",                          0 },
}

for _, data in ipairs(strings) do
    local id, text, version = unpack(data)
    SafeAddString(id, text, version)
end
