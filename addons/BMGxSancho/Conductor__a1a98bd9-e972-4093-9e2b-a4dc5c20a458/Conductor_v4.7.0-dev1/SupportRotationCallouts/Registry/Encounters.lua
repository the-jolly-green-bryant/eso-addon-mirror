local R = Conductor.Registry
local trials = {
    "AETHERIAN_ARCHIVE", "HEL_RA_CITADEL", "SANCTUM_OPHIDIA", "MAW_OF_LORKHAJ",
    "HALLS_OF_FABRICATION", "ASYLUM_SANCTORIUM", "CLOUDREST", "SUNSPIRE",
    "KYNES_AEGIS", "ROCKGROVE", "DREADSAIL_REEF", "SANITYS_EDGE",
    "LUCENT_CITADEL", "OSSEIN_CAGE",
}
for _, key in ipairs(trials) do R:Register("TRIALS", key, { name = key, encounters = {}, researchStatus = "PENDING" }) end
