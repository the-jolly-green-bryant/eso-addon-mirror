ZONE_SOUTHERN_ELSWEYR = {}
local zoneName = "Southern Elsweyr"

function ZONE_SOUTHERN_ELSWEYR.GetName() return zoneName end

local subZones = {
    --Delves
    "Forsaken Citadel"
    ,"Moonlit Cove"
    --Points of Interest
    ,"Black Heights"
    ,"Senchal"
    ,"South Guard Ruins"
    --Striking Locales
    ,"Doomstone Keep"
    ,"Khenarthi's Arch"
    ,"Pridehome"
    ,"Purring Rock"
    ,"The Forgotten Mane"
    ,"Zazaradi's Quarry and Mine"
    --Set Stations
    ,"Cat's-Claw Station"
    ,"Dragonguard Armory"
    ,"Fur-Forge Cove"
    --World Bosses
    ,"Ri'Atahrashi's Training Ground"
    ,"Shrine of the Reforged"
    --World Events
    ,"North Dragonscour"
    ,"South Dragonscour"
    --Player Houses
    ,"Lucky Cat Landing"
    ,"Potentate's RetreatCrown Store"
    --Wayshrines
    ,"Black Heights Wayshrine"
    ,"Dragonguard Sanctum Wayshrine"
    ,"Pridehome Wayshrine"
    ,"Senchal Wayshrine"
    ,"South Guard Ruins Wayshrine"
    ,"Western Plains Wayshrine"
    --Unmarked Locations
    ,"Doomstone Caverns"
    ,"Dragonguard Sanctum"
    ,"Halls of the Highmane"
    ,"Hunt Master's Ruins"
    ,"Marzuk's Tower"
    ,"New Moon Fortress"
    ,"Nishzo's Hideout"
    ,"Passage of Dad'na Ghaten"
    ,"Western Plains"
    ,"West Sentry Tower"
    --Connected Realms
    ,"Dragonhold"
    ,"Dragonhold"
    ,"Jonelight Path"
    ,"Spilled Sand"
}

function ZONE_SOUTHERN_ELSWEYR.GetSubZones() return subZones end

local dialogueSkipList = {
    --Don't Skip
    --Names
    --Titles

    --Skip
    --Names
    --Titles
}

function ZONE_SOUTHERN_ELSWEYR.GetDialogueSkipList() return dialogueSkipList end
DIALOGUE_SKIPPER.AddToSkipSystemList(ZONE_SOUTHERN_ELSWEYR)