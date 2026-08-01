--[[
/script for i=1,3 do for j=1,GetNumChampionDisciplineSkills(i) do local id = GetChampionSkillId(i, j) d(string.format("%d %s %d", j, GetChampionSkillName(id), id)) end end
GetChampionSkillName(GetChampionSkillId(disciplineIndex, skillIndex))

1 Discipline Artisan 279
2 Out of Sight 68
3 Friends in Low Places 76
4 Fade Away 84
5 Cutpurse's Art 90
6 Shadowstrike 80
7 Master Gatherer 78
8 Treasure Hunter 79
9 Steadfast Enchantment 75
10 Rationer 85
11 Liquid Efficiency 86
12 Angler's Instincts 89
13 Reel Technique 88
14 Homemaker 91
15 Wanderer 70
16 Plentiful Harvest 81
17 War Mount 82
18 Gifted Rider 92
19 Meticulous Disassembly 83
20 Inspiration Boost 72
21 Fortune's Favor 71
22 Infamous 77
23 Fleet Phantom 67
24 Gilded Fingers 74
25 Breakfall 69
26 Soul Reservoir 87
27 Steed's Blessing 66
28 Sustaining Shadows 65
29 Professional Upkeep 1

1 Precision 11
2 Fighting Finesse 12
3 Blessed 108
4 From the Brink 262
5 Enlivening Overflow 263
6 Hope Infusion 261
7 Salve of Renewal 260
8 Soothing Tide 24
9 Rejuvenator 9
10 Foresight 163
11 Cleansing Revival 29
12 Focused Mending 26
13 Swift Renewal 28
14 Piercing 10
15 Exploiter 277
16 Force of Nature 276
17 Master-at-Arms 264
18 Weapons Expert 259
19 Flawless Ritual 17
20 War Mage 21
21 Battle Mastery 18
22 Mighty 22
23 Deadly Aim 25
24 Biting Aura 23
25 Thaumaturge 27
26 Reaving Blows 30
27 Wrathful Strikes 8
28 Occult Overload 32
29 Backstabber 31
30 Tireless Discipline 6
31 Quick Recovery 20
32 Ironclad 265
33 Resilience 13
34 Preparation 14
35 Elemental Aegis 15
36 Hardy 16
37 Enduring Resolve 136
38 Reinforced 160
39 Riposte 162
40 Bulwark 159
41 Last Stand 161
42 Cutting Defense 33
43 Duelist's Rebuff 134
44 Unassailable 133
45 Eldritch Insight 99
46 Endless Endurance 5
47 Untamed Aggression 4
48 Arcane Supremacy 3

1 Sprinter 38
2 Hasty 42
3 Thrill of the Hunt 272
4 Celerity 270
5 Refreshing Stride 271
6 Hero's Vigor 113
7 Shield Master 63
8 Bastion 46
9 Tempered Soul 58
10 Survival Instincts 57
11 Spirit Mastery 56
12 Arcane Alacrity 61
13 Piercing Gaze 45
14 Bloody Renewal 48
15 Strategic Reserve 49
16 Mystic Tenacity 53
17 Relentlessness 274
18 Pain's Refuge 275
19 Sustained by Suffering 273
20 Siphoning Spells 47
21 Rousing Speed 62
22 Tireless Guardian 39
23 Savage Defense 40
24 Bashing Brutality 50
25 Nimble Protector 44
26 Soothing Shield 268
27 Bracing Anchor 267
28 Ward Master 266
29 On Guard 60
30 Fortification 43
31 Tumbling 37
32 Expert Evasion 51
33 Defiance 128
34 Slippery 52
35 Unchained 64
36 Juggernaut 59
37 Peace of Mind 54
38 Hardened 55
39 Rejuvenation 35
40 Fortified 34
41 Boundless Vitality 2
]]

-- For deleting with the delete defaults button
DynamicCP.oldDefaultPresetNames = {    
    ["Harvester (1095)"] = true,
    ["PVE (840)"] = true,
    ["Thief (960)"] = true,
    ["Fisher (675)"] = true,
    ["StamDPS (1320)"] = true,
    ["MagDPS (1170)"] = true,
    ["Healer (540)"] = true,
    ["StamDPS (840)"] = true,
    ["MagDPS (1320)"] = true,
    ["MagDPS (840)"] = true,
    ["Tank (570)"] = true,
    ["StamDPS (1770)"] = true,
    ["Tank (1200)"] = true,
    ["Healer (960)"] = true,
    ["MagDPS (1770)"] = true,
    ["Healer (1770)"] = true,
    ["MagDPS (1560)"] = true,
    ["StamDPS (1560)"] = true,
    ["StamDPS (540)"] = true,
    ["StamDPS (1170)"] = true,
    ["MagDPS (540)"] = true,
    ["Tank (870)"] = true,
    ["Tank (1710)"] = true,
    ["MagDPS (2100)"] = true,
    ["StamDPS (2100)"] = true,
    ["Healer (1260)"] = true,
    ["Healer (1626)"] = true,
    ["StamDPS (1446)"] = true,
    ["MagDPS (774)"] = true,
    ["Tank (615)"] = true,
    ["Tank (960)"] = true,
    ["MagDPS (1446)"] = true,
    ["Tank (1305)"] = true,
    ["StamDPS (1194)"] = true,
    ["Healer (999)"] = true,
    ["Tank (1521)"] = true,
    ["DPS/Healer (474)"] = true,
    ["StamDPS (774)"] = true,
    ["MagDPS (1194)"] = true,
    ["Fisher (675)"] = true,
    ["PVE (840)"] = true,
    ["Thief (960)"] = true,
    ["Harvester (1095)"] = true,
    ["Healer (1176)"] = true,
    ["Tank (1176)"] = true,
    ["Tank (849)"] = true,
    ["MagDPS (984)"] = true,
    ["StamDPS (1068)"] = true,
    ["Healer (774)"] = true,
    ["MagDPS (1068)"] = true,
    ["MagDPS (714)"] = true,
    ["StamDPS (984)"] = true,
    ["StamDPS (714)"] = true,
    ["DPS/Healer (414)"] = true,
    ["Tank (570)"] = true,
    ["Tank (1290)"] = true,
    ["StamDPS (1200)"] = true,
    ["StamDPS (420)"] = true,
    ["StamDPS (1560)"] = true,
    ["Healer (1140)"] = true,
    ["Tank (690)"] = true,
    ["MagDPS (990)"] = true,
    ["MagDPS (1200)"] = true,
    ["Healer (780)"] = true,
    ["MagDPS (1080)"] = true,
    ["MagDPS (1560)"] = true,
    ["MagDPS (720)"] = true,
    ["MagDPS (420)"] = true,
    ["Healer (510)"] = true,
    ["Tank (390)"] = true,
    ["StamDPS (720)"] = true,
    ["Tank (930)"] = true,
    ["StamDPS (990)"] = true,
    ["Healer (1350)"] = true,
    ["StamDPS (1080)"] = true,
}
