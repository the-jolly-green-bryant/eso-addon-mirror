if GetCVar("Language.2") ~= "es" then return end

local strings = {
    { SI_DERIVEDSTATS7,  "|cd95238Salud máxima|r",                          2 },
    { SI_DERIVEDSTATS8,  "|cd95238Recuperación de salud|r",                  1 },
    { SI_ATTRIBUTES1,    "|cd95238Salud|r",                                  0 },
    { SI_DERIVEDSTATS10, "|cd95238Curación recibida|r",                       1 },
    { SI_COMBATMECHANICFLAGS32, "|cd95238Salud|r",                            0 },

    { SI_DERIVEDSTATS4,  "|c4cb4ffMagia máxima|r",                            2 },
    { SI_DERIVEDSTATS5,  "|c4cb4ffRecuperación de magia|r",                   1 },
    { SI_ATTRIBUTES2,    "|c4cb4ffMagia|r",                                  0 },

    { SI_DERIVEDSTATS29, "|c9af24bAguante máximo|r",                          2 },
    { SI_DERIVEDSTATS30, "|c9af24bRecuperación de aguante|r",                 1 },
    { SI_ATTRIBUTES3,    "|c9af24bAguante|r",                                0 },

    { SI_DAMAGETYPE2,    "|cffffffFísico|r",                                 0 },
    { SI_DAMAGETYPE3,    "|cff8c00Llama|r",                                  0 },
    { SI_DAMAGETYPE4,    "|c8d6cd2Descarga eléctrica|r",                      0 },
    { SI_DAMAGETYPE6,    "|c00bfffEscarcha|r",                               0 },
    { SI_DAMAGETYPE8,    "|cf441a2Mágico|r",                                 0 },
    { SI_DAMAGETYPE10,   "|c339933Enfermedad|r",                              0 },
    { SI_DAMAGETYPE11,   "|c339933Veneno|r",                                 0 },
    { SI_DAMAGETYPE12,   "|cbe1515Sangrado|r",                                0 },

    { SI_DERIVEDSTATS15, "|cbe1515Resistencia al sangrado|r",                 0 },
    { SI_DERIVEDSTATS26, "|cffffffResistencia a los hechizos|r",             0 },
    { SI_DERIVEDSTATS13, "|cffffffResistencia a los hechizos|r",             0 },
    { SI_DERIVEDSTATS22, "|cffffffResistencia física|r",                      2 },
    { SI_DERIVEDSTATS38, "|cffffffResistencia física|r",                      0 },
    { SI_DERIVEDSTATS24, "|cffffffResistencia al daño crítico|r",             0 },

    { SI_DERIVEDSTATS2,  "Daño de |c9af24barma|r y |c4cb4ffhechizo|r",      1 },
    { SI_DERIVEDSTATS25, "|c4cb4ffDaño de hechizo|r",                        1 },
    { SI_DERIVEDSTATS35, "|c9af24bDaño por arma|r",                          3 },
    { SI_DERIVEDSTATS3,  "|ca9a9a9Armadura|r",                               0 },
    { SI_DERIVEDSTATS27, "|ca9a9a9Penetración ofensiva|r",                   1 },
    { SI_DERIVEDSTATS33, "|ca9a9a9Penetración física|r",                     1 },
    { SI_DERIVEDSTATS34, "|ca9a9a9Penetración de hechizo|r",                 1 },
    { SI_DERIVEDSTATS28, "|cffff00Probabilidad de crítico|r",                 1 },
    { SI_DERIVEDSTATS16, "|cffff00Crítico de arma|r",                         1 },
    { SI_DERIVEDSTATS23, "|cffff00Crítico de hechizo|r",                      0 },
}

for _, data in ipairs(strings) do
    local id, text, version = unpack(data)
    SafeAddString(id, text, version)
end
