if GetCVar("Language.2") ~= "jp" then return end

local strings = {
    { SI_DERIVEDSTATS7,  "|cd95238最大体力|r",                      2 },
    { SI_DERIVEDSTATS8,  "|cd95238体力再生|r",                      1 },
    { SI_ATTRIBUTES1,    "|cd95238体力|r",                          0 },
    { SI_DERIVEDSTATS10, "|cd95238被回復|r",                        1 },
    { SI_COMBATMECHANICFLAGS32, "|cd95238体力|r",                  0 },

    { SI_DERIVEDSTATS4,  "|c4cb4ff最大マジカ|r",                    2 },
    { SI_DERIVEDSTATS5,  "|c4cb4ffマジカ再生|r",                    1 },
    { SI_ATTRIBUTES2,    "|c4cb4ffマジカ|r",                        0 },

    { SI_DERIVEDSTATS29, "|c9af24b最大スタミナ|r",                  2 },
    { SI_DERIVEDSTATS30, "|c9af24bスタミナ再生|r",                  1 },
    { SI_ATTRIBUTES3,    "|c9af24bスタミナ|r",                      0 },

    { SI_DAMAGETYPE2,    "|cffffff物理|r",                          0 },
    { SI_DAMAGETYPE3,    "|cff8c00炎|r",                            0 },
    { SI_DAMAGETYPE4,    "|c8d6cd2雷撃|r",                          0 },
    { SI_DAMAGETYPE6,    "|c00bfff氷結|r",                          0 },
    { SI_DAMAGETYPE8,    "|cf441a2魔法|r",                          0 },
    { SI_DAMAGETYPE10,   "|c339933病気|r",                          0 },
    { SI_DAMAGETYPE11,   "|c339933毒|r",                            0 },
    { SI_DAMAGETYPE12,   "|cbe1515出血|r",                          0 },

    { SI_DERIVEDSTATS15, "|cbe1515出血耐性|r",                      0 },
    { SI_DERIVEDSTATS26, "|cffffff呪文耐性|r",                      0 },
    { SI_DERIVEDSTATS13, "|cffffff呪文耐性|r",                      0 },
    { SI_DERIVEDSTATS22, "|cffffff物理耐性|r",                      2 },
    { SI_DERIVEDSTATS38, "|cffffff物理耐性|r",                      0 },
    { SI_DERIVEDSTATS24, "|cffffffクリティカル耐性|r",             0 },

    { SI_DERIVEDSTATS2,  "武器と|c9af24bスタミナ|rおよび|c4cb4ff呪文|rダメージ", 1 },
    { SI_DERIVEDSTATS25, "|c4cb4ff呪文ダメージ|r",                  1 },
    { SI_DERIVEDSTATS35, "|c9af24b武器ダメージ|r",                  3 },
    { SI_DERIVEDSTATS3,  "|ca9a9a9防御|r",                          0 },
    { SI_DERIVEDSTATS27, "|ca9a9a9攻撃貫通力|r",                    1 },
    { SI_DERIVEDSTATS33, "|ca9a9a9物理貫通|r",                      1 },
    { SI_DERIVEDSTATS34, "|ca9a9a9呪文貫通力|r",                    1 },
    { SI_DERIVEDSTATS28, "|cffff00クリティカルチャンス|r",         1 },
    { SI_DERIVEDSTATS16, "|cffff00武器クリティカル|r",             1 },
    { SI_DERIVEDSTATS23, "|cffff00呪文クリティカル|r",             0 },
}

for _, data in ipairs(strings) do
    local id, text, version = unpack(data)
    SafeAddString(id, text, version)
end
