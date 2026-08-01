-- Inspect Vestige by LuckyRome13
-- Loadout.lua -- reads the LOCAL player's character into the shared data model.
-- Everything here is always available: ESO fully exposes your OWN character.
--
-- Data model produced by IV.BuildOwnLoadout():
--   {
--     meta   = { name, atAccount, class, race, alliance, level, cp, gender, zone, source, ts },
--     gear   = { [equipSlot] = { slot, itemLink, setId, hasSet, setName, trait, quality, enchant } },
--     skills = { primary = {id1..id6}, backup = {id1..id6}, werewolf = {id1..id6}?, ranks = {[id]=1..4} },  -- [6]=ult; werewolf only if WW; ranks = target's I-IV per ability
--     attrs  = { magicka, health, stamina },
--     stats  = { front = {...}, back = {...} },   -- full stat set PER weapon bar; each:
--                { magMax, stamMax, healthMax, dmg, crit, pen, critDmg }   -- back nil until a swap
--     mundus = { id, name } | nil,
--     cp     = { slotted = { starId, ... }, points = { n, ... } },   -- points[i] scales slotted[i]
--     food   = { id, name, icon, itemId?, subtype?, level?, itemLink? } | nil,  -- item fields when resolved
--     curse  = { type="vampire", stage } | { type="werewolf" } | nil,
--     potion = { itemId, subtype, level, name, icon, itemLink } | nil,   -- active quickslot potion
--   }

local IV = InspectVestige

-- Call a possibly-missing/uncertain API without erroring. Returns nil on failure.
local function safeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local results = { pcall(fn, ...) }
    if results[1] then
        return unpack(results, 2)
    end
    return nil
end
IV.safeCall = safeCall

--------------------------------------------------------------------------------
-- Gear
--------------------------------------------------------------------------------
-- Pull the integer data fields out of an item link, in order:
-- [1]=itemId [2]=subtype [3]=level [4]=enchantId [5]=enchantSubtype [6]=enchantLevel ...
-- (subtype+level together encode both display level AND rarity/quality.)
local function parseItemLinkFields(link)
    local fields = {}
    for num in link:gmatch(":(%-?%d+)") do
        fields[#fields + 1] = tonumber(num)
    end
    return fields
end

local function readGearSlot(slot)
    local link = GetItemLink(BAG_WORN, slot, LINK_STYLE_DEFAULT)
    if not link or link == "" then
        return nil
    end

    local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(link, false)
    local trait = GetItemLinkTraitInfo(link)
    local quality = safeCall(GetItemLinkFunctionalQuality, link)
                 or safeCall(GetItemLinkQuality, link)
                 or ITEM_FUNCTIONAL_QUALITY_NORMAL

    -- These raw link fields are transmitted so peers rebuild a faithful link (correct
    -- level, rarity, and enchant/glyph).
    local f = parseItemLinkFields(link)

    return {
        slot         = slot,
        itemLink     = link,
        itemId       = f[1] or 0,
        subtype      = f[2] or 0,
        level        = f[3] or 0,
        enchantId    = f[4] or 0,
        enchantSub   = f[5] or 0,
        enchantLevel = f[6] or 0,
        condCharge   = f[20] or 0,   -- field 20: armor durability(x100) / weapon enchant charges
        setId        = setId or 0,
        hasSet       = hasSet or false,
        setName      = setName or "",
        trait        = trait or ITEM_TRAIT_TYPE_NONE,
        quality      = quality,
    }
end

-- Rebuild a display item link from the transmitted fields. With the real subtype/level
-- and enchant fields the tooltip shows the correct level, rarity, set bonuses and glyph.
-- Fields 7-22 (writ/style/crafted/bound/...) are zeroed; they don't affect the tooltip.
function IV.ReconstructItemLink(itemId, subtype, level, enchantId, enchantSub, enchantLevel, condCharge)
    if not itemId or itemId == 0 then return nil end
    -- Fields 7-22 are zero EXCEPT field 20, which ESO uses for armor durability (x100) and
    -- weapon enchant charges -- transmit it so peer tooltips show real durability & charge
    -- (else both read as 0 / depleted). 13 zeros (fields 7-19), condCharge (20), 2 zeros (21-22).
    return string.format("|H1:item:%d:%d:%d:%d:%d:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:%d:0:0|h|h",
        itemId, subtype or 0, level or 0, enchantId or 0, enchantSub or 0, enchantLevel or 0,
        condCharge or 0)
end

--------------------------------------------------------------------------------
-- Skill bars (slots 3-7 = abilities, slot 8 = ultimate)
--------------------------------------------------------------------------------
local ABILITY_SLOT_FIRST = 3
local ABILITY_SLOT_LAST  = 8

-- Resolve a slotted ability id to the id for its specific morph+RANK. GetSlotBoundId
-- returns a canonical id and SetAbilityId then shows the *viewer's* rank, so we transmit
-- the rank-specific id (each morph+rank is a distinct ability) to make a peer's tooltip
-- read "Stampede IV" for their rank, not the viewer's. Guarded + name-validated so an
-- unexpected result falls back to the original id.
local function rankedAbilityId(id)
    if not id or id == 0 then return id end
    local hasProg, progIndex = safeCall(GetAbilityProgressionXPInfoFromAbilityId, id)
    if not hasProg or not progIndex then return id end
    local _, morph, rank = safeCall(GetAbilityProgressionInfo, progIndex)   -- our morph+rank
    if not morph or not rank then return id end
    local _, _, rankedId = safeCall(GetAbilityProgressionAbilityInfo, progIndex, morph, rank)
    if rankedId and rankedId ~= 0
       and safeCall(GetAbilityName, rankedId) == safeCall(GetAbilityName, id) then
        return rankedId
    end
    return id
end

-- The TARGET's rank (I-IV) for an ability. A peer's skill tooltip shows the *viewer's* rank
-- (SetAbilityId is viewer-scaled) and rank can't be reversed from the id, so we capture it here:
-- GetAbilityProgressionInfo returns OUR morph+rank for the ability's progression (rank is 1-indexed,
-- 4 = IV). nil for non-progression abilities (passives / base). Guarded like the rest.
local function abilityRank(id)
    if not id or id == 0 then return nil end
    local hasProg, progIndex = safeCall(GetAbilityProgressionXPInfoFromAbilityId, id)
    if not hasProg or not progIndex then return nil end
    local _, _, rank = safeCall(GetAbilityProgressionInfo, progIndex)
    if type(rank) == "number" and rank > 0 then return rank end
    return nil
end

-- Scribed/crafted abilities (Gold Road): GetSlotBoundId returns a small CRAFTED ability id
-- (e.g. 2), not a normal ability id, so GetAbilityIcon/SetAbilityId fail (red '?', no
-- tooltip). Map it to the real ability id so icon + tooltip resolve -- and, since it's a
-- normal id afterwards, peers render it with no extra handling. There's no IsCraftedAbilityId,
-- so we confirm it really is crafted via a non-empty crafted display name (a normal ability id
-- is never remapped). Guarded: on a pre-Gold-Road client the functions are absent -> unchanged.
local function resolveCraftedAbility(id)
    if not id or id == 0 then return id end
    local realId = safeCall(GetAbilityIdForCraftedAbilityId, id)
    if realId and realId ~= 0 and realId ~= id then
        local craftedName = safeCall(GetCraftedAbilityDisplayName, id)
        if craftedName and craftedName ~= "" then return realId end
    end
    return id
end

local function readBar(hotbarCategory)
    local bar = {}
    for slot = ABILITY_SLOT_FIRST, ABILITY_SLOT_LAST do
        local abilityId = resolveCraftedAbility(safeCall(GetSlotBoundId, slot, hotbarCategory) or 0)
        bar[#bar + 1] = rankedAbilityId(abilityId)
    end
    return bar
end

--------------------------------------------------------------------------------
-- Attributes
--------------------------------------------------------------------------------
local function readAttributes()
    return {
        magicka = safeCall(GetAttributeSpentPoints, ATTRIBUTE_MAGICKA) or 0,
        health  = safeCall(GetAttributeSpentPoints, ATTRIBUTE_HEALTH)  or 0,
        stamina = safeCall(GetAttributeSpentPoints, ATTRIBUTE_STAMINA) or 0,
    }
end

--------------------------------------------------------------------------------
-- Core derived stats. ESO computes ability tooltips from the CASTER's stats and gives
-- no way to render them for another unit, so we transmit these so the viewer can gauge
-- a group member's actual scaling (shown as a Stats row + appended to skill tooltips).
--------------------------------------------------------------------------------
local function s(stat)
    return safeCall(GetPlayerStat, stat, STAT_BONUS_OPTION_APPLY_BONUS) or 0
end

-- Critical DAMAGE (the % extra damage a crit deals) lives in the Advanced Stats API as stat type
-- 23 ("Critical Damage", category "Damage Bonuses" -- found via /ivdump). Verified against a real
-- client: GetAdvancedStatValue(23) returned (2, nil, 42), and the stat's own in-game tooltip reads
-- "Critical hits do 50% increased damage and can be made more powerful with these additional
-- bonuses, up to a maximum of 125%". So percentValue is the bonus ABOVE the base 50% (42 -> 92%
-- total), and 125 is a HARD cap (U32) -- clamp to it, or an over-capped build would display a
-- number it doesn't actually get. NB: the middle return is nil, so capture positionally --
-- IV.safeCall's unpack would choke on the nil hole. Returns nil if the API is unavailable, and
-- the UI omits the stat.
local ADV_STAT_CRIT_DAMAGE = 23
local CRIT_DAMAGE_BASE     = 50
local CRIT_DAMAGE_CAP      = 125
local function readCritDamage()
    local ok, _, _, pct = pcall(GetAdvancedStatValue, ADV_STAT_CRIT_DAMAGE)
    if not ok or type(pct) ~= "number" then return nil end
    return math.min(CRIT_DAMAGE_CAP, math.floor(CRIT_DAMAGE_BASE + pct + 0.5))
end

-- EVERY derived stat is read from the ACTIVE weapon bar, and many differ between bars:
-- offense (weapon dmg/glyph, Precise/Sharpened traits), crit damage (bar-specific sets), and
-- even Max Mag/Stam/HP ("while slotted" passives like Inner Light / Bound Aegis add max
-- resources on one bar only). GetPlayerStat can't read the inactive bar, so we capture the
-- whole stat set per bar opportunistically as the player weapon-swaps.
local barStats = {}   -- [ACTIVE_WEAPON_PAIR_MAIN|_BACKUP] = { magMax..pen, critDmg }

-- Captures the active bar. Returns true if this bar was NEWLY captured (was absent) -- a
-- discrete event worth pushing to peers (the non-stat broadcast dedup won't re-send a pure
-- stat change on its own).
local function captureActiveBarStats()
    local pair = safeCall(GetActiveWeaponPairInfo)
    if not pair then return false end
    local healthMax = s(STAT_HEALTH_MAX)
    if healthMax <= 0 then return false end   -- stats not ready (e.g. mid-load) -- never cache
                                              -- zeros, or the bar transmits as all-0 not "unsaved"
    local wasNew = (barStats[pair] == nil)
    barStats[pair] = {
        magMax    = s(STAT_MAGICKA_MAX),
        stamMax   = s(STAT_STAMINA_MAX),
        healthMax = healthMax,
        dmg       = s(STAT_SPELL_POWER),      -- post-hybrid: weapon dmg == spell dmg
        crit      = s(STAT_SPELL_CRITICAL),   -- rating; converted to chance % at display
        pen       = s(STAT_SPELL_PENETRATION),
        critDmg   = readCritDamage(),
    }
    return wasNew
end

-- Capture the current bar, refresh an open self-inspect, and -- if a bar became newly
-- available (first swap to the back bar, or the first swap after a loadout change reset the
-- cache) -- force a broadcast so group mates get the now-complete stats promptly (the
-- forced send bypasses the stat-dedup but still respects the load-guard + rate cap).
local function captureAndRefresh()
    local wasNew = captureActiveBarStats()
    if IV.Window and IV.Window.OnBarsCaptured then IV.Window.OnBarsCaptured() end
    if wasNew and IV.Comms and IV.Comms.ScheduleBroadcast then IV.Comms.ScheduleBroadcast(true, "bar-captured") end
end

local function statsEqual(a, b)
    return a and b
        and a.magMax == b.magMax and a.stamMax == b.stamMax and a.healthMax == b.healthMax
        and a.dmg == b.dmg and a.crit == b.crit and a.pen == b.pen and a.critDmg == b.critDmg
end

-- A real loadout change (gear/skill/CP/attribute/food/mundus) shifts stats, so the OTHER
-- (inactive) bar's cache goes stale. But most "change" events also fire when nothing relevant
-- changed -- gear durability/enchant-charge ticks, permanent buffs re-applying, etc. -- and
-- blindly dropping the cache there wiped the inactive bar and re-broadcast an empty back bar to
-- the group EVERY time. So we re-read the ACTIVE bar and only act if its stats ACTUALLY changed:
-- then the inactive bar is genuinely suspect -> drop it (it re-caches on the next weapon swap)
-- and push the fresh active bar. If the active bar is unchanged, do nothing -- don't wipe the
-- inactive bar or spam the channel. (A change that only touches the INACTIVE bar -- e.g. a
-- back-bar weapon -- is invisible from here, but self-heals on the next swap, which recaptures it.)
local function invalidateBarStats()
    -- NEVER touch the cache mid-load. A zone load re-initialises the action bar + inventory (firing
    -- these very "change" events) and re-applies the whole buff storm, which shifts max stats -- so
    -- the comparison below sees a change that never happened, drops the back bar and FORCE-broadcasts
    -- on every single wayshrine (and a forced send skips the dedup, so nothing else stops it).
    -- The `not now` check below is NOT enough: it only catches stats being unreadable, not readable
    -- -but-shifted. You can't change a loadout during a load screen any more than in combat.
    if IV.Comms and IV.Comms.IsLoading and IV.Comms.IsLoading() then return end
    -- NEVER touch the cache in combat. You can't change a loadout mid-fight (no gear/skill/CP/
    -- attribute/food/mundus changes are allowed), so any trigger here is spurious -- and transient
    -- combat buffs inflate the ACTIVE bar's max stats, which would fool the comparison below into
    -- "stats changed" and wipe the inactive bar + re-broadcast on every fight. A real change
    -- re-fires its own event out of combat.
    if safeCall(IsUnitInCombat, "player") then return end
    local pair = safeCall(GetActiveWeaponPairInfo)
    if not pair then return end
    local prev = barStats[pair]
    captureActiveBarStats()               -- re-read + store the active bar (no-op if not ready)
    local now = barStats[pair]
    if not now then return end            -- couldn't read (mid-load) -> leave the cache untouched
    if statsEqual(prev, now) then return end   -- stats unchanged -> keep both bars, no re-broadcast
    for k in pairs(barStats) do
        if k ~= pair then barStats[k] = nil end
    end
    if IV.Window and IV.Window.OnBarsCaptured then IV.Window.OnBarsCaptured() end
    if IV.Comms and IV.Comms.ScheduleBroadcast then IV.Comms.ScheduleBroadcast(true, "stat-invalidate") end
end

-- One-shot debounce: (re)arm `name` to run `fn` after `ms`, coalescing rapid bursts.
local function debounce(name, ms, fn)
    EVENT_MANAGER:UnregisterForUpdate(name)
    EVENT_MANAGER:RegisterForUpdate(name, ms, function()
        EVENT_MANAGER:UnregisterForUpdate(name)
        fn()
    end)
end

-- fwd decl (defined in the mundus/food section below; used by the effect filter in InitStatCapture)
local isFoodIcon, looksLikeMundus

-- Register the weapon-swap capture + loadout-change invalidation. Called once from onAddOnLoaded.
local CAPTURE_TIMER    = IV.name .. "StatsCapture"
local INVALIDATE_TIMER = IV.name .. "StatsInvalidate"
local CAPTURE_SETTLE_MS = 500   -- derived stats keep recomputing for a bit after a swap;
                                -- reading too soon grabs the OLD bar's values (mislabelled).
local INVALIDATE_MS     = 800   -- coalesce rapid changes; fires before Comms' 3s broadcast.
function IV.InitStatCapture()
    captureActiveBarStats()   -- seed the starting bar
    local em, ns = EVENT_MANAGER, IV.name .. "Stats"

    -- Weapon swap -> capture the new bar once it has settled (rapid swap-swap only ever
    -- captures settled states, never a half-updated bar).
    em:RegisterForEvent(ns, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function()
        debounce(CAPTURE_TIMER, CAPTURE_SETTLE_MS, captureAndRefresh)
    end)

    -- Loadout changes -> re-check the active bar and invalidate only if stats really changed.
    local function onChange() debounce(INVALIDATE_TIMER, INVALIDATE_MS, invalidateBarStats) end
    -- Worn-item updates: ignore durability + enchant-charge ticks (they fire nonstop in combat and
    -- never change the loadout). A real equip change uses a different reason and still gets through.
    em:RegisterForEvent(ns, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, _, _, _, _, reason)
        if reason ~= INVENTORY_UPDATE_REASON_DURABILITY_CHANGE
           and reason ~= INVENTORY_UPDATE_REASON_ITEM_CHARGE then
            onChange()
        end
    end)
    em:AddFilterForEvent(ns, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
    em:RegisterForEvent(ns, EVENT_ACTION_SLOT_ABILITY_SLOTTED, onChange)
    em:RegisterForEvent(ns, EVENT_CHAMPION_PURCHASE_RESULT, onChange)
    em:RegisterForEvent(ns, EVENT_ATTRIBUTE_UPGRADE_UPDATED, onChange)
    -- Food / mundus arrive as EVENT_EFFECT_CHANGED -- but so does EVERY other buff. Only react when
    -- the changed effect actually IS the food or the mundus (same icon/name test readBuffs uses):
    -- an ability buff landing or falling off is not a loadout change, and reacting to one wiped the
    -- back bar + re-broadcast to the group. Do NOT go back to a duration/"persistent" check: it
    -- cannot separate them (a FADED event can report no end time, which reads as "permanent"), so
    -- ordinary buffs slipped through -- in combat AND out of it, just from using abilities.
    -- Also skipped in combat (food/mundus can't be applied there) and during a zone load.
    em:RegisterForEvent(ns, EVENT_EFFECT_CHANGED, function(_, _, _, effectName, _, _, _, _, iconName)
        if IV.Comms and IV.Comms.IsLoading and IV.Comms.IsLoading() then return end
        if safeCall(IsUnitInCombat, "player") then return end
        if IV.IsLoadoutEffect(effectName, iconName) then onChange() end
    end)
    em:AddFilterForEvent(ns, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
end

local function readStats()
    captureActiveBarStats()   -- keep the active bar fresh at read time
    return {
        front = barStats[ACTIVE_WEAPON_PAIR_MAIN],    -- full stat set or nil
        back  = barStats[ACTIVE_WEAPON_PAIR_BACKUP],  -- nil until the first weapon swap
    }
end

-- Fresh core stats for the local player (used to live-refresh an open self-inspect).
function IV.GetOwnStats()
    return readStats()
end

--------------------------------------------------------------------------------
-- Mundus + food, read from the player's active buffs
--------------------------------------------------------------------------------
-- A mundus boon shows as a permanent buff (timeEnding == 0). We match by boon name
-- (English), tolerant of a "The " prefix and case. Food/drink is detected via the
-- official GetActiveFoodTypeBonus() gate, then we pick the matching provisioning buff.
function isFoodIcon(icon)
    if type(icon) ~= "string" then return false end
    icon = icon:lower()
    return icon:find("provisioning", 1, true)
        or icon:find("_food", 1, true)
        or icon:find("_drink", 1, true)
        or icon:find("crafting_food", 1, true)
end

function looksLikeMundus(buffName)
    if not buffName or buffName == "" then return false end
    if IV.MUNDUS_NAMES[buffName] then return true end
    -- Tolerate case / missing "The " prefix.
    local stripped = buffName:gsub("^[Tt]he%s+", "")
    for full in pairs(IV.MUNDUS_NAMES) do
        if buffName == full or ("The " .. stripped) == full then return true end
    end
    return false
end

-- Is this EVENT_EFFECT_CHANGED effect part of the LOADOUT (food or mundus)? EVERY buff fires that
-- event, but only food/mundus are loadout changes -- an ability buff landing/falling is not. Shared
-- so the stat-capture invalidation AND the Comms broadcast trigger react to exactly the same effects
-- (reacting to any buff wiped the back bar / churned the broadcast timer -- see the notes at each).
function IV.IsLoadoutEffect(effectName, iconName)
    local icon = (type(iconName) == "string") and iconName:lower() or ""
    return icon:find("mundus", 1, true) ~= nil or looksLikeMundus(effectName) or isFoodIcon(iconName)
end

local function readBuffs()
    local mundus, food
    local bestFoodDuration = -1

    local num = safeCall(GetNumBuffs, "player") or 0
    for i = 1, num do
        local buffName, timeStarted, timeEnding, _, _, icon, _, _, _, _, abilityId, canClickOff =
            GetUnitBuffInfo("player", i)
        local iconLower = (type(icon) == "string") and icon:lower() or ""

        if not mundus and (iconLower:find("mundus", 1, true) or looksLikeMundus(buffName)) then
            -- Buff name is often "Boon: The Thief"; strip the prefix for a clean label.
            local name = buffName and buffName:gsub("^[Bb]oon:%s*", "") or buffName
            mundus = { id = abilityId, name = name }
        elseif timeEnding and timeEnding > 0 and (canClickOff or isFoodIcon(icon)) then
            -- Food/drink is the one *timed* buff you can click off (canClickOff) -- this
            -- reliably identifies it, including event foods whose icons don't match
            -- provisioning patterns. Take the longest if more than one qualifies.
            local duration = timeEnding - (timeStarted or 0)
            if duration > bestFoodDuration then
                bestFoodDuration = duration
                food = { id = abilityId, name = buffName, icon = icon }
            end
        end
    end
    return mundus, food
end

--------------------------------------------------------------------------------
-- Vampire / Werewolf status.
--   Vampire: the always-on "Vampire Stage N" buff -- detected by icon (locale-safe),
--            with the stage read from the icon path (".._stage3..").
--   Werewolf: transformed right now, or the Werewolf world skill line is unlocked.
-- Returns { type = "vampire", stage = n } | { type = "werewolf" } | nil (mortal).
--------------------------------------------------------------------------------
local function readCurse()
    local num = safeCall(GetNumBuffs, "player") or 0
    for i = 1, num do
        local _, _, _, _, _, icon, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        if type(icon) == "string" then
            local low = icon:lower()
            if low:find("vampire", 1, true) then
                return { type = "vampire", stage = tonumber(low:match("stage(%d)")) or 1, id = abilityId }
            end
        end
    end

    if safeCall(IsPlayerInWerewolfForm) then
        return { type = "werewolf" }
    end
    -- The Werewolf (and Vampire) world skill line is listed for EVERYONE, flagged
    -- discovered=false unless you actually have the condition -- so match by name ONLY when
    -- discovered (the 3rd GetSkillLineInfo return: name, rank, discovered). Without this,
    -- every mortal reads as a werewolf.
    local numLines = safeCall(GetNumSkillLines, SKILL_TYPE_WORLD) or 0
    for i = 1, numLines do
        local ok, name, _, discovered = pcall(GetSkillLineInfo, SKILL_TYPE_WORLD, i)
        if ok and discovered and type(name) == "string"
           and zo_strlower(name):find("werewolf", 1, true) then
            return { type = "werewolf" }
        end
    end
    return nil
end

--------------------------------------------------------------------------------
-- Slotted Champion Points (Champion 2.0)
-- Verified against ESO's championassignableactionbar.lua / armorychampionactionbar.lua:
-- the champion bar is a normal action bar. Enumerate its slots via
-- GetAssignableChampionBarStartAndEndSlots() and read each with
-- GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_CHAMPION). Guarded so a mismatch is empty.
--------------------------------------------------------------------------------
-- Returns { slotted = {starId,...}, points = {n,...} } -- points[i] = points invested in
-- slotted[i], which scale a slottable star's bonus (so a peer's tooltip can show THEIR numbers).
local function readSlottedCP()
    local cp = { slotted = {}, points = {} }
    if type(GetAssignableChampionBarStartAndEndSlots) ~= "function" then
        return cp
    end
    local startSlot, endSlot = GetAssignableChampionBarStartAndEndSlots()
    if not startSlot or not endSlot then
        return cp
    end
    local hotbar = HOTBAR_CATEGORY_CHAMPION
    for slotIndex = startSlot, endSlot do
        local skillId = safeCall(GetSlotBoundId, slotIndex, hotbar)
        if skillId and skillId ~= 0 then
            cp.slotted[#cp.slotted + 1] = skillId
            cp.points[#cp.points + 1]   = safeCall(GetNumPointsSpentOnChampionSkill, skillId) or 0
        end
    end
    return cp
end

--------------------------------------------------------------------------------
-- Meta
--------------------------------------------------------------------------------
local function readOwnMeta()
    return {
        name      = GetUnitName("player"),
        atAccount = GetDisplayName(),
        class     = GetUnitClass("player"),
        race      = GetUnitRace("player"),
        alliance  = GetUnitAlliance("player"),
        level     = GetUnitLevel("player"),
        cp        = GetUnitChampionPoints("player"),
        gender    = GetUnitGender("player"),
        zone      = GetUnitZone("player"),
        source    = "self",
        ts        = GetTimeStamp(),
    }
end

--------------------------------------------------------------------------------
-- Cosmetics (the Cosmetics view): per armor/weapon slot the applied OUTFIT style (a style
-- collectible) or, with no outfit on that slot, the item's base motif; plus the collectible
-- cosmetics (costume/skin/hat/personality/polymorph/adornments/markings). All are GLOBAL ids that
-- render on any client (GetCollectibleName/Icon/Link, GetItemStyleName), so they peer-sync like gear.
-- Verified via /ivdump: another player's cosmetics are NOT directly readable (player-self APIs only),
-- and an outfit slot's applied style is a COLLECTIBLE id (GetOutfitSlotInfo's 1st return, 0 = none).
--------------------------------------------------------------------------------

-- A collectible-category constant, or nil if this client doesn't define it (that row is then skipped).
local function cosCat(name) return rawget(_G, "COLLECTIBLE_CATEGORY_TYPE_" .. name) end

-- Is this collectible currently HIDDEN by a higher cosmetic layer (a costume hides body markings /
-- armor, a polymorph hides nearly everything)? -- exactly ESO's own "Hidden by <costume>" test, so
-- we don't hardcode override rules. Mirrors ZO_CollectibleData:IsVisualLayerHidden -- has a visual
-- appearance (so a personality, which has none, is never "hidden") AND would be hidden by the layer
-- above it -- via the C function WouldCollectibleBeHidden. Prefer the data-object method; fall back
-- to the raw C fns. This is a SENDER-side truth (needs the player's live cosmetic combination), so a
-- hidden cosmetic is dropped here at read time -> absent from the view AND the transmitted payload.
local function isCollectibleVisuallyHidden(id)
    if type(id) ~= "number" or id == 0 then return false end
    local pcat = rawget(_G, "GAMEPLAY_ACTOR_CATEGORY_PLAYER") or 0
    local cdm = rawget(_G, "ZO_COLLECTIBLE_DATA_MANAGER")
    if type(cdm) == "table" and type(cdm.GetCollectibleDataById) == "function" then
        local ok, cd = pcall(cdm.GetCollectibleDataById, cdm, id)
        if ok and cd and type(cd.IsVisualLayerHidden) == "function" then
            local ok2, hidden = pcall(cd.IsVisualLayerHidden, cd, pcat)
            if ok2 then return hidden == true end
        end
    end
    -- Fallback: compose it ourselves from the C fns (appearance + would-be-hidden).
    local hasVisual = rawget(_G, "DoesCollectibleHaveVisibleAppearance")
    local wouldHide = rawget(_G, "WouldCollectibleBeHidden")
    if type(wouldHide) == "function" then
        if type(hasVisual) == "function" and safeCall(hasVisual, id) == false then return false end
        local ok3, hidden = pcall(wouldHide, id, pcat)
        if ok3 then return hidden == true end
    end
    return false
end

-- Outfit slot index: prefer the named constant, else the value confirmed via /ivdump (ZOS won't
-- renumber these -- it'd break every saved outfit). Armor 0-6; FRONT weapons 7 (1H main) 8 (1H off)
-- 9 (2H) 10 (bow) 11 (staff) 12 (shield); the BACK bar's weapons have their own slots -- the
-- "_BACKUP" constants, numerically front + 6 (13-18). An out-of-range slot degrades to the base motif.
local function oSlot(name, num) local c = rawget(_G, name); return (type(c) == "number") and c or num end

local ARMOR_OUTFIT_SLOT
local function armorOutfitSlots()
    ARMOR_OUTFIT_SLOT = ARMOR_OUTFIT_SLOT or {
        [EQUIP_SLOT_HEAD]      = oSlot("OUTFIT_SLOT_HEAD", 0),
        [EQUIP_SLOT_CHEST]     = oSlot("OUTFIT_SLOT_CHEST", 1),
        [EQUIP_SLOT_SHOULDERS] = oSlot("OUTFIT_SLOT_SHOULDERS", 2),
        [EQUIP_SLOT_HAND]      = oSlot("OUTFIT_SLOT_HAND", 3),
        [EQUIP_SLOT_WAIST]     = oSlot("OUTFIT_SLOT_WAIST", 4),
        [EQUIP_SLOT_LEGS]      = oSlot("OUTFIT_SLOT_LEGS", 5),
        [EQUIP_SLOT_FEET]      = oSlot("OUTFIT_SLOT_FEET", 6),
    }
    return ARMOR_OUTFIT_SLOT
end

-- Outfits style by weapon TYPE (shared across bars), so map the equipped weapon to its outfit slot.
-- NB: a BACK-bar weapon is styled via its own "_BACKUP" outfit slot -- reading the front slot for it
-- showed the FRONT bar's override on both bars (a real reported bug), because GetOutfitSlotInfo
-- happily answers for whichever slot you pass.
local function weaponOutfitSlot(link, isOffHand, isBackup)
    local wt = safeCall(GetItemLinkWeaponType, link)
    local function pick(name, num)   -- front slot, or its "_BACKUP" twin (numerically front + 6)
        if isBackup then return oSlot(name .. "_BACKUP", num + 6) end
        return oSlot(name, num)
    end
    if wt == WEAPONTYPE_TWO_HANDED_SWORD or wt == WEAPONTYPE_TWO_HANDED_AXE
       or wt == WEAPONTYPE_TWO_HANDED_HAMMER then return pick("OUTFIT_SLOT_WEAPON_TWO_HANDED", 9) end
    if wt == WEAPONTYPE_BOW then return pick("OUTFIT_SLOT_WEAPON_BOW", 10) end
    if wt == WEAPONTYPE_FIRE_STAFF or wt == WEAPONTYPE_FROST_STAFF
       or wt == WEAPONTYPE_LIGHTNING_STAFF or wt == WEAPONTYPE_HEALING_STAFF then
        return pick("OUTFIT_SLOT_WEAPON_STAFF", 11) end
    if wt == WEAPONTYPE_SHIELD then return pick("OUTFIT_SLOT_SHIELD", 12) end
    return isOffHand and pick("OUTFIT_SLOT_WEAPON_OFF_HAND", 8) or pick("OUTFIT_SLOT_WEAPON_MAIN_HAND", 7)
end

-- osid -> outfit-style collectible id. ESO exposes NO reverse lookup, so scan the outfit-style
-- collectibles (category type 24) ONCE, mapping each one's collectibleData:GetReferenceId() (which
-- equals its outfit-style id) to its collectible id, and cache it -- outfit styles don't change
-- mid-session. Built lazily on first use (~8k collectibles, a one-time sweep). This lets a base motif
-- resolve to its true style collectible (rich tooltip + icon), same as an applied outfit override.
local OUTFIT_STYLE_CATEGORY = 24
local styleCollByOsid
local function styleCollectibleForOsid(osid)
    if type(osid) ~= "number" or osid == 0 then return nil end
    if not styleCollByOsid then
        styleCollByOsid = {}
        local cdm = rawget(_G, "ZO_COLLECTIBLE_DATA_MANAGER")
        local getFrom = rawget(_G, "GetCollectibleIdFromType")
        local total = safeCall(GetTotalCollectiblesByCategoryType, OUTFIT_STYLE_CATEGORY) or 0
        if type(cdm) == "table" and type(cdm.GetCollectibleDataById) == "function" and type(getFrom) == "function" then
            for i = 1, total do
                local cid = getFrom(OUTFIT_STYLE_CATEGORY, i)
                local ok, cd = pcall(cdm.GetCollectibleDataById, cdm, cid)
                if ok and cd and cd.GetReferenceId then
                    local ok2, ref = pcall(cd.GetReferenceId, cd)
                    if ok2 and type(ref) == "number" and ref ~= 0 and not styleCollByOsid[ref] then
                        styleCollByOsid[ref] = cid
                    end
                end
            end
        end
    end
    return styleCollByOsid[osid]
end
-- Exposed so the Window resolves a base style's osid -> collectible at DISPLAY time, on whichever
-- client is viewing (self or a peer-receiver). Map is built once + cached (above).
IV.StyleCollectibleForOsid = styleCollectibleForOsid

-- Current dyes for a restyle slot -> { d1, d2, d3 } of dye IDS, or nil when undyed/undyeable.
-- This is the dye UI's own accessor (restyle_shared.lua): GetRestyleSlotCurrentDyes(mode, setIndex,
-- slotType) -- mode EQUIPMENT reads a worn item's saved dyes (slotType = equip slot), OUTFIT reads an
-- outfit slot's (setIndex = outfit index, slotType = outfit slot, incl. the _BACKUP ones), COLLECTIBLE
-- reads a dyeable collectible's (slotType = the collectible CATEGORY type -- costume 4, hat 10).
-- Dye ids are GLOBAL game data, so they transmit as-is and the VIEWER resolves name/RGB
-- (GetDyeInfoById) at display -- same philosophy as the style refs.
local function currentDyes(modeName, setIndex, slotType)
    local mode = rawget(_G, modeName)
    local fn = rawget(_G, "GetRestyleSlotCurrentDyes")
    if type(mode) ~= "number" or type(fn) ~= "function" or type(slotType) ~= "number" then return nil end
    local ok, d1, d2, d3 = pcall(fn, mode, setIndex, slotType)
    if not ok then return nil end
    d1, d2, d3 = tonumber(d1) or 0, tonumber(d2) or 0, tonumber(d3) or 0
    if d1 == 0 and d2 == 0 and d3 == 0 then return nil end   -- fully undyed -> no swatches
    return { d1, d2, d3 }
end

-- Read the local player's cosmetics into the shape the window (and, later, transmission) consume.
function IV.ReadOwnCosmetics()
    local function active(name)
        local cat = cosCat(name)
        local id = cat and safeCall(GetActiveCollectibleByType, cat)
        if type(id) ~= "number" or id == 0 then return nil end
        if isCollectibleVisuallyHidden(id) then return nil end   -- hidden by a higher layer -> omit
        return id
    end

    local cos = {
        slots         = {},   -- [equipSlot] = { ocoll = <outfit-override collectible>, osid = <base style id>, motif = <item style id> } (raw refs; Window resolves)
        costume       = active("COSTUME"),      -- overrides armor appearance when worn (window applies this)
        skin          = active("SKIN"),
        hat           = active("HAT"),
        personality   = active("PERSONALITY"),
        polymorph     = active("POLYMORPH"),
        faceAdornment = active("FACIAL_ACCESSORY"),
        piercing      = active("PIERCING_JEWELRY"),
        headMarking   = active("HEAD_MARKING"),
        bodyMarking   = active("BODY_MARKING"),
        mount         = active("MOUNT"),        -- not character-layer visuals, so never "hidden";
        pet           = active("VANITY_PET"),   -- shown as plain collectible rows
    }

    local pcat = rawget(_G, "GAMEPLAY_ACTOR_CATEGORY_PLAYER") or 0
    local outfitIndex = safeCall(GetEquippedOutfitIndex, pcat)
    if type(outfitIndex) ~= "number" or outfitIndex <= 0 then outfitIndex = nil end
    local armorMap = armorOutfitSlots()
    local defaultSet = rawget(_G, "ZO_RESTYLE_DEFAULT_SET_INDEX") or 1

    -- Dyes on the dyeable collectibles (worn costume / hat).
    if cos.costume then cos.costumeDyes = currentDyes("RESTYLE_MODE_COLLECTIBLE", defaultSet, cosCat("COSTUME")) end
    if cos.hat then cos.hatDyes = currentDyes("RESTYLE_MODE_COLLECTIBLE", defaultSet, cosCat("HAT")) end

    for _, slot in ipairs(IV.GEAR_SLOTS) do
        local isMain   = (slot == EQUIP_SLOT_MAIN_HAND or slot == EQUIP_SLOT_BACKUP_MAIN)
        local isOff    = (slot == EQUIP_SLOT_OFF_HAND or slot == EQUIP_SLOT_BACKUP_OFF)
        local isBackup = (slot == EQUIP_SLOT_BACKUP_MAIN or slot == EQUIP_SLOT_BACKUP_OFF)
        if armorMap[slot] or isMain or isOff then         -- armor + weapons have an appearance; jewelry/poison don't
            local link = GetItemLink(BAG_WORN, slot, LINK_STYLE_DEFAULT)
            if link and link ~= "" then
                local outfitSlot = armorMap[slot] or weaponOutfitSlot(link, isOff, isBackup)
                local motif = safeCall(GetItemLinkItemStyle, link)   -- the item's base style id (for a name)
                if type(motif) ~= "number" or motif == 0 then motif = nil end
                -- Capture RAW style refs; the Window resolves them to a style collectible at DISPLAY time
                -- (via IV.StyleCollectibleForOsid), so the lookup runs on whoever VIEWS -- self OR a
                -- peer-receiver rendering a received build. An applied outfit override is already a
                -- collectible (GetOutfitSlotInfo); a base style keeps its outfit-style id.
                local ocoll, osid
                if outfitIndex and type(outfitSlot) == "number" and outfitSlot >= 0 then
                    -- GetOutfitSlotInfo returns (collectibleId, materialIdx|nil, dye, dye, dye); take
                    -- only the 1st (the nil hole would break safeCall's unpack, so use pcall directly).
                    local ok, v1 = pcall(GetOutfitSlotInfo, pcat, outfitIndex, outfitSlot)
                    if ok and type(v1) == "number" and v1 ~= 0 then ocoll = v1 end
                end
                if not ocoll then
                    local sid = safeCall(GetItemLinkOutfitStyleId, link)   -- base style's outfit-style id
                    if type(sid) == "number" and sid ~= 0 then osid = sid end
                end
                -- Dyes of the VISIBLE appearance: the outfit slot's when an override is applied, else
                -- the worn item's own saved dyes.
                local dyes
                if ocoll then
                    dyes = currentDyes("RESTYLE_MODE_OUTFIT", outfitIndex, outfitSlot)
                else
                    dyes = currentDyes("RESTYLE_MODE_EQUIPMENT", defaultSet, slot)
                end
                if ocoll or osid or motif then
                    cos.slots[slot] = { ocoll = ocoll, osid = osid, motif = motif, dyes = dyes }
                end
            end
        end
    end

    return cos
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

-- Full loadout for the local player.
-- Class skill lines / subclass state (+ equipped Class Mastery passives for a pure class).
-- Subclassing (2025) gives 3 CLASS skill-line slots that can hold lines from up to 3 classes; a PURE
-- class (all 3 are its own) instead equips Class Mastery passives. Detection (verified via /ivdump):
-- the 3 chosen lines are the SKILL_TYPE_CLASS lines with `discovered=true` and a real classId (>0),
-- EXCLUDING the Class Mastery line (its id comes from GetActiveClassMasterySkillLine). pure = all 3
-- belong to GetUnitClassId("player"). Mastery passives = the mastery line's abilities with the
-- `purchased` flag (6th return of GetSkillAbilityInfo) set. All are global ids -> the receiver resolves
-- names/icons at display: skill-line name via SKILLS_DATA_MANAGER:GetSkillLineDataById(id):GetName(),
-- class via GetClassName, passive via GetAbilityName / SetAbilityId.
function IV.ReadClassInfo()
    local ci = { pure = true, lines = {}, mastery = {} }
    local sct = rawget(_G, "SKILL_TYPE_CLASS")
    if not sct then return ci end
    local ownClass = safeCall(GetUnitClassId, "player") or 0
    local sdm = rawget(_G, "SKILLS_DATA_MANAGER")

    -- Class Mastery skill line id(s): exclude them from the "3 chosen" list (they live in the same
    -- SKILL_TYPE_CLASS list, also discovered) and read their equipped passives below.
    local masteryIds = {}
    if type(sdm) == "table" and type(sdm.GetNumActiveClassMasterySkillLines) == "function" then
        local okn, num = pcall(sdm.GetNumActiveClassMasterySkillLines, sdm)
        for i = 1, (okn and tonumber(num) or 0) do
            local okl, line = pcall(sdm.GetActiveClassMasterySkillLine, sdm, i)
            if okl and type(line) == "table" and type(line.GetId) == "function" then
                local mid = select(2, pcall(line.GetId, line))
                if type(mid) == "number" then masteryIds[mid] = true end
            end
        end
    end

    local n = safeCall(GetNumSkillLines, sct) or 0
    for i = 1, n do
        local oki, name, _, discovered = pcall(GetSkillLineInfo, sct, i)   -- name, rank, discovered, ...
        local classId = safeCall(GetSkillLineClassId, sct, i) or 0         -- 0 = no dedicated class (skip)
        local id = safeCall(GetSkillLineId, sct, i)
        if type(id) == "number" and masteryIds[id] then
            -- the mastery line: collect its EQUIPPED (purchased) passives (the pure-class display)
            local na = safeCall(GetNumSkillAbilities, sct, i) or 0
            for j = 1, na do
                local oka, _, _, _, _, _, purchased = pcall(GetSkillAbilityInfo, sct, i, j)   -- ...passive, ultimate, purchased
                if oka and purchased then
                    local aid = safeCall(GetSkillAbilityId, sct, i, j)
                    if type(aid) == "number" and aid ~= 0 then ci.mastery[#ci.mastery + 1] = aid end
                end
            end
        elseif oki and discovered and classId > 0 and type(id) == "number" then
            ci.lines[#ci.lines + 1] = { sl = id, cl = classId }
            if classId ~= ownClass then ci.pure = false end
        end
    end
    return ci
end

-- The quickslot POTION (self only -- there's no API for another player's quickslot, so it transmits
-- like gear). The wheel is read via GetSlotItemLink(idx, HOTBAR_CATEGORY_QUICKSLOT_WHEEL);
-- GetCurrentQuickslot() gives the active wheel index. Fallback order: (1) the ACTIVE quickslot potion
-- (what they'd fire), (2) the character's cached LAST-USED potion (below), (3) scan the wheel for any
-- potion. Captured as item-link fields so a peer rebuilds a faithful tooltip -- crafted potions get a
-- unique itemId per effect-combination, so itemId (+ subtype/level for rarity/scaling) suffice.
local POTION_ITEMTYPE = _G.ITEMTYPE_POTION or 7

-- A potion's tooltip EFFECTS live in the crafted-data link fields (position 16 + the big packed value
-- at 21), NOT in itemId/subtype/level -- so capture those too, to rebuild a faithful peer link.
local function potionFromLink(link)
    if not link or link == "" then return nil end
    local f = parseItemLinkFields(link)
    return {
        itemId   = f[1] or 0,
        subtype  = f[2] or 0,
        level    = f[3] or 0,
        pd1      = f[16] or 0,   -- crafted-data fields carrying the alchemical effects (peer rebuild)
        pd2      = f[21] or 0,
        name     = safeCall(GetItemLinkName, link) or "",
        icon     = safeCall(GetItemLinkIcon, link),
        itemLink = link,   -- self renders this real link; a peer reconstructs from the fields above
    }
end

-- Rebuild a potion link from the transmitted fields. Unlike gear, a potion's effect block needs the
-- crafted-data fields (16 + 21) replaced too -- itemId/subtype/level alone render only the name.
function IV.ReconstructPotionLink(itemId, subtype, level, pd1, pd2)
    if not itemId or itemId == 0 then return nil end
    return string.format("|H1:item:%d:%d:%d:0:0:0:0:0:0:0:0:0:0:0:0:%d:0:0:0:0:%d:0|h|h",
        itemId, subtype or 0, level or 0, pd1 or 0, pd2 or 0)
end

-- Character-specific last-used-potion cache. Stored in the account-wide settings keyed by character
-- id (ids are globally unique, so this is per-character and survives relog). Stores the FULL real
-- link, so a self cached-tooltip is byte-identical to the live one (effects and all).
local function cacheUsedPotion(link)
    if not link or link == "" then return end
    if safeCall(GetItemLinkItemType, link) ~= POTION_ITEMTYPE then return end
    local key = safeCall(GetCurrentCharacterId)
    if not key or not IV.sv then return end
    IV.sv.lastPotion = IV.sv.lastPotion or {}
    IV.sv.lastPotion[key] = link
end

local function cachedUsedPotion()
    local key = safeCall(GetCurrentCharacterId)
    local c = key and IV.sv and IV.sv.lastPotion and IV.sv.lastPotion[key]
    if type(c) == "string" and c ~= "" then return potionFromLink(c) end   -- full real link (current format)
    if type(c) == "table" and c.itemId and c.itemId ~= 0 then              -- legacy entry: name only, no effects
        return potionFromLink(IV.ReconstructPotionLink(c.itemId, c.subtype, c.level, c.pd1, c.pd2))
    end
    return nil
end

local function readPotion()
    local cat = _G.HOTBAR_CATEGORY_QUICKSLOT_WHEEL
    if not cat then return cachedUsedPotion() end   -- can't read the wheel; last-used cache is all we have

    local function potionLinkAt(idx)
        if not idx then return nil end
        local link = safeCall(GetSlotItemLink, idx, cat)
        if not link or link == "" then return nil end        -- empty slot / collectible has no item link
        if safeCall(GetItemLinkItemType, link) ~= POTION_ITEMTYPE then return nil end   -- food/non-potion item
        return link
    end

    -- 1) Active quickslot potion (also refresh the cache so it stays current while a potion is slotted).
    local link = potionLinkAt(safeCall(GetCurrentQuickslot))
    if link then cacheUsedPotion(link); return potionFromLink(link) end

    -- 2) The character's cached last-used potion.
    local cached = cachedUsedPotion()
    if cached then return cached end

    -- 3) Scan the wheel for any potion.
    for idx = 1, 10 do
        link = potionLinkAt(idx)
        if link then return potionFromLink(link) end
    end
    return nil
end

-- ---- Food / drink item (mirrors the potion handling) --------------------------------------------
-- Food is captured as a BUFF; to show its rich ITEM tooltip we resolve the actual food item and
-- transmit its fields (effects come from the itemId, so itemId + subtype + level rebuild a faithful
-- tooltip). There is no buff->item API, and the buff ICON does NOT match the item icon -- but the NAMES
-- match once normalized: they differ only in formatting ("... & Saltrice" buff vs "...-and-Saltrice"
-- item), so we key on the name (lowercased, "&"->"and", non-alphanumerics stripped).
local FOOD_ITEMTYPES = { [_G.ITEMTYPE_FOOD or 4] = true, [_G.ITEMTYPE_DRINK or 12] = true }

local function normFoodName(name)
    if type(name) ~= "string" then return "" end
    return (name:lower():gsub("&", "and"):gsub("[^%w]", ""))
end

-- Find a food/drink ITEM in the backpack whose normalized name matches the active food BUFF's name.
function IV.FindFoodItemByName(buffName)
    local want = normFoodName(buffName)
    if want == "" then return nil end
    for s = 0, (safeCall(GetBagSize, BAG_BACKPACK) or 0) - 1 do
        local link = safeCall(GetItemLink, BAG_BACKPACK, s)
        if link and link ~= "" and FOOD_ITEMTYPES[safeCall(GetItemLinkItemType, link)]
           and normFoodName(safeCall(GetItemLinkName, link)) == want then
            return link
        end
    end
    return nil
end

-- Character-specific last-eaten food cache (like the potion's), storing the full real link.
local function cacheUsedFood(link)
    if not link or link == "" or not FOOD_ITEMTYPES[safeCall(GetItemLinkItemType, link)] then return end
    local key = safeCall(GetCurrentCharacterId)
    if not key or not IV.sv then return end
    IV.sv.lastFood = IV.sv.lastFood or {}
    IV.sv.lastFood[key] = link
end

local function cachedFoodLink()
    local key = safeCall(GetCurrentCharacterId)
    local c = key and IV.sv and IV.sv.lastFood and IV.sv.lastFood[key]
    return (type(c) == "string" and c ~= "") and c or nil
end

-- Resolve the active food BUFF to a food ITEM and merge its transmit fields into `food`. The buff often
-- ISN'T named after the food ("Crown Fortifying Meal" -> buff "Increase All Primary Stats") and its icon
-- differs too, so there's no general match key. Order: (1) a backpack food whose normalized NAME matches
-- the buff -- validated, works for foods whose buff IS the food name (crafted foods); (2) else TRUST the
-- last-eaten cache (the exact food you ate produces the active buff -- same as the potion's last-used
-- cache). No resolution -> stays buff-only.
local function attachFoodItem(food)
    if not food then return end
    local link = (food.name and IV.FindFoodItemByName(food.name)) or cachedFoodLink()
    if not link then return end
    local f = parseItemLinkFields(link)
    food.itemId, food.subtype, food.level = f[1] or 0, f[2] or 0, f[3] or 0
    food.itemLink = link   -- self renders this real link; a peer reconstructs from the fields above
end

-- Cache the character's last-USED potion AND last-eaten food/drink: both are consumed from the backpack
-- (a negative stack change). Selling/destroying also fires this, but re-caching an item you own is
-- harmless (and the food attach re-checks the icon against the active buff). Registered once from
-- onAddOnLoaded (own namespace so its bag filter doesn't clash with StatCapture's).
function IV.InitConsumableTracking()
    local em, ns = EVENT_MANAGER, IV.name .. "Consumable"
    em:RegisterForEvent(ns, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        function(_, bagId, slotId, _, _, _, stackCountChange)
            if not stackCountChange or stackCountChange >= 0 then return end   -- only consumption
            local link = safeCall(GetItemLink, bagId, slotId)
            cacheUsedPotion(link)   -- no-op unless it's a potion
            cacheUsedFood(link)     -- no-op unless it's food/drink
        end)
    em:AddFilterForEvent(ns, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
end

function IV.BuildOwnLoadout()
    local gear = {}
    for _, slot in ipairs(IV.GEAR_SLOTS) do
        gear[slot] = readGearSlot(slot)
    end

    local mundus, food = readBuffs()
    if food then attachFoodItem(food) end   -- resolve the food ITEM (for its rich tooltip), like the potion
    local curse = readCurse()

    local skills = {
        primary = readBar(HOTBAR_CATEGORY_PRIMARY),
        backup  = readBar(HOTBAR_CATEGORY_BACKUP),
    }
    -- Werewolves have a third (transformation) action bar -- read + share it so a viewer can
    -- see their werewolf kit. Only for werewolves; vampires have no separate bar. Only include
    -- it if actually populated (the bar may read empty in human form on some clients -> no
    -- point showing an empty toggle).
    if curse and curse.type == "werewolf" and _G.HOTBAR_CATEGORY_WEREWOLF then
        local ww = readBar(HOTBAR_CATEGORY_WEREWOLF)
        for _, id in ipairs(ww) do
            if id and id ~= 0 then skills.werewolf = ww; break end
        end
    end
    -- Per-ability rank (I-IV). The tooltip's rank numeral is viewer-derived and rank is NOT
    -- recoverable from the ability id, so capture OUR (the target's) rank per ability and transmit
    -- it as skills.ranks[id]; the viewer appends "Target's skill level: N". Keyed by the same
    -- (already rank-resolved) id we transmit, so a viewer looks it up directly.
    local ranks = {}
    local function addBarRanks(bar)
        if not bar then return end
        for _, id in ipairs(bar) do
            if id and id ~= 0 and ranks[id] == nil then ranks[id] = abilityRank(id) end
        end
    end
    addBarRanks(skills.primary)
    addBarRanks(skills.backup)
    addBarRanks(skills.werewolf)
    skills.ranks = ranks

    return {
        meta   = readOwnMeta(),
        gear   = gear,
        skills = skills,
        attrs  = readAttributes(),
        stats  = readStats(),
        mundus = mundus,
        cp     = readSlottedCP(),
        food   = food,
        curse  = curse,
        potion = readPotion(),
        class  = IV.ReadClassInfo(),
        cosmetics = IV.ReadOwnCosmetics(),   -- Cosmetics view; NOT in BuildOwnBuildPayload (separate channel)
    }
end

-- Just the build portion (gear/skills/attrs/mundus/cp/food) that we transmit to
-- peers. Meta is intentionally omitted: the receiver derives it locally from the
-- sender's group unit tag, saving bytes on the tiny group channel.
function IV.BuildOwnBuildPayload()
    local full = IV.BuildOwnLoadout()
    return {
        gear   = full.gear,
        skills = full.skills,
        attrs  = full.attrs,
        stats  = full.stats,
        mundus = full.mundus,
        cp     = full.cp,
        food   = full.food,
        curse  = full.curse,
        potion = full.potion,
        class  = full.class,
    }
end
