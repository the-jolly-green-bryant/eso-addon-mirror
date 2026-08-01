HIGH_ISLE = {}
local zoneName = "High Isle"

function HIGH_ISLE.GetName() return zoneName end

local subZones = {
    --Delves
    "Breakwater Cave"
    ,"Coral Cliffs"
    ,"Death's Valor Keep"
    ,"The Firepot"
    ,"Shipwreck Shoals"
    ,"Whalefall"
    --Points of Interest
    ,"All Flags Islet"
    ,"Amenos Station"
    ,"Brokerock Mine"
    ,"Castle Navire"
    ,"Colossus View Lighthouse"
    ,"Garick's Rest"
    ,"Gonfalon Bay"
    ,"Skulltooth Coast"
    ,"Steadfast Manor"
    ,"Stonelore Grove"
    ,"Tor Draioch"
    ,"Abhain Chapel"
    ,"Druid's Gate"
    ,"Dufort Shipyards"
    ,"Gonfalon Head Lighthouse"
    ,"Jheury's Cove"
    ,"Port Navire"
    --Striking Locales
    ,"Albatross Leap"
    ,"Augury Monoliths"
    ,"Banished Refuge"
    ,"Green Serpent Getaway"
    ,"Spriggan's Crown"
    ,"Stonelore Falls"
    --Set Stations
    ,"Hidden Foundry"
    ,"Steadfast Hammer and Saw"
    ,"Stonelore Forge and Craft"
    --Public Dungeons
    ,"Ghost Haven Bay"
    ,"Spire of the Crimson Coin"
    --Group Dungeons

    --Trials
    ,"Dreadsail Reef"
    --World Bosses
    ,"Amenos Basin"
    ,"Dark Stone Hollow"
    ,"Faun Falls"
    ,"Mornard Falls"
    ,"Serpent Bog"
    ,"Y'ffre's Cauldron"
    --World Events
    ,"Volcanic Vents"
    --Player Houses
    ,"Ancient Anchor Berth"
    ,"Highhallow Hold"
    --Wayshrines
    ,"All Flags Wayshrine"
    ,"Amenos Station Wayshrine"
    ,"Brokerock Wayshrine"
    ,"Castle Navire Wayshrine"
    ,"Coral Road Wayshrine"
    ,"Dufort Shipyards Wayshrine"
    ,"Flooded Coast Wayshrine"
    ,"Garick's Rest Wayshrine"
    ,"Gonfalon Square Wayshrine"
    ,"Serpents Hollow Wayshrine"
    ,"Steadfast Manor Wayshrine"
    ,"Stonelore Grove Wayshrine"
    ,"Tor Draioch Wayshrine"
    ,"Trappers Peak Wayshrine"
    ,"Westbay Wayshrine"
    --Unmarked
    ,"Amenos Extraction Point"
    ,"Druid Circle"
    ,"Loch Abhain"
    ,"Loch Navire"
    ,"Mistmouth Cave"
    ,"Navire Dungeons"
    ,"The Slithermist"
    ,"Systres Sisters Vault"
    ,"Tarnished Grotto"
    ,"Wizard's Grotto"
    --Isolated Buildings
    ,"Erlibru's Cottage"
    ,"Finimi's Domicile"
    ,"Old Coin Fort"
}

function HIGH_ISLE.GetSubZones() return subZones end

local dialogueSkipList = {
    --Don't Skip
    --Names
    --Titles

    --Skip
    --Names
    {"Advocate Inwaldawin",true}
    ,{"Druid Farel",true}
    --Titles
}

function HIGH_ISLE.GetDialogueSkipList() return dialogueSkipList end
DIALOGUE_SKIPPER.AddToSkipSystemList(HIGH_ISLE)