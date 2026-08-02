local R = Conductor.Registry
local VERIFIED_PATCH = 50
local VERIFIED_DATE = "2026-07"
local META_SOURCE = "User-provided Update 50 ESO Logs / Community Meta research"

local entries = {
    -- Tank
    {"NAZARAY","Nazaray",{"DEBUFF_EXTENSION"},{"TANK","HEALER","SUPPORT"}},
    {"ARCHDRUID_DEVYRIC","Archdruid Devyric",{"MAJOR_VULNERABILITY"},{"TANK","SUPPORT"}},
    {"BARON_ZAUDRUS","Baron Zaudrus",{"ULTIMATE_RESTORE"},{"TANK","HEALER"}},
    {"TREMORSCALE","Tremorscale",{"RESISTANCE_REDUCTION"},{"TANK"}},
    {"BLOODSPAWN","Bloodspawn",{"ULTIMATE_RESTORE"},{"TANK"}},
    {"ENCRATIS_BEHEMOTH","Encratis's Behemoth",{"DAMAGE_AMPLIFICATION"},{"TANK","SUPPORT"}},
    {"LADY_THORN","Lady Thorn",{}, {"TANK"}},
    {"ENGINE_GUARDIAN","Engine Guardian",{"RESOURCE_RESTORE"},{"TANK"}},
    {"MAGMA_INCARNATE","Magma Incarnate",{}, {"TANK","HEALER"}},
    {"NUNATAK","Nunatak",{"MAJOR_BRITTLE"},{"TANK","SUPPORT"}},

    -- Healer
    {"SYMPHONY_OF_BLADES","Symphony of Blades",{"RESOURCE_RESTORE"},{"HEALER"}},
    {"OZEZAN_THE_INFERNO","Ozezan the Inferno",{"MINOR_VITALITY"},{"HEALER"}},
    {"EARTHGORE","Earthgore",{}, {"HEALER"}},
    {"SENTINEL_OF_RKUGAMZ","Sentinel of Rkugamz",{"RESOURCE_RESTORE"},{"HEALER"}},
    {"TROLL_KING","Troll King",{}, {"HEALER"}},
    {"BLIND_PATH_INDUCTION","Blind Path Induction",{}, {"HEALER"}},
    {"BOGDAN_THE_NIGHTFLAME","Bogdan the Nightflame",{}, {"HEALER"}},

    -- Damage dealer
    {"SLIMECRAW","Slimecraw",{}, {"DD"}},
    {"KJALNARS_NIGHTMARE","Kjalnar's Nightmare",{}, {"DD"}},
    {"ZAAN","Zaan",{}, {"DD"}},
    {"STORMFIST","Stormfist",{}, {"DD"}},
    {"SELENE","Selene",{}, {"DD"}},
    {"NERIENETH","Nerien'eth",{}, {"DD"}},
    {"VALKYN_SKORIA","Valkyn Skoria",{}, {"DD"}},
    {"MAW_OF_THE_INFERNAL","Maw of the Infernal",{}, {"DD"}},
    {"ICEHEART","Iceheart",{}, {"DD"}},
    {"VELIDRETH","Velidreth",{}, {"DD"}},

    -- Retained recognized provider
    {"VYKOSA","Vykosa",{"MINOR_COWARDICE"},{"TANK"}},
}
for _, entry in ipairs(entries) do
    R:Register("MONSTER_SETS",entry[1],{
        name=entry[2], provides=entry[3], roles=entry[4] or {},
        setIds={}, piecesRequired=2, needsIdValidation=true,
        verifiedPatch=VERIFIED_PATCH, lastVerifiedPatch=VERIFIED_PATCH,
        verifiedDate=VERIFIED_DATE, source=META_SOURCE, metaStatus="CURRENT_U50",
    })
end
