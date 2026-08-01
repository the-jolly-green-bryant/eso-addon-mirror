---=============================================================================
-- Home Auto-Preset System
---=============================================================================
CinematicCam.isHome = false
-- List of all trackable home IDs
CinematicCam.homeIds = {
    -- Inn Rooms
    3,  -- The Ebony Flask Inn
    1,  -- Mara's Kiss Public house
    2,  -- The Rosy Lion
    58, -- Golden Gryphon Garrett
    42, -- Saint Delyn Penthouse
    77, -- Snowmelt Suite
    68, -- Sugar Bowl Suite

    -- Apartments
    28, -- Autumn's Gate
    16, -- Captain Margaux's Place
    25, -- Cyrodilic Jungle House
    31, -- Hammerdeath Bungalow
    10, -- Humblemud
    19, -- Kragenhome
    22, -- Moonmirth House
    13, -- Snugpod
    34, -- Twin Arches

    -- Small Homes
    44, -- Ald Velothi Harbor House
    11, -- The Ample Domicile
    14, -- Bouldertree Refuge
    26, -- Domus Phrasticus
    49, -- Exorciseddven Cottage
    29, -- Grymharth's Woe
    35, -- House of the Silent Magnifico
    32, -- Mournoth Keep
    17, -- Ravenhurst
    23, -- Sleek Creek house
    20, -- Velothi Reverie

    -- Classic Homes
    43, -- Amaya Lake Lodge
    24, -- Dawnshadow
    33, -- Forsaken Stronghold
    18, -- Gardner house
    15, -- The Gorinir Estate
    36, -- Hunding's Palatial Hall
    30, -- Old Mistveil Manor
    21, -- Quondam Indorilia
    12, -- Stay-Moist Mansion
    27, -- Strident Springs Demesne

    -- Notable Homes
    47, -- Coldharbour Surreal Estate
    38, -- Daggerfall Overlook
    39, -- Ebonheart Chateau
    48, -- Hakkvild's High Hall
    37, -- Serenity Falls Estate
    41, -- Earthtear Cavern
    40, -- Grand Topal Hideaway
    46, -- Linchal Grand Manor
    45, -- Tel Galen Tower
    -- DLC Homes (Summerset)
    59, -- Alinor Crest Townhouse
    60, -- Colossal Aldmeri Grotto
    61, -- Hunter's Glade
    62, -- Grand Psijic Villa
    55, -- The Orbservatory Prior
    57, -- Princely Dawnlight Palace

    -- DLC Homes (Murkmire)
    64, -- Lakemire Xanmeer Manor
    63, -- Enchanted Snow Globe Home

    -- DLC Homes (Wrothgar)
    56, -- The Erstwhile Sanctuary

    -- DLC Homes (Elsweyr)
    69, -- Jodes' Embrace
    70, -- Hall of the Lunar Champion
    71, -- Moon-Sugar Meadow
    72, -- Wraithhome
    73, -- Lucky Cat Landing

    -- DLC Homes (Skyrim)
    78, -- Proudspire Manor
    75, -- Forgemaster Falls
    79, -- Bastion Sanguinaris
    80, -- Stillwaters Retreat

    -- DLC Homes (Other)
    66, -- Elinhir Private Arena
    65, -- Frostvalt Chasm
    74, -- Potentate's Retreat
    76, -- Thieves' Oasis
    82, -- Shalidor's Shrouded Realm
    83, -- Stone Eagle Aerie
    85, -- Kushalit Sanctuary
    86, -- Varlaisvea Ayleid Ruins
    90, -- Doomchar Plateau
    91, -- Sweetwater Cascades
    92, -- Ossa Accentium
    54, -- Pariah's Pinnacle
    94, -- Seaveil Spire
}

-- Build lookup table for fast checking
CinematicCam.homeIdsLookup = {}

function CinematicCam:BuildHomeIdsLookup()
    self.homeIdsLookup = {}
    for _, homeId in ipairs(self.homeIds) do
        self.homeIdsLookup[homeId] = true
    end
end

function CinematicCam:CheckAndApplyHomePreset()
    CinematicCam.savedVars.isHome = false
    local currentHouseId = GetCurrentZoneHouseId()
    -- Check if we're in a trackable home
    if currentHouseId and self.homeIdsLookup[currentHouseId] then
        CinematicCam.savedVars.isHome = true
        -- Check if this home has an assigned preset
        self:LoadFromPresetSlot(1)
    end
end

CinematicCam.categorizedEmotes = {
    respectful = {
        "/attention", "/bestowblessing", "/bless", "/blessing", "/bow", "/bow2",
        "/handtoheart", "/honor",
        "/salute", "/saluteloop", "/salute2", "/saluteloop2",
        "/salute3", "/saluteloop3"
    },

    friendly = {
        "/grats", "/thanks", "/thank", "/thankyou",
        "/beckon",
        "/congratulate", "/wave", "/welcome"
    },

    greeting = {
        "/hello", "/welcome", '/wave', "/hail"
    },

    hostile = {
        "/idle4", "/brushoff", "/twiddle"
    },

    frustrated = {
        "/doom", "/facepalm", "/impatient", "/armscrossed",
        "/bored", "/sigh", "/huh", "/tap"
    },

    sad = {
        "/heartbroken", "/cry", "/downcast", "/sad", "/crying", "/humble",
        "/beg", "/beggar", "/plead"
    },

    scared = {
        "/scared", "/surprised"
    },

    confused = {
        "/armscrossed", "/twiddle", "/shrug", "/tilt", "/huh"
    },



    disgusted = {
        "/disgust", "/spit", "/brushoff", "/dismiss", "/goaway", "/disapprove"
    },

    eating = {
        "/drink3", "/drink2", "/drink", "/meal", "/eat3", "/eatbread",
        "/eat2", "/eat4", "/pie", "/smallbread", "/soupbowl", "/eat",
    },

    entertainment = {
        "/dance", "/dancedrunk", "/danceargonian", "/dancebreton", "/dancedarkelf",
        "/dancedunmer", "/dancehighelf", "/dancealtmer", "/danceimperial",
        "/dancekhajiit", "/dancenord", "/danceorc", "/danceredguard", "/dancewoodelf",
        "/dancebosmer", "/juggleflame", "/drum", "/flute", "/lute", "/whistle"
    },

    idle = {
        "/idle", "/idle2", "/idle3", "/armscrossed",
        "/handsonhips"
    },

    sitting = {
        "/sit", "/sit2", "/sit3", "/sit4", "/sit5", "/sit6", "/sitchair",
    },

    pointing = {
        "/poke",
        "/you" },

    physical = {
        "/dustoff", "/headscratch", '/rubhands', "/stretch"
    },

    working = {
        "/letter", "/read"
    },

    tired = {
        "/breathless", "/knuckles", "/dustoff", "/headache", "/scratch",
        "/knockeddown", "/playdead", "/preen", "/rubhands", "/sick", "/stagger",
        "/drunk", "/cold", "/colder", "/phew", "/yawn"
    },

    agreement = {
        "/yes", "/nod", "/thumbsup", "/approve"
    },

    disagreement = {
        "/no", "/disapprove", "/thumbsdown", "/shakefist", "/twiddle", "/stop"
    },

    playful = {
        "/laugh", "/lol", "/drunk", "/dancedrunk", "/cuckoo", "/whistle"
    },

    --Hand gestures when player speaks
    chatty = {
        "/plead", "/brushoff", "/beg", "/huh", '/rubhands', "/shrug", "/tilt", "/surprised", "/thanks", "/twiddle"
    },

    reward = { "/take", "/thankyou" },

    vendor = { "/give" },

    reading = { "/read", "/letter" }
}
