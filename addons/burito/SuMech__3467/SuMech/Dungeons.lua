SuMech.data = {
  ["Example Dungeon"] = {
    ["Example Mob"] = {
      -- if 1,2,4 are missing, will default to 0
      [0] = "Advice for Everyone",
      [1] = "Advice for DPS",
      [2] = "Advice for Tank",
      [4] = "Advice for Healer",
    }
  },

----------------------
-- Non-DLC dungeons --
----------------------

  ["Arx Corinium"] = {
    -- minibosses
    ["Fanged Menace"] = { [0] = "Her AoE drains health" },
    ["Matron Ixniaa"] = { [0] = "Ignore ghosts" },
    ["Ancient Lurcher"] = { [0] = "Can't avoid Green Beam" },
    -- bosses
    ["Ganakton the Tempest"] = { [0] = "" },
    ["Sliklenia the Songstress"] = { [0] = "Keep snake alive, it protects from song" },
    ["Sellistrix the Lamia Queen"] = { [0] = "Don't run, In water +shock -defence" },
  },

  ["The Banished Cells I"] = {
    -- minibosses
    ["Cell Haunter"] = { [0] = "Can't avoid Green Beam" },
    ["Angata the Clannfear Handler"] = { [0] = "Kill adds quickly" },
    ["Skeletal Destroyer"] = { [0] = "" },
    -- bosses
    ["Shadowrend"] = { [0] = "Kill the clone quickly" },
    ["High Kinlord Rilis"] = { [0] = "Destroy orbs, they heal him" },
  },

  ["The Banished Cells II"] = {
    -- minibosses
    ["Keeper Areldur"] = { [0] = "" },
    ["Keeper Voranil"] = { [0] = "" },
    ["Sister Vera"] = { [0] = "Kill one, the other Rages" },
    ["Sister Sihna"] = { [0] = "Kill one, the other Rages" },
    -- bosses
    ["Maw of the Infernal"] = { [0] = "" },
    ["Keeper Imiril"] = { [0] = "Kill adds quickly" },
    ["High Kinlord Rilis"] = { [0] = "After lift, go to that coloured pad" },
  },

  ["Blackheart Haven"] = {
    -- minibosses
    ["Iron-Heel"] = { [0] = "He Kicks, avoid the edge" },
    ["First Mate Wavecutter"] = { [0] = "Interrupt or Dodge Forking Bolt" },
    ["Hollow Heart"] = { [0] = "" },
    -- bosses
    ["Atarus"] = { [0] = "" },
    ["Roost Mother"] = { [0] = "" },
    ["Captain Blackheart"] = { [0] = "Endlessly spawns adds" },
  },

  ["Blessed Crucible"] = {
    -- minibosses
    ["Grunt the Clever"] = { [0] = "" },
    ["Teranya the Faceless"] = { [0] = "" },
    ["Captain Thoran"] = { [0] = "Immune while Atronach lives" },
    -- bosses
    ["Dynus Aralas"] = { [0] = "Use Crowd Control" },
    ["Kayd at-Sal"] = { [0] = "Use Crowd Control" },
    ["Nusana"] = { [0] = "Use Crowd Control" },
    ["Snagg gro-Mashul"] = { [0] = "Use Crowd Control" },
    ["The Beast Master"] = { [0] = "" },
    ["The Troll King"] = { [0] = "" },
    ["The Lava Queen"] = { [0] = "Immune while Atronachs live" },
  },


  ["City of Ash I"] = {
    -- minibosses
    ["Golor the Banekin Handler"] = { [0] = "Kill adds quickly" },
    ["Dark Ember"] = { [0] = "" },
    ["Rothariel Flameheart"] = { [0] = "Kill the Clones quickly" },
    -- bosses
    ["Infernal Guardian"] = { [0] = "" },
    ["Warden of the Shrine"] = { [0] = "" },
    ["Razor Master Erthas"] = { [0] = "Swim to remove Fire DoT" },
  },

  ["City of Ash II"] = {
    -- minibosses
    ["Rukhan"] = { [0] = "Akezel=Healer, Rukhan=Summoner, Marruz=Ranged" },
    ["Akezel"] = { [0] = "Akezel=Healer, Rukhan=Summoner, Marruz=Ranged" },
    ["Marruz"] = { [0] = "Akezel=Healer, Rukhan=Summoner, Marruz=Ranged" },
    ["Urata the Legion"] = { [0] = "Kill adds to prevent healing" },
    ["Xivilai Boltaic"] = { [0] = "Kill adds" },
    ["Xivilai Fulminator"] = { [0] = "Kill adds" },
    -- bosses
    ["Horvantud the Fire Maw"] = { [0] = "Watch for adds" },
    ["Ash Titan"] = { [0] = "Tank kite Antronachs, or Team kill them" },
    ["Valkyn Skoria"] = { [0] = "Time limit = he destroys all platforms" },
  },

  ["Crypt of Hearts I"] = {
    -- minibosses
    ["The Mage Master"] = { [0] = "" },
    ["Uulkar Bonehand"] = { [0] = "" },
    ["Dogas the Berserker"] = { [0] = "" },
    -- bosses
    ["Archmaster Siniel"] = { [0] = "Watch for adds" },
    ["Death's Leviathan"] = { [0] = "" },
    ["Ilambris-Athor"] = { [0] = "Try to kill them together" },
    ["Ilambris-Zaven"] = { [0] = "Try to kill them together" },
    ["Ilambris Amalgam"] = { [0] = "" },
  },

  ["Crypt of Hearts II"] = {
    -- minibosses
    ["Ibelgast"] = { [0] = "Persistant adds that summon Atronachs" },
    ["Chamber Guardian"] = { [0] = "" },
    ["Mezeluth"] = { [0] = "If the circles overlap, instant kill" },
    -- bosses
    ["Ruzozuzalpamaz"] = { [0] = "Everyone must unzip cocooned players" },
    ["Ilambris-Athor"] = { [0] = "Try to kill them together" },
    ["Ilambris-Zaven"] = { [0] = "Try to kill them together" },
    ["Ilambris Amalgam"] = { [0] = "" },
    ["Nerien'eth"] = { [0] = "Arms red = block" },
  },

  ["Darkshade Caverns I"] = {
    -- minibosses
    ["Head Shepherd Neloren"] = { [0] = "Interrupt the heal spells" },
    ["Cavern Patriach"] = { [0] = "" },
    ["Cutting Sphere"] = { [0] = "Will chase random player, kite" },
    -- bosses
    ["Foreman Llothan"] = { [0] = "Keep distance, watch for adds" },
    ["The Hive Lord"] = { [0] = "Keep close, watch for adds" },
    ["Sentinel of Rkugamz"] = { [0] = "Kill the heal spiders" },
  },

  ["Darkshade Caverns II"] = {
    -- minibosses
    ["The Fallen Foreman"] = { [0] = "" },
    ["Transmuted Alit"] = { [0] = "" },
    ["Engine Garrison"] = { [0] = "" },
    -- bosses
    ["Transmuted Hive Lord"] = { [0] = "" },
    ["Grobull the Transmuted"] = { [0] = "Reflect Shield, kill adds to drop" },
    ["The Engine Guardian"] = { [0] = "Taunt immune, levers stop poison" },
  },

  ["Direfrost Keep"] = {
    -- minibosses
    ["Drodda's Apprentice"] = { [0] = "Break Free of Heal Beam" },
    ["Drodda's Dreadlord"] = { [0] = "Beware of adds" },
    ["Teethnasher the Frostbound"] = { [0] = "Stay close, but not too close" },
    -- bosses
    ["Guardian of the Flame"] = { [0] = "" },
    ["Iceheart"] = { [0] = "Kill adds quickly" },
    ["Drodda of Icereach"] = { [0] = "Taunt Resistant, Tank and Kill adds" },
  },

  ["Elden Hollow I"] = {
    -- minibosses
    ["Ancient Spriggan"] = { [0] = "Persistant adds, interrupt heal" },
    ["Nenesh gro-Mal"] = { [0] = "" },
    ["Leafseether"] = { [0] = "" },
    -- bosses
    ["Akash gra-Mal"] = { [0] = "" },
    ["Chokethorn"] = { [0] = "Kill healing adds" },
    ["Canonreeve Oraneth"] = { [0] = "Kill adds quickly" },
  },

  ["Elden Hollow II"] = {
    -- minibosses
    ["Dubroze the Infestor"] = { [0] = "" },
    ["Azara the Frightener"] = { [0] = "Constantly summons adds" },
    ["The Shadow Guard"] = { [0] = "Destroy Protection Totem" },
    ["Dark Root"] = { [0] = "Dead adds leave player healing mist" },
    ["Murklight"] = { [0] = "Stand in white circles" },
    ["Bogdan the Nightflame"] = { [0] = "White adds heal boss" },
  },

  ["Fungal Grotto I"] = {
    -- minibosses
    ["Tazkad the Packmaster"] = { [0] = "" },
    ["Bloodbirther"] = { [0] = "" },
    ["Clatterclaw"] = { [0] = "Watch for adds" },
    -- bosses
    ["War Chief Ozozai"] = { [0] = "" },
    ["Kra'gh the Dreugh King"] = { [0] = "Watch for adds" },
  },

  ["Fungal Grotto II"] = {
    -- minibosses
    ["Mephala's Fang"] = { [0] = "" },
    ["Ciirenas The Shepherd"] = { [0] = "Don't kill the Spiders" },
    ["Reggr Dark-Dawn"] = { [0] = "Will Drain Magicka" },
    -- bosses
    ["Gamyne Bandu"] = { [0] = "Everyone kill the same Shade" },
    ["Spawn of Mephala"] = { [0] = "Closest person to cave gets sent to the spider room" },
    ["Vila Theran"] = { [0] = "|c0000FFBubble|r protects |c0000FFBeams|r HM:don't use" },
  },

  ["Selene's Web"] = {
    -- minibosses
    ["Treethane Kerninn"] = { [0] = "" },
    ["Queen Aklayah"] = { [0] = "" },
    ["Mennir Many-Legs"] = { [0] = "Don't get close, Watch for adds" },
    -- bosses
    ["Longclaw"] = { [0] = "Reflect Shield, kite the ghost cats" },
    ["Shadowiskers"] = { [0] = "Reflect Shield, kite the ghost cats" },
    ["Nighteyes"] = { [0] = "Reflect Shield, kite the ghost cats" },
    ["Heartstalker"] = { [0] = "Reflect Shield, kite the ghost cats" },
    ["Silentpaw"] = { [0] = "Reflect Shield, kite the ghost cats" },
    ["Foulhide"] = { [0] = "Avoid or kill adds" },
    ["Selene"] = { [0] = "Kill healing adds" },
  },

  ["Spindleclutch I"] = {
    -- minibosses
    ["Spindlekin"] = { [0] = "Watch for adds, interrupt feeding" },
    ["Cerise the Widow-Maker"] = { [0] = "" },
    ["Big Rabbu"] = { [0] = "" },
    -- bosses
    ["Swarm Mother"] = { [0] = "Stay near, watch for adds" },
    ["The Whisperer"] = { [0] = "The adds are a hallucination" },
  },

  ["Spindleclutch II"] = {
    -- minibosses
    ["Mad Mortine"] = { [0] = "" },
    ["Flesh Atronach Trio"] = { [0] = "Health Buff when one dies" },
    ["Urvan Veleth"] = { [0] = "Bloodpool drains health" },
    -- bosses
    ["Bloodspawn"] = { [0] = "Time Limit = Cave In" },
    ["Praxin Douare"] = { [0] = "Kill 4 waves of adds first" },
    ["Vorenor Winterbourne"] = { [0] = "Fight him near the entrance" },
  },

  ["Tempest Island"] = {
    -- minibosses
    ["Sonolia the Matriarch"] = { [0] = "" },
    ["Yalorasse the Speaker"] = { [0] = "" },
    ["Commodore Ohmanil"] = { [0] = "" },
    -- bosses
    ["Valaran Stormcaller"] = { [0] = "Kill the add quickly" },
    ["Stormfist"] = { [0] = "Kill adds quickly" },
    ["Stormreeve Neidir"] = { [0] = "Time limit, stay close" },
  },

  ["Vaults of Madness"] = {
    -- minibosses
    ["The Cursed One"] = { [0] = "Stop attacking when white line put on player" },
    ["Death's Head"] = { [0] = "" },
    ["Achaeraizur"] = { [0] = "" },
    ["The Ancient One"] = { [0] = "" },
    -- bosses
    ["Ulguna Soul-Reaver"] = { [0] = "Kill Orbs to free companion" },
    ["Grothdarr"] = { [0] = "" },
    ["Iskra the Omen"] = { [0] = "" },
    ["Mad Architect"] = { [0] = "Kill adds quickly, get in his bubble" },
  },

  ["Volenfell"] = {
    -- minibosses
    ["Desert Lion"] = { [0] = "" },
    ["Boilbite"] = { [0] = "" },
    ["Unstable Construct"] = { [0] = "" },
    -- bosses
    ["Quintus Verres"] = { [0] = "" },
    ["Tremorscale"] = { [0] = "" },
    ["The Guardian's Soul"] = { [0] = "Kite Red, Kill Green and Blue" },
    ["The Guardian's Strength"] = { [0] = "Kite Red, Kill Green and Blue" },
    ["The Guardian's Spark"] = { [0] = "Kite Red, Kill Green and Blue" },
  },

  ["Wayrest Sewers I"] = {
    -- minibosses
    ["Slimecraw"] = { [0] = "" },
    ["The Rat Whisperer"] = { [0] = "Watch for adds" },
    ["Uulgarg the Hungry"] = { [0] = "" },
    -- bosses
    ["Investigator Garron"] = { [0] = "Watch for adds" },
    ["Varaine Pellingare"] = { [0] = "" },
    ["Allene Pellingare"] = { [0] = "Kill adds quickly" },
  },

  ["Wayrest Sewers II"] = {
    -- minibosses
    ["Skull Reaper"] = { [0] = "Kill adds to weaken him" },
    ["Uulgarg the Risen"] = { [0] = "" },
    ["The Forgotten One"] = { [0] = "" },
    -- bosses
    ["Malubeth the Scourger"] = { [0] = "Activate both altars to free player" },
    ["Garron the Returned"] = { [0] = "Kill adds quickly" },
    ["Varaine Pellingare"] = { [0] = "Kill adds quickly" },
    ["Allene Pellingare"] = { [0] = "Kill adds quickly" },
  },

----------------------
---- DLC dungeons ----
----------------------

-- Imperial City
  ["Imperial City Prison"] = {
    -- minibosses
    ["Overfiend"] = { [0] = "Kill adds quick, also Big Add" },
    ["Gravelight Sentry"] = { [0] = "Kill adds first" },
    ["Lord-Warden's Berserker"] = { [0] = "Immortal while Totem stands" },
    ["Lord-Warden's Knight"] = { [0] = "Immortal while Totem stands" },
    ["Lord-Warden's Necromancer"] = { [0] = "Immortal while Totem stands" },
    ["Lord-Warden's Templar"] = { [0] = "Immortal while Totem stands" },
    -- bosses
    ["Ibomez the Flesh Sculptor"] = { [0] = "Use grenades on inmates" },
    ["Flesh Abomination"] = { [0] = "Kill adds quickly" },
    ["Lord Warden Dusk"] = { [0] = "Use portals to escape blast" },
  },

  ["White-Gold Tower"] = {
    -- bosses
    ["The Adjudicator"] = { [0] = "" },
    ["The Planar Inhibitor"] = { [0] = "" },
    ["Molag Kena"] = { [0] = "" },
  },

-- Shadows of the Hist
  ["Cradle of Shadows"] = {
    -- bosses
    ["Khephidaen"] = { [0] = "" },
    ["Draons Velador"] = { [0] = "" },
    ["Velidreth"] = { [0] = "" },
  },
  ["Ruins of Mazzatun"] = {
    -- bosses
    ["Mighty Chudan"] = { [0] = "When targetted, lead through lightning" },
    ["Xal-Nur the Slaver"] = { [0] = "Carry spit to fountain" },
    ["Tree-Minder Na-Kesh"] = { [0] = "Lead Madness victim to Glowing Statue" },
  },

-- Horns of the Reach
  ["Bloodroot Forge"] = {
    -- bosses
    ["Caillaoife"] = { [0] = "" },
    ["Galchobhar"] = { [0] = "" },
    ["Earthgore Amalgam"] = { [0] = "" },
  },
  ["Falkreath Hold"] = {
    -- bosses
    ["Siege Mammoth"] = { [0] = "" },
    ["Cernunnon"] = { [0] = "Use Urns to Cleanse Corpses" },
    ["Domihaus the Bloody-Horned"] = { [0] = "" },
  },

-- Dragon Bones
  ["Fang Lair"] = {
    -- bosses
    ["Cadaverous Menagerie"] = { [0] = "" },
    ["Caluurion"] = { [0] = "" },
    ["Ulfnor"] = { [0] = "" },
    ["Thurvokun"] = { [0] = "" },
  },
  ["Scalecaller Peak"] = {
    -- bosses
    ["Orzun the Foul-Smelling"] = { [0] = "Freeze yourself to protect from Tremor" },
    ["Rinaerus the Rancid"] = { [0] = "Hide behind Ice Pillar to protect from Ice ball" },
    ["Doylemish Ironheart"] = { [0] = "" },
    ["Matriarch Aldis"] = { [0] = "Take disease sample from Leiminid corpse left of door" },
    ["Plague Concoter Mortieu"] = { [0] = "Take disease sample from alchemy bench" },
    ["Zaan the Scalecaller"] = { [0] = "" },
  },

-- Wolfhunter
  ["March of Sacrifices"] = {
    -- mobs
    ["Autumn Lurcher"] = { [0] = "Take to |c00FF00Green Aura|r" },
    ["Frost Lurcher"] = { [0] = "Take to |cFF0000Red Aura|r" },
    ["Blaze Lurcher"] = { [0] = "Take to |c0000FFBlue Aura|r" },
    ["Budding Lurcher"] = { [0] = "Take to |cFF7E00Orange Aura|r" },
    ["Sea Lurcher"] = { [0] = "Block the blue AoE or die" },
    ["Bloodscent Assassin"] = { [0] = "Interrupt or Unpin or die" },
    -- bosses
    ["Wyress Rangifer"] = { [0] = "|cFF0000Damage |c00FF00Heal |c0000FFSilence|r Kill in that order" },
    ["Wyress Strigidae"] = { [0] = "|cFF0000Damage |c00FF00Heal |c0000FFSilence|r Kill in that order" },
    ["Wyress Ursus"] = { [0] = "|cFF0000Damage |c00FF00Heal |c0000FFSilence|r Kill in that order" },
    ["Aghaedh of the Solstice"] = { [0] = "Pick up Lurcher Aura to survive AoE" },
    ["Dagrund the Bulky"] = { [0] = "" },
    ["Tarcyr"] = { [0] = "Crouch in fog, kill adds quick" },
    ["Balorgh"] = { [0] = "When targetted, lure boss to |c0000FFBlue pillar|r" },
  },

  ["Moon Hunter Keep"] = {
    -- bosses
    ["Jailer Melitus"] = { [0] = "His charge attack has to be interrupted" },
    ["Hedge Maze Guardian"] = { [0] = "Kill Spriggans, Bash Stranglers" },
    ["Mylenne Moon-Caller"] = { [0] = "Humans > Dogs > Boss\nBash Boss" },
    ["Archivist Ernarde"] = { [0] = "Adds Spawn at health %" },
    ["Vykosa the Ascendant"] = { [0] = "Wolves spawn at health %" },
  },

-- Wrathstone
  ["Depths of Malatar"] = {
    -- bosses
    ["The Scavenging Maw"] = { [0] = "When found, interrupt" },
    ["The Weeping Woman"] = { [0] = "Knights > Atros > Boss" },
    ["The Dark Orb"] = { [0] = "Tank kite Aurorans" },
    ["King Narilmor"] = { [0] = "Tank lure them together" },
    ["The Symphony of Blades"] = { [0] = "" },
  },
  ["Frostvault"] = {
    -- bosses
    ["Icestalker"] = { [0] = "" },
    ["Warlord Tzogvin"] = { [0] = "" },
    ["The Vault Protector"] = { [0] = "" },
    ["Rizzuk Bonechill"] = { [0] = "Tank solo's Atro" },
    ["The Stonekeeper"] = { [0] = "" },
  },

-- Scalebreaker
  ["Lair of Maarselok"] = {
    -- bosses
    ["Selene's Claws"] = { [0] = "" },
    ["Selene's Fangs"] = { [0] = "" },
    ["Azureblight Lurcher"] = { [0] = "" },
    ["Azureblight Cancroid"] = { [0] = "" },
    ["Maarselok"] = { [0] = "" },
  },
  ["Moongrave Fane"] = {
    -- bosses
    ["Rizen Ruins"] = { [0] = "" },
    ["Dro'zakar"] = { [0] = "" },
    ["Kujo Kethba"] = { [0] = "" },
    ["Nisaazda"] = { [0] = "" },
    ["Grundwulf"] = { [0] = "" },
  },


-- Harrowstorm
  ["Icereach"] = {
    -- bosses
    ["Kjarg the Tuskscaper"] = { [0] = "Kite when |cFF0000Enraged|r" },
    ["Sister Skelga"] = { [0] = "Use fire field to thaw Stranglers" },
    ["Vearogh the Shambler"] = { [0] = "|c0000FFSkele Beams|r drain" },
    ["Stormborn Revenant"] = { [0] = "Storm Atronarchs buff boss" },
    ["Mother Ciannait"] = { [0] = "" },
  },
  ["Unhallowed Grave"] = {
    -- bosses
    ["Eternal Aegis"] = { [0] = "" },
    ["Hakgrym the Howler"] = { [0] = "" },
    ["Keeper of the Kiln"] = { [0] = "" },
    ["Ondagore the Mad"] = { [0] = "" },
    ["Kjalnar Tombskald"] = { [0] = "" },
  },

-- Stonethorn
  ["Castle Thorn"] = {
    -- bosses
    ["Dread Tindulra"] = { [0] = "" },
    ["Blood Twilight"] = { [0] = "" },
    ["Vaduroth"] = { [0] = "" },
    ["Talfyg"] = { [0] = "" },
    ["Lady Thorn"] = { [0] = "" },
  },
  ["Stone Garden"] = {
    -- bosses
    ["Exarch Kraglen"] = { [0] = "Interrupt Howl, Dodge Charge" },
    ["Stone Behemoth"] = { [0] = "" },
    ["Arkasis the Mad Alchemist"] = { [0] = "" },
  },

-- Flames of Ambition
  ["Black Drake Villa"] = {
    -- bosses
    ["Kinras Ironeye"] = { [0] = "Totems > Salamanders > Boss\nSalamanders Enrage\nInterrupt Roar (attracts salamanders)\nFrozen Salamanders debuff" },
    ["Captain Geminus"] = { [0] = "" },
    ["Pyrotuge Encratis"] = { [0] = "" },
    -- hidden bosses
    ["Avatar of Zeal"] = { [0] = "" },
    ["Avatar of Vigor"] = { [0] = "" },
    ["Avatar of Fortitude"] = { [0] = "" },
    ["Sentinel Aksalaz"] = { [0] = "Slot Purge" },
  },
  ["The Cauldron"] = {
    -- bosses
    ["Oxblood the Depraved"] = { [0] = "" },
    ["Taskmaster Viccia"] = { [0] = "" },
    ["Molten Guardian"] = { [0] = "" },
    ["Baron Zaudrus"] = { [0] = "" },
  },

-- Waking Flame
  ["The Dread Cellar"] = {
    -- bosses
    ["Scorion Broodlord"] = { [0] = "" },
    ["Cyronin Artellian"] = { [0] = "" },
    ["Magma Incarnate"] = { [0] = "" },
  },
  ["Red Petal Bastion"] = {
    -- bosses
    ["Rogerain the Sly"] = { [0] = "" },
    ["Eliam Merick"] = { [0] = "" },
    ["Prior Thierric Sarazen"] = { [0] = "" },
  },


  --[[
  [""] = {
    -- minibosses
    [""] = { [0] = "" },
    [""] = { [0] = "" },
    [""] = { [0] = "" },
    -- bosses
    [""] = { [0] = "" },
    [""] = { [0] = "" },
    [""] = { [0] = "" },
  },
--]]

}
