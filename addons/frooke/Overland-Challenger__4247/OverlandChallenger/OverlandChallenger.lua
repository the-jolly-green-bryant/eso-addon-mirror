OverlandChallenger = {}
OverlandChallenger.name = "OverlandChallenger"
OverlandChallenger.isUnequipping = false
OverlandChallenger.slotsToUnequip = {}
OverlandChallenger.oldSkillInfo = nil
OverlandChallenger.blockCompanions = false -- Block Companions
OverlandChallenger.isHardMode = false
local OverlandChallengerVariables

-- Armor Slots
local armorSlots = {
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_CHEST,
    EQUIP_SLOT_HAND,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET,
    EQUIP_SLOT_NECK,
    EQUIP_SLOT_RING1,
    EQUIP_SLOT_RING2,
}

local teaLink = "|H0:item:33600:3:1:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"

local defaults = {
    enemyColor = nil,
    enemyBrightness = nil,
    hardModeActive = false,
}

-- Prohibited Skills
local prohibitedScribing = {
    abilityIds   = { [6] = true }, -- Mender's Wounds
    primaries    = { 
        [19] = true, -- Restore Resources
        [20] = true -- Shield
    },
    secondaries  = { 
        [24] = true, -- DoT
        [27] = true, -- Leeching
        [29] = true, -- 3 Status Effect
        [31] = true, -- Class Mastery
        [32] = true, -- HoT
        [33] = true, -- Shield
        [34] = true, -- Druid
        [38] = true, -- Gladiator Tenacity
        [41] = true -- More Martial Damage
    },
    tertiaries   = { 
        [46] = true, -- Savagery
        [48] = true, -- Resolve
        [50] = true, -- Vitality
        --[51] = true, -- Berserk
        [52] = true, -- BrutalitySorcery
        [55] = true, -- Courage
        [56] = true, -- Heroism
        [57] = true, -- IntelectEndurance
        [60] = true, -- Maim
        [61] = true, -- Cowardice
        [63] = true, -- Mangle
        [64] = true, -- Breach
        [65] = true, -- Lifesteal
        [69] = true -- Magickasteal
    },
}

local prohibitedSkills = {

-- Arcanist
    [183709] = true, -- Vitalizing Glyphic
    [193794] = true, -- Glyphic of the Tides
    [193558] = true, -- Resonating Glyphic
    [183537] = true, -- Remedy Cascade
    [186193] = true, -- Cascading Fortune
    [186200] = true, -- Curative Surge
    [183447] = true, -- Chakram Shields
    [186207] = true, -- Chakram of Destiny
    [186209] = true, -- Tidal Chakram
    [183555] = true, -- Arcanist's Domain
    [186229] = true, -- Zena's Empowering Disc
    [186234] = true, -- Reconstructive Domain
    [189791] = true, -- The Unblinking Eye
    [189837] = true, -- The Tide King's Gaze
    [189867] = true, -- The Languid Eye
    [193398] = true, -- Pragmatic Fatecarver
    [186452] = true, -- Tome-Bearer's Inspiration
    [183006] = true, -- Cephaliarch's Flail
    [185842] = true, -- Inspired Scholarship
    [183047] = true, -- Recuperative Treatise
    [185836] = true, -- The Imperfect Ring
    [185839] = true, -- Rune of Displacement
    [182988] = true, -- Fulminating Rune
    [183676] = true, -- Gibbering Shield
    [192372] = true, -- Sanctum of the Abyssal Sea
    [192380] = true, -- Gibbering Shelter
    [183430] = true, -- Runic Sunder
    [186531] = true, -- Runic Embrace
    [185894] = true, -- Runespite Ward
    [185901] = true, -- Spiteward of the Lucid Mind
    [183241] = true, -- Impervious Runeward
    [183648] = true, -- Fatewoven Armor
    [185908] = true, -- Cruxweaver Armor
    [186477] = true, -- Unbreakable Fate
    [185912] = true, -- Runic Defense
    [183401] = true, -- Runeguard of Still Waters
    [186489] = true, -- Runeguard of Freedom

-- Sorcerer
    [23634] = true, -- Summon Storm Atronach
    --[23492] = true, -- Greater Storm Atronach
    [23495] = true, -- Summon Charged Atronach
    [23304] = true, -- Summon Unstable Familiar
    [23319] = true, -- Summon Unstable Clannfear
    [23316] = true, -- Summon Volatile Familiar
    --[24613] = true, -- Summon Winged Twilight
    --[24636] = true, -- Summon Winged Twilight Tormentor
    [24639] = true, -- Summon Twilight Matriarch
    [28418] = true, -- Conjured Ward
    [29489] = true, -- Hardened Ward
    [29482] = true, -- Regenerative Ward 
    [24165] = true, -- Bound Armaments
    [24158] = true, -- Bound Armor
    [24163] = true, -- Bound Aegis
    [28025] = true, -- Encase
    [28308] = true, -- Shattering Spines
    [28311] = true, -- Vibrant Shroud 
    [46331] = true, -- Crystal Weapon
    --[24584] = true, -- Dark Exchange
    --[24595] = true, -- Dark Deal
    --[24589] = true, -- Dark Conversion
    [24785] = true, -- Overload
    [24806] = true, -- Power Overload
    [24804] = true, -- Energy Overload
    [23182] = true, -- Lightning Splash
    [23200] = true, -- Liquid Lightning
    [23205] = true, -- Lightning Flood
    [23210] = true, -- Lightning Forms
    [23231] = true, -- Hurricane
    [23213] = true, -- Boundless Storm
    [23670] = true, -- Surge
    [23674] = true, -- Power Surge
    [23678] = true, -- Critical Surge

-- Templar  
    [26792] = true, -- Bitting Jabs
    [26797] = true, -- Puncturing Sweep
    [22149] = true, -- Focused Charge
    [22161] = true, -- Explosive Charge
    [15540] = true, -- Toppling Charge
    [26188] = true, -- Spear Shards
    [26858] = true, -- Luminous Shards
    [26869] = true, -- Blazing Spear
    [22178] = true, -- Sun Shield
    [22182] = true, -- Radiant Ward
    [22180] = true, -- Blazing Shield
    [21752] = true, -- Nova
    [21755] = true, -- Solar Prison
    [21758] = true, -- Solar Disturbance
    [21755] = true, -- Solar Prison
    [21726] = true, -- Sun Fire
    [21729] = true, -- Vampire's Bane
    [21732] = true, -- Reflective Light
    [22095] = true, -- Solar Barrage
    [21765] = true, -- Purifying Light
    [22006] = true, -- Living Dark
    [63044] = true, -- Radiant Glory
    [26209] = true, -- Restoring Aura
    [26807] = true, -- Radiant Aura
    [26821] = true, -- Repetance
    [22265] = true, -- Cleasing Ritual
    [22259] = true, -- Ritual of Retribution
    [22262] = true, -- Extended Ritual
    [22234] = true, -- Rune Focus
    [22240] = true, -- Channeled Focus
    [22237] = true, -- Restoring Focus

-- Dragonknight
    [28988] = true, -- Dragonknight Standard
    [32958] = true, -- Shifting Standard
    [32947] = true, -- Standard of Might
    [20657] = true, -- Searing Strike
    [20660] = true, -- Burning Embers
    [20668] = true, -- Venomous Claws
    [20944] = true, -- Noxious Breath
    [28967] = true, -- Inferno
    [32853] = true, -- Flames of Oblivion
    [32881] = true, -- Cauterize 
    [32715] = true, -- Ferocious Leap
    [20319] = true, -- Spike Armor
    [20328] = true, -- Hardened Armor
    [20323] = true, -- Volatile Armor
    [21007] = true, -- Protective Scales
    [21014] = true, -- Protective Plate
    [21017] = true, -- Dragon Fire Scale
    [31837] = true, -- Inhale
    [32792] = true, -- Deep Breath
    [32785] = true, -- Draw Essence
    [15957] = true, -- Magma Armor
    [17874] = true, -- Magma Shell
    [17878] = true, -- Corrosive Armor
    [29043] = true, -- Molten Weapons
    [31874] = true, -- Igneous Weapons
    [31888] = true, -- Molten Armaments
    [29071] = true, -- Obsidian Shield
    [29224] = true, -- Igneous Shield
    [32673] = true, -- Fragmented Shield
    [29059] = true, -- Ash Cloud
    [20779] = true, -- Cinder Storm
    [32710] = true, -- Eruption

-- Warden
    [85995] = true, -- Dive
    [85999] = true, -- Cutting Dive
    [86003] = true, -- Screaming Cliff Racer
    [86015] = true, -- Deep Fissure
    [86023] = true, -- Swarm
    [86027] = true, -- Fetcher Infection
    [86031] = true, -- Growing Swarm
    [86050] = true, -- Betty Netch
    [86054] = true, -- Blue Betty
    [86058] = true, -- Bull Netch
    [86037] = true, -- Falcon's Swiftness
    [86041] = true, -- Deceptive Predator
    [86045] = true, -- Bird of Prey
    [85532] = true, -- Secluded Grove
    [85804] = true, -- Enchanted Forest
    [85807] = true, -- Healing Thicket
    [85578] = true, -- Healing Seed
    [85840] = true, -- Budding Seeds
    [85845] = true, -- Corrupting Pollen
    [85552] = true, -- Living Vines
    [85850] = true, -- Leeching Vines
    [85851] = true, -- Living Trellis
    [85539] = true, -- Lotus Flower
    [85854] = true, -- Green Lotus
    [85855] = true, -- Lotus Blossom
    [85564] = true, -- Nature's Grasp
    [85858] = true, -- Nature's Embrace
    [86122] = true, -- Frost Cloak
    [86126] = true, -- Expansive Frost Cloak
    [86130] = true, -- Ice Fortress
    [86169] = true, -- Winter's Revenge
    [86148] = true, -- Artic Wind
    [86152] = true, -- Polar Wind
    [86156] = true, -- Artic Blast
    [86135] = true, -- Crystallized Shield
    [86139] = true, -- Crystallized Slab
    [86143] = true, -- Shimmering Shield

-- Necromancer
    [118279] = true, -- Ravenous Goliath
    [115115] = true, -- Death Scythe
    [118226] = true, -- Ruinous Scythe
    [118223] = true, -- Hungry Scythe
    [115206] = true, -- Bone Armor
    [118237] = true, -- Beckoning Armor
    [118244] = true, -- Summoner's Armor
    [118352] = true, -- Empowering Grasp
    [122388] = true, -- Glacial Colossus
    [115252] = true, -- Boneyard
    [117805] = true, -- Unnerving Boneyard
    [117850] = true, -- Avid Boneyard
    [114317] = true, -- Skeletal Mage
    [118680] = true, -- Skeletal Archer
    [118726] = true, -- Skeletal Arcanist
    [115924] = true, -- Shocking Siphon
    [118763] = true, -- Detonating Siphon
    [118008] = true, -- Mystic Siphon
    [117883] = true, -- Resistant Flesh
    [115710] = true, -- Spirit Mender
    [118912] = true, -- Spirit Guardian
    [118840] = true, -- Intensive Mender
    [115926] = true, -- Restoring Tether
    [118070] = true, -- Braided Tether
    [118122] = true, -- Mortal Coil

-- Nightblade
    [25484] = true, -- Ambush
    [18342] = true, -- Teleport Strike
    [25493] = true, -- Lotus Fan
    [33357] = true, -- Mark Target
    [36968] = true, -- Piercing Mark
    [36967] = true, -- Reaper's Mark
    [61902] = true, -- Grim Focus
    [61927] = true, -- Relentless Focus
    [61919] = true, -- Merciless Resolve
    [33375] = true, -- Blur
    [35414] = true, -- Mirage
    [35419] = true, -- Phantasmal 
    [25377] = true, -- Dark Cloak
    [36485] = true, -- Veil of Blades
    [33195] = true, -- Patch of Darkness
    [36049] = true, -- Twisting Patch
    [36028] = true, -- Refreshing Patch
    [25352] = true, -- Aspect of Terror
    [37470] = true, -- Mass Hysteria
    [37475] = true, -- Manifestation of Terror
    [35434] = true, -- Dark Shade
    [33291] = true, -- Strife
    [34838] = true, -- Funnel Health
    [34835] = true, -- Swallow Soul
    [33326] = true, -- Cripple
    [36943] = true, -- Debilitate
    [36957] = true, -- Crippling Grasp
    [33319] = true, -- Siphoning Strikes
    [36908] = true, -- Leeching Strikes
    [36935] = true, -- Siphoning Attacks
    [33316] = true, -- Drain Power
    [36901] = true, -- Power Extraction
    [36891] = true, -- Sap Essence

-- Two Handed
    --[28279] = true, -- Uppercut
    [38807] = true, -- Wrecking Blow
    --[38814] = true, -- Dizzying Swing
    [28448] = true, -- Critical Charge
    [38788] = true, -- Stampede
    --[38778] = true, -- Critical Rush
    [20919] = true, -- Cleave
    [38754] = true, -- Brawler
    [38745] = true, -- Carve
    --[28302] = true, -- Reverse Slash
    --[38819] = true, -- Executioner
    --[38823] = true, -- Reverse Slice
    [28297] = true, -- Momentum
    [38794] = true, -- Forward Momentum
    [38802] = true, -- Rally
    [83216] = true, -- Berserker Strike
    --[83229] = true, -- Onslaught
    [83238] = true, -- Berserker Rage

-- Dual Wield
    --[28607] = true, -- Flurry
    --[38857] = true, -- Rapid Strikes
    [38846] = true, -- Bloodthirst
    [28379] = true, -- Twin Slashes
    [38839] = true, -- Rending Slashes
    [38845] = true, -- Blood Craze
    --[28591] = true, -- Whirlwind
    --[38861] = true, -- Steel Tornado
    --[38891] = true, -- Whirling Blades
    [28613] = true, -- Blade Cloak
    [38906] = true, -- Deadly Cloak
    [38901] = true, -- Quick Cloak
    [21157] = true, -- Hidden Blade
    [38910] = true, -- Flying Blade
    [38914] = true, -- Shrouded Daggers
    [83600] = true, -- Lacerate
    [85187] = true, -- Rend
    [85179] = true, -- Thrive in Chaos

-- Bow
    --[28882] = true, -- Snipe
    --[38685] = true, -- Lethal Arrow
    --[38687] = true, -- Focused Aim
    [28876] = true, -- Volley
    [38689] = true, -- Endless Hail
    [38695] = true, -- Arrow Barrage
    --[28869] = true, -- Poison Arrow
    [38660] = true, -- Poison Injection
    [38645] = true, -- Venom Arrow
    --[28879] = true, -- Scatter Shot
    --[38672] = true, -- Magnum Shot
    [38669] = true, -- Draining Shot
    --[31271] = true, -- Arrow Spray
    [38701] = true, -- Acid Spray
    --[38705] = true, -- Bombard
    [83465] = true, -- Rapid Fire
    [85257] = true, -- Toxic Barrage
    [85451] = true, -- Ballista

-- Destruction Staff
    --[46340] = true, -- Force Shock
    --[46348] = true, -- Crushing Shock
    --[46356] = true, -- Force Pulse
    [28858] = true, -- Wall of Elements
    [39011] = true, -- Elemental Blockade
    [39052] = true, -- Unstable Wall of Elements
    [29091] = true, -- Destructive Touch
    [38937] = true, -- Destructive Reach
    --[38984] = true, -- Destructive Clench
    [29173] = true, -- Weakness to Elements
    [39095] = true, -- Elemental Drain
    [39089] = true, -- Elemental Susceptibility
    --[28800] = true, -- Impulse
    --[39161] = true, -- Pulsar
    --[39143] = true, -- Elemental Ring
    [83619] = true, -- Elemental Storm
    [83642] = true, -- Eye of the Storm
    [84434] = true, -- Elemental Rage

-- Restoration Staff
    [28385] = true, -- Grand Healing
    [40060] = true, -- Healing Springs
    [40058] = true, -- Illustrious Healing
    [28536] = true, -- Regeneration
    [40076] = true, -- Rapid Regeneration
    [40079] = true, -- Radiating Regeneration
    [37243] = true, -- Blessing of Protection
    [40103] = true, -- Blessing of Restoration
    [40094] = true, -- Combat Prayer
    [37232] = true, -- Steadfast Ward
    [40126] = true, -- Healing Ward
    [40130] = true, -- Ward Ally
    [31531] = true, -- Force Siphon
    [40109] = true, -- Siphon Spirit
    [40116] = true, -- Quick Siphon
    [83552] = true, -- Panacea
    [83850] = true, -- Life Giver
    [85132] = true, -- Light’s Champion

    -- One Hand and Shield
    --[83272] = true, -- Shield Wall (Ultimate)
    --[83310] = true, -- Shield Discipline (Ultimate)
    --[83292] = true, -- Spell Wall (Ultimate)
    [28306] = true, -- Puncture
    [38250] = true, -- Pierce Armor
    [38256] = true, -- Ransack
    --[28304] = true, -- Low Slash
    --[38268] = true, -- Deep Slash
    --[38264] = true, -- Heroic Slash
    [28727] = true, -- Defensive Posture
    --[38317] = true, -- Absorb Missile
    [38312] = true, -- Defensive Stance
    --[28719] = true, -- Shield Charge
    --[38405] = true, -- Invasion
    --[38401] = true, -- Shielded Assault
    --[28365] = true, -- Power Bash
    --[38452] = true, -- Power Slam
    --[38455] = true, -- Reverberating Bash

-- Armor Skills
    [29338] = true, -- Annulment
    [39186] = true, -- Dampen Magic
    [39182] = true, -- Harness Magic
    [29556] = true, -- Evasion
    [39195] = true, -- Shuffle
    [39192] = true, -- Elude
    [29552] = true, -- Unstoppable
    [39205] = true, -- Unstoppable Brute
    [39197] = true, -- Immovable

-- Soul Magic
    [26768] = true, -- Soul Trap
    [40328] = true, -- Soul Splitting Trap
    [40317] = true, -- Consuming Trap

-- Fighters Guild
    --[35721] = true, -- Silver Bolts
    --[40300] = true, -- Silver Shards
    --[40336] = true, -- Silver Leash
    [35737] = true, -- Circle of Protection
    [40181] = true, -- Turn Evil
    [40169] = true, -- Ring of Preservation
    --[35713] = true, -- Dawnbreaker
    [40161] = true, -- Flawless Dawnbreaker
    --[40158] = true, -- Dawnbreaker of Smiting
    [35750] = true, -- Trap Beast
    [40382] = true, -- Barbed Trap
    [40372] = true, -- Lightweight Beast Trap
    [35762] = true, -- Expert Hunter
    [40194] = true, -- Evil Hunter
    [40195] = true, -- Camouflaged Hunter

-- Mages Guild
    --[16536] = true, -- Meteor
    --[40489] = true, -- Ice Comet
    --[40493] = true, -- Shooting Star
    [30920] = true, -- Magelight
    [40478] = true, -- Inner Light
    [40483] = true, -- Radiant Magelight
    [28567] = true, -- Entropy
    [40457] = true, -- Degeneration
    [40452] = true, -- Structured Entropy
    [31632] = true, -- Fire Rune
    [40470] = true, -- Volcanic Rune
    [40465] = true, -- Scalding Rune
    --[31642] = true, -- Equilibrium
    --[40445] = true, -- Spell Symmetry
    [40441] = true, -- Balance

-- Psijic Order
    [103503] = true, -- Accelerate
    [103710] = true, -- Race Against Time
    [103706] = true, -- Channeled Acceleration
    [103623] = true, -- Crushing Weapon
    [103543] = true, -- Mend Wounds
    [103747] = true, -- Mend Spirit
    [103755] = true, -- Symbiosis
    [103492] = true, -- Meditate
    [103652] = true, -- Deep Thoughts
    [103665] = true, -- Introspection

-- Undaunted
    [39489] = true, -- Blood Altar
    [41967] = true, -- Sanguine Altar
    [41958] = true, -- Overwhelming Altar
    [39425] = true, -- Trapping Webs
    [41990] = true, -- Shadow Silk
    [42012] = true, -- Tangling Webs
    [42060] = true, -- Inner Beast
    [39369] = true, -- Bone Shield
    [42138] = true, -- Spiked Bone Shield
    [42176] = true, -- Bone Surge
    [39298] = true, -- Necrotic Orb
    [42028] = true, -- Mystic Orb
    [42038] = true, -- Energy Orb

-- Alliance War
    [61503] = true, -- Vigor
    [61505] = true, -- Echoing Vigor
    [61507] = true, -- Resolving Vigor
    [33376] = true, -- Caltrops
    [40255] = true, -- Anti-Cavalry Caltrops
    [40242] = true, -- Razor Caltrops
    [38573] = true, -- Barrier
    [40237] = true, -- Reviving Barrier
    [40239] = true, -- Replenishing Barrier
    [61489] = true, -- Revealing Flare
    [61519] = true, -- Lingering Flare
    [61524] = true, -- Blinding Flare

}


-------------------------------------------------
-- Fade
-------------------------------------------------
local function FadeInControl(control, duration)
    control:SetAlpha(0)
    control:SetHidden(false)
    local startTime = GetFrameTimeSeconds()
    local function UpdateAlpha()
        local elapsed = GetFrameTimeSeconds() - startTime
        local alpha = math.min(elapsed / duration, 1)
        control:SetAlpha(alpha)
        if alpha >= 1 then
            EVENT_MANAGER:UnregisterForUpdate("OverlandChallenger_FadeIn")
        end
    end
    EVENT_MANAGER:RegisterForUpdate("OverlandChallenger_FadeIn", 16, UpdateAlpha)
end

local function FadeOutControl(control, duration)
    local startTime = GetFrameTimeSeconds()
    local initialAlpha = control:GetAlpha()
    local function UpdateAlpha()
        local elapsed = GetFrameTimeSeconds() - startTime
        local alpha = math.max(initialAlpha * (1 - elapsed / duration), 0)
        control:SetAlpha(alpha)
        if alpha <= 0 then
            control:SetHidden(true)
            EVENT_MANAGER:UnregisterForUpdate("OverlandChallenger_FadeOut")
        end
    end
    EVENT_MANAGER:RegisterForUpdate("OverlandChallenger_FadeOut", 16, UpdateAlpha)
end

-------------------------------------------------
-- Central Message
-------------------------------------------------
local function ShowCenterScreenMessageWithIcon(text)
    if OverlandChallenger_CenterIcon then
        FadeInControl(OverlandChallenger_CenterIcon, 1)
    end
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.LEVEL_UP)
    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_MAJOR_TEXT)
    messageParams:SetText(text)
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    zo_callLater(function()
        if OverlandChallenger_CenterIcon then
            FadeOutControl(OverlandChallenger_CenterIcon, 0.5)
        end
    end, 5000)
end

-------------------------------------------------
-- Water Mark
-------------------------------------------------

-- Fade In
local function ShowChallengerIcon()
    if OverlandChallenger_ChallengerImage then
        OverlandChallenger_ChallengerImage:SetAlpha(0)
        OverlandChallenger_ChallengerImage:SetHidden(false)
        FadeInControl(OverlandChallenger_ChallengerImage, 1) -- fade in 1 second
    end
end

-- Fade out
local function HideChallengerIcon()
    if OverlandChallenger_ChallengerImage then
        FadeOutControl(OverlandChallenger_ChallengerImage, 1) -- fade out 1 second
    end
end


-------------------------------------------------
-- Inventory / Armors
-------------------------------------------------
local function FindItemByLink(itemLink)
    local numSlots = GetBagSize(BAG_BACKPACK)
    for slotIndex = 0, numSlots do
        local slotItemLink = GetItemLink(BAG_BACKPACK, slotIndex)
        if slotItemLink == itemLink then
            return BAG_BACKPACK, slotIndex
        end
    end
    return nil, nil
end

local function IsInChallengeMode()
    for _, slot in ipairs(armorSlots) do
        if GetItemLink(BAG_WORN, slot) ~= "" then
            return false
        end
    end
    return true
end

local function ProcessUnequipQueue()
    if #OverlandChallenger.slotsToUnequip == 0 then
        OverlandChallenger.isUnequipping = false
        return
    end
    local slot = table.remove(OverlandChallenger.slotsToUnequip, 1)
    if GetItemLink(BAG_WORN, slot) ~= "" then
        UnequipItem(slot)
    end
    zo_callLater(ProcessUnequipQueue, 200)
end

local function UnequipAllArmor()
    if OverlandChallenger.isUnequipping then return end
    OverlandChallenger.slotsToUnequip = {}
    for _, slot in ipairs(armorSlots) do
        if GetItemLink(BAG_WORN, slot) ~= "" then
            table.insert(OverlandChallenger.slotsToUnequip, slot)
        end
    end
    if #OverlandChallenger.slotsToUnequip > 0 then
        CHAT_SYSTEM:AddMessage("|cFF0000Overland Challenger:|r removing items...")
        OverlandChallenger.isUnequipping = true
        ProcessUnequipQueue()
    end
end

-------------------------------------------------
-- Skills Queue
-------------------------------------------------
local DVDWorkQueue = {}
DVDWorkQueue.__index = DVDWorkQueue
function DVDWorkQueue:new()
    local q = { first = 1, last = 0 }
    setmetatable(q, self)
    return q
end
function DVDWorkQueue:add(fn)
    self[self.last + 1] = { run = fn }
    self.last = self.last + 1
end
function DVDWorkQueue:pop()
    local value = self[self.first]
    if not self:empty() then
        self[self.first] = nil
        self.first = self.first + 1
    end
    return value
end
function DVDWorkQueue:empty()
    return self.first > self.last
end
function DVDWorkQueue:run()
    if not self:empty() then
        local item = self:pop()
        item.run()
    end
end
function DVDWorkQueue:clear()
    while not self:empty() do
        self:pop()
    end
end

local function Protected(fname)
    if IsProtectedFunction(fname) then
        return function(...) CallSecureProtected(fname, ...) end
    else
        return _G[fname]
    end
end
local ClearSlot = Protected("ClearSlot")

local skillQueue = DVDWorkQueue:new()

local function FindSkillSlot(skillId, bar)
    local category = bar == 1 and HOTBAR_CATEGORY_PRIMARY or HOTBAR_CATEGORY_BACKUP
    for slot = 3, 8 do
        local boundId = GetSlotBoundId(slot, category)
        if boundId == skillId then
            return slot, category
        end
    end
    return nil, nil
end

local function ClearSlotWithBar(slot, category)
    local pair = GetActiveWeaponPairInfo()
    local activeCat = pair == 1 and HOTBAR_CATEGORY_PRIMARY or HOTBAR_CATEGORY_BACKUP

    local skillId = GetSlotBoundId(slot, category)
    local craftedName = skillId and GetCraftedAbilityDisplayName(skillId)
    local skillName = (craftedName and craftedName ~= "" and craftedName) 
                  or (skillId and GetAbilityName(skillId)) 
                  or "Unknown"

    if activeCat == category then
        ClearSlot(slot)
        d("'"..skillName.."' is too strong for this mode and has been removed from the bar "..(category+1))
        zo_callLater(function() skillQueue:run() end, 50)
    else
        EVENT_MANAGER:RegisterForEvent(OverlandChallenger.name .. "_SkillClear", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, 
            function(eventCode, activeWeaponPair, locked)
                local newCat = activeWeaponPair == 1 and HOTBAR_CATEGORY_PRIMARY or HOTBAR_CATEGORY_BACKUP
                if newCat == category then
                    ClearSlot(slot)
                    d("'"..skillName.."' is too strong for this mode and has been removed from the bar "..(category+1))
                    EVENT_MANAGER:UnregisterForEvent(OverlandChallenger.name .. "_SkillClear", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
                    zo_callLater(function() skillQueue:run() end, 50)
                end
            end)
    end
end

local function IsProhibitedScribing(slot, category)
    local abilityId = GetSlotBoundId(slot, category)
    if not abilityId then return false end

    -- se o abilityId for proibido
    if prohibitedScribing.abilityIds[abilityId] then
        return true
    end

    -- checa primário
    for primary in pairs(prohibitedScribing.primaries) do
        if IsCraftedAbilityScriptActive(abilityId, primary) then
            return true
        end
    end

    -- checa secundário
    for secondary in pairs(prohibitedScribing.secondaries) do
        if IsCraftedAbilityScriptActive(abilityId, secondary) then
            return true
        end
    end

    -- checa terciário
    for tertiary in pairs(prohibitedScribing.tertiaries) do
        if IsCraftedAbilityScriptActive(abilityId, tertiary) then
            return true
        end
    end

    return false
end


-- Modifique ClearProhibitedSkills para incluir a checagem de scribing
local function ClearProhibitedSkills()
    for bar = 1, 2 do
        local category = bar == 1 and HOTBAR_CATEGORY_PRIMARY or HOTBAR_CATEGORY_BACKUP
        for slot = 3, 8 do
            local skillId = GetSlotBoundId(slot, category)
            
            -- Verifica habilidades normais
            if skillId and prohibitedSkills[skillId] then
                skillQueue:add(function() ClearSlotWithBar(slot, category) end)
            end

            -- Verifica scribing
            if IsProhibitedScribing(slot, category) then
                skillQueue:add(function() ClearSlotWithBar(slot, category) end)
            end
        end
    end


    skillQueue:run()
end

-----------------------------------------------
-- Block quickslot (Potions)
-----------------------------------------------

local QuickBlockActive = false

local function IsQuickBlocked()
    return QuickBlockActive
end

ZO_PreHook("ZO_ActionBar_CanUseActionSlots", function()
    if IsQuickBlocked() then
        local slotNum = tonumber(debug.traceback():match('keybind = "ACTION_BUTTON_(%d)'))
        if slotNum == 9 then
            d("Quickslot locked!")
            return true -- block slot 9
        end
    end
    return false
end)

-- Function to toggle state
local function EnableQuickBlock()
    QuickBlockActive = true
    d("Quickslot is now locked.")
end

local function DisableQuickBlock()
    QuickBlockActive = false
    d("Quickslot is now unlocked.")
end

-------------------------------------------------
-- Remove and Block Companions
-------------------------------------------------

local function HideCompanion()
    local activeCompanionId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COMPANION)
    if activeCompanionId ~= 0 then
        local cData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(activeCompanionId)
        if cData then
            cData:Use()
            --d("Companion removed by challenge mode!")
        end
    end
end

-------------------------------------------------
-- Buff food (can't change buff food)
-------------------------------------------------

local StopChallenge -- just declared to exist before being used in EnsureFoodBuff

local function EnsureFoodBuff()
    local expectedAbilityId = 61322 -- food buff id
    local hasBuff = false
    local unitTag = "player"
    local numberOfBuffs = GetNumBuffs(unitTag)

    for i = 0, numberOfBuffs do
        local name, _, count, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        if not name then break end
        if abilityId == expectedAbilityId then
            hasBuff = true
            break
        end
    end

    if not hasBuff then
        local bagId, slotIndex = FindItemByLink(teaLink)
        if bagId and slotIndex then
            CallSecureProtected("UseItem", bagId, slotIndex)
            d("|c88FF88Overland Challenger: Correct buff missing, consuming food:|r " .. teaLink)
        else
            d("|cFF5555Overland Challenger: You need " .. teaLink .. " to continue in Challenge Mode!|r")
            StopChallenge()
        end
    end
end

-------------------------------------------------
-- Champion Points lock
-------------------------------------------------

-------------------------------------------------
-- Champion Points lock
-------------------------------------------------

local function ShowCPBlockedMessage()
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.DUEL_FINISHED)
    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_MAJOR_TEXT)
    messageParams:SetText("Challenge Mode active: Champion Points locked!")
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

local function BlockChampionPoints()
    -- Hook to stop CP buying or respec
    ZO_PreHook("PrepareChampionPurchaseRequest", function(respecRequired)
        if OverlandChallenger.isHardMode then
            ShowCPBlockedMessage()
            d("|cFF5555Challenge Mode active: cannot spend Champion Points!|r")
            return true -- cancela a ação
        end
    end)

    -- Hook extra: impedir que qualquer pedido de compra passe
    ZO_PreHook("SendChampionPurchaseRequest", function()
        if OverlandChallenger.isHardMode then
            ShowCPBlockedMessage()
            --d("|cFF5555Challenge Mode active: CP purchase request blocked!|r")
            return true -- cancela o envio
        end
    end)

    -- Hook para impedir uso de slots da hotbar de CP
    ZO_PreHook("GetSlotBoundId", function(slotIndex, hotbarCategory)
        if OverlandChallenger.isHardMode and hotbarCategory == HOTBAR_CATEGORY_CHAMPION then
            return nil -- impede que retorne um ID válido
        end
    end)
end

-------------------------------------------------
-- Toggle Combat Cues
-------------------------------------------------

local function CombatCuesOFF()
    SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_COLOR, "0 0 0 1")
    SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_BRIGHTNESS, "0")
end

local function CombatCuesON()
    -- Restore original settings from SavedVariables
    if OverlandChallengerVariables.enemyColor then
        SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_COLOR, OverlandChallengerVariables.enemyColor)
    end
    if OverlandChallengerVariables.enemyBrightness then
        SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_BRIGHTNESS, OverlandChallengerVariables.enemyBrightness)
    end
end

-- Hide Combat Tips
local function HideCombatTips(_, _)
    if ZO_ActiveCombatTips then
        ZO_ActiveCombatTips:SetHidden(true)
    end
end

-------------------------------------------------
-- Check free Bag Space
-------------------------------------------------

local function HasFreeInventorySlots(requiredSlots)
    local totalSlots = GetBagSize(BAG_BACKPACK)
    local usedSlots = GetNumBagUsedSlots(BAG_BACKPACK)
    local freeSlots = totalSlots - usedSlots
    return freeSlots >= requiredSlots
end

-------------------------------------------------
-- TEST
-------------------------------------------------


-------------------------------------------------
-- Start / Stop Challenge
-------------------------------------------------
local update_timer_period = 3500 -- 3.5 seconds
local player_unit_tag = "player"

local function OnChallengeUpdate()
    if IsUnitInCombat(player_unit_tag) then return end
    if not IsInChallengeMode() then
        UnequipAllArmor()
    end
    EnsureFoodBuff()
    ClearProhibitedSkills(prohibitedSkills)
        if OverlandChallenger.blockCompanions then
        HideCompanion()
    end
end

local function StartChallenge()

    -- If already active in the OverlandChallengerVariables, force it off first
    if OverlandChallengerVariables.hardModeActive then
        CHAT_SYSTEM:AddMessage("|cFF5555Overland Challenger:|r You were already in Challenge Mode, deactivating...")
        StopChallenge()
        return
    end
    
    -- 0 Check conditions to enter the mode
    if IsUnitInCombat("player") then
        CHAT_SYSTEM:AddMessage("|cFF5555Overland Challenger:|r You cannot start the challenge while in combat!")
        return
    end
    if IsUnitDead("player") then
        CHAT_SYSTEM:AddMessage("|cFF5555Overland Challenger:|r You cannot start the challenge while dead!")
        return
    end
    if IsUnitSwimming("player") then
        CHAT_SYSTEM:AddMessage("|cFF5555Overland Challenger:|r You cannot start the challenge while swimming!")
        return
    end

    -- 0.5 Check inventory
    if not HasFreeInventorySlots(10) then
    CHAT_SYSTEM:AddMessage("|cFF5555Overland Challenger:|r You need at least 10 free inventory slots to start the challenge!")
    return
    end

    -- 1️ Check food
    local bagId, slotIndex = FindItemByLink(teaLink)
    if not (bagId and slotIndex) then
        CHAT_SYSTEM:AddMessage("|cFF5555Overland Challenger:|r You need " .. teaLink .. " to start the challenge!")
        return
    end

    -- 2 Check gold
    local myMoney = GetCurrentMoney() or 0
    if myMoney < 3000 then
        d("You need 3,000 gold to reset your Champion Points. You have: " .. math.floor(myMoney))
        return
    end

    -- 3️ Reset CP
    local ok = OverlandChallenger.CPLite:ResetCP()
    if not ok then
        d("Unable to reset Champion Points. Challenge canceled.")
    return
    end

    -- 4️ Consume food
    CallSecureProtected("UseItem", bagId, slotIndex)
    d(zo_strformat("|c88FF88You made a toast to the challenge with <<1>>!|r", teaLink))

    -- 5️ Start the remaining challenge
    SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENABLED, "0")
EVENT_MANAGER:RegisterForEvent(
    OverlandChallenger.name .. "_HideCombatTips",
    EVENT_DISPLAY_ACTIVE_COMBAT_TIP,
    HideCombatTips)
EVENT_MANAGER:RegisterForEvent(
    OverlandChallenger.name .. "_HideCombatTipsRemove",
    EVENT_REMOVE_ACTIVE_COMBAT_TIP,
    HideCombatTips)
    zo_callLater(function() PlayEmoteByIndex(22) end, 2000)

    UnequipAllArmor()
    ClearProhibitedSkills(prohibitedSkills)
    EnableQuickBlock() -- block potions
    OverlandChallenger.blockCompanions = true
    HideCompanion() -- remove companion
    OverlandChallenger.isHardMode = true
    OverlandChallengerVariables.hardModeActive = true -- check on SavedVariables
    ShowChallengerIcon() -- watermark
    CombatCuesOFF() -- disable combat cues
    BlockChampionPoints()


    local message = "Starting Challenge Mode!"
    zo_callLater(function() ShowCenterScreenMessageWithIcon(message) end, 2000)
    CHAT_SYSTEM:AddMessage("|cFF0000Overland Challenger:|r " .. message)


    EVENT_MANAGER:RegisterForUpdate(OverlandChallenger.name .. "_ChallengeTimer", update_timer_period, OnChallengeUpdate)
end

StopChallenge = function()
    EVENT_MANAGER:UnregisterForUpdate(OverlandChallenger.name .. "_ChallengeTimer")
    EVENT_MANAGER:UnregisterForEvent(OverlandChallenger.name .. "_HideCombatTips", EVENT_DISPLAY_ACTIVE_COMBAT_TIP)
    EVENT_MANAGER:UnregisterForEvent(OverlandChallenger.name .. "_HideCombatTipsRemove", EVENT_REMOVE_ACTIVE_COMBAT_TIP)
    SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENABLED, "1")
    d("|c88FF88Normal Mode enabled. Systems restored.|r")
    DisableQuickBlock()
    HideChallengerIcon()
    OverlandChallenger.blockCompanions = false
    OverlandChallenger.isHardMode = false
    OverlandChallengerVariables.hardModeActive = false
    CombatCuesON()--enable combat cues
end

-------------------------------------------------
-- Can't Open Armory System
-------------------------------------------------

local function OnArmoryMenuOpened()
    if OverlandChallengerVariables.hardModeActive then
        d("|cFF5555Overland Challenger:|r Challenge Mode is turned off because you opened the Armory.")
        StopChallenge()
    end
end

-- registra o evento ao carregar o addon
EVENT_MANAGER:RegisterForEvent(OverlandChallenger.name .. "_ArmoryMenu", EVENT_OPEN_ARMORY_MENU, OnArmoryMenuOpened)

-------------------------------------------------
-- Check Box
-------------------------------------------------

local function ShowChallengeConfirm()
    ZO_Dialogs_ShowDialog("OVERLANDCHALLENGER_CHALLENGE_CONFIRM")
        -- If already active in the OverlandChallengerVariables, force it to turn off first
    if OverlandChallengerVariables.hardModeActive then
        CHAT_SYSTEM:AddMessage("|cFF5555Overland Challenger:|r Você já estava no modo desafio, desativando...")
        StopChallenge()
        return
    end
end

ZO_Dialogs_RegisterCustomDialog("OVERLANDCHALLENGER_CHALLENGE_CONFIRM", {
    title = { text = "Overland Challenger" },
    mainText = {
        text = "\n\n\n|ac|t256:256:OverlandChallenger/art/ON-mapicon-GroupBoss.dds|t\n\n\n\n\n|al"
        .. "The Challenge Mode offers a more balanced experience in Delves and Quests.\n\n"
        .. "It is not recommended for World Bosses or other group content.\n\n"
        .. "When activated, your CPs will be reset.\n"
        .. "Use |c00BFFF/savecp|r before and |c00BFFF/restorecp|r when exiting.\n\n"
        .. "Some abilities will be blocked, including:\n"
        .. " • DoT\n"
        .. " • HoT\n"
        .. " • Shields\n"
        .. "(with rare exceptions).\n\n"
        .. "Major Buffs and Debuffs are extremely limited.\n"
        .. "If your skill is removed, consider changing its morph.\n\n"
        .. "Check the list of prohibited skills on the addon's page.\n\n"
        .. "Activating the mode will cost |cFFD7003,000|r gold and reset your CPs.\n\n"
        .. "Do you want to continue?"
    },
    buttons = {
        [1] = {
            text = SI_DIALOG_ACCEPT,
            callback = function()
                StartChallenge()
            end,
        },
        [2] = {
            text = SI_DIALOG_CANCEL,
        },
    },
})

-------------------------------------------------
-- Inicialization
-------------------------------------------------
local function OnAddOnLoaded(event, addonName)
    if addonName ~= OverlandChallenger.name then return end

    OverlandChallengerVariables = ZO_SavedVars:NewCharacterNameSettings("OverlandChallengerVariables", 1, nil, defaults)

    if OverlandChallengerVariables.hardModeActive then
        d("Overland Challenger: Resetting Challenge Mode status after login/reload. Use /challenge to activate it again.")
        StopChallenge()
    end

-- Initializing module ChampionPointsLite
if OverlandChallenger.CPLite then
    -- Declare SavedVariable for module
    OverlandChallenger.CPLite.OverlandChallengerVariables = OverlandChallengerVariables
    OverlandChallenger.CPLite.savedSnapshot = OverlandChallengerVariables.saved or {}
    OverlandChallenger.CPLite:OnLoaded()
end

    SLASH_COMMANDS["/challenge"] = ShowChallengeConfirm
    SLASH_COMMANDS["/challengeoff"] = StopChallenge

    d("Overland Challenger loaded. Use /challenge to start Challenge Mode.")

    if not OverlandChallengerVariables.enemyColor then
        OverlandChallengerVariables.enemyColor = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_COLOR)
    end
    if not OverlandChallengerVariables.enemyBrightness then
        OverlandChallengerVariables.enemyBrightness = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENEMY_BRIGHTNESS)
    end

BlockChampionPoints()

end

EVENT_MANAGER:RegisterForEvent(OverlandChallenger.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
