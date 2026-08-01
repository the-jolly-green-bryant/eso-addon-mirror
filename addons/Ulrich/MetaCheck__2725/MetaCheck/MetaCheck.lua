-------------------------------------------------------------------------------
-- MetaCheck 1.0.2
-------------------------------------------------------------------------------
--
-- This project uses code from CritPercent addon released under MIT license.
-- See the license text attached to the end of this file.
--
-------------------------------------------------------------------------------

local StamDD = "esoUI/Art/tutorial/gamepad/gp_playermenu_icon_skills.dds"
local MagickaDD = "esoUI/Art/progression/skills_announce_world.dds"
local Tank = "esoUI/Art/progression/skills_announce_armor.dds"
local Healer = "esoUI/Art/lfg/gamepad/lfg_roleicon_healer.dds"

local pvp = "esoUI/Art/lfg/gamepad/lfg_activityicon_cyrodiil.dds"
local pve = "esoUI/Art/journal/gamepad/gp_questtypeicon_instance.dds"

local SizeTable = { 
    [StamDD] = { width = 57, height = 57},
    [MagickaDD] = { width = 48, height = 48},
    [Tank] = { width = 45, height = 45},
    [Healer] = { width = 48, height = 48}
}

local MGcurrentItemWeaponType
local weaponorarmor


MetaCheck = {

displayName = "|c3CB371" .. "Meta Check" .. "|r",
    shortName = "MC",
    name = "MetaCheck",
    version = "1.0.2",  
    
    MetaItemSets = {
      
      
      -- STAMINA

[206] = {use = StamDD},                                                  -- Agilitaet
[301] = {use = StamDD},                                                  -- Staerke des Automaten
[400] = {use = StamDD, domain = pve},                                    -- Blutmond
[144] = {use = StamDD, domain = pve},                                    -- Doppelzuengige Schlange
[212] = {use = StamDD},                                                  -- Dornenherz / Briarheart 
[226] = {use = StamDD, domain = pvp},                                    -- Ewige Jagt
[100] = {use = StamDD, domain = pvp},                                    -- Falkenauge
 [80] = {use = StamDD},                                                  -- Hundings Zorn
[253] = {use = StamDD, domain = pvp},                                    -- Kaiserliche Physis
[325] = {use = StamDD, use2 = MagickaDD, domain = pvp, domain2 = pvp},   -- Kettensprenger 2/2
[331] = {use = StamDD, domain = pve},                                    -- Kriegsmaschine
[302] = {use = StamDD, domain = pve},                                    -- Leviathan
[445] = {use = StamDD, domain = pve},                                    -- Lokkestiiz
[450] = {use = StamDD, domain = pve},                                    -- Lokkestiiz -perfekt-
[308] = {use = StamDD},                                                  -- Lumpen des Knochenpiraten
[352] = {use = StamDD, use2 = Tank, domain = pvp, domain2 = pve},        -- Messingpanzer 2/2
[470] = {use = StamDD, use2 = MagickaDD},                                -- Akolythin des Neuen Mondes 2/2
[239] = {use = StamDD, domain = pvp},                                    -- Raserei des Kriegers
[389] = {use = StamDD, domain = pve},                                    -- Relequen
[393] = {use = StamDD, domain = pve},                                    -- Relequen -perfect-
 [70] = {use = StamDD, domain = pvp},                                    -- Rohling der siebten Legion
 [36] = {use = StamDD, domain = pve},                                    -- Ruestung des Schleiererbes 
[336] = {use = StamDD, domain = pve},                                    -- Säulen von Nirn
 [49] = {use = StamDD, domain = pvp},                                    -- Schatten des Roten Berges
[225] = {use = StamDD, domain = pvp},                                    -- Schlauer Alchemist
[344] = {use = StamDD, domain = pvp},                                    -- Staerkungsprunk
[137] = {use = StamDD, domain = pve},                                    -- Tobender Krieger
[127] = {use = StamDD, domain = pve},                                    -- Toedlicher Stoss
[159] = {use = StamDD, domain = pve},                                    -- Trennflamme
[430] = {use = StamDD, domain = pve},                                    -- Tzogvins Kriegstrupp
[334] = {use = StamDD, use2 = MagickaDD, domain = pvp, domain2 = pvp},   -- Unueberwindliche Ruestung 2/2
[173] = {use = StamDD, domain = pve},                                    -- Vicious Serpent
[234] = {use = StamDD, domain = pvp},                                    -- Wappen des Meisterschuetzen
[286] = {use = StamDD},                                                  -- Dornen des Zweiglings
--101
[490] = {use = StamDD, domain = pvp},                                    -- Stuhns Gunst
 [90] = {use = StamDD, domain = pvp},                                    -- Biss des Senche
[383] = {use = StamDD, domain = pvp},                                    -- Wildheit des Greifen
[475] = {use = StamDD, domain = pve},                                    -- Aegisrufer
[472] = {use = StamDD, domain = pvp},                                    -- Titanenkinds Staerke
[128] = {use = StamDD, domain = pvp},                                    -- Segen des Potentaten
--102
[570] = {use = StamDD, domain = pve},                                    -- Kinras
[467] = {use = StamDD, domain = pve},                                    -- Drachengardeelite
[498] = {use = StamDD, domain = pve},                                    -- Yandirs Macht
[456] = {use = StamDD, domain = pve},                                    -- Azurfäuleschnitter
[387] = {use = StamDD, domain = pvp},                                    -- Nocturals Gunst


      -- TANK

 [21] = {use = Tank, domain = pve},                                      -- Akavirische Drachengarde
 [39] = {use = Tank},                                                    -- Alessianischer Orden
[196] = {use = Tank, domain = pve},                                      -- Auslaugende Ruestung
[422] = {use = Tank},                                                    -- Bataillonsverteidiger v102
[232] = {use = Tank, domain = pve},                                      -- Bruellen von Alkosh
[122] = {use = Tank, use2 = Healer, domain = pve, domain2 = pve},        -- Ebenerzarsenal 2/2
[171] = {use = Tank, domain = pve},                                      -- Ewiger Krieger
[124] = {use = Tank, use2 = Healer, domain = pve, domain2 = pve},        -- Garderobe des Wurms 2/2
[123] = {use = Tank, use2 = Healer, domain = pve},                       -- Hircines Schein 2/2
[180] = {use = Tank, domain = pve},                                      -- Kraftvoller Ansturm
[446] = {use = Tank, domain = pve},                                      -- Kralle von Yolnahkriin
[451] = {use = Tank, domain = pve},                                      -- Kralle von Yolnahkriin -perfect-
[184] = {use = Tank, domain = pve},                                      -- Male des Kaiserreichs
--                                                                       -- Messingpanzer
[231] = {use = Tank, domain = pve},                                      -- Mondbastion
 [50] = {use = Tank, domain = pve},                                      -- Morag Tong
[293] = {use = Tank, domain = pve},                                      -- Seuchendoktor
 [75] = {use = Tank, use2 = Healer, use3 = MagickaDD, domain3 = pvp},    -- Torugs Packt 3/3
[288] = {use = Tank, domain = pve},                                      -- Werkzeug des Bienenhueters
--101
[204] = {use = Tank, domain = pvp},                                      -- Bestaendigkeit
--102
[574] = {use = Tank, domain = pve},                                      -- Foolkillers Ward
[571] = {use = Tank, domain = pve},                                      -- Dracheneile
[388] = {use = Tank, domain = pve},                                      -- Ägis von Galenwe
[113] = {use = Tank, domain = pve},                                      -- Wappen von Cyrodiil
[457] = {use = Tank, domain = pve},                                      -- Drachenschändung
[356] = {use = Tank, domain = pve},                                      -- Stromschlag
               
               
      -- HEALER
               
--                                                                       -- Ebenerzarsenal
--                                                                       -- Garderobe des Wurms
[391] = {use = Healer},                                                  -- Gewandung von Olorime
[395] = {use = Healer},                                                  -- Gewandung von Olorime -perfekt-
[141] = {use = Healer, domain = pve},                                    -- Heilender Magier
[110] = {use = Healer},                                                  -- Heiligtum
--                                                                       -- Hircines Schein
[452] = {use = Healer},                                                  -- Hohlzahndurst
[346] = {use = Healer, domain = pve},                                    -- Jorvulds Führung
 [92] = {use = Healer, domain = pve},                                    -- Kagrenacs Hoffnung
[440] = {use = Healer, use2 = MagickaDD, domain = pvp, domain2 = pvp},   -- Listiger Alfiq 2/2 
[185] = {use = Healer, domain = pve},                                    -- Magiekraftheilung
--                                                                       -- Torugs Packt
[172] = {use = Healer},                                                  -- Unfehlbare Magierin
[147] = {use = Healer},                                                  -- Weg der Kampfkunst
 [25] = {use = Healer, domain = pvp},                                    -- Wüstenrose
--double[368] = {use = Healer},                                          -- Zeitloser Segen
--double[362] = {use = Healer},                                          -- Zeitloser Segen - perfect -
 [38] = {use = Healer},                                                  -- Zwielicht
--101
[471] = {use = Healer, domain = pvp},                                    -- Hitis Feuerstelle
[261] = {use = Healer},                                                  -- Gespinst
[181] = {use = Healer, domain = pvp},                                    -- Meritorischer Dienst
[455] = {use = Healer, domain = pve},                                    -- Zens Wiedergutmachung
--102
[487] = {use = Healer, domain = pve},                                    -- Winterruhe
[496] = {use = Healer, domain = pve},                                    -- Tobender Opportunist
               
               
      -- MAGICKA
               
[160] = {use = MagickaDD, domain = pve},                                 -- Branntzauberweber  
[215] = {use = MagickaDD, domain = pve},                                 -- Elementarfolge
[444] = {use = MagickaDD, domain = pve},                                 -- Ergebenheit zum falschen Gott
[449] = {use = MagickaDD, domain = pve},                                 -- Ergebenheit zum falschen Gott -perfekt-
[207] = {use = MagickaDD},                                               -- Gesetz von Julianos
[289] = {use = MagickaDD},                                               -- Gewaender des Webers
[236] = {use = MagickaDD, domain = pvp},                                 -- Grausamer Tod
[405] = {use = MagickaDD, domain = pvp},                                 -- Hellhalsstolz
--                                                                       -- Kettensprenger
[390] = {use = MagickaDD, domain = pve},                                 -- Mantel von Siroria
[353] = {use = MagickaDD},                                               -- Mechanikblick
[332] = {use = MagickaDD, domain = pve},                                 -- Meisterarchitekt
[292] = {use = MagickaDD, domain = pve},                                 -- Muttertränen
 [98] = {use = MagickaDD},                                               -- Nekropotenz
--                                                                       -- Akolythin des Neuen Mondes
 [43] = {use = MagickaDD},                                               -- Ruestung der Verfuehrung
 [31] = {use = MagickaDD, domain = pve},                                 -- Sonnenseide
[235] = {use = MagickaDD, domain = pvp},                                 -- Transmutation
--                                                                       -- Unueberwindliche Ruestung
[190] = {use = MagickaDD},                                               -- Verletzender Magier
[205] = {use = MagickaDD},                                               -- Willenskraft v102
[418] = {use = MagickaDD, domain = pve},                                 -- Zauberstratege
--101
--                                                                       -- Torugs Packt
[343] = {use = MagickaDD, domain = pvp},                                 -- Caluurions Erbe
[104] = {use = MagickaDD, domain = pvp},                                 -- Fluchfresser
--                                                                       -- Listiger Alfiq
--102
[304] = {use = MagickaDD, domain = pve},                                 -- Versteinerter Blick/Medusa
[227] = {use = MagickaDD, domain = pve},                                 -- Baharas Fluch


      -- STAMINA LEGENDARY WEAPONS
 
[411] = {use = StamDD, domain = pvp},                                    -- brp Mele Waffen - Gallant Charge
[423] = {use = StamDD, domain = pvp},                                    -- brp Mele Waffen - Gallant Charge - perfect -
[413] = {use = StamDD, domain = pvp},                                    -- brp Mele Waffen - Spectral Cloak
[425] = {use = StamDD, domain = pvp},                                    -- brp Mele Waffen - Spectral Cloak - perfect -
--[370] = {use = StamDD},                                                  -- Mahlstrom 1h Mele - Rampaging Slash
--[523] = {use = StamDD},                                                  -- Mahlstrom 1h Mele - perfect Rampaging Slash
[371] = {use = StamDD},                                                  -- Cruel Flurry DW
[524] = {use = StamDD},                                                  -- perfect Cruel Flurry DW
[372] = {use = StamDD, domain = pve},                                    -- Mahlstrom Bogen
[525] = {use = StamDD, domain = pve},                                    -- Perfekter Mahlstrom Bogen
[315] = {use = StamDD, domain = pvp},                                    -- Meister 1h Waffen - Stinging Slashes
[530] = {use = StamDD, domain = pvp},                                    -- Meister 1h Waffen - perfect Stinging Slashes
[316] = {use = StamDD},                                                  -- Meister Bogen
[531] = {use = StamDD},                                                  -- Perfekter Meister Bogen
[313] = {use = StamDD},                                                  -- Meister Zweihaender - Titanic Cleave
[528] = {use = StamDD},                                                  -- Meister Zweihaender - perfect Titanic Cleave
--101
[363] = {use = StamDD, domain = pvp},                                    -- Asylum 2h - Disciplined Slash
[357] = {use = StamDD, domain = pvp},                                    -- Asylum 2h - perfect Disciplined Slash
[369] = {use = StamDD, domain = pvp},                                    -- Mahlstrom 2h - Merciless Charge
[522] = {use = StamDD, domain = pvp},                                    -- Mahlstrom 2h - Perfect Merciless Charge
--102
[557] = {use = StamDD, domain = pve},                                    -- Executioners Blade, Vateshran
[563] = {use = StamDD, domain = pve},                                    -- Perfect Executioners Blade, Vateshran
[560] = {use = StamDD, domain = pve},                                    -- POINT-BLANK SNIPE, Vateshran
[566] = {use = StamDD, domain = pve},                                    -- Perfect POINT-BLANK SNIPE, Vateshran
[558] = {use = StamDD, domain = pvp},                                    -- Vateshran SwordBoard - Void Bash
[564] = {use = StamDD, domain = pvp},                                    -- Vateshran SwordBoard - Perfect Void Bash
 
 
      -- HEALER LEGENDARY WEAPONS
 
[368] = {use = Healer, domain = pve},                                    -- Asylum Heilstab / Timeless blessing
[362] = {use = Healer, domain = pve},                                    -- Asylum Heilstab -perfekt- / Timeless blessing
[318] = {use = Healer, domain = pve},                                    -- Meister Heilstab
[533] = {use = Healer, domain = pve},                                    -- Perfekter Meister Heilstab
--101
--                                                                       -- Blackrose Heilstab / Schutz des Pflegers 2/2u
--                                                                       -- Perfekter Blackrose Heilstab / Schutz des Pflegers 2/2u
--102
[562] = {use = Healer},                                                  -- Vateshran Heilstab - Force Overflow
[568] = {use = Healer},                                                  -- Vateshran Heilstab - Perfect Force Overflow
 
 
      -- MAGICKA LEGENDARY WEAPONS
 
[373] = {use = MagickaDD, domain = pve},                                 -- Mahlstrom Destro / crushing wall
[526] = {use = MagickaDD, domain = pve},                                 -- perfect Mahlstrom Destro / perfect crushing wall
[374] = {use = MagickaDD, domain = pvp},                                 -- Mahlstrom Heilstab
[527] = {use = MagickaDD, domain = pvp},                                 -- Perfekter Mahlstrom Heilstab
[317] = {use = MagickaDD, domain = pvp},                                 -- Meister Eisstab / Destro
[532] = {use = MagickaDD, domain = pvp},                                 -- Perfekter Meister Eisstab / Destro
--101
[416] = {use = MagickaDD, use2 = Healer, domain = pvp},                  -- Blackrose Heilstab / Schutz des Pflegers 2/2u
[428] = {use = MagickaDD, use2 = Healer, domain = pvp},                  -- Perfekter Blackrose Heilstab / Schutz des Pflegers 2/2u
 


      -- STAMINA MONSTERSET 
 
[397] = {use = StamDD, use2 = MagickaDD, domain = pvp},                  -- Balorgh 2/2
[163] = {use = StamDD, use2 = Tank, use3 = MagickaDD, domain = pvp, domain2 = pve, domain3 = pvp},  -- Blutbrut 3/3
[266] = {use = StamDD},                                                  -- Kra’gh
[459] = {use = StamDD},                                                  -- Maarselok 
[183] = {use = StamDD, domain = pvp},                                    -- Molag Kena v102
[270] = {use = StamDD, use2 = MagickaDD, domain = pve},                  -- Schleimkopf 2/2
[279] = {use = StamDD, domain = pve},                                    -- Selene
[275] = {use = StamDD, domain = pve},                                    -- Stormfist
[278] = {use = StamDD, domain = pvp},                                    -- Trollkönig
[257] = {use = StamDD},                                                  -- Velidreth
--101
--                                                                       -- Maechtiger Chudan
--102
[458] = {use = StamDD, domain = pve},                                    -- Grundwulf
[342] = {use = StamDD, use2 = MagickaDD},                                -- Domihaus 2/2

 
 
      -- TANK MONSTERSETS 
 
--                                                                       -- Blutbrut
[341] = {use = Tank, use2 = Healer, use3 = MagickaDD, domain = pve, domain3 = pvp},   -- Erdbluter 3/3
[164] = {use = Tank, domain = pve},                                      -- Hochwaerter
[256] = {use = Tank, use2 = MagickaDD, use3 = StamDD, domain = pve, domain3 = pvp},   -- Maechtiger Chudan 3/3u
[267] = {use = Tank, use2 = MagickaDD},                                  -- Schwarmmutter 2/2 v102
[349] = {use = Tank, domain = pve},                                      -- Thurvokun
[398] = {use = Tank, domain = pve},                                      -- Vykosa
--101
[276] = {use = Tank, domain = pve},                                      -- Bebenschuppe
[265] = {use = Tank, domain = pve},                                      -- Schattenriss
--102
[535] = {use = Tank, domain = pve},                                      -- Fuerstin Dorn
[577] = {use = Tank, use2 = Healer, domain = pve, domain2 = pve},        -- Encratis Behemoth 2/2
[432] = {use = Tank, domain = pvp},                                      -- Steinwahrer
[248] = {use = Tank, domain = pvp},                                      -- Muskeln des Vorboten
 
 
      -- HEALER MONSTERSETS
 
[167] = {use = Healer},                                                  -- Bogdan/Nachtflamme
--                                                                       -- Erdbluter
[268] = {use = Healer, domain = pve},                                    -- Wachposten von Rkugamz
--101
[436] = {use = Healer},                                                  -- Sinfonie der Klingen
--102
[269] = {use = Healer, domain = pve},                                    -- Wuergedorn
--                                                                       -- Encratis Behemoth 2/2
 
 
      -- MAGICKA MONSTERSET 
 
--                                                                       -- Balorgh
--                                                                       -- Blutbrut
[274] = {use = MagickaDD, domain = pve},                                 -- Eisherz
--                                                                       -- Erdbluter
[280] = {use = MagickaDD, domain = pve},                                 -- Grothdarr
[273] = {use = MagickaDD, domain = pve},                                 -- Ilambris
--                                                                       -- Maechtiger Chudan
--                                                                       -- Schleimkopf 2/2
[170] = {use = MagickaDD, domain = pve},                                 -- Schlund des Infernalen
[169] = {use = MagickaDD},                                               -- Valkyn Skoria
[350] = {use = MagickaDD, domain = pve},                                  -- Zaan
--101
[479] = {use = MagickaDD, domain = pvp},                                 -- Kjalnars Albtraum
[168] = {use = MagickaDD},                                               -- Nerien'eth
--102
--                                                                       -- Schwarmmutter 2/2
--                                                                       -- Domihaus 2/2

 
      -- STAMINA MYTHIC ITEMS
      
[505] = {use = StamDD, domain = pvp},                                    -- Ring: Torc of Tonal Constancy
[503] = {use = StamDD, domain = pvp},                                    -- Ring: Ring der Wilden Jagd
--102
[575] = {use = StamDD, use2 = MagickaDD, domain = pve, domain2 = pve},   -- Ring des Fahlen Ordens 2/2


      -- MAGICKA MYTHIC ITEMS

[519] = {use = MagickaDD, domain = pvp},                                 -- Schuhe: Schneetreter
--102
--                                                                       -- Ring des Fahlen Ordens 2/2


      -- TANK MYTHIC ITEMS

[521] = {use = Tank, domain = pve},                                      -- Umarmung des Blutfuersten
--102
[520] = {use = Tank, domain = pvp}                                       -- MALACATHS BAND DER BRUTALITAET
-- LAST NO COMMA

      
  }  
}


local function SetTableEntryToNil(id, type) 

    if MetaCheck.MetaItemSets[id].use == type then
        MetaCheck.MetaItemSets[id].use = nil           
      end
       
    if MetaCheck.MetaItemSets[id].use2 == type then  
        MetaCheck.MetaItemSets[id].use2 = nil
      end
    if MetaCheck.MetaItemSets[id].use3 == type then  
        MetaCheck.MetaItemSets[id].use3 = nil 
      end
      
end


--decide weapon/role combinations:

local function WeaponCheckRole(topSubsection, itemLink, equipped)   

   if weaponorarmor == ITEMTYPE_ARMOR or MetaCheck.MetaItemSets[id] == nil then return end

   if MGcurrentItemWeaponType == 9 then   -- Heal Staff
       SetTableEntryToNil(id, StamDD)
       SetTableEntryToNil(id, Tank)

     if MetaCheck.MetaItemSets[id].use ~= MagickaDD and
         MetaCheck.MetaItemSets[id].use2 ~= MagickaDD and 
         MetaCheck.MetaItemSets[id].use3 ~= MagickaDD then
          
         SetTableEntryToNil(id, MagickaDD)
           
       end
       
     if  MetaCheck.MetaItemSets[id].use ~= Healer and
         MetaCheck.MetaItemSets[id].use2 ~= Healer and
         MetaCheck.MetaItemSets[id].use3 ~= Healer then  
        
         SetTableEntryToNil(id, Healer)
         
       end

  return end
  
  if MGcurrentItemWeaponType == 15 then  -- Lightning Staff
      SetTableEntryToNil(id, StamDD)
      
      if MetaCheck.MetaItemSets[id].use ~= MagickaDD and
         MetaCheck.MetaItemSets[id].use2 ~= MagickaDD and 
         MetaCheck.MetaItemSets[id].use3 ~= MagickaDD then
          
         SetTableEntryToNil(id, MagickaDD)
           
       end
       
     if  MetaCheck.MetaItemSets[id].use ~= Healer and
         MetaCheck.MetaItemSets[id].use2 ~= Healer and
         MetaCheck.MetaItemSets[id].use3 ~= Healer then  
        
         SetTableEntryToNil(id, Healer)
         
       end
       
     if MetaCheck.MetaItemSets[id].use ~= Tank and 
       MetaCheck.MetaItemSets[id].use2 ~= Tank and 
       MetaCheck.MetaItemSets[id].use3 ~= Tank then
         
       SetTableEntryToNil(id, Tank)
       
    end
    
 return end

  if MGcurrentItemWeaponType == 12 then    -- Fire Staff
      SetTableEntryToNil(id, StamDD)
      SetTableEntryToNil(id, Tank)
      SetTableEntryToNil(id, Healer)

    if MetaCheck.MetaItemSets[id].use ~= MagickaDD and 
        MetaCheck.MetaItemSets[id].use2 ~= MagickaDD and 
        MetaCheck.MetaItemSets[id].use3 ~= MagickaDD then
         
        SetTableEntryToNil(id, MagickaDD)
        
      end

  return end
  
  if MGcurrentItemWeaponType == 13 then    --frost staff
      SetTableEntryToNil(id, StamDD)
      SetTableEntryToNil(id, Healer)
      
     if MetaCheck.MetaItemSets[id].use ~= MagickaDD and
         MetaCheck.MetaItemSets[id].use2 ~= MagickaDD and 
         MetaCheck.MetaItemSets[id].use3 ~= MagickaDD then
          
         SetTableEntryToNil(id, MagickaDD)
           
       end
       
     if MetaCheck.MetaItemSets[id].use ~= Tank and 
       MetaCheck.MetaItemSets[id].use2 ~= Tank and 
       MetaCheck.MetaItemSets[id].use3 ~= Tank then
         
       SetTableEntryToNil(id, Tank)
       
    end
    
 return end      

  if MGcurrentItemWeaponType == 1 or MGcurrentItemWeaponType == 11 or   -- OneHand or Hammer
     MGcurrentItemWeaponType == 2 or MGcurrentItemWeaponType == 3 then         
      SetTableEntryToNil(id, Healer)

    if MetaCheck.MetaItemSets[id].use ~= MagickaDD and 
       MetaCheck.MetaItemSets[id].use2 ~= MagickaDD and 
       MetaCheck.MetaItemSets[id].use3 ~= MagickaDD then  
       
       SetTableEntryToNil(id, MagickaDD) 
     end
       
    if MetaCheck.MetaItemSets[id].use ~= StamDD and 
       MetaCheck.MetaItemSets[id].use2 ~= StamDD and 
       MetaCheck.MetaItemSets[id].use3 ~= StamDD then 
        
       SetTableEntryToNil(id, StamDD)
       
     end
      
    if MetaCheck.MetaItemSets[id].use ~= Tank and 
       MetaCheck.MetaItemSets[id].use2 ~= Tank and 
       MetaCheck.MetaItemSets[id].use3 ~= Tank then
         
       SetTableEntryToNil(id, Tank)
       
    end
   
  return end

  if MGcurrentItemWeaponType == 8 or MGcurrentItemWeaponType == 4 or 
     MGcurrentItemWeaponType == 5 or MGcurrentItemWeaponType == 6 then    -- Bow or Twohand
      SetTableEntryToNil(id, Healer)
      SetTableEntryToNil(id, MagickaDD)
      SetTableEntryToNil(id, Tank) 

    if MetaCheck.MetaItemSets[id].use ~= StamDD and 
       MetaCheck.MetaItemSets[id].use2 ~= StamDD and 
       MetaCheck.MetaItemSets[id].use3 ~= StamDD then
         
       SetTableEntryToNil(id, StamDD)  
          
    end       

  return end

  if MGcurrentItemWeaponType == 14 then    -- Shield
     SetTableEntryToNil(id, Healer)
     SetTableEntryToNil(id, MagickaDD)
          
   if MetaCheck.MetaItemSets[id].use ~= StamDD and 
      MetaCheck.MetaItemSets[id].use2 ~= StamDD and 
      MetaCheck.MetaItemSets[id].use3 ~= StamDD then  
      
      SetTableEntryToNil(id, StamDD) 
        
   end
       
   if MetaCheck.MetaItemSets[id].use ~= Tank and 
      MetaCheck.MetaItemSets[id].use2 ~= Tank and 
      MetaCheck.MetaItemSets[id].use3 ~= Tank then
      
      SetTableEntryToNil(id, Tank)
   end
   
  return end

end




local function AddUselessWeapon(topSubsection, itemLink, equipped)

	topSubsection:AddVerticalPadding(14)
    topSubsection:AddLine(zo_iconTextFormat("esoUI/Art/restyle/outfitslot_mainhand_remove.dds", 63, 63))
     
end


local function AddGearInfoRole(topSubsection, itemLink, equipped)
    if MetaCheck.MetaItemSets[id].use == nil then return end

    local scale1 = SizeTable[MetaCheck.MetaItemSets[id].use].width
    local scale2 = SizeTable[MetaCheck.MetaItemSets[id].use].height   
	topSubsection:AddVerticalPadding(18) --old14
    topSubsection:AddLine(zo_iconTextFormat(MetaCheck.MetaItemSets[id].use, scale1, scale2))
     
end
     
    
local function AddGearInfo2ndRole(topSubsection, itemLink, equipped)
    if MetaCheck.MetaItemSets[id].use2 == nil then return end
    
    local scale1 = SizeTable[MetaCheck.MetaItemSets[id].use2].width
    local scale2 = SizeTable[MetaCheck.MetaItemSets[id].use2].height
	topSubsection:AddVerticalPadding(18) --old14
    topSubsection:AddLine(zo_iconTextFormat(MetaCheck.MetaItemSets[id].use2, scale1, scale2))
      
end    
    
  
  local function AddGearInfo3rdRole(topSubsection, itemLink, equipped)
    if MetaCheck.MetaItemSets[id].use3 == nil then return end
    
    local scale1 = SizeTable[MetaCheck.MetaItemSets[id].use3].width
    local scale2 = SizeTable[MetaCheck.MetaItemSets[id].use3].height
	topSubsection:AddVerticalPadding(18) --old14
    topSubsection:AddLine(zo_iconTextFormat(MetaCheck.MetaItemSets[id].use3, scale1, scale2))
      
end    
     
     
local function AddGearInfoDomain(topSubsection, itemLink, equipped)
    if MetaCheck.MetaItemSets[id].domain == nil or MetaCheck.MetaItemSets[id].use == nil then return end 
    
    local zo_iconcustomFormat = zo_iconTextFormat
	topSubsection:AddVerticalPadding(-44)
    topSubsection:AddLine(zo_iconcustomFormat("space", 65, 65, zo_iconcustomFormat(MetaCheck.MetaItemSets[id].domain, 20, 20)))
     
end
     
     
local function AddGearInfoDomain2ndRole(topSubsection, itemLink, equipped)
    if MetaCheck.MetaItemSets[id].domain2 == nil or MetaCheck.MetaItemSets[id].use2 == nil then return end

	local zo_iconcustomFormat = zo_iconTextFormat
	topSubsection:AddVerticalPadding(-44)
    topSubsection:AddLine(zo_iconcustomFormat("space", 65, 65, zo_iconcustomFormat(MetaCheck.MetaItemSets[id].domain2, 20, 20)))
     
end


local function AddGearInfoDomain3rdRole(topSubsection, itemLink, equipped)
    if MetaCheck.MetaItemSets[id].domain3 == nil or MetaCheck.MetaItemSets[id].use3 == nil then return end

	local zo_iconcustomFormat = zo_iconTextFormat
	topSubsection:AddVerticalPadding(-44)
    topSubsection:AddLine(zo_iconcustomFormat("space", 65, 65, zo_iconcustomFormat(MetaCheck.MetaItemSets[id].domain3, 20, 20)))
     
end


local function AddGearInfoLevel1row1(topSubsection, itemLink, equipped) --pos1 
    if MetaCheck.MetaItemSets[id].domain ~= nil or MetaCheck.MetaItemSets[id].use == nil  then return end 

    local zo_iconcustomFormat = zo_iconTextFormat
	topSubsection:AddVerticalPadding(-35)
    topSubsection:AddLine(zo_iconcustomFormat("space", 85, 65, zo_iconcustomFormat("esoUI/Art/capturemeter/capturemeter_downarrow.dds", 33, 33)))
     
end


local function AddGearInfoLevel1row2(topSubsection, itemLink, equipped)
    if MetaCheck.MetaItemSets[id].domain ~= nil or MetaCheck.MetaItemSets[id].use ~= nil  then return end 

    local zo_iconcustomFormat = zo_iconTextFormat
	topSubsection:AddVerticalPadding(-35)
    topSubsection:AddLine(zo_iconcustomFormat("space", 85, 65, zo_iconcustomFormat("esoUI/Art/capturemeter/capturemeter_downarrow.dds", 33, 33)))
     
end


local function AddGearInfoLevel2row1(topSubsection, itemLink, equipped) -- pos2 reihe 1
    if MetaCheck.MetaItemSets[id].domain == nil or MetaCheck.MetaItemSets[id].use == nil then return end
  
    local zo_iconcustomFormat = zo_iconTextFormat
	topSubsection:AddVerticalPadding(-26)
    topSubsection:AddLine(zo_iconcustomFormat("space", 125, 65, zo_iconcustomFormat("esoUI/Art/capturemeter/capturemeter_downarrow.dds", 33, 33)))
     
end


local function AddGearInfoLevel2row2(topSubsection, itemLink, equipped)
    if MetaCheck.MetaItemSets[id].domain == nil or MetaCheck.MetaItemSets[id].use ~= nil then return end
 --d(MetaCheck.MetaItemSets[id].use)
    local zo_iconcustomFormat = zo_iconTextFormat
	topSubsection:AddVerticalPadding(-26)
    topSubsection:AddLine(zo_iconcustomFormat("space", 125, 65, zo_iconcustomFormat("esoUI/Art/capturemeter/capturemeter_downarrow.dds", 33, 33)))
     
end


local function AddGearBadInfoRole(topSubsection, itemLink, equipped)
	
	topSubsection:AddVerticalPadding(14)
    topSubsection:AddLine(zo_iconTextFormat("EsoUI/Art/buttons/minus_up.dds", 54, 54))	
           
end


local function AddGearBadInfoLowCP(topSubsection, itemLink, equipped)
	
    topSubsection:AddVerticalPadding(14)
    topSubsection:AddLine(zo_iconTextFormat("esoUI/Art/buttons/scrollbox_downarrow_up.dds", 44, 34))	
           
end


local function TooltipHook(topSubsection, method, linkFunc, itemLink, equipped) 

    local useBackup = nil
    local use2Backup = nil
    local use3Backup = nil

    local origMethod = topSubsection[method] -- backup the original
    topSubsection[method] = function(self, ...)
    local itemLink = linkFunc(...)     
    origMethod(self, ...) -- call the original    
    
    hasSet, setName, _,_,_, id = GetItemLinkSetInfo(itemLink) -- get setID    
    local requiredVeteranRank = GetItemLinkRequiredVeteranRank(itemLink) -- get CP level    
    MGcurrentItemWeaponType = GetItemLinkWeaponType(itemLink)     
    weaponorarmor = GetItemLinkItemType(itemLink)      
    
 if weaponorarmor ~= ITEMTYPE_ARMOR and weaponorarmor ~= ITEMTYPE_WEAPON then return end  -- only consider gear
      
 if MetaCheck.MetaItemSets[id] ~= nil then
   if MetaCheck.MetaItemSets[id].use ~= nil then
      useBackup = MetaCheck.MetaItemSets[id].use 
   else useBackup = nil 
   end
   
   if MetaCheck.MetaItemSets[id].use2 ~= nil then 
    use2Backup =  MetaCheck.MetaItemSets[id].use2  
   else use2Backup = nil 
   end
   
   if MetaCheck.MetaItemSets[id].use3 ~= nil then 
      use3Backup = MetaCheck.MetaItemSets[id].use3 
   else use3Backup = nil 
   end
 end                            
     
    if id == 0 then return  end   -- Dont show on non-gearset pieces        
   
    if weaponorarmor ~= ITEMTYPE_ARMOR and MetaCheck.MetaItemSets[id] ~= nil then
       WeaponCheckRole(self)
    end
   
     
    if MetaCheck.MetaItemSets[id] ~= nil and 
       MetaCheck.MetaItemSets[id].use == nil and 
       MetaCheck.MetaItemSets[id].use2 == nil and 
       MetaCheck.MetaItemSets[id].use3 == nil then
      
       AddUselessWeapon(self)
       --d("useless weapon", MGcurrentItemWeaponType, id, useBackup, use2Backup, use3Backup)
     
      if useBackup ~= nil then 
         MetaCheck.MetaItemSets[id].use = useBackup             
      end

      if use2Backup ~= nil then 
         MetaCheck.MetaItemSets[id].use2 = use2Backup           
      end

      if use3Backup ~= nil then 
         MetaCheck.MetaItemSets[id].use3 = use3Backup      
      end
      
    return end
    

    if MetaCheck.MetaItemSets[id] ~= nil and requiredVeteranRank == 160 then 
      
       --d("max cp", id)                                                              --enable to post ID of included Sets in chat
       AddGearInfoRole(self)    
       AddGearInfoDomain(self)
       AddGearInfo2ndRole(self)
       AddGearInfoDomain2ndRole(self)
       AddGearInfo3rdRole(self)
       AddGearInfoDomain3rdRole(self)
              
       if useBackup ~= nil then 
          MetaCheck.MetaItemSets[id].use = useBackup              
       end

       if use2Backup ~= nil then 
          MetaCheck.MetaItemSets[id].use2 = use2Backup            
       end

       if use3Backup ~= nil then 
          MetaCheck.MetaItemSets[id].use3 = use3Backup              
       end      
               
          
    else if MetaCheck.MetaItemSets[id] ~= nil and requiredVeteranRank < 160 then 
      
            --d("nicht max cp", id)
            AddGearInfoRole(self)         
            AddGearInfoDomain(self)
            AddGearInfoLevel1row1(self)
            AddGearInfoLevel2row1(self)  
            AddGearInfo2ndRole(self)
            AddGearInfoDomain2ndRole(self)
            AddGearInfoLevel1row2(self)
            AddGearInfoLevel2row2(self)
            AddGearInfo3rdRole(self)
            AddGearInfoDomain3rdRole(self)
      
            if useBackup ~= nil then 
               MetaCheck.MetaItemSets[id].use = useBackup            
            end

            if use2Backup ~= nil then 
               MetaCheck.MetaItemSets[id].use2 = use2Backup          
            end

            if use3Backup ~= nil then 
               MetaCheck.MetaItemSets[id].use3 = use3Backup 
            end
               
                
   
    else if MetaCheck.MetaItemSets[id] == nil and requiredVeteranRank == 160 then 
      
            AddGearBadInfoRole(self)      
            --d("nicht auf liste", id)                                                        --enable to post ID of not included Sets in chat
    
    else if MetaCheck.MetaItemSets[id] == nil and requiredVeteranRank < 160  then 
           
            AddGearBadInfoLowCP(self)  
            --d("nicht auf liste, und low", id)
      
      end
     end
    end
   end
  end 
 end    
    
    
local function ReturnItemLink(itemLink)
    
    return itemLink
    
end   
     
     
local function OnAddOnLoaded(eventCode, addonName)
    if addonName:find("^ZO_") then return end
      
    TooltipHook(ItemTooltip, "SetWornItem", function(equipSlot) -- to work on equipped gear
			isEquippedItem = true
			return GetItemLink(BAG_WORN, equipSlot) end, true)			
			
      EVENT_MANAGER:UnregisterForEvent("MetaCheck", eventCode)
    
      TooltipHook(ItemTooltip, "SetBagItem", GetItemLink)  
      TooltipHook(ItemTooltip, "SetTradeItem", GetTradeItemLink)
      TooltipHook(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
      TooltipHook(ItemTooltip, "SetStoreItem", GetStoreItemLink)
      TooltipHook(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
      TooltipHook(ItemTooltip, "SetLootItem", GetLootItemLink)
      TooltipHook(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
      TooltipHook(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
      TooltipHook(ItemTooltip, "SetLink", ReturnItemLink)
     
      TooltipHook(PopupTooltip, "SetLink", ReturnItemLink)     
     
end
    
    
EVENT_MANAGER:RegisterForEvent("MetaCheck", EVENT_ADD_ON_LOADED, OnAddOnLoaded)

-------------------------------------------------------------------------------
-- CritPercent's license:
-------------------------------------------------------------------------------
--
-- Copyright (c) 2015 Ales Machat (Garkin)
--
-- Permission is hereby granted, free of charge, to any person
-- obtaining a copy of this software and associated documentation
-- files (the "Software"), to deal in the Software without
-- restriction, including without limitation the rights to use,
-- copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following
-- conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
-- OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
--
-------------------------------------------------------------------------------