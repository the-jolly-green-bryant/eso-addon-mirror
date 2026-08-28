CurvedHUD = CurvedHUD or {}
local CH = CurvedHUD
CH.name, CH.version, CH.updateName = "CurvedHUD", "0.8.4-test", "CurvedHUD_Update"
CH.defaults = {enabled=true,preview=false,showDefaultResources=true,buffVerticalOffset=0,useOutOfCombatOpacity=false,outOfCombatOpacity=.45,scale=1.0,spacing=235,verticalOffset=35,resourceGap=7,barWidth=48,fillAlpha=.85,frameAlpha=.48,backgroundAlpha=.24,shieldAlpha=.68,textAlpha=.95,timerFontSize=24,expirationAlerts=false,resourceValueFontSize=27,resourcePercentFontSize=20,majorBuffTracked="Major Resolve",insideTimerStyle="Thin",outsideTimerStyle="Thick",majorBuffColor="Purple",balanceEnabled=true,balanceSlot="bottomLeftInside",balanceColor="Orange",aegisEnabled=true,aegisSlot="topLeftOutside",aegisColor="Pale Blue",armamentsEnabled=true,armamentsSlot="topRightInside",armamentsColor="Pale Blue",fragmentsEnabled=true,fragmentsPosition="Top",fragmentsScale=.75,surgeEnabled=false,surgeSlot="topRightOutside",surgeColor="Gold",shroudEnabled=false,shroudSlot="bottomRightOutside",shroudColor="Cyan",soulBurstEnabled=false,soulBurstSlot="topRightInside",soulBurstColor="Purple",soulBurstDuration=20,contingencyEnabled=false,contingencySlot="bottomRightInside",contingencyColor="Cyan",contingencyDuration=20,showRaw=true,showPercent=true,showMaximum=false,debug=true,layout="Parallel",staminaInside=true,iconCache={}}
CH.characterKeys = {majorBuffTracked=true,majorBuffColor=true,balanceEnabled=true,balanceSlot=true,balanceColor=true,aegisEnabled=true,aegisSlot=true,aegisColor=true,armamentsEnabled=true,armamentsSlot=true,armamentsColor=true,fragmentsEnabled=true,fragmentsPosition=true,surgeEnabled=true,surgeSlot=true,surgeColor=true,shroudEnabled=true,shroudSlot=true,shroudColor=true,soulBurstEnabled=true,soulBurstSlot=true,soulBurstColor=true,soulBurstDuration=true,contingencyEnabled=true,contingencySlot=true,contingencyColor=true,contingencyDuration=true}
CH.characterDefaults = {majorBuffTracked="Major Resolve",majorBuffColor="Purple",balanceEnabled=true,balanceSlot="bottomLeftInside",balanceColor="Orange",aegisEnabled=true,aegisSlot="topLeftOutside",aegisColor="Pale Blue",armamentsEnabled=true,armamentsSlot="topRightInside",armamentsColor="Pale Blue",fragmentsEnabled=true,fragmentsPosition="Top",surgeEnabled=false,surgeSlot="topRightOutside",surgeColor="Gold",shroudEnabled=false,shroudSlot="bottomRightOutside",shroudColor="Cyan",soulBurstEnabled=false,soulBurstSlot="topRightInside",soulBurstColor="Purple",soulBurstDuration=20,contingencyEnabled=false,contingencySlot="bottomRightInside",contingencyColor="Cyan",contingencyDuration=20,initialized=false}
CH.majorBuffChoices = {"None","Major Resolve","Major Brutality","Major Sorcery","Major Savagery","Major Prophecy","Major Expedition","Major Protection","Major Evasion","Major Berserk","Major Force","Major Courage"}
CH.colorChoices = {"Purple","Orange","Pale Blue","Blue","Green","Red","Gold","White","Cyan","Pink"}
CH.colors = {Purple={.58,.24,.92},Orange={.88,.35,.18},["Pale Blue"]={.48,.82,1},Blue={.18,.48,1},Green={.18,.82,.30},Red={.92,.18,.18},Gold={1,.72,.15},White={1,1,1},Cyan={.15,.9,.9},Pink={1,.35,.68}}
CH.trackerSlots = {
    topLeftOutside={side="left",vertical="upper",inside=false}, topLeftInside={side="left",vertical="upper",inside=true},
    bottomLeftOutside={side="left",vertical="lower",inside=false}, bottomLeftInside={side="left",vertical="lower",inside=true},
    topRightInside={side="right",vertical="upper",inside=true}, topRightOutside={side="right",vertical="upper",inside=false},
    bottomRightInside={side="right",vertical="lower",inside=true}, bottomRightOutside={side="right",vertical="lower",inside=false},
}
CH.trackerSlotNames = {"Top Left - Outside","Top Left - Inside","Bottom Left - Outside","Bottom Left - Inside","Top Right - Inside","Top Right - Outside","Bottom Right - Inside","Bottom Right - Outside"}
CH.trackerSlotValues = {"topLeftOutside","topLeftInside","bottomLeftOutside","bottomLeftInside","topRightInside","topRightOutside","bottomRightInside","bottomRightOutside"}
CH.procPositionChoices = {"Top","Right","Bottom","Left","Center"}
CH.scribingTrackerDefinitions = {
    {key="soulBurst",label="Soul Burst",icon="CurvedHUD/textures/soul_burst.dds",slot="topRightInside",color="Purple",duration=20,needles={"soul burst","binding burst","bloody burst","chilling burst","fiery burst","healing burst","leashing burst","magical burst","pestilent burst","shocking burst","sundering burst","warding burst"}},
    {key="contingency",label="Ulfsild's Contingency",icon="CurvedHUD/textures/ulfsilds_contingency.dds",slot="bottomRightInside",color="Cyan",duration=20,needles={"contingency"}},
    {key="elementalExplosion",label="Elemental Explosion",icon="CurvedHUD/textures/elemental_explosion.dds",slot="topRightOutside",color="Orange",duration=20,needles={"elemental explosion","explosion"}},
    {key="mendersBond",label="Mender's Bond",icon="CurvedHUD/textures/menders_bond.dds",slot="bottomRightOutside",color="Cyan",duration=12,needles={"mender's bond","menders bond"," bond"}},
    {key="shieldThrow",label="Shield Throw",icon="CurvedHUD/textures/shield_throw.dds",slot="topLeftOutside",color="Pale Blue",duration=20,needles={"shield throw"," throw"}},
    {key="smash",label="Smash",icon="CurvedHUD/textures/smash.dds",slot="bottomLeftOutside",color="Red",duration=20,needles={"smash"}},
    {key="torchbearer",label="Torchbearer",icon="CurvedHUD/textures/torchbearer.dds",slot="topLeftInside",color="Orange",duration=20,needles={"torchbearer","torch"}},
    {key="trample",label="Trample",icon="CurvedHUD/textures/trample.dds",slot="bottomLeftInside",color="Gold",duration=2,needles={"trample"}},
    {key="travelingKnife",label="Traveling Knife",icon="CurvedHUD/textures/traveling_knife.dds",slot="topRightInside",color="White",duration=20,needles={"traveling knife","knife"}},
    {key="vault",label="Vault",icon="CurvedHUD/textures/vault.dds",slot="bottomRightInside",color="Green",duration=4,needles={"vault"}},
    {key="wieldSoul",label="Wield Soul",icon="CurvedHUD/textures/wield_soul.dds",slot="topRightOutside",color="Purple",duration=20,needles={"wield soul"," soul"}},
}
CH.sorcererTrackerDefinitions = {
    {key="daedricCurse",label="Daedric Curse / Prey",slot="topLeftInside",color="Purple",duration=6,needles={"daedric curse","daedric prey","haunting curse"},durations={ ["daedric curse"]=6,["daedric prey"]=6,["haunting curse"]=12}},
    {key="lightningSplash",label="Lightning Splash",slot="bottomRightOutside",color="Cyan",duration=10,needles={"lightning splash","lightning flood","liquid lightning"},durations={ ["lightning splash"]=10,["lightning flood"]=10,["liquid lightning"]=15}},
    {key="volatileFamiliar",label="Volatile Familiar Activation",slot="bottomLeftOutside",color="Purple",duration=20,needles={"summon volatile familiar","volatile familiar"}},
    {key="twilightTormentor",label="Twilight Tormentor Activation",slot="topRightOutside",color="Pink",duration=20,needles={"summon twilight tormentor","twilight tormentor"}},
    {key="conjuredWard",label="Conjured Ward",slot="bottomLeftInside",color="Pale Blue",duration=6,needles={"conjured ward","hardened ward","regenerative ward"},durations={ ["conjured ward"]=6,["hardened ward"]=6,["regenerative ward"]=10}},
    {key="lightningForm",label="Lightning Form / Hurricane",slot="topRightInside",color="Pale Blue",duration=20,needles={"lightning form","boundless storm","hurricane"},durations={ ["lightning form"]=20,["boundless storm"]=30,["hurricane"]=20}},
    {key="darkExchange",label="Dark Exchange",slot="bottomRightInside",color="Gold",duration=20,needles={"dark exchange","dark conversion","dark deal"}},
    {key="daedricMines",label="Daedric Mines",slot="topLeftOutside",color="Red",duration=15,needles={"daedric mines","daedric minefield","daedric tomb"}},
}
CH.wardenTrackerDefinitions = {
    {key="netch",label="Betty/Bull Netch",slot="topLeftOutside",color="Pale Blue",duration=25,needles={"betty netch","blue betty","bull netch"},icons={ ["betty netch"]="CurvedHUD/textures/betty_netch.dds",["blue betty"]="CurvedHUD/textures/blue_betty.dds",["bull netch"]="CurvedHUD/textures/bull_netch.dds"}},
    {key="swarm",label="Fetcherfly Swarm",slot="bottomLeftOutside",color="Green",duration=20,needles={"swarm","fetcher infection","growing swarm"},icons={ ["swarm"]="CurvedHUD/textures/swarm.dds",["fetcher infection"]="CurvedHUD/textures/fetcher_infection.dds",["growing swarm"]="CurvedHUD/textures/growing_swarm.dds"}},
    {key="shalk",label="Scorch / Shalks",slot="topLeftInside",color="Orange",duration=9,needles={"scorch","deep fissure","subterranean assault"},icons={ ["scorch"]="CurvedHUD/textures/scorch.dds",["deep fissure"]="CurvedHUD/textures/deep_fissure.dds",["subterranean assault"]="CurvedHUD/textures/subterranean_assault.dds"},durations={ ["scorch"]=9,["deep fissure"]=9,["subterranean assault"]=6}},
    {key="shards",label="Impaling Shards / Winter's Revenge",slot="topRightOutside",color="Pale Blue",duration=12,needles={"impaling shards","gripping shards","winter's revenge","winters revenge"}},
    {key="lotus",label="Lotus Flower",slot="bottomRightOutside",color="Pink",duration=20,needles={"lotus flower","green lotus","lotus blossom"},durations={ ["lotus flower"]=20,["green lotus"]=20,["lotus blossom"]=60}},
    {key="seeds",label="Healing Seed / Budding Seeds",slot="bottomLeftInside",color="Green",duration=6,needles={"healing seed","budding seeds","corrupting pollen"}},
    {key="crystallizedShield",label="Crystallized Shield",slot="topRightInside",color="Cyan",duration=6,needles={"crystallized shield","shimmering shield","crystallized slab"}},
}
CH.arcanistTrackerDefinitions = {
    {key="crux",label="Crux",icon="/esoui/art/icons/class_buff_arcanist_crux.dds",slot="topLeftInside",color="Green",duration=30,stackOnly=true,stackMaximum=3,needles={"crux","runeblades","cephaliarch's flail","cephaliarchs flail"}},
    {key="abyssalImpact",label="Abyssal Impact / Flail",slot="bottomLeftInside",color="Green",duration=20,needles={"abyssal impact","cephaliarch's flail","cephaliarchs flail","tentacular dread"}},
    {key="tomeBearer",label="Tome-Bearer's Inspiration",slot="topLeftOutside",color="Gold",duration=30,needles={"tome-bearer's inspiration","tome bearer's inspiration","inspired scholarship","recuperative treatise"}},
    {key="imperfectRing",label="The Imperfect Ring",slot="bottomLeftOutside",color="Purple",duration=20,needles={"the imperfect ring","fulminating rune","rune of displacement"}},
    {key="runicJolt",label="Runic Jolt / Sunder",slot="topRightInside",color="Red",duration=15,needles={"runic jolt","runic embrace","runic sunder"}},
    {key="runespiteWard",label="Runespite Ward",slot="bottomRightInside",color="Pale Blue",duration=6,needles={"runespite ward","spiteward of the lucid mind","impervious runeward"}},
    {key="fatewovenArmor",label="Fatewoven Armor",slot="topRightOutside",color="Purple",duration=20,needles={"fatewoven armor","cruxweaver armor","unbreakable fate"},durations={["fatewoven armor"]=20,["cruxweaver armor"]=30,["unbreakable fate"]=20}},
    {key="runicDefense",label="Runic Defense",slot="bottomRightOutside",color="Pale Blue",duration=20,needles={"runic defense","runeguard of freedom","runeguard of still waters"}},
    {key="eldritchHorror",label="Rune of Eldritch Horror",slot="topLeftInside",color="Pink",duration=20,needles={"rune of eldritch horror","rune of uncanny adoration","rune of the colorless pool"}},
    {key="chakramShields",label="Chakram Shields",slot="bottomLeftInside",color="Cyan",duration=6,needles={"chakram shields","chakram of destiny","tidal chakram"}},
    {key="arcanistDomain",label="Arcanist's Domain",slot="topRightOutside",color="Green",duration=20,needles={"arcanist's domain","arcanists domain","reconstructive domain","zenas' empowering disc","zenas empowering disc"}},
}
CH.nonClassTrackerDefinitions = {
    -- Two Handed
    {line="Two Handed",key="twoHandCleave",label="Cleave / Carve / Brawler",slot="topLeftInside",color="Red",duration=10,needles={"cleave","carve","brawler"},durations={ ["cleave"]=10,["carve"]=12,["brawler"]=6}},
    {line="Two Handed",key="stampede",label="Stampede",slot="bottomLeftInside",color="Orange",duration=15,needles={"stampede"}},
    {line="Two Handed",key="momentum",label="Momentum / Rally",slot="topLeftOutside",color="Gold",duration=20,needles={"momentum","forward momentum","rally"},durations={ ["momentum"]=20,["forward momentum"]=20,["rally"]=30}},
    {line="Two Handed",key="followUp",label="Follow Up Passive",slot="bottomLeftOutside",color="Gold",duration=4,needles={"follow up"}},
    {line="Two Handed",key="battleRush",label="Battle Rush Passive",slot="topRightOutside",color="Green",duration=10,needles={"battle rush"}},
    -- One Hand and Shield
    {line="One Hand and Shield",key="puncture",label="Puncture / Pierce Armor",slot="topRightInside",color="Red",duration=15,needles={"puncture","pierce armor","ransack"}},
    {line="One Hand and Shield",key="lowSlash",label="Low Slash",slot="bottomRightInside",color="Orange",duration=15,needles={"low slash","heroic slash","deep slash"}},
    {line="One Hand and Shield",key="defensivePosture",label="Defensive Posture",slot="topRightOutside",color="Pale Blue",duration=6,needles={"defensive posture","defensive stance","absorb missile"}},
    {line="One Hand and Shield",key="powerSlam",label="Power Slam",slot="bottomRightOutside",color="Gold",duration=10,needles={"power slam"}},
    -- Dual Wield
    {line="Dual Wield",key="twinSlashes",label="Twin Slashes",slot="topRightInside",color="Red",duration=20,needles={"twin slashes","blood craze","rending slashes"}},
    {line="Dual Wield",key="bladeCloak",label="Blade Cloak",slot="bottomRightInside",color="Pale Blue",duration=20,needles={"blade cloak","quick cloak","deadly cloak"}},
    {line="Dual Wield",key="flyingBlade",label="Flying Blade",slot="topRightOutside",color="Gold",duration=10,needles={"flying blade"}},
    -- Bow
    {line="Bow",key="volley",label="Volley",slot="topRightInside",color="Green",duration=10,needles={"volley","arrow barrage","endless hail"},durations={ ["volley"]=10,["arrow barrage"]=10,["endless hail"]=13}},
    {line="Bow",key="poisonArrow",label="Poison Arrow",slot="bottomRightInside",color="Green",duration=20,needles={"poison arrow","poison injection","venom arrow"}},
    {line="Bow",key="acidSpray",label="Acid Spray",slot="topRightOutside",color="Green",duration=5,needles={"acid spray"}},
    {line="Bow",key="hawkEye",label="Hawk Eye Stacks",slot="bottomRightOutside",color="Gold",duration=5,needles={"hawk eye"}},
    -- Destruction Staff
    {line="Destruction Staff",key="wallElements",label="Wall of Elements",slot="topRightInside",color="Cyan",duration=10,needles={"wall of elements","unstable wall","elemental blockade"},durations={ ["wall of elements"]=10,["unstable wall of elements"]=10,["elemental blockade"]=15}},
    {line="Destruction Staff",key="destructiveTouch",label="Destructive Touch",slot="bottomRightInside",color="Orange",duration=20,needles={"destructive touch","destructive clench","destructive reach"}},
    {line="Destruction Staff",key="weaknessElements",label="Weakness to Elements",slot="topRightOutside",color="Purple",duration=30,needles={"weakness to elements","elemental drain","elemental susceptibility"}},
    {line="Destruction Staff",key="pulsar",label="Pulsar",slot="bottomRightOutside",color="Pale Blue",duration=10,needles={"pulsar"}},
    -- Restoration Staff
    {line="Restoration Staff",key="grandHealing",label="Grand Healing",slot="topLeftInside",color="Green",duration=5,needles={"grand healing","healing springs","illustrious healing"}},
    {line="Restoration Staff",key="regeneration",label="Regeneration",slot="bottomLeftInside",color="Green",duration=10,needles={"regeneration","rapid regeneration","radiating regeneration"}},
    {line="Restoration Staff",key="blessingProtection",label="Blessing of Protection",slot="topLeftOutside",color="Gold",duration=10,needles={"blessing of protection","combat prayer","blessing of restoration"}},
    {line="Restoration Staff",key="steadfastWard",label="Steadfast Ward",slot="bottomLeftOutside",color="Pale Blue",duration=6,needles={"steadfast ward","healing ward","ward ally"}},
    {line="Restoration Staff",key="forceSiphon",label="Force Siphon",slot="topRightOutside",color="Cyan",duration=24,needles={"force siphon","quick siphon","siphon spirit"},durations={ ["force siphon"]=24,["quick siphon"]=30,["siphon spirit"]=30}},
    {line="Restoration Staff",key="essenceDrain",label="Essence Drain Passive",slot="bottomRightOutside",color="Gold",duration=4,needles={"essence drain"}},
    -- Fighters Guild
    {line="Fighters Guild",key="trapBeast",label="Trap Beast",slot="topLeftInside",color="Red",duration=20,needles={"trap beast","barbed trap","lightweight beast trap"}},
    {line="Fighters Guild",key="circleProtection",label="Circle of Protection",slot="bottomLeftInside",color="Gold",duration=20,needles={"circle of protection","ring of preservation","turn evil"}},
    -- Mages Guild
    {line="Mages Guild",key="fireRune",label="Fire Rune",slot="topLeftInside",color="Orange",duration=20,needles={"fire rune","scalding rune","volcanic rune"}},
    {line="Mages Guild",key="entropy",label="Entropy",slot="bottomLeftInside",color="Purple",duration=20,needles={"entropy","structured entropy","degeneration"}},
    -- Undaunted
    {line="Undaunted",key="bloodAltar",label="Blood Altar",slot="topLeftOutside",color="Red",duration=30,needles={"blood altar","overflowing altar","sanguine altar"}},
    {line="Undaunted",key="trappingWebs",label="Trapping Webs",slot="bottomLeftOutside",color="Green",duration=10,needles={"trapping webs","shadow silk","tangling webs"}},
    {line="Undaunted",key="innerFire",label="Inner Fire",slot="topRightInside",color="Red",duration=15,needles={"inner fire","inner rage","inner beast"}},
    {line="Undaunted",key="boneShield",label="Bone Shield",slot="bottomRightInside",color="White",duration=6,needles={"bone shield","spiked bone shield","bone surge"}},
    {line="Undaunted",key="necroticOrb",label="Necrotic Orb",slot="topRightOutside",color="Cyan",duration=10,needles={"necrotic orb","mystic orb","energy orb"}},
    -- Psijic Order
    {line="Psijic Order",key="timeStop",label="Time Stop",slot="topLeftInside",color="Purple",duration=4,needles={"time stop","borrowed time","time freeze"}},
    {line="Psijic Order",key="imbueWeapon",label="Imbue Weapon",slot="bottomLeftInside",color="Gold",duration=2,needles={"imbue weapon","crushing weapon","elemental weapon"}},
    {line="Psijic Order",key="accelerate",label="Accelerate",slot="topLeftOutside",color="Pale Blue",duration=20,needles={"accelerate","channeled acceleration","race against time"},durations={ ["accelerate"]=20,["channeled acceleration"]=36,["race against time"]=20}},
    {line="Psijic Order",key="spellOrb",label="Spell Orb Charges",slot="bottomLeftOutside",color="Purple",duration=10,needles={"spell orb","spell charge"}},
    -- Alliance War
    {line="Assault",key="vigor",label="Vigor",slot="topRightInside",color="Green",duration=5,needles={"vigor","resolving vigor","echoing vigor"}},
    {line="Assault",key="caltrops",label="Caltrops",slot="bottomRightInside",color="Red",duration=15,needles={"caltrops","anti-cavalry caltrops","razor caltrops"}},
    {line="Assault",key="rapidManeuver",label="Rapid Maneuver",slot="topRightOutside",color="Gold",duration=8,needles={"rapid maneuver","charging maneuver","retreating maneuver"}},
    {line="Assault",key="magickaDetonation",label="Magicka Detonation",slot="bottomRightOutside",color="Purple",duration=4,needles={"magicka detonation","inevitable detonation","proximity detonation"}},
    {line="Support",key="siegeShield",label="Siege Shield",slot="topLeftOutside",color="Pale Blue",duration=20,needles={"siege shield","propelling shield","siege weapon shield"}},
    {line="Support",key="revealingFlare",label="Revealing Flare",slot="bottomLeftOutside",color="Red",duration=5,needles={"revealing flare","lingering flare","scorching flare"}},
    -- Armor and World
    {line="Light Armor",key="annulment",label="Annulment",slot="topLeftInside",color="Pale Blue",duration=6,needles={"annulment","dampen magic","harness magicka"}},
    {line="Medium Armor",key="evasion",label="Evasion",slot="topRightInside",color="Green",duration=20,needles={"evasion","shuffle","elude"}},
    {line="Heavy Armor",key="unstoppable",label="Unstoppable",slot="bottomLeftInside",color="Gold",duration=20,needles={"unstoppable","immovable","unstoppable brute"}},
    {line="Soul Magic",key="soulTrap",label="Soul Trap",slot="topLeftOutside",color="Purple",duration=20,needles={"soul trap","consuming trap","soul splitting trap"}},
    {line="Vampire",key="mistForm",label="Mist Form",slot="bottomLeftOutside",color="Purple",duration=4,needles={"mist form","blood mist","elusive mist"}},
    {line="Werewolf",key="werewolfRoar",label="Roar",slot="topRightOutside",color="Red",duration=10,needles={"roar","ferocious roar","deafening roar"}},
    {line="Werewolf",key="werewolfClaws",label="Infectious Claws",slot="bottomRightOutside",color="Green",duration=20,needles={"infectious claws","claws of anguish","claws of life"}},
}
CH.weaponSkillLines = {"Two Handed","One Hand and Shield","Dual Wield","Bow","Destruction Staff","Restoration Staff"}
CH.otherSkillLines = {"Fighters Guild","Mages Guild","Undaunted","Psijic Order","Assault","Support","Light Armor","Medium Armor","Heavy Armor","Soul Magic","Vampire","Werewolf"}
CH.scribingSkillLineByKey = {
    smash="Two Handed",shieldThrow="One Hand and Shield",travelingKnife="Dual Wield",vault="Bow",
    elementalExplosion="Destruction Staff",mendersBond="Restoration Staff",torchbearer="Fighters Guild",
    contingency="Mages Guild",wieldSoul="Psijic Order",trample="Assault",soulBurst="Soul Magic",
}
for _,definition in ipairs(CH.scribingTrackerDefinitions) do
    local key=definition.key
    if CH.defaults[key.."Enabled"]==nil then CH.defaults[key.."Enabled"]=false end
    CH.defaults[key.."Slot"]=CH.defaults[key.."Slot"] or definition.slot; CH.defaults[key.."Color"]=CH.defaults[key.."Color"] or definition.color; CH.defaults[key.."Duration"]=CH.defaults[key.."Duration"] or definition.duration
    CH.characterKeys[key.."Enabled"]=true; CH.characterKeys[key.."Slot"]=true; CH.characterKeys[key.."Color"]=true; CH.characterKeys[key.."Duration"]=true
    CH.characterDefaults[key.."Enabled"]=CH.characterDefaults[key.."Enabled"] or false; CH.characterDefaults[key.."Slot"]=CH.characterDefaults[key.."Slot"] or definition.slot; CH.characterDefaults[key.."Color"]=CH.characterDefaults[key.."Color"] or definition.color; CH.characterDefaults[key.."Duration"]=CH.characterDefaults[key.."Duration"] or definition.duration
end
for _,definition in ipairs(CH.wardenTrackerDefinitions) do
    local key=definition.key
    CH.defaults[key.."Enabled"]=false; CH.defaults[key.."Slot"]=definition.slot; CH.defaults[key.."Color"]=definition.color
    CH.characterKeys[key.."Enabled"]=true; CH.characterKeys[key.."Slot"]=true; CH.characterKeys[key.."Color"]=true
    CH.characterDefaults[key.."Enabled"]=false; CH.characterDefaults[key.."Slot"]=definition.slot; CH.characterDefaults[key.."Color"]=definition.color
end
for _,definition in ipairs(CH.arcanistTrackerDefinitions) do
    local key=definition.key
    CH.defaults[key.."Enabled"]=false; CH.defaults[key.."Slot"]=definition.slot; CH.defaults[key.."Color"]=definition.color
    CH.characterKeys[key.."Enabled"]=true; CH.characterKeys[key.."Slot"]=true; CH.characterKeys[key.."Color"]=true
    CH.characterDefaults[key.."Enabled"]=false; CH.characterDefaults[key.."Slot"]=definition.slot; CH.characterDefaults[key.."Color"]=definition.color
end
for _,definition in ipairs(CH.sorcererTrackerDefinitions) do
    local key=definition.key
    CH.defaults[key.."Enabled"]=false; CH.defaults[key.."Slot"]=definition.slot; CH.defaults[key.."Color"]=definition.color
    CH.characterKeys[key.."Enabled"]=true; CH.characterKeys[key.."Slot"]=true; CH.characterKeys[key.."Color"]=true
    CH.characterDefaults[key.."Enabled"]=false; CH.characterDefaults[key.."Slot"]=definition.slot; CH.characterDefaults[key.."Color"]=definition.color
end
for _,definition in ipairs(CH.nonClassTrackerDefinitions) do
    local key=definition.key
    CH.defaults[key.."Enabled"]=false; CH.defaults[key.."Slot"]=definition.slot; CH.defaults[key.."Color"]=definition.color
    CH.characterKeys[key.."Enabled"]=true; CH.characterKeys[key.."Slot"]=true; CH.characterKeys[key.."Color"]=true
    CH.characterDefaults[key.."Enabled"]=false; CH.characterDefaults[key.."Slot"]=definition.slot; CH.characterDefaults[key.."Color"]=definition.color
end
function CH:NormalizeTrackerSlot(value,fallback)
    if self.trackerSlots[value] then return value end
    for index,name in ipairs(self.trackerSlotNames) do
        if value==name then return self.trackerSlotValues[index] end
    end
    return fallback
end
-- These IDs cover ESO's standardized base effects where confirmed. Name matching
-- remains the fallback because some sources expose their own ability ID while
-- retaining the localized standardized buff name.
local MAJOR_BUFF_IDS = {["Major Resolve"]=61694,["Major Brutality"]=61665,["Major Sorcery"]=61687,["Major Savagery"]=64568,["Major Prophecy"]=64570}
local BOUND_ARMAMENTS_SKILL_ID,BOUND_ARMAMENTS_STACK_ID=24165,203447
local CRYSTAL_FRAGMENTS_PROC_EFFECT_ID,CRYSTAL_FRAGMENTS_PROC_SLOT_ID=46327,114716
local CRITICAL_SURGE_EFFECT_ID=23678
local SHROUD_ICON_PATHS={
    ["vibrant shroud"]="CurvedHUD/textures/vibrant_shroud.dds",
    ["encase"]="CurvedHUD/textures/encase.dds",
    ["shattering spines"]="CurvedHUD/textures/shattering_spines.dds",
}
local DEFAULT_SHROUD_ICON_PATH=SHROUD_ICON_PATHS["vibrant shroud"]
local ULFSILD_EFFECT_ID=222285
local WM = WINDOW_MANAGER
local HEALTH_POWER=_G["COMBAT_MECHANIC_FLAGS_HEALTH"] or POWERTYPE_HEALTH
local STAMINA_POWER=_G["COMBAT_MECHANIC_FLAGS_STAMINA"] or POWERTYPE_STAMINA
local MAGICKA_POWER=_G["COMBAT_MECHANIC_FLAGS_MAGICKA"] or POWERTYPE_MAGICKA
local MOUNT_POWER=_G["COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA"] or POWERTYPE_MOUNT_STAMINA
local function clamp(v,lo,hi) return math.max(lo,math.min(hi,v or 0)) end

function CH:Log(message, always)
    local line=string.format("|c66CCFF[CurvedHUD]|r %s",tostring(message))
    if always or (self.sv and self.sv.debug) then if d then d(line) end end
end
function CH:Guard(label,fn)
    local ok,err=pcall(fn)
    if not ok then self:Log("ERROR in "..label..": "..tostring(err),true) end
    return ok
end
local function texture(parent,suffix,level,path,r,g,b,a)
    local c=WM:CreateControl(parent:GetName()..suffix,parent,CT_TEXTURE)
    c:SetDrawLayer(DL_BACKGROUND); c:SetDrawLevel(level); c:SetTexture(path); c:SetColor(r,g,b,a)
    return c
end
local function label(parent,suffix,font)
    local c=WM:CreateControl(parent:GetName()..suffix,parent,CT_LABEL)
    c:SetFont(font or "ZoFontGamepad27"); c:SetHorizontalAlignment(TEXT_ALIGN_CENTER); c:SetVerticalAlignment(TEXT_ALIGN_CENTER); c:SetColor(1,1,1,1)
    return c
end

function CH:CreateBar(key,side,color)
    local b=WM:CreateControl("CurvedHUD_"..key,self.root,CT_CONTROL)
    b.key,b.side,b.color=key,side,color; b:SetDimensions(96,512)
    b.bg=texture(b,"_Background",0,"CurvedHUD/textures/arc_full.dds",.04,.04,.04,self.sv.backgroundAlpha); b.bg:SetAnchorFill(b)
    -- Resource-specific textures provide an ESO-style dark-to-bright gradient.
    -- White tint preserves the authored gradient while SetAlpha remains customizable.
    b.fill=texture(b,"_Fill",2,"CurvedHUD/textures/arc_"..key.."_gradient.dds",1,1,1,self.sv.fillAlpha); b.fill:SetAnchor(BOTTOMLEFT,b,BOTTOMLEFT)
    -- The holder uses the identical geometry as the fill so scaling cannot separate them.
    b.frame=texture(b,"_Frame",1,"CurvedHUD/textures/arc_full.dds",.38,.38,.38,self.sv.frameAlpha); b.frame:SetAnchorFill(b)
    -- Reversed after the first console render showed the arcs facing the wrong way.
    b.u1,b.u2=side=="left" and 1 or 0,side=="left" and 0 or 1
    b.bg:SetTextureCoords(b.u1,b.u2,0,1); b.frame:SetTextureCoords(b.u1,b.u2,0,1)
    b.rawLabel=label(b,"_RawLabel"); b.rawLabel:SetDimensions(190,34)
    b.percentLabel=label(b,"_PercentLabel","ZoFontGamepad20"); b.percentLabel:SetDimensions(110,28)
    self.bars[key]=b
end
function CH:SetTexturePercent(t,owner,pct)
    pct=clamp(pct,0,1)
    local w,h=owner:GetDimensions(); local shown=math.max(1,math.floor(h*pct))
    t:ClearAnchors(); t:SetDimensions(w,shown)
    if owner.segment=="trackerLower" then
        t:SetAnchor(BOTTOMLEFT,owner,BOTTOMLEFT); t:SetTextureCoords(owner.u1,owner.u2,1-(.42*pct),1)
    elseif owner.segment=="upper" then
        -- Keep the outside/top end filled; depletion advances toward it from the midpoint.
        t:SetAnchor(TOPLEFT,owner,TOPLEFT); t:SetTextureCoords(owner.u1,owner.u2,.5,.5+(.5*pct))
    elseif owner.segment=="lower" then
        -- Keep the outside/bottom end filled; depletion advances toward it from the midpoint.
        t:SetAnchor(BOTTOMLEFT,owner,BOTTOMLEFT); t:SetTextureCoords(owner.u1,owner.u2,.5-(.5*pct),.5)
    else
        t:SetAnchor(BOTTOMLEFT,owner,BOTTOMLEFT); t:SetTextureCoords(owner.u1,owner.u2,1-pct,1)
    end
    t:SetHidden(pct<=0)
end

function CH:SetBarSegment(b,segment)
    b.segment=segment
    if segment=="upper" then
        b.bg:SetTextureCoords(b.u1,b.u2,.5,1); b.frame:SetTextureCoords(b.u1,b.u2,.5,1)
    elseif segment=="lower" then
        b.bg:SetTextureCoords(b.u1,b.u2,0,.5); b.frame:SetTextureCoords(b.u1,b.u2,0,.5)
    else
        b.bg:SetTextureCoords(b.u1,b.u2,0,1); b.frame:SetTextureCoords(b.u1,b.u2,0,1)
    end
end
function CH:SetBarValue(b,current,maximum)
    maximum=math.max(1,maximum or 1); current=clamp(current or 0,0,maximum)
    local pct=current/maximum; self:SetTexturePercent(b.fill,b,pct)
    local raw=self.sv.showRaw and ZO_CommaDelimitNumber(current) or ""
    if self.sv.showMaximum then raw=raw..(raw~="" and " / " or "")..ZO_CommaDelimitNumber(maximum) end
    b.rawLabel:SetText(raw); b.rawLabel:SetHidden(raw=="")
    b.percentLabel:SetText(self.sv.showPercent and string.format("%d%%",math.floor(pct*100+.5)) or ""); b.percentLabel:SetHidden(not self.sv.showPercent)
end
function CH:CreateShield()
    local h=self.bars.health
    h.shield=texture(h,"_Shield",3,"CurvedHUD/textures/arc_full.dds",.72,.76,.82,self.sv.shieldAlpha); h.shield:SetAnchor(BOTTOMLEFT,h,BOTTOMLEFT)
    h.overcap=texture(h,"_Overcap",5,"CurvedHUD/textures/arc_frame.dds",1,1,1,.9); h.overcap:SetAnchorFill(h); h.overcap:SetTextureCoords(h.u1,h.u2,0,1); h.overcap:SetHidden(true)
end
function CH:CreateMountBar()
    local b=WM:CreateControl("CurvedHUD_mount",self.root,CT_CONTROL); b:SetDimensions(24,512)
    b.key,b.side,b.segment="mount","right","full"; b.u1,b.u2=0,1
    b.bg=texture(b,"_Background",0,"CurvedHUD/textures/mount_stacked_outer.dds",.04,.04,.04,self.sv.backgroundAlpha); b.bg:SetAnchorFill(b)
    b.frame=texture(b,"_Frame",1,"CurvedHUD/textures/mount_stacked_outer_frame.dds",.38,.38,.38,self.sv.frameAlpha); b.frame:SetAnchorFill(b)
    b.fill=texture(b,"_Fill",2,"CurvedHUD/textures/mount_stacked_outer.dds",.42,.82,.34,self.sv.fillAlpha); b.fill:SetAnchor(BOTTOMLEFT,b,BOTTOMLEFT)
    b.bg:SetTextureCoords(b.u1,b.u2,0,1); b.frame:SetTextureCoords(b.u1,b.u2,0,1)
    b:SetHidden(true); self.mountBar=b
end
function CH:CreateTracker(key,slot,colorSetting,specialTexture)
    local t=WM:CreateControl("CurvedHUD_"..key,self.root,CT_CONTROL); t:SetDimensions(38,180); t.segment="full"
    t.key,t.slot,t.colorSetting,t.specialTexture=key,slot,colorSetting,specialTexture; t.isNegative=key=="balance"
    local info=self.trackerSlots[slot]; t.u1,t.u2=info.side=="left" and 1 or 0,info.side=="left" and 0 or 1
    local textureName=specialTexture=="balance" and "balance_lower" or "tracker_"..info.vertical
    t.frame=texture(t,"_Frame",1,"CurvedHUD/textures/"..textureName.."_frame.dds",.35,.35,.35,.7); t.frame:SetAnchorFill(t); t.frame:SetTextureCoords(t.u1,t.u2,0,1)
    t.fill=texture(t,"_Fill",2,"CurvedHUD/textures/"..textureName..".dds",1,1,1,.9); t.fill:SetAnchor(BOTTOMLEFT,t,BOTTOMLEFT)
    if key=="balance" then
        -- Balance intentionally nests over Health, so its curve must render above
        -- the Health fill rather than disappearing behind the sibling control.
        t.frame:SetDrawLayer(DL_CONTROLS); t.fill:SetDrawLayer(DL_CONTROLS)
    end
    t.icon=texture(t,"_Icon",3,"/esoui/art/icons/icon_missing.dds",1,1,1,1); t.icon:SetDimensions(38,38); t.icon:SetAnchor(TOP,t,BOTTOM,0,4)
    t.expiryBorder=WM:CreateControl(t:GetName().."_ExpiryBorder",t,CT_BACKDROP); t.expiryBorder:SetDimensions(44,44); t.expiryBorder:SetAnchor(CENTER,t.icon,CENTER); t.expiryBorder:SetDrawLayer(DL_OVERLAY); t.expiryBorder:SetDrawLevel(48); t.expiryBorder:SetCenterColor(.8,0,0,.08); t.expiryBorder:SetEdgeColor(1,.05,.05,.9); t.expiryBorder:SetHidden(true)
    t.icon:SetDrawLayer(DL_OVERLAY); t.icon:SetDrawLevel(49)
    t.stackLabel=label(t.icon,"_StackLabel","ZoFontGamepadBold27"); t.stackLabel:SetAnchor(CENTER,t.icon,CENTER); t.stackLabel:SetDimensions(38,38); t.stackLabel:SetDrawLayer(DL_OVERLAY); t.stackLabel:SetDrawLevel(50); t.stackLabel:SetHidden(true)
    t.timer=label(t,"_Timer","ZoFontGamepad20"); t.timer:SetDimensions(70,30); t.timer:SetAnchor(BOTTOM,t,TOP,0,-5)
    t.active,t.beginTime,t.endTime,t.duration=false,0,0,0; t:SetHidden(true); self.trackers[key]=t
end

function CH:CreateProcAlert()
    local p=WM:CreateControl("CurvedHUD_FragmentsProc",self.root,CT_CONTROL); p:SetDimensions(72,72)
    p.bg=WM:CreateControl("CurvedHUD_FragmentsProc_Background",p,CT_BACKDROP); p.bg:SetAnchorFill(p); p.bg:SetCenterColor(.45,.02,.24,.72); p.bg:SetEdgeColor(1,.25,.72,1)
    p.icon=texture(p,"_Icon",4,"/esoui/art/icons/icon_missing.dds",1,1,1,1); p.icon:SetDimensions(64,64); p.icon:SetAnchor(CENTER,p,CENTER)
    local fallback=GetAbilityIcon and GetAbilityIcon(CRYSTAL_FRAGMENTS_PROC_SLOT_ID)
    if (not fallback or fallback=="") and GetAbilityIcon then fallback=GetAbilityIcon(CRYSTAL_FRAGMENTS_PROC_EFFECT_ID) end
    if fallback and fallback~="" then p.icon:SetTexture(fallback) end
    p:SetHidden(true); self.procAlert=p; self.fragmentsEventActive=false; self.fragmentsEndTime=0
end

function CH:ApplyProcLayout(scale)
    local p=self.procAlert; if not p then return end
    local procScale=clamp(tonumber(self.sv.fragmentsScale) or .75,.35,1.5)
    local size=72*scale*procScale; p:SetDimensions(size,size); p.icon:SetDimensions(64*scale*procScale,64*scale*procScale)
    p:ClearAnchors(); local position=self.sv.fragmentsPosition or "Top"; local spacing=self.sv.spacing*scale
    if position~="Top" and position~="Right" and position~="Bottom" and position~="Left" and position~="Center" then
        position="Top"; self.sv.fragmentsPosition=position
    end
    local x,y=0,0
    if position=="Center" then p:SetAnchor(CENTER,GuiRoot,CENTER,0,0); return
    elseif position=="Top" then y=-225*scale
    elseif position=="Bottom" then y=225*scale
    elseif position=="Left" then x=-spacing+92*scale
    elseif position=="Right" then x=spacing-92*scale end
    p:SetAnchor(CENTER,self.root,CENTER,x,y)
end

function CH:IsCrystalFragmentsProcActive()
    local active=self.fragmentsEventActive and (self.fragmentsEndTime<=0 or self.fragmentsEndTime>GetGameTimeSeconds())
    local iconName=nil
    if GetNumBuffs and GetUnitBuffInfo then
        for index=1,GetNumBuffs("player") do
            local name,_,endTime,_,_,icon,_,_,_,_,abilityId=GetUnitBuffInfo("player",index)
            if abilityId==CRYSTAL_FRAGMENTS_PROC_EFFECT_ID or string.find(string.lower(name or ""),"crystal fragments proc",1,true) then
                active=true; self.fragmentsEndTime=endTime or 0; iconName=icon; break
            end
        end
    end
    if GetSlotBoundId then
        local first=_G["ACTION_BAR_FIRST_NORMAL_SLOT_INDEX"] or 3; local last=_G["ACTION_BAR_ULTIMATE_SLOT_INDEX"] or 8
        for slot=first,last do
            local ok,boundId=pcall(GetSlotBoundId,slot)
            if ok and boundId==CRYSTAL_FRAGMENTS_PROC_SLOT_ID then
                active=true
                if GetSlotTexture then local okIcon,slotIcon=pcall(GetSlotTexture,slot); if okIcon then iconName=slotIcon end end
                break
            end
        end
    end
    return active,iconName
end

function CH:UpdateProcAlert()
    local p=self.procAlert; if not p then return end
    local enabled=self.sv.fragmentsEnabled~=false; local active,iconName=false,nil
    if self.sv.preview and enabled then active=true
    elseif enabled then active,iconName=self:IsCrystalFragmentsProcActive() end
    p:SetHidden(not active)
    if active then
        if iconName and iconName~="" then p.icon:SetTexture(iconName) end
        -- The alert inherits both normal HUD opacity and the optional
        -- out-of-combat opacity through its parent. Keep only a subtle local pulse.
        p.bg:SetAlpha(.72+.28*math.abs(math.sin(GetGameTimeMilliseconds()/300)))
    end
end

function CH:UpdateArmamentsReadyEffect()
    local t=self.trackers and self.trackers.armaments; if not t or not t.readyBorder then return end
    local stacks=self.sv.preview and 4 or (tonumber(t.stackCount) or 0)
    local ready=self.sv.armamentsEnabled~=false and stacks>=4 and not t.expiryAlertActive
    t.readyBorder:SetHidden(not ready)
    local selected=self.colors[self.sv.armamentsColor] or self.colors.Gold
    t.stackLabel:SetColor(ready and math.min(1,selected[1]+.25) or 1,ready and math.min(1,selected[2]+.25) or 1,ready and math.min(1,selected[3]+.25) or 1,1)
    if ready then
        local pulse=.55+.45*math.abs(math.sin(GetGameTimeMilliseconds()/260))
        -- Same larger-backdrop construction used by the Crystal Fragments alert:
        -- the icon remains above it while the white-gold perimeter stays visible.
        local blend=.30+.25*pulse
        t.readyBorder:SetCenterColor(selected[1]+(1-selected[1])*blend,selected[2]+(1-selected[2])*blend,selected[3]+(1-selected[3])*blend,.65+.3*pulse)
        t.readyBorder:SetEdgeColor(1,1,1,.8+.2*pulse)
    end
end

function CH:FindSlottedSkillIcon(...)
    if not GetSlotBoundId or not GetAbilityName then return nil end
    local wanted={...}; local first=_G["ACTION_BAR_FIRST_NORMAL_SLOT_INDEX"] or 3; local last=_G["ACTION_BAR_ULTIMATE_SLOT_INDEX"] or 8
    local categories={false,_G["HOTBAR_CATEGORY_PRIMARY"] or false,_G["HOTBAR_CATEGORY_BACKUP"] or false}
    for _,category in ipairs(categories) do
        for slot=first,last do
            local ok,id
            if category then ok,id=pcall(GetSlotBoundId,slot,category) else ok,id=pcall(GetSlotBoundId,slot) end
            if ok and id and id>0 then
                local name=string.lower(GetAbilityName(id) or "")
                for _,needle in ipairs(wanted) do
                    if string.find(name,needle,1,true) then
                        local okIcon,iconName
                        if GetSlotTexture and category then okIcon,iconName=pcall(GetSlotTexture,slot,category)
                        elseif GetSlotTexture then okIcon,iconName=pcall(GetSlotTexture,slot) end
                        if okIcon and iconName and iconName~="" then return iconName,id end
                        if GetAbilityIcon then local fallback=GetAbilityIcon(id); if fallback and fallback~="" then return fallback,id end end
                        -- The console API can identify a slotted skill while its
                        -- texture path is unavailable to an add-on. Keep the ID;
                        -- bundled-icon callers do not need the runtime texture.
                        return nil,id
                    end
                end
            end
        end
    end
    return nil
end

function CH:FindLearnedSkillIcon(...)
    if not GetNumSkillTypes or not GetNumSkillLines or not GetNumSkillAbilities or not GetSkillAbilityInfo then return nil end
    local wanted={...}
    for skillType=1,GetNumSkillTypes() do
        for lineIndex=1,GetNumSkillLines(skillType) do
            for abilityIndex=1,GetNumSkillAbilities(skillType,lineIndex) do
                local ok,name,textureName=pcall(GetSkillAbilityInfo,skillType,lineIndex,abilityIndex)
                local lowerName=ok and string.lower(name or "") or ""
                for _,needle in ipairs(wanted) do
                    if string.find(lowerName,needle,1,true) and textureName and textureName~="" then return textureName end
                end
            end
        end
    end
    return nil
end

function CH:GetShroudIcon(abilityName)
    local lowerName=string.lower(abilityName or "")
    for name,path in pairs(SHROUD_ICON_PATHS) do
        if lowerName==name or string.find(lowerName,name,1,true) then return path end
    end
    return DEFAULT_SHROUD_ICON_PATH
end

function CH:RefreshShroudBinding()
    local t=self.trackers and self.trackers.shroud; if not t then return end
    local _,abilityId=self:FindSlottedSkillIcon("vibrant shroud","shattering spines","encase")
    local abilityName=abilityId and GetAbilityName and GetAbilityName(abilityId) or ""
    local iconPath=self:GetShroudIcon(abilityName)
    t.preferredIcon=iconPath; t.icon:SetTexture(iconPath)
end

function CH:GetConfiguredAbilityDuration(abilityId,fallback)
    local duration=tonumber(fallback) or 20
    if abilityId and abilityId>0 and GetAbilityDuration then
        local ok,durationMs=pcall(GetAbilityDuration,abilityId)
        durationMs=ok and tonumber(durationMs) or 0
        -- Crafted ability IDs reflect the currently selected scripts. Some
        -- combinations still return zero, so preserve the character setting as fallback.
        if durationMs>=1000 and durationMs<=120000 then duration=durationMs/1000 end
    end
    return clamp(duration,1,120)
end

function CH:RefreshScribingBindings()
    if not self.trackers then return end
    self.scribingAbilityIds=self.scribingAbilityIds or {}
    for _,definition in ipairs(self.scribingTrackerDefinitions) do
        local slottedIcon,abilityId=self:FindSlottedSkillIcon(unpack(definition.needles))
        if abilityId then self.scribingAbilityIds[definition.key]=abilityId end
        local tracker=self.trackers[definition.key]
        local abilityName=abilityId and GetAbilityName and GetAbilityName(abilityId) or definition.needles[1]
        if tracker then self:ResolveTrackerIcon(definition,abilityName,abilityId,slottedIcon,nil,tracker) end
    end
    self:RefreshShroudBinding()
end

function CH:GetFamilyIcon(definition,abilityName)
    local lowerName=string.lower(abilityName or "")
    for name,path in pairs(definition.icons or {}) do
        if lowerName==name or string.find(lowerName,name,1,true) then return path end
    end
    return definition.icons and definition.icons[definition.needles[1]] or nil
end

function CH:DefinitionMatches(definition,lowerName,abilityId,idCache)
    if idCache and idCache[definition.key] and idCache[definition.key]==abilityId then return true end
    for _,needle in ipairs(definition.needles or {}) do
        if lowerName==needle or string.find(lowerName,needle,1,true) then return true end
    end
    return false
end

-- Shared, defensive icon chain for every definition-driven tracker. Bundled
-- artwork wins when supplied; ESO's slot, ability, learned-skill, and live
-- event paths provide independent fallbacks. A previously valid texture is
-- retained if a later API call temporarily returns no artwork.
function CH:ResolveTrackerIcon(definition,abilityName,abilityId,slottedIcon,eventIcon,tracker)
    local iconPath=self:GetFamilyIcon(definition,abilityName) or definition.icon
    if not iconPath or iconPath=="" then iconPath=slottedIcon end
    if (not iconPath or iconPath=="") and abilityId and abilityId>0 and GetAbilityIcon then
        local ok,value=pcall(GetAbilityIcon,abilityId); if ok then iconPath=value end
    end
    if not iconPath or iconPath=="" then iconPath=self:FindLearnedSkillIcon(unpack(definition.needles or {})) end
    if not iconPath or iconPath=="" then iconPath=eventIcon end
    local savedCache=self.globalSV and self.globalSV.iconCache
    if (not iconPath or iconPath=="") and savedCache then iconPath=savedCache[definition.key] end
    if (not iconPath or iconPath=="") and tracker then iconPath=tracker.preferredIcon end
    if iconPath and iconPath~="" then
        if savedCache then savedCache[definition.key]=iconPath end
        if tracker then tracker.preferredIcon=iconPath; tracker.icon:SetTexture(iconPath) end
    end
    return iconPath
end

function CH:RefreshDefinitionBindings(definitions,idCache)
    if not self.trackers then return end
    for _,definition in ipairs(definitions) do
        local slottedIcon,abilityId=self:FindSlottedSkillIcon(unpack(definition.needles))
        if abilityId then idCache[definition.key]=abilityId end
        local abilityName=abilityId and GetAbilityName and GetAbilityName(abilityId) or definition.needles[1]
        self:ResolveTrackerIcon(definition,abilityName,abilityId,slottedIcon,nil,self.trackers[definition.key])
    end
end

function CH:RefreshWardenBindings()
    if not self.trackers then return end
    self.wardenAbilityIds=self.wardenAbilityIds or {}
    self:RefreshDefinitionBindings(self.wardenTrackerDefinitions,self.wardenAbilityIds)
end

function CH:RefreshArcanistBindings()
    if not self.trackers then return end
    self.arcanistAbilityIds=self.arcanistAbilityIds or {}
    self:RefreshDefinitionBindings(self.arcanistTrackerDefinitions,self.arcanistAbilityIds)
end

function CH:RefreshSorcererBindings()
    if not self.trackers then return end
    self.sorcererAbilityIds=self.sorcererAbilityIds or {}
    self:RefreshDefinitionBindings(self.sorcererTrackerDefinitions,self.sorcererAbilityIds)
end

function CH:RefreshNonClassBindings()
    if not self.trackers then return end
    self.nonClassAbilityIds=self.nonClassAbilityIds or {}
    self:RefreshDefinitionBindings(self.nonClassTrackerDefinitions,self.nonClassAbilityIds)
end

function CH:RefreshLegacyIconFallbacks()
    if not self.trackers then return end
    local definitions={
        {key="resolve",needles={string.lower(self.sv.majorBuffTracked or "major resolve")},abilityId=MAJOR_BUFF_IDS[self.sv.majorBuffTracked or "Major Resolve"]},
        {key="balance",needles={"balance"},abilityId=48136},
        {key="aegis",needles={"bound aegis","bound armor"},abilityId=24163},
        {key="armaments",needles={"bound armaments"},abilityId=BOUND_ARMAMENTS_SKILL_ID},
        {key="surge",needles={"critical surge","surge"},abilityId=CRITICAL_SURGE_EFFECT_ID},
    }
    for _,definition in ipairs(definitions) do
        local tracker=self.trackers[definition.key]
        local slottedIcon,slottedId=self:FindSlottedSkillIcon(unpack(definition.needles))
        self:ResolveTrackerIcon(definition,definition.needles[1],slottedId or definition.abilityId,slottedIcon,nil,tracker)
    end
    self:RefreshShroudBinding()
    local proc=self.procAlert
    if proc then
        local iconPath,abilityId=self:FindSlottedSkillIcon("crystal fragments","crystal frags")
        if (not iconPath or iconPath=="") and GetAbilityIcon then iconPath=GetAbilityIcon(abilityId or CRYSTAL_FRAGMENTS_PROC_SLOT_ID) end
        if not iconPath or iconPath=="" then iconPath=self:FindLearnedSkillIcon("crystal fragments","crystal frags") end
        local savedCache=self.globalSV and self.globalSV.iconCache
        if (not iconPath or iconPath=="") and savedCache then iconPath=savedCache.crystalFragments end
        if iconPath and iconPath~="" then
            proc.preferredIcon=iconPath; proc.icon:SetTexture(iconPath)
            if savedCache then savedCache.crystalFragments=iconPath end
        elseif proc.preferredIcon then proc.icon:SetTexture(proc.preferredIcon) end
    end
end

function CH:RefreshAllTrackerIcons()
    self:RefreshScribingBindings()
    self:RefreshSorcererBindings()
    self:RefreshWardenBindings()
    self:RefreshArcanistBindings()
    self:RefreshNonClassBindings()
    self:RefreshLegacyIconFallbacks()
end

function CH:ApplyTrackerAppearance(t)
    local info=self.trackerSlots[t.slot]; local style=info.inside and self.sv.insideTimerStyle or self.sv.outsideTimerStyle
    local base
    if t.specialTexture=="balance" and t.slot=="bottomLeftInside" and style=="Thin" then base="balance_lower"
    else base="tracker_"..info.vertical.."_"..(info.inside and "inside" or "outside").."_"..string.lower(style) end
    t.frame:SetTexture("CurvedHUD/textures/"..base.."_frame.dds"); t.fill:SetTexture("CurvedHUD/textures/"..base..".dds")
    t.u1,t.u2=info.side=="left" and 1 or 0,info.side=="left" and 0 or 1
    local color=self.colors[self.sv[t.colorSetting]] or self.colors.White
    t.fill:SetColor(color[1],color[2],color[3],self.sv.fillAlpha)
end

function CH:SyncBarLayers(b)
    local w,h=b:GetDimensions()
    for _,layer in ipairs({b.bg,b.frame,b.overcap}) do
        if layer then layer:ClearAnchors(); layer:SetAnchor(TOPLEFT,b,TOPLEFT); layer:SetDimensions(w,h) end
    end
end
function CH:SyncTrackerLayers(t)
    local w,h=t:GetDimensions()
    t.frame:ClearAnchors(); t.frame:SetAnchor(TOPLEFT,t,TOPLEFT); t.frame:SetDimensions(w,h); t.frame:SetTextureCoords(t.u1,t.u2,0,1)
end
function CH:SetMountTexture(kind)
    local b=self.mountBar; if not b then return end
    if b.textureKind==kind then return end
    b.textureKind=kind
    b.bg:SetTexture("CurvedHUD/textures/mount_"..kind..".dds")
    b.fill:SetTexture("CurvedHUD/textures/mount_"..kind..".dds")
    b.frame:SetTexture("CurvedHUD/textures/mount_"..kind.."_frame.dds")
end
function CH:SetResourceTexture(b,kind)
    if not b or b.key=="health" or b.textureKind==kind then return end
    b.textureKind=kind
    if kind=="standard" then
        b.bg:SetTexture("CurvedHUD/textures/arc_full.dds")
        b.frame:SetTexture("CurvedHUD/textures/arc_full.dds")
        b.fill:SetTexture("CurvedHUD/textures/arc_"..b.key.."_gradient.dds")
    else
        b.bg:SetTexture("CurvedHUD/textures/arc_resource_"..kind..".dds")
        b.frame:SetTexture("CurvedHUD/textures/arc_resource_"..kind..".dds")
        b.fill:SetTexture("CurvedHUD/textures/arc_"..b.key.."_"..kind.."_gradient.dds")
    end
end

function CH:ApplyTrackerSlot(t,h,inner,outer,width,scale)
    local info=self.trackerSlots[t.slot]; if not info then return end
    local style=info.inside and self.sv.insideTimerStyle or self.sv.outsideTimerStyle
    local legacyBalance=t.key=="balance" and t.slot=="bottomLeftInside"
    local legacyAegis=t.key=="aegis" and t.slot=="topLeftOutside"
    local trackerWidth
    if info.inside then trackerWidth=style=="Thick" and 52 or 38
    elseif style=="Thin" then trackerWidth=52
    else trackerWidth=42 end
    if info.side=="right" and not info.inside then trackerWidth=math.max(28,trackerWidth-14) end
    local trackerHeight=info.inside and 145 or 180
    t:SetDimensions(trackerWidth*scale,trackerHeight*scale); t:ClearAnchors()

    local innerNudge=style=="Thick" and 5 or 0
    -- Counter-shift the wider outer-Thin control so its midpoint remains
    -- stable while the far endpoint gains the missing horizontal sweep.
    local outerNudge=style=="Thick" and 5 or 22
    if t.key=="resolve" then t:SetAnchor(BOTTOMRIGHT,h,BOTTOMLEFT,(40+outerNudge)*scale,-42*scale)
    elseif legacyBalance then t:SetAnchor(BOTTOMLEFT,h,BOTTOMRIGHT,(-46+innerNudge)*scale,-62*scale)
    elseif legacyAegis then t:SetAnchor(TOPRIGHT,h,TOPLEFT,(40+outerNudge)*scale,42*scale)
    elseif info.side=="left" then
        local x=info.inside and (-46+innerNudge) or (40+outerNudge)
        local y=info.inside and 62 or 42
        if info.vertical=="upper" then t:SetAnchor(info.inside and TOPLEFT or TOPRIGHT,h,info.inside and TOPRIGHT or TOPLEFT,x*scale,y*scale)
        else t:SetAnchor(info.inside and BOTTOMLEFT or BOTTOMRIGHT,h,info.inside and BOTTOMRIGHT or BOTTOMLEFT,x*scale,-y*scale) end
    else
        -- Parallel uses radial inner/outer resource references. In Stacked,
        -- ESO's anchored controls render `outer` on the visual upper half and
        -- `inner` on the visual lower half, so map by the rendered quadrant;
        -- otherwise the named upper/lower slots appear exchanged.
        local ref
        if self.sv.layout=="Stacked" then ref=info.vertical=="upper" and outer or inner
        else ref=info.inside and inner or outer end
        local rightOuterNudge=style=="Thick" and 10 or 22
        -- Upper/lower inside slots share one horizontal alignment. Outside slots
        -- retain identical curve geometry but use independent quadrant offsets.
        local outsideBase=info.vertical=="upper" and -18 or -15
        local x=info.inside and (24-innerNudge) or (outsideBase-rightOuterNudge)
        if info.vertical=="upper" then t:SetAnchor(info.inside and TOPRIGHT or TOPLEFT,ref,info.inside and TOPLEFT or TOPRIGHT,x*scale,42*scale)
        else t:SetAnchor(info.inside and BOTTOMRIGHT or BOTTOMLEFT,ref,info.inside and BOTTOMLEFT or BOTTOMRIGHT,x*scale,-42*scale) end
    end

    self:ApplyTrackerAppearance(t); self:SyncTrackerLayers(t)
    t.timer:SetScale(scale); t.icon:SetScale(scale)
    if t.readyBorder then t.readyBorder:SetScale(scale) end
    if t.expiryBorder then t.expiryBorder:SetScale(scale) end
    -- Icons move radially away from their timer endpoint: toward screen center
    -- for inside slots and away from center for outside slots.
    local iconX
    if info.vertical=="upper" then
        if info.side=="left" then iconX=info.inside and 40 or -58
        else iconX=info.inside and -40 or 58 end
    elseif info.side=="left" then iconX=info.inside and 48 or -42
    else iconX=info.inside and -48 or 42 end
    t.icon:ClearAnchors(); t.icon:SetAnchor(TOP,t,BOTTOM,iconX*scale,(legacyAegis and -58 or -40)*scale)
    t.timer:SetFont(string.format("$(GAMEPAD_MEDIUM_FONT)|%d|soft-shadow-thick",math.floor(self.sv.timerFontSize or 24)))
    t.timer:ClearAnchors(); t.timer:SetAnchor(BOTTOM,t.icon,TOP,0,-2*scale)
end

function CH:ApplyLayout()
    if not self.root then return end
    local sv=self.sv; local scale=clamp(sv.scale,.5,1.5)
    -- Scale dimensions and offsets explicitly. Root transforms caused texture layers to
    -- round independently on console and visibly separate above scale 1.
    self.root:SetScale(1); self.root:ClearAnchors(); self.root:SetAnchor(CENTER,GuiRoot,CENTER,0,sv.verticalOffset)
    local h,s,m=self.bars.health,self.bars.stamina,self.bars.magicka; local width=clamp(sv.barWidth,24,80)*scale
    local balanceSlot=self:NormalizeTrackerSlot(sv.balanceSlot,"bottomLeftInside")
    local aegisSlot=self:NormalizeTrackerSlot(sv.aegisSlot,"topLeftOutside")
    local armamentsSlot=self:NormalizeTrackerSlot(sv.armamentsSlot,"topRightInside")
    local surgeSlot=self:NormalizeTrackerSlot(sv.surgeSlot,"topRightOutside")
    local shroudSlot=self:NormalizeTrackerSlot(sv.shroudSlot,"bottomRightOutside")
    if balanceSlot~=sv.balanceSlot then sv.balanceSlot=balanceSlot end
    if aegisSlot~=sv.aegisSlot then sv.aegisSlot=aegisSlot end
    if armamentsSlot~=sv.armamentsSlot then sv.armamentsSlot=armamentsSlot end
    if surgeSlot~=sv.surgeSlot then sv.surgeSlot=surgeSlot end
    if shroudSlot~=sv.shroudSlot then sv.shroudSlot=shroudSlot end
    self.trackers.balance.slot=balanceSlot
    self.trackers.aegis.slot=aegisSlot
    self.trackers.armaments.slot=armamentsSlot
    self.trackers.surge.slot=surgeSlot
    self.trackers.shroud.slot=shroudSlot
    for _,definitions in ipairs({self.scribingTrackerDefinitions,self.sorcererTrackerDefinitions,self.wardenTrackerDefinitions,self.arcanistTrackerDefinitions,self.nonClassTrackerDefinitions}) do
        for _,definition in ipairs(definitions) do
            local setting=definition.key.."Slot"; local slot=self:NormalizeTrackerSlot(sv[setting],definition.slot)
            if slot~=sv[setting] then sv[setting]=slot end
            self.trackers[definition.key].slot=slot
        end
    end
    h:SetDimensions(width,512*scale); h:ClearAnchors(); h:SetAnchor(CENTER,self.root,CENTER,-sv.spacing*scale,0)
    local inner,outer=sv.staminaInside and s or m,sv.staminaInside and m or s
    if sv.layout=="Stacked" then
        inner:SetDimensions(width,252*scale); outer:SetDimensions(width,252*scale)
        inner:ClearAnchors(); inner:SetAnchor(TOP,self.root,CENTER,sv.spacing*scale,-4*scale); outer:ClearAnchors(); outer:SetAnchor(BOTTOM,self.root,CENTER,sv.spacing*scale,4*scale)
        self:SetBarSegment(inner,"upper"); self:SetBarSegment(outer,"lower")
        self:SetResourceTexture(inner,"standard"); self:SetResourceTexture(outer,"standard")
        local mount=self.mountBar; mount:SetDimensions(width,252*scale)
        mount:ClearAnchors(); mount:SetAnchor(CENTER,s,CENTER,width*.22,0)
        self:SetMountTexture("stacked_outer"); self:SetBarSegment(mount,s.segment)
    else
        local narrow=math.max(20*scale,math.floor(width*.62)); inner:SetDimensions(narrow,512*scale); outer:SetDimensions(narrow,512*scale)
        inner:ClearAnchors(); inner:SetAnchor(CENTER,self.root,CENTER,sv.spacing*scale,0); outer:ClearAnchors(); outer:SetAnchor(CENTER,inner,CENTER,math.max(4*scale,math.floor(narrow*.28))+sv.resourceGap*scale,0)
        self:SetBarSegment(inner,"full"); self:SetBarSegment(outer,"full")
        self:SetResourceTexture(inner,"inner"); self:SetResourceTexture(outer,"outer")
        local mount=self.mountBar; mount:SetDimensions(narrow,512*scale)
        mount:ClearAnchors()
        if sv.staminaInside then
            mount:SetAnchor(CENTER,s,CENTER,-11*scale,0); self:SetMountTexture("parallel_inner")
        else
            mount:SetAnchor(CENTER,s,CENTER,11*scale,0); self:SetMountTexture("parallel_outer")
        end
        self:SetBarSegment(mount,"full")
    end
    self:SyncBarLayers(h); self:SyncBarLayers(s); self:SyncBarLayers(m); self:SyncBarLayers(self.mountBar)
    -- Independent controls keep raw values aligned above percentages on every bar.
    for _,b in pairs(self.bars) do
        b.rawLabel:SetFont(string.format("$(GAMEPAD_MEDIUM_FONT)|%d|soft-shadow-thick",math.floor(sv.resourceValueFontSize or 27)))
        b.percentLabel:SetFont(string.format("$(GAMEPAD_MEDIUM_FONT)|%d|soft-shadow-thick",math.floor(sv.resourcePercentFontSize or 20)))
        b.rawLabel:SetScale(scale); b.percentLabel:SetScale(scale)
    end
    h.rawLabel:ClearAnchors(); h.rawLabel:SetAnchor(CENTER,h,CENTER,0,-20*scale)
    h.percentLabel:ClearAnchors(); h.percentLabel:SetAnchor(CENTER,h,CENTER,0,16*scale)
    s.rawLabel:ClearAnchors(); s.rawLabel:SetAnchor(CENTER,s,CENTER,8*scale,-54*scale); s.percentLabel:ClearAnchors(); s.percentLabel:SetAnchor(CENTER,s,CENTER,8*scale,-24*scale)
    m.rawLabel:ClearAnchors(); m.rawLabel:SetAnchor(CENTER,m,CENTER,8*scale,24*scale); m.percentLabel:ClearAnchors(); m.percentLabel:SetAnchor(CENTER,m,CENTER,8*scale,54*scale)
    for _,t in pairs(self.trackers) do self:ApplyTrackerSlot(t,h,inner,outer,width,scale) end
    self:ApplyProcLayout(scale)
    for _,b in pairs(self.bars) do b.bg:SetAlpha(sv.backgroundAlpha); b.fill:SetAlpha(sv.fillAlpha); b.frame:SetAlpha(sv.frameAlpha); b.rawLabel:SetAlpha(sv.textAlpha); b.percentLabel:SetAlpha(sv.textAlpha) end
    self.mountBar.bg:SetAlpha(sv.backgroundAlpha); self.mountBar.fill:SetAlpha(sv.fillAlpha); self.mountBar.frame:SetAlpha(sv.frameAlpha)
    for _,t in pairs(self.trackers) do t.fill:SetAlpha(sv.fillAlpha); t.frame:SetAlpha(sv.frameAlpha); t.timer:SetAlpha(sv.textAlpha); t.icon:SetAlpha(sv.textAlpha) end
    h.shield:SetAlpha(sv.shieldAlpha); self:UpdateDefaultUI(true); self:UpdateCombatOpacity(); self:UpdateVisibility(); self:UpdateResources(); self:RefreshMajorBuff(); self:RefreshSorcererTrackers(); self:RefreshWardenTrackers(); self:RefreshArcanistTrackers(); self:RefreshAllTrackerIcons(); self:UpdateProcAlert()
end
function CH:UpdateCombatOpacity(inCombat)
    if not self.root or not self.sv then return end
    if inCombat~=nil then self.inCombat=inCombat
    elseif IsUnitInCombat then self.inCombat=IsUnitInCombat("player") end
    local alpha=1
    if self.sv.useOutOfCombatOpacity and not self.sv.preview and not self.inCombat then alpha=clamp(self.sv.outOfCombatOpacity,.05,1) end
    self.root:SetAlpha(alpha)
end

function CH:UpdateDefaultUI(force)
    if not self.sv then return end
    local show=self.sv.showDefaultResources~=false
    local playerFrame=_G["ZO_PlayerAttribute"]
    if playerFrame then
        -- Reassert only the user's hidden choice; otherwise let ESO retain its own
        -- contextual visibility rules for combat, menus, death, and interaction modes.
        if not show then playerFrame:SetHidden(true)
        elseif force or self.defaultResourcesShown==false then playerFrame:SetHidden(false) end
    end

    -- ZOS anchors the self-buff row 40 px above the stock player resource frame.
    -- When that frame is hidden, move the row into its vacated space.
    local buffTop=_G["ZO_BuffDebuffTopLevel"]
    local buffContainer=_G["ZO_BuffDebuffTopLevelSelfContainer"] or (buffTop and buffTop:GetNamedChild("SelfContainer"))
    if buffContainer and (force or self.defaultResourcesShown~=show) then
        buffContainer:ClearAnchors()
        buffContainer:SetAnchor(CENTER,playerFrame or GuiRoot,playerFrame and TOP or BOTTOM,0,show and -40 or (tonumber(self.sv.buffVerticalOffset) or 0))
    end
    self.defaultResourcesShown=show
end
function CH:UpdateVisibility(state)
    if state~=nil then self.hudVisible=state~=SCENE_HIDDEN end
    if self.root then self.root:SetHidden(not(self.sv and self.sv.enabled and (self.sv.preview or self.hudVisible~=false))) end
end
function CH:GetPowerValues(powerType)
    local current,maximum,effective=GetUnitPower("player",powerType)
    if (maximum or 0)>1 then return current,maximum end
    -- Console builds can expose a pool before the type lookup is initialized.
    for i=0,10 do
        local ok,pType,pCurrent,pMax,pEffective=pcall(GetUnitPowerInfo,"player",i)
        if ok and pType==powerType and (pMax or 0)>1 then return pCurrent,pMax end
    end
    return current or 0,maximum or 0
end
function CH:UpdateResources()
    if not self.root or not self.sv.enabled then return end
    local v=self.power
    if self.sv.preview then v={health={32400,40000},stamina={18700,32000},magicka={21100,32500}}
    else
        local hc,hm=self:GetPowerValues(HEALTH_POWER); local sc,sm=self:GetPowerValues(STAMINA_POWER); local mc,mm=self:GetPowerValues(MAGICKA_POWER)
        if hm<=1 then
            local ok,statMax=pcall(GetPlayerStat,STAT_HEALTH_MAX,STAT_BONUS_OPTION_APPLY_BONUS)
            if ok then hm=statMax or 0 end
        end
        if hm and hm>0 then v.health={hc,hm} end; if sm and sm>0 then v.stamina={sc,sm} end; if mm and mm>0 then v.magicka={mc,mm} end
    end
    self:SetBarValue(self.bars.health,v.health[1],v.health[2]); self:SetBarValue(self.bars.stamina,v.stamina[1],v.stamina[2]); self:SetBarValue(self.bars.magicka,v.magicka[1],v.magicka[2])
    local shield=self.sv.preview and 14000 or self:GetShieldValue()
    self:SetTexturePercent(self.bars.health.shield,self.bars.health,shield/math.max(1,v.health[2]))
    local healthValid=(v.health[2] or 0)>1
    local over=healthValid and shield>v.health[2]
    self.bars.health.overcap:SetHidden(not over)
    if over then self.bars.health.overcap:SetAlpha(.45+.55*math.abs(math.sin(GetGameTimeMilliseconds()/350))) end

    local mounted=self.sv.preview or (IsMounted and IsMounted())
    local mountCurrent,mountMax=0,0
    if mounted and MOUNT_POWER then mountCurrent,mountMax=self:GetPowerValues(MOUNT_POWER) end
    if self.sv.preview then mountCurrent,mountMax=72,100 end
    self.mountBar:SetHidden(not mounted or (mountMax or 0)<=1)
    if mounted and (mountMax or 0)>1 then self:SetTexturePercent(self.mountBar.fill,self.mountBar,mountCurrent/mountMax) end
end
function CH:GetShieldValue()
    if GetUnitAttributeVisualizerEffectInfo then
        local ok,value=pcall(GetUnitAttributeVisualizerEffectInfo,"player",ATTRIBUTE_VISUAL_POWER_SHIELDING,STAT_MITIGATION,ATTRIBUTE_HEALTH,HEALTH_POWER)
        if ok then
            self.shieldValue=math.max(0,tonumber(value) or 0)
            return self.shieldValue
        end
    end
    return math.max(0,self.shieldValue or 0)
end
function CH:OnShieldVisual(eventCode,unitTag,visualType,statType,attributeType,powerType,oldOrValue,newOrMax)
    if unitTag~="player" or visualType~=ATTRIBUTE_VISUAL_POWER_SHIELDING then return end
    if attributeType and attributeType~=ATTRIBUTE_HEALTH then return end
    if eventCode==EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED then self.shieldValue=0
    elseif eventCode==EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED then self.shieldValue=math.max(0,tonumber(newOrMax) or 0)
    else self.shieldValue=math.max(0,tonumber(oldOrValue) or 0) end
    self:UpdateResources()
end
function CH:UpdateTrackers()
    local now=GetGameTimeSeconds()
    for _,t in pairs(self.trackers) do
        local enabled=t.key=="resolve" or self.sv[t.key.."Enabled"]~=false
        local active,pct,remaining=t.active and enabled,0,0
        if self.sv.preview and enabled then
            active=true
            if t.stackMaximum then t.stackCount=t.stackMaximum; pct=1 else pct,remaining=.62,12.4 end
        elseif active then
            if t.stackMaximum then
                pct=clamp((tonumber(t.stackCount) or 0)/t.stackMaximum,0,1)
                if pct<=0 then t.active,active=false,false end
            else
                remaining=math.max(0,t.endTime-now); pct=remaining/math.max(.01,t.duration or 0)
                if remaining>0 then pct=math.max(.035,pct) else t.active,active=false,false end
            end
        end
        t:SetHidden(not active)
        if active then
            self:SetTexturePercent(t.fill,t,pct); t.timer:SetText(t.stackMaximum and "" or string.format("%.1f",remaining))
            local expiring=not t.stackMaximum and self.sv.expirationAlerts==true and not t.isNegative and remaining>0 and remaining<=3
            t.expiryAlertActive=expiring; t.expiryBorder:SetHidden(not expiring)
            if expiring then
                local pulse=.5+.5*math.abs(math.sin(GetGameTimeMilliseconds()/240))
                t.timer:SetColor(1,.08,.08,1)
                t.expiryBorder:SetCenterColor(.8,0,0,.05+.10*pulse)
                t.expiryBorder:SetEdgeColor(1,.03,.03,.62+.38*pulse)
            else t.timer:SetColor(1,1,1,1) end
            local stacks=self.sv.preview and t.key=="armaments" and 4 or (tonumber(t.stackCount) or 0)
            t.stackLabel:SetText(tostring(stacks)); t.stackLabel:SetHidden(stacks<=0)
        else
            t.expiryAlertActive=false; t.expiryBorder:SetHidden(true); t.timer:SetColor(1,1,1,1); t.stackLabel:SetHidden(true)
        end
    end
    self:UpdateArmamentsReadyEffect()
end
function CH:MajorBuffMatches(effectName,abilityId)
    local selected=self.sv.majorBuffTracked or "Major Resolve"; if selected=="None" then return false end
    local knownId=MAJOR_BUFF_IDS[selected]
    if knownId and abilityId==knownId then return true end
    local localized=knownId and GetAbilityName and GetAbilityName(knownId) or nil
    return effectName==selected or (localized and localized~="" and effectName==localized)
end
function CH:RefreshMajorBuff()
    local t=self.trackers and self.trackers.resolve; if not t then return end
    t.active,t.stackCount=false,0
    if self.sv.preview or self.sv.majorBuffTracked=="None" or not GetNumBuffs or not GetUnitBuffInfo then return end
    for index=1,GetNumBuffs("player") do
        local name,beginTime,endTime,_,stackCount,iconName,_,_,_,_,abilityId=GetUnitBuffInfo("player",index)
        if self:MajorBuffMatches(name,abilityId) then
            t.active,t.beginTime,t.endTime,t.duration,t.stackCount=true,beginTime or 0,endTime or 0,math.max(.01,(endTime or 0)-(beginTime or 0)),stackCount or 0
            if iconName and iconName~="" then t.icon:SetTexture(iconName) end
            break
        end
    end
end
function CH:RefreshBoundArmaments()
    local t=self.trackers and self.trackers.armaments; if not t then return end
    t.active,t.stackCount=false,0
    if self.sv.preview or self.sv.armamentsEnabled==false or not GetNumBuffs or not GetUnitBuffInfo then return end
    for index=1,GetNumBuffs("player") do
        local name,beginTime,endTime,_,stackCount,iconName,_,_,_,_,abilityId=GetUnitBuffInfo("player",index)
        if abilityId==BOUND_ARMAMENTS_STACK_ID or ((stackCount or 0)>0 and string.find(string.lower(name or ""),"bound armament",1,true)) then
            t.active,t.beginTime,t.endTime,t.duration,t.stackCount=true,beginTime or 0,endTime or 0,math.max(.01,(endTime or 0)-(beginTime or 0)),stackCount or 0
            if iconName and iconName~="" then t.icon:SetTexture(iconName) end
            break
        end
    end
end
function CH:RefreshSorcererTrackers()
    self:RefreshBoundArmaments()
    local surge=self.trackers and self.trackers.surge
    local shroud=self.trackers and self.trackers.shroud
    if surge then surge.active,surge.stackCount=false,0 end
    if shroud then shroud.active,shroud.stackCount=false,0 end
    if shroud then
        self:RefreshShroudBinding()
    end
    if self.sv.preview or not GetNumBuffs or not GetUnitBuffInfo then return end
    for index=1,GetNumBuffs("player") do
        local name,beginTime,endTime,_,stackCount,iconName,_,_,_,_,abilityId=GetUnitBuffInfo("player",index)
        local lowerName=string.lower(name or "")
        local t
        if surge and self.sv.surgeEnabled~=false and (abilityId==CRITICAL_SURGE_EFFECT_ID or string.find(lowerName,"critical surge",1,true)) then t=surge
        elseif shroud and self.sv.shroudEnabled~=false and (string.find(lowerName,"vibrant shroud",1,true) or string.find(lowerName,"shattering spines",1,true) or lowerName=="encase") then t=shroud end
        if t then
            t.active,t.beginTime,t.endTime,t.duration,t.stackCount=true,beginTime or 0,endTime or 0,math.max(.01,(endTime or 0)-(beginTime or 0)),stackCount or 0
            if t~=shroud and iconName and iconName~="" then t.icon:SetTexture(iconName)
            elseif t==shroud and not t.preferredIcon and iconName and iconName~="" then t.icon:SetTexture(iconName) end
        end
    end
end
function CH:RefreshWardenTrackers()
    local tracker=self.trackers and self.trackers.netch; if not tracker then return end
    tracker.active,tracker.stackCount=false,0
    self:RefreshWardenBindings()
    if self.sv.preview or self.sv.netchEnabled==false or not GetNumBuffs or not GetUnitBuffInfo then return end
    local definition=self.wardenTrackerDefinitions[1]
    for index=1,GetNumBuffs("player") do
        local name,beginTime,endTime,_,stackCount,_,_,_,_,_,abilityId=GetUnitBuffInfo("player",index)
        local lowerName=string.lower(name or "")
        if string.find(lowerName,"betty netch",1,true) or string.find(lowerName,"blue betty",1,true) or string.find(lowerName,"bull netch",1,true) then
            local iconPath=self:GetFamilyIcon(definition,name); tracker.preferredIcon=iconPath; tracker.icon:SetTexture(iconPath)
            tracker.active,tracker.beginTime,tracker.endTime,tracker.duration,tracker.stackCount=true,beginTime or 0,endTime or 0,math.max(.01,(endTime or 0)-(beginTime or 0)),stackCount or 0
            self.wardenAbilityIds=self.wardenAbilityIds or {}; self.wardenAbilityIds.netch=abilityId or self.wardenAbilityIds.netch
            break
        end
    end
end
function CH:RefreshCrux()
    local t=self.trackers and self.trackers.crux; if not t then return end
    t.active,t.stackCount=false,0
    if self.sv.preview or self.sv.cruxEnabled==false or not GetNumBuffs or not GetUnitBuffInfo then return end
    local definition=self.arcanistTrackerDefinitions[1]
    for index=1,GetNumBuffs("player") do
        local name,beginTime,endTime,_,stackCount,iconName,_,_,_,_,abilityId=GetUnitBuffInfo("player",index)
        local lowerName=string.lower(name or "")
        if (stackCount or 0)>0 and string.find(lowerName,"crux",1,true) then
            t.active,t.beginTime,t.endTime,t.duration,t.stackCount=true,beginTime or 0,endTime or 0,math.max(.01,(endTime or 0)-(beginTime or 0)),math.min(3,stackCount or 0)
            self:ResolveTrackerIcon(definition,name,abilityId,nil,iconName,t)
            break
        end
    end
end

function CH:RefreshArcanistTrackers()
    self:RefreshCrux()
    self:RefreshArcanistBindings()
end
function CH:IsSoulBurstName(lowerName)
    if lowerName=="soul burst" then return true end
    for _,prefix in ipairs({"binding ","bloody ","chilling ","fiery ","healing ","leashing ","magical ","pestilent ","shocking ","sundering ","warding "}) do
        if lowerName==prefix.."burst" then return true end
    end
    return false
end
function CH:StartCastTracker(t,duration,abilityGraphic,abilityId)
    if not t then return end
    local beginTime=GetGameTimeSeconds(); duration=self:GetConfiguredAbilityDuration(abilityId,duration)
    t.active,t.beginTime,t.endTime,t.duration,t.stackCount=true,beginTime,beginTime+duration,duration,0
    local iconName=t.preferredIcon or abilityGraphic
    if (not iconName or iconName=="") and GetAbilityIcon then iconName=GetAbilityIcon(abilityId) end
    if iconName and iconName~="" then t.icon:SetTexture(iconName); t.preferredIcon=iconName end
    self:UpdateTrackers()
end
function CH:HandleScribingCast(abilityName,abilityGraphic,abilityId,allowActive)
    local lowerName=string.lower(abilityName or "")
    for _,definition in ipairs(self.scribingTrackerDefinitions) do
        local matched=self.scribingAbilityIds and self.scribingAbilityIds[definition.key]==abilityId
        if not matched then
            if definition.key=="soulBurst" then matched=self:IsSoulBurstName(lowerName)
            else for _,needle in ipairs(definition.needles) do if string.find(lowerName,needle,1,true) then matched=true; break end end end
        end
        if matched and self.sv[definition.key.."Enabled"] then
            local tracker=self.trackers[definition.key]
            if allowActive or not tracker.active then self:StartCastTracker(tracker,self.sv[definition.key.."Duration"],abilityGraphic,abilityId) end
            return true
        end
    end
    return false
end

function CH:HandleWardenCast(abilityName,abilityGraphic,abilityId,allowActive)
    local lowerName=string.lower(abilityName or "")
    for _,definition in ipairs(self.wardenTrackerDefinitions) do
        local matched=self:DefinitionMatches(definition,lowerName,abilityId,self.wardenAbilityIds)
        if matched and self.sv[definition.key.."Enabled"] then
            local tracker=self.trackers[definition.key]
            self:ResolveTrackerIcon(definition,abilityName,abilityId,nil,abilityGraphic,tracker)
            local fallback=definition.durations and definition.durations[lowerName] or definition.duration
            if allowActive or not tracker.active then self:StartCastTracker(tracker,fallback,abilityGraphic,abilityId) end
            return true
        end
    end
    return false
end

function CH:HandleSorcererCast(abilityName,abilityGraphic,abilityId,allowActive)
    local lowerName=string.lower(abilityName or "")
    for _,definition in ipairs(self.sorcererTrackerDefinitions) do
        if self:DefinitionMatches(definition,lowerName,abilityId,self.sorcererAbilityIds) and self.sv[definition.key.."Enabled"] then
            local tracker=self.trackers[definition.key]
            self:ResolveTrackerIcon(definition,abilityName,abilityId,nil,abilityGraphic,tracker)
            local fallback=definition.durations and definition.durations[lowerName] or definition.duration
            if allowActive or not tracker.active then self:StartCastTracker(tracker,fallback,abilityGraphic,abilityId) end
            return true
        end
    end
    return false
end

function CH:HandleArcanistCast(abilityName,abilityGraphic,abilityId,allowActive)
    local lowerName=string.lower(abilityName or "")
    for _,definition in ipairs(self.arcanistTrackerDefinitions) do
        if not definition.stackOnly and self:DefinitionMatches(definition,lowerName,abilityId,self.arcanistAbilityIds) and self.sv[definition.key.."Enabled"] then
            local tracker=self.trackers[definition.key]
            self:ResolveTrackerIcon(definition,abilityName,abilityId,nil,abilityGraphic,tracker)
            local fallback=definition.durations and definition.durations[lowerName] or definition.duration
            if allowActive or not tracker.active then self:StartCastTracker(tracker,fallback,abilityGraphic,abilityId) end
            return true
        end
    end
    return false
end


function CH:HandleNonClassCast(abilityName,abilityGraphic,abilityId,allowActive)
    local lowerName=string.lower(abilityName or "")
    for _,definition in ipairs(self.nonClassTrackerDefinitions) do
        if self:DefinitionMatches(definition,lowerName,abilityId,self.nonClassAbilityIds) and self.sv[definition.key.."Enabled"] then
            local tracker=self.trackers[definition.key]
            self:ResolveTrackerIcon(definition,abilityName,abilityId,nil,abilityGraphic,tracker)
            local fallback=definition.durations and definition.durations[lowerName] or definition.duration
            if allowActive or not tracker.active then self:StartCastTracker(tracker,fallback,abilityGraphic,abilityId) end
            return true
        end
    end
    return false
end
function CH:OnEffectChanged(changeType,effectName,unitTag,beginTime,endTime,stackCount,iconName,abilityId)
    if unitTag~="player" then return end
    local lowerName=string.lower(effectName or "")
    if abilityId==CRYSTAL_FRAGMENTS_PROC_EFFECT_ID or string.find(lowerName,"crystal fragments proc",1,true) then
        self.fragmentsEventActive=changeType~=EFFECT_RESULT_FADED
        self.fragmentsEndTime=endTime or 0
        if iconName and iconName~="" and self.procAlert then self.procAlert.icon:SetTexture(iconName) end
        self:UpdateProcAlert()
        return
    end
    local t
    if self:MajorBuffMatches(effectName,abilityId) then t=self.trackers.resolve
    elseif abilityId==48136 or abilityId==48131 or abilityId==48141 then t=self.trackers.balance
    elseif abilityId==24163 then t=self.trackers.aegis
    elseif abilityId==BOUND_ARMAMENTS_STACK_ID then t=self.trackers.armaments
    elseif abilityId==CRITICAL_SURGE_EFFECT_ID or string.find(lowerName,"critical surge",1,true) then t=self.trackers.surge
    elseif string.find(lowerName,"vibrant shroud",1,true) or string.find(lowerName,"shattering spines",1,true) or lowerName=="encase" then
        t=self.trackers.shroud
        local iconPath=self:GetShroudIcon(effectName); t.preferredIcon=iconPath; t.icon:SetTexture(iconPath)
    elseif abilityId==ULFSILD_EFFECT_ID or string.find(lowerName,"ulfsild",1,true) and string.find(lowerName,"contingency",1,true) then t=self.trackers.contingency
    elseif string.find(lowerName,"betty netch",1,true) or string.find(lowerName,"blue betty",1,true) or string.find(lowerName,"bull netch",1,true) then
        t=self.trackers.netch
        local iconPath=self:GetFamilyIcon(self.wardenTrackerDefinitions[1],effectName); t.preferredIcon=iconPath; t.icon:SetTexture(iconPath)
    else
        if self.sv.cruxEnabled and stackCount and stackCount>0 and string.find(lowerName,"crux",1,true) then t=self.trackers.crux end
        for _,group in ipairs({{self.wardenTrackerDefinitions,self.wardenAbilityIds},{self.sorcererTrackerDefinitions,self.sorcererAbilityIds},{self.arcanistTrackerDefinitions,self.arcanistAbilityIds},{self.nonClassTrackerDefinitions,self.nonClassAbilityIds}}) do
            if t then break end
            for _,definition in ipairs(group[1]) do
                if not definition.stackOnly and self.sv[definition.key.."Enabled"] and self:DefinitionMatches(definition,lowerName,abilityId,group[2]) then
                    t=self.trackers[definition.key]
                    self:ResolveTrackerIcon(definition,effectName,abilityId,nil,iconName,t)
                    break
                end
            end
            if t then break end
        end
        local duration=(endTime or 0)-(beginTime or 0)
        if not t and duration>0 and duration<30 and (string.find(lowerName,"bound aegis",1,true) or string.find(lowerName,"bound armor",1,true)) then t=self.trackers.aegis end
        if not t and stackCount and stackCount>0 and string.find(lowerName,"bound armament",1,true) then t=self.trackers.armaments end
    end
    if not t then return end
    local wasActive=t.active
    t.active=changeType~=EFFECT_RESULT_FADED and (endTime or 0)>GetGameTimeSeconds(); t.beginTime,t.endTime=beginTime or 0,endTime or 0
    t.stackCount=stackCount or 0
    local reportedDuration=(endTime or 0)-(beginTime or 0)
    if t.active and (not wasActive or (reportedDuration>0 and reportedDuration<3600)) then t.duration=reportedDuration end
    if t.preferredIcon then t.icon:SetTexture(t.preferredIcon)
    elseif iconName and iconName~="" then t.icon:SetTexture(iconName) end
    self:UpdateTrackers()
end

function CH:CreateHUD()
    self.root=WM:CreateTopLevelWindow("CurvedHUD_Root"); self.root:SetDimensions(900,600); self.root:SetMouseEnabled(false); self.root:SetClampedToScreen(false); self.root:SetDrawTier(DT_HIGH)
    self.bars,self.trackers={},{}; self:CreateBar("health","left",{.85,.1,.1}); self:CreateBar("stamina","right",{.15,.78,.22}); self:CreateBar("magicka","right",{.12,.42,.95})
    self:CreateShield(); self:CreateMountBar(); self:CreateTracker("resolve","bottomLeftOutside","majorBuffColor"); self:CreateTracker("balance","bottomLeftInside","balanceColor","balance"); self:CreateTracker("aegis","topLeftOutside","aegisColor"); self:CreateTracker("armaments","topRightInside","armamentsColor"); self:CreateTracker("surge","topRightOutside","surgeColor"); self:CreateTracker("shroud","bottomRightOutside","shroudColor")
    for _,definitions in ipairs({self.scribingTrackerDefinitions,self.sorcererTrackerDefinitions,self.wardenTrackerDefinitions,self.arcanistTrackerDefinitions,self.nonClassTrackerDefinitions}) do
        for _,definition in ipairs(definitions) do
            self:CreateTracker(definition.key,definition.slot,definition.key.."Color")
            self.trackers[definition.key].stackMaximum=definition.stackMaximum
        end
    end
    local armamentsIcon=GetAbilityIcon and GetAbilityIcon(BOUND_ARMAMENTS_SKILL_ID); if armamentsIcon and armamentsIcon~="" then self.trackers.armaments.icon:SetTexture(armamentsIcon) end
    local armaments=self.trackers.armaments
    local readyBorder=WM:CreateControl("CurvedHUD_armaments_ReadyBorder",armaments,CT_BACKDROP); readyBorder:SetDimensions(44,44); readyBorder:SetAnchor(CENTER,armaments.icon,CENTER); readyBorder:SetDrawLayer(DL_OVERLAY); readyBorder:SetDrawLevel(50); readyBorder:SetCenterColor(1,.78,.2,.9); readyBorder:SetEdgeColor(1,1,1,1); readyBorder:SetHidden(true)
    armaments.icon:SetDrawLayer(DL_OVERLAY); armaments.icon:SetDrawLevel(51); armaments.stackLabel:SetDrawLayer(DL_OVERLAY); armaments.stackLabel:SetDrawLevel(52); armaments.readyBorder=readyBorder
    -- Fixed ESO asset path for Vibrant Shroud; cast/slotted detection may replace
    -- it with Encase or Shattering Spines artwork when those variants are used.
    self:CreateProcAlert(); self:RefreshAllTrackerIcons(); self:ApplyLayout()
end
function CH:RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(self.name,EVENT_POWER_UPDATE,function(_,unitTag,_,powerType,current,maximum,effectiveMaximum)
        if unitTag~="player" then return end
        local key=powerType==HEALTH_POWER and "health" or powerType==STAMINA_POWER and "stamina" or powerType==MAGICKA_POWER and "magicka"
        local usableMax=(maximum or 0)>1 and maximum or (effectiveMaximum or 0)
        if key and usableMax>1 then self.power[key]={current,usableMax}; self:Guard("power event",function() self:UpdateResources() end) end
    end); EVENT_MANAGER:AddFilterForEvent(self.name,EVENT_POWER_UPDATE,REGISTER_FILTER_UNIT_TAG,"player")
    EVENT_MANAGER:RegisterForEvent(self.name.."Effects",EVENT_EFFECT_CHANGED,function(_,changeType,_,effectName,unitTag,beginTime,endTime,stackCount,iconName,_,_,_,_,_,_,abilityId)
        self:Guard("effect event",function() self:OnEffectChanged(changeType,effectName,unitTag,beginTime,endTime,stackCount,iconName,abilityId) end)
    end); EVENT_MANAGER:AddFilterForEvent(self.name.."Effects",EVENT_EFFECT_CHANGED,REGISTER_FILTER_UNIT_TAG,"player")
    EVENT_MANAGER:RegisterForEvent(self.name.."TrackedCasts",EVENT_COMBAT_EVENT,function(_,result,_,abilityName,abilityGraphic,_,sourceName,sourceType,_,_,_,_,_,_,_,_,abilityId)
        if sourceType~=COMBAT_UNIT_TYPE_PLAYER then return end
        local lowerName=string.lower(abilityName or "")
        if self.sv.shroudEnabled and (string.find(lowerName,"vibrant shroud",1,true) or string.find(lowerName,"shattering spines",1,true) or lowerName=="encase") then
            local beginTime=GetGameTimeSeconds(); local t=self.trackers.shroud; t.active,t.beginTime,t.endTime,t.duration=true,beginTime,beginTime+10,10
            local iconPath=self:GetShroudIcon(abilityName); t.preferredIcon=iconPath; t.icon:SetTexture(iconPath)
            self:UpdateTrackers()
        else
            if not self:HandleScribingCast(abilityName,abilityGraphic,abilityId,false) and not self:HandleSorcererCast(abilityName,abilityGraphic,abilityId,false) and not self:HandleWardenCast(abilityName,abilityGraphic,abilityId,false) and not self:HandleArcanistCast(abilityName,abilityGraphic,abilityId,false) then self:HandleNonClassCast(abilityName,abilityGraphic,abilityId,false) end
        end
    end)
    if EVENT_ACTION_SLOT_ABILITY_USED then
        EVENT_MANAGER:RegisterForEvent(self.name.."SlotUsed",EVENT_ACTION_SLOT_ABILITY_USED,function(_,slotNum)
            local ok,id=pcall(GetSlotBoundId,slotNum); if not ok or not id or id<=0 then return end
            local abilityName=GetAbilityName and GetAbilityName(id) or ""; local abilityGraphic=nil
            if GetSlotTexture then local okIcon,icon=pcall(GetSlotTexture,slotNum); if okIcon then abilityGraphic=icon end end
            if not self:HandleScribingCast(abilityName,abilityGraphic,id,true) and not self:HandleSorcererCast(abilityName,abilityGraphic,id,true) and not self:HandleWardenCast(abilityName,abilityGraphic,id,true) and not self:HandleArcanistCast(abilityName,abilityGraphic,id,true) then self:HandleNonClassCast(abilityName,abilityGraphic,id,true) end
        end)
    end
    EVENT_MANAGER:RegisterForEvent(self.name.."Activated",EVENT_PLAYER_ACTIVATED,function() self:Guard("player activation",function() self:ApplyLayout() end) end)
    EVENT_MANAGER:RegisterForEvent(self.name.."Combat",EVENT_PLAYER_COMBAT_STATE,function(_,inCombat) self:Guard("combat opacity",function() self:UpdateCombatOpacity(inCombat) end) end)
    local shieldCallback=function(eventCode,unitTag,visualType,statType,attributeType,powerType,value1,value2)
        self:Guard("shield event",function() self:OnShieldVisual(eventCode,unitTag,visualType,statType,attributeType,powerType,value1,value2) end)
    end
    EVENT_MANAGER:RegisterForEvent(self.name.."ShieldAdded",EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED,shieldCallback)
    EVENT_MANAGER:RegisterForEvent(self.name.."ShieldUpdated",EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED,shieldCallback)
    EVENT_MANAGER:RegisterForEvent(self.name.."ShieldRemoved",EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED,shieldCallback)
    local callback=function(_,state) self:UpdateVisibility(state) end
    SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange",callback); SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange",callback)
    EVENT_MANAGER:RegisterForUpdate(self.updateName,100,function() self:Guard("periodic update",function() self:UpdateResources(); self:RefreshCrux(); self:UpdateTrackers(); self:UpdateProcAlert(); self:UpdateDefaultUI(false) end) end)
end
function CH:Initialize()
    self.globalSV=ZO_SavedVars:NewAccountWide("CurvedHUD_SavedVariables",1,nil,self.defaults)
    self.characterSV=ZO_SavedVars:New("CurvedHUD_CharacterSavedVariables",1,nil,self.characterDefaults)
    -- Preserve the user's existing account-wide tracker choices once when a
    -- character first adopts the new character-specific tracker profile.
    if not self.characterSV.initialized then
        for key in pairs(self.characterKeys) do
            if self.globalSV[key]~=nil then self.characterSV[key]=self.globalSV[key] end
        end
        self.characterSV.initialized=true
    end
    -- Existing code and both settings providers can continue using CH.sv. The
    -- proxy routes only tracker choices to this character; geometry, sizing,
    -- opacity, fonts, and layout remain account-wide.
    self.sv=setmetatable({}, {
        __index=function(_,key) if self.characterKeys[key] then return self.characterSV[key] end return self.globalSV[key] end,
        __newindex=function(_,key,value) if self.characterKeys[key] then self.characterSV[key]=value else self.globalSV[key]=value end end,
    })
    self.power={health={0,0},stamina={0,0},magicka={0,0}}; self.shieldValue=0; self.hudVisible=true
    self:Guard("HUD creation",function() self:CreateHUD() end); self:Guard("settings registration",function() if self.RegisterSettings then self:RegisterSettings() end end); self:Guard("event registration",function() self:RegisterEvents() end)
    SLASH_COMMANDS["/curvedhud"]=function(arg)
        arg=string.lower(arg or "")
        if arg=="preview" then self.sv.preview=not self.sv.preview; self:ApplyLayout()
        elseif arg=="debug" then self.sv.debug=not self.sv.debug; self:Log("Debug "..(self.sv.debug and "enabled" or "disabled"),true)
        elseif arg=="status" then
            local hc,hm,he=GetUnitPower("player",HEALTH_POWER)
            self:Log(string.format("Health API: type=%s current=%s max=%s effective=%s cached=%s/%s shield=%s",tostring(HEALTH_POWER),tostring(hc),tostring(hm),tostring(he),tostring(self.power.health[1]),tostring(self.power.health[2]),tostring(self.shieldValue)),true)
        else self:Log("Loaded "..self.version..". Commands: /curvedhud preview, /curvedhud debug, /curvedhud status",true) end
    end
    self:Log("Loaded "..self.version.."; HUD, shield, and trackers created",true)
end
local function loaded(_,addonName)
    if addonName~=CH.name then return end; EVENT_MANAGER:UnregisterForEvent(CH.name,EVENT_ADD_ON_LOADED); CH:Guard("initialization",function() CH:Initialize() end)
end
EVENT_MANAGER:RegisterForEvent(CH.name,EVENT_ADD_ON_LOADED,loaded)
