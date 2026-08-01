HowToCloudrest = HowToCloudrest or {}
local HowToCloudrest = HowToCloudrest

HowToCloudrest.AbilitiesToTrack = {
    
    -- General --
    [104755] = HowToCloudrest.HeavyAttack, --when Siroria HA's
    [105780] = HowToCloudrest.HeavyAttack, --when Relequen HA's
    [106375] = HowToCloudrest.HeavyAttack, --when Galenwe HA's

    --[105541] = HowToCloudrest.Displacement, -- Minidisplacement spawn
    
    [106601] = HowToCloudrest.MiniJump, --siroria jump
    [105796] = HowToCloudrest.MiniJump, --when Relequen does Flux Burst (jump)
    [106682] = HowToCloudrest.MiniJump, --galenwe teleport
    
    [105380] = HowToCloudrest.MiniBash, --when Relequen begins channeling Direct Current (Interrupt)
    [106405] = HowToCloudrest.MiniBash, --when Galenwe begins channeling Glacial Spikes (Interrupt)
    
    [104902] = HowToCloudrest.MiniSkill, --when Siroria does Banner
    [106614] = HowToCloudrest.MiniSkill, --when Relequen does Jolt (Cone?)
    [106378] = HowToCloudrest.MiniSkill, --when Galenwe does Donut

    [106656] = HowToCloudrest.RazorThorns, --when a Creeper roots you with Razor Thorns ability

    -- Siroria --
    [105765] = HowToCloudrest.DarkTalons, --when Siroria casts Dark Talons (root)
    [103531] = HowToCloudrest.RoaringFlare,
    [110431] = HowToCloudrest.RoaringFlare, -- additional fire on execute

    -- Relequen --
    [87346]  = HowToCloudrest.Overload, --when overload will appear on you
    [103555] = HowToCloudrest.Overload, --when you have overload on you


    -- Galenwe --
    [105151] = HowToCloudrest.HoarfrostCast, -- castIds
    [110466] = HowToCloudrest.HoarfrostCast, -- castIds (2nd during execute)

    [103695] = HowToCloudrest.Hoarfrost, -- hoarFrostIds
    [110516] = HowToCloudrest.Hoarfrost, -- hoarFrostIds (2nd during execute)

    [103697] = HowToCloudrest.HoarfrostSynergy, -- synergy
    [110525] = HowToCloudrest.HoarfrostSynergy, -- synergy (2nd during execute)

    [103765] = HowToCloudrest.HoarfrostAoe, -- aoe

    [106374] = HowToCloudrest.ChillingComet, -- When Galenwe casts Chilling Comet on 3 ppl.
    [106367] = HowToCloudrest.ChillingComet, -- When Galenwe casts Chilling Comet on 3 ppl.

    -- Portal --
    [107478] = HowToCloudrest.ResetPortals, --when Z'maja resets
    [103946] = HowToCloudrest.PortalOpen, --when portals spawn/open

    [104057] = HowToCloudrest.PortalClosed, --when Remove Shadow Realm is cast (portal close(Normal?))
    [104792] = HowToCloudrest.PortalClosed, --when portal closes
    [105890] = HowToCloudrest.PortalClosed, --when Z'Maja is engaged (portals)
    [105218] = HowToCloudrest.PortalClosed, -- Raid notifier "player_exit_srealm". Needed for sidebosses.


    [103980] = HowToCloudrest.MalevolentCoreHit, --when a Malevolent Core is exposed (TODO)
    [103989] = HowToCloudrest.MalevolentCoreHit, --when a Malevolent Core hits a player with Malevolent Exposure (Ball is picked up)
    [110202] = HowToCloudrest.MalevolentCoreHit, --when a Malevolent Core hits a player with Shadow Flare (Balls not picked up)

    -- [104107] --Wind of Wekynar (When platforms appear?)
    -- [104111] --Wind of the Welkynar (Platform synergy)
    -- [104036] --Welkynar's Light (Spear synergy)
    -- [104015] --Olorime Spears?
    [104018] = HowToCloudrest.OlorimeSpearGrant, --when an Olorime spear is granted

    -- Z'Maja --
    [104564] = HowToCloudrest.ZmajaJump, --When Zmaja begin jump
    [104452] = HowToCloudrest.HideJump, --When Zmaja do her last jump to shade

    [105152] = HowToCloudrest.CrushingDarkness, -- when Zmaja begin crushing
    [105172] = HowToCloudrest.CrushingDarkness,
    [105239] = HowToCloudrest.CrushingDarkness, -- when Zmaja begin crushing

    [105123] = HowToCloudrest.ShadowSplashCast, -- when Z'maja begins channeling Shadow Splash (Drop from ceiling)

    [107490] = HowToCloudrest.MiniShackled, -- when Olorime shackles a mini during the Z'Maja fight (Mini dies during +1, +2 or +3)

    [107196] = HowToCloudrest.BanefulMarkOnExecute, -- when Z'Maja casts Baneful Mark during execute.

    [105291] = HowToCloudrest.MaliciousSphereSpawn,
    --[110242] = HowToCloudrest.MaliciousStrike, -- Orb killed
    --[105363] = HowToCloudrest.MaliciousStrike, -- Orb collided - action result = 2240
    [105339] = HowToCloudrest.ShadowBeadTick,
    [105363] = HowToCloudrest.ShadowBeadSpawn,
    [105373] = HowToCloudrest.ShadowBeadCharge,
    -- [105375] = HowToCloudrest.MaliciousSphereCharge -- when an orb is not killed in time it charges a random person. (Mental Manip Charge)

    [105016] = HowToCloudrest.CreeperSpawn,
}

--Add a notification :
    --add the ID here with a function
    --main file :
        --create the corresping function
        --create the UI function
        --add default values
        --add new events / variables to the reset function
    --settings file :
        --add to unlock all
        --add an enable / unlock option
        --add to the text size
    --UI file :
        --add to the init function
        --add the saveLoc function
    --XML file :
        --add the new part of UI