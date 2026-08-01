MechanicMentorTrials = MechanicMentorTrials or {}

-- v0.8.2 trial data injection.
-- Craglorn trials polished against Alcast references.
-- Early DLC trials injected as structured first-pass data for testing/refinement.

MechanicMentorTrials.Batches = {
    {
        version = "0.8.1",
        label = "Craglorn Trials",
        trials = { "Aetherian Archive", "Hel Ra Citadel", "Sanctum Ophidia" },
    },
    {
        version = "0.8.2",
        label = "Early DLC Trials",
        trials = { "Maw of Lorkhaj", "Halls of Fabrication", "Asylum Sanctorium", "Cloudrest" },
    },
    {
        version = "0.8.3",
        label = "Later DLC Trials",
        trials = { "Sunspire", "Kyne's Aegis", "Rockgrove", "Dreadsail Reef", "Sanity's Edge", "Lucent Citadel", "Ossein Cage" },
    },
}

local function mech(t, n, d, hm, roles)
    return { type = t, name = n, description = d, hardMode = hm == true, roles = roles }
end

local function pending(name, batchVersion, batchLabel)
    return {
        name = name,
        batchVersion = batchVersion,
        batchLabel = batchLabel,
        isTrial = true,
        bosses = {
            {
                name = "Trial Mechanics Data Pending",
                mechanics = {
                    mech("TRIAL FRAMEWORK", "Mechanics Pending", "This trial is registered in the Mechanic Mentor trial framework. Boss and veteran mechanics will be added in a later data pass."),
                },
            },
        },
    }
end

local AA = {
    name = "Aetherian Archive",
    batchVersion = "0.8.1",
    batchLabel = "Craglorn Trials",
    isTrial = true,
    bosses = {
        {
            name = "Lightning Storm Atronach",
            mechanics = {
                mech("POSITIONING", "Group Stack", "Tank faces the Atronach toward the bridge and away from group. Everyone stacks behind boss for healing and damage.", false, {"tank", "healer", "dps"}),
                mech("AOE / AVOID", "Impending Storm", "Boss arches back and releases a large lightning pulse. STACK, shield, heal, and block if needed until the storm ends.", false, {"healer", "dps"}),
                mech("AOE / AVOID", "Lightning Strikes", "Yellow circles target players during the fight. MOVE OUT of circles and avoid overlapping them on the group.", false, {"dps", "healer"}),
                mech("ADDS", "Storm Clones", "Boss splits into atronach copies. DPS kill assigned copies quickly before explosions overwhelm the group.", false, {"dps"}),
                mech("HEALER", "Barrier Timing", "Barrier or strong mitigation helps newer groups survive storm damage. HEALERS prepare burst healing for Impending Storm.", false, {"healer"}),
            },
        },
        {
            name = "Foundation Stone Atronach",
            mechanics = {
                mech("POSITIONING", "Face Away", "Tank keeps boss facing away from the group. DPS and healers stay behind boss and avoid the frontal cone.", false, {"tank", "dps", "healer"}),
                mech("HEAVY ATTACK", "Stone Heavy", "Heavy melee pressure on the tank. BLOCK heavy attacks and maintain boss control.", false, {"tank"}),
                mech("AOE / AVOID", "Big Quake", "Boss pounds the ground five times with heavy raid damage. STACK for healing and use mitigation or ultimates.", false, {"healer", "dps"}),
                mech("AOE / AVOID", "Frontal Cone", "Frontal cone can kill non-tanks. TANK faces boss away; everyone else stays behind or dodges out.", false, {"tank", "dps", "healer"}),
                mech("HEALER", "Solar Prison Rotation", "Groups often rotate mitigation ultimates through Big Quake. HEALERS call healing and mitigation timing.", false, {"healer"}),
            },
        },
        {
            name = "Varlariel",
            mechanics = {
                mech("DPS CHECK", "Mirror Images", "Varlariel splits into copies around the room. DPS kill assigned images quickly or the group takes lethal explosions.", false, {"dps"}),
                mech("TIMER", "Split Waves", "More images appear in later waves. Pre-assign players to positions and move immediately when the split begins.", false, {"dps"}),
                mech("POSITIONING", "Pillar Assignments", "Assign image positions before pull. After killing copies, return to boss quickly and continue burn.", false, {"dps"}),
                mech("AOE / AVOID", "Image Detonation", "Missed or late image kills cause heavy group damage. Shield, heal, and recover quickly if a detonation occurs.", false, {"healer", "dps"}),
                mech("DPS CHECK", "Final Split Skip", "If boss health is low, strong groups can ignore the last split and execute. Only do this if raid lead calls burn.", false, {"dps"}),
            },
        },
        {
            name = "The Mage",
            mechanics = {
                mech("DEBUFF", "Chain Lightning", "Lightning can jump through stacked players. Keep controlled spacing and heal through unavoidable raid damage.", false, {"healer", "dps"}),
                mech("AOE / AVOID", "Daedric Corruption Mines", "Purple mines with red circles spawn around the arena. AVOID mines or carefully shield if assigned to clear.", false, {"dps", "healer"}),
                mech("ADDS", "Conjured Axes", "Mage summons axes in pairs. Off-tank controls axes while DPS burns or cleaves them safely.", false, {"tank", "dps"}),
                mech("ADDS", "Conjured Reflection", "Reflection adds spawn during the fight. DPS kill them quickly before they add pressure to healers.", false, {"dps"}),
                mech("EXECUTE", "Fifteen Percent Burn", "At low health, damage pressure increases. Save ultimates, maintain heals, avoid mines, and finish the boss cleanly.", false, {"dps", "healer"}),
                mech("HARD MODE", "Meteors And Storm Atronachs", "Hard Mode adds extra meteor and atronach pressure. Stack only when safe, control adds, and keep execution disciplined.", true, {"tank", "healer", "dps"}),
            },
        },
    },
}

local HRC = {
    name = "Hel Ra Citadel",
    batchVersion = "0.8.1",
    batchLabel = "Craglorn Trials",
    isTrial = true,
    bosses = {
        {
            name = "Ra Kotu",
            mechanics = {
                mech("POSITIONING", "Blue Circle", "Group stacks in the protective blue circle. Tank keeps Ra Kotu just outside and faces him away from group.", false, {"tank", "healer", "dps"}),
                mech("ADDS", "Flame-Mages", "Flame-Mages raise their staffs and channel heavy damage. INTERRUPT them immediately and stack/kill them fast.", false, {"dps", "tank"}),
                mech("AOE / AVOID", "Whirlwinds", "Whirlwinds follow players and deal heavy damage. Kite away from group and heal through unavoidable pressure.", false, {"healer", "dps"}),
                mech("HEAVY ATTACK", "Sword Heavy", "Tank blocks heavy hits and holds boss still. Do not face boss into the group.", false, {"tank"}),
                mech("MOVEMENT", "Split Path Opens", "After Ra Kotu dies, raid splits left and right. Assign groups before the pull so each side has support and interrupts.", false, {"tank", "healer", "dps"}),
            },
        },
        {
            name = "Yokeda Rok'dun",
            mechanics = {
                mech("ADDS", "Left Path Waves", "Left-side group clears stacked add waves before the boss. DPS use AoE and tanks pull enemies tightly.", false, {"tank", "dps"}),
                mech("AOE / AVOID", "Oil And Fire", "Avoid oil and fire ground effects while clearing waves. Do not stand in stacked hazards.", false, {"dps", "healer"}),
                mech("ADDS", "Gargoyles And Destroyers", "Priority adds can hit hard or explode. Tank controls them and DPS kill dangerous enemies first.", false, {"tank", "dps"}),
                mech("HEAVY ATTACK", "Archer Pressure", "Tank controls Yokeda Rok'dun and blocks heavy attacks. DPS maintain pressure while avoiding add damage.", false, {"tank", "dps"}),
            },
        },
        {
            name = "Yokeda Kai",
            mechanics = {
                mech("INTERRUPT", "Mage Duplicates", "Kai duplicates himself and all copies charge fire AoE. INTERRUPT boss and copies immediately or group takes lethal damage.", false, {"dps", "tank"}),
                mech("AOE / AVOID", "Fireball AoE", "Failed interrupts create heavy fire damage. Block, heal, and recover, but prioritise bashing the channel.", false, {"healer", "dps"}),
                mech("POSITIONING", "Right Path Group", "Right-side group needs players with ranged interrupts. Keep boss and copies visible so interrupts land quickly.", false, {"dps", "healer"}),
                mech("HEALER", "Barrier Backup", "If interrupts are missed, HEALERS use mitigation and burst healing to stabilise the right group.", false, {"healer"}),
            },
        },
        {
            name = "The Warrior",
            mechanics = {
                mech("POSITIONING", "Pedestal Position", "Tank pulls boss near the pedestal and just outside the blue circle. Group stacks safely in the blue circle.", false, {"tank", "healer", "dps"}),
                mech("HEAVY ATTACK", "Frontal Cleave", "Tank blocks heavy cleaves and keeps boss facing away. Group must never stand in front of Warrior.", false, {"tank"}),
                mech("AOE / AVOID", "Starfall", "Red circles target players. MOVE OUT and avoid overlapping circles on the stack.", false, {"dps", "healer"}),
                mech("ADDS", "Statue Phase", "Statues/adds activate during the fight. DPS kill priority targets and return to boss quickly.", false, {"dps"}),
                mech("EXECUTE", "Whirlwind Execute", "Damage ramps near execute and Warrior can spin. Tank may kite; healers prepare heavy healing and DPS burn safely.", false, {"tank", "healer", "dps"}),
                mech("HARD MODE", "Stonebreaker Pressure", "Hard Mode increases punishment during statue and execute overlap. Control adds, keep formation, and execute cleanly.", true, {"tank", "healer", "dps"}),
            },
        },
    },
}

local SO = {
    name = "Sanctum Ophidia",
    batchVersion = "0.8.1",
    batchLabel = "Craglorn Trials",
    isTrial = true,
    bosses = {
        {
            name = "Possessed Mantikora",
            mechanics = {
                mech("POSITIONING", "Face Away", "Tank holds Mantikora in the middle and faces him away. Group stacks behind boss with space for poison mechanics.", false, {"tank", "healer", "dps"}),
                mech("AOE / AVOID", "Popcorn Circles", "Three circles target players one after another and launch them. DODGE the first circle away from group and keep moving out.", false, {"dps", "healer"}),
                mech("AOE / AVOID", "Culminating Slam", "Mantikora slams/stomps for heavy arena damage. BLOCK or move as called and prepare healing.", false, {"healer", "dps"}),
                mech("DEBUFF", "Poison Shards", "Poison targets selected players. Keep assigned players slightly separated and avoid spreading poison through group.", false, {"healer", "dps"}),
                mech("ADDS", "Overchargers", "Overchargers are dangerous priority adds in Sanctum. Kill them first whenever they appear.", false, {"dps"}),
                mech("TANK", "Role Switch", "Tank and off-tank must be ready to swap boss/add duties. Coordinate taunts and keep dangerous fronts away from group.", false, {"tank"}),
            },
        },
        {
            name = "Stonebreaker Troll",
            mechanics = {
                mech("POSITIONING", "Bridge Control", "Tank positions the troll so Overchargers are not pulled into the group. Avoid fighting in unsafe bridge locations.", false, {"tank"}),
                mech("ADDS", "Overchargers", "Overchargers spawn and cause dangerous ranged pressure. DPS kill them first before focusing the troll.", false, {"dps"}),
                mech("AOE / AVOID", "Poison Ground", "Poison effects pressure the tank and nearby players. MOVE OUT of poison and keep healing on the tank.", false, {"healer", "tank"}),
                mech("HEAVY ATTACK", "Troll Smash", "Tank blocks heavy hits from Stonebreaker. DPS and healers avoid the frontal area.", false, {"tank"}),
            },
        },
        {
            name = "Ozara",
            mechanics = {
                mech("ADDS", "Priority Add Waves", "Ozara spawns Troll, Overcharger, War Priest, Archer, and Skirmisher adds. Tanks separate dangerous adds and DPS kill priority targets.", false, {"tank", "dps"}),
                mech("CROWD CONTROL", "Pinned Players", "Players can be pinned or controlled by adds. BREAK FREE and kill controlling adds quickly.", false, {"dps", "healer"}),
                mech("POSITIONING", "Main Tank Stack", "Main tank can control Ozara and Overcharger while off-tank holds War Priest/Troll/Archer away from group.", false, {"tank"}),
                mech("HEALER", "Split Damage", "Healers watch pinned or separated players. Burst heal anyone caught by adds, poison, or ground effects.", false, {"healer"}),
                mech("AOE / AVOID", "Poison Areas", "Avoid poison and ground effects. Do not stand in overlapping damage while adds are active.", false, {"dps", "healer"}),
            },
        },
        {
            name = "The Serpent",
            mechanics = {
                mech("DEBUFF", "Poison Phase", "Group takes heavy poison pressure. STACK in healing and use mitigation; healers maintain HoTs and purge/cleanse support.", false, {"healer", "dps"}),
                mech("HEAVY ATTACK", "Frontal Cleave", "After poison phase, Serpent cleaves in front. Tank faces boss away and blocks heavy attacks.", false, {"tank"}),
                mech("MECHANIC", "Totems", "Totems can pull, debuff, or threaten the group. Kill dangerous totems quickly; dodge roll if pulled by green totem.", false, {"dps"}),
                mech("ADDS", "Lamia Adds", "Lamia adds spawn during the fight. Off-tank controls them away from group; avoid killing them in dangerous positions because they explode.", false, {"tank", "dps"}),
                mech("AOE / AVOID", "World Shaper", "Large arena damage/phase mechanic. Follow group positioning and move to safe areas immediately.", false, {"dps", "healer"}),
                mech("EXECUTE", "Final Burn", "Mechanic overlap increases near execute. Save ultimates, control adds/totems, and finish boss safely.", false, {"dps", "healer", "tank"}),
                mech("HARD MODE", "Mantikora And Totem Overlap", "Hard Mode adds tighter add/totem overlap. Tanks coordinate, DPS prioritise totems/adds, healers prepare burst healing.", true, {"tank", "healer", "dps"}),
            },
        },
    },
}

local MOL = {
    name = "Maw of Lorkhaj",
    batchVersion = "0.8.2",
    batchLabel = "Early DLC Trials",
    isTrial = true,
    bosses = {
        {
            name = "Zhaj'hassa the Forgotten",
            mechanics = {
                mech("DEBUFF", "Curse", "Random players are cursed and must reach a cleanse pad within 30 seconds or die. DPS avoid taking tank/healer pads unless assigned.", false, {"dps", "healer", "tank"}),
                mech("ADDS", "Sar'm'athra Panthers", "Panthers cannot be taunted. Tanks chain them into boss so DPS cleave them down with AoE.", false, {"tank", "dps"}),
                mech("ONE SHOT", "Void Pillars", "Boss raises his sword with an echo. HIDE behind a void pillar to survive the blast.", false, {"dps", "healer", "tank"}),
                mech("DPS CHECK", "Fewer Pillars", "Each blast spawns fewer pillars. Kill boss before the group runs out of safe pillars.", false, {"dps"}),
                mech("DPS CHECK", "Boss Shield 70/30", "At 70% and 30%, boss shields and blasts AoEs under players. Burn shield fast and keep positions disciplined.", false, {"dps", "healer"}),
                mech("HEALER", "Shield Phase Healing", "Group damage increases the longer shield remains active. HEALERS use mitigation and burst healing during shield phases.", false, {"healer"}),
            },
        },
        {
            name = "Vashai and S'kinrai",
            mechanics = {
                mech("MECHANIC", "Holy And Shadow", "Six players receive holy and six receive shadow. You deal full damage to opposite-colour enemies and explode near opposite-colour players.", false, {"dps", "healer", "tank"}),
                mech("MOVEMENT", "Colour Swap", "Before prayer, marked players swap sides clockwise. Move immediately and avoid crossing into opposite-colour players.", false, {"dps", "healer"}),
                mech("MECHANIC", "Prayer", "Bosses jump and pray. If boss colour matches your colour, swap sides; if opposite, stay and damage.", false, {"dps", "healer", "tank"}),
                mech("TANK", "Ranged Taunt Swap", "Tanks swap bosses during prayer using ranged taunt. Do not cross the candle line.", false, {"tank"}),
                mech("ADDS", "Colour Adds", "Adds must be chained to the boss of the same colour and cleaved immediately. Bash channeling adds.", false, {"tank", "dps"}),
                mech("DPS CHECK", "Simultaneous Demise", "Kill both twins within 20 seconds of each other. After one dies, colours are removed and everyone can attack the last boss.", false, {"dps"}),
            },
        },
        {
            name = "Rakkhat",
            mechanics = {
                mech("POSITIONING", "Lunar Pad Rotation", "Boss moves through lunar pads. Follow raid lead positions and stay on correct pads to control damage and shielding.", false, {"tank", "healer", "dps"}),
                mech("PORTAL", "Backyard Team", "Assigned players enter backyard/shadow realm and kill shadows quickly before returning. Do not repeat if debuffed.", false, {"dps", "healer"}),
                mech("ADDS", "Hulks And Adds", "Hulks and adds spawn during pad phases. Tanks control them and DPS kill priority adds before they overwhelm group.", false, {"tank", "dps"}),
                mech("AOE / AVOID", "Dark Barrage And Meteors", "Avoid ground damage and stack where called for meteors. Healers prepare group healing during pad transitions.", false, {"healer", "dps"}),
                mech("EXECUTE", "Eleven Percent Center", "At 11%, Rakkhat moves to the middle pad. Save resources and burn while handling remaining mechanics.", false, {"dps", "healer", "tank"}),
                mech("HARD MODE", "Breath Of Lorkhaj", "Hard Mode backyard players receive a breath debuff that cannot be cleansed and can spread. Rotate different players each time.", true, {"dps", "healer"}),
                mech("HARD MODE", "Assassins", "Hard Mode assassins spawn after shadows die. Avoid tornado/knockback effects and kill assassins fast.", true, {"dps"}),
            },
        },
    },
}

local HOF = {
    name = "Halls of Fabrication",
    batchVersion = "0.8.2",
    batchLabel = "Early DLC Trials",
    isTrial = true,
    bosses = {
        {
            name = "Hunter-Killer Negatrix and Positrox",
            mechanics = {
                mech("POSITIONING", "Split Bosses", "Each tank holds one boss on opposite sides. Do not let bosses stay connected by beam for more than a short time.", false, {"tank"}),
                mech("ONE SHOT", "Electric Beam", "Beam between bosses can kill players and enrages if bosses stay connected. Never stand between bosses.", false, {"tank", "dps", "healer"}),
                mech("AOE / AVOID", "Shock Field", "Boss drops shock field under tank. Move boss away and keep group out of the field.", false, {"tank"}),
                mech("DEBUFF", "Sparkles", "Tail balls stun players and leave purgeable DoTs. BLOCK to reduce damage and purge if needed.", false, {"healer", "dps"}),
                mech("DEBUFF", "Bleed And Heal Debuff", "Tank receives bleed and healing debuff. HEALERS focus tank and purge/cleanse when needed.", false, {"tank", "healer"}),
                mech("INTERRUPT", "Headbang Tank Stun", "Boss knocks tank down and channels. INTERRUPT quickly or the tank can die.", false, {"dps", "tank"}),
                mech("ADDS", "Spheres", "Spheres apply poison DoTs. DPS kill spheres and group purges poison pressure.", false, {"dps", "healer"}),
            },
        },
        {
            name = "Pinnacle Factotum",
            mechanics = {
                mech("AOE / AVOID", "Conduit", "A conduit spawns during the fight. DPS focus conduit quickly and avoid standing in steam or unsafe ground.", false, {"dps"}),
                mech("AOE / AVOID", "Staff Spin", "When boss twirls his staff, back up and prepare to dodge incoming damage.", false, {"dps", "healer"}),
                mech("ADDS", "Centurion Add", "Spin-to-win centurion can be kited by off-tank. Group gives off-tank path around arena and avoids being run over.", false, {"tank", "dps"}),
                mech("HEAVY ATTACK", "Factotum Heavy", "Tank blocks heavy hits and keeps boss positioned so group can safely damage conduits and adds.", false, {"tank"}),
            },
        },
        {
            name = "Archcustodian",
            mechanics = {
                mech("MECHANIC", "Shield", "Boss is immune while shielded and the shield kills players who touch it. Do not walk into shield.", false, {"dps", "tank", "healer"}),
                mech("MECHANIC", "Stun Phase", "Tank presses button to activate laser. Pull boss through laser, then burn while shield drops for a short window.", false, {"tank", "dps"}),
                mech("ADDS", "Stun Adds", "Adds spawn after each stun. Damage them early, then drag them into boss during stun so they cleave down.", false, {"tank", "dps"}),
                mech("AOE / AVOID", "Blades", "Blades move along the walkway and apply bleed. Stack on faster blades only if group calls it and heal through.", false, {"healer", "dps"}),
                mech("ONE SHOT", "Shock Darts", "Do not move too far from boss or shock darts can kill you. Stay within safe range while rotating platforms.", false, {"dps", "healer"}),
            },
        },
        {
            name = "Reassembly Committee",
            mechanics = {
                mech("POSITIONING", "Lightning Leash", "If bosses get too close, they connect by lightning. Keep them separated except during planned stun phases.", false, {"tank"}),
                mech("MECHANIC", "Enrage 69/39/19", "Bring all three bosses together just before 69%, 39%, and 19% so they stun together, then separate and continue.", false, {"tank", "dps"}),
                mech("ADDS", "Reclaimer Adds", "Reclaimer spawns explosive adds. Kill them fast and avoid their spawn explosions.", false, {"dps"}),
                mech("DEBUFF", "Reducer Fireballs", "Reducer fireballs apply painful purgeable DoTs. Healers purge and players avoid unnecessary hits.", false, {"healer", "dps"}),
                mech("AOE / AVOID", "Reactor Waves", "Reactor sends waves that leave ground effects and pull players down. Move out immediately.", false, {"dps", "healer"}),
                mech("EXECUTE", "Nineteen Percent Control", "At 19%, stun all bosses together. Focus Reclaimer first, then finish remaining bosses one by one.", false, {"tank", "dps"}),
            },
        },
        {
            name = "Assembly General",
            mechanics = {
                mech("HEAVY ATTACK", "Stomp", "Boss stomp knocks back players if not blocked. BLOCK when stomp is incoming.", false, {"tank", "dps", "healer"}),
                mech("AOE / AVOID", "Meteors", "Meteors fall on group. Spread slightly to reduce overlapping AoE damage.", false, {"dps", "healer"}),
                mech("TANK", "Right Blade Arm", "Off-tank stands on boss right side to control blade arm mechanic and keep group safe.", false, {"tank"}),
                mech("MECHANIC", "Repair Phases 85/65/45", "When both arms break, boss returns middle to repair. Get off the top and do not attack during reflect phase.", false, {"dps", "healer", "tank"}),
                mech("ADDS", "Repair Spheres", "Four spheres spawn in corridors during repair. Kill at least two before returning to boss to reduce incoming damage.", false, {"dps"}),
                mech("ADDS", "Scheduled Adds", "Adds spawn at fixed health ranges. Tanks control them and DPS kill priority adds while maintaining boss damage.", false, {"tank", "dps"}),
                mech("HARD MODE", "Final Boss Additions", "Hard Mode increases add, arm, and repair pressure. Maintain assignments, kill spheres, and respect reflect phases.", true, {"tank", "healer", "dps"}),
            },
        },
    },
}

local AS = {
    name = "Asylum Sanctorium",
    batchVersion = "0.8.2",
    batchLabel = "Early DLC Trials",
    isTrial = true,
    bosses = {
        {
            name = "Saint Llothis the Pious",
            mechanics = {
                mech("DEBUFF", "Noxious Gas", "Llothis teleports and leaves poison cloud that slows, damages, and healing-debuffs players. Move out immediately.", false, {"dps", "healer"}),
                mech("AOE / AVOID", "Defiling Blast", "A green-glowing target stands still while everyone else moves out of the narrow cone. Block first if caught, then dodge out.", false, {"dps", "healer"}),
                mech("INTERRUPT", "Oppressive Bolts", "Boss glows green and raises weapon to rain bolts on group. INTERRUPT immediately.", false, {"dps", "tank"}),
                mech("HEAVY ATTACK", "Corroding Bolt", "Bolt targets the player with aggro. Tank blocks or dodge rolls the hit.", false, {"tank"}),
                mech("ADDS", "Imperfect Attendants", "Attendants enrage after roughly 30-35 seconds. Stack and kill them quickly before they become lethal.", false, {"tank", "dps"}),
            },
        },
        {
            name = "Saint Felms the Bold",
            mechanics = {
                mech("MOVEMENT", "Shrapnel Storm", "Felms teleports to furthest players and drops pulsing AoEs. Assigned players catch jumps away from group.", false, {"healer", "dps"}),
                mech("DEBUFF", "Bleeding", "Standing in Shrapnel Storm applies a bleed DoT. Cleanse if needed and avoid remaining in the storm.", false, {"healer", "dps"}),
                mech("AOE / AVOID", "Manifest Wrath", "Boss sends small AoEs from red markers. Spread briefly, avoid the center of the pattern, then restack.", false, {"dps", "healer"}),
                mech("ADDS", "Pneuma Projections", "Projection adds enrage if alive too long. Save damage and kill them quickly, especially below 25%. ", false, {"dps"}),
                mech("HEAVY ATTACK", "Cyclonic Carving", "Projection whirlwind can be blocked or dodge rolled and applies Maim. Avoid or block when targeted.", false, {"tank", "dps"}),
                mech("CROWD CONTROL", "Lead To Slaughter", "Projection chains a far player into melee range. BLOCK the pull and move back to assignment.", false, {"dps", "healer"}),
            },
        },
        {
            name = "Saint Olms the Just",
            mechanics = {
                mech("ADDS", "Ordinated Protector Sphere", "Spheres shield Olms and make him immune while connected. DPS kill spheres immediately.", false, {"dps"}),
                mech("AOE / AVOID", "Shockball Spit", "Lightning orbs land on targeted players and create shock AoEs. Move them to edges and roll out.", false, {"dps", "healer"}),
                mech("AOE / AVOID", "Storm The Heavens", "Olms flies and fires lightning waves. Keep moving, avoid overlap, and do not run through other players.", false, {"dps", "healer"}),
                mech("MOVEMENT", "Gust Of Steam", "At 90%, 75%, 50%, and 25%, Olms jumps and slams across the room. Move to safe sides and do not overlap.", false, {"dps", "healer", "tank"}),
                mech("EXECUTE", "Trial By Fire", "At execute, huge fire meteors fill sections of arena. Stay in safe zones, purge DoTs, and shield/heal through damage.", false, {"healer", "dps"}),
                mech("ONE SHOT", "Scalding Roar", "Steam breath cone kills players in front. Tank faces Olms away and group avoids the front.", false, {"tank", "dps", "healer"}),
                mech("HARD MODE", "+1 / +2 Saints", "In higher difficulties, Llothis and/or Felms join Olms. Off-tank pulls minis into cleave and DPS kills them before enrage.", true, {"tank", "dps"}),
                mech("HARD MODE", "Healer Kite Duties", "Hard Mode healers manage shock/maim fields around the arena. Keep space for the main tank and group assignments.", true, {"healer"}),
            },
        },
    },
}

local CR = {
    name = "Cloudrest",
    batchVersion = "0.8.2",
    batchLabel = "Early DLC Trials",
    isTrial = true,
    bosses = {
        {
            name = "Shade of Siroria",
            mechanics = {
                mech("ADDS", "Creepers And Adds", "Kill Creepers and other adds first. Creepers stun and pressure group if ignored.", false, {"dps"}),
                mech("TANK", "Gryphon Position", "One tank controls the Gryphon and faces it away. DPS focus Gryphon whenever it lands.", false, {"tank", "dps"}),
                mech("STACK", "Fire Meteor", "A yellow circle targets a player. At least three players stack inside to split damage and survive.", false, {"dps", "healer"}),
                mech("POSITIONING", "Separate Boss And Gryphon", "Keep Siroria and Gryphon apart. If too close, they empower and deal more damage.", false, {"tank"}),
                mech("PORTAL", "Shadow Realm", "Portal team enters, destroys crystals, sends shards, carries orbs to shards, and returns. Rotate teams because portal debuff prevents re-entry.", false, {"dps"}),
            },
        },
        {
            name = "Shade of Relequen",
            mechanics = {
                mech("ADDS", "Creepers And Adds", "Kill Creepers and other adds first. Avoid being stunned by their ground effects.", false, {"dps"}),
                mech("TANK", "Gryphon Position", "Tank controls Gryphon and faces it away from group. DPS hit Gryphon when it is grounded.", false, {"tank", "dps"}),
                mech("DEBUFF", "Voltaic Overload", "Floor turns blue around you. Swap bars and stay on the other bar until the timer ends or group damage can occur.", false, {"dps", "healer", "tank"}),
                mech("POSITIONING", "Separate Boss And Gryphon", "Keep Relequen and Gryphon separated to prevent empowerment.", false, {"tank"}),
                mech("PORTAL", "Shadow Realm", "Assigned portal team clears crystals and handles orbs/shards. Do not enter portal again while debuffed.", false, {"dps"}),
            },
        },
        {
            name = "Shade of Galenwe",
            mechanics = {
                mech("ADDS", "Creepers And Adds", "Kill Creepers and other adds first. Avoid ground stuns and keep group stable.", false, {"dps"}),
                mech("TANK", "Gryphon Position", "Tank controls Gryphon and faces it away. DPS burns Gryphon while grounded.", false, {"tank", "dps"}),
                mech("DEBUFF", "Hoarfrost", "Hoarfrost must be managed by assigned players. Move/kite it safely and avoid dropping it on group.", false, {"dps", "healer"}),
                mech("POSITIONING", "Separate Boss And Gryphon", "Keep Galenwe and Gryphon apart to prevent empowerment.", false, {"tank"}),
                mech("PORTAL", "Shadow Realm", "Portal team destroys crystals and sends orbs to shards. Rotate teams because portal debuff prevents repeat entry.", false, {"dps"}),
            },
        },
        {
            name = "Z'Maja",
            mechanics = {
                mech("PORTAL", "Shadow Realm", "Portal teams rotate into shadow realm, destroy crystals, send shards, carry orbs, and return before add pressure overwhelms group.", false, {"dps"}),
                mech("ADDS", "Creepers", "Creepers spawn and stun players with ground effects. DPS kill them quickly throughout the fight.", false, {"dps"}),
                mech("ADDS", "Orbs And Monstrosities", "Portal delays can spawn dangerous adds into normal world. Complete portal mechanic quickly to prevent extra pressure.", false, {"dps", "tank"}),
                mech("INTERRUPT", "Interruptible Cast", "Z'Maja can cast dangerous interruptible abilities. INTERRUPT immediately when called.", false, {"dps", "tank"}),
                mech("EXECUTE", "Shadow Of Z'Maja", "Final phase adds heavy damage and boss copy pressure. Burn assigned targets and keep portal/add control disciplined.", false, {"dps", "healer", "tank"}),
                mech("HARD MODE", "+1 / +2 / +3 Welkynars", "Leaving mini bosses alive adds their fire, lightning, and ice mechanics to Z'Maja. Handle all active mini-boss mechanics from start to finish.", true, {"tank", "healer", "dps"}),
            },
        },
    },
}

local SS = {
    name = "Sunspire",
    batchVersion = "0.8.3",
    batchLabel = "Later DLC Trials",
    isTrial = true,
    bosses = {
        {
            name = "Lokkestiiz",
            mechanics = {
                mech("POSITIONING", "Dragon Facing", "Group stacks in front at safe distance; avoid standing too close or too far to the side. Tank keeps dragon controlled.", false, {"tank", "healer", "dps"}),
                mech("MECHANIC", "Ice Tomb", "One player enters the ice circle and becomes frozen. HEALERS restore them to full health before they explode.", false, {"healer", "dps"}),
                mech("ADDS", "Frost Atronachs", "Do not kill Frost Atronachs with damage alone. Kill Storm Atronach, then tank moves Frost Atronachs into the shock circle.", false, {"tank", "dps"}),
                mech("ONE SHOT", "Laser Beam", "Boss fires a lethal beam during flight phases. BLOCK when beam is coming or you die.", false, {"tank", "healer", "dps"}),
                mech("PHASE", "Flight 80/50/20", "Boss flies at 80%, 50%, and 20%. Handle adds and prepare for laser timing; 50% laser comes quickly.", false, {"dps", "healer"}),
                mech("HARD MODE", "Double Ice Tomb", "Hard Mode drops two ice circles. Stagger entries slightly so healers can fully heal each frozen player before explosion.", true, {"healer", "dps"}),
                mech("HARD MODE", "Flame Atronachs", "Hard Mode adds Flame Atronachs through the fight. Tank pulls them into group and DPS cleaves them safely.", true, {"tank", "dps"}),
            },
        },
        {
            name = "Yolnahkriin",
            mechanics = {
                mech("PHASE", "Flight 75/50/25", "At 75%, 50%, and 25%, boss flies and burns the center. Move to outer ring immediately or die.", false, {"tank", "healer", "dps"}),
                mech("ENVIRONMENTAL", "Lava Growth", "Lava expands if the phase lasts too long. Push boss to next phase before arena space is lost.", false, {"dps"}),
                mech("HEAVY ATTACK", "Fire Breath", "Breath has long range. Tank faces boss away and off-tank respects positioning to avoid being hit behind group.", false, {"tank"}),
                mech("ADDS", "Fire Atronachs", "Adds spawn and should be pulled into group for cleave. Kill them before they overwhelm healers.", false, {"tank", "dps"}),
                mech("AOE / AVOID", "Wing Thrash", "Standing too far to the side can trigger wing attacks. Stay in assigned safe zones.", false, {"dps", "healer"}),
                mech("HARD MODE", "Faster Lava Pressure", "Hard Mode increases arena pressure and punishes slow phase pushes. DPS must meet burn timings cleanly.", true, {"dps", "healer"}),
            },
        },
        {
            name = "Nahviintaas",
            mechanics = {
                mech("PORTAL", "Time Breach Upstairs", "Assigned portal team goes upstairs and completes time mechanics. Coordinate upstairs and downstairs callouts.", false, {"dps", "healer"}),
                mech("ADDS", "Flame Atronachs", "Flame Atronachs spawn through the fight and in execute. Tank pulls them in and DPS cleaves them down.", false, {"tank", "dps"}),
                mech("DEBUFF", "Time Bubble Buff", "Players upstairs can create a green field for downstairs group. Pick it up when called for increased damage.", false, {"dps"}),
                mech("HEAVY ATTACK", "Dragon Breath", "Tank faces boss away from group. Avoid the front and block heavy breath pressure.", false, {"tank"}),
                mech("EXECUTE", "Final Burn", "Execute adds and raid damage overlap. Save ultimates, kill Flame Atronachs, and maintain portal discipline.", false, {"tank", "healer", "dps"}),
                mech("HARD MODE", "Defile", "Hard Mode applies healing reduction to the group. Healers prepare stronger healing and players use shields defensively.", true, {"healer", "dps"}),
                mech("HARD MODE", "Vigil Statue", "Off-tank holds Vigil Statue near boss. Damage it when vulnerable, avoid smash, and interrupt rock waves after several casts.", true, {"tank", "dps"}),
            },
        },
    },
}

local KA = {
    name = "Kyne's Aegis",
    batchVersion = "0.8.3",
    batchLabel = "Later DLC Trials",
    isTrial = true,
    bosses = {
        {
            name = "Yandir the Butcher",
            mechanics = {
                mech("MECHANIC", "Totem Hand Glow", "Yandir summons totems based on hand glow. Identify totem type quickly and respond before it controls the arena.", false, {"dps", "healer"}),
                mech("AOE / AVOID", "Dragon Totems", "Two dragon totems fire lines in their facing directions. Look where heads face and avoid the fire waves.", false, {"dps", "healer"}),
                mech("CROWD CONTROL", "Gargoyle Totems", "Gargoyle totems stone players. BLOCK if possible and BREAK FREE immediately.", false, {"dps", "healer", "tank"}),
                mech("DEBUFF", "Chaurus Totems", "Several players receive poison. Spread into assigned positions and avoid stacking while poison is active.", false, {"dps", "healer"}),
                mech("ADDS", "Butcher Adds", "Adds spawn during the fight. Tanks control them and DPS kills priority targets while maintaining boss damage.", false, {"tank", "dps"}),
                mech("HARD MODE", "Fire Shaman Meteors", "Hard Mode fire shamans channel meteors. BLOCK or mitigate meteor hits and kill/interrupt shamans as assigned.", true, {"dps", "healer"}),
            },
        },
        {
            name = "Captain Vrol",
            mechanics = {
                mech("MECHANIC", "Ballista Repair Parts", "Players collect repair parts from back of arena and repair ballistas so they can shoot boat adds.", false, {"dps"}),
                mech("ADDS", "Boat Shamans", "From 50%, Vrol summons paired shamans on the longship. Kill them with ballistas or group gets overwhelmed.", false, {"dps"}),
                mech("HEAVY ATTACK", "Thunderous Bash", "Heavy attack creates lightning strikes in group. Tank blocks and group avoids follow-up strikes.", false, {"tank", "healer", "dps"}),
                mech("AOE / AVOID", "Frigid Fog", "Boss drops a damaging/stunning fog that refreshes a shield if he stands in it. Tank moves boss out quickly.", false, {"tank"}),
                mech("HARD MODE", "Siege Pressure", "Hard Mode increases punishment for missed ballista timing. Repair quickly and kill boat adds on schedule.", true, {"dps"}),
            },
        },
        {
            name = "Lord Falgravn",
            mechanics = {
                mech("TANK", "Lieutenant Njordal", "Phase one includes Njordal. Off-tank controls him; main tank may guard/support due to heavy light attacks.", false, {"tank"}),
                mech("HEAVY ATTACK", "Blood Cleave", "Njordal frontal cleave kills players. Face him away and dodge/block heavy uppercut-style hits.", false, {"tank"}),
                mech("AOE / AVOID", "Sanguine's Grasp", "Hands rise from the ground and kill players who stand in them. MOVE OUT immediately.", false, {"dps", "healer"}),
                mech("PHASE", "Stage Two Transform", "Falgravn changes phases and gains heavier raid damage. Maintain positioning and prepare for new add/mechanic overlap.", false, {"tank", "healer", "dps"}),
                mech("ADDS", "Torturers", "Torturers must be controlled and killed before mechanics stack out of control. DPS prioritise them when called.", false, {"tank", "dps"}),
                mech("EXECUTE", "Final Phase Pressure", "Final phase combines high raid damage, adds, and movement. Save ultimates and stabilise before burn.", false, {"healer", "dps"}),
                mech("HARD MODE", "Full HM Timeline", "Hard Mode adds tighter timing and heavier overlap across phases. Keep add priorities, cleaves, and movement disciplined.", true, {"tank", "healer", "dps"}),
            },
        },
    },
}

local RG = {
    name = "Rockgrove",
    batchVersion = "0.8.3",
    batchLabel = "Later DLC Trials",
    isTrial = true,
    bosses = {
        {
            name = "Oaxiltso",
            mechanics = {
                mech("AOE / AVOID", "Stomp", "Boss stomps and sends fire waves in straight lines. Avoid the fire lanes.", false, {"dps", "healer"}),
                mech("AOE / AVOID", "Meteors", "Two meteors strike down. Avoid or block; getting hit by both can kill you.", false, {"dps", "healer"}),
                mech("DEBUFF", "Noxious Sludge", "Two players get orange screen/sludge. Cleanse in assigned pools or poison AoEs spawn in group.", false, {"dps", "healer"}),
                mech("MOVEMENT", "Charge", "Boss charges the furthest player. Assigned far player/healer controls charge position.", false, {"healer", "dps"}),
                mech("ADDS", "Havocrel Annihilator", "Mini boss spawns at 95%, 75%, 50%, and 25%. Off-tank controls it away from Oaxiltso.", false, {"tank", "dps"}),
                mech("POSITIONING", "Enrage Distance", "Main boss and mini boss enrage if too close. Tanks keep them separated.", false, {"tank"}),
                mech("HARD MODE", "Double Charge", "Hard Mode boss charges twice. Avoid standing far unless assigned and keep cleanse positions disciplined.", true, {"healer", "dps"}),
            },
        },
        {
            name = "Flame-Herald Bahsei",
            mechanics = {
                mech("PORTAL", "Shadow Portal", "Portal cone rotates and sends hit players into shadow realm. Assigned players enter, kill wraiths, and return quickly.", false, {"dps"}),
                mech("AOE / AVOID", "Rotating Cone", "Avoid the portal cone unless assigned to enter. The cone slowly rotates through the arena.", false, {"dps", "healer"}),
                mech("ADDS", "Wraiths", "Shadow realm wraiths must be killed quickly. They have low health but portal time becomes dangerous.", false, {"dps"}),
                mech("DEBUFF", "Realm Damage", "Shadow realm pulses damage that ramps over time. Complete portal duty quickly and leave.", false, {"healer", "dps"}),
                mech("ADDS", "Flame And Poison Adds", "Adds and arena hazards overlap with boss mechanics. Tanks control adds and DPS kills priority targets.", false, {"tank", "dps"}),
                mech("HARD MODE", "Portal Precision", "Hard Mode punishes portal mistakes heavily. Only assigned players enter and portal team clears wraiths fast.", true, {"dps", "healer"}),
            },
        },
        {
            name = "Xalvakka",
            mechanics = {
                mech("PHASE", "Arena Phases", "Fight moves through multiple phases with changing arena hazards. Follow group movement calls and maintain safe positioning.", false, {"tank", "healer", "dps"}),
                mech("ADDS", "Priority Adds", "Adds spawn throughout the fight. Tanks control dangerous enemies and DPS kill priority targets before returning to boss.", false, {"tank", "dps"}),
                mech("AOE / AVOID", "Fire Waves", "Fire waves and ground hazards move across the arena. Keep moving and avoid standing in overlapping damage.", false, {"dps", "healer"}),
                mech("DEBUFF", "Group Damage", "Raid-wide damage increases during phase overlap. Healers prepare mitigation and players avoid unnecessary hits.", false, {"healer"}),
                mech("EXECUTE", "Final Burn", "Execute combines add pressure and arena hazards. Save ultimates and burn while keeping survival first.", false, {"dps", "healer", "tank"}),
                mech("HARD MODE", "Xalvakka Hard Mode", "Hard Mode increases arena pressure and add overlap. Respect movement calls, kill adds, and keep tanks stable.", true, {"tank", "healer", "dps"}),
            },
        },
    },
}

local DSR = {
    name = "Dreadsail Reef",
    batchVersion = "0.8.3",
    batchLabel = "Later DLC Trials",
    isTrial = true,
    bosses = {
        {
            name = "Lylanar and Turlassil",
            mechanics = {
                mech("POSITIONING", "Fire And Ice Split", "Group manages two bosses with opposing elements. Tanks separate bosses and players respect assigned sides.", false, {"tank", "healer", "dps"}),
                mech("DEBUFF", "Elemental Enfeeblement", "Players can receive fire or ice weakness. Avoid taking the wrong element and follow assignment calls.", false, {"dps", "healer"}),
                mech("PHASE", "Titanic Clash", "Bosses clash and lower platform becomes dangerous/superheated. Move as called and avoid heat ray damage.", false, {"tank", "healer", "dps"}),
                mech("AOE / AVOID", "Heat Rays", "Sparking and Blazing Heat Rays apply dangerous effects. Avoid re-entering the same ray unnecessarily.", false, {"dps", "healer"}),
                mech("HARD MODE", "Titanic Triumph", "Hard Mode requires clean Titanic Clash handling and elemental assignments. Maintain fire/ice discipline through both clashes.", true, {"tank", "healer", "dps"}),
            },
        },
        {
            name = "Reef Guardian",
            mechanics = {
                mech("AOE / AVOID", "Acid Reflux", "Boss casts a cone on tank and drops poison pools every two seconds. Only tank stays in cone to limit pools.", false, {"tank"}),
                mech("DEBUFF", "Acidic Vulnerability", "Poison pools apply stacking poison vulnerability. Avoid standing in pools and move boss cleanly.", false, {"tank", "healer", "dps"}),
                mech("PORTAL", "Heart Portals", "Assigned players enter portals and destroy the heart mechanic. Missing portal duty can wipe the group on veteran.", false, {"dps"}),
                mech("ADDS", "Reef Adds", "Adds spawn during the fight. Tanks control them and DPS kills priority adds before they overwhelm the room.", false, {"tank", "dps"}),
                mech("HARD MODE", "Portal Discipline", "Hard Mode increases punishment for missed heart/portal timing. Portal teams must execute quickly and return safely.", true, {"dps", "healer"}),
            },
        },
        {
            name = "Tideborn Taleria",
            mechanics = {
                mech("POSITIONING", "Sea Arena Control", "Fight uses large arena movement and water hazards. Follow safe-side calls and avoid being cut off by hazards.", false, {"tank", "healer", "dps"}),
                mech("ADDS", "Side Boss Pressure", "Side-boss style mechanics and adds can overlap. Tanks control adds and DPS prioritises dangerous targets.", false, {"tank", "dps"}),
                mech("AOE / AVOID", "Water And Lightning", "Avoid expanding water/lightning hazards and do not stack overlapping damage on group.", false, {"dps", "healer"}),
                mech("HEALER", "Raid Damage Waves", "Group damage spikes during arena transitions. Healers prepare mitigation and burst healing.", false, {"healer"}),
                mech("EXECUTE", "Final Burn", "Mechanic overlap increases at low health. Save ultimates, stabilise, and finish after add pressure is controlled.", false, {"dps", "healer", "tank"}),
                mech("HARD MODE", "Taleria Hard Mode", "Hard Mode adds stricter movement, add, and arena-pressure checks. Keep assignments tight and survival first.", true, {"tank", "healer", "dps"}),
            },
        },
    },
}

local SE = {
    name = "Sanity's Edge",
    batchVersion = "0.8.3",
    batchLabel = "Later DLC Trials",
    isTrial = true,
    bosses = {
        {
            name = "Exarchanic Yaseyla",
            mechanics = {
                mech("DEBUFF", "Hemorrhage", "Yaseyla melee attacks apply Hemorrhage. Tanks and healers monitor bleed pressure.", false, {"tank", "healer"}),
                mech("ADDS", "Contramagis Wamasu", "At health thresholds, Yaseyla summons Wamasu and Archers. DPS must kill adds before mechanics stack too high.", false, {"dps", "tank"}),
                mech("TIMER", "Health Thresholds", "Adds spawn at set health thresholds. Avoid pushing boss too fast if adds are still alive.", false, {"dps"}),
                mech("AOE / AVOID", "Archer Pressure", "Archers and protected horrors create dangerous zones. Move out and kill priority adds.", false, {"dps", "healer"}),
                mech("HARD MODE", "Extra Thresholds", "Hard Mode adds more Wamasu/Archer thresholds. Control burn and clear adds before pushing.", true, {"dps", "tank"}),
            },
        },
        {
            name = "Archwizard Twelvane",
            mechanics = {
                mech("MECHANIC", "Illusion Control", "Fight uses dream/illusion mechanics. Follow assigned positioning and avoid chasing false targets without callouts.", false, {"dps", "healer"}),
                mech("ADDS", "Dream Adds", "Adds spawn during the encounter. DPS kill priority adds while tanks keep dangerous enemies controlled.", false, {"tank", "dps"}),
                mech("AOE / AVOID", "Arcane Ground Effects", "Move out of arcane AoEs and avoid overlapping them near the group.", false, {"dps", "healer"}),
                mech("HEALER", "Group Burst Damage", "Damage spikes during illusion/add overlap. Healers prepare shields and burst healing.", false, {"healer"}),
                mech("HARD MODE", "Twelvane Hard Mode", "Hard Mode increases overlap and punishes missed add/positioning assignments. Keep raid calls clear.", true, {"tank", "healer", "dps"}),
            },
        },
        {
            name = "Ansuul the Tormentor",
            mechanics = {
                mech("PHASE", "Reality Shift", "Ansuul changes arena state and mechanics as the fight progresses. Follow raid calls and move early.", false, {"tank", "healer", "dps"}),
                mech("AOE / AVOID", "Torment Zones", "Dangerous ground zones and attacks overlap. Avoid stacking hazards on group.", false, {"dps", "healer"}),
                mech("ADDS", "Tormentor Adds", "Adds spawn during phase pressure. Tanks control them and DPS kills priority adds quickly.", false, {"tank", "dps"}),
                mech("HEALER", "Mental Pressure", "Raid-wide damage spikes during phase transitions. Healers prepare mitigation and burst healing.", false, {"healer"}),
                mech("EXECUTE", "Final Torment", "Final phase compresses mechanics and damage. Save ultimates and finish after stabilising adds/mechanics.", false, {"tank", "healer", "dps"}),
                mech("HARD MODE", "Ansuul Hard Mode", "Hard Mode increases mechanic density and punishes failed movement. Maintain role assignments and avoid panic burns.", true, {"tank", "healer", "dps"}),
            },
        },
    },
}

local LC = {
    name = "Lucent Citadel",
    batchVersion = "0.8.3",
    batchLabel = "Later DLC Trials",
    isTrial = true,
    bosses = {
        {
            name = "Count Ryelaz and Zilyesset",
            mechanics = {
                mech("POSITIONING", "Mirror Split", "Room is divided by mirror/window. Split group between darkness and light sides; buffs do not cross sides.", false, {"tank", "healer", "dps"}),
                mech("MECHANIC", "Annihilation Platforms", "Both bosses cast Annihilation. Look through mirror, find glowing platform, stand on it, and swap sides before wipe cast finishes.", false, {"dps", "healer", "tank"}),
                mech("EXECUTE", "Rejuvenation Timer", "When one boss dies, kill the other within timer or first revives. Timer is shorter in veteran/HM.", false, {"dps"}),
                mech("HEAVY ATTACK", "Ryelaz Shear", "Ryelaz heavy causes meteors after hit. Tank blocks and players avoid stacking during meteors.", false, {"tank", "dps"}),
                mech("HEAVY ATTACK", "Zilyesset Triple Heavy", "Zilyesset heavy hits three times with increasing damage. Tank blocks and healers support.", false, {"tank", "healer"}),
                mech("ADDS", "Blackguard And Bone Flayers", "Side adds require correct beam/aura handling to remove protection. Kill priority adds on each side.", false, {"dps", "tank"}),
                mech("HARD MODE", "Short Rejuvenation", "Hard Mode shortens kill window and increases side pressure. Balance boss health carefully and execute together.", true, {"dps", "healer", "tank"}),
            },
        },
        {
            name = "Cavot Agnan",
            mechanics = {
                mech("ADDS", "Skeletal Minions", "Cavot controls skeletal minions. Kill remaining minions while avoiding boss aura pressure.", false, {"dps"}),
                mech("AOE / AVOID", "Bleakquake", "Staff slam launches small circles. Avoid standing close enough to be hit by multiple circles.", false, {"dps", "healer"}),
                mech("MECHANIC", "Radiance", "Cavot becomes immune and makes enemies in aura immune. Do not touch aura; kill remaining minions during Radiance.", false, {"dps", "tank"}),
                mech("HEAVY ATTACK", "Smite", "Tank must block Smite. If tank dodge rolls instead, everyone else must dodge or be hit.", false, {"tank", "healer", "dps"}),
                mech("POSITIONING", "Safe Distance", "Do not stand touching Cavot during Radiance/Sunburst pressure. Fight at safe distance and move as a group.", false, {"dps", "healer"}),
            },
        },
        {
            name = "Orphic Shattered Shard / Xoryn",
            mechanics = {
                mech("PHASE", "Shard Phases", "Shard encounter uses escalating phase mechanics. Follow group movement and handle assigned objectives before boss pressure resumes.", false, {"tank", "healer", "dps"}),
                mech("ADDS", "Mirrormoor Adds", "Adds spawn during the fight and can overwhelm the group. Tanks control them and DPS burns priority targets.", false, {"tank", "dps"}),
                mech("AOE / AVOID", "Crystalline Hazards", "Avoid crystal and mirror ground effects. Do not stack overlapping hazards on group.", false, {"dps", "healer"}),
                mech("HEALER", "High Raid Damage", "Raid damage spikes during shard mechanics. Healers prepare mitigation and sustain healing.", false, {"healer"}),
                mech("EXECUTE", "Temporary Subdue", "Xoryn can only be subdued temporarily. Finish assigned objectives and execute cleanly.", false, {"dps", "tank", "healer"}),
                mech("HARD MODE", "Shard Hard Mode", "Hard Mode increases add and phase pressure. Maintain role assignments and avoid rushing mechanics.", true, {"tank", "healer", "dps"}),
            },
        },
    },
}

local OC = {
    name = "Ossein Cage",
    batchVersion = "0.8.3",
    batchLabel = "Later DLC Trials",
    isTrial = true,
    bosses = {
        {
            name = "Shapers of Flesh",
            mechanics = {
                mech("ADDS", "Fleshspawn", "Fleshspawn can combine into Flesh Abomination if uncontrolled. Kill or manage Fleshspawn before they merge.", false, {"dps"}),
                mech("PORTAL", "Carrion Portals", "Assigned players use Carrion portals to handle channelers/objectives. Rotate portal use so all assignments are covered.", false, {"dps", "healer"}),
                mech("DEBUFF", "Caustic Carrion", "Carrion portal damage can stack. Use Carrion Shield resets correctly before damage becomes lethal.", false, {"healer", "dps"}),
                mech("ADDS", "Channelers", "Players using corresponding Carrion portal must help defeat channelers without dying. Kill channelers quickly.", false, {"dps"}),
                mech("HARD MODE", "Fears Of The Flesh", "Hard Mode increases Fleshspawn/portal pressure. Manage portals, channelers, and Fleshspawn with strict assignments.", true, {"tank", "healer", "dps"}),
            },
        },
        {
            name = "Jynorah and Skorkhif",
            mechanics = {
                mech("MECHANIC", "Titanic Clash", "During Titanic Clash, lower platform becomes Superheated. Handle movement and heat ray assignments cleanly.", false, {"tank", "healer", "dps"}),
                mech("DEBUFF", "Sparking Enfeeblement", "Avoid incorrect Spark damage unless assigned. Track Sparking effects during clash phases.", false, {"dps", "healer"}),
                mech("DEBUFF", "Blazing Enfeeblement", "Avoid incorrect Blaze damage unless assigned. Do not overlap both effects unless achievement/strategy calls it.", false, {"dps", "healer"}),
                mech("AOE / AVOID", "Heat Rays", "Sparking and Blazing Heat Rays apply dangerous effects. Avoid re-entering same cast unnecessarily.", false, {"dps", "healer"}),
                mech("HARD MODE", "Titanic Triumph", "Hard Mode requires clean Titanic Clash handling and careful Spark/Blaze management across the group.", true, {"tank", "healer", "dps"}),
            },
        },
        {
            name = "Overfiend Kazpian",
            mechanics = {
                mech("MECHANIC", "Agonizer Bomb", "Bomb explosion should only hit initial target. Group avoids splash and respects bomb positioning.", false, {"dps", "healer"}),
                mech("PORTAL", "Side Island", "Assigned players go to side island at least once in strategies requiring it. Return safely before main group is overwhelmed.", false, {"dps", "healer"}),
                mech("ADDS", "Molag Kena And Low Warden", "Final encounter can include Molag Kena and Low Warden Dusk. Tanks control them and DPS follows kill/hold strategy.", false, {"tank", "dps"}),
                mech("CROWD CONTROL", "Dominator Chains", "Chains partner players or restrict positioning. Keep distance from chain partner and avoid breaking assignments.", false, {"dps", "healer"}),
                mech("AOE / AVOID", "Ogrim Charge And Goaded Breath", "Avoid charge paths and breath cones. Tanks face enemies away and group keeps lanes clear.", false, {"tank", "dps", "healer"}),
                mech("HARD MODE", "Familiar Foes", "Hard Mode can require keeping Molag Kena and Low Warden alive until the end. Follow raid lead kill/hold calls.", true, {"tank", "healer", "dps"}),
            },
        },
        {
            name = "Red Witch Gedna Relvel",
            mechanics = {
                mech("ADDS", "Abductor Mini-Boss", "Optional abductor mini-boss required for achievements. Control adds and kill according to raid lead call.", false, {"tank", "dps"}),
                mech("AOE / AVOID", "Witch Ground Effects", "Avoid dangerous ground effects and keep the boss positioned for safe cleave.", false, {"dps", "healer"}),
            },
        },
        {
            name = "The Tortured Trio",
            mechanics = {
                mech("ADDS", "Triple Mini-Boss", "Optional trio encounter required for achievements. Tanks control enemies and DPS follows priority order.", false, {"tank", "dps"}),
                mech("POSITIONING", "Separate Pressure", "Avoid stacking all dangerous effects in one place. Maintain clean positioning while killing targets.", false, {"tank", "healer", "dps"}),
            },
        },
        {
            name = "Blood Drinker Thisa",
            mechanics = {
                mech("ADDS", "Abductor Mini-Boss", "Optional abductor mini-boss required for achievements. Kill safely and avoid unnecessary deaths before main bosses.", false, {"tank", "dps"}),
                mech("DEBUFF", "Blood Pressure", "Watch for bleed or blood-themed pressure. Healers keep HoTs active and group avoids stacked damage.", false, {"healer", "dps"}),
            },
        },
    },
}

MechanicMentorTrials.List = {
    AA,
    HRC,
    SO,
    MOL,
    HOF,
    AS,
    CR,
    SS,
    KA,
    RG,
    DSR,
    SE,
    LC,
    OC,
}

for index, trial in ipairs(MechanicMentorTrials.List) do
    trial.releaseOrder = index
    trial.id = trial.id or string.lower((trial.name or "trial"):gsub("[^%w]+", "_")):gsub("^_+", ""):gsub("_+$", "")
end
