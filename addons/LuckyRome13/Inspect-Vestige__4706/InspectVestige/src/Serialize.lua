-- Inspect Vestige by LuckyRome13
-- Serialize.lua -- OWNS the wire format for transmitting a build over LibGroupBroadcast.
--
-- v3: a bit-packed LGB typed-field schema (was v2's ASCII "IV2;..." string). ~2x smaller and
-- quicker to trickle over the shared ~30 B/s channel. Meta is NOT included -- the receiver rebuilds
-- it from the sender's group unit tag.
--
-- Three pieces, all here so the schema and the value-mapping can't drift apart:
--   * IV.BuildLoadoutSchema(LGB) -> the single VariantField added to the protocol (Comms.Init).
--       variants: req (group index) | hi (presence beacon) | fo (friends-only refusal) | build.
--   * IV.EncodeBuild(build, friendsOnly) -> the `build` variant's value table (what you Send).
--   * IV.DecodeBuild(values)             -> our Loadout `build` table (from what OnData gives).
--   * IV.SignatureOf(build)              -> broadcast-dedup signature of the NON-VOLATILE fields.
--
-- Field sizes are generous (item/ability/enchant ids get 21 bits; the small item-link fields 16)
-- and every NumericField uses trimValues=true, so an unexpected out-of-range value is CLAMPED
-- rather than failing the whole Send -- a wrong guess degrades one field, it never bricks peer sync.
-- WIRE BREAK: this reuses protocol id 420 with a new schema, so a v2 (old) peer and a v3 peer can't
-- decode each other -- both sides must update. (Chosen over a second reserved id for simplicity.)

local IV = InspectVestige

local ID_MAX = 2 ^ 21 - 1   -- item / ability / enchant ids (~2M; real max is ~200k, huge headroom)

local function n(v) return math.floor((tonumber(v) or 0) + 0.5) end

local function joinIds(list, sep)
    local out = {}
    for i = 1, #(list or {}) do out[i] = n(list[i]) end
    return table.concat(out, sep)
end

--------------------------------------------------------------------------------
-- Schema (built in Comms.Init, which passes in LGB)
--------------------------------------------------------------------------------
function IV.BuildLoadoutSchema(LGB)
    -- numeric field with clamping; num(label, maxValue[, minValue])
    local function num(label, maxValue, minValue)
        return LGB.CreateNumericField(label,
            { minValue = minValue or 0, maxValue = maxValue, trimValues = true })
    end

    local gearRec = LGB.CreateTableField("gear", {
        num("slot", 63), num("it", ID_MAX), num("st", 65535), num("lv", 65535),
        num("ei", ID_MAX), num("es", 65535), num("el", 65535), num("tr", 63), num("cc", 65535),
    })
    local function skillBar(label)   -- 6 slots (3..8), each {id, rank 0-4}; maxLength 8 = headroom
        return LGB.CreateArrayField(
            LGB.CreateTableField(label, { num("id", ID_MAX), num("rk", 7) }), { maxLength = 8 })
    end
    local cpRec = LGB.CreateTableField("cp", { num("sr", ID_MAX), num("pt", 255) })
    local clsRec = LGB.CreateTableField("cls", { num("sl", ID_MAX), num("cl", 255) })   -- class line + its classId
    local mpRec  = LGB.CreateTableField("mp", { num("a", ID_MAX) })                      -- an equipped mastery passive
    local function statTable(label)  -- magMax stamMax hpMax dmg crit pen critDmg
        return LGB.CreateTableField(label, {
            num("m", 262143), num("s", 262143), num("h", 262143),
            num("d", 262143), num("c", 262143), num("p", 262143), num("cd", 255),
        })
    end

    local build = LGB.CreateTableField("build", {
        LGB.CreateFlagField("fr"),                                  -- friends-only marker
        LGB.CreateArrayField(gearRec, { maxLength = 20 }),          -- 16 equip slots today; headroom (exceeding maxLength fails the whole Send)
        skillBar("sf"), skillBar("sb"), skillBar("sw"),            -- sw empty = no werewolf bar
        num("am", 127), num("ah", 127), num("as", 127),           -- attribute points
        num("mn", ID_MAX),                                         -- mundus id (0 = none)
        LGB.CreateArrayField(cpRec, { maxLength = 16 }),
        num("fd", ID_MAX),                                         -- food buff id (0 = none)
        num("fdi", ID_MAX), num("fds", 65535), num("fdl", 65535),  -- resolved food ITEM (fdi 0 = unresolved)
        num("cu", 31),                                             -- curse: 0 none / 1 ww / 10+stage vamp
        LGB.CreateFlagField("hf"), statTable("stf"),              -- front stats (hf = present)
        LGB.CreateFlagField("hb"), statTable("stb"),              -- back stats  (hb = present)
        LGB.CreateFlagField("pu"),                               -- pure class (vs subclassing)
        LGB.CreateArrayField(clsRec, { maxLength = 4 }),         -- the 3 chosen class skill lines
        LGB.CreateArrayField(mpRec, { maxLength = 10 }),         -- equipped Class Mastery passives (pure)
        num("poi", ID_MAX), num("pos", 65535), num("pol", 65535),   -- quickslot potion item (poi 0 = none)
        num("pd1", 65535), num("pd2", 2 ^ 32 - 1),                  -- potion crafted-data fields (its effects)
    })

    return LGB.CreateVariantField({
        num("req", 24, 1),            -- inspect request: target group index (1..24)
        LGB.CreateFlagField("hi"),    -- presence beacon
        LGB.CreateFlagField("fo"),    -- "I only share with friends" refusal
        build,
    })
end

--------------------------------------------------------------------------------
-- Encode: our Loadout `build` table -> the `build` variant's value table
--------------------------------------------------------------------------------
function IV.EncodeBuild(build, friendsOnly)
    build = build or {}
    local v = { fr = friendsOnly and true or false }

    v.gear = {}
    for _, slot in ipairs(IV.GEAR_SLOTS) do
        local g = build.gear and build.gear[slot]
        if g then
            v.gear[#v.gear + 1] = {
                slot = n(slot), it = n(g.itemId), st = n(g.subtype), lv = n(g.level),
                ei = n(g.enchantId), es = n(g.enchantSub), el = n(g.enchantLevel),
                tr = n(g.trait), cc = n(g.condCharge),
            }
        end
    end

    local sk = build.skills or {}
    local ranks = sk.ranks or {}
    local function bar(list)
        local out = {}
        for _, id in ipairs(list or {}) do
            out[#out + 1] = { id = n(id), rk = n(ranks[id] or 0) }
        end
        return out
    end
    v.sf, v.sb, v.sw = bar(sk.primary), bar(sk.backup), bar(sk.werewolf)

    local a = build.attrs or {}
    v.am, v.ah, v.as = n(a.magicka), n(a.health), n(a.stamina)
    v.mn = (build.mundus and n(build.mundus.id)) or 0
    v.fd = (build.food and n(build.food.id)) or 0
    v.fdi = (build.food and build.food.itemId and n(build.food.itemId)) or 0
    v.fds = (build.food and build.food.subtype and n(build.food.subtype)) or 0
    v.fdl = (build.food and build.food.level and n(build.food.level)) or 0

    v.cp = {}
    local cp = build.cp
    if cp and cp.slotted then
        for i, id in ipairs(cp.slotted) do
            v.cp[#v.cp + 1] = { sr = n(id), pt = n(cp.points and cp.points[i] or 0) }
        end
    end

    local cu = 0
    if build.curse then
        if build.curse.type == "werewolf" then cu = 1
        elseif build.curse.type == "vampire" then cu = 10 + (build.curse.stage or 1) end
    end
    v.cu = cu

    local st = build.stats or {}
    local function statVals(t)
        t = t or {}
        return { m = n(t.magMax), s = n(t.stamMax), h = n(t.healthMax),
                 d = n(t.dmg), c = n(t.crit), p = n(t.pen), cd = n(t.critDmg) }
    end
    v.hf, v.stf = st.front and true or false, statVals(st.front)
    v.hb, v.stb = st.back and true or false, statVals(st.back)

    local cls = build.class or {}
    v.pu = cls.pure and true or false
    v.cls = {}
    for _, l in ipairs(cls.lines or {}) do v.cls[#v.cls + 1] = { sl = n(l.sl), cl = n(l.cl) } end
    v.mp = {}
    for _, id in ipairs(cls.mastery or {}) do v.mp[#v.mp + 1] = { a = n(id) } end

    local po = build.potion
    v.poi, v.pos, v.pol = po and n(po.itemId) or 0, po and n(po.subtype) or 0, po and n(po.level) or 0
    v.pd1, v.pd2 = po and n(po.pd1) or 0, po and n(po.pd2) or 0

    return v
end

--------------------------------------------------------------------------------
-- Decode: the `build` variant value table -> our Loadout `build` table
--------------------------------------------------------------------------------
function IV.DecodeBuild(v)
    if type(v) ~= "table" then return nil end
    local build = { gear = {}, skills = {}, attrs = {}, cp = { slotted = {}, points = {} } }

    for _, r in ipairs(v.gear or {}) do
        -- NOTE: EQUIP_SLOT_HEAD == 0, so slot 0 is valid.
        build.gear[r.slot] = {
            slot = r.slot, itemId = r.it or 0, subtype = r.st or 0, level = r.lv or 0,
            enchantId = r.ei or 0, enchantSub = r.es or 0, enchantLevel = r.el or 0,
            trait = r.tr or 0, condCharge = r.cc or 0,
        }
    end

    local ranks = {}
    local function bar(arr)
        local ids = {}
        for _, e in ipairs(arr or {}) do
            ids[#ids + 1] = e.id or 0
            if e.rk and e.rk > 0 then ranks[e.id or 0] = e.rk end
        end
        return ids
    end
    build.skills.primary = bar(v.sf)
    build.skills.backup  = bar(v.sb)
    local ww = bar(v.sw)
    for _, id in ipairs(ww) do
        if id ~= 0 then build.skills.werewolf = ww; break end   -- only if it has a real ability
    end
    if next(ranks) then build.skills.ranks = ranks end

    build.attrs = { magicka = v.am or 0, health = v.ah or 0, stamina = v.as or 0 }
    if v.mn and v.mn ~= 0 then build.mundus = { id = v.mn } end
    if v.fd and v.fd ~= 0 then
        build.food = { id = v.fd }
        if v.fdi and v.fdi ~= 0 then   -- resolved food item -> the receiver rebuilds its rich tooltip
            build.food.itemId, build.food.subtype, build.food.level = v.fdi, v.fds or 0, v.fdl or 0
        end
    end

    for _, e in ipairs(v.cp or {}) do
        build.cp.slotted[#build.cp.slotted + 1] = e.sr or 0
        build.cp.points[#build.cp.points + 1]   = e.pt or 0
    end

    local cu = v.cu or 0
    if cu == 1 then build.curse = { type = "werewolf" }
    elseif cu >= 10 then build.curse = { type = "vampire", stage = cu - 10 } end

    local function statBar(t)
        t = t or {}
        return { magMax = t.m or 0, stamMax = t.s or 0, healthMax = t.h or 0,
                 dmg = t.d or 0, crit = t.c or 0, pen = t.p or 0,
                 critDmg = (t.cd and t.cd ~= 0) and t.cd or nil }
    end
    if v.hf then build.stats = { front = statBar(v.stf) } end
    if v.hb then build.stats = build.stats or {}; build.stats.back = statBar(v.stb) end

    build.class = { pure = v.pu and true or false, lines = {}, mastery = {} }
    for _, r in ipairs(v.cls or {}) do
        if r.sl and r.sl ~= 0 then build.class.lines[#build.class.lines + 1] = { sl = r.sl, cl = r.cl } end
    end
    for _, r in ipairs(v.mp or {}) do
        if r.a and r.a ~= 0 then build.class.mastery[#build.class.mastery + 1] = r.a end
    end

    if v.poi and v.poi ~= 0 then
        build.potion = { itemId = v.poi, subtype = v.pos or 0, level = v.pol or 0,
                         pd1 = v.pd1 or 0, pd2 = v.pd2 or 0 }
    end

    return build
end

--------------------------------------------------------------------------------
-- Dedup signature: a stable string of the NON-VOLATILE build fields only. EXCLUDES <stats> (moves
-- with every buff / the zone-load buff storm) and each gear record's condCharge (durability +
-- enchant charge tick down nonstop in combat). Both still transmit -- they just aren't "a change".
-- Both were real disconnect/flood bugs; see the Comms broadcast notes.
--------------------------------------------------------------------------------
function IV.SignatureOf(build)
    if type(build) ~= "table" then return "" end
    local parts = {}

    local g = {}
    for _, slot in ipairs(IV.GEAR_SLOTS) do
        local r = build.gear and build.gear[slot]
        if r then
            g[#g + 1] = table.concat({ n(slot), n(r.itemId), n(r.subtype), n(r.level),
                n(r.enchantId), n(r.enchantSub), n(r.enchantLevel), n(r.trait) }, ":")   -- no condCharge
        end
    end
    parts[#parts + 1] = table.concat(g, ",")

    local sk = build.skills or {}
    parts[#parts + 1] = joinIds(sk.primary, "-") .. "|" .. joinIds(sk.backup, "-") ..
                        "|" .. joinIds(sk.werewolf, "-")
    local rp = {}
    for id, rk in pairs(sk.ranks or {}) do rp[#rp + 1] = n(id) .. ":" .. n(rk) end
    table.sort(rp)   -- pairs() is unordered; sort so the signature is stable
    parts[#parts + 1] = table.concat(rp, ",")

    local a = build.attrs or {}
    parts[#parts + 1] = n(a.magicka) .. "-" .. n(a.health) .. "-" .. n(a.stamina)
    parts[#parts + 1] = (build.mundus and n(build.mundus.id)) or ""
    parts[#parts + 1] = build.food and (n(build.food.id) .. ":" .. n(build.food.itemId or 0)) or ""
    parts[#parts + 1] = build.curse and (build.curse.type .. tostring(build.curse.stage or "")) or ""
    parts[#parts + 1] = build.potion and (n(build.potion.itemId) .. ":" .. n(build.potion.subtype) ..
                                          ":" .. n(build.potion.level)) or ""

    local cpp = {}
    if build.cp and build.cp.slotted then
        for i, id in ipairs(build.cp.slotted) do
            cpp[i] = n(id) .. ":" .. n(build.cp.points and build.cp.points[i] or 0)
        end
    end
    parts[#parts + 1] = table.concat(cpp, "-")

    -- Class / subclass (a subclass swap or a mastery-passive change is a real build change).
    local cls = build.class
    if cls then
        local ls = {}
        for _, l in ipairs(cls.lines or {}) do ls[#ls + 1] = n(l.sl) .. ":" .. n(l.cl) end
        parts[#parts + 1] = (cls.pure and "P" or "S") .. "|" .. table.concat(ls, ",") ..
                            "|" .. joinIds(cls.mastery, "-")
    else
        parts[#parts + 1] = ""
    end

    return table.concat(parts, ";")
end

--------------------------------------------------------------------------------
-- COSMETICS wire format (a SECOND LGB protocol, id 421 -- see Comms.lua). Cosmetics change far less
-- often than a loadout, so they ride their own channel with their own change-trigger + dedup, fully
-- decoupled from the frequent build broadcast. Same schema conventions as the build (numeric id
-- fields, trimValues=true clamp, ArrayField headroom, all-fields-present sentinels).
--
-- Per armor/weapon slot we transmit RAW style refs (the receiver resolves them at DISPLAY time, so
-- the osid->collectible lookup runs on whoever views): oc = an applied outfit-override COLLECTIBLE
-- (already global), os = a base style's OUTFIT-STYLE id (resolved via IV.StyleCollectibleForOsid),
-- mo = the item's base style id (for the family-name label / no-collectible fallback). All are
-- global ids, so any client renders them (icon / GetCollectibleName / SetCollectible).
--   * IV.BuildCosmeticsSchema(LGB) -> the VariantField: req (group index) | cos (TableField). No `fo`
--     refusal variant -- the build channel already tells a non-friend "friends only", so the cosmetics
--     channel just stays silent to them (an empty Cosmetics view is self-explanatory).
--   * IV.EncodeCosmetics(cos, friendsOnly) / IV.DecodeCosmetics(values) -> our cosmetics table.
--   * IV.CosmeticsSignatureOf(cos)        -> broadcast-dedup signature (nothing volatile here).
--------------------------------------------------------------------------------
function IV.BuildCosmeticsSchema(LGB)
    local function num(label, maxValue, minValue)
        return LGB.CreateNumericField(label,
            { minValue = minValue or 0, maxValue = maxValue, trimValues = true })
    end

    local slotRec = LGB.CreateTableField("sl", {
        num("slot", 63), num("oc", ID_MAX), num("os", ID_MAX), num("mo", 65535),
        num("d1", 65535), num("d2", 65535), num("d3", 65535),   -- the visible appearance's dye ids (0 = undyed)
    })
    local cos = LGB.CreateTableField("cos", {
        LGB.CreateFlagField("fr"),                            -- friends-only marker
        LGB.CreateArrayField(slotRec, { maxLength = 20 }),    -- ~7 armor + up to 4 weapons; headroom
        num("co", ID_MAX), num("sk", ID_MAX), num("ha", ID_MAX), num("pe", ID_MAX),
        num("po", ID_MAX), num("fa", ID_MAX), num("pi", ID_MAX), num("hm", ID_MAX), num("bm", ID_MAX),
        num("mt", ID_MAX), num("pt", ID_MAX),                 -- mount + vanity pet
        num("cd1", 65535), num("cd2", 65535), num("cd3", 65535),   -- costume dyes
        num("hd1", 65535), num("hd2", 65535), num("hd3", 65535),   -- hat dyes
    })

    return LGB.CreateVariantField({
        num("req", 24, 1),            -- cosmetics request: target group index (1..24)
        cos,                          -- the cosmetics payload (2 variants is LGB's minimum)
    })
end

function IV.EncodeCosmetics(cos, friendsOnly)
    cos = cos or {}
    local v = { fr = friendsOnly and true or false }
    v.sl = {}
    for _, slot in ipairs(IV.GEAR_SLOTS) do
        local s = cos.slots and cos.slots[slot]
        if s then
            local dy = s.dyes or {}
            v.sl[#v.sl + 1] = { slot = n(slot), oc = n(s.ocoll), os = n(s.osid), mo = n(s.motif),
                                d1 = n(dy[1]), d2 = n(dy[2]), d3 = n(dy[3]) }
        end
    end
    v.co = n(cos.costume); v.sk = n(cos.skin); v.ha = n(cos.hat); v.pe = n(cos.personality)
    v.po = n(cos.polymorph); v.fa = n(cos.faceAdornment); v.pi = n(cos.piercing)
    v.hm = n(cos.headMarking); v.bm = n(cos.bodyMarking)
    v.mt = n(cos.mount); v.pt = n(cos.pet)
    local cd, hd = cos.costumeDyes or {}, cos.hatDyes or {}
    v.cd1, v.cd2, v.cd3 = n(cd[1]), n(cd[2]), n(cd[3])
    v.hd1, v.hd2, v.hd3 = n(hd[1]), n(hd[2]), n(hd[3])
    return v
end

function IV.DecodeCosmetics(v)
    if type(v) ~= "table" then return nil end
    local function dyeTriple(d1, d2, d3)   -- {d1,d2,d3} when any channel is dyed, else nil
        d1, d2, d3 = d1 or 0, d2 or 0, d3 or 0
        if d1 == 0 and d2 == 0 and d3 == 0 then return nil end
        return { d1, d2, d3 }
    end
    local cos = { slots = {} }
    for _, r in ipairs(v.sl or {}) do
        -- NOTE: EQUIP_SLOT_HEAD == 0, so slot 0 is valid.
        local ocoll = (r.oc and r.oc ~= 0) and r.oc or nil
        local osid  = (r.os and r.os ~= 0) and r.os or nil
        local motif = (r.mo and r.mo ~= 0) and r.mo or nil
        if ocoll or osid or motif then
            cos.slots[r.slot] = { ocoll = ocoll, osid = osid, motif = motif,
                                  dyes = dyeTriple(r.d1, r.d2, r.d3) }
        end
    end
    local function id(x) return (x and x ~= 0) and x or nil end
    cos.costume = id(v.co); cos.skin = id(v.sk); cos.hat = id(v.ha); cos.personality = id(v.pe)
    cos.polymorph = id(v.po); cos.faceAdornment = id(v.fa); cos.piercing = id(v.pi)
    cos.headMarking = id(v.hm); cos.bodyMarking = id(v.bm)
    cos.mount = id(v.mt); cos.pet = id(v.pt)
    cos.costumeDyes = dyeTriple(v.cd1, v.cd2, v.cd3)
    cos.hatDyes     = dyeTriple(v.hd1, v.hd2, v.hd3)
    return cos
end

function IV.CosmeticsSignatureOf(cos)
    if type(cos) ~= "table" then return "" end
    local function dy(t) t = t or {}; return n(t[1]) .. "." .. n(t[2]) .. "." .. n(t[3]) end
    local parts = {}
    local sl = {}
    for _, slot in ipairs(IV.GEAR_SLOTS) do
        local s = cos.slots and cos.slots[slot]
        if s then
            sl[#sl + 1] = table.concat({ n(slot), n(s.ocoll), n(s.osid), n(s.motif), dy(s.dyes) }, ":")
        end
    end
    parts[#parts + 1] = table.concat(sl, ",")
    parts[#parts + 1] = table.concat({ n(cos.costume), n(cos.skin), n(cos.hat), n(cos.personality),
        n(cos.polymorph), n(cos.faceAdornment), n(cos.piercing), n(cos.headMarking), n(cos.bodyMarking),
        n(cos.mount), n(cos.pet) }, "-")
    parts[#parts + 1] = dy(cos.costumeDyes) .. "|" .. dy(cos.hatDyes)
    return table.concat(parts, ";")
end
