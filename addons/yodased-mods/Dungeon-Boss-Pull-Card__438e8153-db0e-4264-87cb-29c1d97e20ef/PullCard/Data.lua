-- PullCard Base-Game Core Dataset
-- 24 real non-DLC ESO group dungeons. Main/mechanic-heavy bosses prioritized.
-- No invented dungeon names. Add trivial/optional minibosses after live unit-name capture.
-- Source basis: ESO-Hub achievements/zone pages; Xynode All About Mechanics; Alcast guides.

PullCardData = PullCardData or {}
PullCardData.bosses = PullCardData.bosses or {}
PullCardData.dungeons = PullCardData.dungeons or {}

local function AddBoss(dungeon, name, data)
    local key = name
    if PullCardData.bosses[key] then
        key = string.format("%s (%s)", name, dungeon)
        data.aliases = data.aliases or {}

        local hasBaseAlias = false
        for _, alias in ipairs(data.aliases) do
            if alias == name then
                hasBaseAlias = true
                break
            end
        end
        if not hasBaseAlias then
            table.insert(data.aliases, name)
        end
    end

    data.dungeon = dungeon
    data.title = data.title or name
    data.aliases = data.aliases or {}
    PullCardData.bosses[key] = data
    PullCardData.dungeons[dungeon] = PullCardData.dungeons[dungeon] or { bosses = {} }
    table.insert(PullCardData.dungeons[dungeon].bosses, key)
end


-- ========================================================================
-- FUNGAL GROTTO I
-- ========================================================================
AddBoss("Fungal Grotto I", "Tazkad the Packmaster", {
    everyone = "Interrupt Agony; stay behind the boss and clear Durzogs/goblins.",
    tank = "Face Tazkad away; hold adds with boss and interrupt.",
    healer = "Watch tank during Frenzy of Blows.",
    dps = "Interrupt and cleave adds.",
    tldr = "[Tazkad] Interrupt Agony; tank face away; clear adds.",
    tags = { "interrupt", "adds", "frontal" },
})
AddBoss("Fungal Grotto I", "War Chief Ozozai", {
    aliases = { "Warchief Ozozai" },
    everyone = "Kill the two adds first. Red beam/AoE target moves away from group; leave the low-health roar AoE.",
    tank = "Block Haymaker and face boss away.",
    healer = "Top group after leap/roar.",
    dps = "Adds first; spread red beam.",
    tldr = "[Ozozai] Adds first. Red beam = spread. Block heavy; leave roar AoE.",
    tags = { "spread", "adds", "block" },
})
AddBoss("Fungal Grotto I", "Broodbirther", {
    everyone = "Stay behind boss and avoid frontal Shocking Rake.",
    tank = "Hold still and face away.",
    healer = "Heal incidental pull damage.",
    dps = "Kill adds then stay behind.",
    tldr = "[Broodbirther] Adds first; stay behind boss; avoid frontal rake.",
    tags = { "frontal", "adds" },
})
AddBoss("Fungal Grotto I", "Clatterclaw", {
    everyone = "Stack near boss and AoE the mudcrab swarm.",
    tank = "Hold boss steady; gather mudcrabs.",
    healer = "Keep group stacked.",
    dps = "Cleave mudcrabs while burning.",
    tldr = "[Clatterclaw] Stack and cleave the mudcrab swarm.",
    tags = { "adds", "stack" },
})
AddBoss("Fungal Grotto I", "Kra'gh the Dreugh King", {
    aliases = { "Kra’gh the Dreugh King", "Kragh the Dreugh King" },
    everyone = "Leave Lightning Field immediately; cleave mudcrabs.",
    tank = "Block Lunge/Storm Flurry and face boss away.",
    healer = "Be ready for Lightning Field damage.",
    dps = "Stay behind; leave Lightning Field.",
    tldr = "[Kra'gh] Leave Lightning Field. Tank block heavies; cleave mudcrabs.",
    tags = { "ground-aoe", "block", "adds" },
})

-- ========================================================================
-- FUNGAL GROTTO II
-- ========================================================================
AddBoss("Fungal Grotto II", "Mephala's Fang", {
    aliases = { "Mephala’s Fang" },
    everyone = "Kill healer adds first; drop poison away and avoid frontal poison spray.",
    tank = "Face spider away and block bite.",
    healer = "Prioritize poison DoTs.",
    dps = "Healers first; stay behind.",
    tldr = "[Mephala's Fang] Kill healers; drop poison away; avoid frontal spray.",
    tags = { "adds", "frontal", "ground-aoe" },
})
AddBoss("Fungal Grotto II", "Gamyne Bandu", {
    everyone = "Execution: all focus ONE shade to free chained player. Black tether between two players: run apart.",
    tank = "Block Ripper; keep boss stable.",
    healer = "Keep chained player alive.",
    dps = "Focus one shade; kill aspects.",
    tldr = "[Gamyne] Execution = focus ONE shade. Black tether = run apart.",
    tags = { "one-shot", "adds", "tether" },
})
AddBoss("Fungal Grotto II", "Ciirenas the Shepherd", {
    aliases = { "Ciirenas the Shepard" },
    everyone = "DO NOT KILL THE SPIDERS; dead spiders empower Ciirenas. Burn boss while tank holds spiders away.",
    tank = "Taunt spiders away and keep them alive.",
    healer = "Watch pheromone target.",
    dps = "Burn boss; do not cleave spiders.",
    tldr = "[Ciirenas] DO NOT KILL SPIDERS. Tank holds them away; burn boss.",
    tags = { "dont-kill", "adds" },
})
AddBoss("Fungal Grotto II", "Spawn of Mephala", {
    everyone = "Portaled player survives/kills spiders inside; outside group avoids tracking beam and boss explosion.",
    tank = "Hold boss stable.",
    healer = "Heal surface group through beam/explosion.",
    dps = "If portaled, survive spiders; otherwise burn.",
    tldr = "[Spawn] Portaled player survives spiders; outside kite beam and leave explosion.",
    tags = { "portal", "ground-aoe" },
})
AddBoss("Fungal Grotto II", "Reggr Dark-Dawn", {
    everyone = "He drains Magicka periodically; save recovery/potions until AFTER the drain. Leave his spin.",
    tank = "Block heavy; hold still.",
    healer = "Plan resources around drain.",
    dps = "Recover after drain; leave spin.",
    tldr = "[Reggr] Magicka drain first, recover AFTER. Leave spin; block heavy.",
    tags = { "resource-drain", "block" },
})
AddBoss("Fungal Grotto II", "Vila Theran", {
    everyone = "Stack to place Growing Corruption together, then move as a group. Use protective dome/strong heals for Channeled Shadow.",
    tank = "Keep corruption placement controlled.",
    healer = "Group tightly during channel.",
    dps = "Stack corruption drops; move together.",
    tldr = "[Vila] Stack corruption, move together; use dome/heals for Channeled Shadow.",
    tags = { "stack", "group-damage", "ground-aoe" },
})

-- ========================================================================
-- SPINDLECLUTCH I
-- ========================================================================
AddBoss("Spindleclutch I", "Swarm Mother", {
    everyone = "Stay fairly close so she does not leap around; move out of poison.",
    tank = "Back boss to wall and block Bite.",
    healer = "Clean poison damage.",
    dps = "Stay behind; cleave spiders.",
    tldr = "[Swarm Mother] Stay close; tank block heavy; move out of poison.",
    tags = { "block", "adds", "ground-aoe" },
})
AddBoss("Spindleclutch I", "Cerise the Widow-Maker", {
    everyone = "Interrupt Agony and break free from fear/stuns.",
    tank = "Control adds and block Assassinate.",
    healer = "Watch stunned players.",
    dps = "Interrupt and clear adds.",
    tldr = "[Cerise] Interrupt Agony; break free; control adds.",
    tags = { "interrupt", "break-free", "adds" },
})
AddBoss("Spindleclutch I", "The Whisperer", {
    everyone = "Web Pull drags group in: RUN OUT of the large explosion. Kill Storm Atronach immediately.",
    tank = "Keep boss stable; block heavy.",
    healer = "Burst-heal after pull/fear.",
    dps = "Atronach priority; leave explosion.",
    tldr = "[Whisperer] Pulled in = RUN OUT. Kill Storm Atronach immediately.",
    tags = { "one-shot", "adds", "ground-aoe" },
})

-- ========================================================================
-- SPINDLECLUTCH II
-- ========================================================================
AddBoss("Spindleclutch II", "Bloodspawn", {
    everyone = "Avoid cave-ins/ground AoEs and stay out of the frontal.",
    tank = "Face away and block heavies.",
    healer = "Watch cave-in damage.",
    dps = "Stay behind; move from falling rocks.",
    tldr = "[Bloodspawn] Tank face away; avoid cave-ins and ground AoE.",
    tags = { "ground-aoe", "frontal" },
})
AddBoss("Spindleclutch II", "Praxin Douare", {
    aliases = { "Praxin's Ghost", "Praxin’s Ghost" },
    everyone = "Kill summoned adds and avoid expanding/rotating ground hazards.",
    tank = "Control adds.",
    healer = "Heavy group damage during add phases.",
    dps = "Adds first.",
    tldr = "[Praxin] Kill adds first and avoid expanding ground hazards.",
    tags = { "adds", "ground-aoe" },
})
AddBoss("Spindleclutch II", "Vorenor Winterbourne", {
    everyone = "Do not kill innocent captives if doing Compassionate Hero; survive drain phases and burn boss.",
    tank = "Block and control boss.",
    healer = "Expect drain pressure.",
    dps = "Avoid captives while burning.",
    tldr = "[Vorenor] Keep captives alive; burn boss and survive drain phases.",
    tags = { "dont-kill", "group-damage" },
})

-- ========================================================================
-- THE BANISHED CELLS I
-- ========================================================================
AddBoss("The Banished Cells I", "Shadowrend", {
    everyone = "Avoid frontal/shadow attacks.",
    tank = "Face away and block heavies.",
    healer = "Watch tank.",
    dps = "Stay behind.",
    tldr = "[Shadowrend] Tank face away; block heavies; avoid shadow AoE.",
    tags = { "frontal", "block" },
})
AddBoss("The Banished Cells I", "High Kinlord Rilis", {
    everyone = "Kill healing orbs before they reach Rilis; handle banish/teleport mechanics quickly.",
    tank = "Reacquire after teleports; block.",
    healer = "Watch banished players.",
    dps = "Healing orbs are priority.",
    tldr = "[Rilis] Kill healing orbs before they reach boss; handle banish.",
    tags = { "heal-prevention", "adds", "teleport" },
})

-- ========================================================================
-- THE BANISHED CELLS II
-- ========================================================================
AddBoss("The Banished Cells II", "Maw of the Infernal", {
    everyone = "Avoid the large flame breath cone and ground fire.",
    tank = "Keep Maw faced away.",
    healer = "Watch flame-breath clips.",
    dps = "Stay behind.",
    tldr = "[Maw] Stay behind; avoid flame breath and fire.",
    tags = { "frontal", "ground-aoe" },
})
AddBoss("The Banished Cells II", "Keeper Imiril", {
    everyone = "Kill each portal add wave before Imiril returns; avoid bouncing blue orbs and return burst.",
    tank = "Control each add wave.",
    healer = "Prepare for return burst.",
    dps = "Adds are priority.",
    tldr = "[Imiril] Kill portal adds FAST; avoid blue orbs and return burst.",
    tags = { "adds", "phase", "ground-aoe" },
})
AddBoss("The Banished Cells II", "High Kinlord Rilis", {
    everyone = "Kill healing Feasts immediately. HM: keep 3+ Daedroth alive when Rilis dies.",
    tank = "Hold Daedroth off group; manage teleports.",
    healer = "HM tank pressure rises with Daedroth count.",
    dps = "Feasts first; HM do not overkill Daedroth.",
    tldr = "[Rilis II] Kill healing orbs. HM: keep 3+ Daedroth alive.",
    tags = { "heal-prevention", "adds", "hardmode" },
})

-- ========================================================================
-- DARKSHADE CAVERNS I
-- ========================================================================
AddBoss("Darkshade Caverns I", "Foreman Llothan", {
    everyone = "Avoid poison/fire ground effects and interrupt dangerous channels.",
    tank = "Hold boss/adds together.",
    healer = "Watch poison pressure.",
    dps = "Interrupt and cleave adds.",
    tldr = "[Llothan] Interrupt; avoid ground effects; cleave adds.",
    tags = { "interrupt", "adds", "ground-aoe" },
})
AddBoss("Darkshade Caverns I", "The Hive Lord", {
    everyone = "Interrupt Scrib channels; burn the boss's low-health damage shield quickly.",
    tank = "Face away and control Scribs.",
    healer = "Heavy healing while shield is active.",
    dps = "Interrupt Scribs; burst shield.",
    tldr = "[Hive Lord] Interrupt Scribs; burn the low-health shield fast.",
    tags = { "interrupt", "shield", "adds" },
})
AddBoss("Darkshade Caverns I", "Sentinel of Rkugamz", {
    everyone = "Avoid spinning/ground attacks and manage Dwemer adds.",
    tank = "Block heavy; control boss.",
    healer = "Watch group during spin.",
    dps = "Avoid AoE; cleave constructs.",
    tldr = "[Sentinel] Avoid spinning/ground AoEs; tank block heavies.",
    tags = { "ground-aoe", "block" },
})

-- ========================================================================
-- DARKSHADE CAVERNS II
-- ========================================================================
AddBoss("Darkshade Caverns II", "Transmuted Alit", {
    everyone = "Damage all three Alits evenly; dead Alits revive if the others live too long.",
    tank = "Taunt/stack all three.",
    healer = "Watch triple heavies.",
    dps = "Kill all three together.",
    tldr = "[Alits] Stack all 3 and kill together or they revive.",
    tags = { "linked-health", "adds" },
})
AddBoss("Darkshade Caverns II", "Grobull the Transmuted", {
    everyone = "Do NOT attack Grobull while shielded. Kill Netch adds until boss drops, then burst it.",
    tank = "Control large Netches.",
    healer = "Watch stuns/lightning.",
    dps = "Adds first; burst only when boss falls.",
    tldr = "[Grobull] Shielded boss = kill Netches. When it drops, BURN.",
    tags = { "reflect", "adds", "burst-window" },
})
AddBoss("Darkshade Caverns II", "The Engine Guardian", {
    everyone = "Green poison = stack/heal; fire = stay away from flamethrower; lightning = keep range and kill spheres.",
    tank = "Control adds/debuff; boss moves.",
    healer = "Poison is main heal check.",
    dps = "Respect phases and time burst.",
    tldr = "[Engine Guardian] Green=heal, Fire=stay away, Lightning=range/kill spheres.",
    tags = { "phase", "heal-check", "adds" },
})

-- ========================================================================
-- ELDEN HOLLOW I
-- ========================================================================
AddBoss("Elden Hollow I", "Chokethorn", {
    everyone = "Kill healing Stranglers when they channel; avoid poison.",
    tank = "Hold boss/adds steady.",
    healer = "Watch poison.",
    dps = "Healing Stranglers first.",
    tldr = "[Chokethorn] Kill healing Stranglers; avoid poison.",
    tags = { "heal-prevention", "adds" },
})
AddBoss("Elden Hollow I", "Canonreeve Oraneth", {
    everyone = "Dodge the targeted poison bolt; move out of grasping-hands ground stun.",
    tank = "Face away/block cleave.",
    healer = "Clean poison DoT.",
    dps = "Dodge bolt; leave hands.",
    tldr = "[Oraneth] Dodge poison bolt; leave grasping-hands AoE.",
    tags = { "dodge", "ground-aoe" },
})

-- ========================================================================
-- ELDEN HOLLOW II
-- ========================================================================
AddBoss("Elden Hollow II", "Dark Root", {
    everyone = "Control adds and avoid root/ground attacks.",
    tank = "Stack/control adds.",
    healer = "Watch add waves.",
    dps = "Adds first if they build.",
    tldr = "[Dark Root] Control adds and avoid root/ground AoEs.",
    tags = { "adds", "ground-aoe" },
})
AddBoss("Elden Hollow II", "Bogdan the Nightflame", {
    everyone = "Move from fire AoEs and control dangerous adds; stay healable during fire pressure.",
    tank = "Face away/control adds.",
    healer = "Strong group healing in fire phases.",
    dps = "Avoid fire; kill adds.",
    tldr = "[Bogdan] Avoid fire, control adds, stay healable.",
    tags = { "ground-aoe", "adds", "group-damage" },
})

-- ========================================================================
-- WAYREST SEWERS I
-- ========================================================================
AddBoss("Wayrest Sewers I", "Investigator Garron", {
    everyone = "Interrupt his channels, especially the immobilizing ice cast.",
    tank = "Interrupt and hold stable.",
    healer = "Watch immobilized targets.",
    dps = "Bash channels immediately.",
    tldr = "[Garron] INTERRUPT his channels, especially the ice cast.",
    tags = { "interrupt" },
})
AddBoss("Wayrest Sewers I", "Uulgarg the Hungry", {
    everyone = "Save Stamina to BREAK FREE from Fear; immediately block the heavy that often follows.",
    tank = "Keep central; block heavy.",
    healer = "Watch slow breaks.",
    dps = "Break fear; block; leave whirlwind.",
    tldr = "[Uulgarg] Save Stam: BREAK FEAR, then BLOCK the heavy.",
    tags = { "break-free", "block" },
})
AddBoss("Wayrest Sewers I", "Allene Pellingare", {
    everyone = "Block dangerous heavy/spin attacks and kill bats during disappearance phases.",
    tank = "Block heavies; reacquire after bats.",
    healer = "Watch Ambush targets.",
    dps = "Kill bats; block if ambushed.",
    tldr = "[Allene] Block heavy/spin; kill bats; block Ambush.",
    tags = { "block", "adds" },
})

-- ========================================================================
-- WAYREST SEWERS II
-- ========================================================================
AddBoss("Wayrest Sewers II", "Malubeth the Scourger", {
    everyone = "Grabbed/drained player: teammates use the two altar synergies to free them.",
    tank = "Keep boss controlled.",
    healer = "Keep grabbed player alive until freed.",
    dps = "Use altar synergies immediately.",
    tldr = "[Malubeth] Player grabbed = teammates use BOTH altar synergies.",
    tags = { "synergy", "rescue" },
})
AddBoss("Wayrest Sewers II", "Garron the Returned", {
    everyone = "Interrupt dangerous channels and kill summoned undead.",
    tank = "Control adds.",
    healer = "Watch add phases.",
    dps = "Interrupt and prioritize adds.",
    tldr = "[Garron Returned] Interrupt channels; kill undead adds.",
    tags = { "interrupt", "adds" },
})

-- ========================================================================
-- CRYPT OF HEARTS I
-- ========================================================================
AddBoss("Crypt of Hearts I", "Archmaster Siniel", {
    everyone = "Interrupt dangerous casts and clear summoned undead.",
    tank = "Control boss/adds.",
    healer = "Watch ranged pressure.",
    dps = "Interrupt and cleave.",
    tldr = "[Siniel] Interrupt casts and clear adds.",
    tags = { "interrupt", "adds" },
})
AddBoss("Crypt of Hearts I", "Death's Leviathan", {
    everyone = "Avoid frontal attacks/ground effects; block if targeted by a heavy.",
    tank = "Face away and block.",
    healer = "Watch tank.",
    dps = "Stay behind.",
    tldr = "[Leviathan] Tank face away/block; group avoid frontal/ground AoE.",
    tags = { "frontal", "block" },
})
AddBoss("Crypt of Hearts I", "Ilambris-Zaven & Ilambris-Athor", {
    aliases = { "Ilambris-Zaven and Ilambris-Athor" },
    everyone = "Control both brothers and avoid overlapping fire/lightning AoEs.",
    tank = "Keep fronts away from group.",
    healer = "Heal elemental overlap.",
    dps = "Focus called target.",
    tldr = "[Ilambris] Control both; avoid overlapping fire/lightning AoEs.",
    tags = { "dual-boss", "ground-aoe" },
})

-- ========================================================================
-- CRYPT OF HEARTS II
-- ========================================================================
AddBoss("Crypt of Hearts II", "Ruzozuzalpamaz", {
    everyone = "Clear spider adds and avoid poison/web ground effects.",
    tank = "Face away/gather adds.",
    healer = "Watch poison.",
    dps = "Cleave spiders.",
    tldr = "[Ruzozuzalpamaz] Cleave spiders; avoid poison/web AoE.",
    tags = { "adds", "ground-aoe" },
})
AddBoss("Crypt of Hearts II", "Ilambris Amalgam", {
    everyone = "Avoid elemental AoEs and block dangerous heavy attacks.",
    tank = "Face away/block.",
    healer = "Watch elemental burst.",
    dps = "Stay behind/avoid AoE.",
    tldr = "[Amalgam] Tank block; group avoid elemental AoEs.",
    tags = { "block", "ground-aoe" },
})
AddBoss("Crypt of Hearts II", "Nerien'eth", {
    aliases = { "Nerien’eth" },
    everyone = "Free chained players quickly and avoid lethal telegraphs.",
    tank = "Control/block boss.",
    healer = "Watch chained allies.",
    dps = "Free chained allies immediately.",
    tldr = "[Nerien'eth] Free chained players immediately; avoid lethal telegraphs.",
    tags = { "rescue", "one-shot" },
})

-- ========================================================================
-- CITY OF ASH I
-- ========================================================================
AddBoss("City of Ash I", "Rothariel Flameheart", {
    everyone = "Handle clones and avoid fire ground effects.",
    tank = "Keep boss controlled through clone phase.",
    healer = "Watch clone burst.",
    dps = "Deal with clones; avoid fire.",
    tldr = "[Rothariel] Handle clones and avoid fire AoEs.",
    tags = { "adds", "ground-aoe" },
})
AddBoss("City of Ash I", "Razor Master Erthas", {
    everyone = "Avoid fire circles and kill summoned Flame Atronachs.",
    tank = "Control boss/adds.",
    healer = "Watch fire pressure.",
    dps = "Atronachs first.",
    tldr = "[Erthas] Kill Flame Atronachs and avoid fire circles.",
    tags = { "adds", "ground-aoe" },
})

-- ========================================================================
-- CITY OF ASH II
-- ========================================================================
AddBoss("City of Ash II", "Ash Titan", {
    everyone = "Avoid fire breath/ground fire; kill dangerous adds.",
    tank = "Face Titan away and block.",
    healer = "Watch fire clips.",
    dps = "Stay behind/handle adds.",
    tldr = "[Ash Titan] Tank face away; avoid fire breath and ground fire.",
    tags = { "frontal", "ground-aoe", "adds" },
})
AddBoss("City of Ash II", "Valkyn Skoria", {
    everyone = "Platforms are destroyed during the fight; move together to safe platforms and avoid lava/fire.",
    tank = "Keep near safe platform space.",
    healer = "Keep group together on transitions.",
    dps = "Save mobility; don't get stranded.",
    tldr = "[Skoria] Platforms disappear—move together; stay out of lava/fire.",
    tags = { "platform", "movement", "ground-aoe" },
})

-- ========================================================================
-- ARX CORINIUM
-- ========================================================================
AddBoss("Arx Corinium", "Sliklenia the Songstress", {
    everyone = "Use the friendly snake's protection during the lethal song; DO NOT kill the protective snake.",
    tank = "Keep boss controlled away from safe snake.",
    healer = "Stack around protection during song.",
    dps = "Do not kill protective snake.",
    tldr = "[Sliklenia] DO NOT kill the friendly snake—use its protection during song.",
    tags = { "safe-zone", "dont-kill" },
})
AddBoss("Arx Corinium", "Sellistrix the Lamia Queen", {
    everyone = "Move out of lightning/electrified ground and stay healable.",
    tank = "Face away/block.",
    healer = "Watch lightning damage.",
    dps = "Avoid electrified ground.",
    tldr = "[Sellistrix] Avoid lightning water/AoEs; tank face away.",
    tags = { "ground-aoe", "block" },
})

-- ========================================================================
-- BLACKHEART HAVEN
-- ========================================================================
AddBoss("Blackheart Haven", "First Mate Wavecutter", {
    everyone = "INTERRUPT Shadow Volley immediately; it can wipe the group.",
    tank = "Hold still/gather harpies.",
    healer = "Watch if volley gets through.",
    dps = "Bash purple channel instantly.",
    tldr = "[Wavecutter] INTERRUPT purple Shadow Volley or group can wipe.",
    tags = { "interrupt", "one-shot" },
})
AddBoss("Blackheart Haven", "Roost Mother", {
    everyone = "Stand still while she marks fireball locations; move only when the fire comes down. Avoid breath.",
    tank = "Face away/follow teleports.",
    healer = "Heal raining-fire pressure.",
    dps = "Do not run while locations are marked.",
    tldr = "[Roost Mother] Stand still while fire is MARKED, then move when it lands.",
    tags = { "ground-aoe", "movement" },
})
AddBoss("Blackheart Haven", "Captain Blackheart", {
    everyone = "Random player becomes a skeleton and loses normal skills; stay grouped and heavy-attack while transformed. Kill skeleton adds.",
    tank = "Control adds; if transformed group temporarily loses taunt.",
    healer = "If transformed group must self-heal.",
    dps = "Cleave skeletons; transformed player heavy-attacks.",
    tldr = "[Blackheart] Skeleton curse disables skills—stay grouped and heavy attack.",
    tags = { "transformation", "adds" },
})

-- ========================================================================
-- BLESSED CRUCIBLE
-- ========================================================================
AddBoss("Blessed Crucible", "The Troll King", {
    everyone = "STAY CLOSE. Players too far away trigger his jump; avoid/block slam.",
    tank = "Keep centered/close.",
    healer = "Stay close.",
    dps = "Do not range-kite.",
    tldr = "[Troll King] STAY CLOSE or he jumps on ranged players.",
    tags = { "stay-close", "jump" },
})
AddBoss("Blessed Crucible", "Captain Thoran", {
    everyone = "Avoid flame runes/clouds; kill Flame Atronach to remove boss shield.",
    tank = "Stack adds/boss.",
    healer = "Watch fire.",
    dps = "Atronach first when shielded.",
    tldr = "[Thoran] Kill Flame Atronach to remove shield; avoid fire.",
    tags = { "adds", "shield", "ground-aoe" },
})
AddBoss("Blessed Crucible", "The Lava Queen", {
    everyone = "Flame Atronachs make boss immune—kill them immediately. Avoid lava/fire; block heavy if targeted.",
    tank = "Keep central/block.",
    healer = "Heavy fire pressure.",
    dps = "Atronachs absolute priority.",
    tldr = "[Lava Queen] Atronachs = boss IMMUNE. Kill them first; avoid lava.",
    tags = { "adds", "immune", "ground-aoe" },
})

-- ========================================================================
-- DIREFROST KEEP
-- ========================================================================
AddBoss("Direfrost Keep", "Iceheart", {
    everyone = "Leave spreading ice AoE and kill spawned Draugr.",
    tank = "Face away/block cone.",
    healer = "Watch ice spikes/adds.",
    dps = "Avoid ice; cleave Draugr.",
    tldr = "[Iceheart] Leave spreading ice; tank face away; cleave adds.",
    tags = { "ground-aoe", "adds", "frontal" },
})
AddBoss("Direfrost Keep", "Drodda of Icereach", {
    everyone = "SAVE STAMINA. Drain beam/lift = BREAK FREE immediately or Drodda heals massively.",
    tank = "Control summoned adds.",
    healer = "Watch drained player.",
    dps = "Do not waste Stam sprinting; break drain instantly.",
    tldr = "[Drodda] SAVE STAM. Drain beam = BREAK FREE immediately or she heals.",
    tags = { "break-free", "heal-prevention", "resource-check" },
})

-- ========================================================================
-- SELENE'S WEB
-- ========================================================================
AddBoss("Selene's Web", "Longclaw", {
    everyone = "DO NOT kill the green spirit panthers; tank holds them aside. Avoid poison/volley.",
    tank = "Hold panthers away.",
    healer = "Watch poison.",
    dps = "Burn boss; don't kill green cats.",
    tldr = "[Longclaw] DO NOT kill green spirit cats; tank holds them away.",
    tags = { "dont-kill", "adds" },
})
AddBoss("Selene's Web", "Selene", {
    everyone = "After web pull, leave swarm AoE. Humanoid phase: spectral bear frontal can one-shot; NEVER spin boss into group.",
    tank = "Face Selene away; sidestep/block bear without turning.",
    healer = "Heal pull/add pressure.",
    dps = "Stay behind; kill adds.",
    tldr = "[Selene] Tank NEVER spin boss. Bear frontal can one-shot; leave swarm AoE.",
    tags = { "one-shot", "frontal", "adds" },
})

-- ========================================================================
-- TEMPEST ISLAND
-- ========================================================================
AddBoss("Tempest Island", "Stormreeve Neidir", {
    everyone = "Stay reasonably close; avoid lightning tornadoes/ground AoEs and dangerous leap pressure.",
    tank = "Keep stable/block.",
    healer = "Watch lightning pressure.",
    dps = "Stay close enough; avoid AoEs.",
    tldr = "[Stormreeve] Stay fairly close; avoid lightning/tornadoes and block heavies.",
    tags = { "stay-close", "ground-aoe" },
})

-- ========================================================================
-- VOLENFELL
-- ========================================================================
AddBoss("Volenfell", "Tremorscale", {
    everyone = "Avoid frontal attacks and burrow/ground AoEs.",
    tank = "Face away/block.",
    healer = "Watch tank.",
    dps = "Stay behind.",
    tldr = "[Tremorscale] Tank face away; avoid burrow/ground AoE.",
    tags = { "frontal", "ground-aoe" },
})
AddBoss("Volenfell", "The Guardian Council", {
    aliases = { "Guardian Council" },
    everyone = "Three constructs have different elemental attacks; control all three, focus one, avoid overlapping AoEs.",
    tank = "Control all three.",
    healer = "Expect elemental overlap.",
    dps = "Focus called target.",
    tldr = "[Guardian Council] Control all 3, focus one, avoid overlapping elemental AoEs.",
    tags = { "multi-boss", "ground-aoe" },
})

-- ========================================================================
-- VAULTS OF MADNESS
-- ========================================================================
AddBoss("Vaults of Madness", "Grothdarr", {
    everyone = "Avoid fire ground effects and stay behind boss.",
    tank = "Face away/block.",
    healer = "Watch sustained fire.",
    dps = "Avoid fire.",
    tldr = "[Grothdarr] Avoid fire AoEs; tank face away.",
    tags = { "ground-aoe", "frontal" },
})
AddBoss("Vaults of Madness", "The Mad Architect", {
    everyone = "When protective bubble/safe zone appears, get inside for the lethal room-wide attack.",
    tank = "Keep boss near group.",
    healer = "Make sure everyone reaches protection.",
    dps = "Stop tunneling and get inside.",
    tldr = "[Mad Architect] Lethal room-wide attack = GET IN THE PROTECTIVE BUBBLE.",
    tags = { "safe-zone", "one-shot" },
})

PullCardData.baseGameDungeonOrder = {
    "Fungal Grotto I",
    "Fungal Grotto II",
    "Spindleclutch I",
    "Spindleclutch II",
    "The Banished Cells I",
    "The Banished Cells II",
    "Darkshade Caverns I",
    "Darkshade Caverns II",
    "Elden Hollow I",
    "Elden Hollow II",
    "Wayrest Sewers I",
    "Wayrest Sewers II",
    "Crypt of Hearts I",
    "Crypt of Hearts II",
    "City of Ash I",
    "City of Ash II",
    "Arx Corinium",
    "Blackheart Haven",
    "Blessed Crucible",
    "Direfrost Keep",
    "Selene's Web",
    "Tempest Island",
    "Volenfell",
    "Vaults of Madness",
}

-- Core entries: 64
-- Intentionally incomplete for trivial/optional minibosses; mechanics-first, no filler.
