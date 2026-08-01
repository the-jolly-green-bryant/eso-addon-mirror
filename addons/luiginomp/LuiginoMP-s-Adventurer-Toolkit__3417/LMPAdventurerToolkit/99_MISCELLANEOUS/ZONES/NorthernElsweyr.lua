ZONE_NORTHERN_ELSWEYR = {}
local zoneName = "Northern Elsweyr"

function ZONE_NORTHERN_ELSWEYR.GetName() return zoneName end

local subZones = {
    --Delves
    "Abode of Ignominy"
    ,"Darkpool Mine"
    ,"Desert Wind Caverns"
    ,"Predator Mesa"
    ,"The Tangle"
    ,"Tomb of the Serpents"
    --Points of Interest
    ,"Anequina Aqueduct"
    ,"Ashen Scar"
    ,"Cicatrice"
    ,"Hakoshae"
    ,"Merryvale Farms"
    ,"The Prowl"
    ,"Rimmen"
    ,"Riverhold"
    ,"The Stitches"
    ,"Two Moons at Tenmar Temple"
    ,"Weeping Scar"
    --Striking Locales
    ,"Defense Force Outpost"
    ,"Moon Gate of Anequina"
    ,"Sandswirl Manor"
    ,"Shadow Dance Ruins"
    ,"Sleepy Senche Mine"
    ,"Star Haven Adeptorium"
    ,"Valenwood Gate"
    --Set Stations
    ,"Rimmen Masterworks"
    ,"Starlight Adeptorium"
    ,"Valenwood Border Artisan Camp"
    --Public Dungeons
    ,"Orcrest"
    ,"Rimmen Necropolis"
    --Group Dungeons
    ,"Moongrave FaneScalebreaker"
    --Trials
    ,"Sunspire"
    --World Bosses
    ,"The Bone Pit"
    ,"Hill of Shattered Swords"
    ,"Nightmare Plateau"
    ,"Red Hands Run"
    ,"Scar's Edge"
    ,"Talon Gulch"
    --World Events
    ,"Prowl's Edge Dragonscour"
    ,"Sandblown Dragonscour"
    ,"Scab Ridge Dragonscour"
    --Player Houses
    ,"Hall of the Lunar Champion"
    ,"Jode's EmbraceCrown Store"
    ,"Moon-Sugar Meadow"
    ,"Sugar Bowl Suite"
    --Wayshrines
    ,"Hakoshae Wayshrine"
    ,"Rimmen Wayshrine"
    ,"Riverhold Wayshrine"
    ,"Scar's End Wayshrine"
    ,"Star Haven Wayshrine"
    ,"The Stitches Wayshrine"
    ,"Tenmar Temple Wayshrine"
    --Unmarked
    ,"Bonechime Outpost"
    ,"Dov-Vahl Shrine"
    ,"Hakoshae Tombs"
    ,"Hidden Moon Crypts"
    ,"Meirvale Keep"
    ,"Sepulcher of Mischance"
    ,"Skooma Cat's Cloister"
    ,"S'rendarr's Cradle"
    ,"Tenarr Zalviit Ossuary"
}

function ZONE_NORTHERN_ELSWEYR.GetSubZones() return subZones end

local dialogueSkipList = {
    --Don't Skip
    --Names
    {"Shrine to Alkosh", false}
    ,{"Shrine to S'rendarr", false}
    --Titles

    --Skip
    --Names
    ,{"Battlereeve Tanerline", true}
    --Titles
}

function ZONE_NORTHERN_ELSWEYR.GetDialogueSkipList() return dialogueSkipList end
DIALOGUE_SKIPPER.AddToSkipSystemList(ZONE_NORTHERN_ELSWEYR)