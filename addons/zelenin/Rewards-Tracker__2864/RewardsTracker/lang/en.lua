local localization_strings = {
    SI_BINDING_NAME_REWARDS_TRACKER_TOGGLE = "Toggle Rewards Tracker",
    SI_REWARDS_TRACKER_SO = "Sanctum Ophidia",
    SI_REWARDS_TRACKER_AA = "Aetherian Archive",
    SI_REWARDS_TRACKER_HRC = "Hel Ra Citadel",
    SI_REWARDS_TRACKER_MOL = "Maw of Lorkhaj",
    SI_REWARDS_TRACKER_HOF = "Halls of Fabrication",
    SI_REWARDS_TRACKER_AS = "Asylum Sanctorium",
    SI_REWARDS_TRACKER_CR = "Cloudrest",
    SI_REWARDS_TRACKER_SS = "Sunspire",
    SI_REWARDS_TRACKER_KA = "Kyne's Aegis",
    SI_REWARDS_TRACKER_RG = "Rockgrove",
    SI_REWARDS_TRACKER_DR = "Dreadsail Reef",
    SI_REWARDS_TRACKER_SE = "Sanity's Edge",
    SI_REWARDS_TRACKER_LC = "Lucent Citadel",
    SI_REWARDS_TRACKER_OC = "Ossein Cage",
    SI_REWARDS_TRACKER_RD = "Random Dungeon",
    SI_REWARDS_TRACKER_RB = "Random Battleground",
    SI_REWARDS_TRACKER_SHS = "Shadowy Supplier",
}

for stringId, stringValue in pairs(localization_strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
