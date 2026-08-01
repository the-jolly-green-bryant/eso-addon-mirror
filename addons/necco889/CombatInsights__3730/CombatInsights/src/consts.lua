CombatInsightsConsts =
{

    --set with /widbg
    DEBUG_MODE=false,

    --for i=1, GetNumClasses() do d(GetClassInfo(i)) end
    CLASS_ID_DK       = 1,      -- index 1
    CLASS_ID_SORC     = 2,      -- index 2
    CLASS_ID_NB       = 3,      -- index 3
    CLASS_ID_TEMPLAR  = 6,      -- index 4
    CLASS_ID_WARDEN   = 4,      -- index 5
    CLASS_ID_NECRO    = 5,      -- index 6
    CLASS_ID_ARCANIST = 117,    -- index 7

    FIGHT_DATA_VERSION = 4600,  --update 46

    itemSlotsBody =
    {
        EQUIP_SLOT_CHEST, EQUIP_SLOT_FEET, EQUIP_SLOT_HAND, EQUIP_SLOT_HEAD,
        EQUIP_SLOT_LEGS, EQUIP_SLOT_SHOULDERS, EQUIP_SLOT_WAIST
    },

    itemSlotsJewels =
    {
        EQUIP_SLOT_NECK, EQUIP_SLOT_RING1, EQUIP_SLOT_RING2
    },

    slottableCpIds = 
    {
        ff   = 12,
        bs   = 31,
        da   = 25,
        ba   = 23,
        th   = 27,
        maa  = 264,
        ws   = 8,
        ua   = 4,
        fon  = 276,
        exp  = 277,
    
    },

    passiveCps = 
    {
        warmage   = 21,
        mighty   = 22,
    },


    CRIT_DMG_VALUE_BASE             = 50,
    CRIT_DMG_VALUE_MINOR_BRITTLE    = 10,
    CRIT_DMG_VALUE_MAJOR_BRITTLE    = 20,
    CRIT_DMG_VALUE_CATALYST         = 5,
    CRIT_DMG_VALUE_CATALYST_DUMMY   = 15,
    CRIT_DMG_VALUE_BACKSTABBER      = 10,
    CRIT_DMG_VALUE_FINESSE          = 8,
    CRIT_DMG_VALUE_MAX              = 125,
    
    PEN_MINORBREACH    = 2974,
    PEN_MAJORBREACH    = 5948,
    PEN_CRUSHER        = 2108,
    PEN_CRYSTALWEAPON  = 1000,
    PEN_ALKOSH         = 6000,
    PEN_CRIMSONOATH    = 3541,
    PEN_TREMORSCALE    = 2640,
    PEN_RUNICSUNDER    = 2200,
    PEN_FON_PER_STACK  = 660,
    
    DEBUFF_ID_CATALYST_FLAME = 142610,
    DEBUFF_ID_CATALYST_FROST = 142652,
    DEBUFF_ID_CATALYST_SHOCK = 142653,
    DEBUFF_ID_CATALYST_DUMMY = 181606,
    DEBUFF_ID_MINOR_BRITTLE = 145975,
    DEBUFF_ID_MAJOR_BRITTLE = 145977,
-- DEBUFF_ID_OFF_BALANCE = 62988,
    DEBUFF_ID_OFF_BALANCE = 120014,
    
    sorcPetAbilities =
    {
        [23664] = true,
        [178132] = true,
        [23667] = true,
        [29809] = true,
        [117255] = true,
        [77186] = true,
        [29529] = true,
        [29528] = true,
        [117274] = true,
        [117273] = true,
        [117321] = true,
        [117320] = true,
    },
    
    buffs =
    {
        -- dmg done
        minorBerserk = 62636,
        majorBerserk = 172866,
        minorSlayer = 147226,
        majorSlayer = 93109,
        -- crit dmg
        minorForce = 61746,
        majorForce = 40225,
        -- weapon dmg
        minorSorcery = 61685,
        minorBrutality = 61799,
        majorSorcery = 92503,
        majorBrutality = 76518,
        minorCourage = 147417,
        majorCourage = 109994,
        powerfulAssault = 61771,
        auraOfPride = 163401,
        weaponDmgEnchant = 21230,
        -- resource
        aggressiveHorn = 40224,
        -- sets
        sulxan = 154737,
        ansulActive = 194105,
        huntersFocus = 155150,
        bloodhungry = 214958,
        -- arena
        spectralCloak = 113617,
        mercilessCharge = 99789,
        -- skill line
        hawkeye = 78855,
        followUp = 60888,
        -- class specific
        sunsphere = 197255,     --dark flare
        sunsphere2 = 109420,    --solar barrage
        -- seethingFury = 122729,  --this gives the weapon damage bonus, no need to track
        seethingFuryWhip = 122658,  --this gives the 20% to whip
        crux = 184220,
        harnessedQuintessence = 184860, --arcanist wep dmg buff passive
        sunderer = 215727,  --sundered status effect +100 wep dmg
        graveLordsSacrifice = 117757,

        --scribing
        fieryBanner = 227003,   -- +6% dot
        magicalBanner = 217705, -- +6% magical
        shatteringBanner = 227004, -- +6% aoe
        sunderingBanner = 217704, -- +6% martial
        shockingBanner = 217706, -- +6% direct
        bannerCavaliersCharge = 227082, -- +6 wd / 1% bonus move speed (max 450): this is totally messed up, ignore this!
        
    },

    buffsIgnore = 
    {
        [227082] = true, -- bannerCavaliersCharge
        [227067] = true, -- some random effect of banner
    },

    debuffs =
    {
        minorBrittle = 145975,
        majorBrittle = 145977,
        majorBreach = 53881,
        minorBreach = 61742,
        crusher = 17906,
        minorVuln = 79717,
        majorVuln = 167061,
        
        -- class spec
        crystalWeapon = 143808,
        daedricPrey = 24328,
        engulfing = 31104,
        stagger = 134336,
        abyssalInk = 183008,        -- abyssal impact fixed debuff
        abyssalInk2 = 185825,       -- tentacular dread crux based debuff
        runicSunder = 187742,
        incap = 113107,
        soulharvest = 61400,
        
        --sets
        flameWeakness = 142610,
        frostWeakness = 142652,
        shockWeakness = 142653,
        mk = 127070,
        zen = 126597,
        encratis = 151034,  --behemoth's vulnerability
        alkosh = 76667,
        crimsonOath = 159288,
        tremorscale = 80866,
        bloodied = 214954,

        -- status effects
        burning = 18084,
        chilled = 95136,
        diseased = 178127,
        hemorrhaging = 148801,
        overcharged = 178118,
        poisoned = 21929,
        sundered = 178123,
        -- ablities for areana weapons
        warmth = 160949,
        poisonInjection = 44549,
        offBalance = 62988,

        --scribing
        magicKnife = 217358,
    },

    trialDummybuffs = 
    {
        "minorBerserk",
        "majorSlayer",
        "minorSorcery",
        "minorBrutality",
        "minorCourage",
        "majorCourage",
        "majorForce",
        "aggressiveHorn",

    },
    trialDummyDebuffs =
    {
        "minorBrittle",
        "majorBreach",
        "minorBreach",
        "crusher",
        "minorVuln",
        "majorVuln",
        "engulfing",
        -- this is implemented under one ability on the dummy: elemental catalyst (181606)
        "flameWeakness",
        "frostWeakness",
        "shockWeakness",
        "alkosh",
    },


    abilityTable = 
    {
--[[ --------------------------------------------------------]]
--[[ --------------------------------------------------------]]
--[[ ----------------------------Necro----------------------------]]
--[[ Glacial Colo --]] [122392] = { necro = true, graveLord = true, aoe = true, direct = true,},
--[[ Pestilent Colo hit 1 --]] [122399] = { necro = true, graveLord = true, aoe = true, direct = true,},
--[[ Pestilent Colo hit 2 --]] [122400] = { necro = true, graveLord = true, aoe = true, direct = true,},
--[[ Pestilent Colo hit 3 --]] [122401] = { necro = true, graveLord = true, aoe = true, direct = true,},
--[[ Venom Skull hit 1 --]] [117624] = { necro = true, graveLord = true, st = true, direct = true,},
--[[ Venom Skull hit 3 --]] [123699] = { necro = true, graveLord = true, st = true, direct = true,},
--[[ Venom Skull hit 3 --]] [123704] = { necro = true, graveLord = true, st = true, direct = true,},
--[[ Ricochet Skull 1 --]] [117637] = { necro = true, graveLord = true, st = true, direct = true,},
--[[ Ricochet Skull 2 --]] [123718] = { necro = true, graveLord = true, st = true, direct = true,},
--[[ Ricochet Skull 3 --]] [123719] = { necro = true, graveLord = true, st = true, direct = true,},
--[[ Ricochet Skull bounce --]] [123729] = { necro = true, graveLord = true, st = true, direct = true,},
--[[ Stalking Blastbones close 1,7s --]] [117757] = { necro = true, graveLord = true, aoe = true, direct = true, special = true,},
--[[ ----------------------------Stalking Blastbones 3,4s----------------------------]]
--[[ ----------------------------Stalking Blastbones 4,4s (stuck behind stairs)----------------------------]]
--[[ Blighted Blastbones --]] [117715] = { necro = true, graveLord = true, aoe = true, direct = true,},
--[[ Unnerving Boneyard (dot) --]] [117809] = { necro = true, graveLord = true, aoe = true, dot = true,},
--[[ Avid Boneyard no corpse --]] [117854] = { necro = true, graveLord = true, aoe = true, dot = true, special = true,},
--[[ ----------------------------Avid Boneyard with corpse----------------------------]]
--[[ Skeletal Archer hit 1 --]] [122774] = { necro = true, graveLord = true, st = true, direct = true, special = true, ignore = true,},
--[[ ----------------------------Skeletal Archer hit 2----------------------------]]
--[[ ----------------------------Skeletal Archer hit 3----------------------------]]
--[[ Skeletal Arcanist primary target --]] [118746] = { necro = true, graveLord = true, st = true, direct = true,},
--[[ Skeletal Arcanist aoe hit --]] [124468] = { necro = true, graveLord = true, aoe = true, direct = true,},
--[[ Mystic Siphon (dot) --]] [118011] = { necro = true, graveLord = true, aoe = true, dot = true,},
--[[ Avid Boneyard (Graverobber) --]] [115572] = { necro = true, graveLord = true, aoe = true, direct = true,},
--[[ Detonating Siphon (dot) --]] [118766] = { necro = true, graveLord = true, aoe = true, dot = true,},
--[[ Detonating Siphon (Explosion) --]] [123082] = { necro = true, graveLord = true, aoe = true, direct = true,},
--[[ Ruinous Scythe --]] [118226] = { necro = true, boneTyrant = true, aoe = true, direct = true,},
--[[ Hungry Scythe --]] [118223] = { necro = true, boneTyrant = true, aoe = true, direct = true,},
--[[ ----------------------------dragonknight----------------------------]]
--[[ shifting standard --]] [32960] = { dk = true, ardentFlame = true, aoe = true, dot = true,},
--[[ standrad of might --]] [32948] = { dk = true, ardentFlame = true, aoe = true, dot = true,},
--[[ molten whip --]] [20805] = { dk = true, ardentFlame = true, st = true, direct = true,},
--[[ venomous claw hit --]] [20668] = { dk = true, ardentFlame = true, st = true, direct = true,},
--[[ venomous claw dot first 1. hit --]] [44369] = { dk = true, ardentFlame = true, st = true, dot = true, },
--[[ noxious breath hit --]] [20944] = { dk = true, ardentFlame = true, aoe = true, direct = true,},
--[[ noxious breath dot --]] [31103] = { dk = true, ardentFlame = true, st = true, dot = true,},
--[[ chains of devastation --]] [20499] = { dk = true, ardentFlame = true, st = true, direct = true,},
--[[ flames of oblivion --]] [61945] = { dk = true, ardentFlame = true, st = true, direct = true,},
--[[ burning talons hit --]] [20252] = { dk = true, draconicPower = true, aoe = true, direct = true,},
--[[ burning talons dot --]] [31898] = { dk = true, draconicPower = true, st = true, dot = true,},
--[[ deep breath cast --]] [32792] = { dk = true, draconicPower = true, aoe = true, direct = true,},
--[[ deep breath explosion --]] [32794] = { dk = true, draconicPower = true, aoe = true, direct = true,},
--[[ stone giant 1. cast (aoe) --]] [134340] = { dk = true, earthenHeart = true, aoe = true, direct = true,},
--[[ stone giant stack casts (st) --]] [133027] = { dk = true, earthenHeart = true, st = true, direct = true,},
--[[ eruption cast --]] [32714] = { dk = true, earthenHeart = true, aoe = true, direct = true,},
--[[ eruption dot --]] [32711] = { dk = true, earthenHeart = true, aoe = true, dot = true,},
--[[ flame lash --]] [20816] = { dk = true, ardentFlame = true, st = true, direct = true,},
--[[ power lash (flame lash off balance) --]] [20824] = { dk = true, ardentFlame = true, st = true, direct = true,},
--[[ burning embers hit --]] [20660] = { dk = true, ardentFlame = true, st = true, direct = true,},
--[[ burning embers dot --]] [44373] = { dk = true, ardentFlame = true, st = true, dot = true,},
--[[ engulfing flames hit --]] [20930] = { dk = true, ardentFlame = true, aoe = true, direct = true,},
--[[ engulfing flames dot --]] [31104] = { dk = true, ardentFlame = true, st = true, dot = true,},
--[[ draw essence cast --]] [32785] = { dk = true, draconicPower = true, aoe = true, direct = true,},
--[[ draw essence explosion --]] [32787] = { dk = true, draconicPower = true, aoe = true, direct = true,},
--[[ chocking talons --]] [20251] = { dk = true, draconicPower = true, aoe = true, direct = true,},
--[[ ----------------------------arcanist----------------------------]]
--[[ the languid eye --]] [189869] = { arcanist = true, heraldOfTheTome = true, aoe = true, dot = true,},
--[[ tide king's gaze --]] [189839] = { arcanist = true, heraldOfTheTome = true, aoe = true, dot = true,},
--[[ writhing runeblades 1 --]] [188787] = { arcanist = true, heraldOfTheTome = true, st = true, direct = true,},
--[[ writhing runeblades 2 --]] [188186] = { arcanist = true, heraldOfTheTome = true, st = true, direct = true,},
--[[ writhing runeblades 3 --]] [185804] = { arcanist = true, heraldOfTheTome = true, st = true, direct = true,},
--[[ escalating runeblades hit 1 --]] [182980] = { arcanist = true, heraldOfTheTome = true, st = true, direct = true,},
--[[ escalating runeblades hit 2 --]] [182978] = { arcanist = true, heraldOfTheTome = true, st = true, direct = true,},
--[[ escalating runeblades hit 3 (aoe) --]] [182979] = { arcanist = true, heraldOfTheTome = true, aoe = true, direct = true,},
--[[ exhausting fatecarver --]] [183123] = { arcanist = true, heraldOfTheTome = true, aoe = true, direct = true, channel = true},
--[[ pragmatic fatecarver --]] [186370] = { arcanist = true, heraldOfTheTome = true, aoe = true, direct = true, channel = true},
--[[ cephaliarch's flail --]] [183006] = { arcanist = true, heraldOfTheTome = true, aoe = true, direct = true,},
--[[ tentacular dread --]] [185823] = { arcanist = true, heraldOfTheTome = true, aoe = true, direct = true, special = true,},
--[[ recuperative treatise --]] [183048] = { arcanist = true, heraldOfTheTome = true, st = true, direct = true,},
--[[ inspired scholarship --]] [185843] = { arcanist = true, heraldOfTheTome = true, st = true, direct = true,},
--[[ fulminating rune dot --]] [182989] = { arcanist = true, heraldOfTheTome = true, st = true, dot = true,},
--[[ fulminating rune proc --]] [185407] = { arcanist = true, heraldOfTheTome = true, aoe = true, direct = true,},
--[[ rune of displacement --]] [185840] = { arcanist = true, heraldOfTheTome = true, st = true, dot = true,},
--[[ ----------------------------sorc----------------------------]]
--[[ crystal fragments --]] [46324] = { sorcerer = true, darkMagic = true, st = true, direct = true,},
--[[ crystal fragments proc --]] [114716] = { sorcerer = true, darkMagic = true, st = true, direct = true,},
--[[ crystal weapon 1 --]] [143804] = { sorcerer = true, darkMagic = true, st = true, direct = true,},
--[[ crystal weapon 2 --]] [181056] = { sorcerer = true, darkMagic = true, st = true, direct = true,},
--[[ daedric tomb --]] [24843] = { sorcerer = true, darkMagic = true, st = true, direct = true,},
--[[ daedric minefield --]] [25161] = { sorcerer = true, darkMagic = true, st = true, direct = true,},
--[[ streak --]] [23239] = { sorcerer = true, stormCalling = true, aoe = true, direct = true,},
--[[ daedric prey proc primary target --]] [24329] = { sorcerer = true, daedricSummoning = true, st = true, direct = true,},
--[[ daedric prey proc other targets --]] [44511] = { sorcerer = true, daedricSummoning = true, aoe = true, direct = true,},
--[[ haunting curse primary target --]] [24331] = { sorcerer = true, daedricSummoning = true, st = true, direct = true,},
--[[ haunting curse other targets --]] [44515] = { sorcerer = true, daedricSummoning = true, aoe = true, direct = true,},
--[[ greater storm attro landing --]] [23664] = { sorcerer = true, daedricSummoning = true, aoe = true, direct = true,},
--[[ greater storm attro zap --]] [178132] = { sorcerer = true, daedricSummoning = true, st = true, dot = true,},
--[[ charged attro  landing --]] [23667] = { sorcerer = true, daedricSummoning = true, aoe = true, direct = true,},
--[[ charged attro  aoe --]] [29809] = { sorcerer = true, daedricSummoning = true, aoe = true, direct = true,},
--[[ volatile familiar (entropic touch) --]] [117255] = { sorcerer = true, daedricSummoning = true, st = true, direct = true,},
--[[ volatile familiar active (volatile pulse) --]] [77186] = { sorcerer = true, daedricSummoning = true, aoe = true, dot = true,},
--[[ clannfear --]] [29529] = { sorcerer = true, daedricSummoning = true, aoe = true, direct = true,},
--[[ clannfear headbutt --]] [29528] = { sorcerer = true, daedricSummoning = true, st = true, direct = true,},
--[[ twilight tormentor (zap) --]] [117274] = { sorcerer = true, daedricSummoning = true, st = true, direct = true,},
--[[ twilight tormentor (kick) --]] [117273] = { sorcerer = true, daedricSummoning = true, st = true, direct = true,},
--[[ twilight matriarch (zap) --]] [117321] = { sorcerer = true, daedricSummoning = true, st = true, direct = true,},
--[[ twilight matriarch (kick) --]] [117320] = { sorcerer = true, daedricSummoning = true, st = true, direct = true,},
--[[ bound armaments --]] [130293] = { sorcerer = true, daedricSummoning = true, st = true, direct = true,},
--[[ mages wrath hit --]] [19123] = { sorcerer = true, stormCalling = true, st = true, direct = true,},
--[[ mages wrath explosion --]] [19128] = { sorcerer = true, stormCalling = true, aoe = true, direct = true,},
--[[ endless fury --]] [19109] = { sorcerer = true, stormCalling = true, st = true, direct = true,},
--[[ boundless storm --]] [23214] = { sorcerer = true, stormCalling = true, aoe = true, dot = true,},
--[[ liquid lightning --]] [23202] = { sorcerer = true, stormCalling = true, dot = true,},
--[[ lightning flood --]] [23208] = { sorcerer = true, stormCalling = true, aoe = true, dot = true,},
--[[ power overload light attack --]] [114769] = { sorcerer = true, stormCalling = true, st = true, direct = true,},
--[[ power overload heavy attack --]] [24811] = { sorcerer = true, stormCalling = true, aoe = true, direct = true,},
--[[ energy overload light attack --]] [114773] = { sorcerer = true, stormCalling = true, st = true, direct = true,},
--[[ energy overload heavy attack --]] [114798] = { sorcerer = true, stormCalling = true, aoe = true, direct = true,},
--[[ ----------------------------templar----------------------------]]
--[[ everlasting sweep hit --]] [22144] = { templar = true, aedricSpear = true, aoe = true, direct = true,},
--[[ everlasting sweep dot --]] [62598] = { templar = true, aedricSpear = true, aoe = true, dot = true,},
--[[ crescent sweep hit --]] [62606] = { templar = true, aedricSpear = true, aoe = true, direct = true,},
--[[ crescent sweep dot --]] [22139] = { templar = true, aedricSpear = true, aoe = true, dot = true,},
--[[ biting jabs closest target --]] [44432] = { templar = true, aedricSpear = true, aoe = true, direct = true, channel = true,},
--[[ biting jabs other target --]] [26794] = { templar = true, aedricSpear = true, aoe = true, direct = true, channel = true,},
--[[ puncturing sweep closest target --]] [44436] = { templar = true, aedricSpear = true, aoe = true, direct = true, channel = true,},
--[[ puncturing sweep other target --]] [26799] = { templar = true, aedricSpear = true, aoe = true, direct = true, channel = true,},
--[[ aurora javelin close --]] [26800] = { templar = true, aedricSpear = true, st = true, direct = true, special = true, ignore = true,},
--[[ binding javelin --]] [26804] = { templar = true, aedricSpear = true, st = true, direct = true, special = true, ignore = true,},
--[[ explosive charge --]] [22165] = { templar = true, aedricSpear = true, aoe = true, direct = true,},
--[[ toppling charge --]] [15544] = { templar = true, aedricSpear = true, st = true, direct = true,},
--[[ luminous shards --]] [26859] = { templar = true, aedricSpear = true, aoe = true, direct = true,},
--[[ blazing spear hit --]] [26871] = { templar = true, aedricSpear = true, aoe = true, direct = true,},
--[[ blazing spear dot --]] [26879] = { templar = true, aedricSpear = true, aoe = true, dot = true,},
--[[ radiant ward --]] [22182] = { templar = true, aedricSpear = true, aoe = true, direct = true,},
--[[ balzing shield --]] [22181] = { templar = true, aedricSpear = true, aoe = true, direct = true,},
--[[ solar prison --]] [21756] = { templar = true, dawnsWrath = true, aoe = true, dot = true,},
--[[ solar distrubance --]] [217559] = { templar = true, dawnsWrath = true, aoe = true, dot = true,},
--[[ vampire's bane hit --]] [21729] = { templar = true, dawnsWrath = true, st = true, direct = true,},
--[[ vampire's bane dot --]] [21731] = { templar = true, dawnsWrath = true, st = true, dot = true,},
--[[ reflective light hit --]] [21732] = { templar = true, dawnsWrath = true, aoe = true, direct = true,},
--[[ reflective light dot --]] [21734] = { templar = true, dawnsWrath = true, st = true, dot = true,},
--[[ dark flare --]] [22110] = { templar = true, dawnsWrath = true, st = true, direct = true,},
--[[ solar barrage --]] [100218] = { templar = true, dawnsWrath = true, aoe = true, dot = true,},
--[[ purifying light hit --]] [89825] = { templar = true, dawnsWrath = true, st = true, direct = true,},
--[[ purifying light proc  --]] [27544] = { templar = true, dawnsWrath = true, st = true, direct = true,},
--[[ power of the light hit --]] [89828] = { templar = true, dawnsWrath = true, st = true, direct = true,},
--[[ power of the light proc --]] [27567] = { templar = true, dawnsWrath = true,},
--[[ radiant glory over 50% --]] [63956] = { templar = true, dawnsWrath = true, st = true, direct = true, channel = true},
--[[ radiant oppression over 50% --]] [63961] = { templar = true, dawnsWrath = true, st = true, direct = true, channel = true},
--[[ passive: burning light --]] [80170] = { templar = true, aedricSpear = true, st = true, direct = true,},
--[[ ----------------------------nightblade----------------------------]]
--[[ incapacitating strike --]] [113105] = { nightblade = true, assasination = true, st = true, direct = true,},
--[[ soul harvest --]] [36514] = { nightblade = true, assasination = true, st = true, direct = true,},
--[[ killers blade --]] [34843] = { nightblade = true, assasination = true, st = true, direct = true,},
--[[ impale --]] [34851] = { nightblade = true, assasination = true, st = true, direct = true,},
--[[ lotus fan hit --]] [25494] = { nightblade = true, assasination = true, st = true, direct = true,},
--[[ lotus fan dot --]] [35336] = { nightblade = true, assasination = true, st = true, dot = true,},
--[[ relentless focus --]] [61927] = { nightblade = true, assasination = true, st = true, direct = true,},
--[[ merciless resolve --]] [61919] = { nightblade = true, assasination = true, st = true, direct = true,},
--[[ surprise attack --]] [25260] = { nightblade = true, shadow = true, st = true, direct = true,},
--[[ concealed weapon --]] [25267] = { nightblade = true, shadow = true, st = true, direct = true,},
--[[ twisting path --]] [36052] = { nightblade = true, shadow = true, aoe = true, dot = true,},
--[[ dark shade strike --]] [123945] = { nightblade = true, shadow = true, st = true, direct = true,},
--[[ dark shade spin --]] [108936] = { nightblade = true, shadow = true, aoe = true, direct = true,},
--[[ shadow image arrow --]] [51556] = { nightblade = true, shadow = true, st = true, direct = true,},
--[[ soul tether hit --]] [35460] = { nightblade = true, siphoning = true, aoe = true, direct = true,},
--[[ soul tether dot --]] [35462] = { nightblade = true, siphoning = true, st = true, dot = true,},
--[[ swallow soul --]] [34835] = { nightblade = true, siphoning = true, st = true, direct = true,},
--[[ funnel health --]] [34838] = { nightblade = true, siphoning = true, st = true, direct = true,},
--[[ debilitate --]] [36947] = { nightblade = true, siphoning = true, st = true, dot = true,},
--[[ crippling grasp hit --]] [36963] = { nightblade = true, siphoning = true, st = true, direct = true,},
--[[ crippling grasp dot --]] [36960] = { nightblade = true, siphoning = true, st = true, dot = true,},
--[[ power extraction --]] [369901] = { nightblade = true, siphoning = true, aoe = true, direct = true,},
--[[ sap essence --]] [36891] = { nightblade = true, siphoning = true, aoe = true, direct = true,},
--[[ ----------------------------warden----------------------------]]
--[[ eternal guardian bite --]] [105906] = { warden = true, animalCompanion = true, st = true, direct = true,},
--[[ eternal guardian crushing swipe --]] [105907] = { warden = true, animalCompanion = true, aoe = true, direct = true,},
--[[ eternal guardian active hit --]] [105921] = { warden = true, animalCompanion = true, st = true, direct = true,},
--[[ wild guardian bite --]] [89219] = { warden = true, animalCompanion = true, st = true, direct = true,},
--[[ wild guardian crushing swipe --]] [89220] = { warden = true, animalCompanion = true, aoe = true, direct = true,},
--[[ wild guardian  active hit --]] [92160] = { warden = true, animalCompanion = true, st = true, direct = true,},
--[[ cutting dive hit --]] [85999] = { warden = true, animalCompanion = true, st = true, direct = true,},
--[[ cutting dive dot --]] [130140] = { warden = true, animalCompanion = true, st = true, dot = true,},
--[[ screaming cliff racer --]] [86003] = { warden = true, animalCompanion = true, st = true, direct = true,},
--[[ subterranean assault both proc --]] [94445] = { warden = true, animalCompanion = true, aoe = true, direct = true,},
--[[ deep fissure --]] [94424] = { warden = true, animalCompanion = true,},
--[[ fetcher infection --]] [101904] = { warden = true, animalCompanion = true, st = true, dot = true,},
--[[ growing swarm primary target --]] [101944] = { warden = true, animalCompanion = true, st = true, dot = true,},
--[[ growing swarm other targets --]] [130170] = { warden = true, animalCompanion = true, aoe = true, dot = true,},
--[[ northern storm --]] [88860] = { warden = true, wintersEmbrace = true, aoe = true, dot = true,},
--[[ permafrost --]] [88863] = { warden = true, wintersEmbrace = true, aoe = true, dot = true,},
--[[ winters revenge --]] [88802] = { warden = true, wintersEmbrace = true, aoe = true, dot = true,},
--[[ gripping shards --]] [88791] = { warden = true, wintersEmbrace = true, aoe = true, dot = true,},
--[[ arctic blast --]] [130406] = { warden = true, wintersEmbrace = true, aoe = true, dot = true,},
--[[ ----------------------------dual wield----------------------------]]
--[[ rend --]] [85192] = { dualWield = true, st = true, dot = true,},
--[[ thrive in chaos 1 enemy --]] [85182] = { dualWield = true, st = true, dot = true,},
--[[ ----------------------------thrive in chaos 3 enemy----------------------------]]
--[[ rapid strikes --]] [38857] = { dualWield = true, st = true, direct = true, channel = true,},
--[[ bloodthirst --]] [38846] = { dualWield = true, channel = true,},
--[[ Rending slashes dot --]] [38841] = { dualWield = true, st = true, dot = true,},
--[[ Rending slashes hit 1 --]] [38839] = { dualWield = true, st = true, direct = true,},
--[[ Rending slashes hit 2 --]] [38840] = { dualWield = true, st = true, direct = true,},
--[[ blood craze dot --]] [38848] = { dualWield = true, st = true, dot = true,},
--[[ blood craze hit 1 --]] [38845] = { dualWield = true, st = true, direct = true,},
--[[ blood craze hit 2 --]] [38847] = { dualWield = true, st = true, direct = true,},
--[[ Whirling Blades --]] [38891] = { dualWield = true, aoe = true, direct = true,},
--[[ steel tornado --]] [38861] = { dualWield = true,},
--[[ Quick Cloak --]] [62529] = { dualWield = true, aoe = true, dot = true,},
--[[ Deadly Cloak --]] [62547] = { dualWield = true, aoe = true, dot = true,},
--[[ shrouded daggers --]] [38914] = { dualWield = true, st = true, direct = true,},
--[[ shrouded daggers bounce --]] [68862] = { dualWield = true, st = true, direct = true,},
--[[ flying blade hit --]] [38910] = { dualWield = true, st = true, direct = true,},
--[[ flying blade jump --]] [126666] = { dualWield = true, st = true, direct = true,},
--[[ ----------------------------bow----------------------------]]
--[[ toxic barrage hit --]] [85260] = { bow = true, st = true, direct = true,},
--[[ toxic barrage dot --]] [85261] = { bow = true, st = true, dot = true,},
--[[ ballista --]] [85462] = { bow = true, st = true, direct = true,},
--[[ lethal arrow --]] [38685] = { bow = true, st = true, direct = true,},
--[[ focused aim --]] [38687] = { bow = true, st = true, direct = true,},
--[[ endless hail --]] [38690] = { bow = true, aoe = true, dot = true,},
--[[ arrow barrage --]] [38696] = { bow = true, aoe = true, dot = true,},
--[[ magnum shot --]] [38672] = { bow = true, st = true, direct = true,},
--[[ draining shot --]] [38669] = { bow = true, st = true, direct = true,},
--[[ bombard --]] [38723] = { bow = true, aoe = true, direct = true,},
--[[ acid spray hit --]] [38724] = { bow = true, aoe = true, direct = true,},
--[[ acid spray dot --]] [38703] = { bow = true, st = true, dot = true,},
--[[ venom arrow hit --]] [38645] = { bow = true, st = true, direct = true,},
--[[ venom arrow dot --]] [44545] = { bow = true, st = true, dot = true,},
--[[ poision injection hit --]] [38660] = { bow = true, st = true, direct = true,},
--[[ poision injection dot --]] [44549] = { bow = true, st = true, dot = true,},
--[[ ----------------------------two handed----------------------------]]
--[[ onslaught primary target --]] [83229] = { twoHanded = true, st = true, direct = true, special = true, ignore = true,},
--[[ onslaught other targets --]] [126497] = { twoHanded = true, aoe = true, direct = true, special = true, ignore = true,},
--[[ berserker rage primary target --]] [83328] = { twoHanded = true, st = true, direct = true, special = true, ignore = true,},
--[[ berserker rage other targets --]] [126492] = { twoHanded = true, aoe = true, direct = true, special = true, ignore = true,},
--[[ dizzying swing --]] [38814] = { twoHanded = true, st = true, direct = true,},
--[[ wrecking blow --]] [38807] = { twoHanded = true, st = true, direct = true,},
--[[ stampede hit --]] [38792] = { twoHanded = true, aoe = true, direct = true,},
--[[ stampede dot --]] [126474] = { twoHanded = true, aoe = true, dot = true,},
--[[ critical rush --]] [38782] = { twoHanded = true, st = true, direct = true, special = true, ignore = true,},
--[[ carve hit --]] [38745] = { twoHanded = true, aoe = true, direct = true,},
--[[ carve dot --]] [38747] = { twoHanded = true, st = true, dot = true,},
--[[ brawler --]] [38754] = { twoHanded = true, aoe = true, direct = true,},
--[[ reverse slice --]] [38823] = { twoHanded = true, aoe = true, direct = true,},
--[[ executioner --]] [38819] = { twoHanded = true, st = true, direct = true,},
--[[ ----------------------------destruction staff----------------------------]]
--[[ elemental rage - fire --]] [85127] = { destroStaff = true, aoe = true, dot = true,},
--[[ crushing shock fire --]] [46348] = { destroStaff = true, st = true, direct = true,},
--[[ crushing shock frost --]] [46350] = { destroStaff = true, st = true, direct = true,},
--[[ crushing shock shock --]] [46351] = { destroStaff = true, st = true, direct = true,},
--[[ force pulse fire --]] [46356] = { destroStaff = true, st = true, direct = true,},
--[[ force pulse frost --]] [46357] = { destroStaff = true, st = true, direct = true,},
--[[ force pulse shock --]] [46358] = { destroStaff = true, st = true, direct = true,},
--[[ force pulse magic (cleave) --]] [48016] = { destroStaff = true, st = true, direct = true,},
--[[ elemental blockade fire --]] [62912] = { destroStaff = true, aoe = true, dot = true,},
--[[ unstable wall dot - fire --]] [39054] = { destroStaff = true, aoe = true, dot = true, special = true,},
--[[ unstable wall explosion - fire --]] [39056] = { destroStaff = true, aoe = true, direct = true,},
--[[ destructive reach dot - fire --]] [62682] = { destroStaff = true, st = true, dot = true,},
--[[ destructive reach hit - fire --]] [38944] = { destroStaff = true, st = true, direct = true,},
--[[ pulsar fire --]] [170989] = { destroStaff = true, aoe = true, direct = true,},
--[[ pulsar fire afterburn --]] [146585] = { destroStaff = true, st = true, direct = true, special = true,},
--[[ elemental ring - fire --]] [39149] = { destroStaff = true, aoe = true, direct = true,},
--[[ elemental ring - fire afterburn --]] [146586] = { destroStaff = true, st = true, direct = true,},
--[[ elemental rage - shock --]] [85131] = { destroStaff = true, aoe = true, dot = true,},
--[[ elemental blockade - shock --]] [62990] = { destroStaff = true, aoe = true, dot = true,},
--[[ unstable wall dot - shock --]] [39079] = { destroStaff = true, aoe = true, dot = true,},
--[[ unstable wall explosion - shock --]] [39080] = { destroStaff = true, aoe = true, direct = true,},
--[[ destructive reach dot - shock --]] [62745] = { destroStaff = true, st = true, dot = true,},
--[[ destructive reach hit - shock --]] [38978] = { destroStaff = true, st = true, direct = true,},
--[[ tri focus (shock heavy aoe) hit --]] [45505] = { destroStaff = true, st = true, direct = true,},
--[[ shock pulsar 1 enemy --]] [146593] = { destroStaff = true, aoe = true, direct = true, special = true,},
--[[ elemental ring - shock 1 enemy --]] [39153] = { destroStaff = true, aoe = true, direct = true, special = true,},
--[[ ----------------------------undaunted----------------------------]]
--[[ mystic orb --]] [42029] = { undaunted = true, aoe = true, dot = true,},
--[[ shadow silk cast --]] [126720] = { undaunted = true, aoe = true, direct = true,},
--[[ shadow silk proc (after 10s) --]] [80107] = { undaunted = true, aoe = true, direct = true,},
--[[ --------------------------------------------------------]]
--[[ ----------------------------mages guild----------------------------]]
--[[ degeneration --]] [126374] = { magesGuild = true, st = true, dot = true,},
--[[ structured entropy --]] [126371] = { magesGuild = true, st = true, dot = true,},
--[[ scalding rune dot --]] [40468] = { magesGuild = true, st = true, dot = true,},
--[[ scalding rune proc --]] [40469] = { magesGuild = true, aoe = true, direct = true,},
--[[ shooting star dot --]] [63471] = { magesGuild = true, aoe = true, dot = true,},
--[[ shooting star proc --]] [63474] = { magesGuild = true, aoe = true, direct = true,},
--[[ ----------------------------psijic guild----------------------------]]
--[[ ----------------------------fighters guild----------------------------]]
--[[ flawless dawnbringer hit --]] [40161] = { fightersGuild = true, aoe = true, direct = true,},
--[[ flawless dawnbringer dot --]] [62310] = { fightersGuild = true, st = true, dot = true,},
--[[ silver shards --]] [40300] = { fightersGuild = true, aoe = true, direct = true,},
--[[ barbed trap dot --]] [40385] = { fightersGuild = true, st = true, dot = true,},
--[[ barbed trap proc --]] [40389] = { fightersGuild = true, st = true, direct = true,},
--[[ ----------------------------alliance war----------------------------]]
--[[ anti cavalry caltrops --]] [40267] = { allianceWar = true, aoe = true, dot = true,},
--[[ proximity detonation  --]] [61502] = { allianceWar = true, aoe = true, direct = true,},
--[[ ----------------------------status effects----------------------------]]
--[[ Sundered --]] [148800] = { statusEffect = true, st = true, direct = true,},
--[[ Burning --]] [18084] = { statusEffect = true, st = true, dot = true,},
--[[ Poisioned --]] [21929] = { statusEffect = true, st = true, dot = true,},
--[[ Hemorrhaging --]] [148801] = { statusEffect = true, st = true, dot = true,},
--[[ Chilled --]] [21481] = { statusEffect = true,},
--[[ overcharged --]] [148797] = { statusEffect = true, st = true, direct = true,},
--[[ Concussion --]] [21487] = { statusEffect = true, st = true, direct = true,},
--[[ ----------------------------synergies----------------------------]]
--[[ mystic orb - combustion --]] [85432] = { synergy = true, aoe = true, direct = true,},
--[[ fulminating rune - runebreak --]] [191078] = { synergy = true, aoe = true, direct = true,},
--[[ trapping webs - spawn broodling --]] [39429] = { synergy = true, st = true, direct = true,},
--[[ trapping webs - bite --]] [77245] = { synergy = true, st = true, direct = true,},
--[[ ----------------------------enchant----------------------------]]
--[[ Fiery Weapon --]] [17895] = { enchant = true, st = true, direct = true,},
--[[ Poisoned Weapon --]] [17902] = { st = true, direct = true,},
--[[ ----------------------------light attack----------------------------]]
--[[ unarmed light --]] [23064] = { none = true, st = true, direct = true, basicAttack = true,},
--[[ unarmed medium --]] [18430] = { none = true, st = true, direct = true, basicAttack = true,},
--[[ unarmed heavy --]] [18431] = { none = true, st = true, direct = true, basicAttack = true,},
--[[ dual wield light --]] [16499] = { dualWield = true, st = true, direct = true, basicAttack = true,},
--[[ dual wield medium --]] [17170] = { dualWield = true, st = true, direct = true, basicAttack = true,},
--[[ dual wield heavy --]] [17169] = { dualWield = true, st = true, direct = true, basicAttack = true,},
--[[ dual wield heavy 2 --]] [18622] = { dualWield = true, st = true, direct = true, basicAttack = true,},
--[[ inferno staff light --]] [16165] = { destroStaff = true, st = true, direct = true, basicAttack = true,},
--[[ inferno staff medium --]] [15385] = { destroStaff = true, st = true, direct = true, basicAttack = true,},
--[[ inferno staff heavy --]] [16321] = { destroStaff = true, st = true, direct = true, basicAttack = true,},
--[[ shock staff light attack --]] [18350] = { destroStaff = true, st = true, direct = true, basicAttack = true,},
--[[ shock staff heavy attack channel --]] [18396] = { destroStaff = true, st = true, dot = true, basicAttack = true,},
--[[ shock staff heavy attack hit --]] [19277] = { destroStaff = true, st = true, direct = true, basicAttack = true,},
--[[ ice staff light --]] [16277] = { destroStaff = true, st = true, direct = true, basicAttack = true,},
--[[ ice staff medium --]] [18405] = { destroStaff = true, st = true, direct = true, basicAttack = true,},
--[[ ice staff heavy --]] [18406] = { destroStaff = true, st = true, direct = true, basicAttack = true,},
--[[ 2h light --]] [16037] = { twoHanded = true, st = true, direct = true, basicAttack = true,},
--[[ 2h medium --]] [17162] = { twoHanded = true, st = true, direct = true, basicAttack = true,},
--[[ 2h heavy --]] [17163] = { twoHanded = true, st = true, direct = true, basicAttack = true,},
--[[ 2h forceful passive --]] [45445] = { twoHanded = true, st = true, direct = true, basicAttack = true,},
--[[ bow light --]] [16688] = { bow = true, st = true, direct = true, basicAttack = true,},
--[[ bow medium --]] [17174] = { bow = true, st = true, direct = true, basicAttack = true,},
--[[ bow heavy --]] [17173] = { bow = true, st = true, direct = true, basicAttack = true,},
--[[ resto light --]] [16145] = { restoStaff = true, st = true, direct = true, basicAttack = true,},
--[[ resto heavy channel --]] [16212] = { restoStaff = true, st = true, dot = true, basicAttack = true,},
--[[ resto heavy hit --]] [67022] = { restoStaff = true, st = true, direct = true, basicAttack = true,},
--[[ one handed light --]] [15435] = { oneHanded = true, st = true, direct = true, basicAttack = true,},
--[[ one handed medium --]] [15282] = { oneHanded = true, st = true, direct = true, basicAttack = true,},
--[[ one handed heavy --]] [15829] = { oneHanded = true, st = true, direct = true, basicAttack = true,},
--[[ ----------------------------scribing-----------------------------]]
--[[ elemental explosion - fire/frost/magic/shock --]] [217231] = { scribing = true, aoe = true, direct = true,},
--[[ elemental explosion lingering torment - fire/frost/magic/shock --]] [217241] = { scribing = true, st = true, dot = true,},
--[[ elemental explosion - phys --]] [229600] = { scribing = true, aoe = true, direct = true,},
--[[ elemental explosion lingering torment - phys --]] [229602] = { scribing = true, st = true, dot = true,},
--[[ shield throw - frost/magic --]] [217808] = { scribing = true, st = true, direct = true,},
--[[ shield throw lingering torment - frost/magic --]] [219818] = { scribing = true, st = true, dot = true,},
--[[ shield throw - phys --]] [216973] = { scribing = true, st = true, direct = true,},
--[[ shield throw lingering torment - phys/multi target --]] [217095] = { scribing = true, st = true, dot = true,},
--[[ shield throw - multi target --]] [217061] = { scribing = true, st = true, direct = true,},
--[[ shield throw bounce 1- multi target --]] [217071] = { scribing = true, st = true, direct = true,},
--[[ shield throw bounce 2 - multi target --]] [217072] = { scribing = true, st = true, direct = true,},
--[[ smash - bleed/phys/poi --]] [217178] = { scribing = true, aoe = true, direct = true,},
--[[ smash lingering torment - bleed/phys/poi --]] [217188] = { scribing = true, st = true, dot = true,},
--[[ smash - magic --]] [217179] = { scribing = true, aoe = true, direct = true,},
--[[ smash lingering torment - magic --]] [219973] = { scribing = true, st = true, dot = true,},
--[[ travelling knife first hit - bleed/phys/poi --]] [217872] = { scribing = true, st = true, direct = true,},
--[[ travelling knife return hit - bleed/phys/poi --]] [217359] = { scribing = true, aoe = true, direct = true,},
--[[ travelling knife lingering torment - bleed/phys/poi/multi target --]] [219720] = { scribing = true, st = true, dot = true,},
--[[ travelling knife first hit - frost/magic --]] [217473] = { scribing = true, st = true, direct = true,},
--[[ travelling knife return hit - frost/magic --]] [219705] = { scribing = true, aoe = true, direct = true,},
--[[ travelling knife lingering torment - frost/magic --]] [219719] = { scribing = true, st = true, dot = true,},
--[[ travelling knife first hit - multi target --]] [217340] = { scribing = true, st = true, direct = true,},
--[[ travelling knife aoe hit - multi target --]] [217348] = { scribing = true, aoe = true, direct = true,},
--[[ vault - bleed/disease/phys/poi --]] [214960] = { scribing = true, aoe = true, direct = true,},
--[[ vault lingering torment - bleed/disease/phys/poi --]] [214982] = { scribing = true, st = true, dot = true,},
--[[ vault - fire --]] [214978] = { scribing = true, aoe = true, direct = true,},
--[[ vault lingering torment - fire --]] [217776] = { scribing = true, st = true, dot = true,},
--[[ soul burst - bleed/disease/phys --]] [217465] = { scribing = true, aoe = true, direct = true,},
--[[ soul burst lingering torment - bleed/disease/phys --]] [217461] = { scribing = true, st = true, dot = true,},
--[[ soul burst - fire/frost/magic/shock --]] [217459] = { scribing = true, aoe = true, direct = true,},
--[[ soul burst lingering torment --]] [217471] = { scribing = true, st = true, dot = true,},
--[[ wield soul - bleed/disease/phys --]] [219780] = { scribing = true, st = true, direct = true,},
--[[ wield soul lingering torment --]] [219781] = { scribing = true, st = true, dot = true,},
--[[ wield soul - fire/frost/magic/shock --]] [215731] = { scribing = true, st = true, direct = true,},
--[[ wield soul lingering torment --]] [216833] = { scribing = true, st = true, dot = true,},
--[[ torchbearer - bleed/phys --]] [217631] = { scribing = true, aoe = true, direct = true,},
--[[ torchbearer lingering torment - bleed/phys --]] [217638] = { scribing = true, st = true, dot = true,},
--[[ torchbearer - fire/frost --]] [217632] = { scribing = true, aoe = true, direct = true,},
--[[ torchbearer lingering torment - fire/frost --]] [219873] = { scribing = true, st = true, dot = true,},
--[[ ulfsild continegency - bleed --]] [229656] = { scribing = true, aoe = true, direct = true,},
--[[ ulfsild continegency lingering torment - bleed --]] [229658] = { scribing = true, st = true, dot = true,},
--[[ ulfsild continegency - flame/frost/magic/shock --]] [217605] = { scribing = true, aoe = true, direct = true,},
--[[ ulfsild continegency lingering torment - flame/frost/magic/shock --]] [217621] = { scribing = true, st = true, dot = true,},
--[[ trample - disease/phys --]] [217679] = { scribing = true, aoe = true, direct = true,},
--[[ trample lingering torment - disease/phys --]] [217688] = { scribing = true, st = true, dot = true,},
--[[ trample - frost/magic --]] [217682] = { scribing = true, aoe = true, direct = true,},
--[[ trample lingering torment - frost/magic --]] [220739] = { scribing = true, st = true, dot = true,},
--[[ ----------------------------proc sets----------------------------]]
--[[ azureblight: blight seed 1 enemy --]] [126633] = { procSet = true, st = true, direct = true,},
--[[ stormfist dot --]] [80522] = { procSet = true, aoe = true, dot = true,},
--[[ stormfist hit --]] [80521] = { procSet = true, aoe = true, direct = true,},
--[[ pillar of nirn hit --]] [97716] = { procSet = true, aoe = true, direct = true,},
--[[ pillar of nirn dot --]] [97743] = { procSet = true, st = true, dot = true,},
--[[ whorl of depths target dot --]] [172671] = { procSet = true, st = true, dot = true,},
--[[ whorl of depths aoe dot --]] [172672] = { procSet = true, aoe = true, dot = true,},
--[[ relequen (harmful winds) --]] [107203] = { procSet = true, st = true, dot = true,},
    },


    procsets = 
    {
--[[ stormfist dot --]] [80522] = true,
--[[ stormfist hit --]] [80521] = true,
--[[ azureblight --]] [126633] = true,
--[[ pillar hit --]] [97716] = true,
--[[ pillar dot --]] [97743] = true,
--[[ whorl of depths target dot --]] [172671] = true,

--[[ whorl of depths aoe dot --]] [172672] = true,
--[[ relequen (harmful winds) --]] [107203] = true,
    },
    
    
    otherProcsetCoefs = 
    {
        ma2h = {c1 = 0.09292055218962, c2 = -0.00775893653678, },
    },



    sets =
    {
        deadly =
        {
            iln = "|H1:item:87874:364:50:26848:370:50:26:0:0:0:0:0:0:0:2049:25:0:1:0:60:0|h|h",
            n = 5,
        },
        ansuul =
        {
            iln = "|H0:item:196367:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:142:0:0:0:10000:0|h|h",
            ilp = "|H1:item:197236:363:50:0:0:0:0:0:0:0:0:0:0:0:1:142:0:1:0:10000:0|h|h",
            n = 5,
        },
        coral =
        {
            iln = "|H0:item:186562:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:130:0:0:0:10000:0|h|h",
            ilp = "|H1:item:187755:364:50:45883:370:50:31:0:0:0:0:0:0:0:2049:130:0:1:0:0:0|h|h",
            n = 5,
        },
        velothi =
        {
            iln = "|H1:item:194512:364:50:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h",
            mythic = true,
            n = 1,
        },
        kilt =
        {
            iln = "|H1:item:175524:364:50:26588:370:50:0:0:0:0:0:0:0:0:1:10:0:1:0:3333:0|h|h",
            mythic = true,
            n = 1,
        },
        mastersBow =
        {
            iln = "|H1:item:166060:364:50:54484:370:50:4:0:0:0:0:0:0:0:2049:8:0:1:0:432:0|h|h",
            arena = true,
            n = 2,
        },
        maCrushingWall =
        {
            iln = "|H1:item:166198:364:50:54484:370:50:4:0:0:0:0:0:0:0:2049:14:0:1:0:323:0|h|h",
            arena = true,
            n = 2,
        },
        ma2h =
        {
            iln = "|H1:item:166196:364:50:54484:370:50:4:0:0:0:0:0:0:0:2049:14:0:1:0:303:0|h|h",
            arena = true,
            n = 2,
        },



    },

    -- /script local s = "" for i=1,GetNumSkillLines(SKILL_TYPE_CLASS) do local name,_,_,id = GetSkillLineInfo(SKILL_TYPE_CLASS, i); s = s.. string.format("%d --%s\n", id, name) end d(s)
    skillLineIds = {
        --SKILL_TYPE_CLASS
        arcanist = {
            herald = 218, --Herald of the Tome
            soldier = 219, --Soldier of Apocrypha
            curative = 220, --Curative Runeforms
        },
        templar = {
            aedric = 22, --Aedric Spear
            dawns = 27, --Dawn's Wrath
            restoring = 28, --Restoring Light
        },
        dk = {
            ardent = 35, --Ardent Flame
            draconic = 36, --Draconic Power
            earthen = 37, --Earthen Heart
        },
        nb = {
            assasination = 38, --Assassination
            shadow = 39, --Shadow
            siphon = 40, --Siphoning
        },
        sorc = {
            dark = 41, --Dark Magic
            daedric = 42, --Daedric Summoning
            storm = 43, --Storm Calling
        },
        warden = {
            animal = 127, --Animal Companions
            green = 128, --Green Balance
            winter = 129, --Winter's Embrace
        },
        necro = {
            graveLord = 131, --Grave Lord
            bone = 132, --Bone Tyrant
            living = 133, --Living Death
        },
        --SKILL_TYPE_GUILD
        fightersGuild = 45,
        magesGuild = 44,
        psijicGuild = 130,
        undaunted = 55,

        --SKILL_TYPE_ARMOR
        -- 24 --Light Armor
        -- 25 --Medium Armor
        -- 26 --Heavy Armor

        --SKILL_TYPE_WEAPON
        twoHanded = 30, --Two Handed
        -- 29 --One Hand and Shield
        dualWield = 31, --Dual Wield
        bow = 32, --Bow
        destroStaff = 33, --Destruction Staff
        -- 34 --Restoration Staff

        --SKILL_TYPE_WORLD
        -- 157 --Excavation
        -- 111 --Legerdemain
        -- 155 --Scrying
        -- 72 --Soul Magic
        -- 51 --Vampire
        -- 50 --Werewolf

        --SKILL_TYPE_RACIAL
        -- 64 --Dark Elf Skills
        -- 52 --Orc Skills
        -- 56 --High Elf Skills
        -- 57 --Wood Elf Skills
        -- 58 --Khajiit Skills
        -- 59 --Imperial Skills
        -- 60 --Breton Skills
        -- 62 --Redguard Skills
        -- 63 --Argonian Skills
        -- 65 --Nord Skills
    },

    -- passives which provide any dps boost we care about
    -- abilityid -> key for the skill in the player data which will map to the skill's level
    -- /script local s = "" local st, sli = GetSkillLineIndicesFromSkillLineId(218); for i=1,GetNumSkillAbilities(st, sli) do local name = GetSkillAbilityInfo(st, sli, i); local id = GetSkillAbilityId(st, sli, i);  s = s.. string.format("%d --%s\n", id, name) end d(s)
    interestingPassives = {
        --arcanist
        [184873] = "psychicLesion",     --Psychic Lesion, 7/15% dmg done with status effects
        --templar
        [31565] = "balancedWarrior",    --Balanced Warrior, 3/6% weapon and spell damage
        --dk
        [29424] = "combustion",         --Combustion, 16/33% dmg done with burning and poison status effect
        [29430] = "wramth",             --Warmth, 3/6% more dot dmg for 3s after dealing direct dmg with ardent flame ability TODO
        [29451] = "worldInRuin",        --World in Ruin  2/5% dmg done with flame and poison
        --nb
        --sorc
        [31421] = "energized",          --Energized 3/5% physical/shock dmg done
        [31422] = "amplitude",          --Amplitude 1% dmg done for every 20/10% current hp the target has

        --warden
        --necro
        [116199] = "rapidRot",          --Rapid Rot 5/10% dmg done with dots

        -- two handed
        [29389] = "followUp",           --Follow Up 5/10% with two handed attacks if the buff is active (after heavy attack for 4s)

        --dual wield
        [45476] = "slaughter", --Slaughter, 10/20% dmg done with dual wield abilities to targets under 25%
        [45481] = "ruffian", --Ruffian, 15% dmg done to stunned, immobilized, silenced enemies while dual wielding
        --bow
        [45494] = "vinedusk", --Vinedusk Training, 2/5% dmg done to enemies 15m or closer
        [45497] = "hawkeye", --Hawk Eye, 2/5% to bow abilities stacking up 5 times (while the buff is active)
        --destro
        [45513] = "ancientKnowledge", --Ancient Knowledge 6/12% to dot. status with infero; direct, channeled with lightning staff

        --fightersGuild
        [45596] = "slayer", --Slayer, 3 level, 1/2/3% weapond and spell dmg for each fighters guild ability
        [40393] = "skilledTracker", --Skilled Tracker, 1 level, 10% dmg done with fighters guild abilities

    }

}



function CombatInsightsConsts.Init()
    local morphIndices =
    {
        MORPH_SLOT_BASE,
        MORPH_SLOT_MORPH_1,
        MORPH_SLOT_MORPH_2,
    }


-- SKILL_TYPE_ARMOR
-- SKILL_TYPE_AVA
-- SKILL_TYPE_CHAMPION
-- SKILL_TYPE_CLASS
-- SKILL_TYPE_GUILD
-- SKILL_TYPE_RACIAL
-- SKILL_TYPE_TRADESKILL
-- SKILL_TYPE_WEAPON
-- SKILL_TYPE_WORLD
-- GetNumSkillTypes()
-- GetNumSkillLines(number SkillType skillType)
-- GetSkillAbilityInfo(number SkillType skillType, number skillLineIndex, number skillIndex)
-- GetSpecificSkillAbilityInfo(number SkillType skillType, number skillLineIndex, number skillIndex, number morphChoice, number rank)
-- GetSkillLineId(number SkillType skillType, number skillLineIndex)
-- GetSkillLineNameById(number skillLineId)
-- GetNumSkillAbilities(number SkillType skillType, number skillLineIndex)
-- GetSkillAbilityInfo(number SkillType skillType, number skillLineIndex, number skillIndex)
-- Returns: string name, textureName texture, number earnedRank, boolean passive, boolean ultimate, boolean purchased, number:nilable progressionIndex, number rank


    --these lookup tables are used to determine wether an ability is part of a skill line or not (for passives which require abilities to be slotted)

    CombatInsightsConsts.fightersGuildAbilities = {}
    local skillType, skillLineIndex = GetSkillLineIndicesFromSkillLineId(CombatInsightsConsts.skillLineIds.fightersGuild)
    for i=1,GetNumSkillAbilities(skillType, skillLineIndex) do
        local _, _, _, passive = GetSkillAbilityInfo(skillType, skillLineIndex, i)
        if not passive then
            for _,m in ipairs(morphIndices) do
                local abilityId = GetSpecificSkillAbilityInfo(skillType, skillLineIndex, i, m, 1)
                CombatInsightsConsts.fightersGuildAbilities[abilityId] = true
            end
        end
    end


    CombatInsightsConsts.nbSiphoningAbilities = {}
    skillType, skillLineIndex = GetSkillLineIndicesFromSkillLineId(CombatInsightsConsts.skillLineIds.nb.siphoning)
    for i=1,GetNumSkillAbilities(skillType, skillLineIndex) do
        local _, _, _, passive = GetSkillAbilityInfo(skillType, skillLineIndex, i)
        if not passive then
            for _,m in ipairs(morphIndices) do
                local abilityId = GetSpecificSkillAbilityInfo(skillType, skillLineIndex, i, m, 1)
                CombatInsightsConsts.nbSiphoningAbilities[abilityId] = true
            end
        end
    end

    CombatInsightsConsts.necroSiphon = {}
    skillType, skillLineIndex = GetSkillLineIndicesFromSkillLineId(CombatInsightsConsts.skillLineIds.necro.graveLord)
    for _,m in ipairs(morphIndices) do
        local abilityId = GetSpecificSkillAbilityInfo(skillType, skillLineIndex, 6, m, 1)
        CombatInsightsConsts.necroSiphon[abilityId] = true
    end

    CombatInsightsConsts.sorcSkills = {}
    for _,v in pairs(CombatInsightsConsts.skillLineIds.sorc) do
        skillType, skillLineIndex = GetSkillLineIndicesFromSkillLineId(v)
        for i=1,GetNumSkillAbilities(skillType, skillLineIndex) do
            local _, _, _, passive = GetSkillAbilityInfo(skillType, skillLineIndex, i)
            if not passive then
                for _,m in ipairs(morphIndices) do
                    local abilityId = GetSpecificSkillAbilityInfo(skillType, skillLineIndex, i, m, 1)
                    CombatInsightsConsts.sorcSkills[abilityId] = true
                end
            end
        end
    end

    --grab the icons for the sets
    for _,d in pairs(CombatInsightsConsts.sets) do
        d.icon = GetItemLinkIcon(d.iln)
    end

    --flatten the interesting skill line ids
    CombatInsightsConsts.interestingSkillLineIds = {}
    for _,v in pairs(CombatInsightsConsts.skillLineIds) do
        if type(v) == "table" then
            for _,v2 in pairs(v) do
                table.insert(CombatInsightsConsts.interestingSkillLineIds, v2)
            end
        else
            table.insert(CombatInsightsConsts.interestingSkillLineIds, v)
        end
    end
end


