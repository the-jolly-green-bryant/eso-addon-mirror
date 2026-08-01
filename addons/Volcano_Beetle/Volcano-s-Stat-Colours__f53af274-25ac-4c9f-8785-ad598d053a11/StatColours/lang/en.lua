if GetCVar("Language.2") ~= "en" then return end

local strings = {
    { SI_DERIVEDSTATS7,  "|cd95238Maximum Health|r",                2 },
    { SI_DERIVEDSTATS8,  "|cd95238Health Recovery|r",                1 },
    { SI_ATTRIBUTES1,    "|cd95238Health|r",                         0 },
    { SI_DERIVEDSTATS10, "|cd95238Healing Taken|r",                 1 },
    { SI_COMBATMECHANICFLAGS32, "|cd95238Health|r",                  0 },

    { SI_DERIVEDSTATS4,  "|c4cb4ffMaximum Magicka|r",               2 },
    { SI_DERIVEDSTATS5,  "|c4cb4ffMagicka Recovery|r",              1 },
    { SI_ATTRIBUTES2,    "|c4cb4ffMagicka|r",                       0 },

    { SI_DERIVEDSTATS29, "|c9af24bMaximum Stamina|r",               2 },
    { SI_DERIVEDSTATS30, "|c9af24bStamina Recovery|r",              1 },
    { SI_ATTRIBUTES3,    "|c9af24bStamina|r",                       0 },

    { SI_DAMAGETYPE2,    "|cffffffPhysical|r",                      0 },
    { SI_DAMAGETYPE3,    "|cff8c00Flame|r",                        0 },
    { SI_DAMAGETYPE4,    "|c8d6cd2Shock|r",                        0 },
    { SI_DAMAGETYPE6,    "|c00bfffFrost|r",                        0 },
    { SI_DAMAGETYPE8,    "|cf441a2Magic|r",                        0 },
    { SI_DAMAGETYPE10,   "|c339933Disease|r",                      0 },
    { SI_DAMAGETYPE11,   "|c339933Poison|r",                       0 },
    { SI_DAMAGETYPE12,   "|cbe1515Bleed|r",                        0 },

    { SI_DERIVEDSTATS15, "|cbe1515Bleed Resistance|r",             0 },
    { SI_DERIVEDSTATS26, "|cffffffSpell Resistance|r",             0 },
    { SI_DERIVEDSTATS13, "|cffffffSpell Resistance|r",             0 },
    { SI_DERIVEDSTATS22, "|cffffffPhysical Resistance|r",          2 },
    { SI_DERIVEDSTATS38, "|cffffffPhysical Resistance|r",          0 },
    { SI_DERIVEDSTATS24, "|cffffffCritical Resistance|r",          0 },

    { SI_DERIVEDSTATS2,  "|c9af24bWeapon|r and |c4cb4ffSpell Damage|r", 1 },
    { SI_DERIVEDSTATS25, "|c4cb4ffSpell Damage|r",                 1 },
    { SI_DERIVEDSTATS35, "|c9af24bWeapon Damage|r",                3 },
    { SI_DERIVEDSTATS3,  "|ca9a9a9Armor|r",                       0 },
    { SI_DERIVEDSTATS27, "|ca9a9a9Offensive Penetration|r",       1 },
    { SI_DERIVEDSTATS33, "|ca9a9a9Physical Penetration|r",        1 },
    { SI_DERIVEDSTATS34, "|ca9a9a9Spell Penetration|r",           1 },
    { SI_DERIVEDSTATS28, "|cffff00Critical Chance|r",             1 },
    { SI_DERIVEDSTATS16, "|cffff00Weapon Critical|r",             1 },
    { SI_DERIVEDSTATS23, "|cffff00Spell Critical|r",              0 },
}

for _, data in ipairs(strings) do
    local id, text, version = unpack(data)
    SafeAddString(id, text, version)
end
