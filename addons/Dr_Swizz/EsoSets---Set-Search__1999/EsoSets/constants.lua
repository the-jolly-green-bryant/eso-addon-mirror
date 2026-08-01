function Esosets.InitConstants()
    -- Universal variable so i dont fuck spelling up

    Esosets.ANY = "Any"

    Esosets.SPELL_DAMAGE ="Spell Damage";
    Esosets.MAX_MAGIC ="Max Magicka";
    Esosets.MAGIC_REGEN ="Magicka Recovery";
    Esosets.SPELL_CRIT ="Spell Critical";
    Esosets.SPELL_PEN ="Spell Penetration";
    Esosets.REDUCE_MAGIC_COST= "Reduce Magic Cost";

    Esosets.MAX_STAMINA= "Max Stamina";
    Esosets.STAMINA_REGEN ="Stamina Recovery";
    Esosets.WEAPON_CRIT = "Weapon Critical";
    Esosets.WEAPON_DAMAGE = "Weapon Damage";

    Esosets.MAX_HEALTH ="Max Health";
    Esosets.HEALTH_REGEN ="Health Recovery";
    Esosets.HEALING_TAKEN = "Healing Taken";



    Esosets.PHYSICAL_RESISTANCE = "Physical Resistance";
    Esosets.PHYSICAL_DAMAGE = "Physical Damage";

    Esosets.CRIT_RESIST ="Critical Resistance";

    Esosets.REDUCE_AOE = "Reduced AOE Damage";

    Esosets.DAMAGE_SHIELD ="Damage Shield";
    Esosets.ULTIMATE = "Ultimate";
    Esosets.POISON_DAMAGE ="Poison Damage";
    Esosets.STUN ="Stun Enemy";

    Esosets.REDUCE_ENCHANT_COOLDOWN ="Reduce Enchant Cooldown";
    Esosets.FLAME_DAMAGE = "Flame Damage";
    Esosets.SPELL_RESISTANCE = "Spell Resistance";
    Esosets.ELEMENTAL_RESISTANCE = "Elemental Resistance";

    Esosets.HEAL ="Healing";
    Esosets.BLEED ="Bleed";

    Esosets.REDUCE_WEAPON_DAMAGE ="Reduce Enemy Weapon Damage";
    Esosets.REDUCE_PHYSICAL_RESISTANCE ="Reduce Enemy Physical Resistance";
    Esosets.BREAK_FREE="Break Free";
    Esosets.MUNDUS = "Mundus Stone";
    Esosets.DODGE="Dodge";
    Esosets.REDUCE_DAMAGE ="Reduce Damage";
    Esosets.RESURRECTION ="Resurrection";
    Esosets.REDUCE_NEGATIVE_EFFECTS ="Reduce Negative Effects";
    Esosets.REDUCE_COST ="Reduce Cost";
    Esosets.REDUCE_STAM_COST ="Reduce Stamina Cost";


    Esosets.PHYSICAL_PEN ="Physical Penetration";

    Esosets.FROST_DAMAGE ="Frost Damage";
    Esosets.SHOCK_DAMAGE = "Shock Damage";
    Esosets.OBLIVION_DAMAGE ="Oblivion Damage";
    Esosets.MAGIC_DAMAGE ="Magic Damage";
    Esosets.DISEASE_DAMAGE ="Disease Damage";
    Esosets.BOW ="Bow";


    Esosets.HEAVY_ATTACKS ="Heavy Attacks";
    Esosets.TAUNT ="Taunt";




    --buffs
    Esosets.SLAYER ="Slayer";
    Esosets.AEGIS = "Aegis";
    Esosets.BRUTALITY ="Brutality";
    Esosets.EVASION = "Evasion";
    Esosets.EXPEDITION ="Expedition";
    Esosets.PROPHECY="Prophecy";
    Esosets.BERSERK ="Berserk";
    Esosets.TOUGHNESS ="Toughness";
    Esosets.MENDING ="Mending";
    Esosets.PROTECTION ="Protection";
    Esosets.HEROISM ="Heroism";
    Esosets.VITALITY ="Vitality";
    Esosets.MAIM ="Maim";
    Esosets.DEFILE ="Defile";
    Esosets.VULNERABILITY ="Vulnerability";
    Esosets.FRACTURE ="Fracture";
    Esosets.FORCE = "Force";
    Esosets.WARD ="Ward";
    Esosets.RESOLVE = "Resolve";
    Esosets.SORCERY= "Sorcery";
    Esosets.SAVAGERY = "Savagery";
    Esosets.COURAGE = "Courage"




    --An array of all the set bonuses
    Esosets.ALL_BONUSES ={Esosets.ANY,Esosets.SPELL_CRIT, Esosets.MAX_MAGIC,Esosets.SPELL_DAMAGE, Esosets.MAGIC_REGEN, Esosets.MAX_STAMINA,
        Esosets.STAMINA_REGEN, Esosets.WEAPON_CRIT, Esosets.WEAPON_DAMAGE, Esosets.MAX_HEALTH, Esosets.HEALTH_REGEN, Esosets.HEALING_TAKEN,
        Esosets.PHYSICAL_DAMAGE,Esosets.PHYSICAL_RESISTANCE,Esosets.CRIT_RESIST,Esosets.SLAYER,
        Esosets.AEGIS,Esosets.REDUCE_AOE,Esosets.DAMAGE_SHIELD, Esosets.ULTIMATE,Esosets.POISON_DAMAGE, Esosets.STUN,
        Esosets.REDUCE_ENCHANT_COOLDOWN,Esosets.SPELL_RESISTANCE, Esosets.ELEMENTAL_RESISTANCE, Esosets.REDUCE_MAGIC_COST,
        Esosets.EVASION,Esosets.HEAL,Esosets.REDUCE_WEAPON_DAMAGE,Esosets.BREAK_FREE,Esosets.REDUCE_PHYSICAL_RESISTANCE,
        Esosets.MUNDUS,Esosets.DODGE, Esosets.REDUCE_DAMAGE, Esosets.RESURRECTION, Esosets.REDUCE_NEGATIVE_EFFECTS,Esosets.REDUCE_COST,
        Esosets.REDUCE_STAM_COST,Esosets.BRUTALITY,Esosets.EXPEDITION,Esosets.SPELL_PEN, Esosets.PROPHECY,Esosets.PHYSICAL_PEN,
        Esosets.FLAME_DAMAGE,Esosets.FROST_DAMAGE,Esosets.SHOCK_DAMAGE,Esosets.BERSERK,Esosets.TOUGHNESS,Esosets.OBLIVION_DAMAGE,Esosets.HEAVY_ATTACKS,
        Esosets.TAUNT,Esosets.MAIM, Esosets.MAGIC_DAMAGE,Esosets.DEFILE,Esosets.BLEED, Esosets.DISEASE_DAMAGE,Esosets.VITALITY,
        Esosets.PROTECTION,Esosets.BOW,Esosets.VULNERABILITY,Esosets.FRACTURE,Esosets.MENDING,Esosets.FORCE,Esosets.WARD,Esosets.RESOLVE,Esosets.SORCERY,
        Esosets.SAVAGERY, Esosets.COURAGE


    };



    Esosets.LIGHT = "Light";
    Esosets.MEDIUM = "Medium";
    Esosets.HEAVY = "Heavy";

    Esosets.ALL_WEIGHTS ={Esosets.ANY,Esosets.LIGHT,Esosets.MEDIUM,Esosets.HEAVY};



    --SET DROP TYPES
    Esosets.CRAFTED_SET ="Crafted Set";
    Esosets.DUNGEON_SET ="Dungeon Drop";
    Esosets.TELVAR_SET ="Tel Var Set";
    Esosets.MONSTER_SET ="Monster Set";
    Esosets.ACCESSORY_SET = "Accessory Set";
    Esosets.OVERLAND_SET ="Overland Set";
    Esosets.CYRODIIL_SET ="Cyrodiil Rewards / Vendor";
    Esosets.BATTLE_GROUNDS_SET ="Battlegrounds Set";
    Esosets.TRIAL_SET ="Trial Set";

    --this is used to filter by the type of set
    Esosets.ALL_SETS_BY_TYPE={Esosets.ANY, Esosets.MONSTER_SET,Esosets.CRAFTED_SET,Esosets.TEL_VAR_SET,Esosets.DUNGEON_SET,Esosets. ACCESSORY_SET,
        Esosets.TRIAL_SET,Esosets.BATTLE_GROUNDS_SET,Esosets.CYRODIIL_SET,Esosets.OVERLAND_SET};


    -- UPDATES
    Esosets.BASE="Base Game";
    Esosets.IMPERIAL_CITY = "Imperial City";
    Esosets.ORSINIUM = "Orsinium";
    Esosets.THIEVES_GUILD = "Thieves Guild";
    Esosets.DARK_BROTHERHOOD ="Dark Brotherhood";
    Esosets.ONE_TAMRIEL ="One Tamriel";
    Esosets.SHADOWS_OF_THE_HIST ="Shadows of the Hist";
    Esosets.MORROWIND = "Morrowind";
    Esosets.HORNS_OF_THE_REACH="Horns of the Reach";
    Esosets.CLOCKWORK_CITY ="Clockwork City";
    Esosets.DRAGON_BONES = "Dragon Bones";
    Esosets.SUMMERSET = "Summerset";
    Esosets.WOLFHUNTER = "Wolfhunter";
    Esosets.MURKMIRE ="Murkmire";
    Esosets.WRATHSTONE = "Wrathstone";
    Esosets.ELSWEYR = "Elsweyr";
    Esosets.SCALEBREAKER = "Scalebreaker";
    Esosets.DRAGONHOLD = "Dragon Hold";

    --this will be used to search by updates*/
    Esosets.ALL_DLC ={Esosets.ANY, Esosets.BASE,Esosets.IMPERIAL_CITY,Esosets.ORSINIUM,Esosets.THIEVES_GUILD,Esosets.DARK_BROTHERHOOD,Esosets.SHADOWS_OF_THE_HIST,Esosets.ONE_TAMRIEL,
        Esosets.MORROWIND,Esosets.HORNS_OF_THE_REACH,Esosets.CLOCKWORK_CITY,Esosets.DRAGON_BONES, Esosets.SUMMERSET, Esosets.WOLFHUNTER, Esosets.MURKMIRE, Esosets.WRATHSTONE,
        Esosets.ELSWEYR, Esosets.SCALEBREAKER,Esosets.DRAGONHOLD

    };




    -- DUNGEONS

    Esosets.RUINS_OF_MAZZ = "Ruins of Mazzatun";
    Esosets.CRADLE_OF_SHADOWS = "Cradle of Shadows";
    Esosets.SPINDLE_CLUTCH_I ="Spindle Clutch I";
    Esosets.SPINDLE_CLUTCH_II = "Spindle Clutch II";
    Esosets.WHITE_GOLD_TOWER ="White Gold Tower";
    Esosets.CITY_OF_ASH_I ="City of Ash I";
    Esosets.CITY_OF_ASH_II ="City of Ash II";
    Esosets.WAYREST_SEWERS_I ="Wayrest Sewers I";
    Esosets.WAYREST_SEWERS_II ="Wayrest Sewers II";
    Esosets.FUNGAL_GROTTO_I ="Fungal Grotto I";
    Esosets.FUNGAL_GROTTO_II ="Fungal Grotto II";
    Esosets.DARKSHADE_CAVERNS_I ="Darkshade Caverns I";
    Esosets.DARKSHADE_CAVERNS_II ="Darkshade Caverns II";
    Esosets.ARX ="Arx Corinium";
    Esosets.ELDEN_HOLLOW_I= "Elden Hollow I";
    Esosets.ELDEN_HOLLOW_II = "Elden Hollow II";
    Esosets.IMPERIAL_CITY_PRISON ="Imperial City Prison";
    Esosets.DIREFROST_KEEP ="Direfrost Keep";
    Esosets.BANISHED_CELLS_I ="Banished Cells I";
    Esosets.BANISHED_CELLS_II = "Banished Cells II";
    Esosets.CRYPT_OF_HEARTS_I ="Crypt of Hearts I";
    Esosets.CRYPT_OF_HEARTS_II ="Crypt of Hearts II";
    Esosets.BLESSED_CRUCIBLE ="Blessed Crucible";
    Esosets.TEMPEST_ISLAND ="Tempest Island";
    Esosets.VOLENFELL ="Volenfell";
    Esosets.SELENES_WEB ="Selene's Web";
    Esosets.VAULTS_OF_MADNESS ="Vault's of Madness";
    Esosets.BLACKHEART_HAVEN ="Blackheart Haven";
    Esosets.FALKREATH_HOLD ="Falkreath Hold";
    Esosets.BLOODROOT_FORGE ="Bloodroot Forge";
    Esosets.FANG_LAIR = "Fang Lair";
    Esosets.SCALECALLER_PEAK ="Scalecaller Peak";
    Esosets.MOON_HUNTER_KEEP = "Moon Hunter Keep";
    Esosets.MARCH_OF_SACRIFICES ="March of Sacrifices";



    Esosets.HALLS_OF_FABRICATION="Halls of Fabrication";
    Esosets.HEL_RA ="Hel Ra Citidel";
    Esosets.MAELSTROM ="Maelstrom Arena";
    Esosets.ATHERIAN_ARCHIVE ="Aetherian Archive";
    Esosets.SANCTUM ="Sanctum Ophidia";
    Esosets.DSA ="Dragon Star Arena";
    Esosets.MAW_OF_LORKAJ ="Maw of Lorkhaj";
    Esosets.CLOUDREST ="Cloudrest";

    Esosets.FROST_VAULT = "Frostvault";
    Esosets.DEPTHS_OF_MALATAR = "Depths of Malatar";
    Esosets.LAYER_OF_MAARSELOK = "Lair of Maarselok";
    Esosets.MOONGRAVE_FANE = "Moongrave Fane";
    Esosets.SUNSPIRE = "Sunspire";



    Esosets.ALL_DUNGEONS ={Esosets.ANY, Esosets.RUINS_OF_MAZZ,Esosets.CRADLE_OF_SHADOWS,Esosets.HALLS_OF_FABRICATION, Esosets.SPINDLE_CLUTCH_I,Esosets.SPINDLE_CLUTCH_II,
        Esosets.WHITE_GOLD_TOWER,Esosets.CITY_OF_ASH_I,Esosets.CITY_OF_ASH_II,Esosets.WAYREST_SEWERS_I,Esosets.WAYREST_SEWERS_II,Esosets.HEL_RA,
        Esosets.FUNGAL_GROTTO_I,Esosets.FUNGAL_GROTTO_II,Esosets.MAELSTROM,Esosets.DARKSHADE_CAVERNS_I,Esosets.DARKSHADE_CAVERNS_II,Esosets.ATHERIAN_ARCHIVE,
        Esosets.SANCTUM, Esosets.DSA, Esosets.ARX, Esosets.ELDEN_HOLLOW_I,Esosets.ELDEN_HOLLOW_II,Esosets.IMPERIAL_CITY_PRISON,Esosets.MAW_OF_LORKAJ,
        Esosets.DIREFROST_KEEP,Esosets.BANISHED_CELLS_I,Esosets.BANISHED_CELLS_II,Esosets.CRYPT_OF_HEARTS_I,Esosets.CRYPT_OF_HEARTS_II,Esosets.BLESSED_CRUCIBLE,
        Esosets.TEMPEST_ISLAND,Esosets.VOLENFELL,Esosets.SELENES_WEB,Esosets.VAULTS_OF_MADNESS,Esosets.BLACKHEART_HAVEN,Esosets.FALKREATH_HOLD,
        Esosets.BLOODROOT_FORGE,Esosets.FANG_LAIR,Esosets.SCALECALLER_PEAK, Esosets.CLOUDREST, Esosets.MOON_HUNTER_KEEP, Esosets.MARCH_OF_SACRIFICES,
        Esosets.FROST_VAULT, Esosets.DEPTHS_OF_MALATAR,Esosets.LAYER_OF_MAARSELOK,Esosets.MOONGRAVE_FANE, Esosets.SUNSPIRE



    };


    -- ZONES

    Esosets.SUMMERSET_ISLE = "Summerset Isle"
    Esosets.ARTAEUM ="Artaeum"
    Esosets.VVARDENFELL ="Vvardenfell";
    Esosets.HEWS_BANE ="Hew's Bane";
    Esosets.WROTHGAR ="Wrothgar";
    Esosets.GOLD_COAST ="Gold Coast";
    Esosets.BATTLE_GROUNDS ="Battlegrounds";
    Esosets.CYRODIIL ="Cyrodiil";

    Esosets.STROS_MKAI = "Stros M'Kai";
    Esosets.BETNIKH ="Betnikh";
    Esosets.GLENUMBRA ="Glenumbra";
    Esosets.STORMHAVEN ="Stormhaven";
    Esosets.RIVENSPIRE ="Rivenspire";
    Esosets.ALIKR ="Alik'r Desert";
    Esosets.BANGKORAI ="Bangkorai";
    


    Esosets.KHENARTHIS_ROOST ="Khenarthi's Roost";
    Esosets.AURIDON = "Auridon";
    Esosets.GRAHTWOOD ="Grahtwood";
    Esosets.GREENSHADE ="Greenshade";
    Esosets.MALABAL_TOR="Malabal Tor";
    Esosets.REAPERS_MARCH="Reaper's March";


    Esosets.BLEAKROCK ="Bleakrock Isle";
    Esosets.BAL_FOYEN ="Bal Foyen";
    Esosets.STONEFALLS ="Stonefalls";
    Esosets.DESHAAN ="Deshaan";
    Esosets.SHADOWFEN ="Shadowfen";
    Esosets.EASTMARCH ="Eastmarch";
    Esosets.THE_RIFT ="The Rift";



    Esosets.COLDHARBOUR ="Coldharbour";
    Esosets.CRAGLORN = "Craglorn";
    Esosets.EYEVEA ="Eyevea";
    Esosets.CLOCKWORKCITY ="Clockwork City";

    -- this will be used to find sets by zones or dungeons*/
    Esosets.ALL_ZONES = {Esosets.ANY, Esosets.VVARDENFELL,Esosets.HEWS_BANE,Esosets.WROTHGAR,Esosets.GOLD_COAST,Esosets.BATTLE_GROUNDS,Esosets.CYRODIIL,Esosets.GLENUMBRA,Esosets.COLDHARBOUR,
        Esosets.STROS_MKAI, Esosets.BETNIKH,Esosets.STORMHAVEN, Esosets.RIVENSPIRE, Esosets.ALIKR, Esosets.BANGKORAI,Esosets.KHENARTHIS_ROOST,Esosets.AURIDON,
        Esosets.CRAGLORN, Esosets.GRAHTWOOD, Esosets.GREENSHADE,Esosets.MALABAL_TOR,Esosets.REAPERS_MARCH,Esosets.BLEAKROCK,Esosets.BAL_FOYEN,Esosets.STONEFALLS,
        Esosets.DESHAAN,Esosets.SHADOWFEN,Esosets.EASTMARCH,Esosets.THE_RIFT,Esosets.EYEVEA,Esosets.CLOCKWORKCITY,Esosets.SUMMERSET_ISLE,Esosets.ARTAEUM, Esosets.MURKMIRE
    };


    -- MONSTER SHOULDERS
    Esosets.MAJ_AL ="Maj Al-Ragath";
    Esosets.GILIRION ="Gilirion";
    Esosets.URG ="Urgalarg Chief-bane";


    Esosets.ALL_MONSTER_SHOULDER_VENDORS ={Esosets.ANY,Esosets.MAJ_AL,Esosets.GILIRION,Esosets.URG};

    Esosets.PVP = "PvP"
    Esosets.PVE = "PvE"
    Esosets.NICHE = "Niche"
    Esosets.BEGINNER = "Beginner"

    Esosets.ALL_BEST_USED_FOR = {Esosets.ANY,Esosets.PVE,Esosets.PVP,Esosets.NICHE,Esosets.BEGINNER}

    local function compare(a,b)
        return a < b
    end

    table.sort(Esosets.ALL_BONUSES, compare)
    table.sort(Esosets.ALL_ZONES, compare)
    table.sort(Esosets.ALL_DUNGEONS, compare)


end -- end InitConstants()
