if GetCVar("Language.2") ~= "zh" then return end

local strings = {
    { SI_DERIVEDSTATS7,  "|cd95238生命上限|r",                      2 },
    { SI_DERIVEDSTATS8,  "|cd95238生命恢复|r",                      1 },
    { SI_ATTRIBUTES1,    "|cd95238生命|r",                          0 },
    { SI_DERIVEDSTATS10, "|cd95238受到的治疗|r",                    1 },
    { SI_COMBATMECHANICFLAGS32, "|cd95238生命|r",                  0 },

    { SI_DERIVEDSTATS4,  "|c4cb4ff魔力上限|r",                      2 },
    { SI_DERIVEDSTATS5,  "|c4cb4ff魔力恢复|r",                      1 },
    { SI_ATTRIBUTES2,    "|c4cb4ff魔力|r",                          0 },

    { SI_DERIVEDSTATS29, "|c9af24b耐力上限|r",                      2 },
    { SI_DERIVEDSTATS30, "|c9af24b耐力恢复|r",                      1 },
    { SI_ATTRIBUTES3,    "|c9af24b耐力|r",                          0 },

    { SI_DAMAGETYPE2,    "|cffffff物理|r",                          0 },
    { SI_DAMAGETYPE3,    "|cff8c00火焰|r",                          0 },
    { SI_DAMAGETYPE4,    "|c8d6cd2电击|r",                          0 },
    { SI_DAMAGETYPE6,    "|c00bfff寒霜|r",                          0 },
    { SI_DAMAGETYPE8,    "|cf441a2魔法|r",                          0 },
    { SI_DAMAGETYPE10,   "|c339933疾病|r",                          0 },
    { SI_DAMAGETYPE11,   "|c339933毒药|r",                          0 },
    { SI_DAMAGETYPE12,   "|cbe1515流血|r",                          0 },

    { SI_DERIVEDSTATS15, "|cbe1515流血抗性|r",                      0 },
    { SI_DERIVEDSTATS26, "|cffffff法术抗性|r",                      0 },
    { SI_DERIVEDSTATS13, "|cffffff法术抗性|r",                      0 },
    { SI_DERIVEDSTATS22, "|cffffff物理抗性|r",                      2 },
    { SI_DERIVEDSTATS38, "|cffffff物理抗性|r",                      0 },
    { SI_DERIVEDSTATS24, "|cffffff暴击抗性|r",                      0 },

    { SI_DERIVEDSTATS2,  "武器|c9af24b和|r|c4cb4ff法术|r伤害",       1 },
    { SI_DERIVEDSTATS25, "|c4cb4ff法术伤害|r",                      1 },
    { SI_DERIVEDSTATS35, "|c9af24b武器伤害|r",                      3 },
    { SI_DERIVEDSTATS3,  "|ca9a9a9护甲|r",                          0 },
    { SI_DERIVEDSTATS27, "|ca9a9a9攻击穿透|r",                      1 },
    { SI_DERIVEDSTATS33, "|ca9a9a9物理穿透|r",                      1 },
    { SI_DERIVEDSTATS34, "|ca9a9a9法术穿透|r",                      1 },
    { SI_DERIVEDSTATS28, "|cffff00暴击率|r",                        1 },
    { SI_DERIVEDSTATS16, "|cffff00武器暴击率|r",                    1 },
    { SI_DERIVEDSTATS23, "|cffff00法术暴击率|r",                    0 },
}

for _, data in ipairs(strings) do
    local id, text, version = unpack(data)
    SafeAddString(id, text, version)
end
