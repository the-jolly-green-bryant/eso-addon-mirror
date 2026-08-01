FOB = {
    -- for some reason using SI_GAMECAMERAACTIONTYPEs does not work in some languages
    Actions = {
        Catch = GetString(FOB_CATCH),
        Collect = GetString(FOB_COLLECT),
        Examine = GetString(FOB_EXAMINE),
        Loot = GetString(FOB_LOOT),
        Open = GetString(FOB_OPEN),
        Search = GetString(FOB_SEARCH),
        Take = GetString(FOB_TAKE),
        Talk = GetString(FOB_TALK),
        Use = GetString(FOB_USE)
    },
    BladeOfWoe = GetAbilityName(78219, "player"),
    Bookshelf = GetString(FOB_BOOKSHELF),
    CheeseIcons = {
        "/esoui/art/icons/housing_bre_inc_cheese001.dds",
        "/esoui/art/icons/quest_trollfat_001.dds",
        "/esoui/art/icons/quest_critter_001.dds",
        "/esoui/art/icons/ability_1handed_004.dds",
        "/esoui/art/icons/adornment_uni_radiusrebreather.dds"
    },
    CoffeeIcons = {
        "/esoui/art/icons/crafting_coffee_beans.dds",
        "/esoui/art/icons/housing_orc_inc_cupbone001.dds",
        "/esoui/art/icons/crowncrate_magickahealth_drink.dds"
    },
    DarkBrotherhood = GetString(FOB_DARK_BROTHERHOOD),
    DefIds = {
        Bastian = 1,
        Mirri = 2,
        Ember = 5,
        Isobel = 6,
        Sharp = 8,
        Azander = 9,
        Tanlorin = 12,
        Zerith = 13
    },
    Edicts = { [71779] = true, [73754] = true },
    Exceptions = {
        [GetString(FOB_LADY_LLARELS_SHELTER) or "nil"] = true,
        [GetString(FOB_BLACKHEART_HAVEN) or "nil"] = true,
        [GetString(FOB_SHINYTRADE) or "nil"] = true,
        [GetString(FOB_SEBASTIAN_BRUTYA or "nil")] = true,
        [GetString(FOB_MAZZA_MIRRI or "nil")] = true,
        [GetString(FOB_EVELI_SHARP_ARROW or "nil")] = true,
        [GetString(FOB_LERISA_DIE_GERISSENE or "nil")] = true,
    },
    FlyingInsects = {
        [GetString(FOB_BLACKREACH_JELLY)] = true,
        [GetString(FOB_BRIGHT_MOONS_LUNAR_MOTH)] = true,
        [GetString(FOB_BUTTERFLY)] = true,
        [GetString(FOB_CAVE_JELLY)] = true,
        [GetString(FOB_DRAGONFLY)] = true,
        [GetString(FOB_FETCHERFLY)] = true,
        [GetString(FOB_FLESHFLIES)] = true,
        [GetString(FOB_ISLAND_MOTH)] = true,
        [GetString(FOB_MOON_KISSED_JELLY)] = true,
        [GetString(FOB_NETCH_CALF)] = true,
        [GetString(FOB_SEHTS_DOVAH_FLY)] = true,
        [GetString(FOB_SWAMP_JELLY)] = true,
        [GetString(FOB_TORCHBUG)] = true,
        [GetString(FOB_WAFT)] = true,
        [GetString(FOB_WASP)] = true,
        [GetString(FOB_WINTER_MOTH)] = true
    },
    Functions = {},
    Illegal = {
        [GetString(SI_GAMECAMERAACTIONTYPE20)] = true, -- Steal From
        [GetString(SI_GAMECAMERAACTIONTYPE21)] = true, -- Pickpocket
        [GetString(SI_GAMECAMERAACTIONTYPE23)] = true  -- Trespass
    },
    LC = LibFBCommon,
    LF = string.char(10),
    Logo = "FOB/assets/FOB.dds",
    LogoBlock = "FOB/assets/fobBlock.dds",
    MagesGuild = GetString(FOB_MAGES_GUILD),
    MirriInsects = {
        [GetString(FOB_BUTTERFLY)] = true,
        [GetString(FOB_TORCHBUG)] = true
    },
    Mushrooms = {
        [GetString(FOB_BLANCHED_RUSSULA_CAP)] = true,
        [GetString(FOB_BLIGHT_BOG_MUSHROOM)] = true,
        [GetString(FOB_BLUE_ENTOLOMA)] = true,
        [GetString(FOB_CALDERA_MUSHROOM)] = true,
        [GetString(FOB_CANIS_CAP_MUSHROOM)] = true,
        [GetString(FOB_DUSK_MUSHROOM)] = true,
        [GetString(FOB_EMETIC_RUSSULA)] = true,
        [GetString(FOB_GLEAMCAP)] = true,
        [GetString(FOB_GLOOM_MOREL)] = true,
        [GetString(FOB_GLOOMSPORE_AGARIC)] = true,
        [GetString(FOB_GRAVEN_CAP)] = true,
        [GetString(FOB_IMP_STOOL)] = true,
        [GetString(FOB_IRONSTALK_MUSHROOM)] = true,
        [GetString(FOB_KWAMA_CAP)] = true,
        [GetString(FOB_LAVANDER_CAP)] = true,
        [GetString(FOB_LUMINOUS_RUSSULA)] = true,
        [GetString(FOB_NAMIRAS_ROT)] = true,
        [GetString(FOB_PARASOL_LICHEN)] = true,
        [GetString(FOB_PRUNE_MOREL_MUSHROOM)] = true,
        [GetString(FOB_STINKHORN)] = true,
        [GetString(FOB_VIOLET_COPRINUS)] = true,
        [GetString(FOB_WHITE_CAP)] = true
    },
    Name = "FOB",
    Nirnroot = GetString(FOB_NIRNROOT),
    NoPickPocketing = {},
    OutlawsRefuge = {
        [zo_strlower(GetString(FOB_OUTLAWS_REFUGE))] = true,
        [zo_strlower(GetString(FOB_THIEVES_DEN))] = true
    },
    PsijicPortal = GetString(FOB_PSIJIC_PORTAL),
    Treasures = {
        [GetString(FOB_RITUAL)] = true,
        [GetString(FOB_MEDICAL)] = true
    }
}
